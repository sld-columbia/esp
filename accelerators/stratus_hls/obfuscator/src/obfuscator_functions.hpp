/* Copyright 2018 Columbia University, SLD Group */

#ifndef __OBFUSCATOR_FUNCTIONS_HPP__
#define __OBFUSCATOR_FUNCTIONS_HPP__

// Some utilities

#define MAX(x, y) (((x) < (y)) ? (y) : (x))

FPDATA_WORD multiply_by_5(FPDATA_WORD val)
{
    sc_int<35> val1 = val;
    sc_int<35> val2 = sc_int<35>(5)
        << (sc_uint<35>) FPDATA_PL;
    return FPDATA_WORD(((val1 * val2) >> FPDATA_PL));
}

// Computational Kernels

void obfuscator::apply_blurring(bool pingpong, uint32_t length)
{
    FPDATA_WORD val;
    FPDATA_WORD max;

    for (uint32_t y = 0; y < length; y += KERNEL_SIZE)
    {
        HLS_UNROLL_LOOP(OFF); // disabled

        max = PLM_C0.port2[0][y >> KERNEL_SIZE_LOG];

        for (uint32_t iy = y; (iy < y + KERNEL_SIZE)
                && (iy < length); ++iy)
        {
            HLS_UNROLL_LOOP(OFF); // disabled

            if (pingpong)
            {
                val = PLM_B0.port2[0][iy];
            }
            else // if (!pingpong)
            {
                val = PLM_B1.port2[0][iy];
            }

            // if (row == 75)
            // {
            //     ESP_REPORT_INFO("val[%d] is: %lf", iy,
            //       bv2fp<FPDATA, 32>(val).to_double());
            // }

            if (val > max)
            {
                max = val;
            }
        }

        PLM_C0.port1[0][y >> KERNEL_SIZE_LOG] = max;
    }
}

void obfuscator::apply_sharpening(uint32_t circ_buffer,
        bool pingpong, uint32_t row, uint32_t chk, uint32_t
        num_rows, uint32_t chunks, uint32_t length)
{
    FPDATA_WORD val;
    FPDATA_WORD val1;
    FPDATA_WORD val2;
    FPDATA_WORD val3;
    FPDATA_WORD val4;
    FPDATA_WORD val5;

#define READ_VALS_FROM(A0, A1, A2) \
    val1 = A1.port2[0][col + 0];   \
    val2 = A0.port2[0][col + 0];   \
    val3 = A2.port2[0][col + 0];   \
    val4 = A1.port2[0][col - 1];   \
    val5 = A1.port2[0][col + 1]

    uint32_t init = (chk != 0) ? 1: 0;
    uint32_t last = ((chk != 0)) ? 1 : 0;

    // { ESP_REPORT_INFO("-- init %d last %d length %d", init, last, length); }

    for (uint32_t col = init; col < length + last; ++col)
    {
        HLS_UNROLL_LOOP(OFF); // disabled

        if ((row != 0) && (row != num_rows - 1) && (col != 0) &&
            (chk != chunks - 1 || col != length + last - 1))
        {
            // { ESP_REPORT_INFO("(true) row %d col %d", row, col); }

            if (circ_buffer == 0)
            {
                READ_VALS_FROM(PLM_A3, PLM_A0, PLM_A1);
            }
            else if (circ_buffer == 1)
            {
                READ_VALS_FROM(PLM_A0, PLM_A1, PLM_A2);
            }
            else if (circ_buffer == 2)
            {
                READ_VALS_FROM(PLM_A1, PLM_A2, PLM_A3);
            }
            else // if (circ_buffer == 3)
            {
                READ_VALS_FROM(PLM_A2, PLM_A3, PLM_A0);
            }

            val = multiply_by_5(val1) -
              val2 - val3 - val4 - val5;

            // { ESP_REPORT_INFO(" -----     => %lf",
            //    bv2fp<FPDATA, 32>(val1).to_double());
            // ESP_REPORT_INFO(" -----     => %lf",
            //    bv2fp<FPDATA, 32>(val2).to_double());
            // ESP_REPORT_INFO(" -----     => %lf",
            //    bv2fp<FPDATA, 32>(val3).to_double());
            // ESP_REPORT_INFO(" -----     => %lf",
            //    bv2fp<FPDATA, 32>(val4).to_double());
            // ESP_REPORT_INFO(" -----     => %lf",
            //    bv2fp<FPDATA, 32>(val5).to_double()); }


        } else { /* all the middle rows */

            // { ESP_REPORT_INFO("(false) row %d col %d", row, col); }

            if (circ_buffer == 0)
            {
                val = PLM_A0.port2[0][col];
            }
            else if (circ_buffer == 1)
            {
                val = PLM_A1.port2[0][col];
            }
            else if (circ_buffer == 2)
            {
                val = PLM_A2.port2[0][col];
            }
            else // if (circ_buffer == 3)
            {
                val = PLM_A3.port2[0][col];
            }

        }

        // { ESP_REPORT_INFO("output[%d] => %lf (%d)", col - init,
        //    bv2fp<FPDATA, 32>(val).to_double(), pingpong); }

        if (pingpong)
        {
            PLM_B0.port1[0][col - init] = val;
        }
        else // if (!pingpong)
        {
            PLM_B1.port1[0][col - init] = val;
        }
    }
}

