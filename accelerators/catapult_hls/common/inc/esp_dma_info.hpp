// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#ifndef __ESP_DMA_INFO_HPP__
#define __ESP_DMA_INFO_HPP__

#include "esp_types.hpp"

#define SIZE_BYTE   0
#define SIZE_HWORD  1
#define SIZE_WORD   2
#define SIZE_DWORD  3
#define SIZE_4WORD  4
#define SIZE_8WORD  5
#define SIZE_16WORD 6
#define SIZE_32WORD 7

struct dma_info_t {

    // Index
    uint32_t index;

    // Length
    uint32_t length;

    // Length
    ac_int<3, false> size;

};

#endif // __ESP_DMA_INFO_HPP__
