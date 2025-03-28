#==============================================================
# TCL proc for getting a list of cells marked with HD.PARTITION
#==============================================================
proc get_partitions {} {
   if {[catch current_instance]} {
      puts "INFO: No open design."
      return
   }
   set partitions [get_cells -quiet -hier -filter HD.PARTITION]
   if {![llength $partitions]} {
      puts "Info: No cells found with HD.PARTITION==1"
      return
   }
   return $partitions
}

#==============================================================
# TCL proc for getting a list of blackbox cells 
#==============================================================
proc get_bb {} {
   if {[catch current_instance]} {
      puts "INFO: No open design."
      return
   }
   set bb [get_cells -quiet -hier -filter IS_BLACKBOX]
   if {![llength $bb]} {
      puts "Info: No blackbox cells found"
      return
   }
   return $bb
}

#==============================================================
# TCL proc for carving out (black_box) cells: 
#   ex. 'bb [get_partitions]' 
#==============================================================
proc bb { cells } {
   if {[catch current_instance]} {
      puts "INFO: No open design."
      return
   }
   foreach cell $cells {
      update_design -black_box -cell $cell
   }
}

#==============================================================
# TCL proc to insert proxy (insert LUT1) on specified cells. Cells
# must be black_box before command can be run. 
#   ex. 'gb [get_bb]' 
#==============================================================
proc gb { cells } {
   if {[catch current_instance]} {
      puts "INFO: No open design."
      return
   }
   foreach cell $cells {
      update_design -buffer_ports -cell $cell
   }
}

