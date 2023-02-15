// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>

#include "../../common/helper.h"
#include <math.h>



/* argument list: 
 * Please specify 6 arguments in the following order:\
 * 1. numX\
 * 2. numK\
 * 3. batch_size_k\
 * 4. num_batch_k\
 * 5. batch_size_x\
 * 6. num_batch_x
 * e.g. $./wrt_bmData 64 64 16 4 16 4
 */


void write_in(FILE *fp, unsigned len, float *val, unsigned batch, unsigned base_in) {
  unsigned base = batch * len;

  // len is the batch_size_x or batch_size_k;
  
  for (int i = 0; i < len; i++)
    
    fprintf(fp, "in[%d] = float2fx((float) %f, FX_IL);\n", base_in + i, val[base+i]);
  
}

void write_gold(FILE *fp, unsigned len, float *val, unsigned batch, unsigned base_in) {
  unsigned base = batch * len;

  // len is the batch_size_x or batch_size_k;
  
  for (int i = 0; i < len; i++)
    
    fprintf(fp, "gold[%d] = %f;\n", base_in + i, val[base+i]);
  
}


int main(int argc, char **argv) {
  if(argc<=1) {
    printf("Please specify 6 arguments in the following order:\n \
1. numX\n \
2. numK\n \
3. batch_size_k\n \
4. num_batch_k\n \
5. batch_size_x\n \
6. num_batch_x\n");
    exit(1);
  }

  int numX, numK;
  unsigned batch_size_k;
  unsigned num_batch_k;
  unsigned batch_size_x;
  unsigned num_batch_x;


  numX = atoi(argv[1]);
  numK = atoi(argv[2]);
  batch_size_k = atoi(argv[3]);
  num_batch_k = atoi(argv[4]);
  batch_size_x = atoi(argv[5]);
  num_batch_x = atoi(argv[6]);

  char inputName[100];
  sprintf(inputName, "test_32_x%d_k%d.bin", numX, numK);


  char bm_name[100];// = "test_32_x64_k64_bm.h";
  sprintf(bm_name, "test_32_x%d_k%d_bm.h", numX, numK);



  float *kx, *ky, *kz;          /* K trajectory (3D vectors) */
  float *x, *y, *z;             /* X coordinates (3D vectors) */
  float *phiR, *phiI;           /* Phi values (complex) */
  float *Qr, *Qi;

  inputData(inputName, &numK, &numX,
	    &kx, &ky, &kz,
	    &x,  &y,  &z,
	    &phiR, &phiI);

  printf("numK is %d, numX is %d\n", numK, numX);

  createDataStructsforCompute(numX, &Qr, &Qi);

  ComputeQ(numK, numX,\
	   kx,\
	   ky,\
	   kz,\
	   x,\
	   y,\
	   z,\
	   phiR,\
	   phiI,\
	   Qr,Qi);

  FILE *bmp;
  bmp = fopen(bm_name, "w");
  int base_in;

  // write input to file
  for (int b = 0; b < num_batch_k; b++) {

    base_in = 5 * b * batch_size_k;
    write_in(bmp, batch_size_k, kx, b, base_in);

    base_in += batch_size_k;
    write_in(bmp, batch_size_k, ky, b, base_in);

    base_in += batch_size_k;
    write_in(bmp, batch_size_k, kz, b, base_in);


    base_in += batch_size_k;
    write_in(bmp, batch_size_k, phiR, b, base_in);


    base_in += batch_size_k;
    write_in(bmp, batch_size_k, phiI, b, base_in);
  }


  for (int b = 0; b < num_batch_x; b++) {
    base_in = 5 * numK + 3 * b * batch_size_x;
    write_in(bmp, batch_size_x, x, b, base_in);

    base_in += batch_size_x;
    write_in(bmp, batch_size_x, y, b, base_in);

    base_in += batch_size_x;
    write_in(bmp, batch_size_x, z, b, base_in);
  }

  // write golden output to file
  for (int b = 0; b < num_batch_x; b++) {
    base_in = 2 * b * batch_size_x;
    write_gold(bmp, batch_size_x, Qr, b, base_in);

    base_in += batch_size_x;
    write_gold(bmp, batch_size_x, Qi, b, base_in);
  }

  free(kx);
  free(ky);
  free(kz);
  free(x);
  free(y);
  free(z);
  free(phiR);
  free(phiI);
  free(Qr);
  free(Qi);
  fclose(bmp);

  return 0;

}
