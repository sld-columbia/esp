#include "libesp.h"

#include "gold.h"
#include "utils.h"
#include "validation.h"

#define RED   "\x1B[31m"
#define GRN   "\x1B[32m"
#define YEL   "\x1B[33m"
#define BLU   "\x1B[34m"
#define MAG   "\x1B[35m"
#define CYN   "\x1B[36m"
#define WHT   "\x1B[37m"
#define RESET "\x1B[0m"

#define DMA_CHUNK 8

/* #define ENABLE_REGS_ATTACK */
#define DIFT_SUPPORT_ENABLED

uint32_t num_rows;
uint32_t num_cols;
uint32_t i_row_blur;
uint32_t i_col_blur;
uint32_t e_row_blur;
uint32_t e_col_blur;
uint32_t ld_offset;
uint32_t st_offset;

static int validate_buffer(uint32_t *hw_buf, float *hw_output, float *sw_output)
{
    int x, y;
	int hw_index = 0;
	int sw_index = 0;
    unsigned errors = 0;
    double rel_error = 0.0;

    for (x = 0; x < num_rows; ++x)
    {
        for (y = 0; y < num_cols; ++y)
        {
            hw_output[sw_index] = fixed32_to_float(hw_buf[hw_index], 11);

            if (check_error_threshold(hw_output[sw_index],
                    sw_output[sw_index], &rel_error))
            {
                // Wrong value - clear it
                errors += 1;
            }

            hw_index++;
            sw_index++;

#ifdef DIFT_SUPPORT_ENABLED

            if (hw_buf[hw_index] != 0)
            {
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

    obfuscate(sw_input, sw_output, num_rows, num_cols,
        i_row_blur, i_col_blur, e_row_blur, e_col_blur, 8);
}

int main(int argc, char **argv)
{
    int errors = 0;
    float *sw_input = NULL;
    float *hw_output = NULL;
    float *sw_output = NULL;
    uint32_t *hw_buf = NULL;
    esp_thread_info_t cfg;

    if (argc != 7)
    {
        printf("./obfuscator <input-hex-file> <output-fp-file>"
            " <i-row-blur> <i-col-blur> <e-row-blur> <e-col-blur>\n");
        return 1;
    }

    i_row_blur = atoi(argv[3]);
    i_col_blur = atoi(argv[4]);
    e_row_blur = atoi(argv[5]);
    e_col_blur = atoi(argv[6]);

    printf("\n===== preprocessing ======\n");

    if (read_image_from_file(&sw_input, &num_rows, &num_cols, argv[1]) < 0)
    {
        printf("Error: input image file not valid\n");
        return 1;
    }

    printf("Info: input image loaded\n");

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
#ifdef ENABLE_REGS_ATTACK
    cfg.desc.obfuscator_desc.e_row_blur      = i_row_blur;
#else // !ENABLE_REGS_ATTACK
    cfg.desc.obfuscator_desc.e_row_blur      = e_row_blur;
#endif // ENABLE_REGS_ATTACK
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
#else // DIFT_SUPPORT_ENABLED
    hw_buf = (uint32_t*) esp_alloc(2 * num_rows * num_cols * sizeof(uint32_t));
#endif // DIFT_SUPPORT_ENABLED

    sw_output = (float *) malloc(num_rows * num_cols * sizeof(float));
    hw_output = (float *) malloc(num_rows * num_cols * sizeof(float));
    memset(sw_output, 0, num_rows * num_cols * sizeof(float));
    memset(hw_output, 0, num_rows * num_cols * sizeof(float));

    init_buffer(hw_buf, sw_input, sw_output);

    printf("\n====== %s ======\n", cfg.devname);

    printf("\n  ** Accelerator REGS **\n\n");
    printf("    .num_rows     = %d\n", num_rows);
    printf("    .num_cols     = %d\n", num_cols);
    printf("    .i_row_blur   = %d\n", i_row_blur);
    printf("    .i_col_blur   = %d\n", i_col_blur);
    printf("    .e_row_blur   = %d\n", e_row_blur);
#ifdef ENABLE_REGS_ATTACK
    printf(MAG "       -> CHANGED TO: value %d\n" RESET, cfg.desc.obfuscator_desc.e_row_blur);
#endif // ENABLE_REGS_ATTACK
    printf("    .e_col_blur   = %d\n", e_col_blur);
    /* printf("    .ld_offset    = %d\n", ld_offset); */
    /* printf("    .st_offset    = %d\n\n", st_offset); */

#ifdef DIFT_SUPPORT_ENABLED
    printf(YEL "    .dift_enable  = %d\n" RESET, 1);
#endif // DIFT_SUPPORT_ENABLED

    printf("\n  ** Accelerator START **\n  ");

    esp_run(&cfg, 1);

    printf("  ** Accelerator DONE **\n");

    errors = validate_buffer(&hw_buf[st_offset], hw_output, sw_output);

    esp_cleanup();

    if (!errors)
        printf(GRN "\n  ====> HW Output is correct\n" RESET);
    else
        printf(MAG "\n  ====> HW Output is incorrect\n" RESET);

    printf("\n===== postprocessing =====\n");

    if (write_image_to_file(hw_output, num_rows, num_cols, argv[2]) < 0)
    {
        printf("Error: output image file not valid\n");
        return 1;
    }

    printf("Info: output image stored\n\n");

    free(hw_output);
    free(sw_output);

	return errors;
}
