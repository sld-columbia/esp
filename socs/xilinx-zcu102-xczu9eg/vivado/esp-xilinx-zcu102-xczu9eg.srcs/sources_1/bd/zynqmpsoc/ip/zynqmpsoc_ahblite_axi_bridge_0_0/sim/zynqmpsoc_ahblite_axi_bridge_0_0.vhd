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

-- IP VLNV: xilinx.com:ip:ahblite_axi_bridge:3.0
-- IP Revision: 15

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY ahblite_axi_bridge_v3_0_15;
USE ahblite_axi_bridge_v3_0_15.ahblite_axi_bridge;

ENTITY zynqmpsoc_ahblite_axi_bridge_0_0 IS
  PORT (
    s_ahb_hclk : IN STD_LOGIC;
    s_ahb_hresetn : IN STD_LOGIC;
    s_ahb_hsel : IN STD_LOGIC;
    s_ahb_haddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_ahb_hprot : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_ahb_htrans : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_ahb_hsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_ahb_hwrite : IN STD_LOGIC;
    s_ahb_hburst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_ahb_hwdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_ahb_hready_out : OUT STD_LOGIC;
    s_ahb_hready_in : IN STD_LOGIC;
    s_ahb_hrdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    s_ahb_hresp : OUT STD_LOGIC;
    m_axi_awid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_awvalid : OUT STD_LOGIC;
    m_axi_awready : IN STD_LOGIC;
    m_axi_awlock : OUT STD_LOGIC;
    m_axi_wdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axi_wstrb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_wlast : OUT STD_LOGIC;
    m_axi_wvalid : OUT STD_LOGIC;
    m_axi_wready : IN STD_LOGIC;
    m_axi_bid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_bvalid : IN STD_LOGIC;
    m_axi_bready : OUT STD_LOGIC;
    m_axi_arid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_arvalid : OUT STD_LOGIC;
    m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_arlock : OUT STD_LOGIC;
    m_axi_arready : IN STD_LOGIC;
    m_axi_rid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_rdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_rvalid : IN STD_LOGIC;
    m_axi_rlast : IN STD_LOGIC;
    m_axi_rready : OUT STD_LOGIC
  );
END zynqmpsoc_ahblite_axi_bridge_0_0;

ARCHITECTURE zynqmpsoc_ahblite_axi_bridge_0_0_arch OF zynqmpsoc_ahblite_axi_bridge_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF zynqmpsoc_ahblite_axi_bridge_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT ahblite_axi_bridge IS
    GENERIC (
      C_FAMILY : STRING;
      C_INSTANCE : STRING;
      C_M_AXI_SUPPORTS_NARROW_BURST : INTEGER;
      C_M_AXI_NON_SECURE : INTEGER;
      C_S_AHB_ADDR_WIDTH : INTEGER;
      C_M_AXI_ADDR_WIDTH : INTEGER;
      C_S_AHB_DATA_WIDTH : INTEGER;
      C_M_AXI_DATA_WIDTH : INTEGER;
      C_M_AXI_PROTOCOL : STRING;
      C_M_AXI_THREAD_ID_WIDTH : INTEGER;
      C_AHB_AXI_TIMEOUT : INTEGER
    );
    PORT (
      s_ahb_hclk : IN STD_LOGIC;
      s_ahb_hresetn : IN STD_LOGIC;
      s_ahb_hsel : IN STD_LOGIC;
      s_ahb_haddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_ahb_hprot : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_ahb_htrans : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_ahb_hsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_ahb_hwrite : IN STD_LOGIC;
      s_ahb_hburst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s_ahb_hwdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      s_ahb_hready_out : OUT STD_LOGIC;
      s_ahb_hready_in : IN STD_LOGIC;
      s_ahb_hrdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      s_ahb_hresp : OUT STD_LOGIC;
      m_axi_awid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_awvalid : OUT STD_LOGIC;
      m_axi_awready : IN STD_LOGIC;
      m_axi_awlock : OUT STD_LOGIC;
      m_axi_wdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      m_axi_wstrb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axi_wlast : OUT STD_LOGIC;
      m_axi_wvalid : OUT STD_LOGIC;
      m_axi_wready : IN STD_LOGIC;
      m_axi_bid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_bvalid : IN STD_LOGIC;
      m_axi_bready : OUT STD_LOGIC;
      m_axi_arid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_arvalid : OUT STD_LOGIC;
      m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_arlock : OUT STD_LOGIC;
      m_axi_arready : IN STD_LOGIC;
      m_axi_rid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_rdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_rvalid : IN STD_LOGIC;
      m_axi_rlast : IN STD_LOGIC;
      m_axi_rready : OUT STD_LOGIC
    );
  END COMPONENT ahblite_axi_bridge;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_rlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_rid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI RID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arlock: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_arid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI ARID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_bid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI BID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_wlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI WLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awlock: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWADDR";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWBURST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWLEN";
  ATTRIBUTE X_INTERFACE_PARAMETER OF m_axi_awid: SIGNAL IS "XIL_INTERFACENAME M_AXI, MAX_BURST_LENGTH 16, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 4, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 16, NUM_WRITE_OUTSTANDING 16, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, N" & 
