-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
-- Date        : Mon Jan 11 12:11:30 2021
-- Host        : skie running 64-bit Ubuntu 18.04.5 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ zynqmpsoc_system_ila_0_0_stub.vhdl
-- Design      : zynqmpsoc_system_ila_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    clk : in STD_LOGIC;
    SLOT_0_AHBLITE_haddr : in STD_LOGIC;
    SLOT_0_AHBLITE_hprot : in STD_LOGIC;
    SLOT_0_AHBLITE_htrans : in STD_LOGIC;
    SLOT_0_AHBLITE_hsize : in STD_LOGIC;
    SLOT_0_AHBLITE_hwrite : in STD_LOGIC;
    SLOT_0_AHBLITE_hburst : in STD_LOGIC;
    SLOT_0_AHBLITE_hwdata : in STD_LOGIC;
    SLOT_0_AHBLITE_hrdata : in STD_LOGIC;
    SLOT_0_AHBLITE_hresp : in STD_LOGIC;
    SLOT_0_AHBLITE_hmastlock : in STD_LOGIC;
    SLOT_0_AHBLITE_hready : in STD_LOGIC;
    SLOT_1_AHBLITE_sel : in STD_LOGIC;
    SLOT_1_AHBLITE_haddr : in STD_LOGIC;
    SLOT_1_AHBLITE_hprot : in STD_LOGIC;
    SLOT_1_AHBLITE_htrans : in STD_LOGIC;
    SLOT_1_AHBLITE_hsize : in STD_LOGIC;
    SLOT_1_AHBLITE_hwrite : in STD_LOGIC;
    SLOT_1_AHBLITE_hburst : in STD_LOGIC;
    SLOT_1_AHBLITE_hwdata : in STD_LOGIC;
    SLOT_1_AHBLITE_hrdata : in STD_LOGIC;
    SLOT_1_AHBLITE_hresp : in STD_LOGIC;
    SLOT_1_AHBLITE_hready_in : in STD_LOGIC;
    SLOT_1_AHBLITE_hready_out : in STD_LOGIC
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,SLOT_0_AHBLITE_haddr,SLOT_0_AHBLITE_hprot,SLOT_0_AHBLITE_htrans,SLOT_0_AHBLITE_hsize,SLOT_0_AHBLITE_hwrite,SLOT_0_AHBLITE_hburst,SLOT_0_AHBLITE_hwdata,SLOT_0_AHBLITE_hrdata,SLOT_0_AHBLITE_hresp,SLOT_0_AHBLITE_hmastlock,SLOT_0_AHBLITE_hready,SLOT_1_AHBLITE_sel,SLOT_1_AHBLITE_haddr,SLOT_1_AHBLITE_hprot,SLOT_1_AHBLITE_htrans,SLOT_1_AHBLITE_hsize,SLOT_1_AHBLITE_hwrite,SLOT_1_AHBLITE_hburst,SLOT_1_AHBLITE_hwdata,SLOT_1_AHBLITE_hrdata,SLOT_1_AHBLITE_hresp,SLOT_1_AHBLITE_hready_in,SLOT_1_AHBLITE_hready_out";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "bd_c007,Vivado 2019.2.1";
begin
end;
