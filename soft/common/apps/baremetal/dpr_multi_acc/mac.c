/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include "mac.h"

int validate_buf_mac(token_t *out, token_t *gold)
{
    int i;
    int j;
    unsigned errors = 0;

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++)
            if (gold[i * out_words_adj_mac + j] != out[i * out_words_adj_mac + j]) errors++;

    return errors;
}

void init_buf_mac(token_t *in, token_t *gold)
{
    int i;
    int j;
    int k = 0;
    float out_gold;

    for (i = 0; i < mac_n; i++) {
        for (j = 0; j < mac_len * mac_vec; j++) {
            float data               = ((i * 8 + j + k) % 32) + 0.25;
            token_t data_fxd         = float_to_fixed32(data, 16);
            in[i * in_words_adj_mac + j] = data_fxd;
        }
        k++;
    }

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++) {
            out_gold = 0;
            for (k = 0; k < mac_len; k += 2) {
                float data1 = fixed32_to_float(in[i * in_words_adj_mac + j * mac_len + k], 16);
                float data2 = fixed32_to_float(in[i * in_words_adj_mac + j * mac_len + k + 1], 16);
                out_gold += data1 * data2;
            }
            gold[i * out_words_adj_mac + j] = float_to_fixed32(out_gold, 16);
        }
}
