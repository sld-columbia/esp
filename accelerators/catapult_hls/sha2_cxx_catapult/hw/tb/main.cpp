//#include "../inc/espacc_config.h"
//#include "../inc/espacc.h"

#include "sha2_cxx_catapult.hpp"
#include "esp_headers.hpp" // ESP-common headers

#include <cstdlib>
#include <cstdio>

#include <mc_scverify.h>   // Enable SCVerify

// This can be read from a file (and should)
static unsigned raw_in_bytes[12] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 64, 0};
static unsigned raw_out_bytes[12] = {28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28};

static unsigned raw_inputs[12][1600] = {
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
     0xb4b65248, 0xf66a08ed, 0xf6e08326, 0x89a9dc3a, 0x2e5d2095, 0xeeea50bd, 0x862bac88, 0xc8bd318d}, // 512, SHA224ShortMsg.rsp
    {0x0, 0x0}};

static unsigned raw_outputs[12][8] = {
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
    {0xb2a5586d, 0x9cbf0baa, 0x999157b4, 0xaf06d88a, 0xe08d7c9f, 0xaab4bc1a, 0x96829d65, 0x0},
    {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}};

#ifdef __CUSTOM_SIM__
int sc_main(int argc, char **argv) {
#else
CCS_MAIN(int argc, char **argv) {
#endif
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - SHA2 [Catapult HLS C++]");
    ESP_REPORT_INFO(VON, "      Single block");
    ESP_REPORT_INFO(VON, "--------------------------------");

    const unsigned sha2_in_size = PLM_IN_SIZE;
    const unsigned sha2_out_size = PLM_OUT_SIZE;

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
    ac_int<WL, false> inputs[PLM_IN_SIZE];
    ac_int<WL, false> outputs[PLM_OUT_SIZE];
    ac_int<WL, false> gold_outputs[PLM_OUT_SIZE];

    ESP_REPORT_INFO(VON, "DMA & PLM info:");
    ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
    ESP_REPORT_INFO(VON, "  - PLM in size: %u", PLM_IN_SIZE);
    ESP_REPORT_INFO(VON, "  - PLM out size: %u", PLM_OUT_SIZE);
    ESP_REPORT_INFO(VON, "  - PLM width: %u", PLM_WIDTH);
    //ESP_REPORT_INFO(VON, "  - SHA2 in (words): %u", sha2_in_size);
    //ESP_REPORT_INFO(VON, "  - SHA2 out (words): %u", sha2_out_size);
    //ESP_REPORT_INFO(VON, "  - total memory in (words): %u", sha2_in_size);
    //ESP_REPORT_INFO(VON, "  - total memory out (words): %u", sha2_out_size);
    ESP_REPORT_INFO(VON, "-----------------");

    // Iterate over test length
    for (unsigned t = 1; t < 2; t++) {

        conf_info_data.in_bytes = raw_in_bytes[t];
        conf_info_data.out_bytes = raw_out_bytes[t];

        unsigned in_words = (ESP_TO_UINT32(conf_info_data.in_bytes) + 4 - 1)/4;
        unsigned out_words = (ESP_TO_UINT32(conf_info_data.out_bytes) + 4 - 1)/4;

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - in_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.in_bytes), in_words);
        ESP_REPORT_INFO(VON, "  - out_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.out_bytes), out_words);


        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //
        // Pass inputs to the accelerator
        for (unsigned j = 0; j < in_words; j+=2) {
            ac_int<WL, false> data_fp_0(raw_inputs[t][j+0]);
            ac_int<WL, false> data_fp_1(raw_inputs[t][j+1]);

            inputs[j+0] = data_fp_0;
            inputs[j+1] = data_fp_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, inputs[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, inputs[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }
        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
#ifdef __CUSTOM_SIM__
        sha2_cxx_catapult(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#else
        CCS_DESIGN(sha2_cxx_catapult)(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#endif

        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(out_words/2)) {} // Testbench stalls until data ready
        for (unsigned i = 0; i < out_words; i+=2) {
            ac_int<DMA_WIDTH, false> data = dma_write_chnl.read().template slc<DMA_WIDTH>(0);
            ac_int<WL, false> data_0 = data.template slc<DMA_WIDTH>(WL*0);
            ac_int<WL, false> data_1 = data.template slc<DMA_WIDTH>(WL*1);
            outputs[i+0].template set_slc<WL>(0, data_0);
            outputs[i+1].template set_slc<WL>(0, data_1);
        }

        // Validation
        unsigned errors = 0;
        ESP_REPORT_INFO(VON, "-----------------");
        for (unsigned j = 0; j < out_words; j++) {
            gold_outputs[j] = raw_outputs[t][j];
        }

        for (unsigned i = 0; i < out_words; i++) {
            ac_int<WL, false> gold = gold_outputs[i];
            ac_int<WL, false> data = outputs[i];

            if (gold != data) {
                ESP_REPORT_INFO(VON, "[%u]: %X (expected %X)", i, data.to_uint(), gold.to_uint());
                errors++;
            }
        }

        if (errors > 0) {
            ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, out_words);
            rc |= 1;
        } else {
            ESP_REPORT_INFO(VON, "Validation: PASS");
            rc |= 0;
        }
        ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, out_words);
        ESP_REPORT_INFO(VON, "-----------------");
    }

#ifdef __CUSTOM_SIM__
    return rc;
#else
    CCS_RETURN(rc);
#endif
}
