/* SPDX-License-Identifier: GPL-2.0 */
/*Code based on https://github.com/xdp-project/xdp-tutorial/tree/master/advanced03-AF_XDP
Modified by Marcelo Abranches for mTCP/AF_XDP integration
(made0661@colorado.edu)*/
#include "io_module.h"
#ifndef DISABLE_AFXDP

#include <assert.h>
#include <getopt.h>
#include <locale.h>
#include <poll.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <sys/resource.h>

#include <bpf/bpf.h>
#include <bpf/xsk.h>

#include "afxdp_module.h"
/* for AF_XDP related def'ns */
//#include "../../afxdp/common/common_params.h"
//#include "../../afxdp/common/common_user_bpf_xdp.h"
//#define MAX_PKT_BURST 64

//#define NUM_FRAMES         4096
//#define FRAME_SIZE         XSK_UMEM__DEFAULT_FRAME_SIZE
//#define RX_BATCH_SIZE      64
//#define INVALID_UMEM_FRAME UINT64_MAX

/* for mtcp related def'ns */
#include "mtcp.h"
/* for errno */
#include <errno.h>
/* for logging */
#include "debug.h"
/* for num_devices_* */
#include "config.h"
/* for ETHER_CRC_LEN */
#include <net/ethernet.h>
/*----------------------------------------------------------------------------*/
#define MAX_IFNAMELEN			(IF_NAMESIZE + 10)

/*
 * Ethernet frame overhead
 */

#define ETHER_IFG			12
#define	ETHER_PREAMBLE			8
#define ETHER_OVR			(ETHER_CRC_LEN + ETHER_PREAMBLE + ETHER_IFG)

/*----------------------------------------------------------------------------*/


struct afxdp_private_context { //private context on mTCP
    int xsks_map_fd;
    struct bpf_map *map;
    struct xsk_umem_info *umem;
	struct xsk_socket_info *xsk_socket;
	struct bpf_object *bpf_obj;
    void *packet_buffer;
	uint64_t packet_buffer_size;
	uint32_t idx_rx;
	uint32_t idx_tx;
	uint64_t addr;
	//int rcvd;
	int processed_pkts;
	struct snd_list_info *snd_list;
	struct config cfg;
	struct pollfd fds[2];
}__attribute__((aligned(__WORDSIZE)));


/*----------------------------------------------------------------------------*/
void complete_tx(struct afxdp_private_context *axpc)
{
        //m-> this looks like a simple mechanism
        unsigned int completed;
        uint32_t idx_cq;

        if (!axpc->xsk_socket->outstanding_tx)
                return;

        //m-> this will produce a xdp_desc on the tx_ring
        sendto(xsk_socket__fd(axpc->xsk_socket->xsk), NULL, 0, MSG_DONTWAIT, NULL, 0);


        /* Collect/free completed TX buffers */
        //m-> now the completition queue is queried to see
        //which UMEM memmory frames can be freed and reused
        //to receive packets (so cq is the completition queue)
        completed = xsk_ring_cons__peek(&axpc->xsk_socket->umem->cq,
                                        XSK_RING_CONS__DEFAULT_NUM_DESCS,
                                        &idx_cq);

        //printf("completed transmission: %i\n", completed);

        if (completed > 0) {
                for (int i = 0; i < completed; i++)
                        xsk_free_umem_frame(axpc->xsk_socket,
                                            *xsk_ring_cons__comp_addr(&axpc->xsk_socket->umem->cq,
                                                                      idx_cq++));

                xsk_ring_cons__release(&axpc->xsk_socket->umem->cq, completed);
        }
        //m-> reset send index
        axpc->xsk_socket->outstanding_tx = 0;
        axpc->snd_list->send_index = 0;
}

