#ifndef PARAMETERS_H_
#define PARAMETERS_H_

#include <ac_fixed.h>

#include "nnet_utils/nnet_helpers.h"
//hls-fpga-machine-learning insert includes
#include "nnet_utils/nnet_activation.h"
#include "nnet_utils/nnet_activation_stream.h"
#include "nnet_utils/nnet_batchnorm.h"
#include "nnet_utils/nnet_batchnorm_stream.h"
#include "nnet_utils/nnet_dense.h"
#include "nnet_utils/nnet_dense_compressed.h"
#include "nnet_utils/nnet_dense_stream.h"
 
//hls-fpga-machine-learning insert weights
#include "weights/w2.h"
#include "weights/b2.h"
#include "weights/s4.h"
#include "weights/b4.h"
#include "weights/w6.h"
#include "weights/b6.h"
#include "weights/s8.h"
#include "weights/b8.h"
#include "weights/w10.h"
#include "weights/b10.h"
#include "weights/s12.h"
#include "weights/b12.h"
#include "weights/w14.h"
#include "weights/b14.h"
#include "weights/s16.h"
#include "weights/b16.h"
#include "weights/w18.h"
#include "weights/b18.h"
#include "weights/s20.h"
#include "weights/b20.h"
#include "weights/w22.h"
#include "weights/b22.h"

//hls-fpga-machine-learning insert layer-config
struct config2 : nnet::dense_config {
    static const unsigned n_in = N_INPUT_1_1;
    static const unsigned n_out = N_LAYER_2;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned strategy = nnet::resource;
    static const unsigned reuse_factor = 4096;
    static const unsigned n_zeros = 1063;
    static const unsigned n_nonzeros = 7129;
    static const bool store_weights_in_bram = false;
    typedef ac_fixed<32,16> accum_t;
    typedef bias2_t bias_t;
    typedef weight2_t weight_t;
    typedef ac_int<1, false> index_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct config4 : nnet::batchnorm_config {
    static const unsigned n_in = N_LAYER_2;
    static const int n_filt = -1;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    static const bool store_weights_in_bram = false;
    typedef batch_normalization_bias_t bias_t;
    typedef batch_normalization_scale_t scale_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct relu_config5 : nnet::activ_config {
    static const unsigned n_in = N_LAYER_2;
    static const unsigned table_size = 1024;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    typedef ac_fixed<18,8> table_t;
};

struct config6 : nnet::dense_config {
    static const unsigned n_in = N_LAYER_2;
    static const unsigned n_out = N_LAYER_6;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned strategy = nnet::resource;
    static const unsigned reuse_factor = 4096;
    static const unsigned n_zeros = 435;
    static const unsigned n_nonzeros = 3661;
    static const bool store_weights_in_bram = false;
    typedef ac_fixed<32,16> accum_t;
    typedef bias6_t bias_t;
    typedef weight6_t weight_t;
    typedef ac_int<1, false> index_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct config8 : nnet::batchnorm_config {
    static const unsigned n_in = N_LAYER_6;
    static const int n_filt = -1;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    static const bool store_weights_in_bram = false;
    typedef batch_normalization_1_bias_t bias_t;
    typedef batch_normalization_1_scale_t scale_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct relu_config9 : nnet::activ_config {
    static const unsigned n_in = N_LAYER_6;
    static const unsigned table_size = 1024;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    typedef ac_fixed<18,8> table_t;
};

struct config10 : nnet::dense_config {
    static const unsigned n_in = N_LAYER_6;
    static const unsigned n_out = N_LAYER_10;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned strategy = nnet::resource;
    static const unsigned reuse_factor = 512;
    static const unsigned n_zeros = 10;
    static const unsigned n_nonzeros = 502;
    static const bool store_weights_in_bram = false;
    typedef ac_fixed<32,16> accum_t;
    typedef bias10_t bias_t;
    typedef weight10_t weight_t;
    typedef ac_int<1, false> index_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct config12 : nnet::batchnorm_config {
    static const unsigned n_in = N_LAYER_10;
    static const int n_filt = -1;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    static const bool store_weights_in_bram = false;
    typedef batch_normalization_2_bias_t bias_t;
    typedef batch_normalization_2_scale_t scale_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct relu_config13 : nnet::activ_config {
    static const unsigned n_in = N_LAYER_10;
    static const unsigned table_size = 1024;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    typedef ac_fixed<18,8> table_t;
};

struct config14 : nnet::dense_config {
    static const unsigned n_in = N_LAYER_10;
    static const unsigned n_out = N_LAYER_14;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned strategy = nnet::resource;
    static const unsigned reuse_factor = 512;
    static const unsigned n_zeros = 144;
    static const unsigned n_nonzeros = 368;
    static const bool store_weights_in_bram = false;
    typedef ac_fixed<32,16> accum_t;
    typedef bias14_t bias_t;
    typedef weight14_t weight_t;
    typedef ac_int<1, false> index_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct config16 : nnet::batchnorm_config {
    static const unsigned n_in = N_LAYER_14;
    static const int n_filt = -1;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    static const bool store_weights_in_bram = false;
    typedef batch_normalization_3_bias_t bias_t;
    typedef batch_normalization_3_scale_t scale_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct relu_config17 : nnet::activ_config {
    static const unsigned n_in = N_LAYER_14;
    static const unsigned table_size = 1024;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    typedef ac_fixed<18,8> table_t;
};

struct config18 : nnet::dense_config {
    static const unsigned n_in = N_LAYER_14;
    static const unsigned n_out = N_LAYER_18;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned strategy = nnet::resource;
    static const unsigned reuse_factor = 4096;
    static const unsigned n_zeros = 462;
    static const unsigned n_nonzeros = 3634;
    static const bool store_weights_in_bram = false;
    typedef ac_fixed<32,16> accum_t;
    typedef bias18_t bias_t;
    typedef weight18_t weight_t;
    typedef ac_int<1, false> index_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct config20 : nnet::batchnorm_config {
    static const unsigned n_in = N_LAYER_18;
    static const int n_filt = -1;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    static const bool store_weights_in_bram = false;
    typedef batch_normalization_4_bias_t bias_t;
    typedef batch_normalization_4_scale_t scale_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};

struct relu_config21 : nnet::activ_config {
    static const unsigned n_in = N_LAYER_18;
    static const unsigned table_size = 1024;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned reuse_factor = 4096;
    typedef ac_fixed<18,8> table_t;
};

struct config22 : nnet::dense_config {
    static const unsigned n_in = N_LAYER_18;
    static const unsigned n_out = N_LAYER_22;
    static const unsigned io_type = nnet::io_parallel;
    static const unsigned strategy = nnet::resource;
    static const unsigned reuse_factor = 4096;
    static const unsigned n_zeros = 440;
    static const unsigned n_nonzeros = 7752;
    static const bool store_weights_in_bram = false;
    typedef ac_fixed<32,16> accum_t;
    typedef bias22_t bias_t;
    typedef weight22_t weight_t;
    typedef ac_int<1, false> index_t;
    template<class x_T, class y_T, class res_T>
    using product = nnet::product::mult<x_T, y_T, res_T>;
};


#endif
