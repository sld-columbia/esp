// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>

#include <assert.h>

#if defined(USE_CBLAS)
#include "cblas.h"
#endif // USE_CBLAS

#include "golden.hpp"


void conv_pvt(int l_n,int previous_soft,float *Gold,float *Cnn_W,int W_size,int W_cols,int W_rows,int in_ch,int out_ch, float* out,int out_size,float* layer_in_soft,float*layer_in_hard,float* layer_out_bias,int layer_in_cols,int layer_in_rows,int layer_out_cols,int layer_out_rows,int in_pad_h,int in_pad_w,int out_pad_h,int out_pad_w,int stride_h,int stride_w,int dilation_h,int dilation_w, int relu, int batch_size,int pool_out,int pool_in)
{
	
	float* w_pv=new float[W_size];
	int k_size=W_cols*W_rows;
	
	
	//weights matrix reshape 

	for (int j=0;j<out_ch;j++)
		for (int i=0; i<in_ch;i++)
			for (int k=0;k<k_size;k++)
			{
				w_pv[(i+j*in_ch)*k_size+k]=Cnn_W[(i*out_ch+j)*k_size+k];
			}

	//remove padding from input if present

	int cnn_size=(layer_in_cols-2*out_pad_w) * (layer_in_rows-2*out_pad_h) * in_ch;
	float* cnn=new float[cnn_size-1];


	int cnn_out_size=(layer_out_cols-2*out_pad_w) * (layer_out_rows-2*out_pad_h) * out_ch;
	float* cnn_out=new float[cnn_out_size-1];

	if (out_pad_h>0)
	{
	
		//	myfilex<<"input reshape";

		if (pool_in==1)
		{
			int rows=(layer_in_rows+2*in_pad_h)/2;
			int cols=(layer_in_cols+2*in_pad_h)/2;
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < rows-in_pad_h ; j++)     // intput h
					for (int i = 1; i < cols-in_pad_w ; i++) // intput w
					{
						int index_out = k*rows*cols+j * cols + i;
						int ind_out=k*(rows-2*in_pad_h)*(cols-2*in_pad_w)+(j-1)*(cols-2*in_pad_w)+(i-1);
						cnn[ind_out] =layer_in_soft[index_out];
					}
			// std::ofstream myfile_;
			// myfile_.open("check.txt");
			// if (myfile_.is_open())
			// 	{
			// 		myfile_<<l_n<<" \n";
			// 		for (int i=0;i<200;i++)
			// 			myfile_<<" "<<cnn[i]<<" "<<layer_in[i]<<"\n";
			// 	}
				
			// myfile_.close();


	
		}
		else
		{
		for (int k=0;k<in_ch;k++)
			for (int j = 1; j < layer_in_cols-in_pad_h ; j++)     // intput h
				for (int i = 1; i < layer_in_rows-in_pad_w ; i++) // intput w
				{
					int index_out = k*layer_in_rows*layer_in_cols+j * layer_in_cols + i;
					int ind_out=k*(layer_in_rows-2*in_pad_h)*(layer_in_cols-2*in_pad_w)+(j-1)*(layer_in_cols-2*in_pad_w)+(i-1);
					cnn[ind_out] =layer_in_soft[index_out];
				}
		}

		//output reshape

		if (pool_out==1)
		{
			for (int k=0;k<out_ch;k++)
				for (int j = 1; j < (layer_out_cols+2*out_pad_h)/2-out_pad_h ; j++)     // output h
					for (int i = 1; i < (layer_out_rows+2*out_pad_w)/2-out_pad_w ; i++) // output w
					{
						int rows=(layer_out_rows+2*out_pad_h)/2;
						int cols=(layer_out_cols+2*out_pad_h)/2;
						int index_out = k*rows*cols+j *cols + i;
						int ind_out=k*(rows-2*out_pad_h)*(cols-2*out_pad_w)+(j-1)*(cols-2*out_pad_w)+(i-1);
						cnn_out[ind_out] =Gold[index_out];
					}
		
		}
		else
		{
			for (int k=0;k<out_ch;k++)
				for (int j = 1; j < layer_out_cols-out_pad_h ; j++)     // output h
					for (int i = 1; i < layer_out_rows-out_pad_w ; i++) // output w
					{
						int index_out = k*layer_out_rows*layer_out_cols+j * layer_out_cols + i;
						int ind_out=k*(layer_out_rows-2*out_pad_h)*(layer_out_cols-2*out_pad_w)+(j-1)*(layer_out_cols-2*out_pad_w)+(i-1);
						cnn_out[ind_out] =Gold[index_out];
					}
		}

	}
	else
	{
		//input reshape
		if (pool_in==1)
		{
			int rows=(layer_in_rows+2*in_pad_h)/2;
			int cols=(layer_in_cols+2*in_pad_h)/2;
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < rows-in_pad_h ; j++)     // intput h
					for (int i = 1; i < cols-in_pad_w ; i++) // intput w
					{
						int index_out = k*rows*cols+j * cols + i;
						int ind_out=k*(rows-2*in_pad_h)*(cols-2*in_pad_w)+(j-1)*(cols-2*in_pad_w)+(i-1);
						cnn[ind_out] =layer_in_soft[index_out];
					}
			// std::ofstream myfile_;
			// myfile_.open("check.txt");
			// if (myfile_.is_open())
			// 	{
			// 		myfile_<<l_n<<" \n";
			// 		for (int i=0;i<200;i++)
			// 			myfile_<<" "<<cnn[i]<<" "<<layer_in[i]<<"\n";
			// 	}
				
			// myfile_.close();


	
		}
		else
		{
		for (int k=0;k<in_ch;k++)
			for (int j = 1; j < layer_in_cols-in_pad_h ; j++)     // intput h
				for (int i = 1; i < layer_in_rows-in_pad_w ; i++) // intput w
				{
					int index_out = k*layer_in_rows*layer_in_cols+j * layer_in_cols + i;
					int ind_out=k*(layer_in_rows-2*in_pad_h)*(layer_in_cols-2*in_pad_w)+(j-1)*(layer_in_cols-2*in_pad_w)+(i-1);
					cnn[ind_out] =layer_in_soft[index_out];
				}
		}

		cnn_out=Gold;
	}


	int in_size=(layer_in_cols-2*out_pad_w) * (layer_in_rows-2*out_pad_h) * in_ch;
	float* cnn_in=new float[in_size-1];

	if (previous_soft==1)
		cnn_in=cnn;
	else
		cnn_in=layer_in_hard;

	sw_conv_layer(cnn_in,in_ch,layer_out_rows-2*in_pad_h,layer_out_cols-2*in_pad_w,W_rows,W_cols,in_pad_h,in_pad_w,stride_h,stride_w,dilation_h,dilation_w,out_ch,w_pv,layer_out_bias,out,relu,pool_out,batch_size);


	  std::ofstream myfilex;
	  if (l_n==1)
		  myfilex.open ("res1.txt");//, ios::out | ios::app | ios::binary);
	  else if (l_n==2)
		  myfilex.open ("res2.txt");//, ios::out | ios::app | ios::binary);
	  else if (l_n==3)
		  myfilex.open ("res3.txt");//, ios::out | ios::app | ios::binary);
	  else if (l_n==4)
		  myfilex.open ("res4.txt");//, ios::out | ios::app | ios::binary);

              if (myfilex.is_open())
              {
		      if (pool_out==1)
		      {
			      int rows=(layer_out_rows+2*out_pad_h)/2;
			      int cols=(layer_out_cols+2*out_pad_h)/2;
			      int tot_errors1=0;
			      double rel_error=0.1;
			      printf("Layer %d validation results:\n",l_n);
			      for (int i=0;i<rows*cols*out_ch;i++)
			      {
				      //if (check_error_threshold((double)out[i], (double)cnn_out[i], rel_error)){
					      if (i<(rows-2)*(cols-2)*out_ch)
					      {
						      if (check_error_threshold((double)out[i], (double)cnn_out[i], rel_error)){
							      
								      tot_errors1++;
								      myfilex<<"Mismatch "<<tot_errors1<<" (index "<<i<<"): ref|conv_pv     "<<
									      cnn_out[i]<<"|"<<out[i]<<"\n";
						      }
						      else
						      {
							      myfilex<<"Match (index "<<i<<"): ref|conv_pv     "<<
								      cnn_out[i]<<"|"<<out[i]<<"\n";
						      }
					      }
				     //}
			      }
		      
			      if (tot_errors1>0)
				      std::cout<<"Total amount of mismatches in convolutional layer "<<l_n<<":"<<tot_errors1<<"\n \n";
			      else
				      std::cout<<"Convolutional layer "<<l_n<<" validated \n \n";


		      }
		      else
		      {
			      int tot_errors1=0;
			      double rel_error=0.1;
			      printf("Layer %d validation results: \n",l_n);
			      for (int i=0;i<out_size;i++)
			      {
				      // if (check_error_threshold((double)out[i], (double)cnn_out[i], rel_error)){
					      if (i<(layer_out_rows-2)*(layer_out_cols-2)*out_ch)
					      {
						      if (check_error_threshold((double)out[i], (double)cnn_out[i], rel_error)){
						
							      tot_errors1++;
							      myfilex<<"Mismatch "<<tot_errors1<<" (index "<<i<<"): ref|conv_pv     "<<
								      cnn_out[i]<<"|"<<out[i]<<"\n";
						      }
						      else
						      {
							      
							      myfilex<<"Match (index "<<i<<"): ref|conv_pv     "<<
								      cnn_out[i]<<"|"<<out[i]<<"\n";
						      }
					      }
					      // }
			      }
			      if (tot_errors1>0)
				      std::cout<<"Total amount of mismatches in convolutional layer "<<l_n<<":"<<tot_errors1<<"\n \n";
			      else
				      std::cout<<"Convolutional layer "<<l_n<<" validated \n \n";
		      }

              }
              else std::cout << "Unable to open file";

	      myfilex.close();
	

}
