// Copyright (c) 2011-2026 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdint.h>

#include "uart.h"

// Standalone Ariane validation payload for CPU, DDR, AMO, timer, and SoC CSR access.

#define DDR_OPEN_SBI_PAYLOAD_BASE UINT64_C(0x80200000)
#define DDR_OPEN_SBI_FDT_BASE     UINT64_C(0x82200000)
#define DDR_SCRATCH_BASE          UINT64_C(0x81000000)
#define DDR_TEST_BYTES            (32U * 1024U)
#define DDR_TEST_WORDS            (DDR_TEST_BYTES / sizeof(uint64_t))

#define UART_BASE_ADDR UINT64_C(0x60000100)
#define UART_DATA_ADDR (UART_BASE_ADDR + UINT64_C(0x00))
#define UART_STAT_ADDR (UART_BASE_ADDR + UINT64_C(0x04))
#define UART_CTRL_ADDR (UART_BASE_ADDR + UINT64_C(0x08))
#define UART_SCAL_ADDR (UART_BASE_ADDR + UINT64_C(0x0c))

#define CLINT_MTIME_ADDR UINT64_C(0x0200bff8)
#define PLIC_PRIORITY1   UINT64_C(0x6c000004)
#define PLIC_PENDING0    UINT64_C(0x6c001000)
#define PLIC_THRESHOLD0  UINT64_C(0x6c200000)

#ifndef DIAG_ENABLE_SOC_REG_READS
#define DIAG_ENABLE_SOC_REG_READS 1
#endif

static inline uint64_t read_csr_mhartid(void)
{
	uint64_t value;
	__asm__ volatile("csrr %0, mhartid" : "=r"(value));
	return value;
}

static inline uint64_t read_csr_mcycle(void)
{
	uint64_t value;
	__asm__ volatile("csrr %0, mcycle" : "=r"(value));
	return value;
}

static inline uint64_t read_csr_minstret(void)
{
	uint64_t value;
	__asm__ volatile("csrr %0, minstret" : "=r"(value));
	return value;
}

static inline uint64_t read_csr_misa(void)
{
	uint64_t value;
	__asm__ volatile("csrr %0, misa" : "=r"(value));
	return value;
}

static inline void fence_rw(void)
{
	__asm__ volatile("fence rw, rw" ::: "memory");
}

static inline uint64_t rotl64(uint64_t value, unsigned int shift)
{
	return (value << shift) | (value >> (64U - shift));
}

static uint64_t pattern64(uint64_t base, uint64_t index)
{
	uint64_t x = base + UINT64_C(0x9e3779b97f4a7c15) * (index + 1U);

	x ^= x >> 33;
	x *= UINT64_C(0xff51afd7ed558ccd);
	x ^= x >> 29;
	x *= UINT64_C(0xc4ceb9fe1a85ec53);
	x ^= x >> 32;
	return x;
}

static void print_hex64_label(const char *label, uint64_t value)
{
	print_uart(label);
	print_uart_int64(value);
	print_uart("\n");
}

static void print_dec_u64(uint64_t value)
{
	char buf[21];
	unsigned int pos = sizeof(buf);

	buf[--pos] = '\0';
	if (value == 0) {
		buf[--pos] = '0';
	}
	else {
		while (value != 0 && pos > 0) {
			buf[--pos] = (char)('0' + (value % 10U));
			value /= 10U;
		}
	}

	print_uart(&buf[pos]);
}

static void print_dec_i32(int value)
{
	if (value < 0) {
		print_uart("-");
		print_dec_u64((uint64_t)(-value));
	}
	else {
		print_dec_u64((uint64_t)value);
	}
}

static void print_progress_line(const char *phase, const char *name, uint64_t index)
{
	print_uart("[diag] ");
	print_uart(phase);
	print_uart(" ");
	print_uart(name);
	print_uart(" index ");
	print_dec_u64(index);
	print_uart("\n");
}

static void test_uart_burst(void)
{
	print_uart("[diag] UART burst start\n");
	for (unsigned int i = 0; i < 32; ++i) {
		print_uart("[diag] UART burst line ");
		print_dec_u64(i);
		print_uart(" abcdefghijklmnopqrstuvwxyz 0123456789\n");
	}
	print_uart("[diag] UART burst end\n");
}

uintptr_t handle_trap(uintptr_t cause, uintptr_t epc, uintptr_t regs[32])
{
	(void)regs;

	print_uart("\n[diag] TRAP cause=0x");
	print_uart_int64(cause);
	print_uart(" epc=0x");
	print_uart_int64(epc);
	print_uart("\n");

	while (1) {
		__asm__ volatile("wfi");
	}
}

