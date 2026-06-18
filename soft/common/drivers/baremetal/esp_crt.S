#define _start __esp_riscv_tests_start
#include "crt.S"
#undef _start

  .section ".text.init"
  .globl _start
_start:
  la  t0, __esp_boot_dtb
  SREG a1, 0(t0)
  j   __esp_riscv_tests_start

  .section ".data"
  .align 3
  .globl __esp_boot_dtb
__esp_boot_dtb:
#if __riscv_xlen == 64
  .dword 0
#else
  .word 0
#endif
