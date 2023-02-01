# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

VPATH  += $(UTILS_GRLIB)/software/leon3
XINC   +=-I$(UTILS_GRLIB)/software/leon3

XCC     = $(CROSS_COMPILE_ELF)gcc $(XINC) $(BOPT)
XAS     = $(CROSS_COMPILE_ELF)gcc -c -I. $(XINC) $(BOPT)
XAR     = $(CROSS_COMPILE_ELF)ar
XCFLAGS = -O2 -g -msoft-float

LDFLAGS = -lm
#LDFLAGS=-qnoambapp
XLDFLAGS=-L$(SOFT_BUILD)/ $(SOFT_BUILD)/lib3tests.a $(LDFLAGS)

PROGS = report_device apbuart divtest multest regtest \
	cache gpio ramfill ramtest irqmp leon3_test gptimer \
	mulasm cacheasm spwtest mptest fpu grfpu_ops \
	base_test grfpu_test can_oc mmu mmu_asm pcitest greth atactrl \
	amba dsu3 greth_api grcan grdmac\
	spictrl i2cmst misc spimctrl svgactrl apbps2 \
	i2cslv i2c \
	grusbdc rt_1553 brm_1553 pcif grtc grtm satcan memscrub_test \
	ftahbram ftlib ftsrctrl ftmctrl bch l2timers l2irqctrl leon2_test \
	grpwm grhcan brm grusbhc leon4_test base_test4 griommu l34stat ftddr2spa \
	router greth_throughput grpci2 gr1553b_test spwrouter \
	cgtest privtest privtest_asm mmudmap leon4_tsc mem_test grspwtdp \
	rextest rextest_asm awptest \
	cache_fill false_sharing rand_rw cache_evict assembly \
        lock mesi_test combined_test report data_structs

FPROGS=$(shell for i in $(PROGS); do \
			if [ -r $(UTILS_GRLIB)/software/leon3/$$i.c -o -r $(UTILS_GRLIB)/software/leon3/$$i.S ]; then \
				echo $$i; \
			fi; \
		done; \
		if [ -r $(UTILS_GRLIB)/software/greth/greth_api.c ]; then \
			echo greth_api; \
		fi; )
FPROGS+=$(EXTRA_PROGS)

OFILES = $(foreach of, $(FPROGS:%=%.o), $(SOFT_BUILD)/grlib/$(of))

all:

$(SOFT_BUILD)/grlib/%.o: %.c
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) $(XCFLAGS) -c  $< -o $@

$(SOFT_BUILD)/grlib/%.o: %.S
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) $(XCFLAGS) -c  $< -o $@

$(SOFT_BUILD)/grlib/fpu.o: fpu.c
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) -ffast-math -O3 -c  $< -o $@

$(SOFT_BUILD)/grlib/multest.o: multest.c
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) -O2 -c -mcpu=v8  $< -o $@

$(SOFT_BUILD)/grlib/divtest.o: divtest.c
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) -O2 -c -mcpu=v8  $< -o $@

$(SOFT_BUILD)/grlib/greth_api.o : $(UTILS_GRLIB)/software/greth/greth_api.c
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) -g -msoft-float -c $< -o $@

$(SOFT_BUILD)/grlib/cgtest.o : cgtest.c
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) -c  $<  -o $@

$(SOFT_BUILD)/grlib/gptimer.o : gptimer.c gptimer.h gpio.h
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) -c -g -O2 $< -o $@

$(SOFT_BUILD)/grlib/grspwtdp.o : grspwtdp.c grspwtdp.h grspwtdp-regs.h
	@mkdir -p $(SOFT_BUILD)/grlib
	$(QUIET_CC)$(XCC) -c -g -Wall -O2 $< -o $@

$(SOFT_BUILD)/lib3tests.a: $(OFILES)
	$(QUIET_AR)$(XAR) -cr $@ $(OFILES)

leon3-soft: $(SOFT_BUILD)/prom.srec $(SOFT_BUILD)/ram.srec

$(SOFT_BUILD)/systest.exe: systest.c $(SOFT_BUILD)/lib3tests.a
	$(QUIET_CC)$(XCC) $(XCFLAGS) systest.c $(XLDFLAGS) -o $@

$(SOFT_BUILD)/ram.srec: $(TEST_PROGRAM)
	$(QUIET_OBJCP)$(CROSS_COMPILE_ELF)objcopy -O srec --gap-fill 0 $< $@

leon3-soft-clean:
	$(QUIET_CLEAN)$(RM) $(OFILES) $(SOFT_BUILD)/lib3tests.a $(SOFT_BUILD)/prom.o

leon3-soft-distclean: soft-clean
	$(QUIET_CLEAN)$(RM) $(SOFT_BUILD)/prom.exe $(SOFT_BUILD)/systest.exe $(SOFT_BUILD)/standalone.exe

$(SOFT_BUILD)/standalone.exe: systest.c standalone.c $(SOFT_BUILD)/lib3tests.a
	$(QUIET_CC)$(XCC) $(XCFLAGS) systest.c $(VPATH)/standalone.c $(XLDFLAGS) -o standalone.exe
