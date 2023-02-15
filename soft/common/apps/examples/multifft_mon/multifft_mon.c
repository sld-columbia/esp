// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "monitors.h"
#include "libesp.h"
#include "multifft_mon_cfg.h"
#include "utils/fft_utils.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

const float ERR_TH = 0.05;

/* User-defined code */
static int validate_buffer(token_t *out, float *gold)
{
	int j;
	unsigned errors = 0;
	int total;

	total = 2 * len;

	for (j = 0; j < total; j++) {
		native_t val = fx2float(out[j], FX_IL);
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH)
			errors++;
	}

	printf("  + Relative error > %.02f for %d output values out of %d\n", ERR_TH, errors, total);

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, float *gold, bool p2p)
{
	int j, p, iters;
	const float LO = -1.0;
	const float HI = 1.0;

	srand((unsigned int) time(NULL));

	/* Repeat FFT for NACC times on the same memory region */
	if (p2p)
		iters = NACC;
	else
		iters = 1;

	for (j = 0; j < 2 * len; j++) {
		float scaling_factor = (float) rand () / (float) RAND_MAX;
		gold[j] = LO + scaling_factor * (HI - LO);
	}

	// convert input to fixed point
	for (j = 0; j < 2 * len; j++)
		in[j] = float2fx((native_t) gold[j], FX_IL);

	for (p = 0; p < iters; p++) {
		// Compute golden output
		fft_comp(gold, len, log_len,  -1, DO_BITREV);
	}
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 2 * len;
		out_words_adj = 2 * len;
	} else {
		in_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(2 * len, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj;
	out_len =  out_words_adj;
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = 0;
	size = (out_offset * sizeof(token_t)) + out_size;
}


int main(int argc, char **argv)
{
	int errors;
	char key;

	float *gold[3];
	token_t *buf[3];

	const float ERROR_COUNT_TH = 0.01;
	int k;

	init_parameters();

	for (k = 0; k < NACC; k++) {
		buf[k] = (token_t *) esp_alloc(NACC * size);
		gold[k] = malloc(NACC * out_len * sizeof(float));
	}

	init_buffer(buf[0], gold[0], false);

	printf("\n====== Non coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	cfg_nc[0].hw_buf = buf[0];

	//ESP MONITORS: EXAMPLE #1
	//read a single monitor from the tile number and monitor offset

	//statically declare monitor arg structure
	esp_monitor_args_t mon_args;

	//set up argument structure using READ_SINGLE mode
	//the off-chip memory accesses are read from the memory tile at the DDR_WORD_TRANSFER monitor
	const int MEM_TILE_IDX = 0;
	mon_args.read_mode = ESP_MON_READ_SINGLE;
	mon_args.tile_index = MEM_TILE_IDX;
	mon_args.mon_index = MON_DDR_WORD_TRANSFER_INDEX;

	//in the READ_SINGLE mode, the monitor value is returned directly
	//read before and after
	unsigned int ddr_accesses_start, ddr_accesses_end;
	ddr_accesses_start = esp_monitor(mon_args, NULL);
	esp_run(cfg_nc, 1);
	ddr_accesses_end = esp_monitor(mon_args, NULL);

	printf("\n	** DONE **\n");

	//calculate differnce, accounting for overflow
	unsigned int ddr_accesses_diff;
	ddr_accesses_diff = sub_monitor_vals(ddr_accesses_start, ddr_accesses_end);
	printf("\tOff-chip memory accesses: %d\n", ddr_accesses_diff);

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

		if (((float) errors / (float) len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
		else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");


	/* LLC-Coherent test */
	init_buffer(buf[0], gold[0], false);

	printf("\n====== LLC-coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	//ESP MONITORS: EXAMPLE #2
	//read all monitors on the SoC

	//statically declare monitor vals structures
	esp_monitor_vals_t vals_start, vals_end;

	//set read_mode to ALL
	mon_args.read_mode = ESP_MON_READ_ALL;

	cfg_llc[0].hw_buf = buf[0];

	printf("\n	** DONE **\n");

	//values written into vals struct argument
	esp_monitor(mon_args, &vals_start);
	esp_run(cfg_llc, 1);
	esp_monitor(mon_args, &vals_end);

	//calculate difference of all values
	esp_monitor_vals_t vals_diff;
	vals_diff = esp_monitor_diff(vals_start, vals_end);

	FILE *fp = fopen("multifft_esp_mon_all.txt", "w");
	esp_monitor_print(mon_args, vals_diff, fp);
	fclose(fp);

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

	if (((float) errors / (float) len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
	else
		printf("  + TEST PASS: not exceeding error count threshold\n");


	printf("\n============\n\n");

	/* Fully-Coherent test */
	init_buffer(buf[0], gold[0], false);

	printf("\n====== Fully-coherent DMA ======\n\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	//ESP MONITORS: EXAMPLE #3
	//read a specified subset of the monitors on the SoC

	//dynamically allocate monitor arg structure
	esp_monitor_vals_t *vals_start_ptr = esp_monitor_vals_alloc();
	esp_monitor_vals_t *vals_end_ptr = esp_monitor_vals_alloc();

	//set read_mode to MANY
	mon_args.read_mode = ESP_MON_READ_MANY;
	mon_args.read_mask = 0;

	//enable reading memory accesses
	mon_args.read_mask |= 1 << ESP_MON_READ_DDR_ACCESSES;

	//enable reading L2 statistics
	mon_args.read_mask |= 1 << ESP_MON_READ_L2_STATS;

	//enable reading LLC statistics
	mon_args.read_mask |= 1 << ESP_MON_READ_LLC_STATS;

	//enable reading acc statistics - requires the index of the accelerator
	mon_args.acc_index = 0;
	mon_args.read_mask |= 1 << ESP_MON_READ_ACC_STATS;

	//enable reading noc injections - requires the index of the tile
	const int ACC_TILE_INDEX = 2;
	mon_args.tile_index = ACC_TILE_INDEX;
	mon_args.read_mask |= 1 << ESP_MON_READ_NOC_INJECTS;

	//enable reading noc backpressure on a plane - requires the index of the noc plane
	const int NOC_PLANE = 0;
	mon_args.noc_index = NOC_PLANE;
	mon_args.read_mask |= 1 << ESP_MON_READ_NOC_QUEUE_FULL_PLANE;

	cfg_fc[0].hw_buf = buf[0];

	//values written into vals struct argument
	esp_monitor(mon_args, vals_start_ptr);
	esp_run(cfg_fc, 1);
	esp_monitor(mon_args, vals_end_ptr);

	printf("\n	** DONE **\n");

   //calculate difference of all values
	vals_diff = esp_monitor_diff(*vals_start_ptr, *vals_end_ptr);

	//write results to file
	fp = fopen("multifft_esp_mon_many.txt", "w");
	esp_monitor_print(mon_args, vals_diff, fp);
	fclose(fp);

	//when done with monitors, free all allocated structures, and unmap the address space
	esp_monitor_free();

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

	if (((float) errors / (float) len) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
	else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");

	/* Parallel test */
	for (k = 0; k < NACC; k++) {
		init_buffer(buf[k], gold[k], false);
	}

	printf("\n====== Concurrent execution ======\n\n");
	printf("  fft.0 -> fully coherent\n");
	printf("  fft.1 -> LLC-coherent DMA\n");
	printf("  fft.2 -> non-coherent DMA\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	for (k = 0; k < NACC; k++)
		cfg_parallel[k].hw_buf = buf[k];

	esp_run(cfg_parallel, NACC);

	printf("\n	** DONE **\n");

	for (k = 0; k < NACC; k++) {
		errors = validate_buffer(&buf[k][out_offset], gold[k]);
		if (( (float) errors / (float) (len * NACC)) > ERROR_COUNT_TH)
		printf("  + TEST FAIL fft.%d: exceeding error count threshold\n", k);
		else
		printf("  + TEST PASS fft.%d: not exceeding error count threshold\n", k);
	}

	printf("\n============\n\n");


	/* P2P test */
	init_buffer(buf[0], gold[0], true);

	printf("\n====== Point-to-point Test ======\n\n");
	printf("  fft.0 (NC DMA) -> fft.1 -> fft.2 (NC DMA)\n");
	printf("  .len = %d\n", len);
	printf("  .log_len = %d\n", log_len);

	printf("  ** Press ENTER to START ** ");
	scanf("%c", &key);

	for (k = 0; k < NACC; k++)
		cfg_p2p[k].hw_buf = buf[0];

	esp_run(cfg_p2p, NACC);

	printf("\n	** DONE **\n");

	errors = validate_buffer(&buf[0][out_offset], gold[0]);

		if (((float) errors / (float) (len * NACC)) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
		else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n============\n\n");

	for (k = 0; k < NACC; k++) {
		free(gold[k]);
		esp_free(buf[k]);
	}

	return errors;
}
