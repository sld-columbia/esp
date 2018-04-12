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
    HLS_FLATTEN_ARRAY(owner_buf);		\
    HLS_FLATTEN_ARRAY(dirty_bit_buf)

// Reset functions
#define LLC_RESET_IO				\
    HLS_DEFINE_PROTOCOL("llc-reset-io-protocol")

#ifdef LLC_DEBUG

#define LLC_RESET_STATES						\
    HLS_DEFINE_PROTOCOL("llc-reset-states-protocol");			\
    bookmark_tmp |= BM_LLC_RESET_STATES;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reset states.")

#define LLC_FLUSH						\
    bookmark_tmp |= BM_LLC_FLUSH;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Flush.")

#define FLUSH_DIRTY_LINE					\
    bookmark_tmp |= BM_FLUSH_DIRTY_LINE;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Flush dirty line.")
    
#define LLC_EVICT						\
    bookmark_tmp |= BM_LLC_EVICT;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict.")
    // HLS_DEFINE_PROTOCOL("llc-evict");

#define EVICT_EM							\
    bookmark_tmp |= BM_EVICT_EM;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict EM.")

#define EVICT_S							\
    bookmark_tmp |= BM_EVICT_S;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict S.")

#define EVICT_V							\
    bookmark_tmp |= BM_EVICT_V;					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict V.")

#define SEND_MEM_REQ							\
    HLS_DEFINE_PROTOCOL("llc-send-mem-req-protocol");			\
    bookmark_tmp |= BM_LLC_SEND_MEM_REQ;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send mem req.")

#define GET_MEM_RSP							\
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
    bookmark_tmp |= BM_LLC_SEND_RSP_OUT;				\
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

#define DMA_BURST \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA burst.")

#define LLC_DMA_READ					\
    bookmark_tmp |= BM_LLC_DMA_READ;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA read.")

#define LLC_DMA_READ_BURST				\
    bookmark_tmp |= BM_LLC_DMA_READ;			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA read burst.")

#define LLC_DMA_WRITE						\
    bookmark_tmp |= BM_LLC_DMA_WRITE;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA write.")

#define LLC_DMA_WRITE_BURST					\
    bookmark_tmp |= BM_LLC_DMA_WRITE;				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA write burst.")

#define GENERIC_ASSERT \
    asserts_tmp |= AS_GENERIC

#define GETS_IV							 \
    HLS_DEFINE_PROTOCOL("gets-iv-protocol");			 \
    bookmark_tmp |= BM_GETS_IV

#define GETS_S							 \
    HLS_DEFINE_PROTOCOL("gets-s-protocol");			 \
    bookmark_tmp |= BM_GETS_S;					 \
    if (sharers_buf[way] == 0) asserts_tmp |= AS_GETS_S_NOSHARE; \
    if ((sharers_buf[way] & (1 << req_in.req_id)) != 0)		 \
	asserts_tmp |= AS_GETS_S_ALREADYSHARE

#define GETS_EM				     \
    HLS_DEFINE_PROTOCOL("gets-em-protocol"); \
    bookmark_tmp |= BM_GETS_EM;			\
    if (owner_buf[way] == req_in.req_id)	\
	asserts_tmp |= AS_GETS_EM_ALREADYOWN

#define GETS_SD \
    HLS_DEFINE_PROTOCOL("gets-sd-protocol"); \
    bookmark_tmp |= BM_GETS_SD; \
    if ((sharers_buf[way] & (1 << req_in.req_id)) != 0)	\
	asserts_tmp |= AS_GETS_SD_ALREADYSHARE

#define GETM_IV \
    HLS_DEFINE_PROTOCOL("getm-iv-protocol"); \
    bookmark_tmp |= BM_GETM_IV

#define GETM_S \
    HLS_DEFINE_PROTOCOL("getm-s-protocol"); \
    bookmark_tmp |= BM_GETM_S

#define GETM_E \
    HLS_DEFINE_PROTOCOL("getm-e-protocol"); \
    bookmark_tmp |= BM_GETM_E;		    \
    if (owner_buf[way] == req_in.req_id)  \
	asserts_tmp |= AS_GETM_EM_ALREADYOWN

#define GETM_M \
    HLS_DEFINE_PROTOCOL("getm-m-protocol"); \
    bookmark_tmp |= BM_GETM_M;		    \
    if (owner_buf[way] == req_in.req_id)  \
	asserts_tmp |= AS_GETM_EM_ALREADYOWN

#define GETM_SD \
    HLS_DEFINE_PROTOCOL("getm-sd-protocol"); \
    bookmark_tmp |= BM_GETM_SD

#define PUTS_IVM				\
    HLS_DEFINE_PROTOCOL("puts-ivm-protocol"); \
    bookmark_tmp |= BM_PUTS_IVM

#define PUTS_S \
    HLS_DEFINE_PROTOCOL("puts-s-protocol"); \
    bookmark_tmp |= BM_PUTS_S

#define PUTS_E \
    HLS_DEFINE_PROTOCOL("puts-e-protocol"); \
    bookmark_tmp |= BM_PUTS_E

#define PUTS_SD \
    HLS_DEFINE_PROTOCOL("puts-sd-protocol"); \
    bookmark_tmp |= BM_PUTS_SD

#define PUTM_IV					\
    HLS_DEFINE_PROTOCOL("putm-iv-protocol"); \
    bookmark_tmp |= BM_PUTM_IV

#define PUTM_S \
    HLS_DEFINE_PROTOCOL("putm-s-protocol"); \
    bookmark_tmp |= BM_PUTM_S