static int test_integer_pipeline(void)
{
	uint64_t x = UINT64_C(0x0123456789abcdef);
	uint64_t y = UINT64_C(0xfedcba9876543210);

	print_uart("[diag] integer pipeline start\n");
	for (uint64_t i = 0; i < 4096; ++i) {
		x = rotl64(x ^ (i * UINT64_C(0x100000001b3)), 13);
		y ^= x + UINT64_C(0x9e3779b97f4a7c15) + (y << 6) + (y >> 2);
		if ((i & 0x3ffU) == 0) {
			print_progress_line("integer", "loop", i);
		}
	}

	print_hex64_label("[diag] integer checksum 0x", x ^ y);
	print_uart("[diag] integer pipeline end\n");
	return 0;
}

static uint64_t stack_walk(unsigned int depth, uint64_t seed)
{
	volatile uint64_t local[8];
	uint64_t mix = seed ^ (UINT64_C(0xfeedfacecafebeef) + depth);

	for (unsigned int i = 0; i < 8; ++i) {
		local[i] = pattern64(mix, i + depth);
		mix ^= local[i] + rotl64(mix, 7);
	}

	if (depth == 0) {
		return mix;
	}

	return mix ^ stack_walk(depth - 1, mix + depth);
}

static int test_stack(void)
{
	uint64_t checksum = stack_walk(12, UINT64_C(0x13579bdf2468ace0));

	print_hex64_label("[diag] stack checksum   0x", checksum);
	print_uart("[diag] stack walk complete\n");
	return 0;
}

static int test_ddr_range(uint64_t base, const char *name)
{
	volatile uint64_t *mem = (volatile uint64_t *)(uintptr_t)base;
	uint64_t checksum = 0;
	int errors = 0;

	print_uart("[diag] DDR ");
	print_uart(name);
	print_uart(" write 0x");
	print_uart_int64(base);
	print_uart("..0x");
	print_uart_int64(base + DDR_TEST_BYTES - 1U);
	print_uart("\n");

	for (uint64_t i = 0; i < DDR_TEST_WORDS; ++i) {
		mem[i] = pattern64(base, i);
		if ((i & 0x1ffU) == 0) {
			print_progress_line("DDR write", name, i);
		}
	}

	fence_rw();
	print_uart("[diag] DDR ");
	print_uart(name);
	print_uart(" readback start\n");

	for (uint64_t i = 0; i < DDR_TEST_WORDS; ++i) {
		uint64_t expected = pattern64(base, i);
		uint64_t observed = mem[i];

		if ((i & 0x1ffU) == 0) {
			print_progress_line("DDR read", name, i);
		}

		checksum ^= observed + rotl64(checksum, 11);
		if (observed != expected) {
			if (errors < 4) {
				print_uart("[diag] DDR mismatch ");
				print_uart(name);
				print_uart(" index ");
				print_dec_u64(i);
				print_uart(" exp=0x");
				print_uart_int64(expected);
				print_uart(" got=0x");
				print_uart_int64(observed);
				print_uart("\n");
			}
			++errors;
		}
	}

	print_uart("[diag] DDR ");
	print_uart(name);
	print_uart(" errors=");
	print_dec_i32(errors);
	print_uart(" checksum=0x");
	print_uart_int64(checksum);
	print_uart("\n");

	return errors;
}

static int test_narrow_accesses(void)
{
	volatile uint8_t *bytes = (volatile uint8_t *)(uintptr_t)(DDR_SCRATCH_BASE + 0x20000U);
	volatile uint16_t *halves = (volatile uint16_t *)(uintptr_t)(DDR_SCRATCH_BASE + 0x21000U);
	volatile uint32_t *words = (volatile uint32_t *)(uintptr_t)(DDR_SCRATCH_BASE + 0x22000U);
	int errors = 0;

	print_uart("[diag] narrow byte writes\n");
	for (unsigned int i = 0; i < 256; ++i) {
		bytes[i] = (uint8_t)(i ^ 0xa5U);
	}
	print_uart("[diag] narrow halfword writes\n");
	for (unsigned int i = 0; i < 128; ++i) {
		halves[i] = (uint16_t)(0x5a00U | i);
	}
	print_uart("[diag] narrow word writes\n");
	for (unsigned int i = 0; i < 128; ++i) {
		words[i] = (uint32_t)(0xc0010000U | i);
	}

	fence_rw();

	print_uart("[diag] narrow readback\n");
	for (unsigned int i = 0; i < 256; ++i) {
		if (bytes[i] != (uint8_t)(i ^ 0xa5U)) {
			++errors;
		}
	}
	for (unsigned int i = 0; i < 128; ++i) {
		if (halves[i] != (uint16_t)(0x5a00U | i)) {
			++errors;
		}
	}
	for (unsigned int i = 0; i < 128; ++i) {
		if (words[i] != (uint32_t)(0xc0010000U | i)) {
			++errors;
		}
	}

	print_uart("[diag] narrow access errors=");
	print_dec_i32(errors);
	print_uart("\n");
	return errors;
}

