/* Copyright 2018 Columbia University, SLD Group */

#ifndef __OBFUSCATOR_DIFT_HPP__
#define __OBFUSCATOR_DIFT_HPP__

#include "obfuscator_wrap.h"
#include "esp_dift_templates.hpp"

class obfuscator_dift : public esp_dift_wrapper<DMA_WIDTH>
{
    public:

        // -- Modules

        // Accelerator
        obfuscator_wrapper acc;

        // Config process
        esp_dift_config_proc cfg;

        // -- Module constructor

        SC_HAS_PROCESS(obfuscator_dift);
        obfuscator_dift(const sc_module_name &name)
            : esp_dift_wrapper<DMA_WIDTH>(name)
            , acc("obfuscator_accelerator")
            , cfg("esp_dift_config_proc")
        {
            // Choose the load wrapper
            this->load_wrapper = new esp_dift_load_wrapper_I<DMA_WIDTH>("load_wrapper");

            // Binding the load wrapper
            this->bind_load_wrapper(&cfg);

            // Choose the store wrapper
            this->store_wrapper = new esp_dift_store_wrapper_I<DMA_WIDTH>("store_wrapper");

            // Binding the store wrapper
            this->bind_store_wrapper(&cfg);

            // Binding the configuration
            cfg.bind_with<DMA_WIDTH>(*this);
            cfg.conf_valid(this->sig_conf_valid);

            // Binding the accelerator
            acc.clk(this->clk);
            acc.rst(this->rst);
            acc.conf_info(cfg.sig_conf_info);
            acc.conf_done(cfg.sig_conf_done);
            acc.dma_read_chnl(this->dift_read_chnl);
            acc.dma_read_ctrl(this->dift_read_ctrl);
            acc.dma_write_chnl(this->dift_write_chnl);
            acc.dma_write_ctrl(this->dift_write_ctrl);
            acc.acc_done(this->sig_acc_done);
            acc.debug(this->sig_debug);
        }

        // -- Module destructor

        ~obfuscator_dift()
        {
            delete this->load_wrapper;
            delete this->store_wrapper;
        }
};

#endif // __OBFUSCATOR_DIFT_HPP__
