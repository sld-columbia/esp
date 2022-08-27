#include "fine_grained.h"
#include "zynq.h"

class zynq_fine_grained{
public:
    finegrained_res_description fg[ZYNQ_WIDTH] =   {{CLB, 0, 1},
                                                    {CLB,  2, 3},
                                                    {CLB,  4, 5},
                                                    {BRAM, 0, 0},
                                                    {CLB,  6, 7},
                                                    {CLB, 8, 9},
                                                    {DSP, 0, 0},
                                                    {CLB, 10, 11},
                                                    {CLB, 12, 13},
                                                    {FBDN, 1, 0},
                                                    {CLB, 14, 15},
                                                    {CLB, 16, 17},
                                                    {CLB, 18, 19},
                                                    {CLB, 20, 21},
                                                    {CENTRAL_CLK, 0 ,1},
                                                    {CLB, 22, 23},
                                                    {CLB, 24, 25},
                                                    {BRAM, 1, 1},
                                                    {CLB, 26, 27},
                                                    {CLB, 28, 29},
                                                    {CLB, 30, 31},
                                                    {DSP, 1, 1},
                                                    {CLB, 32, 33},
                                                    {CLB, 34, 35},
                                                    {BRAM, 2, 2},
                                                    {CLB, 36, 37},
                                                    {CLB, 38, 39},
                                                    {CLB, 40, 41},
                                                    {CLB, 42, 43}};

    void init_fine_grained();
    zynq_fine_grained();
};
