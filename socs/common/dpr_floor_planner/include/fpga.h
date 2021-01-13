#ifndef ZYNQ_H
#define ZYNQ_H

#define MAX_SLOTS 10
#define CLB  0
#define BRAM 1
#define DSP  2

typedef struct {
    int x;
    int y;
    int w;
    int h;
}pos;

typedef struct {
    pos clk_reg_pos;
    int clb_per_column;
    int bram_per_column;
    int dsp_per_column;
    int clb_num;
    int bram_num;
    int dsp_num;
    int forbidden_num;
    int *bram_pos;
    int *dsp_pos;
}fpga_clk_reg;

#define init_clk_reg(id, pos, clb, bram, dsp, num_bram, num_dsp,\
                               pos_bram, pos_dsp) \
                               clk_reg[id].clk_reg_pos = pos;    \
                               clk_reg[id].clb_per_column = clb;\
                               clk_reg[id].bram_per_column = bram; \
                               clk_reg[id].dsp_per_column = dsp;  \
                               clk_reg[id].bram_num = num_bram;  \
                               clk_reg[id].dsp_num = num_dsp;\
                               clk_reg[id].bram_pos = pos_bram;\
                               clk_reg[id].dsp_pos = pos_dsp;

#endif
