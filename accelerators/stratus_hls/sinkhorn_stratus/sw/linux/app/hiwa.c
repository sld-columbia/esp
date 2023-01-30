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
				printf("P error is bigger than 3 percent\n");
				errors++;
			}

		}
	}

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;
	int k;

	printf("Initializing buffer\n");

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < p_rows * m_rows; j++)
		{
			in[i * in_words_adj + j] = (token_t) float_to_fixed32(inputX[j], 11);
		}

		//j = inX_len;

		printf("Finished loading X\n");

		for (k = 0; k < q_cols * m_rows; k++)
		{
			in[i * in_words_adj + j + k] = (token_t) float_to_fixed32(inputYT[k], 11);
		}

		printf("Finished loading Y\n");
	}

	gold[p_rows * q_cols] = (token_t) float_to_fixed32(0.868033, 11);

	printf("Finished initialization");
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		inX_words_adj = p_rows * m_rows;
		inY_words_adj = q_cols * m_rows;
		in_words_adj = inX_words_adj + inY_words_adj;
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

	struct timespec startn, endn;
	unsigned long long sw_ns;


	gettime(&startn);
	sum = sinkhorn(p, q, inputX, inputYT, P, gamma, iter, outputX, outputY, C,
				K, a, b, tmp);
	gettime(&endn);

	sw_ns = ts_subtract(&startn, &endn);
	printf("  > Software test time: %llu ns\n", sw_ns);
	printf("    + CP_sum: %f\n", sum);

	float outputX1[229] = {0};
	float outputY1[177] = {0};
	float C1[229*177] = {0};
	float K1[229*177] = {0};
	float a1[229] = {0};
	float b1[177] = {0};

	//Use eigen library
	gettime(&startn);
	sum = c_run_hiwa(p, q, inputX, inputYT, gamma, iter,
			outputX1, outputY1, C1, K1, a1, b1);

	gettime(&endn);

	sw_ns = ts_subtract(&startn, &endn);
	printf("  > Eigen software test time: %llu ns\n", sw_ns);
	printf("    + CP_sum: %f\n", sum);
}

 int main(int argc, char **argv)
 {
	int errors;

	token_t *gold;
	token_t *buf;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	gold = malloc(out_size);

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[1].devname);
	/* <<--print-params-->> */
	printf("  .maxiter = %d\n", maxiter);
	printf("  .gamma = %f\n", gamma_float);
	printf("  .q_cols = %d\n", q_cols);
	printf("  .m_rows = %d\n", m_rows);
	printf("  .p_rows = %d\n", p_rows);
	printf("\n  ** START **\n");

	((struct sinkhorn_access*) cfg_000[1].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	cfg_000[1].hw_buf = buf;

	//Run software execution for comparison
	c_run();

	//Run Sinkhorn accelerator
	esp_run(&cfg_000[1], 1);

	printf("\n  ** DONE **\n");

	//Validate the output
	errors = validate_buffer(&buf[out_offset], gold);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[1].devname);


	//In case we have more than one sinkhorn - check maximum 4
	for(int8_t i = 1; i < 4; i++){
		char acc[3][16];
		sprintf(acc[i-1], "/dev/sinkhorn.%d", i);

		if(access(acc[i-1], F_OK) == 0){

			printf("\nAdditional accelerator: %s\n\n", acc[i-1]);

			((struct sinkhorn_access*) cfg_000[i+1].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
			cfg_000[i+1].hw_buf = buf;
			esp_run(&cfg_000[i+1], 1);

			errors = validate_buffer(&buf[out_offset], gold);

			if (!errors)
				printf("+ Test PASSED for %s\n", acc[i-1]);
			else
				printf("+ Test FAILED for %s\n", acc[i-1]);
		}
	}

	printf("\n  ** DONE **\n");

	esp_free(buf);
	free(gold);

	return errors;
	return 0;
 }
