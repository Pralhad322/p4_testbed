/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;
register<bit<32>>(8) buffer;
register<bit<32>>(1) packet_counter;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    tos;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

struct metadata {
    bit<32> current_queue_bound;
    bit<32> rank;
}

struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }
}

/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    
    register<bit<32>>(8) threshold;

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action sort_8() {
        bit<32> r0; 
        bit<32> r1; 
        bit<32> r2; 
        bit<32> r3;
        bit<32> r4; 
        bit<32> r5; 
        bit<32> r6; 
        bit<32> r7;
        bit<32> tmp;

        buffer.read(r0, 0); 
        buffer.read(r1, 1); 
        buffer.read(r2, 2); 
        buffer.read(r3, 3);
        buffer.read(r4, 4); 
        buffer.read(r5, 5); 
        buffer.read(r6, 6); 
        buffer.read(r7, 7);

        if (r0 > r1) { tmp = r0; r0 = r1; r1 = tmp; }
        if (r2 > r3) { tmp = r2; r2 = r3; r3 = tmp; }
        if (r4 > r5) { tmp = r4; r4 = r5; r5 = tmp; }
        if (r6 > r7) { tmp = r6; r6 = r7; r7 = tmp; }
        if (r0 > r2) { tmp = r0; r0 = r2; r2 = tmp; }
        if (r1 > r3) { tmp = r1; r1 = r3; r3 = tmp; }
        if (r4 > r6) { tmp = r4; r4 = r6; r6 = tmp; }
        if (r5 > r7) { tmp = r5; r5 = r7; r7 = tmp; }
        if (r1 > r2) { tmp = r1; r1 = r2; r2 = tmp; }
        if (r5 > r6) { tmp = r5; r5 = r6; r6 = tmp; }
        if (r0 > r4) { tmp = r0; r0 = r4; r4 = tmp; }
        if (r1 > r5) { tmp = r1; r1 = r5; r5 = tmp; }
        if (r2 > r6) { tmp = r2; r2 = r6; r6 = tmp; }
        if (r3 > r7) { tmp = r3; r3 = r7; r7 = tmp; }
        if (r1 > r2) { tmp = r1; r1 = r2; r2 = tmp; }
        if (r3 > r4) { tmp = r3; r3 = r4; r4 = tmp; }
        if (r5 > r6) { tmp = r5; r5 = r6; r6 = tmp; }
        if (r2 > r3) { tmp = r2; r2 = r3; r3 = tmp; }
        if (r4 > r5) { tmp = r4; r4 = r5; r5 = tmp; }
        if (r6 > r7) { tmp = r6; r6 = r7; r7 = tmp; }
        if (r4 > r6) { tmp = r4; r4 = r6; r6 = tmp; }
        if (r5 > r7) { tmp = r5; r5 = r7; r7 = tmp; }
        if (r3 > r4) { tmp = r3; r3 = r4; r4 = tmp; }

        buffer.write(0, r0); 
        buffer.write(1, r1); 
        buffer.write(2, r2); 
        buffer.write(3, r3);
        buffer.write(4, r4); 
        buffer.write(5, r5); 
        buffer.write(6, r6); 
        buffer.write(7, r7);
    }

    action clear_top_4() {
        buffer.write(4, 0xFFFFFFFF);
        buffer.write(5, 0xFFFFFFFF);
        buffer.write(6, 0xFFFFFFFF);
        buffer.write(7, 0xFFFFFFFF);
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    action Quantile_calculation() {
        bit<32> previous_threshold;
        buffer.read(previous_threshold, 0);
        threshold.write(0, previous_threshold);
        buffer.read(previous_threshold, 1);
        threshold.write(1, previous_threshold);
        buffer.read(previous_threshold, 2);
        threshold.write(2, previous_threshold);
        buffer.read(previous_threshold, 3);
        threshold.write(3, previous_threshold);
        buffer.read(previous_threshold, 4);
        threshold.write(4, previous_threshold);
        buffer.read(previous_threshold, 5);
        threshold.write(5, previous_threshold);
        buffer.read(previous_threshold, 6);
        threshold.write(6, previous_threshold);
        buffer.read(previous_threshold, 7);
        threshold.write(7, previous_threshold);
    }

    apply {
        bit<32> count;
        meta.rank = (bit<32>)hdr.ipv4.tos;
        packet_counter.read(count, 0);
        packet_counter.write(0, count + 1);
        if (count + 1 < 8) {
            buffer.write(count + 1, meta.rank); 
        }else{
            sort_8();
            Quantile_calculation();
            clear_top_4();
            packet_counter.write(0, count - 4);
            buffer.write(count + 1, meta.rank);  
        }

        threshold.read(meta.current_queue_bound, 0);
        if((meta.current_queue_bound >= meta.rank)){
            standard_metadata.priority = (bit<3>)0;
        }else{
            threshold.read(meta.current_queue_bound, 1);
            if((meta.current_queue_bound >= meta.rank)){
                standard_metadata.priority = (bit<3>)1;
            }else{
                threshold.read(meta.current_queue_bound, 2);
                if((meta.current_queue_bound >= meta.rank)){
                    standard_metadata.priority = (bit<3>)2;
                }else{
                    threshold.read(meta.current_queue_bound, 3);
                    if((meta.current_queue_bound >= meta.rank)){
                        standard_metadata.priority = (bit<3>)3;
                    }else{
                        threshold.read(meta.current_queue_bound, 4);
                        if((meta.current_queue_bound >= meta.rank)){
                            standard_metadata.priority = (bit<3>)4;
                        }else{
                            threshold.read(meta.current_queue_bound, 5);
                            if((meta.current_queue_bound >= meta.rank)){
                                standard_metadata.priority = (bit<3>)5;
                            }else{
                                threshold.read(meta.current_queue_bound, 6);
                                if((meta.current_queue_bound >= meta.rank)){
                                    standard_metadata.priority = (bit<3>)6;
                                }else{
                                    standard_metadata.priority = (bit<3>)7;
                                }
                            }
                        }
                    }
                }
            }
        }

        ipv4_lpm.apply();
    }
}


/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply { }
}

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
     apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { hdr.ipv4.version,
              hdr.ipv4.ihl,
              hdr.ipv4.tos,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;