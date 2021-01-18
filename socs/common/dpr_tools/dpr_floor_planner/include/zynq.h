#ifndef ZYNQ_DEF_H
#define ZYNQ_DEF_H

#include "fpga.h"

//parameters for zynq
#define ZYNQ_CLB_TOT 2200
#define ZYNQ_BRAM_TOT 60
#define ZYNQ_DSP_TOT 80
#define ZYNQ_CLB_MIN 10
#define ZYNQ_BRAM_MIN 0
#define ZYNQ_DSP_MIN 0
#define ZYNQ_FORBIDDEN 2
#define ZYNQ_NUM_ROWS 10
#define ZYNQ_WIDTH 29
#define ZYNQ_CLK_REG 4
#define ZYNQ_CLK00_BRAM 1
#define ZYNQ_CLK01_BRAM 1
#define ZYNQ_CLK10_BRAM 2
#define ZYNQ_CLK11_BRAM 2
#define ZYNQ_CLK00_DSP 1
#define ZYNQ_CLK01_DSP 1
#define ZYNQ_CLK10_DSP 1 
#define ZYNQ_CLK11_DSP 1
#define ZYNQ_CLB_PER_TILE 50
#define ZYNQ_BRAM_PER_TILE 10
#define ZYNQ_DSP_PER_TILE 20

class zynq_7010
{
public: 
    int clb_per_col  = ZYNQ_CLB_PER_TILE;
    int bram_per_col = ZYNQ_BRAM_PER_TILE;
    int dsp_per_col  = ZYNQ_DSP_PER_TILE;
    int num_clk_reg =  ZYNQ_CLK_REG;

    fpga_clk_reg clk_reg[ZYNQ_CLK_REG];
    pos clk_reg_pos [ZYNQ_CLK_REG] = {{0,  0,  14, 50},
                                      {0,  50, 14, 50},
                                      {15, 0,  14, 50},
                                      {15, 50, 14, 50}};

    unsigned long num_rows = ZYNQ_NUM_ROWS;
    unsigned long width    = ZYNQ_WIDTH;

    int bram_in_reg[ZYNQ_CLK_REG] =  {1, 1, 2, 2};
    int bram_pos[ZYNQ_CLK_REG][10] = {{4, 0, 0},  {4, 0, 0},
                                     {18, 25, 0}, {18, 25, 0}};

    int dsp_in_reg[ZYNQ_CLK_REG] = {1, 1, 1, 1};
    int dsp_pos[ZYNQ_CLK_REG][3] = {{7, 0, 0},
                                    {7, 0, 0},
                                    {22, 0, 0},
                                    {22, 0, 0}};

    unsigned long num_forbidden_slots = ZYNQ_FORBIDDEN;
    pos forbidden_pos[ZYNQ_FORBIDDEN] = {{9, 0, 1, 20},
                                        {14, 0, 1, 20}};

    void initialize_clk_reg();
    zynq_7010();
};

#endif
