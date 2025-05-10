#Detect if file is being sourced from "design.tcl", and create log files if so
if {[info exists tclDir]} {
   set runLog "run"
   set commandLog "command"
   set criticalLog "critical"

   set logs [list $runLog $commandLog $criticalLog]
   foreach log $logs {
      if {[file exists ${log}.log]} {
         file copy -force $log.log ${log}_prev.log
      }
   }

   set RFH [open "$runLog.log" w]
   set CFH [open "$commandLog.log" w]
   set WFH [open "$criticalLog.log" w]
}

###############################################################
### Log time of various commands to run log
###############################################################
proc log_time {phase start_time end_time {header 0} {notes ""}} {
   global RFH
   upvar #1 rfh rfh

   if {![info exists rfh]} {
      set rfh "stdout"
   }

   #Define widths of each column
   set widthCol1 19
   set widthCol2 13
   set widthCol3 25
   set widthCol4 85

   #Calculate times based of passed in times
   set total_seconds [expr $end_time - $start_time]
   set total_minutes [expr $total_seconds / 60]
   set total_hours [expr $total_minutes / 60]

   if {$header} {
      puts $rfh "\n| [string repeat - $widthCol1] | [string repeat - $widthCol2] | [string repeat - $widthCol3] | [string repeat - $widthCol4] |"
      puts $rfh [format "| %-*s | %-*s | %-*s | %-*s |" $widthCol1 "Phase" $widthCol2 "Time in Phase" $widthCol3 "Time\/Date" $widthCol4 "Description"]
      puts $rfh "| [string repeat - $widthCol1] | [string repeat - $widthCol2] | [string repeat - $widthCol3] | [string repeat - $widthCol4] |"
      if {[info exists RFH]} {
         puts $RFH "\n| [string repeat - $widthCol1] | [string repeat - $widthCol2] | [string repeat - $widthCol3] | [string repeat - $widthCol4] |"
         puts $RFH [format "| %-*s | %-*s | %-*s | %-*s |" $widthCol1 "Phase" $widthCol2 "Time in Phase" $widthCol3 "Time\/Date" $widthCol4 "Description"]
         puts $RFH "| [string repeat - $widthCol1] | [string repeat - $widthCol2] | [string repeat - $widthCol3] | [string repeat - $widthCol4] |"
      }
   }

   if {[string match $phase final]} {
      set time "[format %02d [expr $total_hours]]h:[format %02d [expr $total_minutes-($total_hours*60)]]m:[format %02d [expr $total_seconds-($total_minutes*60)]]s"
      puts $rfh "Total time:\t\t$time\n\n"
      if {[info exists RFH]} {
         puts $RFH "Total time:\t\t$time\n\n"
      }
   } else {
      set time "[format %02d [expr $total_hours]]h:[format %02d [expr $total_minutes-($total_hours*60)]]m:[format %02d [expr $total_seconds-($total_minutes*60)]]s"
      set date "[clock format $start_time -format {%H:%M:%S %a %b %d %Y}]"
      puts $rfh [format "| %-*s | %-*s | %-*s | %-*s |" $widthCol1 "$phase" $widthCol2 "$time" $widthCol3 "$date" $widthCol4 "$notes"]
      puts $rfh "| [string repeat - $widthCol1] | [string repeat - $widthCol2] | [string repeat - $widthCol3] | [string repeat - $widthCol4] |"
      if {[info exists RFH]} {
         puts $RFH [format "| %-*s | %-*s | %-*s | %-*s |" $widthCol1 "$phase" $widthCol2 "$time" $widthCol3 "$date" $widthCol4 "$notes"]
         puts $RFH "| [string repeat - $widthCol1] | [string repeat - $widthCol2] | [string repeat - $widthCol3] | [string repeat - $widthCol4] |"
      } 
   } 
   if {[info exists RFH]} {
      flush $RFH
   }
   if {![string match $rfh "stdout"]} {
      flush $rfh
   }
}

###############################################################
### Log any commands to specified command log file
### Check for errors with catch and return error messages
### Automatically write out current in-memory design if error
### Supports a redirect file for each command 
### e.g. command "opt_design -directive <val>" "opt.log"
### Print command to STDOUT if verbose > 1 
###############################################################
proc command { command  {log ""} {quiet 0} } {
   global verbose CFH
   upvar #1 cfh cfh
   
   if {![info exists cfh]} {
      set cfh "stdout"
   }

   if {![info exists CFH]} {
      set CFH "stdout"
   }

   #Write all commands to command.log if file hanlde exists
   if {![string match $cfh "stdout"]} {
      if {[llength $log]} {
         puts $cfh "$command \> $log"
      } else {
         puts $cfh $command
      }
      flush $cfh
   }
   if {![string match $CFH "stdout"]} {
      if {[llength $log]} {
         puts $CFH "$command \> $log"
      } else {
         puts $CFH $command
      }
      flush $CFH
   }

   #ignore new-line, comments, or if verbose=0 (to generate scripts only)
   if {[string match "\n" $command] || [string match "#*" $command] || !$verbose} {
      return 0
   }

   if {$verbose > 1} {
      puts "\tCOMMAND: $command"
   }

   set commandName [lindex [split $command] 0]
   if {[llength $log] > 0} {
      if { [catch "$command > $log" errMsg] && !$quiet } {
         puts "#HD: Command \'$commandName\' failed! Parsing $log for relavant messages"
         parse_log $log
         regexp {(\.*.*)(\..*)} $log matched logName logType
         #If design is open write out a debug DCP
         if { ![catch {current_instance}] } {
            puts "#HD: Writing checkpoint ${logName}_error.dcp for debug."
            command "write_checkpoint -force ${logName}_error.dcp"
         }
         #upvar start_time start_time
         upvar #1 start_time start_time
         set end_time [clock seconds]
         log_time $commandName $start_time $end_time 0 $errMsg
         append errMsg "\nERROR: $commandName command \"$command\" failed.\nSee log file $log for more details."
         error $errMsg
      }
      #Prevent messages from being dumped to terminal if quiet mode
      if {!$quiet} {
         parse_log $log
      }
   } else {
      if { [catch $command errMsg] && !$quiet} {
         append errMsg "\nERROR: $commandName command failed.\n\t$command\n"
         error $errMsg
      }
   }
}

###############################################################
### Log any commands to command log file
### Check for errors
### Print command to STDOUT if verbose > 1 
###############################################################
proc parse_log { log } {
   global RFH WFH
   upvar #1 wfh wfh
   upvar #1 rfh rfh

   set warningFiles ""
   if {[info exists WFH]} {
      lappend warningFiles $WFH
   }
   if {[info exists wfh]} {
      lappend warningFiles $wfh
   }

   set runFiles ""
   if {[info exists rfh]} {
      lappend runFiles $rfh
   }
   if {[info exists RFH]} {
      lappend runFiles $RFH
   }

   set log_data ""
   set log_lines ""
   if {[file exists $log]} {
      set lfh [open $log r]
      set log_data [read $lfh]
      close $lfh
      set log_lines [split $log_data "\n" ]
   } else {
      puts "ERROR: Could not find specified log file \"$log\"."
   }

   foreach fh $warningFiles {
      puts $fh "\t#HD: Parsing log file \"$log\":"
      foreach line $log_lines {
         if {[string match "CRITICAL WARNING*" $line]} {
            puts $fh "\t$line"
         }
      }
      puts $fh "\n"
      flush $fh
   }

   foreach fh $runFiles {
      foreach line $log_lines {
         if {[string match "ERROR:*" $line]} {
            puts $fh $line
            puts $line
         }
      }
      flush $fh
   }

}

###############################################################
### Proc to parse timing summary (report or string) for timing 
###############################################################
proc getTimingInfo { {report {}} } {
   global RFH
   upvar #1 rfh rfh

   if {![info exists RFH]} {
      set RFH "stdout"
   }

   if {$report == {}} { 
      set report [split [report_timing_summary -no_detailed_paths -no_check_timing -no_header -return_string] \n]
   } else {
      set report [split $report \n]
   }

   foreach {wns tns tnsFailingEp tnsTotalEp whs ths thsFailingEp thsTotalEp wpws tpws tpwsFailingEp tpwsTotalEp} [list {N/A} {N/A} {N/A} {N/A} {N/A} {N/A} {N/A} {N/A} {N/A} {N/A} {N/A} {N/A}] { 
      break 
   }
   if {[set i [lsearch -regexp $report {Design Timing Summary}]] != -1} {
      foreach {wns tns tnsFailingEp tnsTotalEp whs ths thsFailingEp thsTotalEp wpws tpws tpwsFailingEp tpwsTotalEp} [regexp -inline -all -- {\S+} [lindex $report [expr $i + 6]]] { 
         break 
      }
   }
   puts "Setup:\n\t| WNS=$wns | TNS=$tns | Failing Endpoints=$tnsFailingEp | Total Endpoints=$tnsTotalEp |"
   puts "Hold:\n\t| WHS=$whs | THS=$ths | Failing Endpoints=$thsFailingEp | Total Endpoints=$thsTotalEp |"
   puts "Pulse Width:\n\t | WPWS=$wpws | TPWS=$tpws | Failing Endpoints=$tpwsFailingEp | Total Endpoints=$tpwsTotalEp |\n\n"
   puts $RFH "Setup:\n\t| WNS=$wns | TNS=$tns | Failing Endpoints=$tnsFailingEp | Total Endpoints=$tnsTotalEp |"
   puts $RFH "Hold:\n\t| WHS=$whs | THS=$ths | Failing Endpoints=$thsFailingEp | Total Endpoints=$thsTotalEp |"
   puts $RFH "Pulse Width:\n\t | WPWS=$wpws | TPWS=$tpws | Failing Endpoints=$tpwsFailingEp | Total Endpoints=$tpwsTotalEp |\n\n"
   puts $rfh "Setup:\n\t| WNS=$wns | TNS=$tns | Failing Endpoints=$tnsFailingEp | Total Endpoints=$tnsTotalEp |"
   puts $rfh "Hold:\n\t| WHS=$whs | THS=$ths | Failing Endpoints=$thsFailingEp | Total Endpoints=$thsTotalEp |"
   puts $rfh "Pulse Width:\n\t | WPWS=$wpws | TPWS=$tpws | Failing Endpoints=$tpwsFailingEp | Total Endpoints=$tpwsTotalEp |\n\n"
}

###############################################################
### Read specified file, split per line, and return list 
###############################################################
proc read_file_lines {file} {
   if {![file exists $file]} {
      puts "Error: Specified file $file does not exist. Please check path."
      return
   }
   set fh [open $file r]
   set fileData [read $fh]
   close $fh
   set fileLines [split $fileData "\n" ]
   return $fileLines
}

#################################################
# Proc to print out data in a table format
# Table column sizes are determined by script
# All rows must have the same number of entries,
# but blank values ("") can be passed in as well
#### Example usage:
# set clocks [get_nets -of [get_pins -filter DIRECTION==OUT -of [get_cells -hier -filter REF_NAME=~BUF*]]]
# set row0 {Clock Driver "Number of Loads"}
# set count 1
# foreach clock $clocks {
#     set row${count} $clock 
#     lappend row${count} [get_cells -of [get_pins -leaf -filter DIRECTION==OUT -of [get_nets $clock]]] 
#     lappend row${count} [llength [get_pins -leaf -filter DIRECTION==IN -of [get_nets $clock]]]
#     incr count
#  }
# print_table -title "Clocks: [llength $clocks]" -row $row0 -row $row1 -row $row2

# Clocks: 2:
# | ----------------------- | ---------------------- | ---------------- |
# | Clock                   | Driver                 | Number of Loads  |
# | ----------------------- | ---------------------- | ---------------- |
# | U0_clocks/clkfbout_buf  | U0_clocks/clkf_buf     | 1                |
# | ----------------------- | ---------------------- | ---------------- |
# | U0_clocks/clk_out       | U0_clocks/clkout1_buf  | 65               |
# | ----------------------- | ---------------------- | ---------------- |
#################################################
proc print_table { args } {
   set args [join $args]
   set title "Table"
   set FH "stdout"

   #Override defaults with command options
   set argLength [llength $args]
   set index 0
   set rowCount 0
   while {$index < $argLength} {
      set arg [lindex $args $index]
      set value [lindex $args [expr $index+1]]
      switch -exact -- $arg {
         {-title}    {set title $value}
         {-row}      {dict set rows row${rowCount} $value
                      incr rowCount
                     }
         {-file}     {set FH [open $value w]}
         {-handle}   {upvar $value FH}
         {-help}     {set     helpMsg "Description:"
                      lappend helpMsg "Prints out a table in order the Rows are specified.\n"
                      lappend helpMsg "Syntax:"
                      lappend helpMsg "print_table\t\[-row <row1>] ... \[-row <rowN] \[-file <arg>]\n"
                      lappend helpMsg "Usage:"
                      lappend helpMsg "  Name                        Description"
                      lappend helpMsg "  -------------------------------------------------------------------------------"
                      lappend helpMsg "  \[-title]                    Optional. Defines the title of the table."
                      lappend helpMsg "                              A default table name is used if no title is defined" 
                      lappend helpMsg "  \[-row]                      Required. Defines a Row of the table to be printed."
                      lappend helpMsg "                              The order the rows are defined is the print order." 
                      lappend helpMsg "  \[-file]                     Optional. Specifies the output file name."
                      lappend helpMsg "                              If not specified the output will be written to STDOUT"
                      lappend helpMsg "  \[-help]                     Displays this message\n\n"
                      foreach line $helpMsg {
                         puts $FH $line
                      }
                      return
                     }
         default     {set errMsg "ERROR: Specified argument $arg is not supported.\n"
                      append errMsg "Supported arguments are -help, -title, -row, and -file.\n"
                      append errMsg "Use the -help option for more details"
                      error $errMsg 
                     }
      }
      set index [expr $index + 2]
   }


   #Create an array for column widths for each header entry
   set headers [dict get $rows row0]
   set colCount 0
   set colTotal [llength $headers]
   foreach header $headers {
      set colWidth($colCount) [expr [string length $header] + 1]
      incr colCount
   }

   
   #Get max length of entry, and update colWidth if necessary
   dict for {row entries} $rows {
      set colCount 0
      set rowTotal [llength $entries]
      if {$rowTotal != $colTotal} {
         set errMsg "Error: The number of entries for $row does match the number of entries for row0.\n"
         append errMsg "row0: [dict get $rows row0]\n"
         append errMsg "$row: [dict get $rows $row]\n"
         error $errMsg
      }
      foreach cell $entries {
         set length [expr [string length $cell] + 1]
         #puts "$colCount: $cell: $length"
         if {$length > $colWidth($colCount) } {
            set colWidth($colCount) $length
         }
         incr colCount
      }
   }

   #Create a string to seperate each row/column of data
   set separator "|"
   set colCount 0
   foreach {key value} [array get colWidth] {
      set width $colWidth($colCount)
      append separator " [string repeat - $width] |"
      incr colCount
   }

   #Create the necessary string for each row to be used with "format" command
   #[format "| %-*s | %-*s | %-*s | %-*s | %-*s | %-*s |" $width1 $value1 $width2 $value2 ... $widthN $valueN]
   set rowCount 0
   dict for {row entries} $rows {
      dict set table row${rowCount} "\"|"
      foreach cell $entries {
         dict append table row${rowCount} " %-*s |"
      }
      dict append table row${rowCount} "\""
      #puts "[dict get $table row${rowCount}]"
      incr rowCount
   }

   #Add additional information to each row to complete information needed for "format" command
   #[format "| %-*s | %-*s | %-*s | %-*s | %-*s | %-*s |" $width1 $value1 $width2 $value2 ... $widthN $valueN]
   set rowCount 0
   dict for {row entries} $rows {
      set col 0
      foreach cell $entries {
         dict append table row${rowCount} " $colWidth($col) \"$cell\""
         incr col
      }
      #puts "[dict get $table row${rowCount}]"
      incr rowCount
   }

   #Print the Table
   puts $FH "\n$title:"
   dict for {row value} $table {
      puts $FH $separator
      puts $FH [eval format $value]
   }
   puts $FH "$separator\n"

   #Close the file handle if -file was specified
   if {![string match $FH "stdout"]} {
      close $FH
   }
}
