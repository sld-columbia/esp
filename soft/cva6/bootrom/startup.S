# start sequence of the bootloader
#
#
#include <smp.h>
#define DRAM_BASE 0x80000000

  .section .text.init
  .option norvc
  .globl _prog_start
_prog_start:
#if SMP != 1
  smp_pause(s1, s2)
#endif
  li sp, 0x9ff00000
  call main
#if SMP != 1
  smp_resume(s1, s2)
#endif
  csrr a0, mhartid
  la a1, _dtb
  li s1, DRAM_BASE
  jr s1

  .section .dtb
  .globl _dtb
  .align 4, 0
_dtb:
  .incbin "riscv.dtb"
