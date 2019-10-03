#include "libesp.h"
#include "cfg.h"

/* User-defined code */
const unsigned in_size = /* <<--in-words-->> */ * sizeof(token_t);
const unsigned out_size = /* <<--out-words-->> */ * sizeof(token_t);
const unsigned out_offset = /* <<--store-offset-->> */;
const unsigned size = in_size + out_size;

/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	unsigned errors = 0;

	for (i = 0; i < /* <<--out-words-->> */; i++) {
		if (gold[i] != out[i])
			errors++;
	}

	return errors;

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;

	for (i = 0; i < /* <<--in-words-->> */; i++)
		in[i] = (token_t) i;

	for (i = 0; i < /* <<--out-words-->> */; i++)
		gold[i] = (token_t) i;
}

int main(int argc, char **argv)
{
	int errors;
	contig_handle_t contig;

	token_t *buf = malloc(size);
	token_t *gold = malloc(out_size);

	init_buffer(buf, gold);

	esp_alloc(&contig, buf, size, in_size);
	esp_run(cfg_000, NACC);
	esp_dump(&buf[out_offset], out_size);
	esp_cleanup();

	errors = validate_buffer(&buf[out_offset], gold);
	free(buf);
	free(gold);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	return errors;
}
