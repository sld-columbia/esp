-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
-- Date        : Mon Jan 11 12:09:40 2021
-- Host        : skie running 64-bit Ubuntu 18.04.5 LTS
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ zynqmpsoc_ahblite_axi_bridge_0_0_sim_netlist.vhdl
-- Design      : zynqmpsoc_ahblite_axi_bridge_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_if is
  port (
    ahb_hburst_single : out STD_LOGIC;
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    idle_txfer_pending : out STD_LOGIC;
    ahb_penult_beat_reg_0 : out STD_LOGIC;
    nonseq_txfer_pending : out STD_LOGIC;
    s_ahb_hready_out : out STD_LOGIC;
    s_ahb_hresp : out STD_LOGIC;
    burst_term_hwrite : out STD_LOGIC;
    burst_term_single_incr : out STD_LOGIC;
    burst_term : out STD_LOGIC;
    dummy_txfer_in_progress_reg_0 : out STD_LOGIC;
    ahb_data_valid : out STD_LOGIC;
    D : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ahb_hburst_incr_i_reg_0 : out STD_LOGIC;
    nonseq_txfer_pending_i_reg_0 : out STD_LOGIC;
    set_axi_waddr : out STD_LOGIC;
    s_ahb_hsel_0 : out STD_LOGIC;
    nonseq_detected : out STD_LOGIC;
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    ahb_hburst_incr_i_reg_1 : out STD_LOGIC;
    m_axi_wready_0 : out STD_LOGIC;
    ahb_hburst_incr_i_reg_2 : out STD_LOGIC;
    \burst_term_txer_cnt_i_reg[2]_0\ : out STD_LOGIC;
    \INFERRED_GEN.icount_out_reg[0]\ : out STD_LOGIC;
    \INFERRED_GEN.icount_out_reg[4]\ : out STD_LOGIC;
    \INFERRED_GEN.icount_out_reg[0]_0\ : out STD_LOGIC;
    \burst_term_cur_cnt_i_reg[4]_0\ : out STD_LOGIC_VECTOR ( 4 downto 0 );
    \burst_term_cur_cnt_i_reg[0]_0\ : out STD_LOGIC;
    s_ahb_hready_in_0 : out STD_LOGIC;
    m_axi_awready_0 : out STD_LOGIC;
    nonseq_txfer_pending_i_reg_1 : out STD_LOGIC;
    m_axi_arready_0 : out STD_LOGIC;
    \valid_cnt_required_i_reg[3]_0\ : out STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ahb_hrdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_arlen : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_arcache : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    SS : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_ahb_hclk : in STD_LOGIC;
    s_ahb_hprot : in STD_LOGIC_VECTOR ( 3 downto 0 );
    idle_txfer_pending_reg_0 : in STD_LOGIC;
    ahb_penult_beat_reg_1 : in STD_LOGIC;
    nonseq_txfer_pending_i_reg_2 : in STD_LOGIC;
    burst_term_hwrite_reg_0 : in STD_LOGIC;
    burst_term_single_incr_reg_0 : in STD_LOGIC;
    burst_term_i_reg_0 : in STD_LOGIC;
    ahb_data_valid_i_reg_0 : in STD_LOGIC;
    dummy_txfer_in_progress_reg_1 : in STD_LOGIC;
    ahb_done_axi_in_progress_reg_0 : in STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    ahb_wnr_i_reg : in STD_LOGIC;
    S_AHB_HREADY_OUT_i_reg_0 : in STD_LOGIC;
    S_AHB_HREADY_OUT_i_reg_1 : in STD_LOGIC;
    S_AHB_HRESP_i_reg_0 : in STD_LOGIC;
    s_ahb_hwrite : in STD_LOGIC;
    set_hresp_err : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AHB_HREADY_OUT_i_reg_2 : in STD_LOGIC;
    S_AHB_HREADY_OUT_i_reg_3 : in STD_LOGIC;
    m_axi_bvalid : in STD_LOGIC;
    ahb_wnr_i_reg_0 : in STD_LOGIC;
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_ahb_hready_in : in STD_LOGIC;
    s_ahb_hsel : in STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[0]\ : in STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[0]_0\ : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 0 to 0 );
    S_AHB_HREADY_OUT_i_reg_4 : in STD_LOGIC;
    ahb_data_valid_burst_term : in STD_LOGIC;
    M_AXI_WVALID_i_reg : in STD_LOGIC;
    M_AXI_WVALID_i_reg_0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_ahb_hburst : in STD_LOGIC_VECTOR ( 2 downto 0 );
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\ : in STD_LOGIC_VECTOR ( 4 downto 0 );
    ahb_done_axi_in_progress_reg_1 : in STD_LOGIC;
    p_10_in : in STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_awvalid : in STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    M_AXI_ARVALID_i_reg : in STD_LOGIC;
    \S_AHB_HRDATA_i_reg[63]_0\ : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_ahb_hsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ahb_haddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    \burst_term_txer_cnt_i_reg[3]_0\ : in STD_LOGIC_VECTOR ( 0 to 0 );
    \burst_term_cur_cnt_i_reg[4]_1\ : in STD_LOGIC_VECTOR ( 4 downto 0 )
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_if;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_if is
  signal AXI_ABURST_i : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \AXI_ABURST_i[1]_i_1_n_0\ : STD_LOGIC;
  signal \AXI_ABURST_i[1]_i_2_n_0\ : STD_LOGIC;
  signal AXI_ALEN_i : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal AXI_ALEN_i0 : STD_LOGIC;
  signal \^d\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \FSM_onehot_ctl_sm_cs[0]_i_4_n_0\ : STD_LOGIC;
  signal \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1_n_0\ : STD_LOGIC;
  signal \^inferred_gen.icount_out_reg[4]\ : STD_LOGIC;
  signal \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7_n_0\ : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_10_n_0 : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_11_n_0 : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_14_n_0 : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_16_n_0 : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_2_n_0 : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_4_n_0 : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_6_n_0 : STD_LOGIC;
  signal S_AHB_HREADY_OUT_i_i_7_n_0 : STD_LOGIC;
  signal S_AHB_HRESP_i_i_1_n_0 : STD_LOGIC;
  signal S_AHB_HRESP_i_i_3_n_0 : STD_LOGIC;
  signal S_AHB_HRESP_i_i_4_n_0 : STD_LOGIC;
  signal S_AHB_HSIZE_i0 : STD_LOGIC;
  signal ahb_burst_done : STD_LOGIC;
  signal ahb_done_axi_in_progress : STD_LOGIC;
  signal ahb_done_axi_in_progress_i_1_n_0 : STD_LOGIC;
  signal ahb_hburst_incr : STD_LOGIC;
  signal \^ahb_hburst_incr_i_reg_0\ : STD_LOGIC;
  signal \^ahb_hburst_single\ : STD_LOGIC;
  signal \^ahb_penult_beat_reg_0\ : STD_LOGIC;
  signal \^burst_term\ : STD_LOGIC;
  signal \^burst_term_cur_cnt_i_reg[4]_0\ : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal \^burst_term_hwrite\ : STD_LOGIC;
  signal \^burst_term_single_incr\ : STD_LOGIC;
  signal burst_term_txer_cnt : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal dummy_txfer_in_progress_i_1_n_0 : STD_LOGIC;
  signal \^dummy_txfer_in_progress_reg_0\ : STD_LOGIC;
  signal eqOp : STD_LOGIC;
  signal eqOp0_in : STD_LOGIC;
  signal \^idle_txfer_pending\ : STD_LOGIC;
  signal \^m_axi_arprot\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \^nonseq_detected\ : STD_LOGIC;
  signal \^nonseq_txfer_pending\ : STD_LOGIC;
  signal \^nonseq_txfer_pending_i_reg_0\ : STD_LOGIC;
  signal p_1_out : STD_LOGIC_VECTOR ( 2 to 2 );
  signal \^s_ahb_hready_in_0\ : STD_LOGIC;
  signal \^s_ahb_hready_out\ : STD_LOGIC;
  signal \^s_ahb_hresp\ : STD_LOGIC;
  signal \^s_ahb_hsel_0\ : STD_LOGIC;
  signal set_axi_raddr : STD_LOGIC;
  signal \^set_axi_waddr\ : STD_LOGIC;
  signal \^valid_cnt_required_i_reg[3]_0\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \AXI_ABURST_i[0]_i_1\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \AXI_ABURST_i[1]_i_2\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \AXI_ALEN_i[1]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \FSM_onehot_ctl_sm_cs[0]_i_2\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \FSM_onehot_ctl_sm_cs[6]_i_2\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_2\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of M_AXI_ARVALID_i_i_2 : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of M_AXI_WLAST_i_i_3 : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of S_AHB_HREADY_OUT_i_i_11 : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of S_AHB_HREADY_OUT_i_i_15 : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of S_AHB_HREADY_OUT_i_i_17 : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of S_AHB_HREADY_OUT_i_i_3 : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of S_AHB_HRESP_i_i_3 : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of ahb_hburst_incr_i_i_1 : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of ahb_hburst_single_i_i_2 : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of ahb_wnr_i_i_1 : label is "soft_lutpair5";
begin
  D(2 downto 0) <= \^d\(2 downto 0);
  \INFERRED_GEN.icount_out_reg[4]\ <= \^inferred_gen.icount_out_reg[4]\;
  ahb_hburst_incr_i_reg_0 <= \^ahb_hburst_incr_i_reg_0\;
  ahb_hburst_single <= \^ahb_hburst_single\;
  ahb_penult_beat_reg_0 <= \^ahb_penult_beat_reg_0\;
  burst_term <= \^burst_term\;
  \burst_term_cur_cnt_i_reg[4]_0\(4 downto 0) <= \^burst_term_cur_cnt_i_reg[4]_0\(4 downto 0);
  burst_term_hwrite <= \^burst_term_hwrite\;
  burst_term_single_incr <= \^burst_term_single_incr\;
  dummy_txfer_in_progress_reg_0 <= \^dummy_txfer_in_progress_reg_0\;
  idle_txfer_pending <= \^idle_txfer_pending\;
  m_axi_arprot(2 downto 0) <= \^m_axi_arprot\(2 downto 0);
  nonseq_detected <= \^nonseq_detected\;
  nonseq_txfer_pending <= \^nonseq_txfer_pending\;
  nonseq_txfer_pending_i_reg_0 <= \^nonseq_txfer_pending_i_reg_0\;
  s_ahb_hready_in_0 <= \^s_ahb_hready_in_0\;
  s_ahb_hready_out <= \^s_ahb_hready_out\;
  s_ahb_hresp <= \^s_ahb_hresp\;
  s_ahb_hsel_0 <= \^s_ahb_hsel_0\;
  set_axi_waddr <= \^set_axi_waddr\;
  \valid_cnt_required_i_reg[3]_0\(2 downto 0) <= \^valid_cnt_required_i_reg[3]_0\(2 downto 0);
\AXI_AADDR_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(0),
      Q => m_axi_araddr(0),
      R => SS(0)
    );
\AXI_AADDR_i_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(10),
      Q => m_axi_araddr(10),
      R => SS(0)
    );
\AXI_AADDR_i_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(11),
      Q => m_axi_araddr(11),
      R => SS(0)
    );
\AXI_AADDR_i_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(12),
      Q => m_axi_araddr(12),
      R => SS(0)
    );
\AXI_AADDR_i_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(13),
      Q => m_axi_araddr(13),
      R => SS(0)
    );
\AXI_AADDR_i_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(14),
      Q => m_axi_araddr(14),
      R => SS(0)
    );
\AXI_AADDR_i_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(15),
      Q => m_axi_araddr(15),
      R => SS(0)
    );
\AXI_AADDR_i_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(16),
      Q => m_axi_araddr(16),
      R => SS(0)
    );
\AXI_AADDR_i_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(17),
      Q => m_axi_araddr(17),
      R => SS(0)
    );
\AXI_AADDR_i_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(18),
      Q => m_axi_araddr(18),
      R => SS(0)
    );
\AXI_AADDR_i_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(19),
      Q => m_axi_araddr(19),
      R => SS(0)
    );
\AXI_AADDR_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(1),
      Q => m_axi_araddr(1),
      R => SS(0)
    );
\AXI_AADDR_i_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(20),
      Q => m_axi_araddr(20),
      R => SS(0)
    );
\AXI_AADDR_i_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(21),
      Q => m_axi_araddr(21),
      R => SS(0)
    );
\AXI_AADDR_i_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(22),
      Q => m_axi_araddr(22),
      R => SS(0)
    );
\AXI_AADDR_i_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(23),
      Q => m_axi_araddr(23),
      R => SS(0)
    );
\AXI_AADDR_i_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(24),
      Q => m_axi_araddr(24),
      R => SS(0)
    );
\AXI_AADDR_i_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(25),
      Q => m_axi_araddr(25),
      R => SS(0)
    );
\AXI_AADDR_i_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(26),
      Q => m_axi_araddr(26),
      R => SS(0)
    );
\AXI_AADDR_i_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(27),
      Q => m_axi_araddr(27),
      R => SS(0)
    );
\AXI_AADDR_i_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(28),
      Q => m_axi_araddr(28),
      R => SS(0)
    );
\AXI_AADDR_i_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(29),
      Q => m_axi_araddr(29),
      R => SS(0)
    );
\AXI_AADDR_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(2),
      Q => m_axi_araddr(2),
      R => SS(0)
    );
\AXI_AADDR_i_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(30),
      Q => m_axi_araddr(30),
      R => SS(0)
    );
\AXI_AADDR_i_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(31),
      Q => m_axi_araddr(31),
      R => SS(0)
    );
\AXI_AADDR_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(3),
      Q => m_axi_araddr(3),
      R => SS(0)
    );
\AXI_AADDR_i_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(4),
      Q => m_axi_araddr(4),
      R => SS(0)
    );
\AXI_AADDR_i_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(5),
      Q => m_axi_araddr(5),
      R => SS(0)
    );
\AXI_AADDR_i_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(6),
      Q => m_axi_araddr(6),
      R => SS(0)
    );
\AXI_AADDR_i_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(7),
      Q => m_axi_araddr(7),
      R => SS(0)
    );
\AXI_AADDR_i_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(8),
      Q => m_axi_araddr(8),
      R => SS(0)
    );
\AXI_AADDR_i_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_haddr(9),
      Q => m_axi_araddr(9),
      R => SS(0)
    );
\AXI_ABURST_i[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"888A"
    )
        port map (
      I0 => s_ahb_hresetn,
      I1 => s_ahb_hburst(0),
      I2 => s_ahb_hburst(2),
      I3 => s_ahb_hburst(1),
      O => AXI_ABURST_i(0)
    );
\AXI_ABURST_i[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"DF55555555555555"
    )
        port map (
      I0 => s_ahb_hresetn,
      I1 => ahb_hburst_incr,
      I2 => s_ahb_htrans(0),
      I3 => s_ahb_hready_in,
      I4 => s_ahb_hsel,
      I5 => s_ahb_htrans(1),
      O => \AXI_ABURST_i[1]_i_1_n_0\
    );
\AXI_ABURST_i[1]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"5400"
    )
        port map (
      I0 => s_ahb_hburst(0),
      I1 => s_ahb_hburst(2),
      I2 => s_ahb_hburst(1),
      I3 => s_ahb_hresetn,
      O => \AXI_ABURST_i[1]_i_2_n_0\
    );
\AXI_ABURST_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \AXI_ABURST_i[1]_i_1_n_0\,
      D => AXI_ABURST_i(0),
      Q => m_axi_arburst(0),
      R => '0'
    );
\AXI_ABURST_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \AXI_ABURST_i[1]_i_1_n_0\,
      D => \AXI_ABURST_i[1]_i_2_n_0\,
      Q => m_axi_arburst(1),
      R => '0'
    );
\AXI_ALEN_i[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => s_ahb_hburst(2),
      I1 => s_ahb_hburst(1),
      O => AXI_ALEN_i(1)
    );
\AXI_ALEN_i[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B0000000"
    )
        port map (
      I0 => ahb_hburst_incr,
      I1 => s_ahb_htrans(0),
      I2 => s_ahb_hready_in,
      I3 => s_ahb_hsel,
      I4 => s_ahb_htrans(1),
      O => AXI_ALEN_i0
    );
\AXI_ALEN_i[3]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => s_ahb_hburst(2),
      I1 => s_ahb_hburst(1),
      O => AXI_ALEN_i(3)
    );
\AXI_ALEN_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => AXI_ALEN_i(1),
      Q => m_axi_arlen(0),
      R => SS(0)
    );
\AXI_ALEN_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_hburst(2),
      Q => m_axi_arlen(1),
      R => SS(0)
    );
\AXI_ALEN_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => AXI_ALEN_i(3),
      Q => m_axi_arlen(2),
      R => SS(0)
    );
\AXI_ASIZE_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => s_ahb_hsize(0),
      Q => m_axi_arsize(0),
      R => SS(0)
    );
\AXI_ASIZE_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => s_ahb_hsize(1),
      Q => m_axi_arsize(1),
      R => SS(0)
    );
\AXI_ASIZE_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => s_ahb_hsize(2),
      Q => m_axi_arsize(2),
      R => SS(0)
    );
\FSM_onehot_ctl_sm_cs[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF0D00FFFFFFFF"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs_reg[0]\,
      I1 => \^idle_txfer_pending\,
      I2 => \^nonseq_txfer_pending_i_reg_0\,
      I3 => Q(3),
      I4 => \FSM_onehot_ctl_sm_cs_reg[0]_0\,
      I5 => \FSM_onehot_ctl_sm_cs[0]_i_4_n_0\,
      O => \^d\(0)
    );
\FSM_onehot_ctl_sm_cs[0]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BAAAAAAA"
    )
        port map (
      I0 => \^nonseq_txfer_pending\,
      I1 => s_ahb_htrans(0),
      I2 => s_ahb_htrans(1),
      I3 => s_ahb_hsel,
      I4 => s_ahb_hready_in,
      O => \^nonseq_txfer_pending_i_reg_0\
    );
\FSM_onehot_ctl_sm_cs[0]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F0F0F040FFFFFFFF"
    )
        port map (
      I0 => \^idle_txfer_pending\,
      I1 => m_axi_bresp(0),
      I2 => m_axi_bvalid,
      I3 => \^nonseq_detected\,
      I4 => \^nonseq_txfer_pending\,
      I5 => Q(2),
      O => \FSM_onehot_ctl_sm_cs[0]_i_4_n_0\
    );
