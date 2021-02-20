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

#ifndef _INPUT_LAYER_H_
#define _INPUT_LAYER_H_

#include "base_layer.h"

namespace mojo {

//----------------------------------------------------------------------------------------------------------
// I N P U T   L A Y E R
//
// input layer class - can be 1D, 2D (c=1), or stacked 2D (c>1)
class input_layer : public base_layer {
  public:
    input_layer(const char *layer_name, int _w, int _h = 1, int _c = 1) : base_layer(layer_name, _w, _h, _c) {}

    virtual ~input_layer() {}

    virtual std::string get_config_string() {
        std::stringstream str;
        str << "input " << node.cols << " " << node.rows << " " << node.chans << " "
            << "\n";
        return str.str();
    }
};

} // namespace

#endif // _INPUT_LAYER_H_
