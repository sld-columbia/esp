#ifndef DEFINES_H_
#define DEFINES_H_

#include <ac_fixed.h>

//hls-fpga-machine-learning insert numbers
#define N_INPUT_1_1 128
#define N_LAYER_2 64
#define N_LAYER_6 64
#define N_LAYER_10 8
#define N_LAYER_14 64
#define N_LAYER_18 64
#define N_LAYER_22 128

//hls-fpga-machine-learning insert layer-precision
typedef ac_fixed<8,8> input_1_default_t;
typedef ac_fixed<8,8> input_t;
typedef ac_fixed<5,3> model_default_t;
typedef ac_fixed<32,16> layer2_t;
typedef ac_fixed<6,1> weight2_t;
typedef ac_fixed<5,1> bias2_t;
typedef ac_fixed<32,16> layer4_t;
typedef ac_fixed<16,6> batch_normalization_scale_t;
typedef ac_fixed<16,6> batch_normalization_bias_t;
typedef ac_fixed<7,4> layer5_t;
typedef ac_fixed<32,16> layer6_t;
typedef ac_fixed<6,1> weight6_t;
typedef ac_fixed<9,4> bias6_t;
typedef ac_fixed<32,16> layer8_t;
typedef ac_fixed<16,6> batch_normalization_1_scale_t;
typedef ac_fixed<16,6> batch_normalization_1_bias_t;
typedef ac_fixed<5,3> layer9_t;
typedef ac_fixed<32,16> layer10_t;
typedef ac_fixed<8,1> weight10_t;
typedef ac_fixed<8,1> bias10_t;
typedef ac_fixed<32,16> layer12_t;
typedef ac_fixed<16,6> batch_normalization_2_scale_t;
typedef ac_fixed<16,6> batch_normalization_2_bias_t;
typedef ac_fixed<6,4> layer13_t;
typedef ac_fixed<32,16> layer14_t;
typedef ac_fixed<3,2> weight14_t;
typedef ac_fixed<7,1> bias14_t;
typedef ac_fixed<32,16> layer16_t;
typedef ac_fixed<16,6> batch_normalization_3_scale_t;
typedef ac_fixed<16,6> batch_normalization_3_bias_t;
typedef ac_fixed<6,4> layer17_t;
typedef ac_fixed<32,16> layer18_t;
typedef ac_fixed<6,1> weight18_t;
typedef ac_fixed<6,1> bias18_t;
typedef ac_fixed<32,16> layer20_t;
typedef ac_fixed<16,6> batch_normalization_4_scale_t;
typedef ac_fixed<16,6> batch_normalization_4_bias_t;
typedef ac_fixed<5,3> layer21_t;
typedef ac_fixed<32,16> layer22_t;
typedef ac_fixed<5,1> weight22_t;
typedef ac_fixed<9,4> bias22_t;

#endif
