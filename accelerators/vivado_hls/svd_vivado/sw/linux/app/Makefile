EXTRA_OBJS := $(BUILD_PATH)/libcrunsvd.so
LDFLAGS += -L$(BUILD_PATH)
LDFLAGS += -lcrunsvd

APPNAME := svd
include $(DRIVERS)/common.mk

LIB_CFLAGS ?= -std=gnu++14 -I../../../../../../soft/common/drivers/common/utils

$(BUILD_PATH)/libcrunsvd.so: c_run.cpp $(wildcard *.h)
	@mkdir -p $(BUILD_PATH)
	$(CXX) $(LIB_CFLAGS) $< -shared -fPIC -o $@
