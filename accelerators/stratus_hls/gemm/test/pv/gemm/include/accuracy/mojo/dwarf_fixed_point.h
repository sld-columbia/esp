/* Copyright 2019 Columbia University, SLD Group */
/* Contact: paolo@cs.columbia.edu                */

#ifndef _DWARF_FIXED_POINT_H_
#define _DWARF_FIXED_POINT_H_

#include <cmath>

// FIXED POINT input, output and bias fraction part precision
#define FPDATA_FL (FPDATA_WL - FPDATA_IL)

// FIXED POINT weights fraction part precision
#define W_FPDATA_FL (W_FPDATA_WL - W_FPDATA_IL)


int add_fixed(int a, int b)
{
    long long int _a = a;
    long long int _b = b;

    long long int res = _a + _b;

    bool sign = (res < 0);

    if (!sign) {
	if (res >= (1 << FPDATA_WL)) {
	    // saturate
	    res = ((1 << (FPDATA_WL - 1)) - 1);
	}
    } else {
	if ((-res) >= (1 << FPDATA_WL)) {
	    // saturate
	    res = ((1 << (FPDATA_WL - 1)));
	}
    }

    return (int) res;
}

int mul_fixed(int a, int b)
{
    long long int res;
    long long int _a = a;
    long long int _b = b;

    if (FPDATA_FL > W_FPDATA_FL)
    {
        _b = _b << (long long int) (FPDATA_FL - W_FPDATA_FL);
        res = (_a * _b) >> (long long int) FPDATA_FL;
    }

    if (FPDATA_FL < W_FPDATA_FL)
    {
        _a = _a << (long long int) (W_FPDATA_FL - FPDATA_FL);
        res = (_a * _b) >> (long long int) (W_FPDATA_FL + (W_FPDATA_FL - FPDATA_FL));
    }

    res = (_a * _b) >> (long long int) FPDATA_FL;

    bool sign = (res < 0);

    if (!sign) {
	if (res >= (1 << FPDATA_WL)) {
	    // saturate
	    res = ((1 << (FPDATA_WL - 1)) - 1);
	}
    } else {
	if ((-res) >= (1 << FPDATA_WL)) {
	    // saturate
	    res = ((1 << (FPDATA_WL - 1)));
	}
    }

    return (int) res;
}

/*
 * Helpers to convert to/from floating and fixed point.
 *
 * The functions directly manipulate floating point type bits to
 * directly compute 1 / 2^n_int_bits.
 */

/**
 * fixed_to_float - convert a fixed point value to single-precision
 * floating point.
 * @value: fixed point value to be converted
 * @n_frac_bits: number of fractional bits
 *
 * Note: this assumes the fixed point value is at most 64 bits long
 */
static inline float fixed_to_float(long long int value)
{
    double f = (double) value / (double) (1 << FRAC_BITS);
    return (float) f;
}


/**
 * float_to_fixed - convert a single-precision floating point value to
 * fixed point.
 * @value: floating point value to be converted
 * @n_frac_bits: number of fractional bits
 *
 * Note: this assumes the fixed point value is at most 64 bits long
 */
static inline int float_to_fixed(float value)
{
    double f = (double) value * (double) (1 << FPDATA_FL);
    f = round(f);
    long long int r = (long long int) f;

    bool sign = (value < 0);

    if (!sign) {
	if (r >= (1 << FPDATA_WL)) {
	    // saturate
	    r = ((1 << (FPDATA_WL - 1)) - 1);
	}
    } else {
	if ((-r) >= (1 << FPDATA_WL)) {
	    // saturate
	    r = ((1 << (FPDATA_WL - 1)));
	}
    }

    return (int) r;
}

static inline int float_to_fixed_weights(float value)
{
    double f = (double) value * (double) (1 << W_FPDATA_FL);
    f = round(f);
    long long int r = (long long int) f;

    bool sign = (value < 0);

    if (!sign) {
	if (r >= (1 << W_FPDATA_WL)) {
	    // saturate
	    r = ((1 << (W_FPDATA_WL - 1)) - 1);
	}
    } else {
	if ((-r) >= (1 << W_FPDATA_WL)) {
	    // saturate
	    r = ((1 << (W_FPDATA_WL - 1)));
	}
    }

    return (int) r;
}

//
// Convolution
//
void convolution_compute(float *dst, float *bias, float *src, float *w,
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
	    int b = float_to_fixed(bias[c]);

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
		    int out_fixed = float_to_fixed(out[index_out]);

		    // FIXED POINT: convert weights to fixed point
		    int filter_fixed[9];
		    for (int i = 0; i < 9; i++)
			filter_fixed[9] = float_to_fixed_weights(filter[i]);

		    // FIXED POINT: convert input to fixed point
		    int img_fixed[9];
		    img_fixed[0] = float_to_fixed(img[index_out - 1 - 1 * cols]);
		    img_fixed[1] = float_to_fixed(img[index_out + 0 - 1 * cols]);
		    img_fixed[2] = float_to_fixed(img[index_out + 1 - 1 * cols]);
		    img_fixed[3] = float_to_fixed(img[index_out - 1]);
		    img_fixed[4] = float_to_fixed(img[index_out + 0]);
		    img_fixed[5] = float_to_fixed(img[index_out + 1]);
		    img_fixed[6] = float_to_fixed(img[index_out - 1 + 1 * cols]);
		    img_fixed[7] = float_to_fixed(img[index_out + 0 + 1 * cols]);
		    img_fixed[8] = float_to_fixed(img[index_out + 1 + 1 * cols]);
		    
		    // FIXED POINT: accumulate o += dot_product(i * w)
		    for (int i = 0; i < 9; i++)
			out_fixed = add_fixed(out_fixed, mul_fixed(img[i], filter[i]));

		    if (last)
		    {
			out_fixed = add_fixed(out_fixed, b);
						
			if (out_fixed < 0)
			    out_fixed = 0;

			out[index_out] = fixed_to_fload(out_fixed);

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

#endif // _DWARF_FIXED_POINT_H_
