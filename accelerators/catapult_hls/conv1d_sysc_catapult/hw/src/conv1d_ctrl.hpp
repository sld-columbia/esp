#ifndef _CONV1D_CTRL_HPP_
#define _CONV1D_CTRL_HPP_

#include <systemc.h>
#include <nvhls_int.h>
#include <nvhls_connections.h>
#include <ac_shared_bank_array.h>

#include "../inc/conv1d_conf_info.hpp"
#include "../inc/conv1d_specs.hpp"
#include "../inc/esp_dma_info_sysc.hpp"

SC_MODULE(AccController)
{
public:
    sc_in<bool>     CCS_INIT_S1(clk);
    sc_in<bool>     CCS_INIT_S1(rst);
    sc_out<bool>    CCS_INIT_S1(acc_done);

    Connections::In<ac_int<DMA_WIDTH>>    CCS_INIT_S1(dma_read_chnl);
    Connections::Out<ac_int<DMA_WIDTH>>   CCS_INIT_S1(dma_write_chnl);
    Connections::Out<dma_info_t>          CCS_INIT_S1(dma_read_ctrl);
    Connections::Out<dma_info_t>          CCS_INIT_S1(dma_write_ctrl);

    Connections::In<conf_info_t>          CCS_INIT_S1(conf_info_dma2acc);
    Connections::In<conf_info_t>          CCS_INIT_S1(conf_info_plm2vec);
    Connections::In<conf_info_t>          CCS_INIT_S1(conf_info_acc2dma);

    Connections::Out<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_in_itcn);
    Connections::Out<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_weight_itcn);
    Connections::Out<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(vec_psum_itcn);
    Connections::In<array_t<FPDATA, VEC_LEN>>  CCS_INIT_S1(vec_out_itcn);

    Connections::Out<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_in_bias_itcn);
    Connections::Out<array_t<FPDATA, VEC_LEN>> CCS_INIT_S1(data_bias_itcn);
    Connections::In<array_t<FPDATA, VEC_LEN>>  CCS_INIT_S1(data_out_bias_itcn);

    Connections::Combinational<int32_t> CCS_INIT_S1(ld2com_sync);
    Connections::Combinational<int32_t> CCS_INIT_S1(com2st_sync);
    Connections::Combinational<int32_t> CCS_INIT_S1(st2ld_sync);

    ac_shared_bank_array_2D<DATA_TYPE, bks, ebks> plm_in_ping;
    ac_shared_bank_array_2D<DATA_TYPE, bks, ebks> plm_weight_ping;
    ac_shared_bank_array_2D<DATA_TYPE, bks, ebks> plm_bias_ping;
	ac_shared_bank_array_2D<DATA_TYPE, bks, ebks> plm_out_ping;

