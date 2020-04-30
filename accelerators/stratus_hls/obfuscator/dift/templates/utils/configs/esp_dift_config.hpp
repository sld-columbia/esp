/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_CONFIG_HPP__
#define __ESP_DIFT_CONFIG_HPP__

#include "core/accelerators/esp_accelerator.hpp"
#include "core/wrappers/esp_dift_wrapper.hpp"

class esp_dift_config : public sc_module
{

    public:

        // Clock signal
        sc_in<bool> clk;

        // Reset signal
        sc_in<bool> rst;

        // -- Input ports

        // Wrapper start signal
        sc_in<bool> conf_done;

        // Wrapper configuration
        sc_in<conf_info_t> conf_info;

        // -- Output ports

        // Accelerator start signal
        sc_out<bool> acc_conf_done;

        // Accelerator configuration
        sc_out<conf_info_t> acc_conf_info;

        // -- Internal signals

        // Tag to check the input
        sc_signal<tag_t> src_tag;

        // Tag to check the output
        sc_signal<tag_t> dst_tag;

        // Distance between two tags
        sc_signal<tag_t> tag_off;

        // Signal to check if the conf is valid
        sc_out<bool> conf_valid;

        // Signal to connect accelerator/wrapper
        sc_signal<bool> sig_conf_done;

        // Signal to connect accelerator/wrapper
        sc_signal<conf_info_t> sig_conf_info;

        // -- Module constructor

        SC_HAS_PROCESS(esp_dift_config);
        esp_dift_config(const sc_module_name &name)
            : sc_module(name)
            , clk("clk")
            , rst("rst")
            , conf_done("conf_done")
            , conf_info("conf_info")
            , acc_conf_done("acc_conf_done")
            , acc_conf_info("acc_conf_info")
            , src_tag("src_tag")
            , dst_tag("dst_tag")
            , tag_off("tag_off")
            , conf_valid("conf_valid")
            , sig_conf_done("sig_conf_done")
            , sig_conf_info("sig_conf_info")
        {
            // Thread used to configure the wrapper
            SC_CTHREAD(config_wrapper, clk.pos());
            this->reset_signal_is(rst, false);
        }

        // -- Processes

        // Configure the wrapper
        virtual void config_wrapper() = 0;

        // -- Functions

        // Binding the wrapper
        template < size_t _DMA_WIDTH_ >
        inline void bind_with(esp_dift_wrapper<_DMA_WIDTH_> &wrap);
};

// Implementation
#include "esp_dift_config.i.hpp"

#endif // __ESP_DIFT_CONFIG_HPP__
