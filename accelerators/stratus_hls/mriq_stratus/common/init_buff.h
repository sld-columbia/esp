// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "helper.h"

// init_buffer function can't be used in baremetal app 




void init_buffer(float *in, float *gold, 
		 const char* inputFile, 
		 const char* goldFile,
		 int32_t batch_size_x, int32_t num_batch_x,
		 int32_t batch_size_k, int32_t num_batch_k)
{

  int numX_bm, numK_bm;
  float *kx, *ky, *kz, *x, *y, *z, *phiR, *phiI;

  inputData(inputFile, 
	      &numK_bm, 
	      &numX_bm, 
	      &kx, &ky, &kz, 
	      &x, &y, &z, 
	      &phiR, &phiI);


  int i, j;
  int offset_idx = 0;
  int idx_single;


  for(i=0; i < num_batch_k; i++) {

      idx_single = i * batch_size_k;

      
      for(j=0; j < batch_size_k; j++)  
	in[offset_idx + j] = kx[idx_single + j];

      offset_idx += batch_size_k; // 1 

      for(j=0; j < batch_size_k; j++)
	in[offset_idx + j] = ky[idx_single + j];
      
      offset_idx += batch_size_k; // 2

      for(j=0; j < batch_size_k; j++)
	in[offset_idx + j] = kz[idx_single + j];
            
      offset_idx += batch_size_k; // 3

      for(j=0; j < batch_size_k; j++)
	in[offset_idx + j] = phiR[idx_single + j];
      
      offset_idx += batch_size_k; // 4

      for(j=0; j < batch_size_k; j++)
	in[offset_idx + j] = phiI[idx_single + j];
      
      offset_idx += batch_size_k; // 5
  }
  

  for(i = 0; i < num_batch_x; i++) {
      idx_single = i * batch_size_x;

      for(j=0; j < batch_size_x; j++)
	in[offset_idx + j] = x[idx_single + j];

      offset_idx += batch_size_x; // 1

      for(j=0; j < batch_size_x; j++)
	in[offset_idx + j] = y[idx_single + j];

      offset_idx += batch_size_x; // 2

      for(j=0; j < batch_size_x; j++)
	in[offset_idx + j] = z[idx_single + j];

      offset_idx += batch_size_x; // 3
  }


      // read golden output from files and store to gold buf 

  float *Qr, *Qi;
  outputData(goldFile, &Qr, &Qi, &numX_bm);

  for (int b = 0; b < num_batch_x; b++) {
    unsigned base_in = 2 * b * batch_size_x;

    unsigned base = b * batch_size_x;

    for (int i = 0; i < batch_size_x; i++)
      gold[base_in + i] = Qr[base + i];

    base_in += batch_size_x;

    for (int i = 0; i < batch_size_x; i++)
      gold[base_in + i] = Qi[base + i];
    
  }


  free(x);
  free(y);
  free(z);
  free(kx);
  free(ky);
  free(kz);
  free(phiR);
  free(phiI);

  free(Qr);
  free(Qi);

}
