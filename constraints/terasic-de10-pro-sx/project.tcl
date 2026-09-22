# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

if {[llength $argv] != 8} {
    error "usage: project.tcl <qpf> <revision> <device> <top> <constraints-dir> <srcs-auto> <qsys-file> <fpga-dir>"
}

set project_qpf [lindex $argv 0]
set revision_name [lindex $argv 1]
set device_name [lindex $argv 2]
set top_entity [lindex $argv 3]
set constraints_dir [lindex $argv 4]
set srcs_auto [lindex $argv 5]
set qsys_file [lindex $argv 6]
set fpga_dir [lindex $argv 7]

proc env_or_default {name default_value} {
    if {[info exists ::env($name)]} {
        set value [set ::env($name)]
        if {$value ne ""} {
            return $value
        }
    }
    return $default_value
}

proc qsys_generated_qip {qsys_file} {
    set qsys_dir [file rootname $qsys_file]
    set qsys_base [file rootname [file tail $qsys_file]]
    return [file join $qsys_dir "${qsys_base}.qip"]
}

proc qsys_generated_files_qip {qsys_file} {
    set qsys_dir [file rootname $qsys_file]
    set qsys_base [file rootname [file tail $qsys_file]]
    return [file join $qsys_dir "${qsys_base}_files.qip"]
}

set project_name [file rootname [file tail $project_qpf]]
set qsys_project_mode [env_or_default QUARTUS_QSYS_PROJECT_MODE qsys]
set qsys_files_qip [env_or_default QUARTUS_QSYS_FILES_QIP [qsys_generated_files_qip $qsys_file]]

foreach required_file [list \
    [file join $constraints_dir pins.tcl] \
    [file join $constraints_dir timing.sdc] \
    [file join $constraints_dir jtag.sdc] \
    [file join $fpga_dir $top_entity.v] \
    $srcs_auto] {
    if {![file exists $required_file]} {
        error "required Quartus input not found: $required_file"
    }
}

if {[file exists $project_qpf]} {
    project_open -revision $revision_name $project_name
} else {
    project_new -revision $revision_name $project_name
}

set_global_assignment -name FAMILY "Stratix 10"
set_global_assignment -name DEVICE $device_name
set_global_assignment -name TOP_LEVEL_ENTITY $top_entity
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2009

set_global_assignment -name USE_CONF_DONE SDM_IO16
set_global_assignment -name USE_HPS_COLD_RESET SDM_IO15
set_global_assignment -name HPS_INITIALIZATION "AFTER INIT_DONE"
set_global_assignment -name HPS_DAP_SPLIT_MODE "SDM PINS"
set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "ACTIVE SERIAL X4"
set_global_assignment -name ENABLE_SIGNALTAP ON
set_global_assignment -name INI_VARS "ASM_ENABLE_ADVANCED_DEVICES=ON;hps_dump_handoff_data=on"

set_global_assignment -name USE_PWRMGT_SCL SDM_IO0
set_global_assignment -name USE_PWRMGT_SDA SDM_IO12
set_global_assignment -name VID_OPERATION_MODE "PMBUS MASTER"
set_global_assignment -name PWRMGT_BUS_SPEED_MODE "400 KHZ"
set_global_assignment -name PWRMGT_SLAVE_DEVICE_TYPE OTHER
set_global_assignment -name PWRMGT_SLAVE_DEVICE0_ADDRESS 4F
set_global_assignment -name PWRMGT_PAGE_COMMAND_ENABLE ON
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "AUTO DISCOVERY"
set_global_assignment -name PWRMGT_TRANSLATED_VOLTAGE_VALUE_UNIT VOLTS
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100

source $srcs_auto
source [file join $constraints_dir pins.tcl]

set_global_assignment -name SDC_FILE [file join $constraints_dir timing.sdc]
set_global_assignment -name SDC_FILE [file join $constraints_dir jtag.sdc]

if {$qsys_file ne ""} {
    switch -- $qsys_project_mode {
        qsys {
            set_global_assignment -name QSYS_FILE $qsys_file
        }
        generated-qip {
            set_global_assignment -name QIP_FILE [qsys_generated_qip $qsys_file]
        }
        generated-files-qip {
            set_global_assignment -name QIP_FILE $qsys_files_qip
        }
        none {
        }
        default {
            error "unsupported QUARTUS_QSYS_PROJECT_MODE '$qsys_project_mode'; expected qsys, generated-qip, generated-files-qip, or none"
        }
    }
}

export_assignments
project_close