#define PUTM_EM \
    HLS_DEFINE_PROTOCOL("putm-em-protocol"); \
    bookmark_tmp |= BM_PUTM_EM

#define PUTM_SD \
    HLS_DEFINE_PROTOCOL("putm-sd-protocol"); \
    bookmark_tmp |= BM_PUTM_SD

#define DMA_READ_SD \
    HLS_DEFINE_PROTOCOL("dma-read-sd-protocol"); \
    bookmark_tmp |= BM_DMA_READ_SD

#define DMA_READ_I \
    bookmark_tmp |= BM_DMA_READ_I

#define DMA_READ_NOTSD \
    HLS_DEFINE_PROTOCOL("dma-read-notsd-protocol"); \
    bookmark_tmp |= BM_DMA_READ_NOTSD

#define DMA_WRITE_SD \
    HLS_DEFINE_PROTOCOL("dma-write-sd-protocol"); \
    bookmark_tmp |= BM_DMA_WRITE_SD

#define DMA_WRITE_I \
    bookmark_tmp |= BM_DMA_WRITE_I

#define DMA_WRITE_NOTSD \
    HLS_DEFINE_PROTOCOL("dma-write-notsd-protocol"); \
    bookmark_tmp |= BM_DMA_WRITE_NOTSD

#else

#define LLC_RESET_STATES						\
    HLS_DEFINE_PROTOCOL("llc-reset-states-protocol");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Reset states.")

#define LLC_FLUSH						\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Flush.")

#define FLUSH_DIRTY_LINE					\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Flush dirty line.")

#define LLC_EVICT						\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict.")
    // HLS_DEFINE_PROTOCOL("llc-evict");

#define EVICT_EM							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict EM.")

#define EVICT_S							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict S.")

#define EVICT_V							\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Evict V.")

#define SEND_MEM_REQ							\
    HLS_DEFINE_PROTOCOL("llc-send-mem-req-protocol");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send mem req.")

#define GET_MEM_RSP							\
    HLS_DEFINE_PROTOCOL("llc-mem-rsp-protocol");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get mem rsp.")

#define GET_REQ_IN							\
    HLS_DEFINE_PROTOCOL("llc-req-in-protocol");				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get req in.")

#define LLC_GET_RSP_IN							\
    HLS_DEFINE_PROTOCOL("llc-rsp-in-protocol");				\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Get rsp in.")

#define SEND_RSP_OUT							\
    HLS_DEFINE_PROTOCOL("llc-send-rsp-out-protocol");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send rsp out.")

#define SEND_FWD_OUT							\
    HLS_DEFINE_PROTOCOL("llc-send-fwd-out-protocol");			\
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "Send fwd out.")

#define LLC_GETS
#define LLC_GETM
#define LLC_PUTS
#define LLC_PUTM

#define DMA_BURST \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA burst.")

#define LLC_DMA_READ \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA read.")

#define LLC_DMA_READ_BURST \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA read burst.")

#define LLC_DMA_WRITE \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA write.")

#define LLC_DMA_WRITE_BURST \
    if (RPT_RTL) CACHE_REPORT_TIME(sc_time_stamp(), "LLC DMA write burst.")

#define GENERIC_ASSERT

#define GETS_IV					\
    HLS_DEFINE_PROTOCOL("gets-iv-protocol");

#define GETS_S							 \
    HLS_DEFINE_PROTOCOL("gets-s-protocol")

#define GETS_EM				     \
    HLS_DEFINE_PROTOCOL("gets-em-protocol")

#define GETS_SD				     \
    HLS_DEFINE_PROTOCOL("gets-sd-protocol")

#define GETM_IV \
    HLS_DEFINE_PROTOCOL("getm-iv-protocol")

#define GETM_S \
    HLS_DEFINE_PROTOCOL("getm-s-protocol")

#define GETM_E \
    HLS_DEFINE_PROTOCOL("getm-e-protocol")

#define GETM_M \
    HLS_DEFINE_PROTOCOL("getm-m-protocol")

#define GETM_SD \
    HLS_DEFINE_PROTOCOL("getm-sd-protocol")

#define PUTS_IVM \
    HLS_DEFINE_PROTOCOL("puts-ivm-protocol")

#define PUTS_S \
    HLS_DEFINE_PROTOCOL("puts-s-protocol")

#define PUTS_E \
    HLS_DEFINE_PROTOCOL("puts-e-protocol")

#define PUTS_SD \
    HLS_DEFINE_PROTOCOL("puts-sd-protocol")

#define PUTM_IV	\
    HLS_DEFINE_PROTOCOL("putm-iv-protocol")

#define PUTM_S \
    HLS_DEFINE_PROTOCOL("putm-s-protocol")

#define PUTM_EM \
    HLS_DEFINE_PROTOCOL("putm-em-protocol")

#define PUTM_SD \
    HLS_DEFINE_PROTOCOL("putm-sd-protocol")

#define DMA_READ_SD \
    HLS_DEFINE_PROTOCOL("dma-read-sd-protocol")

#define DMA_READ_I

#define DMA_READ_NOTSD \
    HLS_DEFINE_PROTOCOL("dma-read-notsd-protocol")

#define DMA_WRITE_SD \
    HLS_DEFINE_PROTOCOL("dma-write-sd-protocol")

#define DMA_WRITE_I

#define DMA_WRITE_NOTSD \
    HLS_DEFINE_PROTOCOL("dma-write-notsd-protocol")

#endif

#endif /* __LLC_DIRECTIVES_HPP_ */
