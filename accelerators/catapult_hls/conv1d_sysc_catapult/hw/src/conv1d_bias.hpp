#ifndef _CONV1D_BIAS_HPP_
#define _CONV1D_BIAS_HPP_

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>
#include "../inc/conv1d_specs.hpp"
#include <ac_fixed.h>
#include <ac_math/ac_leakyrelu.h>

SC_MODULE(BiasEngine)
{
public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);
    
	Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_in_itcn);
    Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_bias_itcn);
	Connections::Out <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_out_itcn);
    Connections::In<act_mode_t> CCS_INIT_S1(act_mode_itcn);

    SC_HAS_PROCESS(BiasEngine);
    BiasEngine(const sc_module_name& name): 
        sc_module(name),
        clk("clk"), rst("rst"),
        data_in_itcn("data_in_itcn"),
        data_bias_itcn("data_bias_itcn"),
        data_out_itcn("data_out_itcn"),
        act_mode_itcn("act_mode_itcn")
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
        act_mode_itcn.Reset();

        wait();
        while(1)
        {
            array_t<FPDATA, VEC_LEN> in_buffer = data_in_itcn.Pop();
            array_t<FPDATA, VEC_LEN> bias_in_buffer = data_bias_itcn.Pop();
            uint32_t act_mode = act_mode_itcn.Pop().to_uint();
            array_t<FPDATA, VEC_LEN> out_buffer;

			#pragma hls_unroll yes            
			for (int vec=0; vec<VEC_LEN; vec++)
            {
                FPDATA val = in_buffer.data[vec] + bias_in_buffer.data[vec];
                switch (act_mode) {
                case CONV1D_ACT_RELU:
                    if (val < 0) {
                        val = FPDATA(0);
                    }
                    break;
                case CONV1D_ACT_LEAKY_RELU:{
                    ac_fixed<FPDATA_WL, FPDATA_IL> lrelu_in(val);
					ac_fixed<FPDATA_WL, FPDATA_IL> lrelu_out;
					ac_math::ac_leakyrelu(lrelu_in, lrelu_out, FPDATA(CONV1D_LEAKY_RELU_SLOPE));
					val = FPDATA(lrelu_out);
					break;
				}
                case CONV1D_ACT_BIAS_ONLY:
                default:
                    break;
                }
                out_buffer.data[vec] = val;
            }

            data_out_itcn.Push(out_buffer);
        }
    }
};

#endif
