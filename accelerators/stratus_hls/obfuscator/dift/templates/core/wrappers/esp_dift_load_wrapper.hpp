/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_LOAD_WRAPPER_HPP__
#define __ESP_DIFT_LOAD_WRAPPER_HPP__

#include "utils/esp_dift_utils.hpp"

#include "core/systems/esp_dma_info.hpp"

//
// Note: interface for the load wrappers.
//

template < size_t _DMA_WIDTH_ >
class esp_dift_load_wrapper : public sc_module
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

        // DMA read control
        nb_get_initiator<dma_info_t> output_dma_read_ctrl;

        // DMA read channel
        get_initiator<sc_dt::sc_bv<_DMA_WIDTH_> > input_dma_read_chnl;

        // -- Output ports

        // Tags are correct
        sc_out<bool> load_valid;

        // DMA read control
        b_put_initiator<dma_info_t> input_dma_read_ctrl;

        // DMA read channel
        b_put_initiator<sc_dt::sc_bv<_DMA_WIDTH_> > output_dma_read_chnl;

        // -- Module constructor

        SC_HAS_PROCESS(esp_dift_load_wrapper);
        esp_dift_load_wrapper(const sc_module_name &name)
            : sc_module(name)
            , clk("clk")
            , rst("rst")
            , tag("tag")
            , tag_off("tag_off")
            , output_dma_read_ctrl("output_dma_read_ctrl")
            , input_dma_read_chnl("input_dma_read_chnl")
            , load_valid("load_valid")
            , input_dma_read_ctrl("input_dma_read_ctrl")
            , output_dma_read_chnl("output_dma_read_chnl")
        {
            // Thread used to drive dma_read_ctrl
            SC_CTHREAD(load_input, clk.pos());
            this->reset_signal_is(rst, false);

            // Binding the clock and reset signals
            output_dma_read_ctrl.clk_rst(clk, rst);
            input_dma_read_chnl.clk_rst(clk, rst);
            input_dma_read_ctrl.clk_rst(clk, rst);
            output_dma_read_chnl.clk_rst(clk, rst);
        }

        // -- Processes

        // Double the read requests
        virtual void load_input() = 0;
};

#endif // __ESP_DIFT_LOAD_WRAPPER_HPP__
