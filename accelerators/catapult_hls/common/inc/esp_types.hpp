// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#ifndef __ESP_TYPES_HPP__
#define __ESP_TYPES_HPP__

#include <ac_int.h>
#include <ac_fixed.h>

// Unsigned integers
#define uint8_t ac_int<8, false>
#define uint16_t ac_int<16, false>
#define uint32_t ac_int<32, false>
#define uint64_t ac_int<64, false>

#define ESP_TO_UINT32(x) x.to_uint()
#define ESP_TO_UINT64(x) x.to_uint64()

// Signed integers
#define int8_t ac_int<8, true>
#define int16_t ac_int<16, true>
#define int32_t ac_int<32, true>
#define int64_t ac_int<64, true>

#define ESP_TO_INT32(x) x.to_int()
#define ESP_TO_INT64(x) x.to_int64()

// Forward struct
struct conf_info_t;

#endif // __ESP_TYPES_HPP__
