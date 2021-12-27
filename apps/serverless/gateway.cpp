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

#include <mtcp_api.h>
#include <mtcp_epoll.h>

#include <bpf/bpf.h>
#include <bpf/xsk.h>
#include <bpf/libbpf.h>
#include <bpf/libbpf.h>

#include "serverless.h"

#ifndef SO_PREFER_BUSY_POLL
#define SO_PREFER_BUSY_POLL	69
#endif

#ifndef SO_BUSY_POLL_BUDGET
#define SO_BUSY_POLL_BUDGET 70
#endif

#ifndef __NR_pidfd_getfd
#define __NR_pidfd_getfd 438
#endif


#define HTTP_PORT 8080

const char* http_response_header = 
"HTTP/1.1 200 OK\r\n"
"Connection: close\r\n"
"Content-Type: text/plain\r\n"
"Content-Length:         \r\n\r\n";

int http_response_header_len = strlen(http_response_header);
mctx_t mctx;
int ep_id;

struct Server{
    rpc::server rpc_srv = rpc::server(RPC_PORT);

    // the segment id of shared memory
    int segment_id;
    // the data region of umem
    char* data;

    int skmsg_prog_fd;
    int skmsg_map_fd;

    int dummy_server_socket_fd;
    int skmsg_socket_fd;

    // the index in frames array
    int next_free_idx = 0;
    int frames[SHARED_MEM_FRAME_CNT];

    void create() {
        segment_id = shmget(rand(), SHARED_MEM_SIZE, IPC_CREAT | 0666);
        assert(segment_id != -1);

        data = (char*)shmat(segment_id, NULL, 0);
        assert(data != (char*)-1);

        // initialize frames array
        for(int i=0; i<SHARED_MEM_FRAME_CNT; i++) {
            frames[i] = i;
        }

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
        addr.sin_addr.s_addr = inet_addr("127.0.0.1");

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

        int key = 0;
        ret = bpf_map_update_elem(skmsg_map_fd, &key, &skmsg_socket_fd, 0); 
        assert(ret == 0);

        // add rpc
        rpc_srv.bind(RPC_GET_SHM_SEGMENT_ID, [this](){return this->segment_id;});
        rpc_srv.bind(RPC_UPDATE_SOCKMAP, [this](int fun_pid, int fun_sk_msg_sock_fd, int key){
            int pidfd = syscall(SYS_pidfd_open, fun_pid, 0);
            assert(pidfd != -1);

            int sock_fd = syscall(__NR_pidfd_getfd, pidfd, fun_sk_msg_sock_fd, 0);
            assert(sock_fd != -1);

            int ret = bpf_map_update_elem(this->skmsg_map_fd, &key, &sock_fd, 0);
            assert(ret == 0);

            #ifdef SERVERLESS_DBG
            printf("sockmap pos %d updated\n", key);
            #endif
        });
    }

    int allocate_frame() {
        assert(next_free_idx != SHARED_MEM_FRAME_CNT);
        return frames[next_free_idx++];
    }

    void free_frame(int frame) {
        assert(frame != 0);
        frames[--next_free_idx] = frame;
    }

    void run_rpc_async() {
        std::thread t([this](){
            this->rpc_srv.run();
        });
        t.detach();
    }

    void skmsg_ingress(int frame) {
        Meta meta;
        meta.next_func_id = 1;
        meta.frame = frame;
        meta.timestamp = get_time_nano();
        
        int ret = send(skmsg_socket_fd, &meta, sizeof(meta), 0);
        assert(ret == sizeof(meta));
    }

    void run_skmsg_egress_async() {
        std::thread t([this](){
            while(1) {
                Meta meta;
                int ret = recv(this->skmsg_socket_fd, &meta, sizeof(meta), 0);
                assert(ret == sizeof(meta));

                #ifdef SERVERLESS_DBG
                printf("send http response back to client\n");
                #endif

                RequestFrame* p_request_frame = (RequestFrame*)&this->data[meta.frame * SHARED_MEM_FRAME_SIZE];
                ResponseFrame* p_response_frame = (ResponseFrame*)&this->data[meta.frame * SHARED_MEM_FRAME_SIZE + SHARED_MEM_SUBFRAME_OFFSET];
                
                sprintf(&p_response_frame->data[p_response_frame->header_len - 12], "%d", p_response_frame->data_len);
                p_response_frame->data[p_response_frame->header_len - 12 + strlen(&p_response_frame->data[p_response_frame->header_len - 12])] = ' ';

                ret = mtcp_write(mctx, p_request_frame->sockid, p_response_frame->data, p_response_frame->header_len + p_response_frame->data_len);
                assert(ret == p_response_frame->header_len + p_response_frame->data_len);

                ret = mtcp_epoll_ctl(mctx, ep_id, MTCP_EPOLL_CTL_DEL, p_request_frame->sockid, NULL);
                assert(ret == 0);
                ret = mtcp_close(mctx, p_request_frame->sockid);
                assert(ret == 0);
            }
        });
        t.detach();
    }
    
};

