// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CACHE_TYPES_HPP__
#define __CACHE_TYPES_HPP__


#include <stdint.h>
#include <sstream>
#include "math.h"
#include "systemc.h"
#include "cache_consts.hpp"

/*
 * Cache data types
 */

typedef sc_uint<CPU_MSG_TYPE_WIDTH>	cpu_msg_t; // CPU bus requests
typedef sc_uint<COH_MSG_TYPE_WIDTH>	coh_msg_t; // Requests without DMA, Forwards, Responses
typedef sc_uint<MIX_MSG_TYPE_WIDTH>	mix_msg_t; // Requests if including DMA
typedef sc_uint<HSIZE_WIDTH>		hsize_t;
typedef sc_uint<HPROT_WIDTH>    	hprot_t;
typedef sc_uint<INVACK_CNT_WIDTH>	invack_cnt_t;
typedef sc_uint<INVACK_CNT_CALC_WIDTH>	invack_cnt_calc_t;
typedef sc_uint<ADDR_BITS>		addr_t;
typedef sc_uint<LINE_ADDR_BITS>		line_addr_t;
typedef sc_uint<L2_ADDR_BITS>           l2_addr_t;
typedef sc_uint<LLC_ADDR_BITS>          llc_addr_t;
typedef sc_uint<BITS_PER_WORD>		word_t;
typedef sc_biguint<BITS_PER_LINE>	line_t;
typedef sc_uint<L2_TAG_BITS>		l2_tag_t;
typedef sc_uint<LLC_TAG_BITS>		llc_tag_t;
typedef sc_uint<L2_SET_BITS>		l2_set_t;
typedef sc_uint<LLC_SET_BITS>		llc_set_t;
#if (L2_WAY_BITS == 1)
typedef sc_uint<2> l2_way_t;
#else
typedef sc_uint<L2_WAY_BITS> l2_way_t;
#endif
typedef sc_uint<LLC_WAY_BITS>		llc_way_t;
typedef sc_uint<OFFSET_BITS>		offset_t;
typedef sc_uint<WORD_BITS>		word_offset_t;
typedef sc_uint<BYTE_BITS>		byte_offset_t;
typedef sc_uint<STABLE_STATE_BITS>	state_t;
typedef sc_uint<LLC_STATE_BITS>	        llc_state_t;
typedef sc_uint<UNSTABLE_STATE_BITS>	unstable_state_t;
typedef sc_uint<CACHE_ID_WIDTH>         cache_id_t;
typedef sc_uint<LLC_COH_DEV_ID_WIDTH>   llc_coh_dev_id_t;
typedef sc_uint<MAX_N_L2_BITS>		owner_t;
typedef sc_uint<MAX_N_L2>		sharers_t;
typedef sc_uint<DMA_BURST_LENGTH_BITS>  dma_length_t;

/*
 * L2 cache coherence channels types
 */

/* L1 to L2 */

// L1 request
class l2_cpu_req_t
{

public:

    cpu_msg_t	cpu_msg;	// r, w, r atom., w atom., flush
    hsize_t	hsize;
    hprot_t	hprot;
    addr_t	addr;
    word_t	word;

    l2_cpu_req_t() :
	cpu_msg(0),
	hsize(0),
	hprot(0),
	addr(0),
	word(0)
    {}

    inline l2_cpu_req_t& operator  = (const l2_cpu_req_t& x) {
	cpu_msg = x.cpu_msg;
	hsize   = x.hsize;
	hprot   = x.hprot;
	addr    = x.addr;
	word    = x.word;
	return *this;
    }
    inline bool operator  == (const l2_cpu_req_t& x) const {
	return (x.cpu_msg == cpu_msg	&&
		x.hsize   == hsize	&&
		x.hprot   == hprot	&&
		x.addr    == addr	&&
		x.word    == word);
    }
    inline friend void sc_trace(sc_trace_file *tf, const l2_cpu_req_t& x, const std::string & name) {
	sc_trace(tf, x.cpu_msg , name + ".cpu_msg ");
	sc_trace(tf, x.hsize,    name + ".hsize");
	sc_trace(tf, x.hprot,    name + ".hprot");
	sc_trace(tf, x.addr,     name + ".addr");
	sc_trace(tf, x.word,     name + ".word");
    }
    inline friend ostream & operator<<(ostream& os, const l2_cpu_req_t& x) {
	os << hex << "("
	   << "cpu_msg: "   << x.cpu_msg
	   << ", hsize: "   << x.hsize
	   << ", hprot: "   << x.hprot
	   << ", addr: "    << x.addr
	   << ", word: "    << x.word << ")";
	return os;
    }
};

