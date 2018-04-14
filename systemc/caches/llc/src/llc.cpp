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

	bool is_rst_to_get = false;
	bool is_rsp_to_get = false;
	bool is_req_to_get = false;

	if (llc_rst_tb.nb_can_get()) {

	    is_rst_to_get = true;

	} else if (llc_rsp_in.nb_can_get()) {

	    is_rsp_to_get = true;

	} else if ((llc_req_in.nb_can_get() && !req_stall) || 
		   (!req_stall && req_in_stalled_valid)) {

	    is_req_to_get = true;
	}

#ifdef LLC_DEBUG
	bookmark_tmp = 0;
	asserts_tmp = 0;
#endif

	if (is_rst_to_get) {

	    bool rst_tmp = false;
	    llc_rst_tb.nb_get(rst_tmp);

	    if (!rst_tmp) { // reset

		this->reset_states();

	    } else { // partial flush (only VALID data lines)

		LLC_FLUSH;

		for (int set = 0; set < LLC_SETS; set++) {

		    const llc_addr_t base = (set << LLC_WAY_BITS);

		    for (int i = LLC_WAYS/LLC_LOOKUP_WAYS - 1; i >= 0 ; i--) {
			read_set(base, i * LLC_LOOKUP_WAYS);
		    }

		    {
			HLS_DEFINE_PROTOCOL("llc-flush-set-protocol");
			wait();
		    }

		    for (int way = 0; way < LLC_WAYS; way++) {

#ifdef LLC_DEBUG
			flush_set_out.write(set);
			flush_way_out.write(way);
#endif			

			line_addr_t line_addr = (tag_buf[way] << LLC_SET_BITS) | (set);

			llc_addr_t llc_addr = (set << LLC_WAY_BITS) + way;

			if (state_buf[way] == VALID && hprot_buf[way] == DATA) {

			    states.port1[0][llc_addr] = INVALID;
			    sharers.port1[0][llc_addr] = 0;

			    if (dirty_bit_buf[way]) {

				FLUSH_DIRTY_LINE;

				dirty_bits.port1[0][llc_addr] = 0;

				send_mem_req(WRITE, line_addr, hprot_buf[way], line_buf[way]);
			    }
			}

			{
			    HLS_DEFINE_PROTOCOL("llc-flush-way-protocol");
			    wait();
			}
		    }
		}
	    }

	    llc_rst_tb_done.put(1);

	} else if (is_rsp_to_get) {


	    llc_rsp_in_t rsp_in;

	    get_rsp_in(rsp_in);

	    process_rsp_in(rsp_in);

	} else if (is_req_to_get) {

	    llc_req_in_t req_in;
	    line_breakdown_t<llc_tag_t, llc_set_t> line_br;
	    llc_way_t way;
	    llc_addr_t llc_addr;
	    bool evict;

	    if (!req_in_stalled_valid) {
		get_req_in(req_in);
	    } else {
		req_in_stalled_valid = false;
		req_in = req_in_stalled;
	    }

	    if (req_in.coh_msg == REQ_DMA_READ_BURST ||
		req_in.coh_msg == REQ_DMA_WRITE_BURST) {

		DMA_BURST;

		addr_t addr = req_in.addr;
		dma_length_t length = req_in.line;
		dma_length_t dma_length = 0;
		bool dma_done = false;

		while (!dma_done) {

		    line_br.llc_line_breakdown(addr);

		    lookup(line_br.tag, line_br.set, way, evict, llc_addr);

		    line_addr_t addr_evict = (tag_buf[way] << LLC_SET_BITS) + line_br.set;

#ifdef LLC_DEBUG
		    evict_addr_out.write(addr_evict);
#endif

		    if (evict) {

			LLC_EVICT;

			{
			    HLS_DEFINE_PROTOCOL("evict-start-protocol");
			    wait();
			}

			llc_rsp_in_t rsp_in;

			if (state_buf[way] == SD) {
			    // receive and process RSP_IN until one matching the addr_evict arrives
			    rsp_in = wait_rsp_in(addr_evict);
			    // process the RSP_IN that matches the addr_evict
			    process_rsp_in(rsp_in);

			    {
				HLS_DEFINE_PROTOCOL("evict-start-protocol");
				wait();
			    }
			}


			if (way == evict_way_buf)
			    evict_ways.port1[0][line_br.set] = evict_way_buf + 1;

			if (state_buf[way] == EXCLUSIVE || state_buf[way] == MODIFIED) {

			    EVICT_EM;

			    // set requestor same as owner, it means requestor = LLC
			    send_fwd_out(FWD_GETM, addr_evict, owner_buf[way], owner_buf[way]);

			    owners.port1[0][llc_addr] = 0;

			    {
				HLS_DEFINE_PROTOCOL("evict-em-protocol");
				wait();
			    }

			    // receive and process RSP_IN until one matching the addr_evict arrives
			    rsp_in = wait_rsp_in(addr_evict);

			    if (rsp_in.coh_msg == RSP_DATA)
				send_mem_req(WRITE, addr_evict, hprot_buf[way], rsp_in.line);

			    else if (dirty_bit_buf[way]) // rsp_in.coh_msg == RSP_INVACK
				send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);

			} else if (state_buf[way] == SHARED) {

			    EVICT_S;

			    for (int i = 0; i < MAX_N_L2; i++) {
				if (sharers_buf[way] & (1 << i))
				    send_fwd_out(FWD_INV, addr_evict, i, i);
				wait();
			    }

			    sharers.port1[0][llc_addr] = 0;

			    if (dirty_bit_buf[way])
				send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);

			} else if (state_buf[way] == VALID) {

			    EVICT_V;

			    if (dirty_bit_buf[way])
				send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);
			}

			state_buf[way] = INVALID;

			{
			    HLS_DEFINE_PROTOCOL("llc-req-in-after-evict");
			    wait();
			}
		    }

		    if (req_in.coh_msg == REQ_DMA_READ_BURST) {

			LLC_DMA_READ_BURST;

			dma_length++;

			if (dma_length == length)
			    dma_done = true;

			if (state_buf[way] == INVALID) {

			    DMA_READ_I;

			    send_mem_req(READ, addr, req_in.hprot, 0);
			    get_mem_rsp(line_buf[way]);
			}

			send_rsp_out(RSP_DATA_DMA, addr, line_buf[way], 
				     req_in.req_id, 0, dma_done);

			if (state_buf[way] == INVALID) {

			    hprots.port1[0][llc_addr] = DATA;
			    lines.port1[0][llc_addr] = line_buf[way];
			    tags.port1[0][llc_addr] = line_br.tag;
			    states.port1[0][llc_addr] = VALID;
			    dirty_bits.port1[0][llc_addr] = 0;
			}

		    } else if (req_in.coh_msg == REQ_DMA_WRITE_BURST) {

			LLC_DMA_WRITE_BURST;

			if (state_buf[way] == INVALID) {

			    DMA_WRITE_I;

			    states.port1[0][llc_addr] = VALID;
			    hprots.port1[0][llc_addr] = DATA;
			    tags.port1[0][llc_addr] = line_br.tag;
			}

			lines.port1[0][llc_addr] = req_in.line;
			dirty_bits.port1[0][llc_addr] = 1;

			if (req_in.hprot) {

			    dma_done = true;

			} else {

			    while (!llc_req_in.nb_can_get()) {
				HLS_DEFINE_PROTOCOL("evict-wait-for-rsp");
				wait();
			    }

			    get_req_in(req_in);
			}
		    }

		    addr++;
		}

	    } else {

		line_br.llc_line_breakdown(req_in.addr);

		lookup(line_br.tag, line_br.set, way, evict, llc_addr);

		// if (evict && ((req_in.coh_msg != REQ_GETS && req_in.coh_msg != REQ_GETM) ||
		// 		  (state_buf[way] != VALID))) {
		// 	GENERIC_ASSERT;
		// }

		    line_addr_t addr_evict = (tag_buf[way] << LLC_SET_BITS) + line_br.set;

#ifdef LLC_DEBUG
		    evict_addr_out.write(addr_evict);
#endif

		    if (evict) {

			LLC_EVICT;

			llc_rsp_in_t rsp_in;

			if (state_buf[way] == SD) {
			    // receive and process RSP_IN until one matching the addr_evict arrives
			    rsp_in = wait_rsp_in(addr_evict);
			    // process the RSP_IN that matches the addr_evict
			    process_rsp_in(rsp_in);
			}

			{
			    HLS_DEFINE_PROTOCOL("llc-req-in-after-lookup");
			    wait();
			}

			if (way == evict_way_buf)
			    evict_ways.port1[0][line_br.set] = evict_way_buf + 1;

			if (state_buf[way] == EXCLUSIVE || state_buf[way] == MODIFIED) {

			    EVICT_EM;

			    // set requestor same as owner, it means requestor = LLC
			    send_fwd_out(FWD_GETM, addr_evict, owner_buf[way], owner_buf[way]);

			    owners.port1[0][llc_addr] = 0;

			    // receive and process RSP_IN until one matching the addr_evict arrives
			    rsp_in = wait_rsp_in(addr_evict);

			    if (rsp_in.coh_msg == RSP_DATA)
				send_mem_req(WRITE, addr_evict, hprot_buf[way], rsp_in.line);

			    else if (dirty_bit_buf[way]) // rsp_in.coh_msg == RSP_INVACK
				send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);

			} else if (state_buf[way] == SHARED) {

			    EVICT_S;

			    for (int i = 0; i < MAX_N_L2; i++) {
				if (sharers_buf[way] & (1 << i))
				    send_fwd_out(FWD_INV, addr_evict, i, i);
				wait();
			    }

			    sharers.port1[0][llc_addr] = 0;

			    if (dirty_bit_buf[way])
				send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);

			} else if (state_buf[way] == VALID) {

			    EVICT_V;

			    if (dirty_bit_buf[way])
				send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);
			}

			state_buf[way] = INVALID;

			{
			    HLS_DEFINE_PROTOCOL("llc-req-in-after-evict");
			    wait();
			}
		    }

