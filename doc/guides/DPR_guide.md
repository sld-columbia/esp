# ESP Dynamic Partial Reconfiguration Flow Guide

A guide to using the dynamic partial reconfiguration (DPR) flow in
ESP.

## Why the DPR flow for ESP?

The major advantage of using the DPR flow in ESP is to reduce the FPGA
prototyping (FPGA implementation) time of a design for design
iterations where only some portion of the design is modified.  In the
near future, a run-time partial reconfiguration will also be
integrated into ESP. In the run-time partial reconfiguration of
accelerators, all the accelerator tiles are partially reconfigurable
and can be swapped in and out of the design at run-time without the
need to fully reconfigure the FPGA (while the rest of the system
continues to be operational).  The DPR flow is an alternative to the
exisiting monolithic vivado prototyping of ESP.
        
## An example of the ESP DPR flow

This guide demonstrates FPGA prototyping of ESP in 2x2 tile
configuration using the DPR flow. The tiles are configured as, a cpu
tile, an accelerator tile, a mem tile and an I/O tile.  Protoyping ESP
with the DPR flow is almost the same as the non-dpr flow except the
make targets that are used to generate the FPGA bitstream and
programming the FPGA in Xilinx Vivado.  The example focuses on
implementing ESP with a MAC accelerator in the accelerator tile in the
first design run, and then replacing the MAC accelerator with a FIR
accelerator in the second run. Both accelerators are designed using
the Vivado HLS based acceleration design flow from the ESP website,
https://www.esp.cs.columbia.edu/docs/cpp_acc/cpp_acc-guide, but it
should also work for the systemC based accelerator design flow.

The DPR flow was tested on the Xilinx VC707, VCU118 and VCU128 design
targets.

### First design run: MAC accelerator implementaion

1. Follow the steps to create the MAC acclerator using the guide
   https://www.esp.cs.columbia.edu/docs/cpp_acc/cpp_acc-guide/ up
   until "the Accelerator integration" step.

2. Follow the steps to generate a single-core ESP SoC
   https://www.esp.cs.columbia.edu/docs/singlecore/singlecore-guide/
   except the "FPGA prototyping section".

3. At the FPGA prototyping stage replace the `make vivado-syn` target
   with `make vivado-syn-dpr`.

4. Finally when deploying the bitstream into the FPGA, replace the
`fpga-run` and `fpga-run-linux` targets with `fpga-run-dpr` and
`fpga-run-linux-dpr`, to load the bitstream to the FPGA and run a
baremetal application or linux respectively.

### Second design run: Replacing the MAC accelerator with a FIR accelerator

In the second design run, the MAC accelerator is replaced with FIR
accelerator. All the other tiles in the design remain unchanged.

1. Follow the steps to create the FIR accelerator using the guide
   https://www.esp.cs.columbia.edu/docs/cpp_acc/cpp_acc-guide/. Run
   the `init_accelerator.sh` with the following specifications
   ```
   * Enter accelerator name [dummy]: fir
   * Select design flow (Stratus HLS, Vivado HLS, hls4ml) [S]: V
   * Enter ESP path [/home/sholmes/esp_new/esp]: 
   * Enter unique accelerator id as three hex digits [04A]: 100
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
   `accelerators/vivado_hls/fir/src/espacc.cpp` with the following
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
   accelerators/vivado_hls/fir/tb/tb.cc with the following code
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
   soft/ariane/drivers/fir/barec/fir.c with the following code
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
   from MAC to FIR

6. run `make vivado-syn-dpr-acc` to replace the accelerator and run
   vivado implementation

7. Finally when deploying the bitstream into the FPGA, replace the
`fpga-run` and `fpga-run-linux` targets with `fpga-run-dpr` and
`fpga-run-linux-dpr`, to load the bitstream to the FPGA and run a
baremetal application or linux.

## Things to Note

In the existing DPR integration, only the accelerator tiles are
partially reconfigurable, hence if any of the tiles, besides the
accelerator tile, are modified, then the flow must be run again with
`make vivado-syn-dpr`.  The design flow has been tested with a 3x2,
2x3, 3x3 and 4x3 tile configuration.
