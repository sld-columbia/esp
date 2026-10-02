# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

package require qsys

proc env_or_default {name default_value} {
    if {[info exists ::env($name)]} {
        set value $::env($name)
        if {$value ne ""} {
            return $value
        }
    }
    return $default_value
}

proc require_step {description body} {
    if {[catch {uplevel 1 $body} message]} {
        error "$description failed: $message"
    }
}

proc warn_step {description body} {
    if {[catch {uplevel 1 $body} message]} {
        puts "INFO: $description skipped: $message"
    }
}

proc add_instance_compat {instance_name module_name version} {
    if {[catch {add_instance $instance_name $module_name $version}]} {
        add_instance $instance_name $module_name
    }
}

proc set_parameter_if_present {instance_name parameter_name value} {
    warn_step "set $instance_name.$parameter_name" \
        [list set_instance_parameter_value $instance_name $parameter_name $value]
}

proc set_parameter_list_if_present {instance_name parameter_name values} {
    warn_step "set $instance_name.$parameter_name" \
        [list set_instance_parameter_value $instance_name $parameter_name [join $values " "]]
}

proc export_interface {export_name type role source_interface} {
    require_step "export $source_interface as $export_name" [list add_interface $export_name $type $role]
    require_step "bind $export_name" [list set_interface_property $export_name EXPORT_OF $source_interface]
}

proc instance_interface_exists {source_interface} {
    set parts [split $source_interface "."]
    if {[llength $parts] != 2} {
        return 0
    }

    set instance_name [lindex $parts 0]
    set interface_name [lindex $parts 1]

    if {[catch {get_instance_interfaces $instance_name} interfaces]} {
        puts "INFO: cannot query interfaces for $instance_name"
        return 0
    }

    return [expr {[lsearch -exact $interfaces $interface_name] >= 0}]
}

proc export_interface_if_present {export_name type role source_interface} {
    if {[instance_interface_exists $source_interface]} {
        export_interface $export_name $type $role $source_interface
    } else {
        puts "INFO: skipping missing interface export $export_name from $source_interface"
    }
}

set system_file [env_or_default QUARTUS_QSYS_FILE qsys_top.qsys]
set system_name [file rootname [file tail $system_file]]
set device_name [env_or_default QUARTUS_DEVICE 1SX280HU2F50E1VG]

create_system $system_name

warn_step "set project device family" {set_project_property DEVICE_FAMILY "Stratix 10"}
warn_step "set project device" [list set_project_property DEVICE $device_name]

require_step "add clock bridge" {add_instance_compat clk_100 altera_clock_bridge 19.1}
require_step "add reset bridge" {add_instance_compat rst_in altera_reset_bridge 19.1}
require_step "add reset source/probe" {add_instance_compat src_prb_rst altera_in_system_sources_probes 19.1}
require_step "add HPS EMIF" {add_instance_compat emif_hps altera_emif_s10_hps 19.1.0}
require_step "add Stratix 10 HPS" {add_instance_compat s10_hps altera_stratix10_hps 19.1}

# This is the board HPS shared-I/O map. The wrapper only connects the HPS pins
# ESP uses, but the HPS IP validates the complete hard-pin assignment.
set hps_io_enable {
    NONE NONE NONE NONE NONE NONE NONE NONE NONE NONE NONE NONE
    EMAC0:TX_CLK EMAC0:TX_CTL EMAC0:RX_CLK EMAC0:RX_CTL
    EMAC0:TXD0 EMAC0:TXD1 EMAC0:RXD0 EMAC0:RXD1
    EMAC0:TXD2 EMAC0:TXD3 EMAC0:RXD2 EMAC0:RXD3
    NONE NONE UART0:TX UART0:RX NONE NONE NONE NONE
    NONE NONE NONE NONE SDMMC:D0 SDMMC:CMD SDMMC:CCLK SDMMC:D1
    SDMMC:D2 SDMMC:D3 NONE HPS_OSC_CLK GPIO NONE MDIO0:MDIO MDIO0:MDC
}
set hps_pin_to_ball_map {
    35 A32 36 P30 37 J30 38 A31 40 D31 39 H30 41 H32 42 B29
    43 J31 44 D33 45 D28 46 K31 47 B28 10 B30 11 D29 12 F31
    13 R29 14 G28 15 F30 16 J28 0 E29 17 E28 1 C33 18 B34
    2 D30 19 E31 20 P29 3 A30 21 B32 4 C32 22 G29 5 A27
    23 H28 6 A29 24 G30 7 E33 25 C28 8 F29 26 F32 9 E32
    27 K29 28 A34 29 N30 30 B33 31 H31 32 K28 33 J29 34 G32
}

