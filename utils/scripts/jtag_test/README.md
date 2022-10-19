# JTAG-based Testing Flow

This directory contains the scripts for executing the steps of
the verification and testing flow using the JTAG-based Debug Unit of ESP.

* For a given ESP configuration and application, the first step consists in collecting
signature traces from the tile-under-test/NoC boundary interface during the application
execution in RTL simulation (normal mode).
This can be done by launching the following make target from the design folder:

`JTAG_TEST_TILE=X TEST_PROGRAM=./soft-build/<cpu>/baremetal/<target_application.exe>  make jtag-trace`

where X is the number of the tile-under-test in the SoC configuration. Note that, if not specified,
`JTAG_TEST_TILE=0` and `TEST_PROGRAM=systest.exe`.

After compiling all the source files, this target sets up the traces collection executing the `jtag_test_gettrace.tcl` script. Once completed the simulation, it reformats the list into readable traces with the `jtag_test_format.sh` script. Finally, it generates the final stimulus file (stim.txt) ready for testing by executing the script `jtag_test_stim.py`, saving it in `modelsim/jtag/`.

* After collecting the traces, to simulate the Debug Unit RTL with the collected traces, launch the following target:

'JTAG_TEST_TILE=X make sim-jtag'

This sets the target tile in test-mode (TMS=1) and starts the simulation which reads the traces. During the simulation, the flits of the stimulus file `modelsim/jtag/stim.txt` are injected one by one into the target tile through the TDI signal, and the simulation responses are received by the testbench through the TDO signal and finally saved in the output `stimX_fin.txt` files, for each NoC plane `X`.

* To test on FPGA, generate the bitstreams of the fpga-proxy and the emulated chip and deploy them on the dual-fpga setup. At that point launch the target

`STIM_FILE=<path_to_stim.txt> fpga-run-jtag`

This target write the stimulus file flits from the stim.txt to the fpga-proxy through esplink. You can then start the test by setting the TMS to 1 with an esplink write-register operation pointing to the dedicated register for TMS (address=`20020000`).
