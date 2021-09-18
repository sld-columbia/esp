/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include "multi_acc.h"
#include "gemm.h"
#include "conv2d.h"
#include "fft2.h"
#include "vitdodec.h"

const float ERROR_COUNT_TH = 0.001;

int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	unsigned done;
	unsigned errors = 0;
	unsigned coherence = ACC_COH_NONE;
	struct esp_device *espdevs_gemm, *espdevs_conv2d, *espdevs_fft2, *espdevs_vit;
	struct esp_device *dev_gemm, *dev_conv2d, *dev_fft2, *dev_vit;
	unsigned **ptable_gemm, **ptable_conv2d, **ptable_fft2, **ptable_vit;
	token_t *mem_gemm, *mem_conv2d, *mem_fft2;
	native_t *sw_buf_gemm, *sw_buf_conv2d, *sw_buf_fft2;
	token_vit_t *mem_vit, *sw_buf_vit;

	//////////////////////
	// Initialize
	
	// gemm
	do_relu_gemm = 0;
	transpose = 1;
#ifndef LARGE_WORKLOAD
	ninputs = 2;
	d3 = 8;
	d2 = 8;
	d1 = 8;
#else
	ninputs = 64;
	d3 = 64;
	d2 = 64;
	d1 = 64;
#endif
	ld_offset1 = 0;

	st_offset = ninputs * (d1 * d2 + d2 * d3);
	ld_offset2 = ninputs * (d1 * d2);
	in1_len_gemm = round_up(ninputs * d1 * d2, DMA_WORD_PER_BEAT(sizeof(token_t)));
	in_len_gemm = round_up(ninputs * (d1*d2 + d2*d3), DMA_WORD_PER_BEAT(sizeof(token_t)));
	out_len_gemm = round_up(ninputs * d1 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
	in_size_gemm = in_len_gemm * sizeof(token_t);
	out_size_gemm = out_len_gemm * sizeof(token_t);
	out_offset_gemm  = in_len_gemm;
	mem_size_gemm = (out_offset_gemm * sizeof(token_t)) + out_size_gemm;

	// conv2d
#ifndef LARGE_WORKLOAD
	batch_size = 1;
	n_channels = 2;
	feature_map_height = 6;
	feature_map_width = 6;
	n_filters = 2;
#else
	batch_size = 16;
	n_channels = 16;
	feature_map_height = 32;
	feature_map_width = 32;
	n_filters = 16;
#endif
	filter_height = 3;
	filter_width = 3;
	pad_h = 1;
	pad_w = 1;
	is_padded = 1;
	stride_h = 1;
	stride_w = 1;
	dilation_h = 1;
	dilation_w = 1;
	do_relu_conv2d = 0;
	pool_type = 0;

	in_len_conv2d = round_up(n_channels * feature_map_height * feature_map_width,
			  DMA_WORD_PER_BEAT(sizeof(token_t)));
	weights_len_conv2d = round_up(n_filters * n_channels * filter_height * filter_width,
			       DMA_WORD_PER_BEAT(sizeof(token_t)));
	bias_len_conv2d = round_up(n_filters, DMA_WORD_PER_BEAT(sizeof(token_t)));
	out_len_conv2d = round_up(n_filters * feature_map_height * feature_map_width,
			   DMA_WORD_PER_BEAT(sizeof(token_t)));
	in_size_conv2d = in_len_conv2d * sizeof(token_t);
	weights_size_conv2d = weights_len_conv2d * sizeof(token_t);
	bias_size_conv2d = bias_len_conv2d * sizeof(token_t);
	out_size_conv2d = out_len_conv2d * sizeof(token_t);
	weights_offset_conv2d = in_len_conv2d;
	bias_offset_conv2d = in_len_conv2d + weights_len_conv2d;
	out_offset_conv2d  = in_len_conv2d + weights_len_conv2d + bias_len_conv2d;
	mem_size_conv2d = in_size_conv2d + weights_size_conv2d + bias_len_conv2d + out_size_conv2d;

	// fft2
#ifndef LARGE_WORKLOAD
	logn_samples = 3;
	num_ffts = 1;
#else
	logn_samples = 14;
	num_ffts = 32;
#endif
	do_inverse = 0;
	do_shift = 0;
	scale_factor = 1;
	num_samples = (1 << logn_samples);
	
	len_fft2 = num_ffts * (1 << logn_samples);
	in_len_fft2 = round_up(2 * len_fft2, DMA_WORD_PER_BEAT(sizeof(token_t)));
	out_len_fft2 = round_up(2 * len_fft2, DMA_WORD_PER_BEAT(sizeof(token_t)));
	in_size_fft2 = in_len_fft2 * sizeof(token_t);
	out_size_fft2 = out_len_fft2 * sizeof(token_t);
	out_offset_fft2  = 0;
	mem_size_fft2 = (out_offset_fft2 * sizeof(token_t)) + out_size_fft2;

	// vitdodec
	cbps = 48;
	ntraceback = 5;
#ifndef LARGE_WORKLOAD
	data_bits = 288;
#else
	data_bits = 18585;
#endif

	in_len_vit = round_up(24852, DMA_WORD_PER_BEAT(sizeof(token_vit_t)));
	out_len_vit = round_up(18585, DMA_WORD_PER_BEAT(sizeof(token_vit_t)));
	in_size_vit = in_len_vit * sizeof(token_vit_t);
	out_size_vit = out_len_vit * sizeof(token_vit_t);
	out_offset_vit  = in_len_vit;
	mem_size_vit = (out_offset_vit * sizeof(token_vit_t)) + out_size_vit;
	
	///////////////////////////////////
	// Probing
	printf("  Probing...\n");
	
	// gemm
	printf("  Initialize GeMM app...\n");
	ndev = probe(&espdevs_gemm, VENDOR_SLD, SLD_GEMM, DEV_NAME_GEMM);
	if (ndev == 0) {
		printf("gemm not found\n");
		return 0;
	}
	dev_gemm = &espdevs_gemm[0];
	// Check DMA capabilities
	if (ioread32(dev_gemm, PT_NCHUNK_MAX_REG) == 0) {
	    printf("  -> scatter-gather DMA is disabled. Abort.\n");
	    return 0;
	}
	if (ioread32(dev_gemm, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_gemm)) {
	    printf("  -> Not enough TLB entries available. Abort.\n");
	    return 0;
	}

	// conv2d
	ndev = probe(&espdevs_conv2d, VENDOR_SLD, SLD_CONV2D, DEV_NAME_CONV2D);
	if (ndev == 0) {
		printf("conv2d not found\n");
		return 0;
	}
	dev_conv2d = &espdevs_conv2d[0];
	// Check DMA capabilities
	if (ioread32(dev_conv2d, PT_NCHUNK_MAX_REG) == 0) {
	    printf("  -> scatter-gather DMA is disabled. Abort.\n");
	    return 0;
	}
	if (ioread32(dev_conv2d, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_conv2d)) {
	    printf("  -> Not enough TLB entries available. Abort.\n");
	    return 0;
	}
	
	// fft2
	ndev = probe(&espdevs_fft2, VENDOR_SLD, SLD_FFT2, DEV_NAME_FFT2);
	if (ndev == 0) {
		printf("fft2 not found\n");
		return 0;
	}
	dev_fft2 = &espdevs_fft2[0];
	// Check DMA capabilities
	if (ioread32(dev_fft2, PT_NCHUNK_MAX_REG) == 0) {
	    printf("  -> scatter-gather DMA is disabled. Abort.\n");
	    return 0;
	}
	if (ioread32(dev_fft2, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_fft2)) {
	    printf("  -> Not enough TLB entries available. Abort.\n");
	    return 0;
	}

	// vit
	ndev = probe(&espdevs_vit, VENDOR_SLD, SLD_VITDODEC, DEV_NAME_VIT);
	if (ndev == 0) {
		printf("vit not found\n");
		return 0;
	}
	dev_vit = &espdevs_vit[0];
	// Check DMA capabilities
	if (ioread32(dev_vit, PT_NCHUNK_MAX_REG) == 0) {
	    printf("  -> scatter-gather DMA is disabled. Abort.\n");
	    return 0;
	}
	if (ioread32(dev_vit, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_vit)) {
	    printf("  -> Not enough TLB entries available. Abort.\n");
	    return 0;
	}

	///////////////////////////////////
	// Allocation
	printf("  Allocation...\n");

	// gemm
	sw_buf_gemm = aligned_malloc(mem_size_gemm);
	mem_gemm = aligned_malloc(mem_size_gemm);
	// printf("  memory buffer base-address = %p\n", mem_gemm);
	// printf("  sw memory buffer base-address = %p\n", sw_buf_gemm);
	ptable_gemm = aligned_malloc(NCHUNK(mem_size_gemm) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size_gemm); i++)
	    ptable_gemm[i] = (unsigned *) &mem_gemm[i * (CHUNK_SIZE / sizeof(token_t))];
	// printf("  ptable = %p\n", ptable_gemm);
	// printf("  nchunk = %lu\n", NCHUNK(mem_size_gemm));

	// conv2d
	sw_buf_conv2d = aligned_malloc(mem_size_conv2d);
	mem_conv2d = aligned_malloc(mem_size_conv2d);
	// printf("  memory buffer base-address = %p\n", mem_conv2d);
	// printf("  sw memory buffer base-address = %p\n", sw_buf_conv2d);
	ptable_conv2d = aligned_malloc(NCHUNK(mem_size_conv2d) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size_conv2d); i++)
	    ptable_conv2d[i] = (unsigned *) &mem_conv2d[i * (CHUNK_SIZE / sizeof(token_t))];
	// printf("  ptable = %p\n", ptable_conv2d);
	// printf("  nchunk = %lu\n", NCHUNK(mem_size_conv2d));

	// fft2
	sw_buf_fft2 = aligned_malloc(mem_size_fft2);
	mem_fft2 = aligned_malloc(mem_size_fft2);
	// printf("  memory buffer base-address = %p\n", mem_fft2);
	// printf("  sw memory buffer base-address = %p\n", sw_buf_fft2);
	ptable_fft2 = aligned_malloc(NCHUNK(mem_size_fft2) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size_fft2); i++)
	    ptable_fft2[i] = (unsigned *) &mem_fft2[i * (CHUNK_SIZE / sizeof(token_t))];
	// printf("  ptable = %p\n", ptable_fft2);
	// printf("  nchunk = %lu\n", NCHUNK(mem_size_fft2));

	// vit
	sw_buf_vit = aligned_malloc(out_size_vit);
	mem_vit = aligned_malloc(mem_size_vit);
	// printf("  memory buffer base-address = %p\n", mem_vit);
	// printf("  sw memory buffer base-address = %p\n", sw_buf_vit);
	ptable_vit = aligned_malloc(NCHUNK(mem_size_vit) * sizeof(unsigned *));
	for (i = 0; i < NCHUNK(mem_size_vit); i++)
	    ptable_vit[i] = (unsigned *) &mem_vit[i * (CHUNK_SIZE / sizeof(token_t))];
	// printf("  ptable = %p\n", ptable_vit);
	// printf("  nchunk = %lu\n", NCHUNK(mem_size_vit));
	
	///////////////////////////////////
	// Data Initialization
	printf("  Data initialization...\n");

	init_buf_gemm(mem_gemm, sw_buf_gemm);
	init_buf_conv2d(mem_conv2d, sw_buf_conv2d);
	init_buf_fft2(mem_fft2, sw_buf_fft2);
	init_buf_vitdodec(mem_vit, sw_buf_vit);

	///////////////////////////////////
	// Pre-configuration
	printf("  Pre-configuration...\n");

	// gemm
	iowrite32(dev_gemm, SELECT_REG, ioread32(dev_gemm, DEVID_REG));
	iowrite32(dev_gemm, COHERENCE_REG, coherence);
	iowrite32(dev_gemm, PT_ADDRESS_REG, (unsigned long) ptable_gemm);
	iowrite32(dev_gemm, PT_NCHUNK_REG, NCHUNK(mem_size_gemm));
	iowrite32(dev_gemm, PT_SHIFT_REG, CHUNK_SHIFT);
	iowrite32(dev_gemm, SRC_OFFSET_REG, 0);
	iowrite32(dev_gemm, DST_OFFSET_REG, 0);
	// conv2d
	iowrite32(dev_conv2d, SELECT_REG, ioread32(dev_conv2d, DEVID_REG));
	iowrite32(dev_conv2d, COHERENCE_REG, coherence);
	iowrite32(dev_conv2d, PT_ADDRESS_REG, (unsigned long) ptable_conv2d);
	iowrite32(dev_conv2d, PT_NCHUNK_REG, NCHUNK(mem_size_conv2d));
	iowrite32(dev_conv2d, PT_SHIFT_REG, CHUNK_SHIFT);
	iowrite32(dev_conv2d, SRC_OFFSET_REG, 0);
	iowrite32(dev_conv2d, DST_OFFSET_REG, 0);
	// fft2
	iowrite32(dev_fft2, SELECT_REG, ioread32(dev_fft2, DEVID_REG));
	iowrite32(dev_fft2, COHERENCE_REG, coherence);
	iowrite32(dev_fft2, PT_ADDRESS_REG, (unsigned long) ptable_fft2);
	iowrite32(dev_fft2, PT_NCHUNK_REG, NCHUNK(mem_size_fft2));
	iowrite32(dev_fft2, PT_SHIFT_REG, CHUNK_SHIFT);
	iowrite32(dev_fft2, SRC_OFFSET_REG, 0);
	iowrite32(dev_fft2, DST_OFFSET_REG, 0);
	// vitdodec
	iowrite32(dev_vit, SELECT_REG, ioread32(dev_vit, DEVID_REG));
	iowrite32(dev_vit, COHERENCE_REG, coherence);
	iowrite32(dev_vit, PT_ADDRESS_REG, (unsigned long) ptable_vit);
	iowrite32(dev_vit, PT_NCHUNK_REG, NCHUNK(mem_size_vit));
	iowrite32(dev_vit, PT_SHIFT_REG, CHUNK_SHIFT);
	iowrite32(dev_vit, SRC_OFFSET_REG, 0);
	iowrite32(dev_vit, DST_OFFSET_REG, 0);
	
	///////////////////////////////////
	// Execution on accelerators
	printf("  Execute on accelerators...\n");

	// TODO: START MEASURING ACCELERATOR EXECUTION TIME HERE

	// Flush (customize coherence model here)
	esp_flush(coherence);

	// gemm
	iowrite32(dev_gemm, GEMM_DO_RELU_REG, do_relu_gemm);
	iowrite32(dev_gemm, GEMM_TRANSPOSE_REG, transpose);
	iowrite32(dev_gemm, GEMM_NINPUTS_REG, ninputs);
	iowrite32(dev_gemm, GEMM_D3_REG, d3);
	iowrite32(dev_gemm, GEMM_D2_REG, d2);
	iowrite32(dev_gemm, GEMM_D1_REG, d1);
	iowrite32(dev_gemm, GEMM_ST_OFFSET_REG, st_offset);
	iowrite32(dev_gemm, GEMM_LD_OFFSET1_REG, ld_offset1);
	iowrite32(dev_gemm, GEMM_LD_OFFSET2_REG, ld_offset2);

	iowrite32(dev_gemm, CMD_REG, CMD_MASK_START);
	done = 0;
	while (!done) {
	    done = ioread32(dev_gemm, STATUS_REG);
	    done &= STATUS_MASK_DONE;
	}
	iowrite32(dev_gemm, CMD_REG, 0x0);

	// conv2d

	// TODO BIRUK: RECONFIGURE HERE! GEMM --> CONV2D

	iowrite32(dev_conv2d, CONV2D_N_CHANNELS_REG, n_channels);
	iowrite32(dev_conv2d, CONV2D_FEATURE_MAP_HEIGHT_REG, feature_map_height);
	iowrite32(dev_conv2d, CONV2D_FEATURE_MAP_WIDTH_REG, feature_map_width);
	iowrite32(dev_conv2d, CONV2D_N_FILTERS_REG, n_filters);
	iowrite32(dev_conv2d, CONV2D_FILTER_DIM_REG, filter_height);
	iowrite32(dev_conv2d, CONV2D_IS_PADDED_REG, is_padded);
	iowrite32(dev_conv2d, CONV2D_STRIDE_REG, stride_w);
	iowrite32(dev_conv2d, CONV2D_DO_RELU_REG, do_relu_conv2d);
	iowrite32(dev_conv2d, CONV2D_POOL_TYPE_REG, pool_type);
	iowrite32(dev_conv2d, CONV2D_BATCH_SIZE_REG, batch_size);
	
	iowrite32(dev_conv2d, CMD_REG, CMD_MASK_START);
	done = 0;
	while (!done) {
	    done = ioread32(dev_conv2d, STATUS_REG);
	    done &= STATUS_MASK_DONE;
	}
	iowrite32(dev_conv2d, CMD_REG, 0x0);
	
	// fft2

	// TODO BIRUK: RECONFIGURE HERE! CONV2D --> FFT2

	iowrite32(dev_fft2, FFT2_LOGN_SAMPLES_REG, logn_samples);
	iowrite32(dev_fft2, FFT2_NUM_FFTS_REG, num_ffts);
	iowrite32(dev_fft2, FFT2_SCALE_FACTOR_REG, scale_factor);
	iowrite32(dev_fft2, FFT2_DO_SHIFT_REG, do_shift);
	iowrite32(dev_fft2, FFT2_DO_INVERSE_REG, do_inverse);

	iowrite32(dev_fft2, CMD_REG, CMD_MASK_START);
	done = 0;
	while (!done) {
	    done = ioread32(dev_fft2, STATUS_REG);
	    done &= STATUS_MASK_DONE;
	}
	iowrite32(dev_fft2, CMD_REG, 0x0);

	// vitdodec

	// TODO BIRUK: RECONFIGURE HERE! FFT2 --> VITDODEC

	iowrite32(dev_vit, VITDODEC_CBPS_REG, cbps);
	iowrite32(dev_vit, VITDODEC_NTRACEBACK_REG, ntraceback);
	iowrite32(dev_vit, VITDODEC_DATA_BITS_REG, data_bits);

	iowrite32(dev_vit, CMD_REG, CMD_MASK_START);
	done = 0;
	while (!done) {
	    done = ioread32(dev_vit, STATUS_REG);
	    done &= STATUS_MASK_DONE;
	}
	iowrite32(dev_vit, CMD_REG, 0x0);

	// TODO: STOP MEASURING ACCELERATOR EXECUTION TIME HERE
	
	///////////////////////////////////
	// Execution on processor
	printf("  Execute on processor...\n");

	// TODO: START MEASURING PROCESSOR EXECUTION TIME HERE

	// gemm
	sw_run_gemm(do_relu_gemm, transpose, ninputs, d3, d2, d1,
		    sw_buf_gemm, &sw_buf_gemm[in1_len_gemm], &sw_buf_gemm[in_len_gemm]);


	// conv2d
	sw_run_conv2d(n_channels, feature_map_height, feature_map_width,
	       n_filters, filter_height, is_padded, stride_h,
	       do_relu_conv2d, pool_type, batch_size,
	       sw_buf_conv2d, &sw_buf_conv2d[weights_offset_conv2d],
	       &sw_buf_conv2d[bias_offset_conv2d], &sw_buf_conv2d[out_offset_conv2d]);

	// fft2
	fft2_comp(sw_buf_fft2, num_ffts, num_samples, logn_samples, do_inverse, do_shift);

	// vitdodec
	do_decoding(data_bits, cbps, ntraceback, (unsigned char *)mem_vit, (unsigned char*)sw_buf_vit);

	// TODO: STOP MEASURING PROCESSOR EXECUTION TIME HERE

	///////////////////////////////////
	// Validation
	printf("  Validation...\n");

	// gemm
	errors = validate_buf_gemm(&mem_gemm[out_offset_gemm], &sw_buf_gemm[out_offset_gemm]);
	if (errors)
	    printf("  ... gemm FAIL\n");
	else
	    printf("  ... gemm PASS\n");

	// conv2d
	errors = validate_buf_conv2d(&mem_conv2d[out_offset_conv2d], &sw_buf_conv2d[out_offset_conv2d]);
	if (errors)
	    printf("  ... conv2d FAIL\n");
	else
	    printf("  ... conv2d PASS\n");

	// fft2
	errors = validate_buf_fft2(&mem_fft2[out_offset_fft2], &sw_buf_fft2[out_offset_fft2]);
	if ((float)((float)errors / (2.0 * (float)len_fft2)) > ERROR_COUNT_TH)
	    printf("  ... fft2 FAIL\n");
	else
	    printf("  ... fft2 PASS\n");

	// vitdodec
	errors = validate_buf_vitdodec(&mem_vit[out_offset_vit], sw_buf_vit);
	if (errors)
	    printf("  ... vit FAIL\n");
	else
	    printf("  ... vit PASS\n");

	///////////////////////////////////
	// Free

	// gemm
	aligned_free(ptable_gemm);
	aligned_free(mem_gemm);
	aligned_free(sw_buf_gemm);
	// conv2d
	aligned_free(ptable_conv2d);
	aligned_free(mem_conv2d);
	aligned_free(sw_buf_conv2d);
	// fft2
	aligned_free(ptable_fft2);
	aligned_free(mem_fft2);
	aligned_free(sw_buf_fft2);
	// vitdodec
	aligned_free(ptable_vit);
	aligned_free(mem_vit);
	aligned_free(sw_buf_vit);
}
