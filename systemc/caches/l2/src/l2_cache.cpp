/* Copyright 2017 Columbia University, SLD Group */

#include "l2_cache.hpp"

/*
 * Processes
 */

void l2_cache::ctrl()
{
    /*
     * Constant variables
     */

    // empty
    const invack_cnt_t empty_invack_cnt = 0;
    const invack_cnt_t max_invack_cnt = MAX_INVACK_CNT;
    const word_t empty_word = 0;
    const line_t empty_line = 0;
    const hprot_t empty_hprot = 0;

    /*
     * End of constant variables
     */


    /*
     * Reset
     */

    // Reset all signals and channels
    this->reset_io();

    // Reset state memory
    this->reset_states();

    /*
     * End of reset
     */


    while(true) {
	/*
	 * Local variables
	 */

	// input
	l2_cpu_req_t	cpu_req;
	l2_fwd_in_t	fwd_in;
	l2_rsp_in_t	rsp_in;

	// output
	l2_req_out_t req_out;
	l2_rd_rsp_t rd_rsp;
	l2_wr_rsp_t wr_rsp;

	// input address breakdown
	addr_breakdown_t	addr_br;

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
	bool	is_rsp_to_get = false;
	bool	is_evict_done = false;
	bool	is_req_to_get = false;
    
	// others
	state_t state;
	unstable_state_t unstable_state;
	line_t line;
	tag_t tag;
	uint32_t put_cnt;
	
	/*
	 * End of local variables
	 */


	{
	    NB_GET;

	    is_flush_to_get = false;
	    is_rsp_to_get = false;
	    is_evict_done = false;
	    is_req_to_get = false;

	    if (l2_flush.nb_can_get()) {
		is_flush_to_get = true;
	    } else if (l2_rsp_in.nb_can_get()) { // put ack and inv ack not managed yet
	    	is_rsp_to_get = true;
	    } else if (evict_done) {
		is_evict_done = true;
	    } else if (l2_cpu_req.nb_can_get()) { // assuming READ or WRITE, HPROT cacheable
		is_req_to_get = true;
	    } else {
	     	wait();
	    }
	}

	bookmark_tmp = 0;
	asserts_tmp = 0;

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

			    while (!l2_req_out.nb_can_put()) {
				if (l2_rsp_in.nb_can_get()) {
				    get_rsp_in(rsp_in); // it must be a put ack
				    --put_cnt;
				}
				wait();
			    }

			    addr_br.line = (tag_buf[w] << TAG_RANGE_LO) | (s << SET_RANGE_LO);
			    ++put_cnt;

			    if (state_buf[w] == SHARED) {
				send_req_out(REQ_PUTS, empty_hprot, addr_br.line, empty_line);
			    } else {
				send_req_out(REQ_PUTM, empty_hprot, addr_br.line, lines_buf[w]);
			    }

			    states.port1[0][(s << L2_WAY_BITS) + w] = INVALID;
			    wait();
			}
		    }
		}
	    }

	    while (put_cnt) {
		FLUSH_END;

		if (l2_rsp_in.nb_can_get()) {
		    get_rsp_in(rsp_in); // it must be a put ack
		    --put_cnt;
		}
		wait();
	    }

	} else if (is_rsp_to_get) { // put ack and inv ack not managed yet
	    get_rsp_in(rsp_in);
	    
	    wait(); // for SystemC simulation only

	    addr_breakdown(rsp_in.addr, addr_br);

	    reqs_lookup(addr_br, reqs_hit, reqs_hit_i);

	    // evicts_lookup(addr_br, evicts_hit, evicts_hit_i);

	    switch (rsp_in.coh_msg) {
		
	    case RSP_DATA :

		switch (reqs[reqs_hit_i].state) {
		
		case ISD :
		    {
			RSP_DATA_ISD;

			// read response
			send_rd_rsp(rsp_in.line);

			// resolve unstable state
			reqs[reqs_hit_i].state = INVALID;
			put_reqs(addr_br.set, reqs[reqs_hit_i].way, addr_br.tag,
				 rsp_in.line, reqs[reqs_hit_i].hprot, SHARED);
		    }
		    break;

		case IMAD :
		case SMAD :
		    {
			RSP_DATA_XMAD;

			// write response
			send_wr_rsp(reqs[reqs_hit_i].set);

			// write word and resolve unstable state
			write_word(rsp_in.line, reqs[reqs_hit_i].word, reqs[reqs_hit_i].w_off, 
				   reqs[reqs_hit_i].b_off, reqs[reqs_hit_i].hsize);
			reqs[reqs_hit_i].state = INVALID;
			put_reqs(addr_br.set, reqs[reqs_hit_i].way, addr_br.tag, 
				 rsp_in.line, reqs[reqs_hit_i].hprot, MODIFIED);
		    }

		    break;

		default :
		    RSP_DATA_DEFAULT;
		}

		break;

	    case RSP_EDATA :
		{
		    RSP_EDATA_ALL;

		    // read response
		    send_rd_rsp(rsp_in.line);

		    // resolve unstable state
		    reqs[reqs_hit_i].state = INVALID;
		    put_reqs(addr_br.set, reqs[reqs_hit_i].way, addr_br.tag,
			     rsp_in.line, reqs[reqs_hit_i].hprot, EXCLUSIVE);
		}
		break;

	    case RSP_INVACK : // not implemented yet
		break;

	    default :
		RSP_DEFAULT;
	    }

	} else if (is_req_to_get || is_evict_done) { // assuming READ or WRITE, HPROT cacheable

	    // if (is_evict_done) {
	    // 	cpu_req = estall_cpu_req;
	    // 	is_evict_done = false;
	    // } else {
		get_cpu_req(cpu_req);
	    // }

	    wait(); // for SystemC simulation only

	    addr_breakdown(cpu_req.addr, addr_br);

	    tag_lookup(addr_br, tag_hit, way_hit, 
		       empty_way_found, empty_way, reqs_i);

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
			    fill_reqs(addr_br, way_hit, cpu_req.hsize, SMAD, cpu_req.hprot,
				      max_invack_cnt, cpu_req.word,
				      lines_buf[way_hit], reqs_i);

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

			    // write response
			    send_wr_rsp(addr_br.set);

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

			// save request in intermediate state
			fill_reqs(addr_br, empty_way, cpu_req.hsize, ISD, cpu_req.hprot,
				  max_invack_cnt, empty_word, empty_line, reqs_i);

			// send request to directory
			send_req_out(REQ_GETS, cpu_req.hprot, 
				     addr_br.line, empty_line);
		    }
		    break;

		case WRITE :
		    {
			MISS_WRITE;

			// save request in intermediate state
			fill_reqs(addr_br, empty_way, cpu_req.hsize, IMAD, cpu_req.hprot,
				  max_invack_cnt, cpu_req.word, empty_line, reqs_i);

			// send request to directory
			send_req_out(REQ_GETM, cpu_req.hprot,
				     addr_br.line, empty_line);
		    }
		    break;
		    
		default:
		    MISS_DEFAULT;
		}

	    } else {
		EVICT_DEFAULT;
		// TODO implement eviction
	    }
	}
	
	// update debug vectors
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

