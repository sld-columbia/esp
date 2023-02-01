// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MMI64_MON_H__
#define __MMI64_MON_H__

extern "C" {
#include "profpga.h"
#include "mmi64.h"
#include "mmi64_module_regif.h"
#include "mmi64_module_devzero.h"
#include "profpga_error.h"
#include "profpga_acm.h"
}

#include "mmi64_regs.h"

#include <string>
#include <stdio.h>
#include <iostream>
#include <cmath>

int message_handler(const int messagetype, const char *fmt,...);

class mmi64_mon {
public:
	mmi64_mon()
	{
		current_time = 0;
		acc_relevant_sample = false;
		dvfs_relevant_sample = false;
		mh_status = profpga_set_message_handler(message_handler);
	}

	void probes_statistics_reset() {
		sample_start = current_time - 1;
		for (int k = 0; k < TILES_NUM; k++)
			/* for (int i = 0; i < VF_OP_POINTS; i++) { */
			/* 	probes_dvfs_max[k][i] = probes_dvfs[k][i]; */
			/* 	probes_dvfs_ave[k][i] = probes_dvfs[k][i]; */
			/* 	probes_dvfs_tot[k][i] = probes_dvfs[k][i]; */
			/* } */

		for (int j = 0; j < NOCS_NUM; j++)
			for (int k = 0; k < TILES_NUM; k++)
				for (int i = 0; i < DIRECTIONS; i++) {
				probes_queue_max[j][k][i] = probes_queue[j][k][i];
				probes_queue_ave[j][k][i] = probes_queue[j][k][i];
				probes_queue_tot[j][k][i] = probes_queue[j][k][i];
			}

		for (int k = 0; k < ACCS_NUM; k++)
			for (int i = 0; i < 3; i++) {
				probes_acc_max[k][i] = probes_acc[k][i];
				probes_acc_ave[k][i] = probes_acc[k][i];
				probes_acc_tot[k][i] = probes_acc[k][i];
			}
	}

	profpga_error_t open_system();
	profpga_error_t close_system();
	mmi64_error_t   get_user_module();
	mmi64_error_t   set_window(uint32_t window);
	mmi64_error_t   read_timestamp();
	bool relevant_sample()
	{
		return (acc_relevant_sample || dvfs_relevant_sample);
	}

#ifdef DVFS_offset
	mmi64_error_t   read_dvfs();
#endif
#ifdef ACC_offset
	mmi64_error_t   read_acc(int accelerator);
	mmi64_error_t   read_accs();
#endif
#ifdef NOC_QUEUES_offset
	mmi64_error_t   read_queues();
#endif

	long long unsigned current_time;
	uint32_t current_window;
	profpga_handle_t *profpga;
	mmi64_module_t * user_module;
	int mh_status;
	long long unsigned new_time;
	bool acc_relevant_sample;
	bool dvfs_relevant_sample;

	uint32_t probes_dvfs[TILES_NUM][VF_OP_POINTS];
	long long unsigned probes_acc[ACCS_NUM][3];
	uint32_t probes_queue[NOCS_NUM][TILES_NUM][DIRECTIONS];
#ifdef SIGNATURE_offset
	uint32_t probes_signature[SIGNATURE_LEN - 1];
#endif
	/* long long unsigned probes_dvfs_tot[TILES_NUM][VF_OP_POINTS]; */
	long long unsigned probes_acc_tot[ACCS_NUM][3];
	long long unsigned probes_queue_tot[NOCS_NUM][TILES_NUM][DIRECTIONS];

	/* uint32_t probes_dvfs_max[TILES_NUM][VF_OP_POINTS]; */
	long long unsigned probes_acc_max[ACCS_NUM][3];
	uint32_t probes_queue_max[NOCS_NUM][TILES_NUM][DIRECTIONS];

	/* uint32_t probes_dvfs_ave[TILES_NUM][VF_OP_POINTS]; */
	long long unsigned probes_acc_ave[ACCS_NUM][3];
	uint32_t probes_queue_ave[NOCS_NUM][TILES_NUM][DIRECTIONS];

	long long unsigned sample_start;
};

#endif /*  __MMI64_MON_H__ */
