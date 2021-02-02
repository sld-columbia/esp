/* Copyright 2019 Columbia University, SLD Group */
/* Contact: paolo@cs.columbia.edu                */

#ifndef _DWARF_H_
#define _DWARF_H_

#include <cmath>
#include "../fpdata.hpp"
#ifdef SYSTEM_ACCURACY
#include "../precision_test_fpdata.hpp"
#endif

//
// Helper functions
//

// FIXED POINT input, output and bias fraction part precision
#define FPDATA_FL (FPDATA_WL - FPDATA_IL)

// FIXED POINT weights fraction part precision
#define W_FPDATA_FL (W_FPDATA_WL - W_FPDATA_IL)

template < uint32_t __FPDATA_WL__ >
long long int saturate(long long int res)
{
    bool sign = (res < 0);

    if (!sign) {
    	if (res >= (long long int) (1ULL << __FPDATA_WL__)) {
    	    // saturate
    	    res = ((1ULL << (__FPDATA_WL__ - 1)) - 1);
    	}
    } else {
    	if ((-res) >= (long long int) (1ULL << __FPDATA_WL__)) {
    	    // saturate
    	    res = ((1ULL << (__FPDATA_WL__ - 1)));
    	}
    }

    return res;
}

template < uint32_t __FPDATA_WL__ >
int add_fixed(int a, int b)
{
    long long int _a = a;
    long long int _b = b;

    long long int res = _a + _b;

    return (int) saturate<__FPDATA_WL__>(res);
}

template < uint32_t __FPDATA_WL__, uint32_t __FPDATA_FL__, uint32_t __W_FPDATA_FL__ >
int mul_fixed(int a, int b)
{
    long long int res;
    long long int _a = a;
    long long int _b = b;

    if (__FPDATA_FL__ > __W_FPDATA_FL__) {

    _b = _b << (long long int) (__FPDATA_FL__ - __W_FPDATA_FL__);
    res = (_a * _b) >> (long long int) __FPDATA_FL__;

    } else if (__FPDATA_FL__ < __W_FPDATA_FL__) {

    _a = _a << (long long int) (__W_FPDATA_FL__ - __FPDATA_FL__);
    res = (_a * _b) >> (long long int) (__W_FPDATA_FL__ + (__W_FPDATA_FL__ - __FPDATA_FL__));

    } else {

    res = (_a * _b) >> (long long int) __FPDATA_FL__;

    }

    return (int) saturate<__FPDATA_WL__>(res);
}

template <uint32_t __FPDATA_FL__ >
static inline float fixed_to_float(long long int value)
{
    double f = (double) value / (double) (1 << __FPDATA_FL__);
    return (float) f;
}

template <uint32_t __W_FPDATA_FL__ >
static inline float fixed_to_float_weights(long long int value)
{
    double f = (double) value / (double) (1 << __W_FPDATA_FL__);
    return (float) f;
}

template <uint32_t __FPDATA_FL__ , uint32_t __FPDATA_WL__>
static inline int float_to_fixed(float value)
{
    double f = (double) value * (double) (1 << __FPDATA_FL__);
    f = round(f);
    long long int r = (long long int) f;

    return (int) saturate<__FPDATA_WL__>(r);
}

template <uint32_t __W_FPDATA_FL__, uint32_t __W_FPDATA_WL__ >
static inline int float_to_fixed_weights(float value)
{
    double f = (double) value * (double) (1 << __W_FPDATA_FL__);
    f = round(f);
    long long int r = (long long int) f;

    return (int) saturate<__W_FPDATA_WL__>(r);
}

int get_pool_size(int cols, int rows, bool do_pool, bool do_pad)
{
	int pool_size = cols;
	if (do_pool)
	{
		if (do_pad)
			pool_size = (cols + 2) / 2;
		else
			pool_size = (cols - 2) / 2;
	}
	return pool_size;
}

