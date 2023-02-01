# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
include ../../../common/common.mk

ifeq ("$(STRATUS_PATH)", "")
$(error please define STRATUS_PATH required for FlexChannels and FixedPoint library headers)
endif

ifeq ("$(SYSTEMC)", "")
$(error please define SYSTEMC to execute a standalone simulation)
endif

ifeq ("$(DMA_WIDTH)", "")
$(error please define the desired DMA_WIDTH for simulation)
endif

INCDIR ?=
INCDIR += -I../src
INCDIR += -I../tb
INCDIR += -I$(SYSTEMC)/include
INCDIR += -I$(STRATUS_PATH)/share/stratus/include
INCDIR += -I$(ESP_ROOT)/accelerators/stratus_hls/common/inc

CXXFLAGS ?=
CXXFLAGS += -O3
CXXFLAGS += $(INCDIR)
CXXFLAGS += -DDMA_WIDTH=$(DMA_WIDTH)
CXXFLAGS += -DCLOCK_PERIOD=10000

LDFLAGS :=
LDFLAGS += -L$(SYSTEMC)/lib-linux64
LDFLAGS += -lsystemc


TARGET = $(ACCELERATOR)

VPATH ?=
VPATH += ../src
VPATH += ../tb

SRCS :=
SRCS += $(foreach s, $(wildcard ../src/*.cpp) $(wildcard ../tb/*.cpp), $(shell basename $(s)))

OBJS := $(SRCS:.cpp=.o)

HDRS := $(wildcard ../src/*.hpp) $(wildcard ../tb/*.hpp)


all: $(TARGET)

.SUFFIXES: .cpp .hpp .o

$(OBJS): $(HDRS)

$(TARGET): $(OBJS)
	$(QUIET_LINK)$(CXX) -o $@ $^ ${LDFLAGS}

.cpp.o:
	$(QUIET_CXX)$(CXX) $(CXXFLAGS) ${INCDIR} -c $< -o $@

run: $(TARGET)
	$(QUIET_RUN) LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(SYSTEMC)/lib-linux64 ./$< $(RUN_ARGS)

clean:
	$(QUIET_CLEAN)rm -f *.o $(TARGET)

.PHONY: all clean run
