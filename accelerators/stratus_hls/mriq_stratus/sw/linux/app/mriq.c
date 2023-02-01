// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
#include "libesp.h"
#include "cfg.h"
#include "../../../common/utils.h"     // init_parameters() and validate_buffer()
#include "../../../common/sw_exec.h"   // sw_exec()
#include "../../../common/init_buff.h" // init_buffer()
#include <fixed_point.h>

#include <math.h> // for fabs function


#define fx2float fixed32_to_float
#define float2fx float_to_fixed32
#define FX_IL 12


static unsigned in_words_adj;
static unsigned out_words_adj;
static unsigned in_len;
static unsigned out_len;
static unsigned in_size;
static unsigned out_size;
static unsigned out_offset;
static unsigned mem_size;


/* User-defined code */
void file2be(const char* in_file_name, const char* out_file_name)
{

  FILE* in_file = fopen(in_file_name, "r");
  FILE* out_file = fopen(out_file_name, "w");

  uint8_t rd_data[4];
  int i;

  while(fread(rd_data, sizeof(uint8_t), 4, in_file) == 4){
    for (i = 3; i>= 0; i--)
      fwrite(&rd_data[i], sizeof(uint8_t), 1, out_file);
  }

  fclose(in_file);
  fclose(out_file);
}



static int validate_buf(token_t *out, float *gold)
{
    float *out_fp;
    int ret;

    out_fp = malloc(out_len * sizeof(float));

    for (int i = 0; i < out_len; i++) {
      out_fp[i] = fx2float(out[i], FX_IL);
    }

    ret = validate_buffer(out_fp, gold, out_len);

    free(out_fp);
    return ret;
}




/* User-defined code */

static void init_buf(token_t *in, float *in_fp, float *gold, 
		      const char* inputFile, 
		      const char* goldFile)
{


#ifdef __sparc

  const char* be_inputFile = "be_inputFile.bin";
  const char* be_goldFile = "be_goldFile.bin";

  file2be(inputFile, be_inputFile);
  file2be(goldFile, be_goldFile);

  init_buffer(in_fp, gold, be_inputFile, be_goldFile, 
	      batch_size_x, num_batch_x,
	      batch_size_k, num_batch_k);

#else


  init_buffer(in_fp, gold, inputFile, goldFile, 
	      batch_size_x, num_batch_x,
	      batch_size_k, num_batch_k);
#endif

  for(int i=0; i < in_len; i++) {
    in[i] = float2fx(in_fp[i], FX_IL);
  }

}

 


int main(int argc, char **argv)
{
        if (argc < 3) {
	  printf("please pass 3 arguments: inputName, goldName, run_sw\n");
	  exit(1);
	}

	int errors;
	float *gold;
	token_t *buf;
	float *in_fp;

	const char* inputFile = argv[1];
	const char* goldFile  = argv[2];
	int run_sw = atoi(argv[3]); 

	//	printf("\n before init parameters \n");

	init_parameters(batch_size_x, num_batch_x, 
			batch_size_k, num_batch_k,
			&in_words_adj, &out_words_adj,
			&in_len, &out_len,
			&in_size, &out_size,
			&out_offset,
			&mem_size,
			DMA_WORD_PER_BEAT(sizeof(token_t)));

	buf = (token_t *) esp_alloc(mem_size);

	cfg_000[0].hw_buf = buf;
    
	gold = malloc(out_len * sizeof(float));

	in_fp = malloc(in_len * sizeof(float));
	
	printf("\n====== %s ======\n\n", cfg_000[0].devname);
	/* <<--print-params-->> */
	printf("  .num_batch_k = %d\n", num_batch_k);
	printf("  .batch_size_k = %d\n", batch_size_k);
	printf("  .num_batch_x = %d\n", num_batch_x);
	printf("  .batch_size_x = %d\n", batch_size_x);

	init_buf(buf, in_fp, gold, inputFile, goldFile);

	printf("\n  ** START HW TESTING **\n");

	esp_run(cfg_000, NACC);

	printf("\n  ** DONE **\n");

	errors = validate_buf(&buf[out_offset], gold);

	if (!errors)
		printf("+ HW Test PASSED\n");
	else
		printf("+ HW Test FAILED\n");


	if(run_sw) {
	  
	  float *out_sw = malloc(out_len * sizeof(float));

	  sw_exec(out_sw, in_fp, 
		  batch_size_x, num_batch_x,
		  batch_size_k, num_batch_k);

	  int ret;

	  ret = validate_buffer(out_sw, gold, out_len);

	  if (ret)
	    printf("+ SW Test FAILED!\n");
	  else
	    printf("+ SW Test PASSED!\n");

	  free(out_sw);

	}



	free(gold);

	free(in_fp);

	esp_free(buf);


	printf("\n====== %s ======\n\n", cfg_000[0].devname);


	return errors;

}
