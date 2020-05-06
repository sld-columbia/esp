#ifndef __ESP_CFG_000_H__
#define __ESP_CFG_000_H__

#include "libesp.h"

#define NACC 1
#define ENCRYPTION 0
#define NUM_BLOCKS 3

typedef uint8_t token_t;

esp_thread_info_t cfg_000[] = {
    {
		.run = true,
		.devname = "aes.0",
		.type = aes,
		.desc.aes_desc.num_blocks = NUM_BLOCKS,
		.desc.aes_desc.encryption = ENCRYPTION,
		.desc.aes_desc.src_offset = 0,
		.desc.aes_desc.dst_offset = 0,
		.desc.aes_desc.esp.coherence = ACC_COH_NONE,
		.desc.aes_desc.esp.p2p_store = 0,
		.desc.aes_desc.esp.p2p_nsrcs = 0,
		.desc.aes_desc.esp.p2p_srcs = {"", "", "", ""},
	}
};

int read_bin_file(const char* filename, uint8_t **data, uint32_t *data_bytes)
{
    FILE *file = fopen(filename, "rb");
    if (file == NULL)
        return 1;

    fseek(file, 0, SEEK_END);
    *data_bytes = ftell(file);
    fseek(file, 0, SEEK_SET);

    (*data) = (uint8_t*) malloc(sizeof(uint8_t) * (*data_bytes));
    if (*data == NULL)
        return 1;

    fread(*data, sizeof(uint8_t), *data_bytes, file);
    fclose(file);

    return 0;
}

int write_bin_file(const char* filename, uint8_t *data, uint32_t data_bytes)
{
    FILE *file = fopen(filename, "wb");
    if (file == NULL)
        return 1;

    fwrite(data, sizeof(uint8_t), data_bytes, file);
    fclose(file);

    return 0;
}

#endif /* __ESP_CFG_000_H__ */
