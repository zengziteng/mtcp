#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/shm.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/queue.h>
#include <assert.h>
#include <stdbool.h>
#include <assert.h>
#include <bits/stdc++.h>
#include <rpc/server.h>

#include <bpf/bpf.h>
#include <bpf/xsk.h>
#include <bpf/libbpf.h>
#include <bpf/libbpf.h>

#include "serverless.h"


#ifndef __NR_pidfd_getfd
#define __NR_pidfd_getfd 438
#endif


const char* http_response_header = 
"HTTP/1.1 200 OK\r\n"
"Connection: close\r\n"
"Content-Type: text/plain\r\n"
"Content-Length:             \r\n\r\n";

int http_response_header_len = strlen(http_response_header);

int listener_to_client_handler_pipe[2];
int client_handler_to_skmsg_pipe[2];
int skmsg_to_client_handler_pipe[2];

const char* rpc_ip = NULL;

struct GatewayListener{
    int ep_id;
    int listenfd;
    epoll_event events[EPOLL_MAX_NUM_BUFFERS];
    epoll_event ev;

    void init() {
        int ret;
        listenfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        assert(listenfd != -1);

        int flags = fcntl(listenfd, F_GETFL, 0);
        assert(flags != -1);
        ret = fcntl(listenfd, F_SETFL, flags | O_NONBLOCK);
        assert(ret != -1);

        int one = 1;
        ret = setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, (char*)&one, sizeof(one));
        assert(ret == 0);

        sockaddr_in srv_addr;

        srv_addr.sin_family = AF_INET;
        srv_addr.sin_port = htons(HTTP_PORT);
        srv_addr.sin_addr.s_addr = INADDR_ANY;
        ret = bind(listenfd, (struct sockaddr*)&srv_addr, sizeof(srv_addr));
        assert(ret == 0);

        ret = listen(listenfd, 1000);
        assert(ret == 0);
        
        ep_id = epoll_create(EPOLL_MAX_NUM_BUFFERS);
        assert(ep_id != -1);

        ev.events = EPOLLIN;
        ev.data.fd = listenfd;
        ret = epoll_ctl(ep_id, EPOLL_CTL_ADD, listenfd, &ev);
        assert(ret == 0);
    }

    void run() {
        int ret;
        while(true) {
            int nevents = epoll_wait(ep_id, events, EPOLL_MAX_NUM_BUFFERS, -1);

            #ifdef SERVERLESS_DBG
            printf("[listener] nevents %d\n", nevents);
            #endif
            
            if(nevents < 0) {
                break;
            }

            bool do_accept = false;

            for(int i=0; i<nevents; i++) {
                int eventid = events[i].events;
                assert(!(eventid & EPOLLHUP));
                assert(!(eventid & EPOLLERR));

                int sockid = events[i].data.fd;
                assert(sockid == listenfd);

                #ifdef SERVERLESS_DBG
                printf("[listener] server eventid: %d event: %s %s %s\n", eventid,
                        eventid & EPOLLIN ? "IN" : "", eventid & EPOLLHUP ? "HUP" : "", eventid & EPOLLERR ? "ERR" : "");
                #endif

                if(sockid == listenfd && (eventid & EPOLLIN)) {
                    do_accept = true;
                }
            }

            if(do_accept) {
                while(true) {
                    int cfd = accept(listenfd, NULL, NULL);
                    if(cfd < 0) {
                        break;
                    }

                    #ifdef SERVERLESS_DBG
                    printf("[listener] accept new client %d\n", cfd);
                    #endif

                    int flags = fcntl(cfd, F_GETFL, 0);
                    assert(flags != -1);
                    ret = fcntl(cfd, F_SETFL, flags | O_NONBLOCK);
                    assert(ret != -1);

                    ssize_t bytes_written = write(listener_to_client_handler_pipe[1], &cfd, 4);
                    assert(bytes_written == 4);
                }
            }
        }

        close(listenfd);
    }
};
GatewayListener gatewayListener;

struct SharedMemoryManager{
    int next_free_idx = 0;
    int frames[HTTP_TRANSACTION_CNT];

    void init() {
        // initialize frames array
        for(int i=0; i<HTTP_TRANSACTION_CNT; i++) {
            frames[i] = i;
        }
    }

    int allocate_frame() {
        assert(next_free_idx != HTTP_TRANSACTION_CNT);
        return frames[next_free_idx++];
    }

