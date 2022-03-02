// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "sinkhorn.hpp"

// Optional application-specific helper functions

//Inputs: inputX[m*p], inputY[m*q], p, q, m, gamma, maxiter
//Outputs: P[p*q], CP_sum
//Memories: P[q*p], C[q*p], K[q*p], x_a[p], y_b[q], inputX[m*p], inputY[m*q]
//Registers: CP_sum

#ifndef STRATUS_HLS
float min = 100, max = 0, max_error = 0;
#endif

void sinkhorn::compute_C(uint32_t p, uint32_t q, uint32_t m, FPDATA_WORD gamma)
{
    //Function that calculates C and R matrix for sinkhorn kernel

#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Calculating C with p = %u, q = %u, m = %u", p, q ,m);
    float sum_K = 0;
#endif

    FPDATA gamma_fp[READ_INPUT_WRITE_CK];
    HLS_FLAT(gamma_fp);
    FPDATA_WORD gamma_word_val = gamma;
    FPDATA gamma_fp_val;
    cynw_interpret(gamma_word_val, gamma_fp_val);
    gamma_fp_val = 1 / gamma_fp_val;

    for(uint8_t i = 0; i < READ_INPUT_WRITE_CK; i++)
    {
        HLS_UNROLL_LOOP(ON);
        gamma_fp[i] = gamma_fp_val;
    }

    //Calculate C (subtract R already)
    for(uint8_t i = 0; i < P_MAX; i++)
    {
        //HLS_CONSTRAIN_LATENCY("C LOOP");
        if(i >= p){}
        else
        {
            HLS_BREAK_DEP(x_a);
            FPDATA_WORD in_X_word[M_MAX*READ_INPUT_WRITE_CK];
            FPDATA x_a_calc[M_MAX];
            FPDATA x_a_tot;
            HLS_FLAT(in_X_word);
            HLS_FLAT(x_a_calc);

            for(uint8_t k = 0; k < M_MAX; k++)
            {
                //HLS_CONSTRAIN_LATENCY("READ X for C LOOP");
                HLS_UNROLL_LOOP(AGGRESSIVE, M_MAX, "read X for R loop");
                HLS_BREAK_DEP(inputX);

                if(k >= m){}
                else
                {
                    uint32_t X_index = k * p + i;
                    FPDATA_WORD X_word = inputX[X_index];
                    FPDATA in_fp;

#ifndef STRATUS_HLS
            FPDATA data_fp;
            FPDATA_WORD data_word = X_word;
            cynw_interpret(data_word, data_fp);
            // bv2fp<FPDATA, FPDATA_WL, FPDATA_WL>(sc_bv<DMA_WIDTH>(CP_sum), data_fp);
            float data_float;
            fp2native(data_fp, data_float);
            //ESP_REPORT_INFO("inputX = %.20f, index is %d", data_float, X_index);
#endif

                    for(uint8_t d = 0; d < READ_INPUT_WRITE_CK; d++)
                    {
                        HLS_UNROLL_LOOP(ON, "store X for R loop");
                        in_X_word[k+d*m] = X_word;
                    }

                    cynw_interpret(X_word, in_fp);
                    x_a_calc[k] = in_fp * in_fp;

                }
            }

            x_a_tot = x_a_calc[0] + x_a_calc[1] + x_a_calc[2];

            for(uint8_t j = 0; j < Q_MAX; j+=READ_INPUT_WRITE_CK)
            {
                HLS_PIPELINE_LOOP(SOFT_STALL, 1, "write C loop");
                // HLS_CONSTRAIN_ARRAY_MAX_DISTANCE(inputY , 1, "constrain_Y");
                // HLS_CONSTRAIN_ARRAY_MAX_DISTANCE(K , 1, "constrain_K");
                // HLS_CONSTRAIN_ARRAY_MAX_DISTANCE(C , 1, "constrain_C");
                if(j >= q){}
                else
                {
                    //Calculate R: X.T @ Y
                    FPDATA_WORD C_word[READ_INPUT_WRITE_CK];
                    FPDATA C_fp[M_MAX * READ_INPUT_WRITE_CK];
                    FPDATA C_fp_final[READ_INPUT_WRITE_CK];
                    HLS_FLAT(C_fp);
                    HLS_FLAT(C_word);
                    HLS_FLAT(C_fp_final);
                    FPDATA y_b_fp[M_MAX * READ_INPUT_WRITE_CK];
                    HLS_FLAT(y_b_fp);

                    for(uint8_t k = 0; k < M_MAX*READ_INPUT_WRITE_CK; k++)
                    {
                        HLS_BREAK_DEP(inputX);
                        HLS_BREAK_DEP(inputY);

                        if(k >= m * READ_INPUT_WRITE_CK){}// || j*m + k >= q*m){}
                        else
                        {
                            // uint32_t X_index;
                            uint32_t Y_index = 0;
                            if(k < m){
                                Y_index = k * q + j;}
#if (READ_INPUT_WRITE_CK >= 2)
                            else if(k >= m && k < 2*m){
                                Y_index = (k - m) * q + j + 1;}
#endif
#if (READ_INPUT_WRITE_CK >= 3)
                            else if(k >= 2*m && k < 3*m){
                            Y_index = (k - 2 * m) * q + j + 2;}
#endif
#if (READ_INPUT_WRITE_CK >= 4)
                            else{
                            Y_index = (k - 3 * m) * q + j + 3;}
#endif

                            FPDATA in_X_fp;
                            FPDATA_WORD in_Y_word = inputY[Y_index];
                            FPDATA in_Y_fp;

                            cynw_interpret(in_X_word[k], in_X_fp);
                            cynw_interpret(in_Y_word, in_Y_fp);

                            C_fp[k] = in_X_fp * in_Y_fp;
                            //ESP_REPORT_INFO("R[%u] finished", i*q+j+k/m);

                            y_b_fp[k] = in_Y_fp * in_Y_fp;

                        }
                    }

                    for(uint8_t h = 0; h < READ_INPUT_WRITE_CK; h++)
                    {
                        HLS_BREAK_DEP(y_b);
                        HLS_BREAK_DEP(C);
                        HLS_BREAK_DEP(K);

                        if(j + h >= q){}
                        else
                        {
                            FPDATA in_y_fp1 = 0;
                            FPDATA C_fp_tot1 = 0;

                            //C[i * q + j] += y_b[i] + x_a[j] - 2 * C[i * q + j];
                            in_y_fp1 = y_b_fp[h*m] + y_b_fp[h*m+1] + y_b_fp[h*m+2];
                            C_fp_tot1 = C_fp[h*m]+ C_fp[h*m+1] + C_fp[h*m+2];
                            C_fp_final[h] = in_y_fp1 + x_a_tot - 2 * C_fp_tot1;

                            FPDATA K_fp;
                            FPDATA_WORD K_word;
                            K_fp = neg_exp(C_fp_final[h] * gamma_fp[h]);

                            cynw_interpret(K_fp, K_word);
                            K[i * q + j + h] = K_word;

                            cynw_interpret(C_fp_final[h], C_word[h]);
                            C[i * q + j + h] = C_word[h];

                            //ESP_REPORT_INFO("C[%u] finished", i * q + j + h + i);

                        }
                    }
                }
            }
        }
    }


#ifndef STRATUS_HLS
    ESP_REPORT_INFO("Final C finished");
#endif

    //Check C
#ifndef STRATUS_HLS
    float sum = 0;

    for(uint32_t i = 0; i < p*q; i++)
    {
        FPDATA_WORD C_word = C[i];
        FPDATA C_fp = 0;
        cynw_interpret(C_word, C_fp);

        float data_float;
        fp2native(C_fp, data_float);
        //ESP_REPORT_INFO("C[%d] is %.20f", i, data_float);
        sum += data_float;
    }

    ESP_REPORT_INFO("C sum is %f", sum);
#endif

}

