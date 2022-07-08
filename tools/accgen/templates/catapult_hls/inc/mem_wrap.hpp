/* Copyright 2021 Columbia University SLD Group */

#ifndef MEMWRAP_H
#define MEMWRAP_H

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

    Address_type    mem1_read_addrs[kNumReadPorts];
    bool        mem1_read_req_valid[kNumReadPorts];
    Address_type    mem1_write_addrs[kNumWritePorts];
    bool        mem1_write_req_valid[kNumWritePorts];
    WordType  mem1_write_data[kNumWritePorts];
    bool        mem1_read_ack[kNumReadPorts];
    bool        mem1_write_ack[kNumWritePorts];
    bool        mem1_read_ready[kNumReadPorts];
    WordType  mem1_port_read_out[kNumReadPorts];
    bool        mem1_port_read_out_valid[kNumReadPorts];

    SC_CTOR(mem_wrap) {
        SC_THREAD(mem1_run);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

        }

    ArbitratedScratchpadDP<kNumBanks,      
                           kNumReadPorts,  
                           kNumWritePorts, 
                           kEntriesPerBank, 
                           WordType , 
                           false, false> mem1;           

    void mem1_run() {
        write_req.Reset();
        read_req.Reset();
        read_rsp.Reset();

#pragma hls_pipeline_init_interval 1
#pragma pipeline_stall_mode flush
        while(1){

            NVUINT2 valid_regs = 0;
            NVUINT4 rsp_mode = 0;

            DataRReq large_rreq_regs;
            DataWReq large_wreq_regs;
            valid_regs[0] = write_req.PopNB(large_wreq_regs);
            valid_regs[1] = read_req.PopNB(large_rreq_regs);

            if (valid_regs[0] !=0) {

#pragma hls_unroll yes
                for (int i=0; i<kNumWritePorts; i++)
                {
                    mem1_write_addrs[i] = large_wreq_regs.indx[i];
                    mem1_write_req_valid[i] = 1;
                    mem1_write_data[i] = large_wreq_regs.data[i];
                }
            }

            if (valid_regs[1] !=0) {
                    rsp_mode = 0x1;
#pragma hls_unroll yes
                for (int i=0; i<kNumReadPorts; i++)
                {
                    mem1_read_addrs[i] = large_rreq_regs.indx[i];
                    mem1_read_req_valid[i] = 1;
                    mem1_read_ready[i] = 1;
                }
            }

            mem1.run(
                mem1_read_addrs          ,
                mem1_read_req_valid      ,
                mem1_write_addrs         ,
                mem1_write_req_valid     ,
                mem1_write_data          ,
                mem1_read_ack            ,
                mem1_write_ack           ,
                mem1_read_ready          ,
                mem1_port_read_out       ,
                mem1_port_read_out_valid
                );

            switch (rsp_mode) {
            case 0x1: {
                DataRRsp  mem1_rsp_reg;
#pragma hls_unroll yes
                for (int i=0; i<kNumReadPorts; i++)
                    mem1_rsp_reg.data[i] = mem1_port_read_out[i];
                read_rsp.Push(mem1_rsp_reg);
                break;
            }
            default: {
                break;
            }
            }
            wait();
        }
    };


};


#endif 
