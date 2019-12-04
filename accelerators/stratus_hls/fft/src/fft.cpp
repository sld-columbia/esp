// Copyright (c) 2011-2019 Columbia University, System Level Design Group
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
    int32_t len;
    int32_t log_len;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        len = config.len;
        log_len = config.log_len;
    }

    // Load
    {
        HLS_PROTO("load-dma");
        uint32_t offset = 0;

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
            A0[i] = dataBv.to_int64();
        }
#else
        for (uint16_t i = 0; i < length; i += DMA_WORD_PER_BEAT)
        {
            HLS_BREAK_DEP(A0);

            sc_dt::sc_bv<DMA_WIDTH> dataBv;

            dataBv = this->dma_read_chnl.get();
            wait();

            // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
            {
                HLS_UNROLL_SIMPLE;
                A0[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
            }
        }
#endif
        this->load_compute_handshake();
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
    int32_t len;
    int32_t log_len;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        len = config.len;
        log_len = config.log_len;
    }

    // Store
    {
        HLS_PROTO("store-dma");
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = (2 * len) * 1;
#else
        uint32_t store_offset = round_up(2 * len, DMA_WORD_PER_BEAT) * 1;
#endif
        uint32_t offset = 0;

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
            data = B0[i];
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
                dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = B0[i + k];
            }
            this->dma_write_chnl.put(dataBv);
        }
#endif
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
    int32_t len;
    int32_t log_len;
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        len = config.len;
        log_len = config.log_len;
    }


    // Compute FFT single pass (FIXME: assume vector fits in the PLM)
    {
        uint32_t length = 2 * len;
        this->compute_load_handshake();

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
                    CompNum akj32, akjm32;
                    CompNum bkj32, bkjm32;
                    CompNum akj32_A, akjm32_A;
                    CompNum akj32_C, akjm32_C;

                    akj32_A.re = int2fp<FPDATA, WORD_SIZE>(A0[2 * kj]);
                    akj32_A.im = int2fp<FPDATA, WORD_SIZE>(A0[2 * kj + 1]);
                    akj32_C.re = int2fp<FPDATA, WORD_SIZE>(C[2 * kj]);
                    akj32_C.im = int2fp<FPDATA, WORD_SIZE>(C[2 * kj + 1]);
                    akjm32_A.re = int2fp<FPDATA, WORD_SIZE>(A0[2 * kjm]);
                    akjm32_A.im = int2fp<FPDATA, WORD_SIZE>(A0[2 * kjm + 1]);
                    akjm32_C.re = int2fp<FPDATA, WORD_SIZE>(C[2 * kjm]);
                    akjm32_C.im = int2fp<FPDATA, WORD_SIZE>(C[2 * kjm + 1]);

                    if (s == 1) {
                        akj32 = akj32_A;
                        akjm32 = akjm32_A;
                    } else {
                        akj32 = akj32_C;
                        akjm32 = akjm32_C;
                    }
                    akj.re = akj32.re;
                    akj.im = akj32.im;
                    akjm.re = akjm32.re;
                    akjm.im = akjm32.im;

                    // printf("i: %d,  j: %d\n", kj, kjm);
                    // printf("w: %.15g, %.15g\n", w.re, w.im);

                    CompNum t;
                    compMul(w, akjm, t);
                    CompNum u(akj.re, akj.im);
                    compAdd(u, t, bkj);
                    compSub(u, t, bkjm);
                    CompNum wwm;
                    wwm.re = w.re - (wm.im * w.im + wm.re * w.re);
                    wwm.im = w.im + (wm.im * w.re - wm.re * w.im);
                    // compMul(w, wm, wwm);
                    w = wwm;

                    bkj32.re = bkj.re;
                    bkj32.im = bkj.im;
                    bkjm32.re = bkjm.re;
                    bkjm32.im = bkjm.im;

                    if (s == log_len) {
                        HLS_PROTO("compute_write_B0");
                        HLS_BREAK_DEP(B0);
                        wait();
                        B0[2 * kj] = fp2int<FPDATA, WORD_SIZE>(bkj32.re);
                        B0[2 * kj + 1] = fp2int<FPDATA, WORD_SIZE>(bkj32.im);
                        wait();
                        B0[2 * kjm] = fp2int<FPDATA, WORD_SIZE>(bkjm32.re);
                        B0[2 * kjm + 1] = fp2int<FPDATA, WORD_SIZE>(bkjm32.im);
                        // cout << "DFT: B0 " << kj << ": " << B0[kj].re.to_hex() << " " << B0[kj].im.to_hex() << endl;
                        // cout << "DFT: B0 " << kjm << ": " << B0[kjm].re.to_hex() << " " << B0[kjm].im.to_hex() << endl;
                    } else {
                        HLS_PROTO("compute_write_C");
                        HLS_BREAK_DEP(C);
                        wait();
                        C[2 * kj] = fp2int<FPDATA, WORD_SIZE>(bkj32.re);
                        C[2 * kj + 1] = fp2int<FPDATA, WORD_SIZE>(bkj32.im);
                        wait();
                        C[2 * kjm] = fp2int<FPDATA, WORD_SIZE>(bkjm32.re);
                        C[2 * kjm + 1] = fp2int<FPDATA, WORD_SIZE>(bkjm32.im);
                        // cout << "DFT: C " << kj << ": " << C[kj].re.to_hex() << " " << C[kj].im.to_hex() << endl;
                        // cout << "DFT: C " << kjm << ": " << C[kjm].re.to_hex() << " " << C[kjm].im.to_hex() << endl;
                    }
                }
            }
        }
        this->compute_store_handshake();

        // Conclude
        {
            this->process_done();
        }
    }
}