/* L2 to L1 */

// read data response
class l2_rd_rsp_t
{
public:
    line_t line;

    l2_rd_rsp_t() :
	line(0)
    {}

    inline l2_rd_rsp_t& operator  = (const l2_rd_rsp_t& x) {
	line    = x.line;
	return *this;
    }
    inline bool operator == (const l2_rd_rsp_t& x) const {
	return (x.line == line);
    }
    inline friend void sc_trace(sc_trace_file *tf, const l2_rd_rsp_t& x, const std::string & name) {
	sc_trace(tf, x.line , name + ".line ");
    }
    inline friend ostream & operator<<(ostream& os, const l2_rd_rsp_t& x) {
	os << hex << "("
	   << "line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
	    os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ")";
	return os;
    }
};

// invalidate address
typedef line_addr_t l2_inval_t;

/* L2/LLC to L2 */

// forwards
class l2_fwd_in_t
{

public:

    mix_msg_t	coh_msg; // fwd-gets, fwd-getm, fwd-invalidate
    line_addr_t	addr;
    cache_id_t  req_id;

    l2_fwd_in_t() :
	coh_msg(0),
	addr(0),
	req_id(0)
    { }

    inline l2_fwd_in_t& operator  = (const l2_fwd_in_t& x) {
	coh_msg = x.coh_msg;
	addr    = x.addr;
	req_id  = x.req_id;
	return *this;
    }
    inline bool operator  == (const l2_fwd_in_t& x) const {
	return (x.coh_msg == coh_msg	&&
		x.addr    == addr       &&
		x.req_id  == req_id);
    }
    inline friend void sc_trace(sc_trace_file *tf, const l2_fwd_in_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg , name + ".coh_msg ");
	sc_trace(tf, x.addr,     name + ".addr");
	sc_trace(tf, x.req_id,     name + ".req_id");
    }
    inline friend ostream & operator<<(ostream& os, const l2_fwd_in_t& x) {
	os << hex << "("
	   << "coh_msg: " << x.coh_msg
	   << ", addr: "  << x.addr
	   << ", req_id: "  << x.req_id << ")";
	return os;
    }
};

// responses
class l2_rsp_in_t
{

public:

    coh_msg_t		coh_msg;	// data, e-data, inv-ack, put-ack
    line_addr_t		addr;
    line_t		line;
    invack_cnt_t	invack_cnt;

    l2_rsp_in_t() :
	coh_msg(0),
	addr(0),
	line(0),
	invack_cnt(0)
    {}

    inline l2_rsp_in_t& operator  = (const l2_rsp_in_t& x) {
	coh_msg    = x.coh_msg;
	addr       = x.addr;
	line       = x.line;
	invack_cnt = x.invack_cnt;
	return *this;
    }
    inline bool operator     == (const l2_rsp_in_t& x) const {
	return (x.coh_msg    == coh_msg &&
		x.addr       == addr    &&
		x.line      == line   &&
		x.invack_cnt == invack_cnt);
    }
    inline friend void sc_trace(sc_trace_file	*tf, const l2_rsp_in_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg ,   name + ".cpu_msg ");
	sc_trace(tf, x.addr,       name + ".addr");
	sc_trace(tf, x.line,      name + ".line");
	sc_trace(tf, x.invack_cnt, name + ".invack_cnt");
    }
    inline friend ostream & operator<<(ostream& os, const l2_rsp_in_t& x) {
	os << hex << "("
	   << "coh_msg: "    << x.coh_msg
	   << ", addr: "       << x.addr
	   << ", line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
		os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ", invack_cnt: " << x.invack_cnt << ")";
	return os;
    }
};

template <unsigned REQ_ID_WIDTH>
class llc_rsp_out_t
{

public:

