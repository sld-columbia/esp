//#include "../inc/espacc_config.h"
//#include "../inc/espacc.h"

#include "crypto_cxx_catapult.hpp"
#include "esp_headers.hpp" // ESP-common headers

#include <cstdio>
#include <cstdlib>

#include <mc_scverify.h> // Enable SCVerify

#define SHA1_ALGO 1
//#define SHA2_ALGO 2
//#define AES_ALGO 3

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
    {0x45927e32, 0xddf801ca, 0xf35e18e7, 0xb5078b7f, 0x54352782, 0x12ec6bb9, 0x9df884f4,
     0x9b327c64, // SHA1ShortMsg 512
     0x86feae46, 0xba187dc1, 0xcc914512, 0x1e1492e6, 0xb06e9007, 0x394dc33b, 0x7748f86a,
     0xc3207cfe},
    {0x6cb70d19, 0xc096200f, 0x9249d2db, 0xc04299b0, 0x085eb068, 0x257560be, 0x3a307dbd,
     0x741a3378, // SHA1LongMsg 2096
     0xebfa03fc, 0xca610883, 0xb07f7fea, 0x563a8665, 0x71822472, 0xdade8a0b, 0xec4b9820,
     0x2d47a344, 0x312976a7, 0xbcb39644, 0x27eacb5b, 0x0525db22, 0x066599b8, 0x1be41e5a,
     0xdaf157d9, 0x25fac04b, 0x06eb6e01, 0xdeb753ba, 0xbf33be16, 0x162b214e, 0x8db01721,
     0x2fafa512, 0xcdc8c0d0, 0xa15c10f6, 0x32e8f4f4, 0x7792c64d, 0x3f026004, 0xd173df50,
     0xcf0aa797, 0x6066a79a, 0x8d78deee, 0xec951dab, 0x7cc90f68, 0xd16f7866, 0x71feba0b,
     0x7d269d92, 0x941c4f02, 0xf432aa5c, 0xe2aab619, 0x4dcc6fd3, 0xae36c843, 0x3274ef6b,
     0x1bd0d314, 0x636be47b, 0xa38d1948, 0x343a38bf, 0x9406523a, 0x0b2a8cd7, 0x8ed6266e,
     0xe3c9b5c6, 0x0620b308, 0xcc6b3a73, 0xc6060d52, 0x68a7d82b, 0x6a33b93a, 0x6fd6fe1d,
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
    {0xa70cfbfe, 0x7563dd0e, 0x665c7c67, 0x15a96a8d, 0x756950c0, 0x0},  // SHA1ShortMsg 512
    {0x4a75a406, 0xf4de5f9e, 0x1132069d, 0x66717fc4, 0x24376388, 0x0}}; // SHA1LongMsg 2096
#endif

#ifdef SHA2_ALGO
    // This can be read from a file (and should)
    #define N_TESTS 11

static unsigned sha2_raw_in_bytes[N_TESTS]  = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 64};
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
     0xb4b65248, 0xf66a08ed, 0xf6e08326, 0x89a9dc3a, 0x2e5d2095, 0xeeea50bd, 0x862bac88,
     0xc8bd318d}}; // 512, SHA224ShortMsg.rsp

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

#ifdef AES_ALGO

    #define N_TESTS 10

// aes32/tests/aesmmt/ECBMMT128.rsp
static unsigned aes_raw_encrypt_count[N_TESTS] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

static unsigned aes_raw_encrypt_key[N_TESTS][4] = {
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
static unsigned aes_raw_encrypt_key_bytes[N_TESTS] = {4 * 4, 4 * 4, 4 * 4, 4 * 4, 4 * 4,
                                                      4 * 4, 4 * 4, 4 * 4, 4 * 4, 4 * 4};
static unsigned aes_raw_encrypt_key_words[N_TESTS] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4};

