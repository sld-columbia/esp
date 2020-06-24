#include "libesp.h"
#include "cfg.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
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
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	native_t cnt;

	cnt = 1;
	for (i = 0; i < ninputs * (d1*d2 + d2*d3); i++) {
#ifdef __FIXED
	    in[i] = float2fx(cnt, FX_IL);
#else
	    in[i] = cnt;
#endif
	    cnt++;
	    if (cnt == 17)
		cnt = 1;
	}

#include "gold.h"
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = ninputs * (d1*d2 + d2*d3);
		out_words_adj = ninputs * d1 * d3;
	} else {
		in_words_adj = round_up(ninputs * (d1*d2 + d2*d3), DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(ninputs * d1 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj;
	out_len =  out_words_adj;
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = in_len;
	size = (out_offset * sizeof(token_t)) + out_size;
}


int main(int argc, char **argv)
{
	int errors;

	token_t *gold;
	token_t *buf;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	gold = malloc(out_size);

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .do_relu = %d\n", do_relu);
	printf("  .transpose = %d\n", transpose);
	printf("  .ninputs = %d\n", ninputs);
	printf("  .d3 = %d\n", d3);
	printf("  .d2 = %d\n", d2);
	printf("  .d1 = %d\n", d1);
	printf("  .st_offset = %d\n", st_offset);
	printf("  .ld_offset1 = %d\n", ld_offset1);
	printf("  .ld_offset2 = %d\n", ld_offset2);
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
