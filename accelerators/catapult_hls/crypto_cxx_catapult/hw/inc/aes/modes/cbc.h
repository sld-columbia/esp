#ifndef __CBC_H__
#define __CBC_H__

#include "../dec.h"
#include "../defines.h"
#include "../enc.h"
#include "../exp.h"

/* Cipher Block Chaining (CBC) */

int aes_cbc_cipher(uint32 encryption, uint32 key_bytes, uint32 input_bytes, uint32 iv_bytes,
                   uint32 ekey[AES_EXP_KEY_SIZE], uint32 iv[AES_MAX_IV_WORDS],
                   uint32 in[AES_MAX_IN_WORDS], uint32 out[AES_MAX_IN_WORDS]);

#endif /* __CBC_H__ */
