/* Copyright (c) 2011-2021 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
    #include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>
#include "blitzcoin_3x3.h"
#include "blitzcoin_fft.h"
#include "blitzcoin_vitdodec.h"
#include "blitzcoin_nvdla.h"

int main(int argc, char *argv[])
{
    int i;
    int n;
    // unsigned config0, config1_v1, config1_v2, config2, config3;
    // unsigned tokens_next0, tokens_next1;

    unsigned acc_tile_pm_csr_addr[N_ACC];
    struct esp_device espdevs[N_ACC];
    struct esp_device *espdev;

    // setup CSR base addresses
    for (i = 0; i < N_ACC; i++) {
        acc_tile_pm_csr_addr[i] =
            CSR_BASE_ADDR + CSR_TILE_OFFSET * acc_tile_ids[i] + CSR_TOKEN_PM_OFFSET;
        espdevs[i].addr = acc_tile_pm_csr_addr[i];
    }

#ifdef TEST_0

    reset_blitzcoin(espdevs);

    // Configure and start PM of all accelerator tiles
    printf("Test 0: Config and start PM of two accelerators\n");

    init_consts();

    // Only tiles 0 and 2 are enabled

    // Configure tiles
    espdev = &espdevs[0];
    write_lut(espdevs, lut_data_const_NVDLA, random_rate_const_0, no_activity_const, 0);
    write_config2(espdev, neighbors_id_const_EXP0[0]);
    write_config3(espdev, pm_network_const[0]);
    write_config1(espdev, activity_const, random_rate_const_0, 0, token_counter_override[0]);
    write_config1(espdev, activity_const, random_rate_const_0, 0, 0);
    espdev = &espdevs[2];
    write_lut(espdevs, lut_data_const_VIT, random_rate_const_0, no_activity_const, 2);
    write_config2(espdev, neighbors_id_const_EXP0[2]);
    write_config3(espdev, pm_network_const[2]);
    write_config1(espdev, activity_const, random_rate_const_0, 0, token_counter_override[2]);
    write_config1(espdev, activity_const, random_rate_const_0, 0, 0);

    // Enable blitzcoin on the 2 tiles
    espdev = &espdevs[0];
    write_config0(espdev, enable_const, max_tokens_EXP0[0], refresh_rate_min_const[0],
                  refresh_rate_max_const[0]);
    espdev = &espdevs[2];
    write_config0(espdev, enable_const, max_tokens_EXP0[2], refresh_rate_min_const[2],
                  refresh_rate_max_const[2]);

    wait_for_token_next(&espdevs[0], 15);
    wait_for_token_next(&espdevs[2], 15);
    printf("   --> tokens_next converged\n");

    printf("Stop activity of accelerator 2\n");
    write_config1(&espdevs[2], no_activity_const, random_rate_const_0, 0, 0);
    wait_for_token_next(&espdevs[0], 30);
    wait_for_token_next(&espdevs[2], 0);
    printf("   --> tokens_next converged\n");

    printf("Restart activity of accelerator 2\n");
    write_config1(&espdevs[2], activity_const, random_rate_const_0, 0, 0);
    wait_for_token_next(&espdevs[0], 15);
    wait_for_token_next(&espdevs[2], 15);
    printf("   --> tokens_next converged\n");

    printf("Set max_tokens = 0 for accelerator 0\n");
    write_config0(&espdevs[0], enable_const, 0, refresh_rate_min_const[0],
                  refresh_rate_max_const[0]);
    wait_for_token_next(&espdevs[0], 0);
    wait_for_token_next(&espdevs[2], 30);
    printf("   --> tokens_next converged\n");

    printf("Completed test 0\n");
#endif

#ifdef TEST_1

    // Test running all viterbi, NVDLA and FFT tiles
    struct esp_device *espdevs_fft, *espdevs_viterbi, *espdevs_nvdla;
    struct esp_device *dev_n0 = aligned_malloc(sizeof(struct esp_device));
    struct esp_device *dev_f0 = aligned_malloc(sizeof(struct esp_device));
    struct esp_device *dev_f1 = aligned_malloc(sizeof(struct esp_device));
    struct esp_device *dev_f2 = aligned_malloc(sizeof(struct esp_device));
    struct esp_device *dev_v0 = aligned_malloc(sizeof(struct esp_device));
    struct esp_device *dev_v1 = aligned_malloc(sizeof(struct esp_device));
    // struct esp_device *dev, *dev_f0, *dev_f1, *dev_f2 ;
    // struct esp_device *dev_v0, *dev_v1 ;
    unsigned done_all, done_f0 = 0, done_v0 = 0, done_f0_before = 0, done_v0_before = 0;
    unsigned done_f1 = 0, done_v1 = 0, done_f1_before = 0, done_v1_before = 0;
    unsigned done_f2 = 0, done_n0 = 0, done_f2_before = 0, done_n0_before = 0;

    unsigned **ptable_f0 = NULL;
    unsigned **ptable_f1 = NULL;
    unsigned **ptable_f2 = NULL;
    unsigned **ptable_v0 = NULL;
    unsigned **ptable_v1 = NULL;
    nvdla_token_t *mem_n0;
    nvdla_token_t *gold_nvdla;
    fft_token_t *mem_f0, *mem_f1, *mem_f2;
    fft_token_t *gold_fft;
    vit_token_t *mem_v0, *mem_v1;
    vit_token_t *gold_vit;

    unsigned errors          = 0;
    unsigned coherence       = ACC_COH_RECALL;
    const int ERROR_COUNT_TH = 0.001;
    uint64_t cycles_start = 0, cycles_end_n0 = 0, cycles_end_f0 = 0, cycles_end_v0 = 0,
             cycles_end_f1 = 0, cycles_end_v1 = 0, cycles_end_f2 = 0;
    int ndev;

    // Initialize tokens
    init_consts();
    reset_blitzcoin(espdevs);
    #ifdef PID_CONFIG
    write_lut_all(espdevs, lut_data_const, random_rate_const, no_activity_const);
    #else
    write_lut(espdevs, lut_data_const_NVDLA, random_rate_const_0, no_activity_const, 0);
    write_lut(espdevs, lut_data_const_FFT, random_rate_const, no_activity_const, 1);
    write_lut(espdevs, lut_data_const_VIT, random_rate_const, no_activity_const, 2);
    write_lut(espdevs, lut_data_const_FFT, random_rate_const, no_activity_const, 3);
    write_lut(espdevs, lut_data_const_VIT, random_rate_const, no_activity_const, 4);
    write_lut(espdevs, lut_data_const_FFT, random_rate_const, no_activity_const, 5);
    #endif

    // Configure and start PM of all accelerator tiles
    printf("Test 1: Config and start PM of all accelerators\n");
    printf("Clock frequency: 0x%x\n", TOKEN_PM_CONFIG8_REG_DEFAULT);

    for (i = 0; i < N_ACC; i++) {
        espdev = &espdevs[i];
        write_config2(espdev, neighbors_id_const[i]);
        write_config3(espdev, pm_network_const[i]);
        if (i > 0) {
            write_config1(espdev, no_activity_const, random_rate_const, 0,
                          token_counter_override[i]);
            write_config1(espdev, no_activity_const, random_rate_const, 0, 0);
        }
        else {
            write_config1(espdev, no_activity_const, random_rate_const_0, 0,
                          token_counter_override[i]);
            write_config1(espdev, no_activity_const, random_rate_const_0, 0, 0);
        }

        write_config0(espdev, enable_const, max_tokens[i], refresh_rate_min_const[i],
                      refresh_rate_max_const[i]);
    }

    ////FFT setup/////
    #ifdef DEBUG
    printf("Setting up FFT accelerators\n");
    #endif
    mem_size = fft_init_params();
    // fft_probe(&espdevs_fft);

    // dev_f0 = &espdevs_fft[0];
    dev_f0->addr = ACC_ADDR_FFT0;
    setup_fft(dev_f0, gold_fft, mem_f0, ptable_f0);
    #ifdef DEBUG
    printf("FFT0 setup complete, address=0x%x\n", dev_f0->addr);
    #endif
    // dev_f1= &espdevs_fft[1];
    dev_f1->addr = ACC_ADDR_FFT1;
    setup_fft(dev_f1, gold_fft, mem_f1, ptable_f1);
    #ifdef DEBUG
    printf("FFT1 setup complete, address=0x%x\n", dev_f1->addr);
    #endif
    // dev_f2 = &espdevs_fft[2];
    dev_f2->addr = ACC_ADDR_FFT2;
    setup_fft(dev_f2, gold_fft, mem_f2, ptable_f2);
    #ifdef DEBUG
    printf("FFT2 setup complete, address=0x%x\n", dev_f2->addr);
    #endif
    // printf("FFT setup complete\n");

    // FFT is all set

    //////Viterbi setup//////

    #ifdef DEBUG
    printf("Starting viterbi init\n");
    #endif
    mem_size = vit_init_params();
    // vit_probe(&espdevs_viterbi);

    // dev_v0 = &espdevs_viterbi[0];
    dev_v0->addr = ACC_ADDR_VITERBI0;
    setup_viterbi(dev_v0, gold_vit, mem_v0, ptable_v0);
    #ifdef DEBUG
    printf("Viterbi0 setup complete, address=0x%x\n", dev_v0->addr);
    #endif
    // dev_v1= &espdevs_viterbi[1];
    // dev_v1.addr = ACC_ADDR_VITERBI2;
    dev_v1->addr = ACC_ADDR_VITERBI1;
    setup_viterbi(dev_v1, gold_vit, mem_v1, ptable_v1);
    #ifdef DEBUG
    printf("Viterbi1 setup complete, address=0x%x\n", dev_v1->addr);
    #endif
    // printf("Viterbi setup complete\n");

    //////NVDLA setup//////
    #ifdef DEBUG
    printf("NVDLA init and start\n");
    #endif
    // nvdla_probe(&espdevs_nvdla);
    // dev_n0 = &espdevs_nvdla[0];
    dev_n0->addr = ACC_ADDR_NVDLA;

    // Flush (customize coherence model here)
    if (coherence != ACC_COH_RECALL) esp_flush(coherence);

    // printf("Start accelerators\n");
    ///////Start accelerators//////
    iowrite32(dev_f0, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[1];
    // write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    printf("Started F0\n");
    #endif
    iowrite32(dev_v0, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[2];
    // write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    printf("Started V0\n");
    #endif
    iowrite32(dev_f1, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[3];
    // write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    printf("Started F1\n");
    #endif
    iowrite32(dev_v1, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[4];
    // write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    printf("Started V1\n");
    #endif
    iowrite32(dev_f2, CMD_REG, CMD_MASK_START);
    espdev = &espdevs[5];
    // write_config1(espdev, activity_const, random_rate_const, 0, 0);
    #ifdef DEBUG
    printf("Started F2\n");
    #endif

    cycles_start = get_counter();

    espdev = &espdevs[0];
    write_config1(espdev, activity_const, random_rate_const_0, 0,
                  0); // For NVDLA the activity flag is toggled manually
    run_nvdla(espdev, dev_n0, gold_nvdla, mem_n0, 0);
    write_config1(espdev, 0, random_rate_const_0, 0, 0);

    #ifdef DEBUG
    printf("NVDLA finished, address=0x%x\n", dev_n0->addr);
    #endif

    ////Wait for them to complete////
    printf("Running all accelerators... Start cycles = %u\n", cycles_start);
    // NVDLA is handled separately... We assume FFT and Viterbi terminate only after NVDLA
    while (!(done_f0 && done_f1 && done_f2 && done_v0 && done_v1)) {
        if (!done_f0) {
            done_f0 = ioread32(dev_f0, STATUS_REG);
            done_f0 &= STATUS_MASK_DONE;
        }
        if (!done_f1) {
            done_f1 = ioread32(dev_f1, STATUS_REG);
            done_f1 &= STATUS_MASK_DONE;
        }
        if (!done_f2) {
            done_f2 = ioread32(dev_f2, STATUS_REG);
            done_f2 &= STATUS_MASK_DONE;
        }
        if (!done_v0) {
            done_v0 = ioread32(dev_v0, STATUS_REG);
            done_v0 &= STATUS_MASK_DONE;
        }
        if (!done_v1) {
            done_v1 = ioread32(dev_v1, STATUS_REG);
            done_v1 &= STATUS_MASK_DONE;
        }

        if (done_f0 && !done_f0_before) {
            cycles_end_f0 = get_counter();
            espdev        = &espdevs[1];
            // write_config1(espdev, 0, random_rate_const, 0, 0);
            done_f0_before = done_f0;
    #ifdef DEBUG
            printf("Finished F0\n");
    #endif
        }
        if (done_v0 && !done_v0_before) {
            cycles_end_v0 = get_counter();
            espdev        = &espdevs[2];
            // write_config1(espdev, 0, random_rate_const, 0, 0);
            done_v0_before = done_v0;
    #ifdef DEBUG
            printf("Finished V0\n");
    #endif
        }
        if (done_f1 && !done_f1_before) {
            cycles_end_f1 = get_counter();
            espdev        = &espdevs[3];
            // write_config1(espdev, 0, random_rate_const, 0, 0);
            done_f1_before = done_f1;
    #ifdef DEBUG
            printf("Finished F1\n");
    #endif
        }
        if (done_v1 && !done_v1_before) {
            cycles_end_v1 = get_counter();
            espdev        = &espdevs[4];
            // write_config1(espdev, 0, random_rate_const, 0, 0);
            done_v1_before = done_v1;
    #ifdef DEBUG
            printf("Finished V1\n");
    #endif
        }
        if (done_f2 && !done_f2_before) {
            cycles_end_f2 = get_counter();
            espdev        = &espdevs[5];
            // write_config1(espdev, 0, random_rate_const, 0, 0);
            done_f2_before = done_f2;
    #ifdef DEBUG
            printf("Finished F2\n");
    #endif
        }
    }

    printf("  Viterbi Execution cycles : v0=%llu, v1=%llu\n", cycles_end_v0 - cycles_start,
           cycles_end_v1 - cycles_start);
    printf("  FFT Execution cycles : f0=%llu, f1=%llu, f2=%llu\n", cycles_end_f0 - cycles_start,
           cycles_end_f1 - cycles_start, cycles_end_f2 - cycles_start);
    printf(" Simulation has completed \n");
    #ifdef DEBUG
    printf("  validating...\n");

    // Validation Viterbi
    errors = vit_validate_buf(&mem_v0[out_offset], gold_vit);
    if (errors) printf("  ... FAIL Viterbi\n");
    else
        printf("  ... PASS Viterbi\n");

    // Validation FFT
    errors = fft_validate_buf(&mem_f0[out_offset], gold_fft);
    if ((errors / len) > ERROR_COUNT_TH) printf("  ... FAIL FFT\n");
    else
        printf("  ... PASS FFT\n");
    #endif
    printf("Completed Test 1\n");
#endif

    return 0;
}
