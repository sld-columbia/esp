# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set_time_format -unit ns -decimal_places 3

set tck_ports [get_ports -nowarn {altera_reserved_tck}]
if {[get_collection_size $tck_ports] > 0} {
    create_clock -name {altera_reserved_tck} -period 62.500 $tck_ports
    set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]
}

set tdi_ports [get_ports -nowarn {altera_reserved_tdi}]
set tdo_ports [get_ports -nowarn {altera_reserved_tdo}]
if {[get_collection_size $tdi_ports] > 0 && [get_collection_size $tdo_ports] > 0} {
    set_false_path -from $tdi_ports -to $tdo_ports
}

set jtag_regs [get_registers -nowarn {*~jtag_reg}]
if {[get_collection_size $jtag_regs] > 0 && [get_collection_size $tdo_ports] > 0} {
    set_false_path -from $jtag_regs -to $tdo_ports
}

set ntrst_ports [get_ports -nowarn {altera_reserved_ntrst}]
if {[get_collection_size $ntrst_ports] > 0} {
    set_false_path -from $ntrst_ports
}
