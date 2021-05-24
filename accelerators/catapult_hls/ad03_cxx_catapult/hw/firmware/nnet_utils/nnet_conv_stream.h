#ifndef NNET_CONV_STREAM_H_
#define NNET_CONV_STREAM_H_

#include "nnet_common.h"
#include <ac_channel.h>
#include <ac_float.h>

namespace nnet {

template<unsigned K, unsigned S, unsigned W>
unsigned scale_index(const unsigned idx) {

    if (idx < K - S) {
        return idx;
    }

    constexpr unsigned nW = ((W - K) / S) * S + K; // Nearest W without unused pixels on the right
    constexpr unsigned sW = (DIV_ROUNDUP(K, S) - 1) * S + K; // Scaled W that behaves like original W
    if (idx >= nW) {
        return sW;
    }

    const unsigned r = nW - idx;
    if (r <= K - S) {
        return sW - r;
    }

    return K - S + (idx - (K - S)) % S;
}

template<class data_T, class res_T, typename CONFIG_T>
void mult_buffer(
    ac_channel<typename data_T::value_type> data_window[CONFIG_T::kernel_size * CONFIG_T::n_chan],
    res_T& res_pack,
    ac_channel<res_T>& res_stream,
    unsigned & outputs_ready,
    typename CONFIG_T::weight_t weights[CONFIG_T::kernel_size * CONFIG_T::n_chan * CONFIG_T::n_filt],
    typename CONFIG_T::bias_t biases[CONFIG_T::n_filt]
) {

    typename data_T::value_type data[CONFIG_T::kernel_size * CONFIG_T::n_chan];
    typename res_T::value_type res[CONFIG_T::n_filt];

    InitData: for (int id = 0; id < CONFIG_T::kernel_size * CONFIG_T::n_chan; id++) {
        data[id] = data_window[id].read();
    }

    if (CONFIG_T::strategy == nnet::latency) {
        dense_latency<typename data_T::value_type, typename res_T::value_type, typename CONFIG_T::mult_config>(data, res, weights, biases);
    } else {
        dense_resource<typename data_T::value_type, typename res_T::value_type, typename CONFIG_T::mult_config>(data, res, weights, biases);
    }

    CastLoop: for (unsigned jj = 0; jj < CONFIG_T::n_filt; jj++) {
        if (res_T::size / CONFIG_T::n_filt == 1) {
            res_pack[jj] = res[jj];
        } else {
            res_pack[outputs_ready * CONFIG_T::n_filt + jj] = res[jj];
        }
    }

    if (res_T::size / CONFIG_T::n_filt == 1) {
        res_stream.write(res_pack);
    } else {
        if (outputs_ready == (res_T::size / CONFIG_T::n_filt) - 1) {
            res_stream.write(res_pack);
            outputs_ready = 0;
        } else {
            outputs_ready++;
        }
    }
}

template<class data_T, class res_T, typename CONFIG_T>
void compute_output(
    const data_T& in_elem,
    ac_channel<typename data_T::value_type> data_window[CONFIG_T::kernel_size * CONFIG_T::n_chan],
    ac_channel<res_T> &res,
    res_T &res_pack,
    unsigned &outputs_ready,
    typename CONFIG_T::weight_t weights[CONFIG_T::kernel_size * CONFIG_T::n_chan * CONFIG_T::n_filt],
    typename CONFIG_T::bias_t biases[CONFIG_T::n_filt],
    ac_int<CONFIG_T::kernel_size, false> *pixel_idx
) {

    MultLoop: for (unsigned p = 0; p < data_T::size / CONFIG_T::n_chan; p++) {
        CopyDataFilt: for (unsigned f = 0; f < CONFIG_T::kernel_size; f++) {
            CopyDataChan: for (unsigned c = 0; c < CONFIG_T::n_chan; c++) {
                if (pixel_idx[p][f]) data_window[f * CONFIG_T::n_chan + c].write(in_elem[p * CONFIG_T::n_chan + c]);
            }
        }
        if (pixel_idx[p][CONFIG_T::kernel_size - 1]) {
            mult_buffer<data_T, res_T, CONFIG_T>(data_window, res_pack, res, outputs_ready, weights, biases);
        }
    }
}

}
#endif