\FSM_onehot_ctl_sm_cs[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000004000000000"
    )
        port map (
      I0 => \^idle_txfer_pending\,
      I1 => m_axi_bresp(0),
      I2 => m_axi_bvalid,
      I3 => \^nonseq_detected\,
      I4 => \^nonseq_txfer_pending\,
      I5 => Q(2),
      O => \^d\(1)
    );
\FSM_onehot_ctl_sm_cs[6]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000008"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs_reg[0]\,
      I1 => Q(3),
      I2 => \^idle_txfer_pending\,
      I3 => \^nonseq_detected\,
      I4 => \^nonseq_txfer_pending\,
      O => \^d\(2)
    );
\FSM_onehot_ctl_sm_cs[6]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => ahb_hburst_incr,
      I1 => s_ahb_htrans(0),
      I2 => s_ahb_hready_in,
      I3 => s_ahb_hsel,
      I4 => s_ahb_htrans(1),
      I5 => Q(0),
      O => \^ahb_hburst_incr_i_reg_0\
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_ACACHE_i_reg[0]\: unisim.vcomponents.FDSE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_hprot(2),
      Q => m_axi_arcache(0),
      S => SS(0)
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_ACACHE_i_reg[1]\: unisim.vcomponents.FDSE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_hprot(3),
      Q => m_axi_arcache(1),
      S => SS(0)
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AEAEAAAEFFFFFFFF"
    )
        port map (
      I0 => \^m_axi_arprot\(1),
      I1 => s_ahb_htrans(1),
      I2 => \^s_ahb_hsel_0\,
      I3 => s_ahb_htrans(0),
      I4 => ahb_hburst_incr,
      I5 => s_ahb_hresetn,
      O => \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1_n_0\
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => s_ahb_hsel,
      I1 => s_ahb_hready_in,
      O => \^s_ahb_hsel_0\
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[2]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => s_ahb_hprot(0),
      O => p_1_out(2)
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => s_ahb_hprot(1),
      Q => \^m_axi_arprot\(0),
      R => SS(0)
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => \GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i[1]_i_1_n_0\,
      Q => \^m_axi_arprot\(1),
      R => '0'
    );
\GEN_1_PROT_CACHE_REG_NON_SECURE.AXI_APROT_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => AXI_ALEN_i0,
      D => p_1_out(2),
      Q => \^m_axi_arprot\(2),
      R => SS(0)
    );
\INFERRED_GEN.icount_out[4]_i_1__0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"5D00000000000000"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => s_ahb_hwrite,
      I2 => ahb_hburst_incr,
      I3 => s_ahb_htrans(1),
      I4 => s_ahb_hsel,
      I5 => s_ahb_hready_in,
      O => E(0)
    );
M_AXI_ARVALID_i_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"DC"
    )
        port map (
      I0 => m_axi_arready,
      I1 => set_axi_raddr,
      I2 => M_AXI_ARVALID_i_reg,
      O => m_axi_arready_0
    );
M_AXI_ARVALID_i_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0CCD0CFF"
    )
        port map (
      I0 => ahb_wnr_i_reg_0,
      I1 => ahb_wnr_i_reg,
      I2 => \^burst_term_hwrite\,
      I3 => s_ahb_hwrite,
      I4 => \^ahb_hburst_incr_i_reg_0\,
      O => set_axi_raddr
    );
M_AXI_AWVALID_i_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"DC"
    )
        port map (
      I0 => m_axi_awready,
      I1 => \^set_axi_waddr\,
      I2 => m_axi_awvalid,
      O => m_axi_awready_0
    );
M_AXI_WLAST_i_i_3: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFF44444"
    )
        port map (
      I0 => m_axi_wready,
      I1 => ahb_done_axi_in_progress_reg_0,
      I2 => ahb_hburst_incr,
      I3 => \^ahb_hburst_single\,
      I4 => M_AXI_WVALID_i_reg_0(0),
      O => m_axi_wready_0
    );
M_AXI_WVALID_i_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFF0004040000"
    )
        port map (
      I0 => ahb_hburst_incr,
      I1 => Q(1),
      I2 => \^ahb_hburst_single\,
      I3 => ahb_data_valid_burst_term,
      I4 => M_AXI_WVALID_i_reg,
      I5 => M_AXI_WVALID_i_reg_0(0),
      O => ahb_hburst_incr_i_reg_1
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00009009"
    )
        port map (
      I0 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(0),
      I1 => \^burst_term_cur_cnt_i_reg[4]_0\(0),
      I2 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(3),
      I3 => \^burst_term_cur_cnt_i_reg[4]_0\(3),
      I4 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7_n_0\,
      O => \INFERRED_GEN.icount_out_reg[0]_0\
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_6\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => \^burst_term_cur_cnt_i_reg[4]_0\(0),
      I1 => \^burst_term_cur_cnt_i_reg[4]_0\(1),
      I2 => \^burst_term_cur_cnt_i_reg[4]_0\(2),
      O => \burst_term_cur_cnt_i_reg[0]_0\
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6FF6FFFFFFFF6FF6"
    )
        port map (
      I0 => \^burst_term_cur_cnt_i_reg[4]_0\(4),
      I1 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(4),
      I2 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(1),
      I3 => \^burst_term_cur_cnt_i_reg[4]_0\(1),
      I4 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(2),
      I5 => \^burst_term_cur_cnt_i_reg[4]_0\(2),
      O => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_7_n_0\
    );
\S_AHB_HRDATA_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(0),
      Q => s_ahb_hrdata(0),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(10),
      Q => s_ahb_hrdata(10),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(11),
      Q => s_ahb_hrdata(11),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(12),
      Q => s_ahb_hrdata(12),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(13),
      Q => s_ahb_hrdata(13),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(14),
      Q => s_ahb_hrdata(14),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(15),
      Q => s_ahb_hrdata(15),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(16),
      Q => s_ahb_hrdata(16),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(17),
      Q => s_ahb_hrdata(17),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(18),
      Q => s_ahb_hrdata(18),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(19),
      Q => s_ahb_hrdata(19),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(1),
      Q => s_ahb_hrdata(1),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(20),
      Q => s_ahb_hrdata(20),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(21),
      Q => s_ahb_hrdata(21),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(22),
      Q => s_ahb_hrdata(22),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(23),
      Q => s_ahb_hrdata(23),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(24),
      Q => s_ahb_hrdata(24),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(25),
      Q => s_ahb_hrdata(25),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(26),
      Q => s_ahb_hrdata(26),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(27),
      Q => s_ahb_hrdata(27),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(28),
      Q => s_ahb_hrdata(28),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(29),
      Q => s_ahb_hrdata(29),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(2),
      Q => s_ahb_hrdata(2),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(30),
      Q => s_ahb_hrdata(30),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(31),
      Q => s_ahb_hrdata(31),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[32]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(32),
      Q => s_ahb_hrdata(32),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[33]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(33),
      Q => s_ahb_hrdata(33),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[34]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(34),
      Q => s_ahb_hrdata(34),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[35]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(35),
      Q => s_ahb_hrdata(35),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[36]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(36),
      Q => s_ahb_hrdata(36),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[37]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(37),
      Q => s_ahb_hrdata(37),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[38]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(38),
      Q => s_ahb_hrdata(38),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[39]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(39),
      Q => s_ahb_hrdata(39),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(3),
      Q => s_ahb_hrdata(3),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[40]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(40),
      Q => s_ahb_hrdata(40),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[41]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(41),
      Q => s_ahb_hrdata(41),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[42]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(42),
      Q => s_ahb_hrdata(42),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[43]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(43),
      Q => s_ahb_hrdata(43),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[44]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(44),
      Q => s_ahb_hrdata(44),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[45]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(45),
      Q => s_ahb_hrdata(45),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[46]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(46),
      Q => s_ahb_hrdata(46),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[47]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(47),
      Q => s_ahb_hrdata(47),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[48]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(48),
      Q => s_ahb_hrdata(48),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[49]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(49),
      Q => s_ahb_hrdata(49),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(4),
      Q => s_ahb_hrdata(4),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[50]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(50),
      Q => s_ahb_hrdata(50),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[51]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(51),
      Q => s_ahb_hrdata(51),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[52]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(52),
      Q => s_ahb_hrdata(52),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[53]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(53),
      Q => s_ahb_hrdata(53),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[54]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(54),
      Q => s_ahb_hrdata(54),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[55]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(55),
      Q => s_ahb_hrdata(55),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[56]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(56),
      Q => s_ahb_hrdata(56),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[57]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(57),
      Q => s_ahb_hrdata(57),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[58]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(58),
      Q => s_ahb_hrdata(58),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[59]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(59),
      Q => s_ahb_hrdata(59),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(5),
      Q => s_ahb_hrdata(5),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[60]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(60),
      Q => s_ahb_hrdata(60),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[61]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(61),
      Q => s_ahb_hrdata(61),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[62]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(62),
      Q => s_ahb_hrdata(62),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[63]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(63),
      Q => s_ahb_hrdata(63),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(6),
      Q => s_ahb_hrdata(6),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(7),
      Q => s_ahb_hrdata(7),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(8),
      Q => s_ahb_hrdata(8),
      R => SS(0)
    );
\S_AHB_HRDATA_i_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \S_AHB_HRDATA_i_reg[63]_0\(0),
      D => m_axi_rdata(9),
      Q => s_ahb_hrdata(9),
      R => SS(0)
    );
S_AHB_HREADY_OUT_i_i_10: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFF3FFF3AAA20000"
    )
        port map (
      I0 => AXI_ALEN_i(1),
      I1 => S_AHB_HRESP_i_reg_0,
      I2 => S_AHB_HREADY_OUT_i_i_11_n_0,
      I3 => S_AHB_HREADY_OUT_i_i_16_n_0,
      I4 => s_ahb_hwrite,
      I5 => \^ahb_hburst_incr_i_reg_0\,
      O => S_AHB_HREADY_OUT_i_i_10_n_0
    );
S_AHB_HREADY_OUT_i_i_11: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000E000"
    )
        port map (
      I0 => s_ahb_hburst(1),
      I1 => s_ahb_hburst(2),
      I2 => s_ahb_hwrite,
      I3 => \^burst_term_hwrite\,
      I4 => \^burst_term_single_incr\,
      O => S_AHB_HREADY_OUT_i_i_11_n_0
    );
S_AHB_HREADY_OUT_i_i_14: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => ahb_hburst_incr,
      I1 => s_ahb_htrans(0),
      I2 => s_ahb_hready_in,
      I3 => s_ahb_hsel,
      I4 => s_ahb_htrans(1),
      O => S_AHB_HREADY_OUT_i_i_14_n_0
    );
S_AHB_HREADY_OUT_i_i_15: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => \^ahb_penult_beat_reg_0\,
      I1 => s_ahb_htrans(0),
      I2 => s_ahb_hready_in,
      I3 => s_ahb_hsel,
      I4 => s_ahb_htrans(1),
      O => ahb_burst_done
    );
S_AHB_HREADY_OUT_i_i_16: unisim.vcomponents.LUT6
    generic map(
      INIT => X"45555555FFFFFFFF"
    )
        port map (
      I0 => \^nonseq_txfer_pending\,
      I1 => s_ahb_htrans(0),
      I2 => s_ahb_htrans(1),
      I3 => s_ahb_hsel,
      I4 => s_ahb_hready_in,
      I5 => Q(3),
      O => S_AHB_HREADY_OUT_i_i_16_n_0
    );
S_AHB_HREADY_OUT_i_i_17: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => ahb_hburst_incr,
      I1 => \^ahb_hburst_single\,
      O => ahb_hburst_incr_i_reg_2
    );
S_AHB_HREADY_OUT_i_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000FFFA0000FCFA"
    )
        port map (
      I0 => \^s_ahb_hready_in_0\,
      I1 => S_AHB_HREADY_OUT_i_i_4_n_0,
      I2 => p_10_in,
      I3 => S_AHB_HREADY_OUT_i_i_6_n_0,
      I4 => S_AHB_HREADY_OUT_i_i_7_n_0,
      I5 => \^s_ahb_hready_out\,
      O => S_AHB_HREADY_OUT_i_i_2_n_0
    );
S_AHB_HREADY_OUT_i_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0080"
    )
        port map (
      I0 => s_ahb_hready_in,
      I1 => s_ahb_hsel,
      I2 => s_ahb_htrans(0),
      I3 => s_ahb_htrans(1),
      O => \^s_ahb_hready_in_0\
    );
S_AHB_HREADY_OUT_i_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"EEEF"
    )
        port map (
      I0 => S_AHB_HREADY_OUT_i_reg_2,
      I1 => S_AHB_HRESP_i_i_4_n_0,
      I2 => S_AHB_HRESP_i_i_3_n_0,
      I3 => S_AHB_HREADY_OUT_i_reg_3,
      O => S_AHB_HREADY_OUT_i_i_4_n_0
    );
S_AHB_HREADY_OUT_i_i_6: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000000008A"
    )
        port map (
      I0 => S_AHB_HREADY_OUT_i_i_10_n_0,
      I1 => S_AHB_HREADY_OUT_i_i_11_n_0,
      I2 => ahb_wnr_i_reg,
      I3 => S_AHB_HREADY_OUT_i_reg_0,
      I4 => \^d\(1),
      I5 => S_AHB_HREADY_OUT_i_reg_1,
      O => S_AHB_HREADY_OUT_i_i_6_n_0
    );
S_AHB_HREADY_OUT_i_i_7: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFEFFFCFFFE"
    )
        port map (
      I0 => S_AHB_HREADY_OUT_i_i_14_n_0,
      I1 => S_AHB_HREADY_OUT_i_reg_4,
      I2 => ahb_done_axi_in_progress,
      I3 => \^nonseq_txfer_pending\,
      I4 => s_ahb_hwrite,
      I5 => ahb_burst_done,
      O => S_AHB_HREADY_OUT_i_i_7_n_0
    );
S_AHB_HREADY_OUT_i_reg: unisim.vcomponents.FDSE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => S_AHB_HREADY_OUT_i_i_2_n_0,
      Q => \^s_ahb_hready_out\,
      S => SS(0)
    );
S_AHB_HRESP_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000A80000"
    )
        port map (
      I0 => s_ahb_hresetn,
      I1 => set_hresp_err,
      I2 => \^s_ahb_hresp\,
      I3 => Q(0),
      I4 => S_AHB_HRESP_i_i_3_n_0,
      I5 => S_AHB_HRESP_i_i_4_n_0,
      O => S_AHB_HRESP_i_i_1_n_0
    );
S_AHB_HRESP_i_i_3: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFFFFB"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs_reg[0]\,
      I1 => Q(3),
      I2 => \^idle_txfer_pending\,
      I3 => \^nonseq_detected\,
      I4 => \^nonseq_txfer_pending\,
      O => S_AHB_HRESP_i_i_3_n_0
    );
S_AHB_HRESP_i_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"44F4444444444444"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs[0]_i_4_n_0\,
      I1 => m_axi_bvalid,
      I2 => Q(3),
      I3 => \^nonseq_txfer_pending_i_reg_0\,
      I4 => \^idle_txfer_pending\,
      I5 => S_AHB_HRESP_i_reg_0,
      O => S_AHB_HRESP_i_i_4_n_0
    );
S_AHB_HRESP_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => S_AHB_HRESP_i_i_1_n_0,
      Q => \^s_ahb_hresp\,
      R => '0'
    );
ahb_data_valid_burst_term_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"BA"
    )
        port map (
      I0 => \^nonseq_txfer_pending\,
      I1 => dummy_txfer_in_progress_reg_1,
      I2 => ahb_data_valid_burst_term,
      O => nonseq_txfer_pending_i_reg_1
    );
ahb_data_valid_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => ahb_data_valid_i_reg_0,
      Q => ahb_data_valid,
      R => SS(0)
    );
ahb_done_axi_in_progress_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"4FFF4444"
    )
        port map (
      I0 => ahb_done_axi_in_progress_reg_1,
      I1 => \^ahb_penult_beat_reg_0\,
      I2 => m_axi_wready,
      I3 => ahb_done_axi_in_progress_reg_0,
      I4 => ahb_done_axi_in_progress,
      O => ahb_done_axi_in_progress_i_1_n_0
    );
ahb_done_axi_in_progress_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => ahb_done_axi_in_progress_i_1_n_0,
      Q => ahb_done_axi_in_progress,
      R => SS(0)
    );
ahb_hburst_incr_i_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"02"
    )
        port map (
      I0 => s_ahb_hburst(0),
      I1 => s_ahb_hburst(1),
      I2 => s_ahb_hburst(2),
      O => eqOp
    );
ahb_hburst_incr_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => S_AHB_HSIZE_i0,
      D => eqOp,
      Q => ahb_hburst_incr,
      R => SS(0)
    );
ahb_hburst_single_i_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => \^s_ahb_hready_out\,
      I1 => s_ahb_htrans(1),
      I2 => s_ahb_htrans(0),
      O => S_AHB_HSIZE_i0
    );
ahb_hburst_single_i_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => s_ahb_hburst(0),
      I1 => s_ahb_hburst(1),
      I2 => s_ahb_hburst(2),
      O => eqOp0_in
    );
ahb_hburst_single_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => S_AHB_HSIZE_i0,
      D => eqOp0_in,
      Q => \^ahb_hburst_single\,
      R => SS(0)
    );
ahb_penult_beat_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => ahb_penult_beat_reg_1,
      Q => \^ahb_penult_beat_reg_0\,
      R => '0'
    );
ahb_wnr_i_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CF88FFAA"
    )
        port map (
      I0 => \^burst_term_hwrite\,
      I1 => ahb_wnr_i_reg,
      I2 => \^ahb_hburst_incr_i_reg_0\,
      I3 => s_ahb_hwrite,
      I4 => ahb_wnr_i_reg_0,
      O => \^set_axi_waddr\
    );
axi_last_beat_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4008048000000000"
    )
        port map (
      I0 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(0),
      I1 => \^inferred_gen.icount_out_reg[4]\,
      I2 => burst_term_txer_cnt(2),
      I3 => burst_term_txer_cnt(1),
      I4 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(2),
      I5 => \^burst_term\,
      O => \INFERRED_GEN.icount_out_reg[0]\
    );
axi_penult_beat_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFF9FFFF6FFFFFFF"
    )
        port map (
      I0 => burst_term_txer_cnt(2),
      I1 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(2),
      I2 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(0),
      I3 => burst_term_txer_cnt(1),
      I4 => \^burst_term\,
      I5 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(1),
      O => \burst_term_txer_cnt_i_reg[2]_0\
    );
axi_penult_beat_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"44421114"
    )
        port map (
      I0 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(4),
      I1 => burst_term_txer_cnt(3),
      I2 => burst_term_txer_cnt(1),
      I3 => burst_term_txer_cnt(2),
      I4 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(3),
      O => \^inferred_gen.icount_out_reg[4]\
    );
