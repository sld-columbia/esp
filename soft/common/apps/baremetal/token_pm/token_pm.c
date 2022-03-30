/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "token_pm.h"
#include "token_pm_fft.h"
#include "token_pm_vitdodec.h"

int main(int argc, char * argv[])
{
    int i;
    int n;
    unsigned config0, config1_v1, config1_v2, config2, config3;
    unsigned tokens_next0, tokens_next1;



    unsigned acc_tile_pm_csr_addr[N_ACC];
    struct esp_device espdevs[N_ACC];
    struct esp_device *espdev;

    // setup CSR base addresses
    for (i = 0; i < N_ACC; i++) {
	acc_tile_pm_csr_addr[i] = CSR_BASE_ADDR + CSR_TILE_OFFSET * acc_tile_ids[i] + CSR_TOKEN_PM_OFFSET;
	espdevs[i].addr = acc_tile_pm_csr_addr[i];
    }


#ifdef TEST_0

    reset_token_pm(espdevs);

    write_lut(espdevs, lut_data_const, random_rate_const, no_activity_const);

    //validate_lut(espdevs, lut_data_const); // TO DO
    
    // Configure and start PM of all accelerator tiles
    printf("Config and start PM of all accelerators\n");
    for (n = 0; n < N_ACC; n++) {

	espdev = &espdevs[n];

	write_config2(espdev, neighbors_id_const[n]);
	write_config3(espdev, pm_network_const);
	write_config1(espdev, activity_const, random_rate_const, 0, token_counter_override_const[n]);
	write_config1(espdev, activity_const, random_rate_const, 0, 0);
	write_config0(espdev, enable_const, max_tokens_const[n], refresh_rate_min_const, refresh_rate_max_const);
    }

    wait_for_token_next(&espdevs[0], 30);
    wait_for_token_next(&espdevs[1], 30);
    printf("   --> tokens_next converged\n");

    printf("Stop activity of accelerator 1\n");
    write_config1(&espdevs[1], no_activity_const, random_rate_const, 0, 0);
    wait_for_token_next(&espdevs[0], 60);
    wait_for_token_next(&espdevs[1], 0);
    printf("   --> tokens_next converged\n");

    printf("Restart activity of accelerator 1\n");
    write_config1(&espdevs[1], activity_const, random_rate_const, 0, 0);
    wait_for_token_next(&espdevs[0], 30);
    wait_for_token_next(&espdevs[1], 30);
    printf("   --> tokens_next converged\n");

    printf("Set max_tokens = 0 for accelerator 0\n");
    write_config0(&espdevs[0], enable_const, 0, refresh_rate_min_const, refresh_rate_max_const);
    wait_for_token_next(&espdevs[0], 0);
    wait_for_token_next(&espdevs[1], 60);
    printf("   --> tokens_next converged\n");

    printf("Set max_tokens = 10 for accelerator 0\n");
    write_config0(&espdevs[0], enable_const, 10, refresh_rate_min_const, refresh_rate_max_const);

    wait_for_token_next(&espdevs[0], 9);
    wait_for_token_next(&espdevs[1], 51);
    printf("   --> tokens_next converged\n");

#endif

#ifdef TEST_1

    reset_token_pm(espdevs);

    write_lut(espdevs, lut_data_const_vc707, random_rate_const, no_activity_const);

    // Configure and start PM of all accelerator tiles
    printf("Config and start PM of all accelerators\n");
    unsigned token_counter_override_vc707[N_ACC] = {0x80, 0xb0}; // {1000 0000 (0), 1011 0000 (48)}    
    unsigned max_tokens_vc707[N_ACC] = {0, 48};
    for (n = 0; n < N_ACC; n++) {

	espdev = &espdevs[n];

	write_config2(espdev, neighbors_id_const[n]);
	write_config3(espdev, pm_network_const);
	write_config1(espdev, activity_const, random_rate_const, 0, token_counter_override_vc707[n]);
	write_config1(espdev, activity_const, random_rate_const, 0, 0);
	write_config0(espdev, enable_const, max_tokens_vc707[n], refresh_rate_min_const, refresh_rate_max_const);
    }

    wait_for_token_next(&espdevs[0], 0);
    wait_for_token_next(&espdevs[1], 48);
    printf("   --> tokens_next converged\n");
    
    printf("Set max_tokens 16 for acc 0, 32 for acc 1\n");
    write_config0(&espdevs[0], enable_const, 16, refresh_rate_min_const, refresh_rate_max_const);
    write_config0(&espdevs[1], enable_const, 32, refresh_rate_min_const, refresh_rate_max_const);
    wait_for_token_next(&espdevs[0], 16);
    wait_for_token_next(&espdevs[1], 32);
    printf("   --> tokens_next converged\n");

    printf("Set max_tokens 32 for acc 0, 16 for acc 1\n");
    write_config0(&espdevs[0], enable_const, 32, refresh_rate_min_const, refresh_rate_max_const);
    write_config0(&espdevs[1], enable_const, 16, refresh_rate_min_const, refresh_rate_max_const);
    wait_for_token_next(&espdevs[0], 32);
    wait_for_token_next(&espdevs[1], 16);
    printf("   --> tokens_next converged\n");

    printf("Set max_tokens 48 for acc 0, 0 for acc 1\n");
    write_config0(&espdevs[0], enable_const, 48, refresh_rate_min_const, refresh_rate_max_const);
    write_config0(&espdevs[1], enable_const,  0, refresh_rate_min_const, refresh_rate_max_const);
    wait_for_token_next(&espdevs[0], 48);
    wait_for_token_next(&espdevs[1], 0);
    printf("   --> tokens_next converged\n");

#endif

#ifdef TEST_2
    struct esp_device *espdevs_fft;
    struct esp_device *dev;
    unsigned done;
    unsigned **ptable = NULL;
    fft_token_t *mem;
    float *gold;
    unsigned errors = 0;
    unsigned coherence = ACC_COH_RECALL;
    const int ERROR_COUNT_TH = 0.001;
    unsigned iterations = 1;
    uint64_t cycles_start = 0, cycles_end = 0;

    fft_init_params();

    fft_probe(&espdevs_fft);

    dev = &espdevs_fft[0];

    // Check DMA capabilities
    if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
	printf("  -> scatter-gather DMA is disabled. Abort.\n");
	return 0;
    }

    if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size)) {
	printf("  -> Not enough TLB entries available. Abort.\n");
	return 0;
    }

    // Allocate memory
    gold = aligned_malloc(out_len * sizeof(float));
    mem = aligned_malloc(mem_size);
    printf("  memory buffer base-address = %p\n", mem);

    // Allocate and populate page table
    ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(mem_size); i++)
	ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(fft_token_t))];

    printf("  ptable = %p\n", ptable);
    printf("  nchunk = %lu\n", NCHUNK(mem_size));

    reset_token_pm(espdevs);

    write_lut(espdevs, lut_data_const_vc707, random_rate_const, no_activity_const);
    
    // Configure and start PM of all accelerator tiles
    printf("Config and start PM of all accelerators\n");
    unsigned token_counter_override_vc707[N_ACC] = {0x80, 0xb0}; // {1000 0000 (0), 1011 0000 (48)}    
    unsigned max_tokens_vc707[N_ACC] = {0, 48};
    for (i = 0; i < N_ACC; i++) {
	espdev = &espdevs[i];
	write_config2(espdev, neighbors_id_const[i]);
	write_config3(espdev, pm_network_const);
	write_config1(espdev, activity_const, random_rate_const, 0, token_counter_override_vc707[i]);
	write_config1(espdev, activity_const, random_rate_const, 0, 0);
	write_config0(espdev, enable_const, max_tokens_vc707[i], refresh_rate_min_const, refresh_rate_max_const);
    }
    wait_for_token_next(&espdevs[0], 0);
    wait_for_token_next(&espdevs[1], 48);
    printf("   --> tokens_next converged\n");

    unsigned max_tokens_fft[N_ACC][4] = {{0,16, 32, 48},{48, 32, 16, 0}};
    
    for (i = 0; i < iterations; ++i) {

	printf("Set max_tokens %u for acc 0, %u for acc 1\n", max_tokens_fft[0][i], max_tokens_fft[1][i]);
	write_config0(&espdevs[0], enable_const, max_tokens_fft[0][i], refresh_rate_min_const, refresh_rate_max_const);
	write_config0(&espdevs[1], enable_const, max_tokens_fft[1][i], refresh_rate_min_const, refresh_rate_max_const);
	wait_for_token_next(&espdevs[0], max_tokens_fft[0][i]);
	wait_for_token_next(&espdevs[1], max_tokens_fft[1][i]);
	printf("   --> tokens_next converged\n");

	//Disable tile 0
	espdev = &espdevs[0];
	write_config1(espdev, no_activity_const, random_rate_const, 0, 0);

	//Enable tile 1
	espdev = &espdevs[1];
	write_config1(espdev, activity_const, random_rate_const, 0, 0);


	printf("  --------------------\n");
	printf("  Generate input...\n");
	/* init_buf(mem, gold); */

	// Pass common configuration parameters

	iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);

	iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);

	iowrite32(dev, PT_NCHUNK_REG, NCHUNK(mem_size));
	iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);

	// Use the following if input and output data are not allocated at the default offsets
	iowrite32(dev, SRC_OFFSET_REG, 0x0);
	iowrite32(dev, DST_OFFSET_REG, 0x0);

	// Pass accelerator-specific configuration parameters
	/* <<--regs-config-->> */
	iowrite32(dev, FFT_DO_PEAK_REG, 0);
	iowrite32(dev, FFT_DO_BITREV_REG, do_bitrev);
	iowrite32(dev, FFT_LOG_LEN_REG, log_len);

	// Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence, 1);
	
	//Enable tile 0
	espdev = &espdevs[0];
	write_config1(espdev, activity_const, random_rate_const, 0, 0);

	// Start accelerators
	printf("  Start...\n");
	iowrite32(dev, CMD_REG, CMD_MASK_START);
	
