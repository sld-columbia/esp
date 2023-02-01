// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MEMWRAP_HPP__
#define __MEMWRAP_HPP__

#pragma once

#include <systemc.h>
#include "<accelerator_name>_specs.hpp"
#include "<accelerator_name>_data_types.hpp"

template<unsigned int kNumBanks, unsigned int kNumReadPorts,unsigned int
         kNumWritePorts, unsigned int kEntriesPerBank, typename WordType,
         typename Address_type, typename DataWReq, typename DataRReq,
         typename DataRRsp>
class mem_wrap : public sc_module
{
    public:
    sc_in<bool> clk;
    sc_in<bool> rst;

    Connections::In<DataWReq>      write_req;
    Connections::In<DataRReq>      read_req;
    Connections::Out<DataRRsp>    read_rsp;

    Address_type    mem_read_addrs[kNumReadPorts];
    bool        mem_read_req_valid[kNumReadPorts];
    Address_type    mem_write_addrs[kNumWritePorts];
    bool        mem_write_req_valid[kNumWritePorts];
    WordType  mem_write_data[kNumWritePorts];
    bool        mem_read_ack[kNumReadPorts];
    bool        mem_write_ack[kNumWritePorts];
    bool        mem_read_ready[kNumReadPorts];
    WordType  mem_port_read_out[kNumReadPorts];
    bool        mem_port_read_out_valid[kNumReadPorts];

    SC_CTOR(mem_wrap) {

        SC_THREAD(mem_run);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

    }

    ArbitratedScratchpadDP<kNumBanks,
                           kNumReadPorts,
                           kNumWritePorts,
                           kEntriesPerBank,
                           WordType ,
                           false, false> mem;

    void mem_run() {
        write_req.Reset();
        read_req.Reset();
        read_rsp.Reset();

#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
        while(1){

            NVUINT2 valid_regs = 0;
            bool rsp = 0;
            DataRReq large_rreq_regs;
            DataWReq large_wreq_regs;
            valid_regs[0] = write_req.PopNB(large_wreq_regs);
            valid_regs[1] = read_req.PopNB(large_rreq_regs);

            if (valid_regs[0] !=0) {

#pragma hls_unroll yes
                for (int i=0; i<kNumWritePorts; i++)
                {
                    mem_write_addrs[i] = large_wreq_regs.indx[i];
                    mem_write_req_valid[i] = 1;
                    mem_write_data[i] = large_wreq_regs.data[i];
                }
            }

            if (valid_regs[1] !=0) {
                    rsp = 1;
#pragma hls_unroll yes
                for (int i=0; i<kNumReadPorts; i++)
                {
                    mem_read_addrs[i] = large_rreq_regs.indx[i];
                    mem_read_req_valid[i] = 1;
                    mem_read_ready[i] = 1;
                }
            }

            mem.run(
                mem_read_addrs          ,
                mem_read_req_valid      ,
                mem_write_addrs         ,
                mem_write_req_valid     ,
                mem_write_data          ,
                mem_read_ack            ,
                mem_write_ack           ,
                mem_read_ready          ,
                mem_port_read_out       ,
                mem_port_read_out_valid
                );

            if (rsp){
                DataRRsp  mem_rsp_reg;
                #pragma hls_unroll yes
                for (int i=0; i<kNumReadPorts; i++)
                    mem_rsp_reg.data[i] = mem_port_read_out[i];
                read_rsp.Push(mem_rsp_reg);
            }
            wait();
        }
    };
};

#endif
