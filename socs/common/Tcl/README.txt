Script Version: 2014.1
+ design.tcl
    The scripts are designed so that this is the only file that should need to be modified.
    This file is used to describe the various synthesis (modules) and implementation runs
    for a given design. The following commands are used to define the design in this file.

    - add_module              -> Defines the top-level of lower-level module to be run with bottom-up 
                                 synthesis. Various module attibutes (listed below) can be defined or
                                 obtained using set_attribute/get_attribute, respectively.

    - add_ooc_implemmentation -> Used to define an out-of-context implementation run. Various implementation
                                 attibutes (listed below) can be defined or obtained using set_attribute
                                 or get_attribute, respectively.
                                             
    - add_implementation      -> Used to define an implementation to run a design flat, to assemble an OOC 
                                 design (Module Reuse) or to generate constraints for an OOC implementation
                                 (TopDown). Various implementation attibutes (listed below) can be defined 
                                 or obtained using set_attribute or get_attribute, respectively.
                                  
+ Valid Module Attributes
    - "moduleName"          -> Defines the actual module name. Default is value specified for add_module. 
    - "top_level"           -> Specify if the module is the top-level of the design
    - "prj"                 -> Specify location of PRJ file (If defined, sysvlog, vlog, and vhdl attribuges are ignored)
    - "includes"            -> Specify include files
    - "generics"            -> Specify values of generics
    - "vlog_headers"        -> Specify Verilog header files
    - "vlog_defines"        -> Specify Verilog defines
    - "sysvlog"             -> Specify System Verilog files
    - "vlog"                -> Specify Verilog files
    - "vhdl"                -> Specify VHDL files
    - "ip"                  -> Specify Vivado IP (XCI) files that need to be genenated
    - "ipRepo"              -> Specify IP Repositories needed by the design
    - "bd"                  -> Specify Vivado IPI (BD) systems that need to be genenated
    - "cores"               -> Specify synthesized IP cores (NGC, EDN, EDF)
    - "xdc"                 -> Specify module XDC file to be used for Synthesis and Implementation
    - "synthXDC"            -> Specify module XDC file to be used for Synthesis only
    - "implXDC"             -> Specify module XDC file to be used for implementation only
    - "synth"               -> Specify if synthesis should be run on the module 
    - "synth_options"       -> Specify synthesis options for the module
    - "synthCheckpoint"     -> Specify location of post-synth_design checkpoint if outside expected locations

+ Valid OOC Implementation Attributes
    - "module"              -> Specify the module name of OOC implementation
    - "inst"                -> Specify the non-hierarchical cell name of the OOC module (eg U1)
    - "hierInst"            -> Specify the hierachical cell name of the OOC module (eg U0/U1)
    - "implXDC"             -> Specify the OOC XDC files. Name any XDC files that are to be used in the OOC
                               run only as "*ooc*.xdc" so the scripts will mark it as USED_IN OOC.
    - "cores"               -> Specify any synthesized IP cores not already in the netlist (NGC, EDF, EDN)
    - "impl"                -> Specify if implementation should be run (Default is 0)
    - "hd.isolated          -> Specify if the OOC module is using the ISOLATION flow
    - "budget.create        -> Specify if interface budget constraints should be created. Default is 0. 
    - "budget.percent       -> Specify percent of clock to be used for interface budget constraints. Default is 50. 
    - "link"                -> Specify if link_design should be run (Default is 1)
    - "opt"                 -> Specify if opt_design should be run (Default is 1)
    - "opt.pre"             -> Specify script to run prior to opt_design
    - "opt_options"         -> Specify opt_design options
    - "opt_directive"       -> Specify opt_design directive
    - "place"               -> Specify if place_design should be run (Default is 1)
    - "place.pre"           -> Specify script to run prior to place_design
    - "place_options"       -> Specify place_desig options
    - "place_directive"     -> Specify place_design directive
    - "phys"                -> Specify if phys_opt_design should be run (Default is 1)
    - "phys.pre"            -> Specify script to run prior to phys_opt_design
    - "phys_options"        -> Specify phys_opt_design options
    - "phys_directive"      -> Specify phys_opt_design directive
    - "route"               -> Specify if route_design should be run (Default is 1)
    - "route.pre"           -> Specify script to run prior to route_design
    - "route_options"       -> Specify route_design options
    - "route_directive"     -> Specify route_design directive
    - "bitstream"           -> Specify if write_bitstream should be run (Default is 0)
    - "bitstream.pre"       -> Specify script to run prior to write_bitstream
    - "bitstream_options"   -> Specify write_bitstream options
    - "bitstream_settings"  -> Specify configuration bitstream settings (UG908 - Table A-1)
    - "implCheckpoint"      -> Specify location of post-route_design checkpoint (Default is $dcpDir)
    - "preservation"        -> Specify the preservation level of DCP when imported (Default is routing)

