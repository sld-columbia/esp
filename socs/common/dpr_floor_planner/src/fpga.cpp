/*#include "fpga.h"

zynq_7010::zynq_7010()
{
    zynq_7010::initialize_clk_reg();
}

void zynq_7010::initialize_clk_reg()
{
    unsigned int i = 0;

    for(i = 0; i < ZYNQ_CLK_REG ;  i++) {
     init_clk_reg(i, clk_reg_pos[i], clb_per_col,
                bram_per_col, dsp_per_col,
                bram_in_reg[i], dsp_in_reg[i],
                bram_pos[i], dsp_pos[i]);
    }
}

virtex::virtex()
{
    virtex::initialize_clk_reg();
}

void virtex::initialize_clk_reg()
{
    unsigned int i = 0;

    for(i = 0; i < VIRTEX_CLK_REG ;  i++) {
    init_clk_reg(i, clk_reg_pos[i], clb_per_col,
                bram_per_col, dsp_per_col,
                bram_in_reg[i], dsp_in_reg[i],
                bram_pos[i], dsp_pos[i]);
    }
}

virtex_5::virtex_5()
{
    virtex_5::initialize_clk_reg();
}

void virtex_5::initialize_clk_reg()
{
    unsigned int i = 0;

    for(i = 0; i < VIRTEX_5_CLK_REG ;  i++) {
    init_clk_reg(i, clk_reg_pos[i], clb_per_col,
                bram_per_col, dsp_per_col,
                bram_in_reg[i], dsp_in_reg[i],
                bram_pos[i], dsp_pos[i]);
    }
}

pynq::pynq()
{
    pynq::initialize_clk_reg();
}

void pynq::initialize_clk_reg()
{
    unsigned int i = 0;

    for(i = 0; i < PYNQ_CLK_REG ;  i++) {
    init_clk_reg(i, clk_reg_pos[i], clb_per_col,
                bram_per_col, dsp_per_col,
                bram_in_reg[i], dsp_in_reg[i],
                bram_pos[i], dsp_pos[i]);
    }
}

*/