// 		if (evict) {

// 		    LLC_EVICT;

// 		    line_addr_t addr_evict = (tag_buf[way] << LLC_SET_BITS) + line_br.set;

// #ifdef LLC_DEBUG
// 		    evict_addr_out.write(addr_evict);
// #endif

// 		    if (way == evict_way_buf) {
// 			HLS_DEFINE_PROTOCOL("llc-req-in-after-lookup");
// 			wait();
// 			evict_ways.port1[0][line_br.set] = evict_way_buf + 1;
// 		    }

// 		    if (state_buf[way] == VALID) {

// 			EVICT_V;

// 			if (dirty_bit_buf[way])
// 			    send_mem_req(WRITE, addr_evict, hprot_buf[way], line_buf[way]);
// 		    }

// 		    state_buf[way] = INVALID;
// 		}

		switch (req_in.coh_msg) {

		case REQ_GETS :

		    LLC_GETS;

		    switch (state_buf[way]) {

		    case INVALID :
		    case VALID :
		    {		    
			GETS_IV;

			if (state_buf[way] == INVALID) {
			    send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			    get_mem_rsp(line_buf[way]);
			}

			if (req_in.hprot == 0) {
			    send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);

			    wait();

			    states.port1[0][llc_addr] = SHARED;
			    sharers.port1[0][llc_addr] = 1 << req_in.req_id;
			} else {
			    send_rsp_out(RSP_EDATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);

			    wait();

			    states.port1[0][llc_addr] = EXCLUSIVE;
			    owners.port1[0][llc_addr] = req_in.req_id;
			}

			if (state_buf[way] == INVALID) {
			    hprots.port1[0][llc_addr] = req_in.hprot;
			    lines.port1[0][llc_addr] = line_buf[way];
			    tags.port1[0][llc_addr] = line_br.tag;
			    dirty_bits.port1[0][llc_addr] = 0;
			}
		    }
		    break;

		    case SHARED :
		    {
			GETS_S;

			send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);

			wait();

			sharers.port1[0][llc_addr] = sharers_buf[way] | (1 << req_in.req_id);
		    }
		    break;

		    case EXCLUSIVE :
		    case MODIFIED :
		    {
			GETS_EM;

			send_fwd_out(FWD_GETS, req_in.addr, req_in.req_id, owner_buf[way]);

			wait();

			sharers.port1[0][llc_addr] = (1 << req_in.req_id) | (1 << owner_buf[way]);
			states.port1[0][llc_addr] = SD;
		    }
		    break;

		    case SD :
		    {
			GETS_SD;

			req_stall = true;
			req_in_stalled_valid = true;
			req_in_stalled = req_in;
			req_in_stalled_tag = line_br.tag;
			req_in_stalled_set = line_br.set;
		    }
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
		    {
			GETM_IV;

			if (state_buf[way] == INVALID) {
			    send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			    get_mem_rsp(line_buf[way]);
			}

			send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);

			wait();
		
			owners.port1[0][llc_addr] = req_in.req_id;
			states.port1[0][llc_addr] = MODIFIED;

			if (state_buf[way] == INVALID) {
			    hprots.port1[0][llc_addr] = req_in.hprot;
			    lines.port1[0][llc_addr] = line_buf[way];
			    tags.port1[0][llc_addr] = line_br.tag;
			    dirty_bits.port1[0][llc_addr] = 0;
			}
		    }
		    break;

		    case SHARED :
		    {
			GETM_S;

			invack_cnt_t invack_cnt = 0;

			for (int i = 0; i < MAX_N_L2; i++) {
			    if (((sharers_buf[way] & (1 << i)) != 0) && (i != req_in.req_id)) {
				send_fwd_out(FWD_INV, req_in.addr, req_in.req_id, i);
				invack_cnt++;
			    }
			    wait();
			}

			send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, invack_cnt);

			states.port1[0][llc_addr] = MODIFIED;
			owners.port1[0][llc_addr] = req_in.req_id;
			sharers.port1[0][llc_addr] = 0;
		    }
		    break;
		    
		    case EXCLUSIVE :
		    {
			GETM_E;

			send_fwd_out(FWD_GETM, req_in.addr, req_in.req_id, owner_buf[way]);

			wait();

			states.port1[0][llc_addr] = MODIFIED;
			owners.port1[0][llc_addr] = req_in.req_id;
		    }
		    break;

		    case MODIFIED :
		    {
			GETM_M;

			send_fwd_out(FWD_GETM, req_in.addr, req_in.req_id, owner_buf[way]);

			wait();

			owners.port1[0][llc_addr] = req_in.req_id;
		    }
		    break;

		    case SD :
		    {		    
			GETM_SD;

			req_stall = true;
			req_in_stalled_valid = true;
			req_in_stalled = req_in;
			req_in_stalled_tag = line_br.tag;
			req_in_stalled_set = line_br.set;
		    }
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
		    {
			PUTS_IVM;
		    }
		    break;

		    case SHARED :
		    {
			PUTS_S;

			wait();

			sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);
			sharers.port1[0][llc_addr] = sharers_buf[way];

			if (sharers_buf[way] == 0) {
			    states.port1[0][llc_addr] = VALID;
			}
		    }
		    break;

		    case EXCLUSIVE :
		    {
			PUTS_E;

			wait();

			if (owner_buf[way] == req_in.req_id) {
			    states.port1[0][llc_addr] = VALID;
			}
		    }
		    break;

		    case SD :
		    {
			PUTS_SD;

			wait();

			sharers.port1[0][llc_addr] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    }
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
		    {
			PUTM_IV;
		    }
		    break;

		    case SHARED :
		    {
			PUTM_S;

			wait();

			sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);
			sharers.port1[0][llc_addr] = sharers_buf[way];
			if (sharers_buf[way] == 0) {
			    states.port1[0][llc_addr] = VALID;
			}
		    }
		    break;

		    case EXCLUSIVE :
		    case MODIFIED :
		    {
			PUTM_EM;

			wait();

			if (owner_buf[way] == req_in.req_id) {
			    states.port1[0][llc_addr] = VALID;
			    lines.port1[0][llc_addr] = req_in.line;
			    dirty_bits.port1[0][llc_addr] = 1;
			}
		    }
		    break;

		    case SD :
		    {
			PUTM_SD;

			wait();

			sharers.port1[0][llc_addr] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    }
		    break;

		    default :
			GENERIC_ASSERT;
		    }
		    break;

		case REQ_DMA_READ:

		    LLC_DMA_READ;

		    if (state_buf[way] == SD) {

			DMA_READ_SD;

			req_stall = true;
			req_in_stalled_valid = true;
			req_in_stalled = req_in;
			req_in_stalled_tag = tag_buf[way];
			req_in_stalled_set = line_br.set;;

		    } else {

			DMA_READ_NOTSD;

			if (state_buf[way] == INVALID) {

			    DMA_READ_I;

			    send_mem_req(READ, req_in.addr, req_in.hprot, 0);
			    get_mem_rsp(line_buf[way]);
			}

			send_rsp_out(RSP_DATA, req_in.addr, line_buf[way], req_in.req_id, 0, 0);

			if (state_buf[way] == INVALID) {
			    wait();

			    hprots.port1[0][llc_addr] = DATA;
			    lines.port1[0][llc_addr] = line_buf[way];
			    tags.port1[0][llc_addr] = line_br.tag;
			    states.port1[0][llc_addr] = VALID;
			    dirty_bits.port1[0][llc_addr] = 0;
			}
		    }

		    break;

		case REQ_DMA_WRITE:

		    LLC_DMA_WRITE;

		    if (state_buf[way] == SD) {

			DMA_WRITE_SD;

			req_stall = true;
			req_in_stalled_valid = true;
			req_in_stalled = req_in;
			req_in_stalled_tag = tag_buf[way];
			req_in_stalled_set = line_br.set;;

		    } else {

			DMA_WRITE_NOTSD;

			wait();

			if (state_buf[way] == INVALID) {

			    DMA_WRITE_I;

			    states.port1[0][llc_addr] = VALID;
			    hprots.port1[0][llc_addr] = DATA;
			    tags.port1[0][llc_addr] = line_br.tag;
			}

			lines.port1[0][llc_addr] = req_in.line;
			dirty_bits.port1[0][llc_addr] = 1;
		    }

		    break;

		default :
		    GENERIC_ASSERT;
		}
	    }	    
	}