    void free_frame(int frame) {
        assert(frame != -1);
        frames[--next_free_idx] = frame;
    }
};


struct GatewayClientHandler{
    int ep_id;
    epoll_event events[EPOLL_MAX_NUM_BUFFERS];
    epoll_event ev;

    // the segment id of shared memory
    int segment_id;
    // the shared memory
    HttpTransaction* transactions;

    SharedMemoryManager sharedMemoryManager;

    void init() {
        int ret;
        segment_id = shmget(rand(), sizeof(HttpTransaction) * HTTP_TRANSACTION_CNT, IPC_CREAT | 0666);
        assert(segment_id != -1);

        transactions = (HttpTransaction*)shmat(segment_id, NULL, 0);
        assert(transactions != (HttpTransaction*)-1);

        sharedMemoryManager.init();

        ep_id = epoll_create(EPOLL_MAX_NUM_BUFFERS);
        assert(ep_id != -1);

        ev.events = EPOLLIN;
        ev.data.fd = listener_to_client_handler_pipe[0];
        ret = epoll_ctl(ep_id, EPOLL_CTL_ADD, listener_to_client_handler_pipe[0], &ev);
        assert(ret == 0);

        ev.events = EPOLLIN;
        ev.data.fd = skmsg_to_client_handler_pipe[0];
        ret = epoll_ctl(ep_id, EPOLL_CTL_ADD, skmsg_to_client_handler_pipe[0], &ev);
        assert(ret == 0);
    }

    void add_new_client() {
        int ret;
        while(true) {
            int cfd;
            ssize_t bytes_read = read(listener_to_client_handler_pipe[0], &cfd, 4);
            if(bytes_read == -1) {
                if(errno == EAGAIN) {
                    break;
                }else{
                    assert(0);
                }
            }
            assert(bytes_read == 4);

            #ifdef SERVERLESS_DBG
            printf("[ClientHandler] add new client %d to epoll\n", cfd);
            #endif

            int frame = sharedMemoryManager.allocate_frame();
            HttpTransaction* tran = &transactions[frame];
            tran->sockid = cfd;
            tran->frame = frame;
            tran->recv_cur_pos = 0;
            tran->send_cur_pos = 0;
            tran->header_length = http_response_header_len;
            tran->content_length = 0;
            memcpy(tran->response, http_response_header, http_response_header_len);

            ev.events = EPOLLIN;
            ev.data.ptr = tran;

            ret = epoll_ctl(ep_id, EPOLL_CTL_ADD, cfd, &ev);
            assert(ret == 0);
        }
    }

    void write_response() {
        int ret;
        while(true) {
            int frame;
            ssize_t bytes_read = read(skmsg_to_client_handler_pipe[0], &frame, 4);
            if(bytes_read == -1) {
                if(errno == EAGAIN) {
                    break;
                }else{
                    assert(0);
                }
            }
            assert(bytes_read == 4);

            HttpTransaction* tran = &transactions[frame];

            #ifdef SERVERLESS_DBG
            printf("[ClientHandler] send response to client %d\n", tran->sockid);
            #endif

            char* res_data = &tran->response[tran->header_length];
            char* res_content_len = res_data - 16;
            int null_offset = sprintf(res_content_len, "%d", tran->content_length);
            res_content_len[null_offset] = ' ';

            int to_write = tran->header_length + tran->content_length;
            while(tran->send_cur_pos < to_write) {
                ssize_t written = send(tran->sockid, &tran->response[tran->send_cur_pos], to_write - tran->send_cur_pos, 0);
                assert(written != -1);
                tran->send_cur_pos += written;
            }

            ret = epoll_ctl(ep_id, EPOLL_CTL_DEL, tran->sockid, NULL);
            assert(ret == 0);
            ret = close(tran->sockid);
            assert(ret == 0);

            // recycle the frame
            sharedMemoryManager.free_frame(tran->frame);
        }
    }

