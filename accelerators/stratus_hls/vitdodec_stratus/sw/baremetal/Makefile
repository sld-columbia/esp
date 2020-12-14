target: $(BUILD_PATH)/vitdodec.exe

include $(DRIVERS)/common_bare.mk

$(BUILD_PATH)/vitdodec.exe: vitdodec.c $(wildcard $(DRIVERS)/probe/*.c) $(BUILD_PATH)/do_decoding.o
	CROSS_COMPILE=$(CROSS_COMPILE) DESIGN_PATH=$(DESIGN_PATH) BUILD_PATH=$(BUILD_PATH)/../../probe $(MAKE) -C $(DRIVERS)/probe
	$(CC) -I./ $(CFLAGS) -o $@  $(LDFLAGS) $< $(BUILD_PATH)/do_decoding.o $(BUILD_PATH)/../../probe/libprobe.a

$(BUILD_PATH)/do_decoding.o: do_decoding.c
	$(CC) $(CFLAGS) -c $< -o $@
