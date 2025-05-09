// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __LEAKY_COM_H__
#define __LEAKY_COM_H__

#pragma once

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>
#include <string>
#include <mc_scverify.h>

#include "../inc/leakyrelu_data_types.h"
#include "../inc/leakyrelu_specs.h"
#include "../inc/leakyrelu_conf_info.h"

#include <ac_math/ac_leakyrelu.h>
using namespace ac_math;

SC_MODULE(LeakyreluEngine)
{
    public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);
    
	Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in_a);
	Connections::In <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in_b);
	Connections::Out <array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_out);

    SC_HAS_PROCESS(LeakyreluEngine);
    LeakyreluEngine(const sc_module_name& name): 
        sc_module(name),
        vec_in_a("vec_in_a"),
        vec_in_b("vec_in_b"),
        vec_out("vec_out")
    {
        SC_THREAD(Compute);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);
    }

    void Compute()
    {
        array_t<FPDATA, VEC_LEN> in_a_itcn, in_b_itcn, out_itcn;
        vec_in_a.Reset();
        vec_in_b.Reset();
        vec_out.Reset();

        FPDATA in_a[VEC_LEN], in_b[VEC_LEN], in[VEC_LEN], out[VEC_LEN];
        FPDATA_WORD in_word[VEC_LEN], out_word[VEC_LEN];
        ac_fixed<FPDATA_WL, FPDATA_IL> lrelu_in[VEC_LEN], lrelu_out[VEC_LEN];

        wait();
        while(1)
        {
            in_a_itcn = vec_in_a.Pop();
            in_b_itcn = vec_in_b.Pop();
            
            #pragma hls_unroll yes
            for (int vec=0; vec<VEC_LEN; vec++)
            {
                in_a[vec] = in_a_itcn.data[vec];
                in_b[vec] = in_b_itcn.data[vec];
                in[vec] = in_a[vec] + in_b[vec];


                lrelu_in[vec] = ac_fixed<FPDATA_WL, FPDATA_IL> (in[vec]);            
                ac_math::ac_leakyrelu(lrelu_in[vec], lrelu_out[vec], FPDATA(0.5));
                out[vec] = ac_fixed<FPDATA_WL, FPDATA_IL> (lrelu_out[vec]);            
    
                out_itcn.data[vec] = out[vec];
                
            }

            vec_out.Push(out_itcn);
        }
    }
};

#endif
