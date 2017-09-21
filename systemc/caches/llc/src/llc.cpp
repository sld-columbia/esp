/* Copyright 2017 Columbia University, SLD Group */

#include "llc.hpp"

/*
 * Processes
 */

void llc::ctrl()
{
    // Reset all signals and channels
    this->reset_io();

    // Reset state memory
    this->reset_states();

    // Main loop
    while(true) {

	// transaction select flags
	bool is_rsp_to_get = false;
	bool is_req_to_get = false;

	// input
	llc_rsp_in_t  rsp_in;
	llc_req_in_t  req_in;

	// input address breakdown
	addr_breakdown_t addr_br;
	llc_way_t way = 0;
	llc_addr_t llc_addr = 0;
	bool evict = false;

	{
	    NB_GET;

	    wait();

	    is_rsp_to_get = false;
	    is_req_to_get = false;

	    if (llc_rsp_in.nb_can_get()) { // rsp_data
	    	is_rsp_to_get = true;
	    } else if (llc_req_in.nb_can_get() == 1 && !req_stall) { // req_gets, req_getm, req_puts, req_putm
		is_req_to_get = true;
	    }
	}

	bookmark_tmp = 0;
	asserts_tmp = 0;

	if (is_rsp_to_get) {

	    get_rsp_in(rsp_in);

	    addr_br.breakdown(rsp_in.addr);

	    lookup(addr_br.tag, addr_br.set, way, evict, llc_addr);

	    if (sharers_buf[way] != 0) {
		states[llc_addr] = SHARED;
	    } else {
		states[llc_addr] = INVALID_NOT_EMPTY;
	    }
	    lines[llc_addr] = rsp_in.line;

	    if (state_buf[way] != SD) {
		GENERIC_ASSERT;
	    }

	    if (req_stall = true & rsp_in.addr == req_in_stalled.addr) {
		req_stall = false;
	    }

	} else if (is_req_to_get == true) {

	    if (!req_in_stalled_valid) {
		get_req_in(req_in);
	    } else {
		req_in_stalled_valid = false;
		req_in = req_in_stalled;
	    }

	    addr_br.breakdown(req_in.addr);

	    lookup(addr_br.tag, addr_br.set, way, evict, llc_addr);

	    if (evict && ((req_in.coh_msg != REQ_GETS && req_in.coh_msg != REQ_GETM) ||
			  (state_buf[way] != INVALID_NOT_EMPTY))) {
		GENERIC_ASSERT;
	    }

	    if (evict) {
		HLS_DEFINE_PROTOCOL("llc-eviction");
		// evict_ways[addr_br.set] = evict_way_buf + 1;
		addr_t addr_evict = (tag_buf[way]<<TAG_RANGE_LO) + addr_br.line.range(SET_RANGE_HI,0);
		send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);
		wait();
		send_mem_req(READ, req_in.addr, req_in.hprot, 0);
		get_mem_rsp(line_buf[way]);
		hprots[llc_addr] = req_in.hprot;
		lines[llc_addr] = line_buf[way];
		tags[llc_addr] = addr_br.tag;
	    }

	    switch (req_in.coh_msg) {

	    case REQ_GETS :
		LLC_GETS;
		switch (state_buf[way]) {

		case INVALID :
		case INVALID_NOT_EMPTY :
		    if (state_buf[way] == INVALID) {
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots[llc_addr] = req_in.hprot;
			lines[llc_addr] = line_buf[way];
			tags[llc_addr] = addr_br.tag;
		    }
		    owners[llc_addr] = req_in.req_id;
		    sharers[llc_addr] = 0; // TODO REMOVE: It's redundant.
		    states[llc_addr] = EXCLUSIVE;
		    send_rsp_out(RSP_EDATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case SHARED :
		    sharers[llc_addr] = sharers_buf[way] | (1 << req_in.req_id);
		    send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case EXCLUSIVE :
		case MODIFIED :
		    sharers[llc_addr] = (1 << req_in.req_id) | (1 << owner_buf[way]);
		    states[llc_addr] = SD;
		    send_fwd_out(FWD_GETS, req_in.addr, req_in.req_id, owner_buf[way]);
		    break;

		case SD :
		    req_stall = true;
		    req_in_stalled_valid = true;
		    req_in_stalled = req_in;
		    break;

		default :
		    GENERIC_ASSERT;
		}

		break;

	    case REQ_GETM :
		LLC_GETM;
		switch (state_buf[way]) {

		case INVALID :
		case INVALID_NOT_EMPTY :
		    if (state_buf[way] == INVALID) {
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots[llc_addr] = req_in.hprot;
			lines[llc_addr] = line_buf[way];
			tags[llc_addr] = addr_br.tag;
		    }
		    owners[llc_addr] = req_in.req_id;
		    sharers[llc_addr] = 0; // TODO REMOVE: It's redundant.
		    states[llc_addr] = MODIFIED;
		    send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case SHARED :
		    states[llc_addr] = MODIFIED;
		    owners[llc_addr] = req_in.req_id;
		    sharers[llc_addr] = 0;
		    {
			HLS_DEFINE_PROTOCOL("llc-getm-shared-protocol");
			invack_cnt_t invack_cnt = 0;
			for (int i = 0; i < N_CPU; i++) {
			    if ((sharers_buf[way] & ~(1 << i)) != 0) {
				send_fwd_out(FWD_INV, req_in.addr, req_in.req_id, i);
				invack_cnt++;
			    }
			    wait();
			}
			send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, invack_cnt);
			wait();
		    }
		    break;
		    
		case EXCLUSIVE :
		    states[llc_addr] = MODIFIED;
		case MODIFIED :
		    owners[llc_addr] = req_in.req_id;
		    sharers[llc_addr] = 0; // TODO REMOVE: It's redundant.
		    send_fwd_out(FWD_GETM, req_in.addr, req_in.req_id, owner_buf[way]);
		    break;

		case SD :
		    req_stall = true;
		    req_in_stalled_valid = true;
		    req_in_stalled = req_in;
		    break;

		default :
		    GENERIC_ASSERT;
		}

		break;

	    case REQ_PUTS :
		LLC_PUTS;
		send_rsp_out(RSP_PUTACK, req_in.addr, 0, req_in.req_id, 0, 0);

		switch (state_buf[way]) {

		case INVALID :
		case INVALID_NOT_EMPTY :
		    break;

		case SHARED :
		    sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    sharers[llc_addr] = sharers_buf[way];
		    if (sharers_buf[way] == 0) {
			states[llc_addr] = INVALID_NOT_EMPTY;
		    }
		    break;

		case EXCLUSIVE :
		    if (owner_buf[way] == req_in.req_id) {
			states[llc_addr] = INVALID_NOT_EMPTY;
			owners[llc_addr] = 0;
		    }
		    break;

		case MODIFIED :
		    break;

		case SD :
		    sharers[llc_addr] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    break;

		default :
		    GENERIC_ASSERT;
		}

		break;

	    case REQ_PUTM :
		LLC_PUTM;
		send_rsp_out(RSP_PUTACK, req_in.addr, 0, req_in.req_id, 0, 0);

		switch (state_buf[way]) {

		case INVALID :
		case INVALID_NOT_EMPTY :
		    break;

		case SHARED :
		    sharers[llc_addr] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    if (sharers_buf[way] == 0) {
			states[llc_addr] = INVALID_NOT_EMPTY;
		    }
		    break;

		case EXCLUSIVE :
		case MODIFIED :
		    if (owner_buf[way] == req_in.req_id) {
			states[llc_addr] = INVALID_NOT_EMPTY;
			owners[llc_addr] = 0;
			lines[llc_addr] = req_in.line;
		    }
		    break;

		case SD :
		    sharers[llc_addr] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    break;

		default :
		    GENERIC_ASSERT;
		}
		break;

	    default :
		GENERIC_ASSERT;
	    }
	    
	}
	asserts.write(asserts_tmp);
	bookmark.write(bookmark_tmp);
	custom_dbg.write(evict);
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
    llc_rsp_in.reset();
    llc_mem_rsp.reset();
    llc_rsp_out.reset();
    llc_fwd_out.reset();
    llc_mem_req.reset();

    asserts.write(0);
    bookmark.write(0);
    custom_dbg.write(0);

    req_stall = false;
    req_in_stalled_valid = false;

    tag_hit_out.write(0);
    hit_way_out.write(0);
    empty_way_found_out.write(0);
    empty_way_out.write(0);
    evict_out.write(0);
    way_out.write(0);
    llc_addr_out.write(0);

    wait();
}

