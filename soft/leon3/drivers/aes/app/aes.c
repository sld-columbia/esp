#include "libesp.h"
#include "cfg.h"

/* #define ENABLE_VALIDATION */

#ifdef ENABLE_VALIDATION

static int validate_buffer(token_t *out, token_t *gold, uint32_t num_blocks)
{
	unsigned errors = 0;

    // Output

    for (int k = 0; k < num_blocks; ++k)
    {
        for (int i = 0; i < 16; ++i)
        {
            if (out[k * 16 + i] != gold[k * 16 + i])
            {
                if (errors <= 10)
                    printf("Error: aes[%d] = %02x (%02x)\n", k * 16 + i,
                            out[k * 16 + i], gold[k * 16 + i]);
                errors += 1;
            }
        }
    }

	return errors;
}

#endif // ENABLE_VALIDATION

static void init_buffer(token_t *in, token_t *input_bytes, uint32_t num_blocks)
{
    // Key

    for (int i = 0; i < 16; ++i)
        in[i] = i;

    // Input

    for (int k = 0; k < num_blocks; ++k)
    {
        for (int i = 0; i < 16; ++i)
            in[i + 16 * (k + 1)] = input_bytes[k * 16 + i];
    }
}

int main(int argc, char **argv)
{
    uint32_t bytes = 0;
    uint32_t out_offset = 0;
    token_t *hw_buffer = NULL;
    token_t *input_bytes = NULL;
    token_t *output_bytes = NULL;
    
#ifdef ENABLE_VALIDATION
    unsigned errors = 0;
    token_t *golden_bytes = NULL;

    if (argc != 5)
    {
        printf("./aes.exe <input-file> <output-file> "
                "<acc#> <golden-output-file>\n");
        return 1;
    }

#else // !ENABLE_VALIDATION
    if (argc != 4)
    {
        printf("./aes.exe <input-file> <output-file> <acc#>\n");
        return 1;
    }

#endif // ENABLE_VALIDATION

    printf("\n===== preprocessing ======\n\n");

    if (read_bin_file(argv[1], &input_bytes, &bytes) < 0)
    {
        printf("Error: input image file not valid\n");
        return 1;
    }

    printf("Info: input image loaded\n");

#ifdef ENABLE_VALIDATION

    if (read_bin_file(argv[4], &golden_bytes, &bytes) < 0)
    {
        printf("Error: golden image file not valid\n");
        return 1;
    }

    printf("Info: golden image loaded\n");

#endif 
   
    output_bytes = (token_t*) malloc(sizeof(token_t) * bytes);
	hw_buffer = (token_t*) esp_alloc((16 + 2 * bytes) * sizeof(token_t));

    out_offset = 16 + bytes;
    cfg_000[0].desc.aes_desc.encryption = 0;
    cfg_000[0].desc.aes_desc.num_blocks = bytes / 16;
    if (atoi(argv[3]) == 0)
        cfg_000[0].devname = "aes.0";
    else // assuming two accelerators
        cfg_000[0].devname = "aes.1";

    init_buffer(hw_buffer, input_bytes, bytes / 16);
	
    printf("\n========= %s ==========\n", cfg_000[0].devname);
	
    printf("\n  ** Accelerator REGS **\n\n");
    printf("    .encryption = %d\n", cfg_000[0].desc.aes_desc.encryption);
	printf("    .num_blocks = %d\n", cfg_000[0].desc.aes_desc.num_blocks);

    printf("\n  ** Accelerator START **\n\n  ");

	esp_run(cfg_000, NACC);

#ifdef ENABLE_VALIDATION

    printf("\n  ** Accelerator DONE **\n\n");

	errors = validate_buffer(&hw_buffer[out_offset], golden_bytes, bytes / 16); 
    
    if (!errors)
        printf("    > HW Output is correct\n");
    else
        printf("    > HW Output is incorrect\n");

#else // !ENABLED_VALIDATION

    printf("\n  ** Accelerator DONE **\n\n");

#endif // ENABLE_VALIDATION

    printf("\n===== postprocessing =====\n\n");

    if (write_bin_file(argv[2], &hw_buffer[out_offset], bytes))
    {
        printf("Error: output image file not valid\n");
        return 1;
    }

    printf("Info: output image stored\n\n");
    
    free(output_bytes);
    free(input_bytes);
	esp_cleanup();

	return 0;
}