    void get_request(HttpTransaction* tran) {
        assert(tran != NULL);

        #ifdef SERVERLESS_DBG
        printf("[ClientHandler] epoll_in on %d\n", tran->sockid);
        #endif

        ssize_t bytes_read = read(tran->sockid, &tran->request[tran->recv_cur_pos], HTTP_MSG_LENGTH_REQUEST_MAX - tran->recv_cur_pos);
        assert(bytes_read != -1);

        tran->recv_cur_pos += bytes_read;
        if(tran->request[tran->recv_cur_pos-4] == '\r' &&
            tran->request[tran->recv_cur_pos-3] == '\n' &&
            tran->request[tran->recv_cur_pos-2] == '\r' &&
            tran->request[tran->recv_cur_pos-1] == '\n') {
                ssize_t bytes_written = write(client_handler_to_skmsg_pipe[1], &tran->frame, 4);
                assert(bytes_written == 4);
        }
    }

    void run() {
        int ret;
        while(true) {
            int nevents = epoll_wait(ep_id, events, EPOLL_MAX_NUM_BUFFERS, -1);

            #ifdef SERVERLESS_DBG
            printf("[ClientHandler] nevents %d\n", nevents);
            #endif

            for(int i=0; i<nevents; i++) {
                int eventid = events[i].events;
                assert(!(eventid & EPOLLHUP));
                assert(!(eventid & EPOLLERR));

                if(events[i].data.fd == listener_to_client_handler_pipe[0]) {
                    assert(eventid & EPOLLIN);
                    add_new_client();
                }else if(events[i].data.fd == skmsg_to_client_handler_pipe[0]) {
                    assert(eventid & EPOLLIN);
                    write_response();
                }else{
                    assert(eventid & EPOLLIN);
                    printf("eventid = %d\n", eventid);
                    get_request((HttpTransaction*)events[i].data.ptr);
                }
            }
        }
    }
};
GatewayClientHandler gatewayClientHandler;


struct GatewaySkMsg{
    int skmsg_prog_fd;
    int skmsg_map_fd;

    int dummy_server_socket_fd;
    int skmsg_socket_fd;

    int ep_id;
    epoll_event events[EPOLL_MAX_NUM_BUFFERS];
    epoll_event ev;

    void init() {
        // load program
        struct bpf_object* obj;
        int ret = bpf_prog_load("../../afxdp/mtcp_xdp_pktio/sk_msg_kern.o", BPF_PROG_TYPE_SK_MSG, &obj, &skmsg_prog_fd);
        assert(ret == 0);

        // get map fd
        skmsg_map_fd = bpf_object__find_map_fd_by_name(obj, "sock_map");
        assert(skmsg_map_fd >= 0);

        // attach map
        ret = bpf_prog_attach(skmsg_prog_fd, skmsg_map_fd, BPF_SK_MSG_VERDICT, 0);
        assert(ret == 0);

        // create dummy server
        dummy_server_socket_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        assert(dummy_server_socket_fd != -1);

        int one = 1;
        ret = setsockopt(dummy_server_socket_fd, SOL_SOCKET, SO_REUSEADDR, (char*)&one, sizeof(one));
        assert(ret == 0);

        struct sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(SK_MSG_PORT);
        addr.sin_addr.s_addr = inet_addr(rpc_ip);

        ret = bind(dummy_server_socket_fd, (struct sockaddr*)&addr, sizeof(addr));
        assert(ret == 0);

        ret = listen(dummy_server_socket_fd, 100);
        assert(ret == 0);

        std::thread t([this](){
            while(true) {
                int connection_socket = accept(this->dummy_server_socket_fd, NULL, NULL);
                assert(connection_socket != -1);
            }
        });
        t.detach();

        // create skmsg socket
        skmsg_socket_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        assert(skmsg_socket_fd != -1);

        ret = connect(skmsg_socket_fd, (struct sockaddr*)&addr, sizeof(addr));
        assert(ret == 0);

        int flags = fcntl(skmsg_socket_fd, F_GETFL, 0);
        assert(flags != -1);
        ret = fcntl(skmsg_socket_fd, F_SETFL, flags | O_NONBLOCK);
        assert(ret != -1);

        int key = 0;
        ret = bpf_map_update_elem(skmsg_map_fd, &key, &skmsg_socket_fd, 0); 
        assert(ret == 0);

        ep_id = epoll_create(EPOLL_MAX_NUM_BUFFERS);
        assert(ep_id != -1);

        ev.events = EPOLLIN;
        ev.data.fd = client_handler_to_skmsg_pipe[0];
        ret = epoll_ctl(ep_id, EPOLL_CTL_ADD, client_handler_to_skmsg_pipe[0], &ev);
        assert(ret == 0);

        ev.events = EPOLLIN;
        ev.data.fd = skmsg_socket_fd;
        ret = epoll_ctl(ep_id, EPOLL_CTL_ADD, skmsg_socket_fd, &ev);
        assert(ret == 0);
    }

