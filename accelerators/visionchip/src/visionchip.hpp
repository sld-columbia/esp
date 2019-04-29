// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// // SPDX-License-Identifier: MIT

#ifndef __VISIONCHIP_HPP__
#define __VISIONCHIP_HPP__

#include "visionchip_conf_info.hpp"
#include "visionchip_debug_info.hpp"

#include "esp_templates.hpp"

#include "visionchip_directives.hpp"

#include "plm_data32_1w1r.hpp"
#include "plm_data32_2w2r.hpp"
#include "plm_hist_1w1r.hpp"

#define WORD_SIZE 32

// Include generated header files for PLM here

class visionchip : public esp_accelerator_3P<DMA_WIDTH>
{
public:
// Constructor
	SC_HAS_PROCESS(visionchip);
        visionchip(const sc_module_name& name)
          : esp_accelerator_3P<DMA_WIDTH>(name)
          , cfg("config")
        {
            // Signal binding
            cfg.bind_with(*this);

	    // Clock binding for memories
	    mem_buff_1.clk(this->clk);
	    mem_buff_2.clk(this->clk);
	    mem_hist.clk(this->clk);
	    mem_CDF.clk(this->clk);
	    mem_LUT.clk(this->clk);
        }

        // Processes

        // Load the input data
        void load_input();

        // Computation
        void compute_kernel();

        // Store the output data
        void store_output();

        // Configure visionchip
        esp_config_proc cfg;

        // Functions
	int kernel_nf(int n_Rows, int n_Cols);
	int kernel_hist(int n_Rows, int n_Cols);
	int kernel_histEq(int n_Rows, int n_Cols);
        int kernel_dwt(int n_Rows, int n_Cols);
	int dwt_row_transpose(int n_Rows, int n_Cols);
	int dwt_col_transpose(int n_Rows, int n_Cols);
	
        // -- Private local memories
        plm_data32_2w2r_t<int32_t, PLM_IMG_SIZE> mem_buff_1;
        plm_data32_1w1r_t<int32_t, PLM_IMG_SIZE> mem_buff_2;
        plm_hist_1w1r_t<int32_t, PLM_HIST_SIZE> mem_hist;
        plm_hist_1w1r_t<int32_t, PLM_HIST_SIZE> mem_CDF;
        plm_hist_1w1r_t<int32_t, PLM_HIST_SIZE> mem_LUT;
};


#endif /* __VISIONCHIP_HPP__ */