public:
    SC_HAS_PROCESS(AccController);
    AccController(const sc_module_name& name) :
        sc_module(name),
        clk("clk"), rst("rst"), 
		acc_done("acc_done"),
        dma_read_chnl("dma_read_chnl"), 
		dma_write_chnl("dma_write_chnl"),
        dma_read_ctrl("dma_read_ctrl"), 
		dma_write_ctrl("dma_write_ctrl"),
        conf_info_dma2acc("conf_info_dma2acc"), 
		conf_info_plm2vec("conf_info_plm2vec"), 
		conf_info_acc2dma("conf_info_acc2dma"),
        vec_in_itcn("vec_in_itcn"), 
		vec_weight_itcn("vec_weight_itcn"), 
		vec_psum_itcn("vec_psum_itcn"), 
		vec_out_itcn("vec_out_itcn"),
        data_in_bias_itcn("data_in_bias_itcn"), 
		data_bias_itcn("data_bias_itcn"), 
		data_out_bias_itcn("data_out_bias_itcn"),
        ld2com_sync("ld2com_sync"), 
		com2st_sync("com2st_sync"), 
		st2ld_sync("st2ld_sync")
    {
        SC_THREAD(dma2acc);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

        SC_THREAD(plm2vec);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);

        SC_THREAD(acc2dma);
        sensitive << clk.pos();
        async_reset_signal_is(rst, false);
    }

    // Helper: DMA Read Request
    template <typename SharedArray2D>
    void load(uint32_t dma_ld_addr, uint32_t dma_ld_size, uint32_t plm_addr_offset, SharedArray2D& plm, const uint32_t num_banks, const uint32_t elems_per_bank) {
        uint32_t dma_beats = (dma_ld_size + DMA_WORD_PER_BEAT - 1) / DMA_WORD_PER_BEAT;
        dma_info_t dma_req;
        dma_req.index = dma_ld_addr;
        dma_req.length = dma_beats;
        dma_req.size = (DMA_WIDTH/8) - 1;
        dma_read_ctrl.Push(dma_req);

        for (uint32_t i = 0; i < dma_beats; ++i) {
            ac_int<DMA_WIDTH> raw_data = dma_read_chnl.Pop();
            #pragma hls_unroll yes
            for (int k = 0; k < DMA_WORD_PER_BEAT; ++k) {
                uint32_t current_plm_idx = plm_addr_offset + (i * DMA_WORD_PER_BEAT) + k;
                plm[current_plm_idx % num_banks][current_plm_idx / num_banks] = raw_data.slc<DATA_WIDTH>(k * DATA_WIDTH);
            }
        }
    }

    // Helper: DMA Write Request
    template <typename SharedArray2D>
    void store(uint32_t dma_st_addr, uint32_t dma_st_size, uint32_t plm_addr_offset, SharedArray2D& plm, const uint32_t num_banks, const uint32_t elems_per_bank) {
        uint32_t dma_beats = (dma_st_size + DMA_WORD_PER_BEAT - 1) / DMA_WORD_PER_BEAT;
        dma_info_t dma_req;
        dma_req.index = dma_st_addr;
        dma_req.length = dma_beats;
        dma_req.size = (DMA_WIDTH/8) - 1;
        dma_write_ctrl.Push(dma_req);

        for (uint32_t i = 0; i < dma_beats; ++i) {
            ac_int<DMA_WIDTH> raw_data;
            #pragma hls_unroll yes
            for (int k = 0; k < DMA_WORD_PER_BEAT; ++k) {
                uint32_t current_plm_idx = plm_addr_offset + (i * DMA_WORD_PER_BEAT) + k;
                if (current_plm_idx < (num_banks * elems_per_bank)) {
                    raw_data.set_slc(k * DATA_WIDTH, (ac_int<DATA_WIDTH, true>)plm[current_plm_idx % num_banks][current_plm_idx / num_banks]);
                }
            }
            dma_write_chnl.Push(raw_data);
        }
    }

    // Process 1: Load Data from DRAM to PLM
    void dma2acc() {
        conf_info_dma2acc.Reset();
        dma_read_chnl.Reset();
        dma_read_ctrl.Reset();
        
		ld2com_sync.ResetWrite();
        st2ld_sync.ResetRead();

        wait();
        while (true) {
            conf_info_t config = conf_info_dma2acc.Pop();
            uint32_t w_iter = config.n_filters / VEC_LEN;
            uint32_t input_size = config.feature_map_len * config.n_channels;
            uint32_t weights_per_filter_size = config.kernel_size * config.n_channels;
            const uint32_t bytes_per_word = DATA_WIDTH / 8;
            load(config.addrI, input_size, 0, plm_in_ping, bks, ebks);

            for (uint32_t w_i = 0; w_i < w_iter; ++w_i) {
                if(w_i > 0)
                    st2ld_sync.Pop();
                uint32_t current_weights_size = weights_per_filter_size * VEC_LEN;
                uint32_t current_bias_size = VEC_LEN;
                uint32_t weights_dma_addr = config.addrW + (w_i * current_weights_size * bytes_per_word);
                uint32_t bias_dma_addr = config.addrB + (w_i * current_bias_size * bytes_per_word);
                load(weights_dma_addr, current_weights_size, 0, plm_weight_ping, bks, ebks);
                load(bias_dma_addr, current_bias_size, 0, plm_bias_ping, bks, ebks);
                ld2com_sync.Push(1);
            }
        }
    }
    
    void int2fx(const ac_int<FPDATA_WL, true> in, FPDATA &out) {
        out.set_slc(0, in.template slc<FPDATA_WL>(0));
    }

    void fx2int(const FPDATA in, ac_int<FPDATA_WL, true> &out) {
        out.set_slc(0, in.template slc<FPDATA_WL>(0));
    }

    // Process 2: Compute Data (MAC + Bias + Activation)
    void plm2vec() {
        conf_info_plm2vec.Reset();
        vec_in_itcn.Reset();
        vec_weight_itcn.Reset();
        vec_psum_itcn.Reset();
        vec_out_itcn.Reset();
        data_in_bias_itcn.Reset();
        data_bias_itcn.Reset();
        data_out_bias_itcn.Reset();
        
		ld2com_sync.ResetRead();
        com2st_sync.ResetWrite();

        wait();
        while (true) {
            conf_info_t config = conf_info_plm2vec.Pop();
            int32_t kernel_size = static_cast<int32_t>(config.kernel_size);
            int32_t n_channels = static_cast<int32_t>(config.n_channels);
            int32_t stride = static_cast<int32_t>(config.stride);
            int32_t feature_map_len = static_cast<int32_t>(config.feature_map_len);
            int32_t n_filters = static_cast<int32_t>(config.n_filters);

            uint32_t w_iter = static_cast<uint32_t>(n_filters / VEC_LEN);
            uint32_t output_len = static_cast<uint32_t>(feature_map_len / stride);
            int32_t pad_needed = (static_cast<int32_t>(output_len) - 1) * stride + kernel_size - feature_map_len;
            int32_t pad_left = (pad_needed > 0) ? pad_needed / 2 : 0;
            
            for (uint32_t w_i = 0; w_i < w_iter; ++w_i) {
                ld2com_sync.Pop();
                for (uint32_t l_out = 0; l_out < output_len; ++l_out) {
                    int32_t l_in_start = static_cast<int32_t>(l_out) * stride - pad_left;

                    array_t<FPDATA, VEC_LEN> current_bias_vec;
                    #pragma hls_unroll yes
                    for (int v_idx = 0; v_idx < VEC_LEN; ++v_idx) {
                        ac_int<FPDATA_WL, true> bias_val;
                        bias_val = (ac_int<FPDATA_WL, true>)plm_bias_ping[v_idx % bks][v_idx / bks];
                        int2fx(bias_val, current_bias_vec.data[v_idx]);
                    }

                    array_t<FPDATA, VEC_LEN> acc_vec;
                    #pragma hls_unroll yes
                    for (int v_idx = 0; v_idx < VEC_LEN; ++v_idx) {
                        acc_vec.data[v_idx] = 0.0f;
                    }

                    for (int32_t k_idx = 0; k_idx < kernel_size; ++k_idx) {
                        int32_t l_in = l_in_start + k_idx;
                        if (l_in >= 0 && l_in < feature_map_len) {
                            for (int32_t c_in_idx = 0; c_in_idx < n_channels; ++c_in_idx) {
                                array_t<FPDATA, VEC_LEN> v_in, v_w, v_p, v_o;
                                uint32_t input_plm_idx = static_cast<uint32_t>(l_in * n_channels + c_in_idx);
                                ac_int<FPDATA_WL, true> in_val = (ac_int<FPDATA_WL, true>)plm_in_ping[input_plm_idx % bks][input_plm_idx / bks];
                                #pragma hls_unroll yes
                                for (int v_idx = 0; v_idx < VEC_LEN; ++v_idx) {
                                    int2fx(in_val, v_in.data[v_idx]);
                                }

                                #pragma hls_unroll yes
                                for (int v_idx = 0; v_idx < VEC_LEN; ++v_idx) {
                                    // Weight layout in memory is filter-major (f, c, k).
                                    // Re-index into PLM accordingly so each lane grabs its filter.
                                    uint32_t w_plm_idx = static_cast<uint32_t>(v_idx * n_channels * kernel_size +
                                                         (c_in_idx * kernel_size) + k_idx);
                                    ac_int<FPDATA_WL, true> weight_val = (ac_int<FPDATA_WL, true>)plm_weight_ping[w_plm_idx % bks][w_plm_idx / bks];
                                    int2fx(weight_val, v_w.data[v_idx]);
                                }
                                v_p = acc_vec;
                                vec_in_itcn.Push(v_in);
                                vec_weight_itcn.Push(v_w);
                                vec_psum_itcn.Push(v_p);
                                v_o = vec_out_itcn.Pop();
                                #ifdef DEBUG_ACC
                                std::cout << "ACC IN: v_in[0]=" << v_in.data[0] << ", v_w[0]=" << v_w.data[0] << ", v_p[0]=" << v_p.data[0] << ", v_o[0]=" << v_o.data[0] << std::endl;
                                #endif
                                acc_vec = v_o;
                            }
                        }
                    }
                    data_in_bias_itcn.Push(acc_vec);
                    data_bias_itcn.Push(current_bias_vec);
                    array_t<FPDATA, VEC_LEN> activated_output = data_out_bias_itcn.Pop();
                    #pragma hls_unroll yes
                    for (int v_idx = 0; v_idx < VEC_LEN; ++v_idx) {
                        // Store outputs in filter-major order: each filter's outputs are contiguous.
                        uint32_t out_plm_idx = (v_idx * output_len) + l_out;
                        ac_int<FPDATA_WL, true> out_val;
                        fx2int(activated_output.data[v_idx], out_val);
                        plm_out_ping[out_plm_idx % bks][out_plm_idx / bks] = out_val;
                    }
                }
                com2st_sync.Push(1);
            }
        }
    }

    // Process 3: Store Data from PLM to DRAM
    void acc2dma() {
        conf_info_acc2dma.Reset();
        dma_write_chnl.Reset();
        dma_write_ctrl.Reset();
        com2st_sync.ResetRead();
        st2ld_sync.ResetWrite();
        acc_done.write(false);

        wait();
        while (true) {
            conf_info_t config = conf_info_acc2dma.Pop();
            uint32_t w_iter = config.n_filters / VEC_LEN;
            uint32_t output_len = config.feature_map_len / config.stride;
            const uint32_t bytes_per_word = DATA_WIDTH / 8;

            for (uint32_t w_i = 0; w_i < w_iter; ++w_i) {
                com2st_sync.Pop();
                uint32_t current_output_size = output_len * VEC_LEN;
                uint32_t output_dma_addr = config.addrO + (w_i * current_output_size * bytes_per_word);
                store(output_dma_addr, current_output_size, 0, plm_out_ping, bks, ebks);
                st2ld_sync.Push(1);
            }
            acc_done.write(true);
            wait();
            acc_done.write(false);
        }
    }
};

#endif