+ Valid Implementation Attributes
    - "top"                 -> Specify the top module name of implementation
    - "implXDC"             -> Specify the top XDC files.
    - "linkXDC"             -> Specify XDC files that must be read in post module importing.
    - "cores"               -> Specify any synthesized IP cores not already in the netlist (NGC, EDF, EDN)
    - "hd.impl"             -> Specify if the implementation run has OOC modules to import
    - "td.impl"             -> Specify if the implementation run is a TopDown run to generate OOC constraints
    - "pr.impl"             -> Specify if the implementation run uses Partial Reconfiguration
    - "impl"                -> Specify if implementation should be run (Default is 0)
    - "link"                -> Specify if link_design should be run (Default is 1)
    - "opt"                 -> Specify if opt_design should be run (Default is 1)
    - "opt.pre"             -> Specify script to run prior to opt_design
    - "opt_options"         -> Specify opt_design options
    - "opt_directive"       -> Specify opt_design directive
    - "place"               -> Specify if place_design should be run (Default is 1)
    - "place.pre"           -> Specify script to run prior to place_design
    - "place_options"       -> Specify place_desig options
    - "place_directive"     -> Specify place_design directive
    - "phys"                -> Specify if phys_opt_design should be run (Default is 1)
    - "phys.pre"            -> Specify script to run prior to phys_opt_design
    - "phys_options"        -> Specify phys_opt_design options
    - "phys_directive"      -> Specify phys_opt_design directive
    - "route"               -> Specify if route_design should be run (Default is 1)
    - "route.pre"           -> Specify script to run prior to route_design
    - "route_options"       -> Specify route_design options
    - "route_directive"     -> Specify route_design directive
    - "bitstream"           -> Specify if write_bitstream should be run (Default is 0)
    - "bitstream.pre"       -> Specify script to run prior to write_bitstream
    - "bitstream_options"   -> Specify write_bitstream options
    - "bitstream_settings"  -> Specify configuration bitstream settings (UG908 - Table A-1)

#################################################################
  The following section define information about the additional 
  Tcl scripts provided in the "./Tcl" directory
#################################################################
+ design_utils.tcl - Defines the following procs used by design.tcl
    - add_module
    - add_ooc_implementation
    - add_implementation
    - add_configuration
    - set_attribute
    - get_attribute
    - check_attribute
    - check_attribute_value
    - check_list
    - set_directives
    - sort_configurations
    - set_paramaters

+ hd_floorplan_utils.tcl - Defines the following procs used to generate OOC constraints
    - create_ooc_clock
    - create_set_logic
    - write_hd_xdc
    - highlight_partpins
    - hd_floorplan

+ synth_utils.tcl - Defines the following procs used for synthesis flows
    - add_prj
    - add_ip
    - add_sysvlog
    - add_vlog
    - add_vhdl
    - add_bd

+ impl_utils.tcl - Defines the following procs used for implementation flows
    - get_module_file
    - get_ooc_results
    - generate_pr_bitstreams
    - verify_configs
    - add_xdc
    - readXDC
    - add_cores
    - report_final_drc
    - get_bad_pins
    - get_bad_ports
    - insert_proxy_flop

+ eco_utils.tcl - Not currently used by any flow, provides a couple quick examples of how to edit the in-memory design to add or delete cells.  
    - insert_global_buffer
    - remover_buffer
    - replace_iobuf_bibuf
    - swap_clock_buffers

    - log_time

+ log_utils.tcl - Defined the following procs used for logging the commands, critical messages, and results
    - log_time
    - log_data
    - command
    - parse_log
    - print_table

+ run.tcl        - Called from design.tcl; controls the flows that are run
+ synthesize.tcl - Proc used to run all synthesis runs
+ ooc_impl.tcl   - Proc used to run OOC implementations
+ implement.tcl  - Proc used to run Partial Reconfiguration, TopDown, Assembly, or Flat implementations
+ step.tcl       - Proc used to call each step of implementation

