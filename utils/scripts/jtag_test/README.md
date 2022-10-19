# JTAG-based Testing Flow

This directory contains the scripts for executing the steps of
the verification and testing flow using the JTAG-based Debug Unit of ESP.

* For a given ESP configuration and application, the first step consists in collecting
simulation traces from the tile-under-test/NoC boundary interface during the application
execution in RTL simulation (normal mode).
This can be done by launching the following make target from the design folder:

`JTAG_TEST_TILE=X TEST_PROGRAM=./soft-build/<cpu>/baremetal/<target_application>.exe  make jtag-trace`

where X is the number of the tile-under-test in the SoC configuration. Note that, if not specified,
`JTAG_TEST_TILE=0` and `TEST_PROGRAM=systest.exe`.

After compiling all of the source files, this target sets up the trace collection by executing the `jtag_test_gettrace.tcl` script. Once the simulation completes, it reformats the list into readable traces with the `jtag_test_format.sh` script. Finally, it generates the stimulus file for testing (`stim.txt`) by executing the script `jtag_test_stim.py`, saving it in `modelsim/jtag/`.

* After collecting the traces, to simulate the target tile the collected traces through the debug unit, launch the following target:

'JTAG_TEST_TILE=X make sim-jtag'

This sets the target tile in test-mode (TMS=1) and starts the simulation which reads the traces. During the simulation, the flits of the stimulus file `modelsim/jtag/stim.txt` are injected one by one into the target tile through the TDI signal, and the simulation responses are received by the testbench through the TDO signal and saved in the output `stimX_fin.txt` files, for each NoC plane `X`. The expected responses are saved in `stimX_orig.txt` for comparison.

* To test on FPGA, generate the bitstreams of the fpga-proxy and the emulated chip and deploy them on the dual-fpga setup. Then, launch the target

`STIM_FILE=<path_to_stim.txt> fpga-run-jtag`

This target writes the stimulus file flits from the stim.txt to the fpga-proxy through esplink. Before running this target, enable the debug unit with an esplink register write operation to the dedicated register for TMS (address=`20020000`) with data `1`.
