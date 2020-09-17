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
	int j;
	unsigned errors = 0;
 const float ERR_TH = 0.2f;
        for (i = 0; i < 1; i++)
                for (j = 0; j < output_rows * output_rows; j++)
                  if ((fabs(gold[j] - out[j]) / fabs(gold[j])) > ERR_TH) {
                                printf(" GOLD = %d   and  OUT = %d  and J = %d \n", gold[j], out[j], );
                                errors++; }
`
	return errors;
}




/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = input_rows * input_rows;
		out_words_adj = output_rows * output_rows;
	} else {
		in_words_adj = round_up(input_rows * input_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(output_rows * output_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len =  out_words_adj * (1);
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
    cfg_000.hw_buf = buf;
    
    gold = malloc(out_size);

//	init_buffer(buf, gold);
#include "data.h"

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .input_rows = %d\n", input_rows);
	printf("  .output_rows = %d\n", output_rows);
	printf("\n  ** START **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	free(gold);
	esp_free(buf);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	return errors;
}
