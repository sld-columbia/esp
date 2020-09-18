// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "llc.hpp"


inline void llc::reset_io()
{

    // Reset put-get channels
    llc_req_in.reset_get();
    llc_dma_req_in.reset_get();
    llc_rsp_in.reset_get();
    llc_mem_rsp.reset_get();
    llc_rst_tb.reset_get();
    llc_rsp_out.reset_put();
    llc_dma_rsp_out.reset_put();
    llc_fwd_out.reset_put();
    llc_mem_req.reset_put();
    llc_rst_tb_done.reset_put();
#ifdef STATS_ENABLE
    llc_stats.reset_put();
#endif

    evict_ways_buf = 0;

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

    wait();
}

inline void llc::reset_state()
{
    rst_stall = true;
    flush_stall = false;
    rst_flush_stalled_set = 0;
    req_stall = false;
    req_in_stalled_valid = false;
    req_in_stalled_tag = 0;
    req_in_stalled_set = 0;
    dma_read_pending = false;
    dma_write_pending = false;
    dma_addr = 0;
    dma_read_length = 0;
    dma_length = 0;
    dma_done = false;
    dma_start = false;
    recall_pending = false;
    recall_valid = false;


    for (int i = 0; i < LLC_WAYS; i++) {
	HLS_UNROLL_LOOP(ON, "reset-bufs");

	tags_buf[i] = 0;
	states_buf[i] = 0;
	lines_buf[i] = 0;
	sharers_buf[i] = 0;
	owners_buf[i] = 0;
	dirty_bits_buf[i] = 0;
	hprots_buf[i] = 0;
    }


#ifdef LLC_DEBUG
    dbg_asserts.write(0);
    dbg_bookmark.write(0);

    dbg_is_rst_to_get.write(0);
    dbg_is_rsp_to_get.write(0);
    dbg_is_req_to_get.write(0);

    dbg_tag_hit.write(0);
    dbg_hit_way.write(0);
    dbg_empty_way_found.write(0);
    dbg_empty_way.write(0);
    dbg_way.write(0);
    dbg_llc_addr.write(0);
    dbg_evict.write(0);
    dbg_evict_valid.write(0);
    dbg_evict_way_not_sd.write(0);
    dbg_evict_addr.write(0);
    dbg_flush_set.write(0);
    dbg_flush_way.write(0);

    dbg_req_stall.write(0);
    dbg_req_in_stalled_valid.write(0);
    dbg_req_in_stalled_tag.write(0);
    dbg_req_in_stalled_set.write(0);

    dbg_length.write(0);
    dbg_dma_length.write(0);
    dbg_dma_done.write(0);
    dbg_dma_addr.write(0);
#endif

    wait();
}


