/* SPDX-License-Identifier: GPL-2.0 */
/*Code based on https://github.com/xdp-project/xdp-tutorial/tree/master/advanced03-AF_XDP
Modified by Marcelo Abranches (made0661@colorado.edu)*/


#include <linux/bpf.h>

#include <bpf/bpf_helpers.h>


struct bpf_map_def SEC("maps") xsks_map = {
	.type = BPF_MAP_TYPE_XSKMAP,
	.key_size = sizeof(int),
	.value_size = sizeof(int),
	.max_entries = 64,  /* Assume netdev has no more than 64 queues */
};


SEC("xdp_sock")
int xdp_sock_prog(struct xdp_md *ctx)
{

    int index = ctx->rx_queue_index;
    
    //AF_XDP code
    if (bpf_map_lookup_elem(&xsks_map, &index))
        return bpf_redirect_map(&xsks_map, index, 0); //this sends the pkt to user space
    else
	 return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