static unsigned aes_raw_encrypt_plaintext[N_TESTS][40] = {
    {0x1695fe47, 0x5421cace, 0x3557daca, 0x01f445ff},
    {0x1b0a69b7, 0xbc534c16, 0xcecffae0, 0x2cc53231, 0x90ceb413, 0xf1db3e9f, 0x0f79ba65,
     0x4c54b60e},
    {0x6f172bb6, 0xec364833, 0x411841a8, 0xf9ea2051, 0x735d6005, 0x38a9ea5e, 0x8cd2431a, 0x432903c1,
     0xd6178988, 0xb616ed76, 0xe00036c5, 0xb28ccd8b},
    {0x59355931, 0x8cc66bf6, 0x95e49feb, 0x42794bdf, 0xb66bce89, 0x5ec222ca, 0x2609b133, 0xecf66ac7,
     0x344d1302, 0x1e01e11a, 0x969c4684, 0xcbe20aba, 0xe2b19d3c, 0xeb2cacd4, 0x1419f21f,
     0x1c865149},
    {0x84f809fc, 0x5c846523, 0x76cc0df1, 0x0095bc00, 0xb9f0547f, 0xa91a2d33, 0x10a0adbc,
     0x9cc6191a, 0xde2aaa6f, 0xffa5e406, 0xaf722395, 0x5f9277bf, 0xb06eb1dd, 0x2bbfbefe,
     0x32ab342c, 0x36302bf2, 0x2bc64e1b, 0x394032bb, 0xb5f4e674, 0x4f1bcbf2},
    {0x7adcf4a4, 0x94f6b097, 0x90c82c8b, 0xb97db62c, 0x5d3fa403, 0x2f06dfec,
     0xeaad9ecb, 0x374b747b, 0xd1c08d07, 0xe78e351d, 0xc2eb99bf, 0xa714d23c,
     0xffe31f5f, 0xb5a472e6, 0xe0252f35, 0xa20c304c, 0x4f6d0cf7, 0xd29c9944,
     0x4d40af3a, 0x00a92fc8, 0x6c6444fc, 0xb80ce976, 0x5362ac1b, 0xdba0b10e},
    {0x37a1205e, 0xa929355d, 0x2e4ee52d, 0x5e1d9cda, 0x279ae01e, 0x640287cc, 0xb153276e,
     0x7e0ecf2d, 0x633cf4f2, 0xb3afaecb, 0x548a2590, 0xce0445c6, 0xa168bac3, 0xdc601813,
     0xeb74591b, 0xb1ce8dfc, 0xd740cdbb, 0x6388719e, 0x8cd283d9, 0xcc7e7369, 0x38240b41,
     0x0dd5a6a4, 0x8ba49dd2, 0x066503e6, 0x3ab592ff, 0xdf3be49e, 0x7d2de74f, 0x82158b8c},
    {0xeaf1760c, 0x0f25310d, 0xada6debe, 0xb966304d, 0xb7a9f1b2, 0xd1c3af92, 0x2623b263,
     0x649031d2, 0x99b3c561, 0x46d61d55, 0xb6ebf4cf, 0x8dd04039, 0xa4d1ace3, 0x146f49ee,
     0x915f806a, 0xfad64cbb, 0x2d04a641, 0x20de4038, 0x2e2175dc, 0xae9480d1, 0xca8dedc3,
     0x8fb64e4a, 0x40112f10, 0xf03a4c35, 0x4fed01f2, 0xc5c7017d, 0xbd514b2d, 0x443a5adf,
     0xd2e49c98, 0x6723266c, 0xda41a69e, 0x6e459908},
    {0x8177d79c, 0x8f239178, 0x186b4dc5, 0xf1df2ea7, 0xfee7d0db, 0x535489ef, 0x983aefb3, 0xb2029aeb,
     0xa0bb2b46, 0xa2b18c94, 0xa1417a33, 0xcbeb41ca, 0x7ea9c73a, 0x677fccd2, 0xeb5470c3, 0xc500f6d3,
     0xf1a6c755, 0xc944ba58, 0x6f88921f, 0x6ae6c9d1, 0x94e78c72, 0x33c40612, 0x6633e144, 0xc3810ad2,
     0x3ee1b5af, 0x4c04a22d, 0x49e99e70, 0x17f74c23, 0x09492569, 0xff49be17, 0xd2804920, 0xf2ac5f51,
     0x4d13fd3e, 0x7318cc7c, 0xf80ca510, 0x1a465428},
    {0x451f4566, 0x3b44fd00, 0x5f3c288a, 0xe57b3838, 0x83f02d9a, 0xd3dc1715, 0xf9e3d694,
     0x8564257b, 0x9b06d7dd, 0x51935fee, 0x580a96bb, 0xdfefb918, 0xb4e6b1da, 0xac809847,
     0x465578cb, 0x8b5356ed, 0x38556f80, 0x1ff7c11e, 0xcba9cdd2, 0x63039c15, 0xd05900fc,
     0x228e1caf, 0x302d261d, 0x7fb56cee, 0x663595b9, 0x6f192a78, 0xff445539, 0x3a5fe816,
     0x2170a066, 0xfdaeac35, 0x019469f2, 0x2b347068, 0x6bced2f0, 0x07a1a2e4, 0x3e01b456,
     0x2caaa502, 0xed541b82, 0x05874ec1, 0xffb1c8b2, 0x55766942}};
