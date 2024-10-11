#ifndef __ECB_H__
#define __ECB_H__

#include "../defines.h"
#include "../exp.h"
#include "../enc.h"
#include "../dec.h"

/* Electronic Codebook (ECB) */
/* Integer Counter Mode (CTR) */

int aes_ecb_ctr_cipher(uint32 oper_mode,
                       uint32 encryption,
                       uint32 key_bytes,
                       uint32 iv_bytes,
                       uint32 input_bytes,
                       uint32 ekey[AES_EXP_KEY_SIZE],
                       uint32 iv[AES_MAX_IV_WORDS],
                       uint32 in[AES_MAX_IN_WORDS],
                       uint32 out[AES_MAX_IN_WORDS]);

#endif /* __ECB_H__ */
