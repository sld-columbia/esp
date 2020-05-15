/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_LOAD_WRAPPER_I_HPP__
#define __ESP_DIFT_LOAD_WRAPPER_I_HPP__

// -- Interleaved tagging scheme

#include "esp_dift_load_wrapper.hpp"

template < size_t _DMA_WIDTH_ >
class esp_dift_load_wrapper_I : public esp_dift_load_wrapper<_DMA_WIDTH_>
{
    // Inline module
    HLS_INLINE_MODULE;

    public:

        // -- Module constructor

        SC_HAS_PROCESS(esp_dift_load_wrapper_I);
        esp_dift_load_wrapper_I(const sc_module_name &name)
            : esp_dift_load_wrapper<_DMA_WIDTH_>(name) { }

        // -- Processes

        // Adjust the read requests
        void load_input();
};

// Implementation
#include "esp_dift_load_wrapper_I.i.hpp"

#endif // __ESP_DIFT_LOAD_WRAPPER_I_HPP__
