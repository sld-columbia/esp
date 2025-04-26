/* Copyright (c) 2011-2023 Columbia University, System Level Design Group */
/* SPDX-License-Identifier: Apache-2.0 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <monitors.h>

#include "soc_defs.h"
#include "soc_locs.h"

#include "dfs_mac.h"
#include "mac.h"

#define NUM_FREQUENCIES 5
//#define RUN_LOOP

#define SLD_ACC_TILE_1 0x98
#define DEV_NAME_MAC "sld,mac_vivado"

#define DCO_CC_REG_ADDR 408

int main(int argc, char * argv[])
{
	  int i;
	  int k;
	  int n;
	  int ndev;
	  unsigned done;
	  unsigned high_time;
	  unsigned errors = 0;
	  unsigned coherence = ACC_COH_NONE;
	  struct esp_device *espdevs_tile_1;
	  struct esp_device *dev_tile_1;
	  unsigned **ptable_mac;
    token_t *mem_mac, *mem_gold_mac;

    printf("Hello from dfs_mac\n");

    // cycle monitor
    esp_monitor_args_t mon_args;
    const int CPU_TILE_IDX = 1;
    unsigned int cycles_start, cycles_end, cycles_diff;
    mon_args.read_mode = ESP_MON_READ_SINGLE;
    mon_args.tile_index = CPU_TILE_IDX;
    mon_args.mon_index = MON_DVFS_BASE_INDEX + 3;

    // MAC
    if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
        in_words_adj = mac_len * mac_vec;
        out_words_adj = mac_vec;
    } else {
        in_words_adj = round_up(mac_len * mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
        out_words_adj = round_up(mac_vec, DMA_WORD_PER_BEAT(sizeof(token_t)));
    }
    in_len_mac = in_words_adj * (mac_n);
    out_len_mac = out_words_adj * (mac_n);
    in_size_mac = in_len_mac * sizeof(token_t);
    out_size_mac = out_len_mac * sizeof(token_t);
    out_offset_mac  = in_len_mac;
    mem_size_mac = (out_offset_mac * sizeof(token_t)) + out_size_mac;

    for(k = 0; k < 1; k++) {
        // half of the clock divider value
        //   output clock is high then low for (k+1) cycles of the PLL's reference
        //   divide by (k+1)+(k+1) = 2k+2
        //   fout = fin / (2k+2)
        high_time = (k+1) << 1;

        // MAC accelerator section
        // Probing
        printf("  Probing... MAC\n");

        // Search for the device
        printf("Scanning device tree... \n");

        ndev = probe(&espdevs_tile_1, VENDOR_SLD, SLD_ACC_TILE_1, DEV_NAME_MAC);
        if (ndev == 0) {
            printf("mac not found\n");
            return 0;
        }

        for (n = 0; n < ndev; n++) {

            printf("**************** %s.%d ****************\n", DEV_NAME, n);

            dev_tile_1 = &espdevs_tile_1[n];

            for (int z = 0; z < NUM_FREQUENCIES; z++) {

            printf("Writing register\n");
            //iowrite32(dev_tile_1, CMD_REG, 0);
            //iowrite32(dev_tile_1, DCO_CC_REG_ADDR, (2 & 0x3f));
            printf("Done writing register\n");
            printf("Reading register\n");
            //int test_val = ioread32(dev_tile_1, PT_NCHUNK_MAX_REG);
            int test_val = ioread32(dev_tile_1, DCO_CC_REG_ADDR);
            printf("Read register and got %d\n", test_val);
            printf("Writing register\n");
            //iowrite32(dev_tile_1, CMD_REG, 0);
            //iowrite32(dev_tile_1, DCO_CC_REG_ADDR, (4 & 0x3f));
            printf("Done writing register\n");
            printf("Reading register\n");
            //int test_val = ioread32(dev_tile_1, PT_NCHUNK_MAX_REG);
            test_val = ioread32(dev_tile_1, DCO_CC_REG_ADDR);
            printf("Read register and got %d\n", test_val);

            // Check DMA capabilities
            printf("Checking DMA\n");
            /*if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) == 0) {
                printf("  -> scatter-gather DMA is disabled. Abort.\n");
                return 0;
            }

            if (ioread32(dev_tile_1, PT_NCHUNK_MAX_REG) < NCHUNK(mem_size_mac)) {
                printf("  -> Not enough TLB entries available. Abort.\n");
                return 0;
            }*/

            // Allocate memory
            printf("Allocating memory\n");
            mem_gold_mac = aligned_malloc(out_size_mac);
            mem_mac = aligned_malloc(mem_size_mac);
            printf("  memory buffer base-address = %p\n", mem_mac);

            // Alocate and populate page table
            ptable_mac = aligned_malloc(NCHUNK(mem_size_mac) * sizeof(unsigned *));
            for (i = 0; i < NCHUNK(mem_size_mac); i++)
                ptable_mac[i] = (unsigned *) &mem_mac[i * (CHUNK_SIZE_MAC / sizeof(token_t))];

            printf("  ptable = %p\n", ptable_mac);
            printf("  nchunk = %lu\n", NCHUNK(mem_size_mac));

    #ifndef __riscv
            for (coherence = ACC_COH_NONE; coherence <= ACC_COH_RECALL; coherence++) {
    #else
            {
                /* TODO: Restore full test once ESP caches are integrated */
                coherence = ACC_COH_NONE;
    #endif
                printf("  --------------------\n");
                printf("  Generate input...\n");
                iowrite32(dev_tile_1, CMD_REG, 0);
                init_buf_mac(mem_mac, mem_gold_mac);
                printf("  Done generating input\n");

                // Pass common configuration parameters

                //iowrite32(dev_tile_1, SELECT_REG, ioread32(dev_tile_1, DEVID_REG));
                printf("Writing basic configuration registers\n");
                iowrite32(dev_tile_1, COHERENCE_REG, coherence);

    #ifndef __sparc
                iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned long long) ptable_mac);
    #else
                iowrite32(dev_tile_1, PT_ADDRESS_REG, (unsigned) ptable_mac);
    #endif
                iowrite32(dev_tile_1, PT_NCHUNK_REG, NCHUNK(mem_size_mac));
                iowrite32(dev_tile_1, PT_SHIFT_REG, CHUNK_SHIFT_MAC);

                // Use the following if input and output data are not allocated at the default offsets
                iowrite32(dev_tile_1, SRC_OFFSET_REG, 0x0);
                iowrite32(dev_tile_1, DST_OFFSET_REG, 0x0);
                printf("Done writing basic configuration registers\n");

                // MG configure clock frequency
                printf("Writing DCO\n");
                /*
                 * Address
                 *   [8:7] = "11"
                 *   [6:2] = ESP_CSR_DCO_NOC_CFG_ADDR = 6 = "00110"
                 *   [1:0] = 0 = "00"
                 *   0b110011000 = 408
                 *
                 * Write
                 * config_r(ESP_CSR_DCO_CFG_MSB downto ESP_CSR_DCO_CFG_LSB) <=
                apbi.pwdata(ESP_CSR_DCO_CFG_MSB - ESP_CSR_DCO_CFG_LSB downto 0);
                 *   [34:11] = apb_wdata[23:0]
                 *
                 * Data
                 * dco_cc_sel   <= tile_config_int(ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 downto ESP_CSR_DCO_CFG_MSB - DCO_CFG_LPDDR_CTRL_BITS - 11 - 5);
                 *   [34-12-11:34-12-11-5] = [11:6]
                 *
                 * ESP_CSR_DCO_NOC_CFG_MSB = 34
                 * ESP_CSR_DCO_NOC_CFG_LSB = 16
                 * DCO_CFG_LPDDR_CTRL_BITS = 12
                   constant ESP_CSR_DCO_NOC_CFG_ADDR : integer range 0 to 31 := 6;
  constant ESP_CSR_DCO_NOC_CFG_LSB : integer range 0 to ESP_CSR_WIDTH - 1 := 16;
  constant ESP_CSR_DCO_NOC_CFG_MSB : integer range 0 to ESP_CSR_WIDTH - 1 := 34;

                 */
                high_time = z+2;
                test_val = ioread32(dev_tile_1, DCO_CC_REG_ADDR);
                printf("Read register and got %d\n", test_val);
                iowrite32(dev_tile_1, DCO_CC_REG_ADDR, (high_time & 0x3f));
                printf("Done writing DCO (high_time = %u)\n", high_time);
                test_val = ioread32(dev_tile_1, DCO_CC_REG_ADDR);
                printf("Read register and got %d\n", test_val);

                // Pass accelerator-specific configuration parameters
                /* <<--regs-config-->> */
                printf("Writing specific configuration registers\n");
                iowrite32(dev_tile_1, MAC_MAC_N_REG, mac_n);
                iowrite32(dev_tile_1, MAC_MAC_VEC_REG, mac_vec);
                iowrite32(dev_tile_1, MAC_MAC_LEN_REG, mac_len);
                printf("Done writing configuration registers\n");

                // Flush (customize coherence model here)
                //esp_flush(coherence);

                // Start accelerators
                printf("  Start...\n");
                cycles_start = esp_monitor(mon_args, NULL);
                //for (int z = 0; z < 1; z++) {
                    iowrite32(dev_tile_1, CMD_REG, CMD_MASK_START);

                    // Wait for completion
                    done = 0;
                    int iterations;
                    for (iterations = 0; iterations < 1000000 && !done; iterations++) {
                        while (!done) {
                            done = ioread32(dev_tile_1, STATUS_REG);
                            done &= STATUS_MASK_DONE;
                        }
                    }
                    iowrite32(dev_tile_1, CMD_REG, 0x0);
                    if (iterations == 1000000) {
                        printf("Warning: timed out at 1000000 iterations\n");
                    }
                //}
                cycles_end = esp_monitor(mon_args, NULL);
                cycles_diff = sub_monitor_vals(cycles_start, cycles_end);

                printf("  Done\n");
                printf("  validating...\n");

                /* Validation */
                errors = validate_buf_mac(&mem_mac[out_offset_mac], mem_gold_mac);
                if (errors)
                    printf("  ... FAIL\n");
                else
                    printf("  ... PASS\n");
                printf("  ... latency of calculation was %u (%u - %u) core cycles for a high_time of %u\n", cycles_diff, cycles_end, cycles_start, high_time);
            }
            aligned_free(ptable_mac);
            aligned_free(mem_mac);
            aligned_free(mem_gold_mac);
            }
        }

    }
    return 0;
}
