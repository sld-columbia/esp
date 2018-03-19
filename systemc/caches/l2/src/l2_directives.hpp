/* Copyright 2017 Columbia University, SLD Group */

#ifndef __L2_DIRECTIVES_HPP__
#define __L2_DIRECTIVES_HPP__

#define L2_FLATTEN_REGS				\
    HLS_FLATTEN_ARRAY(reqs);			\
    HLS_FLATTEN_ARRAY(tag_buf);			\
    HLS_FLATTEN_ARRAY(state_buf);		\
    HLS_FLATTEN_ARRAY(hprot_buf);		\
    HLS_FLATTEN_ARRAY(lines_buf);

// Reset
#define L2_RESET_IO				\
    HLS_DEFINE_PROTOCOL("l2-reset-io-protocol")
#define RESET_STATES_LOOP				\
    HLS_DEFINE_PROTOCOL("l2-reset-states-protocol")

// Debug
#define REQS_OUTPUT					\
    HLS_UNROLL_LOOP(ON, "l2-reqs-output-unroll")	
#define BUFS_OUTPUT					\
    HLS_UNROLL_LOOP(ON, "l2-bufs-output-unroll")	

// Input messages
#define GET_CPU_REQ							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get cpu req.")
// bookmark_tmp |= BM_GET_CPU_REQ;
#define L2_GET_FWD_IN
// bookmark_tmp |= BM_GET_FWD_IN
#define L2_GET_RSP_IN
// bookmark_tmp |= BM_GET_RSP_IN
#define GET_FLUSH							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get flush.")
// bookmark_tmp |= BM_GET_FLUSH;			
// #define RSP_WHILE_FLUSHING						
//     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "ERROR: Rsp while flushing."); 
//     asserts_tmp |= AS_RSP_WHILE_FLUSHING

// Output messages 
#define SEND_REQ_OUT							\
    HLS_DEFINE_PROTOCOL("l2-send-req-protocol");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send req out.")
// bookmark_tmp |= BM_SEND_REQ_OUT;			
#define SEND_RD_RSP							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rd rsp.")
// bookmark_tmp |= BM_SEND_RD_RSP;      	    
#define SEND_INVAL							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send inval.")
// bookmark_tmp |= BM_SEND_INVAL;			
#define SEND_RSP_OUT							\
    HLS_DEFINE_PROTOCOL("l2-send-rsp-protocol");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rsp out.")
// bookmark_tmp |= BM_SEND_RSP_OUT;			
// Buffered lines
#define FILL_REQS							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fill-reqs-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fill reqs.")
// bookmark_tmp |= BM_FILL_REQS;			
#define PUT_REQS							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-put-reqs-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Put reqs.")
// bookmark_tmp |= BM_PUT_REQS;			
// Search for cache lines
#define TAG_LOOKUP							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-tag-lookup-latency");	\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Tag lookup.")
// bookmark_tmp |= BM_TAG_LOOKUP;				       
#define TAG_LOOKUP_FWD							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-tag-lookup-fwd-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Tag lookup fwd.")
// bookmark_tmp |= BM_TAG_LOOKUP;				       
#define TAG_LOOKUP_LOOP					\
    HLS_UNROLL_LOOP(ON, "l2-tag-lookup-loop-unroll")
#define TAG_LOOKUP_FWD_LOOP					\
    HLS_UNROLL_LOOP(ON, "l2-tag-lookup-fwd-loop-unroll")
#define REQS_LOOKUP							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-reqs-lookup-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reqs lookup.")
// bookmark_tmp |= BM_REQS_LOOKUP;					
#define REQS_LOOKUP_LOOP				\
    HLS_UNROLL_LOOP(ON, "l2-reqs-lookup-loop-unroll")
// #define REQS_LOOKUP_ASSERT						
//     if (!reqs_hit || reqs[reqs_hit_i].state == INVALID) asserts_tmp |= AS_REQS_LOOKUP
#define REQS_PEEK_REQ							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-reqs-peek-req-latency"); \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reqs peek req.")
// bookmark_tmp |= BM_REQS_PEEK_REQ;					
#define REQS_PEEK_REQ_LOOP				\
    HLS_UNROLL_LOOP(ON, "l2-reqs-peek-req-loop-unroll")
#define REQS_PEEK_FWD							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-reqs-peek-fwd-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reqs peek fwd.")
// bookmark_tmp |= BM_REQS_PEEK_FWD;					
#define REQS_PEEK_FWD_LOOP				\
    HLS_UNROLL_LOOP(ON, "l2-reqs-peek-fwd-loop-unroll")

// Manage flush
#define FLUSH_READ_SET							\
    HLS_CONSTRAIN_LATENCY(0, 1, "l2-flush-read-set-latency"); \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Flush read set.")
// bookmark_tmp |= BM_FLUSH_READ_SET;					
#define FLUSH_LOOP					\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-flush-loop-latency")
#define FLUSH_END					\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-flush-end-latency")

// Manage rsp in
#define RSP_IN							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-rsp-in-latency")
#define RSP_EDATA_ISD							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-rsp-edata-isd-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp edata isd.")
// bookmark_tmp |= BM_RSP_EDATA_ISD;					
#define RSP_DATA_ISD							\
	HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-rsp-data-isd-latency");		\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data isd.")
// bookmark_tmp |= BM_RSP_DATA_ISD;					
#define RSP_DATA_XMAD							\
	HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-rsp-data-xmad-latency");		\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data xmad.")
// bookmark_tmp |= BM_RSP_DATA_XMAD;					
// if (rsp_in.coh_msg == RSP_EDATA) asserts_tmp |= AS_RSP_DATA_XMAD;
#define RSP_DATA_XMADW							\
	HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-rsp-data-xmadw-latency");		\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data xmadw.")