// -- Functions

void obfuscator::reset_before_blurring(uint32_t length)
{
    for (uint32_t y = 0; y < length; y += KERNEL_SIZE)
    {
        HLS_UNROLL_LOOP(OFF); // disabled

        PLM_C0.port1[0][y >> KERNEL_SIZE_LOG] = 0;
    }
}

void obfuscator::calc_chunks(uint32_t &chunks, uint32_t
        &rem, uint32_t dma_chunk, uint32_t num_cols)
{
    // Calculate the number of chunks
    chunks = num_cols >> dma_chunk;

    // Calculate the length of the last chunk
    rem = num_cols - (chunks << dma_chunk);

    // Check if it is needed an additional chunk
    chunks = chunks + ((rem != 0) ? 1 : 0);
}

void obfuscator::adj_request(uint32_t &index, uint32_t
        &length, uint32_t chk, uint32_t chunks, uint32_t rem)
{
    if (chk == 0)
    {
        // First chunk needs to include
        // 1 value from the next chunk
        index += 0;
        length += 1;
    }
    else if (chk == chunks - 1)
    {
        // Last chunk needs to include
        // 1 value from the previous chunk
        index -= 1;
        if (rem != 0)
            length = MAX(1, rem);
        length += 1;
    }
    else // is a middle chunk
    {
        // Middle chunks must include 1 value from the
        // previous chunk and 1 value from the next one
        index -= 1;
        length += 2;
    }
}

void obfuscator::load_data(uint8_t circ_buffer, uint32_t index, uint32_t length)
{
    sc_bv<DMA_WIDTH> data;

    {
        HLS_DEFINE_PROTOCOL("load-put-info");

        dma_info_t dma_info(index, length, DMA_SIZE);
        this->dma_read_ctrl.put(dma_info);
    }

    for (uint32_t col = 0; col < length; ++col)
    {
        HLS_UNROLL_LOOP(OFF); // disabled

        {
            data = this->dma_read_chnl.get();

            if (circ_buffer == 0)
            {
                PLM_A0.port1[0][col] = data.to_uint();
            }
            else if (circ_buffer == 1)
            {
                PLM_A1.port1[0][col] = data.to_uint();
            }
            else if (circ_buffer == 2)
            {
                PLM_A2.port1[0][col] = data.to_uint();
            }
            else // if (circ_buffer == 3)
            {
                PLM_A3.port1[0][col] = data.to_uint();
            }

            // ESP_REPORT_INFO(" -- read %lf ", int2fp<FPDATA, 32>(
            //            data.to_uint()).to_double());

            wait(); // behavioral only
        }
    }
}

void obfuscator::store_unblurred_data(bool pingpong,
        uint32_t index, uint32_t length)
{
    sc_bv<DMA_WIDTH> data;

    {
        HLS_DEFINE_PROTOCOL("load-put-info");

        dma_info_t dma_info(index, length, DMA_SIZE);
        this->dma_write_ctrl.put(dma_info);
    }

    for (uint32_t col = 0; col < length; ++col)
    {
        HLS_UNROLL_LOOP(OFF); // disabled

        if (pingpong)
        {
            data = sc_bv<DMA_WIDTH>(PLM_B0.port2[0][col]);
        }
        else
        {
            data = sc_bv<DMA_WIDTH>(PLM_B1.port2[0][col]);
        }

        this->dma_write_chnl.put(data);

        // ESP_REPORT_INFO(" -- write %d unblurred %lf ", col,
        //     int2fp<FPDATA, 32>(data.to_uint()).to_double());

        wait(); // behavioral only
    }
}

void obfuscator::store_blurred_data(uint32_t index, uint32_t length)
{
    sc_bv<DMA_WIDTH> data;

    {
        HLS_DEFINE_PROTOCOL("load-put-info");

        dma_info_t dma_info(index, length, DMA_SIZE);
        this->dma_write_ctrl.put(dma_info);
    }

    for (uint32_t y = 0; y < length; y += KERNEL_SIZE)
    {
        HLS_UNROLL_LOOP(OFF); // disabled

        data = sc_bv<DMA_WIDTH>(PLM_C0.port2[0][y >> KERNEL_SIZE_LOG]);

        for (uint32_t iy = y; (iy < y + KERNEL_SIZE) && iy < length; ++iy)
        {
            HLS_UNROLL_LOOP(OFF); // disabled

            this->dma_write_chnl.put(data);

            // ESP_REPORT_INFO(" -- write %d blurred %lf ", iy,
            //    int2fp<FPDATA, 32>(data.to_uint()).to_double());

            wait(); // behavioral only
        }
    }
}

#endif // __OBFUSCATOR_FUNCTIONS_HPP__
