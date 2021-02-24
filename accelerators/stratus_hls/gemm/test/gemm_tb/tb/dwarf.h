/* Copyright 2019 Columbia University, SLD Group */
/* Contact: paolo@cs.columbia.edu                */

#ifndef _DWARF_H_
#define _DWARF_H_

#include <iostream>
#include <cmath>
#include <sstream>
#include <fstream>
#include <stdio.h>

//
// Helper functions
//

int get_pool_size(int cols, int rows, bool do_pool, bool do_pad) {
    int pool_size = cols;
    if (do_pool) {
        if (do_pad)
            pool_size = (cols + 2) / 2;
        else
            pool_size = (cols - 2) / 2;
    }
    return pool_size;
}

int get_pool_stride(int cols, int rows, bool do_pool, bool do_pad) {
    int pool_stride = cols * rows;
    if (do_pool) {
        if (do_pad)
            pool_stride = (cols + 2) / 2 * (rows + 2) / 2;
        else
            pool_stride = (cols - 2) / 2 * (rows - 2) / 2;
    }
    return pool_stride;
}

//
// Convolution
//

void convolution_compute(float *dst, float *bias, float *src, float *w, int cols, int rows, int src_chans,
                         int dst_chans, int pool_size, int pool_stride, bool do_pool, bool do_pad) {

    const int chan_stride = cols * rows;
    const int kernel_size = 9;

    // Convolution
    for (int k = 0; k < src_chans; k++) {
        bool last = false;
        if (k == src_chans - 1)
            last = true;

        const float *img = &src[k * chan_stride];

        for (int c = 0; c < dst_chans; c++) {
            const float *filter = &w[k * dst_chans * kernel_size + c * kernel_size];
            float *out = &dst[chan_stride * c];
            float b = bias[c];

	    /* if(c == 0 || c == 1){  */
	    /* 	    std::cout << " Filter is :" << std::endl;  */
	    /* 	    for(int h = 0; h < 9; h++){  */
	    /* 		    std::cout << filter[h] << " " << std::endl;   */
	    /* 	    }  */
	    /* }/ */
            
	    float *out_pool = &dst[pool_stride * c];

            // dotsum_3x3
            for (int j = 1; j < cols - 1; j++)     // intput h
                for (int i = 1; i < cols - 1; i++) // intput w
                {
                    const int index_out_p0 = (j - 1) * cols + i - 1;
                    const int index_out_p1 = j * cols + i - 1;
                    const int index_out_p2 = (j - 1) * cols + i;
                    const int index_out_p3 = j * cols + i;
                    int index_out=index_out_p3 ;
		    //const int ind_out=(j-1)*(cols-2)+(i-1);
		    /* int indx_out; */

		    /* if (do_pad) */
		    /* 	    indx_out=index_out_p3; */
		    /* else */
		    /* 	    indx_out=ind_out; */

                    int index_out_pool;
                    if (do_pad)
                        index_out_pool = j / 2 * pool_size + i / 2;
                    else
                        index_out_pool = (j / 2 - 1) * pool_size + i / 2 - 1;


                    out[index_out] +=
                        img[index_out - 1 - 1 * cols] * filter[0] + img[index_out + 0 - 1 * cols] * filter[1] +
                        img[index_out + 1 - 1 * cols] * filter[2] + img[index_out - 1] * filter[3] +
                        img[index_out + 0] * filter[4] + img[index_out + 1] * filter[5] +
                        img[index_out - 1 + 1 * cols] * filter[6] + img[index_out + 0 + 1 * cols] * filter[7] +
                        img[index_out + 1 + 1 * cols] * filter[8];

                    // Activation
                    if (last) {
                        if (out[index_out] + b < 0)
                            out[index_out] = 0;
                        else
                            out[index_out] = out[index_out] + b;

                        // Max Pool 2x2
                        if ((j % 2 == 0) && (i % 2 == 0) && do_pool) {
                            const float p0 = out[index_out_p0];
                            const float p1 = out[index_out_p1];
                            const float p2 = out[index_out_p2];
                            const float p3 = out[index_out_p3];

                            float max = p0;
                            if (max < p1)
                                max = p1;
                            if (max < p2)
                                max = p2;
                            if (max < p3)
                                max = p3;
                            out_pool[index_out_pool] = max;
                        }
                    }
                }

            // Pad (resize)
            if (last && do_pad) {
                for (int i = 0; i < pool_size; i++)
                    // first row
                    out_pool[i] = 0.0;

                for (int i = 0; i < pool_size; i++)
                    // last row
                    out_pool[pool_size * (pool_size - 1) + i] = 0.0;

                for (int i = 0; i < pool_size; i++)
                    // first column
                    out_pool[pool_size * i] = 0.0;

                for (int i = 0; i < pool_size; i++)
                    // last column
                    out_pool[pool_size * i + pool_size - 1] = 0.0;
            }
        }
    }
}

//
// Fully connected
//

void fc_compute(float *dst, float *src, float *w, float *b, int w_cols, int w_rows, bool relu) {
	/* int count; */

    /* for (int i = 0; i < w_cols; i++) { */
    /* 	    //   dst[j] += src[i] * w[w_index + i]; */
    /*      std::cout<<src[i]<<" "; //r */
    /* 	 if(src[i]!=0) */
    /* 	 {count++;} */
    /*      } */

    /* 	std::cout<<"count:"<<count; */

    // Multiply the input with the weight matrix
    for (int j = 0; j < w_rows; j++) {
        const int w_index = j * w_cols;
        dst[j] = 0;
	                                 //r         
        for (int i = 0; i < w_cols; i++) {
            dst[j] += src[i] * w[w_index + i];

	    //   std::cout<<src[i]<<" "; //r
	    }
	//std::cout<<"cols:"<<w_cols;                //r
	
        if (relu) {
            if (dst[j] + b[j] < 0)
                dst[j] = 0;
            else
                dst[j] += b[j];
        }
    }

    // Softmax
    if (!relu)
        for (int i = 0; i < w_rows; i++) {
            float max = dst[0];
            for (int j = 1; j < w_rows; j++)
                if (dst[j] > max)
                    max = dst[j];

            float denom = 0;
            for (int j = 0; j < w_rows; j++)
                denom += exp(dst[j] - max);

            dst[i] = exp(dst[i] - max) / denom;
        }
}

const char *labels[] = { "airplane", "automobile", "bird", "cat", "deer", "dog", "frog", "horse", "ship", "truck" };

#endif // _DWARF_H_
