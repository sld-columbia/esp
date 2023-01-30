#include "../inc/espacc_config.h"
#include "../inc/espacc.h"
#include "../inc/input.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {

    printf("****start*****\n");

    /* <<--params-->> */
    const unsigned q = 177;
    const unsigned p = 229;
    const unsigned m = 3;
    unsigned p2p_out = 1;
    unsigned p2p_in = 0;
    unsigned p2p_iter = 1;
    unsigned load_state = 0;

    uint32_t in_words_adj;
    uint32_t out_words_adj;
    uint32_t in_size;
    uint32_t out_size;
    uint32_t dma_in_size;
    uint32_t dma_out_size;
    uint32_t dma_size;


    in_words_adj = round_up(p*q+m*p+m*q+m*m+1, VALUES_PER_WORD);
    out_words_adj = round_up(m*m+m*p+m*q, VALUES_PER_WORD);
    if(p2p_out == 1)
        out_words_adj = round_up(m*p+m*q, VALUES_PER_WORD);
    in_size = in_words_adj * (1);
    out_size = out_words_adj * (4);

    dma_in_size = in_size / VALUES_PER_WORD;
    dma_out_size = out_size / VALUES_PER_WORD;
    dma_size = dma_in_size + dma_out_size;

    dma_word_t *mem=(dma_word_t*) malloc(dma_size * sizeof(dma_word_t));
    word_t *inbuff=(word_t*) malloc(in_size * sizeof(word_t));
    word_t *outbuff=(word_t*) malloc(out_size * sizeof(word_t));
    word_t *outbuff_gold= (word_t*) malloc(out_size * sizeof(word_t));
    dma_info_t load;
    dma_info_t store;


    // Prepare input data
    for(unsigned i = 0; i < 1; i++)
    {
        unsigned j = 0;
        for(; j < p*q; j++) //Q
        {
            word_fixed_t val = (word_t) 1/(p * q);
            // printf("val = %f \n", val.to_float());
            inbuff[i * in_words_adj + j] = val;

        }
        unsigned x = 0;
        for(; x < m*p; x++) //X
            inbuff[i * in_words_adj + j + x] = inputX[x];

        unsigned y = 0;
        for(; y < m*q; y++) //Y
            inbuff[i * in_words_adj + j + x + y] = inputY[y];

        unsigned t = 0;
        for(; t < m*m; t++) //T
                inbuff[i * in_words_adj + j + x + y + t] = inputT[t];


        inbuff[i * in_words_adj + j + x + y + t] = inputP;

    }

    for(unsigned i = 0; i < dma_in_size; i++)
	for(unsigned k = 0; k < VALUES_PER_WORD; k++)
	    mem[i].word[k] = inbuff[i * VALUES_PER_WORD + k];


    for(unsigned i = 0; i < m; i++)
        for(unsigned j = 0; j < m; j++)
            gold_out_2d[i][j] = gold_out[i * m + j];

    word_t gold_out_sink[M_MAX][P_MAX];
    word_t X_2d[P_MAX][M_MAX] = {{0}};
    word_t Y_2d_t[M_MAX][Q_MAX] = {{0}};

    for(unsigned i = 0; i < p; i++)
        for(unsigned j = 0; j < m; j++)
            X_2d[i][j] = inputX[i * m + j];

    for(unsigned i = 0; i < q; i++)
        for(unsigned j = 0; j < m; j++)
        {
            Y_2d_t[j][i] = inputY[i * m + j];
            // printf("index %d Y_2d saved value: %f %f \n", i*m+j, Y_2d_t[j][i].to_float(), inputY[i * m + j].to_float());
        }

    //For Sinkhorn
    hls::matrix_multiply<hls::NoTranspose, hls::Transpose,
                    M_MAX /*A_ROWS*/, M_MAX /*A_COLS*/, P_MAX /*X_ROWS*/, M_MAX /*X_COLS*/,
                    M_MAX /*X_SINK_ROWS*/, P_MAX /*X_SINK_COLS*/,
                    word_t, word_t> (gold_out_2d, X_2d, gold_out_sink);

    // Set golden output
    for(unsigned i = 0; i < 1; i++)
    {
        unsigned j = 0;
        if(p2p_out == 0)
            for(; j < m*m; j++)
                outbuff_gold[i * out_words_adj + j] = (word_t) gold_out[j];
        unsigned k = 0;
        for(; k < m*p; k++)
            outbuff_gold[i * out_words_adj + j + k] = (word_t) gold_out_sink[k / p][k % p];
        unsigned h = 0;
        for(; h < m*q; h++)
        {
            outbuff_gold[i * out_words_adj + j + k + h] = (word_t) Y_2d_t[h / q][h % q];
            // printf("index %d Y_2d saved value: %.20f \n", i * out_words_adj + j + k + h, Y_2d_t[h / q][h % q]);
        }
    }

    load_state = 1;// only load
    //p2p_out = 0;
    p2p_in = 0;
    p2p_iter = 1;

    // Call the TOP function
    top(mem, mem,
        /* <<--args-->> */
        q,
        p,
        m,
        p2p_out,
        p2p_in,
        p2p_iter,
        load_state,
        load, store);

    load_state = 2; // compute and store
    p2p_iter = 4;
    p2p_in = 1;
    p2p_out = 1;

    top(mem, mem,
        /* <<--args-->> */
        q,
        p,
        m,
        p2p_out,
        p2p_in,
        p2p_iter,
        load_state,
        load, store);


    load_state = 2; // compute and store
    p2p_iter = 1;
    p2p_in = 0;
    p2p_out = 1;

    top(mem, mem,
        /* <<--args-->> */
        q,
        p,
        m,
        p2p_out,
        p2p_in,
        p2p_iter,
        load_state,
        load, store);


    // Validate
    uint32_t out_offset = dma_in_size;
    for(unsigned i = 0; i < dma_out_size; i++)
	for(unsigned k = 0; k < VALUES_PER_WORD; k++)
        {
	    outbuff[i * VALUES_PER_WORD + k] = mem[out_offset + i].word[k];
            // printf("%f \n", outbuff[i * VALUES_PER_WORD + k]);
        }

    int errors = 0;
    float MAE_sum = 0;
    float MAE = 0;
    int check_size = m*m+m*p;
    int start_idx = 0;
    if(p2p_out == 1)
    {
        check_size = m*p;
        start_idx = m*m;
    }
    for(unsigned i = 0; i < 1; i++)
        for(unsigned j = 0; j < check_size/*+m*q*/; j++)
        {
#if IS_TYPE_FLOAT
           MAE = (outbuff[i * out_words_adj + j] - outbuff_gold[i * out_words_adj + j])/outbuff_gold[i * out_words_adj + j];

            printf("%d: out = %.20f , gold = %.20f \n", j, outbuff[i *
            VALUES_PER_WORD + j], outbuff_gold[i * out_words_adj + j]);

#else
            MAE = (outbuff[i * out_words_adj + j].to_float() - outbuff_gold[i * out_words_adj + j].to_float())/outbuff_gold[i * out_words_adj + j].to_float();

            printf("%d: out = %.20f , gold = %.20f \n", j, outbuff[i *
            VALUES_PER_WORD + j].to_float(), outbuff_gold[i * out_words_adj + j].to_float());
#endif

            // printf("MAE is %f \n", MAE);
	    // if (outbuff[i * out_words_adj + j] != outbuff_gold[i * out_words_adj + j])
	    //     errors++;

            MAE_sum += pow(MAE,2);
            if (MAE < -0.3 || MAE > 0.3)
            {
	        errors++;
                printf("ERROR index is %u \n\n\n", j);
            }
        }

    float num = m*m+p*m;
    printf("Sum of errors is %f \n", MAE_sum / num);
    if (MAE_sum / num > 0.0001)
    {
        printf("ERROR in total. \n");
        errors++;
    }

    if (errors)
	std::cout << "Test FAILED with " << errors << " errors." << std::endl;
    else
	std::cout << "Test PASSED." << std::endl;

    // Free memory

    free(mem);
    free(inbuff);
    free(outbuff);
    free(outbuff_gold);

    return 0;
}