inline void l2_cache::reset_io()
{
    RESET_IO;

    l2_cpu_req.reset_get();
    l2_fwd_in.reset_get();
    l2_rsp_in.reset_get();
    l2_flush.reset_get();
    l2_rd_rsp.reset_put();
    l2_wr_rsp.reset_put();
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

    evict_done = 0;
    
    wait();
}

inline void l2_cache::reset_states()
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

void l2_cache::addr_breakdown(addr_t addr, addr_breakdown_t &addr_br)
{
    addr_br.line = addr;
    addr_br.line.range(OFF_RANGE_HI, OFF_RANGE_LO) = 0;
    addr_br.tag	  = addr.range(TAG_RANGE_HI, TAG_RANGE_LO);
    addr_br.set	  = addr.range(SET_RANGE_HI, SET_RANGE_LO);
    addr_br.off	  = addr.range(OFF_RANGE_HI, OFF_RANGE_LO);
    addr_br.w_off = addr.range(W_OFF_RANGE_HI, W_OFF_RANGE_LO);
    addr_br.b_off = addr.range(B_OFF_RANGE_HI, B_OFF_RANGE_LO);
}

void l2_cache::tag_lookup(addr_breakdown_t addr_br, bool &tag_hit,
			  l2_way_t &way_hit, bool &empty_way_found, 
			  l2_way_t &empty_way, sc_uint<REQS_BITS> &reqs_i)
{
    TAG_LOOKUP;

    tag_hit = false;
    empty_way_found = false;

    read_set(addr_br.set);
    evict_way = evict_ways.port2[0][addr_br.set];

    for (unsigned int i = 0; i < L2_WAYS; ++i) {
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

    for (unsigned int i = 0; i < N_REQS; ++i) {
	REQS_LOOKUP_SPACE;
	
	if (reqs[i].state == INVALID) {
	    reqs_i = i;
	}
    }
}

void l2_cache::read_set(set_t set)
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

void l2_cache::reqs_lookup(addr_breakdown_t addr_br, bool &reqs_hit, sc_uint<REQS_BITS> &reqs_hit_i)
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
}

