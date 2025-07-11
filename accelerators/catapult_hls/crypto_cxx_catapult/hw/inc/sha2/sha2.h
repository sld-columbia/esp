#ifndef __SHA2_H__
#define __SHA2_H__

#include "defines.h"
#include "data.hpp"

#ifndef C_SIMULATION
    #ifndef __MENTOR_CATAPULT_HLS__
        #include <hls_stream.h>
    #endif /* __MENTOR_CATAPULT_HLS__ */
#endif     /* C_SIMULATION */

#define SHA2_MAX_BLOCK_SIZE 1600
const int sha2_max_addr_mem = 1600;

/* out_len = 28 -> SHA2-224 */
/* out_len = 32 -> SHA2-256 */
/* out_len = 48 -> SHA2-384 */
/* out_len = 64 -> SHA2-512 */

int sha2(
#ifdef PROPERTIES_ENABLED
    uint32 props,
#endif // PROPERTIES_ENABLED
    uint32 in_bytes, uint32 out_bytes, uint32 in[SHA2_MAX_BLOCK_SIZE],
    uint32 out[SHA2_MAX_DIGEST_WORDS]);

#endif /* __SHA2_H__ */
