// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "fft2.hpp"
#include "fft2_directives.hpp"

// Functions

#include "fft2_functions.hpp"

// Processes

void fft2::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();
        this->reset_load_to_store();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    //int32_t scale_factor;
    //int32_t do_inverse;
    int32_t logn_samples;
    int32_t num_samples;
    //int32_t do_shift;
    int32_t num_ffts;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        logn_samples = config.logn_samples;
        num_samples = 1 << logn_samples;
        num_ffts = config.num_ffts;
        //do_inverse = config.do_inverse;
        //do_shift = config.do_shift;
        //scale_factor = config.scale_factor;
    }

    // Load
    int loads_done = 0;
    {
        HLS_PROTO("load-dma");
        uint32_t offset = 0;

        wait();
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t length = 2 * num_ffts * num_samples;
#else
        uint32_t length = round_up(2 * num_ffts * num_samples, DMA_WORD_PER_BEAT);
#endif
        // Chunking
        for (int rem = length; rem > 0; rem -= PLM_IN_WORD)
        {
            wait();
            // Configure DMA transaction
            uint32_t len = rem > PLM_IN_WORD ? PLM_IN_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
            // data word is wider than NoC links
            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
            printf("LOAD DMA INFO : rem %u : off = %u , len %u\n", rem, (offset/DMA_WORD_PER_BEAT), (len/DMA_WORD_PER_BEAT));
            dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
            offset += len;

            this->dma_read_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
            // data word is wider than NoC links
            for (uint16_t i = 0; i < len; i++)
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
            for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
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
            printf("LOAD hit the load-compute handshake...\n");
            this->load_compute_handshake();
            this->load_to_store_handshake();
            loads_done++;
        } // for (rem = length downto 0 )
    } // Load scope

    //printf("LOAD process is done -- did %u loads\n", loads_done);
    // Conclude
    {
        this->process_done();
    }
}



