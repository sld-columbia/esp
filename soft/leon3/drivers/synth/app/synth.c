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

#define NLOOP 1
#define NPHASES_MAX 8
#define NTHREADS_MAX 12

#define NDEV 12
#define NDDR 2


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
static const yx_t coordinates[NDEV] = {
	/* {0, 0}, mem.0 */
	{0, 1}, /* synth.0 */
	{0, 2}, /* synth.1 */
	{0, 3}, /* synth.2 */
	{1, 0}, /* synth.3 */
	/* {1, 1}, cpu 0 */
	{1, 2}, /* synth.4 */
	{1, 3}, /* synth.5 */
	{2, 0}, /* synth.6 */
	{2, 1}, /* synth.7 */
	/* {2, 2}, cpu.1 */
	{2, 3}, /* synth.8 */
	{3, 0}, /* synth.9 */
	{3, 1}, /* synth.10 */
	{3, 2}, /* synth.11 */
	/* {3, 3} mem 1 */
};


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
static const struct synth_cfg synth_cfg_init[NDEV] = {
     /* { offset, pattern          , in_size, access_factor, burst_len, compute_bound_factor, irregular_seed, reuse_factor, ld_st_ratio, stride_len, out_size, in_place } */
	{ 0     , PATTERN_STREAMING, 0      , 0            , 8192     , 1                   , 0             , 1           , 2          , 0         , 0       , 1        }, // synth.0
	{ 0     , PATTERN_STREAMING, 0      , 0            , 4096     , 8                   , 0             , 2           , 32         , 0         , 0       , 0        }, // synth.1
	{ 0     , PATTERN_STREAMING, 0      , 0            , 2048     , 4                   , 0             , 4           , 16         , 0         , 0       , 0        }, // synth.2
	{ 0     , PATTERN_STREAMING, 0      , 0            , 1024     , 2                   , 0             , 1           , 1          , 0         , 0       , 0        }, // synth.3
	{ 0     , PATTERN_STREAMING, 0      , 0            , 512      , 1                   , 0             , 2           , 8          , 0         , 0       , 1        }, // synth.4
	{ 0     , PATTERN_STREAMING, 0      , 0            , 256      , 1                   , 0             , 4           , 4          , 0         , 0       , 0        }, // synth.5
	{ 0     , PATTERN_STRIDED  , 0      , 0            , 4        , 1                   , 0             , 1           , 2048       , 2048      , 0       , 0        }, // synth.6
	{ 0     , PATTERN_STRIDED  , 0      , 0            , 4        , 1                   , 0             , 2           , 1024       , 1024      , 0       , 0        }, // synth.7
	{ 0     , PATTERN_STRIDED  , 0      , 0            , 1        , 1                   , 0             , 4           , 512        , 512       , 0       , 0        }, // synth.8
	{ 0     , PATTERN_IRREGULAR, 0      , 0            , 4        , 1                   , 0             , 1           , 32         , 0         , 0       , 0        }, // synth.9
	{ 0     , PATTERN_IRREGULAR, 0      , 2            , 1        , 1                   , 0             , 2           , 4          , 0         , 0       , 0        }, // synth.10
	{ 0     , PATTERN_IRREGULAR, 0      , 4            , 1        , 1                   , 0             , 4           , 1          , 0         , 0       , 0        }, // synth.11
};

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
static void config_thread(accelerator_thread_info_t *info,
			unsigned int *in_size,
			unsigned int *out_size)
{
	int acc;
	size_t memsz = in_size[0];
	unsigned int offset = 0;

	for (acc = 0; acc < info->ndev; acc++) {
		int devid = info->chain[acc].devid;

		info->chain[acc].desc.cfg = synth_cfg_init[devid];

		if (synth_cfg_init[devid].pattern == PATTERN_IRREGULAR)
			info->chain[acc].desc.cfg.irregular_seed = rand() % IRREGULAR_SEED_MAX;

		info->chain[acc].desc.cfg.in_size = in_size[acc];
		info->chain[acc].desc.cfg.out_size = out_size[acc];

		info->chain[acc].desc.cfg.offset = offset;

		if (synth_cfg_init[devid].in_place == 0) {
			memsz += out_size[acc];
			offset += in_size[acc];
		}

		unsigned int footprint = in_size[acc] >>
		    info->chain[acc].desc.cfg.access_factor;

		if (!(info->chain[acc].desc.cfg.in_place))
		    footprint += out_size[acc];

		info->chain[acc].desc.esp.footprint = footprint;
	}

	info->memsz = memsz;
}

static void alloc_phase(accelerator_thread_info_t **info, int nthreads,
			enum accelerator_coherence coherence)
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

		if (nthreads < 3) {
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

		if (contig_alloc_policy(params, info[i]->memsz, &info[i]->mem))
			die_errno("error: cannot allocate %zu contig bytes", info[i]->memsz);

		for (acc = 0; acc < info[i]->ndev; acc++) {

                        info[i]->chain[acc].desc.esp.run       = true;
                        info[i]->chain[acc].desc.esp.coherence = coherence; // TODO: better hint?
                        info[i]->chain[acc].desc.esp.contig    = contig_to_khandle(info[i]->mem);

			info[i]->chain[acc].desc.esp.alloc_policy = params.policy;
			info[i]->chain[acc].desc.esp.ddr_node = contig_to_most_allocated(info[i]->mem);
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

		if (ioctl(info->chain[acc].fd, SYNTH_IOC_ACCESS, info->chain[acc].desc))
			die_errno("ioctl: cannot run accelerator %d", acc);

	}

	gettime(&info->th_end);

	return NULL;
}



