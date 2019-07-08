#ifndef _CLKGATE_H
#define _CLKGATE_H

/*
 * Driver for GRLIB clock gating unit. The driver is stateless.
 */

#include <stdint.h>

/*** Control interface ***/

/* Gate the clock for cores in coremask. */
int clkgate_gate(uint32_t coremask);

/* Enable the clock and reset cores in coremask. */
int clkgate_enable(uint32_t coremask);

/* Clock gate registers */
struct grclkgate_regs {
	uint32_t unlock;
	uint32_t enable;
	uint32_t reset;
};

#endif

