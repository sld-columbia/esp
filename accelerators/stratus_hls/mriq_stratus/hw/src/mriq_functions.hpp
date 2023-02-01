// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "mriq.hpp"
#include "fpdata.hpp"
#include "cynw_fixed.h"
// Optional application-specific helper functions


template <typename T>
void mriq::dma_read(T array[],  uint32_t dma_index, uint32_t dma_length)
{
  dma_info_t dma_info(dma_index, dma_length, DMA_SIZE);
  this -> dma_read_ctrl.put(dma_info);

  for(uint16_t i = 0; i < dma_length; i++)
    {
      HLS_BREAK_DEP(array);
      sc_dt::sc_bv<DMA_WIDTH> data = this->dma_read_chnl.get();
      wait();

      for(int k = 0; k < DMA_WORD_PER_BEAT; k++){
	HLS_UNROLL_SIMPLE;
	array[i * DMA_WORD_PER_BEAT + k] = data.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
      }
    }
}

template <typename T>
void mriq::dma_write(T array[], uint32_t dma_index, uint32_t dma_length)
{
  dma_info_t dma_info(dma_index, dma_length, DMA_SIZE);
  this -> dma_write_ctrl.put(dma_info);

  for(uint16_t i = 0; i < dma_length; i++)
    {
      HLS_BREAK_DEP(array);
      sc_dt::sc_bv<DMA_WIDTH> data;
      wait();      

      for(int k = 0; k < DMA_WORD_PER_BEAT; k++){
	HLS_UNROLL_SIMPLE;
	data.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = array[i * DMA_WORD_PER_BEAT + k];

      }
      this->dma_write_chnl.put(data);
    }
}


