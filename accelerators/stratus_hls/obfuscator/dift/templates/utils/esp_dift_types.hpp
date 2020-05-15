/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_TYPES_HPP__
#define __ESP_DIFT_TYPES_HPP__

#include <stdint.h>

class dift_uint32_t
{
    public:

        tag_t tag;

        uint32_t val;

        dift_uint32_t() :
            tag(0), val(0)
        {
            // Nothing to do
        }

        dift_uint32_t(tag_t tag, uint32_t val)
            : tag(tag), val(val)
        {
            // Nothing to do
        }

        inline bool operator==(const dift_uint32_t &rhs) const
        {
            return (rhs.tag == tag)
                && (rhs.val == val);
        }

        inline dift_uint32_t &operator=(const dift_uint32_t &other)
        {
            tag = other.tag;
            val = other.val;
            return *this;
        }

        friend ostream &operator<<(ostream &stream, const dift_uint32_t &conf)
        {
            // Not supported
            return stream;
        }

        friend void sc_trace(sc_trace_file *tf, const dift_uint32_t &conf,
             const std::string &name)
        {
            // Not supported
        }
};

#endif // __ESP_DIFT_TYPES_HPP__