    coh_msg_t		coh_msg; // data, e-data, inv-ack, rsp-data-dma
    line_addr_t		addr;
    line_t		line;
    invack_cnt_t	invack_cnt; // used to mark last line of RSP_DATA_DMA
    sc_uint<REQ_ID_WIDTH> req_id;
    cache_id_t          dest_id;
    word_offset_t       word_offset;

    llc_rsp_out_t() :
	coh_msg(0),
	addr(0),
	line(0),
	invack_cnt(0),
	req_id(0),
	dest_id(0),
        word_offset(0)
    {}

    inline llc_rsp_out_t& operator  = (const llc_rsp_out_t& x) {
	coh_msg     = x.coh_msg;
	addr        = x.addr;
	line        = x.line;
	invack_cnt  = x.invack_cnt;
	req_id      = x.req_id;
	dest_id     = x.dest_id;
        word_offset = x.word_offset;
	return *this;
    }
    inline bool operator     == (const llc_rsp_out_t& x) const {
	return (x.coh_msg     == coh_msg    &&
		x.addr        == addr       &&
		x.line        == line       &&
		x.invack_cnt  == invack_cnt &&
		x.req_id      == req_id     &&
		x.dest_id     == dest_id    &&
		x.word_offset == word_offset);
    }
    inline friend void sc_trace(sc_trace_file	*tf, const llc_rsp_out_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg ,    name + ".cpu_msg ");
	sc_trace(tf, x.addr,        name + ".addr");
	sc_trace(tf, x.line,        name + ".line");
	sc_trace(tf, x.invack_cnt,  name + ".invack_cnt");
	sc_trace(tf, x.req_id,      name + ".req_id");
	sc_trace(tf, x.dest_id,     name + ".dest_id");
	sc_trace(tf, x.word_offset, name + ".word_offset");
    }
    inline friend ostream & operator<<(ostream& os, const llc_rsp_out_t& x) {
	os << hex << "(coh_msg: ";
        switch (x.coh_msg) {
        case RSP_DATA : os << "DATA"; break;
        case RSP_EDATA : os << "EDATA"; break;
        case RSP_INVACK : os << "INVACK"; break;
        case RSP_DATA_DMA : os << "DATA_DMA"; break;
        default: os << "UNKNOWN"; break;
        }
        os << ", addr: "       << x.addr
	   << ", line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
		os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ", invack_cnt: " << x.invack_cnt
	   << ", req_id: " << x.req_id
	   << ", dest_id: " << x.dest_id
	   << ", word_offset: " << x.word_offset << ")";
	return os;
    }
};

class llc_fwd_out_t
{

public:

    mix_msg_t		coh_msg;	// fwd_gets, fwd_getm, fwd_inv
    line_addr_t		addr;
    cache_id_t          req_id;
    cache_id_t          dest_id;

    llc_fwd_out_t() :
	coh_msg(0),
	addr(0),
	req_id(0),
	dest_id(0)
    {}

    inline llc_fwd_out_t& operator  = (const llc_fwd_out_t& x) {
	coh_msg    = x.coh_msg;
	addr       = x.addr;
	req_id     = x.req_id;
	dest_id    = x.dest_id;
	return *this;
    }
    inline bool operator     == (const llc_fwd_out_t& x) const {
	return (x.coh_msg    == coh_msg &&
		x.addr       == addr    &&
		x.req_id     == req_id &&
		x.dest_id    == dest_id);
    }
    inline friend void sc_trace(sc_trace_file	*tf, const llc_fwd_out_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg ,   name + ".cpu_msg ");
	sc_trace(tf, x.addr,       name + ".addr");
	sc_trace(tf, x.req_id, name + ".req_id");
	sc_trace(tf, x.dest_id, name + ".dest_id");
    }
    inline friend ostream & operator<<(ostream& os, const llc_fwd_out_t& x) {
	os << hex << "(coh_msg: ";
        switch (x.coh_msg) {
        case FWD_GETS : os << "GETS"; break;
        case FWD_GETM : os << "GETM"; break;
        case FWD_INV : os << "INV"; break;
        case FWD_PUTACK : os << "PUTACK"; break;
        case FWD_GETM_LLC : os << "RECALL_EM"; break;
        case FWD_INV_LLC : os << "RECALL_S"; break;
        default: os << "UNKNOWN"; break;
        }
        os << ", addr: "       << x.addr
	   << ", req_id: " << x.req_id
	   << ", dest_id: " << x.dest_id << ")";
	return os;
    }
};

