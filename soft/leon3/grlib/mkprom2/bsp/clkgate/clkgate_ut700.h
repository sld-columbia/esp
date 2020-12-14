#ifndef _CLKGATE_UT700_H
#define _CLKGATE_UT700_H

/*
 * Any combination of the following defines can be used (ored) when calling the
 * clkgate_gate() and clkgate_enable() functions.
 */
#define CLKGATE_UT700_GR1553B   (1 <<  7)
#define CLKGATE_UT700_GRPCI     (1 <<  6)
#define CLKGATE_UT700_GRETH     (1 <<  5)
#define CLKGATE_UT700_CAN       (1 <<  4)
#define CLKGATE_UT700_GRSPW3    (1 <<  3)
#define CLKGATE_UT700_GRSPW2    (1 <<  2)
#define CLKGATE_UT700_GRSPW1    (1 <<  1)
#define CLKGATE_UT700_GRSPW0    (1 <<  0)
#define CLKGATE_UT700_ALL       (0xff)

#endif

