# User Generated miscellaneous constraints


set_property HD.RECONFIGURABLE true [get_cells  esp_1/tiles_gen[2].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst]
create_pblock pblock_slot_0
add_cells_to_pblock [get_pblocks pblock_slot_0] [get_cells -quiet [list  esp_1/tiles_gen[2].accelerator_tile.tile_acc_i/tile_acc_1/acc_top_inst]]
resize_pblock [get_pblocks pblock_slot_0] -add {SLICE_X178Y0:SLICE_X187Y199}
resize_pblock [get_pblocks pblock_slot_0] -add {RAMB18_X12Y0:RAMB18_X12Y79}
resize_pblock [get_pblocks pblock_slot_0] -add {RAMB36_X12Y0:RAMB36_X12Y39}
resize_pblock [get_pblocks pblock_slot_0] -add {DSP48_X17Y0:DSP48_X17Y79}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_slot_0]
set_property SNAPPING_MODE ON [get_pblocks pblock_slot_0]


set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