void sinkhorn::compute_P(uint32_t p, uint32_t q, uint32_t maxiter/*, FPDATA_WORD gamma*/)
{
#ifndef STRATUS_HLS
    float sum = 0;
#endif



    FPDATA q_fp = q;
    FPDATA b_fp_calc = 1 / q_fp;
    // bool pingpong = true;

    //y_b needs to be initialized with 1/q - can be done outside
    for(uint16_t i = 0 ; i < Q_MAX; i+=INIT_B)
    {
        //HLS_CONSTRAIN_LATENCY("INIT B LOOP");
        HLS_PIPELINE_LOOP(SOFT_STALL, 1, "init b loop");
        if(i >= q){}
        else
        {
            //FPDATA_WORD b_word[INIT_B];
            for(uint8_t h = 0; h < INIT_B; h++)
            {
                //HLS_UNROLL_LOOP(AGGRESSIVE, INIT_B, "initialize b loop");
                HLS_BREAK_DEP(y_b);
                if(i + h >= q){}
                else
                {
                    FPDATA_WORD b_word;
                    FPDATA b_fp = b_fp_calc;

                    cynw_interpret(b_fp, b_word);
                    y_b[i+h] = b_word;

                }
            }
        }
    }

#ifdef STRATUS_HLS
    printf("Initialize b is done\n");
#endif

    //Main loop

    // kernel_op_alt(p, q, maxiter);
    bool converge = false;
    FPDATA a_error, b_error;//, prev_error = 1;
    FPDATA limit_val = 0.0001;
    FPDATA limit = limit_val;// * q_fp;
    uint16_t counter = 0;

    // for(uint32_t i = 0; i < MAX_ITER; i++)
    // {
    while(!converge)
    {
        //HLS_PIPELINE_LOOP(SOFT_STALL, 1, "kernel loop");
        // if(i >= maxiter){}
        // else
        // {
#ifdef STRATUS_HLS
        //printf("Computing kernel iteration %d out of %d\n", i, maxiter);
            printf("End iteration");
#endif

            //a
            a_error = kernel_operation(p, q, false);

#ifdef STRATUS_HLS
            printf("Finished a starting b\n");
#endif

            //b
            b_error = kernel_operation(p, q, true);
            counter = counter + 1;
            if(a_error <= limit || b_error <= limit || counter >= maxiter)
                converge = true;

#ifndef STRATUS_HLS
            float error_val;
            fp2native(a_error, error_val);
            ESP_REPORT_INFO("End iteration %d with %.20f a_error, min %f, max %f", counter, error_val, min, max);
            fp2native(b_error, error_val);
            ESP_REPORT_INFO("End iteration %d with %.20f b_error, min %f, max %f", counter, error_val, min, max);
#endif

        // }

    }


#ifndef STRATUS_HLS
    float sum_a = 0;
    float sum_b = 0;
    for(uint32_t i = 0; i < p; i++)
    {
        FPDATA_WORD a_word = x_a[i];
        FPDATA a_fp1=0;
        FPDATA a_fp2=0;
        float a_val = 0;
        //cynw_interpret64(a_word, a_fp2, a_fp1);
        cynw_interpret(a_word, a_fp1);
        fp2native(a_fp1, a_val);
        //ESP_REPORT_INFO("a[%u] = %f ", i, a_val);
        sum_a += a_fp1;
        if(i != p-1)
            fp2native(a_fp2, a_val);
        //ESP_REPORT_INFO("a[%u] = %f ", i, a_val);
        sum_a += a_fp2;

    }
    for(uint32_t i = 0; i < q; i++)
    {
        FPDATA_WORD b_word = y_b[i];
        FPDATA b_fp1=0;
        FPDATA b_fp2=0;
        float b_val = 0;
        //cynw_interpret64(b_word, b_fp1, b_fp2);
        cynw_interpret(b_word, b_fp1);
        fp2native(b_fp1, b_val);
        //ESP_REPORT_INFO("b[%u] = %f ", i, b_val);
        sum_b += b_fp1;
        if(i != q-1)
            fp2native(b_fp2, b_val);
        //ESP_REPORT_INFO("b[%u] = %f ", i, b_val);
        sum_b += b_fp2;
    }

    ESP_REPORT_INFO("sum of a is %f, sum of b is %f", sum_a, sum_b);

#endif
#ifndef STRATUS_HLS
    sum = 0;
#endif

}


