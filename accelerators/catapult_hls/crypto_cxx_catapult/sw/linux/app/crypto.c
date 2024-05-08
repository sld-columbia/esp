// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "aes_tests.h"
#include "cfg.h"
#include "sha1_tests.h"
#include "sha2_tests.h"

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
    int j;
    unsigned errors = 0;

    for (j = 0; j < out_words_adj; j++) {
        if (gold[j] != out[j]) {
            printf("[%d] - expected: %x, got: %x\n", j, gold[j], out[j]);
            errors++;
        }
    }
    return errors;
}

/* User-defined code */
static void init_buffer(token_t *in, token_t *gold, int crypto_algo, int aes_oper_mode, int index)
{
    int i, j;

    if (crypto_algo == 1) {
        for (i = 0; i < sha1_raw_in_words[index]; i++)
            in[i] = sha1_raw_inputs[index][i];
        for (i = 0; i < sha1_raw_out_words[index]; i++)
            gold[i] = sha1_raw_outputs[index][i];
    }
    else if (crypto_algo == 2) {
        for (i = 0; i < sha2_raw_in_words[index]; i++)
            in[i] = sha2_raw_inputs[index][i];
        for (i = 0; i < sha2_raw_out_words[index]; i++)
            gold[i] = sha2_raw_outputs[index][i];
    }
    else if (crypto_algo == 3 && aes_oper_mode == 1) {
        j = 0;
        for (i = 0; i < aes_ecb_raw_encrypt_key_words[index]; i++, j++)
            in[j] = aes_ecb_raw_encrypt_key[index][i];
        for (i = 0; i < aes_ecb_raw_encrypt_plaintext_words[index]; i++, j++)
            in[j] = aes_ecb_raw_encrypt_plaintext[index][i];
        for (i = 0; i < aes_ecb_raw_encrypt_ciphertext_words[index]; i++)
            gold[i] = aes_ecb_raw_encrypt_ciphertext[index][i];
    }
    else if (crypto_algo == 3 && aes_oper_mode == 2) {
        j = 0;
        for (i = 0; i < aes_ctr_raw_encrypt_key_words[index]; i++, j++)
            in[j] = aes_ctr_raw_encrypt_key[index][i];
        for (i = 0; i < aes_ctr_raw_encrypt_iv_words[index]; i++, j++)
            in[j] = aes_ctr_raw_encrypt_iv[index][i];
        for (i = 0; i < aes_ctr_raw_encrypt_plaintext_words[index]; i++, j++)
            in[j] = aes_ctr_raw_encrypt_plaintext[index][i];
        for (i = 0; i < aes_ctr_raw_encrypt_ciphertext_words[index]; i++)
            gold[i] = aes_ctr_raw_encrypt_ciphertext[index][i];
    }
    else if (crypto_algo == 3 && aes_oper_mode == 3) {
        j = 0;
        for (i = 0; i < aes_cbc_raw_encrypt_key_words[index]; i++, j++)
            in[j] = aes_cbc_raw_encrypt_key[index][i];
        for (i = 0; i < aes_cbc_raw_encrypt_iv_words[index]; i++, j++)
            in[j] = aes_cbc_raw_encrypt_iv[index][i];
        for (i = 0; i < aes_cbc_raw_encrypt_plaintext_words[index]; i++, j++)
            in[j] = aes_cbc_raw_encrypt_plaintext[index][i];
        for (i = 0; i < aes_cbc_raw_encrypt_ciphertext_words[index]; i++)
            gold[i] = aes_cbc_raw_encrypt_ciphertext[index][i];
    }
}