###############################################################
# Create budget constraints for pins for greybox Partitions
###############################################################
proc create_partition_budget { args } {
   set FH "stdout"
   set excludePins ""

   #Override defaults with command options
   set argLength [llength $args]
   set index 0
   while {$index < $argLength} {
      set arg [lindex $args $index]
      set value [lindex $args [expr $index+1]]
      switch -exact -- $arg {
         {-cell}     {set cell [get_cells $value]}
         {-file}     {set FH [open $value w]}
         {-exclude}  {set excludePins $value}
         {-help}     {set     helpMsg "Description:"
                      lappend helpMsg "Creates set_max_delay constraints for initial DFX run.\n"
                      lappend helpMsg "Syntax:"
                      lappend helpMsg "create_partition_budget\ -cell <arg> \[-file <arg>] \[-exclude\]\n"
                      lappend helpMsg "Usage:"
                      lappend helpMsg "  Name                        Description"
                      lappend helpMsg "  ---------------------------------------"
                      lappend helpMsg "  \[-cell]                     Specifies the DFX cell to process."
                      lappend helpMsg "  \[-file]                     Optional. Specifies the output file name."
                      lappend helpMsg "                              If not specified the output will be written to STDOUT"
                      lappend helpMsg "  \[-exclude]                  Optional. List of pins to skip."
                      lappend helpMsg "                              Specifies local pin names without hierachy"
                      lappend helpMsg "  \[-help]                     Displays this message\n\n"
                      foreach line $helpMsg {
                         puts $line
                      }
                      return
                     }
         default     {set errMsg "ERROR: Specified argument $arg is not supported.\n"
                      append errMsg "Supported arguments are -help, -cell, and -file.\n"
                      append errMsg "Use the -help option for more details"
                      error $errMsg 
                     }
      }
      set index [expr $index + 2]
   }

   set_msg_config -id "Constraints 18-514" -suppress
   set_msg_config -id "Constraints 18-515" -suppress
   set_msg_config -id "Constraints 18-402" -suppress
   puts $FH "####Budget constraints for cell $cell####"


   set filter "REF_NAME=~FD* || REF_NAME=~RAMB* || REF_NAME=~DSP* || REF_NAME=~SRL*"
   set startPoints {}
   set endPoints {}

   #Process Input Pins. Ignore pins tied to clock logic, IO buffer, or VCC/GND 
   set inputs [get_pins -of [get_cells $cell] -filter DIRECTION==IN]
   puts "\tProcessing Input Pins of cell $cell ([llength $inputs] pins)"
   puts $FH "#Input pins:"
   set count 0
   foreach pin [lsort -dict $inputs] {
      if {[lsearch -exact $excludePins [lindex [split $pin /] end]] > "-1"} {
         puts "\tInfo: Skipping excluded pin $pin"
         continue
      }
      set HD_LUT [get_cells -quiet -of [get_pins -quiet -leaf -filter NAME=~$cell/HD_PR* -of [get_nets -quiet -of [get_pins $pin]]]]
      if {[llength $HD_LUT]} {
         #Get the cell names and filter out GTs, BUFG, IBUF, etc.
         set startPointCells [get_cells -quiet -filter $filter [all_fanin -quiet -startpoints_only -flat -only_cells $pin]]
         set clockPins [get_pins -quiet -filter IS_CLOCK -of $startPointCells]
         set clocks [get_clocks -quiet -of $clockPins]
         if {[llength $clocks]} {
            foreach clock $clocks {
               set timingPaths [get_timing_paths -quiet -from $startPointCells -through $pin -nworst 100000 -filter STARTPOINT_CLOCK==$clock]
               if {![llength $timingPaths]} {
                  puts "\tInfo: No timing path found through pin $pin for clock $clock." 
                  continue
               }

               #set startPointPins [lsort -dict -unique [join [get_pins [get_property STARTPOINT_PIN $timingPaths] -filter $filter]]]
               set startPointPins [lsort -dict -unique [get_pins [get_property STARTPOINT_PIN $timingPaths] -filter $filter]]
               lappend startPoints [get_cells -of [get_pins $startPointPins]]
               set logicLevels [lindex [lsort -dict [get_property LOGIC_LEVELS $timingPaths]] end]
               set period [get_property PERIOD [get_clocks $clock]]
               #If driver is RAMB*, add level of logic to account for large clk2out times
               if {[lsearch [get_property REF_NAME [get_pins $startPointPins]] "RAMB*"] > "-1"} {
                  set logicLevels [expr $logicLevels + 2]
               }
               if {$logicLevels < 1} {
                  set percentage "0.4"
               } elseif {$logicLevels < 2} {
                  set percentage "0.5"
               } elseif {$logicLevels < 3} {
                  set percentage "0.6"
               } elseif {$logicLevels < 4} {
                  set percentage "0.7"
               } elseif {$logicLevels >= 4} {
                  set percentage "0.8"
                  #puts "\tCritical Warning: Path found with $logicLevels levels of logic through pin $pin. Consider revising interface."
                  #puts "\tPath has load clock $clock with period of ${period}ns. Interface budget set to ${percentage} of period."
               }

               set value [expr $period * $percentage]
               puts $FH "#Pin: $pin\tLogic Levels: $logicLevels\tClock: $clock\tPeriod: $period\tBudget: $percentage"
               puts $FH "set_max_delay -datapath_only -from \[get_pins \[list $startPointPins\]\] -to \[get_pins $HD_LUT/I0\] $value"
               incr count
            }
         } elseif {[llength $clockPins]} {
            puts "Critical Warning: Found [llength $clockPins] clock pins \{$clockPins\} on source cells \{[lindex $startPointCells 0]\} of input pin $pin, but no clocks were defined. Ensure all required constraints have been defined. Try \"get_clocks -of \[get_pins [lindex $clockPins 0]\]\"" 
         }
      }
      if {![string match $FH "stdout"]} {
         flush $FH
      }
   }
   puts "\tAdded $count input path segmentation constraints for $cell"


   #Process output pins. Add set_logic_dc to prevent timing arc 
   #from being disabled by a constant (LUT1 connected to GND).
   set outputs [get_pins -of [get_cells $cell] -filter DIRECTION==OUT]
   puts "\tProcessing Output Pins of cell $cell ([llength $outputs] pins)"
   puts $FH "\n#Output pins:"
   foreach pin [lsort -dict $outputs] {
      set HD_LUT [get_cells -quiet -of [get_pins -quiet -leaf -filter NAME=~$cell/HD_PR* -of [get_nets -quiet -of [get_pins $pin]]]]
      if {[llength $HD_LUT]} {
         #Set a DC on LUT initially to prevent constant propagation, or no timing paths will be found, and all_fanout will return 0 endpoints
         set_logic_dc  [get_pins $HD_LUT/I0]
      }
   }

   set count 0
   foreach pin [lsort -dict $outputs] {
      if {[lsearch -exact $excludePins [lindex [split $pin /] end]] > "-1"} {
         puts "\tInfo: Skipping excluded pin $pin"
         continue
      }
      set HD_LUT [get_cells -quiet -of [get_pins -quiet -leaf -filter NAME=~$cell/HD_PR* -of [get_nets -quiet -of [get_pins $pin]]]]
      if {[llength $HD_LUT]} {
##         #Set a DC on LUT initially to prevent constant propagation, or no timing paths will be found, and all_fanout will return 0 endpoints
##         set_logic_dc  [get_pins $HD_LUT/I0]
         #Get the cell names and filter out GTs, OBUF, etc.
         set endPointCells [get_cells -quiet -filter $filter [all_fanout -quiet -endpoints_only -flat -only_cells $pin]]
         set clockPins [get_pins -quiet -filter IS_CLOCK -of $endPointCells]
         set clocks [get_clocks -quiet -of $clockPins]
         if {[llength $clocks]} {
            #Add set_logic_dc to XDC or set_max_delay on outputs wont't work. Only set once on pins with endpoints.
            puts $FH "set_logic_dc \[get_pins $HD_LUT/I0\]"
            foreach clock $clocks {
               #set timingPaths [get_timing_paths -quiet -through $pin -to $endPointCells -max_paths 100000 -filter ENDPOINT_CLOCK==$clock]
               set timingPaths [get_timing_paths -quiet -through $pin -to $endPointCells -nworst 100000 -filter ENDPOINT_CLOCK==$clock]
               if {![llength $timingPaths]} {
                   puts "\tCritical Warning: No timing path found through pin $pin for clock $clock." 
                  continue
               }
               #set endPointPins [lsort -dict -unique [join [get_pins [get_property ENDPOINT_PIN $timingPaths] -filter $filter]]]
               set endPointPins [lsort -dict -unique [get_pins [get_property ENDPOINT_PIN $timingPaths] -filter $filter]]
               lappend endPoints [get_cells -of [get_pins $endPointPins]]
               set logicLevels [lindex [lsort -dict [get_property LOGIC_LEVELS $timingPaths]] end]
               set period [get_property PERIOD [get_clocks $clock]]
               if {$logicLevels < 1} {
                  set percentage "0.4"
               } elseif {$logicLevels < 2} {
                  set percentage "0.5"
               } elseif {$logicLevels < 3} {
                  set percentage "0.6"
               } elseif {$logicLevels < 4} {
                  set percentage "0.7"
               } elseif {$logicLevels >= 4} {
                  set percentage "0.8"
                  #puts "\tCritical Warning: Path found with $logicLevels levels of logic through pin $pin. Consider revising interface."
                  #puts "\tPath has load clock $clock with period of ${period}ns. Interface budget set to ${percentage} of period."
               }
               #puts "#DEBUG - Pin: $pin\nLoad Data Pin: $end\nLoad Clock Pin: $clock\nPeriod: $period"
               set value [expr $period * $percentage]
               puts $FH "#Pin: $pin\tLogic Levels: $logicLevels\tClock: $clock\tPeriod: $period\tBudget: $percentage"
               puts $FH "set_max_delay -datapath_only -from \[get_pins $HD_LUT/O\] -to \[get_pins \[list $endPointPins\]\] $value"
               incr count
            }
         } elseif {[llength $clockPins]} {
            puts "Critical Warning: Found [llength $clockPins] clock pins \{$clockPins\} on load cells \{[lindex $endPointCells 0]\} of output pin $pin, but no clocks were defined. Ensure all required constraints have been defined. Try \"get_clocks -of \[get_pins [lindex $clockPins 0]\]\"" 
         }
      }
      if {![string match $FH "stdout"]} {
         flush $FH
      }
   }
   puts "\tAdded $count output path segmentation constraints for $cell"


   ###Check if feedback path exists... ie. startpoint also exists as an endpoint
##Comment this out as some designs have a high occurance of this (too many messages). 
#   set startPoints [lsort -dict [join $startPoints]]
#   set endPoints [lsort -dict [join $endPoints]]
#   foreach point $startPoints {
#      set matches [lsearch -exact -all $endPoints $point]
#      if {[llength $matches] > 0} {
#         puts "\nCritical Warning: The cell \'$point\' was found in more than one budget constraint. Constraining the same cell with multiple set_max_delay may lead to undesired timing results. \nResolution:\nSearch the resulting timing constraints for the cell listed above, and determine why this is being constrained through multiple Partition Pins.  Adjust the constraints or design as necessary."
#      }
#   }

   if {![string match $FH "stdout"]} {
      close $FH
   }
   reset_msg_config -quiet -id "Constraints 18-514" -suppress
   reset_msg_config -quiet -id "Constraints 18-515" -suppress
   reset_msg_config -quiet -id "Constraints 18-402" -suppress
}

