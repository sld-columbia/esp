#ifndef _CONV1D_HPP_
#define _CONV1D_HPP_

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>

#include "conv1d_conf_info.hpp"
#include "conv1d_specs.hpp"
#include "esp_dma_info_sysc.hpp" // For dma_info_t

#include "../src/conv1d_cfg.hpp"
#include "../src/conv1d_ctrl.hpp"
#include "../src/conv1d_vec.hpp"
#include "../src/conv1d_bias.hpp"

SC_MODULE(conv1d_sysc_catapult)
{
public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);
    sc_out<bool>    CCS_INIT_S1(acc_done);

    // External Interface 
    Connections::In<conf_info_t>            CCS_INIT_S1(conf_info);
    Connections::In<ac_int<DMA_WIDTH>>    CCS_INIT_S1(dma_read_chnl);
    Connections::Out<ac_int<DMA_WIDTH>>   CCS_INIT_S1(dma_write_chnl);
    Connections::Out<dma_info_t>            CCS_INIT_S1(dma_read_ctrl);
    Connections::Out<dma_info_t>            CCS_INIT_S1(dma_write_ctrl);

    // Internal Connections
    Connections::Combinational<conf_info_t> CCS_INIT_S1(conf_info_dma2acc);
    Connections::Combinational<conf_info_t> CCS_INIT_S1(conf_info_plm2vec);
    Connections::Combinational<conf_info_t> CCS_INIT_S1(conf_info_acc2dma);
    Connections::Combinational<act_mode_t>  CCS_INIT_S1(act_mode_itcn);

    // To VectorEngine
    Connections::Combinational<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in);
    Connections::Combinational<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_weight);
    Connections::Combinational<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_psum);
    Connections::Combinational<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_out);

    // To BiasEngine
    Connections::Combinational<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_in_bias);
    Connections::Combinational<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_bias);
    Connections::Combinational<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_out_bias);

    // Module Instantiations
    AccConfig       cfg_inst;
    AccController   ctrl_inst;
    VectorEngine    vec_inst;
    BiasEngine      bias_inst;

    SC_HAS_PROCESS(conv1d_sysc_catapult);
    conv1d_sysc_catapult(const sc_module_name& name):
        sc_module(name),
        clk("clk"), rst("rst"), acc_done("acc_done"),
        conf_info("conf_info"),
        dma_read_chnl("dma_read_chnl"), dma_write_chnl("dma_write_chnl"),
        dma_read_ctrl("dma_read_ctrl"), dma_write_ctrl("dma_write_ctrl"),
        cfg_inst("cfg_inst"),
        ctrl_inst("ctrl_inst"),
        vec_inst("vec_inst"),
        bias_inst("bias_inst")
    {
        // Connect AccConfig
        cfg_inst.clk(clk);
        cfg_inst.rst(rst);
        cfg_inst.conf_info(conf_info);
        cfg_inst.conf_info_dma2acc(conf_info_dma2acc);
        cfg_inst.conf_info_plm2vec(conf_info_plm2vec);
        cfg_inst.conf_info_acc2dma(conf_info_acc2dma);

        // Connect AccController
        ctrl_inst.clk(clk);
        ctrl_inst.rst(rst);
        ctrl_inst.acc_done(acc_done);
        ctrl_inst.dma_read_chnl(dma_read_chnl);
        ctrl_inst.dma_write_chnl(dma_write_chnl);
        ctrl_inst.dma_read_ctrl(dma_read_ctrl);
        ctrl_inst.dma_write_ctrl(dma_write_ctrl);
        
        ctrl_inst.conf_info_dma2acc(conf_info_dma2acc);
        ctrl_inst.conf_info_plm2vec(conf_info_plm2vec);
        ctrl_inst.conf_info_acc2dma(conf_info_acc2dma);

        ctrl_inst.vec_in_itcn(vec_in);
        ctrl_inst.vec_weight_itcn(vec_weight);
        ctrl_inst.vec_psum_itcn(vec_psum);
        ctrl_inst.vec_out_itcn(vec_out);
        ctrl_inst.data_in_bias_itcn(data_in_bias);
        ctrl_inst.data_bias_itcn(data_bias);
        ctrl_inst.data_out_bias_itcn(data_out_bias);
        ctrl_inst.act_mode_itcn(act_mode_itcn);

        // Connect VectorEngine
        vec_inst.clk(clk);
        vec_inst.rst(rst);
        vec_inst.vec_in(vec_in);
        vec_inst.vec_weight(vec_weight);
        vec_inst.vec_psum(vec_psum);
        vec_inst.vec_out(vec_out);

        // Connect BiasEngine
        bias_inst.clk(clk);
        bias_inst.rst(rst);
        bias_inst.data_in_itcn(data_in_bias);
        bias_inst.data_bias_itcn(data_bias);
        bias_inst.data_out_itcn(data_out_bias);
        bias_inst.act_mode_itcn(act_mode_itcn);
    }
};

#endif // _CONV1D_HPP_
