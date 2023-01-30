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

static int validate_final(token_t *out_svd, token_t* out_hiwa, float* final_svd, float final_hiwa, int32_t p_i, int32_t q_i)
{
	int i, j;
	unsigned errors = 0;
	float MAE, MAE_sum = 0;
	float val_out, val_gold;

	for (i = 0; i < 1; i++)
	{
		for (j = 0; j < m_rows*m_rows; j++)
		{
			val_out = fixed32_to_float(out_svd[i * out_words_adj_svd + j], 11);
			val_gold = final_svd[i * out_words_adj_svd + j];

			MAE = (val_out - val_gold) / val_gold;

			printf("R: %d: out = %f , gold = %f \n", j, val_out, val_gold);

			MAE_sum += pow(MAE,2);

			if (MAE < -0.1 || MAE > 0.1)
			{
				printf("More than 10 percent error in value \n");
				//errors++;
			}
		}

		val_out = fixed32_to_float(out_hiwa[p_i*q_i], 11);
		val_gold = final_hiwa;

		MAE = (val_out - val_gold) / val_gold;
		if(MAE < 0)
			MAE *= -1;
	}

	printf("Total error in CP sum is %f percent. value: %f gold: %f\n", MAE*100, val_out, val_gold);

	if (MAE > 5)
		errors++;

	printf("Total MSE in R is %f\n", MAE_sum / (m_rows*m_rows));

	if (MAE_sum / (m_rows*m_rows) > 0.11)
		errors++;

	printf("Sum of errors is %d \n", errors);

	return errors;
}

/* User-defined code */

static void init_buffer_svd(token_t *in, int32_t p_i, int32_t q_i, int32_t n, int32_t l)
{

	int i, j, x, y, t;

	for (i = 0; i < 1; i++)
	{
		for(j = 0; j < p_i*q_i; j++) //Q
		{
			float val = (float) 1/(p_i * q_i);
			in[i * in_words_adj_svd + j] = (token_t) float_to_fixed32(val, 11);
		}

		for(x = 0; x < m_rows*p_i; x++) //X
		{
			in[i * in_words_adj_svd + j + x] = (token_t) float_to_fixed32(X_tot[n][x], 11);
		}

		for(y = 0; y < m_rows*q_i; y++) //Y
		{
			in[i * in_words_adj_svd + j + x + y] = (token_t) float_to_fixed32(Y_tot[l][y], 11);
		}


		for(t = 0; t < m_rows*m_rows; t++) //T
		{
			in[i * in_words_adj_svd + j + x + y + t] = (token_t) float_to_fixed32(inputT[t],11);
		}

		in[i * in_words_adj_svd + j + x + y + t] = (token_t) float_to_fixed32(inputP,11);

	}

	printf("  Generated all inputs \n");
}


