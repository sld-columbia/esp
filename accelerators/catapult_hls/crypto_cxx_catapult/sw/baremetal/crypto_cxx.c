/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#include <stdlib.h>

#include <fixed_point.h>
#include <math.h>

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef uint32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st) { return (sizeof(void *) / _st); }

#define SLD_CRYPTO_CXX 0x091
#define DEV_NAME       "sld,crypto_cxx_catapult"

/* <<--params-->> */
static unsigned crypto_algo;

static unsigned sha1_in_bytes;

static unsigned sha2_in_bytes;
static unsigned sha2_out_bytes;

static unsigned aes_tag_bytes;
static unsigned aes_aad_bytes;
static unsigned aes_in_bytes;
static unsigned aes_out_bytes;
static unsigned aes_iv_bytes;
static unsigned aes_key_bytes;
static unsigned aes_encryption;
static unsigned aes_oper_mode;

/* Other parameters */
// const unsigned sha1_in_words = 1600;
static unsigned sha1_in_words;
static unsigned sha1_out_words;
static unsigned sha1_out_bytes;

static unsigned sha2_in_words;
static unsigned sha2_out_words;

static unsigned aes_key_words;
static unsigned aes_iv_words;
static unsigned aes_in_words;
static unsigned aes_out_words;
static unsigned aes_aad_words;
static unsigned aes_tag_words;