void fft2::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();
        this->reset_store_to_load();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t logn_samples;
    int32_t num_samples;
    int32_t num_ffts;
    //int32_t scale_factor;
    //int32_t do_inverse;
    //int32_t do_shift;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        logn_samples = config.logn_samples;
        num_samples = 1 << logn_samples;
        num_ffts = config.num_ffts;
        //do_inverse = config.do_inverse;
        //do_shift = config.do_shift;
        //scale_factor = config.scale_factor;
    }

    // Store
    int stores_done = 0;
    {
        HLS_PROTO("store-dma");
        wait();

#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = (2 * num_samples);
#else
        uint32_t store_offset = round_up(2 * num_samples, DMA_WORD_PER_BEAT);
#endif
        uint32_t offset = 0;

        wait();
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t length = 2 * num_ffts * num_samples;
#else
        uint32_t length = round_up(2 * num_ffts * num_samples, DMA_WORD_PER_BEAT);
#endif
        // Chunking
        for (int rem = length; rem > 0; rem -= PLM_OUT_WORD)
        {
            printf("STORE hit the store-compute handshake...\n");
            this->store_compute_handshake();

            // Configure DMA transaction
            uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
            // data word is wider than NoC links
            dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
            printf("STORE DMA INFO : rem %u : off = %u , len = %u\n", rem, (offset/DMA_WORD_PER_BEAT), (len/DMA_WORD_PER_BEAT));
            dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
            offset += len;

            this->dma_write_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
            // data word is wider than NoC links
            for (uint16_t i = 0; i < len; i++)
            {
                // Read from PLM
                sc_dt::sc_int<DATA_WIDTH> data;
                wait();
                data = A0[i];
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
            for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
            {
                sc_dt::sc_bv<DMA_WIDTH> dataBv;

                // Read from PLM
                wait();
                for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                {
                    HLS_UNROLL_SIMPLE;
                    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = A0[i + k];
                }
                this->dma_write_chnl.put(dataBv);
            }
#endif
            stores_done++;
            //rem = 0;
            this->store_to_load_handshake();
        } // for (rem = length downto 0
    } // Store scope
    //printf("STORE process is done - did %u stores!\n", stores_done);
    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void fft2::compute_kernel()
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
    int32_t logn_samples;
    int32_t num_samples;
    int32_t num_ffts;
    int32_t do_inverse;
    int32_t do_shift;
    //int32_t scale_factor;
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        logn_samples = config.logn_samples;
#ifndef STRATUS_HLS
        sc_assert(logn_samples < MAX_LOGN_SAMPLES);
#endif
        num_samples = 1 << logn_samples;
        num_ffts = config.num_ffts;
        do_inverse = config.do_inverse;
        do_shift = config.do_shift;
        //scale_factor = config.scale_factor;
    }
    //printf("COMPUTE: logn_samples %u num_samples %u num_ffts %u inverse %u shift %u\n", logn_samples, num_samples, num_ffts, do_inverse, do_shift);

    // Compute
    // Loop through the num_ffts successive FFT computations
    {
        uint32_t in_length  = 2 * num_ffts * num_samples;
        uint32_t out_length = in_length;
        uint32_t out_rem = out_length;
        unsigned max_in_ffts = 1 << (MAX_LOGN_SAMPLES - logn_samples);
        unsigned ffts_done = 0;
        printf("COMPUTE: in_len %u : max_in_ffts %u >> %u = %u\n", in_length, MAX_LOGN_SAMPLES, logn_samples, max_in_ffts); 
        // Chunking : Load/Store Memory transfers (refill memory)
        for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD)
        {
            uint32_t in_len  = in_rem  > PLM_IN_WORD  ? PLM_IN_WORD  : in_rem;
            uint32_t out_len = out_rem > PLM_OUT_WORD ? PLM_OUT_WORD : out_rem;

            // Compute FFT(s) in the PLM
            printf("COMPUTE INFO : in_rem %u : in_len %u :: out_rem %u : out_len %u\n", in_rem, in_len, out_rem, out_len);
            printf("COMPUTE hit the compute-load handshake...\n");
            this->compute_load_handshake();
            unsigned rem_ffts = (num_ffts - ffts_done); 
            unsigned in_ffts =  (rem_ffts > max_in_ffts) ? max_in_ffts : rem_ffts;
            printf("COMPUTE has %u rem_ffts : proceeding to the next %u FFT computations...\n", rem_ffts, in_ffts);
            for (unsigned fftn = 0; fftn < in_ffts; fftn++) {
                unsigned offset = fftn * num_samples;  // Offset into Mem for start of this FFT
                printf("COMPUTE: starting FFT %u of %u = %u : offset = %u\n", fftn, in_ffts, ffts_done, offset);
                int sin_sign = (do_inverse) ? -1 : 1; // This modifes the mySin
                                                      // values used below
                if (do_inverse && do_shift) {
                    //printf("ACCEL: Calling Inverse-Do-Shift\n");
                    fft2_do_shift(offset, num_samples, logn_samples);
                }

                // Do the bit-reverse
                fft2_bit_reverse(offset, num_samples, logn_samples);

                // Computing phase implementation
                int m = 1;  // iterative FFT

            FFT2_SINGLE_L1:
                for(unsigned s = 1; s <= logn_samples; s++) {
                    //printf(" L1 : FFT %u = %u : s %u\n", fftn, ffts_done, s);
                    m = 1 << s;
                    CompNum wm(myCos(s), sin_sign*mySin(s));
                    // printf("s: %d\n", s);
                    // printf("wm.re: %.15g, wm.im: %.15g\n", wm.re, wm.im);

                FFT2_SINGLE_L2:
                    for(unsigned k = 0; k < num_samples; k +=m) {
                        // if (k < 2) {
                        //     printf("  L2 : FFT %u = %u : s %u : k %u\n", fftn, ffts_done, s, k);
                        // }

                        CompNum w((FPDATA) 1, (FPDATA) 0);
                        int md2 = m / 2;

                    FFT2_SINGLE_L3:
                        for(int j = 0; j < md2; j++) {

                            int kj = offset + k + j;
                            int kjm = offset + k + j + md2;
                            // if ((k == 0) && (j == 0)) {
                            //     printf("  L3 : FFT %u = %u : k %u j %u md2 %u : kj %u kjm %u : kji %u kjmi %u\n", fftn, ffts_done, k, j, md2, kj, kjm, 2*kj, 2*kjm);
                            // }
                            CompNum akj, akjm;
                            CompNum bkj, bkjm;

                            akj.re = int2fp<FPDATA, WORD_SIZE>(A0[2 * kj]);
                            akj.im = int2fp<FPDATA, WORD_SIZE>(A0[2 * kj + 1]);
                            akjm.re = int2fp<FPDATA, WORD_SIZE>(A0[2 * kjm]);
                            akjm.im = int2fp<FPDATA, WORD_SIZE>(A0[2 * kjm + 1]);

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
                                HLS_PROTO("compute_write_A0");
                                HLS_BREAK_DEP(A0);
                                wait();
                                A0[2 * kj] = fp2int<FPDATA, WORD_SIZE>(bkj.re);
                                A0[2 * kj + 1] = fp2int<FPDATA, WORD_SIZE>(bkj.im);
                                wait();
                                A0[2 * kjm] = fp2int<FPDATA, WORD_SIZE>(bkjm.re);
                                A0[2 * kjm + 1] = fp2int<FPDATA, WORD_SIZE>(bkjm.im);
                                // cout << "DFT: A0 " << kj << ": " << A0[kj].re.to_hex() << " " << A0[kj].im.to_hex() << endl;
                                // cout << "DFT: A0 " << kjm << ": " << A0[kjm].re.to_hex() << " " << A0[kjm].im.to_hex() << endl;
                                // if ((k == 0) && (j == 0)) {
                                //         printf("  L3 : WROTE A0 %u and %u and %u and %u\n", 2*kj, 2*kj + 1, 2*kjm, 2*kjm + 1);
                                // }
                            }
                        } // for (j = 0 .. md2)
                    } // for (k = 0 .. num_samples)
                } // for (s = 1 .. logn_samples)

                if ((!do_inverse) && (do_shift)) {
                    //printf("ACCEL: Calling Non-Inverse Do-Shift\n");
                    fft2_do_shift(offset, num_samples, logn_samples);
                }
                //printf("COMPUTE: done with FF %u = %u\n", fftn, ffts_done);
                /*cout << "ACCEL-END : FFT " << ffts_done << " : A0[0] = " << A0[0].to_double() << endl;
                  cout << "ACCEL-END : FFT " << ffts_done << " : A0[1] = " << A0[1].to_double() << endl;
                  cout << "ACCEL-END : FFT " << ffts_done << " : A0[2] = " << A0[2].to_double() << endl;
                  cout << "ACCEL-END : FFT " << ffts_done << " : A0[3] = " << A0[3].to_double() << endl;*/
                ffts_done++;
                offset += num_samples;  // Offset into Mem for start of this FFT
            } // for( n = 0 .. mnum_ffts)
            out_rem -= PLM_OUT_WORD;
            printf("COMPUTE hit the compute-store handshake...\n");
            this->compute_store_handshake();
        } // for (in_rem = in_length downto 0)

        // Conclude
        {
            this->process_done();
        }
    } // Compute scope
} // Function : compute_kernel