static int test_amo(void)
{
	volatile uint64_t *word = (volatile uint64_t *)(uintptr_t)(DDR_SCRATCH_BASE + 0x23000U);
	uint64_t old;
	int errors = 0;

	*word = UINT64_C(0x100);
	fence_rw();

	__asm__ volatile("amoadd.d %0, %2, (%1)"
			 : "=r"(old)
			 : "r"(word), "r"(UINT64_C(0x23))
			 : "memory");

	fence_rw();

	if (old != UINT64_C(0x100) || *word != UINT64_C(0x123)) {
		++errors;
	}

	print_uart("[diag] amo old=0x");
	print_uart_int64(old);
	print_uart(" new=0x");
	print_uart_int64(*word);
	print_uart(" errors=");
	print_dec_i32(errors);
	print_uart("\n");

	return errors;
}

static int test_soc_register_reads(void)
{
	volatile uint32_t *uart_stat = (volatile uint32_t *)(uintptr_t)UART_STAT_ADDR;
	volatile uint32_t *uart_ctrl = (volatile uint32_t *)(uintptr_t)UART_CTRL_ADDR;
	volatile uint32_t *uart_scal = (volatile uint32_t *)(uintptr_t)UART_SCAL_ADDR;
	volatile uint64_t *mtime = (volatile uint64_t *)(uintptr_t)CLINT_MTIME_ADDR;
	volatile uint32_t *plic_prio = (volatile uint32_t *)(uintptr_t)PLIC_PRIORITY1;
	volatile uint32_t *plic_pending = (volatile uint32_t *)(uintptr_t)PLIC_PENDING0;
	volatile uint32_t *plic_threshold = (volatile uint32_t *)(uintptr_t)PLIC_THRESHOLD0;
	uint64_t t0;
	uint64_t t1;

	(void)UART_DATA_ADDR;

	print_uart("[diag] SoC register probe start\n");
	print_uart("[diag] uart stat=0x");
	print_uart_int64(*uart_stat);
	print_uart(" ctrl=0x");
	print_uart_int64(*uart_ctrl);
	print_uart(" scaler=0x");
	print_uart_int64(*uart_scal);
	print_uart("\n");

	print_uart("[diag] reading CLINT mtime\n");
	t0 = *mtime;
	for (volatile unsigned int i = 0; i < 1000U; ++i) {
		;
	}
	t1 = *mtime;
	print_uart("[diag] clint mtime0=0x");
	print_uart_int64(t0);
	print_uart(" mtime1=0x");
	print_uart_int64(t1);
	print_uart("\n");

	print_uart("[diag] reading PLIC registers\n");
	print_uart("[diag] plic priority1=0x");
	print_uart_int64(*plic_prio);
	print_uart(" pending0=0x");
	print_uart_int64(*plic_pending);
	print_uart(" threshold0=0x");
	print_uart_int64(*plic_threshold);
	print_uart("\n");
	print_uart("[diag] SoC register probe end\n");

	return 0;
}

int main(int argc, char **argv)
{
	int errors = 0;

	(void)argc;
	(void)argv;

	print_uart("\n[diag] ESP Ariane baremetal diagnostic start\n");
	test_uart_burst();
	print_hex64_label("[diag] mhartid          0x", read_csr_mhartid());
	print_hex64_label("[diag] misa             0x", read_csr_misa());
	print_hex64_label("[diag] mcycle start     0x", read_csr_mcycle());
	print_hex64_label("[diag] minstret start   0x", read_csr_minstret());

	errors += test_integer_pipeline();
	errors += test_stack();
	errors += test_ddr_range(DDR_OPEN_SBI_PAYLOAD_BASE, "opensbi-payload");
	errors += test_ddr_range(DDR_OPEN_SBI_FDT_BASE, "opensbi-fdt");
	errors += test_ddr_range(DDR_SCRATCH_BASE, "scratch");
	errors += test_narrow_accesses();
	errors += test_amo();

	if (errors == 0) {
		print_uart("[diag] core and DDR checks PASS; probing SoC registers next\n");
	}
	else {
		print_uart("[diag] core and DDR checks found errors; probing SoC registers next\n");
	}

#if DIAG_ENABLE_SOC_REG_READS
	errors += test_soc_register_reads();
#else
	print_uart("[diag] SoC register probe skipped by DIAG_ENABLE_SOC_REG_READS=0\n");
#endif

	print_hex64_label("[diag] mcycle end       0x", read_csr_mcycle());
	print_hex64_label("[diag] minstret end     0x", read_csr_minstret());

	if (errors == 0) {
		print_uart("[diag] PASS\n");
	}
	else {
		print_uart("[diag] FAIL errors=");
		print_dec_i32(errors);
		print_uart("\n");
	}

	return errors == 0 ? 0 : 1;
}
