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

#define SLD_AES_CXX 0x089
#define DEV_NAME "sld,aes_cxx_catapult"

/* <<--params-->> */
static unsigned tag_bytes;
static unsigned aad_bytes;
static unsigned in_bytes;
static unsigned out_bytes;
static unsigned iv_bytes;
static unsigned key_bytes;
static unsigned encryption;
static unsigned oper_mode;

static unsigned key_words;
static unsigned iv_words;
static unsigned in_words;
static unsigned out_words;
static unsigned aad_words;
static unsigned tag_words;

static unsigned key_size;
static unsigned iv_size;
static unsigned in_size;
static unsigned out_size;
static unsigned aad_size;
static unsigned tag_size;

static unsigned mem_size;

const unsigned aes_key_size = 8;
const unsigned aes_iv_size = 4;
const unsigned aes_in_size = 40;
const unsigned aes_out_size = 40;
const unsigned aes_aad_size = 32;
const unsigned aes_tag_size = 4;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 20
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK(_sz) ((_sz % CHUNK_SIZE == 0) ?        \
        (_sz / CHUNK_SIZE) :        \
        (_sz / CHUNK_SIZE) + 1)

         /* User defined registers */
         /* <<--regs-->> */
//#define AES_CXX_TAG_BYTES_REG 0x40
//#define AES_CXX_AAD_BYTES_REG 0x44
#define AES_CXX_INPUT_BYTES_REG 0x40
//#define AES_CXX_IV_BYTES_REG 0x52
#define AES_CXX_KEY_BYTES_REG 0x44
//#define AES_CXX_ENCRYPTION_REG 0x60
//#define AES_CXX_OPER_MODE_REG 0x64

#if 0
#define N_TESTS 10
static unsigned raw_encrypt_count[N_TESTS] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

static unsigned raw_encrypt_key[N_TESTS][4] = {
    {0xedfdb257, 0xcb37cdf1, 0x82c5455b, 0x0c0efebb},
    {0x7723d87d, 0x773a8bbf, 0xe1ae5b08, 0x1235b566},
    {0x280afe06, 0x3216a10b, 0x9cad9b20, 0x95552b16},
    {0xef60fb14, 0x00c83936, 0x414a2565, 0x1eb51a1b},
    {0xc5805cd1, 0xc4a7b98a, 0x715badb7, 0x09720bf4},
    {0x4c35be02, 0x8e147527, 0x8346eae5, 0x31cbee5c},
    {0x00cc73c9, 0x90d376b8, 0x2246e45e, 0xa3ae2e37},
    {0x0a53aa7a, 0x3e4a4f36, 0x4e8c6c72, 0x24af5501},
    {0xb80bcc92, 0x9052cb54, 0x50479442, 0xe2b809ce},
    {0xebea9c6a, 0x82213a00, 0xac1d22fa, 0xea22116f}};
static unsigned raw_encrypt_key_bytes[N_TESTS] = {4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4};
static unsigned raw_encrypt_key_words[N_TESTS] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4};

