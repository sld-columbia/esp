#ifndef _WAMI_PARAMS_H_
#define _WAMI_PARAMS_H_

#include <stdint.h>

typedef struct _rgb_pixel {
    uint16_t r, g, b;
} rgb_pixel;

/*
 * WAMI_DEBAYER_PAD: The number of edge pixels clipped during the
 * debayer process due to not having enough pixels for the full
 * interpolation kernel. Other interpolations could be applied near
 * the edges, but we instead clip the image for simplicity.
 */
#define WAMI_GMM_NUM_MODELS 5
#define WAMI_GMM_NUM_FRAMES 5
#define WAMI_DEBAYER_PAD 2

#endif
