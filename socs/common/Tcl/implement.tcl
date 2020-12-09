###########################
#### Implement Modules ####
###########################
proc implement {impl} {
   global tclParams 
   global part
   global dcpLevel
   global verbose
   global implDir
   global xdcDir
   global dcpDir
   global ooc_implementations 

   set top                 [get_attribute impl $impl top]
   set implXDC             [get_attribute impl $impl implXDC]
   set linkXDC             [get_attribute impl $impl linkXDC]
   set cores               [get_attribute impl $impl cores]
   set ip                  [get_attribute impl $impl ip]
   set ipRepo              [get_attribute impl $impl ipRepo]
   set hd                  [get_attribute impl $impl hd.impl]
   set td                  [get_attribute impl $impl td.impl]
   set pr                  [get_attribute impl $impl pr.impl]
   set ic                  [get_attribute impl $impl ic.impl]
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
   set bitstream           [get_attribute impl $impl bitstream]
   set bitstream.pre       [get_attribute impl $impl bitstream.pre]
   set bitstream_options   [get_attribute impl $impl bitstream_options]
   set bitstream_settings  [get_attribute impl $impl bitstream_settings]
   set drc.quiet           [get_attribute impl $impl drc.quiet]

   if {($hd && $td) || ($hd && $ic) || ($td && $ic) || ($pr && $hd) || ($pr && $ic) || ($pr && $td)} {
      set errMsg "\nERROR: Implementation $impl has more than one of the following flow variables set to 1"
      append errMsg "\n\thd.impl($hd)\n\ttd.impl($td)\n\tic.impl($ic)\n\tpr.impl($pr)\n"
      append errMsg "Only one of these variables can be set true at one time. To run multiple flows, create separate implementation runs."
      error $errMsg
   }

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

   command "puts \"#HD: Running implementation $impl\""
   puts "\tWriting results to: $resultDir"
   puts "\tWriting reports to: $reportDir"
   set impl_start [clock seconds]

   #### Set Tcl Params
   if {[info exists tclParams] && [llength $tclParams] > 0} {
      set_parameters $tclParams
   }

   #### Create in-memory project
   command "create_project -in_memory -part $part" "$resultDir/create_project.log"
   
   #### Setup any IP Repositories 
   if {$ipRepo != ""} {
      puts "\tLoading IP Repositories:\n\t+ [join $ipRepo "\n\t+ "]"
      command "set_property IP_REPO_PATHS \{$ipRepo\} \[current_fileset\]" "$resultDir/temp.log"
      command "update_ip_catalog" "$resultsDir/temp.log"
   }

   ###########################################
   # Linking
   ###########################################
   if {$link} {
      #Determine state of Top (import or implement). 
      set topState "implement"
      foreach partition $partitions {
         lassign $partition module cell state level dcp
         if {[string match $cell $top]} {
            set topState $state 
            if {[llength $dcp]} {
               set topFile $dcp
            }
         }
      }

      #If DCP for top is not defined in Partition settings, try and find it.
      if {![info exist topFile] || ![llength $topFile]} {
         set module [get_modules top_level]
         if {[string match $topState "implement"]} {
            set topFile [get_module_file $module]
         } elseif {[string match $topState "import"]} {
            if {$pr} {
               set topFile "$dcpDir/${top}_static.dcp"
            } else {
               set topFile "$dcpDir/${top}_routed.dcp"
            }
         } else {
            set errMsg "\nERROR: State of Top module $top is set to illegal state $topState." 
            error $errMsg
         }
      }

      puts "\t#HD: Adding file $topFile for $top"
      if {[info exists topFile]} {
         command "add_files $topFile"
      } else {
         set errMsg "\nERROR: Specified file $topFile cannot be found on disk. Verify path is correct." 
         error $errMsg
      }
   
      ####Read in top-level cores, ip,  and XDC on if Top is being implemented
      if {[string match $topState "implement"]} { 
         # Read in IP Netlists 
         if {[llength $cores] > 0} {
            add_cores $cores
         }
         # Read IP XCI files
         if {[llength $ip] > 0} {
            set start_time [clock seconds]
            add_ip $ip
            set end_time [clock seconds]
            log_time add_ip $start_time $end_time 0 "Add XCI files and generate/synthesize IP"
         }
         # Read in XDC files
         if {[llength $implXDC] > 0 && [string match $topState "implement"]} {
            add_xdc $implXDC
         } else {
            if {[string match $topState "implement"]} {
               puts "\tINFO: Skipping top-level XDC files because $top is set to $topState"
            } else {
               puts "\tINFO: No pre-link_design XDC file specified for $impl"
            }
         }
      }
   
      ###########################################################
      # Link the top-level design with black boxes for Partitions 
      ###########################################################
      set start_time [clock seconds]
      puts "\t#HD: Running link_design for $top \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
      command "link_design -mode default -part $part -top $top" "$resultDir/${top}_link_design.log"
      set end_time [clock seconds]
      log_time link_design $start_time $end_time 1 "link_design -part $part -top $top"
   
      ##############################################
      # Resolve Partitions 
      ##############################################
      foreach partition $partitions {
         lassign $partition module cell state level dcp

         #Process each partition that is not Top
         set moduleName [get_attribute module $module moduleName]
         set name [lindex [split $cell "/"] end]
         if {![string match $moduleName $top]} {
            #Set appropriate HD.* property if Top/Static is being implemented
            if {[string match $topState "implement"]} {
               if {$pr} {
                  command "set_property HD.RECONFIGURABLE 1 \[get_cells $cell]"
               } else {
                  command "set_property HD.PARTITION 1 \[get_cells $cell]"
               }
            }

            #Find correct file to be used for Partition
            if {[llength $dcp] && ![string match $state "greybox"]} {
               set partitionFile $dcp
            } else {
               if {[string match $state "implement"]} {
                  set partitionFile [get_module_file $module]
               } elseif {[string match $state "import"]} {
                  set pblockName [get_pblocks -of [get_cells $cell]]
                  set partitionFile "$dcpDir/${module}_${pblockName}_route_design.dcp"
               } elseif {[string match $state "greybox"]} {
                  puts "\tInfo: Cell $cell will be implemented as a grey box."
               } else {
                  set errMsg "\nERROR: Invalid state \"$state\" in settings for $name\($impl)."
                  append errMsg"Valid states are \"implement\", \"import\", or \"greybox\".\n" 
                  error $errMsg
               }
            }

            #Resolve blackbox for partition
            if {[string match $state "greybox"]} {
               set start_time [clock seconds]
               puts "\tInserting LUT1 buffers on interface of $name \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               command "update_design -cells $cell -buffer_ports" "$resultDir/update_design_$name.log"
               log_time buffer_port $start_time $end_time 0 "Buffer blackbox RM $name"
            } else {
               set fileSplit [split $partitionFile "."]
               set type [lindex $fileSplit end]
               if {[string match $type "dcp"]} {
                  set start_time [clock seconds]
                  puts "\tReading in checkpoint $partitionFile for $cell ($module) \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  command "read_checkpoint -cell $cell $partitionFile -strict" "$resultDir/read_checkpoint_${module}_${name}.log"
                  set end_time [clock seconds]
                  log_time read_checkpoint $start_time $end_time 0 "Resolve blackbox for $name"
               } elseif {[string match $type "edf"] || [string match $type "edn"]} {
                  set start_time [clock seconds]
                  puts "\tUpdating design with $partitionFile for $cell ($module) \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
                  command "update_design -cells $cell -from_file $partitionFile" "$resultDir/update_design_$name.log"
                  set end_time [clock seconds]
                  log_time update_design $start_time $end_time 0 "Resolve blackbox for $name"
               } else {
                  set errMsg "\nERROR: Invalid file type \"$type\" for $partitionFile.\n"
                  error $errMsg
               }
            }
   
            #Read in Module XDC if module is not imported
            if {![string match $state "import"]} { 
               ## Read in module Impl XDC files 
               set implXDC [get_attribute module $module implXDC]
               if {[llength $implXDC] > 0} {
                  set start_time [clock seconds]
                  readXDC $implXDC
                  set end_time [clock seconds]
                  log_time read_xdc $start_time $end_time 0 "Cell level XDCs for $name"
               } else {
                  puts "\tINFO: No cell XDC file specified for $cell"
               }
            }
   
            #Lock imported Partitions
            if {[string match $state "import"]} {
               if {![llength $level]} {
                  set level "routing"
               }
               set start_time [clock seconds]
               puts "\tLocking $cell \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               command "lock_design -level $level $cell" "$resultDir/lock_design_$name.log"
               set end_time [clock seconds]
               log_time lock_design $start_time $end_time 0 "Locking cell $cell at level routing"
            }
   
            #Do up front check for PR for Pblocks on Partitions
            if {$verbose && $pr} {
               set rpPblock [get_pblocks -quiet -of [get_cells $cell]]
               if {![llength $rpPblock]} {
                  set errMsg "ERROR: No pblock found for PR cell $cell."
                  #error $errMsg
               }
            }
   
            #If verbose it turned up, write out intermediate link_design DCP files
            if {$dcpLevel > 1} {
               set start_time [clock seconds]
               command "write_checkpoint -force $resultDir/${top}_link_design_intermediate.dcp" "$resultDir/temp.log"
               set end_time [clock seconds]
               log_time write_checkpoint $start_time $end_time 0 "Intermediate link_design checkpoint for debug"
            }
         }
         #End: Process each partition that is not Top
      }

      ##############################################
      # Bring in OOC module check points  
      ##############################################
      if {[llength $ooc_implementations] > 0 && [string match $topState "implement"]} {
         get_ooc_results $ooc_implementations
      } 

      ##############################################
      # Special processing for TopDown implementation
      ##############################################
      if {$td && $verbose > 0} {
         #Turn off phys_opt_design and route_design for TD run
         set phys  [set_attribute impl $impl phys  0]
         set route [set_attribute impl $impl route 0]
         #Turn on param to generate PP_RANGE if one does not exist
         set_parameters {hd.partPinRangesForPblock 1} 

         puts "\t#HD: Creating OOC constraints"
         set start_time [clock seconds]
         foreach ooc $ooc_implementations {
            #Set HD.PARTITION and create set_logic_* constraints
            set module [get_attribute ooc $ooc module]
            set instName [get_attribute ooc $ooc inst]
            set hierInst [get_attribute ooc $ooc hierInst]
            set oocFile [get_module_file $module]
            set fileSplit [split $oocFile "."]
            set type [lindex $fileSplit end]
            set start_time [clock seconds]
            puts "\tResolving $hierInst ($module) with $oocFile \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
            if {[string match $type "dcp"]} {
               command "read_checkpoint -cell $hierInst $oocFile -strict" "$resultDir/read_checkpoint_$instName.log"
               set end_time [clock seconds]
               log_time read_checkpoint $start_time $end_time 0 "Resolve blackbox for $instName"
            } elseif {[string match $type "edf"] || [string match $type "edn"]} {
               command "update_design -cells $hierInst -from_file $oocFile" "$resultDir/update_design_$instName.log"
               set end_time [clock seconds]
               log_time update_design $start_time $end_time 0 "Resolve blackbox for $instName"
            } else {
               set errMsg "\nERROR: Invalid file type \"$type\" for $oocFile.\n"
               error $errMsg
            }
            command "set_property HD.PARTITION 1 \[get_cells $hierInst\]"
            create_set_logic $instName $hierInst $xdcDir
            create_ooc_clocks $instName $hierInst $xdcDir
         }
         set end_time [clock seconds]
         log_time "create_ooc" $start_time $end_time 0 "Create necessary OOC constraints"
      }

      ##############################################
      # Read in any linkXDC files 
      ##############################################
      if {[llength $linkXDC] > 0 && [string match $topState "implement"]} {
         set start_time [clock seconds]
         readXDC $linkXDC
         set end_time [clock seconds]
         log_time read_xdc $start_time $end_time 0 "Post link_design XDC files"
      } else {
         if {[string match $topState "implement"]} {
            puts "\tINFO: Skipping top-level XDC files because $top is set to $topState"
         } else {
            puts "\tINFO: No post-link_design XDC file specified for $impl"
         }
      }

      if {$dcpLevel > 0} {
         set start_time [clock seconds]
         command "write_checkpoint -force $resultDir/${top}_link_design.dcp" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Post link_design checkpoint"
      }


      ##############################################
      # Write out final link_design DCP 
      ##############################################
      if {$verbose > 1} {
         set start_time [clock seconds]
         command "report_utilization -file $reportDir/${top}_utilization_link_design.rpt" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time report_utilization $start_time $end_time
      } 
      puts "\t#HD: Completed link_design"
      puts "\t##########################\n"

      ##############################################
      # Run Methodology DRCs checks 
      ##############################################
      #Run methodology DRCs and catch any Critical Warnings or Error (module ruledeck quiet)
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
   
   ############################################################################################
   # Implementation steps: opt_design, place_design, phys_opt_design, route_design
   ############################################################################################
   if {$opt} {
      impl_step opt_design $top $opt_options $opt_directive ${opt.pre}
   }

   if {$place} {
      impl_step place_design $top $place_options $place_directive ${place.pre}

      #### If Top-Down, write out XDCs 
      if {$td && $verbose > 0} {
         puts "\n\tWriting instance level XDC files."
         foreach ooc $ooc_implementations {
            set instName [get_attribute ooc $ooc inst]
            set hierInst [get_attribute ooc $ooc hierInst]
            write_hd_xdc $instName $hierInst $xdcDir
         }
      }
   }

   if {$phys} {
      impl_step phys_opt_design $top $phys_options $phys_directive ${phys.pre}
   }

   if {$route} {
      impl_step route_design $top $route_options $route_directive ${route.pre}
 
      #Run report_timing_summary on final design
      set start_time [clock seconds]
      command "report_timing_summary -file $reportDir/${top}_timing_summary.rpt" "$resultDir/temp.log"
      set end_time [clock seconds]
      log_time report_timing $start_time $end_time 0 "Timing Summary"
   
      #Run a final DRC that catches any Critical Warnings (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $top bitstream_checks ${drc.quiet}
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "bistream_checks"
   
      #Report PR specific statitics for debug and analysis
      if {$pr} {
         command "debug::report_design_status" "$reportDir/${top}_design_status.rpt"
      }
   }
   
   if {![file exists $dcpDir]} {
      command "file mkdir $dcpDir"
   }   

   #Write out cell checkpoints for all Partitions 
   if {$ic || $pr} {
      foreach partition $partitions {
         lassign $partition module cell state level dcp
         set moduleName [get_attribute module $module moduleName]
         set pblockName [get_pblocks -of [get_cells $cell]]
         set name [lindex [split $cell "/"] end]
         if {![string match $moduleName $top] && ([string match $state "implement"] || [string match $topState "implement"])} {
            set start_time [clock seconds]
            set dcp "$resultDir/${module}_${pblockName}_route_design.dcp"
            command "write_checkpoint -force -cell $cell $dcp" "$resultDir/temp.log"
            set end_time [clock seconds]
            log_time write_checkpoint $start_time $end_time 0 "Write cell checkpoint for $cell"
            command "file copy -force $dcp $dcpDir"
            if {[string match $topState "implement"]} {
               set start_time [clock seconds]
               puts "\tCarving out $cell to be a black box \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
               command "update_design -cell $cell -black_box" "$resultDir/carve_$name.log"
               set end_time [clock seconds]
               log_time update_design $start_time $end_time 0 "Carve out (blackbox) $cell"
            }
         }
      }
   }

   #Write out implemented version of Top for import
   foreach partition $partitions {
      lassign $partition module cell state level dcp
      set moduleName [get_attribute module $module moduleName]
      set name [lindex [split $cell "/"] end]
      if {[string match $moduleName $top] && [string match $state "implement"]} {
         set start_time [clock seconds]
         puts "\tLocking $top and exporting results \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
         command "lock_design -level routing" "$resultDir/lock_design_$top.log"
         set end_time [clock seconds]
         log_time lock_design $start_time $end_time 0 "Lock placement and routing of $top"
         if {$pr} {
            set topDCP "$resultDir/${top}_static.dcp"
         } else {
            set topDCP "$resultDir/${top}_routed.dcp"
         }
         command "write_checkpoint -force $topDCP" "$resultDir/temp.log"
         command "file copy -force $topDCP $dcpDir"
      }
   }

   #For PR, don't write out bitstreams until after PR_VERIFY is ran. See run.tcl
   if {$bitstream && !$pr} {
      impl_step write_bitstream $top $bitstream_options none ${bitstream.pre} $bitstream_settings
   }
   
   set impl_end [clock seconds]
   log_time final $impl_start $impl_end 
   log_data $impl $top

   command "close_project"
   command "puts \"#HD: Implementation $impl complete\\n\""
   close $rfh
   close $cfh
   close $wfh
}
