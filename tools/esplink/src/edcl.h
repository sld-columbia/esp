// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#include <le.h>

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

typedef struct edcl_msg_rcv {
	u32 offset;
	u32 sequence;
	u32 nack;
	u32 length;
	u32 address;
	u32 data[NWORD_MAX_RCV];
	size_t msglen;
} edcl_rcv_t;

typedef struct edcl_msg_snd {
	u32 offset;
	u32 sequence;
	u32 write;
	u32 length;
	u32 address;
	u32 data[NWORD_MAX_SND];
	size_t msglen;
} edcl_snd_t;

void die(char *s);
void connect_edcl(const char *server);
void dump_memory(u32 address, u32 size, char *fname);
void load_memory(char *fname);
void load_memory_bin(u32 base_addr, char *fname);
void dump_memory_bin(u32 address, u32 size, char *fname);
void set_word(u32 addr, u32 data);
void get_word(u32 addr);
void reset(u32 addr);
void disconnect_edcl(void);



#endif /* __EDCL_H__ */
