# Copyright (c) 2011-2019 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

# User-defined configuration ports
# <<--directives-param-->>

set_directive_interface -mode ap_none "top" conf_info_q
set_directive_interface -mode ap_none "top" conf_info_p
set_directive_interface -mode ap_none "top" conf_info_m
set_directive_interface -mode ap_none "top" conf_info_p2p_out
set_directive_interface -mode ap_none "top" conf_info_p2p_in
set_directive_interface -mode ap_none "top" conf_info_p2p_iter
set_directive_interface -mode ap_none "top" conf_info_load_state

set_directive_array_partition -type cyclic -factor 2 -dim 1 "top" _inbuff
set_directive_array_partition -type cyclic -factor 2 -dim 1 "top" _outbuff

set_directive_array_partition -type cyclic -factor 2 -dim 1 "load" tmp
set_directive_pipeline "load/load_label1"

# set_directive_dataflow "load"
# set_directive_dataflow "store"
# set_directive_dataflow "compute"

# Insert here any custom directive
# set_directive_unroll -factor 8 "load"
# set_directive_unroll -factor 8 "store"
set_directive_pipeline -II 125 "compute/LOOP_Q1"
set_directive_pipeline -II 2 "compute/LOOP_X1"
# set_directive_pipeline "compute/LOOP_X2"
set_directive_pipeline -II 2 "compute/LOOP_Y1"
set_directive_pipeline -II 2 "compute/LOOP_A1"
set_directive_pipeline "compute/LOOP_A3"
set_directive_pipeline "compute/LOOP_OUT11"
set_directive_pipeline "compute/LOOP_OUT22"
set_directive_pipeline "compute/LOOP_OUT33"
# set_directive_pipeline "compute/LOOP_OUT4"

# set_directive_array_partition -type cyclic -factor 16 -dim 1 "compute" Y
# set_directive_array_partition -type cyclic -factor 3 -dim 2 "compute" Y
# set_directive_array_partition -type cyclic -factor 16 -dim 1 "compute" X
# set_directive_array_partition -type cyclic -factor 3 -dim 2 "compute" X
# set_directive_array_partition -type cyclic -factor 3 -dim 0 "compute" T
# set_directive_array_partition -type cyclic -factor 16 -dim 2 "compute" Q
# set_directive_array_partition -type cyclic -factor 16 -dim 2 "compute" C
# set_directive_array_partition -type cyclic -factor 3 -dim 1 "compute" A
# set_directive_array_partition -type cyclic -factor 3 -dim 2 "compute" A
set_directive_array_partition -type complete -dim 0 "compute" A
# set_directive_array_partition -type cyclic -factor 3 -dim 1 "compute" A_f
# set_directive_array_partition -type cyclic -factor 3 -dim 2 "compute" A_f
set_directive_array_partition -type complete -dim 0 "compute" A_f
# set_directive_array_partition -type cyclic -factor 3 -dim 1 "compute" U_f
# set_directive_array_partition -type cyclic -factor 3 -dim 2 "compute" U_f
# set_directive_array_partition -type cyclic -factor 3 -dim 1 "compute" S_f
# set_directive_array_partition -type cyclic -factor 16 -dim 2 "compute" X_SINK
# set_directive_array_partition -type cyclic -factor 16 -dim 2 "compute" Y_SINK

# set_directive_array_partition -type cyclic -factor 3 -dim 1 "top" Q
# set_directive_array_partition -type cyclic -factor 3 -dim 1 "compute" C
# set_directive_array_partition -type cyclic -factor 3 -dim 1 "compute" X
# set_directive_array_partition -type cyclic -factor 3 -dim 2 "top" Y
# set_directive_array_partition -type cyclic -factor 3 -dim 1 "compute" T