    void begin_function_chain() {
        int ret;
        while(true) {
            int frame;
            ssize_t bytes_read = read(client_handler_to_skmsg_pipe[0], &frame, 4);
            if(bytes_read == -1) {
                if(errno == EAGAIN) {
                    break;
                }else{
                    assert(0);
                }
            }
            assert(bytes_read == 4);

            Meta meta;
            meta.next_func_id = 1;
            meta.frame = frame;
            meta.timestamp = get_time_nano();

            int ret = send(skmsg_socket_fd, &meta, sizeof(meta), 0);
            assert(ret == sizeof(meta));
        }
    }

    void end_function_chain() {
        int ret;
        while(true) {
            Meta meta;
            ssize_t bytes_read = recv(skmsg_socket_fd, &meta, sizeof(meta), 0);
            if(bytes_read == -1) {
                if(errno == EAGAIN) {
                    break;
                }else{
                    assert(0);
                }
            }
            assert(bytes_read == sizeof(meta));

            ssize_t bytes_written = write(skmsg_to_client_handler_pipe[1], &meta.frame, 4);
            assert(bytes_written == 4);
        }
    }

    void run() {
        int ret;
        while(true) {
            int nevents = epoll_wait(ep_id, events, EPOLL_MAX_NUM_BUFFERS, -1);

            #ifdef SERVERLESS_DBG
            printf("[SkMsg] nevents %d\n", nevents);
            #endif

            for(int i=0; i<nevents; i++) {
                int eventid = events[i].events;
                assert(!(eventid & EPOLLHUP));
                assert(!(eventid & EPOLLERR));

                if(events[i].data.fd == client_handler_to_skmsg_pipe[0]) {
                    assert(eventid & EPOLLIN);
                    begin_function_chain();
                }else if(events[i].data.fd == skmsg_socket_fd) {
                    assert(eventid & EPOLLIN);
                    end_function_chain();
                }
            }
        }
    }
};

GatewaySkMsg gatewaySkMsg;

void usage() {
    printf("Usage: ./gateway {-b (bind ip for rpc and sk_msg)}\n");
    exit(1);
}

int main(int argc, char* argv[]) {
    int ret;
    rpc::server *rpc_srv;
    

    while(1) {
        int opt = getopt(argc, argv, "b:");
        if(opt == -1){
            break;
        }

        switch(opt)
        {
            case 'b':
                rpc_ip = optarg;
                break;
            default:
                break;
        }
    }

    if(rpc_ip == NULL) {
        usage();
    }

    ret = pipe2(listener_to_client_handler_pipe, O_NONBLOCK);
    assert(ret == 0);
    ret = pipe2(client_handler_to_skmsg_pipe, O_NONBLOCK);
    assert(ret == 0);
    ret = pipe2(skmsg_to_client_handler_pipe, O_NONBLOCK);
    assert(ret == 0);

    gatewayListener.init();
    gatewayClientHandler.init();
    gatewaySkMsg.init();
    
    rpc_srv = new rpc::server(rpc_ip, RPC_PORT);
    // add rpc
    rpc_srv->bind(RPC_GET_SHM_SEGMENT_ID, [&](){return gatewayClientHandler.segment_id;});
    rpc_srv->bind(RPC_UPDATE_SOCKMAP, [&](int fun_pid, int fun_sk_msg_sock_fd, int key){
        int pidfd = syscall(SYS_pidfd_open, fun_pid, 0);
        assert(pidfd != -1);

        int sock_fd = syscall(__NR_pidfd_getfd, pidfd, fun_sk_msg_sock_fd, 0);
        assert(sock_fd != -1);

        int ret = bpf_map_update_elem(gatewaySkMsg.skmsg_map_fd, &key, &sock_fd, 0);
        assert(ret == 0);

        #ifdef SERVERLESS_DBG
        printf("sockmap pos %d updated\n", key);
        #endif
    });

    std::thread t([&](){
        gatewayListener.run();
    });
    t.detach();

    std::thread t2([&](){
        gatewayClientHandler.run();
    });
    t2.detach();

    std::thread t3([&](){
        gatewaySkMsg.run();
    });
    t3.detach();

    rpc_srv->run();

    return 0;
}