"UM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_awid: SIGNAL IS "xilinx.com:interface:aximm:1.0 M_AXI AWID";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hresp: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hrdata: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HRDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hready_in: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HREADY_IN";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hready_out: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HREADY_OUT";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hwdata: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HWDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hburst: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hwrite: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HWRITE";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hsize: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_htrans: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HTRANS";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hprot: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_haddr: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_ahb_hsel: SIGNAL IS "XIL_INTERFACENAME AHB_INTERFACE, BD_ATTRIBUTE.TYPE INTERIOR";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hsel: SIGNAL IS "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE SEL";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_ahb_hresetn: SIGNAL IS "XIL_INTERFACENAME AHB_RESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 AHB_RESETN RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_ahb_hclk: SIGNAL IS "XIL_INTERFACENAME AHB_CLK, ASSOCIATED_BUSIF AHB_INTERFACE:M_AXI, ASSOCIATED_RESET s_ahb_hresetn, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_ahb_hclk: SIGNAL IS "xilinx.com:signal:clock:1.0 AHB_CLK CLK";
BEGIN
  U0 : ahblite_axi_bridge
    GENERIC MAP (
      C_FAMILY => "zynquplus",
      C_INSTANCE => "zynqmpsoc_ahblite_axi_bridge_0_0",
      C_M_AXI_SUPPORTS_NARROW_BURST => 0,
      C_M_AXI_NON_SECURE => 1,
      C_S_AHB_ADDR_WIDTH => 32,
      C_M_AXI_ADDR_WIDTH => 32,
      C_S_AHB_DATA_WIDTH => 64,
      C_M_AXI_DATA_WIDTH => 64,
      C_M_AXI_PROTOCOL => "AXI4",
      C_M_AXI_THREAD_ID_WIDTH => 4,
      C_AHB_AXI_TIMEOUT => 0
    )
    PORT MAP (
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_hsel => s_ahb_hsel,
      s_ahb_haddr => s_ahb_haddr,
      s_ahb_hprot => s_ahb_hprot,
      s_ahb_htrans => s_ahb_htrans,
      s_ahb_hsize => s_ahb_hsize,
      s_ahb_hwrite => s_ahb_hwrite,
      s_ahb_hburst => s_ahb_hburst,
      s_ahb_hwdata => s_ahb_hwdata,
      s_ahb_hready_out => s_ahb_hready_out,
      s_ahb_hready_in => s_ahb_hready_in,
      s_ahb_hrdata => s_ahb_hrdata,
      s_ahb_hresp => s_ahb_hresp,
      m_axi_awid => m_axi_awid,
      m_axi_awlen => m_axi_awlen,
      m_axi_awsize => m_axi_awsize,
      m_axi_awburst => m_axi_awburst,
      m_axi_awcache => m_axi_awcache,
      m_axi_awaddr => m_axi_awaddr,
      m_axi_awprot => m_axi_awprot,
      m_axi_awvalid => m_axi_awvalid,
      m_axi_awready => m_axi_awready,
      m_axi_awlock => m_axi_awlock,
      m_axi_wdata => m_axi_wdata,
      m_axi_wstrb => m_axi_wstrb,
      m_axi_wlast => m_axi_wlast,
      m_axi_wvalid => m_axi_wvalid,
      m_axi_wready => m_axi_wready,
      m_axi_bid => m_axi_bid,
      m_axi_bresp => m_axi_bresp,
      m_axi_bvalid => m_axi_bvalid,
      m_axi_bready => m_axi_bready,
      m_axi_arid => m_axi_arid,
      m_axi_arlen => m_axi_arlen,
      m_axi_arsize => m_axi_arsize,
      m_axi_arburst => m_axi_arburst,
      m_axi_arprot => m_axi_arprot,
      m_axi_arcache => m_axi_arcache,
      m_axi_arvalid => m_axi_arvalid,
      m_axi_araddr => m_axi_araddr,
      m_axi_arlock => m_axi_arlock,
      m_axi_arready => m_axi_arready,
      m_axi_rid => m_axi_rid,
      m_axi_rdata => m_axi_rdata,
      m_axi_rresp => m_axi_rresp,
      m_axi_rvalid => m_axi_rvalid,
      m_axi_rlast => m_axi_rlast,
      m_axi_rready => m_axi_rready
    );
END zynqmpsoc_ahblite_axi_bridge_0_0_arch;
