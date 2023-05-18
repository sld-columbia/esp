// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "dwarf_nn_cfg.h"
#include "load_model.h"

//software softmax
void soft_max(token_t *acc_buf, unsigned out_size, unsigned offset)
{
	//get start index 
	unsigned idx= offset - out_size;

	for (int i = 0; i < out_size; i++ ) {
    	    float max = fx2float(acc_buf[idx], FX_IL);
    	    for (int j = 1; j < out_size; j++ )
    		    if (fx2float(acc_buf[idx + j], FX_IL) > max)
    			    max = fx2float(acc_buf[idx + j], FX_IL);

    	    float denom = 0;
    	    for (int j = 0; j <out_size; j++ )
    		    denom += exp(fx2float(acc_buf[idx + j], FX_IL) - max);

    	    acc_buf[idx  +  i] = float2fx(exp(fx2float(acc_buf[idx +  i], FX_IL) - max) / denom, FX_IL);
	}
}

static void init_buffer_gemm(token_t *acc_buf,float *mat1,token_t *mat2, float *sw_buf, unsigned in1_len,unsigned in2_len, unsigned out_len, unsigned* old_out_len, unsigned* offset)
{
        int i;

        printf("  Initialize inputs\n");

        for (i = 0; i < in2_len; i++ ) {
                sw_buf[in1_len +  i] = fx2float(mat2[i], FX_IL);
        }

        for (i = 0; i < in1_len; i++ ) {

#ifdef __FIXED
                acc_buf[i] = float2fx(mat1[i], FX_IL);
#else
                acc_buf[i] = mat1[i];
#endif
                sw_buf[i] = mat1[i];
        }

	*old_out_len = out_len;
	*offset += in1_len + out_len;
}

static void init_buffer_conv2d(token_t *acc_buf, native_t *sw_buf, token_t* input, float*weights, float*bias, unsigned in_len, unsigned out_len, unsigned weights_len, unsigned bias_len, unsigned*  old_out_len, unsigned* offset)
{
	int i;

	printf("  Initialize inputs\n");

	for (i = 0; i < in_len; i++ ) {
		sw_buf[i] = fx2float(input[i], FX_IL);
	}

	for (i = 0; i < weights_len; i++ ) {
#ifdef __FIXED
		acc_buf[i] = float2fx(weights[i], FX_IL);
#else
		acc_buf[i] = weights[i];
#endif
		sw_buf[in_len +  i] = weights[i];
	}

	for (i = 0; i < bias_len; i++ ) {
#ifdef __FIXED
		acc_buf[weights_len +  i] = float2fx(bias[i], FX_IL);
#else
		acc_buf[weights_len +  i] = bias[i];
#endif
		sw_buf[in_len + weights_len +  i] = bias[i];
	}

	*old_out_len = out_len;
	*offset += weights_len + bias_len + out_len;

}