#ifdef LLC_DEBUG
	asserts.write(asserts_tmp);
	bookmark.write(bookmark_tmp);

	req_stall_out.write(req_stall);
	req_in_stalled_valid_out.write(req_in_stalled_valid);
	req_in_stalled_out.write(req_in_stalled);

	evict_way_buf_out = evict_way_buf;
	
	for (int i = 0; i < LLC_WAYS; i++) {
	    HLS_UNROLL_LOOP(ON, "buf-output-unroll");
	    tag_buf_out[i] = tag_buf[i];
	    state_buf_out[i] = state_buf[i];
	    hprot_buf_out[i] = hprot_buf[i];
	    line_buf_out[i] = line_buf[i];
	    sharers_buf_out[i] = sharers_buf[i];
	    owner_buf_out[i] = owner_buf[i];
	    dirty_bit_buf_out[i] = dirty_bit_buf[i];
	}
#endif

	{
	    HLS_DEFINE_PROTOCOL("nbget-protocol");
	    wait();
	}
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

    // Reset put-get channels
    llc_req_in.reset_get();
    llc_rsp_in.reset_get();
    llc_mem_rsp.reset_get();
    llc_rst_tb.reset_get();
    llc_rsp_out.reset_put();
    llc_fwd_out.reset_put();
    llc_mem_req.reset_put();
    llc_rst_tb_done.reset_put();

    /* Reset memories */

    tags.port1.reset();
    states.port1.reset();
    hprots.port1.reset();
    lines.port1.reset();
    owners.port1.reset();
    sharers.port1.reset();
    dirty_bits.port1.reset();

    tags.port2.reset();
    states.port2.reset();
    hprots.port2.reset();
    lines.port2.reset();
    owners.port2.reset();
    sharers.port2.reset();
    dirty_bits.port2.reset();

    tags.port3.reset();
    states.port3.reset();
    hprots.port3.reset();
    lines.port3.reset();
    owners.port3.reset();
    sharers.port3.reset();
    dirty_bits.port3.reset();

    tags.port4.reset();
    states.port4.reset();
    hprots.port4.reset();
    lines.port4.reset();
    owners.port4.reset();
    sharers.port4.reset();
    dirty_bits.port4.reset();

    tags.port5.reset();
    states.port5.reset();
    hprots.port5.reset();
    lines.port5.reset();
    owners.port5.reset();
    sharers.port5.reset();
    dirty_bits.port5.reset();

