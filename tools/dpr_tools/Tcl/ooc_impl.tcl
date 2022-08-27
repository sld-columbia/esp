##############################
#### Implement OOC Module ####
##############################
proc ooc_impl { impl } {
   global tclParams 
   global part
   global dcpLevel
   global verbose
   global xdcDir
   global implDir
   global dcpDir

   set ooc_module          [get_attribute ooc $impl module]
   set ooc_inst            [get_attribute ooc $impl inst]
   set ooc_xdc             [get_attribute ooc $impl implXDC]
   set cores               [get_attribute ooc $impl cores]
   set hd.isolated         [get_attribute ooc $impl hd.isolated]
   set budget.create       [get_attribute ooc $impl budget.create]
   set budget.percent      [get_attribute ooc $impl budget.percent]
   set link                [get_attribute ooc $impl link]
   set opt                 [get_attribute ooc $impl opt]
   set opt.pre             [get_attribute ooc $impl opt.pre]
   set opt_options         [get_attribute ooc $impl opt_options]
   set opt_directive       [get_attribute ooc $impl opt_directive]
   set place               [get_attribute ooc $impl place]
   set place.pre           [get_attribute ooc $impl place.pre]
   set place_options       [get_attribute ooc $impl place_options]
   set place_directive     [get_attribute ooc $impl place_directive]
   set phys                [get_attribute ooc $impl phys]
   set phys.pre            [get_attribute ooc $impl phys.pre]
   set phys_options        [get_attribute ooc $impl phys_options]
   set phys_directive      [get_attribute ooc $impl phys_directive]
   set route               [get_attribute ooc $impl route]
   set route.pre           [get_attribute ooc $impl route.pre]
   set route_options       [get_attribute ooc $impl route_options]
   set route_directive     [get_attribute ooc $impl route_directive]
   set bitstream           [get_attribute ooc $impl bitstream]
   set bitstream.pre       [get_attribute ooc $impl bitstream.pre]
   set bitstream_options   [get_attribute ooc $impl bitstream_options]
   set drc.quiet           [get_attribute ooc $impl drc.quiet]

   set resultDir "$implDir/$impl"
   set reportDir "$resultDir/reports"
   
   # Make the implementation directory, Clean-out and re-make the results directory
   command "file mkdir $implDir"
   command "file delete -force $resultDir"
   command "file mkdir $resultDir"
   command "file mkdir $reportDir"
   
   #Open local log files
   set rfh [open "$resultDir/run.log" w]
   set cfh [open "$resultDir/command.log" w]
   set wfh [open "$resultDir/critical.log" w]

   command "puts \"#HD: Running OOC implementation $impl (OUT-OF-CONTEXT)\""
   puts "\tWriting results to: $resultDir"
   puts "\tWriting reports to: $reportDir"
   set impl_start [clock seconds]

   #### Set Tcl Params
   if {[info exists tclParams] && [llength $tclParams] > 0} {
      set_parameters $tclParams
   }

   #Create in-memory project
   command "create_project -in_memory -part $part" "$resultDir/create_project.log"

   ###########################################
   # Linking
   ###########################################
   if {$link} {
      ###########################################
      # Define the OOC Module source
      ###########################################
      set topFile [get_module_file $ooc_module]
      puts "\tAdding $topFile for $ooc_module"
      command "add_files $topFile"

      #### Read in IP Netlists 
      if {[llength $cores] > 0} {
         add_cores $cores
      }
      
      #### Read in XDC file
      if {[llength $ooc_xdc] > 0} {
         add_xdc $ooc_xdc
      } else {
         puts "\tWarning: No XDC file specified for $impl"
      }
   
   
      ##############################################
      # Link the OOC design 
      ##############################################
      set start_time [clock seconds]
      set link_step "link_design -mode out_of_context -part $part -top [get_attribute module $ooc_module moduleName]"
      puts "\t#HD: Running $link_step for $ooc_module"
      set log "$resultDir/${ooc_inst}_link_design.log"
      puts "\tWriting Results to $log"
      puts "\tlink_design start time: \[[clock format $start_time -format {%H:%M:%S %a %b %d %Y}]\]"
      command "$link_step" "$log"
      set end_time [clock seconds]
      log_time link_design $start_time $end_time 1 "link_design -mode out_of_context -part $part -top [get_attribute module $ooc_module moduleName]"

      if {${hd.isolated}} {
         command "set_property HD.ISOLATED 1 \[current_design]"
      } else {
         command "set_property HD.PARTITION 1 \[current_design]"
      }

      puts "\t#HD: Completed link_design"
      puts "\t##########################\n"
      if {$dcpLevel > 0} {
         set start_time [clock seconds]
         command "write_checkpoint -force $resultDir/${ooc_inst}_link_design.dcp" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time write_checkpoint $start_time $end_time 0 "Post link_design checkpoint"
      }
      if {$verbose > 1} {
         set start_time [clock seconds]
         command "report_utilization -file $reportDir/${ooc_inst}_utilization_link_design.rpt" "$resultDir/temp.log"
         set end_time [clock seconds]
         log_time report_utilization $start_time $end_time
      } 
      #Run methodology DRCs and catch any Critical Warnings or Error (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $ooc_inst methodology_checks 1
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "methodology checks"
      #Run timing DRCs and catch any Critical Warnings or Error (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $ooc_inst timing_checks 1
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "timing_checks"
   }
   
   ############################################################################################
   # Implementation steps: opt_design, place_design, phys_opt_design, route_design
   ############################################################################################
   #Create timing budget constraints for the interface ports based on a percentage of the full period
   if {${budget.create}} {
      set budgetXDC "${ooc_inst}_ooc_budget.xdc"
      puts "\tWriting inteface budgets constraints to XDC file \"$xdcDir/$budgetXDC\"."
      command "::debug::gen_hd_timing_constraints -percent ${budget.percent} -file $xdcDir/$budgetXDC"
      puts "\tReading XDC file $xdcDir/$budgetXDC"
      command "read_xdc -mode out_of_context $xdcDir/$budgetXDC" "$resultDir/read_xdc_${ooc_inst}_budget.log"
   }

   if {$opt} {
      impl_step opt_design $ooc_inst $opt_options $opt_directive ${opt.pre}
   }
   
   if {$place} {
      impl_step place_design $ooc_inst $place_options $place_directive ${place.pre}
   }
   
   if {$phys} {
      impl_step phys_opt_design $ooc_inst $phys_options $phys_directive ${phys.pre}
   }
   
   if {$route} {
      impl_step route_design $ooc_inst $route_options $route_directive ${route.pre}
   
 
      #Copy OOC implementation results to Checkpoint directory
      if {![file exists $dcpDir]} {
         command "file mkdir $dcpDir"
      }   
      command "file copy -force $resultDir/${ooc_inst}_route_design.dcp $dcpDir"
   
      #Run report_timing_summary on final design
      set start_time [clock seconds]
      command "report_timing_summary -file $reportDir/${ooc_inst}_timing_summary.rpt" "$resultDir/temp.log"
      set end_time [clock seconds]
      log_time report_timing $start_time $end_time 0 "Timing Summary"
   
      #Run a final DRC that catches any Critical Warnings (module ruledeck quiet)
      set start_time [clock seconds]
      check_drc $ooc_inst default ${drc.quiet}
      set end_time [clock seconds]
      log_time report_drc $start_time $end_time 0 "default"
   }
   
   if {${hd.isolated} && $bitstream} {
      command "set_property IS_ENABLED {false} \[get_drc_checks]"
      impl_step write_bitstream $ooc_inst $bitstream_options none ${bitstream.pre}
      command "reset_drc_check \[get_drc_checks]"
   }

   set impl_end [clock seconds]
   log_time final $impl_start $impl_end 
   log_data $impl $ooc_inst
   
   command "close_project"
   command "puts \"#HD: OOC implementation of $impl complete\\n\""
   close $rfh
   close $cfh
   close $wfh
}
