*************************************************************************
     
 © Copyright 2023 Advanced Micro Devices, Inc. All rights reserved.
 This file contains confidential and proprietary information of 
 Advanced Micro Devices, Inc. and is protected under U.S. and 
 international copyright and other intellectual property laws. 
 
*************************************************************************

Vendor: AMD 
Current readme.txt Version: 2.0
Date Last Modified:  19OCT2023
Date Created: 17APR2020

Associated Filename: ug947-vivado-partial-reconfiguration-tutorial.zip
Associated Document: UG947, Vivado Design Suite Tutorial: Dynamic Function eXchange

Supported Device(s): All AMD FPGAs and SoCs
   
*************************************************************************

Disclaimer: 

      This disclaimer is not a license and does not grant any rights to 
      the materials distributed herewith. Except as otherwise provided in 
      a valid license issued to you by Xilinx, and to the maximum extent 
      permitted by applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE 
      "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL 
      WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
      INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, 
      NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
      (2) Xilinx shall not be liable (whether in contract or tort, 
      including negligence, or under any other theory of liability) for 
      any loss or damage of any kind or nature related to, arising under 
      or in connection with these materials, including for any direct, or 
      any indirect, special, incidental, or consequential loss or damage 
      (including loss of data, profits, goodwill, or any type of loss or 
      damage suffered as a result of any action brought by a third party) 
      even if such damage or loss was reasonably foreseeable or Xilinx 
      had been advised of the possibility of the same.

Critical Applications:

      Xilinx products are not designed or intended to be fail-safe, or 
      for use in any application requiring fail-safe performance, such as 
      life-support or safety devices or systems, Class III medical 
      devices, nuclear facilities, applications related to the deployment 
      of airbags, or any other applications that could lead to death, 
      personal injury, or severe property or environmental damage 
      (individually and collectively, "Critical Applications"). Customer 
      assumes the sole risk and liability of any use of Xilinx products 
      in Critical Applications, subject only to applicable laws and 
      regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS 
FILE AT ALL TIMES.

#################################################################
Script Version: Must use Vivado 2020.1 or newer

 The scripts are designed so that only a single file (i.e. run_dfx.tcl) 
 needs to be defined/modified for any design. This file is used to 
 describe the various synthesis (modules) and implementation runs
 for a given design. 
