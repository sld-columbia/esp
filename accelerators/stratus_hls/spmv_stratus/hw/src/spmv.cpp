// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "spmv.hpp"
#include "spmv_directives.hpp"

// Functions

#include "spmv_functions.hpp"

// Processes

void spmv::load_input()
{
    /* Local variables */

    // for PLM pingpong
    bool ping;

    // for input configuration
    uint32_t nrows;
    uint32_t ncols;
    uint32_t max_nonzero;
    uint32_t mtx_len;
    uint32_t vals_plm_size;
    bool     vect_fits_plm;

    // for derived configuration
    uint32_t index_rows;
    uint32_t index_cols;
    uint32_t index_vals;
    uint32_t index_vect;
    uint32_t len_rows;
    uint32_t len_cols;
    uint32_t len_vals;
    uint32_t len_vect;

    // # of bursts evaluation
    uint32_t bursts;

    // last row value of previous burst
    uint32_t rows_last, rows_last_diff;

    // Reset
    {
	HLS_LOAD_RESET;

	this->reset_load_input();

	ping = true;

	nrows = 0;
	ncols = 0;
	max_nonzero = 0;
	mtx_len = 0;
	vals_plm_size = 0;
	vect_fits_plm = 0;

	index_rows = 0;
	index_cols = 0;
	index_vals = 0;
	index_vect = 0;
	len_rows = 0;
	len_cols = 0;
	len_vals = 0;
	len_vect = 0;

	bursts = 0;

	rows_last = 0;
	rows_last_diff = 0;

	wait();
    }

    // Config
    {
    	HLS_LOAD_CONFIG;

	// Acquire config parameters
    	cfg.wait_for_config(); // config process
    	conf_info_t config = this->conf_info.read();

    	nrows = config.nrows;
    	ncols = config.ncols;
    	max_nonzero = config.max_nonzero;
    	mtx_len = config.mtx_len;
	vals_plm_size = config.vals_plm_size;
	vect_fits_plm = config.vect_fits_plm;

    	// DMA index evaluation
    	index_rows = 2 * mtx_len;
    	index_cols = mtx_len;
    	index_vals = 0;
    	index_vect = nrows + 2 * mtx_len;

    	// DMA length evaluation
    	len_rows = (uint32_t) (vals_plm_size / max_nonzero);

    	// # of bursts evaluation
    	bursts = (uint32_t) ((nrows - 1) / len_rows) + 1;
    }

    // Load the whole vector if it fits the PLM
    if (vect_fits_plm) {

	{
	    HLS_LOAD_DMA;

	    dma_info_t dma_info(index_vect, ncols, SIZE_WORD);
	    this->dma_read_ctrl.put(dma_info);
	}

    	for (int i = 0; i < ncols; i++) {

    	    HLS_LOAD_VECT_PLM_READ;

    	    sc_bv<WORD_SIZE> data = this->dma_read_chnl.get();

    	    {
    		HLS_LOAD_VECT_PLM_WRITE;

		VECT0[i] = data.to_int();

    		wait();
    	    }
    	}
    }

    // Load bursts
    for (uint32_t b = 0; b < bursts; b++)
    {
    	HLS_LOAD_INPUT_BATCH_LOOP;

    	// Load row delimiters
    	{
    	    HLS_LOAD_DMA;

    	    dma_info_t dma_info(index_rows, len_rows, SIZE_WORD);
    	    index_rows += len_rows;
    	    this->dma_read_ctrl.put(dma_info);
    	}

    	for (uint16_t i = 0; i < len_rows; i++)
    	{
    	    HLS_LOAD_INPUT_LOOP;

    	    sc_bv<WORD_SIZE> data = this->dma_read_chnl.get();

    	    {
    		HLS_LOAD_ROWS_PLM_WRITE;

    		if (ping)
    		    ROWS0[i] = data.to_int() - rows_last;
    		else
    		    ROWS1[i] = data.to_int() - rows_last;

    		if (i == len_rows - 1) {
    		    rows_last_diff = data.to_int() - rows_last;
    		    rows_last = data.to_int();
    		}

    		wait();
    	    }
    	}

    	// Load matrix values
    	len_vals = rows_last_diff;

    	{
    	    HLS_LOAD_DMA;

    	    dma_info_t dma_info(index_vals, len_vals, SIZE_WORD);
    	    index_vals += len_vals;
    	    this->dma_read_ctrl.put(dma_info);
    	}

    	for (uint16_t i = 0; i < len_vals; i++)
    	{
    	    HLS_LOAD_INPUT_LOOP;

    	    sc_bv<WORD_SIZE> data = this->dma_read_chnl.get();

    	    {
    		HLS_LOAD_VALS_PLM_WRITE;
    		if (ping)
    		    VALS0[i] = data.to_int();
    		else
    		    VALS1[i] = data.to_int();
    		wait();
    	    }
    	}

    	// Load column values
    	len_cols = rows_last_diff;

    	{
    	    HLS_LOAD_DMA;

    	    dma_info_t dma_info(index_cols, len_cols, SIZE_WORD);
    	    index_cols += len_cols;
    	    this->dma_read_ctrl.put(dma_info);
    	}

    	for (uint16_t i = 0; i < len_cols; i++)
    	{
    	    HLS_LOAD_INPUT_LOOP;

    	    sc_bv<WORD_SIZE> data = this->dma_read_chnl.get();

    	    {
    		HLS_LOAD_COLS_PLM_WRITE;

		if (ping | !vect_fits_plm)
		    COLS0[i] = data.to_int();
		else
		    COLS1[i] = data.to_int();

    		wait();
    	    }
    	}

	if (!vect_fits_plm) {
	    // Load vector values based on column values
	    len_vect = rows_last_diff;

	    for (int i = 0; i < len_vect; i++) {

		HLS_LOAD_VECT_PLM_READ;

		uint32_t local_index_vect;

		local_index_vect = index_vect + COLS0[i];

		{
		    HLS_LOAD_DMA;

		    dma_info_t dma_info(local_index_vect, 1, SIZE_WORD);
		    this->dma_read_ctrl.put(dma_info);
		}

		sc_bv<WORD_SIZE> data = this->dma_read_chnl.get();

		{
		    HLS_LOAD_VECT_PLM_WRITE;
		    if (ping)
			VECT0[i] = data.to_int();
		    else
			VECT1[i] = data.to_int();
		    wait();
		}
	    }
	}

    	ping = !ping;
    	this->load_compute_handshake();
    }

    // Conclude
    this->process_done();
}


