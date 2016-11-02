# FPGA and Dev Board used in Design
TECHNOLOGY=Virtex7
PART=XC7VX485T
PACKAGE=ffg1761
PROTOBOARD=xilinx.com:vc707:part0:1.3
SPEED=2
PROMGENPAR=-u 0 $(TOP).bit -p mcs -data_width 16 -w -o $(BOARD)
