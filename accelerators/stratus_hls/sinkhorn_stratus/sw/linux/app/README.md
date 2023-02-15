Sinkhorn Accelerator Linux Application
======================================

`hiwa.c` - Run the Sinkhorn accelerator with fixed-point data type (11 bit integer part out of 32 bit) and input from memory to complete 1 iteration of the HiWA algorithm.\
`hiwa_svd.c` - Run 1 Sinkhorn accelerator and 1 SVD acceelrator to implement the HiWA algorithm. Accelerators communicate through P2P or memory.\
`hiwa_svd_mem.c` - Run 1 Sinkhorn accelerator and 1 SVD accelrator to implement the HiWA algorithm. Accelerators communicate through memory.\
`multi_hiwa.c` - Run 4 Sinkhorn accelerators and 4 SVD accelrators in parallel to implement the HiWA algorithm. Accelerators communicate through P2P. All Sinkhorn-SVD pairs compute over the same dataset and should generate the same final output.\
`multi_hiwa2.c` - Run 2-3 Sinkhorn accelerators and 2-3 SVD accelrators in parallel to implement the HiWA algorithm. Accelerators communicate through P2P.All Sinkhorn-SVD pairs compute over the same dataset and should generate the same final output.\
`total_hiwa.c` - Run 4 Sinkhorn accelerators and 4 SVD accelrators in parallel to implement the HiWA algorithm. Accelerators communicate through P2P. Each Sinkhorn-SVD pair compute over different datasets and generates a different final output.

`c_run.cpp` `c_run.h` - Implement C++ functions to simulate Sinkhorn on FPGA without the accelerator.
