-- (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:axi_ahblite_bridge:3.0
-- IP Revision: 17

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY axi_ahblite_bridge_v3_0_17;
USE axi_ahblite_bridge_v3_0_17.axi_ahblite_bridge;

ENTITY zynqmpsoc_axi_ahblite_bridge_0_0 IS
  PORT (
    s_axi_aclk : IN STD_LOGIC;
    s_axi_aresetn : IN STD_LOGIC;
    s_axi_awid : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_awready : OUT STD_LOGIC;
    s_axi_awlock : IN STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_wlast : IN STD_LOGIC;
    s_axi_wvalid : IN STD_LOGIC;
    s_axi_wready : OUT STD_LOGIC;
    s_axi_bid : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_arid : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_arlock : IN STD_LOGIC;
    s_axi_arready : OUT STD_LOGIC;
    s_axi_rid : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_rlast : OUT STD_LOGIC;
    s_axi_rready : IN STD_LOGIC;
    m_ahb_haddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_ahb_hwrite : OUT STD_LOGIC;
    m_ahb_hsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_ahb_hburst : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_ahb_hprot : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_ahb_htrans : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_ahb_hmastlock : OUT STD_LOGIC;
    m_ahb_hwdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_ahb_hready : IN STD_LOGIC;
    m_ahb_hrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_ahb_hresp : IN STD_LOGIC
  );
END zynqmpsoc_axi_ahblite_bridge_0_0;

ARCHITECTURE zynqmpsoc_axi_ahblite_bridge_0_0_arch OF zynqmpsoc_axi_ahblite_bridge_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF zynqmpsoc_axi_ahblite_bridge_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT axi_ahblite_bridge IS
    GENERIC (
      C_FAMILY : STRING;
      C_INSTANCE : STRING;
      C_S_AXI_ADDR_WIDTH : INTEGER;
      C_S_AXI_DATA_WIDTH : INTEGER;
      C_S_AXI_SUPPORTS_NARROW_BURST : INTEGER;
      C_S_AXI_ID_WIDTH : INTEGER;
      C_M_AHB_ADDR_WIDTH : INTEGER;
      C_M_AHB_DATA_WIDTH : INTEGER;
      C_DPHASE_TIMEOUT : INTEGER
    );
    PORT (
      s_axi_aclk : IN STD_LOGIC;
      s_axi_aresetn : IN STD_LOGIC;
      s_axi_awid : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_awvalid : IN STD_LOGIC;
      s_axi_awready : OUT STD_LOGIC;
      s_axi_awlock : IN STD_LOGIC;
      s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_wlast : IN STD_LOGIC;
      s_axi_wvalid : IN STD_LOGIC;
      s_axi_wready : OUT STD_LOGIC;
      s_axi_bid : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_bvalid : OUT STD_LOGIC;
      s_axi_bready : IN STD_LOGIC;
      s_axi_arid : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_arvalid : IN STD_LOGIC;
      s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_arlock : IN STD_LOGIC;
      s_axi_arready : OUT STD_LOGIC;
      s_axi_rid : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_rvalid : OUT STD_LOGIC;
      s_axi_rlast : OUT STD_LOGIC;
      s_axi_rready : IN STD_LOGIC;
      m_ahb_haddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_ahb_hwrite : OUT STD_LOGIC;
      m_ahb_hsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_ahb_hburst : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_ahb_hprot : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_ahb_htrans : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_ahb_hmastlock : OUT STD_LOGIC;
      m_ahb_hwdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_ahb_hready : IN STD_LOGIC;
      m_ahb_hrdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_ahb_hresp : IN STD_LOGIC
    );
  END COMPONENT axi_ahblite_bridge;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF zynqmpsoc_axi_ahblite_bridge_0_0_arch: ARCHITECTURE IS "axi_ahblite_bridge,Vivado 2019.2.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF zynqmpsoc_axi_ahblite_bridge_0_0_arch : ARCHITECTURE IS "zynqmpsoc_axi_ahblite_bridge_0_0,axi_ahblite_bridge,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF zynqmpsoc_axi_ahblite_bridge_0_0_arch: ARCHITECTURE IS "zynqmpsoc_axi_ahblite_bridge_0_0,axi_ahblite_bridge,{x_ipProduct=Vivado 2019.2.1,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=axi_ahblite_bridge,x_ipVersion=3.0,x_ipCoreRevision=17,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_FAMILY=zynquplus,C_INSTANCE=zynqmpsoc_axi_ahblite_bridge_0_0,C_S_AXI_ADDR_WIDTH=32,C_S_AXI_DATA_WIDTH=32,C_S_AXI_SUPPORTS_NARROW_BURST=1,C_S_AXI_ID_WIDTH=16,C_M_AHB_ADDR_WIDTH=32,C_M_AHB_DATA_WIDTH=32,C_DPHASE_TIMEOUT=0}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hresp: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HRESP";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hrdata: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HRDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hready: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hwdata: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HWDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hmastlock: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HMASTLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_htrans: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HTRANS";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hprot: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HPROT";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hburst: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HBURST";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hsize: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_hwrite: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HWRITE";
  ATTRIBUTE X_INTERFACE_INFO OF m_ahb_haddr: SIGNAL IS "xilinx.com:interface:ahblite:2.0 M_AHB HADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_rid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 RID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arlock: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_arid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 ARID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_bid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 BID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 WLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awlock: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWLEN";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_awid: SIGNAL IS "XIL_INTERFACENAME AXI4, BD_ATTRIBUTE.TYPE INTERIOR, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 16, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_" & 
"clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_awid: SIGNAL IS "xilinx.com:interface:aximm:1.0 AXI4 AWID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_aresetn: SIGNAL IS "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 ARESETN RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_aclk: SIGNAL IS "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF AXI4:M_AHB, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 ACLK CLK";
BEGIN
  U0 : axi_ahblite_bridge
    GENERIC MAP (
      C_FAMILY => "zynquplus",
      C_INSTANCE => "zynqmpsoc_axi_ahblite_bridge_0_0",
      C_S_AXI_ADDR_WIDTH => 32,
      C_S_AXI_DATA_WIDTH => 32,
      C_S_AXI_SUPPORTS_NARROW_BURST => 1,
      C_S_AXI_ID_WIDTH => 16,
      C_M_AHB_ADDR_WIDTH => 32,
      C_M_AHB_DATA_WIDTH => 32,
      C_DPHASE_TIMEOUT => 0
    )
    PORT MAP (
      s_axi_aclk => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_awid => s_axi_awid,
      s_axi_awlen => s_axi_awlen,
      s_axi_awsize => s_axi_awsize,
      s_axi_awburst => s_axi_awburst,
      s_axi_awcache => s_axi_awcache,
      s_axi_awaddr => s_axi_awaddr,
      s_axi_awprot => s_axi_awprot,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,
      s_axi_awlock => s_axi_awlock,
      s_axi_wdata => s_axi_wdata,
      s_axi_wstrb => s_axi_wstrb,
      s_axi_wlast => s_axi_wlast,
      s_axi_wvalid => s_axi_wvalid,
      s_axi_wready => s_axi_wready,
      s_axi_bid => s_axi_bid,
      s_axi_bresp => s_axi_bresp,
      s_axi_bvalid => s_axi_bvalid,
      s_axi_bready => s_axi_bready,
      s_axi_arid => s_axi_arid,
      s_axi_araddr => s_axi_araddr,
      s_axi_arprot => s_axi_arprot,
      s_axi_arcache => s_axi_arcache,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arlen => s_axi_arlen,
      s_axi_arsize => s_axi_arsize,
      s_axi_arburst => s_axi_arburst,
      s_axi_arlock => s_axi_arlock,
      s_axi_arready => s_axi_arready,
      s_axi_rid => s_axi_rid,
      s_axi_rdata => s_axi_rdata,
      s_axi_rresp => s_axi_rresp,
      s_axi_rvalid => s_axi_rvalid,
      s_axi_rlast => s_axi_rlast,
      s_axi_rready => s_axi_rready,
      m_ahb_haddr => m_ahb_haddr,
      m_ahb_hwrite => m_ahb_hwrite,
      m_ahb_hsize => m_ahb_hsize,
      m_ahb_hburst => m_ahb_hburst,
      m_ahb_hprot => m_ahb_hprot,
      m_ahb_htrans => m_ahb_htrans,
      m_ahb_hmastlock => m_ahb_hmastlock,
      m_ahb_hwdata => m_ahb_hwdata,
      m_ahb_hready => m_ahb_hready,
      m_ahb_hrdata => m_ahb_hrdata,
      m_ahb_hresp => m_ahb_hresp
    );
END zynqmpsoc_axi_ahblite_bridge_0_0_arch;