\burst_term_cur_cnt_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \burst_term_cur_cnt_i_reg[4]_1\(0),
      Q => \^burst_term_cur_cnt_i_reg[4]_0\(0),
      R => SS(0)
    );
\burst_term_cur_cnt_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \burst_term_cur_cnt_i_reg[4]_1\(1),
      Q => \^burst_term_cur_cnt_i_reg[4]_0\(1),
      R => SS(0)
    );
\burst_term_cur_cnt_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \burst_term_cur_cnt_i_reg[4]_1\(2),
      Q => \^burst_term_cur_cnt_i_reg[4]_0\(2),
      R => SS(0)
    );
\burst_term_cur_cnt_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \burst_term_cur_cnt_i_reg[4]_1\(3),
      Q => \^burst_term_cur_cnt_i_reg[4]_0\(3),
      R => SS(0)
    );
\burst_term_cur_cnt_i_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \burst_term_cur_cnt_i_reg[4]_1\(4),
      Q => \^burst_term_cur_cnt_i_reg[4]_0\(4),
      R => SS(0)
    );
burst_term_hwrite_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => burst_term_hwrite_reg_0,
      Q => \^burst_term_hwrite\,
      R => SS(0)
    );
burst_term_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => burst_term_i_reg_0,
      Q => \^burst_term\,
      R => '0'
    );
burst_term_single_incr_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => burst_term_single_incr_reg_0,
      Q => \^burst_term_single_incr\,
      R => SS(0)
    );
\burst_term_txer_cnt_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \^valid_cnt_required_i_reg[3]_0\(0),
      Q => burst_term_txer_cnt(1),
      R => SS(0)
    );
\burst_term_txer_cnt_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \^valid_cnt_required_i_reg[3]_0\(1),
      Q => burst_term_txer_cnt(2),
      R => SS(0)
    );
\burst_term_txer_cnt_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \burst_term_txer_cnt_i_reg[3]_0\(0),
      D => \^valid_cnt_required_i_reg[3]_0\(2),
      Q => burst_term_txer_cnt(3),
      R => SS(0)
    );
dummy_txfer_in_progress_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"C555C00000000000"
    )
        port map (
      I0 => dummy_txfer_in_progress_reg_1,
      I1 => \^burst_term\,
      I2 => ahb_done_axi_in_progress_reg_0,
      I3 => m_axi_wready,
      I4 => \^dummy_txfer_in_progress_reg_0\,
      I5 => s_ahb_hresetn,
      O => dummy_txfer_in_progress_i_1_n_0
    );
dummy_txfer_in_progress_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => dummy_txfer_in_progress_i_1_n_0,
      Q => \^dummy_txfer_in_progress_reg_0\,
      R => '0'
    );
idle_txfer_pending_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => idle_txfer_pending_reg_0,
      Q => \^idle_txfer_pending\,
      R => '0'
    );
nonseq_txfer_pending_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => nonseq_txfer_pending_i_reg_2,
      Q => \^nonseq_txfer_pending\,
      R => SS(0)
    );
\valid_cnt_required_i[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0080"
    )
        port map (
      I0 => s_ahb_hready_in,
      I1 => s_ahb_hsel,
      I2 => s_ahb_htrans(1),
      I3 => s_ahb_htrans(0),
      O => \^nonseq_detected\
    );
\valid_cnt_required_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^nonseq_detected\,
      D => AXI_ALEN_i(1),
      Q => \^valid_cnt_required_i_reg[3]_0\(0),
      R => SS(0)
    );
\valid_cnt_required_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^nonseq_detected\,
      D => s_ahb_hburst(2),
      Q => \^valid_cnt_required_i_reg[3]_0\(1),
      R => SS(0)
    );
\valid_cnt_required_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^nonseq_detected\,
      D => AXI_ALEN_i(3),
      Q => \^valid_cnt_required_i_reg[3]_0\(2),
      R => SS(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_control is
  port (
    axi_waddr_done_i : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 3 downto 0 );
    burst_term_i_reg : out STD_LOGIC;
    idle_txfer_pending_reg : out STD_LOGIC;
    s_ahb_htrans_1_sp_1 : out STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[3]_0\ : out STD_LOGIC;
    s_ahb_htrans_0_sp_1 : out STD_LOGIC;
    set_hresp_err : out STD_LOGIC;
    p_10_in : out STD_LOGIC;
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    \FSM_onehot_ctl_sm_cs_reg[4]_0\ : out STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[2]_0\ : out STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[4]_1\ : out STD_LOGIC;
    \s_ahb_htrans[1]_0\ : out STD_LOGIC;
    s_ahb_hwrite_0 : out STD_LOGIC;
    m_axi_bvalid_0 : out STD_LOGIC;
    \s_ahb_hburst[2]\ : out STD_LOGIC;
    \s_ahb_htrans[0]_0\ : out STD_LOGIC;
    SS : in STD_LOGIC_VECTOR ( 0 to 0 );
    set_axi_waddr : in STD_LOGIC;
    s_ahb_hclk : in STD_LOGIC;
    last_axi_rd_sample : in STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[0]_0\ : in STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[0]_1\ : in STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    burst_term_i_reg_0 : in STD_LOGIC;
    burst_term : in STD_LOGIC;
    burst_term_i_reg_1 : in STD_LOGIC;
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 1 downto 0 );
    idle_txfer_pending : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    nonseq_detected : in STD_LOGIC;
    nonseq_txfer_pending : in STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[0]_2\ : in STD_LOGIC;
    m_axi_bvalid : in STD_LOGIC;
    D : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_RREADY_i_reg : in STD_LOGIC;
    nonseq_txfer_pending_i_reg : in STD_LOGIC;
    S_AHB_HRESP_i_reg : in STD_LOGIC;
    m_axi_bresp : in STD_LOGIC_VECTOR ( 0 to 0 );
    \FSM_onehot_ctl_sm_cs_reg[0]_3\ : in STD_LOGIC;
    s_ahb_hsel : in STD_LOGIC;
    s_ahb_hready_in : in STD_LOGIC;
    ahb_hburst_single : in STD_LOGIC;
    S_AHB_HREADY_OUT_i_i_6 : in STD_LOGIC;
    s_ahb_hwrite : in STD_LOGIC;
    S_AHB_HREADY_OUT_i_i_6_0 : in STD_LOGIC;
    burst_term_hwrite : in STD_LOGIC;
    m_axi_bready : in STD_LOGIC;
    s_ahb_hburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    burst_term_single_incr : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_control;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_control is
  signal \FSM_onehot_ctl_sm_cs[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs[2]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs[5]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs[6]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs[6]_i_5_n_0\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs_reg_n_0_[1]\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs_reg_n_0_[4]\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs_reg_n_0_[6]\ : STD_LOGIC;
  signal M_AXI_RLAST_reg : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \^axi_waddr_done_i\ : STD_LOGIC;
  signal idle_txfer_pending_i_2_n_0 : STD_LOGIC;
  signal \^idle_txfer_pending_reg\ : STD_LOGIC;
  signal \^s_ahb_htrans[0]_0\ : STD_LOGIC;
  signal s_ahb_htrans_0_sn_1 : STD_LOGIC;
  signal s_ahb_htrans_1_sn_1 : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_onehot_ctl_sm_cs[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \FSM_onehot_ctl_sm_cs[5]_i_1\ : label is "soft_lutpair2";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_onehot_ctl_sm_cs_reg[0]\ : label is "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_ctl_sm_cs_reg[1]\ : label is "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_ctl_sm_cs_reg[2]\ : label is "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_ctl_sm_cs_reg[3]\ : label is "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_ctl_sm_cs_reg[4]\ : label is "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_ctl_sm_cs_reg[5]\ : label is "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000";
  attribute FSM_ENCODED_STATES of \FSM_onehot_ctl_sm_cs_reg[6]\ : label is "ctl_bresp:0001000,ctl_write:0000100,ctl_read_err:1000000,ctl_read:0100000,ctl_addr:0000010,ctl_idle:0000001,ctl_bresp_err:0010000";
  attribute SOFT_HLUTNM of S_AHB_HREADY_OUT_i_i_5 : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of burst_term_single_incr_i_2 : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \burst_term_txer_cnt_i[3]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of idle_txfer_pending_i_2 : label is "soft_lutpair1";
begin
  Q(3 downto 0) <= \^q\(3 downto 0);
  axi_waddr_done_i <= \^axi_waddr_done_i\;
  idle_txfer_pending_reg <= \^idle_txfer_pending_reg\;
  \s_ahb_htrans[0]_0\ <= \^s_ahb_htrans[0]_0\;
  s_ahb_htrans_0_sp_1 <= s_ahb_htrans_0_sn_1;
  s_ahb_htrans_1_sp_1 <= s_ahb_htrans_1_sn_1;
\FSM_onehot_ctl_sm_cs[0]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"EA"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs_reg_n_0_[4]\,
      I1 => M_AXI_RLAST_reg,
      I2 => \FSM_onehot_ctl_sm_cs_reg_n_0_[6]\,
      O => \FSM_onehot_ctl_sm_cs_reg[4]_1\
    );
\FSM_onehot_ctl_sm_cs[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFF08880"
    )
        port map (
      I0 => m_axi_bvalid,
      I1 => \^q\(2),
      I2 => nonseq_txfer_pending,
      I3 => nonseq_detected,
      I4 => \^q\(3),
      I5 => \^q\(0),
      O => \FSM_onehot_ctl_sm_cs[1]_i_1_n_0\
    );
\FSM_onehot_ctl_sm_cs[2]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs_reg_n_0_[1]\,
      I1 => \^axi_waddr_done_i\,
      O => \FSM_onehot_ctl_sm_cs[2]_i_1_n_0\
    );
\FSM_onehot_ctl_sm_cs[5]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4F44"
    )
        port map (
      I0 => \^axi_waddr_done_i\,
      I1 => \FSM_onehot_ctl_sm_cs_reg_n_0_[1]\,
      I2 => M_AXI_RLAST_reg,
      I3 => \FSM_onehot_ctl_sm_cs_reg_n_0_[6]\,
      O => \FSM_onehot_ctl_sm_cs[5]_i_1_n_0\
    );
\FSM_onehot_ctl_sm_cs[6]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFBBBBBBB"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs[6]_i_3_n_0\,
      I1 => \FSM_onehot_ctl_sm_cs_reg[0]_0\,
      I2 => \FSM_onehot_ctl_sm_cs_reg[0]_1\,
      I3 => m_axi_wready,
      I4 => \^q\(1),
      I5 => \FSM_onehot_ctl_sm_cs[6]_i_5_n_0\,
      O => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\
    );
\FSM_onehot_ctl_sm_cs[6]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF1000"
    )
        port map (
      I0 => S_AHB_HRESP_i_reg,
      I1 => idle_txfer_pending,
      I2 => \^q\(3),
      I3 => \FSM_onehot_ctl_sm_cs_reg[0]_3\,
      I4 => \FSM_onehot_ctl_sm_cs_reg_n_0_[6]\,
      I5 => \FSM_onehot_ctl_sm_cs_reg_n_0_[4]\,
      O => \FSM_onehot_ctl_sm_cs[6]_i_3_n_0\
    );
\FSM_onehot_ctl_sm_cs[6]_i_5\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFFF888"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs_reg[0]_2\,
      I1 => \^q\(3),
      I2 => m_axi_bvalid,
      I3 => \^q\(2),
      I4 => \FSM_onehot_ctl_sm_cs_reg_n_0_[1]\,
      O => \FSM_onehot_ctl_sm_cs[6]_i_5_n_0\
    );
\FSM_onehot_ctl_sm_cs_reg[0]\: unisim.vcomponents.FDSE
    generic map(
      INIT => '1'
    )
        port map (
      C => s_ahb_hclk,
      CE => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\,
      D => D(0),
      Q => \^q\(0),
      S => SS(0)
    );
\FSM_onehot_ctl_sm_cs_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_ahb_hclk,
      CE => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\,
      D => \FSM_onehot_ctl_sm_cs[1]_i_1_n_0\,
      Q => \FSM_onehot_ctl_sm_cs_reg_n_0_[1]\,
      R => SS(0)
    );
\FSM_onehot_ctl_sm_cs_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_ahb_hclk,
      CE => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\,
      D => \FSM_onehot_ctl_sm_cs[2]_i_1_n_0\,
      Q => \^q\(1),
      R => SS(0)
    );
\FSM_onehot_ctl_sm_cs_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_ahb_hclk,
      CE => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\,
      D => \^q\(1),
      Q => \^q\(2),
      R => SS(0)
    );
\FSM_onehot_ctl_sm_cs_reg[4]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_ahb_hclk,
      CE => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\,
      D => D(1),
      Q => \FSM_onehot_ctl_sm_cs_reg_n_0_[4]\,
      R => SS(0)
    );
\FSM_onehot_ctl_sm_cs_reg[5]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_ahb_hclk,
      CE => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\,
      D => \FSM_onehot_ctl_sm_cs[5]_i_1_n_0\,
      Q => \^q\(3),
      R => SS(0)
    );
\FSM_onehot_ctl_sm_cs_reg[6]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => s_ahb_hclk,
      CE => \FSM_onehot_ctl_sm_cs[6]_i_1_n_0\,
      D => D(2),
      Q => \FSM_onehot_ctl_sm_cs_reg_n_0_[6]\,
      R => SS(0)
    );
M_AXI_BREADY_i_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"DC"
    )
        port map (
      I0 => m_axi_bvalid,
      I1 => \^axi_waddr_done_i\,
      I2 => m_axi_bready,
      O => m_axi_bvalid_0
    );
M_AXI_RLAST_reg_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => last_axi_rd_sample,
      Q => M_AXI_RLAST_reg,
      R => SS(0)
    );
M_AXI_RREADY_i_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FEFEFEFEFEFFFEFE"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs[6]_i_3_n_0\,
      I1 => D(1),
      I2 => M_AXI_RREADY_i_reg,
      I3 => nonseq_txfer_pending_i_reg,
      I4 => s_ahb_htrans(0),
      I5 => s_ahb_htrans(1),
      O => s_ahb_htrans_0_sn_1
    );
S_AHB_HREADY_OUT_i_i_12: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF4FCC44CC44CC44"
    )
        port map (
      I0 => S_AHB_HREADY_OUT_i_i_6,
      I1 => \^q\(1),
      I2 => s_ahb_hwrite,
      I3 => S_AHB_HREADY_OUT_i_i_6_0,
      I4 => \FSM_onehot_ctl_sm_cs_reg_n_0_[1]\,
      I5 => \^axi_waddr_done_i\,
      O => \FSM_onehot_ctl_sm_cs_reg[2]_0\
    );
S_AHB_HREADY_OUT_i_i_5: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00001000"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => \^q\(0),
      I2 => s_ahb_hsel,
      I3 => s_ahb_hready_in,
      I4 => s_ahb_htrans(1),
      O => p_10_in
    );
S_AHB_HREADY_OUT_i_i_8: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FEFFFEFEFEFEFEFE"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs_reg_n_0_[4]\,
      I1 => \FSM_onehot_ctl_sm_cs_reg_n_0_[6]\,
      I2 => \FSM_onehot_ctl_sm_cs[2]_i_1_n_0\,
      I3 => ahb_hburst_single,
      I4 => \^q\(1),
      I5 => S_AHB_HREADY_OUT_i_i_6,
      O => \FSM_onehot_ctl_sm_cs_reg[4]_0\
    );
S_AHB_HRESP_i_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF00002000"
    )
        port map (
      I0 => \^q\(2),
      I1 => S_AHB_HRESP_i_reg,
      I2 => m_axi_bvalid,
      I3 => m_axi_bresp(0),
      I4 => idle_txfer_pending,
      I5 => \FSM_onehot_ctl_sm_cs[6]_i_3_n_0\,
      O => set_hresp_err
    );
ahb_wnr_i_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8880"
    )
        port map (
      I0 => \^q\(2),
      I1 => m_axi_bvalid,
      I2 => nonseq_txfer_pending,
      I3 => nonseq_detected,
      O => \FSM_onehot_ctl_sm_cs_reg[3]_0\
    );
ahb_wnr_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => set_axi_waddr,
      Q => \^axi_waddr_done_i\,
      R => SS(0)
    );
burst_term_hwrite_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFEFFFF00020000"
    )
        port map (
      I0 => s_ahb_hwrite,
      I1 => s_ahb_htrans(0),
      I2 => \^q\(0),
      I3 => nonseq_txfer_pending_i_reg,
      I4 => s_ahb_htrans(1),
      I5 => burst_term_hwrite,
      O => s_ahb_hwrite_0
    );
burst_term_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000001130"
    )
        port map (
      I0 => \^idle_txfer_pending_reg\,
      I1 => burst_term_i_reg_0,
      I2 => idle_txfer_pending_i_2_n_0,
      I3 => burst_term,
      I4 => burst_term_i_reg_1,
      I5 => last_axi_rd_sample,
      O => burst_term_i_reg
    );
burst_term_single_incr_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FF10"
    )
        port map (
      I0 => s_ahb_hburst(1),
      I1 => s_ahb_hburst(0),
      I2 => \^s_ahb_htrans[0]_0\,
      I3 => burst_term_single_incr,
      O => \s_ahb_hburst[2]\
    );
burst_term_single_incr_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"10000000"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => \^q\(0),
      I2 => s_ahb_hsel,
      I3 => s_ahb_hready_in,
      I4 => s_ahb_htrans(1),
      O => \^s_ahb_htrans[0]_0\
    );
\burst_term_txer_cnt_i[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00001000"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => \^q\(0),
      I2 => s_ahb_hsel,
      I3 => s_ahb_hready_in,
      I4 => burst_term,
      O => E(0)
    );
idle_txfer_pending_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000F400"
    )
        port map (
      I0 => s_ahb_htrans(1),
      I1 => idle_txfer_pending_i_2_n_0,
      I2 => idle_txfer_pending,
      I3 => s_ahb_hresetn,
      I4 => \^idle_txfer_pending_reg\,
      O => s_ahb_htrans_1_sn_1
    );
idle_txfer_pending_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0008"
    )
        port map (
      I0 => s_ahb_hready_in,
      I1 => s_ahb_hsel,
      I2 => \^q\(0),
      I3 => s_ahb_htrans(0),
      O => idle_txfer_pending_i_2_n_0
    );
