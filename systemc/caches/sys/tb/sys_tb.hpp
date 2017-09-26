/* Copyright 2017 Columbia University, SLD Group */

#ifndef __SYS_TB_HPP__
#define __SYS_TB_HPP__


#include "cache_utils.hpp"

class sys_tb : public sc_module
{

public:

	// Clock signal
	sc_in<bool> clk;

	// Reset signal
	sc_in<bool> rst;

	//
	// Signals
	//

	// L2 Debug
	sc_in< sc_bv<ASSERT_WIDTH> >    l2_asserts[N_CPU];
	sc_in< sc_bv<BOOKMARK_WIDTH> >  l2_bookmark[N_CPU];
	sc_in<uint32_t>                 l2_custom_dbg[N_CPU];
	sc_in<bool>                     l2_flush_done[N_CPU];
	// To L2 cache
	put_initiator<l2_cpu_req_t>     *l2_cpu_req_tb[N_CPU];
	put_initiator<bool>		*l2_flush_tb[N_CPU];
	// From	L2 cache
	get_initiator<l2_rd_rsp_t>	*l2_rd_rsp_tb[N_CPU];
	get_initiator<l2_inval_t>       *l2_inval_tb[N_CPU];
	// LLC Debug
	sc_in< sc_bv<LLC_ASSERT_WIDTH> >   llc_asserts;
	sc_in< sc_bv<LLC_BOOKMARK_WIDTH> > llc_bookmark;
	sc_in<uint32_t>                    llc_custom_dbg;
	sc_in<bool>                        llc_tag_hit_out;
	sc_in<llc_way_t>                   llc_hit_way_out;
	sc_in<bool>                        llc_empty_way_found_out;
	sc_in<llc_way_t>                   llc_empty_way_out;
	sc_in<bool>                        llc_evict_out;
	sc_in<llc_way_t>                   llc_way_out;
	sc_in<llc_addr_t>                  llc_addr_out;
	// To LLC
	put_initiator<bool>                llc_rst_tb;
	// From LLC
	b_get_initiator<bool>              llc_rst_tb_done;

	// Constructor
	SC_CTOR(sys_tb)
		{
			// Process performing the test
			SC_CTHREAD(sys_test, clk.pos());
			reset_signal_is(rst, false);

			// Assign clock and reset to put_get ports
			for (int i = 0; i < N_CPU; i++) {
				std::stringstream stm;
				stm.str("");
				stm << "l2_cpu_req_tb_" << i;
				l2_cpu_req_tb[i] = new put_initiator<l2_cpu_req_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_flush_tb_" << i;
				l2_flush_tb[i] = new put_initiator<bool>(stm.str().c_str());
				stm.str("");
				stm << "l2_rd_rsp_tb_" << i;
				l2_rd_rsp_tb[i] = new get_initiator<l2_rd_rsp_t>(stm.str().c_str());
				stm.str("");
				stm << "l2_inval_tb_" << i;
				l2_inval_tb[i] = new get_initiator<l2_inval_t>(stm.str().c_str());

				l2_cpu_req_tb[i]->clk_rst(clk, rst);
				l2_flush_tb[i]->clk_rst(clk, rst);
				l2_rd_rsp_tb[i]->clk_rst(clk, rst);
				l2_inval_tb[i]->clk_rst(clk, rst);
			}
			llc_rst_tb.clk_rst(clk, rst);
			llc_rst_tb_done.clk_rst(clk, rst);
		}

	// Processes
	void sys_test();

	// Functions
	inline void reset_sys_test();

	void put_cpu_req(l2_cpu_req_t &cpu_req, cpu_msg_t cpu_msg, hsize_t hsize,
			 bool cacheable, addr_t addr, word_t word, bool rpt);
	void get_req_out(coh_msg_t coh_msg, addr_t addr, hprot_t hprot, bool rpt);
	void put_rsp_in(coh_msg_t coh_msg, addr_t addr, line_t line, bool rpt);
	void get_rd_rsp(addr_breakdown_t addr, line_t line, bool rpt);
	void get_inval(addr_t addr, bool rpt);
	void op(cpu_msg_t cpu_msg, sc_uint<2> beh, coh_msg_t put_msg, hsize_t hsize, bool cacheable, 
		addr_breakdown_t req_addr, word_t req_word, line_t rsp_line, bool rpt);
	void op_flush(coh_msg_t coh_msg, addr_t addr_line, bool rpt);
};


#endif /* __SYS_TB_HPP__ */


