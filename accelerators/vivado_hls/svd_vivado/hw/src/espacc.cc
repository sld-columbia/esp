#include "../inc/espacc_config.h"
#include "../inc/espacc.h"
#include "hls_stream.h"
#include "hls_math.h"
#include <cstring>

//Inputs: Q(pxq), Y(mxq), X(mxp), T(mxm), P(1x1)
//Output: UxV_h(mxm)

void load(word_t Q[P_MAX][Q_MAX], word_t X[P_MAX][M_MAX],
          word_t Y[Q_MAX][M_MAX], word_t T[M_MAX][M_MAX], word_t &P, dma_word_t *in1,
          /* <<--compute-params-->> */
          const unsigned q,
          const unsigned p,
          const unsigned m,
          const unsigned p2p_in,
          const unsigned b,
          const unsigned load_state,
	  dma_info_t &load_ctrl)
{
load_data:

#ifndef __SYNTHESIS__
    printf("LOAD STATE: %d \n", load_state);
#endif

    unsigned length = round_up(p*q+m*p+m*q+m*m+1, VALUES_PER_WORD) / 1;
    if(p2p_in == 1)
        length = round_up(p*q, VALUES_PER_WORD);

    const unsigned index = 0; //length * (batch * 1 + chunk);
    const unsigned length_Q = p*q;
    const unsigned length_X = p*m;
    const unsigned length_Y = m*q;
    const unsigned length_T = m*m;

    unsigned X_index = length_Q;
    unsigned Y_index = X_index + length_X;
    unsigned T_index = Y_index + length_Y;
    unsigned P_index = T_index + length_T;
    unsigned row = 0;
    word_t tmp[2];
    word_t dummy;

    unsigned dma_length = length / VALUES_PER_WORD;
    unsigned dma_index = index / VALUES_PER_WORD;

    // unsigned dma_length = length >> LOG_VALUES_PER_WORD;
    // unsigned dma_index = index >> LOG_VALUES_PER_WORD;

    if(!(load_state == 2 && b == 0)) // Don't load
    {
        load_ctrl.index = dma_index;
        load_ctrl.length = dma_length;
        load_ctrl.size = SIZE_WORD_T;

#ifndef __SYNTHESIS__
        printf("DMA INFO LOAD: index = %d, length = %d, size = %d \n", dma_index, dma_length, SIZE_WORD_T);
        printf("size of expected read: %d, size of actual read: %d \n", length, P_index+1);
#endif

        //Expect all inputs to SVD to come sequentially
        for (unsigned i = 0; i < dma_length; i++) {

#pragma HLS loop_tripcount max=20881

        load_label0:for(unsigned j = 0; j < VALUES_PER_WORD; j++){
                tmp[j] = in1[dma_index + i].word[j];
                unsigned col_index = 0;
                unsigned total_index = (i * VALUES_PER_WORD) + j;
                if(p2p_in == 1 && total_index >= length_Q)
                    // We need this so we don't overwrite the data after Q
                    break;
                //Make the arrays 2D with an offset\counter that jumps when needed
                if (total_index < X_index){
                    col_index = total_index - row*q;
                    Q[row][col_index] = tmp[j];
                    if(col_index == q-1)
                        row++;
                    if(row == p)
                        row = 0;
                }
                else if (total_index < Y_index){
                    col_index = total_index - X_index - row*m;
                    X[row][col_index] = tmp[j];
                    if(col_index == m-1)
                        row++;
                    if(row == p)
                        row = 0;
                }
                else if (total_index < T_index){
                    col_index = total_index - Y_index - row*m;
                    Y[row][col_index] = tmp[j];
                    if(col_index == m-1)
                        row++;
                    if(row == q)
                        row = 0;
                }
                else if (total_index < P_index){
                    col_index = total_index - T_index - row*m;
                    T[row][col_index] = tmp[j];
                    if(col_index == m-1)
                        row++;
                    if(row == m)
                        row = 0;
                }
                else if (total_index == P_index){
                    P = tmp[j];
                    //printf("index read by P is: %d, dma_length: %d \n", total_index, i+1);
                }
                else{
                    dummy = tmp[j];
                    printf("index read by tmp is: %d, dma_length: %d \n", total_index, i+1);
                }
            }
        }
    }
}

