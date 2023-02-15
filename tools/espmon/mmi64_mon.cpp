// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "mmi64_mon.h"
#include <iostream>
#include <cstdarg>
#include <string>


int message_handler(const int messagetype __attribute__((unused)), const char *fmt,...)
{
	int n;
	va_list ap;
	va_start(ap, fmt);
	n = vfprintf(stdout, fmt, ap);
	va_end(ap);
	return n;
}

profpga_error_t mmi64_mon::open_system()
{
	profpga_error_t status = profpga_open(&profpga, "mmi64.cfg");
	return status;
}

mmi64_error_t mmi64_mon::get_user_module()
{
	const mmi64_addr_t user_addr[] = {2, 1, 0};

	mmi64_error_t status = mmi64_identify_scan(profpga->mmi64_domain);
	if (status != E_MMI64_OK)
		return status;
	status = mmi64_info_print(profpga->mmi64_domain);
	if (status != E_MMI64_OK)
		return status;
	status = mmi64_identify_by_address(profpga->mmi64_domain, user_addr, &user_module);
	if (status != E_MMI64_OK)
		return status;
	if (user_module == NULL)
		return E_MMI64_IDENTIFY_FAILED;
	return status;
}

profpga_error_t mmi64_mon::close_system()
{
	profpga_error_t status = profpga_close(&profpga);
	return status;
}

mmi64_error_t mmi64_mon::set_window(uint32_t window)
{
	mmi64_error_t status;
	uint32_t regid = MONITOR_WINDOW_SIZE_offset;
	status = mmi64_regif_write_32_ack(user_module, regid, 1, &window);
	current_window = window;
	return status;
}

mmi64_error_t mmi64_mon::read_timestamp()
{
	mmi64_error_t status;
	int window_lo_regid = MONITOR_WINDOW_LO_offset;
	int window_hi_regid = MONITOR_WINDOW_HI_offset;
	long long unsigned time_stamp = 0;
	unsigned rdata;
	status = mmi64_regif_read_32(user_module, window_hi_regid, 1, &rdata);
	time_stamp = ((long long unsigned) rdata) << 32;
	status = mmi64_regif_read_32(user_module, window_lo_regid, 1, &rdata);
	time_stamp |= (long long unsigned) rdata;
	current_time = time_stamp;
	return status;
}


#ifdef DVFS_offset
mmi64_error_t mmi64_mon::read_dvfs()
{
	mmi64_error_t status;
	dvfs_relevant_sample = false;
	for (int k = 0; k < TILES_NUM; k++)
		for (int i = 0; i < VF_OP_POINTS; i++) {
			uint32_t regid = DVFS_offset + (k * VF_OP_POINTS) + i;
			status = mmi64_regif_read_32(user_module, regid, 1, &probes_dvfs[k][i]);
			if (status != E_MMI64_OK)
				return status;

			// probes_dvfs_tot[k][i] += probes_dvfs[k][i];
			// probes_dvfs_ave[k][i] = probes_dvfs_tot[k][i] / (current_time - sample_start);
			// if (probes_dvfs[k][i] > probes_dvfs_max[k][i])
			// 	probes_dvfs_max[k][i] = probes_dvfs[k][i];

			if (tiles[k].type == accelerator_tile && probes_dvfs[k][i])
				dvfs_relevant_sample = true;
		}
	return E_MMI64_OK;
}
#endif

#ifdef ACC_offset
mmi64_error_t mmi64_mon::read_acc(int accelerator)
{
	/*
	 * TLB = 0
	 * MEM_LO = 1
	 * MEM_HI = 2
	 * TOT_LO = 3
	 * TOT_HI = 4
	 */
	mmi64_error_t status;
	int tlb_regid    = ACC_offset + accelerator * 5 + 0;
	int mem_lo_regid = ACC_offset + accelerator * 5 + 1;
	int mem_hi_regid = ACC_offset + accelerator * 5 + 2;
	int tot_lo_regid = ACC_offset + accelerator * 5 + 3;
	int tot_hi_regid = ACC_offset + accelerator * 5 + 4;

	long long unsigned tlb = 0;
	long long unsigned mem = 0;
	long long unsigned tot = 0;
	unsigned rdata;
	status = mmi64_regif_read_32(user_module, tot_hi_regid, 1, &rdata);
	if (status != E_MMI64_OK)
		return status;
	tot = ((long long unsigned) rdata) << 32;
	status = mmi64_regif_read_32(user_module, tot_lo_regid, 1, &rdata);
	if (status != E_MMI64_OK)
		return status;
	tot |= (long long unsigned ) rdata;
	status = mmi64_regif_read_32(user_module, mem_hi_regid, 1, &rdata);
	if (status != E_MMI64_OK)
		return status;
	mem = ((long long unsigned) rdata) << 32;
	status = mmi64_regif_read_32(user_module, mem_lo_regid, 1, &rdata);
	if (status != E_MMI64_OK)
		return status;
	mem |= (long long unsigned ) rdata;
	status = mmi64_regif_read_32(user_module, tlb_regid, 1, &rdata);
	if (status != E_MMI64_OK)
		return status;
	tlb = (long long unsigned) rdata;

	probes_acc[accelerator][0] = tlb;
	probes_acc[accelerator][1] = mem;
	probes_acc[accelerator][2] = tot;

	probes_acc_tot[accelerator][0] += tlb;
	probes_acc_tot[accelerator][1] += mem;
	probes_acc_tot[accelerator][2] += tot;

	probes_acc_ave[accelerator][0] = probes_acc_tot[accelerator][0] / (current_time - sample_start);
	probes_acc_ave[accelerator][1] = probes_acc_tot[accelerator][1] / (current_time - sample_start);
	probes_acc_ave[accelerator][2] = probes_acc_tot[accelerator][2] / (current_time - sample_start);


	if (tlb > probes_acc_max[accelerator][0])
		probes_acc_max[accelerator][0] = tlb;
	if (mem > probes_acc_max[accelerator][1])
		probes_acc_max[accelerator][1] = mem;
	if (tot > probes_acc_max[accelerator][2])
		probes_acc_max[accelerator][2] = tot;

	if (tot)
		acc_relevant_sample = true;

	return E_MMI64_OK;
}

