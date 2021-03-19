void validate_hw_gemm(int l_n,float* out,float* layer_bias,float* out_gold,int wr,int size_out,int relu)
{

	std::ofstream myfilex;
	if (l_n==5)
		myfilex.open ("res5.txt");
	else if (l_n==6)
		myfilex.open ("res6.txt");

	for (int i = 0; i < wr; i++) {
		if (relu) {
			if (out[i] + layer_bias[i] < 0)
				out[i] = 0;
			else
				out[i] += layer_bias[i];
		}
	}
	printf("\n");
// Softmax for layer without relu
	if (!relu)
	{
		for (int i = 0; i < wr; i++) {
			float max = out[0];
			for (int j = 1; j < wr; j++)
				if (out[j] > max)
					max = out[j];

			float denom = 0;
			for (int j = 0; j <wr; j++)
				denom += exp(out[j] - max);

			out[i] = exp(out[i] - max) / denom;
//                      printf("%f ",out[i]);
		}
	}

//Validate Layer

	std::cout << "Validate target layer: "<<l_n<< std::endl;


// Check for mismatches
	int tot_errors=0;
	double rel_error;

	if (myfilex.is_open())
	{
		printf("Layer %d validation results:\n",l_n);
		for (int i=0;i<size_out;i++)
		{
			if (check_error_threshold(out[i], out_gold[i], rel_error)){

				tot_errors++;
				myfilex<<"Mismatch "<<tot_errors<<" (index "<<i<<"): gemm_sw|gemm_hw   "<<out_gold[i]<<"|"<<out[i]<<"\n";
				}
			else
				{
					myfilex<<"Match (index "<<i<<")\
: gemm_sw|gemm_hw   "<<out_gold[i]<<"|"<<out[i]<<"\n";
				}
		}

	if (tot_errors>0)
		std::cout<<"Total amount of mismatches in fully connected layer "<<l_n<<":"<<tot_errors<<"\n \n";
	else
		std::cout<<"Fully connected layer "<<l_n<<" validated \n \n";
	}
	else std::cout << "Unable to open file";

	myfilex.close();
}





