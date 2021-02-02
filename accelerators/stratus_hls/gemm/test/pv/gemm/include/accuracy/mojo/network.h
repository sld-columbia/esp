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
//    network.h: The main artificial neural network graph for mojo
// ==================================================================== mojo ==

#ifndef _NETWORK_H_
#define _NETWORK_H_

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>

#include "base_layer.h"
#include "convolution_layer.h"
#include "fully_connected_layer.h"
#include "input_layer.h"

namespace mojo {

//--------------------------------------------------
// N E W    L A Y E R
//
// "input", "fully_connected","max_pool","convolution","concatination"
	base_layer *new_layer(const char *layer_name, const char *config)
	{
		std::istringstream iss(config);
		std::string str;
		iss >> str;
		int w, h, k, c;
		int do_pool, do_pad, relu;
		if(str.compare("input") == 0)
		{
			iss >> w; iss >> h; iss >> c;
			return new input_layer(layer_name, w, h, c);
		}
		else if(str.compare("fully_connected") == 0)
		{
			iss >> c; iss >> relu;
			return new fully_connected_layer(layer_name, c, relu);
		}
		else if(str.compare("convolution") == 0)
		{
			iss >> w; iss >> h; iss >> k; iss >> c; iss >> do_pool; iss >> do_pad;
			return new convolution_layer(layer_name, w, h, k, c, do_pool, do_pad);
		}
		else
		{
			std::cout << "ERROR : layer type not valid: '" << str  << "'\n";
			exit(-1);
		}

		return NULL;
	}

	// returns Energy (euclidian distance / 2) and max index
	float match_labels(const float *out, const float *target, const int size, int *best_index = NULL)
	{
		float E = 0;
		int max_j = 0;
		for (int j = 0; j<size; j++)
		{
			E += (out[j] - target[j])*(out[j] - target[j]);
			if (out[max_j]<out[j]) max_j = j;
		}
		if (best_index) *best_index = max_j;
		E *= 0.5;
		return E;
	}

	// returns index of highest value (argmax)
	int arg_max(const float *out, const int size)
	{
		int max_j = 0;
		for (int j = 0; j<size; j++)
			if (out[max_j]<out[j])
			{max_j = j; }
		return max_j;
	}

//----------------------------------------------------------------------
//  network
//  - class that holds all the layers and connection information
//	- runs forward prediction

	class network
	{

		int _size;
	public:
		std::vector<base_layer *> layer_sets;

		std::map<std::string, int> layer_map;  // name-to-index of layer for layer management
		std::vector<std::pair<std::string, std::string> > layer_graph; // pairs of names of layers that are connected
		std::vector<matrix *> W; // these are the weights between/connecting layers

		network(const char* opt_name=NULL)
			{
				_size=0;
			}

		~network()
			{
				clear();
			}

		// call clear if you want to load a different configuration/model
		void clear()
			{
				layer_sets.clear();
				for (int i = 0; i < (int) W.size(); i++)
					if(W[i])
						delete W[i];
				W.clear();
				layer_map.clear();
				layer_graph.clear();
			}

		// output size of final layer;
		int out_size() {return _size;}

		// get input size
		bool get_input_size(int *w, int *h, int *c)
			{
				if(layer_sets.size() < 1)
					return false;
				*w = layer_sets[0]->node.cols;
				*h = layer_sets[0]->node.rows;
				*c = layer_sets[0]->node.chans;
				return true;
			}

		// used to push a layer back in the ORDERED list of layers
		// if connect_all() is used, then the order of the push_back is used to connect the layers
		// when forward or backward propogation, this order is used for the serialized order of calculations
		// Layer_name must be unique.
		bool push_back(const char *layer_name, const char *layer_config)
			{
				if (layer_map[layer_name])
					return false; //already exists
				base_layer *l = new_layer(layer_name, layer_config);
				// set map to index
				layer_map[layer_name] = (int) layer_sets.size();
				layer_sets.push_back(l);
				// update as potential last layer - so it sets the out size
				_size = l->fan_size();
				return true;
			}

		// connect 2 layers together and initialize weights
		// top and bottom concepts are reversed from literature
		// my 'top' is the input of a forward() pass and the 'bottom' is the output
		// perhaps 'top' traditionally comes from the brain model, but my 'top' comes
		// from reading order (information flows top to bottom)
		void connect(const char *layer_name_top, const char *layer_name_bottom)
			{
				size_t i_top = layer_map[layer_name_top];
				size_t i_bottom = layer_map[layer_name_bottom];

				base_layer *l_top = layer_sets[i_top];
				base_layer *l_bottom = layer_sets[i_bottom];

				int w_i = (int) W.size();
				matrix *w = l_bottom->new_connection(*l_top, w_i);
				W.push_back(w);
				layer_graph.push_back(std::make_pair(layer_name_top,layer_name_bottom));
			}

