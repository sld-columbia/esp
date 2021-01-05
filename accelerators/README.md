# Accelerators

This directory contains multiple accelerator design and integration
flows, as well as many example accelerators. Beside the hardware
design and integration of the accelerators, each flow includes the
design of the software to control the accelerator, both in bare-metal
and on top of Linux.

Each folder corresponds to a design flow:

* `catapult_hls`: accelerator design in C/C++ with Mentor Catapult HLS
  ([guide](https://www.esp.cs.columbia.edu/docs/mentor_cpp_acc/)).

* `chisel`: accelerator design in Chisel.

* `hls4ml`: accelerator design in Keras/Pytorch/ONNX with
  [hls4ml](https://fastmachinelearning.org/hls4ml/)
  ([guide](https://www.esp.cs.columbia.edu/docs/hls4ml/)).

* `stratus_hls`: accelerator design in SystemC with Cadence Stratus
  HLS ([guide](https://www.esp.cs.columbia.edu/docs/systemc_acc/)).

* `third-party`: HW/SW integration of third-party accelerators that
  have not been designed with one of the ESP flows
  ([guide](https://www.esp.cs.columbia.edu/docs/thirdparty_acc/)).

* `vivado_hls`: accelerator design in C/C++ with Xilinx Vivado HLS
  ([guide](https://www.esp.cs.columbia.edu/docs/cpp_acc/)).

The structure of the accelerator folders for the HLS-based flows
(e.g. `stratus_hls/fft_stratus`) are as follows:

* `hw/`

  * `<accelerator>.xml`: accelerator description and register list

  * `memlist.txt`: specs of accelerator private-local memory (SystemC
    accelerators only)

  * `hls/`: HLS and simulation scripts

  * `sim/`: SystemC simulation scripts independent from HLS tool
    (SystemC accelerators only)

  * `tb/`: accelerator testbench

  * `src/`: accelerator source code

  * `inc/`: accelerator header files

* `sw/`

  * `baremetal/`: bare-metal test application for the accelerator

  * `linux/`: Linux test application and Linux device driver for the
    accelerator
