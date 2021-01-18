#################################################
# Proc to unroute, uplace, and reset HD.PARTPIN_* 
#################################################
proc pr_unplace {} {
   route_design -unroute
   place_design -unplace
   set cells [get_cells -quiet -hier -filter HD.RECONFIGURABLE]
   foreach cell $cells {
      reset_property HD.PARTPIN_LOCS [get_pins $cell/*]
      reset_property HD.PARTPIN_RANGE [get_pins $cell/*]
   }
}

#==============================================================
# TCL proc for changing current value of HD.RECONFIGURABLE 
#==============================================================
proc toggle_pr { cells } {
   if {[catch current_instance]} {
      puts "INFO: No open design."
      return
   }
   foreach cell $cells {
      if {[get_property HD.RECONFIGURABLE [get_cells $cell]] != "1"} {
         set_property HD.RECONFIGURABLE 1 [get_cells $cell]
      } else {
         set_property HD.RECONFIGURABLE 0 [get_cells $cell]
      }
   } 
}

#==============================================================
# TCL proc for getting a list of cells marked with HD.RECONFIGURABLE 
#==============================================================
proc get_rps {} {
   if {[catch current_instance]} {
      puts "INFO: No open design."
      return
   }
   set rps [get_cells -quiet -hier -filter HD.RECONFIGURABLE]
   if {![llength $rps]} {
      puts "Info: No cells found with HD.RECONFIGURABLE==1"
      return
   }
   return $rps
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
#   ex. 'bb [get_rps]' 
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
# TCL proc to grey_boxy (insert LUT1) specified cells. Cells
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

#==============================================================
# TCL proc for clearing PartPin information 
# Usage:
#     delete_PartPins [get_cells -quiet -hier -filter HD.RECONFIGURABLE]
#==============================================================
proc delete_PartPins { RPs } {
   foreach rp $RPs {
      reset_property HD.PARTPIN_RANGE [get_pins $rp/*]
      reset_property HD.PARTPIN_LOCS  [get_pins $rp/*]
   }
}

#################################################
# Proc to highlight PARTPIN_RANGE value
# Currently, picks first pin. Need to modify
# to get a super set from all pins
#################################################
proc get_pp_range { cell } {
   set pp_range_sites ""
   set pp_ranges ""
   set pins [get_pins -filter HD.PARTPIN_RANGE!="" -of [get_cells $cell]]
   foreach pin $pins {
      set ranges [get_property HD.PARTPIN_RANGE [get_pins $pin]]
      if {[llength $ranges]} {
         foreach range $ranges {
            if {[lsearch -exact $pp_ranges $range]==-1} {
               puts "Found unique range $range"
               lappend pp_ranges $range
               lappend pp_range_sites [get_sites -range $range]
            }
         }
      }
   }
   set sites [concat {*}$pp_range_sites]
   highlight_objects -color yellow [get_sites [lsort $sites]]
}


#################################################
# Proc to find and report all clocks driving an RP. 
# Lists the clock pin, net, driver, and Static/RM
# load counts. 
#################################################
proc get_rp_clocks { cell {file ""}} {
   set table " -row {\"Clock Pin\" \"Clock Net\" \"Clock Driver\" \"Driver Type\" \"RM Loads\" \"Static Loads\"}"
   set count 0
   set clockNets ""
   set staticLods ""
   set pins [get_pins $cell/* -filter DIRECTION==IN]
   foreach pin $pins {
      set clock_driver [get_cells -quiet -of [get_pins -quiet -leaf -of [get_nets -quiet -of $pin] -filter DIRECTION==OUT] -filter REF_NAME=~BUF*]
      if {[llength $clock_driver]} {
         incr count
         set clock_net [get_nets -of [get_pins $pin]]
         set driver_type [get_property REF_NAME [get_cells $clock_driver]]
         set rm_loads [llength [get_pins -quiet -leaf -of $clock_net -filter NAME=~$cell/*]]
         set static_pins [get_pins -quiet -leaf -of $clock_net -filter "NAME!~$cell/* && DIRECTION==IN"]
         set static_loads [llength $static_pins]
         append table " -row {$pin $clock_net $clock_driver $driver_type $rm_loads $static_loads}"
         lappend clockNets $clock_net
         lappend staticLoads [get_cells -quiet -of $static_pins -filter "REF_NAME!~BUF* && REF_NAME!~MMCM* && REF_NAME!~PLL*"]
      }
   }
   set title "-title {#HD: Clock information for RP $cell ($count clocks total)}"
   set table ${title}${table}
   if {[llength $file]} {
      print_table $table -file $file
   } else {
      print_table $table
   }
   return $clockNets
#   return $staticLoads
}

#################################################
# Proc to print all clocks with $limit number of 
# loads. Prints total clocks, and clocks that meet
# the limit along with driver/laods
#################################################
proc get_limit_clocks {{limit 4}} {
   set clocks [get_clocks -quiet]
   puts "Found [llength $clocks] clocks in the design"
   set clockCount 0
   set title "-title {Total Clocks:[llength $clocks] in design. Reporting on clocks with $limit or less connections}"
   set table " -row {\"\" \"Clock\" \"Total Loads\" \"Load Types\" \"Driver Type\"}"
   foreach clock $clocks {
      set loads  [get_pins -quiet -leaf -filter DIRECTION==IN -of [get_nets -of $clock]]
      set driver [get_pins -quiet -leaf -filter DIRECTION==OUT -of [get_nets -of $clock]]
      if {[llength $loads]<=$limit} {
         incr clockCount
         if {[llength $driver]} {
            append table " -row {$clockCount $clock [llength $loads] [list [get_property REF_NAME $loads]] [get_property REF_NAME $driver]}"
         } elseif {[llength [get_ports -quiet -of [get_nets -of $clock]]]} {
            set driver [get_ports -of [get_nets -of $clock]]
            append table " -row {$clockCount $clock [llength $loads] [list [get_property REF_NAME $loads]] Port\($driver\)}"
         } else {
            append table " -row {$clockCount $clock [llength $loads] [list [get_property REF_NAME $loads]] Unknown}"
         }
      }
   }
   print_table $table
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
   }
   puts "\nFound [llength $nodeOverlaps] overlapping nodes."
   if {[llength $nodeOverlaps]} {
      select_objects $nodeOverlaps
      highlight_objects -color red [get_selected_objects]
   }
}

#######################################################
#Tcl proc to export either all or specified PartPins to
# STDOUT or to a specified file.
#######################################################
proc export_partpins { args } {
   set FH "stdout"
   set pins [get_pins -hier * -filter HD.ASSIGNED_PPLOCS!=""]
   array set options {-pblocks $pblocks -file ""}

   #Override defaults with command options
   set argLength [llength $args]
   set index 0
   while {$index < $argLength} {
      set arg [lindex $args $index]
      set value [lindex $args [expr $index+1]]
      switch -exact -- $arg {
         {-cells}  {set cells [get_cells $value]}
         {-file}     {set FH [open $value w]}
         {-help}     {set     helpMsg "Description:"
                      lappend helpMsg "Exports Partition Pins from in memory design to STDOUT or specified file.\n"
                      lappend helpMsg "Syntax:"
                      lappend helpMsg "export_partpins\t\[-cells <arg>] \[-file <arg>]\n"
                      lappend helpMsg "Usage:"
                      lappend helpMsg "  Name                        Description"
                      lappend helpMsg "  ---------------------------------------"
                      lappend helpMsg "  \[-cells]                  Optional. Specifies the list of Cells to export."
                      lappend helpMsg "                              If no Cells are specified, all PartPins will be exported." 
                      lappend helpMsg "  \[-file]                   Optional. Specifies the output file name."
                      lappend helpMsg "                              If not specified the output will be written to STDOUT"
                      lappend helpMsg "  \[-help]                   Displays this message\n\n"
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
   
   if {![info exists cells]} {
      set errMsg "Error: No -cells option specificed. A cell must be specified with this option."
      error $errMsg
   }

   #if -cell is used, clear out pin list and create a list based of of specified cells
   if {[llength $cells]} {
      foreach cell $cells {
         foreach pin [lsort -dict [get_pins -of [get_cells $cell] -filter HD.ASSIGNED_PPLOCS!=""]] {
            puts $FH "set_property HD.PARTPIN_LOCS [lindex [get_property HD.ASSIGNED_PPLOCS $pin] 0] \[get_pins \{$pin\}\]"
            flush $FH
         }
      }
   }
   close $FH
}

#######################################################
#Tcl proc to export either all or specified Pblocks to
# STDOUT or to a specified file.
#######################################################
proc export_pblocks { args } {

   set FH "stdout"
   set pblocks [get_pblocks]
   array set options {-pblocks $pblocks -file ""}

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
      set cells [get_cells -quiet -of [get_pblocks $pblock]]
      if {[llength $cells]} {
         puts $FH "add_cells_to_pblock \[get_pblocks $pblock\] \[get_cells \[list $cells\]\]"
      }
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

      #Detect Ranges in Pblock with no matching GRIDTYPES (like BUFG or IO in non-PR Pblock)
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

#########################################
# Proc to highlight nets internal to a
# specified cell. Intended to show the routes
# controlled by CONTAIN_ROUTING.
# Default highlight color is red
#########################################
proc highlight_internal_nets { cell {color red} } {

   if {[get_property IS_BLACKBOX [get_cells $cell]]} {
      puts "Info: Cell $cell is a blackbox, and will not be processed."
      return
   }
   #Get a list of all nets that match the cell name, but filter out clocks and Global_Logic
   set nets [get_nets -hier -filter "NAME=~$cell/* && TYPE!=GLOBAL_CLOCK && TYPE!=GND && TYPE!=VCC && TYPE!= POWER && TYPE!=GROUND"]
   puts "All nets from $cell: [llength $nets]"
   set internal_nets ""
   foreach net $nets {
      #get a list of all leaf level pins that the net connects to
      set pins [get_pins -quiet -leaf -of [get_nets $net]]
      set external 0
      #Look at each pin to see if connects to a pin outside of the specified cell
      #If it does, ignore this net and move on (break)
      foreach pin $pins {
         if {![string match "$cell/*" $pin]} {
            set external 1
            break
         }
      }
      if {!$external} {
         lappend internal_nets $net
      }
   }
   llength $internal_nets
   puts "Internal nets of $cell: [llength $internal_nets]"
   highlight_objects -color $color [get_nets $internal_nets]
}

#==============================================================
# TCL proc for exporting inteface nets to an XDC
# Currently, write_checkpoint -cell does not write out
# interface nets, so this proc is a way to preserve these
# routes for doing timing checks of all configurations in SW 
#==============================================================
proc fix_interface_nets { cell {xdc ""} } {
   #Define default file name if one is not specified
   if {![llength $xdc]} {
      set xdc "[lindex [split $cell /] end].xdc"
   }
   #Check to see if any pins have PartPins
   set pins [get_pins $cell/* -filter HD.ASSIGNED_PPLOCS!=""]
   if {![llength $pins]} {
      return
   }
   puts "Creating output file \"$xdc\""
   set FH [open $xdc w]
   foreach pin $pins {
      if {[llength [get_property HD.ASSIGNED_PPLOCS $pin]]} {
         set net [get_nets -of $pin]
         set_property IS_ROUTE_FIXED 1 $net
         puts $FH "set_property FIXED_ROUTE [get_property FIXED_ROUTE $net] \[get_nets $net\]"
         flush $FH
         set_property IS_ROUTE_FIXED 0 $net
      }
   }
   close $FH
}

###############################################
# A proc to read in a list of RMs (OOC DCPs) for 
# a module, and create a worst case "training"
# module for the initial PR configuration.
###############################################
proc create_training_kernel { dcps } {
   array set module {}
   #Check if all specified DCPs exists
   foreach dcp $dcps {
      if {![file exists $dcp]} {
         set errMsg "Error: Specified DCP does not exist.\n$dcp" 
         error $errMsg
      }
   }
   
   set LFH [open "training_kernel.log" w]
   #Open each DCP and get the worst case load/drivers in the RM.
   foreach dcp $dcps {
      puts "Opening DCP $dcp"
      open_checkpoint $dcp > temp.log
      set part [get_property PART [current_design]]
      #Get the module name make sure it matches between all versions of specified DCPs.
      set top [get_property TOP [current_design]]
      if {[info exists name]} {
         if {![string match $name $top]} {
            set errMsg "Error: Value of property top ($top) does match previous value $name."
            error $errMsg
          }
      } else {
         set name $top
      }

      foreach port_object [lsort -dict [get_ports ]] {
         set port [get_property NAME $port_object]
         #puts $LFH "Examining Port $port"
         set info [get_loads $port]
         lassign $info levels loads clock direction
         set level [lindex $info 0]
         if {![info exists module($port)] || $level >= [lindex $module($port) 0]} { 
            #puts $LFH "Setting $info for $port"
            set module($port) $info
         } else {
             puts "\tPrevious value [lindex $module($port) 0] was greater that new value $level for $port"
         }
      }
      close_project
      puts "Done with DCP $dcp"
   }
   

   puts "Creating kernel for $name"
   #Create an empty design (OOC) to start creating the training kernel
   link_design -part $part -mode out_of_context
   rename_ref -ref netlist_EMPTY -to $name

#   set table "-title \"$name - $dcp\""
#   append table " -row {Ports Direction Levels Loads Clock}"
   #Define all clock ports and create clock nets
   foreach port [lsort -dict [array names module]] {
      lassign $module($port) levels loads clock direction
#      append table " -row {$port $direction $levels $loads $clock}"
      if {[string match $clock "is_clock"]} {
         create_clock_port $port
      }
   }
#   append $table " -handle $LFH"
#   print_table $table 

   #Create a GND cell/net to drive output flops
   create_cell GND -reference GND
   create_net <const0>
   connect_net -net <const0> -objects [get_pins GND/G]

   #Create data ports with specified levels of logic
   foreach port [lsort -dict [array names module]] {
      lassign $module($port) levels loads clock direction
      if {![string match $clock "is_clock"]} {
         if {[string match $direction "IN"]} {
            puts "Creating Input Port $port:"
            create_input_port $port $module($port)
         } elseif {[string match $direction "OUT"]} {
            puts "Creating Output Port $port:"
            create_output_port $port $module($port)
         } else {
            set errMsg "ERROR: Invalid direction $direction specfied for port $port"
            error $errMsg
         }
      }
   }

   close $LFH
   #Apply DONT_TOUCH constraints to prevent optimization
   puts "Setting DONT_TOUCH properties"
   set_property DONT_TOUCH 1 [get_cells]
   set_property DONT_TOUCH 1 [get_nets]

   #Export newly created training module to be used as initial RM
   write_checkpoint -force ${name}_training_synth.dcp
   close_project
}

###############################################
# A proc to create a clock port with specfifed 
# name. Creates net and connects it as well.
###############################################
proc create_clock_port { port } {
   upvar LFH LFH
   set direction "IN"
   puts $LFH "Creating clock port $port"
   regexp {(.*)\[(\d*)\]} $port port portName portIndex
   if {[info exists portIndex]} {
      create_port -direction $direction $portName -from $portIndex -to $portIndex
      set portRef ${portName}_$portIndex
   } else {
      create_port -direction $direction $port
      set portRef $port
   } 
   create_net $portRef
   connect_net -net $portRef -objects [get_ports $port]
}

###############################################
# A proc to create an output port with specfifed 
# name. Creates specified levels of logic (LUT1)
# from the port to an FDRE driver connected to 
# the specifiedclock port (which is already created),
# and ties off D pin to GND.
###############################################
proc create_output_port {port info} {
   upvar LFH LFH
   lassign $info levels loads clock direction
   puts $LFH "Creating logic for output port: $port\tClock port: $clock\tLevels of logic: $levels"
   regexp {(.*)\[(\d*)\]} $port port portName portIndex
   if {[info exists portIndex]} {
      create_port -direction $direction $portName -from $portIndex -to $portIndex
      set portRef ${portName}_$portIndex
   } else {
      create_port -direction $direction $port
      set portRef $port
   } 
   #puts "\tCreating Nets and Cells for $port using unique reference $portRef"
   if {[string match $clock "none"]} {
      puts "Critical Warnings: Created output port $port with no synchronous Driver. Consider removing this port from the RP interface."
      return 
   } elseif {$levels==0} {
      regexp {(.*)\[(\d*)\]} $clock clock clockName clockIndex
      if {[info exists clockIndex]} {
         set clockRef ${clockName}_$clockIndex
      } else {
         set clockRef $clock
      }
      create_net ${portRef}
      create_cell -reference FDRE ${portRef}_FDRE
      connect_net -net $portRef -objects [list [get_ports $port] [get_pins ${portRef}_FDRE/Q]]
      connect_net -net $clockRef -objects [get_pins ${portRef}_FDRE/C]
      connect_net -net <const0> -objects [get_pins ${portRef}_FDRE/D]
   } else {
      for {set i 0} {$i <= $levels} {incr i} {
         if {$i==0} {
            create_net ${portRef}_$i
            create_cell -reference LUT1 ${portRef}_LUT1_$i
            set_property INIT 2'h2 [get_cells ${portRef}_LUT1_$i]
            connect_net -net ${portRef}_$i -objects [list [get_ports $port] [get_pins ${portRef}_LUT1_$i/O]]
         } elseif {$i==$levels} {
            regexp {(.*)\[(\d*)\]} $clock clock clockName clockIndex
            if {[info exists clockIndex]} {
               set clockRef ${clockName}_$clockIndex
            } else {
               set clockRef $clock
            }
            create_net ${portRef}_$i
            create_cell -reference FDRE ${portRef}_FDRE
            connect_net -net ${portRef}_$i -objects [list [get_pins ${portRef}_LUT1_[expr $i-1]/I0] [get_pins ${portRef}_FDRE/Q]]
            connect_net -net $clockRef -objects [get_pins ${portRef}_FDRE/C]
            connect_net -net <const0> -objects [get_pins ${portRef}_FDRE/D]
         } else {
            create_net ${portRef}_$i
            create_cell -reference LUT1 ${portRef}_LUT1_$i
            set_property INIT 2'h2 [get_cells ${portRef}_LUT1_$i]
            connect_net -net ${portRef}_$i -objects [list [get_pins ${portRef}_LUT1_[expr $i-1]/I0] [get_pins ${portRef}_LUT1_$i/O]]
         }
      }
   }
}

###############################################
# A proc to create an input port with specfifed 
# name. Creates specified levels of logic (LUT1)
# from the port to an FDRE connected to specified
# clock port (which is already created).
###############################################
proc create_input_port {port info} {
   upvar LFH LFH
   lassign $info levels loads clock direction
   #Support for only 1 clock at this time
   set clock [lindex $clock 0]
   puts $LFH "Creating logic for input port: $port\tClock port: $clock\tLevels of logic: $levels"
   regexp {(.*)\[(\d*)\]} $port port portName portIndex
   if {[info exists portIndex]} {
      create_port -direction $direction $portName -from $portIndex -to $portIndex
      set portRef ${portName}_$portIndex
   } else {
      create_port -direction $direction $port
      set portRef $port
   } 

   #puts "\tCreating Nets and Cells for $port using unique reference $portRef"
   if {[string match $clock "none"]} {
      puts "Critical Warnings: Created input port $port with no synchronous loads. Consider removing this port from the RP interface."
      return
   } elseif {$levels==0} {
      regexp {(.*)\[(\d*)\]} $clock clock clockName clockIndex
      if {[info exists clockIndex]} {
         set clockRef ${clockName}_$clockIndex
      } else {
         set clockRef $clock
      }
      create_net ${portRef}
      create_cell -reference FDRE ${portRef}_FDRE
      connect_net -net $portRef -objects [list [get_ports $port] [get_pins ${portRef}_FDRE/D]]
      connect_net -net $clockRef -objects [get_pins ${portRef}_FDRE/C]
   } else {
      for {set i 0} {$i <= $levels} {incr i} {
         if {$i==0} {
            create_net ${portRef}_$i
            create_cell -reference LUT1 ${portRef}_LUT1_$i
            set_property INIT 2'h2 [get_cells ${portRef}_LUT1_$i]
            connect_net -net ${portRef}_$i -objects [list [get_ports $port] [get_pins ${portRef}_LUT1_$i/I0]]
         } elseif {$i==$levels} {
            regexp {(.*)\[(\d*)\]} $clock clock clockName clockIndex
            if {[info exists clockIndex]} {
               set clockRef ${clockName}_$clockIndex
            } else {
               set clockRef $clock
            }
            create_net ${portRef}_$i
            create_cell -reference FDRE ${portRef}_FDRE
            connect_net -net ${portRef}_$i -objects [list [get_pins ${portRef}_LUT1_[expr $i-1]/O] [get_pins ${portRef}_FDRE/D]]
            connect_net -net $clockRef -objects [get_pins ${portRef}_FDRE/C]
         } else {
            create_net ${portRef}_$i
            create_cell -reference LUT1 ${portRef}_LUT1_$i
            set_property INIT 2'h2 [get_cells ${portRef}_LUT1_$i]
            connect_net -net ${portRef}_$i -objects [list [get_pins ${portRef}_LUT1_[expr $i-1]/O] [get_pins ${portRef}_LUT1_$i/I0]]
         }
      }
   }
}

###############################################
# A proc to anlayze a specified port in an open
# design. Collect port direction, number of loads
# for outputs, and name of clock port connected 
# to loads/driver. 
# Returns list of information. 
###############################################
proc get_loads { port } {
   set direction  [get_property DIRECTION [get_ports $port]]
   if {[string match "IN" $direction]} {
      #Filter out clocks
      set clockLoads [llength [get_pins -quiet -leaf -of [get_nets -quiet -of [get_ports $port]] -filter IS_CLOCK]]
      if {$clockLoads > 0} {
         return [list 0 $clockLoads is_clock $direction]
      }
      set logicLevel [lindex [lsort [get_property -quiet LOGIC_LEVELS [get_timing_paths -quiet -from [get_ports $port] -to [all_fanout -quiet -endpoint -flat [get_ports $port]]]]] end]
      if {[llength $logicLevel]} {
         set loads [all_fanout -quiet -endpoint -flat -only_cells [get_ports $port]]
         set clockPort [get_ports -of [get_nets -of [get_pins -of [get_cells $loads] -filter IS_CLOCK]]]
         if {[llength $clockPort] > 1} {
            puts "INFO: Found loads driven by port $port with different clock sources.\nClocks found for $port:\n\t[join $clockPort \n\t]"
         }
         return [list $logicLevel [llength $loads] [get_property NAME $clockPort] $direction]
      } else {
         return [list 0 0 none $direction]
      }
   } else {
      set logicLevel [lindex [lsort [get_property -quiet LOGIC_LEVELS [get_timing_paths -quiet -from [all_fanin -quiet -startpoint -flat [get_ports $port]] -to [get_ports $port]]]] end]
      if {[llength $logicLevel]} {
         set driver [all_fanin -quiet -startpoint -flat -only_cells [get_ports $port]]
         set clockPort [get_ports -of [get_nets -of [get_pins -of [get_cells $driver] -filter IS_CLOCK]]]
         return [list $logicLevel 1 [get_property NAME $clockPort] $direction]
      } else {
         return [list 0 0 none $direction]
      }
   }
}


###############################################################
# Create budget constraints for pins on unsed RP 
###############################################################
proc create_pr_budget { args } {
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
                      lappend helpMsg "Creates set_max_delay constraints for initial PR run.\n"
                      lappend helpMsg "Syntax:"
                      lappend helpMsg "create_pr_budget\ -cell <arg> \[-file <arg>] \[-exclude\]\n"
                      lappend helpMsg "Usage:"
                      lappend helpMsg "  Name                        Description"
                      lappend helpMsg "  ---------------------------------------"
                      lappend helpMsg "  \[-cell]                     Specifies the PR cell to process."
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
               set startPointPins [get_pins [get_property STARTPOINT_PIN $timingPaths] -filter $filter]
               set logicLevels [lindex [lsort -dict [get_property LOGIC_LEVELS $timingPaths]] end]
               set period [get_property PERIOD [get_clocks $clock]]
               #If driver is RAMB*, add level of logic to account for large clk2out times
               if {[lsearch [get_property REF_NAME $startPointPins] "RAMB*"] > "-1"} {
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
               } elseif {$logicLevels > 4} {
                  set percentage "0.8"
                  puts "\tCritical Warning: Path found with $logicLevels levels of logic through pin $pin. Consider revising interface."
                  puts "\tPath has load clock $clock with period of ${period}ns. Interface budget set to ${percentage} of period."
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
   set count 0
   foreach pin [lsort -dict $outputs] {
      if {[lsearch -exact $excludePins [lindex [split $pin /] end]] > "-1"} {
         puts "\tInfo: Skipping excluded pin $pin"
         continue
      }
      set HD_LUT [get_cells -quiet -of [get_pins -quiet -leaf -filter NAME=~$cell/HD_PR* -of [get_nets -quiet -of [get_pins $pin]]]]
      if {[llength $HD_LUT]} {
         #Set a DC on LUT initially to prevent constant propagation, or no timing paths will be found, and all_fanout will return 0 endpoints
         set_logic_dc  [get_pins $HD_LUT/I0]
         #Get the cell names and filter out GTs, OBUF, etc.
         set endPointCells [get_cells -quiet -filter $filter [all_fanout -quiet -endpoints_only -flat -only_cells $pin]]
         set clockPins [get_pins -quiet -filter IS_CLOCK -of $endPointCells]
         set clocks [get_clocks -quiet -of $clockPins]
         if {[llength $clocks]} {
            #Add set_logic_dc to XDC or set_max_delay on outputs wont't work. Only set once on pins with endpoints.
            puts $FH "set_logic_dc \[get_pins $HD_LUT/I0\]"
            foreach clock $clocks {
               set timingPaths [get_timing_paths -quiet -through $pin -to $endPointCells -max_paths 100000 -filter ENDPOINT_CLOCK==$clock]
               if {![llength $timingPaths]} {
                   puts "\tCritical Warning: No timing path found through pin $pin for clock $clock." 
                  continue
               }
               set endPointPins [get_pins [get_property ENDPOINT_PIN $timingPaths] -filter $filter]
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
               } elseif {$logicLevels > 4} {
                  set percentage "0.8"
                  puts "\tCritical Warning: Path found with $logicLevels levels of logic through pin $pin. Consider revising interface."
                  puts "\tPath has load clock $clock with period of ${period}ns. Interface budget set to ${percentage} of period."
               }
               #puts "Pin: $pin\nLoad Data Pin: $end\nLoad Clock Pin: $clock\nPeriod: $period"
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




   if {![string match $FH "stdout"]} {
      close $FH
   }
   reset_msg_config -quiet -id "Constraints 18-514" -suppress
   reset_msg_config -quiet -id "Constraints 18-515" -suppress
   reset_msg_config -quiet -id "Constraints 18-402" -suppress
}


###############################################################
# Analyze PR interface timing 
###############################################################
proc analyze_pr_interface { DCPs {file "pr_timing_analysis"} {debug 0} } {
   set_msg_config -id "Constraints 18-514" -suppress
   set_msg_config -id "Constraints 18-515" -suppress
   set_msg_config -id "Constraints 18-402" -suppress

   set filter "REF_NAME=~FD* || REF_NAME=~RAMB* || REF_NAME=~DSP* || REF_NAME=~SRL*"
   set pblocks ""
   foreach dcp $DCPs {
      puts "Opening Checkpoint $dcp"
      open_checkpoint $dcp > open_checkpoint.log
      set RPs [get_rps]
      if {[llength $RPs]} {
         puts "Found [llength $RPs] cells marked with HD.RECONFIGURABLE"
      }

      #Carve out RP cells if not already blackbox
      set lock 0
      foreach cell $RPs {
         if {![get_property IS_BLACKBOX [get_cells $cell]]} {
            puts "Info: Specified cell $cell in DCP $dcp is not a blackbox. Creating Blackbox."
            update_design -cell $cell -black_box > black_box.log
            set lock 1
         }
      }

      #Lock Static design if needed. If RP were already BB, assume lock_design already run.
      if {$lock} {
         lock_design -level routing
      }
      
      #Insert LUT1 for each RP
      foreach cell $RPs {
         puts "Buffering ports on RP cell $cell"
         update_design -cell $cell -buffer_ports > buffer_ports.log
      }

      #Place/Route LUT1 buffers
      puts "Placing RP port buffers"
      place_design > place_design.log
      if {$debug} {
         write_checkpoint -force static_inserted_place.dcp
      }
      puts "Routing RP port buffers"
      route_design > route_design.log
      if {$debug} {
         write_checkpoint -force static_inserted_route.dcp
      }
      
      foreach cell $RPs {
         set pblock [get_pblocks -of [get_cells $cell]]
         if {[lsearch -exact $pblocks $pblock] < 0} {
            lappend pblocks $pblock
         }
         #Process Input Pins. Ignore pins tied to clock logic, IO buffer, or VCC/GND 
         set inputs [get_pins -of [get_cells $cell] -filter DIRECTION==IN]
         puts "Processing Input Pins of cell $cell ([llength $inputs] pins)"
         if {$debug} {
            set count 0
         }
         foreach pin [lsort -dict $inputs] {
            if {$debug} {
               if {$count==10} {
                  break
               }
               incr count
               puts "pin$count: $pin"
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
                     set startPointPins [get_pins [get_property STARTPOINT_PIN $timingPaths] -filter $filter]
                     set period [get_property PERIOD [get_clocks $clock]]
                     set_max_delay -datapath_only -from [get_pins [list $startPointPins]] -to [get_pins $HD_LUT/I0] $period
                     set timing_path [get_timing_path -quiet -through [get_pins $pin]]
                     set startClock  [get_property STARTPOINT_CLOCK $timing_path]
                     set requirement [get_property REQUIREMENT $timing_path]
                     set slack       [get_property SLACK $timing_path]
                     set levels      [get_property LOGIC_LEVELS $timing_path]
                     set totalDelay  [get_property DATAPATH_DELAY $timing_path]
                     #Check to see if array entry already exists. If not, check that requirement matches
                     if {$debug} {
                        puts "DEBUG: key:${pin}.${clock} Requirement: $requirement Clock: $startClock"
                     }
                     if {[info exists pinDelays_${pblock}(${pin}.${clock})]} {
                        set checkRequirement [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 0]
                        if {$checkRequirement != $requirement} {
                           puts "Critical Warning: Requirement of $requirement for pin $pin of DCP $dcp is different from previous DCP with requirement of $checkRequirement"
                        }
                        set checkClock [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 1]
                        if {$checkClock != $startClock} {
                           puts "Critical Warning: Clock $startClock for pin $pin of DCP $dcp is different from previous DCP with clock of $checkClock"
                           set pinDelays_${pblock}(${pin}.${clock}) [lreplace [set pinDelays_${pblock}\(${pin}.${clock}\)] 1 1 $startClock]
                        }
                           #lappend pinDelays_${pblock}(${pin}.${clock}) [list $slack $levels $totalDelay $dcp]
                           set pinDelays_${pblock}(${pin}.${clock}) [list [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 0] [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 1] [linsert [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 2] 0 [list $slack $levels $totalDelay $dcp]]]
                     } else {
#puts "Setting pin $pin"
                        set pinDelays_${pblock}(${pin}.${clock}) [list $requirement $startClock [list [list $slack $levels $totalDelay $dcp]]]
                     }
#                     if {[string match "null" $checkClock]} {
#                        puts "DEBUG: Found null clock for pin $pin with clock $checkClock. Value should be $startClock."
#                     }
                  }
               } elseif {[llength $clockPins]} {
                  puts "Critical Warning: Found [llength $clockPins] clock pins driving input pin $pin, but no clocks were defined. Ensure all required constraints have been defined." 
               }
            }
         }
      
      
         #Process output pins. Add set_logic_dc to prevent timing arc 
         #from being disabled by a constant (LUT1 connected to GND).
         set outputs [get_pins -of [get_cells $cell] -filter DIRECTION==OUT]
         puts "Processing Output Pins of cell $cell ([llength $outputs] pins)"
         if {$debug} {
            set count 0
         }
         foreach pin [lsort -dict $outputs] {
            if {$debug} {
               if {$count==10} {
                  break
               }
               incr count
               puts "pin$count: $pin"
            }
            set HD_LUT [get_cells -quiet -of [get_pins -quiet -leaf -filter NAME=~$cell/HD_PR* -of [get_nets -quiet -of [get_pins $pin]]]]
            if {[llength $HD_LUT]} {
               #Set a DC on LUT initially to prevent constant propagation, or no timing paths will be found, and all_fanout will return 0 endpoints
               set_logic_dc  [get_pins $HD_LUT/I0]
               #Get the cell names and filter out GTs, OBUF, etc.
               set endPointCells [get_cells -quiet -filter $filter [all_fanout -quiet -endpoints_only -flat -only_cells $pin]]
               set clockPins [get_pins -quiet -filter IS_CLOCK -of $endPointCells]
               set clocks [get_clocks -quiet -of $clockPins]
               if {[llength $clocks]} {
                  #Add set_logic_dc to XDC or set_max_delay on outputs wont't work. Only set once on pins with endpoints.
                  foreach clock $clocks {
                     set timingPaths [get_timing_paths -quiet -through [get_pins $pin] -to $endPointCells -filter ENDPOINT_CLOCK==$clock]
                     if {![llength $timingPaths]} {
                         puts "\tCritical Warning: No timing path found through pin $pin for clock $clock." 
                        continue
                     }
                     set endPointPins [get_pins -quiet [get_property ENDPOINT_PIN $timingPaths] -filter $filter]
                     set period [get_property PERIOD [get_clocks $clock]]
                     set_max_delay -datapath_only -from [get_pins $HD_LUT/O] -to [get_pins [list $endPointPins]] $period
                     set timing_path [get_timing_path -quiet -through $pin -to $endPointCells -max_paths 100000 -filter ENDPOINT_CLOCK==$clock]
                     set endClock    [get_property ENDPOINT_CLOCK $timing_path]
                     set requirement [get_property REQUIREMENT $timing_path]
                     set slack       [get_property SLACK $timing_path]
                     set levels      [get_property LOGIC_LEVELS $timing_path]
                     set totalDelay  [get_property DATAPATH_DELAY $timing_path]
                     #Check to see if array entry already exists. Add if not, and check that requirement matches if so
                     if {$debug} {
                        puts "DEBUG: key:${pin}.${clock} Requirement: $requirement Clock: $endClock"
                     }
                     if {[info exists pinDelays_${pblock}(${pin}.${clock})]} {
                        set checkRequirement [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 0]
                        if {$checkRequirement != $requirement} {
                           puts "Critical Warning: Requirement of $requirement for pin $pin of DCP $dcp is different from previous DCP with requirement of $checkRequirement$"
                        }
                        set checkClock [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 1]
                        if {$checkClock != $endClock} {
                           puts "Critical Warning: Clock $endClock for pin $pin of DCP $dcp is different from previous DCP with clock of $checkClock"
                           set pinDelays_${pblock}(${pin}.${clock}) [lreplace [set pinDelays_${pblock}\(${pin}.${clock}\)] 1 1 $endClock]
                        }
                        #lappend pinDelays_${pblock}(${pin}.${clock}) [list [list $slack $levels $totalDelay $dcp]]
                        set pinDelays_${pblock}(${pin}.${clock}) [list [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 0] [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 1] [linsert [lindex [set pinDelays_${pblock}\(${pin}.${clock}\)] 2] 0 [list $slack $levels $totalDelay $dcp]]]
                     } else {
                        set pinDelays_${pblock}(${pin}.${clock}) [list $requirement $endClock [list [list $slack $levels $totalDelay $dcp]]]
                     }
                  }
               } elseif {[llength $clockPins]} {
                  puts "Critical Warning: Found [llength $clockPins] clock pins for loads of output pin $pin, but no clocks were defined. Ensure all required constraints have been defined." 
               }
            }
         }
      }
      puts "DEBUG: Closing project for $dcp"
      close_project
   }

   puts "\tPrinting Tables: Pblocks $pblocks"
   foreach pblock $pblocks {
      if {$debug} {
         puts "DEBUG: Printing Table for $pblock"
         puts [array get pinDelays_${pblock}]
      }
      set totalDCPs [llength $DCPs]
      set title "-title {#HD: Interface timing analysis}"
      set table " -row {\"Pin\" \"Clock\" \"Requirement\" \"Slack\" \"Levels\" \"Delay\" \"DCP\"}"
      set indexCount 1
      foreach {pin} [lsort -dict [array names pinDelays_${pblock}]] {
         set pinName [lindex [split $pin "."] 0]
         set data [lindex [array get pinDelays_${pblock}] $indexCount]
         lassign $data requirment clock timing
         foreach value $timing {
            lassign $value slack levels totalDelay dcp
            append table " -row {$pinName $clock $requirement $slack $levels $totalDelay $dcp}"
         }
         set indexCount [expr $indexCount + 2]
      }

      set table ${title}${table}
      if {[string match $file "STDOUT"]} {
         print_table $table
      } else {
         puts "Writing results to ${file}_${pblock}.rpt"
         print_table $table -file ${file}_${pblock}.rpt
      }
   }

   reset_msg_config -quiet -id "Constraints 18-514" -suppress
   reset_msg_config -quiet -id "Constraints 18-515" -suppress
   reset_msg_config -quiet -id "Constraints 18-402" -suppress
}


