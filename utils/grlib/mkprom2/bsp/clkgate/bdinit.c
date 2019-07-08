#define GRCLKGATE_REG_ADDR 0x80000600
#include "clkgate.c"
#include "init_dev.c"

/*
 * bdinit0 is called before peripheral has been initialized and before RAM is
 * available.
 */
void bdinit0(void)
{
}

/*
 * bdinit1 is called after peripherals registers have been initialized, but
 * before RAM is available.
 */
void bdinit1(void)
{
}

#include "clkgate_ut700.h"


/*
 * This is an example initialization table.
 *
 * For this particular example, it is assumed that an GPIO peripheral (GRGPIO)
 * is available at register address 0x80000900. This is applicable for example
 * to UT700.
 *
 * The table is made up of a set of entries.
 * Each entry is on the format             {address, value}.
 * The table is terminated with the entry  {0,       0}
 */
const struct init_dev init_dev_table_example[] = {
/* gpio0 - General Purpose I/O port */
        /* First mask interrupts and then configure all signals as inputs. */
        {0x8000090c, /* I/O interrupt mask register             */ 0x00000000},
        {0x80000910, /* I/O interrupt polarity register         */ 0x000003c0},
        {0x80000914, /* I/O interrupt edge register             */ 0x00000000},
        {0x80000908, /* I/O port direction register             */ 0x00000000},
        {0x80000904, /* I/O port output register                */ 0x00000000},

/* The table must be terminated with the 0 as address. */
	{0x00000000, /* END OF TABLE                            */ 0x00000000}
};

/* bdinit2 is called after MKPROM boot loader has initialized memory. */
void bdinit2(void)
{
        /*
         * Do custom register initialization based on a static table, defined
         * above.
         */
        init_dev(&init_dev_table_example[0]);

        /*
         * Clock gate the MIL-STD-1553, CAN and SpaceWire 3 core. More
         * defines for UT700 are available in the file clkgate_ut700.h
         */
        clkgate_gate(
                CLKGATE_UT700_GR1553B   |
                CLKGATE_UT700_CAN       |
                CLKGATE_UT700_GRSPW3    |
                0
        );

        /*
         * Clock enable SpaceWire 0 core. This is not needed on UT700 since all
         * cores are enabled on reset.
         */
#if 0
        clkgate_enable(
                CLKGATE_UT700_GRSPW0    |
                0
        );
#endif
}