inline void llc::read_set(const llc_addr_t base, const llc_way_t way_offset)
{
// #if LLC_WAYS == 32
//     for (int i = 0; i < LLC_LOOKUP_WAYS; i++) {
// #else
//     for (int i = 0; i < LLC_WAYS; i++) {
// #endif
//         HLS_UNROLL_LOOP(ON);

//         tags_buf[i + way_offset]       = tags[base + i + way_offset];
//         states_buf[i + way_offset]     = states[base + i + way_offset];
//         hprots_buf[i + way_offset]     = hprots[base + i + way_offset];
//         lines_buf[i + way_offset]      = lines[base + i + way_offset];
//         owners_buf[i + way_offset]     = owners[base + i + way_offset];
//         sharers_buf[i + way_offset]   = sharers[base + i + way_offset];
//         dirty_bits_buf[i + way_offset] = dirty_bits[base + i + way_offset];
//     }

    tags_buf[0 + way_offset] = tags.port2[0][base + 0 + way_offset];
    states_buf[0 + way_offset] = states.port2[0][base + 0 + way_offset];
    hprots_buf[0 + way_offset] = hprots.port2[0][base + 0 + way_offset];
    lines_buf[0 + way_offset] = lines.port2[0][base + 0 + way_offset];
    owners_buf[0 + way_offset] = owners.port2[0][base + 0 + way_offset];
    sharers_buf[0 + way_offset] = sharers.port2[0][base + 0 + way_offset];
    dirty_bits_buf[0 + way_offset] = dirty_bits.port2[0][base + 0 + way_offset];

    tags_buf[1 + way_offset] = tags.port3[0][base + 1 + way_offset];
    states_buf[1 + way_offset] = states.port3[0][base + 1 + way_offset];
    hprots_buf[1 + way_offset] = hprots.port3[0][base + 1 + way_offset];
    lines_buf[1 + way_offset] = lines.port3[0][base + 1 + way_offset];
    owners_buf[1 + way_offset] = owners.port3[0][base + 1 + way_offset];
    sharers_buf[1 + way_offset] = sharers.port3[0][base + 1 + way_offset];
    dirty_bits_buf[1 + way_offset] = dirty_bits.port3[0][base + 1 + way_offset];

    tags_buf[2 + way_offset] = tags.port4[0][base + 2 + way_offset];
    states_buf[2 + way_offset] = states.port4[0][base + 2 + way_offset];
    hprots_buf[2 + way_offset] = hprots.port4[0][base + 2 + way_offset];
    lines_buf[2 + way_offset] = lines.port4[0][base + 2 + way_offset];
    owners_buf[2 + way_offset] = owners.port4[0][base + 2 + way_offset];
    sharers_buf[2 + way_offset] = sharers.port4[0][base + 2 + way_offset];
    dirty_bits_buf[2 + way_offset] = dirty_bits.port4[0][base + 2 + way_offset];

    tags_buf[3 + way_offset] = tags.port5[0][base + 3 + way_offset];
    states_buf[3 + way_offset] = states.port5[0][base + 3 + way_offset];
    hprots_buf[3 + way_offset] = hprots.port5[0][base + 3 + way_offset];
    lines_buf[3 + way_offset] = lines.port5[0][base + 3 + way_offset];
    owners_buf[3 + way_offset] = owners.port5[0][base + 3 + way_offset];
    sharers_buf[3 + way_offset] = sharers.port5[0][base + 3 + way_offset];
    dirty_bits_buf[3 + way_offset] = dirty_bits.port5[0][base + 3 + way_offset];

#if (LLC_WAYS >= 8)

    tags_buf[4 + way_offset] = tags.port6[0][base + 4 + way_offset];
    states_buf[4 + way_offset] = states.port6[0][base + 4 + way_offset];
    hprots_buf[4 + way_offset] = hprots.port6[0][base + 4 + way_offset];
    lines_buf[4 + way_offset] = lines.port6[0][base + 4 + way_offset];
    owners_buf[4 + way_offset] = owners.port6[0][base + 4 + way_offset];
    sharers_buf[4 + way_offset] = sharers.port6[0][base + 4 + way_offset];
    dirty_bits_buf[4 + way_offset] = dirty_bits.port6[0][base + 4 + way_offset];

    tags_buf[5 + way_offset] = tags.port7[0][base + 5 + way_offset];
    states_buf[5 + way_offset] = states.port7[0][base + 5 + way_offset];
    hprots_buf[5 + way_offset] = hprots.port7[0][base + 5 + way_offset];
    lines_buf[5 + way_offset] = lines.port7[0][base + 5 + way_offset];
    owners_buf[5 + way_offset] = owners.port7[0][base + 5 + way_offset];
    sharers_buf[5 + way_offset] = sharers.port7[0][base + 5 + way_offset];
    dirty_bits_buf[5 + way_offset] = dirty_bits.port7[0][base + 5 + way_offset];

    tags_buf[6 + way_offset] = tags.port8[0][base + 6 + way_offset];
    states_buf[6 + way_offset] = states.port8[0][base + 6 + way_offset];
    hprots_buf[6 + way_offset] = hprots.port8[0][base + 6 + way_offset];
    lines_buf[6 + way_offset] = lines.port8[0][base + 6 + way_offset];
    owners_buf[6 + way_offset] = owners.port8[0][base + 6 + way_offset];
    sharers_buf[6 + way_offset] = sharers.port8[0][base + 6 + way_offset];
    dirty_bits_buf[6 + way_offset] = dirty_bits.port8[0][base + 6 + way_offset];

    tags_buf[7 + way_offset] = tags.port9[0][base + 7 + way_offset];
    states_buf[7 + way_offset] = states.port9[0][base + 7 + way_offset];
    hprots_buf[7 + way_offset] = hprots.port9[0][base + 7 + way_offset];
    lines_buf[7 + way_offset] = lines.port9[0][base + 7 + way_offset];
    owners_buf[7 + way_offset] = owners.port9[0][base + 7 + way_offset];
    sharers_buf[7 + way_offset] = sharers.port9[0][base + 7 + way_offset];
    dirty_bits_buf[7 + way_offset] = dirty_bits.port9[0][base + 7 + way_offset];

#if (LLC_WAYS >= 16)

    tags_buf[8 + way_offset] = tags.port10[0][base + 8 + way_offset];
    states_buf[8 + way_offset] = states.port10[0][base + 8 + way_offset];
    hprots_buf[8 + way_offset] = hprots.port10[0][base + 8 + way_offset];
    lines_buf[8 + way_offset] = lines.port10[0][base + 8 + way_offset];
    owners_buf[8 + way_offset] = owners.port10[0][base + 8 + way_offset];
    sharers_buf[8 + way_offset] = sharers.port10[0][base + 8 + way_offset];
    dirty_bits_buf[8 + way_offset] = dirty_bits.port10[0][base + 8 + way_offset];

    tags_buf[9 + way_offset] = tags.port11[0][base + 9 + way_offset];
    states_buf[9 + way_offset] = states.port11[0][base + 9 + way_offset];
    hprots_buf[9 + way_offset] = hprots.port11[0][base + 9 + way_offset];
    lines_buf[9 + way_offset] = lines.port11[0][base + 9 + way_offset];
    owners_buf[9 + way_offset] = owners.port11[0][base + 9 + way_offset];
    sharers_buf[9 + way_offset] = sharers.port11[0][base + 9 + way_offset];
    dirty_bits_buf[9 + way_offset] = dirty_bits.port11[0][base + 9 + way_offset];

    tags_buf[10 + way_offset] = tags.port12[0][base + 10 + way_offset];
    states_buf[10 + way_offset] = states.port12[0][base + 10 + way_offset];
    hprots_buf[10 + way_offset] = hprots.port12[0][base + 10 + way_offset];
    lines_buf[10 + way_offset] = lines.port12[0][base + 10 + way_offset];
    owners_buf[10 + way_offset] = owners.port12[0][base + 10 + way_offset];
    sharers_buf[10 + way_offset] = sharers.port12[0][base + 10 + way_offset];
    dirty_bits_buf[10 + way_offset] = dirty_bits.port12[0][base + 10 + way_offset];

    tags_buf[11 + way_offset] = tags.port13[0][base + 11 + way_offset];
    states_buf[11 + way_offset] = states.port13[0][base + 11 + way_offset];
    hprots_buf[11 + way_offset] = hprots.port13[0][base + 11 + way_offset];
    lines_buf[11 + way_offset] = lines.port13[0][base + 11 + way_offset];
    owners_buf[11 + way_offset] = owners.port13[0][base + 11 + way_offset];
    sharers_buf[11 + way_offset] = sharers.port13[0][base + 11 + way_offset];
    dirty_bits_buf[11 + way_offset] = dirty_bits.port13[0][base + 11 + way_offset];

    tags_buf[12 + way_offset] = tags.port14[0][base + 12 + way_offset];
    states_buf[12 + way_offset] = states.port14[0][base + 12 + way_offset];
    hprots_buf[12 + way_offset] = hprots.port14[0][base + 12 + way_offset];
    lines_buf[12 + way_offset] = lines.port14[0][base + 12 + way_offset];
    owners_buf[12 + way_offset] = owners.port14[0][base + 12 + way_offset];
    sharers_buf[12 + way_offset] = sharers.port14[0][base + 12 + way_offset];
    dirty_bits_buf[12 + way_offset] = dirty_bits.port14[0][base + 12 + way_offset];

    tags_buf[13 + way_offset] = tags.port15[0][base + 13 + way_offset];
    states_buf[13 + way_offset] = states.port15[0][base + 13 + way_offset];
    hprots_buf[13 + way_offset] = hprots.port15[0][base + 13 + way_offset];
    lines_buf[13 + way_offset] = lines.port15[0][base + 13 + way_offset];
    owners_buf[13 + way_offset] = owners.port15[0][base + 13 + way_offset];
    sharers_buf[13 + way_offset] = sharers.port15[0][base + 13 + way_offset];
    dirty_bits_buf[13 + way_offset] = dirty_bits.port15[0][base + 13 + way_offset];

    tags_buf[14 + way_offset] = tags.port16[0][base + 14 + way_offset];
    states_buf[14 + way_offset] = states.port16[0][base + 14 + way_offset];
    hprots_buf[14 + way_offset] = hprots.port16[0][base + 14 + way_offset];
    lines_buf[14 + way_offset] = lines.port16[0][base + 14 + way_offset];
    owners_buf[14 + way_offset] = owners.port16[0][base + 14 + way_offset];
    sharers_buf[14 + way_offset] = sharers.port16[0][base + 14 + way_offset];
    dirty_bits_buf[14 + way_offset] = dirty_bits.port16[0][base + 14 + way_offset];

    tags_buf[15 + way_offset] = tags.port17[0][base + 15 + way_offset];
    states_buf[15 + way_offset] = states.port17[0][base + 15 + way_offset];
    hprots_buf[15 + way_offset] = hprots.port17[0][base + 15 + way_offset];
    lines_buf[15 + way_offset] = lines.port17[0][base + 15 + way_offset];
    owners_buf[15 + way_offset] = owners.port17[0][base + 15 + way_offset];
    sharers_buf[15 + way_offset] = sharers.port17[0][base + 15 + way_offset];
    dirty_bits_buf[15 + way_offset] = dirty_bits.port17[0][base + 15 + way_offset];

#endif
#endif


#ifdef LLC_DEBUG
    for (int i = 0; i < LLC_LOOKUP_WAYS; i++) {
	HLS_UNROLL_LOOP(ON, "buf-output-unroll");
	dbg_tags_buf[i + way_offset]	  = tags_buf[i];
	dbg_states_buf[i + way_offset]     = states_buf[i];
	dbg_hprots_buf[i + way_offset]     = hprots_buf[i];
	dbg_lines_buf[i + way_offset]	  = lines_buf[i];
	dbg_sharers_buf[i + way_offset]   = sharers_buf[i];
	dbg_owners_buf[i + way_offset]     = owners_buf[i];
	dbg_dirty_bits_buf[i + way_offset] = dirty_bits_buf[i];
    }
#endif
}