FPDATA sinkhorn::kernel_operation(uint32_t p, uint32_t q, bool a_or_b)
{

    //The kernel operation for the sinkhorn method
    // FPDATA_WORD gamma_word_val = gamma;
    // FPDATA gamma_fp;
    // cynw_interpret(gamma_word_val, gamma_fp);
    // gamma_fp = 1 / gamma_fp;

    FPDATA p_fp = p;
    FPDATA q_fp = q;
    FPDATA inv_p_fp = 1/p_fp;
    FPDATA inv_q_fp = 1/q_fp;

    if(!a_or_b) //Do a = p / (K @ b)
    {
        FPDATA a_error = 0;
        for(uint8_t i = 0; i < P_MAX; i++)
        {
            //HLS_PIPELINE_LOOP(SOFT_STALL, 64, "pipe a loop");
            HLS_BREAK_DEP(x_a);
            if(i >= p){}
            else
            {
                FPDATA_WORD a_word;
                //FPDATA p_fp = p;
                FPDATA a_fp_total = 0;

                for(uint16_t k = 0; k < Q_MAX; k+=READ_B)
                {
                    //HLS_CONSTRAIN_LATENCY("PIPE A LOOP");
                    HLS_PIPELINE_LOOP(SOFT_STALL, 1, "pipe a loop");
                    if(k >= q){}
                    else
                    {
                        FPDATA a_fp[READ_B];
                        HLS_FLAT(a_fp);
                        // FPDATA_WORD b_word[READ_AB];
                        // HLS_FLAT(b_word);

                        FPDATA a_fp_total_1 = 0;
                        FPDATA a_fp_total_2 = 0;

                        for(uint8_t h = 0; h < READ_B; h++)
                        {
                            //HLS_UNROLL_LOOP(AGGRESSIVE, READ_AB, "read bK loop");
                            HLS_BREAK_DEP(y_b);
                            HLS_BREAK_DEP(K);
                            //HLS_BREAK_DEP(C);

                            a_fp[h] = 0;
                            // a_fp[h+1] = 0;

                            if(k + h >= q){}
                            else
                            {
                                FPDATA_WORD b_word = y_b[k + h];
                                FPDATA b_fp = 0;

                                // FPDATA_WORD C_word = C[i * q + k + h];
                                // FPDATA C_fp, K_fp;
                                // cynw_interpret(C_word, C_fp);
                                // K_fp = neg_exp(C_fp * gamma_fp);

                                FPDATA_WORD K_word = K[i * q + k + h];
                                FPDATA K_fp = 0;

                                cynw_interpret(b_word, b_fp);
                                cynw_interpret(K_word, K_fp);
                                a_fp[h] = K_fp * b_fp;

                                // cynw_interpret(b_word, b_fp);
                                // a_fp[h] = K_fp * b_fp;

                            }
                        }

                        for(uint8_t j = 0; j < READ_B/2; j++)
                        {
                            a_fp_total_1 += a_fp[j];
                            a_fp_total_2 += a_fp[j+READ_B/2];
                        }

                        a_fp_total += a_fp_total_1 + a_fp_total_2;

                    }
                }

                // FPDATA inv_a_taylor = 1;
                // FPDATA term = 1;

                // for(uint8_t l = 0; l < 15; l++)
                // {
                //     HLS_PIPELINE_LOOP(SOFT_STALL, 1, "pipe taylor a loop");
                //     term *= 1-a_fp_total;
                //     inv_a_taylor += term;
                // }

#ifndef STRATUS_HLS
                float float_val;
                FPDATA val = a_fp_total;
                fp2native(val, float_val);
                if(float_val > max)
                    max = float_val;
                if(float_val < min)
                    min = float_val;
#endif
                //x_a[i] = 1/(p * x_a[i]);
                a_fp_total = 1 / (p_fp * a_fp_total);
                //a_fp_total = inv_p_fp * inv_a_taylor;

                FPDATA_WORD a_prev = x_a[i];
                FPDATA a_fp_prev, new_err;
                cynw_interpret(a_prev, a_fp_prev);
                new_err = (a_fp_prev - a_fp_total);// / a_fp_prev;
                // a_error += new_err * new_err;
                if(new_err >= 0)
                    a_error += new_err;
                else
                    a_error -= new_err;

                cynw_interpret(a_fp_total, a_word);
                x_a[i] = a_word;

            }
        }

        return a_error;
    }
    else //Do b = q / (K.T @ a)
    {
        FPDATA b_error = 0;
        for(uint8_t i = 0; i < Q_MAX; i++)
        {
            //HLS_PIPELINE_LOOP(SOFT_STALL, 64, "pipe b loop");
            HLS_BREAK_DEP(y_b);
            //HLS_BREAK_DEP(x_a);

            if(i >= q){}
            else
            {
                FPDATA_WORD b_word;
                //FPDATA q_fp = q;
                FPDATA b_fp_total = 0;

                for(uint16_t k = 0; k < P_MAX; k+=READ_A)
                {
                    //HLS_CONSTRAIN_LATENCY("PIPE B LOOP");
                    HLS_PIPELINE_LOOP(SOFT_STALL, 1, "pipe b loop");
                    //HLS_CONSTRAIN_ARRAY_MAX_DISTANCE(y_b ,15, "pipe b_alt");
                    if(k >= p){}
                    else
                    {
                        FPDATA b_fp[READ_A];
                        HLS_FLAT(b_fp);

                        FPDATA b_fp_total_1 = 0;
                        FPDATA b_fp_total_2 = 0;

                        for(uint8_t h = 0; h < READ_A; h++)
                        {
                            //HLS_UNROLL_LOOP(AGGRESSIVE, READ_AB, "read aK loop");
                            HLS_BREAK_DEP(x_a);
                            //HLS_BREAK_DEP(y_b);
                            HLS_BREAK_DEP(K);
                            //HLS_BREAK_DEP(C);
                            b_fp[h] = 0;

                            if(h + k >= p){}
                            else
                            {
                                FPDATA_WORD a_word = x_a[k + h];
                                FPDATA a_fp = 0;

                                FPDATA_WORD K_word = K[(k + h) * q + i];
                                FPDATA K_fp = 0;

                                cynw_interpret(a_word, a_fp);
                                cynw_interpret(K_word, K_fp);
                                b_fp[h] = K_fp * a_fp;

                                // FPDATA_WORD C_word = C[(k + h) * q + i];
                                // FPDATA C_fp, K_fp;
                                // cynw_interpret(C_word, C_fp);
                                // K_fp = neg_exp(C_fp * gamma_fp);

                                // cynw_interpret(a_word, a_fp);
                                // b_fp[h] = K_fp * a_fp;

                            }
                        }


                        for(uint8_t j = 0; j < READ_A/2; j++)
                        {
                            b_fp_total_1 += b_fp[j];
                            b_fp_total_2 += b_fp[j+READ_A/2];
                            // ESP_REPORT_INFO("j %d j+READ_AB/2 %d", j, j+READ_AB/2);
                        }

                        b_fp_total += b_fp_total_1 + b_fp_total_2;

                    }
                }

                // //1/b_fp_total taylor series
                // FPDATA inv_b_taylor = 1;
                // FPDATA term = 1;

                // for(uint8_t l = 0; l < 15; l++)
                // {
                //     HLS_PIPELINE_LOOP(SOFT_STALL, 1, "pipe taylor b loop");
                //     term *= 1-b_fp_total;
                //     inv_b_taylor += term;
                // }

// #ifndef STRATUS_HLS
//                 float float_val, taylor_val, err_val;
//                 FPDATA val = b_fp_total;
//                 fp2native(val, float_val);
//                 fp2native(inv_b_taylor, taylor_val);
//                 if(float_val > max)
//                     max = float_val;
//                 if(float_val < min)
//                     min = float_val;

//                 err_val = (1/float_val - taylor_val)*(1/float_val - taylor_val);
//                 if(max_error < err_val)
//                     max_error = err_val;
//                 //ESP_REPORT_INFO("inv b value: %f , taylor value: %f, error: %f", 1/float_val, taylor_val, max_error);
// #endif

                //y_b[i] = 1/(q * y_b[i]);
                b_fp_total = 1 / (q_fp * b_fp_total);
                //b_fp_total = inv_q_fp * inv_b_taylor;
                FPDATA_WORD b_prev = y_b[i];
                FPDATA b_fp_prev, new_err;
                cynw_interpret(b_prev, b_fp_prev);
                new_err = (b_fp_prev - b_fp_total);// / b_fp_prev;
                b_error += new_err * new_err;
                cynw_interpret(b_fp_total, b_word);
                y_b[i] = b_word;

            }
        }

        return b_error;
    }

}