#if (LLC_WAYS >= 8)

    tags.port6.reset();
    states.port6.reset();
    hprots.port6.reset();
    lines.port6.reset();
    owners.port6.reset();
    sharers.port6.reset();
    dirty_bits.port6.reset();

    tags.port7.reset();
    states.port7.reset();
    hprots.port7.reset();
    lines.port7.reset();
    owners.port7.reset();
    sharers.port7.reset();
    dirty_bits.port7.reset();

    tags.port8.reset();
    states.port8.reset();
    hprots.port8.reset();
    lines.port8.reset();
    owners.port8.reset();
    sharers.port8.reset();
    dirty_bits.port8.reset();

    tags.port9.reset();
    states.port9.reset();
    hprots.port9.reset();
    lines.port9.reset();
    owners.port9.reset();
    sharers.port9.reset();
    dirty_bits.port9.reset();

#if (LLC_WAYS >= 16)

    tags.port10.reset();
    states.port10.reset();
    hprots.port10.reset();
    lines.port10.reset();
    owners.port10.reset();
    sharers.port10.reset();
    dirty_bits.port10.reset();

    tags.port11.reset();
    states.port11.reset();
    hprots.port11.reset();
    lines.port11.reset();
    owners.port11.reset();
    sharers.port11.reset();
    dirty_bits.port11.reset();

    tags.port12.reset();
    states.port12.reset();
    hprots.port12.reset();
    lines.port12.reset();
    owners.port12.reset();
    sharers.port12.reset();
    dirty_bits.port12.reset();

    tags.port13.reset();
    states.port13.reset();
    hprots.port13.reset();
    lines.port13.reset();
    owners.port13.reset();
    sharers.port13.reset();
    dirty_bits.port13.reset();

    tags.port14.reset();
    states.port14.reset();
    hprots.port14.reset();
    lines.port14.reset();
    owners.port14.reset();
    sharers.port14.reset();
    dirty_bits.port14.reset();

    tags.port15.reset();
    states.port15.reset();
    hprots.port15.reset();
    lines.port15.reset();
    owners.port15.reset();
    sharers.port15.reset();
    dirty_bits.port15.reset();

    tags.port16.reset();
    states.port16.reset();
    hprots.port16.reset();
    lines.port16.reset();
    owners.port16.reset();
    sharers.port16.reset();
    dirty_bits.port16.reset();

    tags.port17.reset();
    states.port17.reset();
    hprots.port17.reset();
    lines.port17.reset();
    owners.port17.reset();
    sharers.port17.reset();
    dirty_bits.port17.reset();

