# Environment variable settings
global env
set CATAPULT_HOME "/opt/Catapult_2024.2/Mgc_home"
## Set the variable for file path prefixing 
set RTL_TOOL_SCRIPT_DIR /home/gtombesi/catapult_update_april24/esp/accelerators/catapult_hls/macfin2_sysc_catapult/hw/hls/DataPath/Catapult/DataPath.v1/vivado_concat_v
set RTL_TOOL_SCRIPT_DIR [file dirname [file normalize [info script] ] ]
puts "-- RTL_TOOL_SCRIPT_DIR is set to '$RTL_TOOL_SCRIPT_DIR' "
# Vivado Non-Project mode script starts here
puts "==========================================="
puts "Catapult driving Vivado in Non-Project mode"
puts "==========================================="
set outputDir /home/gtombesi/catapult_update_april24/esp/accelerators/catapult_hls/macfin2_sysc_catapult/hw/hls/DataPath/Catapult/DataPath.v1/vivado_concat_v
set outputDir $RTL_TOOL_SCRIPT_DIR
create_project -force ip_tcl_concat_v
   read_verilog ../concat_DataPath.v
# set up XPM libraries for XPM-related IP like the Catapult Xilinx_FIFO
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY XPM_FIFO} [current_project]
read_xdc $outputDir/concat_DataPath.v.xv.sdc
set_property part xc7vx485tffg1761-2 [current_project]
