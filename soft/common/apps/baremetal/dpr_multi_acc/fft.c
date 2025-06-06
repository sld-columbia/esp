/* Copyright (c) 2011-2024 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <monitors.h>
#include "utils/fft_utils.h"
#include "fft.h"

//static unsigned int fft_rev(unsigned int v)
//{
//    unsigned int r = v;
//    int s          = sizeof(v) * CHAR_BIT - 1;
//
//    for (v >>= 1; v; v >>= 1) {
//        r <<= 1;
//        r |= v & 1;
//        s--;
//    }
//    r <<= s;
//    return r;
//}
//
//static void fft_bit_reverse(float *w, unsigned int n, unsigned int bits)
//{
//    unsigned int i, s, shift;
//
//    s     = sizeof(i) * CHAR_BIT - 1;
//    shift = s - bits + 1;
//
//    for (i = 0; i < n; i++) {
//        unsigned int r;
//        float t_real, t_imag;
//
//        r = fft_rev(i);
//        r >>= shift;
//
//        if (i < r) {
//            t_real       = w[2 * i];
//            t_imag       = w[2 * i + 1];
//            w[2 * i]     = w[2 * r];
//            w[2 * i + 1] = w[2 * r + 1];
//            w[2 * r]     = t_real;
//            w[2 * r + 1] = t_imag;
//        }
//    }
//}
//
//static int fft_comp(float *data, unsigned int n, unsigned int logn, int sign, bool rev)
//{
//    unsigned int transform_length;
//    unsigned int a, b, i, j, bit;
//    float theta, t_real, t_imag, w_real, w_imag, s, t, s2, z_real, z_imag;
//
//    if (rev) fft_bit_reverse(data, n, logn);
//
//    transform_length = 1;
//
//    /* calculation */
//    for (bit = 0; bit < logn; bit++) {
//        w_real = 1.0;
//        w_imag = 0.0;
//
//        theta = 1.0 * sign * M_PI / (float)transform_length;
//
//        s  = sin(theta);
//        t  = sin(0.5 * theta);
//        s2 = 2.0 * t * t;
//
//        for (a = 0; a < transform_length; a++) {
//            for (b = 0; b < n; b += 2 * transform_length) {
//                i = b + a;
//                j = b + a + transform_length;
//
//                z_real = data[2 * j];
//                z_imag = data[2 * j + 1];
//
//                t_real = w_real * z_real - w_imag * z_imag;
//                t_imag = w_real * z_imag + w_imag * z_real;
//
//                /* write the result */
//                data[2 * j]     = data[2 * i] - t_real;
//                data[2 * j + 1] = data[2 * i + 1] - t_imag;
//                data[2 * i] += t_real;
//                data[2 * i + 1] += t_imag;
//            }
//
//            /* adjust w */
//            t_real = w_real - (s * w_imag + s2 * w_real);
//            t_imag = w_imag + (s * w_real - s2 * w_imag);
//            w_real = t_real;
//            w_imag = t_imag;
//        }
//        transform_length *= 2;
//    }
//
//    return 0;
//}

int validate_buf_fft(token_t *out, float *gold)
{
    int j;
    unsigned errors = 0;

    for (j = 0; j < 2 * len_fft * batch_size_fft; j++) {
        native_t val = fx2float(out[j], FX_IL);
        if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH) { errors++; }
    }

    printf("  %u errors\n", errors);
    return errors;
}

void init_buf_fft(token_t *in, float *gold)
{
    int j;
    const float LO = -10.0;
    const float HI = 10.0;

    /* srand((unsigned int) time(NULL)); */

    for (j = 0; j < 2 * len_fft * batch_size_fft; j++) {
        float scaling_factor = (float)rand() / (float)RAND_MAX;
        gold[j]              = LO + scaling_factor * (HI - LO);
    }

    // preprocess with bitreverse (fast in software anyway)
    if (!do_bitrev_fft) fft_bit_reverse(gold, len_fft, log_len_fft);

    // convert input to fixed point
    for (j = 0; j < 2 * len_fft * batch_size_fft; j++)
        in[j] = float2fx((native_t)gold[j], FX_IL);

    // Compute golden output
    for (j = 0; j < batch_size_fft; j++)
        fft_comp(&gold[j * 2 * len_fft], len_fft, log_len_fft, -1, do_bitrev_fft);
}

