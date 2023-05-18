// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

// #ifndef __CONVNET_TEST
// #include "golden.hpp"
// #endif
#include <stdio.h>
#include "math.h"

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
    return (a + b + c + d) / 4;
}

inline float variance(float *in, float mean, unsigned size) {
	float var=0;
	float offs=0.00001;
	for (unsigned i=0;i<size;i++){
		var+=pow(in[i]-mean,2);
	}
	var=sqrt(var/size+offs);
	return var;
}
	

inline void do_reluf(float *in, unsigned size) {
	for (unsigned i=0;i<size;i++){
		if (in[i]<0){
			in[i]=0;
		}
		}
}

inline void batch_normalization(float *in, float mean,float var, unsigned size) {
	for (unsigned i=0;i<size;i++){
		in[i]=(in[i]-mean)/var;
	}
}


inline void pooling_8x8(float *in, float *out, unsigned size) {

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
		
	
	    // 	std::endl;
	}
    }
}


inline void pooling_2x2(float *in, float *out, unsigned size, bool type) {

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


inline void do_pooling_8x8(float*out,int batch_size, int num_filters, int output_w)
{
	const int out_channel_size = output_w * output_w; //round_up(output_w * output_h, DMA_WORD_PER_BEAT);
	const int pool_channel_size = output_w/8 * output_w/8;//round_up((output_w/2) * (output_h/2), DMA_WORD_PER_BEAT);

	for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
		for (int num_filter = 0; num_filter < num_filters; num_filter++) {
			pooling_8x8(&out[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],&out[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],output_w);
		}
	}
}



inline void do_pooling_2x2(float*out,int batch_size, int num_filters, int output_w,bool p_type)
{
	const int out_channel_size = output_w * output_w; //round_up(output_w * output_h, DMA_WORD_PER_BEAT);
	const int pool_channel_size = output_w/2 * output_w/2;//round_up((output_w/2) * (output_h/2), DMA_WORD_PER_BEAT);

	for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
		for (int num_filter = 0; num_filter < num_filters; num_filter++) {
			pooling_2x2(&out[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],&out[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],output_w, p_type);
		}
	}
}