# The Platform Designer interface keeps the clk_100 name, but the board wrapper
# drives it from CLK_50_B3C.
set_parameter_if_present clk_100 EXPLICIT_CLOCK_RATE 50000000
set_parameter_if_present clk_100 DERIVED_CLOCK_RATE 50000000

set_parameter_if_present rst_in ACTIVE_LOW_RESET 1
set_parameter_if_present rst_in NUM_RESET_OUTPUTS 1
set_parameter_if_present rst_in SYNCHRONOUS_EDGES both
set_parameter_if_present rst_in USE_RESET_REQUEST 0

set_parameter_if_present src_prb_rst device_family "Stratix 10"
set_parameter_if_present src_prb_rst source_width 1
set_parameter_if_present src_prb_rst source_initial_value 1
set_parameter_if_present src_prb_rst probe_width 0
set_parameter_if_present src_prb_rst create_source_clock true
set_parameter_if_present src_prb_rst enable_metastability YES

# Match the DE10-Pro SX 16 GB GHRD memory device rather than relying on the
# EMIF catalog defaults. PROTOCOL_ENUM selects DDR4; MEM_FORMAT_ENUM selects
# the physical module organization and must therefore be UDIMM, not "DDR4".
set_parameter_if_present emif_hps PROTOCOL_ENUM PROTOCOL_DDR4
set_parameter_if_present emif_hps MEM_FORMAT_ENUM MEM_FORMAT_UDIMM
set_parameter_if_present emif_hps MEM_DDR4_FORMAT_ENUM MEM_FORMAT_UDIMM
set_parameter_if_present emif_hps PHY_REF_CLK_FREQ_MHZ 266.667
set_parameter_if_present emif_hps PHY_DDR4_MEM_CLK_FREQ_MHZ 1066.667
set_parameter_if_present emif_hps PHY_DDR4_REF_CLK_FREQ_MHZ 266.667
set_parameter_if_present emif_hps PHY_DDR4_USER_REF_CLK_FREQ_MHZ 133.333
set_parameter_if_present emif_hps MEM_DDR4_DQ_WIDTH 72
set_parameter_if_present emif_hps MEM_DDR4_DQS_WIDTH 9
set_parameter_if_present emif_hps MEM_DDR4_DQ_PER_DQS 8
set_parameter_if_present emif_hps MEM_DDR4_DISCRETE_CS_WIDTH 1
set_parameter_if_present emif_hps MEM_DDR4_NUM_OF_DIMMS 1
set_parameter_if_present emif_hps MEM_DDR4_RANKS_PER_DIMM 1
set_parameter_if_present emif_hps MEM_DDR4_CKE_PER_DIMM 1
set_parameter_if_present emif_hps MEM_DDR4_CK_WIDTH 1
set_parameter_if_present emif_hps MEM_DDR4_ROW_ADDR_WIDTH 15
set_parameter_if_present emif_hps MEM_DDR4_COL_ADDR_WIDTH 10
set_parameter_if_present emif_hps MEM_DDR4_ADDR_WIDTH 17
set_parameter_if_present emif_hps MEM_DDR4_BANK_ADDR_WIDTH 2
set_parameter_if_present emif_hps MEM_DDR4_BANK_GROUP_WIDTH 2
set_parameter_if_present emif_hps MEM_DDR4_SPEEDBIN_ENUM DDR4_SPEEDBIN_2666
set_parameter_if_present emif_hps MEM_DDR4_DM_EN true
set_parameter_if_present emif_hps MEM_DDR4_ALERT_PAR_EN true
set_parameter_if_present emif_hps MEM_DDR4_ALERT_N_PLACEMENT_ENUM DDR4_ALERT_N_PLACEMENT_DATA_LANES
set_parameter_if_present emif_hps MEM_DDR4_MIRROR_ADDRESSING_EN true
set_parameter_if_present emif_hps MEM_DDR4_USE_DEFAULT_ODT true
set_parameter_if_present emif_hps MEM_DDR4_DRV_STR_ENUM DDR4_DRV_STR_RZQ_7
set_parameter_if_present emif_hps MEM_DDR4_RTT_NOM_ENUM DDR4_RTT_NOM_RZQ_5
set_parameter_if_present emif_hps MEM_DDR4_RTT_WR_ENUM DDR4_RTT_WR_ODT_DISABLED
set_parameter_if_present emif_hps MEM_DDR4_GEARDOWN DDR4_GEARDOWN_HR
set_parameter_if_present emif_hps MEM_DDR4_TCL 19
set_parameter_if_present emif_hps MEM_DDR4_WTCL 14
set_parameter_if_present emif_hps MEM_DDR4_TFAW_NS 21.0
set_parameter_if_present emif_hps MEM_DDR4_TRAS_NS 32.0
set_parameter_if_present emif_hps MEM_DDR4_TRCD_NS 14.25
set_parameter_if_present emif_hps MEM_DDR4_TREFI_US 7.8
set_parameter_if_present emif_hps MEM_DDR4_TRFC_NS 260.0
set_parameter_if_present emif_hps MEM_DDR4_TRP_NS 14.25
set_parameter_if_present emif_hps MEM_DDR4_TWR_NS 15.0
set_parameter_if_present emif_hps MEM_DDR4_TWTR_L_CYC 4
set_parameter_if_present emif_hps MEM_DDR4_TWTR_S_CYC 2
set_parameter_if_present emif_hps MEM_DDR4_TRRD_L_CYC 4
set_parameter_if_present emif_hps MEM_DDR4_TCCD_L_CYC 5
set_parameter_if_present emif_hps MEM_DDR4_TRFC_DLR_NS 260.0
set_parameter_if_present emif_hps MEM_DDR4_TDQSCK_PS 170
set_parameter_if_present emif_hps MEM_DDR4_TDQSQ_UI 0.18
set_parameter_if_present emif_hps MEM_DDR4_TQH_UI 0.74
set_parameter_if_present emif_hps MEM_DDR4_TQSH_CYC 0.4
set_parameter_if_present emif_hps MEM_DDR4_TDIVW_TOTAL_UI 0.22
set_parameter_if_present emif_hps MEM_DDR4_VDIVW_TOTAL 120
set_parameter_if_present emif_hps MEM_DDR4_READ_DBI true
set_parameter_if_present emif_hps MEM_DDR4_WRITE_DBI false
set_parameter_if_present emif_hps PHY_DDR4_DEFAULT_IO false
set_parameter_if_present emif_hps PHY_DDR4_USER_AC_IO_STD_ENUM IO_STD_SSTL_12
set_parameter_if_present emif_hps PHY_DDR4_USER_AC_MODE_ENUM OUT_OCT_40_CAL
set_parameter_if_present emif_hps PHY_DDR4_USER_AC_SLEW_RATE_ENUM SLEW_RATE_FAST
set_parameter_if_present emif_hps PHY_DDR4_USER_AUTO_STARTING_VREFIN_EN true
set_parameter_if_present emif_hps PHY_DDR4_USER_CK_IO_STD_ENUM IO_STD_SSTL_12
set_parameter_if_present emif_hps PHY_DDR4_USER_CK_MODE_ENUM OUT_OCT_40_CAL
set_parameter_if_present emif_hps PHY_DDR4_USER_CK_SLEW_RATE_ENUM SLEW_RATE_FAST
set_parameter_if_present emif_hps PHY_DDR4_USER_CLAMSHELL_EN false
set_parameter_if_present emif_hps PHY_DDR4_USER_DATA_IN_MODE_ENUM IN_OCT_48_CAL
set_parameter_if_present emif_hps PHY_DDR4_USER_DATA_IO_STD_ENUM IO_STD_POD_12
set_parameter_if_present emif_hps PHY_DDR4_USER_DATA_OUT_MODE_ENUM OUT_OCT_34_CAL
set_parameter_if_present emif_hps PHY_DDR4_USER_DLL_CORE_UPDN_EN false
set_parameter_if_present emif_hps PHY_DDR4_USER_PERIODIC_OCT_RECAL_ENUM PERIODIC_OCT_RECAL_AUTO
set_parameter_if_present emif_hps PHY_DDR4_USER_PING_PONG_EN false
set_parameter_if_present emif_hps PHY_DDR4_USER_PLL_REF_CLK_IO_STD_ENUM IO_STD_LVDS_NO_OCT
set_parameter_if_present emif_hps PHY_DDR4_USER_RZQ_IO_STD_ENUM IO_STD_CMOS_12
set_parameter_if_present emif_hps PHY_DDR4_USER_STARTING_VREFIN 70.0
set_parameter_if_present emif_hps PHY_DDR4_DATA_IO_STD_ENUM IO_STD_POD_12
set_parameter_if_present emif_hps PHY_DDR4_DATA_IN_MODE_ENUM IN_OCT_48_CAL
set_parameter_if_present emif_hps PHY_DDR4_DATA_OUT_MODE_ENUM OUT_OCT_34_CAL
set_parameter_if_present emif_hps PHY_DDR4_AC_IO_STD_ENUM IO_STD_SSTL_12
set_parameter_if_present emif_hps PHY_DDR4_AC_MODE_ENUM OUT_OCT_40_CAL
set_parameter_if_present emif_hps PHY_DDR4_CK_IO_STD_ENUM IO_STD_SSTL_12
set_parameter_if_present emif_hps PHY_DDR4_CK_MODE_ENUM OUT_OCT_40_CAL
set_parameter_if_present emif_hps PHY_DDR4_PLL_REF_CLK_IO_STD_ENUM IO_STD_LVDS_NO_OCT
set_parameter_if_present emif_hps PHY_DDR4_RZQ_IO_STD_ENUM IO_STD_CMOS_12