int main(int argc, char* argv[]) {
    
    struct mtcp_conf mcfg;
    int core = 0;
    int listenfd;
    struct sockaddr_in srv_addr;
    int ret;
    struct mtcp_epoll_event *events;
	struct mtcp_epoll_event ev;
    

    Server server;
    server.create();
    server.run_rpc_async();
    server.run_skmsg_egress_async();

    mtcp_getconf(&mcfg);
    mcfg.num_cores = 1;
    mtcp_setconf(&mcfg);

    ret = mtcp_init("gateway.conf");
    assert(ret == 0);

    ret = mtcp_core_affinitize(core);
    assert(ret == 0);

    mctx = mtcp_create_context(core);
    assert(mctx != NULL);

    listenfd = mtcp_socket(mctx, AF_INET, SOCK_STREAM, 0);
    assert(listenfd != -1);

    ret = mtcp_setsock_nonblock(mctx, listenfd);
    assert(ret == 0);

    srv_addr.sin_family = AF_INET;
    srv_addr.sin_port = htons(HTTP_PORT);
    srv_addr.sin_addr.s_addr = INADDR_ANY;
    ret = mtcp_bind(mctx, listenfd, (struct sockaddr*)&srv_addr, sizeof(srv_addr));
    assert(ret == 0);

    ret = mtcp_listen(mctx, listenfd, 1000);
    assert(ret == 0);

    events = new mtcp_epoll_event[mcfg.max_num_buffers];
    assert(events != NULL);
    
    ep_id = mtcp_epoll_create(mctx, mcfg.max_num_buffers);
    assert(ep_id != -1);

    ev.events = MTCP_EPOLLIN;
    ev.data.sockid = listenfd;
    ret = mtcp_epoll_ctl(mctx, ep_id, MTCP_EPOLL_CTL_ADD, listenfd, &ev);
    assert(ret == 0);

    while(1) {
        int nevents = mtcp_epoll_wait(mctx, ep_id, events, mcfg.max_num_buffers, -1);
        #ifdef SERVERLESS_DBG
        printf("nevents %d\n", nevents);
        #endif
        
        if(nevents < 0) {
            break;
        }

        for(int i=0; i<nevents; i++) {
            int sockid = events[i].data.sockid;
            int eventid = events[i].events;
            #ifdef SERVERLESS_DBG
            printf("sockid is %d\n", sockid);
            #endif

            if(sockid == listenfd) {
                #ifdef SERVERLESS_DBG
                printf("socket: server    event: %s\n", eventid == MTCP_EPOLLIN ? "IN" : "OUT");
                #endif
                if(eventid == MTCP_EPOLLIN) {
                    #ifdef SERVERLESS_DBG
                    printf("accept new client\n");
                    #endif
                    int cfd = mtcp_accept(mctx, listenfd, NULL, NULL);
                    assert(cfd != -1);

                    ret = mtcp_setsock_nonblock(mctx, cfd);
                    assert(ret == 0);

                    int frame = server.allocate_frame();
                    RequestFrame* p_request_frame = (RequestFrame*)&server.data[frame * SHARED_MEM_FRAME_SIZE];
                    p_request_frame->sockid = cfd;
                    p_request_frame->frame = frame;
                    p_request_frame->recv_cur_pos = 0;

                    ev.events = MTCP_EPOLLIN | MTCP_EPOLLOUT;
                    ev.data.sockid = cfd;
                    ev.data.ptr = p_request_frame;                   

                    #ifdef SERVERLESS_DBG
                    printf("set ev.data.ptr = %p\n", ev.data.ptr);
                    printf("set client fd to %d\n", cfd);
                    #endif

                    ret = mtcp_epoll_ctl(mctx, ep_id, MTCP_EPOLL_CTL_ADD, cfd, &ev);
                    assert(ret == 0);
                }
            }else{
                #ifdef SERVERLESS_DBG
                printf("socket: client    event: %s %s\n", eventid & MTCP_EPOLLIN ? "IN" : "", eventid & MTCP_EPOLLOUT ? "OUT" : "");
                #endif
                if(eventid & MTCP_EPOLLIN) {
                    RequestFrame* p_request_frame = (RequestFrame*)events[i].data.ptr;
                    assert(p_request_frame != NULL);
                    sockid = p_request_frame->sockid;

                    #ifdef SERVERLESS_DBG
                    printf("get events[i].data.ptr = %p\n", p_request_frame);
                    printf("data->recv_cur_pos %d\n", p_request_frame->recv_cur_pos);
                    #endif

                    int len = mtcp_read(mctx, sockid, &p_request_frame->buffer[p_request_frame->recv_cur_pos], SHARED_MEM_SUBFRAME_OFFSET - 9 - p_request_frame->recv_cur_pos);
                    assert(len != -1);
                    p_request_frame->recv_cur_pos += len;
                    #ifdef SERVERLESS_DBG
                    printf("receive request data of len %d from client\n", len);
                    #endif
                    
                    if(p_request_frame->recv_cur_pos >= 4) {
                        if(p_request_frame->buffer[p_request_frame->recv_cur_pos-4] == '\r' &&
                           p_request_frame->buffer[p_request_frame->recv_cur_pos-3] == '\n' &&
                           p_request_frame->buffer[p_request_frame->recv_cur_pos-2] == '\r' &&
                           p_request_frame->buffer[p_request_frame->recv_cur_pos-1] == '\n'){
                               ResponseFrame* p_response_frame = (ResponseFrame*)&server.data[p_request_frame->frame * SHARED_MEM_FRAME_SIZE + SHARED_MEM_SUBFRAME_OFFSET];
                               p_response_frame->header_len = http_response_header_len;
                               p_response_frame->data_len = 0;
                               memcpy(p_response_frame->data, http_response_header, http_response_header_len);
                               server.skmsg_ingress(p_request_frame->frame);
                           }
                    }

                }
            }
        }
    }

    printf("mtcp_destroy\n");
    
    mtcp_destroy_context(mctx);
    mtcp_destroy();

    return 0;
}