/*----------------------------------------------------------------------------*/
//void config_af_xdp(struct config cfg, struct af_xdp_context *af_xdp_ctx)
void
afxdp_init_handle(struct mtcp_thread_context *ctxt)
{
	struct afxdp_private_context *axpc;
	char ifname[MAX_IFNAMELEN];
	char nifname[MAX_IFNAMELEN];
	int j;
//	char ethtool_command[50];
//        sprintf(ethtool_command, "ethtool -L %s combined %i", ifname, CONFIG.num_cores);


	/* create and initialize private I/O module context */
	ctxt->io_private_context = calloc(1, sizeof(struct afxdp_private_context));
	if (ctxt->io_private_context == NULL) {
		TRACE_ERROR("Failed to initialize ctxt->io_private_context: "
			    "Can't allocate memory\n");
		exit(EXIT_FAILURE);
	}

	axpc = (struct afxdp_private_context *)ctxt->io_private_context;


	struct rlimit rlim = {RLIM_INFINITY, RLIM_INFINITY};

	//m-> come back here to evaluate the multiple interface scenario
	//for (j = 0; j < num_devices_attached; j++) {
	for (j = 0; j < num_devices_attached; j++) {
		if (if_indextoname(devices_attached[j], ifname) == NULL) {
			TRACE_ERROR("Failed to initialize interface %s with ifidx: %d - "
				    "error string: %s\n",
				    ifname, devices_attached[j], strerror(errno));
			exit(EXIT_FAILURE);
		}
		
		axpc->bpf_obj = NULL;
		axpc->cfg.ifindex = devices_attached[j]; //(enp0s8) m-> 3 if not getting correctly from mTCP
		axpc->cfg.do_unload = 0;
		sprintf(axpc->cfg.filename, "../../afxdp/afxdp_kern.o");
		sprintf(axpc->cfg.progsec, "xdp_sock");
		axpc->cfg.ifname = malloc(MAX_IFNAMELEN);
		axpc->cfg.ifname = ifname;
		axpc->cfg.xsk_if_queue = ctxt->cpu;  //m-> set the receiving queue to the processing core number 

		//m-> enable poll mode
		axpc->cfg.xsk_poll_mode = 1;
	
		//m-> load xdp ebpf program in the Kernel
		if (ctxt->cpu != 0) //m-> change this to a pthread barrier
			sleep(2);
		if (ctxt->cpu == 0){
			printf("Initing XDP...\n");
			char ethtool_command[50];
	                sprintf(ethtool_command, "ethtool -L %s combined %i 2> /dev/null", ifname, CONFIG.num_cores);
        	        system(ethtool_command);
               		bzero(ethtool_command, sizeof(ethtool_command));

		//	char ethtool_command[50];
		//      	sprintf(ethtool_command, "ethtool -L %s combined %i", ifname, CONFIG.num_cores);
			//printf("ifname: %s\n", ifname);
			axpc->bpf_obj = load_bpf_and_xdp_attach(&axpc->cfg);
			if (!axpc->bpf_obj) {
				/* Error handling done in load_bpf_and_xdp_attach() */
				exit(EXIT_FAILURE);
			}
		
			/* We also need to load the xsks_map */
			axpc->map = bpf_object__find_map_by_name(axpc->bpf_obj, "xsks_map");
			//m-> Place xsk (xdp socket) in the xdp/ebpf map
			axpc->xsks_map_fd = bpf_map__fd(axpc->map);
			if (axpc->xsks_map_fd < 0) {
				fprintf(stderr, "ERROR: no xsks map found: %s\n",
					strerror(axpc->xsks_map_fd));
				exit(EXIT_FAILURE);
			}
	
		}

		/* Allow unlimited locking of memory, so all memory needed for packet
	 	* buffers can be locked.
	 	*/

		if (setrlimit(RLIMIT_MEMLOCK, &rlim)) {
			fprintf(stderr, "ERROR: setrlimit(RLIMIT_MEMLOCK) \"%s\"\n",
				strerror(errno));
			exit(EXIT_FAILURE);
		}

		axpc->packet_buffer_size = NUM_FRAMES * FRAME_SIZE;
		if (posix_memalign(&axpc->packet_buffer,
				getpagesize(), /* PAGE_SIZE aligned */
			   	axpc->packet_buffer_size)) {
				fprintf(stderr, "ERROR: Can't allocate buffer memory \"%s\"\n",
				strerror(errno));
			exit(EXIT_FAILURE);
		}

		/* Initialize shared packet_buffer for umem usage */
		axpc->umem = configure_xsk_umem(axpc->packet_buffer, axpc->packet_buffer_size);
		if (axpc->umem == NULL) {
			fprintf(stderr, "ERROR: Can't create umem \"%s\"\n",
				strerror(errno));
			exit(EXIT_FAILURE);
		}

		/* Open and configure the AF_XDP (xsk) socket */
		axpc->xsk_socket = xsk_configure_socket(&axpc->cfg, axpc->umem);
		if (axpc->xsk_socket == NULL) {
			fprintf(stderr, "ERROR: Can't setup AF_XDP socket \"%s\"\n",
				strerror(errno));
			exit(EXIT_FAILURE);
		}

	}
		if (axpc->cfg.xsk_poll_mode){
                        memset(axpc->fds, 0, sizeof(axpc->fds));
			axpc->fds[0].fd = xsk_socket__fd(axpc->xsk_socket->xsk);
			axpc->fds[0].events = POLLIN;
                }


		//m-> initialize snd_list
		axpc->snd_list = malloc(sizeof(struct snd_list_info));
		axpc->snd_list->send_index = 0;
}
/*----------------------------------------------------------------------------*/
int
afxdp_link_devices(struct mtcp_thread_context *ctxt)
{
	/* linking takes place during mtcp_init() */
	return 0;
}
/*----------------------------------------------------------------------------*/
void
afxdp_release_pkt(struct mtcp_thread_context *ctxt, int ifidx, unsigned char *pkt_data, int len){
	struct afxdp_private_context *axpc;
	//printf("afxdp_release_pkt\n");
	axpc = (struct afxdp_private_context *)ctxt->io_private_context;

	xsk_free_umem_frame(axpc->xsk_socket, axpc->addr);
}
/*----------------------------------------------------------------------------*/
//m-> remember to make this accessible from iom (call it core.c (line 802)
void afxdp_release_rx_ring(struct mtcp_thread_context *ctxt, int recv_cnt){
	struct afxdp_private_context *axpc;

	axpc = (struct afxdp_private_context *)ctxt->io_private_context;
	xsk_ring_cons__release(&axpc->xsk_socket->rx, recv_cnt);

}
/*----------------------------------------------------------------------------*/
int
afxdp_send_pkts(struct mtcp_thread_context *ctxt, int nif)
{
	struct afxdp_private_context *axpc;
	axpc = (struct afxdp_private_context *)ctxt->io_private_context;

	uint64_t addr;
	uint64_t len;
	int ret = 0;

	//printf("Sending data ...\n");
	//printf("outstanding_tx %i\n", axpc->xsk_socket->outstanding_tx);
	ret = xsk_ring_prod__reserve (&axpc->xsk_socket->tx, axpc->snd_list->send_index, &axpc->idx_tx);

	for (int i = 0; i < axpc->snd_list->send_index; i++)
	{
		addr = axpc->snd_list->addrs[i];
		len = axpc->snd_list->lens[i];

		//m->generate file descriptors as in my notebook page 51.
		xsk_ring_prod__tx_desc(&axpc->xsk_socket->tx, axpc->idx_tx)->addr = addr;
		xsk_ring_prod__tx_desc(&axpc->xsk_socket->tx, axpc->idx_tx++)->len = len;

		axpc->xsk_socket->outstanding_tx++;
		//printf("outstanding_tx %i\n", axpc->xsk_socket->outstanding_tx);

#ifdef NETSTAT  //m-> Review this
		mtcp->nstat.tx_packets[nif]++;
		mtcp->nstat.tx_bytes[nif] += len + ETHER_OVR;
#endif

	}
	//m->submit batc h to tx ring
	xsk_ring_prod__submit(&axpc->xsk_socket->tx, axpc->snd_list->send_index);
	//m-> send the batch
	complete_tx(axpc);
	return 1;
}
/*----------------------------------------------------------------------------*/
//m-> for more details of what needs to be done see my notebook (mtcp pktio), pages 44 and 54
//also see the get_wptr dpdk function to see more details
uint8_t
*afxdp_get_wptr(struct mtcp_thread_context *ctxt, int nif, uint16_t pktsize){
	struct afxdp_private_context *axpc;
	axpc = (struct afxdp_private_context *)ctxt->io_private_context;

	uint64_t addr;
	//m-> should I use pktsize (len) anywhere?
	addr = xsk_alloc_umem_frame(axpc->xsk_socket);
	//af_xdp_ctx->addr = xsk_alloc_umem_frame(af_xdp_ctx->xsk_socket);

	uint8_t *pktbuf = xsk_umem__get_data(axpc->xsk_socket->umem->buffer, addr);

	axpc->snd_list->addrs[axpc->snd_list->send_index] = addr;
	axpc->snd_list->lens[axpc->snd_list->send_index] = pktsize;
	axpc->snd_list->send_index++;

	return pktbuf;
}
/*----------------------------------------------------------------------------*/
//static void handle_receive_packets(struct xsk_socket_info *xsk)
int32_t
afxdp_recv_pkts(struct mtcp_thread_context *ctxt, int ifidx)
{
	struct afxdp_private_context *axpc;
	axpc = (struct afxdp_private_context *)ctxt->io_private_context;


	int ret, nfds = 1;
	if(axpc->cfg.xsk_poll_mode){
		//ret = poll(axpc->fds, nfds, -1);
		//ret = poll(axpc->fds, nfds, 2);
		ret = poll(axpc->fds, nfds, 10);
		if(ret < 1)
			return 0;	

	}

	unsigned int rcvd, stock_frames, i;
	uint32_t idx_fq = 0;
	ret = 0;
	rcvd = xsk_ring_cons__peek(&axpc->xsk_socket->rx, RX_BATCH_SIZE, &axpc->idx_rx);
	//rcvd = xsk_ring_cons__peek(&axpc->xsk_socket->rx, 1, &axpc->idx_rx);

	//if(rcvd > 0)
	//printf("af_xdp_ctx->idx_rx: %u, on cpu: %i\n", axpc->idx_rx, ctxt->cpu);

	if (!rcvd)
		return 0;

		/* Stuff the ring with as much frames as possible */
		//m-> fq is the fill queue
		stock_frames = xsk_prod_nb_free(&axpc->xsk_socket->umem->fq,
					xsk_umem_free_frames(axpc->xsk_socket));

		if (stock_frames > 0) {

			ret = xsk_ring_prod__reserve(&axpc->xsk_socket->umem->fq, stock_frames,
					     &idx_fq);

			/* This should not happen, but just in case */
			while (ret != stock_frames)
				ret = xsk_ring_prod__reserve(&axpc->xsk_socket->umem->fq, rcvd,
						     &idx_fq);

		//m-> apps use the fill ring to send addresses
		//to the kernel in which it should fill in rx pkts
		//references to these frames will then appear on the
		//rx ring once each packet has been received (umem->fq
		//is the fill queue)
			for (i = 0; i < stock_frames; i++)
				*xsk_ring_prod__fill_addr(&axpc->xsk_socket->umem->fq, idx_fq++) =
					xsk_alloc_umem_frame(axpc->xsk_socket);

			xsk_ring_prod__submit(&axpc->xsk_socket->umem->fq, stock_frames);
		}
//	printf("recvd: %i\n", rcvd);
	return rcvd;
}
/*----------------------------------------------------------------------------*/
//m-> function to return the pointers to mTCP (This should iterate through to the number of
//recv pkts and return pointers to pkts to be processed by mTCP)
uint8_t
*afxdp_get_rptr(struct mtcp_thread_context *ctxt, int ifidx, int index, uint16_t *len)
{
	struct afxdp_private_context *axpc;
	//printf("retrieving *rptr\n");
	axpc = (struct afxdp_private_context *)ctxt->io_private_context;

	axpc->addr = xsk_ring_cons__rx_desc(&axpc->xsk_socket->rx, axpc->idx_rx)->addr;
	*len = xsk_ring_cons__rx_desc(&axpc->xsk_socket->rx, axpc->idx_rx++)->len;

	uint8_t *pktbuf = xsk_umem__get_data(axpc->xsk_socket->umem->buffer, axpc->addr);

	return pktbuf;
}
/*----------------------------------------------------------------------------*/
int32_t
afxdp_select(struct mtcp_thread_context *ctxt)
{
//m-> implement
}
/*----------------------------------------------------------------------------*/
void
afxdp_destroy_handle(struct mtcp_thread_context *ctxt)
{
	struct afxdp_private_context *axpc;
	axpc = (struct afxdp_private_context *)ctxt->io_private_context;

	xsk_socket__delete(axpc->xsk_socket->xsk);
	xsk_umem__delete(axpc->umem->umem);
	xdp_link_detach(axpc->cfg.ifindex, axpc->cfg.xdp_flags, 0);
}
/*----------------------------------------------------------------------------*/
void
afxdp_load_module(void)
{
	/* not needed - all initializations done in netmap_init_handle() */
}