static unsigned mem_bytes;  /* Total memory buffer size in bytes */
static unsigned mem_words;  /* Total memory buffer size in words */
static unsigned out_offset; /* Output offset in memory buffer */
static unsigned out_bytes;  /* Output buffer size in bytes */
static unsigned out_words;  /* Output buffer size in words */

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE  BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ? (_sz / CHUNK_SIZE) : (_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define CRYPTO_CXX_CRYPTO_ALGO_REG 0x40
#define CRYPTO_CXX_ENCRYPTION_REG  0x44

#define CRYPTO_CXX_SHA1_IN_BYTES_REG 0x48

#define CRYPTO_CXX_SHA2_IN_BYTES_REG  0x4C
#define CRYPTO_CXX_SHA2_OUT_BYTES_REG 0x50

#define CRYPTO_CXX_AES_OPER_MODE_REG   0x54
#define CRYPTO_CXX_AES_KEY_BYTES_REG   0x58
#define CRYPTO_CXX_AES_INPUT_BYTES_REG 0x5C
#define CRYPTO_CXX_AES_IV_BYTES_REG    0x60
#define CRYPTO_CXX_AES_AAD_BYTES_REG   0x64
#define CRYPTO_CXX_AES_TAG_BYTES_REG   0x68

//#define SHA1_ALGO 1
//#define SHA2_ALGO 2
//#define AES_ALGO 3

#if defined(SHA1_ALGO)
    #include "sha1_tests.h"
// #include "SHA1ShortMsg.h"
// #include "SHA1LongMsg.h"
#elif defined(SHA2_ALGO)
    #include "sha2_tests.h"
#elif defined(AES_ALGO)
    #include "aes_tests.h"
#else
    #error "Crypto algo is not defined!"
    #error "Compilation flags: [-DSHA1_ALGO | -DSHA2_ALGO | -DAES_ALGO]"
#endif

static int validate_buf(token_t *out, token_t *gold, unsigned out_words)
{
    int j;
    unsigned errors = 0;

    printf("INFO: gold output data @%p\n", gold);
    printf("INFO:      output data @%p\n", out);

    for (j = 0; j < out_words; j++) {
        token_t gold_data = gold[j];
        token_t out_data  = out[j];

        if (out_data != gold_data) {
            errors++;
#ifdef __DEBUG__
            printf("[%u] @%p %x (%x) %s\n", j, out + j, out_data, gold_data,
                   ((out_data != gold_data) ? " !!!" : ""));
#endif
        }
    }

    printf("INFO: Total errors %u\n", errors);

    return errors;
}

static inline uint64_t get_counter()
{
    uint64_t counter;
    asm volatile("li t0, 0;"
                 "csrr t0, mcycle;"
                 "mv %0, t0"
                 : "=r"(counter)
                 :
                 : "t0");
    return counter;
}

int main(int argc, char *argv[])
{
    int i;
    int n;
    int ndev;
    struct esp_device *espdevs;
    struct esp_device *dev;
    unsigned done;
    unsigned **ptable;
    token_t *mem;
    token_t *gold;
    unsigned errors = 0;

    // Search for the device
    printf("INFO: Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_CRYPTO_CXX, DEV_NAME);

    printf("INFO: Found %d devices: %s\n", ndev, DEV_NAME);

    if (ndev == 0) {
        printf("ERROR: crypto_cxx not found\n");
        return 0;
    }

    printf("INFO: sizeof(token_t) = %u B\n", sizeof(token_t));

    for (unsigned idx = 1; idx < N_TESTS; idx++) {

        printf("INFO: Test: %u / %u\n", idx, N_TESTS - 1);

#ifdef SHA1_ALGO
        crypto_algo = SHA1_ALGO;

        printf("INFO: === SHA1 ===\n");

        sha1_in_bytes  = sha1_raw_in_bytes[idx];
        sha1_in_words  = sha1_raw_in_words[idx];
        sha1_out_bytes = sha1_raw_out_bytes[idx];
        sha1_out_words = sha1_raw_out_words[idx];

        mem_bytes = sha1_in_bytes + sha1_out_bytes;

        out_offset = sha1_in_words;
        out_bytes  = sha1_out_bytes;

        // ATTENTION: SHA1 output is 5 32-bit words, DMA is 64 bits
        // Discard the last extra word
        out_words = sha1_out_words - 1;
#endif

#ifdef SHA2_ALGO
        crypto_algo = SHA2_ALGO;

        printf("INFO: === SHA2 ===\n");

        sha2_in_bytes  = sha2_raw_in_bytes[idx];
        sha2_in_words  = sha2_raw_in_words[idx];
        sha2_out_bytes = sha2_raw_out_bytes[idx];
        sha2_out_words = sha2_raw_out_words[idx];

        mem_bytes = sha2_in_bytes + sha2_out_bytes;

        out_offset = sha2_in_words;
        out_bytes  = sha2_out_bytes;
        out_words  = sha2_out_words;
#endif

#if defined(AES_ALGO) && defined(AES_ECB_OPERATION_MODE)
        crypto_algo = AES_ALGO;

        printf("INFO: === AES - ECB mode ===\n");

        aes_key_bytes = aes_ecb_raw_encrypt_key_bytes[idx];
        aes_key_words = aes_ecb_raw_encrypt_key_words[idx];

        aes_in_bytes = aes_ecb_raw_encrypt_plaintext_bytes[idx];
        aes_in_words = aes_ecb_raw_encrypt_plaintext_words[idx];

        aes_tag_bytes = 0;
        aes_aad_bytes = 0;
        aes_iv_bytes  = 0;

        out_offset = aes_key_words + aes_in_words;
        out_bytes  = aes_in_bytes;
        out_words  = aes_in_words;

        mem_bytes = aes_key_bytes + aes_in_bytes + out_bytes;
#endif

#if defined(AES_ALGO) && defined(AES_CTR_OPERATION_MODE)
        crypto_algo = AES_ALGO;

        printf("INFO: === AES - CTR mode ===\n");

        aes_key_bytes = aes_ctr_raw_encrypt_key_bytes[idx];
        aes_key_words = aes_ctr_raw_encrypt_key_words[idx];

        aes_iv_bytes = aes_ctr_raw_encrypt_iv_bytes[idx];
        aes_iv_words = aes_ctr_raw_encrypt_iv_words[idx];

        aes_in_bytes = aes_ctr_raw_encrypt_plaintext_bytes[idx];
        aes_in_words = aes_ctr_raw_encrypt_plaintext_words[idx];

        aes_tag_bytes = 0;
        aes_aad_bytes = 0;

        out_offset = aes_key_words + aes_iv_words + aes_in_words;
        out_bytes  = aes_in_bytes;
        out_words  = aes_in_words;

        mem_bytes = aes_key_bytes + aes_iv_bytes + aes_in_bytes + out_bytes;
#endif

#if defined(AES_ALGO) && defined(AES_CBC_OPERATION_MODE)
        crypto_algo = AES_ALGO;

        printf("INFO: === AES - CBC mode ===\n");

        aes_key_bytes = aes_cbc_raw_encrypt_key_bytes[idx];
        aes_key_words = aes_cbc_raw_encrypt_key_words[idx];

        aes_iv_bytes = aes_cbc_raw_encrypt_iv_bytes[idx];
        aes_iv_words = aes_cbc_raw_encrypt_iv_words[idx];

        aes_in_bytes = aes_cbc_raw_encrypt_plaintext_bytes[idx];
        aes_in_words = aes_cbc_raw_encrypt_plaintext_words[idx];

        aes_tag_bytes = 0;
        aes_aad_bytes = 0;

        out_offset = aes_key_words + aes_iv_words + aes_in_words;
        out_bytes  = aes_in_bytes;
        out_words  = aes_in_words;

        mem_bytes = aes_key_bytes + aes_iv_bytes + aes_in_bytes + out_bytes;
#endif

        // Allocate memory
        gold = aligned_malloc(out_bytes);
        mem  = aligned_malloc(mem_bytes);
        printf("INFO: Memory buffer\n");
        printf("INFO:   - base address = %p\n", mem);
        printf("INFO:   - size = %u B\n", mem_bytes);
        printf("INFO: Golden buffer\n");
        printf("INFO:   - base address = %p\n", gold);
        printf("INFO:   - size = %u B\n", out_bytes);

        // Alocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_bytes) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_bytes); i++)
            ptable[i] = (unsigned *)&mem[i * (CHUNK_SIZE / sizeof(token_t))];
        // printf("  ptable = %p\n", ptable);
        // printf("  nchunk = %lu\n", NCHUNK(mem_bytes));

        printf("INFO: Generate input...\n");

#ifdef SHA1_ALGO
        sha1_init_buf(idx, mem, gold, sha1_raw_in_words, sha1_raw_out_words, sha1_raw_inputs,
                      sha1_raw_outputs);
#endif

#ifdef SHA2_ALGO
        sha2_init_buf(idx, mem, gold, sha2_raw_in_words, sha2_raw_out_words, sha2_raw_inputs,
                      sha2_raw_outputs);
#endif

#if defined(AES_ALGO) && defined(AES_ECB_OPERATION_MODE)
        aes_init_buf(idx, mem, gold, aes_ecb_raw_encrypt_key_words, NULL,
                     aes_ecb_raw_encrypt_plaintext_words, aes_ecb_raw_encrypt_ciphertext_words,
                     aes_ecb_raw_encrypt_key, NULL, aes_ecb_raw_encrypt_plaintext,
                     aes_ecb_raw_encrypt_ciphertext);
#endif

#if defined(AES_ALGO) && defined(AES_CTR_OPERATION_MODE)
        aes_init_buf(idx, mem, gold, aes_ctr_raw_encrypt_key_words, aes_ctr_raw_encrypt_iv_words,
                     aes_ctr_raw_encrypt_plaintext_words, aes_ctr_raw_encrypt_ciphertext_words,
                     aes_ctr_raw_encrypt_key, aes_ctr_raw_encrypt_iv, aes_ctr_raw_encrypt_plaintext,
                     aes_ctr_raw_encrypt_ciphertext);
#endif

#if defined(AES_ALGO) && defined(AES_CBC_OPERATION_MODE)
        aes_init_buf(idx, mem, gold, aes_cbc_raw_encrypt_key_words, aes_cbc_raw_encrypt_iv_words,
                     aes_cbc_raw_encrypt_plaintext_words, aes_cbc_raw_encrypt_ciphertext_words,
                     aes_cbc_raw_encrypt_key, aes_cbc_raw_encrypt_iv, aes_cbc_raw_encrypt_plaintext,
                     aes_cbc_raw_encrypt_ciphertext);
#endif

        printf("INFO: Input ready!\n");

        // Pass common configuration parameters
        for (n = 0; n < ndev; n++) {

            dev = &espdevs[n];

            // Check DMA capabilities
            if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
                printf("ERROR: Scatter-gather DMA is disabled. Abort.\n");
                return 0;
            }

            if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_bytes)) {
                printf("ERROR: Not enough TLB entries available. Abort.\n");
                return 0;
            }

            // Pass common configuration parameters
            iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
            iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long)ptable);
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_bytes));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            // iowrite32(dev, SRC_OFFSET_REG, 0x0);
            // iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev, CRYPTO_CXX_CRYPTO_ALGO_REG, crypto_algo);