void llc::lookup(llc_tag_t tag, llc_way_t &way, bool &evict)
{
    bool tag_hit = false, empty_way_found = false, evict_valid = false, evict_not_sd = false;
    llc_way_t hit_way = 0, empty_way = 0, evict_way_valid = 0, evict_way_not_sd = 0;

    evict = false;

    /*
     * Hit and empty way policy: If any, the empty way selected is the closest to 0.
     */

    for (int i = LLC_WAYS - 1; i >= 0; i--) {
    	HLS_UNROLL_LOOP(ON);

    	if (tags_buf[i] == tag && states_buf[i] != INVALID) {
    	    tag_hit = true;
    	    hit_way = i;
    	}

    	if (states_buf[i] == INVALID) {
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

    for (int i = LLC_WAYS - 1; i >= 0; i--) {
    	HLS_UNROLL_LOOP(ON);

    	llc_way_t way = (llc_way_t) i + evict_ways_buf;

    	if (states_buf[way] == VALID) {
    	    evict_valid = true;
    	    evict_way_valid = way;
    	}

    	if (states_buf[way] != SD) {
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
	way = evict_ways_buf;
	evict = true;
    }

#ifdef LLC_DEBUG
    {
        HLS_DEFINE_PROTOCOL("lookup_dbg");
        dbg_tag_hit.write(tag_hit);
        dbg_hit_way.write(hit_way);
        dbg_empty_way_found.write(empty_way_found);
        dbg_empty_way.write(empty_way);
        dbg_way.write(way);
        dbg_evict.write(evict);
        dbg_evict_valid.write(evict_valid);
        dbg_evict_way_not_sd.write(evict_way_not_sd);
    }
#endif
}



inline void llc::send_mem_req(bool hwrite, line_addr_t addr, hprot_t hprot, line_t line)
{
    SEND_MEM_REQ;

    llc_mem_req_t mem_req;
    mem_req.hwrite = hwrite;
    mem_req.addr = addr;
    mem_req.hsize = WORD;
    mem_req.hprot = hprot;
    mem_req.line = line;
    do {wait();}
    while (!llc_mem_req.nb_can_put());
    llc_mem_req.nb_put(mem_req);
}

inline void llc::get_mem_rsp(line_t &line)
{
    GET_MEM_RSP;

    llc_mem_rsp_t mem_rsp;
    while (!llc_mem_rsp.nb_can_get())
        wait();
    llc_mem_rsp.nb_get(mem_rsp);
    line = mem_rsp.line;
}


#ifdef STATS_ENABLE
inline void llc::send_stats(bool stats)
{
    SEND_STATS;
    do {wait();}
    while (!llc_stats.nb_can_put());
    llc_stats.nb_put(stats);
}
#endif

inline void llc::send_rsp_out(coh_msg_t coh_msg, line_addr_t addr, line_t line, cache_id_t req_id,
                              cache_id_t dest_id, invack_cnt_t invack_cnt, word_offset_t word_offset)
{
    SEND_RSP_OUT;
    llc_rsp_out_t<CACHE_ID_WIDTH> rsp_out;
    rsp_out.coh_msg = coh_msg;
    rsp_out.addr = addr;
    rsp_out.line = line;
    rsp_out.req_id = req_id;
    rsp_out.dest_id = dest_id;
    rsp_out.invack_cnt = invack_cnt;
    rsp_out.word_offset = word_offset;
    while (!llc_rsp_out.nb_can_put())
        wait();
    llc_rsp_out.nb_put(rsp_out);
}

inline void llc::send_fwd_out(mix_msg_t coh_msg, line_addr_t addr, cache_id_t req_id,
                              cache_id_t dest_id)
{
    SEND_FWD_OUT;
    llc_fwd_out_t fwd_out;

    fwd_out.coh_msg = coh_msg;
    fwd_out.addr = addr;
    fwd_out.req_id = req_id;
    fwd_out.dest_id = dest_id;
    while (!llc_fwd_out.nb_can_put())
        wait();
    llc_fwd_out.nb_put(fwd_out);
}

inline void llc::send_dma_rsp_out(coh_msg_t coh_msg, line_addr_t addr, line_t line, llc_coh_dev_id_t req_id,
                           cache_id_t dest_id, invack_cnt_t invack_cnt, word_offset_t word_offset)
{
    SEND_DMA_RSP_OUT;
    llc_rsp_out_t<LLC_COH_DEV_ID_WIDTH> rsp_out;
    rsp_out.coh_msg = coh_msg;
    rsp_out.addr = addr;
    rsp_out.line = line;
    rsp_out.req_id = req_id;
    rsp_out.dest_id = dest_id;
    rsp_out.invack_cnt = invack_cnt;
    rsp_out.word_offset = word_offset;
    while (!llc_dma_rsp_out.nb_can_put())
        wait();
    llc_dma_rsp_out.nb_put(rsp_out);
}

/*
 * Processes
 */

void llc::ctrl()
{
    // -----------------------------
    // RESET
    // -----------------------------

    // Reset all signals and channels
    {
        HLS_DEFINE_PROTOCOL("reset-io");

        this->reset_io();
    }

    // Reset state memory
    {
        HLS_DEFINE_PROTOCOL("reset_state-1");

        this->reset_state();
    }


    while (true) {

        bool is_rst_to_resume = false;
        bool is_flush_to_resume = false;
	bool is_rst_to_get = false;
	bool is_rsp_to_get = false;
	bool is_req_to_get = false;
        bool is_dma_read_to_resume = false;
        bool is_dma_write_to_resume = false;
	bool is_dma_req_to_get = false;

        bool rst_in = false;
        llc_rsp_in_t rsp_in;
        llc_req_in_t<CACHE_ID_WIDTH> req_in;

        bool can_get_rst_tb = false;
        bool can_get_rsp_in = false;
        bool can_get_req_in = false;
        bool can_get_dma_req_in = false;

        bool update_evict_ways = false;

        bool look;
        line_breakdown_t<llc_tag_t, llc_set_t> line_br;
        llc_set_t set;
        llc_way_t way;
        bool evict;
        llc_addr_t base;
        llc_addr_t llc_addr;
        line_addr_t addr_evict;

        // -----------------------------
        // Check input channels
        // -----------------------------

        {
            HLS_DEFINE_PROTOCOL("proto-llc-io-check");

            bool do_get_req = false;
            bool do_get_dma_req = false;

            can_get_rst_tb = llc_rst_tb.nb_can_get();
            can_get_rsp_in = llc_rsp_in.nb_can_get();
            can_get_req_in = llc_req_in.nb_can_get();
            can_get_dma_req_in = llc_dma_req_in.nb_can_get();

            if (recall_pending) {
                if (!recall_valid) {
                // Response (could be related to the recall or not)
                    if (can_get_rsp_in) {
                        is_rsp_to_get = true;
                    }

                } else {
                    if (dma_read_pending)
                        is_dma_read_to_resume = true;
                    else if (dma_write_pending)
                        is_dma_write_to_resume = true;
                }

            } else if (rst_stall) {
                // Pending reset
                is_rst_to_resume = true;

            } else if (flush_stall) {
                // Pending flush
                is_flush_to_resume = true;

            } else if (can_get_rst_tb && !dma_read_pending && !dma_write_pending) {
                // Reset or flush
                is_rst_to_get = true;

            } else if (can_get_rsp_in) {
                // Response
                is_rsp_to_get = true;

            } else if ((can_get_req_in && !req_stall) || (!req_stall && req_in_stalled_valid)) {
                // New request

                if (req_in_stalled_valid) {
                    req_in_stalled_valid = false;
                    req_in = req_in_stalled;
                } else {
                    do_get_req = true;
                }

                is_req_to_get = true;

            } else if (dma_read_pending) {
                // Pending DMA read

                is_dma_read_to_resume = true;

            } else if (dma_write_pending) {
                // Pending DMA write

                if (can_get_dma_req_in) {
                    is_dma_write_to_resume = true;
                    do_get_dma_req = true;
                }

            } else if (can_get_dma_req_in && !req_stall) {
                // New DMA request
                is_dma_req_to_get = true;
                do_get_dma_req = true;
            }


            if (is_rsp_to_get) {
                LLC_GET_RSP_IN;
                llc_rsp_in.nb_get(rsp_in);
            }

            if (is_rst_to_get) {
                llc_rst_tb.nb_get(rst_in);
            }

            if (do_get_req) {
                GET_REQ_IN;
                llc_req_in.nb_get(req_in);
            }

            if (do_get_dma_req) {
                GET_DMA_REQ_IN;
                llc_dma_req_in.nb_get(dma_req_in);
            }

        }

#ifdef LLC_DEBUG
	dbg_is_rst_to_get.write(is_rst_to_get);
	dbg_is_rsp_to_get.write(is_rsp_to_get);
	dbg_is_req_to_get.write(is_req_to_get);
        dbg_is_dma_read_to_resume.write(is_dma_read_to_resume);
        dbg_is_dma_write_to_resume.write(is_dma_write_to_resume);
        dbg_is_dma_req_to_get.write(is_dma_req_to_get);

	bookmark_tmp = 0;
	asserts_tmp = 0;
#endif

        // -----------------------------
        // Lookup cache
        // -----------------------------
        look = is_flush_to_resume ||
            is_rsp_to_get ||
            is_req_to_get ||
            is_dma_req_to_get ||
            (is_dma_read_to_resume && !recall_pending) ||
            (is_dma_write_to_resume && !recall_pending);

        // Pick right set
        if (is_flush_to_resume || is_rst_to_resume) {
            set = rst_flush_stalled_set;

            // Update current set
            rst_flush_stalled_set++;
            if (rst_flush_stalled_set == 0) {
                rst_stall = false;
                flush_stall = false;
            }
        } else if (is_rsp_to_get) {
            line_br.llc_line_breakdown(rsp_in.addr);
            set = line_br.set;

            if ((req_stall == true) && (line_br.tag == req_in_stalled_tag)
                && (line_br.set == req_in_stalled_set)) {
                req_stall = false;
            }
        } else if (is_req_to_get) {
            line_br.llc_line_breakdown(req_in.addr);
            set = line_br.set;
        } else if (is_dma_req_to_get || is_dma_read_to_resume || is_dma_write_to_resume) {
            if (is_dma_req_to_get)
                dma_addr = dma_req_in.addr;

            line_br.llc_line_breakdown(dma_addr);
            set = line_br.set;
        }

        // Compute llc_address based on set
        base = set << LLC_WAY_BITS;
#ifdef LLC_DEBUG
        dbg_llc_addr.write(llc_addr);
#endif
        // Read all ways from set into buffer
        if (look) {

            HLS_DEFINE_PROTOCOL("read-cache");

            wait();
            read_set(base, 0);
            evict_ways_buf = evict_ways.port2[0][set];
#if LLC_WAYS == 32
            wait();
            read_set(base, 1);
#endif

#ifdef LLC_DEBUG
            dbg_evict_ways_buf = evict_ways_buf;
#endif
        }


        // Select select way and determine potential eviction
        lookup(line_br.tag, way, evict);

        // Compute llc_address based on selected way
        llc_addr = base + way;
        // Compute memory address to use in case of eviction
        addr_evict = (tags_buf[way] << LLC_SET_BITS) + set;

        // -----------------------------
        // Process current request
        // -----------------------------

        // Resume flush
        if (is_flush_to_resume) {
            // partial flush (only VALID DATA lines)

            for (int way = 0; way < LLC_WAYS; way++) {
                HLS_DEFINE_PROTOCOL("is_flush_to_resume");
                line_addr_t line_addr = (tags_buf[way] << LLC_SET_BITS) | (set);

                if (states_buf[way] == VALID && dirty_bits_buf[way]) {
                    FLUSH_DIRTY_LINE;
                    send_mem_req(WRITE, line_addr, hprots_buf[way], lines_buf[way]);

                    // Uncomment for additional debug info during behavioral simulation
                    // const line_addr_t new_addr_evict = (tags_buf[way] << LLC_SET_BITS) + set;
                    // std::cout << std::hex << "*** way: " << way << " set: " <<  set << " addr: " << new_addr_evict << " state: " << states_buf[way] << " line: " << lines_buf[way] << std::endl;
                } else {
                    wait();
                }
            }
        }

        // Start new reset/flush
        else if (is_rst_to_get) {

            if (!rst_in) {
                HLS_DEFINE_PROTOCOL("is_reset");
                this->reset_state();

            } else {
                LLC_FLUSH;
                flush_stall = true;
                rst_flush_stalled_set = 0;
            }

        }

        // Process response
        else if (is_rsp_to_get) {

            // Check if response resolve the pending recall
            if (recall_pending && (rsp_in.addr == addr_evict)) {
                if (rsp_in.coh_msg == RSP_DATA) {
                    lines_buf[way] = rsp_in.line;
                    dirty_bits_buf[way] = 1;
                }
                recall_valid = true;
            } else {
                lines_buf[way] = rsp_in.line;
                dirty_bits_buf[way] = 1;
            }

            // Check if response solves a currently stalled request
            if ((req_stall == true) && (line_br.tag == req_in_stalled_tag)
                && (line_br.set == req_in_stalled_set)) {
                req_stall = false;
            }

            // Update buffers with data from response
            // (state/sharers/owners to be fixed when recall completes)
            if (sharers_buf[way] != 0)
                states_buf[way] = SHARED;
            else
                states_buf[way] = VALID;

        }


        // Process new request
        else if (is_req_to_get) {

#ifdef LLC_DEBUG
            dbg_evict_addr.write(addr_evict);
#endif

#ifdef STATS_ENABLE
            const bool hit = !((states_buf[way] == INVALID) || evict);
            {
                HLS_DEFINE_PROTOCOL("send_stats-1");
                send_stats(hit);
            }
#endif

            if (evict) {
                LLC_EVICT;

                if (way == evict_ways_buf) {
                    update_evict_ways = true;
                    evict_ways_buf++;
                }

                if (states_buf[way] == VALID) {
                    EVICT_V;

                    if (dirty_bits_buf[way]) {
                        HLS_DEFINE_PROTOCOL("send_mem_req-2");
                        send_mem_req(WRITE, addr_evict, hprots_buf[way], lines_buf[way]);
                    }
                }
                states_buf[way] = INVALID;
            }

            switch (req_in.coh_msg) {

            case REQ_GETS :
                LLC_GETS;

                switch (states_buf[way]) {

                case INVALID :
                case VALID :
		    {
			GETS_IV;

			if (states_buf[way] == INVALID) {
                            {
                                HLS_DEFINE_PROTOCOL("send_mem_req-3");
                                send_mem_req(READ, req_in.addr, req_in.hprot, 0);
                                get_mem_rsp(lines_buf[way]);
                            }
			    hprots_buf[way]     = req_in.hprot;
			    tags_buf[way]       = line_br.tag;
			    dirty_bits_buf[way] = 0;
			}

			if (req_in.hprot == 0) {
			    {
                                HLS_DEFINE_PROTOCOL("send_rsp_out-1");
                                send_rsp_out(RSP_DATA, req_in.addr, lines_buf[way], req_in.req_id, 0, 0, 0);
                            }


			    states_buf[way] = SHARED;
			    sharers_buf[way] = 1 << req_in.req_id;
			} else {
			    {
                                HLS_DEFINE_PROTOCOL("send_rsp_out-2");
                                send_rsp_out(RSP_EDATA, req_in.addr, lines_buf[way], req_in.req_id, 0, 0, 0);
                            }


			    states_buf[way] = EXCLUSIVE;
			    owners_buf[way] = req_in.req_id;
			}

		    }
		    break;

                case SHARED :
		    {
			GETS_S;

			{
                            HLS_DEFINE_PROTOCOL("send_rsp_out-3");
                            send_rsp_out(RSP_DATA, req_in.addr, lines_buf[way], req_in.req_id, 0, 0, 0);
                        }

			sharers_buf[way] = sharers_buf[way] | (1 << req_in.req_id);
		    }
		    break;

                case EXCLUSIVE :
                case MODIFIED :
		    {
			GETS_EM;

                        {
                            HLS_DEFINE_PROTOCOL("send_fwd_out-0");
                            send_fwd_out(FWD_GETS, req_in.addr, req_in.req_id, owners_buf[way]);
                        }

			sharers_buf[way] = (1 << req_in.req_id) | (1 << owners_buf[way]);
			states_buf[way]  = SD;
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

                switch (states_buf[way]) {

                case INVALID :
                case VALID :
		    {
			GETM_IV;

			if (states_buf[way] == INVALID) {
                            {
                                HLS_DEFINE_PROTOCOL("send_mem_req-4");
                                send_mem_req(READ, req_in.addr, req_in.hprot, 0);
                                get_mem_rsp(lines_buf[way]);
                            }

			    hprots_buf[way]     = req_in.hprot;
			    tags_buf[way]       = line_br.tag;
			    dirty_bits_buf[way] = 0;
			}

			{
                            HLS_DEFINE_PROTOCOL("send_rsp_out-4");
                            send_rsp_out(RSP_DATA, req_in.addr, lines_buf[way], req_in.req_id, 0, 0, 0);
                        }

			owners_buf[way] = req_in.req_id;
			states_buf[way] = MODIFIED;

		    }
		    break;

                case SHARED :
		    {
			GETM_S;

			invack_cnt_t invack_cnt = 0;

			for (int i = 0; i < MAX_N_L2; i++) {
                            HLS_DEFINE_PROTOCOL("send_fwd_out-1");
			    if (((sharers_buf[way] & (1 << i)) != 0) && (i != req_in.req_id)) {
				send_fwd_out(FWD_INV, req_in.addr, req_in.req_id, i);
				invack_cnt++;
			    }
			    wait();
			}

			{
                            HLS_DEFINE_PROTOCOL("send_rsp_out-5");
                            send_rsp_out(RSP_DATA, req_in.addr, lines_buf[way], req_in.req_id, 0, invack_cnt, 0);
                        }

			states_buf[way]  = MODIFIED;
			owners_buf[way]  = req_in.req_id;
			sharers_buf[way] = 0;
		    }
		    break;

                case EXCLUSIVE :
		    {
			GETM_E;

                        {
                            HLS_DEFINE_PROTOCOL("send_fwd_out-2");
                            send_fwd_out(FWD_GETM, req_in.addr, req_in.req_id, owners_buf[way]);
                        }

			states_buf[way] = MODIFIED;
			owners_buf[way] = req_in.req_id;
		    }
		    break;

                case MODIFIED :
		    {
			GETM_M;

                        {
                            HLS_DEFINE_PROTOCOL("send_fwd_out-3");
                            send_fwd_out(FWD_GETM, req_in.addr, req_in.req_id, owners_buf[way]);
                        }

			owners_buf[way] = req_in.req_id;
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

                {
                    HLS_DEFINE_PROTOCOL("send_fwd_out-4");
                    send_fwd_out(FWD_PUTACK, req_in.addr, req_in.req_id, req_in.req_id);
                }

                switch (states_buf[way]) {

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

			sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);

			if (sharers_buf[way] == 0)
			    states_buf[way] = VALID;
		    }
		    break;

                case EXCLUSIVE :
		    {
			PUTS_E;

			if (owners_buf[way] == req_in.req_id)
			    states_buf[way] = VALID;
		    }
		    break;

                case SD :
		    {
			PUTS_SD;

			sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    }
		    break;

                default :
                    GENERIC_ASSERT;
                }

                break;

            case REQ_PUTM :

                LLC_PUTM;

                {
                    HLS_DEFINE_PROTOCOL("send_fwd_out-5");
                    send_fwd_out(FWD_PUTACK, req_in.addr, req_in.req_id, req_in.req_id);
                }

                switch (states_buf[way]) {

                case INVALID :
                case VALID :
		    {
			PUTM_IV;
		    }
		    break;

                case SHARED :
		    {
			PUTM_S;

			sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);

			if (sharers_buf[way] == 0)
			    states_buf[way] = VALID;
		    }
		    break;

                case EXCLUSIVE :
                case MODIFIED :
		    {
			PUTM_EM;

			if (owners_buf[way] == req_in.req_id) {
			    states_buf[way]     = VALID;
			    lines_buf[way]      = req_in.line;
			    dirty_bits_buf[way] = 1;
			}
		    }
		    break;

                case SD :
		    {
			PUTM_SD;

			sharers_buf[way] = sharers_buf[way] & ~ (1 << req_in.req_id);
		    }
		    break;

                default :
                    GENERIC_ASSERT;
                }
                break;

            default :
                GENERIC_ASSERT;
            }
	}


        // Process DMA
        else if (is_dma_req_to_get || is_dma_read_to_resume || is_dma_write_to_resume) {

            bool evict_dirty = false;

            if (is_dma_req_to_get) {
                DMA_BURST;

                if (dma_req_in.coh_msg == REQ_DMA_READ_BURST) {
                    dma_read_pending = true;
                    is_dma_read_to_resume = true;
                } else {
                    dma_write_pending = true;
                    is_dma_write_to_resume = true;
                }

                dma_read_length = dma_req_in.line.range(BITS_PER_LINE - 1, BITS_PER_LINE - ADDR_BITS).to_uint();
                dma_length = 0;
                dma_done = false;
                dma_start = true;

            }

            if (!recall_valid && !recall_pending) {
#ifdef LLC_DEBUG
                dbg_evict_addr.write(addr_evict);
#endif

#ifdef STATS_ENABLE
                const bool hit = !((states_buf[way] == INVALID) || evict);
                {
                    HLS_DEFINE_PROTOCOL("send_stats-2");
                    send_stats(hit);
                }
#endif

                // Recall (may or may not evict depending on miss/hit)
                if (states_buf[way] == EXCLUSIVE || states_buf[way] == MODIFIED) {
                    RECALL_EM;
                    HLS_DEFINE_PROTOCOL("send_fwd_out-6");
                    send_fwd_out(FWD_GETM_LLC, addr_evict, owners_buf[way], owners_buf[way]);
                    recall_pending = true;
                }


                else if (states_buf[way] == SD) {
                    for (int i = 0; i < MAX_N_L2; i++) {
                        HLS_DEFINE_PROTOCOL("send_fwd_out-8");
                        if (sharers_buf[way] & (1 << i))
                            send_fwd_out(FWD_INV_LLC, addr_evict, i, i);
                        wait();
                    }

                    recall_pending = true;
                }

                else if (states_buf[way] == SHARED) {
                    RECALL_S;

                    for (int i = 0; i < MAX_N_L2; i++) {
                        HLS_DEFINE_PROTOCOL("send_fwd_out-7");
                        if (sharers_buf[way] & (1 << i))
                            send_fwd_out(FWD_INV_LLC, addr_evict, i, i);
                        wait();
                    }
                    recall_valid = true;
                }

            }

            if (!recall_pending  || recall_valid) {

                if (dirty_bits_buf[way])
                    evict_dirty = true;

                if (evict || recall_valid) {
                    owners_buf[way] = 0;
                    sharers_buf[way] = 0;
                }

                if (evict) {
                    // Eviction

                    LLC_EVICT;

                    if (way == evict_ways_buf) {
                        update_evict_ways = true;
                        evict_ways_buf++;
                    }

                    if (evict_dirty ) {
                        HLS_DEFINE_PROTOCOL("send_mem_req-6");
                        send_mem_req(WRITE, addr_evict, hprots_buf[way], lines_buf[way]);
                    }

                    states_buf[way] = INVALID;

                } else if (recall_valid) {
                    states_buf[way]     = VALID;
                }

                // Recall complete
                recall_pending = false;
                recall_valid = false;

                if (is_dma_read_to_resume) {
                    LLC_DMA_READ_BURST;

                    dma_length_t valid_words;
                    word_offset_t dma_read_woffset;
                    invack_cnt_t dma_info;

                    if (dma_start)
                        dma_read_woffset = dma_req_in.word_offset;
                    else
                        dma_read_woffset = 0;

                    dma_length += WORDS_PER_LINE - dma_read_woffset;

                    if (dma_length >= dma_read_length)
                        dma_done = true;

                    if (dma_start & dma_done)
                        valid_words = dma_read_length;
                    else if (dma_start)
                        valid_words = dma_length;
                    else if (dma_length > dma_read_length)
                        valid_words = WORDS_PER_LINE - (dma_length - dma_read_length);
                    else
                        valid_words = WORDS_PER_LINE;

                    if (states_buf[way] == INVALID) {

                        DMA_READ_I;
                        HLS_DEFINE_PROTOCOL("send_mem_req-7");
                        send_mem_req(READ, dma_addr, dma_req_in.hprot, 0);
                        get_mem_rsp(lines_buf[way]);
                    }

                    dma_info[0] = dma_done;
                    dma_info.range(WORD_BITS, 1) = (valid_words - 1);

                    {
                        HLS_DEFINE_PROTOCOL("send_dma_rsp_out");
                        send_dma_rsp_out(RSP_DATA_DMA, dma_addr, lines_buf[way],
                                         dma_req_in.req_id, 0, dma_info, dma_read_woffset);
                    }

                    if (states_buf[way] == INVALID) {
                        hprots_buf[way]     = DATA;
                        tags_buf[way]       = line_br.tag;
                        states_buf[way]     = VALID;
                        dirty_bits_buf[way] = 0;
                    }

                } else { // is_dma_write_to_resume
                    LLC_DMA_WRITE_BURST;

                    word_offset_t dma_write_woffset = dma_req_in.word_offset;
                    dma_length_t valid_words = dma_req_in.valid_words + 1;
                    bool misaligned;

                    misaligned = (dma_write_woffset != 0 || valid_words != WORDS_PER_LINE);

                    if (states_buf[way] == INVALID) {

                        DMA_WRITE_I;

                        if (misaligned) {
                            HLS_DEFINE_PROTOCOL("send_mem_req-8");
                            send_mem_req(READ, dma_addr, dma_req_in.hprot, 0);
                            get_mem_rsp(lines_buf[way]);
                        }

                    }

                    if (misaligned) {
                        int word_cnt = 0;

                        for (int i = 0; i < WORDS_PER_LINE; i++) {

                            HLS_UNROLL_LOOP(ON, "misaligned-dma-start-unroll");

                            if (word_cnt < valid_words && i >= dma_write_woffset) {
                                write_word(lines_buf[way], read_word(dma_req_in.line, i), i, 0, WORD);
                                word_cnt++;
                            }

                        }

                    } else {

                        lines_buf[way] = dma_req_in.line;

                    }

                    lines_buf[way] = lines_buf[way];
                    dirty_bits_buf[way] = 1;

                    if (states_buf[way] == INVALID) {
                        states_buf[way] = VALID;
                        hprots_buf[way] = DATA;
                        tags_buf[way] = line_br.tag;
                    }

                    if (dma_req_in.hprot) {

                        dma_done = true;

                    }
                }

#ifdef LLC_DEBUG
                dbg_length.write(dma_read_length);
                dbg_dma_length.write(dma_length);
                dbg_dma_done.write(dma_done);
                dbg_dma_addr.write(dma_addr);
#endif
                dma_addr++;
                dma_start   = false;

                if (dma_done) {
                    dma_read_pending = false;
                    dma_write_pending = false;
                }
            }
        }


        // Complete reset/flush
        if (is_flush_to_resume || is_rst_to_resume) {
            if (!flush_stall && !rst_stall) {
                HLS_DEFINE_PROTOCOL("rst_flush_done");
                do {wait();}
                while (!llc_rst_tb_done.nb_can_put());
                llc_rst_tb_done.nb_put(1);
            }
        }


        // -----------------------------
        // Update cache
        // -----------------------------

        // Resume reset
        if (is_rst_to_resume) {

            evict_ways.port1[0][set] = 0;

            for (int way = 0; way < LLC_WAYS; way++) { // do not unroll
                const int idx = base + way;

                states.port1[0][idx]     = INVALID;
                dirty_bits.port1[0][idx] = 0;
                sharers.port1[0][idx]    = 0;

            }
        }

        // Resume flush
        else if (is_flush_to_resume) {
            // partial flush (only VALID DATA lines)

            for (int way = 0; way < LLC_WAYS; way++) {

#ifdef LLC_DEBUG
                dbg_flush_set.write(set);
                dbg_flush_way.write(way);
#endif
                llc_addr_t llc_addr = base + way;

                if (states_buf[way] == VALID && hprots_buf[way] == DATA) {

                    states.port1[0][llc_addr]     = INVALID;
                    sharers.port1[0][llc_addr]    = 0;
                    dirty_bits.port1[0][llc_addr] = 0;

                }
            }
        }


        else if (is_rsp_to_get ||
                 is_req_to_get ||
                 is_dma_req_to_get ||
                 is_dma_read_to_resume ||
                 is_dma_write_to_resume) {

            tags.port1[0][llc_addr]       = tags_buf[way];
            states.port1[0][llc_addr]     = states_buf[way];
            lines.port1[0][llc_addr]      = lines_buf[way];
            hprots.port1[0][llc_addr]     = hprots_buf[way];
            owners.port1[0][llc_addr]     = owners_buf[way];
            sharers.port1[0][llc_addr]    = sharers_buf[way];
            dirty_bits.port1[0][llc_addr] = dirty_bits_buf[way];

            if (update_evict_ways)
                evict_ways.port1[0][set] = evict_ways_buf;

            // Uncomment for additional debug info during behavioral simulation
            // const line_addr_t new_addr_evict = (tags_buf[way] << LLC_SET_BITS) + set;
            // std::cout << std::hex << "*** way: " << way << " set: " <<  set << " addr: " << new_addr_evict << " state: " << states[llc_addr] << " line: " << lines[llc_addr] << std::endl;

        }


        {
            HLS_DEFINE_PROTOCOL("end-of-loop-break-rw-protocol");
            wait();
        }
    }
}
