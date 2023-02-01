// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "espacc_config.h"
#include "espacc.h"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fstream>
#include <iostream>
#include <vector>

int main(int argc, char **argv) {

    printf("****start*****\n");

    int nbursts = /* <<--tb-inputs-->> */;
    int size_in = nbursts * SIZE_IN_CHUNK;
    int size_out = nbursts * SIZE_OUT_CHUNK;

    dma_word_t *in=(dma_word_t*) malloc(size_in * sizeof(dma_word_t));
    word_t *inbuff= (word_t*) malloc(size_in * VALUES_PER_WORD * sizeof(word_t));
    dma_word_t *out= (dma_word_t*) malloc(size_out * sizeof(dma_word_t));
    word_t *outbuff_gold= (word_t*) malloc(size_out * VALUES_PER_WORD * sizeof(word_t));
    dma_info_t load;
    dma_info_t store;

    if (in == NULL || out == NULL)
    {
    	printf("null operator...FAIL");
    	exit(1);
    }

    // Prepare input data

    //load input data from text file
    std::ifstream fin("tb_data/tb_input_features.dat");
    //load predictions from text file
    std::ifstream fpr("tb_data/tb_output_predictions_fixed.dat");

    std::string iline;
    std::string pline;
    int e = 0;

#ifdef RTL_SIM
    std::string RESULTS_LOG = "tb_data/rtl_cosim_results.log";
#else
    std::string RESULTS_LOG = "tb_data/csim_results.log";
#endif
    std::cout << "INFO: save inference results to file: " << RESULTS_LOG << std::endl;
    std::ofstream results;
    results.open(RESULTS_LOG);

    if (!fin.is_open() || !fpr.is_open()) {
	printf("cannot open file... FAIL");
    	exit(1);
    }

    std::ofstream fout;
    fout.open("tb_output_data.dat");

    std::vector<float> in_vector;
    std::vector<float> pr;

    while ( std::getline(fin,iline) && std::getline (fpr,pline) ) {
	e++;
	char* cstr=const_cast<char*>(iline.c_str());
	char* current;

	current=strtok(cstr," ");
	while(current!=NULL) {
	    in_vector.push_back(atof(current));
	    current=strtok(NULL," ");
	}
	cstr=const_cast<char*>(pline.c_str());

	current=strtok(cstr," ");
	while(current!=NULL) {
	    pr.push_back(atof(current));
	    current=strtok(NULL," ");
	}
    }

    unsigned k = 0;
    for(unsigned i = 0; i < size_in; i++) {
	for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    in[i].word[j] = (word_t) (in_vector[k++]);
	}
    }

    for(unsigned i = 0; i < size_out; i++) {
	for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
	    out[i].word[j] = (word_t) 3.3;
	}
    }

    // Call the TOP function
    top(out, in, nbursts, load, store);

    // Validate
    std::cout << "Results" << std::endl;
    fout << "Result" << std::endl;
    unsigned errors = 0;
    for(int l = 0; l < nbursts; l++) {
	k = 0;
	for(int i = 0; i < SIZE_OUT_CHUNK; i++) {
	    for(unsigned j = 0; j < VALUES_PER_WORD; j++) {
		if (i * VALUES_PER_WORD + j < SIZE_OUT_CHUNK_DATA) {
		    word_t out_int =
			out[l * SIZE_OUT_CHUNK + i].word[j];

		    fout << out_int << " ";
		    results << out_int << " ";
		    std::cout << out_int << " ";

		    word_t tolerance = ((word_t) 0.05) * out_int;
		    word_t error = (word_t)
			    abs((float) ((word_t) pr[k + l * SIZE_OUT_CHUNK_DATA] - out_int));

		    if (error > tolerance) {
			    errors++;
			    std::cout << "<-error(expected "
				      << (word_t) pr[k + l * SIZE_OUT_CHUNK_DATA] << ")";
		    }

		    k++;
		}
	    }
	}
	std::cout << "\n";
	fout << std::endl;
	results << std::endl;
	std::cout << std::endl;
    }

    if (errors)
	std::cout << "Test FAILED with " << errors << " errors." << std::endl;
    else
	std::cout << "Test PASSED." << std::endl;

    // Free memory

    free(in);
    free(inbuff);
    free(out);
    free(outbuff_gold);

    return 0;
}