#ifdef SHA1_ALGO
            iowrite32(dev, CRYPTO_CXX_SHA1_IN_BYTES_REG, sha1_in_bytes);
#endif
#ifdef SHA2_ALGO
            iowrite32(dev, CRYPTO_CXX_SHA2_IN_BYTES_REG, sha2_in_bytes);
            iowrite32(dev, CRYPTO_CXX_SHA2_OUT_BYTES_REG, sha2_out_bytes);
#endif
#ifdef AES_ALGO
            iowrite32(dev, CRYPTO_CXX_AES_OPER_MODE_REG, AES_OPERATION_MODE);
            // iowrite32(dev, CRYPTO_CXX_AES_ENCRYPTION_REG, AES_ENCRYPTION_MODE);
            iowrite32(dev, CRYPTO_CXX_ENCRYPTION_REG, AES_ENCRYPTION_MODE);
            iowrite32(dev, CRYPTO_CXX_AES_KEY_BYTES_REG, aes_key_bytes);
            iowrite32(dev, CRYPTO_CXX_AES_INPUT_BYTES_REG, aes_in_bytes);
            iowrite32(dev, CRYPTO_CXX_AES_IV_BYTES_REG, aes_iv_bytes);
            iowrite32(dev, CRYPTO_CXX_AES_AAD_BYTES_REG, aes_aad_bytes);
            iowrite32(dev, CRYPTO_CXX_AES_TAG_BYTES_REG, aes_tag_bytes);
