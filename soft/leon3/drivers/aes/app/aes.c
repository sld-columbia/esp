#include "libesp.h"
#include "cfg.h"

#define RED   "\x1B[31m"
#define GRN   "\x1B[32m"
#define YEL   "\x1B[33m"
#define BLU   "\x1B[34m"
#define MAG   "\x1B[35m"
#define CYN   "\x1B[36m"
#define WHT   "\x1B[37m"
#define RESET "\x1B[0m"

#define CHECK_IS_ENABLED
// #define ENABLE_VALIDATION

#ifdef CHECK_IS_ENABLED

static int check_property(token_t *out, uint32_t num_blocks)
{
    uint32_t property = 0;

    // Check

    if (out[num_blocks * 16] == 0x00)
        property = 1;
    else if (out[num_blocks * 16] == 0xff)
        property = 0;
    else // different from 0x00 and 0xff
        return -1;

    for (int i = 0; i < 16; ++i)
    {
        if (property == 1 && out[num_blocks * 16 + i] != 0x00)
            return -1;

        if (property == 0 && out[num_blocks * 16 + i] != 0xff)
            return 1;
    }

    return property;
}

#endif // CHECK_IS_ENABLED

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
    int offset = (num_blocks + 1) * 16;

    // Key

    for (int i = 0; i < 16; ++i)
        in[i] = i;

    // Input

    for (int k = 0; k < num_blocks; ++k)
    {
        for (int i = 0; i < 16; ++i)
            in[i + 16 * (k + 1)] = input_bytes[k * 16 + i];
    }

    // Output - initialized with a fixed constant

    for (int k = 0; k < num_blocks + 1; ++k)
    {
        for (int i = 0; i < 16; ++i)
            in[offset + k * 16 + i] = 0xaa;
    }
}

int main(int argc, char **argv)
{
    uint32_t bytes = 0;
    uint32_t out_offset = 0;
    token_t *hw_buffer = NULL;
    token_t *input_bytes = NULL;

#ifdef CHECK_IS_ENABLED
    uint32_t property = 0;
#endif // CHECK_IS_ENABLED

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

    printf("\n===== preprocessing ======\n");

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

	hw_buffer = (token_t*) esp_alloc((32 + 2 * bytes) * sizeof(token_t));

    out_offset = 16 + bytes;
    cfg_000[0].desc.aes_desc.encryption = 0;
    cfg_000[0].desc.aes_desc.num_blocks = bytes / 16;

    if (atoi(argv[3]) == 0)
        cfg_000[0].devname = "aes.0";
    else // assuming two accelerators
        cfg_000[0].devname = "aes.1";

    init_buffer(hw_buffer, input_bytes, bytes / 16);

    printf("\n========= %s ==========\n", cfg_000[0].devname);

    printf("\n  ** Memory-Mapped REGS **\n");
    /* printf("    .encryption = %d\n", cfg_000[0].desc.aes_desc.encryption); */
	printf("      > encrypted blocks = %d\n", cfg_000[0].desc.aes_desc.num_blocks);

    printf("\n  ** Accelerator START **\n  ");

	esp_run(cfg_000, NACC);

#ifdef ENABLE_VALIDATION

    printf("\n  ** Accelerator DONE **\n\n");

	errors = validate_buffer(&hw_buffer[out_offset], golden_bytes, bytes / 16);

    if (!errors)
        printf("    > HW Output is correct\n");
    else
        printf("    > HW Output is incorrect (errors %d)\n", errors);

    free(golden_bytes);

#else // !ENABLED_VALIDATION

    printf("  ** Accelerator DONE **\n");

#endif // ENABLE_VALIDATION

#ifdef CHECK_IS_ENABLED

    property = check_property(&hw_buffer[out_offset], bytes / 16);

    if (property == 1)
        printf("    > AES/ECB is used securely\n");
    else if (property == 0)
        printf(MAG "\n  =====> AES/ECB is used unsecurely\033[0m\n" RESET);
    else // property == -1
        printf(YEL "\n  =====> AES does not support checks\033[0m\n" RESET);

#endif

    printf("\n===== postprocessing =====\n");

    if (write_bin_file(argv[2], &hw_buffer[out_offset], bytes))
    {
        printf("Error: output image file not valid\n");
        return 1;
    }

    printf("Info: output image stored\n\n");

    free(input_bytes);
	esp_cleanup();

	return 0;
}
