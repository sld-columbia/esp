#ifndef NNET_CONV2D_STREAM_H_
#define NNET_CONV2D_STREAM_H_

#include "nnet_common.h"
#include "nnet_conv_stream.h"
#include <ac_channel.h>
#include <ac_float.h>
namespace nnet {

template<class data_T, typename CONFIG_T>
void compute_scaled_indices_2d(
    const unsigned h_idx,
    const unsigned w_idx,
    ac_int<CONFIG_T::filt_height * CONFIG_T::filt_width, false> *pixel_idx
) {
    const unsigned sh_idx = scale_index<CONFIG_T::filt_height, CONFIG_T::stride_height, CONFIG_T::in_height>(h_idx);
    unsigned wp_idx = w_idx * (data_T::size / CONFIG_T::n_chan);

    ComputeIndex: for (unsigned p = 0; p < data_T::size / CONFIG_T::n_chan; p++) {

        unsigned sw_idx = scale_index<CONFIG_T::filt_width, CONFIG_T::stride_width, CONFIG_T::in_width>(wp_idx + p);
        pixel_idx[p] = CONFIG_T::pixels[sh_idx * CONFIG_T::min_width + sw_idx];
    }
}

template<class data_T, class res_T, typename CONFIG_T>
void conv_2d_cl(
    ac_channel<data_T> &data,
    ac_channel<res_T>  &res,
    typename CONFIG_T::weight_t weights[CONFIG_T::filt_height * CONFIG_T::filt_width * CONFIG_T::n_chan * CONFIG_T::n_filt],
    typename CONFIG_T::bias_t   biases[CONFIG_T::n_filt])
{
    assert(CONFIG_T::pad_top == 0 && CONFIG_T::pad_bottom == 0 && CONFIG_T::pad_left == 0 && CONFIG_T::pad_right == 0);
    assert(CONFIG_T::filt_height == CONFIG_T::filt_width);
    assert(CONFIG_T::stride_height <= CONFIG_T::filt_height && CONFIG_T::stride_width <= CONFIG_T::filt_width);

    ac_channel<typename data_T::value_type> data_window[CONFIG_T::filt_height * CONFIG_T::filt_width * CONFIG_T::n_chan];
    const int win_depth = CONFIG_T::filt_height * CONFIG_T::out_width;
    for (unsigned i_out = 0; i_out < CONFIG_T::filt_height * CONFIG_T::filt_width * CONFIG_T::n_chan; i_out++) {
    }


    res_T res_pack;
    unsigned outputs_ready = 0;

    ac_int<CONFIG_T::filt_height * CONFIG_T::filt_width, false> pixel_idx[data_T::size / CONFIG_T::n_chan];

    ReadInputHeight: for (unsigned i_ih = 0; i_ih < CONFIG_T::in_height; i_ih++) {
        ReadInputWidth: for (unsigned i_iw = 0; i_iw < CONFIG_T::in_width / (data_T::size / CONFIG_T::n_chan); i_iw++) {
            if (CONFIG_T::strategy == nnet::latency && data_T::size / CONFIG_T::n_chan == 1) {
            }
            compute_scaled_indices_2d<data_T, CONFIG_T>(i_ih, i_iw, pixel_idx);
            compute_output<data_T, res_T, CONFIG_T>(data.read(), data_window, res, res_pack, outputs_ready, weights, biases, pixel_idx);
        }
    }
}

}
#endif