# Board trace-delay and skew values affect EMIF calibration margins and must
# match the DE10-Pro SX 16 GB routing rather than the IP catalog defaults.
set_parameter_if_present emif_hps BOARD_DDR4_MAX_CK_DELAY_NS 0.565703659
set_parameter_if_present emif_hps BOARD_DDR4_MAX_DQS_DELAY_NS 0.597036059
set_parameter_if_present emif_hps BOARD_DDR4_AC_TO_CK_SKEW_NS -2.10241E-4
set_parameter_if_present emif_hps BOARD_DDR4_DQS_TO_CK_SKEW_NS -0.048363933
set_parameter_if_present emif_hps BOARD_DDR4_SKEW_BETWEEN_DQS_NS 0.159407567
set_parameter_if_present emif_hps BOARD_DDR4_SKEW_WITHIN_AC_NS 0.002277926
set_parameter_if_present emif_hps BOARD_DDR4_PKG_BRD_SKEW_WITHIN_AC_NS 0.002277926
set_parameter_if_present emif_hps BOARD_DDR4_SKEW_WITHIN_DQS_NS 0.001410759
set_parameter_if_present emif_hps BOARD_DDR4_PKG_BRD_SKEW_WITHIN_DQS_NS 0.001410759
set_parameter_if_present emif_hps BOARD_DDR4_IS_SKEW_WITHIN_AC_DESKEWED true

