
void reshape_input(float* layer_in_soft,int pool_in,int in_rows,int in_cols,int in_pad_h,int in_pad_w,int in_ch)
{
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
