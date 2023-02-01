# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
include ../../../common/common.mk

ifeq ("$(CATAPULT_HOME)", "")
$(error please define CATAPULT_HOME required for Catapult HLS library headers)
endif

ifeq ("$(SYSTEMC)", "")
$(error please define SYSTEMC to execute a standalone simulation)
endif

ifeq ("$(DMA_WIDTH)", "")
$(error DMA_WIDTH variable is not set! Please enter DMA_WIDTH=64 for Ariane or DMA_WIDTH=32 for Leon3 and Ibex before the corresponding make target)
endif

INCDIR ?=
INCDIR += -I../tb
INCDIR += -I../tb/tests
INCDIR += -I../inc
INCDIR += -I../inc/mem_bank/
INCDIR += -I../../../common/inc
INCDIR += -I../../../common/inc/core/systems

INCDIR += -I../../../common/matchlib_toolkit/include
INCDIR += -I../../../common/matchlib_toolkit/examples/systemc-2.3.3/include
INCDIR += -I../../../common/matchlib_toolkit/examples/systemc-2.3.3/src
INCDIR += -I../../../common/matchlib_toolkit/examples/matchlib_connections/include
INCDIR += -I../../../common/matchlib_toolkit/examples/matchlib/cmod/include
INCDIR += -I../../../common/matchlib_toolkit/examples/preprocessor/include
INCDIR += -I../../../common/matchlib_toolkit/examples/rapidjson/include
INCDIR += -I../../../common/matchlib_toolkit/examples/ac_types/include
INCDIR += -I../../../common/matchlib_toolkit/examples/ac_math/include
INCDIR += -I../../../common/matchlib_toolkit/examples/ac_simutils/include

CXXFLAGS ?=
CXXFLAGS += -MMD
CXXFLAGS += -g
CXXFLAGS += -O0
CXXFLAGS += $(INCDIR)
CXXFLAGS += -DDMA_WIDTH=$(DMA_WIDTH)
CXXFLAGS += -DCLOCK_PERIOD=10000
CXXFLAGS += -D__CUSTOM_SIM__
CXXFLAGS += -D__MATCHLIB_CONNECTIONS__
CXXFLAGS += -DHLS_CATAPULT

CXXFLAGS += -DCONNECTIONS_ACCURATE_SIM -DSC_INCLUDE_DYNAMIC_PROCESSES -DCONNECTIONS_NAMING_ORIGINAL

CXXFLAGS += -std=c++11
CXXFLAGS += -Wno-unknown-pragmas
CXXFLAGS += -Wno-unused-variable
CXXFLAGS += -Wno-unused-label
CXXFLAGS += -Wall


SYSTEMC_HOME=../../../common/matchlib_toolkit/examples/systemc-2.3.3

LDLIBS :=
LDLIBS += -L$(SYSTEMC_HOME)/lib -L$(SYSTEMC_HOME)/lib-linux64

LDFLAGS :=
LDFLAGS += -lsystemc
LDFLAGS += -lpthread

TARGET = $(ACCELERATOR)

VPATH ?=
VPATH += ../tb
VPATH += ../tb/tests
VPATH += ../inc
VPATH += ../src
VPATH += ../../../common/inc

SRCS ?=
SRCS += $(foreach s, $(wildcard ../src/*.cpp) $(wildcard ../tb/*.cpp), $(shell basename $(s)))

OBJS := $(SRCS:.cpp=.o)
-include $(OBJS:.o=.d)

HDRS ?=
HDRS += $(wildcard ../inc/*.hpp) $(wildcard ../tb/*.hpp)


all: $(TARGET)

.SUFFIXES: .cpp .hpp .o

$(OBJS): $(HDRS)

$(TARGET): $(OBJS)
	$(QUIET_LINK)$(CXX) -o $@ $^ ${LDFLAGS} ${LDLIBS}

.cpp.o:
	$(QUIET_CXX)$(CXX) $(CXXFLAGS) ${INCDIR} -c $< -o $@

run: $(TARGET)
	$(QUIET_RUN) LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(SYSTEMC_HOME)/lib-linux64 ./$< $(RUN_ARGS)

clean:
	$(QUIET_CLEAN)rm -f *.o *.d *.txt *.vcd $(TARGET)

.PHONY: all clean run