/* User-defined code */
static void init_parameters(int crypto_algo, int aes_oper_mode, int index)
{
    int in_words  = 0;
    int out_words = 0;

    if (crypto_algo == 1) {
        in_words  = sha1_raw_in_words[index];
        out_words = sha1_raw_out_words[index];
    }
    else if (crypto_algo == 2) {
        in_words  = sha2_raw_in_words[index];
        out_words = sha2_raw_out_words[index];
    }
    else if (crypto_algo == 3 && aes_oper_mode == 1) {
        in_words =
            aes_ecb_raw_encrypt_key_words[index] + aes_ecb_raw_encrypt_plaintext_words[index];
        out_words = aes_ecb_raw_encrypt_ciphertext_words[index];
    }
    else if (crypto_algo == 3 && aes_oper_mode == 2) {
        in_words = aes_ctr_raw_encrypt_key_words[index] + aes_ctr_raw_encrypt_iv_words[index] +
            aes_ctr_raw_encrypt_plaintext_words[index];
        out_words = aes_ctr_raw_encrypt_ciphertext_words[index];
    }
    else if (crypto_algo == 3 && aes_oper_mode == 3) {
        in_words = aes_cbc_raw_encrypt_key_words[index] + aes_cbc_raw_encrypt_iv_words[index] +
            aes_cbc_raw_encrypt_plaintext_words[index];
        out_words = aes_cbc_raw_encrypt_ciphertext_words[index];
    }

    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj  = in_words;
        out_words_adj = out_words;
    }
    else {
        in_words_adj  = round_up(in_words, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(out_words, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len     = in_words_adj;
    out_len    = out_words_adj;
    in_size    = in_len * sizeof(token_t);
    out_size   = out_len * sizeof(token_t);
    out_offset = in_len;
    size       = (out_offset * sizeof(token_t)) + out_size;
}

static void init_cfg(int crypto_algo, int aes_oper_mode, int index)
{
    crypto_cfg_000[0].crypto_algo = crypto_algo;

    if (crypto_algo == 1) { crypto_cfg_000[0].sha1_in_bytes = sha1_raw_in_bytes[index]; }
    else if (crypto_algo == 2) {
        crypto_cfg_000[0].sha2_in_bytes  = sha2_raw_in_bytes[index];
        crypto_cfg_000[0].sha2_out_bytes = sha2_raw_out_bytes[index];
    }
    else if (crypto_algo == 3) {
        crypto_cfg_000[0].aes_oper_mode = aes_oper_mode;
        crypto_cfg_000[0].encryption    = AES_ENCRYPTION_MODE;
        if (aes_oper_mode == 1) {
            crypto_cfg_000[0].aes_key_bytes   = aes_ecb_raw_encrypt_key_bytes[index];
            crypto_cfg_000[0].aes_input_bytes = aes_ecb_raw_encrypt_plaintext_bytes[index];
            crypto_cfg_000[0].aes_iv_bytes    = 0;
            crypto_cfg_000[0].aes_aad_bytes   = 0;
            crypto_cfg_000[0].aes_tag_bytes   = 0;
        }
        else if (aes_oper_mode == 2) {
            crypto_cfg_000[0].aes_key_bytes   = aes_ctr_raw_encrypt_key_bytes[index];
            crypto_cfg_000[0].aes_input_bytes = aes_ctr_raw_encrypt_plaintext_bytes[index];
            crypto_cfg_000[0].aes_iv_bytes    = aes_ctr_raw_encrypt_iv_bytes[index];
            crypto_cfg_000[0].aes_aad_bytes   = 0;
            crypto_cfg_000[0].aes_tag_bytes   = 0;
        }
        else if (aes_oper_mode == 3) {
            crypto_cfg_000[0].aes_key_bytes   = aes_cbc_raw_encrypt_key_bytes[index];
            crypto_cfg_000[0].aes_input_bytes = aes_cbc_raw_encrypt_plaintext_bytes[index];
            crypto_cfg_000[0].aes_iv_bytes    = aes_cbc_raw_encrypt_iv_bytes[index];
            crypto_cfg_000[0].aes_aad_bytes   = 0;
            crypto_cfg_000[0].aes_tag_bytes   = 0;
        }
    }
}

void usage()
{
    printf("usage: ./crypto crypto_algo [aes_mode]\n");
    printf("crypto_algo: 1 - SHA1, 2 - SHA2, 3 - AES\n");
    printf("aes_mode - required if crypto_algo == AES: 1 - ECB, 2 - CTR, 3 - CBC\n");
}

int main(int argc, char **argv)
{
    int errors     = 0;
    int fail_count = 0;

    token_t *gold;
    token_t *buf;

    if (argc < 2) {
        usage();
        return -1;
    }

    int crypto_algo = atoi(argv[1]);
    if (crypto_algo < 1 || crypto_algo > 4) {
        usage();
        return -1;
    }

    if (crypto_algo == 3 && argc < 3) {
        usage();
        return -1;
    }

    int aes_oper_mode = 0;
    if (crypto_algo == 3) {
        aes_oper_mode = atoi(argv[2]);
        if (aes_oper_mode < 1 || aes_oper_mode > 3) {
            usage();
            return -1;
        }
    }

    int N_TESTS = 0;
    if (crypto_algo == 1) {
        N_TESTS = 13;
        printf("Starting %d tests for SHA1\n", N_TESTS);
    }
    else if (crypto_algo == 2) {
        N_TESTS = 12;
        printf("Starting %d tests for SHA2\n", N_TESTS);
    }
    else if (crypto_algo == 3 && aes_oper_mode == 1) {
        N_TESTS = 10;
        printf("Starting %d tests for AES ECB\n", N_TESTS);
    }
    else if (crypto_algo == 3 && aes_oper_mode == 2) {
        N_TESTS = 4;
        printf("Starting %d tests for AES CTR\n", N_TESTS);
    }
    else if (crypto_algo == 3 && aes_oper_mode == 3) {
        N_TESTS = 10;
        printf("Starting %d tests for AES CBC\n", N_TESTS);
    }

    for (int i = 1; i < N_TESTS; i++) {
        init_parameters(crypto_algo, aes_oper_mode, i);

        buf               = (token_t *)esp_alloc(size);
        cfg_000[0].hw_buf = buf;
        gold              = malloc(out_len * sizeof(float));

        init_buffer(buf, gold, crypto_algo, aes_oper_mode, i);

        init_cfg(crypto_algo, aes_oper_mode, i);

        printf("\n====== %s, TEST %d ======\n\n", cfg_000[0].devname, i);
        /* <<--print-params-->> */
        printf("  .crypto_algo = %d\n", crypto_cfg_000[0].crypto_algo);
        printf("  .encryption = %d\n", crypto_cfg_000[0].encryption);
        printf("  .sha1_in_bytes = %d\n", crypto_cfg_000[0].sha1_in_bytes);
        printf("  .sha2_in_bytes = %d\n", crypto_cfg_000[0].sha2_in_bytes);
        printf("  .aes_oper_mode = %d\n", crypto_cfg_000[0].aes_oper_mode);
        printf("  .aes_key_bytes = %d\n", crypto_cfg_000[0].aes_key_bytes);
        printf("  .aes_input_bytes = %d\n", crypto_cfg_000[0].aes_input_bytes);
        printf("  .aes_iv_bytes = %d\n", crypto_cfg_000[0].aes_iv_bytes);
        printf("  .aes_aad_bytes = %d\n", crypto_cfg_000[0].aes_aad_bytes);
        printf("  .aes_tag_bytes = %d\n", crypto_cfg_000[0].aes_tag_bytes);

        printf("\n  ** START **\n");

        esp_run(cfg_000, NACC);

        printf("\n  ** DONE **\n");

        errors = validate_buffer(&buf[out_offset], gold);

        free(gold);
        esp_free(buf);

        if (errors) {
            printf(" TEST %d FAIL: %d errors\n", i, errors);
            fail_count++;
        }
        else
            printf(" TEST %d PASS\n", i);

        printf("\n====== %s ======\n\n", cfg_000[0].devname);
    }

    if (fail_count == 0) printf("ALL TESTS PASSED!\n");
    else
        printf("%d/%d TESTS FAILED!\n", fail_count, N_TESTS - 1);

    return errors;
}
