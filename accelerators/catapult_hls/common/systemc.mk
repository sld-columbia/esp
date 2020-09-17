include ../../common/common.mk

ifeq ("$(CATAPULT_PATH)", "")
$(error please define CATAPULT_PATH required for Catapult HLS library headers)
endif

ifeq ("$(MGC_HOME)", "")
$(error please define MGC_HOME required for Catapult HLS library headers)
endif

ifeq ("$(SYSTEMC)", "")
$(error please define SYSTEMC to execute a standalone simulation)
endif

ifeq ("$(DMA_WIDTH)", "")
$(error please define the desired DMA_WIDTH for simulation)
endif

INCDIR ?=
INCDIR += -I../tb
INCDIR += -I../tb/tests
INCDIR += -I../inc
INCDIR += -I../../common
INCDIR += -I$(SYSTEMC)/include
#INCDIR += -I$(CATAPULT_PATH)/shared/include
INCDIR += -I$(MGC_HOME)/shared/include
INCDIR += -I$(ESP_ROOT)/accelerators/catapult_hls/common/syn-templates
INCDIR += -I$(ESP_ROOT)/accelerators/catapult_hls/common/matchlib/cmod/include
INCDIR += -I$(BOOST_HOME)/include

CXXFLAGS ?=
CXXFLAGS += -MMD
CXXFLAGS += -g
CXXFLAGS += -O0
CXXFLAGS += $(INCDIR)
CXXFLAGS += -DDMA_WIDTH=$(DMA_WIDTH)
CXXFLAGS += -DCLOCK_PERIOD=10000
CXXFLAGS += -D__CUSTOM_SIM__
CXXFLAGS += -D__MATCHLIB_CONNECTIONS__
#CXXFLAGS += -D__MNTR_AC_SHARED__
CXXFLAGS += -DHLS_CATAPULT
CXXFLAGS += -std=c++11
CXXFLAGS += -Wno-unknown-pragmas
CXXFLAGS += -Wno-unused-variable
CXXFLAGS += -Wno-unused-label
CXXFLAGS += -Wall
#CXXFLAGS += -DDMA_SINGLE_PROCESS

LDLIBS :=
LDLIBS += -L$(MGC_HOME)/shared/lib
#LDLIBS += -L$(CATAPULT_PATH)/shared/lib

LDFLAGS :=
LDFLAGS += -lsystemc
LDFLAGS += -lpthread

TARGET = $(ACCELERATOR)

VPATH ?=
VPATH += ../tb
VPATH += ../tb/tests
VPATH += ../inc
VPATH += ../src
VPATH += ../../common
#VPATH += $(ESP_ROOT)/accelerators/catapult_hls/common/syn-templates/core/systems

SRCS ?=
SRCS += $(foreach s, $(wildcard ../src/*.cpp) $(wildcard ../tb/*.cpp), $(shell basename $(s)))
#SRCS += $(foreach s, $(wildcard $(ESP_ROOT)/accelerators/catapult_hls/common/syn-templates/core/systems/*.cpp), $(shell basename $(s)))

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
	$(QUIET_RUN) LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(SYSTEMC)/lib-linux64 ./$< $(RUN_ARGS)

clean:
	$(QUIET_CLEAN)rm -f *.o *.d *.txt *.vcd $(TARGET)

.PHONY: all clean run
