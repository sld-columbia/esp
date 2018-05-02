#ifndef _WAMI_DEBAYER_H_
#define _WAMI_DEBAYER_H_

#include "wami_params.h"

/* Shorten the name of the Debayer pad for readability */
#define PAD WAMI_DEBAYER_PAD

void wami_debayer(int rows, int cols, rgb_pixel debayered[rows- 2 * PAD][cols - 2 * PAD], uint16_t (* const bayer)[cols]);

#endif
