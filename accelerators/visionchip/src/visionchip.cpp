// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#include "visionchip.hpp"
#include "visionchip_directives.hpp"

// Functions

#include "visionchip_functions.cpp"

// Processes

void visionchip::load_input()
{
	uint32_t n_Rows;
	uint32_t n_Cols;

	// Reset
	{
		HLS_DEFINE_PROTOCOL("load-reset");

		this->reset_load_input();

		// PLM memories reset
		mem_buff_1.port2.reset();

		// User-defined reset code
		n_Rows = 0;
		n_Cols = 0;

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("load-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();

		// User-defined config code
		n_Rows = config.n_Rows;
		n_Cols = config.n_Cols;
	}

	// Load
	{
		uint32_t curr_addr = 0; 

		for (uint16_t b = 0; b < n_Rows; b++)
		{
			HLS_LOAD_INPUT_BATCH_LOOP;

			{
				HLS_DEFINE_PROTOCOL("load-dma-conf");

				// Configure DMA transaction
				dma_info_t dma_info(curr_addr, n_Cols);

				this->dma_read_ctrl.put(dma_info);
			}

			for (uint16_t i = curr_addr; i < (curr_addr + n_Cols); i++)
			{
				HLS_LOAD_INPUT_LOOP;

				int32_t data = this->dma_read_chnl.get().to_int();
				{
					HLS_LOAD_INPUT_PLM_WRITE;

					// Write to PLM
					mem_buff_1.port2[0][i] = data;
				}
			}

			curr_addr += n_Cols;
		}
		this->load_compute_handshake();
	}

	// Conclude
	{
		this->process_done();
	}
}



void visionchip::store_output()
{
	uint32_t n_Rows;
	uint32_t n_Cols;

	// Reset
	{
		HLS_DEFINE_PROTOCOL("store-reset");

		this->reset_store_output();

		// PLM memories reset
		mem_buff_1.port4.reset();

		// User-defined reset code
		n_Rows = 0;
		n_Cols = 0;

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("store-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();

		// User-defined config code
		n_Rows = config.n_Rows;
		n_Cols = config.n_Cols;
	}

	// Store
	{
		this->store_compute_handshake();

		uint32_t curr_addr = 0;

		for (uint16_t b = 0; b < n_Rows; b++)
		{
			HLS_STORE_OUTPUT_BATCH_LOOP;

			{
				HLS_DEFINE_PROTOCOL("store-dma-conf");

				// Configure DMA transaction
				dma_info_t dma_info(curr_addr, n_Cols);

				this->dma_write_ctrl.put(dma_info);
			}
			for (uint16_t i = curr_addr; i < (curr_addr + n_Cols); i++)
			{
				HLS_STORE_OUTPUT_LOOP;

				sc_bv<WORD_SIZE> data;
				{
					HLS_STORE_OUTPUT_PLM_READ;
					// Read from PLM
					data = sc_bv<WORD_SIZE>(mem_buff_1.port4[0][i]);
				}
				this->dma_write_chnl.put(data);
			}
			curr_addr += n_Cols;
		}
	}

	// Conclude
	{
		this->accelerator_done();
		this->process_done();
	}
}


void visionchip::compute_kernel()
{
	uint32_t n_Rows;
	uint32_t n_Cols;

	// Reset
	{
		HLS_DEFINE_PROTOCOL("compute-reset");

		this->reset_compute_kernel();

		// PLM memories reset
		mem_buff_1.port1.reset();
		mem_buff_1.port3.reset();
		mem_buff_2.port1.reset();
		mem_buff_2.port2.reset();

		mem_hist.port1.reset();
		mem_hist.port2.reset();

		mem_CDF.port1.reset();
		mem_CDF.port2.reset();

		mem_LUT.port1.reset();
		mem_LUT.port2.reset();

		// User-defined reset code
		n_Rows = 0;
		n_Cols = 0;

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("compute-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();

		// User-defined config code
		n_Rows = config.n_Rows;
		n_Cols = config.n_Cols;
	}


	// Compute
	{
		this->compute_load_handshake();

		// Computing phase implementation
		kernel_nf(n_Rows, n_Cols);
		kernel_hist(n_Rows, n_Cols);
		kernel_histEq(n_Rows, n_Cols);
		kernel_dwt(n_Rows, n_Cols);

		this->compute_store_handshake();

		// Conclude
		{
			this->process_done();
		}
	}
}