/* L2 to L2/LLC */

// requests
class l2_req_out_t
{

public:

    coh_msg_t	coh_msg;	// gets, getm, puts, putm
    hprot_t	hprot;
    line_addr_t	addr;
    line_t	line;

    l2_req_out_t() :
	coh_msg(coh_msg_t(0)),
	hprot(0),
	addr(0),
	line(0)
    {}

    inline l2_req_out_t& operator  = (const l2_req_out_t& x) {
	coh_msg = x.coh_msg;
	hprot   = x.hprot;
	addr    = x.addr;
	line    = x.line;
	return *this;
    }
    inline bool operator  == (const l2_req_out_t& x) const {
	return (x.coh_msg == coh_msg	&&
		x.hprot   == hprot	&&
		x.addr    == addr	&&
		x.line	  == line);
    }
    inline friend void sc_trace(sc_trace_file *tf, const l2_req_out_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg , name + ".coh_msg ");
	sc_trace(tf, x.hprot,    name + ".hprot");
	sc_trace(tf, x.addr,     name + ".addr");
	sc_trace(tf, x.line,    name + ".line");
    }
    inline friend ostream & operator<<(ostream& os, const l2_req_out_t& x) {
	os << hex << "("
	   << "coh_msg: " << x.coh_msg
	   << ", hprot: " << x.hprot
	   << ", addr: " << x.addr
	   << ", line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
	    os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ")";
	return os;
    }
};

template <unsigned REQ_ID_WIDTH>
class llc_req_in_t
{

public:

    mix_msg_t	  coh_msg;	// gets, getm, puts, putm, dma_read, dma_write
    hprot_t	  hprot; // used for dma write burst end (0) and non-aligned addr (1)
    line_addr_t	  addr;
    line_t	  line; // used for dma burst length too
    sc_uint<REQ_ID_WIDTH> req_id;
    word_offset_t word_offset;
    word_offset_t valid_words;

    llc_req_in_t() :
	coh_msg(coh_msg_t(0)),
	hprot(0),
	addr(0),
	line(0),
	req_id(0),
        word_offset(0),
        valid_words(0)
    {}

    inline llc_req_in_t& operator  = (const llc_req_in_t& x) {
	coh_msg     = x.coh_msg;
	hprot       = x.hprot;
	addr        = x.addr;
	line        = x.line;
	req_id      = x.req_id;
        word_offset = x.word_offset;
        valid_words = x.valid_words;
	return *this;
    }
    inline bool operator  == (const llc_req_in_t& x) const {
	return (x.coh_msg     == coh_msg     &&
		x.hprot       == hprot       &&
		x.addr        == addr        &&
		x.line        == line        &&
		x.req_id      == req_id      &&
		x.word_offset == word_offset &&
		x.valid_words == valid_words);
    }
    inline friend void sc_trace(sc_trace_file *tf, const llc_req_in_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg,     name + ".coh_msg ");
	sc_trace(tf, x.hprot,       name + ".hprot");
	sc_trace(tf, x.addr,        name + ".addr");
	sc_trace(tf, x.line,        name + ".line");
	sc_trace(tf, x.req_id,      name + ".req_id");
	sc_trace(tf, x.word_offset, name + ".word_offset");
	sc_trace(tf, x.valid_words, name + ".valid_words");
    }
    inline friend ostream & operator<<(ostream& os, const llc_req_in_t& x) {
	os << hex << "(coh_msg: ";
        switch (x.coh_msg) {
        case REQ_GETS : os << "GETS"; break;
        case REQ_GETM : os << "GETM"; break;
        case REQ_PUTS : os << "PUTS"; break;
        case REQ_PUTM : os << "PUTM"; break;
        case REQ_DMA_READ : os << "DMA_READ"; break;
        case REQ_DMA_WRITE : os << "DMA_WRITE"; break;
        case REQ_DMA_READ_BURST : os << "DMA_READ_BURST"; break;
        case REQ_DMA_WRITE_BURST : os << "DMA_WRITE_BURST"; break;
        default: os << "UNKNOWN"; break;
        }
        os << ", hprot: " << x.hprot
	   << ", addr: " << x.addr
	   << ", req_id: " << x.req_id
	   << ", word_offset: " << x.word_offset
	   << ", valid_words: " << x.valid_words
	   << ", line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
	    os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ")";
	return os;
    }
};

