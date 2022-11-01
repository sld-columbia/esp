#include "libesp.h"
#include "cfg.h"
#include "c_run.h"

static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned size;

/* User-defined code */
static int validate_buffer(token_t *out, token_t *gold)
{
	int i;
	int j;
	unsigned errors = 0;
	float MAE, MAE_sum, num;
	MAE_sum = 0.0;

	for (i = 0; i < 1; i++)
		for (j = 0; j < m*m+m*p; j++)
		{

			float val_out, val_gold;
			val_out = fixed32_to_float(out[i * out_words_adj + j], 11);
			val_gold = fixed32_to_float(gold[i * out_words_adj + j], 11);

			MAE = (val_out - val_gold) / val_gold;

			//printf("%d: out = %.20f , gold = %.20f \n", j, val_out, val_gold);

			MAE_sum += pow(MAE,2);
			if (MAE < -0.15 || MAE > 0.15)
				errors++;

		}

	num = m*m+p*m;
	if (MAE_sum / num > 0.01)
		errors++;

	printf("Sum of errors is %d \n", errors);

	return errors;
}


/* User-defined code */
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;
	int k, x, y, t;

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < p*q; j++) //Q
		{
			float val = (float) 1/(p * q);
			in[i * in_words_adj + j] = (token_t) float_to_fixed32(val, 11);
		}

		for(x = 0; x < m*p; x++) //X
		{
			in[i * in_words_adj + j + x] = (token_t) float_to_fixed32(inputX[x], 11);
			//printf(" in[%d] = %f \n", i * in_words_adj + j + x, in[i * in_words_adj + j + x]);
		}

		for(y = 0; y < m*q; y++) //Y
		{
			in[i * in_words_adj + j + x + y] = (token_t) float_to_fixed32(inputY[y], 11);
			//printf(" in[%d] = %f \n", i * in_words_adj + j + x + y, in[i * in_words_adj + j + x +y]);
		}

		for(t = 0; t < m*m; t++) //T
		{
			in[i * in_words_adj + j + x + y + t] = (token_t) float_to_fixed32(inputT[t], 11);
			//printf(" in[%d] = %f \n", i * in_words_adj + j + x + y + t, in[i * in_words_adj + j + x + y + t]);
		}

		in[i * in_words_adj + j + x + y + t] = (token_t) float_to_fixed32(inputP, 11);
		//printf(" in[%d] = %f \n", i * in_words_adj + j + x + y + t, in[i * in_words_adj + j + x + y + t]);

	}

	printf("  Generated all inputs \n");

	for(k = 0; k < m; k++)
		for(j = 0; j < p; j++)
			gold_out_sink[k][j] = 0.0;

	for(k = 0; k < m; k++)
		for(i = 0; i < p; i++)
			for(j = 0; j < m; j++)
				gold_out_sink[k][i] += inputX[i * m + j] * gold_out[k * m + j];

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < m*m; j++)
		{
			gold[i * out_words_adj + j] = (token_t) float_to_fixed32(gold_out[j], 11);
			//printf("gold: %d: val = %f \n", j, gold_out[j]);
		}

		for(k = 0; k < m*p; k++)
		{
			gold[i * out_words_adj + j + k] = (token_t) float_to_fixed32(gold_out_sink[k / p][k % p], 11);
			//printf("gold: %d: val = %f \n", k, gold_out_sink[k/p][k%p]);
		}
	}

	printf("  Generated golden output \n");
}


/* User-defined code */
static void init_parameters()
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		in_words_adj = p*q+m*p+m*q+m*m+1;
		out_words_adj = m*m+m*p;
	} else {
		in_words_adj = round_up(p*q+m*p+m*q+m*m+1, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(m*m+m*p, DMA_WORD_PER_BEAT(sizeof(token_t)));
	}
	in_len = in_words_adj * (1);
	out_len =  out_words_adj * (1);
	in_size = in_len * sizeof(token_t);
	out_size = out_len * sizeof(token_t);
	out_offset = in_len;
	size = (out_offset * sizeof(token_t)) + out_size;
}

