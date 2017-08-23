/* Copyright 2017 Columbia University, SLD Group */

#include "llc.hpp"

/*
 * Processes
 */

void llc::ctrl()
{
    // empty variables
    const invack_cnt_t empty_invack_cnt = 0;
    const invack_cnt_t max_invack_cnt = MAX_INVACK_CNT;
    const word_t empty_word = 0;
    const line_t empty_line = 0;
    const hprot_t empty_hprot = 0;
    const tag_t empty_tag = 0;

    // transaction select flags
    bool is_rsp_to_get = false;
    bool is_req_to_get = false;

    // input
    llc_rsp_in_t  rsp_in;
    llc_req_in_t  req_in;

    // input address breakdown
    addr_breakdown_t addr_br;
    llc_way_t way;
    bool evict;
    llc_addr_t llc_addr;
    
    // Reset all signals and channels
    this->reset_io();

    // Reset state memory
    this->reset_states();

    // Main loop
    while(true) {

	{
	    NB_GET;

	    is_rsp_to_get = false;
	    is_req_to_get = false;

	    if (llc_rsp_in.nb_can_get()) { // rsp_data
		is_rsp_to_get = true;
	    } else if (llc_req_in.nb_can_get() && !evict_stall) { // req_gets, req_getm, req_puts, req_putm
		is_req_to_get = true;
	    } else {
		wait();
	    }
	}

	bookmark_tmp = 0;
	asserts_tmp = 0;

	if (is_rsp_to_get) {


	} else if (is_req_to_get) {
	    get_req_in(req_in);

	    wait(); // for SystemC simulation only

	    addr_br.breakdown(req_in.addr);

	    lookup(addr_br.tag, addr_br.set, way, evict, llc_addr);

	    switch (req_in.coh_msg) {

	    case REQ_GETS :

		switch (state_buf[way]) {
		case INVALID :
		case INVALID_NOT_EMPTY :
		    if (evict) {
			send_mem_req(WRITE, req_in.addr, req_in.hprot, line_buf[way]);
			evict_ways[addr_br.set] = evict_way_buf + 1;
		    }
		    if (state_buf[way] == INVALID || evict) {
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots[llc_addr] = req_in.hprot;
			lines[llc_addr] = line_buf[way];
			tags[llc_addr] = addr_br.tag;
		    }
		    owners[llc_addr] = req_in.req_id;
		    states[llc_addr] = EXCLUSIVE;
		    send_rsp_out(RSP_EDATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case SHARED :
		    break;
		case EXCLUSIVE :
		    break;
		case MODIFIED :
		    break;
		case SD :
		    break;
		}

		break;

	    case REQ_GETM :

		switch (state_buf[way]) {
		case INVALID :
		case INVALID_NOT_EMPTY :
		    if (evict) {
			send_mem_req(WRITE, req_in.addr, req_in.hprot, line_buf[way]);
			evict_ways[addr_br.set] = evict_way_buf + 1;
		    }
		    if (state_buf[way] == INVALID || evict) {
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots[llc_addr] = req_in.hprot;
			lines[llc_addr] = line_buf[way];
			tags[llc_addr] = addr_br.tag;
		    }
		    owners[llc_addr] = req_in.req_id;
		    states[llc_addr] = MODIFIED;
		    send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case SHARED :
		    break;
		case EXCLUSIVE :
		    break;
		case MODIFIED :
		    break;
		case SD :
		    break;
		}

		break;

	    case REQ_PUTS :

		switch (state_buf[way]) {
		case INVALID :
		    break;
		case INVALID_NOT_EMPTY :
		    break;
		case SHARED :
		    break;
		case EXCLUSIVE :
		    states[llc_addr] = INVALID_NOT_EMPTY;
		    owners[llc_addr] = 0;
		    send_rsp_out(RSP_PUTACK, req_in.addr, 0, req_in.req_id, 0, 0);
		    break;
		case MODIFIED :
		    break;
		case SD :
		    break;
		}

		break;

	    case REQ_PUTM :

		switch (state_buf[way]) {
		case INVALID :
		    break;
		case INVALID_NOT_EMPTY :
		    break;
		case SHARED :
		    break;
		case EXCLUSIVE :
		case MODIFIED :
		    states[llc_addr] = INVALID_NOT_EMPTY;
		    owners[llc_addr] = 0;
		    lines[llc_addr] = req_in.line;
		    send_rsp_out(RSP_PUTACK, req_in.addr, 0, req_in.req_id, 0, 0);
		    break;
		case SD :
		    break;
		}
		break;
	    }

	}

	asserts.write(asserts_tmp);
	bookmark.write(bookmark_tmp);

    }

    /* 
     * End of main loop
     */

}

/*
 * Functions
 */

inline void llc::reset_io()
{
    RESET_IO;

    llc_req_in.reset();
    // llc_rsp_in.reset();
    llc_mem_rsp.reset();
    llc_rsp_out.reset();
    // llc_fwd_out.reset();
    llc_mem_req.reset();

    evict_stall = 0;

    asserts.write(0);
    bookmark.write(0);
    custom_dbg.write(0);

    wait();
}

inline void llc::reset_states()
{
    for (int i=0; i<SETS; i++) { // do not unroll
	for (int j=0; j<LLC_WAYS; j++) { // do not unroll
	    {
		HLS_UNROLL_LOOP(OFF, "llc-reset-states-loop");
		states[(i << LLC_WAY_BITS) + j] = INVALID;
		wait();
	    }
	}
    }
}

void llc::lookup(tag_t tag, set_t set, llc_way_t &way, bool &evict, llc_addr_t &llc_addr)
{
    bool tag_hit = false, empty_way_found = false;
    llc_way_t hit_way = 0, empty_way = 0, evict_way = 0;

    llc_addr = (set << LLC_WAY_BITS);

    evict_way_buf = evict_ways[set];

    for (int i = LLC_WAYS-1; i >= 0; --i) {
	HLS_UNROLL_LOOP(COMPLETE, LLC_WAYS_UNROLL, "llc-lookup-unroll");

	HLS_BREAK_ARRAY_DEPENDENCY(tags);
	HLS_BREAK_ARRAY_DEPENDENCY(states);
	HLS_BREAK_ARRAY_DEPENDENCY(hprots);
	HLS_BREAK_ARRAY_DEPENDENCY(lines);
	HLS_BREAK_ARRAY_DEPENDENCY(sharers);
	HLS_BREAK_ARRAY_DEPENDENCY(owners);

	tag_buf[i]   = tags[llc_addr + i];
	state_buf[i] = states[llc_addr + i];
	hprot_buf[i] = hprots[llc_addr + i];
	line_buf[i] = lines[llc_addr + i];
	sharers_buf[i] = sharers[llc_addr + i];
	owner_buf[i] = owners[llc_addr + i];

	if (tag_buf[i] == tag && state_buf[i] != INVALID) {
	    tag_hit = true;
	    hit_way = i;
	}

	if (state_buf[i] == INVALID) {
	    empty_way_found = true;
	    empty_way = i;
	}
	
	if (state_buf[i] == INVALID_NOT_EMPTY) {
	    evict_way = i;
	}
    }

    if (tag_hit) {
	way = hit_way;
	evict = false;
    } else if (empty_way_found) {
	way = empty_way;
	evict = false;
    } else {
	way = evict_way;
	evict = true;
    }

    llc_addr += way;
}

void llc::send_mem_req(bool hwrite, addr_t addr, hprot_t hprot, line_t line)
{
    SEND_MEM_REQ;
    llc_mem_req_t mem_req;
    mem_req.hwrite = hwrite;
    mem_req.addr = addr;
    mem_req.hsize = WORD;
    mem_req.hprot = hprot;
    mem_req.line = line;
    llc_mem_req.put(mem_req);
}

void llc::get_mem_rsp(line_t &line)
{
    GET_MEM_RSP;
    llc_mem_rsp_t mem_rsp;
    llc_mem_rsp.get(mem_rsp);
    line = mem_rsp.line;
}

void llc::get_req_in(llc_req_in_t &req_in)
{
    GET_REQ_IN;
    llc_req_in.nb_get(req_in);
}

void llc::send_rsp_out(coh_msg_t coh_msg, addr_t addr, line_t line, cache_id_t req_id,
		       cache_id_t dest_id, invack_cnt_t invack_cnt)
{
    SEND_RSP_OUT;
    llc_rsp_out_t rsp_out;
    rsp_out.coh_msg = coh_msg;
    rsp_out.addr = addr;
    rsp_out.line = line;
    rsp_out.req_id = req_id;
    rsp_out.dest_id = dest_id;
    rsp_out.invack_cnt = invack_cnt;
    llc_rsp_out.put(rsp_out);
}


