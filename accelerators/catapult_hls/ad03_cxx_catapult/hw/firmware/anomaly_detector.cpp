//
//    rfnoc-hls-neuralnet: Vivado HLS code for neural-net building blocks
//
//    Copyright (C) 2017 EJ Kreinar
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
#include <iostream>

#include "anomaly_detector.h"
#include "parameters.h"

void anomaly_detector(
    input_t input_1[N_INPUT_1_1],
    layer22_t layer22_out[N_LAYER_22],
    unsigned short &const_size_in_1,
    unsigned short &const_size_out_1
#if 0
    ,
	//hls-fpga-machine-learning insert weights ports
    weight2_t w2[8192],
    bias2_t b2[64],
    batch_normalization_scale_t s4[64],
    batch_normalization_bias_t b4[64],
    weight6_t w6[4096],
    bias6_t b6[64],
    batch_normalization_1_scale_t s8[64],
    batch_normalization_1_bias_t b8[64],
    weight10_t w10[512],
    bias10_t b10[8],
    batch_normalization_2_scale_t s12[8],
    batch_normalization_2_bias_t b12[8],
    weight14_t w14[512],
    bias14_t b14[64],
    batch_normalization_3_scale_t s16[64],
    batch_normalization_3_bias_t b16[64],
    weight18_t w18[4096],
    bias18_t b18[64],
    batch_normalization_4_scale_t s20[64],
    batch_normalization_4_bias_t b20[64],
    weight22_t w22[8192],
    bias22_t b22[128]
#endif
) {

    //hls-fpga-machine-learning insert IO
    //#pragma HLS ARRAY_RESHAPE variable=input_1 complete dim=0
    //#pragma HLS ARRAY_PARTITION variable=layer22_out complete dim=0
    //#pragma HLS INTERFACE ap_vld port=input_1,layer22_out 
    //#pragma HLS DATAFLOW 

    const_size_in_1 = N_INPUT_1_1;
    const_size_out_1 = N_LAYER_22;

    // ****************************************
    // NETWORK INSTANTIATION
    // ****************************************

    //hls-fpga-machine-learning insert layers

    layer2_t layer2_out[N_LAYER_2];
    //#pragma HLS ARRAY_PARTITION variable=layer2_out complete dim=0
    //#pragma HLS STABLE variable=layer2_out
    nnet::dense<input_t, layer2_t, config2>(input_1, layer2_out, w2, b2);

    layer4_t layer4_out[N_LAYER_2];
    //#pragma HLS ARRAY_PARTITION variable=layer4_out complete dim=0
    //#pragma HLS STABLE variable=layer4_out
    nnet::normalize<layer2_t, layer4_t, config4>(layer2_out, layer4_out, s4, b4);

    layer5_t layer5_out[N_LAYER_2];
    //#pragma HLS ARRAY_PARTITION variable=layer5_out complete dim=0
    //#pragma HLS STABLE variable=layer5_out
    nnet::relu<layer4_t, layer5_t, relu_config5>(layer4_out, layer5_out);

    layer6_t layer6_out[N_LAYER_6];
    //#pragma HLS ARRAY_PARTITION variable=layer6_out complete dim=0
    //#pragma HLS STABLE variable=layer6_out
    nnet::dense<layer5_t, layer6_t, config6>(layer5_out, layer6_out, w6, b6);

    layer8_t layer8_out[N_LAYER_6];
    //#pragma HLS ARRAY_PARTITION variable=layer8_out complete dim=0
    //#pragma HLS STABLE variable=layer8_out
    nnet::normalize<layer6_t, layer8_t, config8>(layer6_out, layer8_out, s8, b8);

    layer9_t layer9_out[N_LAYER_6];
    //#pragma HLS ARRAY_PARTITION variable=layer9_out complete dim=0
    //#pragma HLS STABLE variable=layer9_out
    nnet::relu<layer8_t, layer9_t, relu_config9>(layer8_out, layer9_out);

    layer10_t layer10_out[N_LAYER_10];
    //#pragma HLS ARRAY_PARTITION variable=layer10_out complete dim=0
    //#pragma HLS STABLE variable=layer10_out
    nnet::dense<layer9_t, layer10_t, config10>(layer9_out, layer10_out, w10, b10);

    layer12_t layer12_out[N_LAYER_10];
    //#pragma HLS ARRAY_PARTITION variable=layer12_out complete dim=0
    //#pragma HLS STABLE variable=layer12_out
    nnet::normalize<layer10_t, layer12_t, config12>(layer10_out, layer12_out, s12, b12);

    layer13_t layer13_out[N_LAYER_10];
    //#pragma HLS ARRAY_PARTITION variable=layer13_out complete dim=0
    //#pragma HLS STABLE variable=layer13_out
    nnet::relu<layer12_t, layer13_t, relu_config13>(layer12_out, layer13_out);

    layer14_t layer14_out[N_LAYER_14];
    //#pragma HLS ARRAY_PARTITION variable=layer14_out complete dim=0
    //#pragma HLS STABLE variable=layer14_out
    nnet::dense<layer13_t, layer14_t, config14>(layer13_out, layer14_out, w14, b14);

    layer16_t layer16_out[N_LAYER_14];
    //#pragma HLS ARRAY_PARTITION variable=layer16_out complete dim=0
    //#pragma HLS STABLE variable=layer16_out
    nnet::normalize<layer14_t, layer16_t, config16>(layer14_out, layer16_out, s16, b16);

    layer17_t layer17_out[N_LAYER_14];
    //#pragma HLS ARRAY_PARTITION variable=layer17_out complete dim=0
    //#pragma HLS STABLE variable=layer17_out
    nnet::relu<layer16_t, layer17_t, relu_config17>(layer16_out, layer17_out);

    layer18_t layer18_out[N_LAYER_18];
    //#pragma HLS ARRAY_PARTITION variable=layer18_out complete dim=0
    //#pragma HLS STABLE variable=layer18_out
    nnet::dense<layer17_t, layer18_t, config18>(layer17_out, layer18_out, w18, b18);

    layer20_t layer20_out[N_LAYER_18];
    //#pragma HLS ARRAY_PARTITION variable=layer20_out complete dim=0
    //#pragma HLS STABLE variable=layer20_out
    nnet::normalize<layer18_t, layer20_t, config20>(layer18_out, layer20_out, s20, b20);

    layer21_t layer21_out[N_LAYER_18];
    //#pragma HLS ARRAY_PARTITION variable=layer21_out complete dim=0
    //#pragma HLS STABLE variable=layer21_out
    nnet::relu<layer20_t, layer21_t, relu_config21>(layer20_out, layer21_out);

    nnet::dense<layer21_t, layer22_t, config22>(layer21_out, layer22_out, w22, b22);

}
