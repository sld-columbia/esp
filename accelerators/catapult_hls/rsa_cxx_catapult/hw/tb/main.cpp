#include "rsa_cxx_catapult.hpp"
#include "esp_headers.hpp" // ESP-common headers

#include <cstdlib>
#include <cstdio>

#include <mc_scverify.h>   // Enable SCVerify

// This can be read from a file (and should)

// rsa/tests/simple/RSAPPKCS1_enc.fax
static unsigned raw_encrypt_count[2] = {0, 1};

static unsigned raw_encrypt_EM[2][64] = {
    {0xDE68F0FC, 0x00000000},
    //{0xfcf068de, 0x00000000},
    {0x5139D195, 0x0000003E}};
    //{0x95d13951, 0x3e000000}};

static unsigned raw_encrypt_EM_bytes[2] = {4, 5};
static unsigned raw_encrypt_EM_words[2] = {1, 2};

static unsigned raw_encrypt_e[2][64] = {
    {0x5D2D1165, 0x963D09BE, 0xA4E082CE, 0xD273A7AD, 0x5EC6867C, 0x91A038F2, 0x61B51AB6, 0x935BC2C1, 0x7E37D57A, 0x5AFE1125, 0x37E83DBF, 0x940C3995, 0x6AD7EEF8, 0x7CB6F3EC, 0x003454DB, 0xC116E61C},
    //{0x65112d5d, 0xbe093d96, 0xce82e0a4, 0xada773d2, 0x7c86c65e, 0xf238a091, 0xb61ab561, 0xc1c25b93, 0x7ad5377e, 0x2511fe5a, 0xbf3de837, 0x95390c94, 0xf8eed76a, 0xecf3b67c, 0xdb543400, 0x1ce616c1},
    {0xF5053D2B, 0xB2750FDD, 0x2E62ED5A, 0x7E8125E6, 0xFA92AD8C, 0x5D0EC53B, 0x6B891FDF, 0x5946C0F9, 0x97F028C5, 0x4B52E5BF, 0xBBFEB5AF, 0x9718B0F3, 0x1F3FD37D, 0xADE069C3, 0x5D5257C3, 0x81C7BF79}};
    //{0x2b3d05f5, 0xdd0f75b2, 0x5aed622e, 0xe625817e, 0x8cad92fa, 0x3bc50e5d, 0xdf1f896b, 0xf9c04659, 0xc528f097, 0xbfe5524b, 0xafb5febb, 0xf3b01897, 0x7dd33f1f, 0xc369e0ad, 0xc357525d, 0x79bfc781}};
static unsigned raw_encrypt_e_bytes[2] = {16*4, 16*4};
static unsigned raw_encrypt_e_words[2] = {16, 16};

static unsigned raw_encrypt_n[2][64] = {
    {0xFBCABB93, 0xDEFE61DB, 0x32AF44A6, 0xBD2C8A9E, 0x3E0F28E9, 0x1F2B2E5F, 0x079B2F5E, 0x038E85B5, 0x9F73EF9A, 0x3D7BFAFB, 0x87E7DA78, 0x7E263E6B, 0x44AEC1EF, 0x9F364E67, 0xF8BE172E, 0xF19A4795},
    //{0x93bbcafb, 0xdb61fede, 0xa644af32, 0x9e8a2cbd, 0xe9280f3e, 0x5f2e2b1f, 0x5e2f9b07, 0xb5858e03, 0x9aef739f, 0xfbfa7b3d, 0x78dae787, 0x6b3e267e, 0xefc1ae44, 0x674e369f, 0x2e17bef8, 0x95479af1},
    {0x69192780, 0xDF7C2740, 0xAD3F4F38, 0xAAE1B4D9, 0xE7FA48F4, 0xE9E04659, 0xBD3472ED, 0x95C0A3B8, 0x65A357C6, 0x3CCA45FD, 0xA95CA92D, 0x274CD443, 0x50CF0DFA, 0x80603F35, 0x6FBC24B5, 0x2906123D}};
    //{0x80271969, 0x40277cdf, 0x384f3fad, 0xd9b4e1aa, 0xf448fae7, 0x5946e0e9, 0xed7234bd, 0xb8a3c095, 0xc657a365, 0xfd45ca3c, 0x2da95ca9, 0x43d44c27, 0xfa0dcf50, 0x353f6080, 0xb524bc6f, 0x3d120629}};
static unsigned raw_encrypt_n_bytes[2] = {16*4, 16*4};
static unsigned raw_encrypt_n_words[2] = {16, 16};

static unsigned raw_encrypt_r[2][64]; // computed on the fly
static unsigned raw_encrypt_r_bytes[2] = {16*4, 16*4};
static unsigned raw_encrypt_r_words[2] = {16, 16};

