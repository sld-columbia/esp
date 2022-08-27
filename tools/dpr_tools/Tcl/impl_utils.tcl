###############################################################
# Source scripts need for implementation
###############################################################
if {[info exists tclDir]} {
   source $tclDir/ooc_impl.tcl
   source $tclDir/implement.tcl
   source $tclDir/step.tcl
}
###############################################################
# Find netlist for specified module
###############################################################
proc get_module_file { module } {
   global synthDir
   global netlistDir
   
   if {![info exists synthDir]} {
      set synthDir "."
   }
   if {![info exists netlistDir]} {
      set netlistDir "."
   }

   set moduleName [get_attribute module $module moduleName]
   set synthDCP   [get_attribute module $module synthCheckpoint]
   set searchFiles [list $synthDCP \
                         $synthDir/$module/${moduleName}_synth.dcp  \
                         $netlistDir/$module/${moduleName}.edf      \
                         $netlistDir/$module/${moduleName}.edn      \
                         $netlistDir/$module/${moduleName}.ngc      \
                   ]
   set moduleFile ""
   foreach file $searchFiles {
      if {[file exists $file]} {
         set moduleFile $file
         break
      }
   } 
   if {![llength $moduleFile]} {
      set errMsg "\nERROR: No synthesis netlist or checkpoint file found for $module."
      append errMsg "\nSearched directories:"
      foreach file $searchFiles {
         append errMsg "\t$file\n"
      }
      error $errMsg
   }
   return $moduleFile
}

