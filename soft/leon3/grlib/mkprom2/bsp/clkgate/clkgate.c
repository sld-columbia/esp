#include <stdint.h>

#include "clkgate.h"

static volatile struct grclkgate_regs *const regs =
        (struct grclkgate_regs *) GRCLKGATE_REG_ADDR;

/* Implementation according to GRLIB IP core User's Manual. */

/*
 * The bits in clock enable and core reset registers can only be written when
 * the corresponding bit in the unlock register is 1.
 */

int clkgate_gate(uint32_t coremask)
{
        regs->unlock = coremask;
        regs->reset = coremask;
        regs->enable = 0;
        regs->unlock = 0;

        return 0;
}

int clkgate_enable(uint32_t coremask)
{
        /* Filter out cores which are already enabled. */
        coremask = coremask & ~(regs->enable);
        regs->unlock = coremask;
        regs->reset = coremask;
        regs->enable = coremask;
        regs->reset = 0;
        regs->unlock = 0;

        return 0;
}

