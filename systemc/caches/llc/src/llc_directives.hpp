/* Copyright 2017 Columbia University, SLD Group */

#ifndef __LLC_DIRECTIVES_HPP__
#define __LLC_DIRECTIVES_HPP__

#define LLC_WAYS_UNROLL (LLC_WAYS/8)

#define LLC_FLATTEN_REGS			\
    HLS_FLATTEN_ARRAY(tag_buf);			\
    HLS_FLATTEN_ARRAY(state_buf);		\
    HLS_FLATTEN_ARRAY(line_buf);		\
    HLS_FLATTEN_ARRAY(hprot_buf);		\
    HLS_FLATTEN_ARRAY(sharers_buf);		\
    HLS_FLATTEN_ARRAY(owner_buf)

// Reset functions
#define LLC_RESET_IO				\
    HLS_DEFINE_PROTOCOL("llc-reset-io-protocol")

#define LLC_NB_GET				\
    HLS_DEFINE_PROTOCOL("llc-nb-get-protocol")

#define SEND_MEM_REQ							\
    HLS_DEFINE_PROTOCOL("llc-send-mem-req-protocol");			\
    bookmark_tmp |= BM_LLC_SEND_MEM_REQ;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send mem req.")

#define GET_MEM_RSP \
    HLS_DEFINE_PROTOCOL("llc-mem-rsp-protocol");			\
    bookmark_tmp |= BM_LLC_GET_MEM_RSP;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get mem rsp.")

#define GET_REQ_IN							\
    HLS_DEFINE_PROTOCOL("llc-req-in-protocol");				\
    bookmark_tmp |= BM_LLC_GET_REQ_IN;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get req in.")

#define LLC_GET_RSP_IN							\
    HLS_DEFINE_PROTOCOL("llc-rsp-in-protocol");				\
    bookmark_tmp |= BM_LLC_GET_RSP_IN;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get rsp in.")

#define SEND_RSP_OUT							\
    HLS_DEFINE_PROTOCOL("llc-send-rsp-out-protocol");			\
    bookmark_tmp |= BM_LLC_SEND_RSP_OUT;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rsp out.")

#define SEND_FWD_OUT							\
    HLS_DEFINE_PROTOCOL("llc-send-fwd-out-protocol");			\
    bookmark_tmp |= BM_LLC_SEND_FWD_OUT;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send fwd out.")

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
#define GETS_S \
    if (sharers_buf[way] == 0) asserts_tmp |= AS_GETS_S_NOSHARE; \
    if (sharers_buf[way] & (1 << req_in.req_id) != 0) \
	asserts_tmp |= AS_GETS_S_ALREADYSHARE
#define GETS_EM \
    if (owner_buf[way] == req_in.req_id)  \
	asserts_tmp |= AS_GETS_EM_ALREADYOWN
#define GETS_SD \
    if (sharers_buf[way] & (1 << req_in.req_id) != 0) \
	asserts_tmp |= AS_GETS_SD_ALREADYSHARE
#define GETM_EM \
    if (owner_buf[way] == req_in.req_id)  \
	asserts_tmp |= AS_GETM_EM_ALREADYOWN


#endif /* __LLC_DIRECTIVES_HPP_ */
