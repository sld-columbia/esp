// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "cholesky_6x6.hpp"
#include "cholesky_6x6_directives.hpp"

// Functions

#include "cholesky_6x6_functions.hpp"

// Processes

void cholesky_6x6::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t input_rows;
    int32_t output_rows;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        input_rows = config.input_rows;
        output_rows = config.output_rows;
    }

    // Load
    {
        HLS_PROTO("load-dma");
        wait();

        bool ping = true;
        bool fetch_ping ;
        uint32_t offset = 0;
        uint32_t fetch_offset = 0;
        uint32_t loader = 1;
 	bool DMA_EVEN;
	uint32_t start_fetching_output=0;
	sc_dt::sc_bv<DMA_WIDTH> rows_bv(input_rows);
	DMA_EVEN = ( rows_bv.range(0,0)==0) ?	 true : false;

        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();
            uint32_t length = input_rows * input_rows;
            // Chunking
            for (int rem = length; rem > 0; rem -= input_rows)
            {
                wait();
                // Configure DMA transaction
                uint32_t len = rem > input_rows ? input_rows : rem;
		len = (DMA_WORD_PER_BEAT==2 && DMA_EVEN== false) ? len+1 : len;
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
                offset += (DMA_WORD_PER_BEAT==2 && DMA_EVEN== false) ? ((ping) ? (len-2) : len) : len;

                this->dma_read_ctrl.put(dma_info);

                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    HLS_BREAK_DEP(plm_in_ping);
                    HLS_BREAK_DEP(plm_in_pong);

                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    dataBv = this->dma_read_chnl.get();
                    wait();

                    if(DMA_WORD_PER_BEAT==2 && DMA_EVEN==false)
		       {
                         for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                             {
                        	HLS_UNROLL_SIMPLE;
                        	if (ping)
				   {
                                     //if(i==(len-2) && (k==0))
                                     //   plm_in_ping[i ] = dataBv.range(  DATA_WIDTH - 1, 0).to_int64();
                                    // else if (i!=(len-2))
                                        plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                                   }
                                else
				   {
                                    if(i==0 && (k==0))
                                      plm_in_pong[i ] = dataBv.range((2) * DATA_WIDTH - 1,  DATA_WIDTH).to_int64();
                                    else if(i!=0)
                                      plm_in_pong[i + k-1] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();

                                  }
                             } 
                       }
		    else 
		       {
                    	for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    	    {
                        	HLS_UNROLL_SIMPLE;
                        	if (ping)
                            	   plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                        	else
                            	   plm_in_pong[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
				    
                             }
               	       }
		}//for(i-loader) 
		if(start_fetching_output >=3)
		  {  
			fetch_ping=true; 
			bool skip = false;
		       int fetch_time = start_fetching_output-2;
		       fetch_offset = (input_rows * input_rows) + input_rows ;
		       for (int fetch_index = 0; fetch_index < fetch_time+1; fetch_index++)
            		   {
               			 wait();
				 if(skip) {
				 uint32_t fetch_len = input_rows ;
                		 fetch_len = (DMA_WORD_PER_BEAT==2 && DMA_EVEN== false) ? fetch_len+1 : fetch_len;

				 dma_info_t dma_info(fetch_offset / DMA_WORD_PER_BEAT, fetch_len / DMA_WORD_PER_BEAT, DMA_SIZE);
                		 fetch_offset += (DMA_WORD_PER_BEAT==2 && DMA_EVEN== false) ? ((fetch_ping) ? (fetch_len) : fetch_len-2) : fetch_len;
                		 this->dma_read_ctrl.put(dma_info);
		 		     for (uint16_t i = 0; i < fetch_len; i += DMA_WORD_PER_BEAT)
               				 {
                    			   HLS_BREAK_DEP(plm_fetch_outdata_ping);
                    			   HLS_BREAK_DEP(plm_fetch_outdata_pong);
                    			   sc_dt::sc_bv<DMA_WIDTH> data_Bv;
                    			   data_Bv = this->dma_read_chnl.get();
                    			   wait();
					
  					   if(DMA_WORD_PER_BEAT==2 && DMA_EVEN==false)
                      			      {
                         			for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                            			   {
                                			HLS_UNROLL_SIMPLE;
                                			if (fetch_ping)
                                   			  {
							    if(i==0 && (k==0))
                                                                plm_fetch_outdata_ping[i ] = data_Bv.range((2) * DATA_WIDTH - 1,  DATA_WIDTH).to_int64();
                                                             else if(i!=0)
                                                                plm_fetch_outdata_ping[i + k-1] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();

                                   			  }
                                	                else
                                  			  {
							    if(i==(fetch_len-2) && (k==0))
                                                                plm_fetch_outdata_pong[i ] = data_Bv.range(  DATA_WIDTH - 1, 0).to_int64();
                                                            else if (i!=(fetch_len-2))
                                                                plm_fetch_outdata_pong[i + k] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();

                                  			  }
                            			   } 
                      			      }

					    else// DMA Proper Even Align//
					     {
	  					for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                            			    {
                                			HLS_UNROLL_SIMPLE;
                               				if (fetch_ping)
                                   			   plm_fetch_outdata_ping[i + k] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                                			else
                                   			   plm_fetch_outdata_pong[i + k] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                            			    }
					     }
					 }//for(i)
				fetch_ping=!fetch_ping;
				}//skip
				skip=true;
				this->load_compute_handshake();
		           }//for(fetch-index)
		}//if(start_fetching)
			
                loader++;
		if(start_fetching_output<3)
		this->load_compute_handshake();
                ping = !ping;
		start_fetching_output++;
            }//for(rem)
        }
    }

    // Conclude
    {
        this->process_done();
    }
}