static unsigned raw_encrypt_plaintext[N_TESTS][40] = {
    {0x1695fe47, 0x5421cace, 0x3557daca, 0x01f445ff},
    {0x1b0a69b7, 0xbc534c16, 0xcecffae0, 0x2cc53231, 0x90ceb413, 0xf1db3e9f, 0x0f79ba65, 0x4c54b60e},
    {0x6f172bb6, 0xec364833, 0x411841a8, 0xf9ea2051, 0x735d6005, 0x38a9ea5e, 0x8cd2431a, 0x432903c1, 0xd6178988, 0xb616ed76, 0xe00036c5, 0xb28ccd8b},
    {0x59355931, 0x8cc66bf6, 0x95e49feb, 0x42794bdf, 0xb66bce89, 0x5ec222ca, 0x2609b133, 0xecf66ac7, 0x344d1302, 0x1e01e11a, 0x969c4684, 0xcbe20aba, 0xe2b19d3c, 0xeb2cacd4, 0x1419f21f, 0x1c865149},
    {0x84f809fc, 0x5c846523, 0x76cc0df1, 0x0095bc00, 0xb9f0547f, 0xa91a2d33, 0x10a0adbc, 0x9cc6191a, 0xde2aaa6f, 0xffa5e406, 0xaf722395, 0x5f9277bf, 0xb06eb1dd, 0x2bbfbefe, 0x32ab342c, 0x36302bf2, 0x2bc64e1b, 0x394032bb, 0xb5f4e674, 0x4f1bcbf2},
    {0x7adcf4a4, 0x94f6b097, 0x90c82c8b, 0xb97db62c, 0x5d3fa403, 0x2f06dfec, 0xeaad9ecb, 0x374b747b, 0xd1c08d07, 0xe78e351d, 0xc2eb99bf, 0xa714d23c, 0xffe31f5f, 0xb5a472e6, 0xe0252f35, 0xa20c304c, 0x4f6d0cf7, 0xd29c9944, 0x4d40af3a, 0x00a92fc8, 0x6c6444fc, 0xb80ce976, 0x5362ac1b, 0xdba0b10e},
    {0x37a1205e, 0xa929355d, 0x2e4ee52d, 0x5e1d9cda, 0x279ae01e, 0x640287cc, 0xb153276e, 0x7e0ecf2d, 0x633cf4f2, 0xb3afaecb, 0x548a2590, 0xce0445c6, 0xa168bac3, 0xdc601813, 0xeb74591b, 0xb1ce8dfc, 0xd740cdbb, 0x6388719e, 0x8cd283d9, 0xcc7e7369, 0x38240b41, 0x0dd5a6a4, 0x8ba49dd2, 0x066503e6, 0x3ab592ff, 0xdf3be49e, 0x7d2de74f, 0x82158b8c},
    {0xeaf1760c, 0x0f25310d, 0xada6debe, 0xb966304d, 0xb7a9f1b2, 0xd1c3af92, 0x2623b263, 0x649031d2, 0x99b3c561, 0x46d61d55, 0xb6ebf4cf, 0x8dd04039, 0xa4d1ace3, 0x146f49ee, 0x915f806a, 0xfad64cbb, 0x2d04a641, 0x20de4038, 0x2e2175dc, 0xae9480d1, 0xca8dedc3, 0x8fb64e4a, 0x40112f10, 0xf03a4c35, 0x4fed01f2, 0xc5c7017d, 0xbd514b2d, 0x443a5adf, 0xd2e49c98, 0x6723266c, 0xda41a69e, 0x6e459908},
    {0x8177d79c, 0x8f239178, 0x186b4dc5, 0xf1df2ea7, 0xfee7d0db, 0x535489ef, 0x983aefb3, 0xb2029aeb, 0xa0bb2b46, 0xa2b18c94, 0xa1417a33, 0xcbeb41ca, 0x7ea9c73a, 0x677fccd2, 0xeb5470c3, 0xc500f6d3, 0xf1a6c755, 0xc944ba58, 0x6f88921f, 0x6ae6c9d1, 0x94e78c72, 0x33c40612, 0x6633e144, 0xc3810ad2, 0x3ee1b5af, 0x4c04a22d, 0x49e99e70, 0x17f74c23, 0x09492569, 0xff49be17, 0xd2804920, 0xf2ac5f51, 0x4d13fd3e, 0x7318cc7c, 0xf80ca510, 0x1a465428},
    {0x451f4566, 0x3b44fd00, 0x5f3c288a, 0xe57b3838, 0x83f02d9a, 0xd3dc1715, 0xf9e3d694, 0x8564257b, 0x9b06d7dd, 0x51935fee, 0x580a96bb, 0xdfefb918, 0xb4e6b1da, 0xac809847, 0x465578cb, 0x8b5356ed, 0x38556f80, 0x1ff7c11e, 0xcba9cdd2, 0x63039c15, 0xd05900fc, 0x228e1caf, 0x302d261d, 0x7fb56cee, 0x663595b9, 0x6f192a78, 0xff445539, 0x3a5fe816, 0x2170a066, 0xfdaeac35, 0x019469f2, 0x2b347068, 0x6bced2f0, 0x07a1a2e4, 0x3e01b456, 0x2caaa502, 0xed541b82, 0x05874ec1, 0xffb1c8b2, 0x55766942}};
static unsigned raw_encrypt_plaintext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned raw_encrypt_plaintext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

