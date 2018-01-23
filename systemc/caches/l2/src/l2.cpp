/* Copyright 2017 Columbia University, SLD Group */

#include "l2.hpp"

/*
 * Processes
 */

void l2::ctrl()
{
    // empty variables
    const invack_cnt_t empty_invack_cnt = 0;
    const invack_cnt_t max_invack_cnt = MAX_INVACK_CNT;
    const word_t empty_word = 0;
    const line_t empty_line = 0;
    const hprot_t empty_hprot = 0;
    const tag_t empty_tag = 0;

    // Reset all signals and channels
    this->reset_io();

    // Reset state memory
    this->reset_states();

    // Main loop
    while(true) {

	// input
	l2_cpu_req_t	cpu_req;
	l2_fwd_in_t	fwd_in;
	l2_rsp_in_t	rsp_in;

	// input address breakdown
	addr_breakdown_t addr_br;

	// tag lookup
	bool		tag_hit;
	l2_way_t	way_hit;
	bool		empty_way_found;
	l2_way_t	empty_way;

	// ongoing trans buffers
	bool			reqs_hit;
	sc_uint<REQS_BITS>	reqs_hit_i;
	sc_uint<REQS_BITS>	reqs_i;

	// transaction select flags
	bool    is_flush_to_get = false;
	bool	is_rsp_to_get	= false;
	bool	is_req_to_get	= false;
    
	// utilities
	uint32_t	put_cnt;

	// tmp
	unstable_state_t	state_tmp;
	addr_t			addr_evict;
	coh_msg_t		coh_msg_tmp;
	tag_t			tag_tmp;
	set_t                   set_tmp;

	{
	    L2_NB_GET;

	    is_flush_to_get = false;
	    is_rsp_to_get = false;
	    is_req_to_get = false;

	    if (l2_flush.nb_can_get()) {
		if (reqs_cnt == N_REQS)
		    is_flush_to_get = true;
		else if (l2_rsp_in.nb_can_get())
		    is_rsp_to_get = true;
	    } else if (l2_rsp_in.nb_can_get()) {
	    	is_rsp_to_get = true;
	    } else if ((l2_cpu_req.nb_can_get() && !evict_stall && 
			(reqs_cnt != 0 || ongoing_atomic)) || 
		       set_conflict) { // assuming HPROT cacheable
		is_req_to_get = true;
	    } else {
	     	wait();
	    }
	}

	bookmark_tmp = 0;
	asserts_tmp = 0;

	if (is_flush_to_get) {

	    get_flush();

	    // for (unsigned int i = 0; i < N_REQS; ++i) {
	    // 	HLS_UNROLL_LOOP(ON, "flush-check");

	    // 	if (reqs[i].state != INVALID)
	    // 	    asserts_tmp |= AS_FLUSH_CHECK;
	    // }

	    wait();

	    put_cnt = 0;

	    for (int s = 0; s < SETS; ++s) {

		{
		    FLUSH_READ_SET;

		    sc_uint<SET_BITS+L2_WAY_BITS> base = s << L2_WAY_BITS;

		    for (int i = L2_WAYS-1; i >=0; --i) {
			HLS_UNROLL_LOOP(ON, "flus-read-loop");

			HLS_BREAK_ARRAY_DEPENDENCY(tags);
			HLS_BREAK_ARRAY_DEPENDENCY(states);
			HLS_BREAK_ARRAY_DEPENDENCY(hprots);
			HLS_BREAK_ARRAY_DEPENDENCY(lines);

			tag_buf[i]   = tags[base + i];
			state_buf[i] = states[base + i];
			hprot_buf[i] = hprots[base + i];
			lines_buf[i] = lines[base + i];
		    }
		}

		for (int w = 0; w < L2_WAYS; ++w) {
		    if (state_buf[w] != INVALID) {
			{
			    FLUSH_LOOP;

			    while (l2_rsp_in.nb_can_get()) {
				get_rsp_in(rsp_in); // it must be a put ack

				// if (rsp_in.coh_msg != RSP_PUTACK)
				//     asserts_tmp |= AS_FLUSH_NOPUTACK;

				put_cnt--;
				wait();
			    }

			    while (!l2_req_out.nb_can_put()){ 
				if (l2_rsp_in.nb_can_get()) {
				    get_rsp_in(rsp_in); // it must be a put ack

				    // if (rsp_in.coh_msg != RSP_PUTACK)
				    // 	asserts_tmp |= AS_FLUSH_NOPUTACK;

				    put_cnt--;
				}
				wait();
			    }

			    addr_br.line = (tag_buf[w] << TAG_RANGE_LO) | (s << SET_RANGE_LO);
			    put_cnt++;

			    if (state_buf[w] == SHARED || state_buf[w] == EXCLUSIVE) {
				send_req_out(REQ_PUTS, empty_hprot, addr_br.line, empty_line);
			    } else {
				send_req_out(REQ_PUTM, empty_hprot, addr_br.line, lines_buf[w]);
			    }

			    states[(s << L2_WAY_BITS) + w] = INVALID;
			    wait();
			}
		    }
		    wait();
		}
	    }

	    {
		FLUSH_END;
		
		// int tmp_flag = 0;

		while (put_cnt > 0) {
		    if (l2_rsp_in.nb_can_get()) {
			get_rsp_in(rsp_in); // it must be a put ack

			// if (rsp_in.coh_msg != RSP_PUTACK)
			//     tmp_flag = 1;

			put_cnt--;
		    }
		    wait();
		}
		flush_done.write(true);
		wait();
		flush_done.write(false);

		// if (tmp_flag == 1)
		//     asserts_tmp |= AS_FLUSH_NOPUTACK;

	    }

	} else if (is_rsp_to_get) {
	    get_rsp_in(rsp_in);
	    
	    wait(); // for SystemC simulation only

	    addr_br.breakdown(rsp_in.addr);

	    reqs_lookup(addr_br, reqs_hit, reqs_hit_i);

	    if (!reqs_hit)
	    	asserts_tmp |= AS_RSP_NOHIT;

	    switch (rsp_in.coh_msg) {
		
	    case RSP_EDATA :
	    {
		RSP_EDATA_ISD;

		// read response
		send_rd_rsp(rsp_in.line);
			
		state_tmp = EXCLUSIVE;

		// resolve unstable state
		reqs[reqs_hit_i].state = INVALID;
		reqs_cnt++;

		put_reqs(addr_br.set, reqs[reqs_hit_i].way, addr_br.tag,
			 rsp_in.line, reqs[reqs_hit_i].hprot, state_tmp);

		break;
	    }

	    case RSP_DATA :

		switch (reqs[reqs_hit_i].state) {
		
		case ISD :
		{
		    RSP_DATA_ISD;
			
		    // read response
		    send_rd_rsp(rsp_in.line);
			
		    state_tmp = SHARED;

		    // resolve unstable state
		    reqs[reqs_hit_i].state = INVALID;
		    reqs_cnt++;

		    put_reqs(addr_br.set, reqs[reqs_hit_i].way, addr_br.tag,
			     rsp_in.line, reqs[reqs_hit_i].hprot, state_tmp);
		}

		break;

		case IMAD :
		case SMAD :
		{
		    RSP_DATA_XMAD;

		    // write word and resolve unstable state
		    write_word(rsp_in.line, reqs[reqs_hit_i].word, reqs[reqs_hit_i].w_off, 
			       reqs[reqs_hit_i].b_off, reqs[reqs_hit_i].hsize);

		    state_tmp = MODIFIED;

		    put_reqs(addr_br.set, reqs[reqs_hit_i].way, addr_br.tag,
			     rsp_in.line, reqs[reqs_hit_i].hprot, state_tmp);

		    // update invack_cnt
		    reqs[reqs_hit_i].invack_cnt += rsp_in.invack_cnt;

		    if (reqs[reqs_hit_i].invack_cnt == N_CPU) {
			// resolve unstable state
			reqs[reqs_hit_i].state = INVALID;
			reqs_cnt++;
		    } else {
			// update unstable state (+=2 is an optimization)
			reqs[reqs_hit_i].state += 2;
		    }
		}

		break;

		case IMADW :
		case SMADW :
		{
		    RSP_DATA_XMADW;

		    // read response
		    send_rd_rsp(rsp_in.line);

		    reqs[reqs_hit_i].line = rsp_in.line;

		    // update invack_cnt
		    reqs[reqs_hit_i].invack_cnt += rsp_in.invack_cnt;

		    if (reqs[reqs_hit_i].invack_cnt == N_CPU) {
			// update unstable state
			reqs[reqs_hit_i].state = XMW;
		    } else {
			// update unstable state (+=2 is an optimization)
			reqs[reqs_hit_i].state += 2;
		    }
		}

		break;

		default :
		    RSP_DATA_DEFAULT;
		}

		break;

	    case RSP_INVACK : // not implemented yet
	    {
		RSP_INVACK_ALL;

		reqs[reqs_hit_i].invack_cnt--;

		if (reqs[reqs_hit_i].invack_cnt == N_CPU) {

		    switch (reqs[reqs_hit_i].state) {
		
		    case IMA :
		    case SMA :
		    {
			reqs[reqs_hit_i].state = INVALID;
			reqs_cnt++;
		    }
		    break;

		    case IMAW :
		    case SMAW :
		    {
			reqs[reqs_hit_i].state = XMW;
		    }
		    break;

		    default :
			INVACK_DEFAULT;
		    }
		}
	    }
	    break;

	    case RSP_PUTACK :

		switch (reqs[reqs_hit_i].cpu_msg) {

		case READ : 
		    state_tmp = ISD;
		    coh_msg_tmp = REQ_GETS;
		    break;

		case WRITE :
		    state_tmp = IMAD;
		    coh_msg_tmp = REQ_GETM;
		    break;

		default :
		    PUTACK_DEFAULT;
		}

		set_tmp = reqs[reqs_hit_i].set;
		evict_ways[set_tmp] = reqs[reqs_hit_i].way + 1;
		evict_stall = false;

		reqs[reqs_hit_i].state = state_tmp;
		reqs[reqs_hit_i].tag = reqs[reqs_hit_i].tag_estall;

		addr_br.line = (reqs[reqs_hit_i].tag_estall << TAG_RANGE_LO) | 
		    (addr_br.set << SET_RANGE_LO);

		// send request to directory
		send_req_out(coh_msg_tmp, reqs[reqs_hit_i].hprot, addr_br.line, empty_line);

		break;
	    }

	} else if (is_req_to_get) { // assuming READ or WRITE, HPROT cacheable

 	    if (!set_conflict) {
		get_cpu_req(cpu_req);
	    } else {
		cpu_req = cpu_req_conflict;
	    }

	    wait(); // for SystemC simulation only

	    addr_br.breakdown(cpu_req.addr);

	    set_conflict = reqs_peek(addr_br.set, reqs_i);

	    if (ongoing_atomic) {

		if (atomic_line_addr != addr_br.line) {

		    put_reqs(reqs[reqs_atomic_i].set, reqs[reqs_atomic_i].way, reqs[reqs_atomic_i].tag,
			     reqs[reqs_atomic_i].line, reqs[reqs_atomic_i].hprot, MODIFIED);

		    ongoing_atomic = false;

		    reqs_i = reqs_atomic_i;

		} else {

		    set_conflict = false;

		    switch (cpu_req.cpu_msg) {

		    case READ :

			send_rd_rsp(reqs[reqs_atomic_i].line);

			put_reqs(reqs[reqs_atomic_i].set, reqs[reqs_atomic_i].way, reqs[reqs_atomic_i].tag,
				 reqs[reqs_atomic_i].line, reqs[reqs_atomic_i].hprot, MODIFIED);

			ongoing_atomic = false;

			break;

		    case READ_ATOM :

			send_rd_rsp(reqs[reqs_atomic_i].line);
			
			break;

		    case WRITE :
		    case WRITE_ATOM :

			write_word(reqs[reqs_atomic_i], cpu_req.word, addr_br.w_off, 
				   addr_br.b_off, cpu_req.hsize);

			put_reqs(reqs[reqs_atomic_i].set, reqs[reqs_atomic_i].way, reqs[reqs_atomic_i].tag,
				 reqs[reqs_atomic_i].line, reqs[reqs_atomic_i].hprot, MODIFIED);

			ongoing_atomic = false;

			break;
		    }

		    continue;
		}
	    }

	    if (set_conflict) {

		cpu_req_conflict = cpu_req;

	    } else {

		tag_lookup(addr_br, tag_hit, way_hit, 
			   empty_way_found, empty_way);

		if (tag_hit) {

		    switch (cpu_req.cpu_msg) {
		    
		    case READ : // read hit
		    {
			HIT_READ;

			// read response
			send_rd_rsp(lines_buf[way_hit]);
		    }
		    break;

		    case READ_ATOMIC : // read atomic hit

			ongoing_atomic = true;
			reqs_atomic_i = reqs_i;
			atomic_line_addr = addr_br.line;

			switch (state_buf[way_hit]) {

			case SHARED :
			{
			    HIT_READ_ATOMIC_S;

			    // save request in intermediate state
			    fill_reqs(cpu_req.cpu_msg, addr_br, empty_tag, way_hit, cpu_req.hsize, SMADW, 
				      cpu_req.hprot, cpu_req.word, lines_buf[way_hit], reqs_i);

			    // send request to directory
			    send_req_out(REQ_GETM, cpu_req.hprot,
					 addr_br.line, empty_line);
			}
			break;

			case EXCLUSIVE : // write hit
			case MODIFIED : // write hit
			{
			    HIT_READ_ATOMIC_EM;

			    // save request in intermediate state
			    fill_reqs(cpu_req.cpu_msg, addr_br, empty_tag, way_hit, cpu_req.hsize, XMW, 
				      cpu_req.hprot, cpu_req.word, lines_buf[way_hit], reqs_i);

                            // read response 
			    send_rd_rsp(lines_buf[way_hit]);
			}
			break;

			default:
			    HIT_WRITE_DEFAULT;
			}

		    break;

		    case WRITE :

			switch (state_buf[way_hit]) {

			case SHARED :
			{
			    HIT_WRITE_S;

			    // save request in intermediate state
			    fill_reqs(cpu_req.cpu_msg, addr_br, empty_tag, way_hit, cpu_req.hsize, SMAD, cpu_req.hprot,
				      cpu_req.word, lines_buf[way_hit], reqs_i);

			    // send request to directory
			    send_req_out(REQ_GETM, cpu_req.hprot,
					 addr_br.line, empty_line);
			}
			break;

			case EXCLUSIVE : // write hit
			    states[(addr_br.set << L2_WAY_BITS) + way_hit] = MODIFIED;
			case MODIFIED : // write hit
			{
			    HIT_WRITE_EM;

			    // write word
			    write_word(lines_buf[way_hit], cpu_req.word, addr_br.w_off, 
				       addr_br.b_off, cpu_req.hsize);
			    lines[(addr_br.set << L2_WAY_BITS) + way_hit] = lines_buf[way_hit];
			}
			break;

			default:
			    HIT_WRITE_DEFAULT;
			}
			break;

		    default:
			HIT_DEFAULT;
		    }

		} else if (empty_way_found) {

		    switch (cpu_req.cpu_msg) {
		    
		    case READ :
		    {
			MISS_READ;

			state_tmp = ISD;
			coh_msg_tmp = REQ_GETS;

		    }
		    break;

		    case WRITE :
		    {
			MISS_WRITE;

			state_tmp = IMAD;
			coh_msg_tmp = REQ_GETM;

		    }
		    break;

		    default:
			MISS_DEFAULT;
		    }

		    // save request in intermediate state
		    fill_reqs(cpu_req.cpu_msg, addr_br, empty_tag, empty_way, cpu_req.hsize, 
			      state_tmp, cpu_req.hprot, cpu_req.word, empty_line, reqs_i);

		    // send request to directory
		    send_req_out(coh_msg_tmp, cpu_req.hprot, addr_br.line, empty_line);

		} else {

		    evict_stall = true;

		    addr_evict = (tag_buf[evict_way] << TAG_RANGE_LO) | (addr_br.set << SET_RANGE_LO);
		    tag_tmp = addr_br.tag;
		    addr_br.tag = tag_buf[evict_way];
		
		    switch (state_buf[evict_way]) {

		    case SHARED :
			coh_msg_tmp = REQ_PUTS;
			state_tmp = SIA;
			break;

		    case EXCLUSIVE :
			coh_msg_tmp = REQ_PUTS;
			state_tmp = MIA;
			break;

		    case MODIFIED :
			coh_msg_tmp = REQ_PUTM;
			state_tmp = MIA;
			break;

		    default :
			EVICT_DEFAULT;
		    }

		    send_inval(addr_evict);
		    send_req_out(coh_msg_tmp, empty_hprot, addr_evict, lines_buf[evict_way]);
		    fill_reqs(cpu_req.cpu_msg, addr_br, tag_tmp, evict_way, cpu_req.hsize, state_tmp, 
			      cpu_req.hprot, cpu_req.word, empty_line, reqs_i);
		}
	    }
	}
	
	// // update debug vectors
	// // {
	// //     HLS_DEFINE_PROTOCOL("debug-outputs");
	asserts.write(asserts_tmp);
	bookmark.write(bookmark_tmp);
	//     evict_stall_out.write(evict_stall);
	//     set_conflict_out.write(set_conflict);
	//     cpu_req_conflict_out.write(cpu_req_conflict);
	//     reqs_cnt_out.write(reqs_cnt);
	//     tag_hit_out.write(tag_hit);
	//     way_hit_out.write(way_hit);
	//     empty_way_found_out.write(empty_way_found);
	//     empty_way_out.write(empty_way);
	//     way_evict_out.write(evict_way);
	//     reqs_hit_out.write(reqs_hit);
	//     reqs_hit_i_out.write(reqs_hit_i);

	//     for (int i = 0; i < N_REQS; i++) {
	//     	REQS_OUTPUT;
	//     	reqs_out[i] = reqs[i];
	//     }
	// //     wait();
	// // }
    }

    /* 
     * End of main loop
     */

}

