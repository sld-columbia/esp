CFLAGS = -I$(DRIVERS)/include -I../include -std=c99 -DUSE_ESP_INTERFACE -DRUN_HW

SRC_S = $(wildcard *.c)
OBJ_S = $(SRC_S:.c=.o)
OBJ_S := $(addprefix  $(BUILD_PATH)/, $(OBJ_S))

TARGET = $(BUILD_PATH)/vitbfly2.exe

compile: $(TARGET)

include $(DRIVERS)/common.mk

$(BUILD_PATH)/%.o: %.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_PATH)/vitbfly2.exe: $(OBJ_S)
	CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS) $(MAKE) -C $(BUILD_PATH)/../../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../../test $(MAKE) -C $(DRIVERS)/test
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../../libesp $(MAKE) -C $(DRIVERS)/libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

.PHONY: compile
