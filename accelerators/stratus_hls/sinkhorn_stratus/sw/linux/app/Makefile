
LDFLAGS += -L$(BUILD_PATH)
LDFLAGS += -lcrunhiwa
EXTRA_OBJS := $(BUILD_PATH)/libcrunhiwa.so

#EXTRA_CFLAGS ?= -I$(ESP_ROOT)/accelerators/vivado_hls/svd_vivado/sw/linux/include
EXTRA_CFLAGS ?= -I../../../../../vivado_hls/svd_vivado/sw/linux/include
LIB_CFLAGS ?= -std=gnu++14 -I../../../../../../soft/common/drivers/common/utils

#APPNAME := hiwa hiwa_svd multi_hiwa multi_hiwa2 total_hiwa
include $(DRIVERS)/common.mk

$(BUILD_PATH)/libcrunhiwa.so: c_run.cpp $(wildcard *.h)
	@mkdir -p $(BUILD_PATH)
	$(CXX) $(LIB_CFLAGS) $< -shared -fPIC -o $@