void mriq::ComputeQ(FPDATA_S x,FPDATA_S y,FPDATA_S z, uint16_t  batch_size_k, bool pingpong_k, FPDATA_S *sin_table, FPDATA_L *Qr, FPDATA_L *Qi)
{           
  int indexK, i;

  const FPDATA_S PI2 = 6.2831853071796;
  const FPDATA_S HALF_PI = 1.5707963267949;


  FPDATA_L Qracc = 0;
  FPDATA_L Qiacc = 0;
#if(PARAL==4)
  uint16_t unroll_factor = 4;
  FPDATA_L Qracc_p[4];
  FPDATA_L Qiacc_p[4];
  FPDATA_S kx[4];
  FPDATA_S ky[4];
  FPDATA_S kz[4];
  FPDATA_S phiR[4];
  FPDATA_S phiI[4];
  FPDATA_L expArg[4];
  FPDATA_S cosArg[4];
  FPDATA_S sinArg[4];
  FPDATA_S phiMag[4];


#elif(PARAL==8)
  uint16_t unroll_factor = 8;
  FPDATA_L Qracc_p[8];
  FPDATA_L Qiacc_p[8];
  FPDATA_S kx[8];
  FPDATA_S ky[8];
  FPDATA_S kz[8];
  FPDATA_S phiR[8];
  FPDATA_S phiI[8];
  FPDATA_L expArg[8];
  FPDATA_S cosArg[8];
  FPDATA_S sinArg[8];
  FPDATA_S phiMag[8];

#elif(PARAL==16)
  uint16_t unroll_factor = 16;
  FPDATA_L Qracc_p[16];
  FPDATA_L Qiacc_p[16];

  FPDATA_S kx[16];
  FPDATA_S ky[16];
  FPDATA_S kz[16];
  FPDATA_S phiR[16];
  FPDATA_S phiI[16];
  FPDATA_L expArg[16];
  FPDATA_S cosArg[16];
  FPDATA_S sinArg[16];
  FPDATA_S phiMag[16];

#endif

  HLS_FLATTEN_ARRAY(Qracc_p);
  HLS_FLATTEN_ARRAY(Qiacc_p);

  HLS_FLATTEN_ARRAY(kx);
  HLS_FLATTEN_ARRAY(ky);
  HLS_FLATTEN_ARRAY(kz);
  HLS_FLATTEN_ARRAY(phiR);
  HLS_FLATTEN_ARRAY(phiI);
  HLS_FLATTEN_ARRAY(expArg);
  HLS_FLATTEN_ARRAY(cosArg);
  HLS_FLATTEN_ARRAY(sinArg);
  HLS_FLATTEN_ARRAY(phiMag);
  //

#if(ARCH==0)
  //  ESP_REPORT_INFO("compute function: ever come into if SK part");
  for(indexK = 0; indexK < batch_size_k; indexK += unroll_factor)
    {
      //  ESP_REPORT_INFO("compute function: SK-for loop");
      HLS_PIPELINE_LOOP(HARD_STALL, 1, "inner-k-loop-A0");

      // read data from PLMs to registers

      for(i = 0; i < unroll_factor; i++){
	HLS_UNROLL_SIMPLE;
	HLS_BREAK_DEP(plm_kx);
	HLS_BREAK_DEP(plm_ky);
	HLS_BREAK_DEP(plm_kz);
	HLS_BREAK_DEP(plm_phiR);
	HLS_BREAK_DEP(plm_phiI);

	kx[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_kx[indexK + i]);   
	ky[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_ky[indexK + i]);   
	kz[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_kz[indexK + i]);   
	phiR[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_phiR[indexK + i]);   
	phiI[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_phiI[indexK + i]);   
      }

      // do computation
      for(i = 0; i < unroll_factor; i++){
	HLS_UNROLL_SIMPLE;

	phiMag[i] = phiR[i] * phiR[i] + phiI[i] * phiI[i];
	expArg[i] = PI2 * (kx[i] * x + ky[i] * y + kz[i] * z);
	cosArg[i] = mySinf(HALF_PI - expArg[i], sin_table);
	sinArg[i] = mySinf(expArg[i], sin_table);
	Qracc_p[i] = phiMag[i] * cosArg[i];
	Qiacc_p[i] = phiMag[i] * sinArg[i];
      }

      // do accumulation

#if(PARAL==4)
      Qracc += Qracc_p[0] + Qracc_p[1] + Qracc_p[2] + Qracc_p[3];  
      Qiacc += Qiacc_p[0] + Qiacc_p[1] + Qiacc_p[2] + Qiacc_p[3];  
#elif(PARAL==8)
      Qracc += Qracc_p[0] + Qracc_p[1] + Qracc_p[2] + Qracc_p[3] + Qracc_p[4] +  Qracc_p[5] + Qracc_p[6] + Qracc_p[7];  
      Qiacc += Qiacc_p[0] + Qiacc_p[1] + Qiacc_p[2] + Qiacc_p[3] + Qiacc_p[4] +  Qiacc_p[5] + Qiacc_p[6] + Qiacc_p[7];  
#elif(PARAL==16)
      Qracc += Qracc_p[0] + Qracc_p[1] + Qracc_p[2] + Qracc_p[3] + Qracc_p[4] +  Qracc_p[5] + Qracc_p[6] + Qracc_p[7] +
	Qracc_p[8] + Qracc_p[9] + Qracc_p[10] + Qracc_p[11] + Qracc_p[12] +  Qracc_p[13] + Qracc_p[14] + Qracc_p[15];
      Qiacc += Qiacc_p[0] + Qiacc_p[1] + Qiacc_p[2] + Qiacc_p[3] + Qiacc_p[4] +  Qiacc_p[5] + Qiacc_p[6] + Qiacc_p[7] +
	Qiacc_p[8] + Qiacc_p[9] + Qiacc_p[10] + Qiacc_p[11] + Qiacc_p[12] +  Qiacc_p[13] + Qiacc_p[14] + Qiacc_p[15];
#endif

#if(0) // the following implementation can't have a valid scheduling when generating RTL for PARAL=8 and 16.
      for(i = 0; i < unroll_factor; i++){
	HLS_UNROLL_SIMPLE;

	Qracc += Qracc_p[i];
	Qiacc += Qiacc_p[i];
      }
#endif     

    } // end for numK


#else
  //  ESP_REPORT_INFO("compute function: ever come into else  part");
  for (indexK = 0; indexK < batch_size_k; indexK += unroll_factor) 
    {    
      HLS_PIPELINE_LOOP(HARD_STALL, 1, "inner-k-loop-A1");    
      if(pingpong_k)
	{
	  //  ESP_REPORT_INFO("compute function: else-for loop");
	  for(i=0; i < unroll_factor; i++)
	    {
	      HLS_UNROLL_SIMPLE;
	      HLS_BREAK_DEP(plm_kx_ping);
	      HLS_BREAK_DEP(plm_ky_ping);
	      HLS_BREAK_DEP(plm_kz_ping);
	      HLS_BREAK_DEP(plm_phiR_ping);
	      HLS_BREAK_DEP(plm_phiI_ping);


	      kx[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_kx_ping[indexK  + i]); 
	      ky[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_ky_ping[indexK  + i]); 
	      kz[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_kz_ping[indexK  + i]); 
	      phiR[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_phiR_ping[indexK  + i]); 
	      phiI[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_phiI_ping[indexK  + i]); 
	    }
	} // if pingpong
      else{
	for(i=0; i < unroll_factor; i++)
	  {
	    HLS_UNROLL_SIMPLE;
	      
	    HLS_BREAK_DEP(plm_kx_pong);
	    HLS_BREAK_DEP(plm_ky_pong);
	    HLS_BREAK_DEP(plm_kz_pong);
	    HLS_BREAK_DEP(plm_phiR_pong);
	    HLS_BREAK_DEP(plm_phiI_pong);

	    kx[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_kx_pong[indexK  + i]); 
	    ky[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_ky_pong[indexK  + i]); 
	    kz[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_kz_pong[indexK  + i]); 
	    phiR[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_phiR_pong[indexK  + i]); 
	    phiI[i] = int2fp<FPDATA_S, FPDATA_S_WL>(plm_phiI_pong[indexK  + i]); 
	  }
      } // else pingpong

      for(i=0; i < unroll_factor; i++)
	{
	  HLS_UNROLL_SIMPLE;
	  phiMag[i] = phiR[i] * phiR[i] + phiI[i] * phiI[i];
	  expArg[i] = PI2 * (kx[i] * x + ky[i] * y + kz[i] * z);
	  cosArg[i] = mySinf(HALF_PI - expArg[i], sin_table);
	  sinArg[i] = mySinf(expArg[i], sin_table);
	  Qracc_p[i] = phiMag[i] * cosArg[i];
	  Qiacc_p[i] = phiMag[i] * sinArg[i];

	} // for- unroll facto

      // do accumulation

#if(PARAL==4)
      Qracc += Qracc_p[0] + Qracc_p[1] + Qracc_p[2] + Qracc_p[3];  
      Qiacc += Qiacc_p[0] + Qiacc_p[1] + Qiacc_p[2] + Qiacc_p[3];  
#elif(PARAL==8)
      Qracc += Qracc_p[0] + Qracc_p[1] + Qracc_p[2] + Qracc_p[3] + Qracc_p[4] +  Qracc_p[5] + Qracc_p[6] + Qracc_p[7];  
      Qiacc += Qiacc_p[0] + Qiacc_p[1] + Qiacc_p[2] + Qiacc_p[3] + Qiacc_p[4] +  Qiacc_p[5] + Qiacc_p[6] + Qiacc_p[7];  
#elif(PARAL==16)
      Qracc += Qracc_p[0] + Qracc_p[1] + Qracc_p[2] + Qracc_p[3] + Qracc_p[4] +  Qracc_p[5] + Qracc_p[6] + Qracc_p[7] +
	Qracc_p[8] + Qracc_p[9] + Qracc_p[10] + Qracc_p[11] + Qracc_p[12] +  Qracc_p[13] + Qracc_p[14] + Qracc_p[15];
      Qiacc += Qiacc_p[0] + Qiacc_p[1] + Qiacc_p[2] + Qiacc_p[3] + Qiacc_p[4] +  Qiacc_p[5] + Qiacc_p[6] + Qiacc_p[7] +
	Qiacc_p[8] + Qiacc_p[9] + Qiacc_p[10] + Qiacc_p[11] + Qiacc_p[12] +  Qiacc_p[13] + Qiacc_p[14] + Qiacc_p[15];
#endif



    } // for batch_k_size;
#endif
  *Qr = Qracc;
  *Qi = Qiacc;
   
}
  

