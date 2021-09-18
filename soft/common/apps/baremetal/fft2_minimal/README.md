# FFT2 Minimal Test

This is a short version of the FFT2 baremetal test application. This
is obtained by simplifying the original version
(`accelerators/stratus_hls/fft2_stratus/sw/baremetal`). This minimal
application doesn't probe the device tree to look for FFT2_STRATUS
devices, it uses preset input and expected outputs array, it doesn't
execute the FFT on the CPU, and it has minimal terminal prints.

## Execute the test

From any design folder run:

```bash
# compile the bare-metal app
make fft2_minimal-baremetal

# run RTL simulation of the bare-metal app
TEST_PROGRAM=soft-build/ariane/baremetal/fft2_minimal.exe make sim
```

## Mandatory test customization

- In `fft2_minimal.h` set `ACC_ID` according to the position of the
  `fft2_stratus` accelerator to be tested. The accelerator IDs start
  from 0 and count the accelerator tiles from left to right and from
  top to bottom.

- In `fft2_minimal.c` the default initialization value of
  `logn_samples` is `3`. Accordingly, the `init_buf` function includes
  the corresponding input and expected output (gold) header
  files. This default test is pretty much the shortest possible test
  of the FFT2 accelerator (FFT on an array of 16 words). By
  initializing `logn_samples` to `10` and by including the `long_10`
  version of the header files in `init_buf` you will run a more
  meaningful test (FFT on an array of 2048 words).

- The default accelerator coherence mode (`coherence`) is set to
  ACC_COH_RECALL. This avoids the need of cache flushes to synchronize
  CPU and accelerator, and it doesn't require the accelerator tile to
  have a private cache. You can modify this parameter as needed.

- Most `printf` are commented out, but it can be useful to decomment
  them for debugging purposes.