// responses
class l2_rsp_out_t
{

public:

    coh_msg_t	coh_msg;	// gets, getm, puts, putm
    cache_id_t  req_id;
    sc_uint<2>  to_req;
    line_addr_t	addr;
    line_t	line;

    l2_rsp_out_t() :
	coh_msg(coh_msg_t(0)),
	req_id(0),
	to_req(0),
	addr(0),
	line(0)
    {}

    inline l2_rsp_out_t& operator  = (const l2_rsp_out_t& x) {
	coh_msg = x.coh_msg;
	req_id   = x.req_id;
	to_req   = x.to_req;
	addr    = x.addr;
	line    = x.line;
	return *this;
    }
    inline bool operator  == (const l2_rsp_out_t& x) const {
	return (x.coh_msg == coh_msg	&&
		x.req_id   == req_id	&&
		x.to_req   == to_req	&&
		x.addr    == addr	&&
		x.line	  == line);
    }
    inline friend void sc_trace(sc_trace_file *tf, const l2_rsp_out_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg , name + ".coh_msg ");
	sc_trace(tf, x.req_id,    name + ".req_id");
	sc_trace(tf, x.to_req,    name + ".to_req");
	sc_trace(tf, x.addr,     name + ".addr");
	sc_trace(tf, x.line,    name + ".line");
    }
    inline friend ostream & operator<<(ostream& os, const l2_rsp_out_t& x) {
	os << hex << "("
	   << "coh_msg: " << x.coh_msg
	   << ", req_id: " << x.req_id
	   << ", to_req: " << x.to_req
	   << ", addr: " << x.addr
	   << ", line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
	    os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ")";
	return os;
    }
};

class llc_rsp_in_t
{

public:

    coh_msg_t coh_msg;
    line_addr_t	addr;
    line_t	line;
    cache_id_t  req_id;

    llc_rsp_in_t() :
	coh_msg(0),
	addr(0),
	line(0),
	req_id(0)
    {}

    inline llc_rsp_in_t& operator  = (const llc_rsp_in_t& x) {
	coh_msg = x.coh_msg;
	addr    = x.addr;
	line    = x.line;
	req_id  = x.req_id;
	return *this;
    }
    inline bool operator  == (const llc_rsp_in_t& x) const {
	return (x.coh_msg == coh_msg	&&
		x.addr    == addr	&&
		x.line	  == line       &&
		x.req_id  == req_id);
    }
    inline friend void sc_trace(sc_trace_file *tf, const llc_rsp_in_t& x, const std::string & name) {
	sc_trace(tf, x.coh_msg,  name + ".coh_msg");
	sc_trace(tf, x.addr,     name + ".addr");
	sc_trace(tf, x.line,     name + ".line");
	sc_trace(tf, x.req_id,   name + ".req_id");
    }
    inline friend ostream & operator<<(ostream& os, const llc_rsp_in_t& x) {
	os << hex << "("
	   << "coh_msg: " << x.coh_msg
	   << ", addr: " << x.addr
	   << ", req_id: " << x.req_id
	   << ", line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
	    os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ")";
	return os;
    }
};

/* LLC to Memory */

// requests
class llc_mem_req_t
{

public:

    bool	hwrite;	// r, w, r atom., w atom., flush
    hsize_t	hsize;
    hprot_t	hprot;
    line_addr_t	addr;
    line_t	line;

    llc_mem_req_t() :
	hwrite(0),
	hsize(0),
	hprot(0),
	addr(0),
	line(0)
    {}