void store(word_t _outbuff[SIZE_OUT_CHUNK_DATA], dma_word_t *out,
           /* <<--compute-params-->> */
           const unsigned q,
           const unsigned p,
           const unsigned m,
           const unsigned p2p_out,
           const unsigned b,
           const unsigned load_state,
	   dma_info_t &store_ctrl)
{
store_data:

    unsigned length = round_up(m*m+m*p+m*q, VALUES_PER_WORD);
    unsigned offset = M_MAX*M_MAX;
    if(p2p_out == 1)
        length = round_up(m*p+m*q+1, VALUES_PER_WORD);
    else
        offset = 0;
    const unsigned store_offset = round_up(p*q+m*p+m*q+m*m+1, VALUES_PER_WORD);
    const unsigned out_offset = store_offset;
    const unsigned index = out_offset + length * b; // + length * (batch * 1 + chunk);

    unsigned dma_length = length / VALUES_PER_WORD;
    unsigned dma_index = index / VALUES_PER_WORD;

    // unsigned dma_length = length >> LOG_VALUES_PER_WORD;
    // unsigned dma_index = index >> LOG_VALUES_PER_WORD;

    if(load_state != 1)
    {
        store_ctrl.index = dma_index;
        store_ctrl.length = dma_length;
        store_ctrl.size = SIZE_WORD_T;//32

#ifndef __SYNTHESIS__
        printf("DMA INFO STORE: index = %d, length = %d, size = %d \n", dma_index, dma_length, SIZE_WORD_T);
#endif

        for (unsigned i = 0; i < dma_length; i++) {

#pragma HLS loop_tripcount max=614

        store_label1:for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
                out[dma_index + i].word[j] = _outbuff[(i * VALUES_PER_WORD) + j + offset];
            }
        }
    }
}


