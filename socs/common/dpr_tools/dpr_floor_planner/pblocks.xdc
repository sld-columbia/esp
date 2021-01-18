# User Generated miscellaneous constraints


set_property HD.RECONFIGURABLE true [get_cells  esp_1/tiles_gen[2].accelerator_tile.tile_acc_i ]
create_pblock pblock_slot_0
add_cells_to_pblock [get_pblocks pblock_slot_0] [get_cells -quiet [list  esp_1/tiles_gen[2].accelerator_tile.tile_acc_i ]]
resize_pblock [get_pblocks pblock_slot_0] -add {SLICE_X72Y100:SLICE_X101Y249}
resize_pblock [get_pblocks pblock_slot_0] -add {RAMB18_X5Y40:RAMB18_X6Y99}
resize_pblock [get_pblocks pblock_slot_0] -add {RAMB36_X5Y20:RAMB36_X6Y49}
resize_pblock [get_pblocks pblock_slot_0] -add {DSP48_X6Y40:DSP48_X7Y99}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_slot_0]
set_property SNAPPING_MODE ON [get_pblocks pblock_slot_0]


set_property HD.RECONFIGURABLE true [get_cells  esp_1/tiles_gen[4].accelerator_tile.tile_acc_i ]
create_pblock pblock_slot_1
add_cells_to_pblock [get_pblocks pblock_slot_1] [get_cells -quiet [list  esp_1/tiles_gen[4].accelerator_tile.tile_acc_i ]]
resize_pblock [get_pblocks pblock_slot_1] -add {SLICE_X62Y250:SLICE_X115Y349}
resize_pblock [get_pblocks pblock_slot_1] -add {RAMB18_X5Y100:RAMB18_X6Y139}
resize_pblock [get_pblocks pblock_slot_1] -add {RAMB36_X5Y50:RAMB36_X6Y69}
resize_pblock [get_pblocks pblock_slot_1] -add {DSP48_X5Y100:DSP48_X9Y139}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_slot_1]
set_property SNAPPING_MODE ON [get_pblocks pblock_slot_1]


set_property HD.RECONFIGURABLE true [get_cells  esp_1/tiles_gen[5].accelerator_tile.tile_acc_i ]
create_pblock pblock_slot_2
add_cells_to_pblock [get_pblocks pblock_slot_2] [get_cells -quiet [list  esp_1/tiles_gen[5].accelerator_tile.tile_acc_i ]]
resize_pblock [get_pblocks pblock_slot_2] -add {SLICE_X64Y0:SLICE_X127Y99}
resize_pblock [get_pblocks pblock_slot_2] -add {RAMB18_X5Y0:RAMB18_X7Y39}
resize_pblock [get_pblocks pblock_slot_2] -add {RAMB36_X5Y0:RAMB36_X7Y19}
resize_pblock [get_pblocks pblock_slot_2] -add {DSP48_X5Y0:DSP48_X10Y39}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_slot_2]
set_property SNAPPING_MODE ON [get_pblocks pblock_slot_2]


set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