static unsigned raw_encrypt_ciphertext[N_TESTS][40] = {
    {0x7888beae, 0x6e7a4263, 0x32a7eaa2, 0xf808e637},
    {0xad5b0895, 0x15e78210, 0x87c61652, 0xdc477ab1, 0xf2cc6331, 0xa70dfc59, 0xc9ffb0c7, 0x23c682f6},
    {0x4cc2a8f1, 0x3c8c7c36, 0xed6a814d, 0xb7f26900, 0xc7e04df4, 0x9cbad916, 0xce6a44d0, 0xae4fe7ed, 0xc0b40279, 0x4675b369, 0x4933ebbc, 0x356525d8},
    {0x3ea6f430, 0x5217bd47, 0xeebe773d, 0xa4b57854, 0x9cac744c, 0x00cbd8f9, 0xd596d380, 0x10304bd8, 0x50cc2f4b, 0x19a91c2e, 0x022eabf1, 0x00266185, 0xca270512, 0x7815dfd4, 0x6efbe4ec, 0xd46a3058},
    {0xa6dc096b, 0xc21b0658, 0xe416a0f6, 0x79fefc6e, 0x958e9c56, 0xe3ce04fd, 0xf6e392c2, 0xdb770a60, 0xd9523c25, 0x5925e14a, 0x3e02a100, 0x2bf3875c, 0x2e501bac, 0x618bee1f, 0x55f98504, 0x54854eef, 0x9d693d90, 0x937cc838, 0x7b6f4c44, 0x14e2080b},
    {0x22217953, 0xf71932ab, 0x4360d97e, 0xf4950815, 0x59f1fcb0, 0x9caca41f, 0xa0c65f7b, 0x1792b560, 0xeabe18f3, 0xb3b06ef8, 0x0c41886f, 0x24c5d6d3, 0x2d20427e, 0x83d8b556, 0x4d9ac743, 0x5a2842c1, 0xcf7c6fcc, 0x229eb7f5, 0x18d3e016, 0x7d510efb, 0xaee39a04, 0x38fc800e, 0xb6acfc20, 0x3c93280c},
    {0xc88e0338, 0x3ba9da6f, 0x982c057f, 0xe92c0bb3, 0xed5b9cd1, 0x8295a100, 0xe13a4e12, 0xd440b919, 0xbbb8b221, 0xabead362, 0x902ce44d, 0x30d0b80e, 0x56bee1f6, 0x6a7d8de0, 0xb1e1b4db, 0xf76c90c1, 0x807a3bc5, 0xf277e981, 0x4c82ab12, 0x0f7e1021, 0x7dfdf609, 0x2ce4958f, 0x8906c5e3, 0x2279c653, 0x7dd1fbae, 0x20cb7a1d, 0x9f89d049, 0x0b6aefc1},
    {0x5ece70a4, 0x4da41bc7, 0xcfb9b582, 0xea9ce098, 0x0030ec4a, 0xf331e764, 0x99961f88, 0x860aa055, 0x4aba3ecb, 0xf77ca429, 0x3a3fee85, 0x4a2caf3a, 0xe800343f, 0xb4521388, 0xb16b6dc5, 0x99b3d60b, 0xf82777f9, 0x8e1a8d04, 0xab9cd54d, 0xd9a24809, 0x5795d4df, 0xe4858bfd, 0x9a05f54c, 0x795bb086, 0xe15f7c22, 0x228184ec, 0x66a9ca10, 0xb1cf71a6, 0xbb9303c5, 0xcd1dcc05, 0x6460a86d, 0xf651f053},
    {0x5befb306, 0x2a7a7246, 0xaf1f77b0, 0xec0ac614, 0xe28be06a, 0xc2c81b19, 0xe5a0481b, 0xf160f9f2, 0xbc43f28f, 0x65487876, 0x39e4ce3e, 0x0f1e9547, 0x5f0e81ce, 0xb793004c, 0x8e46670e, 0xbd48b866, 0xd5b43d10, 0x4874ead4, 0xbe8a236b, 0xf90b48f8, 0x62f7e252, 0xdec4475f, 0xdbb841a6, 0x62efcd25, 0xed64b291, 0x0e9baaea, 0x9466e413, 0xa4241438, 0xb31df0bd, 0x3df9a16f, 0x46416367, 0x54e25986, 0x1728aa7d, 0xdf435cc5, 0x1f54f79a, 0x1db25f52},
    {0x01043053, 0xf832ef9b, 0x911ed387, 0xba577451, 0xe30d51d4, 0xb6b11f31, 0x9d4cd539, 0xd067b7f4, 0xf9b4f41f, 0x7f3d4e92, 0x0c57cbe2, 0xb5e1885a, 0xa66203ae, 0x493e93a1, 0xdf63793a, 0x9563c176, 0xbc6775dd, 0x09cc9161, 0xe278a01b, 0xeb8fd8a1, 0x9200326b, 0xd95abc5f, 0x716768e3, 0x4f90b505, 0x23d30fda, 0xbb103a3b, 0xc020afbb, 0xb0cb3bd2, 0xad512a6f, 0xea79f8d6, 0x4cef3474, 0x58dec48b, 0xe89451cb, 0x0b807d73, 0x593f273d, 0x9fc521b7, 0x89a77524, 0x404f43e0, 0x0f20b3b7, 0x7b938b1a}};
