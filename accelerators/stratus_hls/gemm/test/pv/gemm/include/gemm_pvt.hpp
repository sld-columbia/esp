#include "double_matrix_t.h"

void gemm_pvt(
	int l_n,
	float* layer_node,
	float* layer_bias,
	bool relu,
	float*w,
	size_t wr,
	size_t wc,
	size_t ws,
	float* out,
	float* gold);