void sw_conv_layer (
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

	// for (int i=0;i<10; i++)
	// 	std::cout<<"input["<<i<<"]="<<input[i]<<"\n";

	// std::cout<<"\n \n";

	// std::ofstream ofile ("convtest.txt");
	// if (ofile.is_open())
	// {

    for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
	for (int num_filter = 0; num_filter < num_filters; num_filter++) {
	    float acc=0;
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
				    out_value += input[batch_i * channels * channel_size + channel * channel_size +input_row * width + input_col] *weights[num_filter * filter_size + k];
				    // if (channels==3 && num_filter==0 && output_row==0 && output_col==0){
				    // 	    std::cout<<"channel,kernel_row,kernel_col,input,weight,out_value,i_r,i_col,height,width "<<channel<<" "<<kernel_row<<" "<<kernel_col<<" "<<input[batch_i * channels * channel_size + channel * channel_size +input_row * width + input_col]<<" "<< weights[num_filter * filter_size + k]<<" "<<out_value<<" "<<input_row<<" "<<input_col<<" "<<height<<" "<<width<<std::endl;
				    // }
			    // ofile<<"in,w,index_in,index_w,k:"<<input[batch_i * channels * channel_size + channel * channel_size +input_row * width + input_col]<<" "<<weights[num_filter * filter_size + k]<<" "<<batch_i * channels * channel_size + channel * channel_size +input_row * width + input_col<<" "<<num_filter * filter_size + k<<" "<<k<<"\n";

				}

                                // if (num_filter==0 && output_row==0 && output_col==0 && channel==0)
                                //         printf("channel 0: %d %d %d %d %d %f %f \n",k,input_row,input_col,channel*channel_size+input_row * width + input_col,
                                //                channel* filter_size +num_filter*(kernel_h*kernel_w)+ k,weights[num_filter*filter_size+ k],input[ channel * channel_size +input_row * width + input_col]);

                                // if (num_filter==0 && output_row==0 && output_col==0 && channel==1)
                                //         printf("channel 1:%d %d %d %d %d %f %f \n",k,input_row,input_col,channel*channel_size+input_row * width + input_col,
                                //                channel* filter_size +num_filter*(kernel_h*kernel_w)+ k,weights[num_filter* filter_size + k],input[ channel * channel_size +input_row * width + input_col]);


				k++;
			    }
			}
		    }
		    out_value += biases[num_filter];
      
		    
		    //relu feature modified 
		    // if (do_relu && out_value < 0)
		    // 	out_value = 0;

		    output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size + output_row * output_w + output_col] = out_value;
		    // ofile<<"out_val,index,k:"<<output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size + output_row * output_w + output_col]<<" "<<batch_i * num_filters * out_channel_size + num_filter * out_channel_size + output_row * output_w + output_col<<" "<<k<<"\n";



		    // printf("output_index %d \n",batch_i * num_filters * out_channel_size + num_filter * out_channel_size +
		    // 	   output_row * output_w + output_col);
		    // std::cout << "out_value[" << num_filter << "," << output_row <<
		    //     "," << output_col << "]: " << out_value << std::endl;
		    acc+=out_value;
		    
		}
	    }
	    // printf("end output \n \n \n");
	    // std::cout << "pool_channel_size " << pool_channel_size << std::endl;
	    
	    float mean=acc/out_channel_size;
	    // std::cout<<"mean:"<<mean<<std::endl;

	    float var;
	    //batchnorm for convnet test
	    if (batch_norm){
		    var=variance(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,out_channel_size);
		    // std::cout<<"variance:"<<var<<std::endl;
		    batch_normalization(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,var,out_channel_size);
			    }
	    if (do_relu)
	    {
		    do_reluf(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],out_channel_size);
	    }
		    

            if (pool_type)
		    pooling_2x2(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],
				&output[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],
				output_w, pool_type);


	}
    }


    // ofile.close();
    // 	}
    // 	else std::cout << "Unable to open file";

}



void batch_norm (
        const int channels, const int height, const int width,
        const int kernel_h, const int kernel_w, const int pad_h, const int pad_w,
        const int stride_h, const int stride_w, const int dilation_h, const int dilation_w,
        const int num_filters, float* output,const int batch_size,int do_relu,int pool_type)
{

        /* const int channel_size = round_up(height * width, DMA_RATIO); */
        /* const int filter_size = channels * kernel_w * kernel_h; */
        const int output_h = (height + 2 * pad_h - (dilation_h * (kernel_h - 1) + 1)) / stride_h + 1;
        const int output_w = (width + 2 * pad_w - (dilation_w * (kernel_w - 1) + 1)) / stride_w + 1;
        const int out_channel_size = output_w * output_h;
        const int pool_channel_size = output_w/2 * output_h/2;

        for (int batch_i = 0;  batch_i < batch_size; batch_i++) {
                for (int num_filter = 0; num_filter < num_filters; num_filter++) {
                        float acc=0;
                        for (int output_row = 0; output_row < output_h; output_row++) {
                                for (int output_col = 0; output_col< output_w; output_col++) {

                                acc+=output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size +
                                            output_row * output_w + output_col];

                                }
                        }

                        float mean=acc/out_channel_size;
                        float var=0;
                        //batchnorm for convnet test          
                        var=variance(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,out_channel_size);

                        batch_normalization(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],mean,var,out_channel_size);

                        if (do_relu)
                        {
                                do_reluf(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],out_channel_size);
                        }
                        if (pool_type)
                                pooling_2x2(&output[batch_i * num_filters * out_channel_size + num_filter * out_channel_size],
                                            &output[batch_i * num_filters * pool_channel_size + num_filter * pool_channel_size],
                                            output_w, pool_type);

                }
        }
}