set_parameter_if_present emif_hps CTRL_ECC_EN true
set_parameter_if_present emif_hps CTRL_DDR4_ECC_EN true
set_parameter_if_present emif_hps CTRL_DDR4_ECC_AUTO_CORRECTION_EN true
set_parameter_if_present emif_hps CTRL_DDR4_ADDR_ORDER_ENUM DDR4_CTRL_ADDR_ORDER_CS_R_B_C_BG
set_parameter_if_present emif_hps CTRL_DDR4_REORDER_EN true

# These "Width" fields are Quartus HPS enum values, not literal bit widths.
# The board wrapper expects 32-bit H2F control traffic and 64-bit F2SDRAM0
# payload traffic, matching the HPS interfaces used by the ESP bridge RTL.
set_parameter_if_present s10_hps EMIF_CONDUIT_Enable 1
set_parameter_if_present s10_hps MPU_EVENTS_Enable false
set_parameter_if_present s10_hps F2S_Width 3
set_parameter_if_present s10_hps F2S_ready_latency 0
set_parameter_if_present s10_hps S2F_Width 1
set_parameter_if_present s10_hps S2F_ready_latency 0
set_parameter_if_present s10_hps LWH2F_Enable 1
set_parameter_if_present s10_hps LWH2F_ready_latency 0
set_parameter_if_present s10_hps F2SDRAM0_Width 2
set_parameter_if_present s10_hps F2SDRAM0_ready_latency 0
set_parameter_if_present s10_hps F2SDRAM_ADDRESS_WIDTH 33
set_parameter_if_present s10_hps F2SINTERRUPT_Enable 1
set_parameter_if_present s10_hps STM_Enable 1
set_parameter_if_present s10_hps H2F_AXI_CLOCK_FREQ 50000000
set_parameter_if_present s10_hps H2F_LW_AXI_CLOCK_FREQ 50000000
set_parameter_if_present s10_hps F2H_AXI_CLOCK_FREQ 50000000
set_parameter_if_present s10_hps F2H_SDRAM0_CLOCK_FREQ 50000000

