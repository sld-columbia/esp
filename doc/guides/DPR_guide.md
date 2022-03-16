# ESP Dynamic Partial Reconfiguration (DPR) guide

This guides introduces the ESP DPR FPGA flow and the runtime reconfiguration 
of accelerators using DPR. The flow explains the necessary design steps 
to generate the bitstreams as well as the post-bitstream-generation 
processing to prepare for an execution. Meanwhile, the runtime reconfiguation 
demonstrates how to swap accelerators on the fly.
       
## Brief description

This guide demonstrates FPGA prototyping of ESP in 2x2 tile
configuration using the DPR flow. The tiles are configured as, a cpu
tile, an accelerator tile, a mem tile and an I/O tile.  Protoyping ESP
with the DPR flow is almost the same as the non-dpr flow except the
make targets that are used to generate the FPGA bitstream and
programming the FPGA in Xilinx Vivado.  

This simple example demonstrates the implementation and execution of two accelerators 
(MAC and FIR) using the DPR flow. In the first design run, the full and partial bitstreams
of the MAC accelerator are generated. Then in the second design run, only the partial 
bitstreams are generated for the FIR accelerators. Both accelerators are designed using
the Vivado HLS based acceleration design flow from the ESP website,
https://www.esp.cs.columbia.edu/docs/cpp_acc/cpp_acc-guide, but the flow does not change
for SystemC based accelerators designed using Stratus/Catapult.

The DPR flow was fully tested on the Xilinx VC707. The development for the
VCU118 and VCU128 targets is still in progress.

### First design run: MAC accelerator implementaion

1. Follow the steps to create the MAC acclerator using the guide
   https://www.esp.cs.columbia.edu/docs/cpp_acc/cpp_acc-guide/ up
   until "the Accelerator integration" step.

2. Follow the steps to generate a single-core ESP SoC
   https://www.esp.cs.columbia.edu/docs/singlecore/singlecore-guide/
   except the "FPGA prototyping section".

3. At the FPGA prototyping stage replace the `make vivado-syn` target
   with `make vivado-syn-dpr`.

At the end of this step, you should note the following
    a. The full and partial bitstreams of the design are located inside
    `socs/xilinx-vc707-xc7vx485t/vivado_dpr/Bitstreams` folder.
    The `acc_bs.bit` represents the full bitstream and `mac_vivado_x.bin` 
    (x representing the tile_id) is the partial bitstream.
    
    b. The partial bistreams are also stored inside 
    `socs/xilinx-vc707-xc7vx485t/partial_bistreams` folder.

    c. The flow also generates a struct inside 
    `socs/xilinx-vc707-xc7vx485tsocgen/esp/pbs_map.h` that contains 
    general information used when the partial bitstreams are loaded 
    on the FPGA. 

### Second design run: Implementing the FIR accelerator

In the second design run, the MAC accelerator is replaced with FIR
accelerator. All the other tiles in the design remain unchanged.

1. Follow the steps to create the FIR accelerator using the guide
   https://www.esp.cs.columbia.edu/docs/cpp_acc/cpp_acc-guide/. Run
   the `/tools/accgen/accgen.sh` and customize the accelerator template as follows
   ```
   * Enter accelerator name [dummy]: fir
   * Select design flow (Stratus HLS, Vivado HLS, hls4ml) [S]: V
   * Enter ESP path [/home/sholmes/esp_new/esp]: 
   * Enter unique accelerator id as three hex digits [04A]: 122
   * Enter accelerator registers
     - register 0 name [size]: fir_in
     - register 0 default value [1]: 120
     - register 0 max value [120]: 
     - register 1 name []: fir_iter
     - register 1 default value [1]: 10
     - register 1 max value [10]: 
     - register 2 name []: 
   * Configure PLM size and create skeleton for load and store:
     - Enter data bit-width (8, 16, 32, 64) [32]: 
     - Enter input data size in terms of configuration registers (e.g. 2 * fir_in}) [fir_in]: 
       data_in_size_max = 120
     - Enter output data size in terms of configuration registers (e.g. 2 * fir_in) [fir_in]: 
       data_out_size_max = 120
     - Enter an integer chunking factor (use 1 if you want PLM size equal to data size) [1]: 
       Input PLM has 120 32-bits words
       Output PLM has 120 32-bits words
     - Enter number of input data to be processed in batch (can be function of configuration registers) [1]:  fir_iter
       batching_factor_max = 16
   ```