// void sinkhorn::kernel_op_alt(uint32_t p, uint32_t q, uint32_t iter)
// {
//     for(uint32_t d = 0; d < MAX_ITER; d++)
//     {
//         if(d >= iter){}
//         else
//         {
//             //The kernel operation for the sinkhorn method

//             for(uint32_t i = 0; i < P_MAX; i++)
//             {
//                 //HLS_PIPELINE_LOOP(SOFT_STALL, 1, "pipe a loop");
//                 HLS_BREAK_DEP(x_a);
//                 if(i >= p){}
//                 else
//                 {
//                     FPDATA_WORD a_word;
//                     FPDATA a_fp[READ_AB];
//                     HLS_FLAT(a_fp);
//                     FPDATA p_fp = p;
//                     FPDATA a_fp_total = 0;

//                     //x_a[i] = 0;

//                     for(uint32_t k = 0; k < Q_MAX; k+=READ_AB)
//                     {
//                         //HLS_CONSTRAIN_LATENCY("PIPE A LOOP");
//                         HLS_PIPELINE_LOOP(SOFT_STALL, 1, "pipe a loop");
//                         if(k >= q){}
//                         else
//                         {
//                             FPDATA a_fp_total_1 = 0;
//                             FPDATA a_fp_total_2 = 0;

