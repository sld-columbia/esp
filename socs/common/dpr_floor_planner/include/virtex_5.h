//parameters for virtex_5
#define VIRTEX_5_CLB_TOT 8140
#define VIRTEX_5_BRAM_TOT 160
#define VIRTEX_5_DSP_TOT 64
#define VIRTEX_5_CLB_MIN 10
#define VIRTEX_5_BRAM_MIN 0
#define VIRTEX_5_DSP_MIN 0
#define VIRTEX_5_CLK_REG 16
#define VIRTEX_5_FORBIDDEN 2
#define VIRTEX_5_NUM_ROWS 4
#define VIRTEX_5_WIDTH 62
#define VIRTEX_5_CLB_PER_TILE 20
#define VIRTEX_5_BRAM_PER_TILE 4
#define VIRTEX_5_DSP_PER_TILE 8
#define VIRTEX_5_CLK00_BRAM 2
#define VIRTEX_5_CLK01_BRAM 2
#define VIRTEX_5_CLK02_BRAM 2
#define VIRTEX_5_CLK03_BRAM 2
#define VIRTEX_5_CLK04_BRAM 2
#define VIRTEX_5_CLK05_BRAM 2
#define VIRTEX_5_CLK06_BRAM 2
#define VIRTEX_5_CLK07_BRAM 2
#define VIRTEX_5_CLK10_BRAM 3
#define VIRTEX_5_CLK11_BRAM 3
#define VIRTEX_5_CLK12_BRAM 3
#define VIRTEX_5_CLK13_BRAM 3
#define VIRTEX_5_CLK14_BRAM 3
#define VIRTEX_5_CLK15_BRAM 3
#define VIRTEX_5_CLK16_BRAM 3
#define VIRTEX_5_CLK17_BRAM 3
#define VIRTEX_5_CLK00_DSP 1
#define VIRTEX_5_CLK01_DSP 1
#define VIRTEX_5_CLK02_DSP 1
#define VIRTEX_5_CLK03_DSP 1
#define VIRTEX_5_CLK04_DSP 1
#define VIRTEX_5_CLK05_DSP 1
#define VIRTEX_5_CLK06_DSP 1
#define VIRTEX_5_CLK07_DSP 1
#define VIRTEX_5_CLK10_DSP 0
#define VIRTEX_5_CLK11_DSP 0
#define VIRTEX_5_CLK12_DSP 0
#define VIRTEX_5_CLK13_DSP 0
#define VIRTEX_5_CLK14_DSP 0
#define VIRTEX_5_CLK15_DSP 0
#define VIRTEX_5_CLK16_DSP 0
#define VIRTEX_5_CLK17_DSP 0


class virtex_5
{
public:
    int num_clk_reg = VIRTEX_5_CLK_REG;
    fpga_clk_reg clk_reg[VIRTEX_5_CLK_REG];
    pos clk_reg_pos [VIRTEX_5_CLK_REG] ={{0,  140, 27, 20},
                                         {0,  120, 27, 20},
                                         {0,  100, 27, 20},
                                         {0,  80, 27, 20},
                                         {0,  60, 27, 20},
                                         {0,  40, 27, 20},
                                         {0,  20,  27, 20},
                                         {0,  0,  27, 20},
                                         {28, 140, 34, 20},
                                         {28, 120, 34, 20},
                                         {28, 100, 34, 20},
                                         {28, 80, 34, 20},
                                         {28, 60, 34, 20},
                                         {28, 40, 34, 20},
                                         {28, 20, 34, 20},
                                         {28, 0, 34, 20}};


    int clb_per_col  =  VIRTEX_5_CLB_PER_TILE;
    int bram_per_col =  VIRTEX_5_BRAM_PER_TILE;
    int dsp_per_col  =  VIRTEX_5_DSP_PER_TILE;

    unsigned long num_rows = VIRTEX_5_NUM_ROWS;
    unsigned long width = VIRTEX_5_WIDTH;

    int bram_in_reg[VIRTEX_5_CLK_REG] = {2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3};

    int bram_pos[VIRTEX_5_CLK_REG][5] = {{4, 15}, {4, 15}, {4, 15}, {4, 15}, {4, 15},
                                         {4, 15}, {4, 15}, {4, 15}, {40, 51, 62},
                                         {40, 51, 62}, {40, 51, 62}, {40, 51, 62},
                                         {40, 51, 62}, {40, 51, 62}, {40, 51, 62},
                                         {40, 51, 62}};

    int dsp_in_reg[VIRTEX_5_CLK_REG] = {1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0};

    int dsp_pos[VIRTEX_5_CLK_REG][5] = {{18}, {18}, {18}, {18},{18} ,{18}, {18}, {18},
                                        };

    unsigned long num_forbidden_slots = VIRTEX_5_FORBIDDEN;
    pos forbidden_pos[VIRTEX_5_FORBIDDEN] = {{56, 0,  1, 80},
                                             {61, 20, 1, 30}};

    void initialize_clk_reg();
    virtex_5();

};
