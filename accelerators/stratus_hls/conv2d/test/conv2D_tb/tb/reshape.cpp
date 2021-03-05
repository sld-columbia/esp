#include <stdio.h>
#include <stdlib.h>

void reshape(int in_ch,int out_ch,float* out,int out_size,int layer_in_cols,int layer_in_rows,int layer_out_cols,int layer_out_rows,int in_pad_h,int in_pad_w,int out_pad_h,int out_pad_w, int pool_in)
{

        //remove padding from input if present

        // int cnn_size=(layer_in_cols-2*out_pad_w) * (layer_in_rows-2*out_pad_h) * in_ch;
        // float* cnn=new float[cnn_size-1];
        if (out_pad_h>0)
        {

             //input reshape

             if (pool_in==1)                     //input reshape if the input is padded and pooling has been perfomed in the previous layer executed in software
             {
                     int rows=(layer_in_rows+2*in_pad_h)/2;
                     int cols=(layer_in_cols+2*in_pad_h)/2;
                     for (int k=0;k<in_ch;k++)
                             for (int j = 1; j < rows-in_pad_h ; j++)     // intput h
                                     for (int i = 1; i < cols-in_pad_w ; i++) // intput w
                                     {
                                             int index_out = k*rows*cols+j * cols + i;
                                             int ind_out=k*(rows-2*in_pad_h)*(cols-2*in_pad_w)+(j-1)*(cols-2*in_pad_w)+(i-1);
					     out[ind_out] =out[index_out];
				     }
	     }
	     else                              //input reshape if input padded
	     {
		     for (int k=0;k<in_ch;k++)
			     for (int j = 1; j < layer_in_cols-in_pad_h ; j++)     // intput h
				     for (int i = 1; i < layer_in_rows-in_pad_w ; i++) // intput w
					     int index_out = k*layer_in_rows*layer_in_cols+j * layer_in_cols + i;
		     int ind_out=k*(layer_in_rows-2*in_pad_h)*(layer_in_cols-2*in_pad_w)+(j-1)*(layer_in_cols-2*in_pad_w)+(i-1);
		     out[ind_out] =out[index_out];
	     }
	}
	else
	{
		//input reshape
		if (pool_in==1)               //same input reshape as above
		{
			int rows=(layer_in_rows+2*in_pad_h)/2;
			int cols=(layer_in_cols+2*in_pad_h)/2;
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < rows-in_pad_h ; j++)     // intput h
					for (int i = 1; i < cols-in_pad_w ; i++) // intput w
					{
						int index_out = k*rows*cols+j * cols + i;
						int ind_out=k*(rows-2*in_pad_h)*(cols-2*in_pad_w)+(j-1)*(cols-2*in_pad_w)+(i-1);
						out[ind_out] =out[index_out];
					}

		}
		else
		{
			for (int k=0;k<in_ch;k++)
				for (int j = 1; j < layer_in_cols-in_pad_h ; j++)     // intput h
					for (int i = 1; i < layer_in_rows-in_pad_w ; i++) // intput w
					{
						int index_out = k*layer_in_rows*layer_in_cols+j * layer_in_cols + i;
						int ind_out=k*(layer_in_rows-2*in_pad_h)*(layer_in_cols-2*in_pad_w)+(j-1)*(layer_in_cols-2*in_pad_w)+(i-1);
						out[ind_out] =out[index_out];
					}
		}
	}
}
