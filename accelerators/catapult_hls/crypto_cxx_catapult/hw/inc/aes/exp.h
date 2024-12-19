#ifndef __EXP_H__
#define __EXP_H__

#include "defines.h"

void aes_expand(uint32 encryption, uint32 key_bytes, uint32 key[AES_MAX_KEY_WORDS],
                uint32 ekey[AES_EXP_KEY_SIZE]);

#endif /* __EXP_H__ */
