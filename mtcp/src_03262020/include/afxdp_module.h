//#include "../common/common_params.h"
//#include "../common/common_user_bpf_xdp.h"
#include "/home/vagrant/mtcp/afxdp/common/common_params.h"
#include "/home/vagrant/mtcp/afxdp/common/common_user_bpf_xdp.h"
#include <errno.h>
#define MAX_PKT_BURST 64
//#include "../common/common_libbpf.h"


#define NUM_FRAMES         4096
#define FRAME_SIZE         XSK_UMEM__DEFAULT_FRAME_SIZE
#define RX_BATCH_SIZE      64
#define INVALID_UMEM_FRAME UINT64_MAX


struct snd_list_info {
	uint64_t addrs[MAX_PKT_BURST]; //addr of the pkt
	uint64_t lens[MAX_PKT_BURST]; //len of the pkt
	int send_index;
};

struct xsk_umem_info {
	struct xsk_ring_prod fq;
	struct xsk_ring_cons cq;
	struct xsk_umem *umem;
	void *buffer;
};

struct xsk_socket_info {
	struct xsk_ring_cons rx;
	struct xsk_ring_prod tx;
	struct xsk_umem_info *umem;
	struct xsk_socket *xsk;

	uint64_t umem_frame_addr[NUM_FRAMES];
	uint32_t umem_frame_free;

	uint32_t outstanding_tx;

};

static struct xsk_umem_info *configure_xsk_umem(void *buffer, uint64_t size)
{
	struct xsk_umem_info *umem;
	int ret;

	umem = calloc(1, sizeof(*umem));
	if (!umem)
		return NULL;

	ret = xsk_umem__create(&umem->umem, buffer, size, &umem->fq, &umem->cq,
			       NULL);
	if (ret) {
		errno = -ret;
		return NULL;
	}

	umem->buffer = buffer;
	return umem;
}

static uint64_t xsk_alloc_umem_frame(struct xsk_socket_info *xsk)
{
	uint64_t frame;
	if (xsk->umem_frame_free == 0)
		return INVALID_UMEM_FRAME;

	frame = xsk->umem_frame_addr[--xsk->umem_frame_free];
	xsk->umem_frame_addr[xsk->umem_frame_free] = INVALID_UMEM_FRAME;
	return frame;
}

static void xsk_free_umem_frame(struct xsk_socket_info *xsk, uint64_t frame)
{
	assert(xsk->umem_frame_free < NUM_FRAMES);

	xsk->umem_frame_addr[xsk->umem_frame_free++] = frame;
}

static uint64_t xsk_umem_free_frames(struct xsk_socket_info *xsk)
{
	return xsk->umem_frame_free;
}

static struct xsk_socket_info *xsk_configure_socket(struct config *cfg,
						    struct xsk_umem_info *umem)
{
	struct xsk_socket_config xsk_cfg;
	struct xsk_socket_info *xsk_info;
	uint32_t idx;
	uint32_t prog_id = 0;
	int i;
	int ret;

	xsk_info = calloc(1, sizeof(*xsk_info));
	if (!xsk_info)
		return NULL;

	xsk_info->umem = umem;
	xsk_cfg.rx_size = XSK_RING_CONS__DEFAULT_NUM_DESCS;
	xsk_cfg.tx_size = XSK_RING_PROD__DEFAULT_NUM_DESCS;
	xsk_cfg.libbpf_flags = 0;
	xsk_cfg.xdp_flags = cfg->xdp_flags;
	xsk_cfg.bind_flags = cfg->xsk_bind_flags;
	ret = xsk_socket__create(&xsk_info->xsk, cfg->ifname,
				 cfg->xsk_if_queue, umem->umem, &xsk_info->rx,
				 &xsk_info->tx, &xsk_cfg);

	if (ret)
		goto error_exit;

	ret = bpf_get_link_xdp_id(cfg->ifindex, &prog_id, cfg->xdp_flags);
	if (ret)
		goto error_exit;

	/* Initialize umem frame allocation */

	for (i = 0; i < NUM_FRAMES; i++)
		xsk_info->umem_frame_addr[i] = i * FRAME_SIZE;

	xsk_info->umem_frame_free = NUM_FRAMES;

