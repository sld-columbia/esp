// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "cholesky.hpp"
#include "cholesky_directives.hpp"

// Functions

#include "cholesky_functions.hpp"

// Processes

void cholesky::load_input()
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
    int32_t rows;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        rows = config.rows;
    }

    // Load
    {
        HLS_PROTO("load-dma");
        wait();

        bool ping = true;
        bool fetch_ping ;
        uint32_t offset = 0;
        uint32_t fetch_offset = 0;
        bool even_rows;
        uint32_t start_fetching_output = 0;
        uint32_t start_fetching_output_thresh = 3;
        sc_dt::sc_bv<DMA_WIDTH> rows_bv(rows);
        even_rows = (rows_bv.range(0, 0) == 0);

        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();
            uint32_t length = rows * rows;
            // Chunking
            for (int rem = length; rem > 0; rem -= rows)
            {
                wait();
                // Configure DMA transaction
                uint32_t len = rem > rows ? rows : rem;
		        len = (DMA_WORD_PER_BEAT==2 && !even_rows) ? len+1 : len;
                //ESP_REPORT_INFO("Load offset: %d, adjusted: %d\n", offset, offset / DMA_WORD_PER_BEAT);
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
                offset += (DMA_WORD_PER_BEAT==2 && !even_rows) ? ((ping) ? (len-2) : len) : len;

                this->dma_read_ctrl.put(dma_info);

                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    HLS_BREAK_DEP(plm_in_ping);
                    HLS_BREAK_DEP(plm_in_pong);

                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    dataBv = this->dma_read_chnl.get();
                    wait();
#if (DMA_WORD_PER_BEAT == 2)
                    if(!even_rows) {
                         for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                        	HLS_UNROLL_SIMPLE;
                        	if (ping) {
                               plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                            }
                            else {
                                if(i == 0 && k == 0)
                                  plm_in_pong[i ] = dataBv.range(2 * DATA_WIDTH - 1,  DATA_WIDTH).to_int64();
                                else if(i != 0)
                                  plm_in_pong[i + k-1] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                            }
                         }
                    } else {
                    	for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                        	HLS_UNROLL_SIMPLE;
                        	if (ping)
                            	   plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                        	else
                            	   plm_in_pong[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
				        }
               	    }
#else
                    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                        HLS_UNROLL_SIMPLE;
                        if (ping)
                               plm_in_ping[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                        else
                               plm_in_pong[i + k] = dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
				    }
#endif
		        }   //for(i)

                if(start_fetching_output >= start_fetching_output_thresh) {
			        fetch_ping = true;
			        bool skip = false;
                    int fetch_time = start_fetching_output - 2;
                    fetch_offset = (rows * rows) + rows;
                    for (int fetch_index = 0; fetch_index < fetch_time+1; fetch_index++) {
               	        wait();

				        if(skip) {
				            uint32_t fetch_len = rows;
                		    fetch_len = (DMA_WORD_PER_BEAT == 2 && !even_rows) ? fetch_len + 1 : fetch_len;

				            dma_info_t dma_info(fetch_offset / DMA_WORD_PER_BEAT, fetch_len / DMA_WORD_PER_BEAT, DMA_SIZE);
                		    fetch_offset += (DMA_WORD_PER_BEAT == 2 && !even_rows) ? (fetch_ping ? fetch_len : fetch_len - 2) : fetch_len;
                		    this->dma_read_ctrl.put(dma_info);

		 		            for (uint16_t i = 0; i < fetch_len; i += DMA_WORD_PER_BEAT)
               				{
                                HLS_BREAK_DEP(plm_fetch_outdata_ping);
                                HLS_BREAK_DEP(plm_fetch_outdata_pong);
                                sc_dt::sc_bv<DMA_WIDTH> data_Bv;
                                data_Bv = this->dma_read_chnl.get();
                                wait();
#if (DMA_WORD_PER_BEAT == 2)
  					            if (!even_rows) {
                         	        for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                                	    HLS_UNROLL_SIMPLE;
                                		if (fetch_ping) {
							                if (i == 0 && k == 0)
                                                plm_fetch_outdata_ping[i] = data_Bv.range(2 * DATA_WIDTH - 1, DATA_WIDTH).to_int64();
                                            else if(i != 0)
                                                plm_fetch_outdata_ping[i+k-1] = data_Bv.range((k+1)*DATA_WIDTH-1, k*DATA_WIDTH).to_int64();
                                        } else {
                                            if(i == (fetch_len - 2) && k == 0)
                                                plm_fetch_outdata_pong[i] = data_Bv.range(DATA_WIDTH - 1, 0).to_int64();
                                            else if (i!=(fetch_len-2))
                                                plm_fetch_outdata_pong[i+k] = data_Bv.range((k+1)*DATA_WIDTH-1, k * DATA_WIDTH).to_int64();
                                  	    }
                                    }
                                } else { // DMA Proper Even Align//
	  					            for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                                	    HLS_UNROLL_SIMPLE;
                               			if (fetch_ping)
                              			    plm_fetch_outdata_ping[i+k] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                                	    else
                                   		    plm_fetch_outdata_pong[i+k] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                            	    }
					            }
#else
                                for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                                    HLS_UNROLL_SIMPLE;
                                    if (fetch_ping)
                                        plm_fetch_outdata_ping[i+k] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                                    else
                                        plm_fetch_outdata_pong[i+k] = data_Bv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
                                }
#endif
                            }  //for(i)

                            fetch_ping = !fetch_ping;
				        } //skip

                        skip = true;
				        this->load_compute_handshake();
		           } //for(fetch-index)
		        } //if(start_fetching)

		        if(start_fetching_output < start_fetching_output_thresh)
		            this->load_compute_handshake();

                ping = !ping;
		        start_fetching_output++;
            } //for(rem)
        } //for(b)
    }

    // Conclude
    {
        this->process_done();
    }
}



