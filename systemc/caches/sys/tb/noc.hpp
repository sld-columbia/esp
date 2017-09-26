/* Copyright 2017 Columbia University, SLD Group */

#ifndef __NOC_HPP__
#define __NOC_HPP__

#include <string>
#include <iostream>
#include <sstream>

#include "cache_utils.hpp"

#define QUEUE_DEPTH 2

class noc : public sc_module
{

public:

	// Clock signal
	sc_in<bool> clk;

	// Reset signal
	sc_in<bool> rst;

	//
	// Signals
	//

	// To  L2 cache
	nb_put_initiator<l2_fwd_in_t>   *l2_fwd_in[N_CPU];
	nb_put_initiator<l2_rsp_in_t>   *l2_rsp_in[N_CPU];
	// From	L2 cache
	nb_get_initiator<l2_req_out_t>  *l2_req_out[N_CPU];
	nb_get_initiator<l2_rsp_out_t>  *l2_rsp_out[N_CPU];
	// To LLC cache
	nb_put_initiator<llc_req_in_t>  llc_req_in;
	nb_put_initiator<llc_rsp_in_t>  llc_rsp_in;
	// From LLC cache
	nb_get_peek_initiator<llc_rsp_out_t> llc_rsp_out;
	nb_get_peek_initiator<llc_fwd_out_t> llc_fwd_out;

	// Constructor
	SC_CTOR(noc)
		: clk("clk")
		, rst("rst")
		, llc_req_in("llc_req_in")
		, llc_rsp_in("llc_rsp_in")
		, llc_rsp_out("llc_rsp_out")
		, llc_fwd_out("llc_fwd_out")
		{
			// Cache controller process
			SC_CTHREAD(req_plane_to_llc, clk.pos());
			reset_signal_is(rst, false);
			SC_CTHREAD(rsp_plane_to_llc, clk.pos());
			reset_signal_is(rst, false);
			SC_CTHREAD(fwd_plane_from_llc, clk.pos());
			reset_signal_is(rst, false);
			SC_CTHREAD(rsp_plane_from_llc, clk.pos());
			reset_signal_is(rst, false);


			// Assign clock and reset to put_get ports
			for (int i = 0; i < N_CPU; i++) {
				std::stringstream stm;
				stm.str("");
				stm << "l2_fwd_in_" << i;
				l2_fwd_in[i] = new nb_put_initiator<l2_fwd_in_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_rsp_in_" << i;
				l2_rsp_in[i] = new nb_put_initiator<l2_rsp_in_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_req_out_" << i;
				l2_req_out[i] = new nb_get_initiator<l2_req_out_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_rsp_out_" << i;
				l2_rsp_out[i] = new nb_get_initiator<l2_rsp_out_t>(stm.str().c_str());

				l2_fwd_in[i]->clk_rst(clk, rst);
				l2_rsp_in[i]->clk_rst(clk, rst);
				l2_req_out[i]->clk_rst(clk, rst);
				l2_rsp_out[i]->clk_rst(clk, rst);
			}

			llc_req_in.clk_rst(clk, rst);
			llc_rsp_in.clk_rst(clk, rst);
			llc_rsp_out.clk_rst(clk, rst);
			llc_fwd_out.clk_rst(clk, rst);
		}

	// Processes
	void req_plane_to_llc();
	void rsp_plane_to_llc();
	void fwd_plane_from_llc();
	void rsp_plane_from_llc();

	// Queues
	l2_fwd_in_t   l2_fwd_in_q[N_CPU][QUEUE_DEPTH];
	l2_rsp_in_t   l2_rsp_in_q[N_CPU][QUEUE_DEPTH];
	l2_req_out_t  l2_req_out_q[N_CPU][QUEUE_DEPTH];
	l2_rsp_out_t  l2_rsp_out_q[N_CPU][QUEUE_DEPTH];
	int l2_fwd_in_ptr[N_CPU];
	int l2_rsp_in_ptr[N_CPU];
	int l2_req_out_ptr[N_CPU];
	int l2_rsp_out_ptr[N_CPU];
};

#endif /* __NOC_HPP__ */
