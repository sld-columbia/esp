
#OBJS := libcrunhiwa.so #hiwa.exe hiwa_svd.exe multi_hiwa.exe multi_hiwa2.exe total_hiwa.exe
#CFLAGS += -L.
LDFLAGS += -L.
LDFLAGS += -lcrunhiwa
CXX := riscv64-unknown-linux-gnu-g++
EXTRA_OBJS := libcrunhiwa.so

#EXTRA_CFLAGS ?= -I$(ESP_ROOT)/accelerators/vivado_hls/svd_vivado/sw/linux/include
EXTRA_CFLAGS ?= -I../../../../../vivado_hls/svd_vivado/sw/linux/include
LIB_CFLAGS ?= -I../../../../../../soft/common/drivers/common/utils

#APPNAME := hiwa hiwa_svd multi_hiwa multi_hiwa2 total_hiwa
include $(DRIVERS)/common.mk

libcrunhiwa.so:
	$(CXX) $(LIB_CFLAGS) c_run.cpp -L. -shared -fPIC -o $@