static unsigned aes_raw_encrypt_plaintext_bytes[N_TESTS] = {4 * 4,  8 * 4,  12 * 4, 16 * 4, 20 * 4,
                                                            24 * 4, 28 * 4, 32 * 4, 36 * 4, 40 * 4};
static unsigned aes_raw_encrypt_plaintext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};

static unsigned aes_raw_encrypt_ciphertext[N_TESTS][40] = {
    {0x7888beae, 0x6e7a4263, 0x32a7eaa2, 0xf808e637},
    {0xad5b0895, 0x15e78210, 0x87c61652, 0xdc477ab1, 0xf2cc6331, 0xa70dfc59, 0xc9ffb0c7,
     0x23c682f6},
    {0x4cc2a8f1, 0x3c8c7c36, 0xed6a814d, 0xb7f26900, 0xc7e04df4, 0x9cbad916, 0xce6a44d0, 0xae4fe7ed,
     0xc0b40279, 0x4675b369, 0x4933ebbc, 0x356525d8},
    {0x3ea6f430, 0x5217bd47, 0xeebe773d, 0xa4b57854, 0x9cac744c, 0x00cbd8f9, 0xd596d380, 0x10304bd8,
     0x50cc2f4b, 0x19a91c2e, 0x022eabf1, 0x00266185, 0xca270512, 0x7815dfd4, 0x6efbe4ec,
     0xd46a3058},
    {0xa6dc096b, 0xc21b0658, 0xe416a0f6, 0x79fefc6e, 0x958e9c56, 0xe3ce04fd, 0xf6e392c2,
     0xdb770a60, 0xd9523c25, 0x5925e14a, 0x3e02a100, 0x2bf3875c, 0x2e501bac, 0x618bee1f,
     0x55f98504, 0x54854eef, 0x9d693d90, 0x937cc838, 0x7b6f4c44, 0x14e2080b},
    {0x22217953, 0xf71932ab, 0x4360d97e, 0xf4950815, 0x59f1fcb0, 0x9caca41f,
     0xa0c65f7b, 0x1792b560, 0xeabe18f3, 0xb3b06ef8, 0x0c41886f, 0x24c5d6d3,
     0x2d20427e, 0x83d8b556, 0x4d9ac743, 0x5a2842c1, 0xcf7c6fcc, 0x229eb7f5,
     0x18d3e016, 0x7d510efb, 0xaee39a04, 0x38fc800e, 0xb6acfc20, 0x3c93280c},
    {0xc88e0338, 0x3ba9da6f, 0x982c057f, 0xe92c0bb3, 0xed5b9cd1, 0x8295a100, 0xe13a4e12,
     0xd440b919, 0xbbb8b221, 0xabead362, 0x902ce44d, 0x30d0b80e, 0x56bee1f6, 0x6a7d8de0,
     0xb1e1b4db, 0xf76c90c1, 0x807a3bc5, 0xf277e981, 0x4c82ab12, 0x0f7e1021, 0x7dfdf609,
     0x2ce4958f, 0x8906c5e3, 0x2279c653, 0x7dd1fbae, 0x20cb7a1d, 0x9f89d049, 0x0b6aefc1},
    {0x5ece70a4, 0x4da41bc7, 0xcfb9b582, 0xea9ce098, 0x0030ec4a, 0xf331e764, 0x99961f88,
     0x860aa055, 0x4aba3ecb, 0xf77ca429, 0x3a3fee85, 0x4a2caf3a, 0xe800343f, 0xb4521388,
     0xb16b6dc5, 0x99b3d60b, 0xf82777f9, 0x8e1a8d04, 0xab9cd54d, 0xd9a24809, 0x5795d4df,
     0xe4858bfd, 0x9a05f54c, 0x795bb086, 0xe15f7c22, 0x228184ec, 0x66a9ca10, 0xb1cf71a6,
     0xbb9303c5, 0xcd1dcc05, 0x6460a86d, 0xf651f053},
    {0x5befb306, 0x2a7a7246, 0xaf1f77b0, 0xec0ac614, 0xe28be06a, 0xc2c81b19, 0xe5a0481b, 0xf160f9f2,
     0xbc43f28f, 0x65487876, 0x39e4ce3e, 0x0f1e9547, 0x5f0e81ce, 0xb793004c, 0x8e46670e, 0xbd48b866,
     0xd5b43d10, 0x4874ead4, 0xbe8a236b, 0xf90b48f8, 0x62f7e252, 0xdec4475f, 0xdbb841a6, 0x62efcd25,
     0xed64b291, 0x0e9baaea, 0x9466e413, 0xa4241438, 0xb31df0bd, 0x3df9a16f, 0x46416367, 0x54e25986,
     0x1728aa7d, 0xdf435cc5, 0x1f54f79a, 0x1db25f52},
    {0x01043053, 0xf832ef9b, 0x911ed387, 0xba577451, 0xe30d51d4, 0xb6b11f31, 0x9d4cd539,
     0xd067b7f4, 0xf9b4f41f, 0x7f3d4e92, 0x0c57cbe2, 0xb5e1885a, 0xa66203ae, 0x493e93a1,
     0xdf63793a, 0x9563c176, 0xbc6775dd, 0x09cc9161, 0xe278a01b, 0xeb8fd8a1, 0x9200326b,
     0xd95abc5f, 0x716768e3, 0x4f90b505, 0x23d30fda, 0xbb103a3b, 0xc020afbb, 0xb0cb3bd2,
     0xad512a6f, 0xea79f8d6, 0x4cef3474, 0x58dec48b, 0xe89451cb, 0x0b807d73, 0x593f273d,
     0x9fc521b7, 0x89a77524, 0x404f43e0, 0x0f20b3b7, 0x7b938b1a}};
