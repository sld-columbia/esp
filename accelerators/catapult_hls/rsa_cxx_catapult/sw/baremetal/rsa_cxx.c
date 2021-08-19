/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#include <stdlib.h>

#include <fixed_point.h>
#include <math.h>

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef uint32_t token_t;

static unsigned DMA_WORD_PER_BEAT(unsigned _st)
{
    return (sizeof(void *) / _st);
}

#define SLD_RSA_CXX 0x090
#define DEV_NAME "sld,rsa_cxx_catapult"

/* <<--params-->> */
static unsigned in_bytes;
static unsigned e_bytes;
static unsigned n_bytes;
static unsigned pubpriv;
static unsigned padding;
static unsigned encryption;

/* Other parameters */
static unsigned r_bytes;
static unsigned out_bytes;

static unsigned in_words;
static unsigned e_words;
static unsigned n_words;
static unsigned r_words;
static unsigned out_words;

static unsigned mem_bytes; /* Total memory buffer size in bytes */
static unsigned mem_words; /* Total memory buffer size in words */

static unsigned out_offset; /* Output offset in memory buffer in words */

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?        \
        (_sz / CHUNK_SIZE) :        \
        (_sz / CHUNK_SIZE) + 1)

/* User defined registers */
/* <<--regs-->> */
#define RSA_CXX_ENCRYPTION_REG 0x40
#define RSA_CXX_PADDING_REG 0x44
#define RSA_CXX_PUBPRIV_REG 0x48
#define RSA_CXX_N_BYTES_REG 0x4C
#define RSA_CXX_E_BYTES_REG 0x50
#define RSA_CXX_IN_BYTES_REG 0x54

/* Possible values for 'padding' */
#define RSA_NO_PADDING 0
#define RSA_ZERO_PADDING 1
#define RSA_PKCS1_PADDING 2

/* Possible values of 'encryption' */
#define ENCRYPTION_MODE 1
#define DECRYPTION_MODE 2

/* Possible values of 'pubpriv'*/
#define PRIVATE_KEY 1
#define PUBLIC_KEY 2

/* rsa/tests/simple/RSAPPKCS1_enc.fax */
#define N_TESTS 2

         // rsa/tests/simple/RSAPPKCS1_enc.fax
static unsigned rsa_raw_encrypt_count[N_TESTS] = {0, 1};

static unsigned rsa_raw_encrypt_EM[N_TESTS][64] = {
    {0xDE68F0FC, 0x00000000},
    //{0xfcf068de, 0x00000000},
    {0x5139D195, 0x0000003E}};
    //{0x95d13951, 0x3e000000}};

static unsigned rsa_raw_encrypt_EM_bytes[N_TESTS] = {4, 5};
static unsigned rsa_raw_encrypt_EM_words[N_TESTS] = {1, 2};

static unsigned rsa_raw_encrypt_e[N_TESTS][64] = {
    {0x5D2D1165, 0x963D09BE, 0xA4E082CE, 0xD273A7AD, 0x5EC6867C, 0x91A038F2, 0x61B51AB6, 0x935BC2C1, 0x7E37D57A, 0x5AFE1125, 0x37E83DBF, 0x940C3995, 0x6AD7EEF8, 0x7CB6F3EC, 0x003454DB, 0xC116E61C},
    //{0x65112d5d, 0xbe093d96, 0xce82e0a4, 0xada773d2, 0x7c86c65e, 0xf238a091, 0xb61ab561, 0xc1c25b93, 0x7ad5377e, 0x2511fe5a, 0xbf3de837, 0x95390c94, 0xf8eed76a, 0xecf3b67c, 0xdb543400, 0x1ce616c1},
    {0xF5053D2B, 0xB2750FDD, 0x2E62ED5A, 0x7E8125E6, 0xFA92AD8C, 0x5D0EC53B, 0x6B891FDF, 0x5946C0F9, 0x97F028C5, 0x4B52E5BF, 0xBBFEB5AF, 0x9718B0F3, 0x1F3FD37D, 0xADE069C3, 0x5D5257C3, 0x81C7BF79}};
    //{0x2b3d05f5, 0xdd0f75b2, 0x5aed622e, 0xe625817e, 0x8cad92fa, 0x3bc50e5d, 0xdf1f896b, 0xf9c04659, 0xc528f097, 0xbfe5524b, 0xafb5febb, 0xf3b01897, 0x7dd33f1f, 0xc369e0ad, 0xc357525d, 0x79bfc781}};
static unsigned rsa_raw_encrypt_e_bytes[N_TESTS] = {16*4, 16*4};
static unsigned rsa_raw_encrypt_e_words[N_TESTS] = {16, 16};

