###########################
#### Implement Modules ####
###########################
proc implement {impl} {
   global tclParams 
   global board
   global part
   global dcpLevel
   global verbose
   global implDir
   global xdcDir
   global dcpDir
   global RFH

   set top                 [get_attribute impl $impl top]
   set name                [get_attribute impl $impl name]
   set implXDC             [get_attribute impl $impl implXDC]
   set cellXDC             [get_attribute impl $impl cellXDC]
   set cores               [get_attribute impl $impl cores]
   set ip                  [get_attribute impl $impl ip]
   set ipRepo              [get_attribute impl $impl ipRepo]
   set hd                  [get_attribute impl $impl hd.impl]
   set dfx                 [get_attribute impl $impl dfx.impl]
   set hd.budget           [get_attribute impl $impl hd.budget]
   set budgetExclude       [get_attribute impl $impl hd.budget_exclude]
   set partitions          [get_attribute impl $impl partitions]
   set link                [get_attribute impl $impl link]
   set opt                 [get_attribute impl $impl opt]
   set opt.pre             [get_attribute impl $impl opt.pre]
   set opt_options         [get_attribute impl $impl opt_options]
   set opt_directive       [get_attribute impl $impl opt_directive]
   set place               [get_attribute impl $impl place]
   set place.pre           [get_attribute impl $impl place.pre]
   set place_options       [get_attribute impl $impl place_options]
   set place_directive     [get_attribute impl $impl place_directive]
   set phys                [get_attribute impl $impl phys]
   set phys.pre            [get_attribute impl $impl phys.pre]
   set phys_options        [get_attribute impl $impl phys_options]
   set phys_directive      [get_attribute impl $impl phys_directive]
   set route               [get_attribute impl $impl route]
   set route.pre           [get_attribute impl $impl route.pre]
   set route_options       [get_attribute impl $impl route_options]
   set route_directive     [get_attribute impl $impl route_directive]
   set post_phys           [get_attribute impl $impl post_phys]
   set post_phys.pre       [get_attribute impl $impl post_phys.pre]
   set post_phys_options   [get_attribute impl $impl post_phys_options]
   set post_phys_directive [get_attribute impl $impl post_phys_directive]
   set bitstream           [get_attribute impl $impl bitstream]
   set bitstream.pre       [get_attribute impl $impl bitstream.pre]
   set bitstream_options   [get_attribute impl $impl bitstream_options]
   set bitstream_settings  [get_attribute impl $impl bitstream_settings]
   set drc.quiet           [get_attribute impl $impl drc.quiet]

#   if {($hd && $dfx)} {
#      set errMsg "\nERROR: Implementation $impl has more than one of the following flow variables set to 1"
#      append errMsg "\n\thd.impl($hd)\n\tdfx.impl($dfx)\n"
#      append errMsg "Only one of these variables can be set true at one time. To run multiple flows, create separate implementation runs."
#      error $errMsg
#   }

   set resultDir "$implDir/$impl"
   set reportDir "$resultDir/reports"

   #### Make the implementation directory, Clean-out and re-make the results directory
   command "file mkdir $implDir"
   command "file delete -force $resultDir"
   command "file mkdir $resultDir"
   command "file mkdir $reportDir"
   
   #### Open local log files
   set rfh [open "$resultDir/run.log" w]
   set cfh [open "$resultDir/command.log" w]
   set wfh [open "$resultDir/critical.log" w]

   set vivadoVer [version]
   puts $rfh "Info: Running Vivado version $vivadoVer"
   puts $RFH "Info: Running Vivado version $vivadoVer"

   command "puts \"#HD: Running implementation $impl\""
   puts "\tWriting results to: $resultDir"
   puts "\tWriting reports to: $reportDir"
   puts $rfh "\n#HD: Running implementation $impl"
   puts $rfh "Writing results to: $resultDir"
   puts $rfh "Writing reports to: $reportDir"
   puts $RFH "\n#HD: Running implementation $impl"
   puts $RFH "Writing results to: $resultDir"
   puts $RFH "Writing reports to: $reportDir"
   set impl_start [clock seconds]

   #### Set Tcl Params
   if {[info exists tclParams] && [llength $tclParams] > 0} {
      set_parameters $tclParams
   }

   #### Create in-memory project
   command "create_project -in_memory -part $part" "$resultDir/create_project.log"
   if {[info exists board] && [llength $board]} {
      command "set_property board_part $board \[current_project\]"
   }   

   #### Setup any IP Repositories 
   if {$ipRepo != ""} {
      puts "\tLoading IP Repositories:\n\t+ [join $ipRepo "\n\t+ "]"
      command "set_property IP_REPO_PATHS \{$ipRepo\} \[current_fileset\]" "$resultDir/temp.log"
      command "update_ip_catalog" "$resultDir/temp.log"
   }

   ###########################################
   # Linking
   ###########################################
   if {$link} {
      #Determine state of Top (import or implement). 
      set topState "implement"
      foreach partition $partitions {
         lassign $partition module cell state name type level dcp
         if {[string match $cell $top]} {
            set topState $state 
            if {[llength $dcp]} {
               set topFile $dcp
            }
         }
      }

      #If DCP for top is not defined in Partition settings, try and find it.
      if {![info exist topFile] || ![llength $topFile]} {
         foreach module [get_modules] {
            set moduleName [get_attribute module $module moduleName]
            if {[string match $top $moduleName]} {
               break
            }
         }
         if {[string match $topState "implement"]} {
            set topFile [get_module_file $module]
         } elseif {[string match $topState "import"]} {
            if {$dfx} {
               set topFile "$dcpDir/${top}_static.dcp"
            } else {
               set topFile "$dcpDir/${top}_routed.dcp"
            }
         } else {
            set errMsg "\nERROR: State of Top module $top is set to illegal state $topState." 
            error $errMsg
         }
      }

      #Add file if it exists, or if $verbose=0 for testing
      if {[file exists $topFile] || !$verbose} {
         set type [lindex [split $topFile .] end]
         puts "\t#HD: Adding \'$type\' file $topFile for $top"
         command "add_files $topFile"
      } else {
         set errMsg "\nERROR: Specified file $topFile cannot be found on disk. Verify path is correct, and that all dependencies have been run." 
         error $errMsg
      }
   
      ####Read in top-level cores/ip/XDC if Top is being implemented
      ####All Partition core/ip/XDC should be defined as Module attributes
      if {[string match $topState "implement"]} { 
         # Read in IP Netlists 
         if {[llength $cores] > 0} {
            add_cores $cores
         }
         # Read IP XCI files
         if {[llength $ip] > 0} {
            add_ip $ip
         }

         # Read in XDC files
         if {[llength $implXDC] > 0} {
            if {[string match $topState "implement"]} {
               add_xdc $implXDC
            } else {
               puts "\tInfo: Skipping top-level XDC files because $top is set to $topState."
            }
         } else {
            puts "\tWarning: No top-level XDC files were specified."
         }
      }

      ####Always read in RP/RM specific XDC files
      if {[llength $cellXDC] > 0} {
         foreach data $cellXDC {
            lassign $data cell xdc 
            puts "\tAdding scoped XDC files for $cell"
            add_xdc $xdc 0 $cell
         }
      }

      ####Read in Partition netlist, cores, ip, and XDC if module is being implemented
      foreach partition $partitions {
         lassign $partition module cell state name type level dcp
         if {![llength $name]} {
            set name [lindex [split $cell "/"] end]
         }

         if {![string match "greybox" $state]} {
            set moduleName [get_attribute module $module moduleName]
         } else {
            set moduleName $module
         }

         #Process each partition that is not Top. Ignore greybox Partitions
         if {![string match $moduleName $top] && ![string match "greybox" $state]} {
            #Find correct file to be used for Partition
            if {[llength $dcp] && ![string match $state "greybox"]} {
               set partitionFile $dcp
            } else {
               #if partition has state=implement, load synth netlist
               if {[string match $state "implement"]} {
                  set partitionFile [get_module_file $module]
               } elseif {[string match $state "import"]} {
                  #TODO: Name used to be based on Pblock to uniquify. Now no open design with new link_design flow,
                  #      so no way to query Pblock name. This code will not work if RPs have same name at the end of hierarchy.
                  #      Project flow names these cell DCPs based of full hierachy name, which can have issues of its own
                  #      if the hierarchy name is very long.  Need to revisit to develop a solution.
                  set partitionFile "$dcpDir/${name}_${module}_route_design.dcp"
               } else {
                  set errMsg "\nERROR: Invalid state \"$state\" in settings for $name\($impl)."
                  append errMsg"Valid states are \"implement\", \"import\", or \"greybox\".\n" 
                  error $errMsg
               }

            }
            #Add the partition source file to the in-memory project
            if {![file exists $partitionFile] && $verbose} {
               set errMsg "ERROR: Partition \'$cell\' with state \'$state\' is set to use the file:\n$partitionFile\n\nThis file does not exist."
               error $errMsg
            }
            set fileSplit [split $partitionFile "."]
            set fileType [lindex $fileSplit end]
            set start_time [clock seconds]
            puts "\tAdding file $partitionFile for $cell ($module) \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
            command "add_file $partitionFile"
            #Check if file is an XCI. SCOPED_TO_CELLS not supported for XCI
            if {![string match [lindex [split $partitionFile .] end] "xci"]} {
               #Check if this file is already scoped to another partition
               if {[llength [get_property SCOPED_TO_CELLS [get_files $partitionFile]]]} {
                  set cells [get_property SCOPED_TO_CELLS [get_files $partitionFile]]
                  lappend cells $cell
                  command "set_property SCOPED_TO_CELLS \{$cells\} \[get_files $partitionFile\]"
               } else {
                  command "set_property SCOPED_TO_CELLS \{$cell\} \[get_files $partitionFile\]"
               }
            }

            #Add Module specific implementation sources   
            if {[string match $state "implement"]} { 
               #Read in Module IP if module is not imported or greybox
               set moduleIP [get_attribute module $module ip]
               if {[llength $moduleIP] > 0} {
                  puts "\tAdding module ip files for $cell ($module)"
                  add_ip $moduleIP
               }

               #Read in Module cores if module is not imported or greybox
               set moduleCores [get_attribute module $module cores]
               if {[llength $moduleCores] > 0} {
                  puts "\tAdding module core files for $cell ($module)"
                  add_cores $moduleCores
               }
            }

               #Read in scoped module impl XDC even if module is imported since routed cell DCPs won't have timing constraints
               set implXDC [get_attribute module $module implXDC]
               if {[llength $implXDC] > 0} {
                  puts "\tAdding scoped XDC files for $cell"
                  add_xdc $implXDC 0 $cell
               } else {
                  puts "\tInfo: No scoped XDC files specified for $cell"
               }
         }; #End: Process each partition that is not Top and not greybox
      }; #End: Foreach partition
   
      ###########################################################
      # Link the top-level design with no black boxes (unless greybox) 
      ###########################################################
      set start_time [clock seconds]
      puts "\t#HD: Running link_design for $top \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
      set partitionCells ""
      foreach partition $partitions {
         lassign $partition module cell state name type level dcp
         if {![string match $cell $top]} {
            lappend partitionCells $cell
         }
      }
      if {$dfx} {
         set linkCommand "link_design -mode default -reconfig_partitions \{$partitionCells\} -part $part -top $top"
         command $linkCommand "$resultDir/${top}_link_design.log"
      } elseif {$hd} {
         set linkCommand "link_design -mode default -partitions \{$partitionCells\} -part $part -top $top"
         command $linkCommand "$resultDir/${top}_link_design.log"
      } else {
         set linkCommand "link_design -mode default -part $part -top $top"
         command $linkCommand "$resultDir/${top}_link_design.log"
      }
      set end_time [clock seconds]
      log_time link_design $start_time $end_time 1 $linkCommand
      
      ##############################################
      # Process Grey Box Partitions 
      ##############################################
      foreach partition $partitions {
         lassign $partition module cell state name type level dcp
         if {![llength $name]} {
            set name [lindex [split $cell "/"] end]
         }

         if {![string match "greybox" $state]} {
            set moduleName [get_attribute module $module moduleName]
         } else {
            set moduleName $module
         }
         if {![string match $moduleName $top]} {
            if {[string match "greybox" $state]} {
               #If any greybox partition exist, need to run post-route DRC check in quiet mode
               set drc.quiet 1

               #Process greybox partitions. Name can be random, so just grab name from partition def.
               puts "\tInfo: Cell $cell will be implemented as a grey box."
               set partitionFile "NA"
   
               #Insert LUT1 for greybox partition
               if {$verbose && ![get_property IS_BLACKBOX [get_cells $cell]]} {
                  set start_time [clock seconds]
                  puts "\tCritical Warning: Partition cell \'$cell\' is not a blackbox. This likely occurred because OOC synthesis was not used. This can cause illegal optimization. Please verify it is intentional that this cell is not a blackbox at this stage in the flow.\nResolution: Caving out cell to make required blackbox. \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  command "update_design -cells $cell -black_box" "$resultDir/update_design_blackbox_$name.log"
                  set end_time [clock seconds]
                  log_time update_design $start_time $end_time 0 "Create blackbox for $name"
               }
               command "set_msg_config -quiet -id \"Constraints 18-514\" -suppress"
               command "set_msg_config -quiet -id \"Constraints 18-515\" -suppress"
               command "set_msg_config -quiet -id \"Constraints 18-402\" -suppress"
               set start_time [clock seconds]
               puts "\t#HD: Inserting LUT1 buffers on interface of $name \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               command "update_design -cells $cell -buffer_ports" "$resultDir/update_design_bufferport_$name.log"
               set end_time [clock seconds]
               log_time update_design $start_time $end_time 0 "Convert blackbox partition $name to greybox"
               set budgetXDC $xdcDir/${module}_budget.xdc
               if {![file exists $budgetXDC] || ${hd.budget}} {
                  set start_time [clock seconds]
                  puts "\t#HD: Creating budget constraints for greybox $name \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  create_partition_budget -cell $cell -file $budgetXDC -exclude $budgetExclude
                  set end_time [clock seconds]
                  log_time create_budget $start_time $end_time 0 "Create budget constraints for $name"
               }
               set start_time [clock seconds]
               readXDC $budgetXDC
               set end_time [clock seconds]
               log_time read_xdc $start_time $end_time 0 "Read in budget constraints for $name"
            }; #End: Process greybox partitions
         }; #End: Process each partition that is not Top
      }; #End: Foreach partition
   
      ##############################################
      # Lock imported Partitions 
      ##############################################
      foreach partition $partitions {
         lassign $partition module cell state name type level dcp
         if {![string match "greybox" $state]} {
            set moduleName [get_attribute module $module moduleName]
         } else {
            set moduleName $module
         }
         if {![string match $moduleName $top] && [string match $state "import"]} {
            if {![llength $level]} {
               set level "routing"
            }
            set start_time [clock seconds]
            puts "\tLocking $cell \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
            command "lock_design -level $level $cell" "$resultDir/lock_design_$name.log"
            set end_time [clock seconds]
            log_time lock_design $start_time $end_time 0 "Locking cell $cell at level routing"
         }; #End: Process each partition that is not Top
      }; #End: Foreach partition
      puts "\t#HD: Completed link_design"
      puts "\t##########################"

      ##############################################
      # Write out final link_design DCP 
      ##############################################
      if {$dcpLevel > 0} {
         set start_time [clock seconds]
         puts "\tWriting post-link_design checkpoint: $resultDir/${top}_link_design.dcp \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]\n"
         command "write_checkpoint -force $resultDir/${top}_link_design.dcp" "$resultDir/write_checkpoint.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Post link_design checkpoint"
      }

      if {$verbose > 1} {
         set start_time [clock seconds]
         puts "\tRunning report_utilization \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
         command "report_utilization -file $reportDir/${top}_utilization_link_design.rpt" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time report_utilization $start_time $end_time
      } 

      ##############################################
      # Run Methodology DRCs checks 
      ##############################################
      #Run methodology DRCs and catch any Critical Warnings or Error (module ruledeck quiet)
      if {$verbose > 1} {
         set start_time [clock seconds]
         check_drc $top methodology_checks 1
         set end_time [clock seconds]
         log_time report_drc $start_time $end_time 0 "methodology checks"
         #Run timing DRCs and catch any Critical Warnings or Error (module ruledeck quiet)
         set start_time [clock seconds]
         check_drc $top timing_checks 1
         set end_time [clock seconds]
         log_time report_drc $start_time $end_time 0 "timing_checks"
      }
   }; #END: if $link

   ############################################################################################
   # Implementation steps: opt_design, place_design, phys_opt_design, route_design
   ############################################################################################
   #Determine if all partitions (including top) are being imported
   set allImport 1
   foreach partition $partitions {
      lassign $partition module cell state name type level dcp
      if {![string match "import" $state]} { 
         set allImport 0
         break
      }
   }
   if {$allImport} {
      if {$hd} {
         set skipOpt 1
         set skipPlace 1
         set skipPhysOpt 1
         set skipRoute 0
      } elseif {$dfx} {
         set skipOpt 1
         set skipPlace 1
         set skipPhysOpt 1
         set skipRoute 1
      } else {
         set errMsg "\nERROR: Implementation has all partitions set to import, but supported partition flow not detected."
         lappend errMsg "\nVerify the either HD or DFX attribute is set to \'1\'."
         error $errMsg
      }
   } else {
      set skipOpt 0
      set skipPlace 0
      set skipPhysOpt 0
      set skipRoute 0
   }
   
   if {$opt && !$skipOpt} {
      impl_step opt_design $top $opt_options $opt_directive ${opt.pre}
   }

   if {$place && !$skipPlace} {
      impl_step place_design $top $place_options $place_directive ${place.pre}
   }

   if {$phys && !$skipPhysOpt} {
      impl_step phys_opt_design $top $phys_options $phys_directive ${phys.pre}
   }

   if {$route && !$skipRoute} {
      impl_step route_design $top $route_options $route_directive ${route.pre}
 
      if {$post_phys} {
         impl_step post_phys_opt $top $post_phys_options $post_phys_directive ${post_phys.pre}
      }

      #Run report_timing_summary on final design
      set start_time [clock seconds]
      puts "\tRunning report_timing_summary: $reportDir/${top}_timing_summary.rpt \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
      command "report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file $reportDir/${top}_timing_summary.rpt" "$resultDir/temp.log"
      set end_time [clock seconds]
      log_time report_timing $start_time $end_time 0 "Timing Summary"

      #Report DFX specific statitics for debug and analysis
      if {$dfx} {
         set start_time
         puts "\tRunning report_design_stauts: $reportDir/${top}_design_status.rpt \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
         command "debug::report_design_status" "$reportDir/${top}_design_status.rpt"
      }

      if {$verbose} {
         getTimingInfo
      }
      set impl_end [clock seconds]
      log_time final $impl_start $impl_end 
   }

   #For DFX, don't write out bitstreams until after PR_VERIFY has run. See run.tcl
   #For HD, run write_bitstream prior to creating blackbox or DRC errors will occur.
   if {$bitstream && !$dfx} {
      impl_step write_bitstream $top $bitstream_options none ${bitstream.pre} $bitstream_settings
   } else {
      #If skipping write_bitstream, run a final DRC that catches any Critical Warnings (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $top bitstream_checks ${drc.quiet}
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "bitstream_checks"
   }
   
   set extras_start [clock seconds]
   if {![file exists $dcpDir]} {
      command "file mkdir $dcpDir"
   }   

   if {$hd || $dfx} {
      #Write out cell checkpoints for all Partitions and create black_box 
      puts $rfh "\n#HD: Running implementation $impl"
      puts $RFH "\n#HD: Running implementation $impl"
      #Generate a new header for a table the first time through
      set header 1
      foreach partition $partitions {
         lassign $partition module cell state name type level dcp
         #Don't try to get moduleName for greybox Partitions as the name can be random
         if {![string match "greybox" $state]} { 
            set moduleName [get_attribute module $module moduleName]
         } else {
            set moduleName $module
         }
  
         if {![string match $moduleName $top]} {
            #Only write out cell DCPs for implemented cells
            if {([string match $state "implement"])} {
               if {![llength $name]} {
                  set name [lindex [split $cell "/"] end]
               }
               set start_time [clock seconds]
               set dcp "$resultDir/${name}_${module}_route_design.dcp"
               #Lock the netlist of the cell to prevent MLO optimizations when cell DCP is reused.
               #Cannot lock placement/routing at this stage, or the carver will not be able to remove the cell.
               command "lock_design -level logical -cell $cell" "$resultDir/lock_$name.log"
               command "write_checkpoint -force -cell $cell $dcp" "$resultDir/write_checkpoint.log"
               set end_time [clock seconds]
               log_time write_checkpoint $start_time $end_time $header "Write cell checkpoint for $cell"
               set header 0

               #BEGIN - TEST HD PARTITION IMPORT USING DFX 
               if {$hd && $dfx} {
                  #Post Process partition DCP to get rid of clock routes and PartPin info. 
                  puts "\tProcessing routed DCP for $cell to remove PhysDB for external clocks"
                  command "open_checkpoint $dcp" "$resultDir/open_checkpoint.log"
                  set clockNets [get_nets -filter TYPE==LOCAL_CLOCK]
                  foreach net $clockNets {
                     command "reset_property HD.PARTPIN_LOCS \[get_ports -of \[get_nets $net\]\]"
                  }
                  command "route_design -unroute -nets \[get_nets \{$clockNets\}\]" "$resultDir/${name}_unroute.log"
                  command "write_checkpoint -force $dcp" "$resultDir/write_checkpoint.log"
                  command "close_design"
               }
               #END - TEST HD PARTITION IMPORT USING DFX
               command "file copy -force $dcp $dcpDir"
            }

            #Carve out all implemented partitions if Top/Static was implemented
            if {[string match $topState "implement"]} {
               set start_time [clock seconds]
               puts "\tCarving out $cell to be a black box \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               #unlock cells before carving them if they were imported
               if {[string match $state "import"]} {
                  command "lock_design -unlock -level placement $cell" "$reportDir/unlock_$name.log"
               }
               command "update_design -cell $cell -black_box" "$resultDir/carve_$name.log"
               set end_time [clock seconds]
               log_time update_design $start_time $end_time $header "Carve out (blackbox) $cell"
               set header 0
            }
         }
      }
   }

   #Write out implemented version of Top for import in subsequent runs
   if {$dfx || $hd} {
      foreach partition $partitions {
         lassign $partition module cell state name type level dcp
         #Skip this step for greybox partitions to avoid errors in getting moduleName property
         if {[string match "greybox" $state]} { 
            continue
         }
         set moduleName [get_attribute module $module moduleName]
         if {[string match $moduleName $top] && [string match $state "implement"]} {
            set start_time [clock seconds]
            puts "\t#HD: Locking $top and exporting results \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
            command "lock_design -level routing" "$resultDir/lock_design_$top.log"
            set end_time [clock seconds]
            log_time lock_design $start_time $end_time 0 "Lock placement and routing of $top"
            if {$hd} {
               set topDCP "$resultDir/${top}_routed.dcp"
            }
            if {$dfx} {
               set topDCP "$resultDir/${top}_static.dcp"
            } 
            set start_time [clock seconds]
            command "write_checkpoint -force $topDCP" "$resultDir/write_checkpoint.log"
            command "file copy -force $topDCP $dcpDir"
            set end_time [clock seconds]
            log_time write_checkpoint $start_time $end_time 0 "Write out locked Static checkpoint"
         }
      }
   }

   set extras_end [clock seconds]
   log_time final $extras_start $extras_end 
   command "puts \"#HD: Implementation $impl complete\\n\""
   command "close_project"
   close $rfh
   close $cfh
   close $wfh
}