/*
 * Functions
 */

inline void l2::reset_io()
{
    L2_RESET_IO;

    l2_cpu_req.reset_get();
    l2_fwd_in.reset_get();
    l2_rsp_in.reset_get();
    l2_flush.reset_get();
    l2_rd_rsp.reset_put();
    l2_inval.reset_put();
    l2_req_out.reset_put();
    l2_rsp_out.reset_put();

    asserts.write(0);
    bookmark.write(0);

    evict_stall = false;
    set_conflict = false;
    reqs_cnt = N_REQS;
    // custom_dbg.write(0);
    // evict_stall_out.write(0);
    // set_conflict_out.write(0);
    // reqs_cnt_out = N_REQS;
    // tag_hit_out.write(0);
    // way_hit_out.write(0);
    // empty_way_found_out.write(0);
    // empty_way_out.write(0);
    // way_evict_out.write(0);
    // reqs_hit_out.write(0);
    // reqs_hit_i_out.write(0);
    ongoing_atomic = false;

    flush_done.write(0);

    wait();
}

inline void l2::reset_states()
{
    RESET_STATES;

    for (int i=0; i<SETS; i++) { // do not unroll
	for (int j=0; j<L2_WAYS; j++) { // do not unroll
	    {
		RESET_STATES_LOOP;
		states[(i << L2_WAY_BITS) + j] = INVALID;
		wait();
	    }
	}
    }
}

