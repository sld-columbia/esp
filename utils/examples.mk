
EXAMPLES_PATH = $(ESP_ROOT)/soft/examples/
EXAMPLES_OUT_PATH = $(DESIGN_PATH)/examples

EXAMPLES = $(filter-out common, $(shell ls -d $(EXAMPLES_PATH)/*/ | awk -F/ '{print $$(NF-1)}'))
EXAMPLES_TARGET = $(foreach e, $(EXAMPLES), $(EXAMPLES_OUT_PATH)/$(e)/$(e).exe)

EXAMPLE_CFLAGS =

ifeq ("$(CPU_ARCH)", "leon3")
# uclibc does not have sinf()
EXAMPLE_CFLAGS += -fno-builtin-cos -fno-builtin-sin
endif

EXAMPLE_CFLAGS += -O3
EXAMPLE_CFLAGS += -Wall
EXAMPLE_CFLAGS += -I$(DRIVERS)/include
EXAMPLE_CFLAGS += -I$(EXAMPLES_PATH)/$(EXAMPLE)

EXAMPLE_LDLIBS += -L$(DRIVERS)/contig_alloc
EXAMPLE_LDLIBS += -L$(DRIVERS)/test
EXAMPLE_LDLIBS += -L$(DRIVERS)/libesp

EXAMPLE_LDFLAGS += -lm -lrt -lpthread -lesp -ltest -lcontig

EXAMPLE_CC = gcc
EXAMPLE_LD = $(CROSS_COMPILE_LINUX)$(LD)

EXAMPLE_SRCS = $(foreach f, $(wildcard $(EXAMPLES_PATH)/$(EXAMPLE)/*.c), $(shell basename $(f)))
EXAMPLE_HDRS = $(wildcard $(EXAMPLES_PATH)/$(EXAMPLE)/*.h)
EXAMPLE_OBJS = $(EXAMPLE_SRCS:.c=.o)

$(EXAMPLES_OUT_PATH)/$(EXAMPLE):
	@$(QUIET_MKDIR) mkdir -p $@

$(EXAMPLES_OUT_PATH)/$(EXAMPLE)/%.o: $(EXAMPLES_PATH)/$(EXAMPLE)/%.c
	@$(MAKE) $(EXAMPLES_OUT_PATH)/$(EXAMPLE)
	$(QUIET_CC) $(CROSS_COMPILE_LINUX)$(EXAMPLE_CC) $(EXAMPLE_CFLAGS) -c -o $@ $<

$(EXAMPLES_OUT_PATH)/$(EXAMPLE)/$(EXAMPLE_OBJS): $(EXAMPLE_HDRS)


$(EXAMPLES_OUT_PATH)/$(EXAMPLE)/$(EXAMPLE).exe: $(EXAMPLES_OUT_PATH)/$(EXAMPLE)/$(EXAMPLE_OBJS)
	$(QUIET_LINK) $(CROSS_COMPILE_LINUX)$(EXAMPLE_CC) $(EXAMPLE_LDLIBS) -o $@ $^ $(EXAMPLE_LDFLAGS)


define EXAMPLES_GEN

$(1):
	@$(MAKE) EXAMPLE=$(1) $(EXAMPLES_OUT_PATH)/$(1)/$(1).exe

endef

$(foreach e, $(EXAMPLES), $(eval $(call EXAMPLES_GEN,$(e))))

examples: $(EXAMPLES)

examples-clean:
	$(QUIET_CLEAN) $(RM) $(DESIGN_PATH)/examples


.PHONY: examples examples-clean $(EXAMPLES)
