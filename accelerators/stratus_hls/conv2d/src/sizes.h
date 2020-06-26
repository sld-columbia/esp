// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SIZES_H__
#define __SIZES_H__

#define features_size(H, W, C) (H) * (W) * (C)
#define weights_size(H, W, CI, CO) (H) * (W) * (CI) * (CO)
#define patches_size(H, W, HW, WW, CI) (H) * (W) * (HW) * (WW) * (CI)

/* conv1_1 */
#define CONV1_1_F_HEIGHT       224
#define CONV1_1_F_WIDTH        224
#define CONV1_1_F_CHANNELS       3

#define CONV1_1_W_HEIGHT         3
#define CONV1_1_W_WIDTH          3
#define CONV1_1_W_IN_CHANNELS    3
#define CONV1_1_W_OUT_CHANNELS  64

#define CONV1_1_F_SIZE features_size(CONV1_1_F_HEIGHT, CONV1_1_F_WIDTH, CONV1_1_F_CHANNELS)
#define CONV1_1_W_SIZE weights_size(CONV1_1_W_HEIGHT, CONV1_1_W_WIDTH, CONV1_1_W_IN_CHANNELS, CONV1_1_W_OUT_CHANNELS)
#define CONV1_1_P_SIZE patches_size(CONV1_1_F_HEIGHT, CONV1_1_F_WIDTH, CONV1_1_W_HEIGHT, CONV1_1_W_WIDTH, CONV1_1_W_IN_CHANNELS)

/* conv1_2 */ /* biggest features */
#define CONV1_2_F_HEIGHT       224
#define CONV1_2_F_WIDTH        224
#define CONV1_2_F_CHANNELS      64

#define CONV1_2_W_HEIGHT         3
#define CONV1_2_W_WIDTH          3
#define CONV1_2_W_IN_CHANNELS   64
#define CONV1_2_W_OUT_CHANNELS  64

#define CONV1_2_F_SIZE features_size(CONV1_2_F_HEIGHT, CONV1_2_F_WIDTH, CONV1_2_F_CHANNELS)
#define CONV1_2_W_SIZE weights_size(CONV1_2_W_HEIGHT, CONV1_2_W_WIDTH, CONV1_2_W_IN_CHANNELS, CONV1_2_W_OUT_CHANNELS)
#define CONV1_2_P_SIZE patches_size(CONV1_2_F_HEIGHT, CONV1_2_F_WIDTH, CONV1_2_W_HEIGHT, CONV1_2_W_WIDTH, CONV1_2_W_IN_CHANNELS)

/* conv2_1 */
#define CONV2_1_F_HEIGHT       112
#define CONV2_1_F_WIDTH        112
#define CONV2_1_F_CHANNELS      64

#define CONV2_1_W_HEIGHT         3
#define CONV2_1_W_WIDTH          3
#define CONV2_1_W_IN_CHANNELS   64
#define CONV2_1_W_OUT_CHANNELS 128

#define CONV2_1_F_SIZE features_size(CONV2_1_F_HEIGHT, CONV2_1_F_WIDTH, CONV2_1_F_CHANNELS)
#define CONV2_1_W_SIZE weights_size(CONV2_1_W_HEIGHT, CONV2_1_W_WIDTH, CONV2_1_W_IN_CHANNELS, CONV2_1_W_OUT_CHANNELS)
#define CONV2_1_P_SIZE patches_size(CONV2_1_F_HEIGHT, CONV2_1_F_WIDTH, CONV2_1_W_HEIGHT, CONV2_1_W_WIDTH, CONV2_1_W_IN_CHANNELS)

/* conv2_2 */
#define CONV2_2_F_HEIGHT       112
#define CONV2_2_F_WIDTH        112
#define CONV2_2_F_CHANNELS     128

#define CONV2_2_W_HEIGHT         3
#define CONV2_2_W_WIDTH          3
#define CONV2_2_W_IN_CHANNELS  128
#define CONV2_2_W_OUT_CHANNELS 128

