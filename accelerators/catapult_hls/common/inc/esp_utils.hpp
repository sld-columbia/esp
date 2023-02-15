// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#ifndef __ESP_UTILS_HPP__
#define __ESP_UTILS_HPP__

#ifdef __SYNTHESIS__

#define ESP_REPORT_INFO(...)
#define ESP_REPORT_ERROR(...)
#define ESP_REPORT_TIME(time, ...)

#elif defined(__DEBUG__)

#define VON 1
#define VOFF 0

#define ESP_REPORT_INFO(verbosity, ...) \
  if (verbosity == VON) \
  { fprintf(stderr, "INFO: %s::%u::%s(): ", __FILE__, __LINE__, __func__); \
    fprintf(stderr, __VA_ARGS__); \
    fprintf(stderr, "\n"); }

#define ESP_REPORT_ERROR(verbosity, ...) \
  if (verbosity == VON) \
  { fprintf(stderr, "ERROR: %s::%u::%s(): ", __FILE__, __LINE__, __func__); \
    fprintf(stderr, __VA_ARGS__); \
    fprintf(stderr, "\n"); }

#else

#define VON 1
#define VOFF 0

#define ESP_REPORT_INFO(verbosity, ...) \
  if (verbosity == VON) \
  { fprintf(stderr, "INFO: %12s(): ", __func__); \
    fprintf(stderr, __VA_ARGS__); \
    fprintf(stderr, "\n"); }

#define ESP_REPORT_ERROR(verbosity, ...) \
  if (verbosity == VON) \
  { fprintf(stderr, "ERROR: %12s(): ", __func__); \
    fprintf(stderr, __VA_ARGS__); \
    fprintf(stderr, "\n"); }

#endif

#endif /* __ESP_UTILS_HPP__ */
