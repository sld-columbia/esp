//Copyright (c) 2011-2024 Columbia University, System Level Design Group
//SPDX-License-Identifier: Apache-2.0

#include "testbench.hpp"
#include <math.h>
#include <mc_connections.h>
#include <mc_scverify.h>

#define ERR_THRESHOLD 0.01
#define PI  3.14159265358979323846
#define A 0.044715

void init_tensor(float* tensor, const int size, bool random, bool print)
{
    float value;
    for (int i = 0; i < size; ++i) {
        if (random){
            value = rand() / float(RAND_MAX);
        }
        else {
            value = float(0);
        }
	    
	    tensor[i] = value - 0.5;
        if (print){
            printf("tensor[%d] = %f \n", i, tensor[i]);
        }
    }
}

conf_info_t testbench::load_config()
{
    conf_info_t config;
    config.batch        = batch;
    config.row          = row;
    config.addrA        = addrA;
    config.addrB        = addrB;
    config.addrO        = addrO;
    return config;
}

void testbench::compile_config()
{
    sw_in_a_size        = batch*(row*VEC_LEN);
    sw_in_b_size        = batch*(row*VEC_LEN);
    sw_out_size         = batch*(row*VEC_LEN);
    in_a_size           = round_up(sw_in_a_size, DMA_WORD_PER_BEAT);
    in_b_size           = round_up(sw_in_b_size, DMA_WORD_PER_BEAT);
    out_size            = round_up(sw_out_size, DMA_WORD_PER_BEAT);
    addrA               = 0;
    addrB               = in_a_size;
    addrO               = in_a_size + in_b_size;
}

void testbench::load_memory(float *file_arr, uint32_t base_addr, uint32_t size)
{
#if (DMA_WORD_PER_BEAT == 0)
    for (int i=0; i<size; i++)
    {
        ac_int<DATA_WIDTH> data_bv = file_arr[i];

        for (int j=0; j<DMA_BEAT_PER_WORD; j++)
        {
            mem[DMA_BEAT_PER_WORD * i + j] = data_bv.slc<DMA_WIDTH>(j * DMA_WIDTH);
        }
    }
#else
    for (int i=0; i <size/DMA_WORD_PER_BEAT; i++)
    {
        ac_int<DMA_WIDTH> data_bv;
        for (int j=0; j<DMA_WORD_PER_BEAT; j++)
        {
            FPDATA_WORD fpdata_word;
        #ifdef FL_POINT
            float data = file_arr[i* DMA_WORD_PER_BEAT + j];
            FPDATA fpdata = FPDATA(data);
            f2int(fpdata, fpdata_word);
        #else
            ac_ieee_float32 data = file_arr[i* DMA_WORD_PER_BEAT + j];
            FPDATA fpdata = data.convert_to_ac_fixed<FPDATA_WL,FPDATA_IL,true,AC_TRN, AC_WRAP>();
            fx2int(fpdata, fpdata_word);
        #endif
            data_bv.set_slc(j*DATA_WIDTH, fpdata_word);
        }
        mem[base_addr/DMA_WORD_PER_BEAT + i] = data_bv;
    }
#endif
}


void testbench::generate_data()
{
    in_a = (float*) malloc(in_a_size * sizeof(float));
    in_b = (float*) malloc(in_b_size * sizeof(float));
    init_tensor(in_a, in_a_size, true, false);
    init_tensor(in_b, in_b_size, true, false);
    load_memory(in_a, addrA, in_a_size); 
    load_memory(in_b, addrB, in_b_size); 
}


void testbench::pv_leaky_relu(float *in_a, float*in_b, float *out)
{
    float vector;

    for (int b=0; b<batch; b++){
        for (int r=0; r<row; r++){
            for (int v=0; v<VEC_LEN; v++){
                vector = (in_a[b*(row*VEC_LEN) + r*VEC_LEN + v] + in_b[b*(row*VEC_LEN) + r*VEC_LEN + v]);

                if (vector > 0){
                    out[b*(row*VEC_LEN) + r*VEC_LEN + v] = vector;
                }
                else {
                    out[b*(row*VEC_LEN) + r*VEC_LEN + v] = vector * 0.5;
                }
            }
        }
    }

}

void testbench::validate_kernel(void)
{
    acc_out = new ac_int<DATA_WIDTH, false>[out_size];

#if (DMA_WORD_PER_BEAT == 0)
    int offset = addrO * DMA_BEAT_PER_WORD;
    for (uint32_t i=0; i<out_size; i++){
        ac_int <DATA_WIDTH> data_bv;
        for (int j=0; j<DMA_BEAT_PER_WORD; j++){
            data_bv.set_slc(j*DMA_WIDTH, mem[offset + DMA_BEAT_PER_WORD*i + j]);
        }
        acc_out[i] = data_bv.to_int64();
    }
#else
    int offset = addrO/DMA_WORD_PER_BEAT;
    for (uint32_t i=0; i<out_size/DMA_WORD_PER_BEAT; i++){
        for (uint32_t j=0; j<DMA_WORD_PER_BEAT; j++){
            acc_out[i*DMA_WORD_PER_BEAT + j] = mem[offset+i].slc<DATA_WIDTH>(j*DATA_WIDTH);
        }
    }
#endif
    CCS_LOG("testbench dump memory completed" );

    int err = 0;
    float acc_result;
    float *golden_arr = new float[out_size];
    
    pv_leaky_relu(in_a, in_b, golden_arr);


    for (int i=0; i<sw_out_size; i++){
        FPDATA_WORD data_bv = acc_out[i];
        FPDATA data_fp;
    
    #ifdef FL_POINT
        int2f(data_bv, data_fp);
        acc_result = data_fp.to_ac_float().to_float();
    #else
        bv2fp(data_bv, data_fp);
        double data_double = data_fp.to_double();
        acc_result = (float) data_double;
    #endif
        float golden = golden_arr[i];

        printf(" Vector: output[%d] = %f (pv_golden: %f) \n", i, acc_result, golden_arr[i]);
        if (golden != acc_result){
            float MSE = (golden - acc_result) * (golden - acc_result) / golden;
            if (MSE > ERR_THRESHOLD){
                printf("Vector: output[%d] = %f (pv_golden: %f) \n", i, acc_result, golden_arr[i]);
                err += 1;
            }
        }
    }

    if (err == 0){
        CCS_LOG("---------------------------------------");
        printf("  Validation succeeded for total %d!\n", sw_out_size);
        CCS_LOG("---------------------------------------");
    } else {
        CCS_LOG("---------------------------------------");
        printf("  Validation failed! (err rate: %d / %d = %f%%)\n", err, sw_out_size, err/float(sw_out_size)*100);
        CCS_LOG("---------------------------------------");
    }
    CCS_LOG("testbench accelerator validation completed" );
}


void testbench::kernel_processing()
{
    conf_info.Reset();
    wait();

    CCS_LOG("=== TEST BEGIN ===");    
    compile_config();
    CCS_LOG("testbench setup configuration completed" );
    generate_data();
    CCS_LOG("testbench setup memory completed" );

    sc_time start_time = sc_time_stamp();
    conf_info_t config = load_config();
    conf_info.Push(config);
    CCS_LOG("testbench push configuration info completed" );

    wait();
    do { wait(); } while (!acc_done.read());
    sc_time end_time = sc_time_stamp();

    validate_kernel();

    sc_time elapsed_time = end_time - start_time;
    CCS_LOG("testbench operating accelerator completed" );
    std::cout << "--------------------------------------- Elapsed time: " << elapsed_time << " ---------------------------------------" << std::endl;

    free(acc_out);
    sc_stop();
}
