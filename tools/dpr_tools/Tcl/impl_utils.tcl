###############################################################
# Source scripts need for implementation
###############################################################
if {[info exists tclDir]} {
   source $tclDir/implement.tcl
   source $tclDir/step.tcl
}

###############################################################
# Find netlist for specified module
###############################################################
proc get_module_file { module } {
   global verbose
   global synthDir
   global ipDir
   global netlistDir
   
   if {![info exists synthDir]} {
      set synthDir "."
   }
   if {![info exists ipDir]} {
      set ipDir "."
   }
   if {![info exists netlistDir]} {
      set netlistDir "."
   }

   set moduleName [get_attribute module $module moduleName]
   set synthDCP   [get_attribute module $module synthCheckpoint]
   set searchFiles [list $synthDCP \
                         $synthDir/$module/${moduleName}_synth.dcp  \
                         $ipDir/$module/${moduleName}.xci           \
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
      #If verbose==0 to generate scripts only, no file may exist if synthesis has not been run.
      #Instead of erroring in this case, just return default file of $synthDir/...
      if {!$verbose} {
         set moduleFile "$synthDir/$module/${moduleName}_synth.dcp"
         return $moduleFile
      }
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
# Generate Partial ICAP/PCAP formated BIN files
# Must have Partial Bitstreams already generated
###############################################################
proc generate_dfx_binfiles { config } {
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
         lassign $partition module cell state name type level dcp
         if {![llength $name]} {
            set name [lindex [split $cell "/"] end]
         }
         if {![string match $cell $top]} {
            set pblock [get_pblocks -quiet -of [get_cells $cell]]
            if {[string match "greybox" $state]} {
               set bitName "${pblock}_greybox_partial"
            } else {
               set bitName "${pblock}_${module}_partial"
            }
            set bitFile "$bitDir/${bitName}.bit"
            if {![file exists $bitFile]} {
               puts "\tCritical Warning: No bit file found for $cell ($module) in configuration $config. Skipping BIN file generation. Expected file \n\t$bitFile.\n\tRun write_bitstream first to generate the expected file."
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
# Generate Partial Bitstreams  
###############################################################
proc generate_dfx_bitstreams { configs } {
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
      set top               [get_attribute impl $config top]
      set partitions        [get_attribute impl $config partitions]
      set post_phys         [get_attribute impl $config post_phys]
      set bitstream         [get_attribute impl $config bitstream]
      set bitstream.pre     [get_attribute impl $config bitstream.pre]
      set bitOptions        [get_attribute impl $config bitstream_options]
      set bitSettings       [get_attribute impl $config bitstream_settings]
      set partialOptions    [get_attribute impl $config partial_bitstream_options]
      set partialSettings   [get_attribute impl $config partial_bitstream_settings]
      if {$bitstream} {
         set start_time [clock seconds]
         set msg "\t#HD: Running write_bitstream on $config"
         command "puts \"$msg\""
         set logFile "$bitDir/write_bitstream_${config}.log"
         if {$post_phys} {
            set configFile "$implDir/$config/${top}_post_phys_opt.dcp"
         } else {
            set configFile "$implDir/$config/${top}_route_design.dcp"
         }
         if {[file exists $configFile]} {
            command "open_checkpoint $configFile" "$bitDir/open_checkpoint_$config.log"

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

            #Apply config settings for full bit file
            foreach setting $bitSettings {
               puts "\tSetting property $setting"
               command "set_property $setting \[current_design\]"
            }
            #Generate full Bitstream
            foreach partition $partitions {
               lassign $partition module cell state name type level dcp
               if {[string match $cell $top]} {
                  #Generate full bitstream only
                  command "write_bitstream -force $bitOptions $bitDir/${config}_full -no_partial_bitfile" "$bitDir/${config}_full.log"
               }
            }

            #Check for dbg_hub in Static and write out probes
            if {[llength [get_cells -quiet -hier -filter REF_NAME==dbg_hub_CV]]} {
               command "write_debug_probes -force -no_partial_ltxfile $bitDir/${config}_full.ltx" "$bitDir/write_debug_probes_$config.log"
            }

            #Apply any partial specfic config settings (ie. compression)
            foreach setting $partialSettings {
               puts "\tSetting property $setting"
               command "set_property $setting \[current_design\]"
            }
            #Check for specific options for partial bit files. Otherwise default to full settings.
            if {[llength $partialOptions]} {
               set bitOptions $partialOptions
            }
            #Generate partials using -cell for better naming
            foreach partition $partitions {
               lassign $partition module cell state name type level dcp
               if {![string match $cell $top]} {
                  set pblock [get_pblocks -quiet -of [get_cells $cell]]
                  if {[string match "greybox" $state]} {
                     set bitName "${pblock}_greybox_partial"
                  } else {
                     set bitName "${pblock}_${module}_partial"
                  }
                  command "write_bitstream -force $bitOptions -cell $cell $bitDir/$bitName" "$bitDir/$bitName.log"
                  #Check for dbg_bridge in RM and write out probes
                  if {[llength [get_cells -quiet -hier -filter "REF_NAME=~debug_bridge* && NAME=~$cell/*"]]} {
                     command "write_debug_probes -force -cell $cell $bitDir/${bitName}.ltx" "$bitDir/write_debug_probes_$module.log"
                  }
               }
            }
         } else {
            puts "\tInfo: Skipping write_bitstream for configuration $config because the file \'$configFile\' could not be found."
            continue
         }

         set end_time [clock seconds]
         log_time write_bitstream $start_time $end_time 1 $config
         generate_dfx_binfiles $config 
         command "close_project" "$bitDir/temp.log"
      } else {
         puts "\tSkipping write_bitstream for Configuration $config with attribute \"bitstream\" set to \'$bitstream\'"
      }
   }
}

###############################################################
# Verify all configurations 
###############################################################
proc verify_configs { configs } {
   global implDir

   set configNames ""
   set configFiles ""
   foreach config $configs {
      set verify [get_attribute impl $config verify]
      set post_phys [get_attribute impl $config post_phys]
      #Check if configuration has verify attribute set
      if {$verify} {
         set configTop [get_attribute impl $config top]
         if {$post_phys} {
            set configFile $implDir/$config/${configTop}_post_phys_opt.dcp
         } else {
            set configFile $implDir/$config/${configTop}_route_design.dcp
         }
         #Even with verify set, check if routed DCP exists before adding to the list to be verified
         if {[file exists $configFile]} {
            lappend configFiles $configFile
            lappend configNames $config
         } else {
            puts "\tInfo: Skipping Configuration $config with attribute \"verify\" to \'$verify\' because file \'$configFile\' cannot be found."
         }
      } else {
         puts "\tInfo: Skipping Configuration $config with attribute \"verify\" set to \'$verify\'"
      }
   }
   
   if {[llength $configFiles] > 1} {
      set start_time [clock seconds]
      set initialConfig [lindex $configNames 0]
      set initialConfigFile [lindex $configFiles 0]
      set additionalConfigs [lrange $configNames 1 end]
      set additionalConfigFiles [lrange $configFiles 1 end]
      set msg "#HD: Running pr_verify between initial Configuration \'$initialConfig\' and subsequent configurations \'$additionalConfigs\'"
      command "puts \"$msg\""
      set logFile "pr_verify_results.log"
      command "pr_verify -full_check -initial $initialConfigFile -additional \{$additionalConfigFiles\}" $logFile
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
proc add_xdc { xdc {synth 0} {cell ""} } {
   #Flatten list if nested lists exist
   set files [join [join $xdc]]
   foreach file $files {
      if {[file exists $file]} {
         puts "\t#HD: Adding 'xdc' file $file"
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

         if {[llength $cell]} {
            #Check if this file is already scoped to another partition
            if {[llength [get_property SCOPED_TO_CELLS [get_files $file]]]} {
               set cells [get_property SCOPED_TO_CELLS [get_files $file]]
               lappend cells $cell
               command "set_property SCOPED_TO_CELLS \{$cells\} \[get_files $file\]"
            } else {
               command "set_property SCOPED_TO_CELLS \{$cell\} \[get_files $file\]"
            }
         }

         #Set all partition scoped XDC to late by default. May need to review.
         if {[string match "*late*" $fileName] || [llength $cell]} {
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

   puts "\tReading XDC files"
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
   global verbose
   upvar resultDir resultDir

   foreach ip $ips {
      if {[string length ip] > 0} { 
         if {[file exists $ip]} {
            set ip_split [split $ip "/"] 
            set xci [lindex $ip_split end]
            set ipPathList [lrange $ip_split 0 end-1]
            set ipPath [join $ipPathList "/"]
            set ipName [lindex [split $xci "."] 0]
            set ipType [lindex [split $xci "."] end]
            puts "\t#HD: Adding \'$ipType\' file $xci"
            command "add_files $ipPath/$xci" "$resultDir/${ipName}_add.log"
            if {[string match $ipType "bd"] || $verbose==0} {
               return
            }
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
   #Flatten list if nested lists exist
   set files [join [join $cores]]
   foreach file $files {
      if {[string length $file] > 0} { 
         if {[file exists $file]} {
            #Comment this out to prevent adding files 1 at a time. Add all at once instead.
            puts "\t#HD: Adding core file $file"
            command "add_files $file"
         } else {
            set errMsg "\nERROR: Could not find specified core file: $file" 
            error $errMsg
         }
      }
   }
}

#==============================================================
# TCL proc for running DRC on post-route_design to catch 
# Critical Warnings. These will be errors in write_bitstream. 
# Catches unroutes, antennas, etc. 
#==============================================================
proc check_drc { module {ruleDeck default} {quiet 0} } {
   upvar reportDir reportDir

   if {[info exists reportDir]==0} {
      set reportDir "."
   }
   puts "\t#HD: Running report_drc with ruledeck $ruleDeck.\n\tResults saved to $reportDir/${module}_drc_$ruleDeck.rpt" 
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

#==============================================================
# FOR TESTING ONLY!!!!
# TCL proc to Detect and fix unsafe timing paths to temporarily
# clean up incorretly constrained design.
#==============================================================
proc fix_timing {} {
   set clk_intr [split [report_clock_interaction -return_string] \n]
   foreach line $clk_intr {
      if { [regexp {^(\S+)\s+(\S+)\s+\S+.*Timed \(unsafe\).*} $line full src dst]} {
         set_false_path -from [get_clocks $src] -to [get_clocks $dst]
      }
   }
}
