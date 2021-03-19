
void reshape_weights(float*w_pv,float*W,int in_ch, int out_ch,int k_size)
{

        for (int j=0;j<out_ch;j++)
                for (int i=0; i<in_ch;i++)
                        for (int k=0;k<k_size;k++)
                        {
                                w_pv[(i+j*in_ch)*k_size+k]=W[(i*out_ch+j)*k_size+k];
                        }
}
