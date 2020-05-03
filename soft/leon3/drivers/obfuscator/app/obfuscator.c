#include "libesp.h"

#include "gold.h"
#include "utils.h"
#include "validation.h"

#define DMA_CHUNK 8

/* #define DIFT_SUPPORT_ENABLED */

uint32_t num_rows;
uint32_t num_cols;
uint32_t i_row_blur;
uint32_t i_col_blur;
uint32_t e_row_blur;
uint32_t e_col_blur;
uint32_t ld_offset;
uint32_t st_offset;

static int validate_buffer(uint32_t *hw_output, float *sw_output)
{
    int x, y;
	int index = 0;
    unsigned errors = 0;
    double rel_error;

    for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            float value = ufixed32_to_float(hw_output[index], 11);

            if (check_error_threshold(value, sw_output[index], &rel_error))
            {
                printf("[%d, %d] val: %f expected: %f\n",
                        x, y, value, sw_output[index]);
                errors += 1;
            }

            index++;

#ifdef DIFT_SUPPORT_ENABLED

            if (out[index] != 0)
            {
                printf("[%d, %d] tag: %d expected: %d\n",
                        x, y, out[index], 0);
            }

            index++;

#endif // DIFT_SUPPORT_ENABLED

        }
    }

	return errors;
}

static void init_buffer(uint32_t *hw_buf, float *sw_input, float* sw_output)
{
    unsigned x, y;
    unsigned index = 0;

    for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            hw_buf[index] = float_to_ufixed32(sw_input[index], 11);

            index++;

#ifdef DIFT_SUPPORT_ENABLED

            if (x >= i_row_blur && x <= e_row_blur &&
                y >= i_col_blur && y <= e_col_blur)
            {
                hw_buf[index] = 1;
            }
            else
            {
                hw_buf[index] = 0;
            }

            index++;

#endif // DIFT_SUPPORT_ENABLED

        }
    }

    obfuscate(sw_input, sw_output, num_rows, num_cols, i_row_blur,
            i_col_blur, e_row_blur, e_col_blur, 8);
}

int main(int argc, char **argv)
{
	int errors;
    float *sw_input = NULL;
	float *sw_output = NULL;
    uint32_t *hw_buf = NULL;
    esp_thread_info_t cfg;

    if (argc != 7)
    {
        printf("./obfuscator <input> <output> <i-row>"
                " <i-col> <e-row> <e-col>\n");
        return 1;
    }

    i_row_blur = atoi(argv[3]);
    i_col_blur = atoi(argv[4]);
    e_row_blur = atoi(argv[5]);
    e_col_blur = atoi(argv[6]);

    if (read_image_from_file(&sw_input, &num_rows, &num_cols, argv[1]) < 0)
    {
        printf("Error: input image file not valid\n");
        return 1;
    }

    st_offset  = num_rows * num_cols;
    i_col_blur = my_round_down(i_col_blur, 1 << DMA_CHUNK);
    e_col_blur = my_round_up(e_col_blur, 1 << DMA_CHUNK, num_cols);

    cfg.run                                  = true;
    cfg.type                                 = obfuscator;
    cfg.devname                              = "obfuscator.0";
    cfg.desc.obfuscator_desc.num_rows        = num_rows;
    cfg.desc.obfuscator_desc.num_cols        = num_cols;
    cfg.desc.obfuscator_desc.i_row_blur      = i_row_blur;
    cfg.desc.obfuscator_desc.i_col_blur      = i_col_blur;
    cfg.desc.obfuscator_desc.e_row_blur      = e_row_blur;
    cfg.desc.obfuscator_desc.e_col_blur      = e_col_blur;
    cfg.desc.obfuscator_desc.ld_offset       = 0;
    cfg.desc.obfuscator_desc.st_offset       = st_offset;
    cfg.desc.obfuscator_desc.src_offset      = 0;
    cfg.desc.obfuscator_desc.dst_offset      = 0;
    cfg.desc.obfuscator_desc.esp.coherence   = ACC_COH_NONE;
    cfg.desc.obfuscator_desc.esp.p2p_store   = 0;
    cfg.desc.obfuscator_desc.esp.p2p_nsrcs   = 0;

	hw_buf = (uint32_t*) esp_alloc(2 * num_rows * num_cols);
    sw_output = malloc(sizeof(float) * num_rows * num_cols);

	init_buffer(hw_buf, sw_input, sw_output);

	printf("\n====== %s ======\n\n", cfg.devname);
	printf("  .num_rows   = %d\n", num_rows);
	printf("  .num_cols   = %d\n", num_cols);
	printf("  .i_row_blur = %d\n", i_row_blur);
	printf("  .i_col_blur = %d\n", i_col_blur);
	printf("  .e_row_blur = %d\n", e_row_blur);
	printf("  .e_col_blur = %d\n", e_col_blur);
	printf("  .ld_offset  = %d\n", ld_offset);
	printf("  .st_offset  = %d\n", st_offset);
	printf("\n  ** START **\n");

	esp_run(&cfg, 1);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&hw_buf[st_offset], sw_output);

	free(sw_output);
	esp_cleanup();

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg.devname);

    if (write_image_to_file(sw_output, num_rows, num_cols, argv[2]) < 0)
    {
        printf("Error: output image file not valid\n");
        return 1;
    }

	return errors;
}
