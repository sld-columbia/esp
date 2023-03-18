/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include "mac.h"
//#include "dpr_multi_acc.h"

int validate_buf_mac(token_t *out, token_t *gold)
{
    int i;
    int j;
    unsigned errors = 0;

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++)
            if (gold[i * out_words_adj + j] != out[i * out_words_adj + j])
                errors++;

    return errors;
}

void init_buf_mac(token_t *in, token_t * gold)
{
    int i;
    int j;
    int k;

    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_len * mac_vec; j++)
            in[i * in_words_adj + j] = j % mac_vec;

    // Compute golden output
    for (i = 0; i < mac_n; i++)
        for (j = 0; j < mac_vec; j++) {
            gold[i * out_words_adj + j] = 0;
            for (k = 0; k < mac_len; k += 2)
                gold[i * out_words_adj + j] +=
                        in[i * in_words_adj + j * mac_len + k] * in[i * in_words_adj + j * mac_len + k + 1];
        }
}

