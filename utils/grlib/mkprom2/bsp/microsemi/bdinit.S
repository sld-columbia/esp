        .section        .text
        .global         bdinit0
        .global         bdinit1
        .global         bdinit2

/* NOTE: Memory is NOT available when bdinit0 is called. */
bdinit0:
        /* Remember return address */
        mov     %o7, %g5

#if MDDR_APB
        set     MDDR_APB, %l0
        st      %g0, [%l0]
        set     mddr_init_table, %o1
        call    init_reg32
         mov    %l0, %o0
        set     1, %g1
        st      %g1, [%l0]
#endif

#if FDDRE_APB
        set     FDDRE_APB, %l0
        st      %g0, [%l0]
        set     fddre_init_table, %o1
        call    init_reg32
         mov    %l0, %o0
        set     1, %g1
        st      %g1, [%l0]
#endif

#if FDDRW_APB
        set     FDDRW_APB, %l0
        st      %g0, [%l0]
        set     fddrw_init_table, %o1
        call    init_reg32
         mov    %l0, %o0
        set     1, %g1
        st      %g1, [%l0]
#endif

#if SERDES_APB
        set     SERDES_APB, %o0

        /* Clear bit 5 at offset 0x2008 */
        set     0x2008, %o2
        ld      [%o0 + %o2], %o3
        andn    %o3, 0x20, %o3
        st      %o3, [%o0 + %o2]

        set     serdes_init_table, %o1
        call    init_reg32
         nop

        /* Set bit 5 at offset 0x2008 */
        set     0x2008, %o2
        ld      [%o0 + %o2], %o3
        or      %o3, 0x20, %o3
        st      %o3, [%o0 + %o2]
#endif

        mov     %g5, %o7
        retl
         nop

/*
 * This routine generates bus writes given a table of offset/value pairs. See
 * the file init_reg32.c for the interface.
 */
#include "../shared/init_reg32.S"

/* Bring in the configuration table for DDR controller */
#if MDDR_APB
        .section        .rodata
        .global         mddr_init_table
mddr_init_table:
#include "mddr_init.inc"
#endif

/* Bring in the configuration table for DDR controller */
#if FDDRE_APB
        .section        .rodata
        .global         fddre_init_table
mddr_init_table:
#include "fddre_init.inc"
#endif

/* Bring in the configuration table for DDR controller */
#if FDDRW_APB
        .section        .rodata
        .global         fddrw_init_table
mddr_init_table:
#include "fddrw_init.inc"
#endif

/* Bring in the configuration table for SERDES controller */
#if SERDES_APB
        .section        .rodata
        .global         serdes_init_table
serdes_init_table:
#include "serdes_init.inc"
#endif


        .section        .text
bdinit1:
        retl
         nop

bdinit2:
        retl
         nop