static unsigned aes_raw_encrypt_ciphertext_bytes[N_TESTS] = {
    4 * 4, 8 * 4, 12 * 4, 16 * 4, 20 * 4, 24 * 4, 28 * 4, 32 * 4, 36 * 4, 40 * 4};
static unsigned aes_raw_encrypt_ciphertext_words[N_TESTS] = {4, 8, 12, 16, 20, 24, 28, 32, 36, 40};
#endif

#ifdef __CUSTOM_SIM__
int sc_main(int argc, char **argv)
{
#else
CCS_MAIN(int argc, char **argv)
{
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

#ifdef AES_ALGO
    ESP_REPORT_INFO(VON, "--------------------------------");
    ESP_REPORT_INFO(VON, "ESP - AES [Catapult HLS C++]");
    ESP_REPORT_INFO(VON, "      Single block");
    ESP_REPORT_INFO(VON, "--------------------------------");
#endif

    const unsigned sha1_in_size  = SHA1_PLM_IN_SIZE;
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
#ifdef SHA1_ALGO
    ac_int<WL, false> sha1_inputs[SHA1_PLM_IN_SIZE];
    ac_int<WL, false> sha1_outputs[SHA1_PLM_OUT_SIZE];
    ac_int<WL, false> sha1_gold_outputs[SHA1_PLM_OUT_SIZE];
#endif

#ifdef SHA2_ALGO
    ac_int<WL, false> sha2_inputs[SHA2_PLM_IN_SIZE];
    ac_int<WL, false> sha2_outputs[SHA2_PLM_OUT_SIZE];
    ac_int<WL, false> sha2_gold_outputs[SHA2_PLM_OUT_SIZE];
#endif

#ifdef AES_ALGO
    ac_int<WL, false> aes_inputs[AES_PLM_IN_SIZE];
    ac_int<WL, false> aes_outputs[AES_PLM_OUT_SIZE];
    ac_int<WL, false> aes_gold_outputs[AES_PLM_OUT_SIZE];
#endif

    ESP_REPORT_INFO(VON, "DMA & PLM info:");
    ESP_REPORT_INFO(VON, "  - DMA width: %u", DMA_WIDTH);
#ifdef SHA1_ALGO
    ESP_REPORT_INFO(VON, "  - SHA1 PLM in size: %u", SHA1_PLM_IN_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA1 PLM out size: %u", SHA1_PLM_OUT_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA1 PLM width: %u", SHA1_PLM_WIDTH);
#endif
#ifdef SHA2_ALGO
    ESP_REPORT_INFO(VON, "  - SHA2 PLM in size: %u", SHA2_PLM_IN_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA2 PLM out size: %u", SHA2_PLM_OUT_SIZE);
    ESP_REPORT_INFO(VON, "  - SHA2 PLM width: %u", SHA2_PLM_WIDTH);
#endif
#ifdef AES_ALGO
    ESP_REPORT_INFO(VON, "  - AES PLM in size: %u", AES_PLM_IN_SIZE);
    ESP_REPORT_INFO(VON, "  - AES PLM out size: %u", AES_PLM_OUT_SIZE);
    ESP_REPORT_INFO(VON, "  - AES PLM width: %u", AES_PLM_WIDTH);
#endif
    ESP_REPORT_INFO(VON, "-----------------");

    // Iterate over test length
    for (unsigned t = 1; t < N_TESTS; t++) {

#ifdef SHA1_ALGO
        conf_info_data.crypto_algo   = SHA1_ALGO;
        conf_info_data.sha1_in_bytes = sha1_raw_in_bytes[t];
        unsigned sha1_in_words       = (ESP_TO_UINT32(conf_info_data.sha1_in_bytes) + 4 - 1) / 4;

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - sha1_in_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.sha1_in_bytes), sha1_in_words);
#endif

#ifdef SHA2_ALGO
        conf_info_data.crypto_algo    = SHA2_ALGO;
        conf_info_data.sha2_in_bytes  = sha2_raw_in_bytes[t];
        conf_info_data.sha2_out_bytes = sha2_raw_out_bytes[t];
        unsigned sha2_in_words        = (ESP_TO_UINT32(conf_info_data.sha2_in_bytes) + 4 - 1) / 4;
        unsigned sha2_out_words       = (ESP_TO_UINT32(conf_info_data.sha2_out_bytes) + 4 - 1) / 4;

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - sha2_in_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.sha2_in_bytes), sha2_in_words);
        ESP_REPORT_INFO(VON, "  - sha2_out_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.sha2_out_bytes), sha2_out_words);
#endif

#ifdef AES_ALGO
        conf_info_data.crypto_algo   = AES_ALGO;
        conf_info_data.aes_oper_mode = AES_ECB_OPERATION_MODE;
        // conf_info_data.aes_encryption = AES_ENCRYPTION_MODE;
        conf_info_data.encryption    = AES_ENCRYPTION_MODE;
        conf_info_data.aes_key_bytes = aes_raw_encrypt_key_bytes[t];
        conf_info_data.aes_in_bytes  = aes_raw_encrypt_plaintext_bytes[t];
        conf_info_data.aes_iv_bytes  = 0; // 0 for ECB
        conf_info_data.aes_aad_bytes = 0; // 0 for ECB
        conf_info_data.aes_tag_bytes = 0; // 0 for ECB

        unsigned aes_key_words = aes_raw_encrypt_key_words[t];
        unsigned aes_in_words  = aes_raw_encrypt_plaintext_words[t];
        unsigned aes_out_words = aes_raw_encrypt_ciphertext_words[t];
        unsigned aes_iv_words  = 0; // 0 for ECB
        unsigned aes_aad_words = 0; // 0 for ECB
        unsigned aes_tag_words = 0; // 0 for ECB

        ESP_REPORT_INFO(VON, "Configuration:");
        ESP_REPORT_INFO(VON, "  - aes_oper_mode: %u", ESP_TO_UINT32(conf_info_data.aes_oper_mode));
        // ESP_REPORT_INFO(VON, "  - aes_encryption: %u",
        // ESP_TO_UINT32(conf_info_data.aes_encryption));
        ESP_REPORT_INFO(VON, "  - aes_encryption: %u", ESP_TO_UINT32(conf_info_data.encryption));
        ESP_REPORT_INFO(VON, "  - aes_key_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.aes_key_bytes), aes_key_words);
        ESP_REPORT_INFO(VON, "  - aes_in_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.aes_in_bytes), aes_in_words);
        ESP_REPORT_INFO(VON, "  - aes_iv_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.aes_iv_bytes), aes_iv_words);
        ESP_REPORT_INFO(VON, "  - aes_aad_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.aes_aad_bytes), aes_aad_words);
        ESP_REPORT_INFO(VON, "  - aes_tag_bytes: %u (words %u)",
                        ESP_TO_UINT32(conf_info_data.aes_tag_bytes), aes_tag_words);
#endif

#ifdef SHA1_ALGO
        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //
        // Pass inputs to the accelerator
        for (unsigned j = 0; j < sha1_in_words; j += 2) {
            ac_int<WL, false> data_fp_0(sha1_raw_inputs[t][j + 0]);
            ac_int<WL, false> data_fp_1(sha1_raw_inputs[t][j + 1]);

            sha1_inputs[j + 0] = data_fp_0;
            sha1_inputs[j + 1] = data_fp_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL * 0, sha1_inputs[j + 0].template slc<WL>(0));
            data_ac.set_slc(WL * 1, sha1_inputs[j + 1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }
#endif

#ifdef SHA2_ALGO
        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //
        // Pass inputs to the accelerator
        for (unsigned j = 0; j < sha2_in_words; j += 2) {
            ac_int<WL, false> data_fp_0(sha2_raw_inputs[t][j + 0]);
            ac_int<WL, false> data_fp_1(sha2_raw_inputs[t][j + 1]);

            sha2_inputs[j + 0] = data_fp_0;
            sha2_inputs[j + 1] = data_fp_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL * 0, sha2_inputs[j + 0].template slc<WL>(0));
            data_ac.set_slc(WL * 1, sha2_inputs[j + 1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }
#endif

#ifdef AES_ALGO
        // DMA word
        // |<--- 0 --->|<--- 1 --->|
        //

        // Pass inputs to the accelerator
        for (unsigned j = 0; j < aes_key_words; j += 2) {
            ac_int<WL, false> data_0(aes_raw_encrypt_key[t][j + 0]);
            ac_int<WL, false> data_1(aes_raw_encrypt_key[t][j + 1]);

            aes_inputs[j + 0] = data_0;
            aes_inputs[j + 1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL * 0, aes_inputs[j + 0].template slc<WL>(0));
            data_ac.set_slc(WL * 1, aes_inputs[j + 1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }

        for (unsigned j = 0; j < aes_in_words; j += 2) {
            ac_int<WL, false> data_0(aes_raw_encrypt_plaintext[t][j + 0]);
            ac_int<WL, false> data_1(aes_raw_encrypt_plaintext[t][j + 1]);

            aes_inputs[j + 0] = data_0;
            aes_inputs[j + 1] = data_1;

            ac_int<DMA_WIDTH, false> data_ac;
            data_ac.set_slc(WL * 0, aes_inputs[j + 0].template slc<WL>(0));
            data_ac.set_slc(WL * 1, aes_inputs[j + 1].template slc<WL>(0));

            dma_read_chnl.write(data_ac);
        }
#endif

        // Pass configuration to the accelerator
        conf_info.write(conf_info_data);

        // Run the accelerator
#ifdef __CUSTOM_SIM__
        crypto_cxx_catapult(conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl,
                            acc_done);
#else
        CCS_DESIGN(crypto_cxx_catapult)
        (conf_info, dma_read_ctrl, dma_write_ctrl, dma_read_chnl, dma_write_chnl, acc_done);
#endif

#ifdef SHA1_ALGO
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(sha1_out_size / 2)) {} // Testbench stalls until data ready
        for (unsigned i = 0; i < sha1_out_size; i += 2) {
            ac_int<DMA_WIDTH, false> data = dma_write_chnl.read().template slc<DMA_WIDTH>(0);
            ac_int<WL, false> data_0      = data.template slc<DMA_WIDTH>(WL * 0);
            ac_int<WL, false> data_1      = data.template slc<DMA_WIDTH>(WL * 1);
            sha1_outputs[i + 0].template set_slc<WL>(0, data_0);
            sha1_outputs[i + 1].template set_slc<WL>(0, data_1);
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
        }
        else {
            ESP_REPORT_INFO(VON, "Validation: PASS");
            rc |= 0;
        }
        ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, sha1_out_size);
        ESP_REPORT_INFO(VON, "-----------------");
#endif

#ifdef SHA2_ALGO
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(sha2_out_words / 2)) {
        } // Testbench stalls until data ready
        for (unsigned i = 0; i < sha2_out_words; i += 2) {
            ac_int<DMA_WIDTH, false> data = dma_write_chnl.read().template slc<DMA_WIDTH>(0);
            ac_int<WL, false> data_0      = data.template slc<DMA_WIDTH>(WL * 0);
            ac_int<WL, false> data_1      = data.template slc<DMA_WIDTH>(WL * 1);
            sha2_outputs[i + 0].template set_slc<WL>(0, data_0);
            sha2_outputs[i + 1].template set_slc<WL>(0, data_1);
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
        }
        else {
            ESP_REPORT_INFO(VON, "Validation: PASS");
            rc |= 0;
        }
        ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, sha2_out_words);
        ESP_REPORT_INFO(VON, "-----------------");
#endif

#ifdef AES_ALGO
        // Fetch outputs from the accelerator
        while (!dma_write_chnl.available(aes_out_words / 2)) {} // Testbench stalls until data ready
        for (unsigned i = 0; i < aes_out_words; i += 2) {
            ac_int<DMA_WIDTH, false> data = dma_write_chnl.read().template slc<DMA_WIDTH>(0);
            ac_int<WL, false> data_0      = data.template slc<DMA_WIDTH>(WL * 0);
            ac_int<WL, false> data_1      = data.template slc<DMA_WIDTH>(WL * 1);
            aes_outputs[i + 0].template set_slc<WL>(0, data_0);
            aes_outputs[i + 1].template set_slc<WL>(0, data_1);
        }

        // Validation
        unsigned errors = 0;
        ESP_REPORT_INFO(VON, "-----------------");
        for (unsigned j = 0; j < aes_out_words; j++) {
            aes_gold_outputs[j] = aes_raw_encrypt_ciphertext[t][j];
        }

        for (unsigned i = 0; i < aes_out_words; i++) {
            ac_int<WL, false> gold = aes_gold_outputs[i];
            ac_int<WL, false> data = aes_outputs[i];

            if (gold != data) {
                ESP_REPORT_INFO(VON, "[%u]: %X (expected %X)", i, data.to_uint(), gold.to_uint());
                errors++;
            }
        }

        if (errors > 0) {
            ESP_REPORT_INFO(VON, "Validation: FAIL (errors %u / total %u)", errors, aes_out_words);
            rc |= 1;
        }
        else {
            ESP_REPORT_INFO(VON, "Validation: PASS");
            rc |= 0;
        }
        ESP_REPORT_INFO(VON, "  - errors %u / total %u", errors, aes_out_words);
        ESP_REPORT_INFO(VON, "-----------------");
#endif
    }

#ifdef __CUSTOM_SIM__
    return rc;
#else
    CCS_RETURN(rc);
#endif
}
