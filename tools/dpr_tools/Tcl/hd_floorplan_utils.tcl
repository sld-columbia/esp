#==============================================================
# TCL proc for find and translating top level "create_clock"
# constraints to module level constraints 
# This should be ran on a placed/routed design with
# "set_property dont_touch 1 [get_cells <cell>]" set on each
# instace of the OOC modules to prevent pin optimizations.
#==============================================================
proc create_ooc_clocks { cell hier_cell dir } {
   set_param tcl.statsThreshold -1
   set_msg_config -id "Vivado 12-1008" -suppress
   set_msg_config -id "Vivado 12-626" -suppress

   set xdcFile "$dir/${cell}_ooc_timing.xdc"
   if {[catch {file delete -force $xdcFile} errMSG] } {
      append errMsg "\nERROR: Could not delete \"$xdcFile\". Verify file is closed."
      error $errMsg
   }
   set fh [open "$xdcFile" w]
   puts "\tWriting XDC file \"$xdcFile\"."
   set in_pins [lsort [get_pins -of [get_cells $hier_cell] -filter DIRECTION==IN]]
   puts $fh "#---------------------------------------"
   puts $fh "# Create Clock Constraints - $hier_cell "
   puts $fh "#---------------------------------------"
   set portClocks ""
   foreach inpin $in_pins {
      set clocks [get_clocks -of [get_pins $inpin]]
      if {[llength $clocks] > 0} {
         foreach clock $clocks {
            set pin_split [split $inpin "/" ]
            set port [lindex $pin_split end]
            lappend portClocks $clock.$port 
            set period [get_property PERIOD [get_clocks $clock]]
            set wave [get_property WAVEFORM [get_clocks $clock]] 
            puts $fh "create_clock -period $period -name ${clock}.${port} \[get_ports \{$port\}] -waveform \{$wave\}"
         }
         if {[llength $clocks] ==2} {
            puts $fh "set_clock_groups -name $port -physically_exclusive -group \[get_clocks \{[lindex $portClocks end]\}] -group \[get_clocks \{[lindex $portClocks end-1]\}]"
         } 
         set clk_src [get_cells -quiet -of [get_pins -quiet -leaf -of [get_nets [get_pins $inpin]] -filter DIRECTION==OUT]]
         if {[llength $clk_src] == 1} {
            set clk_src_val [get_property LOC [get_cells $clk_src]]
            if {[llength $clk_src_val] == 1 && [get_property IS_LOC_FIXED [get_cells $clk_src]]} {
               puts $fh "set_property HD.CLK_SRC $clk_src_val \[get_ports \{$port\}]"
            } else {
               puts $fh "#WARNING: Clock Source for pin \"$inpin\" ($clk_src) is not locked. Add a location constraint to the XDC prior to running this command."
            }
         }
      }
   }
   set_msg_config -id "Timing 38-127" -suppress
   set_msg_config -id "Timing 38-164" -suppress
   set_msg_config -id "Vivado 12-975" -suppress
   set numClocks [llength $portClocks]
   puts "\tNumber of Clocks Found: $numClocks"
   puts $fh "set_system_jitter 0.0"
   puts "\tGetting Clock Uncertainty for inter-clock paths" 
   puts "\tCalculating Clock Latency for all Clocks" 
   foreach portClock $portClocks {
      set clockSplit [split $portClock "." ]
      set clock [lindex $clockSplit 0]
      set clockPath [get_timing_paths -from [get_clocks $clock] -to [get_clocks $clock]]
      if {[llength $clockPath] > 0} {
         set uncertainty [get_property -quiet UNCERTAINTY $clockPath]
         set startPinDelay [get_property -quiet STARTPOINT_CLOCK_DELAY $clockPath]
         set startPin [get_property -quiet STARTPOINT_PIN $clockPath]
         set endPin   [get_property -quiet ENDPOINT_PIN $clockPath]
         if {[string match [get_property CLASS $startPin] "pin"]} {
            set clkPin [get_pins -leaf -of [get_nets -of [get_pins $startPin]] -filter DIRECTION==OUT]
         } elseif {[string match [get_property CLASS $endPin] "pin"]} {
            set clkPin [get_pins -leaf -of [get_nets -of [get_pins $endPin]] -filter DIRECTION==OUT]
            set startPin $endPin
         } else {
            puts "info: No clock pins found in timing path"
            set clkPin ""
         }
         if {[llength $startPin] > 0 && [llength $clkPin] > 0} {
            set arcDelay_max [get_property DELAY_MAX_RISE [get_timing_arcs -from [get_pins $clkPin] -to [get_pins $startPin]]]
            set arcDelay_min [get_property DELAY_MIN_RISE [get_timing_arcs -from [get_pins $clkPin] -to [get_pins $startPin]]]
            #Subtract off minimum arcDelay from max Path delay to get maxInsertion... visa versa for minInsertion
            set maxInsertion [expr $startPinDelay - $arcDelay_min]
            set minInsertion [expr $startPinDelay - $arcDelay_max]
            puts $fh "set_clock_latency -source -max $maxInsertion \[get_clocks \{$portClock\}]" 
            puts $fh "set_clock_latency -source -min $minInsertion \[get_clocks \{$portClock\}]" 
			   puts $fh "set_clock_uncertainty $uncertainty \[get_clocks \{$portClock\}]"
		   }
      }
   }

   #Generate Clock Uncertainty and asynchronous clock constraints
   #Loop through clocks efficiently to avoid duplicate constraints being generated
   puts "\tGetting Clock Uncertainty for intra-clock paths" 
   for {set i 0} {$i < [expr $numClocks-1]} {incr i} {
      set portClock1 [lindex $portClocks $i]
      set clockSplit [split $portClock1 "." ]
      set clock1 [lindex $clockSplit 0]
      for {set j [expr $i+1]} {$j < $numClocks} {incr j} {
         set portClock2 [lindex $portClocks $j]
         set clock_split [split $portClock2 "." ]
         set clock2 [lindex $clock_split 0]
         set clkPath1 [get_timing_paths -from [get_clocks $clock1] -to [get_clocks $clock2]]
         set clkPath2 [get_timing_paths -from [get_clocks $clock2] -to [get_clocks $clock1]]
         if {[llength $clkPath1] > 0 || [llength $clkPath2] > 0 } {
            if {[get_property -quiet SLACK $clkPath1] == "" && [get_property -quiet SLACK $clkPath2] == ""} {
               puts $fh "set_clock_groups -asynchronous -group \[get_clocks \{$portClock1\}] -group \[get_clocks \{$portClock2\}]"
            } 
            if {[get_property -quiet SLACK $clkPath1] != ""} { 
               puts $fh "set_clock_uncertainty -from \[get_clocks \{$portClock1\}] -to \[get_clocks \{$portClock2\}] [get_property -quiet UNCERTAINTY $clkPath1]"
            }
            if {[get_property -quiet SLACK $clkPath2] != ""} { 
               puts $fh "set_clock_uncertainty -from \[get_clocks \{$portClock2\}] -to \[get_clocks \{$portClock1\}] [get_property -quiet UNCERTAINTY $clkPath2]"
            }
         }
      }
   }
      
   puts "\t#HD: create_ooc_clocks completed successfully\n"
   reset_msg_config -quiet -id "Timing 38-127" -suppress
   reset_msg_config -quiet -id "Timing 38-164" -suppress
   reset_msg_config -quiet -id "Vivado 12-975" -suppress
   reset_msg_config -quiet -id "Vivado 12-1008" -suppress
   reset_msg_config -quiet -id "Vivado 12-626" -suppress
   reset_param tcl.statsThreshold
   close $fh
}

