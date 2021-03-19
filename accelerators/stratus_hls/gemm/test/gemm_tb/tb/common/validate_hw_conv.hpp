
void validate_hw_conv(int l_n,float* out,float* cnn_out,int out_rows, int out_cols,int out_pad_h,int out_ch,int pool_out,int out_size)
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


