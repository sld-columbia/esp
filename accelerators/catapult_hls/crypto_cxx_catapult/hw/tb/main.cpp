//#include "../inc/espacc_config.h"
//#include "../inc/espacc.h"

#include "crypto_cxx_catapult.hpp"
#include "esp_headers.hpp" // ESP-common headers

#include <cstdlib>
#include <cstdio>

#include <mc_scverify.h>   // Enable SCVerify

//#define SHA1_ALGO 1
#define SHA2_ALGO 2

#ifdef SHA1_ALGO
// This can be read from a file (and should)
#define N_TESTS 12

static unsigned sha1_raw_in_bytes[N_TESTS] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 64, 262};

static unsigned sha1_raw_inputs[N_TESTS][1600] = {
    {0x00000000, 0x00000000},
    {0x36000000, 0x00000000},
    {0x195a0000, 0x00000000},
    {0xdf4bd200, 0x00000000},
    {0x549e959e, 0x00000000},
    {0xf7fb1be2, 0x05000000},
    {0xc0e5abea, 0xea630000},
    {0x63bfc1ed, 0x7f78ab00},
    {0x7e3d7b3e, 0xada98866},
    {0x9e61e55d, 0x9ed37b1c, 0x20000000, 0x00000000},
    {0x45927e32, 0xddf801ca, 0xf35e18e7, 0xb5078b7f, 0x54352782, 0x12ec6bb9, 0x9df884f4, 0x9b327c64, // SHA1ShortMsg 512
     0x86feae46, 0xba187dc1, 0xcc914512, 0x1e1492e6, 0xb06e9007, 0x394dc33b, 0x7748f86a, 0xc3207cfe},
    {0x6cb70d19, 0xc096200f, 0x9249d2db, 0xc04299b0, 0x085eb068, 0x257560be, 0x3a307dbd, 0x741a3378, // SHA1LongMsg 2096
     0xebfa03fc, 0xca610883, 0xb07f7fea, 0x563a8665, 0x71822472, 0xdade8a0b, 0xec4b9820, 0x2d47a344,
     0x312976a7, 0xbcb39644, 0x27eacb5b, 0x0525db22, 0x066599b8, 0x1be41e5a, 0xdaf157d9, 0x25fac04b,
     0x06eb6e01, 0xdeb753ba, 0xbf33be16, 0x162b214e, 0x8db01721, 0x2fafa512, 0xcdc8c0d0, 0xa15c10f6,
     0x32e8f4f4, 0x7792c64d, 0x3f026004, 0xd173df50, 0xcf0aa797, 0x6066a79a, 0x8d78deee, 0xec951dab,
     0x7cc90f68, 0xd16f7866, 0x71feba0b, 0x7d269d92, 0x941c4f02, 0xf432aa5c, 0xe2aab619, 0x4dcc6fd3,
     0xae36c843, 0x3274ef6b, 0x1bd0d314, 0x636be47b, 0xa38d1948, 0x343a38bf, 0x9406523a, 0x0b2a8cd7,
     0x8ed6266e, 0xe3c9b5c6, 0x0620b308, 0xcc6b3a73, 0xc6060d52, 0x68a7d82b, 0x6a33b93a, 0x6fd6fe1d,
     0xe55231d1, 0x2c970000}};


static unsigned sha1_raw_outputs[N_TESTS][6] = {
    {0xda39a3ee, 0x5e6b4b0d, 0x3255bfef, 0x95601890, 0xafd80709, 0x0},
    {0xc1dfd96e, 0xea8cc2b6, 0x2785275b, 0xca38ac26, 0x1256e278, 0x0},
    {0x0a1c2d55, 0x5bbe431a, 0xd6288af5, 0xa54f93e0, 0x449c9232, 0x0},
    {0xbf36ed5d, 0x74727dfd, 0x5d7854ec, 0x6b1d4946, 0x8d8ee8aa, 0x0},
    {0xb78bae6d, 0x14338ffc, 0xcfd5d5b5, 0x674a275f, 0x6ef9c717, 0x0},
    {0x60b7d5bb, 0x560a1acf, 0x6fa45721, 0xbd0abb41, 0x9a841a89, 0x0},
    {0xa6d33845, 0x9780c083, 0x63090fd8, 0xfc7d28dc, 0x80e8e01f, 0x0},
    {0x860328d8, 0x0509500c, 0x1783169e, 0xbf0ba0c4, 0xb94da5e5, 0x0},
    {0x24a2c34b, 0x97630527, 0x7ce58c2f, 0x42d50920, 0x31572520, 0x0},
    {0x411ccee1, 0xf6e3677d, 0xf1269841, 0x1eb09d3f, 0xf580af97, 0x0},
    {0xa70cfbfe, 0x7563dd0e, 0x665c7c67, 0x15a96a8d, 0x756950c0, 0x0}, // SHA1ShortMsg 512
    {0x4a75a406, 0xf4de5f9e, 0x1132069d, 0x66717fc4, 0x24376388, 0x0}}; // SHA1LongMsg 2096
