/*
 * Copyright (c) 2011-2019 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#define _GNU_SOURCE /* asprintf */

#include <assert.h>
#include <ctype.h>
#include <stdarg.h>
#include <fcntl.h>
#include <math.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/syscall.h>
#include <sched.h>
#include <unistd.h>
#include <errno.h>
#include <stdbool.h>

#include <contig.h>
#include <esp_accelerator.h>

#include "synth.h"

#define NPHASES_MAX 9
#define NTHREADS_MAX 12

#define NDEV 12
#define NDDR 2

#define M8    8388608
#define M4    4194304
#define M2    2097152
#define M1    1048576
#define K512   524288
#define K256   262144
#define K128   131072
#define K64     65536
#define K32     32768
#define K16     16384
#define K8       8192
#define K4       4096
#define K2       2048
#define K1       1024

/* Helper functions */
#ifndef NORETURN
#define NORETURN __attribute__((noreturn))
#endif

static int err_vfmt(const char *prefix, const char *fmt, va_list ap)
{
        char err[2048];

        vsnprintf(err, sizeof(err), fmt, ap);
        return fprintf(stderr, "%s%s\n", prefix, err);
}

static void NORETURN die_vfmt(const char *fmt, va_list ap)
{
        err_vfmt("fatal: ", fmt, ap);
        exit(EXIT_FAILURE);
}

static void NORETURN errno_vfmt(const char *fmt, va_list ap)
{
        char err[1024];

        snprintf(err, sizeof(err), "%s: %s", fmt, strerror(errno));
        die_vfmt(err, ap);
}


static void NORETURN die_errno(const char *fmt, ...)
{
        va_list ap;

        va_start(ap, fmt);
        errno_vfmt(fmt, ap);
        va_end(ap);
}

static unsigned long long ts_subtract(const struct timespec *a, const struct timespec *b)
{
	unsigned long long ns;

	ns = (b->tv_sec - a->tv_sec) * 1000000000ULL;
	ns += (b->tv_nsec - a->tv_nsec);
	return ns;
}

static inline void gettime(struct timespec *ts)
{
	if (clock_gettime(CLOCK_MONOTONIC, ts)) {
		perror("error: cannot get time");
		exit(1);
	}
}



/* Device names */
static const char *devname[NDEV] = {
	"/dev/synth.0",
	"/dev/synth.1",
	"/dev/synth.2",
	"/dev/synth.3",
	"/dev/synth.4",
	"/dev/synth.5",
	"/dev/synth.6",
	"/dev/synth.7",
	"/dev/synth.8",
	"/dev/synth.9",
	"/dev/synth.10",
	"/dev/synth.11"};


/*
 * ESP Configuration
 *
 *  |     0          1         2          3
 *--|----------------------------------------------->  X
 *  | ---------------------------------------------
 *  | |          |          |          |          |
 * 0| |  mem.0   | synth.0  | synth.1  | synth.2  |
 *  | |          |          |          |          |
 *  | -----------+----------+----------+----------+
 *  | |          |          |          |          |
 * 1| | synth.3  |  cpu.0   | synth.4  | synth.5  |
 *  | |          |          |          |          |
 *  | -----------+----------+----------+----------+
 *  | |          |          |          |          |
 * 2| | synth.6  | synth.7  |  cpu.1   | synth.8  |
 *  | |          |          |          |          |
 *  | -----------+----------+----------+----------+
 *  | |          |          |          |          |
 * 3| |  synth.9 | synth.10 | synth.11 |  mem.1   |
 *  | |          |          |          |          |
 *  | -----------+----------+----------+----------+
 *  |
 *  v
 *
 *  Y
 *
 */

/* y -> NoC Row; x-> NoC col */
typedef struct yx_struct { unsigned char y; unsigned char x; } yx_t;

