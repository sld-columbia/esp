#include "libesp.h"

#include "gold.h"
#include "utils.h"
#include "validation.h"

#define DMA_CHUNK 8
#define DIFT_SUPPORT_ENABLED

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
	int hw_index = 0;
	int sw_index = 0;
    unsigned errors = 0;
    double rel_error;

    for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            float value = fixed32_to_float(hw_output[hw_index], 11);

            if (check_error_threshold(value, sw_output[sw_index], &rel_error))
            {
                if (errors < 50)
                    printf("[%d, %d] val: %f expected: %f\n",
                        x, y, value, sw_output[sw_index]);
                errors += 1;
            }

            hw_index++;
            sw_index++;

#ifdef DIFT_SUPPORT_ENABLED

            if (hw_output[hw_index] != 0)
            {
                printf("[%d, %d] tag: %d expected: %d\n",
                        x, y, hw_output[hw_index], 0);
                errors += 1;
            }

            hw_index++;

#endif // DIFT_SUPPORT_ENABLED

        }
    }

#ifdef DIFT_SUPPORT_ENABLED
    assert (sw_index == num_rows * num_cols);
    assert (hw_index == 2 * num_rows * num_cols);
#endif // DIFT_SUPPORT_ENABLED

	return errors;
}

static void init_buffer(uint32_t *hw_buf, float *sw_input, float* sw_output)
{
    unsigned x, y;
    unsigned hw_index = 0;
    unsigned sw_index = 0;

    for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            hw_buf[hw_index] = float_to_fixed32(sw_input[sw_index], 11);

            hw_index++;
            sw_index++;

#ifdef DIFT_SUPPORT_ENABLED

            if (x >= i_row_blur && x <= e_row_blur &&
                y >= i_col_blur && y <= e_col_blur)
            {
                hw_buf[hw_index] = 1;
            }
            else
            {
                hw_buf[hw_index] = 0;
            }

            hw_index++;

#endif // DIFT_SUPPORT_ENABLED

        }
    }

#ifdef DIFT_SUPPORT_ENABLED
    assert (sw_index == num_rows * num_cols);
    assert (hw_index == 2 * num_rows * num_cols);
#endif // DIFT_SUPPORT_ENABLED

    /* obfuscate(sw_input, sw_output, num_rows, num_cols, */
        /* i_row_blur, i_col_blur, e_row_blur, e_col_blur, 8); */

    printf("sw_output[0] %f\n", sw_output[0]);
    printf("sw_output[1] %f\n", sw_output[1]);
}

/* int main(int argc, char **argv) */
/* { */
    /* float f1, f2; uint32_t u1, u2, u3, u4; */
    /* FILE *file = fopen("./hex.txt", "r"); */
    /* fscanf(file, "%u", &u1); */
    /* fscanf(file, "%u", &u2); */
    /* fscanf(file, "%x", &u3); */
    /* fscanf(file, "%x", &u4); */
    /* f1 = (float) *((float*) &u3); */
    /* f2 = (float) *((float*) &u4); */
    /* printf("the hexadecimal 0x%08x becomes %.3f as a float\n", u3, f1); */
    /* printf("the hexadecimal 0x%08x becomes %.3f as a float\n", u4, f2); */
    /* return 0; */
/* } */

int main(int argc, char **argv)
{
    int errors;
    float *sw_input = NULL;
    float *sw_output = NULL;
    uint32_t *hw_buf = NULL;
    esp_thread_info_t cfg;

    if (argc != 7)
    {
        printf("./obfuscator <input-hex-file> <output-hex-file>"
                " <i-row> <i-col> <e-row> <e-col>\n");
        return 1;
    }

    i_row_blur = atoi(argv[3]);
    i_col_blur = atoi(argv[4]);
    e_row_blur = atoi(argv[5]);
    e_col_blur = atoi(argv[6]);

    printf("Info: input image file: %s\n", argv[1]);
    printf("Info: output image file: %s\n", argv[2]);

    if (read_image_from_file(&sw_input, &num_rows, &num_cols, argv[1]) < 0)
    {
        printf("Error: input image file not valid\n");
        return 1;
    }

    printf("Info: input image loaded\n");
    
    if (read_image_from_file(&sw_output, &num_rows, &num_cols, argv[2]) < 0)
    {
        printf("Error: input image file not valid\n");
        return 1;
    }

    printf("Info: output image loaded\n");

    i_col_blur = my_round_down(i_col_blur, 1 << DMA_CHUNK);
    e_col_blur = my_round_up(e_col_blur, 1 << DMA_CHUNK, num_cols);

    ld_offset = 0;
#ifdef DIFT_SUPPORT_ENABLED
    st_offset = num_rows * num_cols * 2;
#else // DIFT_SUPPORT_ENABLED
    st_offset = num_rows * num_cols;
#endif // DIFT_SUPPORT_ENABLED

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

#ifdef DIFT_SUPPORT_ENABLED
    hw_buf = (uint32_t*) esp_alloc(4 * num_rows * num_cols * sizeof(uint32_t));
    /* sw_output = (float *) malloc(2 * num_rows * num_cols * sizeof(float)); */
#else // DIFT_SUPPORT_ENABLED
    hw_buf = (uint32_t*) esp_alloc(2 * num_rows * num_cols * sizeof(uint32_t));
    /* sw_output = (float *) malloc(num_rows * num_cols * sizeof(float)); */
#endif // DIFT_SUPPORT_ENABLED

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

#ifdef DIFT_SUPPORT_ENABLED
    printf(" DIFT ENABLED\n");
#endif // DIFT_SUPPORT_ENABLED
    
    esp_run(&cfg, 1);

    printf("\n  ** DONE **\n");

    errors = validate_buffer(&hw_buf[st_offset], sw_output);

    esp_cleanup();

    if (!errors)
       printf("+ Test PASSED\n");
    else
        printf("+ Test FAILED\n");

    printf("\n====== %s ======\n\n", cfg.devname);

    /* if (write_image_to_file(sw_output, num_rows, num_cols, argv[2]) < 0) */
    /* { */
        /* printf("Error: output image file not valid\n"); */
        /* return 1; */
    /* } */

	return errors;
}
