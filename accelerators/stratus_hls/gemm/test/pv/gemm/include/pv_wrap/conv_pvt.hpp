// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#if defined(USE_CBLAS)
#include "cblas.h"
#endif // USE_CBLAS

#include "golden.hpp"
#ifndef __CONV2D_DATA_HPP__
#include "golden.cpp"
#endif

// // #include "golden.cpp"
// #include "mojo.h"
#include "reshape_input.hpp" //_input.hpp"
#include "reshape_weights.hpp"

// void conv_pvt(int l_n,float*layer_in,float*out,float *W,float* bias,int in_ch,int out_ch,int out_size,int in_cols,int in_rows,int out_cols,int out_rows,int in_pad_h,int in_pad_w,int out_pad_h,int out_pad_w,int W_size,int W_cols,int W_rows,int stride_h,int stride_w,int dilation_h,int dilation_w, int batch_size,int pool_out,int pool_in)

void conv_pvt(int l_n,int prev_soft,float*layer_in_sw,float*layer_in_hw,float*out,float *W,float* bias,int in_ch,int out_ch,int in_cols,int in_rows,int out_cols,int out_rows,int in_pad_h,int in_pad_w,int out_pad_h,int out_pad_w,int W_size,int W_cols,int W_rows,int stride_h,int stride_w,int dilation_h,int dilation_w, int batch_size,int pool_out,int pool_in)
{
	
	float* w_pv=new float[W_size];
	int k_size=W_cols*W_rows;
	
	//weights matrix reshape 

	reshape_weights(w_pv,W,in_ch,out_ch,k_size);

	//remove padding from input if present


	//select input between: reshaped input from dwarf model (cnn) and outputs of previous 
        //layer executed by the accelerator's programmer's view (layer_in_hw)

	int in_size=(in_cols-2*out_pad_w) * (in_rows-2*out_pad_h) * in_ch;
	float* cnn_in=new float[in_size-1];

	if (prev_soft==1)
	{
		reshape_input(layer_in_sw,pool_in,in_rows,in_cols,in_pad_h,in_pad_w,in_ch);
		cnn_in=layer_in_sw;
	}
	else
		cnn_in=layer_in_hw;

	//Call to Conv2d programmer's view 

	sw_conv_layer(cnn_in,in_ch,out_rows-2*in_pad_h,out_cols-2*in_pad_w,W_rows,W_cols,
		      in_pad_h,in_pad_w,stride_h,stride_w,dilation_h,dilation_w,out_ch,w_pv,
		      bias,out,1,pool_out,batch_size);
	
}