#endif
#endif

    evict_ways.port1.reset();
    evict_ways.port2.reset();
		   
    req_stall = false;
    req_in_stalled_valid = false;
    req_in_stalled_tag = 0;
    req_in_stalled_set = 0;

    for (int i = 0; i < LLC_WAYS; i++) {
	HLS_UNROLL_LOOP(ON, "reset-bufs");

	tag_buf[i] = 0;
	state_buf[i] = 0;
	line_buf[i] = 0;
	sharers_buf[i] = 0;
	owner_buf[i] = 0;
	dirty_bit_buf[i] = 0;
	hprot_buf[i] = 0;
    }

    evict_way_buf = 0;

#ifdef LLC_DEBUG
    asserts.write(0);
    bookmark.write(0);
    custom_dbg.write(0);

    tag_hit_out.write(0);
    hit_way_out.write(0);
    empty_way_found_out.write(0);
    empty_way_out.write(0);
    way_out.write(0);
    llc_addr_out.write(0);

    req_stall_out.write(0);
    req_in_stalled_valid_out.write(0);
#endif

    wait();
}

inline void llc::reset_states()
{
    LLC_RESET_STATES;

    for (int i=0; i<LLC_SETS; i++) { // do not unroll

	evict_ways.port1[0][i] = 0;

	for (int j=0; j<LLC_WAYS; j++) { // do not unroll

	    states.port1[0][(i << LLC_WAY_BITS) + j]	 = INVALID;
	    dirty_bits.port1[0][(i << LLC_WAY_BITS) + j] = 0;
	    sharers.port1[0][(i << LLC_WAY_BITS) + j]	 = 0;

	    wait();
	}
    }
}