void l2::tag_lookup(addr_breakdown_t addr_br, bool &tag_hit,
		    l2_way_t &way_hit, bool &empty_way_found, 
		    l2_way_t &empty_way)
{
    TAG_LOOKUP;

    tag_hit = false;
    empty_way_found = false;

    sc_uint<SET_BITS+L2_WAY_BITS> base = addr_br.set << L2_WAY_BITS;

    evict_way = evict_ways[addr_br.set];

    for (int i = L2_WAYS-1; i >=0; --i) {
	TAG_LOOKUP_LOOP;

	HLS_BREAK_ARRAY_DEPENDENCY(tags);
	HLS_BREAK_ARRAY_DEPENDENCY(states);
	HLS_BREAK_ARRAY_DEPENDENCY(hprots);
	HLS_BREAK_ARRAY_DEPENDENCY(lines);

	tag_buf[i]   = tags[base + i];
	state_buf[i] = states[base + i];
	hprot_buf[i] = hprots[base + i];
	lines_buf[i] = lines[base + i];
		
	if (tag_buf[i] == addr_br.tag && state_buf[i] != INVALID) {
	    tag_hit = true;
	    way_hit = i;
	}

	if (state_buf[i] == INVALID) {
	    empty_way_found = true;
	    empty_way = i;
	}
    }
}


