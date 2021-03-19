// #include "validation.hpp"
// #include "gemm_pv.h"
#include "double_matrix_t.h"
#define M_DIMS 3

void gemm_pvt(int l_n,int prev_soft,float*layer_in_sw,float* layer_in_hw,float*out,float* W,float*bias, bool relu,int wr,int wc,int ws);
