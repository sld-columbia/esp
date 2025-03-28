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
   show_objects -name RPs $rps
   return $rps
}

#==============================================================
# TCL proc for changing current value of HD.RECONFIGURABLE 
#==============================================================
proc toggle_dfx { cells } {
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

#######################################################
#Tcl proc to export either all or specified PartPins to
# STDOUT or to a specified file.
#######################################################
proc export_partpins { args } {
   set FH "stdout"
   set pins [get_pins -hier * -filter HD.ASSIGNED_PPLOCS!=""]

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
#Tcl proc to resize all Pblocks with SNAPPING_MODE to 
#the DERIVED_RANGES 
#######################################################
proc convert_pblocks {} {

   set filter "SNAPPING_MODE!=\"\" && SNAPPING_MODE!=OFF"
   set pblocks [get_pblocks -filter $filter]
   foreach pblock $pblocks {
      resize_pblock $pblock -add [get_property DERIVED_RANGES $pblock] -replace
   }
}

#==============================================================
# TCL proc for getting number of reporting RP/Static sites 
#==============================================================
proc get_static_sites {} {
   set sliceTotal [llength [get_sites SLICE*]]
   set sliceExclude [llength [get_sites SLICE* -of [get_pblocks -filter EXCLUDE_PLACEMENT]]]

   puts "Total Slices: $sliceTotal"
   puts "Slices Excluded: $sliceExclude"
   puts "-----------------------------"
   puts "Static Slices: [expr $sliceTotal - $sliceExclude]"
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
#   return $clockNets
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

#########################################
# Proc to find nets with connection to 
# pins of the specified cells. Intended
# to find commone connections between 2 RPs
# but maybe useful for other analysis.
#########################################
proc get_common_nets { cells } {
   array set netPins {}
   foreach cell $cells {
      set pins [lsort -dict [get_pins -of [get_cells $cell]]]
      foreach pin $pins {
         set net [get_nets -quiet -top -of $pin]
         if {[llength $net]} {
            lappend netPins($net) "${pin}([get_property DIRECTION $pin])"
         }
      }
   }
   #return [array get netPins]
   set count 0
   foreach net [lsort -dict [array names netPins]] {
      set pins $netPins($net)
      if {[llength $pins] > 1 && ![string match "<const*>" $net]} { 
         incr count
         puts "${net}([llength $pins]): [lsort -dict $pins]"
      }
   }
   puts "Found $count nets with multiple PartPins"
}

#########################################
# Proc to print out port information of an RM
# For buses it only captures one entry with bus info
# Can run on a list of ports(OOC) or pins(in-context)
#########################################
proc rp_port_info { ports } {

   array set unique_ports {}
   foreach port [lsort -dict $ports] {
      set busName [get_property BUS_NAME $port]
      set busWidth [get_property BUS_WIDTH $port] 
      set direction [get_property DIRECTION $port]
      if {[llength $busName]} {
         set unique_ports($busName) "$busName $busWidth $direction"
      } else {
         set unique_ports($port) "$port 0 $direction"
      }
   }

   set table {-title RP Ports -row \{Port Width Direction\}}
   foreach {port info} [lsort [array get unique_ports]] {
      lassign $info name width direction
      lappend table "-row \{$name $width $direction\}"
   }
   puts [join $table]
   print_table [join $table]
}

#################################################
# Proc to unlock routing all placment except IOB, Phaser, clocks, etc 
#################################################
proc dfx_unlock {} {
   lock_design -unlock -level routing
   set_property IS_LOC_FIXED 0 [get_cells -hier -filter {(PRIMITIVE_LEVEL!=INTERNAL && PRIMITIVE_LEVEL!=MACRO && PRIMITIVE_LEVEL!="") && (REF_NAME=~FD* || REF_NAME=~LUT* || REF_NAME=~SRL* || REF_NAME=~CARRY* || REF_NAME=~MUX*)}]
   set_property IS_BEL_FIXED 0 [get_cells -hier -filter {(PRIMITIVE_LEVEL!=INTERNAL && PRIMITIVE_LEVEL!=MACRO && PRIMITIVE_LEVEL!="") && (REF_NAME=~FD* || REF_NAME=~LUT* || REF_NAME=~SRL* || REF_NAME=~CARRY* || REF_NAME=~MUX*)}]
   set_property IS_LOC_FIXED 0 [get_cells -hier -filter {(PRIMITIVE_LEVEL==MACRO) && (REF_NAME=~RAM* || REF_NAME=~LUT*)}]
   set_property IS_BEL_FIXED 0 [get_cells -hier -filter {(PRIMITIVE_LEVEL==MACRO) && (REF_NAME=~RAM* || REF_NAME=~LUT*)}]
   set_property IS_LOC_FIXED 0 [get_cells -hier -filter {(PRIMITIVE_LEVEL==LEAF) && (REF_NAME=~RAMB* || REF_NAME=~FIFO*)}]
   set_property IS_BEL_FIXED 0 [get_cells -hier -filter {(PRIMITIVE_LEVEL==LEAF) && (REF_NAME=~RAMB* || REF_NAME=~FIFO*)}]
}

#################################################
# Proc to unroute/unplace unlocked nets/cells, and reset HD.PARTPIN_* 
#################################################
proc dfx_unplace {} {
   route_design -unroute
   place_design -unplace
   set cells [get_cells -quiet -hier -filter HD.RECONFIGURABLE]
   foreach cell $cells {
      reset_property HD.PARTPIN_LOCS [get_pins $cell/*]
      reset_property HD.PARTPIN_RANGE [get_pins $cell/*]
   }
}

#################################################
# Proc to reset HD.PARTPIN_* 
#################################################
proc reset_partpins {} {
   set cells [get_cells -quiet -hier -filter HD.RECONFIGURABLE]
   foreach cell $cells {
      reset_property HD.PARTPIN_LOCS [get_pins $cell/*]
      reset_property HD.PARTPIN_RANGE [get_pins $cell/*]
   }
}

