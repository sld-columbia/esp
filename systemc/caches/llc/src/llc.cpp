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

#ifdef LLC_DEBUG
	bookmark_tmp = 0;
	asserts_tmp = 0;
#endif

	if (llc_rst_tb.nb_can_get()) {

	    bool rst_tmp;
	    llc_rst_tb.nb_get(rst_tmp);

	    if (!rst_tmp) { // reset

		this->reset_states();

	    } else { // partial flush (only VALID data lines)

		for (int set = 0; set < LLC_SETS; set++) {

		    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "llc-flush-set");

		    CACHE_REPORT_VAR(sc_time_stamp(), "Flush set", set);

		    const llc_addr_t base = (set << LLC_WAY_BITS);

		    read_set(base);

		    for (int way = 0; way < LLC_WAYS; way++) {

			HLS_DEFINE_PROTOCOL("llc-flush-body");

			CACHE_REPORT_VAR(sc_time_stamp(), "Flush way", way);
			CACHE_REPORT_VAR(sc_time_stamp(), "State", state_buf[way]);
			CACHE_REPORT_VAR(sc_time_stamp(), "Hprot", hprot_buf[way]);
			CACHE_REPORT_VAR(sc_time_stamp(), "Tag", tag_buf[way]);

			line_addr_t line_addr = (tag_buf[way] << LLC_SET_BITS) | (set);

			CACHE_REPORT_VAR(sc_time_stamp(), "lineaddr", line_addr);

			llc_addr_t llc_addr = (set << LLC_WAY_BITS) + way;

			if (state_buf[way] == VALID && hprot_buf[way] == DATA) {

			    CACHE_REPORT_INFO("Found something");
			    
			    states[llc_addr] = INVALID;
			    sharers[llc_addr] = 0;

			    if (dirty_bit_buf[way] == true) {

				CACHE_REPORT_INFO("Dirty bit too");

				dirty_bits[llc_addr] = false;

				CACHE_REPORT_VAR(sc_time_stamp(), "mem line addr", line_addr);
				send_mem_req(WRITE, line_addr, hprot_buf[way], line_buf[way]);
			    }
			}
			wait();
		    }

		    {
			HLS_DEFINE_PROTOCOL("llc-flush-new-set");

			wait();
		    }
		}
	    }

	    llc_rst_tb_done.put(1);

	} else if (llc_rsp_in.nb_can_get()) {

	    llc_rsp_in_t rsp_in;
	    line_breakdown_t<llc_tag_t, llc_set_t> line_br;
	    llc_way_t way;
	    llc_addr_t llc_addr;
	    bool evict;

	    get_rsp_in(rsp_in);

	    line_br.llc_line_breakdown(rsp_in.addr);

	    if ((req_stall == true) && (line_br.tag == req_in_stalled_tag)
		&& (line_br.set == req_in_stalled_set)) {
		req_stall = false;
	    }

	    lookup(line_br.tag, line_br.set, way, evict, llc_addr);

	    if (sharers_buf[way] != 0) {
		states[llc_addr] = SHARED;
	    } else {
		states[llc_addr] = VALID;
	    }

	    CACHE_REPORT_VAR(sc_time_stamp(), "RECEIVED", rsp_in.line);
	    CACHE_REPORT_VAR(sc_time_stamp(), "RECEIVED", req_stall);
	    CACHE_REPORT_VAR(sc_time_stamp(), "RECEIVED", req_in_stalled_valid);
	    CACHE_REPORT_VAR(sc_time_stamp(), "RECEIVED", req_in_stalled_tag);
	    CACHE_REPORT_VAR(sc_time_stamp(), "RECEIVED", req_in_stalled_set);

	    lines[llc_addr] = rsp_in.line;

	    dirty_bits[llc_addr] = true;

	} else if ((llc_req_in.nb_can_get() && !req_stall) || 
		   (!req_stall && req_in_stalled_valid)) {

	    llc_req_in_t req_in;
	    llc_rsp_in_t rsp_in;
	    line_breakdown_t<llc_tag_t, llc_set_t> line_br;
	    llc_way_t way;
	    llc_addr_t llc_addr;
	    bool evict;

	    if (!req_in_stalled_valid) {
		get_req_in(req_in);
	    } else {
		req_in_stalled_valid = false;
		req_in = req_in_stalled;

		CACHE_REPORT_INFO("BACK FROM STALL");
	    }

	    line_br.llc_line_breakdown(req_in.addr);

	    CACHE_REPORT_VAR(sc_time_stamp(), "req_get addr: ", req_in.addr);

	    lookup(line_br.tag, line_br.set, way, evict, llc_addr);

	    // if (evict && ((req_in.coh_msg != REQ_GETS && req_in.coh_msg != REQ_GETM) ||
	    // 		  (state_buf[way] != VALID))) {
	    // 	GENERIC_ASSERT;
	    // }

	    if (evict && !(state_buf[way] == SD)) {

		HLS_DEFINE_PROTOCOL("llc-eviction");

		line_addr_t addr_evict = (tag_buf[way] << LLC_SET_BITS) + line_br.set;

		if (way == evict_way_buf)
		    evict_ways[line_br.set] = evict_way_buf + 1;

		if (state_buf[way] == EXCLUSIVE || state_buf[way] == MODIFIED) {
		    // set requestor same as owner, it means requestor = LLC
		    send_fwd_out(FWD_GETM, addr_evict, owner_buf[way], owner_buf[way]);

		    owners[llc_addr] = 0;

		    while (!llc_rsp_in.nb_can_get()) {
			HLS_DEFINE_PROTOCOL("evict-wait-for-rsp");
			wait();
		    }

		    get_rsp_in(rsp_in);

		    CACHE_REPORT_VAR(sc_time_stamp(), "dma evict E", rsp_in.coh_msg);		    

		    if (rsp_in.coh_msg == RSP_DATA) {
			CACHE_REPORT_VAR(sc_time_stamp(), "dma evict E data", rsp_in.line);		    
			send_mem_req(WRITE, addr_evict, hprot_buf[way], rsp_in.line);

		    } else if (dirty_bit_buf[way]) { // rsp_in.coh_msg == RSP_INVACK

			CACHE_REPORT_VAR(sc_time_stamp(), "dma evict E dirty", way);		    
			send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);
		    }
		} else if (state_buf[way] == SHARED) {

		    CACHE_REPORT_VAR(sc_time_stamp(), "evict shared", way);		    

		    for (int i = 0; i < MAX_N_L2; i++) {
			if (sharers_buf[way] & (1 << i))
			    send_fwd_out(FWD_INV, addr_evict, i, i);
			wait();
		    }

		    sharers[llc_addr] = 0;

		    if (dirty_bit_buf[way])
			send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);

		} else if (state_buf[way] == VALID) {
		    if (dirty_bit_buf[way])
			send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);
		}

		state_buf[way] = INVALID;

		wait();
	    }

	    switch (req_in.coh_msg) {
	    case REQ_GETS :
		LLC_GETS;
		switch (state_buf[way]) {

		case INVALID :
		case VALID :
		    if (state_buf[way] == INVALID) {
			CACHE_REPORT_VAR(sc_time_stamp(), "gets-invalid-mem-req: ", req_in.addr);
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots[llc_addr] = req_in.hprot;
			lines[llc_addr] = line_buf[way];
			tags[llc_addr] = line_br.tag;
			dirty_bits[llc_addr] = false;
		    }

		    if (req_in.hprot == 0) {
			states[llc_addr] = SHARED;
			send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
			sharers[llc_addr] = 1 << req_in.req_id;
		    } else {
			states[llc_addr] = EXCLUSIVE;
			owners[llc_addr] = req_in.req_id;
			send_rsp_out(RSP_EDATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    }

		    break;

		case SHARED :
		    
		    GETS_S;

		    sharers[llc_addr] = sharers_buf[way] | (1 << req_in.req_id);
		    send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		    break;

		case EXCLUSIVE :
		case MODIFIED :

		    GETS_EM;

		    sharers[llc_addr] = (1 << req_in.req_id) | (1 << owner_buf[way]);
		    states[llc_addr] = SD;
		    send_fwd_out(FWD_GETS, req_in.addr, req_in.req_id, owner_buf[way]);
		    break;

		case SD :

		    GETS_SD;

		    req_stall = true;
		    req_in_stalled_valid = true;
		    req_in_stalled = req_in;
		    req_in_stalled_tag = line_br.tag;
		    req_in_stalled_set = line_br.set;

		    break;

		default :
		    GENERIC_ASSERT;
		}

		break;

	    case REQ_GETM :
		LLC_GETM;
		switch (state_buf[way]) {

		case INVALID :
		case VALID :
		    if (state_buf[way] == INVALID) {
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots[llc_addr] = req_in.hprot;
			lines[llc_addr] = line_buf[way];
			tags[llc_addr] = line_br.tag;
			dirty_bits[llc_addr] = false;
		    }
		    owners[llc_addr] = req_in.req_id;
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
			for (int i = 0; i < MAX_N_L2; i++) {
			    if (((sharers_buf[way] & (1 << i)) != 0) && (i != req_in.req_id)) {
				CACHE_REPORT_VAR(sc_time_stamp(), "inv id", i);
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

		    GETM_EM;

		    owners[llc_addr] = req_in.req_id;
		    send_fwd_out(FWD_GETM, req_in.addr, req_in.req_id, owner_buf[way]);
		    break;

		case SD :
		    req_stall = true;
		    req_in_stalled_valid = true;
		    req_in_stalled = req_in;
		    req_in_stalled_tag = line_br.tag;
		    req_in_stalled_set = line_br.set;

		    break;

		default :
		    GENERIC_ASSERT;
		}

		break;

	    case REQ_PUTS :
		LLC_PUTS;
		send_fwd_out(FWD_PUTACK, req_in.addr, req_in.req_id, 0);

		switch (state_buf[way]) {

		case INVALID :
		case VALID :
		case MODIFIED :
		    break;

		case SHARED :
		    sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    sharers[llc_addr] = sharers_buf[way];

		    if (sharers_buf[way] == 0) {
			states[llc_addr] = VALID;
		    }
		    break;

		case EXCLUSIVE :
		    if (owner_buf[way] == req_in.req_id) {
			states[llc_addr] = VALID;
		    }
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
		send_fwd_out(FWD_PUTACK, req_in.addr, req_in.req_id, 0);

		switch (state_buf[way]) {

		case INVALID :
		case VALID :
		    break;

		case SHARED :
		    sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    sharers[llc_addr] = sharers_buf[way];
		    if (sharers_buf[way] == 0) {
			states[llc_addr] = VALID;
		    }
		    break;

		case EXCLUSIVE :
		case MODIFIED :
		    if (owner_buf[way] == req_in.req_id) {
			states[llc_addr] = VALID;
			lines[llc_addr] = req_in.line;
			dirty_bits[llc_addr] = true;
		    }
		    break;

		case SD :
		    sharers[llc_addr] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    break;

		default :
		    GENERIC_ASSERT;
		}
		break;

	    case REQ_DMA_READ:

		if (state_buf[way] == SD) {

		    req_stall = true;
		    req_in_stalled_valid = true;
		    req_in_stalled = req_in;
		    req_in_stalled_tag = tag_buf[way];
		    req_in_stalled_set = line_br.set;;

		    CACHE_REPORT_INFO("DMA READ STALL");

		} else {

		    if (state_buf[way] == INVALID) {
			send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			get_mem_rsp(line_buf[way]);
			hprots[llc_addr] = DATA;
			lines[llc_addr] = line_buf[way];
			tags[llc_addr] = line_br.tag;
			states[llc_addr] = VALID;
			dirty_bits[llc_addr] = false;
		    }

		    send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);
		}

		break;

	    case REQ_DMA_WRITE:

		if (state_buf[way] == SD) {

		    req_stall = true;
		    req_in_stalled_valid = true;
		    req_in_stalled = req_in;
		    req_in_stalled_tag = tag_buf[way];
		    req_in_stalled_set = line_br.set;;

		    CACHE_REPORT_INFO("DMA WRITE STALL");

		} else {

		    if (state_buf[way] == INVALID) {
			states[llc_addr] = VALID;
			hprots[llc_addr] = DATA;
			tags[llc_addr] = line_br.tag;
		    }

		    CACHE_REPORT_INFO("DMA write.");    

		    lines[llc_addr] = req_in.line;
		    dirty_bits[llc_addr] = true;
		}

		break;

	    default :
		GENERIC_ASSERT;
	    }
	    
	}

#ifdef LLC_DEBUG
	asserts.write(asserts_tmp);
	bookmark.write(bookmark_tmp);
	custom_dbg.write(evict);

	req_stall_out.write(req_stall);
	req_in_stalled_valid_out.write(req_in_stalled_valid);
	req_in_stalled_out.write(req_in_stalled);

	is_rsp_to_get_out.write(is_rsp_to_get);
	is_req_to_get_out.write(is_req_to_get);

	for (int i = 0; i < LLC_WAYS; i++) {
	    HLS_UNROLL_LOOP(ON, "buf-output-unroll");
	    tag_buf_out[i] = tag_buf[i];
	    state_buf_out[i] = state_buf[i];
	    sharers_buf_out[i] = sharers_buf[i];
	    owner_buf_out[i] = owner_buf[i];
	}
#endif

	wait();

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
    LLC_RESET_IO;

    wait();

    llc_req_in.reset_get();
    llc_rsp_in.reset_get();
    llc_mem_rsp.reset_get();
    llc_rst_tb.reset_get();
    llc_rsp_out.reset_put();
    llc_fwd_out.reset_put();
    llc_mem_req.reset_put();
    llc_rst_tb_done.reset_put();

    req_stall = false;
    req_in_stalled_valid = false;

#ifdef LLC_DEBUG
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

    req_stall_out.write(0);
    req_in_stalled_valid_out.write(0);
    is_rsp_to_get_out.write(0);
    is_req_to_get_out.write(0);
#endif

    wait();
}

inline void llc::reset_states()
{
    HLS_DEFINE_PROTOCOL("llc-reset-states-protocol");
    wait();
    for (int i=0; i<LLC_SETS; i++) { // do not unroll

	evict_ways[i] = 0;

	for (int j=0; j<LLC_WAYS; j++) { // do not unroll

	    states[(i << LLC_WAY_BITS) + j] = INVALID;
	    dirty_bits[(i << LLC_WAY_BITS) + j] = false;
	    sharers[(i << LLC_WAY_BITS) + j] = 0;

	    wait();
	}
    }
}

void llc::read_set(llc_addr_t base)
{
    for (int i = LLC_WAYS - 1; i >= 0; i--) {
	HLS_UNROLL_LOOP(ON, "llc-read-set");
	tag_buf[i]	 = tags[base + i];
	state_buf[i]	 = states[base + i];
	hprot_buf[i]	 = hprots[base + i];
	line_buf[i]	 = lines[base + i];
	sharers_buf[i]   = sharers[base + i];
	owner_buf[i]	 = owners[base + i];
	dirty_bit_buf[i] = dirty_bits[base + i];
    }

    // CACHE_REPORT_VAR(sc_time_stamp(), "tag0", tag_buf[0]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag1", tag_buf[1]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag2", tag_buf[2]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag3", tag_buf[3]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag4", tag_buf[4]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag5", tag_buf[5]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag6", tag_buf[6]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag7", tag_buf[7]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag8", tag_buf[8]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag9", tag_buf[9]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag10", tag_buf[10]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag11", tag_buf[11]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag12", tag_buf[12]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag13", tag_buf[13]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag14", tag_buf[14]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "tag15", tag_buf[15]);

    // CACHE_REPORT_VAR(sc_time_stamp(), "state0", state_buf[0]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state1", state_buf[1]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state2", state_buf[2]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state3", state_buf[3]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state4", state_buf[4]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state5", state_buf[5]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state6", state_buf[6]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state7", state_buf[7]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state8", state_buf[8]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state9", state_buf[9]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state10", state_buf[10]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state11", state_buf[11]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state12", state_buf[12]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state13", state_buf[13]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state14", state_buf[14]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "state15", state_buf[15]);

    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit0", dirty_bit_buf[0]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit1", dirty_bit_buf[1]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit2", dirty_bit_buf[2]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit3", dirty_bit_buf[3]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit4", dirty_bit_buf[4]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit5", dirty_bit_buf[5]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit6", dirty_bit_buf[6]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit7", dirty_bit_buf[7]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit8", dirty_bit_buf[8]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit9", dirty_bit_buf[9]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit10", dirty_bit_buf[10]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit11", dirty_bit_buf[11]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit12", dirty_bit_buf[12]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit13", dirty_bit_buf[13]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit14", dirty_bit_buf[14]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "dirty_bit15", dirty_bit_buf[15]);

    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers0", sharers_buf[0]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers1", sharers_buf[1]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers2", sharers_buf[2]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers3", sharers_buf[3]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers4", sharers_buf[4]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers5", sharers_buf[5]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers6", sharers_buf[6]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers7", sharers_buf[7]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers8", sharers_buf[8]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers9", sharers_buf[9]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers10", sharers_buf[10]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers11", sharers_buf[11]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers12", sharers_buf[12]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers13", sharers_buf[13]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers14", sharers_buf[14]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "sharers15", sharers_buf[15]);

    // CACHE_REPORT_VAR(sc_time_stamp(), "owner0", owner_buf[0]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner1", owner_buf[1]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner2", owner_buf[2]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner3", owner_buf[3]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner4", owner_buf[4]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner5", owner_buf[5]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner6", owner_buf[6]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner7", owner_buf[7]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner8", owner_buf[8]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner9", owner_buf[9]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner10", owner_buf[10]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner11", owner_buf[11]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner12", owner_buf[12]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner13", owner_buf[13]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner14", owner_buf[14]);
    // CACHE_REPORT_VAR(sc_time_stamp(), "owner15", owner_buf[15]);
}

// TODO make *_buf only with LLC_LOOKUP_WAYS positions to save area
void llc::lookup(llc_tag_t tag, llc_set_t set, llc_way_t &way, bool &evict, llc_addr_t &llc_addr)
{
    HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE, "llc-tag-lookup-latency");

    bool tag_hit = false, empty_way_found = false, evict_valid = false, evict_not_sd = false;
    llc_way_t hit_way = 0, empty_way = 0, evict_way_valid = 0, evict_way_not_sd = 0;

    evict = false;

    const llc_addr_t base = (set << LLC_WAY_BITS);

    // for (int i = 0; i < LLC_WAYS/LLC_LOOKUP_WAYS; i++) {
    //read_set(base + LLC_LOOKUP_WAYS*i, i*LLC_LOOKUP_WAYS);
    // }

    read_set(base);

    /*
     * Hit and empty way policy: If any, the empty way selected is the closest to 0.
     */

    for (int i = LLC_WAYS - 1; i >= 0; i--) {
    	HLS_UNROLL_LOOP(ON, "llc-lookup-unroll");

    	if (tag_buf[i] == tag && state_buf[i] != INVALID) {
    	    tag_hit = true;
    	    hit_way = i;
    	}

    	if (state_buf[i] == INVALID) {
    	    empty_way_found = true;
    	    empty_way = i;
    	}
    }


    /*
     * Eviction policy: FIFO like.
     * - Starting from evict_ways[set] evict first VALID line if any
     * - Otherwise starting from evict_ways[set] evict first line not SD if any
     * - Otherwise evict evict_ways[set] way (it is in SD state). This will cause a stall.
     */

    evict_way_buf = evict_ways[set];

    for (int i = LLC_WAYS - 1; i >= 0; i--) {
    	HLS_UNROLL_LOOP(ON, "llc-lookup-evict-unroll");

	llc_way_t way = (llc_way_t) i + evict_way_buf;

    	if (state_buf[way] == VALID) {
    	    evict_valid = true;
	    evict_way_valid = way;
	    break;
    	} 

	if (state_buf[way] != SD) {
	    evict_not_sd = true;
	    evict_way_not_sd = way;
	}
    }

    if (tag_hit == true) {
	way = hit_way;
    } else if (empty_way_found == true) {
	way = empty_way;
    } else if (evict_valid) {
	way = evict_way_valid;
	evict = true;
    } else if (evict_not_sd) {
	way = evict_way_not_sd;
	evict = true;
    } else {
	way = evict_way_buf;
	evict = true;
    }

    llc_addr = base + way;

#if LLC_DEBUG
    tag_hit_out = tag_hit;
    hit_way_out = hit_way;
    empty_way_found_out = empty_way_found;
    empty_way_out = empty_way;
    evict_out = evict;
    way_out = way;
    llc_addr_out = llc_addr;
#endif
}

void llc::send_mem_req(bool hwrite, line_addr_t addr, hprot_t hprot, line_t line)
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
    LLC_GET_RSP_IN;

    llc_rsp_in.nb_get(rsp_in);
}

void llc::send_rsp_out(coh_msg_t coh_msg, line_addr_t addr, line_t line, cache_id_t req_id,
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

void llc::send_fwd_out(coh_msg_t coh_msg, line_addr_t addr, cache_id_t req_id,
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