2. Replace the body of the `compute()` function in
   `accelerators/vivado_hls/fir_vivado/hw/src/espacc.cpp` with the following
   code
   ```c
   //FIR window size
   const unsigned N  = 10;
   int j, i;

   //FIR coeff
   int coeff[N] = {13, -2, 9, 11, 26, 18, 95, -43, 6, 74};

   //Shift registersint
   int shift_reg[N] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

   // loop through each output
   for (i = 0; i < fir_in; i++ ) {
       int acc = 0;

       // shift registers
       for (j = N -1; j > 0; j--) {
           shift_reg[j] = shift_reg[j -1];
       }

       // put the new input value into the first register
       shift_reg[0] = _inbuff[i];

       // do multiply-accumulate operation
       for (j = 0; j < N; j++) {
           acc += shift_reg[j] * coeff[j];
       }

       _outbuff[i] = acc;
   }
   ```

3. Replace the initialization of the inbuff and outbuff_gold in
   accelerators/vivado_hls/fir_vivado/hw/tb/tb.cc with the following code
   ```c
   //FIR window size
   const unsigned N = 10;

   //FIR coeff
   int coeff[N] = {13, -2, 9, 11, 26, 18, 95, -43, 6, 74};

   // Prepare input data
   for(unsigned i = 0; i < fir_iter; i++)
       for(unsigned j = 0; j < fir_in; j++)
           inbuff[i * in_words_adj + j] = (word_t) j;

   for(unsigned i = 0; i < dma_in_size; i++)
       for(unsigned k = 0; k < VALUES_PER_WORD; k++)
           mem[i].word[k] = inbuff[i * VALUES_PER_WORD + k];

   for(unsigned k = 0; k < fir_iter; k++) {
       for(unsigned n = 0; n < fir_in; n++) {
           outbuff_gold[k * out_words_adj + n] = 0;
           for (unsigned i = 0; i < N; i++){
               int temp = (int) n - i;
               if(temp >= 0)
                   outbuff_gold[k * out_words_adj + n] +=
                   coeff[i] * inbuff[k * in_words_adj + n - i];
           }
       }
   }
   ```

4. Replace the code inside the init_buff function in
   accelerators/vivado_hls/fir_vivado/sw/baremetal/fir.c with the following code
   ```c
   int i;
   int j;
   int k;
   int n;

   const unsigned N = 10;
   int coeff[] = {13, -2, 9, 11, 26, 18, 95, -43, 6, 74};

   for (i = 0; i < fir_iter; i++)
       for (j = 0; j < fir_in; j++)
           in[i * in_words_adj + j] =  (token_t) j;

   for (k = 0; k < fir_iter; k++) {
       for (n = 0; n < fir_in; n++) {
           gold[k * out_words_adj + n] = 0;
           for (i = 0; i < N; i++){
               if ( n - i >= 0) {
                   gold[k * out_words_adj + n] +=
                   coeff[i] * in[k * in_words_adj + n - i];
               }
           }
       }
   }
   ```
4. Generate your accelerator using `make fir-hls` same way as you
   would for the mac accelerator.

5. run the `make esp-xconfig` target to change the accelerator tile
   from MAC_VIVADO to FIR_VIVADO

6. run `make vivado-syn-dpr-acc` to replace the accelerator and run
   vivado implementation

7. Finally when deploying the bitstream into the FPGA, replace the
`fpga-run` and `fpga-run-linux` targets with `fpga-run-dpr` and
`fpga-run-linux-dpr`, to load the bitstream to the FPGA and run a
baremetal application or linux.

## Once again, things to Note

    a. The `socs/xilinx-vc707-xc7vx485t/partial_bistreams` folder is updated
    with the new fir bitstream. 
    
    b. The struct inside `socs/xilinx-vc707-xc7vx485tsocgen/esp/pbs_map.h` is
    also updated with fir bistream information.


## Executing the accelerators
    Performing the DPR execution consists of three steps

    a. Loading the design with the full bitstream and the partial bitstreams
        using the `make fpga-reconf` target

    b. Slightly patching the baremetal software and compiling them.
    The sw patch is added to call the DPR library to enable the tile 
    decoupler during reconfiguation and trigger the reconfiguration.
    
    The patched files are `accelerators/vivado_hls/fir_vivado/sw/baremetal/fir.c` 
    and `accelerators/vivado_hls/mac_vivado/sw/baremetal/mac.c` 
    
    Patch 1. add

    ```c
    
    #include <prc_utils.h>
    
    ```
    Patch 2. replace the 
    
    ```c
    printf("**************** %s.%d ****************\n", DEV_NAME, n);
    
    dev = &espdevs[n];
    
    ``` code with 
    
    ```c
    printf("**************** %s.%d ****************\n", DEV_NAME, n);
            
    dev = &espdevs[n];
    
    decouple_acc(dev, 0); //disable decoupler
    
    ```

    Patch 3. add the following before the end of the function

    ```c
    //
    decouple_acc(dev, 1); //enable decoupler
    reconfigure_FPGA(dev, 0);

    return 0; 

    ```
    The baremetal sw is compiled as 
        `make mac_vivado-baremetal` and  `make mac_vivado-baremetal`

    c. Run the accelerator using 
        make `fpga-run-sw` target
