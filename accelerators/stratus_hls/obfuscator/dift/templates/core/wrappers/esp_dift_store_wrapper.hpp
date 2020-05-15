/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_STORE_WRAPPER_HPP__
#define __ESP_DIFT_STORE_WRAPPER_HPP__

#include "utils/esp_utils.hpp"

#include "core/systems/esp_dma_info.hpp"

//
// Note: interface for the store wrappers.
//

template < size_t _DMA_WIDTH_ >
class esp_dift_store_wrapper : public sc_module
{
    public:

        // Clock signal
        sc_in<bool> clk;

        // Reset signal
        sc_in<bool> rst;

        // -- Input ports

        // Tag for checking
        sc_in<tag_t> tag;

        // Log of the tag offset
        sc_in<uint32_t> tag_off;

        // Wrapper configuration
        sc_in<conf_info_t> conf_info;

        // DMA write control
        nb_get_initiator<dma_info_t> input_dma_write_ctrl;

        // DMA write channel
        b_get_initiator<sc_dt::sc_bv<_DMA_WIDTH_> > input_dma_write_chnl;

        // -- Output ports

        sc_in<bool> load_valid;

        // Tags are correct
        sc_out<bool> store_valid;

        // DMA write control
        b_put_initiator<dma_info_t> output_dma_write_ctrl;

        // DMA write channel
        put_initiator<sc_dt::sc_bv<_DMA_WIDTH_> > output_dma_write_chnl;

        // -- Module constructor

        SC_HAS_PROCESS(esp_dift_store_wrapper);
        esp_dift_store_wrapper(const sc_module_name &name)
            : sc_module(name)
            , clk("clk")
            , rst("rst")
            , tag("tag")
            , tag_off("tag_off")
            , conf_info("conf_info")
            , input_dma_write_ctrl("input_dma_write_ctrl")
            , input_dma_write_chnl("input_dma_write_chnl")
            , load_valid("load_valid")
            , store_valid("store_valid")
            , output_dma_write_ctrl("output_dma_write_ctrl")
            , output_dma_write_chnl("output_dma_write_chnl")
        {
            // Thread used to drive dma_write_ctrl
            SC_CTHREAD(store_output, clk.pos());
            this->reset_signal_is(rst, false);

            // Binding the clock and reset signals
            input_dma_write_ctrl.clk_rst(clk, rst);
            input_dma_write_chnl.clk_rst(clk, rst);
            output_dma_write_ctrl.clk_rst(clk, rst);
            output_dma_write_chnl.clk_rst(clk, rst);
        }

        // -- Processes

        // Double the write requests
        virtual void store_output() = 0;
};

#endif // __ESP_DIFT_STORE_WRAPPER_HPP__
