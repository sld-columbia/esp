// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "system.hpp"
#include <sstream>

// Process
void system_t::config_proc() {

  // Reset
  {
    conf_done.write(false);
    conf_info.write(conf_info_t());
    wait();
  }

  ESP_REPORT_INFO("reset done");

  // Config
  load_memory();
  {
    conf_info_t config;
    config.tokens = 2048;
    config.batch = 1;

    wait();
    conf_info.write(config);
    conf_done.write(true);
  }

  ESP_REPORT_INFO("config done");

  // Compute
  {
    // Print information about begin time
    sc_time begin_time = sc_time_stamp();
    ESP_REPORT_TIME(begin_time, "BEGIN - dummy");

    // Wait the termination of the accelerator
    do {
      wait();
    } while (!acc_done.read());
    debug_info_t debug_code = debug.read();

    // Print information about end time
    sc_time end_time = sc_time_stamp();
    ESP_REPORT_TIME(end_time, "END - dummy");

    esc_log_latency(sc_object::basename(), clock_cycle(end_time - begin_time));
    wait();
    conf_done.write(false);
  }

  // Validate
  {
    out = new uint64_t[MEM_SIZE / DMA_BEAT_PER_WORD];
    dump_memory(); // store the output in more suitable data structure if needed
    // check the results with the golden model
    if (validate()) {
      ESP_REPORT_ERROR("validation failed!");
    } else {
      ESP_REPORT_INFO("validation passed!");
    }
    delete[] out;
  }

  // Conclude
  { sc_stop(); }
}

// Functions
void system_t::load_memory() {
  //  Memory initialization:
  //  ==============  ^
  //  |  in data   |  | batch * tokens * sizeof(uint64_t)
  //  ==============  v
  //  ==============  ^
  //  |  out data  |  | batch * tokens * sizeof(uint64_t)
  //  ==============  v

#if (DMA_WORD_PER_BEAT == 0)
  for (int i = 0; i < MEM_SIZE / DMA_BEAT_PER_WORD; i++) {
    uint64_t data = 0xfeed0bac00000000L | (uint64_t)i;
    sc_dt::sc_bv<64> data_bv(data);

    for (int j = 0; j < DMA_BEAT_PER_WORD; j++) {
      mem[DMA_BEAT_PER_WORD * i + j] =
          data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
  }
#else
  for (int i = 0; i < MEM_SIZE / DMA_WORD_PER_BEAT; i++) {
    sc_dt::sc_bv<DMA_WIDTH> data_bv;
    for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
      uint64_t data = 0xfeed0bac00000000L | (uint64_t)i * DMA_WORD_PER_BEAT + j;
      data_bv.range((j + 1) * 64 - 1, j * 64) = data;
    }
    mem[i] = data_bv;
  }
#endif
  ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory() {
  // Get results from memory
#if (DMA_WORD_PER_BEAT == 0)
  for (int i = 0; i < MEM_SIZE / DMA_BEAT_PER_WORD; i++) {
    sc_dt::sc_bv<64> data_bv;

    for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
      data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) =
          mem[DMA_BEAT_PER_WORD * i + j];

    out[i] = data_bv.to_uint64();
  }
#else
  for (int i = 0; i < MEM_SIZE / DMA_WORD_PER_BEAT; i++) {
    sc_dt::sc_bv<64> data_bv;
    for (int j = 0; j < DMA_WORD_PER_BEAT; j++) {
      data_bv = mem[i].range((j + 1) * 64 - 1, j * 64);
      out[i * DMA_WORD_PER_BEAT + j] = data_bv.to_uint64();
    }
  }
#endif

  ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate() {
  uint32_t errors = 0;

  // Check for mismatches
  for (int i = 0; i < 2048; i++)
    if (out[i] != (0xfeed0bac00000000L | (uint64_t)i)) {
      std::cout << i << ": 0x" << std::hex << out[i] << std::dec << std::endl;
      errors++;
    }

  return errors;
}
