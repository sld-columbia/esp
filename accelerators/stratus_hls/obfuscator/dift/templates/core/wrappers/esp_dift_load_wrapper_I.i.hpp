/* Copyright 2018 Columbia University, SLD Group */

#include "utils/esp_utils.hpp"

// -- Processes

template < size_t _DMA_WIDTH_ >
void esp_dift_load_wrapper_I<_DMA_WIDTH_>::load_input(void)
{
    dma_info_t info;
    uint32_t tag_off_pow;
    uint32_t tag_off;
    uint32_t mem_tags;
    uint32_t num_tags;
    uint32_t init_off;
    uint32_t o_length;
    uint32_t counter;
    bool first;

    // Reset

    {
        HLS_DEFINE_PROTOCOL("dift-load-ctrl-reset");

        this->input_dma_read_ctrl.reset_put();
        this->input_dma_read_chnl.reset_get();

        this->output_dma_read_chnl.reset_put();
        this->output_dma_read_ctrl.reset_get();

        this->load_valid.write(true);

        tag_off_pow = 0;
        tag_off = 0;
        mem_tags = 0;
        num_tags = 0;
        init_off = 0;
        o_length = 0;
        counter = 0;
        first = true;

        wait();
    }

    // Compute

    {
        while (true)
        {
            /// --- Handle the requests of the accelerator

            do
            {
                HLS_DEFINE_PROTOCOL("dift-load-nbcanget");
                wait();

            } while (!this->output_dma_read_ctrl.nb_can_get());

            this->output_dma_read_ctrl.nb_get(info); // valid

            if (first)
            {
                HLS_DEFINE_PROTOCOL("dift-load-tagoffset");

                // Note: we assume that the first index required by the
                // accelerator is the beginning of the input in memory
                tag_off_pow = 1ULL << this->tag_off.read();
                tag_off = this->tag_off.read();
                init_off = info.index;
                first = false;
            }

            /// --- Calculate how to adjust the read request

            o_length = info.length; // save original length

            // How many tags we have before the request in memory
            mem_tags = (info.index - init_off) >> tag_off;

            // How many tags we have in the current request burst
            num_tags = ((info.index + info.length - init_off)
                        >> tag_off) - mem_tags;

            // Adjust the read requests of the accelerator
            info.index  = info.index  + mem_tags;
            info.length = info.length + num_tags;

            {
                HLS_DEFINE_PROTOCOL("load-get-info");
                this->input_dma_read_ctrl.put(info);
            }

            if (o_length >= tag_off_pow)
            {
                // The cases where we have > 1 tags
                counter = tag_off_pow + 1;
            }
            else
            {
                // The cases where we have 0 or 1 tag
                counter = o_length + 1;
            }

            /// --- Handle the requests of the accelerator

            sc_bv<_DMA_WIDTH_> tmp;

            for (uint32_t i = 0; i < info.length; ++i)
            {
                HLS_DEFINE_PROTOCOL("load-get-data");

                tmp = this->input_dma_read_chnl.get();

                if (counter == 1)
                {
                    /* ESP_REPORT_INFO("tag\n"); */
                    // The current input data is a tag
                    if (this->tag.read() != tmp)
                    {
                        // The tag is not the one expected
                        this->load_valid.write(false);
                    }

                    counter = tag_off_pow + 1;
                }
                else
                {
                    /* ESP_REPORT_INFO("val\n"); */
                    // The current input data is a value
                    this->output_dma_read_chnl.put(tmp);
                    counter--;
                }

                wait();
            }
        }
    }
}
