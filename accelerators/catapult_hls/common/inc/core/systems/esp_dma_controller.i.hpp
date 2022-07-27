// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

// Processes

template <
    int _DMA_WIDTH_,
    int _MEM_SIZE_
    >
void esp_dma_controller<_DMA_WIDTH_, _MEM_SIZE_>::read()
{
    dma_read_ctrl.Reset();
    dma_read_chnl.Reset();

    wait();

    while(1) {
        // Read request
        dma_info_t dma_info_r=dma_read_ctrl.Pop();

        uint32_t mem_base = dma_info_r.index;
        uint32_t burst_size = dma_info_r.length;

        dma_read(mem_base, burst_size);

    }

}


template <
    int _DMA_WIDTH_,
    int _MEM_SIZE_
    >
void esp_dma_controller<_DMA_WIDTH_, _MEM_SIZE_>::write()
{
    dma_write_ctrl.Reset();
    dma_write_chnl.Reset();

    wait();

    while(1) {
        // Write request
        dma_info_t dma_info_w=dma_write_ctrl.Pop();

        uint32_t mem_base = dma_info_w.index;
        uint32_t burst_size = dma_info_w.length;

        num_of_write_burst++;
        total_write_bytes += dma_info_w.length * (_DMA_WIDTH_ / 8);

        dma_write(mem_base, burst_size);
    }
}



template <
    int _DMA_WIDTH_,
    int _MEM_SIZE_
    >
void esp_dma_controller<_DMA_WIDTH_, _MEM_SIZE_>::res()
{

    acc_rst.write(true);
    wait();

    if (acc_done.read()) {
        acc_rst.write(false);
        wait();
        acc_rst.write(true);
    }
}

// Functions

template <int _DMA_WIDTH_, int _MEM_SIZE_> inline
void esp_dma_controller<_DMA_WIDTH_, _MEM_SIZE_>::dma_read(
    uint32_t mem_base, uint32_t burst_size)
{

    static bool first_dma_read = true;
    if (first_dma_read)
    {
        load_input_begin = sc_time_stamp();
    }
    sc_assert(mem != NULL);
    for (uint32_t i = 0; i < burst_size; ++i)
    {
        sc_assert(mem_base + i < _MEM_SIZE_);
        ac_int<_DMA_WIDTH_> data = mem[mem_base + i];
        dma_read_chnl.Push(data);
    }
    if (first_dma_read)
    {
        load_input_end = sc_time_stamp();
        first_dma_read = false;
    }
}

template <int _DMA_WIDTH_, int _MEM_SIZE_> inline
void esp_dma_controller<_DMA_WIDTH_, _MEM_SIZE_>::dma_write(
    uint32_t mem_base, uint32_t burst_size)
{
    static bool first_dma_write = true;

    if (first_dma_write)
    {
        store_output_begin = sc_time_stamp();
    }

    sc_assert(mem != NULL);
    for (uint32_t i = 0; i < burst_size; ++i)
    {
        sc_assert(mem_base + i < _MEM_SIZE_);

        ac_int<_DMA_WIDTH_> data = dma_write_chnl.Pop();

        mem[mem_base + i] = data;
    }

    if (first_dma_write)
    {
        store_output_end = sc_time_stamp();
        first_dma_write = false;
    }
}

