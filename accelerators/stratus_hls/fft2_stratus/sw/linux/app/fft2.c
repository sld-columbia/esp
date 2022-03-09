#include "cfg.h"
#include "utils/fft2_utils.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

const float ERR_TH = 0.05;
#include "in_data.h"
#include "out_data.h"

/* User-defined code */
static int validate_buffer(token_t *out, float *gold)
{
	int j;
	unsigned errors1 = 0;
	unsigned errors2 = 0;
	unsigned errors3 = 0;
	
    const unsigned num_samples = 1<<logn_samples;

	for (j = 0; j < 2 * num_ffts * num_samples; j++) {
		native_t val = fx2float(out[j], FX_IL);
		printf("FFT_OUTPUT %u : %f vs %f\n", j, FFT_OUTPUTS[j], val);
		usleep(50000);
	}

	for (j = 0; j < 2 * num_ffts * num_samples; j++) {
		native_t val = fx2float(out[j], FX_IL);
		/*printf("GOLD[%u] = %f : %f = OUTPUT[%u]\n", j, gold[j], val, j);*/

		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH) {
			if (errors1 < 2) { 
				printf(" GOLD[%u] = %f vs %f = out[%u]\n", j, gold[j], val, j);
			}
			errors1++;
		}
	}
	for (j = 0; j < 2 * num_ffts * num_samples; j++) {
		native_t val = fx2float(out[j], FX_IL);
		if ((fabs(FFT_OUTPUTS[j] - val) / fabs(FFT_OUTPUTS[j])) > ERR_TH) {
			if (errors2 < 2) { 
				printf(" FFT_OUTPUTS[%u] = %f vs %f = out[%u]\n", j, FFT_OUTPUTS[j], val, j);
			}
			errors2++;
		}
	}
	for (j = 0; j < 2 * num_ffts * num_samples; j++) {
		if ((fabs(FFT_OUTPUTS[j] - gold[j]) / fabs(FFT_OUTPUTS[j])) > ERR_TH) {
			if (errors3 < 2) { 
				printf(" FFT_OUTPUTS[%u] = %f vs %f = gold[%u]\n", j, FFT_OUTPUTS[j], gold[j], j);
			}
			errors3++;
		}
	}
	printf("  + Relative error > %.02f for %d gold %d output %d GvO values out of %d\n", ERR_TH, errors1, errors2, errors3, 2 * num_ffts * num_samples);

	return errors1;
/*
		if ((fabs(gold[j] - val) / fabs(gold[j])) > ERR_TH) {
			if (errors < 2) {
				printf(" GOLD[%u] = %f vs %f = out[%u]\n", j, gold[j], val, j);
			}
			errors++;
		}
	}
	printf("  + Relative error > %.02f for %d values out of %d\n", ERR_TH, errors, 2 * num_ffts * num_samples);

	return errors;
*/
}


/* User-defined code */
static void init_buffer(token_t *in, float *gold)
{
	int j;
	
    //const float LO = -2.0;
	//const float HI = 2.0;

	const unsigned num_samples = (1 << logn_samples);

	srand((unsigned int) time(NULL));

	for (j = 0; j < 2 * num_ffts * num_samples; j++) {
		//float scaling_factor = (float) rand () / (float) RAND_MAX;
		//gold[j] = LO + scaling_factor * (HI - LO);
		gold[j] = FFT_INPUTS[j];
		printf("INPUT %u : %f\n", j, gold[j]);
	}

	// convert input to fixed point
	for (j = 0; j < 2 * num_ffts * num_samples; j++) {
		in[j] = float2fx((native_t) gold[j], FX_IL);
	}

	// Compute golden output
	fft2_comp(gold, num_ffts, (1<<logn_samples), logn_samples, do_inverse, do_shift);
	for (j = 0; j < 2 * num_ffts * num_samples; j++) {
		printf("GOLD %u : %f\n", j, gold[j]);
		usleep(50000);
	}
	{
		float    tf_vals[4] = { 1.0, 0.5, 0.25, 1/sqrt(52.0)};
		token_t  tx_vals[4];
		for (int ti = 0; ti < 4; ti++) {
			tx_vals[ti] = float2fx(tf_vals[ti], FX_IL);
#if (FFT2_FX_WIDTH == 64)
			printf(" FP2FX: %f -> 0x%16llx\n", tf_vals[ti], *(uint64_t*)(&tx_vals[ti]));
#elif (FFT2_FX_WIDTH == 32)
			printf(" FP2FX: %f -> 0x%8x\n", tf_vals[ti], *(uint32_t*)(&tx_vals[ti]));
#endif
		}
	}
}


/* User-defined code */
static void init_parameters()
{
	const unsigned num_samples = (1 << logn_samples);

	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = 2 * num_ffts * num_samples;
		out_words_adj = 2 * num_ffts * num_samples;
	} else {
		in_words_adj = round_up(2 * num_ffts * num_samples, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(2 * num_ffts * num_samples, DMA_WORD_PER_BEAT(sizeof(token_t)));
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

	float *gold;
	token_t *buf;

        const float ERROR_COUNT_TH = 0.001;
	const unsigned num_samples = (1 << logn_samples);

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	cfg_000[0].hw_buf = buf;
	gold = malloc(out_len * sizeof(float));

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .logn_samples = %d\n", logn_samples);
	printf("   num_samples  = %d\n", (1 << logn_samples));
	printf("  .num_ffts = %d\n", num_ffts);
	printf("  .do_inverse = %d\n", do_inverse);
	printf("  .do_shift = %d\n", do_shift);
	printf("  .scale_factor = %d\n", scale_factor);
	printf("\n  ** START **\n");
	init_buffer(buf, gold);

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	free(gold);
	esp_free(buf);

        if ((float)(errors / (float)(2.0 * (float)num_ffts * (float)num_samples)) > ERROR_COUNT_TH)
		printf("  + TEST FAIL: exceeding error count threshold\n");
        else
		printf("  + TEST PASS: not exceeding error count threshold\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
