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

#ifndef _FULLY_CONNECTED_LAYER_H_
#define _FULLY_CONNECTED_LAYER_H_

#include "base_layer.h"

namespace mojo {

//----------------------------------------------------------------------------------------------------------
// F U L L Y   C O N N E C T E D
//
// fully connected layer
class fully_connected_layer : public base_layer {
  public:
    fully_connected_layer(const char *layer_name, int _size, int _relu) : base_layer(layer_name, 1, 1, _size) {
        relu = _relu;
        _use_bias = true;
        bias = matrix(node.cols, node.rows, node.chans);
        bias.fill(0.);
    }

    virtual std::string get_config_string() {
        std::stringstream str;
        str << "fully_connected " << node.size() << " "
            << "\n";
        return str.str();
    }

    virtual matrix *new_connection(base_layer &top, int weight_mat_index) {
        top.forward_linked_layers.push_back(std::make_pair((int)weight_mat_index, this));
        backward_linked_layers.push_back(std::make_pair((int)weight_mat_index, &top));

        int rows = node.cols * node.rows * node.chans;
        int top_cols = top.node.cols;
        int top_rows = top.node.rows;
        if (top.node.cols != 1)
            top_cols = top_cols / 2 - 1;
        if (top.node.rows != 1)
            top_rows = top_rows / 2 - 1;
        int cols = top_cols * top_rows * top.node.chans;
        return new matrix(cols, rows, 1);
    }
};

} // namespace

#endif // _FULLY_CONNECTED_LAYER_H_
