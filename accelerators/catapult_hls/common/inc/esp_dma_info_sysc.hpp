#ifndef __ESP_CONF_INFO_HPP__
#define __ESP_CONF_INFO_HPP__

#include <sstream>
#include <mc_connections.h>
// #include "<accelerator_name>_specs.hpp"

struct dma_info_t {

    uint32_t index;
    uint32_t length;
    ac_int<3,false> size;

    static const unsigned int width = 32+32+3 ;
    template <unsigned int Size> void Marshall(Marshaller<Size> &m) {
        m &index;
        m &length;
        m &size;
    }

    dma_info_t()
        : index(0), length(0) ,size(0){ }

    dma_info_t(uint32_t i, uint32_t l, ac_int<3,false> s)
        : index(i), length(l), size(s) { }

    dma_info_t(const dma_info_t &other)
        : index(other.index), length(other.length), size(other.size) { }

    // Operators

    // Assign operator
    dma_info_t& operator=(const dma_info_t &other)
    {
        index = other.index;
        length = other.length;
        size = other.size;
        return *this;
    }

    // Equals operator
    inline bool operator==(const dma_info_t &rhs) const
    {
        return ((rhs.index == index)
                && (rhs.length == length)
                && (rhs.size == size));
    }


    // Friend zone

    // Dump operator
    friend ostream& operator<<(ostream &os, dma_info_t const &dma_info)
    {
        os << "{" << dma_info.index  << ","
           << dma_info.length  << "}";
        return os;
    }

    // Makes this type traceable by SystemC
    inline friend void sc_trace(sc_trace_file *tf, const dma_info_t &v,
                                const std::string &name)
    {

        std::stringstream sstm_c;
        sstm_c << name << ".index";
        sc_trace(tf, v.index, sstm_c.str());
        sstm_c << name << ".length";
        sc_trace(tf, v.length, sstm_c.str());
    }

};

#endif
