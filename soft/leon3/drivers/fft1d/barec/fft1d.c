#include <stdbool.h>
#include <assert.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

#include <esp_accelerator.h>
#include <esp_probe.h>
#include <fixed_point.h>

#define SLD_FFT1D  0x10
#define DEV_NAME "fft1d"

/* LOG2 = 3 --> BUF_SIZE = 1KB */
#define FFT_LOG_LEN 3
#define FFT_LEN (1 << FFT_LOG_LEN)

#define FFT_BUF_SIZE (FFT_LEN * sizeof(float) * 2)
#define CHUNK_SHIFT 8
#define DEV_CHUNK_SIZE (1 << CHUNK_SHIFT)
#define NCHUNK ((FFT_BUF_SIZE % DEV_CHUNK_SIZE == 0) ?			\
			(FFT_BUF_SIZE / DEV_CHUNK_SIZE) :			\
			(FFT_BUF_SIZE / DEV_CHUNK_SIZE) + 1)


#define FFT1D_LEN_REG 0x40
#define FFT1D_LOG_LEN_REG 0x44
#define FFT1D_LOG_LEN_MAX_REG 0x48

#define PI 3.14159265358979323846

#define MAX_REL_ERR 0.05

static void to_float(void *buf, int n)
{
	int *bufp = buf;
	int i;

	for (i = 0; i < n * 2; i++)
		fixed_to_float(&bufp[i], 20);
}

static void to_sc_fixed(void *buf, int n)
{
	int *bufp = buf;
	int i;

	for (i = 0; i < n * 2; i++)
		float_to_fixed(&bufp[i], 20);
}

static inline void buf_printf(const float *buf, int n)
{
	int i;

	for (i = 0; i < n; i++)
		printf("%d %.15g %.15g\n", i, buf[2*i], buf[2*i+1]);
}

static bool fft_diff_ok(const float *sw_fft, const float *hw_fft, int n)
{
	bool ok = true;
	int i;

	for (i = 0; i < n; i++) {
		float sw1 = sw_fft[2 * i];
		float sw2 = sw_fft[2 * i + 1];
		float hw1 = hw_fft[2 * i];
		float hw2 = hw_fft[2 * i + 1];
		double rel1 = fabs(sw1 - hw1) / sw1;
		double rel2 = fabs(sw2 - hw2) / sw2;

		if (rel1 > MAX_REL_ERR || rel2 > MAX_REL_ERR) {
			/* fprintf(stderr, "warning: FFT relative discrepancy above maximum relative error %g:\n", MAX_REL_ERR); */
			/* fprintf(stderr, "  sw FFT[%d] = %.15g %.15g\n", 2 * i, sw1, sw2); */
			/* fprintf(stderr, "  hw FFT[%d] = %.15g %.15g\n", 2 * i, hw1, hw2); */
			ok = false;
		}
	}
	return ok;
}

static unsigned int __rev(unsigned int v)
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

static float *bit_reverse(float *w, unsigned int n, unsigned int bits)
{
	unsigned int i, s, shift;
	s = sizeof(i) * CHAR_BIT - 1;
	shift = s - bits + 1;

	for (i = 0; i < n; i++) {
		unsigned int r;
		float t_real, t_imag;
		r = __rev(i);
		r >>= shift;

		if (i < r) {
			t_real = w[2 * i];
			t_imag = w[2 * i + 1];
			w[2 * i] = w[2 * r];
			w[2 * i + 1] = w[2 * r + 1];
			w[2 * r] = t_real;
			w[2 * r + 1] = t_imag;
		}
	}

	return w;
}

static void init_buf(float *a, int n)
{
	int i = 0;

	for (i = 0; i < 2 * n; i++)
		a[i] = (float) rand () / (float) RAND_MAX;
}

