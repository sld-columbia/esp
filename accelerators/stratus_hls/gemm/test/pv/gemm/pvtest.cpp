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

#include <iostream>
#include <vector>
#include <sstream>
#include <fstream>
#include <stdio.h>

#include <mojo.h>
#include <mojo_utils.h>
#include <dwarf.h>

#include "validation.hpp"
#include "contrast_adj.h"
#include "run_pv.hpp"

std::ofstream ofs;

std::string image_path = "include/data/truck.bmp";
std::string model_file = "../models/dwarf7.mojo";
int target_layer = 5;
int target_test= 1;
int main(int argc, char **argv) {
    // if (argc > 1)
    //     image_path = std::string(argv[1]);
    // if (argc > 2)
    //     target_layer = atoi(argv[2]);
    // if (argc > 3)
    // 	target_test= atoi(argv[3]);
    std::cout << image_path << std::endl;

    // read image
    cv::Mat im = cv::imread(image_path);
    if (im.empty() || im.cols < 1) {
        std::cout << "Failed to read a valid image. (" << image_path << ")" << std::endl;
        return 1;
    }

    // resize to 32x32 BGR format
    // cv::resize(im,im,cv::Size(32,32));
    // make 3 chan
    // if (im.channels()<3) cv::cvtColor(im,im,CV_GRAY2BGR);

    // convert packed BGR to planar BGR, apply contrast_adj,
    // and subtract DWARF mean (while converting to float)
    cv::Mat bgr[3];
    cv::split(im, bgr);

    float *img = new float[3 * 32 * 32];

    int R_1[1024];
    int G_1[1024];
    int B_1[1024];
    int R_2[1024];
    int G_2[1024];
    int B_2[1024];

    for (int i = 0; i < 32 * 32; i++)
    {
        R_1[i] = (int)bgr[2].data[i];
        G_1[i] = (int)bgr[1].data[i];
        B_1[i] = (int)bgr[0].data[i];
    }

    // perform contrast_adj
    int r_err = contrast_adj(R_1, R_2, 32, 32, 16, 8);
    int g_err = contrast_adj(G_1, G_2, 32, 32, 16, 8);
    int b_err = contrast_adj(B_1, B_2, 32, 32, 16, 8);

    if (r_err || g_err || b_err)
        std::cout << "error: " << r_err << "\t" << g_err << "\t" << b_err << std::endl;

    for (int i = 0; i < 32 * 32; i++)
    {
        bgr[2].data[i] = R_2[i];
        bgr[1].data[i] = G_2[i];
        bgr[0].data[i] = B_2[i];
    }


    // data stats from training the model
    float data_mean = 120.70748;
    float data_std = 64.150024;

    // normalize input data
    for (int i = 0; i < 32 * 32; i++) {
        img[i + 32 * 32 * 0] = ((float)bgr[2].data[i] - data_mean) / (data_std + 1e-7);
        img[i + 32 * 32 * 1] = ((float)bgr[1].data[i] - data_mean) / (data_std + 1e-7);
        img[i + 32 * 32 * 2] = ((float)bgr[0].data[i] - data_mean) / (data_std + 1e-7);
    }

    // create a network
    mojo::network cnn;

    // load DWARF7 model
    std::cout << "Loading DWARF7 model..." << std::endl;
    if (!cnn.read(model_file)) {
        std::cerr << "error: could not read model.\n";
        return 1;
    }


    // start a (low precision) timer
    std::cout << "Classifying image..." << std::endl;

    // Load input
    cnn.forward_setup(img);

    // ------- Run inference -------

    // Input layer -> nothing to be done
    // input 34x34 (including pad of 2 pixels), 3 channels

    // conv2d #1: 34x34 (including pad of 2 pixels), kernel size 3x3, 32 channels, relu
    convolution_compute(cnn.layer_sets[1]->node.x, cnn.layer_sets[1]->bias.x, cnn.layer_sets[0]->node.x, cnn.W[0]->x,
                        cnn.layer_sets[1]->node.cols, cnn.layer_sets[1]->node.rows, cnn.layer_sets[0]->node.chans,
                        cnn.layer_sets[1]->node.chans,
                        get_pool_size(cnn.layer_sets[1]->node.cols, cnn.layer_sets[1]->node.rows,
                                      cnn.layer_sets[1]->do_pool, cnn.layer_sets[1]->do_pad),
                        get_pool_stride(cnn.layer_sets[1]->node.cols, cnn.layer_sets[1]->node.rows,
                                        cnn.layer_sets[1]->do_pool, cnn.layer_sets[1]->do_pad),
                        cnn.layer_sets[1]->do_pool, cnn.layer_sets[1]->do_pad);

    // conv2d #2: 34x34 (including pad of 2 pixels), kernel size 3x3, 32 channels, relu, max pooling 2x2 (pad on output
    // -> 18x18)
    convolution_compute(cnn.layer_sets[2]->node.x, cnn.layer_sets[2]->bias.x, cnn.layer_sets[1]->node.x, cnn.W[1]->x,
                        cnn.layer_sets[2]->node.cols, cnn.layer_sets[2]->node.rows, cnn.layer_sets[1]->node.chans,
                        cnn.layer_sets[2]->node.chans,
                        get_pool_size(cnn.layer_sets[2]->node.cols, cnn.layer_sets[2]->node.rows,
                                      cnn.layer_sets[2]->do_pool, cnn.layer_sets[2]->do_pad),
                        get_pool_stride(cnn.layer_sets[2]->node.cols, cnn.layer_sets[2]->node.rows,
                                        cnn.layer_sets[2]->do_pool, cnn.layer_sets[2]->do_pad),
                        cnn.layer_sets[2]->do_pool, cnn.layer_sets[2]->do_pad);

    // conv2d #3: 18x18 (including pad of 2 pixels), kernel size 3x3, 64 channels, relu, max pooling 2x2 (pad on output
    // -> 10x10)
    convolution_compute(cnn.layer_sets[3]->node.x, cnn.layer_sets[3]->bias.x, cnn.layer_sets[2]->node.x, cnn.W[2]->x,
                        cnn.layer_sets[3]->node.cols, cnn.layer_sets[3]->node.rows, cnn.layer_sets[2]->node.chans,
                        cnn.layer_sets[3]->node.chans,
                        get_pool_size(cnn.layer_sets[3]->node.cols, cnn.layer_sets[3]->node.rows,
                                      cnn.layer_sets[3]->do_pool, cnn.layer_sets[3]->do_pad),
                        get_pool_stride(cnn.layer_sets[3]->node.cols, cnn.layer_sets[3]->node.rows,
                                        cnn.layer_sets[3]->do_pool, cnn.layer_sets[3]->do_pad),
                        cnn.layer_sets[3]->do_pool, cnn.layer_sets[3]->do_pad);

    // conv2d #4: 10x10 (including pad of 2 pixels), kernel size 3x3, 128 channels, relu, max pooling 2x2
    convolution_compute(cnn.layer_sets[4]->node.x, cnn.layer_sets[4]->bias.x, cnn.layer_sets[3]->node.x, cnn.W[3]->x,
                        cnn.layer_sets[4]->node.cols, cnn.layer_sets[4]->node.rows, cnn.layer_sets[3]->node.chans,
                        cnn.layer_sets[4]->node.chans,
                        get_pool_size(cnn.layer_sets[4]->node.cols, cnn.layer_sets[4]->node.rows,
                                      cnn.layer_sets[4]->do_pool, cnn.layer_sets[4]->do_pad),
                        get_pool_stride(cnn.layer_sets[4]->node.cols, cnn.layer_sets[4]->node.rows,
                                        cnn.layer_sets[4]->do_pool, cnn.layer_sets[4]->do_pad),
                        cnn.layer_sets[4]->do_pool, cnn.layer_sets[4]->do_pad);


    // fc (dense) #1: 1x1, 2048 channels, relu
    fc_compute(cnn.layer_sets[5]->node.x, cnn.layer_sets[4]->node.x, cnn.W[4]->x, cnn.layer_sets[5]->bias.x,
               cnn.W[4]->cols, cnn.W[4]->rows, cnn.layer_sets[5]->relu);

    // fc (dense) #2: 1x1, 64 channels, relu
    fc_compute(cnn.layer_sets[6]->node.x, cnn.layer_sets[5]->node.x, cnn.W[5]->x, cnn.layer_sets[6]->bias.x,
                cnn.W[5]->cols, cnn.W[5]->rows, cnn.layer_sets[6]->relu);




    //Run programmer's view:run_pv->conv_pvt->sw_conv_layer
    float* out0=new float[36991]{0};//cnn.layer_sets[1]->node.get_size()]{0};
    float* out1=new float[36991]{0};//cnn.layer_sets[1]->node.get_size()]{0};
    float* out2=new float[36991]{0};//cnn.layer_sets[1]->node.get_size()]{0};
    float* out3=new float[65535]{0};//cnn.layer_sets[1]->node.get_size()]{0};
    float* out4=new float[32767]{0};//cnn.layer_sets[1]->node.get_size()]{0};
    float *out5=new float[cnn.W[4]->rows];
    float *out6=new float[cnn.W[5]->rows];


    mojo::network * cnn_ptr=&cnn;

    run_pv(cnn_ptr,1,1,out0,out1,0);
    run_pv(cnn_ptr,0,2,out1,out2,0);
    run_pv(cnn_ptr,0,3,out2,out3,0);
    run_pv(cnn_ptr,0,4,out3,out4,0);
    run_pv(cnn_ptr,0,5,out4,out5,1);
    run_pv(cnn_ptr,0,6,out5,out6,1);

    // ------- Finish inference -------

    float *out = cnn.layer_sets[6]->node.x;

    std::cout<<"Results:"<<std::endl<<std::endl;

    std::cout << "Dwarf_pv:" << std::endl;
    int first = mojo::arg_max(out, cnn.out_size());
    std::cout << "  1: label|score: \t\"" << labels[first] << "\" | " << out[first] << std::endl;

    // find next best
    out[first] = -1;
    int second = mojo::arg_max(out, cnn.out_size());
    std::cout << "  2: label|score: \t\"" << labels[second] << "\" | " << out[second] << std::endl;


    std::cout << "Using_gemm_pv:" << std::endl;
    int first_g = mojo::arg_max(out6, cnn.out_size());
    std::cout << "  1: label|score: \t\"" << labels[first_g] << "\" | " << out6[first_g] << std::endl;

    // find next best
    out6[first_g] = -1;
    int second_g = mojo::arg_max(out6, cnn.out_size());
    std::cout << "  2: label|score: \t\"" << labels[second_g] << "\" | " << out6[second_g] << std::endl;


    delete[] img;

    return 0;
}
