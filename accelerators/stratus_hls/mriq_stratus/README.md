### Directory introduction:

* `hw/`

  * `mriq.xml`

  * `memlist.txt`

  * `hls/`

  * `sim/`

  * `tb/`

  * `src/`

  * `inc/`
 
  * `data/`
    * 32\_32\_32\_dataset.bin: 
      * It comes from Parboil benchmark, with numX as 32768, numK as 3072. We use this file to generate test data with smaller sizes.
    * genData.c :
        * generate a smaller dataset from 32\_32\_32\_dataset.bin. It needs two arguments: numX and numK. It writes new data into an input file with name test\_32\_x<numX>\_k<numK>.bin and a golden output file test\_32\_x<numX>\_k<numK>.bin with the same data layout. So we can use the two programs provided by Parboil benchmark to read data into pointer variables.
    *  wrt_bmData.c
        *   This program is used to generate test data for baremetal application. We need to provide six arguments:  1, numX, 2. numK, 3. batch\_size\_k, 4. num\_batch\_k, 5. batch\_size\_x, 6. num\_batch\_x.
    * Makefile
        *   compile genData.c and wrt_bmData.c


* `sw/`

  * `baremetal`

  * `linux`

* `common/`
    * helper.h 
        * Contains functions reading data from input file and golden output file. It is included by init_buff.h file
    * init_buff.h
        * Generate input data and golden output data. It is used in hw/tb/system.cpp and sw/linux/app/mriq.c. 
    * sw_exec.h
        * It is only used in sw/linux/app/mriq.c. sw_exec() measures executing time of software computation. 
    * utils.h 
        * Has two functions: init\_parameters() and validate\_buffer(). They are used by hw/tb/system.cpp, sw/baremetal/mriq.c, sw/linux/app/mriq.c

###  Testing Instructions:
#### Testing with testbench
The file path and name are specified in hls/project.tcl. We hardcoded the test file names and path in hls/project.tcl as hw/data/test\_small.bin and hw/data/test\_small.out. Its configuration parameters are [batch\_size\_x, num\_batch\_x, batch\_size\_k, num\_batch\_k] = [4, 1, 16, 1]. If you want to use other paramters, you can firstly specify them in tb/system.hpp file, then use the same parameters to generate the corresponding testing data with programs in hw/data. You can rename the testing file in project.tcl or use the same name "test\_small"
#### Testing with baremetal app
We can generate the corresponding test data with the two programs under hw/data/ folder. The instructions of how to generate test data are in the README file of hw/data/. We then set the configuration parameters in sw/baremetal/mriq.c and include the file in init\_buf() function.

#### Testing with Linux app

There are three arguments of linux app: name-of-input-file, name-of-golden-outputfile, and the answer to "do you want to run software program of this accelerator?". For example:
>  ./mriq_stratus.exe test_small.bin test_small.out 0

The 3rd argment tells the linux app whether you want to run the software code of computation and measure its execution time on FPGA. "0" means "No" and "1" is "Yes". Files should be transfered to the ~/applications/test/ folder on Linux.