static unsigned rsa_raw_encrypt_n[N_TESTS][64] = {
    {0xFBCABB93, 0xDEFE61DB, 0x32AF44A6, 0xBD2C8A9E, 0x3E0F28E9, 0x1F2B2E5F, 0x079B2F5E, 0x038E85B5, 0x9F73EF9A, 0x3D7BFAFB, 0x87E7DA78, 0x7E263E6B, 0x44AEC1EF, 0x9F364E67, 0xF8BE172E, 0xF19A4795},
    //{0x93bbcafb, 0xdb61fede, 0xa644af32, 0x9e8a2cbd, 0xe9280f3e, 0x5f2e2b1f, 0x5e2f9b07, 0xb5858e03, 0x9aef739f, 0xfbfa7b3d, 0x78dae787, 0x6b3e267e, 0xefc1ae44, 0x674e369f, 0x2e17bef8, 0x95479af1},
    {0x69192780, 0xDF7C2740, 0xAD3F4F38, 0xAAE1B4D9, 0xE7FA48F4, 0xE9E04659, 0xBD3472ED, 0x95C0A3B8, 0x65A357C6, 0x3CCA45FD, 0xA95CA92D, 0x274CD443, 0x50CF0DFA, 0x80603F35, 0x6FBC24B5, 0x2906123D}};
    //{0x80271969, 0x40277cdf, 0x384f3fad, 0xd9b4e1aa, 0xf448fae7, 0x5946e0e9, 0xed7234bd, 0xb8a3c095, 0xc657a365, 0xfd45ca3c, 0x2da95ca9, 0x43d44c27, 0xfa0dcf50, 0x353f6080, 0xb524bc6f, 0x3d120629}};
static unsigned rsa_raw_encrypt_n_bytes[N_TESTS] = {16*4, 16*4};
static unsigned rsa_raw_encrypt_n_words[N_TESTS] = {16, 16};

static unsigned rsa_raw_encrypt_r[N_TESTS][64] = { // it SHOULD be computed on the fly
    {0xE6F3F792, 0xDB5E8395, 0x37B4F549, 0x168ED6FC, 0x1FDF6497, 0x702BEF1A, 0x312474B5, 0x7CFB434E, 0xC0E6817A, 0xCF3E60C3, 0x29FB9D4A, 0x16645B82, 0xB88FD285, 0x1EAC5F1D, 0x935FE9EA, 0xE29E545A},
    {0x7159D55E, 0xE312F2EF, 0x55B65B59, 0x6D686A48, 0x1286C2EC, 0x8FA09B31, 0x77B1EA8A, 0x9F61AAB5, 0x4F547B4D, 0x052A7797, 0x867B9350, 0x5848C37E, 0x6ECB2556, 0x90495615, 0xA4349449, 0x643164E4}};
static unsigned rsa_raw_encrypt_r_bytes[N_TESTS] = {16*4, 16*4};
static unsigned rsa_raw_encrypt_r_words[N_TESTS] = {16, 16};

static unsigned rsa_raw_encrypt_S[N_TESTS][64] = {
    {0x06783C4C, 0x0B3ECF73, 0x0FAA4AE2, 0xC893F987, 0x41A96490, 0x603BDDD2, 0x8DF79D91, 0xAB35287E, 0xF5196A76, 0x80BB8E2F, 0xCCDABCCC, 0x1074A819, 0x14B57CDB, 0x3ED16BDD, 0x96E14584, 0x8107E106},
    //{0x4c3c7806, 0x73cf3e0b, 0xe24aaa0f, 0x87f993c8, 0x9064a941, 0xd2dd3b60, 0x919df78d, 0x7e2835ab, 0x766a19f5, 0x2f8ebb80, 0xccbcdacc, 0x19a87410, 0xdb7cb514, 0xdd6bd13e, 0x8445e196, 0x06e10781},
    {0x67758210, 0x4D234D19, 0x079197F2, 0x8AD971EB, 0x7979C28A, 0x26DC9BAA, 0x07379083, 0x4037B902, 0x08D9EE84, 0x6132A3D4, 0x5339F9DB, 0xDFA892CB, 0x547DA49E, 0xC0777927, 0x66698BFD, 0x2406C941}};
    //{0x10827567, 0x194d234d, 0xf2979107, 0xeb71d98a, 0x8ac27979, 0xaa9bdc26, 0x83903707, 0x02b93740, 0x84eed908, 0xd4a33261, 0xdbf93953, 0xcb92a8df, 0x9ea47d54, 0x277977c0, 0xfd8b6966, 0x41c90624}};
static unsigned rsa_raw_encrypt_S_bytes[N_TESTS] = {16*4, 16*4};
static unsigned rsa_raw_encrypt_S_words[N_TESTS] = {16, 16};


