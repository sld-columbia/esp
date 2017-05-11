/* Copyright 2017 Columbia University, SLD Group */

#include "<accelerator_name>.hpp"
#include "<accelerator_name>_directives.hpp"

// Functions

#include "<accelerator_name>_functions.cpp"

// Processes

void <accelerator_name>::load_input()
{

	// Reset
	{
		HLS_DEFINE_PROTOCOL("load-reset");

		this->reset_load_input();

		// PLM memories reset

		// User-defined reset code

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("load-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();

		// User-defined config code
	}

	// Load
	{
		for (uint16_t b = 0; b < /* number of transfers */; b++)
		{
			HLS_LOAD_INPUT_BATCH_LOOP;

			{
				HLS_DEFINE_PROTOCOL("load-dma-conf");

				dma_info_t dma_info;
				// Configure DMA transaction

				this->dma_read_ctrl.put(dma_info);
			}

			for (uint16_t i = 0; i < /* transfer lenght */; i++)
			{
				HLS_LOAD_INPUT_LOOP;

				uint32_t data = this->dma_read_chnl.get().to_uint();
				{
					HLS_LOAD_INPUT_PLM_WRITE;
					// Write to PLM
				}
			}
			this->load_compute_handshake();
		}
	}

	// Conclude
	{
		this->process_done();
	}
}



void <accelerator_name>::store_output()
{
	// Reset
	{
		HLS_DEFINE_PROTOCOL("store-reset");

		this->reset_store_output();

		// PLM memories reset

		// User-defined reset code

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("store-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();

		// User-defined config code
	}

	// Store
	{
		for (uint16_t b = 0; b < /* number of transfers */; b++)
		{
			HLS_STORE_OUTPUT_BATCH_LOOP;

			this->store_compute_handshake();

			{
				HLS_DEFINE_PROTOCOL("store-dma-conf");

				dma_info_t dma_info;
				// Configure DMA transaction

				this->dma_write_ctrl.put(dma_info);
			}
			for (uint16_t i = 0; i < /* transfer lenght */; i++)
			{
				HLS_STORE_OUTPUT_LOOP;

				uint32_t data;
				{
					HLS_STORE_OUTPUT_PLM_READ;
					// Read from PLM
				}
				this->dma_write_chnl.put(data);
			}
		}
	}

	// Conclude
	{
		this->accelerator_done();
		this->process_done();
	}
}


void <accelerator_name>::compute_kernel()
{
	// Reset
	{
		HLS_DEFINE_PROTOCOL("compute-reset");

		this->reset_compute_1_kernel();

		// PLM memories reset

		// User-defined reset code

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("compute-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();

		// User-defined config code
	}


	// Compute
	{
		for (uint16_t b = 0; b < /* number of transfers */; b++)
		{
			this->compute_load_handshake();

			// Computing phase implementation

			this->compute_store_handshake();
		}

		// Conclude
		{
			this->process_done();
		}
	}
}
