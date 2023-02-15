// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "fft.hpp"
#include "fft_directives.hpp"

// Functions

#include "fft_functions.hpp"

// Processes

void fft::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    bool pingpong;
    int32_t len;
    int32_t log_len;
    int32_t batch_size;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        batch_size = config.batch_size;
        log_len = config.log_len;
        len = 1 << log_len;
        pingpong = 0;
    }

    // Load
    uint32_t offset = 0;
    for (int b = 0; b < batch_size; b++) {
        HLS_PROTO("load-dma");

        wait();
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t length = 2 * len;
#else
        uint32_t length = round_up(2 * len, DMA_WORD_PER_BEAT);
#endif

        wait();
        // Configure DMA transaction
#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, length * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
        dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, length / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
        offset += length;

        this->dma_read_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        for (uint16_t i = 0; i < length; i++)
        {
            sc_dt::sc_bv<DATA_WIDTH> dataBv;

            for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++)
            {
                dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH) = this->dma_read_chnl.get();
                wait();
            }

            // Write to PLM
            if (!pingpong)
                PLM_IN_PING[i] = dataBv.to_int64();
            else
                PLM_IN_PONG[i] = dataBv.to_int64();
        }
#else
        for (uint16_t i = 0; i < length; i += DMA_WORD_PER_BEAT)
        {
            HLS_BREAK_DEP(PLM_IN_PING);
            HLS_BREAK_DEP(PLM_IN_PONG);

            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            dataBv = this->dma_read_chnl.get();
            wait();

            // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                HLS_UNROLL_SIMPLE;
                if (!pingpong)
                    PLM_IN_PING[i + k] =
                        dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                else
                    PLM_IN_PONG[i + k] =
                        dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
            }
        }
#endif
        this->load_compute_handshake();
        pingpong = !pingpong;
    }

    // Conclude
    {
        this->process_done();
    }
}



void fft::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    bool pingpong;
    int32_t len;
    int32_t log_len;
    int32_t batch_size;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        batch_size = config.batch_size;
        log_len = config.log_len;
        len = 1 << log_len;
        pingpong = 0;
    }

    // Store
    uint32_t offset = 0;
    for (int b = 0; b < batch_size; b++) {
        HLS_PROTO("store-dma");
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = (2 * len) * 1;
#else
        uint32_t store_offset = round_up(2 * len, DMA_WORD_PER_BEAT) * 1;
#endif

        wait();
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t length = 2 * len;
#else
        uint32_t length = round_up(2 * len, DMA_WORD_PER_BEAT);
#endif
        this->store_compute_handshake();

        // Configure DMA transaction
#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, length * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
        dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, length / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
        offset += length;

        this->dma_write_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
        // data word is wider than NoC links
        for (uint16_t i = 0; i < length; i++)
        {
            // Read from PLM
            sc_dt::sc_int<DATA_WIDTH> data;
            wait();
            if (!pingpong)
                data = PLM_OUT_PING[i];
            else
                data = PLM_OUT_PONG[i];

            sc_dt::sc_bv<DATA_WIDTH> dataBv(data);

            uint16_t k = 0;
            for (k = 0; k < DMA_BEAT_PER_WORD - 1; k++)
            {
                this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                wait();
            }
            // Last beat on the bus does not require wait(), which is
            // placed before accessing the PLM
            this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
        }
#else
        for (uint16_t i = 0; i < length; i += DMA_WORD_PER_BEAT)
        {
            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            // Read from PLM
            wait();
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                HLS_UNROLL_SIMPLE;
                if (!pingpong)
                    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = PLM_OUT_PING[i + k];
                else
                    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = PLM_OUT_PONG[i + k];
            }
            this->dma_write_chnl.put(dataBv);
        }
#endif
        pingpong = !pingpong;
    }

// Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void fft::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    bool pingpong;
    bool do_peak;
    bool do_bitrev;
    int32_t len;
    int32_t log_len;
    int32_t batch_size;
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        batch_size = config.batch_size;
        log_len = config.log_len;
#ifndef STRATUS_HLS
        sc_assert(log_len < LOG_LEN_MAX);
