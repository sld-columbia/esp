
EXTRA_OBJS := libcrunsvd.so
CFLAGS += -L.
LDFLAGS += -lcrunsvd
CXX := riscv64-unknown-linux-gnu-g++

APPNAME := svd
include $(DRIVERS)/common.mk

LIB_CFLAGS ?= -I../../../../../../soft/common/drivers/common/utils

libcrunsvd.so:
	$(CXX) $(LIB_CFLAGS) c_run.cpp -L. -shared -fPIC -o $@

