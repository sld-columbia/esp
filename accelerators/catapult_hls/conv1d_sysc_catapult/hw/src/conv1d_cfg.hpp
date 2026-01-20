#ifndef _CONV1D_CFG_HPP_
#define _CONV1D_CFG_HPP_

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>

#include "../inc/conv1d_conf_info.hpp"
#include "../inc/conv1d_specs.hpp" // For DMA_WIDTH if needed

SC_MODULE(AccConfig)
{
public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);

    Connections::In<conf_info_t>    CCS_INIT_S1(conf_info);

    Connections::Out<conf_info_t>   CCS_INIT_S1(conf_info_dma2acc);
    Connections::Out<conf_info_t>   CCS_INIT_S1(conf_info_plm2vec);
    Connections::Out<conf_info_t>   CCS_INIT_S1(conf_info_acc2dma);

    SC_HAS_PROCESS(AccConfig);
    AccConfig(const sc_module_name& name) :
        sc_module(name),
        clk("clk"),
        rst("rst"),
        conf_info("conf_info"),
        conf_info_dma2acc("conf_info_dma2acc"),
        conf_info_plm2vec("conf_info_plm2vec"),
        conf_info_acc2dma("conf_info_acc2dma")
    {
        SC_THREAD(config_run);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);
    }

    void config_run()
    {
        conf_info.Reset();
        conf_info_dma2acc.Reset();
        conf_info_plm2vec.Reset();
        conf_info_acc2dma.Reset();

        wait();
        while (true)
        {
            conf_info_t config_data = conf_info.Pop();

            conf_info_dma2acc.Push(config_data);
            conf_info_plm2vec.Push(config_data);
            conf_info_acc2dma.Push(config_data);
        }
    }
};

#endif // _CONV1D_CFG_HPP_
