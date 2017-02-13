#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "utils/esp_systemc.hpp"

#include "sort_conf_info.hpp"
#include "sort_debug_info.hpp"
#include "sort.hpp"

const size_t MEM_SIZE = LEN * LEN * sizeof(uint32_t);

#include "core/systems/esp_system.hpp"

#include GENERATE_MODULE_INCLUDE_NAME(sort, DMA_WIDTH_VAL)

class system_t : public esp_system<DMA_WIDTH_VAL, MEM_SIZE>
{
public:

        // ACC instance
        GENERATE_MODULE_NAME(sort, DMA_WIDTH_VAL) *acc;

        // Constructor
        SC_HAS_PROCESS(system_t);
        system_t(sc_module_name name)
          : esp_system<DMA_WIDTH_VAL, MEM_SIZE>(name)
        {
             // ACC
             acc = new GENERATE_MODULE_NAME(sort, DMA_WIDTH_VAL)("sort_wrapper");

             // Binding ACC
             acc->clk(clk);
             acc->rst(acc_rst);
             acc->dma_read_ctrl(dma_read_ctrl);
             acc->dma_write_ctrl(dma_write_ctrl);
             acc->dma_read_chnl(dma_read_chnl);
             acc->dma_write_chnl(dma_write_chnl);
             acc->conf_info(conf_info);
             acc->conf_done(conf_done);
             acc->acc_done(acc_done);
             acc->debug(debug);
        }

        // Processes

        // Configure accelerator
        void config_proc();

        // Load internal memory
        void load_memory();

        // Dump internal memory
        void dump_memory();

        // Validate accelerator results
        int validate();

        // Accelerator-specific data
	uint32_t SORT_LEN;
	uint32_t SORT_BATCH;
        float *vectors;
        float *gold;

	// Other Functions
	void insertion_sort(float *value, int len);
	int check_gold(float *gold, float *array, int len);
};

#endif // __SYSTEM_HPP__