int get_pool_stride(int cols, int rows, bool do_pool, bool do_pad)
{
	int pool_stride = cols * rows;
	if (do_pool)
	{
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

void convolution_float(float *dst, float *bias, float *src, float *w,
		       int cols, int rows, int src_chans, int dst_chans,
		       int pool_size, int pool_stride,
		       bool do_pool, bool do_pad)
{

    const int chan_stride = cols * rows;
    const int kernel_size = 9;

    // Convolution
    for (int k = 0; k < src_chans; k++)
    {
	bool last = false;
	if (k == src_chans - 1)
	    last = true;

	const float *img = &src[k * chan_stride];

	for (int c = 0; c < dst_chans; c++)
	{
	    const float *filter = &w[k * dst_chans * kernel_size + c * kernel_size];
	    float *out = &dst[chan_stride * c];
	    float b = bias[c];

	    float *out_pool = &dst[pool_stride * c];

	    // dotsum_3x3
	    for (int j = 1; j < cols - 1; j++) // intput h
		for (int i = 1; i < cols - 1; i++) // intput w
		{
		    const int index_out_p0 = (j - 1) * cols + i - 1;
		    const int index_out_p1 = j * cols + i - 1;
		    const int index_out_p2 = (j - 1) * cols + i;
		    const int index_out_p3 = j * cols + i;
		    const int index_out = index_out_p3;

		    int index_out_pool;
		    if (do_pad)
			index_out_pool = j / 2 * pool_size + i / 2;
		    else
			index_out_pool = (j / 2 - 1) * pool_size + i / 2 - 1;

		    float partial = 0;

		    partial += img[index_out - 1 - 1 * cols  ] * filter[0];
		    /* if (k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out - 1 - 1 * cols  ] * filter[0], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out + 0 - 1 * cols  ] * filter[1];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out + 0 - 1 * cols  ] * filter[1], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out + 1 - 1 * cols  ] * filter[2];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out + 1 - 1 * cols  ] * filter[2], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out - 1             ] * filter[3];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out - 1  ] * filter[3], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out + 0             ] * filter[4];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out + 0] * filter[4], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out + 1             ] * filter[5];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out + 1             ] * filter[5], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out - 1 + 1 * cols  ] * filter[6];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out - 1 + 1 * cols  ] * filter[6], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out + 0 + 1 * cols  ] * filter[7];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out + 0 + 1 * cols  ] * filter[7], */
		    /* 	       partial); */
		    /* } */
		    partial += img[index_out + 1 + 1 * cols  ] * filter[8];
		    /* if ( k < 3 && c == 0 && i == 5 && j == 5) { */
		    /* 	printf("FLOAD mul_res %f partial %f\n", */
		    /* 	       img[index_out + 1 + 1 * cols   ] * filter[8], */
		    /* 	       partial); */
		    /* } */

		    out[index_out] = out[index_out] + partial;

		    /* if (k < 3 && c == 0 && i == 5 && j == 5) */
		    /* 	printf("FLOAT out: %f\n", out[index_out]); */

		    // Activation
		    if (last)
		    {
			if (out[index_out] + b < 0)
			    out[index_out] = 0;
			else
			    out[index_out] = out[index_out] + b;

			// Max Pool 2x2
			if ((j % 2 == 0) && (i % 2 == 0) && do_pool)
			{
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
	    if (last && do_pad)
	    {
		for (int i = 0; i < pool_size; i ++)
		    // first row
		    out_pool[i] = 0.0;

		for (int i = 0; i < pool_size; i ++)
		    // last row
		    out_pool[pool_size * (pool_size - 1) + i] = 0.0;

		for (int i = 0; i < pool_size; i ++)
		    // first column
		    out_pool[pool_size * i] = 0.0;

		for (int i = 0; i < pool_size; i ++)
		    // last column
		    out_pool[pool_size * i + pool_size - 1] = 0.0;
	    }
	}
    }
}

template < uint32_t __FPDATA_WL__, uint32_t __W_FPDATA_WL__, uint32_t __FPDATA_FL__, uint32_t __W_FPDATA_FL__ >
void convolution_fixed(float *dst, float *bias, float *src, float *w,
		       int cols, int rows, int src_chans, int dst_chans,
		       int pool_size, int pool_stride,
		       bool do_pool, bool do_pad)
{
    const int chan_stride = cols * rows;
    const int kernel_size = 9;

    // Convolution
    for (int k = 0; k < src_chans; k++)
    {
	bool last = false;
	if (k == src_chans - 1)
	    last = true;

	const float *img = &src[k * chan_stride];

	for (int c = 0; c < dst_chans; c++)
	{
	    const float *filter = &w[k * dst_chans * kernel_size + c * kernel_size];
	    float *out = &dst[chan_stride * c];
	    float *out_pool = &dst[pool_stride * c];

	    // FIXED POINT: convert bias to fixed point
	    int b = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(bias[c]);
	    /* if (k == 0 && c == 0) */
	    /* 	printf("FIXED b_fx: %f, b_fp: %f\n", fixed_to_float<__FPDATA_FL__>(b), bias[c]); */

	    // dotsum_3x3
	    for (int j = 1; j < cols - 1; j++) // intput h
		for (int i = 1; i < cols - 1; i++) // intput w
		{
		    const int index_out_p0 = (j - 1) * cols + i - 1;
		    const int index_out_p1 = j * cols + i - 1;
		    const int index_out_p2 = (j - 1) * cols + i;
		    const int index_out_p3 = j * cols + i;
		    const int index_out = index_out_p3;

		    int index_out_pool;
		    if (do_pad)
			index_out_pool = j / 2 * pool_size + i / 2;
		    else
			index_out_pool = (j / 2 - 1) * pool_size + i / 2 - 1;

		    // FIXED POINT: convert partial output to fixed point
		    int out_fixed = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(out[index_out]);
		    /* if (k == 2 && c == 0) */
		    /* 	printf("FIXED out_fx: %f, out_fp: %f\n", */
		    /* 	       fixed_to_float<__FPDATA_FL__>(out_fixed), out[index_out]); */

		    // FIXED POINT: convert weights to fixed point
		    int filter_fixed[9];
		    for (int ii = 0; ii < 9; ii++) {
			filter_fixed[ii] = float_to_fixed_weights<__W_FPDATA_FL__, __W_FPDATA_WL__>(filter[ii]);
			/* if (k == 0 && c == 0 && i == 5 && j == 5) */
			/*     printf("FIXED w_fx: %f, w_fp: %f\n", */
			/* 	   fixed_to_float_weights<__W_FPDATA_FL__>(filter_fixed[ii]), filter[ii]); */
		    }

		    // FIXED POINT: convert input to fixed point
		    int img_fixed[9];
		    img_fixed[0] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out - 1 - 1 * cols]);
		    img_fixed[1] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out + 0 - 1 * cols]);
		    img_fixed[2] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out + 1 - 1 * cols]);
		    img_fixed[3] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out - 1]);
		    img_fixed[4] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out + 0]);
		    img_fixed[5] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out + 1]);
		    img_fixed[6] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out - 1 + 1 * cols]);
		    img_fixed[7] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out + 0 + 1 * cols]);
		    img_fixed[8] = float_to_fixed<__FPDATA_FL__, __FPDATA_WL__>(img[index_out + 1 + 1 * cols]);
		    
		    // FIXED POINT: accumulate o += dot_product(i * w)
		    int out_fixed_partial = 0;
		    for (int ii = 0; ii < 9; ii++) {
			int mul_res = mul_fixed<__FPDATA_WL__, __FPDATA_FL__, __W_FPDATA_FL__>(img_fixed[ii], filter_fixed[ii]);

			/* if (k == 0 && c == 0 && i == 5 && j == 5 && ii == 0) */
			/*     printf("FIXED mul_res: %f, factor1: %f, factor: %f\n", */
			/*        fixed_to_float<__FPDATA_FL__>(mul_res), img[index_out - 1 - 1 * cols], */
			/* 	   filter[ii]); */

			/* int saved_out_fixed = out_fixed; */
			out_fixed_partial = add_fixed<__FPDATA_WL__>(out_fixed_partial, mul_res);

			/* if (k == 0 && c == 0 && i == 5 && j == 5 && ii == 0) */
			/*     printf("FIXED mul_res: %f, factor1: %f, factor: %f\n", */
			/* 	   fixed_to_float<__FPDATA_FL__>(out_fixed), fixed_to_float<__FPDATA_FL__>(saved_out_fixed), */
			/* 	   fixed_to_float<__FPDATA_FL__>(mul_res)); */

			/* if (k < 3 && c == 0 && i == 5 && j == 5) { */
			/*     printf("FIXED mul_res %f out_fixed_partial %f\n", */
			/* 	   fixed_to_float<__FPDATA_FL__>(mul_res), fixed_to_float<__FPDATA_FL__>(out_fixed_partial)); */
			/* } */
		    }
		    out_fixed = add_fixed<__FPDATA_WL__>(out_fixed, out_fixed_partial);

		    /* if (k < 3 && c == 0 && i == 5 && j == 5) */
		    /* 	printf("FIXED out_fixed: %f\n", fixed_to_float<__FPDATA_FL__>(out_fixed)); */

		    if (last)
		    {
			out_fixed = add_fixed<__FPDATA_WL__>(out_fixed, b);
	
			out[index_out] = fixed_to_float<__FPDATA_FL__>(out_fixed);

			if (out[index_out] < 0)
			    out[index_out] = 0;

			// Max Pool 2x2
			if ((j % 2 == 0) && (i % 2 == 0) && do_pool)
			{
			    const float p0 = out[index_out_p0];
			    const float p1 = out[index_out_p1];
			    const float p2 = out[index_out_p2];
			    const float p3 = out[index_out_p3];

			    float max = p0;

			    // TODO fixed point
			    if (max < p1)
				max = p1;
			    if (max < p2)
				max = p2;
			    if (max < p3)
				max = p3;
			    out_pool[index_out_pool] = max;
			}
		    } else {
			out[index_out] = fixed_to_float<__FPDATA_FL__>(out_fixed);
		    }
		}

	    // Pad (resize)
	    if (last && do_pad)
	    {
		for (int i = 0; i < pool_size; i ++)
		    // first row
		    out_pool[i] = 0.0;

		for (int i = 0; i < pool_size; i ++)
		    // last row
		    out_pool[pool_size * (pool_size - 1) + i] = 0.0;

		for (int i = 0; i < pool_size; i ++)
		    // first column
		    out_pool[pool_size * i] = 0.0;

		for (int i = 0; i < pool_size; i ++)
		    // last column
		    out_pool[pool_size * i + pool_size - 1] = 0.0;
	    }
	}
    }
}

