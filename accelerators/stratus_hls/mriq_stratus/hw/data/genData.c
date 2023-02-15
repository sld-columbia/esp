// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

/* argument list: numX numK
 * e.g. $./genData 4 16
 */


#include <stdlib.h>
#include <stdio.h>

#include "../../common/helper.h"



#define PI   3.1415926535897932384626433832795029f
#define PIx2 6.2831853071795864769252867665590058f


int main (int argc, char **argv) {

  if(argc<=1) {
    printf("Please specify 2 arguments in the following order:\n \
 1. numX\n \
 2. numK\n");
    exit(1);
  } 

  // read data out from original data file provided by Parboil benchmark.

  // input file provided by parboil benchmark
 char *in_Parboil = "32_32_32_dataset.bin";

  printf("*** Reading data from %s ***\n", in_Parboil);

  int numX, numK;               /* Number of X and K values */
  float *kx, *ky, *kz;          /* K trajectory (3D vectors) */
  float *x, *y, *z;             /* X coordinates (3D vectors) */
  float *phiR, *phiI;           /* Phi values (complex) */
  float *Qr, *Qi;               /* Q signal (complex) */


  // read out data into different variables.
  inputData(in_Parboil, &numK, &numX,
            &kx, &ky, &kz,
            &x,  &y,  &z,
            &phiR, &phiI);

  printf("original numK = %d\n", numK);
  printf("original numX = %d\n", numX);
  

  // set the numX and numK you want for new files.
  numX = atoi(argv[1]);
  numK = atoi(argv[2]); 

  char inputName[100];
  char goldenName[100];
  sprintf(inputName, "test_32_x%d_k%d.bin", numX, numK);
  sprintf(goldenName, "test_32_x%d_k%d.out", numX, numK);

  printf("*** Writing data into %s and %s ***\n", inputName, goldenName);

  printf("new numK = %d\n", numK);
  printf("new numX = %d\n", numX);

  // input file extracted from original parboil benchmark
  // with new numX and numK


  FILE* fid = fopen(inputName, "wr");
  if (fid == NULL)
    {
      fprintf(stderr, "Cannot open file\n");
      exit(-1);
    }

  // write numK, numX to the bin file
  int ret;
  ret = fwrite(&numK,sizeof(int),1, fid);  
  ret = fwrite(&numX,sizeof(int),1, fid);  


  // write kx, ky, kz to the bin file
  ret = fwrite(kx,sizeof(float),numK, fid);
  if(ret!=numK){
    printf("not writing correctly!\n");
  }
  ret = fwrite(ky,sizeof(float),numK, fid);
  if(ret!=numK){
    printf("not writing correctly!\n");
  }
  ret = fwrite(kz,sizeof(float),numK, fid);
  if(ret!=numK){
    printf("not writing correctly!\n");
  }

  // writing x, y, z to the bin file
  ret = fwrite(x,sizeof(float),numX, fid);
  if(ret!=numX){
    printf("not writing correctly!\n");
  }
  ret = fwrite(y,sizeof(float),numX, fid);
  if(ret!=numX){
    printf("not writing correctly!\n");
  }
  ret = fwrite(z,sizeof(float),numX, fid);
  if(ret!=numX){
    printf("not writing correctly!\n");
  }
  // write phiR and phiI
  ret = fwrite(phiR,sizeof(float),numK, fid);
  if(ret!=numK){
    printf("not writing correctly!\n");
  }
  ret = fwrite(phiI,sizeof(float),numK, fid);
  if(ret!=numK){
    printf("not writing correctly!\n");
  }

  fclose(fid);

  

  // compute golden output

  createDataStructsforCompute(numX, &Qr, &Qi);

  ComputeQ(numK, numX,
	   kx,
	   ky,
	   kz,
	   x,
	   y,
	   z,
	   phiR,
	   phiI,
	   Qr,Qi);

  FILE *fout = fopen(goldenName, "wr");
  if(fout == NULL){
    printf("can't open file");
  }
  // write numX to the golden output file
  ret = fwrite(&numX, sizeof(float), 1, fout);

  if(ret!= 1){
    printf("not writing correctly!\n");
  }

  // write Qr to the golden output file
  ret = fwrite(Qr, sizeof(float), numX, fout);
  if(ret!=numX){
    printf("not writing correctly!\n");
  }

  // write Qi to the golden output file
  ret = fwrite(Qi, sizeof(float), numX, fout);
  if(ret!=numX){
    printf("not writing correctly!\n");
  }

  fclose(fout);


  // free memory
  free(Qr);
  free(Qi);
  free(x);
  free(y);
  free(z);
  free(kx);
  free(ky);
  free(kz);
  free(phiR);
  free(phiI);

  return 0;

}
