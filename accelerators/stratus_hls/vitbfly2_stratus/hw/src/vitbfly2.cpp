// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "vitbfly2.hpp"
#include "vitbfly2_directives.hpp"

// Functions

#include "vitbfly2_functions.hpp"

// Processes

void vitbfly2::load_input()
{

    // Reset
    {
        HLS_DEFINE_PROTOCOL("load-reset");

        this->reset_load_input();

        // User-defined reset code

        wait();
    }

    // // PLM memories reset
    // for (int i = 0; i < 64; i++) {
    //     symbols[i] = 0;
    //     mm0[i] = 0;
    //     mm1[i] = 0;
    //     pp0[i] = 0;
    //     pp1[i] = 0;
    //     d_brtab27[i] = 0;
    // }


    // Config
    {
        HLS_DEFINE_PROTOCOL("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
    }

    // Load
    {
        HLS_DEFINE_PROTOCOL("load-dma");

        uint32_t dma_addr = 0;
        //for (uint16_t b = 0; b < /* number of transfers */; b++)
        {
            dma_info_t dma_info(dma_addr, 6 * 64 / WORDS_PER_DMA, SIZE_BYTE);
            // Configure DMA transaction
            this->dma_read_ctrl.put(dma_info);

            for (uint16_t j = 0; j < 6; j++)
                for (uint16_t i = 0; i < 64; i += WORDS_PER_DMA)
                {
                    wait();
                    sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();
                    switch(j) {
                    case 0:
                        for (int k = 0; k < WORDS_PER_DMA; k++) {
                            HLS_UNROLL_LOOP_SIMPLE;
                            mm0[i + k] = data.range(((k + 1) << 3) - 1, k << 3).to_uint();
                        }
                        break;

                    case 1:
                        for (int k = 0; k < WORDS_PER_DMA; k++) {
                            HLS_UNROLL_LOOP_SIMPLE;
                            mm1[i + k] = data.range(((k + 1) << 3) - 1, k << 3).to_uint();
                        }
                        break;

                    case 2:
                        for (int k = 0; k < WORDS_PER_DMA; k++) {
                            HLS_UNROLL_LOOP_SIMPLE;
                            pp0[i + k] = data.range(((k + 1) << 3) - 1, k << 3).to_uint();
                        }
                        break;

                    case 3:
                        for (int k = 0; k < WORDS_PER_DMA; k++) {
                            HLS_UNROLL_LOOP_SIMPLE;
                            pp1[i + k] = data.range(((k + 1) << 3) - 1, k << 3).to_uint();
                        }
                        break;

                    case 4:
                        for (int k = 0; k < WORDS_PER_DMA; k++) {
                            HLS_UNROLL_LOOP_SIMPLE;
                            unsigned index = i % 32;
                            if (i < 32)
                                d_brtab27[0][index + k] = data.range(((k + 1) << 3) - 1, k << 3).to_uint();
                            else
                                d_brtab27[1][index + k] = data.range(((k + 1) << 3) - 1, k << 3).to_uint();
                        }
                        break;

                    case 5:
                        for (int k = 0; k < WORDS_PER_DMA; k++) {
                            HLS_UNROLL_LOOP_SIMPLE;
                            symbols[i + k] = data.range(((k + 1) << 3) - 1, k << 3).to_uint();
                        }
                        break;

                    default:
                        break;

                    }
                }
            this->load_compute_handshake();
        }
    }

    // Conclude
    {
        this->process_done();
    }
}



void vitbfly2::store_output()
{
    // Reset
    {
        HLS_DEFINE_PROTOCOL("store-reset");

        this->reset_store_output();

        // PLM memories reset

        // User-defined reset code

        wait();
    }

    // Config
    {
        HLS_DEFINE_PROTOCOL("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
    }

    // Store
    uint32_t dma_addr = 0;
    {
        HLS_DEFINE_PROTOCOL("store-dma-conf");

        this->store_compute_handshake();

        dma_info_t dma_info(dma_addr, 4 * 64 / WORDS_PER_DMA, SIZE_BYTE);
        // Configure DMA transaction

        this->dma_write_ctrl.put(dma_info);

        for (uint16_t j = 0; j < 4; j++)
            for (uint16_t i = 0; i < 64; i += WORDS_PER_DMA)
            {
                wait();
                sc_dt::sc_bv<DMA_WIDTH> data;

                switch(j) {
                case 0:
                    for (int k = 0; k < WORDS_PER_DMA; k++) {
                        HLS_UNROLL_LOOP_SIMPLE;
                        data.range(((k + 1) << 3) - 1, k << 3) = sc_bv<8>(mm0[i + k]);
                    }
                    break;

                case 1:
                    for (int k = 0; k < WORDS_PER_DMA; k++) {
                        HLS_UNROLL_LOOP_SIMPLE;
                        data.range(((k + 1) << 3) - 1, k << 3) = sc_bv<8>(mm1[i + k]);
                    }
                    break;

                case 2:
                    for (int k = 0; k < WORDS_PER_DMA; k++) {
                        HLS_UNROLL_LOOP_SIMPLE;
                        data.range(((k + 1) << 3) - 1, k << 3) = sc_bv<8>(pp0[i + k]);
                    }
                    break;

                case 3:
                    for (int k = 0; k < WORDS_PER_DMA; k++) {
                        HLS_UNROLL_LOOP_SIMPLE;
                        data.range(((k + 1) << 3) - 1, k << 3) = sc_bv<8>(pp1[i + k]);
                    }
                    break;

                }

                this->dma_write_chnl.put(data);

            }
    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void vitbfly2::compute_kernel()
{
    // Reset
    {
        HLS_DEFINE_PROTOCOL("compute-reset");

        this->reset_compute_kernel();

        // PLM memories reset

        // User-defined reset code

        wait();
    }

    // Config
    {
        HLS_DEFINE_PROTOCOL("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
    }


    // Compute
    {
        this->compute_load_handshake();

        // Computing phase implementation
        viterbi_butterfly2_generic();

        this->compute_store_handshake();

        // Conclude
        {
            this->process_done();
        }
    }
}
