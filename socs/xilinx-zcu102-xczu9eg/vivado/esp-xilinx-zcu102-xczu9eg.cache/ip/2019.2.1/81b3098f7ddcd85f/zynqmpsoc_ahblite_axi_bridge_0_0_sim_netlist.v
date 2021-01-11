// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
// Date        : Mon Jan 11 12:09:39 2021
// Host        : skie running 64-bit Ubuntu 18.04.5 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ zynqmpsoc_ahblite_axi_bridge_0_0_sim_netlist.v
// Design      : zynqmpsoc_ahblite_axi_bridge_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_data_counter
   (s_ahb_htrans_0_sp_1,
    Q,
    s_ahb_htrans,
    ahb_penult_beat_reg,
    ahb_penult_beat_reg_0,
    s_ahb_hresetn,
    nonseq_detected,
    ahb_penult_beat_reg_1,
    SS,
    E,
    s_ahb_hclk);
  output s_ahb_htrans_0_sp_1;
  output [4:0]Q;
  input [1:0]s_ahb_htrans;
  input ahb_penult_beat_reg;
  input ahb_penult_beat_reg_0;
  input s_ahb_hresetn;
  input nonseq_detected;
  input [2:0]ahb_penult_beat_reg_1;
  input [0:0]SS;
  input [0:0]E;
  input s_ahb_hclk;

  wire [0:0]E;
  wire [4:0]Q;
  wire [0:0]SS;
  wire ahb_penult_beat_reg;
  wire ahb_penult_beat_reg_0;
  wire [2:0]ahb_penult_beat_reg_1;
  wire nonseq_detected;
  wire s_ahb_hclk;
  wire s_ahb_hresetn;
  wire [1:0]s_ahb_htrans;
  wire s_ahb_htrans_0_sn_1;

  assign s_ahb_htrans_0_sp_1 = s_ahb_htrans_0_sn_1;
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f_0 AHB_SAMPLE_CNT_MODULE
       (.E(E),
        .Q(Q),
        .SS(SS),
        .ahb_penult_beat_reg(ahb_penult_beat_reg),
        .ahb_penult_beat_reg_0(ahb_penult_beat_reg_0),
        .ahb_penult_beat_reg_1(ahb_penult_beat_reg_1),
        .nonseq_detected(nonseq_detected),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hresetn(s_ahb_hresetn),
        .s_ahb_htrans(s_ahb_htrans),
        .s_ahb_htrans_0_sp_1(s_ahb_htrans_0_sn_1));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_if
   (ahb_hburst_single,
    m_axi_arprot,
    idle_txfer_pending,
    ahb_penult_beat_reg_0,
    nonseq_txfer_pending,
    s_ahb_hready_out,
    s_ahb_hresp,
    burst_term_hwrite,
    burst_term_single_incr,
    burst_term,
    dummy_txfer_in_progress_reg_0,
    ahb_data_valid,
    D,
    ahb_hburst_incr_i_reg_0,
    nonseq_txfer_pending_i_reg_0,
    set_axi_waddr,
    s_ahb_hsel_0,
    nonseq_detected,
    E,
    ahb_hburst_incr_i_reg_1,
    m_axi_wready_0,
    ahb_hburst_incr_i_reg_2,
    \burst_term_txer_cnt_i_reg[2]_0 ,
    \INFERRED_GEN.icount_out_reg[0] ,
    \INFERRED_GEN.icount_out_reg[4] ,
    \INFERRED_GEN.icount_out_reg[0]_0 ,
    \burst_term_cur_cnt_i_reg[4]_0 ,
    \burst_term_cur_cnt_i_reg[0]_0 ,
    s_ahb_hready_in_0,
    m_axi_awready_0,
    nonseq_txfer_pending_i_reg_1,
    m_axi_arready_0,
    \valid_cnt_required_i_reg[3]_0 ,
    s_ahb_hrdata,
    m_axi_arlen,
    m_axi_arsize,
    m_axi_arburst,
    m_axi_arcache,
    m_axi_araddr,
    SS,
    s_ahb_hclk,
    s_ahb_hprot,
    idle_txfer_pending_reg_0,
    ahb_penult_beat_reg_1,
    nonseq_txfer_pending_i_reg_2,
    burst_term_hwrite_reg_0,
    burst_term_single_incr_reg_0,
    burst_term_i_reg_0,
    ahb_data_valid_i_reg_0,
    dummy_txfer_in_progress_reg_1,
    ahb_done_axi_in_progress_reg_0,
    m_axi_wready,
    s_ahb_hresetn,
    ahb_wnr_i_reg,
    S_AHB_HREADY_OUT_i_reg_0,
    S_AHB_HREADY_OUT_i_reg_1,
    S_AHB_HRESP_i_reg_0,
    s_ahb_hwrite,
    set_hresp_err,
    Q,
    S_AHB_HREADY_OUT_i_reg_2,
    S_AHB_HREADY_OUT_i_reg_3,
    m_axi_bvalid,
    ahb_wnr_i_reg_0,
    s_ahb_htrans,
    s_ahb_hready_in,
    s_ahb_hsel,
    \FSM_onehot_ctl_sm_cs_reg[0] ,
    \FSM_onehot_ctl_sm_cs_reg[0]_0 ,
    m_axi_bresp,
    S_AHB_HREADY_OUT_i_reg_4,
    ahb_data_valid_burst_term,
    M_AXI_WVALID_i_reg,
    M_AXI_WVALID_i_reg_0,
    s_ahb_hburst,
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 ,
    ahb_done_axi_in_progress_reg_1,
    p_10_in,
    m_axi_awready,
    m_axi_awvalid,
    m_axi_arready,
    M_AXI_ARVALID_i_reg,
    \S_AHB_HRDATA_i_reg[63]_0 ,
    m_axi_rdata,
    s_ahb_hsize,
    s_ahb_haddr,
    \burst_term_txer_cnt_i_reg[3]_0 ,
    \burst_term_cur_cnt_i_reg[4]_1 );
  output ahb_hburst_single;
  output [2:0]m_axi_arprot;
  output idle_txfer_pending;
  output ahb_penult_beat_reg_0;
  output nonseq_txfer_pending;
  output s_ahb_hready_out;
  output s_ahb_hresp;
  output burst_term_hwrite;
  output burst_term_single_incr;
  output burst_term;
  output dummy_txfer_in_progress_reg_0;
  output ahb_data_valid;
  output [2:0]D;
  output ahb_hburst_incr_i_reg_0;
  output nonseq_txfer_pending_i_reg_0;
  output set_axi_waddr;
  output s_ahb_hsel_0;
  output nonseq_detected;
  output [0:0]E;
  output ahb_hburst_incr_i_reg_1;
  output m_axi_wready_0;
  output ahb_hburst_incr_i_reg_2;
  output \burst_term_txer_cnt_i_reg[2]_0 ;
  output \INFERRED_GEN.icount_out_reg[0] ;
  output \INFERRED_GEN.icount_out_reg[4] ;
  output \INFERRED_GEN.icount_out_reg[0]_0 ;
  output [4:0]\burst_term_cur_cnt_i_reg[4]_0 ;
  output \burst_term_cur_cnt_i_reg[0]_0 ;
  output s_ahb_hready_in_0;
  output m_axi_awready_0;
  output nonseq_txfer_pending_i_reg_1;
  output m_axi_arready_0;
  output [2:0]\valid_cnt_required_i_reg[3]_0 ;
  output [63:0]s_ahb_hrdata;
  output [2:0]m_axi_arlen;
  output [2:0]m_axi_arsize;
  output [1:0]m_axi_arburst;
  output [1:0]m_axi_arcache;
  output [31:0]m_axi_araddr;
  input [0:0]SS;
  input s_ahb_hclk;
  input [3:0]s_ahb_hprot;
  input idle_txfer_pending_reg_0;
  input ahb_penult_beat_reg_1;
  input nonseq_txfer_pending_i_reg_2;
  input burst_term_hwrite_reg_0;
  input burst_term_single_incr_reg_0;
  input burst_term_i_reg_0;
  input ahb_data_valid_i_reg_0;
  input dummy_txfer_in_progress_reg_1;
  input ahb_done_axi_in_progress_reg_0;
  input m_axi_wready;
  input s_ahb_hresetn;
  input ahb_wnr_i_reg;
  input S_AHB_HREADY_OUT_i_reg_0;
  input S_AHB_HREADY_OUT_i_reg_1;
  input S_AHB_HRESP_i_reg_0;
  input s_ahb_hwrite;
  input set_hresp_err;
  input [3:0]Q;
  input S_AHB_HREADY_OUT_i_reg_2;
  input S_AHB_HREADY_OUT_i_reg_3;
  input m_axi_bvalid;
  input ahb_wnr_i_reg_0;
  input [1:0]s_ahb_htrans;
  input s_ahb_hready_in;
  input s_ahb_hsel;
  input \FSM_onehot_ctl_sm_cs_reg[0] ;
  input \FSM_onehot_ctl_sm_cs_reg[0]_0 ;
  input [0:0]m_axi_bresp;
  input S_AHB_HREADY_OUT_i_reg_4;
  input ahb_data_valid_burst_term;
  input M_AXI_WVALID_i_reg;
  input [0:0]M_AXI_WVALID_i_reg_0;
  input [2:0]s_ahb_hburst;
  input [4:0]\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 ;
  input ahb_done_axi_in_progress_reg_1;
  input p_10_in;
  input m_axi_awready;
  input m_axi_awvalid;
  input m_axi_arready;
  input M_AXI_ARVALID_i_reg;
  input [0:0]\S_AHB_HRDATA_i_reg[63]_0 ;
  input [63:0]m_axi_rdata;
  input [2:0]s_ahb_hsize;
  input [31:0]s_ahb_haddr;
  input [0:0]\burst_term_txer_cnt_i_reg[3]_0 ;
  input [4:0]\burst_term_cur_cnt_i_reg[4]_1 ;

  wire [0:0]AXI_ABURST_i;
  wire \AXI_ABURST_i[1]_i_1_n_0 ;
  wire \AXI_ABURST_i[1]_i_2_n_0 ;
  wire [3:1]AXI_ALEN_i;
  wire AXI_ALEN_i0;
  wire [2:0]D;
  wire [0:0]E;
  wire \FSM_onehot_ctl_sm_cs[0]_i_4_n_0 ;
  wire \FSM_onehot_ctl_sm_cs_reg[0] ;
  wire \FSM_onehot_ctl_sm_cs_reg[0]_0 ;
  wire \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1_n_0 ;
  wire \INFERRED_GEN.icount_out_reg[0] ;
  wire \INFERRED_GEN.icount_out_reg[0]_0 ;
  wire \INFERRED_GEN.icount_out_reg[4] ;
  wire M_AXI_ARVALID_i_reg;
  wire M_AXI_WVALID_i_reg;
  wire [0:0]M_AXI_WVALID_i_reg_0;
  wire [4:0]\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7_n_0 ;
  wire [3:0]Q;
  wire [0:0]SS;
  wire [0:0]\S_AHB_HRDATA_i_reg[63]_0 ;
  wire S_AHB_HREADY_OUT_i_i_10_n_0;
  wire S_AHB_HREADY_OUT_i_i_11_n_0;
  wire S_AHB_HREADY_OUT_i_i_14_n_0;
  wire S_AHB_HREADY_OUT_i_i_16_n_0;
  wire S_AHB_HREADY_OUT_i_i_2_n_0;
  wire S_AHB_HREADY_OUT_i_i_4_n_0;
  wire S_AHB_HREADY_OUT_i_i_6_n_0;
  wire S_AHB_HREADY_OUT_i_i_7_n_0;
  wire S_AHB_HREADY_OUT_i_reg_0;
  wire S_AHB_HREADY_OUT_i_reg_1;
  wire S_AHB_HREADY_OUT_i_reg_2;
  wire S_AHB_HREADY_OUT_i_reg_3;
  wire S_AHB_HREADY_OUT_i_reg_4;
  wire S_AHB_HRESP_i_i_1_n_0;
  wire S_AHB_HRESP_i_i_3_n_0;
  wire S_AHB_HRESP_i_i_4_n_0;
  wire S_AHB_HRESP_i_reg_0;
  wire S_AHB_HSIZE_i0;
  wire ahb_burst_done;
  wire ahb_data_valid;
  wire ahb_data_valid_burst_term;
  wire ahb_data_valid_i_reg_0;
  wire ahb_done_axi_in_progress;
  wire ahb_done_axi_in_progress_i_1_n_0;
  wire ahb_done_axi_in_progress_reg_0;
  wire ahb_done_axi_in_progress_reg_1;
  wire ahb_hburst_incr;
  wire ahb_hburst_incr_i_reg_0;
  wire ahb_hburst_incr_i_reg_1;
  wire ahb_hburst_incr_i_reg_2;
  wire ahb_hburst_single;
  wire ahb_penult_beat_reg_0;
  wire ahb_penult_beat_reg_1;
  wire ahb_wnr_i_reg;
  wire ahb_wnr_i_reg_0;
  wire burst_term;
  wire \burst_term_cur_cnt_i_reg[0]_0 ;
  wire [4:0]\burst_term_cur_cnt_i_reg[4]_0 ;
  wire [4:0]\burst_term_cur_cnt_i_reg[4]_1 ;
  wire burst_term_hwrite;
  wire burst_term_hwrite_reg_0;
  wire burst_term_i_reg_0;
  wire burst_term_single_incr;
  wire burst_term_single_incr_reg_0;
  wire [3:1]burst_term_txer_cnt;
  wire \burst_term_txer_cnt_i_reg[2]_0 ;
  wire [0:0]\burst_term_txer_cnt_i_reg[3]_0 ;
  wire dummy_txfer_in_progress_i_1_n_0;
  wire dummy_txfer_in_progress_reg_0;
  wire dummy_txfer_in_progress_reg_1;
  wire eqOp;
  wire eqOp0_in;
  wire idle_txfer_pending;
  wire idle_txfer_pending_reg_0;
  wire [31:0]m_axi_araddr;
  wire [1:0]m_axi_arburst;
  wire [1:0]m_axi_arcache;
  wire [2:0]m_axi_arlen;
  wire [2:0]m_axi_arprot;
  wire m_axi_arready;
  wire m_axi_arready_0;
  wire [2:0]m_axi_arsize;
  wire m_axi_awready;
  wire m_axi_awready_0;
  wire m_axi_awvalid;
  wire [0:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire [63:0]m_axi_rdata;
  wire m_axi_wready;
  wire m_axi_wready_0;
  wire nonseq_detected;
  wire nonseq_txfer_pending;
  wire nonseq_txfer_pending_i_reg_0;
  wire nonseq_txfer_pending_i_reg_1;
  wire nonseq_txfer_pending_i_reg_2;
  wire p_10_in;
  wire [2:2]p_1_out;
  wire [31:0]s_ahb_haddr;
  wire [2:0]s_ahb_hburst;
  wire s_ahb_hclk;
  wire [3:0]s_ahb_hprot;
  wire [63:0]s_ahb_hrdata;
  wire s_ahb_hready_in;
  wire s_ahb_hready_in_0;
  wire s_ahb_hready_out;
  wire s_ahb_hresetn;
  wire s_ahb_hresp;
  wire s_ahb_hsel;
  wire s_ahb_hsel_0;
  wire [2:0]s_ahb_hsize;
  wire [1:0]s_ahb_htrans;
  wire s_ahb_hwrite;
  wire set_axi_raddr;
  wire set_axi_waddr;
  wire set_hresp_err;
  wire [2:0]\valid_cnt_required_i_reg[3]_0 ;

  FDRE \AXI_AADDR_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[0]),
        .Q(m_axi_araddr[0]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[10] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[10]),
        .Q(m_axi_araddr[10]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[11] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[11]),
        .Q(m_axi_araddr[11]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[12] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[12]),
        .Q(m_axi_araddr[12]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[13] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[13]),
        .Q(m_axi_araddr[13]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[14] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[14]),
        .Q(m_axi_araddr[14]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[15] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[15]),
        .Q(m_axi_araddr[15]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[16] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[16]),
        .Q(m_axi_araddr[16]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[17] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[17]),
        .Q(m_axi_araddr[17]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[18] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[18]),
        .Q(m_axi_araddr[18]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[19] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[19]),
        .Q(m_axi_araddr[19]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[1]),
        .Q(m_axi_araddr[1]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[20] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[20]),
        .Q(m_axi_araddr[20]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[21] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[21]),
        .Q(m_axi_araddr[21]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[22] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[22]),
        .Q(m_axi_araddr[22]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[23] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[23]),
        .Q(m_axi_araddr[23]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[24] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[24]),
        .Q(m_axi_araddr[24]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[25] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[25]),
        .Q(m_axi_araddr[25]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[26] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[26]),
        .Q(m_axi_araddr[26]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[27] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[27]),
        .Q(m_axi_araddr[27]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[28] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[28]),
        .Q(m_axi_araddr[28]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[29] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[29]),
        .Q(m_axi_araddr[29]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[2]),
        .Q(m_axi_araddr[2]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[30] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[30]),
        .Q(m_axi_araddr[30]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[31] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[31]),
        .Q(m_axi_araddr[31]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[3] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[3]),
        .Q(m_axi_araddr[3]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[4] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[4]),
        .Q(m_axi_araddr[4]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[5] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[5]),
        .Q(m_axi_araddr[5]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[6] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[6]),
        .Q(m_axi_araddr[6]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[7] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[7]),
        .Q(m_axi_araddr[7]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[8] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[8]),
        .Q(m_axi_araddr[8]),
        .R(SS));
  FDRE \AXI_AADDR_i_reg[9] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_haddr[9]),
        .Q(m_axi_araddr[9]),
        .R(SS));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h888A)) 
    \AXI_ABURST_i[0]_i_1 
       (.I0(s_ahb_hresetn),
        .I1(s_ahb_hburst[0]),
        .I2(s_ahb_hburst[2]),
        .I3(s_ahb_hburst[1]),
        .O(AXI_ABURST_i));
  LUT6 #(
    .INIT(64'hDF55555555555555)) 
    \AXI_ABURST_i[1]_i_1 
       (.I0(s_ahb_hresetn),
        .I1(ahb_hburst_incr),
        .I2(s_ahb_htrans[0]),
        .I3(s_ahb_hready_in),
        .I4(s_ahb_hsel),
        .I5(s_ahb_htrans[1]),
        .O(\AXI_ABURST_i[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'h5400)) 
    \AXI_ABURST_i[1]_i_2 
       (.I0(s_ahb_hburst[0]),
        .I1(s_ahb_hburst[2]),
        .I2(s_ahb_hburst[1]),
        .I3(s_ahb_hresetn),
        .O(\AXI_ABURST_i[1]_i_2_n_0 ));
  FDRE \AXI_ABURST_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(\AXI_ABURST_i[1]_i_1_n_0 ),
        .D(AXI_ABURST_i),
        .Q(m_axi_arburst[0]),
        .R(1'b0));
  FDRE \AXI_ABURST_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(\AXI_ABURST_i[1]_i_1_n_0 ),
        .D(\AXI_ABURST_i[1]_i_2_n_0 ),
        .Q(m_axi_arburst[1]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \AXI_ALEN_i[1]_i_1 
       (.I0(s_ahb_hburst[2]),
        .I1(s_ahb_hburst[1]),
        .O(AXI_ALEN_i[1]));
  LUT5 #(
    .INIT(32'hB0000000)) 
    \AXI_ALEN_i[3]_i_1 
       (.I0(ahb_hburst_incr),
        .I1(s_ahb_htrans[0]),
        .I2(s_ahb_hready_in),
        .I3(s_ahb_hsel),
        .I4(s_ahb_htrans[1]),
        .O(AXI_ALEN_i0));
  LUT2 #(
    .INIT(4'h8)) 
    \AXI_ALEN_i[3]_i_2 
       (.I0(s_ahb_hburst[2]),
        .I1(s_ahb_hburst[1]),
        .O(AXI_ALEN_i[3]));
  FDRE \AXI_ALEN_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(AXI_ALEN_i[1]),
        .Q(m_axi_arlen[0]),
        .R(SS));
  FDRE \AXI_ALEN_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_hburst[2]),
        .Q(m_axi_arlen[1]),
        .R(SS));
  FDRE \AXI_ALEN_i_reg[3] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(AXI_ALEN_i[3]),
        .Q(m_axi_arlen[2]),
        .R(SS));
  FDRE \AXI_ASIZE_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(s_ahb_hsize[0]),
        .Q(m_axi_arsize[0]),
        .R(SS));
  FDRE \AXI_ASIZE_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(s_ahb_hsize[1]),
        .Q(m_axi_arsize[1]),
        .R(SS));
  FDRE \AXI_ASIZE_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(s_ahb_hsize[2]),
        .Q(m_axi_arsize[2]),
        .R(SS));
  LUT6 #(
    .INIT(64'hFFFF0D00FFFFFFFF)) 
    \FSM_onehot_ctl_sm_cs[0]_i_1 
       (.I0(\FSM_onehot_ctl_sm_cs_reg[0] ),
        .I1(idle_txfer_pending),
        .I2(nonseq_txfer_pending_i_reg_0),
        .I3(Q[3]),
        .I4(\FSM_onehot_ctl_sm_cs_reg[0]_0 ),
        .I5(\FSM_onehot_ctl_sm_cs[0]_i_4_n_0 ),
        .O(D[0]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'hBAAAAAAA)) 
    \FSM_onehot_ctl_sm_cs[0]_i_2 
       (.I0(nonseq_txfer_pending),
        .I1(s_ahb_htrans[0]),
        .I2(s_ahb_htrans[1]),
        .I3(s_ahb_hsel),
        .I4(s_ahb_hready_in),
        .O(nonseq_txfer_pending_i_reg_0));
  LUT6 #(
    .INIT(64'hF0F0F040FFFFFFFF)) 
    \FSM_onehot_ctl_sm_cs[0]_i_4 
       (.I0(idle_txfer_pending),
        .I1(m_axi_bresp),
        .I2(m_axi_bvalid),
        .I3(nonseq_detected),
        .I4(nonseq_txfer_pending),
        .I5(Q[2]),
        .O(\FSM_onehot_ctl_sm_cs[0]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h0000004000000000)) 
    \FSM_onehot_ctl_sm_cs[4]_i_1 
       (.I0(idle_txfer_pending),
        .I1(m_axi_bresp),
        .I2(m_axi_bvalid),
        .I3(nonseq_detected),
        .I4(nonseq_txfer_pending),
        .I5(Q[2]),
        .O(D[1]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'h00000008)) 
    \FSM_onehot_ctl_sm_cs[6]_i_2 
       (.I0(\FSM_onehot_ctl_sm_cs_reg[0] ),
        .I1(Q[3]),
        .I2(idle_txfer_pending),
        .I3(nonseq_detected),
        .I4(nonseq_txfer_pending),
        .O(D[2]));
  LUT6 #(
    .INIT(64'h4FFFFFFFFFFFFFFF)) 
    \FSM_onehot_ctl_sm_cs[6]_i_4 
       (.I0(ahb_hburst_incr),
        .I1(s_ahb_htrans[0]),
        .I2(s_ahb_hready_in),
        .I3(s_ahb_hsel),
        .I4(s_ahb_htrans[1]),
        .I5(Q[0]),
        .O(ahb_hburst_incr_i_reg_0));
  FDSE \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_ACACHE_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_hprot[2]),
        .Q(m_axi_arcache[0]),
        .S(SS));
  FDSE \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_ACACHE_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_hprot[3]),
        .Q(m_axi_arcache[1]),
        .S(SS));
  LUT6 #(
    .INIT(64'hAEAEAAAEFFFFFFFF)) 
    \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1 
       (.I0(m_axi_arprot[1]),
        .I1(s_ahb_htrans[1]),
        .I2(s_ahb_hsel_0),
        .I3(s_ahb_htrans[0]),
        .I4(ahb_hburst_incr),
        .I5(s_ahb_hresetn),
        .O(\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_2 
       (.I0(s_ahb_hsel),
        .I1(s_ahb_hready_in),
        .O(s_ahb_hsel_0));
  LUT1 #(
    .INIT(2'h1)) 
    \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[2]_i_1 
       (.I0(s_ahb_hprot[0]),
        .O(p_1_out));
  FDRE \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(s_ahb_hprot[1]),
        .Q(m_axi_arprot[0]),
        .R(SS));
  FDRE \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1_n_0 ),
        .Q(m_axi_arprot[1]),
        .R(1'b0));
  FDRE \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(AXI_ALEN_i0),
        .D(p_1_out),
        .Q(m_axi_arprot[2]),
        .R(SS));
  LUT6 #(
    .INIT(64'h5D00000000000000)) 
    \INFERRED_GEN.icount_out[4]_i_1__0 
       (.I0(s_ahb_htrans[0]),
        .I1(s_ahb_hwrite),
        .I2(ahb_hburst_incr),
        .I3(s_ahb_htrans[1]),
        .I4(s_ahb_hsel),
        .I5(s_ahb_hready_in),
        .O(E));
  LUT3 #(
    .INIT(8'hDC)) 
    M_AXI_ARVALID_i_i_1
       (.I0(m_axi_arready),
        .I1(set_axi_raddr),
        .I2(M_AXI_ARVALID_i_reg),
        .O(m_axi_arready_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h0CCD0CFF)) 
    M_AXI_ARVALID_i_i_2
       (.I0(ahb_wnr_i_reg_0),
        .I1(ahb_wnr_i_reg),
        .I2(burst_term_hwrite),
        .I3(s_ahb_hwrite),
        .I4(ahb_hburst_incr_i_reg_0),
        .O(set_axi_raddr));
  LUT3 #(
    .INIT(8'hDC)) 
    M_AXI_AWVALID_i_i_1
       (.I0(m_axi_awready),
        .I1(set_axi_waddr),
        .I2(m_axi_awvalid),
        .O(m_axi_awready_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT5 #(
    .INIT(32'hFFF44444)) 
    M_AXI_WLAST_i_i_3
       (.I0(m_axi_wready),
        .I1(ahb_done_axi_in_progress_reg_0),
        .I2(ahb_hburst_incr),
        .I3(ahb_hburst_single),
        .I4(M_AXI_WVALID_i_reg_0),
        .O(m_axi_wready_0));
  LUT6 #(
    .INIT(64'hFFFFFF0004040000)) 
    M_AXI_WVALID_i_i_2
       (.I0(ahb_hburst_incr),
        .I1(Q[1]),
        .I2(ahb_hburst_single),
        .I3(ahb_data_valid_burst_term),
        .I4(M_AXI_WVALID_i_reg),
        .I5(M_AXI_WVALID_i_reg_0),
        .O(ahb_hburst_incr_i_reg_1));
  LUT5 #(
    .INIT(32'h00009009)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4 
       (.I0(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [0]),
        .I1(\burst_term_cur_cnt_i_reg[4]_0 [0]),
        .I2(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [3]),
        .I3(\burst_term_cur_cnt_i_reg[4]_0 [3]),
        .I4(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7_n_0 ),
        .O(\INFERRED_GEN.icount_out_reg[0]_0 ));
  LUT3 #(
    .INIT(8'h01)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_6 
       (.I0(\burst_term_cur_cnt_i_reg[4]_0 [0]),
        .I1(\burst_term_cur_cnt_i_reg[4]_0 [1]),
        .I2(\burst_term_cur_cnt_i_reg[4]_0 [2]),
        .O(\burst_term_cur_cnt_i_reg[0]_0 ));
  LUT6 #(
    .INIT(64'h6FF6FFFFFFFF6FF6)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7 
       (.I0(\burst_term_cur_cnt_i_reg[4]_0 [4]),
        .I1(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [4]),
        .I2(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [1]),
        .I3(\burst_term_cur_cnt_i_reg[4]_0 [1]),
        .I4(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [2]),
        .I5(\burst_term_cur_cnt_i_reg[4]_0 [2]),
        .O(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7_n_0 ));
  FDRE \S_AHB_HRDATA_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[0]),
        .Q(s_ahb_hrdata[0]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[10] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[10]),
        .Q(s_ahb_hrdata[10]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[11] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[11]),
        .Q(s_ahb_hrdata[11]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[12] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[12]),
        .Q(s_ahb_hrdata[12]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[13] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[13]),
        .Q(s_ahb_hrdata[13]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[14] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[14]),
        .Q(s_ahb_hrdata[14]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[15] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[15]),
        .Q(s_ahb_hrdata[15]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[16] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[16]),
        .Q(s_ahb_hrdata[16]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[17] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[17]),
        .Q(s_ahb_hrdata[17]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[18] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[18]),
        .Q(s_ahb_hrdata[18]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[19] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[19]),
        .Q(s_ahb_hrdata[19]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[1]),
        .Q(s_ahb_hrdata[1]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[20] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[20]),
        .Q(s_ahb_hrdata[20]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[21] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[21]),
        .Q(s_ahb_hrdata[21]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[22] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[22]),
        .Q(s_ahb_hrdata[22]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[23] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[23]),
        .Q(s_ahb_hrdata[23]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[24] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[24]),
        .Q(s_ahb_hrdata[24]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[25] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[25]),
        .Q(s_ahb_hrdata[25]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[26] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[26]),
        .Q(s_ahb_hrdata[26]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[27] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[27]),
        .Q(s_ahb_hrdata[27]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[28] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[28]),
        .Q(s_ahb_hrdata[28]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[29] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[29]),
        .Q(s_ahb_hrdata[29]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[2]),
        .Q(s_ahb_hrdata[2]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[30] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[30]),
        .Q(s_ahb_hrdata[30]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[31] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[31]),
        .Q(s_ahb_hrdata[31]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[32] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[32]),
        .Q(s_ahb_hrdata[32]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[33] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[33]),
        .Q(s_ahb_hrdata[33]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[34] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[34]),
        .Q(s_ahb_hrdata[34]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[35] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[35]),
        .Q(s_ahb_hrdata[35]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[36] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[36]),
        .Q(s_ahb_hrdata[36]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[37] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[37]),
        .Q(s_ahb_hrdata[37]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[38] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[38]),
        .Q(s_ahb_hrdata[38]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[39] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[39]),
        .Q(s_ahb_hrdata[39]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[3] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[3]),
        .Q(s_ahb_hrdata[3]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[40] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[40]),
        .Q(s_ahb_hrdata[40]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[41] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[41]),
        .Q(s_ahb_hrdata[41]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[42] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[42]),
        .Q(s_ahb_hrdata[42]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[43] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[43]),
        .Q(s_ahb_hrdata[43]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[44] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[44]),
        .Q(s_ahb_hrdata[44]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[45] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[45]),
        .Q(s_ahb_hrdata[45]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[46] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[46]),
        .Q(s_ahb_hrdata[46]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[47] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[47]),
        .Q(s_ahb_hrdata[47]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[48] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[48]),
        .Q(s_ahb_hrdata[48]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[49] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[49]),
        .Q(s_ahb_hrdata[49]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[4] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[4]),
        .Q(s_ahb_hrdata[4]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[50] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[50]),
        .Q(s_ahb_hrdata[50]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[51] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[51]),
        .Q(s_ahb_hrdata[51]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[52] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[52]),
        .Q(s_ahb_hrdata[52]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[53] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[53]),
        .Q(s_ahb_hrdata[53]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[54] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[54]),
        .Q(s_ahb_hrdata[54]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[55] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[55]),
        .Q(s_ahb_hrdata[55]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[56] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[56]),
        .Q(s_ahb_hrdata[56]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[57] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[57]),
        .Q(s_ahb_hrdata[57]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[58] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[58]),
        .Q(s_ahb_hrdata[58]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[59] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[59]),
        .Q(s_ahb_hrdata[59]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[5] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[5]),
        .Q(s_ahb_hrdata[5]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[60] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[60]),
        .Q(s_ahb_hrdata[60]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[61] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[61]),
        .Q(s_ahb_hrdata[61]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[62] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[62]),
        .Q(s_ahb_hrdata[62]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[63] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[63]),
        .Q(s_ahb_hrdata[63]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[6] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[6]),
        .Q(s_ahb_hrdata[6]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[7] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[7]),
        .Q(s_ahb_hrdata[7]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[8] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[8]),
        .Q(s_ahb_hrdata[8]),
        .R(SS));
  FDRE \S_AHB_HRDATA_i_reg[9] 
       (.C(s_ahb_hclk),
        .CE(\S_AHB_HRDATA_i_reg[63]_0 ),
        .D(m_axi_rdata[9]),
        .Q(s_ahb_hrdata[9]),
        .R(SS));
  LUT6 #(
    .INIT(64'hFFF3FFF3AAA20000)) 
    S_AHB_HREADY_OUT_i_i_10
       (.I0(AXI_ALEN_i[1]),
        .I1(S_AHB_HRESP_i_reg_0),
        .I2(S_AHB_HREADY_OUT_i_i_11_n_0),
        .I3(S_AHB_HREADY_OUT_i_i_16_n_0),
        .I4(s_ahb_hwrite),
        .I5(ahb_hburst_incr_i_reg_0),
        .O(S_AHB_HREADY_OUT_i_i_10_n_0));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT5 #(
    .INIT(32'h0000E000)) 
    S_AHB_HREADY_OUT_i_i_11
       (.I0(s_ahb_hburst[1]),
        .I1(s_ahb_hburst[2]),
        .I2(s_ahb_hwrite),
        .I3(burst_term_hwrite),
        .I4(burst_term_single_incr),
        .O(S_AHB_HREADY_OUT_i_i_11_n_0));
  LUT5 #(
    .INIT(32'h80000000)) 
    S_AHB_HREADY_OUT_i_i_14
       (.I0(ahb_hburst_incr),
        .I1(s_ahb_htrans[0]),
        .I2(s_ahb_hready_in),
        .I3(s_ahb_hsel),
        .I4(s_ahb_htrans[1]),
        .O(S_AHB_HREADY_OUT_i_i_14_n_0));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    S_AHB_HREADY_OUT_i_i_15
       (.I0(ahb_penult_beat_reg_0),
        .I1(s_ahb_htrans[0]),
        .I2(s_ahb_hready_in),
        .I3(s_ahb_hsel),
        .I4(s_ahb_htrans[1]),
        .O(ahb_burst_done));
  LUT6 #(
    .INIT(64'h45555555FFFFFFFF)) 
    S_AHB_HREADY_OUT_i_i_16
       (.I0(nonseq_txfer_pending),
        .I1(s_ahb_htrans[0]),
        .I2(s_ahb_htrans[1]),
        .I3(s_ahb_hsel),
        .I4(s_ahb_hready_in),
        .I5(Q[3]),
        .O(S_AHB_HREADY_OUT_i_i_16_n_0));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'hE)) 
    S_AHB_HREADY_OUT_i_i_17
       (.I0(ahb_hburst_incr),
        .I1(ahb_hburst_single),
        .O(ahb_hburst_incr_i_reg_2));
  LUT6 #(
    .INIT(64'h0000FFFA0000FCFA)) 
    S_AHB_HREADY_OUT_i_i_2
       (.I0(s_ahb_hready_in_0),
        .I1(S_AHB_HREADY_OUT_i_i_4_n_0),
        .I2(p_10_in),
        .I3(S_AHB_HREADY_OUT_i_i_6_n_0),
        .I4(S_AHB_HREADY_OUT_i_i_7_n_0),
        .I5(s_ahb_hready_out),
        .O(S_AHB_HREADY_OUT_i_i_2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h0080)) 
    S_AHB_HREADY_OUT_i_i_3
       (.I0(s_ahb_hready_in),
        .I1(s_ahb_hsel),
        .I2(s_ahb_htrans[0]),
        .I3(s_ahb_htrans[1]),
        .O(s_ahb_hready_in_0));
  LUT4 #(
    .INIT(16'hEEEF)) 
    S_AHB_HREADY_OUT_i_i_4
       (.I0(S_AHB_HREADY_OUT_i_reg_2),
        .I1(S_AHB_HRESP_i_i_4_n_0),
        .I2(S_AHB_HRESP_i_i_3_n_0),
        .I3(S_AHB_HREADY_OUT_i_reg_3),
        .O(S_AHB_HREADY_OUT_i_i_4_n_0));
  LUT6 #(
    .INIT(64'h000000000000008A)) 
    S_AHB_HREADY_OUT_i_i_6
       (.I0(S_AHB_HREADY_OUT_i_i_10_n_0),
        .I1(S_AHB_HREADY_OUT_i_i_11_n_0),
        .I2(ahb_wnr_i_reg),
        .I3(S_AHB_HREADY_OUT_i_reg_0),
        .I4(D[1]),
        .I5(S_AHB_HREADY_OUT_i_reg_1),
        .O(S_AHB_HREADY_OUT_i_i_6_n_0));
  LUT6 #(
    .INIT(64'hFFFFFFFEFFFCFFFE)) 
    S_AHB_HREADY_OUT_i_i_7
       (.I0(S_AHB_HREADY_OUT_i_i_14_n_0),
        .I1(S_AHB_HREADY_OUT_i_reg_4),
        .I2(ahb_done_axi_in_progress),
        .I3(nonseq_txfer_pending),
        .I4(s_ahb_hwrite),
        .I5(ahb_burst_done),
        .O(S_AHB_HREADY_OUT_i_i_7_n_0));
  FDSE S_AHB_HREADY_OUT_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(S_AHB_HREADY_OUT_i_i_2_n_0),
        .Q(s_ahb_hready_out),
        .S(SS));
  LUT6 #(
    .INIT(64'h0000000000A80000)) 
    S_AHB_HRESP_i_i_1
       (.I0(s_ahb_hresetn),
        .I1(set_hresp_err),
        .I2(s_ahb_hresp),
        .I3(Q[0]),
        .I4(S_AHB_HRESP_i_i_3_n_0),
        .I5(S_AHB_HRESP_i_i_4_n_0),
        .O(S_AHB_HRESP_i_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFB)) 
    S_AHB_HRESP_i_i_3
       (.I0(\FSM_onehot_ctl_sm_cs_reg[0] ),
        .I1(Q[3]),
        .I2(idle_txfer_pending),
        .I3(nonseq_detected),
        .I4(nonseq_txfer_pending),
        .O(S_AHB_HRESP_i_i_3_n_0));
  LUT6 #(
    .INIT(64'h44F4444444444444)) 
    S_AHB_HRESP_i_i_4
       (.I0(\FSM_onehot_ctl_sm_cs[0]_i_4_n_0 ),
        .I1(m_axi_bvalid),
        .I2(Q[3]),
        .I3(nonseq_txfer_pending_i_reg_0),
        .I4(idle_txfer_pending),
        .I5(S_AHB_HRESP_i_reg_0),
        .O(S_AHB_HRESP_i_i_4_n_0));
  FDRE S_AHB_HRESP_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(S_AHB_HRESP_i_i_1_n_0),
        .Q(s_ahb_hresp),
        .R(1'b0));
  LUT3 #(
    .INIT(8'hBA)) 
    ahb_data_valid_burst_term_i_1
       (.I0(nonseq_txfer_pending),
        .I1(dummy_txfer_in_progress_reg_1),
        .I2(ahb_data_valid_burst_term),
        .O(nonseq_txfer_pending_i_reg_1));
  FDRE ahb_data_valid_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(ahb_data_valid_i_reg_0),
        .Q(ahb_data_valid),
        .R(SS));
  LUT5 #(
    .INIT(32'h4FFF4444)) 
    ahb_done_axi_in_progress_i_1
       (.I0(ahb_done_axi_in_progress_reg_1),
        .I1(ahb_penult_beat_reg_0),
        .I2(m_axi_wready),
        .I3(ahb_done_axi_in_progress_reg_0),
        .I4(ahb_done_axi_in_progress),
        .O(ahb_done_axi_in_progress_i_1_n_0));
  FDRE ahb_done_axi_in_progress_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(ahb_done_axi_in_progress_i_1_n_0),
        .Q(ahb_done_axi_in_progress),
        .R(SS));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'h02)) 
    ahb_hburst_incr_i_i_1
       (.I0(s_ahb_hburst[0]),
        .I1(s_ahb_hburst[1]),
        .I2(s_ahb_hburst[2]),
        .O(eqOp));
  FDRE ahb_hburst_incr_i_reg
       (.C(s_ahb_hclk),
        .CE(S_AHB_HSIZE_i0),
        .D(eqOp),
        .Q(ahb_hburst_incr),
        .R(SS));
  LUT3 #(
    .INIT(8'h08)) 
    ahb_hburst_single_i_i_1
       (.I0(s_ahb_hready_out),
        .I1(s_ahb_htrans[1]),
        .I2(s_ahb_htrans[0]),
        .O(S_AHB_HSIZE_i0));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'h01)) 
    ahb_hburst_single_i_i_2
       (.I0(s_ahb_hburst[0]),
        .I1(s_ahb_hburst[1]),
        .I2(s_ahb_hburst[2]),
        .O(eqOp0_in));
  FDRE ahb_hburst_single_i_reg
       (.C(s_ahb_hclk),
        .CE(S_AHB_HSIZE_i0),
        .D(eqOp0_in),
        .Q(ahb_hburst_single),
        .R(SS));
  FDRE ahb_penult_beat_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(ahb_penult_beat_reg_1),
        .Q(ahb_penult_beat_reg_0),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'hCF88FFAA)) 
    ahb_wnr_i_i_1
       (.I0(burst_term_hwrite),
        .I1(ahb_wnr_i_reg),
        .I2(ahb_hburst_incr_i_reg_0),
        .I3(s_ahb_hwrite),
        .I4(ahb_wnr_i_reg_0),
        .O(set_axi_waddr));
  LUT6 #(
    .INIT(64'h4008048000000000)) 
    axi_last_beat_i_3
       (.I0(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [0]),
        .I1(\INFERRED_GEN.icount_out_reg[4] ),
        .I2(burst_term_txer_cnt[2]),
        .I3(burst_term_txer_cnt[1]),
        .I4(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [2]),
        .I5(burst_term),
        .O(\INFERRED_GEN.icount_out_reg[0] ));
  LUT6 #(
    .INIT(64'hFFF9FFFF6FFFFFFF)) 
    axi_penult_beat_i_4
       (.I0(burst_term_txer_cnt[2]),
        .I1(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [2]),
        .I2(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [0]),
        .I3(burst_term_txer_cnt[1]),
        .I4(burst_term),
        .I5(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [1]),
        .O(\burst_term_txer_cnt_i_reg[2]_0 ));
  LUT5 #(
    .INIT(32'h44421114)) 
    axi_penult_beat_i_5
       (.I0(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [4]),
        .I1(burst_term_txer_cnt[3]),
        .I2(burst_term_txer_cnt[1]),
        .I3(burst_term_txer_cnt[2]),
        .I4(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 [3]),
        .O(\INFERRED_GEN.icount_out_reg[4] ));
  FDRE \burst_term_cur_cnt_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\burst_term_cur_cnt_i_reg[4]_1 [0]),
        .Q(\burst_term_cur_cnt_i_reg[4]_0 [0]),
        .R(SS));
  FDRE \burst_term_cur_cnt_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\burst_term_cur_cnt_i_reg[4]_1 [1]),
        .Q(\burst_term_cur_cnt_i_reg[4]_0 [1]),
        .R(SS));
  FDRE \burst_term_cur_cnt_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\burst_term_cur_cnt_i_reg[4]_1 [2]),
        .Q(\burst_term_cur_cnt_i_reg[4]_0 [2]),
        .R(SS));
  FDRE \burst_term_cur_cnt_i_reg[3] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\burst_term_cur_cnt_i_reg[4]_1 [3]),
        .Q(\burst_term_cur_cnt_i_reg[4]_0 [3]),
        .R(SS));
  FDRE \burst_term_cur_cnt_i_reg[4] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\burst_term_cur_cnt_i_reg[4]_1 [4]),
        .Q(\burst_term_cur_cnt_i_reg[4]_0 [4]),
        .R(SS));
  FDRE burst_term_hwrite_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(burst_term_hwrite_reg_0),
        .Q(burst_term_hwrite),
        .R(SS));
  FDRE burst_term_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(burst_term_i_reg_0),
        .Q(burst_term),
        .R(1'b0));
  FDRE burst_term_single_incr_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(burst_term_single_incr_reg_0),
        .Q(burst_term_single_incr),
        .R(SS));
  FDRE \burst_term_txer_cnt_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\valid_cnt_required_i_reg[3]_0 [0]),
        .Q(burst_term_txer_cnt[1]),
        .R(SS));
  FDRE \burst_term_txer_cnt_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\valid_cnt_required_i_reg[3]_0 [1]),
        .Q(burst_term_txer_cnt[2]),
        .R(SS));
  FDRE \burst_term_txer_cnt_i_reg[3] 
       (.C(s_ahb_hclk),
        .CE(\burst_term_txer_cnt_i_reg[3]_0 ),
        .D(\valid_cnt_required_i_reg[3]_0 [2]),
        .Q(burst_term_txer_cnt[3]),
        .R(SS));
  LUT6 #(
    .INIT(64'hC555C00000000000)) 
    dummy_txfer_in_progress_i_1
       (.I0(dummy_txfer_in_progress_reg_1),
        .I1(burst_term),
        .I2(ahb_done_axi_in_progress_reg_0),
        .I3(m_axi_wready),
        .I4(dummy_txfer_in_progress_reg_0),
        .I5(s_ahb_hresetn),
        .O(dummy_txfer_in_progress_i_1_n_0));
  FDRE dummy_txfer_in_progress_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(dummy_txfer_in_progress_i_1_n_0),
        .Q(dummy_txfer_in_progress_reg_0),
        .R(1'b0));
  FDRE idle_txfer_pending_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(idle_txfer_pending_reg_0),
        .Q(idle_txfer_pending),
        .R(1'b0));
  FDRE nonseq_txfer_pending_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(nonseq_txfer_pending_i_reg_2),
        .Q(nonseq_txfer_pending),
        .R(SS));
  LUT4 #(
    .INIT(16'h0080)) 
    \valid_cnt_required_i[3]_i_1 
       (.I0(s_ahb_hready_in),
        .I1(s_ahb_hsel),
        .I2(s_ahb_htrans[1]),
        .I3(s_ahb_htrans[0]),
        .O(nonseq_detected));
  FDRE \valid_cnt_required_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(nonseq_detected),
        .D(AXI_ALEN_i[1]),
        .Q(\valid_cnt_required_i_reg[3]_0 [0]),
        .R(SS));
  FDRE \valid_cnt_required_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(nonseq_detected),
        .D(s_ahb_hburst[2]),
        .Q(\valid_cnt_required_i_reg[3]_0 [1]),
        .R(SS));
  FDRE \valid_cnt_required_i_reg[3] 
       (.C(s_ahb_hclk),
        .CE(nonseq_detected),
        .D(AXI_ALEN_i[3]),
        .Q(\valid_cnt_required_i_reg[3]_0 [2]),
        .R(SS));
endmodule

(* C_AHB_AXI_TIMEOUT = "0" *) (* C_FAMILY = "zynquplus" *) (* C_INSTANCE = "zynqmpsoc_ahblite_axi_bridge_0_0" *) 
(* C_M_AXI_ADDR_WIDTH = "32" *) (* C_M_AXI_DATA_WIDTH = "64" *) (* C_M_AXI_NON_SECURE = "1" *) 
(* C_M_AXI_PROTOCOL = "AXI4" *) (* C_M_AXI_SUPPORTS_NARROW_BURST = "0" *) (* C_M_AXI_THREAD_ID_WIDTH = "4" *) 
(* C_S_AHB_ADDR_WIDTH = "32" *) (* C_S_AHB_DATA_WIDTH = "64" *) (* downgradeipidentifiedwarnings = "yes" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge
   (s_ahb_hclk,
    s_ahb_hresetn,
    s_ahb_hsel,
    s_ahb_haddr,
    s_ahb_hprot,
    s_ahb_htrans,
    s_ahb_hsize,
    s_ahb_hwrite,
    s_ahb_hburst,
    s_ahb_hwdata,
    s_ahb_hready_out,
    s_ahb_hready_in,
    s_ahb_hrdata,
    s_ahb_hresp,
    m_axi_awid,
    m_axi_awlen,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awcache,
    m_axi_awaddr,
    m_axi_awprot,
    m_axi_awvalid,
    m_axi_awready,
    m_axi_awlock,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wlast,
    m_axi_wvalid,
    m_axi_wready,
    m_axi_bid,
    m_axi_bresp,
    m_axi_bvalid,
    m_axi_bready,
    m_axi_arid,
    m_axi_arlen,
    m_axi_arsize,
    m_axi_arburst,
    m_axi_arprot,
    m_axi_arcache,
    m_axi_arvalid,
    m_axi_araddr,
    m_axi_arlock,
    m_axi_arready,
    m_axi_rid,
    m_axi_rdata,
    m_axi_rresp,
    m_axi_rvalid,
    m_axi_rlast,
    m_axi_rready);
  input s_ahb_hclk;
  input s_ahb_hresetn;
  input s_ahb_hsel;
  input [31:0]s_ahb_haddr;
  input [3:0]s_ahb_hprot;
  input [1:0]s_ahb_htrans;
  input [2:0]s_ahb_hsize;
  input s_ahb_hwrite;
  input [2:0]s_ahb_hburst;
  input [63:0]s_ahb_hwdata;
  output s_ahb_hready_out;
  input s_ahb_hready_in;
  output [63:0]s_ahb_hrdata;
  output s_ahb_hresp;
  output [3:0]m_axi_awid;
  output [7:0]m_axi_awlen;
  output [2:0]m_axi_awsize;
  output [1:0]m_axi_awburst;
  output [3:0]m_axi_awcache;
  output [31:0]m_axi_awaddr;
  output [2:0]m_axi_awprot;
  output m_axi_awvalid;
  input m_axi_awready;
  output m_axi_awlock;
  output [63:0]m_axi_wdata;
  output [7:0]m_axi_wstrb;
  output m_axi_wlast;
  output m_axi_wvalid;
  input m_axi_wready;
  input [3:0]m_axi_bid;
  input [1:0]m_axi_bresp;
  input m_axi_bvalid;
  output m_axi_bready;
  output [3:0]m_axi_arid;
  output [7:0]m_axi_arlen;
  output [2:0]m_axi_arsize;
  output [1:0]m_axi_arburst;
  output [2:0]m_axi_arprot;
  output [3:0]m_axi_arcache;
  output m_axi_arvalid;
  output [31:0]m_axi_araddr;
  output m_axi_arlock;
  input m_axi_arready;
  input [3:0]m_axi_rid;
  input [63:0]m_axi_rdata;
  input [1:0]m_axi_rresp;
  input m_axi_rvalid;
  input m_axi_rlast;
  output m_axi_rready;

  wire \<const0> ;
  wire AHBLITE_AXI_CONTROL_n_1;
  wire AHBLITE_AXI_CONTROL_n_13;
  wire AHBLITE_AXI_CONTROL_n_14;
  wire AHBLITE_AXI_CONTROL_n_15;
  wire AHBLITE_AXI_CONTROL_n_16;
  wire AHBLITE_AXI_CONTROL_n_17;
  wire AHBLITE_AXI_CONTROL_n_18;
  wire AHBLITE_AXI_CONTROL_n_19;
  wire AHBLITE_AXI_CONTROL_n_2;
  wire AHBLITE_AXI_CONTROL_n_20;
  wire AHBLITE_AXI_CONTROL_n_3;
  wire AHBLITE_AXI_CONTROL_n_5;
  wire AHBLITE_AXI_CONTROL_n_6;
  wire AHBLITE_AXI_CONTROL_n_7;
  wire AHBLITE_AXI_CONTROL_n_8;
  wire AHBLITE_AXI_CONTROL_n_9;
  wire AHB_DATA_COUNTER_n_0;
  wire AHB_DATA_COUNTER_n_1;
  wire AHB_DATA_COUNTER_n_2;
  wire AHB_DATA_COUNTER_n_3;
  wire AHB_DATA_COUNTER_n_4;
  wire AHB_DATA_COUNTER_n_5;
  wire AHB_IF_n_12;
  wire AHB_IF_n_14;
  wire AHB_IF_n_15;
  wire AHB_IF_n_16;
  wire AHB_IF_n_17;
  wire AHB_IF_n_18;
  wire AHB_IF_n_20;
  wire AHB_IF_n_22;
  wire AHB_IF_n_23;
  wire AHB_IF_n_24;
  wire AHB_IF_n_25;
  wire AHB_IF_n_26;
  wire AHB_IF_n_27;
  wire AHB_IF_n_28;
  wire AHB_IF_n_29;
  wire AHB_IF_n_35;
  wire AHB_IF_n_36;
  wire AHB_IF_n_37;
  wire AHB_IF_n_38;
  wire AHB_IF_n_39;
  wire AHB_IF_n_5;
  wire AXI_RCHANNEL_n_10;
  wire AXI_RCHANNEL_n_2;
  wire AXI_RCHANNEL_n_3;
  wire AXI_RCHANNEL_n_4;
  wire AXI_RCHANNEL_n_6;
  wire AXI_RCHANNEL_n_7;
  wire AXI_RCHANNEL_n_8;
  wire AXI_WCHANNEL_n_10;
  wire AXI_WCHANNEL_n_11;
  wire AXI_WCHANNEL_n_12;
  wire AXI_WCHANNEL_n_13;
  wire AXI_WCHANNEL_n_14;
  wire AXI_WCHANNEL_n_15;
  wire AXI_WCHANNEL_n_7;
  wire AXI_WCHANNEL_n_8;
  wire AXI_WCHANNEL_n_9;
  wire ahb_data_valid;
  wire ahb_data_valid_burst_term;
  wire ahb_hburst_single;
  wire axi_waddr_done_i;
  wire burst_term;
  wire [4:0]burst_term_cur_cnt;
  wire burst_term_hwrite;
  wire burst_term_single_incr;
  wire burst_term_txer_cnt_i0;
  wire cntr_rst;
  wire core_is_idle;
  wire idle_txfer_pending;
  wire last_axi_rd_sample;
  wire [31:0]m_axi_araddr;
  wire [1:0]m_axi_arburst;
  wire [1:0]\^m_axi_arcache ;
  wire [3:2]\^m_axi_arlen ;
  wire [2:0]m_axi_arprot;
  wire m_axi_arready;
  wire [2:0]m_axi_arsize;
  wire m_axi_arvalid;
  wire [0:0]\^m_axi_awlen ;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire [63:0]m_axi_rdata;
  wire m_axi_rlast;
  wire m_axi_rready;
  wire [1:0]m_axi_rresp;
  wire m_axi_rvalid;
  wire [63:0]m_axi_wdata;
  wire m_axi_wlast;
  wire m_axi_wready;
  wire [6:6]\^m_axi_wstrb ;
  wire m_axi_wvalid;
  wire nonseq_detected;
  wire nonseq_txfer_pending;
  wire p_10_in;
  wire rd_load_timeout_cntr;
  wire [31:0]s_ahb_haddr;
  wire [2:0]s_ahb_hburst;
  wire s_ahb_hclk;
  wire [3:0]s_ahb_hprot;
  wire [63:0]s_ahb_hrdata;
  wire s_ahb_hready_in;
  wire s_ahb_hready_out;
  wire s_ahb_hresetn;
  wire s_ahb_hresp;
  wire s_ahb_hsel;
  wire [2:0]s_ahb_hsize;
  wire [1:0]s_ahb_htrans;
  wire [63:0]s_ahb_hwdata;
  wire s_ahb_hwrite;
  wire set_axi_waddr;
  wire set_hresp_err;
  wire [3:1]valid_cnt_required;

  assign m_axi_arcache[3] = \<const0> ;
  assign m_axi_arcache[2] = \<const0> ;
  assign m_axi_arcache[1:0] = \^m_axi_arcache [1:0];
  assign m_axi_arid[3] = \<const0> ;
  assign m_axi_arid[2] = \<const0> ;
  assign m_axi_arid[1] = \<const0> ;
  assign m_axi_arid[0] = \<const0> ;
  assign m_axi_arlen[7] = \<const0> ;
  assign m_axi_arlen[6] = \<const0> ;
  assign m_axi_arlen[5] = \<const0> ;
  assign m_axi_arlen[4] = \<const0> ;
  assign m_axi_arlen[3:2] = \^m_axi_arlen [3:2];
  assign m_axi_arlen[1] = \^m_axi_awlen [0];
  assign m_axi_arlen[0] = \^m_axi_awlen [0];
  assign m_axi_arlock = \<const0> ;
  assign m_axi_awaddr[31:0] = m_axi_araddr;
  assign m_axi_awburst[1:0] = m_axi_arburst;
  assign m_axi_awcache[3] = \<const0> ;
  assign m_axi_awcache[2] = \<const0> ;
  assign m_axi_awcache[1:0] = \^m_axi_arcache [1:0];
  assign m_axi_awid[3] = \<const0> ;
  assign m_axi_awid[2] = \<const0> ;
  assign m_axi_awid[1] = \<const0> ;
  assign m_axi_awid[0] = \<const0> ;
  assign m_axi_awlen[7] = \<const0> ;
  assign m_axi_awlen[6] = \<const0> ;
  assign m_axi_awlen[5] = \<const0> ;
  assign m_axi_awlen[4] = \<const0> ;
  assign m_axi_awlen[3:2] = \^m_axi_arlen [3:2];
  assign m_axi_awlen[1] = \^m_axi_awlen [0];
  assign m_axi_awlen[0] = \^m_axi_awlen [0];
  assign m_axi_awlock = \<const0> ;
  assign m_axi_awprot[2:0] = m_axi_arprot;
  assign m_axi_awsize[2:0] = m_axi_arsize;
  assign m_axi_wstrb[7] = \^m_axi_wstrb [6];
  assign m_axi_wstrb[6] = \^m_axi_wstrb [6];
  assign m_axi_wstrb[5] = \^m_axi_wstrb [6];
  assign m_axi_wstrb[4] = \^m_axi_wstrb [6];
  assign m_axi_wstrb[3] = \^m_axi_wstrb [6];
  assign m_axi_wstrb[2] = \^m_axi_wstrb [6];
  assign m_axi_wstrb[1] = \^m_axi_wstrb [6];
  assign m_axi_wstrb[0] = \^m_axi_wstrb [6];
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_control AHBLITE_AXI_CONTROL
       (.D({AHB_IF_n_14,AHB_IF_n_15,AHB_IF_n_16}),
        .E(burst_term_txer_cnt_i0),
        .\FSM_onehot_ctl_sm_cs_reg[0]_0 (AHB_IF_n_17),
        .\FSM_onehot_ctl_sm_cs_reg[0]_1 (m_axi_wlast),
        .\FSM_onehot_ctl_sm_cs_reg[0]_2 (AXI_RCHANNEL_n_4),
        .\FSM_onehot_ctl_sm_cs_reg[0]_3 (AXI_RCHANNEL_n_7),
        .\FSM_onehot_ctl_sm_cs_reg[2]_0 (AHBLITE_AXI_CONTROL_n_14),
        .\FSM_onehot_ctl_sm_cs_reg[3]_0 (AHBLITE_AXI_CONTROL_n_8),
        .\FSM_onehot_ctl_sm_cs_reg[4]_0 (AHBLITE_AXI_CONTROL_n_13),
        .\FSM_onehot_ctl_sm_cs_reg[4]_1 (AHBLITE_AXI_CONTROL_n_15),
        .M_AXI_RREADY_i_reg(AXI_RCHANNEL_n_10),
        .Q({AHBLITE_AXI_CONTROL_n_1,AHBLITE_AXI_CONTROL_n_2,AHBLITE_AXI_CONTROL_n_3,core_is_idle}),
        .SS(cntr_rst),
        .S_AHB_HREADY_OUT_i_i_6(AXI_WCHANNEL_n_12),
        .S_AHB_HREADY_OUT_i_i_6_0(AHB_IF_n_25),
        .S_AHB_HRESP_i_reg(AHB_IF_n_18),
        .ahb_hburst_single(ahb_hburst_single),
        .axi_waddr_done_i(axi_waddr_done_i),
        .burst_term(burst_term),
        .burst_term_hwrite(burst_term_hwrite),
        .burst_term_i_reg(AHBLITE_AXI_CONTROL_n_5),
        .burst_term_i_reg_0(AXI_WCHANNEL_n_15),
        .burst_term_i_reg_1(AHB_IF_n_12),
        .burst_term_single_incr(burst_term_single_incr),
        .idle_txfer_pending(idle_txfer_pending),
        .idle_txfer_pending_reg(AHBLITE_AXI_CONTROL_n_6),
        .last_axi_rd_sample(last_axi_rd_sample),
        .m_axi_bready(m_axi_bready),
        .m_axi_bresp(m_axi_bresp[1]),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bvalid_0(AHBLITE_AXI_CONTROL_n_18),
        .m_axi_wready(m_axi_wready),
        .nonseq_detected(nonseq_detected),
        .nonseq_txfer_pending(nonseq_txfer_pending),
        .nonseq_txfer_pending_i_reg(AHB_IF_n_20),
        .p_10_in(p_10_in),
        .s_ahb_hburst(s_ahb_hburst[2:1]),
        .\s_ahb_hburst[2] (AHBLITE_AXI_CONTROL_n_19),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hready_in(s_ahb_hready_in),
        .s_ahb_hresetn(s_ahb_hresetn),
        .s_ahb_hsel(s_ahb_hsel),
        .s_ahb_htrans(s_ahb_htrans),
        .\s_ahb_htrans[0]_0 (AHBLITE_AXI_CONTROL_n_20),
        .\s_ahb_htrans[1]_0 (AHBLITE_AXI_CONTROL_n_16),
        .s_ahb_htrans_0_sp_1(AHBLITE_AXI_CONTROL_n_9),
        .s_ahb_htrans_1_sp_1(AHBLITE_AXI_CONTROL_n_7),
        .s_ahb_hwrite(s_ahb_hwrite),
        .s_ahb_hwrite_0(AHBLITE_AXI_CONTROL_n_17),
        .set_axi_waddr(set_axi_waddr),
        .set_hresp_err(set_hresp_err));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_data_counter AHB_DATA_COUNTER
       (.E(AHB_IF_n_22),
        .Q({AHB_DATA_COUNTER_n_1,AHB_DATA_COUNTER_n_2,AHB_DATA_COUNTER_n_3,AHB_DATA_COUNTER_n_4,AHB_DATA_COUNTER_n_5}),
        .SS(cntr_rst),
        .ahb_penult_beat_reg(AHB_IF_n_20),
        .ahb_penult_beat_reg_0(AHB_IF_n_5),
        .ahb_penult_beat_reg_1(valid_cnt_required),
        .nonseq_detected(nonseq_detected),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hresetn(s_ahb_hresetn),
        .s_ahb_htrans(s_ahb_htrans),
        .s_ahb_htrans_0_sp_1(AHB_DATA_COUNTER_n_0));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_if AHB_IF
       (.D({AHB_IF_n_14,AHB_IF_n_15,AHB_IF_n_16}),
        .E(AHB_IF_n_22),
        .\FSM_onehot_ctl_sm_cs_reg[0] (AXI_RCHANNEL_n_7),
        .\FSM_onehot_ctl_sm_cs_reg[0]_0 (AHBLITE_AXI_CONTROL_n_15),
        .\INFERRED_GEN.icount_out_reg[0] (AHB_IF_n_27),
        .\INFERRED_GEN.icount_out_reg[0]_0 (AHB_IF_n_29),
        .\INFERRED_GEN.icount_out_reg[4] (AHB_IF_n_28),
        .M_AXI_ARVALID_i_reg(m_axi_arvalid),
        .M_AXI_WVALID_i_reg(AXI_WCHANNEL_n_13),
        .M_AXI_WVALID_i_reg_0(axi_waddr_done_i),
        .\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0 ({AXI_WCHANNEL_n_7,AXI_WCHANNEL_n_8,AXI_WCHANNEL_n_9,AXI_WCHANNEL_n_10,AXI_WCHANNEL_n_11}),
        .Q({AHBLITE_AXI_CONTROL_n_1,AHBLITE_AXI_CONTROL_n_2,AHBLITE_AXI_CONTROL_n_3,core_is_idle}),
        .SS(cntr_rst),
        .\S_AHB_HRDATA_i_reg[63]_0 (rd_load_timeout_cntr),
        .S_AHB_HREADY_OUT_i_reg_0(AHBLITE_AXI_CONTROL_n_14),
        .S_AHB_HREADY_OUT_i_reg_1(AXI_RCHANNEL_n_6),
        .S_AHB_HREADY_OUT_i_reg_2(AHBLITE_AXI_CONTROL_n_13),
        .S_AHB_HREADY_OUT_i_reg_3(AXI_RCHANNEL_n_8),
        .S_AHB_HREADY_OUT_i_reg_4(AHBLITE_AXI_CONTROL_n_20),
        .S_AHB_HRESP_i_reg_0(AXI_RCHANNEL_n_4),
        .ahb_data_valid(ahb_data_valid),
        .ahb_data_valid_burst_term(ahb_data_valid_burst_term),
        .ahb_data_valid_i_reg_0(AXI_WCHANNEL_n_14),
        .ahb_done_axi_in_progress_reg_0(m_axi_wlast),
        .ahb_done_axi_in_progress_reg_1(AXI_RCHANNEL_n_2),
        .ahb_hburst_incr_i_reg_0(AHB_IF_n_17),
        .ahb_hburst_incr_i_reg_1(AHB_IF_n_23),
        .ahb_hburst_incr_i_reg_2(AHB_IF_n_25),
        .ahb_hburst_single(ahb_hburst_single),
        .ahb_penult_beat_reg_0(AHB_IF_n_5),
        .ahb_penult_beat_reg_1(AHB_DATA_COUNTER_n_0),
        .ahb_wnr_i_reg(AHBLITE_AXI_CONTROL_n_8),
        .ahb_wnr_i_reg_0(AXI_RCHANNEL_n_3),
        .burst_term(burst_term),
        .\burst_term_cur_cnt_i_reg[0]_0 (AHB_IF_n_35),
        .\burst_term_cur_cnt_i_reg[4]_0 (burst_term_cur_cnt),
        .\burst_term_cur_cnt_i_reg[4]_1 ({AHB_DATA_COUNTER_n_1,AHB_DATA_COUNTER_n_2,AHB_DATA_COUNTER_n_3,AHB_DATA_COUNTER_n_4,AHB_DATA_COUNTER_n_5}),
        .burst_term_hwrite(burst_term_hwrite),
        .burst_term_hwrite_reg_0(AHBLITE_AXI_CONTROL_n_17),
        .burst_term_i_reg_0(AHBLITE_AXI_CONTROL_n_5),
        .burst_term_single_incr(burst_term_single_incr),
        .burst_term_single_incr_reg_0(AHBLITE_AXI_CONTROL_n_19),
        .\burst_term_txer_cnt_i_reg[2]_0 (AHB_IF_n_26),
        .\burst_term_txer_cnt_i_reg[3]_0 (burst_term_txer_cnt_i0),
        .dummy_txfer_in_progress_reg_0(AHB_IF_n_12),
        .dummy_txfer_in_progress_reg_1(AHBLITE_AXI_CONTROL_n_6),
        .idle_txfer_pending(idle_txfer_pending),
        .idle_txfer_pending_reg_0(AHBLITE_AXI_CONTROL_n_7),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arcache(\^m_axi_arcache ),
        .m_axi_arlen({\^m_axi_arlen ,\^m_axi_awlen }),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arready(m_axi_arready),
        .m_axi_arready_0(AHB_IF_n_39),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_awready(m_axi_awready),
        .m_axi_awready_0(AHB_IF_n_37),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_bresp(m_axi_bresp[1]),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_wready(m_axi_wready),
        .m_axi_wready_0(AHB_IF_n_24),
        .nonseq_detected(nonseq_detected),
        .nonseq_txfer_pending(nonseq_txfer_pending),
        .nonseq_txfer_pending_i_reg_0(AHB_IF_n_18),
        .nonseq_txfer_pending_i_reg_1(AHB_IF_n_38),
        .nonseq_txfer_pending_i_reg_2(AHBLITE_AXI_CONTROL_n_16),
        .p_10_in(p_10_in),
        .s_ahb_haddr(s_ahb_haddr),
        .s_ahb_hburst(s_ahb_hburst),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hprot(s_ahb_hprot),
        .s_ahb_hrdata(s_ahb_hrdata),
        .s_ahb_hready_in(s_ahb_hready_in),
        .s_ahb_hready_in_0(AHB_IF_n_36),
        .s_ahb_hready_out(s_ahb_hready_out),
        .s_ahb_hresetn(s_ahb_hresetn),
        .s_ahb_hresp(s_ahb_hresp),
        .s_ahb_hsel(s_ahb_hsel),
        .s_ahb_hsel_0(AHB_IF_n_20),
        .s_ahb_hsize(s_ahb_hsize),
        .s_ahb_htrans(s_ahb_htrans),
        .s_ahb_hwrite(s_ahb_hwrite),
        .set_axi_waddr(set_axi_waddr),
        .set_hresp_err(set_hresp_err),
        .\valid_cnt_required_i_reg[3]_0 (valid_cnt_required));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_rchannel AXI_RCHANNEL
       (.\FSM_onehot_ctl_sm_cs_reg[5] (AXI_RCHANNEL_n_3),
        .\FSM_onehot_ctl_sm_cs_reg[5]_0 (AXI_RCHANNEL_n_6),
        .M_AXI_ARVALID_i_reg_0(m_axi_arvalid),
        .M_AXI_ARVALID_i_reg_1(AHB_IF_n_39),
        .M_AXI_RREADY_i_reg_0(m_axi_rready),
        .M_AXI_RREADY_i_reg_1(rd_load_timeout_cntr),
        .M_AXI_RREADY_i_reg_2(AHBLITE_AXI_CONTROL_n_9),
        .Q(AHBLITE_AXI_CONTROL_n_1),
        .SS(cntr_rst),
        .ahb_rd_req_reg_0(AXI_RCHANNEL_n_8),
        .ahb_rd_txer_pending_reg_0(AXI_RCHANNEL_n_4),
        .ahb_rd_txer_pending_reg_1(AHB_IF_n_36),
        .axi_rd_avlbl_reg_0(AXI_RCHANNEL_n_10),
        .\axi_rresp_avlbl_reg[1]_0 (AHB_IF_n_20),
        .idle_txfer_pending(idle_txfer_pending),
        .last_axi_rd_sample(last_axi_rd_sample),
        .m_axi_arready(m_axi_arready),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rresp(m_axi_rresp[1]),
        .\m_axi_rresp[1] (AXI_RCHANNEL_n_7),
        .m_axi_rvalid(m_axi_rvalid),
        .nonseq_detected(nonseq_detected),
        .nonseq_txfer_pending(nonseq_txfer_pending),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hready_in(s_ahb_hready_in),
        .s_ahb_hresetn(s_ahb_hresetn),
        .s_ahb_hsel(s_ahb_hsel),
        .s_ahb_htrans(s_ahb_htrans),
        .s_ahb_htrans_1_sp_1(AXI_RCHANNEL_n_2));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_wchannel AXI_WCHANNEL
       (.D(valid_cnt_required),
        .E(axi_waddr_done_i),
        .M_AXI_AWVALID_i_reg_0(AHB_IF_n_37),
        .M_AXI_BREADY_i_reg_0(AHBLITE_AXI_CONTROL_n_18),
        .M_AXI_WLAST_i_reg_0(m_axi_wlast),
        .M_AXI_WLAST_i_reg_1(AHB_IF_n_24),
        .M_AXI_WVALID_i_reg_0(m_axi_wvalid),
        .M_AXI_WVALID_i_reg_1(AHB_IF_n_23),
        .\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2 (burst_term_cur_cnt),
        .\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 (AHB_IF_n_35),
        .\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0 (AHB_IF_n_29),
        .Q({AXI_WCHANNEL_n_7,AXI_WCHANNEL_n_8,AXI_WCHANNEL_n_9,AXI_WCHANNEL_n_10,AXI_WCHANNEL_n_11}),
        .SS(cntr_rst),
        .ahb_data_valid(ahb_data_valid),
        .ahb_data_valid_burst_term(ahb_data_valid_burst_term),
        .ahb_data_valid_burst_term_reg_0(AHB_IF_n_38),
        .axi_last_beat_reg_0(AHB_IF_n_27),
        .axi_penult_beat_reg_0(AHB_IF_n_26),
        .axi_penult_beat_reg_1(AHB_IF_n_28),
        .burst_term(burst_term),
        .local_en_reg_0(AXI_WCHANNEL_n_13),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_bready(m_axi_bready),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wready(m_axi_wready),
        .m_axi_wready_0(AXI_WCHANNEL_n_12),
        .m_axi_wready_1(AXI_WCHANNEL_n_15),
        .m_axi_wstrb(\^m_axi_wstrb ),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hready_in(s_ahb_hready_in),
        .s_ahb_hresetn(s_ahb_hresetn),
        .s_ahb_hsel(s_ahb_hsel),
        .s_ahb_htrans(s_ahb_htrans[1]),
        .\s_ahb_htrans[1] (AXI_WCHANNEL_n_14),
        .s_ahb_hwdata(s_ahb_hwdata),
        .set_axi_waddr(set_axi_waddr));
  GND GND
       (.G(\<const0> ));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_control
   (axi_waddr_done_i,
    Q,
    burst_term_i_reg,
    idle_txfer_pending_reg,
    s_ahb_htrans_1_sp_1,
    \FSM_onehot_ctl_sm_cs_reg[3]_0 ,
    s_ahb_htrans_0_sp_1,
    set_hresp_err,
    p_10_in,
    E,
    \FSM_onehot_ctl_sm_cs_reg[4]_0 ,
    \FSM_onehot_ctl_sm_cs_reg[2]_0 ,
    \FSM_onehot_ctl_sm_cs_reg[4]_1 ,
    \s_ahb_htrans[1]_0 ,
    s_ahb_hwrite_0,
    m_axi_bvalid_0,
    \s_ahb_hburst[2] ,
    \s_ahb_htrans[0]_0 ,
    SS,
    set_axi_waddr,
    s_ahb_hclk,
    last_axi_rd_sample,
    \FSM_onehot_ctl_sm_cs_reg[0]_0 ,
    \FSM_onehot_ctl_sm_cs_reg[0]_1 ,
    m_axi_wready,
    burst_term_i_reg_0,
    burst_term,
    burst_term_i_reg_1,
    s_ahb_htrans,
    idle_txfer_pending,
    s_ahb_hresetn,
    nonseq_detected,
    nonseq_txfer_pending,
    \FSM_onehot_ctl_sm_cs_reg[0]_2 ,
    m_axi_bvalid,
    D,
    M_AXI_RREADY_i_reg,
    nonseq_txfer_pending_i_reg,
    S_AHB_HRESP_i_reg,
    m_axi_bresp,
    \FSM_onehot_ctl_sm_cs_reg[0]_3 ,
    s_ahb_hsel,
    s_ahb_hready_in,
    ahb_hburst_single,
    S_AHB_HREADY_OUT_i_i_6,
    s_ahb_hwrite,
    S_AHB_HREADY_OUT_i_i_6_0,
    burst_term_hwrite,
    m_axi_bready,
    s_ahb_hburst,
    burst_term_single_incr);
  output axi_waddr_done_i;
  output [3:0]Q;
  output burst_term_i_reg;
  output idle_txfer_pending_reg;
  output s_ahb_htrans_1_sp_1;
  output \FSM_onehot_ctl_sm_cs_reg[3]_0 ;
  output s_ahb_htrans_0_sp_1;
  output set_hresp_err;
  output p_10_in;
  output [0:0]E;
  output \FSM_onehot_ctl_sm_cs_reg[4]_0 ;
  output \FSM_onehot_ctl_sm_cs_reg[2]_0 ;
  output \FSM_onehot_ctl_sm_cs_reg[4]_1 ;
  output \s_ahb_htrans[1]_0 ;
  output s_ahb_hwrite_0;
  output m_axi_bvalid_0;
  output \s_ahb_hburst[2] ;
  output \s_ahb_htrans[0]_0 ;
  input [0:0]SS;
  input set_axi_waddr;
  input s_ahb_hclk;
  input last_axi_rd_sample;
  input \FSM_onehot_ctl_sm_cs_reg[0]_0 ;
  input \FSM_onehot_ctl_sm_cs_reg[0]_1 ;
  input m_axi_wready;
  input burst_term_i_reg_0;
  input burst_term;
  input burst_term_i_reg_1;
  input [1:0]s_ahb_htrans;
  input idle_txfer_pending;
  input s_ahb_hresetn;
  input nonseq_detected;
  input nonseq_txfer_pending;
  input \FSM_onehot_ctl_sm_cs_reg[0]_2 ;
  input m_axi_bvalid;
  input [2:0]D;
  input M_AXI_RREADY_i_reg;
  input nonseq_txfer_pending_i_reg;
  input S_AHB_HRESP_i_reg;
  input [0:0]m_axi_bresp;
  input \FSM_onehot_ctl_sm_cs_reg[0]_3 ;
  input s_ahb_hsel;
  input s_ahb_hready_in;
  input ahb_hburst_single;
  input S_AHB_HREADY_OUT_i_i_6;
  input s_ahb_hwrite;
  input S_AHB_HREADY_OUT_i_i_6_0;
  input burst_term_hwrite;
  input m_axi_bready;
  input [1:0]s_ahb_hburst;
  input burst_term_single_incr;

  wire [2:0]D;
  wire [0:0]E;
  wire \FSM_onehot_ctl_sm_cs[1]_i_1_n_0 ;
  wire \FSM_onehot_ctl_sm_cs[2]_i_1_n_0 ;
  wire \FSM_onehot_ctl_sm_cs[5]_i_1_n_0 ;
  wire \FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ;
  wire \FSM_onehot_ctl_sm_cs[6]_i_3_n_0 ;
  wire \FSM_onehot_ctl_sm_cs[6]_i_5_n_0 ;
  wire \FSM_onehot_ctl_sm_cs_reg[0]_0 ;
  wire \FSM_onehot_ctl_sm_cs_reg[0]_1 ;
  wire \FSM_onehot_ctl_sm_cs_reg[0]_2 ;
  wire \FSM_onehot_ctl_sm_cs_reg[0]_3 ;
  wire \FSM_onehot_ctl_sm_cs_reg[2]_0 ;
  wire \FSM_onehot_ctl_sm_cs_reg[3]_0 ;
  wire \FSM_onehot_ctl_sm_cs_reg[4]_0 ;
  wire \FSM_onehot_ctl_sm_cs_reg[4]_1 ;
  wire \FSM_onehot_ctl_sm_cs_reg_n_0_[1] ;
  wire \FSM_onehot_ctl_sm_cs_reg_n_0_[4] ;
  wire \FSM_onehot_ctl_sm_cs_reg_n_0_[6] ;
  wire M_AXI_RLAST_reg;
  wire M_AXI_RREADY_i_reg;
  wire [3:0]Q;
  wire [0:0]SS;
  wire S_AHB_HREADY_OUT_i_i_6;
  wire S_AHB_HREADY_OUT_i_i_6_0;
  wire S_AHB_HRESP_i_reg;
  wire ahb_hburst_single;
  wire axi_waddr_done_i;
  wire burst_term;
  wire burst_term_hwrite;
  wire burst_term_i_reg;
  wire burst_term_i_reg_0;
  wire burst_term_i_reg_1;
  wire burst_term_single_incr;
  wire idle_txfer_pending;
  wire idle_txfer_pending_i_2_n_0;
  wire idle_txfer_pending_reg;
  wire last_axi_rd_sample;
  wire m_axi_bready;
  wire [0:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire m_axi_bvalid_0;
  wire m_axi_wready;
  wire nonseq_detected;
  wire nonseq_txfer_pending;
  wire nonseq_txfer_pending_i_reg;
  wire p_10_in;
  wire [1:0]s_ahb_hburst;
  wire \s_ahb_hburst[2] ;
  wire s_ahb_hclk;
  wire s_ahb_hready_in;
  wire s_ahb_hresetn;
  wire s_ahb_hsel;
  wire [1:0]s_ahb_htrans;
  wire \s_ahb_htrans[0]_0 ;
  wire \s_ahb_htrans[1]_0 ;
  wire s_ahb_htrans_0_sn_1;
  wire s_ahb_htrans_1_sn_1;
  wire s_ahb_hwrite;
  wire s_ahb_hwrite_0;
  wire set_axi_waddr;
  wire set_hresp_err;

  assign s_ahb_htrans_0_sp_1 = s_ahb_htrans_0_sn_1;
  assign s_ahb_htrans_1_sp_1 = s_ahb_htrans_1_sn_1;
  LUT3 #(
    .INIT(8'hEA)) 
    \FSM_onehot_ctl_sm_cs[0]_i_3 
       (.I0(\FSM_onehot_ctl_sm_cs_reg_n_0_[4] ),
        .I1(M_AXI_RLAST_reg),
        .I2(\FSM_onehot_ctl_sm_cs_reg_n_0_[6] ),
        .O(\FSM_onehot_ctl_sm_cs_reg[4]_1 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFF08880)) 
    \FSM_onehot_ctl_sm_cs[1]_i_1 
       (.I0(m_axi_bvalid),
        .I1(Q[2]),
        .I2(nonseq_txfer_pending),
        .I3(nonseq_detected),
        .I4(Q[3]),
        .I5(Q[0]),
        .O(\FSM_onehot_ctl_sm_cs[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_onehot_ctl_sm_cs[2]_i_1 
       (.I0(\FSM_onehot_ctl_sm_cs_reg_n_0_[1] ),
        .I1(axi_waddr_done_i),
        .O(\FSM_onehot_ctl_sm_cs[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h4F44)) 
    \FSM_onehot_ctl_sm_cs[5]_i_1 
       (.I0(axi_waddr_done_i),
        .I1(\FSM_onehot_ctl_sm_cs_reg_n_0_[1] ),
        .I2(M_AXI_RLAST_reg),
        .I3(\FSM_onehot_ctl_sm_cs_reg_n_0_[6] ),
        .O(\FSM_onehot_ctl_sm_cs[5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFBBBBBBB)) 
    \FSM_onehot_ctl_sm_cs[6]_i_1 
       (.I0(\FSM_onehot_ctl_sm_cs[6]_i_3_n_0 ),
        .I1(\FSM_onehot_ctl_sm_cs_reg[0]_0 ),
        .I2(\FSM_onehot_ctl_sm_cs_reg[0]_1 ),
        .I3(m_axi_wready),
        .I4(Q[1]),
        .I5(\FSM_onehot_ctl_sm_cs[6]_i_5_n_0 ),
        .O(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFF1000)) 
    \FSM_onehot_ctl_sm_cs[6]_i_3 
       (.I0(S_AHB_HRESP_i_reg),
        .I1(idle_txfer_pending),
        .I2(Q[3]),
        .I3(\FSM_onehot_ctl_sm_cs_reg[0]_3 ),
        .I4(\FSM_onehot_ctl_sm_cs_reg_n_0_[6] ),
        .I5(\FSM_onehot_ctl_sm_cs_reg_n_0_[4] ),
        .O(\FSM_onehot_ctl_sm_cs[6]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF888)) 
    \FSM_onehot_ctl_sm_cs[6]_i_5 
       (.I0(\FSM_onehot_ctl_sm_cs_reg[0]_2 ),
        .I1(Q[3]),
        .I2(m_axi_bvalid),
        .I3(Q[2]),
        .I4(\FSM_onehot_ctl_sm_cs_reg_n_0_[1] ),
        .O(\FSM_onehot_ctl_sm_cs[6]_i_5_n_0 ));
  (* FSM_ENCODED_STATES = "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000" *) 
  FDSE #(
    .INIT(1'b1)) 
    \FSM_onehot_ctl_sm_cs_reg[0] 
       (.C(s_ahb_hclk),
        .CE(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ),
        .D(D[0]),
        .Q(Q[0]),
        .S(SS));
  (* FSM_ENCODED_STATES = "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_ctl_sm_cs_reg[1] 
       (.C(s_ahb_hclk),
        .CE(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ),
        .D(\FSM_onehot_ctl_sm_cs[1]_i_1_n_0 ),
        .Q(\FSM_onehot_ctl_sm_cs_reg_n_0_[1] ),
        .R(SS));
  (* FSM_ENCODED_STATES = "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_ctl_sm_cs_reg[2] 
       (.C(s_ahb_hclk),
        .CE(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ),
        .D(\FSM_onehot_ctl_sm_cs[2]_i_1_n_0 ),
        .Q(Q[1]),
        .R(SS));
  (* FSM_ENCODED_STATES = "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_ctl_sm_cs_reg[3] 
       (.C(s_ahb_hclk),
        .CE(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ),
        .D(Q[1]),
        .Q(Q[2]),
        .R(SS));
  (* FSM_ENCODED_STATES = "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_ctl_sm_cs_reg[4] 
       (.C(s_ahb_hclk),
        .CE(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ),
        .D(D[1]),
        .Q(\FSM_onehot_ctl_sm_cs_reg_n_0_[4] ),
        .R(SS));
  (* FSM_ENCODED_STATES = "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_ctl_sm_cs_reg[5] 
       (.C(s_ahb_hclk),
        .CE(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ),
        .D(\FSM_onehot_ctl_sm_cs[5]_i_1_n_0 ),
        .Q(Q[3]),
        .R(SS));
  (* FSM_ENCODED_STATES = "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_onehot_ctl_sm_cs_reg[6] 
       (.C(s_ahb_hclk),
        .CE(\FSM_onehot_ctl_sm_cs[6]_i_1_n_0 ),
        .D(D[2]),
        .Q(\FSM_onehot_ctl_sm_cs_reg_n_0_[6] ),
        .R(SS));
  LUT3 #(
    .INIT(8'hDC)) 
    M_AXI_BREADY_i_i_1
       (.I0(m_axi_bvalid),
        .I1(axi_waddr_done_i),
        .I2(m_axi_bready),
        .O(m_axi_bvalid_0));
  FDRE M_AXI_RLAST_reg_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(last_axi_rd_sample),
        .Q(M_AXI_RLAST_reg),
        .R(SS));
  LUT6 #(
    .INIT(64'hFEFEFEFEFEFFFEFE)) 
    M_AXI_RREADY_i_i_2
       (.I0(\FSM_onehot_ctl_sm_cs[6]_i_3_n_0 ),
        .I1(D[1]),
        .I2(M_AXI_RREADY_i_reg),
        .I3(nonseq_txfer_pending_i_reg),
        .I4(s_ahb_htrans[0]),
        .I5(s_ahb_htrans[1]),
        .O(s_ahb_htrans_0_sn_1));
  LUT6 #(
    .INIT(64'hFF4FCC44CC44CC44)) 
    S_AHB_HREADY_OUT_i_i_12
       (.I0(S_AHB_HREADY_OUT_i_i_6),
        .I1(Q[1]),
        .I2(s_ahb_hwrite),
        .I3(S_AHB_HREADY_OUT_i_i_6_0),
        .I4(\FSM_onehot_ctl_sm_cs_reg_n_0_[1] ),
        .I5(axi_waddr_done_i),
        .O(\FSM_onehot_ctl_sm_cs_reg[2]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00001000)) 
    S_AHB_HREADY_OUT_i_i_5
       (.I0(s_ahb_htrans[0]),
        .I1(Q[0]),
        .I2(s_ahb_hsel),
        .I3(s_ahb_hready_in),
        .I4(s_ahb_htrans[1]),
        .O(p_10_in));
  LUT6 #(
    .INIT(64'hFEFFFEFEFEFEFEFE)) 
    S_AHB_HREADY_OUT_i_i_8
       (.I0(\FSM_onehot_ctl_sm_cs_reg_n_0_[4] ),
        .I1(\FSM_onehot_ctl_sm_cs_reg_n_0_[6] ),
        .I2(\FSM_onehot_ctl_sm_cs[2]_i_1_n_0 ),
        .I3(ahb_hburst_single),
        .I4(Q[1]),
        .I5(S_AHB_HREADY_OUT_i_i_6),
        .O(\FSM_onehot_ctl_sm_cs_reg[4]_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00002000)) 
    S_AHB_HRESP_i_i_2
       (.I0(Q[2]),
        .I1(S_AHB_HRESP_i_reg),
        .I2(m_axi_bvalid),
        .I3(m_axi_bresp),
        .I4(idle_txfer_pending),
        .I5(\FSM_onehot_ctl_sm_cs[6]_i_3_n_0 ),
        .O(set_hresp_err));
  LUT4 #(
    .INIT(16'h8880)) 
    ahb_wnr_i_i_2
       (.I0(Q[2]),
        .I1(m_axi_bvalid),
        .I2(nonseq_txfer_pending),
        .I3(nonseq_detected),
        .O(\FSM_onehot_ctl_sm_cs_reg[3]_0 ));
  FDRE ahb_wnr_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(set_axi_waddr),
        .Q(axi_waddr_done_i),
        .R(SS));
  LUT6 #(
    .INIT(64'hFFFEFFFF00020000)) 
    burst_term_hwrite_i_1
       (.I0(s_ahb_hwrite),
        .I1(s_ahb_htrans[0]),
        .I2(Q[0]),
        .I3(nonseq_txfer_pending_i_reg),
        .I4(s_ahb_htrans[1]),
        .I5(burst_term_hwrite),
        .O(s_ahb_hwrite_0));
  LUT6 #(
    .INIT(64'h0000000000001130)) 
    burst_term_i_i_1
       (.I0(idle_txfer_pending_reg),
        .I1(burst_term_i_reg_0),
        .I2(idle_txfer_pending_i_2_n_0),
        .I3(burst_term),
        .I4(burst_term_i_reg_1),
        .I5(last_axi_rd_sample),
        .O(burst_term_i_reg));
  LUT4 #(
    .INIT(16'hFF10)) 
    burst_term_single_incr_i_1
       (.I0(s_ahb_hburst[1]),
        .I1(s_ahb_hburst[0]),
        .I2(\s_ahb_htrans[0]_0 ),
        .I3(burst_term_single_incr),
        .O(\s_ahb_hburst[2] ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h10000000)) 
    burst_term_single_incr_i_2
       (.I0(s_ahb_htrans[0]),
        .I1(Q[0]),
        .I2(s_ahb_hsel),
        .I3(s_ahb_hready_in),
        .I4(s_ahb_htrans[1]),
        .O(\s_ahb_htrans[0]_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h00001000)) 
    \burst_term_txer_cnt_i[3]_i_1 
       (.I0(s_ahb_htrans[0]),
        .I1(Q[0]),
        .I2(s_ahb_hsel),
        .I3(s_ahb_hready_in),
        .I4(burst_term),
        .O(E));
  LUT5 #(
    .INIT(32'h0000F400)) 
    idle_txfer_pending_i_1
       (.I0(s_ahb_htrans[1]),
        .I1(idle_txfer_pending_i_2_n_0),
        .I2(idle_txfer_pending),
        .I3(s_ahb_hresetn),
        .I4(idle_txfer_pending_reg),
        .O(s_ahb_htrans_1_sn_1));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    idle_txfer_pending_i_2
       (.I0(s_ahb_hready_in),
        .I1(s_ahb_hsel),
        .I2(Q[0]),
        .I3(s_ahb_htrans[0]),
        .O(idle_txfer_pending_i_2_n_0));
  LUT5 #(
    .INIT(32'hAAAAAAA8)) 
    idle_txfer_pending_i_3
       (.I0(\FSM_onehot_ctl_sm_cs[6]_i_5_n_0 ),
        .I1(idle_txfer_pending),
        .I2(nonseq_detected),
        .I3(nonseq_txfer_pending),
        .I4(\FSM_onehot_ctl_sm_cs_reg_n_0_[1] ),
        .O(idle_txfer_pending_reg));
  LUT6 #(
    .INIT(64'h0002FFFF00020002)) 
    nonseq_txfer_pending_i_i_1
       (.I0(s_ahb_htrans[1]),
        .I1(nonseq_txfer_pending_i_reg),
        .I2(Q[0]),
        .I3(s_ahb_htrans[0]),
        .I4(idle_txfer_pending_reg),
        .I5(nonseq_txfer_pending),
        .O(\s_ahb_htrans[1]_0 ));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_rchannel
   (M_AXI_ARVALID_i_reg_0,
    M_AXI_RREADY_i_reg_0,
    s_ahb_htrans_1_sp_1,
    \FSM_onehot_ctl_sm_cs_reg[5] ,
    ahb_rd_txer_pending_reg_0,
    last_axi_rd_sample,
    \FSM_onehot_ctl_sm_cs_reg[5]_0 ,
    \m_axi_rresp[1] ,
    ahb_rd_req_reg_0,
    M_AXI_RREADY_i_reg_1,
    axi_rd_avlbl_reg_0,
    s_ahb_hclk,
    SS,
    m_axi_rresp,
    m_axi_rlast,
    M_AXI_ARVALID_i_reg_1,
    s_ahb_hresetn,
    Q,
    nonseq_txfer_pending,
    nonseq_detected,
    ahb_rd_txer_pending_reg_1,
    m_axi_rvalid,
    idle_txfer_pending,
    s_ahb_htrans,
    s_ahb_hready_in,
    s_ahb_hsel,
    M_AXI_RREADY_i_reg_2,
    m_axi_arready,
    \axi_rresp_avlbl_reg[1]_0 );
  output M_AXI_ARVALID_i_reg_0;
  output M_AXI_RREADY_i_reg_0;
  output s_ahb_htrans_1_sp_1;
  output \FSM_onehot_ctl_sm_cs_reg[5] ;
  output ahb_rd_txer_pending_reg_0;
  output last_axi_rd_sample;
  output \FSM_onehot_ctl_sm_cs_reg[5]_0 ;
  output \m_axi_rresp[1] ;
  output ahb_rd_req_reg_0;
  output [0:0]M_AXI_RREADY_i_reg_1;
  output axi_rd_avlbl_reg_0;
  input s_ahb_hclk;
  input [0:0]SS;
  input [0:0]m_axi_rresp;
  input m_axi_rlast;
  input M_AXI_ARVALID_i_reg_1;
  input s_ahb_hresetn;
  input [0:0]Q;
  input nonseq_txfer_pending;
  input nonseq_detected;
  input ahb_rd_txer_pending_reg_1;
  input m_axi_rvalid;
  input idle_txfer_pending;
  input [1:0]s_ahb_htrans;
  input s_ahb_hready_in;
  input s_ahb_hsel;
  input M_AXI_RREADY_i_reg_2;
  input m_axi_arready;
  input \axi_rresp_avlbl_reg[1]_0 ;

  wire \FSM_onehot_ctl_sm_cs[6]_i_7_n_0 ;
  wire \FSM_onehot_ctl_sm_cs[6]_i_8_n_0 ;
  wire \FSM_onehot_ctl_sm_cs_reg[5] ;
  wire \FSM_onehot_ctl_sm_cs_reg[5]_0 ;
  wire M_AXI_ARVALID_i_reg_0;
  wire M_AXI_ARVALID_i_reg_1;
  wire M_AXI_RREADY_i_i_1_n_0;
  wire M_AXI_RREADY_i_reg_0;
  wire [0:0]M_AXI_RREADY_i_reg_1;
  wire M_AXI_RREADY_i_reg_2;
  wire [0:0]Q;
  wire [0:0]SS;
  wire ahb_rd_req;
  wire ahb_rd_req_i_1_n_0;
  wire ahb_rd_req_reg_0;
  wire ahb_rd_txer_pending;
  wire ahb_rd_txer_pending_i_1_n_0;
  wire ahb_rd_txer_pending_reg_0;
  wire ahb_rd_txer_pending_reg_1;
  wire axi_last_avlbl;
  wire axi_last_avlbl_reg_n_0;
  wire axi_rd_avlbl;
  wire axi_rd_avlbl_i_2_n_0;
  wire axi_rd_avlbl_reg_0;
  wire [1:1]axi_rresp_avlbl;
  wire \axi_rresp_avlbl_reg[1]_0 ;
  wire bridge_rd_in_progress;
  wire bridge_rd_in_progress_i_1_n_0;
  wire idle_txfer_pending;
  wire last_axi_rd_sample;
  wire m_axi_arready;
  wire m_axi_rlast;
  wire [0:0]m_axi_rresp;
  wire \m_axi_rresp[1] ;
  wire m_axi_rvalid;
  wire nonseq_detected;
  wire nonseq_txfer_pending;
  wire s_ahb_hclk;
  wire s_ahb_hready_in;
  wire s_ahb_hresetn;
  wire s_ahb_hsel;
  wire [1:0]s_ahb_htrans;
  wire s_ahb_htrans_1_sn_1;
  wire seq_detected;
  wire seq_detected_d1;

  assign s_ahb_htrans_1_sp_1 = s_ahb_htrans_1_sn_1;
  LUT6 #(
    .INIT(64'hFB08080808080808)) 
    \FSM_onehot_ctl_sm_cs[6]_i_6 
       (.I0(m_axi_rresp),
        .I1(\FSM_onehot_ctl_sm_cs[6]_i_7_n_0 ),
        .I2(\FSM_onehot_ctl_sm_cs[6]_i_8_n_0 ),
        .I3(axi_rresp_avlbl),
        .I4(ahb_rd_req),
        .I5(axi_rd_avlbl),
        .O(\m_axi_rresp[1] ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT5 #(
    .INIT(32'h45555555)) 
    \FSM_onehot_ctl_sm_cs[6]_i_7 
       (.I0(ahb_rd_txer_pending),
        .I1(s_ahb_htrans[1]),
        .I2(s_ahb_htrans[0]),
        .I3(s_ahb_hsel),
        .I4(s_ahb_hready_in),
        .O(\FSM_onehot_ctl_sm_cs[6]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \FSM_onehot_ctl_sm_cs[6]_i_8 
       (.I0(m_axi_rvalid),
        .I1(M_AXI_RREADY_i_reg_0),
        .O(\FSM_onehot_ctl_sm_cs[6]_i_8_n_0 ));
  FDRE M_AXI_ARVALID_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(M_AXI_ARVALID_i_reg_1),
        .Q(M_AXI_ARVALID_i_reg_0),
        .R(SS));
  LUT4 #(
    .INIT(16'hAAEA)) 
    M_AXI_RLAST_reg_i_1
       (.I0(axi_last_avlbl_reg_n_0),
        .I1(m_axi_rvalid),
        .I2(m_axi_rlast),
        .I3(ahb_rd_txer_pending),
        .O(last_axi_rd_sample));
  LUT6 #(
    .INIT(64'hFF555555FF454545)) 
    M_AXI_RREADY_i_i_1
       (.I0(M_AXI_RREADY_i_reg_2),
        .I1(ahb_rd_txer_pending),
        .I2(s_ahb_htrans_1_sn_1),
        .I3(m_axi_arready),
        .I4(M_AXI_ARVALID_i_reg_0),
        .I5(M_AXI_RREADY_i_reg_0),
        .O(M_AXI_RREADY_i_i_1_n_0));
  LUT4 #(
    .INIT(16'h7FFF)) 
    M_AXI_RREADY_i_i_3
       (.I0(s_ahb_htrans[1]),
        .I1(s_ahb_hsel),
        .I2(s_ahb_hready_in),
        .I3(s_ahb_htrans[0]),
        .O(s_ahb_htrans_1_sn_1));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT5 #(
    .INIT(32'hFAAAEAAA)) 
    M_AXI_RREADY_i_i_4
       (.I0(axi_rd_avlbl),
        .I1(ahb_rd_txer_pending),
        .I2(M_AXI_RREADY_i_reg_0),
        .I3(m_axi_rvalid),
        .I4(m_axi_rlast),
        .O(axi_rd_avlbl_reg_0));
  FDRE M_AXI_RREADY_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(M_AXI_RREADY_i_i_1_n_0),
        .Q(M_AXI_RREADY_i_reg_0),
        .R(SS));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \S_AHB_HRDATA_i[63]_i_1 
       (.I0(M_AXI_RREADY_i_reg_0),
        .I1(m_axi_rvalid),
        .O(M_AXI_RREADY_i_reg_1));
  LUT6 #(
    .INIT(64'h00000000000000E0)) 
    S_AHB_HREADY_OUT_i_i_13
       (.I0(\m_axi_rresp[1] ),
        .I1(ahb_rd_req_reg_0),
        .I2(Q),
        .I3(idle_txfer_pending),
        .I4(nonseq_detected),
        .I5(nonseq_txfer_pending),
        .O(\FSM_onehot_ctl_sm_cs_reg[5]_0 ));
  LUT6 #(
    .INIT(64'h7777777777770777)) 
    S_AHB_HREADY_OUT_i_i_9
       (.I0(ahb_rd_req),
        .I1(axi_rd_avlbl),
        .I2(m_axi_rvalid),
        .I3(M_AXI_RREADY_i_reg_0),
        .I4(ahb_rd_txer_pending),
        .I5(ahb_rd_txer_pending_reg_1),
        .O(ahb_rd_req_reg_0));
  LUT6 #(
    .INIT(64'hAAAA000200020002)) 
    S_AHB_HRESP_i_i_5
       (.I0(last_axi_rd_sample),
        .I1(ahb_rd_txer_pending_reg_1),
        .I2(ahb_rd_txer_pending),
        .I3(\FSM_onehot_ctl_sm_cs[6]_i_8_n_0 ),
        .I4(axi_rd_avlbl),
        .I5(ahb_rd_req),
        .O(ahb_rd_txer_pending_reg_0));
  LUT6 #(
    .INIT(64'h7774000C00000000)) 
    ahb_rd_req_i_1
       (.I0(axi_rd_avlbl),
        .I1(ahb_rd_txer_pending),
        .I2(seq_detected_d1),
        .I3(s_ahb_htrans_1_sn_1),
        .I4(ahb_rd_req),
        .I5(s_ahb_hresetn),
        .O(ahb_rd_req_i_1_n_0));
  FDRE ahb_rd_req_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(ahb_rd_req_i_1_n_0),
        .Q(ahb_rd_req),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h00EAEAEA00000000)) 
    ahb_rd_txer_pending_i_1
       (.I0(ahb_rd_txer_pending),
        .I1(bridge_rd_in_progress),
        .I2(ahb_rd_txer_pending_reg_1),
        .I3(axi_rd_avlbl),
        .I4(ahb_rd_req),
        .I5(s_ahb_hresetn),
        .O(ahb_rd_txer_pending_i_1_n_0));
  FDRE ahb_rd_txer_pending_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(ahb_rd_txer_pending_i_1_n_0),
        .Q(ahb_rd_txer_pending),
        .R(1'b0));
  LUT4 #(
    .INIT(16'h777F)) 
    ahb_wnr_i_i_3
       (.I0(ahb_rd_txer_pending_reg_0),
        .I1(Q),
        .I2(nonseq_txfer_pending),
        .I3(nonseq_detected),
        .O(\FSM_onehot_ctl_sm_cs_reg[5] ));
  FDRE axi_last_avlbl_reg
       (.C(s_ahb_hclk),
        .CE(axi_rd_avlbl_i_2_n_0),
        .D(m_axi_rlast),
        .Q(axi_last_avlbl_reg_n_0),
        .R(axi_last_avlbl));
  LUT3 #(
    .INIT(8'hD5)) 
    axi_rd_avlbl_i_1
       (.I0(s_ahb_hresetn),
        .I1(ahb_rd_req),
        .I2(axi_rd_avlbl),
        .O(axi_last_avlbl));
  LUT6 #(
    .INIT(64'h8888888800000800)) 
    axi_rd_avlbl_i_2
       (.I0(M_AXI_RREADY_i_reg_0),
        .I1(m_axi_rvalid),
        .I2(\axi_rresp_avlbl_reg[1]_0 ),
        .I3(s_ahb_htrans[0]),
        .I4(s_ahb_htrans[1]),
        .I5(ahb_rd_txer_pending),
        .O(axi_rd_avlbl_i_2_n_0));
  FDRE axi_rd_avlbl_reg
       (.C(s_ahb_hclk),
        .CE(axi_rd_avlbl_i_2_n_0),
        .D(axi_rd_avlbl_i_2_n_0),
        .Q(axi_rd_avlbl),
        .R(axi_last_avlbl));
  FDRE \axi_rresp_avlbl_reg[1] 
       (.C(s_ahb_hclk),
        .CE(axi_rd_avlbl_i_2_n_0),
        .D(m_axi_rresp),
        .Q(axi_rresp_avlbl),
        .R(axi_last_avlbl));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT5 #(
    .INIT(32'hBFFFAAAA)) 
    bridge_rd_in_progress_i_1
       (.I0(M_AXI_ARVALID_i_reg_0),
        .I1(m_axi_rvalid),
        .I2(M_AXI_RREADY_i_reg_0),
        .I3(m_axi_rlast),
        .I4(bridge_rd_in_progress),
        .O(bridge_rd_in_progress_i_1_n_0));
  FDRE bridge_rd_in_progress_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(bridge_rd_in_progress_i_1_n_0),
        .Q(bridge_rd_in_progress),
        .R(SS));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    seq_detected_d1_i_1
       (.I0(s_ahb_htrans[0]),
        .I1(s_ahb_hready_in),
        .I2(s_ahb_hsel),
        .I3(s_ahb_htrans[1]),
        .O(seq_detected));
  FDRE seq_detected_d1_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(seq_detected),
        .Q(seq_detected_d1),
        .R(SS));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_wchannel
   (m_axi_wstrb,
    SS,
    m_axi_awvalid,
    M_AXI_WLAST_i_reg_0,
    ahb_data_valid_burst_term,
    M_AXI_WVALID_i_reg_0,
    m_axi_bready,
    Q,
    m_axi_wready_0,
    local_en_reg_0,
    \s_ahb_htrans[1] ,
    m_axi_wready_1,
    m_axi_wdata,
    s_ahb_hclk,
    M_AXI_AWVALID_i_reg_0,
    ahb_data_valid_burst_term_reg_0,
    M_AXI_BREADY_i_reg_0,
    m_axi_wready,
    s_ahb_hresetn,
    set_axi_waddr,
    M_AXI_WVALID_i_reg_1,
    ahb_data_valid,
    burst_term,
    s_ahb_hwdata,
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0 ,
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2 ,
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 ,
    axi_penult_beat_reg_0,
    axi_penult_beat_reg_1,
    axi_last_beat_reg_0,
    s_ahb_htrans,
    s_ahb_hready_in,
    s_ahb_hsel,
    M_AXI_WLAST_i_reg_1,
    E,
    D);
  output [0:0]m_axi_wstrb;
  output [0:0]SS;
  output m_axi_awvalid;
  output M_AXI_WLAST_i_reg_0;
  output ahb_data_valid_burst_term;
  output M_AXI_WVALID_i_reg_0;
  output m_axi_bready;
  output [4:0]Q;
  output m_axi_wready_0;
  output local_en_reg_0;
  output \s_ahb_htrans[1] ;
  output m_axi_wready_1;
  output [63:0]m_axi_wdata;
  input s_ahb_hclk;
  input M_AXI_AWVALID_i_reg_0;
  input ahb_data_valid_burst_term_reg_0;
  input M_AXI_BREADY_i_reg_0;
  input m_axi_wready;
  input s_ahb_hresetn;
  input set_axi_waddr;
  input M_AXI_WVALID_i_reg_1;
  input ahb_data_valid;
  input burst_term;
  input [63:0]s_ahb_hwdata;
  input \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0 ;
  input [4:0]\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2 ;
  input \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 ;
  input axi_penult_beat_reg_0;
  input axi_penult_beat_reg_1;
  input axi_last_beat_reg_0;
  input [0:0]s_ahb_htrans;
  input s_ahb_hready_in;
  input s_ahb_hsel;
  input M_AXI_WLAST_i_reg_1;
  input [0:0]E;
  input [2:0]D;

  wire AXI_WRITE_CNT_MODULE_n_0;
  wire AXI_WRITE_CNT_MODULE_n_1;
  wire AXI_WRITE_CNT_MODULE_n_10;
  wire AXI_WRITE_CNT_MODULE_n_7;
  wire [2:0]D;
  wire [0:0]E;
  wire M_AXI_AWVALID_i_reg_0;
  wire M_AXI_BREADY_i_reg_0;
  wire M_AXI_WLAST_i_i_1_n_0;
  wire M_AXI_WLAST_i_i_2_n_0;
  wire M_AXI_WLAST_i_reg_0;
  wire M_AXI_WLAST_i_reg_1;
  wire [0:0]M_AXI_WSTRB_i;
  wire M_AXI_WVALID_i_reg_0;
  wire M_AXI_WVALID_i_reg_1;
  wire [4:0]\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0 ;
  wire [4:0]Q;
  wire [0:0]SS;
  wire ahb_data_valid;
  wire ahb_data_valid_burst_term;
  wire ahb_data_valid_burst_term_reg_0;
  wire [3:1]axi_cnt_required;
  wire axi_last_beat_reg_0;
  wire axi_last_beat_reg_n_0;
  wire axi_penult_beat_reg_0;
  wire axi_penult_beat_reg_1;
  wire axi_penult_beat_reg_n_0;
  wire axi_wdata_done_i0;
  wire burst_term;
  wire dummy_on_axi_progress;
  wire local_en;
  wire local_en_i_1_n_0;
  wire local_en_reg_0;
  wire [63:0]local_wdata;
  wire local_wdata0;
  wire m_axi_awvalid;
  wire m_axi_bready;
  wire [63:0]m_axi_wdata;
  wire m_axi_wready;
  wire m_axi_wready_0;
  wire m_axi_wready_1;
  wire [0:0]m_axi_wstrb;
  wire [63:0]p_1_in;
  wire s_ahb_hclk;
  wire s_ahb_hready_in;
  wire s_ahb_hresetn;
  wire s_ahb_hsel;
  wire [0:0]s_ahb_htrans;
  wire \s_ahb_htrans[1] ;
  wire [63:0]s_ahb_hwdata;
  wire set_axi_waddr;
  wire wr_load_timeout_cntr;

  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f AXI_WRITE_CNT_MODULE
       (.E(m_axi_wready_0),
        .\INFERRED_GEN.icount_out_reg[0]_0 (M_AXI_WVALID_i_reg_0),
        .M_AXI_WSTRB_i(M_AXI_WSTRB_i),
        .M_AXI_WVALID_i_reg(M_AXI_WVALID_i_reg_1),
        .\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 (\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2 ),
        .\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1 (\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 ),
        .\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7] (\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0 ),
        .Q(Q),
        .SR(SS),
        .axi_last_beat_reg(axi_last_beat_reg_n_0),
        .axi_last_beat_reg_0(axi_last_beat_reg_0),
        .axi_penult_beat_i_2_0(axi_cnt_required),
        .axi_penult_beat_reg(axi_penult_beat_reg_n_0),
        .axi_penult_beat_reg_0(axi_penult_beat_reg_0),
        .axi_penult_beat_reg_1(axi_penult_beat_reg_1),
        .axi_wdata_done_i0(axi_wdata_done_i0),
        .burst_term(burst_term),
        .dummy_on_axi_progress(dummy_on_axi_progress),
        .dummy_on_axi_progress_reg(AXI_WRITE_CNT_MODULE_n_7),
        .dummy_on_axi_progress_reg_0(M_AXI_WLAST_i_reg_0),
        .m_axi_wready(m_axi_wready),
        .m_axi_wready_0(AXI_WRITE_CNT_MODULE_n_0),
        .m_axi_wready_1(AXI_WRITE_CNT_MODULE_n_1),
        .m_axi_wready_2(AXI_WRITE_CNT_MODULE_n_10),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hresetn(s_ahb_hresetn),
        .set_axi_waddr(set_axi_waddr),
        .wr_load_timeout_cntr(wr_load_timeout_cntr));
  FDRE M_AXI_AWVALID_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(M_AXI_AWVALID_i_reg_0),
        .Q(m_axi_awvalid),
        .R(SS));
  FDRE M_AXI_BREADY_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(M_AXI_BREADY_i_reg_0),
        .Q(m_axi_bready),
        .R(SS));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[0]_i_1 
       (.I0(s_ahb_hwdata[0]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[0]),
        .O(p_1_in[0]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[10]_i_1 
       (.I0(s_ahb_hwdata[10]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[10]),
        .O(p_1_in[10]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[11]_i_1 
       (.I0(s_ahb_hwdata[11]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[11]),
        .O(p_1_in[11]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[12]_i_1 
       (.I0(s_ahb_hwdata[12]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[12]),
        .O(p_1_in[12]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[13]_i_1 
       (.I0(s_ahb_hwdata[13]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[13]),
        .O(p_1_in[13]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[14]_i_1 
       (.I0(s_ahb_hwdata[14]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[14]),
        .O(p_1_in[14]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[15]_i_1 
       (.I0(s_ahb_hwdata[15]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[15]),
        .O(p_1_in[15]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[16]_i_1 
       (.I0(s_ahb_hwdata[16]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[16]),
        .O(p_1_in[16]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[17]_i_1 
       (.I0(s_ahb_hwdata[17]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[17]),
        .O(p_1_in[17]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[18]_i_1 
       (.I0(s_ahb_hwdata[18]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[18]),
        .O(p_1_in[18]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[19]_i_1 
       (.I0(s_ahb_hwdata[19]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[19]),
        .O(p_1_in[19]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[1]_i_1 
       (.I0(s_ahb_hwdata[1]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[1]),
        .O(p_1_in[1]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[20]_i_1 
       (.I0(s_ahb_hwdata[20]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[20]),
        .O(p_1_in[20]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[21]_i_1 
       (.I0(s_ahb_hwdata[21]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[21]),
        .O(p_1_in[21]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[22]_i_1 
       (.I0(s_ahb_hwdata[22]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[22]),
        .O(p_1_in[22]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[23]_i_1 
       (.I0(s_ahb_hwdata[23]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[23]),
        .O(p_1_in[23]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[24]_i_1 
       (.I0(s_ahb_hwdata[24]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[24]),
        .O(p_1_in[24]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[25]_i_1 
       (.I0(s_ahb_hwdata[25]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[25]),
        .O(p_1_in[25]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[26]_i_1 
       (.I0(s_ahb_hwdata[26]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[26]),
        .O(p_1_in[26]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[27]_i_1 
       (.I0(s_ahb_hwdata[27]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[27]),
        .O(p_1_in[27]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[28]_i_1 
       (.I0(s_ahb_hwdata[28]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[28]),
        .O(p_1_in[28]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[29]_i_1 
       (.I0(s_ahb_hwdata[29]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[29]),
        .O(p_1_in[29]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[2]_i_1 
       (.I0(s_ahb_hwdata[2]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[2]),
        .O(p_1_in[2]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[30]_i_1 
       (.I0(s_ahb_hwdata[30]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[30]),
        .O(p_1_in[30]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[31]_i_1 
       (.I0(s_ahb_hwdata[31]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[31]),
        .O(p_1_in[31]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[32]_i_1 
       (.I0(s_ahb_hwdata[32]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[32]),
        .O(p_1_in[32]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[33]_i_1 
       (.I0(s_ahb_hwdata[33]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[33]),
        .O(p_1_in[33]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[34]_i_1 
       (.I0(s_ahb_hwdata[34]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[34]),
        .O(p_1_in[34]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[35]_i_1 
       (.I0(s_ahb_hwdata[35]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[35]),
        .O(p_1_in[35]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[36]_i_1 
       (.I0(s_ahb_hwdata[36]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[36]),
        .O(p_1_in[36]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[37]_i_1 
       (.I0(s_ahb_hwdata[37]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[37]),
        .O(p_1_in[37]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[38]_i_1 
       (.I0(s_ahb_hwdata[38]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[38]),
        .O(p_1_in[38]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[39]_i_1 
       (.I0(s_ahb_hwdata[39]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[39]),
        .O(p_1_in[39]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[3]_i_1 
       (.I0(s_ahb_hwdata[3]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[3]),
        .O(p_1_in[3]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[40]_i_1 
       (.I0(s_ahb_hwdata[40]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[40]),
        .O(p_1_in[40]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[41]_i_1 
       (.I0(s_ahb_hwdata[41]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[41]),
        .O(p_1_in[41]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[42]_i_1 
       (.I0(s_ahb_hwdata[42]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[42]),
        .O(p_1_in[42]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[43]_i_1 
       (.I0(s_ahb_hwdata[43]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[43]),
        .O(p_1_in[43]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[44]_i_1 
       (.I0(s_ahb_hwdata[44]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[44]),
        .O(p_1_in[44]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[45]_i_1 
       (.I0(s_ahb_hwdata[45]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[45]),
        .O(p_1_in[45]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[46]_i_1 
       (.I0(s_ahb_hwdata[46]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[46]),
        .O(p_1_in[46]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[47]_i_1 
       (.I0(s_ahb_hwdata[47]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[47]),
        .O(p_1_in[47]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[48]_i_1 
       (.I0(s_ahb_hwdata[48]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[48]),
        .O(p_1_in[48]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[49]_i_1 
       (.I0(s_ahb_hwdata[49]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[49]),
        .O(p_1_in[49]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[4]_i_1 
       (.I0(s_ahb_hwdata[4]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[4]),
        .O(p_1_in[4]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[50]_i_1 
       (.I0(s_ahb_hwdata[50]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[50]),
        .O(p_1_in[50]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[51]_i_1 
       (.I0(s_ahb_hwdata[51]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[51]),
        .O(p_1_in[51]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[52]_i_1 
       (.I0(s_ahb_hwdata[52]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[52]),
        .O(p_1_in[52]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[53]_i_1 
       (.I0(s_ahb_hwdata[53]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[53]),
        .O(p_1_in[53]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[54]_i_1 
       (.I0(s_ahb_hwdata[54]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[54]),
        .O(p_1_in[54]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[55]_i_1 
       (.I0(s_ahb_hwdata[55]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[55]),
        .O(p_1_in[55]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[56]_i_1 
       (.I0(s_ahb_hwdata[56]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[56]),
        .O(p_1_in[56]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[57]_i_1 
       (.I0(s_ahb_hwdata[57]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[57]),
        .O(p_1_in[57]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[58]_i_1 
       (.I0(s_ahb_hwdata[58]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[58]),
        .O(p_1_in[58]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[59]_i_1 
       (.I0(s_ahb_hwdata[59]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[59]),
        .O(p_1_in[59]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[5]_i_1 
       (.I0(s_ahb_hwdata[5]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[5]),
        .O(p_1_in[5]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[60]_i_1 
       (.I0(s_ahb_hwdata[60]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[60]),
        .O(p_1_in[60]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[61]_i_1 
       (.I0(s_ahb_hwdata[61]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[61]),
        .O(p_1_in[61]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[62]_i_1 
       (.I0(s_ahb_hwdata[62]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[62]),
        .O(p_1_in[62]));
  LUT2 #(
    .INIT(4'hB)) 
    \M_AXI_WDATA_i[63]_i_1 
       (.I0(m_axi_wready),
        .I1(M_AXI_WVALID_i_reg_0),
        .O(m_axi_wready_0));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[63]_i_2 
       (.I0(s_ahb_hwdata[63]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[63]),
        .O(p_1_in[63]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[6]_i_1 
       (.I0(s_ahb_hwdata[6]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[6]),
        .O(p_1_in[6]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[7]_i_1 
       (.I0(s_ahb_hwdata[7]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[7]),
        .O(p_1_in[7]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[8]_i_1 
       (.I0(s_ahb_hwdata[8]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[8]),
        .O(p_1_in[8]));
  LUT5 #(
    .INIT(32'hEEAE22A2)) 
    \M_AXI_WDATA_i[9]_i_1 
       (.I0(s_ahb_hwdata[9]),
        .I1(local_en),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(m_axi_wready),
        .I4(local_wdata[9]),
        .O(p_1_in[9]));
  FDRE \M_AXI_WDATA_i_reg[0] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[0]),
        .Q(m_axi_wdata[0]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[10] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[10]),
        .Q(m_axi_wdata[10]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[11] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[11]),
        .Q(m_axi_wdata[11]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[12] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[12]),
        .Q(m_axi_wdata[12]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[13] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[13]),
        .Q(m_axi_wdata[13]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[14] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[14]),
        .Q(m_axi_wdata[14]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[15] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[15]),
        .Q(m_axi_wdata[15]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[16] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[16]),
        .Q(m_axi_wdata[16]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[17] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[17]),
        .Q(m_axi_wdata[17]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[18] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[18]),
        .Q(m_axi_wdata[18]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[19] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[19]),
        .Q(m_axi_wdata[19]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[1] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[1]),
        .Q(m_axi_wdata[1]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[20] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[20]),
        .Q(m_axi_wdata[20]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[21] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[21]),
        .Q(m_axi_wdata[21]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[22] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[22]),
        .Q(m_axi_wdata[22]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[23] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[23]),
        .Q(m_axi_wdata[23]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[24] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[24]),
        .Q(m_axi_wdata[24]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[25] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[25]),
        .Q(m_axi_wdata[25]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[26] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[26]),
        .Q(m_axi_wdata[26]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[27] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[27]),
        .Q(m_axi_wdata[27]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[28] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[28]),
        .Q(m_axi_wdata[28]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[29] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[29]),
        .Q(m_axi_wdata[29]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[2] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[2]),
        .Q(m_axi_wdata[2]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[30] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[30]),
        .Q(m_axi_wdata[30]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[31] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[31]),
        .Q(m_axi_wdata[31]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[32] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[32]),
        .Q(m_axi_wdata[32]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[33] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[33]),
        .Q(m_axi_wdata[33]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[34] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[34]),
        .Q(m_axi_wdata[34]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[35] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[35]),
        .Q(m_axi_wdata[35]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[36] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[36]),
        .Q(m_axi_wdata[36]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[37] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[37]),
        .Q(m_axi_wdata[37]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[38] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[38]),
        .Q(m_axi_wdata[38]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[39] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[39]),
        .Q(m_axi_wdata[39]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[3] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[3]),
        .Q(m_axi_wdata[3]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[40] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[40]),
        .Q(m_axi_wdata[40]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[41] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[41]),
        .Q(m_axi_wdata[41]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[42] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[42]),
        .Q(m_axi_wdata[42]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[43] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[43]),
        .Q(m_axi_wdata[43]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[44] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[44]),
        .Q(m_axi_wdata[44]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[45] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[45]),
        .Q(m_axi_wdata[45]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[46] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[46]),
        .Q(m_axi_wdata[46]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[47] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[47]),
        .Q(m_axi_wdata[47]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[48] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[48]),
        .Q(m_axi_wdata[48]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[49] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[49]),
        .Q(m_axi_wdata[49]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[4] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[4]),
        .Q(m_axi_wdata[4]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[50] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[50]),
        .Q(m_axi_wdata[50]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[51] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[51]),
        .Q(m_axi_wdata[51]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[52] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[52]),
        .Q(m_axi_wdata[52]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[53] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[53]),
        .Q(m_axi_wdata[53]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[54] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[54]),
        .Q(m_axi_wdata[54]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[55] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[55]),
        .Q(m_axi_wdata[55]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[56] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[56]),
        .Q(m_axi_wdata[56]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[57] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[57]),
        .Q(m_axi_wdata[57]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[58] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[58]),
        .Q(m_axi_wdata[58]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[59] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[59]),
        .Q(m_axi_wdata[59]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[5] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[5]),
        .Q(m_axi_wdata[5]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[60] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[60]),
        .Q(m_axi_wdata[60]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[61] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[61]),
        .Q(m_axi_wdata[61]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[62] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[62]),
        .Q(m_axi_wdata[62]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[63] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[63]),
        .Q(m_axi_wdata[63]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[6] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[6]),
        .Q(m_axi_wdata[6]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[7] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[7]),
        .Q(m_axi_wdata[7]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[8] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[8]),
        .Q(m_axi_wdata[8]),
        .R(SS));
  FDRE \M_AXI_WDATA_i_reg[9] 
       (.C(s_ahb_hclk),
        .CE(m_axi_wready_0),
        .D(p_1_in[9]),
        .Q(m_axi_wdata[9]),
        .R(SS));
  LUT6 #(
    .INIT(64'hEEEEEEECEEEFEEEC)) 
    M_AXI_WLAST_i_i_1
       (.I0(M_AXI_WLAST_i_i_2_n_0),
        .I1(M_AXI_WLAST_i_reg_1),
        .I2(axi_last_beat_reg_n_0),
        .I3(axi_penult_beat_reg_n_0),
        .I4(M_AXI_WLAST_i_reg_0),
        .I5(m_axi_wready),
        .O(M_AXI_WLAST_i_i_1_n_0));
  LUT6 #(
    .INIT(64'h00000000FEFE00FE)) 
    M_AXI_WLAST_i_i_2
       (.I0(local_en),
        .I1(ahb_data_valid),
        .I2(burst_term),
        .I3(axi_penult_beat_reg_n_0),
        .I4(wr_load_timeout_cntr),
        .I5(axi_wdata_done_i0),
        .O(M_AXI_WLAST_i_i_2_n_0));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h8)) 
    M_AXI_WLAST_i_i_4
       (.I0(m_axi_wready),
        .I1(M_AXI_WVALID_i_reg_0),
        .O(wr_load_timeout_cntr));
  FDRE M_AXI_WLAST_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(M_AXI_WLAST_i_i_1_n_0),
        .Q(M_AXI_WLAST_i_reg_0),
        .R(SS));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT2 #(
    .INIT(4'h8)) 
    M_AXI_WVALID_i_i_3
       (.I0(M_AXI_WLAST_i_reg_0),
        .I1(m_axi_wready),
        .O(axi_wdata_done_i0));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT2 #(
    .INIT(4'hE)) 
    M_AXI_WVALID_i_i_4
       (.I0(local_en),
        .I1(ahb_data_valid),
        .O(local_en_reg_0));
  FDRE M_AXI_WVALID_i_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(AXI_WRITE_CNT_MODULE_n_7),
        .Q(M_AXI_WVALID_i_reg_0),
        .R(1'b0));
  FDSE \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7] 
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(M_AXI_WSTRB_i),
        .Q(m_axi_wstrb),
        .S(SS));
  FDRE ahb_data_valid_burst_term_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(ahb_data_valid_burst_term_reg_0),
        .Q(ahb_data_valid_burst_term),
        .R(SS));
  LUT6 #(
    .INIT(64'hAAAA0C000C000C00)) 
    ahb_data_valid_i_i_1
       (.I0(s_ahb_htrans),
        .I1(local_en),
        .I2(m_axi_wready_0),
        .I3(ahb_data_valid),
        .I4(s_ahb_hready_in),
        .I5(s_ahb_hsel),
        .O(\s_ahb_htrans[1] ));
  FDRE \axi_cnt_required_reg[1] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(D[0]),
        .Q(axi_cnt_required[1]),
        .R(SS));
  FDRE \axi_cnt_required_reg[2] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(D[1]),
        .Q(axi_cnt_required[2]),
        .R(SS));
  FDRE \axi_cnt_required_reg[3] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(D[2]),
        .Q(axi_cnt_required[3]),
        .R(SS));
  FDRE axi_last_beat_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(AXI_WRITE_CNT_MODULE_n_1),
        .Q(axi_last_beat_reg_n_0),
        .R(1'b0));
  FDRE axi_penult_beat_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(AXI_WRITE_CNT_MODULE_n_0),
        .Q(axi_penult_beat_reg_n_0),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'h8F)) 
    burst_term_i_i_2
       (.I0(m_axi_wready),
        .I1(M_AXI_WLAST_i_reg_0),
        .I2(s_ahb_hresetn),
        .O(m_axi_wready_1));
  FDRE dummy_on_axi_progress_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(AXI_WRITE_CNT_MODULE_n_10),
        .Q(dummy_on_axi_progress),
        .R(SS));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'hD540)) 
    local_en_i_1
       (.I0(m_axi_wready),
        .I1(ahb_data_valid),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(local_en),
        .O(local_en_i_1_n_0));
  FDRE local_en_reg
       (.C(s_ahb_hclk),
        .CE(1'b1),
        .D(local_en_i_1_n_0),
        .Q(local_en),
        .R(SS));
  LUT4 #(
    .INIT(16'hD555)) 
    \local_wdata[63]_i_1 
       (.I0(local_en),
        .I1(m_axi_wready),
        .I2(M_AXI_WVALID_i_reg_0),
        .I3(ahb_data_valid),
        .O(local_wdata0));
  FDRE \local_wdata_reg[0] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[0]),
        .Q(local_wdata[0]),
        .R(SS));
  FDRE \local_wdata_reg[10] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[10]),
        .Q(local_wdata[10]),
        .R(SS));
  FDRE \local_wdata_reg[11] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[11]),
        .Q(local_wdata[11]),
        .R(SS));
  FDRE \local_wdata_reg[12] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[12]),
        .Q(local_wdata[12]),
        .R(SS));
  FDRE \local_wdata_reg[13] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[13]),
        .Q(local_wdata[13]),
        .R(SS));
  FDRE \local_wdata_reg[14] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[14]),
        .Q(local_wdata[14]),
        .R(SS));
  FDRE \local_wdata_reg[15] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[15]),
        .Q(local_wdata[15]),
        .R(SS));
  FDRE \local_wdata_reg[16] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[16]),
        .Q(local_wdata[16]),
        .R(SS));
  FDRE \local_wdata_reg[17] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[17]),
        .Q(local_wdata[17]),
        .R(SS));
  FDRE \local_wdata_reg[18] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[18]),
        .Q(local_wdata[18]),
        .R(SS));
  FDRE \local_wdata_reg[19] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[19]),
        .Q(local_wdata[19]),
        .R(SS));
  FDRE \local_wdata_reg[1] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[1]),
        .Q(local_wdata[1]),
        .R(SS));
  FDRE \local_wdata_reg[20] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[20]),
        .Q(local_wdata[20]),
        .R(SS));
  FDRE \local_wdata_reg[21] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[21]),
        .Q(local_wdata[21]),
        .R(SS));
  FDRE \local_wdata_reg[22] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[22]),
        .Q(local_wdata[22]),
        .R(SS));
  FDRE \local_wdata_reg[23] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[23]),
        .Q(local_wdata[23]),
        .R(SS));
  FDRE \local_wdata_reg[24] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[24]),
        .Q(local_wdata[24]),
        .R(SS));
  FDRE \local_wdata_reg[25] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[25]),
        .Q(local_wdata[25]),
        .R(SS));
  FDRE \local_wdata_reg[26] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[26]),
        .Q(local_wdata[26]),
        .R(SS));
  FDRE \local_wdata_reg[27] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[27]),
        .Q(local_wdata[27]),
        .R(SS));
  FDRE \local_wdata_reg[28] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[28]),
        .Q(local_wdata[28]),
        .R(SS));
  FDRE \local_wdata_reg[29] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[29]),
        .Q(local_wdata[29]),
        .R(SS));
  FDRE \local_wdata_reg[2] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[2]),
        .Q(local_wdata[2]),
        .R(SS));
  FDRE \local_wdata_reg[30] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[30]),
        .Q(local_wdata[30]),
        .R(SS));
  FDRE \local_wdata_reg[31] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[31]),
        .Q(local_wdata[31]),
        .R(SS));
  FDRE \local_wdata_reg[32] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[32]),
        .Q(local_wdata[32]),
        .R(SS));
  FDRE \local_wdata_reg[33] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[33]),
        .Q(local_wdata[33]),
        .R(SS));
  FDRE \local_wdata_reg[34] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[34]),
        .Q(local_wdata[34]),
        .R(SS));
  FDRE \local_wdata_reg[35] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[35]),
        .Q(local_wdata[35]),
        .R(SS));
  FDRE \local_wdata_reg[36] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[36]),
        .Q(local_wdata[36]),
        .R(SS));
  FDRE \local_wdata_reg[37] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[37]),
        .Q(local_wdata[37]),
        .R(SS));
  FDRE \local_wdata_reg[38] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[38]),
        .Q(local_wdata[38]),
        .R(SS));
  FDRE \local_wdata_reg[39] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[39]),
        .Q(local_wdata[39]),
        .R(SS));
  FDRE \local_wdata_reg[3] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[3]),
        .Q(local_wdata[3]),
        .R(SS));
  FDRE \local_wdata_reg[40] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[40]),
        .Q(local_wdata[40]),
        .R(SS));
  FDRE \local_wdata_reg[41] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[41]),
        .Q(local_wdata[41]),
        .R(SS));
  FDRE \local_wdata_reg[42] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[42]),
        .Q(local_wdata[42]),
        .R(SS));
  FDRE \local_wdata_reg[43] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[43]),
        .Q(local_wdata[43]),
        .R(SS));
  FDRE \local_wdata_reg[44] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[44]),
        .Q(local_wdata[44]),
        .R(SS));
  FDRE \local_wdata_reg[45] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[45]),
        .Q(local_wdata[45]),
        .R(SS));
  FDRE \local_wdata_reg[46] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[46]),
        .Q(local_wdata[46]),
        .R(SS));
  FDRE \local_wdata_reg[47] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[47]),
        .Q(local_wdata[47]),
        .R(SS));
  FDRE \local_wdata_reg[48] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[48]),
        .Q(local_wdata[48]),
        .R(SS));
  FDRE \local_wdata_reg[49] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[49]),
        .Q(local_wdata[49]),
        .R(SS));
  FDRE \local_wdata_reg[4] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[4]),
        .Q(local_wdata[4]),
        .R(SS));
  FDRE \local_wdata_reg[50] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[50]),
        .Q(local_wdata[50]),
        .R(SS));
  FDRE \local_wdata_reg[51] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[51]),
        .Q(local_wdata[51]),
        .R(SS));
  FDRE \local_wdata_reg[52] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[52]),
        .Q(local_wdata[52]),
        .R(SS));
  FDRE \local_wdata_reg[53] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[53]),
        .Q(local_wdata[53]),
        .R(SS));
  FDRE \local_wdata_reg[54] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[54]),
        .Q(local_wdata[54]),
        .R(SS));
  FDRE \local_wdata_reg[55] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[55]),
        .Q(local_wdata[55]),
        .R(SS));
  FDRE \local_wdata_reg[56] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[56]),
        .Q(local_wdata[56]),
        .R(SS));
  FDRE \local_wdata_reg[57] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[57]),
        .Q(local_wdata[57]),
        .R(SS));
  FDRE \local_wdata_reg[58] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[58]),
        .Q(local_wdata[58]),
        .R(SS));
  FDRE \local_wdata_reg[59] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[59]),
        .Q(local_wdata[59]),
        .R(SS));
  FDRE \local_wdata_reg[5] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[5]),
        .Q(local_wdata[5]),
        .R(SS));
  FDRE \local_wdata_reg[60] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[60]),
        .Q(local_wdata[60]),
        .R(SS));
  FDRE \local_wdata_reg[61] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[61]),
        .Q(local_wdata[61]),
        .R(SS));
  FDRE \local_wdata_reg[62] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[62]),
        .Q(local_wdata[62]),
        .R(SS));
  FDRE \local_wdata_reg[63] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[63]),
        .Q(local_wdata[63]),
        .R(SS));
  FDRE \local_wdata_reg[6] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[6]),
        .Q(local_wdata[6]),
        .R(SS));
  FDRE \local_wdata_reg[7] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[7]),
        .Q(local_wdata[7]),
        .R(SS));
  FDRE \local_wdata_reg[8] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[8]),
        .Q(local_wdata[8]),
        .R(SS));
  FDRE \local_wdata_reg[9] 
       (.C(s_ahb_hclk),
        .CE(local_wdata0),
        .D(s_ahb_hwdata[9]),
        .Q(local_wdata[9]),
        .R(SS));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f
   (m_axi_wready_0,
    m_axi_wready_1,
    Q,
    dummy_on_axi_progress_reg,
    M_AXI_WSTRB_i,
    SR,
    m_axi_wready_2,
    m_axi_wready,
    \INFERRED_GEN.icount_out_reg[0]_0 ,
    axi_penult_beat_reg,
    s_ahb_hresetn,
    axi_last_beat_reg,
    set_axi_waddr,
    E,
    dummy_on_axi_progress,
    M_AXI_WVALID_i_reg,
    axi_wdata_done_i0,
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7] ,
    burst_term,
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 ,
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1 ,
    wr_load_timeout_cntr,
    axi_penult_beat_i_2_0,
    axi_penult_beat_reg_0,
    axi_penult_beat_reg_1,
    axi_last_beat_reg_0,
    dummy_on_axi_progress_reg_0,
    s_ahb_hclk);
  output m_axi_wready_0;
  output m_axi_wready_1;
  output [4:0]Q;
  output dummy_on_axi_progress_reg;
  output [0:0]M_AXI_WSTRB_i;
  output [0:0]SR;
  output m_axi_wready_2;
  input m_axi_wready;
  input \INFERRED_GEN.icount_out_reg[0]_0 ;
  input axi_penult_beat_reg;
  input s_ahb_hresetn;
  input axi_last_beat_reg;
  input set_axi_waddr;
  input [0:0]E;
  input dummy_on_axi_progress;
  input M_AXI_WVALID_i_reg;
  input axi_wdata_done_i0;
  input \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7] ;
  input burst_term;
  input [4:0]\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 ;
  input \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1 ;
  input wr_load_timeout_cntr;
  input [2:0]axi_penult_beat_i_2_0;
  input axi_penult_beat_reg_0;
  input axi_penult_beat_reg_1;
  input axi_last_beat_reg_0;
  input dummy_on_axi_progress_reg_0;
  input s_ahb_hclk;

  wire [0:0]E;
  wire \INFERRED_GEN.icount_out[0]_i_1_n_0 ;
  wire \INFERRED_GEN.icount_out[1]_i_1_n_0 ;
  wire \INFERRED_GEN.icount_out[2]_i_1_n_0 ;
  wire \INFERRED_GEN.icount_out[3]_i_1_n_0 ;
  wire \INFERRED_GEN.icount_out[4]_i_1_n_0 ;
  wire \INFERRED_GEN.icount_out[4]_i_2_n_0 ;
  wire \INFERRED_GEN.icount_out_reg[0]_0 ;
  wire [0:0]M_AXI_WSTRB_i;
  wire M_AXI_WVALID_i_reg;
  wire [4:0]\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3_n_0 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5_n_0 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8_n_0 ;
  wire \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7] ;
  wire [4:0]Q;
  wire [0:0]SR;
  wire axi_last_beat_i_2_n_0;
  wire axi_last_beat_reg;
  wire axi_last_beat_reg_0;
  wire [2:0]axi_penult_beat_i_2_0;
  wire axi_penult_beat_i_2_n_0;
  wire axi_penult_beat_i_3_n_0;
  wire axi_penult_beat_reg;
  wire axi_penult_beat_reg_0;
  wire axi_penult_beat_reg_1;
  wire axi_wdata_done_i0;
  wire burst_term;
  wire dummy_on_axi_init;
  wire dummy_on_axi_progress;
  wire dummy_on_axi_progress_reg;
  wire dummy_on_axi_progress_reg_0;
  wire m_axi_wready;
  wire m_axi_wready_0;
  wire m_axi_wready_1;
  wire m_axi_wready_2;
  wire s_ahb_hclk;
  wire s_ahb_hresetn;
  wire set_axi_waddr;
  wire wr_load_timeout_cntr;

  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \INFERRED_GEN.icount_out[0]_i_1 
       (.I0(Q[0]),
        .I1(set_axi_waddr),
        .O(\INFERRED_GEN.icount_out[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'h06)) 
    \INFERRED_GEN.icount_out[1]_i_1 
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(set_axi_waddr),
        .O(\INFERRED_GEN.icount_out[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT4 #(
    .INIT(16'h0078)) 
    \INFERRED_GEN.icount_out[2]_i_1 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(Q[2]),
        .I3(set_axi_waddr),
        .O(\INFERRED_GEN.icount_out[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT5 #(
    .INIT(32'h00007F80)) 
    \INFERRED_GEN.icount_out[3]_i_1 
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(Q[2]),
        .I3(Q[3]),
        .I4(set_axi_waddr),
        .O(\INFERRED_GEN.icount_out[3]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'hF8)) 
    \INFERRED_GEN.icount_out[4]_i_1 
       (.I0(\INFERRED_GEN.icount_out_reg[0]_0 ),
        .I1(m_axi_wready),
        .I2(set_axi_waddr),
        .O(\INFERRED_GEN.icount_out[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h000000007FFF8000)) 
    \INFERRED_GEN.icount_out[4]_i_2 
       (.I0(Q[2]),
        .I1(Q[1]),
        .I2(Q[0]),
        .I3(Q[3]),
        .I4(Q[4]),
        .I5(set_axi_waddr),
        .O(\INFERRED_GEN.icount_out[4]_i_2_n_0 ));
  FDRE \INFERRED_GEN.icount_out_reg[0] 
       (.C(s_ahb_hclk),
        .CE(\INFERRED_GEN.icount_out[4]_i_1_n_0 ),
        .D(\INFERRED_GEN.icount_out[0]_i_1_n_0 ),
        .Q(Q[0]),
        .R(SR));
  FDRE \INFERRED_GEN.icount_out_reg[1] 
       (.C(s_ahb_hclk),
        .CE(\INFERRED_GEN.icount_out[4]_i_1_n_0 ),
        .D(\INFERRED_GEN.icount_out[1]_i_1_n_0 ),
        .Q(Q[1]),
        .R(SR));
  FDRE \INFERRED_GEN.icount_out_reg[2] 
       (.C(s_ahb_hclk),
        .CE(\INFERRED_GEN.icount_out[4]_i_1_n_0 ),
        .D(\INFERRED_GEN.icount_out[2]_i_1_n_0 ),
        .Q(Q[2]),
        .R(SR));
  FDRE \INFERRED_GEN.icount_out_reg[3] 
       (.C(s_ahb_hclk),
        .CE(\INFERRED_GEN.icount_out[4]_i_1_n_0 ),
        .D(\INFERRED_GEN.icount_out[3]_i_1_n_0 ),
        .Q(Q[3]),
        .R(SR));
  FDRE \INFERRED_GEN.icount_out_reg[4] 
       (.C(s_ahb_hclk),
        .CE(\INFERRED_GEN.icount_out[4]_i_1_n_0 ),
        .D(\INFERRED_GEN.icount_out[4]_i_2_n_0 ),
        .Q(Q[4]),
        .R(SR));
  LUT6 #(
    .INIT(64'h00000000FFFD0000)) 
    M_AXI_WVALID_i_i_1
       (.I0(E),
        .I1(dummy_on_axi_init),
        .I2(dummy_on_axi_progress),
        .I3(M_AXI_WVALID_i_reg),
        .I4(s_ahb_hresetn),
        .I5(axi_wdata_done_i0),
        .O(dummy_on_axi_progress_reg));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_1 
       (.I0(dummy_on_axi_init),
        .I1(dummy_on_axi_progress),
        .O(M_AXI_WSTRB_i));
  LUT4 #(
    .INIT(16'h00D0)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2 
       (.I0(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3_n_0 ),
        .I1(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7] ),
        .I2(burst_term),
        .I3(dummy_on_axi_progress),
        .O(dummy_on_axi_init));
  LUT6 #(
    .INIT(64'hFFF6F6FFF9FFFFF6)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3 
       (.I0(Q[4]),
        .I1(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 [4]),
        .I2(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5_n_0 ),
        .I3(Q[3]),
        .I4(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1 ),
        .I5(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 [3]),
        .O(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFBFF7FFFBFFFFBF)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5 
       (.I0(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8_n_0 ),
        .I1(wr_load_timeout_cntr),
        .I2(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 [0]),
        .I3(Q[0]),
        .I4(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 [1]),
        .I5(Q[1]),
        .O(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8 
       (.I0(Q[2]),
        .I1(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0 [2]),
        .O(\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    S_AHB_HREADY_OUT_i_i_1
       (.I0(s_ahb_hresetn),
        .O(SR));
  LUT5 #(
    .INIT(32'h87800000)) 
    axi_last_beat_i_1
       (.I0(m_axi_wready),
        .I1(\INFERRED_GEN.icount_out_reg[0]_0 ),
        .I2(axi_last_beat_i_2_n_0),
        .I3(axi_last_beat_reg),
        .I4(s_ahb_hresetn),
        .O(m_axi_wready_1));
  LUT5 #(
    .INIT(32'h8AA88888)) 
    axi_last_beat_i_2
       (.I0(Q[1]),
        .I1(axi_last_beat_reg_0),
        .I2(Q[0]),
        .I3(axi_penult_beat_i_2_0[0]),
        .I4(axi_penult_beat_i_3_n_0),
        .O(axi_last_beat_i_2_n_0));
  LUT5 #(
    .INIT(32'h87800000)) 
    axi_penult_beat_i_1
       (.I0(m_axi_wready),
        .I1(\INFERRED_GEN.icount_out_reg[0]_0 ),
        .I2(axi_penult_beat_i_2_n_0),
        .I3(axi_penult_beat_reg),
        .I4(s_ahb_hresetn),
        .O(m_axi_wready_0));
  LUT6 #(
    .INIT(64'h2400FFFF24002400)) 
    axi_penult_beat_i_2
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(axi_penult_beat_i_2_0[0]),
        .I3(axi_penult_beat_i_3_n_0),
        .I4(axi_penult_beat_reg_0),
        .I5(axi_penult_beat_reg_1),
        .O(axi_penult_beat_i_2_n_0));
  LUT6 #(
    .INIT(64'h2010100802010120)) 
    axi_penult_beat_i_3
       (.I0(Q[2]),
        .I1(Q[4]),
        .I2(axi_penult_beat_i_2_0[2]),
        .I3(axi_penult_beat_i_2_0[0]),
        .I4(axi_penult_beat_i_2_0[1]),
        .I5(Q[3]),
        .O(axi_penult_beat_i_3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT4 #(
    .INIT(16'hF7F0)) 
    dummy_on_axi_progress_i_1
       (.I0(m_axi_wready),
        .I1(dummy_on_axi_progress_reg_0),
        .I2(dummy_on_axi_init),
        .I3(dummy_on_axi_progress),
        .O(m_axi_wready_2));
endmodule

(* ORIG_REF_NAME = "counter_f" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f_0
   (s_ahb_htrans_0_sp_1,
    Q,
    s_ahb_htrans,
    ahb_penult_beat_reg,
    ahb_penult_beat_reg_0,
    s_ahb_hresetn,
    nonseq_detected,
    ahb_penult_beat_reg_1,
    SS,
    E,
    s_ahb_hclk);
  output s_ahb_htrans_0_sp_1;
  output [4:0]Q;
  input [1:0]s_ahb_htrans;
  input ahb_penult_beat_reg;
  input ahb_penult_beat_reg_0;
  input s_ahb_hresetn;
  input nonseq_detected;
  input [2:0]ahb_penult_beat_reg_1;
  input [0:0]SS;
  input [0:0]E;
  input s_ahb_hclk;

  wire [0:0]E;
  wire \INFERRED_GEN.icount_out[0]_i_1__0_n_0 ;
  wire \INFERRED_GEN.icount_out[1]_i_1__0_n_0 ;
  wire \INFERRED_GEN.icount_out[2]_i_1__0_n_0 ;
  wire \INFERRED_GEN.icount_out[3]_i_1__0_n_0 ;
  wire \INFERRED_GEN.icount_out[4]_i_2__0_n_0 ;
  wire [4:0]Q;
  wire [0:0]SS;
  wire ahb_penult_beat_i_2_n_0;
  wire ahb_penult_beat_i_3_n_0;
  wire ahb_penult_beat_reg;
  wire ahb_penult_beat_reg_0;
  wire [2:0]ahb_penult_beat_reg_1;
  wire nonseq_detected;
  wire s_ahb_hclk;
  wire s_ahb_hresetn;
  wire [1:0]s_ahb_htrans;
  wire s_ahb_htrans_0_sn_1;

  assign s_ahb_htrans_0_sp_1 = s_ahb_htrans_0_sn_1;
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \INFERRED_GEN.icount_out[0]_i_1__0 
       (.I0(s_ahb_htrans[0]),
        .I1(Q[0]),
        .O(\INFERRED_GEN.icount_out[0]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h28)) 
    \INFERRED_GEN.icount_out[1]_i_1__0 
       (.I0(s_ahb_htrans[0]),
        .I1(Q[1]),
        .I2(Q[0]),
        .O(\INFERRED_GEN.icount_out[1]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h1444)) 
    \INFERRED_GEN.icount_out[2]_i_1__0 
       (.I0(nonseq_detected),
        .I1(Q[2]),
        .I2(Q[0]),
        .I3(Q[1]),
        .O(\INFERRED_GEN.icount_out[2]_i_1__0_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h00006AAA)) 
    \INFERRED_GEN.icount_out[3]_i_1__0 
       (.I0(Q[3]),
        .I1(Q[2]),
        .I2(Q[0]),
        .I3(Q[1]),
        .I4(nonseq_detected),
        .O(\INFERRED_GEN.icount_out[3]_i_1__0_n_0 ));
  LUT6 #(
    .INIT(64'h000000007FFF8000)) 
    \INFERRED_GEN.icount_out[4]_i_2__0 
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(Q[2]),
        .I3(Q[3]),
        .I4(Q[4]),
        .I5(nonseq_detected),
        .O(\INFERRED_GEN.icount_out[4]_i_2__0_n_0 ));
  FDRE \INFERRED_GEN.icount_out_reg[0] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(\INFERRED_GEN.icount_out[0]_i_1__0_n_0 ),
        .Q(Q[0]),
        .R(SS));
  FDRE \INFERRED_GEN.icount_out_reg[1] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(\INFERRED_GEN.icount_out[1]_i_1__0_n_0 ),
        .Q(Q[1]),
        .R(SS));
  FDRE \INFERRED_GEN.icount_out_reg[2] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(\INFERRED_GEN.icount_out[2]_i_1__0_n_0 ),
        .Q(Q[2]),
        .R(SS));
  FDRE \INFERRED_GEN.icount_out_reg[3] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(\INFERRED_GEN.icount_out[3]_i_1__0_n_0 ),
        .Q(Q[3]),
        .R(SS));
  FDRE \INFERRED_GEN.icount_out_reg[4] 
       (.C(s_ahb_hclk),
        .CE(E),
        .D(\INFERRED_GEN.icount_out[4]_i_2__0_n_0 ),
        .Q(Q[4]),
        .R(SS));
  LUT6 #(
    .INIT(64'h20CE200000000000)) 
    ahb_penult_beat_i_1
       (.I0(s_ahb_htrans[0]),
        .I1(ahb_penult_beat_reg),
        .I2(s_ahb_htrans[1]),
        .I3(ahb_penult_beat_i_2_n_0),
        .I4(ahb_penult_beat_reg_0),
        .I5(s_ahb_hresetn),
        .O(s_ahb_htrans_0_sn_1));
  LUT6 #(
    .INIT(64'h0000000021212118)) 
    ahb_penult_beat_i_2
       (.I0(Q[3]),
        .I1(Q[4]),
        .I2(ahb_penult_beat_reg_1[2]),
        .I3(ahb_penult_beat_reg_1[1]),
        .I4(ahb_penult_beat_reg_1[0]),
        .I5(ahb_penult_beat_i_3_n_0),
        .O(ahb_penult_beat_i_2_n_0));
  LUT5 #(
    .INIT(32'hBFF7FB7F)) 
    ahb_penult_beat_i_3
       (.I0(Q[0]),
        .I1(Q[1]),
        .I2(ahb_penult_beat_reg_1[1]),
        .I3(ahb_penult_beat_reg_1[0]),
        .I4(Q[2]),
        .O(ahb_penult_beat_i_3_n_0));
endmodule

(* CHECK_LICENSE_TYPE = "zynqmpsoc_ahblite_axi_bridge_0_0,ahblite_axi_bridge,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "ahblite_axi_bridge,Vivado 2019.2.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (s_ahb_hclk,
    s_ahb_hresetn,
    s_ahb_hsel,
    s_ahb_haddr,
    s_ahb_hprot,
    s_ahb_htrans,
    s_ahb_hsize,
    s_ahb_hwrite,
    s_ahb_hburst,
    s_ahb_hwdata,
    s_ahb_hready_out,
    s_ahb_hready_in,
    s_ahb_hrdata,
    s_ahb_hresp,
    m_axi_awid,
    m_axi_awlen,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awcache,
    m_axi_awaddr,
    m_axi_awprot,
    m_axi_awvalid,
    m_axi_awready,
    m_axi_awlock,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wlast,
    m_axi_wvalid,
    m_axi_wready,
    m_axi_bid,
    m_axi_bresp,
    m_axi_bvalid,
    m_axi_bready,
    m_axi_arid,
    m_axi_arlen,
    m_axi_arsize,
    m_axi_arburst,
    m_axi_arprot,
    m_axi_arcache,
    m_axi_arvalid,
    m_axi_araddr,
    m_axi_arlock,
    m_axi_arready,
    m_axi_rid,
    m_axi_rdata,
    m_axi_rresp,
    m_axi_rvalid,
    m_axi_rlast,
    m_axi_rready);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 AHB_CLK CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME AHB_CLK, ASSOCIATED_BUSIF AHB_INTERFACE:M_AXI, ASSOCIATED_RESET s_ahb_hresetn, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input s_ahb_hclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 AHB_RESETN RST" *) (* x_interface_parameter = "XIL_INTERFACENAME AHB_RESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_ahb_hresetn;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE SEL" *) (* x_interface_parameter = "XIL_INTERFACENAME AHB_INTERFACE, BD_ATTRIBUTE.TYPE INTERIOR" *) input s_ahb_hsel;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HADDR" *) input [31:0]s_ahb_haddr;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HPROT" *) input [3:0]s_ahb_hprot;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HTRANS" *) input [1:0]s_ahb_htrans;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HSIZE" *) input [2:0]s_ahb_hsize;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HWRITE" *) input s_ahb_hwrite;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HBURST" *) input [2:0]s_ahb_hburst;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HWDATA" *) input [63:0]s_ahb_hwdata;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HREADY_OUT" *) output s_ahb_hready_out;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HREADY_IN" *) input s_ahb_hready_in;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HRDATA" *) output [63:0]s_ahb_hrdata;
  (* x_interface_info = "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HRESP" *) output s_ahb_hresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWID" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXI, MAX_BURST_LENGTH 16, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 4, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 16, NUM_WRITE_OUTSTANDING 16, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [3:0]m_axi_awid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWLEN" *) output [7:0]m_axi_awlen;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWSIZE" *) output [2:0]m_axi_awsize;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWBURST" *) output [1:0]m_axi_awburst;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWCACHE" *) output [3:0]m_axi_awcache;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *) output [31:0]m_axi_awaddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWPROT" *) output [2:0]m_axi_awprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *) output m_axi_awvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *) input m_axi_awready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI AWLOCK" *) output m_axi_awlock;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *) output [63:0]m_axi_wdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI WSTRB" *) output [7:0]m_axi_wstrb;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI WLAST" *) output m_axi_wlast;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI WVALID" *) output m_axi_wvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI WREADY" *) input m_axi_wready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI BID" *) input [3:0]m_axi_bid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI BRESP" *) input [1:0]m_axi_bresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI BVALID" *) input m_axi_bvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI BREADY" *) output m_axi_bready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARID" *) output [3:0]m_axi_arid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARLEN" *) output [7:0]m_axi_arlen;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARSIZE" *) output [2:0]m_axi_arsize;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARBURST" *) output [1:0]m_axi_arburst;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARPROT" *) output [2:0]m_axi_arprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARCACHE" *) output [3:0]m_axi_arcache;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARVALID" *) output m_axi_arvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARADDR" *) output [31:0]m_axi_araddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARLOCK" *) output m_axi_arlock;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI ARREADY" *) input m_axi_arready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI RID" *) input [3:0]m_axi_rid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI RDATA" *) input [63:0]m_axi_rdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI RRESP" *) input [1:0]m_axi_rresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI RVALID" *) input m_axi_rvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI RLAST" *) input m_axi_rlast;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 M_AXI RREADY" *) output m_axi_rready;

  wire [31:0]m_axi_araddr;
  wire [1:0]m_axi_arburst;
  wire [3:0]m_axi_arcache;
  wire [3:0]m_axi_arid;
  wire [7:0]m_axi_arlen;
  wire m_axi_arlock;
  wire [2:0]m_axi_arprot;
  wire m_axi_arready;
  wire [2:0]m_axi_arsize;
  wire m_axi_arvalid;
  wire [31:0]m_axi_awaddr;
  wire [1:0]m_axi_awburst;
  wire [3:0]m_axi_awcache;
  wire [3:0]m_axi_awid;
  wire [7:0]m_axi_awlen;
  wire m_axi_awlock;
  wire [2:0]m_axi_awprot;
  wire m_axi_awready;
  wire [2:0]m_axi_awsize;
  wire m_axi_awvalid;
  wire [3:0]m_axi_bid;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire [63:0]m_axi_rdata;
  wire [3:0]m_axi_rid;
  wire m_axi_rlast;
  wire m_axi_rready;
  wire [1:0]m_axi_rresp;
  wire m_axi_rvalid;
  wire [63:0]m_axi_wdata;
  wire m_axi_wlast;
  wire m_axi_wready;
  wire [7:0]m_axi_wstrb;
  wire m_axi_wvalid;
  wire [31:0]s_ahb_haddr;
  wire [2:0]s_ahb_hburst;
  wire s_ahb_hclk;
  wire [3:0]s_ahb_hprot;
  wire [63:0]s_ahb_hrdata;
  wire s_ahb_hready_in;
  wire s_ahb_hready_out;
  wire s_ahb_hresetn;
  wire s_ahb_hresp;
  wire s_ahb_hsel;
  wire [2:0]s_ahb_hsize;
  wire [1:0]s_ahb_htrans;
  wire [63:0]s_ahb_hwdata;
  wire s_ahb_hwrite;

  (* C_AHB_AXI_TIMEOUT = "0" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_INSTANCE = "zynqmpsoc_ahblite_axi_bridge_0_0" *) 
  (* C_M_AXI_ADDR_WIDTH = "32" *) 
  (* C_M_AXI_DATA_WIDTH = "64" *) 
  (* C_M_AXI_NON_SECURE = "1" *) 
  (* C_M_AXI_PROTOCOL = "AXI4" *) 
  (* C_M_AXI_SUPPORTS_NARROW_BURST = "0" *) 
  (* C_M_AXI_THREAD_ID_WIDTH = "4" *) 
  (* C_S_AHB_ADDR_WIDTH = "32" *) 
  (* C_S_AHB_DATA_WIDTH = "64" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge U0
       (.m_axi_araddr(m_axi_araddr),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arid(m_axi_arid),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arready(m_axi_arready),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awid(m_axi_awid),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awlock(m_axi_awlock),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awready(m_axi_awready),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_bid(m_axi_bid),
        .m_axi_bready(m_axi_bready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rid(m_axi_rid),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rready(m_axi_rready),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wready(m_axi_wready),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid),
        .s_ahb_haddr(s_ahb_haddr),
        .s_ahb_hburst(s_ahb_hburst),
        .s_ahb_hclk(s_ahb_hclk),
        .s_ahb_hprot(s_ahb_hprot),
        .s_ahb_hrdata(s_ahb_hrdata),
        .s_ahb_hready_in(s_ahb_hready_in),
        .s_ahb_hready_out(s_ahb_hready_out),
        .s_ahb_hresetn(s_ahb_hresetn),
        .s_ahb_hresp(s_ahb_hresp),
        .s_ahb_hsel(s_ahb_hsel),
        .s_ahb_hsize(s_ahb_hsize),
        .s_ahb_htrans(s_ahb_htrans),
        .s_ahb_hwdata(s_ahb_hwdata),
        .s_ahb_hwrite(s_ahb_hwrite));
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
