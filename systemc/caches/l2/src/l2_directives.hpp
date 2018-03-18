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
#define RESET_STATES_LOOP			\
    HLS_DEFINE_PROTOCOL("l2-reset-states-protocol")

// Debug
#define REQS_OUTPUT					\
    HLS_UNROLL_LOOP(ON, "l2-reqs-output-unroll")	
#define BUFS_OUTPUT					\
    HLS_UNROLL_LOOP(ON, "l2-bufs-output-unroll")	

// Input messages
#define L2_NB_GET				\
    HLS_DEFINE_PROTOCOL("l2-nb-get-protocol")
#define GET_CPU_REQ							\
    HLS_DEFINE_PROTOCOL("l2-get-cpu-req-protocol");			\
    bookmark_tmp |= BM_GET_CPU_REQ;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get cpu req.")
#define L2_GET_FWD_IN					\
    HLS_DEFINE_PROTOCOL("l2-get-fwd-in-protocol");	\
    bookmark_tmp |= BM_GET_FWD_IN
#define L2_GET_RSP_IN					\
    HLS_DEFINE_PROTOCOL("l2-get-rsp-in-protocol");	\
    bookmark_tmp |= BM_GET_RSP_IN
#define GET_FLUSH							\
    HLS_DEFINE_PROTOCOL("l2-get-flush-protocol");			\
    bookmark_tmp |= BM_GET_FLUSH;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get flush.")
#define RSP_WHILE_FLUSHING						\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "ERROR: Rsp while flushing."); \
    asserts_tmp |= AS_RSP_WHILE_FLUSHING

// Output messages 
#define SEND_REQ_OUT					\
    HLS_DEFINE_PROTOCOL("l2-send-req-out-protocol");	\
    bookmark_tmp |= BM_SEND_REQ_OUT;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send req out.")
#define SEND_RD_RSP				    \
    HLS_DEFINE_PROTOCOL("l2-send-rd-rsp-protocol"); \
    bookmark_tmp |= BM_SEND_RD_RSP;      	    \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rd rsp.")
#define SEND_INVAL					\
    HLS_DEFINE_PROTOCOL("l2-send-inval-protocol");	\
    bookmark_tmp |= BM_SEND_INVAL;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send inval.")
#define SEND_RSP_OUT					\
    HLS_DEFINE_PROTOCOL("l2-send-rsp-out-protocol");	\
    bookmark_tmp |= BM_SEND_RSP_OUT;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rsp out.")

// Buffered lines
#define FILL_REQS					\
    HLS_CONSTRAIN_LATENCY("l2-fill-reqs-latency");	\
    bookmark_tmp |= BM_FILL_REQS;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fill reqs.")
#define PUT_REQS					\
    HLS_CONSTRAIN_LATENCY("l2-put-reqs-latency");	\
    bookmark_tmp |= BM_PUT_REQS;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Put reqs.")
// Search for cache lines
#define TAG_LOOKUP						       \
    HLS_CONSTRAIN_LATENCY(0, 1, "l2-tag-lookup-latency"); \
    bookmark_tmp |= BM_TAG_LOOKUP;				       \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Tag lookup.")
#define TAG_LOOKUP_LOOP					\
    HLS_UNROLL_LOOP(ON, "l2-tag-lookup-loop-unroll")
#define REQS_LOOKUP							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-reqs-lookup-latency"); \
    bookmark_tmp |= BM_REQS_LOOKUP;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reqs lookup.")
#define REQS_LOOKUP_LOOP				\
    HLS_UNROLL_LOOP(ON, "l2-reqs-lookup-loop-unroll")
#define REQS_LOOKUP_ASSERT						\
    if (!reqs_hit || reqs[reqs_hit_i].state == INVALID) asserts_tmp |= AS_REQS_LOOKUP
#define REQS_PEEK_REQ							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-reqs-peek-req-latency"); \
    bookmark_tmp |= BM_REQS_PEEK_REQ;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reqs peek req.")
#define REQS_PEEK_REQ_LOOP					\
    HLS_UNROLL_LOOP(ON, "l2-reqs-peek-req-loop-unroll")
#define REQS_PEEK_FWD							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-reqs-peek-fwd-latency"); \
    bookmark_tmp |= BM_REQS_PEEK_FWD;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reqs peek fwd.")
#define REQS_PEEK_FWD_LOOP					\
    HLS_UNROLL_LOOP(ON, "l2-reqs-peek-fwd-loop-unroll")

// Manage flush
#define FLUSH_READ_SET							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-flush-read-set-latency"); \
    bookmark_tmp |= BM_FLUSH_READ_SET;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Flush read set.")
#define FLUSH_LOOP					\
    HLS_DEFINE_PROTOCOL("l2-flush-loop-protocol")
#define FLUSH_END					\
    HLS_DEFINE_PROTOCOL("l2-flush-end-protocol")

// Manage rsp in
#define RSP_EDATA_ISD							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-edata-isd-latency");			\
    bookmark_tmp |= BM_RSP_EDATA_ISD;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp edata isd.")
#define RSP_DATA_ISD							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-data-isd-latency");			\
    bookmark_tmp |= BM_RSP_DATA_ISD;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data isd.")
#define RSP_DATA_XMAD							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-data-xmad-latency");			\
    bookmark_tmp |= BM_RSP_DATA_XMAD;					\
    if (rsp_in.coh_msg == RSP_EDATA) asserts_tmp |= AS_RSP_DATA_XMAD;	\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data xmad.")
#define RSP_DATA_XMADW							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-data-xmadw-latency");			\
    bookmark_tmp |= BM_RSP_DATA_XMADW;					\
    if (rsp_in.coh_msg == RSP_EDATA) asserts_tmp |= AS_RSP_DATA_XMADW;	\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data xmadw.")
