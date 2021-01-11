create_project esp-xilinx-zcu102-xczu9eg -part xczu9eg-ffvb1156-2-e -force
set_property target_language verilog [current_project]
set_property include_dirs {/home/jescobedo/repos/juanesp/rtl/cores/ariane/ariane/src/common_cells/include /home/jescobedo/repos/juanesp/socs/xilinx-zcu102-xczu9eg /home/jescobedo/repos/juanesp/socs/xilinx-zcu102-xczu9eg/socgen/grlib /home/jescobedo/repos/juanesp/socs/xilinx-zcu102-xczu9eg/socgen/esp  /home/jescobedo/repos/juanesp/accelerators/third-party/NV_NVDLA/vlog_incdir /home/jescobedo/repos/juanesp/rtl/caches/esp-caches/common/defs} [get_filesets {sim_1 sources_1}]
set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1} [get_filesets {sim_1 sources_1}]
source ./srcs.tcl
set_property board_part xilinx.com:zcu102:part0:3.3 [current_project]
set argv [list 64]
set argv [list 64]
set argc 1
source ./zynq/zynq.tcl
unset argv
set argc 0
read_xdc /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg.xdc
set_property used_in_synthesis true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg.xdc]
set_property used_in_implementation true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg.xdc]
read_xdc /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-mig-pins.xdc
set_property used_in_synthesis true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-mig-pins.xdc]
set_property used_in_implementation true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-mig-pins.xdc]
read_xdc /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-mig-constraints.xdc
set_property used_in_synthesis true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-mig-constraints.xdc]
set_property used_in_implementation true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-mig-constraints.xdc]
read_xdc /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-eth-pins.xdc
set_property used_in_synthesis true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-eth-pins.xdc]
set_property used_in_implementation true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-eth-pins.xdc]
read_xdc /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-dvi-pins.xdc
set_property used_in_synthesis true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-dvi-pins.xdc]
set_property used_in_implementation true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-dvi-pins.xdc]
read_xdc /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-eth-constraints.xdc
set_property used_in_synthesis true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-eth-constraints.xdc]
set_property used_in_implementation true [get_files /home/jescobedo/repos/juanesp/constraints/xilinx-zcu102-xczu9eg/xilinx-zcu102-xczu9eg-eth-constraints.xdc]
set_property top zynqmp_top_wrapper [current_fileset]
