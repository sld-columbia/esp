#include "libesp.h"
#include "cfg.h"
#include "c_run.h"

static unsigned inX_words_adj;
static unsigned inY_words_adj;
static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned inX_len;
static unsigned inY_len;
static unsigned in_len;
static unsigned out_len;
static unsigned inX_size;
static unsigned inY_size;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

static unsigned in_words_adj_svd;
static unsigned out_words_adj_svd;
static unsigned in_len_svd;
static unsigned out_len_svd;
static unsigned in_size_svd;
static unsigned out_size_svd;
static unsigned out_offset_svd;
static unsigned size_svd;


/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	int j;
	float sum = 0;
	unsigned errors = 0;

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < p_rows * q_cols + 1; j++)
		{
			float val = fixed32_to_float(out[i * out_words_adj + j], 11);
			if (j != p_rows * q_cols) // P sum
				sum += val;
			else
			{
				float CP_val = fixed32_to_float(gold[i * out_words_adj + j],11);
				if (CP_val != val) // CP_sum
				{
					float CP_error = 100*(CP_val-val)/CP_val;
					printf("CP_sum is: %f\n", val);
					printf("Expected CP_sum is: %f\n", CP_val);
					if (CP_error > 3 || CP_error < -3)
					{
						printf("CP error is bigger than 3 percent - %f.\n", CP_error);
						errors++;
					}
					else
						printf("CP error is smaller than 3 percent - Passed.\n");
				}
			}
		}

		if (sum != 1.0)
		{
			float P_error = 100*(1.0-sum)/1.0;

			printf("P sum is: %f\n", sum);
			if (P_error > 3)
			{
				printf("P error is bigger than 3 percent.\n");
				errors++;
			}

		}
	}

	return errors;
}


static int validate_final(token_t *out_svd, token_t *out_hiwa, float* final_svd, float* final_hiwa)
{
	int i, j;
	unsigned errors = 0;
	float MAE, MAE_sum, num;
	MAE_sum = 0.0;

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < m_rows*m_rows; j++)
		{
			float val_out, val_gold;
			val_out = fixed32_to_float(out_svd[i * out_words_adj_svd + j], 11);
			val_gold = final_svd[i * out_words_adj_svd + j];

			MAE = (val_out - val_gold) / val_gold;

			printf("R: %d: out = %f , gold = %f \n", j, val_out, val_gold);

			if (MAE < -0.01 || MAE > 0.01)
				errors++;

		}

		for (j = 0; j < p_rows*q_cols; j++)
		{
			float val_out, val_gold;
			val_out = fixed32_to_float(out_hiwa[i * out_words_adj_svd + j], 11);
			val_gold = final_hiwa[i * out_words_adj_svd + j];

			MAE = (val_out - val_gold) / val_gold;

			//printf("%d: out = %f , gold = %f \n", j, val_out, val_gold);

			MAE_sum += pow(MAE, 2);
			if (MAE < -0.1 || MAE > 0.1)
			{
				printf("Q: %d: out = %.10f , gold = %.10f \n", j, val_out, val_gold);
				//errors++;
			}

		}

	}

	num = p_rows*q_cols;
	printf("Total error in Q is %f. \n", MAE_sum / num);
	if (MAE_sum / num > 0.01)
	{
		errors++;
	}

	printf("Sum of errors is %d \n", errors);


	return errors;
}

/* User-defined code */
static int validate_buffer_svd(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;
	float MAE, MAE_sum, num;
	MAE_sum = 0.0;

	for (i = 0; i < 1; i++)
		for (j = 0; j < m_rows*m_rows+m_rows*p_rows/*+m_rows*q_cols*/; j++)
		{

			float val_out, val_gold;
			val_out = fixed32_to_float(out[i * out_words_adj_svd + j], 11);
			val_gold = fixed32_to_float(gold[i * out_words_adj_svd + j], 11);

			MAE = (val_out - val_gold) / val_gold;

			//printf("%d: out = %f , gold = %f \n", j, out[j], gold[j]);

			MAE_sum += pow(MAE,2);
			if (MAE < -0.15 || MAE > 0.15)
				errors++;

		}

	num = m_rows*m_rows+p_rows*m_rows;
	if (MAE_sum / num > 0.01)
		errors++;

	printf("Sum of errors is %d \n", errors);

	return errors;
}

