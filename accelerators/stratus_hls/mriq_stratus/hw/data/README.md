How to generate testing data for bare metal app and linux app

1. run "make"
2. run genData with 2 arguments
   * ./genData numX numK (replace numX and numK with the value you want)
   * For example: ./genData 64 64

         ./genData 64 64

    *   genData generates two files:

        1. "test_32_x64_k64.bin"
        2. "test_32_x64_k64.out"
        
    * These two files needed when testing linux app.
    * They are also fed into wrt_bmData to generate input file for
        baremetal app testing.
3. run wrt_bmData with 6 arguments (6 parameters to the accelerator)
   * The 6 argments are in the following order:

            numX numK batch_size_k num_batch_k batch_size_x num_batch_x
   * For example: 
 
         ./wrt_bmData 64 64 16 4 16 4
    *   wrt_bmData generates one file:
        * "test_32_x64_k64_bm.h"