###############################################################
# Read in all implemented OOC modules
###############################################################
proc get_ooc_results { implementations } {
   global dcpLevel
   upvar resultDir resultDir

   foreach ooc $implementations {
      set instName       [get_attribute ooc $ooc inst]
      set hierInst       [get_attribute ooc $ooc hierInst]
      set readCheckpoint [get_attribute ooc $ooc implCheckpoint]
      set preservation   [get_attribute ooc $ooc preservation]
      set hd.isolated    [get_attribute ooc $ooc hd.isolated]

      if {![file exists $readCheckpoint]} {
         set errMsg "\nERROR: Specified OOC Checkpoint $readCheckpoint does not exist."
         error $errMsg
      }

      if {[get_property IS_BLACKBOX [get_cells $hierInst]} {
         puts "\tReading in checkpoint $readCheckpoint for $instName \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
         if {${hd.isolated}} {
            command "set_property HD.ISOLATED 1 \[get_cells $hierInst]"
         } else {
            command "set_property HD.PARTITION 1 \[get_cells $hierInst]"
         }
         set start_time [clock seconds]
         command "read_checkpoint -cell $hierInst $readCheckpoint -strict" "$resultDir/read_checkpoint_${instName}.log"
         set end_time [clock seconds]
         log_time read_checkpoint $start_time $end_time 0 "Resolve blacbox for $instName"
         if {[string match $preservation "logical"  ] || \
             [string match $preservation "placement"] || \
             [string match $preservation "routing"  ]} {
            set start_time [clock seconds]
            puts "\tLocking $hierInst \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
            command "lock_design -level $preservation $hierInst" "$resultDir/lock_design_$instName.log"
            set end_time [clock seconds]
            log_time lock_design $start_time $end_time 0 "Locking cell $hierInst at level $preservation"
         } elseif {[string match $preservation "none"] || [string match $preservation ""] } {
            puts "\tSkipping lock_design for $hierInst"
         } else {
            set errMsg "\nERROR: Unknown value \"$preservation\" specified for lock_design for cell $hierInst."
            error $errMsg
         }
      } else {
         puts "Cell $hierInst, implemented as OOC, is not a blackbox. OOC implementation results will not be used."
      }
   
      if {$dcpLevel > 1} {
         set start_time [clock seconds]
         command "write_checkpoint -force $resultDir/${instName}_link_design_intermediate.dcp" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Intermediate link_design checkpoint"
      }
   }
}
###############################################################
# Generate Partial ICAP/PCAP formated BIN files
# Must have Partial Bitstreams already generated
###############################################################
proc generate_pr_binfiles { config } {
   upvar bitDir bitDir

   set top           [get_attribute impl $config top]
   set partitions    [get_attribute impl $config partitions]
   set icap          [get_attribute impl $config cfgmem.icap]
   set pcap          [get_attribute impl $config cfgmem.pcap]
   set offset        [get_attribute impl $config cfgmem.offset]
   set size          [get_attribute impl $config cfgmem.size]
   set interface     [get_attribute impl $config cfgmem.interface]
   if {$icap || $pcap} {
      foreach partition $partitions {
         lassign $partition name cell state level dcp
         if {![string match $cell $top]} {
            set pblock [get_pblock -quiet -of [get_cells $cell]]
            set bitFile "$bitDir/${config}_${pblock}_partial.bit"
            if {![file exists $bitFile]} {
               puts "\tCritical Warning: No bit file found for $name in configuration $config. Skipping BIN file generation. Expected file \n\t$bitFile.\n\tRun write_bitstream first to generate the expected file."
               return 
            }
            if {$icap} {
               set logFile "$bitDir/write_cfgmem_${config}_${name}_icap.log"
               set msg "\t#HD: Generating ICAP formatted BIN file for $name of Configuration $config"
               command "puts \"$msg\""
               set start_time [clock seconds]
               set binFile "$bitDir/${config}_${pblock}_partial_icap.bin"
               #command "write_cfgmem -force -format BIN -interface $interface -loadbit \"$offset $bitFile\" -size $size $binFile" $logFile
               command "write_cfgmem -force -format BIN -interface $interface -loadbit \"$offset $bitFile\" $binFile" $logFile
               set end_time [clock seconds]
               log_time write_cfgmem $start_time $end_time 1 "Generate ICAP format bin file for ${config}(${name})"
            }
            if {$pcap} {
               set logFile "$bitDir/write_cfgmem_${config}_${name}_pcap.log"
               set msg "\t#HD: Generating PCAP formatted BIN file for $name of Configuration $config"
               command "puts \"$msg\""
               set start_time [clock seconds]
               set binFile "$bitDir/${config}_${pblock}_partial_pcap.bin"
               #command "write_cfgmem -force -format BIN -interface $interface -disablebitswap -loadbit \"$offset $bitFile\" -size $size $binFile" $logFile 
               command "write_cfgmem -force -format BIN -interface $interface -disablebitswap -loadbit \"$offset $bitFile\" $binFile" $logFile 
               set end_time [clock seconds]
               log_time write_cfgmem $start_time $end_time 1 "Generate PCAP format bin file for ${config}(${name})"
            }
         }
      }
   } else {
      puts "\tINFO: Skipping partial BIN file generation for Configuration $config."
   }
}

###############################################################
# Genearte Partial Bitstreams  
###############################################################
proc generate_pr_bitstreams { configs } {
   global dcpDir bitDir implDir

   #Set a default directory to write bitstreams if not already defined
   if {![info exists bitDir]} {
      set bitDir "./Bitstreams"
   }

   #command "file delete -force $bitDir"
   if {![file exists $bitDir]} {
      command "file mkdir $bitDir"
   }

   foreach config $configs {
      set top           [get_attribute impl $config top]
      set partitions    [get_attribute impl $config partitions]
      set bitstream     [get_attribute impl $config bitstream]
      set bitstream.pre [get_attribute impl $config bitstream.pre]
      set bitOptions    [get_attribute impl $config bitstream_options]
      set bitSettings   [get_attribute impl $config bitstream_settings]
      if {$bitstream} {
         set start_time [clock seconds]
         set msg "\t#HD: Running write_bitstream on $config"
         command "puts \"$msg\""
         set logFile "$bitDir/write_bitstream_${config}.log"
         foreach partition $partitions {
            lassign $partition name cell state level dcp
            if {[string match $cell $top]} {
               set configFile "$implDir/$config/${top}_route_design.dcp"
               if {[file exists $configFile]} {
                  command "open_checkpoint $configFile" "$bitDir/open_checkpoint_$config.log"
                  #Check for dbg_hub and write out probes
                  if {[llength [get_cells -quiet -hier -filter REF_NAME==dbg_hub_CV]]} {
                     command "write_debug_probes -force $bitDir/$config" "$bitDir/write_debug_probes_$config.log"
                  }

                  #Run any pre.hook scripts for write_bitstream
                  foreach script ${bitstream.pre} {
                     if {[file exists $script]} {
                        puts "\t#HD: Running pre-bitstream script $script"
                        command "source $script" "$bitDir/pre_bitstream_script.log"
                     } else {
                        set errMsg "\nERROR: Script $script specified for pre-bitstream does not exist"
                        error $errMsg
                     }
                  }
                  #Set any design level bistream properties
                  foreach setting $bitSettings {
                     puts "\tSetting property $setting"
                     command "set_property $setting \[current_design]"
                  }
                  command "write_bitstream -force $bitOptions $bitDir/$config" "$bitDir/$config.log"
               } else {
                  puts "\tERROR: The route_design DCP $configFile was not found for $config"
                  continue
               }
            }
         }
         set end_time [clock seconds]
         log_time write_bitstream $start_time $end_time 1 $config
         generate_pr_binfiles $config 
         command "close_project" "$bitDir/temp.log"
      } else {
         puts "\tSkipping write_bitstream for Configuration $config with attribute \"bitstream\" set to \'$bitstream\'"
      }
   }
}

###############################################################
# Create budget constraints on unsed RP pins 
###############################################################
proc pr_budget { cells } {
   set LUT_STRING1 "HD_PR*"
   set LUT_STRING2 "VCC_HD*"
   set LUT_STRING3 "GND_HD*"

   set_msg_config -id "Constraints 18-514" -suppress
   set_msg_config -id "Constraints 18-515" -suppress
   set_msg_config -id "Constraints 18-402" -suppress

   foreach cell $cells {
      puts "Processing Cell $cell:"
      set inputs [get_pins -of [get_cells $cell] -filter DIRECTION==IN]
      set outputs [get_pins -of [get_cells $cell] -filter DIRECTION==OUT]

      #Process Input Pins. Ignore clock pins tied to SIN LUT1 buffer, and capture active clock name
      #to be used during output pin processing.
      puts "\tProcessing input pins:"
      set count 0
      foreach pin $inputs {
         set HD_LUT [get_cells -quiet -of [get_pins -quiet -leaf -of [get_nets -quiet -of [get_pins $pin]] -filter "NAME=~$cell/$LUT_STRING1 || NAME=~$cell/$LUT_STRING2 || NAME=~$cell/$LUT_STRING3"]]
         set driver [get_property REF_NAME [get_cells -quiet -of [get_pins -quiet -leaf -of [get_nets -quiet -of [get_pins $pin]] -filter DIRECTION==OUT]]]
         if {[llength $HD_LUT] && ![string match "BUF*" $driver]} {
            #puts "\tSetting constraint on input pin: $pin ($HD_LUT)"
            set_max_delay -to [get_pins $HD_LUT/I0] 2
            incr count
         } elseif {![llength $HD_LUT] && [string match "BUF*" $driver]} {
            set clock [get_nets -boundary_type lower -of [get_pins $pin]]
            puts "\tFound active clock: $clock"
         } else {
            #puts "\tSkipping pin: $pin"
         }
      }
      puts "\tAdded $count input path segmentation constraints for $cell"
      #Check if an active clock was found in the RP. It doesn't really matter
      #which clock gets connected to the inserted output flow since we are creating
      #path segmentation constraints. However, an active clock must exist as non-active
      #clocks (connected to SIN buffer) have a DONT_TOUCH and can't be connected/modified.
      if {![info exists clock]} {
         set errMsg "Error: No active clock found in the RP $cell."
         error $errMsg
      } else {
         puts "\n\tUsing clock $clock for FDRE inserted on $cell\n"
      }

      #Process output pins. Insert a FF before each SOUT LUT1 buffer to prevent timing arcs
      #from being disabled by a constrant (LUT1 connected to GND).
      puts "\tProcessing output pins:"
      set count 0
      foreach pin $outputs {
         set HD_LUT [get_cells -quiet -of [get_pins -quiet -leaf -of [get_nets -quiet -of [get_pins $pin]] -filter "NAME=~$cell/$LUT_STRING1 || NAME=~$cell/$LUT_STRING2 || NAME=~$cell/$LUT_STRING3"]]
         if {[llength $HD_LUT]} {
            #puts "\tSetting constraint on output pin: $pin ($HD_LUT)"
            set HD_FF ${HD_LUT}_FF
            set HD_NET ${HD_LUT}_NET
            set HD_GND_NET [get_nets -of [get_pins $HD_LUT/I0]]
            disconnect_net -net $HD_GND_NET -objects [get_pins $HD_LUT/I0]
            create_cell $HD_FF -reference FDRE
            create_net $HD_NET
            connect_net -net $HD_NET -objects [get_pins [list $HD_LUT/I0 $HD_FF/Q]]
            connect_net -net $HD_GND_NET -objects [get_pins $HD_FF/D]
            connect_net -net $clock -objects [get_pins $HD_FF/C] 
            set_property DONT_TOUCH 1 [get_cells $HD_FF]
            set_property DONT_TOUCH 1 [get_nets $HD_NET]
            set_max_delay -datapath_only -from [get_pins $HD_FF/Q] 3
            incr count
         } else {
            #puts "\tSkipping pin: $pin"
         }
      }
      puts "\tAdded $count input path segmentation constraints for $cell"
   }
   reset_msg_config -quiet -id "Constraints 18-514" -suppress
   reset_msg_config -quiet -id "Constraints 18-515" -suppress
   reset_msg_config -quiet -id "Constraints 18-402" -suppress
}

###############################################################
# Verify all configurations 
###############################################################
proc verify_configs { configs } {
   global implDir

   #Compare Initial Configuration to all others
   set initialConfig [lindex $configs 0]
   set initialConfigTop [get_attribute impl $initialConfig top]
   set initialConfigFile $implDir/$initialConfig/${initialConfigTop}_route_design.dcp

   set numConfigs [llength $configs]
   set additionalConfigs ""
   set additionalConfigFiles ""
   for {set i 1} {$i < $numConfigs} {incr i} {
      set config [lindex $configs $i]
      set verify [get_attribute impl $config verify]
      if {$verify} {
         lappend additionalConfigs $config
         set configTop [get_attribute impl $config top]
         set configFile $implDir/$config/${configTop}_route_design.dcp
         lappend additionalConfigFiles $configFile
      } else {
         puts "\tSkipping pr_verify for Configuration $config with attribute \"verify\" set to \'$verify\'"
      }
   }
   
   if {[llength $additionalConfigFiles]} {
      set start_time [clock seconds]
      set msg "#HD: Running pr_verify between initial config $initialConfig and additional configurations $additionalConfigs"
      command "puts \"$msg\""
      set logFile "pr_verify_results.log"
      command "pr_verify -full_check -initial $initialConfigFile -additional \"$additionalConfigFiles\"" $logFile
      #Parse log file for errors or successful results
      if {[file exists $logFile]} {
         set lfh [open $logFile r]
         set log_data [read $lfh]
         close $lfh
         set log_lines [split $log_data "\n" ]
         foreach line $log_lines {
            if {[string match "*Vivado 12-3253*" $line] || [string match "*ERROR:*" $line]} {
               puts "$line"
            }
         }
      }
      set end_time [clock seconds]
      log_time pr_verify $start_time $end_time 1 "[llength $configs] Configurations"
   }
}

###############################################################
# Add all XDC files in list, and mark as OOC if applicable
###############################################################
proc add_xdc { xdc { synth 0} } {
   puts "\tAdding XDC files"
   #Flatten list if nested lists exist
   set files [join [join $xdc]]
   foreach file $files {
      if {[file exists $file]} {
         command "add_files $file"
         set file_split [split $file "/"]
         set fileName [lindex $file_split end]
         if { $synth ==2 || [string match "*synth*" $fileName] } { 
            if {[string match "*ooc*" $fileName]} {
               command "set_property USED_IN {synthesis out_of_context} \[get_files $file\]"
            } else {
               command "set_property USED_IN {synthesis} \[get_files $file\]"
            }
         } elseif { $synth==1 } {
            if {[string match "*ooc*" $fileName]} {
               command "set_property USED_IN {synthesis implementation out_of_context} \[get_files $file\]"
            } else {
               command "set_property USED_IN {synthesis implementation} \[get_files $file\]"
            }
         } else {
            if {[string match "*ooc*" $fileName]} {
               command "set_property USED_IN {implementation out_of_context} \[get_files $file\]"
            } else {
               command "set_property USED_IN {implementation} \[get_files $file\]"
            }
         }

         if {[string match "*late*" $fileName]} {
            command "set_property PROCESSING_ORDER late \[get_files $file\]"
         } elseif {[string match "*early*" $fileName]} {
            command "set_property PROCESSING_ORDER early \[get_files $file\]"
         }
      } else {
         set errMsg "\nERROR: Could not find specified XDC: $file" 
         error $errMsg 
      }
   }
}

###############################################################
# A proc to read in XDC files post link_design 
###############################################################
proc readXDC { xdc {cell ""} } {
   upvar resultDir resultDir

   puts "\tAdding XDC files"
   #Flatten list if nested lists exist
   set files [join [join $xdc]]
   foreach file $files {
      if {[file exists $file]} {
         if {![llength $cell]} {
            command "read_xdc $file" "$resultDir/read_xdc.log"
         } else {
            command "read_xdc -cell $cell $file" "$resultDir/read_xdc_cell.log"
         }
      } else {
         set errMsg "\nERROR: Could not find specified XDC: $file" 
         error $errMsg 
      }
   }
}

###############################################################
### Add all XCI files in list
###############################################################
proc add_ip { ips } {
   upvar resultDir resultDir

   foreach ip $ips {
      if {[string length ip] > 0} { 
         if {[file exists $ip]} {
            set ip_split [split $ip "/"] 
            set xci [lindex $ip_split end]
            set ipPathList [lrange $ip_split 0 end-1]
            set ipPath [join $ipPathList "/"]
            set ipName [lindex [split $xci "."] 0]
            command "add_files $ipPath/$xci"
            if {[get_property GENERATE_SYNTH_CHECKPOINT [get_files $ipPath/$xci]]} {
               if {![file exists $ipPath/${ipName}.dcp]} {
                  puts "\tSynthesizing IP $ipName"
                  command "synth_ip \[get_files $ipPath/$xci]" "$resultDir/${ipName}_synth.log"
               }
            } else {
               puts "\tGenerating output for IP $ipName"
               command "generate_target all \[get_ips $ipName]" "$resultDir/${ipName}_generate.log"
            }
         } else {
            set errMsg "\nERROR: Could not find specified IP file: $ip" 
            error $errMsg
         }
      }
   }
}

###############################################################
# Add all core netlists in list 
###############################################################
proc add_cores { cores } {
   puts "\tAdding core files"
   #Flatten list if nested lists exist
   set files [join [join $cores]]
   foreach file $files {
      if {[string length $file] > 0} { 
         if {![file exists $file]} {
            #Comment this out to prevent adding files 1 at a time. Add all at once instead.
            #command "add_files $file"
            set errMsg "\nERROR: Could not find specified IP netlist: $file" 
            error $errMsg
         }
      }
   }
   #Check to make sure file list is not empty
   if {[string length $files] > 0} { 
      command "add_files $files"
   }
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

#==============================================================
# TCL proc for running DRC on post-route_design to catch 
# Critical Warnings. These will be errors in write_bitstream. 
# Catches unroutes, antennas, etc. 
#==============================================================
proc check_drc { module {ruleDeck all} {quiet 0} } {
   upvar reportDir reportDir

   if {[info exists reportDir]==0} {
      set reportDir "."
   }
   puts "\tRunning report_drc with ruledeck $ruleDeck.\n\tResults saved to $reportDir/${module}_drc_$ruleDeck.rpt" 
   command "report_drc -ruledeck $ruleDeck -name $module -file $reportDir/${module}_drc_$ruleDeck.rpt" "$reportDir/temp.log"
   set Advisories   [get_drc_violations -quiet -name $module -filter {SEVERITY=~"Advisory"}]
   set Warnings     [get_drc_violations -quiet -name $module -filter {SEVERITY=~"Warning"}]
   set CritWarnings [get_drc_violations -quiet -name $module -filter {SEVERITY=~"Critical Warning"}]
   set Errors       [get_drc_violations -quiet -name $module -filter {SEVERITY=~"Error"}]
   puts "\tAdvisories: [llength $Advisories]; Warnings: [llength $Warnings]; Critical Warnings: [llength $CritWarnings]; Errors: [llength $Errors];"

   if {[llength $Errors]} {
      if {!$quiet} {
         set errMsg "\nERROR: DRC found [llength $Errors] errors ($Errors)."
      } else {
         puts "\tCritical Warning: DRC found [llength $Errors] errors ($Errors)."
      }
      foreach error $Errors {
         puts "\n\t${error}: [get_property DESCRIPTION [get_drc_violations -name $module $error]]"
      }
      #Stop the script for Errors, unless user specifies quiet as true
      if {!$quiet} {
         error $errMsg
      }
   }

   if {[llength $CritWarnings]} {
      if {!$quiet} {
         set errMsg "\nERROR: DRC found [llength $CritWarnings] Critical Warnings ($CritWarnings)."
      } else {
         puts "\tCritical Warning: DRC found [llength $CritWarnings] Critical Warnings ($CritWarnings)."
      }
      foreach cw $CritWarnings {
         puts "\n\t${cw}: [get_property DESCRIPTION [get_drc_violations -name $module $cw]]"
      }
      #Stop the script for Critcal Warnings, unless user specifies quiet as true
      if {!$quiet} {
         error $errMsg
      }
   }
}

#==============================================================
# TCL proc for Checking if a cell's pins have PartPins.
# Not all pins should have PartPins (clocks, etc) so filter out 
#==============================================================
proc get_bad_pins { cell } {
   set noPP_pins [get_pins -of [get_cells $cell] -filter "HD.ASSIGNED_PPLOCS!~*INT* && HD.ASSIGNED_PPLOCS!~*INT*"]
   set io_pins [get_pins -of [get_nets -of [get_cells -hier -filter LIB_CELL=~*BUF*]] -filter PARENT_CELL==$cell]
   set count 0
   set clock_pins ""
   set bad_pins ""
   foreach pin $noPP_pins {
      set clock [get_clocks -quiet -of [get_pins $pin]]
      if { [lsearch -exact $io_pins $pin]!="-1" } {
  #       puts "Found match: $pin"
      } else {
         if { $clock!=""} {
  #          puts "Found clock: $pin"
            lappend clock_pins $pin
         } else {
  #          puts "No match found: $pin"
            lappend bad_pins $pin
         }
      }
   }
   puts "[join $bad_pins "\n"]"
   puts "\nTotal Number of pins without PP: [llength $noPP_pins]"
   puts "Total Number of pins connected to buffers: [llength $io_pins]"
   puts "Total Number of clock pins: [llength $clock_pins]"
   puts "Total Number of \"bad\" pins: [llength $bad_pins]"
}

#==============================================================
# TCL proc for Checking if a cell's ports have PartPins.
# Not all pins should have PartPins (clocks, etc) so filter out 
#==============================================================
proc get_bad_ports { } {
   set noPP_ports [get_ports -filter "HD.PARTPIN_LOCS!~*INT* && HD.ASSIGNED_PPLOCS!~*INT*"]
   set io_ports [get_ports -of [get_nets -of [get_cells -hier -filter LIB_CELL=~*BUF*]]]
   set count 0
   set clock_ports ""
   set bad_ports ""
   foreach port $noPP_ports {
      set clock [get_clocks -quiet -of [get_ports $port]]
      if { [lsearch -exact $io_ports $port]!="-1" } {
   #      puts "Found match: $port"
      } else {
         if { $clock!=""} {
   #         puts "Found clock: $port"
             lappend clock_ports $port
         } else {
   #         puts "No match found: $port"
            lappend bad_ports $port
         }
      }
   }
   puts "[join $bad_ports "\n"]"
   puts "\nTotal Number of ports without PP: [llength $noPP_ports]"
   puts "Total Number of ports connected to buffers: [llength $io_ports]"
   puts "Total Number of clock ports: [llength $clock_ports]"
   puts "Total Number of \"bad\" ports: [llength $bad_ports]"
}

#==============================================================
# TCL proc for inserting a proxy flop (FDCE) connection on 
# blackboxes. 
# - Allows for black box support in implementation by creating grey box. 
# - Marks the cell as HD.PARTITION to prevent optimization
# - Attempts to connect the proxy to the correct clock domain,
#   but connects it to the fist clock in the list if it can't
#==============================================================
proc insert_proxy_flop { cell } {

   if {[get_property IS_BLACKBOX [get_cells $cell]] == 0} {
      puts "ERROR: Specified cell $cell is not a blackbox.\nThe Tcl proc insert_proxy_flop can only be run on a cell that is a black box. Specify a black box cell, or run \'update_design -cell $cell -black_box\' prior to running this command."
      return 1
   }

   set all_in_pins [lsort [get_pins -of [get_cells $cell] -filter DIRECTION==IN]]
   set all_out_pins [lsort [get_pins -of [get_cells $cell] -filter DIRECTION==OUT]]
   #### Get a list of all clock pins (driver is a BUFG, BUFR, BUFH, etc)
   foreach inpin $all_in_pins {
      #Get the leaf level driver of the input pin
      set driver [get_cells -quiet -of [get_pins -quiet -leaf -of [get_nets -of [get_pins $inpin]] -filter DIRECTION==OUT]]
      #Check for direct connects to ports
      set port [get_ports -quiet -of [get_nets -of [get_pins $inpin]]]
      if {![llength $driver] || [llength $port] || [string match "GND" $driver] || [string match "VCC" $driver] } {
         puts "Info: No synchronous driver found for input pin $inpin. Skipping insertion."
         continue
      }
      if {[string match -nocase "BUF*" [get_property -quiet LIB_CELL [get_cells -quiet $driver]]]} {
         lappend clocks $inpin 
      } else {
         lappend in_pins $inpin
      }
   }
   puts "Found [llength $clocks] clock pins."
   puts "Found [llength $in_pins] active input pins."
   foreach clock $clocks {
      puts "Creating clock net \"$clock\""
      create_net $clock
      connect_net -net $clock -objects "$clock"
   }

   ####Process input pins, minus those driven by BUFG
   puts "Inserting Proxy Flops for input pins"
   foreach inpin $in_pins {
      create_cell -reference FDCE ${inpin}_PROXY
      create_net $inpin
      connect_net -net $inpin -objects "$inpin ${inpin}_PROXY/D"
      set endpoints [get_cells -quiet -of [all_fanin -quiet -startpoints_only -flat [get_pins $inpin]]]
      set foundClock 0
      foreach endpoint $endpoints {
         #If the element is sequential 
         if {[get_property -quiet IS_SEQUENTIAL [get_cells -quiet $endpoint]]} {
            #puts "Found sequential driver \"$endpoint\" for pin $inpin"
            set driver_clock [get_nets -quiet [get_nets -quiet -segments -of [get_pins -of [get_cells $endpoint] -filter IS_CLOCK]] -filter NAME=~$cell/*]
            if {[llength $driver_clock] > 0 && [lsearch $clocks [lindex $driver_clock 0]] >= 0} {
               #puts "\tFound clock connections: $driver_clock"
               connect_net -net [lindex $driver_clock 0] -objects "${inpin}_PROXY/C"
               set foundClock 1
               break
            }
         } 
      }
      if {$foundClock == 0} {
         #Connect the inserted flop to the first clock in the list if the above fails 
         puts "Info: No common clock connection found for input pin $inpin. Removing inserted flop."
         remove_net $inpin 
         remove_cell ${inpin}_PROXY
      }
   }

   ####Process output pins
   puts "\nFound [llength $all_out_pins] output pins."
   puts "Inserting Proxy Flops for output pins"
   #Create a local GND cell to tie-off output flops.
   create_cell $cell/GND -reference GND
   create_net $cell/<const0>
   connect_net -net $cell/<const0> -objects $cell/GND/G
   foreach outpin $all_out_pins {
      create_cell -reference FDCE ${outpin}_PROXY
      create_net $outpin
      connect_net -net $outpin -objects "$outpin ${outpin}_PROXY/Q"
      #Tie off input to inserted output flop
      connect_net -net $cell/<const0> -objects "${outpin}_PROXY/D"
      set endpoints [get_cells -quiet -of [all_fanout -quiet -endpoints_only -flat [get_pins $outpin]]]
      #Check for direct connects to ports
      append endpoints [get_ports -quiet -of [get_nets -quiet -of [get_pins $outpin]]]
      if {![llength $endpoints]} {
         puts "Info: No loads found for output pin $outpin"
      }
      set foundClock 0
      foreach endpoint $endpoints {
         set load [get_property -quiet IS_SEQUENTIAL [get_cells -quiet $endpoint]]
         if {[llength $load]} {
            #puts "Found sequential load \"$endpoint\" for pin $outpin"
            set load_clock [get_nets -quiet [get_nets -quiet -segments -of [get_pins -of [get_cells $endpoint] -filter IS_CLOCK]] -filter NAME=~$cell/*]
            if {[llength $load_clock] > 0 && [lsearch $clocks [lindex $load_clock 0]] >= 0} {
               #puts "\tFound clock connections: $load_clock"
               connect_net -net [lindex $load_clock 0] -objects "${outpin}_PROXY/C"
               set foundClock 1
               break
            }
         }
      }
      if {$foundClock == 0} {
         #Connect the inserted flop to the first clock in the list if the above fails 
         puts "Info: No common clock connection found for output pin $outpin. Removing inserted flop."
         remove_net $outpin
         remove_cell ${outpin}_PROXY
      }
   }
   set_property HD.PARTITION 1 [get_cells $cell]
}

#==============================================================
# TCL proc for print out rule information for given ruledecks 
# Use get_drc_ruledecks to list valid ruledecks
#==============================================================
proc printRuleDecks { {decks ""} } {
   if {[llength $decks]} {
      set rules [get_drc_checks -of [get_drc_ruledecks $decks]]
      foreach rule $rules {
         set name [get_property NAME [get_drc_checks $rule]]
         set description [get_property DESCRIPTION [get_drc_checks $rule]]
         set severity [get_property SEVERITY [get_drc_checks $rule]]
         puts "\t${name}(${severity}): ${description}"
      }
   } else {
      puts "Rule Decks:\n\t[join [get_drc_ruledecks] "\n\t"]"
   }
}

#==============================================================
# TCL proc for print out rule information for given rules
#==============================================================
proc printRules { rules } {
   foreach rule $rules {
      set name [get_property NAME [get_drc_checks $rule]]
      set description [get_property DESCRIPTION [get_drc_checks $rule]]
      set severity [get_property SEVERITY [get_drc_checks $rule]]
      puts "\t${name}(${severity}): $description"
   }
}
