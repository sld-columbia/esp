package require -exact qsys 18.1

set epoch_time [clock seconds]
set sysid_type "altera_avalon_sysid_qsys"
set generic_component_type "altera_generic_component"
set dot_ip_extension ".ip"
set found_sysid_ip_files [list]

set qsys_file_path [get_module_property FILE]
set qsys_file_directory [file dirname ${qsys_file_path}]

foreach inst [get_instances] {
    set inst_type [get_instance_property $inst CLASS_NAME]
    #puts "$inst_type"
    if {$inst_type==$generic_component_type} {
        load_component $inst
        set component_file [get_instantiation_property IP_FILE]
        set extension [file extension ${component_file}]
        #puts "$extension"
        if {$extension==$dot_ip_extension} {
            set type [get_component_property CLASS_NAME]
            #puts "$inst: $type"
            if {$type==$sysid_type} {
                set absolute_ip_file [file join ${qsys_file_directory} ${component_file}]
                #puts $absolute_ip_file
                lappend found_sysid_ip_files ${absolute_ip_file}
            }
        }
    }
}

foreach sysid $found_sysid_ip_files {
    load_system ${sysid}
    #puts [get_module_property GENERATION_ID]
    set_module_property GENERATION_ID $epoch_time
    #puts [get_module_property GENERATION_ID]
    validate_system
    save_system ${sysid}
}
