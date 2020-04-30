/* Copyright 2018 Columbia University, SLD Group */

#include "obfuscator.hpp"

// -- Functions

#include "obfuscator_functions.hpp"

// -- Processes

void obfuscator::load_input()
{
    uint32_t rem;
    uint32_t index;
    uint32_t length;
    uint32_t chunks;

    uint32_t num_rows;
    uint32_t num_cols;
    uint32_t ld_offset;

    uint8_t circ_buffer;

    // Reset

    {
        HLS_DEFINE_PROTOCOL("reset-load");

        this->reset_load_input();
        LOAD_INPUT_RESET_PORTS;

        rem = 0;
        index = 0;
        length = 0;
        chunks = 0;

        num_rows = 0;
        num_cols = 0;
        ld_offset = 0;

        circ_buffer = 0;

        wait();
    }

    // Config

    {
        HLS_DEFINE_PROTOCOL("config-load");

        cfg.wait_for_config();
        num_rows = this->conf_info.read().num_rows;
        num_cols = this->conf_info.read().num_cols;
        ld_offset = this->conf_info.read().ld_offset;
    }

    // Compute

    {
        // -- Calculate the total number of chunks
        calc_chunks(chunks, rem, DMA_CHUNK, num_cols);

        for (uint32_t chk = 0; chk < chunks; ++chk)
        {
            HLS_UNROLL_LOOP(OFF); // disabled

            // -- Length for this chunk
            length = (1 << DMA_CHUNK);

            // -- Index for this chunk
            index = ld_offset + length * chk;

            // -- Adjust index and length for padding
            adj_request(index, length, chk, chunks, rem);

            // ESP_REPORT_INFO("chunk %d -> length %d", chk, length);

            for (uint32_t row = 0; row < num_rows; ++row)
            {
                HLS_UNROLL_LOOP(OFF); // disabled

                // -- Load the data in the PLM via DMA
                load_data(circ_buffer, index, length);

                // -- Go to the next row of the image
                index = index + num_cols;

                // -- Handshake with compute
                load_compute_handshake();

                // -- Update circular buffer
                if (++circ_buffer > 3)
                   circ_buffer = 0;
            }
        }
    }

    // Conclude

    {
        this->process_done();
    }
}

void obfuscator::compute_kernel()
{
    uint32_t rem;
    uint32_t length;
    uint32_t chunks;

    uint32_t num_rows;
    uint32_t num_cols;

    uint32_t circ_buffer;

    bool pingpong;

    // Reset

    {
        HLS_DEFINE_PROTOCOL("reset-load");

        this->reset_compute_kernel();
        COMPUTE_KERNEL_RESET_PORTS;

        rem = 0;
        length = 0;
        chunks = 0;

        num_rows = 0;
        num_cols = 0;

        circ_buffer = 0;

        pingpong = false;

        wait();
    }

    // Config

    {
        HLS_DEFINE_PROTOCOL("config-load");

        cfg.wait_for_config();
        num_rows = this->conf_info.read().num_rows;
        num_cols = this->conf_info.read().num_cols;
   }

    // Compute

    {
        // -- Calculate the total number of chunks
        calc_chunks(chunks, rem, DMA_CHUNK, num_cols);

        for (uint32_t chk = 0; chk < chunks; ++chk)
        {
            HLS_UNROLL_LOOP(OFF); // disabled

            // -- Length for this chunk
            length = (1 << DMA_CHUNK);

            // -- Adjust the length of the last chunk
            if (chk == chunks - 1 && rem != 0)
               length = MAX(1, rem);

            // -- Pre-handshake with load to be sure
            //  to have three rows already loaded at
            //  the 2nd iteration of the "row loop"
            compute_load_handshake();

            for (uint32_t row = 0; row < num_rows; ++row)
            {
                HLS_UNROLL_LOOP(OFF); // disabled

                //-- Handshake with load
                if (row < num_rows - 1)
                    compute_load_handshake();

                // -- Call the kernel for obfuscation
                apply_sharpening(circ_buffer, pingpong, row,
                   chk, num_rows, chunks, length);

                // -- Handshake with store
                compute_store_handshake();

                // Update circular buffer
                if (++circ_buffer > 3)
                    circ_buffer = 0;

                // Update pingpong
                pingpong = !pingpong;
            }
        }
    }

    // Conclude

    {
        this->process_done();
    }
}

