# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set_time_format -unit ns -decimal_places 3

proc create_clock_if_port_exists {clock_name period port_name} {
    set ports [get_ports -nowarn $port_name]
    if {[get_collection_size $ports] > 0} {
        create_clock -name $clock_name -period $period $ports
    }
}

proc false_path_from_port_if_exists {port_name} {
    set ports [get_ports -nowarn $port_name]
    if {[get_collection_size $ports] > 0} {
        set_false_path -from $ports
    }
}

proc false_path_to_port_if_exists {port_name} {
    set ports [get_ports -nowarn $port_name]
    if {[get_collection_size $ports] > 0} {
        set_false_path -to $ports
    }
}

proc false_path_bidir_port_if_exists {port_name} {
    false_path_from_port_if_exists $port_name
    false_path_to_port_if_exists $port_name
}

proc max_skew_to_port_if_exists {port_name skew} {
    set ports [get_ports -nowarn $port_name]
    if {[get_collection_size $ports] > 0} {
        set_max_skew -to $ports $skew
    }
}

create_clock_if_port_exists MAIN_CLOCK 20.000 {CLK_50_B3C}
create_clock_if_port_exists CHIP_REFCLK 20.000 {chip_refclk}
create_clock_if_port_exists EMIF_REF_CLOCK 3.750 {DDR4A_REFCLK_p}
create_clock_if_port_exists PCS_CLOCK 8.000 {enet_refclk}

false_path_from_port_if_exists {CPU_RESET_n}
false_path_from_port_if_exists {reset}

false_path_bidir_port_if_exists {BUTTON[*]}
false_path_bidir_port_if_exists {SW[*]}
false_path_bidir_port_if_exists {switch[*]}
false_path_to_port_if_exists {LED[*]}
false_path_to_port_if_exists {led[*]}

false_path_bidir_port_if_exists {FAN_ALERT_n}
false_path_bidir_port_if_exists {FAN_I2C_SCL}
false_path_bidir_port_if_exists {FAN_I2C_SDA}

max_skew_to_port_if_exists {HPS_EMAC0_MDC} 2.000
max_skew_to_port_if_exists {HPS_EMAC0_MDIO} 2.000
false_path_to_port_if_exists {emac1_phy_rst_n}
false_path_from_port_if_exists {emac1_phy_irq}

set timing_dir [file dirname [file normalize [info script]]]
source [file join $timing_dir jtag.sdc]