idle_txfer_pending_i_3: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAAAA8"
    )
        port map (
      I0 => \FSM_onehot_ctl_sm_cs[6]_i_5_n_0\,
      I1 => idle_txfer_pending,
      I2 => nonseq_detected,
      I3 => nonseq_txfer_pending,
      I4 => \FSM_onehot_ctl_sm_cs_reg_n_0_[1]\,
      O => \^idle_txfer_pending_reg\
    );
nonseq_txfer_pending_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0002FFFF00020002"
    )
        port map (
      I0 => s_ahb_htrans(1),
      I1 => nonseq_txfer_pending_i_reg,
      I2 => \^q\(0),
      I3 => s_ahb_htrans(0),
      I4 => \^idle_txfer_pending_reg\,
      I5 => nonseq_txfer_pending,
      O => \s_ahb_htrans[1]_0\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_rchannel is
  port (
    M_AXI_ARVALID_i_reg_0 : out STD_LOGIC;
    M_AXI_RREADY_i_reg_0 : out STD_LOGIC;
    s_ahb_htrans_1_sp_1 : out STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[5]\ : out STD_LOGIC;
    ahb_rd_txer_pending_reg_0 : out STD_LOGIC;
    last_axi_rd_sample : out STD_LOGIC;
    \FSM_onehot_ctl_sm_cs_reg[5]_0\ : out STD_LOGIC;
    \m_axi_rresp[1]\ : out STD_LOGIC;
    ahb_rd_req_reg_0 : out STD_LOGIC;
    M_AXI_RREADY_i_reg_1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    axi_rd_avlbl_reg_0 : out STD_LOGIC;
    s_ahb_hclk : in STD_LOGIC;
    SS : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_rlast : in STD_LOGIC;
    M_AXI_ARVALID_i_reg_1 : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 0 to 0 );
    nonseq_txfer_pending : in STD_LOGIC;
    nonseq_detected : in STD_LOGIC;
    ahb_rd_txer_pending_reg_1 : in STD_LOGIC;
    m_axi_rvalid : in STD_LOGIC;
    idle_txfer_pending : in STD_LOGIC;
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_ahb_hready_in : in STD_LOGIC;
    s_ahb_hsel : in STD_LOGIC;
    M_AXI_RREADY_i_reg_2 : in STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    \axi_rresp_avlbl_reg[1]_0\ : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_rchannel;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_rchannel is
  signal \FSM_onehot_ctl_sm_cs[6]_i_7_n_0\ : STD_LOGIC;
  signal \FSM_onehot_ctl_sm_cs[6]_i_8_n_0\ : STD_LOGIC;
  signal \^m_axi_arvalid_i_reg_0\ : STD_LOGIC;
  signal M_AXI_RREADY_i_i_1_n_0 : STD_LOGIC;
  signal \^m_axi_rready_i_reg_0\ : STD_LOGIC;
  signal ahb_rd_req : STD_LOGIC;
  signal ahb_rd_req_i_1_n_0 : STD_LOGIC;
  signal \^ahb_rd_req_reg_0\ : STD_LOGIC;
  signal ahb_rd_txer_pending : STD_LOGIC;
  signal ahb_rd_txer_pending_i_1_n_0 : STD_LOGIC;
  signal \^ahb_rd_txer_pending_reg_0\ : STD_LOGIC;
  signal axi_last_avlbl : STD_LOGIC;
  signal axi_last_avlbl_reg_n_0 : STD_LOGIC;
  signal axi_rd_avlbl : STD_LOGIC;
  signal axi_rd_avlbl_i_2_n_0 : STD_LOGIC;
  signal axi_rresp_avlbl : STD_LOGIC_VECTOR ( 1 to 1 );
  signal bridge_rd_in_progress : STD_LOGIC;
  signal bridge_rd_in_progress_i_1_n_0 : STD_LOGIC;
  signal \^last_axi_rd_sample\ : STD_LOGIC;
  signal \^m_axi_rresp[1]\ : STD_LOGIC;
  signal s_ahb_htrans_1_sn_1 : STD_LOGIC;
  signal seq_detected : STD_LOGIC;
  signal seq_detected_d1 : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_onehot_ctl_sm_cs[6]_i_7\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \FSM_onehot_ctl_sm_cs[6]_i_8\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of M_AXI_RREADY_i_i_4 : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \S_AHB_HRDATA_i[63]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of bridge_rd_in_progress_i_1 : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of seq_detected_d1_i_1 : label is "soft_lutpair13";
begin
  M_AXI_ARVALID_i_reg_0 <= \^m_axi_arvalid_i_reg_0\;
  M_AXI_RREADY_i_reg_0 <= \^m_axi_rready_i_reg_0\;
  ahb_rd_req_reg_0 <= \^ahb_rd_req_reg_0\;
  ahb_rd_txer_pending_reg_0 <= \^ahb_rd_txer_pending_reg_0\;
  last_axi_rd_sample <= \^last_axi_rd_sample\;
  \m_axi_rresp[1]\ <= \^m_axi_rresp[1]\;
  s_ahb_htrans_1_sp_1 <= s_ahb_htrans_1_sn_1;
\FSM_onehot_ctl_sm_cs[6]_i_6\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FB08080808080808"
    )
        port map (
      I0 => m_axi_rresp(0),
      I1 => \FSM_onehot_ctl_sm_cs[6]_i_7_n_0\,
      I2 => \FSM_onehot_ctl_sm_cs[6]_i_8_n_0\,
      I3 => axi_rresp_avlbl(1),
      I4 => ahb_rd_req,
      I5 => axi_rd_avlbl,
      O => \^m_axi_rresp[1]\
    );
\FSM_onehot_ctl_sm_cs[6]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"45555555"
    )
        port map (
      I0 => ahb_rd_txer_pending,
      I1 => s_ahb_htrans(1),
      I2 => s_ahb_htrans(0),
      I3 => s_ahb_hsel,
      I4 => s_ahb_hready_in,
      O => \FSM_onehot_ctl_sm_cs[6]_i_7_n_0\
    );
\FSM_onehot_ctl_sm_cs[6]_i_8\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => m_axi_rvalid,
      I1 => \^m_axi_rready_i_reg_0\,
      O => \FSM_onehot_ctl_sm_cs[6]_i_8_n_0\
    );
M_AXI_ARVALID_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => M_AXI_ARVALID_i_reg_1,
      Q => \^m_axi_arvalid_i_reg_0\,
      R => SS(0)
    );
M_AXI_RLAST_reg_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"AAEA"
    )
        port map (
      I0 => axi_last_avlbl_reg_n_0,
      I1 => m_axi_rvalid,
      I2 => m_axi_rlast,
      I3 => ahb_rd_txer_pending,
      O => \^last_axi_rd_sample\
    );
M_AXI_RREADY_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF555555FF454545"
    )
        port map (
      I0 => M_AXI_RREADY_i_reg_2,
      I1 => ahb_rd_txer_pending,
      I2 => s_ahb_htrans_1_sn_1,
      I3 => m_axi_arready,
      I4 => \^m_axi_arvalid_i_reg_0\,
      I5 => \^m_axi_rready_i_reg_0\,
      O => M_AXI_RREADY_i_i_1_n_0
    );
M_AXI_RREADY_i_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7FFF"
    )
        port map (
      I0 => s_ahb_htrans(1),
      I1 => s_ahb_hsel,
      I2 => s_ahb_hready_in,
      I3 => s_ahb_htrans(0),
      O => s_ahb_htrans_1_sn_1
    );
M_AXI_RREADY_i_i_4: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FAAAEAAA"
    )
        port map (
      I0 => axi_rd_avlbl,
      I1 => ahb_rd_txer_pending,
      I2 => \^m_axi_rready_i_reg_0\,
      I3 => m_axi_rvalid,
      I4 => m_axi_rlast,
      O => axi_rd_avlbl_reg_0
    );
M_AXI_RREADY_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => M_AXI_RREADY_i_i_1_n_0,
      Q => \^m_axi_rready_i_reg_0\,
      R => SS(0)
    );
\S_AHB_HRDATA_i[63]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^m_axi_rready_i_reg_0\,
      I1 => m_axi_rvalid,
      O => M_AXI_RREADY_i_reg_1(0)
    );
S_AHB_HREADY_OUT_i_i_13: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000000000E0"
    )
        port map (
      I0 => \^m_axi_rresp[1]\,
      I1 => \^ahb_rd_req_reg_0\,
      I2 => Q(0),
      I3 => idle_txfer_pending,
      I4 => nonseq_detected,
      I5 => nonseq_txfer_pending,
      O => \FSM_onehot_ctl_sm_cs_reg[5]_0\
    );
S_AHB_HREADY_OUT_i_i_9: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7777777777770777"
    )
        port map (
      I0 => ahb_rd_req,
      I1 => axi_rd_avlbl,
      I2 => m_axi_rvalid,
      I3 => \^m_axi_rready_i_reg_0\,
      I4 => ahb_rd_txer_pending,
      I5 => ahb_rd_txer_pending_reg_1,
      O => \^ahb_rd_req_reg_0\
    );
S_AHB_HRESP_i_i_5: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAA000200020002"
    )
        port map (
      I0 => \^last_axi_rd_sample\,
      I1 => ahb_rd_txer_pending_reg_1,
      I2 => ahb_rd_txer_pending,
      I3 => \FSM_onehot_ctl_sm_cs[6]_i_8_n_0\,
      I4 => axi_rd_avlbl,
      I5 => ahb_rd_req,
      O => \^ahb_rd_txer_pending_reg_0\
    );
ahb_rd_req_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7774000C00000000"
    )
        port map (
      I0 => axi_rd_avlbl,
      I1 => ahb_rd_txer_pending,
      I2 => seq_detected_d1,
      I3 => s_ahb_htrans_1_sn_1,
      I4 => ahb_rd_req,
      I5 => s_ahb_hresetn,
      O => ahb_rd_req_i_1_n_0
    );
ahb_rd_req_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => ahb_rd_req_i_1_n_0,
      Q => ahb_rd_req,
      R => '0'
    );
ahb_rd_txer_pending_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00EAEAEA00000000"
    )
        port map (
      I0 => ahb_rd_txer_pending,
      I1 => bridge_rd_in_progress,
      I2 => ahb_rd_txer_pending_reg_1,
      I3 => axi_rd_avlbl,
      I4 => ahb_rd_req,
      I5 => s_ahb_hresetn,
      O => ahb_rd_txer_pending_i_1_n_0
    );
ahb_rd_txer_pending_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => ahb_rd_txer_pending_i_1_n_0,
      Q => ahb_rd_txer_pending,
      R => '0'
    );
ahb_wnr_i_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"777F"
    )
        port map (
      I0 => \^ahb_rd_txer_pending_reg_0\,
      I1 => Q(0),
      I2 => nonseq_txfer_pending,
      I3 => nonseq_detected,
      O => \FSM_onehot_ctl_sm_cs_reg[5]\
    );
axi_last_avlbl_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => axi_rd_avlbl_i_2_n_0,
      D => m_axi_rlast,
      Q => axi_last_avlbl_reg_n_0,
      R => axi_last_avlbl
    );
axi_rd_avlbl_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D5"
    )
        port map (
      I0 => s_ahb_hresetn,
      I1 => ahb_rd_req,
      I2 => axi_rd_avlbl,
      O => axi_last_avlbl
    );
axi_rd_avlbl_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8888888800000800"
    )
        port map (
      I0 => \^m_axi_rready_i_reg_0\,
      I1 => m_axi_rvalid,
      I2 => \axi_rresp_avlbl_reg[1]_0\,
      I3 => s_ahb_htrans(0),
      I4 => s_ahb_htrans(1),
      I5 => ahb_rd_txer_pending,
      O => axi_rd_avlbl_i_2_n_0
    );
axi_rd_avlbl_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => axi_rd_avlbl_i_2_n_0,
      D => axi_rd_avlbl_i_2_n_0,
      Q => axi_rd_avlbl,
      R => axi_last_avlbl
    );
\axi_rresp_avlbl_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => axi_rd_avlbl_i_2_n_0,
      D => m_axi_rresp(0),
      Q => axi_rresp_avlbl(1),
      R => axi_last_avlbl
    );
bridge_rd_in_progress_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BFFFAAAA"
    )
        port map (
      I0 => \^m_axi_arvalid_i_reg_0\,
      I1 => m_axi_rvalid,
      I2 => \^m_axi_rready_i_reg_0\,
      I3 => m_axi_rlast,
      I4 => bridge_rd_in_progress,
      O => bridge_rd_in_progress_i_1_n_0
    );
bridge_rd_in_progress_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => bridge_rd_in_progress_i_1_n_0,
      Q => bridge_rd_in_progress,
      R => SS(0)
    );
seq_detected_d1_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => s_ahb_hready_in,
      I2 => s_ahb_hsel,
      I3 => s_ahb_htrans(1),
      O => seq_detected
    );
seq_detected_d1_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => seq_detected,
      Q => seq_detected_d1,
      R => SS(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f is
  port (
    m_axi_wready_0 : out STD_LOGIC;
    m_axi_wready_1 : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 4 downto 0 );
    dummy_on_axi_progress_reg : out STD_LOGIC;
    M_AXI_WSTRB_i : out STD_LOGIC_VECTOR ( 0 to 0 );
    SR : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_wready_2 : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    \INFERRED_GEN.icount_out_reg[0]_0\ : in STD_LOGIC;
    axi_penult_beat_reg : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    axi_last_beat_reg : in STD_LOGIC;
    set_axi_waddr : in STD_LOGIC;
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    dummy_on_axi_progress : in STD_LOGIC;
    M_AXI_WVALID_i_reg : in STD_LOGIC;
    axi_wdata_done_i0 : in STD_LOGIC;
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]\ : in STD_LOGIC;
    burst_term : in STD_LOGIC;
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\ : in STD_LOGIC_VECTOR ( 4 downto 0 );
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1\ : in STD_LOGIC;
    wr_load_timeout_cntr : in STD_LOGIC;
    axi_penult_beat_i_2_0 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    axi_penult_beat_reg_0 : in STD_LOGIC;
    axi_penult_beat_reg_1 : in STD_LOGIC;
    axi_last_beat_reg_0 : in STD_LOGIC;
    dummy_on_axi_progress_reg_0 : in STD_LOGIC;
    s_ahb_hclk : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f is
  signal \INFERRED_GEN.icount_out[0]_i_1_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[1]_i_1_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[2]_i_1_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[3]_i_1_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[4]_i_1_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[4]_i_2_n_0\ : STD_LOGIC;
  signal \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3_n_0\ : STD_LOGIC;
  signal \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5_n_0\ : STD_LOGIC;
  signal \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8_n_0\ : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal \^sr\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_last_beat_i_2_n_0 : STD_LOGIC;
  signal axi_penult_beat_i_2_n_0 : STD_LOGIC;
  signal axi_penult_beat_i_3_n_0 : STD_LOGIC;
  signal dummy_on_axi_init : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[0]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[1]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[2]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[3]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of dummy_on_axi_progress_i_1 : label is "soft_lutpair17";
begin
  Q(4 downto 0) <= \^q\(4 downto 0);
  SR(0) <= \^sr\(0);
\INFERRED_GEN.icount_out[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^q\(0),
      I1 => set_axi_waddr,
      O => \INFERRED_GEN.icount_out[0]_i_1_n_0\
    );
\INFERRED_GEN.icount_out[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"06"
    )
        port map (
      I0 => \^q\(0),
      I1 => \^q\(1),
      I2 => set_axi_waddr,
      O => \INFERRED_GEN.icount_out[1]_i_1_n_0\
    );
\INFERRED_GEN.icount_out[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0078"
    )
        port map (
      I0 => \^q\(1),
      I1 => \^q\(0),
      I2 => \^q\(2),
      I3 => set_axi_waddr,
      O => \INFERRED_GEN.icount_out[2]_i_1_n_0\
    );
\INFERRED_GEN.icount_out[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00007F80"
    )
        port map (
      I0 => \^q\(0),
      I1 => \^q\(1),
      I2 => \^q\(2),
      I3 => \^q\(3),
      I4 => set_axi_waddr,
      O => \INFERRED_GEN.icount_out[3]_i_1_n_0\
    );
\INFERRED_GEN.icount_out[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"F8"
    )
        port map (
      I0 => \INFERRED_GEN.icount_out_reg[0]_0\,
      I1 => m_axi_wready,
      I2 => set_axi_waddr,
      O => \INFERRED_GEN.icount_out[4]_i_1_n_0\
    );
\INFERRED_GEN.icount_out[4]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000007FFF8000"
    )
        port map (
      I0 => \^q\(2),
      I1 => \^q\(1),
      I2 => \^q\(0),
      I3 => \^q\(3),
      I4 => \^q\(4),
      I5 => set_axi_waddr,
      O => \INFERRED_GEN.icount_out[4]_i_2_n_0\
    );
\INFERRED_GEN.icount_out_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \INFERRED_GEN.icount_out[4]_i_1_n_0\,
      D => \INFERRED_GEN.icount_out[0]_i_1_n_0\,
      Q => \^q\(0),
      R => \^sr\(0)
    );
\INFERRED_GEN.icount_out_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \INFERRED_GEN.icount_out[4]_i_1_n_0\,
      D => \INFERRED_GEN.icount_out[1]_i_1_n_0\,
      Q => \^q\(1),
      R => \^sr\(0)
    );
\INFERRED_GEN.icount_out_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \INFERRED_GEN.icount_out[4]_i_1_n_0\,
      D => \INFERRED_GEN.icount_out[2]_i_1_n_0\,
      Q => \^q\(2),
      R => \^sr\(0)
    );
\INFERRED_GEN.icount_out_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \INFERRED_GEN.icount_out[4]_i_1_n_0\,
      D => \INFERRED_GEN.icount_out[3]_i_1_n_0\,
      Q => \^q\(3),
      R => \^sr\(0)
    );
\INFERRED_GEN.icount_out_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \INFERRED_GEN.icount_out[4]_i_1_n_0\,
      D => \INFERRED_GEN.icount_out[4]_i_2_n_0\,
      Q => \^q\(4),
      R => \^sr\(0)
    );
