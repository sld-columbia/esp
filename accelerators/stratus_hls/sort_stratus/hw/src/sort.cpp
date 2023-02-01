// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "sort.hpp"
#include "sort_directives.hpp"

// Functions

#include "sort_functions.hpp"

// Processes

void sort::load_input()
{
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch
	unsigned index;

	// Reset
	{
		HLS_LOAD_RESET;

		this->reset_load_input();

 		index = 0;
		len = 0;
		bursts = 0;

		ping = true;
		wait();
	}

	// Config
	{
		HLS_LOAD_CONFIG;

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}

	// Load
	{
		for (uint16_t b = 0; b < bursts; b++)
		{
			HLS_LOAD_INPUT_BATCH_LOOP;

			{
				HLS_LOAD_DMA;

				dma_info_t dma_info(index / (DMA_WIDTH / 32), len / (DMA_WIDTH / 32), SIZE_WORD);
				index += len;
				this->dma_read_ctrl.put(dma_info);
			}
#if (DMA_WIDTH == 32)
			for (uint16_t i = 0; i < len; i++)
			{
				HLS_LOAD_INPUT_LOOP;

				uint32_t data = this->dma_read_chnl.get().to_uint();
				{
					HLS_LOAD_INPUT_PLM_WRITE;
					if (ping)
						A0[i] = data;
					else
						A1[i] = data;
					wait();
				}
#elif (DMA_WIDTH == 64)
			for (uint16_t i = 0; i < len; i += 2)
			{
				HLS_LOAD_INPUT_LOOP;

				sc_dt::sc_bv<64> data_bv = this->dma_read_chnl.get();
				{
					HLS_LOAD_INPUT_PLM_WRITE;
					uint32_t data_1 = data_bv.range(31, 0).to_uint();
					uint32_t data_2 = data_bv.range(63, 32).to_uint();
					if (ping) {
						A0[i] = data_1;
						A0[i + 1] = data_2;
					} else {
						A1[i] = data_1;
						A1[i + 1] = data_2;
					}
					wait();
				}
#endif
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



void sort::store_output()
{
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch
	unsigned index;

	// Reset
	{
		HLS_STORE_RESET;

		this->reset_store_output();

 		index = 0;
		len = 0;
		bursts = 0;

		ping = true;
		wait();
	}

	// Config
	{
		HLS_STORE_CONFIG;

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}

	// Store
	{
		for (uint16_t b = 0; b < bursts; b++)
		{
			HLS_STORE_OUTPUT_BATCH_LOOP;

			this->store_compute_handshake();

			{
				HLS_STORE_DMA;

				dma_info_t dma_info(index / (DMA_WIDTH / 32), len / (DMA_WIDTH / 32), SIZE_WORD);
				index += len;
				this->dma_write_ctrl.put(dma_info);
			}
#if (DMA_WIDTH == 32)
			for (uint16_t i = 0; i < len; i++)
			{
				HLS_STORE_OUTPUT_LOOP;

				uint32_t data;
				{
					HLS_STORE_OUTPUT_PLM_READ;
					if (ping)
						data = B0[i];
					else
						data = B1[i];
					wait();
				}
				this->dma_write_chnl.put(data);
#elif (DMA_WIDTH == 64)
			for (uint16_t i = 0; i < len; i += 2)
			{
				HLS_STORE_OUTPUT_LOOP;

				sc_dt::sc_bv<64> data_bv;
				{
					HLS_STORE_OUTPUT_PLM_READ;
					if (ping) {
						data_bv.range(31, 0)  = B0[i];
						data_bv.range(63, 32) = B0[i + 1];
					} else {
						data_bv.range(31, 0)  = B1[i];
						data_bv.range(63, 32) = B1[i + 1];
					}
					wait();
				}
				this->dma_write_chnl.put(data_bv);
#endif
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


void sort::compute_kernel()
{
	// Bi-tonic sort
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch

	// Reset
	{
		HLS_RB_RESET;

		this->reset_compute_1_kernel();

		len = 0;
		bursts = 0;

		ping = true;
		wait();
	}

	// Config
	{
		HLS_RB_CONFIG;

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}


	// Compute
	{
	for (uint16_t b = 0; b < bursts; b++)
	{
		HLS_RB_SORT_LOOP;

		this->compute_load_handshake();

		// Flatten array
		unsigned regs[NUM];
		HLS_RB_MAP_REGS;

		uint8_t wchunk = 0;

		// Break the following
		for (uint16_t chunk = 0; chunk < LEN / NUM; chunk++)
		{
			HLS_RB_MAIN;

			if (chunk * NUM == len)
				break;

			//Break the following
			for (uint8_t i = 0; i < NUM; i++)
			{
				HLS_RB_RW_CHUNK;

				unsigned elem;
				if (ping)
				{
					elem = A0[chunk * NUM + i];
					C0[wchunk][i] = regs[i];
				}
				else
				{
					elem = A1[chunk * NUM + i];
					C1[wchunk][i] = regs[i];
				}
				regs[i] = elem;
			}
			if (chunk != 0)
				wchunk++;

			//Break the following
			for (uint8_t k = 0; k < NUM; k++)
			{
				HLS_RB_INSERTION_OUTER;
				//Unroll the following
				for (uint8_t i = 0; i < NUM; i += 2)
				{
					HLS_RB_INSERTION_EVEN;
					if (!lt_float(regs[i], regs[i + 1]))
					{
						unsigned tmp = regs[i];
						regs[i]      = regs[i + 1];
						regs[i + 1]  = tmp;
					}
				}

				//Unroll the following
				for (uint8_t i = 1; i < NUM - 1; i += 2)
				{
					HLS_RB_INSERTION_ODD;
					if (!lt_float(regs[i], regs[i + 1]))
					{
						unsigned tmp = regs[i];
						regs[i]      = regs[i + 1];
						regs[i + 1]  = tmp;
					}
				}
			}
		}

		{
			HLS_RB_BREAK_FALSE_DEP;
		}

		for (uint8_t i = 0; i < NUM; i++)
		{
			HLS_RB_W_LAST_CHUNKS_INNER;
			uint32_t elem = regs[i];
			if (ping)
				C0[wchunk][i] = elem;
			else
				C1[wchunk][i] = elem;
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


void sort::compute_2_kernel()
{
	// Bi-tonic sort
	bool ping;
	unsigned len; // from conf_info.len
	unsigned bursts; // from conf_info.batch

	// Reset
	{
		HLS_MERGE_RESET;

		this->reset_compute_2_kernel();

		len = 0;
		bursts = 0;

		ping = true;
		wait();
	}

	// Config
	{
		HLS_MERGE_CONFIG;

		cfg.wait_for_config(); // config process
		conf_info_t config = this->conf_info.read();
		len = config.len;
		bursts = config.batch;
	}


	// Compute
	const uint8_t chunk_max = (uint8_t) (len >> lgNUM);
	{
	for (uint16_t b = 0; b < bursts; b++)
	{
		HLS_MERGE_SORT_LOOP;
		unsigned head[LEN / NUM];  // Fifo output
		unsigned fidx[LEN / NUM];  // Fifo index
		bool pop_array[32];
		sc_dt::sc_bv<32> pop_bv(0);
		unsigned pop;              // pop from ith fifo
		bool shift_array[32];
		sc_dt::sc_bv<32> shift_bv(0);
		unsigned shift;            // shift from ith fifo
		unsigned regs[LEN / NUM];  // State
		unsigned regs_in[LEN / NUM]; // Next state
		HLS_MERGE_SORT_MAP_REGS;

		//Should not be a combinational loop. BTW unroll.
		for (uint8_t i = 0; i < LEN / NUM; i++)
		{
			HLS_MERGE_INIT_ZERO_FIDX;

			fidx[i] = 0;
			shift_array[i] = false;
			pop_array[i] = false;
		}

		this->compute_2_compute_handshake();

		if (chunk_max > 1)  //MERGE is needed
		{

			//Break the following
			for (uint8_t chunk = 0; chunk < LEN / NUM; chunk++)
			{
				HLS_MERGE_RD_FIRST_ELEMENTS;

				unsigned elem;
				if (ping)
					elem = C0[chunk][0];
				else
					elem = C1[chunk][0];

				if (chunk < chunk_max) {
					head[chunk] = elem;
					fidx[chunk]++;
				}
			}

			regs[0] = head[0];
			{
				HLS_MERGE_RD_NEXT_ELEMENT;
				if (ping)
					head[0] = C0[0][1];
				else
					head[0] = C1[0][1];
			}
			fidx[0]++;

			uint8_t cur = 2;
			uint16_t cnt = 0;
			//Break the following
			while(true)
			{
				HLS_MERGE_MAIN;
				//Unroll the following
				for (uint8_t chunk = 1; chunk < LEN / NUM; chunk++)
				{
					HLS_MERGE_COMPARE;

					if ((chunk < cur) && !lt_float(regs[chunk - 1], head[chunk]))
						shift_array[chunk] = 1;
				}
				for (uint8_t chunk = 0; chunk < LEN / NUM; chunk++)
				{
					HLS_MERGE_SHIFT_ARRAY;

						shift_bv[chunk] = shift_array[chunk];
				}
				shift = shift_bv.to_uint();

				const int DeBruijn32[32] =
					{
						0, 1, 28, 2, 29, 14, 24, 3,
						30, 22, 20, 15, 25, 17, 4, 8,
						31, 27, 13, 23, 21, 19, 16, 7,
						26, 12, 18, 6, 11, 5, 10, 9
					};
				HLS_MERGE_DEBRUIJN32;

				sc_dt::sc_bv<32> shift_rev_bv;
				//Unroll the following
				for (uint8_t i = 0; i < 32; i++) {
					HLS_MERGE_SHIFT_REV;

					const uint8_t index_rev = 31 - i;
					shift_rev_bv[index_rev] = shift_bv[i];
				}
				unsigned shift_rev = shift_rev_bv.to_uint();
				unsigned shift_msb;
				{
					int v = shift_rev;
					shift_msb = 31 - DeBruijn32[((unsigned)((v & -v) * 0x077CB531U)) >> 27];
					shift_msb = shift != 0 ? shift_msb : 0;
				}

				regs_in[0] = regs[0];
				//Unroll the following
				for (uint8_t chunk =  LEN / NUM - 1; chunk > 1; chunk--)
				{
					HLS_MERGE_SHIFT;

					const uint32_t mask = 1 << chunk;
					if (chunk < cur && chunk >= shift_msb) {
						if (shift & mask)
						{
							regs_in[chunk] = head[chunk];
							pop_array[chunk] = 1;
						}
						else
						{
							regs_in[chunk] = regs[chunk - 1];
						}
					}
				}

				if (shift_msb <= 1) {
					if (shift & 2)
					{
						regs_in[1] = head[1];
						pop_array[1]  = 1;
					}
					else
					{
						regs_in[1] = regs[0];
						regs_in[0] = head[0];
						pop_array[0]  = 1;
					}
				}

				for (uint8_t chunk = 0; chunk < LEN / NUM; chunk++)
				{
					HLS_MERGE_POP_ARRAY;

						pop_bv[chunk] = pop_array[chunk];
				}
				pop = pop_bv.to_uint();

				//Unroll the following
				for (uint8_t chunk = 0; chunk < LEN / NUM; chunk++)
				{
					HLS_MERGE_SEQ;

					if (chunk < cur)
						regs[chunk] = regs_in[chunk];
				}

				if (cur == chunk_max)
				{
					HLS_MERGE_WR_LAST_ELEMENTS;
					// write output
					if (ping)
						B0[cnt] = regs[chunk_max - 1];
					else
						B1[cnt] = regs[chunk_max - 1];
					cnt++;
				}

				//Notice that only one pop[i] will be true at any time
				int pop_idx = -1;
				{
					unsigned pop_msb;
					int v = pop;
					pop_msb = DeBruijn32[((unsigned)((v & -v) * 0x077CB531U)) >> 27];
					pop_idx = pop != 0 ? pop_msb : -1;
				}


				if (pop_idx != -1)
					if (fidx[pop_idx] >= NUM) {
						head[pop_idx] = 0x7f800000; // +INF
						pop_idx = -1;
					}

				if (pop_idx != -1)
				{
					HLS_MERGE_DO_POP;
					if (ping)
						head[pop_idx] = C0[pop_idx][fidx[pop_idx]];
					else
						head[pop_idx] = C1[pop_idx][fidx[pop_idx]];
					fidx[pop_idx]++;
				}

				for (uint8_t chunk = 0; chunk < LEN / NUM; chunk++)
				{
					HLS_MERGE_ZERO;
					shift_array[chunk] = false;
					pop_array[chunk] = false;
				}

				// DEBUG
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
			for (uint8_t chunk = 0; chunk < LEN / NUM; chunk++)
			{
				HLS_MERGE_NO_MERGE_OUTER;
				if (chunk == chunk_max)
					break;

				for (uint8_t i = 0; i < NUM; i++)
				{
					HLS_MERGE_NO_MERGE_INNER;

					unsigned elem;
					{
						if (ping)
							elem = C0[chunk][i];
						else
							elem = C1[chunk][i];
					}
					{
						if (ping)
							B0[i] = elem;
						else
							B1[i] = elem;
					}
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