static unsigned raw_encrypt_ciphertext_bytes[N_TESTS] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned raw_encrypt_ciphertext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
#else
#define N_TESTS 2

static unsigned raw_encrypt_count[N_TESTS] = {0, 1};

static unsigned raw_encrypt_key[N_TESTS][4] = {
    {0xedfdb257, 0xcb37cdf1, 0x82c5455b, 0x0c0efebb},
    {0x7723d87d, 0x773a8bbf, 0xe1ae5b08, 0x1235b566}};
static unsigned raw_encrypt_key_bytes[N_TESTS] = {4*4, 4*4};
static unsigned raw_encrypt_key_words[N_TESTS] = {4, 4};

static unsigned raw_encrypt_plaintext[N_TESTS][40] = {
    {0x1695fe47, 0x5421cace, 0x3557daca, 0x01f445ff},
    {0x1b0a69b7, 0xbc534c16, 0xcecffae0, 0x2cc53231, 0x90ceb413, 0xf1db3e9f, 0x0f79ba65, 0x4c54b60e}};
static unsigned raw_encrypt_plaintext_bytes[N_TESTS] = {4*4, 8*4};
static unsigned raw_encrypt_plaintext_words[N_TESTS] = {4, 8};

static unsigned raw_encrypt_ciphertext[N_TESTS][40] = {
    {0x7888beae, 0x6e7a4263, 0x32a7eaa2, 0xf808e637},
    {0xad5b0895, 0x15e78210, 0x87c61652, 0xdc477ab1, 0xf2cc6331, 0xa70dfc59, 0xc9ffb0c7, 0x23c682f6}};
static unsigned raw_encrypt_ciphertext_bytes[N_TESTS] = {4*4, 8*4};
static unsigned raw_encrypt_ciphertext_words[N_TESTS] = {4, 8};
#endif

static int validate_buf(unsigned idx, token_t *out, token_t *gold)
{
    int j;
    unsigned errors = 0;

    printf("  gold output data @%p\n", gold);
    printf("       output data @%p\n", out);

    for (j = 0; j < raw_encrypt_ciphertext_words[idx]; j++)
    {
        token_t gold_data = gold[j];
        token_t out_data = out[j];

        if (out_data != gold_data)
        {
            errors++;
        }
        printf("[%u] %x (%x)\n", j, out_data, gold_data);
    }

    printf("  total errors %u\n", errors);

    return errors;
}

