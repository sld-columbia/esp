/************************************************************************/
/*   This file is a part of the mkprom2 boot-prom utility               */
/*   Copyright (C) 2016 Cobham Gaisler                                  */
/*                                                                      */
/*   This library is free software; you can redistribute it and/or      */
/*   modify it under the terms of the GNU General Public                */
/*   License as published by the Free Software Foundation; either       */
/*   version 2 of the License, or (at your option) any later version.   */
/*                                                                      */
/*   See the file COPYING.GPL for the full details of the license.      */
/************************************************************************/



    .seg    "text"
    .global _prom_registers_init

_prom_registers_init:

    /* LEON2 */
    set    LEON_REG, %g1
    set    0x81000f, %g2
    st     %g2, [%g1+0x14]       ! Leon2 Cache Ctrl register

    /* MCTRL */
    set   _memcfg1, %g2          ! leon2 Load memory config register 1
    ld    [%g2], %g2
    ld    [%g1], %g3             !
    and   %g3, 0x300, %g3
    or    %g2, %g3, %g2
    st    %g2, [%g1 + 0x00]
    set   _memcfg2, %g2          ! leon2 Load memory config register 2
    ld    [%g2], %g2
    st    %g2, [%g1 + 0x04]
    set   _memcfg3, %g2          ! leon2 Load memory config register 3
    ld    [%g2], %g2
    ld    [%g1 + 0x08], %g3
    set   0x100, %g4             ! dont write PROM edac enable (bit 8), set from external PIN
    and   %g3, %g4, %g3
    andn  %g2, %g4, %g2
    or    %g3, %g2, %g2
    st    %g2, [%g1 + 0x08]

    /* TIMER */
    set   freq, %g2              ! leon2 Load timer scaler register
    ld    [%g2], %g2
    sub   %g2, 1, %g2

    st    %g2, [%g1 + 0x64]      ! leon2 timer prescalar reload register
    st    %g2, [%g1 + 0x60]      ! leon2 timer prescalar counter register
    set   -1, %g3
    st    %g3, [%g1 + 0x40]      ! leon2 timer1 count register
    st    %g3, [%g1 + 0x44]      ! leon2 timer1 reload register
    set   7, %g3
    st    %g3, [%g1 + 0x48]      ! leon2 timer1 ctrl register

    /* IRQMP */
    set   LEON_REG, %g1
    sub   %g0, 1, %g2
    st    %g0, [%g1 + 0x90]      ! Clear irq mask
    st    %g0, [%g1 + 0x98]      ! Clear irq force
    st    %g2, [%g1 + 0x9C]      ! Clear irq pending
    st    %g0, [%g1 + 0x100]     ! Clear CIC mask
    st    %g2, [%g1 + 0x108]     ! Clear CIC pending

    /* UART */
    sethi %hi(0x800001C8), %g1   ! Load UART reset register
    or    %g1, %lo(0x800001C8), %g1
    set   1, %g2                 ! Reset UART module
    st    %g2, [%g1]
    set   _uaddr, %g1            ! Load UART base address
    ld    [%g1], %g1
    set   _uart, %g2             ! Load UART scaler value
    ld    [%g2], %g2
    st    %g2, [%g1 + 0x20]      ! UART scalar register
    set   3, %g2                 ! Enable UART
    st    %g2, [%g1 + 0x1C]      ! UART ctrl register
    st    %g0, [%g1 + 0x18]      ! UART status register

    mov    %g0, %y               ! Init Y-register

    retl
      nop
