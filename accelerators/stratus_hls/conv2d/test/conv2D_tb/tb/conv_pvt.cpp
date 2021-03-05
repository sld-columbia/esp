// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>

#include <assert.h>

#if defined(USE_CBLAS)
#include "cblas.h"
#endif // USE_CBLAS

#include "golden.hpp"
#include "mojo.h"

void reshape_input(float*layer_in_soft,int in_rows,int in_cols,int in_ch,int in_pad_h,int in_pad_w,int pool_in,int pool_out)
{
	if (in_pad_h>0)
	{	
		//input reshape

		if (pool_in==1)                     //input reshape if the input is padded and pooling has been perfomed in the previous layer executed in software
		{
			int rows=(in_rows+2*in_pad_h)/2;
			int cols=(in_cols+2*in_pad_w)/2;
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < rows-in_pad_h ; j++)    
					for (int i = 1; i < cols-in_pad_w ; i++) 
					{
						int index_out = k*rows*cols+j * cols + i;
						int ind_out=k*(rows-2*in_pad_h)*(cols-2*in_pad_w)+(j-1)*(cols-2*in_pad_w)+(i-1);
						layer_in_soft[ind_out] =layer_in_soft[index_out];
					}
		}
		else                              //input reshape if input padded
		{
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < in_cols-in_pad_h ; j++)     
					for (int i = 1; i < in_rows-in_pad_w ; i++) 
					{
						int index_out = k*in_rows*in_cols+j * in_cols + i;
						int ind_out=k*(in_rows-2*in_pad_h)*(in_cols-2*in_pad_w)+(j-1)*(in_cols-2*in_pad_w)+(i-1);
						layer_in_soft[ind_out] =layer_in_soft[index_out];
					}
		}

	}
	else
	{
		//input reshape
		if (pool_in==1)               //same input reshape as above
		{
			int rows=(in_rows+2*in_pad_h)/2;
			int cols=(in_cols+2*in_pad_h)/2;
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < rows-in_pad_h ; j++)     
					for (int i = 1; i < cols-in_pad_w ; i++) 
					{
						int index_out = k*rows*cols+j * cols + i;
						int ind_out=k*(rows-2*in_pad_h)*(cols-2*in_pad_w)+(j-1)*(cols-2*in_pad_w)+(i-1);
						layer_in_soft[ind_out] =layer_in_soft[index_out];
					}

		}
		else
		{
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < in_cols-in_pad_h ; j++)     
					for (int i = 1; i < in_rows-in_pad_w ; i++) 
					{
						int index_out = k*in_rows*in_cols+j * in_cols + i;
						int ind_out=k*(in_rows-2*in_pad_h)*(in_cols-2*in_pad_w)+(j-1)*(in_cols-2*in_pad_w)+(i-1);
						layer_in_soft[ind_out] =layer_in_soft[index_out];
					}
		}

	}
}


void validate_hw(int l_n,float* out,float* cnn_out,int out_rows, int out_cols,int out_pad_h,int out_ch,int pool_out,int out_size)
{
	  std::ofstream myfilex;
	  if (l_n==1)
	  	  myfilex.open ("res1.txt");
	  else if (l_n==2)
	  	  myfilex.open ("res2.txt");
	  else if (l_n==3)
	  	  myfilex.open ("res3.txt");
	  else if (l_n==4)
	  	  myfilex.open ("res4.txt");

	  int rows,cols,sz;

	  if (pool_out==1)
	  {
	  	  rows=(out_rows+2*out_pad_h)/2;
		  cols=(out_cols+2*out_pad_h)/2;
		  sz=rows*cols*out_ch;
	  }
	  else 
	  {
		  rows=out_rows;
		  cols=out_cols;
		  sz=out_size;
	  }

	  if (myfilex.is_open())
              {
	  		      int tot_errors=0;
	  		      double rel_error;
	  		      printf("Layer %d validation results:\n",l_n);
	  		      for (int i=0;i<sz;i++)
	  		      {
	  				      if (i<(rows-2*out_pad_h)*(cols-2*out_pad_h)*out_ch)
	  				      {
	  					      if (check_error_threshold((double)out[i], (double)cnn_out[i], rel_error)){
							      
	  							      tot_errors++;
	  							      myfilex<<"Mismatch "<<tot_errors<<" (index "<<i<<"): conv_sw|conv_hw     "<<
	  								      cnn_out[i]<<"|"<<out[i]<<"\n";
	  					      }
	  					      else
	  					      {
	  						      myfilex<<"Match (index "<<i<<"): conv_sw|conv_hw     "<<
	  							      cnn_out[i]<<"|"<<out[i]<<"\n";
	  					      }
	  				      }
	  		      }
		      
	  		      if (tot_errors>0)
	  			      std::cout<<"Total amount of mismatches in convolutional layer "<<l_n<<":"<<tot_errors<<"\n \n";
	  		      else
	  			      std::cout<<"Convolutional layer "<<l_n<<" validated \n \n";
	      }
    
              else std::cout << "Unable to open file";

	      myfilex.close();	
}

void reshape_weights(float*w_pv,float*W,int in_ch, int out_ch,int k_size)
{

	for (int j=0;j<out_ch;j++)
		for (int i=0; i<in_ch;i++)
			for (int k=0;k<k_size;k++)
			{
				w_pv[(i+j*in_ch)*k_size+k]=W[(i*out_ch+j)*k_size+k];
			}
}


void conv_pvt(int l_n,float*layer_in,float*out,float *W,float* bias,int in_ch,int out_ch,int out_size,int in_cols,int in_rows,int out_cols,int out_rows,int in_pad_h,int in_pad_w,int out_pad_h,int out_pad_w,int W_size,int W_cols,int W_rows,int stride_h,int stride_w,int dilation_h,int dilation_w, int batch_size,int pool_out,int pool_in)
{ 
	
	float* w_pv=new float[W_size];
	int k_size=W_cols*W_rows;
	
	//weights matrix reshape 

	reshape_weights(w_pv,W,in_ch,out_ch,k_size);

	//remove padding from input stored in the zero-layer of the CNN 

	if (l_n==1)
		{
			std::cout<<"reshape"<<std::endl;
			reshape_input(layer_in,in_rows,in_cols,in_ch,1,1,pool_in,pool_out);
		}

	//call to the accelerator programmer's view

	sw_conv_layer(layer_in,in_ch,out_rows-2*in_pad_h,out_cols-2*in_pad_w,W_rows,W_cols,
		      in_pad_h,in_pad_w,stride_h,stride_w,dilation_h,dilation_w,out_ch,w_pv,
		      bias,out,1,pool_out,batch_size);
	
}



void run_pv_conv(mojo::network* cnn,int layer)//float*in_hw,float*out)
{

	conv_pvt(layer,cnn->layer_sets[layer-1]->node.x,cnn->layer_sets[layer]->node.x,cnn->W[layer-1]->x,cnn->layer_sets[layer]->bias.x,cnn->layer_sets[layer-1]->node.chans,cnn->layer_sets[layer]->node.chans,cnn->layer_sets[layer]->node.get_size(),cnn->layer_sets[layer-1]->node.cols,cnn->layer_sets[layer-1]->node.rows,cnn->layer_sets[layer]->node.cols,cnn->layer_sets[layer]->node.rows,1,1,cnn->layer_sets[layer]->do_pad,cnn->layer_sets[layer]->do_pad,cnn->W[layer-1]->get_size(),cnn->W[layer-1]->cols,cnn->W[layer-1]->rows,1,1,1,1,1,cnn->layer_sets[layer]->do_pool,cnn->layer_sets[layer-1]->do_pool);

}

