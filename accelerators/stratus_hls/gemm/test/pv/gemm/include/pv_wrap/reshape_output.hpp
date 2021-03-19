
void reshape_output(float* cnn_out,float* Gold,int pool_out,int out_rows,int out_cols,int out_pad_h,int out_pad_w,int out_ch)
{
	if (out_pad_h>0)
	{
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
		for (int i=0;i<=out_ch*out_rows*out_cols;i++)
		{
			cnn_out[i]=Gold[i];           //golden output remains untouched
		}
	}
}
