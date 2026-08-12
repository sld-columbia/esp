# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Constaints ###
ifneq ("$(OVR_TECHLIB)","")
XDC_SUFFIX = -fpga-proxy
XDC_EMU_SUFFIX = -chip-emu

XDC_EMU += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_EMU_SUFFIX).xdc
XDC_EMU += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_EMU_SUFFIX)-eth-pins.xdc
XDC_EMU += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_EMU_SUFFIX)-eth-constraints.xdc
XDC_EMU += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_EMU_SUFFIX)-cable-pins.xdc
else
XDC_SUFFIX =
endif


ifneq ($(filter $(TECHLIB),$(XIL_FPGALIBS)),)

ACC_TECH_DIR   = $(ESP_ROOT)/tech/$(TECHLIB)/acc
ACC_TECH_PRESENT = $(filter-out common,$(filter $(notdir $(wildcard $(ACC_TECH_DIR)/*)),$(RTL_ACC)))
THIRDPARTY_LIBS = $(THIRDPARTY_ACC)
ACC_VHDL_SRCS  = $(filter $(foreach acc,$(ACC_TECH_PRESENT),$(ACC_TECH_DIR)/$(acc)/%),$(VHDL_SRCS))
ACC_VLOG_SRCS  = $(filter $(foreach acc,$(ACC_TECH_PRESENT),$(ACC_TECH_DIR)/$(acc)/%),$(VLOG_SRCS))
THIRDPARTY_VHDL_PKGS_SRCS = $(filter $(THIRDPARTY_PATH)/%,$(VHDL_PKGS))
THIRDPARTY_VHDL_SRCS = $(filter $(THIRDPARTY_PATH)/%,$(VHDL_SRCS))
THIRDPARTY_VLOG_SRCS = $(filter $(THIRDPARTY_PATH)/%,$(VLOG_SRCS))
BASE_VHDL_PKGS = $(filter-out $(THIRDPARTY_VHDL_PKGS_SRCS),$(VHDL_PKGS))
BASE_VHDL_SRCS = $(filter-out $(ACC_VHDL_SRCS) $(THIRDPARTY_VHDL_SRCS),$(VHDL_SRCS))
BASE_VLOG_SRCS = $(filter-out $(ACC_VLOG_SRCS) $(THIRDPARTY_VLOG_SRCS),$(VLOG_SRCS))
VIVADO_SOURCE_MANIFEST ?= $(RTL_CFG_BUILD)/vivado_sources.list
VIVADO_DAT_MANIFEST ?= $(RTL_CFG_BUILD)/vivado_dat_files.list
VIVADO_INCDIR_MANIFEST ?= $(RTL_CFG_BUILD)/vivado_incdirs.list
VIVADO_EMU_INCDIR_MANIFEST ?= $(RTL_CFG_BUILD)/vivado_emu_incdirs.list
VIVADO_IP_XCI_MANIFEST ?= $(RTL_CFG_BUILD)/vivado_ip_xci.list

XDC   = $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX).xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-mig-pins.xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-mig-constraints.xdc
ifneq ($(findstring profpga, $(BOARD)),)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-mmi64.xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-cable-pins.xdc
endif
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-eth-pins.xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-dvi-pins.xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-eth-constraints.xdc
ifeq ($(CONFIG_SVGA_ENABLE),y)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)$(XDC_SUFFIX)-dvi-constraints.xdc
endif
ifeq ($(CONFIG_HAS_DVFS),y)
XDC  += $(ESP_ROOT)/constraints/esp-common/esp-plls.xdc
endif
endif


### Options for Vivado batch mode ###
VIVADO_BATCH_OPT = -mode batch -quiet -notrace
VIVADO_JOBS ?= 32
VIVADO_TRUE_VALUES := true TRUE 1 yes YES
VIVADO_ENABLE_ALL_OPTIMIZATIONS ?= 0
VIVADO_SYNTH_RETIMING ?=
VIVADO_SYNTH_GLOBAL_RETIMING ?= $(VIVADO_SYNTH_RETIMING)
VIVADO_SYNTH_STRATEGY ?=
VIVADO_IMPL_STRATEGY ?=
VIVADO_OPT_DIRECTIVE ?=
VIVADO_PLACE_DIRECTIVE ?=
VIVADO_PHYS_OPT_DIRECTIVE ?=
VIVADO_ROUTE_DIRECTIVE ?=
VIVADO_POST_ROUTE_PHYS_OPT_ENABLE ?=
VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE ?=
VIVADO_LOGS_ABS = $(abspath $(VIVADO_LOGS))
PIPEFAIL_SHELL ?= bash

# Full Vivado timing-closure profile, tuned for Vivado 2023.2.
ifneq ($(filter $(VIVADO_TRUE_VALUES),$(strip $(VIVADO_ENABLE_ALL_OPTIMIZATIONS))),)
ifeq ($(strip $(VIVADO_SYNTH_GLOBAL_RETIMING)),)
VIVADO_SYNTH_GLOBAL_RETIMING := true
endif
ifeq ($(strip $(VIVADO_SYNTH_STRATEGY)),)
VIVADO_SYNTH_STRATEGY := Flow_PerfOptimized_high
endif
ifeq ($(strip $(VIVADO_IMPL_STRATEGY)),)
VIVADO_IMPL_STRATEGY := Performance_Explore
endif
ifeq ($(strip $(VIVADO_OPT_DIRECTIVE)),)
VIVADO_OPT_DIRECTIVE := Explore
endif
ifeq ($(strip $(VIVADO_PLACE_DIRECTIVE)),)
VIVADO_PLACE_DIRECTIVE := ExtraNetDelay_high
endif
ifeq ($(strip $(VIVADO_PHYS_OPT_DIRECTIVE)),)
VIVADO_PHYS_OPT_DIRECTIVE := AggressiveExplore
endif
ifeq ($(strip $(VIVADO_ROUTE_DIRECTIVE)),)
VIVADO_ROUTE_DIRECTIVE := AggressiveExplore
endif
ifeq ($(strip $(VIVADO_POST_ROUTE_PHYS_OPT_ENABLE)),)
VIVADO_POST_ROUTE_PHYS_OPT_ENABLE := true
endif
ifeq ($(strip $(VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE)),)
VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE := AggressiveExplore
endif
ifeq ($(strip $(VIVADO_ENABLE_EXTRA_TIMING_REPORTS)),)
VIVADO_ENABLE_EXTRA_TIMING_REPORTS := 1
endif
endif

VIVADO_ENABLE_EXTRA_TIMING_REPORTS ?= 0

$(VIVADO_LOGS):
	$(QUIET_MKDIR)mkdir -p $(VIVADO_LOGS)

vivado: $(VIVADO_LOGS)
	$(QUIET_MKDIR)mkdir -p vivado

ifneq ($(filter $(TECHLIB),$(XIL_FPGALIBS)),)

vivado/srcs.tcl: vivado check_all_rtl_srcs $(RTL_CFG_BUILD)/check_all_rtl_srcs.old
	$(QUIET_INFO)echo "generating source list for Vivado"
	@$(RM) $@
	@$(file >$(VIVADO_SOURCE_MANIFEST))
ifneq ($(findstring profpga, $(BOARD)),)
	@$(foreach vhd,$(VHDL_PROFPGA),$(file >>$(VIVADO_SOURCE_MANIFEST),profpga-vhdl|$(PROFPGA)/hdl/$(vhd)))
	@$(foreach ver,$(VERILOG_PROFPGA),$(file >>$(VIVADO_SOURCE_MANIFEST),profpga-vlog|$(PROFPGA)/hdl/$(ver)))
endif
	@$(foreach rtl,$(BASE_VHDL_PKGS),$(file >>$(VIVADO_SOURCE_MANIFEST),vhdl|$(rtl)))
	@$(foreach rtl,$(filter-out $(DESIGN_PATH)/socketgen/noc_%.vhd,$(BASE_VHDL_SRCS)),$(file >>$(VIVADO_SOURCE_MANIFEST),vhdl|$(rtl)))
	@$(file >>$(VIVADO_SOURCE_MANIFEST),socketgen|)
	@$(foreach rtl,$(BASE_VLOG_SRCS),$(file >>$(VIVADO_SOURCE_MANIFEST),vlog|$(rtl)))
	@while IFS='|' read -r kind rtl; do \
		case "$$kind" in \
			profpga-vhdl) echo "read_vhdl -library profpga $$rtl" >> $@ ;; \
			profpga-vlog) echo "read_verilog -library profpga -sv $$rtl" >> $@ ;; \
			vhdl) echo "read_vhdl $$rtl" >> $@ ;; \
			socketgen) \
				if test -d "$(DESIGN_PATH)/socketgen"; then \
					find "$(DESIGN_PATH)/socketgen" -maxdepth 1 -type f -name "noc_*.vhd" | sort | \
					while IFS= read -r noc_rtl; do \
						echo "read_vhdl $$noc_rtl" >> $@; \
					done; \
				fi ;; \
			vlog) \
				case "$$rtl" in \
					$(ACC_TECH_DIR)/*) \
						accname=$$(printf "%s\n" "$$rtl" | awk -F/ '{for(i=1;i<=NF;i++) if($$i=="acc"){print $$(i+1); exit}}'); \
						case " $(RTL_ACC) " in *" $$accname "*) continue ;; esac ;; \
				esac; \
				echo "read_verilog -sv $$rtl" >> $@ ;; \
		esac; \
	done < "$(VIVADO_SOURCE_MANIFEST)"
	@if test -d $(ACC_TECH_DIR); then \
		for accdir in $(ACC_TECH_DIR)/*; do \
			if test -d "$$accdir"; then \
				accname=`basename "$$accdir"`; \
				case " $(RTL_ACC) " in *" $$accname "*) ;; *) continue ;; esac; \
				acclib=$$accname; \
				accsrc="$(ESP_ROOT)/accelerators/rtl/$$accname"; \
				incroot="$$accsrc/vlog_incdir"; \
				echo "# Accelerator $$accname (library $$acclib)" >> $@; \
				vendbn=$$(mktemp); vendbn_u=$$(mktemp); vendcmds=$$(mktemp); \
				: > $$vendbn; : > $$vendcmds; : > $$vendbn_u; \
				if test -d "$$incroot"; then \
					incdirs=`find "$$incroot" -type d`; \
					echo "set_property include_dirs [concat {$$incdirs} [get_property include_dirs [get_filesets sources_1]]] [get_filesets sources_1]" >> $@; \
					echo "set_property include_dirs [concat {$$incdirs} [get_property include_dirs [get_filesets sim_1]]] [get_filesets sim_1]" >> $@; \
				fi; \
				hasflist=0; \
				for fl in "$$accsrc"/*.sverilog "$$accsrc"/*.verilog; do \
					if test -f "$$fl"; then hasflist=1; break; fi; \
				done; \
				for rtl in `find "$$accdir" -type f \( -name "*.vhd" -o -name "*.vhdl" \)`; do \
					echo "read_vhdl -library $$acclib $$rtl" >> $@; \
				done; \
				if test $$hasflist -eq 1; then \
					echo "# Vendor include dirs and sources from ordered filelists" >> $@; \
					for fl in "$$accsrc"/*.sverilog "$$accsrc"/*.verilog; do \
						if test -f "$$fl"; then \
							svopt=""; \
							case "$$fl" in *.sverilog) svopt="-sv" ;; esac; \
							while IFS= read -r p; do \
								p=`printf "%s" "$$p" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$$//'`; \
								case "$$p" in \
									""|\#*) continue ;; \
									+incdir+*) \
										dirs=`printf "%s" "$$p" | sed 's/^+incdir+//; s/+/ /g'`; \
										for d in $$dirs; do \
											d="$(ESP_ROOT)/accelerators/rtl/$$accname/vendor/$$d"; \
											echo "set_property include_dirs [concat {$$d} [get_property include_dirs [get_filesets sources_1]]] [get_filesets sources_1]" >> $@; \
											echo "set_property include_dirs [concat {$$d} [get_property include_dirs [get_filesets sim_1]]] [get_filesets sim_1]" >> $@; \
										done; \
										continue ;; \
								esac; \
								f="$(ESP_ROOT)/accelerators/rtl/$$accname/vendor/$$p"; \
								if test -f "$$f"; then \
									echo "$$(basename "$$f")" >> $$vendbn; \
									echo "read_verilog -library $$acclib $$svopt $$f" >> $$vendcmds; \
								else \
									echo "ERROR missing vendor source $$f (from $$fl)" 1>&2; \
									rm -f $$vendbn $$vendbn_u $$vendcmds; \
									exit 1; \
								fi; \
							done < "$$fl"; \
						fi; \
					done; \
					if test -s $$vendbn; then sort -u $$vendbn > $$vendbn_u; fi; \
				fi; \
				if test -d "$$incroot"; then \
					echo "# SV packages and helpers from vlog_incdir (skip duplicates provided by vendor filelists)" >> $@; \
					for pkg in `find "$$incroot" -type f -name "*.sv" | sort`; do \
						bn=$$(basename "$$pkg"); \
						if test -s $$vendbn_u && grep -qx "$$bn" $$vendbn_u; then \
							continue; \
						fi; \
						echo "read_verilog -library $$acclib -sv $$pkg" >> $@; \
					done; \
				fi; \
				if test -s $$vendcmds; then cat $$vendcmds >> $@; fi; \
				rm -f $$vendbn $$vendbn_u $$vendcmds; \
				echo "# Wrapper RTL from tech folder" >> $@; \
				for rtl in `find "$$accdir" -type f \( -name "*.v" -o -name "*.sv" \)`; do \
					echo "read_verilog -library $$acclib -sv $$rtl" >> $@; \
				done; \
			fi; \
			done; \
		fi;
	@if test -d $(THIRDPARTY_PATH); then \
		for acc in $(THIRDPARTY_LIBS); do \
			accsrc="$(THIRDPARTY_PATH)/$$acc"; \
			acclib=$$acc; \
			echo "# Third-party accelerator $$acc (library $$acclib)" >> $@; \
			if test -d "$$accsrc/vlog_incdir"; then \
				incdirs=`find "$$accsrc/vlog_incdir" -type d`; \
				echo "set_property include_dirs [concat {$$incdirs} [get_property include_dirs [get_filesets sources_1]]] [get_filesets sources_1]" >> $@; \
				echo "set_property include_dirs [concat {$$incdirs} [get_property include_dirs [get_filesets sim_1]]] [get_filesets sim_1]" >> $@; \
			fi; \
			for vhdf in "$$accsrc/$$acc.pkgs" "$$accsrc/$$acc.vhdl"; do \
				if test -f "$$vhdf"; then \
					while IFS= read -r p; do \
						p=`printf "%s" "$$p" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$$//'`; \
						case "$$p" in ""|\#*|//*|--*) continue ;; esac; \
						case "$$p" in /*) f="$$p" ;; *) f="$$accsrc/out/$$p" ;; esac; \
						if test -f "$$f"; then \
							echo "read_vhdl -library $$acclib $$f" >> $@; \
						else \
							echo "ERROR missing third-party VHDL source $$f (from $$vhdf)" 1>&2; \
							exit 1; \
						fi; \
					done < "$$vhdf"; \
				fi; \
			done; \
			if test -f "$$accsrc/$${acc}_wrapper.v"; then \
				echo "read_verilog -library $$acclib -sv $$accsrc/$${acc}_wrapper.v" >> $@; \
			fi; \
			for fl in "$$accsrc/$$acc.verilog" "$$accsrc/$$acc.sverilog"; do \
				if test -f "$$fl"; then \
					svopt=""; \
					case "$$fl" in *.sverilog) svopt="-sv" ;; esac; \
					while IFS= read -r p; do \
						p=`printf "%s" "$$p" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$$//'`; \
						case "$$p" in ""|\#*|//*|--*) continue ;; esac; \
						case "$$p" in +incdir+*) \
							dirs=`printf "%s" "$$p" | sed 's/^+incdir+//; s/+/ /g'`; \
							for d in $$dirs; do \
								case "$$d" in /*) idir="$$d" ;; *) idir="$$accsrc/out/$$d" ;; esac; \
								echo "set_property include_dirs [concat {$$idir} [get_property include_dirs [get_filesets sources_1]]] [get_filesets sources_1]" >> $@; \
								echo "set_property include_dirs [concat {$$idir} [get_property include_dirs [get_filesets sim_1]]] [get_filesets sim_1]" >> $@; \
							done; \
							continue ;; \
						esac; \
						case "$$p" in /*) f="$$p" ;; *) f="$$accsrc/out/$$p" ;; esac; \
						if test -f "$$f"; then \
							echo "read_verilog -library $$acclib $$svopt $$f" >> $@; \
						else \
							echo "ERROR missing third-party Verilog source $$f (from $$fl)" 1>&2; \
							exit 1; \
						fi; \
					done < "$$fl"; \
				fi; \
			done; \
		done; \
	fi;
	@$(file >$(VIVADO_DAT_MANIFEST))
	@$(foreach dat,$(DAT_SRCS),$(file >>$(VIVADO_DAT_MANIFEST),$(dat)))
	@while IFS= read -r dat; do \
		echo "add_files $$dat" >> $@; \
	done < "$(VIVADO_DAT_MANIFEST)"


vivado/setup.tcl: vivado $(RTL_CFG_BUILD) $(BOARD_FILES)
	$(QUIET_INFO)echo "generating project script for Vivado"
	@$(RM) $@
	@$(file >$(VIVADO_INCDIR_MANIFEST))
	@$(foreach dir,$(INCDIR),$(file >>$(VIVADO_INCDIR_MANIFEST),$(dir)))
	@$(file >$(VIVADO_IP_XCI_MANIFEST))
	@$(foreach rtl,$(IP_XCI_SRCS),$(file >>$(VIVADO_IP_XCI_MANIFEST),$(rtl)))
	@echo "create_project $(DESIGN) -part ${DEVICE} -force" > $@
	@echo "set_property target_language verilog [current_project]" >> $@
	@printf '%s' 'set_property include_dirs {' >> $@; \
	while IFS= read -r dir; do \
		printf '%s ' "$$dir" >> $@; \
	done < "$(VIVADO_INCDIR_MANIFEST)"; \
	printf '%s\n' '} [get_filesets {sim_1 sources_1}]' >> $@
ifeq ("$(CPU_ARCH)","ibex")
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1 PRIM_DEFAULT_IMPL=prim_pkg::ImplXilinx $(GT_VORTEX_VIVADO_DEFINES)} [get_filesets {sim_1 sources_1}]" >> $@
else
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1 FPU_FPNEW=1 SYNTHESIS=1 XLEN_64=1 $(GT_VORTEX_VIVADO_DEFINES)} [get_filesets {sim_1 sources_1}]" >> $@
endif
	@echo "source ./srcs.tcl" >> $@
ifneq ("$(PROTOBOARD)","")
	@echo "set_property board_part $(PROTOBOARD) [current_project]"  >> $@
endif
ifneq ($(IP_XCI_SRCS),)
	@while IFS= read -r rtl; do \
		echo "import_ip -files $$rtl" >> $@; \
	done < "$(VIVADO_IP_XCI_MANIFEST)"
	@echo "upgrade_ip [get_ips -all]" >> $@
endif
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/$(CPU_ARCH)/mig.xci; then \
		echo $(SPACES)"INFO including MIG IP"; \
		mkdir -p vivado/mig; \
        cp $(ESP_ROOT)/constraints/$(BOARD)/$(CPU_ARCH)/mig.xci ./vivado/mig; \
        if test -r $(ESP_ROOT)/constraints/$(BOARD)/$(CPU_ARCH)/mig_a.prj; then \
            cp $(ESP_ROOT)/constraints/$(BOARD)/$(CPU_ARCH)/mig_a.prj ./vivado/mig; \
            cp $(ESP_ROOT)/constraints/$(BOARD)/$(CPU_ARCH)/mig_b.prj ./vivado/mig; \
        fi; \
		echo "import_ip -files ./mig/mig.xci" >> $@; \
		echo "generate_target  all [get_ips mig] -force " >> $@; \
	elif test -r $(ESP_ROOT)/constraints/$(BOARD)/$(CPU_ARCH)/mig.tcl; then \
		echo $(SPACES)"INFO including MIG IP"; \
		mkdir -p vivado/mig; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/$(CPU_ARCH)/mig.tcl ./vivado/mig; \
		if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.csv; then \
			cp $(ESP_ROOT)/constraints/$(BOARD)/mig.csv ./vivado/mig; \
		fi; \
		echo "source ./mig/mig.tcl" >> $@; \
		echo "generate_target  all [get_ips mig] -force " >> $@; \
	else \
		echo $(SPACES)"WARNING: no MIG IP was found"; \
	fi;
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/zynq.tcl; then \
		echo $(SPACES)"INFO including ZYNQ PS IP"; \
		mkdir -p vivado/zynq; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/zynq.tcl ./vivado/zynq; \
		echo "set argv [list $(ARCH_BITS)]" >> $@; \
		echo "set argv [list $(ARCH_BITS)]" >> $@; \
		echo "set argc 1" >> $@; \
		echo "source ./zynq/zynq.tcl" >> $@; \
		echo "unset argv" >> $@; \
		echo "set argc 0" >> $@; \
	fi;
ifeq ($(CONFIG_ETH_EN),y)
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci; then \
		echo $(SPACES)"INFO including SGMII IP"; \
		mkdir -p vivado/sgmii; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci ./vivado/sgmii; \
		echo "set_property target_language verilog [current_project]" >> $@; \
		echo "import_ip -files ./sgmii/sgmii.xci" >> $@; \
		echo "generate_target  all [get_ips sgmii] -force" >> $@; \
	elif test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.tcl; then \
		echo $(SPACES)"INFO including SGMII IP"; \
		mkdir -p vivado/sgmii; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.tcl ./vivado/sgmii; \
		echo "set_property target_language verilog [current_project]" >> $@; \
		echo "source ./sgmii/sgmii.tcl" >> $@; \
		echo "generate_target  all [get_ips sgmii] -force" >> $@; \
	else \
		echo $(SPACES)"WARNING: no SGMII IP was found"; \
	fi;
endif
	@if test -r $(UTILS_GRLIB)/netlists/$(TECHLIB); then \
		echo "import_files $(UTILS_GRLIB)/netlists/$(TECHLIB)" >> $@; \
	fi;
	@if test -r $(DESIGN_PATH)/socgen/esp/mem_tile_floorplanning.xdc; then \
		echo "read_xdc  $(DESIGN_PATH)/socgen/esp/mem_tile_floorplanning.xdc" >> $@; \
	    echo "set_property used_in_synthesis true [get_files $(DESIGN_PATH)/socgen/esp/mem_tile_floorplanning.xdc]" >> $@; \
	    echo "set_property used_in_implementation true [get_files $(DESIGN_PATH)/socgen/esp/mem_tile_floorplanning.xdc]" >> $@; \
	echo "set_property strategy Congestion_SpreadLogic_high [get_runs impl_1]" >> $@; \
	fi;
	@for i in $(XDC); do \
	  if test -e $$i; then \
	    echo "read_xdc $$i" >> $@; \
	    echo "set_property used_in_synthesis true [get_files $$i]" >> $@; \
	    echo "set_property used_in_implementation true [get_files $$i]" >> $@; \
          fi; \
	done;
	@echo "set_property top $(TOP) [current_fileset]" >> $@
ifneq ($(strip $(VIVADO_SYNTH_STRATEGY)),)
	@echo "set_property strategy $(VIVADO_SYNTH_STRATEGY) [get_runs synth_1]" >> $@
endif
ifneq ($(strip $(VIVADO_IMPL_STRATEGY)),)
	@echo "set_property strategy $(VIVADO_IMPL_STRATEGY) [get_runs impl_1]" >> $@
endif
ifneq ($(filter $(VIVADO_TRUE_VALUES),$(strip $(VIVADO_SYNTH_GLOBAL_RETIMING))),)
	@echo "set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]" >> $@
endif
ifneq ($(strip $(VIVADO_OPT_DIRECTIVE)),)
	@echo "set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE $(VIVADO_OPT_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_PLACE_DIRECTIVE)),)
	@echo "set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE $(VIVADO_PLACE_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_PHYS_OPT_DIRECTIVE)),)
	@echo "set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE $(VIVADO_PHYS_OPT_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_ROUTE_DIRECTIVE)),)
	@echo "set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE $(VIVADO_ROUTE_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_POST_ROUTE_PHYS_OPT_ENABLE)),)
	@echo "set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED $(VIVADO_POST_ROUTE_PHYS_OPT_ENABLE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE)),)
	@echo "set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE $(VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE) [get_runs impl_1]" >> $@
endif


vivado/setup_emu.tcl: vivado $(RTL_CFG_BUILD) $(BOARD_FILES)
	$(QUIET_INFO)echo "generating project script for Vivado"
	@$(RM) $@
	@$(file >$(VIVADO_EMU_INCDIR_MANIFEST))
	@$(foreach dir,$(INCDIR),$(file >>$(VIVADO_EMU_INCDIR_MANIFEST),$(dir)))
	@echo "create_project $(DESIGN)-chip-emu -part ${DEVICE} -force" > $@
	@echo "set_property target_language verilog [current_project]" >> $@
	@printf '%s' 'set_property include_dirs {' >> $@; \
	while IFS= read -r dir; do \
		printf '%s ' "$$dir" >> $@; \
	done < "$(VIVADO_EMU_INCDIR_MANIFEST)"; \
	printf '%s\n' '} [get_filesets {sim_1 sources_1}]' >> $@
ifeq ("$(CPU_ARCH)","ibex")
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1 PRIM_DEFAULT_IMPL=prim_pkg::ImplXilinx $(GT_VORTEX_VIVADO_DEFINES)} [get_filesets {sim_1 sources_1}]" >> $@
else
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1 $(GT_VORTEX_VIVADO_DEFINES)} [get_filesets {sim_1 sources_1}]" >> $@
endif
	@echo "source ./srcs.tcl" >> $@
ifneq ("$(PROTOBOARD)","")
	@echo "set_property board_part $(PROTOBOARD) [current_project]"  >> $@
endif
	@for i in $(XDC_EMU); do \
	  if test -e $$i; then \
	    echo "read_xdc $$i" >> $@; \
	    echo "set_property used_in_synthesis true [get_files $$i]" >> $@; \
	    echo "set_property used_in_implementation true [get_files $$i]" >> $@; \
          fi; \
	done;
	@echo "set_property top chip_emu_top [get_filesets {sim_1 sources_1}]" >> $@
	@echo "update_compile_order -fileset sources_1" >> $@
	@echo "update_compile_order -fileset sim_1" >> $@
ifneq ($(strip $(VIVADO_SYNTH_STRATEGY)),)
	@echo "set_property strategy $(VIVADO_SYNTH_STRATEGY) [get_runs synth_1]" >> $@
endif
ifneq ($(strip $(VIVADO_IMPL_STRATEGY)),)
	@echo "set_property strategy $(VIVADO_IMPL_STRATEGY) [get_runs impl_1]" >> $@
endif
ifneq ($(filter $(VIVADO_TRUE_VALUES),$(strip $(VIVADO_SYNTH_GLOBAL_RETIMING))),)
	@echo "set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]" >> $@
endif
ifneq ($(strip $(VIVADO_OPT_DIRECTIVE)),)
	@echo "set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE $(VIVADO_OPT_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_PLACE_DIRECTIVE)),)
	@echo "set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE $(VIVADO_PLACE_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_PHYS_OPT_DIRECTIVE)),)
	@echo "set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE $(VIVADO_PHYS_OPT_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_ROUTE_DIRECTIVE)),)
	@echo "set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE $(VIVADO_ROUTE_DIRECTIVE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_POST_ROUTE_PHYS_OPT_ENABLE)),)
	@echo "set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED $(VIVADO_POST_ROUTE_PHYS_OPT_ENABLE) [get_runs impl_1]" >> $@
endif
ifneq ($(strip $(VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE)),)
	@echo "set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE $(VIVADO_POST_ROUTE_PHYS_OPT_DIRECTIVE) [get_runs impl_1]" >> $@
endif


vivado/syn.tcl: vivado
	$(QUIET_INFO)echo "generating synthesis script for Vivado"
	@$(RM) $@
	@echo "open_project $(DESIGN).xpr" > $@
	@echo "update_ip_catalog" >> $@
	@echo "update_compile_order -fileset sources_1" >> $@
	@echo "set_param general.maxThreads $(VIVADO_JOBS)" >> $@
	@echo "reset_run impl_1" >> $@
	@echo "reset_run synth_1" >> $@
#	@echo "synth_design -rtl -name rtl_1" >> $@
#	@echo "synth_design -directive runtimeoptimize -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
#	@echo "synth_design -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
	@echo "launch_runs synth_1 -jobs $(VIVADO_JOBS)" >> $@
	@echo "get_ips" >> $@
	@echo "wait_on_run -timeout 720 synth_1" >> $@
	@echo "set_msg_config -suppress -id {Drc 23-20}" >> $@
	@echo "launch_runs impl_1 -jobs $(VIVADO_JOBS)" >> $@
	@echo "wait_on_run -timeout 720 impl_1" >> $@
	@echo "launch_runs impl_1 -to_step write_bitstream" >> $@
	@echo "wait_on_run -timeout 60 impl_1" >> $@
ifneq ($(strip $(VIVADO_ENABLE_EXTRA_TIMING_REPORTS)),0)
	@echo "open_run synth_1" >> $@
	@echo "check_timing -verbose -file top_check_timing_synth.rpt" >> $@
	@echo "report_timing -max_paths 20 -nworst 20 -delay_type max -sort_by slack -file top_timing_worst_20_synth.rpt" >> $@
	@echo "open_run impl_1" >> $@
	@echo "report_qor_suggestions -file top_qor_suggestions_impl.rpt" >> $@
	@echo "report_high_fanout_nets -fanout_greater_than 64 -max_nets 200 -file top_high_fanout_nets_impl.rpt" >> $@
endif

vivado/syn_emu.tcl: vivado
	$(QUIET_INFO)echo "generating synthesis script for Vivado"
	@$(RM) $@
	@echo "open_project $(DESIGN)-chip-emu.xpr" > $@
	@echo "update_ip_catalog" >> $@
	@echo "update_compile_order -fileset sources_1" >> $@
	@echo "set_param general.maxThreads $(VIVADO_JOBS)" >> $@
	@echo "reset_run impl_1" >> $@
	@echo "reset_run synth_1" >> $@
#	@echo "synth_design -rtl -name rtl_1" >> $@
#	@echo "synth_design -directive runtimeoptimize -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
#	@echo "synth_design -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
	@echo "launch_runs synth_1 -jobs $(VIVADO_JOBS)" >> $@
	@echo "get_ips" >> $@
	@echo "wait_on_run -timeout 720 synth_1" >> $@
	@echo "set_msg_config -suppress -id {Drc 23-20}" >> $@
	@echo "launch_runs impl_1 -jobs $(VIVADO_JOBS)" >> $@
	@echo "wait_on_run -timeout 720 impl_1" >> $@
	@echo "launch_runs impl_1 -to_step write_bitstream" >> $@
	@echo "wait_on_run -timeout 60 impl_1" >> $@

vivado/program.tcl: vivado
	$(QUIET_INFO)echo "generating programming script for $(PART)"
	@$(RM) $@
	@echo "set fpga_host [lindex \$$argv 0]" >> $@
	@echo "set port [lindex \$$argv 1]" >> $@
	@echo "set part [lindex \$$argv 2]" >> $@
	@echo "set bit [lindex \$$argv 3]" >> $@
	@echo "" >> $@
	@echo "open_hw_manager" >> $@
	@echo "connect_hw_server -url \$$fpga_host:\$$port" >> $@
	@echo "puts \"Connected to \$$fpga_host\"" >> $@
	@echo "puts \"Searching for \$$part...\"" >> $@
	@echo "" >> $@
	@echo "foreach cable [get_hw_targets ] {" >> $@
	@echo "    open_hw_target \$$cable" >> $@
	@echo "    set dev [get_hw_devices]" >> $@
	@echo "    if [string match -nocase \"\$$part*\" \$$dev] {" >> $@
	@echo "	puts \"Programming \$$part ...\"" >> $@
	@echo "	set_property PROGRAM.FILE \$$bit \$$dev" >> $@
	@echo "	program_hw_devices \$$dev" >> $@
	@echo "	close_hw_target" >> $@
	@echo "	disconnect_hw_server" >> $@
	@echo "	close_hw" >> $@
	@echo "	exit" >> $@
	@echo "    }" >> $@
	@echo "    close_hw_target" >> $@
	@echo "}" >> $@
	@echo "" >> $@
	@echo "disconnect_hw_server" >> $@
	@echo "close_hw" >> $@
	@echo "error \"ERROR: \$$part not found at host \$$fpga_host\"" >> $@


vivado/$(DESIGN): vivado vivado/srcs.tcl vivado/setup.tcl vivado/syn.tcl
	$(QUIET_INFO)echo "launching Vivado setup script"
	@(cd vivado && $(PIPEFAIL_SHELL) -o pipefail -c ' \
	if test -r $(DESIGN).xpr; then \
		echo -n $(SPACES)"WARNING: overwrite existing Vivado project \"$(DESIGN)\"? [y|n]"; \
		while true; do \
			read -p " " yn; \
			case $$yn in \
				[Yy] ) \
					$(RM) $(DESIGN); \
					vivado $(VIVADO_BATCH_OPT) -source setup.tcl 2>&1 | tee "$$1"; \
					exit $$?;; \
				[Nn] ) \
					echo $(SPACES)"INFO aborting $@"; \
					exit 0;; \
				* ) echo -n $(SPACES)"INFO Please answer yes or no [y|n].";; \
			esac; \
		done; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source setup.tcl 2>&1 | tee "$$1"; \
	fi' _ "$(VIVADO_LOGS_ABS)/vivado_setup.log")
	@test -r vivado/$(DESIGN).xpr || { echo $(SPACES)"ERROR: Vivado project not found after setup: vivado/$(DESIGN).xpr"; false; }

vivado/$(DESIGN)-chip-emu: vivado vivado/srcs.tcl vivado/setup_emu.tcl vivado/syn_emu.tcl
	$(QUIET_INFO)echo "launching Vivado setup script"
	@(cd vivado && $(PIPEFAIL_SHELL) -o pipefail -c ' \
	if test -r $(DESIGN)-chip-emu.xpr; then \
		echo -n $(SPACES)"WARNING: overwrite existing Vivado project \"$(DESIGN)-chip-emu\"? [y|n]"; \
		while true; do \
			read -p " " yn; \
			case $$yn in \
				[Yy] ) \
					$(RM) $(DESIGN)-chip-emu; \
					vivado $(VIVADO_BATCH_OPT) -source setup_emu.tcl 2>&1 | tee "$$1"; \
					exit $$?;; \
				[Nn] ) \
					echo $(SPACES)"INFO aborting $@"; \
					exit 0;; \
				* ) echo -n $(SPACES)"INFO Please answer yes or no [y|n].";; \
			esac; \
		done; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source setup_emu.tcl 2>&1 | tee "$$1"; \
	fi' _ "$(VIVADO_LOGS_ABS)/vivado_setup_emu.log")
	@test -r vivado/$(DESIGN)-chip-emu.xpr || { echo $(SPACES)"ERROR: Vivado project not found after setup: vivado/$(DESIGN)-chip-emu.xpr"; false; }

vivado-setup: check_all_rtl_srcs vivado/$(DESIGN)

vivado-setup-emu: check_all_rtl_srcs vivado/$(DESIGN)-chip-emu

vivado-gui: vivado-setup
	$(QUIET_RUN)
	@cd vivado; \
	vivado $(DESIGN).xpr; \
	cd ../;

vivado-gui-emu: vivado-setup-emu
	$(QUIET_RUN)
	@cd vivado; \
	vivado $(DESIGN)-chip-emu.xpr; \
	cd ../;

vivado-syn: vivado-setup
	$(QUIET_INFO)echo "launching Vivado implementation script"
	@(cd vivado && $(PIPEFAIL_SHELL) -o pipefail -c 'vivado $(VIVADO_BATCH_OPT) -source syn.tcl 2>&1 | tee "$$1"' _ "$(VIVADO_LOGS_ABS)/vivado_syn.log")
	@bit=vivado/$(DESIGN).runs/impl_1/$(TOP).bit; \
	if test -r $$bit; then \
		rm -rf $(TOP).bit; \
		ln -s $$bit; \
	else \
		echo $(SPACES)"ERROR: bitstream not found; synthesis failed"; \
		false; \
	fi;

vivado-syn-emu: vivado-setup-emu
	$(QUIET_INFO)echo "launching Vivado implementation script"
	@(cd vivado && $(PIPEFAIL_SHELL) -o pipefail -c 'vivado $(VIVADO_BATCH_OPT) -source syn_emu.tcl 2>&1 | tee "$$1"' _ "$(VIVADO_LOGS_ABS)/vivado_syn_emu.log")
	@bit=vivado/$(DESIGN)-chip-emu.runs/impl_1/chip_emu_top.bit; \
	if test -r $$bit; then \
		rm -rf chip_emu_top.bit; \
		ln -s $$bit; \
	else \
		echo $(SPACES)"ERROR: bitstream not found; synthesis failed"; \
		false; \
	fi;

vivado-update: vivado vivado/syn.tcl
	$(QUIET_INFO)echo "Updating implementaiton with Vivado"
	@test -r vivado/$(DESIGN).xpr || { echo -n $(SPACES)"Error: Vivado project \"$(DESIGN)\" does not exist. Please run 'make vivado-syn' first"; false; }
	@(cd vivado && $(PIPEFAIL_SHELL) -o pipefail -c 'vivado $(VIVADO_BATCH_OPT) -source syn.tcl 2>&1 | tee "$$1"' _ "$(VIVADO_LOGS_ABS)/vivado_syn.log")
	@bit=vivado/$(DESIGN).runs/impl_1/$(TOP).bit; \
	if test -r $$bit; then \
		rm -rf $(TOP).bit; \
		ln -s $$bit; \
	else \
		echo $(SPACES)"ERROR: bitstream not found; synthesis failed"; \
		false; \
	fi;

vivado-update-emu: vivado vivado/syn_emu.tcl
	$(QUIET_INFO)echo "Updating implementaiton with Vivado"
	@test -r vivado/$(DESIGN)-chip-emu.xpr || { echo -n $(SPACES)"Error: Vivado project \"$(DESIGN)-chip-emu\" does not exist. Please run 'make vivado-syn' first"; false; }
	@(cd vivado && $(PIPEFAIL_SHELL) -o pipefail -c 'vivado $(VIVADO_BATCH_OPT) -source syn_emu.tcl 2>&1 | tee "$$1"' _ "$(VIVADO_LOGS_ABS)/vivado_syn_emu.log")
	@bit=vivado/$(DESIGN)-chip-emu.runs/impl_1/chip_emu_top.bit; \
	if test -r $$bit; then \
		rm -rf chip_emu_top.bit; \
		ln -s $$bit; \
	else \
		echo $(SPACES)"ERROR: bitstream not found; synthesis failed"; \
		false; \
	fi;

endif # ifneq ($(filter $(TECHLIB),$(XIL_FPGALIBS)),)

vivado-prog-fpga: vivado/program.tcl
	@cd vivado; \
	bit=$(DESIGN).runs/impl_1/$(TOP).bit; \
	if test -r $$bit; then \
		vivado $(VIVADO_BATCH_OPT) -source program.tcl -tclargs $(FPGA_HOST) $(XIL_HW_SERVER_PORT) $(PART) $$bit; \
	else \
		echo $(SPACES)"ERROR: bitstream not found; please run target vivado-syn first"; \
		false; \
	fi; \
	cd ../;

vivado-clean:
	$(QUIET_CLEAN)$(RM) $(VIVADO_LOGS)

vivado-distclean: vivado-clean
	$(QUIET_CLEAN)$(RM) \
		vivado	\
		*.bit

.PHONY: vivado-clean vivado-distclean vivado-syn vivado-prog-fpga vivado/$(DESIGN) vivado-setup vivado-gui
