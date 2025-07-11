#ifndef __AES_H__
#define __AES_H__

#include "defines.h"

int aes(uint32 oper_mode, uint32 encryption, uint32 key_bytes, uint32 iv_bytes, uint32 input_bytes,
        uint32 aad_bytes, uint32 tag_bytes,
        uint32 key[AES_MAX_KEY_WORDS], // input, max=8
        uint32 iv[AES_MAX_IV_WORDS],   // input, max=4 (parameter for cbc, ctr, gcm only)
        uint32 in[AES_MAX_IN_WORDS],   // input, max=40(ecb,cbc),16(ctr).32(gcm)
        uint32 out[AES_MAX_IN_WORDS],  // output, max=40(ecb,cbc),16(ctr),32(gcm)
        uint32 aad[AES_MAX_IN_WORDS],  // input, max=32 (parameter for gcm only)
        uint32 tag[AES_MAX_IN_WORDS]); // input/output, max=4 (parameter gcm only)

#endif /* __AES_H__ */