#################################################################
 +design.tcl - The following commands are used to define a design using this file.

   - add_module              -> Defines the top-level of lower-level module to be run with bottom-up 
                                synthesis. Various module attibutes (listed below) can be defined or
                                obtained using set_attribute/get_attribute, respectively.

   - add_implementation      -> Used to define an implementation to run a design flat, to assemble an OOC 
                                design (Module Reuse) or to generate constraints for an OOC implementation
                                (TopDown). Various implementation attibutes (listed below) can be defined 
                                or obtained using set_attribute or get_attribute, respectively.

   - set_attribute           -> Used to define attributes for each module or implementation that gets defined.
                                Only attributes that need values other than the defaults need to be defined. A
                                list of valid attributes and the default values can be found in design_utils.tcl.
                                  
 + Valid Module Attributes
    - "moduleName"                  -> Defines the actual module name. Default is value specified for add_module. 
    - "top_level"                   -> Specify if the module is the top-level of the design
    - "prj"                         -> Specify location of PRJ file (If defined, sysvlog, vlog, and vhdl attribuges are ignored)
    - "includes"                    -> Specify include files
    - "generics"                    -> Specify values of generics
    - "vlog_headers"                -> Specify Verilog header files
    - "vlog_defines"                -> Specify Verilog defines
    - "sysvlog"                     -> Specify System Verilog files
    - "vlog"                        -> Specify Verilog files
    - "vhdl"                        -> Specify VHDL files
    - "ip"                          -> Specify Vivado IP (XCI) files that need to be genenated
    - "ipRepo"                      -> Specify IP Repositories needed by the design
    - "bd"                          -> Specify Vivado IPI (BD) systems that need to be genenated
    - "cores"                       -> Specify synthesized IP cores (NGC, EDN, EDF)
    - "xdc"                         -> Specify module XDC file to be used for Synthesis and Implementation
    - "synthXDC"                    -> Specify module XDC file to be used for Synthesis only
    - "implXDC"                     -> Specify module XDC file to be used for implementation only
    - "synth"                       -> Specify if synthesis should be run on the module 
    - "synth_options"               -> Specify synthesis options for the module
    - "synthCheckpoint"             -> Specify location of post-synth_design checkpoint if outside expected locations

 + Valid Implementation Attributes
    - "top"                         -> Specify the top module name of implementation
    - "implXDC"                     -> Specify the top XDC files. Only get read when Top/Static is implemented.
    - "cellXDC"                     -> Specify cell specific XDC (eg. BRAM LOCs). Different than Module "implXDC" (not applied to all instances)
    - "cores"                       -> Specify any synthesized IP cores not already in the netlist (NGC, EDF, EDN)
    - "hd.impl"                     -> Specify if the implementation run has OOC modules to import
    - "td.impl"                     -> Specify if the implementation run is a TopDown run to generate OOC constraints
    - "dfx.impl"                    -> Specify if the implementation run uses Dynamic Function eXchange
    - "impl"                        -> Specify if implementation should be run (Default is 0)
    - "link"                        -> Specify if link_design should be run (Default is 1)
    - "opt"                         -> Specify if opt_design should be run (Default is 1)
    - "opt.pre"                     -> Specify script to run prior to opt_design
    - "opt_options"                 -> Specify opt_design options
    - "opt_directive"               -> Specify opt_design directive
    - "place"                       -> Specify if place_design should be run (Default is 1)
    - "place.pre"                   -> Specify script to run prior to place_design
    - "place_options"               -> Specify place_desig options
    - "place_directive"             -> Specify place_design directive
    - "phys"                        -> Specify if phys_opt_design should be run (Default is 1)
    - "phys.pre"                    -> Specify script to run prior to phys_opt_design
    - "phys_options"                -> Specify phys_opt_design options
    - "phys_directive"              -> Specify phys_opt_design directive
    - "route"                       -> Specify if route_design should be run (Default is 1)
    - "route.pre"                   -> Specify script to run prior to route_design
    - "route_options"               -> Specify route_design options
    - "route_directive"             -> Specify route_design directive
    - "bitstream"                   -> Specify if write_bitstream should be run (Default is 0)
    - "bitstream.pre"               -> Specify script to run prior to write_bitstream
    - "bitstream_options"           -> Specify write_bitstream options
    - "bitstream_settings"          -> Specify configuration bitstream settings (UG908 - Table A-1)
    - "partial_bitstream_options"   -> Specify write_bitstream options specific to partial bitfiles
    - "partial_bitstream_settings"  -> Specify additional configuration bitstream settings for partial bit files

#################################################################
 The following section define information about the additional 
 Tcl scripts provided in the "./Tcl_HD" directory
#################################################################
+ design_utils.tcl - Defines the following procs used by design.tcl
    - add_module
    - add_implementation
    - set_attribute
    - get_attribute
    - check_attribute
    - check_attribute_value
    - check_list
    - set_directives
    - sort_configurations
    - set_paramaters

+ hd_utils.tcl - Defines the following procs used to generate OOC constraints
    - get_partitions
    - get_bb (blackbox)
    - bb (blackbox)
    - gb (greybox)
    - create_partition_budget
    - export_pblocks

+ dfx_utils.tcl - Defines the following procs used to generate OOC constraints
    - get_rps
    - toggle_dfx
    - get_pp_range
    - export_partpins
    - convert_pblocks

+ synth_utils.tcl - Defines the following procs used for synthesis flows
    - add_prj
    - add_ip
    - add_sysvlog
    - add_vlog
    - add_vhdl
    - add_bd

+ impl_utils.tcl - Defines the following procs used for implementation flows
    - get_module_file
    - generate_dfx_binfiles
    - generate_dfx_bitstreams
    - verify_configs
    - add_xdc
    - readXDC
    - add_ip
    - add_cores
    - check_drc

+ eco_utils.tcl - Not currently used by any flow, provides a couple quick examples of how to edit the in-memory design to add or delete cells.  
    - insert_ibuf
    - insert_clock_buffer
    - remover_buffer
    - swap_clock_buffers
    - insert_flop
    - split_BUFG_GT_load 

+ log_utils.tcl - Defined the following procs used for logging the commands, critical messages, and results
    - log_time
    - command
    - parse_log
    - getTimingInfo 
    - read_file_lines
    - print_table

+ run.tcl        - Called from design.tcl; controls the flows that are run
+ synthesize.tcl - Proc used to run all synthesis runs
+ implement.tcl  - Proc used to run Dynamic Function eXchange, HD-Platform, or Flat implementations
+ step.tcl       - Proc used to call each step of implementation