void spmv::store_output()
{
    /* Local variables */

    // for PLM pingpong
    bool ping;

    // for input configuration
    uint32_t nrows;
    uint32_t ncols;
    uint32_t max_nonzero;
    uint32_t mtx_len;
    uint32_t vals_plm_size;
    bool     vect_fits_plm;

    // for derived configuration
    uint32_t index_out;
    uint32_t len_out;

    // # of bursts evaluation
    uint32_t bursts;

    // Reset
    {
	HLS_STORE_RESET;

	this->reset_store_output();

	ping = true;

	nrows = 0;
	ncols = 0;
	max_nonzero = 0;
	mtx_len = 0;
	vals_plm_size = 0;
	vect_fits_plm = 0;

	index_out = 0;
	len_out = 0;

	bursts = 0;

	wait();
    }

    // Config
    {
    	HLS_STORE_CONFIG;

    	cfg.wait_for_config(); // config process
    	conf_info_t config = this->conf_info.read();

    	nrows = config.nrows;
    	ncols = config.ncols;
    	max_nonzero = config.max_nonzero;
    	mtx_len = config.mtx_len;
	vals_plm_size = config.vals_plm_size;
	vect_fits_plm = config.vect_fits_plm;

    	// DMA index evaluation
    	index_out = nrows + ncols + 2 * mtx_len;

    	// DMA length evaluation
    	len_out = (uint32_t) (vals_plm_size / max_nonzero);

    	// # of bursts evaluation
    	bursts = (uint32_t) ((nrows - 1) / len_out) + 1;
    }

    // Store bursts
    for (uint16_t b = 0; b < bursts; b++)
    {
    	HLS_STORE_OUTPUT_BATCH_LOOP;

    	this->store_compute_handshake();

    	{
    	    HLS_STORE_DMA;

    	    dma_info_t dma_info(index_out, len_out, SIZE_WORD);
    	    index_out += len_out;
    	    this->dma_write_ctrl.put(dma_info);
    	}

    	for (uint16_t i = 0; i < len_out; i++)
    	{
    	    HLS_STORE_OUTPUT_LOOP;

    	    sc_bv<WORD_SIZE> data;

	    float tmp;
	    
    	    {
    		HLS_STORE_OUTPUT_PLM_READ;
    		if (ping)
    		    data = sc_bv<WORD_SIZE>(OUT0[i]);
		else
    		    data = sc_bv<WORD_SIZE>(OUT1[i]);

    		wait();
    	    }
    	    this->dma_write_chnl.put(data);
    	}

	ping = !ping;
    }

    // Conclude
    {
	this->accelerator_done();
	this->process_done();
    }
}


