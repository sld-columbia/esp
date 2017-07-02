/* Copyright 2017 Columbia University, SLD Group */

#ifndef __L2_CACHE_DIRECTIVES_HPP__
#define __L2_CACHE_DIRECTIVES_HPP__


#define FLATTEN_REGS				\
    HLS_FLATTEN_ARRAY(reqs);			\
    HLS_FLATTEN_ARRAY(tag_buf);			\
    HLS_FLATTEN_ARRAY(state_buf);		\
    HLS_FLATTEN_ARRAY(hprot_buf);		\
    HLS_FLATTEN_ARRAY(lines_buf);

// Reset functions
#define RESET_IO				\
    HLS_DEFINE_PROTOCOL("l2-reset-io-protocol")
#define RESET_STATES

#define RESET_STATES_LOOP				\
    HLS_DEFINE_PROTOCOL("l2-reset-states-protocol")

// Request selection and acquisition
#define NB_GET					\
    HLS_DEFINE_PROTOCOL("l2-nb-get-protocol")
#define GET_RSP_IN					\
    HLS_DEFINE_PROTOCOL("l2-get-rsp-in-protocol");	\
    bookmark_tmp |= BM_GET_RSP_IN
#define GET_CPU_REQ							\
    HLS_DEFINE_PROTOCOL("l2-get-cpu-req-protocol");			\
    bookmark_tmp |= BM_GET_CPU_REQ;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get cpu req.")
#define GET_FLUSH							\
    HLS_DEFINE_PROTOCOL("l2-get-flush-protocol");			\
    bookmark_tmp |= BM_GET_FLUSH;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get flush.")

// Lookup functions
#define TAG_LOOKUP							\
    bookmark_tmp |= BM_TAG_LOOKUP;					\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-tag-lookup-latency")
#define TAG_LOOKUP_LOOP					\
    HLS_UNROLL_LOOP(ON, "l2-tag-lookup-loop-unroll")
#define REQS_LOOKUP_SPACE				\
    HLS_UNROLL_LOOP(ON, "l2-reqs-lookup-space-unroll")
#define REQS_LOOKUP							\
    bookmark_tmp |= BM_REQS_LOOKUP;					\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-reqs-lookup-latency")
#define REQS_LOOKUP_LOOP				\
    HLS_UNROLL_LOOP(ON, "l2-reqs-lookup-loop-unroll")

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
#define RSP_DATA_ISD							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-data-isd-latency");			\
    bookmark_tmp |= BM_RSP_DATA_ISD;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data isd.")
#define RSP_DATA_XMAD							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-data-xmad-latency");			\
    bookmark_tmp |= BM_RSP_DATA_XMAD;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data xmad.")
#define RSP_DATA_DEFAULT						\
    asserts_tmp |= AS_RSP_DATA_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp data default.")
#define RSP_EDATA_ALL							\
    HLS_CONSTRAIN_LATENCY("l2-rsp-edata-latency");			\
    bookmark_tmp |= BM_RSP_EDATA;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp edata all.")
#define PUTACK_DEFAULT							\
    asserts_tmp |= AS_PUTACK_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Put ack default.")
#define RSP_DEFAULT							\
    asserts_tmp |= AS_RSP_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Rsp default.")

// Manage cpu req
#define HIT_READ							\
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-hit-read-latency");	\
    bookmark_tmp |= BM_HIT_READ;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit read.")
#define HIT_WRITE_S							\
		     HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "l2-hit-write-latency"); \
		     bookmark_tmp |= BM_HIT_WRITE_S
#define HIT_WRITE_EM						\
	bookmark_tmp |= BM_HIT_WRITE_EM;			\
	HLS_CONSTRAIN_LATENCY("l2-hit-write-em-latency")
#define HIT_WRITE_DEFAULT						\
		     asserts_tmp |= AS_HIT_WRITE_DEFAULT;		\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit write default.")
#define HIT_DEFAULT							\
    asserts_tmp |= AS_HIT_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Hit default.")

#define MISS_READ							\
    HLS_CONSTRAIN_LATENCY("l2-miss-read-latency");			\
    bookmark_tmp |= BM_MISS_READ;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss read.")
#define MISS_WRITE							\
    HLS_CONSTRAIN_LATENCY("l2-miss-write-latency");			\
    bookmark_tmp |= BM_MISS_WRITE;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss write.")
#define MISS_DEFAULT							\
		     asserts_tmp |= AS_MISS_DEFAULT;			\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Miss default.")

#define EVICT_DEFAULT							\
    asserts_tmp |= AS_EVICT_DEFAULT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict default.")

// Output messages 
#define SEND_REQ_OUT							\
		     HLS_DEFINE_PROTOCOL("l2-send-req-out-protocol");	\
		     bookmark_tmp |= BM_SEND_REQ_OUT;			\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send req out.")

#define SEND_RD_RSP							\
		     HLS_DEFINE_PROTOCOL("l2-send-rd-rsp-protocol");	\
		     bookmark_tmp |= BM_SEND_RD_RSP;			\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rd rsp.")

#define SEND_WR_RSP							\
		     HLS_DEFINE_PROTOCOL("l2-send-wr-rsp-protocol");	\
		     bookmark_tmp |= BM_SEND_WR_RSP;			\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send wr rsp.")

#define SEND_INVAL							\
		     HLS_DEFINE_PROTOCOL("l2-send-inval-protocol");	\
		     bookmark_tmp |= BM_SEND_INVAL;			\
		     if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send inval.")

// Memory
#define PUT_REQS							\
	HLS_CONSTRAIN_LATENCY("l2-put-reqs-latency");			\
	bookmark_tmp |= BM_PUT_REQS;					\
	if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Put reqs.")

// Asserts
#define WRONG_HSIZE				\
	asserts_tmp |= AS_WRONG_HSIZE


#endif /* __L2_CACHE_DIRECTIVES_HPP_ */
