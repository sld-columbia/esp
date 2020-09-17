// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "cholesky_small.hpp"
#include "cholesky_small_directives.hpp"

// Functions

#include "cholesky_small_functions.hpp"

// Processes

void cholesky_small::load_input()
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
        uint32_t offset = 0;

        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();
#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = input_rows * input_rows;
#else
            uint32_t length = round_up(input_rows * input_rows, DMA_WORD_PER_BEAT);
#endif
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_IN_WORD)
            {
                wait();
                // Configure DMA transaction
                uint32_t len = rem > PLM_IN_WORD ? PLM_IN_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
                offset += len;

                this->dma_read_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                for (uint16_t i = 0; i < len; i++)
                {
                    sc_dt::sc_bv<DATA_WIDTH> dataBv;

                    for (uint16_t k = 0; k < DMA_BEAT_PER_WORD; k++)
                    {
                        dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH) = this->dma_read_chnl.get();
                        wait();
                    }

                    // Write to PLM
                    if (ping)
                        plm_in_ping[i] = dataBv.to_int64();
                    else
                        plm_in_pong[i] = dataBv.to_int64();
                }
#else
                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    HLS_BREAK_DEP(plm_in_ping);
                    HLS_BREAK_DEP(plm_in_pong);

                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    dataBv = this->dma_read_chnl.get();
                    wait();

                    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        HLS_UNROLL_SIMPLE;
                        if (ping)
                            plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                        else
                            plm_in_pong[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                    }
                }
#endif
                this->load_compute_handshake();
                ping = !ping;
            }
        }
    }

    // Conclude
    {
        this->process_done();
    }
}



void cholesky_small::store_output()
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
#if (DMA_WORD_PER_BEAT == 0)
        uint32_t store_offset = (input_rows * input_rows) * 1;
#else
        uint32_t store_offset = round_up(input_rows * input_rows, DMA_WORD_PER_BEAT) * 1;
#endif
        uint32_t offset = store_offset;

        wait();
        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();
#if (DMA_WORD_PER_BEAT == 0)
            uint32_t length = output_rows * output_rows;
#else
            uint32_t length = round_up(output_rows * output_rows, DMA_WORD_PER_BEAT);
#endif
            // Chunking
            for (int rem = length; rem > 0; rem -= PLM_OUT_WORD)
            {

                this->store_compute_handshake();

                // Configure DMA transaction
                uint32_t len = rem > PLM_OUT_WORD ? PLM_OUT_WORD : rem;
#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                dma_info_t dma_info(offset * DMA_BEAT_PER_WORD, len * DMA_BEAT_PER_WORD, DMA_SIZE);
#else
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
#endif
                offset += len;

                this->dma_write_ctrl.put(dma_info);

#if (DMA_WORD_PER_BEAT == 0)
                // data word is wider than NoC links
                for (uint16_t i = 0; i < len; i++)
                {
                    // Read from PLM
                    sc_dt::sc_int<DATA_WIDTH> data;
                    wait();
                    if (ping)
                        data = plm_out_ping[i];
                    else
                        data = plm_out_pong[i];
                    sc_dt::sc_bv<DATA_WIDTH> dataBv(data);

                    uint16_t k = 0;
                    for (k = 0; k < DMA_BEAT_PER_WORD - 1; k++)
                    {
                        this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                        wait();
                    }
                    // Last beat on the bus does not require wait(), which is
                    // placed before accessing the PLM
                    this->dma_write_chnl.put(dataBv.range((k+1) * DMA_WIDTH - 1, k * DMA_WIDTH));
                }
#else
                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    // Read from PLM
                    wait();
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                    {
                        HLS_UNROLL_SIMPLE;
                        if (ping)
                            dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_ping[i + k];
                        else
                            dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_pong[i + k];
                    }
                    this->dma_write_chnl.put(dataBv);
                }
#endif
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