//                             for(uint32_t h = 0; h < READ_AB; h++)
//                             {
//                                 //HLS_UNROLL_LOOP(AGGRESSIVE, READ_AB, "read bK loop");
//                                 HLS_BREAK_DEP(y_b);
//                                 //HLS_BREAK_DEP(b_alt);
//                                 HLS_BREAK_DEP(K);
//                                 a_fp[h] = 0;

//                                 if(k + h >= q){}
//                                 else
//                                 {
//                                     FPDATA_WORD b_word;
//                                     FPDATA b_fp = 0;
//                                     FPDATA_WORD K_word = K[i * q + k + h];
//                                     FPDATA K_fp = 0;

//                                     b_word = y_b[k+h];

//                                     cynw_interpret(b_word, b_fp);
//                                     cynw_interpret(K_word, K_fp);

//                                     a_fp[h] = K_fp * b_fp;
//                                 }
//                             }

//                             for(uint32_t j = 0; j < READ_AB/2; j++)
//                             {
//                                 a_fp_total_1 += a_fp[j];
//                                 a_fp_total_2 += a_fp[j+READ_AB/2];
//                             }

//                             a_fp_total += a_fp_total_1 + a_fp_total_2;
//                             // float tmp1, tmp2;
//                             // fp2native(a_fp_total_1+a_fp_total_2, tmp1);
//                             // fp2native(a_fp_total, tmp2);
//                             // ESP_REPORT_INFO("a_fp_1+a_fp_2 %f a_fp_total %f", tmp1, tmp2);