M_AXI_WVALID_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000FFFD0000"
    )
        port map (
      I0 => E(0),
      I1 => dummy_on_axi_init,
      I2 => dummy_on_axi_progress,
      I3 => M_AXI_WVALID_i_reg,
      I4 => s_ahb_hresetn,
      I5 => axi_wdata_done_i0,
      O => dummy_on_axi_progress_reg
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => dummy_on_axi_init,
      I1 => dummy_on_axi_progress,
      O => M_AXI_WSTRB_i(0)
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00D0"
    )
        port map (
      I0 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3_n_0\,
      I1 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]\,
      I2 => burst_term,
      I3 => dummy_on_axi_progress,
      O => dummy_on_axi_init
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFF6F6FFF9FFFFF6"
    )
        port map (
      I0 => \^q\(4),
      I1 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\(4),
      I2 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5_n_0\,
      I3 => \^q\(3),
      I4 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1\,
      I5 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\(3),
      O => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_3_n_0\
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFBFF7FFFBFFFFBF"
    )
        port map (
      I0 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8_n_0\,
      I1 => wr_load_timeout_cntr,
      I2 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\(0),
      I3 => \^q\(0),
      I4 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\(1),
      I5 => \^q\(1),
      O => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_5_n_0\
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \^q\(2),
      I1 => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\(2),
      O => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_8_n_0\
    );
S_AHB_HREADY_OUT_i_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => s_ahb_hresetn,
      O => \^sr\(0)
    );
axi_last_beat_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"87800000"
    )
        port map (
      I0 => m_axi_wready,
      I1 => \INFERRED_GEN.icount_out_reg[0]_0\,
      I2 => axi_last_beat_i_2_n_0,
      I3 => axi_last_beat_reg,
      I4 => s_ahb_hresetn,
      O => m_axi_wready_1
    );
axi_last_beat_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"8AA88888"
    )
        port map (
      I0 => \^q\(1),
      I1 => axi_last_beat_reg_0,
      I2 => \^q\(0),
      I3 => axi_penult_beat_i_2_0(0),
      I4 => axi_penult_beat_i_3_n_0,
      O => axi_last_beat_i_2_n_0
    );
axi_penult_beat_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"87800000"
    )
        port map (
      I0 => m_axi_wready,
      I1 => \INFERRED_GEN.icount_out_reg[0]_0\,
      I2 => axi_penult_beat_i_2_n_0,
      I3 => axi_penult_beat_reg,
      I4 => s_ahb_hresetn,
      O => m_axi_wready_0
    );
axi_penult_beat_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"2400FFFF24002400"
    )
        port map (
      I0 => \^q\(0),
      I1 => \^q\(1),
      I2 => axi_penult_beat_i_2_0(0),
      I3 => axi_penult_beat_i_3_n_0,
      I4 => axi_penult_beat_reg_0,
      I5 => axi_penult_beat_reg_1,
      O => axi_penult_beat_i_2_n_0
    );
axi_penult_beat_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"2010100802010120"
    )
        port map (
      I0 => \^q\(2),
      I1 => \^q\(4),
      I2 => axi_penult_beat_i_2_0(2),
      I3 => axi_penult_beat_i_2_0(0),
      I4 => axi_penult_beat_i_2_0(1),
      I5 => \^q\(3),
      O => axi_penult_beat_i_3_n_0
    );
dummy_on_axi_progress_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"F7F0"
    )
        port map (
      I0 => m_axi_wready,
      I1 => dummy_on_axi_progress_reg_0,
      I2 => dummy_on_axi_init,
      I3 => dummy_on_axi_progress,
      O => m_axi_wready_2
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f_0 is
  port (
    s_ahb_htrans_0_sp_1 : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 4 downto 0 );
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ahb_penult_beat_reg : in STD_LOGIC;
    ahb_penult_beat_reg_0 : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    nonseq_detected : in STD_LOGIC;
    ahb_penult_beat_reg_1 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    SS : in STD_LOGIC_VECTOR ( 0 to 0 );
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_ahb_hclk : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f_0 : entity is "counter_f";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f_0;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f_0 is
  signal \INFERRED_GEN.icount_out[0]_i_1__0_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[1]_i_1__0_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[2]_i_1__0_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[3]_i_1__0_n_0\ : STD_LOGIC;
  signal \INFERRED_GEN.icount_out[4]_i_2__0_n_0\ : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal ahb_penult_beat_i_2_n_0 : STD_LOGIC;
  signal ahb_penult_beat_i_3_n_0 : STD_LOGIC;
  signal s_ahb_htrans_0_sn_1 : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[0]_i_1__0\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[1]_i_1__0\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[2]_i_1__0\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \INFERRED_GEN.icount_out[3]_i_1__0\ : label is "soft_lutpair3";
begin
  Q(4 downto 0) <= \^q\(4 downto 0);
  s_ahb_htrans_0_sp_1 <= s_ahb_htrans_0_sn_1;
\INFERRED_GEN.icount_out[0]_i_1__0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => \^q\(0),
      O => \INFERRED_GEN.icount_out[0]_i_1__0_n_0\
    );
\INFERRED_GEN.icount_out[1]_i_1__0\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"28"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => \^q\(1),
      I2 => \^q\(0),
      O => \INFERRED_GEN.icount_out[1]_i_1__0_n_0\
    );
\INFERRED_GEN.icount_out[2]_i_1__0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1444"
    )
        port map (
      I0 => nonseq_detected,
      I1 => \^q\(2),
      I2 => \^q\(0),
      I3 => \^q\(1),
      O => \INFERRED_GEN.icount_out[2]_i_1__0_n_0\
    );
\INFERRED_GEN.icount_out[3]_i_1__0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00006AAA"
    )
        port map (
      I0 => \^q\(3),
      I1 => \^q\(2),
      I2 => \^q\(0),
      I3 => \^q\(1),
      I4 => nonseq_detected,
      O => \INFERRED_GEN.icount_out[3]_i_1__0_n_0\
    );
\INFERRED_GEN.icount_out[4]_i_2__0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000007FFF8000"
    )
        port map (
      I0 => \^q\(1),
      I1 => \^q\(0),
      I2 => \^q\(2),
      I3 => \^q\(3),
      I4 => \^q\(4),
      I5 => nonseq_detected,
      O => \INFERRED_GEN.icount_out[4]_i_2__0_n_0\
    );
\INFERRED_GEN.icount_out_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => \INFERRED_GEN.icount_out[0]_i_1__0_n_0\,
      Q => \^q\(0),
      R => SS(0)
    );
\INFERRED_GEN.icount_out_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => \INFERRED_GEN.icount_out[1]_i_1__0_n_0\,
      Q => \^q\(1),
      R => SS(0)
    );
\INFERRED_GEN.icount_out_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => \INFERRED_GEN.icount_out[2]_i_1__0_n_0\,
      Q => \^q\(2),
      R => SS(0)
    );
\INFERRED_GEN.icount_out_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => \INFERRED_GEN.icount_out[3]_i_1__0_n_0\,
      Q => \^q\(3),
      R => SS(0)
    );
\INFERRED_GEN.icount_out_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => \INFERRED_GEN.icount_out[4]_i_2__0_n_0\,
      Q => \^q\(4),
      R => SS(0)
    );
ahb_penult_beat_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"20CE200000000000"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => ahb_penult_beat_reg,
      I2 => s_ahb_htrans(1),
      I3 => ahb_penult_beat_i_2_n_0,
      I4 => ahb_penult_beat_reg_0,
      I5 => s_ahb_hresetn,
      O => s_ahb_htrans_0_sn_1
    );
ahb_penult_beat_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000021212118"
    )
        port map (
      I0 => \^q\(3),
      I1 => \^q\(4),
      I2 => ahb_penult_beat_reg_1(2),
      I3 => ahb_penult_beat_reg_1(1),
      I4 => ahb_penult_beat_reg_1(0),
      I5 => ahb_penult_beat_i_3_n_0,
      O => ahb_penult_beat_i_2_n_0
    );
ahb_penult_beat_i_3: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BFF7FB7F"
    )
        port map (
      I0 => \^q\(0),
      I1 => \^q\(1),
      I2 => ahb_penult_beat_reg_1(1),
      I3 => ahb_penult_beat_reg_1(0),
      I4 => \^q\(2),
      O => ahb_penult_beat_i_3_n_0
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_data_counter is
  port (
    s_ahb_htrans_0_sp_1 : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 4 downto 0 );
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ahb_penult_beat_reg : in STD_LOGIC;
    ahb_penult_beat_reg_0 : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    nonseq_detected : in STD_LOGIC;
    ahb_penult_beat_reg_1 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    SS : in STD_LOGIC_VECTOR ( 0 to 0 );
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_ahb_hclk : in STD_LOGIC
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_data_counter;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_data_counter is
  signal s_ahb_htrans_0_sn_1 : STD_LOGIC;
begin
  s_ahb_htrans_0_sp_1 <= s_ahb_htrans_0_sn_1;
AHB_SAMPLE_CNT_MODULE: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f_0
     port map (
      E(0) => E(0),
      Q(4 downto 0) => Q(4 downto 0),
      SS(0) => SS(0),
      ahb_penult_beat_reg => ahb_penult_beat_reg,
      ahb_penult_beat_reg_0 => ahb_penult_beat_reg_0,
      ahb_penult_beat_reg_1(2 downto 0) => ahb_penult_beat_reg_1(2 downto 0),
      nonseq_detected => nonseq_detected,
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_htrans(1 downto 0) => s_ahb_htrans(1 downto 0),
      s_ahb_htrans_0_sp_1 => s_ahb_htrans_0_sn_1
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_wchannel is
  port (
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 0 to 0 );
    SS : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_awvalid : out STD_LOGIC;
    M_AXI_WLAST_i_reg_0 : out STD_LOGIC;
    ahb_data_valid_burst_term : out STD_LOGIC;
    M_AXI_WVALID_i_reg_0 : out STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 4 downto 0 );
    m_axi_wready_0 : out STD_LOGIC;
    local_en_reg_0 : out STD_LOGIC;
    \s_ahb_htrans[1]\ : out STD_LOGIC;
    m_axi_wready_1 : out STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    s_ahb_hclk : in STD_LOGIC;
    M_AXI_AWVALID_i_reg_0 : in STD_LOGIC;
    ahb_data_valid_burst_term_reg_0 : in STD_LOGIC;
    M_AXI_BREADY_i_reg_0 : in STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    set_axi_waddr : in STD_LOGIC;
    M_AXI_WVALID_i_reg_1 : in STD_LOGIC;
    ahb_data_valid : in STD_LOGIC;
    burst_term : in STD_LOGIC;
    s_ahb_hwdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0\ : in STD_LOGIC;
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2\ : in STD_LOGIC_VECTOR ( 4 downto 0 );
    \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\ : in STD_LOGIC;
    axi_penult_beat_reg_0 : in STD_LOGIC;
    axi_penult_beat_reg_1 : in STD_LOGIC;
    axi_last_beat_reg_0 : in STD_LOGIC;
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_ahb_hready_in : in STD_LOGIC;
    s_ahb_hsel : in STD_LOGIC;
    M_AXI_WLAST_i_reg_1 : in STD_LOGIC;
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    D : in STD_LOGIC_VECTOR ( 2 downto 0 )
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_wchannel;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_wchannel is
  signal AXI_WRITE_CNT_MODULE_n_0 : STD_LOGIC;
  signal AXI_WRITE_CNT_MODULE_n_1 : STD_LOGIC;
  signal AXI_WRITE_CNT_MODULE_n_10 : STD_LOGIC;
  signal AXI_WRITE_CNT_MODULE_n_7 : STD_LOGIC;
  signal M_AXI_WLAST_i_i_1_n_0 : STD_LOGIC;
  signal M_AXI_WLAST_i_i_2_n_0 : STD_LOGIC;
  signal \^m_axi_wlast_i_reg_0\ : STD_LOGIC;
  signal M_AXI_WSTRB_i : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^m_axi_wvalid_i_reg_0\ : STD_LOGIC;
  signal \^ss\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_cnt_required : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal axi_last_beat_reg_n_0 : STD_LOGIC;
  signal axi_penult_beat_reg_n_0 : STD_LOGIC;
  signal axi_wdata_done_i0 : STD_LOGIC;
  signal dummy_on_axi_progress : STD_LOGIC;
  signal local_en : STD_LOGIC;
  signal local_en_i_1_n_0 : STD_LOGIC;
  signal local_wdata : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal local_wdata0 : STD_LOGIC;
  signal \^m_axi_wready_0\ : STD_LOGIC;
  signal p_1_in : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal wr_load_timeout_cntr : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \M_AXI_WDATA_i[29]_i_1\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of M_AXI_WLAST_i_i_4 : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of M_AXI_WVALID_i_i_3 : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of M_AXI_WVALID_i_i_4 : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of burst_term_i_i_2 : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of local_en_i_1 : label is "soft_lutpair20";
begin
  M_AXI_WLAST_i_reg_0 <= \^m_axi_wlast_i_reg_0\;
  M_AXI_WVALID_i_reg_0 <= \^m_axi_wvalid_i_reg_0\;
  SS(0) <= \^ss\(0);
  m_axi_wready_0 <= \^m_axi_wready_0\;
AXI_WRITE_CNT_MODULE: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_counter_f
     port map (
      E(0) => \^m_axi_wready_0\,
      \INFERRED_GEN.icount_out_reg[0]_0\ => \^m_axi_wvalid_i_reg_0\,
      M_AXI_WSTRB_i(0) => M_AXI_WSTRB_i(0),
      M_AXI_WVALID_i_reg => M_AXI_WVALID_i_reg_1,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\(4 downto 0) => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2\(4 downto 0),
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_1\ => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]\ => \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0\,
      Q(4 downto 0) => Q(4 downto 0),
      SR(0) => \^ss\(0),
      axi_last_beat_reg => axi_last_beat_reg_n_0,
      axi_last_beat_reg_0 => axi_last_beat_reg_0,
      axi_penult_beat_i_2_0(2 downto 0) => axi_cnt_required(3 downto 1),
      axi_penult_beat_reg => axi_penult_beat_reg_n_0,
      axi_penult_beat_reg_0 => axi_penult_beat_reg_0,
      axi_penult_beat_reg_1 => axi_penult_beat_reg_1,
      axi_wdata_done_i0 => axi_wdata_done_i0,
      burst_term => burst_term,
      dummy_on_axi_progress => dummy_on_axi_progress,
      dummy_on_axi_progress_reg => AXI_WRITE_CNT_MODULE_n_7,
      dummy_on_axi_progress_reg_0 => \^m_axi_wlast_i_reg_0\,
      m_axi_wready => m_axi_wready,
      m_axi_wready_0 => AXI_WRITE_CNT_MODULE_n_0,
      m_axi_wready_1 => AXI_WRITE_CNT_MODULE_n_1,
      m_axi_wready_2 => AXI_WRITE_CNT_MODULE_n_10,
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hresetn => s_ahb_hresetn,
      set_axi_waddr => set_axi_waddr,
      wr_load_timeout_cntr => wr_load_timeout_cntr
    );
M_AXI_AWVALID_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => M_AXI_AWVALID_i_reg_0,
      Q => m_axi_awvalid,
      R => \^ss\(0)
    );
M_AXI_BREADY_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => M_AXI_BREADY_i_reg_0,
      Q => m_axi_bready,
      R => \^ss\(0)
    );
\M_AXI_WDATA_i[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(0),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(0),
      O => p_1_in(0)
    );
\M_AXI_WDATA_i[10]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(10),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(10),
      O => p_1_in(10)
    );
\M_AXI_WDATA_i[11]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(11),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(11),
      O => p_1_in(11)
    );
\M_AXI_WDATA_i[12]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(12),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(12),
      O => p_1_in(12)
    );
\M_AXI_WDATA_i[13]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(13),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(13),
      O => p_1_in(13)
    );
\M_AXI_WDATA_i[14]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(14),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(14),
      O => p_1_in(14)
    );
\M_AXI_WDATA_i[15]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(15),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(15),
      O => p_1_in(15)
    );
\M_AXI_WDATA_i[16]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(16),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(16),
      O => p_1_in(16)
    );
\M_AXI_WDATA_i[17]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(17),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(17),
      O => p_1_in(17)
    );
\M_AXI_WDATA_i[18]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(18),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(18),
      O => p_1_in(18)
    );
\M_AXI_WDATA_i[19]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(19),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(19),
      O => p_1_in(19)
    );
\M_AXI_WDATA_i[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(1),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(1),
      O => p_1_in(1)
    );
\M_AXI_WDATA_i[20]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(20),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(20),
      O => p_1_in(20)
    );
\M_AXI_WDATA_i[21]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(21),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(21),
      O => p_1_in(21)
    );
\M_AXI_WDATA_i[22]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(22),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(22),
      O => p_1_in(22)
    );
\M_AXI_WDATA_i[23]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(23),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(23),
      O => p_1_in(23)
    );
\M_AXI_WDATA_i[24]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(24),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(24),
      O => p_1_in(24)
    );
\M_AXI_WDATA_i[25]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(25),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(25),
      O => p_1_in(25)
    );
\M_AXI_WDATA_i[26]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(26),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(26),
      O => p_1_in(26)
    );
\M_AXI_WDATA_i[27]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(27),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(27),
      O => p_1_in(27)
    );
\M_AXI_WDATA_i[28]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(28),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(28),
      O => p_1_in(28)
    );
\M_AXI_WDATA_i[29]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(29),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(29),
      O => p_1_in(29)
    );
\M_AXI_WDATA_i[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(2),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(2),
      O => p_1_in(2)
    );
\M_AXI_WDATA_i[30]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(30),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(30),
      O => p_1_in(30)
    );
\M_AXI_WDATA_i[31]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(31),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(31),
      O => p_1_in(31)
    );
\M_AXI_WDATA_i[32]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(32),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(32),
      O => p_1_in(32)
    );
\M_AXI_WDATA_i[33]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(33),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(33),
      O => p_1_in(33)
    );
\M_AXI_WDATA_i[34]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(34),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(34),
      O => p_1_in(34)
    );
\M_AXI_WDATA_i[35]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(35),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(35),
      O => p_1_in(35)
    );
\M_AXI_WDATA_i[36]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(36),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(36),
      O => p_1_in(36)
    );
\M_AXI_WDATA_i[37]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(37),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(37),
      O => p_1_in(37)
    );
\M_AXI_WDATA_i[38]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(38),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(38),
      O => p_1_in(38)
    );
\M_AXI_WDATA_i[39]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(39),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(39),
      O => p_1_in(39)
    );
\M_AXI_WDATA_i[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(3),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(3),
      O => p_1_in(3)
    );
\M_AXI_WDATA_i[40]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(40),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(40),
      O => p_1_in(40)
    );
\M_AXI_WDATA_i[41]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(41),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(41),
      O => p_1_in(41)
    );
\M_AXI_WDATA_i[42]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(42),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(42),
      O => p_1_in(42)
    );
\M_AXI_WDATA_i[43]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(43),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(43),
      O => p_1_in(43)
    );
\M_AXI_WDATA_i[44]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(44),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(44),
      O => p_1_in(44)
    );
\M_AXI_WDATA_i[45]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(45),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(45),
      O => p_1_in(45)
    );
