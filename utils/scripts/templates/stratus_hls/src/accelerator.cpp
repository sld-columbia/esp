// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "<accelerator_name>.hpp"
#include "<accelerator_name>_directives.hpp"

// Functions

#include "<accelerator_name>_functions.hpp"

// Processes

void <accelerator_name>::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();

        // PLM memories reset

        // User-defined reset code

        wait();
    }

    // Config
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
    }

    // Load
    {
        HLS_PROTO("load-dma");
        for (uint16_t b = 0; b < /* number of transfers */; b++)
        {

            dma_info_t dma_info;
            // Configure DMA transaction

            this->dma_read_ctrl.put(dma_info);

            for (uint16_t i = 0; i < /* transfer lenght */; i++)
            {

                uint32_t data = this->dma_read_chnl.get().to_uint();
                wait();
                // Write to PLM

            }
            this->load_compute_handshake();
        }
    }

    // Conclude
    {
        this->process_done();
    }
}



void <accelerator_name>::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();

        // PLM memories reset

        // User-defined reset code

        wait();
    }

    // Config
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
    }

    // Store
    {
        HLS_PROTO("store-dma");

        for (uint16_t b = 0; b < /* number of transfers */; b++)
        {

            this->store_compute_handshake();

            dma_info_t dma_info;
            // Configure DMA transaction

            this->dma_write_ctrl.put(dma_info);

            for (uint16_t i = 0; i < /* transfer lenght */; i++)
            {
                uint32_t data;
                wait();
                // Read from PLM

                this->dma_write_chnl.put(data);
            }
        }
    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void <accelerator_name>::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        // PLM memories reset

        // User-defined reset code

        wait();
    }

    // Config
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
    }


    // Compute
    {
        for (uint16_t b = 0; b < /* number of transfers */; b++)
        {
            this->compute_load_handshake();

            // Computing phase implementation

            this->compute_store_handshake();
        }

        // Conclude
        {
            this->process_done();
        }
    }
}
