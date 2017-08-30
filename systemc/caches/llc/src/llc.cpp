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
    llc_way_t way = 0;
    llc_addr_t llc_addr = 0;
    bool evict = false;

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

	    // if (llc_rsp_in.nb_can_get()) { // rsp_data
	    // 	is_rsp_to_get = true;
	    if (llc_req_in.nb_can_get() == 1 && evict_stall == 0) { // req_gets, req_getm, req_puts, req_putm
		is_req_to_get = true;
	    }
	    wait();
	}

	bookmark_tmp = 0;
	asserts_tmp = 0;

	// if (is_rsp_to_get) {


	if (is_req_to_get == true) {
	    get_req_in(req_in);

	    // wait(); // for SystemC simulation only

	    addr_br.breakdown(req_in.addr);

	    // CACHE_REPORT_TIME(sc_time_stamp(), "After addr br.");

	    lookup(addr_br.tag, addr_br.set, way, evict, llc_addr);

	    if (evict == 1) {
		HLS_DEFINE_PROTOCOL("llc-eviction");
		GENERIC_ASSERT;
		// evict_ways.port1[0][addr_br.set] = evict_way_buf + 1;
		addr_t addr_evict = (tag_buf[way]<<TAG_RANGE_LO) + addr_br.line.range(SET_RANGE_HI,0);
		send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);
		wait();
		send_mem_req(READ, req_in.addr, req_in.hprot, 0);
		get_mem_rsp(line_buf[way]);
		hprots.port1[0][llc_addr] = req_in.hprot;
		lines.port1[0][llc_addr] = line_buf[way];
		tags.port1[0][llc_addr] = addr_br.tag;
	    }

	    // CACHE_REPORT_TIME(sc_time_stamp(), "After lookup.");

	    switch (req_in.coh_msg) {

	    case REQ_GETS :
		LLC_GETS;
		switch (state_buf[way]) {
		case INVALID :
		case INVALID_NOT_EMPTY :
		    if (state_buf[way] == INVALID) {
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots.port1[0][llc_addr] = req_in.hprot;
			lines.port1[0][llc_addr] = line_buf[way];
			tags.port1[0][llc_addr] = addr_br.tag;
		    }
		    // owners.port1[0][llc_addr] = req_in.req_id;
		    states.port1[0][llc_addr] = EXCLUSIVE;
		    send_rsp_out(RSP_EDATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case SHARED :
		case EXCLUSIVE :
		case MODIFIED :
		case SD :
		    GENERIC_ASSERT;
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
			hprots.port1[0][llc_addr] = req_in.hprot;
			lines.port1[0][llc_addr] = line_buf[way];
			tags.port1[0][llc_addr] = addr_br.tag;
		    }
		    // owners.port1[0][llc_addr] = req_in.req_id;
		    states.port1[0][llc_addr] = MODIFIED;
		    send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case SHARED :
		case EXCLUSIVE :
		case MODIFIED :
		case SD :
		    GENERIC_ASSERT;
		    break;
		default :
		    GENERIC_ASSERT;
		}

		break;

	    case REQ_PUTS :
		LLC_PUTS;
		switch (state_buf[way]) {
		case INVALID :
		case INVALID_NOT_EMPTY :
		case SHARED :
		    GENERIC_ASSERT;
		    break;
		case EXCLUSIVE :
		    states.port1[0][llc_addr] = INVALID_NOT_EMPTY;
		    // owners.port1[0][llc_addr] = 0;
		    send_rsp_out(RSP_PUTACK, req_in.addr, 0, req_in.req_id, 0, 0);
		    break;
		case MODIFIED :
		case SD :
		    GENERIC_ASSERT;
		    break;
		default :
		    GENERIC_ASSERT;
		}

		break;

	    case REQ_PUTM :
		LLC_PUTM;
		switch (state_buf[way]) {
		case INVALID :
		case INVALID_NOT_EMPTY :
		case SHARED :
		    GENERIC_ASSERT;
		    break;
		case EXCLUSIVE :
		case MODIFIED :
		    states.port1[0][llc_addr] = INVALID_NOT_EMPTY;
		    // owners.port1[0][llc_addr] = 0;
		    lines.port1[0][llc_addr] = req_in.line;
		    send_rsp_out(RSP_PUTACK, req_in.addr, 0, req_in.req_id, 0, 0);
		    break;
		case SD :
		    GENERIC_ASSERT;
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

    evict_stall = 0;

    asserts.write(0);
    bookmark.write(0);
    custom_dbg.write(0);

    tag_hit_out.write(0);
    hit_way_out.write(0);
    empty_way_found_out.write(0);
    empty_way_out.write(0);
    evict_out.write(0);
    way_out.write(0);
    llc_addr_out.write(0);

    tags.port1.reset();
    tags.port2.reset();
    tags.port3.reset();
    tags.port4.reset();
    tags.port5.reset();
    tags.port6.reset();
    tags.port7.reset();
    tags.port8.reset();
    tags.port9.reset();

    states.port1.reset();
    states.port2.reset();
    states.port3.reset();
    states.port4.reset();
    states.port5.reset();
    states.port6.reset();
    states.port7.reset();
    states.port8.reset();
    states.port9.reset();

    hprots.port1.reset();
    hprots.port2.reset();
    hprots.port3.reset();
    hprots.port4.reset();
    hprots.port5.reset();
    hprots.port6.reset();
    hprots.port7.reset();
    hprots.port8.reset();
    hprots.port9.reset();

    lines.port1.reset();
    lines.port2.reset();
    lines.port3.reset();
    lines.port4.reset();
    lines.port5.reset();
    lines.port6.reset();
    lines.port7.reset();
    lines.port8.reset();
    lines.port9.reset();

    // sharers.port1.reset();
    // sharers.port2.reset();
    // sharers.port3.reset();
    // sharers.port4.reset();
    // sharers.port5.reset();
    // sharers.port6.reset();
    // sharers.port7.reset();
    // sharers.port8.reset();
    // sharers.port9.reset();

    // owners.port1.reset();
    // owners.port2.reset();
    // owners.port3.reset();
    // owners.port4.reset();
    // owners.port5.reset();
    // owners.port6.reset();
    // owners.port7.reset();
    // owners.port8.reset();
    // owners.port9.reset();

    // evict_ways.port1.reset();
    // evict_ways.port2.reset();

    wait();
}

inline void llc::reset_states()
{
    for (int i=0; i<SETS; i++) { // do not unroll
	for (int j=0; j<LLC_WAYS; j++) { // do not unroll
	    {
		HLS_DEFINE_PROTOCOL("llc-reset-states-protocol");
		states.port1[0][(i << LLC_WAY_BITS) + j] = INVALID;
		wait();
	    }
	}
    }
}

void llc::read_set(llc_addr_t base)
{
    tag_buf[0]	   = tags.port2[0][base + 0];
    state_buf[0]   = states.port2[0][base + 0];
    hprot_buf[0]   = hprots.port2[0][base + 0];
    line_buf[0]   = lines.port2[0][base + 0];
    //    sharers_buf[0] = sharers.port2[0][base + 0];
    //    owners_buf[0]  = owners.port2[0][base + 0];
    tag_buf[1]	   = tags.port3[0][base + 1];
    state_buf[1]   = states.port3[0][base + 1];
    hprot_buf[1]   = hprots.port3[0][base + 1];
    line_buf[1]   = lines.port3[0][base + 1];
    //    sharers_buf[1] = sharers.port3[0][base + 1];
    //    owners_buf[1]  = owners.port3[0][base + 1];
    tag_buf[2]	   = tags.port4[0][base + 2];
    state_buf[2]   = states.port4[0][base + 2];
    hprot_buf[2]   = hprots.port4[0][base + 2];
    line_buf[2]   = lines.port4[0][base + 2];
    //    sharers_buf[2] = sharers.port4[0][base + 2];
    //    owners_buf[2]  = owners.port4[0][base + 2];
    tag_buf[3]	   = tags.port5[0][base + 3];
    state_buf[3]   = states.port5[0][base + 3];
    hprot_buf[3]   = hprots.port5[0][base + 3];
    line_buf[3]   = lines.port5[0][base + 3];
    //    sharers_buf[3] = sharers.port5[0][base + 3];
    //    owners_buf[3]  = owners.port5[0][base + 3];
    tag_buf[4]	   = tags.port6[0][base + 4];
    state_buf[4]   = states.port6[0][base + 4];
    hprot_buf[4]   = hprots.port6[0][base + 4];
    line_buf[4]   = lines.port6[0][base + 4];
    //    sharers_buf[4] = sharers.port6[0][base + 4];
    //    owners_buf[4]  = owners.port6[0][base + 4];
    tag_buf[5]	   = tags.port7[0][base + 5];
    state_buf[5]   = states.port7[0][base + 5];
    hprot_buf[5]   = hprots.port7[0][base + 5];
    line_buf[5]   = lines.port7[0][base + 5];
    //    sharers_buf[5] = sharers.port7[0][base + 5];
    //    owners_buf[5]  = owners.port7[0][base + 5];
    tag_buf[6]	   = tags.port8[0][base + 6];
    state_buf[6]   = states.port8[0][base + 6];
    hprot_buf[6]   = hprots.port8[0][base + 6];
    line_buf[6]   = lines.port8[0][base + 6];
    //    sharers_buf[6] = sharers.port8[0][base + 6];
    //    owners_buf[6]  = owners.port8[0][base + 6];
    tag_buf[7]	   = tags.port9[0][base + 7];
    state_buf[7]   = states.port9[0][base + 7];
    hprot_buf[7]   = hprots.port9[0][base + 7];
    line_buf[7]   = lines.port9[0][base + 7];
    //    sharers_buf[7] = sharers.port9[0][base + 7];
    //    owners_buf[7]  = owners.port9[0][base + 7];
}

void llc::lookup(tag_t tag, set_t set, llc_way_t &way, bool &evict, llc_addr_t &llc_addr)
{
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "llc-tag-lookup-latency");

    bool tag_hit = false, empty_way_found = false;
    llc_way_t hit_way = 0, empty_way = 0, evict_way = 0;
    evict = false;

    const llc_addr_t base = (set << LLC_WAY_BITS);

    // evict_way_buf = evict_ways.port2[0][set];

    read_set(base);

    for (int i = 0; i < LLC_WAYS; i++) {
    	HLS_UNROLL_LOOP(ON, "llc-lookup-unroll");

    	// tag_buf[i]   = tags[base + i];
    	// state_buf[i] = states[base + i];
    	// hprot_buf[i] = hprots[base + i];
    	// line_buf[i] = lines[base + i];
    	// // sharers_buf[i] = sharers[base + i];
    	// // owner_buf[i] = owners[base + i];

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