/* User-defined code */
static void init_parameters(int32_t p_i, int32_t q_i)
{
	if (DMA_WORD_PER_BEAT(sizeof(token_t)) == 0) {
		inX_words_adj = p_i * m_rows;
		inY_words_adj = q_i * m_rows;
		in_words_adj = inY_words_adj + inX_words_adj;
		out_words_adj = p_i * q_i + 1;
	} else {
		inX_words_adj = round_up(p_i * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		inY_words_adj = round_up(q_i * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		in_words_adj = round_up((p_i+q_i) * m_rows, DMA_WORD_PER_BEAT(sizeof(token_t)));
		out_words_adj = round_up(p_i * q_i + 1, DMA_WORD_PER_BEAT(sizeof(token_t)));
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
		in_words_adj_svd = p_i*q_i+m_rows*p_i+m_rows*q_i+m_rows*m_rows+1;
		out_words_adj_svd = m_rows*m_rows+m_rows*p_i+m_rows*q_i;
	} else {
		in_words_adj_svd = round_up(p_i*q_i+m_rows*p_i+m_rows*q_i+m_rows*m_rows+1, DMA_WORD_PER_BEAT(sizeof(float)));
		out_words_adj_svd = round_up(m_rows*m_rows+m_rows*p_i+m_rows*q_i, DMA_WORD_PER_BEAT(sizeof(float)));
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

	token_t *buf0;
	token_t *buf1;
	token_t *buf2;
	token_t *buf3;

	token_t *buf_svd0;
	token_t *buf_svd1;
	token_t *buf_svd2;
	token_t *buf_svd3;

	init_parameters(p_tot[0], q_tot[0]);

	buf0 = (token_t *) esp_alloc(size+size_svd);
	buf1 = (token_t *) esp_alloc(size+size_svd);
	buf2 = (token_t *) esp_alloc(size+size_svd);
	buf3 = (token_t *) esp_alloc(size+size_svd);

	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 4xSVD -> 4xSinkhorn Test $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");

	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
	{
		buf0[i] = 0;
		buf1[i] = 0;
		buf2[i] = 0;
		buf3[i] = 0;
	}

	buf_svd0 = &buf0[size/sizeof(token_t)];
	buf_svd1 = &buf1[size/sizeof(token_t)];
	buf_svd2 = &buf2[size/sizeof(token_t)];
	buf_svd3 = &buf3[size/sizeof(token_t)];

	printf("\n====== one batch %s-%s 50 Iterations (norm break) ======\n\n", cfg_multi2[0].devname, cfg_multi2[1].devname);

	/* <<--print-params-->> */
	printf("  .maxiter = %d\n", maxiter);
	printf("  .gamma = %f\n", gamma_float);
	printf("  .q = %d\n", q_tot[0]);
	printf("  .p = %d\n", p_tot[0]);
	printf("  .m = %d\n", m_rows);

	((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[5].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[6].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
	((struct sinkhorn_access*) cfg_multi2[7].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);

	((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->q_cols = q_tot[0];
	((struct sinkhorn_access*) cfg_multi2[5].esp_desc)->q_cols = q_tot[0];
	((struct sinkhorn_access*) cfg_multi2[6].esp_desc)->q_cols = q_tot[0];
	((struct sinkhorn_access*) cfg_multi2[7].esp_desc)->q_cols = q_tot[0];
	((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->p_rows = p_tot[0];
	((struct sinkhorn_access*) cfg_multi2[5].esp_desc)->p_rows = p_tot[0];
	((struct sinkhorn_access*) cfg_multi2[6].esp_desc)->p_rows = p_tot[0];
	((struct sinkhorn_access*) cfg_multi2[7].esp_desc)->p_rows = p_tot[0];

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
		((struct svd_access*) cfg_multi2[i].esp_desc)->q = q_tot[0];
		((struct svd_access*) cfg_multi2[i].esp_desc)->p = p_tot[0];
	}

	printf("\nClean SVDs - send all zeros\n");
	esp_run(cfg_multi2, 4);

	init_buffer_svd(buf_svd0, p_tot[0], q_tot[0], 0, 0);
	init_buffer_svd(buf_svd1, p_tot[0], q_tot[0], 0, 0);
	init_buffer_svd(buf_svd2, p_tot[0], q_tot[0], 0, 0);
	init_buffer_svd(buf_svd3, p_tot[0], q_tot[0], 0, 0);

	//First load data into SVDs
	for(int i = 0; i < 4; i++)
	{
		((struct svd_access*) cfg_multi2[i].esp_desc)->src_offset = size;
		((struct svd_access*) cfg_multi2[i].esp_desc)->dst_offset = size;
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

	/* printf("\nRun sinkhorn.0 just for sanity check\n"); */
	/* ((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->p2p_in = 0; */
	/* ((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->p2p_out = 0; */
	/* ((struct sinkhorn_access*) cfg_multi2[4].esp_desc)->esp.p2p_nsrcs = 0; */
	/* esp_run(&cfg_multi2[4], 1); */

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

	printf("\nRun HiWA = SVD->Sinkhorn for 50 iterations (norm break)\n");
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
	errors0 = validate_final(&buf_svd0[out_offset_svd], &buf0[out_offset], R_tot[0], CP_tot[0], p_tot[0], q_tot[0]);
	printf("\nResults from HiWA.1:\n");
	errors1 = validate_final(&buf_svd1[out_offset_svd], &buf1[out_offset], R_tot[0], CP_tot[0], p_tot[0], q_tot[0]);
	printf("\nResults from HiWA.2:\n");
	errors2 = validate_final(&buf_svd2[out_offset_svd], &buf2[out_offset], R_tot[0], CP_tot[0], p_tot[0], q_tot[0]);
	printf("\nResults from HiWA.3:\n");
	errors3 = validate_final(&buf_svd3[out_offset_svd], &buf3[out_offset], R_tot[0], CP_tot[0], p_tot[0], q_tot[0]);

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

	init_parameters(p_tot[0], q_tot[0]);
	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
	{
		buf0[i] = 0;
		buf1[i] = 0;
		buf2[i] = 0;
		buf3[i] = 0;
	}

	for(int i = 0; i < 4; i++)
	{
                //SVDs
		((struct svd_access*) cfg_multi2[i].esp_desc)->p2p_out = 1;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_nsrcs = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->esp.p2p_store = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->load_state = 0;
		((struct svd_access*) cfg_multi2[i].esp_desc)->q = q_tot[0];
		((struct svd_access*) cfg_multi2[i].esp_desc)->p = p_tot[0];
	}

	printf("\nClean SVDs - send all zeros\n");
	esp_run(cfg_multi2, 4);


	printf("\n====== %s-%s P2P 50 Iterations (norm break) ======\n\n", cfg_p2p[0].devname, cfg_p2p[1].devname);

	//return errors0+errors1+errors2+errors3;



	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ All datasets 4xSVD -> 4xSinkhorn Test $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");


	int32_t errors[4][4];

	token_t* buf[16];
	token_t* buf_svd[16];
	token_t* dummy_buf;

        //Initialize memory space for all 16 datasets
	for(int k = 0; k < 4; k++)
		for(int j = 0; j < 4; j++)
		{
			init_parameters(p_tot[k], q_tot[j]);
			buf[k*4+j] = (token_t *) esp_alloc(size+size_svd);
			for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
			{
				buf[k*4+j][i] = 0;
			}

			buf_svd[k*4+j] = &buf[k*4+j][size/sizeof(token_t)];
		}

        //Used to initialize accelerators
	init_parameters(p_tot[0], q_tot[0]); //biggest values
	dummy_buf = (token_t *) esp_alloc(size+size_svd);
	for(int i = 0; i < (size+size_svd)/sizeof(token_t); i++)
	{
		dummy_buf[i] = 0;
	}

	printf("\n====== %s-%s 50 Iterations (norm break) ======\n\n", cfg_multi2[0].devname, cfg_multi2[1].devname);

	for(int i = 0; i < 4; i++)
	{
                //Initialize and clean
		for(int j = 0; j < 4; j++)
		{
			/* <<--print-params-->> */
			printf("  .maxiter = %d\n", maxiter);
			printf("  .gamma = %f\n", gamma_float);
			printf("  .q = %d\n", q_tot[j]);
			printf("  .p = %d\n", p_tot[i]);
			printf("  .m = %d\n", m_rows);

			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->gamma = float_to_fixed32(gamma_float, 11);
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->q_cols = q_tot[j];
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->p_rows = p_tot[i];

			cfg_multi2[j].hw_buf = buf[i*4+j];
			cfg_multi2[j+4].hw_buf = buf[i*4+j];

			/* init_parameters(p_tot[i], q_tot[j]); */
			/* ((struct svd_access*) cfg_multi2[j].esp_desc)->src_offset = size; */
			/* ((struct svd_access*) cfg_multi2[j].esp_desc)->dst_offset = size; */
			/* ((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_out = 1; */
			/* ((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_nsrcs = 0; */
			/* ((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_store = 0; */
			/* ((struct svd_access*) cfg_multi2[j].esp_desc)->load_state = 0; */
			((struct svd_access*) cfg_multi2[j].esp_desc)->q = q_tot[j];
			((struct svd_access*) cfg_multi2[j].esp_desc)->p = p_tot[i];

			/* for(int k = 0; k < (size+size_svd)/sizeof(token_t); k++) */
			/* { */
			/* 	buf[j][k] = 0; */
			/* } */

		}

		/* printf("\nClean SVDs - send all zeros\n"); */
		/* esp_run(cfg_multi2, 4); */

		//First load data into SVDs
		for(int j = 0; j < 4; j++)
		{
			init_parameters(p_tot[i], q_tot[j]);
			init_buffer_svd(buf_svd[i*4+j], p_tot[i], q_tot[j], i, j );
			((struct svd_access*) cfg_multi2[j].esp_desc)->src_offset = size;
			((struct svd_access*) cfg_multi2[j].esp_desc)->dst_offset = size;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_out = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_in = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_iter = 1;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_nsrcs = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_store = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->load_state = 1;
		}

		printf("\n  ** START **\n");

		printf("\nLoad data into SVDs\n");
		esp_run(cfg_multi2, 4);

		//Run SVDs-Sinkhorns with p2p no load from memory
		for(int j = 0; j < 4; j++)
		{
			//SVD
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_out = 1;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_in = 1;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_iter = 50;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_nsrcs = 1;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_store = 1;
			((struct svd_access*) cfg_multi2[j].esp_desc)->load_state = 2;
			//Sinkhorn
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->p2p_out = 1;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->p2p_in = 1;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->p2p_iter = 50;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->esp.p2p_nsrcs = 1;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->esp.p2p_store = 1;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->store_state = 1;
		}

		printf("\nRun SVD->Sinkhorn for 50 iterations (norm break)\n");
		esp_run(cfg_multi2, 8);

 		for(int j = 0; j < 4; j++)
		{
			//SVD
			init_parameters(p_tot[i], q_tot[j]);
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_out = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_in = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_iter = 1;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_nsrcs = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_store = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->load_state = 2;
			((struct svd_access*) cfg_multi2[j].esp_desc)->dst_offset = size;
			//Sinkhorn
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->p2p_out = 0;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->p2p_in = 0;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->p2p_iter = 1;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->esp.p2p_nsrcs = 0;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->esp.p2p_store = 0;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->store_state = 2;
			((struct sinkhorn_access*) cfg_multi2[j+4].esp_desc)->dst_offset = 0;
		}

		printf("\nStore data from SVD and Sinkhorn\n");
		esp_run(cfg_multi2, 8);

		printf("\n  ** DONE **\n");

		for(int j = 0; j < 4; j++)
		{
			init_parameters(p_tot[0], q_tot[0]); //biggest values
			((struct svd_access*) cfg_multi2[j].esp_desc)->src_offset = size;
			((struct svd_access*) cfg_multi2[j].esp_desc)->dst_offset = size;
			((struct svd_access*) cfg_multi2[j].esp_desc)->p2p_out = 1;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_nsrcs = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->esp.p2p_store = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->load_state = 0;
			((struct svd_access*) cfg_multi2[j].esp_desc)->q = q_tot[0];
			((struct svd_access*) cfg_multi2[j].esp_desc)->p = p_tot[0];

			cfg_multi2[j].hw_buf = dummy_buf;
		}

		printf("\nClean SVDs - send all zeros\n");
		esp_run(cfg_multi2, 4);


	}

	printf("\n");

	for(int i = 0; i < 4; i++)
		for(int j = 0; j< 4; j++)
		{
			printf("\nResults from HiWA.%d:\n", j);
			init_parameters(p_tot[i], q_tot[j]);
			errors[i][j] = validate_final(&buf_svd[i*4+j][out_offset_svd],
						&buf[i*4+j][out_offset],
						R_tot[i*4+j], CP_tot[i*4+j], p_tot[i], q_tot[j]);

			if (!errors[i][j])
				printf("+ Test (%d,%d) PASSED\n", i, j);
			else
				printf("+ Test (%d, %d) FAILED\n", i ,j);
		}


	printf("\n====== %s-%s P2P 50 Iterations (norm break) ======\n\n", cfg_multi2[0].devname, cfg_multi[4].devname);

	printf("\n$=$=$=$=$=$=$=$=$=$=$=$=$=$ 4xSVD -> 4xSinkhorn Test $=$=$=$=$=$=$=$=$=$=$=$=$=$\n\n");

	int tot_errors = 0;
	for(int i = 0; i < 4; i++)
	{
		for(int j = 0; j < 4; j++)
		{
			esp_free(buf[i*4 + j]);
			tot_errors += errors[i][j];
		}
	}

	esp_free(buf0);
	esp_free(buf1);
	esp_free(buf2);
	esp_free(buf3);

	return tot_errors;
	return 0;
 }