/* void c_run() */
/* { */
/* 	//Variables */
/* 	float inputQ[229*177]; */
/* 	int p = 229, q = 177; */
/* 	for(int j = 0; j < p*q; j++) //Q */
/* 		inputQ[j] = (float) 1/(p * q); */

/* 	Matrix3f A; */
/* 	//float Q[229*177]; */
/* 	MatrixXf Q = Map<Matrix<float, 177, 229> >(inputQ); */
/* 	MatrixXf C; */
/* 	MatrixXf X = Map<Matrix<float, 3, 229> >(inputX); */
/* 	MatrixXf Y = Map<Matrix<float, 3, 177> >(inputY); */
/* 	Matrix3f T = Map<Matrix<float, 3, 3> >(inputT); */

/*         //Measure time */
/* 	struct timespec startn, endn; */
/* 	unsigned long long sw_ns; */

/* 	gettime(&startn); */

/*         //Run svd software - get R, X*R and Y.T */
/* 	A = Y*Q*X.transpose()*2*inputP+T; */
/* 	JacobiSVD<Matrix3f> svd(A, ComputeFullU | ComputeFullV); */
/* 	Matrix3f U = svd.matrixU(); */
/* 	Matrix3f Vh = svd.matrixV().transpose(); */
/* 	Matrix3f res = U * Vh; */
/* 	MatrixXf X_res = X.transpose()*res; */
/* 	MatrixXf Y_res = Y; */

/* 	gettime(&endn); */

/* 	sw_ns = ts_subtract(&startn, &endn); */
/* 	printf("  > Software test time: %llu ns\n", sw_ns); */
/* 	//printf("    + CP_sum: %f\n", sum); */
/* } */

int main(int argc, char **argv)
{
	int errors;

	token_t *gold;
	token_t *buf;

        //Measure time
	struct timespec startn, endn;
	unsigned long long sw_ns;

	init_parameters();

	buf = (token_t *) esp_alloc(size);
	gold = malloc(out_size);

	for(int i = 0; i < size/sizeof(token_t); i++)
		buf[i] = 0;

	cfg_000[0].hw_buf = buf;

	printf("\nClean SVD - send all zeros\n");
	esp_run(&cfg_000[0], 1);

	init_buffer(buf, gold);

	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .q = %d\n", q);
	printf("  .p = %d\n", p);
	printf("  .m = %d\n", m);

	printf("\n  ** START **\n");

        //Run svd software
	gettime(&startn);
	c_run_svd(inputP, inputX, inputY, inputT);
	gettime(&endn);
	sw_ns = ts_subtract(&startn, &endn);
	printf("  > Software test time: %llu ns\n", sw_ns);

	cfg_000[0].hw_buf = buf;

        //Run SVD hardware
	esp_run(cfg_000, NACC);

        printR();

	printf("\n  ** DONE **\n");

	errors = validate_buffer(&buf[out_offset], gold);

	if (!errors)
		printf("+ Test PASSED\n");
	else
		printf("+ Test FAILED\n");

	printf("\n====== %s ======\n\n", cfg_000[0].devname);

	//In case we have more than one sinkhorn - check maximum 4
	for(int8_t i = 1; i < 4; i++){
		char acc[3][11];
		sprintf(acc[i-1], "/dev/svd.%d", i);

		if(access(acc[i-1], F_OK) == 0){

			printf("\nAdditional accelerator: %s\n\n", acc[i-1]);

			cfg_000[i].hw_buf = buf;
			esp_run(&cfg_000[i], 1);

			errors = validate_buffer(&buf[out_offset], gold);

			if (!errors)
				printf("+ Test PASSED for %s\n", acc[i-1]);
			else
				printf("+ Test FAILED for %s\n", acc[i-1]);
		}
	}


	printf("\n  ** DONE **\n");

	free(gold);
	esp_free(buf);

	return errors;
}