static int validate_buf(unsigned idx, token_t *out, token_t *gold, unsigned *raw_encrypt_S_words)
{
    int j;
    unsigned errors = 0;

    printf("INFO: gold output data @%p\n", gold);
    printf("INFO:      output data @%p\n", out);

    for (j = 0; j < rsa_raw_encrypt_S_words[idx]; j++)
    {
        token_t gold_data = gold[j];
        token_t out_data = out[j];

        if (out_data != gold_data)
        {
            errors++;
#ifdef __DEBUG__
            printf("INFO: [%u] @%p %x (%x) %s\n", j, out + j, out_data, gold_data, ((out_data != gold_data)?" !!!":""));
#endif
        }
    }

    printf("INFO: Total errors %u\n", errors);

    return errors;
}

static void init_buf(unsigned idx, token_t *inputs, token_t *gold_outputs, unsigned *raw_encrypt_EM_words, unsigned *raw_encrypt_e_words, unsigned *raw_encrypt_n_words, unsigned *raw_encrypt_S_words, unsigned rsa_raw_encrypt_EM[][64], unsigned rsa_raw_encrypt_e[][64], unsigned rsa_raw_encrypt_n[][64], unsigned rsa_raw_encrypt_S[][64])
{
    int i, j;

    printf("INFO:   input data @%p\n", inputs);
    //printf("INFO:   key_bytes %u\n", key_bytes);
    //printf("INFO:   in_bytes %u\n", in_bytes);
    //printf("INFO:   out_bytes %u\n", out_bytes);

    printf("INFO:   rsa_raw_encrypt_EM_words %u\n", rsa_raw_encrypt_EM_words[idx]);
    printf("INFO:   rsa_raw_encrypt_e_words %u\n", rsa_raw_encrypt_e_words[idx]);
    printf("INFO:   rsa_raw_encrypt_n_words %u\n", rsa_raw_encrypt_n_words[idx]);
    printf("INFO:   rsa_raw_encrypt_S_words %u\n", rsa_raw_encrypt_S_words[idx]);

    for (j = 0; j < rsa_raw_encrypt_EM_words[idx]; j++)
    {
        inputs[j] = rsa_raw_encrypt_EM[idx][j];
#ifdef __DEBUG__
        printf("INFO:   rsa_raw_encrypt_EM[%2u][%2u]       | inputs[%3u]@%p %8x\n", idx, j, j, inputs + j, rsa_raw_encrypt_EM[idx][j]);
#endif
    }

    for (i = 0; i < rsa_raw_encrypt_e_words[idx]; i++, j++)
    {
        inputs[j] = rsa_raw_encrypt_e[idx][i];
#ifdef __DEBUG__
        printf("INFO:   rsa_raw_encrypt_e [%2u][%2u]       | inputs[%3u]@%p %8x\n", idx, i, j, inputs + j, rsa_raw_encrypt_e[idx][i]);
#endif
    }

    for (i = 0; i < rsa_raw_encrypt_n_words[idx]; i++, j++)
    {
        inputs[j] = rsa_raw_encrypt_n[idx][i];
#ifdef __DEBUG__
        printf("INFO:   rsa_raw_encrypt_n [%2u][%2u]       | inputs[%3u]@%p %8x\n", idx, i, j, inputs + j, rsa_raw_encrypt_n[idx][i]);
#endif
    }

    // hardcoded
    //calc_res(rsa_raw_encrypt_n_bytes[idx], (unsigned char*)rsa_raw_encrypt_n[idx], (unsigned char*)rsa_raw_encrypt_r[idx]);

    for (i = 0; i < rsa_raw_encrypt_r_words[idx]; i++, j++)
    {
        inputs[j] = rsa_raw_encrypt_r[idx][i];
#ifdef __DEBUG__
        printf("INFO:   rsa_raw_encrypt_r [%2u][%2u]       | inputs[%3u]@%p %8x\n", idx, i, j, inputs + j, rsa_raw_encrypt_r[idx][i]);
#endif
    }

    for (i = 0; i < rsa_raw_encrypt_S_words[idx]; i++, j++)
    {
        inputs[j] = 0xdeadbeef;
#ifdef __DEBUG__
        printf("INFO:                                    | inputs[%3u]@%p %8x\n", j, inputs + j, 0xdeadbeef);
#endif
    }

#ifdef __DEBUG__
    printf("INFO:   gold output data @%p\n", gold_outputs);
#endif

    for (j = 0; j < rsa_raw_encrypt_S_words[idx]; j++) {
        gold_outputs[j] = rsa_raw_encrypt_S[idx][j];
#ifdef __DEBUG__
        printf("INFO:   rsa_raw_encrypt_S [%2u][%2u]       | gold[%3u]  @%p %8x\n", idx, j, j, gold_outputs + j, rsa_raw_encrypt_S[idx][j]);
#endif
    }
}