#define CONV2_2_F_SIZE features_size(CONV2_2_F_HEIGHT, CONV2_2_F_WIDTH, CONV2_2_F_CHANNELS)
#define CONV2_2_W_SIZE weights_size(CONV2_2_W_HEIGHT, CONV2_2_W_WIDTH, CONV2_2_W_IN_CHANNELS, CONV2_2_W_OUT_CHANNELS)
#define CONV2_2_P_SIZE patches_size(CONV2_2_F_HEIGHT, CONV2_2_F_WIDTH, CONV2_2_W_HEIGHT, CONV2_2_W_WIDTH, CONV2_2_W_IN_CHANNELS)

/* conv3_1 */
#define CONV3_1_F_HEIGHT        56
#define CONV3_1_F_WIDTH         56
#define CONV3_1_F_CHANNELS     128

#define CONV3_1_W_HEIGHT         3
#define CONV3_1_W_WIDTH          3
#define CONV3_1_W_IN_CHANNELS  128 
#define CONV3_1_W_OUT_CHANNELS 256 

#define CONV3_1_F_SIZE features_size(CONV3_1_F_HEIGHT, CONV3_1_F_WIDTH, CONV3_1_F_CHANNELS)
#define CONV3_1_W_SIZE weights_size(CONV3_1_W_HEIGHT, CONV3_1_W_WIDTH, CONV3_1_W_IN_CHANNELS, CONV3_1_W_OUT_CHANNELS)
#define CONV3_1_P_SIZE patches_size(CONV3_1_F_HEIGHT, CONV3_1_F_WIDTH, CONV3_1_W_HEIGHT, CONV3_1_W_WIDTH, CONV3_1_W_IN_CHANNELS)

/* conv3_2 */
#define CONV3_2_F_HEIGHT        56
#define CONV3_2_F_WIDTH         56
#define CONV3_2_F_CHANNELS     256

#define CONV3_2_W_HEIGHT         3
#define CONV3_2_W_WIDTH          3
#define CONV3_2_W_IN_CHANNELS  256
#define CONV3_2_W_OUT_CHANNELS 256

#define CONV3_2_F_SIZE features_size(CONV3_2_F_HEIGHT, CONV3_2_F_WIDTH, CONV3_2_F_CHANNELS)
#define CONV3_2_W_SIZE weights_size(CONV3_2_W_HEIGHT, CONV3_2_W_WIDTH, CONV3_2_W_IN_CHANNELS, CONV3_2_W_OUT_CHANNELS)
#define CONV3_2_P_SIZE patches_size(CONV3_2_F_HEIGHT, CONV3_2_F_WIDTH, CONV3_2_W_HEIGHT, CONV3_2_W_WIDTH, CONV3_2_W_IN_CHANNELS)

/* conv3_3 */
#define CONV3_3_F_HEIGHT        56
#define CONV3_3_F_WIDTH         56
#define CONV3_3_F_CHANNELS     256

#define CONV3_3_W_HEIGHT         3
#define CONV3_3_W_WIDTH          3
#define CONV3_3_W_IN_CHANNELS  256
#define CONV3_3_W_OUT_CHANNELS 256

#define CONV3_3_F_SIZE features_size(CONV3_3_F_HEIGHT, CONV3_3_F_WIDTH, CONV3_3_F_CHANNELS)
#define CONV3_3_W_SIZE weights_size(CONV3_3_W_HEIGHT, CONV3_3_W_WIDTH, CONV3_3_W_IN_CHANNELS, CONV3_3_W_OUT_CHANNELS)
#define CONV3_3_P_SIZE patches_size(CONV3_3_F_HEIGHT, CONV3_3_F_WIDTH, CONV3_3_W_HEIGHT, CONV3_3_W_WIDTH, CONV3_3_W_IN_CHANNELS)

/* conv4_1 */
#define CONV4_1_F_HEIGHT        28
#define CONV4_1_F_WIDTH         28
#define CONV4_1_F_CHANNELS     256

#define CONV4_1_W_HEIGHT         3
#define CONV4_1_W_WIDTH          3
#define CONV4_1_W_IN_CHANNELS  256
#define CONV4_1_W_OUT_CHANNELS 512

