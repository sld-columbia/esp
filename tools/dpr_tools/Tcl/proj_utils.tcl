proc xpr2tcl {} {
 
   set top [get_property TOP [get_filesets sources_1]] 

   foreach partition [get_partition_defs] {
      foreach rm [get_reconfig_module -of $partition] {
      }
   }
}
###############################################################
### Parse PRJ and add all files 
###############################################################
proc add_module_prj { prj {top 0} } {
   global srcDir FH
   upvar module module

   if {[file exists $prj]} {
      puts "\tParsing PRJ file: $prj"
      set source [open $prj r]
      set source_data [read $source]
      close $source
      #Remove quotes from PRJ file
      regsub -all {\"} $source_data {} source_data
      set prj_lines [split $source_data "\n" ]
      set line_count 0
      foreach line $prj_lines {
         incr line_count
         #Ignore empty and commented lines
         if {[llength $line] > 0 && ![string match -nocase "#*" $line]} {
            if {[llength $line]!=3} {
               set errMsg "\nERROR: Line $line_count is invalid format. Should be:\n\t<file_type> <library> <file>"
               error $errMsg
            }
            lassign $line type lib file
            if {![string match -nocase $type "dcp"]     && \
                ![string match -nocase $type "xci"]     && \
                ![string match -nocase $type "header"]  && \
                ![string match -nocase $type "system"]  && \
                ![string match -nocase $type "verilog"] && \
                ![string match -nocase $type "vhdl"]} {
               set errMsg "\nERROR: File type $type is not a supported value.\n"
               append errMsg "Supported types are:\n\tdcp\n\txci\n\theader\n\tsystem\n\tverilog\n\tvhdl\n\t"
               error $errMsg
            }
            if {[file exists ${srcDir}/$file]} {
               set file ${srcDir}/$file
               if {$top} {
                  puts $FH "add_files $file"
               } else {
                  puts $FH "add_files $file -of \[get_reconfig_module $module\]"
               }
               if {[string match -nocase $type "vhdl"]} {
                  puts $FH "set_property LIBRARY $lib \[get_files $file\]"
               }
               if {[string match -nocase $type "system"]} {
                  puts $FH "set_property FILE_TYPE SystemVerilog \[get_files $file\]"
               }
               if {[string match -nocase $type "header"]} {
                   puts $FH "set_property FILE_TYPE {Verilog Header} \[get_files $file\]"
               }
            } elseif {[file exists $file]} {
               if {$top} {
                  puts $FH "add_files $file"
               } else {
                  puts $FH "add_files $file -of \[get_reconfig_module $module\]"
               }
               if {[string match -nocase $type "vhdl"]} {
                  puts $FH "set_property LIBRARY $lib \[get_files $file\]"
               }
               if {[string match -nocase $type "system"]} {
                  puts $FH "set_property FILE_TYPE SystemVerilog \[get_files $file\]"
               }
               if {[string match -nocase $type "header"]} {
                   puts $FH "set_property FILE_TYPE {Verilog Header} \[get_files $file\]"
               }
            } else {
               puts "ERROR: Could not find file \"$file\" on line $line_count."
               set error 1
            }
         }
      }
      if {[info exists error]} {
         set errMsg "\nERROR: Files not found. Check messages for more details.\n"
         error $errMsg
      }
   } else {
      set errMsg "\nERROR: Could not find PRJ file $prj"
      error $errMsg
   }
}

###############################################################
### Add all system Verilog files 
###############################################################
proc add_module_sysvlog { sysvlog {top 0} } {
   global FH
   upvar module module

   set files [join $sysvlog]
   foreach file $files {
      if {[file exists $file]} {
         if {$top} {
            puts $FH "add_files $file"
         } else {
            puts $FH "add_files $file -of \[get_reconfig_module $module\]"
         }
         puts $FH "set_property FILE_TYPE SystemVerilog \[get_files $file\]"
      } else {
         puts "ERROR: Could not find file \"$file\"."
         set error 1;
      }
   }
   if {[info exists error]} {
      set errMsg "\nERROR: Files not found. Check messages for more details.\n"
      error $errMsg
   }
}

###############################################################
### Add all Verilog files 
###############################################################
proc add_module_vlog { vlog {top 0} } {
   global FH
   upvar module module

   set files [join $vlog]
   foreach file $files {
      if {[file exists $file]} {
         if {$top} {
            puts $FH "add_files $file"
         } else {
            puts $FH "add_files $file -of \[get_reconfig_module $module\]"
         }
      } else {
         puts "ERROR: Could not find file \"$file\"."
         set error 1;
      }
   }
   if {[info exists error]} {
      set errMsg "\nERROR: Files not found. Check messages for more details.\n"
      error $errMsg
   }
}

###############################################################
### Add all VHDL files 
###############################################################
proc add_module_vhdl { vhdl {top 0} } {
   global FH
   upvar module module

   set index 0
   while {$index < [llength $vhdl]} {
      set lib [lindex $vhdl [expr $index+1]]
      foreach file [lindex $vhdl $index] {
         if {[file exists $file]} {
            if {$top} {
               puts $FH "add_files $file"
            } else {
               puts $FH "add_files $file -of \[get_reconfig_module $module\]"
            }
            puts $FH "set_property LIBRARY $lib \[get_files $file\]"
         } else {
            puts "ERROR: Could not find file \"$file\"."
            set error 1;
         }
      }
      set index [expr $index+2]
   }
   if {[info exists error]} {
      set errMsg "\nERROR: Files not found. Check messages for more details.\n"
      error $errMsg
   }
}

###############################################################
# Add all core netlists in list 
###############################################################
proc add_module_cores { cores {top 0} } {
   global FH
   upvar module module

   #Flatten list if nested lists exist
   set files [join [join $cores]]
   foreach file $files {
      if {[string length $file] > 0} { 
         if {![file exists $file]} {
            #Comment this out to prevent adding files 1 at a time. Add all at once instead.
            #puts $FH "add_files $file -of \[get_reconfig_module $module\]"
            set errMsg "\nERROR: Could not find specified IP netlist: $file" 
            error $errMsg
         }
      }
   }
   #Check to make sure file list is not empty
   if {[string length $files] > 0} { 
      if {$top} {
         puts $FH "add_files $files"
      } else {
         puts $FH "add_files $files -of \[get_reconfig_module $module\]"
      }
   }
}

###############################################################
### Add all XCI files in list
###############################################################
proc add_module_ip { ips {top 0} } {
   global FH
   upvar module module

   foreach ip $ips {
      if {[string length ip] > 0} { 
         if {[file exists $ip]} {
            set ip_split [split $ip "/"] 
            set xci [lindex $ip_split end]
            set ipPathList [lrange $ip_split 0 end-1]
            set ipPath [join $ipPathList "/"]
            set ipName [lindex [split $xci "."] 0]
            set ipType [lindex [split $xci "."] end]
            if {$top} {
               puts $FH "add_files $ipPath/$xci"
            } else {
               puts $FH "add_files $ipPath/$xci -of \[get_reconfig_module $module\]"
            }
         } else {
            set errMsg "\nERROR: Could not find specified IP file: $ip" 
            error $errMsg
         }
      }
   }
}

###############################################################
### Add all BD files in list
###############################################################
proc add_module_bd { files {top 0} } {
   global FH
   upvar module module

   foreach file $files {
      if {[string length file] > 0} { 
         if {[file exists $file]} {
            set bd_split [split $file "/"] 
            set bd [lindex $bd_split end]
            set bdName [lindex [split $bd "."] 0]
            if {[regexp {.*\.tcl} $file]} {
               puts $FH "source $file"
#               puts $FH "generate_target all \[get_files .srcs/sources_1/bd/${bdName}/${bdName}.bd\]"
            } else {
               if {$top} {
                  puts $FH "add_files $file"
               } else {
                  puts $FH "add_files $file -of \[get_reconfig_module $module\]"
#                  puts $FH "generate_target all \[get_files $file]" "$resultDir/${bdName}_generate.log"
               }
            }
         } else {
            set errMsg "\nERROR: Could not find specified BD file: $file" 
            error $errMsg
         }
      }
   }
}

###############################################################
# Add all XDC files in list, and mark as OOC if applicable
###############################################################
proc add_module_xdc { xdc { synth 0} {top 0} } {
   global FH
   upvar module module

   #Flatten list if nested lists exist
   set files [join [join $xdc]]
   foreach file $files {
      if {[file exists $file]} {
         if {$top} {
            puts $FH "add_files $file"
         } else {
            puts $FH "add_files $file -of \[get_reconfig_module $module\]"
         } 
         set file_split [split $file "/"]
         set fileName [lindex $file_split end]
         if { $synth ==2 || [string match "*synth*" $fileName] } { 
            if {[string match "*ooc*" $fileName]} {
               puts $FH "set_property USED_IN {synthesis out_of_context} \[get_files $file\]"
            } else {
               puts $FH "set_property USED_IN {synthesis} \[get_files $file\]"
            }
         } elseif { $synth==1 } {
            if {[string match "*ooc*" $fileName]} {
               puts $FH "set_property USED_IN {synthesis implementation out_of_context} \[get_files $file\]"
            } else {
               puts $FH "set_property USED_IN {synthesis implementation} \[get_files $file\]"
            }
         } else {
            if {[string match "*ooc*" $fileName]} {
               puts $FH "set_property USED_IN {implementation out_of_context} \[get_files $file\]"
            } else {
               puts $FH "set_property USED_IN {implementation} \[get_files $file\]"
            }
         }

         if {[string match "*late*" $fileName]} {
            puts $FH "set_property PROCESSING_ORDER late \[get_files $file\]"
         } elseif {[string match "*early*" $fileName]} {
            puts $FH "set_property PROCESSING_ORDER early \[get_files $file\]"
         }
      } else {
         set errMsg "\nERROR: Could not find specified XDC: $file" 
         error $errMsg 
      }
   }
}

###########################################
# Use Module attributes to add all sources
###########################################
proc add_module_sources {module {top 0} } {
   set top_level   [get_attribute module $module top_level]
   set prj         [get_attribute module $module prj]
   set includes    [get_attribute module $module includes]
   set generics    [get_attribute module $module generics]
   set vlogHeaders [get_attribute module $module vlog_headers]
   set vlogDefines [get_attribute module $module vlog_defines]
   set sysvlog     [get_attribute module $module sysvlog]
   set vlog        [get_attribute module $module vlog]
   set vhdl        [get_attribute module $module vhdl]
   set ip          [get_attribute module $module ip]
   set ipRepo      [get_attribute module $module ipRepo]
   set bd          [get_attribute module $module bd]
   set cores       [get_attribute module $module cores]
   set xdc         [get_attribute module $module xdc]
   set synthXDC    [get_attribute module $module synthXDC]
   set implXDC     [get_attribute module $module implXDC]

   if {[llength $prj] > 0} {
      add_module_prj $prj $top
   } 

   #### Read in System Verilog
   if {[llength $sysvlog] > 0} {
      add_module_sysvlog $sysvlog $top
   }
   
   #### Read in Verilog
   if {[llength $vlog] > 0} {
      add_module_vlog $vlog $top 
   }
   
   #### Read in VHDL
   if {[llength $vhdl] > 0} {
      add_module_vhdl $vhdl $top
   }

   #### Read IP from Catalog
   if {[llength $ip] > 0} {
      add_module_ip $ip $top
   }
      
   #### Read IPI systems
   if {[llength $bd] > 0} {
      add_module_bd $bd $top
   }
   
   #### Read in IP Netlists 
   if {[llength $cores] > 0} {
      add_module_cores $cores $top
   }
   
   #### Read in synthXDC files
   if {[llength $synthXDC] > 0} {
      add_module_xdc $synthXDC 2 $top
   }

   #### Read in synthesis/implementation XDC file
   if {[llength $xdc] > 0} {
      add_module_xdc $xdc 1 $top 
   }

   #### Read in implementation XDC file
   if {[llength $implXDC] > 0} {
      add_module_xdc $implXDC 0 $top 
   }
}

###########Project flow commands#####################
#Create paritition_def with specified name and module
proc create_partition {name module} {
   create_partition_def -name $name -module $module 
}

#Add constraints to Static constraints set
proc add_constraints { config } {
   global FH

   puts $FH "create_fileset -constrset $config"
   set implXDC [get_attribute impl $config implXDC]
   foreach xdc $implXDC {
      puts $FH "add_files -fileset $config $xdc"
   }
}

#############################################################
## This Tcl should be called directly from design.tcl where
## all key variables are readily available
#############################################################
#set FH "stdout"
set FH [open "create_$projName.tcl" w]

#Create Project 
puts $FH "create_project $projName $projDir -part $part -force"
puts $FH "set_property PR_FLOW 1 \[current_project\]" 
 
set topModule [get_modules top_level]
add_module_sources $topModule 1
puts $FH "update_compile_order -fileset sources_1"

#Get all modules that are not the top-level
foreach module [get_modules !top_level] {
   set moduleName [get_attribute module $module moduleName]
   lappend Modules($moduleName) $module
}

foreach {module rms} [array get Modules] {
   # module name is optional for the Partition Definition
   puts $FH "\ncreate_partition_def -name ${module}_def -module $module"
   foreach rm $rms {
      puts $FH "\ncreate_reconfig_module -name $rm -partition_def \[get_partition_def ${module}_def\] -top $module"
      add_module_sources $rm
   }
}

###TODO - May need to modify existing design.tcl files to move cores/ip from CONFIG definitions to module definitions so that all files get added to module/top source sets, not configurations
array unset Modules
set parentRuns ""
set childRuns ""
foreach config [get_implementations "dfx.impl impl" &&] {
   set staticState ""
   set partitionList ""
   set greyboxList ""

   foreach partition [get_attribute impl $config partitions] {
      lassign $partition module cell state name type level dcp
      if {[string match $cell $top]} {
         set staticState $state
      } else {
         if {[string match $state greybox]} {
            lappend greyboxList $cell
         } else {
            lappend partitionList $cell:$module
         }
      }
   }

   puts $FH "create_pr_configuration -name $config -partitions \{ $partitionList \} -greyboxes \{ $greyboxList \}"
   if {[string match $staticState "implement"]} {
      add_constraints $config
      lappend parentRuns $config
   } else {
      lappend childRuns $config
   }
}

foreach run $parentRuns {
   if {[string match [get_property DESIGN_MODE [get_filesets sources_1]] "GateLvl"]} {
      puts $FH "create_run $run -pr_config $run -constrset $run -flow \{Vivado Implementation 2016\}"
   } else {
      puts $FH "create_run $run -pr_config $run -parent_run synth_1 -constrset $run -flow \{Vivado Implementation 2016\}"
   }
}
#Delete default impl_1 run and make a parent run the active run
puts $FH "current_run \[get_runs [lindex $parentRuns 0]\]"
puts $FH "delete_runs \[get_runs impl_1\]"

foreach run $childRuns {
   puts $FH "create_run $run -parent_run [lindex $parentRuns 0] -pr_config $run -constrset [lindex $parentRuns 0] -flow \{Vivado Implementation 2016\}"
}
#puts $FH "delete_fileset constrs_1"

if {![string match "stdout" $FH]} {
   close $FH
}

source ./create_$projName.tcl
start_gui
launch_runs $childRuns
foreach run $childRuns {
   wait_on_run $run
}
