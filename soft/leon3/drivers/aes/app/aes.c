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

uint8_t key[16]    = { 0x00, 0x01, 0x02, 0x03,
                       0x04, 0x05, 0x06, 0x07,
                       0x08, 0x09, 0x10, 0x11,
                       0x12, 0x13, 0x14, 0x15 };

uint8_t plain[16]  = { 0x01, 0x03, 0x05, 0x07,
                       0x09, 0x11, 0x13, 0x15,
                       0x17, 0x19, 0x21, 0x23,
                       0x25, 0x27, 0x29, 0x31 };

uint8_t cipher[16] = { 0x8f, 0x70, 0xba, 0xf2,
                       0x14, 0x0e, 0x91, 0x30,
                       0xb7, 0x4f, 0x8a, 0x8d,
                       0xcc, 0x72, 0x63, 0x54 };

static int validate_buffer(token_t *out, token_t *gold)
{
	unsigned errors = 0;

    for (int k = 0; k < num_blocks; ++k)
    {
        for (int i = 0; i < 16; i++)
        {
	    	if (out[k * 16 + i] != cipher[i])
            {
                printf("error: %02x %02x\n", out[i], cipher[i]);
                errors++;
            }
        }
    }

	return errors;
}

static void init_buffer(token_t *in, token_t * gold)
{
    // Key

    for (int i = 0; i < 16; ++i)
        in[i] = key[i];

    // Input

    for (int k = 0; k < num_blocks; ++k)
    {
        for (int i = 0; i < 16; ++i)
            in[i + 16 * (k + 1)] = plain[i];
    }
}

static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0)
    {
		in_words_adj = (num_blocks + 1) * 16;
		out_words_adj = num_blocks * 16;
	}
    else
    {
		in_words_adj = round_up((num_blocks + 1) * 16,
            DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(num_blocks * 16,
            DMA_WORD_PER_BEAT(sizeof(token_t)));
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
	printf("  .encryption = %d\n", encryption);
	printf("  .num_blocks = %d\n", num_blocks);
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
