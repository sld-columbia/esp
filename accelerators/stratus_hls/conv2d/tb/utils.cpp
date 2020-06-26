// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>
#include <cmath>
#include <sstream>
#include <cassert>
//#include "esp_templates.hpp"
#include "utils.hpp"

void init_image(FPDATA* hw_image, float* sw_image, const int channels, const int height, const int width, bool random) {
    int i = 0;
    for (int c = 0; c < channels; c++) {
        for (int h = 0; h < height; h++) {
            for (int w = 0; w < width; w++) {
                hw_image[c * height * width + h * width + w] = FPDATA(i % 8);
                sw_image[c * height * width + h * width + w] = float(i % 8);
                i++;
            }
        }
    }
}

void init_weights(FPDATA* hw_weights, float* sw_weights, const int filters, const int channels, const int height, const int width, bool random) {
    for (int f = 0; f < filters; f++) {
        for (int c = 0; c < channels; c++) {
            for (int h = 0; h < height; h++) {
                for (int w = 0; w < width; w++) {
                    float rand_value = rand() / float(RAND_MAX);
                    hw_weights[f * channels * height * width + c * height * width + h * width + w] = FPDATA(rand_value);
                    sw_weights[f * channels * height * width + c * height * width + h * width + w] = rand_value;
                }
            }
        }
    }
}

//void init_array(FPDATA* matrix, const int length, bool random) {
//    init_image(matrix, 1, 1, length, random);
//}


void print_hw_image(const char * name, FPDATA* image, const int channels, const int height, const int width) {
    printf("%s: C x H x W = %u x %u x %u\n", name, channels, height, width);
    if (channels * height * width < 256)
    {
        for (int c = 0; c < channels; c++) {
            std::stringstream ss;
            ss << "| ";
            for (int h = 0; h < height; h++) {
                for (int w = 0; w < width; w++) {
                    ss << (float)image[c * height * width + h * width + w] << "  ";
                }
                ss << "| ";
            }
            printf("%s: C %u: %s", name, c, ss.str().c_str());
        }
    }
}


void print_sw_image(const char * name, float* image, const int channels, const int height, const int width) {
       printf("%s: C x H x W = %u x %u x %u\n", name, channels, height, width);
    if (channels * height * width < 256)
    {
        for (int c = 0; c < channels; c++) {
            std::stringstream ss;
            ss << "| ";
            for (int h = 0; h < height; h++) {
                for (int w = 0; w < width; w++) {
                    ss << (float)image[c * height * width + h * width + w] << "  ";
                }
                ss << "| ";
            }
            printf("%s: C %u: %s\n", name, c, ss.str().c_str());
        }
    }
}



void print_hw_weights(const char * name, FPDATA* weights, const int filters, const int channels, const int height, const int width) {
       printf("%s: F x C x H x W = %u x %u x %u x %u\n", name, filters, channels, height, width);
    if (channels * height * width < 256)
    {
        for (int f = 0; f < filters; f++) {
            for (int c = 0; c < channels; c++) {
                std::stringstream ss;
                ss << "| ";
                for (int h = 0; h < height; h++) {
                    for (int w = 0; w < width; w++) {
                        ss << (float)weights[f * channels * height * width + c * height * width + h * width + w] << "  ";
                    }
                    ss << "| ";
                }
                printf("%s: F %u, C %u: %s", name, f, c, ss.str().c_str());
            }
        }
    }
}

void print_sw_weights(const char * name, float* weights, const int filters, const int channels, const int height, const int width) {
       printf("%s: F x C x H x W = %u x %u x %u x %u\n", name, filters, channels, height, width);
    if (channels * height * width < 256)
    {
        for (int f = 0; f < filters; f++) {
            for (int c = 0; c < channels; c++) {
                std::stringstream ss;
                ss << "| ";
                for (int h = 0; h < height; h++) {
                    for (int w = 0; w < width; w++) {
                        ss << (float)weights[f * channels * height * width + c * height * width + h * width + w] << "  ";
                    }
                    ss << "| ";
                }
                printf("%s: F %u, C %u: %s\n", name, f, c, ss.str().c_str());
            }
        }
    }
}

void print_array(const char * name, FPDATA* matrix, const int length) {
       printf("%s: L = %u\n", name, length);
    std::stringstream ss;
    for (int l = 0; l < length; l++) {
        ss << (float)matrix[l] << " ";
    }
    printf("%s: %s\n", name, ss.str().c_str());
}