\M_AXI_WDATA_i[46]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(46),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(46),
      O => p_1_in(46)
    );
\M_AXI_WDATA_i[47]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(47),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(47),
      O => p_1_in(47)
    );
\M_AXI_WDATA_i[48]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(48),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(48),
      O => p_1_in(48)
    );
\M_AXI_WDATA_i[49]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(49),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(49),
      O => p_1_in(49)
    );
\M_AXI_WDATA_i[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(4),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(4),
      O => p_1_in(4)
    );
\M_AXI_WDATA_i[50]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(50),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(50),
      O => p_1_in(50)
    );
\M_AXI_WDATA_i[51]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(51),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(51),
      O => p_1_in(51)
    );
\M_AXI_WDATA_i[52]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(52),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(52),
      O => p_1_in(52)
    );
\M_AXI_WDATA_i[53]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(53),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(53),
      O => p_1_in(53)
    );
\M_AXI_WDATA_i[54]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(54),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(54),
      O => p_1_in(54)
    );
\M_AXI_WDATA_i[55]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(55),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(55),
      O => p_1_in(55)
    );
\M_AXI_WDATA_i[56]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(56),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(56),
      O => p_1_in(56)
    );
\M_AXI_WDATA_i[57]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(57),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(57),
      O => p_1_in(57)
    );
\M_AXI_WDATA_i[58]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(58),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(58),
      O => p_1_in(58)
    );
\M_AXI_WDATA_i[59]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(59),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(59),
      O => p_1_in(59)
    );
\M_AXI_WDATA_i[5]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(5),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(5),
      O => p_1_in(5)
    );
\M_AXI_WDATA_i[60]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(60),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(60),
      O => p_1_in(60)
    );
\M_AXI_WDATA_i[61]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(61),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(61),
      O => p_1_in(61)
    );
\M_AXI_WDATA_i[62]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(62),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(62),
      O => p_1_in(62)
    );
\M_AXI_WDATA_i[63]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => m_axi_wready,
      I1 => \^m_axi_wvalid_i_reg_0\,
      O => \^m_axi_wready_0\
    );
\M_AXI_WDATA_i[63]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(63),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(63),
      O => p_1_in(63)
    );
\M_AXI_WDATA_i[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(6),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(6),
      O => p_1_in(6)
    );
\M_AXI_WDATA_i[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(7),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(7),
      O => p_1_in(7)
    );
\M_AXI_WDATA_i[8]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(8),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(8),
      O => p_1_in(8)
    );
\M_AXI_WDATA_i[9]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EEAE22A2"
    )
        port map (
      I0 => s_ahb_hwdata(9),
      I1 => local_en,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => m_axi_wready,
      I4 => local_wdata(9),
      O => p_1_in(9)
    );
\M_AXI_WDATA_i_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(0),
      Q => m_axi_wdata(0),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(10),
      Q => m_axi_wdata(10),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(11),
      Q => m_axi_wdata(11),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(12),
      Q => m_axi_wdata(12),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(13),
      Q => m_axi_wdata(13),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(14),
      Q => m_axi_wdata(14),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(15),
      Q => m_axi_wdata(15),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(16),
      Q => m_axi_wdata(16),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(17),
      Q => m_axi_wdata(17),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(18),
      Q => m_axi_wdata(18),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(19),
      Q => m_axi_wdata(19),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(1),
      Q => m_axi_wdata(1),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(20),
      Q => m_axi_wdata(20),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(21),
      Q => m_axi_wdata(21),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(22),
      Q => m_axi_wdata(22),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(23),
      Q => m_axi_wdata(23),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(24),
      Q => m_axi_wdata(24),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(25),
      Q => m_axi_wdata(25),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(26),
      Q => m_axi_wdata(26),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(27),
      Q => m_axi_wdata(27),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(28),
      Q => m_axi_wdata(28),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(29),
      Q => m_axi_wdata(29),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(2),
      Q => m_axi_wdata(2),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(30),
      Q => m_axi_wdata(30),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(31),
      Q => m_axi_wdata(31),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[32]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(32),
      Q => m_axi_wdata(32),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[33]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(33),
      Q => m_axi_wdata(33),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[34]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(34),
      Q => m_axi_wdata(34),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[35]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(35),
      Q => m_axi_wdata(35),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[36]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(36),
      Q => m_axi_wdata(36),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[37]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(37),
      Q => m_axi_wdata(37),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[38]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(38),
      Q => m_axi_wdata(38),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[39]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(39),
      Q => m_axi_wdata(39),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(3),
      Q => m_axi_wdata(3),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[40]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(40),
      Q => m_axi_wdata(40),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[41]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(41),
      Q => m_axi_wdata(41),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[42]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(42),
      Q => m_axi_wdata(42),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[43]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(43),
      Q => m_axi_wdata(43),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[44]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(44),
      Q => m_axi_wdata(44),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[45]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(45),
      Q => m_axi_wdata(45),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[46]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(46),
      Q => m_axi_wdata(46),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[47]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(47),
      Q => m_axi_wdata(47),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[48]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(48),
      Q => m_axi_wdata(48),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[49]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(49),
      Q => m_axi_wdata(49),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(4),
      Q => m_axi_wdata(4),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[50]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(50),
      Q => m_axi_wdata(50),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[51]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(51),
      Q => m_axi_wdata(51),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[52]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(52),
      Q => m_axi_wdata(52),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[53]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(53),
      Q => m_axi_wdata(53),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[54]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(54),
      Q => m_axi_wdata(54),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[55]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(55),
      Q => m_axi_wdata(55),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[56]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(56),
      Q => m_axi_wdata(56),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[57]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(57),
      Q => m_axi_wdata(57),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[58]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(58),
      Q => m_axi_wdata(58),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[59]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(59),
      Q => m_axi_wdata(59),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(5),
      Q => m_axi_wdata(5),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[60]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(60),
      Q => m_axi_wdata(60),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[61]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(61),
      Q => m_axi_wdata(61),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[62]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(62),
      Q => m_axi_wdata(62),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[63]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(63),
      Q => m_axi_wdata(63),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(6),
      Q => m_axi_wdata(6),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(7),
      Q => m_axi_wdata(7),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(8),
      Q => m_axi_wdata(8),
      R => \^ss\(0)
    );
\M_AXI_WDATA_i_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => \^m_axi_wready_0\,
      D => p_1_in(9),
      Q => m_axi_wdata(9),
      R => \^ss\(0)
    );
M_AXI_WLAST_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"EEEEEEECEEEFEEEC"
    )
        port map (
      I0 => M_AXI_WLAST_i_i_2_n_0,
      I1 => M_AXI_WLAST_i_reg_1,
      I2 => axi_last_beat_reg_n_0,
      I3 => axi_penult_beat_reg_n_0,
      I4 => \^m_axi_wlast_i_reg_0\,
      I5 => m_axi_wready,
      O => M_AXI_WLAST_i_i_1_n_0
    );
M_AXI_WLAST_i_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00000000FEFE00FE"
    )
        port map (
      I0 => local_en,
      I1 => ahb_data_valid,
      I2 => burst_term,
      I3 => axi_penult_beat_reg_n_0,
      I4 => wr_load_timeout_cntr,
      I5 => axi_wdata_done_i0,
      O => M_AXI_WLAST_i_i_2_n_0
    );
M_AXI_WLAST_i_i_4: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => m_axi_wready,
      I1 => \^m_axi_wvalid_i_reg_0\,
      O => wr_load_timeout_cntr
    );
M_AXI_WLAST_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => M_AXI_WLAST_i_i_1_n_0,
      Q => \^m_axi_wlast_i_reg_0\,
      R => \^ss\(0)
    );
M_AXI_WVALID_i_i_3: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^m_axi_wlast_i_reg_0\,
      I1 => m_axi_wready,
      O => axi_wdata_done_i0
    );
M_AXI_WVALID_i_i_4: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => local_en,
      I1 => ahb_data_valid,
      O => local_en_reg_0
    );
M_AXI_WVALID_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => AXI_WRITE_CNT_MODULE_n_7,
      Q => \^m_axi_wvalid_i_reg_0\,
      R => '0'
    );
\NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]\: unisim.vcomponents.FDSE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => M_AXI_WSTRB_i(0),
      Q => m_axi_wstrb(0),
      S => \^ss\(0)
    );
ahb_data_valid_burst_term_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => ahb_data_valid_burst_term_reg_0,
      Q => ahb_data_valid_burst_term,
      R => \^ss\(0)
    );
ahb_data_valid_i_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAA0C000C000C00"
    )
        port map (
      I0 => s_ahb_htrans(0),
      I1 => local_en,
      I2 => \^m_axi_wready_0\,
      I3 => ahb_data_valid,
      I4 => s_ahb_hready_in,
      I5 => s_ahb_hsel,
      O => \s_ahb_htrans[1]\
    );
\axi_cnt_required_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => D(0),
      Q => axi_cnt_required(1),
      R => \^ss\(0)
    );
\axi_cnt_required_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => D(1),
      Q => axi_cnt_required(2),
      R => \^ss\(0)
    );
\axi_cnt_required_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => E(0),
      D => D(2),
      Q => axi_cnt_required(3),
      R => \^ss\(0)
    );
axi_last_beat_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => AXI_WRITE_CNT_MODULE_n_1,
      Q => axi_last_beat_reg_n_0,
      R => '0'
    );
axi_penult_beat_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => AXI_WRITE_CNT_MODULE_n_0,
      Q => axi_penult_beat_reg_n_0,
      R => '0'
    );
burst_term_i_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"8F"
    )
        port map (
      I0 => m_axi_wready,
      I1 => \^m_axi_wlast_i_reg_0\,
      I2 => s_ahb_hresetn,
      O => m_axi_wready_1
    );
dummy_on_axi_progress_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => AXI_WRITE_CNT_MODULE_n_10,
      Q => dummy_on_axi_progress,
      R => \^ss\(0)
    );
local_en_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"D540"
    )
        port map (
      I0 => m_axi_wready,
      I1 => ahb_data_valid,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => local_en,
      O => local_en_i_1_n_0
    );
local_en_reg: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => '1',
      D => local_en_i_1_n_0,
      Q => local_en,
      R => \^ss\(0)
    );
\local_wdata[63]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"D555"
    )
        port map (
      I0 => local_en,
      I1 => m_axi_wready,
      I2 => \^m_axi_wvalid_i_reg_0\,
      I3 => ahb_data_valid,
      O => local_wdata0
    );
\local_wdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(0),
      Q => local_wdata(0),
      R => \^ss\(0)
    );
\local_wdata_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(10),
      Q => local_wdata(10),
      R => \^ss\(0)
    );
\local_wdata_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(11),
      Q => local_wdata(11),
      R => \^ss\(0)
    );
\local_wdata_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(12),
      Q => local_wdata(12),
      R => \^ss\(0)
    );
\local_wdata_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(13),
      Q => local_wdata(13),
      R => \^ss\(0)
    );
\local_wdata_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(14),
      Q => local_wdata(14),
      R => \^ss\(0)
    );
\local_wdata_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(15),
      Q => local_wdata(15),
      R => \^ss\(0)
    );
\local_wdata_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(16),
      Q => local_wdata(16),
      R => \^ss\(0)
    );
\local_wdata_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(17),
      Q => local_wdata(17),
      R => \^ss\(0)
    );
\local_wdata_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(18),
      Q => local_wdata(18),
      R => \^ss\(0)
    );
\local_wdata_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(19),
      Q => local_wdata(19),
      R => \^ss\(0)
    );
\local_wdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(1),
      Q => local_wdata(1),
      R => \^ss\(0)
    );
\local_wdata_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(20),
      Q => local_wdata(20),
      R => \^ss\(0)
    );
\local_wdata_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(21),
      Q => local_wdata(21),
      R => \^ss\(0)
    );
\local_wdata_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(22),
      Q => local_wdata(22),
      R => \^ss\(0)
    );
\local_wdata_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(23),
      Q => local_wdata(23),
      R => \^ss\(0)
    );
\local_wdata_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(24),
      Q => local_wdata(24),
      R => \^ss\(0)
    );
\local_wdata_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(25),
      Q => local_wdata(25),
      R => \^ss\(0)
    );
\local_wdata_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(26),
      Q => local_wdata(26),
      R => \^ss\(0)
    );
\local_wdata_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(27),
      Q => local_wdata(27),
      R => \^ss\(0)
    );
\local_wdata_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(28),
      Q => local_wdata(28),
      R => \^ss\(0)
    );
\local_wdata_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(29),
      Q => local_wdata(29),
      R => \^ss\(0)
    );
\local_wdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(2),
      Q => local_wdata(2),
      R => \^ss\(0)
    );
\local_wdata_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(30),
      Q => local_wdata(30),
      R => \^ss\(0)
    );
\local_wdata_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(31),
      Q => local_wdata(31),
      R => \^ss\(0)
    );
\local_wdata_reg[32]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(32),
      Q => local_wdata(32),
      R => \^ss\(0)
    );
\local_wdata_reg[33]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(33),
      Q => local_wdata(33),
      R => \^ss\(0)
    );
\local_wdata_reg[34]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(34),
      Q => local_wdata(34),
      R => \^ss\(0)
    );
\local_wdata_reg[35]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(35),
      Q => local_wdata(35),
      R => \^ss\(0)
    );
\local_wdata_reg[36]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(36),
      Q => local_wdata(36),
      R => \^ss\(0)
    );
\local_wdata_reg[37]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(37),
      Q => local_wdata(37),
      R => \^ss\(0)
    );
\local_wdata_reg[38]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(38),
      Q => local_wdata(38),
      R => \^ss\(0)
    );
\local_wdata_reg[39]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(39),
      Q => local_wdata(39),
      R => \^ss\(0)
    );
\local_wdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(3),
      Q => local_wdata(3),
      R => \^ss\(0)
    );
\local_wdata_reg[40]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(40),
      Q => local_wdata(40),
      R => \^ss\(0)
    );
\local_wdata_reg[41]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(41),
      Q => local_wdata(41),
      R => \^ss\(0)
    );
\local_wdata_reg[42]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(42),
      Q => local_wdata(42),
      R => \^ss\(0)
    );
\local_wdata_reg[43]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(43),
      Q => local_wdata(43),
      R => \^ss\(0)
    );
\local_wdata_reg[44]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(44),
      Q => local_wdata(44),
      R => \^ss\(0)
    );
\local_wdata_reg[45]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(45),
      Q => local_wdata(45),
      R => \^ss\(0)
    );
\local_wdata_reg[46]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(46),
      Q => local_wdata(46),
      R => \^ss\(0)
    );
\local_wdata_reg[47]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(47),
      Q => local_wdata(47),
      R => \^ss\(0)
    );
\local_wdata_reg[48]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(48),
      Q => local_wdata(48),
      R => \^ss\(0)
    );
\local_wdata_reg[49]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(49),
      Q => local_wdata(49),
      R => \^ss\(0)
    );
\local_wdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(4),
      Q => local_wdata(4),
      R => \^ss\(0)
    );
\local_wdata_reg[50]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(50),
      Q => local_wdata(50),
      R => \^ss\(0)
    );
\local_wdata_reg[51]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(51),
      Q => local_wdata(51),
      R => \^ss\(0)
    );
\local_wdata_reg[52]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(52),
      Q => local_wdata(52),
      R => \^ss\(0)
    );
\local_wdata_reg[53]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(53),
      Q => local_wdata(53),
      R => \^ss\(0)
    );
\local_wdata_reg[54]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(54),
      Q => local_wdata(54),
      R => \^ss\(0)
    );
\local_wdata_reg[55]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(55),
      Q => local_wdata(55),
      R => \^ss\(0)
    );
\local_wdata_reg[56]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(56),
      Q => local_wdata(56),
      R => \^ss\(0)
    );
\local_wdata_reg[57]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(57),
      Q => local_wdata(57),
      R => \^ss\(0)
    );
\local_wdata_reg[58]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(58),
      Q => local_wdata(58),
      R => \^ss\(0)
    );
\local_wdata_reg[59]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(59),
      Q => local_wdata(59),
      R => \^ss\(0)
    );
\local_wdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(5),
      Q => local_wdata(5),
      R => \^ss\(0)
    );
\local_wdata_reg[60]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(60),
      Q => local_wdata(60),
      R => \^ss\(0)
    );
\local_wdata_reg[61]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(61),
      Q => local_wdata(61),
      R => \^ss\(0)
    );
\local_wdata_reg[62]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(62),
      Q => local_wdata(62),
      R => \^ss\(0)
    );
\local_wdata_reg[63]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(63),
      Q => local_wdata(63),
      R => \^ss\(0)
    );
\local_wdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(6),
      Q => local_wdata(6),
      R => \^ss\(0)
    );
\local_wdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(7),
      Q => local_wdata(7),
      R => \^ss\(0)
    );
\local_wdata_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(8),
      Q => local_wdata(8),
      R => \^ss\(0)
    );