#endif

#ifdef SHA2_ALGO
// This can be read from a file (and should)
#define N_TESTS 11

static unsigned sha2_raw_in_bytes[N_TESTS] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 64};
static unsigned sha2_raw_out_bytes[N_TESTS] = {28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28};

static unsigned sha2_raw_inputs[N_TESTS][1600] = {
    {0x00000000, 0x00000000},
    {0x84000000, 0x00000000},
    {0x5c7b0000, 0x00000000},
    {0x51ca3d00, 0x00000000},
    {0x6084347e, 0x00000000},
    {0x493e1462, 0x3c000000},
    {0xd729d8cd, 0x16310000},
    {0xcbf2061e, 0x10faa500},
    {0x5f77b366, 0x4823c33e},
    {0x10713b89, 0x4de4a734, 0xc0000000, 0x00000000},
    {0xa3310ba0, 0x64be2e14, 0xad32276e, 0x18cd0310, 0xc933a6e6, 0x50c3c754, 0xd0243c6c, 0x61207865,
     0xb4b65248, 0xf66a08ed, 0xf6e08326, 0x89a9dc3a, 0x2e5d2095, 0xeeea50bd, 0x862bac88, 0xc8bd318d}}; // 512, SHA224ShortMsg.rsp

static unsigned sha2_raw_outputs[N_TESTS][8] = {
    {0xd14a028c, 0x2a3a2bc9, 0x476102bb, 0x288234c4, 0x15a2b01f, 0x828ea62a, 0xc5b3e42f, 0x0},
    {0x3cd36921, 0xdf5d6963, 0xe73739cf, 0x4d20211e, 0x2d8877c1, 0x9cff087a, 0xde9d0e3a, 0x0},
    {0xdaff9bce, 0x685eb831, 0xf97fc122, 0x5b03c275, 0xa6c112e2, 0xd6e76f5f, 0xaf7a36e6, 0x0},
    {0x2c895902, 0x3515476e, 0x38388abb, 0x43599a29, 0x876b4b33, 0xd56adc06, 0x032de3a2, 0x0},
    {0xae57c0a6, 0xd49739ba, 0x338adfa5, 0x3bdae063, 0xe5c09122, 0xb7760478, 0x0a8eeaa3, 0x0},
    {0x7f631f29, 0x5e024e74, 0x55208324, 0x5ca8f988, 0xa3fb6568, 0x0ae97c30, 0x40d2e65c, 0x0},
    {0x342e8e6b, 0x23c1c6a5, 0x4910631f, 0x098e08e8, 0x36259c57, 0xe49c1b1d, 0x023d166d, 0x0},
    {0x3aa702b1, 0xb66dc57d, 0x7aec3ccd, 0xbdfbd885, 0x92d7520f, 0x843ba5d0, 0xfa481168, 0x0},
    {0xbdf21ff3, 0x25f75415, 0x7ccf417f, 0x4855360a, 0x72e8fd11, 0x7d28c8fe, 0x7da3ea38, 0x0},
    {0x03842600, 0xc86f5cd6, 0x0c3a2147, 0xa067cb96, 0x2a05303c, 0x3488b05c, 0xb45327bd, 0x0},
    {0xb2a5586d, 0x9cbf0baa, 0x999157b4, 0xaf06d88a, 0xe08d7c9f, 0xaab4bc1a, 0x96829d65, 0x0}};
#endif

