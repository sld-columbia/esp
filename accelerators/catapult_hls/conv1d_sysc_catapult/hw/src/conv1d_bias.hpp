#ifndef _CONV1D_BIAS_HPP_
#define _CONV1D_BIAS_HPP_

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>
#include "../inc/conv1d_specs.hpp"

SC_MODULE(BiasEngine)
{
public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);
    
	Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_in_itcn);
    Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_bias_itcn);
	Connections::Out <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_out_itcn);

    SC_HAS_PROCESS(BiasEngine);
    BiasEngine(const sc_module_name& name): 
        sc_module(name),
        clk("clk"), rst("rst"),
        data_in_itcn("data_in_itcn"),
        data_bias_itcn("data_bias_itcn"),
        data_out_itcn("data_out_itcn")
    {
        SC_THREAD(Activation);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);
    }

    void Activation()
    {
        data_in_itcn.Reset();
        data_bias_itcn.Reset();
        data_out_itcn.Reset();

        wait();
		
        while(1)
        {
            array_t<FPDATA, VEC_LEN> in_buffer = data_in_itcn.Pop();
            array_t<FPDATA, VEC_LEN> bias_in_buffer = data_bias_itcn.Pop();
            array_t<FPDATA, VEC_LEN> out_buffer;

			#pragma hls_unroll yes            
			for (int vec=0; vec<VEC_LEN; vec++)
            {
                FPDATA val = in_buffer.data[vec] + bias_in_buffer.data[vec];
                if (val < 0) {
                    val = val * FPDATA(0.3);
                }
                out_buffer.data[vec] = val;
            }

            data_out_itcn.Push(out_buffer);
        }
    }
};

#endif
