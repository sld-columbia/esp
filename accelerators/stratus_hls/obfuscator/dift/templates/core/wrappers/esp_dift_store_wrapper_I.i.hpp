/* Copyright 2018 Columbia University, SLD Group */

#include "utils/esp_utils.hpp"

// -- Processes

template < size_t _DMA_WIDTH_ >
void esp_dift_store_wrapper_I<_DMA_WIDTH_>::store_output(void)
{
    dma_info_t info;
    uint32_t tag_off_pow;
    uint32_t tag_off;
    uint32_t mem_tags;
    uint32_t num_tags;
    uint32_t init_off;
    uint32_t counter;
    bool first;

    {
        HLS_DEFINE_PROTOCOL("dift-store-ctrl-reset");

        this->input_dma_write_ctrl.reset_get();
        this->input_dma_write_chnl.reset_get();

        this->output_dma_write_chnl.reset_put();
        this->output_dma_write_ctrl.reset_put();

        // Always valid in this case
        this->store_valid.write(true);

        tag_off_pow = 0;
        tag_off = 0;
        mem_tags = 0;
        num_tags = 0;
        init_off = 0;
        counter = 0;
        first = true;

        wait();
    }

    {
        while (true)
        {
            /// --- Handle the requests of the accelerator

            do
            {
                HLS_DEFINE_PROTOCOL("dift-store-nbcanget");
                wait();

            } while (!this->input_dma_write_ctrl.nb_can_get());

            this->input_dma_write_ctrl.nb_get(info); // valid

            if (first)
            {
                HLS_DEFINE_PROTOCOL("dift-store-tagoffset");

                // Note: we assume that the first index required by the
                // accelerator is the beginning of the input in memory
                tag_off_pow = 1ULL << this->tag_off.read();
                tag_off = this->tag_off.read();
                counter = tag_off_pow + 1;
                init_off = info.index;
                first = false;
            }

            /// --- Calculate how to adjust the write request

            // How many tags we have before the request in memory
            mem_tags = (info.index - init_off) >> tag_off;

            // How many tags we have in the current request burst
            num_tags = ((info.index + info.length - init_off)
                        >> tag_off) - mem_tags;

            // Adjust the write requests of the accelerator
            info.index  = info.index  + mem_tags;
            info.length = info.length + num_tags;

            {
                HLS_DEFINE_PROTOCOL("store-put-info");
                this->output_dma_write_ctrl.put(info);
            }

            /// --- Handle the requests of the accelerator

            sc_bv<_DMA_WIDTH_> tmp;

            for (uint32_t i = 0; i < info.length; ++i)
            {
                HLS_DEFINE_PROTOCOL("store-put-data");

                if (counter == 1)
                {
                    // The output data must be a tag
                    tmp = sc_bv<_DMA_WIDTH_>(this->tag.read());
                    counter = tag_off_pow + 1;
                }
                else
                {
                    // The output data must be a value
                    tmp = this->input_dma_write_chnl.get();
                    counter--;
                }

                this->output_dma_write_chnl.put(tmp);

                wait();
            }
        }
    }
}
