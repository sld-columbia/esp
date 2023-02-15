# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

# Insert here any custom directive

# hls4ml accelerators only have one user-defined configuration register named nbursts
set_directive_interface -mode ap_none "top" conf_info_nbursts

add_files [glob ../hls4ml/firmware/*.cpp] -cflags "-I../inc \
	  -I../hls4ml/firmware -I[file normalize ../hls4ml/firmware/nnet_utils] \
	  -DDMA_SIZE=${dma} -DDATA_BITWIDTH=${width} -std=c++0x "
add_files -tb ../hls4ml/firmware/weights
add_files -tb ../hls4ml/tb_data
catch {config_array_partition -maximum_size 4096}
