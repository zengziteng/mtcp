/* SPDX-License-Identifier: GPL-2.0 */
/*Code based on https://github.com/xdp-project/xdp-tutorial/tree/master/advanced03-AF_XDP
Modified by Marcelo Abranches (made0661@colorado.edu)*/


#include <linux/bpf.h>

#include <bpf/bpf_helpers.h>

//m-> send arp and icmp to userspace
#include <bpf/bpf_endian.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <linux/ipv6.h>
#include <linux/ip.h>
#include <linux/icmpv6.h>
#include <linux/icmp.h>
#define IPPROTO_ICMP 1




struct bpf_map_def SEC("maps") xsks_map = {
	.type = BPF_MAP_TYPE_XSKMAP,
	.key_size = sizeof(int),
	.value_size = sizeof(int),
	.max_entries = 64,  /* Assume netdev has no more than 64 queues */
};

/* Header cursor to keep track of current parsing position */
struct hdr_cursor {
        void *pos;
};


static __always_inline int parse_ethhdr(struct hdr_cursor *nh,
                                        void *data_end,
                                        struct ethhdr **ethhdr)
{
        struct ethhdr *eth = nh->pos;
        __u16 h_proto;

        if (eth + 1 > data_end)
                return -1;

        nh->pos = eth + 1;

        h_proto = eth->h_proto;
        
        return h_proto; /* network-byte-order */
}




static __always_inline int parse_ip4hdr(struct hdr_cursor *nh,
                                        void *data_end,
                                        struct iphdr **iphdr)
{
         __u16 ip_proto;

        struct iphdr *iph = nh->pos;
        
        //int hdrsize ;
        
        if (iph + 1 > data_end)
                return -1;

        //hdrsize = iph->ihl * 4;

        //nh->pos += hdrsize;
        
        //nh->pos = iph + 100000;

        //*iphdr = iph;


        ip_proto = iph->protocol;

        return ip_proto;

}




SEC("xdp_sock")
int xdp_sock_prog(struct xdp_md *ctx)
{
    int nh_type;
    struct hdr_cursor nh;
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;
    struct ethhdr *eth;
    struct iphdr *ip;


    int index = ctx->rx_queue_index;
    
        /* A set entry here means that the correspnding queue_id
    * has an active AF_XDP socket bound to it. */

    //m-> create code to determine if a packet is an ARP request or
    //or an ICMP request. If so send to Kernel
    /* Start next header cursor position at data start */
    nh.pos = data;

    nh_type = parse_ethhdr(&nh, data_end, &eth);

    //if (nh_type == 1544)
    if (nh_type ==  bpf_htons(ETH_P_ARP))
        return XDP_PASS;

    else if (nh_type == bpf_htons(ETH_P_IP)){
        nh_type =  parse_ip4hdr(&nh, data_end, &ip);
        bpf_printk("nh_type: %i",  nh_type);

     //   if (nh_type == IPPROTO_ICMP)
     //       return XDP_PASS;
    }

    //AF_XDP code
    if (bpf_map_lookup_elem(&xsks_map, &index))
        return bpf_redirect_map(&xsks_map, index, 0); //this sends the pkt to user space

    return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