void llc::read_set(llc_addr_t base, llc_way_t way_offset)
{

    tag_buf[0 + way_offset] = tags.port2[0][base + 0 + way_offset];
    state_buf[0 + way_offset] = states.port2[0][base + 0 + way_offset];
    hprot_buf[0 + way_offset] = hprots.port2[0][base + 0 + way_offset];
    line_buf[0 + way_offset] = lines.port2[0][base + 0 + way_offset];
    owner_buf[0 + way_offset] = owners.port2[0][base + 0 + way_offset];
    sharers_buf[0 + way_offset] = sharers.port2[0][base + 0 + way_offset];
    dirty_bit_buf[0 + way_offset] = dirty_bits.port2[0][base + 0 + way_offset];

    tag_buf[1 + way_offset] = tags.port3[0][base + 1 + way_offset];
    state_buf[1 + way_offset] = states.port3[0][base + 1 + way_offset];
    hprot_buf[1 + way_offset] = hprots.port3[0][base + 1 + way_offset];
    line_buf[1 + way_offset] = lines.port3[0][base + 1 + way_offset];
    owner_buf[1 + way_offset] = owners.port3[0][base + 1 + way_offset];
    sharers_buf[1 + way_offset] = sharers.port3[0][base + 1 + way_offset];
    dirty_bit_buf[1 + way_offset] = dirty_bits.port3[0][base + 1 + way_offset];

    tag_buf[2 + way_offset] = tags.port4[0][base + 2 + way_offset];
    state_buf[2 + way_offset] = states.port4[0][base + 2 + way_offset];
    hprot_buf[2 + way_offset] = hprots.port4[0][base + 2 + way_offset];
    line_buf[2 + way_offset] = lines.port4[0][base + 2 + way_offset];
    owner_buf[2 + way_offset] = owners.port4[0][base + 2 + way_offset];
    sharers_buf[2 + way_offset] = sharers.port4[0][base + 2 + way_offset];
    dirty_bit_buf[2 + way_offset] = dirty_bits.port4[0][base + 2 + way_offset];

    tag_buf[3 + way_offset] = tags.port5[0][base + 3 + way_offset];
    state_buf[3 + way_offset] = states.port5[0][base + 3 + way_offset];
    hprot_buf[3 + way_offset] = hprots.port5[0][base + 3 + way_offset];
    line_buf[3 + way_offset] = lines.port5[0][base + 3 + way_offset];
    owner_buf[3 + way_offset] = owners.port5[0][base + 3 + way_offset];
    sharers_buf[3 + way_offset] = sharers.port5[0][base + 3 + way_offset];
    dirty_bit_buf[3 + way_offset] = dirty_bits.port5[0][base + 3 + way_offset];

#if (LLC_WAYS >= 8)

    tag_buf[4 + way_offset] = tags.port6[0][base + 4 + way_offset];
    state_buf[4 + way_offset] = states.port6[0][base + 4 + way_offset];
    hprot_buf[4 + way_offset] = hprots.port6[0][base + 4 + way_offset];
    line_buf[4 + way_offset] = lines.port6[0][base + 4 + way_offset];
    owner_buf[4 + way_offset] = owners.port6[0][base + 4 + way_offset];
    sharers_buf[4 + way_offset] = sharers.port6[0][base + 4 + way_offset];
    dirty_bit_buf[4 + way_offset] = dirty_bits.port6[0][base + 4 + way_offset];

    tag_buf[5 + way_offset] = tags.port7[0][base + 5 + way_offset];
    state_buf[5 + way_offset] = states.port7[0][base + 5 + way_offset];
    hprot_buf[5 + way_offset] = hprots.port7[0][base + 5 + way_offset];
    line_buf[5 + way_offset] = lines.port7[0][base + 5 + way_offset];
    owner_buf[5 + way_offset] = owners.port7[0][base + 5 + way_offset];
    sharers_buf[5 + way_offset] = sharers.port7[0][base + 5 + way_offset];
    dirty_bit_buf[5 + way_offset] = dirty_bits.port7[0][base + 5 + way_offset];

    tag_buf[6 + way_offset] = tags.port8[0][base + 6 + way_offset];
    state_buf[6 + way_offset] = states.port8[0][base + 6 + way_offset];
    hprot_buf[6 + way_offset] = hprots.port8[0][base + 6 + way_offset];
    line_buf[6 + way_offset] = lines.port8[0][base + 6 + way_offset];
    owner_buf[6 + way_offset] = owners.port8[0][base + 6 + way_offset];
    sharers_buf[6 + way_offset] = sharers.port8[0][base + 6 + way_offset];
    dirty_bit_buf[6 + way_offset] = dirty_bits.port8[0][base + 6 + way_offset];

    tag_buf[7 + way_offset] = tags.port9[0][base + 7 + way_offset];
    state_buf[7 + way_offset] = states.port9[0][base + 7 + way_offset];
    hprot_buf[7 + way_offset] = hprots.port9[0][base + 7 + way_offset];
    line_buf[7 + way_offset] = lines.port9[0][base + 7 + way_offset];
    owner_buf[7 + way_offset] = owners.port9[0][base + 7 + way_offset];
    sharers_buf[7 + way_offset] = sharers.port9[0][base + 7 + way_offset];
    dirty_bit_buf[7 + way_offset] = dirty_bits.port9[0][base + 7 + way_offset];

#if (LLC_WAYS >= 16)

    tag_buf[8 + way_offset] = tags.port10[0][base + 8 + way_offset];
    state_buf[8 + way_offset] = states.port10[0][base + 8 + way_offset];
    hprot_buf[8 + way_offset] = hprots.port10[0][base + 8 + way_offset];
    line_buf[8 + way_offset] = lines.port10[0][base + 8 + way_offset];
    owner_buf[8 + way_offset] = owners.port10[0][base + 8 + way_offset];
    sharers_buf[8 + way_offset] = sharers.port10[0][base + 8 + way_offset];
    dirty_bit_buf[8 + way_offset] = dirty_bits.port10[0][base + 8 + way_offset];

    tag_buf[9 + way_offset] = tags.port11[0][base + 9 + way_offset];
    state_buf[9 + way_offset] = states.port11[0][base + 9 + way_offset];
    hprot_buf[9 + way_offset] = hprots.port11[0][base + 9 + way_offset];
    line_buf[9 + way_offset] = lines.port11[0][base + 9 + way_offset];
    owner_buf[9 + way_offset] = owners.port11[0][base + 9 + way_offset];
    sharers_buf[9 + way_offset] = sharers.port11[0][base + 9 + way_offset];
    dirty_bit_buf[9 + way_offset] = dirty_bits.port11[0][base + 9 + way_offset];

    tag_buf[10 + way_offset] = tags.port12[0][base + 10 + way_offset];
    state_buf[10 + way_offset] = states.port12[0][base + 10 + way_offset];
    hprot_buf[10 + way_offset] = hprots.port12[0][base + 10 + way_offset];
    line_buf[10 + way_offset] = lines.port12[0][base + 10 + way_offset];
    owner_buf[10 + way_offset] = owners.port12[0][base + 10 + way_offset];
    sharers_buf[10 + way_offset] = sharers.port12[0][base + 10 + way_offset];
    dirty_bit_buf[10 + way_offset] = dirty_bits.port12[0][base + 10 + way_offset];

    tag_buf[11 + way_offset] = tags.port13[0][base + 11 + way_offset];
    state_buf[11 + way_offset] = states.port13[0][base + 11 + way_offset];
    hprot_buf[11 + way_offset] = hprots.port13[0][base + 11 + way_offset];
    line_buf[11 + way_offset] = lines.port13[0][base + 11 + way_offset];
    owner_buf[11 + way_offset] = owners.port13[0][base + 11 + way_offset];
    sharers_buf[11 + way_offset] = sharers.port13[0][base + 11 + way_offset];
    dirty_bit_buf[11 + way_offset] = dirty_bits.port13[0][base + 11 + way_offset];

    tag_buf[12 + way_offset] = tags.port14[0][base + 12 + way_offset];
    state_buf[12 + way_offset] = states.port14[0][base + 12 + way_offset];
    hprot_buf[12 + way_offset] = hprots.port14[0][base + 12 + way_offset];
    line_buf[12 + way_offset] = lines.port14[0][base + 12 + way_offset];
    owner_buf[12 + way_offset] = owners.port14[0][base + 12 + way_offset];
    sharers_buf[12 + way_offset] = sharers.port14[0][base + 12 + way_offset];
    dirty_bit_buf[12 + way_offset] = dirty_bits.port14[0][base + 12 + way_offset];

    tag_buf[13 + way_offset] = tags.port15[0][base + 13 + way_offset];
    state_buf[13 + way_offset] = states.port15[0][base + 13 + way_offset];
    hprot_buf[13 + way_offset] = hprots.port15[0][base + 13 + way_offset];
    line_buf[13 + way_offset] = lines.port15[0][base + 13 + way_offset];
    owner_buf[13 + way_offset] = owners.port15[0][base + 13 + way_offset];
    sharers_buf[13 + way_offset] = sharers.port15[0][base + 13 + way_offset];
    dirty_bit_buf[13 + way_offset] = dirty_bits.port15[0][base + 13 + way_offset];

    tag_buf[14 + way_offset] = tags.port16[0][base + 14 + way_offset];
    state_buf[14 + way_offset] = states.port16[0][base + 14 + way_offset];
    hprot_buf[14 + way_offset] = hprots.port16[0][base + 14 + way_offset];
    line_buf[14 + way_offset] = lines.port16[0][base + 14 + way_offset];
    owner_buf[14 + way_offset] = owners.port16[0][base + 14 + way_offset];
    sharers_buf[14 + way_offset] = sharers.port16[0][base + 14 + way_offset];
    dirty_bit_buf[14 + way_offset] = dirty_bits.port16[0][base + 14 + way_offset];

    tag_buf[15 + way_offset] = tags.port17[0][base + 15 + way_offset];
    state_buf[15 + way_offset] = states.port17[0][base + 15 + way_offset];
    hprot_buf[15 + way_offset] = hprots.port17[0][base + 15 + way_offset];
    line_buf[15 + way_offset] = lines.port17[0][base + 15 + way_offset];
    owner_buf[15 + way_offset] = owners.port17[0][base + 15 + way_offset];
    sharers_buf[15 + way_offset] = sharers.port17[0][base + 15 + way_offset];
    dirty_bit_buf[15 + way_offset] = dirty_bits.port17[0][base + 15 + way_offset];

#endif
#endif

#ifdef LLC_DEBUG
    evict_way_buf_out = evict_way_buf;
	
    for (int i = 0; i < LLC_WAYS; i++) {
	HLS_UNROLL_LOOP(ON, "buf-output-unroll");
	tag_buf_out[i] = tag_buf[i];
	state_buf_out[i] = state_buf[i];
	hprot_buf_out[i] = hprot_buf[i];
	line_buf_out[i] = line_buf[i];
	sharers_buf_out[i] = sharers_buf[i];
	owner_buf_out[i] = owner_buf[i];
	dirty_bit_buf_out[i] = dirty_bit_buf[i];
    }
#endif
}

