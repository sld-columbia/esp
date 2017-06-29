/* Copyright 2017 Columbia University, SLD Group */

#ifndef __CACHE_UTILS_HPP__
#define __CACHE_UTILS_HPP__

#include <iostream>
#include <utility>
#include "utils/esp_systemc.hpp"
#include "utils/esp_utils.hpp"
#include "cache_consts.hpp"
#include "cache_types.hpp"

#define CACHE_REPORT_INFO(text)						\
    cerr << "Info:  " << sc_object::basename() << ".\t " << text << endl;

#define CACHE_REPORT_ERROR(text, var)					\
    cerr << "ERROR: " << sc_object::basename() << ".\t " << text << " : " \
    << var << endl;

#define CACHE_REPORT_TIME(time, text)					\
    cerr << "Info:  " << sc_object::basename() << ".\t @" << time << " : " \
    << text << endl;

#define CACHE_REPORT_VAR(time, text, var)				\
    cerr << "Info:  " << sc_object::basename() << ".\t @" << time << " : " \
    << text << " : " << var << endl;

#define CACHE_REPORT_DEBUG(time, text, var)				\
    cerr << "Debug:  " << sc_object::basename() << ".\t @" << time << " : " \
    << text << " : " << var << endl;

inline void write_word(line_t &line, word_t word, word_offset_t w_off)
{
    line.range(BITS_PER_WORD*w_off+BITS_PER_WORD-1, BITS_PER_WORD*w_off) = (sc_biguint<BITS_PER_WORD>) word;
}

inline word_t read_word(line_t line, word_offset_t w_off)
{
    word_t word;
    word = (sc_uint<BITS_PER_WORD>) line.range(BITS_PER_WORD*w_off+BITS_PER_WORD-1, BITS_PER_WORD*w_off);

    return word;
}

#endif /* __CACHE_UTILS_HPP__ */
