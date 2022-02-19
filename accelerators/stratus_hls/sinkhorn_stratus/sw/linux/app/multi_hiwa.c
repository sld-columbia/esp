#include "libesp.h"
#include "cfg.h"

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
			/* if (MAE < -0.1 || MAE > 0.1) */
			/* { */
			/* 	printf("Q: %d: out = %.10f , gold = %.10f \n", j, val_out, val_gold); */
			/* 	//errors++; */
			/* } */

		}

	}

	num = p_rows*q_cols;
	if (MAE_sum / num > 0.01)
	{
		printf("Total error in Q is %f. \n", MAE_sum / num);
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

			if(j < m_rows*m_rows)
				printf("%d: out = %f , gold = %f \n", j, val_out, val_gold);

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
static void init_buffer(token_t *in, token_t * gold)
{
	int i;
	int j;
	int k;

	printf("\nInitializing buffer\n");

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < p_rows * m_rows; j++)
		{
			in[i * inX_words_adj + j] = (token_t) float_to_fixed32(inputX[j], 11);
		}

		printf("Finished loading X\n");

		for (k = 0; k < q_cols * m_rows; k++)
		{
			in[i * inY_words_adj + j + k] = float_to_fixed32(inputYT[k], 11);
		}

		printf("Finished loading Y\n");
	}

	gold[p_rows * q_cols] = (token_t) float_to_fixed32(0.868033, 11);

	printf("Finished initialization\n");
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
	out_len_svd =  out_words_adj_svd * (4);
	in_size_svd = in_len_svd * sizeof(token_t);
	out_size_svd = out_len_svd * sizeof(token_t);
	out_offset_svd = in_len_svd;
	size_svd = (out_offset_svd * sizeof(token_t)) + out_size_svd;
}

 int main(int argc, char **argv)
 {
	int errors0, errors1, errors2, errors3;

	token_t *gold0;
	token_t *gold1;
	token_t *gold2;
	token_t *gold3;

	token_t *buf0;
	token_t *buf1;
	token_t *buf2;
	token_t *buf3;

	token_t *gold_svd0;
	token_t *gold_svd1;
	token_t *gold_svd2;
	token_t *gold_svd3;
	token_t *buf_svd0;
	token_t *buf_svd1;
	token_t *buf_svd2;
	token_t *buf_svd3;

	init_parameters();

	buf0 = (token_t *) esp_alloc(size+size_svd);
	buf1 = (token_t *) esp_alloc(size+size_svd);
	buf2 = (token_t *) esp_alloc(size+size_svd);
	buf3 = (token_t *) esp_alloc(size+size_svd);
	gold0 = (token_t *) malloc(out_size);
	gold1 = (token_t *) malloc(out_size);
	gold2 = (token_t *) malloc(out_size);
	gold3 = (token_t *) malloc(out_size);

	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 1xSVD -> 4xSinkhorn Test $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");

	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
	{
		buf0[i] = 0;
		buf1[i] = 0;
		buf2[i] = 0;
		buf3[i] = 0;
	}

	init_buffer(buf0, gold0);
	init_buffer(buf1, gold1);
	init_buffer(buf2, gold2);
	init_buffer(buf3, gold3);

	buf_svd0 = &buf0[size/sizeof(token_t)];
	buf_svd1 = &buf1[size/sizeof(token_t)];
	buf_svd2 = &buf2[size/sizeof(token_t)];
	buf_svd3 = &buf3[size/sizeof(token_t)];
	gold_svd0 = (token_t *) malloc(out_size_svd);
	gold_svd1 = (token_t *) malloc(out_size_svd);
	gold_svd2 = (token_t *) malloc(out_size_svd);
	gold_svd3 = (token_t *) malloc(out_size_svd);

	init_buffer_svd(buf_svd0, gold_svd0);
	init_buffer_svd(buf_svd1, gold_svd1);
	init_buffer_svd(buf_svd2, gold_svd2);
	init_buffer_svd(buf_svd3, gold_svd3);

        //SVD execution

	printf("\n====== First %s -> 4x%s ======\n\n", cfg_multi[0].devname, cfg_multi[1].devname);
	/* <<--print-params-->> */
	printf("  .maxiter = %d\n", maxiter);
	printf("  .gamma = %f\n", gamma_float);
	printf("  .q = %d\n", q_cols);
	printf("  .p = %d\n", p_rows);
	printf("  .m = %d\n", m_rows);

	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);

        //Configure SVD
	((struct svd_access*) cfg_multi[0].esp_desc)->src_offset = size;
	((struct svd_access*) cfg_multi[0].esp_desc)->dst_offset = size;
	cfg_multi[0].hw_buf = buf0; // We run the same dataset 4 times
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_out = 1;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_in = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_iter = 4;
	((struct svd_access*) cfg_multi[0].esp_desc)->load_state = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_store = 1;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_nsrcs = 0;

	//Configure Sinkhorns
	cfg_multi[1].hw_buf = buf0;
	cfg_multi[2].hw_buf = buf1;
	cfg_multi[3].hw_buf = buf2;
	cfg_multi[4].hw_buf = buf3;
 	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_out = 0;
 	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_out = 0;
 	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_out = 0;
 	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_out = 0;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->store_state = 0;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->store_state = 0;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->store_state = 0;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->store_state = 0;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->esp.p2p_nsrcs = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->esp.p2p_nsrcs = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->esp.p2p_nsrcs = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->esp.p2p_nsrcs = 1;

	//printf("\n  ** START **\n");

	printf("\n Run SVD->Sinkhorns (-> mem for debug) \n");
	esp_run(cfg_multi, 5);

	//printf("\n  ** DONE **\n");

        //Check for errors
	printf("\nDebug Sinkhorns for errors:\n");
	errors0 = validate_buffer(&buf0[out_offset], gold0);
	errors1 = validate_buffer(&buf1[out_offset], gold1);
	errors2 = validate_buffer(&buf2[out_offset], gold2);
	errors3 = validate_buffer(&buf3[out_offset], gold3);

	printf("\n");
	if (!errors0)
		printf("+ Test0 PASSED\n");
	else
		printf("+ Test0 FAILED\n");

	if (!errors1)
		printf("+ Test1 PASSED\n");
	else
		printf("+ Test1 FAILED\n");

	if (!errors2)
		printf("+ Test2 PASSED\n");
	else
		printf("+ Test2 FAILED\n");

	if (!errors3)
		printf("+ Test3 PASSED\n");
	else
		printf("+ Test3 FAILED\n");



	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_out = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_in = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_iter = 1;
	((struct svd_access*) cfg_multi[0].esp_desc)->load_state = 2;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_store = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_nsrcs = 0;

	printf("\nDebug SVD for errors:\n");
	esp_run(cfg_multi, 1);
	errors0 = validate_buffer_svd(&buf_svd0[out_offset_svd], gold_svd0);

	printf("\n");
	if (!errors0)
		printf("+ Test0 PASSED\n");
	else
		printf("+ Test0 FAILED\n");


	printf("\n====== First %s -> 4x%s ======\n\n", cfg_multi[0].devname, cfg_multi[1].devname);

	uint32_t N = 8;

	printf("\n====== 4x%s -> %s %d Iterations ======\n\n", cfg_multi[1].devname, cfg_multi[0].devname, N);


	//Configure SVD
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_out = 1;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_in = 1;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_iter = N*4;
	((struct svd_access*) cfg_multi[0].esp_desc)->load_state = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_store = 1;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_nsrcs = 4;
	//((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_srcs = {Default is all sinkhorns};

        //Configure Sinkhorns
 	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_out = 1;
 	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_out = 1;
 	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_out = 1;
 	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_out = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_in = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_iter = N+1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_iter = N+1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_iter = N+1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_iter = N+1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->store_state = 3;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->store_state = 3;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->store_state = 3;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->store_state = 3;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->esp.p2p_nsrcs = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->esp.p2p_nsrcs = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->esp.p2p_nsrcs = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->esp.p2p_nsrcs = 1;

	printf("\n Run Sinkhorns->SVD->Sinkhorns (%d iterations) \n", N);
	esp_run(cfg_multi, 5);

	printf("\n====== 4x%s -> %s %d Iterations ======\n\n", cfg_multi[1].devname, cfg_multi[0].devname, N);

 	printf("\n====== 4x%s -> %s -> mem ======\n\n", cfg_multi[1].devname, cfg_multi[0].devname);

	//Configure SVD
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_out = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_in = 1;
	((struct svd_access*) cfg_multi[0].esp_desc)->p2p_iter = 4;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_nsrcs = 4;
	((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_store = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->load_state = 0;
	((struct svd_access*) cfg_multi[0].esp_desc)->dst_offset = size;

        //Configure Sinkhorns
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_out = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_in = 0;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->esp.p2p_nsrcs = 0;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->store_state = 2;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->dst_offset = 0;

	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_out = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_in = 0;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->esp.p2p_nsrcs = 0;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->store_state = 2;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->dst_offset = 0;

	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_out = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_in = 0;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->esp.p2p_nsrcs = 0;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->store_state = 2;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->dst_offset = 0;

	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_out = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_in = 0;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_iter = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->esp.p2p_nsrcs = 0;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->esp.p2p_store = 1;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->store_state = 2;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->dst_offset = 0;

	//strcpy(((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_srcs[0], "sinkhorn.0");
	//strcpy(cfg_multi[1].devname, "sinkhorn.0");
	cfg_multi[0].hw_buf = buf0;
	//cfg_multi[1].hw_buf = buf0;
	printf("\nStore data Sinkhorns -> SVD -> mem\n");
	esp_run(cfg_multi, 5);

	/* strcpy(((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_srcs[0], "sinkhorn.1"); */
	/* cfg_multi[1].devname = "sinkhorn.1"; */
	/* cfg_multi[0].hw_buf = buf1; */
	/* cfg_multi[1].hw_buf = buf1; */
	/* printf("\nStore data Sinkhorn.1 -> SVD -> mem\n"); */
	/* esp_run(cfg_multi, 2); */

	/* strcpy(((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_srcs[0], "sinkhorn.2"); */
	/* cfg_multi[1].devname = "sinkhorn.2"; */
	/* cfg_multi[0].hw_buf = buf2; */
	/* cfg_multi[1].hw_buf = buf2; */
	/* printf("\nStore data Sinkhorn.2 -> SVD -> mem\n"); */
	/* esp_run(cfg_multi, 2); */

	/* strcpy(((struct svd_access*) cfg_multi[0].esp_desc)->esp.p2p_srcs[0], "sinkhorn.3"); */
	/* cfg_multi[1].devname = "sinkhorn.3"; */
	/* cfg_multi[0].hw_buf = buf3; */
	/* cfg_multi[1].hw_buf = buf3; */
	/* printf("\nStore data Sinkhorn.3 -> SVD -> mem\n"); */
	/* esp_run(cfg_multi, 2); */

	printf("\nRun Sinkhorns and store their data\n");
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->p2p_out = 0;
	((struct sinkhorn_access*) cfg_multi[1].esp_desc)->esp.p2p_store = 0;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->p2p_out = 0;
	((struct sinkhorn_access*) cfg_multi[2].esp_desc)->esp.p2p_store = 0;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->p2p_out = 0;
	((struct sinkhorn_access*) cfg_multi[3].esp_desc)->esp.p2p_store = 0;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->p2p_out = 0;
	((struct sinkhorn_access*) cfg_multi[4].esp_desc)->esp.p2p_store = 0;

	//Store data from Sinkhorns
	cfg_multi[1].devname = "sinkhorn.0";
	cfg_multi[2].devname = "sinkhorn.1";
	cfg_multi[3].devname = "sinkhorn.2";
	cfg_multi[4].devname = "sinkhorn.3";
	cfg_multi[1].hw_buf = buf0;
	cfg_multi[2].hw_buf = buf1;
	cfg_multi[3].hw_buf = buf2;
	cfg_multi[4].hw_buf = buf3;
	printf("\nRun 4 Sinkhorns in parallel and store data in memory\n");
	esp_run(&cfg_multi[1], 4);

	//strcpy(cfg_multi[1].devname, "sinkhorn.3");
	//cfg_multi[1].hw_buf = buf3;
	//printf("\nStore data from Sinkhorn.3 -> mem\n");
	//esp_run(&cfg_multi[1], 1);
	//strcpy(cfg_multi[1].devname, "sinkhorn.2");
	//cfg_multi[1].hw_buf = buf2;
	//printf("\nStore data from Sinkhorn.2 -> mem\n");
	//esp_run(&cfg_multi[1], 1);
	//strcpy(cfg_multi[1].devname, "hiwa.1");
	//cfg_multi[1].hw_buf = buf1;
	//printf("\nStore data from Sinkhorn.1 -> mem\n");
	//esp_run(&cfg_multi[1], 1);
	//strcpy(cfg_multi[1].devname, "hiwa.0");
	//cfg_multi[1].hw_buf = buf0;
	//printf("\nStore data from Sinkhorn.0 -> mem\n");
	//esp_run(&cfg_multi[1], 1);


 	printf("\n====== 4x%s -> %s -> mem ======\n\n", cfg_multi[1].devname, cfg_multi[0].devname);

	printf("\nResults from HiWA.0:\n");
	errors0 = validate_final(&buf_svd0[out_offset_svd], &buf0[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.1:\n");
	errors1 = validate_final(&buf_svd0[out_offset_svd+out_words_adj_svd], &buf1[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.2:\n");
	errors2 = validate_final(&buf_svd0[out_offset_svd+2*out_words_adj_svd], &buf2[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.3:\n");
	errors3 = validate_final(&buf_svd0[out_offset_svd+3*out_words_adj_svd], &buf3[out_offset], finalR, finalQ);

	printf("\n");
	if (!errors0)
		printf("+ Test0 PASSED\n");
	else
		printf("+ Test0 FAILED\n");

	if (!errors1)
		printf("+ Test1 PASSED\n");
	else
		printf("+ Test1 FAILED\n");

	if (!errors2)
		printf("+ Test2 PASSED\n");
	else
		printf("+ Test2 FAILED\n");

	if (!errors3)
		printf("+ Test3 PASSED\n");
	else
		printf("+ Test3 FAILED\n");

	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 1xSVD -> 4xSinkhorn Test $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");


	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 4xSVD -> 4xSinkhorn Test $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");

	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
	{
		buf0[i] = 0;
		buf1[i] = 0;
		buf2[i] = 0;
		buf3[i] = 0;
	}

	//init_buffer(buf0, gold0);
	//init_buffer(buf1, gold1);
	//init_buffer(buf2, gold2);
	//init_buffer(buf3, gold3);

	buf_svd0 = &buf0[size/sizeof(token_t)];
	buf_svd1 = &buf1[size/sizeof(token_t)];
	buf_svd2 = &buf2[size/sizeof(token_t)];
	buf_svd3 = &buf3[size/sizeof(token_t)];
	gold_svd0 = (token_t *) malloc(out_size_svd);
	gold_svd1 = (token_t *) malloc(out_size_svd);
	gold_svd2 = (token_t *) malloc(out_size_svd);
	gold_svd3 = (token_t *) malloc(out_size_svd);

	printf("\n====== %s-%s 50 Iterations (norm break) ======\n\n", cfg_multi2[0].devname, cfg_multi2[1].devname);

	/* <<--print-params-->> */
	printf("  .maxiter = %d\n", maxiter);
	printf("  .gamma = %f\n", gamma_float);
	printf("  .q = %d\n", q_cols);
	printf("  .p = %d\n", p_rows);
	printf("  .m = %d\n", m_rows);

	((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[5].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[6].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[7].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);

	cfg_multi2[0].hw_buf = buf0;
	cfg_multi2[1].hw_buf = buf1;
	cfg_multi2[2].hw_buf = buf2;
	cfg_multi2[3].hw_buf = buf3;
	cfg_multi2[4].hw_buf = buf0;
	cfg_multi2[5].hw_buf = buf1;
	cfg_multi2[6].hw_buf = buf2;
	cfg_multi2[7].hw_buf = buf3;

	for(int i = 0; i < 4; i++)
	{
                //SVDs
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 0;
	}

	printf("\nClean SVDs - send all zeros\n");
	esp_run(cfg_multi2, 4);

	init_buffer_svd(buf_svd0, gold_svd0);
	init_buffer_svd(buf_svd1, gold_svd1);
	init_buffer_svd(buf_svd2, gold_svd2);
	init_buffer_svd(buf_svd3, gold_svd3);

	//First load data into SVDs
	for(int i = 0; i < 4; i++)
	{
		((struct svd_access*) cfg_multi2[i].esp_desc)->src_offset = size;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_in = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_iter = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 1;
	}

	printf("\n  ** START **\n");

	printf("\nLoad data into SVDs\n");
	esp_run(cfg_multi2, 4);

	//Run SVDs-Sinkhorns with p2p no load from memory
	for(int i = 0; i< 4; i++)
	{
		//SVD
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_in = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_iter = 50;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 2;
		//Sinkhorn
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_out = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_in = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_iter = 50;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_nsrcs = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_store = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->store_state = 1;
	}

	printf("\nRun SVD->Sinkhorn for 50 iterations (norm break)\n");
	esp_run(cfg_multi2, 8);

	/* unsigned nthreads = 4; */
        /* esp_thread_info_t **cfg_ptrs = malloc(sizeof(esp_thread_info_t*) * nthreads); */
        /* unsigned *nacc_arr = malloc(sizeof(unsigned) * nthreads); */
        /* esp_thread_info_t cfg_tmp[8]; */

        /* for (int i = 0; i < nthreads; i++){ */
        /*     nacc_arr[i] = 2; */
	/*     if(i == 0) */
	/*     { */
	/* 	    cfg_tmp[i] = cfg_multi2[i]; */
	/* 	    cfg_tmp[i+1] = cfg_multi2[i+4]; */
	/* 	    cfg_ptrs[i] = &cfg_tmp[i]; */
	/*     } */
	/*     else if(i == 1) */
	/*     { */
	/* 	    cfg_tmp[i+1] = cfg_multi2[i]; */
	/* 	    cfg_tmp[i+2] = cfg_multi2[i+4]; */
	/* 	    cfg_ptrs[i] = &cfg_tmp[i+1]; */
	/*     } */
	/*     else if(i == 2) */
	/*     { */
	/* 	    cfg_tmp[i+2] = cfg_multi2[i]; */
	/* 	    cfg_tmp[i+3] = cfg_multi2[i+4]; */
	/* 	    cfg_ptrs[i] = &cfg_tmp[i+2]; */
	/*     } */
	/*     else if(i == 3) */
	/*     { */
	/* 	    cfg_tmp[i+3] = cfg_multi2[i]; */
	/* 	    cfg_tmp[i+4] = cfg_multi2[i+4]; */
	/* 	    cfg_ptrs[i] = &cfg_tmp[i+3]; */
	/*     } */

        /* } */
        /* esp_run_parallel(cfg_ptrs, nthreads, nacc_arr); */
        /* free(nacc_arr); */
        /* free(cfg_ptrs); */


	for(int i = 0; i< 4; i++)
	{
		//SVD
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_in = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_iter = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 2;
		((struct svd_access*) cfg_multi2[i].esp_desc)->dst_offset = size;
		//Sinkhron
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_out = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_in = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_iter = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_nsrcs = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_store = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->store_state = 2;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->dst_offset = 0;
	}

	printf("\nStore data from SVD and Sinkhorn\n");
	esp_run(cfg_multi2, 8);

	printf("\n  ** DONE **\n");

	printf("\nResults from HiWA.0:\n");
	errors0 = validate_final(&buf_svd0[out_offset_svd], &buf0[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.1:\n");
	errors1 = validate_final(&buf_svd1[out_offset_svd], &buf1[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.2:\n");
	errors2 = validate_final(&buf_svd2[out_offset_svd], &buf2[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.3:\n");
	errors3 = validate_final(&buf_svd3[out_offset_svd], &buf3[out_offset], finalR, finalQ);

	printf("\n");
	if (!errors0)
		printf("+ Test0 PASSED\n");
	else
		printf("+ Test0 FAILED\n");

	if (!errors1)
		printf("+ Test1 PASSED\n");
	else
		printf("+ Test1 FAILED\n");

	if (!errors2)
		printf("+ Test2 PASSED\n");
	else
		printf("+ Test2 FAILED\n");

	if (!errors3)
		printf("+ Test3 PASSED\n");
	else
		printf("+ Test3 FAILED\n");


	printf("\n====== %s-%s P2P 50 Iterations (norm break) ======\n\n", cfg_p2p[0].devname, cfg_p2p[1].devname);



	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 4xSVD -> 4xSinkhorn Test $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");


	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 4xSVD -> 4xSinkhorn Test no norm break $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");

	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
	{
		buf0[i] = 0;
		buf1[i] = 0;
		buf2[i] = 0;
		buf3[i] = 0;
	}

	//init_buffer(buf0, gold0);
	//init_buffer(buf1, gold1);
	//init_buffer(buf2, gold2);
	//init_buffer(buf3, gold3);

	buf_svd0 = &buf0[size/sizeof(token_t)];
	buf_svd1 = &buf1[size/sizeof(token_t)];
	buf_svd2 = &buf2[size/sizeof(token_t)];
	buf_svd3 = &buf3[size/sizeof(token_t)];
	gold_svd0 = (token_t *) malloc(out_size_svd);
	gold_svd1 = (token_t *) malloc(out_size_svd);
	gold_svd2 = (token_t *) malloc(out_size_svd);
	gold_svd3 = (token_t *) malloc(out_size_svd);

	N = 8;

	printf("\n====== %s-%s %d Iterations (no norm break) ======\n\n", cfg_multi2[0].devname, cfg_multi2[1].devname, N);

	/* <<--print-params-->> */
	printf("  .maxiter = %d\n", maxiter);
	printf("  .gamma = %f\n", gamma_float);
	printf("  .q = %d\n", q_cols);
	printf("  .p = %d\n", p_rows);
	printf("  .m = %d\n", m_rows);

	((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[5].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[6].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[7].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);

	cfg_multi2[0].hw_buf = buf0;
	cfg_multi2[1].hw_buf = buf1;
	cfg_multi2[2].hw_buf = buf2;
	cfg_multi2[3].hw_buf = buf3;
	cfg_multi2[4].hw_buf = buf0;
	cfg_multi2[5].hw_buf = buf1;
	cfg_multi2[6].hw_buf = buf2;
	cfg_multi2[7].hw_buf = buf3;

	for(int i = 0; i < 4; i++)
	{
                //SVDs
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 0;
	}

	printf("\nClean SVDs - send all zeros\n");
	esp_run(cfg_multi2, 4);

	init_buffer_svd(buf_svd0, gold_svd0);
	init_buffer_svd(buf_svd1, gold_svd1);
	init_buffer_svd(buf_svd2, gold_svd2);
	init_buffer_svd(buf_svd3, gold_svd3);

	//First load data into SVDs->Sinkhorns
	for(int i = 0; i < 4; i++)
	{
                //SVDs
		((struct svd_access*) cfg_multi2[i].esp_desc)->src_offset = size;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_in = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_iter = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 0;

		//Configure Sinkhorns
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_out = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_in = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_iter = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->store_state = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_nsrcs = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_store = 0;

	}

	printf("\n  ** START **\n");

	printf("\n Run SVD->Sinkhorns \n");
	esp_run(cfg_multi2, 8);

	//Run Sinkhorns->SVDs with p2p no load from memory
	for(int i = 0; i< 4; i++)
	{
		//SVD
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_in = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_iter = N;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 0;
		//Sinkhorn
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_out = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_in = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_iter = N+1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_nsrcs = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_store = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->store_state = 3;
	}

	printf("\nRun SVD->Sinkhorn for %d iterations (no norm break)\n", N);
	esp_run(cfg_multi2, 8);

	for(int i = 0; i< 4; i++)
	{
		//SVD
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_in = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_iter = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 2;
		((struct svd_access*) cfg_multi2[i].esp_desc)->dst_offset = size;
		//Sinkhorn
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_out = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_in = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->p2p_iter = 1;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_nsrcs = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->esp.p2p_store = 0;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->store_state = 2;
		((struct sinkhorn_access*) cfg_multi2[i+4].esp_desc)->dst_offset = 0;
	}

	printf("\nStore data from SVD and Sinkhorn\n");
	esp_run(cfg_multi2, 8);

	printf("\n  ** DONE **\n");

	printf("\nResults from HiWA.0:\n");
	errors0 = validate_final(&buf_svd0[out_offset_svd], &buf0[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.1:\n");
	errors1 = validate_final(&buf_svd1[out_offset_svd], &buf1[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.2:\n");
	errors2 = validate_final(&buf_svd2[out_offset_svd], &buf2[out_offset], finalR, finalQ);
	printf("\nResults from HiWA.3:\n");
	errors3 = validate_final(&buf_svd3[out_offset_svd], &buf3[out_offset], finalR, finalQ);

	printf("\n");
	if (!errors0)
		printf("+ Test0 PASSED\n");
	else
		printf("+ Test0 FAILED\n");

	if (!errors1)
		printf("+ Test1 PASSED\n");
	else
		printf("+ Test1 FAILED\n");

	if (!errors2)
		printf("+ Test2 PASSED\n");
	else
		printf("+ Test2 FAILED\n");

	if (!errors3)
		printf("+ Test3 PASSED\n");
	else
		printf("+ Test3 FAILED\n");


	printf("\n====== %s-%s P2P 50 Iterations (norm break) ======\n\n", cfg_p2p[0].devname, cfg_p2p[1].devname);



	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 4xSVD -> 4xSinkhorn Test no norm break$=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");


	free(gold_svd0);
	free(gold_svd1);
	free(gold_svd2);
	free(gold_svd3);
	free(gold0);
	free(gold1);
	free(gold2);
	free(gold3);
	esp_free(buf0);
	esp_free(buf1);
	esp_free(buf2);
	esp_free(buf3);

	return errors0+errors1+errors2+errors3;
	return 0;
 }
