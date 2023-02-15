/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <pthread.h>

#include <stdio.h>
#include <stdint.h>
#include "profpga.h"
#include "mmi64.h"
#include "mmi64_module_regif.h"
#include "mmi64_module_devzero.h"
#include "profpga_error.h"
#include "profpga_acm.h"
#include <stdarg.h>

#include "mmi64_regs.h"

#ifdef PRINT_COLORS
#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

#define SET_RED(_fp) fprintf(_fp, "%s", KRED)
#define SET_GRN(_fp) fprintf(_fp, "%s", KGRN)
#define SET_YEL(_fp) fprintf(_fp, "%s", KYEL)
#define SET_BLU(_fp) fprintf(_fp, "%s", KBLU)
#define SET_MAG(_fp) fprintf(_fp, "%s", KMAG)
#define SET_CYN(_fp) fprintf(_fp, "%s", KCYN)
#define SET_WHT(_fp) fprintf(_fp, "%s", KWHT)
#define SET_NRM(_fp) fprintf(_fp, "%s", KNRM)

#else

#define SET_RED(_fp)
#define SET_GRN(_fp)
#define SET_YEL(_fp)
#define SET_BLU(_fp)
#define SET_MAG(_fp)
#define SET_CYN(_fp)
#define SET_WHT(_fp)
#define SET_NRM(_fp)

#endif

#ifdef NOC_QUEUES_offset
static const char *direction[5] = {"n", "s", "w", "e", "l"};
#endif

#ifdef DVFS_offset
static const int tile_has_dvfs[TILES_NUM] = {0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0};
#endif

static relevant_window = 0;

long long unsigned current_time = 0;
FILE *fp;

void reset_all_counters(mmi64_module_t *user_module)
{
	int i;
	profpga_error_t status;
	int reset_regid = MONITOR_RESET_offset;
	for (i = 0; i < MONITOR_REG_COUNT; i++) {
		int ireg = i;
		status = mmi64_regif_write_32_ack(user_module, reset_regid, 1, &ireg);
	}
}

void read_counter(mmi64_module_t *user_module, int regid)
{
	if (regid >= TOTAL_REG_COUNT) {
		fprintf(stderr, "%s: invalid register id %d; range is [0-%d]\n", __func__, regid, TOTAL_REG_COUNT);
		exit(EXIT_FAILURE);
	}
	profpga_error_t status;
	unsigned rdata;
	status = mmi64_regif_read_32(user_module, regid, 1, &rdata);
	fprintf(fp, "r%d = %d\n", regid, rdata);
}

long long unsigned read_timestamp(mmi64_module_t *user_module)
{
	profpga_error_t status;
	int window_lo_regid = MONITOR_WINDOW_LO_offset;
	int window_hi_regid = MONITOR_WINDOW_HI_offset;
	long long unsigned time_stamp = 0;
	unsigned rdata;
	status = mmi64_regif_read_32(user_module, window_hi_regid, 1, &rdata);
	time_stamp = ((long long unsigned) rdata) << 32;
	status = mmi64_regif_read_32(user_module, window_lo_regid, 1, &rdata);
	time_stamp |= (long long unsigned) rdata;
	return time_stamp;
}

#ifdef NOC_QUEUES_offset
void read_noc_traffic(mmi64_module_t *user_module)
{
/*
  # NoC<noc_id>.queue_n_traffic_<tile_id>
  # NoC<noc_id>.queue_s_traffic_<tile_id>
  # NoC<noc_id>.queue_w_traffic_<tile_id>
  # NoC<noc_id>.queue_e_traffic_<tile_id>
  # NoC<noc_id>.queue_l_traffic_<tile_id>
*/
	profpga_error_t status;
	int noc, tile, dir;
	unsigned rdata[NOCS_NUM][TILES_NUM][5];
	int regid;

	for (noc = 0; noc < NOCS_NUM; noc++)
		for (tile = 0; tile < TILES_NUM; tile++)
			for (dir = 0; dir < 5; dir++) {
				regid = NOC_QUEUES_offset + noc * TILES_NUM * 5 + tile * 5 + dir;
				status = mmi64_regif_read_32(user_module, regid, 1, &rdata[noc][tile][dir]);
			}

	for (noc = 0; noc < NOCS_NUM; noc++)
		for (tile = 0; tile < TILES_NUM; tile++)
			for (dir = 0; dir < 5; dir++)
				fprintf(fp, "%d\t", rdata[noc][tile][dir]);

}
#endif

