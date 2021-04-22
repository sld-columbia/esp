#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <err.h>
#include <fcntl.h>
#include <stdint.h>

#include "le_zcu.h"

#ifndef __EDCL_H__
#define __EDCL_H__



/* #define VERBOSE */

#define NWORD_MAX_SND 27
#define MAX_SND_SZ (4 * NWORD_MAX_SND)
#define BUFSIZE_MAX_SND (10 + 4 * NWORD_MAX_SND)

#define NWORD_MAX_RCV 23
#define MAX_RCV_SZ (4 * NWORD_MAX_RCV)
#define BUFSIZE_MAX_RCV (10 + 4 * NWORD_MAX_RCV)

typedef unsigned char u8;
typedef unsigned u32;
typedef unsigned long long u64;

typedef enum action {
	DO_NONE = 0,
	DO_READ,
	DO_WRITE,
	DO_READ_BIN,
	DO_WRITE_BIN,
	DO_SET_WORD,
	DO_GET_WORD,
	DO_LOAD_BOOTROM,
	DO_LOAD_DRAM,
	DO_RESET
} action_t;

void* MMU_Remap(unsigned long int PhysAddr, unsigned long int MappedRange_Bytes);
unsigned* uiomap();
uint64_t* udmabufmap();
void die(char *s);
void load_memory(void *ptr, char *fname);
void dump_memory_uio(unsigned *ptr, u32 address, u32 size, char *fname);
void load_memory_bin_uio(unsigned *ptr, u32 base_addr, char *fname);
void dump_memory_bin_uio(unsigned *ptr, u32 address, u32 size, char *fname);
void set_word_uio(unsigned *ptr, u32 addr, u32 data);
void get_word_uio(unsigned *ptr, u32 addr);
void dump_memory_udma(uint64_t *ptr, u32 address, u32 size, char *fname);
void load_memory_bin_udma(uint64_t *ptr, u32 base_addr, char *fname);
void dump_memory_bin_udma(uint64_t *ptr, u32 address, u32 size, char *fname);
void set_word_udma(uint64_t *ptr, u32 addr, u64 data);
void get_word_udma(uint64_t *ptr, u32 addr);
void reset(unsigned *ptr, u32 addr);

#endif /* SRC_MEMMAP_H_ */