static void init_buf (unsigned idx, token_t *inputs, token_t * gold_outputs)
{
    int i, j;

    printf("  input data @%p\n", inputs);
    printf("  key_bytes %u\n", key_bytes);
    printf("  in_bytes %u\n", in_bytes);
    printf("  out_bytes %u\n", out_bytes);

    printf("  raw_encrypt_key_words %u\n", raw_encrypt_key_words[idx]);
    printf("  raw_encrypt_plaintext_words %u\n", raw_encrypt_plaintext_words[idx]);
    printf("  raw_encrypt_ciphertext_words %u\n", raw_encrypt_ciphertext_words[idx]);

    for (j = 0; j < raw_encrypt_key_words[idx]; j++)
    {
        inputs[j] = raw_encrypt_key[idx][j];
        printf("  raw_encrypt_key[%u][%u] @%p %x\n", idx, j, inputs + j, raw_encrypt_key[idx][j]);
    }

    for (i = 0; i < raw_encrypt_plaintext_words[idx]; i++, j++)
    {
        inputs[j] = raw_encrypt_plaintext[idx][i];
        printf("  raw_encrypt_plaintext[%u][%u] @%p %x\n", idx, i, inputs + i, raw_encrypt_plaintext[idx][i]);
    }

    printf("  gold output data @%p\n", gold_outputs);

    for (j = 0; j < raw_encrypt_ciphertext_words[idx]; j++) {
        gold_outputs[j] = raw_encrypt_ciphertext[idx][j];
        printf("  raw_encrypt_ciphertext[%u][%u] %x\n", idx, j, raw_encrypt_ciphertext[idx][j]);
    }
}

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
    printf("Scanning device tree... \n");

    ndev = probe(&espdevs, VENDOR_SLD, SLD_AES_CXX, DEV_NAME);

    printf("Found %d devices: %s\n", ndev, DEV_NAME);

    if (ndev == 0) {
        printf("aes_cxx not found\n");
        return 0;
    }

    printf("   sizeof(token_t) = %u\n", sizeof(token_t));

    for (unsigned idx = 1; idx < N_TESTS; idx++) {

        key_bytes = raw_encrypt_key_bytes[idx];
        key_words = raw_encrypt_key_words[idx];
	key_size = in_words * sizeof(token_t);

        in_bytes = raw_encrypt_plaintext_bytes[idx]; 
        in_words = raw_encrypt_plaintext_words[idx];        
        in_size = in_words * sizeof(token_t);

        out_bytes = in_bytes;
        out_words = in_words;
        out_size = out_words * sizeof(token_t);

        mem_size = key_size + in_size + out_size;

        // Allocate memory
        gold = aligned_malloc(out_size);
        mem = aligned_malloc(mem_size);
        printf("  memory buffer base-address = %p\n", mem);
        printf("  memory buffer size = %p\n", mem_size);
        printf("  golden buffer base-address = %p\n", gold);
        printf("  golden buffer size = %p\n", out_size);

        // Alocate and populate page table
        ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
        for (i = 0; i < NCHUNK(mem_size); i++)
            ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
        printf("  ptable = %p\n", ptable);
        printf("  nchunk = %lu\n", NCHUNK(mem_size));

        printf("  Generate input...\n");

        init_buf(idx, mem, gold);

        printf("  ... input ready!\n");
        printf("%s:%u\n", __func__, __LINE__);
#if 1
        // Pass common configuration parameters
        for (n = 0; n < ndev; n++) {

            dev = &espdevs[n];
            printf("%s:%u\n", __func__, __LINE__);

            // Check DMA capabilities
            if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
                printf("  -> scatter-gather DMA is disabled. Abort.\n");
                return 0;
            }
            printf("%s:%u\n", __func__, __LINE__);

            if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
                printf("  -> Not enough TLB entries available. Abort.\n");
                return 0;
            }
            printf("%s:%u\n", __func__, __LINE__);

            // Pass common configuration parameters
            iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
            iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
            iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
            iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
            iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
            printf("%s:%u\n", __func__, __LINE__);

            // Use the following if input and output data are not allocated at the default offsets
            //iowrite32(dev, SRC_OFFSET_REG, 0x0);
            //iowrite32(dev, DST_OFFSET_REG, 0x0);

            // Pass accelerator-specific configuration parameters
            /* <<--regs-config-->> */
            printf("%s:%u\n", __func__, __LINE__);
            //iowrite32(dev, AES_CXX_ENCRYPTION_REG, 1);
            printf("%s:%u\n", __func__, __LINE__);
            //iowrite32(dev, AES_CXX_OPER_MODE_REG, 1);
            printf("%s:%u\n", __func__, __LINE__);
            iowrite32(dev, AES_CXX_INPUT_BYTES_REG, in_bytes);
            printf("%s:%u\n", __func__, __LINE__);
            iowrite32(dev, AES_CXX_KEY_BYTES_REG, key_bytes);
            printf("%s:%u\n", __func__, __LINE__);

            // Flush (customize coherence model here)
            esp_flush(ACC_COH_NONE);
            printf("%s:%u\n", __func__, __LINE__);

            // Start accelerators
            printf("  Start...\n");

            iowrite32(dev, CMD_REG, CMD_MASK_START);

            // Wait for completion
            done = 0;
            while (!done) {
                done = ioread32(dev, STATUS_REG);
                done &= STATUS_MASK_DONE;
            }
            iowrite32(dev, CMD_REG, 0x0);

            printf("  Done\n");
            printf("  validating...\n");

            for (i = 0; i < in_words + out_words; i++) {
                printf("mem[%u] @%p %x\n", i, mem + i, mem[i]);
            }

            /* Validation */
            errors = validate_buf(idx, mem + in_words, gold);
            if (errors)
                printf("  ... FAIL\n");
            else
                printf("  ... PASS\n");

            aligned_free(ptable);
            aligned_free(mem);
            aligned_free(gold);
        }
#endif
    }
    printf("DONE\n");

    return 0;
}
