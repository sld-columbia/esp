// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "cfg.h"
#include "libesp.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
    int i;
    int j;
    unsigned errors = 0;

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++)
            if (gold[i * out_words_adj + j] != out[i * out_words_adj + j]) errors++;

    return errors;
}

/* User-defined code */
static void init_buffer(token_t *in, token_t *gold)
{
    int i;
    int j;
    int k = 0;
    float out_gold;

    for (i = 0; i < mac_n; i++) {
        for (j = 0; j < mac_len * mac_vec; j++) {
            float data               = ((i * 8 + j + k) % 32) + 0.25;
            token_t data_fxd         = float_to_fixed32(data, 16);
            in[i * in_words_adj + j] = data_fxd;
        }
        k++;
    }

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++) {
            out_gold = 0;
            for (k = 0; k < mac_len; k += 2) {
                float data1 = fixed32_to_float(in[i * in_words_adj + j * mac_len + k], 16);
                float data2 = fixed32_to_float(in[i * in_words_adj + j * mac_len + k + 1], 16);
                out_gold += data1 * data2;
            }
            gold[i * out_words_adj + j] = float_to_fixed32(out_gold, 16);
        }
}

/* User-defined code */
static void init_parameters()
{
    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj  = mac_len * mac_vec;
        out_words_adj = mac_vec;
    }
    else {
        in_words_adj  = round_up(mac_len * mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len     = in_words_adj * (mac_n);
    out_len    = out_words_adj * (mac_n);
    in_size    = in_len * sizeof(token_t);
    out_size   = out_len * sizeof(token_t);
    out_offset = in_len;
    size       = (out_offset * sizeof(token_t)) + out_size;
}

int main(int argc, char **argv)
{
    int errors;

    token_t *gold;
    token_t *buf;

    init_parameters();

    buf               = (token_t *)esp_alloc(size);
    cfg_000[0].hw_buf = buf;

    gold = malloc(out_size);

    init_buffer(buf, gold);

    printf("\n====== %s ======\n\n", cfg_000[0].devname);
    /* <<--print-params-->> */
    printf("  .mac_n = %d\n", mac_n);
    printf("  .mac_vec = %d\n", mac_vec);
    printf("  .mac_len = %d\n", mac_len);
    printf("\n  ** START **\n");

    esp_run(cfg_000, NACC);

    printf("\n  ** DONE **\n");

    errors = validate_buffer(&buf[out_offset], gold);

    free(gold);
    esp_free(buf);

    if (!errors) printf("+ Test PASSED\n");
    else
        printf("+ Test FAILED\n");

    printf("\n====== %s ======\n\n", cfg_000[0].devname);

    return errors;
}