#######################################################
#Tcl proc to export either all or specified Pblocks to
# STDOUT or to a specified file.
#######################################################
proc export_pblocks { args } {

   set FH "stdout"
   set pblocks [get_pblocks]

   #Override defaults with command options
   set argLength [llength $args]
   set index 0
   while {$index < $argLength} {
      set arg [lindex $args $index]
      set value [lindex $args [expr $index+1]]
      switch -exact -- $arg {
         {-pblocks}  {set pblocks [get_pblocks $value]}
         {-file}     {set FH [open $value w]}
         {-help}     {set     helpMsg "Description:"
                      lappend helpMsg "Exports Pblocks from in memory design to STDOUT or specified file.\n"
                      lappend helpMsg "Syntax:"
                      lappend helpMsg "export_pblocks\t\[-pblocks <arg>] \[-file <arg>]\n"
                      lappend helpMsg "Usage:"
                      lappend helpMsg "  Name                        Description"
                      lappend helpMsg "  ---------------------------------------"
                      lappend helpMsg "  \[-pblocks]                  Optional. Specifies the list of Pblocks to export."
                      lappend helpMsg "                              If no Pblocks are specified, all Pblocks will be exported." 
                      lappend helpMsg "  \[-file]                    Optional. Specifies the output file name."
                      lappend helpMsg "                               If not specified the output will be written to STDOUT"
                      lappend helpMsg "  \[-help]                    Displays this message\n\n"
                      foreach line $helpMsg {
                         puts $line
                      }
                      return
                     }
         default     {set errMsg "ERROR: Specified argument $arg is not supported.\n"
                      append errMsg "Supported arguments are -help, -pblocks, and -file.\n"
                      append errMsg "Use the -help option for more details"
                      error $errMsg 
                     }
      }
      set index [expr $index + 2]
   }

   foreach pblock $pblocks {
      puts $FH "\n\n####Pblock $pblock####"
      puts $FH "create_pblock $pblock"

      #Get all cells currently assigned to Pblock
      set cells [get_cells -quiet -of [get_pblocks $pblock]]
      set primitives {}
      if {[llength $cells]} {
         #puts $FH "add_cells_to_pblock \[get_pblocks $pblock\] \[get_cells \[list $cells\]\]"
         foreach cell $cells {
            if {![get_property IS_PRIMITIVE $cell]} {
               puts $FH "add_cells_to_pblock \[get_pblocks $pblock\] \[get_cells \{$cell\}\]"
            } else {
               lappend primitives $cell
            }
         }
         #If there are individual leaf cells, group them by hierarchy and write out one add_cells_to_pblock per matching hierarchy
         if {[llength $primitives]} {
            array set hierCells []
            set topCells ""
            foreach cell $primitives {
               if {[regexp {(.*)/(.*)} $cell match hier name]} {
                  lappend hierCells($hier) $name
               } else {
                  #assume if rexep fails, there was no hierarchy or different hierarchy separator
                  lappend topCells $cell
               }
            }
            foreach {hier} [array names hierCells] {
               set cellList {}
               foreach cell $hierCells($hier) {
                  lappend cellList "${hier}/${cell}"
               }
               puts $FH "add_cells_to_pblock \[get_pblocks $pblock\] \[get_cells \[list $cellList\]\]"
            }
            if {[llength $topCells]} {
               puts $FH "add_cells_to_pblock \[get_pblocks $pblock\] \[get_cells \[list $topCells\]\]"
            }
         }
      } else {
         puts "Warning: No cells currently assigned to Pblock $pblock"
      }

      #Determine Pblocks grids and ranges
      set grids  [get_property GRIDTYPES [get_pblock $pblock]]
      set ranges [get_property GRID_RANGES [get_pblocks $pblock]]
      set matchedRanges ""
      foreach grid $grids {
         set grid_ranges ""
         foreach range $ranges {
            regexp {(\w+)_(X\d+Y\d+)} $range temp type value
            if {[string match $grid $type]} {
               lappend grid_ranges $range
            }
         }
         if {[llength $grid_ranges]} {
            puts $FH "resize_pblock \[get_pblocks $pblock\] -add \{$grid_ranges\}"
            lappend matchedRanges $grid_ranges
         } else {
            puts "Critical Warning: Found GRIDTYPE $grid, but no ranges of the matching type in Pblock range for Pblock $pblock:\n$ranges"
         }
      }

      #Detect Ranges in Pblock with no matching GRIDTYPES (like BUFG or IO in non-DFX Pblock)
      foreach range $ranges {
         if {[lsearch [join $matchedRanges] $range]==-1} {
            puts $FH "resize_pblock \[get_pblocks $pblock\] -add \{$range\}"
         }
      }

      ##Check for addtitional Pblock properties
      if {[get_property PARTPIN_SPREADING [get_pblocks $pblock]] != 5} {
         puts $FH "set_property PARTPIN_SPREADING [get_property PARTPIN_SPREADING [get_pblocks $pblock]] \[get_pblocks $pblock\]"
      }
      if {[llength [get_property SNAPPING_MODE [get_pblocks $pblock]]]} {
         puts $FH "set_property SNAPPING_MODE [get_property SNAPPING_MODE [get_pblocks $pblock]] \[get_pblocks $pblock\]"
      }
      if {[get_property CONTAIN_ROUTING [get_pblocks $pblock]]} {
         puts $FH "set_property CONTAIN_ROUTING 1 \[get_pblocks $pblock\]"
      }
      if {[get_property EXCLUDE_PLACEMENT [get_pblocks $pblock]]} {
         puts $FH "set_property EXCLUDE_PLACEMENT 1 \[get_pblocks $pblock\]"
      }
      if {[get_property RESET_AFTER_RECONFIG [get_pblocks $pblock]]} {
         puts $FH "set_property RESET_AFTER_RECONFIG 1 \[get_pblocks $pblock\]"
      }
      if {![string match "ROOT" [get_property PARENT [get_pblocks $pblock]]]} {
         puts $FH "set_property PARENT [get_property PARENT [get_pblocks $pblock]] \[get_pblocks $pblock\]"
      }
      flush $FH
   }
   if {![string match $FH "stdout"]} {
      close $FH
   }
}

