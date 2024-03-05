#ifndef __GCM_H__
#define __GCM_H__

#include "../defines.h"
#include "../exp.h"
#include "../enc.h"
#include "../dec.h"

#include <stdlib.h>

int aes_gcm_cipher(uint32 encryption,
                   uint32 key_bytes,
                   uint32 input_bytes,
                   uint32 iv_bytes,
                   uint32 aad_bytes,
                   uint32 tag_bytes,
                   uint32 ekey[AES_EXP_KEY_SIZE],
                   uint32 iv[AES_MAX_IV_WORDS],
                   uint32 in[AES_MAX_IN_WORDS],
                   uint32 out[AES_MAX_IN_WORDS],
                   uint32 aad[AES_MAX_IN_WORDS],
                   uint32 tag[AES_MAX_IN_WORDS]);

#endif /* __GCM_H__ */
