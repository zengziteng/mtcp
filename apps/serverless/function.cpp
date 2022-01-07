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
#include <rpc/client.h>
#include <arpa/inet.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/in.h>
#include <linux/tcp.h>
#include <sched.h>

#include "serverless.h"

const char* gateway_rpc_ip = NULL;

void usage() {
    printf("Usage: ./function {-i function_id} {-n next_function_id} {-g gateway_rpc_ip} [-c bind_to_cpu_core]\n");
    exit(1);
}

int main(int argc, char* argv[]) {
    HttpTransaction* transactions;
    int skmsg_socket_fd;
    int segment_id;

    int fun_id = -1;
    int next_fun_id = -1;
    int bind_to_cpu_core = -1;

    while(1) {
        int opt = getopt(argc, argv, "i:n:c:g:");
        if(opt == -1){
            break;
        }

        switch(opt)
        {
            case 'i':
                fun_id = atoi(optarg);
                break;
            case 'n':
                next_fun_id = atoi(optarg);
                break;
            case 'c':
                bind_to_cpu_core = atoi(optarg);
                break;
            case 'g':
                gateway_rpc_ip = optarg;
                break;
            default:
                break;
        }
    }
    if(fun_id == -1 || next_fun_id == -1 || gateway_rpc_ip == NULL) {
        usage();
    }

    if(bind_to_cpu_core == -1) {
        printf("using function id as cpu core id for binding\n");
        bind_to_cpu_core = fun_id;
    }

    cpu_set_t mask;
    CPU_ZERO(&mask);
    CPU_SET(fun_id, &mask);
    int ret = sched_setaffinity(0, sizeof(mask), &mask);
    assert(ret == 0);

    rpc::client rpc_client(gateway_rpc_ip, RPC_PORT);
    segment_id = rpc_client.call(RPC_GET_SHM_SEGMENT_ID).as<int>();
    assert(segment_id != -1);

    #ifdef SERVERLESS_DBG
    printf("segment id is %d\n", segment_id);
    #endif

    transactions = (HttpTransaction*)shmat(segment_id, NULL, 0);
    assert(transactions != (HttpTransaction*)-1);

    // create skmsg socket
    skmsg_socket_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    assert(skmsg_socket_fd != -1);

    // connect to gateway
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(SK_MSG_PORT);
    addr.sin_addr.s_addr = inet_addr(gateway_rpc_ip);

    ret = connect(skmsg_socket_fd, (struct sockaddr*)&addr, sizeof(addr));
    assert(ret == 0);

    rpc_client.call(RPC_UPDATE_SOCKMAP, (int)getpid(), skmsg_socket_fd, fun_id);

    while(1) {
        Meta meta;
        ret = recv(skmsg_socket_fd, &meta, sizeof(meta), 0);
        assert(ret == sizeof(meta));

        long timestamp = get_time_nano();
        #ifdef SERVERLESS_DBG
        printf("delta time in nanoseconds: %ld\n", timestamp - meta.timestamp);
        #endif

        HttpTransaction* tran = &transactions[meta.frame];
        char* buffer = &tran->response[tran->header_length + tran->content_length];
        int newLen = sprintf(buffer,
                "Function %d processing, time: %ld, delta time: %ld\n", fun_id, timestamp, timestamp - meta.timestamp);
        tran->content_length += newLen;

        Meta meta_send;
        meta_send.next_func_id = next_fun_id;
        meta_send.frame = meta.frame;
        meta_send.timestamp = timestamp;

        ret = send(skmsg_socket_fd, &meta_send, sizeof(meta_send), 0);
        assert(ret == sizeof(meta_send));
    }
}