/*----------------------------------------------------------------------------*/
io_module_func afxdp_module_func = {
	.load_module		   = afxdp_load_module,
	.init_handle		   = afxdp_init_handle,
	.link_devices		   = afxdp_link_devices,
	.release_pkt		   = afxdp_release_pkt,
	.send_pkts		   = afxdp_send_pkts,
	.get_wptr   		   = afxdp_get_wptr,
	.recv_pkts		   = afxdp_recv_pkts,
	.get_rptr	   	   = afxdp_get_rptr,
	.select			   = afxdp_select,
	.destroy_handle		   = afxdp_destroy_handle,
	.release_rx_ring	   = afxdp_release_rx_ring,
	.dev_ioctl		   = NULL
};
/*----------------------------------------------------------------------------*/
/*#else
io_module_func afxdp_module_func = {
	.load_module		   = NULL,
	.init_handle		   = NULL,
	.link_devices		   = NULL,
	.release_pkt		   = NULL,
	.send_pkts		   = NULL,
	.get_wptr   		   = NULL,
	.recv_pkts		   = NULL,
	.get_rptr	   	   = NULL,
	.select			   = NULL,
	.destroy_handle		   = NULL,
	.release_rx_ring	   = NULL,
	.dev_ioctl		   = NULL
};*/
/*----------------------------------------------------------------------------*/
#endif /* !DISABLE_AFXDP */
