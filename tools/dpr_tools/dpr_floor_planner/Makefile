CC = g++
CFLAGS = -Iflora/include/
CFLAGS += -Iinclude/
CFLAGS += -std=c++17
#CFLAGS += -L$(GUROBI_HOME)/lib
#CFLAGS += -ggdb -g3

LDFLAGS = -lgurobi_g++5.2 -lgurobi_c++ -lgurobi81 -lm -lstdc++fs

all:
	@echo "Please run the make file using the following format"
	@echo ""
	@echo "make flora FPGA=type_of_FPGA"
	@echo "for type of FPGA please use VC707, VCU118 or VCU128"
	@echo " "
	@echo "For example make flora FPGA=VC707"


SOURCES_SHARED = src/csv_data_manipulator.cpp include/fpga.h flora/src/main.cpp

ifeq ($(FPGA),PYNQ)
SOURCES_SHARED += include/pynq.h src/pynq.cpp include/pynq_fine_grained.h src/pynq_fine_grained.cpp
CFLAGS += -DFPGA_PYNQ
else ifeq ($(FPGA),ZYNQ)
SOURCES_SHARED += include/zynq.h src/zynq.cpp include/zynq_fine_grained.h src/zynq_fine_grained.cpp
CFLAGS += -DFPGA_ZYNQ
else ifeq ($(FPGA),VC707)
SOURCES_SHARED += include/vc707.h src/vc707.cpp include/vc707_fine_grained.h src/vc707_fine_grained.cpp
CFLAGS += -DFPGA_VC707
else 
SOURCES_SHARED += include/zynq.h src/zynq.cpp include/zynq_fine_grained.h src/zynq_fine_grained.cpp
CFLAGS += -DFPGA_ZYNQ
endif


ifeq ($(FPGA),VC707)
flora: SOURCES_MILP = src/milp_model_vc707.cpp
endif

flora: SOURCES += flora/src/flora.cpp
flora: BIN = flora
flora: CFLAGS += -DRUN_FLORA
flora: build

build:
	mkdir -p bin	
	$(CC) -o bin/$(BIN) $(CFLAGS) $(SOURCES_SHARED) $(SOURCES_MILP) $(SOURCES) $(LDFLAGS)

.PHONY: clean
clean: 
	rm -f bin/*run*	