// bookmark_tmp |= BM_RSP_DATA_XMADW;					
// if (rsp_in.coh_msg == RSP_EDATA) asserts_tmp |= AS_RSP_DATA_XMADW;	
#define RSP_DATA_DEFAULT						\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data default.")
// asserts_tmp |= AS_RSP_DATA_DEFAULT;		
#define RSP_INVACK_ALL							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-rsp-invack-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp invack all.")
// bookmark_tmp |= BM_RSP_INVACK;					
#define RSP_INVACK_DEFAULT
// asserts_tmp |= AS_RSP_INVACK_DEFAULT
#define RSP_DEFAULT
// asserts_tmp |= AS_RSP_DEFAULT

// Manage fwd in
#define FWD_IN							\
	HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-in-latency")
#define FWD_STALL_BEGIN							\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd stall begin.")
// bookmark_tmp |= BM_FWD_STALL_BEGIN;					
#define FWD_HIT_SMADX							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-hit-smadx-latency"); \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit smadx.")
// bookmark_tmp |= BM_FWD_HIT_SMADX;					
// if (fwd_in.coh_msg != FWD_INV) asserts_tmp |= AS_HIT_SMADX;		
#define FWD_HIT_EMIA							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-hit-emia-latency"); \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit emia.")
// bookmark_tmp |= BM_FWD_HIT_EMIA;					
// if (fwd_in.coh_msg == FWD_INV) asserts_tmp |= AS_HIT_EMIA;		
#define FWD_HIT_SIA							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-hit-sia-latency");	\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit sia.")
// bookmark_tmp |= BM_FWD_HIT_SIA;					
// if (fwd_in.coh_msg != FWD_INV) asserts_tmp |= AS_HIT_SMADX;		
#define FWD_HIT_DEFAULT							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit default.")
// asserts_tmp |= AS_FWD_HIT_DEFAULT;					
#define FWD_NOHIT_GETS							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-nohit-gets-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit gets.")
// bookmark_tmp |= BM_FWD_NOHIT_GETS;					
#define FWD_NOHIT_GETM							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-nohit-getm-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit getm.")
// bookmark_tmp |= BM_FWD_NOHIT_GETM;					
#define FWD_NOHIT_INV							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-nohit-inv-latency");	\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit inv.")
// bookmark_tmp |= BM_FWD_NOHIT_INV;					
#define FWD_NOHIT_DEFAULT						\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit default.")
// asserts_tmp |= AS_FWD_NOHIT_DEFAULT;				
#define FWD_PUTACK_ALL							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-fwd-putack-latency");	\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd putack all.")
// bookmark_tmp |= BM_FWD_PUTACK;					
#define PUTACK_DEFAULT							\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Put ack default.")
// asserts_tmp |= AS_PUTACK_DEFAULT;					

// Manage cpu req
#define SET_CONFLICT							\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Set conflict.")
// bookmark_tmp |= BM_SET_CONFLICT;					
#define ATOMIC_OVERRIDE							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-atom-override-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Atomic override.")
// bookmark_tmp |= BM_ATOMIC_OVERRIDE;					
#define ATOMIC_CONTINUE							\
	HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-atom-continue-latency");		\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Atomic continue.")
// bookmark_tmp |= BM_ATOMIC_CONTINUE;					
#define HIT_READ \
    HLS_CONSTRAIN_LATENCY(0, 1, "l2-hit-read-latency"); \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit read.")
// bookmark_tmp |= BM_HIT_READ;					
#define HIT_READ_ATOMIC_S \
   HLS_CONSTRAIN_LATENCY(0, 1, "l2-hit-read-atomic-latency")
// bookmark_tmp |= BM_HIT_READ_ATOMIC_S
#define HIT_READ_ATOMIC_EM						\
    HLS_CONSTRAIN_LATENCY(0, 1, "l2-hit-read-atomic-em-latency")
// bookmark_tmp |= BM_HIT_READ_ATOMIC_EM;			
#define HIT_READ_ATOMIC_DEFAULT						\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit read-atomic default.")
// asserts_tmp |= AS_HIT_READ_ATOMIC_DEFAULT;		
#define HIT_WRITE_S							\
    HLS_CONSTRAIN_LATENCY(0, 1, "l2-hit-write-latency")
    // bookmark_tmp |= BM_HIT_WRITE_S
#define HIT_WRITE_EM					\
    HLS_CONSTRAIN_LATENCY(0, 1, "l2-hit-write-em-latency")
    // bookmark_tmp |= BM_HIT_WRITE_EM;			
#define HIT_WRITE_DEFAULT				
// if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit write default.")
// asserts_tmp |= AS_HIT_WRITE_DEFAULT;		
#define HIT_DEFAULT							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit default.")
// asserts_tmp |= AS_HIT_DEFAULT;					
#define MISS_READ							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-miss-read-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss read.")
// bookmark_tmp |= BM_MISS_READ;			
#define MISS_READ_ATOMIC						\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-miss-read-atomic-latency");		\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss read atomic.")
// bookmark_tmp |= BM_MISS_READ_ATOMIC;			
#define MISS_WRITE							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-miss-write-latency");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss write.")
// bookmark_tmp |= BM_MISS_WRITE;			
#define MISS_DEFAULT							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss default.")
// asserts_tmp |= AS_MISS_DEFAULT;			
#define EVICT_DEFAULT							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict default.")
// asserts_tmp |= AS_EVICT_DEFAULT;				

#endif /* __L2_DIRECTIVES_HPP_ */