#endif

            // Flush (customize coherence model here)
            esp_flush(ACC_COH_NONE);
            // esp_flush(ACC_COH_RECALL);

            // Start accelerators
            printf("INFO: Accelerator start...\n");

            uint64_t begin = get_counter();

            iowrite32(dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            iowrite32(dev, CMD_REG, 0x0);
            uint64_t end = get_counter();

            printf("INFO: Accelerator done!\n");
            printf("INFO: Validating...\n");

#ifdef __DEBUG__
            for (i = 0; i < mem_words; i++) {
                printf("INFO: mem[%u] @%p %x\n", i, mem + i, mem[i]);
            }
#endif

            /* Validation */
            errors = validate_buf(mem + out_offset, gold, out_words);
            if (errors) {
                printf("ERROR: FAIL\n");
                aligned_free(ptable);
                aligned_free(mem);
                aligned_free(gold);
                return 1;
            }
            else {
                printf("INFO: Latency %lu clks\n", end - begin);
                printf("INFO: PASS\n");
            }
        }

        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);
    }
#if defined(SHA1_ALGO)
    printf("INFO: Crypto SHA1 DONE\n");
#elif defined(SHA2_ALGO)
    printf("INFO: Crypto SHA2 DONE\n");
#elif defined(AES_ALGO) && defined(AES_ECB_OPERATION_MODE)
    printf("INFO: Crypto AES ECB DONE\n");
#elif defined(AES_ALGO) && defined(AES_CTR_OPERATION_MODE)
    printf("INFO: Crypto AES CTR DONE\n");
#elif defined(AES_ALGO) && defined(AES_CBC_OPERATION_MODE)
    printf("INFO: Crypto AES CBC DONE\n");
#endif

    printf("INFO: DONE\n");

    return 0;
}