void cholesky_6x6::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t input_rows;
    int32_t output_rows;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        input_rows = config.input_rows;
        output_rows = config.output_rows;
    }

    // Store
    {
        HLS_PROTO("store-dma");
        wait();

        bool ping = true;
	int dma_rem_data;
	bool DMA_EVEN;
        sc_dt::sc_bv<DMA_WIDTH> rows_bv(input_rows);
        DMA_EVEN = ( rows_bv.range(0,0)==0) ?    true : false;

        uint32_t store_offset = (input_rows * input_rows) * 1;
        uint32_t offset = (DMA_WORD_PER_BEAT==2 && DMA_EVEN==false) ?  store_offset+1 : store_offset;

        wait();
        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();
            uint32_t length = output_rows * output_rows;
            // Chunking
            for (int rem = length; rem > 0; rem -= output_rows)
            {

                this->store_compute_handshake();

                // Configure DMA transaction
                uint32_t len = rem > output_rows ? output_rows : rem;
		len = (DMA_WORD_PER_BEAT==2 && DMA_EVEN== false) ? len+1 : len;
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
                offset += (DMA_WORD_PER_BEAT==2 && DMA_EVEN== false) ? ((ping) ? (len-2) : len) : len;

                this->dma_write_ctrl.put(dma_info);

                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    // Read from PLM
                    wait();

		 if( DMA_WORD_PER_BEAT==2 && DMA_EVEN==false)
                     {
                         for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                             {
                        	HLS_UNROLL_SIMPLE;
                        	if (ping)
				   {
                                      if(i==(len-2) && k!=1 )
					 {
                            		   dataBv.range( DATA_WIDTH - 1,  0) = plm_out_ping[i ];
                                           dma_rem_data =  plm_out_ping[i ];
                                          }
                                      else 
					 {
                                           if(i!=(len-2))
                                           dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_ping[i + k];
                                	 }


                                   } 
				else
				   {
                                      if(i==0)
                                        {
					  if(k==0)
                            		    dataBv.range(DATA_WIDTH - 1,  0) = dma_rem_data;
                                          else
                            		    dataBv.range((2) * DATA_WIDTH - 1,  DATA_WIDTH) = plm_out_pong[i ];
                                        }
                                      else
                                        dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_pong[i + k-1];


                                  }
                             }//for(k)
                     }
		 else // !( DMA_WORD_PER_BEAT==2 && DMA_EVEN==false)
		     {
                     	for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    	    {
                                HLS_UNROLL_SIMPLE;
                        	if (ping) 
                                    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_ping[i + k]; 
                                else
                                    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_pong[i + k];
                             }
		    }
                 this->dma_write_chnl.put(dataBv);
	
                }//for(i)
                ping = !ping;
            }
        }
    }

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void cholesky_6x6::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int32_t input_rows;
    int32_t output_rows;
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        input_rows = config.input_rows;
        output_rows = config.output_rows;
    }


    // Compute
    	bool ping = true;
	FPDATA s;
    	FPDATA index_sqrt;
   	int index_sqrt_data;
   	int output_data;
    	FPDATA plm_in_data;
    	FPDATA plm_out_data;
    	FPDATA plm_diag_data;
    	FPDATA plm_temp_data;
    	FPDATA plm_fetch_data;

    {
        for (uint16_t b = 0; b < 1; b++)
        {
            uint32_t in_length = input_rows * input_rows;
            uint32_t out_length = output_rows * output_rows;
            int out_rem = out_length;
	    int i =0;
            int fill ;
            int temp ;

            for (int in_rem = in_length; in_rem > 0; in_rem -= input_rows)
            { 
		 HLS_BREAK_DEP(plm_out_ping);
                 HLS_BREAK_DEP(plm_out_pong);
                 HLS_BREAK_DEP(plm_temp_ping);
                 HLS_BREAK_DEP(plm_temp_pong);
                 HLS_BREAK_DEP(plm_diag);
	
		temp =0;
		if(i<3)
                this->compute_load_handshake();
		wait();
                // Computing phase implementation
		int call_times =0;
		fill=0;
		bool fetch_out_ping =true;
		int num_of_calls = (i>=3) ? i-1 :0;
	        int plm_out_data_int;
		int plm_temp_data_int;	
		   for (int j = 0; j < (i+1); j++)
		   	{ 
			   wait();
			   if(i>=3 &&  (call_times < num_of_calls)) 
			   this->compute_load_handshake();
			  
			   plm_in_data = (ping) ? int2fp<FPDATA, WORD_SIZE>(plm_in_ping[ j]) : int2fp<FPDATA, WORD_SIZE>(plm_in_pong[ j]) ;
			  
			   plm_diag_data = int2fp<FPDATA, WORD_SIZE>(plm_diag[ j]);
                           s = 0;
                           for (int k = 0; k < j; k++) 
			      {
				wait();
				plm_out_data_int = (ping) ?  plm_out_ping[k] :  plm_out_pong[k];
				plm_temp_data_int =(ping) ? ( plm_temp_pong[k]) :   ( plm_temp_ping[k]);
				plm_out_data = int2fp<FPDATA, WORD_SIZE> (plm_out_data_int);
			        plm_temp_data = int2fp<FPDATA, WORD_SIZE> (plm_temp_data_int);
				if(i>=3)
                                   {
                                      if(j<(i-1)) 
					 {
					  if(fetch_out_ping)
					      plm_fetch_data =int2fp<FPDATA, WORD_SIZE> ( plm_fetch_outdata_ping[k]);
					  else
					      plm_fetch_data =int2fp<FPDATA, WORD_SIZE> ( plm_fetch_outdata_pong[k]);
                                 	  s +=  plm_out_data * plm_fetch_data ;
					}
                                      else if(j==(i-1))
                                        s += plm_out_data * plm_temp_data;
                                      else
                                        s += plm_out_data * plm_out_data;
                                   }
                                 else
                                   {
                                     if(i!=j)
                                        s += plm_out_data * plm_temp_data;
                                      else
                                        s += plm_out_data * plm_out_data;
                                   }

                              }//for(k)
                           if(i == j)
			     {
                               index_sqrt = plm_in_data - s;
                               index_sqrt_data =fp2int<FPDATA, WORD_SIZE> ( sqrt(index_sqrt));
			       if(ping)
                               	  plm_out_ping[j] =index_sqrt_data;
			       else
				  plm_out_pong[j] =index_sqrt_data;
                               plm_diag[ j] = index_sqrt_data;
                             }
                           else //(i!=j)
			     {
                               if( plm_diag_data != 0)
			         {
                                  output_data =  fp2int<FPDATA, WORD_SIZE> ((1.0 /plm_diag_data) *( plm_in_data - s));  
				  if(ping)
				    {
                                  	plm_out_ping[j] =  output_data;  
                                  	plm_temp_ping[fill] =  output_data;
				    }
				  else
				    {
					plm_out_pong[j] =  output_data;
                                        plm_temp_pong[fill] =  output_data;
				    }
                                 }
			       else
				 {
				    if(ping)
				      {
			         	plm_out_ping[j] = 0;
				 	plm_temp_ping[fill]=0;
				      }
				    else
				      {
					plm_out_pong[j] = 0;
                                        plm_temp_pong[fill]=0;
				      }

				 }
                               fill++;
                             }//else(i!=j)
			    call_times++;
			    if(j>0) fetch_out_ping= !fetch_out_ping;
                        }//for(j)

                for (int z =(i+1) ; z < input_rows ; z++)
		    {
			wait();
                        if(ping)
                          plm_out_ping[z] =0;
                        else
                          plm_out_pong[z] =0;
                    }

                this->compute_store_handshake();
                ping = !ping;
		i++;
            }

        }

        // Conclude
        {
            this->process_done();
        }
    }
}