static unsigned raw_encrypt_S[2][64] = {
    {0x06783C4C, 0x0B3ECF73, 0x0FAA4AE2, 0xC893F987, 0x41A96490, 0x603BDDD2, 0x8DF79D91, 0xAB35287E, 0xF5196A76, 0x80BB8E2F, 0xCCDABCCC, 0x1074A819, 0x14B57CDB, 0x3ED16BDD, 0x96E14584, 0x8107E106},
    //{0x4c3c7806, 0x73cf3e0b, 0xe24aaa0f, 0x87f993c8, 0x9064a941, 0xd2dd3b60, 0x919df78d, 0x7e2835ab, 0x766a19f5, 0x2f8ebb80, 0xccbcdacc, 0x19a87410, 0xdb7cb514, 0xdd6bd13e, 0x8445e196, 0x06e10781},
    {0x67758210, 0x4D234D19, 0x079197F2, 0x8AD971EB, 0x7979C28A, 0x26DC9BAA, 0x07379083, 0x4037B902, 0x08D9EE84, 0x6132A3D4, 0x5339F9DB, 0xDFA892CB, 0x547DA49E, 0xC0777927, 0x66698BFD, 0x2406C941}};
    //{0x10827567, 0x194d234d, 0xf2979107, 0xeb71d98a, 0x8ac27979, 0xaa9bdc26, 0x83903707, 0x02b93740, 0x84eed908, 0xd4a33261, 0xdbf93953, 0xcb92a8df, 0x9ea47d54, 0x277977c0, 0xfd8b6966, 0x41c90624}};
static unsigned raw_encrypt_S_bytes[2] = {16*4, 16*4};
static unsigned raw_encrypt_S_words[2] = {16, 16};


void calc_res(unsigned len, unsigned char* cavp_n, unsigned char *cavp_r)
{
     rsa_dword_t n = 0;
     unsigned n_bits = len << 3;

     for (uint32_t i = 0; i < len; ++i)
     {
         n <<= 8;
#ifdef __MENTOR_CATAPULT_HLS__
         n.set_slc<8>(0, ac_int<8, false>(cavp_n[i]));
#else // C_SIMULATION / VIVADO_HLS
         n.range(7, 0) = cavp_n[i];
#endif // __MENTOR_CATAPULT_HLS__
     }

     rsa_dword_t r = (rsa_dword_t(1) << ((n_bits + 2) << 1)) % n;

     for (uint32_t i = 0; i < len; ++i)
     {
#ifdef __MENTOR_CATAPULT_HLS__
         cavp_r[i] = r.slc<8>(n_bits - 8);
#else // C_SIMULATION / VIVADO_HLS
         cavp_r[i] = r.range(n_bits - 1, n_bits - 8);
#endif //  __MENTOR_CATAPULT_HLS__
         r <<= 8;
     }
}

