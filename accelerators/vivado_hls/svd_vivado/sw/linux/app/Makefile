
EXTRA_OBJS := libcrunsvd.so
CFLAGS += -L.
LDFLAGS += -lcrunsvd
CXX := riscv64-unknown-linux-gnu-g++

APPNAME := svd
include $(DRIVERS)/common.mk

libcrunsvd.so:
	$(CXX) c_run.cpp -L. -shared -fPIC -o $@

