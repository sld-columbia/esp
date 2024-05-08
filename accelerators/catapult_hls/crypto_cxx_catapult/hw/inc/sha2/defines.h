#ifndef __SHA2_DEFINES_H__
#define __SHA2_DEFINES_H__

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SHA256_HBLOCK_WORDS      8
#define SHA256_CBLOCK_BYTES      64
#define SHA256_CBLOCK_WORDS      16
#define SHA256_CBLOCK_BYTES_MASK ~63

#define SHA512_HBLOCK_WORDS      8
#define SHA512_CBLOCK_BYTES      128
#define SHA512_CBLOCK_WORDS      32
#define SHA512_CBLOCK_BYTES_MASK ~127

#define SHA224_DIGEST_LENGTH 28
#define SHA256_DIGEST_LENGTH 32
#define SHA384_DIGEST_LENGTH 48
#define SHA512_DIGEST_LENGTH 64

#define SHA2_MAX_DIGEST_WORDS 16

#endif /* __DEFINES_H__ */
