CROSS_COMPILE = sparc-elf-

VPATH  += $(UTILS_GRLIB)/software/leon3
XINC   +=-I$(UTILS_GRLIB)/software/leon3 -I../common

XCC     = $(CROSS_COMPILE)gcc $(XINC) $(BOPT)
XAS     = $(CROSS_COMPILE)gcc -c -I. $(XINC) $(BOPT)
XAR     = $(CROSS_COMPILE)ar
XCFLAGS = -O2 -g -msoft-float

LDFLAGS = -lm
#LDFLAGS=-qnoambapp
XLDFLAGS=-L./ lib3tests.a $(LDFLAGS)

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

OFILES = $(FPROGS:%=%.o)

all:

%.o: %.c
	$(QUIET_CC)$(XCC) $(XCFLAGS) -c  $<

%.o: %.S
	$(QUIET_CC)$(XCC) $(XCFLAGS) -c  $<

fpu.o: fpu.c
	$(QUIET_CC)$(XCC) -ffast-math -O3 -c  $<

multest.o: multest.c
	$(QUIET_CC)$(XCC) -O2 -c -mcpu=v8  $<

divtest.o: divtest.c
	$(QUIET_CC)$(XCC) -O2 -c -mcpu=v8  $<

greth_api.o : $(UTILS_GRLIB)/software/greth/greth_api.c
	$(QUIET_CC)$(XCC) -g -msoft-float -c $(UTILS_GRLIB)/software/greth/greth_api.c

cgtest.o : cgtest.c
	$(QUIET_CC)$(XCC) -c  $<

gptimer.o : gptimer.c gptimer.h gpio.h
	$(QUIET_CC)$(XCC) -c -g -O2 $<

grspwtdp.o : grspwtdp.c grspwtdp.h grspwtdp-regs.h
	$(QUIET_CC)$(XCC) -c -g -Wall -O2 $<

lib3tests.a: $(OFILES)
	$(QUIET_AR)$(XAR) -cr lib3tests.a $(OFILES)

leon3-soft: prom.srec ram.srec

systest.exe: systest.c lib3tests.a
	$(QUIET_CC)$(XCC) $(XCFLAGS) systest.c $(XLDFLAGS) -o systest.exe

ram.srec: $(TEST_PROGRAM)
	$(QUIET_OBJCP)$(CROSS_COMPILE)objcopy -O srec --gap-fill 0 systest.exe ram.srec

leon3-soft-clean:
	$(QUIET_CLEAN)$(RM) $(OFILES) lib3tests.a prom.o

leon3-soft-distclean: soft-clean
	$(QUIET_CLEAN)$(RM) prom.exe systest.exe standalone.exe prom.srec ram.srec prom.bin

standalone.exe: systest.c standalone.c lib3tests.a
	$(QUIET_CC)$(XCC) $(XCFLAGS) systest.c $(VPATH)/standalone.c $(XLDFLAGS) -o standalone.exe
