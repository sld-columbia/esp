/* Copyright 2017 Columbia University, SLD Group */

#include "noc.hpp"

void noc::req_plane_to_llc()
{
	// Reset
	for (int i = 0; i < N_CPU; i++) {
		l2_req_out[i]->reset_get();
		l2_req_out_ptr[i] = -1;
	}
	llc_req_in.reset_put();
	int next = 0;
	wait();

	while (true) {
		// Forward pending packets
		for (int i = 0; i < N_CPU; i++) {
			if (l2_req_out_ptr[next] != -1) {
				if (llc_req_in.nb_can_put()) {
					l2_req_out_t src = l2_req_out_q[next][l2_req_out_ptr[next]--];
					llc_req_in_t dst;
					dst.coh_msg = src.coh_msg;
					dst.hprot = src.hprot;
					dst.addr = src.addr;
					dst.line = src.line;
					dst.req_id = next;
					llc_req_in.nb_put(dst);
				}
				else {
					break; // Save priority for next iteration
				}
			}
			next = (next + 1) % N_CPU;
		}

		// Check for new packets
		for (int i = 0; i < N_CPU; i++)
			if (l2_req_out_ptr[i] < QUEUE_DEPTH)
				if (l2_req_out[i]->nb_can_get())
					l2_req_out[i]->nb_get(l2_req_out_q[i][l2_req_out_ptr[i]++]);

		wait();
	}

}

void noc::rsp_plane_to_llc()
{
	// Reset
	for (int i = 0; i < N_CPU; i++) {
		l2_rsp_out[i]->reset_get();
		l2_rsp_out_ptr[i] = -1;
	}
	llc_rsp_in.reset_put();
	int next = 0;
	wait();

	while (true) {
		// Forward pending packets
		for (int i = 0; i < N_CPU; i++) {
			if (l2_rsp_out_ptr[next] != -1) {
				if (llc_rsp_in.nb_can_put()) {
					// TODO: add dst_id once L2 will handle coherence with N_CPU > 1
					//       may need to deliver packet to remote L2 instead of LLC.
					l2_rsp_out_t src = l2_rsp_out_q[next][l2_rsp_out_ptr[next]--];
					llc_rsp_in_t dst;
					dst.addr = src.addr;
					dst.line = src.line;
					dst.req_id = next;
					llc_rsp_in.nb_put(dst);
				} else {
					break; // Save priority for next iteration
				}
			}
			next = (next + 1) % N_CPU;
		}

		// Check for new packets
		for (int i = 0; i < N_CPU; i++)
			if (l2_rsp_out_ptr[i] < QUEUE_DEPTH)
				if (l2_rsp_out[i]->nb_can_get())
					l2_rsp_out[i]->nb_get(l2_rsp_out_q[i][l2_rsp_out_ptr[i]++]);

		wait();
	}

}

void noc::fwd_plane_from_llc()
{
	// Reset
	for (int i = 0; i < N_CPU; i++) {
		l2_fwd_in[i]->reset_put();
		l2_fwd_in_ptr[i] = -1;
	}
	llc_fwd_out.reset_get();
	wait();

	while (true) {
		// Check for new packets
		if (llc_fwd_out.nb_can_get()) {
			llc_fwd_out_t src;
			llc_fwd_out.nb_peek(src);
			cache_id_t dest_id = src.dest_id;
			if (l2_fwd_in_ptr[dest_id] < QUEUE_DEPTH) {
				llc_fwd_out.nb_get(src);
				l2_fwd_in_t dst;
				dst.coh_msg = src.coh_msg;
				dst.addr = src.addr;
				l2_fwd_in_q[dest_id][l2_fwd_in_ptr[dest_id]++];
			}
		}

		// Forward pending packets
		for (int i = 0; i < N_CPU; i++)
			if (l2_fwd_in_ptr[i] != -1)
				if (l2_fwd_in[i]->nb_can_put())
					l2_fwd_in[i]->nb_put(l2_fwd_in_q[i][l2_fwd_in_ptr[i]--]);

		wait();
	}

}

void noc::rsp_plane_from_llc()
{
	// Reset
	for (int i = 0; i < N_CPU; i++) {
		l2_rsp_in[i]->reset_put();
		l2_rsp_in_ptr[i] = -1;
	}
	llc_rsp_out.reset_get();
	wait();

	while (true) {
		// Check for new packets
		if (llc_rsp_out.nb_can_get()) {
			llc_rsp_out_t src;
			llc_rsp_out.nb_peek(src);
			cache_id_t dest_id = src.dest_id;
			if (l2_rsp_in_ptr[dest_id] < QUEUE_DEPTH) {
				llc_rsp_out.nb_get(src);
				l2_rsp_in_t dst;
				dst.coh_msg = src.coh_msg;
				dst.addr = src.addr;
				dst.line = src.line;
				dst.invack_cnt = src.invack_cnt;
				l2_rsp_in_q[dest_id][l2_rsp_in_ptr[dest_id]++];
			}
		}

		// Forward pending packets
		for (int i = 0; i < N_CPU; i++)
			if (l2_rsp_in_ptr[i] != -1)
				if (l2_rsp_in[i]->nb_can_put())
					l2_rsp_in[i]->nb_put(l2_rsp_in_q[i][l2_rsp_in_ptr[i]--]);

		wait();
	}
}
