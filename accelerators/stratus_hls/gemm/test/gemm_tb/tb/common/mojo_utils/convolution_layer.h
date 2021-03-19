// == mojo ====================================================================
//
//    Copyright (c) gnawice@gnawice.com. All rights reserved.
//	  See LICENSE in root folder
//
//    Permission is hereby granted, free of charge, to any person obtaining a
//    copy of this software and associated documentation files(the "Software"),
//    to deal in the Software without restriction, including without
//    limitation the rights to use, copy, modify, merge, publish, distribute,
//    sublicense, and/or sell copies of the Software, and to permit persons to
//    whom the Software is furnished to do so, subject to the following
//    conditions :
//
//    The above copyright notice and this permission notice shall be included
//    in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//    OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//    THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// ============================================================================
//    layer.h:  defines layers for neural network
// ==================================================================== mojo ==

#ifndef _CONVOLUTION_LAYER_H_
#define _CONVOLUTION_LAYER_H_

#include "base_layer.h"

namespace mojo {

//----------------------------------------------------------------------------------------------------------
// C O N V O L U T I O N
//
class convolution_layer : public base_layer {
  public:
    convolution_layer(const char *layer_name, int _w, int _h, int _k, int _c, int _pool, int _pad)
        : base_layer(layer_name, _w, _h, _c) {
        kernel_rows = _k;
        kernel_cols = _k;
        kernels_per_chan = 0;
        do_pool = _pool;
        do_pad = _pad;
        pad_cols = kernel_cols - 1;
        pad_rows = kernel_rows - 1;
        _use_bias = true;
        bias = matrix(1, 1, _c);
        bias.fill(0.);
    }

    virtual ~convolution_layer() {}

    virtual std::string get_config_string() {
        std::stringstream str;
        str << "convolution " << kernel_cols << " " << node.chans << " "
            << " "
            << "\n";
        return str.str();
    }

    virtual int fan_size() { return kernel_rows * kernel_cols * node.chans * kernels_per_chan; }

    virtual matrix *new_connection(base_layer &top, int weight_mat_index) {
        top.forward_linked_layers.push_back(std::make_pair(weight_mat_index, this));
        backward_linked_layers.push_back(std::make_pair(weight_mat_index, &top));
        kernels_per_chan += top.node.chans;
        return new matrix(kernel_cols, kernel_rows, node.chans * kernels_per_chan);
    }
};

} // namespace

#endif // _CONVOLUTION_LAYER_H_