#==============================================================
# Not used!! TCL proc for finding the average delay of clocks
# to be used for latency. 
# Using Max and Min was too pessamistic. Rewrite to just use
# Setup/Max paths, and set one latency value (no -min/-max)
#==============================================================
proc average_clock_delay {} {
   #Generate Clock Latency Constraints based on average 
   puts "\tCalculating Average Clock Latency for all Clocks" 
   set maxPaths 10000
   foreach portClock1 $portClocks {
      set totalClock1Delay_max 0
      set totalClock1Delay_min 0
      set clockSplit [split $portClock1 "." ]
      set clock1 [lindex $clockSplit 0]
      set setupPathCount 0
      set holdPathCount 0
      foreach portClock2 $portClocks {
         set clock_split [split $portClock2 "." ]
         set clock2 [lindex $clock_split 0]
         set clockPaths_setup [get_timing_paths -from [get_clocks $clock1] -to [get_clocks $clock2] -max_paths $maxPaths]
         set clockPaths_hold  [get_timing_paths -from [get_clocks $clock1] -to [get_clocks $clock2] -max_paths $maxPaths -hold]
         if {[llength $clockPaths_setup] > 0} {
            foreach setup $clockPaths_setup {
               incr setupPathCount
               set startDelay_max [get_property -quiet STARTPOINT_CLOCK_DELAY $setup]
               set totalClock1Delay_max [expr ($totalClock1Delay_max + $startDelay_max)]
            }
         }
         if {[llength $clockPaths_hold] > 0} {
            foreach hold $clockPaths_hold {
               incr holdPathCount
               set startDelay_min [get_property -quiet STARTPOINT_CLOCK_DELAY $hold]
               set totalClock1Delay_min [expr ($totalClock1Delay_min + $startDelay_min)]
            }
         }
      }
      if {[llength $clockPaths_setup] > 0} {
         set averageClock1Delay_max [expr {double(round(100*$totalClock1Delay_max / $setupPathCount))/100}]
         puts "\tClock: $portClock1, \n\t\tTotal Setup Clock Delay: $totalClock1Delay_max, \n\t\tTotal Number of Paths: $setupPathCount, \n\t\tAverage Clock Delay: $averageClock1Delay_max"
         puts $fh "set_clock_latency -source -max $averageClock1Delay_max \[get_clocks \{$portClock1\}]" 
      }
      if {[llength $clockPaths_hold] > 0} {
         set averageClock1Delay_min [expr {double(round(100*$totalClock1Delay_min / $holdPathCount))/100}]
         puts "\tClock: $portClock1, \n\t\tTotal Hold Clock Delay: $totalClock1Delay_min, \n\t\tTotal Number of Paths: $holdPathCount, \n\t\tAverage Clock Delay: $averageClock1Delay_min"
         puts $fh "set_clock_latency -source -min $averageClock1Delay_min \[get_clocks \{$portClock1\}]" 
      }
   }
}
#==============================================================
# TCL proc for creating set_logic constraints 
# Finds all inputs tied to Vcc/Gnd, and all unconnected outputs
#==============================================================
proc create_set_logic { name hier_cell dir {cell 1}} {
   set_msg_config -id "Vivado 12-1023" -suppress
   set_msg_config -id "Vivado 12-584" -suppress

   if {$cell} {
      set xdcFile "$dir/${name}_ooc_optimize.xdc"
   } else {
      set xdcFile "$dir/${name}_optimize.xdc"
   }
   
   if {[catch {file delete -force $xdcFile} errMsg] } {
      append errMsg "\nERROR: Could not delete \"$xdcFile\". Verify file is closed."
      error $errMsg
   }
   set fh [open "$xdcFile" w]
   puts "\tWriting XDC file \"$xdcFile\"."
   set in_pins [lsort [get_pins -of [get_cells $hier_cell] -filter DIRECTION==IN]]
   set out_pins [lsort [get_pins -of [get_cells $hier_cell] -filter DIRECTION==OUT]]
   #set inout_pins [lsort [get_pins -of [get_cells $hier_cell] -filter DIRECTION==INOUT]]
   foreach inpin $in_pins {
      set pin_split [concat {*}[split $inpin "/"]]
      set port [lindex $pin_split end]
      set net [get_nets -of [get_pins $inpin]]
      if {[llength $net]==0} {
         #for input pins with no driver. Should be tied to Vcc or Gnd in netlist design.
         puts "\tWARNING: Found unconnected input pin \"$inpin\". If this script is being run on an optimzed (implemented) version of the design, pleaes close the current design and rerun on the synthesized netlist design (pre-implementation)."
      } else {
         set type [get_property TYPE [get_nets $net]]
         if {[string match -nocase $type "POWER"]} {
            #for inputs tied to Vcc
            if {$cell} {
               puts $fh "set_logic_one \[get_ports \{$port\}]"
            } else {
               puts $fh "set_logic_one \[get_pins \{$inpin\}]"
            }
         } elseif {[string match -nocase $type "GROUND"]} {
            #for input tied to Ground
            if {$cell} {
               puts $fh "set_logic_zero \[get_ports \{$port\}]"
            } else {
               puts $fh "set_logic_zero \[get_pins \{$inpin\}]"
            }
         }
      }
   }

   foreach outpin $out_pins {
      set pin_split [concat {*}[split $outpin "/"]]
      set port [lindex $pin_split end]
      set net [get_nets -of [get_pins $outpin]]
      if {[llength $net]==0} {
         #for output with no nets
         if {$cell} {
            puts $fh "set_logic_unconnected \[get_ports \{$port\}]"
         } else {
            puts $fh "set_logic_unconnected \[get_pins \{$outpin\}]"
         }
      } else {
         set pin_count [get_property FLAT_PIN_COUNT [get_nets $net]]
         set io_port   [get_ports -of [get_nets $net]]
         set type      [get_property TYPE [get_nets $net]]
         if {[llength $io_port] == 0 && $pin_count <= 1} {
            #for output with dangling nets
            if {$cell} {
               puts $fh "set_logic_unconnected \[get_ports \{$port\}]"
            } else {
               puts $fh "set_logic_unconnected \[get_pins \{$outpin\}]"
            }
         } elseif {[string match -nocase $type "POWER"]} {
            #for outputs tied to Vcc
            if {$cell} {
              # puts $fh "set_logic_one \[get_ports $port]"
            } else {
              # puts $fh "set_logic_one \[get_pins $outpin]"
            }
         } elseif {[string match -nocase $type "GROUND"]} {
            #for output tied to Ground
            if {$cell} {
             #  puts $fh "set_logic_zero \[get_ports $port]"
            } else {
             #  puts $fh "set_logic_zero \[get_pins $outpin]"
            }
         }
      }
   }
   reset_msg_config -quiet -id "Vivado 12-584" -suppress
   reset_msg_config -quiet -id "Vivado 12-1023" -suppress
   close $fh
}