static int __fft(float *data, unsigned int n, unsigned int logn, int sign)
{
	unsigned int transform_length;
	unsigned int a, b, i, j, bit;
	float theta, t_real, t_imag, w_real, w_imag, s, t, s2, z_real, z_imag;

	transform_length = 1;

	/* calculation */
	for (bit = 0; bit < logn; bit++) {
		w_real = 1.0;
		w_imag = 0.0;

		theta = 1.0 * sign * PI / (float) transform_length;

		s = sin(theta);
		t = sin(0.5 * theta);
		s2 = 2.0 * t * t;

		for (a = 0; a < transform_length; a++) {
			for (b = 0; b < n; b += 2 * transform_length) {
				i = b + a;
				j = b + a + transform_length;

				z_real = data[2 * j];
				z_imag = data[2 * j + 1];

				t_real = w_real * z_real - w_imag * z_imag;
				t_imag = w_real * z_imag + w_imag * z_real;

				/* write the result */
				data[2*j]	= data[2*i] - t_real;
				data[2*j + 1]	= data[2*i + 1] - t_imag;
				data[2*i]	+= t_real;
				data[2*i + 1]	+= t_imag;
			}

			/* adjust w */
			t_real = w_real - (s * w_imag + s2 * w_real);
			t_imag = w_imag + (s * w_real - s2 * w_imag);
			w_real = t_real;
			w_imag = t_imag;

		}
		transform_length *= 2;
	}

	return 0;
}


int main(int argc, char * argv[])
{
	int i, n;
	struct esp_device *espdevs = NULL;
	unsigned coherence;

	int ndev;

	float *a, *sw;

	printf("Allocating buffers for fft - %u... ", FFT_LEN);
	a = aligned_malloc(FFT_LEN * 2* sizeof(float));
	if (a == NULL) {
		perror("malloc");
		exit(1);
	}

	sw = malloc(FFT_LEN * 2 * sizeof(float));
	if (sw == NULL) {
		perror("malloc");
		exit(1);
	}

	ndev = probe(&espdevs, SLD_FFT1D, DEV_NAME);
	if (!ndev) {
		fprintf(stderr, "Error: %s device not found!\n", DEV_NAME);
		exit(EXIT_FAILURE);
	}

	for (n = 0; n < ndev; n++) {
		for (coherence = ACC_COH_NONE; coherence <= ACC_COH_FULL; coherence++) {
			struct esp_device *dev = &espdevs[n];
			unsigned **ptable;
			unsigned done;
			unsigned log_len_max;

			printf("=== Test %s.%d - cohernece %s ===\n", DEV_NAME, n, coherence_label[coherence]);

			log_len_max = ioread32(dev, FFT1D_LOG_LEN_MAX_REG);

			printf("FFT log2(len) max is %d:\n", log_len_max);

			if (FFT_LOG_LEN < 1 || FFT_LOG_LEN > log_len_max)
			{
				fprintf(stderr, "Unsupported FFT-2D size\n");
				return 1;
			}


			printf("Initializing buffers... ");
			init_buf(a, FFT_LEN);

			/* the hardware does not do bit_reverse so we have to do it here */
			bit_reverse(a, FFT_LEN, FFT_LOG_LEN);

			memcpy(sw, a, FFT_LEN * 2 * sizeof(float));

			printf("Convert to fixed point... ");
			to_sc_fixed(a, FFT_LEN);
			printf("Input ready...\n");


			//Alocate page table
			ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
			for (i = 0; i < NCHUNK; i++)
				ptable[i] = (unsigned *) &a[i * (DEV_CHUNK_SIZE / sizeof(unsigned))];

			printf("ptable = %p\n", ptable);
			printf("nchunk = %d\n", NCHUNK);
			if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
				fprintf(stderr, "Trying to allocate %d chunks on %d TLB available entries\n",
					NCHUNK, ioread32(dev, PT_NCHUNK_MAX_REG));
				exit(EXIT_FAILURE);
			}


			// Configure device
			iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
			iowrite32(dev, COHERENCE_REG, coherence);
			iowrite32(dev, PT_ADDRESS_REG, (unsigned) ptable);
			iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
			iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
			iowrite32(dev, SRC_OFFSET_REG, 0);
			iowrite32(dev, DST_OFFSET_REG, 0);
			iowrite32(dev, FFT1D_LEN_REG, FFT_LEN);
			iowrite32(dev, FFT1D_LOG_LEN_REG, FFT_LOG_LEN);


			// Flush for non-coherent DMA
			esp_flush(coherence);


			printf("Start!\n");
			iowrite32(dev, CMD_REG, CMD_MASK_START);

			done = 0;
			while (!done) {
				done = ioread32(dev, STATUS_REG);
				done &= STATUS_MASK_DONE;
			}
			iowrite32(dev, CMD_REG, 0x0);
			printf("Done!\n");

			// Validate
			to_float(a, FFT_LEN);
			__fft(sw, FFT_LEN, FFT_LOG_LEN, -1);
			if (fft_diff_ok(sw, a, FFT_LEN))
				printf("Success: hw and sw match!\n");
			else
				printf("Fail: found samples with error above threshold!\n");
		}
	}
	return 0;
}

