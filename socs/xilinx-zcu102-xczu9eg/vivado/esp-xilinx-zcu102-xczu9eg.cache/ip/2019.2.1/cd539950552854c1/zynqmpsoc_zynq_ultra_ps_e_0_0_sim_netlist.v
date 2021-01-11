// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Mon Jan 11 12:09:53 2021
// Host        : skie running 64-bit Ubuntu 18.04.5 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ zynqmpsoc_zynq_ultra_ps_e_0_0_sim_netlist.v
// Design      : zynqmpsoc_zynq_ultra_ps_e_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* C_DP_USE_AUDIO = "0" *) (* C_DP_USE_VIDEO = "0" *) (* C_EMIO_GPIO_WIDTH = "1" *) 
(* C_EN_EMIO_TRACE = "0" *) (* C_EN_FIFO_ENET0 = "0" *) (* C_EN_FIFO_ENET1 = "0" *) 
(* C_EN_FIFO_ENET2 = "0" *) (* C_EN_FIFO_ENET3 = "0" *) (* C_MAXIGP0_DATA_WIDTH = "32" *) 
(* C_MAXIGP1_DATA_WIDTH = "32" *) (* C_MAXIGP2_DATA_WIDTH = "32" *) (* C_NUM_F2P_0_INTR_INPUTS = "1" *) 
(* C_NUM_F2P_1_INTR_INPUTS = "1" *) (* C_NUM_FABRIC_RESETS = "1" *) (* C_PL_CLK0_BUF = "TRUE" *) 
(* C_PL_CLK1_BUF = "FALSE" *) (* C_PL_CLK2_BUF = "FALSE" *) (* C_PL_CLK3_BUF = "FALSE" *) 
(* C_SAXIGP0_DATA_WIDTH = "64" *) (* C_SAXIGP1_DATA_WIDTH = "128" *) (* C_SAXIGP2_DATA_WIDTH = "128" *) 
(* C_SAXIGP3_DATA_WIDTH = "128" *) (* C_SAXIGP4_DATA_WIDTH = "128" *) (* C_SAXIGP5_DATA_WIDTH = "128" *) 
(* C_SAXIGP6_DATA_WIDTH = "128" *) (* C_SD0_INTERNAL_BUS_WIDTH = "8" *) (* C_SD1_INTERNAL_BUS_WIDTH = "8" *) 
(* C_TRACE_DATA_WIDTH = "32" *) (* C_TRACE_PIPELINE_WIDTH = "8" *) (* C_USE_DEBUG_TEST = "0" *) 
(* C_USE_DIFF_RW_CLK_GP0 = "0" *) (* C_USE_DIFF_RW_CLK_GP1 = "0" *) (* C_USE_DIFF_RW_CLK_GP2 = "0" *) 
(* C_USE_DIFF_RW_CLK_GP3 = "0" *) (* C_USE_DIFF_RW_CLK_GP4 = "0" *) (* C_USE_DIFF_RW_CLK_GP5 = "0" *) 
(* C_USE_DIFF_RW_CLK_GP6 = "0" *) (* HW_HANDOFF = "zynqmpsoc_zynq_ultra_ps_e_0_0.hwdef" *) (* PSS_IO = "Signal Name, DiffPair Type, DiffPair Signal,Direction, Site Type, IO Standard, Drive (mA), Slew Rate, Pull Type, IBIS Model, ODT, OUTPUT_IMPEDANCE \nQSPI_X4_SCLK_OUT, , , OUT, PS_MIO0_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MISO_MO1, , , INOUT, PS_MIO1_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO2, , , INOUT, PS_MIO2_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO3, , , INOUT, PS_MIO3_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MOSI_MI0, , , INOUT, PS_MIO4_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_N_SS_OUT, , , OUT, PS_MIO5_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_CLK_FOR_LPBK, , , OUT, PS_MIO6_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_N_SS_OUT_UPPER, , , OUT, PS_MIO7_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[0], , , INOUT, PS_MIO8_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[1], , , INOUT, PS_MIO9_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[2], , , INOUT, PS_MIO10_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[3], , , INOUT, PS_MIO11_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_SCLK_OUT_UPPER, , , OUT, PS_MIO12_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO0_GPIO0[13], , , INOUT, PS_MIO13_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C0_SCL_OUT, , , INOUT, PS_MIO14_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C0_SDA_OUT, , , INOUT, PS_MIO15_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C1_SCL_OUT, , , INOUT, PS_MIO16_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C1_SDA_OUT, , , INOUT, PS_MIO17_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART0_RXD, , , IN, PS_MIO18_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART0_TXD, , , OUT, PS_MIO19_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART1_TXD, , , OUT, PS_MIO20_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART1_RXD, , , IN, PS_MIO21_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO0_GPIO0[22], , , INOUT, PS_MIO22_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO0_GPIO0[23], , , INOUT, PS_MIO23_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nCAN1_PHY_TX, , , OUT, PS_MIO24_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nCAN1_PHY_RX, , , IN, PS_MIO25_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO1_GPIO1[26], , , INOUT, PS_MIO26_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_AUX_DATA_OUT, , , OUT, PS_MIO27_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_HOT_PLUG_DETECT, , , IN, PS_MIO28_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_AUX_DATA_OE, , , OUT, PS_MIO29_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_AUX_DATA_IN, , , IN, PS_MIO30_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPCIE_ROOT_RESET_N, , , OUT, PS_MIO31_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[0], , , OUT, PS_MIO32_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[1], , , OUT, PS_MIO33_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[2], , , OUT, PS_MIO34_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[3], , , OUT, PS_MIO35_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[4], , , OUT, PS_MIO36_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[5], , , OUT, PS_MIO37_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO1_GPIO1[38], , , INOUT, PS_MIO38_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[4], , , INOUT, PS_MIO39_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[5], , , INOUT, PS_MIO40_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[6], , , INOUT, PS_MIO41_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[7], , , INOUT, PS_MIO42_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO1_GPIO1[43], , , INOUT, PS_MIO43_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_WP, , , IN, PS_MIO44_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_CD_N, , , IN, PS_MIO45_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[0], , , INOUT, PS_MIO46_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[1], , , INOUT, PS_MIO47_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[2], , , INOUT, PS_MIO48_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[3], , , INOUT, PS_MIO49_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_CMD_OUT, , , INOUT, PS_MIO50_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_CLK_OUT, , , OUT, PS_MIO51_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_CLK_IN, , , IN, PS_MIO52_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_DIR, , , IN, PS_MIO53_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[2], , , INOUT, PS_MIO54_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_NXT, , , IN, PS_MIO55_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[0], , , INOUT, PS_MIO56_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[1], , , INOUT, PS_MIO57_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_STP, , , OUT, PS_MIO58_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[3], , , INOUT, PS_MIO59_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[4], , , INOUT, PS_MIO60_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[5], , , INOUT, PS_MIO61_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[6], , , INOUT, PS_MIO62_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[7], , , INOUT, PS_MIO63_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TX_CLK, , , OUT, PS_MIO64_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[0], , , OUT, PS_MIO65_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[1], , , OUT, PS_MIO66_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[2], , , OUT, PS_MIO67_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[3], , , OUT, PS_MIO68_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TX_CTL, , , OUT, PS_MIO69_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RX_CLK, , , IN, PS_MIO70_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[0], , , IN, PS_MIO71_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[1], , , IN, PS_MIO72_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[2], , , IN, PS_MIO73_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[3], , , IN, PS_MIO74_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RX_CTL, , , IN, PS_MIO75_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nMDIO3_GEM3_MDC, , , OUT, PS_MIO76_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nMDIO3_GEM3_MDIO_OUT, , , INOUT, PS_MIO77_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPCIE_MGTREFCLK0N, , , IN, PS_MGTREFCLK0N_505, , , , , ,,  \nPCIE_MGTREFCLK0P, , , IN, PS_MGTREFCLK0P_505, , , , , ,,  \nPS_REF_CLK, , , IN, PS_REF_CLK_503, LVCMOS18, 2, SLOW, , PS_MIO_LVCMOS18_S_2,,  \nPS_JTAG_TCK, , , IN, PS_JTAG_TCK_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_JTAG_TDI, , , IN, PS_JTAG_TDI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_JTAG_TDO, , , OUT, PS_JTAG_TDO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_JTAG_TMS, , , IN, PS_JTAG_TMS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_DONE, , , OUT, PS_DONE_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_ERROR_OUT, , , OUT, PS_ERROR_OUT_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_ERROR_STATUS, , , OUT, PS_ERROR_STATUS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_INIT_B, , , INOUT, PS_INIT_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE0, , , IN, PS_MODE0_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE1, , , IN, PS_MODE1_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE2, , , IN, PS_MODE2_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE3, , , IN, PS_MODE3_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_PADI, , , IN, PS_PADI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_PADO, , , OUT, PS_PADO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_POR_B, , , IN, PS_POR_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_PROG_B, , , IN, PS_PROG_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_SRST_B, , , IN, PS_SRST_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPCIE_MGTRRXN0, , , IN, PS_MGTRRXN0_505, , , , , ,,  \nPCIE_MGTRRXP0, , , IN, PS_MGTRRXP0_505, , , , , ,,  \nPCIE_MGTRTXN0, , , OUT, PS_MGTRTXN0_505, , , , , ,,  \nPCIE_MGTRTXP0, , , OUT, PS_MGTRTXP0_505, , , , , ,,  \nSATA1_MGTREFCLK1N, , , IN, PS_MGTREFCLK1N_505, , , , , ,,  \nSATA1_MGTREFCLK1P, , , IN, PS_MGTREFCLK1P_505, , , , , ,,  \nDP0_MGTRRXN1, , , IN, PS_MGTRRXN1_505, , , , , ,,  \nDP0_MGTRRXP1, , , IN, PS_MGTRRXP1_505, , , , , ,,  \nDP0_MGTRTXN1, , , OUT, PS_MGTRTXN1_505, , , , , ,,  \nDP0_MGTRTXP1, , , OUT, PS_MGTRTXP1_505, , , , , ,,  \nUSB0_MGTREFCLK2N, , , IN, PS_MGTREFCLK2N_505, , , , , ,,  \nUSB0_MGTREFCLK2P, , , IN, PS_MGTREFCLK2P_505, , , , , ,,  \nUSB0_MGTRRXN2, , , IN, PS_MGTRRXN2_505, , , , , ,,  \nUSB0_MGTRRXP2, , , IN, PS_MGTRRXP2_505, , , , , ,,  \nUSB0_MGTRTXN2, , , OUT, PS_MGTRTXN2_505, , , , , ,,  \nUSB0_MGTRTXP2, , , OUT, PS_MGTRTXP2_505, , , , , ,,  \nDP0_MGTREFCLK3N, , , IN, PS_MGTREFCLK3N_505, , , , , ,,  \nDP0_MGTREFCLK3P, , , IN, PS_MGTREFCLK3P_505, , , , , ,,  \nSATA1_MGTRRXN3, , , IN, PS_MGTRRXN3_505, , , , , ,,  \nSATA1_MGTRRXP3, , , IN, PS_MGTRRXP3_505, , , , , ,,  \nSATA1_MGTRTXN3, , , OUT, PS_MGTRTXN3_505, , , , , ,,  \nSATA1_MGTRTXP3, , , OUT, PS_MGTRTXP3_505, , , , , ,, \n DDR4_RAM_RST_N, , , OUT, PS_DDR_RAM_RST_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ACT_N, , , OUT, PS_DDR_ACT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_PARITY, , , OUT, PS_DDR_PARITY_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ALERT_N, , , IN, PS_DDR_ALERT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_CK0, P, DDR4_CK_N0, OUT, PS_DDR_CK0_504, DDR4, , , ,PS_DDR4_CK_OUT34_P, RTT_NONE, 34\n DDR4_CK_N0, N, DDR4_CK0, OUT, PS_DDR_CK_N0_504, DDR4, , , ,PS_DDR4_CK_OUT34_N, RTT_NONE, 34\n DDR4_CKE0, , , OUT, PS_DDR_CKE0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_CS_N0, , , OUT, PS_DDR_CS_N0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ODT0, , , OUT, PS_DDR_ODT0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BG0, , , OUT, PS_DDR_BG0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BG1, , , OUT, PS_DDR_BG1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BA0, , , OUT, PS_DDR_BA0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BA1, , , OUT, PS_DDR_BA1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ZQ, , , INOUT, PS_DDR_ZQ_504, DDR4, , , ,, , \n DDR4_A0, , , OUT, PS_DDR_A0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A1, , , OUT, PS_DDR_A1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A2, , , OUT, PS_DDR_A2_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A3, , , OUT, PS_DDR_A3_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A4, , , OUT, PS_DDR_A4_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A5, , , OUT, PS_DDR_A5_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A6, , , OUT, PS_DDR_A6_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A7, , , OUT, PS_DDR_A7_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A8, , , OUT, PS_DDR_A8_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A9, , , OUT, PS_DDR_A9_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A10, , , OUT, PS_DDR_A10_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A11, , , OUT, PS_DDR_A11_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A12, , , OUT, PS_DDR_A12_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A13, , , OUT, PS_DDR_A13_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A14, , , OUT, PS_DDR_A14_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A15, , , OUT, PS_DDR_A15_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_DQS_P0, P, DDR4_DQS_N0, INOUT, PS_DDR_DQS_P0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P1, P, DDR4_DQS_N1, INOUT, PS_DDR_DQS_P1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P2, P, DDR4_DQS_N2, INOUT, PS_DDR_DQS_P2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P3, P, DDR4_DQS_N3, INOUT, PS_DDR_DQS_P3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P4, P, DDR4_DQS_N4, INOUT, PS_DDR_DQS_P4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P5, P, DDR4_DQS_N5, INOUT, PS_DDR_DQS_P5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P6, P, DDR4_DQS_N6, INOUT, PS_DDR_DQS_P6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P7, P, DDR4_DQS_N7, INOUT, PS_DDR_DQS_P7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_N0, N, DDR4_DQS_P0, INOUT, PS_DDR_DQS_N0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N1, N, DDR4_DQS_P1, INOUT, PS_DDR_DQS_N1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N2, N, DDR4_DQS_P2, INOUT, PS_DDR_DQS_N2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N3, N, DDR4_DQS_P3, INOUT, PS_DDR_DQS_N3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N4, N, DDR4_DQS_P4, INOUT, PS_DDR_DQS_N4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N5, N, DDR4_DQS_P5, INOUT, PS_DDR_DQS_N5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N6, N, DDR4_DQS_P6, INOUT, PS_DDR_DQS_N6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N7, N, DDR4_DQS_P7, INOUT, PS_DDR_DQS_N7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DM0, , , OUT, PS_DDR_DM0_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM1, , , OUT, PS_DDR_DM1_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM2, , , OUT, PS_DDR_DM2_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM3, , , OUT, PS_DDR_DM3_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM4, , , OUT, PS_DDR_DM4_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM5, , , OUT, PS_DDR_DM5_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM6, , , OUT, PS_DDR_DM6_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM7, , , OUT, PS_DDR_DM7_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DQ0, , , INOUT, PS_DDR_DQ0_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ1, , , INOUT, PS_DDR_DQ1_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ2, , , INOUT, PS_DDR_DQ2_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ3, , , INOUT, PS_DDR_DQ3_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ4, , , INOUT, PS_DDR_DQ4_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ5, , , INOUT, PS_DDR_DQ5_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ6, , , INOUT, PS_DDR_DQ6_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ7, , , INOUT, PS_DDR_DQ7_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ8, , , INOUT, PS_DDR_DQ8_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ9, , , INOUT, PS_DDR_DQ9_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ10, , , INOUT, PS_DDR_DQ10_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ11, , , INOUT, PS_DDR_DQ11_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ12, , , INOUT, PS_DDR_DQ12_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ13, , , INOUT, PS_DDR_DQ13_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ14, , , INOUT, PS_DDR_DQ14_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ15, , , INOUT, PS_DDR_DQ15_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ16, , , INOUT, PS_DDR_DQ16_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ17, , , INOUT, PS_DDR_DQ17_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ18, , , INOUT, PS_DDR_DQ18_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ19, , , INOUT, PS_DDR_DQ19_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ20, , , INOUT, PS_DDR_DQ20_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ21, , , INOUT, PS_DDR_DQ21_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ22, , , INOUT, PS_DDR_DQ22_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ23, , , INOUT, PS_DDR_DQ23_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ24, , , INOUT, PS_DDR_DQ24_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ25, , , INOUT, PS_DDR_DQ25_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ26, , , INOUT, PS_DDR_DQ26_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ27, , , INOUT, PS_DDR_DQ27_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ28, , , INOUT, PS_DDR_DQ28_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ29, , , INOUT, PS_DDR_DQ29_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ30, , , INOUT, PS_DDR_DQ30_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ31, , , INOUT, PS_DDR_DQ31_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ32, , , INOUT, PS_DDR_DQ32_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ33, , , INOUT, PS_DDR_DQ33_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ34, , , INOUT, PS_DDR_DQ34_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ35, , , INOUT, PS_DDR_DQ35_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ36, , , INOUT, PS_DDR_DQ36_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ37, , , INOUT, PS_DDR_DQ37_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ38, , , INOUT, PS_DDR_DQ38_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ39, , , INOUT, PS_DDR_DQ39_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ40, , , INOUT, PS_DDR_DQ40_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ41, , , INOUT, PS_DDR_DQ41_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ42, , , INOUT, PS_DDR_DQ42_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ43, , , INOUT, PS_DDR_DQ43_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ44, , , INOUT, PS_DDR_DQ44_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ45, , , INOUT, PS_DDR_DQ45_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ46, , , INOUT, PS_DDR_DQ46_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ47, , , INOUT, PS_DDR_DQ47_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ48, , , INOUT, PS_DDR_DQ48_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ49, , , INOUT, PS_DDR_DQ49_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ50, , , INOUT, PS_DDR_DQ50_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ51, , , INOUT, PS_DDR_DQ51_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ52, , , INOUT, PS_DDR_DQ52_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ53, , , INOUT, PS_DDR_DQ53_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ54, , , INOUT, PS_DDR_DQ54_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ55, , , INOUT, PS_DDR_DQ55_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ56, , , INOUT, PS_DDR_DQ56_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ57, , , INOUT, PS_DDR_DQ57_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ58, , , INOUT, PS_DDR_DQ58_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ59, , , INOUT, PS_DDR_DQ59_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ60, , , INOUT, PS_DDR_DQ60_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ61, , , INOUT, PS_DDR_DQ61_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ62, , , INOUT, PS_DDR_DQ62_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ63, , , INOUT, PS_DDR_DQ63_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" *) 
(* PSS_JITTER = "<PSS_EXTERNAL_CLOCKS><EXTERNAL_CLOCK name={PLCLK[0]} clock_external_divide={20} vco_name={IOPLL} vco_freq={3000.000} vco_internal_divide={2}/></PSS_EXTERNAL_CLOCKS>" *) (* PSS_POWER = "<BLOCKTYPE name={PS8}> <PS8><FPD><PROCESSSORS><PROCESSOR name={Cortex A-53} numCores={4} L2Cache={Enable} clockFreq={1200.000000} load={0.5}/><PROCESSOR name={GPU Mali-400 MP} numCores={2} clockFreq={500.000000} load={0.5} /></PROCESSSORS><PLLS><PLL domain={APU} vco={2399.976} /><PLL domain={DDR} vco={2099.979} /><PLL domain={Video} vco={2999.970} /></PLLS><MEMORY memType={DDR4} dataWidth={8} clockFreq={1050.000} readRate={0.5} writeRate={0.5} cmdAddressActivity={0.5} /><SERDES><GT name={PCIe} standard={Gen2} lanes={1} usageRate={0.5} /><GT name={SATA} standard={SATA3} lanes={1} usageRate={0.5} /><GT name={Display Port} standard={SVGA-60 (800x600)} lanes={1} usageRate={0.5} />clockFreq={60} /><GT name={USB3} standard={USB3.0} lanes={1}usageRate={0.5} /><GT name={SGMII} standard={SGMII} lanes={0} usageRate={0.5} /></SERDES><AFI master={2} slave={1} clockFreq={75.000} usageRate={0.5} /><FPINTERCONNECT clockFreq={667} Bandwidth={Low} /></FPD><LPD><PROCESSSORS><PROCESSOR name={Cortex R-5} usage={Enable} TCM={Enable} OCM={Enable} clockFreq={500.000000} load={0.5}/></PROCESSSORS><PLLS><PLL domain={IO} vco={2999.970} /><PLL domain={RPLL} vco={1499.985} /></PLLS><CSUPMU><Unit name={CSU} usageRate={0.5} clockFreq={180} /><Unit name={PMU} usageRate={0.5} clockFreq={180} /></CSUPMU><GPIO><Bank ioBank={VCC_PSIO0} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO1} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO2} number={0} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO3} number={16} io_standard={LVCMOS 1.8V} /></GPIO><IOINTERFACES> <IO name={QSPI} io_standard={} ioBank={VCC_PSIO0} clockFreq={125.000000} inputs={0} outputs={5} inouts={8} usageRate={0.5}/><IO name={NAND 3.1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={USB0} io_standard={} ioBank={VCC_PSIO2} clockFreq={250.000000} inputs={3} outputs={1} inouts={8} usageRate={0.5}/><IO name={USB1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth3} io_standard={} ioBank={VCC_PSIO2} clockFreq={125.000000} inputs={6} outputs={6} inouts={0} usageRate={0.5}/><IO name={GPIO 0} io_standard={} ioBank={VCC_PSIO0} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 1} io_standard={} ioBank={VCC_PSIO1} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GPIO 3} io_standard={} ioBank={VCC_PSIO3} clockFreq={1} inputs={} outputs={} inouts={16} usageRate={0.5}/><IO name={UART0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={UART1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={I2C0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={I2C1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={SPI0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SPI1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={SD0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SD1} io_standard={} ioBank={VCC_PSIO1} clockFreq={187.500000} inputs={2} outputs={1} inouts={9} usageRate={0.5}/><IO name={Trace} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={TTC0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC2} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC3} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={PJTAG} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={DPAUX} io_standard={} ioBank={VCC_PSIO1} clockFreq={} inputs={2} outputs={2} inouts={0} usageRate={0.5}/><IO name={WDT0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={WDT1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/></IOINTERFACES><AFI master={0} slave={0} clockFreq={333.333} usageRate={0.5} /><LPINTERCONNECT clockFreq={667} Bandwidth={High} /></LPD></PS8></BLOCKTYPE>/>" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e
   (maxihpm0_fpd_aclk,
    dp_video_ref_clk,
    dp_audio_ref_clk,
    maxigp0_awid,
    maxigp0_awaddr,
    maxigp0_awlen,
    maxigp0_awsize,
    maxigp0_awburst,
    maxigp0_awlock,
    maxigp0_awcache,
    maxigp0_awprot,
    maxigp0_awvalid,
    maxigp0_awuser,
    maxigp0_awready,
    maxigp0_wdata,
    maxigp0_wstrb,
    maxigp0_wlast,
    maxigp0_wvalid,
    maxigp0_wready,
    maxigp0_bid,
    maxigp0_bresp,
    maxigp0_bvalid,
    maxigp0_bready,
    maxigp0_arid,
    maxigp0_araddr,
    maxigp0_arlen,
    maxigp0_arsize,
    maxigp0_arburst,
    maxigp0_arlock,
    maxigp0_arcache,
    maxigp0_arprot,
    maxigp0_arvalid,
    maxigp0_aruser,
    maxigp0_arready,
    maxigp0_rid,
    maxigp0_rdata,
    maxigp0_rresp,
    maxigp0_rlast,
    maxigp0_rvalid,
    maxigp0_rready,
    maxigp0_awqos,
    maxigp0_arqos,
    maxihpm1_fpd_aclk,
    maxigp1_awid,
    maxigp1_awaddr,
    maxigp1_awlen,
    maxigp1_awsize,
    maxigp1_awburst,
    maxigp1_awlock,
    maxigp1_awcache,
    maxigp1_awprot,
    maxigp1_awvalid,
    maxigp1_awuser,
    maxigp1_awready,
    maxigp1_wdata,
    maxigp1_wstrb,
    maxigp1_wlast,
    maxigp1_wvalid,
    maxigp1_wready,
    maxigp1_bid,
    maxigp1_bresp,
    maxigp1_bvalid,
    maxigp1_bready,
    maxigp1_arid,
    maxigp1_araddr,
    maxigp1_arlen,
    maxigp1_arsize,
    maxigp1_arburst,
    maxigp1_arlock,
    maxigp1_arcache,
    maxigp1_arprot,
    maxigp1_arvalid,
    maxigp1_aruser,
    maxigp1_arready,
    maxigp1_rid,
    maxigp1_rdata,
    maxigp1_rresp,
    maxigp1_rlast,
    maxigp1_rvalid,
    maxigp1_rready,
    maxigp1_awqos,
    maxigp1_arqos,
    maxihpm0_lpd_aclk,
    maxigp2_awid,
    maxigp2_awaddr,
    maxigp2_awlen,
    maxigp2_awsize,
    maxigp2_awburst,
    maxigp2_awlock,
    maxigp2_awcache,
    maxigp2_awprot,
    maxigp2_awvalid,
    maxigp2_awuser,
    maxigp2_awready,
    maxigp2_wdata,
    maxigp2_wstrb,
    maxigp2_wlast,
    maxigp2_wvalid,
    maxigp2_wready,
    maxigp2_bid,
    maxigp2_bresp,
    maxigp2_bvalid,
    maxigp2_bready,
    maxigp2_arid,
    maxigp2_araddr,
    maxigp2_arlen,
    maxigp2_arsize,
    maxigp2_arburst,
    maxigp2_arlock,
    maxigp2_arcache,
    maxigp2_arprot,
    maxigp2_arvalid,
    maxigp2_aruser,
    maxigp2_arready,
    maxigp2_rid,
    maxigp2_rdata,
    maxigp2_rresp,
    maxigp2_rlast,
    maxigp2_rvalid,
    maxigp2_rready,
    maxigp2_awqos,
    maxigp2_arqos,
    saxihpc0_fpd_aclk,
    saxihpc0_fpd_rclk,
    saxihpc0_fpd_wclk,
    saxigp0_aruser,
    saxigp0_awuser,
    saxigp0_awid,
    saxigp0_awaddr,
    saxigp0_awlen,
    saxigp0_awsize,
    saxigp0_awburst,
    saxigp0_awlock,
    saxigp0_awcache,
    saxigp0_awprot,
    saxigp0_awvalid,
    saxigp0_awready,
    saxigp0_wdata,
    saxigp0_wstrb,
    saxigp0_wlast,
    saxigp0_wvalid,
    saxigp0_wready,
    saxigp0_bid,
    saxigp0_bresp,
    saxigp0_bvalid,
    saxigp0_bready,
    saxigp0_arid,
    saxigp0_araddr,
    saxigp0_arlen,
    saxigp0_arsize,
    saxigp0_arburst,
    saxigp0_arlock,
    saxigp0_arcache,
    saxigp0_arprot,
    saxigp0_arvalid,
    saxigp0_arready,
    saxigp0_rid,
    saxigp0_rdata,
    saxigp0_rresp,
    saxigp0_rlast,
    saxigp0_rvalid,
    saxigp0_rready,
    saxigp0_awqos,
    saxigp0_arqos,
    saxigp0_rcount,
    saxigp0_wcount,
    saxigp0_racount,
    saxigp0_wacount,
    saxihpc1_fpd_aclk,
    saxihpc1_fpd_rclk,
    saxihpc1_fpd_wclk,
    saxigp1_aruser,
    saxigp1_awuser,
    saxigp1_awid,
    saxigp1_awaddr,
    saxigp1_awlen,
    saxigp1_awsize,
    saxigp1_awburst,
    saxigp1_awlock,
    saxigp1_awcache,
    saxigp1_awprot,
    saxigp1_awvalid,
    saxigp1_awready,
    saxigp1_wdata,
    saxigp1_wstrb,
    saxigp1_wlast,
    saxigp1_wvalid,
    saxigp1_wready,
    saxigp1_bid,
    saxigp1_bresp,
    saxigp1_bvalid,
    saxigp1_bready,
    saxigp1_arid,
    saxigp1_araddr,
    saxigp1_arlen,
    saxigp1_arsize,
    saxigp1_arburst,
    saxigp1_arlock,
    saxigp1_arcache,
    saxigp1_arprot,
    saxigp1_arvalid,
    saxigp1_arready,
    saxigp1_rid,
    saxigp1_rdata,
    saxigp1_rresp,
    saxigp1_rlast,
    saxigp1_rvalid,
    saxigp1_rready,
    saxigp1_awqos,
    saxigp1_arqos,
    saxigp1_rcount,
    saxigp1_wcount,
    saxigp1_racount,
    saxigp1_wacount,
    saxihp0_fpd_aclk,
    saxihp0_fpd_rclk,
    saxihp0_fpd_wclk,
    saxigp2_aruser,
    saxigp2_awuser,
    saxigp2_awid,
    saxigp2_awaddr,
    saxigp2_awlen,
    saxigp2_awsize,
    saxigp2_awburst,
    saxigp2_awlock,
    saxigp2_awcache,
    saxigp2_awprot,
    saxigp2_awvalid,
    saxigp2_awready,
    saxigp2_wdata,
    saxigp2_wstrb,
    saxigp2_wlast,
    saxigp2_wvalid,
    saxigp2_wready,
    saxigp2_bid,
    saxigp2_bresp,
    saxigp2_bvalid,
    saxigp2_bready,
    saxigp2_arid,
    saxigp2_araddr,
    saxigp2_arlen,
    saxigp2_arsize,
    saxigp2_arburst,
    saxigp2_arlock,
    saxigp2_arcache,
    saxigp2_arprot,
    saxigp2_arvalid,
    saxigp2_arready,
    saxigp2_rid,
    saxigp2_rdata,
    saxigp2_rresp,
    saxigp2_rlast,
    saxigp2_rvalid,
    saxigp2_rready,
    saxigp2_awqos,
    saxigp2_arqos,
    saxigp2_rcount,
    saxigp2_wcount,
    saxigp2_racount,
    saxigp2_wacount,
    saxihp1_fpd_aclk,
    saxihp1_fpd_rclk,
    saxihp1_fpd_wclk,
    saxigp3_aruser,
    saxigp3_awuser,
    saxigp3_awid,
    saxigp3_awaddr,
    saxigp3_awlen,
    saxigp3_awsize,
    saxigp3_awburst,
    saxigp3_awlock,
    saxigp3_awcache,
    saxigp3_awprot,
    saxigp3_awvalid,
    saxigp3_awready,
    saxigp3_wdata,
    saxigp3_wstrb,
    saxigp3_wlast,
    saxigp3_wvalid,
    saxigp3_wready,
    saxigp3_bid,
    saxigp3_bresp,
    saxigp3_bvalid,
    saxigp3_bready,
    saxigp3_arid,
    saxigp3_araddr,
    saxigp3_arlen,
    saxigp3_arsize,
    saxigp3_arburst,
    saxigp3_arlock,
    saxigp3_arcache,
    saxigp3_arprot,
    saxigp3_arvalid,
    saxigp3_arready,
    saxigp3_rid,
    saxigp3_rdata,
    saxigp3_rresp,
    saxigp3_rlast,
    saxigp3_rvalid,
    saxigp3_rready,
    saxigp3_awqos,
    saxigp3_arqos,
    saxigp3_rcount,
    saxigp3_wcount,
    saxigp3_racount,
    saxigp3_wacount,
    saxihp2_fpd_aclk,
    saxihp2_fpd_rclk,
    saxihp2_fpd_wclk,
    saxigp4_aruser,
    saxigp4_awuser,
    saxigp4_awid,
    saxigp4_awaddr,
    saxigp4_awlen,
    saxigp4_awsize,
    saxigp4_awburst,
    saxigp4_awlock,
    saxigp4_awcache,
    saxigp4_awprot,
    saxigp4_awvalid,
    saxigp4_awready,
    saxigp4_wdata,
    saxigp4_wstrb,
    saxigp4_wlast,
    saxigp4_wvalid,
    saxigp4_wready,
    saxigp4_bid,
    saxigp4_bresp,
    saxigp4_bvalid,
    saxigp4_bready,
    saxigp4_arid,
    saxigp4_araddr,
    saxigp4_arlen,
    saxigp4_arsize,
    saxigp4_arburst,
    saxigp4_arlock,
    saxigp4_arcache,
    saxigp4_arprot,
    saxigp4_arvalid,
    saxigp4_arready,
    saxigp4_rid,
    saxigp4_rdata,
    saxigp4_rresp,
    saxigp4_rlast,
    saxigp4_rvalid,
    saxigp4_rready,
    saxigp4_awqos,
    saxigp4_arqos,
    saxigp4_rcount,
    saxigp4_wcount,
    saxigp4_racount,
    saxigp4_wacount,
    saxihp3_fpd_aclk,
    saxihp3_fpd_rclk,
    saxihp3_fpd_wclk,
    saxigp5_aruser,
    saxigp5_awuser,
    saxigp5_awid,
    saxigp5_awaddr,
    saxigp5_awlen,
    saxigp5_awsize,
    saxigp5_awburst,
    saxigp5_awlock,
    saxigp5_awcache,
    saxigp5_awprot,
    saxigp5_awvalid,
    saxigp5_awready,
    saxigp5_wdata,
    saxigp5_wstrb,
    saxigp5_wlast,
    saxigp5_wvalid,
    saxigp5_wready,
    saxigp5_bid,
    saxigp5_bresp,
    saxigp5_bvalid,
    saxigp5_bready,
    saxigp5_arid,
    saxigp5_araddr,
    saxigp5_arlen,
    saxigp5_arsize,
    saxigp5_arburst,
    saxigp5_arlock,
    saxigp5_arcache,
    saxigp5_arprot,
    saxigp5_arvalid,
    saxigp5_arready,
    saxigp5_rid,
    saxigp5_rdata,
    saxigp5_rresp,
    saxigp5_rlast,
    saxigp5_rvalid,
    saxigp5_rready,
    saxigp5_awqos,
    saxigp5_arqos,
    saxigp5_rcount,
    saxigp5_wcount,
    saxigp5_racount,
    saxigp5_wacount,
    saxi_lpd_aclk,
    saxi_lpd_rclk,
    saxi_lpd_wclk,
    saxigp6_aruser,
    saxigp6_awuser,
    saxigp6_awid,
    saxigp6_awaddr,
    saxigp6_awlen,
    saxigp6_awsize,
    saxigp6_awburst,
    saxigp6_awlock,
    saxigp6_awcache,
    saxigp6_awprot,
    saxigp6_awvalid,
    saxigp6_awready,
    saxigp6_wdata,
    saxigp6_wstrb,
    saxigp6_wlast,
    saxigp6_wvalid,
    saxigp6_wready,
    saxigp6_bid,
    saxigp6_bresp,
    saxigp6_bvalid,
    saxigp6_bready,
    saxigp6_arid,
    saxigp6_araddr,
    saxigp6_arlen,
    saxigp6_arsize,
    saxigp6_arburst,
    saxigp6_arlock,
    saxigp6_arcache,
    saxigp6_arprot,
    saxigp6_arvalid,
    saxigp6_arready,
    saxigp6_rid,
    saxigp6_rdata,
    saxigp6_rresp,
    saxigp6_rlast,
    saxigp6_rvalid,
    saxigp6_rready,
    saxigp6_awqos,
    saxigp6_arqos,
    saxigp6_rcount,
    saxigp6_wcount,
    saxigp6_racount,
    saxigp6_wacount,
    saxiacp_fpd_aclk,
    saxiacp_awaddr,
    saxiacp_awid,
    saxiacp_awlen,
    saxiacp_awsize,
    saxiacp_awburst,
    saxiacp_awlock,
    saxiacp_awcache,
    saxiacp_awprot,
    saxiacp_awvalid,
    saxiacp_awready,
    saxiacp_awuser,
    saxiacp_awqos,
    saxiacp_wlast,
    saxiacp_wdata,
    saxiacp_wstrb,
    saxiacp_wvalid,
    saxiacp_wready,
    saxiacp_bresp,
    saxiacp_bid,
    saxiacp_bvalid,
    saxiacp_bready,
    saxiacp_araddr,
    saxiacp_arid,
    saxiacp_arlen,
    saxiacp_arsize,
    saxiacp_arburst,
    saxiacp_arlock,
    saxiacp_arcache,
    saxiacp_arprot,
    saxiacp_arvalid,
    saxiacp_arready,
    saxiacp_aruser,
    saxiacp_arqos,
    saxiacp_rid,
    saxiacp_rlast,
    saxiacp_rdata,
    saxiacp_rresp,
    saxiacp_rvalid,
    saxiacp_rready,
    sacefpd_aclk,
    sacefpd_awvalid,
    sacefpd_awready,
    sacefpd_awid,
    sacefpd_awaddr,
    sacefpd_awregion,
    sacefpd_awlen,
    sacefpd_awsize,
    sacefpd_awburst,
    sacefpd_awlock,
    sacefpd_awcache,
    sacefpd_awprot,
    sacefpd_awdomain,
    sacefpd_awsnoop,
    sacefpd_awbar,
    sacefpd_awqos,
    sacefpd_wvalid,
    sacefpd_wready,
    sacefpd_wdata,
    sacefpd_wstrb,
    sacefpd_wlast,
    sacefpd_wuser,
    sacefpd_bvalid,
    sacefpd_bready,
    sacefpd_bid,
    sacefpd_bresp,
    sacefpd_buser,
    sacefpd_arvalid,
    sacefpd_arready,
    sacefpd_arid,
    sacefpd_araddr,
    sacefpd_arregion,
    sacefpd_arlen,
    sacefpd_arsize,
    sacefpd_arburst,
    sacefpd_arlock,
    sacefpd_arcache,
    sacefpd_arprot,
    sacefpd_ardomain,
    sacefpd_arsnoop,
    sacefpd_arbar,
    sacefpd_arqos,
    sacefpd_rvalid,
    sacefpd_rready,
    sacefpd_rid,
    sacefpd_rdata,
    sacefpd_rresp,
    sacefpd_rlast,
    sacefpd_ruser,
    sacefpd_acvalid,
    sacefpd_acready,
    sacefpd_acaddr,
    sacefpd_acsnoop,
    sacefpd_acprot,
    sacefpd_crvalid,
    sacefpd_crready,
    sacefpd_crresp,
    sacefpd_cdvalid,
    sacefpd_cdready,
    sacefpd_cddata,
    sacefpd_cdlast,
    sacefpd_wack,
    sacefpd_rack,
    emio_can0_phy_tx,
    emio_can0_phy_rx,
    emio_can1_phy_tx,
    emio_can1_phy_rx,
    emio_enet0_gmii_rx_clk,
    emio_enet0_speed_mode,
    emio_enet0_gmii_crs,
    emio_enet0_gmii_col,
    emio_enet0_gmii_rxd,
    emio_enet0_gmii_rx_er,
    emio_enet0_gmii_rx_dv,
    emio_enet0_gmii_tx_clk,
    emio_enet0_gmii_txd,
    emio_enet0_gmii_tx_en,
    emio_enet0_gmii_tx_er,
    emio_enet0_mdio_mdc,
    emio_enet0_mdio_i,
    emio_enet0_mdio_o,
    emio_enet0_mdio_t,
    emio_enet0_mdio_t_n,
    emio_enet1_gmii_rx_clk,
    emio_enet1_speed_mode,
    emio_enet1_gmii_crs,
    emio_enet1_gmii_col,
    emio_enet1_gmii_rxd,
    emio_enet1_gmii_rx_er,
    emio_enet1_gmii_rx_dv,
    emio_enet1_gmii_tx_clk,
    emio_enet1_gmii_txd,
    emio_enet1_gmii_tx_en,
    emio_enet1_gmii_tx_er,
    emio_enet1_mdio_mdc,
    emio_enet1_mdio_i,
    emio_enet1_mdio_o,
    emio_enet1_mdio_t,
    emio_enet1_mdio_t_n,
    emio_enet2_gmii_rx_clk,
    emio_enet2_speed_mode,
    emio_enet2_gmii_crs,
    emio_enet2_gmii_col,
    emio_enet2_gmii_rxd,
    emio_enet2_gmii_rx_er,
    emio_enet2_gmii_rx_dv,
    emio_enet2_gmii_tx_clk,
    emio_enet2_gmii_txd,
    emio_enet2_gmii_tx_en,
    emio_enet2_gmii_tx_er,
    emio_enet2_mdio_mdc,
    emio_enet2_mdio_i,
    emio_enet2_mdio_o,
    emio_enet2_mdio_t,
    emio_enet2_mdio_t_n,
    emio_enet3_gmii_rx_clk,
    emio_enet3_speed_mode,
    emio_enet3_gmii_crs,
    emio_enet3_gmii_col,
    emio_enet3_gmii_rxd,
    emio_enet3_gmii_rx_er,
    emio_enet3_gmii_rx_dv,
    emio_enet3_gmii_tx_clk,
    emio_enet3_gmii_txd,
    emio_enet3_gmii_tx_en,
    emio_enet3_gmii_tx_er,
    emio_enet3_mdio_mdc,
    emio_enet3_mdio_i,
    emio_enet3_mdio_o,
    emio_enet3_mdio_t,
    emio_enet3_mdio_t_n,
    emio_enet0_tx_r_data_rdy,
    emio_enet0_tx_r_rd,
    emio_enet0_tx_r_valid,
    emio_enet0_tx_r_data,
    emio_enet0_tx_r_sop,
    emio_enet0_tx_r_eop,
    emio_enet0_tx_r_err,
    emio_enet0_tx_r_underflow,
    emio_enet0_tx_r_flushed,
    emio_enet0_tx_r_control,
    emio_enet0_dma_tx_end_tog,
    emio_enet0_dma_tx_status_tog,
    emio_enet0_tx_r_status,
    emio_enet0_rx_w_wr,
    emio_enet0_rx_w_data,
    emio_enet0_rx_w_sop,
    emio_enet0_rx_w_eop,
    emio_enet0_rx_w_status,
    emio_enet0_rx_w_err,
    emio_enet0_rx_w_overflow,
    emio_enet0_signal_detect,
    emio_enet0_rx_w_flush,
    emio_enet0_tx_r_fixed_lat,
    emio_enet1_tx_r_data_rdy,
    emio_enet1_tx_r_rd,
    emio_enet1_tx_r_valid,
    emio_enet1_tx_r_data,
    emio_enet1_tx_r_sop,
    emio_enet1_tx_r_eop,
    emio_enet1_tx_r_err,
    emio_enet1_tx_r_underflow,
    emio_enet1_tx_r_flushed,
    emio_enet1_tx_r_control,
    emio_enet1_dma_tx_end_tog,
    emio_enet1_dma_tx_status_tog,
    emio_enet1_tx_r_status,
    emio_enet1_rx_w_wr,
    emio_enet1_rx_w_data,
    emio_enet1_rx_w_sop,
    emio_enet1_rx_w_eop,
    emio_enet1_rx_w_status,
    emio_enet1_rx_w_err,
    emio_enet1_rx_w_overflow,
    emio_enet1_signal_detect,
    emio_enet1_rx_w_flush,
    emio_enet1_tx_r_fixed_lat,
    emio_enet2_tx_r_data_rdy,
    emio_enet2_tx_r_rd,
    emio_enet2_tx_r_valid,
    emio_enet2_tx_r_data,
    emio_enet2_tx_r_sop,
    emio_enet2_tx_r_eop,
    emio_enet2_tx_r_err,
    emio_enet2_tx_r_underflow,
    emio_enet2_tx_r_flushed,
    emio_enet2_tx_r_control,
    emio_enet2_dma_tx_end_tog,
    emio_enet2_dma_tx_status_tog,
    emio_enet2_tx_r_status,
    emio_enet2_rx_w_wr,
    emio_enet2_rx_w_data,
    emio_enet2_rx_w_sop,
    emio_enet2_rx_w_eop,
    emio_enet2_rx_w_status,
    emio_enet2_rx_w_err,
    emio_enet2_rx_w_overflow,
    emio_enet2_signal_detect,
    emio_enet2_rx_w_flush,
    emio_enet2_tx_r_fixed_lat,
    emio_enet3_tx_r_data_rdy,
    emio_enet3_tx_r_rd,
    emio_enet3_tx_r_valid,
    emio_enet3_tx_r_data,
    emio_enet3_tx_r_sop,
    emio_enet3_tx_r_eop,
    emio_enet3_tx_r_err,
    emio_enet3_tx_r_underflow,
    emio_enet3_tx_r_flushed,
    emio_enet3_tx_r_control,
    emio_enet3_dma_tx_end_tog,
    emio_enet3_dma_tx_status_tog,
    emio_enet3_tx_r_status,
    emio_enet3_rx_w_wr,
    emio_enet3_rx_w_data,
    emio_enet3_rx_w_sop,
    emio_enet3_rx_w_eop,
    emio_enet3_rx_w_status,
    emio_enet3_rx_w_err,
    emio_enet3_rx_w_overflow,
    emio_enet3_signal_detect,
    emio_enet3_rx_w_flush,
    emio_enet3_tx_r_fixed_lat,
    fmio_gem0_fifo_tx_clk_to_pl_bufg,
    fmio_gem0_fifo_rx_clk_to_pl_bufg,
    fmio_gem1_fifo_tx_clk_to_pl_bufg,
    fmio_gem1_fifo_rx_clk_to_pl_bufg,
    fmio_gem2_fifo_tx_clk_to_pl_bufg,
    fmio_gem2_fifo_rx_clk_to_pl_bufg,
    fmio_gem3_fifo_tx_clk_to_pl_bufg,
    fmio_gem3_fifo_rx_clk_to_pl_bufg,
    emio_enet0_tx_sof,
    emio_enet0_sync_frame_tx,
    emio_enet0_delay_req_tx,
    emio_enet0_pdelay_req_tx,
    emio_enet0_pdelay_resp_tx,
    emio_enet0_rx_sof,
    emio_enet0_sync_frame_rx,
    emio_enet0_delay_req_rx,
    emio_enet0_pdelay_req_rx,
    emio_enet0_pdelay_resp_rx,
    emio_enet0_tsu_inc_ctrl,
    emio_enet0_tsu_timer_cmp_val,
    emio_enet1_tx_sof,
    emio_enet1_sync_frame_tx,
    emio_enet1_delay_req_tx,
    emio_enet1_pdelay_req_tx,
    emio_enet1_pdelay_resp_tx,
    emio_enet1_rx_sof,
    emio_enet1_sync_frame_rx,
    emio_enet1_delay_req_rx,
    emio_enet1_pdelay_req_rx,
    emio_enet1_pdelay_resp_rx,
    emio_enet1_tsu_inc_ctrl,
    emio_enet1_tsu_timer_cmp_val,
    emio_enet2_tx_sof,
    emio_enet2_sync_frame_tx,
    emio_enet2_delay_req_tx,
    emio_enet2_pdelay_req_tx,
    emio_enet2_pdelay_resp_tx,
    emio_enet2_rx_sof,
    emio_enet2_sync_frame_rx,
    emio_enet2_delay_req_rx,
    emio_enet2_pdelay_req_rx,
    emio_enet2_pdelay_resp_rx,
    emio_enet2_tsu_inc_ctrl,
    emio_enet2_tsu_timer_cmp_val,
    emio_enet3_tx_sof,
    emio_enet3_sync_frame_tx,
    emio_enet3_delay_req_tx,
    emio_enet3_pdelay_req_tx,
    emio_enet3_pdelay_resp_tx,
    emio_enet3_rx_sof,
    emio_enet3_sync_frame_rx,
    emio_enet3_delay_req_rx,
    emio_enet3_pdelay_req_rx,
    emio_enet3_pdelay_resp_rx,
    emio_enet3_tsu_inc_ctrl,
    emio_enet3_tsu_timer_cmp_val,
    fmio_gem_tsu_clk_from_pl,
    fmio_gem_tsu_clk_to_pl_bufg,
    emio_enet_tsu_clk,
    emio_enet0_enet_tsu_timer_cnt,
    emio_enet0_ext_int_in,
    emio_enet1_ext_int_in,
    emio_enet2_ext_int_in,
    emio_enet3_ext_int_in,
    emio_enet0_dma_bus_width,
    emio_enet1_dma_bus_width,
    emio_enet2_dma_bus_width,
    emio_enet3_dma_bus_width,
    emio_gpio_i,
    emio_gpio_o,
    emio_gpio_t,
    emio_gpio_t_n,
    emio_i2c0_scl_i,
    emio_i2c0_scl_o,
    emio_i2c0_scl_t_n,
    emio_i2c0_scl_t,
    emio_i2c0_sda_i,
    emio_i2c0_sda_o,
    emio_i2c0_sda_t_n,
    emio_i2c0_sda_t,
    emio_i2c1_scl_i,
    emio_i2c1_scl_o,
    emio_i2c1_scl_t,
    emio_i2c1_scl_t_n,
    emio_i2c1_sda_i,
    emio_i2c1_sda_o,
    emio_i2c1_sda_t,
    emio_i2c1_sda_t_n,
    emio_uart0_txd,
    emio_uart0_rxd,
    emio_uart0_ctsn,
    emio_uart0_rtsn,
    emio_uart0_dsrn,
    emio_uart0_dcdn,
    emio_uart0_rin,
    emio_uart0_dtrn,
    emio_uart1_txd,
    emio_uart1_rxd,
    emio_uart1_ctsn,
    emio_uart1_rtsn,
    emio_uart1_dsrn,
    emio_uart1_dcdn,
    emio_uart1_rin,
    emio_uart1_dtrn,
    emio_sdio0_clkout,
    emio_sdio0_fb_clk_in,
    emio_sdio0_cmdout,
    emio_sdio0_cmdin,
    emio_sdio0_cmdena,
    emio_sdio0_datain,
    emio_sdio0_dataout,
    emio_sdio0_dataena,
    emio_sdio0_cd_n,
    emio_sdio0_wp,
    emio_sdio0_ledcontrol,
    emio_sdio0_buspower,
    emio_sdio0_bus_volt,
    emio_sdio1_clkout,
    emio_sdio1_fb_clk_in,
    emio_sdio1_cmdout,
    emio_sdio1_cmdin,
    emio_sdio1_cmdena,
    emio_sdio1_datain,
    emio_sdio1_dataout,
    emio_sdio1_dataena,
    emio_sdio1_cd_n,
    emio_sdio1_wp,
    emio_sdio1_ledcontrol,
    emio_sdio1_buspower,
    emio_sdio1_bus_volt,
    emio_spi0_sclk_i,
    emio_spi0_sclk_o,
    emio_spi0_sclk_t,
    emio_spi0_sclk_t_n,
    emio_spi0_m_i,
    emio_spi0_m_o,
    emio_spi0_mo_t,
    emio_spi0_mo_t_n,
    emio_spi0_s_i,
    emio_spi0_s_o,
    emio_spi0_so_t,
    emio_spi0_so_t_n,
    emio_spi0_ss_i_n,
    emio_spi0_ss_o_n,
    emio_spi0_ss1_o_n,
    emio_spi0_ss2_o_n,
    emio_spi0_ss_n_t,
    emio_spi0_ss_n_t_n,
    emio_spi1_sclk_i,
    emio_spi1_sclk_o,
    emio_spi1_sclk_t,
    emio_spi1_sclk_t_n,
    emio_spi1_m_i,
    emio_spi1_m_o,
    emio_spi1_mo_t,
    emio_spi1_mo_t_n,
    emio_spi1_s_i,
    emio_spi1_s_o,
    emio_spi1_so_t,
    emio_spi1_so_t_n,
    emio_spi1_ss_i_n,
    emio_spi1_ss_o_n,
    emio_spi1_ss1_o_n,
    emio_spi1_ss2_o_n,
    emio_spi1_ss_n_t,
    emio_spi1_ss_n_t_n,
    pl_ps_trace_clk,
    ps_pl_tracectl,
    ps_pl_tracedata,
    trace_clk_out,
    emio_ttc0_wave_o,
    emio_ttc0_clk_i,
    emio_ttc1_wave_o,
    emio_ttc1_clk_i,
    emio_ttc2_wave_o,
    emio_ttc2_clk_i,
    emio_ttc3_wave_o,
    emio_ttc3_clk_i,
    emio_wdt0_clk_i,
    emio_wdt0_rst_o,
    emio_wdt1_clk_i,
    emio_wdt1_rst_o,
    emio_hub_port_overcrnt_usb3_0,
    emio_hub_port_overcrnt_usb3_1,
    emio_hub_port_overcrnt_usb2_0,
    emio_hub_port_overcrnt_usb2_1,
    emio_u2dsport_vbus_ctrl_usb3_0,
    emio_u2dsport_vbus_ctrl_usb3_1,
    emio_u3dsport_vbus_ctrl_usb3_0,
    emio_u3dsport_vbus_ctrl_usb3_1,
    adma_fci_clk,
    pl2adma_cvld,
    pl2adma_tack,
    adma2pl_cack,
    adma2pl_tvld,
    perif_gdma_clk,
    perif_gdma_cvld,
    perif_gdma_tack,
    gdma_perif_cack,
    gdma_perif_tvld,
    pl_clock_stop,
    pll_aux_refclk_lpd,
    pll_aux_refclk_fpd,
    dp_s_axis_audio_tdata,
    dp_s_axis_audio_tid,
    dp_s_axis_audio_tvalid,
    dp_s_axis_audio_tready,
    dp_m_axis_mixed_audio_tdata,
    dp_m_axis_mixed_audio_tid,
    dp_m_axis_mixed_audio_tvalid,
    dp_m_axis_mixed_audio_tready,
    dp_s_axis_audio_clk,
    dp_live_video_in_vsync,
    dp_live_video_in_hsync,
    dp_live_video_in_de,
    dp_live_video_in_pixel1,
    dp_video_in_clk,
    dp_video_out_hsync,
    dp_video_out_vsync,
    dp_video_out_pixel1,
    dp_aux_data_in,
    dp_aux_data_out,
    dp_aux_data_oe_n,
    dp_live_gfx_alpha_in,
    dp_live_gfx_pixel1_in,
    dp_hot_plug_detect,
    dp_external_custom_event1,
    dp_external_custom_event2,
    dp_external_vsync_event,
    dp_live_video_de_out,
    pl_ps_eventi,
    ps_pl_evento,
    ps_pl_standbywfe,
    ps_pl_standbywfi,
    pl_ps_apugic_irq,
    pl_ps_apugic_fiq,
    rpu_eventi0,
    rpu_eventi1,
    rpu_evento0,
    rpu_evento1,
    nfiq0_lpd_rpu,
    nfiq1_lpd_rpu,
    nirq0_lpd_rpu,
    nirq1_lpd_rpu,
    irq_ipi_pl_0,
    irq_ipi_pl_1,
    irq_ipi_pl_2,
    irq_ipi_pl_3,
    stm_event,
    pl_ps_trigack_0,
    pl_ps_trigack_1,
    pl_ps_trigack_2,
    pl_ps_trigack_3,
    pl_ps_trigger_0,
    pl_ps_trigger_1,
    pl_ps_trigger_2,
    pl_ps_trigger_3,
    ps_pl_trigack_0,
    ps_pl_trigack_1,
    ps_pl_trigack_2,
    ps_pl_trigack_3,
    ps_pl_trigger_0,
    ps_pl_trigger_1,
    ps_pl_trigger_2,
    ps_pl_trigger_3,
    ftm_gpo,
    ftm_gpi,
    pl_ps_irq0,
    pl_ps_irq1,
    pl_resetn0,
    pl_resetn1,
    pl_resetn2,
    pl_resetn3,
    ps_pl_irq_can0,
    ps_pl_irq_can1,
    ps_pl_irq_enet0,
    ps_pl_irq_enet1,
    ps_pl_irq_enet2,
    ps_pl_irq_enet3,
    ps_pl_irq_enet0_wake,
    ps_pl_irq_enet1_wake,
    ps_pl_irq_enet2_wake,
    ps_pl_irq_enet3_wake,
    ps_pl_irq_gpio,
    ps_pl_irq_i2c0,
    ps_pl_irq_i2c1,
    ps_pl_irq_uart0,
    ps_pl_irq_uart1,
    ps_pl_irq_sdio0,
    ps_pl_irq_sdio1,
    ps_pl_irq_sdio0_wake,
    ps_pl_irq_sdio1_wake,
    ps_pl_irq_spi0,
    ps_pl_irq_spi1,
    ps_pl_irq_qspi,
    ps_pl_irq_ttc0_0,
    ps_pl_irq_ttc0_1,
    ps_pl_irq_ttc0_2,
    ps_pl_irq_ttc1_0,
    ps_pl_irq_ttc1_1,
    ps_pl_irq_ttc1_2,
    ps_pl_irq_ttc2_0,
    ps_pl_irq_ttc2_1,
    ps_pl_irq_ttc2_2,
    ps_pl_irq_ttc3_0,
    ps_pl_irq_ttc3_1,
    ps_pl_irq_ttc3_2,
    ps_pl_irq_csu_pmu_wdt,
    ps_pl_irq_lp_wdt,
    ps_pl_irq_usb3_0_endpoint,
    ps_pl_irq_usb3_0_otg,
    ps_pl_irq_usb3_1_endpoint,
    ps_pl_irq_usb3_1_otg,
    ps_pl_irq_adma_chan,
    ps_pl_irq_usb3_0_pmu_wakeup,
    ps_pl_irq_gdma_chan,
    ps_pl_irq_csu,
    ps_pl_irq_csu_dma,
    ps_pl_irq_efuse,
    ps_pl_irq_xmpu_lpd,
    ps_pl_irq_ddr_ss,
    ps_pl_irq_nand,
    ps_pl_irq_fp_wdt,
    ps_pl_irq_pcie_msi,
    ps_pl_irq_pcie_legacy,
    ps_pl_irq_pcie_dma,
    ps_pl_irq_pcie_msc,
    ps_pl_irq_dport,
    ps_pl_irq_fpd_apb_int,
    ps_pl_irq_fpd_atb_error,
    ps_pl_irq_dpdma,
    ps_pl_irq_apm_fpd,
    ps_pl_irq_gpu,
    ps_pl_irq_sata,
    ps_pl_irq_xmpu_fpd,
    ps_pl_irq_apu_cpumnt,
    ps_pl_irq_apu_cti,
    ps_pl_irq_apu_pmu,
    ps_pl_irq_apu_comm,
    ps_pl_irq_apu_l2err,
    ps_pl_irq_apu_exterr,
    ps_pl_irq_apu_regs,
    ps_pl_irq_intf_ppd_cci,
    ps_pl_irq_intf_fpd_smmu,
    ps_pl_irq_atb_err_lpd,
    ps_pl_irq_aib_axi,
    ps_pl_irq_ams,
    ps_pl_irq_lpd_apm,
    ps_pl_irq_rtc_alaram,
    ps_pl_irq_rtc_seconds,
    ps_pl_irq_clkmon,
    ps_pl_irq_ipi_channel0,
    ps_pl_irq_ipi_channel1,
    ps_pl_irq_ipi_channel2,
    ps_pl_irq_ipi_channel7,
    ps_pl_irq_ipi_channel8,
    ps_pl_irq_ipi_channel9,
    ps_pl_irq_ipi_channel10,
    ps_pl_irq_rpu_pm,
    ps_pl_irq_ocm_error,
    ps_pl_irq_lpd_apb_intr,
    ps_pl_irq_r5_core0_ecc_error,
    ps_pl_irq_r5_core1_ecc_error,
    osc_rtc_clk,
    pl_pmu_gpi,
    pmu_pl_gpo,
    aib_pmu_afifm_fpd_ack,
    aib_pmu_afifm_lpd_ack,
    pmu_aib_afifm_fpd_req,
    pmu_aib_afifm_lpd_req,
    pmu_error_to_pl,
    pmu_error_from_pl,
    ddrc_ext_refresh_rank0_req,
    ddrc_ext_refresh_rank1_req,
    ddrc_refresh_pl_clk,
    pl_acpinact,
    pl_clk3,
    pl_clk2,
    pl_clk1,
    pl_clk0,
    sacefpd_awuser,
    sacefpd_aruser,
    test_adc_clk,
    test_adc_in,
    test_adc2_in,
    test_db,
    test_adc_out,
    test_ams_osc,
    test_mon_data,
    test_dclk,
    test_den,
    test_dwe,
    test_daddr,
    test_di,
    test_drdy,
    test_do,
    test_convst,
    pstp_pl_clk,
    pstp_pl_in,
    pstp_pl_out,
    pstp_pl_ts,
    fmio_test_gem_scanmux_1,
    fmio_test_gem_scanmux_2,
    test_char_mode_fpd_n,
    test_char_mode_lpd_n,
    fmio_test_io_char_scan_clock,
    fmio_test_io_char_scanenable,
    fmio_test_io_char_scan_in,
    fmio_test_io_char_scan_out,
    fmio_test_io_char_scan_reset_n,
    fmio_char_afifslpd_test_select_n,
    fmio_char_afifslpd_test_input,
    fmio_char_afifslpd_test_output,
    fmio_char_afifsfpd_test_select_n,
    fmio_char_afifsfpd_test_input,
    fmio_char_afifsfpd_test_output,
    io_char_audio_in_test_data,
    io_char_audio_mux_sel_n,
    io_char_video_in_test_data,
    io_char_video_mux_sel_n,
    io_char_video_out_test_data,
    io_char_audio_out_test_data,
    fmio_test_qspi_scanmux_1_n,
    fmio_test_sdio_scanmux_1,
    fmio_test_sdio_scanmux_2,
    fmio_sd0_dll_test_in_n,
    fmio_sd0_dll_test_out,
    fmio_sd1_dll_test_in_n,
    fmio_sd1_dll_test_out,
    test_pl_scan_chopper_si,
    test_pl_scan_chopper_so,
    test_pl_scan_chopper_trig,
    test_pl_scan_clk0,
    test_pl_scan_clk1,
    test_pl_scan_edt_clk,
    test_pl_scan_edt_in_apu,
    test_pl_scan_edt_in_cpu,
    test_pl_scan_edt_in_ddr,
    test_pl_scan_edt_in_fp,
    test_pl_scan_edt_in_gpu,
    test_pl_scan_edt_in_lp,
    test_pl_scan_edt_in_usb3,
    test_pl_scan_edt_out_apu,
    test_pl_scan_edt_out_cpu0,
    test_pl_scan_edt_out_cpu1,
    test_pl_scan_edt_out_cpu2,
    test_pl_scan_edt_out_cpu3,
    test_pl_scan_edt_out_ddr,
    test_pl_scan_edt_out_fp,
    test_pl_scan_edt_out_gpu,
    test_pl_scan_edt_out_lp,
    test_pl_scan_edt_out_usb3,
    test_pl_scan_edt_update,
    test_pl_scan_reset_n,
    test_pl_scanenable,
    test_pl_scan_pll_reset,
    test_pl_scan_spare_in0,
    test_pl_scan_spare_in1,
    test_pl_scan_spare_out0,
    test_pl_scan_spare_out1,
    test_pl_scan_wrap_clk,
    test_pl_scan_wrap_ishift,
    test_pl_scan_wrap_oshift,
    test_pl_scan_slcr_config_clk,
    test_pl_scan_slcr_config_rstn,
    test_pl_scan_slcr_config_si,
    test_pl_scan_spare_in2,
    test_pl_scanenable_slcr_en,
    test_pl_pll_lock_out,
    test_pl_scan_slcr_config_so,
    tst_rtc_calibreg_in,
    tst_rtc_calibreg_out,
    tst_rtc_calibreg_we,
    tst_rtc_clk,
    tst_rtc_osc_clk_out,
    tst_rtc_sec_counter_out,
    tst_rtc_seconds_raw_int,
    tst_rtc_testclock_select_n,
    tst_rtc_tick_counter_out,
    tst_rtc_timesetreg_in,
    tst_rtc_timesetreg_out,
    tst_rtc_disable_bat_op,
    tst_rtc_osc_cntrl_in,
    tst_rtc_osc_cntrl_out,
    tst_rtc_osc_cntrl_we,
    tst_rtc_sec_reload,
    tst_rtc_timesetreg_we,
    tst_rtc_testmode_n,
    test_usb0_funcmux_0_n,
    test_usb1_funcmux_0_n,
    test_usb0_scanmux_0_n,
    test_usb1_scanmux_0_n,
    lpd_pll_test_out,
    pl_lpd_pll_test_ck_sel_n,
    pl_lpd_pll_test_fract_clk_sel_n,
    pl_lpd_pll_test_fract_en_n,
    pl_lpd_pll_test_mux_sel,
    pl_lpd_pll_test_sel,
    fpd_pll_test_out,
    pl_fpd_pll_test_ck_sel_n,
    pl_fpd_pll_test_fract_clk_sel_n,
    pl_fpd_pll_test_fract_en_n,
    pl_fpd_pll_test_mux_sel,
    pl_fpd_pll_test_sel,
    fmio_char_gem_selection,
    fmio_char_gem_test_select_n,
    fmio_char_gem_test_input,
    fmio_char_gem_test_output,
    test_ddr2pl_dcd_skewout,
    test_pl2ddr_dcd_sample_pulse,
    test_bscan_en_n,
    test_bscan_tdi,
    test_bscan_updatedr,
    test_bscan_shiftdr,
    test_bscan_reset_tap_b,
    test_bscan_misr_jtag_load,
    test_bscan_intest,
    test_bscan_extest,
    test_bscan_clockdr,
    test_bscan_ac_mode,
    test_bscan_ac_test,
    test_bscan_init_memory,
    test_bscan_mode_c,
    test_bscan_tdo,
    i_dbg_l0_txclk,
    i_dbg_l0_rxclk,
    i_dbg_l1_txclk,
    i_dbg_l1_rxclk,
    i_dbg_l2_txclk,
    i_dbg_l2_rxclk,
    i_dbg_l3_txclk,
    i_dbg_l3_rxclk,
    i_afe_rx_symbol_clk_by_2_pl,
    pl_fpd_spare_0_in,
    pl_fpd_spare_1_in,
    pl_fpd_spare_2_in,
    pl_fpd_spare_3_in,
    pl_fpd_spare_4_in,
    fpd_pl_spare_0_out,
    fpd_pl_spare_1_out,
    fpd_pl_spare_2_out,
    fpd_pl_spare_3_out,
    fpd_pl_spare_4_out,
    pl_lpd_spare_0_in,
    pl_lpd_spare_1_in,
    pl_lpd_spare_2_in,
    pl_lpd_spare_3_in,
    pl_lpd_spare_4_in,
    lpd_pl_spare_0_out,
    lpd_pl_spare_1_out,
    lpd_pl_spare_2_out,
    lpd_pl_spare_3_out,
    lpd_pl_spare_4_out,
    o_dbg_l0_phystatus,
    o_dbg_l0_rxdata,
    o_dbg_l0_rxdatak,
    o_dbg_l0_rxvalid,
    o_dbg_l0_rxstatus,
    o_dbg_l0_rxelecidle,
    o_dbg_l0_rstb,
    o_dbg_l0_txdata,
    o_dbg_l0_txdatak,
    o_dbg_l0_rate,
    o_dbg_l0_powerdown,
    o_dbg_l0_txelecidle,
    o_dbg_l0_txdetrx_lpback,
    o_dbg_l0_rxpolarity,
    o_dbg_l0_tx_sgmii_ewrap,
    o_dbg_l0_rx_sgmii_en_cdet,
    o_dbg_l0_sata_corerxdata,
    o_dbg_l0_sata_corerxdatavalid,
    o_dbg_l0_sata_coreready,
    o_dbg_l0_sata_coreclockready,
    o_dbg_l0_sata_corerxsignaldet,
    o_dbg_l0_sata_phyctrltxdata,
    o_dbg_l0_sata_phyctrltxidle,
    o_dbg_l0_sata_phyctrltxrate,
    o_dbg_l0_sata_phyctrlrxrate,
    o_dbg_l0_sata_phyctrltxrst,
    o_dbg_l0_sata_phyctrlrxrst,
    o_dbg_l0_sata_phyctrlreset,
    o_dbg_l0_sata_phyctrlpartial,
    o_dbg_l0_sata_phyctrlslumber,
    o_dbg_l1_phystatus,
    o_dbg_l1_rxdata,
    o_dbg_l1_rxdatak,
    o_dbg_l1_rxvalid,
    o_dbg_l1_rxstatus,
    o_dbg_l1_rxelecidle,
    o_dbg_l1_rstb,
    o_dbg_l1_txdata,
    o_dbg_l1_txdatak,
    o_dbg_l1_rate,
    o_dbg_l1_powerdown,
    o_dbg_l1_txelecidle,
    o_dbg_l1_txdetrx_lpback,
    o_dbg_l1_rxpolarity,
    o_dbg_l1_tx_sgmii_ewrap,
    o_dbg_l1_rx_sgmii_en_cdet,
    o_dbg_l1_sata_corerxdata,
    o_dbg_l1_sata_corerxdatavalid,
    o_dbg_l1_sata_coreready,
    o_dbg_l1_sata_coreclockready,
    o_dbg_l1_sata_corerxsignaldet,
    o_dbg_l1_sata_phyctrltxdata,
    o_dbg_l1_sata_phyctrltxidle,
    o_dbg_l1_sata_phyctrltxrate,
    o_dbg_l1_sata_phyctrlrxrate,
    o_dbg_l1_sata_phyctrltxrst,
    o_dbg_l1_sata_phyctrlrxrst,
    o_dbg_l1_sata_phyctrlreset,
    o_dbg_l1_sata_phyctrlpartial,
    o_dbg_l1_sata_phyctrlslumber,
    o_dbg_l2_phystatus,
    o_dbg_l2_rxdata,
    o_dbg_l2_rxdatak,
    o_dbg_l2_rxvalid,
    o_dbg_l2_rxstatus,
    o_dbg_l2_rxelecidle,
    o_dbg_l2_rstb,
    o_dbg_l2_txdata,
    o_dbg_l2_txdatak,
    o_dbg_l2_rate,
    o_dbg_l2_powerdown,
    o_dbg_l2_txelecidle,
    o_dbg_l2_txdetrx_lpback,
    o_dbg_l2_rxpolarity,
    o_dbg_l2_tx_sgmii_ewrap,
    o_dbg_l2_rx_sgmii_en_cdet,
    o_dbg_l2_sata_corerxdata,
    o_dbg_l2_sata_corerxdatavalid,
    o_dbg_l2_sata_coreready,
    o_dbg_l2_sata_coreclockready,
    o_dbg_l2_sata_corerxsignaldet,
    o_dbg_l2_sata_phyctrltxdata,
    o_dbg_l2_sata_phyctrltxidle,
    o_dbg_l2_sata_phyctrltxrate,
    o_dbg_l2_sata_phyctrlrxrate,
    o_dbg_l2_sata_phyctrltxrst,
    o_dbg_l2_sata_phyctrlrxrst,
    o_dbg_l2_sata_phyctrlreset,
    o_dbg_l2_sata_phyctrlpartial,
    o_dbg_l2_sata_phyctrlslumber,
    o_dbg_l3_phystatus,
    o_dbg_l3_rxdata,
    o_dbg_l3_rxdatak,
    o_dbg_l3_rxvalid,
    o_dbg_l3_rxstatus,
    o_dbg_l3_rxelecidle,
    o_dbg_l3_rstb,
    o_dbg_l3_txdata,
    o_dbg_l3_txdatak,
    o_dbg_l3_rate,
    o_dbg_l3_powerdown,
    o_dbg_l3_txelecidle,
    o_dbg_l3_txdetrx_lpback,
    o_dbg_l3_rxpolarity,
    o_dbg_l3_tx_sgmii_ewrap,
    o_dbg_l3_rx_sgmii_en_cdet,
    o_dbg_l3_sata_corerxdata,
    o_dbg_l3_sata_corerxdatavalid,
    o_dbg_l3_sata_coreready,
    o_dbg_l3_sata_coreclockready,
    o_dbg_l3_sata_corerxsignaldet,
    o_dbg_l3_sata_phyctrltxdata,
    o_dbg_l3_sata_phyctrltxidle,
    o_dbg_l3_sata_phyctrltxrate,
    o_dbg_l3_sata_phyctrlrxrate,
    o_dbg_l3_sata_phyctrltxrst,
    o_dbg_l3_sata_phyctrlrxrst,
    o_dbg_l3_sata_phyctrlreset,
    o_dbg_l3_sata_phyctrlpartial,
    o_dbg_l3_sata_phyctrlslumber,
    dbg_path_fifo_bypass,
    i_afe_pll_pd_hs_clock_r,
    i_afe_mode,
    i_bgcal_afe_mode,
    o_afe_cmn_calib_comp_out,
    i_afe_cmn_bg_enable_low_leakage,
    i_afe_cmn_bg_iso_ctrl_bar,
    i_afe_cmn_bg_pd,
    i_afe_cmn_bg_pd_bg_ok,
    i_afe_cmn_bg_pd_ptat,
    i_afe_cmn_calib_en_iconst,
    i_afe_cmn_calib_enable_low_leakage,
    i_afe_cmn_calib_iso_ctrl_bar,
    o_afe_pll_dco_count,
    o_afe_pll_clk_sym_hs,
    o_afe_pll_fbclk_frac,
    o_afe_rx_pipe_lfpsbcn_rxelecidle,
    o_afe_rx_pipe_sigdet,
    o_afe_rx_symbol,
    o_afe_rx_symbol_clk_by_2,
    o_afe_rx_uphy_save_calcode,
    o_afe_rx_uphy_startloop_buf,
    o_afe_rx_uphy_rx_calib_done,
    i_afe_rx_rxpma_rstb,
    i_afe_rx_uphy_restore_calcode_data,
    i_afe_rx_pipe_rxeqtraining,
    i_afe_rx_iso_hsrx_ctrl_bar,
    i_afe_rx_iso_lfps_ctrl_bar,
    i_afe_rx_iso_sigdet_ctrl_bar,
    i_afe_rx_hsrx_clock_stop_req,
    o_afe_rx_uphy_save_calcode_data,
    o_afe_rx_hsrx_clock_stop_ack,
    o_afe_pg_avddcr,
    o_afe_pg_avddio,
    o_afe_pg_dvddcr,
    o_afe_pg_static_avddcr,
    o_afe_pg_static_avddio,
    i_pll_afe_mode,
    i_afe_pll_coarse_code,
    i_afe_pll_en_clock_hs_div2,
    i_afe_pll_fbdiv,
    i_afe_pll_load_fbdiv,
    i_afe_pll_pd,
    i_afe_pll_pd_pfd,
    i_afe_pll_rst_fdbk_div,
    i_afe_pll_startloop,
    i_afe_pll_v2i_code,
    i_afe_pll_v2i_prog,
    i_afe_pll_vco_cnt_window,
    i_afe_rx_mphy_gate_symbol_clk,
    i_afe_rx_mphy_mux_hsb_ls,
    i_afe_rx_pipe_rx_term_enable,
    i_afe_rx_uphy_biasgen_iconst_core_mirror_enable,
    i_afe_rx_uphy_biasgen_iconst_io_mirror_enable,
    i_afe_rx_uphy_biasgen_irconst_core_mirror_enable,
    i_afe_rx_uphy_enable_cdr,
    i_afe_rx_uphy_enable_low_leakage,
    i_afe_rx_rxpma_refclk_dig,
    i_afe_rx_uphy_hsrx_rstb,
    i_afe_rx_uphy_pdn_hs_des,
    i_afe_rx_uphy_pd_samp_c2c,
    i_afe_rx_uphy_pd_samp_c2c_eclk,
    i_afe_rx_uphy_pso_clk_lane,
    i_afe_rx_uphy_pso_eq,
    i_afe_rx_uphy_pso_hsrxdig,
    i_afe_rx_uphy_pso_iqpi,
    i_afe_rx_uphy_pso_lfpsbcn,
    i_afe_rx_uphy_pso_samp_flops,
    i_afe_rx_uphy_pso_sigdet,
    i_afe_rx_uphy_restore_calcode,
    i_afe_rx_uphy_run_calib,
    i_afe_rx_uphy_rx_lane_polarity_swap,
    i_afe_rx_uphy_startloop_pll,
    i_afe_rx_uphy_hsclk_division_factor,
    i_afe_rx_uphy_rx_pma_opmode,
    i_afe_tx_enable_hsclk_division,
    i_afe_tx_enable_ldo,
    i_afe_tx_enable_ref,
    i_afe_tx_enable_supply_hsclk,
    i_afe_tx_enable_supply_pipe,
    i_afe_tx_enable_supply_serializer,
    i_afe_tx_enable_supply_uphy,
    i_afe_tx_hs_ser_rstb,
    i_afe_tx_hs_symbol,
    i_afe_tx_mphy_tx_ls_data,
    i_afe_tx_pipe_tx_enable_idle_mode,
    i_afe_tx_pipe_tx_enable_lfps,
    i_afe_tx_pipe_tx_enable_rxdet,
    i_afe_TX_uphy_txpma_opmode,
    i_afe_TX_pmadig_digital_reset_n,
    i_afe_TX_serializer_rst_rel,
    i_afe_TX_pll_symb_clk_2,
    i_afe_TX_ana_if_rate,
    i_afe_TX_en_dig_sublp_mode,
    i_afe_TX_LPBK_SEL,
    i_afe_TX_iso_ctrl_bar,
    i_afe_TX_ser_iso_ctrl_bar,
    i_afe_TX_lfps_clk,
    i_afe_TX_serializer_rstb,
    o_afe_TX_dig_reset_rel_ack,
    o_afe_TX_pipe_TX_dn_rxdet,
    o_afe_TX_pipe_TX_dp_rxdet,
    i_afe_tx_pipe_tx_fast_est_common_mode,
    o_dbg_l0_txclk,
    o_dbg_l0_rxclk,
    o_dbg_l1_txclk,
    o_dbg_l1_rxclk,
    o_dbg_l2_txclk,
    o_dbg_l2_rxclk,
    o_dbg_l3_txclk,
    o_dbg_l3_rxclk);
  input maxihpm0_fpd_aclk;
  output dp_video_ref_clk;
  output dp_audio_ref_clk;
  output [15:0]maxigp0_awid;
  output [39:0]maxigp0_awaddr;
  output [7:0]maxigp0_awlen;
  output [2:0]maxigp0_awsize;
  output [1:0]maxigp0_awburst;
  output maxigp0_awlock;
  output [3:0]maxigp0_awcache;
  output [2:0]maxigp0_awprot;
  output maxigp0_awvalid;
  output [15:0]maxigp0_awuser;
  input maxigp0_awready;
  output [31:0]maxigp0_wdata;
  output [3:0]maxigp0_wstrb;
  output maxigp0_wlast;
  output maxigp0_wvalid;
  input maxigp0_wready;
  input [15:0]maxigp0_bid;
  input [1:0]maxigp0_bresp;
  input maxigp0_bvalid;
  output maxigp0_bready;
  output [15:0]maxigp0_arid;
  output [39:0]maxigp0_araddr;
  output [7:0]maxigp0_arlen;
  output [2:0]maxigp0_arsize;
  output [1:0]maxigp0_arburst;
  output maxigp0_arlock;
  output [3:0]maxigp0_arcache;
  output [2:0]maxigp0_arprot;
  output maxigp0_arvalid;
  output [15:0]maxigp0_aruser;
  input maxigp0_arready;
  input [15:0]maxigp0_rid;
  input [31:0]maxigp0_rdata;
  input [1:0]maxigp0_rresp;
  input maxigp0_rlast;
  input maxigp0_rvalid;
  output maxigp0_rready;
  output [3:0]maxigp0_awqos;
  output [3:0]maxigp0_arqos;
  input maxihpm1_fpd_aclk;
  output [15:0]maxigp1_awid;
  output [39:0]maxigp1_awaddr;
  output [7:0]maxigp1_awlen;
  output [2:0]maxigp1_awsize;
  output [1:0]maxigp1_awburst;
  output maxigp1_awlock;
  output [3:0]maxigp1_awcache;
  output [2:0]maxigp1_awprot;
  output maxigp1_awvalid;
  output [15:0]maxigp1_awuser;
  input maxigp1_awready;
  output [31:0]maxigp1_wdata;
  output [3:0]maxigp1_wstrb;
  output maxigp1_wlast;
  output maxigp1_wvalid;
  input maxigp1_wready;
  input [15:0]maxigp1_bid;
  input [1:0]maxigp1_bresp;
  input maxigp1_bvalid;
  output maxigp1_bready;
  output [15:0]maxigp1_arid;
  output [39:0]maxigp1_araddr;
  output [7:0]maxigp1_arlen;
  output [2:0]maxigp1_arsize;
  output [1:0]maxigp1_arburst;
  output maxigp1_arlock;
  output [3:0]maxigp1_arcache;
  output [2:0]maxigp1_arprot;
  output maxigp1_arvalid;
  output [15:0]maxigp1_aruser;
  input maxigp1_arready;
  input [15:0]maxigp1_rid;
  input [31:0]maxigp1_rdata;
  input [1:0]maxigp1_rresp;
  input maxigp1_rlast;
  input maxigp1_rvalid;
  output maxigp1_rready;
  output [3:0]maxigp1_awqos;
  output [3:0]maxigp1_arqos;
  input maxihpm0_lpd_aclk;
  output [15:0]maxigp2_awid;
  output [39:0]maxigp2_awaddr;
  output [7:0]maxigp2_awlen;
  output [2:0]maxigp2_awsize;
  output [1:0]maxigp2_awburst;
  output maxigp2_awlock;
  output [3:0]maxigp2_awcache;
  output [2:0]maxigp2_awprot;
  output maxigp2_awvalid;
  output [15:0]maxigp2_awuser;
  input maxigp2_awready;
  output [31:0]maxigp2_wdata;
  output [3:0]maxigp2_wstrb;
  output maxigp2_wlast;
  output maxigp2_wvalid;
  input maxigp2_wready;
  input [15:0]maxigp2_bid;
  input [1:0]maxigp2_bresp;
  input maxigp2_bvalid;
  output maxigp2_bready;
  output [15:0]maxigp2_arid;
  output [39:0]maxigp2_araddr;
  output [7:0]maxigp2_arlen;
  output [2:0]maxigp2_arsize;
  output [1:0]maxigp2_arburst;
  output maxigp2_arlock;
  output [3:0]maxigp2_arcache;
  output [2:0]maxigp2_arprot;
  output maxigp2_arvalid;
  output [15:0]maxigp2_aruser;
  input maxigp2_arready;
  input [15:0]maxigp2_rid;
  input [31:0]maxigp2_rdata;
  input [1:0]maxigp2_rresp;
  input maxigp2_rlast;
  input maxigp2_rvalid;
  output maxigp2_rready;
  output [3:0]maxigp2_awqos;
  output [3:0]maxigp2_arqos;
  input saxihpc0_fpd_aclk;
  input saxihpc0_fpd_rclk;
  input saxihpc0_fpd_wclk;
  input saxigp0_aruser;
  input saxigp0_awuser;
  input [5:0]saxigp0_awid;
  input [48:0]saxigp0_awaddr;
  input [7:0]saxigp0_awlen;
  input [2:0]saxigp0_awsize;
  input [1:0]saxigp0_awburst;
  input saxigp0_awlock;
  input [3:0]saxigp0_awcache;
  input [2:0]saxigp0_awprot;
  input saxigp0_awvalid;
  output saxigp0_awready;
  input [63:0]saxigp0_wdata;
  input [7:0]saxigp0_wstrb;
  input saxigp0_wlast;
  input saxigp0_wvalid;
  output saxigp0_wready;
  output [5:0]saxigp0_bid;
  output [1:0]saxigp0_bresp;
  output saxigp0_bvalid;
  input saxigp0_bready;
  input [5:0]saxigp0_arid;
  input [48:0]saxigp0_araddr;
  input [7:0]saxigp0_arlen;
  input [2:0]saxigp0_arsize;
  input [1:0]saxigp0_arburst;
  input saxigp0_arlock;
  input [3:0]saxigp0_arcache;
  input [2:0]saxigp0_arprot;
  input saxigp0_arvalid;
  output saxigp0_arready;
  output [5:0]saxigp0_rid;
  output [63:0]saxigp0_rdata;
  output [1:0]saxigp0_rresp;
  output saxigp0_rlast;
  output saxigp0_rvalid;
  input saxigp0_rready;
  input [3:0]saxigp0_awqos;
  input [3:0]saxigp0_arqos;
  output [7:0]saxigp0_rcount;
  output [7:0]saxigp0_wcount;
  output [3:0]saxigp0_racount;
  output [3:0]saxigp0_wacount;
  input saxihpc1_fpd_aclk;
  input saxihpc1_fpd_rclk;
  input saxihpc1_fpd_wclk;
  input saxigp1_aruser;
  input saxigp1_awuser;
  input [5:0]saxigp1_awid;
  input [48:0]saxigp1_awaddr;
  input [7:0]saxigp1_awlen;
  input [2:0]saxigp1_awsize;
  input [1:0]saxigp1_awburst;
  input saxigp1_awlock;
  input [3:0]saxigp1_awcache;
  input [2:0]saxigp1_awprot;
  input saxigp1_awvalid;
  output saxigp1_awready;
  input [127:0]saxigp1_wdata;
  input [15:0]saxigp1_wstrb;
  input saxigp1_wlast;
  input saxigp1_wvalid;
  output saxigp1_wready;
  output [5:0]saxigp1_bid;
  output [1:0]saxigp1_bresp;
  output saxigp1_bvalid;
  input saxigp1_bready;
  input [5:0]saxigp1_arid;
  input [48:0]saxigp1_araddr;
  input [7:0]saxigp1_arlen;
  input [2:0]saxigp1_arsize;
  input [1:0]saxigp1_arburst;
  input saxigp1_arlock;
  input [3:0]saxigp1_arcache;
  input [2:0]saxigp1_arprot;
  input saxigp1_arvalid;
  output saxigp1_arready;
  output [5:0]saxigp1_rid;
  output [127:0]saxigp1_rdata;
  output [1:0]saxigp1_rresp;
  output saxigp1_rlast;
  output saxigp1_rvalid;
  input saxigp1_rready;
  input [3:0]saxigp1_awqos;
  input [3:0]saxigp1_arqos;
  output [7:0]saxigp1_rcount;
  output [7:0]saxigp1_wcount;
  output [3:0]saxigp1_racount;
  output [3:0]saxigp1_wacount;
  input saxihp0_fpd_aclk;
  input saxihp0_fpd_rclk;
  input saxihp0_fpd_wclk;
  input saxigp2_aruser;
  input saxigp2_awuser;
  input [5:0]saxigp2_awid;
  input [48:0]saxigp2_awaddr;
  input [7:0]saxigp2_awlen;
  input [2:0]saxigp2_awsize;
  input [1:0]saxigp2_awburst;
  input saxigp2_awlock;
  input [3:0]saxigp2_awcache;
  input [2:0]saxigp2_awprot;
  input saxigp2_awvalid;
  output saxigp2_awready;
  input [127:0]saxigp2_wdata;
  input [15:0]saxigp2_wstrb;
  input saxigp2_wlast;
  input saxigp2_wvalid;
  output saxigp2_wready;
  output [5:0]saxigp2_bid;
  output [1:0]saxigp2_bresp;
  output saxigp2_bvalid;
  input saxigp2_bready;
  input [5:0]saxigp2_arid;
  input [48:0]saxigp2_araddr;
  input [7:0]saxigp2_arlen;
  input [2:0]saxigp2_arsize;
  input [1:0]saxigp2_arburst;
  input saxigp2_arlock;
  input [3:0]saxigp2_arcache;
  input [2:0]saxigp2_arprot;
  input saxigp2_arvalid;
  output saxigp2_arready;
  output [5:0]saxigp2_rid;
  output [127:0]saxigp2_rdata;
  output [1:0]saxigp2_rresp;
  output saxigp2_rlast;
  output saxigp2_rvalid;
  input saxigp2_rready;
  input [3:0]saxigp2_awqos;
  input [3:0]saxigp2_arqos;
  output [7:0]saxigp2_rcount;
  output [7:0]saxigp2_wcount;
  output [3:0]saxigp2_racount;
  output [3:0]saxigp2_wacount;
  input saxihp1_fpd_aclk;
  input saxihp1_fpd_rclk;
  input saxihp1_fpd_wclk;
  input saxigp3_aruser;
  input saxigp3_awuser;
  input [5:0]saxigp3_awid;
  input [48:0]saxigp3_awaddr;
  input [7:0]saxigp3_awlen;
  input [2:0]saxigp3_awsize;
  input [1:0]saxigp3_awburst;
  input saxigp3_awlock;
  input [3:0]saxigp3_awcache;
  input [2:0]saxigp3_awprot;
  input saxigp3_awvalid;
  output saxigp3_awready;
  input [127:0]saxigp3_wdata;
  input [15:0]saxigp3_wstrb;
  input saxigp3_wlast;
  input saxigp3_wvalid;
  output saxigp3_wready;
  output [5:0]saxigp3_bid;
  output [1:0]saxigp3_bresp;
  output saxigp3_bvalid;
  input saxigp3_bready;
  input [5:0]saxigp3_arid;
  input [48:0]saxigp3_araddr;
  input [7:0]saxigp3_arlen;
  input [2:0]saxigp3_arsize;
  input [1:0]saxigp3_arburst;
  input saxigp3_arlock;
  input [3:0]saxigp3_arcache;
  input [2:0]saxigp3_arprot;
  input saxigp3_arvalid;
  output saxigp3_arready;
  output [5:0]saxigp3_rid;
  output [127:0]saxigp3_rdata;
  output [1:0]saxigp3_rresp;
  output saxigp3_rlast;
  output saxigp3_rvalid;
  input saxigp3_rready;
  input [3:0]saxigp3_awqos;
  input [3:0]saxigp3_arqos;
  output [7:0]saxigp3_rcount;
  output [7:0]saxigp3_wcount;
  output [3:0]saxigp3_racount;
  output [3:0]saxigp3_wacount;
  input saxihp2_fpd_aclk;
  input saxihp2_fpd_rclk;
  input saxihp2_fpd_wclk;
  input saxigp4_aruser;
  input saxigp4_awuser;
  input [5:0]saxigp4_awid;
  input [48:0]saxigp4_awaddr;
  input [7:0]saxigp4_awlen;
  input [2:0]saxigp4_awsize;
  input [1:0]saxigp4_awburst;
  input saxigp4_awlock;
  input [3:0]saxigp4_awcache;
  input [2:0]saxigp4_awprot;
  input saxigp4_awvalid;
  output saxigp4_awready;
  input [127:0]saxigp4_wdata;
  input [15:0]saxigp4_wstrb;
  input saxigp4_wlast;
  input saxigp4_wvalid;
  output saxigp4_wready;
  output [5:0]saxigp4_bid;
  output [1:0]saxigp4_bresp;
  output saxigp4_bvalid;
  input saxigp4_bready;
  input [5:0]saxigp4_arid;
  input [48:0]saxigp4_araddr;
  input [7:0]saxigp4_arlen;
  input [2:0]saxigp4_arsize;
  input [1:0]saxigp4_arburst;
  input saxigp4_arlock;
  input [3:0]saxigp4_arcache;
  input [2:0]saxigp4_arprot;
  input saxigp4_arvalid;
  output saxigp4_arready;
  output [5:0]saxigp4_rid;
  output [127:0]saxigp4_rdata;
  output [1:0]saxigp4_rresp;
  output saxigp4_rlast;
  output saxigp4_rvalid;
  input saxigp4_rready;
  input [3:0]saxigp4_awqos;
  input [3:0]saxigp4_arqos;
  output [7:0]saxigp4_rcount;
  output [7:0]saxigp4_wcount;
  output [3:0]saxigp4_racount;
  output [3:0]saxigp4_wacount;
  input saxihp3_fpd_aclk;
  input saxihp3_fpd_rclk;
  input saxihp3_fpd_wclk;
  input saxigp5_aruser;
  input saxigp5_awuser;
  input [5:0]saxigp5_awid;
  input [48:0]saxigp5_awaddr;
  input [7:0]saxigp5_awlen;
  input [2:0]saxigp5_awsize;
  input [1:0]saxigp5_awburst;
  input saxigp5_awlock;
  input [3:0]saxigp5_awcache;
  input [2:0]saxigp5_awprot;
  input saxigp5_awvalid;
  output saxigp5_awready;
  input [127:0]saxigp5_wdata;
  input [15:0]saxigp5_wstrb;
  input saxigp5_wlast;
  input saxigp5_wvalid;
  output saxigp5_wready;
  output [5:0]saxigp5_bid;
  output [1:0]saxigp5_bresp;
  output saxigp5_bvalid;
  input saxigp5_bready;
  input [5:0]saxigp5_arid;
  input [48:0]saxigp5_araddr;
  input [7:0]saxigp5_arlen;
  input [2:0]saxigp5_arsize;
  input [1:0]saxigp5_arburst;
  input saxigp5_arlock;
  input [3:0]saxigp5_arcache;
  input [2:0]saxigp5_arprot;
  input saxigp5_arvalid;
  output saxigp5_arready;
  output [5:0]saxigp5_rid;
  output [127:0]saxigp5_rdata;
  output [1:0]saxigp5_rresp;
  output saxigp5_rlast;
  output saxigp5_rvalid;
  input saxigp5_rready;
  input [3:0]saxigp5_awqos;
  input [3:0]saxigp5_arqos;
  output [7:0]saxigp5_rcount;
  output [7:0]saxigp5_wcount;
  output [3:0]saxigp5_racount;
  output [3:0]saxigp5_wacount;
  input saxi_lpd_aclk;
  input saxi_lpd_rclk;
  input saxi_lpd_wclk;
  input saxigp6_aruser;
  input saxigp6_awuser;
  input [5:0]saxigp6_awid;
  input [48:0]saxigp6_awaddr;
  input [7:0]saxigp6_awlen;
  input [2:0]saxigp6_awsize;
  input [1:0]saxigp6_awburst;
  input saxigp6_awlock;
  input [3:0]saxigp6_awcache;
  input [2:0]saxigp6_awprot;
  input saxigp6_awvalid;
  output saxigp6_awready;
  input [127:0]saxigp6_wdata;
  input [15:0]saxigp6_wstrb;
  input saxigp6_wlast;
  input saxigp6_wvalid;
  output saxigp6_wready;
  output [5:0]saxigp6_bid;
  output [1:0]saxigp6_bresp;
  output saxigp6_bvalid;
  input saxigp6_bready;
  input [5:0]saxigp6_arid;
  input [48:0]saxigp6_araddr;
  input [7:0]saxigp6_arlen;
  input [2:0]saxigp6_arsize;
  input [1:0]saxigp6_arburst;
  input saxigp6_arlock;
  input [3:0]saxigp6_arcache;
  input [2:0]saxigp6_arprot;
  input saxigp6_arvalid;
  output saxigp6_arready;
  output [5:0]saxigp6_rid;
  output [127:0]saxigp6_rdata;
  output [1:0]saxigp6_rresp;
  output saxigp6_rlast;
  output saxigp6_rvalid;
  input saxigp6_rready;
  input [3:0]saxigp6_awqos;
  input [3:0]saxigp6_arqos;
  output [7:0]saxigp6_rcount;
  output [7:0]saxigp6_wcount;
  output [3:0]saxigp6_racount;
  output [3:0]saxigp6_wacount;
  input saxiacp_fpd_aclk;
  input [39:0]saxiacp_awaddr;
  input [4:0]saxiacp_awid;
  input [7:0]saxiacp_awlen;
  input [2:0]saxiacp_awsize;
  input [1:0]saxiacp_awburst;
  input saxiacp_awlock;
  input [3:0]saxiacp_awcache;
  input [2:0]saxiacp_awprot;
  input saxiacp_awvalid;
  output saxiacp_awready;
  input [1:0]saxiacp_awuser;
  input [3:0]saxiacp_awqos;
  input saxiacp_wlast;
  input [127:0]saxiacp_wdata;
  input [15:0]saxiacp_wstrb;
  input saxiacp_wvalid;
  output saxiacp_wready;
  output [1:0]saxiacp_bresp;
  output [4:0]saxiacp_bid;
  output saxiacp_bvalid;
  input saxiacp_bready;
  input [39:0]saxiacp_araddr;
  input [4:0]saxiacp_arid;
  input [7:0]saxiacp_arlen;
  input [2:0]saxiacp_arsize;
  input [1:0]saxiacp_arburst;
  input saxiacp_arlock;
  input [3:0]saxiacp_arcache;
  input [2:0]saxiacp_arprot;
  input saxiacp_arvalid;
  output saxiacp_arready;
  input [1:0]saxiacp_aruser;
  input [3:0]saxiacp_arqos;
  output [4:0]saxiacp_rid;
  output saxiacp_rlast;
  output [127:0]saxiacp_rdata;
  output [1:0]saxiacp_rresp;
  output saxiacp_rvalid;
  input saxiacp_rready;
  input sacefpd_aclk;
  input sacefpd_awvalid;
  output sacefpd_awready;
  input [5:0]sacefpd_awid;
  input [43:0]sacefpd_awaddr;
  input [3:0]sacefpd_awregion;
  input [7:0]sacefpd_awlen;
  input [2:0]sacefpd_awsize;
  input [1:0]sacefpd_awburst;
  input sacefpd_awlock;
  input [3:0]sacefpd_awcache;
  input [2:0]sacefpd_awprot;
  input [1:0]sacefpd_awdomain;
  input [2:0]sacefpd_awsnoop;
  input [1:0]sacefpd_awbar;
  input [3:0]sacefpd_awqos;
  input sacefpd_wvalid;
  output sacefpd_wready;
  input [127:0]sacefpd_wdata;
  input [15:0]sacefpd_wstrb;
  input sacefpd_wlast;
  input sacefpd_wuser;
  output sacefpd_bvalid;
  input sacefpd_bready;
  output [5:0]sacefpd_bid;
  output [1:0]sacefpd_bresp;
  output sacefpd_buser;
  input sacefpd_arvalid;
  output sacefpd_arready;
  input [5:0]sacefpd_arid;
  input [43:0]sacefpd_araddr;
  input [3:0]sacefpd_arregion;
  input [7:0]sacefpd_arlen;
  input [2:0]sacefpd_arsize;
  input [1:0]sacefpd_arburst;
  input sacefpd_arlock;
  input [3:0]sacefpd_arcache;
  input [2:0]sacefpd_arprot;
  input [1:0]sacefpd_ardomain;
  input [3:0]sacefpd_arsnoop;
  input [1:0]sacefpd_arbar;
  input [3:0]sacefpd_arqos;
  output sacefpd_rvalid;
  input sacefpd_rready;
  output [5:0]sacefpd_rid;
  output [127:0]sacefpd_rdata;
  output [3:0]sacefpd_rresp;
  output sacefpd_rlast;
  output sacefpd_ruser;
  output sacefpd_acvalid;
  input sacefpd_acready;
  output [43:0]sacefpd_acaddr;
  output [3:0]sacefpd_acsnoop;
  output [2:0]sacefpd_acprot;
  input sacefpd_crvalid;
  output sacefpd_crready;
  input [4:0]sacefpd_crresp;
  input sacefpd_cdvalid;
  output sacefpd_cdready;
  input [127:0]sacefpd_cddata;
  input sacefpd_cdlast;
  input sacefpd_wack;
  input sacefpd_rack;
  output emio_can0_phy_tx;
  input emio_can0_phy_rx;
  output emio_can1_phy_tx;
  input emio_can1_phy_rx;
  input emio_enet0_gmii_rx_clk;
  output [2:0]emio_enet0_speed_mode;
  input emio_enet0_gmii_crs;
  input emio_enet0_gmii_col;
  input [7:0]emio_enet0_gmii_rxd;
  input emio_enet0_gmii_rx_er;
  input emio_enet0_gmii_rx_dv;
  input emio_enet0_gmii_tx_clk;
  output [7:0]emio_enet0_gmii_txd;
  output emio_enet0_gmii_tx_en;
  output emio_enet0_gmii_tx_er;
  output emio_enet0_mdio_mdc;
  input emio_enet0_mdio_i;
  output emio_enet0_mdio_o;
  output emio_enet0_mdio_t;
  output emio_enet0_mdio_t_n;
  input emio_enet1_gmii_rx_clk;
  output [2:0]emio_enet1_speed_mode;
  input emio_enet1_gmii_crs;
  input emio_enet1_gmii_col;
  input [7:0]emio_enet1_gmii_rxd;
  input emio_enet1_gmii_rx_er;
  input emio_enet1_gmii_rx_dv;
  input emio_enet1_gmii_tx_clk;
  output [7:0]emio_enet1_gmii_txd;
  output emio_enet1_gmii_tx_en;
  output emio_enet1_gmii_tx_er;
  output emio_enet1_mdio_mdc;
  input emio_enet1_mdio_i;
  output emio_enet1_mdio_o;
  output emio_enet1_mdio_t;
  output emio_enet1_mdio_t_n;
  input emio_enet2_gmii_rx_clk;
  output [2:0]emio_enet2_speed_mode;
  input emio_enet2_gmii_crs;
  input emio_enet2_gmii_col;
  input [7:0]emio_enet2_gmii_rxd;
  input emio_enet2_gmii_rx_er;
  input emio_enet2_gmii_rx_dv;
  input emio_enet2_gmii_tx_clk;
  output [7:0]emio_enet2_gmii_txd;
  output emio_enet2_gmii_tx_en;
  output emio_enet2_gmii_tx_er;
  output emio_enet2_mdio_mdc;
  input emio_enet2_mdio_i;
  output emio_enet2_mdio_o;
  output emio_enet2_mdio_t;
  output emio_enet2_mdio_t_n;
  input emio_enet3_gmii_rx_clk;
  output [2:0]emio_enet3_speed_mode;
  input emio_enet3_gmii_crs;
  input emio_enet3_gmii_col;
  input [7:0]emio_enet3_gmii_rxd;
  input emio_enet3_gmii_rx_er;
  input emio_enet3_gmii_rx_dv;
  input emio_enet3_gmii_tx_clk;
  output [7:0]emio_enet3_gmii_txd;
  output emio_enet3_gmii_tx_en;
  output emio_enet3_gmii_tx_er;
  output emio_enet3_mdio_mdc;
  input emio_enet3_mdio_i;
  output emio_enet3_mdio_o;
  output emio_enet3_mdio_t;
  output emio_enet3_mdio_t_n;
  input emio_enet0_tx_r_data_rdy;
  output emio_enet0_tx_r_rd;
  input emio_enet0_tx_r_valid;
  input [7:0]emio_enet0_tx_r_data;
  input emio_enet0_tx_r_sop;
  input emio_enet0_tx_r_eop;
  input emio_enet0_tx_r_err;
  input emio_enet0_tx_r_underflow;
  input emio_enet0_tx_r_flushed;
  input emio_enet0_tx_r_control;
  output emio_enet0_dma_tx_end_tog;
  input emio_enet0_dma_tx_status_tog;
  output [3:0]emio_enet0_tx_r_status;
  output emio_enet0_rx_w_wr;
  output [7:0]emio_enet0_rx_w_data;
  output emio_enet0_rx_w_sop;
  output emio_enet0_rx_w_eop;
  output [44:0]emio_enet0_rx_w_status;
  output emio_enet0_rx_w_err;
  input emio_enet0_rx_w_overflow;
  input emio_enet0_signal_detect;
  output emio_enet0_rx_w_flush;
  output emio_enet0_tx_r_fixed_lat;
  input emio_enet1_tx_r_data_rdy;
  output emio_enet1_tx_r_rd;
  input emio_enet1_tx_r_valid;
  input [7:0]emio_enet1_tx_r_data;
  input emio_enet1_tx_r_sop;
  input emio_enet1_tx_r_eop;
  input emio_enet1_tx_r_err;
  input emio_enet1_tx_r_underflow;
  input emio_enet1_tx_r_flushed;
  input emio_enet1_tx_r_control;
  output emio_enet1_dma_tx_end_tog;
  input emio_enet1_dma_tx_status_tog;
  output [3:0]emio_enet1_tx_r_status;
  output emio_enet1_rx_w_wr;
  output [7:0]emio_enet1_rx_w_data;
  output emio_enet1_rx_w_sop;
  output emio_enet1_rx_w_eop;
  output [44:0]emio_enet1_rx_w_status;
  output emio_enet1_rx_w_err;
  input emio_enet1_rx_w_overflow;
  input emio_enet1_signal_detect;
  output emio_enet1_rx_w_flush;
  output emio_enet1_tx_r_fixed_lat;
  input emio_enet2_tx_r_data_rdy;
  output emio_enet2_tx_r_rd;
  input emio_enet2_tx_r_valid;
  input [7:0]emio_enet2_tx_r_data;
  input emio_enet2_tx_r_sop;
  input emio_enet2_tx_r_eop;
  input emio_enet2_tx_r_err;
  input emio_enet2_tx_r_underflow;
  input emio_enet2_tx_r_flushed;
  input emio_enet2_tx_r_control;
  output emio_enet2_dma_tx_end_tog;
  input emio_enet2_dma_tx_status_tog;
  output [3:0]emio_enet2_tx_r_status;
  output emio_enet2_rx_w_wr;
  output [7:0]emio_enet2_rx_w_data;
  output emio_enet2_rx_w_sop;
  output emio_enet2_rx_w_eop;
  output [44:0]emio_enet2_rx_w_status;
  output emio_enet2_rx_w_err;
  input emio_enet2_rx_w_overflow;
  input emio_enet2_signal_detect;
  output emio_enet2_rx_w_flush;
  output emio_enet2_tx_r_fixed_lat;
  input emio_enet3_tx_r_data_rdy;
  output emio_enet3_tx_r_rd;
  input emio_enet3_tx_r_valid;
  input [7:0]emio_enet3_tx_r_data;
  input emio_enet3_tx_r_sop;
  input emio_enet3_tx_r_eop;
  input emio_enet3_tx_r_err;
  input emio_enet3_tx_r_underflow;
  input emio_enet3_tx_r_flushed;
  input emio_enet3_tx_r_control;
  output emio_enet3_dma_tx_end_tog;
  input emio_enet3_dma_tx_status_tog;
  output [3:0]emio_enet3_tx_r_status;
  output emio_enet3_rx_w_wr;
  output [7:0]emio_enet3_rx_w_data;
  output emio_enet3_rx_w_sop;
  output emio_enet3_rx_w_eop;
  output [44:0]emio_enet3_rx_w_status;
  output emio_enet3_rx_w_err;
  input emio_enet3_rx_w_overflow;
  input emio_enet3_signal_detect;
  output emio_enet3_rx_w_flush;
  output emio_enet3_tx_r_fixed_lat;
  output fmio_gem0_fifo_tx_clk_to_pl_bufg;
  output fmio_gem0_fifo_rx_clk_to_pl_bufg;
  output fmio_gem1_fifo_tx_clk_to_pl_bufg;
  output fmio_gem1_fifo_rx_clk_to_pl_bufg;
  output fmio_gem2_fifo_tx_clk_to_pl_bufg;
  output fmio_gem2_fifo_rx_clk_to_pl_bufg;
  output fmio_gem3_fifo_tx_clk_to_pl_bufg;
  output fmio_gem3_fifo_rx_clk_to_pl_bufg;
  output emio_enet0_tx_sof;
  output emio_enet0_sync_frame_tx;
  output emio_enet0_delay_req_tx;
  output emio_enet0_pdelay_req_tx;
  output emio_enet0_pdelay_resp_tx;
  output emio_enet0_rx_sof;
  output emio_enet0_sync_frame_rx;
  output emio_enet0_delay_req_rx;
  output emio_enet0_pdelay_req_rx;
  output emio_enet0_pdelay_resp_rx;
  input [1:0]emio_enet0_tsu_inc_ctrl;
  output emio_enet0_tsu_timer_cmp_val;
  output emio_enet1_tx_sof;
  output emio_enet1_sync_frame_tx;
  output emio_enet1_delay_req_tx;
  output emio_enet1_pdelay_req_tx;
  output emio_enet1_pdelay_resp_tx;
  output emio_enet1_rx_sof;
  output emio_enet1_sync_frame_rx;
  output emio_enet1_delay_req_rx;
  output emio_enet1_pdelay_req_rx;
  output emio_enet1_pdelay_resp_rx;
  input [1:0]emio_enet1_tsu_inc_ctrl;
  output emio_enet1_tsu_timer_cmp_val;
  output emio_enet2_tx_sof;
  output emio_enet2_sync_frame_tx;
  output emio_enet2_delay_req_tx;
  output emio_enet2_pdelay_req_tx;
  output emio_enet2_pdelay_resp_tx;
  output emio_enet2_rx_sof;
  output emio_enet2_sync_frame_rx;
  output emio_enet2_delay_req_rx;
  output emio_enet2_pdelay_req_rx;
  output emio_enet2_pdelay_resp_rx;
  input [1:0]emio_enet2_tsu_inc_ctrl;
  output emio_enet2_tsu_timer_cmp_val;
  output emio_enet3_tx_sof;
  output emio_enet3_sync_frame_tx;
  output emio_enet3_delay_req_tx;
  output emio_enet3_pdelay_req_tx;
  output emio_enet3_pdelay_resp_tx;
  output emio_enet3_rx_sof;
  output emio_enet3_sync_frame_rx;
  output emio_enet3_delay_req_rx;
  output emio_enet3_pdelay_req_rx;
  output emio_enet3_pdelay_resp_rx;
  input [1:0]emio_enet3_tsu_inc_ctrl;
  output emio_enet3_tsu_timer_cmp_val;
  input fmio_gem_tsu_clk_from_pl;
  output fmio_gem_tsu_clk_to_pl_bufg;
  input emio_enet_tsu_clk;
  output [93:0]emio_enet0_enet_tsu_timer_cnt;
  input emio_enet0_ext_int_in;
  input emio_enet1_ext_int_in;
  input emio_enet2_ext_int_in;
  input emio_enet3_ext_int_in;
  output [1:0]emio_enet0_dma_bus_width;
  output [1:0]emio_enet1_dma_bus_width;
  output [1:0]emio_enet2_dma_bus_width;
  output [1:0]emio_enet3_dma_bus_width;
  input [0:0]emio_gpio_i;
  output [0:0]emio_gpio_o;
  output [0:0]emio_gpio_t;
  output [0:0]emio_gpio_t_n;
  input emio_i2c0_scl_i;
  output emio_i2c0_scl_o;
  output emio_i2c0_scl_t_n;
  output emio_i2c0_scl_t;
  input emio_i2c0_sda_i;
  output emio_i2c0_sda_o;
  output emio_i2c0_sda_t_n;
  output emio_i2c0_sda_t;
  input emio_i2c1_scl_i;
  output emio_i2c1_scl_o;
  output emio_i2c1_scl_t;
  output emio_i2c1_scl_t_n;
  input emio_i2c1_sda_i;
  output emio_i2c1_sda_o;
  output emio_i2c1_sda_t;
  output emio_i2c1_sda_t_n;
  output emio_uart0_txd;
  input emio_uart0_rxd;
  input emio_uart0_ctsn;
  output emio_uart0_rtsn;
  input emio_uart0_dsrn;
  input emio_uart0_dcdn;
  input emio_uart0_rin;
  output emio_uart0_dtrn;
  output emio_uart1_txd;
  input emio_uart1_rxd;
  input emio_uart1_ctsn;
  output emio_uart1_rtsn;
  input emio_uart1_dsrn;
  input emio_uart1_dcdn;
  input emio_uart1_rin;
  output emio_uart1_dtrn;
  output emio_sdio0_clkout;
  input emio_sdio0_fb_clk_in;
  output emio_sdio0_cmdout;
  input emio_sdio0_cmdin;
  output emio_sdio0_cmdena;
  input [7:0]emio_sdio0_datain;
  output [7:0]emio_sdio0_dataout;
  output [7:0]emio_sdio0_dataena;
  input emio_sdio0_cd_n;
  input emio_sdio0_wp;
  output emio_sdio0_ledcontrol;
  output emio_sdio0_buspower;
  output [2:0]emio_sdio0_bus_volt;
  output emio_sdio1_clkout;
  input emio_sdio1_fb_clk_in;
  output emio_sdio1_cmdout;
  input emio_sdio1_cmdin;
  output emio_sdio1_cmdena;
  input [7:0]emio_sdio1_datain;
  output [7:0]emio_sdio1_dataout;
  output [7:0]emio_sdio1_dataena;
  input emio_sdio1_cd_n;
  input emio_sdio1_wp;
  output emio_sdio1_ledcontrol;
  output emio_sdio1_buspower;
  output [2:0]emio_sdio1_bus_volt;
  input emio_spi0_sclk_i;
  output emio_spi0_sclk_o;
  output emio_spi0_sclk_t;
  output emio_spi0_sclk_t_n;
  input emio_spi0_m_i;
  output emio_spi0_m_o;
  output emio_spi0_mo_t;
  output emio_spi0_mo_t_n;
  input emio_spi0_s_i;
  output emio_spi0_s_o;
  output emio_spi0_so_t;
  output emio_spi0_so_t_n;
  input emio_spi0_ss_i_n;
  output emio_spi0_ss_o_n;
  output emio_spi0_ss1_o_n;
  output emio_spi0_ss2_o_n;
  output emio_spi0_ss_n_t;
  output emio_spi0_ss_n_t_n;
  input emio_spi1_sclk_i;
  output emio_spi1_sclk_o;
  output emio_spi1_sclk_t;
  output emio_spi1_sclk_t_n;
  input emio_spi1_m_i;
  output emio_spi1_m_o;
  output emio_spi1_mo_t;
  output emio_spi1_mo_t_n;
  input emio_spi1_s_i;
  output emio_spi1_s_o;
  output emio_spi1_so_t;
  output emio_spi1_so_t_n;
  input emio_spi1_ss_i_n;
  output emio_spi1_ss_o_n;
  output emio_spi1_ss1_o_n;
  output emio_spi1_ss2_o_n;
  output emio_spi1_ss_n_t;
  output emio_spi1_ss_n_t_n;
  input pl_ps_trace_clk;
  output ps_pl_tracectl;
  output [31:0]ps_pl_tracedata;
  output trace_clk_out;
  output [2:0]emio_ttc0_wave_o;
  input [2:0]emio_ttc0_clk_i;
  output [2:0]emio_ttc1_wave_o;
  input [2:0]emio_ttc1_clk_i;
  output [2:0]emio_ttc2_wave_o;
  input [2:0]emio_ttc2_clk_i;
  output [2:0]emio_ttc3_wave_o;
  input [2:0]emio_ttc3_clk_i;
  input emio_wdt0_clk_i;
  output emio_wdt0_rst_o;
  input emio_wdt1_clk_i;
  output emio_wdt1_rst_o;
  input emio_hub_port_overcrnt_usb3_0;
  input emio_hub_port_overcrnt_usb3_1;
  input emio_hub_port_overcrnt_usb2_0;
  input emio_hub_port_overcrnt_usb2_1;
  output emio_u2dsport_vbus_ctrl_usb3_0;
  output emio_u2dsport_vbus_ctrl_usb3_1;
  output emio_u3dsport_vbus_ctrl_usb3_0;
  output emio_u3dsport_vbus_ctrl_usb3_1;
  input [7:0]adma_fci_clk;
  input [7:0]pl2adma_cvld;
  input [7:0]pl2adma_tack;
  output [7:0]adma2pl_cack;
  output [7:0]adma2pl_tvld;
  input [7:0]perif_gdma_clk;
  input [7:0]perif_gdma_cvld;
  input [7:0]perif_gdma_tack;
  output [7:0]gdma_perif_cack;
  output [7:0]gdma_perif_tvld;
  input [3:0]pl_clock_stop;
  input [1:0]pll_aux_refclk_lpd;
  input [2:0]pll_aux_refclk_fpd;
  input [31:0]dp_s_axis_audio_tdata;
  input dp_s_axis_audio_tid;
  input dp_s_axis_audio_tvalid;
  output dp_s_axis_audio_tready;
  output [31:0]dp_m_axis_mixed_audio_tdata;
  output dp_m_axis_mixed_audio_tid;
  output dp_m_axis_mixed_audio_tvalid;
  input dp_m_axis_mixed_audio_tready;
  input dp_s_axis_audio_clk;
  input dp_live_video_in_vsync;
  input dp_live_video_in_hsync;
  input dp_live_video_in_de;
  input [35:0]dp_live_video_in_pixel1;
  input dp_video_in_clk;
  output dp_video_out_hsync;
  output dp_video_out_vsync;
  output [35:0]dp_video_out_pixel1;
  input dp_aux_data_in;
  output dp_aux_data_out;
  output dp_aux_data_oe_n;
  input [7:0]dp_live_gfx_alpha_in;
  input [35:0]dp_live_gfx_pixel1_in;
  input dp_hot_plug_detect;
  input dp_external_custom_event1;
  input dp_external_custom_event2;
  input dp_external_vsync_event;
  output dp_live_video_de_out;
  input pl_ps_eventi;
  output ps_pl_evento;
  output [3:0]ps_pl_standbywfe;
  output [3:0]ps_pl_standbywfi;
  input [3:0]pl_ps_apugic_irq;
  input [3:0]pl_ps_apugic_fiq;
  input rpu_eventi0;
  input rpu_eventi1;
  output rpu_evento0;
  output rpu_evento1;
  input nfiq0_lpd_rpu;
  input nfiq1_lpd_rpu;
  input nirq0_lpd_rpu;
  input nirq1_lpd_rpu;
  output irq_ipi_pl_0;
  output irq_ipi_pl_1;
  output irq_ipi_pl_2;
  output irq_ipi_pl_3;
  input [59:0]stm_event;
  input pl_ps_trigack_0;
  input pl_ps_trigack_1;
  input pl_ps_trigack_2;
  input pl_ps_trigack_3;
  input pl_ps_trigger_0;
  input pl_ps_trigger_1;
  input pl_ps_trigger_2;
  input pl_ps_trigger_3;
  output ps_pl_trigack_0;
  output ps_pl_trigack_1;
  output ps_pl_trigack_2;
  output ps_pl_trigack_3;
  output ps_pl_trigger_0;
  output ps_pl_trigger_1;
  output ps_pl_trigger_2;
  output ps_pl_trigger_3;
  output [31:0]ftm_gpo;
  input [31:0]ftm_gpi;
  input [0:0]pl_ps_irq0;
  input [0:0]pl_ps_irq1;
  output pl_resetn0;
  output pl_resetn1;
  output pl_resetn2;
  output pl_resetn3;
  output ps_pl_irq_can0;
  output ps_pl_irq_can1;
  output ps_pl_irq_enet0;
  output ps_pl_irq_enet1;
  output ps_pl_irq_enet2;
  output ps_pl_irq_enet3;
  output ps_pl_irq_enet0_wake;
  output ps_pl_irq_enet1_wake;
  output ps_pl_irq_enet2_wake;
  output ps_pl_irq_enet3_wake;
  output ps_pl_irq_gpio;
  output ps_pl_irq_i2c0;
  output ps_pl_irq_i2c1;
  output ps_pl_irq_uart0;
  output ps_pl_irq_uart1;
  output ps_pl_irq_sdio0;
  output ps_pl_irq_sdio1;
  output ps_pl_irq_sdio0_wake;
  output ps_pl_irq_sdio1_wake;
  output ps_pl_irq_spi0;
  output ps_pl_irq_spi1;
  output ps_pl_irq_qspi;
  output ps_pl_irq_ttc0_0;
  output ps_pl_irq_ttc0_1;
  output ps_pl_irq_ttc0_2;
  output ps_pl_irq_ttc1_0;
  output ps_pl_irq_ttc1_1;
  output ps_pl_irq_ttc1_2;
  output ps_pl_irq_ttc2_0;
  output ps_pl_irq_ttc2_1;
  output ps_pl_irq_ttc2_2;
  output ps_pl_irq_ttc3_0;
  output ps_pl_irq_ttc3_1;
  output ps_pl_irq_ttc3_2;
  output ps_pl_irq_csu_pmu_wdt;
  output ps_pl_irq_lp_wdt;
  output [3:0]ps_pl_irq_usb3_0_endpoint;
  output ps_pl_irq_usb3_0_otg;
  output [3:0]ps_pl_irq_usb3_1_endpoint;
  output ps_pl_irq_usb3_1_otg;
  output [7:0]ps_pl_irq_adma_chan;
  output [1:0]ps_pl_irq_usb3_0_pmu_wakeup;
  output [7:0]ps_pl_irq_gdma_chan;
  output ps_pl_irq_csu;
  output ps_pl_irq_csu_dma;
  output ps_pl_irq_efuse;
  output ps_pl_irq_xmpu_lpd;
  output ps_pl_irq_ddr_ss;
  output ps_pl_irq_nand;
  output ps_pl_irq_fp_wdt;
  output [1:0]ps_pl_irq_pcie_msi;
  output ps_pl_irq_pcie_legacy;
  output ps_pl_irq_pcie_dma;
  output ps_pl_irq_pcie_msc;
  output ps_pl_irq_dport;
  output ps_pl_irq_fpd_apb_int;
  output ps_pl_irq_fpd_atb_error;
  output ps_pl_irq_dpdma;
  output ps_pl_irq_apm_fpd;
  output ps_pl_irq_gpu;
  output ps_pl_irq_sata;
  output ps_pl_irq_xmpu_fpd;
  output [3:0]ps_pl_irq_apu_cpumnt;
  output [3:0]ps_pl_irq_apu_cti;
  output [3:0]ps_pl_irq_apu_pmu;
  output [3:0]ps_pl_irq_apu_comm;
  output ps_pl_irq_apu_l2err;
  output ps_pl_irq_apu_exterr;
  output ps_pl_irq_apu_regs;
  output ps_pl_irq_intf_ppd_cci;
  output ps_pl_irq_intf_fpd_smmu;
  output ps_pl_irq_atb_err_lpd;
  output ps_pl_irq_aib_axi;
  output ps_pl_irq_ams;
  output ps_pl_irq_lpd_apm;
  output ps_pl_irq_rtc_alaram;
  output ps_pl_irq_rtc_seconds;
  output ps_pl_irq_clkmon;
  output ps_pl_irq_ipi_channel0;
  output ps_pl_irq_ipi_channel1;
  output ps_pl_irq_ipi_channel2;
  output ps_pl_irq_ipi_channel7;
  output ps_pl_irq_ipi_channel8;
  output ps_pl_irq_ipi_channel9;
  output ps_pl_irq_ipi_channel10;
  output [1:0]ps_pl_irq_rpu_pm;
  output ps_pl_irq_ocm_error;
  output ps_pl_irq_lpd_apb_intr;
  output ps_pl_irq_r5_core0_ecc_error;
  output ps_pl_irq_r5_core1_ecc_error;
  output osc_rtc_clk;
  input [31:0]pl_pmu_gpi;
  output [31:0]pmu_pl_gpo;
  input aib_pmu_afifm_fpd_ack;
  input aib_pmu_afifm_lpd_ack;
  output pmu_aib_afifm_fpd_req;
  output pmu_aib_afifm_lpd_req;
  output [46:0]pmu_error_to_pl;
  input [3:0]pmu_error_from_pl;
  input ddrc_ext_refresh_rank0_req;
  input ddrc_ext_refresh_rank1_req;
  input ddrc_refresh_pl_clk;
  input pl_acpinact;
  output pl_clk3;
  output pl_clk2;
  output pl_clk1;
  output pl_clk0;
  input [15:0]sacefpd_awuser;
  input [15:0]sacefpd_aruser;
  input [3:0]test_adc_clk;
  input [31:0]test_adc_in;
  input [31:0]test_adc2_in;
  output [15:0]test_db;
  output [19:0]test_adc_out;
  output [7:0]test_ams_osc;
  output [15:0]test_mon_data;
  input test_dclk;
  input test_den;
  input test_dwe;
  input [7:0]test_daddr;
  input [15:0]test_di;
  output test_drdy;
  output [15:0]test_do;
  input test_convst;
  input [3:0]pstp_pl_clk;
  input [31:0]pstp_pl_in;
  output [31:0]pstp_pl_out;
  input [31:0]pstp_pl_ts;
  input fmio_test_gem_scanmux_1;
  input fmio_test_gem_scanmux_2;
  input test_char_mode_fpd_n;
  input test_char_mode_lpd_n;
  input fmio_test_io_char_scan_clock;
  input fmio_test_io_char_scanenable;
  input fmio_test_io_char_scan_in;
  output fmio_test_io_char_scan_out;
  input fmio_test_io_char_scan_reset_n;
  input fmio_char_afifslpd_test_select_n;
  input fmio_char_afifslpd_test_input;
  output fmio_char_afifslpd_test_output;
  input fmio_char_afifsfpd_test_select_n;
  input fmio_char_afifsfpd_test_input;
  output fmio_char_afifsfpd_test_output;
  input io_char_audio_in_test_data;
  input io_char_audio_mux_sel_n;
  input io_char_video_in_test_data;
  input io_char_video_mux_sel_n;
  output io_char_video_out_test_data;
  output io_char_audio_out_test_data;
  input fmio_test_qspi_scanmux_1_n;
  input fmio_test_sdio_scanmux_1;
  input fmio_test_sdio_scanmux_2;
  input [3:0]fmio_sd0_dll_test_in_n;
  output [7:0]fmio_sd0_dll_test_out;
  input [3:0]fmio_sd1_dll_test_in_n;
  output [7:0]fmio_sd1_dll_test_out;
  input test_pl_scan_chopper_si;
  output test_pl_scan_chopper_so;
  input test_pl_scan_chopper_trig;
  input test_pl_scan_clk0;
  input test_pl_scan_clk1;
  input test_pl_scan_edt_clk;
  input test_pl_scan_edt_in_apu;
  input test_pl_scan_edt_in_cpu;
  input [3:0]test_pl_scan_edt_in_ddr;
  input [9:0]test_pl_scan_edt_in_fp;
  input [3:0]test_pl_scan_edt_in_gpu;
  input [8:0]test_pl_scan_edt_in_lp;
  input [1:0]test_pl_scan_edt_in_usb3;
  output test_pl_scan_edt_out_apu;
  output test_pl_scan_edt_out_cpu0;
  output test_pl_scan_edt_out_cpu1;
  output test_pl_scan_edt_out_cpu2;
  output test_pl_scan_edt_out_cpu3;
  output [3:0]test_pl_scan_edt_out_ddr;
  output [9:0]test_pl_scan_edt_out_fp;
  output [3:0]test_pl_scan_edt_out_gpu;
  output [8:0]test_pl_scan_edt_out_lp;
  output [1:0]test_pl_scan_edt_out_usb3;
  input test_pl_scan_edt_update;
  input test_pl_scan_reset_n;
  input test_pl_scanenable;
  input test_pl_scan_pll_reset;
  input test_pl_scan_spare_in0;
  input test_pl_scan_spare_in1;
  output test_pl_scan_spare_out0;
  output test_pl_scan_spare_out1;
  input test_pl_scan_wrap_clk;
  input test_pl_scan_wrap_ishift;
  input test_pl_scan_wrap_oshift;
  input test_pl_scan_slcr_config_clk;
  input test_pl_scan_slcr_config_rstn;
  input test_pl_scan_slcr_config_si;
  input test_pl_scan_spare_in2;
  input test_pl_scanenable_slcr_en;
  output [4:0]test_pl_pll_lock_out;
  output test_pl_scan_slcr_config_so;
  input [20:0]tst_rtc_calibreg_in;
  output [20:0]tst_rtc_calibreg_out;
  input tst_rtc_calibreg_we;
  input tst_rtc_clk;
  output tst_rtc_osc_clk_out;
  output [31:0]tst_rtc_sec_counter_out;
  output tst_rtc_seconds_raw_int;
  input tst_rtc_testclock_select_n;
  output [15:0]tst_rtc_tick_counter_out;
  input [31:0]tst_rtc_timesetreg_in;
  output [31:0]tst_rtc_timesetreg_out;
  input tst_rtc_disable_bat_op;
  input [3:0]tst_rtc_osc_cntrl_in;
  output [3:0]tst_rtc_osc_cntrl_out;
  input tst_rtc_osc_cntrl_we;
  input tst_rtc_sec_reload;
  input tst_rtc_timesetreg_we;
  input tst_rtc_testmode_n;
  input test_usb0_funcmux_0_n;
  input test_usb1_funcmux_0_n;
  input test_usb0_scanmux_0_n;
  input test_usb1_scanmux_0_n;
  output [31:0]lpd_pll_test_out;
  input [2:0]pl_lpd_pll_test_ck_sel_n;
  input pl_lpd_pll_test_fract_clk_sel_n;
  input pl_lpd_pll_test_fract_en_n;
  input pl_lpd_pll_test_mux_sel;
  input [3:0]pl_lpd_pll_test_sel;
  output [31:0]fpd_pll_test_out;
  input [2:0]pl_fpd_pll_test_ck_sel_n;
  input pl_fpd_pll_test_fract_clk_sel_n;
  input pl_fpd_pll_test_fract_en_n;
  input [1:0]pl_fpd_pll_test_mux_sel;
  input [3:0]pl_fpd_pll_test_sel;
  input [1:0]fmio_char_gem_selection;
  input fmio_char_gem_test_select_n;
  input fmio_char_gem_test_input;
  output fmio_char_gem_test_output;
  output test_ddr2pl_dcd_skewout;
  input test_pl2ddr_dcd_sample_pulse;
  input test_bscan_en_n;
  input test_bscan_tdi;
  input test_bscan_updatedr;
  input test_bscan_shiftdr;
  input test_bscan_reset_tap_b;
  input test_bscan_misr_jtag_load;
  input test_bscan_intest;
  input test_bscan_extest;
  input test_bscan_clockdr;
  input test_bscan_ac_mode;
  input test_bscan_ac_test;
  input test_bscan_init_memory;
  input test_bscan_mode_c;
  output test_bscan_tdo;
  input i_dbg_l0_txclk;
  input i_dbg_l0_rxclk;
  input i_dbg_l1_txclk;
  input i_dbg_l1_rxclk;
  input i_dbg_l2_txclk;
  input i_dbg_l2_rxclk;
  input i_dbg_l3_txclk;
  input i_dbg_l3_rxclk;
  input i_afe_rx_symbol_clk_by_2_pl;
  input pl_fpd_spare_0_in;
  input pl_fpd_spare_1_in;
  input pl_fpd_spare_2_in;
  input pl_fpd_spare_3_in;
  input pl_fpd_spare_4_in;
  output fpd_pl_spare_0_out;
  output fpd_pl_spare_1_out;
  output fpd_pl_spare_2_out;
  output fpd_pl_spare_3_out;
  output fpd_pl_spare_4_out;
  input pl_lpd_spare_0_in;
  input pl_lpd_spare_1_in;
  input pl_lpd_spare_2_in;
  input pl_lpd_spare_3_in;
  input pl_lpd_spare_4_in;
  output lpd_pl_spare_0_out;
  output lpd_pl_spare_1_out;
  output lpd_pl_spare_2_out;
  output lpd_pl_spare_3_out;
  output lpd_pl_spare_4_out;
  output o_dbg_l0_phystatus;
  output [19:0]o_dbg_l0_rxdata;
  output [1:0]o_dbg_l0_rxdatak;
  output o_dbg_l0_rxvalid;
  output [2:0]o_dbg_l0_rxstatus;
  output o_dbg_l0_rxelecidle;
  output o_dbg_l0_rstb;
  output [19:0]o_dbg_l0_txdata;
  output [1:0]o_dbg_l0_txdatak;
  output [1:0]o_dbg_l0_rate;
  output [1:0]o_dbg_l0_powerdown;
  output o_dbg_l0_txelecidle;
  output o_dbg_l0_txdetrx_lpback;
  output o_dbg_l0_rxpolarity;
  output o_dbg_l0_tx_sgmii_ewrap;
  output o_dbg_l0_rx_sgmii_en_cdet;
  output [19:0]o_dbg_l0_sata_corerxdata;
  output [1:0]o_dbg_l0_sata_corerxdatavalid;
  output o_dbg_l0_sata_coreready;
  output o_dbg_l0_sata_coreclockready;
  output o_dbg_l0_sata_corerxsignaldet;
  output [19:0]o_dbg_l0_sata_phyctrltxdata;
  output o_dbg_l0_sata_phyctrltxidle;
  output [1:0]o_dbg_l0_sata_phyctrltxrate;
  output [1:0]o_dbg_l0_sata_phyctrlrxrate;
  output o_dbg_l0_sata_phyctrltxrst;
  output o_dbg_l0_sata_phyctrlrxrst;
  output o_dbg_l0_sata_phyctrlreset;
  output o_dbg_l0_sata_phyctrlpartial;
  output o_dbg_l0_sata_phyctrlslumber;
  output o_dbg_l1_phystatus;
  output [19:0]o_dbg_l1_rxdata;
  output [1:0]o_dbg_l1_rxdatak;
  output o_dbg_l1_rxvalid;
  output [2:0]o_dbg_l1_rxstatus;
  output o_dbg_l1_rxelecidle;
  output o_dbg_l1_rstb;
  output [19:0]o_dbg_l1_txdata;
  output [1:0]o_dbg_l1_txdatak;
  output [1:0]o_dbg_l1_rate;
  output [1:0]o_dbg_l1_powerdown;
  output o_dbg_l1_txelecidle;
  output o_dbg_l1_txdetrx_lpback;
  output o_dbg_l1_rxpolarity;
  output o_dbg_l1_tx_sgmii_ewrap;
  output o_dbg_l1_rx_sgmii_en_cdet;
  output [19:0]o_dbg_l1_sata_corerxdata;
  output [1:0]o_dbg_l1_sata_corerxdatavalid;
  output o_dbg_l1_sata_coreready;
  output o_dbg_l1_sata_coreclockready;
  output o_dbg_l1_sata_corerxsignaldet;
  output [19:0]o_dbg_l1_sata_phyctrltxdata;
  output o_dbg_l1_sata_phyctrltxidle;
  output [1:0]o_dbg_l1_sata_phyctrltxrate;
  output [1:0]o_dbg_l1_sata_phyctrlrxrate;
  output o_dbg_l1_sata_phyctrltxrst;
  output o_dbg_l1_sata_phyctrlrxrst;
  output o_dbg_l1_sata_phyctrlreset;
  output o_dbg_l1_sata_phyctrlpartial;
  output o_dbg_l1_sata_phyctrlslumber;
  output o_dbg_l2_phystatus;
  output [19:0]o_dbg_l2_rxdata;
  output [1:0]o_dbg_l2_rxdatak;
  output o_dbg_l2_rxvalid;
  output [2:0]o_dbg_l2_rxstatus;
  output o_dbg_l2_rxelecidle;
  output o_dbg_l2_rstb;
  output [19:0]o_dbg_l2_txdata;
  output [1:0]o_dbg_l2_txdatak;
  output [1:0]o_dbg_l2_rate;
  output [1:0]o_dbg_l2_powerdown;
  output o_dbg_l2_txelecidle;
  output o_dbg_l2_txdetrx_lpback;
  output o_dbg_l2_rxpolarity;
  output o_dbg_l2_tx_sgmii_ewrap;
  output o_dbg_l2_rx_sgmii_en_cdet;
  output [19:0]o_dbg_l2_sata_corerxdata;
  output [1:0]o_dbg_l2_sata_corerxdatavalid;
  output o_dbg_l2_sata_coreready;
  output o_dbg_l2_sata_coreclockready;
  output o_dbg_l2_sata_corerxsignaldet;
  output [19:0]o_dbg_l2_sata_phyctrltxdata;
  output o_dbg_l2_sata_phyctrltxidle;
  output [1:0]o_dbg_l2_sata_phyctrltxrate;
  output [1:0]o_dbg_l2_sata_phyctrlrxrate;
  output o_dbg_l2_sata_phyctrltxrst;
  output o_dbg_l2_sata_phyctrlrxrst;
  output o_dbg_l2_sata_phyctrlreset;
  output o_dbg_l2_sata_phyctrlpartial;
  output o_dbg_l2_sata_phyctrlslumber;
  output o_dbg_l3_phystatus;
  output [19:0]o_dbg_l3_rxdata;
  output [1:0]o_dbg_l3_rxdatak;
  output o_dbg_l3_rxvalid;
  output [2:0]o_dbg_l3_rxstatus;
  output o_dbg_l3_rxelecidle;
  output o_dbg_l3_rstb;
  output [19:0]o_dbg_l3_txdata;
  output [1:0]o_dbg_l3_txdatak;
  output [1:0]o_dbg_l3_rate;
  output [1:0]o_dbg_l3_powerdown;
  output o_dbg_l3_txelecidle;
  output o_dbg_l3_txdetrx_lpback;
  output o_dbg_l3_rxpolarity;
  output o_dbg_l3_tx_sgmii_ewrap;
  output o_dbg_l3_rx_sgmii_en_cdet;
  output [19:0]o_dbg_l3_sata_corerxdata;
  output [1:0]o_dbg_l3_sata_corerxdatavalid;
  output o_dbg_l3_sata_coreready;
  output o_dbg_l3_sata_coreclockready;
  output o_dbg_l3_sata_corerxsignaldet;
  output [19:0]o_dbg_l3_sata_phyctrltxdata;
  output o_dbg_l3_sata_phyctrltxidle;
  output [1:0]o_dbg_l3_sata_phyctrltxrate;
  output [1:0]o_dbg_l3_sata_phyctrlrxrate;
  output o_dbg_l3_sata_phyctrltxrst;
  output o_dbg_l3_sata_phyctrlrxrst;
  output o_dbg_l3_sata_phyctrlreset;
  output o_dbg_l3_sata_phyctrlpartial;
  output o_dbg_l3_sata_phyctrlslumber;
  output dbg_path_fifo_bypass;
  input i_afe_pll_pd_hs_clock_r;
  input i_afe_mode;
  input i_bgcal_afe_mode;
  output o_afe_cmn_calib_comp_out;
  input i_afe_cmn_bg_enable_low_leakage;
  input i_afe_cmn_bg_iso_ctrl_bar;
  input i_afe_cmn_bg_pd;
  input i_afe_cmn_bg_pd_bg_ok;
  input i_afe_cmn_bg_pd_ptat;
  input i_afe_cmn_calib_en_iconst;
  input i_afe_cmn_calib_enable_low_leakage;
  input i_afe_cmn_calib_iso_ctrl_bar;
  output [12:0]o_afe_pll_dco_count;
  output o_afe_pll_clk_sym_hs;
  output o_afe_pll_fbclk_frac;
  output o_afe_rx_pipe_lfpsbcn_rxelecidle;
  output o_afe_rx_pipe_sigdet;
  output [19:0]o_afe_rx_symbol;
  output o_afe_rx_symbol_clk_by_2;
  output o_afe_rx_uphy_save_calcode;
  output o_afe_rx_uphy_startloop_buf;
  output o_afe_rx_uphy_rx_calib_done;
  input i_afe_rx_rxpma_rstb;
  input [7:0]i_afe_rx_uphy_restore_calcode_data;
  input i_afe_rx_pipe_rxeqtraining;
  input i_afe_rx_iso_hsrx_ctrl_bar;
  input i_afe_rx_iso_lfps_ctrl_bar;
  input i_afe_rx_iso_sigdet_ctrl_bar;
  input i_afe_rx_hsrx_clock_stop_req;
  output [7:0]o_afe_rx_uphy_save_calcode_data;
  output o_afe_rx_hsrx_clock_stop_ack;
  output o_afe_pg_avddcr;
  output o_afe_pg_avddio;
  output o_afe_pg_dvddcr;
  output o_afe_pg_static_avddcr;
  output o_afe_pg_static_avddio;
  input i_pll_afe_mode;
  input [10:0]i_afe_pll_coarse_code;
  input i_afe_pll_en_clock_hs_div2;
  input [15:0]i_afe_pll_fbdiv;
  input i_afe_pll_load_fbdiv;
  input i_afe_pll_pd;
  input i_afe_pll_pd_pfd;
  input i_afe_pll_rst_fdbk_div;
  input i_afe_pll_startloop;
  input [5:0]i_afe_pll_v2i_code;
  input [4:0]i_afe_pll_v2i_prog;
  input i_afe_pll_vco_cnt_window;
  input i_afe_rx_mphy_gate_symbol_clk;
  input i_afe_rx_mphy_mux_hsb_ls;
  input i_afe_rx_pipe_rx_term_enable;
  input i_afe_rx_uphy_biasgen_iconst_core_mirror_enable;
  input i_afe_rx_uphy_biasgen_iconst_io_mirror_enable;
  input i_afe_rx_uphy_biasgen_irconst_core_mirror_enable;
  input i_afe_rx_uphy_enable_cdr;
  input i_afe_rx_uphy_enable_low_leakage;
  input i_afe_rx_rxpma_refclk_dig;
  input i_afe_rx_uphy_hsrx_rstb;
  input i_afe_rx_uphy_pdn_hs_des;
  input i_afe_rx_uphy_pd_samp_c2c;
  input i_afe_rx_uphy_pd_samp_c2c_eclk;
  input i_afe_rx_uphy_pso_clk_lane;
  input i_afe_rx_uphy_pso_eq;
  input i_afe_rx_uphy_pso_hsrxdig;
  input i_afe_rx_uphy_pso_iqpi;
  input i_afe_rx_uphy_pso_lfpsbcn;
  input i_afe_rx_uphy_pso_samp_flops;
  input i_afe_rx_uphy_pso_sigdet;
  input i_afe_rx_uphy_restore_calcode;
  input i_afe_rx_uphy_run_calib;
  input i_afe_rx_uphy_rx_lane_polarity_swap;
  input i_afe_rx_uphy_startloop_pll;
  input [1:0]i_afe_rx_uphy_hsclk_division_factor;
  input [7:0]i_afe_rx_uphy_rx_pma_opmode;
  input [1:0]i_afe_tx_enable_hsclk_division;
  input i_afe_tx_enable_ldo;
  input i_afe_tx_enable_ref;
  input i_afe_tx_enable_supply_hsclk;
  input i_afe_tx_enable_supply_pipe;
  input i_afe_tx_enable_supply_serializer;
  input i_afe_tx_enable_supply_uphy;
  input i_afe_tx_hs_ser_rstb;
  input [19:0]i_afe_tx_hs_symbol;
  input i_afe_tx_mphy_tx_ls_data;
  input [1:0]i_afe_tx_pipe_tx_enable_idle_mode;
  input [1:0]i_afe_tx_pipe_tx_enable_lfps;
  input i_afe_tx_pipe_tx_enable_rxdet;
  input [7:0]i_afe_TX_uphy_txpma_opmode;
  input i_afe_TX_pmadig_digital_reset_n;
  input i_afe_TX_serializer_rst_rel;
  input i_afe_TX_pll_symb_clk_2;
  input [1:0]i_afe_TX_ana_if_rate;
  input i_afe_TX_en_dig_sublp_mode;
  input [2:0]i_afe_TX_LPBK_SEL;
  input i_afe_TX_iso_ctrl_bar;
  input i_afe_TX_ser_iso_ctrl_bar;
  input i_afe_TX_lfps_clk;
  input i_afe_TX_serializer_rstb;
  output o_afe_TX_dig_reset_rel_ack;
  output o_afe_TX_pipe_TX_dn_rxdet;
  output o_afe_TX_pipe_TX_dp_rxdet;
  input i_afe_tx_pipe_tx_fast_est_common_mode;
  output o_dbg_l0_txclk;
  output o_dbg_l0_rxclk;
  output o_dbg_l1_txclk;
  output o_dbg_l1_rxclk;
  output o_dbg_l2_txclk;
  output o_dbg_l2_rxclk;
  output o_dbg_l3_txclk;
  output o_dbg_l3_rxclk;

  wire \<const0> ;
  wire \<const1> ;
  wire [7:0]adma2pl_cack;
  wire [7:0]adma2pl_tvld;
  wire [7:0]adma_fci_clk;
  wire aib_pmu_afifm_fpd_ack;
  wire aib_pmu_afifm_lpd_ack;
  wire ddrc_ext_refresh_rank0_req;
  wire ddrc_ext_refresh_rank1_req;
  wire ddrc_refresh_pl_clk;
  wire dp_aux_data_in;
  wire dp_aux_data_oe_n;
  wire dp_aux_data_out;
  wire dp_external_custom_event1;
  wire dp_external_custom_event2;
  wire dp_external_vsync_event;
  wire dp_hot_plug_detect;
  wire [7:0]dp_live_gfx_alpha_in;
  wire [35:0]dp_live_gfx_pixel1_in;
  wire dp_live_video_de_out;
  wire dp_live_video_in_de;
  wire dp_live_video_in_hsync;
  wire [35:0]dp_live_video_in_pixel1;
  wire dp_live_video_in_vsync;
  wire [31:0]dp_m_axis_mixed_audio_tdata;
  wire dp_m_axis_mixed_audio_tid;
  wire dp_m_axis_mixed_audio_tready;
  wire dp_m_axis_mixed_audio_tvalid;
  wire dp_s_axis_audio_clk;
  wire [31:0]dp_s_axis_audio_tdata;
  wire dp_s_axis_audio_tid;
  wire dp_s_axis_audio_tready;
  wire dp_s_axis_audio_tvalid;
  wire dp_video_in_clk;
  wire dp_video_out_hsync;
  wire [35:0]dp_video_out_pixel1;
  wire dp_video_out_vsync;
  wire dp_video_ref_clk;
  wire emio_can0_phy_rx;
  wire emio_can0_phy_tx;
  wire emio_can1_phy_rx;
  wire emio_can1_phy_tx;
  wire emio_enet0_delay_req_rx;
  wire emio_enet0_delay_req_tx;
  wire [1:0]emio_enet0_dma_bus_width;
  wire emio_enet0_dma_tx_end_tog;
  wire emio_enet0_dma_tx_status_tog;
  wire [93:0]emio_enet0_enet_tsu_timer_cnt;
  wire emio_enet0_ext_int_in;
  wire emio_enet0_gmii_col;
  wire emio_enet0_gmii_crs;
  wire emio_enet0_gmii_rx_clk;
  wire emio_enet0_gmii_rx_dv;
  wire emio_enet0_gmii_rx_er;
  wire [7:0]emio_enet0_gmii_rxd;
  wire emio_enet0_gmii_tx_clk;
  wire emio_enet0_gmii_tx_en;
  wire emio_enet0_gmii_tx_er;
  wire [7:0]emio_enet0_gmii_txd;
  wire emio_enet0_mdio_i;
  wire emio_enet0_mdio_mdc;
  wire emio_enet0_mdio_o;
  wire emio_enet0_mdio_t;
  wire emio_enet0_mdio_t_n;
  wire emio_enet0_pdelay_req_rx;
  wire emio_enet0_pdelay_req_tx;
  wire emio_enet0_pdelay_resp_rx;
  wire emio_enet0_pdelay_resp_tx;
  wire emio_enet0_rx_sof;
  wire [7:0]emio_enet0_rx_w_data;
  wire emio_enet0_rx_w_eop;
  wire emio_enet0_rx_w_err;
  wire emio_enet0_rx_w_flush;
  wire emio_enet0_rx_w_overflow;
  wire emio_enet0_rx_w_sop;
  wire [44:0]emio_enet0_rx_w_status;
  wire emio_enet0_rx_w_wr;
  wire emio_enet0_signal_detect;
  wire [2:0]emio_enet0_speed_mode;
  wire emio_enet0_sync_frame_rx;
  wire emio_enet0_sync_frame_tx;
  wire [1:0]emio_enet0_tsu_inc_ctrl;
  wire emio_enet0_tsu_timer_cmp_val;
  wire emio_enet0_tx_r_control;
  wire [7:0]emio_enet0_tx_r_data;
  wire emio_enet0_tx_r_data_rdy;
  wire emio_enet0_tx_r_eop;
  wire emio_enet0_tx_r_err;
  wire emio_enet0_tx_r_fixed_lat;
  wire emio_enet0_tx_r_flushed;
  wire emio_enet0_tx_r_rd;
  wire emio_enet0_tx_r_sop;
  wire [3:0]emio_enet0_tx_r_status;
  wire emio_enet0_tx_r_underflow;
  wire emio_enet0_tx_r_valid;
  wire emio_enet0_tx_sof;
  wire emio_enet1_delay_req_rx;
  wire emio_enet1_delay_req_tx;
  wire [1:0]emio_enet1_dma_bus_width;
  wire emio_enet1_dma_tx_end_tog;
  wire emio_enet1_dma_tx_status_tog;
  wire emio_enet1_ext_int_in;
  wire emio_enet1_gmii_col;
  wire emio_enet1_gmii_crs;
  wire emio_enet1_gmii_rx_clk;
  wire emio_enet1_gmii_rx_dv;
  wire emio_enet1_gmii_rx_er;
  wire [7:0]emio_enet1_gmii_rxd;
  wire emio_enet1_gmii_tx_clk;
  wire emio_enet1_gmii_tx_en;
  wire emio_enet1_gmii_tx_er;
  wire [7:0]emio_enet1_gmii_txd;
  wire emio_enet1_mdio_i;
  wire emio_enet1_mdio_mdc;
  wire emio_enet1_mdio_o;
  wire emio_enet1_mdio_t;
  wire emio_enet1_mdio_t_n;
  wire emio_enet1_pdelay_req_rx;
  wire emio_enet1_pdelay_req_tx;
  wire emio_enet1_pdelay_resp_rx;
  wire emio_enet1_pdelay_resp_tx;
  wire emio_enet1_rx_sof;
  wire [7:0]emio_enet1_rx_w_data;
  wire emio_enet1_rx_w_eop;
  wire emio_enet1_rx_w_err;
  wire emio_enet1_rx_w_flush;
  wire emio_enet1_rx_w_overflow;
  wire emio_enet1_rx_w_sop;
  wire [44:0]emio_enet1_rx_w_status;
  wire emio_enet1_rx_w_wr;
  wire emio_enet1_signal_detect;
  wire [2:0]emio_enet1_speed_mode;
  wire emio_enet1_sync_frame_rx;
  wire emio_enet1_sync_frame_tx;
  wire [1:0]emio_enet1_tsu_inc_ctrl;
  wire emio_enet1_tsu_timer_cmp_val;
  wire emio_enet1_tx_r_control;
  wire [7:0]emio_enet1_tx_r_data;
  wire emio_enet1_tx_r_data_rdy;
  wire emio_enet1_tx_r_eop;
  wire emio_enet1_tx_r_err;
  wire emio_enet1_tx_r_fixed_lat;
  wire emio_enet1_tx_r_flushed;
  wire emio_enet1_tx_r_rd;
  wire emio_enet1_tx_r_sop;
  wire [3:0]emio_enet1_tx_r_status;
  wire emio_enet1_tx_r_underflow;
  wire emio_enet1_tx_r_valid;
  wire emio_enet1_tx_sof;
  wire emio_enet2_delay_req_rx;
  wire emio_enet2_delay_req_tx;
  wire [1:0]emio_enet2_dma_bus_width;
  wire emio_enet2_dma_tx_end_tog;
  wire emio_enet2_dma_tx_status_tog;
  wire emio_enet2_ext_int_in;
  wire emio_enet2_gmii_col;
  wire emio_enet2_gmii_crs;
  wire emio_enet2_gmii_rx_clk;
  wire emio_enet2_gmii_rx_dv;
  wire emio_enet2_gmii_rx_er;
  wire [7:0]emio_enet2_gmii_rxd;
  wire emio_enet2_gmii_tx_clk;
  wire emio_enet2_gmii_tx_en;
  wire emio_enet2_gmii_tx_er;
  wire [7:0]emio_enet2_gmii_txd;
  wire emio_enet2_mdio_i;
  wire emio_enet2_mdio_mdc;
  wire emio_enet2_mdio_o;
  wire emio_enet2_mdio_t;
  wire emio_enet2_mdio_t_n;
  wire emio_enet2_pdelay_req_rx;
  wire emio_enet2_pdelay_req_tx;
  wire emio_enet2_pdelay_resp_rx;
  wire emio_enet2_pdelay_resp_tx;
  wire emio_enet2_rx_sof;
  wire [7:0]emio_enet2_rx_w_data;
  wire emio_enet2_rx_w_eop;
  wire emio_enet2_rx_w_err;
  wire emio_enet2_rx_w_flush;
  wire emio_enet2_rx_w_overflow;
  wire emio_enet2_rx_w_sop;
  wire [44:0]emio_enet2_rx_w_status;
  wire emio_enet2_rx_w_wr;
  wire emio_enet2_signal_detect;
  wire [2:0]emio_enet2_speed_mode;
  wire emio_enet2_sync_frame_rx;
  wire emio_enet2_sync_frame_tx;
  wire [1:0]emio_enet2_tsu_inc_ctrl;
  wire emio_enet2_tsu_timer_cmp_val;
  wire emio_enet2_tx_r_control;
  wire [7:0]emio_enet2_tx_r_data;
  wire emio_enet2_tx_r_data_rdy;
  wire emio_enet2_tx_r_eop;
  wire emio_enet2_tx_r_err;
  wire emio_enet2_tx_r_fixed_lat;
  wire emio_enet2_tx_r_flushed;
  wire emio_enet2_tx_r_rd;
  wire emio_enet2_tx_r_sop;
  wire [3:0]emio_enet2_tx_r_status;
  wire emio_enet2_tx_r_underflow;
  wire emio_enet2_tx_r_valid;
  wire emio_enet2_tx_sof;
  wire emio_enet3_delay_req_rx;
  wire emio_enet3_delay_req_tx;
  wire [1:0]emio_enet3_dma_bus_width;
  wire emio_enet3_dma_tx_end_tog;
  wire emio_enet3_dma_tx_status_tog;
  wire emio_enet3_ext_int_in;
  wire emio_enet3_gmii_col;
  wire emio_enet3_gmii_crs;
  wire emio_enet3_gmii_rx_clk;
  wire emio_enet3_gmii_rx_dv;
  wire emio_enet3_gmii_rx_er;
  wire [7:0]emio_enet3_gmii_rxd;
  wire emio_enet3_gmii_tx_clk;
  wire emio_enet3_gmii_tx_en;
  wire emio_enet3_gmii_tx_er;
  wire [7:0]emio_enet3_gmii_txd;
  wire emio_enet3_mdio_i;
  wire emio_enet3_mdio_mdc;
  wire emio_enet3_mdio_o;
  wire emio_enet3_mdio_t;
  wire emio_enet3_mdio_t_n;
  wire emio_enet3_pdelay_req_rx;
  wire emio_enet3_pdelay_req_tx;
  wire emio_enet3_pdelay_resp_rx;
  wire emio_enet3_pdelay_resp_tx;
  wire emio_enet3_rx_sof;
  wire [7:0]emio_enet3_rx_w_data;
  wire emio_enet3_rx_w_eop;
  wire emio_enet3_rx_w_err;
  wire emio_enet3_rx_w_flush;
  wire emio_enet3_rx_w_overflow;
  wire emio_enet3_rx_w_sop;
  wire [44:0]emio_enet3_rx_w_status;
  wire emio_enet3_rx_w_wr;
  wire emio_enet3_signal_detect;
  wire [2:0]emio_enet3_speed_mode;
  wire emio_enet3_sync_frame_rx;
  wire emio_enet3_sync_frame_tx;
  wire [1:0]emio_enet3_tsu_inc_ctrl;
  wire emio_enet3_tsu_timer_cmp_val;
  wire emio_enet3_tx_r_control;
  wire [7:0]emio_enet3_tx_r_data;
  wire emio_enet3_tx_r_data_rdy;
  wire emio_enet3_tx_r_eop;
  wire emio_enet3_tx_r_err;
  wire emio_enet3_tx_r_fixed_lat;
  wire emio_enet3_tx_r_flushed;
  wire emio_enet3_tx_r_rd;
  wire emio_enet3_tx_r_sop;
  wire [3:0]emio_enet3_tx_r_status;
  wire emio_enet3_tx_r_underflow;
  wire emio_enet3_tx_r_valid;
  wire emio_enet3_tx_sof;
  wire emio_enet_tsu_clk;
  wire [0:0]emio_gpio_i;
  wire [0:0]emio_gpio_o;
  wire [0:0]emio_gpio_t;
  wire [0:0]emio_gpio_t_n;
  wire emio_hub_port_overcrnt_usb2_0;
  wire emio_hub_port_overcrnt_usb2_1;
  wire emio_hub_port_overcrnt_usb3_0;
  wire emio_hub_port_overcrnt_usb3_1;
  wire emio_i2c0_scl_i;
  wire emio_i2c0_scl_o;
  wire emio_i2c0_scl_t;
  wire emio_i2c0_scl_t_n;
  wire emio_i2c0_sda_i;
  wire emio_i2c0_sda_o;
  wire emio_i2c0_sda_t;
  wire emio_i2c0_sda_t_n;
  wire emio_i2c1_scl_i;
  wire emio_i2c1_scl_o;
  wire emio_i2c1_scl_t;
  wire emio_i2c1_scl_t_n;
  wire emio_i2c1_sda_i;
  wire emio_i2c1_sda_o;
  wire emio_i2c1_sda_t;
  wire emio_i2c1_sda_t_n;
  wire [2:0]emio_sdio0_bus_volt;
  wire emio_sdio0_buspower;
  wire emio_sdio0_cd_n;
  wire emio_sdio0_clkout;
  wire emio_sdio0_cmdena;
  wire emio_sdio0_cmdena_i;
  wire emio_sdio0_cmdin;
  wire emio_sdio0_cmdout;
  wire [7:0]emio_sdio0_dataena;
  wire [7:0]emio_sdio0_dataena_i;
  wire [7:0]emio_sdio0_datain;
  wire [7:0]emio_sdio0_dataout;
  wire emio_sdio0_fb_clk_in;
  wire emio_sdio0_ledcontrol;
  wire emio_sdio0_wp;
  wire [2:0]emio_sdio1_bus_volt;
  wire emio_sdio1_buspower;
  wire emio_sdio1_cd_n;
  wire emio_sdio1_clkout;
  wire emio_sdio1_cmdena;
  wire emio_sdio1_cmdena_i;
  wire emio_sdio1_cmdin;
  wire emio_sdio1_cmdout;
  wire [7:0]emio_sdio1_dataena;
  wire [7:0]emio_sdio1_dataena_i;
  wire [7:0]emio_sdio1_datain;
  wire [7:0]emio_sdio1_dataout;
  wire emio_sdio1_fb_clk_in;
  wire emio_sdio1_ledcontrol;
  wire emio_sdio1_wp;
  wire emio_spi0_m_i;
  wire emio_spi0_m_o;
  wire emio_spi0_mo_t;
  wire emio_spi0_mo_t_n;
  wire emio_spi0_s_i;
  wire emio_spi0_s_o;
  wire emio_spi0_sclk_i;
  wire emio_spi0_sclk_o;
  wire emio_spi0_sclk_t;
  wire emio_spi0_sclk_t_n;
  wire emio_spi0_so_t;
  wire emio_spi0_so_t_n;
  wire emio_spi0_ss1_o_n;
  wire emio_spi0_ss2_o_n;
  wire emio_spi0_ss_i_n;
  wire emio_spi0_ss_n_t;
  wire emio_spi0_ss_n_t_n;
  wire emio_spi0_ss_o_n;
  wire emio_spi1_m_i;
  wire emio_spi1_m_o;
  wire emio_spi1_mo_t;
  wire emio_spi1_mo_t_n;
  wire emio_spi1_s_i;
  wire emio_spi1_s_o;
  wire emio_spi1_sclk_i;
  wire emio_spi1_sclk_o;
  wire emio_spi1_sclk_t;
  wire emio_spi1_sclk_t_n;
  wire emio_spi1_so_t;
  wire emio_spi1_so_t_n;
  wire emio_spi1_ss1_o_n;
  wire emio_spi1_ss2_o_n;
  wire emio_spi1_ss_i_n;
  wire emio_spi1_ss_n_t;
  wire emio_spi1_ss_n_t_n;
  wire emio_spi1_ss_o_n;
  wire [2:0]emio_ttc0_clk_i;
  wire [2:0]emio_ttc0_wave_o;
  wire [2:0]emio_ttc1_clk_i;
  wire [2:0]emio_ttc1_wave_o;
  wire [2:0]emio_ttc2_clk_i;
  wire [2:0]emio_ttc2_wave_o;
  wire [2:0]emio_ttc3_clk_i;
  wire [2:0]emio_ttc3_wave_o;
  wire emio_u2dsport_vbus_ctrl_usb3_0;
  wire emio_u2dsport_vbus_ctrl_usb3_1;
  wire emio_u3dsport_vbus_ctrl_usb3_0;
  wire emio_u3dsport_vbus_ctrl_usb3_1;
  wire emio_uart0_ctsn;
  wire emio_uart0_dcdn;
  wire emio_uart0_dsrn;
  wire emio_uart0_dtrn;
  wire emio_uart0_rin;
  wire emio_uart0_rtsn;
  wire emio_uart0_rxd;
  wire emio_uart0_txd;
  wire emio_uart1_ctsn;
  wire emio_uart1_dcdn;
  wire emio_uart1_dsrn;
  wire emio_uart1_dtrn;
  wire emio_uart1_rin;
  wire emio_uart1_rtsn;
  wire emio_uart1_rxd;
  wire emio_uart1_txd;
  wire emio_wdt0_clk_i;
  wire emio_wdt0_rst_o;
  wire emio_wdt1_clk_i;
  wire emio_wdt1_rst_o;
  wire fmio_gem0_fifo_rx_clk_to_pl_bufg;
  wire fmio_gem0_fifo_tx_clk_to_pl_bufg;
  wire fmio_gem1_fifo_rx_clk_to_pl_bufg;
  wire fmio_gem1_fifo_tx_clk_to_pl_bufg;
  wire fmio_gem2_fifo_rx_clk_to_pl_bufg;
  wire fmio_gem2_fifo_tx_clk_to_pl_bufg;
  wire fmio_gem3_fifo_rx_clk_to_pl_bufg;
  wire fmio_gem3_fifo_tx_clk_to_pl_bufg;
  wire fmio_gem_tsu_clk_from_pl;
  wire fmio_gem_tsu_clk_to_pl_bufg;
  wire [31:0]ftm_gpi;
  wire [31:0]ftm_gpo;
  wire [7:0]gdma_perif_cack;
  wire [7:0]gdma_perif_tvld;
  wire [39:0]maxigp0_araddr;
  wire [1:0]maxigp0_arburst;
  wire [3:0]maxigp0_arcache;
  wire [15:0]maxigp0_arid;
  wire [7:0]maxigp0_arlen;
  wire maxigp0_arlock;
  wire [2:0]maxigp0_arprot;
  wire [3:0]maxigp0_arqos;
  wire maxigp0_arready;
  wire [2:0]maxigp0_arsize;
  wire [15:0]maxigp0_aruser;
  wire maxigp0_arvalid;
  wire [39:0]maxigp0_awaddr;
  wire [1:0]maxigp0_awburst;
  wire [3:0]maxigp0_awcache;
  wire [15:0]maxigp0_awid;
  wire [7:0]maxigp0_awlen;
  wire maxigp0_awlock;
  wire [2:0]maxigp0_awprot;
  wire [3:0]maxigp0_awqos;
  wire maxigp0_awready;
  wire [2:0]maxigp0_awsize;
  wire [15:0]maxigp0_awuser;
  wire maxigp0_awvalid;
  wire [15:0]maxigp0_bid;
  wire maxigp0_bready;
  wire [1:0]maxigp0_bresp;
  wire maxigp0_bvalid;
  wire [31:0]maxigp0_rdata;
  wire [15:0]maxigp0_rid;
  wire maxigp0_rlast;
  wire maxigp0_rready;
  wire [1:0]maxigp0_rresp;
  wire maxigp0_rvalid;
  wire [31:0]maxigp0_wdata;
  wire maxigp0_wlast;
  wire maxigp0_wready;
  wire [3:0]maxigp0_wstrb;
  wire maxigp0_wvalid;
  wire [39:0]maxigp1_araddr;
  wire [1:0]maxigp1_arburst;
  wire [3:0]maxigp1_arcache;
  wire [15:0]maxigp1_arid;
  wire [7:0]maxigp1_arlen;
  wire maxigp1_arlock;
  wire [2:0]maxigp1_arprot;
  wire [3:0]maxigp1_arqos;
  wire maxigp1_arready;
  wire [2:0]maxigp1_arsize;
  wire [15:0]maxigp1_aruser;
  wire maxigp1_arvalid;
  wire [39:0]maxigp1_awaddr;
  wire [1:0]maxigp1_awburst;
  wire [3:0]maxigp1_awcache;
  wire [15:0]maxigp1_awid;
  wire [7:0]maxigp1_awlen;
  wire maxigp1_awlock;
  wire [2:0]maxigp1_awprot;
  wire [3:0]maxigp1_awqos;
  wire maxigp1_awready;
  wire [2:0]maxigp1_awsize;
  wire [15:0]maxigp1_awuser;
  wire maxigp1_awvalid;
  wire [15:0]maxigp1_bid;
  wire maxigp1_bready;
  wire [1:0]maxigp1_bresp;
  wire maxigp1_bvalid;
  wire [31:0]maxigp1_rdata;
  wire [15:0]maxigp1_rid;
  wire maxigp1_rlast;
  wire maxigp1_rready;
  wire [1:0]maxigp1_rresp;
  wire maxigp1_rvalid;
  wire [31:0]maxigp1_wdata;
  wire maxigp1_wlast;
  wire maxigp1_wready;
  wire [3:0]maxigp1_wstrb;
  wire maxigp1_wvalid;
  wire [39:0]maxigp2_araddr;
  wire [1:0]maxigp2_arburst;
  wire [3:0]maxigp2_arcache;
  wire [15:0]maxigp2_arid;
  wire [7:0]maxigp2_arlen;
  wire maxigp2_arlock;
  wire [2:0]maxigp2_arprot;
  wire [3:0]maxigp2_arqos;
  wire maxigp2_arready;
  wire [2:0]maxigp2_arsize;
  wire [15:0]maxigp2_aruser;
  wire maxigp2_arvalid;
  wire [39:0]maxigp2_awaddr;
  wire [1:0]maxigp2_awburst;
  wire [3:0]maxigp2_awcache;
  wire [15:0]maxigp2_awid;
  wire [7:0]maxigp2_awlen;
  wire maxigp2_awlock;
  wire [2:0]maxigp2_awprot;
  wire [3:0]maxigp2_awqos;
  wire maxigp2_awready;
  wire [2:0]maxigp2_awsize;
  wire [15:0]maxigp2_awuser;
  wire maxigp2_awvalid;
  wire [15:0]maxigp2_bid;
  wire maxigp2_bready;
  wire [1:0]maxigp2_bresp;
  wire maxigp2_bvalid;
  wire [31:0]maxigp2_rdata;
  wire [15:0]maxigp2_rid;
  wire maxigp2_rlast;
  wire maxigp2_rready;
  wire [1:0]maxigp2_rresp;
  wire maxigp2_rvalid;
  wire [31:0]maxigp2_wdata;
  wire maxigp2_wlast;
  wire maxigp2_wready;
  wire [3:0]maxigp2_wstrb;
  wire maxigp2_wvalid;
  wire maxihpm0_fpd_aclk;
  wire maxihpm0_lpd_aclk;
  wire maxihpm1_fpd_aclk;
  wire nfiq0_lpd_rpu;
  wire nfiq1_lpd_rpu;
  wire nirq0_lpd_rpu;
  wire nirq1_lpd_rpu;
  wire osc_rtc_clk;
  wire p_0_in;
  wire [7:0]perif_gdma_clk;
  wire [7:0]perif_gdma_cvld;
  wire [7:0]perif_gdma_tack;
  wire [7:0]pl2adma_cvld;
  wire [7:0]pl2adma_tack;
  wire pl_acpinact;
  wire pl_clk0;
  wire pl_clk1;
  wire pl_clk2;
  wire pl_clk3;
  wire [0:0]pl_clk_unbuffered;
  wire [3:0]pl_clock_stop;
  wire [31:0]pl_pmu_gpi;
  wire [3:0]pl_ps_apugic_fiq;
  wire [3:0]pl_ps_apugic_irq;
  wire pl_ps_eventi;
  wire [0:0]pl_ps_irq0;
  wire [0:0]pl_ps_irq1;
  wire pl_ps_trace_clk;
  wire pl_ps_trigack_0;
  wire pl_ps_trigack_1;
  wire pl_ps_trigack_2;
  wire pl_ps_trigack_3;
  wire pl_ps_trigger_0;
  wire pl_ps_trigger_1;
  wire pl_ps_trigger_2;
  wire pl_ps_trigger_3;
  wire pl_resetn0;
  wire [2:0]pll_aux_refclk_fpd;
  wire [1:0]pll_aux_refclk_lpd;
  wire pmu_aib_afifm_fpd_req;
  wire pmu_aib_afifm_lpd_req;
  wire [3:0]pmu_error_from_pl;
  wire [46:0]pmu_error_to_pl;
  wire [31:0]pmu_pl_gpo;
  wire ps_pl_evento;
  wire [7:0]ps_pl_irq_adma_chan;
  wire ps_pl_irq_aib_axi;
  wire ps_pl_irq_ams;
  wire ps_pl_irq_apm_fpd;
  wire [3:0]ps_pl_irq_apu_comm;
  wire [3:0]ps_pl_irq_apu_cpumnt;
  wire [3:0]ps_pl_irq_apu_cti;
  wire ps_pl_irq_apu_exterr;
  wire ps_pl_irq_apu_l2err;
  wire [3:0]ps_pl_irq_apu_pmu;
  wire ps_pl_irq_apu_regs;
  wire ps_pl_irq_atb_err_lpd;
  wire ps_pl_irq_can0;
  wire ps_pl_irq_can1;
  wire ps_pl_irq_clkmon;
  wire ps_pl_irq_csu;
  wire ps_pl_irq_csu_dma;
  wire ps_pl_irq_csu_pmu_wdt;
  wire ps_pl_irq_ddr_ss;
  wire ps_pl_irq_dpdma;
  wire ps_pl_irq_dport;
  wire ps_pl_irq_efuse;
  wire ps_pl_irq_enet0;
  wire ps_pl_irq_enet0_wake;
  wire ps_pl_irq_enet1;
  wire ps_pl_irq_enet1_wake;
  wire ps_pl_irq_enet2;
  wire ps_pl_irq_enet2_wake;
  wire ps_pl_irq_enet3;
  wire ps_pl_irq_enet3_wake;
  wire ps_pl_irq_fp_wdt;
  wire ps_pl_irq_fpd_apb_int;
  wire ps_pl_irq_fpd_atb_error;
  wire [7:0]ps_pl_irq_gdma_chan;
  wire ps_pl_irq_gpio;
  wire ps_pl_irq_gpu;
  wire ps_pl_irq_i2c0;
  wire ps_pl_irq_i2c1;
  wire ps_pl_irq_intf_fpd_smmu;
  wire ps_pl_irq_intf_ppd_cci;
  wire ps_pl_irq_ipi_channel0;
  wire ps_pl_irq_ipi_channel1;
  wire ps_pl_irq_ipi_channel10;
  wire ps_pl_irq_ipi_channel2;
  wire ps_pl_irq_ipi_channel7;
  wire ps_pl_irq_ipi_channel8;
  wire ps_pl_irq_ipi_channel9;
  wire ps_pl_irq_lp_wdt;
  wire ps_pl_irq_lpd_apb_intr;
  wire ps_pl_irq_lpd_apm;
  wire ps_pl_irq_nand;
  wire ps_pl_irq_ocm_error;
  wire ps_pl_irq_pcie_dma;
  wire ps_pl_irq_pcie_legacy;
  wire ps_pl_irq_pcie_msc;
  wire [1:0]ps_pl_irq_pcie_msi;
  wire ps_pl_irq_qspi;
  wire ps_pl_irq_r5_core0_ecc_error;
  wire ps_pl_irq_r5_core1_ecc_error;
  wire [1:0]ps_pl_irq_rpu_pm;
  wire ps_pl_irq_rtc_alaram;
  wire ps_pl_irq_rtc_seconds;
  wire ps_pl_irq_sata;
  wire ps_pl_irq_sdio0;
  wire ps_pl_irq_sdio0_wake;
  wire ps_pl_irq_sdio1;
  wire ps_pl_irq_sdio1_wake;
  wire ps_pl_irq_spi0;
  wire ps_pl_irq_spi1;
  wire ps_pl_irq_ttc0_0;
  wire ps_pl_irq_ttc0_1;
  wire ps_pl_irq_ttc0_2;
  wire ps_pl_irq_ttc1_0;
  wire ps_pl_irq_ttc1_1;
  wire ps_pl_irq_ttc1_2;
  wire ps_pl_irq_ttc2_0;
  wire ps_pl_irq_ttc2_1;
  wire ps_pl_irq_ttc2_2;
  wire ps_pl_irq_ttc3_0;
  wire ps_pl_irq_ttc3_1;
  wire ps_pl_irq_ttc3_2;
  wire ps_pl_irq_uart0;
  wire ps_pl_irq_uart1;
  wire [3:0]ps_pl_irq_usb3_0_endpoint;
  wire ps_pl_irq_usb3_0_otg;
  wire [1:0]ps_pl_irq_usb3_0_pmu_wakeup;
  wire [3:0]ps_pl_irq_usb3_1_endpoint;
  wire ps_pl_irq_usb3_1_otg;
  wire ps_pl_irq_xmpu_fpd;
  wire ps_pl_irq_xmpu_lpd;
  wire [3:0]ps_pl_standbywfe;
  wire [3:0]ps_pl_standbywfi;
  wire ps_pl_trigack_0;
  wire ps_pl_trigack_1;
  wire ps_pl_trigack_2;
  wire ps_pl_trigack_3;
  wire ps_pl_trigger_0;
  wire ps_pl_trigger_1;
  wire ps_pl_trigger_2;
  wire ps_pl_trigger_3;
  wire rpu_eventi0;
  wire rpu_eventi1;
  wire rpu_evento0;
  wire rpu_evento1;
  wire [43:0]sacefpd_acaddr;
  wire sacefpd_aclk;
  wire [2:0]sacefpd_acprot;
  wire sacefpd_acready;
  wire [3:0]sacefpd_acsnoop;
  wire sacefpd_acvalid;
  wire [43:0]sacefpd_araddr;
  wire [1:0]sacefpd_arbar;
  wire [1:0]sacefpd_arburst;
  wire [3:0]sacefpd_arcache;
  wire [1:0]sacefpd_ardomain;
  wire [5:0]sacefpd_arid;
  wire [7:0]sacefpd_arlen;
  wire sacefpd_arlock;
  wire [2:0]sacefpd_arprot;
  wire [3:0]sacefpd_arqos;
  wire sacefpd_arready;
  wire [3:0]sacefpd_arregion;
  wire [2:0]sacefpd_arsize;
  wire [3:0]sacefpd_arsnoop;
  wire [15:0]sacefpd_aruser;
  wire sacefpd_arvalid;
  wire [43:0]sacefpd_awaddr;
  wire [1:0]sacefpd_awbar;
  wire [1:0]sacefpd_awburst;
  wire [3:0]sacefpd_awcache;
  wire [1:0]sacefpd_awdomain;
  wire [5:0]sacefpd_awid;
  wire [7:0]sacefpd_awlen;
  wire sacefpd_awlock;
  wire [2:0]sacefpd_awprot;
  wire [3:0]sacefpd_awqos;
  wire sacefpd_awready;
  wire [3:0]sacefpd_awregion;
  wire [2:0]sacefpd_awsize;
  wire [2:0]sacefpd_awsnoop;
  wire [15:0]sacefpd_awuser;
  wire sacefpd_awvalid;
  wire [5:0]sacefpd_bid;
  wire sacefpd_bready;
  wire [1:0]sacefpd_bresp;
  wire sacefpd_buser;
  wire sacefpd_bvalid;
  wire [127:0]sacefpd_cddata;
  wire sacefpd_cdlast;
  wire sacefpd_cdready;
  wire sacefpd_cdvalid;
  wire sacefpd_crready;
  wire [4:0]sacefpd_crresp;
  wire sacefpd_crvalid;
  wire sacefpd_rack;
  wire [127:0]sacefpd_rdata;
  wire [5:0]sacefpd_rid;
  wire sacefpd_rlast;
  wire sacefpd_rready;
  wire [3:0]sacefpd_rresp;
  wire sacefpd_ruser;
  wire sacefpd_rvalid;
  wire sacefpd_wack;
  wire [127:0]sacefpd_wdata;
  wire sacefpd_wlast;
  wire sacefpd_wready;
  wire [15:0]sacefpd_wstrb;
  wire sacefpd_wuser;
  wire sacefpd_wvalid;
  wire saxi_lpd_aclk;
  wire [39:0]saxiacp_araddr;
  wire [1:0]saxiacp_arburst;
  wire [3:0]saxiacp_arcache;
  wire [4:0]saxiacp_arid;
  wire [7:0]saxiacp_arlen;
  wire saxiacp_arlock;
  wire [2:0]saxiacp_arprot;
  wire [3:0]saxiacp_arqos;
  wire saxiacp_arready;
  wire [2:0]saxiacp_arsize;
  wire [1:0]saxiacp_aruser;
  wire saxiacp_arvalid;
  wire [39:0]saxiacp_awaddr;
  wire [1:0]saxiacp_awburst;
  wire [3:0]saxiacp_awcache;
  wire [4:0]saxiacp_awid;
  wire [7:0]saxiacp_awlen;
  wire saxiacp_awlock;
  wire [2:0]saxiacp_awprot;
  wire [3:0]saxiacp_awqos;
  wire saxiacp_awready;
  wire [2:0]saxiacp_awsize;
  wire [1:0]saxiacp_awuser;
  wire saxiacp_awvalid;
  wire [4:0]saxiacp_bid;
  wire saxiacp_bready;
  wire [1:0]saxiacp_bresp;
  wire saxiacp_bvalid;
  wire saxiacp_fpd_aclk;
  wire [127:0]saxiacp_rdata;
  wire [4:0]saxiacp_rid;
  wire saxiacp_rlast;
  wire saxiacp_rready;
  wire [1:0]saxiacp_rresp;
  wire saxiacp_rvalid;
  wire [127:0]saxiacp_wdata;
  wire saxiacp_wlast;
  wire saxiacp_wready;
  wire [15:0]saxiacp_wstrb;
  wire saxiacp_wvalid;
  wire [48:0]saxigp0_araddr;
  wire [1:0]saxigp0_arburst;
  wire [3:0]saxigp0_arcache;
  wire [5:0]saxigp0_arid;
  wire [7:0]saxigp0_arlen;
  wire saxigp0_arlock;
  wire [2:0]saxigp0_arprot;
  wire [3:0]saxigp0_arqos;
  wire saxigp0_arready;
  wire [2:0]saxigp0_arsize;
  wire saxigp0_aruser;
  wire saxigp0_arvalid;
  wire [48:0]saxigp0_awaddr;
  wire [1:0]saxigp0_awburst;
  wire [3:0]saxigp0_awcache;
  wire [5:0]saxigp0_awid;
  wire [7:0]saxigp0_awlen;
  wire saxigp0_awlock;
  wire [2:0]saxigp0_awprot;
  wire [3:0]saxigp0_awqos;
  wire saxigp0_awready;
  wire [2:0]saxigp0_awsize;
  wire saxigp0_awuser;
  wire saxigp0_awvalid;
  wire [5:0]saxigp0_bid;
  wire saxigp0_bready;
  wire [1:0]saxigp0_bresp;
  wire saxigp0_bvalid;
  wire [3:0]saxigp0_racount;
  wire [7:0]saxigp0_rcount;
  wire [63:0]saxigp0_rdata;
  wire [5:0]saxigp0_rid;
  wire saxigp0_rlast;
  wire saxigp0_rready;
  wire [1:0]saxigp0_rresp;
  wire saxigp0_rvalid;
  wire [3:0]saxigp0_wacount;
  wire [7:0]saxigp0_wcount;
  wire [63:0]saxigp0_wdata;
  wire saxigp0_wlast;
  wire saxigp0_wready;
  wire [7:0]saxigp0_wstrb;
  wire saxigp0_wvalid;
  wire [48:0]saxigp1_araddr;
  wire [1:0]saxigp1_arburst;
  wire [3:0]saxigp1_arcache;
  wire [5:0]saxigp1_arid;
  wire [7:0]saxigp1_arlen;
  wire saxigp1_arlock;
  wire [2:0]saxigp1_arprot;
  wire [3:0]saxigp1_arqos;
  wire saxigp1_arready;
  wire [2:0]saxigp1_arsize;
  wire saxigp1_aruser;
  wire saxigp1_arvalid;
  wire [48:0]saxigp1_awaddr;
  wire [1:0]saxigp1_awburst;
  wire [3:0]saxigp1_awcache;
  wire [5:0]saxigp1_awid;
  wire [7:0]saxigp1_awlen;
  wire saxigp1_awlock;
  wire [2:0]saxigp1_awprot;
  wire [3:0]saxigp1_awqos;
  wire saxigp1_awready;
  wire [2:0]saxigp1_awsize;
  wire saxigp1_awuser;
  wire saxigp1_awvalid;
  wire [5:0]saxigp1_bid;
  wire saxigp1_bready;
  wire [1:0]saxigp1_bresp;
  wire saxigp1_bvalid;
  wire [3:0]saxigp1_racount;
  wire [7:0]saxigp1_rcount;
  wire [127:0]saxigp1_rdata;
  wire [5:0]saxigp1_rid;
  wire saxigp1_rlast;
  wire saxigp1_rready;
  wire [1:0]saxigp1_rresp;
  wire saxigp1_rvalid;
  wire [3:0]saxigp1_wacount;
  wire [7:0]saxigp1_wcount;
  wire [127:0]saxigp1_wdata;
  wire saxigp1_wlast;
  wire saxigp1_wready;
  wire [15:0]saxigp1_wstrb;
  wire saxigp1_wvalid;
  wire [48:0]saxigp2_araddr;
  wire [1:0]saxigp2_arburst;
  wire [3:0]saxigp2_arcache;
  wire [5:0]saxigp2_arid;
  wire [7:0]saxigp2_arlen;
  wire saxigp2_arlock;
  wire [2:0]saxigp2_arprot;
  wire [3:0]saxigp2_arqos;
  wire saxigp2_arready;
  wire [2:0]saxigp2_arsize;
  wire saxigp2_aruser;
  wire saxigp2_arvalid;
  wire [48:0]saxigp2_awaddr;
  wire [1:0]saxigp2_awburst;
  wire [3:0]saxigp2_awcache;
  wire [5:0]saxigp2_awid;
  wire [7:0]saxigp2_awlen;
  wire saxigp2_awlock;
  wire [2:0]saxigp2_awprot;
  wire [3:0]saxigp2_awqos;
  wire saxigp2_awready;
  wire [2:0]saxigp2_awsize;
  wire saxigp2_awuser;
  wire saxigp2_awvalid;
  wire [5:0]saxigp2_bid;
  wire saxigp2_bready;
  wire [1:0]saxigp2_bresp;
  wire saxigp2_bvalid;
  wire [3:0]saxigp2_racount;
  wire [7:0]saxigp2_rcount;
  wire [127:0]saxigp2_rdata;
  wire [5:0]saxigp2_rid;
  wire saxigp2_rlast;
  wire saxigp2_rready;
  wire [1:0]saxigp2_rresp;
  wire saxigp2_rvalid;
  wire [3:0]saxigp2_wacount;
  wire [7:0]saxigp2_wcount;
  wire [127:0]saxigp2_wdata;
  wire saxigp2_wlast;
  wire saxigp2_wready;
  wire [15:0]saxigp2_wstrb;
  wire saxigp2_wvalid;
  wire [48:0]saxigp3_araddr;
  wire [1:0]saxigp3_arburst;
  wire [3:0]saxigp3_arcache;
  wire [5:0]saxigp3_arid;
  wire [7:0]saxigp3_arlen;
  wire saxigp3_arlock;
  wire [2:0]saxigp3_arprot;
  wire [3:0]saxigp3_arqos;
  wire saxigp3_arready;
  wire [2:0]saxigp3_arsize;
  wire saxigp3_aruser;
  wire saxigp3_arvalid;
  wire [48:0]saxigp3_awaddr;
  wire [1:0]saxigp3_awburst;
  wire [3:0]saxigp3_awcache;
  wire [5:0]saxigp3_awid;
  wire [7:0]saxigp3_awlen;
  wire saxigp3_awlock;
  wire [2:0]saxigp3_awprot;
  wire [3:0]saxigp3_awqos;
  wire saxigp3_awready;
  wire [2:0]saxigp3_awsize;
  wire saxigp3_awuser;
  wire saxigp3_awvalid;
  wire [5:0]saxigp3_bid;
  wire saxigp3_bready;
  wire [1:0]saxigp3_bresp;
  wire saxigp3_bvalid;
  wire [3:0]saxigp3_racount;
  wire [7:0]saxigp3_rcount;
  wire [127:0]saxigp3_rdata;
  wire [5:0]saxigp3_rid;
  wire saxigp3_rlast;
  wire saxigp3_rready;
  wire [1:0]saxigp3_rresp;
  wire saxigp3_rvalid;
  wire [3:0]saxigp3_wacount;
  wire [7:0]saxigp3_wcount;
  wire [127:0]saxigp3_wdata;
  wire saxigp3_wlast;
  wire saxigp3_wready;
  wire [15:0]saxigp3_wstrb;
  wire saxigp3_wvalid;
  wire [48:0]saxigp4_araddr;
  wire [1:0]saxigp4_arburst;
  wire [3:0]saxigp4_arcache;
  wire [5:0]saxigp4_arid;
  wire [7:0]saxigp4_arlen;
  wire saxigp4_arlock;
  wire [2:0]saxigp4_arprot;
  wire [3:0]saxigp4_arqos;
  wire saxigp4_arready;
  wire [2:0]saxigp4_arsize;
  wire saxigp4_aruser;
  wire saxigp4_arvalid;
  wire [48:0]saxigp4_awaddr;
  wire [1:0]saxigp4_awburst;
  wire [3:0]saxigp4_awcache;
  wire [5:0]saxigp4_awid;
  wire [7:0]saxigp4_awlen;
  wire saxigp4_awlock;
  wire [2:0]saxigp4_awprot;
  wire [3:0]saxigp4_awqos;
  wire saxigp4_awready;
  wire [2:0]saxigp4_awsize;
  wire saxigp4_awuser;
  wire saxigp4_awvalid;
  wire [5:0]saxigp4_bid;
  wire saxigp4_bready;
  wire [1:0]saxigp4_bresp;
  wire saxigp4_bvalid;
  wire [3:0]saxigp4_racount;
  wire [7:0]saxigp4_rcount;
  wire [127:0]saxigp4_rdata;
  wire [5:0]saxigp4_rid;
  wire saxigp4_rlast;
  wire saxigp4_rready;
  wire [1:0]saxigp4_rresp;
  wire saxigp4_rvalid;
  wire [3:0]saxigp4_wacount;
  wire [7:0]saxigp4_wcount;
  wire [127:0]saxigp4_wdata;
  wire saxigp4_wlast;
  wire saxigp4_wready;
  wire [15:0]saxigp4_wstrb;
  wire saxigp4_wvalid;
  wire [48:0]saxigp5_araddr;
  wire [1:0]saxigp5_arburst;
  wire [3:0]saxigp5_arcache;
  wire [5:0]saxigp5_arid;
  wire [7:0]saxigp5_arlen;
  wire saxigp5_arlock;
  wire [2:0]saxigp5_arprot;
  wire [3:0]saxigp5_arqos;
  wire saxigp5_arready;
  wire [2:0]saxigp5_arsize;
  wire saxigp5_aruser;
  wire saxigp5_arvalid;
  wire [48:0]saxigp5_awaddr;
  wire [1:0]saxigp5_awburst;
  wire [3:0]saxigp5_awcache;
  wire [5:0]saxigp5_awid;
  wire [7:0]saxigp5_awlen;
  wire saxigp5_awlock;
  wire [2:0]saxigp5_awprot;
  wire [3:0]saxigp5_awqos;
  wire saxigp5_awready;
  wire [2:0]saxigp5_awsize;
  wire saxigp5_awuser;
  wire saxigp5_awvalid;
  wire [5:0]saxigp5_bid;
  wire saxigp5_bready;
  wire [1:0]saxigp5_bresp;
  wire saxigp5_bvalid;
  wire [3:0]saxigp5_racount;
  wire [7:0]saxigp5_rcount;
  wire [127:0]saxigp5_rdata;
  wire [5:0]saxigp5_rid;
  wire saxigp5_rlast;
  wire saxigp5_rready;
  wire [1:0]saxigp5_rresp;
  wire saxigp5_rvalid;
  wire [3:0]saxigp5_wacount;
  wire [7:0]saxigp5_wcount;
  wire [127:0]saxigp5_wdata;
  wire saxigp5_wlast;
  wire saxigp5_wready;
  wire [15:0]saxigp5_wstrb;
  wire saxigp5_wvalid;
  wire [48:0]saxigp6_araddr;
  wire [1:0]saxigp6_arburst;
  wire [3:0]saxigp6_arcache;
  wire [5:0]saxigp6_arid;
  wire [7:0]saxigp6_arlen;
  wire saxigp6_arlock;
  wire [2:0]saxigp6_arprot;
  wire [3:0]saxigp6_arqos;
  wire saxigp6_arready;
  wire [2:0]saxigp6_arsize;
  wire saxigp6_aruser;
  wire saxigp6_arvalid;
  wire [48:0]saxigp6_awaddr;
  wire [1:0]saxigp6_awburst;
  wire [3:0]saxigp6_awcache;
  wire [5:0]saxigp6_awid;
  wire [7:0]saxigp6_awlen;
  wire saxigp6_awlock;
  wire [2:0]saxigp6_awprot;
  wire [3:0]saxigp6_awqos;
  wire saxigp6_awready;
  wire [2:0]saxigp6_awsize;
  wire saxigp6_awuser;
  wire saxigp6_awvalid;
  wire [5:0]saxigp6_bid;
  wire saxigp6_bready;
  wire [1:0]saxigp6_bresp;
  wire saxigp6_bvalid;
  wire [3:0]saxigp6_racount;
  wire [7:0]saxigp6_rcount;
  wire [127:0]saxigp6_rdata;
  wire [5:0]saxigp6_rid;
  wire saxigp6_rlast;
  wire saxigp6_rready;
  wire [1:0]saxigp6_rresp;
  wire saxigp6_rvalid;
  wire [3:0]saxigp6_wacount;
  wire [7:0]saxigp6_wcount;
  wire [127:0]saxigp6_wdata;
  wire saxigp6_wlast;
  wire saxigp6_wready;
  wire [15:0]saxigp6_wstrb;
  wire saxigp6_wvalid;
  wire saxihp0_fpd_aclk;
  wire saxihp1_fpd_aclk;
  wire saxihp2_fpd_aclk;
  wire saxihp3_fpd_aclk;
  wire saxihpc0_fpd_aclk;
  wire saxihpc1_fpd_aclk;
  wire [59:0]stm_event;
  wire trace_clk_out;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[0] ;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[1] ;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[2] ;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[3] ;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[4] ;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[5] ;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[6] ;
  (* RTL_KEEP = "true" *) wire \trace_ctl_pipe[7] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[0] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[1] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[2] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[3] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[4] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[5] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[6] ;
  (* RTL_KEEP = "true" *) wire [31:0]\trace_data_pipe[7] ;
  wire NLW_PS8_i_DPAUDIOREFCLK_UNCONNECTED;
  wire NLW_PS8_i_PSPLTRACECTL_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_CLK_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_DONEB_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMACTN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMALERTN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMPARITY_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMRAMRSTN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_ERROROUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_ERRORSTATUS_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_INITB_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTCK_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDI_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDO_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTMS_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN0IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN1IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN2IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN3IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP0IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP1IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP2IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP3IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN0OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN1OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN2OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN3OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP0OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP1OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP2OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP3OUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_PADI_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_PADO_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_PORB_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_PROGB_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_RCALIBINOUT_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN0IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN1IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN2IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN3IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP0IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP1IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP2IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP3IN_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_SRSTB_UNCONNECTED;
  wire NLW_PS8_i_PSS_ALTO_CORE_PAD_ZQ_UNCONNECTED;
  wire [94:1]NLW_PS8_i_EMIOGPIOO_UNCONNECTED;
  wire [95:1]NLW_PS8_i_EMIOGPIOTN_UNCONNECTED;
  wire [127:32]NLW_PS8_i_MAXIGP0WDATA_UNCONNECTED;
  wire [15:4]NLW_PS8_i_MAXIGP0WSTRB_UNCONNECTED;
  wire [127:32]NLW_PS8_i_MAXIGP1WDATA_UNCONNECTED;
  wire [15:4]NLW_PS8_i_MAXIGP1WSTRB_UNCONNECTED;
  wire [127:32]NLW_PS8_i_MAXIGP2WDATA_UNCONNECTED;
  wire [15:4]NLW_PS8_i_MAXIGP2WSTRB_UNCONNECTED;
  wire [63:0]NLW_PS8_i_PSPLIRQFPD_UNCONNECTED;
  wire [99:0]NLW_PS8_i_PSPLIRQLPD_UNCONNECTED;
  wire [31:0]NLW_PS8_i_PSPLTRACEDATA_UNCONNECTED;
  wire [3:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_BOOTMODE_UNCONNECTED;
  wire [17:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMA_UNCONNECTED;
  wire [1:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBA_UNCONNECTED;
  wire [1:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBG_UNCONNECTED;
  wire [1:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCK_UNCONNECTED;
  wire [1:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKE_UNCONNECTED;
  wire [1:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKN_UNCONNECTED;
  wire [1:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCSN_UNCONNECTED;
  wire [8:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDM_UNCONNECTED;
  wire [71:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQ_UNCONNECTED;
  wire [8:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQS_UNCONNECTED;
  wire [8:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQSN_UNCONNECTED;
  wire [1:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMODT_UNCONNECTED;
  wire [77:0]NLW_PS8_i_PSS_ALTO_CORE_PAD_MIO_UNCONNECTED;
  wire [127:64]NLW_PS8_i_SAXIGP0RDATA_UNCONNECTED;

  assign dbg_path_fifo_bypass = \<const0> ;
  assign dp_audio_ref_clk = \<const0> ;
  assign fmio_char_afifsfpd_test_output = \<const0> ;
  assign fmio_char_afifslpd_test_output = \<const0> ;
  assign fmio_char_gem_test_output = \<const0> ;
  assign fmio_sd0_dll_test_out[7] = \<const0> ;
  assign fmio_sd0_dll_test_out[6] = \<const0> ;
  assign fmio_sd0_dll_test_out[5] = \<const0> ;
  assign fmio_sd0_dll_test_out[4] = \<const0> ;
  assign fmio_sd0_dll_test_out[3] = \<const0> ;
  assign fmio_sd0_dll_test_out[2] = \<const0> ;
  assign fmio_sd0_dll_test_out[1] = \<const0> ;
  assign fmio_sd0_dll_test_out[0] = \<const0> ;
  assign fmio_sd1_dll_test_out[7] = \<const0> ;
  assign fmio_sd1_dll_test_out[6] = \<const0> ;
  assign fmio_sd1_dll_test_out[5] = \<const0> ;
  assign fmio_sd1_dll_test_out[4] = \<const0> ;
  assign fmio_sd1_dll_test_out[3] = \<const0> ;
  assign fmio_sd1_dll_test_out[2] = \<const0> ;
  assign fmio_sd1_dll_test_out[1] = \<const0> ;
  assign fmio_sd1_dll_test_out[0] = \<const0> ;
  assign fmio_test_io_char_scan_out = \<const0> ;
  assign fpd_pl_spare_0_out = \<const0> ;
  assign fpd_pl_spare_1_out = \<const0> ;
  assign fpd_pl_spare_2_out = \<const0> ;
  assign fpd_pl_spare_3_out = \<const0> ;
  assign fpd_pl_spare_4_out = \<const0> ;
  assign fpd_pll_test_out[31] = \<const0> ;
  assign fpd_pll_test_out[30] = \<const0> ;
  assign fpd_pll_test_out[29] = \<const0> ;
  assign fpd_pll_test_out[28] = \<const0> ;
  assign fpd_pll_test_out[27] = \<const0> ;
  assign fpd_pll_test_out[26] = \<const0> ;
  assign fpd_pll_test_out[25] = \<const0> ;
  assign fpd_pll_test_out[24] = \<const0> ;
  assign fpd_pll_test_out[23] = \<const0> ;
  assign fpd_pll_test_out[22] = \<const0> ;
  assign fpd_pll_test_out[21] = \<const0> ;
  assign fpd_pll_test_out[20] = \<const0> ;
  assign fpd_pll_test_out[19] = \<const0> ;
  assign fpd_pll_test_out[18] = \<const0> ;
  assign fpd_pll_test_out[17] = \<const0> ;
  assign fpd_pll_test_out[16] = \<const0> ;
  assign fpd_pll_test_out[15] = \<const0> ;
  assign fpd_pll_test_out[14] = \<const0> ;
  assign fpd_pll_test_out[13] = \<const0> ;
  assign fpd_pll_test_out[12] = \<const0> ;
  assign fpd_pll_test_out[11] = \<const0> ;
  assign fpd_pll_test_out[10] = \<const0> ;
  assign fpd_pll_test_out[9] = \<const0> ;
  assign fpd_pll_test_out[8] = \<const0> ;
  assign fpd_pll_test_out[7] = \<const0> ;
  assign fpd_pll_test_out[6] = \<const0> ;
  assign fpd_pll_test_out[5] = \<const0> ;
  assign fpd_pll_test_out[4] = \<const0> ;
  assign fpd_pll_test_out[3] = \<const0> ;
  assign fpd_pll_test_out[2] = \<const0> ;
  assign fpd_pll_test_out[1] = \<const0> ;
  assign fpd_pll_test_out[0] = \<const0> ;
  assign io_char_audio_out_test_data = \<const0> ;
  assign io_char_video_out_test_data = \<const0> ;
  assign irq_ipi_pl_0 = \<const0> ;
  assign irq_ipi_pl_1 = \<const0> ;
  assign irq_ipi_pl_2 = \<const0> ;
  assign irq_ipi_pl_3 = \<const0> ;
  assign lpd_pl_spare_0_out = \<const0> ;
  assign lpd_pl_spare_1_out = \<const0> ;
  assign lpd_pl_spare_2_out = \<const0> ;
  assign lpd_pl_spare_3_out = \<const0> ;
  assign lpd_pl_spare_4_out = \<const0> ;
  assign lpd_pll_test_out[31] = \<const0> ;
  assign lpd_pll_test_out[30] = \<const0> ;
  assign lpd_pll_test_out[29] = \<const0> ;
  assign lpd_pll_test_out[28] = \<const0> ;
  assign lpd_pll_test_out[27] = \<const0> ;
  assign lpd_pll_test_out[26] = \<const0> ;
  assign lpd_pll_test_out[25] = \<const0> ;
  assign lpd_pll_test_out[24] = \<const0> ;
  assign lpd_pll_test_out[23] = \<const0> ;
  assign lpd_pll_test_out[22] = \<const0> ;
  assign lpd_pll_test_out[21] = \<const0> ;
  assign lpd_pll_test_out[20] = \<const0> ;
  assign lpd_pll_test_out[19] = \<const0> ;
  assign lpd_pll_test_out[18] = \<const0> ;
  assign lpd_pll_test_out[17] = \<const0> ;
  assign lpd_pll_test_out[16] = \<const0> ;
  assign lpd_pll_test_out[15] = \<const0> ;
  assign lpd_pll_test_out[14] = \<const0> ;
  assign lpd_pll_test_out[13] = \<const0> ;
  assign lpd_pll_test_out[12] = \<const0> ;
  assign lpd_pll_test_out[11] = \<const0> ;
  assign lpd_pll_test_out[10] = \<const0> ;
  assign lpd_pll_test_out[9] = \<const0> ;
  assign lpd_pll_test_out[8] = \<const0> ;
  assign lpd_pll_test_out[7] = \<const0> ;
  assign lpd_pll_test_out[6] = \<const0> ;
  assign lpd_pll_test_out[5] = \<const0> ;
  assign lpd_pll_test_out[4] = \<const0> ;
  assign lpd_pll_test_out[3] = \<const0> ;
  assign lpd_pll_test_out[2] = \<const0> ;
  assign lpd_pll_test_out[1] = \<const0> ;
  assign lpd_pll_test_out[0] = \<const0> ;
  assign o_afe_TX_dig_reset_rel_ack = \<const0> ;
  assign o_afe_TX_pipe_TX_dn_rxdet = \<const0> ;
  assign o_afe_TX_pipe_TX_dp_rxdet = \<const0> ;
  assign o_afe_cmn_calib_comp_out = \<const0> ;
  assign o_afe_pg_avddcr = \<const0> ;
  assign o_afe_pg_avddio = \<const0> ;
  assign o_afe_pg_dvddcr = \<const0> ;
  assign o_afe_pg_static_avddcr = \<const0> ;
  assign o_afe_pg_static_avddio = \<const0> ;
  assign o_afe_pll_clk_sym_hs = \<const0> ;
  assign o_afe_pll_dco_count[12] = \<const0> ;
  assign o_afe_pll_dco_count[11] = \<const0> ;
  assign o_afe_pll_dco_count[10] = \<const0> ;
  assign o_afe_pll_dco_count[9] = \<const0> ;
  assign o_afe_pll_dco_count[8] = \<const0> ;
  assign o_afe_pll_dco_count[7] = \<const0> ;
  assign o_afe_pll_dco_count[6] = \<const0> ;
  assign o_afe_pll_dco_count[5] = \<const0> ;
  assign o_afe_pll_dco_count[4] = \<const0> ;
  assign o_afe_pll_dco_count[3] = \<const0> ;
  assign o_afe_pll_dco_count[2] = \<const0> ;
  assign o_afe_pll_dco_count[1] = \<const0> ;
  assign o_afe_pll_dco_count[0] = \<const0> ;
  assign o_afe_pll_fbclk_frac = \<const0> ;
  assign o_afe_rx_hsrx_clock_stop_ack = \<const0> ;
  assign o_afe_rx_pipe_lfpsbcn_rxelecidle = \<const0> ;
  assign o_afe_rx_pipe_sigdet = \<const0> ;
  assign o_afe_rx_symbol[19] = \<const0> ;
  assign o_afe_rx_symbol[18] = \<const0> ;
  assign o_afe_rx_symbol[17] = \<const0> ;
  assign o_afe_rx_symbol[16] = \<const0> ;
  assign o_afe_rx_symbol[15] = \<const0> ;
  assign o_afe_rx_symbol[14] = \<const0> ;
  assign o_afe_rx_symbol[13] = \<const0> ;
  assign o_afe_rx_symbol[12] = \<const0> ;
  assign o_afe_rx_symbol[11] = \<const0> ;
  assign o_afe_rx_symbol[10] = \<const0> ;
  assign o_afe_rx_symbol[9] = \<const0> ;
  assign o_afe_rx_symbol[8] = \<const0> ;
  assign o_afe_rx_symbol[7] = \<const0> ;
  assign o_afe_rx_symbol[6] = \<const0> ;
  assign o_afe_rx_symbol[5] = \<const0> ;
  assign o_afe_rx_symbol[4] = \<const0> ;
  assign o_afe_rx_symbol[3] = \<const0> ;
  assign o_afe_rx_symbol[2] = \<const0> ;
  assign o_afe_rx_symbol[1] = \<const0> ;
  assign o_afe_rx_symbol[0] = \<const0> ;
  assign o_afe_rx_symbol_clk_by_2 = \<const0> ;
  assign o_afe_rx_uphy_rx_calib_done = \<const0> ;
  assign o_afe_rx_uphy_save_calcode = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[7] = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[6] = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[5] = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[4] = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[3] = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[2] = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[1] = \<const0> ;
  assign o_afe_rx_uphy_save_calcode_data[0] = \<const0> ;
  assign o_afe_rx_uphy_startloop_buf = \<const0> ;
  assign o_dbg_l0_phystatus = \<const0> ;
  assign o_dbg_l0_powerdown[1] = \<const0> ;
  assign o_dbg_l0_powerdown[0] = \<const0> ;
  assign o_dbg_l0_rate[1] = \<const0> ;
  assign o_dbg_l0_rate[0] = \<const0> ;
  assign o_dbg_l0_rstb = \<const0> ;
  assign o_dbg_l0_rx_sgmii_en_cdet = \<const0> ;
  assign o_dbg_l0_rxclk = \<const0> ;
  assign o_dbg_l0_rxdata[19] = \<const0> ;
  assign o_dbg_l0_rxdata[18] = \<const0> ;
  assign o_dbg_l0_rxdata[17] = \<const0> ;
  assign o_dbg_l0_rxdata[16] = \<const0> ;
  assign o_dbg_l0_rxdata[15] = \<const0> ;
  assign o_dbg_l0_rxdata[14] = \<const0> ;
  assign o_dbg_l0_rxdata[13] = \<const0> ;
  assign o_dbg_l0_rxdata[12] = \<const0> ;
  assign o_dbg_l0_rxdata[11] = \<const0> ;
  assign o_dbg_l0_rxdata[10] = \<const0> ;
  assign o_dbg_l0_rxdata[9] = \<const0> ;
  assign o_dbg_l0_rxdata[8] = \<const0> ;
  assign o_dbg_l0_rxdata[7] = \<const0> ;
  assign o_dbg_l0_rxdata[6] = \<const0> ;
  assign o_dbg_l0_rxdata[5] = \<const0> ;
  assign o_dbg_l0_rxdata[4] = \<const0> ;
  assign o_dbg_l0_rxdata[3] = \<const0> ;
  assign o_dbg_l0_rxdata[2] = \<const0> ;
  assign o_dbg_l0_rxdata[1] = \<const0> ;
  assign o_dbg_l0_rxdata[0] = \<const0> ;
  assign o_dbg_l0_rxdatak[1] = \<const0> ;
  assign o_dbg_l0_rxdatak[0] = \<const0> ;
  assign o_dbg_l0_rxelecidle = \<const0> ;
  assign o_dbg_l0_rxpolarity = \<const0> ;
  assign o_dbg_l0_rxstatus[2] = \<const0> ;
  assign o_dbg_l0_rxstatus[1] = \<const0> ;
  assign o_dbg_l0_rxstatus[0] = \<const0> ;
  assign o_dbg_l0_rxvalid = \<const0> ;
  assign o_dbg_l0_sata_coreclockready = \<const0> ;
  assign o_dbg_l0_sata_coreready = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[19] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[18] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[17] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[16] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[15] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[14] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[13] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[12] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[11] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[10] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[9] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[8] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[7] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[6] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[5] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[4] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[3] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[2] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[1] = \<const0> ;
  assign o_dbg_l0_sata_corerxdata[0] = \<const0> ;
  assign o_dbg_l0_sata_corerxdatavalid[1] = \<const0> ;
  assign o_dbg_l0_sata_corerxdatavalid[0] = \<const0> ;
  assign o_dbg_l0_sata_corerxsignaldet = \<const0> ;
  assign o_dbg_l0_sata_phyctrlpartial = \<const0> ;
  assign o_dbg_l0_sata_phyctrlreset = \<const0> ;
  assign o_dbg_l0_sata_phyctrlrxrate[1] = \<const0> ;
  assign o_dbg_l0_sata_phyctrlrxrate[0] = \<const0> ;
  assign o_dbg_l0_sata_phyctrlrxrst = \<const0> ;
  assign o_dbg_l0_sata_phyctrlslumber = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[19] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[18] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[17] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[16] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[15] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[14] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[13] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[12] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[11] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[10] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[9] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[8] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[7] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[6] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[5] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[4] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[3] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[2] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[1] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxdata[0] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxidle = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxrate[1] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxrate[0] = \<const0> ;
  assign o_dbg_l0_sata_phyctrltxrst = \<const0> ;
  assign o_dbg_l0_tx_sgmii_ewrap = \<const0> ;
  assign o_dbg_l0_txclk = \<const0> ;
  assign o_dbg_l0_txdata[19] = \<const0> ;
  assign o_dbg_l0_txdata[18] = \<const0> ;
  assign o_dbg_l0_txdata[17] = \<const0> ;
  assign o_dbg_l0_txdata[16] = \<const0> ;
  assign o_dbg_l0_txdata[15] = \<const0> ;
  assign o_dbg_l0_txdata[14] = \<const0> ;
  assign o_dbg_l0_txdata[13] = \<const0> ;
  assign o_dbg_l0_txdata[12] = \<const0> ;
  assign o_dbg_l0_txdata[11] = \<const0> ;
  assign o_dbg_l0_txdata[10] = \<const0> ;
  assign o_dbg_l0_txdata[9] = \<const0> ;
  assign o_dbg_l0_txdata[8] = \<const0> ;
  assign o_dbg_l0_txdata[7] = \<const0> ;
  assign o_dbg_l0_txdata[6] = \<const0> ;
  assign o_dbg_l0_txdata[5] = \<const0> ;
  assign o_dbg_l0_txdata[4] = \<const0> ;
  assign o_dbg_l0_txdata[3] = \<const0> ;
  assign o_dbg_l0_txdata[2] = \<const0> ;
  assign o_dbg_l0_txdata[1] = \<const0> ;
  assign o_dbg_l0_txdata[0] = \<const0> ;
  assign o_dbg_l0_txdatak[1] = \<const0> ;
  assign o_dbg_l0_txdatak[0] = \<const0> ;
  assign o_dbg_l0_txdetrx_lpback = \<const0> ;
  assign o_dbg_l0_txelecidle = \<const0> ;
  assign o_dbg_l1_phystatus = \<const0> ;
  assign o_dbg_l1_powerdown[1] = \<const0> ;
  assign o_dbg_l1_powerdown[0] = \<const0> ;
  assign o_dbg_l1_rate[1] = \<const0> ;
  assign o_dbg_l1_rate[0] = \<const0> ;
  assign o_dbg_l1_rstb = \<const0> ;
  assign o_dbg_l1_rx_sgmii_en_cdet = \<const0> ;
  assign o_dbg_l1_rxclk = \<const0> ;
  assign o_dbg_l1_rxdata[19] = \<const0> ;
  assign o_dbg_l1_rxdata[18] = \<const0> ;
  assign o_dbg_l1_rxdata[17] = \<const0> ;
  assign o_dbg_l1_rxdata[16] = \<const0> ;
  assign o_dbg_l1_rxdata[15] = \<const0> ;
  assign o_dbg_l1_rxdata[14] = \<const0> ;
  assign o_dbg_l1_rxdata[13] = \<const0> ;
  assign o_dbg_l1_rxdata[12] = \<const0> ;
  assign o_dbg_l1_rxdata[11] = \<const0> ;
  assign o_dbg_l1_rxdata[10] = \<const0> ;
  assign o_dbg_l1_rxdata[9] = \<const0> ;
  assign o_dbg_l1_rxdata[8] = \<const0> ;
  assign o_dbg_l1_rxdata[7] = \<const0> ;
  assign o_dbg_l1_rxdata[6] = \<const0> ;
  assign o_dbg_l1_rxdata[5] = \<const0> ;
  assign o_dbg_l1_rxdata[4] = \<const0> ;
  assign o_dbg_l1_rxdata[3] = \<const0> ;
  assign o_dbg_l1_rxdata[2] = \<const0> ;
  assign o_dbg_l1_rxdata[1] = \<const0> ;
  assign o_dbg_l1_rxdata[0] = \<const0> ;
  assign o_dbg_l1_rxdatak[1] = \<const0> ;
  assign o_dbg_l1_rxdatak[0] = \<const0> ;
  assign o_dbg_l1_rxelecidle = \<const0> ;
  assign o_dbg_l1_rxpolarity = \<const0> ;
  assign o_dbg_l1_rxstatus[2] = \<const0> ;
  assign o_dbg_l1_rxstatus[1] = \<const0> ;
  assign o_dbg_l1_rxstatus[0] = \<const0> ;
  assign o_dbg_l1_rxvalid = \<const0> ;
  assign o_dbg_l1_sata_coreclockready = \<const0> ;
  assign o_dbg_l1_sata_coreready = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[19] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[18] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[17] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[16] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[15] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[14] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[13] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[12] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[11] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[10] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[9] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[8] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[7] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[6] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[5] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[4] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[3] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[2] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[1] = \<const0> ;
  assign o_dbg_l1_sata_corerxdata[0] = \<const0> ;
  assign o_dbg_l1_sata_corerxdatavalid[1] = \<const0> ;
  assign o_dbg_l1_sata_corerxdatavalid[0] = \<const0> ;
  assign o_dbg_l1_sata_corerxsignaldet = \<const0> ;
  assign o_dbg_l1_sata_phyctrlpartial = \<const0> ;
  assign o_dbg_l1_sata_phyctrlreset = \<const0> ;
  assign o_dbg_l1_sata_phyctrlrxrate[1] = \<const0> ;
  assign o_dbg_l1_sata_phyctrlrxrate[0] = \<const0> ;
  assign o_dbg_l1_sata_phyctrlrxrst = \<const0> ;
  assign o_dbg_l1_sata_phyctrlslumber = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[19] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[18] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[17] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[16] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[15] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[14] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[13] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[12] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[11] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[10] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[9] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[8] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[7] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[6] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[5] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[4] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[3] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[2] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[1] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxdata[0] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxidle = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxrate[1] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxrate[0] = \<const0> ;
  assign o_dbg_l1_sata_phyctrltxrst = \<const0> ;
  assign o_dbg_l1_tx_sgmii_ewrap = \<const0> ;
  assign o_dbg_l1_txclk = \<const0> ;
  assign o_dbg_l1_txdata[19] = \<const0> ;
  assign o_dbg_l1_txdata[18] = \<const0> ;
  assign o_dbg_l1_txdata[17] = \<const0> ;
  assign o_dbg_l1_txdata[16] = \<const0> ;
  assign o_dbg_l1_txdata[15] = \<const0> ;
  assign o_dbg_l1_txdata[14] = \<const0> ;
  assign o_dbg_l1_txdata[13] = \<const0> ;
  assign o_dbg_l1_txdata[12] = \<const0> ;
  assign o_dbg_l1_txdata[11] = \<const0> ;
  assign o_dbg_l1_txdata[10] = \<const0> ;
  assign o_dbg_l1_txdata[9] = \<const0> ;
  assign o_dbg_l1_txdata[8] = \<const0> ;
  assign o_dbg_l1_txdata[7] = \<const0> ;
  assign o_dbg_l1_txdata[6] = \<const0> ;
  assign o_dbg_l1_txdata[5] = \<const0> ;
  assign o_dbg_l1_txdata[4] = \<const0> ;
  assign o_dbg_l1_txdata[3] = \<const0> ;
  assign o_dbg_l1_txdata[2] = \<const0> ;
  assign o_dbg_l1_txdata[1] = \<const0> ;
  assign o_dbg_l1_txdata[0] = \<const0> ;
  assign o_dbg_l1_txdatak[1] = \<const0> ;
  assign o_dbg_l1_txdatak[0] = \<const0> ;
  assign o_dbg_l1_txdetrx_lpback = \<const0> ;
  assign o_dbg_l1_txelecidle = \<const0> ;
  assign o_dbg_l2_phystatus = \<const0> ;
  assign o_dbg_l2_powerdown[1] = \<const0> ;
  assign o_dbg_l2_powerdown[0] = \<const0> ;
  assign o_dbg_l2_rate[1] = \<const0> ;
  assign o_dbg_l2_rate[0] = \<const0> ;
  assign o_dbg_l2_rstb = \<const0> ;
  assign o_dbg_l2_rx_sgmii_en_cdet = \<const0> ;
  assign o_dbg_l2_rxclk = \<const0> ;
  assign o_dbg_l2_rxdata[19] = \<const0> ;
  assign o_dbg_l2_rxdata[18] = \<const0> ;
  assign o_dbg_l2_rxdata[17] = \<const0> ;
  assign o_dbg_l2_rxdata[16] = \<const0> ;
  assign o_dbg_l2_rxdata[15] = \<const0> ;
  assign o_dbg_l2_rxdata[14] = \<const0> ;
  assign o_dbg_l2_rxdata[13] = \<const0> ;
  assign o_dbg_l2_rxdata[12] = \<const0> ;
  assign o_dbg_l2_rxdata[11] = \<const0> ;
  assign o_dbg_l2_rxdata[10] = \<const0> ;
  assign o_dbg_l2_rxdata[9] = \<const0> ;
  assign o_dbg_l2_rxdata[8] = \<const0> ;
  assign o_dbg_l2_rxdata[7] = \<const0> ;
  assign o_dbg_l2_rxdata[6] = \<const0> ;
  assign o_dbg_l2_rxdata[5] = \<const0> ;
  assign o_dbg_l2_rxdata[4] = \<const0> ;
  assign o_dbg_l2_rxdata[3] = \<const0> ;
  assign o_dbg_l2_rxdata[2] = \<const0> ;
  assign o_dbg_l2_rxdata[1] = \<const0> ;
  assign o_dbg_l2_rxdata[0] = \<const0> ;
  assign o_dbg_l2_rxdatak[1] = \<const0> ;
  assign o_dbg_l2_rxdatak[0] = \<const0> ;
  assign o_dbg_l2_rxelecidle = \<const0> ;
  assign o_dbg_l2_rxpolarity = \<const0> ;
  assign o_dbg_l2_rxstatus[2] = \<const0> ;
  assign o_dbg_l2_rxstatus[1] = \<const0> ;
  assign o_dbg_l2_rxstatus[0] = \<const0> ;
  assign o_dbg_l2_rxvalid = \<const0> ;
  assign o_dbg_l2_sata_coreclockready = \<const0> ;
  assign o_dbg_l2_sata_coreready = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[19] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[18] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[17] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[16] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[15] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[14] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[13] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[12] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[11] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[10] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[9] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[8] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[7] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[6] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[5] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[4] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[3] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[2] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[1] = \<const0> ;
  assign o_dbg_l2_sata_corerxdata[0] = \<const0> ;
  assign o_dbg_l2_sata_corerxdatavalid[1] = \<const0> ;
  assign o_dbg_l2_sata_corerxdatavalid[0] = \<const0> ;
  assign o_dbg_l2_sata_corerxsignaldet = \<const0> ;
  assign o_dbg_l2_sata_phyctrlpartial = \<const0> ;
  assign o_dbg_l2_sata_phyctrlreset = \<const0> ;
  assign o_dbg_l2_sata_phyctrlrxrate[1] = \<const0> ;
  assign o_dbg_l2_sata_phyctrlrxrate[0] = \<const0> ;
  assign o_dbg_l2_sata_phyctrlrxrst = \<const0> ;
  assign o_dbg_l2_sata_phyctrlslumber = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[19] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[18] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[17] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[16] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[15] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[14] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[13] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[12] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[11] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[10] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[9] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[8] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[7] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[6] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[5] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[4] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[3] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[2] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[1] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxdata[0] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxidle = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxrate[1] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxrate[0] = \<const0> ;
  assign o_dbg_l2_sata_phyctrltxrst = \<const0> ;
  assign o_dbg_l2_tx_sgmii_ewrap = \<const0> ;
  assign o_dbg_l2_txclk = \<const0> ;
  assign o_dbg_l2_txdata[19] = \<const0> ;
  assign o_dbg_l2_txdata[18] = \<const0> ;
  assign o_dbg_l2_txdata[17] = \<const0> ;
  assign o_dbg_l2_txdata[16] = \<const0> ;
  assign o_dbg_l2_txdata[15] = \<const0> ;
  assign o_dbg_l2_txdata[14] = \<const0> ;
  assign o_dbg_l2_txdata[13] = \<const0> ;
  assign o_dbg_l2_txdata[12] = \<const0> ;
  assign o_dbg_l2_txdata[11] = \<const0> ;
  assign o_dbg_l2_txdata[10] = \<const0> ;
  assign o_dbg_l2_txdata[9] = \<const0> ;
  assign o_dbg_l2_txdata[8] = \<const0> ;
  assign o_dbg_l2_txdata[7] = \<const0> ;
  assign o_dbg_l2_txdata[6] = \<const0> ;
  assign o_dbg_l2_txdata[5] = \<const0> ;
  assign o_dbg_l2_txdata[4] = \<const0> ;
  assign o_dbg_l2_txdata[3] = \<const0> ;
  assign o_dbg_l2_txdata[2] = \<const0> ;
  assign o_dbg_l2_txdata[1] = \<const0> ;
  assign o_dbg_l2_txdata[0] = \<const0> ;
  assign o_dbg_l2_txdatak[1] = \<const0> ;
  assign o_dbg_l2_txdatak[0] = \<const0> ;
  assign o_dbg_l2_txdetrx_lpback = \<const0> ;
  assign o_dbg_l2_txelecidle = \<const0> ;
  assign o_dbg_l3_phystatus = \<const0> ;
  assign o_dbg_l3_powerdown[1] = \<const0> ;
  assign o_dbg_l3_powerdown[0] = \<const0> ;
  assign o_dbg_l3_rate[1] = \<const0> ;
  assign o_dbg_l3_rate[0] = \<const0> ;
  assign o_dbg_l3_rstb = \<const0> ;
  assign o_dbg_l3_rx_sgmii_en_cdet = \<const0> ;
  assign o_dbg_l3_rxclk = \<const0> ;
  assign o_dbg_l3_rxdata[19] = \<const0> ;
  assign o_dbg_l3_rxdata[18] = \<const0> ;
  assign o_dbg_l3_rxdata[17] = \<const0> ;
  assign o_dbg_l3_rxdata[16] = \<const0> ;
  assign o_dbg_l3_rxdata[15] = \<const0> ;
  assign o_dbg_l3_rxdata[14] = \<const0> ;
  assign o_dbg_l3_rxdata[13] = \<const0> ;
  assign o_dbg_l3_rxdata[12] = \<const0> ;
  assign o_dbg_l3_rxdata[11] = \<const0> ;
  assign o_dbg_l3_rxdata[10] = \<const0> ;
  assign o_dbg_l3_rxdata[9] = \<const0> ;
  assign o_dbg_l3_rxdata[8] = \<const0> ;
  assign o_dbg_l3_rxdata[7] = \<const0> ;
  assign o_dbg_l3_rxdata[6] = \<const0> ;
  assign o_dbg_l3_rxdata[5] = \<const0> ;
  assign o_dbg_l3_rxdata[4] = \<const0> ;
  assign o_dbg_l3_rxdata[3] = \<const0> ;
  assign o_dbg_l3_rxdata[2] = \<const0> ;
  assign o_dbg_l3_rxdata[1] = \<const0> ;
  assign o_dbg_l3_rxdata[0] = \<const0> ;
  assign o_dbg_l3_rxdatak[1] = \<const0> ;
  assign o_dbg_l3_rxdatak[0] = \<const0> ;
  assign o_dbg_l3_rxelecidle = \<const0> ;
  assign o_dbg_l3_rxpolarity = \<const0> ;
  assign o_dbg_l3_rxstatus[2] = \<const0> ;
  assign o_dbg_l3_rxstatus[1] = \<const0> ;
  assign o_dbg_l3_rxstatus[0] = \<const0> ;
  assign o_dbg_l3_rxvalid = \<const0> ;
  assign o_dbg_l3_sata_coreclockready = \<const0> ;
  assign o_dbg_l3_sata_coreready = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[19] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[18] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[17] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[16] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[15] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[14] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[13] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[12] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[11] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[10] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[9] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[8] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[7] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[6] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[5] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[4] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[3] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[2] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[1] = \<const0> ;
  assign o_dbg_l3_sata_corerxdata[0] = \<const0> ;
  assign o_dbg_l3_sata_corerxdatavalid[1] = \<const0> ;
  assign o_dbg_l3_sata_corerxdatavalid[0] = \<const0> ;
  assign o_dbg_l3_sata_corerxsignaldet = \<const0> ;
  assign o_dbg_l3_sata_phyctrlpartial = \<const0> ;
  assign o_dbg_l3_sata_phyctrlreset = \<const0> ;
  assign o_dbg_l3_sata_phyctrlrxrate[1] = \<const0> ;
  assign o_dbg_l3_sata_phyctrlrxrate[0] = \<const0> ;
  assign o_dbg_l3_sata_phyctrlrxrst = \<const0> ;
  assign o_dbg_l3_sata_phyctrlslumber = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[19] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[18] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[17] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[16] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[15] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[14] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[13] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[12] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[11] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[10] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[9] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[8] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[7] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[6] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[5] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[4] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[3] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[2] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[1] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxdata[0] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxidle = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxrate[1] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxrate[0] = \<const0> ;
  assign o_dbg_l3_sata_phyctrltxrst = \<const0> ;
  assign o_dbg_l3_tx_sgmii_ewrap = \<const0> ;
  assign o_dbg_l3_txclk = \<const0> ;
  assign o_dbg_l3_txdata[19] = \<const0> ;
  assign o_dbg_l3_txdata[18] = \<const0> ;
  assign o_dbg_l3_txdata[17] = \<const0> ;
  assign o_dbg_l3_txdata[16] = \<const0> ;
  assign o_dbg_l3_txdata[15] = \<const0> ;
  assign o_dbg_l3_txdata[14] = \<const0> ;
  assign o_dbg_l3_txdata[13] = \<const0> ;
  assign o_dbg_l3_txdata[12] = \<const0> ;
  assign o_dbg_l3_txdata[11] = \<const0> ;
  assign o_dbg_l3_txdata[10] = \<const0> ;
  assign o_dbg_l3_txdata[9] = \<const0> ;
  assign o_dbg_l3_txdata[8] = \<const0> ;
  assign o_dbg_l3_txdata[7] = \<const0> ;
  assign o_dbg_l3_txdata[6] = \<const0> ;
  assign o_dbg_l3_txdata[5] = \<const0> ;
  assign o_dbg_l3_txdata[4] = \<const0> ;
  assign o_dbg_l3_txdata[3] = \<const0> ;
  assign o_dbg_l3_txdata[2] = \<const0> ;
  assign o_dbg_l3_txdata[1] = \<const0> ;
  assign o_dbg_l3_txdata[0] = \<const0> ;
  assign o_dbg_l3_txdatak[1] = \<const0> ;
  assign o_dbg_l3_txdatak[0] = \<const0> ;
  assign o_dbg_l3_txdetrx_lpback = \<const0> ;
  assign o_dbg_l3_txelecidle = \<const0> ;
  assign pl_resetn1 = \<const1> ;
  assign pl_resetn2 = \<const1> ;
  assign pl_resetn3 = \<const1> ;
  assign ps_pl_tracectl = \trace_ctl_pipe[0] ;
  assign ps_pl_tracedata[31:0] = \trace_data_pipe[0] ;
  assign pstp_pl_out[31] = \<const0> ;
  assign pstp_pl_out[30] = \<const0> ;
  assign pstp_pl_out[29] = \<const0> ;
  assign pstp_pl_out[28] = \<const0> ;
  assign pstp_pl_out[27] = \<const0> ;
  assign pstp_pl_out[26] = \<const0> ;
  assign pstp_pl_out[25] = \<const0> ;
  assign pstp_pl_out[24] = \<const0> ;
  assign pstp_pl_out[23] = \<const0> ;
  assign pstp_pl_out[22] = \<const0> ;
  assign pstp_pl_out[21] = \<const0> ;
  assign pstp_pl_out[20] = \<const0> ;
  assign pstp_pl_out[19] = \<const0> ;
  assign pstp_pl_out[18] = \<const0> ;
  assign pstp_pl_out[17] = \<const0> ;
  assign pstp_pl_out[16] = \<const0> ;
  assign pstp_pl_out[15] = \<const0> ;
  assign pstp_pl_out[14] = \<const0> ;
  assign pstp_pl_out[13] = \<const0> ;
  assign pstp_pl_out[12] = \<const0> ;
  assign pstp_pl_out[11] = \<const0> ;
  assign pstp_pl_out[10] = \<const0> ;
  assign pstp_pl_out[9] = \<const0> ;
  assign pstp_pl_out[8] = \<const0> ;
  assign pstp_pl_out[7] = \<const0> ;
  assign pstp_pl_out[6] = \<const0> ;
  assign pstp_pl_out[5] = \<const0> ;
  assign pstp_pl_out[4] = \<const0> ;
  assign pstp_pl_out[3] = \<const0> ;
  assign pstp_pl_out[2] = \<const0> ;
  assign pstp_pl_out[1] = \<const0> ;
  assign pstp_pl_out[0] = \<const0> ;
  assign test_adc_out[19] = \<const0> ;
  assign test_adc_out[18] = \<const0> ;
  assign test_adc_out[17] = \<const0> ;
  assign test_adc_out[16] = \<const0> ;
  assign test_adc_out[15] = \<const0> ;
  assign test_adc_out[14] = \<const0> ;
  assign test_adc_out[13] = \<const0> ;
  assign test_adc_out[12] = \<const0> ;
  assign test_adc_out[11] = \<const0> ;
  assign test_adc_out[10] = \<const0> ;
  assign test_adc_out[9] = \<const0> ;
  assign test_adc_out[8] = \<const0> ;
  assign test_adc_out[7] = \<const0> ;
  assign test_adc_out[6] = \<const0> ;
  assign test_adc_out[5] = \<const0> ;
  assign test_adc_out[4] = \<const0> ;
  assign test_adc_out[3] = \<const0> ;
  assign test_adc_out[2] = \<const0> ;
  assign test_adc_out[1] = \<const0> ;
  assign test_adc_out[0] = \<const0> ;
  assign test_ams_osc[7] = \<const0> ;
  assign test_ams_osc[6] = \<const0> ;
  assign test_ams_osc[5] = \<const0> ;
  assign test_ams_osc[4] = \<const0> ;
  assign test_ams_osc[3] = \<const0> ;
  assign test_ams_osc[2] = \<const0> ;
  assign test_ams_osc[1] = \<const0> ;
  assign test_ams_osc[0] = \<const0> ;
  assign test_bscan_tdo = \<const0> ;
  assign test_db[15] = \<const0> ;
  assign test_db[14] = \<const0> ;
  assign test_db[13] = \<const0> ;
  assign test_db[12] = \<const0> ;
  assign test_db[11] = \<const0> ;
  assign test_db[10] = \<const0> ;
  assign test_db[9] = \<const0> ;
  assign test_db[8] = \<const0> ;
  assign test_db[7] = \<const0> ;
  assign test_db[6] = \<const0> ;
  assign test_db[5] = \<const0> ;
  assign test_db[4] = \<const0> ;
  assign test_db[3] = \<const0> ;
  assign test_db[2] = \<const0> ;
  assign test_db[1] = \<const0> ;
  assign test_db[0] = \<const0> ;
  assign test_ddr2pl_dcd_skewout = \<const0> ;
  assign test_do[15] = \<const0> ;
  assign test_do[14] = \<const0> ;
  assign test_do[13] = \<const0> ;
  assign test_do[12] = \<const0> ;
  assign test_do[11] = \<const0> ;
  assign test_do[10] = \<const0> ;
  assign test_do[9] = \<const0> ;
  assign test_do[8] = \<const0> ;
  assign test_do[7] = \<const0> ;
  assign test_do[6] = \<const0> ;
  assign test_do[5] = \<const0> ;
  assign test_do[4] = \<const0> ;
  assign test_do[3] = \<const0> ;
  assign test_do[2] = \<const0> ;
  assign test_do[1] = \<const0> ;
  assign test_do[0] = \<const0> ;
  assign test_drdy = \<const0> ;
  assign test_mon_data[15] = \<const0> ;
  assign test_mon_data[14] = \<const0> ;
  assign test_mon_data[13] = \<const0> ;
  assign test_mon_data[12] = \<const0> ;
  assign test_mon_data[11] = \<const0> ;
  assign test_mon_data[10] = \<const0> ;
  assign test_mon_data[9] = \<const0> ;
  assign test_mon_data[8] = \<const0> ;
  assign test_mon_data[7] = \<const0> ;
  assign test_mon_data[6] = \<const0> ;
  assign test_mon_data[5] = \<const0> ;
  assign test_mon_data[4] = \<const0> ;
  assign test_mon_data[3] = \<const0> ;
  assign test_mon_data[2] = \<const0> ;
  assign test_mon_data[1] = \<const0> ;
  assign test_mon_data[0] = \<const0> ;
  assign test_pl_pll_lock_out[4] = \<const0> ;
  assign test_pl_pll_lock_out[3] = \<const0> ;
  assign test_pl_pll_lock_out[2] = \<const0> ;
  assign test_pl_pll_lock_out[1] = \<const0> ;
  assign test_pl_pll_lock_out[0] = \<const0> ;
  assign test_pl_scan_chopper_so = \<const0> ;
  assign test_pl_scan_edt_out_apu = \<const0> ;
  assign test_pl_scan_edt_out_cpu0 = \<const0> ;
  assign test_pl_scan_edt_out_cpu1 = \<const0> ;
  assign test_pl_scan_edt_out_cpu2 = \<const0> ;
  assign test_pl_scan_edt_out_cpu3 = \<const0> ;
  assign test_pl_scan_edt_out_ddr[3] = \<const0> ;
  assign test_pl_scan_edt_out_ddr[2] = \<const0> ;
  assign test_pl_scan_edt_out_ddr[1] = \<const0> ;
  assign test_pl_scan_edt_out_ddr[0] = \<const0> ;
  assign test_pl_scan_edt_out_fp[9] = \<const0> ;
  assign test_pl_scan_edt_out_fp[8] = \<const0> ;
  assign test_pl_scan_edt_out_fp[7] = \<const0> ;
  assign test_pl_scan_edt_out_fp[6] = \<const0> ;
  assign test_pl_scan_edt_out_fp[5] = \<const0> ;
  assign test_pl_scan_edt_out_fp[4] = \<const0> ;
  assign test_pl_scan_edt_out_fp[3] = \<const0> ;
  assign test_pl_scan_edt_out_fp[2] = \<const0> ;
  assign test_pl_scan_edt_out_fp[1] = \<const0> ;
  assign test_pl_scan_edt_out_fp[0] = \<const0> ;
  assign test_pl_scan_edt_out_gpu[3] = \<const0> ;
  assign test_pl_scan_edt_out_gpu[2] = \<const0> ;
  assign test_pl_scan_edt_out_gpu[1] = \<const0> ;
  assign test_pl_scan_edt_out_gpu[0] = \<const0> ;
  assign test_pl_scan_edt_out_lp[8] = \<const0> ;
  assign test_pl_scan_edt_out_lp[7] = \<const0> ;
  assign test_pl_scan_edt_out_lp[6] = \<const0> ;
  assign test_pl_scan_edt_out_lp[5] = \<const0> ;
  assign test_pl_scan_edt_out_lp[4] = \<const0> ;
  assign test_pl_scan_edt_out_lp[3] = \<const0> ;
  assign test_pl_scan_edt_out_lp[2] = \<const0> ;
  assign test_pl_scan_edt_out_lp[1] = \<const0> ;
  assign test_pl_scan_edt_out_lp[0] = \<const0> ;
  assign test_pl_scan_edt_out_usb3[1] = \<const0> ;
  assign test_pl_scan_edt_out_usb3[0] = \<const0> ;
  assign test_pl_scan_slcr_config_so = \<const0> ;
  assign test_pl_scan_spare_out0 = \<const0> ;
  assign test_pl_scan_spare_out1 = \<const0> ;
  assign tst_rtc_calibreg_out[20] = \<const0> ;
  assign tst_rtc_calibreg_out[19] = \<const0> ;
  assign tst_rtc_calibreg_out[18] = \<const0> ;
  assign tst_rtc_calibreg_out[17] = \<const0> ;
  assign tst_rtc_calibreg_out[16] = \<const0> ;
  assign tst_rtc_calibreg_out[15] = \<const0> ;
  assign tst_rtc_calibreg_out[14] = \<const0> ;
  assign tst_rtc_calibreg_out[13] = \<const0> ;
  assign tst_rtc_calibreg_out[12] = \<const0> ;
  assign tst_rtc_calibreg_out[11] = \<const0> ;
  assign tst_rtc_calibreg_out[10] = \<const0> ;
  assign tst_rtc_calibreg_out[9] = \<const0> ;
  assign tst_rtc_calibreg_out[8] = \<const0> ;
  assign tst_rtc_calibreg_out[7] = \<const0> ;
  assign tst_rtc_calibreg_out[6] = \<const0> ;
  assign tst_rtc_calibreg_out[5] = \<const0> ;
  assign tst_rtc_calibreg_out[4] = \<const0> ;
  assign tst_rtc_calibreg_out[3] = \<const0> ;
  assign tst_rtc_calibreg_out[2] = \<const0> ;
  assign tst_rtc_calibreg_out[1] = \<const0> ;
  assign tst_rtc_calibreg_out[0] = \<const0> ;
  assign tst_rtc_osc_clk_out = \<const0> ;
  assign tst_rtc_osc_cntrl_out[3] = \<const0> ;
  assign tst_rtc_osc_cntrl_out[2] = \<const0> ;
  assign tst_rtc_osc_cntrl_out[1] = \<const0> ;
  assign tst_rtc_osc_cntrl_out[0] = \<const0> ;
  assign tst_rtc_sec_counter_out[31] = \<const0> ;
  assign tst_rtc_sec_counter_out[30] = \<const0> ;
  assign tst_rtc_sec_counter_out[29] = \<const0> ;
  assign tst_rtc_sec_counter_out[28] = \<const0> ;
  assign tst_rtc_sec_counter_out[27] = \<const0> ;
  assign tst_rtc_sec_counter_out[26] = \<const0> ;
  assign tst_rtc_sec_counter_out[25] = \<const0> ;
  assign tst_rtc_sec_counter_out[24] = \<const0> ;
  assign tst_rtc_sec_counter_out[23] = \<const0> ;
  assign tst_rtc_sec_counter_out[22] = \<const0> ;
  assign tst_rtc_sec_counter_out[21] = \<const0> ;
  assign tst_rtc_sec_counter_out[20] = \<const0> ;
  assign tst_rtc_sec_counter_out[19] = \<const0> ;
  assign tst_rtc_sec_counter_out[18] = \<const0> ;
  assign tst_rtc_sec_counter_out[17] = \<const0> ;
  assign tst_rtc_sec_counter_out[16] = \<const0> ;
  assign tst_rtc_sec_counter_out[15] = \<const0> ;
  assign tst_rtc_sec_counter_out[14] = \<const0> ;
  assign tst_rtc_sec_counter_out[13] = \<const0> ;
  assign tst_rtc_sec_counter_out[12] = \<const0> ;
  assign tst_rtc_sec_counter_out[11] = \<const0> ;
  assign tst_rtc_sec_counter_out[10] = \<const0> ;
  assign tst_rtc_sec_counter_out[9] = \<const0> ;
  assign tst_rtc_sec_counter_out[8] = \<const0> ;
  assign tst_rtc_sec_counter_out[7] = \<const0> ;
  assign tst_rtc_sec_counter_out[6] = \<const0> ;
  assign tst_rtc_sec_counter_out[5] = \<const0> ;
  assign tst_rtc_sec_counter_out[4] = \<const0> ;
  assign tst_rtc_sec_counter_out[3] = \<const0> ;
  assign tst_rtc_sec_counter_out[2] = \<const0> ;
  assign tst_rtc_sec_counter_out[1] = \<const0> ;
  assign tst_rtc_sec_counter_out[0] = \<const0> ;
  assign tst_rtc_seconds_raw_int = \<const0> ;
  assign tst_rtc_tick_counter_out[15] = \<const0> ;
  assign tst_rtc_tick_counter_out[14] = \<const0> ;
  assign tst_rtc_tick_counter_out[13] = \<const0> ;
  assign tst_rtc_tick_counter_out[12] = \<const0> ;
  assign tst_rtc_tick_counter_out[11] = \<const0> ;
  assign tst_rtc_tick_counter_out[10] = \<const0> ;
  assign tst_rtc_tick_counter_out[9] = \<const0> ;
  assign tst_rtc_tick_counter_out[8] = \<const0> ;
  assign tst_rtc_tick_counter_out[7] = \<const0> ;
  assign tst_rtc_tick_counter_out[6] = \<const0> ;
  assign tst_rtc_tick_counter_out[5] = \<const0> ;
  assign tst_rtc_tick_counter_out[4] = \<const0> ;
  assign tst_rtc_tick_counter_out[3] = \<const0> ;
  assign tst_rtc_tick_counter_out[2] = \<const0> ;
  assign tst_rtc_tick_counter_out[1] = \<const0> ;
  assign tst_rtc_tick_counter_out[0] = \<const0> ;
  assign tst_rtc_timesetreg_out[31] = \<const0> ;
  assign tst_rtc_timesetreg_out[30] = \<const0> ;
  assign tst_rtc_timesetreg_out[29] = \<const0> ;
  assign tst_rtc_timesetreg_out[28] = \<const0> ;
  assign tst_rtc_timesetreg_out[27] = \<const0> ;
  assign tst_rtc_timesetreg_out[26] = \<const0> ;
  assign tst_rtc_timesetreg_out[25] = \<const0> ;
  assign tst_rtc_timesetreg_out[24] = \<const0> ;
  assign tst_rtc_timesetreg_out[23] = \<const0> ;
  assign tst_rtc_timesetreg_out[22] = \<const0> ;
  assign tst_rtc_timesetreg_out[21] = \<const0> ;
  assign tst_rtc_timesetreg_out[20] = \<const0> ;
  assign tst_rtc_timesetreg_out[19] = \<const0> ;
  assign tst_rtc_timesetreg_out[18] = \<const0> ;
  assign tst_rtc_timesetreg_out[17] = \<const0> ;
  assign tst_rtc_timesetreg_out[16] = \<const0> ;
  assign tst_rtc_timesetreg_out[15] = \<const0> ;
  assign tst_rtc_timesetreg_out[14] = \<const0> ;
  assign tst_rtc_timesetreg_out[13] = \<const0> ;
  assign tst_rtc_timesetreg_out[12] = \<const0> ;
  assign tst_rtc_timesetreg_out[11] = \<const0> ;
  assign tst_rtc_timesetreg_out[10] = \<const0> ;
  assign tst_rtc_timesetreg_out[9] = \<const0> ;
  assign tst_rtc_timesetreg_out[8] = \<const0> ;
  assign tst_rtc_timesetreg_out[7] = \<const0> ;
  assign tst_rtc_timesetreg_out[6] = \<const0> ;
  assign tst_rtc_timesetreg_out[5] = \<const0> ;
  assign tst_rtc_timesetreg_out[4] = \<const0> ;
  assign tst_rtc_timesetreg_out[3] = \<const0> ;
  assign tst_rtc_timesetreg_out[2] = \<const0> ;
  assign tst_rtc_timesetreg_out[1] = \<const0> ;
  assign tst_rtc_timesetreg_out[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* DONT_TOUCH *) 
  PS8 PS8_i
       (.ADMA2PLCACK(adma2pl_cack),
        .ADMA2PLTVLD(adma2pl_tvld),
        .ADMAFCICLK(adma_fci_clk),
        .AIBPMUAFIFMFPDACK(aib_pmu_afifm_fpd_ack),
        .AIBPMUAFIFMLPDACK(aib_pmu_afifm_lpd_ack),
        .DDRCEXTREFRESHRANK0REQ(ddrc_ext_refresh_rank0_req),
        .DDRCEXTREFRESHRANK1REQ(ddrc_ext_refresh_rank1_req),
        .DDRCREFRESHPLCLK(ddrc_refresh_pl_clk),
        .DPAUDIOREFCLK(NLW_PS8_i_DPAUDIOREFCLK_UNCONNECTED),
        .DPAUXDATAIN(dp_aux_data_in),
        .DPAUXDATAOEN(dp_aux_data_oe_n),
        .DPAUXDATAOUT(dp_aux_data_out),
        .DPEXTERNALCUSTOMEVENT1(dp_external_custom_event1),
        .DPEXTERNALCUSTOMEVENT2(dp_external_custom_event2),
        .DPEXTERNALVSYNCEVENT(dp_external_vsync_event),
        .DPHOTPLUGDETECT(dp_hot_plug_detect),
        .DPLIVEGFXALPHAIN(dp_live_gfx_alpha_in),
        .DPLIVEGFXPIXEL1IN(dp_live_gfx_pixel1_in),
        .DPLIVEVIDEODEOUT(dp_live_video_de_out),
        .DPLIVEVIDEOINDE(dp_live_video_in_de),
        .DPLIVEVIDEOINHSYNC(dp_live_video_in_hsync),
        .DPLIVEVIDEOINPIXEL1(dp_live_video_in_pixel1),
        .DPLIVEVIDEOINVSYNC(dp_live_video_in_vsync),
        .DPMAXISMIXEDAUDIOTDATA(dp_m_axis_mixed_audio_tdata),
        .DPMAXISMIXEDAUDIOTID(dp_m_axis_mixed_audio_tid),
        .DPMAXISMIXEDAUDIOTREADY(dp_m_axis_mixed_audio_tready),
        .DPMAXISMIXEDAUDIOTVALID(dp_m_axis_mixed_audio_tvalid),
        .DPSAXISAUDIOCLK(dp_s_axis_audio_clk),
        .DPSAXISAUDIOTDATA(dp_s_axis_audio_tdata),
        .DPSAXISAUDIOTID(dp_s_axis_audio_tid),
        .DPSAXISAUDIOTREADY(dp_s_axis_audio_tready),
        .DPSAXISAUDIOTVALID(dp_s_axis_audio_tvalid),
        .DPVIDEOINCLK(dp_video_in_clk),
        .DPVIDEOOUTHSYNC(dp_video_out_hsync),
        .DPVIDEOOUTPIXEL1(dp_video_out_pixel1),
        .DPVIDEOOUTVSYNC(dp_video_out_vsync),
        .DPVIDEOREFCLK(dp_video_ref_clk),
        .EMIOCAN0PHYRX(emio_can0_phy_rx),
        .EMIOCAN0PHYTX(emio_can0_phy_tx),
        .EMIOCAN1PHYRX(emio_can1_phy_rx),
        .EMIOCAN1PHYTX(emio_can1_phy_tx),
        .EMIOENET0DMABUSWIDTH(emio_enet0_dma_bus_width),
        .EMIOENET0DMATXENDTOG(emio_enet0_dma_tx_end_tog),
        .EMIOENET0DMATXSTATUSTOG(emio_enet0_dma_tx_status_tog),
        .EMIOENET0EXTINTIN(emio_enet0_ext_int_in),
        .EMIOENET0GEMTSUTIMERCNT(emio_enet0_enet_tsu_timer_cnt),
        .EMIOENET0GMIICOL(emio_enet0_gmii_col),
        .EMIOENET0GMIICRS(emio_enet0_gmii_crs),
        .EMIOENET0GMIIRXCLK(emio_enet0_gmii_rx_clk),
        .EMIOENET0GMIIRXD(emio_enet0_gmii_rxd),
        .EMIOENET0GMIIRXDV(emio_enet0_gmii_rx_dv),
        .EMIOENET0GMIIRXER(emio_enet0_gmii_rx_er),
        .EMIOENET0GMIITXCLK(emio_enet0_gmii_tx_clk),
        .EMIOENET0GMIITXD(emio_enet0_gmii_txd),
        .EMIOENET0GMIITXEN(emio_enet0_gmii_tx_en),
        .EMIOENET0GMIITXER(emio_enet0_gmii_tx_er),
        .EMIOENET0MDIOI(emio_enet0_mdio_i),
        .EMIOENET0MDIOMDC(emio_enet0_mdio_mdc),
        .EMIOENET0MDIOO(emio_enet0_mdio_o),
        .EMIOENET0MDIOTN(emio_enet0_mdio_t_n),
        .EMIOENET0RXWDATA(emio_enet0_rx_w_data),
        .EMIOENET0RXWEOP(emio_enet0_rx_w_eop),
        .EMIOENET0RXWERR(emio_enet0_rx_w_err),
        .EMIOENET0RXWFLUSH(emio_enet0_rx_w_flush),
        .EMIOENET0RXWOVERFLOW(emio_enet0_rx_w_overflow),
        .EMIOENET0RXWSOP(emio_enet0_rx_w_sop),
        .EMIOENET0RXWSTATUS(emio_enet0_rx_w_status),
        .EMIOENET0RXWWR(emio_enet0_rx_w_wr),
        .EMIOENET0SPEEDMODE(emio_enet0_speed_mode),
        .EMIOENET0TXRCONTROL(emio_enet0_tx_r_control),
        .EMIOENET0TXRDATA(emio_enet0_tx_r_data),
        .EMIOENET0TXRDATARDY(emio_enet0_tx_r_data_rdy),
        .EMIOENET0TXREOP(emio_enet0_tx_r_eop),
        .EMIOENET0TXRERR(emio_enet0_tx_r_err),
        .EMIOENET0TXRFLUSHED(emio_enet0_tx_r_flushed),
        .EMIOENET0TXRRD(emio_enet0_tx_r_rd),
        .EMIOENET0TXRSOP(emio_enet0_tx_r_sop),
        .EMIOENET0TXRSTATUS(emio_enet0_tx_r_status),
        .EMIOENET0TXRUNDERFLOW(emio_enet0_tx_r_underflow),
        .EMIOENET0TXRVALID(emio_enet0_tx_r_valid),
        .EMIOENET1DMABUSWIDTH(emio_enet1_dma_bus_width),
        .EMIOENET1DMATXENDTOG(emio_enet1_dma_tx_end_tog),
        .EMIOENET1DMATXSTATUSTOG(emio_enet1_dma_tx_status_tog),
        .EMIOENET1EXTINTIN(emio_enet1_ext_int_in),
        .EMIOENET1GMIICOL(emio_enet1_gmii_col),
        .EMIOENET1GMIICRS(emio_enet1_gmii_crs),
        .EMIOENET1GMIIRXCLK(emio_enet1_gmii_rx_clk),
        .EMIOENET1GMIIRXD(emio_enet1_gmii_rxd),
        .EMIOENET1GMIIRXDV(emio_enet1_gmii_rx_dv),
        .EMIOENET1GMIIRXER(emio_enet1_gmii_rx_er),
        .EMIOENET1GMIITXCLK(emio_enet1_gmii_tx_clk),
        .EMIOENET1GMIITXD(emio_enet1_gmii_txd),
        .EMIOENET1GMIITXEN(emio_enet1_gmii_tx_en),
        .EMIOENET1GMIITXER(emio_enet1_gmii_tx_er),
        .EMIOENET1MDIOI(emio_enet1_mdio_i),
        .EMIOENET1MDIOMDC(emio_enet1_mdio_mdc),
        .EMIOENET1MDIOO(emio_enet1_mdio_o),
        .EMIOENET1MDIOTN(emio_enet1_mdio_t_n),
        .EMIOENET1RXWDATA(emio_enet1_rx_w_data),
        .EMIOENET1RXWEOP(emio_enet1_rx_w_eop),
        .EMIOENET1RXWERR(emio_enet1_rx_w_err),
        .EMIOENET1RXWFLUSH(emio_enet1_rx_w_flush),
        .EMIOENET1RXWOVERFLOW(emio_enet1_rx_w_overflow),
        .EMIOENET1RXWSOP(emio_enet1_rx_w_sop),
        .EMIOENET1RXWSTATUS(emio_enet1_rx_w_status),
        .EMIOENET1RXWWR(emio_enet1_rx_w_wr),
        .EMIOENET1SPEEDMODE(emio_enet1_speed_mode),
        .EMIOENET1TXRCONTROL(emio_enet1_tx_r_control),
        .EMIOENET1TXRDATA(emio_enet1_tx_r_data),
        .EMIOENET1TXRDATARDY(emio_enet1_tx_r_data_rdy),
        .EMIOENET1TXREOP(emio_enet1_tx_r_eop),
        .EMIOENET1TXRERR(emio_enet1_tx_r_err),
        .EMIOENET1TXRFLUSHED(emio_enet1_tx_r_flushed),
        .EMIOENET1TXRRD(emio_enet1_tx_r_rd),
        .EMIOENET1TXRSOP(emio_enet1_tx_r_sop),
        .EMIOENET1TXRSTATUS(emio_enet1_tx_r_status),
        .EMIOENET1TXRUNDERFLOW(emio_enet1_tx_r_underflow),
        .EMIOENET1TXRVALID(emio_enet1_tx_r_valid),
        .EMIOENET2DMABUSWIDTH(emio_enet2_dma_bus_width),
        .EMIOENET2DMATXENDTOG(emio_enet2_dma_tx_end_tog),
        .EMIOENET2DMATXSTATUSTOG(emio_enet2_dma_tx_status_tog),
        .EMIOENET2EXTINTIN(emio_enet2_ext_int_in),
        .EMIOENET2GMIICOL(emio_enet2_gmii_col),
        .EMIOENET2GMIICRS(emio_enet2_gmii_crs),
        .EMIOENET2GMIIRXCLK(emio_enet2_gmii_rx_clk),
        .EMIOENET2GMIIRXD(emio_enet2_gmii_rxd),
        .EMIOENET2GMIIRXDV(emio_enet2_gmii_rx_dv),
        .EMIOENET2GMIIRXER(emio_enet2_gmii_rx_er),
        .EMIOENET2GMIITXCLK(emio_enet2_gmii_tx_clk),
        .EMIOENET2GMIITXD(emio_enet2_gmii_txd),
        .EMIOENET2GMIITXEN(emio_enet2_gmii_tx_en),
        .EMIOENET2GMIITXER(emio_enet2_gmii_tx_er),
        .EMIOENET2MDIOI(emio_enet2_mdio_i),
        .EMIOENET2MDIOMDC(emio_enet2_mdio_mdc),
        .EMIOENET2MDIOO(emio_enet2_mdio_o),
        .EMIOENET2MDIOTN(emio_enet2_mdio_t_n),
        .EMIOENET2RXWDATA(emio_enet2_rx_w_data),
        .EMIOENET2RXWEOP(emio_enet2_rx_w_eop),
        .EMIOENET2RXWERR(emio_enet2_rx_w_err),
        .EMIOENET2RXWFLUSH(emio_enet2_rx_w_flush),
        .EMIOENET2RXWOVERFLOW(emio_enet2_rx_w_overflow),
        .EMIOENET2RXWSOP(emio_enet2_rx_w_sop),
        .EMIOENET2RXWSTATUS(emio_enet2_rx_w_status),
        .EMIOENET2RXWWR(emio_enet2_rx_w_wr),
        .EMIOENET2SPEEDMODE(emio_enet2_speed_mode),
        .EMIOENET2TXRCONTROL(emio_enet2_tx_r_control),
        .EMIOENET2TXRDATA(emio_enet2_tx_r_data),
        .EMIOENET2TXRDATARDY(emio_enet2_tx_r_data_rdy),
        .EMIOENET2TXREOP(emio_enet2_tx_r_eop),
        .EMIOENET2TXRERR(emio_enet2_tx_r_err),
        .EMIOENET2TXRFLUSHED(emio_enet2_tx_r_flushed),
        .EMIOENET2TXRRD(emio_enet2_tx_r_rd),
        .EMIOENET2TXRSOP(emio_enet2_tx_r_sop),
        .EMIOENET2TXRSTATUS(emio_enet2_tx_r_status),
        .EMIOENET2TXRUNDERFLOW(emio_enet2_tx_r_underflow),
        .EMIOENET2TXRVALID(emio_enet2_tx_r_valid),
        .EMIOENET3DMABUSWIDTH(emio_enet3_dma_bus_width),
        .EMIOENET3DMATXENDTOG(emio_enet3_dma_tx_end_tog),
        .EMIOENET3DMATXSTATUSTOG(emio_enet3_dma_tx_status_tog),
        .EMIOENET3EXTINTIN(emio_enet3_ext_int_in),
        .EMIOENET3GMIICOL(emio_enet3_gmii_col),
        .EMIOENET3GMIICRS(emio_enet3_gmii_crs),
        .EMIOENET3GMIIRXCLK(emio_enet3_gmii_rx_clk),
        .EMIOENET3GMIIRXD(emio_enet3_gmii_rxd),
        .EMIOENET3GMIIRXDV(emio_enet3_gmii_rx_dv),
        .EMIOENET3GMIIRXER(emio_enet3_gmii_rx_er),
        .EMIOENET3GMIITXCLK(emio_enet3_gmii_tx_clk),
        .EMIOENET3GMIITXD(emio_enet3_gmii_txd),
        .EMIOENET3GMIITXEN(emio_enet3_gmii_tx_en),
        .EMIOENET3GMIITXER(emio_enet3_gmii_tx_er),
        .EMIOENET3MDIOI(emio_enet3_mdio_i),
        .EMIOENET3MDIOMDC(emio_enet3_mdio_mdc),
        .EMIOENET3MDIOO(emio_enet3_mdio_o),
        .EMIOENET3MDIOTN(emio_enet3_mdio_t_n),
        .EMIOENET3RXWDATA(emio_enet3_rx_w_data),
        .EMIOENET3RXWEOP(emio_enet3_rx_w_eop),
        .EMIOENET3RXWERR(emio_enet3_rx_w_err),
        .EMIOENET3RXWFLUSH(emio_enet3_rx_w_flush),
        .EMIOENET3RXWOVERFLOW(emio_enet3_rx_w_overflow),
        .EMIOENET3RXWSOP(emio_enet3_rx_w_sop),
        .EMIOENET3RXWSTATUS(emio_enet3_rx_w_status),
        .EMIOENET3RXWWR(emio_enet3_rx_w_wr),
        .EMIOENET3SPEEDMODE(emio_enet3_speed_mode),
        .EMIOENET3TXRCONTROL(emio_enet3_tx_r_control),
        .EMIOENET3TXRDATA(emio_enet3_tx_r_data),
        .EMIOENET3TXRDATARDY(emio_enet3_tx_r_data_rdy),
        .EMIOENET3TXREOP(emio_enet3_tx_r_eop),
        .EMIOENET3TXRERR(emio_enet3_tx_r_err),
        .EMIOENET3TXRFLUSHED(emio_enet3_tx_r_flushed),
        .EMIOENET3TXRRD(emio_enet3_tx_r_rd),
        .EMIOENET3TXRSOP(emio_enet3_tx_r_sop),
        .EMIOENET3TXRSTATUS(emio_enet3_tx_r_status),
        .EMIOENET3TXRUNDERFLOW(emio_enet3_tx_r_underflow),
        .EMIOENET3TXRVALID(emio_enet3_tx_r_valid),
        .EMIOENETTSUCLK(emio_enet_tsu_clk),
        .EMIOGEM0DELAYREQRX(emio_enet0_delay_req_rx),
        .EMIOGEM0DELAYREQTX(emio_enet0_delay_req_tx),
        .EMIOGEM0PDELAYREQRX(emio_enet0_pdelay_req_rx),
        .EMIOGEM0PDELAYREQTX(emio_enet0_pdelay_req_tx),
        .EMIOGEM0PDELAYRESPRX(emio_enet0_pdelay_resp_rx),
        .EMIOGEM0PDELAYRESPTX(emio_enet0_pdelay_resp_tx),
        .EMIOGEM0RXSOF(emio_enet0_rx_sof),
        .EMIOGEM0SYNCFRAMERX(emio_enet0_sync_frame_rx),
        .EMIOGEM0SYNCFRAMETX(emio_enet0_sync_frame_tx),
        .EMIOGEM0TSUINCCTRL(emio_enet0_tsu_inc_ctrl),
        .EMIOGEM0TSUTIMERCMPVAL(emio_enet0_tsu_timer_cmp_val),
        .EMIOGEM0TXRFIXEDLAT(emio_enet0_tx_r_fixed_lat),
        .EMIOGEM0TXSOF(emio_enet0_tx_sof),
        .EMIOGEM1DELAYREQRX(emio_enet1_delay_req_rx),
        .EMIOGEM1DELAYREQTX(emio_enet1_delay_req_tx),
        .EMIOGEM1PDELAYREQRX(emio_enet1_pdelay_req_rx),
        .EMIOGEM1PDELAYREQTX(emio_enet1_pdelay_req_tx),
        .EMIOGEM1PDELAYRESPRX(emio_enet1_pdelay_resp_rx),
        .EMIOGEM1PDELAYRESPTX(emio_enet1_pdelay_resp_tx),
        .EMIOGEM1RXSOF(emio_enet1_rx_sof),
        .EMIOGEM1SYNCFRAMERX(emio_enet1_sync_frame_rx),
        .EMIOGEM1SYNCFRAMETX(emio_enet1_sync_frame_tx),
        .EMIOGEM1TSUINCCTRL(emio_enet1_tsu_inc_ctrl),
        .EMIOGEM1TSUTIMERCMPVAL(emio_enet1_tsu_timer_cmp_val),
        .EMIOGEM1TXRFIXEDLAT(emio_enet1_tx_r_fixed_lat),
        .EMIOGEM1TXSOF(emio_enet1_tx_sof),
        .EMIOGEM2DELAYREQRX(emio_enet2_delay_req_rx),
        .EMIOGEM2DELAYREQTX(emio_enet2_delay_req_tx),
        .EMIOGEM2PDELAYREQRX(emio_enet2_pdelay_req_rx),
        .EMIOGEM2PDELAYREQTX(emio_enet2_pdelay_req_tx),
        .EMIOGEM2PDELAYRESPRX(emio_enet2_pdelay_resp_rx),
        .EMIOGEM2PDELAYRESPTX(emio_enet2_pdelay_resp_tx),
        .EMIOGEM2RXSOF(emio_enet2_rx_sof),
        .EMIOGEM2SYNCFRAMERX(emio_enet2_sync_frame_rx),
        .EMIOGEM2SYNCFRAMETX(emio_enet2_sync_frame_tx),
        .EMIOGEM2TSUINCCTRL(emio_enet2_tsu_inc_ctrl),
        .EMIOGEM2TSUTIMERCMPVAL(emio_enet2_tsu_timer_cmp_val),
        .EMIOGEM2TXRFIXEDLAT(emio_enet2_tx_r_fixed_lat),
        .EMIOGEM2TXSOF(emio_enet2_tx_sof),
        .EMIOGEM3DELAYREQRX(emio_enet3_delay_req_rx),
        .EMIOGEM3DELAYREQTX(emio_enet3_delay_req_tx),
        .EMIOGEM3PDELAYREQRX(emio_enet3_pdelay_req_rx),
        .EMIOGEM3PDELAYREQTX(emio_enet3_pdelay_req_tx),
        .EMIOGEM3PDELAYRESPRX(emio_enet3_pdelay_resp_rx),
        .EMIOGEM3PDELAYRESPTX(emio_enet3_pdelay_resp_tx),
        .EMIOGEM3RXSOF(emio_enet3_rx_sof),
        .EMIOGEM3SYNCFRAMERX(emio_enet3_sync_frame_rx),
        .EMIOGEM3SYNCFRAMETX(emio_enet3_sync_frame_tx),
        .EMIOGEM3TSUINCCTRL(emio_enet3_tsu_inc_ctrl),
        .EMIOGEM3TSUTIMERCMPVAL(emio_enet3_tsu_timer_cmp_val),
        .EMIOGEM3TXRFIXEDLAT(emio_enet3_tx_r_fixed_lat),
        .EMIOGEM3TXSOF(emio_enet3_tx_sof),
        .EMIOGPIOI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,emio_gpio_i}),
        .EMIOGPIOO({pl_resetn0,NLW_PS8_i_EMIOGPIOO_UNCONNECTED[94:1],emio_gpio_o}),
        .EMIOGPIOTN({NLW_PS8_i_EMIOGPIOTN_UNCONNECTED[95:1],emio_gpio_t_n}),
        .EMIOHUBPORTOVERCRNTUSB20(emio_hub_port_overcrnt_usb2_0),
        .EMIOHUBPORTOVERCRNTUSB21(emio_hub_port_overcrnt_usb2_1),
        .EMIOHUBPORTOVERCRNTUSB30(emio_hub_port_overcrnt_usb3_0),
        .EMIOHUBPORTOVERCRNTUSB31(emio_hub_port_overcrnt_usb3_1),
        .EMIOI2C0SCLI(emio_i2c0_scl_i),
        .EMIOI2C0SCLO(emio_i2c0_scl_o),
        .EMIOI2C0SCLTN(emio_i2c0_scl_t_n),
        .EMIOI2C0SDAI(emio_i2c0_sda_i),
        .EMIOI2C0SDAO(emio_i2c0_sda_o),
        .EMIOI2C0SDATN(emio_i2c0_sda_t_n),
        .EMIOI2C1SCLI(emio_i2c1_scl_i),
        .EMIOI2C1SCLO(emio_i2c1_scl_o),
        .EMIOI2C1SCLTN(emio_i2c1_scl_t_n),
        .EMIOI2C1SDAI(emio_i2c1_sda_i),
        .EMIOI2C1SDAO(emio_i2c1_sda_o),
        .EMIOI2C1SDATN(emio_i2c1_sda_t_n),
        .EMIOSDIO0BUSPOWER(emio_sdio0_buspower),
        .EMIOSDIO0BUSVOLT(emio_sdio0_bus_volt),
        .EMIOSDIO0CDN(emio_sdio0_cd_n),
        .EMIOSDIO0CLKOUT(emio_sdio0_clkout),
        .EMIOSDIO0CMDENA(emio_sdio0_cmdena_i),
        .EMIOSDIO0CMDIN(emio_sdio0_cmdin),
        .EMIOSDIO0CMDOUT(emio_sdio0_cmdout),
        .EMIOSDIO0DATAENA(emio_sdio0_dataena_i),
        .EMIOSDIO0DATAIN(emio_sdio0_datain),
        .EMIOSDIO0DATAOUT(emio_sdio0_dataout),
        .EMIOSDIO0FBCLKIN(emio_sdio0_fb_clk_in),
        .EMIOSDIO0LEDCONTROL(emio_sdio0_ledcontrol),
        .EMIOSDIO0WP(emio_sdio0_wp),
        .EMIOSDIO1BUSPOWER(emio_sdio1_buspower),
        .EMIOSDIO1BUSVOLT(emio_sdio1_bus_volt),
        .EMIOSDIO1CDN(emio_sdio1_cd_n),
        .EMIOSDIO1CLKOUT(emio_sdio1_clkout),
        .EMIOSDIO1CMDENA(emio_sdio1_cmdena_i),
        .EMIOSDIO1CMDIN(emio_sdio1_cmdin),
        .EMIOSDIO1CMDOUT(emio_sdio1_cmdout),
        .EMIOSDIO1DATAENA(emio_sdio1_dataena_i),
        .EMIOSDIO1DATAIN(emio_sdio1_datain),
        .EMIOSDIO1DATAOUT(emio_sdio1_dataout),
        .EMIOSDIO1FBCLKIN(emio_sdio1_fb_clk_in),
        .EMIOSDIO1LEDCONTROL(emio_sdio1_ledcontrol),
        .EMIOSDIO1WP(emio_sdio1_wp),
        .EMIOSPI0MI(emio_spi0_m_i),
        .EMIOSPI0MO(emio_spi0_m_o),
        .EMIOSPI0MOTN(emio_spi0_mo_t_n),
        .EMIOSPI0SCLKI(emio_spi0_sclk_i),
        .EMIOSPI0SCLKO(emio_spi0_sclk_o),
        .EMIOSPI0SCLKTN(emio_spi0_sclk_t_n),
        .EMIOSPI0SI(emio_spi0_s_i),
        .EMIOSPI0SO(emio_spi0_s_o),
        .EMIOSPI0SSIN(emio_spi0_ss_i_n),
        .EMIOSPI0SSNTN(emio_spi0_ss_n_t_n),
        .EMIOSPI0SSON({emio_spi0_ss2_o_n,emio_spi0_ss1_o_n,emio_spi0_ss_o_n}),
        .EMIOSPI0STN(emio_spi0_so_t_n),
        .EMIOSPI1MI(emio_spi1_m_i),
        .EMIOSPI1MO(emio_spi1_m_o),
        .EMIOSPI1MOTN(emio_spi1_mo_t_n),
        .EMIOSPI1SCLKI(emio_spi1_sclk_i),
        .EMIOSPI1SCLKO(emio_spi1_sclk_o),
        .EMIOSPI1SCLKTN(emio_spi1_sclk_t_n),
        .EMIOSPI1SI(emio_spi1_s_i),
        .EMIOSPI1SO(emio_spi1_s_o),
        .EMIOSPI1SSIN(emio_spi1_ss_i_n),
        .EMIOSPI1SSNTN(emio_spi1_ss_n_t_n),
        .EMIOSPI1SSON({emio_spi1_ss2_o_n,emio_spi1_ss1_o_n,emio_spi1_ss_o_n}),
        .EMIOSPI1STN(emio_spi1_so_t_n),
        .EMIOTTC0CLKI(emio_ttc0_clk_i),
        .EMIOTTC0WAVEO(emio_ttc0_wave_o),
        .EMIOTTC1CLKI(emio_ttc1_clk_i),
        .EMIOTTC1WAVEO(emio_ttc1_wave_o),
        .EMIOTTC2CLKI(emio_ttc2_clk_i),
        .EMIOTTC2WAVEO(emio_ttc2_wave_o),
        .EMIOTTC3CLKI(emio_ttc3_clk_i),
        .EMIOTTC3WAVEO(emio_ttc3_wave_o),
        .EMIOU2DSPORTVBUSCTRLUSB30(emio_u2dsport_vbus_ctrl_usb3_0),
        .EMIOU2DSPORTVBUSCTRLUSB31(emio_u2dsport_vbus_ctrl_usb3_1),
        .EMIOU3DSPORTVBUSCTRLUSB30(emio_u3dsport_vbus_ctrl_usb3_0),
        .EMIOU3DSPORTVBUSCTRLUSB31(emio_u3dsport_vbus_ctrl_usb3_1),
        .EMIOUART0CTSN(emio_uart0_ctsn),
        .EMIOUART0DCDN(emio_uart0_dcdn),
        .EMIOUART0DSRN(emio_uart0_dsrn),
        .EMIOUART0DTRN(emio_uart0_dtrn),
        .EMIOUART0RIN(emio_uart0_rin),
        .EMIOUART0RTSN(emio_uart0_rtsn),
        .EMIOUART0RX(emio_uart0_rxd),
        .EMIOUART0TX(emio_uart0_txd),
        .EMIOUART1CTSN(emio_uart1_ctsn),
        .EMIOUART1DCDN(emio_uart1_dcdn),
        .EMIOUART1DSRN(emio_uart1_dsrn),
        .EMIOUART1DTRN(emio_uart1_dtrn),
        .EMIOUART1RIN(emio_uart1_rin),
        .EMIOUART1RTSN(emio_uart1_rtsn),
        .EMIOUART1RX(emio_uart1_rxd),
        .EMIOUART1TX(emio_uart1_txd),
        .EMIOWDT0CLKI(emio_wdt0_clk_i),
        .EMIOWDT0RSTO(emio_wdt0_rst_o),
        .EMIOWDT1CLKI(emio_wdt1_clk_i),
        .EMIOWDT1RSTO(emio_wdt1_rst_o),
        .FMIOGEM0FIFORXCLKFROMPL(1'b0),
        .FMIOGEM0FIFORXCLKTOPLBUFG(fmio_gem0_fifo_rx_clk_to_pl_bufg),
        .FMIOGEM0FIFOTXCLKFROMPL(1'b0),
        .FMIOGEM0FIFOTXCLKTOPLBUFG(fmio_gem0_fifo_tx_clk_to_pl_bufg),
        .FMIOGEM0SIGNALDETECT(emio_enet0_signal_detect),
        .FMIOGEM1FIFORXCLKFROMPL(1'b0),
        .FMIOGEM1FIFORXCLKTOPLBUFG(fmio_gem1_fifo_rx_clk_to_pl_bufg),
        .FMIOGEM1FIFOTXCLKFROMPL(1'b0),
        .FMIOGEM1FIFOTXCLKTOPLBUFG(fmio_gem1_fifo_tx_clk_to_pl_bufg),
        .FMIOGEM1SIGNALDETECT(emio_enet1_signal_detect),
        .FMIOGEM2FIFORXCLKFROMPL(1'b0),
        .FMIOGEM2FIFORXCLKTOPLBUFG(fmio_gem2_fifo_rx_clk_to_pl_bufg),
        .FMIOGEM2FIFOTXCLKFROMPL(1'b0),
        .FMIOGEM2FIFOTXCLKTOPLBUFG(fmio_gem2_fifo_tx_clk_to_pl_bufg),
        .FMIOGEM2SIGNALDETECT(emio_enet2_signal_detect),
        .FMIOGEM3FIFORXCLKFROMPL(1'b0),
        .FMIOGEM3FIFORXCLKTOPLBUFG(fmio_gem3_fifo_rx_clk_to_pl_bufg),
        .FMIOGEM3FIFOTXCLKFROMPL(1'b0),
        .FMIOGEM3FIFOTXCLKTOPLBUFG(fmio_gem3_fifo_tx_clk_to_pl_bufg),
        .FMIOGEM3SIGNALDETECT(emio_enet3_signal_detect),
        .FMIOGEMTSUCLKFROMPL(fmio_gem_tsu_clk_from_pl),
        .FMIOGEMTSUCLKTOPLBUFG(fmio_gem_tsu_clk_to_pl_bufg),
        .FTMGPI(ftm_gpi),
        .FTMGPO(ftm_gpo),
        .GDMA2PLCACK(gdma_perif_cack),
        .GDMA2PLTVLD(gdma_perif_tvld),
        .GDMAFCICLK(perif_gdma_clk),
        .MAXIGP0ACLK(maxihpm0_fpd_aclk),
        .MAXIGP0ARADDR(maxigp0_araddr),
        .MAXIGP0ARBURST(maxigp0_arburst),
        .MAXIGP0ARCACHE(maxigp0_arcache),
        .MAXIGP0ARID(maxigp0_arid),
        .MAXIGP0ARLEN(maxigp0_arlen),
        .MAXIGP0ARLOCK(maxigp0_arlock),
        .MAXIGP0ARPROT(maxigp0_arprot),
        .MAXIGP0ARQOS(maxigp0_arqos),
        .MAXIGP0ARREADY(maxigp0_arready),
        .MAXIGP0ARSIZE(maxigp0_arsize),
        .MAXIGP0ARUSER(maxigp0_aruser),
        .MAXIGP0ARVALID(maxigp0_arvalid),
        .MAXIGP0AWADDR(maxigp0_awaddr),
        .MAXIGP0AWBURST(maxigp0_awburst),
        .MAXIGP0AWCACHE(maxigp0_awcache),
        .MAXIGP0AWID(maxigp0_awid),
        .MAXIGP0AWLEN(maxigp0_awlen),
        .MAXIGP0AWLOCK(maxigp0_awlock),
        .MAXIGP0AWPROT(maxigp0_awprot),
        .MAXIGP0AWQOS(maxigp0_awqos),
        .MAXIGP0AWREADY(maxigp0_awready),
        .MAXIGP0AWSIZE(maxigp0_awsize),
        .MAXIGP0AWUSER(maxigp0_awuser),
        .MAXIGP0AWVALID(maxigp0_awvalid),
        .MAXIGP0BID(maxigp0_bid),
        .MAXIGP0BREADY(maxigp0_bready),
        .MAXIGP0BRESP(maxigp0_bresp),
        .MAXIGP0BVALID(maxigp0_bvalid),
        .MAXIGP0RDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,maxigp0_rdata}),
        .MAXIGP0RID(maxigp0_rid),
        .MAXIGP0RLAST(maxigp0_rlast),
        .MAXIGP0RREADY(maxigp0_rready),
        .MAXIGP0RRESP(maxigp0_rresp),
        .MAXIGP0RVALID(maxigp0_rvalid),
        .MAXIGP0WDATA({NLW_PS8_i_MAXIGP0WDATA_UNCONNECTED[127:32],maxigp0_wdata}),
        .MAXIGP0WLAST(maxigp0_wlast),
        .MAXIGP0WREADY(maxigp0_wready),
        .MAXIGP0WSTRB({NLW_PS8_i_MAXIGP0WSTRB_UNCONNECTED[15:4],maxigp0_wstrb}),
        .MAXIGP0WVALID(maxigp0_wvalid),
        .MAXIGP1ACLK(maxihpm1_fpd_aclk),
        .MAXIGP1ARADDR(maxigp1_araddr),
        .MAXIGP1ARBURST(maxigp1_arburst),
        .MAXIGP1ARCACHE(maxigp1_arcache),
        .MAXIGP1ARID(maxigp1_arid),
        .MAXIGP1ARLEN(maxigp1_arlen),
        .MAXIGP1ARLOCK(maxigp1_arlock),
        .MAXIGP1ARPROT(maxigp1_arprot),
        .MAXIGP1ARQOS(maxigp1_arqos),
        .MAXIGP1ARREADY(maxigp1_arready),
        .MAXIGP1ARSIZE(maxigp1_arsize),
        .MAXIGP1ARUSER(maxigp1_aruser),
        .MAXIGP1ARVALID(maxigp1_arvalid),
        .MAXIGP1AWADDR(maxigp1_awaddr),
        .MAXIGP1AWBURST(maxigp1_awburst),
        .MAXIGP1AWCACHE(maxigp1_awcache),
        .MAXIGP1AWID(maxigp1_awid),
        .MAXIGP1AWLEN(maxigp1_awlen),
        .MAXIGP1AWLOCK(maxigp1_awlock),
        .MAXIGP1AWPROT(maxigp1_awprot),
        .MAXIGP1AWQOS(maxigp1_awqos),
        .MAXIGP1AWREADY(maxigp1_awready),
        .MAXIGP1AWSIZE(maxigp1_awsize),
        .MAXIGP1AWUSER(maxigp1_awuser),
        .MAXIGP1AWVALID(maxigp1_awvalid),
        .MAXIGP1BID(maxigp1_bid),
        .MAXIGP1BREADY(maxigp1_bready),
        .MAXIGP1BRESP(maxigp1_bresp),
        .MAXIGP1BVALID(maxigp1_bvalid),
        .MAXIGP1RDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,maxigp1_rdata}),
        .MAXIGP1RID(maxigp1_rid),
        .MAXIGP1RLAST(maxigp1_rlast),
        .MAXIGP1RREADY(maxigp1_rready),
        .MAXIGP1RRESP(maxigp1_rresp),
        .MAXIGP1RVALID(maxigp1_rvalid),
        .MAXIGP1WDATA({NLW_PS8_i_MAXIGP1WDATA_UNCONNECTED[127:32],maxigp1_wdata}),
        .MAXIGP1WLAST(maxigp1_wlast),
        .MAXIGP1WREADY(maxigp1_wready),
        .MAXIGP1WSTRB({NLW_PS8_i_MAXIGP1WSTRB_UNCONNECTED[15:4],maxigp1_wstrb}),
        .MAXIGP1WVALID(maxigp1_wvalid),
        .MAXIGP2ACLK(maxihpm0_lpd_aclk),
        .MAXIGP2ARADDR(maxigp2_araddr),
        .MAXIGP2ARBURST(maxigp2_arburst),
        .MAXIGP2ARCACHE(maxigp2_arcache),
        .MAXIGP2ARID(maxigp2_arid),
        .MAXIGP2ARLEN(maxigp2_arlen),
        .MAXIGP2ARLOCK(maxigp2_arlock),
        .MAXIGP2ARPROT(maxigp2_arprot),
        .MAXIGP2ARQOS(maxigp2_arqos),
        .MAXIGP2ARREADY(maxigp2_arready),
        .MAXIGP2ARSIZE(maxigp2_arsize),
        .MAXIGP2ARUSER(maxigp2_aruser),
        .MAXIGP2ARVALID(maxigp2_arvalid),
        .MAXIGP2AWADDR(maxigp2_awaddr),
        .MAXIGP2AWBURST(maxigp2_awburst),
        .MAXIGP2AWCACHE(maxigp2_awcache),
        .MAXIGP2AWID(maxigp2_awid),
        .MAXIGP2AWLEN(maxigp2_awlen),
        .MAXIGP2AWLOCK(maxigp2_awlock),
        .MAXIGP2AWPROT(maxigp2_awprot),
        .MAXIGP2AWQOS(maxigp2_awqos),
        .MAXIGP2AWREADY(maxigp2_awready),
        .MAXIGP2AWSIZE(maxigp2_awsize),
        .MAXIGP2AWUSER(maxigp2_awuser),
        .MAXIGP2AWVALID(maxigp2_awvalid),
        .MAXIGP2BID(maxigp2_bid),
        .MAXIGP2BREADY(maxigp2_bready),
        .MAXIGP2BRESP(maxigp2_bresp),
        .MAXIGP2BVALID(maxigp2_bvalid),
        .MAXIGP2RDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,maxigp2_rdata}),
        .MAXIGP2RID(maxigp2_rid),
        .MAXIGP2RLAST(maxigp2_rlast),
        .MAXIGP2RREADY(maxigp2_rready),
        .MAXIGP2RRESP(maxigp2_rresp),
        .MAXIGP2RVALID(maxigp2_rvalid),
        .MAXIGP2WDATA({NLW_PS8_i_MAXIGP2WDATA_UNCONNECTED[127:32],maxigp2_wdata}),
        .MAXIGP2WLAST(maxigp2_wlast),
        .MAXIGP2WREADY(maxigp2_wready),
        .MAXIGP2WSTRB({NLW_PS8_i_MAXIGP2WSTRB_UNCONNECTED[15:4],maxigp2_wstrb}),
        .MAXIGP2WVALID(maxigp2_wvalid),
        .NFIQ0LPDRPU(nfiq0_lpd_rpu),
        .NFIQ1LPDRPU(nfiq1_lpd_rpu),
        .NIRQ0LPDRPU(nirq0_lpd_rpu),
        .NIRQ1LPDRPU(nirq1_lpd_rpu),
        .OSCRTCCLK(osc_rtc_clk),
        .PL2ADMACVLD(pl2adma_cvld),
        .PL2ADMATACK(pl2adma_tack),
        .PL2GDMACVLD(perif_gdma_cvld),
        .PL2GDMATACK(perif_gdma_tack),
        .PLACECLK(sacefpd_aclk),
        .PLACPINACT(pl_acpinact),
        .PLCLK({pl_clk3,pl_clk2,pl_clk1,pl_clk_unbuffered}),
        .PLFPGASTOP(pl_clock_stop),
        .PLLAUXREFCLKFPD(pll_aux_refclk_fpd),
        .PLLAUXREFCLKLPD(pll_aux_refclk_lpd),
        .PLPMUGPI(pl_pmu_gpi),
        .PLPSAPUGICFIQ(pl_ps_apugic_fiq),
        .PLPSAPUGICIRQ(pl_ps_apugic_irq),
        .PLPSEVENTI(pl_ps_eventi),
        .PLPSIRQ0({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,pl_ps_irq0}),
        .PLPSIRQ1({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,pl_ps_irq1}),
        .PLPSTRACECLK(pl_ps_trace_clk),
        .PLPSTRIGACK({pl_ps_trigack_3,pl_ps_trigack_2,pl_ps_trigack_1,pl_ps_trigack_0}),
        .PLPSTRIGGER({pl_ps_trigger_3,pl_ps_trigger_2,pl_ps_trigger_1,pl_ps_trigger_0}),
        .PMUAIBAFIFMFPDREQ(pmu_aib_afifm_fpd_req),
        .PMUAIBAFIFMLPDREQ(pmu_aib_afifm_lpd_req),
        .PMUERRORFROMPL(pmu_error_from_pl),
        .PMUERRORTOPL(pmu_error_to_pl),
        .PMUPLGPO(pmu_pl_gpo),
        .PSPLEVENTO(ps_pl_evento),
        .PSPLIRQFPD({NLW_PS8_i_PSPLIRQFPD_UNCONNECTED[63:56],ps_pl_irq_intf_fpd_smmu,ps_pl_irq_intf_ppd_cci,ps_pl_irq_apu_regs,ps_pl_irq_apu_exterr,ps_pl_irq_apu_l2err,ps_pl_irq_apu_comm,ps_pl_irq_apu_pmu,ps_pl_irq_apu_cti,ps_pl_irq_apu_cpumnt,ps_pl_irq_xmpu_fpd,ps_pl_irq_sata,ps_pl_irq_gpu,ps_pl_irq_gdma_chan,ps_pl_irq_apm_fpd,ps_pl_irq_dpdma,ps_pl_irq_fpd_atb_error,ps_pl_irq_fpd_apb_int,ps_pl_irq_dport,ps_pl_irq_pcie_msc,ps_pl_irq_pcie_dma,ps_pl_irq_pcie_legacy,ps_pl_irq_pcie_msi,ps_pl_irq_fp_wdt,ps_pl_irq_ddr_ss,NLW_PS8_i_PSPLIRQFPD_UNCONNECTED[11:0]}),
        .PSPLIRQLPD({NLW_PS8_i_PSPLIRQLPD_UNCONNECTED[99:89],ps_pl_irq_xmpu_lpd,ps_pl_irq_efuse,ps_pl_irq_csu_dma,ps_pl_irq_csu,ps_pl_irq_adma_chan,ps_pl_irq_usb3_0_pmu_wakeup,ps_pl_irq_usb3_1_otg,ps_pl_irq_usb3_1_endpoint,ps_pl_irq_usb3_0_otg,ps_pl_irq_usb3_0_endpoint,ps_pl_irq_enet3_wake,ps_pl_irq_enet3,ps_pl_irq_enet2_wake,ps_pl_irq_enet2,ps_pl_irq_enet1_wake,ps_pl_irq_enet1,ps_pl_irq_enet0_wake,ps_pl_irq_enet0,ps_pl_irq_ams,ps_pl_irq_aib_axi,ps_pl_irq_atb_err_lpd,ps_pl_irq_csu_pmu_wdt,ps_pl_irq_lp_wdt,ps_pl_irq_sdio1_wake,ps_pl_irq_sdio0_wake,ps_pl_irq_sdio1,ps_pl_irq_sdio0,ps_pl_irq_ttc3_2,ps_pl_irq_ttc3_1,ps_pl_irq_ttc3_0,ps_pl_irq_ttc2_2,ps_pl_irq_ttc2_1,ps_pl_irq_ttc2_0,ps_pl_irq_ttc1_2,ps_pl_irq_ttc1_1,ps_pl_irq_ttc1_0,ps_pl_irq_ttc0_2,ps_pl_irq_ttc0_1,ps_pl_irq_ttc0_0,ps_pl_irq_ipi_channel0,ps_pl_irq_ipi_channel1,ps_pl_irq_ipi_channel2,ps_pl_irq_ipi_channel7,ps_pl_irq_ipi_channel8,ps_pl_irq_ipi_channel9,ps_pl_irq_ipi_channel10,ps_pl_irq_clkmon,ps_pl_irq_rtc_seconds,ps_pl_irq_rtc_alaram,ps_pl_irq_lpd_apm,ps_pl_irq_can1,ps_pl_irq_can0,ps_pl_irq_uart1,ps_pl_irq_uart0,ps_pl_irq_spi1,ps_pl_irq_spi0,ps_pl_irq_i2c1,ps_pl_irq_i2c0,ps_pl_irq_gpio,ps_pl_irq_qspi,ps_pl_irq_nand,ps_pl_irq_r5_core1_ecc_error,ps_pl_irq_r5_core0_ecc_error,ps_pl_irq_lpd_apb_intr,ps_pl_irq_ocm_error,ps_pl_irq_rpu_pm,NLW_PS8_i_PSPLIRQLPD_UNCONNECTED[7:0]}),
        .PSPLSTANDBYWFE(ps_pl_standbywfe),
        .PSPLSTANDBYWFI(ps_pl_standbywfi),
        .PSPLTRACECTL(NLW_PS8_i_PSPLTRACECTL_UNCONNECTED),
        .PSPLTRACEDATA(NLW_PS8_i_PSPLTRACEDATA_UNCONNECTED[31:0]),
        .PSPLTRIGACK({ps_pl_trigack_3,ps_pl_trigack_2,ps_pl_trigack_1,ps_pl_trigack_0}),
        .PSPLTRIGGER({ps_pl_trigger_3,ps_pl_trigger_2,ps_pl_trigger_1,ps_pl_trigger_0}),
        .PSS_ALTO_CORE_PAD_BOOTMODE(NLW_PS8_i_PSS_ALTO_CORE_PAD_BOOTMODE_UNCONNECTED[3:0]),
        .PSS_ALTO_CORE_PAD_CLK(NLW_PS8_i_PSS_ALTO_CORE_PAD_CLK_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_DONEB(NLW_PS8_i_PSS_ALTO_CORE_PAD_DONEB_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_DRAMA(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMA_UNCONNECTED[17:0]),
        .PSS_ALTO_CORE_PAD_DRAMACTN(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMACTN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_DRAMALERTN(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMALERTN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_DRAMBA(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBA_UNCONNECTED[1:0]),
        .PSS_ALTO_CORE_PAD_DRAMBG(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBG_UNCONNECTED[1:0]),
        .PSS_ALTO_CORE_PAD_DRAMCK(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCK_UNCONNECTED[1:0]),
        .PSS_ALTO_CORE_PAD_DRAMCKE(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKE_UNCONNECTED[1:0]),
        .PSS_ALTO_CORE_PAD_DRAMCKN(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKN_UNCONNECTED[1:0]),
        .PSS_ALTO_CORE_PAD_DRAMCSN(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCSN_UNCONNECTED[1:0]),
        .PSS_ALTO_CORE_PAD_DRAMDM(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDM_UNCONNECTED[8:0]),
        .PSS_ALTO_CORE_PAD_DRAMDQ(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQ_UNCONNECTED[71:0]),
        .PSS_ALTO_CORE_PAD_DRAMDQS(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQS_UNCONNECTED[8:0]),
        .PSS_ALTO_CORE_PAD_DRAMDQSN(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQSN_UNCONNECTED[8:0]),
        .PSS_ALTO_CORE_PAD_DRAMODT(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMODT_UNCONNECTED[1:0]),
        .PSS_ALTO_CORE_PAD_DRAMPARITY(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMPARITY_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_DRAMRAMRSTN(NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMRAMRSTN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_ERROROUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_ERROROUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_ERRORSTATUS(NLW_PS8_i_PSS_ALTO_CORE_PAD_ERRORSTATUS_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_INITB(NLW_PS8_i_PSS_ALTO_CORE_PAD_INITB_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_JTAGTCK(NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTCK_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_JTAGTDI(NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDI_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_JTAGTDO(NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDO_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_JTAGTMS(NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTMS_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXN0IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN0IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXN1IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN1IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXN2IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN2IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXN3IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN3IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXP0IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP0IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXP1IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP1IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXP2IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP2IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTRXP3IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP3IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXN0OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN0OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXN1OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN1OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXN2OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN2OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXN3OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN3OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXP0OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP0OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXP1OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP1OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXP2OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP2OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MGTTXP3OUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP3OUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_MIO(NLW_PS8_i_PSS_ALTO_CORE_PAD_MIO_UNCONNECTED[77:0]),
        .PSS_ALTO_CORE_PAD_PADI(NLW_PS8_i_PSS_ALTO_CORE_PAD_PADI_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_PADO(NLW_PS8_i_PSS_ALTO_CORE_PAD_PADO_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_PORB(NLW_PS8_i_PSS_ALTO_CORE_PAD_PORB_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_PROGB(NLW_PS8_i_PSS_ALTO_CORE_PAD_PROGB_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_RCALIBINOUT(NLW_PS8_i_PSS_ALTO_CORE_PAD_RCALIBINOUT_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFN0IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN0IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFN1IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN1IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFN2IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN2IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFN3IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN3IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFP0IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP0IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFP1IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP1IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFP2IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP2IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_REFP3IN(NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP3IN_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_SRSTB(NLW_PS8_i_PSS_ALTO_CORE_PAD_SRSTB_UNCONNECTED),
        .PSS_ALTO_CORE_PAD_ZQ(NLW_PS8_i_PSS_ALTO_CORE_PAD_ZQ_UNCONNECTED),
        .RPUEVENTI0(rpu_eventi0),
        .RPUEVENTI1(rpu_eventi1),
        .RPUEVENTO0(rpu_evento0),
        .RPUEVENTO1(rpu_evento1),
        .SACEFPDACADDR(sacefpd_acaddr),
        .SACEFPDACPROT(sacefpd_acprot),
        .SACEFPDACREADY(sacefpd_acready),
        .SACEFPDACSNOOP(sacefpd_acsnoop),
        .SACEFPDACVALID(sacefpd_acvalid),
        .SACEFPDARADDR(sacefpd_araddr),
        .SACEFPDARBAR(sacefpd_arbar),
        .SACEFPDARBURST(sacefpd_arburst),
        .SACEFPDARCACHE(sacefpd_arcache),
        .SACEFPDARDOMAIN(sacefpd_ardomain),
        .SACEFPDARID(sacefpd_arid),
        .SACEFPDARLEN(sacefpd_arlen),
        .SACEFPDARLOCK(sacefpd_arlock),
        .SACEFPDARPROT(sacefpd_arprot),
        .SACEFPDARQOS(sacefpd_arqos),
        .SACEFPDARREADY(sacefpd_arready),
        .SACEFPDARREGION(sacefpd_arregion),
        .SACEFPDARSIZE(sacefpd_arsize),
        .SACEFPDARSNOOP(sacefpd_arsnoop),
        .SACEFPDARUSER({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,sacefpd_aruser[5:0]}),
        .SACEFPDARVALID(sacefpd_arvalid),
        .SACEFPDAWADDR(sacefpd_awaddr),
        .SACEFPDAWBAR(sacefpd_awbar),
        .SACEFPDAWBURST(sacefpd_awburst),
        .SACEFPDAWCACHE(sacefpd_awcache),
        .SACEFPDAWDOMAIN(sacefpd_awdomain),
        .SACEFPDAWID(sacefpd_awid),
        .SACEFPDAWLEN(sacefpd_awlen),
        .SACEFPDAWLOCK(sacefpd_awlock),
        .SACEFPDAWPROT(sacefpd_awprot),
        .SACEFPDAWQOS(sacefpd_awqos),
        .SACEFPDAWREADY(sacefpd_awready),
        .SACEFPDAWREGION(sacefpd_awregion),
        .SACEFPDAWSIZE(sacefpd_awsize),
        .SACEFPDAWSNOOP(sacefpd_awsnoop),
        .SACEFPDAWUSER({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b1,1'b1,1'b1,sacefpd_awuser[5:0]}),
        .SACEFPDAWVALID(sacefpd_awvalid),
        .SACEFPDBID(sacefpd_bid),
        .SACEFPDBREADY(sacefpd_bready),
        .SACEFPDBRESP(sacefpd_bresp),
        .SACEFPDBUSER(sacefpd_buser),
        .SACEFPDBVALID(sacefpd_bvalid),
        .SACEFPDCDDATA(sacefpd_cddata),
        .SACEFPDCDLAST(sacefpd_cdlast),
        .SACEFPDCDREADY(sacefpd_cdready),
        .SACEFPDCDVALID(sacefpd_cdvalid),
        .SACEFPDCRREADY(sacefpd_crready),
        .SACEFPDCRRESP(sacefpd_crresp),
        .SACEFPDCRVALID(sacefpd_crvalid),
        .SACEFPDRACK(sacefpd_rack),
        .SACEFPDRDATA(sacefpd_rdata),
        .SACEFPDRID(sacefpd_rid),
        .SACEFPDRLAST(sacefpd_rlast),
        .SACEFPDRREADY(sacefpd_rready),
        .SACEFPDRRESP(sacefpd_rresp),
        .SACEFPDRUSER(sacefpd_ruser),
        .SACEFPDRVALID(sacefpd_rvalid),
        .SACEFPDWACK(sacefpd_wack),
        .SACEFPDWDATA(sacefpd_wdata),
        .SACEFPDWLAST(sacefpd_wlast),
        .SACEFPDWREADY(sacefpd_wready),
        .SACEFPDWSTRB(sacefpd_wstrb),
        .SACEFPDWUSER(sacefpd_wuser),
        .SACEFPDWVALID(sacefpd_wvalid),
        .SAXIACPACLK(saxiacp_fpd_aclk),
        .SAXIACPARADDR(saxiacp_araddr),
        .SAXIACPARBURST(saxiacp_arburst),
        .SAXIACPARCACHE(saxiacp_arcache),
        .SAXIACPARID(saxiacp_arid),
        .SAXIACPARLEN(saxiacp_arlen),
        .SAXIACPARLOCK(saxiacp_arlock),
        .SAXIACPARPROT(saxiacp_arprot),
        .SAXIACPARQOS(saxiacp_arqos),
        .SAXIACPARREADY(saxiacp_arready),
        .SAXIACPARSIZE(saxiacp_arsize),
        .SAXIACPARUSER(saxiacp_aruser),
        .SAXIACPARVALID(saxiacp_arvalid),
        .SAXIACPAWADDR(saxiacp_awaddr),
        .SAXIACPAWBURST(saxiacp_awburst),
        .SAXIACPAWCACHE(saxiacp_awcache),
        .SAXIACPAWID(saxiacp_awid),
        .SAXIACPAWLEN(saxiacp_awlen),
        .SAXIACPAWLOCK(saxiacp_awlock),
        .SAXIACPAWPROT(saxiacp_awprot),
        .SAXIACPAWQOS(saxiacp_awqos),
        .SAXIACPAWREADY(saxiacp_awready),
        .SAXIACPAWSIZE(saxiacp_awsize),
        .SAXIACPAWUSER(saxiacp_awuser),
        .SAXIACPAWVALID(saxiacp_awvalid),
        .SAXIACPBID(saxiacp_bid),
        .SAXIACPBREADY(saxiacp_bready),
        .SAXIACPBRESP(saxiacp_bresp),
        .SAXIACPBVALID(saxiacp_bvalid),
        .SAXIACPRDATA(saxiacp_rdata),
        .SAXIACPRID(saxiacp_rid),
        .SAXIACPRLAST(saxiacp_rlast),
        .SAXIACPRREADY(saxiacp_rready),
        .SAXIACPRRESP(saxiacp_rresp),
        .SAXIACPRVALID(saxiacp_rvalid),
        .SAXIACPWDATA(saxiacp_wdata),
        .SAXIACPWLAST(saxiacp_wlast),
        .SAXIACPWREADY(saxiacp_wready),
        .SAXIACPWSTRB(saxiacp_wstrb),
        .SAXIACPWVALID(saxiacp_wvalid),
        .SAXIGP0ARADDR(saxigp0_araddr),
        .SAXIGP0ARBURST(saxigp0_arburst),
        .SAXIGP0ARCACHE(saxigp0_arcache),
        .SAXIGP0ARID(saxigp0_arid),
        .SAXIGP0ARLEN(saxigp0_arlen),
        .SAXIGP0ARLOCK(saxigp0_arlock),
        .SAXIGP0ARPROT(saxigp0_arprot),
        .SAXIGP0ARQOS(saxigp0_arqos),
        .SAXIGP0ARREADY(saxigp0_arready),
        .SAXIGP0ARSIZE(saxigp0_arsize),
        .SAXIGP0ARUSER(saxigp0_aruser),
        .SAXIGP0ARVALID(saxigp0_arvalid),
        .SAXIGP0AWADDR(saxigp0_awaddr),
        .SAXIGP0AWBURST(saxigp0_awburst),
        .SAXIGP0AWCACHE(saxigp0_awcache),
        .SAXIGP0AWID(saxigp0_awid),
        .SAXIGP0AWLEN(saxigp0_awlen),
        .SAXIGP0AWLOCK(saxigp0_awlock),
        .SAXIGP0AWPROT(saxigp0_awprot),
        .SAXIGP0AWQOS(saxigp0_awqos),
        .SAXIGP0AWREADY(saxigp0_awready),
        .SAXIGP0AWSIZE(saxigp0_awsize),
        .SAXIGP0AWUSER(saxigp0_awuser),
        .SAXIGP0AWVALID(saxigp0_awvalid),
        .SAXIGP0BID(saxigp0_bid),
        .SAXIGP0BREADY(saxigp0_bready),
        .SAXIGP0BRESP(saxigp0_bresp),
        .SAXIGP0BVALID(saxigp0_bvalid),
        .SAXIGP0RACOUNT(saxigp0_racount),
        .SAXIGP0RCLK(saxihpc0_fpd_aclk),
        .SAXIGP0RCOUNT(saxigp0_rcount),
        .SAXIGP0RDATA({NLW_PS8_i_SAXIGP0RDATA_UNCONNECTED[127:64],saxigp0_rdata}),
        .SAXIGP0RID(saxigp0_rid),
        .SAXIGP0RLAST(saxigp0_rlast),
        .SAXIGP0RREADY(saxigp0_rready),
        .SAXIGP0RRESP(saxigp0_rresp),
        .SAXIGP0RVALID(saxigp0_rvalid),
        .SAXIGP0WACOUNT(saxigp0_wacount),
        .SAXIGP0WCLK(saxihpc0_fpd_aclk),
        .SAXIGP0WCOUNT(saxigp0_wcount),
        .SAXIGP0WDATA({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,saxigp0_wdata}),
        .SAXIGP0WLAST(saxigp0_wlast),
        .SAXIGP0WREADY(saxigp0_wready),
        .SAXIGP0WSTRB({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,saxigp0_wstrb}),
        .SAXIGP0WVALID(saxigp0_wvalid),
        .SAXIGP1ARADDR(saxigp1_araddr),
        .SAXIGP1ARBURST(saxigp1_arburst),
        .SAXIGP1ARCACHE(saxigp1_arcache),
        .SAXIGP1ARID(saxigp1_arid),
        .SAXIGP1ARLEN(saxigp1_arlen),
        .SAXIGP1ARLOCK(saxigp1_arlock),
        .SAXIGP1ARPROT(saxigp1_arprot),
        .SAXIGP1ARQOS(saxigp1_arqos),
        .SAXIGP1ARREADY(saxigp1_arready),
        .SAXIGP1ARSIZE(saxigp1_arsize),
        .SAXIGP1ARUSER(saxigp1_aruser),
        .SAXIGP1ARVALID(saxigp1_arvalid),
        .SAXIGP1AWADDR(saxigp1_awaddr),
        .SAXIGP1AWBURST(saxigp1_awburst),
        .SAXIGP1AWCACHE(saxigp1_awcache),
        .SAXIGP1AWID(saxigp1_awid),
        .SAXIGP1AWLEN(saxigp1_awlen),
        .SAXIGP1AWLOCK(saxigp1_awlock),
        .SAXIGP1AWPROT(saxigp1_awprot),
        .SAXIGP1AWQOS(saxigp1_awqos),
        .SAXIGP1AWREADY(saxigp1_awready),
        .SAXIGP1AWSIZE(saxigp1_awsize),
        .SAXIGP1AWUSER(saxigp1_awuser),
        .SAXIGP1AWVALID(saxigp1_awvalid),
        .SAXIGP1BID(saxigp1_bid),
        .SAXIGP1BREADY(saxigp1_bready),
        .SAXIGP1BRESP(saxigp1_bresp),
        .SAXIGP1BVALID(saxigp1_bvalid),
        .SAXIGP1RACOUNT(saxigp1_racount),
        .SAXIGP1RCLK(saxihpc1_fpd_aclk),
        .SAXIGP1RCOUNT(saxigp1_rcount),
        .SAXIGP1RDATA(saxigp1_rdata),
        .SAXIGP1RID(saxigp1_rid),
        .SAXIGP1RLAST(saxigp1_rlast),
        .SAXIGP1RREADY(saxigp1_rready),
        .SAXIGP1RRESP(saxigp1_rresp),
        .SAXIGP1RVALID(saxigp1_rvalid),
        .SAXIGP1WACOUNT(saxigp1_wacount),
        .SAXIGP1WCLK(saxihpc1_fpd_aclk),
        .SAXIGP1WCOUNT(saxigp1_wcount),
        .SAXIGP1WDATA(saxigp1_wdata),
        .SAXIGP1WLAST(saxigp1_wlast),
        .SAXIGP1WREADY(saxigp1_wready),
        .SAXIGP1WSTRB(saxigp1_wstrb),
        .SAXIGP1WVALID(saxigp1_wvalid),
        .SAXIGP2ARADDR(saxigp2_araddr),
        .SAXIGP2ARBURST(saxigp2_arburst),
        .SAXIGP2ARCACHE(saxigp2_arcache),
        .SAXIGP2ARID(saxigp2_arid),
        .SAXIGP2ARLEN(saxigp2_arlen),
        .SAXIGP2ARLOCK(saxigp2_arlock),
        .SAXIGP2ARPROT(saxigp2_arprot),
        .SAXIGP2ARQOS(saxigp2_arqos),
        .SAXIGP2ARREADY(saxigp2_arready),
        .SAXIGP2ARSIZE(saxigp2_arsize),
        .SAXIGP2ARUSER(saxigp2_aruser),
        .SAXIGP2ARVALID(saxigp2_arvalid),
        .SAXIGP2AWADDR(saxigp2_awaddr),
        .SAXIGP2AWBURST(saxigp2_awburst),
        .SAXIGP2AWCACHE(saxigp2_awcache),
        .SAXIGP2AWID(saxigp2_awid),
        .SAXIGP2AWLEN(saxigp2_awlen),
        .SAXIGP2AWLOCK(saxigp2_awlock),
        .SAXIGP2AWPROT(saxigp2_awprot),
        .SAXIGP2AWQOS(saxigp2_awqos),
        .SAXIGP2AWREADY(saxigp2_awready),
        .SAXIGP2AWSIZE(saxigp2_awsize),
        .SAXIGP2AWUSER(saxigp2_awuser),
        .SAXIGP2AWVALID(saxigp2_awvalid),
        .SAXIGP2BID(saxigp2_bid),
        .SAXIGP2BREADY(saxigp2_bready),
        .SAXIGP2BRESP(saxigp2_bresp),
        .SAXIGP2BVALID(saxigp2_bvalid),
        .SAXIGP2RACOUNT(saxigp2_racount),
        .SAXIGP2RCLK(saxihp0_fpd_aclk),
        .SAXIGP2RCOUNT(saxigp2_rcount),
        .SAXIGP2RDATA(saxigp2_rdata),
        .SAXIGP2RID(saxigp2_rid),
        .SAXIGP2RLAST(saxigp2_rlast),
        .SAXIGP2RREADY(saxigp2_rready),
        .SAXIGP2RRESP(saxigp2_rresp),
        .SAXIGP2RVALID(saxigp2_rvalid),
        .SAXIGP2WACOUNT(saxigp2_wacount),
        .SAXIGP2WCLK(saxihp0_fpd_aclk),
        .SAXIGP2WCOUNT(saxigp2_wcount),
        .SAXIGP2WDATA(saxigp2_wdata),
        .SAXIGP2WLAST(saxigp2_wlast),
        .SAXIGP2WREADY(saxigp2_wready),
        .SAXIGP2WSTRB(saxigp2_wstrb),
        .SAXIGP2WVALID(saxigp2_wvalid),
        .SAXIGP3ARADDR(saxigp3_araddr),
        .SAXIGP3ARBURST(saxigp3_arburst),
        .SAXIGP3ARCACHE(saxigp3_arcache),
        .SAXIGP3ARID(saxigp3_arid),
        .SAXIGP3ARLEN(saxigp3_arlen),
        .SAXIGP3ARLOCK(saxigp3_arlock),
        .SAXIGP3ARPROT(saxigp3_arprot),
        .SAXIGP3ARQOS(saxigp3_arqos),
        .SAXIGP3ARREADY(saxigp3_arready),
        .SAXIGP3ARSIZE(saxigp3_arsize),
        .SAXIGP3ARUSER(saxigp3_aruser),
        .SAXIGP3ARVALID(saxigp3_arvalid),
        .SAXIGP3AWADDR(saxigp3_awaddr),
        .SAXIGP3AWBURST(saxigp3_awburst),
        .SAXIGP3AWCACHE(saxigp3_awcache),
        .SAXIGP3AWID(saxigp3_awid),
        .SAXIGP3AWLEN(saxigp3_awlen),
        .SAXIGP3AWLOCK(saxigp3_awlock),
        .SAXIGP3AWPROT(saxigp3_awprot),
        .SAXIGP3AWQOS(saxigp3_awqos),
        .SAXIGP3AWREADY(saxigp3_awready),
        .SAXIGP3AWSIZE(saxigp3_awsize),
        .SAXIGP3AWUSER(saxigp3_awuser),
        .SAXIGP3AWVALID(saxigp3_awvalid),
        .SAXIGP3BID(saxigp3_bid),
        .SAXIGP3BREADY(saxigp3_bready),
        .SAXIGP3BRESP(saxigp3_bresp),
        .SAXIGP3BVALID(saxigp3_bvalid),
        .SAXIGP3RACOUNT(saxigp3_racount),
        .SAXIGP3RCLK(saxihp1_fpd_aclk),
        .SAXIGP3RCOUNT(saxigp3_rcount),
        .SAXIGP3RDATA(saxigp3_rdata),
        .SAXIGP3RID(saxigp3_rid),
        .SAXIGP3RLAST(saxigp3_rlast),
        .SAXIGP3RREADY(saxigp3_rready),
        .SAXIGP3RRESP(saxigp3_rresp),
        .SAXIGP3RVALID(saxigp3_rvalid),
        .SAXIGP3WACOUNT(saxigp3_wacount),
        .SAXIGP3WCLK(saxihp1_fpd_aclk),
        .SAXIGP3WCOUNT(saxigp3_wcount),
        .SAXIGP3WDATA(saxigp3_wdata),
        .SAXIGP3WLAST(saxigp3_wlast),
        .SAXIGP3WREADY(saxigp3_wready),
        .SAXIGP3WSTRB(saxigp3_wstrb),
        .SAXIGP3WVALID(saxigp3_wvalid),
        .SAXIGP4ARADDR(saxigp4_araddr),
        .SAXIGP4ARBURST(saxigp4_arburst),
        .SAXIGP4ARCACHE(saxigp4_arcache),
        .SAXIGP4ARID(saxigp4_arid),
        .SAXIGP4ARLEN(saxigp4_arlen),
        .SAXIGP4ARLOCK(saxigp4_arlock),
        .SAXIGP4ARPROT(saxigp4_arprot),
        .SAXIGP4ARQOS(saxigp4_arqos),
        .SAXIGP4ARREADY(saxigp4_arready),
        .SAXIGP4ARSIZE(saxigp4_arsize),
        .SAXIGP4ARUSER(saxigp4_aruser),
        .SAXIGP4ARVALID(saxigp4_arvalid),
        .SAXIGP4AWADDR(saxigp4_awaddr),
        .SAXIGP4AWBURST(saxigp4_awburst),
        .SAXIGP4AWCACHE(saxigp4_awcache),
        .SAXIGP4AWID(saxigp4_awid),
        .SAXIGP4AWLEN(saxigp4_awlen),
        .SAXIGP4AWLOCK(saxigp4_awlock),
        .SAXIGP4AWPROT(saxigp4_awprot),
        .SAXIGP4AWQOS(saxigp4_awqos),
        .SAXIGP4AWREADY(saxigp4_awready),
        .SAXIGP4AWSIZE(saxigp4_awsize),
        .SAXIGP4AWUSER(saxigp4_awuser),
        .SAXIGP4AWVALID(saxigp4_awvalid),
        .SAXIGP4BID(saxigp4_bid),
        .SAXIGP4BREADY(saxigp4_bready),
        .SAXIGP4BRESP(saxigp4_bresp),
        .SAXIGP4BVALID(saxigp4_bvalid),
        .SAXIGP4RACOUNT(saxigp4_racount),
        .SAXIGP4RCLK(saxihp2_fpd_aclk),
        .SAXIGP4RCOUNT(saxigp4_rcount),
        .SAXIGP4RDATA(saxigp4_rdata),
        .SAXIGP4RID(saxigp4_rid),
        .SAXIGP4RLAST(saxigp4_rlast),
        .SAXIGP4RREADY(saxigp4_rready),
        .SAXIGP4RRESP(saxigp4_rresp),
        .SAXIGP4RVALID(saxigp4_rvalid),
        .SAXIGP4WACOUNT(saxigp4_wacount),
        .SAXIGP4WCLK(saxihp2_fpd_aclk),
        .SAXIGP4WCOUNT(saxigp4_wcount),
        .SAXIGP4WDATA(saxigp4_wdata),
        .SAXIGP4WLAST(saxigp4_wlast),
        .SAXIGP4WREADY(saxigp4_wready),
        .SAXIGP4WSTRB(saxigp4_wstrb),
        .SAXIGP4WVALID(saxigp4_wvalid),
        .SAXIGP5ARADDR(saxigp5_araddr),
        .SAXIGP5ARBURST(saxigp5_arburst),
        .SAXIGP5ARCACHE(saxigp5_arcache),
        .SAXIGP5ARID(saxigp5_arid),
        .SAXIGP5ARLEN(saxigp5_arlen),
        .SAXIGP5ARLOCK(saxigp5_arlock),
        .SAXIGP5ARPROT(saxigp5_arprot),
        .SAXIGP5ARQOS(saxigp5_arqos),
        .SAXIGP5ARREADY(saxigp5_arready),
        .SAXIGP5ARSIZE(saxigp5_arsize),
        .SAXIGP5ARUSER(saxigp5_aruser),
        .SAXIGP5ARVALID(saxigp5_arvalid),
        .SAXIGP5AWADDR(saxigp5_awaddr),
        .SAXIGP5AWBURST(saxigp5_awburst),
        .SAXIGP5AWCACHE(saxigp5_awcache),
        .SAXIGP5AWID(saxigp5_awid),
        .SAXIGP5AWLEN(saxigp5_awlen),
        .SAXIGP5AWLOCK(saxigp5_awlock),
        .SAXIGP5AWPROT(saxigp5_awprot),
        .SAXIGP5AWQOS(saxigp5_awqos),
        .SAXIGP5AWREADY(saxigp5_awready),
        .SAXIGP5AWSIZE(saxigp5_awsize),
        .SAXIGP5AWUSER(saxigp5_awuser),
        .SAXIGP5AWVALID(saxigp5_awvalid),
        .SAXIGP5BID(saxigp5_bid),
        .SAXIGP5BREADY(saxigp5_bready),
        .SAXIGP5BRESP(saxigp5_bresp),
        .SAXIGP5BVALID(saxigp5_bvalid),
        .SAXIGP5RACOUNT(saxigp5_racount),
        .SAXIGP5RCLK(saxihp3_fpd_aclk),
        .SAXIGP5RCOUNT(saxigp5_rcount),
        .SAXIGP5RDATA(saxigp5_rdata),
        .SAXIGP5RID(saxigp5_rid),
        .SAXIGP5RLAST(saxigp5_rlast),
        .SAXIGP5RREADY(saxigp5_rready),
        .SAXIGP5RRESP(saxigp5_rresp),
        .SAXIGP5RVALID(saxigp5_rvalid),
        .SAXIGP5WACOUNT(saxigp5_wacount),
        .SAXIGP5WCLK(saxihp3_fpd_aclk),
        .SAXIGP5WCOUNT(saxigp5_wcount),
        .SAXIGP5WDATA(saxigp5_wdata),
        .SAXIGP5WLAST(saxigp5_wlast),
        .SAXIGP5WREADY(saxigp5_wready),
        .SAXIGP5WSTRB(saxigp5_wstrb),
        .SAXIGP5WVALID(saxigp5_wvalid),
        .SAXIGP6ARADDR(saxigp6_araddr),
        .SAXIGP6ARBURST(saxigp6_arburst),
        .SAXIGP6ARCACHE(saxigp6_arcache),
        .SAXIGP6ARID(saxigp6_arid),
        .SAXIGP6ARLEN(saxigp6_arlen),
        .SAXIGP6ARLOCK(saxigp6_arlock),
        .SAXIGP6ARPROT(saxigp6_arprot),
        .SAXIGP6ARQOS(saxigp6_arqos),
        .SAXIGP6ARREADY(saxigp6_arready),
        .SAXIGP6ARSIZE(saxigp6_arsize),
        .SAXIGP6ARUSER(saxigp6_aruser),
        .SAXIGP6ARVALID(saxigp6_arvalid),
        .SAXIGP6AWADDR(saxigp6_awaddr),
        .SAXIGP6AWBURST(saxigp6_awburst),
        .SAXIGP6AWCACHE(saxigp6_awcache),
        .SAXIGP6AWID(saxigp6_awid),
        .SAXIGP6AWLEN(saxigp6_awlen),
        .SAXIGP6AWLOCK(saxigp6_awlock),
        .SAXIGP6AWPROT(saxigp6_awprot),
        .SAXIGP6AWQOS(saxigp6_awqos),
        .SAXIGP6AWREADY(saxigp6_awready),
        .SAXIGP6AWSIZE(saxigp6_awsize),
        .SAXIGP6AWUSER(saxigp6_awuser),
        .SAXIGP6AWVALID(saxigp6_awvalid),
        .SAXIGP6BID(saxigp6_bid),
        .SAXIGP6BREADY(saxigp6_bready),
        .SAXIGP6BRESP(saxigp6_bresp),
        .SAXIGP6BVALID(saxigp6_bvalid),
        .SAXIGP6RACOUNT(saxigp6_racount),
        .SAXIGP6RCLK(saxi_lpd_aclk),
        .SAXIGP6RCOUNT(saxigp6_rcount),
        .SAXIGP6RDATA(saxigp6_rdata),
        .SAXIGP6RID(saxigp6_rid),
        .SAXIGP6RLAST(saxigp6_rlast),
        .SAXIGP6RREADY(saxigp6_rready),
        .SAXIGP6RRESP(saxigp6_rresp),
        .SAXIGP6RVALID(saxigp6_rvalid),
        .SAXIGP6WACOUNT(saxigp6_wacount),
        .SAXIGP6WCLK(saxi_lpd_aclk),
        .SAXIGP6WCOUNT(saxigp6_wcount),
        .SAXIGP6WDATA(saxigp6_wdata),
        .SAXIGP6WLAST(saxigp6_wlast),
        .SAXIGP6WREADY(saxigp6_wready),
        .SAXIGP6WSTRB(saxigp6_wstrb),
        .SAXIGP6WVALID(saxigp6_wvalid),
        .STMEVENT(stm_event));
  VCC VCC
       (.P(\<const1> ));
  (* BOX_TYPE = "PRIMITIVE" *) 
  BUFG_PS #(
    .SIM_DEVICE("ULTRASCALE_PLUS"),
    .STARTUP_SYNC("FALSE")) 
    \buffer_pl_clk_0.PL_CLK_0_BUFG 
       (.I(pl_clk_unbuffered),
        .O(pl_clk0));
  LUT1 #(
    .INIT(2'h1)) 
    emio_enet0_mdio_t_INST_0
       (.I0(emio_enet0_mdio_t_n),
        .O(emio_enet0_mdio_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_enet1_mdio_t_INST_0
       (.I0(emio_enet1_mdio_t_n),
        .O(emio_enet1_mdio_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_enet2_mdio_t_INST_0
       (.I0(emio_enet2_mdio_t_n),
        .O(emio_enet2_mdio_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_enet3_mdio_t_INST_0
       (.I0(emio_enet3_mdio_t_n),
        .O(emio_enet3_mdio_t));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_gpio_t[0]_INST_0 
       (.I0(emio_gpio_t_n),
        .O(emio_gpio_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_i2c0_scl_t_INST_0
       (.I0(emio_i2c0_scl_t_n),
        .O(emio_i2c0_scl_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_i2c0_sda_t_INST_0
       (.I0(emio_i2c0_sda_t_n),
        .O(emio_i2c0_sda_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_i2c1_scl_t_INST_0
       (.I0(emio_i2c1_scl_t_n),
        .O(emio_i2c1_scl_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_i2c1_sda_t_INST_0
       (.I0(emio_i2c1_sda_t_n),
        .O(emio_i2c1_sda_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_sdio0_cmdena_INST_0
       (.I0(emio_sdio0_cmdena_i),
        .O(emio_sdio0_cmdena));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[0]_INST_0 
       (.I0(emio_sdio0_dataena_i[0]),
        .O(emio_sdio0_dataena[0]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[1]_INST_0 
       (.I0(emio_sdio0_dataena_i[1]),
        .O(emio_sdio0_dataena[1]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[2]_INST_0 
       (.I0(emio_sdio0_dataena_i[2]),
        .O(emio_sdio0_dataena[2]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[3]_INST_0 
       (.I0(emio_sdio0_dataena_i[3]),
        .O(emio_sdio0_dataena[3]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[4]_INST_0 
       (.I0(emio_sdio0_dataena_i[4]),
        .O(emio_sdio0_dataena[4]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[5]_INST_0 
       (.I0(emio_sdio0_dataena_i[5]),
        .O(emio_sdio0_dataena[5]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[6]_INST_0 
       (.I0(emio_sdio0_dataena_i[6]),
        .O(emio_sdio0_dataena[6]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio0_dataena[7]_INST_0 
       (.I0(emio_sdio0_dataena_i[7]),
        .O(emio_sdio0_dataena[7]));
  LUT1 #(
    .INIT(2'h1)) 
    emio_sdio1_cmdena_INST_0
       (.I0(emio_sdio1_cmdena_i),
        .O(emio_sdio1_cmdena));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[0]_INST_0 
       (.I0(emio_sdio1_dataena_i[0]),
        .O(emio_sdio1_dataena[0]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[1]_INST_0 
       (.I0(emio_sdio1_dataena_i[1]),
        .O(emio_sdio1_dataena[1]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[2]_INST_0 
       (.I0(emio_sdio1_dataena_i[2]),
        .O(emio_sdio1_dataena[2]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[3]_INST_0 
       (.I0(emio_sdio1_dataena_i[3]),
        .O(emio_sdio1_dataena[3]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[4]_INST_0 
       (.I0(emio_sdio1_dataena_i[4]),
        .O(emio_sdio1_dataena[4]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[5]_INST_0 
       (.I0(emio_sdio1_dataena_i[5]),
        .O(emio_sdio1_dataena[5]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[6]_INST_0 
       (.I0(emio_sdio1_dataena_i[6]),
        .O(emio_sdio1_dataena[6]));
  LUT1 #(
    .INIT(2'h1)) 
    \emio_sdio1_dataena[7]_INST_0 
       (.I0(emio_sdio1_dataena_i[7]),
        .O(emio_sdio1_dataena[7]));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi0_mo_t_INST_0
       (.I0(emio_spi0_mo_t_n),
        .O(emio_spi0_mo_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi0_sclk_t_INST_0
       (.I0(emio_spi0_sclk_t_n),
        .O(emio_spi0_sclk_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi0_so_t_INST_0
       (.I0(emio_spi0_so_t_n),
        .O(emio_spi0_so_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi0_ss_n_t_INST_0
       (.I0(emio_spi0_ss_n_t_n),
        .O(emio_spi0_ss_n_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi1_mo_t_INST_0
       (.I0(emio_spi1_mo_t_n),
        .O(emio_spi1_mo_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi1_sclk_t_INST_0
       (.I0(emio_spi1_sclk_t_n),
        .O(emio_spi1_sclk_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi1_so_t_INST_0
       (.I0(emio_spi1_so_t_n),
        .O(emio_spi1_so_t));
  LUT1 #(
    .INIT(2'h1)) 
    emio_spi1_ss_n_t_INST_0
       (.I0(emio_spi1_ss_n_t_n),
        .O(emio_spi1_ss_n_t));
  LUT1 #(
    .INIT(2'h2)) 
    i_0
       (.I0(1'b0),
        .O(\trace_ctl_pipe[0] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_1
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_10
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_100
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_101
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_102
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_103
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_104
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_105
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_106
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_107
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_108
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_109
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_11
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_110
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_111
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_112
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_113
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_114
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_115
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_116
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_117
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_118
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_119
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_12
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_120
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_121
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_122
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_123
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_124
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_125
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_126
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_127
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_128
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_129
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_13
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_130
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_131
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [4]));
  LUT1 #(
    .INIT(2'h2)) 
    i_132
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_133
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_134
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_135
       (.I0(1'b0),
        .O(\trace_data_pipe[5] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_136
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_137
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_138
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_139
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_14
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_140
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_141
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_142
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_143
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_144
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_145
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_146
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_147
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_148
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_149
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_15
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_150
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_151
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_152
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_153
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_154
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_155
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_156
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_157
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_158
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_159
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_16
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_160
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_161
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_162
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_163
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [4]));
  LUT1 #(
    .INIT(2'h2)) 
    i_164
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_165
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_166
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_167
       (.I0(1'b0),
        .O(\trace_data_pipe[4] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_168
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_169
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_17
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_170
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_171
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_172
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_173
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_174
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_175
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_176
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_177
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_178
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_179
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_18
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_180
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_181
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_182
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_183
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_184
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_185
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_186
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_187
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_188
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_189
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_19
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_190
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_191
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_192
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_193
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_194
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_195
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [4]));
  LUT1 #(
    .INIT(2'h2)) 
    i_196
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_197
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_198
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_199
       (.I0(1'b0),
        .O(\trace_data_pipe[3] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_2
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_20
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_200
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_201
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_202
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_203
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_204
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_205
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_206
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_207
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_208
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_209
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_21
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_210
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_211
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_212
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_213
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_214
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_215
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_216
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_217
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_218
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_219
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_22
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_220
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_221
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_222
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_223
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_224
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_225
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_226
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_227
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [4]));
  LUT1 #(
    .INIT(2'h2)) 
    i_228
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_229
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_23
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_230
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_231
       (.I0(1'b0),
        .O(\trace_data_pipe[2] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_232
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_233
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_234
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_235
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_236
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_237
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_238
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_239
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_24
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_240
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_241
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_242
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_243
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_244
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_245
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_246
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_247
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_248
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_249
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_25
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_250
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_251
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_252
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_253
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_254
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_255
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_256
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_257
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_258
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_259
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [4]));
  LUT1 #(
    .INIT(2'h2)) 
    i_26
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_260
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_261
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_262
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_263
       (.I0(1'b0),
        .O(\trace_data_pipe[1] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_27
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_28
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [4]));
  LUT1 #(
    .INIT(2'h2)) 
    i_29
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_3
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_30
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_31
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_32
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_33
       (.I0(1'b0),
        .O(\trace_ctl_pipe[7] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_34
       (.I0(1'b0),
        .O(\trace_ctl_pipe[6] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_35
       (.I0(1'b0),
        .O(\trace_ctl_pipe[5] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_36
       (.I0(1'b0),
        .O(\trace_ctl_pipe[4] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_37
       (.I0(1'b0),
        .O(\trace_ctl_pipe[3] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_38
       (.I0(1'b0),
        .O(\trace_ctl_pipe[2] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_39
       (.I0(1'b0),
        .O(\trace_ctl_pipe[1] ));
  LUT1 #(
    .INIT(2'h2)) 
    i_4
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_40
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_41
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_42
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_43
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_44
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_45
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_46
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_47
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_48
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_49
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_5
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_50
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_51
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_52
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_53
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_54
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_55
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_56
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_57
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_58
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_59
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_6
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_60
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_61
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_62
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_63
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_64
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_65
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_66
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_67
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [4]));
  LUT1 #(
    .INIT(2'h2)) 
    i_68
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [3]));
  LUT1 #(
    .INIT(2'h2)) 
    i_69
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [2]));
  LUT1 #(
    .INIT(2'h2)) 
    i_7
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_70
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [1]));
  LUT1 #(
    .INIT(2'h2)) 
    i_71
       (.I0(1'b0),
        .O(\trace_data_pipe[7] [0]));
  LUT1 #(
    .INIT(2'h2)) 
    i_72
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [31]));
  LUT1 #(
    .INIT(2'h2)) 
    i_73
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [30]));
  LUT1 #(
    .INIT(2'h2)) 
    i_74
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [29]));
  LUT1 #(
    .INIT(2'h2)) 
    i_75
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [28]));
  LUT1 #(
    .INIT(2'h2)) 
    i_76
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [27]));
  LUT1 #(
    .INIT(2'h2)) 
    i_77
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [26]));
  LUT1 #(
    .INIT(2'h2)) 
    i_78
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [25]));
  LUT1 #(
    .INIT(2'h2)) 
    i_79
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_8
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [24]));
  LUT1 #(
    .INIT(2'h2)) 
    i_80
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_81
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [22]));
  LUT1 #(
    .INIT(2'h2)) 
    i_82
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [21]));
  LUT1 #(
    .INIT(2'h2)) 
    i_83
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [20]));
  LUT1 #(
    .INIT(2'h2)) 
    i_84
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [19]));
  LUT1 #(
    .INIT(2'h2)) 
    i_85
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [18]));
  LUT1 #(
    .INIT(2'h2)) 
    i_86
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [17]));
  LUT1 #(
    .INIT(2'h2)) 
    i_87
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [16]));
  LUT1 #(
    .INIT(2'h2)) 
    i_88
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [15]));
  LUT1 #(
    .INIT(2'h2)) 
    i_89
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [14]));
  LUT1 #(
    .INIT(2'h2)) 
    i_9
       (.I0(1'b0),
        .O(\trace_data_pipe[0] [23]));
  LUT1 #(
    .INIT(2'h2)) 
    i_90
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [13]));
  LUT1 #(
    .INIT(2'h2)) 
    i_91
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [12]));
  LUT1 #(
    .INIT(2'h2)) 
    i_92
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [11]));
  LUT1 #(
    .INIT(2'h2)) 
    i_93
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [10]));
  LUT1 #(
    .INIT(2'h2)) 
    i_94
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [9]));
  LUT1 #(
    .INIT(2'h2)) 
    i_95
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [8]));
  LUT1 #(
    .INIT(2'h2)) 
    i_96
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [7]));
  LUT1 #(
    .INIT(2'h2)) 
    i_97
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [6]));
  LUT1 #(
    .INIT(2'h2)) 
    i_98
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [5]));
  LUT1 #(
    .INIT(2'h2)) 
    i_99
       (.I0(1'b0),
        .O(\trace_data_pipe[6] [4]));
  LUT1 #(
    .INIT(2'h1)) 
    trace_clk_out_i_1
       (.I0(trace_clk_out),
        .O(p_0_in));
  FDRE trace_clk_out_reg
       (.C(pl_ps_trace_clk),
        .CE(1'b1),
        .D(p_0_in),
        .Q(trace_clk_out),
        .R(1'b0));
endmodule

(* CHECK_LICENSE_TYPE = "zynqmpsoc_zynq_ultra_ps_e_0_0,zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e,Vivado 2019.2.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (maxihpm0_fpd_aclk,
    maxigp0_awid,
    maxigp0_awaddr,
    maxigp0_awlen,
    maxigp0_awsize,
    maxigp0_awburst,
    maxigp0_awlock,
    maxigp0_awcache,
    maxigp0_awprot,
    maxigp0_awvalid,
    maxigp0_awuser,
    maxigp0_awready,
    maxigp0_wdata,
    maxigp0_wstrb,
    maxigp0_wlast,
    maxigp0_wvalid,
    maxigp0_wready,
    maxigp0_bid,
    maxigp0_bresp,
    maxigp0_bvalid,
    maxigp0_bready,
    maxigp0_arid,
    maxigp0_araddr,
    maxigp0_arlen,
    maxigp0_arsize,
    maxigp0_arburst,
    maxigp0_arlock,
    maxigp0_arcache,
    maxigp0_arprot,
    maxigp0_arvalid,
    maxigp0_aruser,
    maxigp0_arready,
    maxigp0_rid,
    maxigp0_rdata,
    maxigp0_rresp,
    maxigp0_rlast,
    maxigp0_rvalid,
    maxigp0_rready,
    maxigp0_awqos,
    maxigp0_arqos,
    maxihpm1_fpd_aclk,
    maxigp1_awid,
    maxigp1_awaddr,
    maxigp1_awlen,
    maxigp1_awsize,
    maxigp1_awburst,
    maxigp1_awlock,
    maxigp1_awcache,
    maxigp1_awprot,
    maxigp1_awvalid,
    maxigp1_awuser,
    maxigp1_awready,
    maxigp1_wdata,
    maxigp1_wstrb,
    maxigp1_wlast,
    maxigp1_wvalid,
    maxigp1_wready,
    maxigp1_bid,
    maxigp1_bresp,
    maxigp1_bvalid,
    maxigp1_bready,
    maxigp1_arid,
    maxigp1_araddr,
    maxigp1_arlen,
    maxigp1_arsize,
    maxigp1_arburst,
    maxigp1_arlock,
    maxigp1_arcache,
    maxigp1_arprot,
    maxigp1_arvalid,
    maxigp1_aruser,
    maxigp1_arready,
    maxigp1_rid,
    maxigp1_rdata,
    maxigp1_rresp,
    maxigp1_rlast,
    maxigp1_rvalid,
    maxigp1_rready,
    maxigp1_awqos,
    maxigp1_arqos,
    saxihpc0_fpd_aclk,
    saxigp0_aruser,
    saxigp0_awuser,
    saxigp0_awid,
    saxigp0_awaddr,
    saxigp0_awlen,
    saxigp0_awsize,
    saxigp0_awburst,
    saxigp0_awlock,
    saxigp0_awcache,
    saxigp0_awprot,
    saxigp0_awvalid,
    saxigp0_awready,
    saxigp0_wdata,
    saxigp0_wstrb,
    saxigp0_wlast,
    saxigp0_wvalid,
    saxigp0_wready,
    saxigp0_bid,
    saxigp0_bresp,
    saxigp0_bvalid,
    saxigp0_bready,
    saxigp0_arid,
    saxigp0_araddr,
    saxigp0_arlen,
    saxigp0_arsize,
    saxigp0_arburst,
    saxigp0_arlock,
    saxigp0_arcache,
    saxigp0_arprot,
    saxigp0_arvalid,
    saxigp0_arready,
    saxigp0_rid,
    saxigp0_rdata,
    saxigp0_rresp,
    saxigp0_rlast,
    saxigp0_rvalid,
    saxigp0_rready,
    saxigp0_awqos,
    saxigp0_arqos,
    pl_resetn0,
    pl_clk0);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M_AXI_HPM0_FPD_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_HPM0_FPD_ACLK, ASSOCIATED_BUSIF M_AXI_HPM0_FPD, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input maxihpm0_fpd_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWID" *) output [15:0]maxigp0_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWADDR" *) output [39:0]maxigp0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWLEN" *) output [7:0]maxigp0_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWSIZE" *) output [2:0]maxigp0_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWBURST" *) output [1:0]maxigp0_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWLOCK" *) output maxigp0_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWCACHE" *) output [3:0]maxigp0_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWPROT" *) output [2:0]maxigp0_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWVALID" *) output maxigp0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWUSER" *) output [15:0]maxigp0_awuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWREADY" *) input maxigp0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WDATA" *) output [31:0]maxigp0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WSTRB" *) output [3:0]maxigp0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WLAST" *) output maxigp0_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WVALID" *) output maxigp0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WREADY" *) input maxigp0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BID" *) input [15:0]maxigp0_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BRESP" *) input [1:0]maxigp0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BVALID" *) input maxigp0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BREADY" *) output maxigp0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARID" *) output [15:0]maxigp0_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARADDR" *) output [39:0]maxigp0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARLEN" *) output [7:0]maxigp0_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARSIZE" *) output [2:0]maxigp0_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARBURST" *) output [1:0]maxigp0_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARLOCK" *) output maxigp0_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARCACHE" *) output [3:0]maxigp0_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARPROT" *) output [2:0]maxigp0_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARVALID" *) output maxigp0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARUSER" *) output [15:0]maxigp0_aruser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARREADY" *) input maxigp0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RID" *) input [15:0]maxigp0_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RDATA" *) input [31:0]maxigp0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RRESP" *) input [1:0]maxigp0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RLAST" *) input maxigp0_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RVALID" *) input maxigp0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RREADY" *) output maxigp0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWQOS" *) output [3:0]maxigp0_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARQOS" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_HPM0_FPD, NUM_WRITE_OUTSTANDING 8, NUM_READ_OUTSTANDING 8, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 16, ARUSER_WIDTH 16, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [3:0]maxigp0_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M_AXI_HPM1_FPD_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_HPM1_FPD_ACLK, ASSOCIATED_BUSIF M_AXI_HPM1_FPD, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input maxihpm1_fpd_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWID" *) output [15:0]maxigp1_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWADDR" *) output [39:0]maxigp1_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWLEN" *) output [7:0]maxigp1_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWSIZE" *) output [2:0]maxigp1_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWBURST" *) output [1:0]maxigp1_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWLOCK" *) output maxigp1_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWCACHE" *) output [3:0]maxigp1_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWPROT" *) output [2:0]maxigp1_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWVALID" *) output maxigp1_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWUSER" *) output [15:0]maxigp1_awuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWREADY" *) input maxigp1_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WDATA" *) output [31:0]maxigp1_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WSTRB" *) output [3:0]maxigp1_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WLAST" *) output maxigp1_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WVALID" *) output maxigp1_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WREADY" *) input maxigp1_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BID" *) input [15:0]maxigp1_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BRESP" *) input [1:0]maxigp1_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BVALID" *) input maxigp1_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BREADY" *) output maxigp1_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARID" *) output [15:0]maxigp1_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARADDR" *) output [39:0]maxigp1_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARLEN" *) output [7:0]maxigp1_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARSIZE" *) output [2:0]maxigp1_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARBURST" *) output [1:0]maxigp1_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARLOCK" *) output maxigp1_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARCACHE" *) output [3:0]maxigp1_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARPROT" *) output [2:0]maxigp1_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARVALID" *) output maxigp1_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARUSER" *) output [15:0]maxigp1_aruser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARREADY" *) input maxigp1_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RID" *) input [15:0]maxigp1_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RDATA" *) input [31:0]maxigp1_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RRESP" *) input [1:0]maxigp1_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RLAST" *) input maxigp1_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RVALID" *) input maxigp1_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RREADY" *) output maxigp1_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWQOS" *) output [3:0]maxigp1_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARQOS" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_HPM1_FPD, NUM_WRITE_OUTSTANDING 8, NUM_READ_OUTSTANDING 8, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 16, ARUSER_WIDTH 16, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [3:0]maxigp1_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXI_HPC0_FPD_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_HPC0_FPD_ACLK, ASSOCIATED_BUSIF S_AXI_HPC0_FPD, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input saxihpc0_fpd_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARUSER" *) input saxigp0_aruser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWUSER" *) input saxigp0_awuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWID" *) input [5:0]saxigp0_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWADDR" *) input [48:0]saxigp0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWLEN" *) input [7:0]saxigp0_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWSIZE" *) input [2:0]saxigp0_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWBURST" *) input [1:0]saxigp0_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWLOCK" *) input saxigp0_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWCACHE" *) input [3:0]saxigp0_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWPROT" *) input [2:0]saxigp0_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWVALID" *) input saxigp0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWREADY" *) output saxigp0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WDATA" *) input [63:0]saxigp0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WSTRB" *) input [7:0]saxigp0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WLAST" *) input saxigp0_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WVALID" *) input saxigp0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WREADY" *) output saxigp0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BID" *) output [5:0]saxigp0_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BRESP" *) output [1:0]saxigp0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BVALID" *) output saxigp0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BREADY" *) input saxigp0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARID" *) input [5:0]saxigp0_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARADDR" *) input [48:0]saxigp0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARLEN" *) input [7:0]saxigp0_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARSIZE" *) input [2:0]saxigp0_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARBURST" *) input [1:0]saxigp0_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARLOCK" *) input saxigp0_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARCACHE" *) input [3:0]saxigp0_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARPROT" *) input [2:0]saxigp0_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARVALID" *) input saxigp0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARREADY" *) output saxigp0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RID" *) output [5:0]saxigp0_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RDATA" *) output [63:0]saxigp0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RRESP" *) output [1:0]saxigp0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RLAST" *) output saxigp0_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RVALID" *) output saxigp0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RREADY" *) input saxigp0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWQOS" *) input [3:0]saxigp0_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARQOS" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_HPC0_FPD, NUM_WRITE_OUTSTANDING 16, NUM_READ_OUTSTANDING 16, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 6, ADDR_WIDTH 49, AWUSER_WIDTH 1, ARUSER_WIDTH 1, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, MAX_BURST_LENGTH 16, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [3:0]saxigp0_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 PL_RESETN0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PL_RESETN0, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) output pl_resetn0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 PL_CLK0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME PL_CLK0, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) output pl_clk0;

  wire [39:0]maxigp0_araddr;
  wire [1:0]maxigp0_arburst;
  wire [3:0]maxigp0_arcache;
  wire [15:0]maxigp0_arid;
  wire [7:0]maxigp0_arlen;
  wire maxigp0_arlock;
  wire [2:0]maxigp0_arprot;
  wire [3:0]maxigp0_arqos;
  wire maxigp0_arready;
  wire [2:0]maxigp0_arsize;
  wire [15:0]maxigp0_aruser;
  wire maxigp0_arvalid;
  wire [39:0]maxigp0_awaddr;
  wire [1:0]maxigp0_awburst;
  wire [3:0]maxigp0_awcache;
  wire [15:0]maxigp0_awid;
  wire [7:0]maxigp0_awlen;
  wire maxigp0_awlock;
  wire [2:0]maxigp0_awprot;
  wire [3:0]maxigp0_awqos;
  wire maxigp0_awready;
  wire [2:0]maxigp0_awsize;
  wire [15:0]maxigp0_awuser;
  wire maxigp0_awvalid;
  wire [15:0]maxigp0_bid;
  wire maxigp0_bready;
  wire [1:0]maxigp0_bresp;
  wire maxigp0_bvalid;
  wire [31:0]maxigp0_rdata;
  wire [15:0]maxigp0_rid;
  wire maxigp0_rlast;
  wire maxigp0_rready;
  wire [1:0]maxigp0_rresp;
  wire maxigp0_rvalid;
  wire [31:0]maxigp0_wdata;
  wire maxigp0_wlast;
  wire maxigp0_wready;
  wire [3:0]maxigp0_wstrb;
  wire maxigp0_wvalid;
  wire [39:0]maxigp1_araddr;
  wire [1:0]maxigp1_arburst;
  wire [3:0]maxigp1_arcache;
  wire [15:0]maxigp1_arid;
  wire [7:0]maxigp1_arlen;
  wire maxigp1_arlock;
  wire [2:0]maxigp1_arprot;
  wire [3:0]maxigp1_arqos;
  wire maxigp1_arready;
  wire [2:0]maxigp1_arsize;
  wire [15:0]maxigp1_aruser;
  wire maxigp1_arvalid;
  wire [39:0]maxigp1_awaddr;
  wire [1:0]maxigp1_awburst;
  wire [3:0]maxigp1_awcache;
  wire [15:0]maxigp1_awid;
  wire [7:0]maxigp1_awlen;
  wire maxigp1_awlock;
  wire [2:0]maxigp1_awprot;
  wire [3:0]maxigp1_awqos;
  wire maxigp1_awready;
  wire [2:0]maxigp1_awsize;
  wire [15:0]maxigp1_awuser;
  wire maxigp1_awvalid;
  wire [15:0]maxigp1_bid;
  wire maxigp1_bready;
  wire [1:0]maxigp1_bresp;
  wire maxigp1_bvalid;
  wire [31:0]maxigp1_rdata;
  wire [15:0]maxigp1_rid;
  wire maxigp1_rlast;
  wire maxigp1_rready;
  wire [1:0]maxigp1_rresp;
  wire maxigp1_rvalid;
  wire [31:0]maxigp1_wdata;
  wire maxigp1_wlast;
  wire maxigp1_wready;
  wire [3:0]maxigp1_wstrb;
  wire maxigp1_wvalid;
  wire maxihpm0_fpd_aclk;
  wire maxihpm1_fpd_aclk;
  wire pl_clk0;
  wire pl_resetn0;
  wire [48:0]saxigp0_araddr;
  wire [1:0]saxigp0_arburst;
  wire [3:0]saxigp0_arcache;
  wire [5:0]saxigp0_arid;
  wire [7:0]saxigp0_arlen;
  wire saxigp0_arlock;
  wire [2:0]saxigp0_arprot;
  wire [3:0]saxigp0_arqos;
  wire saxigp0_arready;
  wire [2:0]saxigp0_arsize;
  wire saxigp0_aruser;
  wire saxigp0_arvalid;
  wire [48:0]saxigp0_awaddr;
  wire [1:0]saxigp0_awburst;
  wire [3:0]saxigp0_awcache;
  wire [5:0]saxigp0_awid;
  wire [7:0]saxigp0_awlen;
  wire saxigp0_awlock;
  wire [2:0]saxigp0_awprot;
  wire [3:0]saxigp0_awqos;
  wire saxigp0_awready;
  wire [2:0]saxigp0_awsize;
  wire saxigp0_awuser;
  wire saxigp0_awvalid;
  wire [5:0]saxigp0_bid;
  wire saxigp0_bready;
  wire [1:0]saxigp0_bresp;
  wire saxigp0_bvalid;
  wire [63:0]saxigp0_rdata;
  wire [5:0]saxigp0_rid;
  wire saxigp0_rlast;
  wire saxigp0_rready;
  wire [1:0]saxigp0_rresp;
  wire saxigp0_rvalid;
  wire [63:0]saxigp0_wdata;
  wire saxigp0_wlast;
  wire saxigp0_wready;
  wire [7:0]saxigp0_wstrb;
  wire saxigp0_wvalid;
  wire saxihpc0_fpd_aclk;
  wire NLW_inst_dbg_path_fifo_bypass_UNCONNECTED;
  wire NLW_inst_dp_audio_ref_clk_UNCONNECTED;
  wire NLW_inst_dp_aux_data_oe_n_UNCONNECTED;
  wire NLW_inst_dp_aux_data_out_UNCONNECTED;
  wire NLW_inst_dp_live_video_de_out_UNCONNECTED;
  wire NLW_inst_dp_m_axis_mixed_audio_tid_UNCONNECTED;
  wire NLW_inst_dp_m_axis_mixed_audio_tvalid_UNCONNECTED;
  wire NLW_inst_dp_s_axis_audio_tready_UNCONNECTED;
  wire NLW_inst_dp_video_out_hsync_UNCONNECTED;
  wire NLW_inst_dp_video_out_vsync_UNCONNECTED;
  wire NLW_inst_dp_video_ref_clk_UNCONNECTED;
  wire NLW_inst_emio_can0_phy_tx_UNCONNECTED;
  wire NLW_inst_emio_can1_phy_tx_UNCONNECTED;
  wire NLW_inst_emio_enet0_delay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet0_delay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet0_dma_tx_end_tog_UNCONNECTED;
  wire NLW_inst_emio_enet0_gmii_tx_en_UNCONNECTED;
  wire NLW_inst_emio_enet0_gmii_tx_er_UNCONNECTED;
  wire NLW_inst_emio_enet0_mdio_mdc_UNCONNECTED;
  wire NLW_inst_emio_enet0_mdio_o_UNCONNECTED;
  wire NLW_inst_emio_enet0_mdio_t_UNCONNECTED;
  wire NLW_inst_emio_enet0_mdio_t_n_UNCONNECTED;
  wire NLW_inst_emio_enet0_pdelay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet0_pdelay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet0_pdelay_resp_rx_UNCONNECTED;
  wire NLW_inst_emio_enet0_pdelay_resp_tx_UNCONNECTED;
  wire NLW_inst_emio_enet0_rx_sof_UNCONNECTED;
  wire NLW_inst_emio_enet0_rx_w_eop_UNCONNECTED;
  wire NLW_inst_emio_enet0_rx_w_err_UNCONNECTED;
  wire NLW_inst_emio_enet0_rx_w_flush_UNCONNECTED;
  wire NLW_inst_emio_enet0_rx_w_sop_UNCONNECTED;
  wire NLW_inst_emio_enet0_rx_w_wr_UNCONNECTED;
  wire NLW_inst_emio_enet0_sync_frame_rx_UNCONNECTED;
  wire NLW_inst_emio_enet0_sync_frame_tx_UNCONNECTED;
  wire NLW_inst_emio_enet0_tsu_timer_cmp_val_UNCONNECTED;
  wire NLW_inst_emio_enet0_tx_r_fixed_lat_UNCONNECTED;
  wire NLW_inst_emio_enet0_tx_r_rd_UNCONNECTED;
  wire NLW_inst_emio_enet0_tx_sof_UNCONNECTED;
  wire NLW_inst_emio_enet1_delay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet1_delay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet1_dma_tx_end_tog_UNCONNECTED;
  wire NLW_inst_emio_enet1_gmii_tx_en_UNCONNECTED;
  wire NLW_inst_emio_enet1_gmii_tx_er_UNCONNECTED;
  wire NLW_inst_emio_enet1_mdio_mdc_UNCONNECTED;
  wire NLW_inst_emio_enet1_mdio_o_UNCONNECTED;
  wire NLW_inst_emio_enet1_mdio_t_UNCONNECTED;
  wire NLW_inst_emio_enet1_mdio_t_n_UNCONNECTED;
  wire NLW_inst_emio_enet1_pdelay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet1_pdelay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet1_pdelay_resp_rx_UNCONNECTED;
  wire NLW_inst_emio_enet1_pdelay_resp_tx_UNCONNECTED;
  wire NLW_inst_emio_enet1_rx_sof_UNCONNECTED;
  wire NLW_inst_emio_enet1_rx_w_eop_UNCONNECTED;
  wire NLW_inst_emio_enet1_rx_w_err_UNCONNECTED;
  wire NLW_inst_emio_enet1_rx_w_flush_UNCONNECTED;
  wire NLW_inst_emio_enet1_rx_w_sop_UNCONNECTED;
  wire NLW_inst_emio_enet1_rx_w_wr_UNCONNECTED;
  wire NLW_inst_emio_enet1_sync_frame_rx_UNCONNECTED;
  wire NLW_inst_emio_enet1_sync_frame_tx_UNCONNECTED;
  wire NLW_inst_emio_enet1_tsu_timer_cmp_val_UNCONNECTED;
  wire NLW_inst_emio_enet1_tx_r_fixed_lat_UNCONNECTED;
  wire NLW_inst_emio_enet1_tx_r_rd_UNCONNECTED;
  wire NLW_inst_emio_enet1_tx_sof_UNCONNECTED;
  wire NLW_inst_emio_enet2_delay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet2_delay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet2_dma_tx_end_tog_UNCONNECTED;
  wire NLW_inst_emio_enet2_gmii_tx_en_UNCONNECTED;
  wire NLW_inst_emio_enet2_gmii_tx_er_UNCONNECTED;
  wire NLW_inst_emio_enet2_mdio_mdc_UNCONNECTED;
  wire NLW_inst_emio_enet2_mdio_o_UNCONNECTED;
  wire NLW_inst_emio_enet2_mdio_t_UNCONNECTED;
  wire NLW_inst_emio_enet2_mdio_t_n_UNCONNECTED;
  wire NLW_inst_emio_enet2_pdelay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet2_pdelay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet2_pdelay_resp_rx_UNCONNECTED;
  wire NLW_inst_emio_enet2_pdelay_resp_tx_UNCONNECTED;
  wire NLW_inst_emio_enet2_rx_sof_UNCONNECTED;
  wire NLW_inst_emio_enet2_rx_w_eop_UNCONNECTED;
  wire NLW_inst_emio_enet2_rx_w_err_UNCONNECTED;
  wire NLW_inst_emio_enet2_rx_w_flush_UNCONNECTED;
  wire NLW_inst_emio_enet2_rx_w_sop_UNCONNECTED;
  wire NLW_inst_emio_enet2_rx_w_wr_UNCONNECTED;
  wire NLW_inst_emio_enet2_sync_frame_rx_UNCONNECTED;
  wire NLW_inst_emio_enet2_sync_frame_tx_UNCONNECTED;
  wire NLW_inst_emio_enet2_tsu_timer_cmp_val_UNCONNECTED;
  wire NLW_inst_emio_enet2_tx_r_fixed_lat_UNCONNECTED;
  wire NLW_inst_emio_enet2_tx_r_rd_UNCONNECTED;
  wire NLW_inst_emio_enet2_tx_sof_UNCONNECTED;
  wire NLW_inst_emio_enet3_delay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet3_delay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet3_dma_tx_end_tog_UNCONNECTED;
  wire NLW_inst_emio_enet3_gmii_tx_en_UNCONNECTED;
  wire NLW_inst_emio_enet3_gmii_tx_er_UNCONNECTED;
  wire NLW_inst_emio_enet3_mdio_mdc_UNCONNECTED;
  wire NLW_inst_emio_enet3_mdio_o_UNCONNECTED;
  wire NLW_inst_emio_enet3_mdio_t_UNCONNECTED;
  wire NLW_inst_emio_enet3_mdio_t_n_UNCONNECTED;
  wire NLW_inst_emio_enet3_pdelay_req_rx_UNCONNECTED;
  wire NLW_inst_emio_enet3_pdelay_req_tx_UNCONNECTED;
  wire NLW_inst_emio_enet3_pdelay_resp_rx_UNCONNECTED;
  wire NLW_inst_emio_enet3_pdelay_resp_tx_UNCONNECTED;
  wire NLW_inst_emio_enet3_rx_sof_UNCONNECTED;
  wire NLW_inst_emio_enet3_rx_w_eop_UNCONNECTED;
  wire NLW_inst_emio_enet3_rx_w_err_UNCONNECTED;
  wire NLW_inst_emio_enet3_rx_w_flush_UNCONNECTED;
  wire NLW_inst_emio_enet3_rx_w_sop_UNCONNECTED;
  wire NLW_inst_emio_enet3_rx_w_wr_UNCONNECTED;
  wire NLW_inst_emio_enet3_sync_frame_rx_UNCONNECTED;
  wire NLW_inst_emio_enet3_sync_frame_tx_UNCONNECTED;
  wire NLW_inst_emio_enet3_tsu_timer_cmp_val_UNCONNECTED;
  wire NLW_inst_emio_enet3_tx_r_fixed_lat_UNCONNECTED;
  wire NLW_inst_emio_enet3_tx_r_rd_UNCONNECTED;
  wire NLW_inst_emio_enet3_tx_sof_UNCONNECTED;
  wire NLW_inst_emio_i2c0_scl_o_UNCONNECTED;
  wire NLW_inst_emio_i2c0_scl_t_UNCONNECTED;
  wire NLW_inst_emio_i2c0_scl_t_n_UNCONNECTED;
  wire NLW_inst_emio_i2c0_sda_o_UNCONNECTED;
  wire NLW_inst_emio_i2c0_sda_t_UNCONNECTED;
  wire NLW_inst_emio_i2c0_sda_t_n_UNCONNECTED;
  wire NLW_inst_emio_i2c1_scl_o_UNCONNECTED;
  wire NLW_inst_emio_i2c1_scl_t_UNCONNECTED;
  wire NLW_inst_emio_i2c1_scl_t_n_UNCONNECTED;
  wire NLW_inst_emio_i2c1_sda_o_UNCONNECTED;
  wire NLW_inst_emio_i2c1_sda_t_UNCONNECTED;
  wire NLW_inst_emio_i2c1_sda_t_n_UNCONNECTED;
  wire NLW_inst_emio_sdio0_buspower_UNCONNECTED;
  wire NLW_inst_emio_sdio0_clkout_UNCONNECTED;
  wire NLW_inst_emio_sdio0_cmdena_UNCONNECTED;
  wire NLW_inst_emio_sdio0_cmdout_UNCONNECTED;
  wire NLW_inst_emio_sdio0_ledcontrol_UNCONNECTED;
  wire NLW_inst_emio_sdio1_buspower_UNCONNECTED;
  wire NLW_inst_emio_sdio1_clkout_UNCONNECTED;
  wire NLW_inst_emio_sdio1_cmdena_UNCONNECTED;
  wire NLW_inst_emio_sdio1_cmdout_UNCONNECTED;
  wire NLW_inst_emio_sdio1_ledcontrol_UNCONNECTED;
  wire NLW_inst_emio_spi0_m_o_UNCONNECTED;
  wire NLW_inst_emio_spi0_mo_t_UNCONNECTED;
  wire NLW_inst_emio_spi0_mo_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi0_s_o_UNCONNECTED;
  wire NLW_inst_emio_spi0_sclk_o_UNCONNECTED;
  wire NLW_inst_emio_spi0_sclk_t_UNCONNECTED;
  wire NLW_inst_emio_spi0_sclk_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi0_so_t_UNCONNECTED;
  wire NLW_inst_emio_spi0_so_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi0_ss1_o_n_UNCONNECTED;
  wire NLW_inst_emio_spi0_ss2_o_n_UNCONNECTED;
  wire NLW_inst_emio_spi0_ss_n_t_UNCONNECTED;
  wire NLW_inst_emio_spi0_ss_n_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi0_ss_o_n_UNCONNECTED;
  wire NLW_inst_emio_spi1_m_o_UNCONNECTED;
  wire NLW_inst_emio_spi1_mo_t_UNCONNECTED;
  wire NLW_inst_emio_spi1_mo_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi1_s_o_UNCONNECTED;
  wire NLW_inst_emio_spi1_sclk_o_UNCONNECTED;
  wire NLW_inst_emio_spi1_sclk_t_UNCONNECTED;
  wire NLW_inst_emio_spi1_sclk_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi1_so_t_UNCONNECTED;
  wire NLW_inst_emio_spi1_so_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi1_ss1_o_n_UNCONNECTED;
  wire NLW_inst_emio_spi1_ss2_o_n_UNCONNECTED;
  wire NLW_inst_emio_spi1_ss_n_t_UNCONNECTED;
  wire NLW_inst_emio_spi1_ss_n_t_n_UNCONNECTED;
  wire NLW_inst_emio_spi1_ss_o_n_UNCONNECTED;
  wire NLW_inst_emio_u2dsport_vbus_ctrl_usb3_0_UNCONNECTED;
  wire NLW_inst_emio_u2dsport_vbus_ctrl_usb3_1_UNCONNECTED;
  wire NLW_inst_emio_u3dsport_vbus_ctrl_usb3_0_UNCONNECTED;
  wire NLW_inst_emio_u3dsport_vbus_ctrl_usb3_1_UNCONNECTED;
  wire NLW_inst_emio_uart0_dtrn_UNCONNECTED;
  wire NLW_inst_emio_uart0_rtsn_UNCONNECTED;
  wire NLW_inst_emio_uart0_txd_UNCONNECTED;
  wire NLW_inst_emio_uart1_dtrn_UNCONNECTED;
  wire NLW_inst_emio_uart1_rtsn_UNCONNECTED;
  wire NLW_inst_emio_uart1_txd_UNCONNECTED;
  wire NLW_inst_emio_wdt0_rst_o_UNCONNECTED;
  wire NLW_inst_emio_wdt1_rst_o_UNCONNECTED;
  wire NLW_inst_fmio_char_afifsfpd_test_output_UNCONNECTED;
  wire NLW_inst_fmio_char_afifslpd_test_output_UNCONNECTED;
  wire NLW_inst_fmio_char_gem_test_output_UNCONNECTED;
  wire NLW_inst_fmio_gem0_fifo_rx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem0_fifo_tx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem1_fifo_rx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem1_fifo_tx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem2_fifo_rx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem2_fifo_tx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem3_fifo_rx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem3_fifo_tx_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_gem_tsu_clk_to_pl_bufg_UNCONNECTED;
  wire NLW_inst_fmio_test_io_char_scan_out_UNCONNECTED;
  wire NLW_inst_fpd_pl_spare_0_out_UNCONNECTED;
  wire NLW_inst_fpd_pl_spare_1_out_UNCONNECTED;
  wire NLW_inst_fpd_pl_spare_2_out_UNCONNECTED;
  wire NLW_inst_fpd_pl_spare_3_out_UNCONNECTED;
  wire NLW_inst_fpd_pl_spare_4_out_UNCONNECTED;
  wire NLW_inst_io_char_audio_out_test_data_UNCONNECTED;
  wire NLW_inst_io_char_video_out_test_data_UNCONNECTED;
  wire NLW_inst_irq_ipi_pl_0_UNCONNECTED;
  wire NLW_inst_irq_ipi_pl_1_UNCONNECTED;
  wire NLW_inst_irq_ipi_pl_2_UNCONNECTED;
  wire NLW_inst_irq_ipi_pl_3_UNCONNECTED;
  wire NLW_inst_lpd_pl_spare_0_out_UNCONNECTED;
  wire NLW_inst_lpd_pl_spare_1_out_UNCONNECTED;
  wire NLW_inst_lpd_pl_spare_2_out_UNCONNECTED;
  wire NLW_inst_lpd_pl_spare_3_out_UNCONNECTED;
  wire NLW_inst_lpd_pl_spare_4_out_UNCONNECTED;
  wire NLW_inst_maxigp2_arlock_UNCONNECTED;
  wire NLW_inst_maxigp2_arvalid_UNCONNECTED;
  wire NLW_inst_maxigp2_awlock_UNCONNECTED;
  wire NLW_inst_maxigp2_awvalid_UNCONNECTED;
  wire NLW_inst_maxigp2_bready_UNCONNECTED;
  wire NLW_inst_maxigp2_rready_UNCONNECTED;
  wire NLW_inst_maxigp2_wlast_UNCONNECTED;
  wire NLW_inst_maxigp2_wvalid_UNCONNECTED;
  wire NLW_inst_o_afe_TX_dig_reset_rel_ack_UNCONNECTED;
  wire NLW_inst_o_afe_TX_pipe_TX_dn_rxdet_UNCONNECTED;
  wire NLW_inst_o_afe_TX_pipe_TX_dp_rxdet_UNCONNECTED;
  wire NLW_inst_o_afe_cmn_calib_comp_out_UNCONNECTED;
  wire NLW_inst_o_afe_pg_avddcr_UNCONNECTED;
  wire NLW_inst_o_afe_pg_avddio_UNCONNECTED;
  wire NLW_inst_o_afe_pg_dvddcr_UNCONNECTED;
  wire NLW_inst_o_afe_pg_static_avddcr_UNCONNECTED;
  wire NLW_inst_o_afe_pg_static_avddio_UNCONNECTED;
  wire NLW_inst_o_afe_pll_clk_sym_hs_UNCONNECTED;
  wire NLW_inst_o_afe_pll_fbclk_frac_UNCONNECTED;
  wire NLW_inst_o_afe_rx_hsrx_clock_stop_ack_UNCONNECTED;
  wire NLW_inst_o_afe_rx_pipe_lfpsbcn_rxelecidle_UNCONNECTED;
  wire NLW_inst_o_afe_rx_pipe_sigdet_UNCONNECTED;
  wire NLW_inst_o_afe_rx_symbol_clk_by_2_UNCONNECTED;
  wire NLW_inst_o_afe_rx_uphy_rx_calib_done_UNCONNECTED;
  wire NLW_inst_o_afe_rx_uphy_save_calcode_UNCONNECTED;
  wire NLW_inst_o_afe_rx_uphy_startloop_buf_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_phystatus_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_rstb_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_rx_sgmii_en_cdet_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_rxclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_rxelecidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_rxpolarity_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_rxvalid_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_coreclockready_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_coreready_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_corerxsignaldet_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_phyctrlpartial_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_phyctrlreset_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_phyctrlrxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_phyctrlslumber_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_phyctrltxidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_sata_phyctrltxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_tx_sgmii_ewrap_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_txclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_txdetrx_lpback_UNCONNECTED;
  wire NLW_inst_o_dbg_l0_txelecidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_phystatus_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_rstb_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_rx_sgmii_en_cdet_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_rxclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_rxelecidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_rxpolarity_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_rxvalid_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_coreclockready_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_coreready_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_corerxsignaldet_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_phyctrlpartial_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_phyctrlreset_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_phyctrlrxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_phyctrlslumber_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_phyctrltxidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_sata_phyctrltxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_tx_sgmii_ewrap_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_txclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_txdetrx_lpback_UNCONNECTED;
  wire NLW_inst_o_dbg_l1_txelecidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_phystatus_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_rstb_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_rx_sgmii_en_cdet_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_rxclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_rxelecidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_rxpolarity_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_rxvalid_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_coreclockready_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_coreready_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_corerxsignaldet_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_phyctrlpartial_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_phyctrlreset_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_phyctrlrxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_phyctrlslumber_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_phyctrltxidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_sata_phyctrltxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_tx_sgmii_ewrap_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_txclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_txdetrx_lpback_UNCONNECTED;
  wire NLW_inst_o_dbg_l2_txelecidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_phystatus_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_rstb_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_rx_sgmii_en_cdet_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_rxclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_rxelecidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_rxpolarity_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_rxvalid_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_coreclockready_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_coreready_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_corerxsignaldet_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_phyctrlpartial_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_phyctrlreset_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_phyctrlrxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_phyctrlslumber_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_phyctrltxidle_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_sata_phyctrltxrst_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_tx_sgmii_ewrap_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_txclk_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_txdetrx_lpback_UNCONNECTED;
  wire NLW_inst_o_dbg_l3_txelecidle_UNCONNECTED;
  wire NLW_inst_osc_rtc_clk_UNCONNECTED;
  wire NLW_inst_pl_clk1_UNCONNECTED;
  wire NLW_inst_pl_clk2_UNCONNECTED;
  wire NLW_inst_pl_clk3_UNCONNECTED;
  wire NLW_inst_pl_resetn1_UNCONNECTED;
  wire NLW_inst_pl_resetn2_UNCONNECTED;
  wire NLW_inst_pl_resetn3_UNCONNECTED;
  wire NLW_inst_pmu_aib_afifm_fpd_req_UNCONNECTED;
  wire NLW_inst_pmu_aib_afifm_lpd_req_UNCONNECTED;
  wire NLW_inst_ps_pl_evento_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_aib_axi_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ams_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_apm_fpd_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_apu_exterr_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_apu_l2err_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_apu_regs_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_atb_err_lpd_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_can0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_can1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_clkmon_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_csu_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_csu_dma_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_csu_pmu_wdt_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ddr_ss_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_dpdma_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_dport_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_efuse_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet0_wake_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet1_wake_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet2_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet2_wake_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet3_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_enet3_wake_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_fp_wdt_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_fpd_apb_int_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_fpd_atb_error_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_gpio_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_gpu_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_i2c0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_i2c1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_intf_fpd_smmu_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_intf_ppd_cci_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ipi_channel0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ipi_channel1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ipi_channel10_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ipi_channel2_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ipi_channel7_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ipi_channel8_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ipi_channel9_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_lp_wdt_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_lpd_apb_intr_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_lpd_apm_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_nand_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ocm_error_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_pcie_dma_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_pcie_legacy_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_pcie_msc_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_qspi_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_r5_core0_ecc_error_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_r5_core1_ecc_error_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_rtc_alaram_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_rtc_seconds_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_sata_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_sdio0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_sdio0_wake_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_sdio1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_sdio1_wake_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_spi0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_spi1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc0_0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc0_1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc0_2_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc1_0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc1_1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc1_2_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc2_0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc2_1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc2_2_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc3_0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc3_1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_ttc3_2_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_uart0_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_uart1_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_usb3_0_otg_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_usb3_1_otg_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_xmpu_fpd_UNCONNECTED;
  wire NLW_inst_ps_pl_irq_xmpu_lpd_UNCONNECTED;
  wire NLW_inst_ps_pl_tracectl_UNCONNECTED;
  wire NLW_inst_ps_pl_trigack_0_UNCONNECTED;
  wire NLW_inst_ps_pl_trigack_1_UNCONNECTED;
  wire NLW_inst_ps_pl_trigack_2_UNCONNECTED;
  wire NLW_inst_ps_pl_trigack_3_UNCONNECTED;
  wire NLW_inst_ps_pl_trigger_0_UNCONNECTED;
  wire NLW_inst_ps_pl_trigger_1_UNCONNECTED;
  wire NLW_inst_ps_pl_trigger_2_UNCONNECTED;
  wire NLW_inst_ps_pl_trigger_3_UNCONNECTED;
  wire NLW_inst_rpu_evento0_UNCONNECTED;
  wire NLW_inst_rpu_evento1_UNCONNECTED;
  wire NLW_inst_sacefpd_acvalid_UNCONNECTED;
  wire NLW_inst_sacefpd_arready_UNCONNECTED;
  wire NLW_inst_sacefpd_awready_UNCONNECTED;
  wire NLW_inst_sacefpd_buser_UNCONNECTED;
  wire NLW_inst_sacefpd_bvalid_UNCONNECTED;
  wire NLW_inst_sacefpd_cdready_UNCONNECTED;
  wire NLW_inst_sacefpd_crready_UNCONNECTED;
  wire NLW_inst_sacefpd_rlast_UNCONNECTED;
  wire NLW_inst_sacefpd_ruser_UNCONNECTED;
  wire NLW_inst_sacefpd_rvalid_UNCONNECTED;
  wire NLW_inst_sacefpd_wready_UNCONNECTED;
  wire NLW_inst_saxiacp_arready_UNCONNECTED;
  wire NLW_inst_saxiacp_awready_UNCONNECTED;
  wire NLW_inst_saxiacp_bvalid_UNCONNECTED;
  wire NLW_inst_saxiacp_rlast_UNCONNECTED;
  wire NLW_inst_saxiacp_rvalid_UNCONNECTED;
  wire NLW_inst_saxiacp_wready_UNCONNECTED;
  wire NLW_inst_saxigp1_arready_UNCONNECTED;
  wire NLW_inst_saxigp1_awready_UNCONNECTED;
  wire NLW_inst_saxigp1_bvalid_UNCONNECTED;
  wire NLW_inst_saxigp1_rlast_UNCONNECTED;
  wire NLW_inst_saxigp1_rvalid_UNCONNECTED;
  wire NLW_inst_saxigp1_wready_UNCONNECTED;
  wire NLW_inst_saxigp2_arready_UNCONNECTED;
  wire NLW_inst_saxigp2_awready_UNCONNECTED;
  wire NLW_inst_saxigp2_bvalid_UNCONNECTED;
  wire NLW_inst_saxigp2_rlast_UNCONNECTED;
  wire NLW_inst_saxigp2_rvalid_UNCONNECTED;
  wire NLW_inst_saxigp2_wready_UNCONNECTED;
  wire NLW_inst_saxigp3_arready_UNCONNECTED;
  wire NLW_inst_saxigp3_awready_UNCONNECTED;
  wire NLW_inst_saxigp3_bvalid_UNCONNECTED;
  wire NLW_inst_saxigp3_rlast_UNCONNECTED;
  wire NLW_inst_saxigp3_rvalid_UNCONNECTED;
  wire NLW_inst_saxigp3_wready_UNCONNECTED;
  wire NLW_inst_saxigp4_arready_UNCONNECTED;
  wire NLW_inst_saxigp4_awready_UNCONNECTED;
  wire NLW_inst_saxigp4_bvalid_UNCONNECTED;
  wire NLW_inst_saxigp4_rlast_UNCONNECTED;
  wire NLW_inst_saxigp4_rvalid_UNCONNECTED;
  wire NLW_inst_saxigp4_wready_UNCONNECTED;
  wire NLW_inst_saxigp5_arready_UNCONNECTED;
  wire NLW_inst_saxigp5_awready_UNCONNECTED;
  wire NLW_inst_saxigp5_bvalid_UNCONNECTED;
  wire NLW_inst_saxigp5_rlast_UNCONNECTED;
  wire NLW_inst_saxigp5_rvalid_UNCONNECTED;
  wire NLW_inst_saxigp5_wready_UNCONNECTED;
  wire NLW_inst_saxigp6_arready_UNCONNECTED;
  wire NLW_inst_saxigp6_awready_UNCONNECTED;
  wire NLW_inst_saxigp6_bvalid_UNCONNECTED;
  wire NLW_inst_saxigp6_rlast_UNCONNECTED;
  wire NLW_inst_saxigp6_rvalid_UNCONNECTED;
  wire NLW_inst_saxigp6_wready_UNCONNECTED;
  wire NLW_inst_test_bscan_tdo_UNCONNECTED;
  wire NLW_inst_test_ddr2pl_dcd_skewout_UNCONNECTED;
  wire NLW_inst_test_drdy_UNCONNECTED;
  wire NLW_inst_test_pl_scan_chopper_so_UNCONNECTED;
  wire NLW_inst_test_pl_scan_edt_out_apu_UNCONNECTED;
  wire NLW_inst_test_pl_scan_edt_out_cpu0_UNCONNECTED;
  wire NLW_inst_test_pl_scan_edt_out_cpu1_UNCONNECTED;
  wire NLW_inst_test_pl_scan_edt_out_cpu2_UNCONNECTED;
  wire NLW_inst_test_pl_scan_edt_out_cpu3_UNCONNECTED;
  wire NLW_inst_test_pl_scan_slcr_config_so_UNCONNECTED;
  wire NLW_inst_test_pl_scan_spare_out0_UNCONNECTED;
  wire NLW_inst_test_pl_scan_spare_out1_UNCONNECTED;
  wire NLW_inst_trace_clk_out_UNCONNECTED;
  wire NLW_inst_tst_rtc_osc_clk_out_UNCONNECTED;
  wire NLW_inst_tst_rtc_seconds_raw_int_UNCONNECTED;
  wire [7:0]NLW_inst_adma2pl_cack_UNCONNECTED;
  wire [7:0]NLW_inst_adma2pl_tvld_UNCONNECTED;
  wire [31:0]NLW_inst_dp_m_axis_mixed_audio_tdata_UNCONNECTED;
  wire [35:0]NLW_inst_dp_video_out_pixel1_UNCONNECTED;
  wire [1:0]NLW_inst_emio_enet0_dma_bus_width_UNCONNECTED;
  wire [93:0]NLW_inst_emio_enet0_enet_tsu_timer_cnt_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet0_gmii_txd_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet0_rx_w_data_UNCONNECTED;
  wire [44:0]NLW_inst_emio_enet0_rx_w_status_UNCONNECTED;
  wire [2:0]NLW_inst_emio_enet0_speed_mode_UNCONNECTED;
  wire [3:0]NLW_inst_emio_enet0_tx_r_status_UNCONNECTED;
  wire [1:0]NLW_inst_emio_enet1_dma_bus_width_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet1_gmii_txd_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet1_rx_w_data_UNCONNECTED;
  wire [44:0]NLW_inst_emio_enet1_rx_w_status_UNCONNECTED;
  wire [2:0]NLW_inst_emio_enet1_speed_mode_UNCONNECTED;
  wire [3:0]NLW_inst_emio_enet1_tx_r_status_UNCONNECTED;
  wire [1:0]NLW_inst_emio_enet2_dma_bus_width_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet2_gmii_txd_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet2_rx_w_data_UNCONNECTED;
  wire [44:0]NLW_inst_emio_enet2_rx_w_status_UNCONNECTED;
  wire [2:0]NLW_inst_emio_enet2_speed_mode_UNCONNECTED;
  wire [3:0]NLW_inst_emio_enet2_tx_r_status_UNCONNECTED;
  wire [1:0]NLW_inst_emio_enet3_dma_bus_width_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet3_gmii_txd_UNCONNECTED;
  wire [7:0]NLW_inst_emio_enet3_rx_w_data_UNCONNECTED;
  wire [44:0]NLW_inst_emio_enet3_rx_w_status_UNCONNECTED;
  wire [2:0]NLW_inst_emio_enet3_speed_mode_UNCONNECTED;
  wire [3:0]NLW_inst_emio_enet3_tx_r_status_UNCONNECTED;
  wire [0:0]NLW_inst_emio_gpio_o_UNCONNECTED;
  wire [0:0]NLW_inst_emio_gpio_t_UNCONNECTED;
  wire [0:0]NLW_inst_emio_gpio_t_n_UNCONNECTED;
  wire [2:0]NLW_inst_emio_sdio0_bus_volt_UNCONNECTED;
  wire [7:0]NLW_inst_emio_sdio0_dataena_UNCONNECTED;
  wire [7:0]NLW_inst_emio_sdio0_dataout_UNCONNECTED;
  wire [2:0]NLW_inst_emio_sdio1_bus_volt_UNCONNECTED;
  wire [7:0]NLW_inst_emio_sdio1_dataena_UNCONNECTED;
  wire [7:0]NLW_inst_emio_sdio1_dataout_UNCONNECTED;
  wire [2:0]NLW_inst_emio_ttc0_wave_o_UNCONNECTED;
  wire [2:0]NLW_inst_emio_ttc1_wave_o_UNCONNECTED;
  wire [2:0]NLW_inst_emio_ttc2_wave_o_UNCONNECTED;
  wire [2:0]NLW_inst_emio_ttc3_wave_o_UNCONNECTED;
  wire [7:0]NLW_inst_fmio_sd0_dll_test_out_UNCONNECTED;
  wire [7:0]NLW_inst_fmio_sd1_dll_test_out_UNCONNECTED;
  wire [31:0]NLW_inst_fpd_pll_test_out_UNCONNECTED;
  wire [31:0]NLW_inst_ftm_gpo_UNCONNECTED;
  wire [7:0]NLW_inst_gdma_perif_cack_UNCONNECTED;
  wire [7:0]NLW_inst_gdma_perif_tvld_UNCONNECTED;
  wire [31:0]NLW_inst_lpd_pll_test_out_UNCONNECTED;
  wire [39:0]NLW_inst_maxigp2_araddr_UNCONNECTED;
  wire [1:0]NLW_inst_maxigp2_arburst_UNCONNECTED;
  wire [3:0]NLW_inst_maxigp2_arcache_UNCONNECTED;
  wire [15:0]NLW_inst_maxigp2_arid_UNCONNECTED;
  wire [7:0]NLW_inst_maxigp2_arlen_UNCONNECTED;
  wire [2:0]NLW_inst_maxigp2_arprot_UNCONNECTED;
  wire [3:0]NLW_inst_maxigp2_arqos_UNCONNECTED;
  wire [2:0]NLW_inst_maxigp2_arsize_UNCONNECTED;
  wire [15:0]NLW_inst_maxigp2_aruser_UNCONNECTED;
  wire [39:0]NLW_inst_maxigp2_awaddr_UNCONNECTED;
  wire [1:0]NLW_inst_maxigp2_awburst_UNCONNECTED;
  wire [3:0]NLW_inst_maxigp2_awcache_UNCONNECTED;
  wire [15:0]NLW_inst_maxigp2_awid_UNCONNECTED;
  wire [7:0]NLW_inst_maxigp2_awlen_UNCONNECTED;
  wire [2:0]NLW_inst_maxigp2_awprot_UNCONNECTED;
  wire [3:0]NLW_inst_maxigp2_awqos_UNCONNECTED;
  wire [2:0]NLW_inst_maxigp2_awsize_UNCONNECTED;
  wire [15:0]NLW_inst_maxigp2_awuser_UNCONNECTED;
  wire [31:0]NLW_inst_maxigp2_wdata_UNCONNECTED;
  wire [3:0]NLW_inst_maxigp2_wstrb_UNCONNECTED;
  wire [12:0]NLW_inst_o_afe_pll_dco_count_UNCONNECTED;
  wire [19:0]NLW_inst_o_afe_rx_symbol_UNCONNECTED;
  wire [7:0]NLW_inst_o_afe_rx_uphy_save_calcode_data_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l0_powerdown_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l0_rate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l0_rxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l0_rxdatak_UNCONNECTED;
  wire [2:0]NLW_inst_o_dbg_l0_rxstatus_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l0_sata_corerxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l0_sata_corerxdatavalid_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l0_sata_phyctrlrxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l0_sata_phyctrltxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l0_sata_phyctrltxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l0_txdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l0_txdatak_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l1_powerdown_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l1_rate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l1_rxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l1_rxdatak_UNCONNECTED;
  wire [2:0]NLW_inst_o_dbg_l1_rxstatus_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l1_sata_corerxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l1_sata_corerxdatavalid_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l1_sata_phyctrlrxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l1_sata_phyctrltxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l1_sata_phyctrltxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l1_txdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l1_txdatak_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l2_powerdown_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l2_rate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l2_rxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l2_rxdatak_UNCONNECTED;
  wire [2:0]NLW_inst_o_dbg_l2_rxstatus_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l2_sata_corerxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l2_sata_corerxdatavalid_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l2_sata_phyctrlrxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l2_sata_phyctrltxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l2_sata_phyctrltxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l2_txdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l2_txdatak_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l3_powerdown_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l3_rate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l3_rxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l3_rxdatak_UNCONNECTED;
  wire [2:0]NLW_inst_o_dbg_l3_rxstatus_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l3_sata_corerxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l3_sata_corerxdatavalid_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l3_sata_phyctrlrxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l3_sata_phyctrltxdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l3_sata_phyctrltxrate_UNCONNECTED;
  wire [19:0]NLW_inst_o_dbg_l3_txdata_UNCONNECTED;
  wire [1:0]NLW_inst_o_dbg_l3_txdatak_UNCONNECTED;
  wire [46:0]NLW_inst_pmu_error_to_pl_UNCONNECTED;
  wire [31:0]NLW_inst_pmu_pl_gpo_UNCONNECTED;
  wire [7:0]NLW_inst_ps_pl_irq_adma_chan_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_irq_apu_comm_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_irq_apu_cpumnt_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_irq_apu_cti_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_irq_apu_pmu_UNCONNECTED;
  wire [7:0]NLW_inst_ps_pl_irq_gdma_chan_UNCONNECTED;
  wire [1:0]NLW_inst_ps_pl_irq_pcie_msi_UNCONNECTED;
  wire [1:0]NLW_inst_ps_pl_irq_rpu_pm_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_irq_usb3_0_endpoint_UNCONNECTED;
  wire [1:0]NLW_inst_ps_pl_irq_usb3_0_pmu_wakeup_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_irq_usb3_1_endpoint_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_standbywfe_UNCONNECTED;
  wire [3:0]NLW_inst_ps_pl_standbywfi_UNCONNECTED;
  wire [31:0]NLW_inst_ps_pl_tracedata_UNCONNECTED;
  wire [31:0]NLW_inst_pstp_pl_out_UNCONNECTED;
  wire [43:0]NLW_inst_sacefpd_acaddr_UNCONNECTED;
  wire [2:0]NLW_inst_sacefpd_acprot_UNCONNECTED;
  wire [3:0]NLW_inst_sacefpd_acsnoop_UNCONNECTED;
  wire [5:0]NLW_inst_sacefpd_bid_UNCONNECTED;
  wire [1:0]NLW_inst_sacefpd_bresp_UNCONNECTED;
  wire [127:0]NLW_inst_sacefpd_rdata_UNCONNECTED;
  wire [5:0]NLW_inst_sacefpd_rid_UNCONNECTED;
  wire [3:0]NLW_inst_sacefpd_rresp_UNCONNECTED;
  wire [4:0]NLW_inst_saxiacp_bid_UNCONNECTED;
  wire [1:0]NLW_inst_saxiacp_bresp_UNCONNECTED;
  wire [127:0]NLW_inst_saxiacp_rdata_UNCONNECTED;
  wire [4:0]NLW_inst_saxiacp_rid_UNCONNECTED;
  wire [1:0]NLW_inst_saxiacp_rresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp0_racount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp0_rcount_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp0_wacount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp0_wcount_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp1_bid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp1_bresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp1_racount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp1_rcount_UNCONNECTED;
  wire [127:0]NLW_inst_saxigp1_rdata_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp1_rid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp1_rresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp1_wacount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp1_wcount_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp2_bid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp2_bresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp2_racount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp2_rcount_UNCONNECTED;
  wire [127:0]NLW_inst_saxigp2_rdata_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp2_rid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp2_rresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp2_wacount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp2_wcount_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp3_bid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp3_bresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp3_racount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp3_rcount_UNCONNECTED;
  wire [127:0]NLW_inst_saxigp3_rdata_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp3_rid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp3_rresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp3_wacount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp3_wcount_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp4_bid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp4_bresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp4_racount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp4_rcount_UNCONNECTED;
  wire [127:0]NLW_inst_saxigp4_rdata_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp4_rid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp4_rresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp4_wacount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp4_wcount_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp5_bid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp5_bresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp5_racount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp5_rcount_UNCONNECTED;
  wire [127:0]NLW_inst_saxigp5_rdata_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp5_rid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp5_rresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp5_wacount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp5_wcount_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp6_bid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp6_bresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp6_racount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp6_rcount_UNCONNECTED;
  wire [127:0]NLW_inst_saxigp6_rdata_UNCONNECTED;
  wire [5:0]NLW_inst_saxigp6_rid_UNCONNECTED;
  wire [1:0]NLW_inst_saxigp6_rresp_UNCONNECTED;
  wire [3:0]NLW_inst_saxigp6_wacount_UNCONNECTED;
  wire [7:0]NLW_inst_saxigp6_wcount_UNCONNECTED;
  wire [19:0]NLW_inst_test_adc_out_UNCONNECTED;
  wire [7:0]NLW_inst_test_ams_osc_UNCONNECTED;
  wire [15:0]NLW_inst_test_db_UNCONNECTED;
  wire [15:0]NLW_inst_test_do_UNCONNECTED;
  wire [15:0]NLW_inst_test_mon_data_UNCONNECTED;
  wire [4:0]NLW_inst_test_pl_pll_lock_out_UNCONNECTED;
  wire [3:0]NLW_inst_test_pl_scan_edt_out_ddr_UNCONNECTED;
  wire [9:0]NLW_inst_test_pl_scan_edt_out_fp_UNCONNECTED;
  wire [3:0]NLW_inst_test_pl_scan_edt_out_gpu_UNCONNECTED;
  wire [8:0]NLW_inst_test_pl_scan_edt_out_lp_UNCONNECTED;
  wire [1:0]NLW_inst_test_pl_scan_edt_out_usb3_UNCONNECTED;
  wire [20:0]NLW_inst_tst_rtc_calibreg_out_UNCONNECTED;
  wire [3:0]NLW_inst_tst_rtc_osc_cntrl_out_UNCONNECTED;
  wire [31:0]NLW_inst_tst_rtc_sec_counter_out_UNCONNECTED;
  wire [15:0]NLW_inst_tst_rtc_tick_counter_out_UNCONNECTED;
  wire [31:0]NLW_inst_tst_rtc_timesetreg_out_UNCONNECTED;

  (* C_DP_USE_AUDIO = "0" *) 
  (* C_DP_USE_VIDEO = "0" *) 
  (* C_EMIO_GPIO_WIDTH = "1" *) 
  (* C_EN_EMIO_TRACE = "0" *) 
  (* C_EN_FIFO_ENET0 = "0" *) 
  (* C_EN_FIFO_ENET1 = "0" *) 
  (* C_EN_FIFO_ENET2 = "0" *) 
  (* C_EN_FIFO_ENET3 = "0" *) 
  (* C_MAXIGP0_DATA_WIDTH = "32" *) 
  (* C_MAXIGP1_DATA_WIDTH = "32" *) 
  (* C_MAXIGP2_DATA_WIDTH = "32" *) 
  (* C_NUM_F2P_0_INTR_INPUTS = "1" *) 
  (* C_NUM_F2P_1_INTR_INPUTS = "1" *) 
  (* C_NUM_FABRIC_RESETS = "1" *) 
  (* C_PL_CLK0_BUF = "TRUE" *) 
  (* C_PL_CLK1_BUF = "FALSE" *) 
  (* C_PL_CLK2_BUF = "FALSE" *) 
  (* C_PL_CLK3_BUF = "FALSE" *) 
  (* C_SAXIGP0_DATA_WIDTH = "64" *) 
  (* C_SAXIGP1_DATA_WIDTH = "128" *) 
  (* C_SAXIGP2_DATA_WIDTH = "128" *) 
  (* C_SAXIGP3_DATA_WIDTH = "128" *) 
  (* C_SAXIGP4_DATA_WIDTH = "128" *) 
  (* C_SAXIGP5_DATA_WIDTH = "128" *) 
  (* C_SAXIGP6_DATA_WIDTH = "128" *) 
  (* C_SD0_INTERNAL_BUS_WIDTH = "8" *) 
  (* C_SD1_INTERNAL_BUS_WIDTH = "8" *) 
  (* C_TRACE_DATA_WIDTH = "32" *) 
  (* C_TRACE_PIPELINE_WIDTH = "8" *) 
  (* C_USE_DEBUG_TEST = "0" *) 
  (* C_USE_DIFF_RW_CLK_GP0 = "0" *) 
  (* C_USE_DIFF_RW_CLK_GP1 = "0" *) 
  (* C_USE_DIFF_RW_CLK_GP2 = "0" *) 
  (* C_USE_DIFF_RW_CLK_GP3 = "0" *) 
  (* C_USE_DIFF_RW_CLK_GP4 = "0" *) 
  (* C_USE_DIFF_RW_CLK_GP5 = "0" *) 
  (* C_USE_DIFF_RW_CLK_GP6 = "0" *) 
  (* HW_HANDOFF = "zynqmpsoc_zynq_ultra_ps_e_0_0.hwdef" *) 
  (* PSS_IO = "Signal Name, DiffPair Type, DiffPair Signal,Direction, Site Type, IO Standard, Drive (mA), Slew Rate, Pull Type, IBIS Model, ODT, OUTPUT_IMPEDANCE \nQSPI_X4_SCLK_OUT, , , OUT, PS_MIO0_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MISO_MO1, , , INOUT, PS_MIO1_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO2, , , INOUT, PS_MIO2_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO3, , , INOUT, PS_MIO3_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MOSI_MI0, , , INOUT, PS_MIO4_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_N_SS_OUT, , , OUT, PS_MIO5_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_CLK_FOR_LPBK, , , OUT, PS_MIO6_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_N_SS_OUT_UPPER, , , OUT, PS_MIO7_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[0], , , INOUT, PS_MIO8_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[1], , , INOUT, PS_MIO9_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[2], , , INOUT, PS_MIO10_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_MO_UPPER[3], , , INOUT, PS_MIO11_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nQSPI_X4_SCLK_OUT_UPPER, , , OUT, PS_MIO12_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO0_GPIO0[13], , , INOUT, PS_MIO13_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C0_SCL_OUT, , , INOUT, PS_MIO14_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C0_SDA_OUT, , , INOUT, PS_MIO15_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C1_SCL_OUT, , , INOUT, PS_MIO16_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nI2C1_SDA_OUT, , , INOUT, PS_MIO17_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART0_RXD, , , IN, PS_MIO18_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART0_TXD, , , OUT, PS_MIO19_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART1_TXD, , , OUT, PS_MIO20_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUART1_RXD, , , IN, PS_MIO21_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO0_GPIO0[22], , , INOUT, PS_MIO22_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO0_GPIO0[23], , , INOUT, PS_MIO23_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nCAN1_PHY_TX, , , OUT, PS_MIO24_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nCAN1_PHY_RX, , , IN, PS_MIO25_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO1_GPIO1[26], , , INOUT, PS_MIO26_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_AUX_DATA_OUT, , , OUT, PS_MIO27_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_HOT_PLUG_DETECT, , , IN, PS_MIO28_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_AUX_DATA_OE, , , OUT, PS_MIO29_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nDPAUX_DP_AUX_DATA_IN, , , IN, PS_MIO30_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPCIE_ROOT_RESET_N, , , OUT, PS_MIO31_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[0], , , OUT, PS_MIO32_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[1], , , OUT, PS_MIO33_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[2], , , OUT, PS_MIO34_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[3], , , OUT, PS_MIO35_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[4], , , OUT, PS_MIO36_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPMU_GPO[5], , , OUT, PS_MIO37_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO1_GPIO1[38], , , INOUT, PS_MIO38_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[4], , , INOUT, PS_MIO39_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[5], , , INOUT, PS_MIO40_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[6], , , INOUT, PS_MIO41_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[7], , , INOUT, PS_MIO42_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGPIO1_GPIO1[43], , , INOUT, PS_MIO43_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_WP, , , IN, PS_MIO44_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_CD_N, , , IN, PS_MIO45_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[0], , , INOUT, PS_MIO46_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[1], , , INOUT, PS_MIO47_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[2], , , INOUT, PS_MIO48_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_DATA_OUT[3], , , INOUT, PS_MIO49_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_CMD_OUT, , , INOUT, PS_MIO50_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nSD1_SDIO1_CLK_OUT, , , OUT, PS_MIO51_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_CLK_IN, , , IN, PS_MIO52_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_DIR, , , IN, PS_MIO53_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[2], , , INOUT, PS_MIO54_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_NXT, , , IN, PS_MIO55_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[0], , , INOUT, PS_MIO56_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[1], , , INOUT, PS_MIO57_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_STP, , , OUT, PS_MIO58_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[3], , , INOUT, PS_MIO59_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[4], , , INOUT, PS_MIO60_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[5], , , INOUT, PS_MIO61_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[6], , , INOUT, PS_MIO62_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nUSB0_ULPI_TX_DATA[7], , , INOUT, PS_MIO63_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TX_CLK, , , OUT, PS_MIO64_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[0], , , OUT, PS_MIO65_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[1], , , OUT, PS_MIO66_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[2], , , OUT, PS_MIO67_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TXD[3], , , OUT, PS_MIO68_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_TX_CTL, , , OUT, PS_MIO69_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RX_CLK, , , IN, PS_MIO70_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[0], , , IN, PS_MIO71_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[1], , , IN, PS_MIO72_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[2], , , IN, PS_MIO73_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RXD[3], , , IN, PS_MIO74_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nGEM3_RGMII_RX_CTL, , , IN, PS_MIO75_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nMDIO3_GEM3_MDC, , , OUT, PS_MIO76_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nMDIO3_GEM3_MDIO_OUT, , , INOUT, PS_MIO77_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  \nPCIE_MGTREFCLK0N, , , IN, PS_MGTREFCLK0N_505, , , , , ,,  \nPCIE_MGTREFCLK0P, , , IN, PS_MGTREFCLK0P_505, , , , , ,,  \nPS_REF_CLK, , , IN, PS_REF_CLK_503, LVCMOS18, 2, SLOW, , PS_MIO_LVCMOS18_S_2,,  \nPS_JTAG_TCK, , , IN, PS_JTAG_TCK_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_JTAG_TDI, , , IN, PS_JTAG_TDI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_JTAG_TDO, , , OUT, PS_JTAG_TDO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_JTAG_TMS, , , IN, PS_JTAG_TMS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_DONE, , , OUT, PS_DONE_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_ERROR_OUT, , , OUT, PS_ERROR_OUT_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_ERROR_STATUS, , , OUT, PS_ERROR_STATUS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_INIT_B, , , INOUT, PS_INIT_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE0, , , IN, PS_MODE0_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE1, , , IN, PS_MODE1_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE2, , , IN, PS_MODE2_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_MODE3, , , IN, PS_MODE3_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_PADI, , , IN, PS_PADI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_PADO, , , OUT, PS_PADO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_POR_B, , , IN, PS_POR_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_PROG_B, , , IN, PS_PROG_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPS_SRST_B, , , IN, PS_SRST_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  \nPCIE_MGTRRXN0, , , IN, PS_MGTRRXN0_505, , , , , ,,  \nPCIE_MGTRRXP0, , , IN, PS_MGTRRXP0_505, , , , , ,,  \nPCIE_MGTRTXN0, , , OUT, PS_MGTRTXN0_505, , , , , ,,  \nPCIE_MGTRTXP0, , , OUT, PS_MGTRTXP0_505, , , , , ,,  \nSATA1_MGTREFCLK1N, , , IN, PS_MGTREFCLK1N_505, , , , , ,,  \nSATA1_MGTREFCLK1P, , , IN, PS_MGTREFCLK1P_505, , , , , ,,  \nDP0_MGTRRXN1, , , IN, PS_MGTRRXN1_505, , , , , ,,  \nDP0_MGTRRXP1, , , IN, PS_MGTRRXP1_505, , , , , ,,  \nDP0_MGTRTXN1, , , OUT, PS_MGTRTXN1_505, , , , , ,,  \nDP0_MGTRTXP1, , , OUT, PS_MGTRTXP1_505, , , , , ,,  \nUSB0_MGTREFCLK2N, , , IN, PS_MGTREFCLK2N_505, , , , , ,,  \nUSB0_MGTREFCLK2P, , , IN, PS_MGTREFCLK2P_505, , , , , ,,  \nUSB0_MGTRRXN2, , , IN, PS_MGTRRXN2_505, , , , , ,,  \nUSB0_MGTRRXP2, , , IN, PS_MGTRRXP2_505, , , , , ,,  \nUSB0_MGTRTXN2, , , OUT, PS_MGTRTXN2_505, , , , , ,,  \nUSB0_MGTRTXP2, , , OUT, PS_MGTRTXP2_505, , , , , ,,  \nDP0_MGTREFCLK3N, , , IN, PS_MGTREFCLK3N_505, , , , , ,,  \nDP0_MGTREFCLK3P, , , IN, PS_MGTREFCLK3P_505, , , , , ,,  \nSATA1_MGTRRXN3, , , IN, PS_MGTRRXN3_505, , , , , ,,  \nSATA1_MGTRRXP3, , , IN, PS_MGTRRXP3_505, , , , , ,,  \nSATA1_MGTRTXN3, , , OUT, PS_MGTRTXN3_505, , , , , ,,  \nSATA1_MGTRTXP3, , , OUT, PS_MGTRTXP3_505, , , , , ,, \n DDR4_RAM_RST_N, , , OUT, PS_DDR_RAM_RST_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ACT_N, , , OUT, PS_DDR_ACT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_PARITY, , , OUT, PS_DDR_PARITY_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ALERT_N, , , IN, PS_DDR_ALERT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_CK0, P, DDR4_CK_N0, OUT, PS_DDR_CK0_504, DDR4, , , ,PS_DDR4_CK_OUT34_P, RTT_NONE, 34\n DDR4_CK_N0, N, DDR4_CK0, OUT, PS_DDR_CK_N0_504, DDR4, , , ,PS_DDR4_CK_OUT34_N, RTT_NONE, 34\n DDR4_CKE0, , , OUT, PS_DDR_CKE0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_CS_N0, , , OUT, PS_DDR_CS_N0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ODT0, , , OUT, PS_DDR_ODT0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BG0, , , OUT, PS_DDR_BG0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BG1, , , OUT, PS_DDR_BG1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BA0, , , OUT, PS_DDR_BA0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_BA1, , , OUT, PS_DDR_BA1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_ZQ, , , INOUT, PS_DDR_ZQ_504, DDR4, , , ,, , \n DDR4_A0, , , OUT, PS_DDR_A0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A1, , , OUT, PS_DDR_A1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A2, , , OUT, PS_DDR_A2_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A3, , , OUT, PS_DDR_A3_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A4, , , OUT, PS_DDR_A4_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A5, , , OUT, PS_DDR_A5_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A6, , , OUT, PS_DDR_A6_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A7, , , OUT, PS_DDR_A7_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A8, , , OUT, PS_DDR_A8_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A9, , , OUT, PS_DDR_A9_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A10, , , OUT, PS_DDR_A10_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A11, , , OUT, PS_DDR_A11_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A12, , , OUT, PS_DDR_A12_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A13, , , OUT, PS_DDR_A13_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A14, , , OUT, PS_DDR_A14_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_A15, , , OUT, PS_DDR_A15_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34\n DDR4_DQS_P0, P, DDR4_DQS_N0, INOUT, PS_DDR_DQS_P0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P1, P, DDR4_DQS_N1, INOUT, PS_DDR_DQS_P1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P2, P, DDR4_DQS_N2, INOUT, PS_DDR_DQS_P2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P3, P, DDR4_DQS_N3, INOUT, PS_DDR_DQS_P3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P4, P, DDR4_DQS_N4, INOUT, PS_DDR_DQS_P4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P5, P, DDR4_DQS_N5, INOUT, PS_DDR_DQS_P5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P6, P, DDR4_DQS_N6, INOUT, PS_DDR_DQS_P6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_P7, P, DDR4_DQS_N7, INOUT, PS_DDR_DQS_P7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34\n DDR4_DQS_N0, N, DDR4_DQS_P0, INOUT, PS_DDR_DQS_N0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N1, N, DDR4_DQS_P1, INOUT, PS_DDR_DQS_N1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N2, N, DDR4_DQS_P2, INOUT, PS_DDR_DQS_N2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N3, N, DDR4_DQS_P3, INOUT, PS_DDR_DQS_N3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N4, N, DDR4_DQS_P4, INOUT, PS_DDR_DQS_N4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N5, N, DDR4_DQS_P5, INOUT, PS_DDR_DQS_N5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N6, N, DDR4_DQS_P6, INOUT, PS_DDR_DQS_N6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DQS_N7, N, DDR4_DQS_P7, INOUT, PS_DDR_DQS_N7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34\n DDR4_DM0, , , OUT, PS_DDR_DM0_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM1, , , OUT, PS_DDR_DM1_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM2, , , OUT, PS_DDR_DM2_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM3, , , OUT, PS_DDR_DM3_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM4, , , OUT, PS_DDR_DM4_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM5, , , OUT, PS_DDR_DM5_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM6, , , OUT, PS_DDR_DM6_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DM7, , , OUT, PS_DDR_DM7_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34\n DDR4_DQ0, , , INOUT, PS_DDR_DQ0_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ1, , , INOUT, PS_DDR_DQ1_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ2, , , INOUT, PS_DDR_DQ2_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ3, , , INOUT, PS_DDR_DQ3_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ4, , , INOUT, PS_DDR_DQ4_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ5, , , INOUT, PS_DDR_DQ5_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ6, , , INOUT, PS_DDR_DQ6_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ7, , , INOUT, PS_DDR_DQ7_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ8, , , INOUT, PS_DDR_DQ8_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ9, , , INOUT, PS_DDR_DQ9_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ10, , , INOUT, PS_DDR_DQ10_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ11, , , INOUT, PS_DDR_DQ11_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ12, , , INOUT, PS_DDR_DQ12_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ13, , , INOUT, PS_DDR_DQ13_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ14, , , INOUT, PS_DDR_DQ14_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ15, , , INOUT, PS_DDR_DQ15_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ16, , , INOUT, PS_DDR_DQ16_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ17, , , INOUT, PS_DDR_DQ17_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ18, , , INOUT, PS_DDR_DQ18_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ19, , , INOUT, PS_DDR_DQ19_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ20, , , INOUT, PS_DDR_DQ20_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ21, , , INOUT, PS_DDR_DQ21_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ22, , , INOUT, PS_DDR_DQ22_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ23, , , INOUT, PS_DDR_DQ23_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ24, , , INOUT, PS_DDR_DQ24_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ25, , , INOUT, PS_DDR_DQ25_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ26, , , INOUT, PS_DDR_DQ26_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ27, , , INOUT, PS_DDR_DQ27_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ28, , , INOUT, PS_DDR_DQ28_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ29, , , INOUT, PS_DDR_DQ29_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ30, , , INOUT, PS_DDR_DQ30_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ31, , , INOUT, PS_DDR_DQ31_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ32, , , INOUT, PS_DDR_DQ32_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ33, , , INOUT, PS_DDR_DQ33_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ34, , , INOUT, PS_DDR_DQ34_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ35, , , INOUT, PS_DDR_DQ35_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ36, , , INOUT, PS_DDR_DQ36_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ37, , , INOUT, PS_DDR_DQ37_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ38, , , INOUT, PS_DDR_DQ38_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ39, , , INOUT, PS_DDR_DQ39_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ40, , , INOUT, PS_DDR_DQ40_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ41, , , INOUT, PS_DDR_DQ41_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ42, , , INOUT, PS_DDR_DQ42_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ43, , , INOUT, PS_DDR_DQ43_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ44, , , INOUT, PS_DDR_DQ44_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ45, , , INOUT, PS_DDR_DQ45_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ46, , , INOUT, PS_DDR_DQ46_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ47, , , INOUT, PS_DDR_DQ47_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ48, , , INOUT, PS_DDR_DQ48_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ49, , , INOUT, PS_DDR_DQ49_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ50, , , INOUT, PS_DDR_DQ50_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ51, , , INOUT, PS_DDR_DQ51_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ52, , , INOUT, PS_DDR_DQ52_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ53, , , INOUT, PS_DDR_DQ53_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ54, , , INOUT, PS_DDR_DQ54_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ55, , , INOUT, PS_DDR_DQ55_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ56, , , INOUT, PS_DDR_DQ56_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ57, , , INOUT, PS_DDR_DQ57_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ58, , , INOUT, PS_DDR_DQ58_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ59, , , INOUT, PS_DDR_DQ59_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ60, , , INOUT, PS_DDR_DQ60_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ61, , , INOUT, PS_DDR_DQ61_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ62, , , INOUT, PS_DDR_DQ62_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34\n DDR4_DQ63, , , INOUT, PS_DDR_DQ63_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" *) 
  (* PSS_JITTER = "<PSS_EXTERNAL_CLOCKS><EXTERNAL_CLOCK name={PLCLK[0]} clock_external_divide={20} vco_name={IOPLL} vco_freq={3000.000} vco_internal_divide={2}/></PSS_EXTERNAL_CLOCKS>" *) 
  (* PSS_POWER = "<BLOCKTYPE name={PS8}> <PS8><FPD><PROCESSSORS><PROCESSOR name={Cortex A-53} numCores={4} L2Cache={Enable} clockFreq={1200.000000} load={0.5}/><PROCESSOR name={GPU Mali-400 MP} numCores={2} clockFreq={500.000000} load={0.5} /></PROCESSSORS><PLLS><PLL domain={APU} vco={2399.976} /><PLL domain={DDR} vco={2099.979} /><PLL domain={Video} vco={2999.970} /></PLLS><MEMORY memType={DDR4} dataWidth={8} clockFreq={1050.000} readRate={0.5} writeRate={0.5} cmdAddressActivity={0.5} /><SERDES><GT name={PCIe} standard={Gen2} lanes={1} usageRate={0.5} /><GT name={SATA} standard={SATA3} lanes={1} usageRate={0.5} /><GT name={Display Port} standard={SVGA-60 (800x600)} lanes={1} usageRate={0.5} />clockFreq={60} /><GT name={USB3} standard={USB3.0} lanes={1}usageRate={0.5} /><GT name={SGMII} standard={SGMII} lanes={0} usageRate={0.5} /></SERDES><AFI master={2} slave={1} clockFreq={75.000} usageRate={0.5} /><FPINTERCONNECT clockFreq={667} Bandwidth={Low} /></FPD><LPD><PROCESSSORS><PROCESSOR name={Cortex R-5} usage={Enable} TCM={Enable} OCM={Enable} clockFreq={500.000000} load={0.5}/></PROCESSSORS><PLLS><PLL domain={IO} vco={2999.970} /><PLL domain={RPLL} vco={1499.985} /></PLLS><CSUPMU><Unit name={CSU} usageRate={0.5} clockFreq={180} /><Unit name={PMU} usageRate={0.5} clockFreq={180} /></CSUPMU><GPIO><Bank ioBank={VCC_PSIO0} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO1} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO2} number={0} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO3} number={16} io_standard={LVCMOS 1.8V} /></GPIO><IOINTERFACES> <IO name={QSPI} io_standard={} ioBank={VCC_PSIO0} clockFreq={125.000000} inputs={0} outputs={5} inouts={8} usageRate={0.5}/><IO name={NAND 3.1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={USB0} io_standard={} ioBank={VCC_PSIO2} clockFreq={250.000000} inputs={3} outputs={1} inouts={8} usageRate={0.5}/><IO name={USB1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth3} io_standard={} ioBank={VCC_PSIO2} clockFreq={125.000000} inputs={6} outputs={6} inouts={0} usageRate={0.5}/><IO name={GPIO 0} io_standard={} ioBank={VCC_PSIO0} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 1} io_standard={} ioBank={VCC_PSIO1} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GPIO 3} io_standard={} ioBank={VCC_PSIO3} clockFreq={1} inputs={} outputs={} inouts={16} usageRate={0.5}/><IO name={UART0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={UART1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={I2C0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={I2C1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={SPI0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SPI1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={SD0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SD1} io_standard={} ioBank={VCC_PSIO1} clockFreq={187.500000} inputs={2} outputs={1} inouts={9} usageRate={0.5}/><IO name={Trace} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={TTC0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC2} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC3} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={PJTAG} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={DPAUX} io_standard={} ioBank={VCC_PSIO1} clockFreq={} inputs={2} outputs={2} inouts={0} usageRate={0.5}/><IO name={WDT0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={WDT1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/></IOINTERFACES><AFI master={0} slave={0} clockFreq={333.333} usageRate={0.5} /><LPINTERCONNECT clockFreq={667} Bandwidth={High} /></LPD></PS8></BLOCKTYPE>/>" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e inst
       (.adma2pl_cack(NLW_inst_adma2pl_cack_UNCONNECTED[7:0]),
        .adma2pl_tvld(NLW_inst_adma2pl_tvld_UNCONNECTED[7:0]),
        .adma_fci_clk({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .aib_pmu_afifm_fpd_ack(1'b0),
        .aib_pmu_afifm_lpd_ack(1'b0),
        .dbg_path_fifo_bypass(NLW_inst_dbg_path_fifo_bypass_UNCONNECTED),
        .ddrc_ext_refresh_rank0_req(1'b0),
        .ddrc_ext_refresh_rank1_req(1'b0),
        .ddrc_refresh_pl_clk(1'b0),
        .dp_audio_ref_clk(NLW_inst_dp_audio_ref_clk_UNCONNECTED),
        .dp_aux_data_in(1'b0),
        .dp_aux_data_oe_n(NLW_inst_dp_aux_data_oe_n_UNCONNECTED),
        .dp_aux_data_out(NLW_inst_dp_aux_data_out_UNCONNECTED),
        .dp_external_custom_event1(1'b0),
        .dp_external_custom_event2(1'b0),
        .dp_external_vsync_event(1'b0),
        .dp_hot_plug_detect(1'b0),
        .dp_live_gfx_alpha_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dp_live_gfx_pixel1_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dp_live_video_de_out(NLW_inst_dp_live_video_de_out_UNCONNECTED),
        .dp_live_video_in_de(1'b0),
        .dp_live_video_in_hsync(1'b0),
        .dp_live_video_in_pixel1({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dp_live_video_in_vsync(1'b0),
        .dp_m_axis_mixed_audio_tdata(NLW_inst_dp_m_axis_mixed_audio_tdata_UNCONNECTED[31:0]),
        .dp_m_axis_mixed_audio_tid(NLW_inst_dp_m_axis_mixed_audio_tid_UNCONNECTED),
        .dp_m_axis_mixed_audio_tready(1'b0),
        .dp_m_axis_mixed_audio_tvalid(NLW_inst_dp_m_axis_mixed_audio_tvalid_UNCONNECTED),
        .dp_s_axis_audio_clk(1'b0),
        .dp_s_axis_audio_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dp_s_axis_audio_tid(1'b0),
        .dp_s_axis_audio_tready(NLW_inst_dp_s_axis_audio_tready_UNCONNECTED),
        .dp_s_axis_audio_tvalid(1'b0),
        .dp_video_in_clk(1'b0),
        .dp_video_out_hsync(NLW_inst_dp_video_out_hsync_UNCONNECTED),
        .dp_video_out_pixel1(NLW_inst_dp_video_out_pixel1_UNCONNECTED[35:0]),
        .dp_video_out_vsync(NLW_inst_dp_video_out_vsync_UNCONNECTED),
        .dp_video_ref_clk(NLW_inst_dp_video_ref_clk_UNCONNECTED),
        .emio_can0_phy_rx(1'b0),
        .emio_can0_phy_tx(NLW_inst_emio_can0_phy_tx_UNCONNECTED),
        .emio_can1_phy_rx(1'b0),
        .emio_can1_phy_tx(NLW_inst_emio_can1_phy_tx_UNCONNECTED),
        .emio_enet0_delay_req_rx(NLW_inst_emio_enet0_delay_req_rx_UNCONNECTED),
        .emio_enet0_delay_req_tx(NLW_inst_emio_enet0_delay_req_tx_UNCONNECTED),
        .emio_enet0_dma_bus_width(NLW_inst_emio_enet0_dma_bus_width_UNCONNECTED[1:0]),
        .emio_enet0_dma_tx_end_tog(NLW_inst_emio_enet0_dma_tx_end_tog_UNCONNECTED),
        .emio_enet0_dma_tx_status_tog(1'b0),
        .emio_enet0_enet_tsu_timer_cnt(NLW_inst_emio_enet0_enet_tsu_timer_cnt_UNCONNECTED[93:0]),
        .emio_enet0_ext_int_in(1'b0),
        .emio_enet0_gmii_col(1'b0),
        .emio_enet0_gmii_crs(1'b0),
        .emio_enet0_gmii_rx_clk(1'b0),
        .emio_enet0_gmii_rx_dv(1'b0),
        .emio_enet0_gmii_rx_er(1'b0),
        .emio_enet0_gmii_rxd({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet0_gmii_tx_clk(1'b0),
        .emio_enet0_gmii_tx_en(NLW_inst_emio_enet0_gmii_tx_en_UNCONNECTED),
        .emio_enet0_gmii_tx_er(NLW_inst_emio_enet0_gmii_tx_er_UNCONNECTED),
        .emio_enet0_gmii_txd(NLW_inst_emio_enet0_gmii_txd_UNCONNECTED[7:0]),
        .emio_enet0_mdio_i(1'b0),
        .emio_enet0_mdio_mdc(NLW_inst_emio_enet0_mdio_mdc_UNCONNECTED),
        .emio_enet0_mdio_o(NLW_inst_emio_enet0_mdio_o_UNCONNECTED),
        .emio_enet0_mdio_t(NLW_inst_emio_enet0_mdio_t_UNCONNECTED),
        .emio_enet0_mdio_t_n(NLW_inst_emio_enet0_mdio_t_n_UNCONNECTED),
        .emio_enet0_pdelay_req_rx(NLW_inst_emio_enet0_pdelay_req_rx_UNCONNECTED),
        .emio_enet0_pdelay_req_tx(NLW_inst_emio_enet0_pdelay_req_tx_UNCONNECTED),
        .emio_enet0_pdelay_resp_rx(NLW_inst_emio_enet0_pdelay_resp_rx_UNCONNECTED),
        .emio_enet0_pdelay_resp_tx(NLW_inst_emio_enet0_pdelay_resp_tx_UNCONNECTED),
        .emio_enet0_rx_sof(NLW_inst_emio_enet0_rx_sof_UNCONNECTED),
        .emio_enet0_rx_w_data(NLW_inst_emio_enet0_rx_w_data_UNCONNECTED[7:0]),
        .emio_enet0_rx_w_eop(NLW_inst_emio_enet0_rx_w_eop_UNCONNECTED),
        .emio_enet0_rx_w_err(NLW_inst_emio_enet0_rx_w_err_UNCONNECTED),
        .emio_enet0_rx_w_flush(NLW_inst_emio_enet0_rx_w_flush_UNCONNECTED),
        .emio_enet0_rx_w_overflow(1'b0),
        .emio_enet0_rx_w_sop(NLW_inst_emio_enet0_rx_w_sop_UNCONNECTED),
        .emio_enet0_rx_w_status(NLW_inst_emio_enet0_rx_w_status_UNCONNECTED[44:0]),
        .emio_enet0_rx_w_wr(NLW_inst_emio_enet0_rx_w_wr_UNCONNECTED),
        .emio_enet0_signal_detect(1'b0),
        .emio_enet0_speed_mode(NLW_inst_emio_enet0_speed_mode_UNCONNECTED[2:0]),
        .emio_enet0_sync_frame_rx(NLW_inst_emio_enet0_sync_frame_rx_UNCONNECTED),
        .emio_enet0_sync_frame_tx(NLW_inst_emio_enet0_sync_frame_tx_UNCONNECTED),
        .emio_enet0_tsu_inc_ctrl({1'b0,1'b0}),
        .emio_enet0_tsu_timer_cmp_val(NLW_inst_emio_enet0_tsu_timer_cmp_val_UNCONNECTED),
        .emio_enet0_tx_r_control(1'b0),
        .emio_enet0_tx_r_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet0_tx_r_data_rdy(1'b0),
        .emio_enet0_tx_r_eop(1'b1),
        .emio_enet0_tx_r_err(1'b0),
        .emio_enet0_tx_r_fixed_lat(NLW_inst_emio_enet0_tx_r_fixed_lat_UNCONNECTED),
        .emio_enet0_tx_r_flushed(1'b0),
        .emio_enet0_tx_r_rd(NLW_inst_emio_enet0_tx_r_rd_UNCONNECTED),
        .emio_enet0_tx_r_sop(1'b1),
        .emio_enet0_tx_r_status(NLW_inst_emio_enet0_tx_r_status_UNCONNECTED[3:0]),
        .emio_enet0_tx_r_underflow(1'b0),
        .emio_enet0_tx_r_valid(1'b0),
        .emio_enet0_tx_sof(NLW_inst_emio_enet0_tx_sof_UNCONNECTED),
        .emio_enet1_delay_req_rx(NLW_inst_emio_enet1_delay_req_rx_UNCONNECTED),
        .emio_enet1_delay_req_tx(NLW_inst_emio_enet1_delay_req_tx_UNCONNECTED),
        .emio_enet1_dma_bus_width(NLW_inst_emio_enet1_dma_bus_width_UNCONNECTED[1:0]),
        .emio_enet1_dma_tx_end_tog(NLW_inst_emio_enet1_dma_tx_end_tog_UNCONNECTED),
        .emio_enet1_dma_tx_status_tog(1'b0),
        .emio_enet1_ext_int_in(1'b0),
        .emio_enet1_gmii_col(1'b0),
        .emio_enet1_gmii_crs(1'b0),
        .emio_enet1_gmii_rx_clk(1'b0),
        .emio_enet1_gmii_rx_dv(1'b0),
        .emio_enet1_gmii_rx_er(1'b0),
        .emio_enet1_gmii_rxd({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet1_gmii_tx_clk(1'b0),
        .emio_enet1_gmii_tx_en(NLW_inst_emio_enet1_gmii_tx_en_UNCONNECTED),
        .emio_enet1_gmii_tx_er(NLW_inst_emio_enet1_gmii_tx_er_UNCONNECTED),
        .emio_enet1_gmii_txd(NLW_inst_emio_enet1_gmii_txd_UNCONNECTED[7:0]),
        .emio_enet1_mdio_i(1'b0),
        .emio_enet1_mdio_mdc(NLW_inst_emio_enet1_mdio_mdc_UNCONNECTED),
        .emio_enet1_mdio_o(NLW_inst_emio_enet1_mdio_o_UNCONNECTED),
        .emio_enet1_mdio_t(NLW_inst_emio_enet1_mdio_t_UNCONNECTED),
        .emio_enet1_mdio_t_n(NLW_inst_emio_enet1_mdio_t_n_UNCONNECTED),
        .emio_enet1_pdelay_req_rx(NLW_inst_emio_enet1_pdelay_req_rx_UNCONNECTED),
        .emio_enet1_pdelay_req_tx(NLW_inst_emio_enet1_pdelay_req_tx_UNCONNECTED),
        .emio_enet1_pdelay_resp_rx(NLW_inst_emio_enet1_pdelay_resp_rx_UNCONNECTED),
        .emio_enet1_pdelay_resp_tx(NLW_inst_emio_enet1_pdelay_resp_tx_UNCONNECTED),
        .emio_enet1_rx_sof(NLW_inst_emio_enet1_rx_sof_UNCONNECTED),
        .emio_enet1_rx_w_data(NLW_inst_emio_enet1_rx_w_data_UNCONNECTED[7:0]),
        .emio_enet1_rx_w_eop(NLW_inst_emio_enet1_rx_w_eop_UNCONNECTED),
        .emio_enet1_rx_w_err(NLW_inst_emio_enet1_rx_w_err_UNCONNECTED),
        .emio_enet1_rx_w_flush(NLW_inst_emio_enet1_rx_w_flush_UNCONNECTED),
        .emio_enet1_rx_w_overflow(1'b0),
        .emio_enet1_rx_w_sop(NLW_inst_emio_enet1_rx_w_sop_UNCONNECTED),
        .emio_enet1_rx_w_status(NLW_inst_emio_enet1_rx_w_status_UNCONNECTED[44:0]),
        .emio_enet1_rx_w_wr(NLW_inst_emio_enet1_rx_w_wr_UNCONNECTED),
        .emio_enet1_signal_detect(1'b0),
        .emio_enet1_speed_mode(NLW_inst_emio_enet1_speed_mode_UNCONNECTED[2:0]),
        .emio_enet1_sync_frame_rx(NLW_inst_emio_enet1_sync_frame_rx_UNCONNECTED),
        .emio_enet1_sync_frame_tx(NLW_inst_emio_enet1_sync_frame_tx_UNCONNECTED),
        .emio_enet1_tsu_inc_ctrl({1'b0,1'b0}),
        .emio_enet1_tsu_timer_cmp_val(NLW_inst_emio_enet1_tsu_timer_cmp_val_UNCONNECTED),
        .emio_enet1_tx_r_control(1'b0),
        .emio_enet1_tx_r_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet1_tx_r_data_rdy(1'b0),
        .emio_enet1_tx_r_eop(1'b1),
        .emio_enet1_tx_r_err(1'b0),
        .emio_enet1_tx_r_fixed_lat(NLW_inst_emio_enet1_tx_r_fixed_lat_UNCONNECTED),
        .emio_enet1_tx_r_flushed(1'b0),
        .emio_enet1_tx_r_rd(NLW_inst_emio_enet1_tx_r_rd_UNCONNECTED),
        .emio_enet1_tx_r_sop(1'b1),
        .emio_enet1_tx_r_status(NLW_inst_emio_enet1_tx_r_status_UNCONNECTED[3:0]),
        .emio_enet1_tx_r_underflow(1'b0),
        .emio_enet1_tx_r_valid(1'b0),
        .emio_enet1_tx_sof(NLW_inst_emio_enet1_tx_sof_UNCONNECTED),
        .emio_enet2_delay_req_rx(NLW_inst_emio_enet2_delay_req_rx_UNCONNECTED),
        .emio_enet2_delay_req_tx(NLW_inst_emio_enet2_delay_req_tx_UNCONNECTED),
        .emio_enet2_dma_bus_width(NLW_inst_emio_enet2_dma_bus_width_UNCONNECTED[1:0]),
        .emio_enet2_dma_tx_end_tog(NLW_inst_emio_enet2_dma_tx_end_tog_UNCONNECTED),
        .emio_enet2_dma_tx_status_tog(1'b0),
        .emio_enet2_ext_int_in(1'b0),
        .emio_enet2_gmii_col(1'b0),
        .emio_enet2_gmii_crs(1'b0),
        .emio_enet2_gmii_rx_clk(1'b0),
        .emio_enet2_gmii_rx_dv(1'b0),
        .emio_enet2_gmii_rx_er(1'b0),
        .emio_enet2_gmii_rxd({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet2_gmii_tx_clk(1'b0),
        .emio_enet2_gmii_tx_en(NLW_inst_emio_enet2_gmii_tx_en_UNCONNECTED),
        .emio_enet2_gmii_tx_er(NLW_inst_emio_enet2_gmii_tx_er_UNCONNECTED),
        .emio_enet2_gmii_txd(NLW_inst_emio_enet2_gmii_txd_UNCONNECTED[7:0]),
        .emio_enet2_mdio_i(1'b0),
        .emio_enet2_mdio_mdc(NLW_inst_emio_enet2_mdio_mdc_UNCONNECTED),
        .emio_enet2_mdio_o(NLW_inst_emio_enet2_mdio_o_UNCONNECTED),
        .emio_enet2_mdio_t(NLW_inst_emio_enet2_mdio_t_UNCONNECTED),
        .emio_enet2_mdio_t_n(NLW_inst_emio_enet2_mdio_t_n_UNCONNECTED),
        .emio_enet2_pdelay_req_rx(NLW_inst_emio_enet2_pdelay_req_rx_UNCONNECTED),
        .emio_enet2_pdelay_req_tx(NLW_inst_emio_enet2_pdelay_req_tx_UNCONNECTED),
        .emio_enet2_pdelay_resp_rx(NLW_inst_emio_enet2_pdelay_resp_rx_UNCONNECTED),
        .emio_enet2_pdelay_resp_tx(NLW_inst_emio_enet2_pdelay_resp_tx_UNCONNECTED),
        .emio_enet2_rx_sof(NLW_inst_emio_enet2_rx_sof_UNCONNECTED),
        .emio_enet2_rx_w_data(NLW_inst_emio_enet2_rx_w_data_UNCONNECTED[7:0]),
        .emio_enet2_rx_w_eop(NLW_inst_emio_enet2_rx_w_eop_UNCONNECTED),
        .emio_enet2_rx_w_err(NLW_inst_emio_enet2_rx_w_err_UNCONNECTED),
        .emio_enet2_rx_w_flush(NLW_inst_emio_enet2_rx_w_flush_UNCONNECTED),
        .emio_enet2_rx_w_overflow(1'b0),
        .emio_enet2_rx_w_sop(NLW_inst_emio_enet2_rx_w_sop_UNCONNECTED),
        .emio_enet2_rx_w_status(NLW_inst_emio_enet2_rx_w_status_UNCONNECTED[44:0]),
        .emio_enet2_rx_w_wr(NLW_inst_emio_enet2_rx_w_wr_UNCONNECTED),
        .emio_enet2_signal_detect(1'b0),
        .emio_enet2_speed_mode(NLW_inst_emio_enet2_speed_mode_UNCONNECTED[2:0]),
        .emio_enet2_sync_frame_rx(NLW_inst_emio_enet2_sync_frame_rx_UNCONNECTED),
        .emio_enet2_sync_frame_tx(NLW_inst_emio_enet2_sync_frame_tx_UNCONNECTED),
        .emio_enet2_tsu_inc_ctrl({1'b0,1'b0}),
        .emio_enet2_tsu_timer_cmp_val(NLW_inst_emio_enet2_tsu_timer_cmp_val_UNCONNECTED),
        .emio_enet2_tx_r_control(1'b0),
        .emio_enet2_tx_r_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet2_tx_r_data_rdy(1'b0),
        .emio_enet2_tx_r_eop(1'b1),
        .emio_enet2_tx_r_err(1'b0),
        .emio_enet2_tx_r_fixed_lat(NLW_inst_emio_enet2_tx_r_fixed_lat_UNCONNECTED),
        .emio_enet2_tx_r_flushed(1'b0),
        .emio_enet2_tx_r_rd(NLW_inst_emio_enet2_tx_r_rd_UNCONNECTED),
        .emio_enet2_tx_r_sop(1'b1),
        .emio_enet2_tx_r_status(NLW_inst_emio_enet2_tx_r_status_UNCONNECTED[3:0]),
        .emio_enet2_tx_r_underflow(1'b0),
        .emio_enet2_tx_r_valid(1'b0),
        .emio_enet2_tx_sof(NLW_inst_emio_enet2_tx_sof_UNCONNECTED),
        .emio_enet3_delay_req_rx(NLW_inst_emio_enet3_delay_req_rx_UNCONNECTED),
        .emio_enet3_delay_req_tx(NLW_inst_emio_enet3_delay_req_tx_UNCONNECTED),
        .emio_enet3_dma_bus_width(NLW_inst_emio_enet3_dma_bus_width_UNCONNECTED[1:0]),
        .emio_enet3_dma_tx_end_tog(NLW_inst_emio_enet3_dma_tx_end_tog_UNCONNECTED),
        .emio_enet3_dma_tx_status_tog(1'b0),
        .emio_enet3_ext_int_in(1'b0),
        .emio_enet3_gmii_col(1'b0),
        .emio_enet3_gmii_crs(1'b0),
        .emio_enet3_gmii_rx_clk(1'b0),
        .emio_enet3_gmii_rx_dv(1'b0),
        .emio_enet3_gmii_rx_er(1'b0),
        .emio_enet3_gmii_rxd({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet3_gmii_tx_clk(1'b0),
        .emio_enet3_gmii_tx_en(NLW_inst_emio_enet3_gmii_tx_en_UNCONNECTED),
        .emio_enet3_gmii_tx_er(NLW_inst_emio_enet3_gmii_tx_er_UNCONNECTED),
        .emio_enet3_gmii_txd(NLW_inst_emio_enet3_gmii_txd_UNCONNECTED[7:0]),
        .emio_enet3_mdio_i(1'b0),
        .emio_enet3_mdio_mdc(NLW_inst_emio_enet3_mdio_mdc_UNCONNECTED),
        .emio_enet3_mdio_o(NLW_inst_emio_enet3_mdio_o_UNCONNECTED),
        .emio_enet3_mdio_t(NLW_inst_emio_enet3_mdio_t_UNCONNECTED),
        .emio_enet3_mdio_t_n(NLW_inst_emio_enet3_mdio_t_n_UNCONNECTED),
        .emio_enet3_pdelay_req_rx(NLW_inst_emio_enet3_pdelay_req_rx_UNCONNECTED),
        .emio_enet3_pdelay_req_tx(NLW_inst_emio_enet3_pdelay_req_tx_UNCONNECTED),
        .emio_enet3_pdelay_resp_rx(NLW_inst_emio_enet3_pdelay_resp_rx_UNCONNECTED),
        .emio_enet3_pdelay_resp_tx(NLW_inst_emio_enet3_pdelay_resp_tx_UNCONNECTED),
        .emio_enet3_rx_sof(NLW_inst_emio_enet3_rx_sof_UNCONNECTED),
        .emio_enet3_rx_w_data(NLW_inst_emio_enet3_rx_w_data_UNCONNECTED[7:0]),
        .emio_enet3_rx_w_eop(NLW_inst_emio_enet3_rx_w_eop_UNCONNECTED),
        .emio_enet3_rx_w_err(NLW_inst_emio_enet3_rx_w_err_UNCONNECTED),
        .emio_enet3_rx_w_flush(NLW_inst_emio_enet3_rx_w_flush_UNCONNECTED),
        .emio_enet3_rx_w_overflow(1'b0),
        .emio_enet3_rx_w_sop(NLW_inst_emio_enet3_rx_w_sop_UNCONNECTED),
        .emio_enet3_rx_w_status(NLW_inst_emio_enet3_rx_w_status_UNCONNECTED[44:0]),
        .emio_enet3_rx_w_wr(NLW_inst_emio_enet3_rx_w_wr_UNCONNECTED),
        .emio_enet3_signal_detect(1'b0),
        .emio_enet3_speed_mode(NLW_inst_emio_enet3_speed_mode_UNCONNECTED[2:0]),
        .emio_enet3_sync_frame_rx(NLW_inst_emio_enet3_sync_frame_rx_UNCONNECTED),
        .emio_enet3_sync_frame_tx(NLW_inst_emio_enet3_sync_frame_tx_UNCONNECTED),
        .emio_enet3_tsu_inc_ctrl({1'b0,1'b0}),
        .emio_enet3_tsu_timer_cmp_val(NLW_inst_emio_enet3_tsu_timer_cmp_val_UNCONNECTED),
        .emio_enet3_tx_r_control(1'b0),
        .emio_enet3_tx_r_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_enet3_tx_r_data_rdy(1'b0),
        .emio_enet3_tx_r_eop(1'b1),
        .emio_enet3_tx_r_err(1'b0),
        .emio_enet3_tx_r_fixed_lat(NLW_inst_emio_enet3_tx_r_fixed_lat_UNCONNECTED),
        .emio_enet3_tx_r_flushed(1'b0),
        .emio_enet3_tx_r_rd(NLW_inst_emio_enet3_tx_r_rd_UNCONNECTED),
        .emio_enet3_tx_r_sop(1'b1),
        .emio_enet3_tx_r_status(NLW_inst_emio_enet3_tx_r_status_UNCONNECTED[3:0]),
        .emio_enet3_tx_r_underflow(1'b0),
        .emio_enet3_tx_r_valid(1'b0),
        .emio_enet3_tx_sof(NLW_inst_emio_enet3_tx_sof_UNCONNECTED),
        .emio_enet_tsu_clk(1'b0),
        .emio_gpio_i(1'b0),
        .emio_gpio_o(NLW_inst_emio_gpio_o_UNCONNECTED[0]),
        .emio_gpio_t(NLW_inst_emio_gpio_t_UNCONNECTED[0]),
        .emio_gpio_t_n(NLW_inst_emio_gpio_t_n_UNCONNECTED[0]),
        .emio_hub_port_overcrnt_usb2_0(1'b0),
        .emio_hub_port_overcrnt_usb2_1(1'b0),
        .emio_hub_port_overcrnt_usb3_0(1'b0),
        .emio_hub_port_overcrnt_usb3_1(1'b0),
        .emio_i2c0_scl_i(1'b0),
        .emio_i2c0_scl_o(NLW_inst_emio_i2c0_scl_o_UNCONNECTED),
        .emio_i2c0_scl_t(NLW_inst_emio_i2c0_scl_t_UNCONNECTED),
        .emio_i2c0_scl_t_n(NLW_inst_emio_i2c0_scl_t_n_UNCONNECTED),
        .emio_i2c0_sda_i(1'b0),
        .emio_i2c0_sda_o(NLW_inst_emio_i2c0_sda_o_UNCONNECTED),
        .emio_i2c0_sda_t(NLW_inst_emio_i2c0_sda_t_UNCONNECTED),
        .emio_i2c0_sda_t_n(NLW_inst_emio_i2c0_sda_t_n_UNCONNECTED),
        .emio_i2c1_scl_i(1'b0),
        .emio_i2c1_scl_o(NLW_inst_emio_i2c1_scl_o_UNCONNECTED),
        .emio_i2c1_scl_t(NLW_inst_emio_i2c1_scl_t_UNCONNECTED),
        .emio_i2c1_scl_t_n(NLW_inst_emio_i2c1_scl_t_n_UNCONNECTED),
        .emio_i2c1_sda_i(1'b0),
        .emio_i2c1_sda_o(NLW_inst_emio_i2c1_sda_o_UNCONNECTED),
        .emio_i2c1_sda_t(NLW_inst_emio_i2c1_sda_t_UNCONNECTED),
        .emio_i2c1_sda_t_n(NLW_inst_emio_i2c1_sda_t_n_UNCONNECTED),
        .emio_sdio0_bus_volt(NLW_inst_emio_sdio0_bus_volt_UNCONNECTED[2:0]),
        .emio_sdio0_buspower(NLW_inst_emio_sdio0_buspower_UNCONNECTED),
        .emio_sdio0_cd_n(1'b0),
        .emio_sdio0_clkout(NLW_inst_emio_sdio0_clkout_UNCONNECTED),
        .emio_sdio0_cmdena(NLW_inst_emio_sdio0_cmdena_UNCONNECTED),
        .emio_sdio0_cmdin(1'b0),
        .emio_sdio0_cmdout(NLW_inst_emio_sdio0_cmdout_UNCONNECTED),
        .emio_sdio0_dataena(NLW_inst_emio_sdio0_dataena_UNCONNECTED[7:0]),
        .emio_sdio0_datain({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_sdio0_dataout(NLW_inst_emio_sdio0_dataout_UNCONNECTED[7:0]),
        .emio_sdio0_fb_clk_in(1'b0),
        .emio_sdio0_ledcontrol(NLW_inst_emio_sdio0_ledcontrol_UNCONNECTED),
        .emio_sdio0_wp(1'b1),
        .emio_sdio1_bus_volt(NLW_inst_emio_sdio1_bus_volt_UNCONNECTED[2:0]),
        .emio_sdio1_buspower(NLW_inst_emio_sdio1_buspower_UNCONNECTED),
        .emio_sdio1_cd_n(1'b0),
        .emio_sdio1_clkout(NLW_inst_emio_sdio1_clkout_UNCONNECTED),
        .emio_sdio1_cmdena(NLW_inst_emio_sdio1_cmdena_UNCONNECTED),
        .emio_sdio1_cmdin(1'b0),
        .emio_sdio1_cmdout(NLW_inst_emio_sdio1_cmdout_UNCONNECTED),
        .emio_sdio1_dataena(NLW_inst_emio_sdio1_dataena_UNCONNECTED[7:0]),
        .emio_sdio1_datain({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .emio_sdio1_dataout(NLW_inst_emio_sdio1_dataout_UNCONNECTED[7:0]),
        .emio_sdio1_fb_clk_in(1'b0),
        .emio_sdio1_ledcontrol(NLW_inst_emio_sdio1_ledcontrol_UNCONNECTED),
        .emio_sdio1_wp(1'b1),
        .emio_spi0_m_i(1'b0),
        .emio_spi0_m_o(NLW_inst_emio_spi0_m_o_UNCONNECTED),
        .emio_spi0_mo_t(NLW_inst_emio_spi0_mo_t_UNCONNECTED),
        .emio_spi0_mo_t_n(NLW_inst_emio_spi0_mo_t_n_UNCONNECTED),
        .emio_spi0_s_i(1'b0),
        .emio_spi0_s_o(NLW_inst_emio_spi0_s_o_UNCONNECTED),
        .emio_spi0_sclk_i(1'b0),
        .emio_spi0_sclk_o(NLW_inst_emio_spi0_sclk_o_UNCONNECTED),
        .emio_spi0_sclk_t(NLW_inst_emio_spi0_sclk_t_UNCONNECTED),
        .emio_spi0_sclk_t_n(NLW_inst_emio_spi0_sclk_t_n_UNCONNECTED),
        .emio_spi0_so_t(NLW_inst_emio_spi0_so_t_UNCONNECTED),
        .emio_spi0_so_t_n(NLW_inst_emio_spi0_so_t_n_UNCONNECTED),
        .emio_spi0_ss1_o_n(NLW_inst_emio_spi0_ss1_o_n_UNCONNECTED),
        .emio_spi0_ss2_o_n(NLW_inst_emio_spi0_ss2_o_n_UNCONNECTED),
        .emio_spi0_ss_i_n(1'b1),
        .emio_spi0_ss_n_t(NLW_inst_emio_spi0_ss_n_t_UNCONNECTED),
        .emio_spi0_ss_n_t_n(NLW_inst_emio_spi0_ss_n_t_n_UNCONNECTED),
        .emio_spi0_ss_o_n(NLW_inst_emio_spi0_ss_o_n_UNCONNECTED),
        .emio_spi1_m_i(1'b0),
        .emio_spi1_m_o(NLW_inst_emio_spi1_m_o_UNCONNECTED),
        .emio_spi1_mo_t(NLW_inst_emio_spi1_mo_t_UNCONNECTED),
        .emio_spi1_mo_t_n(NLW_inst_emio_spi1_mo_t_n_UNCONNECTED),
        .emio_spi1_s_i(1'b0),
        .emio_spi1_s_o(NLW_inst_emio_spi1_s_o_UNCONNECTED),
        .emio_spi1_sclk_i(1'b0),
        .emio_spi1_sclk_o(NLW_inst_emio_spi1_sclk_o_UNCONNECTED),
        .emio_spi1_sclk_t(NLW_inst_emio_spi1_sclk_t_UNCONNECTED),
        .emio_spi1_sclk_t_n(NLW_inst_emio_spi1_sclk_t_n_UNCONNECTED),
        .emio_spi1_so_t(NLW_inst_emio_spi1_so_t_UNCONNECTED),
        .emio_spi1_so_t_n(NLW_inst_emio_spi1_so_t_n_UNCONNECTED),
        .emio_spi1_ss1_o_n(NLW_inst_emio_spi1_ss1_o_n_UNCONNECTED),
        .emio_spi1_ss2_o_n(NLW_inst_emio_spi1_ss2_o_n_UNCONNECTED),
        .emio_spi1_ss_i_n(1'b1),
        .emio_spi1_ss_n_t(NLW_inst_emio_spi1_ss_n_t_UNCONNECTED),
        .emio_spi1_ss_n_t_n(NLW_inst_emio_spi1_ss_n_t_n_UNCONNECTED),
        .emio_spi1_ss_o_n(NLW_inst_emio_spi1_ss_o_n_UNCONNECTED),
        .emio_ttc0_clk_i({1'b0,1'b0,1'b0}),
        .emio_ttc0_wave_o(NLW_inst_emio_ttc0_wave_o_UNCONNECTED[2:0]),
        .emio_ttc1_clk_i({1'b0,1'b0,1'b0}),
        .emio_ttc1_wave_o(NLW_inst_emio_ttc1_wave_o_UNCONNECTED[2:0]),
        .emio_ttc2_clk_i({1'b0,1'b0,1'b0}),
        .emio_ttc2_wave_o(NLW_inst_emio_ttc2_wave_o_UNCONNECTED[2:0]),
        .emio_ttc3_clk_i({1'b0,1'b0,1'b0}),
        .emio_ttc3_wave_o(NLW_inst_emio_ttc3_wave_o_UNCONNECTED[2:0]),
        .emio_u2dsport_vbus_ctrl_usb3_0(NLW_inst_emio_u2dsport_vbus_ctrl_usb3_0_UNCONNECTED),
        .emio_u2dsport_vbus_ctrl_usb3_1(NLW_inst_emio_u2dsport_vbus_ctrl_usb3_1_UNCONNECTED),
        .emio_u3dsport_vbus_ctrl_usb3_0(NLW_inst_emio_u3dsport_vbus_ctrl_usb3_0_UNCONNECTED),
        .emio_u3dsport_vbus_ctrl_usb3_1(NLW_inst_emio_u3dsport_vbus_ctrl_usb3_1_UNCONNECTED),
        .emio_uart0_ctsn(1'b0),
        .emio_uart0_dcdn(1'b0),
        .emio_uart0_dsrn(1'b0),
        .emio_uart0_dtrn(NLW_inst_emio_uart0_dtrn_UNCONNECTED),
        .emio_uart0_rin(1'b0),
        .emio_uart0_rtsn(NLW_inst_emio_uart0_rtsn_UNCONNECTED),
        .emio_uart0_rxd(1'b0),
        .emio_uart0_txd(NLW_inst_emio_uart0_txd_UNCONNECTED),
        .emio_uart1_ctsn(1'b0),
        .emio_uart1_dcdn(1'b0),
        .emio_uart1_dsrn(1'b0),
        .emio_uart1_dtrn(NLW_inst_emio_uart1_dtrn_UNCONNECTED),
        .emio_uart1_rin(1'b0),
        .emio_uart1_rtsn(NLW_inst_emio_uart1_rtsn_UNCONNECTED),
        .emio_uart1_rxd(1'b0),
        .emio_uart1_txd(NLW_inst_emio_uart1_txd_UNCONNECTED),
        .emio_wdt0_clk_i(1'b0),
        .emio_wdt0_rst_o(NLW_inst_emio_wdt0_rst_o_UNCONNECTED),
        .emio_wdt1_clk_i(1'b0),
        .emio_wdt1_rst_o(NLW_inst_emio_wdt1_rst_o_UNCONNECTED),
        .fmio_char_afifsfpd_test_input(1'b0),
        .fmio_char_afifsfpd_test_output(NLW_inst_fmio_char_afifsfpd_test_output_UNCONNECTED),
        .fmio_char_afifsfpd_test_select_n(1'b0),
        .fmio_char_afifslpd_test_input(1'b0),
        .fmio_char_afifslpd_test_output(NLW_inst_fmio_char_afifslpd_test_output_UNCONNECTED),
        .fmio_char_afifslpd_test_select_n(1'b0),
        .fmio_char_gem_selection({1'b0,1'b0}),
        .fmio_char_gem_test_input(1'b0),
        .fmio_char_gem_test_output(NLW_inst_fmio_char_gem_test_output_UNCONNECTED),
        .fmio_char_gem_test_select_n(1'b0),
        .fmio_gem0_fifo_rx_clk_to_pl_bufg(NLW_inst_fmio_gem0_fifo_rx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem0_fifo_tx_clk_to_pl_bufg(NLW_inst_fmio_gem0_fifo_tx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem1_fifo_rx_clk_to_pl_bufg(NLW_inst_fmio_gem1_fifo_rx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem1_fifo_tx_clk_to_pl_bufg(NLW_inst_fmio_gem1_fifo_tx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem2_fifo_rx_clk_to_pl_bufg(NLW_inst_fmio_gem2_fifo_rx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem2_fifo_tx_clk_to_pl_bufg(NLW_inst_fmio_gem2_fifo_tx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem3_fifo_rx_clk_to_pl_bufg(NLW_inst_fmio_gem3_fifo_rx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem3_fifo_tx_clk_to_pl_bufg(NLW_inst_fmio_gem3_fifo_tx_clk_to_pl_bufg_UNCONNECTED),
        .fmio_gem_tsu_clk_from_pl(1'b0),
        .fmio_gem_tsu_clk_to_pl_bufg(NLW_inst_fmio_gem_tsu_clk_to_pl_bufg_UNCONNECTED),
        .fmio_sd0_dll_test_in_n({1'b0,1'b0,1'b0,1'b0}),
        .fmio_sd0_dll_test_out(NLW_inst_fmio_sd0_dll_test_out_UNCONNECTED[7:0]),
        .fmio_sd1_dll_test_in_n({1'b0,1'b0,1'b0,1'b0}),
        .fmio_sd1_dll_test_out(NLW_inst_fmio_sd1_dll_test_out_UNCONNECTED[7:0]),
        .fmio_test_gem_scanmux_1(1'b0),
        .fmio_test_gem_scanmux_2(1'b0),
        .fmio_test_io_char_scan_clock(1'b0),
        .fmio_test_io_char_scan_in(1'b0),
        .fmio_test_io_char_scan_out(NLW_inst_fmio_test_io_char_scan_out_UNCONNECTED),
        .fmio_test_io_char_scan_reset_n(1'b0),
        .fmio_test_io_char_scanenable(1'b0),
        .fmio_test_qspi_scanmux_1_n(1'b0),
        .fmio_test_sdio_scanmux_1(1'b0),
        .fmio_test_sdio_scanmux_2(1'b0),
        .fpd_pl_spare_0_out(NLW_inst_fpd_pl_spare_0_out_UNCONNECTED),
        .fpd_pl_spare_1_out(NLW_inst_fpd_pl_spare_1_out_UNCONNECTED),
        .fpd_pl_spare_2_out(NLW_inst_fpd_pl_spare_2_out_UNCONNECTED),
        .fpd_pl_spare_3_out(NLW_inst_fpd_pl_spare_3_out_UNCONNECTED),
        .fpd_pl_spare_4_out(NLW_inst_fpd_pl_spare_4_out_UNCONNECTED),
        .fpd_pll_test_out(NLW_inst_fpd_pll_test_out_UNCONNECTED[31:0]),
        .ftm_gpi({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .ftm_gpo(NLW_inst_ftm_gpo_UNCONNECTED[31:0]),
        .gdma_perif_cack(NLW_inst_gdma_perif_cack_UNCONNECTED[7:0]),
        .gdma_perif_tvld(NLW_inst_gdma_perif_tvld_UNCONNECTED[7:0]),
        .i_afe_TX_LPBK_SEL({1'b0,1'b0,1'b0}),
        .i_afe_TX_ana_if_rate({1'b0,1'b0}),
        .i_afe_TX_en_dig_sublp_mode(1'b0),
        .i_afe_TX_iso_ctrl_bar(1'b0),
        .i_afe_TX_lfps_clk(1'b0),
        .i_afe_TX_pll_symb_clk_2(1'b0),
        .i_afe_TX_pmadig_digital_reset_n(1'b0),
        .i_afe_TX_ser_iso_ctrl_bar(1'b0),
        .i_afe_TX_serializer_rst_rel(1'b0),
        .i_afe_TX_serializer_rstb(1'b0),
        .i_afe_TX_uphy_txpma_opmode({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_cmn_bg_enable_low_leakage(1'b0),
        .i_afe_cmn_bg_iso_ctrl_bar(1'b0),
        .i_afe_cmn_bg_pd(1'b0),
        .i_afe_cmn_bg_pd_bg_ok(1'b0),
        .i_afe_cmn_bg_pd_ptat(1'b0),
        .i_afe_cmn_calib_en_iconst(1'b0),
        .i_afe_cmn_calib_enable_low_leakage(1'b0),
        .i_afe_cmn_calib_iso_ctrl_bar(1'b0),
        .i_afe_mode(1'b0),
        .i_afe_pll_coarse_code({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_pll_en_clock_hs_div2(1'b0),
        .i_afe_pll_fbdiv({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_pll_load_fbdiv(1'b0),
        .i_afe_pll_pd(1'b0),
        .i_afe_pll_pd_hs_clock_r(1'b0),
        .i_afe_pll_pd_pfd(1'b0),
        .i_afe_pll_rst_fdbk_div(1'b0),
        .i_afe_pll_startloop(1'b0),
        .i_afe_pll_v2i_code({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_pll_v2i_prog({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_pll_vco_cnt_window(1'b0),
        .i_afe_rx_hsrx_clock_stop_req(1'b0),
        .i_afe_rx_iso_hsrx_ctrl_bar(1'b0),
        .i_afe_rx_iso_lfps_ctrl_bar(1'b0),
        .i_afe_rx_iso_sigdet_ctrl_bar(1'b0),
        .i_afe_rx_mphy_gate_symbol_clk(1'b0),
        .i_afe_rx_mphy_mux_hsb_ls(1'b0),
        .i_afe_rx_pipe_rx_term_enable(1'b0),
        .i_afe_rx_pipe_rxeqtraining(1'b0),
        .i_afe_rx_rxpma_refclk_dig(1'b0),
        .i_afe_rx_rxpma_rstb(1'b0),
        .i_afe_rx_symbol_clk_by_2_pl(1'b0),
        .i_afe_rx_uphy_biasgen_iconst_core_mirror_enable(1'b0),
        .i_afe_rx_uphy_biasgen_iconst_io_mirror_enable(1'b0),
        .i_afe_rx_uphy_biasgen_irconst_core_mirror_enable(1'b0),
        .i_afe_rx_uphy_enable_cdr(1'b0),
        .i_afe_rx_uphy_enable_low_leakage(1'b0),
        .i_afe_rx_uphy_hsclk_division_factor({1'b0,1'b0}),
        .i_afe_rx_uphy_hsrx_rstb(1'b0),
        .i_afe_rx_uphy_pd_samp_c2c(1'b0),
        .i_afe_rx_uphy_pd_samp_c2c_eclk(1'b0),
        .i_afe_rx_uphy_pdn_hs_des(1'b0),
        .i_afe_rx_uphy_pso_clk_lane(1'b0),
        .i_afe_rx_uphy_pso_eq(1'b0),
        .i_afe_rx_uphy_pso_hsrxdig(1'b0),
        .i_afe_rx_uphy_pso_iqpi(1'b0),
        .i_afe_rx_uphy_pso_lfpsbcn(1'b0),
        .i_afe_rx_uphy_pso_samp_flops(1'b0),
        .i_afe_rx_uphy_pso_sigdet(1'b0),
        .i_afe_rx_uphy_restore_calcode(1'b0),
        .i_afe_rx_uphy_restore_calcode_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_rx_uphy_run_calib(1'b0),
        .i_afe_rx_uphy_rx_lane_polarity_swap(1'b0),
        .i_afe_rx_uphy_rx_pma_opmode({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_rx_uphy_startloop_pll(1'b0),
        .i_afe_tx_enable_hsclk_division({1'b0,1'b0}),
        .i_afe_tx_enable_ldo(1'b0),
        .i_afe_tx_enable_ref(1'b0),
        .i_afe_tx_enable_supply_hsclk(1'b0),
        .i_afe_tx_enable_supply_pipe(1'b0),
        .i_afe_tx_enable_supply_serializer(1'b0),
        .i_afe_tx_enable_supply_uphy(1'b0),
        .i_afe_tx_hs_ser_rstb(1'b0),
        .i_afe_tx_hs_symbol({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .i_afe_tx_mphy_tx_ls_data(1'b0),
        .i_afe_tx_pipe_tx_enable_idle_mode({1'b0,1'b0}),
        .i_afe_tx_pipe_tx_enable_lfps({1'b0,1'b0}),
        .i_afe_tx_pipe_tx_enable_rxdet(1'b0),
        .i_afe_tx_pipe_tx_fast_est_common_mode(1'b0),
        .i_bgcal_afe_mode(1'b0),
        .i_dbg_l0_rxclk(1'b0),
        .i_dbg_l0_txclk(1'b0),
        .i_dbg_l1_rxclk(1'b0),
        .i_dbg_l1_txclk(1'b0),
        .i_dbg_l2_rxclk(1'b0),
        .i_dbg_l2_txclk(1'b0),
        .i_dbg_l3_rxclk(1'b0),
        .i_dbg_l3_txclk(1'b0),
        .i_pll_afe_mode(1'b0),
        .io_char_audio_in_test_data(1'b0),
        .io_char_audio_mux_sel_n(1'b0),
        .io_char_audio_out_test_data(NLW_inst_io_char_audio_out_test_data_UNCONNECTED),
        .io_char_video_in_test_data(1'b0),
        .io_char_video_mux_sel_n(1'b0),
        .io_char_video_out_test_data(NLW_inst_io_char_video_out_test_data_UNCONNECTED),
        .irq_ipi_pl_0(NLW_inst_irq_ipi_pl_0_UNCONNECTED),
        .irq_ipi_pl_1(NLW_inst_irq_ipi_pl_1_UNCONNECTED),
        .irq_ipi_pl_2(NLW_inst_irq_ipi_pl_2_UNCONNECTED),
        .irq_ipi_pl_3(NLW_inst_irq_ipi_pl_3_UNCONNECTED),
        .lpd_pl_spare_0_out(NLW_inst_lpd_pl_spare_0_out_UNCONNECTED),
        .lpd_pl_spare_1_out(NLW_inst_lpd_pl_spare_1_out_UNCONNECTED),
        .lpd_pl_spare_2_out(NLW_inst_lpd_pl_spare_2_out_UNCONNECTED),
        .lpd_pl_spare_3_out(NLW_inst_lpd_pl_spare_3_out_UNCONNECTED),
        .lpd_pl_spare_4_out(NLW_inst_lpd_pl_spare_4_out_UNCONNECTED),
        .lpd_pll_test_out(NLW_inst_lpd_pll_test_out_UNCONNECTED[31:0]),
        .maxigp0_araddr(maxigp0_araddr),
        .maxigp0_arburst(maxigp0_arburst),
        .maxigp0_arcache(maxigp0_arcache),
        .maxigp0_arid(maxigp0_arid),
        .maxigp0_arlen(maxigp0_arlen),
        .maxigp0_arlock(maxigp0_arlock),
        .maxigp0_arprot(maxigp0_arprot),
        .maxigp0_arqos(maxigp0_arqos),
        .maxigp0_arready(maxigp0_arready),
        .maxigp0_arsize(maxigp0_arsize),
        .maxigp0_aruser(maxigp0_aruser),
        .maxigp0_arvalid(maxigp0_arvalid),
        .maxigp0_awaddr(maxigp0_awaddr),
        .maxigp0_awburst(maxigp0_awburst),
        .maxigp0_awcache(maxigp0_awcache),
        .maxigp0_awid(maxigp0_awid),
        .maxigp0_awlen(maxigp0_awlen),
        .maxigp0_awlock(maxigp0_awlock),
        .maxigp0_awprot(maxigp0_awprot),
        .maxigp0_awqos(maxigp0_awqos),
        .maxigp0_awready(maxigp0_awready),
        .maxigp0_awsize(maxigp0_awsize),
        .maxigp0_awuser(maxigp0_awuser),
        .maxigp0_awvalid(maxigp0_awvalid),
        .maxigp0_bid(maxigp0_bid),
        .maxigp0_bready(maxigp0_bready),
        .maxigp0_bresp(maxigp0_bresp),
        .maxigp0_bvalid(maxigp0_bvalid),
        .maxigp0_rdata(maxigp0_rdata),
        .maxigp0_rid(maxigp0_rid),
        .maxigp0_rlast(maxigp0_rlast),
        .maxigp0_rready(maxigp0_rready),
        .maxigp0_rresp(maxigp0_rresp),
        .maxigp0_rvalid(maxigp0_rvalid),
        .maxigp0_wdata(maxigp0_wdata),
        .maxigp0_wlast(maxigp0_wlast),
        .maxigp0_wready(maxigp0_wready),
        .maxigp0_wstrb(maxigp0_wstrb),
        .maxigp0_wvalid(maxigp0_wvalid),
        .maxigp1_araddr(maxigp1_araddr),
        .maxigp1_arburst(maxigp1_arburst),
        .maxigp1_arcache(maxigp1_arcache),
        .maxigp1_arid(maxigp1_arid),
        .maxigp1_arlen(maxigp1_arlen),
        .maxigp1_arlock(maxigp1_arlock),
        .maxigp1_arprot(maxigp1_arprot),
        .maxigp1_arqos(maxigp1_arqos),
        .maxigp1_arready(maxigp1_arready),
        .maxigp1_arsize(maxigp1_arsize),
        .maxigp1_aruser(maxigp1_aruser),
        .maxigp1_arvalid(maxigp1_arvalid),
        .maxigp1_awaddr(maxigp1_awaddr),
        .maxigp1_awburst(maxigp1_awburst),
        .maxigp1_awcache(maxigp1_awcache),
        .maxigp1_awid(maxigp1_awid),
        .maxigp1_awlen(maxigp1_awlen),
        .maxigp1_awlock(maxigp1_awlock),
        .maxigp1_awprot(maxigp1_awprot),
        .maxigp1_awqos(maxigp1_awqos),
        .maxigp1_awready(maxigp1_awready),
        .maxigp1_awsize(maxigp1_awsize),
        .maxigp1_awuser(maxigp1_awuser),
        .maxigp1_awvalid(maxigp1_awvalid),
        .maxigp1_bid(maxigp1_bid),
        .maxigp1_bready(maxigp1_bready),
        .maxigp1_bresp(maxigp1_bresp),
        .maxigp1_bvalid(maxigp1_bvalid),
        .maxigp1_rdata(maxigp1_rdata),
        .maxigp1_rid(maxigp1_rid),
        .maxigp1_rlast(maxigp1_rlast),
        .maxigp1_rready(maxigp1_rready),
        .maxigp1_rresp(maxigp1_rresp),
        .maxigp1_rvalid(maxigp1_rvalid),
        .maxigp1_wdata(maxigp1_wdata),
        .maxigp1_wlast(maxigp1_wlast),
        .maxigp1_wready(maxigp1_wready),
        .maxigp1_wstrb(maxigp1_wstrb),
        .maxigp1_wvalid(maxigp1_wvalid),
        .maxigp2_araddr(NLW_inst_maxigp2_araddr_UNCONNECTED[39:0]),
        .maxigp2_arburst(NLW_inst_maxigp2_arburst_UNCONNECTED[1:0]),
        .maxigp2_arcache(NLW_inst_maxigp2_arcache_UNCONNECTED[3:0]),
        .maxigp2_arid(NLW_inst_maxigp2_arid_UNCONNECTED[15:0]),
        .maxigp2_arlen(NLW_inst_maxigp2_arlen_UNCONNECTED[7:0]),
        .maxigp2_arlock(NLW_inst_maxigp2_arlock_UNCONNECTED),
        .maxigp2_arprot(NLW_inst_maxigp2_arprot_UNCONNECTED[2:0]),
        .maxigp2_arqos(NLW_inst_maxigp2_arqos_UNCONNECTED[3:0]),
        .maxigp2_arready(1'b0),
        .maxigp2_arsize(NLW_inst_maxigp2_arsize_UNCONNECTED[2:0]),
        .maxigp2_aruser(NLW_inst_maxigp2_aruser_UNCONNECTED[15:0]),
        .maxigp2_arvalid(NLW_inst_maxigp2_arvalid_UNCONNECTED),
        .maxigp2_awaddr(NLW_inst_maxigp2_awaddr_UNCONNECTED[39:0]),
        .maxigp2_awburst(NLW_inst_maxigp2_awburst_UNCONNECTED[1:0]),
        .maxigp2_awcache(NLW_inst_maxigp2_awcache_UNCONNECTED[3:0]),
        .maxigp2_awid(NLW_inst_maxigp2_awid_UNCONNECTED[15:0]),
        .maxigp2_awlen(NLW_inst_maxigp2_awlen_UNCONNECTED[7:0]),
        .maxigp2_awlock(NLW_inst_maxigp2_awlock_UNCONNECTED),
        .maxigp2_awprot(NLW_inst_maxigp2_awprot_UNCONNECTED[2:0]),
        .maxigp2_awqos(NLW_inst_maxigp2_awqos_UNCONNECTED[3:0]),
        .maxigp2_awready(1'b0),
        .maxigp2_awsize(NLW_inst_maxigp2_awsize_UNCONNECTED[2:0]),
        .maxigp2_awuser(NLW_inst_maxigp2_awuser_UNCONNECTED[15:0]),
        .maxigp2_awvalid(NLW_inst_maxigp2_awvalid_UNCONNECTED),
        .maxigp2_bid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .maxigp2_bready(NLW_inst_maxigp2_bready_UNCONNECTED),
        .maxigp2_bresp({1'b0,1'b0}),
        .maxigp2_bvalid(1'b0),
        .maxigp2_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .maxigp2_rid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .maxigp2_rlast(1'b0),
        .maxigp2_rready(NLW_inst_maxigp2_rready_UNCONNECTED),
        .maxigp2_rresp({1'b0,1'b0}),
        .maxigp2_rvalid(1'b0),
        .maxigp2_wdata(NLW_inst_maxigp2_wdata_UNCONNECTED[31:0]),
        .maxigp2_wlast(NLW_inst_maxigp2_wlast_UNCONNECTED),
        .maxigp2_wready(1'b0),
        .maxigp2_wstrb(NLW_inst_maxigp2_wstrb_UNCONNECTED[3:0]),
        .maxigp2_wvalid(NLW_inst_maxigp2_wvalid_UNCONNECTED),
        .maxihpm0_fpd_aclk(maxihpm0_fpd_aclk),
        .maxihpm0_lpd_aclk(1'b0),
        .maxihpm1_fpd_aclk(maxihpm1_fpd_aclk),
        .nfiq0_lpd_rpu(1'b1),
        .nfiq1_lpd_rpu(1'b1),
        .nirq0_lpd_rpu(1'b1),
        .nirq1_lpd_rpu(1'b1),
        .o_afe_TX_dig_reset_rel_ack(NLW_inst_o_afe_TX_dig_reset_rel_ack_UNCONNECTED),
        .o_afe_TX_pipe_TX_dn_rxdet(NLW_inst_o_afe_TX_pipe_TX_dn_rxdet_UNCONNECTED),
        .o_afe_TX_pipe_TX_dp_rxdet(NLW_inst_o_afe_TX_pipe_TX_dp_rxdet_UNCONNECTED),
        .o_afe_cmn_calib_comp_out(NLW_inst_o_afe_cmn_calib_comp_out_UNCONNECTED),
        .o_afe_pg_avddcr(NLW_inst_o_afe_pg_avddcr_UNCONNECTED),
        .o_afe_pg_avddio(NLW_inst_o_afe_pg_avddio_UNCONNECTED),
        .o_afe_pg_dvddcr(NLW_inst_o_afe_pg_dvddcr_UNCONNECTED),
        .o_afe_pg_static_avddcr(NLW_inst_o_afe_pg_static_avddcr_UNCONNECTED),
        .o_afe_pg_static_avddio(NLW_inst_o_afe_pg_static_avddio_UNCONNECTED),
        .o_afe_pll_clk_sym_hs(NLW_inst_o_afe_pll_clk_sym_hs_UNCONNECTED),
        .o_afe_pll_dco_count(NLW_inst_o_afe_pll_dco_count_UNCONNECTED[12:0]),
        .o_afe_pll_fbclk_frac(NLW_inst_o_afe_pll_fbclk_frac_UNCONNECTED),
        .o_afe_rx_hsrx_clock_stop_ack(NLW_inst_o_afe_rx_hsrx_clock_stop_ack_UNCONNECTED),
        .o_afe_rx_pipe_lfpsbcn_rxelecidle(NLW_inst_o_afe_rx_pipe_lfpsbcn_rxelecidle_UNCONNECTED),
        .o_afe_rx_pipe_sigdet(NLW_inst_o_afe_rx_pipe_sigdet_UNCONNECTED),
        .o_afe_rx_symbol(NLW_inst_o_afe_rx_symbol_UNCONNECTED[19:0]),
        .o_afe_rx_symbol_clk_by_2(NLW_inst_o_afe_rx_symbol_clk_by_2_UNCONNECTED),
        .o_afe_rx_uphy_rx_calib_done(NLW_inst_o_afe_rx_uphy_rx_calib_done_UNCONNECTED),
        .o_afe_rx_uphy_save_calcode(NLW_inst_o_afe_rx_uphy_save_calcode_UNCONNECTED),
        .o_afe_rx_uphy_save_calcode_data(NLW_inst_o_afe_rx_uphy_save_calcode_data_UNCONNECTED[7:0]),
        .o_afe_rx_uphy_startloop_buf(NLW_inst_o_afe_rx_uphy_startloop_buf_UNCONNECTED),
        .o_dbg_l0_phystatus(NLW_inst_o_dbg_l0_phystatus_UNCONNECTED),
        .o_dbg_l0_powerdown(NLW_inst_o_dbg_l0_powerdown_UNCONNECTED[1:0]),
        .o_dbg_l0_rate(NLW_inst_o_dbg_l0_rate_UNCONNECTED[1:0]),
        .o_dbg_l0_rstb(NLW_inst_o_dbg_l0_rstb_UNCONNECTED),
        .o_dbg_l0_rx_sgmii_en_cdet(NLW_inst_o_dbg_l0_rx_sgmii_en_cdet_UNCONNECTED),
        .o_dbg_l0_rxclk(NLW_inst_o_dbg_l0_rxclk_UNCONNECTED),
        .o_dbg_l0_rxdata(NLW_inst_o_dbg_l0_rxdata_UNCONNECTED[19:0]),
        .o_dbg_l0_rxdatak(NLW_inst_o_dbg_l0_rxdatak_UNCONNECTED[1:0]),
        .o_dbg_l0_rxelecidle(NLW_inst_o_dbg_l0_rxelecidle_UNCONNECTED),
        .o_dbg_l0_rxpolarity(NLW_inst_o_dbg_l0_rxpolarity_UNCONNECTED),
        .o_dbg_l0_rxstatus(NLW_inst_o_dbg_l0_rxstatus_UNCONNECTED[2:0]),
        .o_dbg_l0_rxvalid(NLW_inst_o_dbg_l0_rxvalid_UNCONNECTED),
        .o_dbg_l0_sata_coreclockready(NLW_inst_o_dbg_l0_sata_coreclockready_UNCONNECTED),
        .o_dbg_l0_sata_coreready(NLW_inst_o_dbg_l0_sata_coreready_UNCONNECTED),
        .o_dbg_l0_sata_corerxdata(NLW_inst_o_dbg_l0_sata_corerxdata_UNCONNECTED[19:0]),
        .o_dbg_l0_sata_corerxdatavalid(NLW_inst_o_dbg_l0_sata_corerxdatavalid_UNCONNECTED[1:0]),
        .o_dbg_l0_sata_corerxsignaldet(NLW_inst_o_dbg_l0_sata_corerxsignaldet_UNCONNECTED),
        .o_dbg_l0_sata_phyctrlpartial(NLW_inst_o_dbg_l0_sata_phyctrlpartial_UNCONNECTED),
        .o_dbg_l0_sata_phyctrlreset(NLW_inst_o_dbg_l0_sata_phyctrlreset_UNCONNECTED),
        .o_dbg_l0_sata_phyctrlrxrate(NLW_inst_o_dbg_l0_sata_phyctrlrxrate_UNCONNECTED[1:0]),
        .o_dbg_l0_sata_phyctrlrxrst(NLW_inst_o_dbg_l0_sata_phyctrlrxrst_UNCONNECTED),
        .o_dbg_l0_sata_phyctrlslumber(NLW_inst_o_dbg_l0_sata_phyctrlslumber_UNCONNECTED),
        .o_dbg_l0_sata_phyctrltxdata(NLW_inst_o_dbg_l0_sata_phyctrltxdata_UNCONNECTED[19:0]),
        .o_dbg_l0_sata_phyctrltxidle(NLW_inst_o_dbg_l0_sata_phyctrltxidle_UNCONNECTED),
        .o_dbg_l0_sata_phyctrltxrate(NLW_inst_o_dbg_l0_sata_phyctrltxrate_UNCONNECTED[1:0]),
        .o_dbg_l0_sata_phyctrltxrst(NLW_inst_o_dbg_l0_sata_phyctrltxrst_UNCONNECTED),
        .o_dbg_l0_tx_sgmii_ewrap(NLW_inst_o_dbg_l0_tx_sgmii_ewrap_UNCONNECTED),
        .o_dbg_l0_txclk(NLW_inst_o_dbg_l0_txclk_UNCONNECTED),
        .o_dbg_l0_txdata(NLW_inst_o_dbg_l0_txdata_UNCONNECTED[19:0]),
        .o_dbg_l0_txdatak(NLW_inst_o_dbg_l0_txdatak_UNCONNECTED[1:0]),
        .o_dbg_l0_txdetrx_lpback(NLW_inst_o_dbg_l0_txdetrx_lpback_UNCONNECTED),
        .o_dbg_l0_txelecidle(NLW_inst_o_dbg_l0_txelecidle_UNCONNECTED),
        .o_dbg_l1_phystatus(NLW_inst_o_dbg_l1_phystatus_UNCONNECTED),
        .o_dbg_l1_powerdown(NLW_inst_o_dbg_l1_powerdown_UNCONNECTED[1:0]),
        .o_dbg_l1_rate(NLW_inst_o_dbg_l1_rate_UNCONNECTED[1:0]),
        .o_dbg_l1_rstb(NLW_inst_o_dbg_l1_rstb_UNCONNECTED),
        .o_dbg_l1_rx_sgmii_en_cdet(NLW_inst_o_dbg_l1_rx_sgmii_en_cdet_UNCONNECTED),
        .o_dbg_l1_rxclk(NLW_inst_o_dbg_l1_rxclk_UNCONNECTED),
        .o_dbg_l1_rxdata(NLW_inst_o_dbg_l1_rxdata_UNCONNECTED[19:0]),
        .o_dbg_l1_rxdatak(NLW_inst_o_dbg_l1_rxdatak_UNCONNECTED[1:0]),
        .o_dbg_l1_rxelecidle(NLW_inst_o_dbg_l1_rxelecidle_UNCONNECTED),
        .o_dbg_l1_rxpolarity(NLW_inst_o_dbg_l1_rxpolarity_UNCONNECTED),
        .o_dbg_l1_rxstatus(NLW_inst_o_dbg_l1_rxstatus_UNCONNECTED[2:0]),
        .o_dbg_l1_rxvalid(NLW_inst_o_dbg_l1_rxvalid_UNCONNECTED),
        .o_dbg_l1_sata_coreclockready(NLW_inst_o_dbg_l1_sata_coreclockready_UNCONNECTED),
        .o_dbg_l1_sata_coreready(NLW_inst_o_dbg_l1_sata_coreready_UNCONNECTED),
        .o_dbg_l1_sata_corerxdata(NLW_inst_o_dbg_l1_sata_corerxdata_UNCONNECTED[19:0]),
        .o_dbg_l1_sata_corerxdatavalid(NLW_inst_o_dbg_l1_sata_corerxdatavalid_UNCONNECTED[1:0]),
        .o_dbg_l1_sata_corerxsignaldet(NLW_inst_o_dbg_l1_sata_corerxsignaldet_UNCONNECTED),
        .o_dbg_l1_sata_phyctrlpartial(NLW_inst_o_dbg_l1_sata_phyctrlpartial_UNCONNECTED),
        .o_dbg_l1_sata_phyctrlreset(NLW_inst_o_dbg_l1_sata_phyctrlreset_UNCONNECTED),
        .o_dbg_l1_sata_phyctrlrxrate(NLW_inst_o_dbg_l1_sata_phyctrlrxrate_UNCONNECTED[1:0]),
        .o_dbg_l1_sata_phyctrlrxrst(NLW_inst_o_dbg_l1_sata_phyctrlrxrst_UNCONNECTED),
        .o_dbg_l1_sata_phyctrlslumber(NLW_inst_o_dbg_l1_sata_phyctrlslumber_UNCONNECTED),
        .o_dbg_l1_sata_phyctrltxdata(NLW_inst_o_dbg_l1_sata_phyctrltxdata_UNCONNECTED[19:0]),
        .o_dbg_l1_sata_phyctrltxidle(NLW_inst_o_dbg_l1_sata_phyctrltxidle_UNCONNECTED),
        .o_dbg_l1_sata_phyctrltxrate(NLW_inst_o_dbg_l1_sata_phyctrltxrate_UNCONNECTED[1:0]),
        .o_dbg_l1_sata_phyctrltxrst(NLW_inst_o_dbg_l1_sata_phyctrltxrst_UNCONNECTED),
        .o_dbg_l1_tx_sgmii_ewrap(NLW_inst_o_dbg_l1_tx_sgmii_ewrap_UNCONNECTED),
        .o_dbg_l1_txclk(NLW_inst_o_dbg_l1_txclk_UNCONNECTED),
        .o_dbg_l1_txdata(NLW_inst_o_dbg_l1_txdata_UNCONNECTED[19:0]),
        .o_dbg_l1_txdatak(NLW_inst_o_dbg_l1_txdatak_UNCONNECTED[1:0]),
        .o_dbg_l1_txdetrx_lpback(NLW_inst_o_dbg_l1_txdetrx_lpback_UNCONNECTED),
        .o_dbg_l1_txelecidle(NLW_inst_o_dbg_l1_txelecidle_UNCONNECTED),
        .o_dbg_l2_phystatus(NLW_inst_o_dbg_l2_phystatus_UNCONNECTED),
        .o_dbg_l2_powerdown(NLW_inst_o_dbg_l2_powerdown_UNCONNECTED[1:0]),
        .o_dbg_l2_rate(NLW_inst_o_dbg_l2_rate_UNCONNECTED[1:0]),
        .o_dbg_l2_rstb(NLW_inst_o_dbg_l2_rstb_UNCONNECTED),
        .o_dbg_l2_rx_sgmii_en_cdet(NLW_inst_o_dbg_l2_rx_sgmii_en_cdet_UNCONNECTED),
        .o_dbg_l2_rxclk(NLW_inst_o_dbg_l2_rxclk_UNCONNECTED),
        .o_dbg_l2_rxdata(NLW_inst_o_dbg_l2_rxdata_UNCONNECTED[19:0]),
        .o_dbg_l2_rxdatak(NLW_inst_o_dbg_l2_rxdatak_UNCONNECTED[1:0]),
        .o_dbg_l2_rxelecidle(NLW_inst_o_dbg_l2_rxelecidle_UNCONNECTED),
        .o_dbg_l2_rxpolarity(NLW_inst_o_dbg_l2_rxpolarity_UNCONNECTED),
        .o_dbg_l2_rxstatus(NLW_inst_o_dbg_l2_rxstatus_UNCONNECTED[2:0]),
        .o_dbg_l2_rxvalid(NLW_inst_o_dbg_l2_rxvalid_UNCONNECTED),
        .o_dbg_l2_sata_coreclockready(NLW_inst_o_dbg_l2_sata_coreclockready_UNCONNECTED),
        .o_dbg_l2_sata_coreready(NLW_inst_o_dbg_l2_sata_coreready_UNCONNECTED),
        .o_dbg_l2_sata_corerxdata(NLW_inst_o_dbg_l2_sata_corerxdata_UNCONNECTED[19:0]),
        .o_dbg_l2_sata_corerxdatavalid(NLW_inst_o_dbg_l2_sata_corerxdatavalid_UNCONNECTED[1:0]),
        .o_dbg_l2_sata_corerxsignaldet(NLW_inst_o_dbg_l2_sata_corerxsignaldet_UNCONNECTED),
        .o_dbg_l2_sata_phyctrlpartial(NLW_inst_o_dbg_l2_sata_phyctrlpartial_UNCONNECTED),
        .o_dbg_l2_sata_phyctrlreset(NLW_inst_o_dbg_l2_sata_phyctrlreset_UNCONNECTED),
        .o_dbg_l2_sata_phyctrlrxrate(NLW_inst_o_dbg_l2_sata_phyctrlrxrate_UNCONNECTED[1:0]),
        .o_dbg_l2_sata_phyctrlrxrst(NLW_inst_o_dbg_l2_sata_phyctrlrxrst_UNCONNECTED),
        .o_dbg_l2_sata_phyctrlslumber(NLW_inst_o_dbg_l2_sata_phyctrlslumber_UNCONNECTED),
        .o_dbg_l2_sata_phyctrltxdata(NLW_inst_o_dbg_l2_sata_phyctrltxdata_UNCONNECTED[19:0]),
        .o_dbg_l2_sata_phyctrltxidle(NLW_inst_o_dbg_l2_sata_phyctrltxidle_UNCONNECTED),
        .o_dbg_l2_sata_phyctrltxrate(NLW_inst_o_dbg_l2_sata_phyctrltxrate_UNCONNECTED[1:0]),
        .o_dbg_l2_sata_phyctrltxrst(NLW_inst_o_dbg_l2_sata_phyctrltxrst_UNCONNECTED),
        .o_dbg_l2_tx_sgmii_ewrap(NLW_inst_o_dbg_l2_tx_sgmii_ewrap_UNCONNECTED),
        .o_dbg_l2_txclk(NLW_inst_o_dbg_l2_txclk_UNCONNECTED),
        .o_dbg_l2_txdata(NLW_inst_o_dbg_l2_txdata_UNCONNECTED[19:0]),
        .o_dbg_l2_txdatak(NLW_inst_o_dbg_l2_txdatak_UNCONNECTED[1:0]),
        .o_dbg_l2_txdetrx_lpback(NLW_inst_o_dbg_l2_txdetrx_lpback_UNCONNECTED),
        .o_dbg_l2_txelecidle(NLW_inst_o_dbg_l2_txelecidle_UNCONNECTED),
        .o_dbg_l3_phystatus(NLW_inst_o_dbg_l3_phystatus_UNCONNECTED),
        .o_dbg_l3_powerdown(NLW_inst_o_dbg_l3_powerdown_UNCONNECTED[1:0]),
        .o_dbg_l3_rate(NLW_inst_o_dbg_l3_rate_UNCONNECTED[1:0]),
        .o_dbg_l3_rstb(NLW_inst_o_dbg_l3_rstb_UNCONNECTED),
        .o_dbg_l3_rx_sgmii_en_cdet(NLW_inst_o_dbg_l3_rx_sgmii_en_cdet_UNCONNECTED),
        .o_dbg_l3_rxclk(NLW_inst_o_dbg_l3_rxclk_UNCONNECTED),
        .o_dbg_l3_rxdata(NLW_inst_o_dbg_l3_rxdata_UNCONNECTED[19:0]),
        .o_dbg_l3_rxdatak(NLW_inst_o_dbg_l3_rxdatak_UNCONNECTED[1:0]),
        .o_dbg_l3_rxelecidle(NLW_inst_o_dbg_l3_rxelecidle_UNCONNECTED),
        .o_dbg_l3_rxpolarity(NLW_inst_o_dbg_l3_rxpolarity_UNCONNECTED),
        .o_dbg_l3_rxstatus(NLW_inst_o_dbg_l3_rxstatus_UNCONNECTED[2:0]),
        .o_dbg_l3_rxvalid(NLW_inst_o_dbg_l3_rxvalid_UNCONNECTED),
        .o_dbg_l3_sata_coreclockready(NLW_inst_o_dbg_l3_sata_coreclockready_UNCONNECTED),
        .o_dbg_l3_sata_coreready(NLW_inst_o_dbg_l3_sata_coreready_UNCONNECTED),
        .o_dbg_l3_sata_corerxdata(NLW_inst_o_dbg_l3_sata_corerxdata_UNCONNECTED[19:0]),
        .o_dbg_l3_sata_corerxdatavalid(NLW_inst_o_dbg_l3_sata_corerxdatavalid_UNCONNECTED[1:0]),
        .o_dbg_l3_sata_corerxsignaldet(NLW_inst_o_dbg_l3_sata_corerxsignaldet_UNCONNECTED),
        .o_dbg_l3_sata_phyctrlpartial(NLW_inst_o_dbg_l3_sata_phyctrlpartial_UNCONNECTED),
        .o_dbg_l3_sata_phyctrlreset(NLW_inst_o_dbg_l3_sata_phyctrlreset_UNCONNECTED),
        .o_dbg_l3_sata_phyctrlrxrate(NLW_inst_o_dbg_l3_sata_phyctrlrxrate_UNCONNECTED[1:0]),
        .o_dbg_l3_sata_phyctrlrxrst(NLW_inst_o_dbg_l3_sata_phyctrlrxrst_UNCONNECTED),
        .o_dbg_l3_sata_phyctrlslumber(NLW_inst_o_dbg_l3_sata_phyctrlslumber_UNCONNECTED),
        .o_dbg_l3_sata_phyctrltxdata(NLW_inst_o_dbg_l3_sata_phyctrltxdata_UNCONNECTED[19:0]),
        .o_dbg_l3_sata_phyctrltxidle(NLW_inst_o_dbg_l3_sata_phyctrltxidle_UNCONNECTED),
        .o_dbg_l3_sata_phyctrltxrate(NLW_inst_o_dbg_l3_sata_phyctrltxrate_UNCONNECTED[1:0]),
        .o_dbg_l3_sata_phyctrltxrst(NLW_inst_o_dbg_l3_sata_phyctrltxrst_UNCONNECTED),
        .o_dbg_l3_tx_sgmii_ewrap(NLW_inst_o_dbg_l3_tx_sgmii_ewrap_UNCONNECTED),
        .o_dbg_l3_txclk(NLW_inst_o_dbg_l3_txclk_UNCONNECTED),
        .o_dbg_l3_txdata(NLW_inst_o_dbg_l3_txdata_UNCONNECTED[19:0]),
        .o_dbg_l3_txdatak(NLW_inst_o_dbg_l3_txdatak_UNCONNECTED[1:0]),
        .o_dbg_l3_txdetrx_lpback(NLW_inst_o_dbg_l3_txdetrx_lpback_UNCONNECTED),
        .o_dbg_l3_txelecidle(NLW_inst_o_dbg_l3_txelecidle_UNCONNECTED),
        .osc_rtc_clk(NLW_inst_osc_rtc_clk_UNCONNECTED),
        .perif_gdma_clk({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .perif_gdma_cvld({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .perif_gdma_tack({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .pl2adma_cvld({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .pl2adma_tack({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .pl_acpinact(1'b0),
        .pl_clk0(pl_clk0),
        .pl_clk1(NLW_inst_pl_clk1_UNCONNECTED),
        .pl_clk2(NLW_inst_pl_clk2_UNCONNECTED),
        .pl_clk3(NLW_inst_pl_clk3_UNCONNECTED),
        .pl_clock_stop({1'b0,1'b0,1'b0,1'b0}),
        .pl_fpd_pll_test_ck_sel_n({1'b0,1'b0,1'b0}),
        .pl_fpd_pll_test_fract_clk_sel_n(1'b0),
        .pl_fpd_pll_test_fract_en_n(1'b0),
        .pl_fpd_pll_test_mux_sel({1'b0,1'b0}),
        .pl_fpd_pll_test_sel({1'b0,1'b0,1'b0,1'b0}),
        .pl_fpd_spare_0_in(1'b0),
        .pl_fpd_spare_1_in(1'b0),
        .pl_fpd_spare_2_in(1'b0),
        .pl_fpd_spare_3_in(1'b0),
        .pl_fpd_spare_4_in(1'b0),
        .pl_lpd_pll_test_ck_sel_n({1'b0,1'b0,1'b0}),
        .pl_lpd_pll_test_fract_clk_sel_n(1'b0),
        .pl_lpd_pll_test_fract_en_n(1'b0),
        .pl_lpd_pll_test_mux_sel(1'b0),
        .pl_lpd_pll_test_sel({1'b0,1'b0,1'b0,1'b0}),
        .pl_lpd_spare_0_in(1'b0),
        .pl_lpd_spare_1_in(1'b0),
        .pl_lpd_spare_2_in(1'b0),
        .pl_lpd_spare_3_in(1'b0),
        .pl_lpd_spare_4_in(1'b0),
        .pl_pmu_gpi({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .pl_ps_apugic_fiq({1'b0,1'b0,1'b0,1'b0}),
        .pl_ps_apugic_irq({1'b0,1'b0,1'b0,1'b0}),
        .pl_ps_eventi(1'b0),
        .pl_ps_irq0(1'b0),
        .pl_ps_irq1(1'b0),
        .pl_ps_trace_clk(1'b0),
        .pl_ps_trigack_0(1'b0),
        .pl_ps_trigack_1(1'b0),
        .pl_ps_trigack_2(1'b0),
        .pl_ps_trigack_3(1'b0),
        .pl_ps_trigger_0(1'b0),
        .pl_ps_trigger_1(1'b0),
        .pl_ps_trigger_2(1'b0),
        .pl_ps_trigger_3(1'b0),
        .pl_resetn0(pl_resetn0),
        .pl_resetn1(NLW_inst_pl_resetn1_UNCONNECTED),
        .pl_resetn2(NLW_inst_pl_resetn2_UNCONNECTED),
        .pl_resetn3(NLW_inst_pl_resetn3_UNCONNECTED),
        .pll_aux_refclk_fpd({1'b0,1'b0,1'b0}),
        .pll_aux_refclk_lpd({1'b0,1'b0}),
        .pmu_aib_afifm_fpd_req(NLW_inst_pmu_aib_afifm_fpd_req_UNCONNECTED),
        .pmu_aib_afifm_lpd_req(NLW_inst_pmu_aib_afifm_lpd_req_UNCONNECTED),
        .pmu_error_from_pl({1'b0,1'b0,1'b0,1'b0}),
        .pmu_error_to_pl(NLW_inst_pmu_error_to_pl_UNCONNECTED[46:0]),
        .pmu_pl_gpo(NLW_inst_pmu_pl_gpo_UNCONNECTED[31:0]),
        .ps_pl_evento(NLW_inst_ps_pl_evento_UNCONNECTED),
        .ps_pl_irq_adma_chan(NLW_inst_ps_pl_irq_adma_chan_UNCONNECTED[7:0]),
        .ps_pl_irq_aib_axi(NLW_inst_ps_pl_irq_aib_axi_UNCONNECTED),
        .ps_pl_irq_ams(NLW_inst_ps_pl_irq_ams_UNCONNECTED),
        .ps_pl_irq_apm_fpd(NLW_inst_ps_pl_irq_apm_fpd_UNCONNECTED),
        .ps_pl_irq_apu_comm(NLW_inst_ps_pl_irq_apu_comm_UNCONNECTED[3:0]),
        .ps_pl_irq_apu_cpumnt(NLW_inst_ps_pl_irq_apu_cpumnt_UNCONNECTED[3:0]),
        .ps_pl_irq_apu_cti(NLW_inst_ps_pl_irq_apu_cti_UNCONNECTED[3:0]),
        .ps_pl_irq_apu_exterr(NLW_inst_ps_pl_irq_apu_exterr_UNCONNECTED),
        .ps_pl_irq_apu_l2err(NLW_inst_ps_pl_irq_apu_l2err_UNCONNECTED),
        .ps_pl_irq_apu_pmu(NLW_inst_ps_pl_irq_apu_pmu_UNCONNECTED[3:0]),
        .ps_pl_irq_apu_regs(NLW_inst_ps_pl_irq_apu_regs_UNCONNECTED),
        .ps_pl_irq_atb_err_lpd(NLW_inst_ps_pl_irq_atb_err_lpd_UNCONNECTED),
        .ps_pl_irq_can0(NLW_inst_ps_pl_irq_can0_UNCONNECTED),
        .ps_pl_irq_can1(NLW_inst_ps_pl_irq_can1_UNCONNECTED),
        .ps_pl_irq_clkmon(NLW_inst_ps_pl_irq_clkmon_UNCONNECTED),
        .ps_pl_irq_csu(NLW_inst_ps_pl_irq_csu_UNCONNECTED),
        .ps_pl_irq_csu_dma(NLW_inst_ps_pl_irq_csu_dma_UNCONNECTED),
        .ps_pl_irq_csu_pmu_wdt(NLW_inst_ps_pl_irq_csu_pmu_wdt_UNCONNECTED),
        .ps_pl_irq_ddr_ss(NLW_inst_ps_pl_irq_ddr_ss_UNCONNECTED),
        .ps_pl_irq_dpdma(NLW_inst_ps_pl_irq_dpdma_UNCONNECTED),
        .ps_pl_irq_dport(NLW_inst_ps_pl_irq_dport_UNCONNECTED),
        .ps_pl_irq_efuse(NLW_inst_ps_pl_irq_efuse_UNCONNECTED),
        .ps_pl_irq_enet0(NLW_inst_ps_pl_irq_enet0_UNCONNECTED),
        .ps_pl_irq_enet0_wake(NLW_inst_ps_pl_irq_enet0_wake_UNCONNECTED),
        .ps_pl_irq_enet1(NLW_inst_ps_pl_irq_enet1_UNCONNECTED),
        .ps_pl_irq_enet1_wake(NLW_inst_ps_pl_irq_enet1_wake_UNCONNECTED),
        .ps_pl_irq_enet2(NLW_inst_ps_pl_irq_enet2_UNCONNECTED),
        .ps_pl_irq_enet2_wake(NLW_inst_ps_pl_irq_enet2_wake_UNCONNECTED),
        .ps_pl_irq_enet3(NLW_inst_ps_pl_irq_enet3_UNCONNECTED),
        .ps_pl_irq_enet3_wake(NLW_inst_ps_pl_irq_enet3_wake_UNCONNECTED),
        .ps_pl_irq_fp_wdt(NLW_inst_ps_pl_irq_fp_wdt_UNCONNECTED),
        .ps_pl_irq_fpd_apb_int(NLW_inst_ps_pl_irq_fpd_apb_int_UNCONNECTED),
        .ps_pl_irq_fpd_atb_error(NLW_inst_ps_pl_irq_fpd_atb_error_UNCONNECTED),
        .ps_pl_irq_gdma_chan(NLW_inst_ps_pl_irq_gdma_chan_UNCONNECTED[7:0]),
        .ps_pl_irq_gpio(NLW_inst_ps_pl_irq_gpio_UNCONNECTED),
        .ps_pl_irq_gpu(NLW_inst_ps_pl_irq_gpu_UNCONNECTED),
        .ps_pl_irq_i2c0(NLW_inst_ps_pl_irq_i2c0_UNCONNECTED),
        .ps_pl_irq_i2c1(NLW_inst_ps_pl_irq_i2c1_UNCONNECTED),
        .ps_pl_irq_intf_fpd_smmu(NLW_inst_ps_pl_irq_intf_fpd_smmu_UNCONNECTED),
        .ps_pl_irq_intf_ppd_cci(NLW_inst_ps_pl_irq_intf_ppd_cci_UNCONNECTED),
        .ps_pl_irq_ipi_channel0(NLW_inst_ps_pl_irq_ipi_channel0_UNCONNECTED),
        .ps_pl_irq_ipi_channel1(NLW_inst_ps_pl_irq_ipi_channel1_UNCONNECTED),
        .ps_pl_irq_ipi_channel10(NLW_inst_ps_pl_irq_ipi_channel10_UNCONNECTED),
        .ps_pl_irq_ipi_channel2(NLW_inst_ps_pl_irq_ipi_channel2_UNCONNECTED),
        .ps_pl_irq_ipi_channel7(NLW_inst_ps_pl_irq_ipi_channel7_UNCONNECTED),
        .ps_pl_irq_ipi_channel8(NLW_inst_ps_pl_irq_ipi_channel8_UNCONNECTED),
        .ps_pl_irq_ipi_channel9(NLW_inst_ps_pl_irq_ipi_channel9_UNCONNECTED),
        .ps_pl_irq_lp_wdt(NLW_inst_ps_pl_irq_lp_wdt_UNCONNECTED),
        .ps_pl_irq_lpd_apb_intr(NLW_inst_ps_pl_irq_lpd_apb_intr_UNCONNECTED),
        .ps_pl_irq_lpd_apm(NLW_inst_ps_pl_irq_lpd_apm_UNCONNECTED),
        .ps_pl_irq_nand(NLW_inst_ps_pl_irq_nand_UNCONNECTED),
        .ps_pl_irq_ocm_error(NLW_inst_ps_pl_irq_ocm_error_UNCONNECTED),
        .ps_pl_irq_pcie_dma(NLW_inst_ps_pl_irq_pcie_dma_UNCONNECTED),
        .ps_pl_irq_pcie_legacy(NLW_inst_ps_pl_irq_pcie_legacy_UNCONNECTED),
        .ps_pl_irq_pcie_msc(NLW_inst_ps_pl_irq_pcie_msc_UNCONNECTED),
        .ps_pl_irq_pcie_msi(NLW_inst_ps_pl_irq_pcie_msi_UNCONNECTED[1:0]),
        .ps_pl_irq_qspi(NLW_inst_ps_pl_irq_qspi_UNCONNECTED),
        .ps_pl_irq_r5_core0_ecc_error(NLW_inst_ps_pl_irq_r5_core0_ecc_error_UNCONNECTED),
        .ps_pl_irq_r5_core1_ecc_error(NLW_inst_ps_pl_irq_r5_core1_ecc_error_UNCONNECTED),
        .ps_pl_irq_rpu_pm(NLW_inst_ps_pl_irq_rpu_pm_UNCONNECTED[1:0]),
        .ps_pl_irq_rtc_alaram(NLW_inst_ps_pl_irq_rtc_alaram_UNCONNECTED),
        .ps_pl_irq_rtc_seconds(NLW_inst_ps_pl_irq_rtc_seconds_UNCONNECTED),
        .ps_pl_irq_sata(NLW_inst_ps_pl_irq_sata_UNCONNECTED),
        .ps_pl_irq_sdio0(NLW_inst_ps_pl_irq_sdio0_UNCONNECTED),
        .ps_pl_irq_sdio0_wake(NLW_inst_ps_pl_irq_sdio0_wake_UNCONNECTED),
        .ps_pl_irq_sdio1(NLW_inst_ps_pl_irq_sdio1_UNCONNECTED),
        .ps_pl_irq_sdio1_wake(NLW_inst_ps_pl_irq_sdio1_wake_UNCONNECTED),
        .ps_pl_irq_spi0(NLW_inst_ps_pl_irq_spi0_UNCONNECTED),
        .ps_pl_irq_spi1(NLW_inst_ps_pl_irq_spi1_UNCONNECTED),
        .ps_pl_irq_ttc0_0(NLW_inst_ps_pl_irq_ttc0_0_UNCONNECTED),
        .ps_pl_irq_ttc0_1(NLW_inst_ps_pl_irq_ttc0_1_UNCONNECTED),
        .ps_pl_irq_ttc0_2(NLW_inst_ps_pl_irq_ttc0_2_UNCONNECTED),
        .ps_pl_irq_ttc1_0(NLW_inst_ps_pl_irq_ttc1_0_UNCONNECTED),
        .ps_pl_irq_ttc1_1(NLW_inst_ps_pl_irq_ttc1_1_UNCONNECTED),
        .ps_pl_irq_ttc1_2(NLW_inst_ps_pl_irq_ttc1_2_UNCONNECTED),
        .ps_pl_irq_ttc2_0(NLW_inst_ps_pl_irq_ttc2_0_UNCONNECTED),
        .ps_pl_irq_ttc2_1(NLW_inst_ps_pl_irq_ttc2_1_UNCONNECTED),
        .ps_pl_irq_ttc2_2(NLW_inst_ps_pl_irq_ttc2_2_UNCONNECTED),
        .ps_pl_irq_ttc3_0(NLW_inst_ps_pl_irq_ttc3_0_UNCONNECTED),
        .ps_pl_irq_ttc3_1(NLW_inst_ps_pl_irq_ttc3_1_UNCONNECTED),
        .ps_pl_irq_ttc3_2(NLW_inst_ps_pl_irq_ttc3_2_UNCONNECTED),
        .ps_pl_irq_uart0(NLW_inst_ps_pl_irq_uart0_UNCONNECTED),
        .ps_pl_irq_uart1(NLW_inst_ps_pl_irq_uart1_UNCONNECTED),
        .ps_pl_irq_usb3_0_endpoint(NLW_inst_ps_pl_irq_usb3_0_endpoint_UNCONNECTED[3:0]),
        .ps_pl_irq_usb3_0_otg(NLW_inst_ps_pl_irq_usb3_0_otg_UNCONNECTED),
        .ps_pl_irq_usb3_0_pmu_wakeup(NLW_inst_ps_pl_irq_usb3_0_pmu_wakeup_UNCONNECTED[1:0]),
        .ps_pl_irq_usb3_1_endpoint(NLW_inst_ps_pl_irq_usb3_1_endpoint_UNCONNECTED[3:0]),
        .ps_pl_irq_usb3_1_otg(NLW_inst_ps_pl_irq_usb3_1_otg_UNCONNECTED),
        .ps_pl_irq_xmpu_fpd(NLW_inst_ps_pl_irq_xmpu_fpd_UNCONNECTED),
        .ps_pl_irq_xmpu_lpd(NLW_inst_ps_pl_irq_xmpu_lpd_UNCONNECTED),
        .ps_pl_standbywfe(NLW_inst_ps_pl_standbywfe_UNCONNECTED[3:0]),
        .ps_pl_standbywfi(NLW_inst_ps_pl_standbywfi_UNCONNECTED[3:0]),
        .ps_pl_tracectl(NLW_inst_ps_pl_tracectl_UNCONNECTED),
        .ps_pl_tracedata(NLW_inst_ps_pl_tracedata_UNCONNECTED[31:0]),
        .ps_pl_trigack_0(NLW_inst_ps_pl_trigack_0_UNCONNECTED),
        .ps_pl_trigack_1(NLW_inst_ps_pl_trigack_1_UNCONNECTED),
        .ps_pl_trigack_2(NLW_inst_ps_pl_trigack_2_UNCONNECTED),
        .ps_pl_trigack_3(NLW_inst_ps_pl_trigack_3_UNCONNECTED),
        .ps_pl_trigger_0(NLW_inst_ps_pl_trigger_0_UNCONNECTED),
        .ps_pl_trigger_1(NLW_inst_ps_pl_trigger_1_UNCONNECTED),
        .ps_pl_trigger_2(NLW_inst_ps_pl_trigger_2_UNCONNECTED),
        .ps_pl_trigger_3(NLW_inst_ps_pl_trigger_3_UNCONNECTED),
        .pstp_pl_clk({1'b0,1'b0,1'b0,1'b0}),
        .pstp_pl_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .pstp_pl_out(NLW_inst_pstp_pl_out_UNCONNECTED[31:0]),
        .pstp_pl_ts({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rpu_eventi0(1'b0),
        .rpu_eventi1(1'b0),
        .rpu_evento0(NLW_inst_rpu_evento0_UNCONNECTED),
        .rpu_evento1(NLW_inst_rpu_evento1_UNCONNECTED),
        .sacefpd_acaddr(NLW_inst_sacefpd_acaddr_UNCONNECTED[43:0]),
        .sacefpd_aclk(1'b0),
        .sacefpd_acprot(NLW_inst_sacefpd_acprot_UNCONNECTED[2:0]),
        .sacefpd_acready(1'b0),
        .sacefpd_acsnoop(NLW_inst_sacefpd_acsnoop_UNCONNECTED[3:0]),
        .sacefpd_acvalid(NLW_inst_sacefpd_acvalid_UNCONNECTED),
        .sacefpd_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_arbar({1'b0,1'b0}),
        .sacefpd_arburst({1'b0,1'b0}),
        .sacefpd_arcache({1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_ardomain({1'b0,1'b0}),
        .sacefpd_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_arlock(1'b0),
        .sacefpd_arprot({1'b0,1'b0,1'b0}),
        .sacefpd_arqos({1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_arready(NLW_inst_sacefpd_arready_UNCONNECTED),
        .sacefpd_arregion({1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_arsize({1'b0,1'b0,1'b0}),
        .sacefpd_arsnoop({1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_aruser({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_arvalid(1'b0),
        .sacefpd_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_awbar({1'b0,1'b0}),
        .sacefpd_awburst({1'b0,1'b0}),
        .sacefpd_awcache({1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_awdomain({1'b0,1'b0}),
        .sacefpd_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_awlock(1'b0),
        .sacefpd_awprot({1'b0,1'b0,1'b0}),
        .sacefpd_awqos({1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_awready(NLW_inst_sacefpd_awready_UNCONNECTED),
        .sacefpd_awregion({1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_awsize({1'b0,1'b0,1'b0}),
        .sacefpd_awsnoop({1'b0,1'b0,1'b0}),
        .sacefpd_awuser({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_awvalid(1'b0),
        .sacefpd_bid(NLW_inst_sacefpd_bid_UNCONNECTED[5:0]),
        .sacefpd_bready(1'b0),
        .sacefpd_bresp(NLW_inst_sacefpd_bresp_UNCONNECTED[1:0]),
        .sacefpd_buser(NLW_inst_sacefpd_buser_UNCONNECTED),
        .sacefpd_bvalid(NLW_inst_sacefpd_bvalid_UNCONNECTED),
        .sacefpd_cddata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_cdlast(1'b0),
        .sacefpd_cdready(NLW_inst_sacefpd_cdready_UNCONNECTED),
        .sacefpd_cdvalid(1'b0),
        .sacefpd_crready(NLW_inst_sacefpd_crready_UNCONNECTED),
        .sacefpd_crresp({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_crvalid(1'b0),
        .sacefpd_rack(1'b0),
        .sacefpd_rdata(NLW_inst_sacefpd_rdata_UNCONNECTED[127:0]),
        .sacefpd_rid(NLW_inst_sacefpd_rid_UNCONNECTED[5:0]),
        .sacefpd_rlast(NLW_inst_sacefpd_rlast_UNCONNECTED),
        .sacefpd_rready(1'b0),
        .sacefpd_rresp(NLW_inst_sacefpd_rresp_UNCONNECTED[3:0]),
        .sacefpd_ruser(NLW_inst_sacefpd_ruser_UNCONNECTED),
        .sacefpd_rvalid(NLW_inst_sacefpd_rvalid_UNCONNECTED),
        .sacefpd_wack(1'b0),
        .sacefpd_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_wlast(1'b0),
        .sacefpd_wready(NLW_inst_sacefpd_wready_UNCONNECTED),
        .sacefpd_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .sacefpd_wuser(1'b0),
        .sacefpd_wvalid(1'b0),
        .saxi_lpd_aclk(1'b0),
        .saxi_lpd_rclk(1'b0),
        .saxi_lpd_wclk(1'b0),
        .saxiacp_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_arburst({1'b0,1'b0}),
        .saxiacp_arcache({1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_arid({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_arlock(1'b0),
        .saxiacp_arprot({1'b0,1'b0,1'b0}),
        .saxiacp_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_arready(NLW_inst_saxiacp_arready_UNCONNECTED),
        .saxiacp_arsize({1'b0,1'b0,1'b0}),
        .saxiacp_aruser({1'b0,1'b0}),
        .saxiacp_arvalid(1'b0),
        .saxiacp_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_awburst({1'b0,1'b0}),
        .saxiacp_awcache({1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_awid({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_awlock(1'b0),
        .saxiacp_awprot({1'b0,1'b0,1'b0}),
        .saxiacp_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_awready(NLW_inst_saxiacp_awready_UNCONNECTED),
        .saxiacp_awsize({1'b0,1'b0,1'b0}),
        .saxiacp_awuser({1'b0,1'b0}),
        .saxiacp_awvalid(1'b0),
        .saxiacp_bid(NLW_inst_saxiacp_bid_UNCONNECTED[4:0]),
        .saxiacp_bready(1'b0),
        .saxiacp_bresp(NLW_inst_saxiacp_bresp_UNCONNECTED[1:0]),
        .saxiacp_bvalid(NLW_inst_saxiacp_bvalid_UNCONNECTED),
        .saxiacp_fpd_aclk(1'b0),
        .saxiacp_rdata(NLW_inst_saxiacp_rdata_UNCONNECTED[127:0]),
        .saxiacp_rid(NLW_inst_saxiacp_rid_UNCONNECTED[4:0]),
        .saxiacp_rlast(NLW_inst_saxiacp_rlast_UNCONNECTED),
        .saxiacp_rready(1'b0),
        .saxiacp_rresp(NLW_inst_saxiacp_rresp_UNCONNECTED[1:0]),
        .saxiacp_rvalid(NLW_inst_saxiacp_rvalid_UNCONNECTED),
        .saxiacp_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_wlast(1'b0),
        .saxiacp_wready(NLW_inst_saxiacp_wready_UNCONNECTED),
        .saxiacp_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxiacp_wvalid(1'b0),
        .saxigp0_araddr(saxigp0_araddr),
        .saxigp0_arburst(saxigp0_arburst),
        .saxigp0_arcache(saxigp0_arcache),
        .saxigp0_arid(saxigp0_arid),
        .saxigp0_arlen(saxigp0_arlen),
        .saxigp0_arlock(saxigp0_arlock),
        .saxigp0_arprot(saxigp0_arprot),
        .saxigp0_arqos(saxigp0_arqos),
        .saxigp0_arready(saxigp0_arready),
        .saxigp0_arsize(saxigp0_arsize),
        .saxigp0_aruser(saxigp0_aruser),
        .saxigp0_arvalid(saxigp0_arvalid),
        .saxigp0_awaddr(saxigp0_awaddr),
        .saxigp0_awburst(saxigp0_awburst),
        .saxigp0_awcache(saxigp0_awcache),
        .saxigp0_awid(saxigp0_awid),
        .saxigp0_awlen(saxigp0_awlen),
        .saxigp0_awlock(saxigp0_awlock),
        .saxigp0_awprot(saxigp0_awprot),
        .saxigp0_awqos(saxigp0_awqos),
        .saxigp0_awready(saxigp0_awready),
        .saxigp0_awsize(saxigp0_awsize),
        .saxigp0_awuser(saxigp0_awuser),
        .saxigp0_awvalid(saxigp0_awvalid),
        .saxigp0_bid(saxigp0_bid),
        .saxigp0_bready(saxigp0_bready),
        .saxigp0_bresp(saxigp0_bresp),
        .saxigp0_bvalid(saxigp0_bvalid),
        .saxigp0_racount(NLW_inst_saxigp0_racount_UNCONNECTED[3:0]),
        .saxigp0_rcount(NLW_inst_saxigp0_rcount_UNCONNECTED[7:0]),
        .saxigp0_rdata(saxigp0_rdata),
        .saxigp0_rid(saxigp0_rid),
        .saxigp0_rlast(saxigp0_rlast),
        .saxigp0_rready(saxigp0_rready),
        .saxigp0_rresp(saxigp0_rresp),
        .saxigp0_rvalid(saxigp0_rvalid),
        .saxigp0_wacount(NLW_inst_saxigp0_wacount_UNCONNECTED[3:0]),
        .saxigp0_wcount(NLW_inst_saxigp0_wcount_UNCONNECTED[7:0]),
        .saxigp0_wdata(saxigp0_wdata),
        .saxigp0_wlast(saxigp0_wlast),
        .saxigp0_wready(saxigp0_wready),
        .saxigp0_wstrb(saxigp0_wstrb),
        .saxigp0_wvalid(saxigp0_wvalid),
        .saxigp1_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_arburst({1'b0,1'b0}),
        .saxigp1_arcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_arlock(1'b0),
        .saxigp1_arprot({1'b0,1'b0,1'b0}),
        .saxigp1_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_arready(NLW_inst_saxigp1_arready_UNCONNECTED),
        .saxigp1_arsize({1'b0,1'b0,1'b0}),
        .saxigp1_aruser(1'b0),
        .saxigp1_arvalid(1'b0),
        .saxigp1_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_awburst({1'b0,1'b0}),
        .saxigp1_awcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_awlock(1'b0),
        .saxigp1_awprot({1'b0,1'b0,1'b0}),
        .saxigp1_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_awready(NLW_inst_saxigp1_awready_UNCONNECTED),
        .saxigp1_awsize({1'b0,1'b0,1'b0}),
        .saxigp1_awuser(1'b0),
        .saxigp1_awvalid(1'b0),
        .saxigp1_bid(NLW_inst_saxigp1_bid_UNCONNECTED[5:0]),
        .saxigp1_bready(1'b0),
        .saxigp1_bresp(NLW_inst_saxigp1_bresp_UNCONNECTED[1:0]),
        .saxigp1_bvalid(NLW_inst_saxigp1_bvalid_UNCONNECTED),
        .saxigp1_racount(NLW_inst_saxigp1_racount_UNCONNECTED[3:0]),
        .saxigp1_rcount(NLW_inst_saxigp1_rcount_UNCONNECTED[7:0]),
        .saxigp1_rdata(NLW_inst_saxigp1_rdata_UNCONNECTED[127:0]),
        .saxigp1_rid(NLW_inst_saxigp1_rid_UNCONNECTED[5:0]),
        .saxigp1_rlast(NLW_inst_saxigp1_rlast_UNCONNECTED),
        .saxigp1_rready(1'b0),
        .saxigp1_rresp(NLW_inst_saxigp1_rresp_UNCONNECTED[1:0]),
        .saxigp1_rvalid(NLW_inst_saxigp1_rvalid_UNCONNECTED),
        .saxigp1_wacount(NLW_inst_saxigp1_wacount_UNCONNECTED[3:0]),
        .saxigp1_wcount(NLW_inst_saxigp1_wcount_UNCONNECTED[7:0]),
        .saxigp1_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_wlast(1'b0),
        .saxigp1_wready(NLW_inst_saxigp1_wready_UNCONNECTED),
        .saxigp1_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp1_wvalid(1'b0),
        .saxigp2_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_arburst({1'b0,1'b0}),
        .saxigp2_arcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_arlock(1'b0),
        .saxigp2_arprot({1'b0,1'b0,1'b0}),
        .saxigp2_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_arready(NLW_inst_saxigp2_arready_UNCONNECTED),
        .saxigp2_arsize({1'b0,1'b0,1'b0}),
        .saxigp2_aruser(1'b0),
        .saxigp2_arvalid(1'b0),
        .saxigp2_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_awburst({1'b0,1'b0}),
        .saxigp2_awcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_awlock(1'b0),
        .saxigp2_awprot({1'b0,1'b0,1'b0}),
        .saxigp2_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_awready(NLW_inst_saxigp2_awready_UNCONNECTED),
        .saxigp2_awsize({1'b0,1'b0,1'b0}),
        .saxigp2_awuser(1'b0),
        .saxigp2_awvalid(1'b0),
        .saxigp2_bid(NLW_inst_saxigp2_bid_UNCONNECTED[5:0]),
        .saxigp2_bready(1'b0),
        .saxigp2_bresp(NLW_inst_saxigp2_bresp_UNCONNECTED[1:0]),
        .saxigp2_bvalid(NLW_inst_saxigp2_bvalid_UNCONNECTED),
        .saxigp2_racount(NLW_inst_saxigp2_racount_UNCONNECTED[3:0]),
        .saxigp2_rcount(NLW_inst_saxigp2_rcount_UNCONNECTED[7:0]),
        .saxigp2_rdata(NLW_inst_saxigp2_rdata_UNCONNECTED[127:0]),
        .saxigp2_rid(NLW_inst_saxigp2_rid_UNCONNECTED[5:0]),
        .saxigp2_rlast(NLW_inst_saxigp2_rlast_UNCONNECTED),
        .saxigp2_rready(1'b0),
        .saxigp2_rresp(NLW_inst_saxigp2_rresp_UNCONNECTED[1:0]),
        .saxigp2_rvalid(NLW_inst_saxigp2_rvalid_UNCONNECTED),
        .saxigp2_wacount(NLW_inst_saxigp2_wacount_UNCONNECTED[3:0]),
        .saxigp2_wcount(NLW_inst_saxigp2_wcount_UNCONNECTED[7:0]),
        .saxigp2_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_wlast(1'b0),
        .saxigp2_wready(NLW_inst_saxigp2_wready_UNCONNECTED),
        .saxigp2_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp2_wvalid(1'b0),
        .saxigp3_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_arburst({1'b0,1'b0}),
        .saxigp3_arcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_arlock(1'b0),
        .saxigp3_arprot({1'b0,1'b0,1'b0}),
        .saxigp3_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_arready(NLW_inst_saxigp3_arready_UNCONNECTED),
        .saxigp3_arsize({1'b0,1'b0,1'b0}),
        .saxigp3_aruser(1'b0),
        .saxigp3_arvalid(1'b0),
        .saxigp3_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_awburst({1'b0,1'b0}),
        .saxigp3_awcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_awlock(1'b0),
        .saxigp3_awprot({1'b0,1'b0,1'b0}),
        .saxigp3_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_awready(NLW_inst_saxigp3_awready_UNCONNECTED),
        .saxigp3_awsize({1'b0,1'b0,1'b0}),
        .saxigp3_awuser(1'b0),
        .saxigp3_awvalid(1'b0),
        .saxigp3_bid(NLW_inst_saxigp3_bid_UNCONNECTED[5:0]),
        .saxigp3_bready(1'b0),
        .saxigp3_bresp(NLW_inst_saxigp3_bresp_UNCONNECTED[1:0]),
        .saxigp3_bvalid(NLW_inst_saxigp3_bvalid_UNCONNECTED),
        .saxigp3_racount(NLW_inst_saxigp3_racount_UNCONNECTED[3:0]),
        .saxigp3_rcount(NLW_inst_saxigp3_rcount_UNCONNECTED[7:0]),
        .saxigp3_rdata(NLW_inst_saxigp3_rdata_UNCONNECTED[127:0]),
        .saxigp3_rid(NLW_inst_saxigp3_rid_UNCONNECTED[5:0]),
        .saxigp3_rlast(NLW_inst_saxigp3_rlast_UNCONNECTED),
        .saxigp3_rready(1'b0),
        .saxigp3_rresp(NLW_inst_saxigp3_rresp_UNCONNECTED[1:0]),
        .saxigp3_rvalid(NLW_inst_saxigp3_rvalid_UNCONNECTED),
        .saxigp3_wacount(NLW_inst_saxigp3_wacount_UNCONNECTED[3:0]),
        .saxigp3_wcount(NLW_inst_saxigp3_wcount_UNCONNECTED[7:0]),
        .saxigp3_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_wlast(1'b0),
        .saxigp3_wready(NLW_inst_saxigp3_wready_UNCONNECTED),
        .saxigp3_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp3_wvalid(1'b0),
        .saxigp4_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_arburst({1'b0,1'b0}),
        .saxigp4_arcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_arlock(1'b0),
        .saxigp4_arprot({1'b0,1'b0,1'b0}),
        .saxigp4_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_arready(NLW_inst_saxigp4_arready_UNCONNECTED),
        .saxigp4_arsize({1'b0,1'b0,1'b0}),
        .saxigp4_aruser(1'b0),
        .saxigp4_arvalid(1'b0),
        .saxigp4_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_awburst({1'b0,1'b0}),
        .saxigp4_awcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_awlock(1'b0),
        .saxigp4_awprot({1'b0,1'b0,1'b0}),
        .saxigp4_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_awready(NLW_inst_saxigp4_awready_UNCONNECTED),
        .saxigp4_awsize({1'b0,1'b0,1'b0}),
        .saxigp4_awuser(1'b0),
        .saxigp4_awvalid(1'b0),
        .saxigp4_bid(NLW_inst_saxigp4_bid_UNCONNECTED[5:0]),
        .saxigp4_bready(1'b0),
        .saxigp4_bresp(NLW_inst_saxigp4_bresp_UNCONNECTED[1:0]),
        .saxigp4_bvalid(NLW_inst_saxigp4_bvalid_UNCONNECTED),
        .saxigp4_racount(NLW_inst_saxigp4_racount_UNCONNECTED[3:0]),
        .saxigp4_rcount(NLW_inst_saxigp4_rcount_UNCONNECTED[7:0]),
        .saxigp4_rdata(NLW_inst_saxigp4_rdata_UNCONNECTED[127:0]),
        .saxigp4_rid(NLW_inst_saxigp4_rid_UNCONNECTED[5:0]),
        .saxigp4_rlast(NLW_inst_saxigp4_rlast_UNCONNECTED),
        .saxigp4_rready(1'b0),
        .saxigp4_rresp(NLW_inst_saxigp4_rresp_UNCONNECTED[1:0]),
        .saxigp4_rvalid(NLW_inst_saxigp4_rvalid_UNCONNECTED),
        .saxigp4_wacount(NLW_inst_saxigp4_wacount_UNCONNECTED[3:0]),
        .saxigp4_wcount(NLW_inst_saxigp4_wcount_UNCONNECTED[7:0]),
        .saxigp4_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_wlast(1'b0),
        .saxigp4_wready(NLW_inst_saxigp4_wready_UNCONNECTED),
        .saxigp4_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp4_wvalid(1'b0),
        .saxigp5_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_arburst({1'b0,1'b0}),
        .saxigp5_arcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_arlock(1'b0),
        .saxigp5_arprot({1'b0,1'b0,1'b0}),
        .saxigp5_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_arready(NLW_inst_saxigp5_arready_UNCONNECTED),
        .saxigp5_arsize({1'b0,1'b0,1'b0}),
        .saxigp5_aruser(1'b0),
        .saxigp5_arvalid(1'b0),
        .saxigp5_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_awburst({1'b0,1'b0}),
        .saxigp5_awcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_awlock(1'b0),
        .saxigp5_awprot({1'b0,1'b0,1'b0}),
        .saxigp5_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_awready(NLW_inst_saxigp5_awready_UNCONNECTED),
        .saxigp5_awsize({1'b0,1'b0,1'b0}),
        .saxigp5_awuser(1'b0),
        .saxigp5_awvalid(1'b0),
        .saxigp5_bid(NLW_inst_saxigp5_bid_UNCONNECTED[5:0]),
        .saxigp5_bready(1'b0),
        .saxigp5_bresp(NLW_inst_saxigp5_bresp_UNCONNECTED[1:0]),
        .saxigp5_bvalid(NLW_inst_saxigp5_bvalid_UNCONNECTED),
        .saxigp5_racount(NLW_inst_saxigp5_racount_UNCONNECTED[3:0]),
        .saxigp5_rcount(NLW_inst_saxigp5_rcount_UNCONNECTED[7:0]),
        .saxigp5_rdata(NLW_inst_saxigp5_rdata_UNCONNECTED[127:0]),
        .saxigp5_rid(NLW_inst_saxigp5_rid_UNCONNECTED[5:0]),
        .saxigp5_rlast(NLW_inst_saxigp5_rlast_UNCONNECTED),
        .saxigp5_rready(1'b0),
        .saxigp5_rresp(NLW_inst_saxigp5_rresp_UNCONNECTED[1:0]),
        .saxigp5_rvalid(NLW_inst_saxigp5_rvalid_UNCONNECTED),
        .saxigp5_wacount(NLW_inst_saxigp5_wacount_UNCONNECTED[3:0]),
        .saxigp5_wcount(NLW_inst_saxigp5_wcount_UNCONNECTED[7:0]),
        .saxigp5_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_wlast(1'b0),
        .saxigp5_wready(NLW_inst_saxigp5_wready_UNCONNECTED),
        .saxigp5_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp5_wvalid(1'b0),
        .saxigp6_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_arburst({1'b0,1'b0}),
        .saxigp6_arcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_arid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_arlock(1'b0),
        .saxigp6_arprot({1'b0,1'b0,1'b0}),
        .saxigp6_arqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_arready(NLW_inst_saxigp6_arready_UNCONNECTED),
        .saxigp6_arsize({1'b0,1'b0,1'b0}),
        .saxigp6_aruser(1'b0),
        .saxigp6_arvalid(1'b0),
        .saxigp6_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_awburst({1'b0,1'b0}),
        .saxigp6_awcache({1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_awid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_awlock(1'b0),
        .saxigp6_awprot({1'b0,1'b0,1'b0}),
        .saxigp6_awqos({1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_awready(NLW_inst_saxigp6_awready_UNCONNECTED),
        .saxigp6_awsize({1'b0,1'b0,1'b0}),
        .saxigp6_awuser(1'b0),
        .saxigp6_awvalid(1'b0),
        .saxigp6_bid(NLW_inst_saxigp6_bid_UNCONNECTED[5:0]),
        .saxigp6_bready(1'b0),
        .saxigp6_bresp(NLW_inst_saxigp6_bresp_UNCONNECTED[1:0]),
        .saxigp6_bvalid(NLW_inst_saxigp6_bvalid_UNCONNECTED),
        .saxigp6_racount(NLW_inst_saxigp6_racount_UNCONNECTED[3:0]),
        .saxigp6_rcount(NLW_inst_saxigp6_rcount_UNCONNECTED[7:0]),
        .saxigp6_rdata(NLW_inst_saxigp6_rdata_UNCONNECTED[127:0]),
        .saxigp6_rid(NLW_inst_saxigp6_rid_UNCONNECTED[5:0]),
        .saxigp6_rlast(NLW_inst_saxigp6_rlast_UNCONNECTED),
        .saxigp6_rready(1'b0),
        .saxigp6_rresp(NLW_inst_saxigp6_rresp_UNCONNECTED[1:0]),
        .saxigp6_rvalid(NLW_inst_saxigp6_rvalid_UNCONNECTED),
        .saxigp6_wacount(NLW_inst_saxigp6_wacount_UNCONNECTED[3:0]),
        .saxigp6_wcount(NLW_inst_saxigp6_wcount_UNCONNECTED[7:0]),
        .saxigp6_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_wlast(1'b0),
        .saxigp6_wready(NLW_inst_saxigp6_wready_UNCONNECTED),
        .saxigp6_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .saxigp6_wvalid(1'b0),
        .saxihp0_fpd_aclk(1'b0),
        .saxihp0_fpd_rclk(1'b0),
        .saxihp0_fpd_wclk(1'b0),
        .saxihp1_fpd_aclk(1'b0),
        .saxihp1_fpd_rclk(1'b0),
        .saxihp1_fpd_wclk(1'b0),
        .saxihp2_fpd_aclk(1'b0),
        .saxihp2_fpd_rclk(1'b0),
        .saxihp2_fpd_wclk(1'b0),
        .saxihp3_fpd_aclk(1'b0),
        .saxihp3_fpd_rclk(1'b0),
        .saxihp3_fpd_wclk(1'b0),
        .saxihpc0_fpd_aclk(saxihpc0_fpd_aclk),
        .saxihpc0_fpd_rclk(1'b0),
        .saxihpc0_fpd_wclk(1'b0),
        .saxihpc1_fpd_aclk(1'b0),
        .saxihpc1_fpd_rclk(1'b0),
        .saxihpc1_fpd_wclk(1'b0),
        .stm_event({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .test_adc2_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .test_adc_clk({1'b0,1'b0,1'b0,1'b0}),
        .test_adc_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .test_adc_out(NLW_inst_test_adc_out_UNCONNECTED[19:0]),
        .test_ams_osc(NLW_inst_test_ams_osc_UNCONNECTED[7:0]),
        .test_bscan_ac_mode(1'b0),
        .test_bscan_ac_test(1'b0),
        .test_bscan_clockdr(1'b0),
        .test_bscan_en_n(1'b0),
        .test_bscan_extest(1'b0),
        .test_bscan_init_memory(1'b0),
        .test_bscan_intest(1'b0),
        .test_bscan_misr_jtag_load(1'b0),
        .test_bscan_mode_c(1'b0),
        .test_bscan_reset_tap_b(1'b0),
        .test_bscan_shiftdr(1'b0),
        .test_bscan_tdi(1'b0),
        .test_bscan_tdo(NLW_inst_test_bscan_tdo_UNCONNECTED),
        .test_bscan_updatedr(1'b0),
        .test_char_mode_fpd_n(1'b0),
        .test_char_mode_lpd_n(1'b0),
        .test_convst(1'b0),
        .test_daddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .test_db(NLW_inst_test_db_UNCONNECTED[15:0]),
        .test_dclk(1'b0),
        .test_ddr2pl_dcd_skewout(NLW_inst_test_ddr2pl_dcd_skewout_UNCONNECTED),
        .test_den(1'b0),
        .test_di({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .test_do(NLW_inst_test_do_UNCONNECTED[15:0]),
        .test_drdy(NLW_inst_test_drdy_UNCONNECTED),
        .test_dwe(1'b0),
        .test_mon_data(NLW_inst_test_mon_data_UNCONNECTED[15:0]),
        .test_pl2ddr_dcd_sample_pulse(1'b0),
        .test_pl_pll_lock_out(NLW_inst_test_pl_pll_lock_out_UNCONNECTED[4:0]),
        .test_pl_scan_chopper_si(1'b0),
        .test_pl_scan_chopper_so(NLW_inst_test_pl_scan_chopper_so_UNCONNECTED),
        .test_pl_scan_chopper_trig(1'b0),
        .test_pl_scan_clk0(1'b0),
        .test_pl_scan_clk1(1'b0),
        .test_pl_scan_edt_clk(1'b0),
        .test_pl_scan_edt_in_apu(1'b0),
        .test_pl_scan_edt_in_cpu(1'b0),
        .test_pl_scan_edt_in_ddr({1'b0,1'b0,1'b0,1'b0}),
        .test_pl_scan_edt_in_fp({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .test_pl_scan_edt_in_gpu({1'b0,1'b0,1'b0,1'b0}),
        .test_pl_scan_edt_in_lp({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .test_pl_scan_edt_in_usb3({1'b0,1'b0}),
        .test_pl_scan_edt_out_apu(NLW_inst_test_pl_scan_edt_out_apu_UNCONNECTED),
        .test_pl_scan_edt_out_cpu0(NLW_inst_test_pl_scan_edt_out_cpu0_UNCONNECTED),
        .test_pl_scan_edt_out_cpu1(NLW_inst_test_pl_scan_edt_out_cpu1_UNCONNECTED),
        .test_pl_scan_edt_out_cpu2(NLW_inst_test_pl_scan_edt_out_cpu2_UNCONNECTED),
        .test_pl_scan_edt_out_cpu3(NLW_inst_test_pl_scan_edt_out_cpu3_UNCONNECTED),
        .test_pl_scan_edt_out_ddr(NLW_inst_test_pl_scan_edt_out_ddr_UNCONNECTED[3:0]),
        .test_pl_scan_edt_out_fp(NLW_inst_test_pl_scan_edt_out_fp_UNCONNECTED[9:0]),
        .test_pl_scan_edt_out_gpu(NLW_inst_test_pl_scan_edt_out_gpu_UNCONNECTED[3:0]),
        .test_pl_scan_edt_out_lp(NLW_inst_test_pl_scan_edt_out_lp_UNCONNECTED[8:0]),
        .test_pl_scan_edt_out_usb3(NLW_inst_test_pl_scan_edt_out_usb3_UNCONNECTED[1:0]),
        .test_pl_scan_edt_update(1'b0),
        .test_pl_scan_pll_reset(1'b0),
        .test_pl_scan_reset_n(1'b0),
        .test_pl_scan_slcr_config_clk(1'b0),
        .test_pl_scan_slcr_config_rstn(1'b0),
        .test_pl_scan_slcr_config_si(1'b0),
        .test_pl_scan_slcr_config_so(NLW_inst_test_pl_scan_slcr_config_so_UNCONNECTED),
        .test_pl_scan_spare_in0(1'b0),
        .test_pl_scan_spare_in1(1'b0),
        .test_pl_scan_spare_in2(1'b0),
        .test_pl_scan_spare_out0(NLW_inst_test_pl_scan_spare_out0_UNCONNECTED),
        .test_pl_scan_spare_out1(NLW_inst_test_pl_scan_spare_out1_UNCONNECTED),
        .test_pl_scan_wrap_clk(1'b0),
        .test_pl_scan_wrap_ishift(1'b0),
        .test_pl_scan_wrap_oshift(1'b0),
        .test_pl_scanenable(1'b0),
        .test_pl_scanenable_slcr_en(1'b0),
        .test_usb0_funcmux_0_n(1'b0),
        .test_usb0_scanmux_0_n(1'b0),
        .test_usb1_funcmux_0_n(1'b0),
        .test_usb1_scanmux_0_n(1'b0),
        .trace_clk_out(NLW_inst_trace_clk_out_UNCONNECTED),
        .tst_rtc_calibreg_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .tst_rtc_calibreg_out(NLW_inst_tst_rtc_calibreg_out_UNCONNECTED[20:0]),
        .tst_rtc_calibreg_we(1'b0),
        .tst_rtc_clk(1'b0),
        .tst_rtc_disable_bat_op(1'b0),
        .tst_rtc_osc_clk_out(NLW_inst_tst_rtc_osc_clk_out_UNCONNECTED),
        .tst_rtc_osc_cntrl_in({1'b0,1'b0,1'b0,1'b0}),
        .tst_rtc_osc_cntrl_out(NLW_inst_tst_rtc_osc_cntrl_out_UNCONNECTED[3:0]),
        .tst_rtc_osc_cntrl_we(1'b0),
        .tst_rtc_sec_counter_out(NLW_inst_tst_rtc_sec_counter_out_UNCONNECTED[31:0]),
        .tst_rtc_sec_reload(1'b0),
        .tst_rtc_seconds_raw_int(NLW_inst_tst_rtc_seconds_raw_int_UNCONNECTED),
        .tst_rtc_testclock_select_n(1'b0),
        .tst_rtc_testmode_n(1'b0),
        .tst_rtc_tick_counter_out(NLW_inst_tst_rtc_tick_counter_out_UNCONNECTED[15:0]),
        .tst_rtc_timesetreg_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .tst_rtc_timesetreg_out(NLW_inst_tst_rtc_timesetreg_out_UNCONNECTED[31:0]),
        .tst_rtc_timesetreg_we(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