bool l2::reqs_peek(set_t set, sc_uint<REQS_BITS> &reqs_i)
{
    REQS_PEEK;

    set_conflict = false;

    for (unsigned int i = 0; i < N_REQS; ++i) {
	REQS_PEEK_LOOP;
	
	if (reqs[i].state == INVALID) {
	    reqs_i = i;
	}

	if (reqs[i].set == set && reqs[i].state !=    INVALID) {
	    set_conflict = true;
	}
    }

    return set_conflict;
}

void l2::reqs_lookup(addr_breakdown_t addr_br, bool &reqs_hit, sc_uint<REQS_BITS> &reqs_hit_i)
{
    REQS_LOOKUP;

    reqs_hit = false;

    for (unsigned int i = 0; i < N_REQS; ++i) {
	REQS_LOOKUP_LOOP;
	
	if (reqs[i].tag == addr_br.tag && reqs[i].set == addr_br.set && reqs[i].state != INVALID) {
	    reqs_hit = true;
	    reqs_hit_i = i;
	}
    }

    REQS_LOOKUP_ASSERT;
}

void l2::fill_reqs(cpu_msg_t cpu_msg, addr_breakdown_t addr_br, tag_t tag_estall, l2_way_t way_hit, hsize_t hsize,
		   unstable_state_t state, hprot_t hprot, word_t word, 
		   line_t line, sc_uint<REQS_BITS> reqs_i)
{
    reqs[reqs_i].cpu_msg     = cpu_msg;
    reqs[reqs_i].tag	     = addr_br.tag;
    reqs[reqs_i].tag_estall  = tag_estall;
    reqs[reqs_i].set	     = addr_br.set;
    reqs[reqs_i].way	     = way_hit;
    reqs[reqs_i].hsize	     = hsize;
    reqs[reqs_i].w_off       = addr_br.w_off;
    reqs[reqs_i].b_off       = addr_br.b_off;
    reqs[reqs_i].state	     = state;
    reqs[reqs_i].hprot	     = hprot;
    reqs[reqs_i].invack_cnt  = N_CPU;
    reqs[reqs_i].word	     = word;
    reqs[reqs_i].line	     = line;

    reqs_cnt--;
}