#ifdef ACC_offset
int read_accelerator_mon(mmi64_module_t *user_module, int accelerator)
{
	int relevant = 0;
	profpga_error_t status;
	int tlb_regid = ACC_offset + accelerator * 5;
	int mem_lo_regid = ACC_offset + accelerator * 5 + 1;
	int mem_hi_regid = ACC_offset + accelerator * 5 + 2;
	int tot_lo_regid = ACC_offset + accelerator * 5 + 3;
	int tot_hi_regid = ACC_offset + accelerator * 5 + 4;

	long long unsigned tlb = 0;
	long long unsigned mem = 0;
	long long unsigned tot = 0;
	unsigned rdata;
	status = mmi64_regif_read_32(user_module, tot_hi_regid, 1, &rdata);
	tot = ((long long unsigned) rdata) << 32;
	status = mmi64_regif_read_32(user_module, tot_lo_regid, 1, &rdata);
	tot |= (long long unsigned ) rdata;
	status = mmi64_regif_read_32(user_module, mem_hi_regid, 1, &rdata);
	mem = ((long long unsigned) rdata) << 32;
	status = mmi64_regif_read_32(user_module, mem_lo_regid, 1, &rdata);
	mem |= (long long unsigned ) rdata;
	status = mmi64_regif_read_32(user_module, tlb_regid, 1, &rdata);
	tlb = (long long unsigned) rdata;

	if (accelerator % 2)
		SET_CYN(fp);
	else
		SET_WHT(fp);
	fprintf(fp, "%d\t%d\t%d\t", tlb, mem, tot);
	if (tot != 0)
		relevant = 1;

	SET_NRM(fp);

	return relevant;
}

int read_accelerators_mon(mmi64_module_t *user_module)
{
	int i;
	int relevant = 0;
	for (i = 0; i < ACCS_NUM; i++)
		if (read_accelerator_mon(user_module, i))
			relevant = 1;
	return relevant;
}
#endif


#ifdef L2_offset
void read_l2_stats(mmi64_module_t *user_module, int cache_id)
{
	profpga_error_t status;
	int hit_regid = L2_offset + cache_id * 2;
	int miss_regid = L2_offset + cache_id * 2 + 1;

	long long unsigned hit = 0;
	long long unsigned miss = 0;
	unsigned rdata;

	status = mmi64_regif_read_32(user_module, hit_regid, 1, &rdata);
	hit = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, miss_regid, 1, &rdata);
	miss = (long long unsigned) rdata;

	if (cache_id % 2)
		SET_MAG(fp);
	else
		SET_BLU(fp);
	fprintf(fp, "%d\t%d\t", hit, miss);

	SET_NRM(fp);
}

void read_l2s_stats(mmi64_module_t *user_module)
{
	int i;
	for (i = 0; i < L2S_NUM; i++)
		read_l2_stats(user_module, i);
}
#endif

#ifdef LLC_offset
void read_llc_stats(mmi64_module_t *user_module, int cache_id)
{
	profpga_error_t status;
	int hit_regid = LLC_offset + cache_id * 2;
	int miss_regid = LLC_offset + cache_id * 2 + 1;

	long long unsigned hit = 0;
	long long unsigned miss = 0;
	unsigned rdata;

	status = mmi64_regif_read_32(user_module, hit_regid, 1, &rdata);
	hit = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, miss_regid, 1, &rdata);
	miss = (long long unsigned) rdata;

	fprintf(fp, "%d\t%d\t", hit, miss);
}

void read_llcs_stats(mmi64_module_t *user_module)
{
	int i;
	for (i = 0; i < LLCS_NUM; i++)
		read_llc_stats(user_module, i);
}
#endif


#ifdef DDR_offset
void read_ddr(mmi64_module_t *user_module)
{
	profpga_error_t status;
	int i;
	for (i = 0; i < DDRS_NUM; i++) {
		int ddr_regid = DDR_offset + i;
		unsigned ddr;
		status = mmi64_regif_read_32(user_module, ddr_regid, 1, &ddr);
		fprintf(fp, "%d\t", ddr);
	}
}
#endif

