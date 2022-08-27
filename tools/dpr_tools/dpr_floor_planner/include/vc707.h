#ifndef VC707_DEF_H
#define VC707_DEF_H

#include "fpga.h" 

#define VC707_CLK_REG 14
#define VC707_WIDTH 152
#define VC707_NUM_ROWS 10
#define VC707_FORBIDDEN 3
#define VC707_CLB_PER_TILE 50
#define VC707_BRAM_PER_TILE 10
#define VC707_DSP_PER_TILE 20 
#define VC707_CLB_TOT  45525
#define VC707_BRAM_TOT  1030
#define VC707_DSP_TOT  2800

class vc707
{
public:
    int clb_per_tile  = VC707_CLB_PER_TILE;
    int bram_per_tile = VC707_BRAM_PER_TILE;
    int dsp_per_tile  = VC707_DSP_PER_TILE;
    int num_clk_reg =  VC707_CLK_REG;
    unsigned long width    = VC707_WIDTH;
//    void initialize_clk_reg();
    vc707();
};
#endif
