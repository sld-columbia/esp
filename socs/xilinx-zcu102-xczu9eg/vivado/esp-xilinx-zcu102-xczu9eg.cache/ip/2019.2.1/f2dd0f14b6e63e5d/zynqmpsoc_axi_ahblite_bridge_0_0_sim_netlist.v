// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Mon Jan 11 12:09:46 2021
// Host        : skie running 64-bit Ubuntu 18.04.5 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ zynqmpsoc_axi_ahblite_bridge_0_0_sim_netlist.v
// Design      : zynqmpsoc_axi_ahblite_bridge_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_mstr_if
   (m_ahb_haddr,
    m_ahb_hburst,
    m_ahb_hmastlock,
    wrap_in_progress,
    one_kb_in_progress,
    single_ahb_wr,
    m_ahb_hwrite,
    m_ahb_htrans,
    \wrap_brst_count_reg[1]_0 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[3]_0 ,
    one_kb_in_progress_reg_0,
    AWREADY_i_reg,
    \FSM_sequential_ahb_wr_rd_cs_reg[2]_0 ,
    \wrap_brst_count_reg[0]_0 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[1]_0 ,
    one_kb_cross,
    \FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ,
    s_axi_wvalid_0,
    RRESP_1_i,
    wr_err_occured0,
    \FSM_sequential_ahb_wr_rd_cs_reg[1]_2 ,
    \axi_size_reg[0] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_0 ,
    \axi_size_reg[0]_0 ,
    \axi_size_reg[0]_1 ,
    \axi_size_reg[0]_2 ,
    \axi_size_reg[0]_3 ,
    \axi_size_reg[0]_4 ,
    \axi_size_reg[0]_5 ,
    \axi_size_reg[0]_6 ,
    \axi_size_reg[0]_7 ,
    \axi_size_reg[1] ,
    \axi_size_reg[1]_0 ,
    \axi_size_reg[1]_1 ,
    \axi_size_reg[1]_2 ,
    \axi_size_reg[0]_8 ,
    \axi_size_reg[1]_3 ,
    \axi_size_reg[1]_4 ,
    \axi_size_reg[1]_5 ,
    \axi_size_reg[1]_6 ,
    \axi_size_reg[1]_7 ,
    \axi_size_reg[0]_9 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[1]_3 ,
    \HSIZE_i_reg[2]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_0 ,
    \axi_size_reg[1]_8 ,
    \axi_size_reg[0]_10 ,
    \axi_size_reg[1]_9 ,
    \axi_size_reg[1]_10 ,
    \axi_size_reg[1]_11 ,
    \axi_size_reg[1]_12 ,
    \axi_size_reg[1]_13 ,
    \axi_size_reg[1]_14 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_1 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[2]_1 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ,
    m_ahb_hprot,
    m_ahb_hwdata,
    S,
    \axi_address_reg[9] ,
    D,
    Q,
    s_axi_aresetn_int,
    load_counter_sm,
    s_axi_aclk,
    p_1_in,
    p_2_in,
    ahb_burst,
    axi_lock,
    single_ahb_wr_reg_0,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_2 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_1 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_1 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_2 ,
    HWRITE_i_reg_0,
    \HBURST_i_reg[0]_0 ,
    s_axi_aresetn,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ,
    O,
    CO,
    s_axi_wvalid,
    \FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ,
    \M_AHB_HTRANS[0]_i_2_0 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ,
    m_ahb_hready,
    \M_AHB_HTRANS_reg[0]_0 ,
    \M_AHB_HTRANS_reg[0]_1 ,
    \M_AHB_HTRANS_reg[0]_2 ,
    \M_AHB_HTRANS[1]_i_3_0 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[0]_1 ,
    single_ahb_rd_xfer,
    out,
    \FSM_sequential_ahb_wr_rd_cs_reg[1]_5 ,
    \M_AHB_HTRANS[1]_i_4_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_2 ,
    \M_AHB_HTRANS[0]_i_2_1 ,
    \M_AHB_HTRANS[1]_i_3_1 ,
    \M_AHB_HTRANS[1]_i_4_1 ,
    m_ahb_hresp,
    RRESP_1_i_reg,
    write_in_progress,
    m_ahb_hrdata,
    \HSIZE_i_reg[2]_1 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[0]_2 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_3 ,
    \wrap_brst_count_reg[7]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_4 ,
    \HBURST_i_reg[2]_i_3 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_5 ,
    send_wrap_burst,
    load_counter_reg_0,
    E,
    \HWDATA_i_reg[31]_0 ,
    \HBURST_i_reg[2]_i_4 ,
    \HBURST_i_reg[2]_i_4_0 ,
    \HBURST_i_reg[2]_i_4_1 ,
    \HBURST_i_reg[2]_i_4_2 ,
    \HBURST_i_reg[2]_i_4_3 ,
    \HBURST_i_reg[2]_i_4_4 ,
    \HBURST_i_reg[2]_i_3_0 );
  output [31:0]m_ahb_haddr;
  output [2:0]m_ahb_hburst;
  output m_ahb_hmastlock;
  output wrap_in_progress;
  output one_kb_in_progress;
  output single_ahb_wr;
  output m_ahb_hwrite;
  output [1:0]m_ahb_htrans;
  output \wrap_brst_count_reg[1]_0 ;
  output [2:0]\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 ;
  output one_kb_in_progress_reg_0;
  output AWREADY_i_reg;
  output \FSM_sequential_ahb_wr_rd_cs_reg[2]_0 ;
  output \wrap_brst_count_reg[0]_0 ;
  output \FSM_sequential_ahb_wr_rd_cs_reg[1]_0 ;
  output one_kb_cross;
  output \FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ;
  output s_axi_wvalid_0;
  output RRESP_1_i;
  output wr_err_occured0;
  output [4:0]\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 ;
  output \axi_size_reg[0] ;
  output [1:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_0 ;
  output \axi_size_reg[0]_0 ;
  output \axi_size_reg[0]_1 ;
  output \axi_size_reg[0]_2 ;
  output \axi_size_reg[0]_3 ;
  output \axi_size_reg[0]_4 ;
  output \axi_size_reg[0]_5 ;
  output \axi_size_reg[0]_6 ;
  output \axi_size_reg[0]_7 ;
  output \axi_size_reg[1] ;
  output \axi_size_reg[1]_0 ;
  output \axi_size_reg[1]_1 ;
  output \axi_size_reg[1]_2 ;
  output \axi_size_reg[0]_8 ;
  output \axi_size_reg[1]_3 ;
  output \axi_size_reg[1]_4 ;
  output \axi_size_reg[1]_5 ;
  output \axi_size_reg[1]_6 ;
  output \axi_size_reg[1]_7 ;
  output \axi_size_reg[0]_9 ;
  output \FSM_sequential_ahb_wr_rd_cs_reg[1]_3 ;
  output [2:0]\HSIZE_i_reg[2]_0 ;
  output \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_0 ;
  output \axi_size_reg[1]_8 ;
  output \axi_size_reg[0]_10 ;
  output \axi_size_reg[1]_9 ;
  output \axi_size_reg[1]_10 ;
  output \axi_size_reg[1]_11 ;
  output \axi_size_reg[1]_12 ;
  output \axi_size_reg[1]_13 ;
  output \axi_size_reg[1]_14 ;
  output \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_1 ;
  output \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ;
  output [5:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_0 ;
  output [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_0 ;
  output [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ;
  output \FSM_sequential_ahb_wr_rd_cs_reg[2]_1 ;
  output \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ;
  output [2:0]m_ahb_hprot;
  output [31:0]m_ahb_hwdata;
  output [7:0]S;
  output [1:0]\axi_address_reg[9] ;
  input [1:0]D;
  input [2:0]Q;
  input s_axi_aresetn_int;
  input load_counter_sm;
  input s_axi_aclk;
  input [0:0]p_1_in;
  input [25:0]p_2_in;
  input [1:0]ahb_burst;
  input axi_lock;
  input single_ahb_wr_reg_0;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5]_0 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_2 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_1 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_1 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_2 ;
  input HWRITE_i_reg_0;
  input \HBURST_i_reg[0]_0 ;
  input s_axi_aresetn;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ;
  input [0:0]O;
  input [0:0]CO;
  input s_axi_wvalid;
  input \FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ;
  input \M_AHB_HTRANS[0]_i_2_0 ;
  input \FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ;
  input m_ahb_hready;
  input \M_AHB_HTRANS_reg[0]_0 ;
  input \M_AHB_HTRANS_reg[0]_1 ;
  input \M_AHB_HTRANS_reg[0]_2 ;
  input \M_AHB_HTRANS[1]_i_3_0 ;
  input \FSM_sequential_ahb_wr_rd_cs_reg[0]_1 ;
  input single_ahb_rd_xfer;
  input out;
  input \FSM_sequential_ahb_wr_rd_cs_reg[1]_5 ;
  input \M_AHB_HTRANS[1]_i_4_0 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_2 ;
  input \M_AHB_HTRANS[0]_i_2_1 ;
  input \M_AHB_HTRANS[1]_i_3_1 ;
  input \M_AHB_HTRANS[1]_i_4_1 ;
  input m_ahb_hresp;
  input RRESP_1_i_reg;
  input write_in_progress;
  input [4:0]m_ahb_hrdata;
  input [2:0]\HSIZE_i_reg[2]_1 ;
  input \FSM_sequential_ahb_wr_rd_cs_reg[0]_2 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_3 ;
  input [7:0]\wrap_brst_count_reg[7]_0 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_0 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_0 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_4 ;
  input [9:0]\HBURST_i_reg[2]_i_3 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_5 ;
  input send_wrap_burst;
  input load_counter_reg_0;
  input [0:0]E;
  input [31:0]\HWDATA_i_reg[31]_0 ;
  input \HBURST_i_reg[2]_i_4 ;
  input \HBURST_i_reg[2]_i_4_0 ;
  input \HBURST_i_reg[2]_i_4_1 ;
  input \HBURST_i_reg[2]_i_4_2 ;
  input \HBURST_i_reg[2]_i_4_3 ;
  input \HBURST_i_reg[2]_i_4_4 ;
  input \HBURST_i_reg[2]_i_3_0 ;

  wire [5:0]A;
  wire AWREADY_i_reg;
  wire [0:0]CO;
  wire [1:0]D;
  wire [0:0]E;
  wire \FSM_sequential_ahb_wr_rd_cs[0]_i_1_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[0]_i_2_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[0]_i_3_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[1]_i_1_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[1]_i_2_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[1]_i_4_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[2]_i_1_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_11_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_12_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_13_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_14_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_15_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_17_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_18_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_1_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_2_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_4_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_6_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs[3]_i_9_n_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[0]_1 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[0]_2 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[1]_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ;
  wire [4:0]\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[1]_3 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[1]_5 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[2]_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[2]_1 ;
  wire [2:0]\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_4_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_5_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_6_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_1_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_9_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_8_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_7_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_5_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_6_n_0 ;
  wire [1:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_10 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_11 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_13 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_14 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_15 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_8 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_9 ;
  wire [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_10 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_11 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_8 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_9 ;
  wire [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_10 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_11 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_13 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_14 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_15 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_8 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_9 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_10 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_11 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_13 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_14 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_15 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_8 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_9 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_7 ;
  wire [5:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_10 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_11 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_13 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_14 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_15 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_8 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_9 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_10 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_11 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_13 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_14 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_15 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_9 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_10 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_13 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_8 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_9 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_7 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_12 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_14 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_2 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_3 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_4 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_5 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_6 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_7 ;
  wire \HBURST_i_reg[0]_0 ;
  wire [9:0]\HBURST_i_reg[2]_i_3 ;
  wire \HBURST_i_reg[2]_i_3_0 ;
  wire \HBURST_i_reg[2]_i_4 ;
  wire \HBURST_i_reg[2]_i_4_0 ;
  wire \HBURST_i_reg[2]_i_4_1 ;
  wire \HBURST_i_reg[2]_i_4_2 ;
  wire \HBURST_i_reg[2]_i_4_3 ;
  wire \HBURST_i_reg[2]_i_4_4 ;
  wire [2:0]\HSIZE_i_reg[2]_0 ;
  wire [2:0]\HSIZE_i_reg[2]_1 ;
  wire [31:0]\HWDATA_i_reg[31]_0 ;
  wire HWRITE_i_reg_0;
  wire \M_AHB_HTRANS[0]_i_1_n_0 ;
  wire \M_AHB_HTRANS[0]_i_2_0 ;
  wire \M_AHB_HTRANS[0]_i_2_1 ;
  wire \M_AHB_HTRANS[0]_i_2_n_0 ;
  wire \M_AHB_HTRANS[0]_i_3_n_0 ;
  wire \M_AHB_HTRANS[0]_i_4_n_0 ;
  wire \M_AHB_HTRANS[0]_i_5_n_0 ;
  wire \M_AHB_HTRANS[0]_i_6_n_0 ;
  wire \M_AHB_HTRANS[0]_i_8_n_0 ;
  wire \M_AHB_HTRANS[0]_i_9_n_0 ;
  wire \M_AHB_HTRANS[1]_i_10_n_0 ;
  wire \M_AHB_HTRANS[1]_i_12_n_0 ;
  wire \M_AHB_HTRANS[1]_i_13_n_0 ;
  wire \M_AHB_HTRANS[1]_i_14_n_0 ;
  wire \M_AHB_HTRANS[1]_i_15_n_0 ;
  wire \M_AHB_HTRANS[1]_i_16_n_0 ;
  wire \M_AHB_HTRANS[1]_i_17_n_0 ;
  wire \M_AHB_HTRANS[1]_i_1_n_0 ;
  wire \M_AHB_HTRANS[1]_i_20_n_0 ;
  wire \M_AHB_HTRANS[1]_i_22_n_0 ;
  wire \M_AHB_HTRANS[1]_i_26_n_0 ;
  wire \M_AHB_HTRANS[1]_i_2_n_0 ;
  wire \M_AHB_HTRANS[1]_i_3_0 ;
  wire \M_AHB_HTRANS[1]_i_3_1 ;
  wire \M_AHB_HTRANS[1]_i_3_n_0 ;
  wire \M_AHB_HTRANS[1]_i_4_0 ;
  wire \M_AHB_HTRANS[1]_i_4_1 ;
  wire \M_AHB_HTRANS[1]_i_4_n_0 ;
  wire \M_AHB_HTRANS[1]_i_6_n_0 ;
  wire \M_AHB_HTRANS[1]_i_8_n_0 ;
  wire \M_AHB_HTRANS[1]_i_9_n_0 ;
  wire \M_AHB_HTRANS_reg[0]_0 ;
  wire \M_AHB_HTRANS_reg[0]_1 ;
  wire \M_AHB_HTRANS_reg[0]_2 ;
  wire [0:0]O;
  wire [2:0]Q;
  wire RRESP_1_i;
  wire RRESP_1_i_reg;
  wire [7:0]S;
  wire [1:0]ahb_burst;
  wire [1:1]ahb_wr_rd_cs;
  wire [1:0]\axi_address_reg[9] ;
  wire axi_lock;
  wire \axi_size_reg[0] ;
  wire \axi_size_reg[0]_0 ;
  wire \axi_size_reg[0]_1 ;
  wire \axi_size_reg[0]_10 ;
  wire \axi_size_reg[0]_2 ;
  wire \axi_size_reg[0]_3 ;
  wire \axi_size_reg[0]_4 ;
  wire \axi_size_reg[0]_5 ;
  wire \axi_size_reg[0]_6 ;
  wire \axi_size_reg[0]_7 ;
  wire \axi_size_reg[0]_8 ;
  wire \axi_size_reg[0]_9 ;
  wire \axi_size_reg[1] ;
  wire \axi_size_reg[1]_0 ;
  wire \axi_size_reg[1]_1 ;
  wire \axi_size_reg[1]_10 ;
  wire \axi_size_reg[1]_11 ;
  wire \axi_size_reg[1]_12 ;
  wire \axi_size_reg[1]_13 ;
  wire \axi_size_reg[1]_14 ;
  wire \axi_size_reg[1]_2 ;
  wire \axi_size_reg[1]_3 ;
  wire \axi_size_reg[1]_4 ;
  wire \axi_size_reg[1]_5 ;
  wire \axi_size_reg[1]_6 ;
  wire \axi_size_reg[1]_7 ;
  wire \axi_size_reg[1]_8 ;
  wire \axi_size_reg[1]_9 ;
  wire [31:1]data4;
  wire load_counter;
  wire load_counter_reg_0;
  wire load_counter_sm;
  wire [31:0]m_ahb_haddr;
  wire [2:0]m_ahb_hburst;
  wire m_ahb_hmastlock;
  wire [2:0]m_ahb_hprot;
  wire [4:0]m_ahb_hrdata;
  wire m_ahb_hready;
  wire m_ahb_hresp;
  wire [1:0]m_ahb_htrans;
  wire [31:0]m_ahb_hwdata;
  wire m_ahb_hwrite;
  wire one_kb_cross;
  wire one_kb_in_progress;
  wire one_kb_in_progress_i_1_n_0;
  wire one_kb_in_progress_i_3_n_0;
  wire one_kb_in_progress_i_4_n_0;
  wire one_kb_in_progress_i_5_n_0;
  wire one_kb_in_progress_i_6_n_0;
  wire one_kb_in_progress_i_7_n_0;
  wire one_kb_in_progress_i_8_n_0;
  wire one_kb_in_progress_i_9_n_0;
  wire one_kb_in_progress_reg_0;
  wire onekb_cross_access_i_1_n_0;
  wire onekb_cross_access_reg_n_0;
  wire out;
  wire p_0_out_carry_i_10_n_0;
  wire p_0_out_carry_i_11_n_0;
  wire p_0_out_carry_i_12_n_0;
  wire p_0_out_carry_i_13_n_0;
  wire p_0_out_carry_i_7_n_0;
  wire p_0_out_carry_i_8_n_0;
  wire p_0_out_carry_i_9_n_0;
  wire p_0_out_carry_n_10;
  wire p_0_out_carry_n_11;
  wire p_0_out_carry_n_12;
  wire p_0_out_carry_n_13;
  wire p_0_out_carry_n_14;
  wire p_0_out_carry_n_15;
  wire p_0_out_carry_n_2;
  wire p_0_out_carry_n_3;
  wire p_0_out_carry_n_4;
  wire p_0_out_carry_n_5;
  wire p_0_out_carry_n_6;
  wire p_0_out_carry_n_7;
  wire p_0_out_carry_n_9;
  wire [0:0]p_1_in;
  wire [25:0]p_2_in;
  wire [2:2]p_3_out__0;
  wire s_axi_aclk;
  wire s_axi_aresetn;
  wire s_axi_aresetn_int;
  wire s_axi_wvalid;
  wire s_axi_wvalid_0;
  wire send_wr_data;
  wire send_wrap_burst;
  wire single_ahb_rd_xfer;
  wire single_ahb_wr;
  wire single_ahb_wr_reg_0;
  wire wr_err_occured0;
  wire \wrap_brst_count[0]_i_1_n_0 ;
  wire \wrap_brst_count[7]_i_1_n_0 ;
  wire [7:0]wrap_brst_count_reg;
  wire \wrap_brst_count_reg[0]_0 ;
  wire \wrap_brst_count_reg[1]_0 ;
  wire [7:0]\wrap_brst_count_reg[7]_0 ;
  wire wrap_in_progress;
  wire wrap_in_progress_i_1_n_0;
  wire write_in_progress;
  wire [7:7]\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_CO_UNCONNECTED ;
  wire [7:6]\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_CO_UNCONNECTED ;
  wire [7:7]\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_O_UNCONNECTED ;
  wire [7:6]\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_CO_UNCONNECTED ;
  wire [7:7]\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_O_UNCONNECTED ;
  wire [7:6]NLW_p_0_out_carry_CO_UNCONNECTED;
  wire [7:7]NLW_p_0_out_carry_O_UNCONNECTED;

  LUT6 #(
    .INIT(64'h308FF0F03F8FFFFF)) 
    \FSM_sequential_ahb_wr_rd_cs[0]_i_1 
       (.I0(out),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I3(ahb_wr_rd_cs),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I5(\FSM_sequential_ahb_wr_rd_cs[0]_i_2_n_0 ),
        .O(\FSM_sequential_ahb_wr_rd_cs[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF4FCF4FCF4FFF4FC)) 
    \FSM_sequential_ahb_wr_rd_cs[0]_i_2 
       (.I0(\wrap_brst_count_reg[1]_0 ),
        .I1(ahb_wr_rd_cs),
        .I2(\FSM_sequential_ahb_wr_rd_cs[0]_i_3_n_0 ),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I4(single_ahb_rd_xfer),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[1]_5 ),
        .O(\FSM_sequential_ahb_wr_rd_cs[0]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'h080808F8)) 
    \FSM_sequential_ahb_wr_rd_cs[0]_i_3 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I1(single_ahb_wr),
        .I2(ahb_wr_rd_cs),
        .I3(s_axi_wvalid),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .O(\FSM_sequential_ahb_wr_rd_cs[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAFFAAFAAAFFA8FAA)) 
    \FSM_sequential_ahb_wr_rd_cs[1]_i_1 
       (.I0(\FSM_sequential_ahb_wr_rd_cs[1]_i_2_n_0 ),
        .I1(s_axi_wvalid),
        .I2(ahb_wr_rd_cs),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ),
        .O(\FSM_sequential_ahb_wr_rd_cs[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h5555505155554041)) 
    \FSM_sequential_ahb_wr_rd_cs[1]_i_2 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I1(ahb_wr_rd_cs),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[1]_5 ),
        .I4(\FSM_sequential_ahb_wr_rd_cs[1]_i_4_n_0 ),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ),
        .O(\FSM_sequential_ahb_wr_rd_cs[1]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_sequential_ahb_wr_rd_cs[1]_i_4 
       (.I0(\wrap_brst_count_reg[0]_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(\FSM_sequential_ahb_wr_rd_cs[1]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h00EE3F0033CC3300)) 
    \FSM_sequential_ahb_wr_rd_cs[2]_i_1 
       (.I0(\wrap_brst_count_reg[0]_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I2(out),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(ahb_wr_rd_cs),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(\FSM_sequential_ahb_wr_rd_cs[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00303032)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_1 
       (.I0(one_kb_in_progress_reg_0),
        .I1(\FSM_sequential_ahb_wr_rd_cs[3]_i_4_n_0 ),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I4(ahb_wr_rd_cs),
        .I5(\FSM_sequential_ahb_wr_rd_cs[3]_i_6_n_0 ),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_11 
       (.I0(m_ahb_haddr[9]),
        .I1(m_ahb_haddr[4]),
        .I2(m_ahb_haddr[5]),
        .I3(m_ahb_haddr[3]),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_11_n_0 ));
  LUT4 #(
    .INIT(16'hFFDF)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_12 
       (.I0(onekb_cross_access_reg_n_0),
        .I1(wrap_in_progress),
        .I2(m_ahb_haddr[7]),
        .I3(\HSIZE_i_reg[2]_0 [2]),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_12_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h15)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_13 
       (.I0(\HSIZE_i_reg[2]_0 [1]),
        .I1(m_ahb_haddr[2]),
        .I2(m_ahb_haddr[1]),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_13_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'hFEAA)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_14 
       (.I0(\HSIZE_i_reg[2]_0 [0]),
        .I1(\HSIZE_i_reg[2]_0 [1]),
        .I2(m_ahb_haddr[0]),
        .I3(m_ahb_haddr[2]),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_14_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h08008080)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_15 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(ahb_wr_rd_cs),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_15_n_0 ));
  LUT6 #(
    .INIT(64'h2030E82020306020)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_17 
       (.I0(ahb_wr_rd_cs),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(m_ahb_hready),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I5(out),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_17_n_0 ));
  LUT4 #(
    .INIT(16'h0001)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_18 
       (.I0(wrap_brst_count_reg[4]),
        .I1(wrap_brst_count_reg[6]),
        .I2(wrap_brst_count_reg[7]),
        .I3(wrap_brst_count_reg[5]),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_18_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF10000000)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_2 
       (.I0(\wrap_brst_count_reg[0]_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(ahb_wr_rd_cs),
        .I3(\wrap_brst_count_reg[1]_0 ),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I5(\FSM_sequential_ahb_wr_rd_cs[3]_i_9_n_0 ),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAAAA8AAAAAAAA)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_3 
       (.I0(one_kb_in_progress),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0]_2 ),
        .I2(\FSM_sequential_ahb_wr_rd_cs[3]_i_11_n_0 ),
        .I3(\FSM_sequential_ahb_wr_rd_cs[3]_i_12_n_0 ),
        .I4(\FSM_sequential_ahb_wr_rd_cs[3]_i_13_n_0 ),
        .I5(\FSM_sequential_ahb_wr_rd_cs[3]_i_14_n_0 ),
        .O(one_kb_in_progress_reg_0));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_4 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFEFEEEE)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_6 
       (.I0(\M_AHB_HTRANS[1]_i_12_n_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs[3]_i_15_n_0 ),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[0]_1 ),
        .I3(single_ahb_rd_xfer),
        .I4(AWREADY_i_reg),
        .I5(\FSM_sequential_ahb_wr_rd_cs[3]_i_17_n_0 ),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h00000020)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_7 
       (.I0(\FSM_sequential_ahb_wr_rd_cs[3]_i_18_n_0 ),
        .I1(wrap_brst_count_reg[0]),
        .I2(wrap_brst_count_reg[1]),
        .I3(wrap_brst_count_reg[3]),
        .I4(wrap_brst_count_reg[2]),
        .O(\wrap_brst_count_reg[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'hFFFFFFDF)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_8 
       (.I0(\FSM_sequential_ahb_wr_rd_cs[3]_i_18_n_0 ),
        .I1(wrap_brst_count_reg[1]),
        .I2(wrap_brst_count_reg[0]),
        .I3(wrap_brst_count_reg[3]),
        .I4(wrap_brst_count_reg[2]),
        .O(\wrap_brst_count_reg[1]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'h3FC30001)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_9 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[1]_5 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I3(ahb_wr_rd_cs),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .O(\FSM_sequential_ahb_wr_rd_cs[3]_i_9_n_0 ));
  (* FSM_ENCODED_STATES = "ahb_rd_last:1100,ahb_rd_data_incr:1101,ahb_last_wait:0100,ahb_rd_single:1010,ahb_last_addr:0111,ahb_onekb_last:0101,ahb_incr_addr:1001,ahb_rd_addr:1011,ahb_idle:0000,ahb_wr_incr:0011,ahb_wr_single:0010,ahb_wr_addr:0001,ahb_wr_wait:1000,ahb_last:0110,ahb_rd_wait:1110" *) 
  FDRE \FSM_sequential_ahb_wr_rd_cs_reg[0] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_ahb_wr_rd_cs[3]_i_1_n_0 ),
        .D(\FSM_sequential_ahb_wr_rd_cs[0]_i_1_n_0 ),
        .Q(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .R(s_axi_aresetn_int));
  (* FSM_ENCODED_STATES = "ahb_rd_last:1100,ahb_rd_data_incr:1101,ahb_last_wait:0100,ahb_rd_single:1010,ahb_last_addr:0111,ahb_onekb_last:0101,ahb_incr_addr:1001,ahb_rd_addr:1011,ahb_idle:0000,ahb_wr_incr:0011,ahb_wr_single:0010,ahb_wr_addr:0001,ahb_wr_wait:1000,ahb_last:0110,ahb_rd_wait:1110" *) 
  FDRE \FSM_sequential_ahb_wr_rd_cs_reg[1] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_ahb_wr_rd_cs[3]_i_1_n_0 ),
        .D(\FSM_sequential_ahb_wr_rd_cs[1]_i_1_n_0 ),
        .Q(ahb_wr_rd_cs),
        .R(s_axi_aresetn_int));
  (* FSM_ENCODED_STATES = "ahb_rd_last:1100,ahb_rd_data_incr:1101,ahb_last_wait:0100,ahb_rd_single:1010,ahb_last_addr:0111,ahb_onekb_last:0101,ahb_incr_addr:1001,ahb_rd_addr:1011,ahb_idle:0000,ahb_wr_incr:0011,ahb_wr_single:0010,ahb_wr_addr:0001,ahb_wr_wait:1000,ahb_last:0110,ahb_rd_wait:1110" *) 
  FDRE \FSM_sequential_ahb_wr_rd_cs_reg[2] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_ahb_wr_rd_cs[3]_i_1_n_0 ),
        .D(\FSM_sequential_ahb_wr_rd_cs[2]_i_1_n_0 ),
        .Q(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .R(s_axi_aresetn_int));
  (* FSM_ENCODED_STATES = "ahb_rd_last:1100,ahb_rd_data_incr:1101,ahb_last_wait:0100,ahb_rd_single:1010,ahb_last_addr:0111,ahb_onekb_last:0101,ahb_incr_addr:1001,ahb_rd_addr:1011,ahb_idle:0000,ahb_wr_incr:0011,ahb_wr_single:0010,ahb_wr_addr:0001,ahb_wr_wait:1000,ahb_last:0110,ahb_rd_wait:1110" *) 
  FDRE \FSM_sequential_ahb_wr_rd_cs_reg[3] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_ahb_wr_rd_cs[3]_i_1_n_0 ),
        .D(\FSM_sequential_ahb_wr_rd_cs[3]_i_2_n_0 ),
        .Q(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h4000)) 
    \FSM_sequential_axi_read_cs[2]_i_6 
       (.I0(ahb_wr_rd_cs),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ));
  LUT4 #(
    .INIT(16'hDCDF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[10]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_13 ),
        .I1(\HSIZE_i_reg[2]_1 [1]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(data4[10]),
        .O(\axi_size_reg[1]_13 ));
  LUT4 #(
    .INIT(16'hDCDF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_12 ),
        .I1(\HSIZE_i_reg[2]_1 [1]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(data4[11]),
        .O(\axi_size_reg[1]_14 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[12]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_11 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[12]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_12 ),
        .O(\axi_size_reg[0] ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[13]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_10 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[13]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_11 ),
        .O(\axi_size_reg[0]_0 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[14]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_9 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[14]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_10 ),
        .O(\axi_size_reg[0]_1 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[15]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_8 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[15]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_9 ),
        .O(\axi_size_reg[0]_2 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[16]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_15 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[16]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_8 ),
        .O(\axi_size_reg[0]_3 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[17]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_14 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[17]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_15 ),
        .O(\axi_size_reg[0]_4 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[18]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_13 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[18]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_14 ),
        .O(\axi_size_reg[0]_5 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[19]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_12 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[19]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_13 ),
        .O(\axi_size_reg[0]_6 ));
  LUT6 #(
    .INIT(64'h0000FCFFAC5FAC5F)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_7 
       (.I0(m_ahb_haddr[0]),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ),
        .I2(\wrap_brst_count_reg[7]_0 [1]),
        .I3(m_ahb_haddr[1]),
        .I4(data4[1]),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_1 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[20]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_11 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[20]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_12 ),
        .O(\axi_size_reg[0]_7 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[21]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_10 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_11 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[21]),
        .O(\axi_size_reg[1] ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[22]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_9 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_10 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[22]),
        .O(\axi_size_reg[1]_0 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[23]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_8 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_9 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[23]),
        .O(\axi_size_reg[1]_1 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[24]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_15 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_8 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[24]),
        .O(\axi_size_reg[1]_2 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[25]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_14 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[25]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_15 ),
        .O(\axi_size_reg[0]_8 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[26]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_13 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_14 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[26]),
        .O(\axi_size_reg[1]_3 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[27]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_12 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_13 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[27]),
        .O(\axi_size_reg[1]_4 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[28]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_11 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_12 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[28]),
        .O(\axi_size_reg[1]_5 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[29]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_10 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_11 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[29]),
        .O(\axi_size_reg[1]_6 ));
  LUT5 #(
    .INIT(32'hFFFF80B0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_14 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(m_ahb_haddr[2]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_4_n_0 ),
        .O(\axi_size_reg[1]_8 ));
  LUT6 #(
    .INIT(64'h05030500050F050F)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_4 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_5_n_0 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\HSIZE_i_reg[2]_1 [0]),
        .I4(m_ahb_haddr[2]),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_6_n_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h3A3A3F0035353F3F)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_5 
       (.I0(m_ahb_haddr[1]),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_13 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ),
        .I4(\wrap_brst_count_reg[7]_0 [1]),
        .I5(m_ahb_haddr[2]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h7007070777777777)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_6 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ),
        .I1(data4[2]),
        .I2(m_ahb_haddr[2]),
        .I3(m_ahb_haddr[0]),
        .I4(m_ahb_haddr[1]),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_4 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h37F733F337F73FFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[30]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_9 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_10 ),
        .I4(\HSIZE_i_reg[2]_1 [0]),
        .I5(data4[30]),
        .O(\axi_size_reg[1]_7 ));
  LUT6 #(
    .INIT(64'h0407FFFFF4F7FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_5 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_8 ),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(data4[31]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_9 ),
        .O(\axi_size_reg[0]_9 ));
  LUT6 #(
    .INIT(64'hFAFFCCCC0A00CCCC)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_n_0 ),
        .I1(\HBURST_i_reg[2]_i_3 [3]),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_5 ),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[1]_0 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I5(m_ahb_haddr[3]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h888888888AA88888)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_n_0 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_3 ),
        .I2(m_ahb_haddr[2]),
        .I3(m_ahb_haddr[3]),
        .I4(\wrap_brst_count_reg[7]_0 [1]),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0B000B0300000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_4 
       (.I0(\wrap_brst_count_reg[1]_0 ),
        .I1(ahb_wr_rd_cs),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_2 ),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I4(single_ahb_wr),
        .I5(m_ahb_hready),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_0 ));
  LUT6 #(
    .INIT(64'h00000000AAAABFEA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_0 ),
        .I1(one_kb_in_progress_i_7_n_0),
        .I2(m_ahb_haddr[0]),
        .I3(m_ahb_haddr[3]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_9_n_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h850085000300CF00)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_9 
       (.I0(one_kb_in_progress_i_7_n_0),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ),
        .I2(m_ahb_haddr[3]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_0 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_12 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_4 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hC40437F7FFFFFFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_3 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_12 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_4 ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_8_n_0 ),
        .I4(m_ahb_haddr[4]),
        .I5(\HSIZE_i_reg[2]_1 [1]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_8 
       (.I0(m_ahb_haddr[3]),
        .I1(m_ahb_haddr[2]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'h0078000000000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_9 
       (.I0(one_kb_in_progress_i_7_n_0),
        .I1(m_ahb_haddr[3]),
        .I2(m_ahb_haddr[4]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_0 ));
  LUT6 #(
    .INIT(64'h0E02FFFF0E020000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_4 
       (.I0(data4[5]),
        .I1(\HSIZE_i_reg[2]_1 [0]),
        .I2(\HSIZE_i_reg[2]_1 [1]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_10 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_7_n_0 ),
        .O(\axi_size_reg[0]_10 ));
  LUT6 #(
    .INIT(64'h2AAAAAAAAAAAAAAA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_7 
       (.I0(m_ahb_haddr[5]),
        .I1(m_ahb_haddr[4]),
        .I2(m_ahb_haddr[2]),
        .I3(m_ahb_haddr[3]),
        .I4(\wrap_brst_count_reg[7]_0 [3]),
        .I5(\HSIZE_i_reg[2]_1 [1]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h7F)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_8 
       (.I0(m_ahb_haddr[4]),
        .I1(m_ahb_haddr[2]),
        .I2(m_ahb_haddr[3]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ));
  LUT4 #(
    .INIT(16'hDCDF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[6]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_9 ),
        .I1(\HSIZE_i_reg[2]_1 [1]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(data4[6]),
        .O(\axi_size_reg[1]_9 ));
  LUT4 #(
    .INIT(16'hDCDF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_8 ),
        .I1(\HSIZE_i_reg[2]_1 [1]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(data4[7]),
        .O(\axi_size_reg[1]_10 ));
  LUT1 #(
    .INIT(2'h1)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_5 
       (.I0(m_ahb_haddr[1]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hDCDF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_15 ),
        .I1(\HSIZE_i_reg[2]_1 [1]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(data4[8]),
        .O(\axi_size_reg[1]_11 ));
  LUT1 #(
    .INIT(2'h1)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_6 
       (.I0(m_ahb_haddr[2]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'hDCDF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[9]_i_2 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_14 ),
        .I1(\HSIZE_i_reg[2]_1 [1]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(data4[9]),
        .O(\axi_size_reg[1]_12 ));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_2 ),
        .Q(m_ahb_haddr[0]),
        .R(1'b0));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[10] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[4]),
        .Q(m_ahb_haddr[10]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[5]),
        .Q(m_ahb_haddr[11]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[12] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[6]),
        .Q(m_ahb_haddr[12]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[13] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[7]),
        .Q(m_ahb_haddr[13]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[14] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[8]),
        .Q(m_ahb_haddr[14]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[9]),
        .Q(m_ahb_haddr[15]),
        .R(s_axi_aresetn_int));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_0 ),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_8 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_9 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_10 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_11 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_13 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_14 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_15 }),
        .S(m_ahb_haddr[15:8]));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[10]),
        .Q(m_ahb_haddr[16]),
        .R(s_axi_aresetn_int));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_0 ),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(data4[16:9]),
        .S(m_ahb_haddr[16:9]));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_0 ),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_8 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_9 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_10 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_11 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_0 }),
        .S(m_ahb_haddr[16:9]));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[17] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[11]),
        .Q(m_ahb_haddr[17]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[18] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[12]),
        .Q(m_ahb_haddr[18]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[19] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[13]),
        .Q(m_ahb_haddr[19]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_1 ),
        .Q(m_ahb_haddr[1]),
        .R(1'b0));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[20] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[14]),
        .Q(m_ahb_haddr[20]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[21] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[15]),
        .Q(m_ahb_haddr[21]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[22] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[16]),
        .Q(m_ahb_haddr[22]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[17]),
        .Q(m_ahb_haddr[23]),
        .R(s_axi_aresetn_int));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15]_i_3_n_0 ),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_8 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_9 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_10 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_11 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_13 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_14 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_15 }),
        .S(m_ahb_haddr[23:16]));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[18]),
        .Q(m_ahb_haddr[24]),
        .R(s_axi_aresetn_int));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_4_n_0 ),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_8 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_9 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_10 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_11 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_13 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_14 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_15 }),
        .S(m_ahb_haddr[24:17]));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_i_3_n_0 ),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O(data4[24:17]),
        .S(m_ahb_haddr[24:17]));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[25] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[19]),
        .Q(m_ahb_haddr[25]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[26] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[20]),
        .Q(m_ahb_haddr[26]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[27] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[21]),
        .Q(m_ahb_haddr[27]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[28] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[22]),
        .Q(m_ahb_haddr[28]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[29] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[23]),
        .Q(m_ahb_haddr[29]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_1 ),
        .Q(m_ahb_haddr[2]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[30] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[24]),
        .Q(m_ahb_haddr[30]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[25]),
        .Q(m_ahb_haddr[31]),
        .R(s_axi_aresetn_int));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23]_i_3_n_0 ),
        .CI_TOP(1'b0),
        .CO({\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_CO_UNCONNECTED [7],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_8 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_9 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_10 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_11 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_13 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_14 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_6_n_15 }),
        .S(m_ahb_haddr[31:24]));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_4_n_0 ),
        .CI_TOP(1'b0),
        .CO({\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_CO_UNCONNECTED [7:6],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_7_O_UNCONNECTED [7],data4[31:25]}),
        .S({1'b0,m_ahb_haddr[31:25]}));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8 
       (.CI(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24]_i_3_n_0 ),
        .CI_TOP(1'b0),
        .CO({\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_CO_UNCONNECTED [7:6],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_O_UNCONNECTED [7],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_9 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_10 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_11 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_13 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_14 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_i_8_n_15 }),
        .S({1'b0,m_ahb_haddr[31:25]}));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_1_n_0 ),
        .Q(m_ahb_haddr[3]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_2 ),
        .Q(m_ahb_haddr[4]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5]_0 ),
        .Q(m_ahb_haddr[5]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[6] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[0]),
        .Q(m_ahb_haddr[6]),
        .R(s_axi_aresetn_int));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[1]),
        .Q(m_ahb_haddr[7]),
        .R(s_axi_aresetn_int));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4 
       (.CI(1'b0),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,m_ahb_haddr[1],1'b0}),
        .O({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_8 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_9 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_10 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 [2],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7]_i_4_n_13 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 [1:0]}),
        .S({m_ahb_haddr[7:2],\GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_5_n_0 ,m_ahb_haddr[0]}));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[2]),
        .Q(m_ahb_haddr[8]),
        .R(s_axi_aresetn_int));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4 
       (.CI(m_ahb_haddr[0]),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_4_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .O({data4[8:5],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_0 ,data4[2:1]}),
        .S(m_ahb_haddr[8:1]));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5 
       (.CI(1'b0),
        .CI_TOP(1'b0),
        .CO({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_0 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_1 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_2 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_3 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_4 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_5 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_6 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,m_ahb_haddr[2],1'b0}),
        .O({\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_0 [5:2],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_12 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_0 [1],\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_i_5_n_14 ,\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_0 [0]}),
        .S({m_ahb_haddr[8:3],\GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_6_n_0 ,m_ahb_haddr[1]}));
  FDRE \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[9] 
       (.C(s_axi_aclk),
        .CE(p_1_in),
        .D(p_2_in[3]),
        .Q(m_ahb_haddr[9]),
        .R(s_axi_aresetn_int));
  LUT4 #(
    .INIT(16'h56A6)) 
    \HBURST_i[2]_i_10 
       (.I0(\HBURST_i_reg[2]_i_3 [5]),
        .I1(\HBURST_i_reg[2]_i_4_2 ),
        .I2(\HSIZE_i_reg[2]_1 [2]),
        .I3(\wrap_brst_count_reg[7]_0 [5]),
        .O(S[5]));
  LUT4 #(
    .INIT(16'h56A6)) 
    \HBURST_i[2]_i_11 
       (.I0(\HBURST_i_reg[2]_i_3 [4]),
        .I1(\HBURST_i_reg[2]_i_4_1 ),
        .I2(\HSIZE_i_reg[2]_1 [2]),
        .I3(\wrap_brst_count_reg[7]_0 [4]),
        .O(S[4]));
  LUT4 #(
    .INIT(16'h56A6)) 
    \HBURST_i[2]_i_12 
       (.I0(\HBURST_i_reg[2]_i_3 [3]),
        .I1(\HBURST_i_reg[2]_i_4_0 ),
        .I2(\HSIZE_i_reg[2]_1 [2]),
        .I3(\wrap_brst_count_reg[7]_0 [3]),
        .O(S[3]));
  LUT2 #(
    .INIT(4'h6)) 
    \HBURST_i[2]_i_13 
       (.I0(\HBURST_i_reg[2]_i_3 [2]),
        .I1(\HBURST_i_reg[2]_i_4 ),
        .O(S[2]));
  LUT6 #(
    .INIT(64'h555599A9AAAA9AAA)) 
    \HBURST_i[2]_i_14 
       (.I0(\HBURST_i_reg[2]_i_3 [1]),
        .I1(\HSIZE_i_reg[2]_1 [1]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(\wrap_brst_count_reg[7]_0 [0]),
        .I4(\HSIZE_i_reg[2]_1 [2]),
        .I5(\wrap_brst_count_reg[7]_0 [1]),
        .O(S[1]));
  LUT5 #(
    .INIT(32'h6665AAAA)) 
    \HBURST_i[2]_i_15 
       (.I0(\HBURST_i_reg[2]_i_3 [0]),
        .I1(\HSIZE_i_reg[2]_1 [2]),
        .I2(\HSIZE_i_reg[2]_1 [0]),
        .I3(\HSIZE_i_reg[2]_1 [1]),
        .I4(\wrap_brst_count_reg[7]_0 [0]),
        .O(S[0]));
  LUT6 #(
    .INIT(64'h9A999AAAAAAAAAAA)) 
    \HBURST_i[2]_i_6 
       (.I0(\HBURST_i_reg[2]_i_3 [9]),
        .I1(\HSIZE_i_reg[2]_1 [2]),
        .I2(\wrap_brst_count_reg[7]_0 [6]),
        .I3(\HSIZE_i_reg[2]_1 [0]),
        .I4(\wrap_brst_count_reg[7]_0 [7]),
        .I5(\HSIZE_i_reg[2]_1 [1]),
        .O(\axi_address_reg[9] [1]));
  LUT6 #(
    .INIT(64'h9A999AAA9AAA9AAA)) 
    \HBURST_i[2]_i_7 
       (.I0(\HBURST_i_reg[2]_i_3 [8]),
        .I1(\HSIZE_i_reg[2]_1 [2]),
        .I2(\HBURST_i_reg[2]_i_3_0 ),
        .I3(\HSIZE_i_reg[2]_1 [0]),
        .I4(\wrap_brst_count_reg[7]_0 [6]),
        .I5(\HSIZE_i_reg[2]_1 [1]),
        .O(\axi_address_reg[9] [0]));
  LUT4 #(
    .INIT(16'h56A6)) 
    \HBURST_i[2]_i_8 
       (.I0(\HBURST_i_reg[2]_i_3 [7]),
        .I1(\HBURST_i_reg[2]_i_4_4 ),
        .I2(\HSIZE_i_reg[2]_1 [2]),
        .I3(\wrap_brst_count_reg[7]_0 [7]),
        .O(S[7]));
  LUT4 #(
    .INIT(16'h56A6)) 
    \HBURST_i[2]_i_9 
       (.I0(\HBURST_i_reg[2]_i_3 [6]),
        .I1(\HBURST_i_reg[2]_i_4_3 ),
        .I2(\HSIZE_i_reg[2]_1 [2]),
        .I3(\wrap_brst_count_reg[7]_0 [6]),
        .O(S[6]));
  FDRE \HBURST_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\HBURST_i_reg[0]_0 ),
        .Q(m_ahb_hburst[0]),
        .R(1'b0));
  FDRE \HBURST_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ahb_burst[0]),
        .Q(m_ahb_hburst[1]),
        .R(s_axi_aresetn_int));
  FDRE \HBURST_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(ahb_burst[1]),
        .Q(m_ahb_hburst[2]),
        .R(s_axi_aresetn_int));
  FDRE HLOCK_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_lock),
        .Q(m_ahb_hmastlock),
        .R(s_axi_aresetn_int));
  FDSE \HPROT_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(D[0]),
        .Q(m_ahb_hprot[0]),
        .S(s_axi_aresetn_int));
  FDSE \HPROT_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(D[1]),
        .Q(m_ahb_hprot[1]),
        .S(s_axi_aresetn_int));
  FDRE \HPROT_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_3_out__0),
        .Q(m_ahb_hprot[2]),
        .R(s_axi_aresetn_int));
  FDRE \HSIZE_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\HSIZE_i_reg[2]_1 [0]),
        .Q(\HSIZE_i_reg[2]_0 [0]),
        .R(s_axi_aresetn_int));
  FDRE \HSIZE_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\HSIZE_i_reg[2]_1 [1]),
        .Q(\HSIZE_i_reg[2]_0 [1]),
        .R(s_axi_aresetn_int));
  FDRE \HSIZE_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\HSIZE_i_reg[2]_1 [2]),
        .Q(\HSIZE_i_reg[2]_0 [2]),
        .R(s_axi_aresetn_int));
  LUT5 #(
    .INIT(32'h08000088)) 
    \HWDATA_i[31]_i_1 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(ahb_wr_rd_cs),
        .O(send_wr_data));
  FDRE \HWDATA_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [0]),
        .Q(m_ahb_hwdata[0]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[10] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [10]),
        .Q(m_ahb_hwdata[10]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[11] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [11]),
        .Q(m_ahb_hwdata[11]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[12] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [12]),
        .Q(m_ahb_hwdata[12]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[13] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [13]),
        .Q(m_ahb_hwdata[13]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[14] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [14]),
        .Q(m_ahb_hwdata[14]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[15] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [15]),
        .Q(m_ahb_hwdata[15]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[16] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [16]),
        .Q(m_ahb_hwdata[16]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[17] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [17]),
        .Q(m_ahb_hwdata[17]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[18] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [18]),
        .Q(m_ahb_hwdata[18]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[19] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [19]),
        .Q(m_ahb_hwdata[19]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [1]),
        .Q(m_ahb_hwdata[1]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[20] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [20]),
        .Q(m_ahb_hwdata[20]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[21] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [21]),
        .Q(m_ahb_hwdata[21]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[22] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [22]),
        .Q(m_ahb_hwdata[22]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[23] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [23]),
        .Q(m_ahb_hwdata[23]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[24] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [24]),
        .Q(m_ahb_hwdata[24]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[25] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [25]),
        .Q(m_ahb_hwdata[25]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[26] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [26]),
        .Q(m_ahb_hwdata[26]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[27] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [27]),
        .Q(m_ahb_hwdata[27]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[28] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [28]),
        .Q(m_ahb_hwdata[28]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[29] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [29]),
        .Q(m_ahb_hwdata[29]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [2]),
        .Q(m_ahb_hwdata[2]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[30] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [30]),
        .Q(m_ahb_hwdata[30]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[31] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [31]),
        .Q(m_ahb_hwdata[31]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[3] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [3]),
        .Q(m_ahb_hwdata[3]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[4] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [4]),
        .Q(m_ahb_hwdata[4]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[5] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [5]),
        .Q(m_ahb_hwdata[5]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[6] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [6]),
        .Q(m_ahb_hwdata[6]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[7] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [7]),
        .Q(m_ahb_hwdata[7]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[8] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [8]),
        .Q(m_ahb_hwdata[8]),
        .R(s_axi_aresetn_int));
  FDRE \HWDATA_i_reg[9] 
       (.C(s_axi_aclk),
        .CE(send_wr_data),
        .D(\HWDATA_i_reg[31]_0 [9]),
        .Q(m_ahb_hwdata[9]),
        .R(s_axi_aresetn_int));
  FDRE HWRITE_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(HWRITE_i_reg_0),
        .Q(m_ahb_hwrite),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h00000000EFEC0000)) 
    \M_AHB_HTRANS[0]_i_1 
       (.I0(\M_AHB_HTRANS[0]_i_2_n_0 ),
        .I1(\M_AHB_HTRANS[1]_i_2_n_0 ),
        .I2(\M_AHB_HTRANS[1]_i_4_n_0 ),
        .I3(m_ahb_htrans[0]),
        .I4(s_axi_aresetn),
        .I5(\M_AHB_HTRANS[1]_i_3_n_0 ),
        .O(\M_AHB_HTRANS[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1000100010301000)) 
    \M_AHB_HTRANS[0]_i_2 
       (.I0(\M_AHB_HTRANS[0]_i_3_n_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I3(ahb_wr_rd_cs),
        .I4(m_ahb_hready),
        .I5(\M_AHB_HTRANS[0]_i_4_n_0 ),
        .O(\M_AHB_HTRANS[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFCFC4)) 
    \M_AHB_HTRANS[0]_i_3 
       (.I0(\M_AHB_HTRANS[0]_i_5_n_0 ),
        .I1(\M_AHB_HTRANS[0]_i_6_n_0 ),
        .I2(one_kb_cross),
        .I3(one_kb_in_progress),
        .I4(\M_AHB_HTRANS[0]_i_2_1 ),
        .I5(\M_AHB_HTRANS[0]_i_2_0 ),
        .O(\M_AHB_HTRANS[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFF00FFFFFFFE)) 
    \M_AHB_HTRANS[0]_i_4 
       (.I0(one_kb_cross),
        .I1(\M_AHB_HTRANS[0]_i_2_1 ),
        .I2(single_ahb_wr),
        .I3(one_kb_in_progress),
        .I4(\M_AHB_HTRANS[0]_i_2_0 ),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .O(\M_AHB_HTRANS[0]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAAAAA2AA00000000)) 
    \M_AHB_HTRANS[0]_i_5 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I1(\FSM_sequential_ahb_wr_rd_cs[3]_i_18_n_0 ),
        .I2(wrap_brst_count_reg[1]),
        .I3(wrap_brst_count_reg[0]),
        .I4(\M_AHB_HTRANS[0]_i_8_n_0 ),
        .I5(m_ahb_hready),
        .O(\M_AHB_HTRANS[0]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFF7FF)) 
    \M_AHB_HTRANS[0]_i_6 
       (.I0(m_ahb_hready),
        .I1(\FSM_sequential_ahb_wr_rd_cs[3]_i_18_n_0 ),
        .I2(wrap_brst_count_reg[0]),
        .I3(wrap_brst_count_reg[1]),
        .I4(\M_AHB_HTRANS[0]_i_8_n_0 ),
        .I5(\M_AHB_HTRANS[0]_i_9_n_0 ),
        .O(\M_AHB_HTRANS[0]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \M_AHB_HTRANS[0]_i_8 
       (.I0(wrap_brst_count_reg[3]),
        .I1(wrap_brst_count_reg[2]),
        .O(\M_AHB_HTRANS[0]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \M_AHB_HTRANS[0]_i_9 
       (.I0(s_axi_wvalid),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .O(\M_AHB_HTRANS[0]_i_9_n_0 ));
  LUT4 #(
    .INIT(16'hEFEE)) 
    \M_AHB_HTRANS[1]_i_1 
       (.I0(\M_AHB_HTRANS[1]_i_2_n_0 ),
        .I1(\M_AHB_HTRANS[1]_i_3_n_0 ),
        .I2(\M_AHB_HTRANS[1]_i_4_n_0 ),
        .I3(m_ahb_htrans[1]),
        .O(\M_AHB_HTRANS[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFF400040004000)) 
    \M_AHB_HTRANS[1]_i_10 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I3(out),
        .I4(\M_AHB_HTRANS[1]_i_3_1 ),
        .I5(\M_AHB_HTRANS[1]_i_20_n_0 ),
        .O(\M_AHB_HTRANS[1]_i_10_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h00000020)) 
    \M_AHB_HTRANS[1]_i_12 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(ahb_wr_rd_cs),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(\M_AHB_HTRANS[1]_i_12_n_0 ));
  LUT6 #(
    .INIT(64'hAAAEBBBFAAAEAAAE)) 
    \M_AHB_HTRANS[1]_i_13 
       (.I0(\M_AHB_HTRANS[1]_i_22_n_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I2(\M_AHB_HTRANS[0]_i_2_0 ),
        .I3(one_kb_in_progress),
        .I4(single_ahb_wr),
        .I5(\M_AHB_HTRANS[1]_i_4_0 ),
        .O(\M_AHB_HTRANS[1]_i_13_n_0 ));
  LUT6 #(
    .INIT(64'h0000A0A00000A0B0)) 
    \M_AHB_HTRANS[1]_i_14 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I1(\M_AHB_HTRANS[1]_i_4_1 ),
        .I2(ahb_wr_rd_cs),
        .I3(s_axi_wvalid),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ),
        .O(\M_AHB_HTRANS[1]_i_14_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'h00404444)) 
    \M_AHB_HTRANS[1]_i_15 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I1(ahb_wr_rd_cs),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\M_AHB_HTRANS[1]_i_4_0 ),
        .I4(\wrap_brst_count_reg[1]_0 ),
        .O(\M_AHB_HTRANS[1]_i_15_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \M_AHB_HTRANS[1]_i_16 
       (.I0(m_ahb_hready),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(\M_AHB_HTRANS[1]_i_16_n_0 ));
  LUT6 #(
    .INIT(64'h00000000F2020000)) 
    \M_AHB_HTRANS[1]_i_17 
       (.I0(\M_AHB_HTRANS[0]_i_2_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ),
        .I2(ahb_wr_rd_cs),
        .I3(m_ahb_hready),
        .I4(\M_AHB_HTRANS[1]_i_26_n_0 ),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .O(\M_AHB_HTRANS[1]_i_17_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF1000)) 
    \M_AHB_HTRANS[1]_i_2 
       (.I0(\M_AHB_HTRANS_reg[0]_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I3(ahb_wr_rd_cs),
        .I4(\M_AHB_HTRANS[1]_i_6_n_0 ),
        .I5(\M_AHB_HTRANS_reg[0]_1 ),
        .O(\M_AHB_HTRANS[1]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \M_AHB_HTRANS[1]_i_20 
       (.I0(\wrap_brst_count_reg[1]_0 ),
        .I1(s_axi_wvalid_0),
        .O(\M_AHB_HTRANS[1]_i_20_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \M_AHB_HTRANS[1]_i_21 
       (.I0(ahb_wr_rd_cs),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_3 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \M_AHB_HTRANS[1]_i_22 
       (.I0(ahb_wr_rd_cs),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .O(\M_AHB_HTRANS[1]_i_22_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \M_AHB_HTRANS[1]_i_26 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(\M_AHB_HTRANS[1]_i_26_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFEFFFEFFFE)) 
    \M_AHB_HTRANS[1]_i_3 
       (.I0(\M_AHB_HTRANS[1]_i_8_n_0 ),
        .I1(\M_AHB_HTRANS[1]_i_9_n_0 ),
        .I2(\M_AHB_HTRANS[1]_i_10_n_0 ),
        .I3(AWREADY_i_reg),
        .I4(\M_AHB_HTRANS_reg[0]_2 ),
        .I5(\M_AHB_HTRANS[1]_i_12_n_0 ),
        .O(\M_AHB_HTRANS[1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFD00)) 
    \M_AHB_HTRANS[1]_i_4 
       (.I0(\M_AHB_HTRANS[1]_i_13_n_0 ),
        .I1(\M_AHB_HTRANS[1]_i_14_n_0 ),
        .I2(\M_AHB_HTRANS[1]_i_15_n_0 ),
        .I3(\M_AHB_HTRANS[1]_i_16_n_0 ),
        .I4(\M_AHB_HTRANS[0]_i_2_n_0 ),
        .I5(\M_AHB_HTRANS[1]_i_17_n_0 ),
        .O(\M_AHB_HTRANS[1]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h3230303030303030)) 
    \M_AHB_HTRANS[1]_i_6 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ),
        .I1(\M_AHB_HTRANS[1]_i_3_1 ),
        .I2(\M_AHB_HTRANS[1]_i_20_n_0 ),
        .I3(out),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ),
        .O(\M_AHB_HTRANS[1]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h0000800000000000)) 
    \M_AHB_HTRANS[1]_i_8 
       (.I0(ahb_wr_rd_cs),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(out),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[1]_4 ),
        .I5(\wrap_brst_count_reg[1]_0 ),
        .O(\M_AHB_HTRANS[1]_i_8_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h2A222A20)) 
    \M_AHB_HTRANS[1]_i_9 
       (.I0(one_kb_in_progress_i_4_n_0),
        .I1(ahb_wr_rd_cs),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I3(\M_AHB_HTRANS[1]_i_3_0 ),
        .I4(one_kb_in_progress_reg_0),
        .O(\M_AHB_HTRANS[1]_i_9_n_0 ));
  FDRE \M_AHB_HTRANS_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\M_AHB_HTRANS[0]_i_1_n_0 ),
        .Q(m_ahb_htrans[0]),
        .R(1'b0));
  FDRE \M_AHB_HTRANS_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(\M_AHB_HTRANS[1]_i_1_n_0 ),
        .Q(m_ahb_htrans[1]),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'h0000000010800000)) 
    RRESP_1_i_i_1
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I2(m_ahb_hready),
        .I3(ahb_wr_rd_cs),
        .I4(m_ahb_hresp),
        .I5(RRESP_1_i_reg),
        .O(RRESP_1_i));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \S_AXI_RDATA[16]_i_1 
       (.I0(ahb_wr_rd_cs),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(m_ahb_hrdata[1]),
        .I5(RRESP_1_i_reg),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 [1]));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \S_AXI_RDATA[17]_i_1 
       (.I0(ahb_wr_rd_cs),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(m_ahb_hrdata[2]),
        .I5(RRESP_1_i_reg),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 [2]));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \S_AXI_RDATA[1]_i_1 
       (.I0(ahb_wr_rd_cs),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(m_ahb_hrdata[0]),
        .I5(RRESP_1_i_reg),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 [0]));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \S_AXI_RDATA[22]_i_1 
       (.I0(ahb_wr_rd_cs),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(m_ahb_hrdata[3]),
        .I5(RRESP_1_i_reg),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 [3]));
  LUT6 #(
    .INIT(64'h0000000040000000)) 
    \S_AXI_RDATA[30]_i_1 
       (.I0(ahb_wr_rd_cs),
        .I1(m_ahb_hready),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(m_ahb_hrdata[4]),
        .I5(RRESP_1_i_reg),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 [4]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'hEFFFFFFF)) 
    WREADY_i_i_2
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I2(ahb_wr_rd_cs),
        .I3(m_ahb_hready),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[2]_1 ));
  LUT6 #(
    .INIT(64'h0000100010001000)) 
    WREADY_i_i_3
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I2(ahb_wr_rd_cs),
        .I3(m_ahb_hready),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I5(\wrap_brst_count_reg[1]_0 ),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[2]_0 ));
  LUT6 #(
    .INIT(64'h0000000000008000)) 
    WREADY_i_i_5
       (.I0(s_axi_wvalid),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I2(m_ahb_hready),
        .I3(ahb_wr_rd_cs),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .O(s_axi_wvalid_0));
  LUT6 #(
    .INIT(64'h000000000000000E)) 
    load_counter_i_2
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[1]_5 ),
        .I1(load_counter_reg_0),
        .I2(ahb_wr_rd_cs),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .O(AWREADY_i_reg));
  FDRE load_counter_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(load_counter_sm),
        .Q(load_counter),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'hAEEEAAAAAAAAAAAA)) 
    one_kb_in_progress_i_1
       (.I0(one_kb_cross),
        .I1(one_kb_in_progress_i_3_n_0),
        .I2(one_kb_in_progress_i_4_n_0),
        .I3(one_kb_in_progress_i_5_n_0),
        .I4(one_kb_in_progress_i_6_n_0),
        .I5(one_kb_in_progress),
        .O(one_kb_in_progress_i_1_n_0));
  LUT6 #(
    .INIT(64'h00000000000000A8)) 
    one_kb_in_progress_i_2
       (.I0(\FSM_sequential_ahb_wr_rd_cs[3]_i_14_n_0 ),
        .I1(one_kb_in_progress_i_7_n_0),
        .I2(\HSIZE_i_reg[2]_0 [1]),
        .I3(\FSM_sequential_ahb_wr_rd_cs[3]_i_12_n_0 ),
        .I4(\FSM_sequential_ahb_wr_rd_cs[3]_i_11_n_0 ),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[0]_2 ),
        .O(one_kb_cross));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    one_kb_in_progress_i_3
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I3(ahb_wr_rd_cs),
        .O(one_kb_in_progress_i_3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h08)) 
    one_kb_in_progress_i_4
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .O(one_kb_in_progress_i_4_n_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h2)) 
    one_kb_in_progress_i_5
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I1(ahb_wr_rd_cs),
        .O(one_kb_in_progress_i_5_n_0));
  LUT6 #(
    .INIT(64'h5554545555555555)) 
    one_kb_in_progress_i_6
       (.I0(one_kb_in_progress_i_8_n_0),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I2(ahb_wr_rd_cs),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I5(\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ),
        .O(one_kb_in_progress_i_6_n_0));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h8)) 
    one_kb_in_progress_i_7
       (.I0(m_ahb_haddr[1]),
        .I1(m_ahb_haddr[2]),
        .O(one_kb_in_progress_i_7_n_0));
  LUT6 #(
    .INIT(64'hFFFFC000EAAAC000)) 
    one_kb_in_progress_i_8
       (.I0(one_kb_in_progress_i_9_n_0),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I3(out),
        .I4(\wrap_brst_count_reg[1]_0 ),
        .I5(s_axi_wvalid_0),
        .O(one_kb_in_progress_i_8_n_0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00008000)) 
    one_kb_in_progress_i_9
       (.I0(ahb_wr_rd_cs),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(out),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .O(one_kb_in_progress_i_9_n_0));
  FDRE one_kb_in_progress_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(one_kb_in_progress_i_1_n_0),
        .Q(one_kb_in_progress),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'h8F8F8F8000000000)) 
    onekb_cross_access_i_1
       (.I0(\wrap_brst_count_reg[1]_0 ),
        .I1(onekb_cross_access_reg_n_0),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 ),
        .I3(O),
        .I4(CO),
        .I5(s_axi_aresetn),
        .O(onekb_cross_access_i_1_n_0));
  FDRE onekb_cross_access_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(onekb_cross_access_i_1_n_0),
        .Q(onekb_cross_access_reg_n_0),
        .R(1'b0));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 p_0_out_carry
       (.CI(A[0]),
        .CI_TOP(1'b0),
        .CO({NLW_p_0_out_carry_CO_UNCONNECTED[7:6],p_0_out_carry_n_2,p_0_out_carry_n_3,p_0_out_carry_n_4,p_0_out_carry_n_5,p_0_out_carry_n_6,p_0_out_carry_n_7}),
        .DI({1'b0,1'b0,A[5:1],load_counter}),
        .O({NLW_p_0_out_carry_O_UNCONNECTED[7],p_0_out_carry_n_9,p_0_out_carry_n_10,p_0_out_carry_n_11,p_0_out_carry_n_12,p_0_out_carry_n_13,p_0_out_carry_n_14,p_0_out_carry_n_15}),
        .S({1'b0,p_0_out_carry_i_7_n_0,p_0_out_carry_i_8_n_0,p_0_out_carry_i_9_n_0,p_0_out_carry_i_10_n_0,p_0_out_carry_i_11_n_0,p_0_out_carry_i_12_n_0,p_0_out_carry_i_13_n_0}));
  LUT3 #(
    .INIT(8'hB8)) 
    p_0_out_carry_i_1
       (.I0(\wrap_brst_count_reg[7]_0 [0]),
        .I1(load_counter),
        .I2(wrap_brst_count_reg[0]),
        .O(A[0]));
  LUT5 #(
    .INIT(32'hCCA533A5)) 
    p_0_out_carry_i_10
       (.I0(wrap_brst_count_reg[3]),
        .I1(\wrap_brst_count_reg[7]_0 [3]),
        .I2(wrap_brst_count_reg[4]),
        .I3(load_counter),
        .I4(\wrap_brst_count_reg[7]_0 [4]),
        .O(p_0_out_carry_i_10_n_0));
  LUT5 #(
    .INIT(32'hCCA533A5)) 
    p_0_out_carry_i_11
       (.I0(wrap_brst_count_reg[2]),
        .I1(\wrap_brst_count_reg[7]_0 [2]),
        .I2(wrap_brst_count_reg[3]),
        .I3(load_counter),
        .I4(\wrap_brst_count_reg[7]_0 [3]),
        .O(p_0_out_carry_i_11_n_0));
  LUT5 #(
    .INIT(32'hCCA533A5)) 
    p_0_out_carry_i_12
       (.I0(wrap_brst_count_reg[1]),
        .I1(\wrap_brst_count_reg[7]_0 [1]),
        .I2(wrap_brst_count_reg[2]),
        .I3(load_counter),
        .I4(\wrap_brst_count_reg[7]_0 [2]),
        .O(p_0_out_carry_i_12_n_0));
  LUT3 #(
    .INIT(8'hC5)) 
    p_0_out_carry_i_13
       (.I0(wrap_brst_count_reg[1]),
        .I1(\wrap_brst_count_reg[7]_0 [1]),
        .I2(load_counter),
        .O(p_0_out_carry_i_13_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    p_0_out_carry_i_2
       (.I0(\wrap_brst_count_reg[7]_0 [5]),
        .I1(load_counter),
        .I2(wrap_brst_count_reg[5]),
        .O(A[5]));
  LUT3 #(
    .INIT(8'hB8)) 
    p_0_out_carry_i_3
       (.I0(\wrap_brst_count_reg[7]_0 [4]),
        .I1(load_counter),
        .I2(wrap_brst_count_reg[4]),
        .O(A[4]));
  LUT3 #(
    .INIT(8'hB8)) 
    p_0_out_carry_i_4
       (.I0(\wrap_brst_count_reg[7]_0 [3]),
        .I1(load_counter),
        .I2(wrap_brst_count_reg[3]),
        .O(A[3]));
  LUT3 #(
    .INIT(8'hB8)) 
    p_0_out_carry_i_5
       (.I0(\wrap_brst_count_reg[7]_0 [2]),
        .I1(load_counter),
        .I2(wrap_brst_count_reg[2]),
        .O(A[2]));
  LUT3 #(
    .INIT(8'hB8)) 
    p_0_out_carry_i_6
       (.I0(\wrap_brst_count_reg[7]_0 [1]),
        .I1(load_counter),
        .I2(wrap_brst_count_reg[1]),
        .O(A[1]));
  LUT5 #(
    .INIT(32'hCCA533A5)) 
    p_0_out_carry_i_7
       (.I0(wrap_brst_count_reg[6]),
        .I1(\wrap_brst_count_reg[7]_0 [6]),
        .I2(wrap_brst_count_reg[7]),
        .I3(load_counter),
        .I4(\wrap_brst_count_reg[7]_0 [7]),
        .O(p_0_out_carry_i_7_n_0));
  LUT5 #(
    .INIT(32'hCCA533A5)) 
    p_0_out_carry_i_8
       (.I0(wrap_brst_count_reg[5]),
        .I1(\wrap_brst_count_reg[7]_0 [5]),
        .I2(wrap_brst_count_reg[6]),
        .I3(load_counter),
        .I4(\wrap_brst_count_reg[7]_0 [6]),
        .O(p_0_out_carry_i_8_n_0));
  LUT5 #(
    .INIT(32'hCCA533A5)) 
    p_0_out_carry_i_9
       (.I0(wrap_brst_count_reg[4]),
        .I1(\wrap_brst_count_reg[7]_0 [4]),
        .I2(wrap_brst_count_reg[5]),
        .I3(load_counter),
        .I4(\wrap_brst_count_reg[7]_0 [5]),
        .O(p_0_out_carry_i_9_n_0));
  LUT3 #(
    .INIT(8'h02)) 
    p_3_out
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(Q[2]),
        .O(p_3_out__0));
  FDRE single_ahb_wr_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(single_ahb_wr_reg_0),
        .Q(single_ahb_wr),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'h0200800000000000)) 
    wr_err_occured_i_2
       (.I0(write_in_progress),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I3(m_ahb_hready),
        .I4(ahb_wr_rd_cs),
        .I5(m_ahb_hresp),
        .O(wr_err_occured0));
  LUT3 #(
    .INIT(8'h1D)) 
    \wrap_brst_count[0]_i_1 
       (.I0(wrap_brst_count_reg[0]),
        .I1(load_counter),
        .I2(\wrap_brst_count_reg[7]_0 [0]),
        .O(\wrap_brst_count[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hBAAAAAEA)) 
    \wrap_brst_count[7]_i_1 
       (.I0(load_counter),
        .I1(ahb_wr_rd_cs),
        .I2(m_ahb_hready),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [2]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [1]),
        .O(\wrap_brst_count[7]_i_1_n_0 ));
  FDRE \wrap_brst_count_reg[0] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(\wrap_brst_count[0]_i_1_n_0 ),
        .Q(wrap_brst_count_reg[0]),
        .R(s_axi_aresetn_int));
  FDRE \wrap_brst_count_reg[1] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(p_0_out_carry_n_15),
        .Q(wrap_brst_count_reg[1]),
        .R(s_axi_aresetn_int));
  FDRE \wrap_brst_count_reg[2] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(p_0_out_carry_n_14),
        .Q(wrap_brst_count_reg[2]),
        .R(s_axi_aresetn_int));
  FDRE \wrap_brst_count_reg[3] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(p_0_out_carry_n_13),
        .Q(wrap_brst_count_reg[3]),
        .R(s_axi_aresetn_int));
  FDRE \wrap_brst_count_reg[4] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(p_0_out_carry_n_12),
        .Q(wrap_brst_count_reg[4]),
        .R(s_axi_aresetn_int));
  FDRE \wrap_brst_count_reg[5] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(p_0_out_carry_n_11),
        .Q(wrap_brst_count_reg[5]),
        .R(s_axi_aresetn_int));
  FDRE \wrap_brst_count_reg[6] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(p_0_out_carry_n_10),
        .Q(wrap_brst_count_reg[6]),
        .R(s_axi_aresetn_int));
  FDRE \wrap_brst_count_reg[7] 
       (.C(s_axi_aclk),
        .CE(\wrap_brst_count[7]_i_1_n_0 ),
        .D(p_0_out_carry_n_9),
        .Q(wrap_brst_count_reg[7]),
        .R(s_axi_aresetn_int));
  LUT5 #(
    .INIT(32'hDDCDCCCC)) 
    wrap_in_progress_i_1
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[2]_0 ),
        .I1(send_wrap_burst),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[1]_1 ),
        .I3(\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 [0]),
        .I4(wrap_in_progress),
        .O(wrap_in_progress_i_1_n_0));
  FDRE wrap_in_progress_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(wrap_in_progress_i_1_n_0),
        .Q(wrap_in_progress),
        .R(s_axi_aresetn_int));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_skid_buf
   (out,
    s_axi_rvalid,
    s_axi_rlast,
    s_axi_rresp,
    E,
    s_axi_rid,
    s_axi_rdata,
    s_axi_aclk,
    s_axi_aresetn_int,
    s_axi_rlast_int,
    s_axi_rresp_int,
    s_axi_rvalid_int,
    s_axi_rready,
    s_axi_aresetn,
    D,
    \sig_data_skid_reg_reg[31]_0 ,
    RRESP_1_i_reg);
  output out;
  output s_axi_rvalid;
  output s_axi_rlast;
  output [0:0]s_axi_rresp;
  output [0:0]E;
  output [15:0]s_axi_rid;
  output [31:0]s_axi_rdata;
  input s_axi_aclk;
  input s_axi_aresetn_int;
  input s_axi_rlast_int;
  input [0:0]s_axi_rresp_int;
  input s_axi_rvalid_int;
  input s_axi_rready;
  input s_axi_aresetn;
  input [15:0]D;
  input [31:0]\sig_data_skid_reg_reg[31]_0 ;
  input RRESP_1_i_reg;

  wire [15:0]D;
  wire [0:0]E;
  wire RRESP_1_i_reg;
  wire s_axi_aclk;
  wire s_axi_aresetn;
  wire s_axi_aresetn_int;
  wire [31:0]s_axi_rdata;
  wire [15:0]s_axi_rid;
  wire s_axi_rlast;
  wire s_axi_rlast_int;
  wire s_axi_rready;
  wire [0:0]s_axi_rresp;
  wire [0:0]s_axi_rresp_int;
  wire s_axi_rvalid_int;
  wire sig_data_reg_out_en;
  wire [31:0]sig_data_skid_mux_out;
  wire [31:0]sig_data_skid_reg;
  wire [31:0]\sig_data_skid_reg_reg[31]_0 ;
  wire sig_last_skid_mux_out;
  wire sig_last_skid_reg;
  (* RTL_KEEP = "true" *) (* equivalent_register_removal = "no" *) wire sig_m_valid_dup;
  wire sig_m_valid_dup_i_1_n_0;
  (* RTL_KEEP = "true" *) (* equivalent_register_removal = "no" *) wire sig_m_valid_out;
  wire sig_reset_reg;
  wire [1:1]sig_resp_skid_mux_out;
  wire [1:1]sig_resp_skid_reg;
  wire [15:0]sig_rid_skid_mux_out;
  wire [15:0]sig_rid_skid_reg;
  (* RTL_KEEP = "true" *) (* equivalent_register_removal = "no" *) wire sig_s_ready_dup;
  wire sig_s_ready_dup_i_1_n_0;
  (* RTL_KEEP = "true" *) (* equivalent_register_removal = "no" *) wire sig_s_ready_out;

  assign out = sig_s_ready_out;
  assign s_axi_rvalid = sig_m_valid_out;
  LUT2 #(
    .INIT(4'hB)) 
    \S_AXI_RDATA[31]_i_1 
       (.I0(sig_s_ready_out),
        .I1(RRESP_1_i_reg),
        .O(E));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[0]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [0]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[0]),
        .O(sig_data_skid_mux_out[0]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[10]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [10]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[10]),
        .O(sig_data_skid_mux_out[10]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[11]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [11]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[11]),
        .O(sig_data_skid_mux_out[11]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[12]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [12]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[12]),
        .O(sig_data_skid_mux_out[12]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[13]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [13]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[13]),
        .O(sig_data_skid_mux_out[13]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[14]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [14]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[14]),
        .O(sig_data_skid_mux_out[14]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[15]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [15]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[15]),
        .O(sig_data_skid_mux_out[15]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[16]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [16]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[16]),
        .O(sig_data_skid_mux_out[16]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[17]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [17]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[17]),
        .O(sig_data_skid_mux_out[17]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[18]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [18]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[18]),
        .O(sig_data_skid_mux_out[18]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[19]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [19]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[19]),
        .O(sig_data_skid_mux_out[19]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[1]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [1]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[1]),
        .O(sig_data_skid_mux_out[1]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[20]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [20]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[20]),
        .O(sig_data_skid_mux_out[20]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[21]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [21]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[21]),
        .O(sig_data_skid_mux_out[21]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[22]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [22]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[22]),
        .O(sig_data_skid_mux_out[22]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[23]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [23]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[23]),
        .O(sig_data_skid_mux_out[23]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[24]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [24]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[24]),
        .O(sig_data_skid_mux_out[24]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[25]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [25]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[25]),
        .O(sig_data_skid_mux_out[25]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[26]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [26]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[26]),
        .O(sig_data_skid_mux_out[26]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[27]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [27]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[27]),
        .O(sig_data_skid_mux_out[27]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[28]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [28]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[28]),
        .O(sig_data_skid_mux_out[28]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[29]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [29]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[29]),
        .O(sig_data_skid_mux_out[29]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[2]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [2]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[2]),
        .O(sig_data_skid_mux_out[2]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[30]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [30]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[30]),
        .O(sig_data_skid_mux_out[30]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[31]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [31]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[31]),
        .O(sig_data_skid_mux_out[31]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[3]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [3]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[3]),
        .O(sig_data_skid_mux_out[3]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[4]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [4]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[4]),
        .O(sig_data_skid_mux_out[4]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[5]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [5]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[5]),
        .O(sig_data_skid_mux_out[5]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[6]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [6]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[6]),
        .O(sig_data_skid_mux_out[6]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[7]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [7]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[7]),
        .O(sig_data_skid_mux_out[7]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[8]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [8]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[8]),
        .O(sig_data_skid_mux_out[8]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_data_reg_out[9]_i_1 
       (.I0(\sig_data_skid_reg_reg[31]_0 [9]),
        .I1(sig_s_ready_dup),
        .I2(sig_data_skid_reg[9]),
        .O(sig_data_skid_mux_out[9]));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[0] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[0]),
        .Q(s_axi_rdata[0]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[10] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[10]),
        .Q(s_axi_rdata[10]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[11] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[11]),
        .Q(s_axi_rdata[11]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[12] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[12]),
        .Q(s_axi_rdata[12]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[13] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[13]),
        .Q(s_axi_rdata[13]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[14] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[14]),
        .Q(s_axi_rdata[14]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[15] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[15]),
        .Q(s_axi_rdata[15]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[16] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[16]),
        .Q(s_axi_rdata[16]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[17] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[17]),
        .Q(s_axi_rdata[17]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[18] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[18]),
        .Q(s_axi_rdata[18]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[19] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[19]),
        .Q(s_axi_rdata[19]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[1] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[1]),
        .Q(s_axi_rdata[1]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[20] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[20]),
        .Q(s_axi_rdata[20]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[21] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[21]),
        .Q(s_axi_rdata[21]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[22] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[22]),
        .Q(s_axi_rdata[22]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[23] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[23]),
        .Q(s_axi_rdata[23]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[24] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[24]),
        .Q(s_axi_rdata[24]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[25] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[25]),
        .Q(s_axi_rdata[25]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[26] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[26]),
        .Q(s_axi_rdata[26]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[27] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[27]),
        .Q(s_axi_rdata[27]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[28] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[28]),
        .Q(s_axi_rdata[28]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[29] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[29]),
        .Q(s_axi_rdata[29]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[2] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[2]),
        .Q(s_axi_rdata[2]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[30] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[30]),
        .Q(s_axi_rdata[30]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[31] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[31]),
        .Q(s_axi_rdata[31]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[3] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[3]),
        .Q(s_axi_rdata[3]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[4] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[4]),
        .Q(s_axi_rdata[4]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[5] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[5]),
        .Q(s_axi_rdata[5]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[6] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[6]),
        .Q(s_axi_rdata[6]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[7] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[7]),
        .Q(s_axi_rdata[7]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[8] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[8]),
        .Q(s_axi_rdata[8]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_reg_out_reg[9] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_data_skid_mux_out[9]),
        .Q(s_axi_rdata[9]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[0] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [0]),
        .Q(sig_data_skid_reg[0]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[10] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [10]),
        .Q(sig_data_skid_reg[10]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[11] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [11]),
        .Q(sig_data_skid_reg[11]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[12] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [12]),
        .Q(sig_data_skid_reg[12]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[13] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [13]),
        .Q(sig_data_skid_reg[13]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[14] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [14]),
        .Q(sig_data_skid_reg[14]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[15] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [15]),
        .Q(sig_data_skid_reg[15]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[16] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [16]),
        .Q(sig_data_skid_reg[16]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[17] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [17]),
        .Q(sig_data_skid_reg[17]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[18] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [18]),
        .Q(sig_data_skid_reg[18]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[19] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [19]),
        .Q(sig_data_skid_reg[19]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[1] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [1]),
        .Q(sig_data_skid_reg[1]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[20] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [20]),
        .Q(sig_data_skid_reg[20]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[21] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [21]),
        .Q(sig_data_skid_reg[21]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[22] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [22]),
        .Q(sig_data_skid_reg[22]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[23] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [23]),
        .Q(sig_data_skid_reg[23]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[24] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [24]),
        .Q(sig_data_skid_reg[24]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[25] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [25]),
        .Q(sig_data_skid_reg[25]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[26] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [26]),
        .Q(sig_data_skid_reg[26]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[27] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [27]),
        .Q(sig_data_skid_reg[27]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[28] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [28]),
        .Q(sig_data_skid_reg[28]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[29] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [29]),
        .Q(sig_data_skid_reg[29]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[2] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [2]),
        .Q(sig_data_skid_reg[2]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[30] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [30]),
        .Q(sig_data_skid_reg[30]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[31] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [31]),
        .Q(sig_data_skid_reg[31]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[3] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [3]),
        .Q(sig_data_skid_reg[3]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[4] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [4]),
        .Q(sig_data_skid_reg[4]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[5] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [5]),
        .Q(sig_data_skid_reg[5]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[6] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [6]),
        .Q(sig_data_skid_reg[6]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[7] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [7]),
        .Q(sig_data_skid_reg[7]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[8] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [8]),
        .Q(sig_data_skid_reg[8]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_data_skid_reg_reg[9] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(\sig_data_skid_reg_reg[31]_0 [9]),
        .Q(sig_data_skid_reg[9]),
        .R(s_axi_aresetn_int));
  LUT3 #(
    .INIT(8'hB8)) 
    sig_last_reg_out_i_1
       (.I0(s_axi_rlast_int),
        .I1(sig_s_ready_dup),
        .I2(sig_last_skid_reg),
        .O(sig_last_skid_mux_out));
  FDRE #(
    .INIT(1'b0)) 
    sig_last_reg_out_reg
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_last_skid_mux_out),
        .Q(s_axi_rlast),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    sig_last_skid_reg_reg
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(s_axi_rlast_int),
        .Q(sig_last_skid_reg),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'h00000000BAFA0000)) 
    sig_m_valid_dup_i_1
       (.I0(s_axi_rvalid_int),
        .I1(sig_s_ready_dup),
        .I2(sig_m_valid_dup),
        .I3(s_axi_rready),
        .I4(s_axi_aresetn),
        .I5(sig_reset_reg),
        .O(sig_m_valid_dup_i_1_n_0));
  (* KEEP = "yes" *) 
  (* equivalent_register_removal = "no" *) 
  FDRE #(
    .INIT(1'b0)) 
    sig_m_valid_dup_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(sig_m_valid_dup_i_1_n_0),
        .Q(sig_m_valid_dup),
        .R(1'b0));
  (* KEEP = "yes" *) 
  (* equivalent_register_removal = "no" *) 
  FDRE #(
    .INIT(1'b0)) 
    sig_m_valid_out_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(sig_m_valid_dup_i_1_n_0),
        .Q(sig_m_valid_out),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    sig_reset_reg_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(s_axi_aresetn_int),
        .Q(sig_reset_reg),
        .R(1'b0));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_resp_reg_out[1]_i_1 
       (.I0(s_axi_rresp_int),
        .I1(sig_s_ready_dup),
        .I2(sig_resp_skid_reg),
        .O(sig_resp_skid_mux_out));
  FDRE #(
    .INIT(1'b0)) 
    \sig_resp_reg_out_reg[1] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_resp_skid_mux_out),
        .Q(s_axi_rresp),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_resp_skid_reg_reg[1] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(s_axi_rresp_int),
        .Q(sig_resp_skid_reg),
        .R(s_axi_aresetn_int));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[0]_i_1 
       (.I0(D[0]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[0]),
        .O(sig_rid_skid_mux_out[0]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[10]_i_1 
       (.I0(D[10]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[10]),
        .O(sig_rid_skid_mux_out[10]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[11]_i_1 
       (.I0(D[11]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[11]),
        .O(sig_rid_skid_mux_out[11]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[12]_i_1 
       (.I0(D[12]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[12]),
        .O(sig_rid_skid_mux_out[12]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[13]_i_1 
       (.I0(D[13]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[13]),
        .O(sig_rid_skid_mux_out[13]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[14]_i_1 
       (.I0(D[14]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[14]),
        .O(sig_rid_skid_mux_out[14]));
  LUT2 #(
    .INIT(4'hB)) 
    \sig_rid_reg_out[15]_i_1 
       (.I0(s_axi_rready),
        .I1(sig_m_valid_dup),
        .O(sig_data_reg_out_en));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[15]_i_2 
       (.I0(D[15]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[15]),
        .O(sig_rid_skid_mux_out[15]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[1]_i_1 
       (.I0(D[1]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[1]),
        .O(sig_rid_skid_mux_out[1]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[2]_i_1 
       (.I0(D[2]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[2]),
        .O(sig_rid_skid_mux_out[2]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[3]_i_1 
       (.I0(D[3]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[3]),
        .O(sig_rid_skid_mux_out[3]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[4]_i_1 
       (.I0(D[4]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[4]),
        .O(sig_rid_skid_mux_out[4]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[5]_i_1 
       (.I0(D[5]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[5]),
        .O(sig_rid_skid_mux_out[5]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[6]_i_1 
       (.I0(D[6]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[6]),
        .O(sig_rid_skid_mux_out[6]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[7]_i_1 
       (.I0(D[7]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[7]),
        .O(sig_rid_skid_mux_out[7]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[8]_i_1 
       (.I0(D[8]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[8]),
        .O(sig_rid_skid_mux_out[8]));
  LUT3 #(
    .INIT(8'hB8)) 
    \sig_rid_reg_out[9]_i_1 
       (.I0(D[9]),
        .I1(sig_s_ready_dup),
        .I2(sig_rid_skid_reg[9]),
        .O(sig_rid_skid_mux_out[9]));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[0] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[0]),
        .Q(s_axi_rid[0]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[10] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[10]),
        .Q(s_axi_rid[10]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[11] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[11]),
        .Q(s_axi_rid[11]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[12] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[12]),
        .Q(s_axi_rid[12]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[13] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[13]),
        .Q(s_axi_rid[13]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[14] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[14]),
        .Q(s_axi_rid[14]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[15] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[15]),
        .Q(s_axi_rid[15]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[1] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[1]),
        .Q(s_axi_rid[1]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[2] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[2]),
        .Q(s_axi_rid[2]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[3] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[3]),
        .Q(s_axi_rid[3]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[4] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[4]),
        .Q(s_axi_rid[4]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[5] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[5]),
        .Q(s_axi_rid[5]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[6] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[6]),
        .Q(s_axi_rid[6]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[7] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[7]),
        .Q(s_axi_rid[7]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[8] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[8]),
        .Q(s_axi_rid[8]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_reg_out_reg[9] 
       (.C(s_axi_aclk),
        .CE(sig_data_reg_out_en),
        .D(sig_rid_skid_mux_out[9]),
        .Q(s_axi_rid[9]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[0] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[0]),
        .Q(sig_rid_skid_reg[0]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[10] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[10]),
        .Q(sig_rid_skid_reg[10]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[11] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[11]),
        .Q(sig_rid_skid_reg[11]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[12] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[12]),
        .Q(sig_rid_skid_reg[12]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[13] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[13]),
        .Q(sig_rid_skid_reg[13]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[14] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[14]),
        .Q(sig_rid_skid_reg[14]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[15] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[15]),
        .Q(sig_rid_skid_reg[15]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[1] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[1]),
        .Q(sig_rid_skid_reg[1]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[2] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[2]),
        .Q(sig_rid_skid_reg[2]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[3] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[3]),
        .Q(sig_rid_skid_reg[3]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[4] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[4]),
        .Q(sig_rid_skid_reg[4]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[5] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[5]),
        .Q(sig_rid_skid_reg[5]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[6] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[6]),
        .Q(sig_rid_skid_reg[6]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[7] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[7]),
        .Q(sig_rid_skid_reg[7]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[8] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[8]),
        .Q(sig_rid_skid_reg[8]),
        .R(s_axi_aresetn_int));
  FDRE #(
    .INIT(1'b0)) 
    \sig_rid_skid_reg_reg[9] 
       (.C(s_axi_aclk),
        .CE(sig_s_ready_dup),
        .D(D[9]),
        .Q(sig_rid_skid_reg[9]),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'hA8A8AAA8AAA8AAA8)) 
    sig_s_ready_dup_i_1
       (.I0(s_axi_aresetn),
        .I1(s_axi_rready),
        .I2(sig_reset_reg),
        .I3(sig_s_ready_dup),
        .I4(s_axi_rvalid_int),
        .I5(sig_m_valid_dup),
        .O(sig_s_ready_dup_i_1_n_0));
  (* KEEP = "yes" *) 
  (* equivalent_register_removal = "no" *) 
  FDRE #(
    .INIT(1'b0)) 
    sig_s_ready_dup_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(sig_s_ready_dup_i_1_n_0),
        .Q(sig_s_ready_dup),
        .R(1'b0));
  (* KEEP = "yes" *) 
  (* equivalent_register_removal = "no" *) 
  FDRE #(
    .INIT(1'b0)) 
    sig_s_ready_out_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(sig_s_ready_dup_i_1_n_0),
        .Q(sig_s_ready_out),
        .R(1'b0));
endmodule

(* C_DPHASE_TIMEOUT = "0" *) (* C_FAMILY = "zynquplus" *) (* C_INSTANCE = "zynqmpsoc_axi_ahblite_bridge_0_0" *) 
(* C_M_AHB_ADDR_WIDTH = "32" *) (* C_M_AHB_DATA_WIDTH = "32" *) (* C_S_AXI_ADDR_WIDTH = "32" *) 
(* C_S_AXI_DATA_WIDTH = "32" *) (* C_S_AXI_ID_WIDTH = "16" *) (* C_S_AXI_SUPPORTS_NARROW_BURST = "1" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_ahblite_bridge
   (s_axi_aclk,
    s_axi_aresetn,
    s_axi_awid,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awcache,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_awlock,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bid,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_arid,
    s_axi_araddr,
    s_axi_arprot,
    s_axi_arcache,
    s_axi_arvalid,
    s_axi_arlen,
    s_axi_arsize,
    s_axi_arburst,
    s_axi_arlock,
    s_axi_arready,
    s_axi_rid,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_rlast,
    s_axi_rready,
    m_ahb_haddr,
    m_ahb_hwrite,
    m_ahb_hsize,
    m_ahb_hburst,
    m_ahb_hprot,
    m_ahb_htrans,
    m_ahb_hmastlock,
    m_ahb_hwdata,
    m_ahb_hready,
    m_ahb_hrdata,
    m_ahb_hresp);
  input s_axi_aclk;
  input s_axi_aresetn;
  input [15:0]s_axi_awid;
  input [7:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input [3:0]s_axi_awcache;
  input [31:0]s_axi_awaddr;
  input [2:0]s_axi_awprot;
  input s_axi_awvalid;
  output s_axi_awready;
  input s_axi_awlock;
  input [31:0]s_axi_wdata;
  input [3:0]s_axi_wstrb;
  input s_axi_wlast;
  input s_axi_wvalid;
  output s_axi_wready;
  output [15:0]s_axi_bid;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_bready;
  input [15:0]s_axi_arid;
  input [31:0]s_axi_araddr;
  input [2:0]s_axi_arprot;
  input [3:0]s_axi_arcache;
  input s_axi_arvalid;
  input [7:0]s_axi_arlen;
  input [2:0]s_axi_arsize;
  input [1:0]s_axi_arburst;
  input s_axi_arlock;
  output s_axi_arready;
  output [15:0]s_axi_rid;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  output s_axi_rlast;
  input s_axi_rready;
  output [31:0]m_ahb_haddr;
  output m_ahb_hwrite;
  output [2:0]m_ahb_hsize;
  output [2:0]m_ahb_hburst;
  output [3:0]m_ahb_hprot;
  output [1:0]m_ahb_htrans;
  output m_ahb_hmastlock;
  output [31:0]m_ahb_hwdata;
  input m_ahb_hready;
  input [31:0]m_ahb_hrdata;
  input m_ahb_hresp;

  wire \<const0> ;
  wire AHB_MSTR_IF_MODULE_n_100;
  wire AHB_MSTR_IF_MODULE_n_101;
  wire AHB_MSTR_IF_MODULE_n_102;
  wire AHB_MSTR_IF_MODULE_n_103;
  wire AHB_MSTR_IF_MODULE_n_104;
  wire AHB_MSTR_IF_MODULE_n_105;
  wire AHB_MSTR_IF_MODULE_n_106;
  wire AHB_MSTR_IF_MODULE_n_107;
  wire AHB_MSTR_IF_MODULE_n_108;
  wire AHB_MSTR_IF_MODULE_n_109;
  wire AHB_MSTR_IF_MODULE_n_110;
  wire AHB_MSTR_IF_MODULE_n_111;
  wire AHB_MSTR_IF_MODULE_n_147;
  wire AHB_MSTR_IF_MODULE_n_148;
  wire AHB_MSTR_IF_MODULE_n_149;
  wire AHB_MSTR_IF_MODULE_n_150;
  wire AHB_MSTR_IF_MODULE_n_151;
  wire AHB_MSTR_IF_MODULE_n_152;
  wire AHB_MSTR_IF_MODULE_n_153;
  wire AHB_MSTR_IF_MODULE_n_154;
  wire AHB_MSTR_IF_MODULE_n_155;
  wire AHB_MSTR_IF_MODULE_n_156;
  wire AHB_MSTR_IF_MODULE_n_42;
  wire AHB_MSTR_IF_MODULE_n_46;
  wire AHB_MSTR_IF_MODULE_n_47;
  wire AHB_MSTR_IF_MODULE_n_48;
  wire AHB_MSTR_IF_MODULE_n_49;
  wire AHB_MSTR_IF_MODULE_n_50;
  wire AHB_MSTR_IF_MODULE_n_52;
  wire AHB_MSTR_IF_MODULE_n_53;
  wire AHB_MSTR_IF_MODULE_n_61;
  wire AHB_MSTR_IF_MODULE_n_64;
  wire AHB_MSTR_IF_MODULE_n_65;
  wire AHB_MSTR_IF_MODULE_n_66;
  wire AHB_MSTR_IF_MODULE_n_67;
  wire AHB_MSTR_IF_MODULE_n_68;
  wire AHB_MSTR_IF_MODULE_n_69;
  wire AHB_MSTR_IF_MODULE_n_70;
  wire AHB_MSTR_IF_MODULE_n_71;
  wire AHB_MSTR_IF_MODULE_n_72;
  wire AHB_MSTR_IF_MODULE_n_73;
  wire AHB_MSTR_IF_MODULE_n_74;
  wire AHB_MSTR_IF_MODULE_n_75;
  wire AHB_MSTR_IF_MODULE_n_76;
  wire AHB_MSTR_IF_MODULE_n_77;
  wire AHB_MSTR_IF_MODULE_n_78;
  wire AHB_MSTR_IF_MODULE_n_79;
  wire AHB_MSTR_IF_MODULE_n_80;
  wire AHB_MSTR_IF_MODULE_n_81;
  wire AHB_MSTR_IF_MODULE_n_82;
  wire AHB_MSTR_IF_MODULE_n_83;
  wire AHB_MSTR_IF_MODULE_n_87;
  wire AHB_MSTR_IF_MODULE_n_88;
  wire AHB_MSTR_IF_MODULE_n_89;
  wire AHB_MSTR_IF_MODULE_n_90;
  wire AHB_MSTR_IF_MODULE_n_91;
  wire AHB_MSTR_IF_MODULE_n_92;
  wire AHB_MSTR_IF_MODULE_n_93;
  wire AHB_MSTR_IF_MODULE_n_94;
  wire AHB_MSTR_IF_MODULE_n_95;
  wire AHB_MSTR_IF_MODULE_n_96;
  wire AHB_MSTR_IF_MODULE_n_97;
  wire AHB_MSTR_IF_MODULE_n_98;
  wire AHB_MSTR_IF_MODULE_n_99;
  wire AXI_SLV_IF_MODULE_n_100;
  wire AXI_SLV_IF_MODULE_n_101;
  wire AXI_SLV_IF_MODULE_n_102;
  wire AXI_SLV_IF_MODULE_n_103;
  wire AXI_SLV_IF_MODULE_n_104;
  wire AXI_SLV_IF_MODULE_n_105;
  wire AXI_SLV_IF_MODULE_n_12;
  wire AXI_SLV_IF_MODULE_n_13;
  wire AXI_SLV_IF_MODULE_n_41;
  wire AXI_SLV_IF_MODULE_n_42;
  wire AXI_SLV_IF_MODULE_n_43;
  wire AXI_SLV_IF_MODULE_n_44;
  wire AXI_SLV_IF_MODULE_n_45;
  wire AXI_SLV_IF_MODULE_n_46;
  wire AXI_SLV_IF_MODULE_n_47;
  wire AXI_SLV_IF_MODULE_n_48;
  wire AXI_SLV_IF_MODULE_n_52;
  wire AXI_SLV_IF_MODULE_n_53;
  wire AXI_SLV_IF_MODULE_n_62;
  wire AXI_SLV_IF_MODULE_n_63;
  wire AXI_SLV_IF_MODULE_n_76;
  wire AXI_SLV_IF_MODULE_n_80;
  wire AXI_SLV_IF_MODULE_n_82;
  wire AXI_SLV_IF_MODULE_n_83;
  wire AXI_SLV_IF_MODULE_n_84;
  wire AXI_SLV_IF_MODULE_n_85;
  wire AXI_SLV_IF_MODULE_n_86;
  wire AXI_SLV_IF_MODULE_n_87;
  wire AXI_SLV_IF_MODULE_n_88;
  wire AXI_SLV_IF_MODULE_n_89;
  wire AXI_SLV_IF_MODULE_n_90;
  wire AXI_SLV_IF_MODULE_n_91;
  wire AXI_SLV_IF_MODULE_n_92;
  wire AXI_SLV_IF_MODULE_n_93;
  wire AXI_SLV_IF_MODULE_n_94;
  wire AXI_SLV_IF_MODULE_n_95;
  wire AXI_SLV_IF_MODULE_n_96;
  wire AXI_SLV_IF_MODULE_n_97;
  wire AXI_SLV_IF_MODULE_n_98;
  wire AXI_SLV_IF_MODULE_n_99;
  wire HADDR_i1;
  wire [15:0]RID_i;
  wire RRESP_1_i;
  wire [31:0]S_AXI_RDATA;
  wire VALID_READY_SKID_n_4;
  wire [2:1]ahb_burst;
  wire [3:0]ahb_wr_rd_cs;
  wire [9:0]axi_address;
  wire [3:0]axi_cache;
  wire [7:0]axi_length;
  wire axi_lock;
  wire [0:0]axi_prot;
  wire [2:0]axi_size;
  wire [31:0]axi_wdata;
  wire [4:3]data4;
  wire load_counter_sm;
  wire [31:0]m_ahb_haddr;
  wire [2:0]m_ahb_hburst;
  wire m_ahb_hmastlock;
  wire [2:0]\^m_ahb_hprot ;
  wire [31:0]m_ahb_hrdata;
  wire m_ahb_hready;
  wire m_ahb_hresp;
  wire [2:0]m_ahb_hsize;
  wire [1:0]m_ahb_htrans;
  wire [31:0]m_ahb_hwdata;
  wire m_ahb_hwrite;
  wire one_kb_cross;
  wire one_kb_in_progress;
  wire p_0_in1_in;
  wire [31:31]p_1_in;
  wire [30:1]p_2_in;
  wire [31:6]p_2_in_0;
  wire [0:0]p_3_out;
  wire s_axi_aclk;
  wire [31:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [3:0]s_axi_arcache;
  wire s_axi_aresetn;
  wire s_axi_aresetn_int;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire s_axi_arlock;
  wire [2:0]s_axi_arprot;
  wire s_axi_arready;
  wire [2:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire [31:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire s_axi_awready;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire [15:0]s_axi_bid;
  wire s_axi_bready;
  wire [1:1]\^s_axi_bresp ;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire [15:0]s_axi_rid;
  wire s_axi_rlast;
  wire s_axi_rlast_int;
  wire s_axi_rready;
  wire s_axi_rready_int;
  wire [1:1]\^s_axi_rresp ;
  wire [1:1]s_axi_rresp_int;
  wire s_axi_rvalid;
  wire s_axi_rvalid_int;
  wire [31:0]s_axi_wdata;
  wire s_axi_wlast;
  wire s_axi_wready;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;
  wire send_wrap_burst;
  wire single_ahb_rd_xfer;
  wire single_ahb_wr;
  wire wr_err_occured0;
  wire wrap_in_progress;
  wire write_in_progress;

  assign m_ahb_hprot[3] = \<const0> ;
  assign m_ahb_hprot[2:0] = \^m_ahb_hprot [2:0];
  assign s_axi_bresp[1] = \^s_axi_bresp [1];
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_rresp[1] = \^s_axi_rresp [1];
  assign s_axi_rresp[0] = \<const0> ;
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_mstr_if AHB_MSTR_IF_MODULE
       (.AWREADY_i_reg(AHB_MSTR_IF_MODULE_n_47),
        .CO(AXI_SLV_IF_MODULE_n_80),
        .D({axi_prot,p_3_out}),
        .E(HADDR_i1),
        .\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 (AXI_SLV_IF_MODULE_n_45),
        .\FSM_sequential_ahb_wr_rd_cs_reg[0]_1 (AXI_SLV_IF_MODULE_n_92),
        .\FSM_sequential_ahb_wr_rd_cs_reg[0]_2 (AXI_SLV_IF_MODULE_n_83),
        .\FSM_sequential_ahb_wr_rd_cs_reg[1]_0 (AHB_MSTR_IF_MODULE_n_50),
        .\FSM_sequential_ahb_wr_rd_cs_reg[1]_1 (AHB_MSTR_IF_MODULE_n_52),
        .\FSM_sequential_ahb_wr_rd_cs_reg[1]_2 ({p_2_in[30],p_2_in[22],p_2_in[17:16],p_2_in[1]}),
        .\FSM_sequential_ahb_wr_rd_cs_reg[1]_3 (AHB_MSTR_IF_MODULE_n_83),
        .\FSM_sequential_ahb_wr_rd_cs_reg[1]_4 (AXI_SLV_IF_MODULE_n_43),
        .\FSM_sequential_ahb_wr_rd_cs_reg[1]_5 (s_axi_awready),
        .\FSM_sequential_ahb_wr_rd_cs_reg[2]_0 (AHB_MSTR_IF_MODULE_n_48),
        .\FSM_sequential_ahb_wr_rd_cs_reg[2]_1 (AHB_MSTR_IF_MODULE_n_110),
        .\FSM_sequential_ahb_wr_rd_cs_reg[3]_0 ({ahb_wr_rd_cs[3:2],ahb_wr_rd_cs[0]}),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_2_0 (AXI_SLV_IF_MODULE_n_87),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_5_0 (AXI_SLV_IF_MODULE_n_76),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6 (AXI_SLV_IF_MODULE_n_90),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_0 (data4),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_1 (AHB_MSTR_IF_MODULE_n_96),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0]_2 (AXI_SLV_IF_MODULE_n_41),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16]_0 ({AHB_MSTR_IF_MODULE_n_104,AHB_MSTR_IF_MODULE_n_105,AHB_MSTR_IF_MODULE_n_106}),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ({AHB_MSTR_IF_MODULE_n_107,AHB_MSTR_IF_MODULE_n_108,AHB_MSTR_IF_MODULE_n_109}),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_1 (AXI_SLV_IF_MODULE_n_12),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_0 ({AHB_MSTR_IF_MODULE_n_98,AHB_MSTR_IF_MODULE_n_99,AHB_MSTR_IF_MODULE_n_100,AHB_MSTR_IF_MODULE_n_101,AHB_MSTR_IF_MODULE_n_102,AHB_MSTR_IF_MODULE_n_103}),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2]_1 (AXI_SLV_IF_MODULE_n_103),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_0 (AHB_MSTR_IF_MODULE_n_87),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_1 (AXI_SLV_IF_MODULE_n_13),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_2 (AXI_SLV_IF_MODULE_n_84),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_3 (AXI_SLV_IF_MODULE_n_89),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_4 (AXI_SLV_IF_MODULE_n_53),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[3]_5 (AXI_SLV_IF_MODULE_n_86),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 (AHB_MSTR_IF_MODULE_n_97),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 (AHB_MSTR_IF_MODULE_n_111),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_2 (AXI_SLV_IF_MODULE_n_102),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_3 (AXI_SLV_IF_MODULE_n_52),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_4 (AXI_SLV_IF_MODULE_n_93),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5]_0 (AXI_SLV_IF_MODULE_n_101),
        .\HBURST_i_reg[0]_0 (AXI_SLV_IF_MODULE_n_88),
        .\HBURST_i_reg[2]_i_3 (axi_address),
        .\HBURST_i_reg[2]_i_3_0 (AXI_SLV_IF_MODULE_n_95),
        .\HBURST_i_reg[2]_i_4 (AXI_SLV_IF_MODULE_n_100),
        .\HBURST_i_reg[2]_i_4_0 (AXI_SLV_IF_MODULE_n_99),
        .\HBURST_i_reg[2]_i_4_1 (AXI_SLV_IF_MODULE_n_98),
        .\HBURST_i_reg[2]_i_4_2 (AXI_SLV_IF_MODULE_n_97),
        .\HBURST_i_reg[2]_i_4_3 (AXI_SLV_IF_MODULE_n_96),
        .\HBURST_i_reg[2]_i_4_4 (AXI_SLV_IF_MODULE_n_94),
        .\HSIZE_i_reg[2]_0 (m_ahb_hsize),
        .\HSIZE_i_reg[2]_1 (axi_size),
        .\HWDATA_i_reg[31]_0 (axi_wdata),
        .HWRITE_i_reg_0(AXI_SLV_IF_MODULE_n_91),
        .\M_AHB_HTRANS[0]_i_2_0 (AXI_SLV_IF_MODULE_n_85),
        .\M_AHB_HTRANS[0]_i_2_1 (AXI_SLV_IF_MODULE_n_104),
        .\M_AHB_HTRANS[1]_i_3_0 (AXI_SLV_IF_MODULE_n_44),
        .\M_AHB_HTRANS[1]_i_3_1 (AXI_SLV_IF_MODULE_n_62),
        .\M_AHB_HTRANS[1]_i_4_0 (AXI_SLV_IF_MODULE_n_82),
        .\M_AHB_HTRANS[1]_i_4_1 (AXI_SLV_IF_MODULE_n_63),
        .\M_AHB_HTRANS_reg[0]_0 (AXI_SLV_IF_MODULE_n_42),
        .\M_AHB_HTRANS_reg[0]_1 (AXI_SLV_IF_MODULE_n_46),
        .\M_AHB_HTRANS_reg[0]_2 (AXI_SLV_IF_MODULE_n_47),
        .O(p_0_in1_in),
        .Q({axi_cache[3:2],axi_cache[0]}),
        .RRESP_1_i(RRESP_1_i),
        .RRESP_1_i_reg(AXI_SLV_IF_MODULE_n_48),
        .S({AHB_MSTR_IF_MODULE_n_147,AHB_MSTR_IF_MODULE_n_148,AHB_MSTR_IF_MODULE_n_149,AHB_MSTR_IF_MODULE_n_150,AHB_MSTR_IF_MODULE_n_151,AHB_MSTR_IF_MODULE_n_152,AHB_MSTR_IF_MODULE_n_153,AHB_MSTR_IF_MODULE_n_154}),
        .ahb_burst(ahb_burst),
        .\axi_address_reg[9] ({AHB_MSTR_IF_MODULE_n_155,AHB_MSTR_IF_MODULE_n_156}),
        .axi_lock(axi_lock),
        .\axi_size_reg[0] (AHB_MSTR_IF_MODULE_n_61),
        .\axi_size_reg[0]_0 (AHB_MSTR_IF_MODULE_n_64),
        .\axi_size_reg[0]_1 (AHB_MSTR_IF_MODULE_n_65),
        .\axi_size_reg[0]_10 (AHB_MSTR_IF_MODULE_n_89),
        .\axi_size_reg[0]_2 (AHB_MSTR_IF_MODULE_n_66),
        .\axi_size_reg[0]_3 (AHB_MSTR_IF_MODULE_n_67),
        .\axi_size_reg[0]_4 (AHB_MSTR_IF_MODULE_n_68),
        .\axi_size_reg[0]_5 (AHB_MSTR_IF_MODULE_n_69),
        .\axi_size_reg[0]_6 (AHB_MSTR_IF_MODULE_n_70),
        .\axi_size_reg[0]_7 (AHB_MSTR_IF_MODULE_n_71),
        .\axi_size_reg[0]_8 (AHB_MSTR_IF_MODULE_n_76),
        .\axi_size_reg[0]_9 (AHB_MSTR_IF_MODULE_n_82),
        .\axi_size_reg[1] (AHB_MSTR_IF_MODULE_n_72),
        .\axi_size_reg[1]_0 (AHB_MSTR_IF_MODULE_n_73),
        .\axi_size_reg[1]_1 (AHB_MSTR_IF_MODULE_n_74),
        .\axi_size_reg[1]_10 (AHB_MSTR_IF_MODULE_n_91),
        .\axi_size_reg[1]_11 (AHB_MSTR_IF_MODULE_n_92),
        .\axi_size_reg[1]_12 (AHB_MSTR_IF_MODULE_n_93),
        .\axi_size_reg[1]_13 (AHB_MSTR_IF_MODULE_n_94),
        .\axi_size_reg[1]_14 (AHB_MSTR_IF_MODULE_n_95),
        .\axi_size_reg[1]_2 (AHB_MSTR_IF_MODULE_n_75),
        .\axi_size_reg[1]_3 (AHB_MSTR_IF_MODULE_n_77),
        .\axi_size_reg[1]_4 (AHB_MSTR_IF_MODULE_n_78),
        .\axi_size_reg[1]_5 (AHB_MSTR_IF_MODULE_n_79),
        .\axi_size_reg[1]_6 (AHB_MSTR_IF_MODULE_n_80),
        .\axi_size_reg[1]_7 (AHB_MSTR_IF_MODULE_n_81),
        .\axi_size_reg[1]_8 (AHB_MSTR_IF_MODULE_n_88),
        .\axi_size_reg[1]_9 (AHB_MSTR_IF_MODULE_n_90),
        .load_counter_reg_0(s_axi_arready),
        .load_counter_sm(load_counter_sm),
        .m_ahb_haddr(m_ahb_haddr),
        .m_ahb_hburst(m_ahb_hburst),
        .m_ahb_hmastlock(m_ahb_hmastlock),
        .m_ahb_hprot(\^m_ahb_hprot ),
        .m_ahb_hrdata({m_ahb_hrdata[30],m_ahb_hrdata[22],m_ahb_hrdata[17:16],m_ahb_hrdata[1]}),
        .m_ahb_hready(m_ahb_hready),
        .m_ahb_hresp(m_ahb_hresp),
        .m_ahb_htrans(m_ahb_htrans),
        .m_ahb_hwdata(m_ahb_hwdata),
        .m_ahb_hwrite(m_ahb_hwrite),
        .one_kb_cross(one_kb_cross),
        .one_kb_in_progress(one_kb_in_progress),
        .one_kb_in_progress_reg_0(AHB_MSTR_IF_MODULE_n_46),
        .out(s_axi_rready_int),
        .p_1_in(p_1_in),
        .p_2_in(p_2_in_0),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_aresetn_int(s_axi_aresetn_int),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wvalid_0(AHB_MSTR_IF_MODULE_n_53),
        .send_wrap_burst(send_wrap_burst),
        .single_ahb_rd_xfer(single_ahb_rd_xfer),
        .single_ahb_wr(single_ahb_wr),
        .single_ahb_wr_reg_0(AXI_SLV_IF_MODULE_n_105),
        .wr_err_occured0(wr_err_occured0),
        .\wrap_brst_count_reg[0]_0 (AHB_MSTR_IF_MODULE_n_49),
        .\wrap_brst_count_reg[1]_0 (AHB_MSTR_IF_MODULE_n_42),
        .\wrap_brst_count_reg[7]_0 (axi_length),
        .wrap_in_progress(wrap_in_progress),
        .write_in_progress(write_in_progress));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_slv_if AXI_SLV_IF_MODULE
       (.ARREADY_i_reg_0(s_axi_arready),
        .ARREADY_i_reg_1(AXI_SLV_IF_MODULE_n_13),
        .ARREADY_i_reg_2(p_1_in),
        .AWREADY_i_reg_0(s_axi_awready),
        .AWREADY_i_reg_1(HADDR_i1),
        .CO(AXI_SLV_IF_MODULE_n_80),
        .D({p_2_in[30],p_2_in[22],p_2_in[17:16],p_2_in[1]}),
        .E(VALID_READY_SKID_n_4),
        .\FSM_sequential_ahb_wr_rd_cs_reg[0] (AXI_SLV_IF_MODULE_n_48),
        .\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 (AXI_SLV_IF_MODULE_n_84),
        .\FSM_sequential_ahb_wr_rd_cs_reg[1] (AHB_MSTR_IF_MODULE_n_46),
        .\FSM_sequential_ahb_wr_rd_cs_reg[2] (AXI_SLV_IF_MODULE_n_46),
        .\FSM_sequential_axi_write_cs_reg[0]_0 (AXI_SLV_IF_MODULE_n_45),
        .\FSM_sequential_axi_write_cs_reg[0]_1 (AHB_MSTR_IF_MODULE_n_48),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_0 (data4),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_1 (AHB_MSTR_IF_MODULE_n_87),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_2_0 (AHB_MSTR_IF_MODULE_n_97),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0] (AXI_SLV_IF_MODULE_n_41),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[10] (AHB_MSTR_IF_MODULE_n_94),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11] (AHB_MSTR_IF_MODULE_n_95),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11]_0 ({AHB_MSTR_IF_MODULE_n_104,AHB_MSTR_IF_MODULE_n_105,AHB_MSTR_IF_MODULE_n_106}),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[12] (AHB_MSTR_IF_MODULE_n_61),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[13] (AHB_MSTR_IF_MODULE_n_64),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[14] (AHB_MSTR_IF_MODULE_n_65),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15] (AHB_MSTR_IF_MODULE_n_66),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16] (AHB_MSTR_IF_MODULE_n_67),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[17] (AHB_MSTR_IF_MODULE_n_68),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[18] (AHB_MSTR_IF_MODULE_n_69),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[19] (AHB_MSTR_IF_MODULE_n_70),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1] (AXI_SLV_IF_MODULE_n_12),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 (AHB_MSTR_IF_MODULE_n_96),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[20] (AHB_MSTR_IF_MODULE_n_71),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[21] (AHB_MSTR_IF_MODULE_n_72),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[22] (AHB_MSTR_IF_MODULE_n_73),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23] (AHB_MSTR_IF_MODULE_n_74),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24] (AHB_MSTR_IF_MODULE_n_75),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[25] (AHB_MSTR_IF_MODULE_n_76),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[26] (AHB_MSTR_IF_MODULE_n_77),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[27] (AHB_MSTR_IF_MODULE_n_78),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[28] (AHB_MSTR_IF_MODULE_n_79),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[29] (AHB_MSTR_IF_MODULE_n_80),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2] (AHB_MSTR_IF_MODULE_n_88),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[30] (AHB_MSTR_IF_MODULE_n_81),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] (p_2_in_0),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_0 (AHB_MSTR_IF_MODULE_n_82),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] (AHB_MSTR_IF_MODULE_n_50),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ({AHB_MSTR_IF_MODULE_n_107,AHB_MSTR_IF_MODULE_n_108,AHB_MSTR_IF_MODULE_n_109}),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 (AHB_MSTR_IF_MODULE_n_111),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5] (AHB_MSTR_IF_MODULE_n_89),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[6] (AHB_MSTR_IF_MODULE_n_90),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7] (AHB_MSTR_IF_MODULE_n_91),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8] (AHB_MSTR_IF_MODULE_n_92),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 ({AHB_MSTR_IF_MODULE_n_98,AHB_MSTR_IF_MODULE_n_99,AHB_MSTR_IF_MODULE_n_100,AHB_MSTR_IF_MODULE_n_101,AHB_MSTR_IF_MODULE_n_102,AHB_MSTR_IF_MODULE_n_103}),
        .\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[9] (AHB_MSTR_IF_MODULE_n_93),
        .\HBURST_i_reg[2] ({AHB_MSTR_IF_MODULE_n_155,AHB_MSTR_IF_MODULE_n_156}),
        .HWRITE_i_reg(AXI_SLV_IF_MODULE_n_91),
        .\M_AHB_HTRANS[1]_i_14 (AHB_MSTR_IF_MODULE_n_49),
        .\M_AHB_HTRANS[1]_i_2 (AHB_MSTR_IF_MODULE_n_42),
        .\M_AHB_HTRANS[1]_i_2_0 ({ahb_wr_rd_cs[3:2],ahb_wr_rd_cs[0]}),
        .\M_AHB_HTRANS[1]_i_2_1 (AHB_MSTR_IF_MODULE_n_83),
        .O(p_0_in1_in),
        .Q(axi_size),
        .\RID_i_reg[15]_0 (RID_i),
        .RLAST_i_reg_0(AHB_MSTR_IF_MODULE_n_52),
        .RRESP_1_i(RRESP_1_i),
        .S({AHB_MSTR_IF_MODULE_n_147,AHB_MSTR_IF_MODULE_n_148,AHB_MSTR_IF_MODULE_n_149,AHB_MSTR_IF_MODULE_n_150,AHB_MSTR_IF_MODULE_n_151,AHB_MSTR_IF_MODULE_n_152,AHB_MSTR_IF_MODULE_n_153,AHB_MSTR_IF_MODULE_n_154}),
        .\S_AXI_RDATA_reg[31]_0 (S_AXI_RDATA),
        .ahb_burst(ahb_burst),
        .\axi_address_reg[2]_0 (AXI_SLV_IF_MODULE_n_103),
        .\axi_address_reg[4]_0 (AXI_SLV_IF_MODULE_n_102),
        .\axi_address_reg[9]_0 (axi_address),
        .\axi_burst_reg[0]_0 (AXI_SLV_IF_MODULE_n_85),
        .\axi_burst_reg[1]_0 (AXI_SLV_IF_MODULE_n_44),
        .\axi_burst_reg[1]_1 (AXI_SLV_IF_MODULE_n_47),
        .\axi_burst_reg[1]_2 (AXI_SLV_IF_MODULE_n_62),
        .\axi_burst_reg[1]_3 (AXI_SLV_IF_MODULE_n_63),
        .\axi_burst_reg[1]_4 (AXI_SLV_IF_MODULE_n_83),
        .\axi_burst_reg[1]_5 (AXI_SLV_IF_MODULE_n_92),
        .\axi_cache_reg[3]_0 ({axi_cache[3:2],axi_cache[0]}),
        .\axi_length_reg[0]_0 (AXI_SLV_IF_MODULE_n_99),
        .\axi_length_reg[1]_0 (AXI_SLV_IF_MODULE_n_43),
        .\axi_length_reg[1]_1 (AXI_SLV_IF_MODULE_n_89),
        .\axi_length_reg[1]_2 (AXI_SLV_IF_MODULE_n_98),
        .\axi_length_reg[1]_3 (AXI_SLV_IF_MODULE_n_104),
        .\axi_length_reg[2]_0 (AXI_SLV_IF_MODULE_n_52),
        .\axi_length_reg[2]_1 (AXI_SLV_IF_MODULE_n_93),
        .\axi_length_reg[2]_2 (AXI_SLV_IF_MODULE_n_97),
        .\axi_length_reg[3]_0 (AXI_SLV_IF_MODULE_n_53),
        .\axi_length_reg[3]_1 (AXI_SLV_IF_MODULE_n_86),
        .\axi_length_reg[3]_2 (AXI_SLV_IF_MODULE_n_90),
        .\axi_length_reg[3]_3 (AXI_SLV_IF_MODULE_n_96),
        .\axi_length_reg[3]_4 (AXI_SLV_IF_MODULE_n_101),
        .\axi_length_reg[4]_0 (AXI_SLV_IF_MODULE_n_94),
        .\axi_length_reg[5]_0 (AXI_SLV_IF_MODULE_n_95),
        .\axi_length_reg[7]_0 (axi_length),
        .axi_lock(axi_lock),
        .\axi_prot_reg[0]_0 ({axi_prot,p_3_out}),
        .\axi_size_reg[0]_0 (AXI_SLV_IF_MODULE_n_76),
        .\axi_size_reg[1]_0 (AXI_SLV_IF_MODULE_n_87),
        .\axi_size_reg[2]_0 (AXI_SLV_IF_MODULE_n_100),
        .\axi_wdata_reg[0]_0 (AHB_MSTR_IF_MODULE_n_110),
        .\axi_wdata_reg[0]_1 (AHB_MSTR_IF_MODULE_n_53),
        .\axi_wdata_reg[31]_0 (axi_wdata),
        .load_counter_reg(AHB_MSTR_IF_MODULE_n_47),
        .load_counter_sm(load_counter_sm),
        .m_ahb_haddr(m_ahb_haddr),
        .m_ahb_hrdata({m_ahb_hrdata[31],m_ahb_hrdata[29:23],m_ahb_hrdata[21:18],m_ahb_hrdata[15:2],m_ahb_hrdata[0]}),
        .m_ahb_hwrite(m_ahb_hwrite),
        .one_kb_cross(one_kb_cross),
        .one_kb_in_progress(one_kb_in_progress),
        .one_kb_in_progress_reg(AXI_SLV_IF_MODULE_n_82),
        .out(s_axi_rready_int),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arcache({s_axi_arcache[3:2],s_axi_arcache[0]}),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_aresetn_0(AXI_SLV_IF_MODULE_n_88),
        .s_axi_aresetn_int(s_axi_aresetn_int),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arlock(s_axi_arlock),
        .s_axi_arprot({s_axi_arprot[2],s_axi_arprot[0]}),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache({s_axi_awcache[3:2],s_axi_awcache[0]}),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot({s_axi_awprot[2],s_axi_awprot[0]}),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(s_axi_bid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(\^s_axi_bresp ),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rlast_int(s_axi_rlast_int),
        .s_axi_rresp_int(s_axi_rresp_int),
        .s_axi_rvalid_int(s_axi_rvalid_int),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .send_wrap_burst(send_wrap_burst),
        .sig_s_ready_out_reg(AXI_SLV_IF_MODULE_n_42),
        .single_ahb_rd_xfer(single_ahb_rd_xfer),
        .single_ahb_wr(single_ahb_wr),
        .single_axi_wr_xfer_reg_0(AXI_SLV_IF_MODULE_n_105),
        .wr_err_occured0(wr_err_occured0),
        .wrap_in_progress(wrap_in_progress),
        .write_in_progress(write_in_progress));
  GND GND
       (.G(\<const0> ));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_skid_buf VALID_READY_SKID
       (.D(RID_i),
        .E(VALID_READY_SKID_n_4),
        .RRESP_1_i_reg(AXI_SLV_IF_MODULE_n_48),
        .out(s_axi_rready_int),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_aresetn_int(s_axi_aresetn_int),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(s_axi_rid),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rlast_int(s_axi_rlast_int),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(\^s_axi_rresp ),
        .s_axi_rresp_int(s_axi_rresp_int),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rvalid_int(s_axi_rvalid_int),
        .\sig_data_skid_reg_reg[31]_0 (S_AXI_RDATA));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_slv_if
   (AWREADY_i_reg_0,
    s_axi_aresetn_int,
    s_axi_wready,
    s_axi_bvalid,
    ARREADY_i_reg_0,
    s_axi_rvalid_int,
    s_axi_rlast_int,
    s_axi_rresp_int,
    axi_lock,
    write_in_progress,
    single_ahb_rd_xfer,
    s_axi_bresp,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1] ,
    ARREADY_i_reg_1,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] ,
    ARREADY_i_reg_2,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0] ,
    sig_s_ready_out_reg,
    \axi_length_reg[1]_0 ,
    \axi_burst_reg[1]_0 ,
    \FSM_sequential_axi_write_cs_reg[0]_0 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[2] ,
    \axi_burst_reg[1]_1 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[0] ,
    Q,
    \axi_length_reg[2]_0 ,
    \axi_length_reg[3]_0 ,
    \axi_length_reg[7]_0 ,
    \axi_burst_reg[1]_2 ,
    \axi_burst_reg[1]_3 ,
    load_counter_sm,
    send_wrap_burst,
    \axi_address_reg[9]_0 ,
    \axi_size_reg[0]_0 ,
    AWREADY_i_reg_1,
    ahb_burst,
    CO,
    O,
    one_kb_in_progress_reg,
    \axi_burst_reg[1]_4 ,
    \FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ,
    \axi_burst_reg[0]_0 ,
    \axi_length_reg[3]_1 ,
    \axi_size_reg[1]_0 ,
    s_axi_aresetn_0,
    \axi_length_reg[1]_1 ,
    \axi_length_reg[3]_2 ,
    HWRITE_i_reg,
    \axi_burst_reg[1]_5 ,
    \axi_length_reg[2]_1 ,
    \axi_length_reg[4]_0 ,
    \axi_length_reg[5]_0 ,
    \axi_length_reg[3]_3 ,
    \axi_length_reg[2]_2 ,
    \axi_length_reg[1]_2 ,
    \axi_length_reg[0]_0 ,
    \axi_size_reg[2]_0 ,
    \axi_length_reg[3]_4 ,
    \axi_address_reg[4]_0 ,
    \axi_address_reg[2]_0 ,
    \axi_length_reg[1]_3 ,
    single_axi_wr_xfer_reg_0,
    \RID_i_reg[15]_0 ,
    \S_AXI_RDATA_reg[31]_0 ,
    s_axi_bid,
    \axi_prot_reg[0]_0 ,
    \axi_cache_reg[3]_0 ,
    \axi_wdata_reg[31]_0 ,
    s_axi_aclk,
    E,
    RRESP_1_i,
    m_ahb_haddr,
    s_axi_aresetn,
    s_axi_arvalid,
    s_axi_awburst,
    s_axi_awvalid,
    \FSM_sequential_axi_write_cs_reg[0]_1 ,
    s_axi_wlast,
    s_axi_wvalid,
    \axi_wdata_reg[0]_0 ,
    \axi_wdata_reg[0]_1 ,
    s_axi_bready,
    s_axi_awlen,
    s_axi_arlen,
    s_axi_awaddr,
    s_axi_araddr,
    s_axi_arburst,
    s_axi_arsize,
    s_axi_awsize,
    s_axi_wstrb,
    s_axi_awcache,
    s_axi_arcache,
    s_axi_awprot,
    s_axi_arprot,
    s_axi_awlock,
    s_axi_arlock,
    out,
    \M_AHB_HTRANS[1]_i_2 ,
    \M_AHB_HTRANS[1]_i_2_0 ,
    \M_AHB_HTRANS[1]_i_2_1 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] ,
    \FSM_sequential_ahb_wr_rd_cs_reg[1] ,
    \M_AHB_HTRANS[1]_i_14 ,
    load_counter_reg,
    RLAST_i_reg_0,
    D,
    m_ahb_hrdata,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_1 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[6] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[9] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[10] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[30] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[29] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[28] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[27] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[26] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[25] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[22] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[21] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[20] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[19] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[18] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[17] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[14] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[13] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[12] ,
    one_kb_cross,
    one_kb_in_progress,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11]_0 ,
    wrap_in_progress,
    m_ahb_hwrite,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_2_0 ,
    S,
    \HBURST_i_reg[2] ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ,
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2] ,
    wr_err_occured0,
    single_ahb_wr,
    s_axi_arid,
    s_axi_awid,
    s_axi_wdata);
  output AWREADY_i_reg_0;
  output s_axi_aresetn_int;
  output s_axi_wready;
  output s_axi_bvalid;
  output ARREADY_i_reg_0;
  output s_axi_rvalid_int;
  output s_axi_rlast_int;
  output [0:0]s_axi_rresp_int;
  output axi_lock;
  output write_in_progress;
  output single_ahb_rd_xfer;
  output [0:0]s_axi_bresp;
  output \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1] ;
  output ARREADY_i_reg_1;
  output [25:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] ;
  output [0:0]ARREADY_i_reg_2;
  output \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0] ;
  output sig_s_ready_out_reg;
  output \axi_length_reg[1]_0 ;
  output \axi_burst_reg[1]_0 ;
  output \FSM_sequential_axi_write_cs_reg[0]_0 ;
  output \FSM_sequential_ahb_wr_rd_cs_reg[2] ;
  output \axi_burst_reg[1]_1 ;
  output \FSM_sequential_ahb_wr_rd_cs_reg[0] ;
  output [2:0]Q;
  output \axi_length_reg[2]_0 ;
  output \axi_length_reg[3]_0 ;
  output [7:0]\axi_length_reg[7]_0 ;
  output \axi_burst_reg[1]_2 ;
  output \axi_burst_reg[1]_3 ;
  output load_counter_sm;
  output send_wrap_burst;
  output [9:0]\axi_address_reg[9]_0 ;
  output \axi_size_reg[0]_0 ;
  output [0:0]AWREADY_i_reg_1;
  output [1:0]ahb_burst;
  output [0:0]CO;
  output [0:0]O;
  output one_kb_in_progress_reg;
  output \axi_burst_reg[1]_4 ;
  output \FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ;
  output \axi_burst_reg[0]_0 ;
  output \axi_length_reg[3]_1 ;
  output \axi_size_reg[1]_0 ;
  output s_axi_aresetn_0;
  output \axi_length_reg[1]_1 ;
  output \axi_length_reg[3]_2 ;
  output HWRITE_i_reg;
  output \axi_burst_reg[1]_5 ;
  output \axi_length_reg[2]_1 ;
  output \axi_length_reg[4]_0 ;
  output \axi_length_reg[5]_0 ;
  output \axi_length_reg[3]_3 ;
  output \axi_length_reg[2]_2 ;
  output \axi_length_reg[1]_2 ;
  output \axi_length_reg[0]_0 ;
  output \axi_size_reg[2]_0 ;
  output \axi_length_reg[3]_4 ;
  output \axi_address_reg[4]_0 ;
  output \axi_address_reg[2]_0 ;
  output \axi_length_reg[1]_3 ;
  output single_axi_wr_xfer_reg_0;
  output [15:0]\RID_i_reg[15]_0 ;
  output [31:0]\S_AXI_RDATA_reg[31]_0 ;
  output [15:0]s_axi_bid;
  output [1:0]\axi_prot_reg[0]_0 ;
  output [2:0]\axi_cache_reg[3]_0 ;
  output [31:0]\axi_wdata_reg[31]_0 ;
  input s_axi_aclk;
  input [0:0]E;
  input RRESP_1_i;
  input [31:0]m_ahb_haddr;
  input s_axi_aresetn;
  input s_axi_arvalid;
  input [1:0]s_axi_awburst;
  input s_axi_awvalid;
  input \FSM_sequential_axi_write_cs_reg[0]_1 ;
  input s_axi_wlast;
  input s_axi_wvalid;
  input \axi_wdata_reg[0]_0 ;
  input \axi_wdata_reg[0]_1 ;
  input s_axi_bready;
  input [7:0]s_axi_awlen;
  input [7:0]s_axi_arlen;
  input [31:0]s_axi_awaddr;
  input [31:0]s_axi_araddr;
  input [1:0]s_axi_arburst;
  input [2:0]s_axi_arsize;
  input [2:0]s_axi_awsize;
  input [3:0]s_axi_wstrb;
  input [2:0]s_axi_awcache;
  input [2:0]s_axi_arcache;
  input [1:0]s_axi_awprot;
  input [1:0]s_axi_arprot;
  input s_axi_awlock;
  input s_axi_arlock;
  input out;
  input \M_AHB_HTRANS[1]_i_2 ;
  input [2:0]\M_AHB_HTRANS[1]_i_2_0 ;
  input \M_AHB_HTRANS[1]_i_2_1 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] ;
  input \FSM_sequential_ahb_wr_rd_cs_reg[1] ;
  input \M_AHB_HTRANS[1]_i_14 ;
  input load_counter_reg;
  input RLAST_i_reg_0;
  input [4:0]D;
  input [26:0]m_ahb_hrdata;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ;
  input [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ;
  input [1:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_0 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_1 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[6] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[9] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[10] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_0 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[30] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[29] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[28] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[27] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[26] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[25] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[22] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[21] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[20] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[19] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[18] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[17] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[14] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[13] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[12] ;
  input one_kb_cross;
  input one_kb_in_progress;
  input [5:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 ;
  input [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11]_0 ;
  input wrap_in_progress;
  input m_ahb_hwrite;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_2_0 ;
  input [7:0]S;
  input [1:0]\HBURST_i_reg[2] ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ;
  input \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2] ;
  input wr_err_occured0;
  input single_ahb_wr;
  input [15:0]s_axi_arid;
  input [15:0]s_axi_awid;
  input [31:0]s_axi_wdata;

  wire [1:1]\AHB_MSTR_IF_MODULE/p_1_in ;
  wire [5:0]\AHB_MSTR_IF_MODULE/p_2_in ;
  wire ARREADY_i_reg_0;
  wire ARREADY_i_reg_1;
  wire [0:0]ARREADY_i_reg_2;
  wire AWREADY_i_i_2_n_0;
  wire AWREADY_i_reg_0;
  wire [0:0]AWREADY_i_reg_1;
  wire BVALID_sm;
  wire [0:0]CO;
  wire [4:0]D;
  wire [0:0]E;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[0] ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[1] ;
  wire \FSM_sequential_ahb_wr_rd_cs_reg[2] ;
  wire \FSM_sequential_axi_read_cs[2]_i_1_n_0 ;
  wire \FSM_sequential_axi_read_cs[2]_i_4_n_0 ;
  wire \FSM_sequential_axi_read_cs[2]_i_5_n_0 ;
  wire \FSM_sequential_axi_write_cs[2]_i_1_n_0 ;
  wire \FSM_sequential_axi_write_cs[2]_i_3_n_0 ;
  wire \FSM_sequential_axi_write_cs[2]_i_4_n_0 ;
  wire \FSM_sequential_axi_write_cs[2]_i_5_n_0 ;
  wire \FSM_sequential_axi_write_cs[2]_i_6_n_0 ;
  wire \FSM_sequential_axi_write_cs[2]_i_7_n_0 ;
  wire \FSM_sequential_axi_write_cs_reg[0]_0 ;
  wire \FSM_sequential_axi_write_cs_reg[0]_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_2_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_4_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[10]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_2_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_5_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_6_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_8_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_4_n_0 ;
  wire [1:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_4_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_2_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_6_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[6]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i[9]_i_3_n_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[10] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11] ;
  wire [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[12] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[13] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[14] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[17] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[18] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[19] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[20] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[21] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[22] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[25] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[26] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[27] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[28] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[29] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[30] ;
  wire [25:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] ;
  wire [2:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[6] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7] ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8] ;
  wire [5:0]\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 ;
  wire \GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[9] ;
  wire \HBURST_i[0]_i_2_n_0 ;
  wire \HBURST_i[0]_i_3_n_0 ;
  wire \HBURST_i[1]_i_2_n_0 ;
  wire \HBURST_i[2]_i_2_n_0 ;
  wire \HBURST_i[2]_i_5_n_0 ;
  wire [1:0]\HBURST_i_reg[2] ;
  wire \HBURST_i_reg[2]_i_3_n_6 ;
  wire \HBURST_i_reg[2]_i_3_n_7 ;
  wire \HBURST_i_reg[2]_i_4_n_0 ;
  wire \HBURST_i_reg[2]_i_4_n_1 ;
  wire \HBURST_i_reg[2]_i_4_n_2 ;
  wire \HBURST_i_reg[2]_i_4_n_3 ;
  wire \HBURST_i_reg[2]_i_4_n_4 ;
  wire \HBURST_i_reg[2]_i_4_n_5 ;
  wire \HBURST_i_reg[2]_i_4_n_6 ;
  wire \HBURST_i_reg[2]_i_4_n_7 ;
  wire HWRITE_i_reg;
  wire \M_AHB_HTRANS[1]_i_14 ;
  wire \M_AHB_HTRANS[1]_i_2 ;
  wire [2:0]\M_AHB_HTRANS[1]_i_2_0 ;
  wire \M_AHB_HTRANS[1]_i_2_1 ;
  wire [0:0]O;
  wire [2:0]Q;
  wire [15:0]\RID_i_reg[15]_0 ;
  wire RLAST_i_reg_0;
  wire RLAST_sm;
  wire RRESP_1_i;
  wire RVALID_sm;
  wire [7:0]S;
  wire [31:0]\S_AXI_RDATA_reg[31]_0 ;
  wire WREADY_i_i_4_n_0;
  wire [1:0]ahb_burst;
  wire [31:10]axi_address;
  wire \axi_address_reg[2]_0 ;
  wire \axi_address_reg[4]_0 ;
  wire [9:0]\axi_address_reg[9]_0 ;
  wire [1:0]axi_burst;
  wire \axi_burst[0]_i_1_n_0 ;
  wire \axi_burst[1]_i_1_n_0 ;
  wire \axi_burst_reg[0]_0 ;
  wire \axi_burst_reg[1]_0 ;
  wire \axi_burst_reg[1]_1 ;
  wire \axi_burst_reg[1]_2 ;
  wire \axi_burst_reg[1]_3 ;
  wire \axi_burst_reg[1]_4 ;
  wire \axi_burst_reg[1]_5 ;
  wire \axi_cache[0]_i_1_n_0 ;
  wire \axi_cache[2]_i_1_n_0 ;
  wire \axi_cache[3]_i_1_n_0 ;
  wire [2:0]\axi_cache_reg[3]_0 ;
  wire \axi_length[0]_i_1_n_0 ;
  wire \axi_length[1]_i_1_n_0 ;
  wire \axi_length[2]_i_1_n_0 ;
  wire \axi_length[3]_i_1_n_0 ;
  wire \axi_length[4]_i_1_n_0 ;
  wire \axi_length[5]_i_1_n_0 ;
  wire \axi_length[6]_i_1_n_0 ;
  wire \axi_length[7]_i_1_n_0 ;
  wire \axi_length_reg[0]_0 ;
  wire \axi_length_reg[1]_0 ;
  wire \axi_length_reg[1]_1 ;
  wire \axi_length_reg[1]_2 ;
  wire \axi_length_reg[1]_3 ;
  wire \axi_length_reg[2]_0 ;
  wire \axi_length_reg[2]_1 ;
  wire \axi_length_reg[2]_2 ;
  wire \axi_length_reg[3]_0 ;
  wire \axi_length_reg[3]_1 ;
  wire \axi_length_reg[3]_2 ;
  wire \axi_length_reg[3]_3 ;
  wire \axi_length_reg[3]_4 ;
  wire \axi_length_reg[4]_0 ;
  wire \axi_length_reg[5]_0 ;
  wire [7:0]\axi_length_reg[7]_0 ;
  wire axi_lock;
  wire axi_lock_i_1_n_0;
  wire \axi_prot[0]_i_1_n_0 ;
  wire \axi_prot[0]_i_2_n_0 ;
  wire \axi_prot[2]_inv_i_1_n_0 ;
  wire [1:0]\axi_prot_reg[0]_0 ;
  wire [2:0]axi_read_cs;
  wire [2:0]axi_read_ns__0;
  wire [15:0]axi_rid;
  wire \axi_size[0]_i_1_n_0 ;
  wire \axi_size[0]_i_2_n_0 ;
  wire \axi_size[0]_i_3_n_0 ;
  wire \axi_size[1]_i_1_n_0 ;
  wire \axi_size[2]_i_1_n_0 ;
  wire \axi_size[2]_i_2_n_0 ;
  wire \axi_size[2]_i_3_n_0 ;
  wire \axi_size[2]_i_4_n_0 ;
  wire \axi_size_reg[0]_0 ;
  wire \axi_size_reg[1]_0 ;
  wire \axi_size_reg[2]_0 ;
  wire \axi_wdata_reg[0]_0 ;
  wire \axi_wdata_reg[0]_1 ;
  wire [31:0]\axi_wdata_reg[31]_0 ;
  wire [15:0]axi_wid;
  wire [2:0]axi_write_cs;
  wire [2:0]axi_write_ns__0;
  wire load_counter_reg;
  wire load_counter_sm;
  wire [31:0]m_ahb_haddr;
  wire [26:0]m_ahb_hrdata;
  wire m_ahb_hwrite;
  wire one_kb_cross;
  wire one_kb_in_progress;
  wire one_kb_in_progress_reg;
  wire out;
  wire [31:0]p_1_in;
  wire [31:0]p_2_in;
  wire rd_request;
  wire read_in_progress;
  wire read_in_progress_i_1_n_0;
  wire s_axi_aclk;
  wire [31:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [2:0]s_axi_arcache;
  wire s_axi_aresetn;
  wire s_axi_aresetn_0;
  wire s_axi_aresetn_int;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire s_axi_arlock;
  wire [1:0]s_axi_arprot;
  wire [2:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire [31:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [2:0]s_axi_awcache;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire s_axi_awlock;
  wire [1:0]s_axi_awprot;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire [15:0]s_axi_bid;
  wire s_axi_bready;
  wire [0:0]s_axi_bresp;
  wire s_axi_bvalid;
  wire s_axi_rlast_int;
  wire [0:0]s_axi_rresp_int;
  wire s_axi_rvalid_int;
  wire [31:0]s_axi_wdata;
  wire s_axi_wlast;
  wire s_axi_wready;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;
  wire send_wrap_burst;
  wire sig_s_ready_out_reg;
  wire single_ahb_rd_xfer;
  wire single_ahb_wr;
  wire single_ahb_wr_xfer;
  wire single_axi_rd_xfer_i_1_n_0;
  wire single_axi_rd_xfer_i_2_n_0;
  wire single_axi_rd_xfer_i_3_n_0;
  wire single_axi_rd_xfer_i_4_n_0;
  wire single_axi_wr_xfer_i_1_n_0;
  wire single_axi_wr_xfer_i_2_n_0;
  wire single_axi_wr_xfer_i_3_n_0;
  wire single_axi_wr_xfer_reg_0;
  wire wr_err_occured0;
  wire wr_err_occured_i_1_n_0;
  wire wrap_in_progress;
  wire write_in_progress;
  wire write_in_progress_i_1_n_0;
  wire write_in_progress_i_2_n_0;
  wire write_pending;
  wire write_pending_i_1_n_0;
  wire write_ready_sm;
  wire write_waiting;
  wire [7:2]\NLW_HBURST_i_reg[2]_i_3_CO_UNCONNECTED ;
  wire [7:0]\NLW_HBURST_i_reg[2]_i_3_O_UNCONNECTED ;
  wire [7:0]\NLW_HBURST_i_reg[2]_i_4_O_UNCONNECTED ;

  LUT6 #(
    .INIT(64'h0000000000000004)) 
    ARREADY_i_i_1
       (.I0(write_pending),
        .I1(s_axi_arvalid),
        .I2(axi_read_cs[0]),
        .I3(write_in_progress),
        .I4(axi_read_cs[1]),
        .I5(axi_read_cs[2]),
        .O(rd_request));
  FDRE ARREADY_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(rd_request),
        .Q(ARREADY_i_reg_0),
        .R(s_axi_aresetn_int));
  LUT1 #(
    .INIT(2'h1)) 
    AWREADY_i_i_1
       (.I0(s_axi_aresetn),
        .O(s_axi_aresetn_int));
  LUT5 #(
    .INIT(32'h04000000)) 
    AWREADY_i_i_2
       (.I0(axi_write_cs[2]),
        .I1(axi_write_cs[0]),
        .I2(axi_write_cs[1]),
        .I3(s_axi_awvalid),
        .I4(s_axi_wvalid),
        .O(AWREADY_i_i_2_n_0));
  FDRE AWREADY_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(AWREADY_i_i_2_n_0),
        .Q(AWREADY_i_reg_0),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[0]),
        .Q(s_axi_bid[0]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[10] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[10]),
        .Q(s_axi_bid[10]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[11] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[11]),
        .Q(s_axi_bid[11]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[12] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[12]),
        .Q(s_axi_bid[12]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[13] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[13]),
        .Q(s_axi_bid[13]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[14] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[14]),
        .Q(s_axi_bid[14]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[15] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[15]),
        .Q(s_axi_bid[15]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[1]),
        .Q(s_axi_bid[1]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[2]),
        .Q(s_axi_bid[2]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[3]),
        .Q(s_axi_bid[3]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[4]),
        .Q(s_axi_bid[4]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[5]),
        .Q(s_axi_bid[5]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[6]),
        .Q(s_axi_bid[6]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[7]),
        .Q(s_axi_bid[7]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[8] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[8]),
        .Q(s_axi_bid[8]),
        .R(s_axi_aresetn_int));
  FDRE \BID_i_reg[9] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_wid[9]),
        .Q(s_axi_bid[9]),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT5 #(
    .INIT(32'h02C00EC0)) 
    BVALID_i_i_1
       (.I0(\FSM_sequential_axi_write_cs_reg[0]_1 ),
        .I1(axi_write_cs[0]),
        .I2(axi_write_cs[1]),
        .I3(axi_write_cs[2]),
        .I4(s_axi_bready),
        .O(BVALID_sm));
  FDRE BVALID_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(BVALID_sm),
        .Q(s_axi_bvalid),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT5 #(
    .INIT(32'h54545400)) 
    \FSM_sequential_ahb_wr_rd_cs[1]_i_3 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[1] ),
        .I1(\axi_length_reg[7]_0 [1]),
        .I2(\axi_length_reg[2]_0 ),
        .I3(axi_burst[0]),
        .I4(axi_burst[1]),
        .O(\axi_length_reg[1]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'h1FFF)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_10 
       (.I0(axi_burst[1]),
        .I1(axi_burst[0]),
        .I2(m_ahb_haddr[8]),
        .I3(m_ahb_haddr[6]),
        .O(\axi_burst_reg[1]_4 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'h08)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_16 
       (.I0(axi_burst[1]),
        .I1(axi_burst[0]),
        .I2(AWREADY_i_reg_0),
        .O(\axi_burst_reg[1]_5 ));
  LUT5 #(
    .INIT(32'h33200320)) 
    \FSM_sequential_ahb_wr_rd_cs[3]_i_5 
       (.I0(\axi_wdata_reg[0]_1 ),
        .I1(axi_write_cs[0]),
        .I2(axi_write_cs[1]),
        .I3(axi_write_cs[2]),
        .I4(s_axi_wvalid),
        .O(\FSM_sequential_axi_write_cs_reg[0]_0 ));
  LUT6 #(
    .INIT(64'h000000000404FFF0)) 
    \FSM_sequential_axi_read_cs[0]_i_1 
       (.I0(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .I1(RLAST_i_reg_0),
        .I2(axi_read_cs[0]),
        .I3(single_ahb_rd_xfer),
        .I4(axi_read_cs[1]),
        .I5(axi_read_cs[2]),
        .O(axi_read_ns__0[0]));
  LUT6 #(
    .INIT(64'h000F0F40000F0F4F)) 
    \FSM_sequential_axi_read_cs[1]_i_1 
       (.I0(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .I1(RLAST_i_reg_0),
        .I2(axi_read_cs[1]),
        .I3(axi_read_cs[2]),
        .I4(axi_read_cs[0]),
        .I5(single_ahb_rd_xfer),
        .O(axi_read_ns__0[1]));
  LUT6 #(
    .INIT(64'hFFFFFFFFF1FFF3F3)) 
    \FSM_sequential_axi_read_cs[2]_i_1 
       (.I0(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .I2(\FSM_sequential_axi_read_cs[2]_i_4_n_0 ),
        .I3(\FSM_sequential_axi_read_cs[2]_i_5_n_0 ),
        .I4(out),
        .I5(rd_request),
        .O(\FSM_sequential_axi_read_cs[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT5 #(
    .INIT(32'h00000B00)) 
    \FSM_sequential_axi_read_cs[2]_i_2 
       (.I0(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .I1(RLAST_i_reg_0),
        .I2(axi_read_cs[2]),
        .I3(axi_read_cs[1]),
        .I4(axi_read_cs[0]),
        .O(axi_read_ns__0[2]));
  LUT5 #(
    .INIT(32'hFFCBFFFF)) 
    \FSM_sequential_axi_read_cs[2]_i_3 
       (.I0(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .I1(axi_read_cs[0]),
        .I2(axi_read_cs[1]),
        .I3(axi_read_cs[2]),
        .I4(RLAST_i_reg_0),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[0] ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT4 #(
    .INIT(16'h0800)) 
    \FSM_sequential_axi_read_cs[2]_i_4 
       (.I0(out),
        .I1(axi_read_cs[1]),
        .I2(axi_read_cs[2]),
        .I3(axi_read_cs[0]),
        .O(\FSM_sequential_axi_read_cs[2]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hFB)) 
    \FSM_sequential_axi_read_cs[2]_i_5 
       (.I0(axi_read_cs[1]),
        .I1(axi_read_cs[2]),
        .I2(axi_read_cs[0]),
        .O(\FSM_sequential_axi_read_cs[2]_i_5_n_0 ));
  (* FSM_ENCODED_STATES = "axi_rd_idle:000,axi_reading:010,axi_read_last:001,axi_wait_rready:100,rd_resp:011" *) 
  FDRE \FSM_sequential_axi_read_cs_reg[0] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_axi_read_cs[2]_i_1_n_0 ),
        .D(axi_read_ns__0[0]),
        .Q(axi_read_cs[0]),
        .R(s_axi_aresetn_int));
  (* FSM_ENCODED_STATES = "axi_rd_idle:000,axi_reading:010,axi_read_last:001,axi_wait_rready:100,rd_resp:011" *) 
  FDRE \FSM_sequential_axi_read_cs_reg[1] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_axi_read_cs[2]_i_1_n_0 ),
        .D(axi_read_ns__0[1]),
        .Q(axi_read_cs[1]),
        .R(s_axi_aresetn_int));
  (* FSM_ENCODED_STATES = "axi_rd_idle:000,axi_reading:010,axi_read_last:001,axi_wait_rready:100,rd_resp:011" *) 
  FDRE \FSM_sequential_axi_read_cs_reg[2] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_axi_read_cs[2]_i_1_n_0 ),
        .D(axi_read_ns__0[2]),
        .Q(axi_read_cs[2]),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'h555500004000FFFF)) 
    \FSM_sequential_axi_write_cs[0]_i_1 
       (.I0(axi_write_cs[2]),
        .I1(\FSM_sequential_axi_write_cs_reg[0]_1 ),
        .I2(s_axi_wlast),
        .I3(s_axi_wvalid),
        .I4(axi_write_cs[1]),
        .I5(axi_write_cs[0]),
        .O(axi_write_ns__0[0]));
  LUT6 #(
    .INIT(64'h0000FDFD000F0000)) 
    \FSM_sequential_axi_write_cs[1]_i_1 
       (.I0(\FSM_sequential_axi_write_cs[2]_i_4_n_0 ),
        .I1(\FSM_sequential_axi_write_cs_reg[0]_1 ),
        .I2(axi_write_cs[2]),
        .I3(single_ahb_wr_xfer),
        .I4(axi_write_cs[0]),
        .I5(axi_write_cs[1]),
        .O(axi_write_ns__0[1]));
  LUT6 #(
    .INIT(64'hFFFFE2FF0000E200)) 
    \FSM_sequential_axi_write_cs[2]_i_1 
       (.I0(\FSM_sequential_axi_write_cs_reg[0]_1 ),
        .I1(axi_write_cs[0]),
        .I2(s_axi_bready),
        .I3(axi_write_cs[2]),
        .I4(axi_write_cs[1]),
        .I5(\FSM_sequential_axi_write_cs[2]_i_3_n_0 ),
        .O(\FSM_sequential_axi_write_cs[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h4462556255625562)) 
    \FSM_sequential_axi_write_cs[2]_i_2 
       (.I0(axi_write_cs[2]),
        .I1(axi_write_cs[0]),
        .I2(single_ahb_wr_xfer),
        .I3(axi_write_cs[1]),
        .I4(\FSM_sequential_axi_write_cs[2]_i_4_n_0 ),
        .I5(\FSM_sequential_axi_write_cs_reg[0]_1 ),
        .O(axi_write_ns__0[2]));
  LUT6 #(
    .INIT(64'hA0A0A0A0E0F5E5F5)) 
    \FSM_sequential_axi_write_cs[2]_i_3 
       (.I0(\FSM_sequential_axi_write_cs[2]_i_5_n_0 ),
        .I1(s_axi_wlast),
        .I2(s_axi_wvalid),
        .I3(\FSM_sequential_axi_write_cs[2]_i_6_n_0 ),
        .I4(\axi_wdata_reg[0]_0 ),
        .I5(\FSM_sequential_axi_write_cs[2]_i_7_n_0 ),
        .O(\FSM_sequential_axi_write_cs[2]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_sequential_axi_write_cs[2]_i_4 
       (.I0(s_axi_wvalid),
        .I1(s_axi_wlast),
        .O(\FSM_sequential_axi_write_cs[2]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'h8A)) 
    \FSM_sequential_axi_write_cs[2]_i_5 
       (.I0(axi_write_cs[2]),
        .I1(axi_write_cs[1]),
        .I2(axi_write_cs[0]),
        .O(\FSM_sequential_axi_write_cs[2]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \FSM_sequential_axi_write_cs[2]_i_6 
       (.I0(axi_write_cs[1]),
        .I1(axi_write_cs[0]),
        .O(\FSM_sequential_axi_write_cs[2]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT5 #(
    .INIT(32'h0000007F)) 
    \FSM_sequential_axi_write_cs[2]_i_7 
       (.I0(axi_write_cs[0]),
        .I1(s_axi_wvalid),
        .I2(s_axi_awvalid),
        .I3(axi_write_cs[1]),
        .I4(write_in_progress_i_2_n_0),
        .O(\FSM_sequential_axi_write_cs[2]_i_7_n_0 ));
  (* FSM_ENCODED_STATES = "axi_wr_idle:000,axi_wvalids_wait:001,axi_wr_resp:101,axi_writing:010,axi_wvalid_wait:110,axi_write_last:100,axi_wr_resp_wait:011" *) 
  FDRE \FSM_sequential_axi_write_cs_reg[0] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_axi_write_cs[2]_i_1_n_0 ),
        .D(axi_write_ns__0[0]),
        .Q(axi_write_cs[0]),
        .R(s_axi_aresetn_int));
  (* FSM_ENCODED_STATES = "axi_wr_idle:000,axi_wvalids_wait:001,axi_wr_resp:101,axi_writing:010,axi_wvalid_wait:110,axi_write_last:100,axi_wr_resp_wait:011" *) 
  FDRE \FSM_sequential_axi_write_cs_reg[1] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_axi_write_cs[2]_i_1_n_0 ),
        .D(axi_write_ns__0[1]),
        .Q(axi_write_cs[1]),
        .R(s_axi_aresetn_int));
  (* FSM_ENCODED_STATES = "axi_wr_idle:000,axi_wvalids_wait:001,axi_wr_resp:101,axi_writing:010,axi_wvalid_wait:110,axi_write_last:100,axi_wr_resp_wait:011" *) 
  FDRE \FSM_sequential_axi_write_cs_reg[2] 
       (.C(s_axi_aclk),
        .CE(\FSM_sequential_axi_write_cs[2]_i_1_n_0 ),
        .D(axi_write_ns__0[2]),
        .Q(axi_write_cs[2]),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'hD0DDD00000000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_2_n_0 ),
        .I1(ARREADY_i_reg_1),
        .I2(\AHB_MSTR_IF_MODULE/p_2_in [0]),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_4_n_0 ),
        .I4(m_ahb_haddr[0]),
        .I5(s_axi_aresetn),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[0] ));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'h14)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_2 
       (.I0(Q[2]),
        .I1(Q[0]),
        .I2(Q[1]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hB8B8B8B8B88888B8)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_3 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_4_n_0 ),
        .I1(ARREADY_i_reg_1),
        .I2(\axi_address_reg[9]_0 [0]),
        .I3(Q[1]),
        .I4(Q[0]),
        .I5(Q[2]),
        .O(\AHB_MSTR_IF_MODULE/p_2_in [0]));
  LUT5 #(
    .INIT(32'hFFD0008F)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_4 
       (.I0(\axi_length_reg[3]_0 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 [0]),
        .I2(Q[0]),
        .I3(Q[1]),
        .I4(m_ahb_haddr[0]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[0]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFF2EFFFFFF2E0000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[10]_i_1 
       (.I0(m_ahb_haddr[10]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[10] ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[10]_i_3_n_0 ),
        .I4(ARREADY_i_reg_1),
        .I5(axi_address[10]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [4]));
  LUT5 #(
    .INIT(32'hE0000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[10]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(Q[1]),
        .I3(\axi_length_reg[3]_2 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11]_0 [1]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF2EFFFFFF2E0000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_1 
       (.I0(m_ahb_haddr[11]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11] ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_3_n_0 ),
        .I4(ARREADY_i_reg_1),
        .I5(axi_address[11]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [5]));
  LUT5 #(
    .INIT(32'hE0000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(Q[1]),
        .I3(\axi_length_reg[3]_2 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11]_0 [2]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_4 
       (.I0(ARREADY_i_reg_0),
        .I1(AWREADY_i_reg_0),
        .O(ARREADY_i_reg_1));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[11]_i_5 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[7]_0 [1]),
        .I2(\axi_length_reg[7]_0 [0]),
        .I3(wrap_in_progress),
        .I4(\axi_length_reg[7]_0 [2]),
        .O(\axi_length_reg[3]_2 ));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[12]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[12] ),
        .I1(axi_address[12]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[12]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [6]));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[13]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[13] ),
        .I1(axi_address[13]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[13]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [7]));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[14]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[14] ),
        .I1(axi_address[14]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[14]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [8]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[15]_i_1 
       (.I0(m_ahb_haddr[15]),
        .I1(axi_address[15]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[15] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [9]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[16]_i_1 
       (.I0(m_ahb_haddr[16]),
        .I1(axi_address[16]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[16] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [10]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[17]_i_1 
       (.I0(m_ahb_haddr[17]),
        .I1(axi_address[17]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[17] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [11]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[18]_i_1 
       (.I0(m_ahb_haddr[18]),
        .I1(axi_address[18]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[18] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [12]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[19]_i_1 
       (.I0(m_ahb_haddr[19]),
        .I1(axi_address[19]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[19] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [13]));
  LUT6 #(
    .INIT(64'hD0DDD00000000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_2_n_0 ),
        .I1(ARREADY_i_reg_1),
        .I2(\AHB_MSTR_IF_MODULE/p_2_in [1]),
        .I3(\AHB_MSTR_IF_MODULE/p_1_in ),
        .I4(m_ahb_haddr[1]),
        .I5(s_axi_aresetn),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1] ));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_2 
       (.I0(Q[2]),
        .I1(Q[1]),
        .I2(Q[0]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAEAEAEAE0000AE00)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_3 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_5_n_0 ),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_6_n_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[1]_0 ),
        .I3(\axi_address_reg[9]_0 [1]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_2_n_0 ),
        .I5(ARREADY_i_reg_1),
        .O(\AHB_MSTR_IF_MODULE/p_2_in [1]));
  LUT6 #(
    .INIT(64'hAAAAAAAAAAAAAAA2)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_4 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_4_n_0 ),
        .I1(ARREADY_i_reg_1),
        .I2(Q[0]),
        .I3(Q[1]),
        .I4(\axi_length_reg[7]_0 [1]),
        .I5(\axi_length_reg[2]_0 ),
        .O(\AHB_MSTR_IF_MODULE/p_1_in ));
  LUT6 #(
    .INIT(64'hFFFFFFFF08000B00)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_5 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 [1]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(m_ahb_haddr[1]),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_8_n_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_6 
       (.I0(Q[1]),
        .I1(Q[0]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF8A80)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_8 
       (.I0(Q[1]),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 [0]),
        .I2(\axi_length_reg[3]_0 ),
        .I3(m_ahb_haddr[1]),
        .I4(AWREADY_i_reg_0),
        .I5(ARREADY_i_reg_0),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[20]_i_1 
       (.I0(m_ahb_haddr[20]),
        .I1(axi_address[20]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[20] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [14]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[21]_i_1 
       (.I0(m_ahb_haddr[21]),
        .I1(axi_address[21]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[21] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [15]));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[22]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[22] ),
        .I1(axi_address[22]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[22]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [16]));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[23]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[23] ),
        .I1(axi_address[23]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[23]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [17]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[24]_i_1 
       (.I0(m_ahb_haddr[24]),
        .I1(axi_address[24]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[24] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [18]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[25]_i_1 
       (.I0(m_ahb_haddr[25]),
        .I1(axi_address[25]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[25] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [19]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[26]_i_1 
       (.I0(m_ahb_haddr[26]),
        .I1(axi_address[26]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[26] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [20]));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[27]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[27] ),
        .I1(axi_address[27]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[27]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [21]));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[28]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[28] ),
        .I1(axi_address[28]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[28]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [22]));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[29]_i_1 
       (.I0(m_ahb_haddr[29]),
        .I1(axi_address[29]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[29] ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [23]));
  LUT6 #(
    .INIT(64'hCCCCCCAFCCCCCCA0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[2] ),
        .I1(\axi_address_reg[9]_0 [2]),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_3_n_0 ),
        .I3(AWREADY_i_reg_0),
        .I4(ARREADY_i_reg_0),
        .I5(m_ahb_haddr[2]),
        .O(\axi_address_reg[2]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'h00AAA888)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_3 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] ),
        .I1(\axi_length_reg[2]_0 ),
        .I2(\axi_length_reg[7]_0 [1]),
        .I3(Q[0]),
        .I4(Q[1]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hDDD5DDD5CCCFCCC0)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[30]_i_1 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[30] ),
        .I1(axi_address[30]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(m_ahb_haddr[30]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [24]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT4 #(
    .INIT(16'hFE00)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_1 
       (.I0(ARREADY_i_reg_0),
        .I1(AWREADY_i_reg_0),
        .I2(\axi_length_reg[3]_0 ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_4_n_0 ),
        .O(ARREADY_i_reg_2));
  LUT6 #(
    .INIT(64'hCCC0CCCAFFFFCCCA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_2 
       (.I0(m_ahb_haddr[31]),
        .I1(axi_address[31]),
        .I2(AWREADY_i_reg_0),
        .I3(ARREADY_i_reg_0),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31]_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [25]));
  LUT5 #(
    .INIT(32'h3FFFAFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[7]_0 [1]),
        .I2(\axi_length_reg[7]_0 [0]),
        .I3(wrap_in_progress),
        .I4(\axi_length_reg[7]_0 [2]),
        .O(\axi_length_reg[3]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT5 #(
    .INIT(32'hFFFFFF70)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_4 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] ),
        .I3(AWREADY_i_reg_0),
        .I4(ARREADY_i_reg_0),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hFFFF000100FF1111)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(\axi_length_reg[7]_0 [1]),
        .I3(\axi_length_reg[2]_0 ),
        .I4(Q[0]),
        .I5(Q[1]),
        .O(\axi_length_reg[3]_1 ));
  LUT6 #(
    .INIT(64'hFFFF04FF04FF04FF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_6 
       (.I0(\axi_length_reg[7]_0 [1]),
        .I1(m_ahb_haddr[3]),
        .I2(\axi_length_reg[2]_0 ),
        .I3(Q[1]),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 [1]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\axi_length_reg[1]_1 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'hFFFFDDDF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_7 
       (.I0(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .I1(\M_AHB_HTRANS[1]_i_2_0 [1]),
        .I2(axi_burst[0]),
        .I3(axi_burst[1]),
        .I4(Q[2]),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[0]_0 ));
  LUT6 #(
    .INIT(64'hFEFEFEFEEEEEFFEE)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[3]_i_8 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_0 [0]),
        .I3(m_ahb_haddr[3]),
        .I4(\axi_length_reg[7]_0 [3]),
        .I5(\axi_length_reg[3]_0 ),
        .O(\axi_size_reg[1]_0 ));
  LUT6 #(
    .INIT(64'hCFFF8A8ACF008A8A)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_1 
       (.I0(\axi_address_reg[9]_0 [4]),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_n_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_1 ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_4_n_0 ),
        .I4(ARREADY_i_reg_1),
        .I5(m_ahb_haddr[4]),
        .O(\axi_address_reg[4]_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFA000E040)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2 
       (.I0(\axi_length_reg[3]_0 ),
        .I1(m_ahb_haddr[4]),
        .I2(\axi_size_reg[0]_0 ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4]_0 [2]),
        .I4(\axi_length_reg[7]_0 [3]),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6_n_0 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h22AA208822AA2000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_4 
       (.I0(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[4] ),
        .I1(Q[0]),
        .I2(\axi_length_reg[2]_0 ),
        .I3(Q[1]),
        .I4(\axi_length_reg[3]_0 ),
        .I5(\axi_length_reg[7]_0 [3]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_5 
       (.I0(Q[0]),
        .I1(Q[1]),
        .O(\axi_size_reg[0]_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFE040FFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6 
       (.I0(\axi_length_reg[3]_0 ),
        .I1(m_ahb_haddr[4]),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[1]_i_6_n_0 ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_0 [1]),
        .I4(ARREADY_i_reg_1),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_2_1 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[4]_i_7 
       (.I0(\axi_length_reg[7]_0 [2]),
        .I1(wrap_in_progress),
        .I2(\axi_length_reg[7]_0 [0]),
        .I3(\axi_length_reg[7]_0 [1]),
        .O(\axi_length_reg[2]_1 ));
  LUT6 #(
    .INIT(64'hBBBFBFBF88808080)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_1 
       (.I0(\AHB_MSTR_IF_MODULE/p_2_in [5]),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[31]_i_4_n_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_3_n_0 ),
        .I3(\axi_length_reg[7]_0 [3]),
        .I4(Q[1]),
        .I5(m_ahb_haddr[5]),
        .O(\axi_length_reg[3]_4 ));
  LUT6 #(
    .INIT(64'hFACACACACACACACA)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_2 
       (.I0(\axi_address_reg[9]_0 [5]),
        .I1(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[5] ),
        .I2(ARREADY_i_reg_1),
        .I3(Q[1]),
        .I4(\axi_length_reg[2]_0 ),
        .I5(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_6_n_0 ),
        .O(\AHB_MSTR_IF_MODULE/p_2_in [5]));
  LUT6 #(
    .INIT(64'h7FFF3FBFFFFFFFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_3 
       (.I0(\axi_length_reg[7]_0 [2]),
        .I1(wrap_in_progress),
        .I2(\axi_length_reg[7]_0 [0]),
        .I3(\axi_length_reg[7]_0 [1]),
        .I4(\axi_length_reg[7]_0 [3]),
        .I5(ARREADY_i_reg_1),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT4 #(
    .INIT(16'hEFFF)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_5 
       (.I0(\axi_length_reg[7]_0 [2]),
        .I1(\axi_length_reg[7]_0 [3]),
        .I2(\axi_length_reg[7]_0 [0]),
        .I3(wrap_in_progress),
        .O(\axi_length_reg[2]_0 ));
  LUT5 #(
    .INIT(32'h0202FF00)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_6 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(m_ahb_haddr[5]),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_2_0 ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 [2]),
        .I4(\axi_length_reg[2]_1 ),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[5]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hFF2EFFFFFF2E0000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[6]_i_1 
       (.I0(m_ahb_haddr[6]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[6] ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[6]_i_3_n_0 ),
        .I4(ARREADY_i_reg_1),
        .I5(\axi_address_reg[9]_0 [6]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [0]));
  LUT5 #(
    .INIT(32'hE0000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[6]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(Q[1]),
        .I3(\axi_length_reg[3]_2 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 [3]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF2EFFFFFF2E0000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_1 
       (.I0(m_ahb_haddr[7]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[7] ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_3_n_0 ),
        .I4(ARREADY_i_reg_1),
        .I5(\axi_address_reg[9]_0 [7]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [1]));
  LUT5 #(
    .INIT(32'hE0000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(Q[1]),
        .I3(\axi_length_reg[3]_2 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 [4]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF2EFFFFFF2E0000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_1 
       (.I0(m_ahb_haddr[8]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8] ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_3_n_0 ),
        .I4(ARREADY_i_reg_1),
        .I5(\axi_address_reg[9]_0 [8]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [2]));
  LUT5 #(
    .INIT(32'hE0000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(Q[1]),
        .I3(\axi_length_reg[3]_2 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[8]_0 [5]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFF2EFFFFFF2E0000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[9]_i_1 
       (.I0(m_ahb_haddr[9]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[9] ),
        .I3(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[9]_i_3_n_0 ),
        .I4(ARREADY_i_reg_1),
        .I5(\axi_address_reg[9]_0 [9]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[31] [3]));
  LUT5 #(
    .INIT(32'hE0000000)) 
    \GEN_32_DATA_WIDTH_NARROW.HADDR_i[9]_i_3 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[3]_0 ),
        .I2(Q[1]),
        .I3(\axi_length_reg[3]_2 ),
        .I4(\GEN_32_DATA_WIDTH_NARROW.HADDR_i_reg[11]_0 [0]),
        .O(\GEN_32_DATA_WIDTH_NARROW.HADDR_i[9]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h00700000)) 
    \HBURST_i[0]_i_1 
       (.I0(\HBURST_i[0]_i_2_n_0 ),
        .I1(\HBURST_i[0]_i_3_n_0 ),
        .I2(s_axi_aresetn),
        .I3(axi_burst[1]),
        .I4(axi_burst[0]),
        .O(s_axi_aresetn_0));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \HBURST_i[0]_i_2 
       (.I0(\axi_length_reg[7]_0 [2]),
        .I1(\axi_length_reg[7]_0 [3]),
        .I2(\axi_length_reg[7]_0 [0]),
        .I3(\axi_length_reg[7]_0 [1]),
        .O(\HBURST_i[0]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \HBURST_i[0]_i_3 
       (.I0(\axi_length_reg[7]_0 [4]),
        .I1(\axi_length_reg[7]_0 [5]),
        .I2(\axi_length_reg[7]_0 [7]),
        .I3(\axi_length_reg[7]_0 [6]),
        .O(\HBURST_i[0]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'h82)) 
    \HBURST_i[1]_i_1 
       (.I0(\HBURST_i[1]_i_2_n_0 ),
        .I1(\axi_length_reg[7]_0 [2]),
        .I2(\axi_length_reg[7]_0 [3]),
        .O(ahb_burst[0]));
  LUT5 #(
    .INIT(32'h00004446)) 
    \HBURST_i[1]_i_2 
       (.I0(axi_burst[0]),
        .I1(axi_burst[1]),
        .I2(O),
        .I3(CO),
        .I4(\HBURST_i[2]_i_2_n_0 ),
        .O(\HBURST_i[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000000222220000)) 
    \HBURST_i[2]_i_1 
       (.I0(\axi_length_reg[7]_0 [2]),
        .I1(\HBURST_i[2]_i_2_n_0 ),
        .I2(CO),
        .I3(O),
        .I4(axi_burst[1]),
        .I5(axi_burst[0]),
        .O(ahb_burst[1]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \HBURST_i[2]_i_16 
       (.I0(\axi_length_reg[7]_0 [5]),
        .I1(Q[1]),
        .I2(\axi_length_reg[7]_0 [7]),
        .O(\axi_length_reg[5]_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \HBURST_i[2]_i_17 
       (.I0(\axi_length_reg[7]_0 [4]),
        .I1(\axi_length_reg[7]_0 [6]),
        .I2(Q[0]),
        .I3(\axi_length_reg[7]_0 [5]),
        .I4(Q[1]),
        .I5(\axi_length_reg[7]_0 [7]),
        .O(\axi_length_reg[4]_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \HBURST_i[2]_i_18 
       (.I0(\axi_length_reg[7]_0 [3]),
        .I1(\axi_length_reg[7]_0 [5]),
        .I2(Q[0]),
        .I3(\axi_length_reg[7]_0 [4]),
        .I4(Q[1]),
        .I5(\axi_length_reg[7]_0 [6]),
        .O(\axi_length_reg[3]_3 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \HBURST_i[2]_i_19 
       (.I0(\axi_length_reg[7]_0 [2]),
        .I1(\axi_length_reg[7]_0 [4]),
        .I2(Q[0]),
        .I3(\axi_length_reg[7]_0 [3]),
        .I4(Q[1]),
        .I5(\axi_length_reg[7]_0 [5]),
        .O(\axi_length_reg[2]_2 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFF7)) 
    \HBURST_i[2]_i_2 
       (.I0(\axi_length_reg[7]_0 [0]),
        .I1(\axi_length_reg[7]_0 [1]),
        .I2(\axi_length_reg[7]_0 [6]),
        .I3(\axi_length_reg[7]_0 [7]),
        .I4(\axi_length_reg[7]_0 [5]),
        .I5(\axi_length_reg[7]_0 [4]),
        .O(\HBURST_i[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \HBURST_i[2]_i_20 
       (.I0(\axi_length_reg[7]_0 [1]),
        .I1(\axi_length_reg[7]_0 [3]),
        .I2(Q[0]),
        .I3(\axi_length_reg[7]_0 [2]),
        .I4(Q[1]),
        .I5(\axi_length_reg[7]_0 [4]),
        .O(\axi_length_reg[1]_2 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \HBURST_i[2]_i_21 
       (.I0(\axi_length_reg[7]_0 [0]),
        .I1(\axi_length_reg[7]_0 [2]),
        .I2(Q[0]),
        .I3(\axi_length_reg[7]_0 [1]),
        .I4(Q[1]),
        .I5(\axi_length_reg[7]_0 [3]),
        .O(\axi_length_reg[0]_0 ));
  LUT6 #(
    .INIT(64'hAFAAEFEF05004040)) 
    \HBURST_i[2]_i_22 
       (.I0(Q[2]),
        .I1(\axi_length_reg[7]_0 [1]),
        .I2(Q[0]),
        .I3(\axi_length_reg[7]_0 [0]),
        .I4(Q[1]),
        .I5(\axi_length_reg[7]_0 [2]),
        .O(\axi_size_reg[2]_0 ));
  LUT4 #(
    .INIT(16'h0080)) 
    \HBURST_i[2]_i_5 
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(\axi_length_reg[7]_0 [7]),
        .I3(Q[2]),
        .O(\HBURST_i[2]_i_5_n_0 ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \HBURST_i_reg[2]_i_3 
       (.CI(\HBURST_i_reg[2]_i_4_n_0 ),
        .CI_TOP(1'b0),
        .CO({\NLW_HBURST_i_reg[2]_i_3_CO_UNCONNECTED [7:4],CO,\NLW_HBURST_i_reg[2]_i_3_CO_UNCONNECTED [2],\HBURST_i_reg[2]_i_3_n_6 ,\HBURST_i_reg[2]_i_3_n_7 }),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\axi_address_reg[9]_0 [9:8]}),
        .O({\NLW_HBURST_i_reg[2]_i_3_O_UNCONNECTED [7:3],O,\NLW_HBURST_i_reg[2]_i_3_O_UNCONNECTED [1:0]}),
        .S({1'b0,1'b0,1'b0,1'b0,1'b1,\HBURST_i[2]_i_5_n_0 ,\HBURST_i_reg[2] }));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY8 \HBURST_i_reg[2]_i_4 
       (.CI(1'b0),
        .CI_TOP(1'b0),
        .CO({\HBURST_i_reg[2]_i_4_n_0 ,\HBURST_i_reg[2]_i_4_n_1 ,\HBURST_i_reg[2]_i_4_n_2 ,\HBURST_i_reg[2]_i_4_n_3 ,\HBURST_i_reg[2]_i_4_n_4 ,\HBURST_i_reg[2]_i_4_n_5 ,\HBURST_i_reg[2]_i_4_n_6 ,\HBURST_i_reg[2]_i_4_n_7 }),
        .DI(\axi_address_reg[9]_0 [7:0]),
        .O(\NLW_HBURST_i_reg[2]_i_4_O_UNCONNECTED [7:0]),
        .S(S));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \HPROT_i[2]_i_1 
       (.I0(AWREADY_i_reg_0),
        .I1(ARREADY_i_reg_0),
        .O(AWREADY_i_reg_1));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT4 #(
    .INIT(16'h00E0)) 
    HWRITE_i_i_1
       (.I0(m_ahb_hwrite),
        .I1(AWREADY_i_reg_0),
        .I2(s_axi_aresetn),
        .I3(ARREADY_i_reg_0),
        .O(HWRITE_i_reg));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'h00000040)) 
    \M_AHB_HTRANS[0]_i_7 
       (.I0(\axi_length_reg[7]_0 [1]),
        .I1(wrap_in_progress),
        .I2(\axi_length_reg[7]_0 [0]),
        .I3(\axi_length_reg[7]_0 [3]),
        .I4(\axi_length_reg[7]_0 [2]),
        .O(\axi_length_reg[1]_3 ));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hF1)) 
    \M_AHB_HTRANS[1]_i_11 
       (.I0(axi_burst[1]),
        .I1(axi_burst[0]),
        .I2(\FSM_sequential_ahb_wr_rd_cs_reg[1] ),
        .O(\axi_burst_reg[1]_1 ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT4 #(
    .INIT(16'h111F)) 
    \M_AHB_HTRANS[1]_i_18 
       (.I0(axi_burst[1]),
        .I1(axi_burst[0]),
        .I2(\axi_length_reg[2]_0 ),
        .I3(\axi_length_reg[7]_0 [1]),
        .O(\axi_burst_reg[1]_0 ));
  LUT6 #(
    .INIT(64'hABABABABABABFFAB)) 
    \M_AHB_HTRANS[1]_i_19 
       (.I0(\FSM_sequential_ahb_wr_rd_cs_reg[1] ),
        .I1(axi_burst[1]),
        .I2(axi_burst[0]),
        .I3(\M_AHB_HTRANS[1]_i_14 ),
        .I4(\axi_length_reg[2]_0 ),
        .I5(\axi_length_reg[7]_0 [1]),
        .O(\axi_burst_reg[1]_2 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \M_AHB_HTRANS[1]_i_23 
       (.I0(axi_burst[0]),
        .I1(axi_burst[1]),
        .O(\axi_burst_reg[0]_0 ));
  LUT6 #(
    .INIT(64'h1110111011100000)) 
    \M_AHB_HTRANS[1]_i_24 
       (.I0(one_kb_cross),
        .I1(one_kb_in_progress),
        .I2(axi_burst[1]),
        .I3(axi_burst[0]),
        .I4(\axi_length_reg[7]_0 [1]),
        .I5(\axi_length_reg[2]_0 ),
        .O(one_kb_in_progress_reg));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'h0E)) 
    \M_AHB_HTRANS[1]_i_25 
       (.I0(axi_burst[1]),
        .I1(axi_burst[0]),
        .I2(\M_AHB_HTRANS[1]_i_14 ),
        .O(\axi_burst_reg[1]_3 ));
  LUT6 #(
    .INIT(64'h5DFF5D005DFF5DFF)) 
    \M_AHB_HTRANS[1]_i_5 
       (.I0(out),
        .I1(\M_AHB_HTRANS[1]_i_2 ),
        .I2(\axi_length_reg[1]_0 ),
        .I3(\M_AHB_HTRANS[1]_i_2_0 [2]),
        .I4(\axi_burst_reg[1]_0 ),
        .I5(\FSM_sequential_axi_write_cs_reg[0]_0 ),
        .O(sig_s_ready_out_reg));
  LUT6 #(
    .INIT(64'h000000000030A000)) 
    \M_AHB_HTRANS[1]_i_7 
       (.I0(\axi_length_reg[1]_0 ),
        .I1(\axi_burst_reg[1]_1 ),
        .I2(\FSM_sequential_axi_write_cs_reg[0]_0 ),
        .I3(\M_AHB_HTRANS[1]_i_2_0 [1]),
        .I4(\M_AHB_HTRANS[1]_i_2_0 [2]),
        .I5(\M_AHB_HTRANS[1]_i_2_1 ),
        .O(\FSM_sequential_ahb_wr_rd_cs_reg[2] ));
  FDRE \RID_i_reg[0] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[0]),
        .Q(\RID_i_reg[15]_0 [0]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[10] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[10]),
        .Q(\RID_i_reg[15]_0 [10]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[11] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[11]),
        .Q(\RID_i_reg[15]_0 [11]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[12] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[12]),
        .Q(\RID_i_reg[15]_0 [12]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[13] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[13]),
        .Q(\RID_i_reg[15]_0 [13]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[14] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[14]),
        .Q(\RID_i_reg[15]_0 [14]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[15] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[15]),
        .Q(\RID_i_reg[15]_0 [15]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[1] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[1]),
        .Q(\RID_i_reg[15]_0 [1]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[2] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[2]),
        .Q(\RID_i_reg[15]_0 [2]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[3] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[3]),
        .Q(\RID_i_reg[15]_0 [3]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[4] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[4]),
        .Q(\RID_i_reg[15]_0 [4]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[5] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[5]),
        .Q(\RID_i_reg[15]_0 [5]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[6] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[6]),
        .Q(\RID_i_reg[15]_0 [6]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[7] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[7]),
        .Q(\RID_i_reg[15]_0 [7]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[8] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[8]),
        .Q(\RID_i_reg[15]_0 [8]),
        .R(s_axi_aresetn_int));
  FDRE \RID_i_reg[9] 
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(axi_rid[9]),
        .Q(\RID_i_reg[15]_0 [9]),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'h000404000F040400)) 
    RLAST_i_i_1
       (.I0(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .I1(RLAST_i_reg_0),
        .I2(axi_read_cs[2]),
        .I3(axi_read_cs[1]),
        .I4(axi_read_cs[0]),
        .I5(out),
        .O(RLAST_sm));
  FDRE RLAST_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(RLAST_sm),
        .Q(s_axi_rlast_int),
        .R(s_axi_aresetn_int));
  FDRE RRESP_1_i_reg
       (.C(s_axi_aclk),
        .CE(E),
        .D(RRESP_1_i),
        .Q(s_axi_rresp_int),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT5 #(
    .INIT(32'h0410FFFF)) 
    RVALID_i_i_1
       (.I0(out),
        .I1(axi_read_cs[0]),
        .I2(axi_read_cs[2]),
        .I3(axi_read_cs[1]),
        .I4(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(RVALID_sm));
  FDRE RVALID_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(RVALID_sm),
        .Q(s_axi_rvalid_int),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[0]_i_1 
       (.I0(m_ahb_hrdata[0]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[10]_i_1 
       (.I0(m_ahb_hrdata[9]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[10]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[11]_i_1 
       (.I0(m_ahb_hrdata[10]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[11]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[12]_i_1 
       (.I0(m_ahb_hrdata[11]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[12]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[13]_i_1 
       (.I0(m_ahb_hrdata[12]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[13]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[14]_i_1 
       (.I0(m_ahb_hrdata[13]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[14]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[15]_i_1 
       (.I0(m_ahb_hrdata[14]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[15]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[18]_i_1 
       (.I0(m_ahb_hrdata[15]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[18]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[19]_i_1 
       (.I0(m_ahb_hrdata[16]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[19]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[20]_i_1 
       (.I0(m_ahb_hrdata[17]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[20]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[21]_i_1 
       (.I0(m_ahb_hrdata[18]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[21]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[23]_i_1 
       (.I0(m_ahb_hrdata[19]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[23]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[24]_i_1 
       (.I0(m_ahb_hrdata[20]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[24]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[25]_i_1 
       (.I0(m_ahb_hrdata[21]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[25]));
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[26]_i_1 
       (.I0(m_ahb_hrdata[22]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[26]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[27]_i_1 
       (.I0(m_ahb_hrdata[23]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[27]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[28]_i_1 
       (.I0(m_ahb_hrdata[24]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[28]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[29]_i_1 
       (.I0(m_ahb_hrdata[25]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[29]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[2]_i_1 
       (.I0(m_ahb_hrdata[1]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[31]_i_2 
       (.I0(m_ahb_hrdata[26]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[31]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[3]_i_1 
       (.I0(m_ahb_hrdata[2]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[4]_i_1 
       (.I0(m_ahb_hrdata[3]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[4]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[5]_i_1 
       (.I0(m_ahb_hrdata[4]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[6]_i_1 
       (.I0(m_ahb_hrdata[5]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[7]_i_1 
       (.I0(m_ahb_hrdata[6]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[8]_i_1 
       (.I0(m_ahb_hrdata[7]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[8]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \S_AXI_RDATA[9]_i_1 
       (.I0(m_ahb_hrdata[8]),
        .I1(\FSM_sequential_ahb_wr_rd_cs_reg[0] ),
        .O(p_2_in[9]));
  FDRE \S_AXI_RDATA_reg[0] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[0]),
        .Q(\S_AXI_RDATA_reg[31]_0 [0]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[10] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[10]),
        .Q(\S_AXI_RDATA_reg[31]_0 [10]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[11] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[11]),
        .Q(\S_AXI_RDATA_reg[31]_0 [11]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[12] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[12]),
        .Q(\S_AXI_RDATA_reg[31]_0 [12]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[13] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[13]),
        .Q(\S_AXI_RDATA_reg[31]_0 [13]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[14] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[14]),
        .Q(\S_AXI_RDATA_reg[31]_0 [14]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[15] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[15]),
        .Q(\S_AXI_RDATA_reg[31]_0 [15]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[16] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(D[1]),
        .Q(\S_AXI_RDATA_reg[31]_0 [16]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[17] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(D[2]),
        .Q(\S_AXI_RDATA_reg[31]_0 [17]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[18] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[18]),
        .Q(\S_AXI_RDATA_reg[31]_0 [18]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[19] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[19]),
        .Q(\S_AXI_RDATA_reg[31]_0 [19]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[1] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(D[0]),
        .Q(\S_AXI_RDATA_reg[31]_0 [1]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[20] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[20]),
        .Q(\S_AXI_RDATA_reg[31]_0 [20]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[21] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[21]),
        .Q(\S_AXI_RDATA_reg[31]_0 [21]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[22] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(D[3]),
        .Q(\S_AXI_RDATA_reg[31]_0 [22]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[23] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[23]),
        .Q(\S_AXI_RDATA_reg[31]_0 [23]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[24] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[24]),
        .Q(\S_AXI_RDATA_reg[31]_0 [24]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[25] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[25]),
        .Q(\S_AXI_RDATA_reg[31]_0 [25]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[26] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[26]),
        .Q(\S_AXI_RDATA_reg[31]_0 [26]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[27] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[27]),
        .Q(\S_AXI_RDATA_reg[31]_0 [27]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[28] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[28]),
        .Q(\S_AXI_RDATA_reg[31]_0 [28]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[29] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[29]),
        .Q(\S_AXI_RDATA_reg[31]_0 [29]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[2] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[2]),
        .Q(\S_AXI_RDATA_reg[31]_0 [2]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[30] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(D[4]),
        .Q(\S_AXI_RDATA_reg[31]_0 [30]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[31] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[31]),
        .Q(\S_AXI_RDATA_reg[31]_0 [31]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[3] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[3]),
        .Q(\S_AXI_RDATA_reg[31]_0 [3]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[4] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[4]),
        .Q(\S_AXI_RDATA_reg[31]_0 [4]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[5] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[5]),
        .Q(\S_AXI_RDATA_reg[31]_0 [5]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[6] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[6]),
        .Q(\S_AXI_RDATA_reg[31]_0 [6]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[7] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[7]),
        .Q(\S_AXI_RDATA_reg[31]_0 [7]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[8] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[8]),
        .Q(\S_AXI_RDATA_reg[31]_0 [8]),
        .R(s_axi_aresetn_int));
  FDRE \S_AXI_RDATA_reg[9] 
       (.C(s_axi_aclk),
        .CE(E),
        .D(p_2_in[9]),
        .Q(\S_AXI_RDATA_reg[31]_0 [9]),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'hFFFF01FF00000100)) 
    WREADY_i_i_1
       (.I0(axi_write_cs[0]),
        .I1(\axi_wdata_reg[0]_0 ),
        .I2(\FSM_sequential_axi_write_cs_reg[0]_1 ),
        .I3(axi_write_cs[2]),
        .I4(axi_write_cs[1]),
        .I5(WREADY_i_i_4_n_0),
        .O(write_ready_sm));
  LUT6 #(
    .INIT(64'hBEBA8E8A04000400)) 
    WREADY_i_i_4
       (.I0(axi_write_cs[2]),
        .I1(axi_write_cs[1]),
        .I2(axi_write_cs[0]),
        .I3(\axi_wdata_reg[0]_1 ),
        .I4(s_axi_awvalid),
        .I5(s_axi_wvalid),
        .O(WREADY_i_i_4_n_0));
  FDRE WREADY_i_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(write_ready_sm),
        .Q(s_axi_wready),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[0]_i_1 
       (.I0(s_axi_awaddr[0]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[0]),
        .O(p_1_in[0]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[10]_i_1 
       (.I0(s_axi_awaddr[10]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[10]),
        .O(p_1_in[10]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[11]_i_1 
       (.I0(s_axi_awaddr[11]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[11]),
        .O(p_1_in[11]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[12]_i_1 
       (.I0(s_axi_awaddr[12]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[12]),
        .O(p_1_in[12]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[13]_i_1 
       (.I0(s_axi_awaddr[13]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[13]),
        .O(p_1_in[13]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[14]_i_1 
       (.I0(s_axi_awaddr[14]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[14]),
        .O(p_1_in[14]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[15]_i_1 
       (.I0(s_axi_awaddr[15]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[15]),
        .O(p_1_in[15]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[16]_i_1 
       (.I0(s_axi_awaddr[16]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[16]),
        .O(p_1_in[16]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[17]_i_1 
       (.I0(s_axi_awaddr[17]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[17]),
        .O(p_1_in[17]));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[18]_i_1 
       (.I0(s_axi_awaddr[18]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[18]),
        .O(p_1_in[18]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[19]_i_1 
       (.I0(s_axi_awaddr[19]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[19]),
        .O(p_1_in[19]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[1]_i_1 
       (.I0(s_axi_awaddr[1]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[1]),
        .O(p_1_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[20]_i_1 
       (.I0(s_axi_awaddr[20]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[20]),
        .O(p_1_in[20]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[21]_i_1 
       (.I0(s_axi_awaddr[21]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[21]),
        .O(p_1_in[21]));
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[22]_i_1 
       (.I0(s_axi_awaddr[22]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[22]),
        .O(p_1_in[22]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[23]_i_1 
       (.I0(s_axi_awaddr[23]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[23]),
        .O(p_1_in[23]));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[24]_i_1 
       (.I0(s_axi_awaddr[24]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[24]),
        .O(p_1_in[24]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[25]_i_1 
       (.I0(s_axi_awaddr[25]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[25]),
        .O(p_1_in[25]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[26]_i_1 
       (.I0(s_axi_awaddr[26]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[26]),
        .O(p_1_in[26]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[27]_i_1 
       (.I0(s_axi_awaddr[27]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[27]),
        .O(p_1_in[27]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[28]_i_1 
       (.I0(s_axi_awaddr[28]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[28]),
        .O(p_1_in[28]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[29]_i_1 
       (.I0(s_axi_awaddr[29]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[29]),
        .O(p_1_in[29]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[2]_i_1 
       (.I0(s_axi_awaddr[2]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[2]),
        .O(p_1_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[30]_i_1 
       (.I0(s_axi_awaddr[30]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[30]),
        .O(p_1_in[30]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[31]_i_1 
       (.I0(s_axi_awaddr[31]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[31]),
        .O(p_1_in[31]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[3]_i_1 
       (.I0(s_axi_awaddr[3]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[3]),
        .O(p_1_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[4]_i_1 
       (.I0(s_axi_awaddr[4]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[4]),
        .O(p_1_in[4]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[5]_i_1 
       (.I0(s_axi_awaddr[5]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[5]),
        .O(p_1_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[6]_i_1 
       (.I0(s_axi_awaddr[6]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[6]),
        .O(p_1_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[7]_i_1 
       (.I0(s_axi_awaddr[7]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[7]),
        .O(p_1_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[8]_i_1 
       (.I0(s_axi_awaddr[8]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[8]),
        .O(p_1_in[8]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_address[9]_i_1 
       (.I0(s_axi_awaddr[9]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_araddr[9]),
        .O(p_1_in[9]));
  FDRE \axi_address_reg[0] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[0]),
        .Q(\axi_address_reg[9]_0 [0]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[10] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[10]),
        .Q(axi_address[10]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[11] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[11]),
        .Q(axi_address[11]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[12] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[12]),
        .Q(axi_address[12]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[13] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[13]),
        .Q(axi_address[13]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[14] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[14]),
        .Q(axi_address[14]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[15] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[15]),
        .Q(axi_address[15]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[16] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[16]),
        .Q(axi_address[16]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[17] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[17]),
        .Q(axi_address[17]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[18] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[18]),
        .Q(axi_address[18]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[19] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[19]),
        .Q(axi_address[19]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[1] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[1]),
        .Q(\axi_address_reg[9]_0 [1]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[20] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[20]),
        .Q(axi_address[20]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[21] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[21]),
        .Q(axi_address[21]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[22] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[22]),
        .Q(axi_address[22]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[23] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[23]),
        .Q(axi_address[23]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[24] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[24]),
        .Q(axi_address[24]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[25] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[25]),
        .Q(axi_address[25]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[26] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[26]),
        .Q(axi_address[26]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[27] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[27]),
        .Q(axi_address[27]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[28] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[28]),
        .Q(axi_address[28]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[29] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[29]),
        .Q(axi_address[29]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[2] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[2]),
        .Q(\axi_address_reg[9]_0 [2]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[30] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[30]),
        .Q(axi_address[30]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[31] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[31]),
        .Q(axi_address[31]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[3] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[3]),
        .Q(\axi_address_reg[9]_0 [3]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[4] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[4]),
        .Q(\axi_address_reg[9]_0 [4]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[5] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[5]),
        .Q(\axi_address_reg[9]_0 [5]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[6] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[6]),
        .Q(\axi_address_reg[9]_0 [6]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[7] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[7]),
        .Q(\axi_address_reg[9]_0 [7]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[8] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[8]),
        .Q(\axi_address_reg[9]_0 [8]),
        .R(s_axi_aresetn_int));
  FDRE \axi_address_reg[9] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(p_1_in[9]),
        .Q(\axi_address_reg[9]_0 [9]),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_burst[0]_i_1 
       (.I0(s_axi_awburst[0]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arburst[0]),
        .O(\axi_burst[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_burst[1]_i_1 
       (.I0(s_axi_awburst[1]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arburst[1]),
        .O(\axi_burst[1]_i_1_n_0 ));
  FDRE \axi_burst_reg[0] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_burst[0]_i_1_n_0 ),
        .Q(axi_burst[0]),
        .R(s_axi_aresetn_int));
  FDRE \axi_burst_reg[1] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_burst[1]_i_1_n_0 ),
        .Q(axi_burst[1]),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_cache[0]_i_1 
       (.I0(s_axi_awcache[0]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arcache[0]),
        .O(\axi_cache[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_cache[2]_i_1 
       (.I0(s_axi_awcache[1]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arcache[1]),
        .O(\axi_cache[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_cache[3]_i_1 
       (.I0(s_axi_awcache[2]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arcache[2]),
        .O(\axi_cache[3]_i_1_n_0 ));
  FDRE \axi_cache_reg[0] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_cache[0]_i_1_n_0 ),
        .Q(\axi_cache_reg[3]_0 [0]),
        .R(s_axi_aresetn_int));
  FDRE \axi_cache_reg[2] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_cache[2]_i_1_n_0 ),
        .Q(\axi_cache_reg[3]_0 [1]),
        .R(s_axi_aresetn_int));
  FDRE \axi_cache_reg[3] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_cache[3]_i_1_n_0 ),
        .Q(\axi_cache_reg[3]_0 [2]),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[0]_i_1 
       (.I0(s_axi_awlen[0]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[0]),
        .O(\axi_length[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[1]_i_1 
       (.I0(s_axi_awlen[1]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[1]),
        .O(\axi_length[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[2]_i_1 
       (.I0(s_axi_awlen[2]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[2]),
        .O(\axi_length[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[3]_i_1 
       (.I0(s_axi_awlen[3]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[3]),
        .O(\axi_length[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[4]_i_1 
       (.I0(s_axi_awlen[4]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[4]),
        .O(\axi_length[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[5]_i_1 
       (.I0(s_axi_awlen[5]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[5]),
        .O(\axi_length[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[6]_i_1 
       (.I0(s_axi_awlen[6]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[6]),
        .O(\axi_length[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_length[7]_i_1 
       (.I0(s_axi_awlen[7]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlen[7]),
        .O(\axi_length[7]_i_1_n_0 ));
  FDRE \axi_length_reg[0] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[0]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [0]),
        .R(s_axi_aresetn_int));
  FDRE \axi_length_reg[1] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[1]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [1]),
        .R(s_axi_aresetn_int));
  FDRE \axi_length_reg[2] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[2]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [2]),
        .R(s_axi_aresetn_int));
  FDRE \axi_length_reg[3] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[3]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [3]),
        .R(s_axi_aresetn_int));
  FDRE \axi_length_reg[4] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[4]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [4]),
        .R(s_axi_aresetn_int));
  FDRE \axi_length_reg[5] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[5]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [5]),
        .R(s_axi_aresetn_int));
  FDRE \axi_length_reg[6] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[6]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [6]),
        .R(s_axi_aresetn_int));
  FDRE \axi_length_reg[7] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_length[7]_i_1_n_0 ),
        .Q(\axi_length_reg[7]_0 [7]),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    axi_lock_i_1
       (.I0(s_axi_awlock),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arlock),
        .O(axi_lock_i_1_n_0));
  FDRE axi_lock_reg
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(axi_lock_i_1_n_0),
        .Q(axi_lock),
        .R(s_axi_aresetn_int));
  LUT6 #(
    .INIT(64'hAAAAAAAAAAEAAAAA)) 
    \axi_prot[0]_i_1 
       (.I0(rd_request),
        .I1(s_axi_wvalid),
        .I2(s_axi_awvalid),
        .I3(axi_write_cs[1]),
        .I4(axi_write_cs[0]),
        .I5(axi_write_cs[2]),
        .O(\axi_prot[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \axi_prot[0]_i_2 
       (.I0(s_axi_awprot[0]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arprot[0]),
        .O(\axi_prot[0]_i_2_n_0 ));
  LUT3 #(
    .INIT(8'h47)) 
    \axi_prot[2]_inv_i_1 
       (.I0(s_axi_awprot[1]),
        .I1(AWREADY_i_i_2_n_0),
        .I2(s_axi_arprot[1]),
        .O(\axi_prot[2]_inv_i_1_n_0 ));
  FDRE \axi_prot_reg[0] 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_prot[0]_i_2_n_0 ),
        .Q(\axi_prot_reg[0]_0 [1]),
        .R(s_axi_aresetn_int));
  FDSE \axi_prot_reg[2]_inv 
       (.C(s_axi_aclk),
        .CE(\axi_prot[0]_i_1_n_0 ),
        .D(\axi_prot[2]_inv_i_1_n_0 ),
        .Q(\axi_prot_reg[0]_0 [0]),
        .S(s_axi_aresetn_int));
  FDRE \axi_rid_reg[0] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[0]),
        .Q(axi_rid[0]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[10] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[10]),
        .Q(axi_rid[10]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[11] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[11]),
        .Q(axi_rid[11]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[12] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[12]),
        .Q(axi_rid[12]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[13] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[13]),
        .Q(axi_rid[13]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[14] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[14]),
        .Q(axi_rid[14]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[15] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[15]),
        .Q(axi_rid[15]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[1] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[1]),
        .Q(axi_rid[1]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[2] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[2]),
        .Q(axi_rid[2]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[3] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[3]),
        .Q(axi_rid[3]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[4] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[4]),
        .Q(axi_rid[4]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[5] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[5]),
        .Q(axi_rid[5]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[6] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[6]),
        .Q(axi_rid[6]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[7] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[7]),
        .Q(axi_rid[7]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[8] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[8]),
        .Q(axi_rid[8]),
        .R(s_axi_aresetn_int));
  FDRE \axi_rid_reg[9] 
       (.C(s_axi_aclk),
        .CE(rd_request),
        .D(s_axi_arid[9]),
        .Q(axi_rid[9]),
        .R(s_axi_aresetn_int));
  LUT5 #(
    .INIT(32'h08AA0808)) 
    \axi_size[0]_i_1 
       (.I0(s_axi_aresetn),
        .I1(\axi_size[0]_i_2_n_0 ),
        .I2(\axi_size[0]_i_3_n_0 ),
        .I3(AWREADY_i_i_2_n_0),
        .I4(s_axi_arsize[0]),
        .O(\axi_size[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hAAA8A882AAAAAAAA)) 
    \axi_size[0]_i_2 
       (.I0(AWREADY_i_i_2_n_0),
        .I1(s_axi_wstrb[0]),
        .I2(s_axi_wstrb[3]),
        .I3(s_axi_wstrb[1]),
        .I4(s_axi_wstrb[2]),
        .I5(single_axi_wr_xfer_i_2_n_0),
        .O(\axi_size[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h80000000FDFFFF7F)) 
    \axi_size[0]_i_3 
       (.I0(single_axi_wr_xfer_i_2_n_0),
        .I1(s_axi_wstrb[0]),
        .I2(s_axi_wstrb[1]),
        .I3(s_axi_wstrb[3]),
        .I4(s_axi_wstrb[2]),
        .I5(s_axi_awsize[0]),
        .O(\axi_size[0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hAA08AA08AA080808)) 
    \axi_size[1]_i_1 
       (.I0(s_axi_aresetn),
        .I1(s_axi_arsize[1]),
        .I2(AWREADY_i_i_2_n_0),
        .I3(\axi_size[2]_i_3_n_0 ),
        .I4(\axi_size[2]_i_4_n_0 ),
        .I5(s_axi_awsize[1]),
        .O(\axi_size[1]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hB)) 
    \axi_size[2]_i_1 
       (.I0(\axi_prot[0]_i_1_n_0 ),
        .I1(s_axi_aresetn),
        .O(\axi_size[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0080AAAA00800080)) 
    \axi_size[2]_i_2 
       (.I0(s_axi_aresetn),
        .I1(\axi_size[2]_i_3_n_0 ),
        .I2(s_axi_awsize[2]),
        .I3(\axi_size[2]_i_4_n_0 ),
        .I4(AWREADY_i_i_2_n_0),
        .I5(s_axi_arsize[2]),
        .O(\axi_size[2]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hA8A8A802AAAAAAAA)) 
    \axi_size[2]_i_3 
       (.I0(AWREADY_i_i_2_n_0),
        .I1(s_axi_wstrb[2]),
        .I2(s_axi_wstrb[3]),
        .I3(s_axi_wstrb[1]),
        .I4(s_axi_wstrb[0]),
        .I5(single_axi_wr_xfer_i_2_n_0),
        .O(\axi_size[2]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \axi_size[2]_i_4 
       (.I0(single_axi_wr_xfer_i_2_n_0),
        .I1(s_axi_wstrb[2]),
        .I2(s_axi_wstrb[3]),
        .I3(s_axi_wstrb[1]),
        .I4(s_axi_wstrb[0]),
        .O(\axi_size[2]_i_4_n_0 ));
  FDRE \axi_size_reg[0] 
       (.C(s_axi_aclk),
        .CE(\axi_size[2]_i_1_n_0 ),
        .D(\axi_size[0]_i_1_n_0 ),
        .Q(Q[0]),
        .R(1'b0));
  FDRE \axi_size_reg[1] 
       (.C(s_axi_aclk),
        .CE(\axi_size[2]_i_1_n_0 ),
        .D(\axi_size[1]_i_1_n_0 ),
        .Q(Q[1]),
        .R(1'b0));
  FDRE \axi_size_reg[2] 
       (.C(s_axi_aclk),
        .CE(\axi_size[2]_i_1_n_0 ),
        .D(\axi_size[2]_i_2_n_0 ),
        .Q(Q[2]),
        .R(1'b0));
  FDRE \axi_wdata_reg[0] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[0]),
        .Q(\axi_wdata_reg[31]_0 [0]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[10] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[10]),
        .Q(\axi_wdata_reg[31]_0 [10]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[11] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[11]),
        .Q(\axi_wdata_reg[31]_0 [11]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[12] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[12]),
        .Q(\axi_wdata_reg[31]_0 [12]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[13] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[13]),
        .Q(\axi_wdata_reg[31]_0 [13]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[14] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[14]),
        .Q(\axi_wdata_reg[31]_0 [14]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[15] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[15]),
        .Q(\axi_wdata_reg[31]_0 [15]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[16] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[16]),
        .Q(\axi_wdata_reg[31]_0 [16]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[17] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[17]),
        .Q(\axi_wdata_reg[31]_0 [17]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[18] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[18]),
        .Q(\axi_wdata_reg[31]_0 [18]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[19] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[19]),
        .Q(\axi_wdata_reg[31]_0 [19]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[1] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[1]),
        .Q(\axi_wdata_reg[31]_0 [1]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[20] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[20]),
        .Q(\axi_wdata_reg[31]_0 [20]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[21] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[21]),
        .Q(\axi_wdata_reg[31]_0 [21]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[22] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[22]),
        .Q(\axi_wdata_reg[31]_0 [22]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[23] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[23]),
        .Q(\axi_wdata_reg[31]_0 [23]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[24] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[24]),
        .Q(\axi_wdata_reg[31]_0 [24]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[25] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[25]),
        .Q(\axi_wdata_reg[31]_0 [25]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[26] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[26]),
        .Q(\axi_wdata_reg[31]_0 [26]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[27] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[27]),
        .Q(\axi_wdata_reg[31]_0 [27]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[28] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[28]),
        .Q(\axi_wdata_reg[31]_0 [28]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[29] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[29]),
        .Q(\axi_wdata_reg[31]_0 [29]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[2] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[2]),
        .Q(\axi_wdata_reg[31]_0 [2]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[30] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[30]),
        .Q(\axi_wdata_reg[31]_0 [30]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[31] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[31]),
        .Q(\axi_wdata_reg[31]_0 [31]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[3] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[3]),
        .Q(\axi_wdata_reg[31]_0 [3]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[4] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[4]),
        .Q(\axi_wdata_reg[31]_0 [4]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[5] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[5]),
        .Q(\axi_wdata_reg[31]_0 [5]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[6] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[6]),
        .Q(\axi_wdata_reg[31]_0 [6]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[7] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[7]),
        .Q(\axi_wdata_reg[31]_0 [7]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[8] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[8]),
        .Q(\axi_wdata_reg[31]_0 [8]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wdata_reg[9] 
       (.C(s_axi_aclk),
        .CE(write_ready_sm),
        .D(s_axi_wdata[9]),
        .Q(\axi_wdata_reg[31]_0 [9]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[0] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[0]),
        .Q(axi_wid[0]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[10] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[10]),
        .Q(axi_wid[10]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[11] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[11]),
        .Q(axi_wid[11]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[12] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[12]),
        .Q(axi_wid[12]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[13] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[13]),
        .Q(axi_wid[13]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[14] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[14]),
        .Q(axi_wid[14]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[15] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[15]),
        .Q(axi_wid[15]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[1] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[1]),
        .Q(axi_wid[1]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[2] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[2]),
        .Q(axi_wid[2]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[3] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[3]),
        .Q(axi_wid[3]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[4] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[4]),
        .Q(axi_wid[4]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[5] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[5]),
        .Q(axi_wid[5]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[6] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[6]),
        .Q(axi_wid[6]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[7] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[7]),
        .Q(axi_wid[7]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[8] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[8]),
        .Q(axi_wid[8]),
        .R(s_axi_aresetn_int));
  FDRE \axi_wid_reg[9] 
       (.C(s_axi_aclk),
        .CE(AWREADY_i_i_2_n_0),
        .D(s_axi_awid[9]),
        .Q(axi_wid[9]),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT5 #(
    .INIT(32'hA0A2A2A2)) 
    load_counter_i_1
       (.I0(load_counter_reg),
        .I1(single_ahb_rd_xfer),
        .I2(AWREADY_i_reg_0),
        .I3(axi_burst[0]),
        .I4(axi_burst[1]),
        .O(load_counter_sm));
  LUT3 #(
    .INIT(8'hEA)) 
    read_in_progress_i_1
       (.I0(rd_request),
        .I1(single_axi_rd_xfer_i_2_n_0),
        .I2(read_in_progress),
        .O(read_in_progress_i_1_n_0));
  FDRE read_in_progress_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(read_in_progress_i_1_n_0),
        .Q(read_in_progress),
        .R(s_axi_aresetn_int));
  LUT3 #(
    .INIT(8'hB8)) 
    single_ahb_wr_i_1
       (.I0(single_ahb_wr_xfer),
        .I1(AWREADY_i_reg_0),
        .I2(single_ahb_wr),
        .O(single_axi_wr_xfer_reg_0));
  LUT4 #(
    .INIT(16'hE000)) 
    single_axi_rd_xfer_i_1
       (.I0(single_axi_rd_xfer_i_2_n_0),
        .I1(s_axi_arvalid),
        .I2(single_axi_rd_xfer_i_3_n_0),
        .I3(s_axi_aresetn),
        .O(single_axi_rd_xfer_i_1_n_0));
  LUT6 #(
    .INIT(64'hFFBFFFBFFF83FFBF)) 
    single_axi_rd_xfer_i_2
       (.I0(out),
        .I1(axi_read_cs[0]),
        .I2(axi_read_cs[1]),
        .I3(axi_read_cs[2]),
        .I4(RLAST_i_reg_0),
        .I5(\M_AHB_HTRANS[1]_i_2_0 [0]),
        .O(single_axi_rd_xfer_i_2_n_0));
  LUT6 #(
    .INIT(64'h0001FFFF00010000)) 
    single_axi_rd_xfer_i_3
       (.I0(s_axi_arburst[1]),
        .I1(s_axi_arlen[5]),
        .I2(s_axi_arlen[7]),
        .I3(single_axi_rd_xfer_i_4_n_0),
        .I4(s_axi_arvalid),
        .I5(single_ahb_rd_xfer),
        .O(single_axi_rd_xfer_i_3_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    single_axi_rd_xfer_i_4
       (.I0(s_axi_arlen[3]),
        .I1(s_axi_arlen[6]),
        .I2(s_axi_arlen[1]),
        .I3(s_axi_arlen[2]),
        .I4(s_axi_arlen[4]),
        .I5(s_axi_arlen[0]),
        .O(single_axi_rd_xfer_i_4_n_0));
  FDRE single_axi_rd_xfer_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(single_axi_rd_xfer_i_1_n_0),
        .Q(single_ahb_rd_xfer),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h0C550C0000000000)) 
    single_axi_wr_xfer_i_1
       (.I0(BVALID_sm),
        .I1(single_axi_wr_xfer_i_2_n_0),
        .I2(s_axi_awburst[1]),
        .I3(s_axi_awvalid),
        .I4(single_ahb_wr_xfer),
        .I5(s_axi_aresetn),
        .O(single_axi_wr_xfer_i_1_n_0));
  LUT5 #(
    .INIT(32'h00000001)) 
    single_axi_wr_xfer_i_2
       (.I0(s_axi_awlen[1]),
        .I1(s_axi_awlen[4]),
        .I2(s_axi_awlen[2]),
        .I3(s_axi_awlen[5]),
        .I4(single_axi_wr_xfer_i_3_n_0),
        .O(single_axi_wr_xfer_i_2_n_0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    single_axi_wr_xfer_i_3
       (.I0(s_axi_awlen[3]),
        .I1(s_axi_awlen[0]),
        .I2(s_axi_awlen[7]),
        .I3(s_axi_awlen[6]),
        .O(single_axi_wr_xfer_i_3_n_0));
  FDRE single_axi_wr_xfer_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(single_axi_wr_xfer_i_1_n_0),
        .Q(single_ahb_wr_xfer),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFFFFF7FFFFFF0000)) 
    wr_err_occured_i_1
       (.I0(axi_write_cs[2]),
        .I1(s_axi_bready),
        .I2(axi_write_cs[1]),
        .I3(axi_write_cs[0]),
        .I4(wr_err_occured0),
        .I5(s_axi_bresp),
        .O(wr_err_occured_i_1_n_0));
  FDRE wr_err_occured_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(wr_err_occured_i_1_n_0),
        .Q(s_axi_bresp),
        .R(s_axi_aresetn_int));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT5 #(
    .INIT(32'h00008A00)) 
    wrap_in_progress_i_2
       (.I0(load_counter_reg),
        .I1(AWREADY_i_reg_0),
        .I2(single_ahb_rd_xfer),
        .I3(axi_burst[1]),
        .I4(axi_burst[0]),
        .O(send_wrap_burst));
  LUT6 #(
    .INIT(64'hFF3FFFFF00220022)) 
    write_in_progress_i_1
       (.I0(write_in_progress_i_2_n_0),
        .I1(axi_write_cs[2]),
        .I2(s_axi_bready),
        .I3(axi_write_cs[1]),
        .I4(axi_write_cs[0]),
        .I5(write_in_progress),
        .O(write_in_progress_i_1_n_0));
  LUT6 #(
    .INIT(64'h000E000E0000000E)) 
    write_in_progress_i_2
       (.I0(s_axi_wvalid),
        .I1(s_axi_awvalid),
        .I2(read_in_progress),
        .I3(axi_write_cs[0]),
        .I4(s_axi_arvalid),
        .I5(write_pending),
        .O(write_in_progress_i_2_n_0));
  FDRE write_in_progress_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(write_in_progress_i_1_n_0),
        .Q(write_in_progress),
        .R(s_axi_aresetn_int));
  LUT3 #(
    .INIT(8'hBA)) 
    write_pending_i_1
       (.I0(write_waiting),
        .I1(BVALID_sm),
        .I2(write_pending),
        .O(write_pending_i_1_n_0));
  LUT6 #(
    .INIT(64'h00E0000000000000)) 
    write_pending_i_2
       (.I0(s_axi_wvalid),
        .I1(s_axi_awvalid),
        .I2(axi_read_cs[0]),
        .I3(axi_read_cs[2]),
        .I4(axi_read_cs[1]),
        .I5(out),
        .O(write_waiting));
  FDRE write_pending_reg
       (.C(s_axi_aclk),
        .CE(1'b1),
        .D(write_pending_i_1_n_0),
        .Q(write_pending),
        .R(s_axi_aresetn_int));
endmodule

(* CHECK_LICENSE_TYPE = "zynqmpsoc_axi_ahblite_bridge_0_0,axi_ahblite_bridge,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "axi_ahblite_bridge,Vivado 2019.2.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (s_axi_aclk,
    s_axi_aresetn,
    s_axi_awid,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awcache,
    s_axi_awaddr,
    s_axi_awprot,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_awlock,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bid,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_arid,
    s_axi_araddr,
    s_axi_arprot,
    s_axi_arcache,
    s_axi_arvalid,
    s_axi_arlen,
    s_axi_arsize,
    s_axi_arburst,
    s_axi_arlock,
    s_axi_arready,
    s_axi_rid,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_rlast,
    s_axi_rready,
    m_ahb_haddr,
    m_ahb_hwrite,
    m_ahb_hsize,
    m_ahb_hburst,
    m_ahb_hprot,
    m_ahb_htrans,
    m_ahb_hmastlock,
    m_ahb_hwdata,
    m_ahb_hready,
    m_ahb_hrdata,
    m_ahb_hresp);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 ACLK CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF AXI4:M_AHB, ASSOCIATED_RESET s_axi_aresetn, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input s_axi_aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 ARESETN RST" *) (* x_interface_parameter = "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_axi_aresetn;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWID" *) (* x_interface_parameter = "XIL_INTERFACENAME AXI4, BD_ATTRIBUTE.TYPE INTERIOR, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 16, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 256, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [15:0]s_axi_awid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWLEN" *) input [7:0]s_axi_awlen;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWSIZE" *) input [2:0]s_axi_awsize;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWBURST" *) input [1:0]s_axi_awburst;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWCACHE" *) input [3:0]s_axi_awcache;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWADDR" *) input [31:0]s_axi_awaddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWPROT" *) input [2:0]s_axi_awprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWVALID" *) input s_axi_awvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWREADY" *) output s_axi_awready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 AWLOCK" *) input s_axi_awlock;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 WDATA" *) input [31:0]s_axi_wdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 WSTRB" *) input [3:0]s_axi_wstrb;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 WLAST" *) input s_axi_wlast;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 WVALID" *) input s_axi_wvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 WREADY" *) output s_axi_wready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 BID" *) output [15:0]s_axi_bid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 BRESP" *) output [1:0]s_axi_bresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 BVALID" *) output s_axi_bvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 BREADY" *) input s_axi_bready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARID" *) input [15:0]s_axi_arid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARADDR" *) input [31:0]s_axi_araddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARPROT" *) input [2:0]s_axi_arprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARCACHE" *) input [3:0]s_axi_arcache;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARVALID" *) input s_axi_arvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARLEN" *) input [7:0]s_axi_arlen;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARSIZE" *) input [2:0]s_axi_arsize;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARBURST" *) input [1:0]s_axi_arburst;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARLOCK" *) input s_axi_arlock;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 ARREADY" *) output s_axi_arready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 RID" *) output [15:0]s_axi_rid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 RDATA" *) output [31:0]s_axi_rdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 RRESP" *) output [1:0]s_axi_rresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 RVALID" *) output s_axi_rvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 RLAST" *) output s_axi_rlast;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 AXI4 RREADY" *) input s_axi_rready;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HADDR" *) output [31:0]m_ahb_haddr;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HWRITE" *) output m_ahb_hwrite;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HSIZE" *) output [2:0]m_ahb_hsize;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HBURST" *) output [2:0]m_ahb_hburst;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HPROT" *) output [3:0]m_ahb_hprot;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HTRANS" *) output [1:0]m_ahb_htrans;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HMASTLOCK" *) output m_ahb_hmastlock;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HWDATA" *) output [31:0]m_ahb_hwdata;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HREADY" *) input m_ahb_hready;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HRDATA" *) input [31:0]m_ahb_hrdata;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 M_AHB HRESP" *) input m_ahb_hresp;

  wire [31:0]m_ahb_haddr;
  wire [2:0]m_ahb_hburst;
  wire m_ahb_hmastlock;
  wire [3:0]m_ahb_hprot;
  wire [31:0]m_ahb_hrdata;
  wire m_ahb_hready;
  wire m_ahb_hresp;
  wire [2:0]m_ahb_hsize;
  wire [1:0]m_ahb_htrans;
  wire [31:0]m_ahb_hwdata;
  wire m_ahb_hwrite;
  wire s_axi_aclk;
  wire [31:0]s_axi_araddr;
  wire [1:0]s_axi_arburst;
  wire [3:0]s_axi_arcache;
  wire s_axi_aresetn;
  wire [15:0]s_axi_arid;
  wire [7:0]s_axi_arlen;
  wire s_axi_arlock;
  wire [2:0]s_axi_arprot;
  wire s_axi_arready;
  wire [2:0]s_axi_arsize;
  wire s_axi_arvalid;
  wire [31:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [15:0]s_axi_awid;
  wire [7:0]s_axi_awlen;
  wire s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire s_axi_awready;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire [15:0]s_axi_bid;
  wire s_axi_bready;
  wire [1:0]s_axi_bresp;
  wire s_axi_bvalid;
  wire [31:0]s_axi_rdata;
  wire [15:0]s_axi_rid;
  wire s_axi_rlast;
  wire s_axi_rready;
  wire [1:0]s_axi_rresp;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wlast;
  wire s_axi_wready;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;

  (* C_DPHASE_TIMEOUT = "0" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_INSTANCE = "zynqmpsoc_axi_ahblite_bridge_0_0" *) 
  (* C_M_AHB_ADDR_WIDTH = "32" *) 
  (* C_M_AHB_DATA_WIDTH = "32" *) 
  (* C_S_AXI_ADDR_WIDTH = "32" *) 
  (* C_S_AXI_DATA_WIDTH = "32" *) 
  (* C_S_AXI_ID_WIDTH = "16" *) 
  (* C_S_AXI_SUPPORTS_NARROW_BURST = "1" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_ahblite_bridge U0
       (.m_ahb_haddr(m_ahb_haddr),
        .m_ahb_hburst(m_ahb_hburst),
        .m_ahb_hmastlock(m_ahb_hmastlock),
        .m_ahb_hprot(m_ahb_hprot),
        .m_ahb_hrdata(m_ahb_hrdata),
        .m_ahb_hready(m_ahb_hready),
        .m_ahb_hresp(m_ahb_hresp),
        .m_ahb_hsize(m_ahb_hsize),
        .m_ahb_htrans(m_ahb_htrans),
        .m_ahb_hwdata(m_ahb_hwdata),
        .m_ahb_hwrite(m_ahb_hwrite),
        .s_axi_aclk(s_axi_aclk),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arcache(s_axi_arcache),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_arid(s_axi_arid),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arlock(s_axi_arlock),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arready(s_axi_arready),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awid(s_axi_awid),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awready(s_axi_awready),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(s_axi_bid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rid(s_axi_rid),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid));
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