void cholesky_small::compute_kernel()
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
    {
        for (uint16_t b = 0; b < 1; b++)
        {
            uint32_t in_length = input_rows * input_rows;
            uint32_t out_length = output_rows * output_rows;
            int out_rem = out_length;
	    uint32_t n = input_rows;
		int i =0;
		int fill =0;
		int temp ;
            for (int in_rem = in_length; in_rem > 0; in_rem -= PLM_IN_WORD)
            {
		temp=0;
                uint32_t in_len  = in_rem  > PLM_IN_WORD  ? PLM_IN_WORD  : in_rem;
                uint32_t out_len = out_rem > PLM_OUT_WORD ? PLM_OUT_WORD : out_rem;

                this->compute_load_handshake();
		
                // Computing phase implementation
               
                    if (ping)
			{	
			   for (int j = 0; j < (i+1); j++)
			     {
          			 s = 0;
            			 for (int k = 0; k < j; k++) {
					if(i!=j) {
						if(j==(PLM_IN_WORD-2))
                				s += int2fp<FPDATA, WORD_SIZE> ( plm_out_ping[k])  * int2fp<FPDATA, WORD_SIZE> (plm_temp[temp]);
						else
						s += int2fp<FPDATA, WORD_SIZE> ( plm_out_ping[k])  * int2fp<FPDATA, WORD_SIZE> (plm_temp[temp]);
						}
					else 
                			s += int2fp<FPDATA, WORD_SIZE> ( plm_out_ping[k])  * int2fp<FPDATA, WORD_SIZE> (plm_out_ping[k]);
					temp++;
					}

                		if(i == j){
                        	  index_sqrt =int2fp<FPDATA, WORD_SIZE> ( plm_in_ping[i]) - s;
                        	   plm_out_ping[j] =fp2int<FPDATA, WORD_SIZE> ( sqrt(index_sqrt));
                        	   plm_diag[ j] = fp2int<FPDATA, WORD_SIZE> (sqrt(index_sqrt));
                  			 }
               			 else{
			                if( plm_temp[j] != 0) {
                        		  plm_out_ping[j] =  fp2int<FPDATA, WORD_SIZE> ((1.0 /int2fp<FPDATA, WORD_SIZE>( plm_diag[j])) *( int2fp<FPDATA, WORD_SIZE>(plm_in_ping[ j]) - s));                			      plm_temp[fill] =  fp2int<FPDATA, WORD_SIZE> ((1.0 /int2fp<FPDATA, WORD_SIZE>( plm_diag[j])) *( int2fp<FPDATA, WORD_SIZE>(plm_in_ping[ j]) - s));
					}else
                    			   plm_out_ping[j] = 0;
				     fill++;
       				     }	
				  //fill++;
        			 } //for-j

			}//if
                    else // !ping
			{
			    for (int j = 0; j < (i+1); j++)
                             {
                                 s = 0;
                                 for (int k = 0; k < j; k++) {
					if(i!=j)  {
                                                if(j==((PLM_IN_WORD-2)))
                                                s += int2fp<FPDATA, WORD_SIZE> ( plm_out_pong[k])  * int2fp<FPDATA, WORD_SIZE> (plm_temp[temp]); //j+1+k
						else
                                        	s += int2fp<FPDATA, WORD_SIZE> ( plm_out_pong[k]) * int2fp<FPDATA, WORD_SIZE> ( plm_temp[temp]);
						}	
				        else
                                        s += int2fp<FPDATA, WORD_SIZE> ( plm_out_pong[k])  * int2fp<FPDATA, WORD_SIZE> (plm_out_pong[k]);
					temp++;
                                        }

                                if(i == j){
                                  index_sqrt = int2fp<FPDATA, WORD_SIZE> (plm_in_pong[i]) - s;
                                   plm_out_pong[j] = fp2int<FPDATA, WORD_SIZE>  (sqrt(index_sqrt));
                                   plm_diag[ j] = fp2int<FPDATA, WORD_SIZE> (sqrt(index_sqrt));
                                         }
                                 else{
                                        if( plm_diag[j] != 0) {
                                            plm_out_pong[j] =  fp2int<FPDATA, WORD_SIZE> ((1.0 /int2fp<FPDATA, WORD_SIZE>( plm_diag[j])) * (int2fp<FPDATA, WORD_SIZE>(plm_in_pong[j]) - s));
                                            plm_temp[fill] =  fp2int<FPDATA, WORD_SIZE> ((1.0 /int2fp<FPDATA, WORD_SIZE>( plm_diag[j])) * (int2fp<FPDATA, WORD_SIZE>(plm_in_pong[j]) - s));
                                     }   else
                                           plm_out_pong[j] = 0;
					fill++;
                                     }
				// fill++;
                               }//for-j

			}//else

			for (int z =(i+1) ; z < input_rows ; z++) {
				if(ping) 
				 plm_out_ping[z] =0;
				else 
				plm_out_pong[z] =0;
			}

                out_rem -= PLM_OUT_WORD;
                this->compute_store_handshake();
                ping = !ping;
		i++;
		cout << "TEMP VAL " << temp << "\n";
            }

		for( int l =0 ; l <4 ; l++)
		cout << "PLM TEMP LOC = " << l << "  IS  " << int2fp<FPDATA, WORD_SIZE>(plm_temp[l]) << "\n" ;
		cout << "\n";
		for( int l =0 ; l <4 ; l++)
                cout << "PLM DIAG LOC = " << l << "  IS  " << int2fp<FPDATA, WORD_SIZE>(plm_diag[l]) << "\n" ;
        }

        // Conclude
       

 {
            this->process_done();
        }
    }
}