//void compute(word_t _inbuff[SIZE_IN_CHUNK_DATA],
void compute(word_t Q[P_MAX][Q_MAX], word_t X[P_MAX][M_MAX],
	word_t Y[Q_MAX][M_MAX], word_t T[M_MAX][M_MAX], word_t &P,
             /* <<--compute-params-->> */
             const unsigned q,
             const unsigned p,
             const unsigned m,
             const unsigned p2p_out,
             const unsigned load_state,
             unsigned &b,
             const unsigned p2p_iter,
             word_t _outbuff[SIZE_OUT_CHUNK_DATA])
{
compute_data:

#ifndef __SYNTHESIS__
    printf("Inside compute \n");
#endif

    unsigned X_size = p*m;
    unsigned Y_size = q*m;
    unsigned T_size = m*m;

    //Inputs
    //word_t Y[Q_MAX][M_MAX];
    //word_t X[P_MAX][M_MAX];
    //word_t T[M_MAX][M_MAX];
    //word_t Q[P_MAX][Q_MAX];

    //Computed
    word_t C[M_MAX][P_MAX];
    word_t A[M_MAX][M_MAX];
    float A_f[M_MAX][M_MAX];
    // word_t U[M_MAX][M_MAX];
    // word_t S[M_MAX][M_MAX];
    // word_t V[M_MAX][M_MAX];
    float U_f[M_MAX][M_MAX];
    float S_f[M_MAX][M_MAX];
    float V_f[M_MAX][M_MAX];
    word_t X_SINK[M_MAX][P_MAX];
    //word_t Y_SINK[M_MAX][Q_MAX];

    word_t P_d = P * 2; //Double the amount of P

#ifndef __SYNTHESIS__
    printf("All pointers are set \n");
#endif

    if(load_state != 1)
    {

#ifndef __SYNTHESIS__
        //printf("Saved Q \n");
        // printf("Q = \n");
        // hls::print_matrix<P_MAX, Q_MAX, word_t, hls::NoTranspose>((word_t(*)[Q_MAX])Q, "   ");
#endif

#ifndef __SYNTHESIS__
        //printf("Saved X \n");
        // printf("X = \n");
        // hls::print_matrix<P_MAX, M_MAX, word_t, hls::NoTranspose>((word_t(*)[M_MAX])X, "   ");
#endif

#ifndef __SYNTHESIS__
        //printf("Saved Y \n");
        // printf("Y = \n");
        // hls::print_matrix<Q_MAX, M_MAX, word_t, hls::NoTranspose>((word_t(*)[M_MAX])Y, "   ");
#endif

        //Compute C = Y.T x Q.T
        hls::matrix_multiply_top<hls::Transpose, hls::Transpose,
                                 Q_MAX /*Y_ROWS*/, M_MAX /*Y_COLS*/, P_MAX /*Q_ROWS*/, Q_MAX /*Q_COLS*/,
                                 M_MAX /*C_ROWS*/, P_MAX /*C_COLS*/,
                                 TRAITS_C,
                                 word_t, word_t> (/*(word_t(*)[M_MAX])*/Y, /*(word_t(*)[Q_MAX])*/Q, C);

#ifndef __SYNTHESIS__
        printf("Computed Y.T*O.T \n");
        // printf("Y.T*O.T = \n");
        // hls::print_matrix<M_MAX, P_MAX, word_t, hls::NoTranspose>(C, "   ");
#endif

        //Compute A = C x X
        hls::matrix_multiply_top<hls::NoTranspose, hls::NoTranspose,
                                 M_MAX /*C_ROWS*/, P_MAX /*C_COLS*/, P_MAX /*X_ROWS*/, M_MAX /*X_COLS*/,
                                 M_MAX /*C_ROWS*/, M_MAX /*C_COLS*/,
                                 TRAITS_A,
                                 word_t, word_t> (C, /*(word_t(*)[M_MAX])*/X, A);

#ifndef __SYNTHESIS__
        printf("Computed (Y.T*O.T)*X \n");
        printf("(Y.T*O.T)*X = \n");
        hls::print_matrix<M_MAX, M_MAX, word_t, hls::NoTranspose>(A, "   ");
#endif

        //Multiply A elementwize with P_d and add T
    LOOP_A1:for(int i = 0; i < M_MAX; i++)
        LOOP_A2:for(int j = 0; j < M_MAX; j++)
            {
                if (i < m && j < m)
                {
                    A[i][j] = T[i][j] + P_d * A[i][j];
#if IS_TYPE_FLOAT
                    A_f[i][j] = A[i][j];
#else
                    A_f[i][j] = A[i][j].to_float();
#endif
                }
            }

#ifndef __SYNTHESIS__
#if IS_TYPE_FLOAT
        printf("2*P is %f \n", P);
#else
        printf("2*P is %f \n", P.to_float());
#endif
        printf("Saved 2P*A+T \n");
        printf("A = 2P*A + T = \n");
        hls::print_matrix<M_MAX, M_MAX, word_t, hls::NoTranspose>(A, "   ");
        // hls::print_matrix<M_MAX, M_MAX, float, hls::NoTranspose>(A_f, "   ");
#endif

        // Call SVD
        // hls::svd<M_MAX/*A_ROWS*/, M_MAX/*A_COLS*/, word_t, word_t>(A, S, U, V);
        hls::svd_top<M_MAX/*A_ROWS*/, M_MAX/*A_COLS*/, TRAITS_SVD, float, float>(A_f, S_f, U_f, V_f);

#ifndef __SYNTHESIS__
        printf("Finished computing svd(A) \n");
        printf("S = \n");
        // hls::print_matrix<M_MAX, M_MAX, word_t, hls::NoTranspose>(S, "   ");
        // printf("U = \n");
        // hls::print_matrix<M_MAX, M_MAX, word_t, hls::NoTranspose>(U, "   ");
        // printf("V = \n");
        // hls::print_matrix<M_MAX, M_MAX, word_t, hls::NoTranspose>(V, "   ");
        hls::print_matrix<M_MAX, M_MAX, float, hls::NoTranspose>(S_f, "   ");
        printf("U = \n");
        hls::print_matrix<M_MAX, M_MAX, float, hls::NoTranspose>(U_f, "   ");
        printf("V = \n");
        hls::print_matrix<M_MAX, M_MAX, float, hls::NoTranspose>(V_f, "   ");
#endif

        // //Final computation
        // hls::matrix_multiply<hls::NoTranspose, hls::ConjugateTranspose,
        //                 M_MAX /*U_ROWS*/, M_MAX /*U_COLS*/, M_MAX /*V_ROWS*/, M_MAX /*V_COLS*/,
        //                 M_MAX /*A_ROWS*/, M_MAX /*A_COLS*/,
        //                 word_t, word_t> (U, V, A);

        //Final computation
        hls::matrix_multiply_top<hls::NoTranspose, hls::ConjugateTranspose,
                                 M_MAX /*U_ROWS*/, M_MAX /*U_COLS*/, M_MAX /*V_ROWS*/, M_MAX /*V_COLS*/,
                                 M_MAX /*A_ROWS*/, M_MAX /*A_COLS*/,
                                 TRAITS_A_F,
                                 float, float> (U_f, V_f, A_f);

    LOOP_A3:for(int i = 0; i < M_MAX; i++)
        LOOP_A4:for(int j = 0; j < M_MAX; j++)
            {
                if (i < m && j < m)
                {
                    A[i][j] = A_f[i][j];
                }
            }


#ifndef __SYNTHESIS__
        printf("Computed U*V.T \n");
        printf("U*V.T = \n");
        hls::print_matrix<M_MAX, M_MAX, word_t, hls::NoTranspose>(A, "   ");
#endif

        //For Sinkhorn
        hls::matrix_multiply_top<hls::NoTranspose, hls::Transpose,
                                 M_MAX /*A_ROWS*/, M_MAX /*A_COLS*/, P_MAX /*X_ROWS*/, M_MAX /*X_COLS*/,
                                 M_MAX /*X_SINK_ROWS*/, P_MAX /*X_SINK_COLS*/,
                                 TRAITS_X_SINK,
                                 word_t, word_t> (A, /*(word_t(*)[M_MAX])*/X, X_SINK);

#ifndef __SYNTHESIS__
        printf("Computed A*X.T \n");
        // printf("X_SINK = \n");
        // hls::print_matrix<M_MAX, P_MAX, word_out_t, hls::NoTranspose>(X_SINK, "   ");
#endif

        int i = 0, j = 0, k = 0;//, r = 0;
        int ii, jj, kk;
        word_t norm_sum = 0;

LOOP_OUT1:for (; i < m; i++)//T_size
            {
#pragma HLS loop_tripcount max=3

            LOOP_OUT11:for(ii = 0; ii < m; ii++)
                {
#pragma HLS loop_tripcount max=3

                    word_t val = A[i][ii];
                    word_t prev_val = _outbuff[i*m+ii];
                    if(p2p_out == 1)
                        norm_sum += (val-prev_val)*(val-prev_val);
                    _outbuff[i*m+ii] = val;

                }

            LOOP_OUT22:for(jj = 0; jj < p; jj++)
                {
#pragma HLS loop_tripcount max=229

                    _outbuff[T_size+i*p+jj] = X_SINK[i][jj];
                }

            LOOP_OUT33:for(kk = 0; kk < q; kk++)
                {
#pragma HLS loop_tripcount max=177

                    _outbuff[T_size+X_size+i*q+kk] = Y[kk][i];
                }
            }

        if(p2p_out == 1)//Communicating with Sinkhorn - send norm check
        {

#ifndef __SYNTHESIS__
#if IS_TYPE_FLOAT
            printf("norm_sum is %f \n", norm_sum);
#else
            printf("norm_sum is %f \n", norm_sum.to_float());
#endif
#endif

            if(norm_sum < 0.0002 && load_state != 0)
            {
#ifndef __SYNTHESIS__
                printf("Assigning b\n");
#endif
                _outbuff[T_size+X_size+Y_size] = 1.0; //norm check
                b = p2p_iter - 1;
            }
            else _outbuff[T_size+X_size+Y_size] = 0;

        }
    }
}


