// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <stdio.h>
#include <stdlib.h>
#include <cmath>
#include <sstream>
#include <cassert>
//#include "esp_templates.hpp"
#include "utils.hpp"

void init_image(float* hw_image, float* sw_image, const int channels, const int height, const int width, bool random) {
    int i = 0;
    for (int c = 0; c < channels; c++) {
        for (int h = 0; h < height; h++) {
            for (int w = 0; w < width; w++) {
                hw_image[c * height * width + h * width + w] = float(i % 8);
                sw_image[c * height * width + h * width + w] = float(i % 8);
                i++;
            }
        }
    }
}

void init_weights(float* hw_weights, float* sw_weights, const int filters, const int channels, const int height, const int width, bool random) {
    for (int f = 0; f < filters; f++) {
        for (int c = 0; c < channels; c++) {
            for (int h = 0; h < height; h++) {
                for (int w = 0; w < width; w++) {
                    float rand_value = rand() / float(RAND_MAX);
                    hw_weights[f * channels * height * width + c * height * width + h * width + w] = rand_value;
                    sw_weights[f * channels * height * width + c * height * width + h * width + w] = rand_value;
                }
            }
        }
    }
}

void init_bias(float* hw_bias, float* sw_bias, const int n_filters, bool random) {
    int i = 0;
    for (int f = 0; f < n_filters; f++) {
	hw_bias[f] = float(i % 8);
	sw_bias[f] = float(i % 8);
	i++;
    }
}

void print_hw_image(const char * name, float* image, const int channels, const int height, const int width) {
    printf("%s: C x H x W = %u x %u x %u\n", name, channels, height, width);
    if (channels * height * width < 256)
    {
        for (int c = 0; c < channels; c++) {
            std::stringstream ss;
            ss << "| ";
            for (int h = 0; h < height; h++) {
                for (int w = 0; w < width; w++) {
                    ss << FPDATA(image[c * height * width + h * width + w]) << "  ";
                }
                ss << "| ";
            }
            printf("%s: C %u: %s\n", name, c, ss.str().c_str());
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

void print_hw_weights(const char * name, float* weights, const int filters, const int channels, const int height, const int width) {
    printf("%s: F x C x H x W = %u x %u x %u x %u\n", name, filters, channels, height, width);
    if (channels * height * width < 256)
    {
        for (int f = 0; f < filters; f++) {
            for (int c = 0; c < channels; c++) {
                std::stringstream ss;
                ss << "| ";
                for (int h = 0; h < height; h++) {
                    for (int w = 0; w < width; w++) {
                        ss << FPDATA(weights[f * channels * height * width + c * height * width + h * width + w]) << "  ";
                    }
                    ss << "| ";
                }
                printf("%s: F %u, C %u: %s\n", name, f, c, ss.str().c_str());
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

void print_hw_bias(const char * name, float* bias, const int n_filters) {
    printf("%s: F = %u\n", name, n_filters);
    if (n_filters < 64) {
	std::stringstream ss;
	ss << "| ";
        for (int f = 0; f < n_filters; f++) {
	    ss << FPDATA(bias[f]) << "  ";
	}
	ss << "| ";
	printf("%s: %s\n", name, ss.str().c_str());
    }
}

void print_sw_bias(const char * name, float* bias, const int n_filters) {
    printf("%s: F = %u\n", name, n_filters);
    if (n_filters < 64) {
	std::stringstream ss;
	ss << "| ";
        for (int f = 0; f < n_filters; f++) {
	    ss << (float) bias[f] << "  ";
	}
	ss << "| ";
	printf("%s: %s\n", name, ss.str().c_str());
    }
}

void print_array(const char * name, float* matrix, const int length) {
       printf("%s: L = %u\n", name, length);
    std::stringstream ss;
    for (int l = 0; l < length; l++) {
        ss << FPDATA(matrix[l]) << " ";
    }
    printf("%s: %s\n", name, ss.str().c_str());
}

#define NEURON_MAX_ERROR_THRESHOLD 0.01
#define VOLUME_MAX_ERROR_THRESHOLD 0.0001
#define REPORT_THRESHOLD 10

bool check_error_threshold_for_neuron(float hw_data, float sw_data, float &error)
{
    assert(!std::isinf(float(sw_data)) && !std::isnan(float(sw_data)));
    float hw_fdata = hw_data;

    // return an error if hw_data is Infinite or NaN
    if (std::isinf(float(hw_fdata)) || std::isnan(float(hw_fdata))) { return true; }

    if (sw_data != 0)
        error = fabs((float(sw_data) - float(hw_fdata)) / float(sw_data));
    else
        error = fabs((float(hw_fdata) - float(sw_data)) / float(hw_fdata));

    return (error > NEURON_MAX_ERROR_THRESHOLD);
}

int _validate(float* hw_data_array, float* sw_data_array, int num_elements) {
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
            // if (tot_errors < REPORT_THRESHOLD) {
                float hw_fdata = hw_data_array[i];
                printf("[ERROR] Validation: Element %d wrong [%.4f - %.4f]\n",
		       i, float(hw_fdata), float(sw_data_array[i]));
            // }
            tot_errors++;
        } else {
	    float hw_fdata = hw_data_array[i];
	    printf("Validation: Element %d wrong [%.4f - %.4f]\n", i, float(hw_fdata), float(sw_data_array[i]));
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
