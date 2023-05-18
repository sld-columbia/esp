// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"
#include "load_model.h"


void gemm_pv(float *mtx_inA, float *mtx_inB, float *mtx_out,int relu,int soft,
        size_t is_trans, size_t rowsA, size_t colsA, size_t colsB)
{
        unsigned d1, d2, d3, mtx_inA_i, mtx_inB_i;
        double accumulator;
        for (d1 = 0; d1 < rowsA; ++d1)
        {
                for (d2 = 0; d2 < colsB; ++d2)
                {
                        accumulator = 0.0;

                        for (d3 = 0; d3 < colsA; ++d3)
                        {
                                mtx_inA_i = d1 * colsA + d3;
                                mtx_inB_i = is_trans ? (d2 * colsA + d3) : (d3 * colsB + d2);
                                accumulator += mtx_inA[mtx_inA_i] * mtx_inB[mtx_inB_i];
                        }
                        mtx_out[d1 * colsB + d2] = accumulator;
                }
        }


        //relu
        for (int i = 0; i < rowsA; i++) { // only working for inference with one example
                if (relu) {
                        if (mtx_out[i]< 0)
                                mtx_out[i] = 0;
                }
        }
        // softmax for layer without relu
        if (!relu && soft)
        {
                for (int i = 0; i < rowsA; i++) { // only working with one example
                        float max = mtx_out[0];
                        for (int j = 1; j < rowsA; j++)
                                if (mtx_out[j] > max)
                                        max = mtx_out[j];

                        float denom = 0;
                        for (int j = 0; j <rowsA; j++)
                                denom += exp(mtx_out[j] - max);

                        mtx_out[i] = exp(mtx_out[i] - max) / denom;
                }
        }

}


/* User-defined code */
static void validate_buffer(token_t *acc_buf, float *sw_buf, unsigned len)
{
    int i;
    float val;
    unsigned errors = 0;

    printf("\nPrint output\n");

    for (i = 0; i < len; i++) {

#ifdef __FIXED
	val = fx2float(acc_buf[i], FX_IL);
#else
	val = acc_buf[i];
#endif
	if (sw_buf[i] != val) {
	    errors++;
	    /* if (errors <= MAX_PRINTED_ERRORS) */
	    
	}
	if (i<30)
		printf("index %d : output %f : expected %f <-- ERROR\n", i, val, sw_buf[i]);
 //else {
 	/*     if (i < MAX_PRINTED_ERRORS) */
	/* 	printf("index %d : output %d : expected %d\n", i, (int) val,  (int) sw_buf[i]); */
	/* } */
    }

    if (!errors)
	printf("\n  ** Test PASSED! **\n");
    else
	printf("\n  ** Test FAILED! **\n");
}

static void init_buffer_gemm(token_t *acc_buf,float *mat1,token_t *mat2,unsigned in_len1,unsigned in_len2)
{
	int i;

	printf("  Initialize inputs\n");

	for (i = 0; i < in_len1; i++) {

#ifdef __FIXED
		acc_buf[i] = float2fx(mat1[i],FX_IL);
#else
		acc_buf[i] = mat1[i];
#endif
	}
	for (i = 0; i < in_len2; i++) {

#ifdef __FIXED
		acc_buf[in_len1+i] = mat2[i];
#else
		acc_buf[in_len1+i] = mat2[i] ;
#endif
	}


}


/* User-defined code */
static void init_buffer(token_t *acc_buf, token_t* input,float*weights, float*bias, unsigned in_len, unsigned weights_len, unsigned bias_len)
{
    int i;

    printf("  Initialize inputs\n");

// #include "input.h"
// #include "gold.h"
    /* printf("in_len, weights_len,bias_len: %d \n ",in_len) */

    for (i = 0; i < in_len; i++) {
#ifdef __FIXED
	acc_buf[i] = input[i];
#else
        acc_buf[i] = input[i];
#endif
    }

    for (i = 0; i < weights_len; i++) {
#ifdef __FIXED
        acc_buf[in_len+i] = float2fx(weights[i], FX_IL);
#else
        acc_buf[in_len+i] = weights[i];
#endif
    }

    for (i = 0; i < bias_len; i++) {
#ifdef __FIXED
        acc_buf[in_len+weights_len+i] = float2fx(bias[i], FX_IL);
#else
        acc_buf[in_len+weights_len+i] = bias[i];
#endif
    }

}




static void init_buffer1(float *sw_buf, float* input,float*weights, float*bias, unsigned in_len, unsigned weights_len, unsigned bias_len)
{
    int i;

    printf("  Initialize inputs\n");

// #include "input.h"
// #include "gold.h"
    /* printf("in_len, weights_len,bias_len: %d \n ",in_len) */

    for (i = 0; i < in_len; i++) {
	sw_buf[i] = input[i];
    }

    for (i = 0; i < weights_len; i++) {
        sw_buf[in_len+i] = weights[i];
    }

    for (i = 0; i < bias_len; i++) {
        sw_buf[in_len+weights_len+i] = bias[i];
    }

}

/* static void init_buffer1(token_t *acc_buf, float *sw_buf, token_t* input, float*weights, float*bias, unsigned in_len, unsigned weights_len, unsigned bias_len) */
/* { */
/*     int i; */

/*     printf("  Initialize inputs\n"); */

/* // #include "input.h" */
/* // #include "gold.h" */
/*     /\* printf("in_len, weights_len,bias_len: %d \n ",in_len) *\/ */

/*     for (i = 0; i < in_len; i++) { */
/* #ifdef __FIXED */
/*         acc_buf[i] = input[i]; */
/* #else */
/*         acc_buf[i] = input[i]; */
/* #endif */
/*  	sw_buf[i] = fx2float(input[i],FX_IL); */
/*     } */

