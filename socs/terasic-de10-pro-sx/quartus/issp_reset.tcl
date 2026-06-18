# Use ISSP to assert and deassert the DE10-Pro design reset after programming.

proc getenv_or_empty {name} {
    if {[info exists ::env($name)]} {
        return $::env($name)
    }
    return ""
}

proc match_services {services needle} {
    set matches {}
    foreach service $services {
        if {[string first $needle $service] >= 0} {
            lappend matches $service
        }
    }
    return $matches
}

proc print_services {services} {
    foreach service $services {
        puts "  $service"
    }
}

set all_issp_services [get_service_paths issp]
if {[llength $all_issp_services] == 0} {
    error "ERROR: no ISSP service paths found"
}

set service_match [getenv_or_empty INTEL_ISSP_SERVICE_MATCH]
set board_cable [getenv_or_empty BOARD_CABLE]
set board_cable_match [getenv_or_empty BOARD_CABLE_MATCH]
set board_device_index [getenv_or_empty BOARD_DEVICE_INDEX]

set selectors {}
if {$service_match ne ""} {
    lappend selectors "INTEL_ISSP_SERVICE_MATCH" $service_match
} else {
    if {[regexp {\[([^]]+)\]} $board_cable -> cable_port]} {
        lappend selectors "BOARD_CABLE port" $cable_port
    }
    if {$board_cable_match ne ""} {
        lappend selectors "BOARD_CABLE_MATCH" $board_cable_match
    }
    if {$board_cable ne ""} {
        lappend selectors "BOARD_CABLE" $board_cable
    }
    if {$board_device_index ne ""} {
        lappend selectors "BOARD_DEVICE_INDEX" "@${board_device_index}#"
    }
}

set selected_services {}
set selected_by ""
foreach {selector_name selector_value} $selectors {
    set matches [match_services $all_issp_services $selector_value]
    if {[llength $matches] > 0} {
        set selected_services $matches
        set selected_by "$selector_name='$selector_value'"
        break
    }
}

if {[llength $selected_services] == 0 && [llength $selectors] == 0} {
    set selected_services $all_issp_services
    set selected_by "first available ISSP service"
}

if {[llength $selected_services] == 0} {
    puts "ERROR: no ISSP service path matched the selected board."
    puts "Available ISSP service paths:"
    print_services $all_issp_services
    error "Set INTEL_ISSP_SERVICE_MATCH or BOARD_CABLE_MATCH to a string from the wanted ISSP service path."
}

if {[llength $selected_services] > 1} {
    puts "ERROR: multiple ISSP service paths matched $selected_by."
    puts "Matched ISSP service paths:"
    print_services $selected_services
    error "Set INTEL_ISSP_SERVICE_MATCH to disambiguate the board reset target."
}

set issp [lindex $selected_services 0]
puts "Using ISSP service selected by $selected_by:"
puts "  $issp"

set issp_m [claim_service issp $issp claimGroup]

set current_source_data [issp_read_source_data $issp_m]
puts "src_reset_n value: $current_source_data"

puts "assert src_reset_n via issp"
issp_write_source_data $issp_m 0x0
set current_source_data [issp_read_source_data $issp_m]
puts "src_reset_n value: $current_source_data"

after 500

puts "deassert src_reset_n via issp"
issp_write_source_data $issp_m 0x1
set current_source_data [issp_read_source_data $issp_m]
puts "src_reset_n value: $current_source_data"

close_service issp $issp_m
puts "\nInfo: Closed ISSP Service\n"