	/* Stuff the receive path with buffers, we assume we have enough */
	ret = xsk_ring_prod__reserve(&xsk_info->umem->fq,
				     XSK_RING_PROD__DEFAULT_NUM_DESCS,
				     &idx);

	if (ret != XSK_RING_PROD__DEFAULT_NUM_DESCS)
		goto error_exit;

	for (i = 0; i < XSK_RING_PROD__DEFAULT_NUM_DESCS; i ++)
		*xsk_ring_prod__fill_addr(&xsk_info->umem->fq, idx++) =
			xsk_alloc_umem_frame(xsk_info);

	xsk_ring_prod__submit(&xsk_info->umem->fq,
			      XSK_RING_PROD__DEFAULT_NUM_DESCS);

	return xsk_info;

error_exit:
	errno = -ret;
	return NULL;
}

//static void complete_tx(struct af_xdp_private_context *axpc)
//{
//	//m-> this looks like a simple mechanism
//	unsigned int completed;
//	uint32_t idx_cq;
//
//	if (!axpc->xsk_socket->outstanding_tx)
//		return;

//	//m-> this will produce a xdp_desc on the tx_ring
//	sendto(xsk_socket__fd(axpc->xsk_socket->xsk), NULL, 0, MSG_DONTWAIT, NULL, 0);
//

	/* Collect/free completed TX buffers */
	//m-> now the completition queue is queried to see
	//which UMEM memmory frames can be freed and reused
	//to receive packets (so cq is the completition queue) 
//	completed = xsk_ring_cons__peek(&axpc->xsk_socket->umem->cq,
//					XSK_RING_CONS__DEFAULT_NUM_DESCS,
//					&idx_cq);

//	printf("completed transmission: %i\n", completed);

//	if (completed > 0) {
//		for (int i = 0; i < completed; i++)
//			xsk_free_umem_frame(axpc->xsk_socket,
//					    *xsk_ring_cons__comp_addr(&axpc->xsk_socket->umem->cq,
//								      idx_cq++));
//
//		xsk_ring_cons__release(&axpc->xsk_socket->umem->cq, completed);
//	}
//	//m-> reset send index
//	af_xdp_ctx->xsk_socket->outstanding_tx = 0;
//	af_xdp_ctx->snd_list->send_index = 0;
//}

/*struct snd_list_info {
	uint64_t addrs[MAX_PKT_BURST]; //addr of the pkt
	uint64_t lens[MAX_PKT_BURST]; //len of the pkt
	int send_index;
};

struct af_xdp_private_context { //private context on mTCP
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
	int rcvd;
	struct snd_list_info *snd_list;
	struct config cfg;
}__attribute__((aligned(__WORDSIZE)));*/


//m->declarations below will not be needed
/*void config_af_xdp(struct mtcp_thread_context *ctxt);

void tear_down_af_xdp(struct mtcp_thread_context *ctxt);

unsigned int afxdp_recv_pkts(struct mtcp_thread_context *ctxt, int rx_inf);

uint8_t *afxdp_get_rptr(struct mtcp_thread_context *ctxt, int ifidx, int index, uint16_t *len);

void release_rx_ring(struct mtcp_thread_context *ctxt);

void afxdp_release_pkt(struct mtcp_thread_context *ctxt);

void af_xdp_send_pkts(struct mtcp_thread_context *ctxt, int rx_inf);

uint8_t *af_xdp_get_wptr(struct mtcp_thread_context *ctxt, int rx_inf, uint16_t pktsize);
*/

/*
void config_af_xdp(struct config cfg, struct mtcp_thread_context *ctxt);

void tear_down_af_xdp(struct config cfg, struct mtcp_thread_context *ctxt);

unsigned int afxdp_recv_pkts(struct mtcp_thread_context *ctxt, int rx_inf);

uint8_t *afxdp_get_rptr(struct mtcp_thread_context *ctxt, int ifidx, int index, uint16_t *len);

void release_rx_ring(struct mtcp_thread_context *ctxt);

void afxdp_release_pkt(struct mtcp_thread_context *ctxt);

void af_xdp_send_pkts(struct mtcp_thread_context *ctxt, int rx_inf);

uint8_t *af_xdp_get_wptr(struct mtcp_thread_context *ctxt, int rx_inf, uint16_t pktsize);
*/