/*     for (i = 0; i < weights_len; i++) { */
/* #ifdef __FIXED */
/*         acc_buf[in_len+i] = float2fx(weights[i], FX_IL); */
/* #else */
/*         acc_buf[in_len+i] = weights[i]; */
/* #endif */
/* 	sw_buf[in_len+i] = weights[i]; */
/*     } */

/*     for (i = 0; i < bias_len; i++) { */
/* #ifdef __FIXED */
/*         acc_buf[in_len+weights_len+i] = float2fx(bias[i], FX_IL); */
/* #else */
/*         acc_buf[in_len+weights_len+i] = bias[i]; */
/* #endif */
/* 	sw_buf[in_len+weights_len+i] = bias[i]; */
/*     } */

/* } */

/* User-defined code */
static void init_parameters_gemm(int test, int32_t do_relu, int32_t transpose, int32_t ninputs,
                            int32_t d3, int32_t d2, int32_t d1,
                            unsigned *in_len, unsigned *in1_len, unsigned *out_len,
                            unsigned *in_size, unsigned *out_size, unsigned *size)
{
	int32_t ld_offset1, ld_offset2, st_offset;
	unsigned in2_len;

	*in1_len = round_up(ninputs * d1 * d2, DMA_WORD_PER_BEAT(sizeof(token_t)));
	in2_len = round_up(ninputs * d2 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
	*in_len = *in1_len + in2_len;
	*out_len = round_up(ninputs * d1 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
	*in_size = *in_len * sizeof(token_t);
	*out_size = *out_len * sizeof(token_t);
	*size = *in_size + *out_size;

	ld_offset1 = 0;
	ld_offset2 = *in1_len;
	st_offset = *in_len;

	gemm_cfg_000[0].do_relu = do_relu;
	gemm_cfg_000[0].transpose = transpose;
	gemm_cfg_000[0].ninputs = ninputs;
	gemm_cfg_000[0].d1 = d1;
	gemm_cfg_000[0].d2 = d2;
	gemm_cfg_000[0].d3 = d3;
	gemm_cfg_000[0].ld_offset1 = ld_offset1;
	gemm_cfg_000[0].ld_offset2 = ld_offset2;
	gemm_cfg_000[0].st_offset = st_offset;

	// print test info
	/* printf("  Prepare test %d parameters\n", test); */
	printf("    .do_relu = %d\n", do_relu);
	printf("    .transpose = %d\n", transpose);
	printf("    .ninputs = %d\n", ninputs);
	printf("    .d3 = %d\n", d3);
	printf("    .d2 = %d\n", d2);
	printf("    .d1 = %d\n", d1);
	printf("    .st_offset = %d\n", st_offset);
	printf("    .ld_offset1 = %d\n", ld_offset1);
	printf("    .ld_offset2 = %d\n", ld_offset2);
}

static void init_parameters(int test, int32_t n_channels, int32_t feature_map_height, int32_t feature_map_width,
			    int32_t n_filters, int32_t filter_dim, int32_t is_padded,
			    int32_t stride, int32_t do_relu, int32_t pool_type, int32_t batch_size,
			    unsigned *in_len, unsigned *weights_len, unsigned *bias_len, unsigned *out_len,
			    unsigned *in_size, unsigned *weights_size, unsigned *bias_size, unsigned *out_size,
			    unsigned *weights_offset, unsigned *bias_offset, unsigned *out_offset, unsigned *size)
{
    int32_t output_h;
    // int32_t output_w;
    int32_t output_pool_h;
    // int32_t output_pool_w;
    int32_t pad_dim = 0;

    if (is_padded) {
	pad_dim = filter_dim / 2;
    }

    output_h = (feature_map_height + 2 * pad_dim - ((filter_dim - 1) + 1)) / stride + 1;
    // output_w = output_h;
    output_pool_h = pool_type ? output_h / 2 : output_h;
    // output_pool_w = output_pool_h;

    // Input data and golden output (aligned to DMA_WIDTH makes your life easier)
    *in_len = round_up(batch_size * round_up(n_channels * round_up(feature_map_height * feature_map_width, DMA_RATIO), DMA_RATIO), DMA_RATIO);
    *weights_len = round_up(n_filters * n_channels * filter_dim * filter_dim, DMA_RATIO);
    *bias_len = round_up(n_filters, DMA_RATIO);
    *out_len = round_up(batch_size * round_up(n_filters * round_up(output_pool_h * output_pool_h, DMA_RATIO), DMA_RATIO), DMA_RATIO);

    *in_size = *in_len * sizeof(token_t);
    *weights_size = *weights_len * sizeof(token_t);
    *bias_size = *bias_len * sizeof(token_t);
    *out_size = *out_len * sizeof(token_t);
    *weights_offset = *in_len;
    *bias_offset = *in_len + *weights_len;
    *out_offset  = *in_len + *weights_len + *bias_len;
    *size = *in_size + *weights_size + *bias_size + *out_size;

    printf("size, insize,wsize,bsize,osize: %d %d %d %d %d \n",*size,*in_size,*weights_size,*bias_size,*out_size);

    conv2d_cfg_000[0].n_channels = n_channels;
    conv2d_cfg_000[0].feature_map_height = feature_map_height;
    conv2d_cfg_000[0].feature_map_width = feature_map_width;
    conv2d_cfg_000[0].n_filters = n_filters;
    conv2d_cfg_000[0].filter_dim = filter_dim;
    conv2d_cfg_000[0].is_padded = is_padded;
    conv2d_cfg_000[0].stride = stride;
    conv2d_cfg_000[0].do_relu = do_relu;
    conv2d_cfg_000[0].pool_type = pool_type;
    conv2d_cfg_000[0].batch_size = batch_size;

    // print test info
    /* printf("  Prepare test %d parameters\n", test); */
    printf("    .n_channels = %d\n", n_channels);
    printf("    .feature_map_height = %d\n", feature_map_height);
    printf("    .feature_map_width = %d\n", feature_map_width);
    printf("    .n_filters = %d\n", n_filters);
    printf("    .filter_dim = %d\n", filter_dim);
    printf("    .is_padded = %d\n", is_padded);
    printf("    .stride = %d\n", stride);
    printf("    .do_relu = %d\n", do_relu);
    printf("    .pool_type = %d\n", pool_type);
    printf("    .batch_size = %d\n", batch_size);
    printf("    .offset = %d\n", conv2d_cfg_000[0].src_offset);

}



inline float variance1(float *in, float mean, unsigned size) {
        float var=0;
        float offs=0.00001;
        for (unsigned i=0;i<size;i++){
                var+=pow(in[i]-mean,2);
        }
	/* printf("var soft value: %f",var); */
        var=sqrt(var/size+offs);
	/* printf("var soft value: %f \n",var); */
        return var;
}

inline void batch_normalization1(float *in, float mean,float var, unsigned size) {
        for (unsigned i=0;i<size;i++){
                in[i]=(in[i]-mean)/var;
        }
}

inline void do_reluf1(float *in, unsigned size) {
        for (unsigned i=0;i<size;i++){
                if (in[i]<0){
                        in[i]=0;
                }
	}
}

inline float max_of_41(float a, float b, float c, float d) {
    if (a >= b && a >= c && a >= d) {
        return a;
    }
    if (b >= c && b >= d) {
        return b;
    }
    if (c >= d) {
        return c;
    }
    return d;
}

inline float avg_of_41(float a, float b, float c, float d) {
    return (a + b + c + d) / 4;
}

inline void pooling_2x21(float *in, float *out, unsigned size, unsigned type) {

    assert(type >= 1 && type <= 2);

    unsigned i, j, out_i;
    float a, b, c, d;
    for (i = 0; i < size - 1; i += 2) {
        for (j = 0; j < size - 1; j += 2) {
	    a = in[i * size + j];
	    b = in[(i + 1) * size + j];
	    c = in[i * size + (j + 1)];
	    d = in[(i + 1) * size + (j + 1)];
	    out_i = (i / 2) * (size/2) + (j / 2);
	    // std::cout << "out_i " << out_i << std::endl;
	    if (type == 1)
		out[out_i] = max_of_41(a, b, c, d);
	    else
		out[out_i] = avg_of_41(a, b, c, d);

	    // std::cout <<
	    // 	" a " << a <<
	    // 	" b " << b <<
	    // 	" c " << c <<
	    // 	" d " << d <<
	    // 	" out " << out[out_i] <<
	    // 	" i " << i <<
	    // 	" j " << j <<
	    // 	std::endl;
	}
    }
}

float variance(token_t *in, float mean, unsigned size) {
        float var=0;
        /* token_t offs=float2fx(0.00001,FX_IL); */
        for (unsigned i=0;i<size;i++){
                var+=pow(fx2float(in[i],FX_IL)-mean,2);
        }
	/* printf("var value: %f ",var); */
	/* printf("var value: %f " ,fx2float(var,FX_IL)); */
        var=sqrt(var/size);
	/* printf("var value: %f \n" ,fx2float(var,FX_IL)); */
        return var;
}

void batch_normalization(token_t *in, float mean,float var, unsigned size) {
        for (unsigned i=0;i<size;i++)
                in[i]=float2fx((fx2float(in[i],FX_IL)-mean)/var,FX_IL);
}


inline void do_reluf(token_t *in, unsigned size) {
        for (unsigned i=0;i<size;i++){
                if (in[i]<0){
                        in[i]=0;
                }
	}
}


inline bool sw_is_a_ge_zero_and_a_lt_b(int a, int b) {
    return (a >= 0 && a < b);
}

inline token_t max_of_4(token_t a, token_t b, token_t c, token_t d) {
    if (a >= b && a >= c && a >= d) {
        return a;
    }
    if (b >= c && b >= d) {
        return b;
    }
    if (c >= d) {
        return c;
    }
    return d;
}

inline token_t avg_of_4(token_t a, token_t b, token_t c, token_t d) {
    return (a + b + c + d) / 4;
}

inline void pooling_2x2(token_t *in, token_t *out, unsigned size, unsigned type) {

    assert(type >= 1 && type <= 2);

    unsigned i, j, out_i;
    token_t a, b, c, d;
    for (i = 0; i < size - 1; i += 2) {
        for (j = 0; j < size - 1; j += 2) {
	    a = in[i * size + j];
	    b = in[(i + 1) * size + j];
	    c = in[i * size + (j + 1)];
	    d = in[(i + 1) * size + (j + 1)];
	    out_i = (i / 2) * (size/2) + (j / 2);
	    // std::cout << "out_i " << out_i << std::endl;
	    if (type == 1)
		out[out_i] = max_of_4(a, b, c, d);
	    else
		out[out_i] = avg_of_4(a, b, c, d);

	}
    }
}


inline void pooling_8x8(token_t *in, token_t *out, unsigned size) {

	unsigned i, j,k,z, out_i;
	for (i = 0; i < size - 4; i += 8) {
		for (j = 0; j < size - 4; j += 8) {
			float max=-100;
			for (k=0;k<8;k++){
				for (z=0;z<8;z++){
					if (in[(i+k)*size+j+z]>max)
						max=in[(i+k)*size+j+z];
				}
			}
			out_i = (i / 8) * (size/8) + (j / 8);
			// std::cout << "out_i " << out_i << std::endl;
			out[out_i] = max;


			//  std::endl;
		}
	}
}



inline void pooling_2x2f(float *in, float *out, unsigned size, unsigned type) {

    assert(type >= 1 && type <= 2);

    unsigned i, j, out_i;
    float a, b, c, d;
    for (i = 0; i < size - 1; i += 2) {
        for (j = 0; j < size - 1; j += 2) {
	    a = in[i * size + j];
	    b = in[(i + 1) * size + j];
	    c = in[i * size + (j + 1)];
	    d = in[(i + 1) * size + (j + 1)];
	    out_i = (i / 2) * (size/2) + (j / 2);
	    // std::cout << "out_i " << out_i << std::endl;
	    if (type == 1)
		out[out_i] = max_of_4(a, b, c, d);
	    else
		out[out_i] = avg_of_4(a, b, c, d);

	}
    }
}


inline void pooling_8x8f(float *in, float *out, unsigned size) {

	unsigned i, j,k,z, out_i;
	for (i = 0; i < size - 4; i += 8) {
		for (j = 0; j < size - 4; j += 8) {
			float max=-100;
			for (k=0;k<8;k++){
				for (z=0;z<8;z++){
					if (in[(i+k)*size+j+z]>max)
						max=in[(i+k)*size+j+z];
				}
			}
			out_i = (i / 8) * (size/8) + (j / 8);
			// std::cout << "out_i " << out_i << std::endl;
			out[out_i] = max;


			//  std::endl;
		}
	}
}



inline void do_pooling_8x8(token_t*out,int batch_size, int num_filters, int output_w)
{
        const int out_channel_size = output_w * output_w; //round_up(output_w * output_h, DM
	const int pool_channel_size = output_w/8 * output_w/8; //round_up((output_w/2) * 
	for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
		for (int num_filter = 0; num_filter < num_filters; num_filter++) {
			pooling_8x8(&out[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],&out[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],output_w);
		}
	}

}

inline void do_pooling_2x2(token_t *out,int batch_size, int num_filters, int output_w,bool p_type)
{
        const int out_channel_size = output_w * output_w; //round_up(output_w * output_h, DMA_WORD_PER_BEAT);
        const int pool_channel_size = output_w/2 * output_w/2;//round_up((output_w/2) * (output_h/2), DMA_WORD_PER_BEAT);

        for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
                for (int num_filter = 0; num_filter < num_filters; num_filter++) {
                        pooling_2x2(&out[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],&out[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],output_w, p_type);
                }
        }
}