void l2::get_cpu_req(l2_cpu_req_t &cpu_req)
{
    GET_CPU_REQ;

    l2_cpu_req.nb_get(cpu_req);
}

void l2::get_rsp_in(l2_rsp_in_t &rsp_in)
{
    L2_GET_RSP_IN;

    l2_rsp_in.nb_get(rsp_in); // invack_cnt not handled yet
}

void l2::get_flush()
{
    GET_FLUSH;
    
    bool flush_tmp;
    l2_flush.nb_get(flush_tmp);
}

void l2::send_req_out(coh_msg_t coh_msg, hprot_t hprot, 
		      addr_t line_addr, line_t line)
{
    SEND_REQ_OUT;

    l2_req_out_t req_out;

    req_out.coh_msg = coh_msg;
    req_out.hprot = hprot;
    req_out.addr = line_addr;
    req_out.line = line;

    while (!l2_req_out.nb_can_put()) wait();
    
    l2_req_out.nb_put(req_out);
}

void l2::send_rd_rsp(line_t line)
{
    SEND_RD_RSP;

    l2_rd_rsp_t rd_rsp;

    rd_rsp.line = line;
    
    l2_rd_rsp.put(rd_rsp);
}

void l2::send_inval(addr_t addr_inval)
{
    SEND_INVAL;

    l2_inval.put(addr_inval);
}

void l2::put_reqs(set_t set, l2_way_t way, tag_t tag,
		  line_t line, hprot_t hprot, state_t state)
{
    PUT_REQS;

    sc_uint<SET_BITS+L2_WAY_BITS> base = set << L2_WAY_BITS;

    lines[base + way]  = line;
    hprots[base + way] = hprot;
    states[base + way] = state;
    tags[base + way]   = tag;
}
