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


ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)

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

$(VIVADO_LOGS):
	$(QUIET_MKDIR)mkdir -p $(VIVADO_LOGS)

vivado: $(VIVADO_LOGS)
	$(QUIET_MKDIR)mkdir -p vivado

ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)

vivado/srcs.tcl: vivado check_all_rtl_srcs $(RTL_CFG_BUILD)/check_all_rtl_srcs.old
	$(QUIET_INFO)echo "generating source list for Vivado"
	@$(RM) $@
ifneq ($(findstring profpga, $(BOARD)),)
	@for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo "read_vhdl -library profpga $$rtl" >> $@; \
	done;
	@for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo "read_verilog -library profpga -sv $$rtl" >> $@; \
	done;
endif
	@for rtl in $(BASE_VHDL_PKGS); do \
		echo "read_vhdl $$rtl" >> $@; \
	done;
	@for rtl in $(BASE_VHDL_SRCS); do \
		case "$$rtl" in \
			$(DESIGN_PATH)/socketgen/noc_*.vhd) continue ;; \
		esac; \
		echo "read_vhdl $$rtl" >> $@; \
	done;
	@if test -d $(DESIGN_PATH)/socketgen; then \
		for rtl in `find $(DESIGN_PATH)/socketgen -maxdepth 1 -type f -name "noc_*.vhd" | sort`; do \
			echo "read_vhdl $$rtl" >> $@; \
		done; \
	fi;
	@for rtl in $(BASE_VLOG_SRCS); do \
		case "$$rtl" in \
			$(ACC_TECH_DIR)/*) \
				accname=$$(printf "%s\n" "$$rtl" | awk -F/ '{for(i=1;i<=NF;i++) if($$i=="acc"){print $$(i+1); exit}}'); \
				case " $(RTL_ACC) " in *" $$accname "*) continue ;; esac ;; \
		esac; \
		echo "read_verilog -sv $$rtl" >> $@; \
	done;
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
	@for dat in $(DAT_SRCS); do \
		echo "add_files $$dat" >> $@; \
	done;


vivado/setup.tcl: vivado $(BOARD_FILES)
	$(QUIET_INFO)echo "generating project script for Vivado"
	@$(RM) $@
	@echo "create_project $(DESIGN) -part ${DEVICE} -force" > $@
	@echo "set_property target_language verilog [current_project]" >> $@
	@echo "set_property include_dirs {$(INCDIR)} [get_filesets {sim_1 sources_1}]" >> $@
ifeq ("$(CPU_ARCH)","ibex")
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1 PRIM_DEFAULT_IMPL=prim_pkg::ImplXilinx} [get_filesets {sim_1 sources_1}]" >> $@
else
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1} [get_filesets {sim_1 sources_1}]" >> $@
endif
	@echo "source ./srcs.tcl" >> $@
ifneq ("$(PROTOBOARD)","")
	@echo "set_property board_part $(PROTOBOARD) [current_project]"  >> $@
endif
ifneq ($(IP_XCI_SRCS),)
	@for rtl in $(IP_XCI_SRCS); do \
		echo "import_ip -files $$rtl" >> $@; \
	done;
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


vivado/setup_emu.tcl: vivado $(BOARD_FILES)
	$(QUIET_INFO)echo "generating project script for Vivado"
	@$(RM) $@
	@echo "create_project $(DESIGN)-chip-emu -part ${DEVICE} -force" > $@
	@echo "set_property target_language verilog [current_project]" >> $@
	@echo "set_property include_dirs {$(INCDIR)} [get_filesets {sim_1 sources_1}]" >> $@
ifeq ("$(CPU_ARCH)","ibex")
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1 PRIM_DEFAULT_IMPL=prim_pkg::ImplXilinx} [get_filesets {sim_1 sources_1}]" >> $@
else
	@echo "set_property verilog_define {XILINX_FPGA=1 WT_DCACHE=1} [get_filesets {sim_1 sources_1}]" >> $@
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


vivado/syn.tcl: vivado
	$(QUIET_INFO)echo "generating synthesis script for Vivado"
	@$(RM) $@
	@echo "open_project $(DESIGN).xpr" > $@
	@echo "update_ip_catalog" >> $@
	@echo "update_compile_order -fileset sources_1" >> $@
	@echo "reset_run impl_1" >> $@
	@echo "reset_run synth_1" >> $@
#	@echo "synth_design -rtl -name rtl_1" >> $@
#	@echo "synth_design -directive runtimeoptimize -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
#	@echo "synth_design -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
	@echo "launch_runs synth_1 -jobs 12" >> $@
	@echo "get_ips" >> $@
	@echo "wait_on_run -timeout 720 synth_1" >> $@
	@echo "set_msg_config -suppress -id {Drc 23-20}" >> $@
	@echo "launch_runs impl_1 -jobs 12" >> $@
	@echo "wait_on_run -timeout 720 impl_1" >> $@
	@echo "launch_runs impl_1 -to_step write_bitstream" >> $@
	@echo "wait_on_run -timeout 60 impl_1" >> $@

vivado/syn_emu.tcl: vivado
	$(QUIET_INFO)echo "generating synthesis script for Vivado"
	@$(RM) $@
	@echo "open_project $(DESIGN)-chip-emu.xpr" > $@
	@echo "update_ip_catalog" >> $@
	@echo "update_compile_order -fileset sources_1" >> $@
	@echo "reset_run impl_1" >> $@
	@echo "reset_run synth_1" >> $@
#	@echo "synth_design -rtl -name rtl_1" >> $@
#	@echo "synth_design -directive runtimeoptimize -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
#	@echo "synth_design -resource_sharing off -keep_equivalent_registers -no_lc -rtl -name rtl_1" >> $@
	@echo "launch_runs synth_1 -jobs 12" >> $@
	@echo "get_ips" >> $@
	@echo "wait_on_run -timeout 720 synth_1" >> $@
	@echo "set_msg_config -suppress -id {Drc 23-20}" >> $@
	@echo "launch_runs impl_1 -jobs 12" >> $@
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
	@cd vivado; \
	if test -r $(DESIGN).xpr; then \
		echo -n $(SPACES)"WARNING: overwrite existing Vivado project \"$(DESIGN)\"? [y|n]"; \
		while true; do \
			read -p " " yn; \
			case $$yn in \
				[Yy] ) \
					$(RM) $(DESIGN); \
					vivado $(VIVADO_BATCH_OPT) -source setup.tcl | tee ../$(VIVADO_LOGS)/vivado_setup.log; \
					break;; \
				[Nn] ) \
					echo $(SPACES)"INFO aborting $@"; \
					break;; \
				* ) echo -n $(SPACES)"INFO Please answer yes or no [y|n].";; \
			esac; \
		done; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source setup.tcl | tee ../$(VIVADO_LOGS)/vivado_setup.log; \
	fi; \
	cd ../;

vivado/$(DESIGN)-chip-emu: vivado vivado/srcs.tcl vivado/setup_emu.tcl vivado/syn_emu.tcl
	$(QUIET_INFO)echo "launching Vivado setup script"
	@cd vivado; \
	if test -r $(DESIGN)-chip-emu.xpr; then \
		echo -n $(SPACES)"WARNING: overwrite existing Vivado project \"$(DESIGN)-chip-emu\"? [y|n]"; \
		while true; do \
			read -p " " yn; \
			case $$yn in \
				[Yy] ) \
					$(RM) $(DESIGN)-chip-emu; \
					vivado $(VIVADO_BATCH_OPT) -source setup_emu.tcl | tee ../$(VIVADO_LOGS)/vivado_setup_emu.log; \
					break;; \
				[Nn] ) \
					echo $(SPACES)"INFO aborting $@"; \
					break;; \
				* ) echo -n $(SPACES)"INFO Please answer yes or no [y|n].";; \
			esac; \
		done; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source setup_emu.tcl | tee ../$(VIVADO_LOGS)/vivado_setup_emu.log; \
	fi; \
	cd ../;

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
	@cd vivado; \
	vivado $(VIVADO_BATCH_OPT) -source syn.tcl | tee ../$(VIVADO_LOGS)/vivado_syn.log; \
	cd ../;
	@bit=vivado/$(DESIGN).runs/impl_1/$(TOP).bit; \
	if test -r $$bit; then \
		rm -rf $(TOP).bit; \
		ln -s $$bit; \
	else \
		echo $(SPACES)"ERROR: bistream not found; synthesis failed"; \
	fi; \

vivado-syn-emu: vivado-setup-emu
	$(QUIET_INFO)echo "launching Vivado implementation script"
	@cd vivado; \
	vivado $(VIVADO_BATCH_OPT) -source syn_emu.tcl | tee ../$(VIVADO_LOGS)/vivado_syn_emu.log; \
	cd ../;
	@bit=vivado/$(DESIGN)-chip-emu.runs/impl_1/chip_emu_top.bit; \
	if test -r $$bit; then \
		rm -rf chip_emu_top.bit; \
		ln -s $$bit; \
	else \
		echo $(SPACES)"ERROR: bistream not found; synthesis failed"; \
	fi; \

vivado-update: vivado vivado/syn.tcl
	$(QUIET_INFO)echo "Updating implementaiton with Vivado"
	@cd vivado; \
	if ! test -r $(DESIGN).xpr; then \
		echo -n $(SPACES)"Error: Vivado project \"$(DESIGN)\" does not exist. Please run 'make vivado-syn' first"; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source syn.tcl | tee ../$(VIVADO_LOGS)/vivado_syn.log; \
		cd ../; \
		bit=vivado/$(DESIGN).runs/impl_1/$(TOP).bit; \
		if test -r $$bit; then \
			rm -rf $(TOP).bit; \
			ln -s $$bit; \
		else \
			echo $(SPACES)"ERROR: bistream not found; synthesis failed"; \
		fi; \
	fi;

vivado-update-emu: vivado vivado/syn_emu.tcl
	$(QUIET_INFO)echo "Updating implementaiton with Vivado"
	@cd vivado; \
	if ! test -r $(DESIGN)-chip-emu.xpr; then \
		echo -n $(SPACES)"Error: Vivado project \"$(DESIGN)-chip-emu\" does not exist. Please run 'make vivado-syn' first"; \
	else \
		vivado $(VIVADO_BATCH_OPT) -source syn_emu.tcl | tee ../$(VIVADO_LOGS)/vivado_syn_emu.log; \
		cd ../; \
		bit=vivado/$(DESIGN)-chip-emu.runs/impl_1/chip_emu_top.bit; \
		if test -r $$bit; then \
			rm -rf chip_emu_top.bit; \
			ln -s $$bit; \
		else \
			echo $(SPACES)"ERROR: bistream not found; synthesis failed"; \
		fi; \
	fi;

endif # ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)

vivado-prog-fpga: vivado/program.tcl
	@cd vivado; \
	bit=$(DESIGN).runs/impl_1/$(TOP).bit; \
	if test -r $$bit; then \
		vivado $(VIVADO_BATCH_OPT) -source program.tcl -tclargs $(FPGA_HOST) $(XIL_HW_SERVER_PORT) $(PART) $$bit; \
	else \
		echo $(SPACES)"ERROR: bistream not found; please run target vivado-syn first"; \
	fi; \
	cd ../;

vivado-clean:
	$(QUIET_CLEAN)$(RM) $(VIVADO_LOGS)

vivado-distclean: vivado-clean
	$(QUIET_CLEAN)$(RM) \
		vivado	\
		*.bit

.PHONY: vivado-clean vivado-distclean vivado-syn vivado-prog-fpga vivado/$(DESIGN) vivado-setup vivado-gui