inline void do_pooling_8x8f(float*out,int batch_size, int num_filters, int output_w)
{
        const int out_channel_size = output_w * output_w; //round_up(output_w * output_h, DM
	const int pool_channel_size = output_w/8 * output_w/8; //round_up((output_w/2) * 
	for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
		for (int num_filter = 0; num_filter < num_filters; num_filter++) {
			pooling_8x8f(&out[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],&out[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],output_w);
		}
	}

}

inline void do_pooling_2x2f(float *out,int batch_size, int num_filters, int output_w,bool p_type)
{
        const int out_channel_size = output_w * output_w; //round_up(output_w * output_h, DMA_WORD_PER_BEAT);
        const int pool_channel_size = output_w/2 * output_w/2;//round_up((output_w/2) * (output_h/2), DMA_WORD_PER_BEAT);

        for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
                for (int num_filter = 0; num_filter < num_filters; num_filter++) {
                        pooling_2x2f(&out[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],&out[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],output_w, p_type);
                }
        }
}

void sw_conv_layer (
    const float* input, const int channels, const int height, const int width,
    const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
    const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
    const int num_filters, const float* weights, const float* biases, float* output,
    const bool do_relu, const int pool_type, const int batch_size)
{

    const int channel_size = round_up(height * width, DMA_RATIO);
    const int filter_size = channels * kernel_w * kernel_h;
    const int output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
    const int output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;
    const int out_channel_size = round_up(output_w * output_h, DMA_RATIO);
    const int pool_channel_size = round_up((output_w/2) * (output_h/2), DMA_RATIO);

    for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
	for (int num_filter = 0; num_filter < num_filters; num_filter++) {
	    for (int output_row = 0; output_row < output_h; output_row++) {
		for (int output_col = 0; output_col< output_w; output_col++) {
		    int k = 0;
		    float out_value = 0;
		    for (int channel = 0; channel < channels; channel++) {
			for (int kernel_row = 0; kernel_row < kernel_h; kernel_row++) {
			    for (int kernel_col = 0; kernel_col < kernel_w; kernel_col++) {
				int input_row = (output_row * stride_h) - pad_h + kernel_row * dilation_h;
				int input_col = (output_col * stride_w) - pad_w + kernel_col * dilation_w;
				if (!(!sw_is_a_ge_zero_and_a_lt_b(input_row, height) ||
				      (sw_is_a_ge_zero_and_a_lt_b(input_row, height) &&
				       !sw_is_a_ge_zero_and_a_lt_b(input_col, width)))) {
				    out_value += input[batch_i * channels * channel_size + channel * channel_size +
						       input_row * width + input_col] *
					weights[num_filter * filter_size + k];
				}
				k++;
			    }
			}
		    }
		    out_value += biases[num_filter];

		    if (do_relu && out_value < 0)
			out_value = 0;

		    output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size +
			   output_row * output_w + output_col] = out_value;

		    // std::cout << "out_value[" << num_filter << "," << output_row <<
		    //     "," << output_col << "]: " << out_value << std::endl;
		}
	    }

	    if (pool_type)
		pooling_2x21(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],
			    &output[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],
			    output_w, pool_type);
	}
    }
}

