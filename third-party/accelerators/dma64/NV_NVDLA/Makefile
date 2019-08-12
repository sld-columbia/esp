
IP := $(shell basename $$PWD)

OUT_PATH := $(PWD)/out

IP_PATH := $(PWD)/ip

ifndef IP_PATH
$(error variable IP_PATH for $(IP) is not defined)
endif

all:
	@cp config/tree.make $(IP_PATH)
	@cd $(IP_PATH); \
        ./tools/bin/tmake -build vmod;

ip_path:
	@echo "$$(realpath $(IP_PATH))"

out_path:
	@echo "$$(realpath $(OUT_PATH))"

clean:

distclean: clean
	@rm -rf $$(readlink $(PWD)/out)

.PHONY: ip_path out_path all clean distclean