/* Device y,x coordiantes on the NoC */
/* static const yx_t coordinates[NDEV] = { */
/* 	/\* {0, 0}, mem.0 *\/ */
/* 	{0, 1}, /\* synth.0 *\/ */
/* 	{0, 2}, /\* synth.1 *\/ */
/* 	{0, 3}, /\* synth.2 *\/ */
/* 	{1, 0}, /\* synth.3 *\/ */
/* 	/\* {1, 1}, cpu 0 *\/ */
/* 	{1, 2}, /\* synth.4 *\/ */
/* 	{1, 3}, /\* synth.5 *\/ */
/* 	{2, 0}, /\* synth.6 *\/ */
/* 	{2, 1}, /\* synth.7 *\/ */
/* 	/\* {2, 2}, cpu.1 *\/ */
/* 	{2, 3}, /\* synth.8 *\/ */
/* 	{3, 0}, /\* synth.9 *\/ */
/* 	{3, 1}, /\* synth.10 *\/ */
/* 	{3, 2}, /\* synth.11 *\/ */
/* 	/\* {3, 3} mem 1 *\/ */
/* }; */


/* Hops from DDR nodes (the lower the better) */
static const unsigned int ddr_hops[NDEV][NDDR] = {
	{1, 5},
	{2, 4},
	{3, 3},
	{1, 5},
	{3, 3},
	{4, 2},
	{2, 4},
	{3, 3},
	{5, 1},
	{3, 3},
	{4, 2},
	{5, 1}
};


#define IRREGULAR_SEED_MAX 2048

/* Default descriptor including initial configuration parameters */
/* Mutable parameters are offset, in_size, out_size and irregular_seed */
/* { offset, pattern, in_size, access_factor, burst_len, compute_bound_factor,
   irregular_seed, reuse_factor, ld_st_ratio, stride_len, out_size, in_place } */
static const struct synth_cfg synth_cfg_init[2][NDEV] = {
	{{0, PATTERN_STREAMING, 0, 0,   64,  1, 0, 2,  1,    0, 0, 0},//synth.0
	 {0, PATTERN_STRIDED,   0, 0,    4,  1, 0, 4,  2,  256, 0, 0},//synth.1
	 {0, PATTERN_STREAMING, 0, 0,   32,  2, 0, 1,  4,    0, 0, 1},//synth.2
	 {0, PATTERN_IRREGULAR, 0, 0,    4,  2, 0, 1,  1,    0, 0, 1},//synth.3
	 {0, PATTERN_STREAMING, 0, 0,  128,  4, 0, 4,  2,    0, 0, 0},//synth.4
	 {0, PATTERN_STRIDED,   0, 0,    8,  2, 0, 1,  4,   32, 0, 1},//synth.5
	 {0, PATTERN_STREAMING, 0, 0,   64,  8, 0, 1,  1,    0, 0, 0},//synth.6
	 {0, PATTERN_IRREGULAR, 0, 2,    4,  2, 0, 4,  2,    0, 0, 0},//synth.7
	 {0, PATTERN_STREAMING, 0, 0,   16, 16, 0, 1,  4,    0, 0, 1},//synth.8
	 {0, PATTERN_STRIDED,   0, 0,    4,  1, 0, 2,  1,  512, 0, 0},//synth.9
	 {0, PATTERN_STREAMING, 0, 0,   32, 32, 0, 4,  2,    0, 0, 0},//synth.10
	 {0, PATTERN_IRREGULAR, 0, 4,    4,  1, 0, 1,  1,    0, 0, 1}},//synth.11

	{{0, PATTERN_STREAMING, 0, 0,   64,  1, 0, 2,  1,    0, 0, 0},//synth.0
	 {0, PATTERN_STRIDED,   0, 0,    4,  1, 0, 4,  1,  256, 0, 0},//synth.1
	 {0, PATTERN_STREAMING, 0, 0,   32,  2, 0, 1,  1,    0, 0, 1},//synth.2
	 {0, PATTERN_IRREGULAR, 0, 0,    4,  2, 0, 1,  1,    0, 0, 1},//synth.3
	 {0, PATTERN_STREAMING, 0, 0,  128,  4, 0, 4,  1,    0, 0, 0},//synth.4
	 {0, PATTERN_STRIDED,   0, 0,    8,  2, 0, 1,  1,   32, 0, 1},//synth.5
	 {0, PATTERN_STREAMING, 0, 0,   64,  8, 0, 1,  1,    0, 0, 0},//synth.6
	 {0, PATTERN_IRREGULAR, 0, 0,    4,  2, 0, 4,  1,    0, 0, 0},//synth.7
	 {0, PATTERN_STREAMING, 0, 0,   16, 16, 0, 1,  1,    0, 0, 1},//synth.8
	 {0, PATTERN_STRIDED,   0, 0,    4,  1, 0, 2,  1,  512, 0, 0},//synth.9
	 {0, PATTERN_STREAMING, 0, 0,   32, 32, 0, 4,  1,    0, 0, 0},//synth.10
	 {0, PATTERN_IRREGULAR, 0, 0,    4,  1, 0, 1,  1,    0, 0, 1}}};//synth.11

