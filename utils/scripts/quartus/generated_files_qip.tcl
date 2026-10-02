# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

if {[llength $argv] != 3 && [llength $argv] != 5} {
    error "usage: generated_files_qip.tcl <output-qip> <top-qip> <ip-dir> ?<qpf> <revision>?"
}

set output_qip [lindex $argv 0]
set top_qip [lindex $argv 1]
set ip_dir [lindex $argv 2]
set project_qpf [lindex $argv 3]
set revision_name [lindex $argv 4]

proc relative_path {from_dir to_path} {
    set from_parts [file split [file normalize $from_dir]]
    set to_parts [file split [file normalize $to_path]]

    while {[llength $from_parts] > 0 &&
           [llength $to_parts] > 0 &&
           [lindex $from_parts 0] eq [lindex $to_parts 0]} {
        set from_parts [lrange $from_parts 1 end]
        set to_parts [lrange $to_parts 1 end]
    }

    set rel_parts {}
    foreach ignored $from_parts {
        lappend rel_parts ..
    }
    set rel_parts [concat $rel_parts $to_parts]

    if {[llength $rel_parts] == 0} {
        return .
    }
    return [file join {*}$rel_parts]
}

proc collect_qips {top_qip ip_dir} {
    set qips {}

    if {$top_qip ne ""} {
        if {![file exists $top_qip]} {
            error "generated top QIP not found: $top_qip"
        }
        lappend qips $top_qip
    }

    if {$ip_dir ne "" && [file isdirectory $ip_dir]} {
        foreach qip [lsort [glob -nocomplain [file join $ip_dir * *.qip]]] {
            lappend qips $qip
        }
    }

    return $qips
}

proc scrub_project_ip_assignments {project_qpf revision_name output_qip} {
    if {$project_qpf eq ""} {
        return
    }
    if {![file exists $project_qpf]} {
        error "Quartus project not found: $project_qpf"
    }

    set project_name [file rootname [file tail $project_qpf]]
    project_open -revision $revision_name $project_name
    remove_all_global_assignments -name QSYS_FILE
    remove_all_global_assignments -name IP_FILE
    remove_all_global_assignments -name QIP_FILE
    set_global_assignment -name QIP_FILE $output_qip
    export_assignments
    project_close
    puts "INFO: updated $project_qpf to use generated synthesis QIP $output_qip"
}

proc assignment_kind {line} {
    if {[regexp -- { -name ([A-Z0-9_]+)( |$)} $line -> kind]} {
        return $kind
    }
    return ""
}

proc rewrite_qip_path {line qip_dir output_dir source_qip} {
    if {![regexp -- {^(.*)\[file join \$::quartus\(qip_path\) "([^"]+)"\](.*)$} $line -> prefix source_rel suffix]} {
        return $line
    }

    set source_file [file normalize [file join $qip_dir $source_rel]]
    if {![file exists $source_file]} {
        error "generated file listed by $source_qip not found: $source_file"
    }

    set rel [relative_path $output_dir $source_file]
    return "$prefix\[file join \$::quartus(qip_path) \"$rel\"\]$suffix"
}

set output_dir [file dirname $output_qip]
set assignments {}
array set seen {}
array set skip_assignment_kind {
    IP_FILE 1
    QIP_FILE 1
    QSYS_FILE 1
    SYNTHESIS_ONLY_QIP 1
}

foreach qip [collect_qips $top_qip $ip_dir] {
    set qip_dir [file dirname $qip]
    set in [open $qip r]
    while {[gets $in line] >= 0} {
        if {![regexp -- {^set_(global|instance)_assignment } $line]} {
            continue
        }

        set kind [assignment_kind $line]
        if {$kind eq "" || [info exists skip_assignment_kind($kind)]} {
            continue
        }

        set rewritten [rewrite_qip_path $line $qip_dir $output_dir $qip]
        if {[info exists seen($rewritten)]} {
            continue
        }

        set seen($rewritten) 1
        lappend assignments $rewritten
    }
    close $in
}

if {[llength $assignments] == 0} {
    error "no generated Quartus assignments found in $top_qip or $ip_dir"
}

file mkdir $output_dir
set out [open $output_qip w]
puts $out "# Auto-generated from Quartus generated QIP files."
puts $out "# Contains local synthesis payload and IP metadata; project-level IP regeneration descriptors are omitted."
puts $out "set_global_assignment -name SYNTHESIS_ONLY_QIP ON"
puts $out ""

foreach assignment $assignments {
    puts $out $assignment
}

close $out
puts "INFO: wrote generated synthesis QIP $output_qip with [llength $assignments] assignments"

scrub_project_ip_assignments $project_qpf $revision_name $output_qip