void cholesky::store_output()
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
    int32_t rows;
    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        rows = config.rows;
        rows = config.rows;
    }

    // Store
    {
        HLS_PROTO("store-dma");
        wait();

        bool ping = true;
        int dma_rem_data;
        bool even_rows;
        sc_dt::sc_bv<DMA_WIDTH> rows_bv(rows);
        even_rows = (rows_bv.range(0, 0) == 0);

        uint32_t store_offset = (rows * rows) * 1;
        uint32_t offset = (DMA_WORD_PER_BEAT == 2 && !even_rows) ?  store_offset + 1 : store_offset;

        wait();
        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            //HLS_BREAK_DEP(plm_out_ping);
            //HLS_BREAK_DEP(plm_out_pong);
            wait();
            uint32_t length = rows * rows;

            // Chunking
            for (int rem = length; rem > 0; rem -= rows)
            {

                this->store_compute_handshake();

                // Configure DMA transaction
                uint32_t len = rem > rows ? rows : rem;
		        len = (DMA_WORD_PER_BEAT==2 && !even_rows) ? len+1 : len;
                //ESP_REPORT_INFO("Store offset: %d, adjusted: %d\n", offset, offset / DMA_WORD_PER_BEAT);
                dma_info_t dma_info(offset / DMA_WORD_PER_BEAT, len / DMA_WORD_PER_BEAT, DMA_SIZE);
                offset += (DMA_WORD_PER_BEAT==2 && !even_rows) ? (ping ? (len - 2) : len) : len;

                this->dma_write_ctrl.put(dma_info);

                for (uint16_t i = 0; i < len; i += DMA_WORD_PER_BEAT)
                {
                    sc_dt::sc_bv<DMA_WIDTH> dataBv;

                    // Read from PLM
                    wait();
#if (DMA_WORD_PER_BEAT == 2)
		            if(!even_rows) {
                        for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
                        {
                            HLS_UNROLL_SIMPLE;
                        	if (ping) {
                                if(i == (len - 2) && k != 1) {
                                    dataBv.range(DATA_WIDTH - 1,  0) = plm_out_ping[i];
                                    dma_rem_data = plm_out_ping[i];
                                } else {
                                    if(i != (len - 2))
                                        dataBv.range((k + 1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_ping[i + k];
                                }
                            } else {
                                if(i == 0) {
					                if(k == 0)
                            		    dataBv.range(DATA_WIDTH - 1, 0) = dma_rem_data;
                                    else
                            		    dataBv.range(2 * DATA_WIDTH - 1,  DATA_WIDTH) = plm_out_pong[i];
                                 } else
                                    dataBv.range((k + 1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_pong[i + k - 1];
                            }
                        } //for(k)
                    } else {
                        for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                            HLS_UNROLL_SIMPLE;
                        	if (ping)
                                dataBv.range((k + 1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_ping[i + k];
                            else
                                dataBv.range((k + 1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_pong[i + k];
                        }
		            }
#else
                   for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++) {
                        HLS_UNROLL_SIMPLE;
                        if (ping)
                            dataBv.range((k + 1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_ping[i + k];
                        else
                            dataBv.range((k + 1) * DATA_WIDTH - 1, k * DATA_WIDTH) = plm_out_pong[i + k];
                    }
#endif
                    wait();
                    this->dma_write_chnl.put(dataBv);
                } //for(i)

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


void cholesky::compute_kernel()
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
    int32_t rows;
    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        rows = config.rows;
    }

    // Compute
   	bool ping = true;
	FPDATA sum;
   	FPDATA index_sqrt;
   	int index_sqrt_data;
   	int output_data;
   	FPDATA plm_in_data;
   	FPDATA plm_out_data;
   	FPDATA plm_diag_data;
   	FPDATA plm_temp_data;
   	FPDATA plm_fetch_data;
    uint32_t start_fetching_output_thresh = 3;
    {
        for (uint16_t b = 0; b < 1; b++) {
            uint32_t in_length = rows * rows;
	        int i = 0;
            int fill;

            for (int in_rem = in_length; in_rem > 0; in_rem -= rows) {
                //HLS_BREAK_DEP(plm_temp_ping);
                //HLS_BREAK_DEP(plm_temp_pong);
                //HLS_BREAK_DEP(plm_diag);

                if(i < start_fetching_output_thresh)
                    this->compute_load_handshake();

                // Computing phase implementation
		        int iters = 0;
		        bool fetch_out_ping = true;
		        int iters_thresh = (i >= start_fetching_output_thresh) ? i - 1 : 0;
	            int plm_out_data_int;
		        int plm_temp_data_int;
		        fill = 0;

                for (int j = 0; j < i + 1; j++) {
			        if(i >= start_fetching_output_thresh && iters < iters_thresh)
			            this->compute_load_handshake();

			        plm_in_data = ping ? int2fp<FPDATA, WORD_SIZE>(plm_in_ping[j]) : int2fp<FPDATA, WORD_SIZE>(plm_in_pong[j]);
			        plm_diag_data = int2fp<FPDATA, WORD_SIZE>(plm_diag[j]);

                    sum = 0;
                    for (int k = 0; k < j; k++) {
                        plm_out_data_int = ping ? plm_out_ping[k] : plm_out_pong[k];
                        plm_temp_data_int = ping ? plm_temp_pong[k] : plm_temp_ping[k];
                        plm_out_data = int2fp<FPDATA, WORD_SIZE>(plm_out_data_int);
                        plm_temp_data = int2fp<FPDATA, WORD_SIZE>(plm_temp_data_int);

                        if(i >= start_fetching_output_thresh) {
                            if(j < (i - 1)) {
					            if (fetch_out_ping)
					                plm_fetch_data = int2fp<FPDATA, WORD_SIZE>(plm_fetch_outdata_ping[k]);
					            else
					                plm_fetch_data = int2fp<FPDATA, WORD_SIZE>(plm_fetch_outdata_pong[k]);

                                sum +=  plm_out_data * plm_fetch_data;
					        } else if(j == (i - 1)) {
                                sum += plm_out_data * plm_temp_data;
                            } else {
                                sum += plm_out_data * plm_out_data;
                            }
                        } else {
                            if(i != j)
                                sum += plm_out_data * plm_temp_data;
                            else
                                sum += plm_out_data * plm_out_data;
                        }
                    } //for(k)

                    if(i == j) {
                        index_sqrt = plm_in_data - sum;
                        index_sqrt_data =fp2int<FPDATA, WORD_SIZE>(sqrt(index_sqrt));

                        if(ping)
                            plm_out_ping[j] =index_sqrt_data;
			            else
				            plm_out_pong[j] =index_sqrt_data;

                        plm_diag[ j] = index_sqrt_data;
                    } else {
                        if( plm_diag_data != 0) {
                            output_data = fp2int<FPDATA, WORD_SIZE>((1.0 /plm_diag_data) * (plm_in_data - sum));

                            if(ping) {
                                plm_out_ping[j] = output_data;
                                plm_temp_ping[fill] = output_data;
				            } else {
					            plm_out_pong[j] = output_data;
                                plm_temp_pong[fill] = output_data;
				            }
                        } else {
				            if(ping) {
			         	        plm_out_ping[j] = 0;
				 	            plm_temp_ping[fill] = 0;
				            } else {
					            plm_out_pong[j] = 0;
                                plm_temp_pong[fill] = 0;
				            }
				        }

                        fill++;
                    } //if(i==j)

                    iters++;
			        if(j > 0)
                        fetch_out_ping= !fetch_out_ping;
                } //for(j)

                for (int z =(i+1) ; z < rows ; z++) {
                    if(ping)
                        plm_out_ping[z] = 0;
                    else
                        plm_out_pong[z] = 0;
                }
                wait();
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