void obfuscator::store_output()
{
    uint32_t rem;
    uint32_t index;
    uint32_t length;
    uint32_t chunks;

    uint32_t tot_cols;
    uint32_t num_rows;
    uint32_t num_cols;
    uint32_t i_row_blur;
    uint32_t i_col_blur;
    uint32_t e_row_blur;
    uint32_t e_col_blur;
    uint32_t st_offset;

    bool pingpong;

    // Reset

    {
        HLS_DEFINE_PROTOCOL("reset-load");

        this->reset_store_output();
        STORE_OUTPUT_RESET_PORTS;

        rem = 0;
        index = 0;
        length = 0;
        chunks = 0;

        tot_cols = 0;
        num_rows = 0;
        num_cols = 0;
        i_row_blur = 0;
        i_col_blur = 0;
        e_row_blur = 0;
        e_col_blur = 0;
        st_offset = 0;

        pingpong = false;

        wait();
    }

    // Config

    {
        HLS_DEFINE_PROTOCOL("config-load");

        cfg.wait_for_config();
        num_rows = this->conf_info.read().num_rows;
        num_cols = this->conf_info.read().num_cols;
        st_offset = this->conf_info.read().st_offset;
        i_row_blur = this->conf_info.read().i_row_blur;
        i_col_blur = this->conf_info.read().i_col_blur;
        e_row_blur = this->conf_info.read().e_row_blur;
        e_col_blur = this->conf_info.read().e_col_blur;
    }

    // Compute

    {
        // -- Length for this chunk
        length = (1 << DMA_CHUNK);

        calc_chunks(chunks, rem, DMA_CHUNK, num_cols);

        for (uint32_t chk = 0; chk < chunks; ++chk)
        {
            HLS_UNROLL_LOOP(OFF); // disabled

            index = st_offset + length * chk;

            // The next one is the last chunk
            if (chk == chunks - 1 && rem != 0)
              { length = MAX(1, rem); }

            if (tot_cols >= i_col_blur && tot_cols < e_col_blur)
            {
                // ESP_REPORT_INFO("tot_cols is now %d", tot_cols);

                // ---- Unblurred rows

                for (uint32_t row = 0; row < i_row_blur; ++row)
                {
                    HLS_UNROLL_LOOP(OFF); // disabled

                    // -- Handshake with compute
                    store_compute_handshake();

                    // -- Store the unblurred data in the PLM via DMA
                    store_unblurred_data(pingpong, index, length);

                    // -- Go to the next row of the image
                    index = index + num_cols;

                    // -- Change pingpong buffer
                    pingpong = !pingpong;
                }

                // ---- Blurred rows

                for (uint32_t x = i_row_blur; x < e_row_blur; x += KERNEL_SIZE)
                {
                    HLS_UNROLL_LOOP(OFF); // disabled

                    // -- Reset array C before blurring
                    reset_before_blurring(length);

                    for (uint32_t row = x; (row < x + KERNEL_SIZE) &&
                            (row < e_row_blur); ++row)
                    {
                        HLS_UNROLL_LOOP(OFF); // disabled

                        // -- Handshake with compute
                        store_compute_handshake();

                        // -- Perform blurring on the image
                        apply_blurring(pingpong, length);

                        // Change pingpong buffer
                        pingpong = !pingpong;
                    }

                    for (uint32_t row = x; (row < x + KERNEL_SIZE) &&
                            (row < e_row_blur); ++row)
                    {
                        // Store data in the PLM via DMA
                        store_blurred_data(index, length);

                        // Go to the next row of the image
                        index = index + (num_cols);
                    }
                }

                // ---- Unblurred rows

                for (uint32_t x = e_row_blur; x < num_rows; x++)
                {
                    HLS_UNROLL_LOOP(OFF); // disabled

                    // -- Handshake with compute
                    store_compute_handshake();

                    // Store the data in the PLM via DMA
                    store_unblurred_data(pingpong, index, length);

                    // Go to the next row of the image
                    index = index + (num_cols);

                    // Change pingpong buffer
                    pingpong = !pingpong;
                }
            }
            else
            {
                // ---- Unblurred rows

                for (uint32_t x = 0; x < num_rows; x++)
                {
                    HLS_UNROLL_LOOP(OFF); // disabled

                    // -- Handshake with compute
                    store_compute_handshake();

                    // Store the data in the PLM via DMA
                    store_unblurred_data(pingpong, index, length);

                    // Go to the next row of the image
                    index = index + (num_cols);

                    // Change pingpong buffer
                    pingpong = !pingpong;
                }
            }

            // -- Cols processed
            tot_cols += (1 << DMA_CHUNK);
        }
    }

    // Conclude

    {
        this->accelerator_done();

        this->process_done();
    }
}