void batch_norm (
    const int channels, const int height, const int width,
    const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
    const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
    const int num_filters, token_t* output,const int batch_size,int batch_norms,int do_relu,int pool_type)
{

    /* const int channel_size = round_up(height * width, DMA_RATIO); */
    /* const int filter_size = channels * kernel_w * kernel_h; */
    const int output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
    const int output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;
    const int out_channel_size = round_up(output_w * output_h, DMA_RATIO);
    const int pool_channel_size = output_w/2 * output_h/2;//round_up((output_w/2) * (output_h/2), DMA_WORD_PER_BEAT);
   
    for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
	for (int num_filter = 0; num_filter < num_filters; num_filter++) {
		/* token_t acc=0; */
		float acc=0;
		for (int output_row = 0; output_row < output_h; output_row++) {
			for (int output_col = 0; output_col< output_w; output_col++) {
				
				acc+=fx2float(output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size +
							output_row * output_w + output_col], FX_IL);

			}
		}
	
		/* printf(" acc done \n"); */
                float mean=acc/out_channel_size;
		float var=0;
		//batchnorm for convnet test
		if (batch_norms){
			var=variance(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,out_channel_size);

			/* printf(" var done \n"); */

			/* printf("var value: %f \n", fx2float(var,FX_IL)); */
                        // std::cout<<"variance:"<<var<<std::endl;
			batch_normalization(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,var,out_channel_size);

			/* printf(" batch_norm done \n"); */

		}
		if (do_relu)
		{
			do_reluf(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],out_channel_size);
		}

		/* printf(" relu done \n"); */

		if (pool_type)
			pooling_2x2(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],
				    &output[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],
				    output_w, pool_type);

		/* printf(" pooling done \n"); */
	}
    }
}