#ifdef __riscv
	cycles_start = get_counter();
#endif
	// Wait for completion
	done = 0;
	while (!done) {
	    done = ioread32(dev, STATUS_REG);
	    done &= STATUS_MASK_DONE;
	}
	iowrite32(dev, CMD_REG, 0x0);
		
	//Disable tile 0
	espdev = &espdevs[0];
	write_config1(espdev, no_activity_const, random_rate_const, 0, 0);

#ifdef __riscv
	cycles_end = get_counter();
#endif
	printf("  Done\n");
	printf("  Execution cycles: %llu\n", cycles_end - cycles_start);
	printf("  validating...\n");

	/* /\* Validation *\/ */
	/* errors = validate_buf(&mem[out_offset], gold); */
	/* if ((errors / len) > ERROR_COUNT_TH) */
	/*     printf("  ... FAIL\n"); */
	/* else */
	/*     printf("  ... PASS\n"); */
    }

    aligned_free(ptable);
    aligned_free(mem);
    aligned_free(gold);
    
#endif


#ifdef TEST_3
//Test with running Viterbi decoder
	printf("Starting Viterbi test\n");
    struct esp_device dev_vit;
	int ndev;
	unsigned done;
	unsigned **ptable = NULL;
	vit_token_t *mem;
	vit_token_t *gold;
	unsigned errors = 0;
    int coherence = ACC_COH_RECALL;
	uint64_t cycles_start = 0, cycles_end = 0;
	
	
	printf("Config and start PM of all accelerators\n");
    unsigned token_counter_override_vc707[N_ACC] = {0x80, 0xb0}; // {1000 0000 (0), 1011 0000 (48)}    
    unsigned max_tokens_vc707[N_ACC] = {48, 48};
	
    for (i = 0; i < N_ACC; i++) {
	espdev = &espdevs[i];
	write_config2(espdev, neighbors_id_const[i]);
	write_config3(espdev, pm_network_const);
	write_config1(espdev, activity_const, random_rate_const, 0, token_counter_override_vc707[i]);
	write_config1(espdev, activity_const, random_rate_const, 0, 0);
	write_config0(espdev, enable_const, max_tokens_vc707[i], refresh_rate_min_const, refresh_rate_max_const);
    }
    wait_for_token_next(&espdevs[0], 24);
    wait_for_token_next(&espdevs[1], 24);
    printf("   --> tokens_next converged\n");
	
	//Disable tile 1
	espdev = &espdevs[1];
	write_config1(espdev, no_activity_const, random_rate_const, 0, 0);

	//Disable tile 0
	espdev = &espdevs[0];
	write_config1(espdev, no_activity_const, random_rate_const, 0, 0);

	//Viterbi stuff
    printf("Starting viterbi init\n");
	if (DMA_WORD_PER_BEAT(sizeof(vit_token_t)) == 0) {
		in_words_adj = 24852;
		out_words_adj = 18585;
	} else {
		in_words_adj = round_up(24852, DMA_WORD_PER_BEAT(sizeof(vit_token_t)));
		out_words_adj = round_up(18585, DMA_WORD_PER_BEAT(sizeof(vit_token_t)));
	}
	in_len = in_words_adj * (1);
	out_len = out_words_adj * (1);
	in_size = in_len * sizeof(vit_token_t);
	out_size = out_len * sizeof(vit_token_t);
	out_offset  = in_len;
	mem_size = (out_offset * sizeof(vit_token_t)) + out_size;

	dev_vit.addr=ACC_ADDR_VITERBI;

    // Allocate memory
    gold = aligned_malloc(out_size);
    mem = aligned_malloc(mem_size);

    //printf("  memory buffer base-address = %p\n", mem);
    // Alocate and populate page table
    ptable = aligned_malloc(NCHUNK(mem_size) * sizeof(unsigned *));
    for (i = 0; i < NCHUNK(mem_size); i++)
        ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(vit_token_t))];
    printf("  ptable = %p\n", ptable);
    printf("  nchunk = %lu\n", NCHUNK(mem_size));

    printf("  Generate input...\n");
    init_buf(mem, gold);

    // Pass common configuration parameters

    iowrite32(&dev_vit, SELECT_REG, ioread32(&dev_vit, DEVID_REG));
    iowrite32(&dev_vit, COHERENCE_REG, coherence);

    iowrite32(&dev_vit, PT_ADDRESS_REG, (unsigned long) ptable);

    iowrite32(&dev_vit, PT_NCHUNK_REG, NCHUNK(mem_size));
    iowrite32(&dev_vit, PT_SHIFT_REG, CHUNK_SHIFT);

    // Use the following if input and output data are not allocated at the default offsets
    iowrite32(&dev_vit, SRC_OFFSET_REG, 0x0);
    iowrite32(&dev_vit, DST_OFFSET_REG, 0x0);

    // Pass accelerator-specific configuration parameters
    /* <<--regs-config-->> */
    iowrite32(&dev_vit, VITDODEC_CBPS_REG, cbps);
    iowrite32(&dev_vit, VITDODEC_NTRACEBACK_REG, ntraceback);
    iowrite32(&dev_vit, VITDODEC_DATA_BITS_REG, data_bits);

    // Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL)
        esp_flush(coherence, 1);

	//Enable tile 1
	espdev = &espdevs[1];
	write_config1(espdev, activity_const, random_rate_const, 0, 0);

    // Start accelerators
    printf("  Start...\n");
	cycles_start = get_counter();
	

	
    iowrite32(&dev_vit, CMD_REG, CMD_MASK_START);
	

    // Wait for completion
    done = 0;
    while (!done) {
        done = ioread32(&dev_vit, STATUS_REG);
        done &= STATUS_MASK_DONE;
    }
	cycles_end = get_counter();

    iowrite32(&dev_vit, CMD_REG, 0x0);
	//Disable tile 1
	espdev = &espdevs[1];
	write_config1(espdev, 0, random_rate_const, 0, 0);

    printf("  Done\n");
	printf("  Execution cycles: %llu\n", cycles_end - cycles_start);

    printf("  validating...\n");

	//Enable tile 0
	espdev = &espdevs[0];
	write_config1(espdev, activity_const, random_rate_const, 0, 0);

    /* Validation */
    errors = validate_buf(&mem[out_offset], gold);
    if (errors)
        printf("  ... FAIL\n");
    else
        printf("  ... PASS\n");

    aligned_free(ptable);
    aligned_free(mem);
    aligned_free(gold);
#endif

    
    return 0;
}