		// automatically connect all layers in the order they were provided
		// easy way to go, but can't deal with branch/highway/resnet/inception types of architectures
		void connect_all()
			{
				for(int j=0; j < (int) layer_sets.size() - 1; j++)
					connect(layer_sets[j]->name.c_str(), layer_sets[j+1]->name.c_str());
			}

		int get_layer_index(const char *name)
			{
				for (int j = 0; j < (int)layer_sets.size(); j++)
					if (layer_sets[j]->name.compare(name) == 0)
						return j;
				return -1;
			}

		// get the list of layers used (but not connection information)
		std::string get_configuration()
			{
				std::string str;
				// print all layer configs
				for (int j = 0; j<(int)layer_sets.size(); j++)
					str += "  " +
						layer_sets[j]->name + " : " +
						layer_sets[j]->get_config_string();
				str += "\n";
				// print layer links
				if (layer_graph.size() <= 0) return str;

				for (int j = 0; j < (int)layer_graph.size(); j++)
				{
					if (j % 3 == 0) str += "  ";
					if((j % 3 == 1)|| (j % 3 == 2)) str += ", ";
					str +=layer_graph[j].first + "-" + layer_graph[j].second;
					if (j % 3 == 2) str += "\n";
				}
				return str;
			}


		//----------------------------------------------------------------------------------------------------------
		// F O R W A R D
		//
		// the main forward pass
		void forward_setup(const float *in)
			{
				// clear nodes to zero
				for (int i = 0; i < (int) layer_sets.size(); i++)
				{
					base_layer *layer = layer_sets[i];
					layer->node.fill(0.f);
				}

				// first layer assumed input. copy input to it
				const float *in_ptr = in;

				base_layer *layer = layer_sets[0];
				const int pad = 2;
				const int cols = layer->node.cols;
				const int rows = layer->node.rows;
				const int chans = layer->node.chans;
				const int stride = cols * rows;

				for (int c = 0; c < chans; c++)
					for (int j = 1; j < rows - 1; j ++)
					{
						memcpy(&layer->node.x[c * stride  + j * cols + 1], in_ptr, sizeof(float) * (cols - pad));
						in_ptr += (cols - pad);
					}
			}


		//----------------------------------------------------------------------------------------------------------
		// R E A D
		//
		std::string getcleanline(std::istream& ifs)
			{
				std::string s;

				// The characters in the stream are read one-by-one using a std::streambuf.
				// That is faster than reading them one-by-one using the std::istream.
				// Code that uses streambuf this way must be guarded by a sentry object.
				std::istream::sentry se(ifs, true);
				std::streambuf* sb = ifs.rdbuf();

				for (;;) {
					int c = sb->sbumpc();
					switch (c) {
					case '\n':
						return s;
					case '\r':
						if (sb->sgetc() == '\n') sb->sbumpc();
						return s;
					case EOF:
						// Also handle the case when the last line has no line ending
						if (s.empty()) ifs.setstate(std::ios::eofbit);
						return s;
					default:
						s += (char)c;
					}
				}
			}

		bool read(std::istream &ifs)
			{
				if(!ifs.good()) return false;
				std::string s;
				s = getcleanline(ifs);
				int layer_count;
				s = getcleanline(ifs);
				layer_count = atoi(s.c_str());

				// read layer def
				std::string layer_name;
				std::string layer_def;
				for (int i = 0; i < layer_count; i++)
				{
					layer_name = getcleanline(ifs);
					layer_def = getcleanline(ifs);
					std::cout << "  l" << i << ": " << layer_name.c_str() << " - " << layer_def.c_str() <<  std::endl;
					push_back(layer_name.c_str(), layer_def.c_str());
				}
				std::cout << std::endl;

				connect_all();

				// binary weigths
				for(int j = 0; j < (int) layer_sets.size(); j++)
					if (layer_sets[j]->use_bias())
						ifs.read((char*) layer_sets[j]->bias.x, layer_sets[j]->bias.size() * sizeof(float));
				for (int j = 0; j < (int) W.size(); j++)
					if (W[j])
						ifs.read((char*) W[j]->x, W[j]->size() * sizeof(float));
				return true;
			}

		bool read(std::string filename)
			{
				std::ifstream fs(filename.c_str(),std::ios::binary);
				if (fs.is_open())
				{
					bool ret = read(fs);
					fs.close();
					return ret;
				}
				else return false;
			}

		bool read(const char *filename)
			{
				return  read(std::string(filename));
			}
	};
}

#endif // _NETWORK_H_