#ifdef __CUSTOM_SIM__
int sc_main(int argc, char **argv) {
#else
CCS_MAIN(int argc, char **argv) {
#endif

#ifdef SHA1_ALGO
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - SHA1 [Catapult HLS C++]");
    ESP_REPORT_INFO(VON, "      Single block");
    ESP_REPORT_INFO(VON, "--------------------------------");
#endif

#ifdef SHA2_ALGO
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - SHA2 [Catapult HLS C++]");
    ESP_REPORT_INFO(VON, "      Single block");
    ESP_REPORT_INFO(VON, "--------------------------------");
#endif

    const unsigned sha1_in_size = SHA1_PLM_IN_SIZE;
    const unsigned sha1_out_size = SHA1_PLM_OUT_SIZE;

    // Testbench return value (0 = PASS, non-0 = FAIL)
    int rc = 0;

    // Accelerator configuration
    ac_channel<conf_info_t> conf_info;
    conf_info_t conf_info_data;

    // Communication channels
    ac_channel<dma_info_t> dma_read_ctrl;
    ac_channel<dma_info_t> dma_write_ctrl;
    ac_channel<dma_data_t> dma_read_chnl;
    ac_channel<dma_data_t> dma_write_chnl;

    // Accelerator done (workaround)
    ac_sync acc_done;

    // Testbench data
    ac_int<WL, false> sha1_inputs[SHA1_PLM_IN_SIZE];
    ac_int<WL, false> sha1_outputs[SHA1_PLM_OUT_SIZE];
    ac_int<WL, false> sha1_gold_outputs[SHA1_PLM_OUT_SIZE];
    ac_int<WL, false> sha2_inputs[SHA2_PLM_IN_SIZE];
    ac_int<WL, false> sha2_outputs[SHA2_PLM_OUT_SIZE];
    ac_int<WL, false> sha2_gold_outputs[SHA2_PLM_OUT_SIZE];

    ESP_REPORT_INFO(VON, "DMA & PLM info:");
    ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
    ESP_REPORT_INFO(VON, "  - SHA1 PLM in size: %u", SHA1_PLM_IN_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA1 PLM out size: %u", SHA1_PLM_OUT_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA1 PLM width: %u", SHA1_PLM_WIDTH);
    ESP_REPORT_INFO(VON, "  - SHA2 PLM in size: %u", SHA2_PLM_IN_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA2 PLM out size: %u", SHA2_PLM_OUT_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA2 PLM width: %u", SHA2_PLM_WIDTH);
    //ESP_REPORT_INFO(VON, "  - SHA1 in (words): %u", sha1_in_size);
    //ESP_REPORT_INFO(VON, "  - SHA1 out (words): %u", sha1_out_size);
    //ESP_REPORT_INFO(VON, "  - total memory in (words): %u", sha1_in_size);
    //ESP_REPORT_INFO(VON, "  - total memory out (words): %u", sha1_out_size);
    ESP_REPORT_INFO(VON, "-----------------");

    // Iterate over test length
    for (unsigned t = 1; t < N_TESTS; t++) {

#ifdef SHA1_ALGO
        conf_info_data.crypto_algo = SHA1_ALGO;
        conf_info_data.sha1_in_bytes = sha1_raw_in_bytes[t];
        unsigned sha1_in_words = (ESP_TO_UINT32(conf_info_data.sha1_in_bytes) + 4 - 1)/4;

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - sha1_in_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.sha1_in_bytes), sha1_in_words);
#endif

#ifdef SHA2_ALGO
        conf_info_data.crypto_algo = SHA2_ALGO;
        conf_info_data.sha2_in_bytes = sha2_raw_in_bytes[t];
        conf_info_data.sha2_out_bytes = sha2_raw_out_bytes[t];
        unsigned sha2_in_words = (ESP_TO_UINT32(conf_info_data.sha2_in_bytes) + 4 - 1)/4;
        unsigned sha2_out_words = (ESP_TO_UINT32(conf_info_data.sha2_out_bytes) + 4 - 1)/4;

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - sha2_in_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.sha2_in_bytes), sha2_in_words);
        ESP_REPORT_INFO(VON, "  - sha2_out_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.sha2_out_bytes), sha2_out_words);
#endif

#ifdef SHA1_ALGO
        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //
        // Pass inputs to the accelerator
        for (unsigned j = 0; j < sha1_in_words; j+=2) {
            ac_int<WL, false> data_fp_0(sha1_raw_inputs[t][j+0]);
            ac_int<WL, false> data_fp_1(sha1_raw_inputs[t][j+1]);

            sha1_inputs[j+0] = data_fp_0;
            sha1_inputs[j+1] = data_fp_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, sha1_inputs[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, sha1_inputs[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }
#endif


#ifdef SHA2_ALGO
        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //
        // Pass inputs to the accelerator
        for (unsigned j = 0; j < sha2_in_words; j+=2) {
            ac_int<WL, false> data_fp_0(sha2_raw_inputs[t][j+0]);
            ac_int<WL, false> data_fp_1(sha2_raw_inputs[t][j+1]);

            sha2_inputs[j+0] = data_fp_0;
            sha2_inputs[j+1] = data_fp_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, sha2_inputs[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, sha2_inputs[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }
#endif

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
#ifdef __CUSTOM_SIM__
        crypto_cxx_catapult(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#else
        CCS_DESIGN(crypto_cxx_catapult)(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#endif

#ifdef SHA1_ALGO
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(sha1_out_size/2)) {} // Testbench stalls until data ready
        for (unsigned i = 0; i < sha1_out_size; i+=2) {
            ac_int<DMA_WIDTH, false> data = dma_write_chnl.read().template slc<DMA_WIDTH>(0);
            ac_int<WL, false> data_0 = data.template slc<DMA_WIDTH>(WL*0);
            ac_int<WL, false> data_1 = data.template slc<DMA_WIDTH>(WL*1);
            sha1_outputs[i+0].template set_slc<WL>(0, data_0);
            sha1_outputs[i+1].template set_slc<WL>(0, data_1);
        }

        // Validation
        unsigned errors = 0;
        ESP_REPORT_INFO(VON, "-----------------");
        for (unsigned j = 0; j < sha1_out_size; j++) {
            sha1_gold_outputs[j] = sha1_raw_outputs[t][j];
        }

        for (unsigned i = 0; i < sha1_out_size; i++) {
            ac_int<WL, false> gold = sha1_gold_outputs[i];
            ac_int<WL, false> data = sha1_outputs[i];

            if (gold != data) {
                ESP_REPORT_INFO(VON, "[%u]: %X (expected %X)", i, data.to_uint(), gold.to_uint());
                errors++;
            }
        }

        if (errors > 0) {
            ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, sha1_out_size);
            rc |= 1;
        } else {
            ESP_REPORT_INFO(VON, "Validation: PASS");
            rc |= 0;
        }
        ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, sha1_out_size);
        ESP_REPORT_INFO(VON, "-----------------");
#endif

#ifdef SHA2_ALGO
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(sha2_out_words/2)) {} // Testbench stalls until data ready
        for (unsigned i = 0; i < sha2_out_words; i+=2) {
            ac_int<DMA_WIDTH, false> data = dma_write_chnl.read().template slc<DMA_WIDTH>(0);
            ac_int<WL, false> data_0 = data.template slc<DMA_WIDTH>(WL*0);
            ac_int<WL, false> data_1 = data.template slc<DMA_WIDTH>(WL*1);
            sha2_outputs[i+0].template set_slc<WL>(0, data_0);
            sha2_outputs[i+1].template set_slc<WL>(0, data_1);
        }

        // Validation
        unsigned errors = 0;
        ESP_REPORT_INFO(VON, "-----------------");
        for (unsigned j = 0; j < sha2_out_words; j++) {
            sha2_gold_outputs[j] = sha2_raw_outputs[t][j];
        }

        for (unsigned i = 0; i < sha2_out_words; i++) {
            ac_int<WL, false> gold = sha2_gold_outputs[i];
            ac_int<WL, false> data = sha2_outputs[i];

            if (gold != data) {
                ESP_REPORT_INFO(VON, "[%u]: %X (expected %X)", i, data.to_uint(), gold.to_uint());
                errors++;
            }
        }

        if (errors > 0) {
            ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, sha2_out_words);
            rc |= 1;
        } else {
            ESP_REPORT_INFO(VON, "Validation: PASS");
            rc |= 0;
        }
        ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, sha2_out_words);
        ESP_REPORT_INFO(VON, "-----------------");
#endif

    }

#ifdef __CUSTOM_SIM__
    return rc;
#else
    CCS_RETURN(rc);
#endif
}