//                         }
//                     }

//                     //x_a[i] = 1/(p * x_a[i]);
//                     a_fp_total = 1/(p_fp * a_fp_total);

//                     if(d == iter-1)
//                     {
//                         cynw_interpret(a_fp_total, a_word);
//                         x_a[i] = a_word;
//                     }

//                     for(uint32_t k = 0; k < Q_MAX; k+=READ_AB)
//                     {
//                         //HLS_CONSTRAIN_LATENCY("PIPE A LOOP");
//                         HLS_PIPELINE_LOOP(SOFT_STALL, 1, "pipe b loop");
//                         HLS_CONSTRAIN_ARRAY_MAX_DISTANCE(b_alt ,15, "pipe b_alt");
//                         if(k >= q){}
//                         else
//                         {
//                             for(uint32_t h = 0; h < READ_AB; h++)
//                             {
//                                 //HLS_UNROLL_LOOP(AGGRESSIVE, READ_AB, "read bK loop");
//                                 HLS_BREAK_DEP(b_alt);
//                                 HLS_BREAK_DEP(y_b);
//                                 HLS_BREAK_DEP(K);
//                                 a_fp[h] = 0;

//                                 if(k + h >= q){}
//                                 else
//                                 {
//                                     FPDATA_WORD b_word;// = y_b[k + h];
//                                     FPDATA b_fp = 0;
//                                     FPDATA_WORD K_word = K[i * q + k + h];
//                                     FPDATA K_fp;
//                                     FPDATA q_fp = q;

