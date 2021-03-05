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


//int cnn_size=(in_cols-2*out_pad_w) * (in_rows-2*out_pad_h) * in_ch;
// float* cnn;


// //int cnn_out_size=(out_cols-2*out_pad_w) * (out_rows-2*out_pad_h) * out_ch;
// float* cnn_out;



void reshape_input(float* cnn,float*layer_in_soft,int in_rows,int in_cols,int in_ch,float* cnn_out,float* Gold,int out_rows,int out_cols,int out_ch,int in_pad_h,int in_pad_w,int out_pad_h,int out_pad_w,int pool_in,int pool_out)
{
	if (out_pad_h>0)
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
						cnn[ind_out] =layer_in_soft[index_out];
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
						cnn[ind_out] =layer_in_soft[index_out];
					}
		}

		//output reshape

		if (pool_out==1)                 //Golden output reshape if the layer performs both pooling and padding

		{
			for (int k=0;k<out_ch;k++)
				for (int j = 1; j < (out_cols+2*out_pad_h)/2-out_pad_h ; j++)     
					for (int i = 1; i < (out_rows+2*out_pad_w)/2-out_pad_w ; i++)
					{
						int rows=(out_rows+2*out_pad_h)/2;
						int cols=(out_cols+2*out_pad_h)/2;
						int index_out = k*rows*cols+j *cols + i;
						int ind_out=k*(rows-2*out_pad_h)*(cols-2*out_pad_w)+(j-1)*(cols-2*out_pad_w)+(i-1);
						cnn_out[ind_out] =Gold[index_out];
					}
		
		}
		else                             //Golden output reshape if hte layer performs both pooling and padding 
		{
			for (int k=0;k<out_ch;k++)
				for (int j = 1; j < out_cols-out_pad_h ; j++)     
					for (int i = 1; i < out_rows-out_pad_w ; i++) 
					{
						int index_out = k*out_rows*out_cols+j * out_cols + i;
						int ind_out=k*(out_rows-2*out_pad_h)*(out_cols-2*out_pad_w)+(j-1)*(out_cols-2*out_pad_w)+(i-1);
						cnn_out[ind_out] =Gold[index_out];
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
						cnn[ind_out] =layer_in_soft[index_out];
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
						cnn[ind_out] =layer_in_soft[index_out];
					}
		}

		for (int i=0;i<=out_ch*out_rows*out_cols;i++)
		{
			cnn_out[i]=Gold[i];           //golden output remains untouched
		}             
	}
}


void validate(int l_n,float* out,float* cnn_out,int out_rows, int out_cols,int out_pad_h,int out_ch,int pool_out,int out_size)
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
	  		      double rel_error=0.1;
	  		      printf("Layer %d validation results:\n",l_n);
	  		      for (int i=0;i<sz;i++)
	  		      {
	  				      if (i<(rows-2)*(cols-2)*out_ch)
	  				      {
	  					      if (check_error_threshold((double)out[i], (double)cnn_out[i], rel_error)){
							      
	  							      tot_errors++;
	  							      myfilex<<"Mismatch "<<tot_errors<<" (index "<<i<<"): ref|conv_pv     "<<
	  								      cnn_out[i]<<"|"<<out[i]<<"\n";
	  					      }
	  					      else
	  					      {
	  						      myfilex<<"Match (index "<<i<<"): ref|conv_pv     "<<
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


void conv_pvt(int l_n,int prev_soft,float*layer_in_sw,float*layer_in_hw,float*out,float *out_gold,float *W,float* bias,int in_ch,int out_ch,int out_size,int in_cols,int in_rows,int out_cols,int out_rows,int in_pad_h,int in_pad_w,int out_pad_h,int out_pad_w,int W_size,int W_cols,int W_rows,int stride_h,int stride_w,int dilation_h,int dilation_w, int batch_size,int pool_out,int pool_in)
{
	
	float* w_pv=new float[W_size];
	int k_size=W_cols*W_rows;
	
	//weights matrix reshape 

	reshape_weights(w_pv,W,in_ch,out_ch,k_size);

	//remove padding from input if present

	int cnn_size=(in_cols-2*out_pad_w) * (in_rows-2*out_pad_h) * in_ch;
	float* cnn=new float[cnn_size-1];

	int cnn_out_size=(out_cols-2*out_pad_w) * (out_rows-2*out_pad_h) * out_ch;
	float* cnn_out=new float[cnn_out_size-1];

	reshape_input(cnn,layer_in_sw,in_rows,in_cols,in_ch,cnn_out,out_gold,out_rows,
		out_cols,out_ch,in_pad_h,in_pad_w,out_pad_h,out_pad_w,pool_in,pool_out);

	//select input between: reshaped input from dwarf model (cnn) and outputs of previous 
        //layer executed by the accelerator's programmer's view (layer_in_hw)

	int in_size=(in_cols-2*out_pad_w) * (in_rows-2*out_pad_h) * in_ch;
	float* cnn_in=new float[in_size-1];

	if (prev_soft==1)
		cnn_in=cnn;
	else
		cnn_in=layer_in_hw;

	//Call to Conv2d programmer's view 

	sw_conv_layer(cnn_in,in_ch,out_rows-2*in_pad_h,out_cols-2*in_pad_w,W_rows,W_cols,
		      in_pad_h,in_pad_w,stride_h,stride_w,dilation_h,dilation_w,out_ch,w_pv,
		      bias,out,1,pool_out,batch_size);
	
	//validate the results

	validate(l_n,out,cnn_out,out_rows,out_cols,out_pad_h,out_ch,pool_out,out_size);

}



void run_pv(mojo::network* cnn,int prev_soft,int layer,float*in_hw,float*out)
{

	conv_pvt(layer,prev_soft,cnn->layer_sets[layer-1]->node.x,in_hw,out,cnn->layer_sets[layer]->node.x,cnn->W[layer-1]->x,cnn->layer_sets[layer]->bias.x,cnn->layer_sets[layer-1]->node.chans,cnn->layer_sets[layer]->node.chans,cnn->layer_sets[layer]->node.get_size(),cnn->layer_sets[layer-1]->node.cols,cnn->layer_sets[layer-1]->node.rows,cnn->layer_sets[layer]->node.cols,cnn->layer_sets[layer]->node.rows,1,1,cnn->layer_sets[layer]->do_pad,cnn->layer_sets[layer]->do_pad,cnn->W[layer-1]->get_size(),cnn->W[layer-1]->cols,cnn->W[layer-1]->rows,1,1,1,1,1,cnn->layer_sets[layer]->do_pool,cnn->layer_sets[layer-1]->do_pool);

}