#define RSP_DATA_DEFAULT			\
    asserts_tmp |= AS_RSP_DATA_DEFAULT;		\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data default.")
#define RSP_INVACK_ALL							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-invack-latency");			\
    bookmark_tmp |= BM_RSP_INVACK;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp invack all.")
#define RSP_INVACK_DEFAULT				\
    asserts_tmp |= AS_RSP_INVACK_DEFAULT
#define RSP_DEFAULT				\
    asserts_tmp |= AS_RSP_DEFAULT

// Manage fwd in
#define FWD_STALL_BEGIN				\
    bookmark_tmp |= BM_FWD_STALL_BEGIN;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd stall begin.")
#define FWD_HIT_SMADX							\
    HLS_CONSTRAIN_LATENCY("l2-fwd-hit-smadx-latency");			\
    bookmark_tmp |= BM_FWD_HIT_SMADX;					\
    if (fwd_in.coh_msg != FWD_INV) asserts_tmp |= AS_HIT_SMADX;		\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit smadx.")
#define FWD_HIT_EMIA							\
    HLS_CONSTRAIN_LATENCY("l2-fwd-hit-emia-latency");			\
    bookmark_tmp |= BM_FWD_HIT_EMIA;					\
    if (fwd_in.coh_msg == FWD_INV) asserts_tmp |= AS_HIT_EMIA;		\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit emia.")
#define FWD_HIT_SIA							\
    HLS_CONSTRAIN_LATENCY("l2-fwd-hit-sia-latency");			\
    bookmark_tmp |= BM_FWD_HIT_SIA;					\
    if (fwd_in.coh_msg != FWD_INV) asserts_tmp |= AS_HIT_SMADX;		\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit sia.")
#define FWD_HIT_DEFAULT							\
    asserts_tmp |= AS_FWD_HIT_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd hit default.")
#define FWD_NOHIT_GETS							\
    HLS_DEFINE_PROTOCOL("l2-fwd-nohit-gets-protocol");			\
    bookmark_tmp |= BM_FWD_NOHIT_GETS;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit gets.")
#define FWD_NOHIT_GETM							\
    HLS_CONSTRAIN_LATENCY("l2-fwd-nohit-getm-latency");			\
    bookmark_tmp |= BM_FWD_NOHIT_GETM;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit getm.")
#define FWD_NOHIT_INV							\
    HLS_CONSTRAIN_LATENCY("l2-fwd-nohit-inv-latency");			\
    bookmark_tmp |= BM_FWD_NOHIT_INV;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit inv.")
#define FWD_NOHIT_DEFAULT						\
    asserts_tmp |= AS_FWD_NOHIT_DEFAULT;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd nohit default.")
#define FWD_PUTACK_ALL							\
    HLS_CONSTRAIN_LATENCY("l2-fwd-putack-latency");			\
    bookmark_tmp |= BM_FWD_PUTACK;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Fwd putack all.")
#define PUTACK_DEFAULT							\
    asserts_tmp |= AS_PUTACK_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Put ack default.")

// Manage cpu req
#define SET_CONFLICT \
    bookmark_tmp |= BM_SET_CONFLICT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Set conflict.")
#define ATOMIC_OVERRIDE \
    HLS_DEFINE_PROTOCOL("l2-atom-override-protocol");	\
    bookmark_tmp |= BM_ATOMIC_OVERRIDE;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Atomic override.")
#define ATOMIC_CONTINUE \
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-atom-continue-latency");	\
    bookmark_tmp |= BM_ATOMIC_CONTINUE;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Atomic continue.")
#define HIT_READ							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-hit-read-latency");	\
    bookmark_tmp |= BM_HIT_READ;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit read.")
#define HIT_READ_ATOMIC_S						      \
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-hit-read-atomic-latency"); \
    bookmark_tmp |= BM_HIT_READ_ATOMIC_S
#define HIT_READ_ATOMIC_EM					\
    bookmark_tmp |= BM_HIT_READ_ATOMIC_EM;			\
    HLS_CONSTRAIN_LATENCY("l2-hit-read-atomic-em-latency")
#define HIT_READ_ATOMIC_DEFAULT				\
    asserts_tmp |= AS_HIT_READ_ATOMIC_DEFAULT;		\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit read-atomic default.")
#define HIT_WRITE_S						      \
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-hit-write-latency"); \
    bookmark_tmp |= BM_HIT_WRITE_S
#define HIT_WRITE_EM					\
    bookmark_tmp |= BM_HIT_WRITE_EM;			\
    HLS_CONSTRAIN_LATENCY("l2-hit-write-em-latency")
#define HIT_WRITE_DEFAULT				\
    asserts_tmp |= AS_HIT_WRITE_DEFAULT;		\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit write default.")
#define HIT_DEFAULT							\
    asserts_tmp |= AS_HIT_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit default.")
#define MISS_READ					\
    HLS_CONSTRAIN_LATENCY("l2-miss-read-latency");	\
    bookmark_tmp |= BM_MISS_READ;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss read.")
#define MISS_READ_ATOMIC					\
    HLS_CONSTRAIN_LATENCY("l2-miss-read-atomic-latency");	\
    bookmark_tmp |= BM_MISS_READ_ATOMIC;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss read atomic.")
#define MISS_WRITE					\
    HLS_CONSTRAIN_LATENCY("l2-miss-write-latency");	\
    bookmark_tmp |= BM_MISS_WRITE;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss write.")
#define MISS_DEFAULT					\
    asserts_tmp |= AS_MISS_DEFAULT;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss default.")
#define EVICT_DEFAULT						\
    asserts_tmp |= AS_EVICT_DEFAULT;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict default.")

#endif /* __L2_DIRECTIVES_HPP_ */
