// Copyright (c) 2011-2025 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DPTOP_HPP__
#define __DPTOP_HPP__

#pragma once

// #include "./DataPath.hpp"
// #include "./Ctrl.hpp"

#include "macfin2_data_types.h"
#include "macfin2_specs.h"
#include "macfin2_conf_info.h"
#include "ac_shared_bank_array.h"


#define __round_mask(x, y) ((y)-1)
#define round_up(x, y)     ((((x)-1) | __round_mask(x, y)) + 1)


SC_MODULE(DataPath)
{
  public:
    sc_in<bool> CCS_INIT_S1(clk);
    sc_in<bool> CCS_INIT_S1(rst);

    Connections::In<conf_info_t> CCS_INIT_S1(conf_info_in);
    Connections::In<bool> CCS_INIT_S1(sync00);

    // Connections::In<ac_int<DMA_WIDTH>> CCS_INIT_S1(dma_read_chnl);
    // Connections::Out<ac_int<DMA_WIDTH>> CCS_INIT_S1(dma_write_chnl);
    // Connections::Out<dma_info_t> CCS_INIT_S1(dma_read_ctrl);
    // Connections::Out<dma_info_t> CCS_INIT_S1(dma_write_ctrl);

    Connections::Out<FPDATA_WORD> CCS_INIT_S1(in_wr_req);
    Connections::In<read_data> CCS_INIT_S1(in_rd_rsp);
    // Connections::Out<FPDATA_WORD> CCS_INIT_S1(out_wr_req);

    // Connections::Out<FPDATA_WORD> CCS_INIT_S1(out_ping_rd_rsp);
    // Connections::Out<FPDATA_WORD> CCS_INIT_S1(out_pong_rd_rsp);

    SC_CTOR(DataPath)
    {
        SC_THREAD(compute);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

    }

    void compute()
    {

	    sync00.Reset();
	    conf_info_in.Reset();

	    in_rd_rsp.Reset();
	    in_wr_req.Reset();

	    wait();

	    while (1) {

		    sync00.Pop();
		    conf_info_t conf = conf_info_in.Pop();

		    /* <<--local-params-->> */
		    uint32_t mac_n = conf.mac_n;
		    uint32_t mac_vec = conf.mac_vec;
		    uint32_t mac_len = conf.mac_len;

		    // Batching
		    for (uint16_t b = 0; b < mac_n; b++) {
			    wait();

			    uint32_t in_length = mac_vec*mac_len;

			    // Chunking
			    for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD) {

				    uint32_t in_len = in_rem > PLM_IN_WORD ? PLM_IN_WORD : in_rem;

// Compute Kernel

				    FPDATA acc_fx=0;
				    uint32_t vec_indx=0;
				    uint32_t vec_num=0;
				    uint32_t vec_idx=0;

#pragma hls_pipeline_init_interval 2
#pragma pipeline_stall_mode flush
				    for (uint32_t i=0; i < in_len; i+=2) {
					    // FPDATA_WORD op[2];
					    read_data op;
					    op = in_rd_rsp.Pop();

					    FPDATA op0_fx,op1_fx=0;
					    int2fx(op.data[0],op0_fx);
					    int2fx(op.data[1],op1_fx);
					    // Multiply and accumulate
					    acc_fx+=op0_fx * op1_fx;
					    vec_indx+=2;

					    // Write accumulated result
					    if (vec_indx == mac_len) {
						    FPDATA_WORD acc=0;
						    fx2int(acc_fx,acc);

						    in_wr_req.Push(acc);

						    vec_indx=0;
						    acc_fx=0;
					    }
				    }
// End Compute kernel
			    }
		    }
	    }
    }

};


#endif