FPDATA_S mriq::mySinf(FPDATA_L angle, FPDATA_S *sin_table)
{
  FPDATA_S angle_within_2pi;
  FPDATA_S angle_within_halfpi;
  FPDATA_S radian;
  int i;
  int q;
  FPDATA_S ans_sin;

  const FPDATA_S PI = 3.1415926535898;
  const FPDATA_S HALF_PI = 1.5707963267949;
  const FPDATA_S REC_PI = 0.3183098861838;

  angle_within_2pi = angle - PI * 2  * floor(cynw_fixed<FPDATA_L_WL, FPDATA_L_IL, SC_TRN,SC_WRAP, 1> (angle * REC_PI * 0.5));

  q = floor(cynw_fixed<FPDATA_S_WL, FPDATA_S_IL, SC_TRN, SC_WRAP, 1> (angle_within_2pi*2 * REC_PI)).to_int();

  angle_within_halfpi = angle_within_2pi - (HALF_PI) * q;

  
  switch(q){
  case 0: radian = angle_within_2pi;
    break;
  case 1: radian = PI - angle_within_2pi;
    break;
  case 2: radian = angle_within_2pi - PI;
    break;
  case 3: radian = PI * 2- angle_within_2pi;
    break;
  default:radian = angle_within_2pi;
    break;
  }
  
  i = floor(cynw_fixed<FPDATA_L_WL, FPDATA_L_IL, SC_TRN, SC_WRAP, 1> (radian* REC_PI * 40)).to_int();

  if(i >= 19)
    ans_sin = sin_table[19] + (1 - sin_table[19]) * (radian* REC_PI * 40 - 19 );
  else
    ans_sin = sin_table[i] + (sin_table[i + 1] - sin_table[i]) * (radian * REC_PI * 40 - i );


  switch(q){
  case 0: return ans_sin;
  case 1: return ans_sin;
  case 2: return -ans_sin;
  case 3: return -ans_sin;
  default: return ans_sin;
  }

}