/* User-defined code */
static void init_buffer(token_t *in, token_t * gold, token_t * inX, token_t * inY)
{
	int i;
	int j;
	int k;

	printf("\nInitializing buffer\n");

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < p_rows * m_rows; j++)
		{
			in[i * in_words_adj + j] = inX[j];
		}

		//j = inX_len;

		printf("Finished loading X\n");

		for (k = 0; k < q_cols * m_rows; k++)
		{
			in[i * in_words_adj + j + k] = inY[k];
		}

		printf("Finished loading Y\n");
	}

	gold[p_rows * q_cols] = (token_t) float_to_fixed32(0.868033, 11);

	printf("Finished initialization\n");
}

static void init_Q(token_t *in, token_t * out)
{

	int i, j;

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < p_rows*q_cols; j++) //Q
			out[i * in_words_adj_svd + j] = in[i * in_words_adj_svd + j];

		for(j = 0; j < m_rows*m_rows; j++)
			prev_R[j] = out[out_offset_svd + j];
	}
}

static float check_norm(token_t* mat_1, token_t* mat_2)
{
	float norm = 0;
	float mat = 0;

	for(int i = 0; i < m_rows*m_rows; i++)
	{
		mat = fixed32_to_float(mat_1[i], 11) - fixed32_to_float(mat_2[i], 11);
		//printf("%f ", mat);
		mat = pow(mat, 2);
		norm += mat;
	}
	//printf("\n");
	norm = pow(norm, 0.5);
	return norm;
}

static void init_X(token_t *in, token_t * out)
{
	int i;
	int j;

//	printf("Initializing buffer\n");

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < p_rows * m_rows; j++)
		{
			out[i * in_words_adj + j] = in[i * in_words_adj + j];
		}

	}
}

