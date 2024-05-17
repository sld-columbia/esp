#ifndef __SHA1_H__
#define __SHA1_H__

#include "defines.h"
#include "data.hpp"

#ifndef C_SIMULATION
//#include <ac_int.h>
#ifndef __MENTOR_CATAPULT_HLS__
#include <hls_stream.h>
#endif /* __MENTOR_CATAPULT_HLS__ */
#endif /* C_SIMULATION */

#define SHA1_MAX_BLOCK_SIZE 1600
const int sha1_max_addr_mem = 1600;

int sha1(
          uint32 in_bytes,
          uint32 in[SHA1_MAX_BLOCK_SIZE],
          uint32 out[SHA1_DIGEST_WORDS]);

#endif // __SHA1_H__