# HPS clock-manager handoff values for the DE10-Pro SX boot flow.
set_parameter_if_present s10_hps HPS_BOOT 1
set_parameter_if_present s10_hps eosc1_clk_mhz 25.0
set_parameter_if_present s10_hps INTERNAL_OSCILLATOR_ENABLE 60
set_parameter_if_present s10_hps FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_SDMMC_CCLK 100
set_parameter_if_present s10_hps SDMMC_REF_CLK 200
set_parameter_if_present s10_hps DEFAULT_MPU_CLK 1200
set_parameter_if_present s10_hps MPU_CLK_VCCL 2
set_parameter_if_present s10_hps USE_DEFAULT_MPU_CLK false
set_parameter_if_present s10_hps CUSTOM_MPU_CLK 800
set_parameter_if_present s10_hps PSI_CLK_FREQ 500
set_parameter_if_present s10_hps EMAC_PTP_REF_CLK 100
set_parameter_if_present s10_hps GPIO_REF_CLK 4
set_parameter_if_present s10_hps GPIO_REF_CLK2 200
set_parameter_if_present s10_hps L3_MAIN_FREE_CLK 400
set_parameter_if_present s10_hps L4_SYS_FREE_CLK 1
set_parameter_if_present s10_hps NOCDIV_L4MAINCLK 0
set_parameter_if_present s10_hps NOCDIV_L4MPCLK 1
set_parameter_if_present s10_hps NOCDIV_L4SPCLK 2
set_parameter_if_present s10_hps NOCDIV_CS_ATCLK 0
set_parameter_if_present s10_hps NOCDIV_CS_PDBGCLK 1
set_parameter_if_present s10_hps NOCDIV_CS_TRACECLK 0
set_parameter_if_present s10_hps HPS_DIV_GPIO_FREQ 125
set_parameter_if_present s10_hps HPS_DIV_GPIO_FREQ2 200
set_parameter_if_present s10_hps CONFIG_HPS_DIV_GPIO 1
set_parameter_if_present s10_hps EMAC0_CLK 250
set_parameter_if_present s10_hps EMAC1_CLK 250
set_parameter_if_present s10_hps EMAC2_CLK 250
set_parameter_if_present s10_hps DISABLE_PERI_PLL false
set_parameter_if_present s10_hps OVERIDE_PERI_PLL false
set_parameter_if_present s10_hps PERI_PLL_MANUAL_VCO_FREQ 2000
set_parameter_if_present s10_hps PERI_PLL_AUTO_VCO_FREQ 3000
set_parameter_if_present s10_hps CLK_MAIN_PLL_SOURCE2 0
set_parameter_if_present s10_hps CLK_PERI_PLL_SOURCE2 0
set_parameter_if_present s10_hps CLK_MPU_SOURCE 0
set_parameter_if_present s10_hps CLK_MPU_CNT 0
set_parameter_if_present s10_hps CLK_NOC_SOURCE 0
set_parameter_if_present s10_hps CLK_NOC_CNT 0
set_parameter_if_present s10_hps CLK_S2F_USER0_SOURCE 1
set_parameter_if_present s10_hps CLK_S2F_USER1_SOURCE 1
set_parameter_if_present s10_hps CLK_PSI_SOURCE 1
set_parameter_if_present s10_hps CLK_EMAC_PTP_SOURCE 1
set_parameter_if_present s10_hps CLK_GPIO_SOURCE 0
set_parameter_if_present s10_hps CLK_SDMMC_SOURCE 0
set_parameter_if_present s10_hps CLK_EMACA_SOURCE 1
set_parameter_if_present s10_hps CLK_EMACB_SOURCE 1
set_parameter_if_present s10_hps EMAC0SEL 0
set_parameter_if_present s10_hps EMAC1SEL 0
set_parameter_if_present s10_hps EMAC2SEL 0
set_parameter_if_present s10_hps MAINPLLGRP_VCO_DENOM 1
set_parameter_if_present s10_hps MAINPLLGRP_VCO_NUMER 90
set_parameter_if_present s10_hps MAINPLLGRP_MPU_CNT 2
set_parameter_if_present s10_hps MAINPLLGRP_NOC_CNT 6
set_parameter_if_present s10_hps MAINPLLGRP_EMACA_CNT 999
set_parameter_if_present s10_hps MAINPLLGRP_EMACB_CNT 999
set_parameter_if_present s10_hps MAINPLLGRP_EMAC_PTP_CNT 999
set_parameter_if_present s10_hps MAINPLLGRP_GPIO_DB_CNT 1
set_parameter_if_present s10_hps MAINPLLGRP_SDMMC_CNT 1
set_parameter_if_present s10_hps MAINPLLGRP_S2F_USER0_CNT 999
set_parameter_if_present s10_hps MAINPLLGRP_S2F_USER1_CNT 999
set_parameter_if_present s10_hps MAINPLLGRP_PSI_CNT 999
set_parameter_if_present s10_hps MAINPLLGRP_PERIPH_REF_CNT 999
set_parameter_if_present s10_hps PERPLLGRP_VCO_DENOM 1
set_parameter_if_present s10_hps PERPLLGRP_VCO_NUMER 74
set_parameter_if_present s10_hps PERPLLGRP_MPU_CNT 999
set_parameter_if_present s10_hps PERPLLGRP_NOC_CNT 2
set_parameter_if_present s10_hps PERPLLGRP_EMACA_CNT 3
set_parameter_if_present s10_hps PERPLLGRP_EMACB_CNT 999
set_parameter_if_present s10_hps PERPLLGRP_EMAC_PTP_CNT 9
set_parameter_if_present s10_hps PERPLLGRP_GPIO_DB_CNT 999
set_parameter_if_present s10_hps PERPLLGRP_SDMMC_CNT 999
set_parameter_if_present s10_hps PERPLLGRP_S2F_USER0_CNT 1
set_parameter_if_present s10_hps PERPLLGRP_S2F_USER1_CNT 1
set_parameter_if_present s10_hps PERPLLGRP_PSI_CNT 1