void llc::lookup(llc_tag_t tag, llc_set_t set, llc_way_t &way, bool &evict, llc_addr_t &llc_addr)
{
    bool tag_hit = false, empty_way_found = false, evict_valid = false, evict_not_sd = false;
    llc_way_t hit_way = 0, empty_way = 0, evict_way_valid = 0, evict_way_not_sd = 0;

    evict = false;

    const llc_addr_t base = (set << LLC_WAY_BITS);

    for (int i = LLC_WAYS/LLC_LOOKUP_WAYS - 1; i >= 0 ; i--) {
    	read_set(base, i * LLC_LOOKUP_WAYS);
    }

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

    evict_way_buf = evict_ways.port2[0][set];

    for (int i = LLC_WAYS - 1; i >= 0; i--) {
    	HLS_UNROLL_LOOP(ON, "llc-lookup-evict-unroll");

    	llc_way_t way = (llc_way_t) i + evict_way_buf;

    	if (state_buf[way] == VALID) {
    	    evict_valid = true;
    	    evict_way_valid = way;
    	    // break;
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

#ifdef LLC_DEBUG
    tag_hit_out = tag_hit;
    hit_way_out = hit_way;
    empty_way_found_out = empty_way_found;
    empty_way_out = empty_way;
    way_out = way;
    llc_addr_out = llc_addr;
    evict_out = evict;
    evict_valid_out = evict_valid;
    evict_way_not_sd_out = evict_way_not_sd;
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

void llc::process_rsp_in(llc_rsp_in_t rsp_in)
{

    line_breakdown_t<llc_tag_t, llc_set_t> line_br;
    llc_way_t way;
    llc_addr_t llc_addr;
    bool evict;

    line_br.llc_line_breakdown(rsp_in.addr);

    if ((req_stall == true) && (line_br.tag == req_in_stalled_tag)
	&& (line_br.set == req_in_stalled_set)) {
	req_stall = false;
    }

    lookup(line_br.tag, line_br.set, way, evict, llc_addr);

    {
    	HLS_DEFINE_PROTOCOL("llc-rsp-in-after-lookup");
    	wait();
    }

    if (sharers_buf[way] != 0) {
	states.port1[0][llc_addr] = SHARED;
	state_buf[way] = SHARED;
    } else {
	states.port1[0][llc_addr] = VALID;
	state_buf[way] = VALID;
    }

    lines.port1[0][llc_addr] = rsp_in.line;
    line_buf[way] = rsp_in.line;

    dirty_bits.port1[0][llc_addr] = 1;
    dirty_bit_buf[way] = 1;
}

// stall waiting for a RSP_IN to resolve SD state
// serve all other RSP_IN incoming in the meantime
llc_rsp_in_t llc::wait_rsp_in(addr_t addr_evict)
{

    llc_rsp_in_t rsp_in;

    do {
	while (!llc_rsp_in.nb_can_get()) {
	    HLS_DEFINE_PROTOCOL("wait-rsp-in-protocol");
	    wait();
	}

	get_rsp_in(rsp_in);

	if (rsp_in.addr != addr_evict) {

	    process_rsp_in(rsp_in);

	    {
		HLS_DEFINE_PROTOCOL("wait-rsp-in-end-protocol");
		wait();
	    }
	}

    } while (rsp_in.addr != addr_evict);

    return rsp_in;
}
