-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
-- Date        : Mon Jan 11 12:09:55 2021
-- Host        : skie running 64-bit Ubuntu 18.04.5 LTS
-- Command     : write_vhdl -force -mode funcsim
--               /home/jescobedo/repos/juanesp/socs/xilinx-zcu102-xczu9eg/vivado/esp-xilinx-zcu102-xczu9eg.srcs/sources_1/bd/zynqmpsoc/ip/zynqmpsoc_zynq_ultra_ps_e_0_0/zynqmpsoc_zynq_ultra_ps_e_0_0_sim_netlist.vhdl
-- Design      : zynqmpsoc_zynq_ultra_ps_e_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e is
  port (
    maxihpm0_fpd_aclk : in STD_LOGIC;
    dp_video_ref_clk : out STD_LOGIC;
    dp_audio_ref_clk : out STD_LOGIC;
    maxigp0_awid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp0_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp0_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_awlock : out STD_LOGIC;
    maxigp0_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_awvalid : out STD_LOGIC;
    maxigp0_awuser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_awready : in STD_LOGIC;
    maxigp0_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp0_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_wlast : out STD_LOGIC;
    maxigp0_wvalid : out STD_LOGIC;
    maxigp0_wready : in STD_LOGIC;
    maxigp0_bid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_bvalid : in STD_LOGIC;
    maxigp0_bready : out STD_LOGIC;
    maxigp0_arid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp0_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp0_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_arlock : out STD_LOGIC;
    maxigp0_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_arvalid : out STD_LOGIC;
    maxigp0_aruser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_arready : in STD_LOGIC;
    maxigp0_rid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp0_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_rlast : in STD_LOGIC;
    maxigp0_rvalid : in STD_LOGIC;
    maxigp0_rready : out STD_LOGIC;
    maxigp0_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxihpm1_fpd_aclk : in STD_LOGIC;
    maxigp1_awid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp1_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp1_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_awlock : out STD_LOGIC;
    maxigp1_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_awvalid : out STD_LOGIC;
    maxigp1_awuser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_awready : in STD_LOGIC;
    maxigp1_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp1_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_wlast : out STD_LOGIC;
    maxigp1_wvalid : out STD_LOGIC;
    maxigp1_wready : in STD_LOGIC;
    maxigp1_bid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_bvalid : in STD_LOGIC;
    maxigp1_bready : out STD_LOGIC;
    maxigp1_arid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp1_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp1_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_arlock : out STD_LOGIC;
    maxigp1_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_arvalid : out STD_LOGIC;
    maxigp1_aruser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_arready : in STD_LOGIC;
    maxigp1_rid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp1_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_rlast : in STD_LOGIC;
    maxigp1_rvalid : in STD_LOGIC;
    maxigp1_rready : out STD_LOGIC;
    maxigp1_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxihpm0_lpd_aclk : in STD_LOGIC;
    maxigp2_awid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp2_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp2_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_awlock : out STD_LOGIC;
    maxigp2_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp2_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_awvalid : out STD_LOGIC;
    maxigp2_awuser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_awready : in STD_LOGIC;
    maxigp2_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp2_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp2_wlast : out STD_LOGIC;
    maxigp2_wvalid : out STD_LOGIC;
    maxigp2_wready : in STD_LOGIC;
    maxigp2_bid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_bvalid : in STD_LOGIC;
    maxigp2_bready : out STD_LOGIC;
    maxigp2_arid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp2_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp2_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_arlock : out STD_LOGIC;
    maxigp2_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp2_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp2_arvalid : out STD_LOGIC;
    maxigp2_aruser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_arready : in STD_LOGIC;
    maxigp2_rid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp2_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp2_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp2_rlast : in STD_LOGIC;
    maxigp2_rvalid : in STD_LOGIC;
    maxigp2_rready : out STD_LOGIC;
    maxigp2_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp2_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxihpc0_fpd_aclk : in STD_LOGIC;
    saxihpc0_fpd_rclk : in STD_LOGIC;
    saxihpc0_fpd_wclk : in STD_LOGIC;
    saxigp0_aruser : in STD_LOGIC;
    saxigp0_awuser : in STD_LOGIC;
    saxigp0_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp0_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_awlock : in STD_LOGIC;
    saxigp0_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_awvalid : in STD_LOGIC;
    saxigp0_awready : out STD_LOGIC;
    saxigp0_wdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    saxigp0_wstrb : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_wlast : in STD_LOGIC;
    saxigp0_wvalid : in STD_LOGIC;
    saxigp0_wready : out STD_LOGIC;
    saxigp0_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_bvalid : out STD_LOGIC;
    saxigp0_bready : in STD_LOGIC;
    saxigp0_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp0_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_arlock : in STD_LOGIC;
    saxigp0_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_arvalid : in STD_LOGIC;
    saxigp0_arready : out STD_LOGIC;
    saxigp0_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_rdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    saxigp0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_rlast : out STD_LOGIC;
    saxigp0_rvalid : out STD_LOGIC;
    saxigp0_rready : in STD_LOGIC;
    saxigp0_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_rcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_wcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_racount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_wacount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxihpc1_fpd_aclk : in STD_LOGIC;
    saxihpc1_fpd_rclk : in STD_LOGIC;
    saxihpc1_fpd_wclk : in STD_LOGIC;
    saxigp1_aruser : in STD_LOGIC;
    saxigp1_awuser : in STD_LOGIC;
    saxigp1_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp1_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp1_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp1_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp1_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp1_awlock : in STD_LOGIC;
    saxigp1_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp1_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp1_awvalid : in STD_LOGIC;
    saxigp1_awready : out STD_LOGIC;
    saxigp1_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp1_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    saxigp1_wlast : in STD_LOGIC;
    saxigp1_wvalid : in STD_LOGIC;
    saxigp1_wready : out STD_LOGIC;
    saxigp1_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp1_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp1_bvalid : out STD_LOGIC;
    saxigp1_bready : in STD_LOGIC;
    saxigp1_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp1_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp1_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp1_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp1_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp1_arlock : in STD_LOGIC;
    saxigp1_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp1_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp1_arvalid : in STD_LOGIC;
    saxigp1_arready : out STD_LOGIC;
    saxigp1_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp1_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp1_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp1_rlast : out STD_LOGIC;
    saxigp1_rvalid : out STD_LOGIC;
    saxigp1_rready : in STD_LOGIC;
    saxigp1_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp1_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp1_rcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp1_wcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp1_racount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp1_wacount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxihp0_fpd_aclk : in STD_LOGIC;
    saxihp0_fpd_rclk : in STD_LOGIC;
    saxihp0_fpd_wclk : in STD_LOGIC;
    saxigp2_aruser : in STD_LOGIC;
    saxigp2_awuser : in STD_LOGIC;
    saxigp2_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp2_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp2_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp2_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp2_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp2_awlock : in STD_LOGIC;
    saxigp2_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp2_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp2_awvalid : in STD_LOGIC;
    saxigp2_awready : out STD_LOGIC;
    saxigp2_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp2_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    saxigp2_wlast : in STD_LOGIC;
    saxigp2_wvalid : in STD_LOGIC;
    saxigp2_wready : out STD_LOGIC;
    saxigp2_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp2_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp2_bvalid : out STD_LOGIC;
    saxigp2_bready : in STD_LOGIC;
    saxigp2_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp2_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp2_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp2_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp2_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp2_arlock : in STD_LOGIC;
    saxigp2_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp2_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp2_arvalid : in STD_LOGIC;
    saxigp2_arready : out STD_LOGIC;
    saxigp2_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp2_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp2_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp2_rlast : out STD_LOGIC;
    saxigp2_rvalid : out STD_LOGIC;
    saxigp2_rready : in STD_LOGIC;
    saxigp2_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp2_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp2_rcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp2_wcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp2_racount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp2_wacount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxihp1_fpd_aclk : in STD_LOGIC;
    saxihp1_fpd_rclk : in STD_LOGIC;
    saxihp1_fpd_wclk : in STD_LOGIC;
    saxigp3_aruser : in STD_LOGIC;
    saxigp3_awuser : in STD_LOGIC;
    saxigp3_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp3_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp3_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp3_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp3_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp3_awlock : in STD_LOGIC;
    saxigp3_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp3_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp3_awvalid : in STD_LOGIC;
    saxigp3_awready : out STD_LOGIC;
    saxigp3_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp3_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    saxigp3_wlast : in STD_LOGIC;
    saxigp3_wvalid : in STD_LOGIC;
    saxigp3_wready : out STD_LOGIC;
    saxigp3_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp3_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp3_bvalid : out STD_LOGIC;
    saxigp3_bready : in STD_LOGIC;
    saxigp3_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp3_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp3_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp3_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp3_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp3_arlock : in STD_LOGIC;
    saxigp3_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp3_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp3_arvalid : in STD_LOGIC;
    saxigp3_arready : out STD_LOGIC;
    saxigp3_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp3_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp3_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp3_rlast : out STD_LOGIC;
    saxigp3_rvalid : out STD_LOGIC;
    saxigp3_rready : in STD_LOGIC;
    saxigp3_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp3_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp3_rcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp3_wcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp3_racount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp3_wacount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxihp2_fpd_aclk : in STD_LOGIC;
    saxihp2_fpd_rclk : in STD_LOGIC;
    saxihp2_fpd_wclk : in STD_LOGIC;
    saxigp4_aruser : in STD_LOGIC;
    saxigp4_awuser : in STD_LOGIC;
    saxigp4_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp4_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp4_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp4_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp4_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp4_awlock : in STD_LOGIC;
    saxigp4_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp4_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp4_awvalid : in STD_LOGIC;
    saxigp4_awready : out STD_LOGIC;
    saxigp4_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp4_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    saxigp4_wlast : in STD_LOGIC;
    saxigp4_wvalid : in STD_LOGIC;
    saxigp4_wready : out STD_LOGIC;
    saxigp4_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp4_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp4_bvalid : out STD_LOGIC;
    saxigp4_bready : in STD_LOGIC;
    saxigp4_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp4_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp4_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp4_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp4_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp4_arlock : in STD_LOGIC;
    saxigp4_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp4_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp4_arvalid : in STD_LOGIC;
    saxigp4_arready : out STD_LOGIC;
    saxigp4_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp4_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp4_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp4_rlast : out STD_LOGIC;
    saxigp4_rvalid : out STD_LOGIC;
    saxigp4_rready : in STD_LOGIC;
    saxigp4_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp4_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp4_rcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp4_wcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp4_racount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp4_wacount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxihp3_fpd_aclk : in STD_LOGIC;
    saxihp3_fpd_rclk : in STD_LOGIC;
    saxihp3_fpd_wclk : in STD_LOGIC;
    saxigp5_aruser : in STD_LOGIC;
    saxigp5_awuser : in STD_LOGIC;
    saxigp5_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp5_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp5_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp5_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp5_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp5_awlock : in STD_LOGIC;
    saxigp5_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp5_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp5_awvalid : in STD_LOGIC;
    saxigp5_awready : out STD_LOGIC;
    saxigp5_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp5_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    saxigp5_wlast : in STD_LOGIC;
    saxigp5_wvalid : in STD_LOGIC;
    saxigp5_wready : out STD_LOGIC;
    saxigp5_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp5_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp5_bvalid : out STD_LOGIC;
    saxigp5_bready : in STD_LOGIC;
    saxigp5_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp5_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp5_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp5_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp5_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp5_arlock : in STD_LOGIC;
    saxigp5_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp5_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp5_arvalid : in STD_LOGIC;
    saxigp5_arready : out STD_LOGIC;
    saxigp5_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp5_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp5_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp5_rlast : out STD_LOGIC;
    saxigp5_rvalid : out STD_LOGIC;
    saxigp5_rready : in STD_LOGIC;
    saxigp5_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp5_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp5_rcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp5_wcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp5_racount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp5_wacount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxi_lpd_aclk : in STD_LOGIC;
    saxi_lpd_rclk : in STD_LOGIC;
    saxi_lpd_wclk : in STD_LOGIC;
    saxigp6_aruser : in STD_LOGIC;
    saxigp6_awuser : in STD_LOGIC;
    saxigp6_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp6_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp6_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp6_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp6_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp6_awlock : in STD_LOGIC;
    saxigp6_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp6_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp6_awvalid : in STD_LOGIC;
    saxigp6_awready : out STD_LOGIC;
    saxigp6_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp6_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    saxigp6_wlast : in STD_LOGIC;
    saxigp6_wvalid : in STD_LOGIC;
    saxigp6_wready : out STD_LOGIC;
    saxigp6_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp6_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp6_bvalid : out STD_LOGIC;
    saxigp6_bready : in STD_LOGIC;
    saxigp6_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp6_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp6_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp6_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp6_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp6_arlock : in STD_LOGIC;
    saxigp6_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp6_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp6_arvalid : in STD_LOGIC;
    saxigp6_arready : out STD_LOGIC;
    saxigp6_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp6_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    saxigp6_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp6_rlast : out STD_LOGIC;
    saxigp6_rvalid : out STD_LOGIC;
    saxigp6_rready : in STD_LOGIC;
    saxigp6_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp6_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp6_rcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp6_wcount : out STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp6_racount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp6_wacount : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxiacp_fpd_aclk : in STD_LOGIC;
    saxiacp_awaddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    saxiacp_awid : in STD_LOGIC_VECTOR ( 4 downto 0 );
    saxiacp_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxiacp_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxiacp_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxiacp_awlock : in STD_LOGIC;
    saxiacp_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxiacp_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxiacp_awvalid : in STD_LOGIC;
    saxiacp_awready : out STD_LOGIC;
    saxiacp_awuser : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxiacp_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxiacp_wlast : in STD_LOGIC;
    saxiacp_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    saxiacp_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    saxiacp_wvalid : in STD_LOGIC;
    saxiacp_wready : out STD_LOGIC;
    saxiacp_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxiacp_bid : out STD_LOGIC_VECTOR ( 4 downto 0 );
    saxiacp_bvalid : out STD_LOGIC;
    saxiacp_bready : in STD_LOGIC;
    saxiacp_araddr : in STD_LOGIC_VECTOR ( 39 downto 0 );
    saxiacp_arid : in STD_LOGIC_VECTOR ( 4 downto 0 );
    saxiacp_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxiacp_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxiacp_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxiacp_arlock : in STD_LOGIC;
    saxiacp_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxiacp_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxiacp_arvalid : in STD_LOGIC;
    saxiacp_arready : out STD_LOGIC;
    saxiacp_aruser : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxiacp_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxiacp_rid : out STD_LOGIC_VECTOR ( 4 downto 0 );
    saxiacp_rlast : out STD_LOGIC;
    saxiacp_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    saxiacp_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxiacp_rvalid : out STD_LOGIC;
    saxiacp_rready : in STD_LOGIC;
    sacefpd_aclk : in STD_LOGIC;
    sacefpd_awvalid : in STD_LOGIC;
    sacefpd_awready : out STD_LOGIC;
    sacefpd_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    sacefpd_awaddr : in STD_LOGIC_VECTOR ( 43 downto 0 );
    sacefpd_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    sacefpd_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    sacefpd_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    sacefpd_awlock : in STD_LOGIC;
    sacefpd_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    sacefpd_awdomain : in STD_LOGIC_VECTOR ( 1 downto 0 );
    sacefpd_awsnoop : in STD_LOGIC_VECTOR ( 2 downto 0 );
    sacefpd_awbar : in STD_LOGIC_VECTOR ( 1 downto 0 );
    sacefpd_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_wvalid : in STD_LOGIC;
    sacefpd_wready : out STD_LOGIC;
    sacefpd_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    sacefpd_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    sacefpd_wlast : in STD_LOGIC;
    sacefpd_wuser : in STD_LOGIC;
    sacefpd_bvalid : out STD_LOGIC;
    sacefpd_bready : in STD_LOGIC;
    sacefpd_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    sacefpd_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    sacefpd_buser : out STD_LOGIC;
    sacefpd_arvalid : in STD_LOGIC;
    sacefpd_arready : out STD_LOGIC;
    sacefpd_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    sacefpd_araddr : in STD_LOGIC_VECTOR ( 43 downto 0 );
    sacefpd_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    sacefpd_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    sacefpd_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    sacefpd_arlock : in STD_LOGIC;
    sacefpd_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    sacefpd_ardomain : in STD_LOGIC_VECTOR ( 1 downto 0 );
    sacefpd_arsnoop : in STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_arbar : in STD_LOGIC_VECTOR ( 1 downto 0 );
    sacefpd_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_rvalid : out STD_LOGIC;
    sacefpd_rready : in STD_LOGIC;
    sacefpd_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    sacefpd_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    sacefpd_rresp : out STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_rlast : out STD_LOGIC;
    sacefpd_ruser : out STD_LOGIC;
    sacefpd_acvalid : out STD_LOGIC;
    sacefpd_acready : in STD_LOGIC;
    sacefpd_acaddr : out STD_LOGIC_VECTOR ( 43 downto 0 );
    sacefpd_acsnoop : out STD_LOGIC_VECTOR ( 3 downto 0 );
    sacefpd_acprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    sacefpd_crvalid : in STD_LOGIC;
    sacefpd_crready : out STD_LOGIC;
    sacefpd_crresp : in STD_LOGIC_VECTOR ( 4 downto 0 );
    sacefpd_cdvalid : in STD_LOGIC;
    sacefpd_cdready : out STD_LOGIC;
    sacefpd_cddata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    sacefpd_cdlast : in STD_LOGIC;
    sacefpd_wack : in STD_LOGIC;
    sacefpd_rack : in STD_LOGIC;
    emio_can0_phy_tx : out STD_LOGIC;
    emio_can0_phy_rx : in STD_LOGIC;
    emio_can1_phy_tx : out STD_LOGIC;
    emio_can1_phy_rx : in STD_LOGIC;
    emio_enet0_gmii_rx_clk : in STD_LOGIC;
    emio_enet0_speed_mode : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_enet0_gmii_crs : in STD_LOGIC;
    emio_enet0_gmii_col : in STD_LOGIC;
    emio_enet0_gmii_rxd : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet0_gmii_rx_er : in STD_LOGIC;
    emio_enet0_gmii_rx_dv : in STD_LOGIC;
    emio_enet0_gmii_tx_clk : in STD_LOGIC;
    emio_enet0_gmii_txd : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet0_gmii_tx_en : out STD_LOGIC;
    emio_enet0_gmii_tx_er : out STD_LOGIC;
    emio_enet0_mdio_mdc : out STD_LOGIC;
    emio_enet0_mdio_i : in STD_LOGIC;
    emio_enet0_mdio_o : out STD_LOGIC;
    emio_enet0_mdio_t : out STD_LOGIC;
    emio_enet0_mdio_t_n : out STD_LOGIC;
    emio_enet1_gmii_rx_clk : in STD_LOGIC;
    emio_enet1_speed_mode : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_enet1_gmii_crs : in STD_LOGIC;
    emio_enet1_gmii_col : in STD_LOGIC;
    emio_enet1_gmii_rxd : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet1_gmii_rx_er : in STD_LOGIC;
    emio_enet1_gmii_rx_dv : in STD_LOGIC;
    emio_enet1_gmii_tx_clk : in STD_LOGIC;
    emio_enet1_gmii_txd : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet1_gmii_tx_en : out STD_LOGIC;
    emio_enet1_gmii_tx_er : out STD_LOGIC;
    emio_enet1_mdio_mdc : out STD_LOGIC;
    emio_enet1_mdio_i : in STD_LOGIC;
    emio_enet1_mdio_o : out STD_LOGIC;
    emio_enet1_mdio_t : out STD_LOGIC;
    emio_enet1_mdio_t_n : out STD_LOGIC;
    emio_enet2_gmii_rx_clk : in STD_LOGIC;
    emio_enet2_speed_mode : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_enet2_gmii_crs : in STD_LOGIC;
    emio_enet2_gmii_col : in STD_LOGIC;
    emio_enet2_gmii_rxd : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet2_gmii_rx_er : in STD_LOGIC;
    emio_enet2_gmii_rx_dv : in STD_LOGIC;
    emio_enet2_gmii_tx_clk : in STD_LOGIC;
    emio_enet2_gmii_txd : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet2_gmii_tx_en : out STD_LOGIC;
    emio_enet2_gmii_tx_er : out STD_LOGIC;
    emio_enet2_mdio_mdc : out STD_LOGIC;
    emio_enet2_mdio_i : in STD_LOGIC;
    emio_enet2_mdio_o : out STD_LOGIC;
    emio_enet2_mdio_t : out STD_LOGIC;
    emio_enet2_mdio_t_n : out STD_LOGIC;
    emio_enet3_gmii_rx_clk : in STD_LOGIC;
    emio_enet3_speed_mode : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_enet3_gmii_crs : in STD_LOGIC;
    emio_enet3_gmii_col : in STD_LOGIC;
    emio_enet3_gmii_rxd : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet3_gmii_rx_er : in STD_LOGIC;
    emio_enet3_gmii_rx_dv : in STD_LOGIC;
    emio_enet3_gmii_tx_clk : in STD_LOGIC;
    emio_enet3_gmii_txd : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet3_gmii_tx_en : out STD_LOGIC;
    emio_enet3_gmii_tx_er : out STD_LOGIC;
    emio_enet3_mdio_mdc : out STD_LOGIC;
    emio_enet3_mdio_i : in STD_LOGIC;
    emio_enet3_mdio_o : out STD_LOGIC;
    emio_enet3_mdio_t : out STD_LOGIC;
    emio_enet3_mdio_t_n : out STD_LOGIC;
    emio_enet0_tx_r_data_rdy : in STD_LOGIC;
    emio_enet0_tx_r_rd : out STD_LOGIC;
    emio_enet0_tx_r_valid : in STD_LOGIC;
    emio_enet0_tx_r_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet0_tx_r_sop : in STD_LOGIC;
    emio_enet0_tx_r_eop : in STD_LOGIC;
    emio_enet0_tx_r_err : in STD_LOGIC;
    emio_enet0_tx_r_underflow : in STD_LOGIC;
    emio_enet0_tx_r_flushed : in STD_LOGIC;
    emio_enet0_tx_r_control : in STD_LOGIC;
    emio_enet0_dma_tx_end_tog : out STD_LOGIC;
    emio_enet0_dma_tx_status_tog : in STD_LOGIC;
    emio_enet0_tx_r_status : out STD_LOGIC_VECTOR ( 3 downto 0 );
    emio_enet0_rx_w_wr : out STD_LOGIC;
    emio_enet0_rx_w_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet0_rx_w_sop : out STD_LOGIC;
    emio_enet0_rx_w_eop : out STD_LOGIC;
    emio_enet0_rx_w_status : out STD_LOGIC_VECTOR ( 44 downto 0 );
    emio_enet0_rx_w_err : out STD_LOGIC;
    emio_enet0_rx_w_overflow : in STD_LOGIC;
    emio_enet0_signal_detect : in STD_LOGIC;
    emio_enet0_rx_w_flush : out STD_LOGIC;
    emio_enet0_tx_r_fixed_lat : out STD_LOGIC;
    emio_enet1_tx_r_data_rdy : in STD_LOGIC;
    emio_enet1_tx_r_rd : out STD_LOGIC;
    emio_enet1_tx_r_valid : in STD_LOGIC;
    emio_enet1_tx_r_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet1_tx_r_sop : in STD_LOGIC;
    emio_enet1_tx_r_eop : in STD_LOGIC;
    emio_enet1_tx_r_err : in STD_LOGIC;
    emio_enet1_tx_r_underflow : in STD_LOGIC;
    emio_enet1_tx_r_flushed : in STD_LOGIC;
    emio_enet1_tx_r_control : in STD_LOGIC;
    emio_enet1_dma_tx_end_tog : out STD_LOGIC;
    emio_enet1_dma_tx_status_tog : in STD_LOGIC;
    emio_enet1_tx_r_status : out STD_LOGIC_VECTOR ( 3 downto 0 );
    emio_enet1_rx_w_wr : out STD_LOGIC;
    emio_enet1_rx_w_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet1_rx_w_sop : out STD_LOGIC;
    emio_enet1_rx_w_eop : out STD_LOGIC;
    emio_enet1_rx_w_status : out STD_LOGIC_VECTOR ( 44 downto 0 );
    emio_enet1_rx_w_err : out STD_LOGIC;
    emio_enet1_rx_w_overflow : in STD_LOGIC;
    emio_enet1_signal_detect : in STD_LOGIC;
    emio_enet1_rx_w_flush : out STD_LOGIC;
    emio_enet1_tx_r_fixed_lat : out STD_LOGIC;
    emio_enet2_tx_r_data_rdy : in STD_LOGIC;
    emio_enet2_tx_r_rd : out STD_LOGIC;
    emio_enet2_tx_r_valid : in STD_LOGIC;
    emio_enet2_tx_r_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet2_tx_r_sop : in STD_LOGIC;
    emio_enet2_tx_r_eop : in STD_LOGIC;
    emio_enet2_tx_r_err : in STD_LOGIC;
    emio_enet2_tx_r_underflow : in STD_LOGIC;
    emio_enet2_tx_r_flushed : in STD_LOGIC;
    emio_enet2_tx_r_control : in STD_LOGIC;
    emio_enet2_dma_tx_end_tog : out STD_LOGIC;
    emio_enet2_dma_tx_status_tog : in STD_LOGIC;
    emio_enet2_tx_r_status : out STD_LOGIC_VECTOR ( 3 downto 0 );
    emio_enet2_rx_w_wr : out STD_LOGIC;
    emio_enet2_rx_w_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet2_rx_w_sop : out STD_LOGIC;
    emio_enet2_rx_w_eop : out STD_LOGIC;
    emio_enet2_rx_w_status : out STD_LOGIC_VECTOR ( 44 downto 0 );
    emio_enet2_rx_w_err : out STD_LOGIC;
    emio_enet2_rx_w_overflow : in STD_LOGIC;
    emio_enet2_signal_detect : in STD_LOGIC;
    emio_enet2_rx_w_flush : out STD_LOGIC;
    emio_enet2_tx_r_fixed_lat : out STD_LOGIC;
    emio_enet3_tx_r_data_rdy : in STD_LOGIC;
    emio_enet3_tx_r_rd : out STD_LOGIC;
    emio_enet3_tx_r_valid : in STD_LOGIC;
    emio_enet3_tx_r_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet3_tx_r_sop : in STD_LOGIC;
    emio_enet3_tx_r_eop : in STD_LOGIC;
    emio_enet3_tx_r_err : in STD_LOGIC;
    emio_enet3_tx_r_underflow : in STD_LOGIC;
    emio_enet3_tx_r_flushed : in STD_LOGIC;
    emio_enet3_tx_r_control : in STD_LOGIC;
    emio_enet3_dma_tx_end_tog : out STD_LOGIC;
    emio_enet3_dma_tx_status_tog : in STD_LOGIC;
    emio_enet3_tx_r_status : out STD_LOGIC_VECTOR ( 3 downto 0 );
    emio_enet3_rx_w_wr : out STD_LOGIC;
    emio_enet3_rx_w_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_enet3_rx_w_sop : out STD_LOGIC;
    emio_enet3_rx_w_eop : out STD_LOGIC;
    emio_enet3_rx_w_status : out STD_LOGIC_VECTOR ( 44 downto 0 );
    emio_enet3_rx_w_err : out STD_LOGIC;
    emio_enet3_rx_w_overflow : in STD_LOGIC;
    emio_enet3_signal_detect : in STD_LOGIC;
    emio_enet3_rx_w_flush : out STD_LOGIC;
    emio_enet3_tx_r_fixed_lat : out STD_LOGIC;
    fmio_gem0_fifo_tx_clk_to_pl_bufg : out STD_LOGIC;
    fmio_gem0_fifo_rx_clk_to_pl_bufg : out STD_LOGIC;
    fmio_gem1_fifo_tx_clk_to_pl_bufg : out STD_LOGIC;
    fmio_gem1_fifo_rx_clk_to_pl_bufg : out STD_LOGIC;
    fmio_gem2_fifo_tx_clk_to_pl_bufg : out STD_LOGIC;
    fmio_gem2_fifo_rx_clk_to_pl_bufg : out STD_LOGIC;
    fmio_gem3_fifo_tx_clk_to_pl_bufg : out STD_LOGIC;
    fmio_gem3_fifo_rx_clk_to_pl_bufg : out STD_LOGIC;
    emio_enet0_tx_sof : out STD_LOGIC;
    emio_enet0_sync_frame_tx : out STD_LOGIC;
    emio_enet0_delay_req_tx : out STD_LOGIC;
    emio_enet0_pdelay_req_tx : out STD_LOGIC;
    emio_enet0_pdelay_resp_tx : out STD_LOGIC;
    emio_enet0_rx_sof : out STD_LOGIC;
    emio_enet0_sync_frame_rx : out STD_LOGIC;
    emio_enet0_delay_req_rx : out STD_LOGIC;
    emio_enet0_pdelay_req_rx : out STD_LOGIC;
    emio_enet0_pdelay_resp_rx : out STD_LOGIC;
    emio_enet0_tsu_inc_ctrl : in STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_enet0_tsu_timer_cmp_val : out STD_LOGIC;
    emio_enet1_tx_sof : out STD_LOGIC;
    emio_enet1_sync_frame_tx : out STD_LOGIC;
    emio_enet1_delay_req_tx : out STD_LOGIC;
    emio_enet1_pdelay_req_tx : out STD_LOGIC;
    emio_enet1_pdelay_resp_tx : out STD_LOGIC;
    emio_enet1_rx_sof : out STD_LOGIC;
    emio_enet1_sync_frame_rx : out STD_LOGIC;
    emio_enet1_delay_req_rx : out STD_LOGIC;
    emio_enet1_pdelay_req_rx : out STD_LOGIC;
    emio_enet1_pdelay_resp_rx : out STD_LOGIC;
    emio_enet1_tsu_inc_ctrl : in STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_enet1_tsu_timer_cmp_val : out STD_LOGIC;
    emio_enet2_tx_sof : out STD_LOGIC;
    emio_enet2_sync_frame_tx : out STD_LOGIC;
    emio_enet2_delay_req_tx : out STD_LOGIC;
    emio_enet2_pdelay_req_tx : out STD_LOGIC;
    emio_enet2_pdelay_resp_tx : out STD_LOGIC;
    emio_enet2_rx_sof : out STD_LOGIC;
    emio_enet2_sync_frame_rx : out STD_LOGIC;
    emio_enet2_delay_req_rx : out STD_LOGIC;
    emio_enet2_pdelay_req_rx : out STD_LOGIC;
    emio_enet2_pdelay_resp_rx : out STD_LOGIC;
    emio_enet2_tsu_inc_ctrl : in STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_enet2_tsu_timer_cmp_val : out STD_LOGIC;
    emio_enet3_tx_sof : out STD_LOGIC;
    emio_enet3_sync_frame_tx : out STD_LOGIC;
    emio_enet3_delay_req_tx : out STD_LOGIC;
    emio_enet3_pdelay_req_tx : out STD_LOGIC;
    emio_enet3_pdelay_resp_tx : out STD_LOGIC;
    emio_enet3_rx_sof : out STD_LOGIC;
    emio_enet3_sync_frame_rx : out STD_LOGIC;
    emio_enet3_delay_req_rx : out STD_LOGIC;
    emio_enet3_pdelay_req_rx : out STD_LOGIC;
    emio_enet3_pdelay_resp_rx : out STD_LOGIC;
    emio_enet3_tsu_inc_ctrl : in STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_enet3_tsu_timer_cmp_val : out STD_LOGIC;
    fmio_gem_tsu_clk_from_pl : in STD_LOGIC;
    fmio_gem_tsu_clk_to_pl_bufg : out STD_LOGIC;
    emio_enet_tsu_clk : in STD_LOGIC;
    emio_enet0_enet_tsu_timer_cnt : out STD_LOGIC_VECTOR ( 93 downto 0 );
    emio_enet0_ext_int_in : in STD_LOGIC;
    emio_enet1_ext_int_in : in STD_LOGIC;
    emio_enet2_ext_int_in : in STD_LOGIC;
    emio_enet3_ext_int_in : in STD_LOGIC;
    emio_enet0_dma_bus_width : out STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_enet1_dma_bus_width : out STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_enet2_dma_bus_width : out STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_enet3_dma_bus_width : out STD_LOGIC_VECTOR ( 1 downto 0 );
    emio_gpio_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    emio_gpio_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    emio_gpio_t : out STD_LOGIC_VECTOR ( 0 to 0 );
    emio_gpio_t_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    emio_i2c0_scl_i : in STD_LOGIC;
    emio_i2c0_scl_o : out STD_LOGIC;
    emio_i2c0_scl_t_n : out STD_LOGIC;
    emio_i2c0_scl_t : out STD_LOGIC;
    emio_i2c0_sda_i : in STD_LOGIC;
    emio_i2c0_sda_o : out STD_LOGIC;
    emio_i2c0_sda_t_n : out STD_LOGIC;
    emio_i2c0_sda_t : out STD_LOGIC;
    emio_i2c1_scl_i : in STD_LOGIC;
    emio_i2c1_scl_o : out STD_LOGIC;
    emio_i2c1_scl_t : out STD_LOGIC;
    emio_i2c1_scl_t_n : out STD_LOGIC;
    emio_i2c1_sda_i : in STD_LOGIC;
    emio_i2c1_sda_o : out STD_LOGIC;
    emio_i2c1_sda_t : out STD_LOGIC;
    emio_i2c1_sda_t_n : out STD_LOGIC;
    emio_uart0_txd : out STD_LOGIC;
    emio_uart0_rxd : in STD_LOGIC;
    emio_uart0_ctsn : in STD_LOGIC;
    emio_uart0_rtsn : out STD_LOGIC;
    emio_uart0_dsrn : in STD_LOGIC;
    emio_uart0_dcdn : in STD_LOGIC;
    emio_uart0_rin : in STD_LOGIC;
    emio_uart0_dtrn : out STD_LOGIC;
    emio_uart1_txd : out STD_LOGIC;
    emio_uart1_rxd : in STD_LOGIC;
    emio_uart1_ctsn : in STD_LOGIC;
    emio_uart1_rtsn : out STD_LOGIC;
    emio_uart1_dsrn : in STD_LOGIC;
    emio_uart1_dcdn : in STD_LOGIC;
    emio_uart1_rin : in STD_LOGIC;
    emio_uart1_dtrn : out STD_LOGIC;
    emio_sdio0_clkout : out STD_LOGIC;
    emio_sdio0_fb_clk_in : in STD_LOGIC;
    emio_sdio0_cmdout : out STD_LOGIC;
    emio_sdio0_cmdin : in STD_LOGIC;
    emio_sdio0_cmdena : out STD_LOGIC;
    emio_sdio0_datain : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_sdio0_dataout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_sdio0_dataena : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_sdio0_cd_n : in STD_LOGIC;
    emio_sdio0_wp : in STD_LOGIC;
    emio_sdio0_ledcontrol : out STD_LOGIC;
    emio_sdio0_buspower : out STD_LOGIC;
    emio_sdio0_bus_volt : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_sdio1_clkout : out STD_LOGIC;
    emio_sdio1_fb_clk_in : in STD_LOGIC;
    emio_sdio1_cmdout : out STD_LOGIC;
    emio_sdio1_cmdin : in STD_LOGIC;
    emio_sdio1_cmdena : out STD_LOGIC;
    emio_sdio1_datain : in STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_sdio1_dataout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_sdio1_dataena : out STD_LOGIC_VECTOR ( 7 downto 0 );
    emio_sdio1_cd_n : in STD_LOGIC;
    emio_sdio1_wp : in STD_LOGIC;
    emio_sdio1_ledcontrol : out STD_LOGIC;
    emio_sdio1_buspower : out STD_LOGIC;
    emio_sdio1_bus_volt : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_spi0_sclk_i : in STD_LOGIC;
    emio_spi0_sclk_o : out STD_LOGIC;
    emio_spi0_sclk_t : out STD_LOGIC;
    emio_spi0_sclk_t_n : out STD_LOGIC;
    emio_spi0_m_i : in STD_LOGIC;
    emio_spi0_m_o : out STD_LOGIC;
    emio_spi0_mo_t : out STD_LOGIC;
    emio_spi0_mo_t_n : out STD_LOGIC;
    emio_spi0_s_i : in STD_LOGIC;
    emio_spi0_s_o : out STD_LOGIC;
    emio_spi0_so_t : out STD_LOGIC;
    emio_spi0_so_t_n : out STD_LOGIC;
    emio_spi0_ss_i_n : in STD_LOGIC;
    emio_spi0_ss_o_n : out STD_LOGIC;
    emio_spi0_ss1_o_n : out STD_LOGIC;
    emio_spi0_ss2_o_n : out STD_LOGIC;
    emio_spi0_ss_n_t : out STD_LOGIC;
    emio_spi0_ss_n_t_n : out STD_LOGIC;
    emio_spi1_sclk_i : in STD_LOGIC;
    emio_spi1_sclk_o : out STD_LOGIC;
    emio_spi1_sclk_t : out STD_LOGIC;
    emio_spi1_sclk_t_n : out STD_LOGIC;
    emio_spi1_m_i : in STD_LOGIC;
    emio_spi1_m_o : out STD_LOGIC;
    emio_spi1_mo_t : out STD_LOGIC;
    emio_spi1_mo_t_n : out STD_LOGIC;
    emio_spi1_s_i : in STD_LOGIC;
    emio_spi1_s_o : out STD_LOGIC;
    emio_spi1_so_t : out STD_LOGIC;
    emio_spi1_so_t_n : out STD_LOGIC;
    emio_spi1_ss_i_n : in STD_LOGIC;
    emio_spi1_ss_o_n : out STD_LOGIC;
    emio_spi1_ss1_o_n : out STD_LOGIC;
    emio_spi1_ss2_o_n : out STD_LOGIC;
    emio_spi1_ss_n_t : out STD_LOGIC;
    emio_spi1_ss_n_t_n : out STD_LOGIC;
    pl_ps_trace_clk : in STD_LOGIC;
    ps_pl_tracectl : out STD_LOGIC;
    ps_pl_tracedata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    trace_clk_out : out STD_LOGIC;
    emio_ttc0_wave_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_ttc0_clk_i : in STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_ttc1_wave_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_ttc1_clk_i : in STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_ttc2_wave_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_ttc2_clk_i : in STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_ttc3_wave_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_ttc3_clk_i : in STD_LOGIC_VECTOR ( 2 downto 0 );
    emio_wdt0_clk_i : in STD_LOGIC;
    emio_wdt0_rst_o : out STD_LOGIC;
    emio_wdt1_clk_i : in STD_LOGIC;
    emio_wdt1_rst_o : out STD_LOGIC;
    emio_hub_port_overcrnt_usb3_0 : in STD_LOGIC;
    emio_hub_port_overcrnt_usb3_1 : in STD_LOGIC;
    emio_hub_port_overcrnt_usb2_0 : in STD_LOGIC;
    emio_hub_port_overcrnt_usb2_1 : in STD_LOGIC;
    emio_u2dsport_vbus_ctrl_usb3_0 : out STD_LOGIC;
    emio_u2dsport_vbus_ctrl_usb3_1 : out STD_LOGIC;
    emio_u3dsport_vbus_ctrl_usb3_0 : out STD_LOGIC;
    emio_u3dsport_vbus_ctrl_usb3_1 : out STD_LOGIC;
    adma_fci_clk : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pl2adma_cvld : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pl2adma_tack : in STD_LOGIC_VECTOR ( 7 downto 0 );
    adma2pl_cack : out STD_LOGIC_VECTOR ( 7 downto 0 );
    adma2pl_tvld : out STD_LOGIC_VECTOR ( 7 downto 0 );
    perif_gdma_clk : in STD_LOGIC_VECTOR ( 7 downto 0 );
    perif_gdma_cvld : in STD_LOGIC_VECTOR ( 7 downto 0 );
    perif_gdma_tack : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gdma_perif_cack : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gdma_perif_tvld : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pl_clock_stop : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pll_aux_refclk_lpd : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pll_aux_refclk_fpd : in STD_LOGIC_VECTOR ( 2 downto 0 );
    dp_s_axis_audio_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dp_s_axis_audio_tid : in STD_LOGIC;
    dp_s_axis_audio_tvalid : in STD_LOGIC;
    dp_s_axis_audio_tready : out STD_LOGIC;
    dp_m_axis_mixed_audio_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    dp_m_axis_mixed_audio_tid : out STD_LOGIC;
    dp_m_axis_mixed_audio_tvalid : out STD_LOGIC;
    dp_m_axis_mixed_audio_tready : in STD_LOGIC;
    dp_s_axis_audio_clk : in STD_LOGIC;
    dp_live_video_in_vsync : in STD_LOGIC;
    dp_live_video_in_hsync : in STD_LOGIC;
    dp_live_video_in_de : in STD_LOGIC;
    dp_live_video_in_pixel1 : in STD_LOGIC_VECTOR ( 35 downto 0 );
    dp_video_in_clk : in STD_LOGIC;
    dp_video_out_hsync : out STD_LOGIC;
    dp_video_out_vsync : out STD_LOGIC;
    dp_video_out_pixel1 : out STD_LOGIC_VECTOR ( 35 downto 0 );
    dp_aux_data_in : in STD_LOGIC;
    dp_aux_data_out : out STD_LOGIC;
    dp_aux_data_oe_n : out STD_LOGIC;
    dp_live_gfx_alpha_in : in STD_LOGIC_VECTOR ( 7 downto 0 );
    dp_live_gfx_pixel1_in : in STD_LOGIC_VECTOR ( 35 downto 0 );
    dp_hot_plug_detect : in STD_LOGIC;
    dp_external_custom_event1 : in STD_LOGIC;
    dp_external_custom_event2 : in STD_LOGIC;
    dp_external_vsync_event : in STD_LOGIC;
    dp_live_video_de_out : out STD_LOGIC;
    pl_ps_eventi : in STD_LOGIC;
    ps_pl_evento : out STD_LOGIC;
    ps_pl_standbywfe : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ps_pl_standbywfi : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pl_ps_apugic_irq : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pl_ps_apugic_fiq : in STD_LOGIC_VECTOR ( 3 downto 0 );
    rpu_eventi0 : in STD_LOGIC;
    rpu_eventi1 : in STD_LOGIC;
    rpu_evento0 : out STD_LOGIC;
    rpu_evento1 : out STD_LOGIC;
    nfiq0_lpd_rpu : in STD_LOGIC;
    nfiq1_lpd_rpu : in STD_LOGIC;
    nirq0_lpd_rpu : in STD_LOGIC;
    nirq1_lpd_rpu : in STD_LOGIC;
    irq_ipi_pl_0 : out STD_LOGIC;
    irq_ipi_pl_1 : out STD_LOGIC;
    irq_ipi_pl_2 : out STD_LOGIC;
    irq_ipi_pl_3 : out STD_LOGIC;
    stm_event : in STD_LOGIC_VECTOR ( 59 downto 0 );
    pl_ps_trigack_0 : in STD_LOGIC;
    pl_ps_trigack_1 : in STD_LOGIC;
    pl_ps_trigack_2 : in STD_LOGIC;
    pl_ps_trigack_3 : in STD_LOGIC;
    pl_ps_trigger_0 : in STD_LOGIC;
    pl_ps_trigger_1 : in STD_LOGIC;
    pl_ps_trigger_2 : in STD_LOGIC;
    pl_ps_trigger_3 : in STD_LOGIC;
    ps_pl_trigack_0 : out STD_LOGIC;
    ps_pl_trigack_1 : out STD_LOGIC;
    ps_pl_trigack_2 : out STD_LOGIC;
    ps_pl_trigack_3 : out STD_LOGIC;
    ps_pl_trigger_0 : out STD_LOGIC;
    ps_pl_trigger_1 : out STD_LOGIC;
    ps_pl_trigger_2 : out STD_LOGIC;
    ps_pl_trigger_3 : out STD_LOGIC;
    ftm_gpo : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ftm_gpi : in STD_LOGIC_VECTOR ( 31 downto 0 );
    pl_ps_irq0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    pl_ps_irq1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    pl_resetn0 : out STD_LOGIC;
    pl_resetn1 : out STD_LOGIC;
    pl_resetn2 : out STD_LOGIC;
    pl_resetn3 : out STD_LOGIC;
    ps_pl_irq_can0 : out STD_LOGIC;
    ps_pl_irq_can1 : out STD_LOGIC;
    ps_pl_irq_enet0 : out STD_LOGIC;
    ps_pl_irq_enet1 : out STD_LOGIC;
    ps_pl_irq_enet2 : out STD_LOGIC;
    ps_pl_irq_enet3 : out STD_LOGIC;
    ps_pl_irq_enet0_wake : out STD_LOGIC;
    ps_pl_irq_enet1_wake : out STD_LOGIC;
    ps_pl_irq_enet2_wake : out STD_LOGIC;
    ps_pl_irq_enet3_wake : out STD_LOGIC;
    ps_pl_irq_gpio : out STD_LOGIC;
    ps_pl_irq_i2c0 : out STD_LOGIC;
    ps_pl_irq_i2c1 : out STD_LOGIC;
    ps_pl_irq_uart0 : out STD_LOGIC;
    ps_pl_irq_uart1 : out STD_LOGIC;
    ps_pl_irq_sdio0 : out STD_LOGIC;
    ps_pl_irq_sdio1 : out STD_LOGIC;
    ps_pl_irq_sdio0_wake : out STD_LOGIC;
    ps_pl_irq_sdio1_wake : out STD_LOGIC;
    ps_pl_irq_spi0 : out STD_LOGIC;
    ps_pl_irq_spi1 : out STD_LOGIC;
    ps_pl_irq_qspi : out STD_LOGIC;
    ps_pl_irq_ttc0_0 : out STD_LOGIC;
    ps_pl_irq_ttc0_1 : out STD_LOGIC;
    ps_pl_irq_ttc0_2 : out STD_LOGIC;
    ps_pl_irq_ttc1_0 : out STD_LOGIC;
    ps_pl_irq_ttc1_1 : out STD_LOGIC;
    ps_pl_irq_ttc1_2 : out STD_LOGIC;
    ps_pl_irq_ttc2_0 : out STD_LOGIC;
    ps_pl_irq_ttc2_1 : out STD_LOGIC;
    ps_pl_irq_ttc2_2 : out STD_LOGIC;
    ps_pl_irq_ttc3_0 : out STD_LOGIC;
    ps_pl_irq_ttc3_1 : out STD_LOGIC;
    ps_pl_irq_ttc3_2 : out STD_LOGIC;
    ps_pl_irq_csu_pmu_wdt : out STD_LOGIC;
    ps_pl_irq_lp_wdt : out STD_LOGIC;
    ps_pl_irq_usb3_0_endpoint : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ps_pl_irq_usb3_0_otg : out STD_LOGIC;
    ps_pl_irq_usb3_1_endpoint : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ps_pl_irq_usb3_1_otg : out STD_LOGIC;
    ps_pl_irq_adma_chan : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ps_pl_irq_usb3_0_pmu_wakeup : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ps_pl_irq_gdma_chan : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ps_pl_irq_csu : out STD_LOGIC;
    ps_pl_irq_csu_dma : out STD_LOGIC;
    ps_pl_irq_efuse : out STD_LOGIC;
    ps_pl_irq_xmpu_lpd : out STD_LOGIC;
    ps_pl_irq_ddr_ss : out STD_LOGIC;
    ps_pl_irq_nand : out STD_LOGIC;
    ps_pl_irq_fp_wdt : out STD_LOGIC;
    ps_pl_irq_pcie_msi : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ps_pl_irq_pcie_legacy : out STD_LOGIC;
    ps_pl_irq_pcie_dma : out STD_LOGIC;
    ps_pl_irq_pcie_msc : out STD_LOGIC;
    ps_pl_irq_dport : out STD_LOGIC;
    ps_pl_irq_fpd_apb_int : out STD_LOGIC;
    ps_pl_irq_fpd_atb_error : out STD_LOGIC;
    ps_pl_irq_dpdma : out STD_LOGIC;
    ps_pl_irq_apm_fpd : out STD_LOGIC;
    ps_pl_irq_gpu : out STD_LOGIC;
    ps_pl_irq_sata : out STD_LOGIC;
    ps_pl_irq_xmpu_fpd : out STD_LOGIC;
    ps_pl_irq_apu_cpumnt : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ps_pl_irq_apu_cti : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ps_pl_irq_apu_pmu : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ps_pl_irq_apu_comm : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ps_pl_irq_apu_l2err : out STD_LOGIC;
    ps_pl_irq_apu_exterr : out STD_LOGIC;
    ps_pl_irq_apu_regs : out STD_LOGIC;
    ps_pl_irq_intf_ppd_cci : out STD_LOGIC;
    ps_pl_irq_intf_fpd_smmu : out STD_LOGIC;
    ps_pl_irq_atb_err_lpd : out STD_LOGIC;
    ps_pl_irq_aib_axi : out STD_LOGIC;
    ps_pl_irq_ams : out STD_LOGIC;
    ps_pl_irq_lpd_apm : out STD_LOGIC;
    ps_pl_irq_rtc_alaram : out STD_LOGIC;
    ps_pl_irq_rtc_seconds : out STD_LOGIC;
    ps_pl_irq_clkmon : out STD_LOGIC;
    ps_pl_irq_ipi_channel0 : out STD_LOGIC;
    ps_pl_irq_ipi_channel1 : out STD_LOGIC;
    ps_pl_irq_ipi_channel2 : out STD_LOGIC;
    ps_pl_irq_ipi_channel7 : out STD_LOGIC;
    ps_pl_irq_ipi_channel8 : out STD_LOGIC;
    ps_pl_irq_ipi_channel9 : out STD_LOGIC;
    ps_pl_irq_ipi_channel10 : out STD_LOGIC;
    ps_pl_irq_rpu_pm : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ps_pl_irq_ocm_error : out STD_LOGIC;
    ps_pl_irq_lpd_apb_intr : out STD_LOGIC;
    ps_pl_irq_r5_core0_ecc_error : out STD_LOGIC;
    ps_pl_irq_r5_core1_ecc_error : out STD_LOGIC;
    osc_rtc_clk : out STD_LOGIC;
    pl_pmu_gpi : in STD_LOGIC_VECTOR ( 31 downto 0 );
    pmu_pl_gpo : out STD_LOGIC_VECTOR ( 31 downto 0 );
    aib_pmu_afifm_fpd_ack : in STD_LOGIC;
    aib_pmu_afifm_lpd_ack : in STD_LOGIC;
    pmu_aib_afifm_fpd_req : out STD_LOGIC;
    pmu_aib_afifm_lpd_req : out STD_LOGIC;
    pmu_error_to_pl : out STD_LOGIC_VECTOR ( 46 downto 0 );
    pmu_error_from_pl : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ddrc_ext_refresh_rank0_req : in STD_LOGIC;
    ddrc_ext_refresh_rank1_req : in STD_LOGIC;
    ddrc_refresh_pl_clk : in STD_LOGIC;
    pl_acpinact : in STD_LOGIC;
    pl_clk3 : out STD_LOGIC;
    pl_clk2 : out STD_LOGIC;
    pl_clk1 : out STD_LOGIC;
    pl_clk0 : out STD_LOGIC;
    sacefpd_awuser : in STD_LOGIC_VECTOR ( 15 downto 0 );
    sacefpd_aruser : in STD_LOGIC_VECTOR ( 15 downto 0 );
    test_adc_clk : in STD_LOGIC_VECTOR ( 3 downto 0 );
    test_adc_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    test_adc2_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    test_db : out STD_LOGIC_VECTOR ( 15 downto 0 );
    test_adc_out : out STD_LOGIC_VECTOR ( 19 downto 0 );
    test_ams_osc : out STD_LOGIC_VECTOR ( 7 downto 0 );
    test_mon_data : out STD_LOGIC_VECTOR ( 15 downto 0 );
    test_dclk : in STD_LOGIC;
    test_den : in STD_LOGIC;
    test_dwe : in STD_LOGIC;
    test_daddr : in STD_LOGIC_VECTOR ( 7 downto 0 );
    test_di : in STD_LOGIC_VECTOR ( 15 downto 0 );
    test_drdy : out STD_LOGIC;
    test_do : out STD_LOGIC_VECTOR ( 15 downto 0 );
    test_convst : in STD_LOGIC;
    pstp_pl_clk : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pstp_pl_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    pstp_pl_out : out STD_LOGIC_VECTOR ( 31 downto 0 );
    pstp_pl_ts : in STD_LOGIC_VECTOR ( 31 downto 0 );
    fmio_test_gem_scanmux_1 : in STD_LOGIC;
    fmio_test_gem_scanmux_2 : in STD_LOGIC;
    test_char_mode_fpd_n : in STD_LOGIC;
    test_char_mode_lpd_n : in STD_LOGIC;
    fmio_test_io_char_scan_clock : in STD_LOGIC;
    fmio_test_io_char_scanenable : in STD_LOGIC;
    fmio_test_io_char_scan_in : in STD_LOGIC;
    fmio_test_io_char_scan_out : out STD_LOGIC;
    fmio_test_io_char_scan_reset_n : in STD_LOGIC;
    fmio_char_afifslpd_test_select_n : in STD_LOGIC;
    fmio_char_afifslpd_test_input : in STD_LOGIC;
    fmio_char_afifslpd_test_output : out STD_LOGIC;
    fmio_char_afifsfpd_test_select_n : in STD_LOGIC;
    fmio_char_afifsfpd_test_input : in STD_LOGIC;
    fmio_char_afifsfpd_test_output : out STD_LOGIC;
    io_char_audio_in_test_data : in STD_LOGIC;
    io_char_audio_mux_sel_n : in STD_LOGIC;
    io_char_video_in_test_data : in STD_LOGIC;
    io_char_video_mux_sel_n : in STD_LOGIC;
    io_char_video_out_test_data : out STD_LOGIC;
    io_char_audio_out_test_data : out STD_LOGIC;
    fmio_test_qspi_scanmux_1_n : in STD_LOGIC;
    fmio_test_sdio_scanmux_1 : in STD_LOGIC;
    fmio_test_sdio_scanmux_2 : in STD_LOGIC;
    fmio_sd0_dll_test_in_n : in STD_LOGIC_VECTOR ( 3 downto 0 );
    fmio_sd0_dll_test_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    fmio_sd1_dll_test_in_n : in STD_LOGIC_VECTOR ( 3 downto 0 );
    fmio_sd1_dll_test_out : out STD_LOGIC_VECTOR ( 7 downto 0 );
    test_pl_scan_chopper_si : in STD_LOGIC;
    test_pl_scan_chopper_so : out STD_LOGIC;
    test_pl_scan_chopper_trig : in STD_LOGIC;
    test_pl_scan_clk0 : in STD_LOGIC;
    test_pl_scan_clk1 : in STD_LOGIC;
    test_pl_scan_edt_clk : in STD_LOGIC;
    test_pl_scan_edt_in_apu : in STD_LOGIC;
    test_pl_scan_edt_in_cpu : in STD_LOGIC;
    test_pl_scan_edt_in_ddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    test_pl_scan_edt_in_fp : in STD_LOGIC_VECTOR ( 9 downto 0 );
    test_pl_scan_edt_in_gpu : in STD_LOGIC_VECTOR ( 3 downto 0 );
    test_pl_scan_edt_in_lp : in STD_LOGIC_VECTOR ( 8 downto 0 );
    test_pl_scan_edt_in_usb3 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    test_pl_scan_edt_out_apu : out STD_LOGIC;
    test_pl_scan_edt_out_cpu0 : out STD_LOGIC;
    test_pl_scan_edt_out_cpu1 : out STD_LOGIC;
    test_pl_scan_edt_out_cpu2 : out STD_LOGIC;
    test_pl_scan_edt_out_cpu3 : out STD_LOGIC;
    test_pl_scan_edt_out_ddr : out STD_LOGIC_VECTOR ( 3 downto 0 );
    test_pl_scan_edt_out_fp : out STD_LOGIC_VECTOR ( 9 downto 0 );
    test_pl_scan_edt_out_gpu : out STD_LOGIC_VECTOR ( 3 downto 0 );
    test_pl_scan_edt_out_lp : out STD_LOGIC_VECTOR ( 8 downto 0 );
    test_pl_scan_edt_out_usb3 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    test_pl_scan_edt_update : in STD_LOGIC;
    test_pl_scan_reset_n : in STD_LOGIC;
    test_pl_scanenable : in STD_LOGIC;
    test_pl_scan_pll_reset : in STD_LOGIC;
    test_pl_scan_spare_in0 : in STD_LOGIC;
    test_pl_scan_spare_in1 : in STD_LOGIC;
    test_pl_scan_spare_out0 : out STD_LOGIC;
    test_pl_scan_spare_out1 : out STD_LOGIC;
    test_pl_scan_wrap_clk : in STD_LOGIC;
    test_pl_scan_wrap_ishift : in STD_LOGIC;
    test_pl_scan_wrap_oshift : in STD_LOGIC;
    test_pl_scan_slcr_config_clk : in STD_LOGIC;
    test_pl_scan_slcr_config_rstn : in STD_LOGIC;
    test_pl_scan_slcr_config_si : in STD_LOGIC;
    test_pl_scan_spare_in2 : in STD_LOGIC;
    test_pl_scanenable_slcr_en : in STD_LOGIC;
    test_pl_pll_lock_out : out STD_LOGIC_VECTOR ( 4 downto 0 );
    test_pl_scan_slcr_config_so : out STD_LOGIC;
    tst_rtc_calibreg_in : in STD_LOGIC_VECTOR ( 20 downto 0 );
    tst_rtc_calibreg_out : out STD_LOGIC_VECTOR ( 20 downto 0 );
    tst_rtc_calibreg_we : in STD_LOGIC;
    tst_rtc_clk : in STD_LOGIC;
    tst_rtc_osc_clk_out : out STD_LOGIC;
    tst_rtc_sec_counter_out : out STD_LOGIC_VECTOR ( 31 downto 0 );
    tst_rtc_seconds_raw_int : out STD_LOGIC;
    tst_rtc_testclock_select_n : in STD_LOGIC;
    tst_rtc_tick_counter_out : out STD_LOGIC_VECTOR ( 15 downto 0 );
    tst_rtc_timesetreg_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    tst_rtc_timesetreg_out : out STD_LOGIC_VECTOR ( 31 downto 0 );
    tst_rtc_disable_bat_op : in STD_LOGIC;
    tst_rtc_osc_cntrl_in : in STD_LOGIC_VECTOR ( 3 downto 0 );
    tst_rtc_osc_cntrl_out : out STD_LOGIC_VECTOR ( 3 downto 0 );
    tst_rtc_osc_cntrl_we : in STD_LOGIC;
    tst_rtc_sec_reload : in STD_LOGIC;
    tst_rtc_timesetreg_we : in STD_LOGIC;
    tst_rtc_testmode_n : in STD_LOGIC;
    test_usb0_funcmux_0_n : in STD_LOGIC;
    test_usb1_funcmux_0_n : in STD_LOGIC;
    test_usb0_scanmux_0_n : in STD_LOGIC;
    test_usb1_scanmux_0_n : in STD_LOGIC;
    lpd_pll_test_out : out STD_LOGIC_VECTOR ( 31 downto 0 );
    pl_lpd_pll_test_ck_sel_n : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pl_lpd_pll_test_fract_clk_sel_n : in STD_LOGIC;
    pl_lpd_pll_test_fract_en_n : in STD_LOGIC;
    pl_lpd_pll_test_mux_sel : in STD_LOGIC;
    pl_lpd_pll_test_sel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    fpd_pll_test_out : out STD_LOGIC_VECTOR ( 31 downto 0 );
    pl_fpd_pll_test_ck_sel_n : in STD_LOGIC_VECTOR ( 2 downto 0 );
    pl_fpd_pll_test_fract_clk_sel_n : in STD_LOGIC;
    pl_fpd_pll_test_fract_en_n : in STD_LOGIC;
    pl_fpd_pll_test_mux_sel : in STD_LOGIC_VECTOR ( 1 downto 0 );
    pl_fpd_pll_test_sel : in STD_LOGIC_VECTOR ( 3 downto 0 );
    fmio_char_gem_selection : in STD_LOGIC_VECTOR ( 1 downto 0 );
    fmio_char_gem_test_select_n : in STD_LOGIC;
    fmio_char_gem_test_input : in STD_LOGIC;
    fmio_char_gem_test_output : out STD_LOGIC;
    test_ddr2pl_dcd_skewout : out STD_LOGIC;
    test_pl2ddr_dcd_sample_pulse : in STD_LOGIC;
    test_bscan_en_n : in STD_LOGIC;
    test_bscan_tdi : in STD_LOGIC;
    test_bscan_updatedr : in STD_LOGIC;
    test_bscan_shiftdr : in STD_LOGIC;
    test_bscan_reset_tap_b : in STD_LOGIC;
    test_bscan_misr_jtag_load : in STD_LOGIC;
    test_bscan_intest : in STD_LOGIC;
    test_bscan_extest : in STD_LOGIC;
    test_bscan_clockdr : in STD_LOGIC;
    test_bscan_ac_mode : in STD_LOGIC;
    test_bscan_ac_test : in STD_LOGIC;
    test_bscan_init_memory : in STD_LOGIC;
    test_bscan_mode_c : in STD_LOGIC;
    test_bscan_tdo : out STD_LOGIC;
    i_dbg_l0_txclk : in STD_LOGIC;
    i_dbg_l0_rxclk : in STD_LOGIC;
    i_dbg_l1_txclk : in STD_LOGIC;
    i_dbg_l1_rxclk : in STD_LOGIC;
    i_dbg_l2_txclk : in STD_LOGIC;
    i_dbg_l2_rxclk : in STD_LOGIC;
    i_dbg_l3_txclk : in STD_LOGIC;
    i_dbg_l3_rxclk : in STD_LOGIC;
    i_afe_rx_symbol_clk_by_2_pl : in STD_LOGIC;
    pl_fpd_spare_0_in : in STD_LOGIC;
    pl_fpd_spare_1_in : in STD_LOGIC;
    pl_fpd_spare_2_in : in STD_LOGIC;
    pl_fpd_spare_3_in : in STD_LOGIC;
    pl_fpd_spare_4_in : in STD_LOGIC;
    fpd_pl_spare_0_out : out STD_LOGIC;
    fpd_pl_spare_1_out : out STD_LOGIC;
    fpd_pl_spare_2_out : out STD_LOGIC;
    fpd_pl_spare_3_out : out STD_LOGIC;
    fpd_pl_spare_4_out : out STD_LOGIC;
    pl_lpd_spare_0_in : in STD_LOGIC;
    pl_lpd_spare_1_in : in STD_LOGIC;
    pl_lpd_spare_2_in : in STD_LOGIC;
    pl_lpd_spare_3_in : in STD_LOGIC;
    pl_lpd_spare_4_in : in STD_LOGIC;
    lpd_pl_spare_0_out : out STD_LOGIC;
    lpd_pl_spare_1_out : out STD_LOGIC;
    lpd_pl_spare_2_out : out STD_LOGIC;
    lpd_pl_spare_3_out : out STD_LOGIC;
    lpd_pl_spare_4_out : out STD_LOGIC;
    o_dbg_l0_phystatus : out STD_LOGIC;
    o_dbg_l0_rxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l0_rxdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l0_rxvalid : out STD_LOGIC;
    o_dbg_l0_rxstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    o_dbg_l0_rxelecidle : out STD_LOGIC;
    o_dbg_l0_rstb : out STD_LOGIC;
    o_dbg_l0_txdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l0_txdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l0_rate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l0_powerdown : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l0_txelecidle : out STD_LOGIC;
    o_dbg_l0_txdetrx_lpback : out STD_LOGIC;
    o_dbg_l0_rxpolarity : out STD_LOGIC;
    o_dbg_l0_tx_sgmii_ewrap : out STD_LOGIC;
    o_dbg_l0_rx_sgmii_en_cdet : out STD_LOGIC;
    o_dbg_l0_sata_corerxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l0_sata_corerxdatavalid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l0_sata_coreready : out STD_LOGIC;
    o_dbg_l0_sata_coreclockready : out STD_LOGIC;
    o_dbg_l0_sata_corerxsignaldet : out STD_LOGIC;
    o_dbg_l0_sata_phyctrltxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l0_sata_phyctrltxidle : out STD_LOGIC;
    o_dbg_l0_sata_phyctrltxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l0_sata_phyctrlrxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l0_sata_phyctrltxrst : out STD_LOGIC;
    o_dbg_l0_sata_phyctrlrxrst : out STD_LOGIC;
    o_dbg_l0_sata_phyctrlreset : out STD_LOGIC;
    o_dbg_l0_sata_phyctrlpartial : out STD_LOGIC;
    o_dbg_l0_sata_phyctrlslumber : out STD_LOGIC;
    o_dbg_l1_phystatus : out STD_LOGIC;
    o_dbg_l1_rxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l1_rxdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l1_rxvalid : out STD_LOGIC;
    o_dbg_l1_rxstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    o_dbg_l1_rxelecidle : out STD_LOGIC;
    o_dbg_l1_rstb : out STD_LOGIC;
    o_dbg_l1_txdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l1_txdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l1_rate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l1_powerdown : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l1_txelecidle : out STD_LOGIC;
    o_dbg_l1_txdetrx_lpback : out STD_LOGIC;
    o_dbg_l1_rxpolarity : out STD_LOGIC;
    o_dbg_l1_tx_sgmii_ewrap : out STD_LOGIC;
    o_dbg_l1_rx_sgmii_en_cdet : out STD_LOGIC;
    o_dbg_l1_sata_corerxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l1_sata_corerxdatavalid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l1_sata_coreready : out STD_LOGIC;
    o_dbg_l1_sata_coreclockready : out STD_LOGIC;
    o_dbg_l1_sata_corerxsignaldet : out STD_LOGIC;
    o_dbg_l1_sata_phyctrltxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l1_sata_phyctrltxidle : out STD_LOGIC;
    o_dbg_l1_sata_phyctrltxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l1_sata_phyctrlrxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l1_sata_phyctrltxrst : out STD_LOGIC;
    o_dbg_l1_sata_phyctrlrxrst : out STD_LOGIC;
    o_dbg_l1_sata_phyctrlreset : out STD_LOGIC;
    o_dbg_l1_sata_phyctrlpartial : out STD_LOGIC;
    o_dbg_l1_sata_phyctrlslumber : out STD_LOGIC;
    o_dbg_l2_phystatus : out STD_LOGIC;
    o_dbg_l2_rxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l2_rxdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l2_rxvalid : out STD_LOGIC;
    o_dbg_l2_rxstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    o_dbg_l2_rxelecidle : out STD_LOGIC;
    o_dbg_l2_rstb : out STD_LOGIC;
    o_dbg_l2_txdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l2_txdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l2_rate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l2_powerdown : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l2_txelecidle : out STD_LOGIC;
    o_dbg_l2_txdetrx_lpback : out STD_LOGIC;
    o_dbg_l2_rxpolarity : out STD_LOGIC;
    o_dbg_l2_tx_sgmii_ewrap : out STD_LOGIC;
    o_dbg_l2_rx_sgmii_en_cdet : out STD_LOGIC;
    o_dbg_l2_sata_corerxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l2_sata_corerxdatavalid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l2_sata_coreready : out STD_LOGIC;
    o_dbg_l2_sata_coreclockready : out STD_LOGIC;
    o_dbg_l2_sata_corerxsignaldet : out STD_LOGIC;
    o_dbg_l2_sata_phyctrltxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l2_sata_phyctrltxidle : out STD_LOGIC;
    o_dbg_l2_sata_phyctrltxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l2_sata_phyctrlrxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l2_sata_phyctrltxrst : out STD_LOGIC;
    o_dbg_l2_sata_phyctrlrxrst : out STD_LOGIC;
    o_dbg_l2_sata_phyctrlreset : out STD_LOGIC;
    o_dbg_l2_sata_phyctrlpartial : out STD_LOGIC;
    o_dbg_l2_sata_phyctrlslumber : out STD_LOGIC;
    o_dbg_l3_phystatus : out STD_LOGIC;
    o_dbg_l3_rxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l3_rxdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l3_rxvalid : out STD_LOGIC;
    o_dbg_l3_rxstatus : out STD_LOGIC_VECTOR ( 2 downto 0 );
    o_dbg_l3_rxelecidle : out STD_LOGIC;
    o_dbg_l3_rstb : out STD_LOGIC;
    o_dbg_l3_txdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l3_txdatak : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l3_rate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l3_powerdown : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l3_txelecidle : out STD_LOGIC;
    o_dbg_l3_txdetrx_lpback : out STD_LOGIC;
    o_dbg_l3_rxpolarity : out STD_LOGIC;
    o_dbg_l3_tx_sgmii_ewrap : out STD_LOGIC;
    o_dbg_l3_rx_sgmii_en_cdet : out STD_LOGIC;
    o_dbg_l3_sata_corerxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l3_sata_corerxdatavalid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l3_sata_coreready : out STD_LOGIC;
    o_dbg_l3_sata_coreclockready : out STD_LOGIC;
    o_dbg_l3_sata_corerxsignaldet : out STD_LOGIC;
    o_dbg_l3_sata_phyctrltxdata : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_dbg_l3_sata_phyctrltxidle : out STD_LOGIC;
    o_dbg_l3_sata_phyctrltxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l3_sata_phyctrlrxrate : out STD_LOGIC_VECTOR ( 1 downto 0 );
    o_dbg_l3_sata_phyctrltxrst : out STD_LOGIC;
    o_dbg_l3_sata_phyctrlrxrst : out STD_LOGIC;
    o_dbg_l3_sata_phyctrlreset : out STD_LOGIC;
    o_dbg_l3_sata_phyctrlpartial : out STD_LOGIC;
    o_dbg_l3_sata_phyctrlslumber : out STD_LOGIC;
    dbg_path_fifo_bypass : out STD_LOGIC;
    i_afe_pll_pd_hs_clock_r : in STD_LOGIC;
    i_afe_mode : in STD_LOGIC;
    i_bgcal_afe_mode : in STD_LOGIC;
    o_afe_cmn_calib_comp_out : out STD_LOGIC;
    i_afe_cmn_bg_enable_low_leakage : in STD_LOGIC;
    i_afe_cmn_bg_iso_ctrl_bar : in STD_LOGIC;
    i_afe_cmn_bg_pd : in STD_LOGIC;
    i_afe_cmn_bg_pd_bg_ok : in STD_LOGIC;
    i_afe_cmn_bg_pd_ptat : in STD_LOGIC;
    i_afe_cmn_calib_en_iconst : in STD_LOGIC;
    i_afe_cmn_calib_enable_low_leakage : in STD_LOGIC;
    i_afe_cmn_calib_iso_ctrl_bar : in STD_LOGIC;
    o_afe_pll_dco_count : out STD_LOGIC_VECTOR ( 12 downto 0 );
    o_afe_pll_clk_sym_hs : out STD_LOGIC;
    o_afe_pll_fbclk_frac : out STD_LOGIC;
    o_afe_rx_pipe_lfpsbcn_rxelecidle : out STD_LOGIC;
    o_afe_rx_pipe_sigdet : out STD_LOGIC;
    o_afe_rx_symbol : out STD_LOGIC_VECTOR ( 19 downto 0 );
    o_afe_rx_symbol_clk_by_2 : out STD_LOGIC;
    o_afe_rx_uphy_save_calcode : out STD_LOGIC;
    o_afe_rx_uphy_startloop_buf : out STD_LOGIC;
    o_afe_rx_uphy_rx_calib_done : out STD_LOGIC;
    i_afe_rx_rxpma_rstb : in STD_LOGIC;
    i_afe_rx_uphy_restore_calcode_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    i_afe_rx_pipe_rxeqtraining : in STD_LOGIC;
    i_afe_rx_iso_hsrx_ctrl_bar : in STD_LOGIC;
    i_afe_rx_iso_lfps_ctrl_bar : in STD_LOGIC;
    i_afe_rx_iso_sigdet_ctrl_bar : in STD_LOGIC;
    i_afe_rx_hsrx_clock_stop_req : in STD_LOGIC;
    o_afe_rx_uphy_save_calcode_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    o_afe_rx_hsrx_clock_stop_ack : out STD_LOGIC;
    o_afe_pg_avddcr : out STD_LOGIC;
    o_afe_pg_avddio : out STD_LOGIC;
    o_afe_pg_dvddcr : out STD_LOGIC;
    o_afe_pg_static_avddcr : out STD_LOGIC;
    o_afe_pg_static_avddio : out STD_LOGIC;
    i_pll_afe_mode : in STD_LOGIC;
    i_afe_pll_coarse_code : in STD_LOGIC_VECTOR ( 10 downto 0 );
    i_afe_pll_en_clock_hs_div2 : in STD_LOGIC;
    i_afe_pll_fbdiv : in STD_LOGIC_VECTOR ( 15 downto 0 );
    i_afe_pll_load_fbdiv : in STD_LOGIC;
    i_afe_pll_pd : in STD_LOGIC;
    i_afe_pll_pd_pfd : in STD_LOGIC;
    i_afe_pll_rst_fdbk_div : in STD_LOGIC;
    i_afe_pll_startloop : in STD_LOGIC;
    i_afe_pll_v2i_code : in STD_LOGIC_VECTOR ( 5 downto 0 );
    i_afe_pll_v2i_prog : in STD_LOGIC_VECTOR ( 4 downto 0 );
    i_afe_pll_vco_cnt_window : in STD_LOGIC;
    i_afe_rx_mphy_gate_symbol_clk : in STD_LOGIC;
    i_afe_rx_mphy_mux_hsb_ls : in STD_LOGIC;
    i_afe_rx_pipe_rx_term_enable : in STD_LOGIC;
    i_afe_rx_uphy_biasgen_iconst_core_mirror_enable : in STD_LOGIC;
    i_afe_rx_uphy_biasgen_iconst_io_mirror_enable : in STD_LOGIC;
    i_afe_rx_uphy_biasgen_irconst_core_mirror_enable : in STD_LOGIC;
    i_afe_rx_uphy_enable_cdr : in STD_LOGIC;
    i_afe_rx_uphy_enable_low_leakage : in STD_LOGIC;
    i_afe_rx_rxpma_refclk_dig : in STD_LOGIC;
    i_afe_rx_uphy_hsrx_rstb : in STD_LOGIC;
    i_afe_rx_uphy_pdn_hs_des : in STD_LOGIC;
    i_afe_rx_uphy_pd_samp_c2c : in STD_LOGIC;
    i_afe_rx_uphy_pd_samp_c2c_eclk : in STD_LOGIC;
    i_afe_rx_uphy_pso_clk_lane : in STD_LOGIC;
    i_afe_rx_uphy_pso_eq : in STD_LOGIC;
    i_afe_rx_uphy_pso_hsrxdig : in STD_LOGIC;
    i_afe_rx_uphy_pso_iqpi : in STD_LOGIC;
    i_afe_rx_uphy_pso_lfpsbcn : in STD_LOGIC;
    i_afe_rx_uphy_pso_samp_flops : in STD_LOGIC;
    i_afe_rx_uphy_pso_sigdet : in STD_LOGIC;
    i_afe_rx_uphy_restore_calcode : in STD_LOGIC;
    i_afe_rx_uphy_run_calib : in STD_LOGIC;
    i_afe_rx_uphy_rx_lane_polarity_swap : in STD_LOGIC;
    i_afe_rx_uphy_startloop_pll : in STD_LOGIC;
    i_afe_rx_uphy_hsclk_division_factor : in STD_LOGIC_VECTOR ( 1 downto 0 );
    i_afe_rx_uphy_rx_pma_opmode : in STD_LOGIC_VECTOR ( 7 downto 0 );
    i_afe_tx_enable_hsclk_division : in STD_LOGIC_VECTOR ( 1 downto 0 );
    i_afe_tx_enable_ldo : in STD_LOGIC;
    i_afe_tx_enable_ref : in STD_LOGIC;
    i_afe_tx_enable_supply_hsclk : in STD_LOGIC;
    i_afe_tx_enable_supply_pipe : in STD_LOGIC;
    i_afe_tx_enable_supply_serializer : in STD_LOGIC;
    i_afe_tx_enable_supply_uphy : in STD_LOGIC;
    i_afe_tx_hs_ser_rstb : in STD_LOGIC;
    i_afe_tx_hs_symbol : in STD_LOGIC_VECTOR ( 19 downto 0 );
    i_afe_tx_mphy_tx_ls_data : in STD_LOGIC;
    i_afe_tx_pipe_tx_enable_idle_mode : in STD_LOGIC_VECTOR ( 1 downto 0 );
    i_afe_tx_pipe_tx_enable_lfps : in STD_LOGIC_VECTOR ( 1 downto 0 );
    i_afe_tx_pipe_tx_enable_rxdet : in STD_LOGIC;
    i_afe_TX_uphy_txpma_opmode : in STD_LOGIC_VECTOR ( 7 downto 0 );
    i_afe_TX_pmadig_digital_reset_n : in STD_LOGIC;
    i_afe_TX_serializer_rst_rel : in STD_LOGIC;
    i_afe_TX_pll_symb_clk_2 : in STD_LOGIC;
    i_afe_TX_ana_if_rate : in STD_LOGIC_VECTOR ( 1 downto 0 );
    i_afe_TX_en_dig_sublp_mode : in STD_LOGIC;
    i_afe_TX_LPBK_SEL : in STD_LOGIC_VECTOR ( 2 downto 0 );
    i_afe_TX_iso_ctrl_bar : in STD_LOGIC;
    i_afe_TX_ser_iso_ctrl_bar : in STD_LOGIC;
    i_afe_TX_lfps_clk : in STD_LOGIC;
    i_afe_TX_serializer_rstb : in STD_LOGIC;
    o_afe_TX_dig_reset_rel_ack : out STD_LOGIC;
    o_afe_TX_pipe_TX_dn_rxdet : out STD_LOGIC;
    o_afe_TX_pipe_TX_dp_rxdet : out STD_LOGIC;
    i_afe_tx_pipe_tx_fast_est_common_mode : in STD_LOGIC;
    o_dbg_l0_txclk : out STD_LOGIC;
    o_dbg_l0_rxclk : out STD_LOGIC;
    o_dbg_l1_txclk : out STD_LOGIC;
    o_dbg_l1_rxclk : out STD_LOGIC;
    o_dbg_l2_txclk : out STD_LOGIC;
    o_dbg_l2_rxclk : out STD_LOGIC;
    o_dbg_l3_txclk : out STD_LOGIC;
    o_dbg_l3_rxclk : out STD_LOGIC
  );
  attribute C_DP_USE_AUDIO : integer;
  attribute C_DP_USE_AUDIO of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_DP_USE_VIDEO : integer;
  attribute C_DP_USE_VIDEO of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_EMIO_GPIO_WIDTH : integer;
  attribute C_EMIO_GPIO_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 1;
  attribute C_EN_EMIO_TRACE : integer;
  attribute C_EN_EMIO_TRACE of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_EN_FIFO_ENET0 : string;
  attribute C_EN_FIFO_ENET0 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "0";
  attribute C_EN_FIFO_ENET1 : string;
  attribute C_EN_FIFO_ENET1 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "0";
  attribute C_EN_FIFO_ENET2 : string;
  attribute C_EN_FIFO_ENET2 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "0";
  attribute C_EN_FIFO_ENET3 : string;
  attribute C_EN_FIFO_ENET3 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "0";
  attribute C_MAXIGP0_DATA_WIDTH : integer;
  attribute C_MAXIGP0_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 32;
  attribute C_MAXIGP1_DATA_WIDTH : integer;
  attribute C_MAXIGP1_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 32;
  attribute C_MAXIGP2_DATA_WIDTH : integer;
  attribute C_MAXIGP2_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 32;
  attribute C_NUM_F2P_0_INTR_INPUTS : integer;
  attribute C_NUM_F2P_0_INTR_INPUTS of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 1;
  attribute C_NUM_F2P_1_INTR_INPUTS : integer;
  attribute C_NUM_F2P_1_INTR_INPUTS of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 1;
  attribute C_NUM_FABRIC_RESETS : integer;
  attribute C_NUM_FABRIC_RESETS of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 1;
  attribute C_PL_CLK0_BUF : string;
  attribute C_PL_CLK0_BUF of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "TRUE";
  attribute C_PL_CLK1_BUF : string;
  attribute C_PL_CLK1_BUF of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "FALSE";
  attribute C_PL_CLK2_BUF : string;
  attribute C_PL_CLK2_BUF of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "FALSE";
  attribute C_PL_CLK3_BUF : string;
  attribute C_PL_CLK3_BUF of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "FALSE";
  attribute C_SAXIGP0_DATA_WIDTH : integer;
  attribute C_SAXIGP0_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 64;
  attribute C_SAXIGP1_DATA_WIDTH : integer;
  attribute C_SAXIGP1_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 128;
  attribute C_SAXIGP2_DATA_WIDTH : integer;
  attribute C_SAXIGP2_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 128;
  attribute C_SAXIGP3_DATA_WIDTH : integer;
  attribute C_SAXIGP3_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 128;
  attribute C_SAXIGP4_DATA_WIDTH : integer;
  attribute C_SAXIGP4_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 128;
  attribute C_SAXIGP5_DATA_WIDTH : integer;
  attribute C_SAXIGP5_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 128;
  attribute C_SAXIGP6_DATA_WIDTH : integer;
  attribute C_SAXIGP6_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 128;
  attribute C_SD0_INTERNAL_BUS_WIDTH : integer;
  attribute C_SD0_INTERNAL_BUS_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 8;
  attribute C_SD1_INTERNAL_BUS_WIDTH : integer;
  attribute C_SD1_INTERNAL_BUS_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 8;
  attribute C_TRACE_DATA_WIDTH : integer;
  attribute C_TRACE_DATA_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 32;
  attribute C_TRACE_PIPELINE_WIDTH : integer;
  attribute C_TRACE_PIPELINE_WIDTH of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 8;
  attribute C_USE_DEBUG_TEST : integer;
  attribute C_USE_DEBUG_TEST of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_USE_DIFF_RW_CLK_GP0 : integer;
  attribute C_USE_DIFF_RW_CLK_GP0 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_USE_DIFF_RW_CLK_GP1 : integer;
  attribute C_USE_DIFF_RW_CLK_GP1 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_USE_DIFF_RW_CLK_GP2 : integer;
  attribute C_USE_DIFF_RW_CLK_GP2 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_USE_DIFF_RW_CLK_GP3 : integer;
  attribute C_USE_DIFF_RW_CLK_GP3 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_USE_DIFF_RW_CLK_GP4 : integer;
  attribute C_USE_DIFF_RW_CLK_GP4 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_USE_DIFF_RW_CLK_GP5 : integer;
  attribute C_USE_DIFF_RW_CLK_GP5 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute C_USE_DIFF_RW_CLK_GP6 : integer;
  attribute C_USE_DIFF_RW_CLK_GP6 of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is 0;
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "zynqmpsoc_zynq_ultra_ps_e_0_0.hwdef";
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e";
  attribute PSS_IO : string;
  attribute PSS_IO of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "Signal Name, DiffPair Type, DiffPair Signal,Direction, Site Type, IO Standard, Drive (mA), Slew Rate, Pull Type, IBIS Model, ODT, OUTPUT_IMPEDANCE " & LF &
 "QSPI_X4_SCLK_OUT, , , OUT, PS_MIO0_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MISO_MO1, , , INOUT, PS_MIO1_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO2, , , INOUT, PS_MIO2_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO3, , , INOUT, PS_MIO3_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MOSI_MI0, , , INOUT, PS_MIO4_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_N_SS_OUT, , , OUT, PS_MIO5_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_CLK_FOR_LPBK, , , OUT, PS_MIO6_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_N_SS_OUT_UPPER, , , OUT, PS_MIO7_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[0], , , INOUT, PS_MIO8_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[1], , , INOUT, PS_MIO9_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[2], , , INOUT, PS_MIO10_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[3], , , INOUT, PS_MIO11_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_SCLK_OUT_UPPER, , , OUT, PS_MIO12_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO0_GPIO0[13], , , INOUT, PS_MIO13_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C0_SCL_OUT, , , INOUT, PS_MIO14_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C0_SDA_OUT, , , INOUT, PS_MIO15_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C1_SCL_OUT, , , INOUT, PS_MIO16_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C1_SDA_OUT, , , INOUT, PS_MIO17_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART0_RXD, , , IN, PS_MIO18_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART0_TXD, , , OUT, PS_MIO19_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART1_TXD, , , OUT, PS_MIO20_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART1_RXD, , , IN, PS_MIO21_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO0_GPIO0[22], , , INOUT, PS_MIO22_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO0_GPIO0[23], , , INOUT, PS_MIO23_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "CAN1_PHY_TX, , , OUT, PS_MIO24_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "CAN1_PHY_RX, , , IN, PS_MIO25_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO1_GPIO1[26], , , INOUT, PS_MIO26_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_AUX_DATA_OUT, , , OUT, PS_MIO27_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_HOT_PLUG_DETECT, , , IN, PS_MIO28_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_AUX_DATA_OE, , , OUT, PS_MIO29_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_AUX_DATA_IN, , , IN, PS_MIO30_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PCIE_ROOT_RESET_N, , , OUT, PS_MIO31_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[0], , , OUT, PS_MIO32_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[1], , , OUT, PS_MIO33_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[2], , , OUT, PS_MIO34_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[3], , , OUT, PS_MIO35_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[4], , , OUT, PS_MIO36_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[5], , , OUT, PS_MIO37_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO1_GPIO1[38], , , INOUT, PS_MIO38_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[4], , , INOUT, PS_MIO39_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[5], , , INOUT, PS_MIO40_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[6], , , INOUT, PS_MIO41_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[7], , , INOUT, PS_MIO42_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO1_GPIO1[43], , , INOUT, PS_MIO43_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_WP, , , IN, PS_MIO44_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_CD_N, , , IN, PS_MIO45_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[0], , , INOUT, PS_MIO46_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[1], , , INOUT, PS_MIO47_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[2], , , INOUT, PS_MIO48_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[3], , , INOUT, PS_MIO49_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_CMD_OUT, , , INOUT, PS_MIO50_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_CLK_OUT, , , OUT, PS_MIO51_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_CLK_IN, , , IN, PS_MIO52_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_DIR, , , IN, PS_MIO53_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[2], , , INOUT, PS_MIO54_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_NXT, , , IN, PS_MIO55_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[0], , , INOUT, PS_MIO56_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[1], , , INOUT, PS_MIO57_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_STP, , , OUT, PS_MIO58_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[3], , , INOUT, PS_MIO59_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[4], , , INOUT, PS_MIO60_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[5], , , INOUT, PS_MIO61_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[6], , , INOUT, PS_MIO62_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[7], , , INOUT, PS_MIO63_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TX_CLK, , , OUT, PS_MIO64_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[0], , , OUT, PS_MIO65_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[1], , , OUT, PS_MIO66_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[2], , , OUT, PS_MIO67_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[3], , , OUT, PS_MIO68_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TX_CTL, , , OUT, PS_MIO69_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RX_CLK, , , IN, PS_MIO70_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[0], , , IN, PS_MIO71_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[1], , , IN, PS_MIO72_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[2], , , IN, PS_MIO73_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[3], , , IN, PS_MIO74_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RX_CTL, , , IN, PS_MIO75_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "MDIO3_GEM3_MDC, , , OUT, PS_MIO76_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "MDIO3_GEM3_MDIO_OUT, , , INOUT, PS_MIO77_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PCIE_MGTREFCLK0N, , , IN, PS_MGTREFCLK0N_505, , , , , ,,  " & LF &
 "PCIE_MGTREFCLK0P, , , IN, PS_MGTREFCLK0P_505, , , , , ,,  " & LF &
 "PS_REF_CLK, , , IN, PS_REF_CLK_503, LVCMOS18, 2, SLOW, , PS_MIO_LVCMOS18_S_2,,  " & LF &
 "PS_JTAG_TCK, , , IN, PS_JTAG_TCK_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_JTAG_TDI, , , IN, PS_JTAG_TDI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_JTAG_TDO, , , OUT, PS_JTAG_TDO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_JTAG_TMS, , , IN, PS_JTAG_TMS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_DONE, , , OUT, PS_DONE_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_ERROR_OUT, , , OUT, PS_ERROR_OUT_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_ERROR_STATUS, , , OUT, PS_ERROR_STATUS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_INIT_B, , , INOUT, PS_INIT_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE0, , , IN, PS_MODE0_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE1, , , IN, PS_MODE1_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE2, , , IN, PS_MODE2_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE3, , , IN, PS_MODE3_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_PADI, , , IN, PS_PADI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_PADO, , , OUT, PS_PADO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_POR_B, , , IN, PS_POR_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_PROG_B, , , IN, PS_PROG_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_SRST_B, , , IN, PS_SRST_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PCIE_MGTRRXN0, , , IN, PS_MGTRRXN0_505, , , , , ,,  " & LF &
 "PCIE_MGTRRXP0, , , IN, PS_MGTRRXP0_505, , , , , ,,  " & LF &
 "PCIE_MGTRTXN0, , , OUT, PS_MGTRTXN0_505, , , , , ,,  " & LF &
 "PCIE_MGTRTXP0, , , OUT, PS_MGTRTXP0_505, , , , , ,,  " & LF &
 "SATA1_MGTREFCLK1N, , , IN, PS_MGTREFCLK1N_505, , , , , ,,  " & LF &
 "SATA1_MGTREFCLK1P, , , IN, PS_MGTREFCLK1P_505, , , , , ,,  " & LF &
 "DP0_MGTRRXN1, , , IN, PS_MGTRRXN1_505, , , , , ,,  " & LF &
 "DP0_MGTRRXP1, , , IN, PS_MGTRRXP1_505, , , , , ,,  " & LF &
 "DP0_MGTRTXN1, , , OUT, PS_MGTRTXN1_505, , , , , ,,  " & LF &
 "DP0_MGTRTXP1, , , OUT, PS_MGTRTXP1_505, , , , , ,,  " & LF &
 "USB0_MGTREFCLK2N, , , IN, PS_MGTREFCLK2N_505, , , , , ,,  " & LF &
 "USB0_MGTREFCLK2P, , , IN, PS_MGTREFCLK2P_505, , , , , ,,  " & LF &
 "USB0_MGTRRXN2, , , IN, PS_MGTRRXN2_505, , , , , ,,  " & LF &
 "USB0_MGTRRXP2, , , IN, PS_MGTRRXP2_505, , , , , ,,  " & LF &
 "USB0_MGTRTXN2, , , OUT, PS_MGTRTXN2_505, , , , , ,,  " & LF &
 "USB0_MGTRTXP2, , , OUT, PS_MGTRTXP2_505, , , , , ,,  " & LF &
 "DP0_MGTREFCLK3N, , , IN, PS_MGTREFCLK3N_505, , , , , ,,  " & LF &
 "DP0_MGTREFCLK3P, , , IN, PS_MGTREFCLK3P_505, , , , , ,,  " & LF &
 "SATA1_MGTRRXN3, , , IN, PS_MGTRRXN3_505, , , , , ,,  " & LF &
 "SATA1_MGTRRXP3, , , IN, PS_MGTRRXP3_505, , , , , ,,  " & LF &
 "SATA1_MGTRTXN3, , , OUT, PS_MGTRTXN3_505, , , , , ,,  " & LF &
 "SATA1_MGTRTXP3, , , OUT, PS_MGTRTXP3_505, , , , , ,, " & LF &
 " DDR4_RAM_RST_N, , , OUT, PS_DDR_RAM_RST_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ACT_N, , , OUT, PS_DDR_ACT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_PARITY, , , OUT, PS_DDR_PARITY_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ALERT_N, , , IN, PS_DDR_ALERT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_CK0, P, DDR4_CK_N0, OUT, PS_DDR_CK0_504, DDR4, , , ,PS_DDR4_CK_OUT34_P, RTT_NONE, 34" & LF &
 " DDR4_CK_N0, N, DDR4_CK0, OUT, PS_DDR_CK_N0_504, DDR4, , , ,PS_DDR4_CK_OUT34_N, RTT_NONE, 34" & LF &
 " DDR4_CKE0, , , OUT, PS_DDR_CKE0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_CS_N0, , , OUT, PS_DDR_CS_N0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ODT0, , , OUT, PS_DDR_ODT0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BG0, , , OUT, PS_DDR_BG0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BG1, , , OUT, PS_DDR_BG1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BA0, , , OUT, PS_DDR_BA0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BA1, , , OUT, PS_DDR_BA1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ZQ, , , INOUT, PS_DDR_ZQ_504, DDR4, , , ,, , " & LF &
 " DDR4_A0, , , OUT, PS_DDR_A0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A1, , , OUT, PS_DDR_A1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A2, , , OUT, PS_DDR_A2_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A3, , , OUT, PS_DDR_A3_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A4, , , OUT, PS_DDR_A4_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A5, , , OUT, PS_DDR_A5_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A6, , , OUT, PS_DDR_A6_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A7, , , OUT, PS_DDR_A7_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A8, , , OUT, PS_DDR_A8_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A9, , , OUT, PS_DDR_A9_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A10, , , OUT, PS_DDR_A10_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A11, , , OUT, PS_DDR_A11_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A12, , , OUT, PS_DDR_A12_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A13, , , OUT, PS_DDR_A13_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A14, , , OUT, PS_DDR_A14_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A15, , , OUT, PS_DDR_A15_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_DQS_P0, P, DDR4_DQS_N0, INOUT, PS_DDR_DQS_P0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P1, P, DDR4_DQS_N1, INOUT, PS_DDR_DQS_P1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P2, P, DDR4_DQS_N2, INOUT, PS_DDR_DQS_P2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P3, P, DDR4_DQS_N3, INOUT, PS_DDR_DQS_P3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P4, P, DDR4_DQS_N4, INOUT, PS_DDR_DQS_P4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P5, P, DDR4_DQS_N5, INOUT, PS_DDR_DQS_P5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P6, P, DDR4_DQS_N6, INOUT, PS_DDR_DQS_P6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P7, P, DDR4_DQS_N7, INOUT, PS_DDR_DQS_P7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_N0, N, DDR4_DQS_P0, INOUT, PS_DDR_DQS_N0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N1, N, DDR4_DQS_P1, INOUT, PS_DDR_DQS_N1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N2, N, DDR4_DQS_P2, INOUT, PS_DDR_DQS_N2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N3, N, DDR4_DQS_P3, INOUT, PS_DDR_DQS_N3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N4, N, DDR4_DQS_P4, INOUT, PS_DDR_DQS_N4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N5, N, DDR4_DQS_P5, INOUT, PS_DDR_DQS_N5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N6, N, DDR4_DQS_P6, INOUT, PS_DDR_DQS_N6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N7, N, DDR4_DQS_P7, INOUT, PS_DDR_DQS_N7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DM0, , , OUT, PS_DDR_DM0_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM1, , , OUT, PS_DDR_DM1_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM2, , , OUT, PS_DDR_DM2_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM3, , , OUT, PS_DDR_DM3_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM4, , , OUT, PS_DDR_DM4_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM5, , , OUT, PS_DDR_DM5_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM6, , , OUT, PS_DDR_DM6_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM7, , , OUT, PS_DDR_DM7_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DQ0, , , INOUT, PS_DDR_DQ0_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ1, , , INOUT, PS_DDR_DQ1_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ2, , , INOUT, PS_DDR_DQ2_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ3, , , INOUT, PS_DDR_DQ3_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ4, , , INOUT, PS_DDR_DQ4_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ5, , , INOUT, PS_DDR_DQ5_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ6, , , INOUT, PS_DDR_DQ6_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ7, , , INOUT, PS_DDR_DQ7_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ8, , , INOUT, PS_DDR_DQ8_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ9, , , INOUT, PS_DDR_DQ9_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ10, , , INOUT, PS_DDR_DQ10_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ11, , , INOUT, PS_DDR_DQ11_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ12, , , INOUT, PS_DDR_DQ12_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ13, , , INOUT, PS_DDR_DQ13_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ14, , , INOUT, PS_DDR_DQ14_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ15, , , INOUT, PS_DDR_DQ15_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ16, , , INOUT, PS_DDR_DQ16_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ17, , , INOUT, PS_DDR_DQ17_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ18, , , INOUT, PS_DDR_DQ18_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ19, , , INOUT, PS_DDR_DQ19_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ20, , , INOUT, PS_DDR_DQ20_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ21, , , INOUT, PS_DDR_DQ21_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ22, , , INOUT, PS_DDR_DQ22_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ23, , , INOUT, PS_DDR_DQ23_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ24, , , INOUT, PS_DDR_DQ24_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ25, , , INOUT, PS_DDR_DQ25_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ26, , , INOUT, PS_DDR_DQ26_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ27, , , INOUT, PS_DDR_DQ27_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ28, , , INOUT, PS_DDR_DQ28_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ29, , , INOUT, PS_DDR_DQ29_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ30, , , INOUT, PS_DDR_DQ30_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ31, , , INOUT, PS_DDR_DQ31_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ32, , , INOUT, PS_DDR_DQ32_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ33, , , INOUT, PS_DDR_DQ33_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ34, , , INOUT, PS_DDR_DQ34_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ35, , , INOUT, PS_DDR_DQ35_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ36, , , INOUT, PS_DDR_DQ36_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ37, , , INOUT, PS_DDR_DQ37_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ38, , , INOUT, PS_DDR_DQ38_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ39, , , INOUT, PS_DDR_DQ39_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ40, , , INOUT, PS_DDR_DQ40_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ41, , , INOUT, PS_DDR_DQ41_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ42, , , INOUT, PS_DDR_DQ42_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ43, , , INOUT, PS_DDR_DQ43_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ44, , , INOUT, PS_DDR_DQ44_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ45, , , INOUT, PS_DDR_DQ45_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ46, , , INOUT, PS_DDR_DQ46_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ47, , , INOUT, PS_DDR_DQ47_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ48, , , INOUT, PS_DDR_DQ48_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ49, , , INOUT, PS_DDR_DQ49_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ50, , , INOUT, PS_DDR_DQ50_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ51, , , INOUT, PS_DDR_DQ51_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ52, , , INOUT, PS_DDR_DQ52_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ53, , , INOUT, PS_DDR_DQ53_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ54, , , INOUT, PS_DDR_DQ54_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ55, , , INOUT, PS_DDR_DQ55_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ56, , , INOUT, PS_DDR_DQ56_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ57, , , INOUT, PS_DDR_DQ57_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ58, , , INOUT, PS_DDR_DQ58_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ59, , , INOUT, PS_DDR_DQ59_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ60, , , INOUT, PS_DDR_DQ60_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ61, , , INOUT, PS_DDR_DQ61_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ62, , , INOUT, PS_DDR_DQ62_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ63, , , INOUT, PS_DDR_DQ63_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34";
  attribute PSS_JITTER : string;
  attribute PSS_JITTER of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "<PSS_EXTERNAL_CLOCKS><EXTERNAL_CLOCK name={PLCLK[0]} clock_external_divide={20} vco_name={IOPLL} vco_freq={3000.000} vco_internal_divide={2}/></PSS_EXTERNAL_CLOCKS>";
  attribute PSS_POWER : string;
  attribute PSS_POWER of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e : entity is "<BLOCKTYPE name={PS8}> <PS8><FPD><PROCESSSORS><PROCESSOR name={Cortex A-53} numCores={4} L2Cache={Enable} clockFreq={1200.000000} load={0.5}/><PROCESSOR name={GPU Mali-400 MP} numCores={2} clockFreq={500.000000} load={0.5} /></PROCESSSORS><PLLS><PLL domain={APU} vco={2399.976} /><PLL domain={DDR} vco={2099.979} /><PLL domain={Video} vco={2999.970} /></PLLS><MEMORY memType={DDR4} dataWidth={8} clockFreq={1050.000} readRate={0.5} writeRate={0.5} cmdAddressActivity={0.5} /><SERDES><GT name={PCIe} standard={Gen2} lanes={1} usageRate={0.5} /><GT name={SATA} standard={SATA3} lanes={1} usageRate={0.5} /><GT name={Display Port} standard={SVGA-60 (800x600)} lanes={1} usageRate={0.5} />clockFreq={60} /><GT name={USB3} standard={USB3.0} lanes={1}usageRate={0.5} /><GT name={SGMII} standard={SGMII} lanes={0} usageRate={0.5} /></SERDES><AFI master={2} slave={1} clockFreq={75.000} usageRate={0.5} /><FPINTERCONNECT clockFreq={667} Bandwidth={Low} /></FPD><LPD><PROCESSSORS><PROCESSOR name={Cortex R-5} usage={Enable} TCM={Enable} OCM={Enable} clockFreq={500.000000} load={0.5}/></PROCESSSORS><PLLS><PLL domain={IO} vco={2999.970} /><PLL domain={RPLL} vco={1499.985} /></PLLS><CSUPMU><Unit name={CSU} usageRate={0.5} clockFreq={180} /><Unit name={PMU} usageRate={0.5} clockFreq={180} /></CSUPMU><GPIO><Bank ioBank={VCC_PSIO0} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO1} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO2} number={0} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO3} number={16} io_standard={LVCMOS 1.8V} /></GPIO><IOINTERFACES> <IO name={QSPI} io_standard={} ioBank={VCC_PSIO0} clockFreq={125.000000} inputs={0} outputs={5} inouts={8} usageRate={0.5}/><IO name={NAND 3.1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={USB0} io_standard={} ioBank={VCC_PSIO2} clockFreq={250.000000} inputs={3} outputs={1} inouts={8} usageRate={0.5}/><IO name={USB1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth3} io_standard={} ioBank={VCC_PSIO2} clockFreq={125.000000} inputs={6} outputs={6} inouts={0} usageRate={0.5}/><IO name={GPIO 0} io_standard={} ioBank={VCC_PSIO0} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 1} io_standard={} ioBank={VCC_PSIO1} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GPIO 3} io_standard={} ioBank={VCC_PSIO3} clockFreq={1} inputs={} outputs={} inouts={16} usageRate={0.5}/><IO name={UART0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={UART1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={I2C0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={I2C1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={SPI0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SPI1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={SD0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SD1} io_standard={} ioBank={VCC_PSIO1} clockFreq={187.500000} inputs={2} outputs={1} inouts={9} usageRate={0.5}/><IO name={Trace} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={TTC0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC2} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC3} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={PJTAG} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={DPAUX} io_standard={} ioBank={VCC_PSIO1} clockFreq={} inputs={2} outputs={2} inouts={0} usageRate={0.5}/><IO name={WDT0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={WDT1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/></IOINTERFACES><AFI master={0} slave={0} clockFreq={333.333} usageRate={0.5} /><LPINTERCONNECT clockFreq={667} Bandwidth={High} /></LPD></PS8></BLOCKTYPE>/>";
end zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e;

architecture STRUCTURE of zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e is
  signal \<const0>\ : STD_LOGIC;
  signal \<const1>\ : STD_LOGIC;
  signal \^emio_enet0_mdio_t_n\ : STD_LOGIC;
  signal \^emio_enet1_mdio_t_n\ : STD_LOGIC;
  signal \^emio_enet2_mdio_t_n\ : STD_LOGIC;
  signal \^emio_enet3_mdio_t_n\ : STD_LOGIC;
  signal \^emio_gpio_t_n\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^emio_i2c0_scl_t_n\ : STD_LOGIC;
  signal \^emio_i2c0_sda_t_n\ : STD_LOGIC;
  signal \^emio_i2c1_scl_t_n\ : STD_LOGIC;
  signal \^emio_i2c1_sda_t_n\ : STD_LOGIC;
  signal emio_sdio0_cmdena_i : STD_LOGIC;
  signal emio_sdio0_dataena_i : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal emio_sdio1_cmdena_i : STD_LOGIC;
  signal emio_sdio1_dataena_i : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \^emio_spi0_mo_t_n\ : STD_LOGIC;
  signal \^emio_spi0_sclk_t_n\ : STD_LOGIC;
  signal \^emio_spi0_so_t_n\ : STD_LOGIC;
  signal \^emio_spi0_ss_n_t_n\ : STD_LOGIC;
  signal \^emio_spi1_mo_t_n\ : STD_LOGIC;
  signal \^emio_spi1_sclk_t_n\ : STD_LOGIC;
  signal \^emio_spi1_so_t_n\ : STD_LOGIC;
  signal \^emio_spi1_ss_n_t_n\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC;
  signal pl_clk_unbuffered : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^trace_clk_out\ : STD_LOGIC;
  signal \trace_ctl_pipe[0]\ : STD_LOGIC;
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of \trace_ctl_pipe[0]\ : signal is "true";
  signal \trace_ctl_pipe[1]\ : STD_LOGIC;
  attribute RTL_KEEP of \trace_ctl_pipe[1]\ : signal is "true";
  signal \trace_ctl_pipe[2]\ : STD_LOGIC;
  attribute RTL_KEEP of \trace_ctl_pipe[2]\ : signal is "true";
  signal \trace_ctl_pipe[3]\ : STD_LOGIC;
  attribute RTL_KEEP of \trace_ctl_pipe[3]\ : signal is "true";
  signal \trace_ctl_pipe[4]\ : STD_LOGIC;
  attribute RTL_KEEP of \trace_ctl_pipe[4]\ : signal is "true";
  signal \trace_ctl_pipe[5]\ : STD_LOGIC;
  attribute RTL_KEEP of \trace_ctl_pipe[5]\ : signal is "true";
  signal \trace_ctl_pipe[6]\ : STD_LOGIC;
  attribute RTL_KEEP of \trace_ctl_pipe[6]\ : signal is "true";
  signal \trace_ctl_pipe[7]\ : STD_LOGIC;
  attribute RTL_KEEP of \trace_ctl_pipe[7]\ : signal is "true";
  signal \trace_data_pipe[0]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[0]\ : signal is "true";
  signal \trace_data_pipe[1]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[1]\ : signal is "true";
  signal \trace_data_pipe[2]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[2]\ : signal is "true";
  signal \trace_data_pipe[3]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[3]\ : signal is "true";
  signal \trace_data_pipe[4]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[4]\ : signal is "true";
  signal \trace_data_pipe[5]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[5]\ : signal is "true";
  signal \trace_data_pipe[6]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[6]\ : signal is "true";
  signal \trace_data_pipe[7]\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute RTL_KEEP of \trace_data_pipe[7]\ : signal is "true";
  signal NLW_PS8_i_DPAUDIOREFCLK_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSPLTRACECTL_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_CLK_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DONEB_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMACTN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMALERTN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMPARITY_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMRAMRSTN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_ERROROUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_ERRORSTATUS_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_INITB_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTCK_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDI_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDO_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTMS_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN0IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN1IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN2IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN3IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP0IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP1IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP2IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP3IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN0OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN1OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN2OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN3OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP0OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP1OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP2OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP3OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_PADI_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_PADO_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_PORB_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_PROGB_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_RCALIBINOUT_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN0IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN1IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN2IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN3IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP0IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP1IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP2IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP3IN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_SRSTB_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_ZQ_UNCONNECTED : STD_LOGIC;
  signal NLW_PS8_i_EMIOGPIOO_UNCONNECTED : STD_LOGIC_VECTOR ( 94 downto 1 );
  signal NLW_PS8_i_EMIOGPIOTN_UNCONNECTED : STD_LOGIC_VECTOR ( 95 downto 1 );
  signal NLW_PS8_i_MAXIGP0WDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 32 );
  signal NLW_PS8_i_MAXIGP0WSTRB_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 4 );
  signal NLW_PS8_i_MAXIGP1WDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 32 );
  signal NLW_PS8_i_MAXIGP1WSTRB_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 4 );
  signal NLW_PS8_i_MAXIGP2WDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 32 );
  signal NLW_PS8_i_MAXIGP2WSTRB_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 4 );
  signal NLW_PS8_i_PSPLIRQFPD_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_PS8_i_PSPLIRQLPD_UNCONNECTED : STD_LOGIC_VECTOR ( 99 downto 0 );
  signal NLW_PS8_i_PSPLTRACEDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_BOOTMODE_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMA_UNCONNECTED : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBA_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBG_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCK_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKN_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCSN_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDM_UNCONNECTED : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQ_UNCONNECTED : STD_LOGIC_VECTOR ( 71 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQS_UNCONNECTED : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQSN_UNCONNECTED : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMODT_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_PS8_i_PSS_ALTO_CORE_PAD_MIO_UNCONNECTED : STD_LOGIC_VECTOR ( 77 downto 0 );
  signal NLW_PS8_i_SAXIGP0RDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 64 );
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of PS8_i : label is "PRIMITIVE";
  attribute DONT_TOUCH : boolean;
  attribute DONT_TOUCH of PS8_i : label is std.standard.true;
  attribute BOX_TYPE of \buffer_pl_clk_0.PL_CLK_0_BUFG\ : label is "PRIMITIVE";
begin
  dbg_path_fifo_bypass <= \<const0>\;
  dp_audio_ref_clk <= \<const0>\;
  emio_enet0_mdio_t_n <= \^emio_enet0_mdio_t_n\;
  emio_enet1_mdio_t_n <= \^emio_enet1_mdio_t_n\;
  emio_enet2_mdio_t_n <= \^emio_enet2_mdio_t_n\;
  emio_enet3_mdio_t_n <= \^emio_enet3_mdio_t_n\;
  emio_gpio_t_n(0) <= \^emio_gpio_t_n\(0);
  emio_i2c0_scl_t_n <= \^emio_i2c0_scl_t_n\;
  emio_i2c0_sda_t_n <= \^emio_i2c0_sda_t_n\;
  emio_i2c1_scl_t_n <= \^emio_i2c1_scl_t_n\;
  emio_i2c1_sda_t_n <= \^emio_i2c1_sda_t_n\;
  emio_spi0_mo_t_n <= \^emio_spi0_mo_t_n\;
  emio_spi0_sclk_t_n <= \^emio_spi0_sclk_t_n\;
  emio_spi0_so_t_n <= \^emio_spi0_so_t_n\;
  emio_spi0_ss_n_t_n <= \^emio_spi0_ss_n_t_n\;
  emio_spi1_mo_t_n <= \^emio_spi1_mo_t_n\;
  emio_spi1_sclk_t_n <= \^emio_spi1_sclk_t_n\;
  emio_spi1_so_t_n <= \^emio_spi1_so_t_n\;
  emio_spi1_ss_n_t_n <= \^emio_spi1_ss_n_t_n\;
  fmio_char_afifsfpd_test_output <= \<const0>\;
  fmio_char_afifslpd_test_output <= \<const0>\;
  fmio_char_gem_test_output <= \<const0>\;
  fmio_sd0_dll_test_out(7) <= \<const0>\;
  fmio_sd0_dll_test_out(6) <= \<const0>\;
  fmio_sd0_dll_test_out(5) <= \<const0>\;
  fmio_sd0_dll_test_out(4) <= \<const0>\;
  fmio_sd0_dll_test_out(3) <= \<const0>\;
  fmio_sd0_dll_test_out(2) <= \<const0>\;
  fmio_sd0_dll_test_out(1) <= \<const0>\;
  fmio_sd0_dll_test_out(0) <= \<const0>\;
  fmio_sd1_dll_test_out(7) <= \<const0>\;
  fmio_sd1_dll_test_out(6) <= \<const0>\;
  fmio_sd1_dll_test_out(5) <= \<const0>\;
  fmio_sd1_dll_test_out(4) <= \<const0>\;
  fmio_sd1_dll_test_out(3) <= \<const0>\;
  fmio_sd1_dll_test_out(2) <= \<const0>\;
  fmio_sd1_dll_test_out(1) <= \<const0>\;
  fmio_sd1_dll_test_out(0) <= \<const0>\;
  fmio_test_io_char_scan_out <= \<const0>\;
  fpd_pl_spare_0_out <= \<const0>\;
  fpd_pl_spare_1_out <= \<const0>\;
  fpd_pl_spare_2_out <= \<const0>\;
  fpd_pl_spare_3_out <= \<const0>\;
  fpd_pl_spare_4_out <= \<const0>\;
  fpd_pll_test_out(31) <= \<const0>\;
  fpd_pll_test_out(30) <= \<const0>\;
  fpd_pll_test_out(29) <= \<const0>\;
  fpd_pll_test_out(28) <= \<const0>\;
  fpd_pll_test_out(27) <= \<const0>\;
  fpd_pll_test_out(26) <= \<const0>\;
  fpd_pll_test_out(25) <= \<const0>\;
  fpd_pll_test_out(24) <= \<const0>\;
  fpd_pll_test_out(23) <= \<const0>\;
  fpd_pll_test_out(22) <= \<const0>\;
  fpd_pll_test_out(21) <= \<const0>\;
  fpd_pll_test_out(20) <= \<const0>\;
  fpd_pll_test_out(19) <= \<const0>\;
  fpd_pll_test_out(18) <= \<const0>\;
  fpd_pll_test_out(17) <= \<const0>\;
  fpd_pll_test_out(16) <= \<const0>\;
  fpd_pll_test_out(15) <= \<const0>\;
  fpd_pll_test_out(14) <= \<const0>\;
  fpd_pll_test_out(13) <= \<const0>\;
  fpd_pll_test_out(12) <= \<const0>\;
  fpd_pll_test_out(11) <= \<const0>\;
  fpd_pll_test_out(10) <= \<const0>\;
  fpd_pll_test_out(9) <= \<const0>\;
  fpd_pll_test_out(8) <= \<const0>\;
  fpd_pll_test_out(7) <= \<const0>\;
  fpd_pll_test_out(6) <= \<const0>\;
  fpd_pll_test_out(5) <= \<const0>\;
  fpd_pll_test_out(4) <= \<const0>\;
  fpd_pll_test_out(3) <= \<const0>\;
  fpd_pll_test_out(2) <= \<const0>\;
  fpd_pll_test_out(1) <= \<const0>\;
  fpd_pll_test_out(0) <= \<const0>\;
  io_char_audio_out_test_data <= \<const0>\;
  io_char_video_out_test_data <= \<const0>\;
  irq_ipi_pl_0 <= \<const0>\;
  irq_ipi_pl_1 <= \<const0>\;
  irq_ipi_pl_2 <= \<const0>\;
  irq_ipi_pl_3 <= \<const0>\;
  lpd_pl_spare_0_out <= \<const0>\;
  lpd_pl_spare_1_out <= \<const0>\;
  lpd_pl_spare_2_out <= \<const0>\;
  lpd_pl_spare_3_out <= \<const0>\;
  lpd_pl_spare_4_out <= \<const0>\;
  lpd_pll_test_out(31) <= \<const0>\;
  lpd_pll_test_out(30) <= \<const0>\;
  lpd_pll_test_out(29) <= \<const0>\;
  lpd_pll_test_out(28) <= \<const0>\;
  lpd_pll_test_out(27) <= \<const0>\;
  lpd_pll_test_out(26) <= \<const0>\;
  lpd_pll_test_out(25) <= \<const0>\;
  lpd_pll_test_out(24) <= \<const0>\;
  lpd_pll_test_out(23) <= \<const0>\;
  lpd_pll_test_out(22) <= \<const0>\;
  lpd_pll_test_out(21) <= \<const0>\;
  lpd_pll_test_out(20) <= \<const0>\;
  lpd_pll_test_out(19) <= \<const0>\;
  lpd_pll_test_out(18) <= \<const0>\;
  lpd_pll_test_out(17) <= \<const0>\;
  lpd_pll_test_out(16) <= \<const0>\;
  lpd_pll_test_out(15) <= \<const0>\;
  lpd_pll_test_out(14) <= \<const0>\;
  lpd_pll_test_out(13) <= \<const0>\;
  lpd_pll_test_out(12) <= \<const0>\;
  lpd_pll_test_out(11) <= \<const0>\;
  lpd_pll_test_out(10) <= \<const0>\;
  lpd_pll_test_out(9) <= \<const0>\;
  lpd_pll_test_out(8) <= \<const0>\;
  lpd_pll_test_out(7) <= \<const0>\;
  lpd_pll_test_out(6) <= \<const0>\;
  lpd_pll_test_out(5) <= \<const0>\;
  lpd_pll_test_out(4) <= \<const0>\;
  lpd_pll_test_out(3) <= \<const0>\;
  lpd_pll_test_out(2) <= \<const0>\;
  lpd_pll_test_out(1) <= \<const0>\;
  lpd_pll_test_out(0) <= \<const0>\;
  o_afe_TX_dig_reset_rel_ack <= \<const0>\;
  o_afe_TX_pipe_TX_dn_rxdet <= \<const0>\;
  o_afe_TX_pipe_TX_dp_rxdet <= \<const0>\;
  o_afe_cmn_calib_comp_out <= \<const0>\;
  o_afe_pg_avddcr <= \<const0>\;
  o_afe_pg_avddio <= \<const0>\;
  o_afe_pg_dvddcr <= \<const0>\;
  o_afe_pg_static_avddcr <= \<const0>\;
  o_afe_pg_static_avddio <= \<const0>\;
  o_afe_pll_clk_sym_hs <= \<const0>\;
  o_afe_pll_dco_count(12) <= \<const0>\;
  o_afe_pll_dco_count(11) <= \<const0>\;
  o_afe_pll_dco_count(10) <= \<const0>\;
  o_afe_pll_dco_count(9) <= \<const0>\;
  o_afe_pll_dco_count(8) <= \<const0>\;
  o_afe_pll_dco_count(7) <= \<const0>\;
  o_afe_pll_dco_count(6) <= \<const0>\;
  o_afe_pll_dco_count(5) <= \<const0>\;
  o_afe_pll_dco_count(4) <= \<const0>\;
  o_afe_pll_dco_count(3) <= \<const0>\;
  o_afe_pll_dco_count(2) <= \<const0>\;
  o_afe_pll_dco_count(1) <= \<const0>\;
  o_afe_pll_dco_count(0) <= \<const0>\;
  o_afe_pll_fbclk_frac <= \<const0>\;
  o_afe_rx_hsrx_clock_stop_ack <= \<const0>\;
  o_afe_rx_pipe_lfpsbcn_rxelecidle <= \<const0>\;
  o_afe_rx_pipe_sigdet <= \<const0>\;
  o_afe_rx_symbol(19) <= \<const0>\;
  o_afe_rx_symbol(18) <= \<const0>\;
  o_afe_rx_symbol(17) <= \<const0>\;
  o_afe_rx_symbol(16) <= \<const0>\;
  o_afe_rx_symbol(15) <= \<const0>\;
  o_afe_rx_symbol(14) <= \<const0>\;
  o_afe_rx_symbol(13) <= \<const0>\;
  o_afe_rx_symbol(12) <= \<const0>\;
  o_afe_rx_symbol(11) <= \<const0>\;
  o_afe_rx_symbol(10) <= \<const0>\;
  o_afe_rx_symbol(9) <= \<const0>\;
  o_afe_rx_symbol(8) <= \<const0>\;
  o_afe_rx_symbol(7) <= \<const0>\;
  o_afe_rx_symbol(6) <= \<const0>\;
  o_afe_rx_symbol(5) <= \<const0>\;
  o_afe_rx_symbol(4) <= \<const0>\;
  o_afe_rx_symbol(3) <= \<const0>\;
  o_afe_rx_symbol(2) <= \<const0>\;
  o_afe_rx_symbol(1) <= \<const0>\;
  o_afe_rx_symbol(0) <= \<const0>\;
  o_afe_rx_symbol_clk_by_2 <= \<const0>\;
  o_afe_rx_uphy_rx_calib_done <= \<const0>\;
  o_afe_rx_uphy_save_calcode <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(7) <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(6) <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(5) <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(4) <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(3) <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(2) <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(1) <= \<const0>\;
  o_afe_rx_uphy_save_calcode_data(0) <= \<const0>\;
  o_afe_rx_uphy_startloop_buf <= \<const0>\;
  o_dbg_l0_phystatus <= \<const0>\;
  o_dbg_l0_powerdown(1) <= \<const0>\;
  o_dbg_l0_powerdown(0) <= \<const0>\;
  o_dbg_l0_rate(1) <= \<const0>\;
  o_dbg_l0_rate(0) <= \<const0>\;
  o_dbg_l0_rstb <= \<const0>\;
  o_dbg_l0_rx_sgmii_en_cdet <= \<const0>\;
  o_dbg_l0_rxclk <= \<const0>\;
  o_dbg_l0_rxdata(19) <= \<const0>\;
  o_dbg_l0_rxdata(18) <= \<const0>\;
  o_dbg_l0_rxdata(17) <= \<const0>\;
  o_dbg_l0_rxdata(16) <= \<const0>\;
  o_dbg_l0_rxdata(15) <= \<const0>\;
  o_dbg_l0_rxdata(14) <= \<const0>\;
  o_dbg_l0_rxdata(13) <= \<const0>\;
  o_dbg_l0_rxdata(12) <= \<const0>\;
  o_dbg_l0_rxdata(11) <= \<const0>\;
  o_dbg_l0_rxdata(10) <= \<const0>\;
  o_dbg_l0_rxdata(9) <= \<const0>\;
  o_dbg_l0_rxdata(8) <= \<const0>\;
  o_dbg_l0_rxdata(7) <= \<const0>\;
  o_dbg_l0_rxdata(6) <= \<const0>\;
  o_dbg_l0_rxdata(5) <= \<const0>\;
  o_dbg_l0_rxdata(4) <= \<const0>\;
  o_dbg_l0_rxdata(3) <= \<const0>\;
  o_dbg_l0_rxdata(2) <= \<const0>\;
  o_dbg_l0_rxdata(1) <= \<const0>\;
  o_dbg_l0_rxdata(0) <= \<const0>\;
  o_dbg_l0_rxdatak(1) <= \<const0>\;
  o_dbg_l0_rxdatak(0) <= \<const0>\;
  o_dbg_l0_rxelecidle <= \<const0>\;
  o_dbg_l0_rxpolarity <= \<const0>\;
  o_dbg_l0_rxstatus(2) <= \<const0>\;
  o_dbg_l0_rxstatus(1) <= \<const0>\;
  o_dbg_l0_rxstatus(0) <= \<const0>\;
  o_dbg_l0_rxvalid <= \<const0>\;
  o_dbg_l0_sata_coreclockready <= \<const0>\;
  o_dbg_l0_sata_coreready <= \<const0>\;
  o_dbg_l0_sata_corerxdata(19) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(18) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(17) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(16) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(15) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(14) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(13) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(12) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(11) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(10) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(9) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(8) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(7) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(6) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(5) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(4) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(3) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(2) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(1) <= \<const0>\;
  o_dbg_l0_sata_corerxdata(0) <= \<const0>\;
  o_dbg_l0_sata_corerxdatavalid(1) <= \<const0>\;
  o_dbg_l0_sata_corerxdatavalid(0) <= \<const0>\;
  o_dbg_l0_sata_corerxsignaldet <= \<const0>\;
  o_dbg_l0_sata_phyctrlpartial <= \<const0>\;
  o_dbg_l0_sata_phyctrlreset <= \<const0>\;
  o_dbg_l0_sata_phyctrlrxrate(1) <= \<const0>\;
  o_dbg_l0_sata_phyctrlrxrate(0) <= \<const0>\;
  o_dbg_l0_sata_phyctrlrxrst <= \<const0>\;
  o_dbg_l0_sata_phyctrlslumber <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(19) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(18) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(17) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(16) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(15) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(14) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(13) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(12) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(11) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(10) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(9) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(8) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(7) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(6) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(5) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(4) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(3) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(2) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(1) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxdata(0) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxidle <= \<const0>\;
  o_dbg_l0_sata_phyctrltxrate(1) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxrate(0) <= \<const0>\;
  o_dbg_l0_sata_phyctrltxrst <= \<const0>\;
  o_dbg_l0_tx_sgmii_ewrap <= \<const0>\;
  o_dbg_l0_txclk <= \<const0>\;
  o_dbg_l0_txdata(19) <= \<const0>\;
  o_dbg_l0_txdata(18) <= \<const0>\;
  o_dbg_l0_txdata(17) <= \<const0>\;
  o_dbg_l0_txdata(16) <= \<const0>\;
  o_dbg_l0_txdata(15) <= \<const0>\;
  o_dbg_l0_txdata(14) <= \<const0>\;
  o_dbg_l0_txdata(13) <= \<const0>\;
  o_dbg_l0_txdata(12) <= \<const0>\;
  o_dbg_l0_txdata(11) <= \<const0>\;
  o_dbg_l0_txdata(10) <= \<const0>\;
  o_dbg_l0_txdata(9) <= \<const0>\;
  o_dbg_l0_txdata(8) <= \<const0>\;
  o_dbg_l0_txdata(7) <= \<const0>\;
  o_dbg_l0_txdata(6) <= \<const0>\;
  o_dbg_l0_txdata(5) <= \<const0>\;
  o_dbg_l0_txdata(4) <= \<const0>\;
  o_dbg_l0_txdata(3) <= \<const0>\;
  o_dbg_l0_txdata(2) <= \<const0>\;
  o_dbg_l0_txdata(1) <= \<const0>\;
  o_dbg_l0_txdata(0) <= \<const0>\;
  o_dbg_l0_txdatak(1) <= \<const0>\;
  o_dbg_l0_txdatak(0) <= \<const0>\;
  o_dbg_l0_txdetrx_lpback <= \<const0>\;
  o_dbg_l0_txelecidle <= \<const0>\;
  o_dbg_l1_phystatus <= \<const0>\;
  o_dbg_l1_powerdown(1) <= \<const0>\;
  o_dbg_l1_powerdown(0) <= \<const0>\;
  o_dbg_l1_rate(1) <= \<const0>\;
  o_dbg_l1_rate(0) <= \<const0>\;
  o_dbg_l1_rstb <= \<const0>\;
  o_dbg_l1_rx_sgmii_en_cdet <= \<const0>\;
  o_dbg_l1_rxclk <= \<const0>\;
  o_dbg_l1_rxdata(19) <= \<const0>\;
  o_dbg_l1_rxdata(18) <= \<const0>\;
  o_dbg_l1_rxdata(17) <= \<const0>\;
  o_dbg_l1_rxdata(16) <= \<const0>\;
  o_dbg_l1_rxdata(15) <= \<const0>\;
  o_dbg_l1_rxdata(14) <= \<const0>\;
  o_dbg_l1_rxdata(13) <= \<const0>\;
  o_dbg_l1_rxdata(12) <= \<const0>\;
  o_dbg_l1_rxdata(11) <= \<const0>\;
  o_dbg_l1_rxdata(10) <= \<const0>\;
  o_dbg_l1_rxdata(9) <= \<const0>\;
  o_dbg_l1_rxdata(8) <= \<const0>\;
  o_dbg_l1_rxdata(7) <= \<const0>\;
  o_dbg_l1_rxdata(6) <= \<const0>\;
  o_dbg_l1_rxdata(5) <= \<const0>\;
  o_dbg_l1_rxdata(4) <= \<const0>\;
  o_dbg_l1_rxdata(3) <= \<const0>\;
  o_dbg_l1_rxdata(2) <= \<const0>\;
  o_dbg_l1_rxdata(1) <= \<const0>\;
  o_dbg_l1_rxdata(0) <= \<const0>\;
  o_dbg_l1_rxdatak(1) <= \<const0>\;
  o_dbg_l1_rxdatak(0) <= \<const0>\;
  o_dbg_l1_rxelecidle <= \<const0>\;
  o_dbg_l1_rxpolarity <= \<const0>\;
  o_dbg_l1_rxstatus(2) <= \<const0>\;
  o_dbg_l1_rxstatus(1) <= \<const0>\;
  o_dbg_l1_rxstatus(0) <= \<const0>\;
  o_dbg_l1_rxvalid <= \<const0>\;
  o_dbg_l1_sata_coreclockready <= \<const0>\;
  o_dbg_l1_sata_coreready <= \<const0>\;
  o_dbg_l1_sata_corerxdata(19) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(18) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(17) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(16) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(15) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(14) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(13) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(12) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(11) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(10) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(9) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(8) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(7) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(6) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(5) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(4) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(3) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(2) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(1) <= \<const0>\;
  o_dbg_l1_sata_corerxdata(0) <= \<const0>\;
  o_dbg_l1_sata_corerxdatavalid(1) <= \<const0>\;
  o_dbg_l1_sata_corerxdatavalid(0) <= \<const0>\;
  o_dbg_l1_sata_corerxsignaldet <= \<const0>\;
  o_dbg_l1_sata_phyctrlpartial <= \<const0>\;
  o_dbg_l1_sata_phyctrlreset <= \<const0>\;
  o_dbg_l1_sata_phyctrlrxrate(1) <= \<const0>\;
  o_dbg_l1_sata_phyctrlrxrate(0) <= \<const0>\;
  o_dbg_l1_sata_phyctrlrxrst <= \<const0>\;
  o_dbg_l1_sata_phyctrlslumber <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(19) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(18) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(17) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(16) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(15) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(14) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(13) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(12) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(11) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(10) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(9) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(8) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(7) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(6) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(5) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(4) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(3) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(2) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(1) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxdata(0) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxidle <= \<const0>\;
  o_dbg_l1_sata_phyctrltxrate(1) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxrate(0) <= \<const0>\;
  o_dbg_l1_sata_phyctrltxrst <= \<const0>\;
  o_dbg_l1_tx_sgmii_ewrap <= \<const0>\;
  o_dbg_l1_txclk <= \<const0>\;
  o_dbg_l1_txdata(19) <= \<const0>\;
  o_dbg_l1_txdata(18) <= \<const0>\;
  o_dbg_l1_txdata(17) <= \<const0>\;
  o_dbg_l1_txdata(16) <= \<const0>\;
  o_dbg_l1_txdata(15) <= \<const0>\;
  o_dbg_l1_txdata(14) <= \<const0>\;
  o_dbg_l1_txdata(13) <= \<const0>\;
  o_dbg_l1_txdata(12) <= \<const0>\;
  o_dbg_l1_txdata(11) <= \<const0>\;
  o_dbg_l1_txdata(10) <= \<const0>\;
  o_dbg_l1_txdata(9) <= \<const0>\;
  o_dbg_l1_txdata(8) <= \<const0>\;
  o_dbg_l1_txdata(7) <= \<const0>\;
  o_dbg_l1_txdata(6) <= \<const0>\;
  o_dbg_l1_txdata(5) <= \<const0>\;
  o_dbg_l1_txdata(4) <= \<const0>\;
  o_dbg_l1_txdata(3) <= \<const0>\;
  o_dbg_l1_txdata(2) <= \<const0>\;
  o_dbg_l1_txdata(1) <= \<const0>\;
  o_dbg_l1_txdata(0) <= \<const0>\;
  o_dbg_l1_txdatak(1) <= \<const0>\;
  o_dbg_l1_txdatak(0) <= \<const0>\;
  o_dbg_l1_txdetrx_lpback <= \<const0>\;
  o_dbg_l1_txelecidle <= \<const0>\;
  o_dbg_l2_phystatus <= \<const0>\;
  o_dbg_l2_powerdown(1) <= \<const0>\;
  o_dbg_l2_powerdown(0) <= \<const0>\;
  o_dbg_l2_rate(1) <= \<const0>\;
  o_dbg_l2_rate(0) <= \<const0>\;
  o_dbg_l2_rstb <= \<const0>\;
  o_dbg_l2_rx_sgmii_en_cdet <= \<const0>\;
  o_dbg_l2_rxclk <= \<const0>\;
  o_dbg_l2_rxdata(19) <= \<const0>\;
  o_dbg_l2_rxdata(18) <= \<const0>\;
  o_dbg_l2_rxdata(17) <= \<const0>\;
  o_dbg_l2_rxdata(16) <= \<const0>\;
  o_dbg_l2_rxdata(15) <= \<const0>\;
  o_dbg_l2_rxdata(14) <= \<const0>\;
  o_dbg_l2_rxdata(13) <= \<const0>\;
  o_dbg_l2_rxdata(12) <= \<const0>\;
  o_dbg_l2_rxdata(11) <= \<const0>\;
  o_dbg_l2_rxdata(10) <= \<const0>\;
  o_dbg_l2_rxdata(9) <= \<const0>\;
  o_dbg_l2_rxdata(8) <= \<const0>\;
  o_dbg_l2_rxdata(7) <= \<const0>\;
  o_dbg_l2_rxdata(6) <= \<const0>\;
  o_dbg_l2_rxdata(5) <= \<const0>\;
  o_dbg_l2_rxdata(4) <= \<const0>\;
  o_dbg_l2_rxdata(3) <= \<const0>\;
  o_dbg_l2_rxdata(2) <= \<const0>\;
  o_dbg_l2_rxdata(1) <= \<const0>\;
  o_dbg_l2_rxdata(0) <= \<const0>\;
  o_dbg_l2_rxdatak(1) <= \<const0>\;
  o_dbg_l2_rxdatak(0) <= \<const0>\;
  o_dbg_l2_rxelecidle <= \<const0>\;
  o_dbg_l2_rxpolarity <= \<const0>\;
  o_dbg_l2_rxstatus(2) <= \<const0>\;
  o_dbg_l2_rxstatus(1) <= \<const0>\;
  o_dbg_l2_rxstatus(0) <= \<const0>\;
  o_dbg_l2_rxvalid <= \<const0>\;
  o_dbg_l2_sata_coreclockready <= \<const0>\;
  o_dbg_l2_sata_coreready <= \<const0>\;
  o_dbg_l2_sata_corerxdata(19) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(18) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(17) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(16) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(15) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(14) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(13) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(12) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(11) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(10) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(9) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(8) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(7) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(6) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(5) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(4) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(3) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(2) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(1) <= \<const0>\;
  o_dbg_l2_sata_corerxdata(0) <= \<const0>\;
  o_dbg_l2_sata_corerxdatavalid(1) <= \<const0>\;
  o_dbg_l2_sata_corerxdatavalid(0) <= \<const0>\;
  o_dbg_l2_sata_corerxsignaldet <= \<const0>\;
  o_dbg_l2_sata_phyctrlpartial <= \<const0>\;
  o_dbg_l2_sata_phyctrlreset <= \<const0>\;
  o_dbg_l2_sata_phyctrlrxrate(1) <= \<const0>\;
  o_dbg_l2_sata_phyctrlrxrate(0) <= \<const0>\;
  o_dbg_l2_sata_phyctrlrxrst <= \<const0>\;
  o_dbg_l2_sata_phyctrlslumber <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(19) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(18) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(17) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(16) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(15) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(14) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(13) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(12) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(11) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(10) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(9) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(8) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(7) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(6) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(5) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(4) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(3) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(2) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(1) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxdata(0) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxidle <= \<const0>\;
  o_dbg_l2_sata_phyctrltxrate(1) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxrate(0) <= \<const0>\;
  o_dbg_l2_sata_phyctrltxrst <= \<const0>\;
  o_dbg_l2_tx_sgmii_ewrap <= \<const0>\;
  o_dbg_l2_txclk <= \<const0>\;
  o_dbg_l2_txdata(19) <= \<const0>\;
  o_dbg_l2_txdata(18) <= \<const0>\;
  o_dbg_l2_txdata(17) <= \<const0>\;
  o_dbg_l2_txdata(16) <= \<const0>\;
  o_dbg_l2_txdata(15) <= \<const0>\;
  o_dbg_l2_txdata(14) <= \<const0>\;
  o_dbg_l2_txdata(13) <= \<const0>\;
  o_dbg_l2_txdata(12) <= \<const0>\;
  o_dbg_l2_txdata(11) <= \<const0>\;
  o_dbg_l2_txdata(10) <= \<const0>\;
  o_dbg_l2_txdata(9) <= \<const0>\;
  o_dbg_l2_txdata(8) <= \<const0>\;
  o_dbg_l2_txdata(7) <= \<const0>\;
  o_dbg_l2_txdata(6) <= \<const0>\;
  o_dbg_l2_txdata(5) <= \<const0>\;
  o_dbg_l2_txdata(4) <= \<const0>\;
  o_dbg_l2_txdata(3) <= \<const0>\;
  o_dbg_l2_txdata(2) <= \<const0>\;
  o_dbg_l2_txdata(1) <= \<const0>\;
  o_dbg_l2_txdata(0) <= \<const0>\;
  o_dbg_l2_txdatak(1) <= \<const0>\;
  o_dbg_l2_txdatak(0) <= \<const0>\;
  o_dbg_l2_txdetrx_lpback <= \<const0>\;
  o_dbg_l2_txelecidle <= \<const0>\;
  o_dbg_l3_phystatus <= \<const0>\;
  o_dbg_l3_powerdown(1) <= \<const0>\;
  o_dbg_l3_powerdown(0) <= \<const0>\;
  o_dbg_l3_rate(1) <= \<const0>\;
  o_dbg_l3_rate(0) <= \<const0>\;
  o_dbg_l3_rstb <= \<const0>\;
  o_dbg_l3_rx_sgmii_en_cdet <= \<const0>\;
  o_dbg_l3_rxclk <= \<const0>\;
  o_dbg_l3_rxdata(19) <= \<const0>\;
  o_dbg_l3_rxdata(18) <= \<const0>\;
  o_dbg_l3_rxdata(17) <= \<const0>\;
  o_dbg_l3_rxdata(16) <= \<const0>\;
  o_dbg_l3_rxdata(15) <= \<const0>\;
  o_dbg_l3_rxdata(14) <= \<const0>\;
  o_dbg_l3_rxdata(13) <= \<const0>\;
  o_dbg_l3_rxdata(12) <= \<const0>\;
  o_dbg_l3_rxdata(11) <= \<const0>\;
  o_dbg_l3_rxdata(10) <= \<const0>\;
  o_dbg_l3_rxdata(9) <= \<const0>\;
  o_dbg_l3_rxdata(8) <= \<const0>\;
  o_dbg_l3_rxdata(7) <= \<const0>\;
  o_dbg_l3_rxdata(6) <= \<const0>\;
  o_dbg_l3_rxdata(5) <= \<const0>\;
  o_dbg_l3_rxdata(4) <= \<const0>\;
  o_dbg_l3_rxdata(3) <= \<const0>\;
  o_dbg_l3_rxdata(2) <= \<const0>\;
  o_dbg_l3_rxdata(1) <= \<const0>\;
  o_dbg_l3_rxdata(0) <= \<const0>\;
  o_dbg_l3_rxdatak(1) <= \<const0>\;
  o_dbg_l3_rxdatak(0) <= \<const0>\;
  o_dbg_l3_rxelecidle <= \<const0>\;
  o_dbg_l3_rxpolarity <= \<const0>\;
  o_dbg_l3_rxstatus(2) <= \<const0>\;
  o_dbg_l3_rxstatus(1) <= \<const0>\;
  o_dbg_l3_rxstatus(0) <= \<const0>\;
  o_dbg_l3_rxvalid <= \<const0>\;
  o_dbg_l3_sata_coreclockready <= \<const0>\;
  o_dbg_l3_sata_coreready <= \<const0>\;
  o_dbg_l3_sata_corerxdata(19) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(18) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(17) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(16) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(15) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(14) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(13) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(12) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(11) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(10) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(9) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(8) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(7) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(6) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(5) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(4) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(3) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(2) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(1) <= \<const0>\;
  o_dbg_l3_sata_corerxdata(0) <= \<const0>\;
  o_dbg_l3_sata_corerxdatavalid(1) <= \<const0>\;
  o_dbg_l3_sata_corerxdatavalid(0) <= \<const0>\;
  o_dbg_l3_sata_corerxsignaldet <= \<const0>\;
  o_dbg_l3_sata_phyctrlpartial <= \<const0>\;
  o_dbg_l3_sata_phyctrlreset <= \<const0>\;
  o_dbg_l3_sata_phyctrlrxrate(1) <= \<const0>\;
  o_dbg_l3_sata_phyctrlrxrate(0) <= \<const0>\;
  o_dbg_l3_sata_phyctrlrxrst <= \<const0>\;
  o_dbg_l3_sata_phyctrlslumber <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(19) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(18) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(17) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(16) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(15) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(14) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(13) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(12) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(11) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(10) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(9) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(8) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(7) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(6) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(5) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(4) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(3) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(2) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(1) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxdata(0) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxidle <= \<const0>\;
  o_dbg_l3_sata_phyctrltxrate(1) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxrate(0) <= \<const0>\;
  o_dbg_l3_sata_phyctrltxrst <= \<const0>\;
  o_dbg_l3_tx_sgmii_ewrap <= \<const0>\;
  o_dbg_l3_txclk <= \<const0>\;
  o_dbg_l3_txdata(19) <= \<const0>\;
  o_dbg_l3_txdata(18) <= \<const0>\;
  o_dbg_l3_txdata(17) <= \<const0>\;
  o_dbg_l3_txdata(16) <= \<const0>\;
  o_dbg_l3_txdata(15) <= \<const0>\;
  o_dbg_l3_txdata(14) <= \<const0>\;
  o_dbg_l3_txdata(13) <= \<const0>\;
  o_dbg_l3_txdata(12) <= \<const0>\;
  o_dbg_l3_txdata(11) <= \<const0>\;
  o_dbg_l3_txdata(10) <= \<const0>\;
  o_dbg_l3_txdata(9) <= \<const0>\;
  o_dbg_l3_txdata(8) <= \<const0>\;
  o_dbg_l3_txdata(7) <= \<const0>\;
  o_dbg_l3_txdata(6) <= \<const0>\;
  o_dbg_l3_txdata(5) <= \<const0>\;
  o_dbg_l3_txdata(4) <= \<const0>\;
  o_dbg_l3_txdata(3) <= \<const0>\;
  o_dbg_l3_txdata(2) <= \<const0>\;
  o_dbg_l3_txdata(1) <= \<const0>\;
  o_dbg_l3_txdata(0) <= \<const0>\;
  o_dbg_l3_txdatak(1) <= \<const0>\;
  o_dbg_l3_txdatak(0) <= \<const0>\;
  o_dbg_l3_txdetrx_lpback <= \<const0>\;
  o_dbg_l3_txelecidle <= \<const0>\;
  pl_resetn1 <= \<const1>\;
  pl_resetn2 <= \<const1>\;
  pl_resetn3 <= \<const1>\;
  ps_pl_tracectl <= \trace_ctl_pipe[0]\;
  ps_pl_tracedata(31 downto 0) <= \trace_data_pipe[0]\(31 downto 0);
  pstp_pl_out(31) <= \<const0>\;
  pstp_pl_out(30) <= \<const0>\;
  pstp_pl_out(29) <= \<const0>\;
  pstp_pl_out(28) <= \<const0>\;
  pstp_pl_out(27) <= \<const0>\;
  pstp_pl_out(26) <= \<const0>\;
  pstp_pl_out(25) <= \<const0>\;
  pstp_pl_out(24) <= \<const0>\;
  pstp_pl_out(23) <= \<const0>\;
  pstp_pl_out(22) <= \<const0>\;
  pstp_pl_out(21) <= \<const0>\;
  pstp_pl_out(20) <= \<const0>\;
  pstp_pl_out(19) <= \<const0>\;
  pstp_pl_out(18) <= \<const0>\;
  pstp_pl_out(17) <= \<const0>\;
  pstp_pl_out(16) <= \<const0>\;
  pstp_pl_out(15) <= \<const0>\;
  pstp_pl_out(14) <= \<const0>\;
  pstp_pl_out(13) <= \<const0>\;
  pstp_pl_out(12) <= \<const0>\;
  pstp_pl_out(11) <= \<const0>\;
  pstp_pl_out(10) <= \<const0>\;
  pstp_pl_out(9) <= \<const0>\;
  pstp_pl_out(8) <= \<const0>\;
  pstp_pl_out(7) <= \<const0>\;
  pstp_pl_out(6) <= \<const0>\;
  pstp_pl_out(5) <= \<const0>\;
  pstp_pl_out(4) <= \<const0>\;
  pstp_pl_out(3) <= \<const0>\;
  pstp_pl_out(2) <= \<const0>\;
  pstp_pl_out(1) <= \<const0>\;
  pstp_pl_out(0) <= \<const0>\;
  test_adc_out(19) <= \<const0>\;
  test_adc_out(18) <= \<const0>\;
  test_adc_out(17) <= \<const0>\;
  test_adc_out(16) <= \<const0>\;
  test_adc_out(15) <= \<const0>\;
  test_adc_out(14) <= \<const0>\;
  test_adc_out(13) <= \<const0>\;
  test_adc_out(12) <= \<const0>\;
  test_adc_out(11) <= \<const0>\;
  test_adc_out(10) <= \<const0>\;
  test_adc_out(9) <= \<const0>\;
  test_adc_out(8) <= \<const0>\;
  test_adc_out(7) <= \<const0>\;
  test_adc_out(6) <= \<const0>\;
  test_adc_out(5) <= \<const0>\;
  test_adc_out(4) <= \<const0>\;
  test_adc_out(3) <= \<const0>\;
  test_adc_out(2) <= \<const0>\;
  test_adc_out(1) <= \<const0>\;
  test_adc_out(0) <= \<const0>\;
  test_ams_osc(7) <= \<const0>\;
  test_ams_osc(6) <= \<const0>\;
  test_ams_osc(5) <= \<const0>\;
  test_ams_osc(4) <= \<const0>\;
  test_ams_osc(3) <= \<const0>\;
  test_ams_osc(2) <= \<const0>\;
  test_ams_osc(1) <= \<const0>\;
  test_ams_osc(0) <= \<const0>\;
  test_bscan_tdo <= \<const0>\;
  test_db(15) <= \<const0>\;
  test_db(14) <= \<const0>\;
  test_db(13) <= \<const0>\;
  test_db(12) <= \<const0>\;
  test_db(11) <= \<const0>\;
  test_db(10) <= \<const0>\;
  test_db(9) <= \<const0>\;
  test_db(8) <= \<const0>\;
  test_db(7) <= \<const0>\;
  test_db(6) <= \<const0>\;
  test_db(5) <= \<const0>\;
  test_db(4) <= \<const0>\;
  test_db(3) <= \<const0>\;
  test_db(2) <= \<const0>\;
  test_db(1) <= \<const0>\;
  test_db(0) <= \<const0>\;
  test_ddr2pl_dcd_skewout <= \<const0>\;
  test_do(15) <= \<const0>\;
  test_do(14) <= \<const0>\;
  test_do(13) <= \<const0>\;
  test_do(12) <= \<const0>\;
  test_do(11) <= \<const0>\;
  test_do(10) <= \<const0>\;
  test_do(9) <= \<const0>\;
  test_do(8) <= \<const0>\;
  test_do(7) <= \<const0>\;
  test_do(6) <= \<const0>\;
  test_do(5) <= \<const0>\;
  test_do(4) <= \<const0>\;
  test_do(3) <= \<const0>\;
  test_do(2) <= \<const0>\;
  test_do(1) <= \<const0>\;
  test_do(0) <= \<const0>\;
  test_drdy <= \<const0>\;
  test_mon_data(15) <= \<const0>\;
  test_mon_data(14) <= \<const0>\;
  test_mon_data(13) <= \<const0>\;
  test_mon_data(12) <= \<const0>\;
  test_mon_data(11) <= \<const0>\;
  test_mon_data(10) <= \<const0>\;
  test_mon_data(9) <= \<const0>\;
  test_mon_data(8) <= \<const0>\;
  test_mon_data(7) <= \<const0>\;
  test_mon_data(6) <= \<const0>\;
  test_mon_data(5) <= \<const0>\;
  test_mon_data(4) <= \<const0>\;
  test_mon_data(3) <= \<const0>\;
  test_mon_data(2) <= \<const0>\;
  test_mon_data(1) <= \<const0>\;
  test_mon_data(0) <= \<const0>\;
  test_pl_pll_lock_out(4) <= \<const0>\;
  test_pl_pll_lock_out(3) <= \<const0>\;
  test_pl_pll_lock_out(2) <= \<const0>\;
  test_pl_pll_lock_out(1) <= \<const0>\;
  test_pl_pll_lock_out(0) <= \<const0>\;
  test_pl_scan_chopper_so <= \<const0>\;
  test_pl_scan_edt_out_apu <= \<const0>\;
  test_pl_scan_edt_out_cpu0 <= \<const0>\;
  test_pl_scan_edt_out_cpu1 <= \<const0>\;
  test_pl_scan_edt_out_cpu2 <= \<const0>\;
  test_pl_scan_edt_out_cpu3 <= \<const0>\;
  test_pl_scan_edt_out_ddr(3) <= \<const0>\;
  test_pl_scan_edt_out_ddr(2) <= \<const0>\;
  test_pl_scan_edt_out_ddr(1) <= \<const0>\;
  test_pl_scan_edt_out_ddr(0) <= \<const0>\;
  test_pl_scan_edt_out_fp(9) <= \<const0>\;
  test_pl_scan_edt_out_fp(8) <= \<const0>\;
  test_pl_scan_edt_out_fp(7) <= \<const0>\;
  test_pl_scan_edt_out_fp(6) <= \<const0>\;
  test_pl_scan_edt_out_fp(5) <= \<const0>\;
  test_pl_scan_edt_out_fp(4) <= \<const0>\;
  test_pl_scan_edt_out_fp(3) <= \<const0>\;
  test_pl_scan_edt_out_fp(2) <= \<const0>\;
  test_pl_scan_edt_out_fp(1) <= \<const0>\;
  test_pl_scan_edt_out_fp(0) <= \<const0>\;
  test_pl_scan_edt_out_gpu(3) <= \<const0>\;
  test_pl_scan_edt_out_gpu(2) <= \<const0>\;
  test_pl_scan_edt_out_gpu(1) <= \<const0>\;
  test_pl_scan_edt_out_gpu(0) <= \<const0>\;
  test_pl_scan_edt_out_lp(8) <= \<const0>\;
  test_pl_scan_edt_out_lp(7) <= \<const0>\;
  test_pl_scan_edt_out_lp(6) <= \<const0>\;
  test_pl_scan_edt_out_lp(5) <= \<const0>\;
  test_pl_scan_edt_out_lp(4) <= \<const0>\;
  test_pl_scan_edt_out_lp(3) <= \<const0>\;
  test_pl_scan_edt_out_lp(2) <= \<const0>\;
  test_pl_scan_edt_out_lp(1) <= \<const0>\;
  test_pl_scan_edt_out_lp(0) <= \<const0>\;
  test_pl_scan_edt_out_usb3(1) <= \<const0>\;
  test_pl_scan_edt_out_usb3(0) <= \<const0>\;
  test_pl_scan_slcr_config_so <= \<const0>\;
  test_pl_scan_spare_out0 <= \<const0>\;
  test_pl_scan_spare_out1 <= \<const0>\;
  trace_clk_out <= \^trace_clk_out\;
  tst_rtc_calibreg_out(20) <= \<const0>\;
  tst_rtc_calibreg_out(19) <= \<const0>\;
  tst_rtc_calibreg_out(18) <= \<const0>\;
  tst_rtc_calibreg_out(17) <= \<const0>\;
  tst_rtc_calibreg_out(16) <= \<const0>\;
  tst_rtc_calibreg_out(15) <= \<const0>\;
  tst_rtc_calibreg_out(14) <= \<const0>\;
  tst_rtc_calibreg_out(13) <= \<const0>\;
  tst_rtc_calibreg_out(12) <= \<const0>\;
  tst_rtc_calibreg_out(11) <= \<const0>\;
  tst_rtc_calibreg_out(10) <= \<const0>\;
  tst_rtc_calibreg_out(9) <= \<const0>\;
  tst_rtc_calibreg_out(8) <= \<const0>\;
  tst_rtc_calibreg_out(7) <= \<const0>\;
  tst_rtc_calibreg_out(6) <= \<const0>\;
  tst_rtc_calibreg_out(5) <= \<const0>\;
  tst_rtc_calibreg_out(4) <= \<const0>\;
  tst_rtc_calibreg_out(3) <= \<const0>\;
  tst_rtc_calibreg_out(2) <= \<const0>\;
  tst_rtc_calibreg_out(1) <= \<const0>\;
  tst_rtc_calibreg_out(0) <= \<const0>\;
  tst_rtc_osc_clk_out <= \<const0>\;
  tst_rtc_osc_cntrl_out(3) <= \<const0>\;
  tst_rtc_osc_cntrl_out(2) <= \<const0>\;
  tst_rtc_osc_cntrl_out(1) <= \<const0>\;
  tst_rtc_osc_cntrl_out(0) <= \<const0>\;
  tst_rtc_sec_counter_out(31) <= \<const0>\;
  tst_rtc_sec_counter_out(30) <= \<const0>\;
  tst_rtc_sec_counter_out(29) <= \<const0>\;
  tst_rtc_sec_counter_out(28) <= \<const0>\;
  tst_rtc_sec_counter_out(27) <= \<const0>\;
  tst_rtc_sec_counter_out(26) <= \<const0>\;
  tst_rtc_sec_counter_out(25) <= \<const0>\;
  tst_rtc_sec_counter_out(24) <= \<const0>\;
  tst_rtc_sec_counter_out(23) <= \<const0>\;
  tst_rtc_sec_counter_out(22) <= \<const0>\;
  tst_rtc_sec_counter_out(21) <= \<const0>\;
  tst_rtc_sec_counter_out(20) <= \<const0>\;
  tst_rtc_sec_counter_out(19) <= \<const0>\;
  tst_rtc_sec_counter_out(18) <= \<const0>\;
  tst_rtc_sec_counter_out(17) <= \<const0>\;
  tst_rtc_sec_counter_out(16) <= \<const0>\;
  tst_rtc_sec_counter_out(15) <= \<const0>\;
  tst_rtc_sec_counter_out(14) <= \<const0>\;
  tst_rtc_sec_counter_out(13) <= \<const0>\;
  tst_rtc_sec_counter_out(12) <= \<const0>\;
  tst_rtc_sec_counter_out(11) <= \<const0>\;
  tst_rtc_sec_counter_out(10) <= \<const0>\;
  tst_rtc_sec_counter_out(9) <= \<const0>\;
  tst_rtc_sec_counter_out(8) <= \<const0>\;
  tst_rtc_sec_counter_out(7) <= \<const0>\;
  tst_rtc_sec_counter_out(6) <= \<const0>\;
  tst_rtc_sec_counter_out(5) <= \<const0>\;
  tst_rtc_sec_counter_out(4) <= \<const0>\;
  tst_rtc_sec_counter_out(3) <= \<const0>\;
  tst_rtc_sec_counter_out(2) <= \<const0>\;
  tst_rtc_sec_counter_out(1) <= \<const0>\;
  tst_rtc_sec_counter_out(0) <= \<const0>\;
  tst_rtc_seconds_raw_int <= \<const0>\;
  tst_rtc_tick_counter_out(15) <= \<const0>\;
  tst_rtc_tick_counter_out(14) <= \<const0>\;
  tst_rtc_tick_counter_out(13) <= \<const0>\;
  tst_rtc_tick_counter_out(12) <= \<const0>\;
  tst_rtc_tick_counter_out(11) <= \<const0>\;
  tst_rtc_tick_counter_out(10) <= \<const0>\;
  tst_rtc_tick_counter_out(9) <= \<const0>\;
  tst_rtc_tick_counter_out(8) <= \<const0>\;
  tst_rtc_tick_counter_out(7) <= \<const0>\;
  tst_rtc_tick_counter_out(6) <= \<const0>\;
  tst_rtc_tick_counter_out(5) <= \<const0>\;
  tst_rtc_tick_counter_out(4) <= \<const0>\;
  tst_rtc_tick_counter_out(3) <= \<const0>\;
  tst_rtc_tick_counter_out(2) <= \<const0>\;
  tst_rtc_tick_counter_out(1) <= \<const0>\;
  tst_rtc_tick_counter_out(0) <= \<const0>\;
  tst_rtc_timesetreg_out(31) <= \<const0>\;
  tst_rtc_timesetreg_out(30) <= \<const0>\;
  tst_rtc_timesetreg_out(29) <= \<const0>\;
  tst_rtc_timesetreg_out(28) <= \<const0>\;
  tst_rtc_timesetreg_out(27) <= \<const0>\;
  tst_rtc_timesetreg_out(26) <= \<const0>\;
  tst_rtc_timesetreg_out(25) <= \<const0>\;
  tst_rtc_timesetreg_out(24) <= \<const0>\;
  tst_rtc_timesetreg_out(23) <= \<const0>\;
  tst_rtc_timesetreg_out(22) <= \<const0>\;
  tst_rtc_timesetreg_out(21) <= \<const0>\;
  tst_rtc_timesetreg_out(20) <= \<const0>\;
  tst_rtc_timesetreg_out(19) <= \<const0>\;
  tst_rtc_timesetreg_out(18) <= \<const0>\;
  tst_rtc_timesetreg_out(17) <= \<const0>\;
  tst_rtc_timesetreg_out(16) <= \<const0>\;
  tst_rtc_timesetreg_out(15) <= \<const0>\;
  tst_rtc_timesetreg_out(14) <= \<const0>\;
  tst_rtc_timesetreg_out(13) <= \<const0>\;
  tst_rtc_timesetreg_out(12) <= \<const0>\;
  tst_rtc_timesetreg_out(11) <= \<const0>\;
  tst_rtc_timesetreg_out(10) <= \<const0>\;
  tst_rtc_timesetreg_out(9) <= \<const0>\;
  tst_rtc_timesetreg_out(8) <= \<const0>\;
  tst_rtc_timesetreg_out(7) <= \<const0>\;
  tst_rtc_timesetreg_out(6) <= \<const0>\;
  tst_rtc_timesetreg_out(5) <= \<const0>\;
  tst_rtc_timesetreg_out(4) <= \<const0>\;
  tst_rtc_timesetreg_out(3) <= \<const0>\;
  tst_rtc_timesetreg_out(2) <= \<const0>\;
  tst_rtc_timesetreg_out(1) <= \<const0>\;
  tst_rtc_timesetreg_out(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
PS8_i: unisim.vcomponents.PS8
     port map (
      ADMA2PLCACK(7 downto 0) => adma2pl_cack(7 downto 0),
      ADMA2PLTVLD(7 downto 0) => adma2pl_tvld(7 downto 0),
      ADMAFCICLK(7 downto 0) => adma_fci_clk(7 downto 0),
      AIBPMUAFIFMFPDACK => aib_pmu_afifm_fpd_ack,
      AIBPMUAFIFMLPDACK => aib_pmu_afifm_lpd_ack,
      DDRCEXTREFRESHRANK0REQ => ddrc_ext_refresh_rank0_req,
      DDRCEXTREFRESHRANK1REQ => ddrc_ext_refresh_rank1_req,
      DDRCREFRESHPLCLK => ddrc_refresh_pl_clk,
      DPAUDIOREFCLK => NLW_PS8_i_DPAUDIOREFCLK_UNCONNECTED,
      DPAUXDATAIN => dp_aux_data_in,
      DPAUXDATAOEN => dp_aux_data_oe_n,
      DPAUXDATAOUT => dp_aux_data_out,
      DPEXTERNALCUSTOMEVENT1 => dp_external_custom_event1,
      DPEXTERNALCUSTOMEVENT2 => dp_external_custom_event2,
      DPEXTERNALVSYNCEVENT => dp_external_vsync_event,
      DPHOTPLUGDETECT => dp_hot_plug_detect,
      DPLIVEGFXALPHAIN(7 downto 0) => dp_live_gfx_alpha_in(7 downto 0),
      DPLIVEGFXPIXEL1IN(35 downto 0) => dp_live_gfx_pixel1_in(35 downto 0),
      DPLIVEVIDEODEOUT => dp_live_video_de_out,
      DPLIVEVIDEOINDE => dp_live_video_in_de,
      DPLIVEVIDEOINHSYNC => dp_live_video_in_hsync,
      DPLIVEVIDEOINPIXEL1(35 downto 0) => dp_live_video_in_pixel1(35 downto 0),
      DPLIVEVIDEOINVSYNC => dp_live_video_in_vsync,
      DPMAXISMIXEDAUDIOTDATA(31 downto 0) => dp_m_axis_mixed_audio_tdata(31 downto 0),
      DPMAXISMIXEDAUDIOTID => dp_m_axis_mixed_audio_tid,
      DPMAXISMIXEDAUDIOTREADY => dp_m_axis_mixed_audio_tready,
      DPMAXISMIXEDAUDIOTVALID => dp_m_axis_mixed_audio_tvalid,
      DPSAXISAUDIOCLK => dp_s_axis_audio_clk,
      DPSAXISAUDIOTDATA(31 downto 0) => dp_s_axis_audio_tdata(31 downto 0),
      DPSAXISAUDIOTID => dp_s_axis_audio_tid,
      DPSAXISAUDIOTREADY => dp_s_axis_audio_tready,
      DPSAXISAUDIOTVALID => dp_s_axis_audio_tvalid,
      DPVIDEOINCLK => dp_video_in_clk,
      DPVIDEOOUTHSYNC => dp_video_out_hsync,
      DPVIDEOOUTPIXEL1(35 downto 0) => dp_video_out_pixel1(35 downto 0),
      DPVIDEOOUTVSYNC => dp_video_out_vsync,
      DPVIDEOREFCLK => dp_video_ref_clk,
      EMIOCAN0PHYRX => emio_can0_phy_rx,
      EMIOCAN0PHYTX => emio_can0_phy_tx,
      EMIOCAN1PHYRX => emio_can1_phy_rx,
      EMIOCAN1PHYTX => emio_can1_phy_tx,
      EMIOENET0DMABUSWIDTH(1 downto 0) => emio_enet0_dma_bus_width(1 downto 0),
      EMIOENET0DMATXENDTOG => emio_enet0_dma_tx_end_tog,
      EMIOENET0DMATXSTATUSTOG => emio_enet0_dma_tx_status_tog,
      EMIOENET0EXTINTIN => emio_enet0_ext_int_in,
      EMIOENET0GEMTSUTIMERCNT(93 downto 0) => emio_enet0_enet_tsu_timer_cnt(93 downto 0),
      EMIOENET0GMIICOL => emio_enet0_gmii_col,
      EMIOENET0GMIICRS => emio_enet0_gmii_crs,
      EMIOENET0GMIIRXCLK => emio_enet0_gmii_rx_clk,
      EMIOENET0GMIIRXD(7 downto 0) => emio_enet0_gmii_rxd(7 downto 0),
      EMIOENET0GMIIRXDV => emio_enet0_gmii_rx_dv,
      EMIOENET0GMIIRXER => emio_enet0_gmii_rx_er,
      EMIOENET0GMIITXCLK => emio_enet0_gmii_tx_clk,
      EMIOENET0GMIITXD(7 downto 0) => emio_enet0_gmii_txd(7 downto 0),
      EMIOENET0GMIITXEN => emio_enet0_gmii_tx_en,
      EMIOENET0GMIITXER => emio_enet0_gmii_tx_er,
      EMIOENET0MDIOI => emio_enet0_mdio_i,
      EMIOENET0MDIOMDC => emio_enet0_mdio_mdc,
      EMIOENET0MDIOO => emio_enet0_mdio_o,
      EMIOENET0MDIOTN => \^emio_enet0_mdio_t_n\,
      EMIOENET0RXWDATA(7 downto 0) => emio_enet0_rx_w_data(7 downto 0),
      EMIOENET0RXWEOP => emio_enet0_rx_w_eop,
      EMIOENET0RXWERR => emio_enet0_rx_w_err,
      EMIOENET0RXWFLUSH => emio_enet0_rx_w_flush,
      EMIOENET0RXWOVERFLOW => emio_enet0_rx_w_overflow,
      EMIOENET0RXWSOP => emio_enet0_rx_w_sop,
      EMIOENET0RXWSTATUS(44 downto 0) => emio_enet0_rx_w_status(44 downto 0),
      EMIOENET0RXWWR => emio_enet0_rx_w_wr,
      EMIOENET0SPEEDMODE(2 downto 0) => emio_enet0_speed_mode(2 downto 0),
      EMIOENET0TXRCONTROL => emio_enet0_tx_r_control,
      EMIOENET0TXRDATA(7 downto 0) => emio_enet0_tx_r_data(7 downto 0),
      EMIOENET0TXRDATARDY => emio_enet0_tx_r_data_rdy,
      EMIOENET0TXREOP => emio_enet0_tx_r_eop,
      EMIOENET0TXRERR => emio_enet0_tx_r_err,
      EMIOENET0TXRFLUSHED => emio_enet0_tx_r_flushed,
      EMIOENET0TXRRD => emio_enet0_tx_r_rd,
      EMIOENET0TXRSOP => emio_enet0_tx_r_sop,
      EMIOENET0TXRSTATUS(3 downto 0) => emio_enet0_tx_r_status(3 downto 0),
      EMIOENET0TXRUNDERFLOW => emio_enet0_tx_r_underflow,
      EMIOENET0TXRVALID => emio_enet0_tx_r_valid,
      EMIOENET1DMABUSWIDTH(1 downto 0) => emio_enet1_dma_bus_width(1 downto 0),
      EMIOENET1DMATXENDTOG => emio_enet1_dma_tx_end_tog,
      EMIOENET1DMATXSTATUSTOG => emio_enet1_dma_tx_status_tog,
      EMIOENET1EXTINTIN => emio_enet1_ext_int_in,
      EMIOENET1GMIICOL => emio_enet1_gmii_col,
      EMIOENET1GMIICRS => emio_enet1_gmii_crs,
      EMIOENET1GMIIRXCLK => emio_enet1_gmii_rx_clk,
      EMIOENET1GMIIRXD(7 downto 0) => emio_enet1_gmii_rxd(7 downto 0),
      EMIOENET1GMIIRXDV => emio_enet1_gmii_rx_dv,
      EMIOENET1GMIIRXER => emio_enet1_gmii_rx_er,
      EMIOENET1GMIITXCLK => emio_enet1_gmii_tx_clk,
      EMIOENET1GMIITXD(7 downto 0) => emio_enet1_gmii_txd(7 downto 0),
      EMIOENET1GMIITXEN => emio_enet1_gmii_tx_en,
      EMIOENET1GMIITXER => emio_enet1_gmii_tx_er,
      EMIOENET1MDIOI => emio_enet1_mdio_i,
      EMIOENET1MDIOMDC => emio_enet1_mdio_mdc,
      EMIOENET1MDIOO => emio_enet1_mdio_o,
      EMIOENET1MDIOTN => \^emio_enet1_mdio_t_n\,
      EMIOENET1RXWDATA(7 downto 0) => emio_enet1_rx_w_data(7 downto 0),
      EMIOENET1RXWEOP => emio_enet1_rx_w_eop,
      EMIOENET1RXWERR => emio_enet1_rx_w_err,
      EMIOENET1RXWFLUSH => emio_enet1_rx_w_flush,
      EMIOENET1RXWOVERFLOW => emio_enet1_rx_w_overflow,
      EMIOENET1RXWSOP => emio_enet1_rx_w_sop,
      EMIOENET1RXWSTATUS(44 downto 0) => emio_enet1_rx_w_status(44 downto 0),
      EMIOENET1RXWWR => emio_enet1_rx_w_wr,
      EMIOENET1SPEEDMODE(2 downto 0) => emio_enet1_speed_mode(2 downto 0),
      EMIOENET1TXRCONTROL => emio_enet1_tx_r_control,
      EMIOENET1TXRDATA(7 downto 0) => emio_enet1_tx_r_data(7 downto 0),
      EMIOENET1TXRDATARDY => emio_enet1_tx_r_data_rdy,
      EMIOENET1TXREOP => emio_enet1_tx_r_eop,
      EMIOENET1TXRERR => emio_enet1_tx_r_err,
      EMIOENET1TXRFLUSHED => emio_enet1_tx_r_flushed,
      EMIOENET1TXRRD => emio_enet1_tx_r_rd,
      EMIOENET1TXRSOP => emio_enet1_tx_r_sop,
      EMIOENET1TXRSTATUS(3 downto 0) => emio_enet1_tx_r_status(3 downto 0),
      EMIOENET1TXRUNDERFLOW => emio_enet1_tx_r_underflow,
      EMIOENET1TXRVALID => emio_enet1_tx_r_valid,
      EMIOENET2DMABUSWIDTH(1 downto 0) => emio_enet2_dma_bus_width(1 downto 0),
      EMIOENET2DMATXENDTOG => emio_enet2_dma_tx_end_tog,
      EMIOENET2DMATXSTATUSTOG => emio_enet2_dma_tx_status_tog,
      EMIOENET2EXTINTIN => emio_enet2_ext_int_in,
      EMIOENET2GMIICOL => emio_enet2_gmii_col,
      EMIOENET2GMIICRS => emio_enet2_gmii_crs,
      EMIOENET2GMIIRXCLK => emio_enet2_gmii_rx_clk,
      EMIOENET2GMIIRXD(7 downto 0) => emio_enet2_gmii_rxd(7 downto 0),
      EMIOENET2GMIIRXDV => emio_enet2_gmii_rx_dv,
      EMIOENET2GMIIRXER => emio_enet2_gmii_rx_er,
      EMIOENET2GMIITXCLK => emio_enet2_gmii_tx_clk,
      EMIOENET2GMIITXD(7 downto 0) => emio_enet2_gmii_txd(7 downto 0),
      EMIOENET2GMIITXEN => emio_enet2_gmii_tx_en,
      EMIOENET2GMIITXER => emio_enet2_gmii_tx_er,
      EMIOENET2MDIOI => emio_enet2_mdio_i,
      EMIOENET2MDIOMDC => emio_enet2_mdio_mdc,
      EMIOENET2MDIOO => emio_enet2_mdio_o,
      EMIOENET2MDIOTN => \^emio_enet2_mdio_t_n\,
      EMIOENET2RXWDATA(7 downto 0) => emio_enet2_rx_w_data(7 downto 0),
      EMIOENET2RXWEOP => emio_enet2_rx_w_eop,
      EMIOENET2RXWERR => emio_enet2_rx_w_err,
      EMIOENET2RXWFLUSH => emio_enet2_rx_w_flush,
      EMIOENET2RXWOVERFLOW => emio_enet2_rx_w_overflow,
      EMIOENET2RXWSOP => emio_enet2_rx_w_sop,
      EMIOENET2RXWSTATUS(44 downto 0) => emio_enet2_rx_w_status(44 downto 0),
      EMIOENET2RXWWR => emio_enet2_rx_w_wr,
      EMIOENET2SPEEDMODE(2 downto 0) => emio_enet2_speed_mode(2 downto 0),
      EMIOENET2TXRCONTROL => emio_enet2_tx_r_control,
      EMIOENET2TXRDATA(7 downto 0) => emio_enet2_tx_r_data(7 downto 0),
      EMIOENET2TXRDATARDY => emio_enet2_tx_r_data_rdy,
      EMIOENET2TXREOP => emio_enet2_tx_r_eop,
      EMIOENET2TXRERR => emio_enet2_tx_r_err,
      EMIOENET2TXRFLUSHED => emio_enet2_tx_r_flushed,
      EMIOENET2TXRRD => emio_enet2_tx_r_rd,
      EMIOENET2TXRSOP => emio_enet2_tx_r_sop,
      EMIOENET2TXRSTATUS(3 downto 0) => emio_enet2_tx_r_status(3 downto 0),
      EMIOENET2TXRUNDERFLOW => emio_enet2_tx_r_underflow,
      EMIOENET2TXRVALID => emio_enet2_tx_r_valid,
      EMIOENET3DMABUSWIDTH(1 downto 0) => emio_enet3_dma_bus_width(1 downto 0),
      EMIOENET3DMATXENDTOG => emio_enet3_dma_tx_end_tog,
      EMIOENET3DMATXSTATUSTOG => emio_enet3_dma_tx_status_tog,
      EMIOENET3EXTINTIN => emio_enet3_ext_int_in,
      EMIOENET3GMIICOL => emio_enet3_gmii_col,
      EMIOENET3GMIICRS => emio_enet3_gmii_crs,
      EMIOENET3GMIIRXCLK => emio_enet3_gmii_rx_clk,
      EMIOENET3GMIIRXD(7 downto 0) => emio_enet3_gmii_rxd(7 downto 0),
      EMIOENET3GMIIRXDV => emio_enet3_gmii_rx_dv,
      EMIOENET3GMIIRXER => emio_enet3_gmii_rx_er,
      EMIOENET3GMIITXCLK => emio_enet3_gmii_tx_clk,
      EMIOENET3GMIITXD(7 downto 0) => emio_enet3_gmii_txd(7 downto 0),
      EMIOENET3GMIITXEN => emio_enet3_gmii_tx_en,
      EMIOENET3GMIITXER => emio_enet3_gmii_tx_er,
      EMIOENET3MDIOI => emio_enet3_mdio_i,
      EMIOENET3MDIOMDC => emio_enet3_mdio_mdc,
      EMIOENET3MDIOO => emio_enet3_mdio_o,
      EMIOENET3MDIOTN => \^emio_enet3_mdio_t_n\,
      EMIOENET3RXWDATA(7 downto 0) => emio_enet3_rx_w_data(7 downto 0),
      EMIOENET3RXWEOP => emio_enet3_rx_w_eop,
      EMIOENET3RXWERR => emio_enet3_rx_w_err,
      EMIOENET3RXWFLUSH => emio_enet3_rx_w_flush,
      EMIOENET3RXWOVERFLOW => emio_enet3_rx_w_overflow,
      EMIOENET3RXWSOP => emio_enet3_rx_w_sop,
      EMIOENET3RXWSTATUS(44 downto 0) => emio_enet3_rx_w_status(44 downto 0),
      EMIOENET3RXWWR => emio_enet3_rx_w_wr,
      EMIOENET3SPEEDMODE(2 downto 0) => emio_enet3_speed_mode(2 downto 0),
      EMIOENET3TXRCONTROL => emio_enet3_tx_r_control,
      EMIOENET3TXRDATA(7 downto 0) => emio_enet3_tx_r_data(7 downto 0),
      EMIOENET3TXRDATARDY => emio_enet3_tx_r_data_rdy,
      EMIOENET3TXREOP => emio_enet3_tx_r_eop,
      EMIOENET3TXRERR => emio_enet3_tx_r_err,
      EMIOENET3TXRFLUSHED => emio_enet3_tx_r_flushed,
      EMIOENET3TXRRD => emio_enet3_tx_r_rd,
      EMIOENET3TXRSOP => emio_enet3_tx_r_sop,
      EMIOENET3TXRSTATUS(3 downto 0) => emio_enet3_tx_r_status(3 downto 0),
      EMIOENET3TXRUNDERFLOW => emio_enet3_tx_r_underflow,
      EMIOENET3TXRVALID => emio_enet3_tx_r_valid,
      EMIOENETTSUCLK => emio_enet_tsu_clk,
      EMIOGEM0DELAYREQRX => emio_enet0_delay_req_rx,
      EMIOGEM0DELAYREQTX => emio_enet0_delay_req_tx,
      EMIOGEM0PDELAYREQRX => emio_enet0_pdelay_req_rx,
      EMIOGEM0PDELAYREQTX => emio_enet0_pdelay_req_tx,
      EMIOGEM0PDELAYRESPRX => emio_enet0_pdelay_resp_rx,
      EMIOGEM0PDELAYRESPTX => emio_enet0_pdelay_resp_tx,
      EMIOGEM0RXSOF => emio_enet0_rx_sof,
      EMIOGEM0SYNCFRAMERX => emio_enet0_sync_frame_rx,
      EMIOGEM0SYNCFRAMETX => emio_enet0_sync_frame_tx,
      EMIOGEM0TSUINCCTRL(1 downto 0) => emio_enet0_tsu_inc_ctrl(1 downto 0),
      EMIOGEM0TSUTIMERCMPVAL => emio_enet0_tsu_timer_cmp_val,
      EMIOGEM0TXRFIXEDLAT => emio_enet0_tx_r_fixed_lat,
      EMIOGEM0TXSOF => emio_enet0_tx_sof,
      EMIOGEM1DELAYREQRX => emio_enet1_delay_req_rx,
      EMIOGEM1DELAYREQTX => emio_enet1_delay_req_tx,
      EMIOGEM1PDELAYREQRX => emio_enet1_pdelay_req_rx,
      EMIOGEM1PDELAYREQTX => emio_enet1_pdelay_req_tx,
      EMIOGEM1PDELAYRESPRX => emio_enet1_pdelay_resp_rx,
      EMIOGEM1PDELAYRESPTX => emio_enet1_pdelay_resp_tx,
      EMIOGEM1RXSOF => emio_enet1_rx_sof,
      EMIOGEM1SYNCFRAMERX => emio_enet1_sync_frame_rx,
      EMIOGEM1SYNCFRAMETX => emio_enet1_sync_frame_tx,
      EMIOGEM1TSUINCCTRL(1 downto 0) => emio_enet1_tsu_inc_ctrl(1 downto 0),
      EMIOGEM1TSUTIMERCMPVAL => emio_enet1_tsu_timer_cmp_val,
      EMIOGEM1TXRFIXEDLAT => emio_enet1_tx_r_fixed_lat,
      EMIOGEM1TXSOF => emio_enet1_tx_sof,
      EMIOGEM2DELAYREQRX => emio_enet2_delay_req_rx,
      EMIOGEM2DELAYREQTX => emio_enet2_delay_req_tx,
      EMIOGEM2PDELAYREQRX => emio_enet2_pdelay_req_rx,
      EMIOGEM2PDELAYREQTX => emio_enet2_pdelay_req_tx,
      EMIOGEM2PDELAYRESPRX => emio_enet2_pdelay_resp_rx,
      EMIOGEM2PDELAYRESPTX => emio_enet2_pdelay_resp_tx,
      EMIOGEM2RXSOF => emio_enet2_rx_sof,
      EMIOGEM2SYNCFRAMERX => emio_enet2_sync_frame_rx,
      EMIOGEM2SYNCFRAMETX => emio_enet2_sync_frame_tx,
      EMIOGEM2TSUINCCTRL(1 downto 0) => emio_enet2_tsu_inc_ctrl(1 downto 0),
      EMIOGEM2TSUTIMERCMPVAL => emio_enet2_tsu_timer_cmp_val,
      EMIOGEM2TXRFIXEDLAT => emio_enet2_tx_r_fixed_lat,
      EMIOGEM2TXSOF => emio_enet2_tx_sof,
      EMIOGEM3DELAYREQRX => emio_enet3_delay_req_rx,
      EMIOGEM3DELAYREQTX => emio_enet3_delay_req_tx,
      EMIOGEM3PDELAYREQRX => emio_enet3_pdelay_req_rx,
      EMIOGEM3PDELAYREQTX => emio_enet3_pdelay_req_tx,
      EMIOGEM3PDELAYRESPRX => emio_enet3_pdelay_resp_rx,
      EMIOGEM3PDELAYRESPTX => emio_enet3_pdelay_resp_tx,
      EMIOGEM3RXSOF => emio_enet3_rx_sof,
      EMIOGEM3SYNCFRAMERX => emio_enet3_sync_frame_rx,
      EMIOGEM3SYNCFRAMETX => emio_enet3_sync_frame_tx,
      EMIOGEM3TSUINCCTRL(1 downto 0) => emio_enet3_tsu_inc_ctrl(1 downto 0),
      EMIOGEM3TSUTIMERCMPVAL => emio_enet3_tsu_timer_cmp_val,
      EMIOGEM3TXRFIXEDLAT => emio_enet3_tx_r_fixed_lat,
      EMIOGEM3TXSOF => emio_enet3_tx_sof,
      EMIOGPIOI(95 downto 1) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      EMIOGPIOI(0) => emio_gpio_i(0),
      EMIOGPIOO(95) => pl_resetn0,
      EMIOGPIOO(94 downto 1) => NLW_PS8_i_EMIOGPIOO_UNCONNECTED(94 downto 1),
      EMIOGPIOO(0) => emio_gpio_o(0),
      EMIOGPIOTN(95 downto 1) => NLW_PS8_i_EMIOGPIOTN_UNCONNECTED(95 downto 1),
      EMIOGPIOTN(0) => \^emio_gpio_t_n\(0),
      EMIOHUBPORTOVERCRNTUSB20 => emio_hub_port_overcrnt_usb2_0,
      EMIOHUBPORTOVERCRNTUSB21 => emio_hub_port_overcrnt_usb2_1,
      EMIOHUBPORTOVERCRNTUSB30 => emio_hub_port_overcrnt_usb3_0,
      EMIOHUBPORTOVERCRNTUSB31 => emio_hub_port_overcrnt_usb3_1,
      EMIOI2C0SCLI => emio_i2c0_scl_i,
      EMIOI2C0SCLO => emio_i2c0_scl_o,
      EMIOI2C0SCLTN => \^emio_i2c0_scl_t_n\,
      EMIOI2C0SDAI => emio_i2c0_sda_i,
      EMIOI2C0SDAO => emio_i2c0_sda_o,
      EMIOI2C0SDATN => \^emio_i2c0_sda_t_n\,
      EMIOI2C1SCLI => emio_i2c1_scl_i,
      EMIOI2C1SCLO => emio_i2c1_scl_o,
      EMIOI2C1SCLTN => \^emio_i2c1_scl_t_n\,
      EMIOI2C1SDAI => emio_i2c1_sda_i,
      EMIOI2C1SDAO => emio_i2c1_sda_o,
      EMIOI2C1SDATN => \^emio_i2c1_sda_t_n\,
      EMIOSDIO0BUSPOWER => emio_sdio0_buspower,
      EMIOSDIO0BUSVOLT(2 downto 0) => emio_sdio0_bus_volt(2 downto 0),
      EMIOSDIO0CDN => emio_sdio0_cd_n,
      EMIOSDIO0CLKOUT => emio_sdio0_clkout,
      EMIOSDIO0CMDENA => emio_sdio0_cmdena_i,
      EMIOSDIO0CMDIN => emio_sdio0_cmdin,
      EMIOSDIO0CMDOUT => emio_sdio0_cmdout,
      EMIOSDIO0DATAENA(7 downto 0) => emio_sdio0_dataena_i(7 downto 0),
      EMIOSDIO0DATAIN(7 downto 0) => emio_sdio0_datain(7 downto 0),
      EMIOSDIO0DATAOUT(7 downto 0) => emio_sdio0_dataout(7 downto 0),
      EMIOSDIO0FBCLKIN => emio_sdio0_fb_clk_in,
      EMIOSDIO0LEDCONTROL => emio_sdio0_ledcontrol,
      EMIOSDIO0WP => emio_sdio0_wp,
      EMIOSDIO1BUSPOWER => emio_sdio1_buspower,
      EMIOSDIO1BUSVOLT(2 downto 0) => emio_sdio1_bus_volt(2 downto 0),
      EMIOSDIO1CDN => emio_sdio1_cd_n,
      EMIOSDIO1CLKOUT => emio_sdio1_clkout,
      EMIOSDIO1CMDENA => emio_sdio1_cmdena_i,
      EMIOSDIO1CMDIN => emio_sdio1_cmdin,
      EMIOSDIO1CMDOUT => emio_sdio1_cmdout,
      EMIOSDIO1DATAENA(7 downto 0) => emio_sdio1_dataena_i(7 downto 0),
      EMIOSDIO1DATAIN(7 downto 0) => emio_sdio1_datain(7 downto 0),
      EMIOSDIO1DATAOUT(7 downto 0) => emio_sdio1_dataout(7 downto 0),
      EMIOSDIO1FBCLKIN => emio_sdio1_fb_clk_in,
      EMIOSDIO1LEDCONTROL => emio_sdio1_ledcontrol,
      EMIOSDIO1WP => emio_sdio1_wp,
      EMIOSPI0MI => emio_spi0_m_i,
      EMIOSPI0MO => emio_spi0_m_o,
      EMIOSPI0MOTN => \^emio_spi0_mo_t_n\,
      EMIOSPI0SCLKI => emio_spi0_sclk_i,
      EMIOSPI0SCLKO => emio_spi0_sclk_o,
      EMIOSPI0SCLKTN => \^emio_spi0_sclk_t_n\,
      EMIOSPI0SI => emio_spi0_s_i,
      EMIOSPI0SO => emio_spi0_s_o,
      EMIOSPI0SSIN => emio_spi0_ss_i_n,
      EMIOSPI0SSNTN => \^emio_spi0_ss_n_t_n\,
      EMIOSPI0SSON(2) => emio_spi0_ss2_o_n,
      EMIOSPI0SSON(1) => emio_spi0_ss1_o_n,
      EMIOSPI0SSON(0) => emio_spi0_ss_o_n,
      EMIOSPI0STN => \^emio_spi0_so_t_n\,
      EMIOSPI1MI => emio_spi1_m_i,
      EMIOSPI1MO => emio_spi1_m_o,
      EMIOSPI1MOTN => \^emio_spi1_mo_t_n\,
      EMIOSPI1SCLKI => emio_spi1_sclk_i,
      EMIOSPI1SCLKO => emio_spi1_sclk_o,
      EMIOSPI1SCLKTN => \^emio_spi1_sclk_t_n\,
      EMIOSPI1SI => emio_spi1_s_i,
      EMIOSPI1SO => emio_spi1_s_o,
      EMIOSPI1SSIN => emio_spi1_ss_i_n,
      EMIOSPI1SSNTN => \^emio_spi1_ss_n_t_n\,
      EMIOSPI1SSON(2) => emio_spi1_ss2_o_n,
      EMIOSPI1SSON(1) => emio_spi1_ss1_o_n,
      EMIOSPI1SSON(0) => emio_spi1_ss_o_n,
      EMIOSPI1STN => \^emio_spi1_so_t_n\,
      EMIOTTC0CLKI(2 downto 0) => emio_ttc0_clk_i(2 downto 0),
      EMIOTTC0WAVEO(2 downto 0) => emio_ttc0_wave_o(2 downto 0),
      EMIOTTC1CLKI(2 downto 0) => emio_ttc1_clk_i(2 downto 0),
      EMIOTTC1WAVEO(2 downto 0) => emio_ttc1_wave_o(2 downto 0),
      EMIOTTC2CLKI(2 downto 0) => emio_ttc2_clk_i(2 downto 0),
      EMIOTTC2WAVEO(2 downto 0) => emio_ttc2_wave_o(2 downto 0),
      EMIOTTC3CLKI(2 downto 0) => emio_ttc3_clk_i(2 downto 0),
      EMIOTTC3WAVEO(2 downto 0) => emio_ttc3_wave_o(2 downto 0),
      EMIOU2DSPORTVBUSCTRLUSB30 => emio_u2dsport_vbus_ctrl_usb3_0,
      EMIOU2DSPORTVBUSCTRLUSB31 => emio_u2dsport_vbus_ctrl_usb3_1,
      EMIOU3DSPORTVBUSCTRLUSB30 => emio_u3dsport_vbus_ctrl_usb3_0,
      EMIOU3DSPORTVBUSCTRLUSB31 => emio_u3dsport_vbus_ctrl_usb3_1,
      EMIOUART0CTSN => emio_uart0_ctsn,
      EMIOUART0DCDN => emio_uart0_dcdn,
      EMIOUART0DSRN => emio_uart0_dsrn,
      EMIOUART0DTRN => emio_uart0_dtrn,
      EMIOUART0RIN => emio_uart0_rin,
      EMIOUART0RTSN => emio_uart0_rtsn,
      EMIOUART0RX => emio_uart0_rxd,
      EMIOUART0TX => emio_uart0_txd,
      EMIOUART1CTSN => emio_uart1_ctsn,
      EMIOUART1DCDN => emio_uart1_dcdn,
      EMIOUART1DSRN => emio_uart1_dsrn,
      EMIOUART1DTRN => emio_uart1_dtrn,
      EMIOUART1RIN => emio_uart1_rin,
      EMIOUART1RTSN => emio_uart1_rtsn,
      EMIOUART1RX => emio_uart1_rxd,
      EMIOUART1TX => emio_uart1_txd,
      EMIOWDT0CLKI => emio_wdt0_clk_i,
      EMIOWDT0RSTO => emio_wdt0_rst_o,
      EMIOWDT1CLKI => emio_wdt1_clk_i,
      EMIOWDT1RSTO => emio_wdt1_rst_o,
      FMIOGEM0FIFORXCLKFROMPL => '0',
      FMIOGEM0FIFORXCLKTOPLBUFG => fmio_gem0_fifo_rx_clk_to_pl_bufg,
      FMIOGEM0FIFOTXCLKFROMPL => '0',
      FMIOGEM0FIFOTXCLKTOPLBUFG => fmio_gem0_fifo_tx_clk_to_pl_bufg,
      FMIOGEM0SIGNALDETECT => emio_enet0_signal_detect,
      FMIOGEM1FIFORXCLKFROMPL => '0',
      FMIOGEM1FIFORXCLKTOPLBUFG => fmio_gem1_fifo_rx_clk_to_pl_bufg,
      FMIOGEM1FIFOTXCLKFROMPL => '0',
      FMIOGEM1FIFOTXCLKTOPLBUFG => fmio_gem1_fifo_tx_clk_to_pl_bufg,
      FMIOGEM1SIGNALDETECT => emio_enet1_signal_detect,
      FMIOGEM2FIFORXCLKFROMPL => '0',
      FMIOGEM2FIFORXCLKTOPLBUFG => fmio_gem2_fifo_rx_clk_to_pl_bufg,
      FMIOGEM2FIFOTXCLKFROMPL => '0',
      FMIOGEM2FIFOTXCLKTOPLBUFG => fmio_gem2_fifo_tx_clk_to_pl_bufg,
      FMIOGEM2SIGNALDETECT => emio_enet2_signal_detect,
      FMIOGEM3FIFORXCLKFROMPL => '0',
      FMIOGEM3FIFORXCLKTOPLBUFG => fmio_gem3_fifo_rx_clk_to_pl_bufg,
      FMIOGEM3FIFOTXCLKFROMPL => '0',
      FMIOGEM3FIFOTXCLKTOPLBUFG => fmio_gem3_fifo_tx_clk_to_pl_bufg,
      FMIOGEM3SIGNALDETECT => emio_enet3_signal_detect,
      FMIOGEMTSUCLKFROMPL => fmio_gem_tsu_clk_from_pl,
      FMIOGEMTSUCLKTOPLBUFG => fmio_gem_tsu_clk_to_pl_bufg,
      FTMGPI(31 downto 0) => ftm_gpi(31 downto 0),
      FTMGPO(31 downto 0) => ftm_gpo(31 downto 0),
      GDMA2PLCACK(7 downto 0) => gdma_perif_cack(7 downto 0),
      GDMA2PLTVLD(7 downto 0) => gdma_perif_tvld(7 downto 0),
      GDMAFCICLK(7 downto 0) => perif_gdma_clk(7 downto 0),
      MAXIGP0ACLK => maxihpm0_fpd_aclk,
      MAXIGP0ARADDR(39 downto 0) => maxigp0_araddr(39 downto 0),
      MAXIGP0ARBURST(1 downto 0) => maxigp0_arburst(1 downto 0),
      MAXIGP0ARCACHE(3 downto 0) => maxigp0_arcache(3 downto 0),
      MAXIGP0ARID(15 downto 0) => maxigp0_arid(15 downto 0),
      MAXIGP0ARLEN(7 downto 0) => maxigp0_arlen(7 downto 0),
      MAXIGP0ARLOCK => maxigp0_arlock,
      MAXIGP0ARPROT(2 downto 0) => maxigp0_arprot(2 downto 0),
      MAXIGP0ARQOS(3 downto 0) => maxigp0_arqos(3 downto 0),
      MAXIGP0ARREADY => maxigp0_arready,
      MAXIGP0ARSIZE(2 downto 0) => maxigp0_arsize(2 downto 0),
      MAXIGP0ARUSER(15 downto 0) => maxigp0_aruser(15 downto 0),
      MAXIGP0ARVALID => maxigp0_arvalid,
      MAXIGP0AWADDR(39 downto 0) => maxigp0_awaddr(39 downto 0),
      MAXIGP0AWBURST(1 downto 0) => maxigp0_awburst(1 downto 0),
      MAXIGP0AWCACHE(3 downto 0) => maxigp0_awcache(3 downto 0),
      MAXIGP0AWID(15 downto 0) => maxigp0_awid(15 downto 0),
      MAXIGP0AWLEN(7 downto 0) => maxigp0_awlen(7 downto 0),
      MAXIGP0AWLOCK => maxigp0_awlock,
      MAXIGP0AWPROT(2 downto 0) => maxigp0_awprot(2 downto 0),
      MAXIGP0AWQOS(3 downto 0) => maxigp0_awqos(3 downto 0),
      MAXIGP0AWREADY => maxigp0_awready,
      MAXIGP0AWSIZE(2 downto 0) => maxigp0_awsize(2 downto 0),
      MAXIGP0AWUSER(15 downto 0) => maxigp0_awuser(15 downto 0),
      MAXIGP0AWVALID => maxigp0_awvalid,
      MAXIGP0BID(15 downto 0) => maxigp0_bid(15 downto 0),
      MAXIGP0BREADY => maxigp0_bready,
      MAXIGP0BRESP(1 downto 0) => maxigp0_bresp(1 downto 0),
      MAXIGP0BVALID => maxigp0_bvalid,
      MAXIGP0RDATA(127 downto 32) => B"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      MAXIGP0RDATA(31 downto 0) => maxigp0_rdata(31 downto 0),
      MAXIGP0RID(15 downto 0) => maxigp0_rid(15 downto 0),
      MAXIGP0RLAST => maxigp0_rlast,
      MAXIGP0RREADY => maxigp0_rready,
      MAXIGP0RRESP(1 downto 0) => maxigp0_rresp(1 downto 0),
      MAXIGP0RVALID => maxigp0_rvalid,
      MAXIGP0WDATA(127 downto 32) => NLW_PS8_i_MAXIGP0WDATA_UNCONNECTED(127 downto 32),
      MAXIGP0WDATA(31 downto 0) => maxigp0_wdata(31 downto 0),
      MAXIGP0WLAST => maxigp0_wlast,
      MAXIGP0WREADY => maxigp0_wready,
      MAXIGP0WSTRB(15 downto 4) => NLW_PS8_i_MAXIGP0WSTRB_UNCONNECTED(15 downto 4),
      MAXIGP0WSTRB(3 downto 0) => maxigp0_wstrb(3 downto 0),
      MAXIGP0WVALID => maxigp0_wvalid,
      MAXIGP1ACLK => maxihpm1_fpd_aclk,
      MAXIGP1ARADDR(39 downto 0) => maxigp1_araddr(39 downto 0),
      MAXIGP1ARBURST(1 downto 0) => maxigp1_arburst(1 downto 0),
      MAXIGP1ARCACHE(3 downto 0) => maxigp1_arcache(3 downto 0),
      MAXIGP1ARID(15 downto 0) => maxigp1_arid(15 downto 0),
      MAXIGP1ARLEN(7 downto 0) => maxigp1_arlen(7 downto 0),
      MAXIGP1ARLOCK => maxigp1_arlock,
      MAXIGP1ARPROT(2 downto 0) => maxigp1_arprot(2 downto 0),
      MAXIGP1ARQOS(3 downto 0) => maxigp1_arqos(3 downto 0),
      MAXIGP1ARREADY => maxigp1_arready,
      MAXIGP1ARSIZE(2 downto 0) => maxigp1_arsize(2 downto 0),
      MAXIGP1ARUSER(15 downto 0) => maxigp1_aruser(15 downto 0),
      MAXIGP1ARVALID => maxigp1_arvalid,
      MAXIGP1AWADDR(39 downto 0) => maxigp1_awaddr(39 downto 0),
      MAXIGP1AWBURST(1 downto 0) => maxigp1_awburst(1 downto 0),
      MAXIGP1AWCACHE(3 downto 0) => maxigp1_awcache(3 downto 0),
      MAXIGP1AWID(15 downto 0) => maxigp1_awid(15 downto 0),
      MAXIGP1AWLEN(7 downto 0) => maxigp1_awlen(7 downto 0),
      MAXIGP1AWLOCK => maxigp1_awlock,
      MAXIGP1AWPROT(2 downto 0) => maxigp1_awprot(2 downto 0),
      MAXIGP1AWQOS(3 downto 0) => maxigp1_awqos(3 downto 0),
      MAXIGP1AWREADY => maxigp1_awready,
      MAXIGP1AWSIZE(2 downto 0) => maxigp1_awsize(2 downto 0),
      MAXIGP1AWUSER(15 downto 0) => maxigp1_awuser(15 downto 0),
      MAXIGP1AWVALID => maxigp1_awvalid,
      MAXIGP1BID(15 downto 0) => maxigp1_bid(15 downto 0),
      MAXIGP1BREADY => maxigp1_bready,
      MAXIGP1BRESP(1 downto 0) => maxigp1_bresp(1 downto 0),
      MAXIGP1BVALID => maxigp1_bvalid,
      MAXIGP1RDATA(127 downto 32) => B"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      MAXIGP1RDATA(31 downto 0) => maxigp1_rdata(31 downto 0),
      MAXIGP1RID(15 downto 0) => maxigp1_rid(15 downto 0),
      MAXIGP1RLAST => maxigp1_rlast,
      MAXIGP1RREADY => maxigp1_rready,
      MAXIGP1RRESP(1 downto 0) => maxigp1_rresp(1 downto 0),
      MAXIGP1RVALID => maxigp1_rvalid,
      MAXIGP1WDATA(127 downto 32) => NLW_PS8_i_MAXIGP1WDATA_UNCONNECTED(127 downto 32),
      MAXIGP1WDATA(31 downto 0) => maxigp1_wdata(31 downto 0),
      MAXIGP1WLAST => maxigp1_wlast,
      MAXIGP1WREADY => maxigp1_wready,
      MAXIGP1WSTRB(15 downto 4) => NLW_PS8_i_MAXIGP1WSTRB_UNCONNECTED(15 downto 4),
      MAXIGP1WSTRB(3 downto 0) => maxigp1_wstrb(3 downto 0),
      MAXIGP1WVALID => maxigp1_wvalid,
      MAXIGP2ACLK => maxihpm0_lpd_aclk,
      MAXIGP2ARADDR(39 downto 0) => maxigp2_araddr(39 downto 0),
      MAXIGP2ARBURST(1 downto 0) => maxigp2_arburst(1 downto 0),
      MAXIGP2ARCACHE(3 downto 0) => maxigp2_arcache(3 downto 0),
      MAXIGP2ARID(15 downto 0) => maxigp2_arid(15 downto 0),
      MAXIGP2ARLEN(7 downto 0) => maxigp2_arlen(7 downto 0),
      MAXIGP2ARLOCK => maxigp2_arlock,
      MAXIGP2ARPROT(2 downto 0) => maxigp2_arprot(2 downto 0),
      MAXIGP2ARQOS(3 downto 0) => maxigp2_arqos(3 downto 0),
      MAXIGP2ARREADY => maxigp2_arready,
      MAXIGP2ARSIZE(2 downto 0) => maxigp2_arsize(2 downto 0),
      MAXIGP2ARUSER(15 downto 0) => maxigp2_aruser(15 downto 0),
      MAXIGP2ARVALID => maxigp2_arvalid,
      MAXIGP2AWADDR(39 downto 0) => maxigp2_awaddr(39 downto 0),
      MAXIGP2AWBURST(1 downto 0) => maxigp2_awburst(1 downto 0),
      MAXIGP2AWCACHE(3 downto 0) => maxigp2_awcache(3 downto 0),
      MAXIGP2AWID(15 downto 0) => maxigp2_awid(15 downto 0),
      MAXIGP2AWLEN(7 downto 0) => maxigp2_awlen(7 downto 0),
      MAXIGP2AWLOCK => maxigp2_awlock,
      MAXIGP2AWPROT(2 downto 0) => maxigp2_awprot(2 downto 0),
      MAXIGP2AWQOS(3 downto 0) => maxigp2_awqos(3 downto 0),
      MAXIGP2AWREADY => maxigp2_awready,
      MAXIGP2AWSIZE(2 downto 0) => maxigp2_awsize(2 downto 0),
      MAXIGP2AWUSER(15 downto 0) => maxigp2_awuser(15 downto 0),
      MAXIGP2AWVALID => maxigp2_awvalid,
      MAXIGP2BID(15 downto 0) => maxigp2_bid(15 downto 0),
      MAXIGP2BREADY => maxigp2_bready,
      MAXIGP2BRESP(1 downto 0) => maxigp2_bresp(1 downto 0),
      MAXIGP2BVALID => maxigp2_bvalid,
      MAXIGP2RDATA(127 downto 32) => B"000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      MAXIGP2RDATA(31 downto 0) => maxigp2_rdata(31 downto 0),
      MAXIGP2RID(15 downto 0) => maxigp2_rid(15 downto 0),
      MAXIGP2RLAST => maxigp2_rlast,
      MAXIGP2RREADY => maxigp2_rready,
      MAXIGP2RRESP(1 downto 0) => maxigp2_rresp(1 downto 0),
      MAXIGP2RVALID => maxigp2_rvalid,
      MAXIGP2WDATA(127 downto 32) => NLW_PS8_i_MAXIGP2WDATA_UNCONNECTED(127 downto 32),
      MAXIGP2WDATA(31 downto 0) => maxigp2_wdata(31 downto 0),
      MAXIGP2WLAST => maxigp2_wlast,
      MAXIGP2WREADY => maxigp2_wready,
      MAXIGP2WSTRB(15 downto 4) => NLW_PS8_i_MAXIGP2WSTRB_UNCONNECTED(15 downto 4),
      MAXIGP2WSTRB(3 downto 0) => maxigp2_wstrb(3 downto 0),
      MAXIGP2WVALID => maxigp2_wvalid,
      NFIQ0LPDRPU => nfiq0_lpd_rpu,
      NFIQ1LPDRPU => nfiq1_lpd_rpu,
      NIRQ0LPDRPU => nirq0_lpd_rpu,
      NIRQ1LPDRPU => nirq1_lpd_rpu,
      OSCRTCCLK => osc_rtc_clk,
      PL2ADMACVLD(7 downto 0) => pl2adma_cvld(7 downto 0),
      PL2ADMATACK(7 downto 0) => pl2adma_tack(7 downto 0),
      PL2GDMACVLD(7 downto 0) => perif_gdma_cvld(7 downto 0),
      PL2GDMATACK(7 downto 0) => perif_gdma_tack(7 downto 0),
      PLACECLK => sacefpd_aclk,
      PLACPINACT => pl_acpinact,
      PLCLK(3) => pl_clk3,
      PLCLK(2) => pl_clk2,
      PLCLK(1) => pl_clk1,
      PLCLK(0) => pl_clk_unbuffered(0),
      PLFPGASTOP(3 downto 0) => pl_clock_stop(3 downto 0),
      PLLAUXREFCLKFPD(2 downto 0) => pll_aux_refclk_fpd(2 downto 0),
      PLLAUXREFCLKLPD(1 downto 0) => pll_aux_refclk_lpd(1 downto 0),
      PLPMUGPI(31 downto 0) => pl_pmu_gpi(31 downto 0),
      PLPSAPUGICFIQ(3 downto 0) => pl_ps_apugic_fiq(3 downto 0),
      PLPSAPUGICIRQ(3 downto 0) => pl_ps_apugic_irq(3 downto 0),
      PLPSEVENTI => pl_ps_eventi,
      PLPSIRQ0(7 downto 1) => B"0000000",
      PLPSIRQ0(0) => pl_ps_irq0(0),
      PLPSIRQ1(7 downto 1) => B"0000000",
      PLPSIRQ1(0) => pl_ps_irq1(0),
      PLPSTRACECLK => pl_ps_trace_clk,
      PLPSTRIGACK(3) => pl_ps_trigack_3,
      PLPSTRIGACK(2) => pl_ps_trigack_2,
      PLPSTRIGACK(1) => pl_ps_trigack_1,
      PLPSTRIGACK(0) => pl_ps_trigack_0,
      PLPSTRIGGER(3) => pl_ps_trigger_3,
      PLPSTRIGGER(2) => pl_ps_trigger_2,
      PLPSTRIGGER(1) => pl_ps_trigger_1,
      PLPSTRIGGER(0) => pl_ps_trigger_0,
      PMUAIBAFIFMFPDREQ => pmu_aib_afifm_fpd_req,
      PMUAIBAFIFMLPDREQ => pmu_aib_afifm_lpd_req,
      PMUERRORFROMPL(3 downto 0) => pmu_error_from_pl(3 downto 0),
      PMUERRORTOPL(46 downto 0) => pmu_error_to_pl(46 downto 0),
      PMUPLGPO(31 downto 0) => pmu_pl_gpo(31 downto 0),
      PSPLEVENTO => ps_pl_evento,
      PSPLIRQFPD(63 downto 56) => NLW_PS8_i_PSPLIRQFPD_UNCONNECTED(63 downto 56),
      PSPLIRQFPD(55) => ps_pl_irq_intf_fpd_smmu,
      PSPLIRQFPD(54) => ps_pl_irq_intf_ppd_cci,
      PSPLIRQFPD(53) => ps_pl_irq_apu_regs,
      PSPLIRQFPD(52) => ps_pl_irq_apu_exterr,
      PSPLIRQFPD(51) => ps_pl_irq_apu_l2err,
      PSPLIRQFPD(50 downto 47) => ps_pl_irq_apu_comm(3 downto 0),
      PSPLIRQFPD(46 downto 43) => ps_pl_irq_apu_pmu(3 downto 0),
      PSPLIRQFPD(42 downto 39) => ps_pl_irq_apu_cti(3 downto 0),
      PSPLIRQFPD(38 downto 35) => ps_pl_irq_apu_cpumnt(3 downto 0),
      PSPLIRQFPD(34) => ps_pl_irq_xmpu_fpd,
      PSPLIRQFPD(33) => ps_pl_irq_sata,
      PSPLIRQFPD(32) => ps_pl_irq_gpu,
      PSPLIRQFPD(31 downto 24) => ps_pl_irq_gdma_chan(7 downto 0),
      PSPLIRQFPD(23) => ps_pl_irq_apm_fpd,
      PSPLIRQFPD(22) => ps_pl_irq_dpdma,
      PSPLIRQFPD(21) => ps_pl_irq_fpd_atb_error,
      PSPLIRQFPD(20) => ps_pl_irq_fpd_apb_int,
      PSPLIRQFPD(19) => ps_pl_irq_dport,
      PSPLIRQFPD(18) => ps_pl_irq_pcie_msc,
      PSPLIRQFPD(17) => ps_pl_irq_pcie_dma,
      PSPLIRQFPD(16) => ps_pl_irq_pcie_legacy,
      PSPLIRQFPD(15 downto 14) => ps_pl_irq_pcie_msi(1 downto 0),
      PSPLIRQFPD(13) => ps_pl_irq_fp_wdt,
      PSPLIRQFPD(12) => ps_pl_irq_ddr_ss,
      PSPLIRQFPD(11 downto 0) => NLW_PS8_i_PSPLIRQFPD_UNCONNECTED(11 downto 0),
      PSPLIRQLPD(99 downto 89) => NLW_PS8_i_PSPLIRQLPD_UNCONNECTED(99 downto 89),
      PSPLIRQLPD(88) => ps_pl_irq_xmpu_lpd,
      PSPLIRQLPD(87) => ps_pl_irq_efuse,
      PSPLIRQLPD(86) => ps_pl_irq_csu_dma,
      PSPLIRQLPD(85) => ps_pl_irq_csu,
      PSPLIRQLPD(84 downto 77) => ps_pl_irq_adma_chan(7 downto 0),
      PSPLIRQLPD(76 downto 75) => ps_pl_irq_usb3_0_pmu_wakeup(1 downto 0),
      PSPLIRQLPD(74) => ps_pl_irq_usb3_1_otg,
      PSPLIRQLPD(73 downto 70) => ps_pl_irq_usb3_1_endpoint(3 downto 0),
      PSPLIRQLPD(69) => ps_pl_irq_usb3_0_otg,
      PSPLIRQLPD(68 downto 65) => ps_pl_irq_usb3_0_endpoint(3 downto 0),
      PSPLIRQLPD(64) => ps_pl_irq_enet3_wake,
      PSPLIRQLPD(63) => ps_pl_irq_enet3,
      PSPLIRQLPD(62) => ps_pl_irq_enet2_wake,
      PSPLIRQLPD(61) => ps_pl_irq_enet2,
      PSPLIRQLPD(60) => ps_pl_irq_enet1_wake,
      PSPLIRQLPD(59) => ps_pl_irq_enet1,
      PSPLIRQLPD(58) => ps_pl_irq_enet0_wake,
      PSPLIRQLPD(57) => ps_pl_irq_enet0,
      PSPLIRQLPD(56) => ps_pl_irq_ams,
      PSPLIRQLPD(55) => ps_pl_irq_aib_axi,
      PSPLIRQLPD(54) => ps_pl_irq_atb_err_lpd,
      PSPLIRQLPD(53) => ps_pl_irq_csu_pmu_wdt,
      PSPLIRQLPD(52) => ps_pl_irq_lp_wdt,
      PSPLIRQLPD(51) => ps_pl_irq_sdio1_wake,
      PSPLIRQLPD(50) => ps_pl_irq_sdio0_wake,
      PSPLIRQLPD(49) => ps_pl_irq_sdio1,
      PSPLIRQLPD(48) => ps_pl_irq_sdio0,
      PSPLIRQLPD(47) => ps_pl_irq_ttc3_2,
      PSPLIRQLPD(46) => ps_pl_irq_ttc3_1,
      PSPLIRQLPD(45) => ps_pl_irq_ttc3_0,
      PSPLIRQLPD(44) => ps_pl_irq_ttc2_2,
      PSPLIRQLPD(43) => ps_pl_irq_ttc2_1,
      PSPLIRQLPD(42) => ps_pl_irq_ttc2_0,
      PSPLIRQLPD(41) => ps_pl_irq_ttc1_2,
      PSPLIRQLPD(40) => ps_pl_irq_ttc1_1,
      PSPLIRQLPD(39) => ps_pl_irq_ttc1_0,
      PSPLIRQLPD(38) => ps_pl_irq_ttc0_2,
      PSPLIRQLPD(37) => ps_pl_irq_ttc0_1,
      PSPLIRQLPD(36) => ps_pl_irq_ttc0_0,
      PSPLIRQLPD(35) => ps_pl_irq_ipi_channel0,
      PSPLIRQLPD(34) => ps_pl_irq_ipi_channel1,
      PSPLIRQLPD(33) => ps_pl_irq_ipi_channel2,
      PSPLIRQLPD(32) => ps_pl_irq_ipi_channel7,
      PSPLIRQLPD(31) => ps_pl_irq_ipi_channel8,
      PSPLIRQLPD(30) => ps_pl_irq_ipi_channel9,
      PSPLIRQLPD(29) => ps_pl_irq_ipi_channel10,
      PSPLIRQLPD(28) => ps_pl_irq_clkmon,
      PSPLIRQLPD(27) => ps_pl_irq_rtc_seconds,
      PSPLIRQLPD(26) => ps_pl_irq_rtc_alaram,
      PSPLIRQLPD(25) => ps_pl_irq_lpd_apm,
      PSPLIRQLPD(24) => ps_pl_irq_can1,
      PSPLIRQLPD(23) => ps_pl_irq_can0,
      PSPLIRQLPD(22) => ps_pl_irq_uart1,
      PSPLIRQLPD(21) => ps_pl_irq_uart0,
      PSPLIRQLPD(20) => ps_pl_irq_spi1,
      PSPLIRQLPD(19) => ps_pl_irq_spi0,
      PSPLIRQLPD(18) => ps_pl_irq_i2c1,
      PSPLIRQLPD(17) => ps_pl_irq_i2c0,
      PSPLIRQLPD(16) => ps_pl_irq_gpio,
      PSPLIRQLPD(15) => ps_pl_irq_qspi,
      PSPLIRQLPD(14) => ps_pl_irq_nand,
      PSPLIRQLPD(13) => ps_pl_irq_r5_core1_ecc_error,
      PSPLIRQLPD(12) => ps_pl_irq_r5_core0_ecc_error,
      PSPLIRQLPD(11) => ps_pl_irq_lpd_apb_intr,
      PSPLIRQLPD(10) => ps_pl_irq_ocm_error,
      PSPLIRQLPD(9 downto 8) => ps_pl_irq_rpu_pm(1 downto 0),
      PSPLIRQLPD(7 downto 0) => NLW_PS8_i_PSPLIRQLPD_UNCONNECTED(7 downto 0),
      PSPLSTANDBYWFE(3 downto 0) => ps_pl_standbywfe(3 downto 0),
      PSPLSTANDBYWFI(3 downto 0) => ps_pl_standbywfi(3 downto 0),
      PSPLTRACECTL => NLW_PS8_i_PSPLTRACECTL_UNCONNECTED,
      PSPLTRACEDATA(31 downto 0) => NLW_PS8_i_PSPLTRACEDATA_UNCONNECTED(31 downto 0),
      PSPLTRIGACK(3) => ps_pl_trigack_3,
      PSPLTRIGACK(2) => ps_pl_trigack_2,
      PSPLTRIGACK(1) => ps_pl_trigack_1,
      PSPLTRIGACK(0) => ps_pl_trigack_0,
      PSPLTRIGGER(3) => ps_pl_trigger_3,
      PSPLTRIGGER(2) => ps_pl_trigger_2,
      PSPLTRIGGER(1) => ps_pl_trigger_1,
      PSPLTRIGGER(0) => ps_pl_trigger_0,
      PSS_ALTO_CORE_PAD_BOOTMODE(3 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_BOOTMODE_UNCONNECTED(3 downto 0),
      PSS_ALTO_CORE_PAD_CLK => NLW_PS8_i_PSS_ALTO_CORE_PAD_CLK_UNCONNECTED,
      PSS_ALTO_CORE_PAD_DONEB => NLW_PS8_i_PSS_ALTO_CORE_PAD_DONEB_UNCONNECTED,
      PSS_ALTO_CORE_PAD_DRAMA(17 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMA_UNCONNECTED(17 downto 0),
      PSS_ALTO_CORE_PAD_DRAMACTN => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMACTN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_DRAMALERTN => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMALERTN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_DRAMBA(1 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBA_UNCONNECTED(1 downto 0),
      PSS_ALTO_CORE_PAD_DRAMBG(1 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMBG_UNCONNECTED(1 downto 0),
      PSS_ALTO_CORE_PAD_DRAMCK(1 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCK_UNCONNECTED(1 downto 0),
      PSS_ALTO_CORE_PAD_DRAMCKE(1 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKE_UNCONNECTED(1 downto 0),
      PSS_ALTO_CORE_PAD_DRAMCKN(1 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCKN_UNCONNECTED(1 downto 0),
      PSS_ALTO_CORE_PAD_DRAMCSN(1 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMCSN_UNCONNECTED(1 downto 0),
      PSS_ALTO_CORE_PAD_DRAMDM(8 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDM_UNCONNECTED(8 downto 0),
      PSS_ALTO_CORE_PAD_DRAMDQ(71 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQ_UNCONNECTED(71 downto 0),
      PSS_ALTO_CORE_PAD_DRAMDQS(8 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQS_UNCONNECTED(8 downto 0),
      PSS_ALTO_CORE_PAD_DRAMDQSN(8 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMDQSN_UNCONNECTED(8 downto 0),
      PSS_ALTO_CORE_PAD_DRAMODT(1 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMODT_UNCONNECTED(1 downto 0),
      PSS_ALTO_CORE_PAD_DRAMPARITY => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMPARITY_UNCONNECTED,
      PSS_ALTO_CORE_PAD_DRAMRAMRSTN => NLW_PS8_i_PSS_ALTO_CORE_PAD_DRAMRAMRSTN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_ERROROUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_ERROROUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_ERRORSTATUS => NLW_PS8_i_PSS_ALTO_CORE_PAD_ERRORSTATUS_UNCONNECTED,
      PSS_ALTO_CORE_PAD_INITB => NLW_PS8_i_PSS_ALTO_CORE_PAD_INITB_UNCONNECTED,
      PSS_ALTO_CORE_PAD_JTAGTCK => NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTCK_UNCONNECTED,
      PSS_ALTO_CORE_PAD_JTAGTDI => NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDI_UNCONNECTED,
      PSS_ALTO_CORE_PAD_JTAGTDO => NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTDO_UNCONNECTED,
      PSS_ALTO_CORE_PAD_JTAGTMS => NLW_PS8_i_PSS_ALTO_CORE_PAD_JTAGTMS_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXN0IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN0IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXN1IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN1IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXN2IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN2IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXN3IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXN3IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXP0IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP0IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXP1IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP1IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXP2IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP2IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTRXP3IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTRXP3IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXN0OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN0OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXN1OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN1OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXN2OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN2OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXN3OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXN3OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXP0OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP0OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXP1OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP1OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXP2OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP2OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MGTTXP3OUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_MGTTXP3OUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_MIO(77 downto 0) => NLW_PS8_i_PSS_ALTO_CORE_PAD_MIO_UNCONNECTED(77 downto 0),
      PSS_ALTO_CORE_PAD_PADI => NLW_PS8_i_PSS_ALTO_CORE_PAD_PADI_UNCONNECTED,
      PSS_ALTO_CORE_PAD_PADO => NLW_PS8_i_PSS_ALTO_CORE_PAD_PADO_UNCONNECTED,
      PSS_ALTO_CORE_PAD_PORB => NLW_PS8_i_PSS_ALTO_CORE_PAD_PORB_UNCONNECTED,
      PSS_ALTO_CORE_PAD_PROGB => NLW_PS8_i_PSS_ALTO_CORE_PAD_PROGB_UNCONNECTED,
      PSS_ALTO_CORE_PAD_RCALIBINOUT => NLW_PS8_i_PSS_ALTO_CORE_PAD_RCALIBINOUT_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFN0IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN0IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFN1IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN1IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFN2IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN2IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFN3IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFN3IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFP0IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP0IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFP1IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP1IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFP2IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP2IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_REFP3IN => NLW_PS8_i_PSS_ALTO_CORE_PAD_REFP3IN_UNCONNECTED,
      PSS_ALTO_CORE_PAD_SRSTB => NLW_PS8_i_PSS_ALTO_CORE_PAD_SRSTB_UNCONNECTED,
      PSS_ALTO_CORE_PAD_ZQ => NLW_PS8_i_PSS_ALTO_CORE_PAD_ZQ_UNCONNECTED,
      RPUEVENTI0 => rpu_eventi0,
      RPUEVENTI1 => rpu_eventi1,
      RPUEVENTO0 => rpu_evento0,
      RPUEVENTO1 => rpu_evento1,
      SACEFPDACADDR(43 downto 0) => sacefpd_acaddr(43 downto 0),
      SACEFPDACPROT(2 downto 0) => sacefpd_acprot(2 downto 0),
      SACEFPDACREADY => sacefpd_acready,
      SACEFPDACSNOOP(3 downto 0) => sacefpd_acsnoop(3 downto 0),
      SACEFPDACVALID => sacefpd_acvalid,
      SACEFPDARADDR(43 downto 0) => sacefpd_araddr(43 downto 0),
      SACEFPDARBAR(1 downto 0) => sacefpd_arbar(1 downto 0),
      SACEFPDARBURST(1 downto 0) => sacefpd_arburst(1 downto 0),
      SACEFPDARCACHE(3 downto 0) => sacefpd_arcache(3 downto 0),
      SACEFPDARDOMAIN(1 downto 0) => sacefpd_ardomain(1 downto 0),
      SACEFPDARID(5 downto 0) => sacefpd_arid(5 downto 0),
      SACEFPDARLEN(7 downto 0) => sacefpd_arlen(7 downto 0),
      SACEFPDARLOCK => sacefpd_arlock,
      SACEFPDARPROT(2 downto 0) => sacefpd_arprot(2 downto 0),
      SACEFPDARQOS(3 downto 0) => sacefpd_arqos(3 downto 0),
      SACEFPDARREADY => sacefpd_arready,
      SACEFPDARREGION(3 downto 0) => sacefpd_arregion(3 downto 0),
      SACEFPDARSIZE(2 downto 0) => sacefpd_arsize(2 downto 0),
      SACEFPDARSNOOP(3 downto 0) => sacefpd_arsnoop(3 downto 0),
      SACEFPDARUSER(15 downto 6) => B"0000001111",
      SACEFPDARUSER(5 downto 0) => sacefpd_aruser(5 downto 0),
      SACEFPDARVALID => sacefpd_arvalid,
      SACEFPDAWADDR(43 downto 0) => sacefpd_awaddr(43 downto 0),
      SACEFPDAWBAR(1 downto 0) => sacefpd_awbar(1 downto 0),
      SACEFPDAWBURST(1 downto 0) => sacefpd_awburst(1 downto 0),
      SACEFPDAWCACHE(3 downto 0) => sacefpd_awcache(3 downto 0),
      SACEFPDAWDOMAIN(1 downto 0) => sacefpd_awdomain(1 downto 0),
      SACEFPDAWID(5 downto 0) => sacefpd_awid(5 downto 0),
      SACEFPDAWLEN(7 downto 0) => sacefpd_awlen(7 downto 0),
      SACEFPDAWLOCK => sacefpd_awlock,
      SACEFPDAWPROT(2 downto 0) => sacefpd_awprot(2 downto 0),
      SACEFPDAWQOS(3 downto 0) => sacefpd_awqos(3 downto 0),
      SACEFPDAWREADY => sacefpd_awready,
      SACEFPDAWREGION(3 downto 0) => sacefpd_awregion(3 downto 0),
      SACEFPDAWSIZE(2 downto 0) => sacefpd_awsize(2 downto 0),
      SACEFPDAWSNOOP(2 downto 0) => sacefpd_awsnoop(2 downto 0),
      SACEFPDAWUSER(15 downto 6) => B"0000001111",
      SACEFPDAWUSER(5 downto 0) => sacefpd_awuser(5 downto 0),
      SACEFPDAWVALID => sacefpd_awvalid,
      SACEFPDBID(5 downto 0) => sacefpd_bid(5 downto 0),
      SACEFPDBREADY => sacefpd_bready,
      SACEFPDBRESP(1 downto 0) => sacefpd_bresp(1 downto 0),
      SACEFPDBUSER => sacefpd_buser,
      SACEFPDBVALID => sacefpd_bvalid,
      SACEFPDCDDATA(127 downto 0) => sacefpd_cddata(127 downto 0),
      SACEFPDCDLAST => sacefpd_cdlast,
      SACEFPDCDREADY => sacefpd_cdready,
      SACEFPDCDVALID => sacefpd_cdvalid,
      SACEFPDCRREADY => sacefpd_crready,
      SACEFPDCRRESP(4 downto 0) => sacefpd_crresp(4 downto 0),
      SACEFPDCRVALID => sacefpd_crvalid,
      SACEFPDRACK => sacefpd_rack,
      SACEFPDRDATA(127 downto 0) => sacefpd_rdata(127 downto 0),
      SACEFPDRID(5 downto 0) => sacefpd_rid(5 downto 0),
      SACEFPDRLAST => sacefpd_rlast,
      SACEFPDRREADY => sacefpd_rready,
      SACEFPDRRESP(3 downto 0) => sacefpd_rresp(3 downto 0),
      SACEFPDRUSER => sacefpd_ruser,
      SACEFPDRVALID => sacefpd_rvalid,
      SACEFPDWACK => sacefpd_wack,
      SACEFPDWDATA(127 downto 0) => sacefpd_wdata(127 downto 0),
      SACEFPDWLAST => sacefpd_wlast,
      SACEFPDWREADY => sacefpd_wready,
      SACEFPDWSTRB(15 downto 0) => sacefpd_wstrb(15 downto 0),
      SACEFPDWUSER => sacefpd_wuser,
      SACEFPDWVALID => sacefpd_wvalid,
      SAXIACPACLK => saxiacp_fpd_aclk,
      SAXIACPARADDR(39 downto 0) => saxiacp_araddr(39 downto 0),
      SAXIACPARBURST(1 downto 0) => saxiacp_arburst(1 downto 0),
      SAXIACPARCACHE(3 downto 0) => saxiacp_arcache(3 downto 0),
      SAXIACPARID(4 downto 0) => saxiacp_arid(4 downto 0),
      SAXIACPARLEN(7 downto 0) => saxiacp_arlen(7 downto 0),
      SAXIACPARLOCK => saxiacp_arlock,
      SAXIACPARPROT(2 downto 0) => saxiacp_arprot(2 downto 0),
      SAXIACPARQOS(3 downto 0) => saxiacp_arqos(3 downto 0),
      SAXIACPARREADY => saxiacp_arready,
      SAXIACPARSIZE(2 downto 0) => saxiacp_arsize(2 downto 0),
      SAXIACPARUSER(1 downto 0) => saxiacp_aruser(1 downto 0),
      SAXIACPARVALID => saxiacp_arvalid,
      SAXIACPAWADDR(39 downto 0) => saxiacp_awaddr(39 downto 0),
      SAXIACPAWBURST(1 downto 0) => saxiacp_awburst(1 downto 0),
      SAXIACPAWCACHE(3 downto 0) => saxiacp_awcache(3 downto 0),
      SAXIACPAWID(4 downto 0) => saxiacp_awid(4 downto 0),
      SAXIACPAWLEN(7 downto 0) => saxiacp_awlen(7 downto 0),
      SAXIACPAWLOCK => saxiacp_awlock,
      SAXIACPAWPROT(2 downto 0) => saxiacp_awprot(2 downto 0),
      SAXIACPAWQOS(3 downto 0) => saxiacp_awqos(3 downto 0),
      SAXIACPAWREADY => saxiacp_awready,
      SAXIACPAWSIZE(2 downto 0) => saxiacp_awsize(2 downto 0),
      SAXIACPAWUSER(1 downto 0) => saxiacp_awuser(1 downto 0),
      SAXIACPAWVALID => saxiacp_awvalid,
      SAXIACPBID(4 downto 0) => saxiacp_bid(4 downto 0),
      SAXIACPBREADY => saxiacp_bready,
      SAXIACPBRESP(1 downto 0) => saxiacp_bresp(1 downto 0),
      SAXIACPBVALID => saxiacp_bvalid,
      SAXIACPRDATA(127 downto 0) => saxiacp_rdata(127 downto 0),
      SAXIACPRID(4 downto 0) => saxiacp_rid(4 downto 0),
      SAXIACPRLAST => saxiacp_rlast,
      SAXIACPRREADY => saxiacp_rready,
      SAXIACPRRESP(1 downto 0) => saxiacp_rresp(1 downto 0),
      SAXIACPRVALID => saxiacp_rvalid,
      SAXIACPWDATA(127 downto 0) => saxiacp_wdata(127 downto 0),
      SAXIACPWLAST => saxiacp_wlast,
      SAXIACPWREADY => saxiacp_wready,
      SAXIACPWSTRB(15 downto 0) => saxiacp_wstrb(15 downto 0),
      SAXIACPWVALID => saxiacp_wvalid,
      SAXIGP0ARADDR(48 downto 0) => saxigp0_araddr(48 downto 0),
      SAXIGP0ARBURST(1 downto 0) => saxigp0_arburst(1 downto 0),
      SAXIGP0ARCACHE(3 downto 0) => saxigp0_arcache(3 downto 0),
      SAXIGP0ARID(5 downto 0) => saxigp0_arid(5 downto 0),
      SAXIGP0ARLEN(7 downto 0) => saxigp0_arlen(7 downto 0),
      SAXIGP0ARLOCK => saxigp0_arlock,
      SAXIGP0ARPROT(2 downto 0) => saxigp0_arprot(2 downto 0),
      SAXIGP0ARQOS(3 downto 0) => saxigp0_arqos(3 downto 0),
      SAXIGP0ARREADY => saxigp0_arready,
      SAXIGP0ARSIZE(2 downto 0) => saxigp0_arsize(2 downto 0),
      SAXIGP0ARUSER => saxigp0_aruser,
      SAXIGP0ARVALID => saxigp0_arvalid,
      SAXIGP0AWADDR(48 downto 0) => saxigp0_awaddr(48 downto 0),
      SAXIGP0AWBURST(1 downto 0) => saxigp0_awburst(1 downto 0),
      SAXIGP0AWCACHE(3 downto 0) => saxigp0_awcache(3 downto 0),
      SAXIGP0AWID(5 downto 0) => saxigp0_awid(5 downto 0),
      SAXIGP0AWLEN(7 downto 0) => saxigp0_awlen(7 downto 0),
      SAXIGP0AWLOCK => saxigp0_awlock,
      SAXIGP0AWPROT(2 downto 0) => saxigp0_awprot(2 downto 0),
      SAXIGP0AWQOS(3 downto 0) => saxigp0_awqos(3 downto 0),
      SAXIGP0AWREADY => saxigp0_awready,
      SAXIGP0AWSIZE(2 downto 0) => saxigp0_awsize(2 downto 0),
      SAXIGP0AWUSER => saxigp0_awuser,
      SAXIGP0AWVALID => saxigp0_awvalid,
      SAXIGP0BID(5 downto 0) => saxigp0_bid(5 downto 0),
      SAXIGP0BREADY => saxigp0_bready,
      SAXIGP0BRESP(1 downto 0) => saxigp0_bresp(1 downto 0),
      SAXIGP0BVALID => saxigp0_bvalid,
      SAXIGP0RACOUNT(3 downto 0) => saxigp0_racount(3 downto 0),
      SAXIGP0RCLK => saxihpc0_fpd_aclk,
      SAXIGP0RCOUNT(7 downto 0) => saxigp0_rcount(7 downto 0),
      SAXIGP0RDATA(127 downto 64) => NLW_PS8_i_SAXIGP0RDATA_UNCONNECTED(127 downto 64),
      SAXIGP0RDATA(63 downto 0) => saxigp0_rdata(63 downto 0),
      SAXIGP0RID(5 downto 0) => saxigp0_rid(5 downto 0),
      SAXIGP0RLAST => saxigp0_rlast,
      SAXIGP0RREADY => saxigp0_rready,
      SAXIGP0RRESP(1 downto 0) => saxigp0_rresp(1 downto 0),
      SAXIGP0RVALID => saxigp0_rvalid,
      SAXIGP0WACOUNT(3 downto 0) => saxigp0_wacount(3 downto 0),
      SAXIGP0WCLK => saxihpc0_fpd_aclk,
      SAXIGP0WCOUNT(7 downto 0) => saxigp0_wcount(7 downto 0),
      SAXIGP0WDATA(127 downto 64) => B"0000000000000000000000000000000000000000000000000000000000000000",
      SAXIGP0WDATA(63 downto 0) => saxigp0_wdata(63 downto 0),
      SAXIGP0WLAST => saxigp0_wlast,
      SAXIGP0WREADY => saxigp0_wready,
      SAXIGP0WSTRB(15 downto 8) => B"00000000",
      SAXIGP0WSTRB(7 downto 0) => saxigp0_wstrb(7 downto 0),
      SAXIGP0WVALID => saxigp0_wvalid,
      SAXIGP1ARADDR(48 downto 0) => saxigp1_araddr(48 downto 0),
      SAXIGP1ARBURST(1 downto 0) => saxigp1_arburst(1 downto 0),
      SAXIGP1ARCACHE(3 downto 0) => saxigp1_arcache(3 downto 0),
      SAXIGP1ARID(5 downto 0) => saxigp1_arid(5 downto 0),
      SAXIGP1ARLEN(7 downto 0) => saxigp1_arlen(7 downto 0),
      SAXIGP1ARLOCK => saxigp1_arlock,
      SAXIGP1ARPROT(2 downto 0) => saxigp1_arprot(2 downto 0),
      SAXIGP1ARQOS(3 downto 0) => saxigp1_arqos(3 downto 0),
      SAXIGP1ARREADY => saxigp1_arready,
      SAXIGP1ARSIZE(2 downto 0) => saxigp1_arsize(2 downto 0),
      SAXIGP1ARUSER => saxigp1_aruser,
      SAXIGP1ARVALID => saxigp1_arvalid,
      SAXIGP1AWADDR(48 downto 0) => saxigp1_awaddr(48 downto 0),
      SAXIGP1AWBURST(1 downto 0) => saxigp1_awburst(1 downto 0),
      SAXIGP1AWCACHE(3 downto 0) => saxigp1_awcache(3 downto 0),
      SAXIGP1AWID(5 downto 0) => saxigp1_awid(5 downto 0),
      SAXIGP1AWLEN(7 downto 0) => saxigp1_awlen(7 downto 0),
      SAXIGP1AWLOCK => saxigp1_awlock,
      SAXIGP1AWPROT(2 downto 0) => saxigp1_awprot(2 downto 0),
      SAXIGP1AWQOS(3 downto 0) => saxigp1_awqos(3 downto 0),
      SAXIGP1AWREADY => saxigp1_awready,
      SAXIGP1AWSIZE(2 downto 0) => saxigp1_awsize(2 downto 0),
      SAXIGP1AWUSER => saxigp1_awuser,
      SAXIGP1AWVALID => saxigp1_awvalid,
      SAXIGP1BID(5 downto 0) => saxigp1_bid(5 downto 0),
      SAXIGP1BREADY => saxigp1_bready,
      SAXIGP1BRESP(1 downto 0) => saxigp1_bresp(1 downto 0),
      SAXIGP1BVALID => saxigp1_bvalid,
      SAXIGP1RACOUNT(3 downto 0) => saxigp1_racount(3 downto 0),
      SAXIGP1RCLK => saxihpc1_fpd_aclk,
      SAXIGP1RCOUNT(7 downto 0) => saxigp1_rcount(7 downto 0),
      SAXIGP1RDATA(127 downto 0) => saxigp1_rdata(127 downto 0),
      SAXIGP1RID(5 downto 0) => saxigp1_rid(5 downto 0),
      SAXIGP1RLAST => saxigp1_rlast,
      SAXIGP1RREADY => saxigp1_rready,
      SAXIGP1RRESP(1 downto 0) => saxigp1_rresp(1 downto 0),
      SAXIGP1RVALID => saxigp1_rvalid,
      SAXIGP1WACOUNT(3 downto 0) => saxigp1_wacount(3 downto 0),
      SAXIGP1WCLK => saxihpc1_fpd_aclk,
      SAXIGP1WCOUNT(7 downto 0) => saxigp1_wcount(7 downto 0),
      SAXIGP1WDATA(127 downto 0) => saxigp1_wdata(127 downto 0),
      SAXIGP1WLAST => saxigp1_wlast,
      SAXIGP1WREADY => saxigp1_wready,
      SAXIGP1WSTRB(15 downto 0) => saxigp1_wstrb(15 downto 0),
      SAXIGP1WVALID => saxigp1_wvalid,
      SAXIGP2ARADDR(48 downto 0) => saxigp2_araddr(48 downto 0),
      SAXIGP2ARBURST(1 downto 0) => saxigp2_arburst(1 downto 0),
      SAXIGP2ARCACHE(3 downto 0) => saxigp2_arcache(3 downto 0),
      SAXIGP2ARID(5 downto 0) => saxigp2_arid(5 downto 0),
      SAXIGP2ARLEN(7 downto 0) => saxigp2_arlen(7 downto 0),
      SAXIGP2ARLOCK => saxigp2_arlock,
      SAXIGP2ARPROT(2 downto 0) => saxigp2_arprot(2 downto 0),
      SAXIGP2ARQOS(3 downto 0) => saxigp2_arqos(3 downto 0),
      SAXIGP2ARREADY => saxigp2_arready,
      SAXIGP2ARSIZE(2 downto 0) => saxigp2_arsize(2 downto 0),
      SAXIGP2ARUSER => saxigp2_aruser,
      SAXIGP2ARVALID => saxigp2_arvalid,
      SAXIGP2AWADDR(48 downto 0) => saxigp2_awaddr(48 downto 0),
      SAXIGP2AWBURST(1 downto 0) => saxigp2_awburst(1 downto 0),
      SAXIGP2AWCACHE(3 downto 0) => saxigp2_awcache(3 downto 0),
      SAXIGP2AWID(5 downto 0) => saxigp2_awid(5 downto 0),
      SAXIGP2AWLEN(7 downto 0) => saxigp2_awlen(7 downto 0),
      SAXIGP2AWLOCK => saxigp2_awlock,
      SAXIGP2AWPROT(2 downto 0) => saxigp2_awprot(2 downto 0),
      SAXIGP2AWQOS(3 downto 0) => saxigp2_awqos(3 downto 0),
      SAXIGP2AWREADY => saxigp2_awready,
      SAXIGP2AWSIZE(2 downto 0) => saxigp2_awsize(2 downto 0),
      SAXIGP2AWUSER => saxigp2_awuser,
      SAXIGP2AWVALID => saxigp2_awvalid,
      SAXIGP2BID(5 downto 0) => saxigp2_bid(5 downto 0),
      SAXIGP2BREADY => saxigp2_bready,
      SAXIGP2BRESP(1 downto 0) => saxigp2_bresp(1 downto 0),
      SAXIGP2BVALID => saxigp2_bvalid,
      SAXIGP2RACOUNT(3 downto 0) => saxigp2_racount(3 downto 0),
      SAXIGP2RCLK => saxihp0_fpd_aclk,
      SAXIGP2RCOUNT(7 downto 0) => saxigp2_rcount(7 downto 0),
      SAXIGP2RDATA(127 downto 0) => saxigp2_rdata(127 downto 0),
      SAXIGP2RID(5 downto 0) => saxigp2_rid(5 downto 0),
      SAXIGP2RLAST => saxigp2_rlast,
      SAXIGP2RREADY => saxigp2_rready,
      SAXIGP2RRESP(1 downto 0) => saxigp2_rresp(1 downto 0),
      SAXIGP2RVALID => saxigp2_rvalid,
      SAXIGP2WACOUNT(3 downto 0) => saxigp2_wacount(3 downto 0),
      SAXIGP2WCLK => saxihp0_fpd_aclk,
      SAXIGP2WCOUNT(7 downto 0) => saxigp2_wcount(7 downto 0),
      SAXIGP2WDATA(127 downto 0) => saxigp2_wdata(127 downto 0),
      SAXIGP2WLAST => saxigp2_wlast,
      SAXIGP2WREADY => saxigp2_wready,
      SAXIGP2WSTRB(15 downto 0) => saxigp2_wstrb(15 downto 0),
      SAXIGP2WVALID => saxigp2_wvalid,
      SAXIGP3ARADDR(48 downto 0) => saxigp3_araddr(48 downto 0),
      SAXIGP3ARBURST(1 downto 0) => saxigp3_arburst(1 downto 0),
      SAXIGP3ARCACHE(3 downto 0) => saxigp3_arcache(3 downto 0),
      SAXIGP3ARID(5 downto 0) => saxigp3_arid(5 downto 0),
      SAXIGP3ARLEN(7 downto 0) => saxigp3_arlen(7 downto 0),
      SAXIGP3ARLOCK => saxigp3_arlock,
      SAXIGP3ARPROT(2 downto 0) => saxigp3_arprot(2 downto 0),
      SAXIGP3ARQOS(3 downto 0) => saxigp3_arqos(3 downto 0),
      SAXIGP3ARREADY => saxigp3_arready,
      SAXIGP3ARSIZE(2 downto 0) => saxigp3_arsize(2 downto 0),
      SAXIGP3ARUSER => saxigp3_aruser,
      SAXIGP3ARVALID => saxigp3_arvalid,
      SAXIGP3AWADDR(48 downto 0) => saxigp3_awaddr(48 downto 0),
      SAXIGP3AWBURST(1 downto 0) => saxigp3_awburst(1 downto 0),
      SAXIGP3AWCACHE(3 downto 0) => saxigp3_awcache(3 downto 0),
      SAXIGP3AWID(5 downto 0) => saxigp3_awid(5 downto 0),
      SAXIGP3AWLEN(7 downto 0) => saxigp3_awlen(7 downto 0),
      SAXIGP3AWLOCK => saxigp3_awlock,
      SAXIGP3AWPROT(2 downto 0) => saxigp3_awprot(2 downto 0),
      SAXIGP3AWQOS(3 downto 0) => saxigp3_awqos(3 downto 0),
      SAXIGP3AWREADY => saxigp3_awready,
      SAXIGP3AWSIZE(2 downto 0) => saxigp3_awsize(2 downto 0),
      SAXIGP3AWUSER => saxigp3_awuser,
      SAXIGP3AWVALID => saxigp3_awvalid,
      SAXIGP3BID(5 downto 0) => saxigp3_bid(5 downto 0),
      SAXIGP3BREADY => saxigp3_bready,
      SAXIGP3BRESP(1 downto 0) => saxigp3_bresp(1 downto 0),
      SAXIGP3BVALID => saxigp3_bvalid,
      SAXIGP3RACOUNT(3 downto 0) => saxigp3_racount(3 downto 0),
      SAXIGP3RCLK => saxihp1_fpd_aclk,
      SAXIGP3RCOUNT(7 downto 0) => saxigp3_rcount(7 downto 0),
      SAXIGP3RDATA(127 downto 0) => saxigp3_rdata(127 downto 0),
      SAXIGP3RID(5 downto 0) => saxigp3_rid(5 downto 0),
      SAXIGP3RLAST => saxigp3_rlast,
      SAXIGP3RREADY => saxigp3_rready,
      SAXIGP3RRESP(1 downto 0) => saxigp3_rresp(1 downto 0),
      SAXIGP3RVALID => saxigp3_rvalid,
      SAXIGP3WACOUNT(3 downto 0) => saxigp3_wacount(3 downto 0),
      SAXIGP3WCLK => saxihp1_fpd_aclk,
      SAXIGP3WCOUNT(7 downto 0) => saxigp3_wcount(7 downto 0),
      SAXIGP3WDATA(127 downto 0) => saxigp3_wdata(127 downto 0),
      SAXIGP3WLAST => saxigp3_wlast,
      SAXIGP3WREADY => saxigp3_wready,
      SAXIGP3WSTRB(15 downto 0) => saxigp3_wstrb(15 downto 0),
      SAXIGP3WVALID => saxigp3_wvalid,
      SAXIGP4ARADDR(48 downto 0) => saxigp4_araddr(48 downto 0),
      SAXIGP4ARBURST(1 downto 0) => saxigp4_arburst(1 downto 0),
      SAXIGP4ARCACHE(3 downto 0) => saxigp4_arcache(3 downto 0),
      SAXIGP4ARID(5 downto 0) => saxigp4_arid(5 downto 0),
      SAXIGP4ARLEN(7 downto 0) => saxigp4_arlen(7 downto 0),
      SAXIGP4ARLOCK => saxigp4_arlock,
      SAXIGP4ARPROT(2 downto 0) => saxigp4_arprot(2 downto 0),
      SAXIGP4ARQOS(3 downto 0) => saxigp4_arqos(3 downto 0),
      SAXIGP4ARREADY => saxigp4_arready,
      SAXIGP4ARSIZE(2 downto 0) => saxigp4_arsize(2 downto 0),
      SAXIGP4ARUSER => saxigp4_aruser,
      SAXIGP4ARVALID => saxigp4_arvalid,
      SAXIGP4AWADDR(48 downto 0) => saxigp4_awaddr(48 downto 0),
      SAXIGP4AWBURST(1 downto 0) => saxigp4_awburst(1 downto 0),
      SAXIGP4AWCACHE(3 downto 0) => saxigp4_awcache(3 downto 0),
      SAXIGP4AWID(5 downto 0) => saxigp4_awid(5 downto 0),
      SAXIGP4AWLEN(7 downto 0) => saxigp4_awlen(7 downto 0),
      SAXIGP4AWLOCK => saxigp4_awlock,
      SAXIGP4AWPROT(2 downto 0) => saxigp4_awprot(2 downto 0),
      SAXIGP4AWQOS(3 downto 0) => saxigp4_awqos(3 downto 0),
      SAXIGP4AWREADY => saxigp4_awready,
      SAXIGP4AWSIZE(2 downto 0) => saxigp4_awsize(2 downto 0),
      SAXIGP4AWUSER => saxigp4_awuser,
      SAXIGP4AWVALID => saxigp4_awvalid,
      SAXIGP4BID(5 downto 0) => saxigp4_bid(5 downto 0),
      SAXIGP4BREADY => saxigp4_bready,
      SAXIGP4BRESP(1 downto 0) => saxigp4_bresp(1 downto 0),
      SAXIGP4BVALID => saxigp4_bvalid,
      SAXIGP4RACOUNT(3 downto 0) => saxigp4_racount(3 downto 0),
      SAXIGP4RCLK => saxihp2_fpd_aclk,
      SAXIGP4RCOUNT(7 downto 0) => saxigp4_rcount(7 downto 0),
      SAXIGP4RDATA(127 downto 0) => saxigp4_rdata(127 downto 0),
      SAXIGP4RID(5 downto 0) => saxigp4_rid(5 downto 0),
      SAXIGP4RLAST => saxigp4_rlast,
      SAXIGP4RREADY => saxigp4_rready,
      SAXIGP4RRESP(1 downto 0) => saxigp4_rresp(1 downto 0),
      SAXIGP4RVALID => saxigp4_rvalid,
      SAXIGP4WACOUNT(3 downto 0) => saxigp4_wacount(3 downto 0),
      SAXIGP4WCLK => saxihp2_fpd_aclk,
      SAXIGP4WCOUNT(7 downto 0) => saxigp4_wcount(7 downto 0),
      SAXIGP4WDATA(127 downto 0) => saxigp4_wdata(127 downto 0),
      SAXIGP4WLAST => saxigp4_wlast,
      SAXIGP4WREADY => saxigp4_wready,
      SAXIGP4WSTRB(15 downto 0) => saxigp4_wstrb(15 downto 0),
      SAXIGP4WVALID => saxigp4_wvalid,
      SAXIGP5ARADDR(48 downto 0) => saxigp5_araddr(48 downto 0),
      SAXIGP5ARBURST(1 downto 0) => saxigp5_arburst(1 downto 0),
      SAXIGP5ARCACHE(3 downto 0) => saxigp5_arcache(3 downto 0),
      SAXIGP5ARID(5 downto 0) => saxigp5_arid(5 downto 0),
      SAXIGP5ARLEN(7 downto 0) => saxigp5_arlen(7 downto 0),
      SAXIGP5ARLOCK => saxigp5_arlock,
      SAXIGP5ARPROT(2 downto 0) => saxigp5_arprot(2 downto 0),
      SAXIGP5ARQOS(3 downto 0) => saxigp5_arqos(3 downto 0),
      SAXIGP5ARREADY => saxigp5_arready,
      SAXIGP5ARSIZE(2 downto 0) => saxigp5_arsize(2 downto 0),
      SAXIGP5ARUSER => saxigp5_aruser,
      SAXIGP5ARVALID => saxigp5_arvalid,
      SAXIGP5AWADDR(48 downto 0) => saxigp5_awaddr(48 downto 0),
      SAXIGP5AWBURST(1 downto 0) => saxigp5_awburst(1 downto 0),
      SAXIGP5AWCACHE(3 downto 0) => saxigp5_awcache(3 downto 0),
      SAXIGP5AWID(5 downto 0) => saxigp5_awid(5 downto 0),
      SAXIGP5AWLEN(7 downto 0) => saxigp5_awlen(7 downto 0),
      SAXIGP5AWLOCK => saxigp5_awlock,
      SAXIGP5AWPROT(2 downto 0) => saxigp5_awprot(2 downto 0),
      SAXIGP5AWQOS(3 downto 0) => saxigp5_awqos(3 downto 0),
      SAXIGP5AWREADY => saxigp5_awready,
      SAXIGP5AWSIZE(2 downto 0) => saxigp5_awsize(2 downto 0),
      SAXIGP5AWUSER => saxigp5_awuser,
      SAXIGP5AWVALID => saxigp5_awvalid,
      SAXIGP5BID(5 downto 0) => saxigp5_bid(5 downto 0),
      SAXIGP5BREADY => saxigp5_bready,
      SAXIGP5BRESP(1 downto 0) => saxigp5_bresp(1 downto 0),
      SAXIGP5BVALID => saxigp5_bvalid,
      SAXIGP5RACOUNT(3 downto 0) => saxigp5_racount(3 downto 0),
      SAXIGP5RCLK => saxihp3_fpd_aclk,
      SAXIGP5RCOUNT(7 downto 0) => saxigp5_rcount(7 downto 0),
      SAXIGP5RDATA(127 downto 0) => saxigp5_rdata(127 downto 0),
      SAXIGP5RID(5 downto 0) => saxigp5_rid(5 downto 0),
      SAXIGP5RLAST => saxigp5_rlast,
      SAXIGP5RREADY => saxigp5_rready,
      SAXIGP5RRESP(1 downto 0) => saxigp5_rresp(1 downto 0),
      SAXIGP5RVALID => saxigp5_rvalid,
      SAXIGP5WACOUNT(3 downto 0) => saxigp5_wacount(3 downto 0),
      SAXIGP5WCLK => saxihp3_fpd_aclk,
      SAXIGP5WCOUNT(7 downto 0) => saxigp5_wcount(7 downto 0),
      SAXIGP5WDATA(127 downto 0) => saxigp5_wdata(127 downto 0),
      SAXIGP5WLAST => saxigp5_wlast,
      SAXIGP5WREADY => saxigp5_wready,
      SAXIGP5WSTRB(15 downto 0) => saxigp5_wstrb(15 downto 0),
      SAXIGP5WVALID => saxigp5_wvalid,
      SAXIGP6ARADDR(48 downto 0) => saxigp6_araddr(48 downto 0),
      SAXIGP6ARBURST(1 downto 0) => saxigp6_arburst(1 downto 0),
      SAXIGP6ARCACHE(3 downto 0) => saxigp6_arcache(3 downto 0),
      SAXIGP6ARID(5 downto 0) => saxigp6_arid(5 downto 0),
      SAXIGP6ARLEN(7 downto 0) => saxigp6_arlen(7 downto 0),
      SAXIGP6ARLOCK => saxigp6_arlock,
      SAXIGP6ARPROT(2 downto 0) => saxigp6_arprot(2 downto 0),
      SAXIGP6ARQOS(3 downto 0) => saxigp6_arqos(3 downto 0),
      SAXIGP6ARREADY => saxigp6_arready,
      SAXIGP6ARSIZE(2 downto 0) => saxigp6_arsize(2 downto 0),
      SAXIGP6ARUSER => saxigp6_aruser,
      SAXIGP6ARVALID => saxigp6_arvalid,
      SAXIGP6AWADDR(48 downto 0) => saxigp6_awaddr(48 downto 0),
      SAXIGP6AWBURST(1 downto 0) => saxigp6_awburst(1 downto 0),
      SAXIGP6AWCACHE(3 downto 0) => saxigp6_awcache(3 downto 0),
      SAXIGP6AWID(5 downto 0) => saxigp6_awid(5 downto 0),
      SAXIGP6AWLEN(7 downto 0) => saxigp6_awlen(7 downto 0),
      SAXIGP6AWLOCK => saxigp6_awlock,
      SAXIGP6AWPROT(2 downto 0) => saxigp6_awprot(2 downto 0),
      SAXIGP6AWQOS(3 downto 0) => saxigp6_awqos(3 downto 0),
      SAXIGP6AWREADY => saxigp6_awready,
      SAXIGP6AWSIZE(2 downto 0) => saxigp6_awsize(2 downto 0),
      SAXIGP6AWUSER => saxigp6_awuser,
      SAXIGP6AWVALID => saxigp6_awvalid,
      SAXIGP6BID(5 downto 0) => saxigp6_bid(5 downto 0),
      SAXIGP6BREADY => saxigp6_bready,
      SAXIGP6BRESP(1 downto 0) => saxigp6_bresp(1 downto 0),
      SAXIGP6BVALID => saxigp6_bvalid,
      SAXIGP6RACOUNT(3 downto 0) => saxigp6_racount(3 downto 0),
      SAXIGP6RCLK => saxi_lpd_aclk,
      SAXIGP6RCOUNT(7 downto 0) => saxigp6_rcount(7 downto 0),
      SAXIGP6RDATA(127 downto 0) => saxigp6_rdata(127 downto 0),
      SAXIGP6RID(5 downto 0) => saxigp6_rid(5 downto 0),
      SAXIGP6RLAST => saxigp6_rlast,
      SAXIGP6RREADY => saxigp6_rready,
      SAXIGP6RRESP(1 downto 0) => saxigp6_rresp(1 downto 0),
      SAXIGP6RVALID => saxigp6_rvalid,
      SAXIGP6WACOUNT(3 downto 0) => saxigp6_wacount(3 downto 0),
      SAXIGP6WCLK => saxi_lpd_aclk,
      SAXIGP6WCOUNT(7 downto 0) => saxigp6_wcount(7 downto 0),
      SAXIGP6WDATA(127 downto 0) => saxigp6_wdata(127 downto 0),
      SAXIGP6WLAST => saxigp6_wlast,
      SAXIGP6WREADY => saxigp6_wready,
      SAXIGP6WSTRB(15 downto 0) => saxigp6_wstrb(15 downto 0),
      SAXIGP6WVALID => saxigp6_wvalid,
      STMEVENT(59 downto 0) => stm_event(59 downto 0)
    );
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
\buffer_pl_clk_0.PL_CLK_0_BUFG\: unisim.vcomponents.BUFG_PS
    generic map(
      SIM_DEVICE => "ULTRASCALE_PLUS",
      STARTUP_SYNC => "FALSE"
    )
        port map (
      I => pl_clk_unbuffered(0),
      O => pl_clk0
    );
emio_enet0_mdio_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_enet0_mdio_t_n\,
      O => emio_enet0_mdio_t
    );
emio_enet1_mdio_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_enet1_mdio_t_n\,
      O => emio_enet1_mdio_t
    );
emio_enet2_mdio_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_enet2_mdio_t_n\,
      O => emio_enet2_mdio_t
    );
emio_enet3_mdio_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_enet3_mdio_t_n\,
      O => emio_enet3_mdio_t
    );
\emio_gpio_t[0]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_gpio_t_n\(0),
      O => emio_gpio_t(0)
    );
emio_i2c0_scl_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_i2c0_scl_t_n\,
      O => emio_i2c0_scl_t
    );
emio_i2c0_sda_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_i2c0_sda_t_n\,
      O => emio_i2c0_sda_t
    );
emio_i2c1_scl_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_i2c1_scl_t_n\,
      O => emio_i2c1_scl_t
    );
emio_i2c1_sda_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_i2c1_sda_t_n\,
      O => emio_i2c1_sda_t
    );
emio_sdio0_cmdena_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_cmdena_i,
      O => emio_sdio0_cmdena
    );
\emio_sdio0_dataena[0]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(0),
      O => emio_sdio0_dataena(0)
    );
\emio_sdio0_dataena[1]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(1),
      O => emio_sdio0_dataena(1)
    );
\emio_sdio0_dataena[2]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(2),
      O => emio_sdio0_dataena(2)
    );
\emio_sdio0_dataena[3]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(3),
      O => emio_sdio0_dataena(3)
    );
\emio_sdio0_dataena[4]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(4),
      O => emio_sdio0_dataena(4)
    );
\emio_sdio0_dataena[5]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(5),
      O => emio_sdio0_dataena(5)
    );
\emio_sdio0_dataena[6]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(6),
      O => emio_sdio0_dataena(6)
    );
\emio_sdio0_dataena[7]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio0_dataena_i(7),
      O => emio_sdio0_dataena(7)
    );
emio_sdio1_cmdena_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_cmdena_i,
      O => emio_sdio1_cmdena
    );
\emio_sdio1_dataena[0]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(0),
      O => emio_sdio1_dataena(0)
    );
\emio_sdio1_dataena[1]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(1),
      O => emio_sdio1_dataena(1)
    );
\emio_sdio1_dataena[2]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(2),
      O => emio_sdio1_dataena(2)
    );
\emio_sdio1_dataena[3]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(3),
      O => emio_sdio1_dataena(3)
    );
\emio_sdio1_dataena[4]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(4),
      O => emio_sdio1_dataena(4)
    );
\emio_sdio1_dataena[5]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(5),
      O => emio_sdio1_dataena(5)
    );
\emio_sdio1_dataena[6]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(6),
      O => emio_sdio1_dataena(6)
    );
\emio_sdio1_dataena[7]_INST_0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => emio_sdio1_dataena_i(7),
      O => emio_sdio1_dataena(7)
    );
emio_spi0_mo_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi0_mo_t_n\,
      O => emio_spi0_mo_t
    );
emio_spi0_sclk_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi0_sclk_t_n\,
      O => emio_spi0_sclk_t
    );
emio_spi0_so_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi0_so_t_n\,
      O => emio_spi0_so_t
    );
emio_spi0_ss_n_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi0_ss_n_t_n\,
      O => emio_spi0_ss_n_t
    );
emio_spi1_mo_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi1_mo_t_n\,
      O => emio_spi1_mo_t
    );
emio_spi1_sclk_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi1_sclk_t_n\,
      O => emio_spi1_sclk_t
    );
emio_spi1_so_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi1_so_t_n\,
      O => emio_spi1_so_t
    );
emio_spi1_ss_n_t_INST_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^emio_spi1_ss_n_t_n\,
      O => emio_spi1_ss_n_t
    );
i_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[0]\
    );
i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(31)
    );
i_10: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(22)
    );
i_100: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(3)
    );
i_101: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(2)
    );
i_102: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(1)
    );
i_103: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(0)
    );
i_104: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(31)
    );
i_105: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(30)
    );
i_106: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(29)
    );
i_107: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(28)
    );
i_108: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(27)
    );
i_109: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(26)
    );
i_11: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(21)
    );
i_110: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(25)
    );
i_111: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(24)
    );
i_112: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(23)
    );
i_113: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(22)
    );
i_114: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(21)
    );
i_115: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(20)
    );
i_116: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(19)
    );
i_117: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(18)
    );
i_118: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(17)
    );
i_119: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(16)
    );
i_12: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(20)
    );
i_120: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(15)
    );
i_121: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(14)
    );
i_122: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(13)
    );
i_123: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(12)
    );
i_124: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(11)
    );
i_125: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(10)
    );
i_126: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(9)
    );
i_127: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(8)
    );
i_128: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(7)
    );
i_129: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(6)
    );
i_13: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(19)
    );
i_130: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(5)
    );
i_131: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(4)
    );
i_132: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(3)
    );
i_133: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(2)
    );
i_134: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(1)
    );
i_135: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[5]\(0)
    );
i_136: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(31)
    );
i_137: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(30)
    );
i_138: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(29)
    );
i_139: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(28)
    );
i_14: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(18)
    );
i_140: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(27)
    );
i_141: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(26)
    );
i_142: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(25)
    );
i_143: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(24)
    );
i_144: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(23)
    );
i_145: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(22)
    );
i_146: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(21)
    );
i_147: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(20)
    );
i_148: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(19)
    );
i_149: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(18)
    );
i_15: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(17)
    );
i_150: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(17)
    );
i_151: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(16)
    );
i_152: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(15)
    );
i_153: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(14)
    );
i_154: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(13)
    );
i_155: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(12)
    );
i_156: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(11)
    );
i_157: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(10)
    );
i_158: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(9)
    );
i_159: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(8)
    );
i_16: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(16)
    );
i_160: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(7)
    );
i_161: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(6)
    );
i_162: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(5)
    );
i_163: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(4)
    );
i_164: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(3)
    );
i_165: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(2)
    );
i_166: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(1)
    );
i_167: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[4]\(0)
    );
i_168: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(31)
    );
i_169: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(30)
    );
i_17: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(15)
    );
i_170: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(29)
    );
i_171: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(28)
    );
i_172: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(27)
    );
i_173: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(26)
    );
i_174: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(25)
    );
i_175: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(24)
    );
i_176: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(23)
    );
i_177: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(22)
    );
i_178: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(21)
    );
i_179: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(20)
    );
i_18: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(14)
    );
i_180: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(19)
    );
i_181: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(18)
    );
i_182: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(17)
    );
i_183: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(16)
    );
i_184: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(15)
    );
i_185: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(14)
    );
i_186: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(13)
    );
i_187: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(12)
    );
i_188: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(11)
    );
i_189: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(10)
    );
i_19: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(13)
    );
i_190: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(9)
    );
i_191: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(8)
    );
i_192: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(7)
    );
i_193: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(6)
    );
i_194: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(5)
    );
i_195: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(4)
    );
i_196: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(3)
    );
i_197: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(2)
    );
i_198: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(1)
    );
i_199: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[3]\(0)
    );
i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(30)
    );
i_20: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(12)
    );
i_200: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(31)
    );
i_201: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(30)
    );
i_202: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(29)
    );
i_203: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(28)
    );
i_204: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(27)
    );
i_205: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(26)
    );
i_206: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(25)
    );
i_207: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(24)
    );
i_208: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(23)
    );
i_209: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(22)
    );
i_21: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(11)
    );
i_210: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(21)
    );
i_211: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(20)
    );
i_212: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(19)
    );
i_213: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(18)
    );
i_214: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(17)
    );
i_215: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(16)
    );
i_216: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(15)
    );
i_217: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(14)
    );
i_218: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(13)
    );
i_219: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(12)
    );
i_22: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(10)
    );
i_220: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(11)
    );
i_221: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(10)
    );
i_222: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(9)
    );
i_223: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(8)
    );
i_224: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(7)
    );
i_225: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(6)
    );
i_226: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(5)
    );
i_227: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(4)
    );
i_228: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(3)
    );
i_229: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(2)
    );
i_23: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(9)
    );
i_230: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(1)
    );
i_231: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[2]\(0)
    );
i_232: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(31)
    );
i_233: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(30)
    );
i_234: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(29)
    );
i_235: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(28)
    );
i_236: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(27)
    );
i_237: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(26)
    );
i_238: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(25)
    );
i_239: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(24)
    );
i_24: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(8)
    );
i_240: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(23)
    );
i_241: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(22)
    );
i_242: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(21)
    );
i_243: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(20)
    );
i_244: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(19)
    );
i_245: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(18)
    );
i_246: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(17)
    );
i_247: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(16)
    );
i_248: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(15)
    );
i_249: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(14)
    );
i_25: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(7)
    );
i_250: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(13)
    );
i_251: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(12)
    );
i_252: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(11)
    );
i_253: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(10)
    );
i_254: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(9)
    );
i_255: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(8)
    );
i_256: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(7)
    );
i_257: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(6)
    );
i_258: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(5)
    );
i_259: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(4)
    );
i_26: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(6)
    );
i_260: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(3)
    );
i_261: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(2)
    );
i_262: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(1)
    );
i_263: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[1]\(0)
    );
i_27: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(5)
    );
i_28: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(4)
    );
i_29: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(3)
    );
i_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(29)
    );
i_30: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(2)
    );
i_31: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(1)
    );
i_32: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(0)
    );
i_33: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[7]\
    );
i_34: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[6]\
    );
i_35: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[5]\
    );
i_36: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[4]\
    );
i_37: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[3]\
    );
i_38: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[2]\
    );
i_39: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_ctl_pipe[1]\
    );
i_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(28)
    );
i_40: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(31)
    );
i_41: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(30)
    );
i_42: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(29)
    );
i_43: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(28)
    );
i_44: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(27)
    );
i_45: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(26)
    );
i_46: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(25)
    );
i_47: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(24)
    );
i_48: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(23)
    );
i_49: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(22)
    );
i_5: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(27)
    );
i_50: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(21)
    );
i_51: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(20)
    );
i_52: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(19)
    );
i_53: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(18)
    );
i_54: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(17)
    );
i_55: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(16)
    );
i_56: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(15)
    );
i_57: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(14)
    );
i_58: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(13)
    );
i_59: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(12)
    );
i_6: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(26)
    );
i_60: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(11)
    );
i_61: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(10)
    );
i_62: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(9)
    );
i_63: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(8)
    );
i_64: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(7)
    );
i_65: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(6)
    );
i_66: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(5)
    );
i_67: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(4)
    );
i_68: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(3)
    );
i_69: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(2)
    );
i_7: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(25)
    );
i_70: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(1)
    );
i_71: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[7]\(0)
    );
i_72: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(31)
    );
i_73: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(30)
    );
i_74: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(29)
    );
i_75: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(28)
    );
i_76: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(27)
    );
i_77: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(26)
    );
i_78: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(25)
    );
i_79: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(24)
    );
i_8: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(24)
    );
i_80: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(23)
    );
i_81: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(22)
    );
i_82: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(21)
    );
i_83: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(20)
    );
i_84: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(19)
    );
i_85: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(18)
    );
i_86: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(17)
    );
i_87: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(16)
    );
i_88: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(15)
    );
i_89: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(14)
    );
i_9: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[0]\(23)
    );
i_90: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(13)
    );
i_91: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(12)
    );
i_92: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(11)
    );
i_93: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(10)
    );
i_94: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(9)
    );
i_95: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(8)
    );
i_96: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(7)
    );
i_97: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(6)
    );
i_98: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(5)
    );
i_99: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \trace_data_pipe[6]\(4)
    );
trace_clk_out_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^trace_clk_out\,
      O => p_0_in
    );
trace_clk_out_reg: unisim.vcomponents.FDRE
     port map (
      C => pl_ps_trace_clk,
      CE => '1',
      D => p_0_in,
      Q => \^trace_clk_out\,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity zynqmpsoc_zynq_ultra_ps_e_0_0 is
  port (
    maxihpm0_fpd_aclk : in STD_LOGIC;
    maxigp0_awid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp0_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp0_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_awlock : out STD_LOGIC;
    maxigp0_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_awvalid : out STD_LOGIC;
    maxigp0_awuser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_awready : in STD_LOGIC;
    maxigp0_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp0_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_wlast : out STD_LOGIC;
    maxigp0_wvalid : out STD_LOGIC;
    maxigp0_wready : in STD_LOGIC;
    maxigp0_bid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_bvalid : in STD_LOGIC;
    maxigp0_bready : out STD_LOGIC;
    maxigp0_arid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp0_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp0_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_arlock : out STD_LOGIC;
    maxigp0_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp0_arvalid : out STD_LOGIC;
    maxigp0_aruser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_arready : in STD_LOGIC;
    maxigp0_rid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp0_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp0_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp0_rlast : in STD_LOGIC;
    maxigp0_rvalid : in STD_LOGIC;
    maxigp0_rready : out STD_LOGIC;
    maxigp0_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp0_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxihpm1_fpd_aclk : in STD_LOGIC;
    maxigp1_awid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_awaddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp1_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp1_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_awlock : out STD_LOGIC;
    maxigp1_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_awvalid : out STD_LOGIC;
    maxigp1_awuser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_awready : in STD_LOGIC;
    maxigp1_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp1_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_wlast : out STD_LOGIC;
    maxigp1_wvalid : out STD_LOGIC;
    maxigp1_wready : in STD_LOGIC;
    maxigp1_bid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_bvalid : in STD_LOGIC;
    maxigp1_bready : out STD_LOGIC;
    maxigp1_arid : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_araddr : out STD_LOGIC_VECTOR ( 39 downto 0 );
    maxigp1_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    maxigp1_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_arlock : out STD_LOGIC;
    maxigp1_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    maxigp1_arvalid : out STD_LOGIC;
    maxigp1_aruser : out STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_arready : in STD_LOGIC;
    maxigp1_rid : in STD_LOGIC_VECTOR ( 15 downto 0 );
    maxigp1_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    maxigp1_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    maxigp1_rlast : in STD_LOGIC;
    maxigp1_rvalid : in STD_LOGIC;
    maxigp1_rready : out STD_LOGIC;
    maxigp1_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    maxigp1_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    saxihpc0_fpd_aclk : in STD_LOGIC;
    saxigp0_aruser : in STD_LOGIC;
    saxigp0_awuser : in STD_LOGIC;
    saxigp0_awid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_awaddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp0_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_awlock : in STD_LOGIC;
    saxigp0_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_awvalid : in STD_LOGIC;
    saxigp0_awready : out STD_LOGIC;
    saxigp0_wdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    saxigp0_wstrb : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_wlast : in STD_LOGIC;
    saxigp0_wvalid : in STD_LOGIC;
    saxigp0_wready : out STD_LOGIC;
    saxigp0_bid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_bvalid : out STD_LOGIC;
    saxigp0_bready : in STD_LOGIC;
    saxigp0_arid : in STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_araddr : in STD_LOGIC_VECTOR ( 48 downto 0 );
    saxigp0_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    saxigp0_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_arlock : in STD_LOGIC;
    saxigp0_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    saxigp0_arvalid : in STD_LOGIC;
    saxigp0_arready : out STD_LOGIC;
    saxigp0_rid : out STD_LOGIC_VECTOR ( 5 downto 0 );
    saxigp0_rdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    saxigp0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    saxigp0_rlast : out STD_LOGIC;
    saxigp0_rvalid : out STD_LOGIC;
    saxigp0_rready : in STD_LOGIC;
    saxigp0_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    saxigp0_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pl_resetn0 : out STD_LOGIC;
    pl_clk0 : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of zynqmpsoc_zynq_ultra_ps_e_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of zynqmpsoc_zynq_ultra_ps_e_0_0 : entity is "zynqmpsoc_zynq_ultra_ps_e_0_0,zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of zynqmpsoc_zynq_ultra_ps_e_0_0 : entity is "yes";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of zynqmpsoc_zynq_ultra_ps_e_0_0 : entity is "zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e,Vivado 2019.2.1";
end zynqmpsoc_zynq_ultra_ps_e_0_0;

architecture STRUCTURE of zynqmpsoc_zynq_ultra_ps_e_0_0 is
  signal NLW_inst_dbg_path_fifo_bypass_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_audio_ref_clk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_aux_data_oe_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_aux_data_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_live_video_de_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_m_axis_mixed_audio_tid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_m_axis_mixed_audio_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_s_axis_audio_tready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_video_out_hsync_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_video_out_vsync_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_dp_video_ref_clk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_can0_phy_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_can1_phy_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_delay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_delay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_dma_tx_end_tog_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_gmii_tx_en_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_gmii_tx_er_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_mdio_mdc_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_mdio_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_mdio_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_mdio_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_pdelay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_pdelay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_pdelay_resp_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_pdelay_resp_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_rx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_rx_w_eop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_rx_w_err_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_rx_w_flush_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_rx_w_sop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_rx_w_wr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_sync_frame_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_sync_frame_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_tsu_timer_cmp_val_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_tx_r_fixed_lat_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_tx_r_rd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet0_tx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_delay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_delay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_dma_tx_end_tog_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_gmii_tx_en_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_gmii_tx_er_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_mdio_mdc_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_mdio_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_mdio_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_mdio_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_pdelay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_pdelay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_pdelay_resp_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_pdelay_resp_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_rx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_rx_w_eop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_rx_w_err_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_rx_w_flush_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_rx_w_sop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_rx_w_wr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_sync_frame_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_sync_frame_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_tsu_timer_cmp_val_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_tx_r_fixed_lat_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_tx_r_rd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet1_tx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_delay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_delay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_dma_tx_end_tog_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_gmii_tx_en_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_gmii_tx_er_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_mdio_mdc_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_mdio_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_mdio_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_mdio_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_pdelay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_pdelay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_pdelay_resp_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_pdelay_resp_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_rx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_rx_w_eop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_rx_w_err_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_rx_w_flush_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_rx_w_sop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_rx_w_wr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_sync_frame_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_sync_frame_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_tsu_timer_cmp_val_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_tx_r_fixed_lat_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_tx_r_rd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet2_tx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_delay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_delay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_dma_tx_end_tog_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_gmii_tx_en_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_gmii_tx_er_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_mdio_mdc_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_mdio_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_mdio_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_mdio_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_pdelay_req_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_pdelay_req_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_pdelay_resp_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_pdelay_resp_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_rx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_rx_w_eop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_rx_w_err_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_rx_w_flush_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_rx_w_sop_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_rx_w_wr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_sync_frame_rx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_sync_frame_tx_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_tsu_timer_cmp_val_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_tx_r_fixed_lat_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_tx_r_rd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_enet3_tx_sof_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c0_scl_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c0_scl_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c0_scl_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c0_sda_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c0_sda_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c0_sda_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c1_scl_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c1_scl_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c1_scl_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c1_sda_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c1_sda_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_i2c1_sda_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio0_buspower_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio0_clkout_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio0_cmdena_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio0_cmdout_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio0_ledcontrol_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio1_buspower_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio1_clkout_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio1_cmdena_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio1_cmdout_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_sdio1_ledcontrol_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_m_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_mo_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_mo_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_s_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_sclk_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_sclk_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_sclk_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_so_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_so_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_ss1_o_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_ss2_o_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_ss_n_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_ss_n_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi0_ss_o_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_m_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_mo_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_mo_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_s_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_sclk_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_sclk_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_sclk_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_so_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_so_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_ss1_o_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_ss2_o_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_ss_n_t_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_ss_n_t_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_spi1_ss_o_n_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_u2dsport_vbus_ctrl_usb3_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_u2dsport_vbus_ctrl_usb3_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_u3dsport_vbus_ctrl_usb3_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_u3dsport_vbus_ctrl_usb3_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_uart0_dtrn_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_uart0_rtsn_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_uart0_txd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_uart1_dtrn_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_uart1_rtsn_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_uart1_txd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_wdt0_rst_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_emio_wdt1_rst_o_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_char_afifsfpd_test_output_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_char_afifslpd_test_output_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_char_gem_test_output_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem0_fifo_rx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem0_fifo_tx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem1_fifo_rx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem1_fifo_tx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem2_fifo_rx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem2_fifo_tx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem3_fifo_rx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem3_fifo_tx_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_gem_tsu_clk_to_pl_bufg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fmio_test_io_char_scan_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fpd_pl_spare_0_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fpd_pl_spare_1_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fpd_pl_spare_2_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fpd_pl_spare_3_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_fpd_pl_spare_4_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_io_char_audio_out_test_data_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_io_char_video_out_test_data_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_irq_ipi_pl_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_irq_ipi_pl_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_irq_ipi_pl_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_irq_ipi_pl_3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_lpd_pl_spare_0_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_lpd_pl_spare_1_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_lpd_pl_spare_2_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_lpd_pl_spare_3_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_lpd_pl_spare_4_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_arlock_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_arvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_awlock_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_awvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_bready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_rready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_wlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_maxigp2_wvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_TX_dig_reset_rel_ack_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_TX_pipe_TX_dn_rxdet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_TX_pipe_TX_dp_rxdet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_cmn_calib_comp_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_pg_avddcr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_pg_avddio_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_pg_dvddcr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_pg_static_avddcr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_pg_static_avddio_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_pll_clk_sym_hs_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_pll_fbclk_frac_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_rx_hsrx_clock_stop_ack_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_rx_pipe_lfpsbcn_rxelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_rx_pipe_sigdet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_rx_symbol_clk_by_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_rx_uphy_rx_calib_done_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_rx_uphy_save_calcode_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_afe_rx_uphy_startloop_buf_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_phystatus_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_rstb_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_rx_sgmii_en_cdet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_rxclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_rxelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_rxpolarity_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_rxvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_coreclockready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_coreready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_corerxsignaldet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_phyctrlpartial_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_phyctrlreset_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_phyctrlrxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_phyctrlslumber_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_phyctrltxidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_sata_phyctrltxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_tx_sgmii_ewrap_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_txclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_txdetrx_lpback_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l0_txelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_phystatus_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_rstb_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_rx_sgmii_en_cdet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_rxclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_rxelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_rxpolarity_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_rxvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_coreclockready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_coreready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_corerxsignaldet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_phyctrlpartial_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_phyctrlreset_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_phyctrlrxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_phyctrlslumber_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_phyctrltxidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_sata_phyctrltxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_tx_sgmii_ewrap_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_txclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_txdetrx_lpback_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l1_txelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_phystatus_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_rstb_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_rx_sgmii_en_cdet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_rxclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_rxelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_rxpolarity_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_rxvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_coreclockready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_coreready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_corerxsignaldet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_phyctrlpartial_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_phyctrlreset_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_phyctrlrxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_phyctrlslumber_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_phyctrltxidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_sata_phyctrltxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_tx_sgmii_ewrap_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_txclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_txdetrx_lpback_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l2_txelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_phystatus_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_rstb_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_rx_sgmii_en_cdet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_rxclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_rxelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_rxpolarity_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_rxvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_coreclockready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_coreready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_corerxsignaldet_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_phyctrlpartial_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_phyctrlreset_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_phyctrlrxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_phyctrlslumber_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_phyctrltxidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_sata_phyctrltxrst_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_tx_sgmii_ewrap_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_txclk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_txdetrx_lpback_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_o_dbg_l3_txelecidle_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_osc_rtc_clk_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pl_clk1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pl_clk2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pl_clk3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pl_resetn1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pl_resetn2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pl_resetn3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pmu_aib_afifm_fpd_req_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_pmu_aib_afifm_lpd_req_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_evento_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_aib_axi_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ams_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_apm_fpd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_apu_exterr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_apu_l2err_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_apu_regs_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_atb_err_lpd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_can0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_can1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_clkmon_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_csu_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_csu_dma_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_csu_pmu_wdt_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ddr_ss_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_dpdma_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_dport_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_efuse_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet0_wake_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet1_wake_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet2_wake_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_enet3_wake_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_fp_wdt_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_fpd_apb_int_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_fpd_atb_error_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_gpio_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_gpu_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_i2c0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_i2c1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_intf_fpd_smmu_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_intf_ppd_cci_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ipi_channel0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ipi_channel1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ipi_channel10_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ipi_channel2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ipi_channel7_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ipi_channel8_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ipi_channel9_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_lp_wdt_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_lpd_apb_intr_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_lpd_apm_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_nand_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ocm_error_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_pcie_dma_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_pcie_legacy_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_pcie_msc_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_qspi_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_r5_core0_ecc_error_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_r5_core1_ecc_error_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_rtc_alaram_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_rtc_seconds_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_sata_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_sdio0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_sdio0_wake_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_sdio1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_sdio1_wake_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_spi0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_spi1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc0_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc0_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc0_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc1_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc1_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc1_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc2_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc2_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc2_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc3_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc3_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_ttc3_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_uart0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_uart1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_usb3_0_otg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_usb3_1_otg_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_xmpu_fpd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_irq_xmpu_lpd_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_tracectl_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigack_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigack_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigack_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigack_3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigger_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigger_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigger_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ps_pl_trigger_3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_rpu_evento0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_rpu_evento1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_acvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_buser_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_cdready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_crready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_ruser_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_sacefpd_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxiacp_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxiacp_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxiacp_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxiacp_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxiacp_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxiacp_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp1_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp1_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp1_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp1_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp1_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp1_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp2_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp2_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp2_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp2_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp2_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp2_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp3_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp3_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp3_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp3_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp3_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp3_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp4_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp4_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp4_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp4_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp4_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp4_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp5_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp5_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp5_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp5_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp5_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp5_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp6_arready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp6_awready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp6_bvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp6_rlast_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp6_rvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_saxigp6_wready_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_bscan_tdo_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_ddr2pl_dcd_skewout_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_drdy_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_chopper_so_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_edt_out_apu_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_edt_out_cpu0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_edt_out_cpu1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_edt_out_cpu2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_edt_out_cpu3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_slcr_config_so_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_spare_out0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_test_pl_scan_spare_out1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_trace_clk_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_tst_rtc_osc_clk_out_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_tst_rtc_seconds_raw_int_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_adma2pl_cack_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_adma2pl_tvld_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_dp_m_axis_mixed_audio_tdata_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_dp_video_out_pixel1_UNCONNECTED : STD_LOGIC_VECTOR ( 35 downto 0 );
  signal NLW_inst_emio_enet0_dma_bus_width_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_emio_enet0_enet_tsu_timer_cnt_UNCONNECTED : STD_LOGIC_VECTOR ( 93 downto 0 );
  signal NLW_inst_emio_enet0_gmii_txd_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet0_rx_w_data_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet0_rx_w_status_UNCONNECTED : STD_LOGIC_VECTOR ( 44 downto 0 );
  signal NLW_inst_emio_enet0_speed_mode_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_enet0_tx_r_status_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_emio_enet1_dma_bus_width_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_emio_enet1_gmii_txd_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet1_rx_w_data_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet1_rx_w_status_UNCONNECTED : STD_LOGIC_VECTOR ( 44 downto 0 );
  signal NLW_inst_emio_enet1_speed_mode_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_enet1_tx_r_status_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_emio_enet2_dma_bus_width_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_emio_enet2_gmii_txd_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet2_rx_w_data_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet2_rx_w_status_UNCONNECTED : STD_LOGIC_VECTOR ( 44 downto 0 );
  signal NLW_inst_emio_enet2_speed_mode_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_enet2_tx_r_status_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_emio_enet3_dma_bus_width_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_emio_enet3_gmii_txd_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet3_rx_w_data_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_enet3_rx_w_status_UNCONNECTED : STD_LOGIC_VECTOR ( 44 downto 0 );
  signal NLW_inst_emio_enet3_speed_mode_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_enet3_tx_r_status_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_emio_gpio_o_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_inst_emio_gpio_t_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_inst_emio_gpio_t_n_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_inst_emio_sdio0_bus_volt_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_sdio0_dataena_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_sdio0_dataout_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_sdio1_bus_volt_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_sdio1_dataena_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_sdio1_dataout_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_emio_ttc0_wave_o_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_ttc1_wave_o_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_ttc2_wave_o_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_emio_ttc3_wave_o_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_fmio_sd0_dll_test_out_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_fmio_sd1_dll_test_out_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_fpd_pll_test_out_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_ftm_gpo_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_gdma_perif_cack_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_gdma_perif_tvld_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_lpd_pll_test_out_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_maxigp2_araddr_UNCONNECTED : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal NLW_inst_maxigp2_arburst_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_maxigp2_arcache_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_maxigp2_arid_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_maxigp2_arlen_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_maxigp2_arprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_maxigp2_arqos_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_maxigp2_arsize_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_maxigp2_aruser_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_maxigp2_awaddr_UNCONNECTED : STD_LOGIC_VECTOR ( 39 downto 0 );
  signal NLW_inst_maxigp2_awburst_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_maxigp2_awcache_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_maxigp2_awid_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_maxigp2_awlen_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_maxigp2_awprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_maxigp2_awqos_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_maxigp2_awsize_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_maxigp2_awuser_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_maxigp2_wdata_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_maxigp2_wstrb_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_o_afe_pll_dco_count_UNCONNECTED : STD_LOGIC_VECTOR ( 12 downto 0 );
  signal NLW_inst_o_afe_rx_symbol_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_afe_rx_uphy_save_calcode_data_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_o_dbg_l0_powerdown_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l0_rate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l0_rxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l0_rxdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l0_rxstatus_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_o_dbg_l0_sata_corerxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l0_sata_corerxdatavalid_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l0_sata_phyctrlrxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l0_sata_phyctrltxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l0_sata_phyctrltxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l0_txdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l0_txdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l1_powerdown_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l1_rate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l1_rxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l1_rxdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l1_rxstatus_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_o_dbg_l1_sata_corerxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l1_sata_corerxdatavalid_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l1_sata_phyctrlrxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l1_sata_phyctrltxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l1_sata_phyctrltxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l1_txdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l1_txdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l2_powerdown_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l2_rate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l2_rxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l2_rxdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l2_rxstatus_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_o_dbg_l2_sata_corerxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l2_sata_corerxdatavalid_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l2_sata_phyctrlrxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l2_sata_phyctrltxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l2_sata_phyctrltxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l2_txdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l2_txdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l3_powerdown_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l3_rate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l3_rxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l3_rxdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l3_rxstatus_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_o_dbg_l3_sata_corerxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l3_sata_corerxdatavalid_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l3_sata_phyctrlrxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l3_sata_phyctrltxdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l3_sata_phyctrltxrate_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_o_dbg_l3_txdata_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_o_dbg_l3_txdatak_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_pmu_error_to_pl_UNCONNECTED : STD_LOGIC_VECTOR ( 46 downto 0 );
  signal NLW_inst_pmu_pl_gpo_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_ps_pl_irq_adma_chan_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_ps_pl_irq_apu_comm_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_irq_apu_cpumnt_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_irq_apu_cti_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_irq_apu_pmu_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_irq_gdma_chan_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_ps_pl_irq_pcie_msi_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_ps_pl_irq_rpu_pm_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_ps_pl_irq_usb3_0_endpoint_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_irq_usb3_0_pmu_wakeup_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_ps_pl_irq_usb3_1_endpoint_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_standbywfe_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_standbywfi_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_ps_pl_tracedata_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_pstp_pl_out_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_sacefpd_acaddr_UNCONNECTED : STD_LOGIC_VECTOR ( 43 downto 0 );
  signal NLW_inst_sacefpd_acprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_sacefpd_acsnoop_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_sacefpd_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_sacefpd_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_sacefpd_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_sacefpd_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_sacefpd_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxiacp_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal NLW_inst_saxiacp_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxiacp_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_saxiacp_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal NLW_inst_saxiacp_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp0_racount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp0_rcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp0_wacount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp0_wcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp1_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp1_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp1_racount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp1_rcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp1_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_saxigp1_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp1_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp1_wacount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp1_wcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp2_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp2_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp2_racount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp2_rcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp2_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_saxigp2_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp2_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp2_wacount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp2_wcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp3_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp3_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp3_racount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp3_rcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp3_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_saxigp3_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp3_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp3_wacount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp3_wcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp4_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp4_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp4_racount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp4_rcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp4_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_saxigp4_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp4_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp4_wacount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp4_wcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp5_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp5_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp5_racount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp5_rcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp5_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_saxigp5_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp5_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp5_wacount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp5_wcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp6_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp6_bresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp6_racount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp6_rcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_saxigp6_rdata_UNCONNECTED : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal NLW_inst_saxigp6_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_saxigp6_rresp_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_saxigp6_wacount_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_saxigp6_wcount_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_test_adc_out_UNCONNECTED : STD_LOGIC_VECTOR ( 19 downto 0 );
  signal NLW_inst_test_ams_osc_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_test_db_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_test_do_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_test_mon_data_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_test_pl_pll_lock_out_UNCONNECTED : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal NLW_inst_test_pl_scan_edt_out_ddr_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_test_pl_scan_edt_out_fp_UNCONNECTED : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal NLW_inst_test_pl_scan_edt_out_gpu_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_test_pl_scan_edt_out_lp_UNCONNECTED : STD_LOGIC_VECTOR ( 8 downto 0 );
  signal NLW_inst_test_pl_scan_edt_out_usb3_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_tst_rtc_calibreg_out_UNCONNECTED : STD_LOGIC_VECTOR ( 20 downto 0 );
  signal NLW_inst_tst_rtc_osc_cntrl_out_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_tst_rtc_sec_counter_out_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_tst_rtc_tick_counter_out_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_inst_tst_rtc_timesetreg_out_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  attribute C_DP_USE_AUDIO : integer;
  attribute C_DP_USE_AUDIO of inst : label is 0;
  attribute C_DP_USE_VIDEO : integer;
  attribute C_DP_USE_VIDEO of inst : label is 0;
  attribute C_EMIO_GPIO_WIDTH : integer;
  attribute C_EMIO_GPIO_WIDTH of inst : label is 1;
  attribute C_EN_EMIO_TRACE : integer;
  attribute C_EN_EMIO_TRACE of inst : label is 0;
  attribute C_EN_FIFO_ENET0 : string;
  attribute C_EN_FIFO_ENET0 of inst : label is "0";
  attribute C_EN_FIFO_ENET1 : string;
  attribute C_EN_FIFO_ENET1 of inst : label is "0";
  attribute C_EN_FIFO_ENET2 : string;
  attribute C_EN_FIFO_ENET2 of inst : label is "0";
  attribute C_EN_FIFO_ENET3 : string;
  attribute C_EN_FIFO_ENET3 of inst : label is "0";
  attribute C_MAXIGP0_DATA_WIDTH : integer;
  attribute C_MAXIGP0_DATA_WIDTH of inst : label is 32;
  attribute C_MAXIGP1_DATA_WIDTH : integer;
  attribute C_MAXIGP1_DATA_WIDTH of inst : label is 32;
  attribute C_MAXIGP2_DATA_WIDTH : integer;
  attribute C_MAXIGP2_DATA_WIDTH of inst : label is 32;
  attribute C_NUM_F2P_0_INTR_INPUTS : integer;
  attribute C_NUM_F2P_0_INTR_INPUTS of inst : label is 1;
  attribute C_NUM_F2P_1_INTR_INPUTS : integer;
  attribute C_NUM_F2P_1_INTR_INPUTS of inst : label is 1;
  attribute C_NUM_FABRIC_RESETS : integer;
  attribute C_NUM_FABRIC_RESETS of inst : label is 1;
  attribute C_PL_CLK0_BUF : string;
  attribute C_PL_CLK0_BUF of inst : label is "TRUE";
  attribute C_PL_CLK1_BUF : string;
  attribute C_PL_CLK1_BUF of inst : label is "FALSE";
  attribute C_PL_CLK2_BUF : string;
  attribute C_PL_CLK2_BUF of inst : label is "FALSE";
  attribute C_PL_CLK3_BUF : string;
  attribute C_PL_CLK3_BUF of inst : label is "FALSE";
  attribute C_SAXIGP0_DATA_WIDTH : integer;
  attribute C_SAXIGP0_DATA_WIDTH of inst : label is 64;
  attribute C_SAXIGP1_DATA_WIDTH : integer;
  attribute C_SAXIGP1_DATA_WIDTH of inst : label is 128;
  attribute C_SAXIGP2_DATA_WIDTH : integer;
  attribute C_SAXIGP2_DATA_WIDTH of inst : label is 128;
  attribute C_SAXIGP3_DATA_WIDTH : integer;
  attribute C_SAXIGP3_DATA_WIDTH of inst : label is 128;
  attribute C_SAXIGP4_DATA_WIDTH : integer;
  attribute C_SAXIGP4_DATA_WIDTH of inst : label is 128;
  attribute C_SAXIGP5_DATA_WIDTH : integer;
  attribute C_SAXIGP5_DATA_WIDTH of inst : label is 128;
  attribute C_SAXIGP6_DATA_WIDTH : integer;
  attribute C_SAXIGP6_DATA_WIDTH of inst : label is 128;
  attribute C_SD0_INTERNAL_BUS_WIDTH : integer;
  attribute C_SD0_INTERNAL_BUS_WIDTH of inst : label is 8;
  attribute C_SD1_INTERNAL_BUS_WIDTH : integer;
  attribute C_SD1_INTERNAL_BUS_WIDTH of inst : label is 8;
  attribute C_TRACE_DATA_WIDTH : integer;
  attribute C_TRACE_DATA_WIDTH of inst : label is 32;
  attribute C_TRACE_PIPELINE_WIDTH : integer;
  attribute C_TRACE_PIPELINE_WIDTH of inst : label is 8;
  attribute C_USE_DEBUG_TEST : integer;
  attribute C_USE_DEBUG_TEST of inst : label is 0;
  attribute C_USE_DIFF_RW_CLK_GP0 : integer;
  attribute C_USE_DIFF_RW_CLK_GP0 of inst : label is 0;
  attribute C_USE_DIFF_RW_CLK_GP1 : integer;
  attribute C_USE_DIFF_RW_CLK_GP1 of inst : label is 0;
  attribute C_USE_DIFF_RW_CLK_GP2 : integer;
  attribute C_USE_DIFF_RW_CLK_GP2 of inst : label is 0;
  attribute C_USE_DIFF_RW_CLK_GP3 : integer;
  attribute C_USE_DIFF_RW_CLK_GP3 of inst : label is 0;
  attribute C_USE_DIFF_RW_CLK_GP4 : integer;
  attribute C_USE_DIFF_RW_CLK_GP4 of inst : label is 0;
  attribute C_USE_DIFF_RW_CLK_GP5 : integer;
  attribute C_USE_DIFF_RW_CLK_GP5 of inst : label is 0;
  attribute C_USE_DIFF_RW_CLK_GP6 : integer;
  attribute C_USE_DIFF_RW_CLK_GP6 of inst : label is 0;
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of inst : label is "zynqmpsoc_zynq_ultra_ps_e_0_0.hwdef";
  attribute PSS_IO : string;
  attribute PSS_IO of inst : label is "Signal Name, DiffPair Type, DiffPair Signal,Direction, Site Type, IO Standard, Drive (mA), Slew Rate, Pull Type, IBIS Model, ODT, OUTPUT_IMPEDANCE " & LF &
 "QSPI_X4_SCLK_OUT, , , OUT, PS_MIO0_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MISO_MO1, , , INOUT, PS_MIO1_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO2, , , INOUT, PS_MIO2_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO3, , , INOUT, PS_MIO3_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MOSI_MI0, , , INOUT, PS_MIO4_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_N_SS_OUT, , , OUT, PS_MIO5_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_CLK_FOR_LPBK, , , OUT, PS_MIO6_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_N_SS_OUT_UPPER, , , OUT, PS_MIO7_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[0], , , INOUT, PS_MIO8_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[1], , , INOUT, PS_MIO9_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[2], , , INOUT, PS_MIO10_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_MO_UPPER[3], , , INOUT, PS_MIO11_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "QSPI_X4_SCLK_OUT_UPPER, , , OUT, PS_MIO12_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO0_GPIO0[13], , , INOUT, PS_MIO13_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C0_SCL_OUT, , , INOUT, PS_MIO14_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C0_SDA_OUT, , , INOUT, PS_MIO15_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C1_SCL_OUT, , , INOUT, PS_MIO16_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "I2C1_SDA_OUT, , , INOUT, PS_MIO17_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART0_RXD, , , IN, PS_MIO18_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART0_TXD, , , OUT, PS_MIO19_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART1_TXD, , , OUT, PS_MIO20_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "UART1_RXD, , , IN, PS_MIO21_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO0_GPIO0[22], , , INOUT, PS_MIO22_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO0_GPIO0[23], , , INOUT, PS_MIO23_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "CAN1_PHY_TX, , , OUT, PS_MIO24_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "CAN1_PHY_RX, , , IN, PS_MIO25_500, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO1_GPIO1[26], , , INOUT, PS_MIO26_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_AUX_DATA_OUT, , , OUT, PS_MIO27_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_HOT_PLUG_DETECT, , , IN, PS_MIO28_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_AUX_DATA_OE, , , OUT, PS_MIO29_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "DPAUX_DP_AUX_DATA_IN, , , IN, PS_MIO30_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PCIE_ROOT_RESET_N, , , OUT, PS_MIO31_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[0], , , OUT, PS_MIO32_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[1], , , OUT, PS_MIO33_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[2], , , OUT, PS_MIO34_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[3], , , OUT, PS_MIO35_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[4], , , OUT, PS_MIO36_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PMU_GPO[5], , , OUT, PS_MIO37_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO1_GPIO1[38], , , INOUT, PS_MIO38_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[4], , , INOUT, PS_MIO39_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[5], , , INOUT, PS_MIO40_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[6], , , INOUT, PS_MIO41_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[7], , , INOUT, PS_MIO42_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GPIO1_GPIO1[43], , , INOUT, PS_MIO43_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_WP, , , IN, PS_MIO44_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_CD_N, , , IN, PS_MIO45_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[0], , , INOUT, PS_MIO46_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[1], , , INOUT, PS_MIO47_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[2], , , INOUT, PS_MIO48_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_DATA_OUT[3], , , INOUT, PS_MIO49_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_CMD_OUT, , , INOUT, PS_MIO50_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "SD1_SDIO1_CLK_OUT, , , OUT, PS_MIO51_501, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_CLK_IN, , , IN, PS_MIO52_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_DIR, , , IN, PS_MIO53_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[2], , , INOUT, PS_MIO54_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_NXT, , , IN, PS_MIO55_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[0], , , INOUT, PS_MIO56_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[1], , , INOUT, PS_MIO57_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_STP, , , OUT, PS_MIO58_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[3], , , INOUT, PS_MIO59_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[4], , , INOUT, PS_MIO60_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[5], , , INOUT, PS_MIO61_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[6], , , INOUT, PS_MIO62_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "USB0_ULPI_TX_DATA[7], , , INOUT, PS_MIO63_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TX_CLK, , , OUT, PS_MIO64_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[0], , , OUT, PS_MIO65_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[1], , , OUT, PS_MIO66_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[2], , , OUT, PS_MIO67_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TXD[3], , , OUT, PS_MIO68_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_TX_CTL, , , OUT, PS_MIO69_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RX_CLK, , , IN, PS_MIO70_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[0], , , IN, PS_MIO71_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[1], , , IN, PS_MIO72_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[2], , , IN, PS_MIO73_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RXD[3], , , IN, PS_MIO74_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "GEM3_RGMII_RX_CTL, , , IN, PS_MIO75_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "MDIO3_GEM3_MDC, , , OUT, PS_MIO76_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "MDIO3_GEM3_MDIO_OUT, , , INOUT, PS_MIO77_502, LVCMOS18, 12, FAST, PULLUP, PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PCIE_MGTREFCLK0N, , , IN, PS_MGTREFCLK0N_505, , , , , ,,  " & LF &
 "PCIE_MGTREFCLK0P, , , IN, PS_MGTREFCLK0P_505, , , , , ,,  " & LF &
 "PS_REF_CLK, , , IN, PS_REF_CLK_503, LVCMOS18, 2, SLOW, , PS_MIO_LVCMOS18_S_2,,  " & LF &
 "PS_JTAG_TCK, , , IN, PS_JTAG_TCK_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_JTAG_TDI, , , IN, PS_JTAG_TDI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_JTAG_TDO, , , OUT, PS_JTAG_TDO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_JTAG_TMS, , , IN, PS_JTAG_TMS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_DONE, , , OUT, PS_DONE_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_ERROR_OUT, , , OUT, PS_ERROR_OUT_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_ERROR_STATUS, , , OUT, PS_ERROR_STATUS_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_INIT_B, , , INOUT, PS_INIT_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE0, , , IN, PS_MODE0_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE1, , , IN, PS_MODE1_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE2, , , IN, PS_MODE2_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_MODE3, , , IN, PS_MODE3_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_PADI, , , IN, PS_PADI_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_PADO, , , OUT, PS_PADO_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_POR_B, , , IN, PS_POR_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_PROG_B, , , IN, PS_PROG_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PS_SRST_B, , , IN, PS_SRST_B_503, LVCMOS18, 12, FAST, , PS_MIO_LVCMOS18_F_12,,  " & LF &
 "PCIE_MGTRRXN0, , , IN, PS_MGTRRXN0_505, , , , , ,,  " & LF &
 "PCIE_MGTRRXP0, , , IN, PS_MGTRRXP0_505, , , , , ,,  " & LF &
 "PCIE_MGTRTXN0, , , OUT, PS_MGTRTXN0_505, , , , , ,,  " & LF &
 "PCIE_MGTRTXP0, , , OUT, PS_MGTRTXP0_505, , , , , ,,  " & LF &
 "SATA1_MGTREFCLK1N, , , IN, PS_MGTREFCLK1N_505, , , , , ,,  " & LF &
 "SATA1_MGTREFCLK1P, , , IN, PS_MGTREFCLK1P_505, , , , , ,,  " & LF &
 "DP0_MGTRRXN1, , , IN, PS_MGTRRXN1_505, , , , , ,,  " & LF &
 "DP0_MGTRRXP1, , , IN, PS_MGTRRXP1_505, , , , , ,,  " & LF &
 "DP0_MGTRTXN1, , , OUT, PS_MGTRTXN1_505, , , , , ,,  " & LF &
 "DP0_MGTRTXP1, , , OUT, PS_MGTRTXP1_505, , , , , ,,  " & LF &
 "USB0_MGTREFCLK2N, , , IN, PS_MGTREFCLK2N_505, , , , , ,,  " & LF &
 "USB0_MGTREFCLK2P, , , IN, PS_MGTREFCLK2P_505, , , , , ,,  " & LF &
 "USB0_MGTRRXN2, , , IN, PS_MGTRRXN2_505, , , , , ,,  " & LF &
 "USB0_MGTRRXP2, , , IN, PS_MGTRRXP2_505, , , , , ,,  " & LF &
 "USB0_MGTRTXN2, , , OUT, PS_MGTRTXN2_505, , , , , ,,  " & LF &
 "USB0_MGTRTXP2, , , OUT, PS_MGTRTXP2_505, , , , , ,,  " & LF &
 "DP0_MGTREFCLK3N, , , IN, PS_MGTREFCLK3N_505, , , , , ,,  " & LF &
 "DP0_MGTREFCLK3P, , , IN, PS_MGTREFCLK3P_505, , , , , ,,  " & LF &
 "SATA1_MGTRRXN3, , , IN, PS_MGTRRXN3_505, , , , , ,,  " & LF &
 "SATA1_MGTRRXP3, , , IN, PS_MGTRRXP3_505, , , , , ,,  " & LF &
 "SATA1_MGTRTXN3, , , OUT, PS_MGTRTXN3_505, , , , , ,,  " & LF &
 "SATA1_MGTRTXP3, , , OUT, PS_MGTRTXP3_505, , , , , ,, " & LF &
 " DDR4_RAM_RST_N, , , OUT, PS_DDR_RAM_RST_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ACT_N, , , OUT, PS_DDR_ACT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_PARITY, , , OUT, PS_DDR_PARITY_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ALERT_N, , , IN, PS_DDR_ALERT_N_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_CK0, P, DDR4_CK_N0, OUT, PS_DDR_CK0_504, DDR4, , , ,PS_DDR4_CK_OUT34_P, RTT_NONE, 34" & LF &
 " DDR4_CK_N0, N, DDR4_CK0, OUT, PS_DDR_CK_N0_504, DDR4, , , ,PS_DDR4_CK_OUT34_N, RTT_NONE, 34" & LF &
 " DDR4_CKE0, , , OUT, PS_DDR_CKE0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_CS_N0, , , OUT, PS_DDR_CS_N0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ODT0, , , OUT, PS_DDR_ODT0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BG0, , , OUT, PS_DDR_BG0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BG1, , , OUT, PS_DDR_BG1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BA0, , , OUT, PS_DDR_BA0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_BA1, , , OUT, PS_DDR_BA1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_ZQ, , , INOUT, PS_DDR_ZQ_504, DDR4, , , ,, , " & LF &
 " DDR4_A0, , , OUT, PS_DDR_A0_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A1, , , OUT, PS_DDR_A1_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A2, , , OUT, PS_DDR_A2_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A3, , , OUT, PS_DDR_A3_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A4, , , OUT, PS_DDR_A4_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A5, , , OUT, PS_DDR_A5_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A6, , , OUT, PS_DDR_A6_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A7, , , OUT, PS_DDR_A7_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A8, , , OUT, PS_DDR_A8_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A9, , , OUT, PS_DDR_A9_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A10, , , OUT, PS_DDR_A10_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A11, , , OUT, PS_DDR_A11_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A12, , , OUT, PS_DDR_A12_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A13, , , OUT, PS_DDR_A13_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A14, , , OUT, PS_DDR_A14_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_A15, , , OUT, PS_DDR_A15_504, DDR4, , , ,PS_DDR4_CKE_OUT34, RTT_NONE, 34" & LF &
 " DDR4_DQS_P0, P, DDR4_DQS_N0, INOUT, PS_DDR_DQS_P0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P1, P, DDR4_DQS_N1, INOUT, PS_DDR_DQS_P1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P2, P, DDR4_DQS_N2, INOUT, PS_DDR_DQS_P2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P3, P, DDR4_DQS_N3, INOUT, PS_DDR_DQS_P3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P4, P, DDR4_DQS_N4, INOUT, PS_DDR_DQS_P4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P5, P, DDR4_DQS_N5, INOUT, PS_DDR_DQS_P5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P6, P, DDR4_DQS_N6, INOUT, PS_DDR_DQS_P6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_P7, P, DDR4_DQS_N7, INOUT, PS_DDR_DQS_P7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_P|PS_DDR4_DQS_IN40_P, RTT_40, 34" & LF &
 " DDR4_DQS_N0, N, DDR4_DQS_P0, INOUT, PS_DDR_DQS_N0_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N1, N, DDR4_DQS_P1, INOUT, PS_DDR_DQS_N1_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N2, N, DDR4_DQS_P2, INOUT, PS_DDR_DQS_N2_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N3, N, DDR4_DQS_P3, INOUT, PS_DDR_DQS_N3_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N4, N, DDR4_DQS_P4, INOUT, PS_DDR_DQS_N4_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N5, N, DDR4_DQS_P5, INOUT, PS_DDR_DQS_N5_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N6, N, DDR4_DQS_P6, INOUT, PS_DDR_DQS_N6_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DQS_N7, N, DDR4_DQS_P7, INOUT, PS_DDR_DQS_N7_504, DDR4, , , ,PS_DDR4_DQS_OUT34_N|PS_DDR4_DQS_IN40_N, RTT_40, 34" & LF &
 " DDR4_DM0, , , OUT, PS_DDR_DM0_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM1, , , OUT, PS_DDR_DM1_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM2, , , OUT, PS_DDR_DM2_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM3, , , OUT, PS_DDR_DM3_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM4, , , OUT, PS_DDR_DM4_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM5, , , OUT, PS_DDR_DM5_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM6, , , OUT, PS_DDR_DM6_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DM7, , , OUT, PS_DDR_DM7_504, DDR4, , , ,PS_DDR4_DQ_OUT34, RTT_40, 34" & LF &
 " DDR4_DQ0, , , INOUT, PS_DDR_DQ0_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ1, , , INOUT, PS_DDR_DQ1_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ2, , , INOUT, PS_DDR_DQ2_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ3, , , INOUT, PS_DDR_DQ3_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ4, , , INOUT, PS_DDR_DQ4_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ5, , , INOUT, PS_DDR_DQ5_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ6, , , INOUT, PS_DDR_DQ6_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ7, , , INOUT, PS_DDR_DQ7_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ8, , , INOUT, PS_DDR_DQ8_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ9, , , INOUT, PS_DDR_DQ9_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ10, , , INOUT, PS_DDR_DQ10_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ11, , , INOUT, PS_DDR_DQ11_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ12, , , INOUT, PS_DDR_DQ12_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ13, , , INOUT, PS_DDR_DQ13_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ14, , , INOUT, PS_DDR_DQ14_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ15, , , INOUT, PS_DDR_DQ15_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ16, , , INOUT, PS_DDR_DQ16_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ17, , , INOUT, PS_DDR_DQ17_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ18, , , INOUT, PS_DDR_DQ18_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ19, , , INOUT, PS_DDR_DQ19_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ20, , , INOUT, PS_DDR_DQ20_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ21, , , INOUT, PS_DDR_DQ21_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ22, , , INOUT, PS_DDR_DQ22_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ23, , , INOUT, PS_DDR_DQ23_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ24, , , INOUT, PS_DDR_DQ24_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ25, , , INOUT, PS_DDR_DQ25_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ26, , , INOUT, PS_DDR_DQ26_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ27, , , INOUT, PS_DDR_DQ27_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ28, , , INOUT, PS_DDR_DQ28_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ29, , , INOUT, PS_DDR_DQ29_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ30, , , INOUT, PS_DDR_DQ30_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ31, , , INOUT, PS_DDR_DQ31_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ32, , , INOUT, PS_DDR_DQ32_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ33, , , INOUT, PS_DDR_DQ33_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ34, , , INOUT, PS_DDR_DQ34_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ35, , , INOUT, PS_DDR_DQ35_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ36, , , INOUT, PS_DDR_DQ36_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ37, , , INOUT, PS_DDR_DQ37_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ38, , , INOUT, PS_DDR_DQ38_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ39, , , INOUT, PS_DDR_DQ39_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ40, , , INOUT, PS_DDR_DQ40_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ41, , , INOUT, PS_DDR_DQ41_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ42, , , INOUT, PS_DDR_DQ42_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ43, , , INOUT, PS_DDR_DQ43_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ44, , , INOUT, PS_DDR_DQ44_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ45, , , INOUT, PS_DDR_DQ45_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ46, , , INOUT, PS_DDR_DQ46_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ47, , , INOUT, PS_DDR_DQ47_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ48, , , INOUT, PS_DDR_DQ48_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ49, , , INOUT, PS_DDR_DQ49_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ50, , , INOUT, PS_DDR_DQ50_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ51, , , INOUT, PS_DDR_DQ51_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ52, , , INOUT, PS_DDR_DQ52_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ53, , , INOUT, PS_DDR_DQ53_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ54, , , INOUT, PS_DDR_DQ54_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ55, , , INOUT, PS_DDR_DQ55_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ56, , , INOUT, PS_DDR_DQ56_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ57, , , INOUT, PS_DDR_DQ57_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ58, , , INOUT, PS_DDR_DQ58_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ59, , , INOUT, PS_DDR_DQ59_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ60, , , INOUT, PS_DDR_DQ60_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ61, , , INOUT, PS_DDR_DQ61_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ62, , , INOUT, PS_DDR_DQ62_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34" & LF &
 " DDR4_DQ63, , , INOUT, PS_DDR_DQ63_504, DDR4, , , ,PS_DDR4_DQ_OUT34|PS_DDR4_DQ_IN40, RTT_40, 34";
  attribute PSS_JITTER : string;
  attribute PSS_JITTER of inst : label is "<PSS_EXTERNAL_CLOCKS><EXTERNAL_CLOCK name={PLCLK[0]} clock_external_divide={20} vco_name={IOPLL} vco_freq={3000.000} vco_internal_divide={2}/></PSS_EXTERNAL_CLOCKS>";
  attribute PSS_POWER : string;
  attribute PSS_POWER of inst : label is "<BLOCKTYPE name={PS8}> <PS8><FPD><PROCESSSORS><PROCESSOR name={Cortex A-53} numCores={4} L2Cache={Enable} clockFreq={1200.000000} load={0.5}/><PROCESSOR name={GPU Mali-400 MP} numCores={2} clockFreq={500.000000} load={0.5} /></PROCESSSORS><PLLS><PLL domain={APU} vco={2399.976} /><PLL domain={DDR} vco={2099.979} /><PLL domain={Video} vco={2999.970} /></PLLS><MEMORY memType={DDR4} dataWidth={8} clockFreq={1050.000} readRate={0.5} writeRate={0.5} cmdAddressActivity={0.5} /><SERDES><GT name={PCIe} standard={Gen2} lanes={1} usageRate={0.5} /><GT name={SATA} standard={SATA3} lanes={1} usageRate={0.5} /><GT name={Display Port} standard={SVGA-60 (800x600)} lanes={1} usageRate={0.5} />clockFreq={60} /><GT name={USB3} standard={USB3.0} lanes={1}usageRate={0.5} /><GT name={SGMII} standard={SGMII} lanes={0} usageRate={0.5} /></SERDES><AFI master={2} slave={1} clockFreq={75.000} usageRate={0.5} /><FPINTERCONNECT clockFreq={667} Bandwidth={Low} /></FPD><LPD><PROCESSSORS><PROCESSOR name={Cortex R-5} usage={Enable} TCM={Enable} OCM={Enable} clockFreq={500.000000} load={0.5}/></PROCESSSORS><PLLS><PLL domain={IO} vco={2999.970} /><PLL domain={RPLL} vco={1499.985} /></PLLS><CSUPMU><Unit name={CSU} usageRate={0.5} clockFreq={180} /><Unit name={PMU} usageRate={0.5} clockFreq={180} /></CSUPMU><GPIO><Bank ioBank={VCC_PSIO0} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO1} number={3} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO2} number={0} io_standard={LVCMOS 1.8V} /><Bank ioBank={VCC_PSIO3} number={16} io_standard={LVCMOS 1.8V} /></GPIO><IOINTERFACES> <IO name={QSPI} io_standard={} ioBank={VCC_PSIO0} clockFreq={125.000000} inputs={0} outputs={5} inouts={8} usageRate={0.5}/><IO name={NAND 3.1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={USB0} io_standard={} ioBank={VCC_PSIO2} clockFreq={250.000000} inputs={3} outputs={1} inouts={8} usageRate={0.5}/><IO name={USB1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GigabitEth3} io_standard={} ioBank={VCC_PSIO2} clockFreq={125.000000} inputs={6} outputs={6} inouts={0} usageRate={0.5}/><IO name={GPIO 0} io_standard={} ioBank={VCC_PSIO0} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 1} io_standard={} ioBank={VCC_PSIO1} clockFreq={1} inputs={0} outputs={0} inouts={3} usageRate={0.5}/><IO name={GPIO 2} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={GPIO 3} io_standard={} ioBank={VCC_PSIO3} clockFreq={1} inputs={} outputs={} inouts={16} usageRate={0.5}/><IO name={UART0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={UART1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={I2C0} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={I2C1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={0} outputs={0} inouts={2} usageRate={0.5}/><IO name={SPI0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SPI1} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={CAN1} io_standard={} ioBank={VCC_PSIO0} clockFreq={100.000000} inputs={1} outputs={1} inouts={0} usageRate={0.5}/><IO name={SD0} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={SD1} io_standard={} ioBank={VCC_PSIO1} clockFreq={187.500000} inputs={2} outputs={1} inouts={9} usageRate={0.5}/><IO name={Trace} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={TTC0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC2} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={TTC3} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={PJTAG} io_standard={} ioBank={} clockFreq={} inputs={} outputs={} inouts={} usageRate={0.5}/><IO name={DPAUX} io_standard={} ioBank={VCC_PSIO1} clockFreq={} inputs={2} outputs={2} inouts={0} usageRate={0.5}/><IO name={WDT0} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/><IO name={WDT1} io_standard={} ioBank={} clockFreq={100} inputs={0} outputs={0} inouts={0} usageRate={0.5}/></IOINTERFACES><AFI master={0} slave={0} clockFreq={333.333} usageRate={0.5} /><LPINTERCONNECT clockFreq={667} Bandwidth={High} /></LPD></PS8></BLOCKTYPE>/>";
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of maxigp0_arlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARLOCK";
  attribute X_INTERFACE_INFO of maxigp0_arready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARREADY";
  attribute X_INTERFACE_INFO of maxigp0_arvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARVALID";
  attribute X_INTERFACE_INFO of maxigp0_awlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWLOCK";
  attribute X_INTERFACE_INFO of maxigp0_awready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWREADY";
  attribute X_INTERFACE_INFO of maxigp0_awvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWVALID";
  attribute X_INTERFACE_INFO of maxigp0_bready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BREADY";
  attribute X_INTERFACE_INFO of maxigp0_bvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BVALID";
  attribute X_INTERFACE_INFO of maxigp0_rlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RLAST";
  attribute X_INTERFACE_INFO of maxigp0_rready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RREADY";
  attribute X_INTERFACE_INFO of maxigp0_rvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RVALID";
  attribute X_INTERFACE_INFO of maxigp0_wlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WLAST";
  attribute X_INTERFACE_INFO of maxigp0_wready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WREADY";
  attribute X_INTERFACE_INFO of maxigp0_wvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WVALID";
  attribute X_INTERFACE_INFO of maxigp1_arlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARLOCK";
  attribute X_INTERFACE_INFO of maxigp1_arready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARREADY";
  attribute X_INTERFACE_INFO of maxigp1_arvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARVALID";
  attribute X_INTERFACE_INFO of maxigp1_awlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWLOCK";
  attribute X_INTERFACE_INFO of maxigp1_awready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWREADY";
  attribute X_INTERFACE_INFO of maxigp1_awvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWVALID";
  attribute X_INTERFACE_INFO of maxigp1_bready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BREADY";
  attribute X_INTERFACE_INFO of maxigp1_bvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BVALID";
  attribute X_INTERFACE_INFO of maxigp1_rlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RLAST";
  attribute X_INTERFACE_INFO of maxigp1_rready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RREADY";
  attribute X_INTERFACE_INFO of maxigp1_rvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RVALID";
  attribute X_INTERFACE_INFO of maxigp1_wlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WLAST";
  attribute X_INTERFACE_INFO of maxigp1_wready : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WREADY";
  attribute X_INTERFACE_INFO of maxigp1_wvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WVALID";
  attribute X_INTERFACE_INFO of maxihpm0_fpd_aclk : signal is "xilinx.com:signal:clock:1.0 M_AXI_HPM0_FPD_ACLK CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of maxihpm0_fpd_aclk : signal is "XIL_INTERFACENAME M_AXI_HPM0_FPD_ACLK, ASSOCIATED_BUSIF M_AXI_HPM0_FPD, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of maxihpm1_fpd_aclk : signal is "xilinx.com:signal:clock:1.0 M_AXI_HPM1_FPD_ACLK CLK";
  attribute X_INTERFACE_PARAMETER of maxihpm1_fpd_aclk : signal is "XIL_INTERFACENAME M_AXI_HPM1_FPD_ACLK, ASSOCIATED_BUSIF M_AXI_HPM1_FPD, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of pl_clk0 : signal is "xilinx.com:signal:clock:1.0 PL_CLK0 CLK";
  attribute X_INTERFACE_PARAMETER of pl_clk0 : signal is "XIL_INTERFACENAME PL_CLK0, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of pl_resetn0 : signal is "xilinx.com:signal:reset:1.0 PL_RESETN0 RST";
  attribute X_INTERFACE_PARAMETER of pl_resetn0 : signal is "XIL_INTERFACENAME PL_RESETN0, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of saxigp0_arlock : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARLOCK";
  attribute X_INTERFACE_INFO of saxigp0_arready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARREADY";
  attribute X_INTERFACE_INFO of saxigp0_aruser : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARUSER";
  attribute X_INTERFACE_INFO of saxigp0_arvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARVALID";
  attribute X_INTERFACE_INFO of saxigp0_awlock : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWLOCK";
  attribute X_INTERFACE_INFO of saxigp0_awready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWREADY";
  attribute X_INTERFACE_INFO of saxigp0_awuser : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWUSER";
  attribute X_INTERFACE_INFO of saxigp0_awvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWVALID";
  attribute X_INTERFACE_INFO of saxigp0_bready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BREADY";
  attribute X_INTERFACE_INFO of saxigp0_bvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BVALID";
  attribute X_INTERFACE_INFO of saxigp0_rlast : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RLAST";
  attribute X_INTERFACE_INFO of saxigp0_rready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RREADY";
  attribute X_INTERFACE_INFO of saxigp0_rvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RVALID";
  attribute X_INTERFACE_INFO of saxigp0_wlast : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WLAST";
  attribute X_INTERFACE_INFO of saxigp0_wready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WREADY";
  attribute X_INTERFACE_INFO of saxigp0_wvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WVALID";
  attribute X_INTERFACE_INFO of saxihpc0_fpd_aclk : signal is "xilinx.com:signal:clock:1.0 S_AXI_HPC0_FPD_ACLK CLK";
  attribute X_INTERFACE_PARAMETER of saxihpc0_fpd_aclk : signal is "XIL_INTERFACENAME S_AXI_HPC0_FPD_ACLK, ASSOCIATED_BUSIF S_AXI_HPC0_FPD, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of maxigp0_araddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARADDR";
  attribute X_INTERFACE_INFO of maxigp0_arburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARBURST";
  attribute X_INTERFACE_INFO of maxigp0_arcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARCACHE";
  attribute X_INTERFACE_INFO of maxigp0_arid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARID";
  attribute X_INTERFACE_INFO of maxigp0_arlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARLEN";
  attribute X_INTERFACE_INFO of maxigp0_arprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARPROT";
  attribute X_INTERFACE_INFO of maxigp0_arqos : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARQOS";
  attribute X_INTERFACE_PARAMETER of maxigp0_arqos : signal is "XIL_INTERFACENAME M_AXI_HPM0_FPD, NUM_WRITE_OUTSTANDING 8, NUM_READ_OUTSTANDING 8, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 16, ARUSER_WIDTH 16, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of maxigp0_arsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARSIZE";
  attribute X_INTERFACE_INFO of maxigp0_aruser : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD ARUSER";
  attribute X_INTERFACE_INFO of maxigp0_awaddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWADDR";
  attribute X_INTERFACE_INFO of maxigp0_awburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWBURST";
  attribute X_INTERFACE_INFO of maxigp0_awcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWCACHE";
  attribute X_INTERFACE_INFO of maxigp0_awid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWID";
  attribute X_INTERFACE_INFO of maxigp0_awlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWLEN";
  attribute X_INTERFACE_INFO of maxigp0_awprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWPROT";
  attribute X_INTERFACE_INFO of maxigp0_awqos : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWQOS";
  attribute X_INTERFACE_INFO of maxigp0_awsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWSIZE";
  attribute X_INTERFACE_INFO of maxigp0_awuser : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD AWUSER";
  attribute X_INTERFACE_INFO of maxigp0_bid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BID";
  attribute X_INTERFACE_INFO of maxigp0_bresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD BRESP";
  attribute X_INTERFACE_INFO of maxigp0_rdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RDATA";
  attribute X_INTERFACE_INFO of maxigp0_rid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RID";
  attribute X_INTERFACE_INFO of maxigp0_rresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD RRESP";
  attribute X_INTERFACE_INFO of maxigp0_wdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WDATA";
  attribute X_INTERFACE_INFO of maxigp0_wstrb : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM0_FPD WSTRB";
  attribute X_INTERFACE_INFO of maxigp1_araddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARADDR";
  attribute X_INTERFACE_INFO of maxigp1_arburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARBURST";
  attribute X_INTERFACE_INFO of maxigp1_arcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARCACHE";
  attribute X_INTERFACE_INFO of maxigp1_arid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARID";
  attribute X_INTERFACE_INFO of maxigp1_arlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARLEN";
  attribute X_INTERFACE_INFO of maxigp1_arprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARPROT";
  attribute X_INTERFACE_INFO of maxigp1_arqos : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARQOS";
  attribute X_INTERFACE_PARAMETER of maxigp1_arqos : signal is "XIL_INTERFACENAME M_AXI_HPM1_FPD, NUM_WRITE_OUTSTANDING 8, NUM_READ_OUTSTANDING 8, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 16, ADDR_WIDTH 40, AWUSER_WIDTH 16, ARUSER_WIDTH 16, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of maxigp1_arsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARSIZE";
  attribute X_INTERFACE_INFO of maxigp1_aruser : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD ARUSER";
  attribute X_INTERFACE_INFO of maxigp1_awaddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWADDR";
  attribute X_INTERFACE_INFO of maxigp1_awburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWBURST";
  attribute X_INTERFACE_INFO of maxigp1_awcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWCACHE";
  attribute X_INTERFACE_INFO of maxigp1_awid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWID";
  attribute X_INTERFACE_INFO of maxigp1_awlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWLEN";
  attribute X_INTERFACE_INFO of maxigp1_awprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWPROT";
  attribute X_INTERFACE_INFO of maxigp1_awqos : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWQOS";
  attribute X_INTERFACE_INFO of maxigp1_awsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWSIZE";
  attribute X_INTERFACE_INFO of maxigp1_awuser : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD AWUSER";
  attribute X_INTERFACE_INFO of maxigp1_bid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BID";
  attribute X_INTERFACE_INFO of maxigp1_bresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD BRESP";
  attribute X_INTERFACE_INFO of maxigp1_rdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RDATA";
  attribute X_INTERFACE_INFO of maxigp1_rid : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RID";
  attribute X_INTERFACE_INFO of maxigp1_rresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD RRESP";
  attribute X_INTERFACE_INFO of maxigp1_wdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WDATA";
  attribute X_INTERFACE_INFO of maxigp1_wstrb : signal is "xilinx.com:interface:aximm:1.0 M_AXI_HPM1_FPD WSTRB";
  attribute X_INTERFACE_INFO of saxigp0_araddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARADDR";
  attribute X_INTERFACE_INFO of saxigp0_arburst : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARBURST";
  attribute X_INTERFACE_INFO of saxigp0_arcache : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARCACHE";
  attribute X_INTERFACE_INFO of saxigp0_arid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARID";
  attribute X_INTERFACE_INFO of saxigp0_arlen : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARLEN";
  attribute X_INTERFACE_INFO of saxigp0_arprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARPROT";
  attribute X_INTERFACE_INFO of saxigp0_arqos : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARQOS";
  attribute X_INTERFACE_PARAMETER of saxigp0_arqos : signal is "XIL_INTERFACENAME S_AXI_HPC0_FPD, NUM_WRITE_OUTSTANDING 16, NUM_READ_OUTSTANDING 16, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 6, ADDR_WIDTH 49, AWUSER_WIDTH 1, ARUSER_WIDTH 1, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, MAX_BURST_LENGTH 16, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of saxigp0_arsize : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD ARSIZE";
  attribute X_INTERFACE_INFO of saxigp0_awaddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWADDR";
  attribute X_INTERFACE_INFO of saxigp0_awburst : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWBURST";
  attribute X_INTERFACE_INFO of saxigp0_awcache : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWCACHE";
  attribute X_INTERFACE_INFO of saxigp0_awid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWID";
  attribute X_INTERFACE_INFO of saxigp0_awlen : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWLEN";
  attribute X_INTERFACE_INFO of saxigp0_awprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWPROT";
  attribute X_INTERFACE_INFO of saxigp0_awqos : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWQOS";
  attribute X_INTERFACE_INFO of saxigp0_awsize : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD AWSIZE";
  attribute X_INTERFACE_INFO of saxigp0_bid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BID";
  attribute X_INTERFACE_INFO of saxigp0_bresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD BRESP";
  attribute X_INTERFACE_INFO of saxigp0_rdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RDATA";
  attribute X_INTERFACE_INFO of saxigp0_rid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RID";
  attribute X_INTERFACE_INFO of saxigp0_rresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD RRESP";
  attribute X_INTERFACE_INFO of saxigp0_wdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WDATA";
  attribute X_INTERFACE_INFO of saxigp0_wstrb : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HPC0_FPD WSTRB";
begin
inst: entity work.zynqmpsoc_zynq_ultra_ps_e_0_0_zynq_ultra_ps_e_v3_3_1_zynq_ultra_ps_e
     port map (
      adma2pl_cack(7 downto 0) => NLW_inst_adma2pl_cack_UNCONNECTED(7 downto 0),
      adma2pl_tvld(7 downto 0) => NLW_inst_adma2pl_tvld_UNCONNECTED(7 downto 0),
      adma_fci_clk(7 downto 0) => B"00000000",
      aib_pmu_afifm_fpd_ack => '0',
      aib_pmu_afifm_lpd_ack => '0',
      dbg_path_fifo_bypass => NLW_inst_dbg_path_fifo_bypass_UNCONNECTED,
      ddrc_ext_refresh_rank0_req => '0',
      ddrc_ext_refresh_rank1_req => '0',
      ddrc_refresh_pl_clk => '0',
      dp_audio_ref_clk => NLW_inst_dp_audio_ref_clk_UNCONNECTED,
      dp_aux_data_in => '0',
      dp_aux_data_oe_n => NLW_inst_dp_aux_data_oe_n_UNCONNECTED,
      dp_aux_data_out => NLW_inst_dp_aux_data_out_UNCONNECTED,
      dp_external_custom_event1 => '0',
      dp_external_custom_event2 => '0',
      dp_external_vsync_event => '0',
      dp_hot_plug_detect => '0',
      dp_live_gfx_alpha_in(7 downto 0) => B"00000000",
      dp_live_gfx_pixel1_in(35 downto 0) => B"000000000000000000000000000000000000",
      dp_live_video_de_out => NLW_inst_dp_live_video_de_out_UNCONNECTED,
      dp_live_video_in_de => '0',
      dp_live_video_in_hsync => '0',
      dp_live_video_in_pixel1(35 downto 0) => B"000000000000000000000000000000000000",
      dp_live_video_in_vsync => '0',
      dp_m_axis_mixed_audio_tdata(31 downto 0) => NLW_inst_dp_m_axis_mixed_audio_tdata_UNCONNECTED(31 downto 0),
      dp_m_axis_mixed_audio_tid => NLW_inst_dp_m_axis_mixed_audio_tid_UNCONNECTED,
      dp_m_axis_mixed_audio_tready => '0',
      dp_m_axis_mixed_audio_tvalid => NLW_inst_dp_m_axis_mixed_audio_tvalid_UNCONNECTED,
      dp_s_axis_audio_clk => '0',
      dp_s_axis_audio_tdata(31 downto 0) => B"00000000000000000000000000000000",
      dp_s_axis_audio_tid => '0',
      dp_s_axis_audio_tready => NLW_inst_dp_s_axis_audio_tready_UNCONNECTED,
      dp_s_axis_audio_tvalid => '0',
      dp_video_in_clk => '0',
      dp_video_out_hsync => NLW_inst_dp_video_out_hsync_UNCONNECTED,
      dp_video_out_pixel1(35 downto 0) => NLW_inst_dp_video_out_pixel1_UNCONNECTED(35 downto 0),
      dp_video_out_vsync => NLW_inst_dp_video_out_vsync_UNCONNECTED,
      dp_video_ref_clk => NLW_inst_dp_video_ref_clk_UNCONNECTED,
      emio_can0_phy_rx => '0',
      emio_can0_phy_tx => NLW_inst_emio_can0_phy_tx_UNCONNECTED,
      emio_can1_phy_rx => '0',
      emio_can1_phy_tx => NLW_inst_emio_can1_phy_tx_UNCONNECTED,
      emio_enet0_delay_req_rx => NLW_inst_emio_enet0_delay_req_rx_UNCONNECTED,
      emio_enet0_delay_req_tx => NLW_inst_emio_enet0_delay_req_tx_UNCONNECTED,
      emio_enet0_dma_bus_width(1 downto 0) => NLW_inst_emio_enet0_dma_bus_width_UNCONNECTED(1 downto 0),
      emio_enet0_dma_tx_end_tog => NLW_inst_emio_enet0_dma_tx_end_tog_UNCONNECTED,
      emio_enet0_dma_tx_status_tog => '0',
      emio_enet0_enet_tsu_timer_cnt(93 downto 0) => NLW_inst_emio_enet0_enet_tsu_timer_cnt_UNCONNECTED(93 downto 0),
      emio_enet0_ext_int_in => '0',
      emio_enet0_gmii_col => '0',
      emio_enet0_gmii_crs => '0',
      emio_enet0_gmii_rx_clk => '0',
      emio_enet0_gmii_rx_dv => '0',
      emio_enet0_gmii_rx_er => '0',
      emio_enet0_gmii_rxd(7 downto 0) => B"00000000",
      emio_enet0_gmii_tx_clk => '0',
      emio_enet0_gmii_tx_en => NLW_inst_emio_enet0_gmii_tx_en_UNCONNECTED,
      emio_enet0_gmii_tx_er => NLW_inst_emio_enet0_gmii_tx_er_UNCONNECTED,
      emio_enet0_gmii_txd(7 downto 0) => NLW_inst_emio_enet0_gmii_txd_UNCONNECTED(7 downto 0),
      emio_enet0_mdio_i => '0',
      emio_enet0_mdio_mdc => NLW_inst_emio_enet0_mdio_mdc_UNCONNECTED,
      emio_enet0_mdio_o => NLW_inst_emio_enet0_mdio_o_UNCONNECTED,
      emio_enet0_mdio_t => NLW_inst_emio_enet0_mdio_t_UNCONNECTED,
      emio_enet0_mdio_t_n => NLW_inst_emio_enet0_mdio_t_n_UNCONNECTED,
      emio_enet0_pdelay_req_rx => NLW_inst_emio_enet0_pdelay_req_rx_UNCONNECTED,
      emio_enet0_pdelay_req_tx => NLW_inst_emio_enet0_pdelay_req_tx_UNCONNECTED,
      emio_enet0_pdelay_resp_rx => NLW_inst_emio_enet0_pdelay_resp_rx_UNCONNECTED,
      emio_enet0_pdelay_resp_tx => NLW_inst_emio_enet0_pdelay_resp_tx_UNCONNECTED,
      emio_enet0_rx_sof => NLW_inst_emio_enet0_rx_sof_UNCONNECTED,
      emio_enet0_rx_w_data(7 downto 0) => NLW_inst_emio_enet0_rx_w_data_UNCONNECTED(7 downto 0),
      emio_enet0_rx_w_eop => NLW_inst_emio_enet0_rx_w_eop_UNCONNECTED,
      emio_enet0_rx_w_err => NLW_inst_emio_enet0_rx_w_err_UNCONNECTED,
      emio_enet0_rx_w_flush => NLW_inst_emio_enet0_rx_w_flush_UNCONNECTED,
      emio_enet0_rx_w_overflow => '0',
      emio_enet0_rx_w_sop => NLW_inst_emio_enet0_rx_w_sop_UNCONNECTED,
      emio_enet0_rx_w_status(44 downto 0) => NLW_inst_emio_enet0_rx_w_status_UNCONNECTED(44 downto 0),
      emio_enet0_rx_w_wr => NLW_inst_emio_enet0_rx_w_wr_UNCONNECTED,
      emio_enet0_signal_detect => '0',
      emio_enet0_speed_mode(2 downto 0) => NLW_inst_emio_enet0_speed_mode_UNCONNECTED(2 downto 0),
      emio_enet0_sync_frame_rx => NLW_inst_emio_enet0_sync_frame_rx_UNCONNECTED,
      emio_enet0_sync_frame_tx => NLW_inst_emio_enet0_sync_frame_tx_UNCONNECTED,
      emio_enet0_tsu_inc_ctrl(1 downto 0) => B"00",
      emio_enet0_tsu_timer_cmp_val => NLW_inst_emio_enet0_tsu_timer_cmp_val_UNCONNECTED,
      emio_enet0_tx_r_control => '0',
      emio_enet0_tx_r_data(7 downto 0) => B"00000000",
      emio_enet0_tx_r_data_rdy => '0',
      emio_enet0_tx_r_eop => '1',
      emio_enet0_tx_r_err => '0',
      emio_enet0_tx_r_fixed_lat => NLW_inst_emio_enet0_tx_r_fixed_lat_UNCONNECTED,
      emio_enet0_tx_r_flushed => '0',
      emio_enet0_tx_r_rd => NLW_inst_emio_enet0_tx_r_rd_UNCONNECTED,
      emio_enet0_tx_r_sop => '1',
      emio_enet0_tx_r_status(3 downto 0) => NLW_inst_emio_enet0_tx_r_status_UNCONNECTED(3 downto 0),
      emio_enet0_tx_r_underflow => '0',
      emio_enet0_tx_r_valid => '0',
      emio_enet0_tx_sof => NLW_inst_emio_enet0_tx_sof_UNCONNECTED,
      emio_enet1_delay_req_rx => NLW_inst_emio_enet1_delay_req_rx_UNCONNECTED,
      emio_enet1_delay_req_tx => NLW_inst_emio_enet1_delay_req_tx_UNCONNECTED,
      emio_enet1_dma_bus_width(1 downto 0) => NLW_inst_emio_enet1_dma_bus_width_UNCONNECTED(1 downto 0),
      emio_enet1_dma_tx_end_tog => NLW_inst_emio_enet1_dma_tx_end_tog_UNCONNECTED,
      emio_enet1_dma_tx_status_tog => '0',
      emio_enet1_ext_int_in => '0',
      emio_enet1_gmii_col => '0',
      emio_enet1_gmii_crs => '0',
      emio_enet1_gmii_rx_clk => '0',
      emio_enet1_gmii_rx_dv => '0',
      emio_enet1_gmii_rx_er => '0',
      emio_enet1_gmii_rxd(7 downto 0) => B"00000000",
      emio_enet1_gmii_tx_clk => '0',
      emio_enet1_gmii_tx_en => NLW_inst_emio_enet1_gmii_tx_en_UNCONNECTED,
      emio_enet1_gmii_tx_er => NLW_inst_emio_enet1_gmii_tx_er_UNCONNECTED,
      emio_enet1_gmii_txd(7 downto 0) => NLW_inst_emio_enet1_gmii_txd_UNCONNECTED(7 downto 0),
      emio_enet1_mdio_i => '0',
      emio_enet1_mdio_mdc => NLW_inst_emio_enet1_mdio_mdc_UNCONNECTED,
      emio_enet1_mdio_o => NLW_inst_emio_enet1_mdio_o_UNCONNECTED,
      emio_enet1_mdio_t => NLW_inst_emio_enet1_mdio_t_UNCONNECTED,
      emio_enet1_mdio_t_n => NLW_inst_emio_enet1_mdio_t_n_UNCONNECTED,
      emio_enet1_pdelay_req_rx => NLW_inst_emio_enet1_pdelay_req_rx_UNCONNECTED,
      emio_enet1_pdelay_req_tx => NLW_inst_emio_enet1_pdelay_req_tx_UNCONNECTED,
      emio_enet1_pdelay_resp_rx => NLW_inst_emio_enet1_pdelay_resp_rx_UNCONNECTED,
      emio_enet1_pdelay_resp_tx => NLW_inst_emio_enet1_pdelay_resp_tx_UNCONNECTED,
      emio_enet1_rx_sof => NLW_inst_emio_enet1_rx_sof_UNCONNECTED,
      emio_enet1_rx_w_data(7 downto 0) => NLW_inst_emio_enet1_rx_w_data_UNCONNECTED(7 downto 0),
      emio_enet1_rx_w_eop => NLW_inst_emio_enet1_rx_w_eop_UNCONNECTED,
      emio_enet1_rx_w_err => NLW_inst_emio_enet1_rx_w_err_UNCONNECTED,
      emio_enet1_rx_w_flush => NLW_inst_emio_enet1_rx_w_flush_UNCONNECTED,
      emio_enet1_rx_w_overflow => '0',
      emio_enet1_rx_w_sop => NLW_inst_emio_enet1_rx_w_sop_UNCONNECTED,
      emio_enet1_rx_w_status(44 downto 0) => NLW_inst_emio_enet1_rx_w_status_UNCONNECTED(44 downto 0),
      emio_enet1_rx_w_wr => NLW_inst_emio_enet1_rx_w_wr_UNCONNECTED,
      emio_enet1_signal_detect => '0',
      emio_enet1_speed_mode(2 downto 0) => NLW_inst_emio_enet1_speed_mode_UNCONNECTED(2 downto 0),
      emio_enet1_sync_frame_rx => NLW_inst_emio_enet1_sync_frame_rx_UNCONNECTED,
      emio_enet1_sync_frame_tx => NLW_inst_emio_enet1_sync_frame_tx_UNCONNECTED,
      emio_enet1_tsu_inc_ctrl(1 downto 0) => B"00",
      emio_enet1_tsu_timer_cmp_val => NLW_inst_emio_enet1_tsu_timer_cmp_val_UNCONNECTED,
      emio_enet1_tx_r_control => '0',
      emio_enet1_tx_r_data(7 downto 0) => B"00000000",
      emio_enet1_tx_r_data_rdy => '0',
      emio_enet1_tx_r_eop => '1',
      emio_enet1_tx_r_err => '0',
      emio_enet1_tx_r_fixed_lat => NLW_inst_emio_enet1_tx_r_fixed_lat_UNCONNECTED,
      emio_enet1_tx_r_flushed => '0',
      emio_enet1_tx_r_rd => NLW_inst_emio_enet1_tx_r_rd_UNCONNECTED,
      emio_enet1_tx_r_sop => '1',
      emio_enet1_tx_r_status(3 downto 0) => NLW_inst_emio_enet1_tx_r_status_UNCONNECTED(3 downto 0),
      emio_enet1_tx_r_underflow => '0',
      emio_enet1_tx_r_valid => '0',
      emio_enet1_tx_sof => NLW_inst_emio_enet1_tx_sof_UNCONNECTED,
      emio_enet2_delay_req_rx => NLW_inst_emio_enet2_delay_req_rx_UNCONNECTED,
      emio_enet2_delay_req_tx => NLW_inst_emio_enet2_delay_req_tx_UNCONNECTED,
      emio_enet2_dma_bus_width(1 downto 0) => NLW_inst_emio_enet2_dma_bus_width_UNCONNECTED(1 downto 0),
      emio_enet2_dma_tx_end_tog => NLW_inst_emio_enet2_dma_tx_end_tog_UNCONNECTED,
      emio_enet2_dma_tx_status_tog => '0',
      emio_enet2_ext_int_in => '0',
      emio_enet2_gmii_col => '0',
      emio_enet2_gmii_crs => '0',
      emio_enet2_gmii_rx_clk => '0',
      emio_enet2_gmii_rx_dv => '0',
      emio_enet2_gmii_rx_er => '0',
      emio_enet2_gmii_rxd(7 downto 0) => B"00000000",
      emio_enet2_gmii_tx_clk => '0',
      emio_enet2_gmii_tx_en => NLW_inst_emio_enet2_gmii_tx_en_UNCONNECTED,
      emio_enet2_gmii_tx_er => NLW_inst_emio_enet2_gmii_tx_er_UNCONNECTED,
      emio_enet2_gmii_txd(7 downto 0) => NLW_inst_emio_enet2_gmii_txd_UNCONNECTED(7 downto 0),
      emio_enet2_mdio_i => '0',
      emio_enet2_mdio_mdc => NLW_inst_emio_enet2_mdio_mdc_UNCONNECTED,
      emio_enet2_mdio_o => NLW_inst_emio_enet2_mdio_o_UNCONNECTED,
      emio_enet2_mdio_t => NLW_inst_emio_enet2_mdio_t_UNCONNECTED,
      emio_enet2_mdio_t_n => NLW_inst_emio_enet2_mdio_t_n_UNCONNECTED,
      emio_enet2_pdelay_req_rx => NLW_inst_emio_enet2_pdelay_req_rx_UNCONNECTED,
      emio_enet2_pdelay_req_tx => NLW_inst_emio_enet2_pdelay_req_tx_UNCONNECTED,
      emio_enet2_pdelay_resp_rx => NLW_inst_emio_enet2_pdelay_resp_rx_UNCONNECTED,
      emio_enet2_pdelay_resp_tx => NLW_inst_emio_enet2_pdelay_resp_tx_UNCONNECTED,
      emio_enet2_rx_sof => NLW_inst_emio_enet2_rx_sof_UNCONNECTED,
      emio_enet2_rx_w_data(7 downto 0) => NLW_inst_emio_enet2_rx_w_data_UNCONNECTED(7 downto 0),
      emio_enet2_rx_w_eop => NLW_inst_emio_enet2_rx_w_eop_UNCONNECTED,
      emio_enet2_rx_w_err => NLW_inst_emio_enet2_rx_w_err_UNCONNECTED,
      emio_enet2_rx_w_flush => NLW_inst_emio_enet2_rx_w_flush_UNCONNECTED,
      emio_enet2_rx_w_overflow => '0',
      emio_enet2_rx_w_sop => NLW_inst_emio_enet2_rx_w_sop_UNCONNECTED,
      emio_enet2_rx_w_status(44 downto 0) => NLW_inst_emio_enet2_rx_w_status_UNCONNECTED(44 downto 0),
      emio_enet2_rx_w_wr => NLW_inst_emio_enet2_rx_w_wr_UNCONNECTED,
      emio_enet2_signal_detect => '0',
      emio_enet2_speed_mode(2 downto 0) => NLW_inst_emio_enet2_speed_mode_UNCONNECTED(2 downto 0),
      emio_enet2_sync_frame_rx => NLW_inst_emio_enet2_sync_frame_rx_UNCONNECTED,
      emio_enet2_sync_frame_tx => NLW_inst_emio_enet2_sync_frame_tx_UNCONNECTED,
      emio_enet2_tsu_inc_ctrl(1 downto 0) => B"00",
      emio_enet2_tsu_timer_cmp_val => NLW_inst_emio_enet2_tsu_timer_cmp_val_UNCONNECTED,
      emio_enet2_tx_r_control => '0',
      emio_enet2_tx_r_data(7 downto 0) => B"00000000",
      emio_enet2_tx_r_data_rdy => '0',
      emio_enet2_tx_r_eop => '1',
      emio_enet2_tx_r_err => '0',
      emio_enet2_tx_r_fixed_lat => NLW_inst_emio_enet2_tx_r_fixed_lat_UNCONNECTED,
      emio_enet2_tx_r_flushed => '0',
      emio_enet2_tx_r_rd => NLW_inst_emio_enet2_tx_r_rd_UNCONNECTED,
      emio_enet2_tx_r_sop => '1',
      emio_enet2_tx_r_status(3 downto 0) => NLW_inst_emio_enet2_tx_r_status_UNCONNECTED(3 downto 0),
      emio_enet2_tx_r_underflow => '0',
      emio_enet2_tx_r_valid => '0',
      emio_enet2_tx_sof => NLW_inst_emio_enet2_tx_sof_UNCONNECTED,
      emio_enet3_delay_req_rx => NLW_inst_emio_enet3_delay_req_rx_UNCONNECTED,
      emio_enet3_delay_req_tx => NLW_inst_emio_enet3_delay_req_tx_UNCONNECTED,
      emio_enet3_dma_bus_width(1 downto 0) => NLW_inst_emio_enet3_dma_bus_width_UNCONNECTED(1 downto 0),
      emio_enet3_dma_tx_end_tog => NLW_inst_emio_enet3_dma_tx_end_tog_UNCONNECTED,
      emio_enet3_dma_tx_status_tog => '0',
      emio_enet3_ext_int_in => '0',
      emio_enet3_gmii_col => '0',
      emio_enet3_gmii_crs => '0',
      emio_enet3_gmii_rx_clk => '0',
      emio_enet3_gmii_rx_dv => '0',
      emio_enet3_gmii_rx_er => '0',
      emio_enet3_gmii_rxd(7 downto 0) => B"00000000",
      emio_enet3_gmii_tx_clk => '0',
      emio_enet3_gmii_tx_en => NLW_inst_emio_enet3_gmii_tx_en_UNCONNECTED,
      emio_enet3_gmii_tx_er => NLW_inst_emio_enet3_gmii_tx_er_UNCONNECTED,
      emio_enet3_gmii_txd(7 downto 0) => NLW_inst_emio_enet3_gmii_txd_UNCONNECTED(7 downto 0),
      emio_enet3_mdio_i => '0',
      emio_enet3_mdio_mdc => NLW_inst_emio_enet3_mdio_mdc_UNCONNECTED,
      emio_enet3_mdio_o => NLW_inst_emio_enet3_mdio_o_UNCONNECTED,
      emio_enet3_mdio_t => NLW_inst_emio_enet3_mdio_t_UNCONNECTED,
      emio_enet3_mdio_t_n => NLW_inst_emio_enet3_mdio_t_n_UNCONNECTED,
      emio_enet3_pdelay_req_rx => NLW_inst_emio_enet3_pdelay_req_rx_UNCONNECTED,
      emio_enet3_pdelay_req_tx => NLW_inst_emio_enet3_pdelay_req_tx_UNCONNECTED,
      emio_enet3_pdelay_resp_rx => NLW_inst_emio_enet3_pdelay_resp_rx_UNCONNECTED,
      emio_enet3_pdelay_resp_tx => NLW_inst_emio_enet3_pdelay_resp_tx_UNCONNECTED,
      emio_enet3_rx_sof => NLW_inst_emio_enet3_rx_sof_UNCONNECTED,
      emio_enet3_rx_w_data(7 downto 0) => NLW_inst_emio_enet3_rx_w_data_UNCONNECTED(7 downto 0),
      emio_enet3_rx_w_eop => NLW_inst_emio_enet3_rx_w_eop_UNCONNECTED,
      emio_enet3_rx_w_err => NLW_inst_emio_enet3_rx_w_err_UNCONNECTED,
      emio_enet3_rx_w_flush => NLW_inst_emio_enet3_rx_w_flush_UNCONNECTED,
      emio_enet3_rx_w_overflow => '0',
      emio_enet3_rx_w_sop => NLW_inst_emio_enet3_rx_w_sop_UNCONNECTED,
      emio_enet3_rx_w_status(44 downto 0) => NLW_inst_emio_enet3_rx_w_status_UNCONNECTED(44 downto 0),
      emio_enet3_rx_w_wr => NLW_inst_emio_enet3_rx_w_wr_UNCONNECTED,
      emio_enet3_signal_detect => '0',
      emio_enet3_speed_mode(2 downto 0) => NLW_inst_emio_enet3_speed_mode_UNCONNECTED(2 downto 0),
      emio_enet3_sync_frame_rx => NLW_inst_emio_enet3_sync_frame_rx_UNCONNECTED,
      emio_enet3_sync_frame_tx => NLW_inst_emio_enet3_sync_frame_tx_UNCONNECTED,
      emio_enet3_tsu_inc_ctrl(1 downto 0) => B"00",
      emio_enet3_tsu_timer_cmp_val => NLW_inst_emio_enet3_tsu_timer_cmp_val_UNCONNECTED,
      emio_enet3_tx_r_control => '0',
      emio_enet3_tx_r_data(7 downto 0) => B"00000000",
      emio_enet3_tx_r_data_rdy => '0',
      emio_enet3_tx_r_eop => '1',
      emio_enet3_tx_r_err => '0',
      emio_enet3_tx_r_fixed_lat => NLW_inst_emio_enet3_tx_r_fixed_lat_UNCONNECTED,
      emio_enet3_tx_r_flushed => '0',
      emio_enet3_tx_r_rd => NLW_inst_emio_enet3_tx_r_rd_UNCONNECTED,
      emio_enet3_tx_r_sop => '1',
      emio_enet3_tx_r_status(3 downto 0) => NLW_inst_emio_enet3_tx_r_status_UNCONNECTED(3 downto 0),
      emio_enet3_tx_r_underflow => '0',
      emio_enet3_tx_r_valid => '0',
      emio_enet3_tx_sof => NLW_inst_emio_enet3_tx_sof_UNCONNECTED,
      emio_enet_tsu_clk => '0',
      emio_gpio_i(0) => '0',
      emio_gpio_o(0) => NLW_inst_emio_gpio_o_UNCONNECTED(0),
      emio_gpio_t(0) => NLW_inst_emio_gpio_t_UNCONNECTED(0),
      emio_gpio_t_n(0) => NLW_inst_emio_gpio_t_n_UNCONNECTED(0),
      emio_hub_port_overcrnt_usb2_0 => '0',
      emio_hub_port_overcrnt_usb2_1 => '0',
      emio_hub_port_overcrnt_usb3_0 => '0',
      emio_hub_port_overcrnt_usb3_1 => '0',
      emio_i2c0_scl_i => '0',
      emio_i2c0_scl_o => NLW_inst_emio_i2c0_scl_o_UNCONNECTED,
      emio_i2c0_scl_t => NLW_inst_emio_i2c0_scl_t_UNCONNECTED,
      emio_i2c0_scl_t_n => NLW_inst_emio_i2c0_scl_t_n_UNCONNECTED,
      emio_i2c0_sda_i => '0',
      emio_i2c0_sda_o => NLW_inst_emio_i2c0_sda_o_UNCONNECTED,
      emio_i2c0_sda_t => NLW_inst_emio_i2c0_sda_t_UNCONNECTED,
      emio_i2c0_sda_t_n => NLW_inst_emio_i2c0_sda_t_n_UNCONNECTED,
      emio_i2c1_scl_i => '0',
      emio_i2c1_scl_o => NLW_inst_emio_i2c1_scl_o_UNCONNECTED,
      emio_i2c1_scl_t => NLW_inst_emio_i2c1_scl_t_UNCONNECTED,
      emio_i2c1_scl_t_n => NLW_inst_emio_i2c1_scl_t_n_UNCONNECTED,
      emio_i2c1_sda_i => '0',
      emio_i2c1_sda_o => NLW_inst_emio_i2c1_sda_o_UNCONNECTED,
      emio_i2c1_sda_t => NLW_inst_emio_i2c1_sda_t_UNCONNECTED,
      emio_i2c1_sda_t_n => NLW_inst_emio_i2c1_sda_t_n_UNCONNECTED,
      emio_sdio0_bus_volt(2 downto 0) => NLW_inst_emio_sdio0_bus_volt_UNCONNECTED(2 downto 0),
      emio_sdio0_buspower => NLW_inst_emio_sdio0_buspower_UNCONNECTED,
      emio_sdio0_cd_n => '0',
      emio_sdio0_clkout => NLW_inst_emio_sdio0_clkout_UNCONNECTED,
      emio_sdio0_cmdena => NLW_inst_emio_sdio0_cmdena_UNCONNECTED,
      emio_sdio0_cmdin => '0',
      emio_sdio0_cmdout => NLW_inst_emio_sdio0_cmdout_UNCONNECTED,
      emio_sdio0_dataena(7 downto 0) => NLW_inst_emio_sdio0_dataena_UNCONNECTED(7 downto 0),
      emio_sdio0_datain(7 downto 0) => B"00000000",
      emio_sdio0_dataout(7 downto 0) => NLW_inst_emio_sdio0_dataout_UNCONNECTED(7 downto 0),
      emio_sdio0_fb_clk_in => '0',
      emio_sdio0_ledcontrol => NLW_inst_emio_sdio0_ledcontrol_UNCONNECTED,
      emio_sdio0_wp => '1',
      emio_sdio1_bus_volt(2 downto 0) => NLW_inst_emio_sdio1_bus_volt_UNCONNECTED(2 downto 0),
      emio_sdio1_buspower => NLW_inst_emio_sdio1_buspower_UNCONNECTED,
      emio_sdio1_cd_n => '0',
      emio_sdio1_clkout => NLW_inst_emio_sdio1_clkout_UNCONNECTED,
      emio_sdio1_cmdena => NLW_inst_emio_sdio1_cmdena_UNCONNECTED,
      emio_sdio1_cmdin => '0',
      emio_sdio1_cmdout => NLW_inst_emio_sdio1_cmdout_UNCONNECTED,
      emio_sdio1_dataena(7 downto 0) => NLW_inst_emio_sdio1_dataena_UNCONNECTED(7 downto 0),
      emio_sdio1_datain(7 downto 0) => B"00000000",
      emio_sdio1_dataout(7 downto 0) => NLW_inst_emio_sdio1_dataout_UNCONNECTED(7 downto 0),
      emio_sdio1_fb_clk_in => '0',
      emio_sdio1_ledcontrol => NLW_inst_emio_sdio1_ledcontrol_UNCONNECTED,
      emio_sdio1_wp => '1',
      emio_spi0_m_i => '0',
      emio_spi0_m_o => NLW_inst_emio_spi0_m_o_UNCONNECTED,
      emio_spi0_mo_t => NLW_inst_emio_spi0_mo_t_UNCONNECTED,
      emio_spi0_mo_t_n => NLW_inst_emio_spi0_mo_t_n_UNCONNECTED,
      emio_spi0_s_i => '0',
      emio_spi0_s_o => NLW_inst_emio_spi0_s_o_UNCONNECTED,
      emio_spi0_sclk_i => '0',
      emio_spi0_sclk_o => NLW_inst_emio_spi0_sclk_o_UNCONNECTED,
      emio_spi0_sclk_t => NLW_inst_emio_spi0_sclk_t_UNCONNECTED,
      emio_spi0_sclk_t_n => NLW_inst_emio_spi0_sclk_t_n_UNCONNECTED,
      emio_spi0_so_t => NLW_inst_emio_spi0_so_t_UNCONNECTED,
      emio_spi0_so_t_n => NLW_inst_emio_spi0_so_t_n_UNCONNECTED,
      emio_spi0_ss1_o_n => NLW_inst_emio_spi0_ss1_o_n_UNCONNECTED,
      emio_spi0_ss2_o_n => NLW_inst_emio_spi0_ss2_o_n_UNCONNECTED,
      emio_spi0_ss_i_n => '1',
      emio_spi0_ss_n_t => NLW_inst_emio_spi0_ss_n_t_UNCONNECTED,
      emio_spi0_ss_n_t_n => NLW_inst_emio_spi0_ss_n_t_n_UNCONNECTED,
      emio_spi0_ss_o_n => NLW_inst_emio_spi0_ss_o_n_UNCONNECTED,
      emio_spi1_m_i => '0',
      emio_spi1_m_o => NLW_inst_emio_spi1_m_o_UNCONNECTED,
      emio_spi1_mo_t => NLW_inst_emio_spi1_mo_t_UNCONNECTED,
      emio_spi1_mo_t_n => NLW_inst_emio_spi1_mo_t_n_UNCONNECTED,
      emio_spi1_s_i => '0',
      emio_spi1_s_o => NLW_inst_emio_spi1_s_o_UNCONNECTED,
      emio_spi1_sclk_i => '0',
      emio_spi1_sclk_o => NLW_inst_emio_spi1_sclk_o_UNCONNECTED,
      emio_spi1_sclk_t => NLW_inst_emio_spi1_sclk_t_UNCONNECTED,
      emio_spi1_sclk_t_n => NLW_inst_emio_spi1_sclk_t_n_UNCONNECTED,
      emio_spi1_so_t => NLW_inst_emio_spi1_so_t_UNCONNECTED,
      emio_spi1_so_t_n => NLW_inst_emio_spi1_so_t_n_UNCONNECTED,
      emio_spi1_ss1_o_n => NLW_inst_emio_spi1_ss1_o_n_UNCONNECTED,
      emio_spi1_ss2_o_n => NLW_inst_emio_spi1_ss2_o_n_UNCONNECTED,
      emio_spi1_ss_i_n => '1',
      emio_spi1_ss_n_t => NLW_inst_emio_spi1_ss_n_t_UNCONNECTED,
      emio_spi1_ss_n_t_n => NLW_inst_emio_spi1_ss_n_t_n_UNCONNECTED,
      emio_spi1_ss_o_n => NLW_inst_emio_spi1_ss_o_n_UNCONNECTED,
      emio_ttc0_clk_i(2 downto 0) => B"000",
      emio_ttc0_wave_o(2 downto 0) => NLW_inst_emio_ttc0_wave_o_UNCONNECTED(2 downto 0),
      emio_ttc1_clk_i(2 downto 0) => B"000",
      emio_ttc1_wave_o(2 downto 0) => NLW_inst_emio_ttc1_wave_o_UNCONNECTED(2 downto 0),
      emio_ttc2_clk_i(2 downto 0) => B"000",
      emio_ttc2_wave_o(2 downto 0) => NLW_inst_emio_ttc2_wave_o_UNCONNECTED(2 downto 0),
      emio_ttc3_clk_i(2 downto 0) => B"000",
      emio_ttc3_wave_o(2 downto 0) => NLW_inst_emio_ttc3_wave_o_UNCONNECTED(2 downto 0),
      emio_u2dsport_vbus_ctrl_usb3_0 => NLW_inst_emio_u2dsport_vbus_ctrl_usb3_0_UNCONNECTED,
      emio_u2dsport_vbus_ctrl_usb3_1 => NLW_inst_emio_u2dsport_vbus_ctrl_usb3_1_UNCONNECTED,
      emio_u3dsport_vbus_ctrl_usb3_0 => NLW_inst_emio_u3dsport_vbus_ctrl_usb3_0_UNCONNECTED,
      emio_u3dsport_vbus_ctrl_usb3_1 => NLW_inst_emio_u3dsport_vbus_ctrl_usb3_1_UNCONNECTED,
      emio_uart0_ctsn => '0',
      emio_uart0_dcdn => '0',
      emio_uart0_dsrn => '0',
      emio_uart0_dtrn => NLW_inst_emio_uart0_dtrn_UNCONNECTED,
      emio_uart0_rin => '0',
      emio_uart0_rtsn => NLW_inst_emio_uart0_rtsn_UNCONNECTED,
      emio_uart0_rxd => '0',
      emio_uart0_txd => NLW_inst_emio_uart0_txd_UNCONNECTED,
      emio_uart1_ctsn => '0',
      emio_uart1_dcdn => '0',
      emio_uart1_dsrn => '0',
      emio_uart1_dtrn => NLW_inst_emio_uart1_dtrn_UNCONNECTED,
      emio_uart1_rin => '0',
      emio_uart1_rtsn => NLW_inst_emio_uart1_rtsn_UNCONNECTED,
      emio_uart1_rxd => '0',
      emio_uart1_txd => NLW_inst_emio_uart1_txd_UNCONNECTED,
      emio_wdt0_clk_i => '0',
      emio_wdt0_rst_o => NLW_inst_emio_wdt0_rst_o_UNCONNECTED,
      emio_wdt1_clk_i => '0',
      emio_wdt1_rst_o => NLW_inst_emio_wdt1_rst_o_UNCONNECTED,
      fmio_char_afifsfpd_test_input => '0',
      fmio_char_afifsfpd_test_output => NLW_inst_fmio_char_afifsfpd_test_output_UNCONNECTED,
      fmio_char_afifsfpd_test_select_n => '0',
      fmio_char_afifslpd_test_input => '0',
      fmio_char_afifslpd_test_output => NLW_inst_fmio_char_afifslpd_test_output_UNCONNECTED,
      fmio_char_afifslpd_test_select_n => '0',
      fmio_char_gem_selection(1 downto 0) => B"00",
      fmio_char_gem_test_input => '0',
      fmio_char_gem_test_output => NLW_inst_fmio_char_gem_test_output_UNCONNECTED,
      fmio_char_gem_test_select_n => '0',
      fmio_gem0_fifo_rx_clk_to_pl_bufg => NLW_inst_fmio_gem0_fifo_rx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem0_fifo_tx_clk_to_pl_bufg => NLW_inst_fmio_gem0_fifo_tx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem1_fifo_rx_clk_to_pl_bufg => NLW_inst_fmio_gem1_fifo_rx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem1_fifo_tx_clk_to_pl_bufg => NLW_inst_fmio_gem1_fifo_tx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem2_fifo_rx_clk_to_pl_bufg => NLW_inst_fmio_gem2_fifo_rx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem2_fifo_tx_clk_to_pl_bufg => NLW_inst_fmio_gem2_fifo_tx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem3_fifo_rx_clk_to_pl_bufg => NLW_inst_fmio_gem3_fifo_rx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem3_fifo_tx_clk_to_pl_bufg => NLW_inst_fmio_gem3_fifo_tx_clk_to_pl_bufg_UNCONNECTED,
      fmio_gem_tsu_clk_from_pl => '0',
      fmio_gem_tsu_clk_to_pl_bufg => NLW_inst_fmio_gem_tsu_clk_to_pl_bufg_UNCONNECTED,
      fmio_sd0_dll_test_in_n(3 downto 0) => B"0000",
      fmio_sd0_dll_test_out(7 downto 0) => NLW_inst_fmio_sd0_dll_test_out_UNCONNECTED(7 downto 0),
      fmio_sd1_dll_test_in_n(3 downto 0) => B"0000",
      fmio_sd1_dll_test_out(7 downto 0) => NLW_inst_fmio_sd1_dll_test_out_UNCONNECTED(7 downto 0),
      fmio_test_gem_scanmux_1 => '0',
      fmio_test_gem_scanmux_2 => '0',
      fmio_test_io_char_scan_clock => '0',
      fmio_test_io_char_scan_in => '0',
      fmio_test_io_char_scan_out => NLW_inst_fmio_test_io_char_scan_out_UNCONNECTED,
      fmio_test_io_char_scan_reset_n => '0',
      fmio_test_io_char_scanenable => '0',
      fmio_test_qspi_scanmux_1_n => '0',
      fmio_test_sdio_scanmux_1 => '0',
      fmio_test_sdio_scanmux_2 => '0',
      fpd_pl_spare_0_out => NLW_inst_fpd_pl_spare_0_out_UNCONNECTED,
      fpd_pl_spare_1_out => NLW_inst_fpd_pl_spare_1_out_UNCONNECTED,
      fpd_pl_spare_2_out => NLW_inst_fpd_pl_spare_2_out_UNCONNECTED,
      fpd_pl_spare_3_out => NLW_inst_fpd_pl_spare_3_out_UNCONNECTED,
      fpd_pl_spare_4_out => NLW_inst_fpd_pl_spare_4_out_UNCONNECTED,
      fpd_pll_test_out(31 downto 0) => NLW_inst_fpd_pll_test_out_UNCONNECTED(31 downto 0),
      ftm_gpi(31 downto 0) => B"00000000000000000000000000000000",
      ftm_gpo(31 downto 0) => NLW_inst_ftm_gpo_UNCONNECTED(31 downto 0),
      gdma_perif_cack(7 downto 0) => NLW_inst_gdma_perif_cack_UNCONNECTED(7 downto 0),
      gdma_perif_tvld(7 downto 0) => NLW_inst_gdma_perif_tvld_UNCONNECTED(7 downto 0),
      i_afe_TX_LPBK_SEL(2 downto 0) => B"000",
      i_afe_TX_ana_if_rate(1 downto 0) => B"00",
      i_afe_TX_en_dig_sublp_mode => '0',
      i_afe_TX_iso_ctrl_bar => '0',
      i_afe_TX_lfps_clk => '0',
      i_afe_TX_pll_symb_clk_2 => '0',
      i_afe_TX_pmadig_digital_reset_n => '0',
      i_afe_TX_ser_iso_ctrl_bar => '0',
      i_afe_TX_serializer_rst_rel => '0',
      i_afe_TX_serializer_rstb => '0',
      i_afe_TX_uphy_txpma_opmode(7 downto 0) => B"00000000",
      i_afe_cmn_bg_enable_low_leakage => '0',
      i_afe_cmn_bg_iso_ctrl_bar => '0',
      i_afe_cmn_bg_pd => '0',
      i_afe_cmn_bg_pd_bg_ok => '0',
      i_afe_cmn_bg_pd_ptat => '0',
      i_afe_cmn_calib_en_iconst => '0',
      i_afe_cmn_calib_enable_low_leakage => '0',
      i_afe_cmn_calib_iso_ctrl_bar => '0',
      i_afe_mode => '0',
      i_afe_pll_coarse_code(10 downto 0) => B"00000000000",
      i_afe_pll_en_clock_hs_div2 => '0',
      i_afe_pll_fbdiv(15 downto 0) => B"0000000000000000",
      i_afe_pll_load_fbdiv => '0',
      i_afe_pll_pd => '0',
      i_afe_pll_pd_hs_clock_r => '0',
      i_afe_pll_pd_pfd => '0',
      i_afe_pll_rst_fdbk_div => '0',
      i_afe_pll_startloop => '0',
      i_afe_pll_v2i_code(5 downto 0) => B"000000",
      i_afe_pll_v2i_prog(4 downto 0) => B"00000",
      i_afe_pll_vco_cnt_window => '0',
      i_afe_rx_hsrx_clock_stop_req => '0',
      i_afe_rx_iso_hsrx_ctrl_bar => '0',
      i_afe_rx_iso_lfps_ctrl_bar => '0',
      i_afe_rx_iso_sigdet_ctrl_bar => '0',
      i_afe_rx_mphy_gate_symbol_clk => '0',
      i_afe_rx_mphy_mux_hsb_ls => '0',
      i_afe_rx_pipe_rx_term_enable => '0',
      i_afe_rx_pipe_rxeqtraining => '0',
      i_afe_rx_rxpma_refclk_dig => '0',
      i_afe_rx_rxpma_rstb => '0',
      i_afe_rx_symbol_clk_by_2_pl => '0',
      i_afe_rx_uphy_biasgen_iconst_core_mirror_enable => '0',
      i_afe_rx_uphy_biasgen_iconst_io_mirror_enable => '0',
      i_afe_rx_uphy_biasgen_irconst_core_mirror_enable => '0',
      i_afe_rx_uphy_enable_cdr => '0',
      i_afe_rx_uphy_enable_low_leakage => '0',
      i_afe_rx_uphy_hsclk_division_factor(1 downto 0) => B"00",
      i_afe_rx_uphy_hsrx_rstb => '0',
      i_afe_rx_uphy_pd_samp_c2c => '0',
      i_afe_rx_uphy_pd_samp_c2c_eclk => '0',
      i_afe_rx_uphy_pdn_hs_des => '0',
      i_afe_rx_uphy_pso_clk_lane => '0',
      i_afe_rx_uphy_pso_eq => '0',
      i_afe_rx_uphy_pso_hsrxdig => '0',
      i_afe_rx_uphy_pso_iqpi => '0',
      i_afe_rx_uphy_pso_lfpsbcn => '0',
      i_afe_rx_uphy_pso_samp_flops => '0',
      i_afe_rx_uphy_pso_sigdet => '0',
      i_afe_rx_uphy_restore_calcode => '0',
      i_afe_rx_uphy_restore_calcode_data(7 downto 0) => B"00000000",
      i_afe_rx_uphy_run_calib => '0',
      i_afe_rx_uphy_rx_lane_polarity_swap => '0',
      i_afe_rx_uphy_rx_pma_opmode(7 downto 0) => B"00000000",
      i_afe_rx_uphy_startloop_pll => '0',
      i_afe_tx_enable_hsclk_division(1 downto 0) => B"00",
      i_afe_tx_enable_ldo => '0',
      i_afe_tx_enable_ref => '0',
      i_afe_tx_enable_supply_hsclk => '0',
      i_afe_tx_enable_supply_pipe => '0',
      i_afe_tx_enable_supply_serializer => '0',
      i_afe_tx_enable_supply_uphy => '0',
      i_afe_tx_hs_ser_rstb => '0',
      i_afe_tx_hs_symbol(19 downto 0) => B"00000000000000000000",
      i_afe_tx_mphy_tx_ls_data => '0',
      i_afe_tx_pipe_tx_enable_idle_mode(1 downto 0) => B"00",
      i_afe_tx_pipe_tx_enable_lfps(1 downto 0) => B"00",
      i_afe_tx_pipe_tx_enable_rxdet => '0',
      i_afe_tx_pipe_tx_fast_est_common_mode => '0',
      i_bgcal_afe_mode => '0',
      i_dbg_l0_rxclk => '0',
      i_dbg_l0_txclk => '0',
      i_dbg_l1_rxclk => '0',
      i_dbg_l1_txclk => '0',
      i_dbg_l2_rxclk => '0',
      i_dbg_l2_txclk => '0',
      i_dbg_l3_rxclk => '0',
      i_dbg_l3_txclk => '0',
      i_pll_afe_mode => '0',
      io_char_audio_in_test_data => '0',
      io_char_audio_mux_sel_n => '0',
      io_char_audio_out_test_data => NLW_inst_io_char_audio_out_test_data_UNCONNECTED,
      io_char_video_in_test_data => '0',
      io_char_video_mux_sel_n => '0',
      io_char_video_out_test_data => NLW_inst_io_char_video_out_test_data_UNCONNECTED,
      irq_ipi_pl_0 => NLW_inst_irq_ipi_pl_0_UNCONNECTED,
      irq_ipi_pl_1 => NLW_inst_irq_ipi_pl_1_UNCONNECTED,
      irq_ipi_pl_2 => NLW_inst_irq_ipi_pl_2_UNCONNECTED,
      irq_ipi_pl_3 => NLW_inst_irq_ipi_pl_3_UNCONNECTED,
      lpd_pl_spare_0_out => NLW_inst_lpd_pl_spare_0_out_UNCONNECTED,
      lpd_pl_spare_1_out => NLW_inst_lpd_pl_spare_1_out_UNCONNECTED,
      lpd_pl_spare_2_out => NLW_inst_lpd_pl_spare_2_out_UNCONNECTED,
      lpd_pl_spare_3_out => NLW_inst_lpd_pl_spare_3_out_UNCONNECTED,
      lpd_pl_spare_4_out => NLW_inst_lpd_pl_spare_4_out_UNCONNECTED,
      lpd_pll_test_out(31 downto 0) => NLW_inst_lpd_pll_test_out_UNCONNECTED(31 downto 0),
      maxigp0_araddr(39 downto 0) => maxigp0_araddr(39 downto 0),
      maxigp0_arburst(1 downto 0) => maxigp0_arburst(1 downto 0),
      maxigp0_arcache(3 downto 0) => maxigp0_arcache(3 downto 0),
      maxigp0_arid(15 downto 0) => maxigp0_arid(15 downto 0),
      maxigp0_arlen(7 downto 0) => maxigp0_arlen(7 downto 0),
      maxigp0_arlock => maxigp0_arlock,
      maxigp0_arprot(2 downto 0) => maxigp0_arprot(2 downto 0),
      maxigp0_arqos(3 downto 0) => maxigp0_arqos(3 downto 0),
      maxigp0_arready => maxigp0_arready,
      maxigp0_arsize(2 downto 0) => maxigp0_arsize(2 downto 0),
      maxigp0_aruser(15 downto 0) => maxigp0_aruser(15 downto 0),
      maxigp0_arvalid => maxigp0_arvalid,
      maxigp0_awaddr(39 downto 0) => maxigp0_awaddr(39 downto 0),
      maxigp0_awburst(1 downto 0) => maxigp0_awburst(1 downto 0),
      maxigp0_awcache(3 downto 0) => maxigp0_awcache(3 downto 0),
      maxigp0_awid(15 downto 0) => maxigp0_awid(15 downto 0),
      maxigp0_awlen(7 downto 0) => maxigp0_awlen(7 downto 0),
      maxigp0_awlock => maxigp0_awlock,
      maxigp0_awprot(2 downto 0) => maxigp0_awprot(2 downto 0),
      maxigp0_awqos(3 downto 0) => maxigp0_awqos(3 downto 0),
      maxigp0_awready => maxigp0_awready,
      maxigp0_awsize(2 downto 0) => maxigp0_awsize(2 downto 0),
      maxigp0_awuser(15 downto 0) => maxigp0_awuser(15 downto 0),
      maxigp0_awvalid => maxigp0_awvalid,
      maxigp0_bid(15 downto 0) => maxigp0_bid(15 downto 0),
      maxigp0_bready => maxigp0_bready,
      maxigp0_bresp(1 downto 0) => maxigp0_bresp(1 downto 0),
      maxigp0_bvalid => maxigp0_bvalid,
      maxigp0_rdata(31 downto 0) => maxigp0_rdata(31 downto 0),
      maxigp0_rid(15 downto 0) => maxigp0_rid(15 downto 0),
      maxigp0_rlast => maxigp0_rlast,
      maxigp0_rready => maxigp0_rready,
      maxigp0_rresp(1 downto 0) => maxigp0_rresp(1 downto 0),
      maxigp0_rvalid => maxigp0_rvalid,
      maxigp0_wdata(31 downto 0) => maxigp0_wdata(31 downto 0),
      maxigp0_wlast => maxigp0_wlast,
      maxigp0_wready => maxigp0_wready,
      maxigp0_wstrb(3 downto 0) => maxigp0_wstrb(3 downto 0),
      maxigp0_wvalid => maxigp0_wvalid,
      maxigp1_araddr(39 downto 0) => maxigp1_araddr(39 downto 0),
      maxigp1_arburst(1 downto 0) => maxigp1_arburst(1 downto 0),
      maxigp1_arcache(3 downto 0) => maxigp1_arcache(3 downto 0),
      maxigp1_arid(15 downto 0) => maxigp1_arid(15 downto 0),
      maxigp1_arlen(7 downto 0) => maxigp1_arlen(7 downto 0),
      maxigp1_arlock => maxigp1_arlock,
      maxigp1_arprot(2 downto 0) => maxigp1_arprot(2 downto 0),
      maxigp1_arqos(3 downto 0) => maxigp1_arqos(3 downto 0),
      maxigp1_arready => maxigp1_arready,
      maxigp1_arsize(2 downto 0) => maxigp1_arsize(2 downto 0),
      maxigp1_aruser(15 downto 0) => maxigp1_aruser(15 downto 0),
      maxigp1_arvalid => maxigp1_arvalid,
      maxigp1_awaddr(39 downto 0) => maxigp1_awaddr(39 downto 0),
      maxigp1_awburst(1 downto 0) => maxigp1_awburst(1 downto 0),
      maxigp1_awcache(3 downto 0) => maxigp1_awcache(3 downto 0),
      maxigp1_awid(15 downto 0) => maxigp1_awid(15 downto 0),
      maxigp1_awlen(7 downto 0) => maxigp1_awlen(7 downto 0),
      maxigp1_awlock => maxigp1_awlock,
      maxigp1_awprot(2 downto 0) => maxigp1_awprot(2 downto 0),
      maxigp1_awqos(3 downto 0) => maxigp1_awqos(3 downto 0),
      maxigp1_awready => maxigp1_awready,
      maxigp1_awsize(2 downto 0) => maxigp1_awsize(2 downto 0),
      maxigp1_awuser(15 downto 0) => maxigp1_awuser(15 downto 0),
      maxigp1_awvalid => maxigp1_awvalid,
      maxigp1_bid(15 downto 0) => maxigp1_bid(15 downto 0),
      maxigp1_bready => maxigp1_bready,
      maxigp1_bresp(1 downto 0) => maxigp1_bresp(1 downto 0),
      maxigp1_bvalid => maxigp1_bvalid,
      maxigp1_rdata(31 downto 0) => maxigp1_rdata(31 downto 0),
      maxigp1_rid(15 downto 0) => maxigp1_rid(15 downto 0),
      maxigp1_rlast => maxigp1_rlast,
      maxigp1_rready => maxigp1_rready,
      maxigp1_rresp(1 downto 0) => maxigp1_rresp(1 downto 0),
      maxigp1_rvalid => maxigp1_rvalid,
      maxigp1_wdata(31 downto 0) => maxigp1_wdata(31 downto 0),
      maxigp1_wlast => maxigp1_wlast,
      maxigp1_wready => maxigp1_wready,
      maxigp1_wstrb(3 downto 0) => maxigp1_wstrb(3 downto 0),
      maxigp1_wvalid => maxigp1_wvalid,
      maxigp2_araddr(39 downto 0) => NLW_inst_maxigp2_araddr_UNCONNECTED(39 downto 0),
      maxigp2_arburst(1 downto 0) => NLW_inst_maxigp2_arburst_UNCONNECTED(1 downto 0),
      maxigp2_arcache(3 downto 0) => NLW_inst_maxigp2_arcache_UNCONNECTED(3 downto 0),
      maxigp2_arid(15 downto 0) => NLW_inst_maxigp2_arid_UNCONNECTED(15 downto 0),
      maxigp2_arlen(7 downto 0) => NLW_inst_maxigp2_arlen_UNCONNECTED(7 downto 0),
      maxigp2_arlock => NLW_inst_maxigp2_arlock_UNCONNECTED,
      maxigp2_arprot(2 downto 0) => NLW_inst_maxigp2_arprot_UNCONNECTED(2 downto 0),
      maxigp2_arqos(3 downto 0) => NLW_inst_maxigp2_arqos_UNCONNECTED(3 downto 0),
      maxigp2_arready => '0',
      maxigp2_arsize(2 downto 0) => NLW_inst_maxigp2_arsize_UNCONNECTED(2 downto 0),
      maxigp2_aruser(15 downto 0) => NLW_inst_maxigp2_aruser_UNCONNECTED(15 downto 0),
      maxigp2_arvalid => NLW_inst_maxigp2_arvalid_UNCONNECTED,
      maxigp2_awaddr(39 downto 0) => NLW_inst_maxigp2_awaddr_UNCONNECTED(39 downto 0),
      maxigp2_awburst(1 downto 0) => NLW_inst_maxigp2_awburst_UNCONNECTED(1 downto 0),
      maxigp2_awcache(3 downto 0) => NLW_inst_maxigp2_awcache_UNCONNECTED(3 downto 0),
      maxigp2_awid(15 downto 0) => NLW_inst_maxigp2_awid_UNCONNECTED(15 downto 0),
      maxigp2_awlen(7 downto 0) => NLW_inst_maxigp2_awlen_UNCONNECTED(7 downto 0),
      maxigp2_awlock => NLW_inst_maxigp2_awlock_UNCONNECTED,
      maxigp2_awprot(2 downto 0) => NLW_inst_maxigp2_awprot_UNCONNECTED(2 downto 0),
      maxigp2_awqos(3 downto 0) => NLW_inst_maxigp2_awqos_UNCONNECTED(3 downto 0),
      maxigp2_awready => '0',
      maxigp2_awsize(2 downto 0) => NLW_inst_maxigp2_awsize_UNCONNECTED(2 downto 0),
      maxigp2_awuser(15 downto 0) => NLW_inst_maxigp2_awuser_UNCONNECTED(15 downto 0),
      maxigp2_awvalid => NLW_inst_maxigp2_awvalid_UNCONNECTED,
      maxigp2_bid(15 downto 0) => B"0000000000000000",
      maxigp2_bready => NLW_inst_maxigp2_bready_UNCONNECTED,
      maxigp2_bresp(1 downto 0) => B"00",
      maxigp2_bvalid => '0',
      maxigp2_rdata(31 downto 0) => B"00000000000000000000000000000000",
      maxigp2_rid(15 downto 0) => B"0000000000000000",
      maxigp2_rlast => '0',
      maxigp2_rready => NLW_inst_maxigp2_rready_UNCONNECTED,
      maxigp2_rresp(1 downto 0) => B"00",
      maxigp2_rvalid => '0',
      maxigp2_wdata(31 downto 0) => NLW_inst_maxigp2_wdata_UNCONNECTED(31 downto 0),
      maxigp2_wlast => NLW_inst_maxigp2_wlast_UNCONNECTED,
      maxigp2_wready => '0',
      maxigp2_wstrb(3 downto 0) => NLW_inst_maxigp2_wstrb_UNCONNECTED(3 downto 0),
      maxigp2_wvalid => NLW_inst_maxigp2_wvalid_UNCONNECTED,
      maxihpm0_fpd_aclk => maxihpm0_fpd_aclk,
      maxihpm0_lpd_aclk => '0',
      maxihpm1_fpd_aclk => maxihpm1_fpd_aclk,
      nfiq0_lpd_rpu => '1',
      nfiq1_lpd_rpu => '1',
      nirq0_lpd_rpu => '1',
      nirq1_lpd_rpu => '1',
      o_afe_TX_dig_reset_rel_ack => NLW_inst_o_afe_TX_dig_reset_rel_ack_UNCONNECTED,
      o_afe_TX_pipe_TX_dn_rxdet => NLW_inst_o_afe_TX_pipe_TX_dn_rxdet_UNCONNECTED,
      o_afe_TX_pipe_TX_dp_rxdet => NLW_inst_o_afe_TX_pipe_TX_dp_rxdet_UNCONNECTED,
      o_afe_cmn_calib_comp_out => NLW_inst_o_afe_cmn_calib_comp_out_UNCONNECTED,
      o_afe_pg_avddcr => NLW_inst_o_afe_pg_avddcr_UNCONNECTED,
      o_afe_pg_avddio => NLW_inst_o_afe_pg_avddio_UNCONNECTED,
      o_afe_pg_dvddcr => NLW_inst_o_afe_pg_dvddcr_UNCONNECTED,
      o_afe_pg_static_avddcr => NLW_inst_o_afe_pg_static_avddcr_UNCONNECTED,
      o_afe_pg_static_avddio => NLW_inst_o_afe_pg_static_avddio_UNCONNECTED,
      o_afe_pll_clk_sym_hs => NLW_inst_o_afe_pll_clk_sym_hs_UNCONNECTED,
      o_afe_pll_dco_count(12 downto 0) => NLW_inst_o_afe_pll_dco_count_UNCONNECTED(12 downto 0),
      o_afe_pll_fbclk_frac => NLW_inst_o_afe_pll_fbclk_frac_UNCONNECTED,
      o_afe_rx_hsrx_clock_stop_ack => NLW_inst_o_afe_rx_hsrx_clock_stop_ack_UNCONNECTED,
      o_afe_rx_pipe_lfpsbcn_rxelecidle => NLW_inst_o_afe_rx_pipe_lfpsbcn_rxelecidle_UNCONNECTED,
      o_afe_rx_pipe_sigdet => NLW_inst_o_afe_rx_pipe_sigdet_UNCONNECTED,
      o_afe_rx_symbol(19 downto 0) => NLW_inst_o_afe_rx_symbol_UNCONNECTED(19 downto 0),
      o_afe_rx_symbol_clk_by_2 => NLW_inst_o_afe_rx_symbol_clk_by_2_UNCONNECTED,
      o_afe_rx_uphy_rx_calib_done => NLW_inst_o_afe_rx_uphy_rx_calib_done_UNCONNECTED,
      o_afe_rx_uphy_save_calcode => NLW_inst_o_afe_rx_uphy_save_calcode_UNCONNECTED,
      o_afe_rx_uphy_save_calcode_data(7 downto 0) => NLW_inst_o_afe_rx_uphy_save_calcode_data_UNCONNECTED(7 downto 0),
      o_afe_rx_uphy_startloop_buf => NLW_inst_o_afe_rx_uphy_startloop_buf_UNCONNECTED,
      o_dbg_l0_phystatus => NLW_inst_o_dbg_l0_phystatus_UNCONNECTED,
      o_dbg_l0_powerdown(1 downto 0) => NLW_inst_o_dbg_l0_powerdown_UNCONNECTED(1 downto 0),
      o_dbg_l0_rate(1 downto 0) => NLW_inst_o_dbg_l0_rate_UNCONNECTED(1 downto 0),
      o_dbg_l0_rstb => NLW_inst_o_dbg_l0_rstb_UNCONNECTED,
      o_dbg_l0_rx_sgmii_en_cdet => NLW_inst_o_dbg_l0_rx_sgmii_en_cdet_UNCONNECTED,
      o_dbg_l0_rxclk => NLW_inst_o_dbg_l0_rxclk_UNCONNECTED,
      o_dbg_l0_rxdata(19 downto 0) => NLW_inst_o_dbg_l0_rxdata_UNCONNECTED(19 downto 0),
      o_dbg_l0_rxdatak(1 downto 0) => NLW_inst_o_dbg_l0_rxdatak_UNCONNECTED(1 downto 0),
      o_dbg_l0_rxelecidle => NLW_inst_o_dbg_l0_rxelecidle_UNCONNECTED,
      o_dbg_l0_rxpolarity => NLW_inst_o_dbg_l0_rxpolarity_UNCONNECTED,
      o_dbg_l0_rxstatus(2 downto 0) => NLW_inst_o_dbg_l0_rxstatus_UNCONNECTED(2 downto 0),
      o_dbg_l0_rxvalid => NLW_inst_o_dbg_l0_rxvalid_UNCONNECTED,
      o_dbg_l0_sata_coreclockready => NLW_inst_o_dbg_l0_sata_coreclockready_UNCONNECTED,
      o_dbg_l0_sata_coreready => NLW_inst_o_dbg_l0_sata_coreready_UNCONNECTED,
      o_dbg_l0_sata_corerxdata(19 downto 0) => NLW_inst_o_dbg_l0_sata_corerxdata_UNCONNECTED(19 downto 0),
      o_dbg_l0_sata_corerxdatavalid(1 downto 0) => NLW_inst_o_dbg_l0_sata_corerxdatavalid_UNCONNECTED(1 downto 0),
      o_dbg_l0_sata_corerxsignaldet => NLW_inst_o_dbg_l0_sata_corerxsignaldet_UNCONNECTED,
      o_dbg_l0_sata_phyctrlpartial => NLW_inst_o_dbg_l0_sata_phyctrlpartial_UNCONNECTED,
      o_dbg_l0_sata_phyctrlreset => NLW_inst_o_dbg_l0_sata_phyctrlreset_UNCONNECTED,
      o_dbg_l0_sata_phyctrlrxrate(1 downto 0) => NLW_inst_o_dbg_l0_sata_phyctrlrxrate_UNCONNECTED(1 downto 0),
      o_dbg_l0_sata_phyctrlrxrst => NLW_inst_o_dbg_l0_sata_phyctrlrxrst_UNCONNECTED,
      o_dbg_l0_sata_phyctrlslumber => NLW_inst_o_dbg_l0_sata_phyctrlslumber_UNCONNECTED,
      o_dbg_l0_sata_phyctrltxdata(19 downto 0) => NLW_inst_o_dbg_l0_sata_phyctrltxdata_UNCONNECTED(19 downto 0),
      o_dbg_l0_sata_phyctrltxidle => NLW_inst_o_dbg_l0_sata_phyctrltxidle_UNCONNECTED,
      o_dbg_l0_sata_phyctrltxrate(1 downto 0) => NLW_inst_o_dbg_l0_sata_phyctrltxrate_UNCONNECTED(1 downto 0),
      o_dbg_l0_sata_phyctrltxrst => NLW_inst_o_dbg_l0_sata_phyctrltxrst_UNCONNECTED,
      o_dbg_l0_tx_sgmii_ewrap => NLW_inst_o_dbg_l0_tx_sgmii_ewrap_UNCONNECTED,
      o_dbg_l0_txclk => NLW_inst_o_dbg_l0_txclk_UNCONNECTED,
      o_dbg_l0_txdata(19 downto 0) => NLW_inst_o_dbg_l0_txdata_UNCONNECTED(19 downto 0),
      o_dbg_l0_txdatak(1 downto 0) => NLW_inst_o_dbg_l0_txdatak_UNCONNECTED(1 downto 0),
      o_dbg_l0_txdetrx_lpback => NLW_inst_o_dbg_l0_txdetrx_lpback_UNCONNECTED,
      o_dbg_l0_txelecidle => NLW_inst_o_dbg_l0_txelecidle_UNCONNECTED,
      o_dbg_l1_phystatus => NLW_inst_o_dbg_l1_phystatus_UNCONNECTED,
      o_dbg_l1_powerdown(1 downto 0) => NLW_inst_o_dbg_l1_powerdown_UNCONNECTED(1 downto 0),
      o_dbg_l1_rate(1 downto 0) => NLW_inst_o_dbg_l1_rate_UNCONNECTED(1 downto 0),
      o_dbg_l1_rstb => NLW_inst_o_dbg_l1_rstb_UNCONNECTED,
      o_dbg_l1_rx_sgmii_en_cdet => NLW_inst_o_dbg_l1_rx_sgmii_en_cdet_UNCONNECTED,
      o_dbg_l1_rxclk => NLW_inst_o_dbg_l1_rxclk_UNCONNECTED,
      o_dbg_l1_rxdata(19 downto 0) => NLW_inst_o_dbg_l1_rxdata_UNCONNECTED(19 downto 0),
      o_dbg_l1_rxdatak(1 downto 0) => NLW_inst_o_dbg_l1_rxdatak_UNCONNECTED(1 downto 0),
      o_dbg_l1_rxelecidle => NLW_inst_o_dbg_l1_rxelecidle_UNCONNECTED,
      o_dbg_l1_rxpolarity => NLW_inst_o_dbg_l1_rxpolarity_UNCONNECTED,
      o_dbg_l1_rxstatus(2 downto 0) => NLW_inst_o_dbg_l1_rxstatus_UNCONNECTED(2 downto 0),
      o_dbg_l1_rxvalid => NLW_inst_o_dbg_l1_rxvalid_UNCONNECTED,
      o_dbg_l1_sata_coreclockready => NLW_inst_o_dbg_l1_sata_coreclockready_UNCONNECTED,
      o_dbg_l1_sata_coreready => NLW_inst_o_dbg_l1_sata_coreready_UNCONNECTED,
      o_dbg_l1_sata_corerxdata(19 downto 0) => NLW_inst_o_dbg_l1_sata_corerxdata_UNCONNECTED(19 downto 0),
      o_dbg_l1_sata_corerxdatavalid(1 downto 0) => NLW_inst_o_dbg_l1_sata_corerxdatavalid_UNCONNECTED(1 downto 0),
      o_dbg_l1_sata_corerxsignaldet => NLW_inst_o_dbg_l1_sata_corerxsignaldet_UNCONNECTED,
      o_dbg_l1_sata_phyctrlpartial => NLW_inst_o_dbg_l1_sata_phyctrlpartial_UNCONNECTED,
      o_dbg_l1_sata_phyctrlreset => NLW_inst_o_dbg_l1_sata_phyctrlreset_UNCONNECTED,
      o_dbg_l1_sata_phyctrlrxrate(1 downto 0) => NLW_inst_o_dbg_l1_sata_phyctrlrxrate_UNCONNECTED(1 downto 0),
      o_dbg_l1_sata_phyctrlrxrst => NLW_inst_o_dbg_l1_sata_phyctrlrxrst_UNCONNECTED,
      o_dbg_l1_sata_phyctrlslumber => NLW_inst_o_dbg_l1_sata_phyctrlslumber_UNCONNECTED,
      o_dbg_l1_sata_phyctrltxdata(19 downto 0) => NLW_inst_o_dbg_l1_sata_phyctrltxdata_UNCONNECTED(19 downto 0),
      o_dbg_l1_sata_phyctrltxidle => NLW_inst_o_dbg_l1_sata_phyctrltxidle_UNCONNECTED,
      o_dbg_l1_sata_phyctrltxrate(1 downto 0) => NLW_inst_o_dbg_l1_sata_phyctrltxrate_UNCONNECTED(1 downto 0),
      o_dbg_l1_sata_phyctrltxrst => NLW_inst_o_dbg_l1_sata_phyctrltxrst_UNCONNECTED,
      o_dbg_l1_tx_sgmii_ewrap => NLW_inst_o_dbg_l1_tx_sgmii_ewrap_UNCONNECTED,
      o_dbg_l1_txclk => NLW_inst_o_dbg_l1_txclk_UNCONNECTED,
      o_dbg_l1_txdata(19 downto 0) => NLW_inst_o_dbg_l1_txdata_UNCONNECTED(19 downto 0),
      o_dbg_l1_txdatak(1 downto 0) => NLW_inst_o_dbg_l1_txdatak_UNCONNECTED(1 downto 0),
      o_dbg_l1_txdetrx_lpback => NLW_inst_o_dbg_l1_txdetrx_lpback_UNCONNECTED,
      o_dbg_l1_txelecidle => NLW_inst_o_dbg_l1_txelecidle_UNCONNECTED,
      o_dbg_l2_phystatus => NLW_inst_o_dbg_l2_phystatus_UNCONNECTED,
      o_dbg_l2_powerdown(1 downto 0) => NLW_inst_o_dbg_l2_powerdown_UNCONNECTED(1 downto 0),
      o_dbg_l2_rate(1 downto 0) => NLW_inst_o_dbg_l2_rate_UNCONNECTED(1 downto 0),
      o_dbg_l2_rstb => NLW_inst_o_dbg_l2_rstb_UNCONNECTED,
      o_dbg_l2_rx_sgmii_en_cdet => NLW_inst_o_dbg_l2_rx_sgmii_en_cdet_UNCONNECTED,
      o_dbg_l2_rxclk => NLW_inst_o_dbg_l2_rxclk_UNCONNECTED,
      o_dbg_l2_rxdata(19 downto 0) => NLW_inst_o_dbg_l2_rxdata_UNCONNECTED(19 downto 0),
      o_dbg_l2_rxdatak(1 downto 0) => NLW_inst_o_dbg_l2_rxdatak_UNCONNECTED(1 downto 0),
      o_dbg_l2_rxelecidle => NLW_inst_o_dbg_l2_rxelecidle_UNCONNECTED,
      o_dbg_l2_rxpolarity => NLW_inst_o_dbg_l2_rxpolarity_UNCONNECTED,
      o_dbg_l2_rxstatus(2 downto 0) => NLW_inst_o_dbg_l2_rxstatus_UNCONNECTED(2 downto 0),
      o_dbg_l2_rxvalid => NLW_inst_o_dbg_l2_rxvalid_UNCONNECTED,
      o_dbg_l2_sata_coreclockready => NLW_inst_o_dbg_l2_sata_coreclockready_UNCONNECTED,
      o_dbg_l2_sata_coreready => NLW_inst_o_dbg_l2_sata_coreready_UNCONNECTED,
      o_dbg_l2_sata_corerxdata(19 downto 0) => NLW_inst_o_dbg_l2_sata_corerxdata_UNCONNECTED(19 downto 0),
      o_dbg_l2_sata_corerxdatavalid(1 downto 0) => NLW_inst_o_dbg_l2_sata_corerxdatavalid_UNCONNECTED(1 downto 0),
      o_dbg_l2_sata_corerxsignaldet => NLW_inst_o_dbg_l2_sata_corerxsignaldet_UNCONNECTED,
      o_dbg_l2_sata_phyctrlpartial => NLW_inst_o_dbg_l2_sata_phyctrlpartial_UNCONNECTED,
      o_dbg_l2_sata_phyctrlreset => NLW_inst_o_dbg_l2_sata_phyctrlreset_UNCONNECTED,
      o_dbg_l2_sata_phyctrlrxrate(1 downto 0) => NLW_inst_o_dbg_l2_sata_phyctrlrxrate_UNCONNECTED(1 downto 0),
      o_dbg_l2_sata_phyctrlrxrst => NLW_inst_o_dbg_l2_sata_phyctrlrxrst_UNCONNECTED,
      o_dbg_l2_sata_phyctrlslumber => NLW_inst_o_dbg_l2_sata_phyctrlslumber_UNCONNECTED,
      o_dbg_l2_sata_phyctrltxdata(19 downto 0) => NLW_inst_o_dbg_l2_sata_phyctrltxdata_UNCONNECTED(19 downto 0),
      o_dbg_l2_sata_phyctrltxidle => NLW_inst_o_dbg_l2_sata_phyctrltxidle_UNCONNECTED,
      o_dbg_l2_sata_phyctrltxrate(1 downto 0) => NLW_inst_o_dbg_l2_sata_phyctrltxrate_UNCONNECTED(1 downto 0),
      o_dbg_l2_sata_phyctrltxrst => NLW_inst_o_dbg_l2_sata_phyctrltxrst_UNCONNECTED,
      o_dbg_l2_tx_sgmii_ewrap => NLW_inst_o_dbg_l2_tx_sgmii_ewrap_UNCONNECTED,
      o_dbg_l2_txclk => NLW_inst_o_dbg_l2_txclk_UNCONNECTED,
      o_dbg_l2_txdata(19 downto 0) => NLW_inst_o_dbg_l2_txdata_UNCONNECTED(19 downto 0),
      o_dbg_l2_txdatak(1 downto 0) => NLW_inst_o_dbg_l2_txdatak_UNCONNECTED(1 downto 0),
      o_dbg_l2_txdetrx_lpback => NLW_inst_o_dbg_l2_txdetrx_lpback_UNCONNECTED,
      o_dbg_l2_txelecidle => NLW_inst_o_dbg_l2_txelecidle_UNCONNECTED,
      o_dbg_l3_phystatus => NLW_inst_o_dbg_l3_phystatus_UNCONNECTED,
      o_dbg_l3_powerdown(1 downto 0) => NLW_inst_o_dbg_l3_powerdown_UNCONNECTED(1 downto 0),
      o_dbg_l3_rate(1 downto 0) => NLW_inst_o_dbg_l3_rate_UNCONNECTED(1 downto 0),
      o_dbg_l3_rstb => NLW_inst_o_dbg_l3_rstb_UNCONNECTED,
      o_dbg_l3_rx_sgmii_en_cdet => NLW_inst_o_dbg_l3_rx_sgmii_en_cdet_UNCONNECTED,
      o_dbg_l3_rxclk => NLW_inst_o_dbg_l3_rxclk_UNCONNECTED,
      o_dbg_l3_rxdata(19 downto 0) => NLW_inst_o_dbg_l3_rxdata_UNCONNECTED(19 downto 0),
      o_dbg_l3_rxdatak(1 downto 0) => NLW_inst_o_dbg_l3_rxdatak_UNCONNECTED(1 downto 0),
      o_dbg_l3_rxelecidle => NLW_inst_o_dbg_l3_rxelecidle_UNCONNECTED,
      o_dbg_l3_rxpolarity => NLW_inst_o_dbg_l3_rxpolarity_UNCONNECTED,
      o_dbg_l3_rxstatus(2 downto 0) => NLW_inst_o_dbg_l3_rxstatus_UNCONNECTED(2 downto 0),
      o_dbg_l3_rxvalid => NLW_inst_o_dbg_l3_rxvalid_UNCONNECTED,
      o_dbg_l3_sata_coreclockready => NLW_inst_o_dbg_l3_sata_coreclockready_UNCONNECTED,
      o_dbg_l3_sata_coreready => NLW_inst_o_dbg_l3_sata_coreready_UNCONNECTED,
      o_dbg_l3_sata_corerxdata(19 downto 0) => NLW_inst_o_dbg_l3_sata_corerxdata_UNCONNECTED(19 downto 0),
      o_dbg_l3_sata_corerxdatavalid(1 downto 0) => NLW_inst_o_dbg_l3_sata_corerxdatavalid_UNCONNECTED(1 downto 0),
      o_dbg_l3_sata_corerxsignaldet => NLW_inst_o_dbg_l3_sata_corerxsignaldet_UNCONNECTED,
      o_dbg_l3_sata_phyctrlpartial => NLW_inst_o_dbg_l3_sata_phyctrlpartial_UNCONNECTED,
      o_dbg_l3_sata_phyctrlreset => NLW_inst_o_dbg_l3_sata_phyctrlreset_UNCONNECTED,
      o_dbg_l3_sata_phyctrlrxrate(1 downto 0) => NLW_inst_o_dbg_l3_sata_phyctrlrxrate_UNCONNECTED(1 downto 0),
      o_dbg_l3_sata_phyctrlrxrst => NLW_inst_o_dbg_l3_sata_phyctrlrxrst_UNCONNECTED,
      o_dbg_l3_sata_phyctrlslumber => NLW_inst_o_dbg_l3_sata_phyctrlslumber_UNCONNECTED,
      o_dbg_l3_sata_phyctrltxdata(19 downto 0) => NLW_inst_o_dbg_l3_sata_phyctrltxdata_UNCONNECTED(19 downto 0),
      o_dbg_l3_sata_phyctrltxidle => NLW_inst_o_dbg_l3_sata_phyctrltxidle_UNCONNECTED,
      o_dbg_l3_sata_phyctrltxrate(1 downto 0) => NLW_inst_o_dbg_l3_sata_phyctrltxrate_UNCONNECTED(1 downto 0),
      o_dbg_l3_sata_phyctrltxrst => NLW_inst_o_dbg_l3_sata_phyctrltxrst_UNCONNECTED,
      o_dbg_l3_tx_sgmii_ewrap => NLW_inst_o_dbg_l3_tx_sgmii_ewrap_UNCONNECTED,
      o_dbg_l3_txclk => NLW_inst_o_dbg_l3_txclk_UNCONNECTED,
      o_dbg_l3_txdata(19 downto 0) => NLW_inst_o_dbg_l3_txdata_UNCONNECTED(19 downto 0),
      o_dbg_l3_txdatak(1 downto 0) => NLW_inst_o_dbg_l3_txdatak_UNCONNECTED(1 downto 0),
      o_dbg_l3_txdetrx_lpback => NLW_inst_o_dbg_l3_txdetrx_lpback_UNCONNECTED,
      o_dbg_l3_txelecidle => NLW_inst_o_dbg_l3_txelecidle_UNCONNECTED,
      osc_rtc_clk => NLW_inst_osc_rtc_clk_UNCONNECTED,
      perif_gdma_clk(7 downto 0) => B"00000000",
      perif_gdma_cvld(7 downto 0) => B"00000000",
      perif_gdma_tack(7 downto 0) => B"00000000",
      pl2adma_cvld(7 downto 0) => B"00000000",
      pl2adma_tack(7 downto 0) => B"00000000",
      pl_acpinact => '0',
      pl_clk0 => pl_clk0,
      pl_clk1 => NLW_inst_pl_clk1_UNCONNECTED,
      pl_clk2 => NLW_inst_pl_clk2_UNCONNECTED,
      pl_clk3 => NLW_inst_pl_clk3_UNCONNECTED,
      pl_clock_stop(3 downto 0) => B"0000",
      pl_fpd_pll_test_ck_sel_n(2 downto 0) => B"000",
      pl_fpd_pll_test_fract_clk_sel_n => '0',
      pl_fpd_pll_test_fract_en_n => '0',
      pl_fpd_pll_test_mux_sel(1 downto 0) => B"00",
      pl_fpd_pll_test_sel(3 downto 0) => B"0000",
      pl_fpd_spare_0_in => '0',
      pl_fpd_spare_1_in => '0',
      pl_fpd_spare_2_in => '0',
      pl_fpd_spare_3_in => '0',
      pl_fpd_spare_4_in => '0',
      pl_lpd_pll_test_ck_sel_n(2 downto 0) => B"000",
      pl_lpd_pll_test_fract_clk_sel_n => '0',
      pl_lpd_pll_test_fract_en_n => '0',
      pl_lpd_pll_test_mux_sel => '0',
      pl_lpd_pll_test_sel(3 downto 0) => B"0000",
      pl_lpd_spare_0_in => '0',
      pl_lpd_spare_1_in => '0',
      pl_lpd_spare_2_in => '0',
      pl_lpd_spare_3_in => '0',
      pl_lpd_spare_4_in => '0',
      pl_pmu_gpi(31 downto 0) => B"00000000000000000000000000000000",
      pl_ps_apugic_fiq(3 downto 0) => B"0000",
      pl_ps_apugic_irq(3 downto 0) => B"0000",
      pl_ps_eventi => '0',
      pl_ps_irq0(0) => '0',
      pl_ps_irq1(0) => '0',
      pl_ps_trace_clk => '0',
      pl_ps_trigack_0 => '0',
      pl_ps_trigack_1 => '0',
      pl_ps_trigack_2 => '0',
      pl_ps_trigack_3 => '0',
      pl_ps_trigger_0 => '0',
      pl_ps_trigger_1 => '0',
      pl_ps_trigger_2 => '0',
      pl_ps_trigger_3 => '0',
      pl_resetn0 => pl_resetn0,
      pl_resetn1 => NLW_inst_pl_resetn1_UNCONNECTED,
      pl_resetn2 => NLW_inst_pl_resetn2_UNCONNECTED,
      pl_resetn3 => NLW_inst_pl_resetn3_UNCONNECTED,
      pll_aux_refclk_fpd(2 downto 0) => B"000",
      pll_aux_refclk_lpd(1 downto 0) => B"00",
      pmu_aib_afifm_fpd_req => NLW_inst_pmu_aib_afifm_fpd_req_UNCONNECTED,
      pmu_aib_afifm_lpd_req => NLW_inst_pmu_aib_afifm_lpd_req_UNCONNECTED,
      pmu_error_from_pl(3 downto 0) => B"0000",
      pmu_error_to_pl(46 downto 0) => NLW_inst_pmu_error_to_pl_UNCONNECTED(46 downto 0),
      pmu_pl_gpo(31 downto 0) => NLW_inst_pmu_pl_gpo_UNCONNECTED(31 downto 0),
      ps_pl_evento => NLW_inst_ps_pl_evento_UNCONNECTED,
      ps_pl_irq_adma_chan(7 downto 0) => NLW_inst_ps_pl_irq_adma_chan_UNCONNECTED(7 downto 0),
      ps_pl_irq_aib_axi => NLW_inst_ps_pl_irq_aib_axi_UNCONNECTED,
      ps_pl_irq_ams => NLW_inst_ps_pl_irq_ams_UNCONNECTED,
      ps_pl_irq_apm_fpd => NLW_inst_ps_pl_irq_apm_fpd_UNCONNECTED,
      ps_pl_irq_apu_comm(3 downto 0) => NLW_inst_ps_pl_irq_apu_comm_UNCONNECTED(3 downto 0),
      ps_pl_irq_apu_cpumnt(3 downto 0) => NLW_inst_ps_pl_irq_apu_cpumnt_UNCONNECTED(3 downto 0),
      ps_pl_irq_apu_cti(3 downto 0) => NLW_inst_ps_pl_irq_apu_cti_UNCONNECTED(3 downto 0),
      ps_pl_irq_apu_exterr => NLW_inst_ps_pl_irq_apu_exterr_UNCONNECTED,
      ps_pl_irq_apu_l2err => NLW_inst_ps_pl_irq_apu_l2err_UNCONNECTED,
      ps_pl_irq_apu_pmu(3 downto 0) => NLW_inst_ps_pl_irq_apu_pmu_UNCONNECTED(3 downto 0),
      ps_pl_irq_apu_regs => NLW_inst_ps_pl_irq_apu_regs_UNCONNECTED,
      ps_pl_irq_atb_err_lpd => NLW_inst_ps_pl_irq_atb_err_lpd_UNCONNECTED,
      ps_pl_irq_can0 => NLW_inst_ps_pl_irq_can0_UNCONNECTED,
      ps_pl_irq_can1 => NLW_inst_ps_pl_irq_can1_UNCONNECTED,
      ps_pl_irq_clkmon => NLW_inst_ps_pl_irq_clkmon_UNCONNECTED,
      ps_pl_irq_csu => NLW_inst_ps_pl_irq_csu_UNCONNECTED,
      ps_pl_irq_csu_dma => NLW_inst_ps_pl_irq_csu_dma_UNCONNECTED,
      ps_pl_irq_csu_pmu_wdt => NLW_inst_ps_pl_irq_csu_pmu_wdt_UNCONNECTED,
      ps_pl_irq_ddr_ss => NLW_inst_ps_pl_irq_ddr_ss_UNCONNECTED,
      ps_pl_irq_dpdma => NLW_inst_ps_pl_irq_dpdma_UNCONNECTED,
      ps_pl_irq_dport => NLW_inst_ps_pl_irq_dport_UNCONNECTED,
      ps_pl_irq_efuse => NLW_inst_ps_pl_irq_efuse_UNCONNECTED,
      ps_pl_irq_enet0 => NLW_inst_ps_pl_irq_enet0_UNCONNECTED,
      ps_pl_irq_enet0_wake => NLW_inst_ps_pl_irq_enet0_wake_UNCONNECTED,
      ps_pl_irq_enet1 => NLW_inst_ps_pl_irq_enet1_UNCONNECTED,
      ps_pl_irq_enet1_wake => NLW_inst_ps_pl_irq_enet1_wake_UNCONNECTED,
      ps_pl_irq_enet2 => NLW_inst_ps_pl_irq_enet2_UNCONNECTED,
      ps_pl_irq_enet2_wake => NLW_inst_ps_pl_irq_enet2_wake_UNCONNECTED,
      ps_pl_irq_enet3 => NLW_inst_ps_pl_irq_enet3_UNCONNECTED,
      ps_pl_irq_enet3_wake => NLW_inst_ps_pl_irq_enet3_wake_UNCONNECTED,
      ps_pl_irq_fp_wdt => NLW_inst_ps_pl_irq_fp_wdt_UNCONNECTED,
      ps_pl_irq_fpd_apb_int => NLW_inst_ps_pl_irq_fpd_apb_int_UNCONNECTED,
      ps_pl_irq_fpd_atb_error => NLW_inst_ps_pl_irq_fpd_atb_error_UNCONNECTED,
      ps_pl_irq_gdma_chan(7 downto 0) => NLW_inst_ps_pl_irq_gdma_chan_UNCONNECTED(7 downto 0),
      ps_pl_irq_gpio => NLW_inst_ps_pl_irq_gpio_UNCONNECTED,
      ps_pl_irq_gpu => NLW_inst_ps_pl_irq_gpu_UNCONNECTED,
      ps_pl_irq_i2c0 => NLW_inst_ps_pl_irq_i2c0_UNCONNECTED,
      ps_pl_irq_i2c1 => NLW_inst_ps_pl_irq_i2c1_UNCONNECTED,
      ps_pl_irq_intf_fpd_smmu => NLW_inst_ps_pl_irq_intf_fpd_smmu_UNCONNECTED,
      ps_pl_irq_intf_ppd_cci => NLW_inst_ps_pl_irq_intf_ppd_cci_UNCONNECTED,
      ps_pl_irq_ipi_channel0 => NLW_inst_ps_pl_irq_ipi_channel0_UNCONNECTED,
      ps_pl_irq_ipi_channel1 => NLW_inst_ps_pl_irq_ipi_channel1_UNCONNECTED,
      ps_pl_irq_ipi_channel10 => NLW_inst_ps_pl_irq_ipi_channel10_UNCONNECTED,
      ps_pl_irq_ipi_channel2 => NLW_inst_ps_pl_irq_ipi_channel2_UNCONNECTED,
      ps_pl_irq_ipi_channel7 => NLW_inst_ps_pl_irq_ipi_channel7_UNCONNECTED,
      ps_pl_irq_ipi_channel8 => NLW_inst_ps_pl_irq_ipi_channel8_UNCONNECTED,
      ps_pl_irq_ipi_channel9 => NLW_inst_ps_pl_irq_ipi_channel9_UNCONNECTED,
      ps_pl_irq_lp_wdt => NLW_inst_ps_pl_irq_lp_wdt_UNCONNECTED,
      ps_pl_irq_lpd_apb_intr => NLW_inst_ps_pl_irq_lpd_apb_intr_UNCONNECTED,
      ps_pl_irq_lpd_apm => NLW_inst_ps_pl_irq_lpd_apm_UNCONNECTED,
      ps_pl_irq_nand => NLW_inst_ps_pl_irq_nand_UNCONNECTED,
      ps_pl_irq_ocm_error => NLW_inst_ps_pl_irq_ocm_error_UNCONNECTED,
      ps_pl_irq_pcie_dma => NLW_inst_ps_pl_irq_pcie_dma_UNCONNECTED,
      ps_pl_irq_pcie_legacy => NLW_inst_ps_pl_irq_pcie_legacy_UNCONNECTED,
      ps_pl_irq_pcie_msc => NLW_inst_ps_pl_irq_pcie_msc_UNCONNECTED,
      ps_pl_irq_pcie_msi(1 downto 0) => NLW_inst_ps_pl_irq_pcie_msi_UNCONNECTED(1 downto 0),
      ps_pl_irq_qspi => NLW_inst_ps_pl_irq_qspi_UNCONNECTED,
      ps_pl_irq_r5_core0_ecc_error => NLW_inst_ps_pl_irq_r5_core0_ecc_error_UNCONNECTED,
      ps_pl_irq_r5_core1_ecc_error => NLW_inst_ps_pl_irq_r5_core1_ecc_error_UNCONNECTED,
      ps_pl_irq_rpu_pm(1 downto 0) => NLW_inst_ps_pl_irq_rpu_pm_UNCONNECTED(1 downto 0),
      ps_pl_irq_rtc_alaram => NLW_inst_ps_pl_irq_rtc_alaram_UNCONNECTED,
      ps_pl_irq_rtc_seconds => NLW_inst_ps_pl_irq_rtc_seconds_UNCONNECTED,
      ps_pl_irq_sata => NLW_inst_ps_pl_irq_sata_UNCONNECTED,
      ps_pl_irq_sdio0 => NLW_inst_ps_pl_irq_sdio0_UNCONNECTED,
      ps_pl_irq_sdio0_wake => NLW_inst_ps_pl_irq_sdio0_wake_UNCONNECTED,
      ps_pl_irq_sdio1 => NLW_inst_ps_pl_irq_sdio1_UNCONNECTED,
      ps_pl_irq_sdio1_wake => NLW_inst_ps_pl_irq_sdio1_wake_UNCONNECTED,
      ps_pl_irq_spi0 => NLW_inst_ps_pl_irq_spi0_UNCONNECTED,
      ps_pl_irq_spi1 => NLW_inst_ps_pl_irq_spi1_UNCONNECTED,
      ps_pl_irq_ttc0_0 => NLW_inst_ps_pl_irq_ttc0_0_UNCONNECTED,
      ps_pl_irq_ttc0_1 => NLW_inst_ps_pl_irq_ttc0_1_UNCONNECTED,
      ps_pl_irq_ttc0_2 => NLW_inst_ps_pl_irq_ttc0_2_UNCONNECTED,
      ps_pl_irq_ttc1_0 => NLW_inst_ps_pl_irq_ttc1_0_UNCONNECTED,
      ps_pl_irq_ttc1_1 => NLW_inst_ps_pl_irq_ttc1_1_UNCONNECTED,
      ps_pl_irq_ttc1_2 => NLW_inst_ps_pl_irq_ttc1_2_UNCONNECTED,
      ps_pl_irq_ttc2_0 => NLW_inst_ps_pl_irq_ttc2_0_UNCONNECTED,
      ps_pl_irq_ttc2_1 => NLW_inst_ps_pl_irq_ttc2_1_UNCONNECTED,
      ps_pl_irq_ttc2_2 => NLW_inst_ps_pl_irq_ttc2_2_UNCONNECTED,
      ps_pl_irq_ttc3_0 => NLW_inst_ps_pl_irq_ttc3_0_UNCONNECTED,
      ps_pl_irq_ttc3_1 => NLW_inst_ps_pl_irq_ttc3_1_UNCONNECTED,
      ps_pl_irq_ttc3_2 => NLW_inst_ps_pl_irq_ttc3_2_UNCONNECTED,
      ps_pl_irq_uart0 => NLW_inst_ps_pl_irq_uart0_UNCONNECTED,
      ps_pl_irq_uart1 => NLW_inst_ps_pl_irq_uart1_UNCONNECTED,
      ps_pl_irq_usb3_0_endpoint(3 downto 0) => NLW_inst_ps_pl_irq_usb3_0_endpoint_UNCONNECTED(3 downto 0),
      ps_pl_irq_usb3_0_otg => NLW_inst_ps_pl_irq_usb3_0_otg_UNCONNECTED,
      ps_pl_irq_usb3_0_pmu_wakeup(1 downto 0) => NLW_inst_ps_pl_irq_usb3_0_pmu_wakeup_UNCONNECTED(1 downto 0),
      ps_pl_irq_usb3_1_endpoint(3 downto 0) => NLW_inst_ps_pl_irq_usb3_1_endpoint_UNCONNECTED(3 downto 0),
      ps_pl_irq_usb3_1_otg => NLW_inst_ps_pl_irq_usb3_1_otg_UNCONNECTED,
      ps_pl_irq_xmpu_fpd => NLW_inst_ps_pl_irq_xmpu_fpd_UNCONNECTED,
      ps_pl_irq_xmpu_lpd => NLW_inst_ps_pl_irq_xmpu_lpd_UNCONNECTED,
      ps_pl_standbywfe(3 downto 0) => NLW_inst_ps_pl_standbywfe_UNCONNECTED(3 downto 0),
      ps_pl_standbywfi(3 downto 0) => NLW_inst_ps_pl_standbywfi_UNCONNECTED(3 downto 0),
      ps_pl_tracectl => NLW_inst_ps_pl_tracectl_UNCONNECTED,
      ps_pl_tracedata(31 downto 0) => NLW_inst_ps_pl_tracedata_UNCONNECTED(31 downto 0),
      ps_pl_trigack_0 => NLW_inst_ps_pl_trigack_0_UNCONNECTED,
      ps_pl_trigack_1 => NLW_inst_ps_pl_trigack_1_UNCONNECTED,
      ps_pl_trigack_2 => NLW_inst_ps_pl_trigack_2_UNCONNECTED,
      ps_pl_trigack_3 => NLW_inst_ps_pl_trigack_3_UNCONNECTED,
      ps_pl_trigger_0 => NLW_inst_ps_pl_trigger_0_UNCONNECTED,
      ps_pl_trigger_1 => NLW_inst_ps_pl_trigger_1_UNCONNECTED,
      ps_pl_trigger_2 => NLW_inst_ps_pl_trigger_2_UNCONNECTED,
      ps_pl_trigger_3 => NLW_inst_ps_pl_trigger_3_UNCONNECTED,
      pstp_pl_clk(3 downto 0) => B"0000",
      pstp_pl_in(31 downto 0) => B"00000000000000000000000000000000",
      pstp_pl_out(31 downto 0) => NLW_inst_pstp_pl_out_UNCONNECTED(31 downto 0),
      pstp_pl_ts(31 downto 0) => B"00000000000000000000000000000000",
      rpu_eventi0 => '0',
      rpu_eventi1 => '0',
      rpu_evento0 => NLW_inst_rpu_evento0_UNCONNECTED,
      rpu_evento1 => NLW_inst_rpu_evento1_UNCONNECTED,
      sacefpd_acaddr(43 downto 0) => NLW_inst_sacefpd_acaddr_UNCONNECTED(43 downto 0),
      sacefpd_aclk => '0',
      sacefpd_acprot(2 downto 0) => NLW_inst_sacefpd_acprot_UNCONNECTED(2 downto 0),
      sacefpd_acready => '0',
      sacefpd_acsnoop(3 downto 0) => NLW_inst_sacefpd_acsnoop_UNCONNECTED(3 downto 0),
      sacefpd_acvalid => NLW_inst_sacefpd_acvalid_UNCONNECTED,
      sacefpd_araddr(43 downto 0) => B"00000000000000000000000000000000000000000000",
      sacefpd_arbar(1 downto 0) => B"00",
      sacefpd_arburst(1 downto 0) => B"00",
      sacefpd_arcache(3 downto 0) => B"0000",
      sacefpd_ardomain(1 downto 0) => B"00",
      sacefpd_arid(5 downto 0) => B"000000",
      sacefpd_arlen(7 downto 0) => B"00000000",
      sacefpd_arlock => '0',
      sacefpd_arprot(2 downto 0) => B"000",
      sacefpd_arqos(3 downto 0) => B"0000",
      sacefpd_arready => NLW_inst_sacefpd_arready_UNCONNECTED,
      sacefpd_arregion(3 downto 0) => B"0000",
      sacefpd_arsize(2 downto 0) => B"000",
      sacefpd_arsnoop(3 downto 0) => B"0000",
      sacefpd_aruser(15 downto 0) => B"0000000000000000",
      sacefpd_arvalid => '0',
      sacefpd_awaddr(43 downto 0) => B"00000000000000000000000000000000000000000000",
      sacefpd_awbar(1 downto 0) => B"00",
      sacefpd_awburst(1 downto 0) => B"00",
      sacefpd_awcache(3 downto 0) => B"0000",
      sacefpd_awdomain(1 downto 0) => B"00",
      sacefpd_awid(5 downto 0) => B"000000",
      sacefpd_awlen(7 downto 0) => B"00000000",
      sacefpd_awlock => '0',
      sacefpd_awprot(2 downto 0) => B"000",
      sacefpd_awqos(3 downto 0) => B"0000",
      sacefpd_awready => NLW_inst_sacefpd_awready_UNCONNECTED,
      sacefpd_awregion(3 downto 0) => B"0000",
      sacefpd_awsize(2 downto 0) => B"000",
      sacefpd_awsnoop(2 downto 0) => B"000",
      sacefpd_awuser(15 downto 0) => B"0000000000000000",
      sacefpd_awvalid => '0',
      sacefpd_bid(5 downto 0) => NLW_inst_sacefpd_bid_UNCONNECTED(5 downto 0),
      sacefpd_bready => '0',
      sacefpd_bresp(1 downto 0) => NLW_inst_sacefpd_bresp_UNCONNECTED(1 downto 0),
      sacefpd_buser => NLW_inst_sacefpd_buser_UNCONNECTED,
      sacefpd_bvalid => NLW_inst_sacefpd_bvalid_UNCONNECTED,
      sacefpd_cddata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      sacefpd_cdlast => '0',
      sacefpd_cdready => NLW_inst_sacefpd_cdready_UNCONNECTED,
      sacefpd_cdvalid => '0',
      sacefpd_crready => NLW_inst_sacefpd_crready_UNCONNECTED,
      sacefpd_crresp(4 downto 0) => B"00000",
      sacefpd_crvalid => '0',
      sacefpd_rack => '0',
      sacefpd_rdata(127 downto 0) => NLW_inst_sacefpd_rdata_UNCONNECTED(127 downto 0),
      sacefpd_rid(5 downto 0) => NLW_inst_sacefpd_rid_UNCONNECTED(5 downto 0),
      sacefpd_rlast => NLW_inst_sacefpd_rlast_UNCONNECTED,
      sacefpd_rready => '0',
      sacefpd_rresp(3 downto 0) => NLW_inst_sacefpd_rresp_UNCONNECTED(3 downto 0),
      sacefpd_ruser => NLW_inst_sacefpd_ruser_UNCONNECTED,
      sacefpd_rvalid => NLW_inst_sacefpd_rvalid_UNCONNECTED,
      sacefpd_wack => '0',
      sacefpd_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      sacefpd_wlast => '0',
      sacefpd_wready => NLW_inst_sacefpd_wready_UNCONNECTED,
      sacefpd_wstrb(15 downto 0) => B"0000000000000000",
      sacefpd_wuser => '0',
      sacefpd_wvalid => '0',
      saxi_lpd_aclk => '0',
      saxi_lpd_rclk => '0',
      saxi_lpd_wclk => '0',
      saxiacp_araddr(39 downto 0) => B"0000000000000000000000000000000000000000",
      saxiacp_arburst(1 downto 0) => B"00",
      saxiacp_arcache(3 downto 0) => B"0000",
      saxiacp_arid(4 downto 0) => B"00000",
      saxiacp_arlen(7 downto 0) => B"00000000",
      saxiacp_arlock => '0',
      saxiacp_arprot(2 downto 0) => B"000",
      saxiacp_arqos(3 downto 0) => B"0000",
      saxiacp_arready => NLW_inst_saxiacp_arready_UNCONNECTED,
      saxiacp_arsize(2 downto 0) => B"000",
      saxiacp_aruser(1 downto 0) => B"00",
      saxiacp_arvalid => '0',
      saxiacp_awaddr(39 downto 0) => B"0000000000000000000000000000000000000000",
      saxiacp_awburst(1 downto 0) => B"00",
      saxiacp_awcache(3 downto 0) => B"0000",
      saxiacp_awid(4 downto 0) => B"00000",
      saxiacp_awlen(7 downto 0) => B"00000000",
      saxiacp_awlock => '0',
      saxiacp_awprot(2 downto 0) => B"000",
      saxiacp_awqos(3 downto 0) => B"0000",
      saxiacp_awready => NLW_inst_saxiacp_awready_UNCONNECTED,
      saxiacp_awsize(2 downto 0) => B"000",
      saxiacp_awuser(1 downto 0) => B"00",
      saxiacp_awvalid => '0',
      saxiacp_bid(4 downto 0) => NLW_inst_saxiacp_bid_UNCONNECTED(4 downto 0),
      saxiacp_bready => '0',
      saxiacp_bresp(1 downto 0) => NLW_inst_saxiacp_bresp_UNCONNECTED(1 downto 0),
      saxiacp_bvalid => NLW_inst_saxiacp_bvalid_UNCONNECTED,
      saxiacp_fpd_aclk => '0',
      saxiacp_rdata(127 downto 0) => NLW_inst_saxiacp_rdata_UNCONNECTED(127 downto 0),
      saxiacp_rid(4 downto 0) => NLW_inst_saxiacp_rid_UNCONNECTED(4 downto 0),
      saxiacp_rlast => NLW_inst_saxiacp_rlast_UNCONNECTED,
      saxiacp_rready => '0',
      saxiacp_rresp(1 downto 0) => NLW_inst_saxiacp_rresp_UNCONNECTED(1 downto 0),
      saxiacp_rvalid => NLW_inst_saxiacp_rvalid_UNCONNECTED,
      saxiacp_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      saxiacp_wlast => '0',
      saxiacp_wready => NLW_inst_saxiacp_wready_UNCONNECTED,
      saxiacp_wstrb(15 downto 0) => B"0000000000000000",
      saxiacp_wvalid => '0',
      saxigp0_araddr(48 downto 0) => saxigp0_araddr(48 downto 0),
      saxigp0_arburst(1 downto 0) => saxigp0_arburst(1 downto 0),
      saxigp0_arcache(3 downto 0) => saxigp0_arcache(3 downto 0),
      saxigp0_arid(5 downto 0) => saxigp0_arid(5 downto 0),
      saxigp0_arlen(7 downto 0) => saxigp0_arlen(7 downto 0),
      saxigp0_arlock => saxigp0_arlock,
      saxigp0_arprot(2 downto 0) => saxigp0_arprot(2 downto 0),
      saxigp0_arqos(3 downto 0) => saxigp0_arqos(3 downto 0),
      saxigp0_arready => saxigp0_arready,
      saxigp0_arsize(2 downto 0) => saxigp0_arsize(2 downto 0),
      saxigp0_aruser => saxigp0_aruser,
      saxigp0_arvalid => saxigp0_arvalid,
      saxigp0_awaddr(48 downto 0) => saxigp0_awaddr(48 downto 0),
      saxigp0_awburst(1 downto 0) => saxigp0_awburst(1 downto 0),
      saxigp0_awcache(3 downto 0) => saxigp0_awcache(3 downto 0),
      saxigp0_awid(5 downto 0) => saxigp0_awid(5 downto 0),
      saxigp0_awlen(7 downto 0) => saxigp0_awlen(7 downto 0),
      saxigp0_awlock => saxigp0_awlock,
      saxigp0_awprot(2 downto 0) => saxigp0_awprot(2 downto 0),
      saxigp0_awqos(3 downto 0) => saxigp0_awqos(3 downto 0),
      saxigp0_awready => saxigp0_awready,
      saxigp0_awsize(2 downto 0) => saxigp0_awsize(2 downto 0),
      saxigp0_awuser => saxigp0_awuser,
      saxigp0_awvalid => saxigp0_awvalid,
      saxigp0_bid(5 downto 0) => saxigp0_bid(5 downto 0),
      saxigp0_bready => saxigp0_bready,
      saxigp0_bresp(1 downto 0) => saxigp0_bresp(1 downto 0),
      saxigp0_bvalid => saxigp0_bvalid,
      saxigp0_racount(3 downto 0) => NLW_inst_saxigp0_racount_UNCONNECTED(3 downto 0),
      saxigp0_rcount(7 downto 0) => NLW_inst_saxigp0_rcount_UNCONNECTED(7 downto 0),
      saxigp0_rdata(63 downto 0) => saxigp0_rdata(63 downto 0),
      saxigp0_rid(5 downto 0) => saxigp0_rid(5 downto 0),
      saxigp0_rlast => saxigp0_rlast,
      saxigp0_rready => saxigp0_rready,
      saxigp0_rresp(1 downto 0) => saxigp0_rresp(1 downto 0),
      saxigp0_rvalid => saxigp0_rvalid,
      saxigp0_wacount(3 downto 0) => NLW_inst_saxigp0_wacount_UNCONNECTED(3 downto 0),
      saxigp0_wcount(7 downto 0) => NLW_inst_saxigp0_wcount_UNCONNECTED(7 downto 0),
      saxigp0_wdata(63 downto 0) => saxigp0_wdata(63 downto 0),
      saxigp0_wlast => saxigp0_wlast,
      saxigp0_wready => saxigp0_wready,
      saxigp0_wstrb(7 downto 0) => saxigp0_wstrb(7 downto 0),
      saxigp0_wvalid => saxigp0_wvalid,
      saxigp1_araddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp1_arburst(1 downto 0) => B"00",
      saxigp1_arcache(3 downto 0) => B"0000",
      saxigp1_arid(5 downto 0) => B"000000",
      saxigp1_arlen(7 downto 0) => B"00000000",
      saxigp1_arlock => '0',
      saxigp1_arprot(2 downto 0) => B"000",
      saxigp1_arqos(3 downto 0) => B"0000",
      saxigp1_arready => NLW_inst_saxigp1_arready_UNCONNECTED,
      saxigp1_arsize(2 downto 0) => B"000",
      saxigp1_aruser => '0',
      saxigp1_arvalid => '0',
      saxigp1_awaddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp1_awburst(1 downto 0) => B"00",
      saxigp1_awcache(3 downto 0) => B"0000",
      saxigp1_awid(5 downto 0) => B"000000",
      saxigp1_awlen(7 downto 0) => B"00000000",
      saxigp1_awlock => '0',
      saxigp1_awprot(2 downto 0) => B"000",
      saxigp1_awqos(3 downto 0) => B"0000",
      saxigp1_awready => NLW_inst_saxigp1_awready_UNCONNECTED,
      saxigp1_awsize(2 downto 0) => B"000",
      saxigp1_awuser => '0',
      saxigp1_awvalid => '0',
      saxigp1_bid(5 downto 0) => NLW_inst_saxigp1_bid_UNCONNECTED(5 downto 0),
      saxigp1_bready => '0',
      saxigp1_bresp(1 downto 0) => NLW_inst_saxigp1_bresp_UNCONNECTED(1 downto 0),
      saxigp1_bvalid => NLW_inst_saxigp1_bvalid_UNCONNECTED,
      saxigp1_racount(3 downto 0) => NLW_inst_saxigp1_racount_UNCONNECTED(3 downto 0),
      saxigp1_rcount(7 downto 0) => NLW_inst_saxigp1_rcount_UNCONNECTED(7 downto 0),
      saxigp1_rdata(127 downto 0) => NLW_inst_saxigp1_rdata_UNCONNECTED(127 downto 0),
      saxigp1_rid(5 downto 0) => NLW_inst_saxigp1_rid_UNCONNECTED(5 downto 0),
      saxigp1_rlast => NLW_inst_saxigp1_rlast_UNCONNECTED,
      saxigp1_rready => '0',
      saxigp1_rresp(1 downto 0) => NLW_inst_saxigp1_rresp_UNCONNECTED(1 downto 0),
      saxigp1_rvalid => NLW_inst_saxigp1_rvalid_UNCONNECTED,
      saxigp1_wacount(3 downto 0) => NLW_inst_saxigp1_wacount_UNCONNECTED(3 downto 0),
      saxigp1_wcount(7 downto 0) => NLW_inst_saxigp1_wcount_UNCONNECTED(7 downto 0),
      saxigp1_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      saxigp1_wlast => '0',
      saxigp1_wready => NLW_inst_saxigp1_wready_UNCONNECTED,
      saxigp1_wstrb(15 downto 0) => B"0000000000000000",
      saxigp1_wvalid => '0',
      saxigp2_araddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp2_arburst(1 downto 0) => B"00",
      saxigp2_arcache(3 downto 0) => B"0000",
      saxigp2_arid(5 downto 0) => B"000000",
      saxigp2_arlen(7 downto 0) => B"00000000",
      saxigp2_arlock => '0',
      saxigp2_arprot(2 downto 0) => B"000",
      saxigp2_arqos(3 downto 0) => B"0000",
      saxigp2_arready => NLW_inst_saxigp2_arready_UNCONNECTED,
      saxigp2_arsize(2 downto 0) => B"000",
      saxigp2_aruser => '0',
      saxigp2_arvalid => '0',
      saxigp2_awaddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp2_awburst(1 downto 0) => B"00",
      saxigp2_awcache(3 downto 0) => B"0000",
      saxigp2_awid(5 downto 0) => B"000000",
      saxigp2_awlen(7 downto 0) => B"00000000",
      saxigp2_awlock => '0',
      saxigp2_awprot(2 downto 0) => B"000",
      saxigp2_awqos(3 downto 0) => B"0000",
      saxigp2_awready => NLW_inst_saxigp2_awready_UNCONNECTED,
      saxigp2_awsize(2 downto 0) => B"000",
      saxigp2_awuser => '0',
      saxigp2_awvalid => '0',
      saxigp2_bid(5 downto 0) => NLW_inst_saxigp2_bid_UNCONNECTED(5 downto 0),
      saxigp2_bready => '0',
      saxigp2_bresp(1 downto 0) => NLW_inst_saxigp2_bresp_UNCONNECTED(1 downto 0),
      saxigp2_bvalid => NLW_inst_saxigp2_bvalid_UNCONNECTED,
      saxigp2_racount(3 downto 0) => NLW_inst_saxigp2_racount_UNCONNECTED(3 downto 0),
      saxigp2_rcount(7 downto 0) => NLW_inst_saxigp2_rcount_UNCONNECTED(7 downto 0),
      saxigp2_rdata(127 downto 0) => NLW_inst_saxigp2_rdata_UNCONNECTED(127 downto 0),
      saxigp2_rid(5 downto 0) => NLW_inst_saxigp2_rid_UNCONNECTED(5 downto 0),
      saxigp2_rlast => NLW_inst_saxigp2_rlast_UNCONNECTED,
      saxigp2_rready => '0',
      saxigp2_rresp(1 downto 0) => NLW_inst_saxigp2_rresp_UNCONNECTED(1 downto 0),
      saxigp2_rvalid => NLW_inst_saxigp2_rvalid_UNCONNECTED,
      saxigp2_wacount(3 downto 0) => NLW_inst_saxigp2_wacount_UNCONNECTED(3 downto 0),
      saxigp2_wcount(7 downto 0) => NLW_inst_saxigp2_wcount_UNCONNECTED(7 downto 0),
      saxigp2_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      saxigp2_wlast => '0',
      saxigp2_wready => NLW_inst_saxigp2_wready_UNCONNECTED,
      saxigp2_wstrb(15 downto 0) => B"0000000000000000",
      saxigp2_wvalid => '0',
      saxigp3_araddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp3_arburst(1 downto 0) => B"00",
      saxigp3_arcache(3 downto 0) => B"0000",
      saxigp3_arid(5 downto 0) => B"000000",
      saxigp3_arlen(7 downto 0) => B"00000000",
      saxigp3_arlock => '0',
      saxigp3_arprot(2 downto 0) => B"000",
      saxigp3_arqos(3 downto 0) => B"0000",
      saxigp3_arready => NLW_inst_saxigp3_arready_UNCONNECTED,
      saxigp3_arsize(2 downto 0) => B"000",
      saxigp3_aruser => '0',
      saxigp3_arvalid => '0',
      saxigp3_awaddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp3_awburst(1 downto 0) => B"00",
      saxigp3_awcache(3 downto 0) => B"0000",
      saxigp3_awid(5 downto 0) => B"000000",
      saxigp3_awlen(7 downto 0) => B"00000000",
      saxigp3_awlock => '0',
      saxigp3_awprot(2 downto 0) => B"000",
      saxigp3_awqos(3 downto 0) => B"0000",
      saxigp3_awready => NLW_inst_saxigp3_awready_UNCONNECTED,
      saxigp3_awsize(2 downto 0) => B"000",
      saxigp3_awuser => '0',
      saxigp3_awvalid => '0',
      saxigp3_bid(5 downto 0) => NLW_inst_saxigp3_bid_UNCONNECTED(5 downto 0),
      saxigp3_bready => '0',
      saxigp3_bresp(1 downto 0) => NLW_inst_saxigp3_bresp_UNCONNECTED(1 downto 0),
      saxigp3_bvalid => NLW_inst_saxigp3_bvalid_UNCONNECTED,
      saxigp3_racount(3 downto 0) => NLW_inst_saxigp3_racount_UNCONNECTED(3 downto 0),
      saxigp3_rcount(7 downto 0) => NLW_inst_saxigp3_rcount_UNCONNECTED(7 downto 0),
      saxigp3_rdata(127 downto 0) => NLW_inst_saxigp3_rdata_UNCONNECTED(127 downto 0),
      saxigp3_rid(5 downto 0) => NLW_inst_saxigp3_rid_UNCONNECTED(5 downto 0),
      saxigp3_rlast => NLW_inst_saxigp3_rlast_UNCONNECTED,
      saxigp3_rready => '0',
      saxigp3_rresp(1 downto 0) => NLW_inst_saxigp3_rresp_UNCONNECTED(1 downto 0),
      saxigp3_rvalid => NLW_inst_saxigp3_rvalid_UNCONNECTED,
      saxigp3_wacount(3 downto 0) => NLW_inst_saxigp3_wacount_UNCONNECTED(3 downto 0),
      saxigp3_wcount(7 downto 0) => NLW_inst_saxigp3_wcount_UNCONNECTED(7 downto 0),
      saxigp3_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      saxigp3_wlast => '0',
      saxigp3_wready => NLW_inst_saxigp3_wready_UNCONNECTED,
      saxigp3_wstrb(15 downto 0) => B"0000000000000000",
      saxigp3_wvalid => '0',
      saxigp4_araddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp4_arburst(1 downto 0) => B"00",
      saxigp4_arcache(3 downto 0) => B"0000",
      saxigp4_arid(5 downto 0) => B"000000",
      saxigp4_arlen(7 downto 0) => B"00000000",
      saxigp4_arlock => '0',
      saxigp4_arprot(2 downto 0) => B"000",
      saxigp4_arqos(3 downto 0) => B"0000",
      saxigp4_arready => NLW_inst_saxigp4_arready_UNCONNECTED,
      saxigp4_arsize(2 downto 0) => B"000",
      saxigp4_aruser => '0',
      saxigp4_arvalid => '0',
      saxigp4_awaddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp4_awburst(1 downto 0) => B"00",
      saxigp4_awcache(3 downto 0) => B"0000",
      saxigp4_awid(5 downto 0) => B"000000",
      saxigp4_awlen(7 downto 0) => B"00000000",
      saxigp4_awlock => '0',
      saxigp4_awprot(2 downto 0) => B"000",
      saxigp4_awqos(3 downto 0) => B"0000",
      saxigp4_awready => NLW_inst_saxigp4_awready_UNCONNECTED,
      saxigp4_awsize(2 downto 0) => B"000",
      saxigp4_awuser => '0',
      saxigp4_awvalid => '0',
      saxigp4_bid(5 downto 0) => NLW_inst_saxigp4_bid_UNCONNECTED(5 downto 0),
      saxigp4_bready => '0',
      saxigp4_bresp(1 downto 0) => NLW_inst_saxigp4_bresp_UNCONNECTED(1 downto 0),
      saxigp4_bvalid => NLW_inst_saxigp4_bvalid_UNCONNECTED,
      saxigp4_racount(3 downto 0) => NLW_inst_saxigp4_racount_UNCONNECTED(3 downto 0),
      saxigp4_rcount(7 downto 0) => NLW_inst_saxigp4_rcount_UNCONNECTED(7 downto 0),
      saxigp4_rdata(127 downto 0) => NLW_inst_saxigp4_rdata_UNCONNECTED(127 downto 0),
      saxigp4_rid(5 downto 0) => NLW_inst_saxigp4_rid_UNCONNECTED(5 downto 0),
      saxigp4_rlast => NLW_inst_saxigp4_rlast_UNCONNECTED,
      saxigp4_rready => '0',
      saxigp4_rresp(1 downto 0) => NLW_inst_saxigp4_rresp_UNCONNECTED(1 downto 0),
      saxigp4_rvalid => NLW_inst_saxigp4_rvalid_UNCONNECTED,
      saxigp4_wacount(3 downto 0) => NLW_inst_saxigp4_wacount_UNCONNECTED(3 downto 0),
      saxigp4_wcount(7 downto 0) => NLW_inst_saxigp4_wcount_UNCONNECTED(7 downto 0),
      saxigp4_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      saxigp4_wlast => '0',
      saxigp4_wready => NLW_inst_saxigp4_wready_UNCONNECTED,
      saxigp4_wstrb(15 downto 0) => B"0000000000000000",
      saxigp4_wvalid => '0',
      saxigp5_araddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp5_arburst(1 downto 0) => B"00",
      saxigp5_arcache(3 downto 0) => B"0000",
      saxigp5_arid(5 downto 0) => B"000000",
      saxigp5_arlen(7 downto 0) => B"00000000",
      saxigp5_arlock => '0',
      saxigp5_arprot(2 downto 0) => B"000",
      saxigp5_arqos(3 downto 0) => B"0000",
      saxigp5_arready => NLW_inst_saxigp5_arready_UNCONNECTED,
      saxigp5_arsize(2 downto 0) => B"000",
      saxigp5_aruser => '0',
      saxigp5_arvalid => '0',
      saxigp5_awaddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp5_awburst(1 downto 0) => B"00",
      saxigp5_awcache(3 downto 0) => B"0000",
      saxigp5_awid(5 downto 0) => B"000000",
      saxigp5_awlen(7 downto 0) => B"00000000",
      saxigp5_awlock => '0',
      saxigp5_awprot(2 downto 0) => B"000",
      saxigp5_awqos(3 downto 0) => B"0000",
      saxigp5_awready => NLW_inst_saxigp5_awready_UNCONNECTED,
      saxigp5_awsize(2 downto 0) => B"000",
      saxigp5_awuser => '0',
      saxigp5_awvalid => '0',
      saxigp5_bid(5 downto 0) => NLW_inst_saxigp5_bid_UNCONNECTED(5 downto 0),
      saxigp5_bready => '0',
      saxigp5_bresp(1 downto 0) => NLW_inst_saxigp5_bresp_UNCONNECTED(1 downto 0),
      saxigp5_bvalid => NLW_inst_saxigp5_bvalid_UNCONNECTED,
      saxigp5_racount(3 downto 0) => NLW_inst_saxigp5_racount_UNCONNECTED(3 downto 0),
      saxigp5_rcount(7 downto 0) => NLW_inst_saxigp5_rcount_UNCONNECTED(7 downto 0),
      saxigp5_rdata(127 downto 0) => NLW_inst_saxigp5_rdata_UNCONNECTED(127 downto 0),
      saxigp5_rid(5 downto 0) => NLW_inst_saxigp5_rid_UNCONNECTED(5 downto 0),
      saxigp5_rlast => NLW_inst_saxigp5_rlast_UNCONNECTED,
      saxigp5_rready => '0',
      saxigp5_rresp(1 downto 0) => NLW_inst_saxigp5_rresp_UNCONNECTED(1 downto 0),
      saxigp5_rvalid => NLW_inst_saxigp5_rvalid_UNCONNECTED,
      saxigp5_wacount(3 downto 0) => NLW_inst_saxigp5_wacount_UNCONNECTED(3 downto 0),
      saxigp5_wcount(7 downto 0) => NLW_inst_saxigp5_wcount_UNCONNECTED(7 downto 0),
      saxigp5_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      saxigp5_wlast => '0',
      saxigp5_wready => NLW_inst_saxigp5_wready_UNCONNECTED,
      saxigp5_wstrb(15 downto 0) => B"0000000000000000",
      saxigp5_wvalid => '0',
      saxigp6_araddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp6_arburst(1 downto 0) => B"00",
      saxigp6_arcache(3 downto 0) => B"0000",
      saxigp6_arid(5 downto 0) => B"000000",
      saxigp6_arlen(7 downto 0) => B"00000000",
      saxigp6_arlock => '0',
      saxigp6_arprot(2 downto 0) => B"000",
      saxigp6_arqos(3 downto 0) => B"0000",
      saxigp6_arready => NLW_inst_saxigp6_arready_UNCONNECTED,
      saxigp6_arsize(2 downto 0) => B"000",
      saxigp6_aruser => '0',
      saxigp6_arvalid => '0',
      saxigp6_awaddr(48 downto 0) => B"0000000000000000000000000000000000000000000000000",
      saxigp6_awburst(1 downto 0) => B"00",
      saxigp6_awcache(3 downto 0) => B"0000",
      saxigp6_awid(5 downto 0) => B"000000",
      saxigp6_awlen(7 downto 0) => B"00000000",
      saxigp6_awlock => '0',
      saxigp6_awprot(2 downto 0) => B"000",
      saxigp6_awqos(3 downto 0) => B"0000",
      saxigp6_awready => NLW_inst_saxigp6_awready_UNCONNECTED,
      saxigp6_awsize(2 downto 0) => B"000",
      saxigp6_awuser => '0',
      saxigp6_awvalid => '0',
      saxigp6_bid(5 downto 0) => NLW_inst_saxigp6_bid_UNCONNECTED(5 downto 0),
      saxigp6_bready => '0',
      saxigp6_bresp(1 downto 0) => NLW_inst_saxigp6_bresp_UNCONNECTED(1 downto 0),
      saxigp6_bvalid => NLW_inst_saxigp6_bvalid_UNCONNECTED,
      saxigp6_racount(3 downto 0) => NLW_inst_saxigp6_racount_UNCONNECTED(3 downto 0),
      saxigp6_rcount(7 downto 0) => NLW_inst_saxigp6_rcount_UNCONNECTED(7 downto 0),
      saxigp6_rdata(127 downto 0) => NLW_inst_saxigp6_rdata_UNCONNECTED(127 downto 0),
      saxigp6_rid(5 downto 0) => NLW_inst_saxigp6_rid_UNCONNECTED(5 downto 0),
      saxigp6_rlast => NLW_inst_saxigp6_rlast_UNCONNECTED,
      saxigp6_rready => '0',
      saxigp6_rresp(1 downto 0) => NLW_inst_saxigp6_rresp_UNCONNECTED(1 downto 0),
      saxigp6_rvalid => NLW_inst_saxigp6_rvalid_UNCONNECTED,
      saxigp6_wacount(3 downto 0) => NLW_inst_saxigp6_wacount_UNCONNECTED(3 downto 0),
      saxigp6_wcount(7 downto 0) => NLW_inst_saxigp6_wcount_UNCONNECTED(7 downto 0),
      saxigp6_wdata(127 downto 0) => B"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      saxigp6_wlast => '0',
      saxigp6_wready => NLW_inst_saxigp6_wready_UNCONNECTED,
      saxigp6_wstrb(15 downto 0) => B"0000000000000000",
      saxigp6_wvalid => '0',
      saxihp0_fpd_aclk => '0',
      saxihp0_fpd_rclk => '0',
      saxihp0_fpd_wclk => '0',
      saxihp1_fpd_aclk => '0',
      saxihp1_fpd_rclk => '0',
      saxihp1_fpd_wclk => '0',
      saxihp2_fpd_aclk => '0',
      saxihp2_fpd_rclk => '0',
      saxihp2_fpd_wclk => '0',
      saxihp3_fpd_aclk => '0',
      saxihp3_fpd_rclk => '0',
      saxihp3_fpd_wclk => '0',
      saxihpc0_fpd_aclk => saxihpc0_fpd_aclk,
      saxihpc0_fpd_rclk => '0',
      saxihpc0_fpd_wclk => '0',
      saxihpc1_fpd_aclk => '0',
      saxihpc1_fpd_rclk => '0',
      saxihpc1_fpd_wclk => '0',
      stm_event(59 downto 0) => B"000000000000000000000000000000000000000000000000000000000000",
      test_adc2_in(31 downto 0) => B"00000000000000000000000000000000",
      test_adc_clk(3 downto 0) => B"0000",
      test_adc_in(31 downto 0) => B"00000000000000000000000000000000",
      test_adc_out(19 downto 0) => NLW_inst_test_adc_out_UNCONNECTED(19 downto 0),
      test_ams_osc(7 downto 0) => NLW_inst_test_ams_osc_UNCONNECTED(7 downto 0),
      test_bscan_ac_mode => '0',
      test_bscan_ac_test => '0',
      test_bscan_clockdr => '0',
      test_bscan_en_n => '0',
      test_bscan_extest => '0',
      test_bscan_init_memory => '0',
      test_bscan_intest => '0',
      test_bscan_misr_jtag_load => '0',
      test_bscan_mode_c => '0',
      test_bscan_reset_tap_b => '0',
      test_bscan_shiftdr => '0',
      test_bscan_tdi => '0',
      test_bscan_tdo => NLW_inst_test_bscan_tdo_UNCONNECTED,
      test_bscan_updatedr => '0',
      test_char_mode_fpd_n => '0',
      test_char_mode_lpd_n => '0',
      test_convst => '0',
      test_daddr(7 downto 0) => B"00000000",
      test_db(15 downto 0) => NLW_inst_test_db_UNCONNECTED(15 downto 0),
      test_dclk => '0',
      test_ddr2pl_dcd_skewout => NLW_inst_test_ddr2pl_dcd_skewout_UNCONNECTED,
      test_den => '0',
      test_di(15 downto 0) => B"0000000000000000",
      test_do(15 downto 0) => NLW_inst_test_do_UNCONNECTED(15 downto 0),
      test_drdy => NLW_inst_test_drdy_UNCONNECTED,
      test_dwe => '0',
      test_mon_data(15 downto 0) => NLW_inst_test_mon_data_UNCONNECTED(15 downto 0),
      test_pl2ddr_dcd_sample_pulse => '0',
      test_pl_pll_lock_out(4 downto 0) => NLW_inst_test_pl_pll_lock_out_UNCONNECTED(4 downto 0),
      test_pl_scan_chopper_si => '0',
      test_pl_scan_chopper_so => NLW_inst_test_pl_scan_chopper_so_UNCONNECTED,
      test_pl_scan_chopper_trig => '0',
      test_pl_scan_clk0 => '0',
      test_pl_scan_clk1 => '0',
      test_pl_scan_edt_clk => '0',
      test_pl_scan_edt_in_apu => '0',
      test_pl_scan_edt_in_cpu => '0',
      test_pl_scan_edt_in_ddr(3 downto 0) => B"0000",
      test_pl_scan_edt_in_fp(9 downto 0) => B"0000000000",
      test_pl_scan_edt_in_gpu(3 downto 0) => B"0000",
      test_pl_scan_edt_in_lp(8 downto 0) => B"000000000",
      test_pl_scan_edt_in_usb3(1 downto 0) => B"00",
      test_pl_scan_edt_out_apu => NLW_inst_test_pl_scan_edt_out_apu_UNCONNECTED,
      test_pl_scan_edt_out_cpu0 => NLW_inst_test_pl_scan_edt_out_cpu0_UNCONNECTED,
      test_pl_scan_edt_out_cpu1 => NLW_inst_test_pl_scan_edt_out_cpu1_UNCONNECTED,
      test_pl_scan_edt_out_cpu2 => NLW_inst_test_pl_scan_edt_out_cpu2_UNCONNECTED,
      test_pl_scan_edt_out_cpu3 => NLW_inst_test_pl_scan_edt_out_cpu3_UNCONNECTED,
      test_pl_scan_edt_out_ddr(3 downto 0) => NLW_inst_test_pl_scan_edt_out_ddr_UNCONNECTED(3 downto 0),
      test_pl_scan_edt_out_fp(9 downto 0) => NLW_inst_test_pl_scan_edt_out_fp_UNCONNECTED(9 downto 0),
      test_pl_scan_edt_out_gpu(3 downto 0) => NLW_inst_test_pl_scan_edt_out_gpu_UNCONNECTED(3 downto 0),
      test_pl_scan_edt_out_lp(8 downto 0) => NLW_inst_test_pl_scan_edt_out_lp_UNCONNECTED(8 downto 0),
      test_pl_scan_edt_out_usb3(1 downto 0) => NLW_inst_test_pl_scan_edt_out_usb3_UNCONNECTED(1 downto 0),
      test_pl_scan_edt_update => '0',
      test_pl_scan_pll_reset => '0',
      test_pl_scan_reset_n => '0',
      test_pl_scan_slcr_config_clk => '0',
      test_pl_scan_slcr_config_rstn => '0',
      test_pl_scan_slcr_config_si => '0',
      test_pl_scan_slcr_config_so => NLW_inst_test_pl_scan_slcr_config_so_UNCONNECTED,
      test_pl_scan_spare_in0 => '0',
      test_pl_scan_spare_in1 => '0',
      test_pl_scan_spare_in2 => '0',
      test_pl_scan_spare_out0 => NLW_inst_test_pl_scan_spare_out0_UNCONNECTED,
      test_pl_scan_spare_out1 => NLW_inst_test_pl_scan_spare_out1_UNCONNECTED,
      test_pl_scan_wrap_clk => '0',
      test_pl_scan_wrap_ishift => '0',
      test_pl_scan_wrap_oshift => '0',
      test_pl_scanenable => '0',
      test_pl_scanenable_slcr_en => '0',
      test_usb0_funcmux_0_n => '0',
      test_usb0_scanmux_0_n => '0',
      test_usb1_funcmux_0_n => '0',
      test_usb1_scanmux_0_n => '0',
      trace_clk_out => NLW_inst_trace_clk_out_UNCONNECTED,
      tst_rtc_calibreg_in(20 downto 0) => B"000000000000000000000",
      tst_rtc_calibreg_out(20 downto 0) => NLW_inst_tst_rtc_calibreg_out_UNCONNECTED(20 downto 0),
      tst_rtc_calibreg_we => '0',
      tst_rtc_clk => '0',
      tst_rtc_disable_bat_op => '0',
      tst_rtc_osc_clk_out => NLW_inst_tst_rtc_osc_clk_out_UNCONNECTED,
      tst_rtc_osc_cntrl_in(3 downto 0) => B"0000",
      tst_rtc_osc_cntrl_out(3 downto 0) => NLW_inst_tst_rtc_osc_cntrl_out_UNCONNECTED(3 downto 0),
      tst_rtc_osc_cntrl_we => '0',
      tst_rtc_sec_counter_out(31 downto 0) => NLW_inst_tst_rtc_sec_counter_out_UNCONNECTED(31 downto 0),
      tst_rtc_sec_reload => '0',
      tst_rtc_seconds_raw_int => NLW_inst_tst_rtc_seconds_raw_int_UNCONNECTED,
      tst_rtc_testclock_select_n => '0',
      tst_rtc_testmode_n => '0',
      tst_rtc_tick_counter_out(15 downto 0) => NLW_inst_tst_rtc_tick_counter_out_UNCONNECTED(15 downto 0),
      tst_rtc_timesetreg_in(31 downto 0) => B"00000000000000000000000000000000",
      tst_rtc_timesetreg_out(31 downto 0) => NLW_inst_tst_rtc_timesetreg_out_UNCONNECTED(31 downto 0),
      tst_rtc_timesetreg_we => '0'
    );
end STRUCTURE;
