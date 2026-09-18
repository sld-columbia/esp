# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

proc env_or_empty {name} {
    if {[info exists ::env($name)]} {
        return $::env($name)
    }
    return ""
}

proc matching_services {services text} {
    set matches {}
    foreach service $services {
        if {[string first $text $service] >= 0} {
            lappend matches $service
        }
    }
    return $matches
}

proc print_service_list {services} {
    foreach service $services {
        puts "  $service"
    }
}

set services [get_service_paths issp]
if {[llength $services] == 0} {
    error "ERROR: no ISSP service paths found"
}

set selectors {}
set explicit_match [env_or_empty INTEL_ISSP_SERVICE_MATCH]
set cable [env_or_empty BOARD_CABLE]
set cable_match [env_or_empty BOARD_CABLE_MATCH]
set device_index [env_or_empty BOARD_DEVICE_INDEX]

if {$explicit_match ne ""} {
    lappend selectors "INTEL_ISSP_SERVICE_MATCH" $explicit_match
} else {
    if {[regexp {\[([^]]+)\]} $cable -> cable_port]} {
        lappend selectors "BOARD_CABLE port" $cable_port
    }
    if {$cable_match ne ""} {
        lappend selectors "BOARD_CABLE_MATCH" $cable_match
    }
    if {$cable ne ""} {
        lappend selectors "BOARD_CABLE" $cable
    }
    if {$device_index ne ""} {
        lappend selectors "BOARD_DEVICE_INDEX" "@${device_index}#"
    }
}

set selected {}
set selected_by "available ISSP services"

if {[llength $selectors] == 0} {
    set selected $services
} else {
    foreach {name value} $selectors {
        set matches [matching_services $services $value]
        if {[llength $matches] > 0} {
            set selected $matches
            set selected_by "$name='$value'"
            break
        }
    }
}

if {[llength $selected] == 0} {
    puts "Available ISSP service paths:"
    print_service_list $services
    error "ERROR: no ISSP service matched the selected board"
}

if {[llength $selected] > 1} {
    puts "Matched ISSP service paths:"
    print_service_list $selected
    error "ERROR: multiple ISSP services matched $selected_by; set INTEL_ISSP_SERVICE_MATCH"
}

set service_path [lindex $selected 0]
puts "Using ISSP service selected by $selected_by:"
puts "  $service_path"

set service [claim_service issp $service_path espReset]

puts "src_reset_n before reset: [issp_read_source_data $service]"
puts "assert src_reset_n"
issp_write_source_data $service 0x0
after 500

puts "deassert src_reset_n"
issp_write_source_data $service 0x1
puts "src_reset_n after reset: [issp_read_source_data $service]"

close_service issp $service
puts "Info: closed ISSP service"