int main(int argc, char **argv)
{
	int loop;
	struct timespec th_start;
	struct timespec th_end;
	unsigned long long hw_ns = 0;

	int phase;
	int thread;
	int acc;

	int nphases;

	int nthreads[NPHASES_MAX];

	unsigned int ndev[NPHASES_MAX][NTHREADS_MAX];

	int devid[NPHASES_MAX][NTHREADS_MAX][NDEV];
	unsigned int in_size[NPHASES_MAX][NTHREADS_MAX][NDEV];
	unsigned int out_size[NPHASES_MAX][NTHREADS_MAX][NDEV];

	accelerator_thread_info_t *phases[NPHASES_MAX][NTHREADS_MAX];

	pthread_t threads[NTHREADS_MAX];

	enum accelerator_coherence coherence;

	srand(time(NULL));

	if (argc == 2) {
		if (!strcmp(argv[1], "llc"))
			coherence = ACC_COH_LLC;
		else if (!strcmp(argv[1], "full"))
			coherence = ACC_COH_FULL;
		else if (!strcmp(argv[1], "auto"))
			coherence = ACC_COH_AUTO;
		else // if (!strcmp(argv[1], "none"))
			coherence = ACC_COH_NONE;

	} else {
		coherence = ACC_COH_NONE;
	}

	/* Define Phases */
	nphases = 2;

	/* Phase 0 */
	nthreads[0] = 1;

	ndev[0][0] = 3;

	devid[0][0][0] = 1;
	devid[0][0][1] = 4;
	devid[0][0][2] = 9;

	in_size[0][0][0] = 1048576; // 1M;
	in_size[0][0][1] = 524288;  // 512K;
	in_size[0][0][2] = 524288;  // 512K;

	out_size[0][0][0] = 524288;  // 512K;
	out_size[0][0][1] = 524288;  // 512K;
	out_size[0][0][2] = 1024;    // 1K;

	/* Phase 1 */
	nthreads[1] = 3;

	ndev[1][0] = 4;
	ndev[1][1] = 3;
	ndev[1][2] = 2;

	devid[1][0][0] = 6;
	devid[1][0][1] = 5;
	devid[1][0][2] = 3;
	devid[1][0][3] = 8;

	devid[1][1][0] = 11;
	devid[1][1][1] = 10;
	devid[1][1][2] = 9;

	devid[1][2][0] = 12;
	devid[1][2][1] = 2;

	in_size[1][0][0] = 67108864; // 64M;
	in_size[1][0][1] = 4194304;  // 4M;
	in_size[1][0][2] = 524288;   // 512K;
	in_size[1][0][3] = 32768;    // 32K

	in_size[1][1][0] = 16777216; // 16M
	in_size[1][1][1] = 4194304;  // 4M;
	in_size[1][1][2] = 131072;   // 128K

	in_size[1][2][0] = 4194304;  // 4M;
	in_size[1][2][1] = 4194304;  // 4M;

	out_size[1][0][0] = 4194304;  // 4M;
	out_size[1][0][1] = 524288;   // 512K;
	out_size[1][0][2] = 32768;    // 32K;
	out_size[1][0][3] = 32;

	out_size[1][1][0] = 4194304;  // 4M;
	out_size[1][1][1] = 131072;   // 128K;
	out_size[1][1][2] = 256;

	out_size[1][2][0] = 4194304;  // 4M;
	out_size[1][2][1] = 131072;   // 128K;


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
			config_thread(phases[phase][thread], in_size[phase][thread], out_size[phase][thread]);
		}

		// Allocate memory
		alloc_phase(phases[phase], nthreads[phase], coherence);

		for (thread = 0; thread < nthreads[phase]; thread++)
			prepare_thread(phases[phase][thread]);


		// Global time
		gettime(&th_start);

		for (loop = 0; loop < NLOOP; loop++) {
			for (thread = 0; thread < nthreads[phase]; thread++)
				if (pthread_create( &threads[thread], NULL, accelerator_thread, (void*) phases[phase][thread]))
					die_errno("pthread: cannot create thread %d", thread);

			for (thread = 0; thread < nthreads[phase]; thread++)
				if(pthread_join(threads[thread], NULL))
					die_errno("pthread: cannot join thread %d", thread);

		}

		gettime(&th_end);

		hw_ns = ts_subtract(&th_start, &th_end);
		printf("PHASE.%d %llu ns\n", phase, hw_ns);

		// Free memory before starting next phase
		free_phase(phases[phase], nthreads[phase]);

	}

	// TODO: Free data structures..
	return 0;
}
