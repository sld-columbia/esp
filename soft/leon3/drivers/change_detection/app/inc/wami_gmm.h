#ifndef _WAMI_GMM_H_
#define _WAMI_GMM_H_

#include <stdint.h>

#include "wami_params.h"

void wami_gmm(int rows, int cols,
    uint8_t foreground[rows][cols],
    float mu[rows][cols][WAMI_GMM_NUM_MODELS],
    float sigma[rows][cols][WAMI_GMM_NUM_MODELS],
    float weights[rows][cols][WAMI_GMM_NUM_MODELS],
    uint16_t (* const frames)[cols]);

#endif
