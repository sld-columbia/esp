#ifndef MONITORS_H
#define MONITORS_H

#include <fcntl.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

#ifdef LINUX
#include <sys/mman.h>
#include <stdlib.h>
#endif

#include "soc_defs.h"

#define DVFS_OP_POINTS 4
#define NOC_PLANES 6
#define NOC_QUEUES 5
#define SOC_NTILES (SOC_ROWS * SOC_COLS)

#define ESP_MON_READ_DDR_ACCESSES 0
#define ESP_MON_READ_MEM_REQS 1
#define ESP_MON_READ_L2_STATS 2
#define ESP_MON_READ_LLC_STATS 3
#define ESP_MON_READ_ACC_STATS 4			 //requires acc_index
#define ESP_MON_READ_DVFS_OP 5				 //requires tile_index
#define ESP_MON_READ_NOC_INJECTS 6
#define ESP_MON_READ_NOC_QUEUE_FULL_TILE 7	 //requires tile_index
#define ESP_MON_READ_NOC_QUEUE_FULL_PLANE 8  //requires noc_index

#define MON_DDR_WORD_TRANSFER_INDEX		0
#define MON_MEM_COH_REQ_INDEX			1
#define MON_MEM_COH_FWD_INDEX			2
#define MON_MEM_COH_RSP_RCV_INDEX		3
#define MON_MEM_COH_RSP_SND_INDEX		4
#define MON_MEM_DMA_REQ_INDEX			5
#define MON_MEM_DMA_RSP_INDEX			6
#define MON_MEM_COH_DMA_REQ_INDEX		7
#define MON_MEM_COH_DMA_RSP_INDEX		8
#define MON_L2_HIT_INDEX				9
#define MON_L2_MISS_INDEX				10
#define MON_LLC_HIT_INDEX				11
#define MON_LLC_MISS_INDEX				12
#define MON_ACC_TLB_INDEX				13
#define MON_ACC_MEM_LO_INDEX			14
#define MON_ACC_MEM_HI_INDEX			15
#define MON_ACC_TOT_LO_INDEX			16
#define MON_ACC_TOT_HI_INDEX			17

#define MON_DVFS_BASE_INDEX				18
#define VF_OP_POINTS					4

#define NOCS_NUM						6
#define NOC_QUEUES						5
#define MON_NOC_TILE_INJECT_BASE_INDEX	(MON_DVFS_BASE_INDEX + VF_OP_POINTS) //22
#define MON_NOC_QUEUES_FULL_BASE_INDEX	(MON_NOC_TILE_INJECT_BASE_INDEX + NOCS_NUM) //28

typedef struct esp_mem_reqs {
	unsigned int coh_reqs;
	unsigned int coh_fwds;
	unsigned int coh_rsps_rcv;
	unsigned int coh_rsps_snd;
	unsigned int dma_reqs;
	unsigned int dma_rsps;
	unsigned int coh_dma_reqs;
	unsigned int coh_dma_rsps;
} esp_mem_reqs_t;

typedef struct esp_cache_stats {
	unsigned int hits;
	unsigned int misses;
} esp_cache_stats_t;

typedef struct acc_stats_t {
	unsigned int acc_tlb;
	unsigned int acc_mem_lo;
	unsigned int acc_mem_hi;
	unsigned int acc_tot_lo;
	unsigned int acc_tot_hi;
} esp_acc_stats_t;

typedef struct esp_monitor_vals {
	unsigned int ddr_accesses[SOC_NMEM];
	esp_mem_reqs_t mem_reqs[SOC_NMEM];
	esp_cache_stats_t l2_stats[SOC_NTILES];
	esp_cache_stats_t llc_stats[SOC_NMEM];
	esp_acc_stats_t acc_stats[SOC_NACC];
	unsigned int dvfs_op[SOC_NTILES][DVFS_OP_POINTS];
	unsigned int noc_injects[SOC_NTILES][NOC_PLANES];
	unsigned int noc_queue_full[SOC_NTILES][NOC_PLANES][NOC_QUEUES];
} esp_monitor_vals_t;

typedef enum esp_monitor_read_mode {
	ESP_MON_READ_ALL,
	ESP_MON_READ_SINGLE,
	ESP_MON_READ_MANY,
 } esp_monitor_mode_t;

typedef struct esp_monitor_args {
	esp_monitor_mode_t read_mode;
	uint16_t read_mask;
	uint8_t tile_index;
	uint8_t acc_index;
	uint8_t mon_index;
	uint8_t noc_index;
} esp_monitor_args_t;

typedef struct esp_mon_alloc_node {
	esp_monitor_vals_t *vals;
	struct esp_mon_alloc_node *next;
} esp_mon_alloc_node_t;

typedef struct soc_loc{
	uint8_t row;
	uint8_t col;
} soc_loc_t;

esp_monitor_vals_t esp_monitor_diff(esp_monitor_vals_t vals_start, esp_monitor_vals_t vals_end);
unsigned int esp_monitor(esp_monitor_args_t args, esp_monitor_vals_t *vals);
uint32_t sub_monitor_vals (uint32_t val_start, uint32_t val_end);

#ifdef LINUX
esp_monitor_vals_t* esp_monitor_vals_alloc();
void esp_monitor_free();
void esp_monitor_print(esp_monitor_args_t args, esp_monitor_vals_t vals, FILE *fp);
#define print_mon(...) fprintf(fp, __VA_ARGS__)
#else
void esp_monitor_print(esp_monitor_args_t args, esp_monitor_vals_t vals);
#define print_mon(...) printf(__VA_ARGS__)
#endif

#endif //MONITORS_H
