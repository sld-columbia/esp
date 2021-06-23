# start sequence of the bootloader
#
#
#include <smp.h>
#include "esplink.h"
#define DRAM_BASE 0x80000000
#ifdef OVERRIDE_DRAM_SIZE
#define SP_MAX (DRAM_BASE + (OVERRIDE_DRAM_SIZE >> 1) - 0x10)
#else
#define SP_MAX 0x9fff0000
#endif

  .section .text.init
  .option norvc
  .globl _prog_start
_prog_start:
  smp_pause(s1, s2)
  li sp, SP_MAX
  call main
  smp_resume(s1, s2)
  csrr a0, mhartid
  la a1, _dtb
  li s1, DRAM_BASE
  jr s1

  .section .dtb
  .globl _dtb
  .align 4, 0
_dtb:
  .incbin "riscv.dtb"
