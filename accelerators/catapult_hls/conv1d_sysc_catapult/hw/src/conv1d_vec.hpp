#ifndef _CONV1D_VEC_HPP_
#define _CONV1D_VEC_HPP_

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>
#include "../inc/conv1d_specs.hpp"

SC_MODULE(VectorEngine)
{
public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);
    
	Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in);
	Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_weight);
	Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_psum);
	Connections::Out <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_out);

    SC_HAS_PROCESS(VectorEngine);
    VectorEngine(const sc_module_name& name): 
        sc_module(name),
        clk("clk"), rst("rst"),
        vec_in("vec_in"),
        vec_weight("vec_weight"),
        vec_psum("vec_psum"),
        vec_out("vec_out")
    {
        SC_THREAD(Compute);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);
    }

    void Compute()
    {
        vec_in.Reset();
        vec_weight.Reset();
        vec_psum.Reset();
        vec_out.Reset();
        
        wait();
		
        while(1)
        {
            array_t<FPDATA, VEC_LEN> in_itcn = vec_in.Pop();
            array_t<FPDATA, VEC_LEN> weight_itcn = vec_weight.Pop();
            array_t<FPDATA, VEC_LEN> psum_itcn = vec_psum.Pop();
            array_t<FPDATA, VEC_LEN> out_itcn;
			
			#pragma hls_unroll yes     
            for (int vec=0; vec<VEC_LEN; vec++)
            {
                out_itcn.data[vec] = psum_itcn.data[vec] + in_itcn.data[vec] * weight_itcn.data[vec];
            }

            vec_out.Push(out_itcn);
        }
    }
};

#endif