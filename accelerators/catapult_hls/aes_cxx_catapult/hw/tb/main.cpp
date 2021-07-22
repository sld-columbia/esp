//#include "../inc/espacc_config.h"
//#include "../inc/espacc.h"

#include "aes_cxx_catapult.hpp"
#include "esp_headers.hpp" // ESP-common headers

#include <cstdlib>
#include <cstdio>

#include <mc_scverify.h>   // Enable SCVerify

// This can be read from a file (and should)

// aes32/tests/aesmmt/ECBMMT128.rsp
static unsigned raw_encrypt_count[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

static unsigned raw_encrypt_key[10][4] = {
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
static unsigned raw_encrypt_key_bytes[10] = {4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4, 4*4};
static unsigned raw_encrypt_key_words[10] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4};

static unsigned raw_encrypt_plaintext[10][40] = {
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
static unsigned raw_encrypt_plaintext_bytes[10] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned raw_encrypt_plaintext_words[10] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

static unsigned raw_encrypt_ciphertext[10][40] = {
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
static unsigned raw_encrypt_ciphertext_bytes[10] = {4*4, 8*4, 12*4, 16*4, 20*4, 24*4, 28*4, 32*4, 36*4, 40*4};
static unsigned raw_encrypt_ciphertext_words[10] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

#ifdef __CUSTOM_SIM__
int sc_main(int argc, char **argv) {
#else
CCS_MAIN(int argc, char **argv) {
#endif
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - AES [Catapult HLS C++]");
    ESP_REPORT_INFO(VON, "      Single block");
    ESP_REPORT_INFO(VON, "--------------------------------");

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
    ESP_REPORT_INFO(VON, "  - PLM width: %u", PLM_WIDTH);
    ESP_REPORT_INFO(VON, "-----------------");

    // Iterate over test length
    for (unsigned idx = 0; idx < 10; idx++) {
        ESP_REPORT_INFO(VON, "-----------------");

        conf_info_data.oper_mode = ECB_OPERATION_MODE;
        conf_info_data.encryption = ENCRYPTION_MODE;
        conf_info_data.key_bytes = raw_encrypt_key_bytes[idx]; 
        conf_info_data.in_bytes = raw_encrypt_plaintext_bytes[idx];
        conf_info_data.iv_bytes = 0; // 0 for ECB
        conf_info_data.aad_bytes = 0; // 0 for ECB
        conf_info_data.tag_bytes = 0; // 0 for ECB

        unsigned key_words = raw_encrypt_key_words[idx];
        unsigned in_words = raw_encrypt_plaintext_words[idx];
        unsigned out_words = raw_encrypt_ciphertext_words[idx];
        unsigned iv_words = 0; // 0 for ECB
        unsigned aad_words = 0; // 0 for ECB
        unsigned tag_words = 0; // 0 for ECB

        ESP_REPORT_INFO(VON, "Test index: %u", idx);
        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - oper_mode: %u", ESP_TO_UINT32(conf_info_data.oper_mode));
        ESP_REPORT_INFO(VON, "  - encryption: %u", ESP_TO_UINT32(conf_info_data.encryption));
        ESP_REPORT_INFO(VON, "  - key_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.key_bytes), key_words); 
        ESP_REPORT_INFO(VON, "  - in_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.in_bytes), in_words);
        ESP_REPORT_INFO(VON, "  - iv_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.iv_bytes), iv_words);
        ESP_REPORT_INFO(VON, "  - aad_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.aad_bytes), aad_words);
        ESP_REPORT_INFO(VON, "  - tag_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.tag_bytes), tag_words);

        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //

        // Pass inputs to the accelerator
        for (unsigned j = 0; j < key_words; j+=2) {
            ac_int<WL, false> data_0(raw_encrypt_key[idx][j+0]);
            ac_int<WL, false> data_1(raw_encrypt_key[idx][j+1]);

            inputs[j+0] = data_0;
            inputs[j+1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, inputs[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, inputs[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }

        for (unsigned j = 0; j < in_words; j+=2) {
            ac_int<WL, false> data_0(raw_encrypt_plaintext[idx][j+0]);
            ac_int<WL, false> data_1(raw_encrypt_plaintext[idx][j+1]);

            inputs[j+0] = data_0;
            inputs[j+1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, inputs[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, inputs[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }


        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
#ifdef __CUSTOM_SIM__
        aes_cxx_catapult(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#else
        CCS_DESIGN(aes_cxx_catapult)(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
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
            gold_outputs[j] = raw_encrypt_ciphertext[idx][j];
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
