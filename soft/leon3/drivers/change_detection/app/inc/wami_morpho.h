/*
 * Morphological image operations. These are currently used only for
 * correctness evaluation and are not part of the PERFECT suite proper.
 */
#ifndef _WAMI_MORPHO_H_
#define _WAMI_MORPHO_H_

#include <stdint.h>

#include "wami_params.h"

void wami_morpho_erode(int rows, int cols,
    uint8_t eroded[rows][cols],
    uint8_t frame[rows][cols]);

#endif