#################################################
# Proc to mark congestion rectangles reported by 
# route_design in INT_XY -> INT_XY format 
# mark_congestion {"INT_XY -> INT_XY" "INT_XY -> INT_XY"}
# mark_congestion [list {INT_XY -> INT_XY} {INT_XY -> INT_XY}]
#################################################
proc mark_congestion { ranges } {
   set colors {red green blue magenta yellow cyan orange}
   set color 0
   foreach range $ranges {
      set intTile1 [lindex $range 0]
      set intTile2 [lindex $range end]

      set corner1 [lindex [split $intTile1 _] end]
      set corner2 [lindex [split $intTile2 _] end]

      set sites1 [get_sites -of [get_tiles *_$corner1]]
      set sites2 [get_sites -of [get_tiles *_$corner2]]
      puts "$corner1: $sites1"
      puts "$corner2: $sites2"

      mark_objects -color [lindex $colors $color] [get_sites -range [lindex $sites1 0]:[lindex $sites2 end]]
      if {$color==6} {
         set color 0
      } else {
         incr color
      }
   }
}

#################################################
# Proc to find and hightlight all overlapping nodes 
# Requires a route DCP with overlaps.
# Use 'catch {route_design}' to get this DCP 
# This can take a very long time to run. Set limit 
# to stop after specified number of overlappling 
# nodes are found.
#################################################
proc get_overlapping_nodes {{limit 0}} {
   set nets [get_nets -hier -filter ROUTE_STATUS==CONFLICTS]
   puts "Found [llength $nets] nets with Conflicts."
   set nodes [get_nodes -of $nets]
   puts "Parsing [llength $nodes] nodes for potential overlaps."
   set nodeOverlaps {}
   set count 0
   set lineCount 0

   puts -nonewline "0 "
   foreach node $nodes {
      #If a limit is specified, stop after #limit overlapping nodes are found
      if {$limit > 0} {
         if {[llength $nodeOverlaps] == $limit} {
            break
         }
      }
      set nodeNets [get_nets -quiet -of $node]
      if {[llength $nodeNets] > 1} {
         lappend nodeOverlaps $node
      }
      incr count
      #Add a "." for every 100 nodes checked
      if {[expr fmod($count,100)]==0.0} {
         puts -nonewline "."
      }

      #Add a new line of "."s for every 1000 nodes
      if {$count == 1000} {
         set count 0
         incr lineCount
         puts ""
         puts -nonewline "${lineCount}k"
      }
      flush stdout 
   }
   puts "\nFound [llength $nodeOverlaps] overlapping nodes."
   if {[llength $nodeOverlaps]} {
      select_objects $nodeOverlaps
      highlight_objects -color red [get_selected_objects]
   }
}