static void init_parameters_gemm(int layer, int32_t do_relu, int32_t transpose, int32_t ninputs,
				 int32_t d3, int32_t d2, int32_t d1,
				 unsigned *in_len, unsigned *in1_len, unsigned *out_len,
				 unsigned *in_size, unsigned *out_size, unsigned *size)
{
        int32_t ld_offset1, ld_offset2, st_offset;
        unsigned in2_len;

        *in1_len = round_up(ninputs * d1 * d2, DMA_WORD_PER_BEAT(sizeof(token_t)));
        in2_len = round_up(ninputs * d2 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
        *in_len = *in1_len  +  in2_len;
        *out_len = round_up(ninputs * d1 * d3, DMA_WORD_PER_BEAT(sizeof(token_t)));
        *in_size = *in_len * sizeof(token_t);
        *out_size = *out_len * sizeof(token_t);
        *size = *in_size  +  *out_size;

        ld_offset1 = 0;
        ld_offset2 = *in1_len;
        st_offset = *in_len;

        gemm_cfg_000[layer-1].do_relu = do_relu;
        gemm_cfg_000[layer-1].transpose = transpose;
        gemm_cfg_000[layer-1].ninputs = ninputs;
        gemm_cfg_000[layer-1].d1 = d1;
        gemm_cfg_000[layer-1].d2 = d2;
        gemm_cfg_000[layer-1].d3 = d3;
        gemm_cfg_000[layer-1].ld_offset1 = ld_offset1;
        gemm_cfg_000[layer-1].ld_offset2 = ld_offset2;
        gemm_cfg_000[layer-1].st_offset = st_offset;


	if (layer>0 && layer<N_FC_LAYERS)
	{
		gemm_cfg_000[layer].src_offset= gemm_cfg_000[layer-1].src_offset  +  *in_size;
		gemm_cfg_000[layer].dst_offset= gemm_cfg_000[layer-1].src_offset  +  *in_size;
	}

	if (layer==N_FC_LAYERS)
	{
		gemm_cfg_000[layer-2].dst_offset+= (*in1_len)*sizeof(token_t);
	}
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

static void init_parameters(int layer, int32_t n_channels, int32_t feature_map_height, int32_t feature_map_width,
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

    output_h = (feature_map_height  +  2 * pad_dim - ((filter_dim - 1)  +  1)) / stride  +  1;
    output_pool_h = pool_type ? output_h / 2 : output_h;

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
    *bias_offset = *in_len  +  *weights_len;
    *out_offset  = *in_len  +  *weights_len  +  *bias_len;
    *size = *in_size  +  *weights_size  +  *bias_size  +  *out_size;

    conv2d_cfg_000[layer-1].n_channels = n_channels;
    conv2d_cfg_000[layer-1].feature_map_height = feature_map_height;
    conv2d_cfg_000[layer-1].feature_map_width = feature_map_width;
    conv2d_cfg_000[layer-1].n_filters = n_filters;
    conv2d_cfg_000[layer-1].filter_dim = filter_dim;
    conv2d_cfg_000[layer-1].is_padded = is_padded;
    conv2d_cfg_000[layer-1].stride = stride;
    conv2d_cfg_000[layer-1].do_relu = do_relu;
    conv2d_cfg_000[layer-1].pool_type = pool_type;
    conv2d_cfg_000[layer-1].batch_size = batch_size;

    //set offsets for successive layer

    if (layer<N_CONV_LAYERS)
    {
	    conv2d_cfg_000[layer].src_offset = conv2d_cfg_000[layer-1].src_offset  +  (*out_offset)*sizeof(token_t);
	    conv2d_cfg_000[layer].dst_offset = conv2d_cfg_000[layer-1].src_offset  +  (*out_offset)*sizeof(token_t);
    }
    else
    {
	    gemm_cfg_000[0].src_offset = conv2d_cfg_000[layer-1].src_offset  +  (*out_offset)*sizeof(token_t);
	    gemm_cfg_000[0].dst_offset = conv2d_cfg_000[layer-1].src_offset  +  (*out_offset)*sizeof(token_t);

    }

    // print test info
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
}

inline bool sw_is_a_ge_zero_and_a_lt_b(int a, int b) {
    return (a >= 0 && a < b);
}

inline float max_of_4(float a, float b, float c, float d) {
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

inline float avg_of_4(float a, float b, float c, float d) {
    return (a  +  b  +  c  +  d) / 4;
}

inline void pooling_2x2(float *in, float *out, unsigned size, unsigned type) {

    /* assert(type >= 1 && type <= 2); */

    unsigned i, j, out_i;
    float a, b, c, d;
    for (i = 0; i < size - 1; i += 2) {
        for (j = 0; j < size - 1; j += 2) {
	    a = in[i * size  +  j];
	    b = in[(i  +  1) * size  +  j];
	    c = in[i * size  +  (j  +  1)];
	    d = in[(i  +  1) * size  +  (j  +  1)];
	    out_i = (i / 2) * (size/2)  +  (j / 2);
	    if (type == 1)
		out[out_i] = max_of_4(a, b, c, d);
	    else
		out[out_i] = avg_of_4(a, b, c, d);
	}
    }
}

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


void sw_conv_layer (
    const float* input, const int channels, const int height, const int width,
    const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
    const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
    const int num_filters, const float* weights, const float* biases, float* output,
    const bool do_relu, const int pool_type, const int batch_size)
{

    const int channel_size = round_up(height * width, DMA_RATIO);
    const int filter_size = channels * kernel_w * kernel_h;
    const int output_h = (height  +  2 * pad_h - (dilation_h * (kernel_h - 1)  +  1)) / stride_h  +  1;
    const int output_w = (width  +  2 * pad_w - (dilation_w * (kernel_w - 1)  +  1)) / stride_w  +  1;
    const int out_channel_size = round_up(output_w * output_h, DMA_RATIO);
    const int pool_channel_size = round_up((output_w/2) * (output_h/2), DMA_RATIO);

    for (int batch_i = 0;  batch_i < batch_size; batch_i++ ) {
	for (int num_filter = 0; num_filter < num_filters; num_filter++ ) {
	    for (int output_row = 0; output_row < output_h; output_row++ ) {
		for (int output_col = 0; output_col< output_w; output_col++ ) {
		    int k = 0;
		    float out_value = 0;
		    for (int channel = 0; channel < channels; channel++ ) {
			for (int kernel_row = 0; kernel_row < kernel_h; kernel_row++ ) {
			    for (int kernel_col = 0; kernel_col < kernel_w; kernel_col++ ) {
				int input_row = (output_row * stride_h) - pad_h  +  kernel_row * dilation_h;
				int input_col = (output_col * stride_w) - pad_w  +  kernel_col * dilation_w;
				if (!(!sw_is_a_ge_zero_and_a_lt_b(input_row, height) ||
				      (sw_is_a_ge_zero_and_a_lt_b(input_row, height) &&
				       !sw_is_a_ge_zero_and_a_lt_b(input_col, width)))) {
				    out_value += input[batch_i * channels * channel_size  +  channel * channel_size  +
						       input_row * width  +  input_col] *
					weights[num_filter * filter_size  +  k];
				}
				k++ ;
			    }
			}
		    }
		    out_value += biases[num_filter];

		    if (do_relu && out_value < 0)
			out_value = 0;

		    output[batch_i * num_filters * out_channel_size  +  num_filter * out_channel_size  +
			   output_row * output_w  +  output_col] = out_value;

		}
	    }

	    if (pool_type)
		pooling_2x2(&output[batch_i * num_filters * out_channel_size  +  num_filter * out_channel_size],
			    &output[batch_i * num_filters * pool_channel_size  +  num_filter * pool_channel_size],
			    output_w, pool_type);
	}
    }
}

int main(int argc, char **argv)
{
    const char *labels[] = { "airplane",
			     "automobile",
			     "bird",
			     "cat",
			     "deer",
			     "dog",
			     "frog",
			     "horse",
			     "ship",
			     "truck" };

    unsigned in_len, in1_len, weights_len, bias_len, out_len;
    unsigned in_size, weights_size, bias_size, out_size, size;
    unsigned weights_offset, bias_offset, out_offset;

    token_t *acc_buf;
    native_t *sw_buf;


    printf("\n====== %s ======", cfg_000[0].devname);
    printf("\n====== %s ======\n\n", cfg_000[N_CONV_LAYERS].devname);

    //network description

    //convolutional layers

    int32_t n_channels         [N_CONV_LAYERS] = { 3, 32,  32,  64};
    int32_t feature_map_height [N_CONV_LAYERS] = { 32, 32, 16, 8};
    int32_t feature_map_width  [N_CONV_LAYERS] = { 32, 32, 16, 8};
    int32_t n_filters          [N_CONV_LAYERS] = { 32, 32, 64, 128};
    int32_t filter_dim         [N_CONV_LAYERS] = { 3, 3, 3, 3};
    int32_t is_padded          [N_CONV_LAYERS] = { 1, 1, 1, 1};
    int32_t stride             [N_CONV_LAYERS] = { 1, 1, 1, 1};
    int32_t dilation           [N_CONV_LAYERS] = { 1, 1, 1, 1};
    int32_t do_relu_conv       [N_CONV_LAYERS] = { 1, 1, 1, 1};
    int32_t pool_type          [N_CONV_LAYERS] = { 0, 1, 1, 1};
    int32_t batch_size         [N_CONV_LAYERS] = { 1, 1, 1, 1};

    //fully connected layers

    int32_t do_relu_fc         [N_FC_LAYERS] = { 1, 0} ;
    int32_t soft               [N_FC_LAYERS] = { 0, 1} ;
    int32_t transpose          [N_FC_LAYERS] = { 1, 1};
    int32_t ninputs            [N_FC_LAYERS] = { 1, 1};
    int32_t d3                 [N_FC_LAYERS] = { 1, 1};
    int32_t d2                 [N_FC_LAYERS] = { 2048, 64};
    int32_t d1                 [N_FC_LAYERS] = { 64, 10};


    // model allocations

    float **w_conv = (float**)malloc(sizeof(float *) * N_CONV_LAYERS);
    float **bias_conv = (float**)malloc(sizeof(float *) * N_CONV_LAYERS);

    float **w_fc = (float**)malloc(sizeof(float *) * N_FC_LAYERS);
    float **bias_fc = (float**)malloc(sizeof(float *) * N_FC_LAYERS);

    for(int i = 0; i< N_CONV_LAYERS; i++ )
    {
	    w_conv[i] = (float *)malloc(sizeof(float) * n_channels[i] * n_filters[i] * filter_dim[i] * filter_dim[i]);
	    bias_conv[i] = (float *)malloc(sizeof(float) * n_filters[i]);
    }

    for(int i = 0; i< N_FC_LAYERS; i++ )
    {
	    w_fc[i] = (float *)malloc(sizeof(float) * d1[i] * d2[i]);
	    bias_fc[i] = (float *)malloc(sizeof(float) * d1[i]);
    }


    unsigned INPUT_SIZE = n_channels[0] * feature_map_height[0] * feature_map_width [0];
    float* input_im = malloc(INPUT_SIZE*sizeof(float));

    //model load

    load_model(input_im, w_conv, bias_conv, w_fc, bias_fc);

    // allocations

    printf("  Allocations\n");
    acc_buf = (token_t *) esp_alloc(MAX_SIZE);

    for (int i = 0; i< N_LAYERS; i++ )
	    cfg_000[i].hw_buf = acc_buf;

    sw_buf = malloc(MAX_SIZE);


    //run application in software

    float** output_conv= (float**)malloc(sizeof(float)*N_CONV_LAYERS);
    for (int i = 0;i < N_CONV_LAYERS; i++)
            output_conv[i]=(float*)malloc(sizeof(float)*n_filters[i]*feature_map_height[i]*feature_map_width[i]);
    float** output_fc= (float**)malloc(sizeof(float)*N_FC_LAYERS);
    for (int i = 0; i < N_FC_LAYERS; i++)
            output_fc[i]=(float*)malloc(sizeof(float)*d2[i]);

    float* input_conv; /* =(float*)malloc(sizeof(float)*32768); */

    printf("Run programmer views \n");

    struct timespec ts_start, ts_end;

    gettime(&ts_start);
    printf("\n -> conv_layers ... \n");
    for (int i=0;i<N_CONV_LAYERS; i++)
    {

            if (i==0)
                    input_conv=input_im;
            else
                    input_conv=output_conv[i-1];

            sw_conv_layer(input_conv,n_channels[i],feature_map_height[i],feature_map_width[i],filter_dim[i],filter_dim[i],is_padded[i],is_padded[i],stride[i],stride[i],dilation[i],dilation[i],n_filters[i],w_conv[i],bias_conv[i],output_conv[i],do_relu_conv[i],pool_type[i],batch_size[i]);

    }

    printf("\n ->fc_layers ... \n");
    for (int i=0;i<N_FC_LAYERS;i++)
    {

            float* input_fc;

            if (i==0)
                    input_fc=output_conv[3];
            else
                    input_fc=output_fc[i-1];

            printf("start %d\n",i);
            gemm_pv(w_fc[i],input_fc,output_fc[i],do_relu_fc[i],soft[i],transpose[i],d1[i],d2[i],1);

    }

    gettime(&ts_end);


    //store network input

    for (int i = 0; i<INPUT_SIZE; i++ )
	    acc_buf[i] = float2fx(input_im[i], FX_IL);

    //initialize parameters / store model / set offsets

    unsigned offset = INPUT_SIZE;
    unsigned old_out_len = INPUT_SIZE;

    for (int i = 0; i < N_CONV_LAYERS; i++ )
    {
	    //initialize convolutional layers parameters and offsets

	    init_parameters(i + 1,
			    n_channels[i], feature_map_height[i],
			    feature_map_width[i], n_filters[i],
			    filter_dim[i], is_padded[i], stride[i],
			    do_relu_conv[i], pool_type[i],
			    batch_size[i],&in_len, &weights_len,
			    &bias_len, &out_len, &in_size,
			    &weights_size, &bias_size, &out_size,
			    &weights_offset, &bias_offset,
			    &out_offset, &size);

	    // store layers parameters and unpdate offsets

	    init_buffer_conv2d(&acc_buf[offset], sw_buf,
			 &acc_buf[offset-old_out_len],
			 w_conv[i], bias_conv[i],
			 in_len, out_len, weights_len,
			 bias_len, &old_out_len, &offset);

    }

    //modify dst_offset for the last convolutional layer

    conv2d_cfg_000[N_CONV_LAYERS-1].dst_offset+= (d2[0]*d1[0])*sizeof(token_t);


    for (int i = 0; i < N_FC_LAYERS; i++ )
    {
	    //initialize fc layers parameters and offsets

    	    init_parameters_gemm(i + 1,
    				 do_relu_fc[i], transpose[i],
    				 ninputs[i],d3[i], d2[i], d1[i],
    				 &in_len, &in1_len, &out_len,
    				 &in_size, &out_size, &size);

	    //store layers parameters and update offsets

    	    init_buffer_gemm(&acc_buf[offset-old_out_len],
    			     w_fc[i] ,&acc_buf[offset],
    			     sw_buf, in1_len,in_len-in1_len,
		             out_len, &old_out_len, &offset);

    }

    // accelerators invocation

    printf("\n  Start accelerators execution \n");


    struct timespec ts_start1, ts_end1;
    gettime(&ts_start1);


    unsigned nacc_arr[N_LAYERS] = {1, 1, 1, 1, 1, 1};
    esp_run_parallel(cfg, N_LAYERS, nacc_arr);

    gettime(&ts_end1);

    printf("  Completed accelerators execution\n");

    //software execution for softmax function (not supproted yet)

    soft_max(acc_buf,d1[N_FC_LAYERS-1],offset);

    //Print network outputs

    printf("\n \n Output results hardware : \n");
    for (int i = 0; i < d1[N_FC_LAYERS-1]; i++ ){
    	    printf("Class %d (%s): %f \n", i, labels[i], fx2float(acc_buf[offset-d1[N_FC_LAYERS-1] +  i], FX_IL));
    }


    printf("\n \n Output results software: \n");
    for (int i = 0; i < d1[N_FC_LAYERS-1]; i++ ){
    	    printf("Class %d (%s): %f \n", i, labels[i], output_fc[N_FC_LAYERS-1][i]);
    }


    unsigned long long sw_ns,sw_ns1;
    sw_ns = ts_subtract(&ts_start, &ts_end);
    sw_ns1 = ts_subtract(&ts_start1, &ts_end1);

    printf("\n \n");

    printf("  > HW Test time : %llu (ns)\n", sw_ns1);

    printf("  > SW Test time : %llu (ns)\n", sw_ns);


    // free
    esp_free(acc_buf);
    free(sw_buf);

    printf("\n====== %s ======", cfg_000[0].devname);
    printf("\n====== %s ======\n\n", cfg_000[N_CONV_LAYERS].devname);

    return 0;

}
