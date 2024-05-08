#include "aes.h"

#if defined(SYN_AES_ECB) || defined(SYN_AES_CTR)
    #include "ecb.h"
    #include "modes/ecb.cpp"
#endif // defined(SYN_AES_ECB) || defined(SYN_AES_CTR)
#ifdef SYN_AES_CBC
    #include "cbc.h"
    #include "modes/cbc.cpp"
#endif // SYN_AES_CBC
#ifdef SYN_AES_GCM
    #include "gcm.h"
    #include "modes/gcm.cpp"
#endif // SYN_AES_GCM

#include "exp.cpp" // TODO: this is a workaround
#include "exp.h"

int aes(uint32 oper_mode, uint32 encryption, uint32 key_bytes, uint32 iv_bytes, uint32 input_bytes,
        uint32 aad_bytes, uint32 tag_bytes, uint32 key[AES_MAX_KEY_WORDS],
        uint32 iv[AES_MAX_IV_WORDS], uint32 in[AES_MAX_IN_WORDS], uint32 out[AES_MAX_IN_WORDS],
        uint32 aad[AES_MAX_IN_WORDS], uint32 tag[AES_MAX_IN_WORDS])
{
#pragma HLS interface s_axilite port = oper_mode
#pragma HLS interface s_axilite port = encryption
#pragma HLS interface s_axilite port = key_bytes
#pragma HLS interface s_axilite port = iv_bytes
#pragma HLS interface s_axilite port = input_bytes
#pragma HLS interface s_axilite port = aad_bytes
#pragma HLS interface s_axilite port = tag_bytes
#pragma HLS interface s_axilite port = return
#pragma HLS interface m_axi depth = aes_max_addr_mem port = key offset = slave
#pragma HLS interface m_axi depth = aes_max_addr_mem port = iv offset = slave
#pragma HLS interface m_axi depth = aes_max_addr_mem port = in offset = slave
#pragma HLS interface m_axi depth = aes_max_addr_mem port = out offset = slave
#pragma HLS interface m_axi depth = aes_max_addr_mem port = aad offset = slave
#pragma HLS interface m_axi depth = aes_max_addr_mem port = tag offset = slave

    int ret                       = 0;
    uint32 ekey[AES_EXP_KEY_SIZE] = {0x0000};
    uint32 enc = (oper_mode == AES_CTR_OPERATION_MODE || oper_mode == AES_GCM_OPERATION_MODE) ?
        uint32(AES_ENCRYPTION_MODE) :
        encryption;

#pragma HLS array_partition variable = ekey cyclic factor = 8

    aes_expand(enc, key_bytes, key, ekey);

    switch (oper_mode) {
#if defined(SYN_AES_ECB) || defined(SYN_AES_CTR)
        case AES_ECB_OPERATION_MODE:
        case AES_CTR_OPERATION_MODE:
            ret |= aes_ecb_ctr_cipher(oper_mode, encryption, key_bytes, iv_bytes, input_bytes, ekey,
                                      iv, in, out);
            break;
#endif // defined(SYN_AES_ECB) || defined(SYN_AES_CTR)

#ifdef SYN_AES_CBC
        case AES_CBC_OPERATION_MODE:
            ret |= aes_cbc_cipher(encryption, key_bytes, input_bytes, iv_bytes, ekey, iv, in, out);
            break;
#endif // SYN_AES_CBC

#ifdef SYN_AES_GCM
        case AES_GCM_OPERATION_MODE:
            ret |= aes_gcm_cipher(encryption, key_bytes, input_bytes, iv_bytes, aad_bytes,
                                  tag_bytes, ekey, iv, in, out, aad, tag);
            break;
#endif // SYN_AES_GCM

        default: break;
    }

    return ret;
}