//                                     if(i > 0)
//                                     {
//                                         b_word = b_alt[k+h];
//                                         cynw_interpret(b_word, b_fp);
//                                     }

//                                     cynw_interpret(K_word, K_fp);

//                                     b_fp += K_fp * a_fp_total;

//                                     if(i == p-1)
//                                         b_fp = 1 / (q_fp * b_fp);

//                                     cynw_interpret(b_fp, b_word);
//                                     if(i < p-1)
//                                         b_alt[k + h] = b_word;
//                                     else
//                                         y_b[k + h] = b_word;
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }

FPDATA sinkhorn::neg_exp(FPDATA exponent)
{
    HLS_DPOPT_REGION(DPOPT_DEFAULT, "neg_exp");
    //Function that calculates e^exponent when exponent is negative

    //exponent = -exponent;
    FPDATA term = exponent;
    FPDATA exp_result = 1 + exponent;
    //FPDATA precision_const[PRECISION] = {0.5, 0.3333, 0.25, 0.2, 0.1667};
    //HLS_FLAT(precision_const);

    // for(uint8_t i = 0; i < PRECISION; i++)
    // {
    //     precision_const[i] = 1.0 / (i+2);
    // }

    for(uint8_t i = 0; i < PRECISION; i++)
    {
        //HLS_PIPELINE_LOOP(SOFT_STALL, 1, "exp loop");
        //HLS_UNROLL_LOOP(AGGRESSIVE, PRECISION, "exp loop");

        //term *= exponent / (i+2);
        term *= exponent / (i+2); //* precision_const[i];
        exp_result += term;
    }

    return 1 / exp_result;
}
