#include "libesp.h"
#include "cfg.h"

static unsigned in_words_adj;
static unsigned weights_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned weights_len;
static unsigned out_len;
static unsigned in_size;
static unsigned weights_size;
static unsigned out_size;
static unsigned weights_offset;
static unsigned out_offset;
static unsigned size;

/* User-defined code */
static int validate_buffer(token_t *out, native_t *gold)
{
	int i;
	native_t val;
	unsigned errors = 0;

        for (i = 0; i < out_len; i++) {
#ifdef __FIXED
	    val = fx2float(out[i], FX_IL);
#else
            val = out[i];
#endif
            if (gold[i] != val) {
                errors++;
                if (errors <= MAX_PRINTED_ERRORS)
                    printf("%d : %d\n", (int) val, (int) gold[i]);
            }
	}

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, native_t * gold)
{
#include "input.h"
#include "gold.h"
}


/* User-defined code */
static void init_parameters()
{
	// Input data and golden output (aligned to DMA_WIDTH makes your life easier)
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
	    in_words_adj = n_channels * feature_map_height * feature_map_width;
	    weights_words_adj = n_filters * n_channels * filter_height * filter_width;
	    out_words_adj = n_filters * feature_map_height * feature_map_width;
	} else {
	    in_words_adj = round_up(n_channels * feature_map_height * feature_map_width,
				    DMA_WORD_PER_BEAT(sizeof(token_t)));
	    weights_words_adj = round_up(n_filters * n_channels * filter_height * filter_width,
					 DMA_WORD_PER_BEAT(sizeof(token_t)));
	    out_words_adj = round_up(n_filters * feature_map_height * feature_map_width,
				     DMA_WORD_PER_BEAT(sizeof(token_t)));
	}

	in_len = in_words_adj * (1);
	weights_len = weights_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	weights_size = weights_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	weights_offset = in_len;
	out_offset  = in_len + weights_len;
	size = (out_offset * sizeof(token_t)) + out_size;
}


int main(int argc, char **argv)
{
	int errors;

	native_t *gold;
	token_t *buf;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	cfg_000[0].hw_buf = buf;
	gold = malloc(out_size);

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .n_channels = %d\n", n_channels);
	printf("  .n_filters = %d\n", n_filters);
	printf("  .filter_height = %d\n", filter_height);
	printf("  .dilation_h = %d\n", dilation_h);
	printf("  .stride_w = %d\n", stride_w);
	printf("  .pad_w = %d\n", pad_w);
	printf("  .feature_map_height = %d\n", feature_map_height);
	printf("  .pad_h = %d\n", pad_h);
	printf("  .stride_h = %d\n", stride_h);
	printf("  .filter_width = %d\n", filter_width);
	printf("  .dilation_w = %d\n", dilation_w);
	printf("  .feature_map_width = %d\n", feature_map_width);
	printf("\n  ** START **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	free(gold);
	esp_cleanup();

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