#define ROUND_UP(a) ((a+4-1)/4)*4

int main(int argc, char * argv[])
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

    ndev = probe(&espdevs, VENDOR_SLD, SLD_RSA_CXX, DEV_NAME);

    printf("INFO: Found %d devices: %s\n", ndev, DEV_NAME);

    if (ndev == 0) {
        printf("ERROR: rsa_cxx not found\n");
        return 0;
    }

    printf("INFO: sizeof(token_t) = %u\n", sizeof(token_t));

    for (unsigned idx = 1; idx < N_TESTS; idx++) {

        in_bytes = rsa_raw_encrypt_EM_bytes[idx];
        in_words = rsa_raw_encrypt_EM_words[idx];

        e_bytes = rsa_raw_encrypt_e_bytes[idx];
        e_words = rsa_raw_encrypt_e_words[idx];

        n_bytes = rsa_raw_encrypt_n_bytes[idx];
        n_words = rsa_raw_encrypt_n_words[idx];

        r_bytes = rsa_raw_encrypt_r_bytes[idx];
        r_words = rsa_raw_encrypt_r_words[idx];

        out_bytes = n_bytes;
        out_words = n_words;

        mem_bytes = ROUND_UP(in_bytes) + e_bytes + n_bytes + r_bytes + ROUND_UP(out_bytes); // TODO: cleanup byte rounding
        mem_words = in_words + e_words + n_words + r_words + out_words;
        out_offset = in_words + e_words + n_words + r_words;

        // Allocate memory
        gold = aligned_malloc(out_bytes);
        mem = aligned_malloc(mem_bytes);
        printf("INFO: Memory buffer\n");
        printf("INFO:   - base address = %p\n", mem);
        printf("INFO:   - size = %u B\n", mem_bytes);
        printf("INFO: Golden buffer\n");
        printf("INFO:   - base address = %p\n", gold);
        printf("INFO:   - size = %u B\n", out_bytes);

        // Alocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_bytes) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_bytes); i++)
            ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
        //printf("INFO:   ptable = %p\n", ptable);
        //printf("INFO:   nchunk = %lu\n", NCHUNK(mem_bytes));

        printf("INFO: Generate input...\n");

        init_buf(idx, mem, gold, rsa_raw_encrypt_EM_words, rsa_raw_encrypt_e_words, rsa_raw_encrypt_n_words, rsa_raw_encrypt_S_words, rsa_raw_encrypt_EM, rsa_raw_encrypt_e, rsa_raw_encrypt_n, rsa_raw_encrypt_S);

        printf("INFO: Input ready!\n");

        // Pass common configuration parameters
        for (n = 0; n < ndev; n++) {

            dev = &espdevs[n];

            // Check DMA capabilities
            if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
                printf("INFO: Scatter-gather DMA is disabled. Abort.\n");
                return 0;
            }

            if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_bytes)) {
                printf("ERROR: Not enough TLB entries available. Abort.\n");
                return 0;
            }

            // Pass common configuration parameters
            iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
            iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_bytes));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

            // Use the following if input and output data are not allocated at the default offsets
            //iowrite32(dev, SRC_OFFSET_REG, 0x0);
            //iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            iowrite32(dev, RSA_CXX_ENCRYPTION_REG, ENCRYPTION_MODE);
            iowrite32(dev, RSA_CXX_PADDING_REG, RSA_PKCS1_PADDING);
            iowrite32(dev, RSA_CXX_PUBPRIV_REG, PRIVATE_KEY);
            iowrite32(dev, RSA_CXX_N_BYTES_REG, n_bytes);
            iowrite32(dev, RSA_CXX_E_BYTES_REG, e_bytes);
            iowrite32(dev, RSA_CXX_IN_BYTES_REG, in_bytes);

            // Flush (customize coherence model here)
            //esp_flush(ACC_COH_NONE);

            // Start accelerators
            printf("INFO: Accelerator start...\n");

            iowrite32(dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            iowrite32(dev, CMD_REG, 0x0);

            printf("INFO: Accelerator done\n");
            printf("INFO: Validating...\n");

            /* Validation */
            //for (i = 0; i < mem_words; i++) {
            //    printf("INFO: mem[%u] @%p %x\n", i, mem + i, mem[i]);
            //}

            errors = validate_buf(idx, mem + out_offset, gold, rsa_raw_encrypt_S_words);

            if (errors) {
                printf("ERROR: FAIL\n");
                aligned_free(ptable);
                aligned_free(mem);
                aligned_free(gold);
                return 1;
            } else
                printf("INFO: PASS\n");
        }

        aligned_free(ptable);
        aligned_free(mem);
        aligned_free(gold);

    }
    printf("INFO: DONE\n");

    return 0;
}