#ifdef __CUSTOM_SIM__
int sc_main(int argc, char **argv) {
#else
CCS_MAIN(int argc, char **argv) {
#endif
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - RSA [Catapult HLS C++]");
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
    ac_int<WL, false> r[PLM_R_SIZE];
    ac_int<WL, false> n[PLM_N_SIZE];
    ac_int<WL, false> e[PLM_E_SIZE];
    ac_int<WL, false> in[PLM_IN_SIZE];
    ac_int<WL, false> out[PLM_OUT_SIZE];
    ac_int<WL, false> gold_out[PLM_OUT_SIZE];

    ESP_REPORT_INFO(VON, "DMA & PLM info:");
    ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
    ESP_REPORT_INFO(VON, "  - PLM width: %u", PLM_WIDTH);
    ESP_REPORT_INFO(VON, "-----------------");

    // Iterate over test length
    for (unsigned idx = 0; idx < 2; idx++) {
        ESP_REPORT_INFO(VON, "-----------------");

        conf_info_data.in_bytes = raw_encrypt_EM_bytes[idx];
        conf_info_data.e_bytes = raw_encrypt_e_bytes[idx];
        conf_info_data.n_bytes = raw_encrypt_n_bytes[idx];
        conf_info_data.pubpriv = PRIVATE_KEY;
        conf_info_data.padding = RSA_PKCS1_PADDING;
        conf_info_data.encryption = ENCRYPTION_MODE;

        unsigned in_words = raw_encrypt_EM_words[idx];
        unsigned n_words = raw_encrypt_n_words[idx];
        unsigned e_words = raw_encrypt_e_words[idx];
        unsigned r_words = raw_encrypt_n_words[idx];
        unsigned out_words = raw_encrypt_S_words[idx];

        ESP_REPORT_INFO(VON, "Test index: %u", idx);
        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - encryption: %u", ESP_TO_UINT32(conf_info_data.encryption));
        ESP_REPORT_INFO(VON, "  - in_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.in_bytes), in_words); 
        ESP_REPORT_INFO(VON, "  - e_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.e_bytes), e_words);
        ESP_REPORT_INFO(VON, "  - n_bytes: %u (words %u)", ESP_TO_UINT32(conf_info_data.n_bytes), n_words);
        ESP_REPORT_INFO(VON, "  - pubpriv: %u", ESP_TO_UINT32(conf_info_data.pubpriv));
        ESP_REPORT_INFO(VON, "  - padding: %u", ESP_TO_UINT32(conf_info_data.padding));

        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //

        // Pass inputs to the accelerator
        for (unsigned j = 0; j < in_words; j+=2) {
            ac_int<WL, false> data_0(raw_encrypt_EM[idx][j+0]);
            ac_int<WL, false> data_1(raw_encrypt_EM[idx][j+1]);

            in[j+0] = data_0;
            in[j+1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, in[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, in[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }

        for (unsigned j = 0; j < e_words; j+=2) {
            ac_int<WL, false> data_0(raw_encrypt_e[idx][j+0]);
            ac_int<WL, false> data_1(raw_encrypt_e[idx][j+1]);

            e[j+0] = data_0;
            e[j+1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, e[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, e[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }

        for (unsigned j = 0; j < n_words; j+=2) {
            ac_int<WL, false> data_0(raw_encrypt_n[idx][j+0]);
            ac_int<WL, false> data_1(raw_encrypt_n[idx][j+1]);

            n[j+0] = data_0;
            n[j+1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, n[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, n[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }

        //printf("INFO: n_bytes = %u\n", raw_encrypt_n_bytes[idx]);
        //printf("INFO: n: ");
        //for (uint32_t i = 0; i < n_bytesraw_encrypt_n_bytes[idx] >> 2; ++i) {
        //    r_val <<= 32;
        //    range_set(r_val, 31, 0, RSA_SWAP(r[i]));
        //}
        for (unsigned j = 0; j < raw_encrypt_n_bytes[idx]; j++) {
            unsigned char *raw_encrypt_n_idx = (unsigned char *)raw_encrypt_n[idx];
            //printf("%02X", raw_encrypt_n_idx[j]);
        }
        //printf("\n");
        calc_res(raw_encrypt_n_bytes[idx], (unsigned char*)raw_encrypt_n[idx], (unsigned char*)raw_encrypt_r[idx]);
        //printf("INFO: r: ");
        for (unsigned j = 0; j < raw_encrypt_r_bytes[idx]; j++) {
            unsigned char *raw_encrypt_r_idx = (unsigned char *)raw_encrypt_r[idx];
            //printf("%02X", raw_encrypt_r_idx[j]);
        }
        //printf("\n");
        for (unsigned j = 0; j < r_words; j+=2) {
            ac_int<WL, false> data_0(raw_encrypt_r[idx][j+0]);
            ac_int<WL, false> data_1(raw_encrypt_r[idx][j+1]);

            n[j+0] = data_0;
            n[j+1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL*0, n[j+0].template slc<WL>(0));
            data_ac.set_slc(WL*1, n[j+1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
#ifdef __CUSTOM_SIM__
        rsa_cxx_catapult(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#else
        CCS_DESIGN(rsa_cxx_catapult)(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#endif

        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(out_words/2)) {} // Testbench stalls until data ready
        for (unsigned i = 0; i < out_words; i+=2) {
            ac_int<DMA_WIDTH, false> data = dma_write_chnl.read().template slc<DMA_WIDTH>(0);
            ac_int<WL, false> data_0 = data.template slc<DMA_WIDTH>(WL*0);
            ac_int<WL, false> data_1 = data.template slc<DMA_WIDTH>(WL*1);
            out[i+0].template set_slc<WL>(0, data_0);
            out[i+1].template set_slc<WL>(0, data_1);
        }

        // Validation
        ESP_REPORT_INFO(VON, "-----------------");
        unsigned errors = 0;
        for (unsigned j = 0; j < out_words; j++) {
            gold_out[j] = raw_encrypt_S[idx][j];
        }

        for (unsigned i = 0; i < out_words; i++) {
            ac_int<WL, false> gold = gold_out[i];
            ac_int<WL, false> data = out[i];

            if (gold != data) {
                ESP_REPORT_INFO(VOFF, "[%u]: %X (expected %X)", i, data.to_uint(), gold.to_uint());
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
