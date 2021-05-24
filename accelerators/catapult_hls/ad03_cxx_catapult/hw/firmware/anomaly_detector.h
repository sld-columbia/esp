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

#ifndef ANOMALY_DETECTOR_H_
#define ANOMALY_DETECTOR_H_

#include "defines.h"


// Prototype of top level function for C-synthesis
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
);

#endif
