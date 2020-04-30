/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_SYSTEM_HPP__
#define __ESP_DIFT_SYSTEM_HPP__

#include "core/systems/esp_system.hpp"

template <
    size_t _DMA_WIDTH_,
    size_t _MEM_SIZE_
    >
class esp_dift_system: public esp_system<_DMA_WIDTH_, _MEM_SIZE_>
{
    public:

        // -- Module Constructor

        SC_HAS_PROCESS(esp_dift_system);
        esp_dift_system(sc_module_name name)
            : esp_system<_DMA_WIDTH_, _MEM_SIZE_>(name) { };

};

#endif // __ESP_DIFT_SYSTEM_HPP__
