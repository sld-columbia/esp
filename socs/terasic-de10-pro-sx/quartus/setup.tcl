set script_dir [file normalize [file dirname [info script]]]
set project_name "DE10_Pro_GHRD"
set revision_name "DE10_Pro_GHRD"
set opened_project 0
set srcs_auto [file join $script_dir "srcs_auto.tcl"]

if {![file exists $srcs_auto]} {
    error "srcs_auto.tcl not found. Run 'make quartus-srcs' from ../ before sourcing setup.tcl."
}

if {![is_project_open]} {
    project_open -revision $revision_name [file join $script_dir $project_name]
    set opened_project 1
}

set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2009

foreach assignment_name {SEARCH_PATH VHDL_FILE VERILOG_FILE SYSTEMVERILOG_FILE VERILOG_MACRO} {
    catch {remove_all_global_assignments -name $assignment_name}
}

# Ariane's Linux-capable FPGA configuration uses the write-through data cache.
# Keep Quartus aligned with the Vivado, ModelSim, and Xcelium flows.
set_global_assignment -name VERILOG_MACRO "WT_DCACHE=1"

# Ariane's FPGA SRAM wrappers default to the Xilinx inference template unless
# the Intel FPGA target is explicit.
set_global_assignment -name VERILOG_MACRO "FPGA_TARGET_ALTERA=1"

# The cache RTL uses XILINX_FPGA as its FPGA-local-memory compatibility switch.
# This project supplies Stratix 10 implementations of the expected BRAM modules.
set_global_assignment -name VERILOG_MACRO "XILINX_FPGA=1"

# NVDLA uses its own FPGA target define to bypass ASIC clock/power gating and
# select FPGA-safe FIFO/RAM behavior.
set_global_assignment -name VERILOG_MACRO "NVDLA_FPGA_TARGET=1"

set old_dir [pwd]
cd $script_dir
source $srcs_auto
cd $old_dir
export_assignments

if {$opened_project} {
    project_close
}