#define CONV4_1_F_SIZE features_size(CONV4_1_F_HEIGHT, CONV4_1_F_WIDTH, CONV4_1_F_CHANNELS)
#define CONV4_1_W_SIZE weights_size(CONV4_1_W_HEIGHT, CONV4_1_W_WIDTH, CONV4_1_W_IN_CHANNELS, CONV4_1_W_OUT_CHANNELS)
#define CONV4_1_P_SIZE patches_size(CONV4_1_F_HEIGHT, CONV4_1_F_WIDTH, CONV4_1_W_HEIGHT, CONV4_1_W_WIDTH, CONV4_1_W_IN_CHANNELS)

/* conv4_2 */ /* biggest weights */
#define CONV4_2_F_HEIGHT        28
#define CONV4_2_F_WIDTH         28
#define CONV4_2_F_CHANNELS     512

#define CONV4_2_W_HEIGHT         3
#define CONV4_2_W_WIDTH          3
#define CONV4_2_W_IN_CHANNELS  512
#define CONV4_2_W_OUT_CHANNELS 512

#define CONV4_2_F_SIZE features_size(CONV4_2_F_HEIGHT, CONV4_2_F_WIDTH, CONV4_2_F_CHANNELS)
#define CONV4_2_W_SIZE weights_size(CONV4_2_W_HEIGHT, CONV4_2_W_WIDTH, CONV4_2_W_IN_CHANNELS, CONV4_2_W_OUT_CHANNELS)
#define CONV4_2_P_SIZE patches_size(CONV4_2_F_HEIGHT, CONV4_2_F_WIDTH, CONV4_2_W_HEIGHT, CONV4_2_W_WIDTH, CONV4_2_W_IN_CHANNELS)

/* conv4_3 */ /* biggest weights */
#define CONV4_3_F_HEIGHT        28
#define CONV4_3_F_WIDTH         28
#define CONV4_3_F_CHANNELS     512

#define CONV4_3_W_HEIGHT         3
#define CONV4_3_W_WIDTH          3
#define CONV4_3_W_IN_CHANNELS  512
#define CONV4_3_W_OUT_CHANNELS 512

#define CONV4_3_F_SIZE features_size(CONV4_3_F_HEIGHT, CONV4_3_F_WIDTH, CONV4_3_F_CHANNELS)
#define CONV4_3_W_SIZE weights_size(CONV4_3_W_HEIGHT, CONV4_3_W_WIDTH, CONV4_3_W_IN_CHANNELS, CONV4_3_W_OUT_CHANNELS)
#define CONV4_3_P_SIZE patches_size(CONV4_3_F_HEIGHT, CONV4_3_F_WIDTH, CONV4_3_W_HEIGHT, CONV4_3_W_WIDTH, CONV4_3_W_IN_CHANNELS)

/* conv5_1 */ /* biggest weights */
#define CONV5_1_F_HEIGHT        14
#define CONV5_1_F_WIDTH         14
#define CONV5_1_F_CHANNELS     512

#define CONV5_1_W_HEIGHT         3
#define CONV5_1_W_WIDTH          3
#define CONV5_1_W_IN_CHANNELS  512
#define CONV5_1_W_OUT_CHANNELS 512

#define CONV5_1_F_SIZE features_size(CONV5_1_F_HEIGHT, CONV5_1_F_WIDTH, CONV5_1_F_CHANNELS)
#define CONV5_1_W_SIZE weights_size(CONV5_1_W_HEIGHT, CONV5_1_W_WIDTH, CONV5_1_W_IN_CHANNELS, CONV5_1_W_OUT_CHANNELS)
#define CONV5_1_P_SIZE patches_size(CONV5_1_F_HEIGHT, CONV5_1_F_WIDTH, CONV5_1_W_HEIGHT, CONV5_1_W_WIDTH, CONV5_1_W_IN_CHANNELS)

/* conv5_2 */ /* biggest weights */
#define CONV5_2_F_HEIGHT        14
#define CONV5_2_F_WIDTH         14
#define CONV5_2_F_CHANNELS     512

#define CONV5_2_W_HEIGHT         3
#define CONV5_2_W_WIDTH          3
#define CONV5_2_W_IN_CHANNELS  512
#define CONV5_2_W_OUT_CHANNELS 512