/* Accelerators chains per phase */
/*   accelerator in one chain execute in sequence */
/*   accelerators in different chains execute in parallel */
/*   parallel chains should not invoke the same accelerator */
typedef struct accelerators_chain {
	int devid;
	int fd;
	struct synth_access desc;
} chain_t;

/* Thread data structure */
typedef struct accelerator_thread_info {
        int tid;                                        /* Thread ID */
        int ndev;                                       /* number of accelerators in the chain */
        chain_t *chain;                                 /* chain of accelerators */
        contig_handle_t mem;                            /* Memory reserved for the accelerators in this chain */
	size_t memsz;                                   /* Memory size */
        enum accelerator_coherence coherence_hint;      /* Initial guess on best coherence option */
        struct timespec th_start;
        struct timespec th_end;
} accelerator_thread_info_t;



/* Thread functions */
static void config_thread(accelerator_thread_info_t *info, unsigned int *in_size,
			  unsigned int *out_size, int cfgid)
{
	int acc;
	size_t memsz = in_size[0];
	unsigned int offset = 0;

	for (acc = 0; acc < info->ndev; acc++) {
		int devid = info->chain[acc].devid;

		info->chain[acc].desc.cfg = synth_cfg_init[cfgid][devid];

		if (synth_cfg_init[cfgid][devid].pattern == PATTERN_IRREGULAR)
			info->chain[acc].desc.cfg.irregular_seed = rand() % IRREGULAR_SEED_MAX;

		info->chain[acc].desc.cfg.in_size = in_size[acc];
		info->chain[acc].desc.cfg.out_size = out_size[acc];

		info->chain[acc].desc.cfg.offset = offset;

		if (synth_cfg_init[cfgid][devid].in_place == 0) {
			memsz += out_size[acc];
			offset += in_size[acc];
		}

		unsigned int footprint = in_size[acc] >>
		    info->chain[acc].desc.cfg.access_factor;

		if (!(info->chain[acc].desc.cfg.in_place))
		    footprint += out_size[acc];

		info->chain[acc].desc.esp.footprint = footprint;

		info->chain[acc].desc.esp.in_place = synth_cfg_init[cfgid][devid].in_place;
		info->chain[acc].desc.esp.reuse_factor = synth_cfg_init[cfgid][devid].reuse_factor;
	}

	info->memsz = memsz * 4;
}

static void alloc_phase(accelerator_thread_info_t **info, int nthreads,
			enum accelerator_coherence coherence, enum alloc_effort alloc)
{
	int i, j;
	int largest_thread = 0;
	int largest_thread_preferred = 0;
	size_t largest_sz = 0;
	int ddr_node_cost[NDDR];
	int preferred_node_cost;

	// Compute largest thread
	for (i = 0; i < nthreads; i++)
		if (info[i]->memsz > largest_sz) {
			largest_sz = info[i]->memsz;
			largest_thread = i;
		}

	// Compute largest thread's preferred ddr node
	for (j = 0; j < NDDR; j++)
		ddr_node_cost[j] = 0;

	for (i = 0; i < info[largest_thread]->ndev; i++)
		for (j = 0; j < NDDR; j++)
			ddr_node_cost[j] += ddr_hops[info[largest_thread]->chain[i].devid][j];