#ifdef MEM_offset
void read_mem_stats(mmi64_module_t *user_module, int mem_id)
{
	profpga_error_t status;

	int coh_req_regid = MEM_offset + mem_id * 8;
	int coh_fwd_regid = MEM_offset + mem_id * 8 + 1;
	int coh_rsp_rcv_regid = MEM_offset + mem_id * 8 + 2;
	int coh_rsp_snd_regid = MEM_offset + mem_id * 8 + 3;
	int dma_req_regid = MEM_offset + mem_id * 8 + 4;
	int dma_rsp_regid = MEM_offset + mem_id * 8 + 5;
	int coh_dma_req_regid = MEM_offset + mem_id * 8 + 6;
	int coh_dma_rsp_regid = MEM_offset + mem_id * 8 + 7;

	long long unsigned coh_req = 0;
	long long unsigned coh_fwd = 0;
	long long unsigned coh_rsp_rcv = 0;
	long long unsigned coh_rsp_snd = 0;
	long long unsigned dma_req = 0;
	long long unsigned dma_rsp = 0;
	long long unsigned coh_dma_req = 0;
	long long unsigned coh_dma_rsp = 0;

	unsigned rdata;

	status = mmi64_regif_read_32(user_module, coh_req_regid, 1, &rdata);
	coh_req = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, coh_fwd_regid, 1, &rdata);
	coh_fwd = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, coh_rsp_rcv_regid, 1, &rdata);
	coh_rsp_rcv = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, coh_rsp_snd_regid, 1, &rdata);
	coh_rsp_snd = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, dma_req_regid, 1, &rdata);
	dma_req = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, dma_rsp_regid, 1, &rdata);
	dma_rsp = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, coh_dma_req_regid, 1, &rdata);
	coh_dma_req = (long long unsigned) rdata;
	status = mmi64_regif_read_32(user_module, coh_dma_rsp_regid, 1, &rdata);
	coh_dma_rsp = (long long unsigned) rdata;

	SET_GRN(fp);
	fprintf(fp, "%d\t%d\t%d\t%d\t",
		coh_req, coh_fwd, coh_rsp_rcv, coh_rsp_snd);

	SET_RED(fp);
	fprintf(fp, "%d\t%d\t",
		dma_req, dma_rsp);

	SET_YEL(fp);
	fprintf(fp, "%d\t%d\t",
		coh_dma_req, coh_dma_rsp);

	SET_NRM(fp);
}

void read_mems_stats(mmi64_module_t *user_module)
{
	int i;
	for (i = 0; i < MEMS_NUM; i++)
		read_mem_stats(user_module, i);
}
#endif

#ifdef NOC_INJECT_offset
void read_injection_rate(mmi64_module_t *user_module)
{
	profpga_error_t status;
	int i, k;
	unsigned rdata[NOCS_NUM][TILES_NUM];
	for (k = 0; k < NOCS_NUM; k++) {
		for (i = 0; i < TILES_NUM; i++) {
			int injection_regid = NOC_INJECT_offset + (k * TILES_NUM) + i;
			status = mmi64_regif_read_32(user_module, injection_regid, 1, &rdata[k][i]);
		}
	}
	for (k = 0; k < NOCS_NUM; k++)
		for (i = 0; i < TILES_NUM; i++)
			fprintf(fp, "%d\t", rdata[k][i]);

}
#endif

#ifdef DVFS_offset
void read_dvfs(mmi64_module_t *user_module)
{
	profpga_error_t status;
	int i, k;
	unsigned rdata[TILES_NUM][VF_OP_POINTS];
	for (k = 0; k < TILES_NUM; k++) {
		for (i = 0; i < VF_OP_POINTS; i++) {
			int dvfs_regid = DVFS_offset + (k * VF_OP_POINTS) + i;
			status = mmi64_regif_read_32(user_module, dvfs_regid, 1, &rdata[k][i]);
		}
	}
	for (k = 0; k < TILES_NUM; k++)
		for (i = 0; i < VF_OP_POINTS; i++) {
			if (rdata[k][i] != 0 && tile_has_dvfs[k])
				relevant_window = 1;
			fprintf(fp, "%d\t", rdata[k][i]);
		}

}
#endif


void set_window(mmi64_module_t *user_module, int window)
{
	profpga_error_t status;
	int window_size_regid = MONITOR_WINDOW_SIZE_offset;
	status = mmi64_regif_write_32_ack(user_module, window_size_regid, 1, &window);
}

#define CHECK(status)  if (status!=E_PROFPGA_OK) {			\
		printf(NOW("ERROR: %s\n"), profpga_strerror(status));	\
		return status;  }


int message_handler(const int messagetype, const char *fmt,...)
{
	int n;
	va_list ap;
	va_start(ap, fmt);
	n = vfprintf(stdout, fmt, ap);
	va_end(ap);
	return n;
}

char * cfgfilename = "profpga.cfg";

void *wait_for_user_stop(void *stop)
{
	char val;
	int *local_stop = (int *) stop;
	printf("Press any key to stop Monitor...\n");
	scanf("%c", &val);
	*local_stop = 1;
	return NULL;
}