void sw_conv_layer1 (
	const float* input, const int channels, const int height, const int width,
	const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
	const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
	const int num_filters, const float* weights, const float* biases, float* output,
	const bool do_relu, const int pool_type, const int batch_size,int batch_norm)
{

        const int channel_size = height*width;//round_up(height * width, DMA_WORD_PER_BEAT);
        const int filter_size = channels * kernel_w * kernel_h;
        const int output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
        const int output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;
        const int out_channel_size = output_w * output_h; //round_up(output_w * output_h, DMA_WORD_PER_BEAT);
        const int pool_channel_size = output_w/2 * output_h/2;//round_up((output_w/2) * (output_h/2), DMA_WORD_PER_BEAT);
        int batch_i,num_filter,output_row,output_col,channel,kernel_row,kernel_col;

        // std::ofstream ofile ("convtest.txt");
        // if (ofile.is_open()
        // {

        for (batch_i = 0;  batch_i < batch_size; batch_i++) {
                for (num_filter = 0; num_filter < num_filters; num_filter++) {
                        float acc=0;
                        for (output_row = 0; output_row < output_h; output_row++) {
                                for (output_col = 0; output_col< output_w; output_col++) {
                                        int k = 0;
                                        float out_value = 0;
                                        for (channel = 0; channel < channels; channel++) {
                                                for (kernel_row = 0; kernel_row < kernel_h; kernel_row++) {
                                                        for (kernel_col = 0; kernel_col < kernel_w; kernel_col++) {
                                                                int input_row = (output_row * stride_h) - pad_h + kernel_row * dilation_h;
                                                                int input_col = (output_col * stride_w) - pad_w + kernel_col * dilation_w;
                                                                if (!(!sw_is_a_ge_zero_and_a_lt_b(input_row, height) ||
                                                                      (sw_is_a_ge_zero_and_a_lt_b(input_row, height) &&
                                                                       !sw_is_a_ge_zero_and_a_lt_b(input_col, width)))) {
                                                                        out_value += input[batch_i * channels * channel_size + channel * channel_size +input_row * width + input_col] *weights[num_filter * filter_size + k];

                                                                }
                                                                k++;
                                                        }
                                                }
                                        }
                                        out_value += biases[num_filter];

                                        output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size + output_row * output_w + output_col] = out_value;

                                        acc+=out_value;

                                }
                        }
                        float mean=acc/out_channel_size;
                        float var;
                        if (batch_norm){
                                var=variance1(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,out_channel_size);
                                batch_normalization1(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,var,out_channel_size);
                        }
                        if (do_relu)
                        {
                                do_reluf1(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],out_channel_size);
                        }
                        if (pool_type)
                                pooling_2x21(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],
                                            &output[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],
                                            output_w, pool_type);


                }
        }

}

static void sw_run(int32_t n_channels, int32_t feature_map_height, int32_t feature_map_width,
		   int32_t n_filters, int32_t filter_dim, int32_t is_padded, int32_t stride,
		   int32_t do_relu, int32_t pool_type, int32_t batch_size,
		   float *in, float *weights, float *bias, float *out, int32_t batch_norm)
{
    struct timespec th_start, th_end;
    int32_t pad_dim = 0;

    if (is_padded) {
	pad_dim = filter_dim / 2;
    }

    gettime(&th_start);

    sw_conv_layer1(in, n_channels, feature_map_height, feature_map_width, filter_dim, filter_dim,
		  pad_dim, pad_dim, stride, stride, 1, 1, n_filters, weights, bias, out,
		   do_relu, pool_type, batch_size,batch_norm);

    gettime(&th_end);

    unsigned long long hw_ns = ts_subtract(&th_start, &th_end);
    printf("    Software execution time: %llu ns\n", hw_ns);
}