\local_wdata_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s_ahb_hclk,
      CE => local_wdata0,
      D => s_ahb_hwdata(9),
      Q => local_wdata(9),
      R => \^ss\(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge is
  port (
    s_ahb_hclk : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    s_ahb_hsel : in STD_LOGIC;
    s_ahb_haddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_ahb_hprot : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_ahb_hsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ahb_hwrite : in STD_LOGIC;
    s_ahb_hburst : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ahb_hwdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_ahb_hready_out : out STD_LOGIC;
    s_ahb_hready_in : in STD_LOGIC;
    s_ahb_hrdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    s_ahb_hresp : out STD_LOGIC;
    m_axi_awid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_awlock : out STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_wlast : out STD_LOGIC;
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_arid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_arlock : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rlast : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC
  );
  attribute C_AHB_AXI_TIMEOUT : integer;
  attribute C_AHB_AXI_TIMEOUT of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 0;
  attribute C_FAMILY : string;
  attribute C_FAMILY of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is "zynquplus";
  attribute C_INSTANCE : string;
  attribute C_INSTANCE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is "zynqmpsoc_ahblite_axi_bridge_0_0";
  attribute C_M_AXI_ADDR_WIDTH : integer;
  attribute C_M_AXI_ADDR_WIDTH of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 32;
  attribute C_M_AXI_DATA_WIDTH : integer;
  attribute C_M_AXI_DATA_WIDTH of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 64;
  attribute C_M_AXI_NON_SECURE : integer;
  attribute C_M_AXI_NON_SECURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 1;
  attribute C_M_AXI_PROTOCOL : string;
  attribute C_M_AXI_PROTOCOL of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is "AXI4";
  attribute C_M_AXI_SUPPORTS_NARROW_BURST : integer;
  attribute C_M_AXI_SUPPORTS_NARROW_BURST of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 0;
  attribute C_M_AXI_THREAD_ID_WIDTH : integer;
  attribute C_M_AXI_THREAD_ID_WIDTH of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 4;
  attribute C_S_AHB_ADDR_WIDTH : integer;
  attribute C_S_AHB_ADDR_WIDTH of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 32;
  attribute C_S_AHB_DATA_WIDTH : integer;
  attribute C_S_AHB_DATA_WIDTH of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is 64;
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge : entity is "yes";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge is
  signal \<const0>\ : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_1 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_13 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_14 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_15 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_16 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_17 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_18 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_19 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_2 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_20 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_3 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_5 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_6 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_7 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_8 : STD_LOGIC;
  signal AHBLITE_AXI_CONTROL_n_9 : STD_LOGIC;
  signal AHB_DATA_COUNTER_n_0 : STD_LOGIC;
  signal AHB_DATA_COUNTER_n_1 : STD_LOGIC;
  signal AHB_DATA_COUNTER_n_2 : STD_LOGIC;
  signal AHB_DATA_COUNTER_n_3 : STD_LOGIC;
  signal AHB_DATA_COUNTER_n_4 : STD_LOGIC;
  signal AHB_DATA_COUNTER_n_5 : STD_LOGIC;
  signal AHB_IF_n_12 : STD_LOGIC;
  signal AHB_IF_n_14 : STD_LOGIC;
  signal AHB_IF_n_15 : STD_LOGIC;
  signal AHB_IF_n_16 : STD_LOGIC;
  signal AHB_IF_n_17 : STD_LOGIC;
  signal AHB_IF_n_18 : STD_LOGIC;
  signal AHB_IF_n_20 : STD_LOGIC;
  signal AHB_IF_n_22 : STD_LOGIC;
  signal AHB_IF_n_23 : STD_LOGIC;
  signal AHB_IF_n_24 : STD_LOGIC;
  signal AHB_IF_n_25 : STD_LOGIC;
  signal AHB_IF_n_26 : STD_LOGIC;
  signal AHB_IF_n_27 : STD_LOGIC;
  signal AHB_IF_n_28 : STD_LOGIC;
  signal AHB_IF_n_29 : STD_LOGIC;
  signal AHB_IF_n_35 : STD_LOGIC;
  signal AHB_IF_n_36 : STD_LOGIC;
  signal AHB_IF_n_37 : STD_LOGIC;
  signal AHB_IF_n_38 : STD_LOGIC;
  signal AHB_IF_n_39 : STD_LOGIC;
  signal AHB_IF_n_5 : STD_LOGIC;
  signal AXI_RCHANNEL_n_10 : STD_LOGIC;
  signal AXI_RCHANNEL_n_2 : STD_LOGIC;
  signal AXI_RCHANNEL_n_3 : STD_LOGIC;
  signal AXI_RCHANNEL_n_4 : STD_LOGIC;
  signal AXI_RCHANNEL_n_6 : STD_LOGIC;
  signal AXI_RCHANNEL_n_7 : STD_LOGIC;
  signal AXI_RCHANNEL_n_8 : STD_LOGIC;
  signal AXI_WCHANNEL_n_10 : STD_LOGIC;
  signal AXI_WCHANNEL_n_11 : STD_LOGIC;
  signal AXI_WCHANNEL_n_12 : STD_LOGIC;
  signal AXI_WCHANNEL_n_13 : STD_LOGIC;
  signal AXI_WCHANNEL_n_14 : STD_LOGIC;
  signal AXI_WCHANNEL_n_15 : STD_LOGIC;
  signal AXI_WCHANNEL_n_7 : STD_LOGIC;
  signal AXI_WCHANNEL_n_8 : STD_LOGIC;
  signal AXI_WCHANNEL_n_9 : STD_LOGIC;
  signal ahb_data_valid : STD_LOGIC;
  signal ahb_data_valid_burst_term : STD_LOGIC;
  signal ahb_hburst_single : STD_LOGIC;
  signal axi_waddr_done_i : STD_LOGIC;
  signal burst_term : STD_LOGIC;
  signal burst_term_cur_cnt : STD_LOGIC_VECTOR ( 4 downto 0 );
  signal burst_term_hwrite : STD_LOGIC;
  signal burst_term_single_incr : STD_LOGIC;
  signal burst_term_txer_cnt_i0 : STD_LOGIC;
  signal cntr_rst : STD_LOGIC;
  signal core_is_idle : STD_LOGIC;
  signal idle_txfer_pending : STD_LOGIC;
  signal last_axi_rd_sample : STD_LOGIC;
  signal \^m_axi_araddr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^m_axi_arburst\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal \^m_axi_arcache\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal \^m_axi_arlen\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \^m_axi_arprot\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \^m_axi_arsize\ : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \^m_axi_arvalid\ : STD_LOGIC;
  signal \^m_axi_awlen\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^m_axi_awvalid\ : STD_LOGIC;
  signal \^m_axi_bready\ : STD_LOGIC;
  signal \^m_axi_wlast\ : STD_LOGIC;
  signal \^m_axi_wstrb\ : STD_LOGIC_VECTOR ( 6 to 6 );
  signal nonseq_detected : STD_LOGIC;
  signal nonseq_txfer_pending : STD_LOGIC;
  signal p_10_in : STD_LOGIC;
  signal rd_load_timeout_cntr : STD_LOGIC;
  signal set_axi_waddr : STD_LOGIC;
  signal set_hresp_err : STD_LOGIC;
  signal valid_cnt_required : STD_LOGIC_VECTOR ( 3 downto 1 );
begin
  m_axi_araddr(31 downto 0) <= \^m_axi_araddr\(31 downto 0);
  m_axi_arburst(1 downto 0) <= \^m_axi_arburst\(1 downto 0);
  m_axi_arcache(3) <= \<const0>\;
  m_axi_arcache(2) <= \<const0>\;
  m_axi_arcache(1 downto 0) <= \^m_axi_arcache\(1 downto 0);
  m_axi_arid(3) <= \<const0>\;
  m_axi_arid(2) <= \<const0>\;
  m_axi_arid(1) <= \<const0>\;
  m_axi_arid(0) <= \<const0>\;
  m_axi_arlen(7) <= \<const0>\;
  m_axi_arlen(6) <= \<const0>\;
  m_axi_arlen(5) <= \<const0>\;
  m_axi_arlen(4) <= \<const0>\;
  m_axi_arlen(3 downto 2) <= \^m_axi_arlen\(3 downto 2);
  m_axi_arlen(1) <= \^m_axi_awlen\(0);
  m_axi_arlen(0) <= \^m_axi_awlen\(0);
  m_axi_arlock <= \<const0>\;
  m_axi_arprot(2 downto 0) <= \^m_axi_arprot\(2 downto 0);
  m_axi_arsize(2 downto 0) <= \^m_axi_arsize\(2 downto 0);
  m_axi_arvalid <= \^m_axi_arvalid\;
  m_axi_awaddr(31 downto 0) <= \^m_axi_araddr\(31 downto 0);
  m_axi_awburst(1 downto 0) <= \^m_axi_arburst\(1 downto 0);
  m_axi_awcache(3) <= \<const0>\;
  m_axi_awcache(2) <= \<const0>\;
  m_axi_awcache(1 downto 0) <= \^m_axi_arcache\(1 downto 0);
  m_axi_awid(3) <= \<const0>\;
  m_axi_awid(2) <= \<const0>\;
  m_axi_awid(1) <= \<const0>\;
  m_axi_awid(0) <= \<const0>\;
  m_axi_awlen(7) <= \<const0>\;
  m_axi_awlen(6) <= \<const0>\;
  m_axi_awlen(5) <= \<const0>\;
  m_axi_awlen(4) <= \<const0>\;
  m_axi_awlen(3 downto 2) <= \^m_axi_arlen\(3 downto 2);
  m_axi_awlen(1) <= \^m_axi_awlen\(0);
  m_axi_awlen(0) <= \^m_axi_awlen\(0);
  m_axi_awlock <= \<const0>\;
  m_axi_awprot(2 downto 0) <= \^m_axi_arprot\(2 downto 0);
  m_axi_awsize(2 downto 0) <= \^m_axi_arsize\(2 downto 0);
  m_axi_awvalid <= \^m_axi_awvalid\;
  m_axi_bready <= \^m_axi_bready\;
  m_axi_wlast <= \^m_axi_wlast\;
  m_axi_wstrb(7) <= \^m_axi_wstrb\(6);
  m_axi_wstrb(6) <= \^m_axi_wstrb\(6);
  m_axi_wstrb(5) <= \^m_axi_wstrb\(6);
  m_axi_wstrb(4) <= \^m_axi_wstrb\(6);
  m_axi_wstrb(3) <= \^m_axi_wstrb\(6);
  m_axi_wstrb(2) <= \^m_axi_wstrb\(6);
  m_axi_wstrb(1) <= \^m_axi_wstrb\(6);
  m_axi_wstrb(0) <= \^m_axi_wstrb\(6);
AHBLITE_AXI_CONTROL: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_control
     port map (
      D(2) => AHB_IF_n_14,
      D(1) => AHB_IF_n_15,
      D(0) => AHB_IF_n_16,
      E(0) => burst_term_txer_cnt_i0,
      \FSM_onehot_ctl_sm_cs_reg[0]_0\ => AHB_IF_n_17,
      \FSM_onehot_ctl_sm_cs_reg[0]_1\ => \^m_axi_wlast\,
      \FSM_onehot_ctl_sm_cs_reg[0]_2\ => AXI_RCHANNEL_n_4,
      \FSM_onehot_ctl_sm_cs_reg[0]_3\ => AXI_RCHANNEL_n_7,
      \FSM_onehot_ctl_sm_cs_reg[2]_0\ => AHBLITE_AXI_CONTROL_n_14,
      \FSM_onehot_ctl_sm_cs_reg[3]_0\ => AHBLITE_AXI_CONTROL_n_8,
      \FSM_onehot_ctl_sm_cs_reg[4]_0\ => AHBLITE_AXI_CONTROL_n_13,
      \FSM_onehot_ctl_sm_cs_reg[4]_1\ => AHBLITE_AXI_CONTROL_n_15,
      M_AXI_RREADY_i_reg => AXI_RCHANNEL_n_10,
      Q(3) => AHBLITE_AXI_CONTROL_n_1,
      Q(2) => AHBLITE_AXI_CONTROL_n_2,
      Q(1) => AHBLITE_AXI_CONTROL_n_3,
      Q(0) => core_is_idle,
      SS(0) => cntr_rst,
      S_AHB_HREADY_OUT_i_i_6 => AXI_WCHANNEL_n_12,
      S_AHB_HREADY_OUT_i_i_6_0 => AHB_IF_n_25,
      S_AHB_HRESP_i_reg => AHB_IF_n_18,
      ahb_hburst_single => ahb_hburst_single,
      axi_waddr_done_i => axi_waddr_done_i,
      burst_term => burst_term,
      burst_term_hwrite => burst_term_hwrite,
      burst_term_i_reg => AHBLITE_AXI_CONTROL_n_5,
      burst_term_i_reg_0 => AXI_WCHANNEL_n_15,
      burst_term_i_reg_1 => AHB_IF_n_12,
      burst_term_single_incr => burst_term_single_incr,
      idle_txfer_pending => idle_txfer_pending,
      idle_txfer_pending_reg => AHBLITE_AXI_CONTROL_n_6,
      last_axi_rd_sample => last_axi_rd_sample,
      m_axi_bready => \^m_axi_bready\,
      m_axi_bresp(0) => m_axi_bresp(1),
      m_axi_bvalid => m_axi_bvalid,
      m_axi_bvalid_0 => AHBLITE_AXI_CONTROL_n_18,
      m_axi_wready => m_axi_wready,
      nonseq_detected => nonseq_detected,
      nonseq_txfer_pending => nonseq_txfer_pending,
      nonseq_txfer_pending_i_reg => AHB_IF_n_20,
      p_10_in => p_10_in,
      s_ahb_hburst(1 downto 0) => s_ahb_hburst(2 downto 1),
      \s_ahb_hburst[2]\ => AHBLITE_AXI_CONTROL_n_19,
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hready_in => s_ahb_hready_in,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_hsel => s_ahb_hsel,
      s_ahb_htrans(1 downto 0) => s_ahb_htrans(1 downto 0),
      \s_ahb_htrans[0]_0\ => AHBLITE_AXI_CONTROL_n_20,
      \s_ahb_htrans[1]_0\ => AHBLITE_AXI_CONTROL_n_16,
      s_ahb_htrans_0_sp_1 => AHBLITE_AXI_CONTROL_n_9,
      s_ahb_htrans_1_sp_1 => AHBLITE_AXI_CONTROL_n_7,
      s_ahb_hwrite => s_ahb_hwrite,
      s_ahb_hwrite_0 => AHBLITE_AXI_CONTROL_n_17,
      set_axi_waddr => set_axi_waddr,
      set_hresp_err => set_hresp_err
    );
AHB_DATA_COUNTER: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_data_counter
     port map (
      E(0) => AHB_IF_n_22,
      Q(4) => AHB_DATA_COUNTER_n_1,
      Q(3) => AHB_DATA_COUNTER_n_2,
      Q(2) => AHB_DATA_COUNTER_n_3,
      Q(1) => AHB_DATA_COUNTER_n_4,
      Q(0) => AHB_DATA_COUNTER_n_5,
      SS(0) => cntr_rst,
      ahb_penult_beat_reg => AHB_IF_n_20,
      ahb_penult_beat_reg_0 => AHB_IF_n_5,
      ahb_penult_beat_reg_1(2 downto 0) => valid_cnt_required(3 downto 1),
      nonseq_detected => nonseq_detected,
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_htrans(1 downto 0) => s_ahb_htrans(1 downto 0),
      s_ahb_htrans_0_sp_1 => AHB_DATA_COUNTER_n_0
    );
AHB_IF: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahb_if
     port map (
      D(2) => AHB_IF_n_14,
      D(1) => AHB_IF_n_15,
      D(0) => AHB_IF_n_16,
      E(0) => AHB_IF_n_22,
      \FSM_onehot_ctl_sm_cs_reg[0]\ => AXI_RCHANNEL_n_7,
      \FSM_onehot_ctl_sm_cs_reg[0]_0\ => AHBLITE_AXI_CONTROL_n_15,
      \INFERRED_GEN.icount_out_reg[0]\ => AHB_IF_n_27,
      \INFERRED_GEN.icount_out_reg[0]_0\ => AHB_IF_n_29,
      \INFERRED_GEN.icount_out_reg[4]\ => AHB_IF_n_28,
      M_AXI_ARVALID_i_reg => \^m_axi_arvalid\,
      M_AXI_WVALID_i_reg => AXI_WCHANNEL_n_13,
      M_AXI_WVALID_i_reg_0(0) => axi_waddr_done_i,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(4) => AXI_WCHANNEL_n_7,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(3) => AXI_WCHANNEL_n_8,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(2) => AXI_WCHANNEL_n_9,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(1) => AXI_WCHANNEL_n_10,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_4_0\(0) => AXI_WCHANNEL_n_11,
      Q(3) => AHBLITE_AXI_CONTROL_n_1,
      Q(2) => AHBLITE_AXI_CONTROL_n_2,
      Q(1) => AHBLITE_AXI_CONTROL_n_3,
      Q(0) => core_is_idle,
      SS(0) => cntr_rst,
      \S_AHB_HRDATA_i_reg[63]_0\(0) => rd_load_timeout_cntr,
      S_AHB_HREADY_OUT_i_reg_0 => AHBLITE_AXI_CONTROL_n_14,
      S_AHB_HREADY_OUT_i_reg_1 => AXI_RCHANNEL_n_6,
      S_AHB_HREADY_OUT_i_reg_2 => AHBLITE_AXI_CONTROL_n_13,
      S_AHB_HREADY_OUT_i_reg_3 => AXI_RCHANNEL_n_8,
      S_AHB_HREADY_OUT_i_reg_4 => AHBLITE_AXI_CONTROL_n_20,
      S_AHB_HRESP_i_reg_0 => AXI_RCHANNEL_n_4,
      ahb_data_valid => ahb_data_valid,
      ahb_data_valid_burst_term => ahb_data_valid_burst_term,
      ahb_data_valid_i_reg_0 => AXI_WCHANNEL_n_14,
      ahb_done_axi_in_progress_reg_0 => \^m_axi_wlast\,
      ahb_done_axi_in_progress_reg_1 => AXI_RCHANNEL_n_2,
      ahb_hburst_incr_i_reg_0 => AHB_IF_n_17,
      ahb_hburst_incr_i_reg_1 => AHB_IF_n_23,
      ahb_hburst_incr_i_reg_2 => AHB_IF_n_25,
      ahb_hburst_single => ahb_hburst_single,
      ahb_penult_beat_reg_0 => AHB_IF_n_5,
      ahb_penult_beat_reg_1 => AHB_DATA_COUNTER_n_0,
      ahb_wnr_i_reg => AHBLITE_AXI_CONTROL_n_8,
      ahb_wnr_i_reg_0 => AXI_RCHANNEL_n_3,
      burst_term => burst_term,
      \burst_term_cur_cnt_i_reg[0]_0\ => AHB_IF_n_35,
      \burst_term_cur_cnt_i_reg[4]_0\(4 downto 0) => burst_term_cur_cnt(4 downto 0),
      \burst_term_cur_cnt_i_reg[4]_1\(4) => AHB_DATA_COUNTER_n_1,
      \burst_term_cur_cnt_i_reg[4]_1\(3) => AHB_DATA_COUNTER_n_2,
      \burst_term_cur_cnt_i_reg[4]_1\(2) => AHB_DATA_COUNTER_n_3,
      \burst_term_cur_cnt_i_reg[4]_1\(1) => AHB_DATA_COUNTER_n_4,
      \burst_term_cur_cnt_i_reg[4]_1\(0) => AHB_DATA_COUNTER_n_5,
      burst_term_hwrite => burst_term_hwrite,
      burst_term_hwrite_reg_0 => AHBLITE_AXI_CONTROL_n_17,
      burst_term_i_reg_0 => AHBLITE_AXI_CONTROL_n_5,
      burst_term_single_incr => burst_term_single_incr,
      burst_term_single_incr_reg_0 => AHBLITE_AXI_CONTROL_n_19,
      \burst_term_txer_cnt_i_reg[2]_0\ => AHB_IF_n_26,
      \burst_term_txer_cnt_i_reg[3]_0\(0) => burst_term_txer_cnt_i0,
      dummy_txfer_in_progress_reg_0 => AHB_IF_n_12,
      dummy_txfer_in_progress_reg_1 => AHBLITE_AXI_CONTROL_n_6,
      idle_txfer_pending => idle_txfer_pending,
      idle_txfer_pending_reg_0 => AHBLITE_AXI_CONTROL_n_7,
      m_axi_araddr(31 downto 0) => \^m_axi_araddr\(31 downto 0),
      m_axi_arburst(1 downto 0) => \^m_axi_arburst\(1 downto 0),
      m_axi_arcache(1 downto 0) => \^m_axi_arcache\(1 downto 0),
      m_axi_arlen(2 downto 1) => \^m_axi_arlen\(3 downto 2),
      m_axi_arlen(0) => \^m_axi_awlen\(0),
      m_axi_arprot(2 downto 0) => \^m_axi_arprot\(2 downto 0),
      m_axi_arready => m_axi_arready,
      m_axi_arready_0 => AHB_IF_n_39,
      m_axi_arsize(2 downto 0) => \^m_axi_arsize\(2 downto 0),
      m_axi_awready => m_axi_awready,
      m_axi_awready_0 => AHB_IF_n_37,
      m_axi_awvalid => \^m_axi_awvalid\,
      m_axi_bresp(0) => m_axi_bresp(1),
      m_axi_bvalid => m_axi_bvalid,
      m_axi_rdata(63 downto 0) => m_axi_rdata(63 downto 0),
      m_axi_wready => m_axi_wready,
      m_axi_wready_0 => AHB_IF_n_24,
      nonseq_detected => nonseq_detected,
      nonseq_txfer_pending => nonseq_txfer_pending,
      nonseq_txfer_pending_i_reg_0 => AHB_IF_n_18,
      nonseq_txfer_pending_i_reg_1 => AHB_IF_n_38,
      nonseq_txfer_pending_i_reg_2 => AHBLITE_AXI_CONTROL_n_16,
      p_10_in => p_10_in,
      s_ahb_haddr(31 downto 0) => s_ahb_haddr(31 downto 0),
      s_ahb_hburst(2 downto 0) => s_ahb_hburst(2 downto 0),
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hprot(3 downto 0) => s_ahb_hprot(3 downto 0),
      s_ahb_hrdata(63 downto 0) => s_ahb_hrdata(63 downto 0),
      s_ahb_hready_in => s_ahb_hready_in,
      s_ahb_hready_in_0 => AHB_IF_n_36,
      s_ahb_hready_out => s_ahb_hready_out,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_hresp => s_ahb_hresp,
      s_ahb_hsel => s_ahb_hsel,
      s_ahb_hsel_0 => AHB_IF_n_20,
      s_ahb_hsize(2 downto 0) => s_ahb_hsize(2 downto 0),
      s_ahb_htrans(1 downto 0) => s_ahb_htrans(1 downto 0),
      s_ahb_hwrite => s_ahb_hwrite,
      set_axi_waddr => set_axi_waddr,
      set_hresp_err => set_hresp_err,
      \valid_cnt_required_i_reg[3]_0\(2 downto 0) => valid_cnt_required(3 downto 1)
    );
AXI_RCHANNEL: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_rchannel
     port map (
      \FSM_onehot_ctl_sm_cs_reg[5]\ => AXI_RCHANNEL_n_3,
      \FSM_onehot_ctl_sm_cs_reg[5]_0\ => AXI_RCHANNEL_n_6,
      M_AXI_ARVALID_i_reg_0 => \^m_axi_arvalid\,
      M_AXI_ARVALID_i_reg_1 => AHB_IF_n_39,
      M_AXI_RREADY_i_reg_0 => m_axi_rready,
      M_AXI_RREADY_i_reg_1(0) => rd_load_timeout_cntr,
      M_AXI_RREADY_i_reg_2 => AHBLITE_AXI_CONTROL_n_9,
      Q(0) => AHBLITE_AXI_CONTROL_n_1,
      SS(0) => cntr_rst,
      ahb_rd_req_reg_0 => AXI_RCHANNEL_n_8,
      ahb_rd_txer_pending_reg_0 => AXI_RCHANNEL_n_4,
      ahb_rd_txer_pending_reg_1 => AHB_IF_n_36,
      axi_rd_avlbl_reg_0 => AXI_RCHANNEL_n_10,
      \axi_rresp_avlbl_reg[1]_0\ => AHB_IF_n_20,
      idle_txfer_pending => idle_txfer_pending,
      last_axi_rd_sample => last_axi_rd_sample,
      m_axi_arready => m_axi_arready,
      m_axi_rlast => m_axi_rlast,
      m_axi_rresp(0) => m_axi_rresp(1),
      \m_axi_rresp[1]\ => AXI_RCHANNEL_n_7,
      m_axi_rvalid => m_axi_rvalid,
      nonseq_detected => nonseq_detected,
      nonseq_txfer_pending => nonseq_txfer_pending,
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hready_in => s_ahb_hready_in,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_hsel => s_ahb_hsel,
      s_ahb_htrans(1 downto 0) => s_ahb_htrans(1 downto 0),
      s_ahb_htrans_1_sp_1 => AXI_RCHANNEL_n_2
    );
AXI_WCHANNEL: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_axi_wchannel
     port map (
      D(2 downto 0) => valid_cnt_required(3 downto 1),
      E(0) => axi_waddr_done_i,
      M_AXI_AWVALID_i_reg_0 => AHB_IF_n_37,
      M_AXI_BREADY_i_reg_0 => AHBLITE_AXI_CONTROL_n_18,
      M_AXI_WLAST_i_reg_0 => \^m_axi_wlast\,
      M_AXI_WLAST_i_reg_1 => AHB_IF_n_24,
      M_AXI_WVALID_i_reg_0 => m_axi_wvalid,
      M_AXI_WVALID_i_reg_1 => AHB_IF_n_23,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2\(4 downto 0) => burst_term_cur_cnt(4 downto 0),
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i[7]_i_2_0\ => AHB_IF_n_35,
      \NARROW_TRANSFER_OFF.M_AXI_WSTRB_i_reg[7]_0\ => AHB_IF_n_29,
      Q(4) => AXI_WCHANNEL_n_7,
      Q(3) => AXI_WCHANNEL_n_8,
      Q(2) => AXI_WCHANNEL_n_9,
      Q(1) => AXI_WCHANNEL_n_10,
      Q(0) => AXI_WCHANNEL_n_11,
      SS(0) => cntr_rst,
      ahb_data_valid => ahb_data_valid,
      ahb_data_valid_burst_term => ahb_data_valid_burst_term,
      ahb_data_valid_burst_term_reg_0 => AHB_IF_n_38,
      axi_last_beat_reg_0 => AHB_IF_n_27,
      axi_penult_beat_reg_0 => AHB_IF_n_26,
      axi_penult_beat_reg_1 => AHB_IF_n_28,
      burst_term => burst_term,
      local_en_reg_0 => AXI_WCHANNEL_n_13,
      m_axi_awvalid => \^m_axi_awvalid\,
      m_axi_bready => \^m_axi_bready\,
      m_axi_wdata(63 downto 0) => m_axi_wdata(63 downto 0),
      m_axi_wready => m_axi_wready,
      m_axi_wready_0 => AXI_WCHANNEL_n_12,
      m_axi_wready_1 => AXI_WCHANNEL_n_15,
      m_axi_wstrb(0) => \^m_axi_wstrb\(6),
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hready_in => s_ahb_hready_in,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_hsel => s_ahb_hsel,
      s_ahb_htrans(0) => s_ahb_htrans(1),
      \s_ahb_htrans[1]\ => AXI_WCHANNEL_n_14,
      s_ahb_hwdata(63 downto 0) => s_ahb_hwdata(63 downto 0),
      set_axi_waddr => set_axi_waddr
    );
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    s_ahb_hclk : in STD_LOGIC;
    s_ahb_hresetn : in STD_LOGIC;
    s_ahb_hsel : in STD_LOGIC;
    s_ahb_haddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_ahb_hprot : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_ahb_htrans : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_ahb_hsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ahb_hwrite : in STD_LOGIC;
    s_ahb_hburst : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_ahb_hwdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_ahb_hready_out : out STD_LOGIC;
    s_ahb_hready_in : in STD_LOGIC;
    s_ahb_hrdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    s_ahb_hresp : out STD_LOGIC;
    m_axi_awid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_awlock : out STD_LOGIC;
    m_axi_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_wlast : out STD_LOGIC;
    m_axi_wvalid : out STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_arid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_arlock : out STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rvalid : in STD_LOGIC;
    m_axi_rlast : in STD_LOGIC;
    m_axi_rready : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "zynqmpsoc_ahblite_axi_bridge_0_0,ahblite_axi_bridge,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "ahblite_axi_bridge,Vivado 2019.2.1";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  attribute C_AHB_AXI_TIMEOUT : integer;
  attribute C_AHB_AXI_TIMEOUT of U0 : label is 0;
  attribute C_FAMILY : string;
  attribute C_FAMILY of U0 : label is "zynquplus";
  attribute C_INSTANCE : string;
  attribute C_INSTANCE of U0 : label is "zynqmpsoc_ahblite_axi_bridge_0_0";
  attribute C_M_AXI_ADDR_WIDTH : integer;
  attribute C_M_AXI_ADDR_WIDTH of U0 : label is 32;
  attribute C_M_AXI_DATA_WIDTH : integer;
  attribute C_M_AXI_DATA_WIDTH of U0 : label is 64;
  attribute C_M_AXI_NON_SECURE : integer;
  attribute C_M_AXI_NON_SECURE of U0 : label is 1;
  attribute C_M_AXI_PROTOCOL : string;
  attribute C_M_AXI_PROTOCOL of U0 : label is "AXI4";
  attribute C_M_AXI_SUPPORTS_NARROW_BURST : integer;
  attribute C_M_AXI_SUPPORTS_NARROW_BURST of U0 : label is 0;
  attribute C_M_AXI_THREAD_ID_WIDTH : integer;
  attribute C_M_AXI_THREAD_ID_WIDTH of U0 : label is 4;
  attribute C_S_AHB_ADDR_WIDTH : integer;
  attribute C_S_AHB_ADDR_WIDTH of U0 : label is 32;
  attribute C_S_AHB_DATA_WIDTH : integer;
  attribute C_S_AHB_DATA_WIDTH of U0 : label is 64;
  attribute downgradeipidentifiedwarnings of U0 : label is "yes";
  attribute x_interface_info : string;
  attribute x_interface_info of m_axi_arlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARLOCK";
  attribute x_interface_info of m_axi_arready : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARREADY";
  attribute x_interface_info of m_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARVALID";
  attribute x_interface_info of m_axi_awlock : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWLOCK";
  attribute x_interface_info of m_axi_awready : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWREADY";
  attribute x_interface_info of m_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWVALID";
  attribute x_interface_info of m_axi_bready : signal is "xilinx.com:interface:aximm:1.0 M_AXI BREADY";
  attribute x_interface_info of m_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI BVALID";
  attribute x_interface_info of m_axi_rlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI RLAST";
  attribute x_interface_info of m_axi_rready : signal is "xilinx.com:interface:aximm:1.0 M_AXI RREADY";
  attribute x_interface_info of m_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI RVALID";
  attribute x_interface_info of m_axi_wlast : signal is "xilinx.com:interface:aximm:1.0 M_AXI WLAST";
  attribute x_interface_info of m_axi_wready : signal is "xilinx.com:interface:aximm:1.0 M_AXI WREADY";
  attribute x_interface_info of m_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI WVALID";
  attribute x_interface_info of s_ahb_hclk : signal is "xilinx.com:signal:clock:1.0 AHB_CLK CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of s_ahb_hclk : signal is "XIL_INTERFACENAME AHB_CLK, ASSOCIATED_BUSIF AHB_INTERFACE:M_AXI, ASSOCIATED_RESET s_ahb_hresetn, FREQ_HZ 75000000, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute x_interface_info of s_ahb_hready_in : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HREADY_IN";
  attribute x_interface_info of s_ahb_hready_out : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HREADY_OUT";
  attribute x_interface_info of s_ahb_hresetn : signal is "xilinx.com:signal:reset:1.0 AHB_RESETN RST";
  attribute x_interface_parameter of s_ahb_hresetn : signal is "XIL_INTERFACENAME AHB_RESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute x_interface_info of s_ahb_hresp : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HRESP";
  attribute x_interface_info of s_ahb_hsel : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE SEL";
  attribute x_interface_parameter of s_ahb_hsel : signal is "XIL_INTERFACENAME AHB_INTERFACE, BD_ATTRIBUTE.TYPE INTERIOR";
  attribute x_interface_info of s_ahb_hwrite : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HWRITE";
  attribute x_interface_info of m_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARADDR";
  attribute x_interface_info of m_axi_arburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARBURST";
  attribute x_interface_info of m_axi_arcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARCACHE";
  attribute x_interface_info of m_axi_arid : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARID";
  attribute x_interface_info of m_axi_arlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARLEN";
  attribute x_interface_info of m_axi_arprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARPROT";
  attribute x_interface_info of m_axi_arsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARSIZE";
  attribute x_interface_info of m_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWADDR";
  attribute x_interface_info of m_axi_awburst : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWBURST";
  attribute x_interface_info of m_axi_awcache : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWCACHE";
  attribute x_interface_info of m_axi_awid : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWID";
  attribute x_interface_parameter of m_axi_awid : signal is "XIL_INTERFACENAME M_AXI, MAX_BURST_LENGTH 16, DATA_WIDTH 64, PROTOCOL AXI4, FREQ_HZ 75000000, ID_WIDTH 4, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 16, NUM_WRITE_OUTSTANDING 16, PHASE 0.000, CLK_DOMAIN zynqmpsoc_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute x_interface_info of m_axi_awlen : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWLEN";
  attribute x_interface_info of m_axi_awprot : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWPROT";
  attribute x_interface_info of m_axi_awsize : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWSIZE";
  attribute x_interface_info of m_axi_bid : signal is "xilinx.com:interface:aximm:1.0 M_AXI BID";
  attribute x_interface_info of m_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI BRESP";
  attribute x_interface_info of m_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI RDATA";
  attribute x_interface_info of m_axi_rid : signal is "xilinx.com:interface:aximm:1.0 M_AXI RID";
  attribute x_interface_info of m_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI RRESP";
  attribute x_interface_info of m_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI WDATA";
  attribute x_interface_info of m_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 M_AXI WSTRB";
  attribute x_interface_info of s_ahb_haddr : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HADDR";
  attribute x_interface_info of s_ahb_hburst : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HBURST";
  attribute x_interface_info of s_ahb_hprot : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HPROT";
  attribute x_interface_info of s_ahb_hrdata : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HRDATA";
  attribute x_interface_info of s_ahb_hsize : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HSIZE";
  attribute x_interface_info of s_ahb_htrans : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HTRANS";
  attribute x_interface_info of s_ahb_hwdata : signal is "xilinx.com:interface:ahblite:2.0 AHB_INTERFACE HWDATA";
begin
U0: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ahblite_axi_bridge
     port map (
      m_axi_araddr(31 downto 0) => m_axi_araddr(31 downto 0),
      m_axi_arburst(1 downto 0) => m_axi_arburst(1 downto 0),
      m_axi_arcache(3 downto 0) => m_axi_arcache(3 downto 0),
      m_axi_arid(3 downto 0) => m_axi_arid(3 downto 0),
      m_axi_arlen(7 downto 0) => m_axi_arlen(7 downto 0),
      m_axi_arlock => m_axi_arlock,
      m_axi_arprot(2 downto 0) => m_axi_arprot(2 downto 0),
      m_axi_arready => m_axi_arready,
      m_axi_arsize(2 downto 0) => m_axi_arsize(2 downto 0),
      m_axi_arvalid => m_axi_arvalid,
      m_axi_awaddr(31 downto 0) => m_axi_awaddr(31 downto 0),
      m_axi_awburst(1 downto 0) => m_axi_awburst(1 downto 0),
      m_axi_awcache(3 downto 0) => m_axi_awcache(3 downto 0),
      m_axi_awid(3 downto 0) => m_axi_awid(3 downto 0),
      m_axi_awlen(7 downto 0) => m_axi_awlen(7 downto 0),
      m_axi_awlock => m_axi_awlock,
      m_axi_awprot(2 downto 0) => m_axi_awprot(2 downto 0),
      m_axi_awready => m_axi_awready,
      m_axi_awsize(2 downto 0) => m_axi_awsize(2 downto 0),
      m_axi_awvalid => m_axi_awvalid,
      m_axi_bid(3 downto 0) => m_axi_bid(3 downto 0),
      m_axi_bready => m_axi_bready,
      m_axi_bresp(1 downto 0) => m_axi_bresp(1 downto 0),
      m_axi_bvalid => m_axi_bvalid,
      m_axi_rdata(63 downto 0) => m_axi_rdata(63 downto 0),
      m_axi_rid(3 downto 0) => m_axi_rid(3 downto 0),
      m_axi_rlast => m_axi_rlast,
      m_axi_rready => m_axi_rready,
      m_axi_rresp(1 downto 0) => m_axi_rresp(1 downto 0),
      m_axi_rvalid => m_axi_rvalid,
      m_axi_wdata(63 downto 0) => m_axi_wdata(63 downto 0),
      m_axi_wlast => m_axi_wlast,
      m_axi_wready => m_axi_wready,
      m_axi_wstrb(7 downto 0) => m_axi_wstrb(7 downto 0),
      m_axi_wvalid => m_axi_wvalid,
      s_ahb_haddr(31 downto 0) => s_ahb_haddr(31 downto 0),
      s_ahb_hburst(2 downto 0) => s_ahb_hburst(2 downto 0),
      s_ahb_hclk => s_ahb_hclk,
      s_ahb_hprot(3 downto 0) => s_ahb_hprot(3 downto 0),
      s_ahb_hrdata(63 downto 0) => s_ahb_hrdata(63 downto 0),
      s_ahb_hready_in => s_ahb_hready_in,
      s_ahb_hready_out => s_ahb_hready_out,
      s_ahb_hresetn => s_ahb_hresetn,
      s_ahb_hresp => s_ahb_hresp,
      s_ahb_hsel => s_ahb_hsel,
      s_ahb_hsize(2 downto 0) => s_ahb_hsize(2 downto 0),
      s_ahb_htrans(1 downto 0) => s_ahb_htrans(1 downto 0),
      s_ahb_hwdata(63 downto 0) => s_ahb_hwdata(63 downto 0),
      s_ahb_hwrite => s_ahb_hwrite
    );
end STRUCTURE;