void convolution_compute(float *dst, float *bias, float *src, float *w,
			 int cols, int rows, int src_chans, int dst_chans,
			 int pool_size, int pool_stride,
			 bool do_pool, bool do_pad, bool stage, int layer_n)
{
#ifndef SYSTEM_ACCURACY
    if (stage) {
	convolution_fixed<FPDATA_WL, W_FPDATA_WL, FPDATA_FL, W_FPDATA_FL>(dst, bias, src, w,
           cols, rows, src_chans, dst_chans, pool_size, pool_stride, do_pool, do_pad);
    } else {
	convolution_float(dst, bias, src, w, cols, rows, src_chans,
			  dst_chans, pool_size, pool_stride, do_pool,
			  do_pad);
    }
#else // SYSTEM_ACCURACY
    if (layer_n == 1)
    {
        // printf("-- running layer 1 with %u %u %u %u\n", LAYER_FPDATA_WL_1,
        //   LAYER_FPDATA_IL_1, LAYER_FPDATA_WL_1, LAYER_W_FPDATA_IL_1);
	convolution_fixed<LAYER_FPDATA_WL_1,
                          LAYER_W_FPDATA_WL_1, 
                          LAYER_FPDATA_WL_1   - LAYER_FPDATA_IL_1,
                          LAYER_W_FPDATA_WL_1 - LAYER_W_FPDATA_IL_1>(
                          dst, bias, src, w, cols, rows, src_chans, dst_chans, pool_size,
                          pool_stride, do_pool, do_pad);
    }
    else if (layer_n == 2)
    {
        // printf("-- running layer 2 with %u %u %u %u\n", LAYER_FPDATA_WL_2,
        //   LAYER_FPDATA_IL_2, LAYER_FPDATA_WL_2, LAYER_W_FPDATA_IL_2);	
	convolution_fixed<LAYER_FPDATA_WL_2,
                          LAYER_W_FPDATA_WL_2, 
                          LAYER_FPDATA_WL_2   - LAYER_FPDATA_IL_2,
                          LAYER_W_FPDATA_WL_2 - LAYER_W_FPDATA_IL_2>(
                          dst, bias, src, w, cols, rows, src_chans, dst_chans, pool_size,
                          pool_stride, do_pool, do_pad);
    }
    else if (layer_n == 3)
    {
        // printf("-- running layer 3 with %u %u %u %u\n", LAYER_FPDATA_WL_3,
        //   LAYER_FPDATA_IL_3, LAYER_FPDATA_WL_3, LAYER_W_FPDATA_IL_3);	
	convolution_fixed<LAYER_FPDATA_WL_3,
                          LAYER_W_FPDATA_WL_3, 
                          LAYER_FPDATA_WL_3   - LAYER_FPDATA_IL_3,
                          LAYER_W_FPDATA_WL_3 - LAYER_W_FPDATA_IL_3>(
                          dst, bias, src, w, cols, rows, src_chans, dst_chans, pool_size,
                          pool_stride, do_pool, do_pad);

    }
    else if (layer_n == 4)
    {
        // printf("-- running layer 4 with %u %u %u %u\n", LAYER_FPDATA_WL_4,
        //  LAYER_FPDATA_IL_4, LAYER_FPDATA_WL_4, LAYER_W_FPDATA_IL_4);
	convolution_fixed<LAYER_FPDATA_WL_4,
                          LAYER_W_FPDATA_WL_4, 
                          LAYER_FPDATA_WL_4   - LAYER_FPDATA_IL_4,
                          LAYER_W_FPDATA_WL_4 - LAYER_W_FPDATA_IL_4>(
                          dst, bias, src, w, cols, rows, src_chans, dst_chans, pool_size,
                          pool_stride, do_pool, do_pad); 
    }
    else {
      // printf("-- this should not happen\n");
    }

#endif // SYSTEM_ACCURACY
}

//
// Fully connected
//

void fc_compute(float *dst, float *src, float *w, float *b,
		int w_cols, int w_rows, bool relu)
{

	for (int j = 0; j < w_rows; j++)
	{
		const int w_index = j * w_cols;
		dst[j] = 0;
		for (int i = 0; i < w_cols; i++)
			dst[j] += src[i] * w[w_index + i];
		if (relu)
		{
			if (dst[j] + b[j] < 0)
				dst[j] = 0;
			else
				dst[j] += b[j];
		}
	}

	if (!relu)
		for(int i = 0; i < w_rows; i++)
		{
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



const char *labels[]={"airplane", "automobile", "bird", "cat", "deer", "dog", "frog", "horse", "ship", "truck"};

#endif // _DWARF_H_
