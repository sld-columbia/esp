// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __MRIQ_HPP__
#define __MRIQ_HPP__

#include "mriq_conf_info.hpp"
#include "mriq_debug_info.hpp"

#include "esp_templates.hpp"

#include "mriq_directives.hpp"
#include "fpdata.hpp"
#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */


#define DATA_WIDTH FPDATA_S_WL // could be 32 or 24
#define DMA_SIZE SIZE_WORD


class mriq : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Constructor
    SC_HAS_PROCESS(mriq);
    mriq(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
    {
        // Signal binding
        cfg.bind_with(*this);

        // Map arrays to memories
        /* <<--plm-bind-->> */

        HLS_MAP_plm(plm_Qr_ping, PLM_X_NAME);
        HLS_MAP_plm(plm_Qi_ping, PLM_X_NAME);

        HLS_MAP_plm(plm_Qr_pong, PLM_X_NAME);
        HLS_MAP_plm(plm_Qi_pong, PLM_X_NAME);

        HLS_MAP_plm(plm_x_ping, PLM_X_NAME);
        HLS_MAP_plm(plm_y_ping, PLM_X_NAME);
        HLS_MAP_plm(plm_z_ping, PLM_X_NAME);

        HLS_MAP_plm(plm_x_pong, PLM_X_NAME);
        HLS_MAP_plm(plm_y_pong, PLM_X_NAME);
        HLS_MAP_plm(plm_z_pong, PLM_X_NAME);


#if(ARCH==0) // if loading all K-space data into PLM, no need for ping-pong

        HLS_MAP_plm(plm_kx, PLM_K_NAME);
        HLS_MAP_plm(plm_ky, PLM_K_NAME);
        HLS_MAP_plm(plm_kz, PLM_K_NAME);
        HLS_MAP_plm(plm_phiR, PLM_K_NAME);
        HLS_MAP_plm(plm_phiI, PLM_K_NAME);

#else
        HLS_MAP_plm(plm_kx_ping, PLM_K_NAME);
        HLS_MAP_plm(plm_ky_ping, PLM_K_NAME);
        HLS_MAP_plm(plm_kz_ping, PLM_K_NAME);
        HLS_MAP_plm(plm_phiR_ping, PLM_K_NAME);
        HLS_MAP_plm(plm_phiI_ping, PLM_K_NAME);

        HLS_MAP_plm(plm_kx_pong, PLM_K_NAME);
        HLS_MAP_plm(plm_ky_pong, PLM_K_NAME);
        HLS_MAP_plm(plm_kz_pong, PLM_K_NAME);
        HLS_MAP_plm(plm_phiR_pong, PLM_K_NAME);
        HLS_MAP_plm(plm_phiI_pong, PLM_K_NAME);
#endif



    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure mriq
    esp_config_proc cfg;

    // Functions
    template<typename T>
    void dma_read(T array[], uint32_t dma_index, uint32_t dma_length);

    template<typename T>
    void dma_write(T array[], uint32_t dma_index, uint32_t dma_length);

    void ComputeQ(FPDATA_S x,FPDATA_S y,FPDATA_S z, uint16_t  batch_size_k,
		  bool pingpong_k, FPDATA_S *sin_table,
		  FPDATA_L *Qr, FPDATA_L *Qi);


    FPDATA_S mySinf(FPDATA_L angle, FPDATA_S *sin_table);



    // Private local memories
    // FPDATA_S_WORD means data with smaller values.
    // For MRI-Q matrix, input and output data range are fixed.
    FPDATA_S_WORD plm_x_ping[PLM_X_WORD];
    FPDATA_S_WORD plm_y_ping[PLM_X_WORD];
    FPDATA_S_WORD plm_z_ping[PLM_X_WORD];

    FPDATA_S_WORD plm_x_pong[PLM_X_WORD];
    FPDATA_S_WORD plm_y_pong[PLM_X_WORD];
    FPDATA_S_WORD plm_z_pong[PLM_X_WORD];


    FPDATA_L_WORD plm_Qr_ping[PLM_X_WORD];
    FPDATA_L_WORD plm_Qi_ping[PLM_X_WORD];
    FPDATA_L_WORD plm_Qr_pong[PLM_X_WORD];
    FPDATA_L_WORD plm_Qi_pong[PLM_X_WORD];

#if(ARCH==0)

    FPDATA_S_WORD plm_kx[PLM_K_WORD];
    FPDATA_S_WORD plm_ky[PLM_K_WORD];
    FPDATA_S_WORD plm_kz[PLM_K_WORD];
    FPDATA_S_WORD plm_phiR[PLM_K_WORD];
    FPDATA_S_WORD plm_phiI[PLM_K_WORD];
#else

    FPDATA_S_WORD plm_kx_ping[PLM_K_WORD];
    FPDATA_S_WORD plm_ky_ping[PLM_K_WORD];
    FPDATA_S_WORD plm_kz_ping[PLM_K_WORD];
    FPDATA_S_WORD plm_phiR_ping[PLM_K_WORD];
    FPDATA_S_WORD plm_phiI_ping[PLM_K_WORD];

    FPDATA_S_WORD plm_kx_pong[PLM_K_WORD];
    FPDATA_S_WORD plm_ky_pong[PLM_K_WORD];
    FPDATA_S_WORD plm_kz_pong[PLM_K_WORD];
    FPDATA_S_WORD plm_phiR_pong[PLM_K_WORD];
    FPDATA_S_WORD plm_phiI_pong[PLM_K_WORD];

#endif


};


#endif /* __MRIQ_HPP__ */
