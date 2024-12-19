#ifndef __DEC_H__
#define __DEC_H__

#include "defines.h"

void aes_decrypt(uint32 key_bytes, uint32 in[AES_BLOCK_WORDS], uint32 out[AES_BLOCK_WORDS],
                 uint32 ekey[AES_EXP_KEY_SIZE]);

#endif /* __DEC_H__ */