mmi64_error_t mmi64_mon::read_accs()
{
	int i;
	mmi64_error_t status;
	acc_relevant_sample = false;
	for (i = 0; i < ACCS_NUM; i++) {
		status = read_acc(i);
		if (status != E_MMI64_OK)
			return status;
	}

	return E_MMI64_OK;
}
#endif

#ifdef NOC_QUEUES_offset
mmi64_error_t mmi64_mon::read_queues()
{
	/*
	 * N = 0
	 * S = 1
	 * W = 2
	 * E = 3
	 * L = 4
	 */
	mmi64_error_t status;
	int i, j, k;
#ifdef SIGNATURE_offset
	const unsigned bits_per_sample = 3;
	for (i = 0; i < SIGNATURE_LEN - 1; i++) {
		int regid = SIGNATURE_offset + i + 1;
		status = mmi64_regif_read_32(user_module, regid, 1, &probes_signature[i]);
		if (status != E_MMI64_OK)
			return status;
		// probes_signature[i] = 0xffffffff;
	}

	for (k = 0; k < NOCS_NUM; k++)
		for (i = 0; i < TILES_NUM; i++)
			for (j = 0; j < DIRECTIONS-1; j++) {
	// for (k = 0; k < 1; k++)
	// 	for (i = 3; i < 4; i++)
	// 		for (j = 2; j < 3; j++) {
				const unsigned mask = 0xffffffff;
				const unsigned reg_width = (sizeof(uint32_t) * 8);
				unsigned global_lsb_bit =
					k * bits_per_sample * (DIRECTIONS - 1) * TILES_NUM +
					i * bits_per_sample * (DIRECTIONS - 1) +
					j * bits_per_sample;
				unsigned global_msb_bit = global_lsb_bit + bits_per_sample - 1;
				unsigned lsb_part = global_lsb_bit / reg_width;
				unsigned lsb_bit = global_lsb_bit % reg_width;
				unsigned msb_part = global_msb_bit / reg_width;
				unsigned msb_bit = global_msb_bit % reg_width;
				unsigned lsb_mask, msb_mask;
				uint32_t value;
				// std::cout << "lsb_part " << lsb_part << std::endl;
				// std::cout << "msb_part " << msb_part << std::endl;
				// std::cout << "lsb_bit " << lsb_bit << std::endl;
				// std::cout << "msb_bit " << msb_bit << std::endl;
				lsb_mask = mask << lsb_bit;
				msb_mask = mask >> (reg_width - msb_bit - 1);
				if (lsb_part == msb_part) {
					value = (probes_signature[lsb_part] & lsb_mask & msb_mask) >> lsb_bit;
				} else {
					unsigned msb_shift = reg_width - lsb_bit;
					value = (probes_signature[lsb_part] >> lsb_bit) | ((probes_signature[msb_part] & msb_mask) << msb_shift);
				}
				// std::cout << "lsb_mask 0x" << std::hex << lsb_mask << std::dec << std::endl;
				// std::cout << "msb_mask 0x" << std::hex << msb_mask << std::dec << std::endl;
				// std::cout << "value " << value << std::endl;
				switch(value) {
				case 0:	probes_queue[k][i][j] = 0; break;
				case 1:	probes_queue[k][i][j] = ceil((float) 0.250 * current_window); break;
				case 2:	probes_queue[k][i][j] = ceil((float) 0.375 * current_window); break;
				case 3:	probes_queue[k][i][j] = ceil((float) 0.500 * current_window); break;
				case 4:	probes_queue[k][i][j] = ceil((float) 0.625 * current_window); break;
				case 5:	probes_queue[k][i][j] = ceil((float) 0.750 * current_window); break;
				case 6:	probes_queue[k][i][j] = ceil((float) 0.875 * current_window); break;
				case 7:	probes_queue[k][i][j] = ceil((float) 1.000 * current_window); break;
				}

				probes_queue_tot[k][i][j] += probes_queue[k][i][j];
				probes_queue_ave[k][i][j] = probes_queue_tot[k][i][j] / (current_time - sample_start);
				if (probes_queue[k][i][j] > probes_queue_max[k][i][j])
					probes_queue_max[k][i][j] = probes_queue[k][i][j];
				// std::cout << probes_signature[msb_part] << std::endl;
				// std::cout << probes_signature[lsb_part] << std::endl;
			}
#else
	for (k = 0; k < NOCS_NUM; k++) {
		for (i = 0; i < TILES_NUM; i++)
			for (j = 0; j < DIRECTIONS; j++) {
				int regid = NOC_QUEUES_offset + (k * TILES_NUM * DIRECTIONS) + (i * DIRECTIONS) + j;
				status = mmi64_regif_read_32(user_module, regid, 1, &probes_queue[k][i][j]);
				if (status != E_MMI64_OK)
					return status;

				probes_queue_tot[k][i][j] += probes_queue[k][i][j];
				probes_queue_ave[k][i][j] = probes_queue_tot[k][i][j] / (current_time - sample_start);
				if (probes_queue[k][i][j] > probes_queue_max[k][i][j])
					probes_queue_max[k][i][j] = probes_queue[k][i][j];

			}
	}
#endif
	return E_MMI64_OK;
}
#endif
