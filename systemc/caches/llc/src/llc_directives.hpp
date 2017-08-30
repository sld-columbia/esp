/* Copyright 2017 Columbia University, SLD Group */

#ifndef __LLC_DIRECTIVES_HPP__
#define __LLC_DIRECTIVES_HPP__

#define LLC_WAYS_UNROLL (LLC_WAYS/8)

#define FLATTEN_REGS				\
    HLS_FLATTEN_ARRAY(tag_buf);			\
    HLS_FLATTEN_ARRAY(state_buf);		\
    HLS_FLATTEN_ARRAY(line_buf); \
    HLS_FLATTEN_ARRAY(hprot_buf)
//    HLS_FLATTEN_ARRAY(sharers_buf);		\
//    HLS_FLATTEN_ARRAY(owner_buf)

// Reset functions
#define RESET_IO				\
    HLS_DEFINE_PROTOCOL("llc-reset-io-protocol")

#define NB_GET					\
    HLS_DEFINE_PROTOCOL("llc-nb-get-protocol")

#define SEND_MEM_REQ							\
    HLS_DEFINE_PROTOCOL("llc-send-mem-req-protocol");			\
    bookmark_tmp |= BM_LLC_SEND_MEM_REQ;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send mem req.")

#define GET_MEM_RSP \
    HLS_DEFINE_PROTOCOL("llc-mem-rsp-protocol");			\
    bookmark_tmp |= BM_LLC_GET_MEM_RSP;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get mem rsp.")

#define GET_REQ_IN \
    HLS_DEFINE_PROTOCOL("llc-req-in-protocol");			\
    bookmark_tmp |= BM_LLC_GET_REQ_IN;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get req in.")

#define SEND_RSP_OUT							\
    HLS_DEFINE_PROTOCOL("llc-send-rsp-out-protocol");			\
    bookmark_tmp |= BM_LLC_SEND_RSP_OUT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rsp out.")

#define LLC_GETS \
    bookmark_tmp |= BM_LLC_GETS
#define LLC_GETM \
    bookmark_tmp |= BM_LLC_GETM
#define LLC_PUTS \
    bookmark_tmp |= BM_LLC_PUTS
#define LLC_PUTM \
    bookmark_tmp |= BM_LLC_PUTM

#define GENERIC_ASSERT \
    asserts_tmp |= AS_GENERIC

#endif /* __LLC_DIRECTIVES_HPP_ */
