#include "fpga.h"

//parameters for pynq
#define PYNQ_CLK_REG 6
#define PYNQ_WIDTH 70
#define PYNQ_NUM_ROWS 10
#define PYNQ_FORBIDDEN 3
#define PYNQ_CLB_PER_TILE 50
#define PYNQ_BRAM_PER_TILE 10
#define PYNQ_DSP_PER_TILE 20
#define PYNQ_CLB_TOT  6650 
#define PYNQ_BRAM_TOT 140
#define PYNQ_DSP_TOT  220


class pynq
{
public:
    int num_clk_reg = PYNQ_CLK_REG;
    fpga_clk_reg clk_reg[PYNQ_CLK_REG];
    pos clk_reg_pos [PYNQ_CLK_REG] = {{0,  0,  31, 50},
                                      {0,  50, 31, 50},
                                      {0,  100, 31, 50},
                                      {32, 0,  38, 50},
                                      {32, 50, 38, 50},
                                      {32, 100, 38, 50}};

    int clb_per_col  = PYNQ_CLB_PER_TILE;
    int bram_per_col = PYNQ_BRAM_PER_TILE;
    int dsp_per_col  = PYNQ_DSP_PER_TILE;

    unsigned long num_rows = PYNQ_NUM_ROWS;
    unsigned long width    = PYNQ_WIDTH;

    int bram_in_reg[PYNQ_CLK_REG]  = {1, 1, 3, 3, 3, 3};
    int bram_pos[PYNQ_CLK_REG][10] = {{21, 0, 0}, {21, 0, 0}, {5, 16, 21},
                                     {35, 55, 66}, {35, 55, 66}, {35, 55, 66}};

    int dsp_in_reg[PYNQ_CLK_REG] = {1, 1, 3, 2, 2, 2};
    int dsp_pos[PYNQ_CLK_REG][3] = {{24, 0, 0},
                                    {24, 0, 0},
                                    {8, 13, 24},
                                    {58, 63, 0},
                                    {58, 63, 0},
                                    {58, 63, 0}};

    unsigned long num_forbidden_slots = PYNQ_FORBIDDEN;
    pos forbidden_pos[PYNQ_FORBIDDEN] = {{0, 10, 17, 20},
                                        {42, 10, 6,  20},
                                        {47, 0,  2,  10}};

    void initialize_clk_reg();
    pynq();
};