#define CONV5_2_F_SIZE features_size(CONV5_2_F_HEIGHT, CONV5_2_F_WIDTH, CONV5_2_F_CHANNELS)
#define CONV5_2_W_SIZE weights_size(CONV5_2_W_HEIGHT, CONV5_2_W_WIDTH, CONV5_2_W_IN_CHANNELS, CONV5_2_W_OUT_CHANNELS)
#define CONV5_2_P_SIZE patches_size(CONV5_2_F_HEIGHT, CONV5_2_F_WIDTH, CONV5_2_W_HEIGHT, CONV5_2_W_WIDTH, CONV5_2_W_IN_CHANNELS)

/* conv5_3 */ /* biggest weights */
#define CONV5_3_F_HEIGHT        14
#define CONV5_3_F_WIDTH         14
#define CONV5_3_F_CHANNELS     512

#define CONV5_3_W_HEIGHT         3
#define CONV5_3_W_WIDTH          3
#define CONV5_3_W_IN_CHANNELS  512
#define CONV5_3_W_OUT_CHANNELS 512

#define CONV5_3_F_SIZE features_size(CONV5_3_F_HEIGHT, CONV5_3_F_WIDTH, CONV5_3_F_CHANNELS)
#define CONV5_3_W_SIZE weights_size(CONV5_3_W_HEIGHT, CONV5_3_W_WIDTH, CONV5_3_W_IN_CHANNELS, CONV5_3_W_OUT_CHANNELS)
#define CONV5_3_P_SIZE patches_size(CONV5_3_F_HEIGHT, CONV5_3_F_WIDTH, CONV5_3_W_HEIGHT, CONV5_3_W_WIDTH, CONV5_3_W_IN_CHANNELS)

/*#define VGG


#ifdef VGG
#define CONV_F_HEIGHT		(CONV5_1_F_HEIGHT)
#define CONV_F_WIDTH		(CONV5_1_F_WIDTH)
#define CONV_F_CHANNELS		(CONV5_1_F_CHANNELS)

#define CONV_K_HEIGHT		(CONV5_1_W_HEIGHT)
#define CONV_K_WIDTH		(CONV5_1_W_WIDTH)
#define CONV_K_IN_CHANNELS	(CONV5_1_W_IN_CHANNELS)
#define CONV_K_OUT_CHANNELS	(CONV5_1_W_OUT_CHANNELS)
#else
#define CONV_F_HEIGHT		(10)
#define CONV_F_WIDTH		(10)
#define CONV_F_CHANNELS		(512)

#define CONV_K_HEIGHT		(3)
#define CONV_K_WIDTH		(3)
#define CONV_K_IN_CHANNELS	(CONV_F_CHANNELS)
#define CONV_K_OUT_CHANNELS	(1)

//#define CONV_F_HEIGHT		(CONV5_1_F_HEIGHT)
//#define CONV_F_WIDTH		(CONV5_1_F_WIDTH)
//#define CONV_F_CHANNELS		(CONV5_1_F_CHANNELS)
//
//#define CONV_K_HEIGHT		(CONV5_1_W_HEIGHT)
//#define CONV_K_WIDTH		(CONV5_1_W_WIDTH)
//#define CONV_K_IN_CHANNELS	(CONV5_1_W_IN_CHANNELS)
//#define CONV_K_OUT_CHANNELS	(CONV5_1_W_OUT_CHANNELS)
#endif
*/
/*
#define MAX_W_HEIGHT         3
#define MAX_W_WIDTH          3
#define MAX_W_IN_CHANNELS  512
#define MAX_W_OUT_CHANNELS 512
*//*
#define MAX_F_SIZE 3211264
//static_assert(MAX_F_SIZE == (CONV1_2_F_SIZE), "Maximum size of the feature maps do not match");
#define MAX_W_SIZE 2359296
//static_assert(MAX_W_SIZE == (CONV4_2_W_SIZE), "Maximum size of the weights do not match");
#define MAX_P_SIZE 28901376
//static_assert(MAX_P_SIZE == (CONV1_2_P_SIZE), "Maximum size of the patches do not match");
*/

/*
#define K_SIZE_TINY   (3*3*3*16)
#define K_SIZE_SMALL  3*3*64*64
#define K_SIZE_MEDIUM 3*3*128*128
#define K_SIZE_LARGE  3*3*256*256
#define K_SIZE_XLARGE 3*3*512*192

#define K_SIZE K_SIZE_LARGE
*/

#endif /* __SIZES_H__ */