#endif
        len = 1 << log_len;
        do_peak = config.do_peak;
        do_bitrev = config.do_bitrev;
        pingpong = 0;
    }

    // Compute FFT single pass (FIXME: assume vector fits in the PLM)
    for (int b = 0; b < batch_size; b++) {
        uint32_t length = 2 * len;
        this->compute_load_handshake();

        // Optional step: bit reverse
        if (do_bitrev)
            fft_bit_reverse(len, log_len, pingpong);

        // Computing phase implementation
        int m = 1;  // iterative FFT

    FFT_SINGLE_L1:
        for(unsigned s = 1; s <= log_len; s++) {

            m = 1 << s;
            CompNum wm(myCos(s), mySin(s));
            // printf("s: %d\n", s);
            // printf("wm.re: %.15g, wm.im: %.15g\n", wm.re, wm.im);

        FFT_SINGLE_L2:
            for(unsigned k = 0; k < len; k +=m) {

                CompNum w((FPDATA) 1, (FPDATA) 0);
                int md2 = m / 2;

            FFT_SINGLE_L3:
                for(int j = 0; j < md2; j++) {

                    int kj = k + j;
                    int kjm = k + j + md2;

                    CompNum akj, akjm;
                    CompNum bkj, bkjm;

                    if (!pingpong) {
                        akj.re = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PING[2 * kj]);
                        akj.im = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PING[2 * kj + 1]);
                        akjm.re = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PING[2 * kjm]);
                        akjm.im = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PING[2 * kjm + 1]);
                    } else {
                        akj.re = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PONG[2 * kj]);
                        akj.im = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PONG[2 * kj + 1]);
                        akjm.re = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PONG[2 * kjm]);
                        akjm.im = int2fp<FPDATA, WORD_SIZE>(PLM_IN_PONG[2 * kjm + 1]);
                    }

                    CompNum t;
                    compMul(w, akjm, t);
                    CompNum u(akj.re, akj.im);
                    compAdd(u, t, bkj);
                    compSub(u, t, bkjm);
                    CompNum wwm;
                    wwm.re = w.re - (wm.im * w.im + wm.re * w.re);
                    wwm.im = w.im + (wm.im * w.re - wm.re * w.im);
                    w = wwm;

                    {
                        HLS_CONSTRAIN_LATENCY(0, HLS_ACHIEVABLE);
                        //HLS_PROTO("compute_write_A0");
                        HLS_BREAK_DEP(PLM_IN_PING);
                        HLS_BREAK_DEP(PLM_IN_PONG);

                        if (!pingpong) {
                            wait();
                            PLM_IN_PING[2 * kj] = fp2int<FPDATA, WORD_SIZE>(bkj.re);
                            PLM_IN_PING[2 * kj + 1] = fp2int<FPDATA, WORD_SIZE>(bkj.im);
                            wait();
                            PLM_IN_PING[2 * kjm] = fp2int<FPDATA, WORD_SIZE>(bkjm.re);
                            PLM_IN_PING[2 * kjm + 1] = fp2int<FPDATA, WORD_SIZE>(bkjm.im);
                        } else {
                            wait();
                            PLM_IN_PONG[2 * kj] = fp2int<FPDATA, WORD_SIZE>(bkj.re);
                            PLM_IN_PONG[2 * kj + 1] = fp2int<FPDATA, WORD_SIZE>(bkj.im);
                            wait();
                            PLM_IN_PONG[2 * kjm] = fp2int<FPDATA, WORD_SIZE>(bkjm.re);
                            PLM_IN_PONG[2 * kjm + 1] = fp2int<FPDATA, WORD_SIZE>(bkjm.im);
                        }

                        // cout << "DFT: A0 " << kj << ": " << A0[kj].re.to_hex() << " " << A0[kj].im.to_hex() << endl;
                        // cout << "DFT: A0 " << kjm << ": " << A0[kjm].re.to_hex() << " " << A0[kjm].im.to_hex() << endl;
                    }
                }
            }
        }

        for (int p = 0; p < len*2; p++) {
            HLS_BREAK_DEP(PLM_IN_PING);
            HLS_BREAK_DEP(PLM_IN_PONG);
            HLS_BREAK_DEP(PLM_OUT_PING);
            HLS_BREAK_DEP(PLM_OUT_PONG);

            if (!pingpong)
                PLM_OUT_PING[p] = PLM_IN_PING[p];
            else
                PLM_OUT_PONG[p] = PLM_IN_PONG[p];
        }

        pingpong = !pingpong;

        this->compute_store_handshake();
    }

    // Conclude
    {
        this->process_done();
    }

}
