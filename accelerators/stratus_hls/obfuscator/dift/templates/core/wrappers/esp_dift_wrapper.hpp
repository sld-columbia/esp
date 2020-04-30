/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_WRAPPER_HPP__
#define __ESP_DIFT_WRAPPER_HPP__

// Forward declarations
class esp_dift_config;

#include "utils/esp_utils.hpp"

#include "core/accelerators/esp_accelerator.hpp"

#include "core/wrappers/esp_dift_load_wrapper.hpp"
#include "core/wrappers/esp_dift_store_wrapper.hpp"

#include "core/systems/esp_dma_info.hpp"

// Constants to flag errors in the debug port
const debug_info_t _DIFT_CONF_IS_INVALID_ = 1;
const debug_info_t _DIFT_LOAD_IS_INVALID_ = 2;
const debug_info_t _DIFT_STORE_IS_INVALID_ = 3;

template < size_t _DMA_WIDTH_ >
class esp_dift_wrapper : public sc_module
{
    public:

        // Clock signal
        sc_in<bool> clk;

        // Reset signal
        sc_in<bool> rst;

        // -- Input ports

        // DMA read channel
        hier_get_initiator<sc_dt::sc_bv<_DMA_WIDTH_> > dma_read_chnl;

        // Wrapper start signal
        sc_in<bool> conf_done;

        // Wrapper configuration
        sc_in<conf_info_t> conf_info;

        // -- Output ports

        // Wrapper complete
        sc_out<bool> acc_done;

        // Wrapper debug port
        sc_out<debug_info_t> debug;

        // DMA read control
        hier_put_initiator<dma_info_t> dma_read_ctrl;

        // DMA write control
        hier_put_initiator<dma_info_t> dma_write_ctrl;

        // DMA write channel
        hier_put_initiator<sc_dt::sc_bv<_DMA_WIDTH_> > dma_write_chnl;

        // -- Internal signals

        // Signal connected to 'debug' of the accelerator
        sc_signal<debug_info_t> sig_debug;

        // Signal connected to 'acc_done' of the accelerator
        sc_signal<bool> sig_acc_done;

        // Signal to check if the configuration is valid
        sc_signal<bool> sig_conf_valid;

        // Signal to check if the loaded data is valid
        sc_signal<bool> sig_load_valid;

        // Signal to check if the stored data is valid
        sc_signal<bool> sig_store_valid;

        // Signal to check if an error has occurred
        sc_signal<bool> dift_error;

        // -- Internal modules

        // Pointer to a process that handles the loading phase
        esp_dift_load_wrapper< _DMA_WIDTH_ > *load_wrapper;

        // Pointer to a process that handles the storing phase
        esp_dift_store_wrapper< _DMA_WIDTH_ > *store_wrapper;

        // -- Internal channels

        // DMA read control accelerator/wrapper
        put_get_channel< dma_info_t > dift_read_ctrl;

        // DMA write control accelerator/wrapper
        put_get_channel< dma_info_t > dift_write_ctrl;

        // DMA read channel accelerator/wrapper
        put_get_channel< sc_dt::sc_bv<_DMA_WIDTH_> > dift_read_chnl;

        // DMA write channel accelerator/wrapper
        put_get_channel< sc_dt::sc_bv<_DMA_WIDTH_> > dift_write_chnl;

        // -- Module constructor

        SC_HAS_PROCESS(esp_dift_wrapper);
        esp_dift_wrapper(const sc_module_name &name)
            : sc_module(name)
            , clk("clk")
            , rst("rst")
            , conf_done("conf_done")
            , conf_info("conf_info")
            , acc_done("acc_done")
            , debug("debug")
            , dma_read_ctrl("dma_read_ctrl")
            , dma_read_chnl("dma_read_chnl")
            , dma_write_ctrl("dma_write_ctrl")
            , dma_write_chnl("dma_write_chnl")
            , dift_read_ctrl("dift_read_ctrl")
            , dift_read_chnl("dift_read_chnl")
            , dift_write_ctrl("dift_write_ctrl")
            , dift_write_chnl("dift_write_chnl")
        {
            // Thread used to drive acc_done
            SC_CTHREAD(drive_acc_done, clk.pos());
            this->reset_signal_is(rst, false);

            // Thread used to drive debug
            SC_CTHREAD(drive_debug, clk.pos());
            this->reset_signal_is(rst, false);
        }

        // -- Processes

        // Drive the done signal
        void drive_acc_done();

        // Drive the debug signal
        void drive_debug();

        // -- Functions

        // Bind the load wrapper within this module
        void bind_load_wrapper(esp_dift_config *cfg);

        // Bind the store wrapper within this module
        void bind_store_wrapper(esp_dift_config *cfg);
};

// Implementation
#include "esp_dift_wrapper.i.hpp"

#endif // __ESP_DIFT_WRAPPER_HPP__