void l2_cache::fill_reqs(addr_breakdown_t addr_br, l2_way_t way_hit, hsize_t hsize,
				unstable_state_t state, hprot_t hprot, 
				invack_cnt_t invack_cnt, word_t word, 
				line_t line, sc_uint<REQS_BITS> reqs_i)
{
    reqs[reqs_i].tag	     = addr_br.tag;
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
}

void l2_cache::fill_evicts(addr_breakdown_t addr_br, evict_state_t state, l2_way_t way, sc_uint<EVICTS_BITS> evicts_i)
{
    evicts[evicts_i].tag	     = addr_br.tag;
    evicts[evicts_i].set	     = addr_br.set;
    evicts[evicts_i].way	     = way;
    evicts[evicts_i].state	     = state;
}


void l2_cache::get_cpu_req(l2_cpu_req_t &cpu_req)
{
    GET_CPU_REQ;

    l2_cpu_req.nb_get(cpu_req);
}

void l2_cache::get_rsp_in(l2_rsp_in_t &rsp_in)
{
    GET_RSP_IN;

    l2_rsp_in.nb_get(rsp_in); // invack_cnt not handled yet
}

void l2_cache::get_flush()
{
    GET_FLUSH;
    
    bool flush_tmp;
    l2_flush.nb_get(flush_tmp);
}

void l2_cache::send_req_out(coh_msg_t coh_msg, hprot_t hprot, 
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

void l2_cache::send_rd_rsp(line_t line)
{
    SEND_RD_RSP;

    l2_rd_rsp_t rd_rsp;

    rd_rsp.line = line;
    
    l2_rd_rsp.put(rd_rsp);
}

void l2_cache::send_wr_rsp(set_t set)
{
    SEND_WR_RSP;

    l2_wr_rsp_t wr_rsp;

    wr_rsp.set = set;
    
    l2_wr_rsp.put(wr_rsp);
}

void l2_cache::put_reqs(set_t set, l2_way_t way, tag_t tag,
			       line_t line, hprot_t hprot, state_t state)
{
    PUT_REQS;

    sc_uint<SET_BITS+L2_WAY_BITS> base = set << L2_WAY_BITS;

    lines.port1[0][base + way]  = line;
    hprots.port1[0][base + way] = hprot;
    states.port1[0][base + way] = state;
    tags.port1[0][base + way]   = tag;
}
