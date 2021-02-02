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


#ifndef _BASE_LAYER_H_
#define _BASE_LAYER_H_

#include <string>
#include <sstream>

#include "matrix.h"

namespace mojo
{

//----------------------------------------------------------------------------------------------------------
// B A S E   L A Y E R
//
// all other layers derived from this
	class base_layer
	{
	protected:
		bool _has_weights;
		bool _use_bias;

	public:
		// Used for convolution only
		int kernel_rows;
		int kernel_cols;
		int kernels_per_chan;
		bool do_pool;
		bool do_pad;

		// Used for fully connected only
		bool relu;

		bool has_weights() { return _has_weights; }
		bool use_bias() { return _use_bias; }

		int pad_cols, pad_rows;
		matrix node;
		matrix bias;

		std::string name;
		// index of W matrix, index of connected layer
		std::vector<std::pair<int,base_layer*> > forward_linked_layers;
		std::vector<std::pair<int,base_layer*> > backward_linked_layers;

		base_layer(const char* layer_name, int _w, int _h=1, int _c=1)
			: _has_weights(true),
			  _use_bias(false),
			  kernel_rows(0),
			  kernel_cols(0),
			  kernels_per_chan(0),
			  pad_cols(0),
			  pad_rows(0),
			  node(_w, _h, _c),
			  name(layer_name)
			{}

		virtual ~base_layer() { }

		virtual int fan_size() { return node.chans * node.rows * node.cols; }

		virtual matrix * new_connection(base_layer &top, int weight_mat_index)
			{
				top.forward_linked_layers.push_back(std::make_pair((int)weight_mat_index,this));
				backward_linked_layers.push_back(std::make_pair((int)weight_mat_index,&top));
				if (_has_weights)
				{
					int rows = node.cols * node.rows * node.chans;
					int cols = top.node.cols * top.node.rows * top.node.chans;
					return new matrix(cols, rows, 1);
				}
				else
					return NULL;
			}

		virtual std::string get_config_string() =0;
	};

} // namespace

#endif // _BASE_LAYER_H_