    inline llc_mem_req_t& operator  = (const llc_mem_req_t& x) {
	hwrite = x.hwrite;
	hsize   = x.hsize;
	hprot   = x.hprot;
	addr    = x.addr;
	line    = x.line;
	return *this;
    }
    inline bool operator  == (const llc_mem_req_t& x) const {
	return (x.hwrite == hwrite	&&
		x.hsize   == hsize	&&
		x.hprot   == hprot	&&
		x.addr    == addr	&&
		x.line    == line);
    }
    inline friend void sc_trace(sc_trace_file *tf, const llc_mem_req_t& x, const std::string & name) {
	sc_trace(tf, x.hwrite , name + ".hwrite ");
	sc_trace(tf, x.hsize,    name + ".hsize");
	sc_trace(tf, x.hprot,    name + ".hprot");
	sc_trace(tf, x.addr,     name + ".addr");
	sc_trace(tf, x.line,     name + ".line");
    }
    inline friend ostream & operator<<(ostream& os, const llc_mem_req_t& x) {
	os << hex << "("
	   << "hwrite: "   << x.hwrite
	   << ", hsize: "   << x.hsize
	   << ", hprot: "   << x.hprot
	   << ", addr: "    << x.addr
	   << ", line: "    << x.line << ")";
	return os;
    }
};

// responses

typedef l2_rd_rsp_t llc_mem_rsp_t;

/*
 * Ongoing transaction buffer tuypes
 */

// ongoing request buffer
class reqs_buf_t
{

public:

    cpu_msg_t           cpu_msg;
    l2_tag_t		tag;
    l2_tag_t            tag_estall;
    l2_set_t		set;
    l2_way_t            way;
    hsize_t             hsize;
    word_offset_t	w_off;
    byte_offset_t	b_off;
    unstable_state_t	state;
    hprot_t		hprot;
    invack_cnt_calc_t	invack_cnt;
    word_t		word;
    line_t		line;

    reqs_buf_t() :
	cpu_msg(0),
	tag(0),
	tag_estall(0),
	set(0),
	way(0),
	hsize(0),
	w_off(0),
	b_off(0),
	state(0),
	hprot(0),
	invack_cnt(0),
    	word(0),
    	line(0)
    {}

    inline reqs_buf_t& operator = (const reqs_buf_t& x) {
	cpu_msg			= x.cpu_msg;
	tag			= x.tag;
	tag_estall		= x.tag_estall;
	set			= x.set;
	way			= x.way;
	hsize			= x.hsize;
	w_off			= x.w_off;
	b_off			= x.b_off;
	state			= x.state;
	hprot			= x.hprot;
	invack_cnt		= x.invack_cnt;
	word			= x.word;
	line			= x.line;
	return *this;
    }
    inline bool operator     == (const reqs_buf_t& x) const {
	return (x.cpu_msg    == cpu_msg		&&
		x.tag	     == tag		&&
		x.tag_estall == tag_estall	&&
		x.set	     == set		&&
		x.way	     == way		&&
		x.hsize	     == hsize		&&
		x.w_off	     == w_off		&&
		x.b_off	     == b_off		&&
		x.state	     == state		&&
		x.hprot	     == hprot		&&
		x.invack_cnt == invack_cnt	&&
		x.word	     == word		&&
		x.line	     == line);
    }
    inline friend void sc_trace(sc_trace_file *tf, const reqs_buf_t& x, const std::string & name) {
	sc_trace(tf, x.cpu_msg , name + ".cpu_msg ");
	sc_trace(tf, x.tag , name + ".tag");
	sc_trace(tf, x.tag_estall , name + ".tag_estall");
	sc_trace(tf, x.set , name + ".set");
	sc_trace(tf, x.way , name + ".way");
	sc_trace(tf, x.hsize , name + ".hsize");
	sc_trace(tf, x.w_off , name + ".w_off");
	sc_trace(tf, x.b_off , name + ".b_off");
	sc_trace(tf, x.state , name + ".state");
	sc_trace(tf, x.hprot , name + ".hprot");
	sc_trace(tf, x.invack_cnt , name + ".invack_cnt");
	sc_trace(tf, x.word , name + ".word");
	sc_trace(tf, x.line , name + ".line");
    }
    inline friend ostream & operator<<(ostream& os, const reqs_buf_t& x) {
	os << hex << "("
	   << "cpu_msg: " << x.cpu_msg
	   << "tag: " << x.tag
	   << "tag_estall: " << x.tag_estall
	   << ", set: "<< x.set
	   << ", way: " << x.way
	   << ", hsize: " << x.hsize
	   << ", w_off: " << x.w_off
	   << ", b_off: " << x.b_off
	   << ", state: " << x.state
	   << ", hprot: " << x.hprot
	   << ", invack_cnt: " << x.invack_cnt
	   << ", word: " << x.word
	   << ", line: ";
	for (int i = WORDS_PER_LINE-1; i >= 0; --i) {
	    int base = i*BITS_PER_WORD;
	    os << x.line.range(base + BITS_PER_WORD - 1, base) << " ";
	}
	os << ")";
	return os;
    }
};