#ifdef FFT_MAIN
int main(int argc, char *argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device *espdevs;
    struct esp_device *dev;
    unsigned done;
    unsigned **ptable = NULL;
    token_t *mem;
    float *gold;
    unsigned errors = 0;
    unsigned coherence;
    const unsigned ERROR_COUNT_TH = 1;
    unsigned int reads = 0;

    unsigned int cycles_start, cycles_end, cycles_diff;

    len = 1 << log_len;

    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj  = 2 * len * batch_size;
        out_words_adj = 2 * len * batch_size;
    }
    else {
        in_words_adj  = round_up(2 * len * batch_size, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(2 * len * batch_size, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len     = in_words_adj;
    out_len    = out_words_adj;
    in_size    = in_len * sizeof(token_t);
    out_size   = out_len * sizeof(token_t);
    out_offset = 0;
    mem_size   = (out_offset * sizeof(token_t)) + out_size;

    // Search for the device
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_FFT, DEV_NAME);
    if (ndev == 0) {
        printf("fft not found\n");
        return 0;
    }
    dev = &espdevs[0];
    init_server(0, dev, 2, 3);

    for (n = 0; n < NUM_FREQUENCIES; n++) {

        printf("**************** %s.%d ****************\n", DEV_NAME, n);
        spawn_hw_thread(0, 0, n);

        // Check DMA capabilities
        if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
            printf("  -> scatter-gather DMA is disabled. Abort.\n");
            return 0;
        }

        if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
            printf("  -> Not enough TLB entries available. Abort.\n");
            return 0;
        }

        // Allocate memory
        gold = aligned_malloc(out_len * sizeof(float));
        mem  = aligned_malloc(mem_size);
        printf("  memory buffer base-address = %p\n", mem);

        // Allocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(token_t))];

        printf("  ptable = %p\n", ptable);
        printf("  nchunk = %lu\n", NCHUNK(mem_size));

        for (coherence = ACC_COH_NONE; coherence <= ACC_COH_NONE; coherence++) {
            printf("  --------------------\n");
            printf("  Generate input...\n");
            init_buf(mem, gold);

            // Pass common configuration parameters

            iowrite32(dev, COHERENCE_REG, coherence);

            iowrite32(dev, PT_ADDRESS_REG, (unsigned long)ptable);

            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            iowrite32(dev, SRC_OFFSET_REG, 0x0);
            iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev, FFT_DO_PEAK_REG, 0);
            iowrite32(dev, FFT_DO_BITREV_REG, do_bitrev);
            iowrite32(dev, FFT_LOG_LEN_REG, log_len);
            iowrite32(dev, FFT_BATCH_SIZE_REG, batch_size);

            // Flush (customize coherence model here)
            esp_flush(coherence);

            // Start accelerators
            printf("  Start...\n");
            cycles_start = esp_monitor(mon_args, NULL);
            iowrite32(dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            reads = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
                reads++;
            }
            iowrite32(dev, CMD_REG, 0x0);

            cycles_end = esp_monitor(mon_args, NULL);
            cycles_diff = sub_monitor_vals(cycles_start, cycles_end);

            printf("  Done\n");
            printf("  validating...\n");

            /* Validation */
            errors = validate_buf(&mem[out_offset], gold);
            if (errors > (ERROR_COUNT_TH * len / 100)) printf("  ... FAIL\n");
            else
                printf("  ... PASS\n");

            printf("  ... Division selection = %u, latency was %u (%u - %u)\n", div_sel[n], cycles_diff, cycles_end, cycles_start);
            printf("  ... %u reads\n", reads);
        }

        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }

    log_power(0, EVENT_IDLE);

    write_and_read_div_sel(dev, 2, 0b100, 0);
    printf("Thanks for coming\n");

    return 0;
}
#endif
