/* Copyright 2017 Columbia University, SLD Group */

#include "sort.hpp"

// Functions

#include "sort_functions.cpp"

// Processes

template <
	size_t DMA_WIDTH
	>
void sort<DMA_WIDTH>::load_input()
{
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch
	unsigned index;

	// Reset
	{
		HLS_DEFINE_PROTOCOL("load-reset");

		this->reset_load_input();

 		index = 0;
		len = 0;
		bursts = 0;

		ping = true;
		A0.port1.reset();
		A1.port1.reset();

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("load-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}

	// Load
	{
	LOAD_INPUT_BATCH_LOOP:
		for (uint16_t b = 0; b < bursts; b++)
		{
			HLS_UNROLL_LOOP(OFF); // disabled by default

			{
				HLS_DEFINE_PROTOCOL("load-dma-conf");

				dma_info_t dma_info(index, len);
				index += len;
				this->dma_read_ctrl.put(dma_info);
			}
		LOAD_INPUT_LOOP:
			for (uint16_t i = 0; i < len; i++)
			{
				HLS_UNROLL_LOOP(OFF); // disabled by default

				uint32_t data = this->dma_read_chnl.get().to_uint();

				if (ping)
					A0.port1[0][i] = data;
				else
					A1.port1[0][i] = data;
			}
			ping = !ping;
			this->load_compute_handshake();
		}
	}

	// Conclude
	{
		this->process_done();
	}
}



template <
	size_t DMA_WIDTH
	>
void sort<DMA_WIDTH>::store_output()
{
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch
	unsigned index;

	// Reset
	{
		HLS_DEFINE_PROTOCOL("store-reset");

		this->reset_store_output();

 		index = 0;
		len = 0;
		bursts = 0;

		ping = true;
		B0.port2.reset();
		B1.port2.reset();

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("store-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}

	// Store
	{
	STORE_INPUT_BATCH_LOOP:
		for (uint16_t b = 0; b < bursts; b++)
		{
			HLS_UNROLL_LOOP(OFF); // disabled by default

			this->store_compute_handshake();

			{
				HLS_DEFINE_PROTOCOL("store-dma-conf");

				dma_info_t dma_info(index, len);
				index += len;
				this->dma_write_ctrl.put(dma_info);
			}
		STORE_INPUT_LOOP:
			for (uint16_t i = 0; i < len; i++)
			{
				HLS_UNROLL_LOOP(OFF); // disabled by default

				uint32_t data;
				if (ping)
					data = B0.port2[0][i];
				else
					data = B1.port2[0][i];
				this->dma_write_chnl.put(data);
			}
			ping = !ping;
		}
	}

	// Conclude
	{
		this->accelerator_done();
		this->process_done();
	}
}


template <
	size_t DMA_WIDTH
	>
void sort<DMA_WIDTH>::compute_kernel()
{
	// Bi-tonic sort
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch

	// Reset
	{
		HLS_DEFINE_PROTOCOL("compute-reset");

		this->reset_compute_1_kernel();

		len = 0;
		bursts = 0;

		ping = true;
		A0.port2.reset();
		A1.port2.reset();
		C0.port1.reset();
		C1.port1.reset();

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("compute-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}


	// Compute
	{
BITONIC_SORT:
	for (uint16_t b = 0; b < bursts; b++)
	{
		HLS_UNROLL_LOOP(OFF);
		this->compute_load_handshake();

		// Flatten array
		unsigned regs[2][NUM];
		HLS_FLATTEN_ARRAY(regs);
		bool pipe_full = false;
		unsigned wchunk = 0;

		// Break the following
	RB_MAIN:
		for (int chunk = 0; chunk < LEN / NUM; )
		{
			HLS_UNROLL_LOOP(OFF);

			if ((unsigned) chunk * NUM == len)
				break;

			// Unroll the following
		RB_CHAIN_SELECT:
			for (int idx = 0; idx < 2; idx++, chunk++)
			{
				HLS_UNROLL_LOOP(ON);

				if ((unsigned) chunk * NUM == len)
					break;

				//Break the following
			RB_RW_CHUNK:
				for (int i = 0; i < NUM; i++)
				{
					HLS_UNROLL_LOOP(OFF);

					unsigned elem;
					if (ping)
					{
						elem = A0.port2[0][chunk * NUM + i];
						if (pipe_full)
							C0.port1[0][wchunk * NUM + i] = regs[idx][i];
					}
					else
					{
						elem = A1.port2[0][chunk * NUM + i];
						if (pipe_full)
							C1.port1[0][wchunk * NUM + i] = regs[idx][i];
					}
					regs[idx][i] = elem;
				}
				if (pipe_full)
					wchunk++;

				//Break the following
			RB_INSERTION_OUTER:
				for (int k = 0; k < NUM; k++)
				{
					HLS_UNROLL_LOOP(OFF);
					//Unroll the following
				RB_INSERTION_EVEN:
					for (int i = 0; i < NUM; i += 2)
					{
						HLS_UNROLL_LOOP(ON);
						if (!lt_float(regs[idx][i], regs[idx][i + 1]))
						{
							unsigned tmp   = regs[idx][i];
							regs[idx][i]   = regs[idx][i + 1];
							regs[idx][i + 1] = tmp;
						}
					}

					//Unroll the following
				RB_INSERTION_ODD:
					for (int i = 1; i < NUM - 1; i += 2)
					{
						HLS_UNROLL_LOOP(ON);
						if (!lt_float(regs[idx][i], regs[idx][i + 1]))
						{
							unsigned tmp   = regs[idx][i];
							regs[idx][i]   = regs[idx][i + 1];
							regs[idx][i + 1] = tmp;
						}
					}
				}
			}
			pipe_full = true;
		}

		// for (int i = 0; i < NUM; i++)
		//    cout << i << ": " << std::hex << regs[0][i] << std::dec << endl;
		// cout << pipe_full << " " << wchunk << endl;

		//Break the following
	RB_W_LAST_CHUNKS_OUTER:
		for (int idx = 0; idx < 2; idx++)
		{
			if ((unsigned) idx * NUM == len)
				break;

		RB_W_LAST_CHUNKS_INNER:
			for (int i = 0; i < NUM; i++)
			{
				if (ping)
					C0.port1[0][wchunk * NUM + i] = regs[idx][i];
				else
					C1.port1[0][wchunk * NUM + i] = regs[idx][i];
			}
			wchunk++;
		}

		ping = !ping;

		this->compute_compute_2_handshake();
	}

	// Conclude
	{
		this->process_done();
	}
	}
}


template <
	size_t DMA_WIDTH
	>
void sort<DMA_WIDTH>::compute_2_kernel()
{
	// Bi-tonic sort
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch

	// Reset
	{
		HLS_DEFINE_PROTOCOL("compute-2-reset");

		this->reset_compute_2_kernel();

		len = 0;
		bursts = 0;

		ping = true;
		C0.port2.reset();
		C1.port2.reset();
		B0.port1.reset();
		B1.port1.reset();

		wait();
	}

	// Config
	{
		HLS_DEFINE_PROTOCOL("compute-2-config");

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}


	// Compute
	const unsigned chunk_max = (len >> lgNUM);
	{
MERGE_SORT:
	for (uint16_t b = 0; b < bursts; b++)
	{
		unsigned head[LEN / NUM];  // Fifo output
		unsigned fidx[LEN / NUM];  // Fifo index
		bool     pop[LEN / NUM];   // pop from ith fifo
		bool     shift[LEN / NUM];   // shift from ith fifo
		unsigned regs[LEN / NUM];  // State
		unsigned regs_in[LEN / NUM]; // Next state
		HLS_FLATTEN_ARRAY(head);
		HLS_FLATTEN_ARRAY(fidx);
		HLS_FLATTEN_ARRAY(pop);
		HLS_FLATTEN_ARRAY(shift);
		HLS_FLATTEN_ARRAY(regs);
		HLS_FLATTEN_ARRAY(regs_in);

		//Should not be a combinational loop. BTW unroll.
	INIT_ZERO_FIDX:
		for (int i = 0; i < LEN / NUM; i++)
		{
			HLS_UNROLL_LOOP(ON);

			fidx[i] = 0;
			pop[i] = false;
			shift[i] = false;
		}

		this->compute_2_compute_handshake();

		if (chunk_max > 1)  //MERGE is needed
		{
			//DEBUG
			// for (int chunk = 0; chunk < LEN/NUM; chunk++) {
			//    if (chunk*NUM == len)
			//       break;
			//    cout << "CHUNK: " << chunk << endl;
			//    for (int i = 0; i < NUM; i++) {
			//       if (ping)
			//          cout << std::hex << C0[chunk][i] << " ";
			//       else
			//          cout << std::hex << C1[chunk][i] << " ";
			//    }
			//    cout << std::dec << endl << endl;
			// }

			//Break the following
		MERGE_RD_FIRST_ELEMENTS:
			for (int chunk = 0; chunk < LEN / NUM; chunk++)
			{
				if ((unsigned) chunk == chunk_max)
					break;
				if (ping)
					head[chunk] = C0.port2[0][chunk * NUM];
				else
					head[chunk] = C1.port2[0][chunk * NUM];

				fidx[chunk]++;
			}

			regs[0] = head[0];
			if (ping)
				head[0] = C0.port2[0][1];
			else
				head[0] = C1.port2[0][1];
			fidx[0]++;

			//DEBUG
			// cout << "INIT HEADS" << endl;
			// for (int chunk = 0; chunk < LEN/NUM; chunk++) {
			//    if (chunk == chunk_max)
			//       break;
			//    cout << chunk << ": " << std::hex << head[chunk] << "; ";
			// }
			// cout << std::dec << endl << endl;

			unsigned cur = 2;
			unsigned cnt = 0;
			//Break the following
		MERGE_MAIN:
			while(true)
			{
				HLS_UNROLL_LOOP(OFF);
				//Unroll the following
			MERGE_COMPARE:
				for (int chunk = 1; chunk < LEN / NUM; chunk++)
				{
					HLS_UNROLL_LOOP(ON);

					if ((unsigned) chunk == cur)
						break;
					if (lt_float(regs[chunk - 1], head[chunk]))
						shift[chunk] = true;
					else
						shift[chunk] = false;
				}

				regs_in[0] = regs[0];
				//Unroll the following
			MERGE_SHIFT:
				for (int chunk = LEN / NUM - 1; chunk > 0; chunk--)
				{
					HLS_UNROLL_LOOP(ON);

					if ((unsigned) chunk >= cur)
						continue;

					if (shift[chunk])
					{
						regs_in[chunk] = regs[chunk - 1];
						if (chunk == 1)
						{
							regs_in[0] = head[0];
							pop[0] = true;
						}
					}
					else
					{
						regs_in[chunk] = head[chunk];
						pop[chunk] = true;
						break;
					}
				}

				//DEBUG:
				// cout << "POP from...";
				// for (int chunk = 0; chunk < LEN/NUM; chunk++) {
				//    if (chunk == chunk_max)
				//       break;
				//    cout << " " << pop[chunk];
				// }
				// cout << endl;

				//Unroll the following
			MERGE_SEQ:
				for (int chunk = 0; chunk < LEN / NUM; chunk++)
				{
					HLS_UNROLL_LOOP(ON);

					if ((unsigned) chunk == cur)
						break;
					regs[chunk] = regs_in[chunk];
				}

				//DEBUG
				// cout << "regs after shift: ";
				// for (int chunk = 0; chunk < LEN/NUM; chunk++) {
				//    if (chunk == chunk_max)
				//       break;
				//    cout << chunk << ": " << std::hex << regs[chunk] << "; ";
				// }
				// cout << endl;
				// cout << "heads after shift: ";
				// for (int chunk = 0; chunk < LEN/NUM; chunk++) {
				//    if (chunk == chunk_max)
				//       break;
				//    cout << chunk << ": " << std::hex << head[chunk] << "; ";
				// }
				// cout << std::dec << endl;

				if (cur == chunk_max)
				{
					// write output
					if (ping)
						B0.port1[0][cnt] = regs[chunk_max - 1];
					else
						B1.port1[0][cnt] = regs[chunk_max - 1];
					cnt++;
				}

				int pop_idx = -1;
				//Unroll the following
				//Notice that only one pop[i] will be true at any time
			MERGE_DO_POP:
				for (int chunk = 0; chunk < LEN / NUM; chunk++)
				{
					HLS_UNROLL_LOOP(ON);

					if ((unsigned) chunk == cur)
						break;
					if (pop[chunk])
					{
						if (fidx[chunk] < NUM)
						{
							pop_idx = chunk;
						}
						else
						{
							head[chunk] = 0x7f800000; // +INF
						}
						pop[chunk] = false;
						break;
					}
				}

				if (pop_idx != -1)
				{
					if (ping)
						head[pop_idx] = C0.port2[0][pop_idx * NUM + fidx[pop_idx]];
					else
						head[pop_idx] = C1.port2[0][pop_idx * NUM + fidx[pop_idx]];
					fidx[pop_idx]++;
				}

			RESTORE_ZERO_POP:
				for (int i = 0; i < LEN / NUM; i++)
				{
					HLS_UNROLL_LOOP(ON);

					pop[i] = false;
					shift[i] = false;
				}

				//DEBUG
				// cout << "heads after pop: ";
				// for (int chunk = 0; chunk < LEN/NUM; chunk++) {
				//    if (chunk == chunk_max)
				//       break;
				//    cout << chunk << ": " << std::hex << head[chunk] << "; ";
				// }
				// cout << std::dec << endl << endl;

				if (cur < chunk_max)
					cur++;

				if (cnt == len)
					break;
			}
		}
		else     // MERGE is not required
		{
			for (int chunk = 0; chunk < LEN / NUM; chunk++)
			{
				if ((unsigned) chunk == chunk_max)
					break;

				for (int i = 0; i < NUM; i++)
				{
					unsigned elem;
					if (ping)
						elem = C0.port2[0][chunk * NUM + i];
					else
						elem = C1.port2[0][chunk * NUM + i];
					wait();
					if (ping)
						B0.port1[0][i] = elem;
					else
						B1.port1[0][i] = elem;
				}
			}
		}
		ping = !ping;

		this->compute_store_handshake();
	}

	// Conclude
	{
		this->process_done();
	}
	}
}
