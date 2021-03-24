# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

### Constaints ###
ifneq ($(filter $(TECHLIB),$(FPGALIBS)),)
XDC   = $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD).xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-mig-pins.xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-mig-constraints.xdc
ifneq ($(findstring profpga, $(BOARD)),)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-mmi64.xdc
endif
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-eth-pins.xdc
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-dvi-pins.xdc
ifeq ($(CONFIG_GRETH_ENABLE),y)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-eth-constraints.xdc
endif
ifeq ($(CONFIG_SVGA_ENABLE),y)
XDC  += $(ESP_ROOT)/constraints/$(BOARD)/$(BOARD)-dvi-constraints.xdc
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

vivado/srcs.tcl: vivado $(RTL_CFG_BUILD)/check_all_rtl_srcs.old
	$(QUIET_INFO)echo "generating source list for Vivado"
	@$(RM) $@
ifneq ($(findstring profpga, $(BOARD)),)
	@for vhd in $(VHDL_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$vhd; \
		echo "read_vhdl -library profpga $$rtl" >> $@; \
	done;
	@for ver in $(VERILOG_PROFPGA); do \
		rtl=$(PROFPGA)/hdl/$$ver; \
		echo "read_verilog -library profpga $$rtl" >> $@; \
	done;
endif
	@for rtl in $(VHDL_PKGS); do \
		echo "read_vhdl $$rtl" >> $@; \
	done;
	@for rtl in $(VHDL_SRCS); do \
		echo "read_vhdl $$rtl" >> $@; \
	done;
	@for rtl in $(VLOG_SRCS); do \
		echo "read_verilog -sv $$rtl" >> $@; \
	done;
	@for dat in $(DAT_SRCS); do \
		echo "add_files $$dat" >> $@; \
	done;


vivado/setup.tcl: vivado $(XDC) $(BOARD_FILES)
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
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.xci; then \
		echo $(SPACES)"INFO including MIG IP"; \
		mkdir -p vivado/mig; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.xci ./vivado/mig; \
		if test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.prj; then \
			cp $(ESP_ROOT)/constraints/$(BOARD)/mig.prj ./vivado/mig; \
		fi; \
		echo "import_ip -files ./mig/mig.xci" >> $@; \
		echo "generate_target  all [get_ips mig] -force " >> $@; \
	elif test -r $(ESP_ROOT)/constraints/$(BOARD)/mig.tcl; then \
		echo $(SPACES)"INFO including MIG IP"; \
		mkdir -p vivado/mig; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/mig.tcl ./vivado/mig; \
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
		echo "set argv [list $(NOC_WIDTH)]" >> $@; \
		echo "set argv [list $(NOC_WIDTH)]" >> $@; \
		echo "set argc 1" >> $@; \
		echo "source ./zynq/zynq.tcl" >> $@; \
		echo "unset argv" >> $@; \
		echo "set argc 0" >> $@; \
	fi;
ifeq ($(CONFIG_GRETH_ENABLE),y)
	@if test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci; then \
		echo $(SPACES)"INFO including SGMII IP"; \
		mkdir -p vivado/sgmii; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.xci ./vivado/sgmii; \
		echo "set_property target_language verilog [current_project]" >> $@; \
		echo "import_ip -files ./sgmii/sgmii.xci" >> $@; \
		echo "generate_target  all [get_ips sgmii] -force " >> $@; \
	elif test -r $(ESP_ROOT)/constraints/$(BOARD)/sgmii.tcl; then \
		echo $(SPACES)"INFO including SGMII IP"; \
		mkdir -p vivado/sgmii; \
		cp $(ESP_ROOT)/constraints/$(BOARD)/sgmii.tcl ./vivado/sgmii; \
		echo "set_property target_language verilog [current_project]" >> $@; \
		echo "source ./sgmii/sgmii.tcl" >> $@; \
		echo "generate_target  all [get_ips sgmii] -force " >> $@; \
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
	  echo "read_xdc $$i" >> $@; \
	  echo "set_property used_in_synthesis true [get_files $$i]" >> $@; \
	  echo "set_property used_in_implementation true [get_files $$i]" >> $@; \
	done;
	@echo "set_property top $(TOP) [current_fileset]" >> $@

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
	@echo "wait_on_run -timeout 360 synth_1" >> $@
	@echo "set_msg_config -suppress -id {Drc 23-20}" >> $@
	@echo "launch_runs impl_1 -jobs 12" >> $@
	@echo "wait_on_run -timeout 360 impl_1" >> $@
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

vivado-setup: check_all_rtl_srcs vivado/$(DESIGN)

vivado-gui: vivado-setup
	$(QUIET_RUN)
	@cd vivado; \
	vivado $(DESIGN).xpr; \
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