mmi64_error_t mmi64_main(int argc, char * argv[])
{
	profpga_handle_t * profpga;
	profpga_error_t status;
	uint32_t data[8];
	const mmi64_addr_t user_addr[] = {2, 1, 0};
	mmi64_module_t * user_module;

	int mh_status = profpga_set_message_handler(message_handler);
	int i, j, k;

	pid_t pid;
	pthread_t aux;
	int stop = 0;
	long long unsigned new_time;

	if (mh_status!=0) {
		printf("ERROR: Failed to install message handler (code %d)\n", mh_status);
		return mh_status;
	}

	// connect to system
	printf(NOW("Open connection to profpga platform...\n"));

	status = profpga_open (&profpga, cfgfilename);
	if (status!=E_PROFPGA_OK) { // cannot use NOW() macro because required MMI-64 domain handle has not been initialized
		printf("ERROR: Failed connect to PROFPGA system (%s)\n", profpga_strerror(status));
		return status;
	}

#ifdef HDL_SIM
	// for HDL simulation: perform configuration as done by profpga_run --up
	printf(NOW("Bring up system.\n"));
	status = profpga_up(profpga);
	CHECK(status);
#endif

	// scan for MMI-64 modules
	printf(NOW("Scan hardware...\n"));
	status = mmi64_identify_scan(profpga->mmi64_domain);
	CHECK(status);

	// print scan results
	status = mmi64_info_print(profpga->mmi64_domain);
	CHECK(status);

	// find user module
	status = mmi64_identify_by_address(profpga->mmi64_domain, user_addr, &user_module);
	CHECK(status);
	if (user_module==NULL) {
		printf("ERROR: Failed to identify user module. \n");
		return -1;
	}


	fp = fopen("mmi64.rpt", "w+");

	if (pthread_create(&aux, NULL, wait_for_user_stop, (void *) &stop)) {
		fprintf(stderr, "Error creating thread\n");
		exit(EXIT_FAILURE);
	}

	fprintf(fp, "win\t");

#ifdef DDR_offset
	fprintf(fp, "ddr0\tddr1\t");
#endif

#ifdef LLC_offset
	for (i = 0; i < LLCS_NUM; i++)
		fprintf(fp, "coh-req-%d\tcoh-fwd-%d\tcoh_rsp_rcv-%d\tcoh_rsp_snd-%d\tdma_req-%d\tdma_rsp-%d\tcoh_dma_req-%d\tcoh_dma_rsp-%d\t",
			i, i, i, i, i, i, i, i);
#endif

#ifdef NOC_INJECT_offset
	for (k = 0; k < NOCS_NUM; k++)
		for (i = 0; i < TILES_NUM; i++)
			fprintf(fp, "inj-%d-%d\t", k, i);
#endif

#ifdef NOC_QUEUES_offset
	for (k = 0; k < NOCS_NUM; k++)
		for (i = 0; i < TILES_NUM; i++)
			for (j = 0; j < 5; j++)
				fprintf(fp, "v-%d-%d-%s\t", k, i, direction[j]);
#endif

#ifdef ACC_offset
	for (i = 0; i < ACCS_NUM; i++)
		fprintf(fp, "tlb-%d\tmem-%d\ttot-%d\t", i, i, i);
#endif

#ifdef L2_offset
	for (i = 0; i < L2S_NUM; i++)
		fprintf(fp, "hit-%d\tmiss-%d\t", i, i);
#endif

#ifdef LLC_offset
	for (i = 0; i < LLCS_NUM; i++)
		fprintf(fp, "hit-%d\tmiss-%d\t", i, i);
#endif

#ifdef DVFS_offset
	for (k = 0; k < TILES_NUM; k++)
		for (i = 0; i < VF_OP_POINTS; i++)
			fprintf(fp, "vf-%d-%d\t", k, i);
#endif

	fprintf(fp, "\n");
	fflush(fp);

	set_window(user_module, (1<<21));

	int relevant;
	int count = 0;
	while(!stop) {
		/* if (count == 30) */
		/* 	goto close_fpga; */
		relevant = 0;
		new_time = read_timestamp(user_module);
		if (new_time != current_time) {
			current_time = new_time;
			fprintf(fp, "%d\t", new_time);
#ifdef DDR_offset
			read_ddr(user_module);
#endif
#ifdef MEM_offset
			read_mems_stats(user_module);
#endif
#ifdef NOC_INJECT_offset
			read_injection_rate(user_module);
#endif
#ifdef NOC_QUEUES_offset
			read_noc_traffic(user_module);
#endif
#ifdef ACC_offset
			relevant = read_accelerators_mon(user_module);
#endif
#ifdef L2_offset
			read_l2s_stats(user_module);
#endif
#ifdef LLC_offset
			read_llcs_stats(user_module);
#endif
#ifdef DVFS_offset
			read_dvfs(user_module);
#endif
			if (!relevant) {
				fprintf(fp, "\tN");
				count++;
			}
			else {
				fprintf(fp, "\tY");
				count = 0;
			}
			fprintf(fp, "\n");
			fflush(fp);
		}
	}

close_fpga:
	printf(NOW("Done. Closing connection...\n"));
	return profpga_close(&profpga);
}

#ifndef HDL_SIM
int main(int argc, char * argv[])
{
	if (argc!=2) {
		printf("Wrong arguments! Usage:\n    mmi64basic_test [CONFIGFILE.cfg]\n");
		return -1;
	}
	printf("Using configuration file %s\n", argv[1]);
	cfgfilename = argv[1];
	return  mmi64_main(argc, argv);
}
#endif
