// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __OBFUSCATOR_CONF_INFO_HPP__
#define __OBFUSCATOR_CONF_INFO_HPP__

#include <cstddef>

class conf_info_t
{
    public:

        // Number of cols
        uint32_t num_rows;

        // Number of rows
        uint32_t num_cols;

        // Start row blurring
        uint32_t i_row_blur;

        // Start col blurring
        uint32_t i_col_blur;

        // Stop row blurring
        uint32_t e_row_blur;

        // Stop col blurring
        uint32_t e_col_blur;

        // Input offset
        uint32_t ld_offset;

        // Output offset
        uint32_t st_offset;

        conf_info_t()
            : num_rows(0)
            , num_cols(0)
            , i_row_blur(0)
            , i_col_blur(0)
            , e_row_blur(0)
            , e_col_blur(0)
            , ld_offset(0)
            , st_offset(0)
        {
            // Nothing to do
        }

        // -- Operators

        inline bool operator==(const conf_info_t &rhs) const
        {
            return (rhs.num_rows == num_rows)
                && (rhs.num_cols == num_cols)
                && (rhs.i_row_blur == i_row_blur)
                && (rhs.i_col_blur == i_col_blur)
                && (rhs.e_row_blur == e_row_blur)
                && (rhs.e_col_blur == e_col_blur)
                && (rhs.ld_offset == ld_offset)
                && (rhs.st_offset == st_offset);
        }

        inline conf_info_t &operator=(const conf_info_t &other)
        {
            num_rows = other.num_rows;
            num_cols = other.num_cols;
            i_row_blur = other.i_row_blur;
            i_col_blur = other.i_col_blur;
            e_row_blur = other.e_row_blur;
            e_col_blur = other.e_col_blur;
            ld_offset = other.ld_offset;
            st_offset = other.st_offset;
            return *this;
        }

        friend ostream &operator<<(ostream &stream, const conf_info_t &conf)
        {
            // Not supported
            return stream;
        }

        // -- Functions

        friend void sc_trace(sc_trace_file *tf, const conf_info_t &conf,
                             const std::string &name)
        {
            // Not supported
        }
};

#endif // __OBFUSCATOR_CONF_INFO_HPP__
