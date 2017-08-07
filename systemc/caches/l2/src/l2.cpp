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

	// output
	l2_req_out_t	req_out;
	l2_rd_rsp_t	rd_rsp;

	// input address breakdown
	addr_breakdown_t addr_br;

	// tag lookup
	bool		tag_hit;
	l2_way_t	way_hit;
	bool		empty_way_found;
	l2_way_t	empty_way;
	l2_way_t	way_evict;

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
	    NB_GET;

	    is_flush_to_get = false;
	    is_rsp_to_get = false;
	    is_req_to_get = false;

	    if (l2_flush.nb_can_get()) {
		if (reqs_cnt == N_REQS)
		    is_flush_to_get = true;
		else if (l2_rsp_in.nb_can_get())
		    is_rsp_to_get = true;
	    } else if (l2_rsp_in.nb_can_get()) { // inv ack not managed yet
	    	is_rsp_to_get = true;
	    } else if ((l2_cpu_req.nb_can_get() && reqs_cnt != 0 && !evict_stall) || set_conflict) { // assuming READ or WRITE, HPROT cacheable
		is_req_to_get = true;
	    } else {
	     	wait();
	    }
	}

	bookmark_tmp = 0;
	asserts_tmp = 0;
	// custom_dbg_tmp = 0;

	if (is_flush_to_get) {

	    get_flush();

	    wait();

	    put_cnt = 0;

	    for (int s = 0; s < SETS; ++s) {

		{
		    FLUSH_READ_SET;
		    read_set(s);
		}

		for (int w = 0; w < L2_WAYS; ++w) {
		    if (state_buf[w] != INVALID) {
			{
			    FLUSH_LOOP;

			    while (l2_rsp_in.nb_can_get()) {
				get_rsp_in(rsp_in); // it must be a put ack
				put_cnt--;
				wait();
			    }

			    while (!l2_req_out.nb_can_put()){ 
				if (l2_rsp_in.nb_can_get()) {
				    get_rsp_in(rsp_in); // it must be a put ack
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

			    states.port1[0][(s << L2_WAY_BITS) + w] = INVALID;
			    wait();
			}
		    }
		    wait();
		}
	    }

	    {
		FLUSH_END;
		while (put_cnt > 0) {
		    if (l2_rsp_in.nb_can_get()) {
			get_rsp_in(rsp_in); // it must be a put ack
			put_cnt--;
		    }
		    wait();
		}
		flush_done.write(true);
		wait();
		flush_done.write(false);

	    }

	} else if (is_rsp_to_get) { // inv ack not managed yet
	    get_rsp_in(rsp_in);
	    
	    wait(); // for SystemC simulation only

	    addr_br.breakdown(rsp_in.addr);

	    reqs_lookup(addr_br, reqs_hit, reqs_hit_i);

	    switch (rsp_in.coh_msg) {
		
	    case RSP_DATA :
	    case RSP_EDATA :

		switch (reqs[reqs_hit_i].state) {
		
		case ISD :
		    {
			RSP_DATA_ISD;

			// read response
			send_rd_rsp(rsp_in.line);
			
			if (rsp_in.coh_msg == RSP_DATA)
			    state_tmp = SHARED;
			else
			    state_tmp = EXCLUSIVE;
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
		    }

		    break;

		default :
		    RSP_DATA_DEFAULT;
		}

		// resolve unstable state
		reqs[reqs_hit_i].state = INVALID;
		reqs_cnt++;

		put_reqs(addr_br.set, reqs[reqs_hit_i].way, addr_br.tag,
			 rsp_in.line, reqs[reqs_hit_i].hprot, state_tmp);

		break;

	    case RSP_INVACK : // not implemented yet
		RSP_INVACK_DEFAULT;
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
		evict_ways.port1[0][set_tmp] = reqs[reqs_hit_i].way + 1;
		evict_stall = false;

		reqs[reqs_hit_i].state = state_tmp;
		reqs[reqs_hit_i].tag = reqs[reqs_hit_i].tag_estall;

		addr_br.line = (reqs[reqs_hit_i].tag_estall << TAG_RANGE_LO) | 
		    (addr_br.set << SET_RANGE_LO);

		// send request to directory
		send_req_out(coh_msg_tmp, reqs[reqs_hit_i].hprot, addr_br.line, empty_line);

		break;

	    default :
		RSP_DEFAULT;
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
	    custom_dbg.write(set_conflict);

	    if (set_conflict) {
		cpu_req_conflict = cpu_req;
	    }
	    else {

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

		    case WRITE :

			switch (state_buf[way_hit]) {

			case SHARED :
			    {
				HIT_WRITE_S;

				// save request in intermediate state
				fill_reqs(cpu_req.cpu_msg, addr_br, empty_tag, way_hit, cpu_req.hsize, SMAD, cpu_req.hprot,
					  max_invack_cnt, cpu_req.word, lines_buf[way_hit], reqs_i);

				// send request to directory
				send_req_out(REQ_GETM, cpu_req.hprot,
					     addr_br.line, empty_line);
			    }
			    break;

			case EXCLUSIVE : // write hit
			    states.port1[0][(addr_br.set << L2_WAY_BITS) + way_hit] = MODIFIED;
			case MODIFIED : // write hit
			    {
				HIT_WRITE_EM;

				// write word
				write_word(lines_buf[way_hit], cpu_req.word, addr_br.w_off, 
					   addr_br.b_off, cpu_req.hsize);
				lines.port1[0][(addr_br.set << L2_WAY_BITS) + way_hit] = lines_buf[way_hit];
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
			      state_tmp, cpu_req.hprot, max_invack_cnt, cpu_req.word, empty_line, reqs_i);

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
		    fill_reqs(cpu_req.cpu_msg, addr_br, tag_tmp, evict_way, cpu_req.hsize, state_tmp, cpu_req.hprot,
			      max_invack_cnt, cpu_req.word,
			      empty_line, reqs_i);
		}
	    }
	}
	
	// update debug vectors
	asserts.write(asserts_tmp);
	bookmark.write(bookmark_tmp);
	// custom_dbg.write(custom_dbg_tmp);

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
    RESET_IO;

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

    evict_ways.port1.reset();
    evict_ways.port2.reset();

    evict_stall = false;
    set_conflict = false;
    reqs_cnt = N_REQS;
    custom_dbg.write(0);

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
		states.port1[0][(i << L2_WAY_BITS) + j] = INVALID;
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

    read_set(addr_br.set);
    evict_way = evict_ways.port2[0][addr_br.set];

    for (int i = L2_WAYS-1; i >=0; --i) {
	TAG_LOOKUP_LOOP;

	// tag_buf[i]   = tags[uint_set][i];
	// state_buf[i] = states[uint_set][i];
	// hprot_buf[i] = hprots[uint_set][i];
	// lines_buf[i] = lines[uint_set][i];
		
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
    custom_dbg = set_conflict;

    for (unsigned int i = 0; i < N_REQS; ++i) {
	REQS_PEEK_LOOP;
	
	if (reqs[i].state == INVALID) {
	    reqs_i = i;
	}

	if (reqs[i].set == set && reqs[i].state != INVALID) {
	    set_conflict = true;
	    custom_dbg = set_conflict;
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


void l2::read_set(set_t set)
{

    //Manual unroll because these are explicit memories, see commented code 
    // below for implicit memories usage
    sc_uint<SET_BITS+L2_WAY_BITS> base = set << L2_WAY_BITS;

    tag_buf[0]   = tags.port2[0][base + 0];
    state_buf[0] = states.port2[0][base + 0];
    hprot_buf[0] = hprots.port2[0][base + 0];
    lines_buf[0] = lines.port2[0][base + 0];
    tag_buf[1]   = tags.port3[0][base + 1];
    state_buf[1] = states.port3[0][base + 1];
    hprot_buf[1] = hprots.port3[0][base + 1];
    lines_buf[1] = lines.port3[0][base + 1];
    tag_buf[2]   = tags.port4[0][base + 2];
    state_buf[2] = states.port4[0][base + 2];
    hprot_buf[2] = hprots.port4[0][base + 2];
    lines_buf[2] = lines.port4[0][base + 2];
    tag_buf[3]   = tags.port5[0][base + 3];
    state_buf[3] = states.port5[0][base + 3];
    hprot_buf[3] = hprots.port5[0][base + 3];
    lines_buf[3] = lines.port5[0][base + 3];
    tag_buf[4]   = tags.port6[0][base + 4];
    state_buf[4] = states.port6[0][base + 4];
    hprot_buf[4] = hprots.port6[0][base + 4];
    lines_buf[4] = lines.port6[0][base + 4];
    tag_buf[5]   = tags.port7[0][base + 5];
    state_buf[5] = states.port7[0][base + 5];
    hprot_buf[5] = hprots.port7[0][base + 5];
    lines_buf[5] = lines.port7[0][base + 5];
    tag_buf[6]   = tags.port8[0][base + 6];
    state_buf[6] = states.port8[0][base + 6];
    hprot_buf[6] = hprots.port8[0][base + 6];
    lines_buf[6] = lines.port8[0][base + 6];
    tag_buf[7]   = tags.port9[0][base + 7];
    state_buf[7] = states.port9[0][base + 7];
    hprot_buf[7] = hprots.port9[0][base + 7];
    lines_buf[7] = lines.port9[0][base + 7];
}

void l2::fill_reqs(cpu_msg_t cpu_msg, addr_breakdown_t addr_br, tag_t tag_estall, l2_way_t way_hit, hsize_t hsize,
				unstable_state_t state, hprot_t hprot, 
				invack_cnt_t invack_cnt, word_t word, 
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
    reqs[reqs_i].invack_cnt  = invack_cnt;
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
    GET_RSP_IN;

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

    lines.port1[0][base + way]  = line;
    hprots.port1[0][base + way] = hprot;
    states.port1[0][base + way] = state;
    tags.port1[0][base + way]   = tag;

}