	preferred_node_cost = ddr_node_cost[0];
	for (j = 1; j < NDDR; j++)
		if (ddr_node_cost[j] < preferred_node_cost) {
			preferred_node_cost = ddr_node_cost[j];
			largest_thread_preferred = j;
		}


	for (i = 0; i < nthreads; i++) {
		// Compute memory size
		int acc;
		struct contig_alloc_params params;

		if (alloc == ALLOC_NONE) {
			params.policy = CONTIG_ALLOC_PREFERRED;
			params.pol.first.ddr_node = 0;
		} else if (nthreads < 3) {
			params.policy = CONTIG_ALLOC_BALANCED;
			// TODO: tune params based on page size and profiling
			params.pol.balanced.threshold = 4;
			params.pol.balanced.cluster_size = 1;
		} else if (i == largest_thread) {
			params.policy = CONTIG_ALLOC_PREFERRED;
			params.pol.first.ddr_node = largest_thread_preferred;
		} else {
			params.policy = CONTIG_ALLOC_LEAST_LOADED;
			params.pol.lloaded.threshold = 4;
		}

		if (contig_alloc_policy(params, info[i]->memsz, &info[i]->mem) == NULL)
			die_errno("error: cannot allocate %zu contig bytes", info[i]->memsz);

		for (acc = 0; acc < info[i]->ndev; acc++) {

                        info[i]->chain[acc].desc.esp.run       = true;
                        info[i]->chain[acc].desc.esp.coherence = coherence; // TODO: better hint?
                        info[i]->chain[acc].desc.esp.contig    = contig_to_khandle(info[i]->mem);

			info[i]->chain[acc].desc.esp.alloc_policy = params.policy;
			info[i]->chain[acc].desc.esp.ddr_node = contig_to_most_allocated(info[i]->mem);
			info[i]->chain[acc].desc.esp.p2p_store = 0;
			info[i]->chain[acc].desc.esp.p2p_nsrcs = 0;
		}
	}
}

static void free_phase(accelerator_thread_info_t **info, int nthreads)
{
	int i;
	for (i = 0; i < nthreads; i++)
		contig_free(info[i]->mem);
}


static void prepare_thread(accelerator_thread_info_t *info)
{
	int acc;

	for (acc = 0; acc < info->ndev; acc ++) {
		int devid = info->chain[acc].devid;

		// Open
		info->chain[acc].fd = open(devname[devid], O_RDWR, 0);
		if(info->chain[acc].fd < 0)
			die_errno("error: cannot allocate open %s", devname[devid]);

	}
}

void *accelerator_thread( void *ptr )
{
	accelerator_thread_info_t *info = (accelerator_thread_info_t *) ptr;
	int acc;

	gettime(&info->th_start);

	for (acc = 0; acc < info->ndev; acc++) {

		/* printf("acc thread tid %d ioctl acc %d\n", info->tid, acc); */
		
		if (ioctl(info->chain[acc].fd, SYNTH_IOC_ACCESS, info->chain[acc].desc))
			die_errno("ioctl: cannot run accelerator %d", acc);

		/* printf("acc thread tid %d ioctl done acc %d\n", info->tid, acc); */
	}

	gettime(&info->th_end);

	return NULL;
}