inline void llc::reset_states()
{
    for (int i=0; i<SETS; i++) { // do not unroll
	for (int j=0; j<LLC_WAYS; j++) { // do not unroll
	    {
		HLS_DEFINE_PROTOCOL("llc-reset-states-protocol");
		states[(i << LLC_WAY_BITS) + j] = INVALID;
		wait();
	    }
	}
    }
}

void llc::read_set(llc_addr_t base, llc_way_t way_base)
{
	for (int i = L2_WAYS - 1; i >= 0; i--) {
		HLS_UNROLL_LOOP(ON, "llc-read-set");
		tag_buf[way_base + i]	  = tags[base + i];
		state_buf[way_base + i]   = states[base + i];
		hprot_buf[way_base + i]   = hprots[base + i];
		line_buf[way_base + i]	  = lines[base + i];
		sharers_buf[way_base + i] = sharers[base + i];
		owner_buf[way_base + i]	  = owners[base + i];
	}
}

// TODO make *_buf only with L2_WAYS positions to save area
void llc::lookup(tag_t tag, set_t set, llc_way_t &way, bool &evict, llc_addr_t &llc_addr)
{
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "llc-tag-lookup-latency");

    bool tag_hit = false, empty_way_found = false;
    llc_way_t hit_way = 0, empty_way = 0, evict_way = 0;
    evict = false;

    const llc_addr_t base = (set << LLC_WAY_BITS);

    // evict_way_buf = evict_ways[set];

    for (int i = 0; i < LLC_WAYS/L2_WAYS; i++) {
	read_set(base + L2_WAYS*i, i*L2_WAYS);
    }

    for (int i = 0; i < LLC_WAYS; i++) {
    	HLS_UNROLL_LOOP(ON, "llc-lookup-unroll");


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

    if (tag_hit == true) {
	way = hit_way;
    } else if (empty_way_found == true) {
	way = empty_way;
    } else {
	way = evict_way;
	evict = true;
    }

    llc_addr = base + way;

    // TODO REMOVE
    tag_hit_out = tag_hit;
    hit_way_out = hit_way;
    empty_way_found_out = empty_way_found;
    empty_way_out = empty_way;
    evict_out = evict;
    way_out = way;
    llc_addr_out = llc_addr;
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

void llc::get_rsp_in(llc_rsp_in_t &rsp_in)
{
    GET_RSP_IN;
    llc_rsp_in.nb_get(rsp_in);
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

void llc::send_fwd_out(coh_msg_t coh_msg, addr_t addr, cache_id_t req_id,
		       cache_id_t dest_id)
{
    SEND_FWD_OUT;
    llc_fwd_out_t fwd_out;
    fwd_out.coh_msg = coh_msg;
    fwd_out.addr = addr;
    fwd_out.req_id = req_id;
    fwd_out.dest_id = dest_id;
    llc_fwd_out.put(fwd_out);
}
