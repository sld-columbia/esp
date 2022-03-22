#include <stdint.h>
#include <math.h>

#include <utils/fft2_utils.h>


/*
 * This determines the maximum admissible relative error between the accelerated
 * FFT2 and the software one.
 *
 * Note that in simulation, this code is compiled into something different
 * than what is run natively to model the accelerator, so a discrepancy
 * between the simulated and accelerated FFT2 (which in this case would be
 * native) is totally normal.
 *
 * With a hardware accelerator, a discrepancy is again expected, since
 * the floating point precision of the hardware accelerator is different
 * from that of the host CPU.
 */
#define MAX_REL_ERR 0.05

unsigned int fft2_rev(unsigned int v)
{
    unsigned int r = v;
    int s = sizeof(v) * CHAR_BIT - 1;

    for (v >>= 1; v; v >>= 1) {
        r <<= 1;
        r |= v & 1;
        s--;
    }
    r <<= s;
    return r;
}

void fft2_bit_reverse(float *w, unsigned int offset, unsigned int n, unsigned int bits)
{
    unsigned int i, s, shift;

    s = sizeof(i) * CHAR_BIT - 1;
    shift = s - bits + 1;

    for (i = 0; i < n; i++) {
        unsigned int r;
        float t_real, t_imag;

        r = fft2_rev(i);
        r >>= shift;

        if (i < r) {
            t_real = w[2 * (offset + i)];
            t_imag = w[2 * (offset + i) + 1];
            w[2 * (offset + i)] = w[2 * (offset + r)];
            w[2 * (offset + i) + 1] = w[2 * (offset + r) + 1];
            w[2 * (offset + r)] = t_real;
            w[2 * (offset + r) + 1] = t_imag;
        }
    }

}


void fft2_do_shift(float *A0, unsigned int offset, unsigned int num_samples, unsigned int bits)
{
    int md = (num_samples/2);
    unsigned oi;
    /* shift: */
    for(oi = 0; oi < md; oi++) {
        unsigned int iidx = 2*(offset + oi);
        unsigned int midx = 2*(offset + md + oi);
        //printf("TEST: DO_SHIFT: offset %u : iidx %u %u midx %u %u\n", offset, iidx, (iidx+1), midx, (midx+1));

        float swap_rl, swap_im;
        swap_rl = A0[iidx];
        swap_im = A0[iidx + 1];
        A0[iidx]     = A0[midx];
        A0[iidx + 1] = A0[midx + 1];
        A0[midx]     = swap_rl;
        A0[midx + 1] = swap_im;
    }
}


int fft2_comp(float *data, unsigned nffts, unsigned int n, unsigned int logn, int do_inverse, int do_shift)
{
    int nf;
    for (nf = 0; nf < nffts; nf++) {
	unsigned int transform_length;
	unsigned int a, b, i, j, bit;
	float theta, t_real, t_imag, w_real, w_imag, s, t, s2, z_real, z_imag;

        unsigned int offset = nf * n;  // This is the offset for start of nf=th FFT
        int sign;
        //printf("TEST : Doing computation of FFT %u : data[%u] = %.15g\n", nf, 2*offset, data[2*offset]);
        if (do_inverse) {
            sign = 1;
            if (do_shift) {
                //printf("TEST: Calling Inverse-Do-Shift\n");
                fft2_do_shift(data, offset, n, logn);
            }
        } else {
            sign = -1;
        }

	transform_length = 1;

        // Do the bit-reverse
        fft2_bit_reverse(data, offset, n, logn);

	/* calculation */
	for (bit = 0; bit < logn; bit++) {
            w_real = 1.0;
            w_imag = 0.0;

            theta = 1.0 * sign * M_PI / (float) transform_length;

            s = sin(theta);
            t = sin(0.5 * theta);
            s2 = 2.0 * t * t;

            for (a = 0; a < transform_length; a++) {
                for (b = 0; b < n; b += 2 * transform_length) {
                    i = offset + b + a;
                    j = offset + b + a + transform_length;

                    z_real = data[2 * j];
                    z_imag = data[2 * j + 1];

                    t_real = w_real * z_real - w_imag * z_imag;
                    t_imag = w_real * z_imag + w_imag * z_real;

                    /* write the result */
                    data[2*j]	= data[2*i] - t_real;
                    data[2*j + 1]	= data[2*i + 1] - t_imag;
                    data[2*i]	+= t_real;
                    data[2*i + 1]	+= t_imag;
                } // for (b = 0 .. n by 2*transform_length

                /* adjust w */
                t_real = w_real - (s * w_imag + s2 * w_real);
                t_imag = w_imag + (s * w_real - s2 * w_imag);
                w_real = t_real;
                w_imag = t_imag;

            } // for (a = 0 .. transform_length)
            transform_length *= 2;
	} // for (bit = 0 .. logn )

        if ((!do_inverse) && do_shift) {
            //printf("TEST: Calling Non-Inverse Do-Shift\n");
            fft2_do_shift(data, offset, n, logn);
        }

    } // for (nf = 0 .. num_ffts)

    return 0;
}
