#include "reshape_output.hpp"

void validate_conv(int l_n,float* out,float* Gold,int out_rows, int out_cols,int out_pad_h,int out_ch,int pool_out,int out_size)
{

	int cnn_out_size=(out_cols-2*out_pad_h) * (out_rows-2*out_pad_h) * out_ch;
        float* cnn_out=new float[cnn_out_size-1];

	reshape_output(cnn_out,Gold,pool_out,out_rows,out_cols,out_pad_h,out_pad_h,out_ch);

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


void validate_gemm(int l_n,float* out,float* out_gold,int wr)
{
     printf("Layer %d validation results: \n",l_n);

     std::ofstream myfilex;
     if (l_n==5)
             myfilex.open ("res5.txt");
     else if (l_n==6)
             myfilex.open ("res6.txt");

     if (myfilex.is_open())
     {
	     int tot_errors=0;
	     double rel_error=0.1;
             for (int i=0;i<wr;i++)
             {
                     if (check_error_threshold((double)out[i],(double)out_gold[i], rel_error)){
                             tot_errors++;
                             myfilex<<"Mismatch "<<tot_errors<<" (index "<<i<<"): ref|gemm_pv     "<<out_gold[i]<<"|"<<out[i]<<std::endl;
                     }
                     else
                     {
                             myfilex<<"Match (index "<<i<<"): ref|gemm_pv     "<<out_gold[i]<<"|"<<out[i]<<std::endl;
                     }
             }

             if (tot_errors>0)
                     std::cout<<"Total amount of mismatches :"<<tot_errors<<std::endl<<std::endl;
             else
                     std::cout<<"Fully-connected layer "<<l_n<<" validated "<<std::endl<<std::endl;
     }

     else std::cout<< " Unable to open the file";

     myfilex.close();
}
