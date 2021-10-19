/* <<--functions-->> */
#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

	float CP_res[16] = {0};

	float c_run_hiwa(unsigned p, unsigned q, float* X, float* Y,
			float gamma, unsigned maxiter, float outputX[], float outputY[],
			float C[], float K[], float a[], float b[]);

	void reshape_to_C_mat_with_R2(float* y, float* x, float* Y, float* X,
				unsigned q, unsigned p, float* C);

	void c_run_svd(float inputP, float* inputX, float* inputY, float* T);

	float total_sinkhorn_clean(unsigned p, unsigned q, float* X, float* Y, float* P,
				float gamma, unsigned maxiter, float outputX[],
				float outputY[], float C[],float K[], float a[], float b[], float b_prev[]);

	void reshape_to_C_mat_with_RK(float* y, float* x, float* Y, float* X,
				unsigned q, unsigned p, float* C, float* K, float gamma);

	float sinkhorn_kernel_clean(unsigned iter, unsigned p, unsigned q,
				float* a, float* b, float* b_prev,
				float* K, float* C, float* P);

	void sink_kernel_operation(float* a, unsigned p, unsigned q, float* K, float* b, bool transpose);

	void mult_diag_mat_diag(float* diag_vec_1, float* K, float* diag_vec_2, float* R, unsigned m, unsigned n);

	float mult_sum_mats_elementwise(float* C, float* P, unsigned rows, unsigned cols);

	void* c_hiwa_tot(void* pq);

#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */
