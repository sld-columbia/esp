# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set PROJECT_FILE "project.tcl"
set TOOL_VERSION [get_version]
set NIMBUS_OUT_FILE "nimbus.csv"

puts "  _   _ _           _"
puts " | \\ | (_)_ __ ___ | |__  _   _ ___"
puts " |  \\| | | '_ ` _ \\| '_ \\| | | / __|"
puts " | |\\  | | | | | | | |_) | |_| \\__ \\"
puts " |_| \\_|_|_| |_| |_|_.__/ \\__,_|___/"
puts " Nimbus: result post-processing for Cadence Stratus HLS"
puts " Version: $TOOL_VERSION"
puts " Columbia University / giuseppe.diguglielmo@columbia.edu"
puts ""

# Check for project file
set project [ new_BDWProject $PROJECT_FILE ]
if { ! [$project readOK] } {
    puts stderr "ERROR: could not read project"
    exit 1
}
set outfp [open $NIMBUS_OUT_FILE w]

set id 0
puts $outfp "id,module,stimuli,uarch,area,latency,marea,carea,rcount,syntime"
# For each module in the project
foreach mod [$project cynthModules] {
    set mod_name [$mod name]
    # For each simulation configuration
    foreach sim_conf [$project simConfigs] {
	set sim_conf_name [$sim_conf name]
	#set sim_conf_name [lindex [split $sim_conf_name _] 3]; # TODO: hardcoded!
	# Extract the simulation log
	set sim_log [$sim_conf simLog]
	# Extract the synthesis configuration associated w/ the simulation run
	set hls_conf [$sim_conf cynthConfigForModule [$mod name]]
	if { $hls_conf != "NULL" } {
	    set hls_conf_name [$hls_conf name]
	    # Extract the synthesis log
	    set hls_log [$hls_conf cynthHLLog]
	    if { $hls_log != "NULL" } {
		puts "INFO: Gathering HLS results for [$hls_conf name]"
		# Synthesis results
		set total_area [$hls_log totalArea]
		set memory_area [$hls_log memoryArea]
		set combinational_area [$hls_log combinationalArea]
		set register_count [$hls_log regCount]
		set synthesis_time [[lindex [$hls_log allMeasuredTimes] 12] realTime]
		# Simulation results
		set latency [lindex [$sim_log latencies] 0]; # Assumption: there is only one latency object
		if { $latency == "" } {
		    puts "WARNING: Can't find simulation latency for $sim_conf_name"
		} else {
		    set latency_value [$latency value]
		    puts $outfp "$id,$mod_name,$sim_conf_name,$hls_conf_name,$total_area,$latency_value,$memory_area,$combinational_area,$register_count,$synthesis_time"
		    set id [expr $id + 1]
		}
	    }
	}
    }
}

close $outfp

puts "\nResults are saved in: $NIMBUS_OUT_FILE"
