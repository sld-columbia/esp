OBJS := vitdodec.exe

include $(DRIVERS)/common.mk

$(BUILD_PATH)/vitdodec.exe: vitdodec.c $(BUILD_PATH)/do_decoding.o
	CROSS_COMPILE=$(CROSS_COMPILE) DRIVERS=$(DRIVERS) $(MAKE) -C $(BUILD_PATH)/../../../contig_alloc/ libcontig.a
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../../test $(MAKE) -C $(DRIVERS)/test
	CROSS_COMPILE=$(CROSS_COMPILE) BUILD_PATH=$(BUILD_PATH)/../../../libesp $(MAKE) -C $(DRIVERS)/libesp
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -o $@ $< $(BUILD_PATH)/do_decoding.o $(LDFLAGS)

$(BUILD_PATH)/do_decoding.o: do_decoding.c
	$(CROSS_COMPILE)$(CC) $(CFLAGS) -c $< -o $@
