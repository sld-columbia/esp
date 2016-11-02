
        .text
        .align 64
        .global privtrap

privtrap:
        // set PS bit to 1 so code is in supervisor mode after trap
        rd %psr, %l3
        or %l3, 0x40, %l3
        wr %l3, %psr
        // increment privtrap_ctr
        sethi %hi(privtrap_ctr), %l3
        or %l3, %lo(privtrap_ctr), %l3
        ld [%l3], %l4
        add %l4, 1, %l4
        st %l4, [%l3]
        // return to instruction after the trapped one
        jmpl %l2, %g0
        rett %l2+4

        .data
        .global privtrap_ctr
privtrap_ctr:
        .long 0