int main(int argc, char **argv)
{
	int loop;
	struct timespec th_start;
	struct timespec th_end;
	unsigned long long hw_ns = 0, hw_ns_total = 0;
	float hw_s = 0, hw_s_total = 0;

	int phase;
	int thread;
	int acc;
	int p, t, i, j;
	int nphases;

	int nthreads[NPHASES_MAX];

	unsigned int ndev[NPHASES_MAX][NTHREADS_MAX];

	int devid[NPHASES_MAX][NTHREADS_MAX][NDEV];
	unsigned int in_size[NPHASES_MAX][NTHREADS_MAX][NDEV];
	unsigned int out_size[NPHASES_MAX][NTHREADS_MAX][NDEV];

	accelerator_thread_info_t *phases[NPHASES_MAX][NTHREADS_MAX];

	pthread_t threads[NTHREADS_MAX];

	enum accelerator_coherence coherence;
	enum alloc_effort alloc;

	int nthreads_s, nthreads_m, nthreads_l;

	// accelerators configuration
	int cfgid[NPHASES_MAX] = {0, 1, 1, 0, 1, 1, 0, 1, 1};
	//int cfgid[NPHASES_MAX] = {0, 0, 0, 0, 0, 0, 0, 0, 0};

	int nloop[NPHASES_MAX] = {1, 1, 1, 1, 1, 1, 1, 1, 1};

	srand(time(NULL));

	coherence = ACC_COH_NONE;
	if (argc >= 2) {
		if (!strcmp(argv[1], "llc"))
			coherence = ACC_COH_LLC;
		else if (!strcmp(argv[1], "full"))
			coherence = ACC_COH_FULL;
		else if (!strcmp(argv[1], "auto"))
			coherence = ACC_COH_AUTO;
	}

	alloc = ALLOC_NONE;
	if (argc == 3)
		if (!strcmp(argv[1], "auto"))
			alloc = ALLOC_AUTO;

	/* Commented out are the phases of the toy app */

	/* /\* Phase 0 *\/ */
	/* nthreads[0] = 1; */

	/* ndev[0][0] = 3; */

	/* devid[0][0][0] = 0; */
	/* devid[0][0][1] = 3; */
	/* devid[0][0][2] = 8; */

	/* in_size[0][0][0] = 1048576; // 1MB */

	/* /\* Phase 1 *\/ */
	/* nthreads[1] = 3; */

	/* ndev[1][0] = 3; */
	/* ndev[1][1] = 3; */
	/* ndev[1][2] = 2; */

	/* devid[1][0][0] = 4; */
	/* devid[1][0][1] = 2; */
	/* devid[1][0][2] = 7; */

	/* devid[1][1][0] = 10; */
	/* devid[1][1][1] = 9; */
	/* devid[1][1][2] = 8; */

	/* devid[1][2][0] = 11; */
	/* devid[1][2][1] = 1; */

	/* in_size[1][0][0] = 4194304;  // 4M; */
	/* in_size[1][1][0] = 4194304;  // 4M; */
	/* in_size[1][2][0] = 4194304;  // 4M; */

	/* Define Phases */
	/*   Phase 0: serial - mixed footprints */
	/*   Phase 1: serial - small footprints */
	/*   Phase 2: serial - large footprints */
	/*   Phase 3: parallel - mixed footprints */
	/*   Phase 4: parallel - small footprints */
	/*   Phase 5: parallel - large footprints */
	/*   Phase 6: highly parallel - mixed footprints */
	/*   Phase 7: highly parallel - small footprints */
	/*   Phase 8: highly parallel - large footprints */
	nphases = 9;
	
	// number of threads per phase
	nthreads_s = 1;
	nthreads_m = 6;
	nthreads_l = 12;
	nthreads[0] = 1;
	nthreads[1] = 1;
	nthreads[2] = 1;
	nthreads[3] = 6;
	nthreads[4] = 6;
	nthreads[5] = 6;
	nthreads[6] = 12;
	nthreads[7] = 12;
	nthreads[8] = 12;

	// number of accelerators per thread
	for (i = 0; i < nthreads_s; i++) {
		ndev[0][i] = 4;
		ndev[1][i] = 4;
		ndev[2][i] = 4;
	}

	for (i = 0; i < nthreads_m; i++) {
		ndev[3][i] = 4;
		ndev[4][i] = 4;
		ndev[5][i] = 4;
	}

	for (i = 0; i < nthreads_l; i++) {
		ndev[6][i] = 4;
		ndev[7][i] = 4;
		ndev[8][i] = 4;
	}

	// accelerators IDs executed in a thread
	for (i = 0; i < 3; i++) {
		devid[i][0][0] = 6;
		devid[i][0][1] = 10;
		devid[i][0][2] = 1;
		devid[i][0][3] = 11;
	}

	for (i = 3; i < 6; i++) {
		for (j = 0; j < 2; j++) {
			devid[i][0][j*2]   =  0;
			devid[i][0][j*2+1] =  1;
		} 

		for (j = 0; j < 2; j++) {
			devid[i][1][j*2]   =  2;
			devid[i][1][j*2+1] =  3;
		} 

		for (j = 0; j < 2; j++) {
			devid[i][2][j*2]   =  4;
			devid[i][2][j*2+1] =  5;
		} 

		for (j = 0; j < 2; j++) {
			devid[i][3][j*2]   =  6;
			devid[i][3][j*2+1] =  7;
		} 

		for (j = 0; j < 2; j++) {
			devid[i][4][j*2]   =  8;
			devid[i][4][j*2+1] = 10;
		} 

		for (j = 0; j < 2; j++) {
			devid[i][5][j*2]   =  9;
			devid[i][5][j*2+1] = 11;
		} 
	}

	for (i = 6; i < 9; i++) {
		for (j = 0; j < 4; j++)
			devid[i][0][j] =  0;

		for (j = 0; j < 4; j++)
			devid[i][1][j] =  1;

		for (j = 0; j < 4; j++)
			devid[i][2][j] =  2;

		for (j = 0; j < 4; j++)
			devid[i][3][j] =  3;

		for (j = 0; j < 4; j++)
			devid[i][4][j] =  4;

		for (j = 0; j < 4; j++)
			devid[i][5][j] =  5;

		for (j = 0; j < 4; j++)
			devid[i][6][j] =  6;

		for (j = 0; j < 4; j++)
			devid[i][7][j] =  7;

		for (j = 0; j < 4; j++)
			devid[i][8][j] =  8;

		for (j = 0; j < 4; j++)
			devid[i][9][j] =  9;

		for (j = 0; j < 4; j++)
			devid[i][10][j] = 10;

		for (j = 0; j < 4; j++)
			devid[i][11][j] = 11;
	}

	// input size of first accelerator of thread

	in_size[0][0][0] = K256;

	in_size[1][0][0] = M4;

	in_size[2][0][0] = K16;

	in_size[3][0][0] = K256;
	in_size[3][1][0] = K32;
	in_size[3][2][0] = K512;
	in_size[3][3][0] = K128;
	in_size[3][4][0] = K64;
	in_size[3][5][0] = K8;

	in_size[4][0][0] = M1;
	in_size[4][1][0] = M1;
	in_size[4][2][0] = M1;
	in_size[4][3][0] = M1;
	in_size[4][4][0] = M1;
	in_size[4][5][0] = M1;

	in_size[5][0][0] = K1;
	in_size[5][1][0] = K4;
	in_size[5][2][0] = K16;
	in_size[5][3][0] = K2;
	in_size[5][4][0] = K8;
	in_size[5][5][0] = K4;

	in_size[6][ 0][0] = K128;
	in_size[6][ 1][0] = K64;
	in_size[6][ 2][0] = K32;
	in_size[6][ 3][0] = K16;
	in_size[6][ 4][0] = K512;
	in_size[6][ 5][0] = K256;
	in_size[6][ 6][0] = K16;
	in_size[6][ 7][0] = K512;
	in_size[6][ 8][0] = K16;
	in_size[6][ 9][0] = K8;
	in_size[6][10][0] = K128;
	in_size[6][11][0] = K256;

	in_size[7][ 0][0] = M1;
	in_size[7][ 1][0] = M1;
	in_size[7][ 2][0] = M1;
	in_size[7][ 3][0] = M1;
	in_size[7][ 4][0] = M1;
	in_size[7][ 5][0] = M1;
	in_size[7][ 6][0] = M1;
	in_size[7][ 7][0] = M1;
	in_size[7][ 8][0] = M1;
	in_size[7][ 9][0] = M1;
	in_size[7][10][0] = M1;
	in_size[7][11][0] = M1;

	in_size[8][ 0][0] = K1;
	in_size[8][ 1][0] = K2;
	in_size[8][ 2][0] = K4;
	in_size[8][ 3][0] = K8;
	in_size[8][ 4][0] = K16;
	in_size[8][ 5][0] = K1;
	in_size[8][ 6][0] = K2;
	in_size[8][ 7][0] = K4;
	in_size[8][ 8][0] = K8;
	in_size[8][ 9][0] = K16;
	in_size[8][10][0] = K1;
	in_size[8][11][0] = K2;

	/* /\* Print config *\/ */
	/* for (i = 0; i < 2; i++) { */
	/* 	for (j = 0; j < NDEV; j++) { */
	/* 		printf("config %d %d %u\n", i, j, synth_cfg_init[i][j].ld_st_ratio); */
	/* 	} */

	/* } */

	/* Evaluate in_size and out_size for all accelerator invocation*/

	for (p = 0; p < nphases; p++) {

		for (t = 0; t < nthreads[p]; t++) {

			for (i = 0; i < ndev[p][t]; i++) {

				if (i != 0)
					in_size[p][t][i] = out_size[p][t][i-1];
			
				out_size[p][t][i] =
					(in_size[p][t][i] >>
					 synth_cfg_init[cfgid[p]][devid[p][t][i]].access_factor) /
					synth_cfg_init[cfgid[p]][devid[p][t][i]].ld_st_ratio;
			}
		}
	}

	/* printf("\nDATASET SIZES\n\n"); */

	/* for (p = 0; p < nphases; p++) { */

	/* 	printf("\tPHASE %d\n", p); */

	/* 	for (t = 0; t < nthreads[p]; t++) { */

	/* 		printf("\t\tTHREAD %d\n", t); */

	/* 		for (i = 0; i < ndev[p][t]; i++) { */

	/* 			printf("\t\t\tACC %d DEV %d\n", devid[p][t][i], i); */
	/* 			printf("\t\t\t\tin_size = %u\n", in_size[p][t][i]); */
	/* 			printf("\t\t\t\tout_size = %u\n", out_size[p][t][i]); */
	/* 		} */
	/* 	} */
	/* } */

	// give time to the prints to take place
	sleep(2);

	for (phase = 0; phase < nphases; phase++) {

		for (thread = 0; thread < nthreads[phase]; thread++) {

			phases[phase][thread] = malloc(sizeof(accelerator_thread_info_t));

			phases[phase][thread]->tid = thread;
			phases[phase][thread]->ndev = ndev[phase][thread];
			phases[phase][thread]->chain = malloc(sizeof(chain_t) * ndev[phase][thread]);

			// Define chains of accelerators with IDs
			for (acc = 0; acc < ndev[phase][thread]; acc++)
				phases[phase][thread]->chain[acc].devid = devid[phase][thread][acc];

			// Configure in/out_size and compute memsz
			config_thread(phases[phase][thread], in_size[phase][thread],
				      out_size[phase][thread], cfgid[phase]);
		}

		// Allocate memory
		alloc_phase(phases[phase], nthreads[phase], coherence, alloc);

		for (thread = 0; thread < nthreads[phase]; thread++)
			prepare_thread(phases[phase][thread]);

		// Global time
		gettime(&th_start);

		for (loop = 0; loop < nloop[phase]; loop++) {

			for (thread = 0; thread < nthreads[phase]; thread++)  {
				if (pthread_create( &threads[thread], NULL, accelerator_thread,
						    (void*) phases[phase][thread]))
					die_errno("pthread: cannot create thread %d", thread);
				/* printf("thread created thread %d\n", thread); */
			}

			for (thread = 0; thread < nthreads[phase]; thread++) {
				if(pthread_join(threads[thread], NULL))
					die_errno("pthread: cannot join thread %d", thread);
				/* printf("thread joined thread %d\n", thread); */
			}
		}

		gettime(&th_end);

		hw_ns = ts_subtract(&th_start, &th_end);
		hw_ns_total += hw_ns;
		hw_s = (float) hw_ns / 1000000000;

		sleep(1);
		printf("PHASE.%d %.4f s\n", phase, hw_s);
		sleep(1);

		// Free memory before starting next phase
		free_phase(phases[phase], nthreads[phase]);

	}
	hw_s_total = (float) hw_ns_total / 1000000000;
	printf("TOTAL %.4f s\n", hw_s_total);

	// TODO: Free data structures..
	return 0;
}