void transpose_matrix(FPDATA* matrix, const int height, const int width) {

    for (int start = 0; start <= (width * height) - 1; ++start) {
        int next = start;
        int i = 0;
        do {
            ++i;
            next = (next % height) * width + next / height;
        } while (next > start);

        if (next >= start && i != 1) {
            const FPDATA tmp = matrix[start];
            next = start;
            do {
                i = (next % height) * width + next / height;
                matrix[next] = (i == start) ? tmp : matrix[i];
                next = i;
            } while (next > start);
        }
    }

}

// See Floating-Point Design with Vivado HLS
// XAPP599 v1.0
bool approx_eqf(FPDATA x, FPDATA y, int ulp_err_lim, float abs_err_lim)
{
    float_union_t lx, ly;
    lx.fval = x;
    ly.fval = y;
    // ULP based comparison is likely to be meaningless when x or y
    // is exactly zero or their signs differ, so test against an
    // absolute error threshold this test also handles (-0.0 == +0.0),
    // which should return true.
    // N.B. that the abs_err_lim must be chosen wisely, based on
    // knowledge of calculations/algorithms that lead up to the
    // comparison. There is no substitute for proper error analysis
    // when accuracy of results matter.
    if (((float(x) == 0.0f) ^ (float(y) == 0.0f)) || (std::signbit(float(x)) != std::signbit(float(y)))) {
#ifdef _DEBUG
        if (x != y) { // (-0.0 == +0.0) so warning not printed for that case
            printf("\nWARNING: Comparing floating point value against zero \n");
            printf("or values w/ differing signs. \n");
            printf("Absolute error limit has been used.\n");
        }
#endif
        return fabs(float(x) - float(y)) <= fabs(abs_err_lim);
    }
    // Do ULP base comparison for all other cases
    return abs((int) lx.rawbits - (int) ly.rawbits) <= ulp_err_lim;
}

#define NEURON_MAX_ERROR_THRESHOLD 0.01
#define VOLUME_MAX_ERROR_THRESHOLD 0.0001
#define REPORT_THRESHOLD 10

bool check_error_threshold_for_neuron(FPDATA hw_data, float sw_data, float &error)
{
    assert(!std::isinf(float(sw_data)) && !std::isnan(float(sw_data)));
    FPDATA hw_fdata = hw_data;

    // return an error if hw_data is Infinite or NaN
    if (std::isinf(float(hw_fdata)) || std::isnan(float(hw_fdata))) { return true; }

    if (sw_data != 0)
        error = fabs((float(sw_data) - float(hw_fdata)) / float(sw_data));
    else
        error = fabs((float(hw_fdata) - float(sw_data)) / float(hw_fdata));

    return (error > NEURON_MAX_ERROR_THRESHOLD);
}

int _validate(FPDATA* hw_data_array, float* sw_data_array, int num_elements) {
    unsigned tot_errors = 0;
    float rel_error = 0.;
    float avg_error = 0.;
    float max_error = 0.;
    float vol_error = 0.;

    printf("Run validation\n");
    printf("Maximum error threshold per neuron %.5f%%\n", float(NEURON_MAX_ERROR_THRESHOLD)*100);
    printf("Maximum error threshold per volume %.5f%%\n", float(VOLUME_MAX_ERROR_THRESHOLD)*100);
    printf("Maximum reported error threshold %u\n", REPORT_THRESHOLD);

    for (unsigned i = 0; i < num_elements; i++) {
        if (check_error_threshold_for_neuron(float(hw_data_array[i]), float(sw_data_array[i]), rel_error)) {
            if (tot_errors < REPORT_THRESHOLD) {
                FPDATA hw_fdata = hw_data_array[i];
                printf("Validation: Element %d wrong [%.4f - %.4f]\n", i, float(hw_fdata), float(sw_data_array[i]));
            }
            tot_errors++;
        }

        if (rel_error > max_error) max_error = rel_error;

        avg_error += rel_error;
    }

    avg_error /= num_elements;

    vol_error = (tot_errors/float(num_elements));

    printf("Validation: neuron errors # %u out of # %u\n", tot_errors, num_elements);
    printf("Validation: average neuron error: # %.5f%%\n", avg_error * 100);
    printf("Validation: maximum neuron error: # %.5f%%\n", max_error * 100);
    printf("Validation: volume error: # %f%%\n", vol_error * 100);

    // Check error threshold for volume
    return (vol_error > VOLUME_MAX_ERROR_THRESHOLD);
}
