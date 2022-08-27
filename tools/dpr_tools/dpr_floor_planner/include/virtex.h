//parameters for virtex_7
#define VIRTEX_CLB_TOT 21487
#define VIRTEX_BRAM_TOT 500
#define VIRTEX_DSP_TOT 900
#define VIRTEX_CLB_MIN 10
#define VIRTEX_BRAM_MIN 0
#define VIRTEX_DSP_MIN 0
#define VIRTEX_FORBIDDEN 4
#define VIRTEX_NUM_ROWS 10
#define VIRTEX_WIDTH 103
#define VIRTEX_CLK_REG 14
#define VIRTEX_CLB_PER_TILE 50
#define VIRTEX_BRAM_PER_TILE 10
#define VIRTEX_DSP_PER_TILE 20
//bram descritpion on virtex
#define VIRTEX_CLK00_BRAM 4
#define VIRTEX_CLK01_BRAM 4
#define VIRTEX_CLK02_BRAM 4
#define VIRTEX_CLK03_BRAM 4
#define VIRTEX_CLK04_BRAM 4
#define VIRTEX_CLK05_BRAM 2
#define VIRTEX_CLK06_BRAM 2
#define VIRTEX_CLK10_BRAM 4
#define VIRTEX_CLK11_BRAM 4
#define VIRTEX_CLK12_BRAM 4
#define VIRTEX_CLK13_BRAM 4
#define VIRTEX_CLK14_BRAM 5
#define VIRTEX_CLK15_BRAM 5
#define VIRTEX_CLK16_BRAM 5
#define VIRTEX_CLK00_DSP 4
#define VIRTEX_CLK01_DSP 4
#define VIRTEX_CLK02_DSP 4
#define VIRTEX_CLK03_DSP 4
#define VIRTEX_CLK04_DSP 4
#define VIRTEX_CLK05_DSP 2
#define VIRTEX_CLK06_DSP 2
#define VIRTEX_CLK10_DSP 3
#define VIRTEX_CLK11_DSP 3
#define VIRTEX_CLK12_DSP 3
#define VIRTEX_CLK13_DSP 3
#define VIRTEX_CLK14_DSP 3
#define VIRTEX_CLK15_DSP 3
#define VIRTEX_CLK16_DSP 3


class virtex
{
public:
    unsigned long num_clk_reg = VIRTEX_CLK_REG;
    fpga_clk_reg clk_reg[VIRTEX_CLK_REG];
    pos clk_reg_pos [VIRTEX_CLK_REG]= {{0,  300, 54, 50},
                                       {0,  250, 54, 50},
                                       {0,  200, 54, 50},
                                       {0,  150, 54, 50},
                                       {0,  100, 54, 50},
                                       {0,  50,  54, 50},
                                       {0,  0,   54, 50},
                                       {55, 300, 54, 55},
                                       {55, 250, 54, 55},
                                       {55, 200, 54, 55},
                                       {55, 150, 54, 55},
                                       {55, 100, 54, 55},
                                       {55, 50,  54, 55},
                                       {55, 0,   54, 55}};

    int clb_per_col  = VIRTEX_CLB_PER_TILE;
    int bram_per_col = VIRTEX_BRAM_PER_TILE;
    int dsp_per_col  = VIRTEX_DSP_PER_TILE;

    unsigned long num_rows = VIRTEX_NUM_ROWS;
    unsigned long width = VIRTEX_WIDTH;

    int bram_in_reg[VIRTEX_CLK_REG] = {4, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 5, 5, 5};
    int bram_pos[VIRTEX_CLK_REG][5] = {{4, 15, 20, 35}, {4, 15, 20, 35}, {4, 15, 20, 35},
                                        {4, 15, 20, 35}, {4, 15, 20, 35},
                                        {20, 35}, {20, 35}, {56, 73, 86, 92},
                                        {56, 73, 86, 92}, {56, 73, 86, 92},
                                        {56, 73, 86, 92}, {56, 73, 86, 92, 99},
                                        {56, 73, 86, 92, 99}, {56, 73, 86, 92, 99}
                                      };

    int dsp_in_reg[VIRTEX_CLK_REG] = {4, 4, 4, 4, 4, 2, 2, 3, 3, 3, 3, 3, 3, 3};
    int dsp_pos[VIRTEX_CLK_REG][5] = {{7, 12, 23, 32}, {7, 12, 23, 32}, {7, 12, 23, 32},
                                      {7, 12, 23, 32}, {7, 12, 23, 32}, {23, 32},
                                      {23, 32}, {59, 83, 95}, {59, 83, 95},
                                      {59, 83, 95}, {59, 83, 95}, {59, 83, 95},
                                      {59, 83, 95}, {59, 83, 95}};

    unsigned long num_forbidden_slots = VIRTEX_FORBIDDEN;
    pos forbidden_pos[VIRTEX_FORBIDDEN] = {{0,   50,  18, 20},
                                           {74,  50,  8,  20},
                                           {89,  30,  4,  10},
                                           {104, 0,   5,  40}};

    void initialize_clk_reg();
    virtex();
};


