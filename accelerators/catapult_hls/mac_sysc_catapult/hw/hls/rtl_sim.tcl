#Copyright (c) 2011-2023 Columbia University, System Level Design Group
#SPDX-License-Identifier: Apache-2.0

source ../../../common/hls/common.tcl

project load ${ACCELERATOR}_dma${DMA_WIDTH}.ccs

flow run /SCVerify/launch_make ./scverify/Verify_concat_sim_${ACCELERATOR}_v_msim.mk {} SIMTOOL=msim sim