// forward stall backup
class fwd_stall_backup_t
{

public:

    coh_msg_t coh_msg;
    line_addr_t addr;

    fwd_stall_backup_t() :
	coh_msg(0),
	addr(0)
    {}

    inline fwd_stall_backup_t& operator = (const fwd_stall_backup_t& x) {
	coh_msg	= x.coh_msg;
	addr	= x.addr;
	return *this;
    }
    inline bool operator == (const fwd_stall_backup_t& x) const {
	return (x.coh_msg == coh_msg	&&
		x.addr	  == addr);
    }
    inline friend ostream & operator<<(ostream& os, const fwd_stall_backup_t& x) {
	os << hex << "("
	   << "coh_msg: " << x.coh_msg
	   << ", addr: " << x.addr    << ")";
	return os;
    }
};

// addr breakdown
class addr_breakdown_t
{

public:

    addr_t              line;
    line_addr_t         line_addr;
    addr_t              word;
    l2_tag_t            tag;
    l2_set_t            set;
    word_offset_t       w_off;
    byte_offset_t       b_off;

    addr_breakdown_t() :
	line(0),
	line_addr(0),
	word(0),
	tag(0),
	set(0),
	w_off(0),
	b_off(0)
    {}

    inline addr_breakdown_t& operator = (const addr_breakdown_t& x) {
	line	  = x.line;
	line_addr = x.line_addr;
	word	  = x.word;
	tag	  = x.tag;
	set	  = x.set;
	w_off	  = x.w_off;
	b_off	  = x.b_off;
	return *this;
    }
    inline bool operator == (const addr_breakdown_t& x) const {
	return (x.line	    == line		&&
		x.line_addr == line_addr	&&
		x.word	    == word		&&
		x.tag	    == tag		&&
		x.set	    == set		&&
		x.w_off	    == w_off		&&
		x.b_off	    == b_off);
    }
    inline friend ostream & operator<<(ostream& os, const addr_breakdown_t& x) {
	os << hex << "("
	   << "line: "      << x.line
	   << "line_addr: " << x.line_addr
	   << ", word: "    << x.word
	   << ", tag: "     << x.tag
	   << ", set: "     << x.set
	   << ", w_off: "   << x.w_off
	   << ", b_off: "   << x.b_off << ")";
	return os;
    }

    void tag_incr(int a) {
	line	  += a * L2_TAG_OFFSET;
	line_addr += a * L2_SETS;
	word	  += a * L2_TAG_OFFSET;
	tag	  += a;
    }

    void set_incr(int a) {
	line += a * SET_OFFSET;
	line_addr += a;
	word += a * SET_OFFSET;
	set  += a;
    }

    void tag_decr(int a) {
    	line	  -= a * L2_TAG_OFFSET;
    	line_addr -= a * L2_SETS;
    	word	  -= a * L2_TAG_OFFSET;
    	tag	  -= a;
    }

    void set_decr(int a) {
	line -= a * SET_OFFSET;
	line_addr -= a;
	word -= a * SET_OFFSET;
	set  -= a;
    }

    void breakdown(addr_t addr)
    {
	line = addr;
	line_addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
	word  = addr;
	tag   = addr.range(TAG_RANGE_HI, L2_TAG_RANGE_LO);
	set   = addr.range(L2_SET_RANGE_HI, SET_RANGE_LO);
	w_off = addr.range(W_OFF_RANGE_HI, W_OFF_RANGE_LO);
	b_off = addr.range(B_OFF_RANGE_HI, B_OFF_RANGE_LO);

	line.range(OFF_RANGE_HI, OFF_RANGE_LO)	   = 0;
	word.range(B_OFF_RANGE_HI, B_OFF_RANGE_LO) = 0;
    }
};

// addr breakdown
class addr_breakdown_llc_t
{

public:

    addr_t              line;
    line_addr_t         line_addr;
    addr_t              word;
    llc_tag_t            tag;
    llc_set_t            set;
    word_offset_t       w_off;
    byte_offset_t       b_off;