static void init_buffer_svd(token_t *in, token_t * gold)
{

	int i, j, k, x, y, t, h;

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < p_rows*q_cols; j++) //Q
		{
			float val = (float) 1/(p_rows * q_cols);
			in[i * in_words_adj_svd + j] = (token_t) float_to_fixed32(val, 11);
		}

		for(x = 0; x < m_rows*p_rows; x++) //X
		{
			in[i * in_words_adj_svd + j + x] = (token_t) float_to_fixed32(svd_inputX[x], 11);

		}

		for(y = 0; y < m_rows*q_cols; y++) //Y
		{
			in[i * in_words_adj_svd + j + x + y] = (token_t) float_to_fixed32(inputY[y], 11);

		}

		for(t = 0; t < m_rows*m_rows; t++) //T
		{
			in[i * in_words_adj_svd + j + x + y + t] = (token_t) float_to_fixed32(inputT[t],11);

		}

		in[i * in_words_adj_svd + j + x + y + t] = (token_t) float_to_fixed32(inputP,11);

	}

	printf("  Generated all inputs \n");

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < m_rows*m_rows; j++)
			gold[i * out_words_adj_svd + j] = (token_t) float_to_fixed32(gold_out[j], 11);

		for(k = 0; k < m_rows*p_rows; k++)
			gold[i * out_words_adj_svd + j + k] = (token_t) float_to_fixed32(inputX[i * out_words_adj_svd + k], 11);

		for(h = 0; h < m_rows*q_cols; h++)
			gold[i * out_words_adj_svd + j + k + h] = (token_t) float_to_fixed32(inputYT[i * out_words_adj_svd + h], 11);
	}


	printf("  Generated golden output \n");
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		inX_words_adj = p_rows * m_rows;
		inY_words_adj = q_cols * m_rows;
		in_words_adj = inY_words_adj + inX_words_adj;
		out_words_adj = p_rows * q_cols + 1;
	} else {
		inX_words_adj = round_up(p_rows * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		inY_words_adj = round_up(q_cols * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		in_words_adj = round_up((p_rows+q_cols) * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(p_rows * q_cols + 1, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}

	inX_len = inX_words_adj * (1);
	inY_len = inY_words_adj * (1);
	in_len = in_words_adj * (1);
	out_len =  out_words_adj * (1);
	inX_size = inX_len * sizeof(token_t);
	inY_size = inY_len * sizeof(token_t);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = in_len;
	size = (out_offset * sizeof(token_t)) + out_size;

        // SVD parameters
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj_svd = p_rows*q_cols+m_rows*p_rows+m_rows*q_cols+m_rows*m_rows+1;
		out_words_adj_svd = m_rows*m_rows+m_rows*p_rows+m_rows*q_cols;
	} else {
		in_words_adj_svd = round_up(p_rows*q_cols+m_rows*p_rows+m_rows*q_cols+m_rows*m_rows+1, DMA_WORD_PER_BEAT(sizeof(float)));
		out_words_adj_svd = round_up(m_rows*m_rows+m_rows*p_rows+m_rows*q_cols, DMA_WORD_PER_BEAT(sizeof(float)));
	}
	in_len_svd = in_words_adj_svd * (1);
	out_len_svd =  out_words_adj_svd * (1);
	in_size_svd = in_len_svd * sizeof(token_t);
	out_size_svd = out_len_svd * sizeof(token_t);
	out_offset_svd = in_len_svd;
	size_svd = (out_offset_svd * sizeof(token_t)) + out_size_svd;
}

void inline reshape_to_C_mat_with_R(float* y, float* x, float* Y, float* X, unsigned q, unsigned p, float* C)
{
	//Takes two arrays with different dimensions
	//Array x has n elements, array y has m elements
	//Arrange x times m rows in X and y times n columns in Y
	//Add X+Y

	for(unsigned i = 0; i < p; i++)
		for(unsigned j = 0 ; j < q; j++)
		{
			//C[i * q + j] = 0;
			for(unsigned k = 0; k < 3; k++)
			{
				C[i * q + j] += X[k * p + i] * Y[k * q + j];
			}

			C[i * q + j] = y[j] + x[i] - 2 * C[i * q + j];
		}

}

void inline exp_gamma_mat(float* C, float gamma, unsigned rows, unsigned cols, float* K)
{
	//Element-wise operation on C matrix. Divide each element by gamma and exp(-result)
	//Save the final result in K

	for(unsigned i = 0; i < rows*cols; i++)
	{
		K[i] = exp(-C[i] / gamma);
	}
}

void inline sink_kernel_operation(float* a, unsigned p, unsigned q, float* K, float* b, bool transpose)
{
	if(!transpose)//Regular multiplication
	{
		for(unsigned i = 0; i < p; i++)
		{
			a[i] = 0;
			for(unsigned k = 0; k < q; k++)
			{
				a[i] += K[i * q + k] * b[k];
			}
			a[i] = 1.0/((float)p * a[i]);
		}
	}
	else//Transpose multiplication
	{
		for(unsigned i = 0; i < q; i++)
		{
			a[i] = 0;
			for(unsigned k = 0; k < p; k++)
			{
				a[i] += K[k * q + i] * b[k];
			}
			a[i] = 1.0/((float)q * a[i]);
		}
	}
}

void inline mult_diag_mat_diag(float* diag_vec_1, float* K, float* diag_vec_2, float* R, unsigned m, unsigned n)
{
	//Multiply 2 diagonal matrices with another matrix K in the middle
	//Save result in R
	//m is rows in K and n is columns

	for(unsigned i = 0; i < m; i++)
		for(unsigned j = 0; j < n; j++)
		{
			R[i*n + j] = diag_vec_1[i] * K[i*n + j] * diag_vec_2[j];
		}

}

float inline mult_sum_mats_elementwise(float* C, float* P, unsigned rows, unsigned cols)
{
	//Calculate the sum of element-wise multiplication of 2 matrices
	float sum = 0;
	for(unsigned j = 0; j < cols*rows; j++)
	{
		sum += C[j] * P[j];
	}
	return sum;
}

float inline sinkhorn_kernel(unsigned iter, unsigned p, unsigned q, float* a, float* b,
				float* K, float* C, float* tmp, float* P)
{
	//Implementation of the inner loop in sinkhorn algorithm

	float b_prev[177];
	float norm = 0.0;

	//Initializing b
	for(unsigned i = 0; i < q; i++)
		b[i] = 1.0 / (float)q;

	//Main loop
	for(unsigned i = 0; i < iter; i++)
	{
		for(unsigned j = 0; j < 177; j++)
			b_prev[j] = b[j];

		//printf("%u ", i);
		sink_kernel_operation(a, p, q, K, b, false);

		sink_kernel_operation(b, p, q, K, a, true);

                //b norm check
		norm = 0;
		for(unsigned j = 0; j < 177; j++)
			norm += pow(b[j]-b_prev[j],2);
		norm = sqrt(norm);
		if(norm < 0.00001)
			break;
	}

	mult_diag_mat_diag(a, K, b, P, p, q);

	float sum = 0;
	sum = mult_sum_mats_elementwise(C, P, p, q);
	return sum;
}

float inline sinkhorn(float p, float q, float* X, float* Y, float* P, float gamma, unsigned maxiter, float outputX[], float outputY[], float C[], float K[], float a[], float b[], float tmp[])
{
	float sum = 0;
	unsigned m = 3;
	unsigned nX = p;
	unsigned nY = q;
	int power = 2;

	for(unsigned i = 0; i < m; i++)
		for(unsigned j = 0 ; j < nX; j++)
		{
			outputX[j] += pow(X[i * nX + j], power);
		}

	for(unsigned i = 0; i < m; i++)
		for(unsigned j = 0 ; j < nY; j++)
		{
			outputY[j] += pow(Y[i * nY + j], power);
		}

	reshape_to_C_mat_with_R(outputY, outputX, Y, X, 177, 229, C);

	exp_gamma_mat(C, gamma, nX, nY, K);

	sum = sinkhorn_kernel(maxiter, p, q, a, b, K, C, tmp, P);

	return sum;
}

void c_run()
{
	float outputX[229] = {0};
	float outputY[177] = {0};
	float C[229*177] = {0};
	float K[229*177] = {0};
	float a[229] = {0};
	float b[177] = {0};
	float tmp[229*177] = {0};
	float P[229*177] = {0};
	float gamma = 1.6;
	unsigned iter = 150;
	unsigned p = 229;
	unsigned q = 177;
	float sum = 0;
	int N = 9;

	struct timespec startn, endn;
	unsigned long long sw_ns;


	gettime(&startn);

	//Simulate running software for 9 iterations - not real computation
	for(int i = 0; i < N; i++)
	{
		//Sinkhorn
		sum = sinkhorn(p, q, inputX, inputYT, P, gamma, iter, outputX, outputY, C, K, a, b, tmp);

		//SVD
		c_run_svd(inputP, inputX, inputY, inputT);
	}


	gettime(&endn);

	sw_ns = ts_subtract(&startn, &endn);
	printf("  > Software test time: %llu ns (%d iterations)\n", sw_ns, N);
	(void)sum; // Silent warning about sum

        //New software Eigen mixed - real computation
	int pq = 0*4+0;

	gettime(&startn);

	c_hiwa_tot((void*)&pq);

	gettime(&endn);

	sw_ns = ts_subtract(&startn, &endn);
	printf("  > Optimized software test time: %llu ns , CP_sum = %f, Expected = %f\n", sw_ns, CP_res[pq], CP_tot[pq]);

}

 int main(int argc, char **argv)
 {
	int errors;

	token_t *gold;
	token_t *buf;
	token_t* buf_Q;

	token_t *gold_svd;
	token_t *buf_svd;

	init_parameters();

	buf = (token_t *) esp_alloc(size+size_svd);
	gold = (token_t *) malloc(out_size);

	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
	{
		buf[i] = 0;
	}
	//init_buffer(buf, gold);

	buf_svd = &buf[size/sizeof(token_t)];
	gold_svd = (token_t *) malloc(out_size_svd);

	((struct svd_access*) cfg_000[0].esp_desc)->src_offset = size;
	((struct svd_access*) cfg_000[0].esp_desc)->dst_offset = size;
	cfg_000[0].hw_buf = buf;

	printf("\nClean SVD - send all zeros\n");
	esp_run(&cfg_000[0], 1);

	init_buffer_svd(buf_svd, gold_svd);

        //SVD execution

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .q = %d\n", q_cols);
	printf("  .p = %d\n", p_rows);
	printf("  .m = %d\n", m_rows);
	printf("\n  ** START **\n");

	/* ((struct svd_access*) cfg_000[0].esp_desc)->src_offset = size; */
	/* ((struct svd_access*) cfg_000[0].esp_desc)->dst_offset = size; */
	/* cfg_000[0].hw_buf = buf; */

	esp_run(&cfg_000[0], 1);

	printf("\n  ** DONE **\n");

	errors = validate_buffer_svd(&buf_svd[out_offset_svd], gold_svd);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);


	//HIWA execution - reading input from svd output
	token_t* buf_inX = &buf_svd[out_offset_svd+m_rows*m_rows];
	token_t* buf_inY = &buf_svd[out_offset_svd+m_rows*m_rows+m_rows*p_rows];
	init_buffer(buf, gold, buf_inX, buf_inY);

	printf("\n====== %s ======\n\n", cfg_000[1].devname);
	/* <<--print-params-->> */
	printf("  .maxiter = %d\n", maxiter);
	printf("  .gamma = %f\n", gamma_float);
	printf("  .q = %d\n", q_cols);
	printf("  .m = %d\n", m_rows);
	printf("  .p = %d\n", p_rows);
	printf("\n  ** START **\n");

	((struct sinkhorn_access*) cfg_000[1].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	cfg_000[1].hw_buf = buf;

        //run sinkhorn
	esp_run(&cfg_000[1], 1);

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	//free(gold);
	//esp_cleanup();

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[1].devname);


        // multi-run of HiWA=Sinkhorn+SVD
	buf_Q = &buf[out_offset];

	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
		buf[i] = 0;
	for(int j = 0; j < M_ROWS*M_ROWS; j++)
	{
		float zero = 0.0;
		prev_R[j] = (token_t) float_to_fixed32(zero, 11);
	}


	printf("\n====== %s-%s software norm break ======\n\n", cfg_000[1].devname, cfg_000[0].devname);
	printf("\n  ** START **\n");


	struct timespec startn, endn;
	unsigned long long total_hw_ns;
	float norm = 0.0;

	gettime(&startn);

	for(int i = 0; i < 50; i++)
	{
		//SVD
		if(i == 0)
			init_buffer_svd(buf_svd, gold_svd);
		else
			init_Q(buf_Q, buf_svd);
		esp_run(&cfg_000[0], 1);

		//Sinkhorn
		if(i == 0)
			init_buffer(buf, gold, buf_inX, buf_inY);
		else
			init_X(buf_inX, buf);
		esp_run(&cfg_000[1], 1);

		/* float val = fixed32_to_float(buf[out_offset+ p_rows*q_cols], 11); */
		/* printf("\nCP_sum: %f\n", val); */

		norm = check_norm(&buf_svd[out_offset_svd], prev_R);
		//printf("\niteration is %d norm is %f \n", i, norm);
		if(norm < 0.014)
			break;
	}

	gettime(&endn);

	total_hw_ns = ts_subtract(&startn, &endn);
	printf("\nFinal norm is %f \n", norm);
	printf("\n  >>> Total test time: %llu ns\n", total_hw_ns);

	printf("\n  ** DONE **\n");

	errors = validate_final(&buf_svd[out_offset_svd], &buf[out_offset], finalR, finalQ);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s-%s software norm break ======\n\n", cfg_000[1].devname, cfg_000[0].devname);


	free(gold_svd);
	free(gold);
	esp_free(buf);

	/* printf("\nRunning full computation in software on RISC-V CPU...\n"); */
	/* c_run(); */

	return errors;
	return 0;
 }
