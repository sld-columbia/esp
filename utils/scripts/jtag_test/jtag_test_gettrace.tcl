# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

## Use the following for single tile
set target_tile $::env(JTAG_TEST_TILE)
set target_instance [lsearch -all -inline -regexp [find instances -bydu -nodu jtag_test] "tiles_gen\\($target_tile\\)"]

## Use the following for multiple tiles
# set target_instance [find instances -bydu -nodu jtag_test]

set target_ports { \
		       input_port \
		       data_void_in \
		       stop_out \
		       output_port \
		       data_void_out \
		       stop_in \
		   }

proc inst_to_tile_name { inst } {
    set RE /testbench/top_1/chip_i/chip_i/
    set tmp1 [regsub -all $RE $inst ""]
    set RE /.*/.*/jtag_test_i
    set tmp2 [regsub -all $RE $tmp1 ""]
    set tmp3 [regsub \\( $tmp2 "_"]
    set name [regsub \\) $tmp3 ""]
    return $name
}

set name [inst_to_tile_name $target_instance]
#foreach inst $target_instance {
#set name [inst_to_tile_name $inst]

view -new -title $name list

    foreach noc {1 2 3 4 5 6} {
	foreach port $target_ports {
    	    add list ${target_instance}/test${noc}_${port} -window $name
    	}
    }
    configure list -window $name -usestrobe 0
    configure list -window $name -strobestart {0 ps} -strobeperiod {0 ps}
    configure list -window $name -usesignaltrigger 1
    configure list -window $name -delta none
    # configure list -window $name -signalnamewidth 1
    configure list -window $name -datasetprefix -1
    # configure list -window $name -namelimit 0
#}

# This is enough for Hello world.
run 130 us

view list -window $name -dock
write list -window $name jtag/$name.lst

# foreach inst $target_instance {
#     set name [inst_to_tile_name $inst]
#     # Force current active window
#     view list -window $name -dock
#     # Save window
#     write list -window $name $name.lst
# }

quit -f