set_parameter_if_present s10_hps EMAC0_PinMuxing IO
set_parameter_if_present s10_hps EMAC0_Mode RGMII_with_MDIO
set_parameter_if_present s10_hps SDMMC_PinMuxing IO
set_parameter_if_present s10_hps SDMMC_Mode 4-bit
set_parameter_if_present s10_hps UART0_PinMuxing IO
set_parameter_if_present s10_hps UART0_Mode No_flow_control
set_parameter_if_present s10_hps USB0_PinMuxing Unused
set_parameter_if_present s10_hps UART1_PinMuxing Unused
# Add the board delay to EMAC0 TX_CLK (HPS shared-I/O slot 12).
set_parameter_if_present s10_hps IO_OUTPUT_DELAY12 17
set_parameter_if_present s10_hps hps_device_family "Stratix 10"
set_parameter_if_present s10_hps device_name $device_name
set_parameter_list_if_present s10_hps PIN_TO_BALL_MAP $hps_pin_to_ball_map
set_parameter_list_if_present s10_hps HPS_IO_Enable $hps_io_enable

sync_sysinfo_parameters

export_interface clk_100 clock sink clk_100.in_clk
export_interface reset reset sink rst_in.in_reset
export_interface src_prb_rst_sources conduit end src_prb_rst.sources
export_interface emif_hps_pll_ref_clk clock sink emif_hps.pll_ref_clk
export_interface emif_hps_mem conduit end emif_hps.mem
export_interface emif_hps_oct conduit end emif_hps.oct
export_interface s10_hps_f2h_stm_hw_events conduit end s10_hps.f2h_stm_hw_events
export_interface_if_present s10_hps_h2f_mpu_events conduit end s10_hps.h2f_mpu_events
export_interface_if_present hps_io conduit end s10_hps.hps_io
export_interface f2h_irq1 interrupt receiver s10_hps.f2h_irq1
export_interface h2f_reset reset source s10_hps.h2f_reset
export_interface s10_hps_h2f_axi_clock clock sink s10_hps.h2f_axi_clock
export_interface s10_hps_h2f_axi_reset reset sink s10_hps.h2f_axi_reset
export_interface s10_hps_h2f_axi_master axi4 start s10_hps.h2f_axi_master
export_interface s10_hps_f2sdram0_clock clock sink s10_hps.f2sdram0_clock
export_interface s10_hps_f2sdram0_reset reset sink s10_hps.f2sdram0_reset
export_interface s10_hps_f2sdram0_data axi4 end s10_hps.f2sdram0_data

require_step "connect reset bridge clock" {add_connection clk_100.out_clk rst_in.clk}
require_step "connect reset source/probe clock" {add_connection clk_100.out_clk src_prb_rst.source_clk}
require_step "connect HPS F2H AXI clock" {add_connection clk_100.out_clk s10_hps.f2h_axi_clock}
require_step "connect HPS H2F lightweight AXI clock" {add_connection clk_100.out_clk s10_hps.h2f_lw_axi_clock}
require_step "connect HPS F2H AXI reset" {add_connection rst_in.out_reset s10_hps.f2h_axi_reset}
require_step "connect HPS H2F lightweight AXI reset" {add_connection rst_in.out_reset s10_hps.h2f_lw_axi_reset}
require_step "connect HPS EMIF conduit" {add_connection emif_hps.hps_emif s10_hps.hps_emif}

sync_sysinfo_parameters
save_system $system_file
