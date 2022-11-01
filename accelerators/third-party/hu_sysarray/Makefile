
# Define V=1 for a more verbose compilation
ifndef V
	QUIET_BUILD         = @echo '   ' BUILD $@;
	QUIET_CC            = @echo '   ' CC $@;
	QUIET_CXX           = @echo '   ' CXX $@;
	QUIET_LINK          = @echo '   ' LINK $@;
	QUIET_CLEAN         = @echo '   ' CLEAN $@;
endif

IP := $(shell basename $$PWD)

IP_PATH := $(PWD)/ip

SW_PATH := $(PWD)/sw

ifndef IP_PATH
$(error variable IP_PATH for $(IP) is not defined)
endif

all: sw

sw:

hw:

clean:

distclean: clean

.PHONY: all sw hw clean distclean
