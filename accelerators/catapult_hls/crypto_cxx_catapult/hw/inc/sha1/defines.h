#ifndef __SHA1_DEFINES_H__
#define __SHA1_DEFINES_H__

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SHA1_HBLOCK_WORDS      5
#define SHA1_CBLOCK_BYTES      64
#define SHA1_CBLOCK_WORDS      16
#define SHA1_CBLOCK_BYTES_MASK ~63

#define SHA1_DIGEST_LENGTH 20
#define SHA1_DIGEST_WORDS  5

#endif /* __DEFINES_H__ */