    addr_breakdown_llc_t() :
	line(0),
	line_addr(0),
	word(0),
	tag(0),
	set(0),
	w_off(0),
	b_off(0)
    {}

    inline addr_breakdown_llc_t& operator = (const addr_breakdown_llc_t& x) {
	line	  = x.line;
	line_addr = x.line_addr;
	word	  = x.word;
	tag	  = x.tag;
	set	  = x.set;
	w_off	  = x.w_off;
	b_off	  = x.b_off;
	return *this;
    }
    inline bool operator == (const addr_breakdown_llc_t& x) const {
	return (x.line	    == line		&&
		x.line_addr == line_addr	&&
		x.word	    == word		&&
		x.tag	    == tag		&&
		x.set	    == set		&&
		x.w_off	    == w_off		&&
		x.b_off	    == b_off);
    }
    inline friend ostream & operator<<(ostream& os, const addr_breakdown_llc_t& x) {
	os << hex << "("
	   << "line: "      << x.line
	   << "line_addr: " << x.line_addr
	   << ", word: "    << x.word
	   << ", tag: "     << x.tag
	   << ", set: "     << x.set
	   << ", w_off: "   << x.w_off
	   << ", b_off: "   << x.b_off << ")";
	return os;
    }

    void tag_incr(int a) {
	line	  += a * LLC_TAG_OFFSET;
	line_addr += a * LLC_SETS;
	word	  += a * LLC_TAG_OFFSET;
	tag	  += a;
    }

    void set_incr(int a) {
	line += a * SET_OFFSET;
	line_addr += a;
	word += a * SET_OFFSET;
	set  += a;
    }

    void tag_decr(int a) {
    	line	  -= a * LLC_TAG_OFFSET;
    	line_addr -= a * LLC_SETS;
    	word	  -= a * LLC_TAG_OFFSET;
    	tag	  -= a;
    }

    void set_decr(int a) {
	line -= a * SET_OFFSET;
	line_addr -= a;
	word -= a * SET_OFFSET;
	set  -= a;
    }

    void breakdown(addr_t addr)
    {
	line = addr;
	line_addr = addr.range(TAG_RANGE_HI, SET_RANGE_LO);
	word  = addr;
	tag   = addr.range(TAG_RANGE_HI, LLC_TAG_RANGE_LO);
	set   = addr.range(LLC_SET_RANGE_HI, SET_RANGE_LO);
	w_off = addr.range(W_OFF_RANGE_HI, W_OFF_RANGE_LO);
	b_off = addr.range(B_OFF_RANGE_HI, B_OFF_RANGE_LO);

	line.range(OFF_RANGE_HI, OFF_RANGE_LO)	   = 0;
	word.range(B_OFF_RANGE_HI, B_OFF_RANGE_LO) = 0;
    }
};

// line breakdown
template <class tag_t, class set_t>
class line_breakdown_t
{

public:

    tag_t       tag;
    set_t       set;

    line_breakdown_t() :
	tag(0),
	set(0)
    {}

    inline line_breakdown_t& operator = (const line_breakdown_t& x) {
	tag    = x.tag;
	set    = x.set;
	return *this;
    }
    inline bool operator == (const line_breakdown_t& x) const {
	return (x.tag	== tag		&&
		x.set	== set);
    }
    inline friend ostream & operator<<(ostream& os, const line_breakdown_t& x) {
	os << hex << "("
	   << ", tag: "   << x.tag
	   << ", set: "   << x.set << ")";
	return os;
    }

    void tag_incr(int a) {
	tag += a;
    }

    void set_incr(int a) {
	set += a;
    }

    void tag_decr(int a) {
    	tag -= a;
    }

    void set_decr(int a) {
	set -= a;
    }

    void l2_line_breakdown(line_addr_t addr)
    {
	tag   = addr.range(ADDR_BITS - OFFSET_BITS - 1, L2_SET_BITS);
	set   = addr.range(L2_SET_BITS - 1, 0);
    }

    void llc_line_breakdown(line_addr_t addr)
    {
	tag   = addr.range(ADDR_BITS - OFFSET_BITS - 1, LLC_SET_BITS);
	set   = addr.range(LLC_SET_BITS - 1, 0);
    }
};

#endif // __CACHE_TYPES_HPP__
