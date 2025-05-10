proc impl_step {phase instance {options none} {directive none} {pre none} {settings none} } {
   global dcpLevel
   global verbose
   upvar  impl impl 
   upvar  resultDir resultDir
   upvar  reportDir reportDir

   #Make sure $phase is valid and set checkpoint in case no design is open
   if {[string match $phase "opt_design"]} {
      set checkpoint1 "$resultDir/${instance}_link_design.dcp"
   } elseif {[string match $phase "place_design"]} {
      set checkpoint1 "$resultDir/${instance}_opt_design.dcp"
   } elseif {[string match $phase "phys_opt_design"]} {
      set checkpoint1 "$resultDir/${instance}_place_design.dcp"
   } elseif {[string match $phase "route_design"]} {
      set checkpoint1 "$resultDir/${instance}_phys_opt_design.dcp"
      set checkpoint2 "$resultDir/${instance}_place_design.dcp"
   } elseif {[string match $phase "post_phys_opt"]} {
      set checkpoint1 "$resultDir/${instance}_route_design.dcp"
   } elseif {[string match $phase "write_bitstream"]} {
      set checkpoint1 "$resultDir/${instance}_post_phys_opt.dcp"
      set checkpoint2 "$resultDir/${instance}_route_design.dcp"
   } else {
      set errMsg "\nERROR: Value $phase is not a recognized step of implementation. Valid values are \"opt_design\", \"place_design\", \"phys_opt_design\", or \"route_design\"."
      error $errMsg
   }
   #If no design is open
   if { [catch {current_instance > $resultDir/temp.log} errMsg] && $verbose > 0 } {
      puts "\tNo open design" 
      if {[info exists checkpoint1] || [info exists checkpoint2]} {
         if {[file exists $checkpoint1]} {
            puts "\tOpening checkpoint $checkpoint1 for $instance"
            command "open_checkpoint $checkpoint1" "$resultDir/open_checkpoint_${instance}_$phase.log"
            if { [catch {current_instance > $resultDir/temp.log} errMsg] } {
               command "link_design"
            }
         } elseif {[file exists $checkpoint2]} {
            puts "\tOpening checkpoint $checkpoint2 for $instance"
            command "open_checkpoint $checkpoint2" "$resultDir/open_checkpoint_${instance}_$phase.log"
            if { [catch {current_instance > $resultDir/temp.log} errMsg] } {
               command "link_design"
            }
         } else {
            set errMsg "\nERROR: Checkpoint file not found. Please rerun necessary steps."
            error $errMsg
         }
      } else {
        set errMsg "\nERROR: No checkpoint defined."
        error $errMsg
      }
   }
  
   #Run any specified pre-phase scripts
   if {![string match $pre "none"] && ![string match $pre ""] } {
      foreach script $pre {
         if {[file exists $script]} {
            puts "\t#HD: Running pre-$phase script $script"
            command "source $script" "$resultDir/pre_${phase}_script.log"
         } else {
            set errMsg "\nERROR: Script $script specified for pre-${phase} does not exist"
            error $errMsg
         }
      }
   }
 
   #Append options or directives to command
   if {[string match $phase "write_bitstream"]} {
      set impl_step "$phase -force -file $resultDir/$instance"
   } elseif {[string match $phase "post_phys_opt"]} {
      set impl_step "phys_opt_design"
   } else {
      set impl_step $phase
   }

   if {[string match $options "none"]==0 && [string match $options ""]==0} {
      append impl_step " $options"
   }
   if {[string match $directive "none"]==0 && [string match $directive ""]==0} {
      append impl_step " -directive $directive"
   }
   if {[string match $settings "none"]==0 && [string match $settings ""]==0} {
      foreach setting $settings {
         puts "\tSetting property $setting"
         command "set_property $setting \[current_design]"
      }
   }

   #Run the specified Implementation phase
   puts "\n\t#HD: Running $impl_step for $impl"

   set log "$resultDir/${instance}_$phase.log"
   puts "\tWriting Results to $log"

   set start_time [clock seconds]
   puts "\t$phase start time: \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]"
   command "$impl_step" "$log"
   set end_time [clock seconds]
   log_time $phase $start_time $end_time 0 "$impl_step" 
   command "puts \"\t#HD: Completed: $phase\""
   puts "\t################################"
      
   #Write out checkpoint for successfully completed phase
   if {($dcpLevel > 0 || [string match $phase "route_design"]) && ![string match $phase "write_bitstream"]} {
      set start_time [clock seconds]
      puts "\tWriting post-$phase checkpoint: $resultDir/${instance}_$phase.dcp \[[clock format $start_time -format {%a %b %d %H:%M:%S %Y}]\]\n"
      command "write_checkpoint -force $resultDir/${instance}_$phase.dcp" "$resultDir/write_checkpoint.log"
      set end_time [clock seconds]
      log_time write_checkpoint $start_time $end_time 0 "Post-$phase checkpoint"
   }

   #Write out additional reports controled by verbose level
   if {$verbose > 1 || [string match $phase "route_design"]} {
      set start_time [clock seconds]
      command "report_utilization -file $reportDir/${instance}_utilization_${phase}.rpt" "$resultDir/temp.log"
      set end_time [clock seconds]
      log_time report_utilization $start_time $end_time
   }

   if {[string match $phase "route_design"]} {
      set start_time [clock seconds]
      command "report_route_status -file $reportDir/${instance}_route_status.rpt" "$resultDir/temp.log"
      set end_time [clock seconds]
      log_time report_route_status $start_time $end_time
   }
}