void spmv::compute_kernel()
{
    /* Local variables */

    // for PLM pingpong
    bool ping;

    // for input configuration
    uint32_t nrows;
    uint32_t ncols;
    uint32_t max_nonzero;
    uint32_t mtx_len;
    uint32_t vals_plm_size;
    bool     vect_fits_plm;

    // for derived configuration
    uint32_t index_rows;
    uint32_t index_cols;
    uint32_t index_vals;
    uint32_t index_vect;
    uint32_t index_out;
    uint32_t len_rows;
    uint32_t len_cols;
    uint32_t len_vals;
    uint32_t len_vect;
    uint32_t len_out;

    // # of bursts evaluation
    uint32_t bursts;

    // compute support variables
    uint32_t rows_l;
    uint32_t rows_r;

    // Reset
    {
	HLS_COMPUTE_RESET;

	this->reset_compute_kernel();

	ping = true;

	nrows = 0;
	ncols = 0;
	max_nonzero = 0;
	mtx_len = 0;
	vals_plm_size = 0;
	vect_fits_plm = 0;

	index_rows = 0;
	index_cols = 0;
	index_vals = 0;
	index_vect = 0;
	index_out = 0;
	len_rows = 0;
	len_cols = 0;
	len_vals = 0;
	len_vect = 0;
	len_out = 0;

	bursts = 0;

	rows_l = 0;
	rows_r = 0;

	wait();
    }

    // Config
    {
    	HLS_COMPUTE_CONFIG;

    	cfg.wait_for_config(); // config process
    	conf_info_t config = this->conf_info.read();

    	nrows = config.nrows;
    	ncols = config.ncols;
    	max_nonzero = config.max_nonzero;
    	mtx_len = config.mtx_len;
	vals_plm_size = config.vals_plm_size;
	vect_fits_plm = config.vect_fits_plm;

    	// DMA index evaluation
    	index_rows = 2 * mtx_len;
    	index_cols = mtx_len;
    	index_vals = 0;
    	index_vect = nrows + 2 * mtx_len;
    	index_out = nrows + ncols + 2 * mtx_len;

    	// DMA length evaluation
    	len_rows = (uint32_t) (vals_plm_size / max_nonzero);
    	len_out = len_rows;

    	// # of bursts evaluation
    	bursts = (uint32_t) ((nrows - 1) / len_rows) + 1;
    }

    // Compute
    for (unsigned b = 0; b < bursts; b++) {

    	HLS_COMPUTE_SPMV_LOOP;

    	this->compute_load_handshake();

	rows_l = 0;
	rows_r = 0;

    	for (unsigned r = 0; r < len_rows; r++) {

    	    HLS_COMPUTE_MAIN;

    	    FPDATA sum = FPDATA(0.0);

    	    if (ping)
    		rows_r = ROWS0[r];
    	    else
    		rows_r = ROWS1[r];

    	    for (unsigned c = rows_l; c < rows_r; c++) {

    		HLS_COMPUTE_RW_CHUNK;

    		FPDATA val = FPDATA(0.0);
    		FPDATA vect = FPDATA(0.0);
    		FPDATA dot = FPDATA(0.0);
		uint32_t col;

    		if (ping) {
    		    val = int2fp<FPDATA, WORD_SIZE>(VALS0[c]);

		    if (vect_fits_plm) {
			col = COLS0[c];
			vect = int2fp<FPDATA, WORD_SIZE>(VECT0[col]);
		    } else {
			vect = int2fp<FPDATA, WORD_SIZE>(VECT0[c]);
		    }

    		} else {
    		    val = int2fp<FPDATA, WORD_SIZE>(VALS1[c]);

		    if (vect_fits_plm) {
			col = COLS1[c];
			vect = int2fp<FPDATA, WORD_SIZE>(VECT0[col]);
		    } else {
			vect = int2fp<FPDATA, WORD_SIZE>(VECT1[c]);
		    }
    		}
		
    		dot = val * vect;

    		sum += dot;
    	    }

    	    if (ping)
    		OUT0[r] = fp2int<FPDATA, WORD_SIZE>(sum);
    	    else
    		OUT1[r] = fp2int<FPDATA, WORD_SIZE>(sum);

    	    rows_l = rows_r;
    	}

   	ping = !ping;

    	this->compute_store_handshake();
    }

    // Conclude
    this->process_done();
}
