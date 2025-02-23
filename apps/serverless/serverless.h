#pragma once

#define SERVERLESS_DBG

#define HTTP_PORT 8080
#define RPC_PORT 8081
#define SK_MSG_PORT 8082

#define HTTP_TRANSACTION_CNT 8000
#define HTTP_MSG_LENGTH_REQUEST_MAX 1024
#define HTTP_MSG_LENGTH_RESPONSE_MAX 1024

#define EPOLL_MAX_NUM_BUFFERS 1000

struct HttpTransaction {
    int sockid;
    int frame;
    int recv_cur_pos;
    int send_cur_pos;
    int header_length;
    int content_length;

    char request[HTTP_MSG_LENGTH_REQUEST_MAX];
    char response[HTTP_MSG_LENGTH_RESPONSE_MAX];
};


// int()
#define RPC_GET_SHM_SEGMENT_ID "get_shm_segment_id"
// void(int fun_pid, int fun_sk_msg_sock_fd, int key)
#define RPC_UPDATE_SOCKMAP "rpc_update_sockmap"

struct Meta{
    int next_func_id;
    int frame;
    long timestamp;
};





void get_monotonic_time(struct timespec* ts)
{
    clock_gettime(CLOCK_MONOTONIC, ts);
}

long get_time_nano(struct timespec* ts)
{
    return (long)ts->tv_sec * 1e9 + ts->tv_nsec;
}

long get_time_nano()
{
    timespec ts;
    get_monotonic_time(&ts);
    return get_time_nano(&ts);
}

double get_elapsed_time_sec(struct timespec* before, struct timespec* after)
{
    double deltat_s  = after->tv_sec - before->tv_sec;
    double deltat_ns = after->tv_nsec - before->tv_nsec;
    return deltat_s + deltat_ns*1e-9;
}

long get_elapsed_time_nano(struct timespec* before, struct timespec* after)
{
    return get_time_nano(after) - get_time_nano(before);
}