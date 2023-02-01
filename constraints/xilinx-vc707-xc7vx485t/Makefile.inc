# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
# FPGA and Dev Board used in Design
PART=XC7VX485T
PACKAGE=ffg1761
PROTOBOARD=xilinx.com:vc707:part0:1.4
SPEED=2
PROMGENPAR=-u 0 $(TOP).bit -p mcs -data_width 16 -w -o $(BOARD)
