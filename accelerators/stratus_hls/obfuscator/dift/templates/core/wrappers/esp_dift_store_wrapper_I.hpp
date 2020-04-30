/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_STORE_WRAPPER_I_HPP__
#define __ESP_DIFT_STORE_WRAPPER_I_HPP__

#include "esp_dift_store_wrapper.hpp"

template < size_t _DMA_WIDTH_ >
class esp_dift_store_wrapper_I : public esp_dift_store_wrapper<_DMA_WIDTH_>
{
    // Inline module
    HLS_INLINE_MODULE;

    public:

        // -- Module constructor

        SC_HAS_PROCESS(esp_dift_store_wrapper_I);
        esp_dift_store_wrapper_I(const sc_module_name &name)
            : esp_dift_store_wrapper<_DMA_WIDTH_>(name) { }

        // -- Processes

        // Adjust the write requests
        void store_output();
};

// Implementation
#include "esp_dift_store_wrapper_I.i.hpp"

#endif // __ESP_DIFT_STORE_WRAPPER_I_HPP__
