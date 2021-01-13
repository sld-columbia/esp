/* Test for alt window pointer functionality.
 * Test code assumes 5 or more windows implemented */

        .global awptest

awptest:
        /* Allocate our frame */
        save %sp, -96, %sp
        /* Skip test if not enough windows */
        mov %asr17, %l0
        and %l0, 0x1F, %l0
        cmp %l0, 5
        bl 5f
         nop
        /* For partitioning test, we want 3 below windows to not wrap around 0 (CWP >= 3) */
        /* If that is the case, call recursively to shift CWP one step */
        mov %psr, %l0
        and %l0, 0x1F, %l0
        cmp %l0, 3
        bg 8f
         nop
        call awptest
         nop
        ret
         restore
8:      /* proceed with test */
        /* Make sure we have 3 unused windows under us */
        /* (may trigger window_overflow dep on WIM state) */
        save %sp, -96, %sp
        save %sp, -96, %sp
        save %sp, -96, %sp
        restore
        restore
        restore
        /* Backup globals we are using */
        mov %g1, %l1
        mov %g2, %l2
        mov %g3, %l3
        mov %g4, %l4
        /* Just to get known condition code in PSR */
        orcc %g0, %g0, %g0
        /* Enable AWP */
        mov %psr, %g1
        set (1 << 15), %l0
        or %g1, %l0, %g2
        mov %g2, %psr
        nop
        nop
        nop
        /* Check that AWP is supported */
        mov %psr, %g3
        andcc %g3, %l0, %g0
        be 1f
         nop
        /* Set a reg in each window */
        set 1, %l7
        save %l7, 1, %l7
        save %l7, 1, %l7
        save %l7, 1, %l7
        /* Check that PSR (CWP) hasn't changed */
        orcc %g0, %g0, %g0
        mov %psr, %g3
        cmp %g2, %g3
        bne,a 2f
         mov 1, %o0
        /* Go back and check windows */
        cmp %l7, 4
        bne,a 2f
         mov 2, %o0
        restore
        cmp %l7, 3
        bne,a 2f
         mov 3, %o0
        restore
        cmp %l7, 2
        bne,a 2f
         mov 4, %o0
        restore
        cmp %l7, 1
        bne,a 2f
         mov 5, %o0
        /* Rotate full round (32xrestore, 32xsave) - should not trigger of/uf traps */
        set 32, %g3
3:      subcc %g3, 1, %g3
        bne 3b
         restore
        set 32, %g3
4:      subcc %g3, 1, %g3
        bne 4b
         save
        /* Test reading and manipulating AWP directly */
        save
        mov %asr20, %g3
        save
        save
        mov %asr20, %g4
        cmp %l7, 4
        bne,a 2f
         mov 6, %o0
        mov %g3, %asr20
        nop
        nop
        nop
        cmp %l7, 2
        bne,a 2f
         mov 7, %o0
        /* Check that we can disable AWP when AWP!=CWP */
        restore
        restore
        restore
        restore
        mov %g1, %psr
        nop
        nop
        nop
        cmp %l7, 1
        bne,a 2f
         mov 8, %o0
        /* Test trap */
        /* Install handler for software trap 11 */
        set _trap_table, %l6
        add %l6, 0x8B0, %l6
        set awptest_swtrap, %l5
        sub %l5, %l6, %l5
        sll %l5, 8, %l5
        srl %l5, 10, %l5
        set 0x30800000, %l0 /* b,a opcode */
        or %l5, %l0, %l5
        st %l5, [%l6]
        /* Enable AWP */
        mov %g2, %psr
        nop
        nop
        nop
        /* Save twice */
        save
        save
        /* Run trap */
        ta 11
        /* Check that we are still in expected window */
        cmp %l7, 3
        bne,a 2f
         mov 9, %o0
        /* Check that the trap handler ran in expected window */
        cmp %g3, 2
        bne,a 2f
         mov 10, %o0
        /* Restore CWP */
        mov %g1, %psr
        nop
        nop
        nop

        /* Test regfile partitioning */
        /* - backup and clear wim */
        mov %wim, %g3
        mov %g0, %wim
        /* enable partition of current and 3 windows below
         * atomically set CWP also to 3 */
        mov %asr20, %g4
        sub %g4, 3, %l0
        sll %l0, 5, %l0
        or %l0, 3, %l0
        sll %l0, 16, %l0
        or %l0, 32+3, %l0
        mov %l0, %asr20
        nop
        nop
        nop
        /* Move and check that we are in expected windows */
        cmp %l7, 1
        bne,a 2f
         mov 20, %o0
        set 45, %i3
        set 46, %o3
        save
        cmp %l7, 2
        bne,a 2f
         mov 21, %o0
        cmp %i3, 46
        bne,a 2f
         mov 22, %o0
        set 47, %o3
        save
        cmp %l7, 3
        bne,a 2f
         mov 23, %o0
        cmp %i3, 47
        bne,a 2f
         mov 24, %o0
        set 48, %o3
        save
        cmp %l7, 4
        bne,a 2f
         mov 25, %o0
        cmp %i3, 48
        bne,a 2f
         mov 26, %o0
        cmp %o3, 45
        bne,a 2f
         mov 27, %o0
        set 49, %o4
        save /* should wrap back here */
        cmp %l7, 1
        bne,a 2f
         mov 28, %o0
        cmp %i3, 45
        bne,a 2f
         mov 29, %o0
        cmp %i4, 49
        bne,a 2f
         mov 30, %o0
        /* check that WIM is masked on read */
        set ~0, %l0
        mov %l0, %wim
        nop
        nop
        nop
        mov %wim, %l0
        cmp %l0, 0xF
        bne,a 2f
         mov 31, %o0
        /* Restore ASR20 and WIM */
        mov %g4, %asr20
        mov %g1, %psr
        mov %g3, %wim
        nop
        nop
        nop
1:      /* Restore globals */
        mov %l1, %g1
        mov %l2, %g2
        mov %l3, %g3
        mov %l4, %g4
5:      ret
         restore
2:      call fail
         nop
        b,a 1b

awptest_swtrap:
        mov %l7, %g3
        mov %psr, %g4
        jmpl %l2, %g0
        rett %l2+4
