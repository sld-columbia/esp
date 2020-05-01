/* Copyright 2018 Columbia University, SLD Group */

#include <cassert>

#include "utils/configs/esp_dift_config.hpp"

// -- Processes

template < size_t _DMA_WIDTH_ >
void esp_dift_wrapper<_DMA_WIDTH_>::drive_acc_done()
{
    {
        HLS_DEFINE_PROTOCOL("drive-acc-done-reset");

        acc_done.write(false);
        wait();
    }

    {
        while (true)
        {
            HLS_DEFINE_PROTOCOL("drive-acc-done-compute");

            if (sig_acc_done.read())
            {
                wait(); wait();

                wait(); acc_done.write(true);

                wait(); acc_done.write(false);

                do { wait(); } while (true);
            }
            else if (dift_error.read())
            {
                // DIFT exception

                wait(); acc_done.write(true);

                wait(); acc_done.write(false);

                do { wait(); } while (true);
            }

            wait();
        }
    }
}

template < size_t _DMA_WIDTH_ >
void esp_dift_wrapper<_DMA_WIDTH_>::drive_debug()
{
    {
        HLS_DEFINE_PROTOCOL("drive-debug-reset");

        debug.write(0);
        dift_error.write(false);

        wait();
    }

    {
        while (true)
        {
            HLS_DEFINE_PROTOCOL("drive-debug-compute");

            if (sig_debug.read() != 0)
            {
                debug.write(sig_debug.read());
            }
            else
            {
                if (!sig_conf_valid.read())
                {
                    // ESP_REPORT_INFO("dift: wrong register configuration");
                    debug.write(_DIFT_CONF_IS_INVALID_);
                    dift_error.write(true);
                }

                if (!sig_load_valid.read())
                {
                    // ESP_REPORT_INFO("dift: input data has been corrupted");
                    debug.write(_DIFT_LOAD_IS_INVALID_);
                    dift_error.write(true);
                }

                if (!sig_store_valid.read())
                {
                    // ESP_REPORT_INFO("dift: output data has been corrupted");
                    debug.write(_DIFT_STORE_IS_INVALID_);
                    dift_error.write(true);
                }
            }

            wait();
        }
    }
}

// -- Functions

template < size_t _DMA_WIDTH_ >
void esp_dift_wrapper<_DMA_WIDTH_>::bind_load_wrapper(esp_dift_config *cfg)
{
    assert(load_wrapper != NULL);

    load_wrapper->clk(this->clk);
    load_wrapper->rst(this->rst);
    load_wrapper->tag(cfg->src_tag);
    load_wrapper->tag_off(cfg->tag_off);
    load_wrapper->conf_info(this->conf_info);
    load_wrapper->input_dma_read_chnl(this->dma_read_chnl);
    load_wrapper->input_dma_read_ctrl(this->dma_read_ctrl);
    load_wrapper->output_dma_read_ctrl(this->dift_read_ctrl);
    load_wrapper->output_dma_read_chnl(this->dift_read_chnl);
    load_wrapper->load_valid(this->sig_load_valid);
}

template < size_t _DMA_WIDTH_ >
void esp_dift_wrapper<_DMA_WIDTH_>::bind_store_wrapper(esp_dift_config *cfg)
{
    assert(store_wrapper != NULL);

    store_wrapper->clk(this->clk);
    store_wrapper->rst(this->rst);
    store_wrapper->tag(cfg->dst_tag);
    store_wrapper->tag_off(cfg->tag_off);
    store_wrapper->conf_info(this->conf_info);
    store_wrapper->input_dma_write_chnl(this->dift_write_chnl);
    store_wrapper->input_dma_write_ctrl(this->dift_write_ctrl);
    store_wrapper->output_dma_write_ctrl(this->dma_write_ctrl);
    store_wrapper->output_dma_write_chnl(this->dma_write_chnl);
    store_wrapper->store_valid(this->sig_store_valid);
}
