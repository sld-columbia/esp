# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

include $(ESP_ROOT)/utils/make/leon3_sw.mk

soft: leon3-soft $(SOFT_BUILD)/prom.srec $(SOFT_BUILD)/ram.srec $(SOFT_BUILD)/prom.bin $(SOFT_BUILD)/systest.bin

$(SOFT_BUILD)/systest.bin: $(TEST_PROGRAM)
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary --change-addresses -0x40000000 $< $@

soft-clean: leon3-soft-clean
	@$(RM)			\
	$(SOFT_BUILD)/prom.out	\
	$(SOFT_BUILD)/dummy.exe \
	$(SOFT_BUILD)/xdump.s


soft-distclean: leon3-soft-distclean
	@$(RM) 				\
	$(SOFT_BUILD)/mkprom/		\
	$(SOFT_BUILD)/grlib/		\
	$(SOFT_BUILD)/prom.bin		\
	$(SOFT_BUILD)/systest.bin	\
	$(SOFT_BUILD)/prom.srec 	\
	$(SOFT_BUILD)/ram.srec

.PHONY: leon3-soft-clean leon3-soft-distclean


### Leon3 prom ###

$(SOFT_BUILD)/prom.o: $(BOOTROM_PATH)/prom.S $(BOOTROM_PATH)/prom.h
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_AS) $(CROSS_COMPILE_ELF)gcc -c -I$(BOOTROM_PATH) $< -o $@

$(SOFT_BUILD)/prom.exe: $(SOFT_BUILD)/prom.o
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-nostdlib \
		-Tlinkprom -N \
		-nostartfiles \
		-o $@ $<

$(SOFT_BUILD)/prom.srec: $(SOFT_BUILD)/prom.exe
	$(QUIET_OBJCP)$(CROSS_COMPILE_ELF)objcopy -O srec $< $@

$(SOFT_BUILD)/dummy.exe: $(UTILS_GRLIB)/mkprom2/dummy.c
	$(QUIET_MAKE) $(CROSS_COMPILE_ELF)gcc $< -o $@

$(SOFT_BUILD)/mkprom/mkprom2: $(wildcard $(UTILS_GRLIB)/mkprom2/*.S) $(wildcard $(UTILS_GRLIB)/mkprom2/*.c) $(wildcard $(UTILS_GRLIB)/mkprom2/*.h)
	@mkdir -p $(SOFT_BUILD)/mkprom
	$(QUIET_MAKE) $(MAKE) --quiet -C $(UTILS_GRLIB)/mkprom2 PREFIX=$(SOFT_BUILD)/mkprom

$(SOFT_BUILD)/prom.out: $(SOFT_BUILD)/dummy.exe $(SOFT_BUILD)/mkprom/mkprom2
	@cd $(SOFT_BUILD); \
	./mkprom/mkprom2 -leon3 -freq $(BASE_FREQ_MHZ) -nomsg -baud 38343 -stack $(LEON3_STACK) dummy.exe;

$(SOFT_BUILD)/prom.bin: $(SOFT_BUILD)/prom.out
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary --change-addresses -0x40000000 $< $@

### Leon3 Linux ###

$(SOFT_BUILD)/sysroot:
	@mkdir -p $(SOFT_BUILD)
	$(QUIET_CP)cp -r $(ESP_ROOT)/soft/leon3/sysroot $(SOFT_BUILD)/

$(SOFT_BUILD)/sysroot.files: $(SOFT_BUILD)/sysroot
	$(QUIET_MAKE)$(MAKE) -C ${LINUXSRC}/usr gen_init_cpio
	$(QUIET_INFO)echo "Generating root file-system list..."
	@sh ${LINUXSRC}/scripts/gen_initramfs_list.sh -u `id -u` -g `id -g` $< \
	    | sed -e 's/^file \(\/bin\/busybox .*\) 755 0 0/file \1 4755 0 0/' \
	    > $@;
	@echo  "dir /dev 755 0 0" >> $@
	@echo "dir /proc 755 0 0" >> $@
	@echo "dir /sys 755 0 0" >> $@
	@echo "dir /tmp 755 0 0" >> $@
	@echo "dir /var 755 0 0" >> $@
	@echo "dir /root 700 0 0" >> $@
	@echo "nod /dev/null 666 0 0 c 1 3" >> $@
	@echo "nod /dev/tty1 600 0 0 c 4 1" >> $@
	@echo "nod /dev/ttyS0 600 0 0 c 4 64" >> $@
	@echo "nod /dev/tty 666 0 0 c 5 0" >> $@
	@echo "nod /dev/console 600 0 0 c 5 1" >> $@
	@touch $@

$(SOFT_BUILD)/sysroot.cpio: $(SOFT_BUILD)/sysroot.files
	$(QUIET_BUILD)${LINUXSRC}/usr/gen_init_cpio $< > $@


$(SOFT_BUILD)/linux-build/.config: $(LINUXSRC)/arch/sparc/configs/$(LINUX_CONFIG)
	@$(MAKE) $(SOFT_BUILD)/linux-build
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE)  O=$(SOFT_BUILD)/linux-build -C ${LINUXSRC} $(LINUX_CONFIG)

$(SOFT_BUILD)/linux-build/vmlinux: $(SOFT_BUILD)/sysroot.cpio $(SOFT_BUILD)/linux-build/.config
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) -C $(SOFT_BUILD)/linux-build

$(SOFT_BUILD)/linux.dsu: sysroot-update
	$(QUIET_BUILD)mklinuximg -ethmac $(LINUX_MAC) $(SOFT_BUILD)/linux-build/vmlinux $@

$(SOFT_BUILD)/linux.bin: $(SOFT_BUILD)/linux.dsu
	$(QUIET_OBJCP) $(CROSS_COMPILE_LINUX)objcopy -S -O binary --change-addresses -0x40000000 $< $@

linux: $(SOFT_BUILD)/linux.bin

linux-clean: sysroot-clean
	$(QUIET_CLEAN)
	@if test -e $(SOFT_BUILD)/linux-build; then \
		ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) --quiet -C $(SOFT_BUILD)/linux-build clean; \
	fi;

linux-distclean: sysroot-distclean
	$(QUIET_CLEAN)$(RM) $(SOFT_BUILD)/linux-build $(SOFT_BUILD)/linux.dsu $(SOFT_BUILD)/linux.bin