#==============================================================
# TCL proc to write out HD.PARTPIN_LOCS constraitns from an  
# in-context (flat) implemenation. 
#==============================================================
proc write_hd_xdc {inst hierInst dir} {
   reset_property HD.PARTPIN_RANGE [get_pins $hierInst/* -filter "HD.ASSIGNED_PPLOCS=~*INT*"]
   set_property HD.LOC_FIXED 1 [get_pins $hierInst/*]
   set file "${dir}/${inst}_phys.xdc"
   if {[file exists $file]} {
      file delete -force $file
   }
   puts "\tWriting XDC file \"$file\"."
   write_xdc -force -cell $hierInst $file

   set file "${dir}/${inst}_ooc_budget.xdc"
   if {[file exists $file]} {
      file delete -force $file
   }
   puts "\tWriting XDC file \"$file\"."
   ::debug::gen_hd_timing_constraints -percent 50 -of [get_cells $hierInst] -file $file
}

#==============================================================
# TCL proc to highlight PartPin locations.
#==============================================================
proc highlight_partpins { cell index } {
   highlight_objects -color_index $index [get_pins $cell/*] 
}

#==============================================================
# TCL proc to call all others.  Used in TopDown GUI flow. 
# Select all instances of HD modules and call this proc:
# hd_floorplan [get_selected_objects]
#==============================================================
proc hd_floorplan {cells} {
   set relativeDir "Sources/xdc"
   set projectDir "[get_property DIRECTORY [current_project]]"
   set outputDir "${projectDir}/../../${relativeDir}"

   #If no design is open
   #if { [catch {current_instance}] || [string match "netlist_1" [get_property NAME [current_design]]]==0 } {}
#   if { [catch {current_instance}] } {
#      puts "ERROR: No open design... Opened the Synthesized Design prior to running this command."
#      return
#   }

   #Make sure cells are passed into proc
   if {![llength $cells]} {
      puts "ERROR: No cells specified for command hd_floorplan."
      return
   }
   
   puts "Processing cells: $cells"
   set cell_list ""
   set cell_count 0
   foreach cell $cells {
      set cell_split [concat {*}[split $cell "/"]]
      set cell_name [lindex $cell_split end]
      incr cell_count
      #If local cell name is the same for multiple instances, append a unique value
      #This is to prevent output files from having the same name and overwriting
      if {[lsearch -exact $cell_list $cell_name] >= 0} {
         lappend cell_list $cell_name
         set cell_name ${cell_name}_${cell_count}
      } else {
         lappend cell_list $cell_name
      }
      set_property HD.PARTITION 1 [get_cells $cell]
      create_set_logic $cell_name $cell $outputDir
      create_ooc_clocks $cell_name $cell $outputDir
   }

   opt_design
   place_design
   
   set color 1
   set cell_list ""
   set cell_count 0
   foreach cell $cells {
      set cell_split [concat {*}[split $cell "/"]]
      set cell_name [lindex $cell_split end]
      incr cell_count
      #If local cell name is the same for multiple instances, append a unique value
      #This is to prevent output files from having the same name and overwriting
      if {[lsearch -exact $cell_list $cell_name] >= 0} {
         lappend cell_list $cell_name
         set cell_name ${cell_name}_${cell_count}
      } else {
         lappend cell_list $cell_name
      }
      write_hd_xdc $cell_name $cell $outputDir
      highlight_partpins $cell $color
      incr color
   }
   write_checkpoint -force $projectDir/TopDown_place_design.dcp
}