int main(int argc, char **argv)
{

	int32_t chans_c      [N_CONV_LAYERS] = { 3, 16,  32,  64};
	int32_t height_c     [N_CONV_LAYERS] = { 32, 32, 16, 8};
	int32_t width_c      [N_CONV_LAYERS] = { 32, 32, 16, 8};
	int32_t n_flt_c      [N_CONV_LAYERS] = { 16, 32, 64, 128};
	int32_t flt_dim_c    [N_CONV_LAYERS] = { 3, 3, 3, 3};
	int32_t pad_c        [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t stride_c     [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t dil_c        [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t relu_c       [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t pool_c       [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t batch_sz_c   [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t batch_norm_c [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t pool_out_c   [N_CONV_LAYERS] = { 0, 1, 1, 3};// stands for pool after batchnorm
	// 1=2x2 max
	// 2=2x2 average
	// 3=8x8

	//Skip layers (1st layer does not exist)

	int32_t chans_s      [N_CONV_LAYERS] = { 0, 16,  32,  64};
	int32_t height_s     [N_CONV_LAYERS] = { 0, 32, 16, 8};
	int32_t width_s      [N_CONV_LAYERS] = { 0, 32, 16, 8};
	int32_t n_flt_s      [N_CONV_LAYERS] = { 0, 32, 64, 128};
	int32_t flt_dim_s    [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t pad_s        [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t stride_s     [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t dil_s        [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t relu_s       [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t pool_s       [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t batch_sz_s   [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t batch_norm_s [N_CONV_LAYERS] = { 0, 0, 0, 0};

	//Fully connected layers

	int32_t relu_fc      [N_FC_LAYERS] = { 0 } ;
	int32_t soft         [N_FC_LAYERS] = { 1 } ;
	int32_t transpose    [N_FC_LAYERS] = { 1 };
	int32_t ninputs      [N_FC_LAYERS] = { 1 };
	int32_t d3           [N_FC_LAYERS] = { 1 };
	int32_t d2           [N_FC_LAYERS] = { 128};
	int32_t d1           [N_FC_LAYERS] = { 2 } ;

	token_t **out_conv=(token_t**)malloc(sizeof(token_t *) * N_CONV_LAYERS);
	token_t **out_skip=(token_t**)malloc(sizeof(token_t *) * N_CONV_LAYERS);

	float **w_conv = (float**)malloc(sizeof(float *) * N_CONV_LAYERS);
	float **w_skip = (float**)malloc(sizeof(float *) * N_CONV_LAYERS);
	float **w_fc = (float**)malloc(sizeof(float *) * N_FC_LAYERS);

	for(int i = 0; i< N_CONV_LAYERS; i++ )
	{
		w_conv[i] = (float *)malloc(sizeof(float) * chans_c[i] * n_flt_c[i] * flt_dim_c[i] * flt_dim_c[i]);
		w_skip[i] = (float *)malloc(sizeof(float) * chans_s[i] * n_flt_s[i] * flt_dim_s[i] * flt_dim_s[i]);

                out_conv[i]= (token_t *)malloc(sizeof(token_t) * n_flt_c[i] * height_c[i] * width_c[i]);
                out_skip[i]= (token_t *)malloc(sizeof(token_t) * n_flt_s[i] * height_s[i] * width_s[i]);


	}

	for(int i = 0; i< N_FC_LAYERS; i++)
		w_fc[i] = (float *)malloc(sizeof(float) * d1[i] * d2[i]);

	/* unsigned INPUT_SIZE = n_channels[0] * feature_map_height[0] * feature_map_width [0]; */
	/* float* input_im = malloc(INPUT_SIZE*sizeof(float)); */


	token_t ** input_l=(token_t**)malloc(sizeof(token_t*) * N_CONV_LAYERS);
	for(int i=0; i<N_CONV_LAYERS; i++)
		input_l[i]=(token_t*)malloc(sizeof(token_t) *chans_c[i]*height_c[i]*width_c[i]);

	
    int test, n_tests, start_test = 1;

    unsigned in_len,in1_len, weights_len, bias_len, out_len;
    unsigned in_size, weights_size, bias_size, out_size, size;
    unsigned weights_offset, bias_offset, out_offset;

    token_t *acc_buf;
    float *sw_buf;

    float* dummy_b=malloc(300*sizeof(float));

    float* test_1=malloc(3072*sizeof(float));
  
    printf("\n====== %s ======\n\n", cfg_000[0].devname);

    // command line arguments
    if (argc < 3) {
	n_tests = 1;
    } else if (argc == 3) {
	n_tests = strtol(argv[1], NULL, 10);
	if (n_tests > MAX_TESTS) {
	    printf("Wrong input arguments!");
	    return 1;
	}
	start_test = strtol(argv[2], NULL, 10);
	if (start_test > MAX_TESTS) {
	    printf("Wrong input arguments!");
	    return 1;
	}

    } else {
	printf("Wrong input arguments!");
	return 1;
    }
    printf("  Executing %d tests\n", n_tests);

    int i;

    for (i=0; i<300; i++)
            dummy_b[i] = 0;

    // allocations
    printf("  Allocations\n");
    acc_buf = (token_t *) esp_alloc(MAX_SIZE);
    cfg_000[0].hw_buf = acc_buf;

    sw_buf = malloc(MAX_SIZE);
    
    
    load_model(test_1,w_conv[0],w_conv[1],w_skip[1],w_conv[2],w_skip[2],w_conv[3],w_skip[3],w_fc[0]);
    

    //store network input

    for (int i = 0; i<3072; i++ )
            input_l[0][i] = float2fx(test_1[i], FX_IL);


    //layer 0 
    
    printf("\n \n layer 0 \n \n");
    
    // calculate test parameters
    init_parameters(test,
		    chans_c[0], height_c[0], width_c[0],
		    n_flt_c[0], flt_dim_c[0], pad_c[0], stride_c[0],
		    0, 0, batch_sz_c[0],
		    &in_len, &weights_len, &bias_len, &out_len,
		    &in_size, &weights_size, &bias_size, &out_size,
		    &weights_offset, &bias_offset, &out_offset, &size);
    
    // initialize input data
    init_buffer(acc_buf, input_l[0], w_conv[0], dummy_b, in_len, weights_len, bias_len);
    
    /* for (i=0;i<32768;i++) */
    /* { */
    /* 	    if (i<20 ) */
    /* 		    printf("layer0 in: %f \n",fx2float(acc_buf[i],FX_IL)); */
    /* } */


    // hardware execution
    printf("\n  Start accelerator execution\n");
    esp_run(cfg_000, NACC);
    printf("  Completed accelerator execution\n");

    /* for (i=0;i<32768;i++) */
    /* { */
    /* 	    if (i<20 ) */
    /* 		    printf("layer0 after acc: %f \n",fx2float(acc_buf[out_offset+i],FX_IL)); */
    /* } */


    // execute the missing features in sw
    batch_norm(chans_c[0],height_c[0],width_c[0],flt_dim_c[0],flt_dim_c[0],
	    pad_c[0],pad_c[0],stride_c[0],stride_c[0],dil_c[0],dil_c[0],n_flt_c[0],&acc_buf[out_offset],batch_sz_c[0],batch_norm_c[0],relu_c[0],pool_out_c[0]);

    // software execution (pv)
    printf("\n  Start software execution 0 \n");
    sw_run(3, 32, 32,
	   16, 3, 1, 1,
	   1, 0, 1,
	   sw_buf, &sw_buf[weights_offset], &sw_buf[bias_offset], &sw_buf[out_offset],1);
    printf("  Completed software execution 0 \n");
    
    // validation
    validate_buffer(&acc_buf[out_offset], &sw_buf[out_offset], out_len);



    /* for (i=0;i<32768;i++) */
    /* { */
    /* 	    if (i<20 ) */
    /* 		    printf("layer0 out: %f \n",fx2float(acc_buf[out_offset+i],FX_IL)); */
    /* } */
    


    ////////////////////////////////////////////////

    //layer 2-to-4

    ////////////////////////////////////////////////

    for (int j=1; j< N_CONV_LAYERS; j++)
    {

	    if (j==1)
		    for (int i=0; i< chans_c[j]*width_c[j]*height_c[j];i++)
			    input_l[j][i]=acc_buf[out_offset+i];

	    unsigned old_out_offset=out_offset;
	    init_parameters(test,
			    chans_c[j], height_c[j], width_c[j],
			    n_flt_c[j], flt_dim_c[j], pad_c[j], stride_c[j],
			    0, 0, batch_sz_c[j],
			    &in_len, &weights_len, &bias_len, &out_len,
			    &in_size, &weights_size, &bias_size, &out_size,
			    &weights_offset, &bias_offset, &out_offset, &size);
    
	    // initialize input data
	    init_buffer(acc_buf, input_l[j], w_conv[j], dummy_b, in_len, weights_len, bias_len);


	    /* for (i=0;i<32768;i++) */
	    /* { */
	    /* 	    if (i<20 && j==2) */
	    /* 		    printf("init 3 : %f \n",fx2float(acc_buf[i],FX_IL)); */
	    /* } */

	    /* for (i=0;i<32768;i++) */
	    /* { */
	    /* 	    if (i<20 && j==1) */
	    /* 		    printf("buf1 init_buf: %f \n",fx2float(acc_buf[i],FX_IL)); */
	    /* } */

    
	    // hardware execution
	    printf("\n  Start accelerator execution % d \n", j);
	    esp_run(cfg_000, NACC);
	    printf("  Completed accelerator execution\n");


	    printf("\n  batchnorm %d \n", j);
	    batch_norm(chans_c[j],height_c[j],width_c[j],flt_dim_c[j],flt_dim_c[j],
		    pad_c[j],pad_c[j],stride_c[j],stride_c[j],dil_c[j],dil_c[j],n_flt_c[j],&acc_buf[out_offset],batch_sz_c[j],batch_norm_c[j],relu_c[j],0);
	    printf("\n  batchnorm done %d \n", j);


	    /* for (i=0;i<32768;i++) */
	    /* { */
	    /* 	    if (i<40 && j==2) */
	    /* 		    printf("after batch : %f \n",fx2float(acc_buf[out_offset+i],FX_IL)); */
	    /* } */
	    /* // software execution */
	    /* printf("\n  Start software execution\n"); */
	    /* sw_run(chans_c[j], height_c[j], width_c[j], */
	    /* 	    n_flt_c[j], flt_dim_c[j], pad_c[j], stride_c[j], */
	    /* 	    relu_c[j], 0, batch_sz_c[j], */
	    /* 	    sw_buf, &sw_buf[weights_offset], &sw_buf[bias_offset], &sw_buf[out_offset],batch_norm_c[j]); */
	    /* printf("  Completed software execution\n"); */

	    /* // validation */
	    /* validate_buffer(&acc_buf[out_offset], &sw_buf[out_offset], out_len); */

	    for (i=0;i<height_c[j]*width_c[j]*n_flt_c[j];i++)
	    	    out_conv[j][i]=acc_buf[out_offset+i];


	    /* for (i=0;i<32768;i++) */
	    /* { */
	    /* 	    if (i<20 && j==1) */
	    /* 		    printf("buf1 : %f \n",fx2float(acc_buf[out_offset+i],FX_IL)); */
	    /* } */


	    //layer 1 skip

	    printf("\n \n layer %d skip \n \n", j);

	    int32_t old_size=size;

	    init_parameters(test,
			    chans_s[j], height_s[j], width_s[j],
			    n_flt_s[j], flt_dim_s[j], pad_s[j], stride_s[j],
			    0, 0, batch_sz_s[j],
			    &in_len, &weights_len, &bias_len, &out_len,
			    &in_size, &weights_size, &bias_size, &out_size,
			    &weights_offset, &bias_offset, &out_offset, &size);
    
	    // initialize input data
	    init_buffer(acc_buf, acc_buf, w_skip[j], dummy_b, in_len, weights_len, bias_len);

    
	    // hardware execution
	    printf("\n  Start accelerator execution %d \n", j);
	    esp_run(cfg_000, NACC);
	    printf("  Completed accelerator execution\n");

	    // software execution
	    /* printf("\n  Start software execution\n"); */

	    /* sw_run(chans_s[j], height_s[j], width_s[j], */
	    /* 	    n_flt_s[j], flt_dim_s[j], pad_s[j], stride_s[j], */
	    /* 	    relu_s[j], 0, batch_sz_s[j], */
	    /* 	    sw_buf, &sw_buf[weights_offset], &sw_buf[bias_offset], &sw_buf[out_offset],batch_norm_s[j]); */


	    /* // validation */
	    /* validate_buffer(&acc_buf[out_offset], &sw_buf[out_offset], out_len); */

	    /* for (i=0;i<32768;i++) */
	    /* { */
	    /* 	    if (i<40 && j==2) */
	    /* 		    printf("after skip : %f \n",fx2float(acc_buf[out_offset+i],FX_IL)); */
	    /* } */

	    printf("\n\n\n");

	    for (i=0;i<height_c[j]*width_c[j]*n_flt_c[j];i++)
		    out_skip[j][i]=out_conv[j][i]+acc_buf[out_offset+i];

	    if (j!=3)
		    do_pooling_2x2(out_skip[j],batch_sz_c[j],n_flt_c[j],height_c[j],pool_out_c[j]);
	    else
		    do_pooling_8x8(out_skip[j],batch_sz_c[j],n_flt_c[j],height_c[j]);

	    /* for (i=0;i<32768;i++) */
	    /* { */
	    /* 	    if (i<20 && (j==2 || j==1)) */
	    /* 		    printf("after pool : %f \n",fx2float(out_skip[j][i],FX_IL)); */
	    /* } */

	    printf("\n\n\n");

	    if (j<N_CONV_LAYERS-1)
		    for (int i=0; i< chans_c[j+1]*width_c[j+1]*height_c[j+1];i++)
			    input_l[j+1][i]=out_skip[j][i];


    }






    //fc layer 
    printf("\n \n fclayer \n \n");

    cfg_001[0].hw_buf = acc_buf;
    /* (cfg_000[0].esp_desc)->footprint = 1; */

    // calculate test parameters
    init_parameters_gemm(test,
                    0, 1, 1, 1, 128, 2,
                    &in_len, &in1_len, &out_len, &in_size, &out_size, &size);

    // initialize input data
    init_buffer_gemm(acc_buf,w_fc[0],out_skip[3],in1_len,in_len-in1_len);

    // hardware execution
    printf("  Start accelerator execution\n");
    esp_run(cfg_001, NACC);
    printf("  Completed accelerator execution\n");

    
    for (i=0;i<2;i++)
	    printf("out: %f \n",fx2float(acc_buf[in_len+i],FX_IL));



    float* input;
    unsigned size1,size2;
    unsigned out_offset1,out_offset2;

    for (int j=0; j<N_CONV_LAYERS; j++)
    {

	    /* float* out = (float *)malloc(sizeof(float) * n_flt_c[i] * height_c[i] * width_c[i]); */

	    if(j==0)
		    input=test_1;
	    else
		    input=&sw_buf[out_offset2];

	    init_parameters(test,
			    chans_c[j], height_c[j], width_c[j],
			    n_flt_c[j], flt_dim_c[j], pad_c[j], stride_c[j],
			    0, 0, batch_sz_c[j],
			    &in_len, &weights_len, &bias_len, &out_len,
			    &in_size, &weights_size, &bias_size, &out_size,
			    &weights_offset, &bias_offset, &out_offset1, &size1);

    	    init_buffer1(sw_buf, input, w_conv[j], dummy_b, in_len, weights_len, bias_len);
    	    // software execution
    	    printf("\n  Start software execution\n");
    	    sw_run(chans_c[j], height_c[j], width_c[j],
    		    n_flt_c[j], flt_dim_c[j], pad_c[j], stride_c[j],
    		    relu_c[j], 0, batch_sz_c[j],
    		    sw_buf, &sw_buf[weights_offset], &sw_buf[bias_offset], &sw_buf[out_offset1],batch_norm_c[j]);
    	    printf("  Completed software execution\n");

    	    // software execution
    	    printf("\n  Start software execution\n");

	    if (j!=0)
	    {
		    
		    init_parameters(test,
				    chans_s[j], height_s[j], width_s[j],
				    n_flt_s[j], flt_dim_s[j], pad_s[j], stride_s[j],
				    0, 0, batch_sz_s[j],
				    &in_len, &weights_len, &bias_len, &out_len,
				    &in_size, &weights_size, &bias_size, &out_size,
				    &weights_offset, &bias_offset, &out_offset2, &size2);

		    init_buffer1(&sw_buf[size1], &sw_buf[out_offset1], w_skip[j], dummy_b, in_len, weights_len, bias_len);

		    sw_run(chans_s[j], height_s[j], width_s[j],
			    n_flt_s[j], flt_dim_s[j], pad_s[j], stride_s[j],
			    relu_s[j], 0, batch_sz_s[j],
			    sw_buf, &sw_buf[weights_offset], &sw_buf[bias_offset], &sw_buf[out_offset2],batch_norm_s[j]);

		    for (i=0;i<height_c[j]*width_c[j]*n_flt_c[j];i++)
			    sw_buf[out_offset2+i]+=sw_buf[out_offset1+i];

		    if (j!=3)
			    do_pooling_2x2f(&sw_buf[out_offset2],batch_sz_c[j],n_flt_c[j],height_c[j],pool_out_c[j]);
		    else
			    do_pooling_8x8f(&sw_buf[out_offset2],batch_sz_c[j],n_flt_c[j],height_c[j]);
	    }
	    else
		    out_offset2=out_offset1;

    }


    float out_gold[2];

    gemm_pv(w_fc[0],&sw_buf[out_offset2],out_gold,relu_fc[0],0,1,d1[0],d2[0],1);

    for (i=0;i<2;i++)
	    printf("out_gold: %f \n",out_gold[i]);




    // free
    esp_free(acc_buf);
    free(sw_buf);


    free(dummy_b);
    
    free(test_1); 
   

    free(w_conv[0]);
    free(w_conv[1]);
    free(w_conv[2]);
    free(w_conv[3]);

    free(w_skip[0]);
    free(w_skip[1]);
    free(w_skip[2]);
    free(w_skip[3]);

    free(w_fc[0]);

    printf("\n====== %s ======\n\n", cfg_000[0].devname);

    return 0;
	
}