void top(dma_word_t *out, dma_word_t *in1,
         /* <<--params-->> */
	 const unsigned conf_info_q,
	 const unsigned conf_info_p,
	 const unsigned conf_info_m,
	 const unsigned conf_info_p2p_out,
	 const unsigned conf_info_p2p_in,
	 const unsigned conf_info_p2p_iter,
	 const unsigned conf_info_load_state,
	 dma_info_t &load_ctrl, dma_info_t &store_ctrl)
{

    /* <<--local-params-->> */
    const unsigned q = conf_info_q;
    const unsigned p = conf_info_p;
    const unsigned m = conf_info_m;
    const unsigned p2p_out = conf_info_p2p_out;
    const unsigned p2p_in = conf_info_p2p_in;
    const unsigned p2p_iter = conf_info_p2p_iter > 0 ? conf_info_p2p_iter : 1;
    const unsigned load_state = conf_info_load_state;

//load_State = 0, do load compute store as usual
//load_state = 1. do load only
//load_state = 2, do compute store only

#ifndef __SYNTHESIS__
    printf("Inside top \n");
#endif

    static word_t Q[P_MAX][Q_MAX];
    static word_t X[P_MAX][M_MAX];
    static word_t Y[Q_MAX][M_MAX];
    static word_t T[M_MAX][M_MAX];
    static word_t P;

    //static word_t _inbuff[SIZE_IN_CHUNK_DATA];
    static word_t _outbuff[SIZE_OUT_CHUNK_DATA];

    // Batching
batching:
    for (unsigned b = 0; b < p2p_iter; b++)
    {

#pragma HLS loop_tripcount max=1

#ifndef __SYNTHESIS__
        printf("b is %d \n", b);
#endif
    go:
        // load(_inbuff, in1,
        load(Q, X, Y, T, P, in1,
             /* <<--args-->> */
             q,
             p,
             m,
             p2p_in,
             b,
             load_state,
             load_ctrl);

#ifndef __SYNTHESIS__
        printf("Finished load \n");
#endif

        // compute(_inbuff,
        compute(Q, X, Y, T, P,
                /* <<--args-->> */
                q,
                p,
                m,
                p2p_out,
                load_state,
                b,
                p2p_iter,
                _outbuff);

#ifndef __SYNTHESIS__
        printf("Finished compute \n");
#endif

        store(_outbuff, out,
              /* <<--args-->> */
              q,
              p,
              m,
              p2p_out,
              b,
              load_state,
              store_ctrl);

#ifndef __SYNTHESIS__
        printf("Finished store \n");
#endif

        //load_state = 0; //Only the first iteration can have load_state 1 or 2
    }
}
