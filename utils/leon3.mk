# Copyright (c) 2011-2020 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

soft: leon3-soft prom.srec ram.srec prom.bin systest.bin

systest.bin: $(TEST_PROGRAM)
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary --change-addresses -0x40000000 $< $@

soft-clean: leon3-soft-clean ahbrom-clean
	@$(RM)			\
	prom.out		\
	xdump.s			\
	mkprom2			\
	lib			\
	linkprom		\
	linkbch			\
	linkpromerc32		\
	linkpromecos		\
	linkpromflash		\
	linkpromerc32flash	\
	linkpromecosflash	\
	dummy.exe


soft-distclean: leon3-soft-distclean ahbrom-distclean
	@$(RM) 		\
	prom.bin	\
	systest.bin

.PHONY: leon3-soft-clean leon3-soft-distclean


### Leon3 prom ###

prom.o: $(BOOTROM_PATH)/prom.S $(BOOTROM_PATH)/prom.h
	$(QUIET_AS) $(CROSS_COMPILE_ELF)gcc -c -I$(BOOTROM_PATH) $<

prom.exe: prom.o
	$(QUIET_CC) $(CROSS_COMPILE_ELF)gcc \
		-nostdlib \
		-Tlinkprom -N \
		-nostartfiles \
		-o $@ $<

prom.srec: prom.exe
	$(QUIET_OBJCP)$(CROSS_COMPILE_ELF)objcopy -O srec $< $@

dummy.exe: $(UTILS_GRLIB)/mkprom2/dummy.c
	$(QUIET_MAKE) $(CROSS_COMPILE_ELF)gcc $< -o $@

mkprom2: $(wildcard $(UTILS_GRLIB)/mkprom2/*.S) $(wildcard $(UTILS_GRLIB)/mkprom2/*.c) $(wildcard $(UTILS_GRLIB)/mkprom2/*.h)
	$(QUIET_MAKE) $(MAKE) --quiet -C $(UTILS_GRLIB)/mkprom2 PREFIX=$(DESIGN_PATH)

prom.out: dummy.exe mkprom2
	./mkprom2 -leon3 -freq $(LEON3_BASE_FREQ_MHZ) -nomsg -baud 38343 -stack $(LEON3_STACK) dummy.exe

prom.bin: prom.out
	$(QUIET_OBJCP) $(CROSS_COMPILE_ELF)objcopy -O binary --change-addresses -0x40000000 $< $@

ahbrom: $(UTILS_GRLIB)/ahbrom.c
	$(QUIET_CC)$(CC) $< -o $@

ahbrom.bin: prom.exe
	$(QUIET_OBJCP)$(CROSS_COMPILE)objcopy -O binary $< $@

ahbrom.vhd: ahbrom.bin ahbrom
	$(QUIET_BUILD)./ahbrom $< $@

ahbrom-clean:
	$(QUIET_CLEAN)$(RM) ahbrom ahbrom.bin

ahbrom-distclean: ahbrom-clean
	$(QUIET_CLEAN)$(RM) ahbrom.vhd

.PHONY: ahbrom-clean ahbrom-distclean


### Leon3 Linux ###

sysroot:
	$(QUIET_CP)cp -r $(ESP_ROOT)/soft/leon3/sysroot .

sysroot.files: sysroot
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

sysroot.cpio: sysroot.files
	$(QUIET_BUILD)${LINUXSRC}/usr/gen_init_cpio $< > $@


linux-build/.config: $(LINUXSRC)/arch/sparc/configs/$(LINUX_CONFIG)
	@$(MAKE) linux-build
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE)  O=${PWD}/linux-build -C ${LINUXSRC} $(LINUX_CONFIG)

linux-build/vmlinux: sysroot.cpio linux-build/.config
	$(QUIET_MAKE)ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) -C linux-build

linux.dsu: sysroot-update
	$(QUIET_BUILD)mklinuximg -ethmac $(LINUX_MAC) linux-build/vmlinux $@

linux.bin: linux.dsu
	$(QUIET_OBJCP) $(CROSS_COMPILE_LINUX)objcopy -S -O binary --change-addresses -0x40000000 $< $@

linux: linux.bin

linux-clean: sysroot-clean
	$(QUIET_CLEAN)
	@if test -e linux-build; then \
		ARCH=sparc CROSS_COMPILE=$(CROSS_COMPILE_LINUX) $(MAKE) --quiet -C linux-build clean; \
	fi;

linux-distclean: sysroot-distclean
	$(QUIET_CLEAN)$(RM) linux-build linux.dsu linux.bin

barec-all: barec
	@mkdir -p barec/dvi
	@$(MAKE) -C $(DRIVERS)/dvi/barec
	@cp $(DRIVERS)/dvi/barec/*.exe barec/dvi
	@$(MAKE) accelerators-barec


barec-distclean:
	$(QUIET_CLEAN)$(RM) barec
	@CROSS_COMPILE=sparc-elf- $(MAKE) --quiet -C $(DRIVERS)/dvi/barec clean
	@$(MAKE) --quiet accelerators-barec-clean
