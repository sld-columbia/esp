// *****************************************************************************
//                         Cadence C-to-Silicon Compiler
//          Version 14.10-p100  (64 bit), build 50398 Tue, 27 May 2014
// 
// File created on Tue Jul 22 15:06:03 2014
// 
// The code contained herein is generated for Cadences customer and third
// parties authorized by customer.  It may be used in accordance with a
// previously executed license agreement between Cadence and that customer.
// Absolutely no disassembling, decompiling, reverse-translations or
// reverse-engineering of the generated code is allowed.
// 
//*****************************************************************************
// 
// **********************************************************
// SystemC structure port(s) --> RTL flattened representation
// **********************************************************
// bufdin.get_initiator_imp<ctos_sc_dt::sc_fixed<32, 16, SC_RND, SC_WRAP, 0>, SIG_TRAITS_pCLK_nRST, 1>::data.m_mant maps to bufdin_data[31:0]
// bufdout.put_initiator_imp<ctos_sc_dt::sc_fixed<32, 16, SC_RND, SC_WRAP, 0>, SIG_TRAITS_pCLK_nRST, 1>::data.m_mant maps to bufdout_data[31:0]

module fft_unisim_rtl(clk, rst, rd_grant, wr_grant, conf_len, conf_log_len, 
conf_done, bufdin_valid, bufdin_data, bufdout_ready, C_Q1, B0_Q1, B1_Q1, A0_Q1, 
A1_Q1, rd_index, rd_length, rd_request, wr_index, wr_length, wr_request, 
dft_done, bufdin_ready, bufdout_valid, bufdout_data, C_CE0, C_A0, C_D0, C_WE0, 
C_WEM0, C_CE1, C_A1, B0_CE0, B0_A0, B0_D0, B0_WE0, B0_WEM0, B0_CE1, B0_A1, 
B1_CE0, B1_A0, B1_D0, B1_WE0, B1_WEM0, B1_CE1, B1_A1, A0_CE0, A0_A0, A0_D0, 
A0_WE0, A0_WEM0, A0_CE1, A0_A1, A1_CE0, A1_A0, A1_D0, A1_WE0, A1_WEM0, A1_CE1, 
A1_A1);
  input clk;
  input rst;
  input rd_grant;
  input wr_grant;
  input [31:0] conf_len;
  input [31:0] conf_log_len;
  input conf_done;
  input bufdin_valid;
  input [31:0] bufdin_data;
  input bufdout_ready;
  input [63:0] C_Q1;
  input [63:0] B0_Q1;
  input [63:0] B1_Q1;
  input [63:0] A0_Q1;
  input [63:0] A1_Q1;
  output reg [31:0] rd_index;
  output reg [31:0] rd_length;
  output reg rd_request;
  output reg [31:0] wr_index;
  output reg [31:0] wr_length;
  output reg wr_request;
  output reg dft_done;
  output bufdin_ready;
  output bufdout_valid;
  output reg [31:0] bufdout_data;
  output C_CE0;
  output [9:0] C_A0;
  output [63:0] C_D0;
  output C_WE0;
  output [1:0] C_WEM0;
  output C_CE1;
  output [9:0] C_A1;
  output B0_CE0;
  output [9:0] B0_A0;
  output [63:0] B0_D0;
  output B0_WE0;
  output [1:0] B0_WEM0;
  output B0_CE1;
  output [9:0] B0_A1;
  output B1_CE0;
  output [9:0] B1_A0;
  output [63:0] B1_D0;
  output B1_WE0;
  output [1:0] B1_WEM0;
  output B1_CE1;
  output [9:0] B1_A1;
  output A0_CE0;
  output [9:0] A0_A0;
  output [63:0] A0_D0;
  output A0_WE0;
  output [1:0] A0_WEM0;
  output A0_CE1;
  output [9:0] A0_A1;
  output A1_CE0;
  output [9:0] A1_A0;
  output [63:0] A1_D0;
  output A1_WE0;
  output [1:0] A1_WEM0;
  output A1_CE1;
  output [9:0] A1_A1;
  reg [31:0] len;
  reg [31:0] log_len;
  reg init_done;
  reg input_ready;
  reg loop_start;
  reg loop_done;
  reg output_start;
  reg bufdin_set_ready_curr;
  wire [31:0] bufdin_data_buf;
  wire bufdin_can_get_sig;
  wire bufdin_sync_rcv_set_ready_prev;
  wire bufdin_sync_rcv_reset_ready_prev;
  wire bufdin_sync_rcv_reset_ready_curr;
  wire bufdin_sync_rcv_ready_flop;
  reg bufdout_set_valid_curr;
  wire bufdout_can_put_sig;
  wire bufdout_sync_snd_set_valid_prev;
  wire bufdout_sync_snd_reset_valid_prev;
  wire bufdout_sync_snd_reset_valid_curr;
  wire bufdout_sync_snd_valid_flop;
  reg [1:0] state_fft_unisim_fft_config_fft;
  reg [1:0] state_fft_unisim_fft_config_fft_next;
  reg [31:0] log_len_d;
  reg [31:0] len_d;
  reg init_done_d;
  reg [27:0] state_fft_unisim_fft_load_input;
  reg [27:0] state_fft_unisim_fft_load_input_next;
  reg [31:0] mux_index_ln123_q;
  reg [31:0] mux_s_ln123_q;
  reg [9:0] add_ln180_1_q;
  reg [9:0] mux_i_0_ln180_q;
  reg [8:0] add_ln228_1_q;
  reg [8:0] mux_i_1_ln228_q;
  reg [9:0] add_ln260_1_q;
  reg [9:0] mux_i_2_ln260_q;
  reg [9:0] add_ln143_1_q;
  reg [9:0] mux_i_ln143_q;
  reg [31:0] add_ln250_q;
  reg unary_or_ln231_Z_0_tag_0;
  reg [31:0] mux_base_ln123_q;
  reg [31:0] mux_s_ln203_q;
  reg [31:0] mux_index_ln203_q;
  reg [7:0] mux_ping_ln123_q;
  reg [31:0] read_fft_len_ln119_q;
  reg [31:0] read_fft_log_len_ln120_q;
  reg le_ln128_q;
  reg unary_or_ln183_Z_0_tag_0;
  reg [31:0] mux_s_ln288_q;
  reg [31:0] mux_index_ln288_q;
  reg [31:0] mux_base_ln288_q;
  reg A1_bridge0_rtl_CE_en;
  reg [9:0] A1_bridge0_rtl_a;
  reg [63:0] A1_bridge0_rtl_d;
  reg [1:0] A1_bridge0_rtl_wem;
  reg A0_bridge0_rtl_CE_en;
  reg [9:0] A0_bridge0_rtl_a;
  reg [63:0] A0_bridge0_rtl_d;
  reg [1:0] A0_bridge0_rtl_wem;
  reg [31:0] mux_index_ln123_z;
  reg [31:0] mux_s_ln123_z;
  reg [10:0] mux_i_0_ln180_d;
  reg [8:0] mux_i_0_ln180_1_d_0;
  reg [9:0] mux_i_1_ln228_d;
  reg [7:0] mux_i_1_ln228_1_d_0;
  reg [10:0] mux_i_2_ln260_d;
  reg [8:0] mux_i_2_ln260_1_d_0;
  reg input_ready_d;
  reg [10:0] mux_i_ln143_d;
  reg [8:0] mux_i_ln143_1_d_0;
  reg [31:0] add_ln250_d;
  reg unary_or_ln231_Z_0_tag_d;
  reg [31:0] rd_length_d;
  reg [31:0] rd_index_d;
  reg rd_request_d;
  reg [31:0] mux_base_ln123_d;
  reg [63:0] mux_index_ln203_d;
  reg [7:0] mux_ping_ln123_d;
  reg [63:0] read_fft_len_ln119_d;
  reg read_fft_len_ln119_31_d;
  reg unary_or_ln183_Z_0_tag_d;
  reg bufdin_set_ready_curr_d;
  reg [63:0] mux_index_ln288_d;
  reg [31:0] mux_base_ln288_d;
  reg [31:0] state_fft_unisim_fft_process_itr_fft;
  reg [31:0] state_fft_unisim_fft_process_itr_fft_next;
  reg [63:0] memread_fft_A0_ln550_q;
  reg [63:0] memread_fft_C_ln557_q;
  reg [46:0] add_ln176_5_15_q;
  reg [46:0] add_ln176_6_15_q;
  reg [46:0] add_ln176_7_15_q;
  reg [63:0] mux_akjm32_ln549_q;
  reg [63:0] mux_akjm32_0_ln631_q;
  reg [63:0] mux_akjm32_1_ln703_q;
  reg [46:0] sub_ln196_8_15_q;
  reg [46:0] sub_ln196_9_15_q;
  reg [46:0] sub_ln196_10_15_q;
  reg [31:0] add_ln404_7_q;
  reg [31:0] add_ln404_8_q;
  reg [31:0] add_ln404_11_q;
  reg [31:0] add_ln404_12_q;
  reg [31:0] add_ln404_15_q;
  reg [31:0] add_ln404_16_q;
  reg [63:0] mux_akj32_ln549_q;
  reg [77:0] mul_ln221_q;
  reg [77:0] mul_ln221_1_q;
  reg [77:0] mul_ln221_0_q;
  reg [77:0] mul_ln221_2_q;
  reg [77:0] mul_ln221_3_q;
  reg [77:0] mul_ln221_5_q;
  reg [77:0] mul_ln221_4_q;
  reg [77:0] mul_ln221_6_q;
  reg [95:0] mux_w_0_ln619_q;
  reg [77:0] mul_ln221_7_q;
  reg [77:0] mul_ln221_9_q;
  reg [77:0] mul_ln221_8_q;
  reg [77:0] mul_ln221_10_q;
  reg [63:0] mux_akj32_0_ln631_q;
  reg [63:0] mux_akj32_1_ln703_q;
  reg [47:0] add_ln404_q;
  reg [47:0] add_ln404_0_q;
  reg [47:0] add_ln404_2_q;
  reg [47:0] add_ln404_1_q;
  reg [47:0] add_ln404_4_q;
  reg [95:0] mux_w_1_ln693_q;
  reg or_and_0_ln530_Z_0_q;
  reg or_and_0_ln620_Z_0_q;
  reg [9:0] add_ln623_q;
  reg [8:0] mux_j_1_ln693_q;
  reg [8:0] add_ln693_1_q;
  reg [95:0] mux_wsplit_ln754_q;
  reg [47:0] add_ln404_3_q;
  reg [21:0] mux_windex_ln501_q;
  reg [95:0] mux_wsplit_ln501_q;
  reg [31:0] mux_s_ln763_q;
  reg le_ln603_q;
  reg and_1_ln530_q;
  reg lt_ln613_q;
  reg [9:0] mux_k_0_ln613_q;
  reg [9:0] add_ln613_q;
  reg and_1_ln620_q;
  reg [9:0] add_ln624_0_q;
  reg mux_j_0_ln619_q;
  reg [8:0] add_ln619_1_q;
  reg and_1_ln511_q;
  reg or_and_0_ln511_Z_0_q;
  reg [28:0] mux_myCos_ln24_0_q;
  reg unary_or_ln631_Z_0_tag_0;
  reg [31:0] lsh_ln608_q;
  reg [31:0] mux_s_ln490_q;
  reg [30:0] mux_mySin_ln47_0_q;
  reg [30:0] add_div_ln616_q;
  reg [9:0] add_ln541_q;
  reg [9:0] add_ln542_0_q;
  reg mux_j_ln537_q;
  reg [8:0] add_ln537_1_q;
  reg [95:0] mux_w_ln537_q;
  reg [28:0] mux_myCos_ln24_1_q;
  reg [30:0] mux_mySin_ln47_1_q;
  reg unary_or_ln703_Z_0_tag_0;
  reg eq_ln754_q;
  reg [21:0] mux_windex_ln754_q;
  reg eq_ln763_Z_0_tag_0;
  reg [9:0] mux_k_ln529_q;
  reg [31:0] add_ln529_q;
  reg [7:0] mux_ping_ln490_q;
  reg [21:0] mux_index_ln763_q;
  reg eq_ln549_Z_0_tag_0;
  reg eq_ln584_Z_0_tag_0;
  reg [15:0] lsh_ln514_q;
  reg [28:0] mux_myCos_ln24_q;
  reg [3:0] mux_s_ln510_q;
  reg [2:0] add_ln510_1_q;
  reg [30:0] mux_mySin_ln47_q;
  reg [21:0] mux_windex_ln490_q;
  reg [95:0] mux_wsplit_ln490_q;
  reg [31:0] read_fft_len_ln483_q;
  reg [3:0] read_fft_log_len_ln484_q;
  reg le_ln501_q;
  reg C_bridge0_rtl_CE_en;
  reg [9:0] C_bridge0_rtl_a;
  reg [63:0] C_bridge0_rtl_d;
  reg B1_bridge0_rtl_CE_en;
  reg [9:0] B1_bridge0_rtl_a;
  reg [63:0] B1_bridge0_rtl_d;
  reg B0_bridge0_rtl_CE_en;
  reg [9:0] B0_bridge0_rtl_a;
  reg [63:0] B0_bridge0_rtl_d;
  reg A1_bridge1_rtl_CE_en;
  reg [9:0] A1_bridge1_rtl_a;
  wire [63:0] A1_bridge1_rtl_Q;
  reg A0_bridge1_rtl_CE_en;
  reg [9:0] A0_bridge1_rtl_a;
  wire [63:0] A0_bridge1_rtl_Q;
  reg C_bridge1_rtl_CE_en;
  reg [9:0] C_bridge1_rtl_a;
  wire [63:0] C_bridge1_rtl_Q;
  reg [61:0] add_ln176_5_z;
  reg [61:0] add_ln176_6_z;
  reg [61:0] add_ln176_7_z;
  reg [63:0] mux_akjm32_ln549_z;
  reg [63:0] mux_akjm32_0_ln631_z;
  reg [63:0] mux_akjm32_1_ln703_z;
  reg [61:0] sub_ln196_8_z;
  reg [61:0] sub_ln196_9_z;
  reg [61:0] sub_ln196_10_z;
  reg [31:0] add_ln404_7_z;
  reg [31:0] add_ln404_8_z;
  reg [31:0] add_ln404_11_z;
  reg [31:0] add_ln404_12_z;
  reg [31:0] add_ln404_15_z;
  reg [31:0] add_ln404_16_z;
  reg [63:0] mux_akj32_ln549_d;
  reg signed [77:0] mul_ln221_z;
  reg signed [77:0] mul_ln221_1_z;
  reg signed [77:0] mul_ln221_0_z;
  reg signed [77:0] mul_ln221_2_z;
  reg signed [77:0] mul_ln221_3_z;
  reg signed [77:0] mul_ln221_5_z;
  reg signed [77:0] mul_ln221_4_z;
  reg signed [77:0] mul_ln221_6_z;
  reg [63:0] mux_w_0_ln619_d;
  reg [31:0] mux_w_0_ln619_64_d_0;
  reg signed [77:0] mul_ln221_7_z;
  reg signed [77:0] mul_ln221_9_z;
  reg signed [77:0] mul_ln221_8_z;
  reg signed [77:0] mul_ln221_10_z;
  reg [63:0] mux_akj32_0_ln631_d;
  reg [63:0] mux_akj32_1_ln703_d;
  reg [63:0] add_ln404_0_d_0;
  reg [31:0] add_ln404_16_d_0;
  reg [63:0] add_ln404_2_d_0;
  reg [31:0] add_ln404_1_16_d_0;
  reg [63:0] add_ln404_4_d_0;
  reg [63:0] mux_w_1_ln693_d;
  reg [31:0] mux_w_1_ln693_64_d_0;
  reg loop_start_d;
  reg or_and_0_ln530_Z_0_z;
  reg or_and_0_ln620_Z_0_z;
  reg [9:0] add_ln623_d;
  reg [9:0] mux_j_1_ln693_d;
  reg [7:0] mux_j_1_ln693_1_d_0;
  reg [63:0] add_ln404_3_16_d_0;
  reg [63:0] mux_wsplit_ln754_32_d_0;
  reg loop_done_d;
  reg [63:0] mux_windex_ln501_d;
  reg [63:0] mux_wsplit_ln501_42_d_0;
  reg [21:0] mux_s_ln763_10_d_0;
  reg le_ln603_d;
  reg and_1_ln530_z;
  reg [20:0] mux_k_0_ln613_d;
  reg and_1_ln620_z;
  reg [19:0] mux_j_0_ln619_d_0;
  reg and_1_ln511_z;
  reg or_and_0_ln511_Z_0_z;
  reg [63:0] lsh_ln608_d;
  reg [31:0] mux_s_ln490_d;
  reg [59:0] mux_mySin_ln47_0_2_d_0;
  reg [9:0] add_ln541_d;
  reg [9:0] add_ln542_0_d;
  reg [9:0] mux_j_ln537_d_0;
  reg [63:0] mux_w_ln537_d;
  reg [31:0] mux_w_ln537_64_d_0;
  reg [63:0] unary_or_ln703_Z_0_tag_d_0;
  reg [19:0] mux_windex_ln754_2_d_0;
  reg eq_ln763_Z_0_tag_d;
  reg [41:0] mux_k_ln529_d;
  reg [29:0] mux_ping_ln490_d;
  reg [63:0] mux_s_ln510_d;
  reg [3:0] mux_s_ln510_z;
  reg [17:0] mux_mySin_ln47_13_d_0;
  reg [21:0] mux_windex_ln490_d;
  reg [63:0] mux_wsplit_ln490_d;
  reg [31:0] mux_wsplit_ln490_64_d_0;
  reg [36:0] read_fft_len_ln483_d;
  reg [24:0] state_fft_unisim_fft_store_output;
  reg [24:0] state_fft_unisim_fft_store_output_next;
  reg [63:0] memread_fft_B0_ln362_q;
  reg [63:0] mux_data_0_ln390_q;
  reg [63:0] mux_data_1_ln420_q;
  reg [63:0] mux_data_2_ln443_q;
  reg mux_i_0_ln387_q;
  reg [9:0] add_ln387_1_q;
  reg mux_i_1_ln417_q;
  reg [8:0] add_ln417_1_q;
  reg mux_i_2_ln440_q;
  reg [9:0] add_ln440_1_q;
  reg mux_i_ln358_q;
  reg [9:0] add_ln358_1_q;
  reg [31:0] add_ln430_q;
  reg unary_or_ln390_Z_0_tag_0;
  reg [31:0] mux_base_ln331_q;
  reg and_1_ln375_q;
  reg [31:0] mux_index_ln331_q;
  reg and_0_ln375_q;
  reg [31:0] mux_s_ln400_q;
  reg [31:0] mux_index_ln400_q;
  reg [7:0] mux_ping_ln331_q;
  reg [31:0] read_fft_len_ln327_q;
  reg [31:0] read_fft_log_len_ln328_q;
  reg le_ln346_q;
  reg unary_or_ln420_Z_0_tag_0;
  reg [31:0] mux_index_ln459_q;
  reg [31:0] mux_s_ln459_q;
  reg [31:0] mux_base_ln459_q;
  reg B0_bridge1_rtl_CE_en;
  reg [9:0] B0_bridge1_rtl_a;
  wire [63:0] B0_bridge1_rtl_Q;
  reg B1_bridge1_rtl_CE_en;
  reg [9:0] B1_bridge1_rtl_a;
  wire [63:0] B1_bridge1_rtl_Q;
  reg output_start_d;
  reg [63:0] mux_memread_fft_B0_ln362_Q_v;
  reg [31:0] memread_fft_B0_ln362_32_d_0;
  reg [63:0] mux_mux_data_0_ln390_Z_v;
  reg [31:0] mux_data_0_ln390_32_d_0;
  reg [63:0] mux_mux_data_1_ln420_Z_v;
  reg [31:0] mux_data_1_ln420_32_d_0;
  reg [63:0] mux_mux_data_2_ln443_Z_v;
  reg [31:0] mux_data_2_ln443_32_d_0;
  reg bufdout_set_valid_curr_d;
  reg [10:0] mux_i_0_ln387_d_0;
  reg [9:0] mux_i_1_ln417_d_0;
  reg [31:0] wr_index_d;
  reg [31:0] wr_length_d;
  reg wr_request_d;
  reg [10:0] mux_i_2_ln440_d_0;
  reg [31:0] bufdout_data_d;
  reg [10:0] mux_i_ln358_d_0;
  reg dft_done_d;
  reg [31:0] add_ln430_d;
  reg [63:0] mux_base_ln331_d;
  reg [33:0] mux_index_ln331_d;
  reg [32:0] mux_index_ln400_31_d_0;
  reg [7:0] mux_ping_ln331_d;
  reg [63:0] read_fft_len_ln327_d;
  reg read_fft_len_ln327_31_d;
  reg [63:0] unary_or_ln420_Z_0_tag_d_0;
  reg [32:0] mux_s_ln459_31_d_0;

  fft_unisim_fft_bufdin_can_get_mod_process 
                                            fft_unisim_fft_bufdin_can_get_mod_process(
                                            .bufdin_valid(bufdin_valid), .bufdin_ready(
                                            bufdin_ready), .bufdin_can_get_sig(
                                            bufdin_can_get_sig));
  fft_unisim_fft_bufdin_sync_rcv_back_method 
                                             fft_unisim_fft_bufdin_sync_rcv_back_method(
                                             .clk(clk), .rst(rst), .bufdin_valid(
                                             bufdin_valid), .bufdin_ready(
                                             bufdin_ready), .bufdin_set_ready_curr(
                                             bufdin_set_ready_curr), .bufdin_data(
                                             bufdin_data), .bufdin_sync_rcv_set_ready_prev(
                                             bufdin_sync_rcv_set_ready_prev), .bufdin_sync_rcv_reset_ready_prev(
                                             bufdin_sync_rcv_reset_ready_prev), 
                                             .bufdin_sync_rcv_reset_ready_curr(
                                             bufdin_sync_rcv_reset_ready_curr), 
                                             .bufdin_sync_rcv_ready_flop(
                                             bufdin_sync_rcv_ready_flop), .bufdin_data_buf(
                                             bufdin_data_buf));
  fft_unisim_fft_bufdin_sync_rcv_ready_arb 
                                           fft_unisim_fft_bufdin_sync_rcv_ready_arb(
                                           .bufdin_set_ready_curr(
                                           bufdin_set_ready_curr), .bufdin_sync_rcv_set_ready_prev(
                                           bufdin_sync_rcv_set_ready_prev), .bufdin_sync_rcv_reset_ready_curr(
                                           bufdin_sync_rcv_reset_ready_curr), .bufdin_sync_rcv_reset_ready_prev(
                                           bufdin_sync_rcv_reset_ready_prev), .bufdin_sync_rcv_ready_flop(
                                           bufdin_sync_rcv_ready_flop), .bufdin_ready(
                                           bufdin_ready));
  fft_unisim_fft_bufdout_can_put_mod_process 
                                             fft_unisim_fft_bufdout_can_put_mod_process(
                                             .bufdout_valid(bufdout_valid), .bufdout_ready(
                                             bufdout_ready), .bufdout_can_put_sig(
                                             bufdout_can_put_sig));
  fft_unisim_fft_bufdout_sync_snd_back_method 
                                              fft_unisim_fft_bufdout_sync_snd_back_method(
                                              .clk(clk), .rst(rst), .bufdout_ready(
                                              bufdout_ready), .bufdout_valid(
                                              bufdout_valid), .bufdout_set_valid_curr(
                                              bufdout_set_valid_curr), .bufdout_sync_snd_set_valid_prev(
                                              bufdout_sync_snd_set_valid_prev), 
                                              .bufdout_sync_snd_reset_valid_prev(
                                              bufdout_sync_snd_reset_valid_prev), 
                                              .bufdout_sync_snd_reset_valid_curr(
                                              bufdout_sync_snd_reset_valid_curr), 
                                              .bufdout_sync_snd_valid_flop(
                                              bufdout_sync_snd_valid_flop));
  fft_unisim_fft_bufdout_sync_snd_valid_arb 
                                            fft_unisim_fft_bufdout_sync_snd_valid_arb(
                                            .bufdout_set_valid_curr(
                                            bufdout_set_valid_curr), .bufdout_sync_snd_set_valid_prev(
                                            bufdout_sync_snd_set_valid_prev), .bufdout_sync_snd_reset_valid_curr(
                                            bufdout_sync_snd_reset_valid_curr), 
                                            .bufdout_sync_snd_reset_valid_prev(
                                            bufdout_sync_snd_reset_valid_prev), 
                                            .bufdout_sync_snd_valid_flop(
                                            bufdout_sync_snd_valid_flop), .bufdout_valid(
                                            bufdout_valid));
  // synthesis sync_set_reset_local fft_unisim_fft_config_fft_seq_block rst
  always @(posedge clk) // fft_unisim_fft_config_fft_sequential
    begin : fft_unisim_fft_config_fft_seq_block
      if (!rst) // Initialize state and outputs
      begin
        log_len <= 32'sh0;
        len <= 32'sh0;
        init_done <= 1'sb0;
        state_fft_unisim_fft_config_fft <= 2'h1;
      end
      else // Update Q values
      begin
        log_len <= log_len_d;
        len <= len_d;
        init_done <= init_done_d;
        state_fft_unisim_fft_config_fft <= state_fft_unisim_fft_config_fft_next;
      end
    end
  always @(*) begin : fft_unisim_fft_config_fft_combinational
      reg ctrlAnd_1_ln81_z;
      reg ctrlAnd_0_ln81_z;
      reg ctrlOr_ln92_z;

      state_fft_unisim_fft_config_fft_next = 2'h0;
      ctrlAnd_1_ln81_z = conf_done & state_fft_unisim_fft_config_fft[0];
      ctrlAnd_0_ln81_z = !conf_done & state_fft_unisim_fft_config_fft[0];
      if (state_fft_unisim_fft_config_fft[0]) 
        log_len_d = conf_log_len;
      else 
        log_len_d = log_len;
      if (state_fft_unisim_fft_config_fft[0]) 
        len_d = conf_len;
      else 
        len_d = len;
      ctrlOr_ln92_z = state_fft_unisim_fft_config_fft[1] | ctrlAnd_1_ln81_z;
      if (ctrlAnd_1_ln81_z) 
        init_done_d = 1'b1;
      else 
        init_done_d = init_done;
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_config_fft[0]: // Wait_ln82
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln81_z: state_fft_unisim_fft_config_fft_next[0] = 1'b1;
              ctrlOr_ln92_z: state_fft_unisim_fft_config_fft_next[1] = 1'b1;
              default: state_fft_unisim_fft_config_fft_next = 2'hX;
            endcase
          end
        state_fft_unisim_fft_config_fft[1]: // Wait_ln93
          state_fft_unisim_fft_config_fft_next[1] = 1'b1;
        default: // Don't care
          state_fft_unisim_fft_config_fft_next = 2'hX;
      endcase
    end
  fft_unisim_identity_sync_write_m_1024x64m32 A1_bridge0(.rtl_CE(
                                              A1_bridge0_rtl_CE_en), .rtl_A(
                                              A1_bridge0_rtl_a), .rtl_D(
                                              A1_bridge0_rtl_d), .rtl_WE(
                                              A1_bridge0_rtl_CE_en), .rtl_WEM(
                                              A1_bridge0_rtl_wem), .CLK(clk), .mem_CE(
                                              A1_CE0), .mem_A(A1_A0), .mem_D(
                                              A1_D0), .mem_WE(A1_WE0), .mem_WEM(
                                              A1_WEM0));
  fft_unisim_identity_sync_write_m_1024x64m32 A0_bridge0(.rtl_CE(
                                              A0_bridge0_rtl_CE_en), .rtl_A(
                                              A0_bridge0_rtl_a), .rtl_D(
                                              A0_bridge0_rtl_d), .rtl_WE(
                                              A0_bridge0_rtl_CE_en), .rtl_WEM(
                                              A0_bridge0_rtl_wem), .CLK(clk), .mem_CE(
                                              A0_CE0), .mem_A(A0_A0), .mem_D(
                                              A0_D0), .mem_WE(A0_WE0), .mem_WEM(
                                              A0_WEM0));
  // synthesis sync_set_reset_local fft_unisim_fft_load_input_seq_block rst
  always @(posedge clk) // fft_unisim_fft_load_input_sequential
    begin : fft_unisim_fft_load_input_seq_block
      if (!rst) // Initialize state and outputs
      begin
        mux_index_ln123_q <= 32'sh0;
        mux_s_ln123_q <= 32'sh0;
        add_ln180_1_q <= 10'sh0;
        mux_i_0_ln180_q <= 10'sh0;
        add_ln228_1_q <= 9'sh0;
        mux_i_1_ln228_q <= 9'sh0;
        add_ln260_1_q <= 10'sh0;
        mux_i_2_ln260_q <= 10'sh0;
        input_ready <= 1'sb0;
        add_ln143_1_q <= 10'sh0;
        mux_i_ln143_q <= 10'sh0;
        add_ln250_q <= 32'sh0;
        unary_or_ln231_Z_0_tag_0 <= 1'sb0;
        rd_length <= 32'sh0;
        rd_index <= 32'sh0;
        rd_request <= 1'sb0;
        mux_base_ln123_q <= 32'sh0;
        mux_s_ln203_q <= 32'sh0;
        mux_index_ln203_q <= 32'sh0;
        mux_ping_ln123_q <= 8'sh0;
        read_fft_len_ln119_q <= 32'sh0;
        read_fft_log_len_ln120_q <= 32'sh0;
        le_ln128_q <= 1'sb0;
        unary_or_ln183_Z_0_tag_0 <= 1'sb0;
        bufdin_set_ready_curr <= 1'sb0;
        mux_s_ln288_q <= 32'sh0;
        mux_index_ln288_q <= 32'sh0;
        mux_base_ln288_q <= 32'sh0;
        state_fft_unisim_fft_load_input <= 28'h1;
      end
      else // Update Q values
      begin
        mux_index_ln123_q <= mux_index_ln123_z;
        mux_s_ln123_q <= mux_s_ln123_z;
        add_ln180_1_q <= mux_i_0_ln180_d[10:1];
        mux_i_0_ln180_q <= {mux_i_0_ln180_1_d_0, mux_i_0_ln180_d[0]};
        add_ln228_1_q <= mux_i_1_ln228_d[9:1];
        mux_i_1_ln228_q <= {mux_i_1_ln228_1_d_0, mux_i_1_ln228_d[0]};
        add_ln260_1_q <= mux_i_2_ln260_d[10:1];
        mux_i_2_ln260_q <= {mux_i_2_ln260_1_d_0, mux_i_2_ln260_d[0]};
        input_ready <= input_ready_d;
        add_ln143_1_q <= mux_i_ln143_d[10:1];
        mux_i_ln143_q <= {mux_i_ln143_1_d_0, mux_i_ln143_d[0]};
        add_ln250_q <= add_ln250_d;
        unary_or_ln231_Z_0_tag_0 <= unary_or_ln231_Z_0_tag_d;
        rd_length <= rd_length_d;
        rd_index <= rd_index_d;
        rd_request <= rd_request_d;
        mux_base_ln123_q <= mux_base_ln123_d;
        mux_s_ln203_q <= mux_index_ln203_d[63:32];
        mux_index_ln203_q <= mux_index_ln203_d[31:0];
        mux_ping_ln123_q <= mux_ping_ln123_d;
        read_fft_len_ln119_q <= {read_fft_len_ln119_31_d, read_fft_len_ln119_d[
        30:0]};
        read_fft_log_len_ln120_q <= read_fft_len_ln119_d[62:31];
        le_ln128_q <= read_fft_len_ln119_d[63];
        unary_or_ln183_Z_0_tag_0 <= unary_or_ln183_Z_0_tag_d;
        bufdin_set_ready_curr <= bufdin_set_ready_curr_d;
        mux_s_ln288_q <= mux_index_ln288_d[63:32];
        mux_index_ln288_q <= mux_index_ln288_d[31:0];
        mux_base_ln288_q <= mux_base_ln288_d;
        state_fft_unisim_fft_load_input <= state_fft_unisim_fft_load_input_next;
      end
    end
  always @(*) begin : fft_unisim_fft_load_input_combinational
      reg FLEX_GET_END_3_or_0;
      reg ctrlOr_ln300_4_z;
      reg FLEX_GET_END_5_or_0;
      reg ctrlOr_ln300_6_z;
      reg FLEX_GET_END_1_or_0;
      reg ctrlOr_ln300_2_z;
      reg FLEX_GET_END_or_0;
      reg ctrlOr_ln300_0_z;
      reg unary_nor_ln98_z;
      reg unary_nor_ln98_0_z;
      reg unary_nor_ln98_1_z;
      reg unary_nor_ln98_2_z;
      reg unary_nor_ln98_3_z;
      reg unary_nor_ln98_4_z;
      reg unary_nor_ln98_5_z;
      reg unary_nor_ln98_6_z;
      reg ctrlAnd_1_ln180_z;
      reg ctrlAnd_1_ln228_z;
      reg ctrlAnd_1_ln260_z;
      reg le_ln128_z;
      reg [31:0] mux_base_ln125_z;
      reg [31:0] mux_index_ln125_z;
      reg [31:0] mux_s_ln125_z;
      reg mux_i_1_ln228_sel_0;
      reg mux_i_2_ln260_sel_0;
      reg A1_bridge0_rtl_wem_sel;
      reg A1_bridge0_rtl_wem_sel_0;
      reg mux_i_0_ln180_sel_0;
      reg A0_bridge0_rtl_wem_sel;
      reg A0_bridge0_rtl_wem_sel_0;
      reg mux_i_ln143_sel_0;
      reg ctrlAnd_0_ln180_z;
      reg ctrlAnd_0_ln228_z;
      reg ctrlAnd_0_ln260_z;
      reg ctrlAnd_1_ln109_z;
      reg ctrlAnd_0_ln109_z;
      reg ctrlAnd_1_ln139_z;
      reg ctrlAnd_0_ln139_z;
      reg ctrlAnd_1_ln159_z;
      reg ctrlAnd_0_ln159_z;
      reg ctrlAnd_1_ln176_z;
      reg ctrlAnd_0_ln176_z;
      reg ctrlAnd_1_ln209_z;
      reg ctrlAnd_0_ln209_z;
      reg ctrlAnd_1_ln212_z;
      reg ctrlAnd_0_ln212_z;
      reg ctrlAnd_1_ln224_z;
      reg ctrlAnd_0_ln224_z;
      reg ctrlAnd_1_ln256_z;
      reg ctrlAnd_0_ln256_z;
      reg ctrlAnd_1_ln295_z;
      reg ctrlAnd_0_ln295_z;
      reg ctrlAnd_1_ln298_z;
      reg ctrlAnd_0_ln298_z;
      reg [31:0] mux_read_fft_len_ln119_Z_v;
      reg [31:0] mux_read_fft_log_len_ln120_Z_v;
      reg mux_le_ln128_Z_0_v;
      reg if_ln128_z;
      reg [31:0] mux_base_ln123_z;
      reg [9:0] mux_i_0_ln180_z;
      reg [8:0] mux_i_1_ln228_z;
      reg [9:0] mux_i_2_ln260_z;
      reg [10:0] mux_i_ln143_z;
      reg [7:0] mux_ping_ln123_z;
      reg ctrlOr_ln143_0_z;
      reg ctrlOr_ln162_z;
      reg ctrlOr_ln180_z;
      reg ctrlOr_ln209_z;
      reg ctrlOr_ln212_z;
      reg ctrlOr_ln228_z;
      reg rd_request_sel_0;
      reg ctrlOr_ln260_z;
      reg ctrlOr_ln256_z;
      reg input_ready_sel_0;
      reg ctrlOr_ln295_z;
      reg ctrlOr_ln125_z;
      reg ctrlOr_ln298_z;
      reg [31:0] mux_read_fft_len_ln119_Z_0_mux_0_v;
      reg [31:0] mux_read_fft_len_ln119_Z_0_mux_1_v;
      reg mux_read_fft_len_ln119_Z_31_v_2;
      reg [31:0] mux_read_fft_log_len_ln120_Z_0_mux_0_v;
      reg [31:0] mux_read_fft_log_len_ln120_Z_0_mux_1_v;
      reg [31:0] mux_item_ln304_z;
      reg [31:0] mux_item_ln304_0_z;
      reg [31:0] mux_item_ln304_1_z;
      reg [31:0] mux_item_ln304_2_z;
      reg [31:0] mux_item_ln304_3_z;
      reg [31:0] mux_item_ln304_4_z;
      reg [31:0] mux_item_ln304_5_z;
      reg [31:0] mux_item_ln304_6_z;
      reg mux_le_ln128_Z_0_v_0;
      reg mux_le_ln128_Z_0_v_1;
      reg mux_if_ln128_Z_0_v;
      reg [31:0] mux_mux_base_ln123_Z_v;
      reg [9:0] mux_mux_i_0_ln180_Z_v;
      reg [10:0] add_ln180_z;
      reg [8:0] mux_mux_i_1_ln228_Z_v;
      reg [9:0] add_ln228_z;
      reg [9:0] mux_mux_i_2_ln260_Z_v;
      reg [10:0] add_ln260_z;
      reg eq_ln144_z;
      reg lt_ln143_z;
      reg [9:0] mux_mux_i_ln143_Z_v;
      reg [10:0] add_ln143_z;
      reg [20:0] add_ln202_z;
      reg [7:0] mux_mux_ping_ln123_Z_v;
      reg [7:0] unary_not_ln302_z;
      reg unary_or_ln183_z;
      reg unary_or_ln231_z;
      reg [7:0] mux_mux_ping_ln123_Z_0_mux_0_v;
      reg [31:0] add_ln289_z;
      reg gt_ln125_z;
      reg le_ln167_z;
      reg signed [31:0] lsh_ln283_z;
      reg [31:0] lsh_ln217_z;
      reg [31:0] add_ln204_z;
      reg ctrlOr_ln300_1_z;
      reg ctrlOr_ln300_3_z;
      reg ctrlOr_ln300_5_z;
      reg ctrlOr_ln123_z;
      reg ctrlAnd_1_ln300_0_z;
      reg ctrlAnd_0_ln300_0_z;
      reg ctrlAnd_1_ln300_2_z;
      reg ctrlAnd_0_ln300_2_z;
      reg ctrlAnd_1_ln300_4_z;
      reg ctrlAnd_0_ln300_4_z;
      reg ctrlAnd_1_ln300_6_z;
      reg ctrlAnd_0_ln300_6_z;
      reg [9:0] mux_add_ln180_Z_1_v_0;
      reg [8:0] mux_add_ln228_Z_1_v_0;
      reg [9:0] mux_add_ln260_Z_1_v_0;
      reg or_and_0_ln144_Z_0_z;
      reg if_ln144_z;
      reg [9:0] mux_add_ln143_Z_1_v_0;
      reg eq_ln203_z;
      reg mux_unary_or_ln183_Z_0_v;
      reg mux_unary_or_ln231_Z_0_v;
      reg if_ln167_z;
      reg [31:0] add_ln283_z;
      reg [31:0] add_ln250_z;
      reg ctrlAnd_1_ln300_1_z;
      reg mux_base_ln123_sel;
      reg mux_i_0_ln180_sel;
      reg unary_or_ln183_Z_0_tag_sel;
      reg ctrlAnd_0_ln300_1_z;
      reg ctrlAnd_0_ln300_3_z;
      reg ctrlAnd_1_ln300_3_z;
      reg mux_i_1_ln228_sel;
      reg add_ln250_sel;
      reg ctrlAnd_1_ln300_5_z;
      reg mux_i_2_ln260_sel;
      reg mux_index_ln288_sel;
      reg read_fft_len_ln119_sel;
      reg unary_or_ln231_Z_0_tag_sel;
      reg ctrlAnd_0_ln300_5_z;
      reg memwrite_fft_A0_ln191_en;
      reg memwrite_fft_A1_ln193_en;
      reg memwrite_fft_A0_ln239_en;
      reg memwrite_fft_A1_ln241_en;
      reg memwrite_fft_A0_ln271_en;
      reg memwrite_fft_A1_ln273_en;
      reg ctrlAnd_0_ln144_z;
      reg and_1_ln144_z;
      reg [31:0] mux_s_ln203_z;
      reg [31:0] mux_index_ln203_z;
      reg and_1_ln128_z;
      reg ctrlAnd_0_ln125_z;
      reg and_0_ln128_z;
      reg [31:0] mux_add_ln250_Z_v;
      reg [21:0] add_ln282_z;
      reg memwrite_fft_A0_ln184_en;
      reg memwrite_fft_A1_ln186_en;
      reg memwrite_fft_A0_ln232_en;
      reg memwrite_fft_A1_ln234_en;
      reg memwrite_fft_A0_ln264_en;
      reg memwrite_fft_A1_ln266_en;
      reg input_ready_hold;
      reg input_ready_sel;
      reg ctrlOr_ln159_z;
      reg ctrlAnd_1_ln144_z;
      reg [31:0] mux_mux_index_ln203_Z_v;
      reg [31:0] mux_mux_s_ln203_Z_v;
      reg and_1_ln167_z;
      reg and_0_ln167_z;
      reg ctrlAnd_0_ln128_z;
      reg [31:0] sub_ln286_z;
      reg eq_ln283_z;
      reg ctrlOr_ln300_z;
      reg ctrlAnd_1_ln167_z;
      reg ctrlAnd_0_ln167_z;
      reg ctrlOr_ln139_z;
      reg ctrlAnd_1_ln300_z;
      reg mux_i_ln143_sel;
      reg read_fft_len_ln119_31_sel;
      reg ctrlAnd_0_ln300_z;
      reg rd_length_sel;
      reg ctrlOr_ln224_z;
      reg rd_index_hold;
      reg rd_index_sel;
      reg rd_request_hold;
      reg rd_request_sel;
      reg ctrlOr_ln176_z;
      reg [31:0] mux_index_ln283_z;
      reg bufdin_set_ready_curr_hold;
      reg eq_ln288_z;
      reg [31:0] mux_index_ln288_z;
      reg [31:0] mux_s_ln288_z;
      reg [2:0] case_mux_base_ln288_z;
      reg [31:0] mux_mux_s_ln288_Z_v;
      reg [31:0] mux_mux_index_ln288_Z_v;
      reg [31:0] mux_base_ln288_z;
      reg [31:0] mux_mux_base_ln288_Z_v;

      state_fft_unisim_fft_load_input_next = 28'h0;
      FLEX_GET_END_3_or_0 = state_fft_unisim_fft_load_input[17] | 
      state_fft_unisim_fft_load_input[20] | state_fft_unisim_fft_load_input[16];
      ctrlOr_ln300_4_z = state_fft_unisim_fft_load_input[19] | 
      state_fft_unisim_fft_load_input[18];
      FLEX_GET_END_5_or_0 = state_fft_unisim_fft_load_input[22] | 
      state_fft_unisim_fft_load_input[25] | state_fft_unisim_fft_load_input[21];
      ctrlOr_ln300_6_z = state_fft_unisim_fft_load_input[24] | 
      state_fft_unisim_fft_load_input[23];
      FLEX_GET_END_1_or_0 = state_fft_unisim_fft_load_input[10] | 
      state_fft_unisim_fft_load_input[13] | state_fft_unisim_fft_load_input[9];
      ctrlOr_ln300_2_z = state_fft_unisim_fft_load_input[12] | 
      state_fft_unisim_fft_load_input[11];
      FLEX_GET_END_or_0 = state_fft_unisim_fft_load_input[5] | 
      state_fft_unisim_fft_load_input[8] | state_fft_unisim_fft_load_input[2];
      ctrlOr_ln300_0_z = state_fft_unisim_fft_load_input[7] | 
      state_fft_unisim_fft_load_input[6];
      unary_nor_ln98_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_0_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_1_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_2_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_3_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_4_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_5_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_6_z = ~bufdin_set_ready_curr;
      ctrlAnd_1_ln180_z = add_ln180_1_q[9] & state_fft_unisim_fft_load_input[13];
      ctrlAnd_1_ln228_z = add_ln228_1_q[8] & state_fft_unisim_fft_load_input[20];
      ctrlAnd_1_ln260_z = add_ln260_1_q[9] & state_fft_unisim_fft_load_input[25];
      le_ln128_z = log_len <= 32'ha;
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_load_input[1]: mux_base_ln125_z = mux_base_ln123_q;
        state_fft_unisim_fft_load_input[15]: mux_base_ln125_z = mux_base_ln123_q;
        state_fft_unisim_fft_load_input[27]: mux_base_ln125_z = mux_base_ln288_q;
        default: mux_base_ln125_z = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_load_input[1]: mux_index_ln125_z = 
          mux_index_ln123_q;
        state_fft_unisim_fft_load_input[15]: mux_index_ln125_z = 
          mux_index_ln203_q;
        state_fft_unisim_fft_load_input[27]: mux_index_ln125_z = 
          mux_index_ln288_q;
        default: mux_index_ln125_z = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_load_input[1]: mux_s_ln125_z = mux_s_ln123_q;
        state_fft_unisim_fft_load_input[15]: mux_s_ln125_z = mux_s_ln203_q;
        state_fft_unisim_fft_load_input[27]: mux_s_ln125_z = mux_s_ln288_q;
        default: mux_s_ln125_z = 32'hX;
      endcase
      mux_i_1_ln228_sel_0 = ctrlOr_ln300_4_z;
      mux_i_2_ln260_sel_0 = ctrlOr_ln300_6_z;
      A1_bridge0_rtl_wem_sel = FLEX_GET_END_5_or_0 | FLEX_GET_END_3_or_0 | 
      FLEX_GET_END_1_or_0;
      A1_bridge0_rtl_wem_sel_0 = ctrlOr_ln300_6_z | ctrlOr_ln300_4_z | 
      ctrlOr_ln300_2_z;
      mux_i_0_ln180_sel_0 = ctrlOr_ln300_2_z;
      A0_bridge0_rtl_wem_sel = FLEX_GET_END_or_0 | FLEX_GET_END_5_or_0 | 
      FLEX_GET_END_3_or_0 | FLEX_GET_END_1_or_0;
      A0_bridge0_rtl_wem_sel_0 = ctrlOr_ln300_6_z | ctrlOr_ln300_4_z | 
      ctrlOr_ln300_2_z | ctrlOr_ln300_0_z;
      mux_i_ln143_sel_0 = ctrlOr_ln300_0_z;
      ctrlAnd_0_ln180_z = !add_ln180_1_q[9] & 
      state_fft_unisim_fft_load_input[13];
      ctrlAnd_0_ln228_z = !add_ln228_1_q[8] & 
      state_fft_unisim_fft_load_input[20];
      ctrlAnd_0_ln260_z = !add_ln260_1_q[9] & 
      state_fft_unisim_fft_load_input[25];
      ctrlAnd_1_ln109_z = init_done & state_fft_unisim_fft_load_input[0];
      ctrlAnd_0_ln109_z = !init_done & state_fft_unisim_fft_load_input[0];
      ctrlAnd_1_ln139_z = rd_grant & state_fft_unisim_fft_load_input[2];
      ctrlAnd_0_ln139_z = !rd_grant & state_fft_unisim_fft_load_input[2];
      ctrlAnd_1_ln159_z = loop_start & state_fft_unisim_fft_load_input[3];
      ctrlAnd_0_ln159_z = !loop_start & state_fft_unisim_fft_load_input[3];
      ctrlAnd_1_ln176_z = rd_grant & state_fft_unisim_fft_load_input[9];
      ctrlAnd_0_ln176_z = !rd_grant & state_fft_unisim_fft_load_input[9];
      ctrlAnd_1_ln209_z = loop_start & state_fft_unisim_fft_load_input[14];
      ctrlAnd_0_ln209_z = !loop_start & state_fft_unisim_fft_load_input[14];
      ctrlAnd_1_ln212_z = !loop_start & state_fft_unisim_fft_load_input[15];
      ctrlAnd_0_ln212_z = loop_start & state_fft_unisim_fft_load_input[15];
      ctrlAnd_1_ln224_z = rd_grant & state_fft_unisim_fft_load_input[16];
      ctrlAnd_0_ln224_z = !rd_grant & state_fft_unisim_fft_load_input[16];
      ctrlAnd_1_ln256_z = rd_grant & state_fft_unisim_fft_load_input[21];
      ctrlAnd_0_ln256_z = !rd_grant & state_fft_unisim_fft_load_input[21];
      ctrlAnd_1_ln295_z = loop_start & state_fft_unisim_fft_load_input[26];
      ctrlAnd_0_ln295_z = !loop_start & state_fft_unisim_fft_load_input[26];
      ctrlAnd_1_ln298_z = !loop_start & state_fft_unisim_fft_load_input[27];
      ctrlAnd_0_ln298_z = loop_start & state_fft_unisim_fft_load_input[27];
      if (state_fft_unisim_fft_load_input[0]) 
        mux_read_fft_len_ln119_Z_v = len;
      else 
        mux_read_fft_len_ln119_Z_v = read_fft_len_ln119_q;
      if (state_fft_unisim_fft_load_input[0]) 
        mux_read_fft_log_len_ln120_Z_v = log_len;
      else 
        mux_read_fft_log_len_ln120_Z_v = read_fft_log_len_ln120_q;
      if (state_fft_unisim_fft_load_input[0]) 
        mux_le_ln128_Z_0_v = le_ln128_z;
      else 
        mux_le_ln128_Z_0_v = le_ln128_q;
      if_ln128_z = ~le_ln128_z;
      if (state_fft_unisim_fft_load_input[0]) 
        mux_base_ln123_z = 32'h0;
      else 
        mux_base_ln123_z = mux_base_ln125_z;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_i_0_ln180_z = 10'h0;
      else 
        mux_i_0_ln180_z = {add_ln180_1_q[8:0], !mux_i_0_ln180_q[0]};
      if (state_fft_unisim_fft_load_input[16]) 
        mux_i_1_ln228_z = 9'h0;
      else 
        mux_i_1_ln228_z = {add_ln228_1_q[7:0], !mux_i_1_ln228_q[0]};
      if (state_fft_unisim_fft_load_input[21]) 
        mux_i_2_ln260_z = 10'h200;
      else 
        mux_i_2_ln260_z = {add_ln260_1_q[8:0], !mux_i_2_ln260_q[0]};
      if (state_fft_unisim_fft_load_input[2]) 
        mux_i_ln143_z = 11'h0;
      else 
        mux_i_ln143_z = {add_ln143_1_q, !mux_i_ln143_q[0]};
      if (state_fft_unisim_fft_load_input[0]) 
        mux_index_ln123_z = 32'h0;
      else 
        mux_index_ln123_z = mux_index_ln125_z;
      if (state_fft_unisim_fft_load_input[0]) 
        mux_ping_ln123_z = 8'hff;
      else 
        mux_ping_ln123_z = {!mux_ping_ln123_q[7], !mux_ping_ln123_q[6], !
        mux_ping_ln123_q[5], !mux_ping_ln123_q[4], !mux_ping_ln123_q[3], !
        mux_ping_ln123_q[2], !mux_ping_ln123_q[1], !mux_ping_ln123_q[0]};
      if (state_fft_unisim_fft_load_input[0]) 
        mux_s_ln123_z = 32'h1;
      else 
        mux_s_ln123_z = mux_s_ln125_z;
      case (1'b1)// synthesis parallel_case
        A1_bridge0_rtl_wem_sel: A1_bridge0_rtl_wem = 2'h1;
        A1_bridge0_rtl_wem_sel_0: A1_bridge0_rtl_wem = 2'h2;
        default: A1_bridge0_rtl_wem = 2'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        A0_bridge0_rtl_wem_sel: A0_bridge0_rtl_wem = 2'h1;
        A0_bridge0_rtl_wem_sel_0: A0_bridge0_rtl_wem = 2'h2;
        default: A0_bridge0_rtl_wem = 2'hX;
      endcase
      ctrlOr_ln143_0_z = state_fft_unisim_fft_load_input[8] | ctrlAnd_1_ln139_z;
      ctrlOr_ln162_z = state_fft_unisim_fft_load_input[4] | ctrlAnd_1_ln159_z;
      ctrlOr_ln180_z = ctrlAnd_0_ln180_z | ctrlAnd_1_ln176_z;
      ctrlOr_ln209_z = ctrlAnd_0_ln209_z | ctrlAnd_1_ln180_z;
      ctrlOr_ln212_z = ctrlAnd_0_ln212_z | ctrlAnd_1_ln209_z;
      ctrlOr_ln228_z = ctrlAnd_0_ln228_z | ctrlAnd_1_ln224_z;
      rd_request_sel_0 = ctrlAnd_1_ln256_z | ctrlAnd_1_ln224_z | 
      ctrlAnd_1_ln176_z | ctrlAnd_1_ln139_z;
      ctrlOr_ln260_z = ctrlAnd_0_ln260_z | ctrlAnd_1_ln256_z;
      ctrlOr_ln256_z = ctrlAnd_0_ln256_z | ctrlAnd_1_ln228_z;
      input_ready_sel_0 = ctrlAnd_1_ln295_z | ctrlAnd_1_ln209_z | 
      ctrlAnd_1_ln159_z;
      ctrlOr_ln295_z = ctrlAnd_0_ln295_z | ctrlAnd_1_ln260_z;
      ctrlOr_ln125_z = ctrlAnd_1_ln298_z | ctrlAnd_1_ln212_z | 
      state_fft_unisim_fft_load_input[1];
      ctrlOr_ln298_z = ctrlAnd_0_ln298_z | ctrlAnd_1_ln295_z;
      if (state_fft_unisim_fft_load_input[16]) 
        mux_read_fft_len_ln119_Z_0_mux_0_v = read_fft_len_ln119_q;
      else 
        mux_read_fft_len_ln119_Z_0_mux_0_v = mux_read_fft_len_ln119_Z_v;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_read_fft_len_ln119_Z_0_mux_1_v = read_fft_len_ln119_q;
      else 
        mux_read_fft_len_ln119_Z_0_mux_1_v = mux_read_fft_len_ln119_Z_v;
      if (state_fft_unisim_fft_load_input[2]) 
        mux_read_fft_len_ln119_Z_31_v_2 = read_fft_len_ln119_q[31];
      else 
        mux_read_fft_len_ln119_Z_31_v_2 = mux_read_fft_len_ln119_Z_v[31];
      if (state_fft_unisim_fft_load_input[16]) 
        mux_read_fft_log_len_ln120_Z_0_mux_0_v = read_fft_log_len_ln120_q;
      else 
        mux_read_fft_log_len_ln120_Z_0_mux_0_v = mux_read_fft_log_len_ln120_Z_v;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_read_fft_log_len_ln120_Z_0_mux_1_v = read_fft_log_len_ln120_q;
      else 
        mux_read_fft_log_len_ln120_Z_0_mux_1_v = mux_read_fft_log_len_ln120_Z_v;
      if (bufdin_ready) 
        mux_item_ln304_z = bufdin_data;
      else 
        mux_item_ln304_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_0_z = bufdin_data;
      else 
        mux_item_ln304_0_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_1_z = bufdin_data;
      else 
        mux_item_ln304_1_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_2_z = bufdin_data;
      else 
        mux_item_ln304_2_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_3_z = bufdin_data;
      else 
        mux_item_ln304_3_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_4_z = bufdin_data;
      else 
        mux_item_ln304_4_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_5_z = bufdin_data;
      else 
        mux_item_ln304_5_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_6_z = bufdin_data;
      else 
        mux_item_ln304_6_z = bufdin_data_buf;
      if (state_fft_unisim_fft_load_input[16]) 
        mux_le_ln128_Z_0_v_0 = le_ln128_q;
      else 
        mux_le_ln128_Z_0_v_0 = mux_le_ln128_Z_0_v;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_le_ln128_Z_0_v_1 = le_ln128_q;
      else 
        mux_le_ln128_Z_0_v_1 = mux_le_ln128_Z_0_v;
      if (state_fft_unisim_fft_load_input[0]) 
        mux_if_ln128_Z_0_v = if_ln128_z;
      else 
        mux_if_ln128_Z_0_v = !le_ln128_q;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_mux_base_ln123_Z_v = mux_base_ln123_q;
      else 
        mux_mux_base_ln123_Z_v = mux_base_ln123_z;
      if (state_fft_unisim_fft_load_input[10]) 
        mux_mux_i_0_ln180_Z_v = mux_i_0_ln180_q;
      else 
        mux_mux_i_0_ln180_Z_v = mux_i_0_ln180_z;
      add_ln180_z = {1'b0, mux_i_0_ln180_z} + 11'h1;
      if (state_fft_unisim_fft_load_input[17]) 
        mux_mux_i_1_ln228_Z_v = mux_i_1_ln228_q;
      else 
        mux_mux_i_1_ln228_Z_v = mux_i_1_ln228_z;
      add_ln228_z = {1'b0, mux_i_1_ln228_z} + 10'h1;
      if (state_fft_unisim_fft_load_input[22]) 
        mux_mux_i_2_ln260_Z_v = mux_i_2_ln260_q;
      else 
        mux_mux_i_2_ln260_Z_v = mux_i_2_ln260_z;
      add_ln260_z = {1'b0, mux_i_2_ln260_z} + 11'h1;
      eq_ln144_z = {21'h0, mux_i_ln143_z} == {read_fft_len_ln119_q[31], 
      rd_length[31:1]};
      lt_ln143_z = ~mux_i_ln143_z[10];
      if (state_fft_unisim_fft_load_input[5]) 
        mux_mux_i_ln143_Z_v = mux_i_ln143_q;
      else 
        mux_mux_i_ln143_Z_v = mux_i_ln143_z[9:0];
      add_ln143_z = {1'b0, mux_i_ln143_z[9:0]} + 11'h1;
      add_ln202_z = mux_index_ln123_z[31:11] + 21'h1;
      if (state_fft_unisim_fft_load_input[16]) 
        mux_mux_ping_ln123_Z_v = mux_ping_ln123_q;
      else 
        mux_mux_ping_ln123_Z_v = mux_ping_ln123_z;
      unary_not_ln302_z = ~mux_ping_ln123_z;
      unary_or_ln183_z = |mux_ping_ln123_z;
      unary_or_ln231_z = |mux_ping_ln123_z;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_mux_ping_ln123_Z_0_mux_0_v = mux_ping_ln123_q;
      else 
        mux_mux_ping_ln123_Z_0_mux_0_v = mux_ping_ln123_z;
      add_ln289_z = mux_s_ln123_z + 32'h1;
      gt_ln125_z = {1'b0, mux_s_ln123_z} > {1'b0, mux_read_fft_log_len_ln120_Z_v};
      le_ln167_z = mux_s_ln123_z <= 32'ha;
      lsh_ln283_z = 3'sh2 << mux_s_ln123_z[4:0];
      case (mux_s_ln123_z[4:0])
        5'h0: lsh_ln217_z = 32'h1;
        5'h1: lsh_ln217_z = 32'h2;
        5'h2: lsh_ln217_z = 32'h4;
        5'h3: lsh_ln217_z = 32'h8;
        5'h4: lsh_ln217_z = 32'h10;
        5'h5: lsh_ln217_z = 32'h20;
        5'h6: lsh_ln217_z = 32'h40;
        5'h7: lsh_ln217_z = 32'h80;
        5'h8: lsh_ln217_z = 32'h100;
        5'h9: lsh_ln217_z = 32'h200;
        5'ha: lsh_ln217_z = 32'h400;
        5'hb: lsh_ln217_z = 32'h800;
        5'hc: lsh_ln217_z = 32'h1000;
        5'hd: lsh_ln217_z = 32'h2000;
        5'he: lsh_ln217_z = 32'h4000;
        5'hf: lsh_ln217_z = 32'h8000;
        5'h10: lsh_ln217_z = 32'h10000;
        5'h11: lsh_ln217_z = 32'h20000;
        5'h12: lsh_ln217_z = 32'h40000;
        5'h13: lsh_ln217_z = 32'h80000;
        5'h14: lsh_ln217_z = 32'h100000;
        5'h15: lsh_ln217_z = 32'h200000;
        5'h16: lsh_ln217_z = 32'h400000;
        5'h17: lsh_ln217_z = 32'h800000;
        5'h18: lsh_ln217_z = 32'h1000000;
        5'h19: lsh_ln217_z = 32'h2000000;
        5'h1a: lsh_ln217_z = 32'h4000000;
        5'h1b: lsh_ln217_z = 32'h8000000;
        5'h1c: lsh_ln217_z = 32'h10000000;
        5'h1d: lsh_ln217_z = 32'h20000000;
        5'h1e: lsh_ln217_z = 32'h40000000;
        5'h1f: lsh_ln217_z = 32'h80000000;
        default: lsh_ln217_z = 32'h0;
      endcase
      add_ln204_z = mux_s_ln123_z + 32'h1;
      ctrlOr_ln300_1_z = state_fft_unisim_fft_load_input[10] | ctrlOr_ln180_z;
      ctrlOr_ln300_3_z = state_fft_unisim_fft_load_input[17] | ctrlOr_ln228_z;
      ctrlOr_ln300_5_z = state_fft_unisim_fft_load_input[22] | ctrlOr_ln260_z;
      ctrlOr_ln123_z = ctrlOr_ln125_z | ctrlAnd_1_ln109_z;
      case (1'b1)// synthesis parallel_case
        FLEX_GET_END_3_or_0: A1_bridge0_rtl_d = {32'h0, mux_item_ln304_3_z};
        ctrlOr_ln300_4_z: A1_bridge0_rtl_d = {mux_item_ln304_4_z, 32'h0};
        FLEX_GET_END_5_or_0: A1_bridge0_rtl_d = {32'h0, mux_item_ln304_5_z};
        ctrlOr_ln300_6_z: A1_bridge0_rtl_d = {mux_item_ln304_6_z, 32'h0};
        FLEX_GET_END_1_or_0: A1_bridge0_rtl_d = {32'h0, mux_item_ln304_1_z};
        ctrlOr_ln300_2_z: A1_bridge0_rtl_d = {mux_item_ln304_2_z, 32'h0};
        default: A1_bridge0_rtl_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        FLEX_GET_END_3_or_0: A0_bridge0_rtl_d = {32'h0, mux_item_ln304_3_z};
        ctrlOr_ln300_4_z: A0_bridge0_rtl_d = {mux_item_ln304_4_z, 32'h0};
        FLEX_GET_END_5_or_0: A0_bridge0_rtl_d = {32'h0, mux_item_ln304_5_z};
        ctrlOr_ln300_6_z: A0_bridge0_rtl_d = {mux_item_ln304_6_z, 32'h0};
        FLEX_GET_END_1_or_0: A0_bridge0_rtl_d = {32'h0, mux_item_ln304_1_z};
        ctrlOr_ln300_2_z: A0_bridge0_rtl_d = {mux_item_ln304_2_z, 32'h0};
        FLEX_GET_END_or_0: A0_bridge0_rtl_d = {32'h0, mux_item_ln304_z};
        ctrlOr_ln300_0_z: A0_bridge0_rtl_d = {mux_item_ln304_0_z, 32'h0};
        default: A0_bridge0_rtl_d = 64'hX;
      endcase
      ctrlAnd_1_ln300_0_z = bufdin_can_get_sig & ctrlOr_ln300_0_z;
      ctrlAnd_0_ln300_0_z = !bufdin_can_get_sig & ctrlOr_ln300_0_z;
      ctrlAnd_1_ln300_2_z = bufdin_can_get_sig & ctrlOr_ln300_2_z;
      ctrlAnd_0_ln300_2_z = !bufdin_can_get_sig & ctrlOr_ln300_2_z;
      ctrlAnd_1_ln300_4_z = bufdin_can_get_sig & ctrlOr_ln300_4_z;
      ctrlAnd_0_ln300_4_z = !bufdin_can_get_sig & ctrlOr_ln300_4_z;
      ctrlAnd_1_ln300_6_z = bufdin_can_get_sig & ctrlOr_ln300_6_z;
      ctrlAnd_0_ln300_6_z = !bufdin_can_get_sig & ctrlOr_ln300_6_z;
      if (state_fft_unisim_fft_load_input[10]) 
        mux_add_ln180_Z_1_v_0 = add_ln180_1_q;
      else 
        mux_add_ln180_Z_1_v_0 = add_ln180_z[10:1];
      if (state_fft_unisim_fft_load_input[17]) 
        mux_add_ln228_Z_1_v_0 = add_ln228_1_q;
      else 
        mux_add_ln228_Z_1_v_0 = add_ln228_z[9:1];
      case (1'b1)// synthesis parallel_case
        FLEX_GET_END_3_or_0: A1_bridge0_rtl_a = {1'b0, mux_mux_i_1_ln228_Z_v};
        ctrlOr_ln300_4_z: A1_bridge0_rtl_a = {1'b0, mux_i_1_ln228_q};
        FLEX_GET_END_5_or_0: A1_bridge0_rtl_a = mux_mux_i_2_ln260_Z_v;
        ctrlOr_ln300_6_z: A1_bridge0_rtl_a = mux_i_2_ln260_q;
        FLEX_GET_END_1_or_0: A1_bridge0_rtl_a = mux_mux_i_0_ln180_Z_v;
        ctrlOr_ln300_2_z: A1_bridge0_rtl_a = mux_i_0_ln180_q;
        default: A1_bridge0_rtl_a = 10'hX;
      endcase
      if (state_fft_unisim_fft_load_input[22]) 
        mux_add_ln260_Z_1_v_0 = add_ln260_1_q;
      else 
        mux_add_ln260_Z_1_v_0 = add_ln260_z[10:1];
      or_and_0_ln144_Z_0_z = mux_i_ln143_z[10] | eq_ln144_z;
      if_ln144_z = ~eq_ln144_z;
      case (1'b1)// synthesis parallel_case
        FLEX_GET_END_3_or_0: A0_bridge0_rtl_a = {1'b0, mux_mux_i_1_ln228_Z_v};
        ctrlOr_ln300_4_z: A0_bridge0_rtl_a = {1'b0, mux_i_1_ln228_q};
        FLEX_GET_END_5_or_0: A0_bridge0_rtl_a = mux_mux_i_2_ln260_Z_v;
        ctrlOr_ln300_6_z: A0_bridge0_rtl_a = mux_i_2_ln260_q;
        FLEX_GET_END_1_or_0: A0_bridge0_rtl_a = mux_mux_i_0_ln180_Z_v;
        ctrlOr_ln300_2_z: A0_bridge0_rtl_a = mux_i_0_ln180_q;
        FLEX_GET_END_or_0: A0_bridge0_rtl_a = mux_mux_i_ln143_Z_v;
        ctrlOr_ln300_0_z: A0_bridge0_rtl_a = mux_i_ln143_q;
        default: A0_bridge0_rtl_a = 10'hX;
      endcase
      if (state_fft_unisim_fft_load_input[5]) 
        mux_add_ln143_Z_1_v_0 = add_ln143_1_q;
      else 
        mux_add_ln143_Z_1_v_0 = add_ln143_z[10:1];
      eq_ln203_z = {add_ln202_z, mux_index_ln123_z[10:0]} == {
      mux_read_fft_len_ln119_Z_v[30:0], 1'b0};
      if (state_fft_unisim_fft_load_input[9]) 
        mux_unary_or_ln183_Z_0_v = unary_or_ln183_Z_0_tag_0;
      else 
        mux_unary_or_ln183_Z_0_v = unary_or_ln183_z;
      if (state_fft_unisim_fft_load_input[16]) 
        mux_unary_or_ln231_Z_0_v = unary_or_ln231_Z_0_tag_0;
      else 
        mux_unary_or_ln231_Z_0_v = unary_or_ln231_z;
      if_ln167_z = ~le_ln167_z;
      add_ln283_z = mux_base_ln123_z + $unsigned(lsh_ln283_z);
      add_ln250_z = mux_index_ln123_z + lsh_ln217_z;
      ctrlAnd_1_ln300_1_z = bufdin_can_get_sig & ctrlOr_ln300_1_z;
      mux_base_ln123_sel = ctrlOr_ln300_2_z | ctrlOr_ln300_1_z | ctrlOr_ln212_z | 
      ctrlOr_ln209_z;
      mux_i_0_ln180_sel = ctrlOr_ln300_1_z;
      unary_or_ln183_Z_0_tag_sel = ctrlOr_ln300_2_z | ctrlOr_ln300_1_z;
      ctrlAnd_0_ln300_1_z = !bufdin_can_get_sig & ctrlOr_ln300_1_z;
      ctrlAnd_0_ln300_3_z = !bufdin_can_get_sig & ctrlOr_ln300_3_z;
      ctrlAnd_1_ln300_3_z = bufdin_can_get_sig & ctrlOr_ln300_3_z;
      mux_i_1_ln228_sel = ctrlOr_ln300_3_z;
      add_ln250_sel = ctrlOr_ln300_4_z | ctrlOr_ln300_3_z;
      ctrlAnd_1_ln300_5_z = bufdin_can_get_sig & ctrlOr_ln300_5_z;
      mux_i_2_ln260_sel = ctrlOr_ln300_5_z;
      mux_index_ln288_sel = ctrlOr_ln300_6_z | ctrlOr_ln300_5_z | 
      ctrlOr_ln300_4_z | ctrlOr_ln300_3_z | ctrlOr_ln298_z | ctrlOr_ln295_z | 
      ctrlOr_ln256_z;
      read_fft_len_ln119_sel = ctrlOr_ln300_6_z | ctrlOr_ln300_5_z | 
      ctrlOr_ln300_4_z | ctrlOr_ln300_3_z | ctrlOr_ln300_2_z | ctrlOr_ln300_1_z | 
      ctrlOr_ln298_z | ctrlOr_ln295_z | ctrlOr_ln256_z | ctrlOr_ln212_z | 
      ctrlOr_ln209_z;
      unary_or_ln231_Z_0_tag_sel = ctrlOr_ln300_6_z | ctrlOr_ln300_5_z | 
      ctrlOr_ln300_4_z | ctrlOr_ln300_3_z | ctrlOr_ln256_z;
      ctrlAnd_0_ln300_5_z = !bufdin_can_get_sig & ctrlOr_ln300_5_z;
      memwrite_fft_A0_ln191_en = unary_or_ln183_Z_0_tag_0 & ctrlAnd_1_ln300_2_z;
      memwrite_fft_A1_ln193_en = !unary_or_ln183_Z_0_tag_0 & ctrlAnd_1_ln300_2_z;
      memwrite_fft_A0_ln239_en = unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_4_z;
      memwrite_fft_A1_ln241_en = !unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_4_z;
      memwrite_fft_A0_ln271_en = unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_6_z;
      memwrite_fft_A1_ln273_en = !unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_6_z;
      ctrlAnd_0_ln144_z = or_and_0_ln144_Z_0_z & ctrlOr_ln143_0_z;
      and_1_ln144_z = if_ln144_z & lt_ln143_z;
      if (eq_ln203_z) begin
        mux_s_ln203_z = add_ln204_z;
        mux_index_ln203_z = 32'h0;
      end
      else begin
        mux_s_ln203_z = mux_s_ln123_z;
        mux_index_ln203_z = {add_ln202_z, mux_index_ln123_z[10:0]};
      end
      and_1_ln128_z = mux_if_ln128_Z_0_v & !gt_ln125_z;
      ctrlAnd_0_ln125_z = gt_ln125_z & ctrlOr_ln123_z;
      and_0_ln128_z = mux_le_ln128_Z_0_v & !gt_ln125_z;
      if (state_fft_unisim_fft_load_input[16]) 
        mux_add_ln250_Z_v = add_ln250_q;
      else 
        mux_add_ln250_Z_v = add_ln250_z;
      add_ln282_z = add_ln250_z[31:10] + 22'h1;
      memwrite_fft_A0_ln184_en = unary_or_ln183_Z_0_tag_0 & ctrlAnd_1_ln300_1_z;
      memwrite_fft_A1_ln186_en = !unary_or_ln183_Z_0_tag_0 & ctrlAnd_1_ln300_1_z;
      case (1'b1)// synthesis parallel_case
        mux_i_0_ln180_sel: mux_i_0_ln180_d = {mux_add_ln180_Z_1_v_0, 
          mux_mux_i_0_ln180_Z_v[0]};
        mux_i_0_ln180_sel_0: mux_i_0_ln180_d = {add_ln180_1_q, mux_i_0_ln180_q[0]};
        default: mux_i_0_ln180_d = 11'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_i_0_ln180_sel: mux_i_0_ln180_1_d_0 = mux_mux_i_0_ln180_Z_v[9:1];
        ctrlAnd_0_ln300_2_z: mux_i_0_ln180_1_d_0 = mux_i_0_ln180_q[9:1];
        default: mux_i_0_ln180_1_d_0 = 9'hX;
      endcase
      memwrite_fft_A0_ln232_en = unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_3_z;
      memwrite_fft_A1_ln234_en = !unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_3_z;
      case (1'b1)// synthesis parallel_case
        mux_i_1_ln228_sel: mux_i_1_ln228_d = {mux_add_ln228_Z_1_v_0, 
          mux_mux_i_1_ln228_Z_v[0]};
        mux_i_1_ln228_sel_0: mux_i_1_ln228_d = {add_ln228_1_q, mux_i_1_ln228_q[0]};
        default: mux_i_1_ln228_d = 10'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_i_1_ln228_sel: mux_i_1_ln228_1_d_0 = mux_mux_i_1_ln228_Z_v[8:1];
        ctrlAnd_0_ln300_4_z: mux_i_1_ln228_1_d_0 = mux_i_1_ln228_q[8:1];
        default: mux_i_1_ln228_1_d_0 = 8'hX;
      endcase
      memwrite_fft_A0_ln264_en = unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_5_z;
      memwrite_fft_A1_ln266_en = !unary_or_ln231_Z_0_tag_0 & ctrlAnd_1_ln300_5_z;
      case (1'b1)// synthesis parallel_case
        mux_i_2_ln260_sel: mux_i_2_ln260_d = {mux_add_ln260_Z_1_v_0, 
          mux_mux_i_2_ln260_Z_v[0]};
        mux_i_2_ln260_sel_0: mux_i_2_ln260_d = {add_ln260_1_q, mux_i_2_ln260_q[0]};
        default: mux_i_2_ln260_d = 11'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_i_2_ln260_sel: mux_i_2_ln260_1_d_0 = mux_mux_i_2_ln260_Z_v[9:1];
        ctrlAnd_0_ln300_6_z: mux_i_2_ln260_1_d_0 = mux_i_2_ln260_q[9:1];
        default: mux_i_2_ln260_1_d_0 = 9'hX;
      endcase
      input_ready_hold = ~(ctrlAnd_1_ln295_z | ctrlAnd_1_ln260_z | 
      ctrlAnd_1_ln209_z | ctrlAnd_1_ln180_z | ctrlAnd_1_ln159_z | 
      ctrlAnd_0_ln144_z);
      input_ready_sel = ctrlAnd_1_ln260_z | ctrlAnd_1_ln180_z | 
      ctrlAnd_0_ln144_z;
      ctrlOr_ln159_z = ctrlAnd_0_ln159_z | ctrlAnd_0_ln144_z;
      ctrlAnd_1_ln144_z = and_1_ln144_z & ctrlOr_ln143_0_z;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_mux_index_ln203_Z_v = mux_index_ln203_q;
      else 
        mux_mux_index_ln203_Z_v = mux_index_ln203_z;
      if (state_fft_unisim_fft_load_input[9]) 
        mux_mux_s_ln203_Z_v = mux_s_ln203_q;
      else 
        mux_mux_s_ln203_Z_v = mux_s_ln203_z;
      and_1_ln167_z = if_ln167_z & and_1_ln128_z;
      and_0_ln167_z = le_ln167_z & and_1_ln128_z;
      ctrlAnd_0_ln128_z = and_0_ln128_z & ctrlOr_ln123_z;
      sub_ln286_z = {add_ln282_z, add_ln250_z[9:0]} - lsh_ln217_z;
      eq_ln283_z = {add_ln282_z, add_ln250_z[9:0]} == add_ln283_z;
      A1_bridge0_rtl_CE_en = memwrite_fft_A1_ln273_en | memwrite_fft_A1_ln266_en | 
      memwrite_fft_A1_ln241_en | memwrite_fft_A1_ln234_en | 
      memwrite_fft_A1_ln193_en | memwrite_fft_A1_ln186_en;
      case (1'b1)// synthesis parallel_case
        input_ready_sel: input_ready_d = 1'b1;
        input_ready_sel_0: input_ready_d = 1'b0;
        input_ready_hold: input_ready_d = input_ready;
        default: input_ready_d = 1'bX;
      endcase
      ctrlOr_ln300_z = state_fft_unisim_fft_load_input[5] | ctrlAnd_1_ln144_z;
      ctrlAnd_1_ln167_z = and_1_ln167_z & ctrlOr_ln123_z;
      ctrlAnd_0_ln167_z = and_0_ln167_z & ctrlOr_ln123_z;
      ctrlOr_ln139_z = ctrlAnd_0_ln139_z | ctrlAnd_0_ln128_z;
      ctrlAnd_1_ln300_z = bufdin_can_get_sig & ctrlOr_ln300_z;
      mux_i_ln143_sel = ctrlOr_ln300_z;
      read_fft_len_ln119_31_sel = ctrlOr_ln300_z | ctrlOr_ln300_6_z | 
      ctrlOr_ln300_5_z | ctrlOr_ln300_4_z | ctrlOr_ln300_3_z | ctrlOr_ln300_2_z | 
      ctrlOr_ln300_1_z | ctrlOr_ln300_0_z | ctrlOr_ln298_z | ctrlOr_ln295_z | 
      ctrlOr_ln256_z | ctrlOr_ln212_z | ctrlOr_ln209_z;
      ctrlAnd_0_ln300_z = !bufdin_can_get_sig & ctrlOr_ln300_z;
      rd_length_sel = ctrlAnd_1_ln228_z | ctrlAnd_1_ln167_z;
      ctrlOr_ln224_z = ctrlAnd_0_ln224_z | ctrlAnd_1_ln167_z;
      rd_index_hold = ~(ctrlAnd_1_ln228_z | ctrlAnd_1_ln167_z | 
      ctrlAnd_0_ln167_z | ctrlAnd_0_ln128_z);
      rd_index_sel = ctrlAnd_1_ln167_z | ctrlAnd_0_ln167_z;
      rd_request_hold = ~(ctrlAnd_1_ln256_z | ctrlAnd_1_ln228_z | 
      ctrlAnd_1_ln224_z | ctrlAnd_1_ln176_z | ctrlAnd_1_ln167_z | 
      ctrlAnd_1_ln139_z | ctrlAnd_0_ln167_z | ctrlAnd_0_ln128_z);
      rd_request_sel = ctrlAnd_1_ln228_z | ctrlAnd_1_ln167_z | ctrlAnd_0_ln167_z | 
      ctrlAnd_0_ln128_z;
      ctrlOr_ln176_z = ctrlAnd_0_ln176_z | ctrlAnd_0_ln167_z;
      if (eq_ln283_z) 
        mux_index_ln283_z = {add_ln282_z, add_ln250_z[9:0]};
      else 
        mux_index_ln283_z = sub_ln286_z;
      bufdin_set_ready_curr_hold = ~(ctrlAnd_1_ln300_z | ctrlAnd_1_ln300_6_z | 
      ctrlAnd_1_ln300_5_z | ctrlAnd_1_ln300_4_z | ctrlAnd_1_ln300_3_z | 
      ctrlAnd_1_ln300_2_z | ctrlAnd_1_ln300_1_z | ctrlAnd_1_ln300_0_z);
      A0_bridge0_rtl_CE_en = memwrite_fft_A0_ln271_en | memwrite_fft_A0_ln264_en | 
      memwrite_fft_A0_ln239_en | memwrite_fft_A0_ln232_en | 
      memwrite_fft_A0_ln191_en | memwrite_fft_A0_ln184_en | ctrlAnd_1_ln300_z | 
      ctrlAnd_1_ln300_0_z;
      case (1'b1)// synthesis parallel_case
        mux_i_ln143_sel: mux_i_ln143_d = {mux_add_ln143_Z_1_v_0, 
          mux_mux_i_ln143_Z_v[0]};
        mux_i_ln143_sel_0: mux_i_ln143_d = {add_ln143_1_q, mux_i_ln143_q[0]};
        default: mux_i_ln143_d = 11'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_i_ln143_sel: mux_i_ln143_1_d_0 = mux_mux_i_ln143_Z_v[9:1];
        ctrlAnd_0_ln300_0_z: mux_i_ln143_1_d_0 = mux_i_ln143_q[9:1];
        default: mux_i_ln143_1_d_0 = 9'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln224_z: add_ln250_d = mux_add_ln250_Z_v;
        add_ln250_sel: add_ln250_d = add_ln250_q;
        default: add_ln250_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln224_z: unary_or_ln231_Z_0_tag_d = mux_unary_or_ln231_Z_0_v;
        unary_or_ln231_Z_0_tag_sel: unary_or_ln231_Z_0_tag_d = 
          unary_or_ln231_Z_0_tag_0;
        default: unary_or_ln231_Z_0_tag_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln167_z: rd_length_d = 32'h800;
        rd_length_sel: rd_length_d = 32'h400;
        ctrlAnd_0_ln128_z: rd_length_d = {mux_read_fft_len_ln119_Z_v[30:0], 1'b0};
        rd_index_hold: rd_length_d = rd_length;
        default: rd_length_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        rd_index_sel: rd_index_d = mux_index_ln123_z;
        ctrlAnd_1_ln228_z: rd_index_d = add_ln250_q;
        ctrlAnd_0_ln128_z: rd_index_d = 32'h0;
        rd_index_hold: rd_index_d = rd_index;
        default: rd_index_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        rd_request_sel: rd_request_d = 1'b1;
        rd_request_sel_0: rd_request_d = 1'b0;
        rd_request_hold: rd_request_d = rd_request;
        default: rd_request_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln176_z: mux_base_ln123_d = mux_mux_base_ln123_Z_v;
        mux_base_ln123_sel: mux_base_ln123_d = mux_base_ln123_q;
        ctrlAnd_0_ln125_z: mux_base_ln123_d = mux_base_ln123_z;
        default: mux_base_ln123_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln176_z: mux_index_ln203_d = {mux_mux_s_ln203_Z_v, 
          mux_mux_index_ln203_Z_v};
        mux_base_ln123_sel: mux_index_ln203_d = {mux_s_ln203_q, 
          mux_index_ln203_q};
        default: mux_index_ln203_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln224_z: mux_ping_ln123_d = mux_mux_ping_ln123_Z_v;
        read_fft_len_ln119_sel: mux_ping_ln123_d = mux_ping_ln123_q;
        ctrlOr_ln176_z: mux_ping_ln123_d = mux_mux_ping_ln123_Z_0_mux_0_v;
        ctrlAnd_0_ln125_z: mux_ping_ln123_d = mux_ping_ln123_z;
        default: mux_ping_ln123_d = 8'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln224_z: read_fft_len_ln119_31_d = 
          mux_read_fft_len_ln119_Z_0_mux_0_v[31];
        read_fft_len_ln119_31_sel: read_fft_len_ln119_31_d = 
          read_fft_len_ln119_q[31];
        ctrlOr_ln176_z: read_fft_len_ln119_31_d = 
          mux_read_fft_len_ln119_Z_0_mux_1_v[31];
        ctrlAnd_0_ln125_z: read_fft_len_ln119_31_d = mux_read_fft_len_ln119_Z_v[
          31];
        ctrlOr_ln139_z: read_fft_len_ln119_31_d = 
          mux_read_fft_len_ln119_Z_31_v_2;
        default: read_fft_len_ln119_31_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln224_z: read_fft_len_ln119_d = {mux_le_ln128_Z_0_v_0, 
          mux_read_fft_log_len_ln120_Z_0_mux_0_v, 
          mux_read_fft_len_ln119_Z_0_mux_0_v[30:0]};
        read_fft_len_ln119_sel: read_fft_len_ln119_d = {le_ln128_q, 
          read_fft_log_len_ln120_q, read_fft_len_ln119_q[30:0]};
        ctrlOr_ln176_z: read_fft_len_ln119_d = {mux_le_ln128_Z_0_v_1, 
          mux_read_fft_log_len_ln120_Z_0_mux_1_v, 
          mux_read_fft_len_ln119_Z_0_mux_1_v[30:0]};
        ctrlAnd_0_ln125_z: read_fft_len_ln119_d = {mux_le_ln128_Z_0_v, 
          mux_read_fft_log_len_ln120_Z_v, mux_read_fft_len_ln119_Z_v[30:0]};
        default: read_fft_len_ln119_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln176_z: unary_or_ln183_Z_0_tag_d = mux_unary_or_ln183_Z_0_v;
        unary_or_ln183_Z_0_tag_sel: unary_or_ln183_Z_0_tag_d = 
          unary_or_ln183_Z_0_tag_0;
        default: unary_or_ln183_Z_0_tag_d = 1'bX;
      endcase
      eq_ln288_z = mux_index_ln283_z == {mux_read_fft_len_ln119_Z_v[30:0], 1'b0};
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln300_z: bufdin_set_ready_curr_d = unary_nor_ln98_z;
        ctrlAnd_1_ln300_0_z: bufdin_set_ready_curr_d = unary_nor_ln98_0_z;
        ctrlAnd_1_ln300_1_z: bufdin_set_ready_curr_d = unary_nor_ln98_1_z;
        ctrlAnd_1_ln300_2_z: bufdin_set_ready_curr_d = unary_nor_ln98_2_z;
        ctrlAnd_1_ln300_3_z: bufdin_set_ready_curr_d = unary_nor_ln98_3_z;
        ctrlAnd_1_ln300_4_z: bufdin_set_ready_curr_d = unary_nor_ln98_4_z;
        ctrlAnd_1_ln300_5_z: bufdin_set_ready_curr_d = unary_nor_ln98_5_z;
        ctrlAnd_1_ln300_6_z: bufdin_set_ready_curr_d = unary_nor_ln98_6_z;
        bufdin_set_ready_curr_hold: bufdin_set_ready_curr_d = 
          bufdin_set_ready_curr;
        default: bufdin_set_ready_curr_d = 1'bX;
      endcase
      if (eq_ln288_z) begin
        mux_index_ln288_z = 32'h0;
        mux_s_ln288_z = add_ln289_z;
      end
      else begin
        mux_index_ln288_z = mux_index_ln283_z;
        mux_s_ln288_z = mux_s_ln123_z;
      end
      case (1'b1)
        eq_ln288_z: case_mux_base_ln288_z = 3'h1;
        eq_ln283_z: case_mux_base_ln288_z = 3'h2;
        default: case_mux_base_ln288_z = 3'h4;
      endcase
      if (state_fft_unisim_fft_load_input[16]) 
        mux_mux_s_ln288_Z_v = mux_s_ln288_q;
      else 
        mux_mux_s_ln288_Z_v = mux_s_ln288_z;
      if (state_fft_unisim_fft_load_input[16]) 
        mux_mux_index_ln288_Z_v = mux_index_ln288_q;
      else 
        mux_mux_index_ln288_Z_v = mux_index_ln288_z;
      case (1'b1)// synthesis parallel_case
        case_mux_base_ln288_z[0]: mux_base_ln288_z = 32'h0;
        case_mux_base_ln288_z[1]: mux_base_ln288_z = add_ln283_z;
        case_mux_base_ln288_z[2]: mux_base_ln288_z = mux_base_ln123_z;
        default: mux_base_ln288_z = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln224_z: mux_index_ln288_d = {mux_mux_s_ln288_Z_v, 
          mux_mux_index_ln288_Z_v};
        mux_index_ln288_sel: mux_index_ln288_d = {mux_s_ln288_q, 
          mux_index_ln288_q};
        default: mux_index_ln288_d = 64'hX;
      endcase
      if (state_fft_unisim_fft_load_input[16]) 
        mux_mux_base_ln288_Z_v = mux_base_ln288_q;
      else 
        mux_mux_base_ln288_Z_v = mux_base_ln288_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln224_z: mux_base_ln288_d = mux_mux_base_ln288_Z_v;
        mux_index_ln288_sel: mux_base_ln288_d = mux_base_ln288_q;
        default: mux_base_ln288_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_load_input[0]: // Wait_ln109
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln109_z: state_fft_unisim_fft_load_input_next[0] = 1'b1;
              ctrlAnd_0_ln125_z: state_fft_unisim_fft_load_input_next[1] = 1'b1;
              ctrlOr_ln139_z: state_fft_unisim_fft_load_input_next[2] = 1'b1;
              ctrlOr_ln176_z: state_fft_unisim_fft_load_input_next[9] = 1'b1;
              ctrlOr_ln224_z: state_fft_unisim_fft_load_input_next[16] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[1]: // Wait_ln127
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln125_z: state_fft_unisim_fft_load_input_next[1] = 1'b1;
              ctrlOr_ln139_z: state_fft_unisim_fft_load_input_next[2] = 1'b1;
              ctrlOr_ln176_z: state_fft_unisim_fft_load_input_next[9] = 1'b1;
              ctrlOr_ln224_z: state_fft_unisim_fft_load_input_next[16] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[2]: // Wait_ln139
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln139_z: state_fft_unisim_fft_load_input_next[2] = 1'b1;
              ctrlOr_ln159_z: state_fft_unisim_fft_load_input_next[3] = 1'b1;
              ctrlAnd_0_ln300_z: state_fft_unisim_fft_load_input_next[5] = 1'b1;
              ctrlAnd_1_ln300_z: state_fft_unisim_fft_load_input_next[6] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[3]: // Wait_ln159
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln159_z: state_fft_unisim_fft_load_input_next[3] = 1'b1;
              ctrlOr_ln162_z: state_fft_unisim_fft_load_input_next[4] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[4]: // Wait_ln162
          state_fft_unisim_fft_load_input_next[4] = 1'b1;
        state_fft_unisim_fft_load_input[5]: // Wait_ln300
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_z: state_fft_unisim_fft_load_input_next[5] = 1'b1;
              ctrlAnd_1_ln300_z: state_fft_unisim_fft_load_input_next[6] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[6]: // Wait_ln149
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_0_z: state_fft_unisim_fft_load_input_next[7] = 
                1'b1;
              ctrlAnd_1_ln300_0_z: state_fft_unisim_fft_load_input_next[8] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[7]: // Wait_ln300_0
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_0_z: state_fft_unisim_fft_load_input_next[7] = 
                1'b1;
              ctrlAnd_1_ln300_0_z: state_fft_unisim_fft_load_input_next[8] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[8]: // Wait_ln153
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln159_z: state_fft_unisim_fft_load_input_next[3] = 1'b1;
              ctrlAnd_0_ln300_z: state_fft_unisim_fft_load_input_next[5] = 1'b1;
              ctrlAnd_1_ln300_z: state_fft_unisim_fft_load_input_next[6] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[9]: // Wait_ln176
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln176_z: state_fft_unisim_fft_load_input_next[9] = 1'b1;
              ctrlAnd_0_ln300_1_z: state_fft_unisim_fft_load_input_next[10] = 
                1'b1;
              ctrlAnd_1_ln300_1_z: state_fft_unisim_fft_load_input_next[11] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[10]: // Wait_ln300_1
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_1_z: state_fft_unisim_fft_load_input_next[10] = 
                1'b1;
              ctrlAnd_1_ln300_1_z: state_fft_unisim_fft_load_input_next[11] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[11]: // Wait_ln187
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_2_z: state_fft_unisim_fft_load_input_next[12] = 
                1'b1;
              ctrlAnd_1_ln300_2_z: state_fft_unisim_fft_load_input_next[13] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[12]: // Wait_ln300_2
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_2_z: state_fft_unisim_fft_load_input_next[12] = 
                1'b1;
              ctrlAnd_1_ln300_2_z: state_fft_unisim_fft_load_input_next[13] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[13]: // Wait_ln194
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_1_z: state_fft_unisim_fft_load_input_next[10] = 
                1'b1;
              ctrlAnd_1_ln300_1_z: state_fft_unisim_fft_load_input_next[11] = 
                1'b1;
              ctrlOr_ln209_z: state_fft_unisim_fft_load_input_next[14] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[14]: // Wait_ln209
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln209_z: state_fft_unisim_fft_load_input_next[14] = 1'b1;
              ctrlOr_ln212_z: state_fft_unisim_fft_load_input_next[15] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[15]: // Wait_ln212
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln212_z: state_fft_unisim_fft_load_input_next[15] = 1'b1;
              ctrlAnd_0_ln125_z: state_fft_unisim_fft_load_input_next[1] = 1'b1;
              ctrlOr_ln139_z: state_fft_unisim_fft_load_input_next[2] = 1'b1;
              ctrlOr_ln176_z: state_fft_unisim_fft_load_input_next[9] = 1'b1;
              ctrlOr_ln224_z: state_fft_unisim_fft_load_input_next[16] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[16]: // Wait_ln224
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln224_z: state_fft_unisim_fft_load_input_next[16] = 1'b1;
              ctrlAnd_0_ln300_3_z: state_fft_unisim_fft_load_input_next[17] = 
                1'b1;
              ctrlAnd_1_ln300_3_z: state_fft_unisim_fft_load_input_next[18] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[17]: // Wait_ln300_3
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_3_z: state_fft_unisim_fft_load_input_next[17] = 
                1'b1;
              ctrlAnd_1_ln300_3_z: state_fft_unisim_fft_load_input_next[18] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[18]: // Wait_ln235
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_4_z: state_fft_unisim_fft_load_input_next[19] = 
                1'b1;
              ctrlAnd_1_ln300_4_z: state_fft_unisim_fft_load_input_next[20] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[19]: // Wait_ln300_4
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_4_z: state_fft_unisim_fft_load_input_next[19] = 
                1'b1;
              ctrlAnd_1_ln300_4_z: state_fft_unisim_fft_load_input_next[20] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[20]: // Wait_ln242
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_3_z: state_fft_unisim_fft_load_input_next[17] = 
                1'b1;
              ctrlAnd_1_ln300_3_z: state_fft_unisim_fft_load_input_next[18] = 
                1'b1;
              ctrlOr_ln256_z: state_fft_unisim_fft_load_input_next[21] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[21]: // Wait_ln256
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln256_z: state_fft_unisim_fft_load_input_next[21] = 1'b1;
              ctrlAnd_0_ln300_5_z: state_fft_unisim_fft_load_input_next[22] = 
                1'b1;
              ctrlAnd_1_ln300_5_z: state_fft_unisim_fft_load_input_next[23] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[22]: // Wait_ln300_5
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_5_z: state_fft_unisim_fft_load_input_next[22] = 
                1'b1;
              ctrlAnd_1_ln300_5_z: state_fft_unisim_fft_load_input_next[23] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[23]: // Wait_ln267
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_6_z: state_fft_unisim_fft_load_input_next[24] = 
                1'b1;
              ctrlAnd_1_ln300_6_z: state_fft_unisim_fft_load_input_next[25] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[24]: // Wait_ln300_6
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_6_z: state_fft_unisim_fft_load_input_next[24] = 
                1'b1;
              ctrlAnd_1_ln300_6_z: state_fft_unisim_fft_load_input_next[25] = 
                1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[25]: // Wait_ln274
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_5_z: state_fft_unisim_fft_load_input_next[22] = 
                1'b1;
              ctrlAnd_1_ln300_5_z: state_fft_unisim_fft_load_input_next[23] = 
                1'b1;
              ctrlOr_ln295_z: state_fft_unisim_fft_load_input_next[26] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[26]: // Wait_ln295
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln295_z: state_fft_unisim_fft_load_input_next[26] = 1'b1;
              ctrlOr_ln298_z: state_fft_unisim_fft_load_input_next[27] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        state_fft_unisim_fft_load_input[27]: // Wait_ln298
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln298_z: state_fft_unisim_fft_load_input_next[27] = 1'b1;
              ctrlAnd_0_ln125_z: state_fft_unisim_fft_load_input_next[1] = 1'b1;
              ctrlOr_ln139_z: state_fft_unisim_fft_load_input_next[2] = 1'b1;
              ctrlOr_ln176_z: state_fft_unisim_fft_load_input_next[9] = 1'b1;
              ctrlOr_ln224_z: state_fft_unisim_fft_load_input_next[16] = 1'b1;
              default: state_fft_unisim_fft_load_input_next = 28'hX;
            endcase
          end
        default: // Don't care
          state_fft_unisim_fft_load_input_next = 28'hX;
      endcase
    end
  fft_unisim_identity_sync_write_m_1024x64m32 C_bridge0(.rtl_CE(
                                              C_bridge0_rtl_CE_en), .rtl_A(
                                              C_bridge0_rtl_a), .rtl_D(
                                              C_bridge0_rtl_d), .rtl_WE(
                                              C_bridge0_rtl_CE_en), .rtl_WEM(
                                              2'h3), .CLK(clk), .mem_CE(C_CE0), 
                                              .mem_A(C_A0), .mem_D(C_D0), .mem_WE(
                                              C_WE0), .mem_WEM(C_WEM0));
  fft_unisim_identity_sync_write_m_1024x64m32 B1_bridge0(.rtl_CE(
                                              B1_bridge0_rtl_CE_en), .rtl_A(
                                              B1_bridge0_rtl_a), .rtl_D(
                                              B1_bridge0_rtl_d), .rtl_WE(
                                              B1_bridge0_rtl_CE_en), .rtl_WEM(
                                              2'h3), .CLK(clk), .mem_CE(B1_CE0), 
                                              .mem_A(B1_A0), .mem_D(B1_D0), .mem_WE(
                                              B1_WE0), .mem_WEM(B1_WEM0));
  fft_unisim_identity_sync_write_m_1024x64m32 B0_bridge0(.rtl_CE(
                                              B0_bridge0_rtl_CE_en), .rtl_A(
                                              B0_bridge0_rtl_a), .rtl_D(
                                              B0_bridge0_rtl_d), .rtl_WE(
                                              B0_bridge0_rtl_CE_en), .rtl_WEM(
                                              2'h3), .CLK(clk), .mem_CE(B0_CE0), 
                                              .mem_A(B0_A0), .mem_D(B0_D0), .mem_WE(
                                              B0_WE0), .mem_WEM(B0_WEM0));
  fft_unisim_identity_sync_read_1024x64m32 A1_bridge1(.rtl_CE(
                                           A1_bridge1_rtl_CE_en), .rtl_A(
                                           A1_bridge1_rtl_a), .mem_Q(A1_Q1), .CLK(
                                           clk), .mem_CE(A1_CE1), .mem_A(A1_A1), 
                                           .rtl_Q(A1_bridge1_rtl_Q));
  fft_unisim_identity_sync_read_1024x64m32 A0_bridge1(.rtl_CE(
                                           A0_bridge1_rtl_CE_en), .rtl_A(
                                           A0_bridge1_rtl_a), .mem_Q(A0_Q1), .CLK(
                                           clk), .mem_CE(A0_CE1), .mem_A(A0_A1), 
                                           .rtl_Q(A0_bridge1_rtl_Q));
  fft_unisim_identity_sync_read_1024x64m32 C_bridge1(.rtl_CE(C_bridge1_rtl_CE_en), 
                                           .rtl_A(C_bridge1_rtl_a), .mem_Q(C_Q1), 
                                           .CLK(clk), .mem_CE(C_CE1), .mem_A(
                                           C_A1), .rtl_Q(C_bridge1_rtl_Q));
  // synthesis sync_set_reset_local fft_unisim_fft_process_itr_fft_seq_block rst
  always @(posedge clk) // fft_unisim_fft_process_itr_fft_sequential
    begin : fft_unisim_fft_process_itr_fft_seq_block
      if (!rst) // Initialize state and outputs
      begin
        memread_fft_A0_ln550_q <= 64'sh0;
        memread_fft_C_ln557_q <= 64'sh0;
        add_ln176_5_15_q <= 47'h0;
        add_ln176_6_15_q <= 47'h0;
        add_ln176_7_15_q <= 47'h0;
        mux_akjm32_ln549_q <= 64'sh0;
        mux_akjm32_0_ln631_q <= 64'sh0;
        mux_akjm32_1_ln703_q <= 64'sh0;
        sub_ln196_8_15_q <= 47'h0;
        sub_ln196_9_15_q <= 47'h0;
        sub_ln196_10_15_q <= 47'h0;
        add_ln404_7_q <= 32'sh0;
        add_ln404_8_q <= 32'sh0;
        add_ln404_11_q <= 32'sh0;
        add_ln404_12_q <= 32'sh0;
        add_ln404_15_q <= 32'sh0;
        add_ln404_16_q <= 32'sh0;
        mux_akj32_ln549_q <= 64'sh0;
        mul_ln221_q <= 78'sh0;
        mul_ln221_1_q <= 78'sh0;
        mul_ln221_0_q <= 78'sh0;
        mul_ln221_2_q <= 78'sh0;
        mul_ln221_3_q <= 78'sh0;
        mul_ln221_5_q <= 78'sh0;
        mul_ln221_4_q <= 78'sh0;
        mul_ln221_6_q <= 78'sh0;
        mux_w_0_ln619_q <= 96'sh0;
        mul_ln221_7_q <= 78'sh0;
        mul_ln221_9_q <= 78'sh0;
        mul_ln221_8_q <= 78'sh0;
        mul_ln221_10_q <= 78'sh0;
        mux_akj32_0_ln631_q <= 64'sh0;
        mux_akj32_1_ln703_q <= 64'sh0;
        add_ln404_q <= 48'sh0;
        add_ln404_0_q <= 48'sh0;
        add_ln404_2_q <= 48'sh0;
        add_ln404_1_q <= 48'sh0;
        add_ln404_4_q <= 48'sh0;
        mux_w_1_ln693_q <= 96'sh0;
        loop_start <= 1'sb0;
        or_and_0_ln530_Z_0_q <= 1'sb0;
        or_and_0_ln620_Z_0_q <= 1'sb0;
        add_ln623_q <= 10'sh0;
        mux_j_1_ln693_q <= 9'sh0;
        add_ln693_1_q <= 9'sh0;
        mux_wsplit_ln754_q <= 96'sh0;
        add_ln404_3_q <= 48'sh0;
        loop_done <= 1'sb0;
        mux_windex_ln501_q <= 22'sh0;
        mux_wsplit_ln501_q <= 96'sh0;
        mux_s_ln763_q <= 32'sh0;
        le_ln603_q <= 1'sb0;
        and_1_ln530_q <= 1'sb0;
        lt_ln613_q <= 1'sb0;
        mux_k_0_ln613_q <= 10'sh0;
        add_ln613_q <= 10'sh0;
        and_1_ln620_q <= 1'sb0;
        add_ln624_0_q <= 10'sh0;
        mux_j_0_ln619_q <= 1'sb0;
        add_ln619_1_q <= 9'sh0;
        and_1_ln511_q <= 1'sb0;
        or_and_0_ln511_Z_0_q <= 1'sb0;
        mux_myCos_ln24_0_q <= 29'sh0;
        unary_or_ln631_Z_0_tag_0 <= 1'sb0;
        lsh_ln608_q <= 32'sh0;
        mux_s_ln490_q <= 32'sh0;
        mux_mySin_ln47_0_q <= 31'sh0;
        add_div_ln616_q <= 31'sh0;
        add_ln541_q <= 10'sh0;
        add_ln542_0_q <= 10'sh0;
        mux_j_ln537_q <= 1'sb0;
        add_ln537_1_q <= 9'sh0;
        mux_w_ln537_q <= 96'sh0;
        mux_myCos_ln24_1_q <= 29'sh0;
        mux_mySin_ln47_1_q <= 31'sh0;
        unary_or_ln703_Z_0_tag_0 <= 1'sb0;
        eq_ln754_q <= 1'sb0;
        mux_windex_ln754_q <= 22'sh0;
        eq_ln763_Z_0_tag_0 <= 1'sb0;
        mux_k_ln529_q <= 10'sh0;
        add_ln529_q <= 32'sh0;
        mux_ping_ln490_q <= 8'sh0;
        mux_index_ln763_q <= 22'sh0;
        eq_ln549_Z_0_tag_0 <= 1'sb0;
        eq_ln584_Z_0_tag_0 <= 1'sb0;
        lsh_ln514_q <= 16'sh0;
        mux_myCos_ln24_q <= 29'sh0;
        mux_s_ln510_q <= 4'sh0;
        add_ln510_1_q <= 3'sh0;
        mux_mySin_ln47_q <= 31'sh0;
        mux_windex_ln490_q <= 22'sh0;
        mux_wsplit_ln490_q <= 96'sh0;
        read_fft_len_ln483_q <= 32'sh0;
        read_fft_log_len_ln484_q <= 4'sh0;
        le_ln501_q <= 1'sb0;
        state_fft_unisim_fft_process_itr_fft <= 32'h1;
      end
      else // Update Q values
      begin
        memread_fft_A0_ln550_q <= A0_bridge1_rtl_Q;
        memread_fft_C_ln557_q <= C_bridge1_rtl_Q;
        add_ln176_5_15_q <= add_ln176_5_z[61:15];
        add_ln176_6_15_q <= add_ln176_6_z[61:15];
        add_ln176_7_15_q <= add_ln176_7_z[61:15];
        mux_akjm32_ln549_q <= mux_akjm32_ln549_z;
        mux_akjm32_0_ln631_q <= mux_akjm32_0_ln631_z;
        mux_akjm32_1_ln703_q <= mux_akjm32_1_ln703_z;
        sub_ln196_8_15_q <= sub_ln196_8_z[61:15];
        sub_ln196_9_15_q <= sub_ln196_9_z[61:15];
        sub_ln196_10_15_q <= sub_ln196_10_z[61:15];
        add_ln404_7_q <= add_ln404_7_z;
        add_ln404_8_q <= add_ln404_8_z;
        add_ln404_11_q <= add_ln404_11_z;
        add_ln404_12_q <= add_ln404_12_z;
        add_ln404_15_q <= add_ln404_15_z;
        add_ln404_16_q <= add_ln404_16_z;
        mux_akj32_ln549_q <= mux_akj32_ln549_d;
        mul_ln221_q <= mul_ln221_z;
        mul_ln221_1_q <= mul_ln221_1_z;
        mul_ln221_0_q <= mul_ln221_0_z;
        mul_ln221_2_q <= mul_ln221_2_z;
        mul_ln221_3_q <= mul_ln221_3_z;
        mul_ln221_5_q <= mul_ln221_5_z;
        mul_ln221_4_q <= mul_ln221_4_z;
        mul_ln221_6_q <= mul_ln221_6_z;
        mux_w_0_ln619_q <= {mux_w_0_ln619_64_d_0, mux_w_0_ln619_d};
        mul_ln221_7_q <= mul_ln221_7_z;
        mul_ln221_9_q <= mul_ln221_9_z;
        mul_ln221_8_q <= mul_ln221_8_z;
        mul_ln221_10_q <= mul_ln221_10_z;
        mux_akj32_0_ln631_q <= mux_akj32_0_ln631_d;
        mux_akj32_1_ln703_q <= mux_akj32_1_ln703_d;
        add_ln404_q <= {add_ln404_16_d_0, add_ln404_0_d_0[63:48]};
        add_ln404_0_q <= add_ln404_0_d_0[47:0];
        add_ln404_2_q <= add_ln404_2_d_0[47:0];
        add_ln404_1_q <= {add_ln404_1_16_d_0, add_ln404_2_d_0[63:48]};
        add_ln404_4_q <= add_ln404_4_d_0[47:0];
        mux_w_1_ln693_q <= {mux_w_1_ln693_64_d_0, mux_w_1_ln693_d};
        loop_start <= loop_start_d;
        or_and_0_ln530_Z_0_q <= or_and_0_ln530_Z_0_z;
        or_and_0_ln620_Z_0_q <= or_and_0_ln620_Z_0_z;
        add_ln623_q <= add_ln623_d;
        mux_j_1_ln693_q <= {mux_j_1_ln693_1_d_0, mux_j_1_ln693_d[0]};
        add_ln693_1_q <= mux_j_1_ln693_d[9:1];
        mux_wsplit_ln754_q <= {mux_wsplit_ln754_32_d_0, add_ln404_3_16_d_0[63:32]};
        add_ln404_3_q <= {add_ln404_3_16_d_0[31:0], add_ln404_4_d_0[63:48]};
        loop_done <= loop_done_d;
        mux_windex_ln501_q <= mux_windex_ln501_d[21:0];
        mux_wsplit_ln501_q <= {mux_wsplit_ln501_42_d_0[53:0], mux_windex_ln501_d
        [63:22]};
        mux_s_ln763_q <= {mux_s_ln763_10_d_0, mux_wsplit_ln501_42_d_0[63:54]};
        le_ln603_q <= le_ln603_d;
        and_1_ln530_q <= and_1_ln530_z;
        lt_ln613_q <= mux_k_0_ln613_d[20];
        mux_k_0_ln613_q <= mux_k_0_ln613_d[9:0];
        add_ln613_q <= mux_k_0_ln613_d[19:10];
        and_1_ln620_q <= and_1_ln620_z;
        add_ln624_0_q <= mux_j_0_ln619_d_0[19:10];
        mux_j_0_ln619_q <= mux_j_0_ln619_d_0[0];
        add_ln619_1_q <= mux_j_0_ln619_d_0[9:1];
        and_1_ln511_q <= and_1_ln511_z;
        or_and_0_ln511_Z_0_q <= or_and_0_ln511_Z_0_z;
        mux_myCos_ln24_0_q <= lsh_ln608_d[61:33];
        unary_or_ln631_Z_0_tag_0 <= lsh_ln608_d[32];
        lsh_ln608_q <= lsh_ln608_d[31:0];
        mux_s_ln490_q <= mux_s_ln490_d;
        mux_mySin_ln47_0_q <= {mux_mySin_ln47_0_2_d_0[28:0], lsh_ln608_d[63:62]};
        add_div_ln616_q <= mux_mySin_ln47_0_2_d_0[59:29];
        add_ln541_q <= add_ln541_d;
        add_ln542_0_q <= add_ln542_0_d;
        mux_j_ln537_q <= mux_j_ln537_d_0[0];
        add_ln537_1_q <= mux_j_ln537_d_0[9:1];
        mux_w_ln537_q <= {mux_w_ln537_64_d_0, mux_w_ln537_d};
        mux_myCos_ln24_1_q <= unary_or_ln703_Z_0_tag_d_0[30:2];
        mux_mySin_ln47_1_q <= unary_or_ln703_Z_0_tag_d_0[61:31];
        unary_or_ln703_Z_0_tag_0 <= unary_or_ln703_Z_0_tag_d_0[0];
        eq_ln754_q <= unary_or_ln703_Z_0_tag_d_0[1];
        mux_windex_ln754_q <= {mux_windex_ln754_2_d_0, 
        unary_or_ln703_Z_0_tag_d_0[63:62]};
        eq_ln763_Z_0_tag_0 <= eq_ln763_Z_0_tag_d;
        mux_k_ln529_q <= mux_k_ln529_d[9:0];
        add_ln529_q <= mux_k_ln529_d[41:10];
        mux_ping_ln490_q <= mux_ping_ln490_d[7:0];
        mux_index_ln763_q <= mux_ping_ln490_d[29:8];
        eq_ln549_Z_0_tag_0 <= mux_s_ln510_d[20];
        eq_ln584_Z_0_tag_0 <= mux_s_ln510_d[21];
        lsh_ln514_q <= mux_s_ln510_d[16:1];
        mux_myCos_ln24_q <= mux_s_ln510_d[50:22];
        mux_s_ln510_q <= {mux_s_ln510_z[3:1], mux_s_ln510_d[0]};
        add_ln510_1_q <= mux_s_ln510_d[19:17];
        mux_mySin_ln47_q <= {mux_mySin_ln47_13_d_0, mux_s_ln510_d[63:51]};
        mux_windex_ln490_q <= mux_windex_ln490_d;
        mux_wsplit_ln490_q <= {mux_wsplit_ln490_64_d_0, mux_wsplit_ln490_d};
        read_fft_len_ln483_q <= read_fft_len_ln483_d[31:0];
        read_fft_log_len_ln484_q <= read_fft_len_ln483_d[35:32];
        le_ln501_q <= read_fft_len_ln483_d[36];
        state_fft_unisim_fft_process_itr_fft <= 
        state_fft_unisim_fft_process_itr_fft_next;
      end
    end
  always @(*) begin : fft_unisim_fft_process_itr_fft_combinational
      reg memread_fft_A0_ln552_en;
      reg memread_fft_A0_ln634_en;
      reg memread_fft_A0_ln706_en;
      reg ctrlOr_ln537_0_z;
      reg FFT_SPLIT_L3_for_begin_or_0;
      reg memwrite_fft_B0_ln585_en;
      reg memwrite_fft_B0_ln587_en;
      reg memwrite_fft_B0_ln665_en;
      reg memwrite_fft_B0_ln667_en;
      reg memwrite_fft_B0_ln737_en;
      reg memwrite_fft_B0_ln739_en;
      reg ctrlAnd_1_ln620_z;
      reg [45:0] add_ln404_17_z;
      reg [45:0] add_ln404_0_0_z;
      reg [45:0] add_ln404_18_z;
      reg [45:0] add_ln404_0_1_z;
      reg [45:0] add_ln404_19_z;
      reg [45:0] add_ln404_0_2_z;
      reg [77:0] sub_ln196_z;
      reg [77:0] sub_ln196_0_z;
      reg [77:0] sub_ln196_1_z;
      reg signed [61:0] mul_ln221_1_0_z;
      reg signed [61:0] mul_ln221_2_0_z;
      reg signed [61:0] mul_ln221_1_1_z;
      reg signed [61:0] mul_ln221_2_1_z;
      reg signed [61:0] mul_ln221_1_2_z;
      reg signed [61:0] mul_ln221_2_2_z;
      reg [77:0] add_ln176_z;
      reg [77:0] add_ln176_0_z;
      reg [77:0] add_ln176_1_z;
      reg [31:0] mux_s_ln501_z;
      reg add_ln404_0_mux_0_sel;
      reg add_ln404_2_mux_0_sel;
      reg add_ln404_4_mux_0_sel;
      reg add_ln541_sel;
      reg add_ln542_0_sel;
      reg ctrlOr_ln619_0_z;
      reg ctrlAnd_0_ln511_z;
      reg ctrlAnd_0_ln530_z;
      reg ctrlAnd_0_ln620_z;
      reg ctrlAnd_1_ln511_z;
      reg ctrlAnd_1_ln530_z;
      reg ctrlAnd_1_ln693_z;
      reg le_ln501_z;
      reg mux_akj32_0_ln631_sel;
      reg mux_akj32_1_ln703_sel;
      reg mux_j_1_ln693_1_mux_0_sel;
      reg mux_j_1_ln693_sel;
      reg mux_j_ln537_mux_0_sel;
      reg [21:0] mux_windex_ln501_z;
      reg [95:0] mux_wsplit_ln501_z;
      reg mux_w_1_ln693_sel;
      reg mux_w_ln537_sel;
      reg signed [61:0] mul_ln221_11_z;
      reg signed [61:0] mul_ln221_0_0_z;
      reg signed [61:0] mul_ln221_12_z;
      reg signed [61:0] mul_ln221_0_1_z;
      reg signed [61:0] mul_ln221_13_z;
      reg signed [61:0] mul_ln221_0_2_z;
      reg add_ln623_sel;
      reg memread_fft_A0_ln632_en;
      reg mux_j_0_ln619_mux_0_sel;
      reg mux_w_0_ln619_sel;
      reg [45:0] sub_ln196_5_z;
      reg [31:0] add_ln176_8_z;
      reg [45:0] sub_ln196_0_0_z;
      reg [31:0] add_ln176_0_0_z;
      reg [45:0] sub_ln196_6_z;
      reg [31:0] add_ln176_9_z;
      reg [45:0] sub_ln196_0_1_z;
      reg [31:0] add_ln176_0_1_z;
      reg [45:0] sub_ln196_7_z;
      reg [31:0] add_ln176_10_z;
      reg [45:0] sub_ln196_0_2_z;
      reg [31:0] add_ln176_0_2_z;
      reg [47:0] add_ln176_2_z;
      reg [47:0] add_ln176_3_z;
      reg [47:0] add_ln176_4_z;
      reg [77:0] sub_ln196_2_z;
      reg [77:0] sub_ln196_3_z;
      reg [77:0] sub_ln196_4_z;
      reg [31:0] add_ln764_z;
      reg mux_k_0_ln613_sel;
      reg ctrlAnd_0_ln693_z;
      reg ctrlAnd_1_ln477_z;
      reg ctrlAnd_0_ln477_z;
      reg ctrlAnd_1_ln492_z;
      reg ctrlAnd_0_ln492_z;
      reg ctrlAnd_1_ln495_z;
      reg ctrlAnd_0_ln495_z;
      reg ctrlOr_ln510_0_z;
      reg ctrlAnd_0_ln613_z;
      reg ctrlAnd_1_ln774_z;
      reg ctrlAnd_0_ln774_z;
      reg ctrlAnd_1_ln777_z;
      reg ctrlAnd_0_ln777_z;
      reg ctrlAnd_1_ln613_z;
      reg [63:0] mux_akj32_ln549_z;
      reg memread_fft_C_ln555_en;
      reg memwrite_fft_C_ln594_en;
      reg memwrite_fft_C_ln592_en;
      reg [31:0] mux_s_ln490_z;
      reg [21:0] mux_windex_ln490_z;
      reg [95:0] mux_wsplit_ln490_z;
      reg [21:0] mux_index_ln490_z;
      reg [31:0] mux_k_ln529_z;
      reg [95:0] mux_w_ln537_z;
      reg [9:0] mux_k_0_ln613_z;
      reg [95:0] mux_w_0_ln619_z;
      reg [95:0] mux_w_1_ln693_z;
      reg memread_fft_A1_ln639_en;
      reg memwrite_fft_B1_ln672_en;
      reg memwrite_fft_B1_ln674_en;
      reg [63:0] mux_akj32_0_ln631_z;
      reg memread_fft_A1_ln637_en;
      reg memread_fft_A1_ln711_en;
      reg memwrite_fft_B1_ln744_en;
      reg memwrite_fft_B1_ln746_en;
      reg [63:0] mux_akj32_1_ln703_z;
      reg [9:0] mux_j_0_ln619_z;
      reg [8:0] mux_j_1_ln693_z;
      reg [9:0] mux_j_ln537_z;
      reg [21:0] mux_mux_windex_ln501_Z_v;
      reg [63:0] mux_mux_wsplit_ln501_Z_v;
      reg [31:0] mux_mux_wsplit_ln501_Z_64_v_0;
      reg [7:0] mux_ping_ln490_z;
      reg [31:0] add_ln404_5_z;
      reg [31:0] add_ln404_6_z;
      reg [31:0] add_ln404_9_z;
      reg [31:0] add_ln404_10_z;
      reg [31:0] add_ln404_13_z;
      reg [31:0] add_ln404_14_z;
      reg [47:0] add_ln404_0_z;
      reg [47:0] add_ln404_2_z;
      reg [47:0] add_ln404_4_z;
      reg [47:0] add_ln404_z;
      reg [47:0] add_ln404_1_z;
      reg [47:0] add_ln404_3_z;
      reg [31:0] mux_s_ln763_z;
      reg ctrlOr_ln693_z;
      reg ctrlAnd_1_ln501_z;
      reg loop_start_hold;
      reg ctrlAnd_0_ln501_z;
      reg ctrlOr_ln495_z;
      reg ctrlOr_ln613_z;
      reg ctrlOr_ln490_z;
      reg ctrlOr_ln777_z;
      reg ctrlOr_ln501_z;
      reg [31:0] lsh_ln608_z;
      reg [31:0] lsh_ln686_z;
      reg [31:0] mux_mux_s_ln490_Z_v;
      reg [16:0] switch_ln26_0_z;
      reg [30:0] mux_mySin_ln47_0_z;
      reg [28:0] mux_myCos_ln24_0_z;
      reg [16:0] switch_ln26_1_z;
      reg [30:0] mux_mySin_ln47_1_z;
      reg [28:0] mux_myCos_ln24_1_z;
      reg le_ln603_z;
      reg [21:0] mux_mux_windex_ln490_Z_v;
      reg [21:0] add_ln753_z;
      reg [63:0] mux_mux_wsplit_ln490_Z_v;
      reg [31:0] mux_mux_wsplit_ln490_Z_64_v_0;
      reg [21:0] add_ln762_z;
      reg eq_ln530_z;
      reg lt_ln529_z;
      reg [31:0] add_ln529_z;
      reg [31:0] add_ln613_z;
      reg [9:0] add_ln619_z;
      reg eq_ln620_z;
      reg lt_ln619_z;
      reg [9:0] add_ln623_z;
      reg [9:0] add_ln693_z;
      reg [9:0] add_ln537_z;
      reg eq_ln538_z;
      reg lt_ln537_z;
      reg [9:0] add_ln541_z;
      reg [7:0] unary_not_ln767_z;
      reg unary_or_ln631_z;
      reg unary_or_ln703_z;
      reg [7:0] mux_mux_ping_ln490_Z_v;
      reg eq_ln549_z;
      reg eq_ln584_z;
      reg gt_ln511_z;
      reg le_ln510_z;
      reg [15:0] lsh_ln514_z;
      reg [15:0] switch_ln26_z;
      reg [30:0] mux_mySin_ln47_z;
      reg [28:0] mux_myCos_ln24_z;
      reg [3:0] add_ln510_z;
      reg [95:0] mux_wsplit_ln754_z;
      reg [31:0] mux_mux_s_ln763_Z_v;
      reg memread_fft_A0_ln704_en;
      reg memread_fft_A1_ln709_en;
      reg ctrlAnd_1_ln603_z;
      reg ctrlAnd_0_ln603_z;
      reg ctrlOr_ln492_z;
      reg loop_done_hold;
      reg ctrlOr_ln774_z;
      reg and_div_ln616_z;
      reg [31:0] mux_lsh_ln608_Z_v;
      reg [28:0] mux_mux_myCos_ln24_0_Z_v;
      reg [30:0] mux_mux_mySin_ln47_0_Z_v;
      reg [28:0] mux_mux_myCos_ln24_1_Z_v;
      reg [30:0] mux_mux_mySin_ln47_1_Z_v;
      reg mux_le_ln603_Z_0_v;
      reg eq_ln754_z;
      reg eq_ln763_z;
      reg if_ln530_z;
      reg lt_ln613_z;
      reg if_ln620_z;
      reg [9:0] add_ln624_0_z;
      reg or_and_0_ln538_Z_0_z;
      reg if_ln538_z;
      reg [9:0] add_ln542_0_z;
      reg mux_unary_or_ln631_Z_0_v;
      reg mux_unary_or_ln703_Z_0_v;
      reg if_ln511_z;
      reg if_ln510_z;
      reg unary_or_ln703_Z_0_tag_mux_0_sel;
      reg lsh_ln608_sel;
      reg mux_s_ln490_sel;
      reg [30:0] add_div_ln616_z;
      reg mux_eq_ln754_Z_0_v;
      reg mux_eq_ln763_Z_0_v;
      reg ctrlAnd_0_ln538_z;
      reg and_1_ln538_z;
      reg [30:0] mux_add_div_ln616_Z_v;
      reg [21:0] mux_windex_ln754_z;
      reg [21:0] mux_index_ln763_z;
      reg ctrlOr_ln529_0_z;
      reg ctrlAnd_1_ln538_z;
      reg [21:0] mux_mux_windex_ln754_Z_v;
      reg [21:0] mux_mux_index_ln763_Z_v;
      reg eq_ln763_Z_0_tag_sel;
      reg memread_fft_A0_ln550_en;
      reg memread_fft_C_ln557_en;
      reg mux_k_ln529_sel;
      reg mux_ping_ln490_sel;
      reg mux_s_ln510_sel;
      reg mux_windex_ln490_sel;
      reg mux_wsplit_ln490_sel;
      reg read_fft_len_ln483_sel;

      state_fft_unisim_fft_process_itr_fft_next = 32'h0;
      memread_fft_A0_ln552_en = eq_ln549_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[11];
      memread_fft_A0_ln634_en = unary_or_ln631_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[20];
      memread_fft_A0_ln706_en = unary_or_ln703_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[26];
      ctrlOr_ln537_0_z = state_fft_unisim_fft_process_itr_fft[16] | 
      state_fft_unisim_fft_process_itr_fft[10];
      FFT_SPLIT_L3_for_begin_or_0 = state_fft_unisim_fft_process_itr_fft[25] | 
      state_fft_unisim_fft_process_itr_fft[31];
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[14]: B0_bridge0_rtl_a = add_ln541_q;
        state_fft_unisim_fft_process_itr_fft[15]: B0_bridge0_rtl_a = 
          add_ln542_0_q;
        state_fft_unisim_fft_process_itr_fft[23]: B0_bridge0_rtl_a = add_ln623_q;
        state_fft_unisim_fft_process_itr_fft[24]: B0_bridge0_rtl_a = 
          add_ln624_0_q;
        state_fft_unisim_fft_process_itr_fft[29]: B0_bridge0_rtl_a = {1'b0, 
          mux_j_1_ln693_q};
        state_fft_unisim_fft_process_itr_fft[30]: B0_bridge0_rtl_a = {1'b1, 
          mux_j_1_ln693_q};
        default: B0_bridge0_rtl_a = 10'hX;
      endcase
      memwrite_fft_B0_ln585_en = state_fft_unisim_fft_process_itr_fft[14] & 
      eq_ln584_Z_0_tag_0;
      memwrite_fft_B0_ln587_en = eq_ln584_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[15];
      memwrite_fft_B0_ln665_en = unary_or_ln631_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[23];
      memwrite_fft_B0_ln667_en = unary_or_ln631_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[24];
      memwrite_fft_B0_ln737_en = unary_or_ln703_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[29];
      memwrite_fft_B0_ln739_en = unary_or_ln703_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[30];
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[23]: B1_bridge0_rtl_a = add_ln623_q;
        state_fft_unisim_fft_process_itr_fft[24]: B1_bridge0_rtl_a = 
          add_ln624_0_q;
        state_fft_unisim_fft_process_itr_fft[29]: B1_bridge0_rtl_a = {1'b0, 
          mux_j_1_ln693_q};
        state_fft_unisim_fft_process_itr_fft[30]: B1_bridge0_rtl_a = {1'b1, 
          mux_j_1_ln693_q};
        default: B1_bridge0_rtl_a = 10'hX;
      endcase
      ctrlAnd_1_ln620_z = and_1_ln620_q & 
      state_fft_unisim_fft_process_itr_fft[19];
      add_ln404_17_z = sub_ln196_8_15_q[46:1] + sub_ln196_8_15_q[0];
      add_ln404_0_0_z = add_ln176_5_15_q[46:1] + add_ln176_5_15_q[0];
      add_ln404_18_z = sub_ln196_9_15_q[46:1] + sub_ln196_9_15_q[0];
      add_ln404_0_1_z = add_ln176_6_15_q[46:1] + add_ln176_6_15_q[0];
      add_ln404_19_z = sub_ln196_10_15_q[46:1] + sub_ln196_10_15_q[0];
      add_ln404_0_2_z = add_ln176_7_15_q[46:1] + add_ln176_7_15_q[0];
      sub_ln196_z = mul_ln221_1_q - mul_ln221_2_q;
      sub_ln196_0_z = mul_ln221_5_q - mul_ln221_6_q;
      sub_ln196_1_z = mul_ln221_9_q - mul_ln221_10_q;
      mul_ln221_1_0_z = $signed(mux_w_ln537_q[47:0]) * $signed(
      mux_akjm32_ln549_q[63:32]);
      mul_ln221_2_0_z = $signed(mux_w_ln537_q[95:48]) * $signed(
      mux_akjm32_ln549_q[31:0]);
      mul_ln221_1_1_z = $signed(mux_w_0_ln619_q[47:0]) * $signed(
      mux_akjm32_0_ln631_q[63:32]);
      mul_ln221_2_1_z = $signed(mux_w_0_ln619_q[95:48]) * $signed(
      mux_akjm32_0_ln631_q[31:0]);
      mul_ln221_1_2_z = $signed(mux_w_1_ln693_q[47:0]) * $signed(
      mux_akjm32_1_ln703_q[63:32]);
      mul_ln221_2_2_z = $signed(mux_w_1_ln693_q[95:48]) * $signed(
      mux_akjm32_1_ln703_q[31:0]);
      add_ln176_z = mul_ln221_q + mul_ln221_0_q;
      add_ln176_0_z = mul_ln221_3_q + mul_ln221_4_q;
      add_ln176_1_z = mul_ln221_7_q + mul_ln221_8_q;
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[19]: mux_s_ln501_z = mux_s_ln490_q;
        state_fft_unisim_fft_process_itr_fft[5]: mux_s_ln501_z = {28'h0, 
          mux_s_ln510_q};
        state_fft_unisim_fft_process_itr_fft[31]: mux_s_ln501_z = mux_s_ln490_q;
        default: mux_s_ln501_z = 32'hX;
      endcase
      add_ln404_0_mux_0_sel = state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12];
      add_ln404_2_mux_0_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20];
      add_ln404_4_mux_0_sel = state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[30] | 
      state_fft_unisim_fft_process_itr_fft[27];
      add_ln541_sel = state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      add_ln542_0_sel = state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      ctrlOr_ln619_0_z = state_fft_unisim_fft_process_itr_fft[24] | 
      state_fft_unisim_fft_process_itr_fft[18];
      ctrlAnd_0_ln511_z = or_and_0_ln511_Z_0_q & 
      state_fft_unisim_fft_process_itr_fft[5];
      ctrlAnd_0_ln530_z = or_and_0_ln530_Z_0_q & 
      state_fft_unisim_fft_process_itr_fft[9];
      ctrlAnd_0_ln620_z = or_and_0_ln620_Z_0_q & 
      state_fft_unisim_fft_process_itr_fft[19];
      ctrlAnd_1_ln511_z = and_1_ln511_q & 
      state_fft_unisim_fft_process_itr_fft[5];
      ctrlAnd_1_ln530_z = and_1_ln530_q & 
      state_fft_unisim_fft_process_itr_fft[9];
      ctrlAnd_1_ln693_z = add_ln693_1_q[8] & 
      state_fft_unisim_fft_process_itr_fft[31];
      le_ln501_z = log_len <= 32'ha;
      mux_akj32_0_ln631_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[21];
      mux_akj32_1_ln703_sel = state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[27];
      mux_j_1_ln693_1_mux_0_sel = state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26];
      mux_j_1_ln693_sel = state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[30] | 
      state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26];
      mux_j_ln537_mux_0_sel = state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[19]: mux_windex_ln501_z = 
          mux_windex_ln490_q;
        state_fft_unisim_fft_process_itr_fft[5]: mux_windex_ln501_z = 
          mux_windex_ln490_q;
        state_fft_unisim_fft_process_itr_fft[31]: mux_windex_ln501_z = 
          mux_windex_ln754_q;
        default: mux_windex_ln501_z = 22'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[19]: mux_wsplit_ln501_z = 
          mux_wsplit_ln490_q;
        state_fft_unisim_fft_process_itr_fft[5]: mux_wsplit_ln501_z = 
          mux_wsplit_ln490_q;
        state_fft_unisim_fft_process_itr_fft[31]: mux_wsplit_ln501_z = 
          mux_wsplit_ln754_q;
        default: mux_wsplit_ln501_z = 96'hX;
      endcase
      mux_w_1_ln693_sel = state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26];
      mux_w_ln537_sel = state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      mul_ln221_11_z = $signed(mux_w_ln537_q[47:0]) * $signed(mux_akjm32_ln549_q
      [31:0]);
      mul_ln221_0_0_z = $signed(mux_w_ln537_q[95:48]) * $signed(
      mux_akjm32_ln549_q[63:32]);
      mul_ln221_12_z = $signed(mux_w_0_ln619_q[47:0]) * $signed(
      mux_akjm32_0_ln631_q[31:0]);
      mul_ln221_0_1_z = $signed(mux_w_0_ln619_q[95:48]) * $signed(
      mux_akjm32_0_ln631_q[63:32]);
      mul_ln221_13_z = $signed(mux_w_1_ln693_q[47:0]) * $signed(
      mux_akjm32_1_ln703_q[31:0]);
      mul_ln221_0_2_z = $signed(mux_w_1_ln693_q[95:48]) * $signed(
      mux_akjm32_1_ln703_q[63:32]);
      B0_bridge0_rtl_CE_en = memwrite_fft_B0_ln739_en | memwrite_fft_B0_ln737_en | 
      memwrite_fft_B0_ln667_en | memwrite_fft_B0_ln665_en | 
      memwrite_fft_B0_ln587_en | memwrite_fft_B0_ln585_en;
      if (state_fft_unisim_fft_process_itr_fft[14]) 
        C_bridge0_rtl_a = add_ln541_q;
      else 
        C_bridge0_rtl_a = add_ln542_0_q;
      add_ln623_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      ctrlAnd_1_ln620_z | state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20];
      memread_fft_A0_ln632_en = unary_or_ln631_Z_0_tag_0 & ctrlAnd_1_ln620_z;
      mux_j_0_ln619_mux_0_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | ctrlAnd_1_ln620_z | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20];
      mux_w_0_ln619_sel = ctrlAnd_1_ln620_z | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20];
      sub_ln196_5_z = {mux_akj32_ln549_q[31:0], 14'h0} - add_ln404_17_z;
      add_ln176_8_z = mux_akj32_ln549_q[31:0] + add_ln404_17_z[45:14];
      sub_ln196_0_0_z = {mux_akj32_ln549_q[63:32], 14'h0} - add_ln404_0_0_z;
      add_ln176_0_0_z = mux_akj32_ln549_q[63:32] + add_ln404_0_0_z[45:14];
      sub_ln196_6_z = {mux_akj32_0_ln631_q[31:0], 14'h0} - add_ln404_18_z;
      add_ln176_9_z = mux_akj32_0_ln631_q[31:0] + add_ln404_18_z[45:14];
      sub_ln196_0_1_z = {mux_akj32_0_ln631_q[63:32], 14'h0} - add_ln404_0_1_z;
      add_ln176_0_1_z = mux_akj32_0_ln631_q[63:32] + add_ln404_0_1_z[45:14];
      sub_ln196_7_z = {mux_akj32_1_ln703_q[31:0], 14'h0} - add_ln404_19_z;
      add_ln176_10_z = mux_akj32_1_ln703_q[31:0] + add_ln404_19_z[45:14];
      sub_ln196_0_2_z = {mux_akj32_1_ln703_q[63:32], 14'h0} - add_ln404_0_2_z;
      add_ln176_0_2_z = mux_akj32_1_ln703_q[63:32] + add_ln404_0_2_z[45:14];
      add_ln176_2_z = sub_ln196_z[77:30] + mux_w_ln537_q[95:48];
      add_ln176_3_z = sub_ln196_0_z[77:30] + mux_w_0_ln619_q[95:48];
      add_ln176_4_z = sub_ln196_1_z[77:30] + mux_w_1_ln693_q[95:48];
      add_ln176_5_z = $unsigned(mul_ln221_1_0_z) + $unsigned(mul_ln221_2_0_z);
      add_ln176_6_z = $unsigned(mul_ln221_1_1_z) + $unsigned(mul_ln221_2_1_z);
      add_ln176_7_z = $unsigned(mul_ln221_1_2_z) + $unsigned(mul_ln221_2_2_z);
      sub_ln196_2_z = {mux_w_ln537_q[47:0], 30'h0} - add_ln176_z;
      sub_ln196_3_z = {mux_w_0_ln619_q[47:0], 30'h0} - add_ln176_0_z;
      sub_ln196_4_z = {mux_w_1_ln693_q[47:0], 30'h0} - add_ln176_1_z;
      add_ln764_z = mux_s_ln501_z + 32'h1;
      mux_k_0_ln613_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | ctrlOr_ln619_0_z | 
      ctrlAnd_1_ln620_z | state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20];
      ctrlAnd_0_ln693_z = !add_ln693_1_q[8] & 
      state_fft_unisim_fft_process_itr_fft[31];
      ctrlAnd_1_ln477_z = init_done & state_fft_unisim_fft_process_itr_fft[0];
      ctrlAnd_0_ln477_z = !init_done & state_fft_unisim_fft_process_itr_fft[0];
      ctrlAnd_1_ln492_z = input_ready & state_fft_unisim_fft_process_itr_fft[2];
      ctrlAnd_0_ln492_z = !input_ready & state_fft_unisim_fft_process_itr_fft[2];
      ctrlAnd_1_ln495_z = !input_ready & state_fft_unisim_fft_process_itr_fft[3];
      ctrlAnd_0_ln495_z = input_ready & state_fft_unisim_fft_process_itr_fft[3];
      ctrlOr_ln510_0_z = ctrlAnd_0_ln530_z | 
      state_fft_unisim_fft_process_itr_fft[4];
      ctrlAnd_0_ln613_z = lt_ln613_q & ctrlAnd_0_ln620_z;
      ctrlAnd_1_ln774_z = output_start & state_fft_unisim_fft_process_itr_fft[6];
      ctrlAnd_0_ln774_z = !output_start & 
      state_fft_unisim_fft_process_itr_fft[6];
      ctrlAnd_1_ln777_z = !output_start & 
      state_fft_unisim_fft_process_itr_fft[7];
      ctrlAnd_0_ln777_z = output_start & state_fft_unisim_fft_process_itr_fft[7];
      ctrlAnd_1_ln613_z = !lt_ln613_q & ctrlAnd_0_ln620_z;
      if (eq_ln549_Z_0_tag_0) 
        mux_akj32_ln549_z = memread_fft_A0_ln550_q;
      else 
        mux_akj32_ln549_z = C_bridge1_rtl_Q;
      if (eq_ln549_Z_0_tag_0) 
        mux_akjm32_ln549_z = A0_bridge1_rtl_Q;
      else 
        mux_akjm32_ln549_z = memread_fft_C_ln557_q;
      memread_fft_C_ln555_en = !eq_ln549_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[11];
      memwrite_fft_C_ln594_en = !eq_ln584_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[15];
      memwrite_fft_C_ln592_en = state_fft_unisim_fft_process_itr_fft[14] & !
      eq_ln584_Z_0_tag_0;
      if (state_fft_unisim_fft_process_itr_fft[1]) 
        mux_s_ln490_z = 32'h1;
      else 
        mux_s_ln490_z = mux_s_ln763_q;
      if (state_fft_unisim_fft_process_itr_fft[1]) 
        mux_windex_ln490_z = 22'h0;
      else 
        mux_windex_ln490_z = mux_windex_ln501_q;
      if (state_fft_unisim_fft_process_itr_fft[1]) 
        mux_wsplit_ln490_z = 96'h40000000;
      else 
        mux_wsplit_ln490_z = mux_wsplit_ln501_q;
      if (state_fft_unisim_fft_process_itr_fft[1]) 
        mux_index_ln490_z = 22'h0;
      else 
        mux_index_ln490_z = mux_index_ln763_q;
      if (state_fft_unisim_fft_process_itr_fft[8]) 
        mux_k_ln529_z = 32'h0;
      else 
        mux_k_ln529_z = add_ln529_q;
      if (state_fft_unisim_fft_process_itr_fft[10]) 
        mux_w_ln537_z = 96'h40000000;
      else 
        mux_w_ln537_z = {add_ln404_0_q, add_ln404_q};
      if (state_fft_unisim_fft_process_itr_fft[17]) 
        mux_k_0_ln613_z = 10'h0;
      else 
        mux_k_0_ln613_z = add_ln613_q;
      if (state_fft_unisim_fft_process_itr_fft[18]) 
        mux_w_0_ln619_z = 96'h40000000;
      else 
        mux_w_0_ln619_z = {add_ln404_2_q, add_ln404_1_q};
      if (state_fft_unisim_fft_process_itr_fft[25]) 
        mux_w_1_ln693_z = mux_wsplit_ln490_q;
      else 
        mux_w_1_ln693_z = {add_ln404_4_q, add_ln404_3_q};
      memread_fft_A1_ln639_en = !unary_or_ln631_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[20];
      memwrite_fft_B1_ln672_en = !unary_or_ln631_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[23];
      memwrite_fft_B1_ln674_en = !unary_or_ln631_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[24];
      if (unary_or_ln631_Z_0_tag_0) 
        mux_akj32_0_ln631_z = A0_bridge1_rtl_Q;
      else 
        mux_akj32_0_ln631_z = A1_bridge1_rtl_Q;
      if (unary_or_ln631_Z_0_tag_0) 
        mux_akjm32_0_ln631_z = A0_bridge1_rtl_Q;
      else 
        mux_akjm32_0_ln631_z = A1_bridge1_rtl_Q;
      memread_fft_A1_ln637_en = !unary_or_ln631_Z_0_tag_0 & ctrlAnd_1_ln620_z;
      memread_fft_A1_ln711_en = !unary_or_ln703_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[26];
      memwrite_fft_B1_ln744_en = !unary_or_ln703_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[29];
      memwrite_fft_B1_ln746_en = !unary_or_ln703_Z_0_tag_0 & 
      state_fft_unisim_fft_process_itr_fft[30];
      if (unary_or_ln703_Z_0_tag_0) 
        mux_akj32_1_ln703_z = A0_bridge1_rtl_Q;
      else 
        mux_akj32_1_ln703_z = A1_bridge1_rtl_Q;
      if (unary_or_ln703_Z_0_tag_0) 
        mux_akjm32_1_ln703_z = A0_bridge1_rtl_Q;
      else 
        mux_akjm32_1_ln703_z = A1_bridge1_rtl_Q;
      if (state_fft_unisim_fft_process_itr_fft[18]) 
        mux_j_0_ln619_z = 10'h0;
      else 
        mux_j_0_ln619_z = {add_ln619_1_q, !mux_j_0_ln619_q};
      if (state_fft_unisim_fft_process_itr_fft[25]) 
        mux_j_1_ln693_z = 9'h0;
      else 
        mux_j_1_ln693_z = {add_ln693_1_q[7:0], !mux_j_1_ln693_q[0]};
      if (state_fft_unisim_fft_process_itr_fft[10]) 
        mux_j_ln537_z = 10'h0;
      else 
        mux_j_ln537_z = {add_ln537_1_q, !mux_j_ln537_q};
      if (state_fft_unisim_fft_process_itr_fft[6]) 
        mux_mux_windex_ln501_Z_v = mux_windex_ln501_q;
      else 
        mux_mux_windex_ln501_Z_v = mux_windex_ln501_z;
      if (state_fft_unisim_fft_process_itr_fft[6]) 
        mux_mux_wsplit_ln501_Z_v = mux_wsplit_ln501_q[63:0];
      else 
        mux_mux_wsplit_ln501_Z_v = mux_wsplit_ln501_z[63:0];
      if (state_fft_unisim_fft_process_itr_fft[6]) 
        mux_mux_wsplit_ln501_Z_64_v_0 = mux_wsplit_ln501_q[95:64];
      else 
        mux_mux_wsplit_ln501_Z_64_v_0 = mux_wsplit_ln501_z[95:64];
      if (state_fft_unisim_fft_process_itr_fft[1]) 
        mux_ping_ln490_z = 8'hff;
      else 
        mux_ping_ln490_z = {!mux_ping_ln490_q[7], !mux_ping_ln490_q[6], !
        mux_ping_ln490_q[5], !mux_ping_ln490_q[4], !mux_ping_ln490_q[3], !
        mux_ping_ln490_q[2], !mux_ping_ln490_q[1], !mux_ping_ln490_q[0]};
      if (state_fft_unisim_fft_process_itr_fft[4]) 
        mux_s_ln510_z = 4'h1;
      else 
        mux_s_ln510_z = {add_ln510_1_q, !mux_s_ln510_q[0]};
      sub_ln196_8_z = $unsigned(mul_ln221_11_z) - $unsigned(mul_ln221_0_0_z);
      sub_ln196_9_z = $unsigned(mul_ln221_12_z) - $unsigned(mul_ln221_0_1_z);
      sub_ln196_10_z = $unsigned(mul_ln221_13_z) - $unsigned(mul_ln221_0_2_z);
      add_ln404_7_z = sub_ln196_5_z[45:14] + sub_ln196_5_z[13];
      add_ln404_5_z = add_ln176_8_z + add_ln404_17_z[13];
      add_ln404_8_z = sub_ln196_0_0_z[45:14] + sub_ln196_0_0_z[13];
      add_ln404_6_z = add_ln176_0_0_z + add_ln404_0_0_z[13];
      add_ln404_11_z = sub_ln196_6_z[45:14] + sub_ln196_6_z[13];
      add_ln404_9_z = add_ln176_9_z + add_ln404_18_z[13];
      add_ln404_12_z = sub_ln196_0_1_z[45:14] + sub_ln196_0_1_z[13];
      add_ln404_10_z = add_ln176_0_1_z + add_ln404_0_1_z[13];
      add_ln404_15_z = sub_ln196_7_z[45:14] + sub_ln196_7_z[13];
      add_ln404_13_z = add_ln176_10_z + add_ln404_19_z[13];
      add_ln404_16_z = sub_ln196_0_2_z[45:14] + sub_ln196_0_2_z[13];
      add_ln404_14_z = add_ln176_0_2_z + add_ln404_0_2_z[13];
      add_ln404_0_z = add_ln176_2_z + sub_ln196_z[29];
      add_ln404_2_z = add_ln176_3_z + sub_ln196_0_z[29];
      add_ln404_4_z = add_ln176_4_z + sub_ln196_1_z[29];
      add_ln404_z = sub_ln196_2_z[77:30] + sub_ln196_2_z[29];
      add_ln404_1_z = sub_ln196_3_z[77:30] + sub_ln196_3_z[29];
      add_ln404_3_z = sub_ln196_4_z[77:30] + sub_ln196_4_z[29];
      if (eq_ln763_Z_0_tag_0) 
        mux_s_ln763_z = add_ln764_z;
      else 
        mux_s_ln763_z = mux_s_ln501_z;
      ctrlOr_ln693_z = ctrlAnd_0_ln693_z | 
      state_fft_unisim_fft_process_itr_fft[25];
      ctrlAnd_1_ln501_z = !le_ln501_q & ctrlAnd_1_ln495_z;
      loop_start_hold = ~(ctrlAnd_1_ln495_z | ctrlAnd_1_ln492_z);
      ctrlAnd_0_ln501_z = le_ln501_q & ctrlAnd_1_ln495_z;
      ctrlOr_ln495_z = ctrlAnd_0_ln495_z | ctrlAnd_1_ln492_z;
      ctrlOr_ln613_z = ctrlAnd_0_ln613_z | 
      state_fft_unisim_fft_process_itr_fft[17];
      ctrlOr_ln490_z = ctrlAnd_1_ln777_z | 
      state_fft_unisim_fft_process_itr_fft[1];
      ctrlOr_ln777_z = ctrlAnd_0_ln777_z | ctrlAnd_1_ln774_z;
      ctrlOr_ln501_z = ctrlAnd_1_ln693_z | ctrlAnd_0_ln511_z | ctrlAnd_1_ln613_z;
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[12]: mux_akj32_ln549_d = 
          mux_akj32_ln549_z;
        state_fft_unisim_fft_process_itr_fft[13]: mux_akj32_ln549_d = 
          mux_akj32_ln549_q;
        default: mux_akj32_ln549_d = 64'hX;
      endcase
      C_bridge0_rtl_CE_en = memwrite_fft_C_ln594_en | memwrite_fft_C_ln592_en;
      case (mux_s_ln490_z[4:0])
        5'h0: lsh_ln608_z = 32'h1;
        5'h1: lsh_ln608_z = 32'h2;
        5'h2: lsh_ln608_z = 32'h4;
        5'h3: lsh_ln608_z = 32'h8;
        5'h4: lsh_ln608_z = 32'h10;
        5'h5: lsh_ln608_z = 32'h20;
        5'h6: lsh_ln608_z = 32'h40;
        5'h7: lsh_ln608_z = 32'h80;
        5'h8: lsh_ln608_z = 32'h100;
        5'h9: lsh_ln608_z = 32'h200;
        5'ha: lsh_ln608_z = 32'h400;
        5'hb: lsh_ln608_z = 32'h800;
        5'hc: lsh_ln608_z = 32'h1000;
        5'hd: lsh_ln608_z = 32'h2000;
        5'he: lsh_ln608_z = 32'h4000;
        5'hf: lsh_ln608_z = 32'h8000;
        5'h10: lsh_ln608_z = 32'h10000;
        5'h11: lsh_ln608_z = 32'h20000;
        5'h12: lsh_ln608_z = 32'h40000;
        5'h13: lsh_ln608_z = 32'h80000;
        5'h14: lsh_ln608_z = 32'h100000;
        5'h15: lsh_ln608_z = 32'h200000;
        5'h16: lsh_ln608_z = 32'h400000;
        5'h17: lsh_ln608_z = 32'h800000;
        5'h18: lsh_ln608_z = 32'h1000000;
        5'h19: lsh_ln608_z = 32'h2000000;
        5'h1a: lsh_ln608_z = 32'h4000000;
        5'h1b: lsh_ln608_z = 32'h8000000;
        5'h1c: lsh_ln608_z = 32'h10000000;
        5'h1d: lsh_ln608_z = 32'h20000000;
        5'h1e: lsh_ln608_z = 32'h40000000;
        5'h1f: lsh_ln608_z = 32'h80000000;
        default: lsh_ln608_z = 32'h0;
      endcase
      case (mux_s_ln490_z[4:0])
        5'h0: lsh_ln686_z = 32'h1;
        5'h1: lsh_ln686_z = 32'h2;
        5'h2: lsh_ln686_z = 32'h4;
        5'h3: lsh_ln686_z = 32'h8;
        5'h4: lsh_ln686_z = 32'h10;
        5'h5: lsh_ln686_z = 32'h20;
        5'h6: lsh_ln686_z = 32'h40;
        5'h7: lsh_ln686_z = 32'h80;
        5'h8: lsh_ln686_z = 32'h100;
        5'h9: lsh_ln686_z = 32'h200;
        5'ha: lsh_ln686_z = 32'h400;
        5'hb: lsh_ln686_z = 32'h800;
        5'hc: lsh_ln686_z = 32'h1000;
        5'hd: lsh_ln686_z = 32'h2000;
        5'he: lsh_ln686_z = 32'h4000;
        5'hf: lsh_ln686_z = 32'h8000;
        5'h10: lsh_ln686_z = 32'h10000;
        5'h11: lsh_ln686_z = 32'h20000;
        5'h12: lsh_ln686_z = 32'h40000;
        5'h13: lsh_ln686_z = 32'h80000;
        5'h14: lsh_ln686_z = 32'h100000;
        5'h15: lsh_ln686_z = 32'h200000;
        5'h16: lsh_ln686_z = 32'h400000;
        5'h17: lsh_ln686_z = 32'h800000;
        5'h18: lsh_ln686_z = 32'h1000000;
        5'h19: lsh_ln686_z = 32'h2000000;
        5'h1a: lsh_ln686_z = 32'h4000000;
        5'h1b: lsh_ln686_z = 32'h8000000;
        5'h1c: lsh_ln686_z = 32'h10000000;
        5'h1d: lsh_ln686_z = 32'h20000000;
        5'h1e: lsh_ln686_z = 32'h40000000;
        5'h1f: lsh_ln686_z = 32'h80000000;
        default: lsh_ln686_z = 32'h0;
      endcase
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_s_ln490_Z_v = mux_s_ln490_q;
      else 
        mux_mux_s_ln490_Z_v = mux_s_ln490_z;
      case (mux_s_ln490_z)
        32'h1: begin
            mux_mySin_ln47_0_z = 31'h5e;
            mux_myCos_ln24_0_z = 29'h10000000;
          end
        32'h2: begin
            mux_mySin_ln47_0_z = 31'h40000000;
            mux_myCos_ln24_0_z = 29'hfffffc0;
          end
        32'h3: begin
            mux_mySin_ln47_0_z = 31'h52bec340;
            mux_myCos_ln24_0_z = 29'h2bec360;
          end
        32'h4: begin
            mux_mySin_ln47_0_z = 31'h67821d40;
            mux_myCos_ln24_0_z = 29'h4df2860;
          end
        32'h5: begin
            mux_mySin_ln47_0_z = 31'h7383a3e0;
            mux_myCos_ln24_0_z = 29'h13ad060;
          end
        32'h6: begin
            mux_mySin_ln47_0_z = 31'h79ba1650;
            mux_myCos_ln24_0_z = 29'h4ee4b8;
          end
        32'h7: begin
            mux_mySin_ln47_0_z = 31'h7cdc1340;
            mux_myCos_ln24_0_z = 29'h13bc39;
          end
        32'h8: begin
            mux_mySin_ln47_0_z = 31'h7e6deaa0;
            mux_myCos_ln24_0_z = 29'h4ef3f;
          end
        32'h9: begin
            mux_mySin_ln47_0_z = 31'h7f36f170;
            mux_myCos_ln24_0_z = 29'h13bd3;
          end
        32'ha: begin
            mux_mySin_ln47_0_z = 31'h7f9b783c;
            mux_myCos_ln24_0_z = 29'h4ef5;
          end
        32'hb: begin
            mux_mySin_ln47_0_z = 31'h7fcdbc0f;
            mux_myCos_ln24_0_z = 29'h13bd;
          end
        32'hc: begin
            mux_mySin_ln47_0_z = 31'h7fe6de05;
            mux_myCos_ln24_0_z = 29'h4ef;
          end
        32'hd: begin
            mux_mySin_ln47_0_z = 31'h7ff36f02;
            mux_myCos_ln24_0_z = 29'h13c;
          end
        32'he: begin
            mux_mySin_ln47_0_z = 31'h7ff9b781;
            mux_myCos_ln24_0_z = 29'h4f;
          end
        32'hf: begin
            mux_mySin_ln47_0_z = 31'h7ffcdbc1;
            mux_myCos_ln24_0_z = 29'h14;
          end
        32'h10: begin
            mux_mySin_ln47_0_z = 31'h7ffe6de0;
            mux_myCos_ln24_0_z = 29'h5;
          end
        default: begin
            mux_mySin_ln47_0_z = 31'h0;
            mux_myCos_ln24_0_z = 29'h0;
          end
      endcase
      case (mux_s_ln490_z)
        32'h1: begin
            mux_mySin_ln47_1_z = 31'h5e;
            mux_myCos_ln24_1_z = 29'h10000000;
          end
        32'h2: begin
            mux_mySin_ln47_1_z = 31'h40000000;
            mux_myCos_ln24_1_z = 29'hfffffc0;
          end
        32'h3: begin
            mux_mySin_ln47_1_z = 31'h52bec340;
            mux_myCos_ln24_1_z = 29'h2bec360;
          end
        32'h4: begin
            mux_mySin_ln47_1_z = 31'h67821d40;
            mux_myCos_ln24_1_z = 29'h4df2860;
          end
        32'h5: begin
            mux_mySin_ln47_1_z = 31'h7383a3e0;
            mux_myCos_ln24_1_z = 29'h13ad060;
          end
        32'h6: begin
            mux_mySin_ln47_1_z = 31'h79ba1650;
            mux_myCos_ln24_1_z = 29'h4ee4b8;
          end
        32'h7: begin
            mux_mySin_ln47_1_z = 31'h7cdc1340;
            mux_myCos_ln24_1_z = 29'h13bc39;
          end
        32'h8: begin
            mux_mySin_ln47_1_z = 31'h7e6deaa0;
            mux_myCos_ln24_1_z = 29'h4ef3f;
          end
        32'h9: begin
            mux_mySin_ln47_1_z = 31'h7f36f170;
            mux_myCos_ln24_1_z = 29'h13bd3;
          end
        32'ha: begin
            mux_mySin_ln47_1_z = 31'h7f9b783c;
            mux_myCos_ln24_1_z = 29'h4ef5;
          end
        32'hb: begin
            mux_mySin_ln47_1_z = 31'h7fcdbc0f;
            mux_myCos_ln24_1_z = 29'h13bd;
          end
        32'hc: begin
            mux_mySin_ln47_1_z = 31'h7fe6de05;
            mux_myCos_ln24_1_z = 29'h4ef;
          end
        32'hd: begin
            mux_mySin_ln47_1_z = 31'h7ff36f02;
            mux_myCos_ln24_1_z = 29'h13c;
          end
        32'he: begin
            mux_mySin_ln47_1_z = 31'h7ff9b781;
            mux_myCos_ln24_1_z = 29'h4f;
          end
        32'hf: begin
            mux_mySin_ln47_1_z = 31'h7ffcdbc1;
            mux_myCos_ln24_1_z = 29'h14;
          end
        32'h10: begin
            mux_mySin_ln47_1_z = 31'h7ffe6de0;
            mux_myCos_ln24_1_z = 29'h5;
          end
        default: begin
            mux_mySin_ln47_1_z = 31'h0;
            mux_myCos_ln24_1_z = 29'h0;
          end
      endcase
      le_ln603_z = mux_s_ln490_z <= 32'ha;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_windex_ln490_Z_v = mux_windex_ln490_q;
      else 
        mux_mux_windex_ln490_Z_v = mux_windex_ln490_z;
      add_ln753_z = mux_windex_ln490_z + 22'h1;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_wsplit_ln490_Z_v = mux_wsplit_ln490_q[63:0];
      else 
        mux_mux_wsplit_ln490_Z_v = mux_wsplit_ln490_z[63:0];
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_wsplit_ln490_Z_64_v_0 = mux_wsplit_ln490_q[95:64];
      else 
        mux_mux_wsplit_ln490_Z_64_v_0 = mux_wsplit_ln490_z[95:64];
      add_ln762_z = mux_index_ln490_z + 22'h1;
      eq_ln530_z = mux_k_ln529_z == read_fft_len_ln483_q;
      lt_ln529_z = mux_k_ln529_z[31:10] == 22'h0;
      add_ln529_z = mux_k_ln529_z + lsh_ln514_q;
      mul_ln221_z = $signed(mux_w_ln537_z[95:48]) * $signed(mux_mySin_ln47_q);
      mul_ln221_1_z = $signed(mux_w_ln537_z[47:0]) * $signed(mux_mySin_ln47_q);
      mul_ln221_0_z = $signed(mux_w_ln537_z[47:0]) * $signed({1'sb0, 
      mux_myCos_ln24_q[28], 1'sb0, mux_myCos_ln24_q[27], mux_myCos_ln24_q[25], 
      mux_myCos_ln24_q[27:0]});
      mul_ln221_2_z = $signed(mux_w_ln537_z[95:48]) * $signed({1'sb0, 
      mux_myCos_ln24_q[28], 1'sb0, mux_myCos_ln24_q[27], mux_myCos_ln24_q[25], 
      mux_myCos_ln24_q[27:0]});
      add_ln613_z = lsh_ln608_q + mux_k_0_ln613_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln619_0_z: mux_w_0_ln619_d = mux_w_0_ln619_z[63:0];
        mux_w_0_ln619_sel: mux_w_0_ln619_d = mux_w_0_ln619_q[63:0];
        default: mux_w_0_ln619_d = 64'hX;
      endcase
      mul_ln221_3_z = $signed(mux_w_0_ln619_z[95:48]) * $signed(
      mux_mySin_ln47_0_q);
      mul_ln221_5_z = $signed(mux_w_0_ln619_z[47:0]) * $signed(
      mux_mySin_ln47_0_q);
      mul_ln221_4_z = $signed(mux_w_0_ln619_z[47:0]) * $signed({1'sb0, 
      mux_myCos_ln24_0_q[28], 1'sb0, mux_myCos_ln24_0_q[27], mux_myCos_ln24_0_q[
      25], mux_myCos_ln24_0_q[27:0]});
      mul_ln221_6_z = $signed(mux_w_0_ln619_z[95:48]) * $signed({1'sb0, 
      mux_myCos_ln24_0_q[28], 1'sb0, mux_myCos_ln24_0_q[27], mux_myCos_ln24_0_q[
      25], mux_myCos_ln24_0_q[27:0]});
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln619_0_z: mux_w_0_ln619_64_d_0 = mux_w_0_ln619_z[95:64];
        mux_w_0_ln619_sel: mux_w_0_ln619_64_d_0 = mux_w_0_ln619_q[95:64];
        default: mux_w_0_ln619_64_d_0 = 32'hX;
      endcase
      mul_ln221_7_z = $signed(mux_w_1_ln693_z[95:48]) * $signed(
      mux_mySin_ln47_1_q);
      mul_ln221_9_z = $signed(mux_w_1_ln693_z[47:0]) * $signed(
      mux_mySin_ln47_1_q);
      mul_ln221_8_z = $signed(mux_w_1_ln693_z[47:0]) * $signed({1'sb0, 
      mux_myCos_ln24_1_q[28], 1'sb0, mux_myCos_ln24_1_q[27], mux_myCos_ln24_1_q[
      25], mux_myCos_ln24_1_q[27:0]});
      mul_ln221_10_z = $signed(mux_w_1_ln693_z[95:48]) * $signed({1'sb0, 
      mux_myCos_ln24_1_q[28], 1'sb0, mux_myCos_ln24_1_q[27], mux_myCos_ln24_1_q[
      25], mux_myCos_ln24_1_q[27:0]});
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[20]: mux_akj32_0_ln631_d = 
          mux_akj32_0_ln631_z;
        mux_akj32_0_ln631_sel: mux_akj32_0_ln631_d = mux_akj32_0_ln631_q;
        default: mux_akj32_0_ln631_d = 64'hX;
      endcase
      B1_bridge0_rtl_CE_en = memwrite_fft_B1_ln746_en | memwrite_fft_B1_ln744_en | 
      memwrite_fft_B1_ln674_en | memwrite_fft_B1_ln672_en;
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[26]: mux_akj32_1_ln703_d = 
          mux_akj32_1_ln703_z;
        mux_akj32_1_ln703_sel: mux_akj32_1_ln703_d = mux_akj32_1_ln703_q;
        default: mux_akj32_1_ln703_d = 64'hX;
      endcase
      add_ln619_z = {1'b0, mux_j_0_ln619_z[8:0]} + 10'h1;
      eq_ln620_z = {21'h0, mux_j_0_ln619_z} == add_div_ln616_q;
      lt_ln619_z = ~mux_j_0_ln619_z[9];
      add_ln623_z = mux_k_0_ln613_q + mux_j_0_ln619_z;
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[19]: A1_bridge1_rtl_a = add_ln623_q;
        state_fft_unisim_fft_process_itr_fft[20]: A1_bridge1_rtl_a = 
          add_ln624_0_q;
        FFT_SPLIT_L3_for_begin_or_0: A1_bridge1_rtl_a = {1'b0, mux_j_1_ln693_z};
        state_fft_unisim_fft_process_itr_fft[26]: A1_bridge1_rtl_a = {1'b1, 
          mux_j_1_ln693_q};
        default: A1_bridge1_rtl_a = 10'hX;
      endcase
      add_ln693_z = {1'b0, mux_j_1_ln693_z} + 10'h1;
      add_ln537_z = {1'b0, mux_j_ln537_z[8:0]} + 10'h1;
      eq_ln538_z = {5'h0, mux_j_ln537_z} == lsh_ln514_q[15:1];
      lt_ln537_z = ~mux_j_ln537_z[9];
      add_ln541_z = mux_k_ln529_q + mux_j_ln537_z;
      unary_not_ln767_z = ~mux_ping_ln490_z;
      unary_or_ln631_z = |mux_ping_ln490_z;
      unary_or_ln703_z = |mux_ping_ln490_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_ping_ln490_Z_v = mux_ping_ln490_q;
      else 
        mux_mux_ping_ln490_Z_v = mux_ping_ln490_z;
      eq_ln549_z = mux_s_ln510_z == 4'h1;
      eq_ln584_z = mux_s_ln510_z == read_fft_log_len_ln484_q;
      gt_ln511_z = {1'b0, mux_s_ln510_z} > {1'b0, read_fft_log_len_ln484_q};
      le_ln510_z = mux_s_ln510_z <= 4'ha;
      case (mux_s_ln510_z)
        4'h0: lsh_ln514_z = 16'h1;
        4'h1: lsh_ln514_z = 16'h2;
        4'h2: lsh_ln514_z = 16'h4;
        4'h3: lsh_ln514_z = 16'h8;
        4'h4: lsh_ln514_z = 16'h10;
        4'h5: lsh_ln514_z = 16'h20;
        4'h6: lsh_ln514_z = 16'h40;
        4'h7: lsh_ln514_z = 16'h80;
        4'h8: lsh_ln514_z = 16'h100;
        4'h9: lsh_ln514_z = 16'h200;
        4'ha: lsh_ln514_z = 16'h400;
        4'hb: lsh_ln514_z = 16'h800;
        4'hc: lsh_ln514_z = 16'h1000;
        4'hd: lsh_ln514_z = 16'h2000;
        4'he: lsh_ln514_z = 16'h4000;
        4'hf: lsh_ln514_z = 16'h8000;
        default: lsh_ln514_z = 16'h0;
      endcase
      case (mux_s_ln510_z)
        4'h1: begin
            mux_mySin_ln47_z = 31'h5e;
            mux_myCos_ln24_z = 29'h10000000;
          end
        4'h2: begin
            mux_mySin_ln47_z = 31'h40000000;
            mux_myCos_ln24_z = 29'hfffffc0;
          end
        4'h3: begin
            mux_mySin_ln47_z = 31'h52bec340;
            mux_myCos_ln24_z = 29'h2bec360;
          end
        4'h4: begin
            mux_mySin_ln47_z = 31'h67821d40;
            mux_myCos_ln24_z = 29'h4df2860;
          end
        4'h5: begin
            mux_mySin_ln47_z = 31'h7383a3e0;
            mux_myCos_ln24_z = 29'h13ad060;
          end
        4'h6: begin
            mux_mySin_ln47_z = 31'h79ba1650;
            mux_myCos_ln24_z = 29'h4ee4b8;
          end
        4'h7: begin
            mux_mySin_ln47_z = 31'h7cdc1340;
            mux_myCos_ln24_z = 29'h13bc39;
          end
        4'h8: begin
            mux_mySin_ln47_z = 31'h7e6deaa0;
            mux_myCos_ln24_z = 29'h4ef3f;
          end
        4'h9: begin
            mux_mySin_ln47_z = 31'h7f36f170;
            mux_myCos_ln24_z = 29'h13bd3;
          end
        4'ha: begin
            mux_mySin_ln47_z = 31'h7f9b783c;
            mux_myCos_ln24_z = 29'h4ef5;
          end
        4'hb: begin
            mux_mySin_ln47_z = 31'h7fcdbc0f;
            mux_myCos_ln24_z = 29'h13bd;
          end
        4'hc: begin
            mux_mySin_ln47_z = 31'h7fe6de05;
            mux_myCos_ln24_z = 29'h4ef;
          end
        4'hd: begin
            mux_mySin_ln47_z = 31'h7ff36f02;
            mux_myCos_ln24_z = 29'h13c;
          end
        4'he: begin
            mux_mySin_ln47_z = 31'h7ff9b781;
            mux_myCos_ln24_z = 29'h4f;
          end
        4'hf: begin
            mux_mySin_ln47_z = 31'h7ffcdbc1;
            mux_myCos_ln24_z = 29'h14;
          end
        default: begin
            mux_mySin_ln47_z = 31'h0;
            mux_myCos_ln24_z = 29'h0;
          end
      endcase
      add_ln510_z = mux_s_ln510_z + 4'h1;
      if (state_fft_unisim_fft_process_itr_fft[14]) 
        C_bridge0_rtl_d = {add_ln404_6_z, add_ln404_5_z};
      else 
        C_bridge0_rtl_d = {add_ln404_8_q, add_ln404_7_q};
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[23]: B1_bridge0_rtl_d = {
          add_ln404_10_z, add_ln404_9_z};
        state_fft_unisim_fft_process_itr_fft[24]: B1_bridge0_rtl_d = {
          add_ln404_12_q, add_ln404_11_q};
        state_fft_unisim_fft_process_itr_fft[29]: B1_bridge0_rtl_d = {
          add_ln404_14_z, add_ln404_13_z};
        state_fft_unisim_fft_process_itr_fft[30]: B1_bridge0_rtl_d = {
          add_ln404_16_q, add_ln404_15_q};
        default: B1_bridge0_rtl_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[14]: B0_bridge0_rtl_d = {
          add_ln404_6_z, add_ln404_5_z};
        state_fft_unisim_fft_process_itr_fft[15]: B0_bridge0_rtl_d = {
          add_ln404_8_q, add_ln404_7_q};
        state_fft_unisim_fft_process_itr_fft[23]: B0_bridge0_rtl_d = {
          add_ln404_10_z, add_ln404_9_z};
        state_fft_unisim_fft_process_itr_fft[24]: B0_bridge0_rtl_d = {
          add_ln404_12_q, add_ln404_11_q};
        state_fft_unisim_fft_process_itr_fft[29]: B0_bridge0_rtl_d = {
          add_ln404_14_z, add_ln404_13_z};
        state_fft_unisim_fft_process_itr_fft[30]: B0_bridge0_rtl_d = {
          add_ln404_16_q, add_ln404_15_q};
        default: B0_bridge0_rtl_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[11]: add_ln404_16_d_0 = add_ln404_z
          [47:16];
        add_ln404_0_mux_0_sel: add_ln404_16_d_0 = add_ln404_q[47:16];
        default: add_ln404_16_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[11]: add_ln404_0_d_0 = {add_ln404_z
          [15:0], add_ln404_0_z};
        add_ln404_0_mux_0_sel: add_ln404_0_d_0 = {add_ln404_q[15:0], 
          add_ln404_0_q};
        default: add_ln404_0_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln620_z: add_ln404_2_d_0 = {add_ln404_1_z[15:0], add_ln404_2_z};
        add_ln404_2_mux_0_sel: add_ln404_2_d_0 = {add_ln404_1_q[15:0], 
          add_ln404_2_q};
        default: add_ln404_2_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln620_z: add_ln404_1_16_d_0 = add_ln404_1_z[47:16];
        add_ln404_2_mux_0_sel: add_ln404_1_16_d_0 = add_ln404_1_q[47:16];
        default: add_ln404_1_16_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[26]: add_ln404_4_d_0 = {
          add_ln404_3_z[15:0], add_ln404_4_z};
        add_ln404_4_mux_0_sel: add_ln404_4_d_0 = {add_ln404_3_q[15:0], 
          add_ln404_4_q};
        default: add_ln404_4_d_0 = 64'hX;
      endcase
      if (eq_ln754_q) 
        mux_wsplit_ln754_z = 96'h40000000;
      else 
        mux_wsplit_ln754_z = {add_ln404_4_z, add_ln404_3_z};
      if (state_fft_unisim_fft_process_itr_fft[6]) 
        mux_mux_s_ln763_Z_v = mux_s_ln763_q;
      else 
        mux_mux_s_ln763_Z_v = mux_s_ln763_z;
      memread_fft_A0_ln704_en = unary_or_ln703_Z_0_tag_0 & ctrlOr_ln693_z;
      memread_fft_A1_ln709_en = !unary_or_ln703_Z_0_tag_0 & ctrlOr_ln693_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln693_z: mux_j_1_ln693_1_d_0 = mux_j_1_ln693_z[8:1];
        mux_j_1_ln693_1_mux_0_sel: mux_j_1_ln693_1_d_0 = mux_j_1_ln693_q[8:1];
        default: mux_j_1_ln693_1_d_0 = 8'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln693_z: mux_w_1_ln693_64_d_0 = mux_w_1_ln693_z[95:64];
        mux_w_1_ln693_sel: mux_w_1_ln693_64_d_0 = mux_w_1_ln693_q[95:64];
        default: mux_w_1_ln693_64_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln693_z: mux_w_1_ln693_d = mux_w_1_ln693_z[63:0];
        mux_w_1_ln693_sel: mux_w_1_ln693_d = mux_w_1_ln693_q[63:0];
        default: mux_w_1_ln693_d = 64'hX;
      endcase
      ctrlAnd_1_ln603_z = !le_ln603_q & ctrlAnd_1_ln501_z;
      ctrlAnd_0_ln603_z = le_ln603_q & ctrlAnd_1_ln501_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln492_z: loop_start_d = 1'b1;
        ctrlAnd_1_ln495_z: loop_start_d = 1'b0;
        loop_start_hold: loop_start_d = loop_start;
        default: loop_start_d = 1'bX;
      endcase
      ctrlOr_ln492_z = ctrlAnd_0_ln492_z | ctrlOr_ln490_z;
      loop_done_hold = ~(ctrlOr_ln501_z | ctrlAnd_1_ln774_z);
      ctrlOr_ln774_z = ctrlAnd_0_ln774_z | ctrlOr_ln501_z;
      and_div_ln616_z = &{lsh_ln608_z[0], lsh_ln608_z[31]};
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_lsh_ln608_Z_v = lsh_ln608_q;
      else 
        mux_lsh_ln608_Z_v = lsh_ln608_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_myCos_ln24_0_Z_v = mux_myCos_ln24_0_q;
      else 
        mux_mux_myCos_ln24_0_Z_v = mux_myCos_ln24_0_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_mySin_ln47_0_Z_v = mux_mySin_ln47_0_q;
      else 
        mux_mux_mySin_ln47_0_Z_v = mux_mySin_ln47_0_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_myCos_ln24_1_Z_v = mux_myCos_ln24_1_q;
      else 
        mux_mux_myCos_ln24_1_Z_v = mux_myCos_ln24_1_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_mySin_ln47_1_Z_v = mux_mySin_ln47_1_q;
      else 
        mux_mux_mySin_ln47_1_Z_v = mux_mySin_ln47_1_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_le_ln603_Z_0_v = le_ln603_q;
      else 
        mux_le_ln603_Z_0_v = le_ln603_z;
      eq_ln754_z = {add_ln753_z, 10'h0} == lsh_ln686_z;
      eq_ln763_z = {add_ln762_z, 10'h0} == read_fft_len_ln483_q;
      if_ln530_z = ~eq_ln530_z;
      or_and_0_ln530_Z_0_z = !lt_ln529_z | eq_ln530_z;
      lt_ln613_z = add_ln613_z[31:10] == 22'h0;
      or_and_0_ln620_Z_0_z = mux_j_0_ln619_z[9] | eq_ln620_z;
      if_ln620_z = ~eq_ln620_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln619_0_z: add_ln623_d = add_ln623_z;
        add_ln623_sel: add_ln623_d = add_ln623_q;
        default: add_ln623_d = 10'hX;
      endcase
      add_ln624_0_z = add_div_ln616_q[9:0] + add_ln623_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln693_z: mux_j_1_ln693_d = {add_ln693_z[9:1], mux_j_1_ln693_z[0]};
        mux_j_1_ln693_sel: mux_j_1_ln693_d = {add_ln693_1_q, mux_j_1_ln693_q[0]};
        default: mux_j_1_ln693_d = 10'hX;
      endcase
      or_and_0_ln538_Z_0_z = mux_j_ln537_z[9] | eq_ln538_z;
      if_ln538_z = ~eq_ln538_z;
      add_ln542_0_z = lsh_ln514_q[10:1] + add_ln541_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln537_0_z: A0_bridge1_rtl_a = add_ln541_z;
        state_fft_unisim_fft_process_itr_fft[11]: A0_bridge1_rtl_a = 
          add_ln542_0_q;
        state_fft_unisim_fft_process_itr_fft[19]: A0_bridge1_rtl_a = add_ln623_q;
        state_fft_unisim_fft_process_itr_fft[20]: A0_bridge1_rtl_a = 
          add_ln624_0_q;
        FFT_SPLIT_L3_for_begin_or_0: A0_bridge1_rtl_a = {1'b0, mux_j_1_ln693_z};
        state_fft_unisim_fft_process_itr_fft[26]: A0_bridge1_rtl_a = {1'b1, 
          mux_j_1_ln693_q};
        default: A0_bridge1_rtl_a = 10'hX;
      endcase
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_unary_or_ln631_Z_0_v = unary_or_ln631_Z_0_tag_0;
      else 
        mux_unary_or_ln631_Z_0_v = unary_or_ln631_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_unary_or_ln703_Z_0_v = unary_or_ln703_Z_0_tag_0;
      else 
        mux_unary_or_ln703_Z_0_v = unary_or_ln703_z;
      if_ln511_z = ~gt_ln511_z;
      if_ln510_z = ~le_ln510_z;
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[26]: mux_wsplit_ln754_32_d_0 = 
          mux_wsplit_ln754_z[95:32];
        add_ln404_4_mux_0_sel: mux_wsplit_ln754_32_d_0 = mux_wsplit_ln754_q[95:
          32];
        default: mux_wsplit_ln754_32_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[26]: add_ln404_3_16_d_0 = {
          mux_wsplit_ln754_z[31:0], add_ln404_3_z[47:16]};
        add_ln404_4_mux_0_sel: add_ln404_3_16_d_0 = {mux_wsplit_ln754_q[31:0], 
          add_ln404_3_q[47:16]};
        default: add_ln404_3_16_d_0 = 64'hX;
      endcase
      A1_bridge1_rtl_CE_en = memread_fft_A1_ln711_en | memread_fft_A1_ln709_en | 
      memread_fft_A1_ln639_en | memread_fft_A1_ln637_en;
      unary_or_ln703_Z_0_tag_mux_0_sel = 
      state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | ctrlOr_ln693_z | ctrlOr_ln495_z | 
      ctrlAnd_1_ln603_z | state_fft_unisim_fft_process_itr_fft[30] | 
      state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26];
      lsh_ln608_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | ctrlOr_ln619_0_z | 
      ctrlOr_ln613_z | ctrlOr_ln495_z | ctrlAnd_1_ln620_z | ctrlAnd_0_ln603_z | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20];
      mux_s_ln490_sel = state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | ctrlOr_ln693_z | 
      ctrlOr_ln619_0_z | ctrlOr_ln613_z | ctrlOr_ln495_z | ctrlAnd_1_ln620_z | 
      ctrlAnd_1_ln603_z | ctrlAnd_0_ln603_z | 
      state_fft_unisim_fft_process_itr_fft[30] | 
      state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26] | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20];
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln501_z: loop_done_d = 1'b1;
        ctrlAnd_1_ln774_z: loop_done_d = 1'b0;
        loop_done_hold: loop_done_d = loop_done;
        default: loop_done_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln774_z: mux_s_ln763_10_d_0 = mux_mux_s_ln763_Z_v[31:10];
        ctrlOr_ln777_z: mux_s_ln763_10_d_0 = mux_s_ln763_q[31:10];
        default: mux_s_ln763_10_d_0 = 22'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln774_z: mux_windex_ln501_d = {mux_mux_wsplit_ln501_Z_v[41:0], 
          mux_mux_windex_ln501_Z_v};
        ctrlOr_ln777_z: mux_windex_ln501_d = {mux_wsplit_ln501_q[41:0], 
          mux_windex_ln501_q};
        default: mux_windex_ln501_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln774_z: mux_wsplit_ln501_42_d_0 = {mux_mux_s_ln763_Z_v[9:0], 
          mux_mux_wsplit_ln501_Z_64_v_0, mux_mux_wsplit_ln501_Z_v[63:42]};
        ctrlOr_ln777_z: mux_wsplit_ln501_42_d_0 = {mux_s_ln763_q[9:0], 
          mux_wsplit_ln501_q[95:42]};
        default: mux_wsplit_ln501_42_d_0 = 64'hX;
      endcase
      add_div_ln616_z = lsh_ln608_z[31:1] + and_div_ln616_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: le_ln603_d = mux_le_ln603_Z_0_v;
        ctrlOr_ln495_z: le_ln603_d = le_ln603_q;
        default: le_ln603_d = 1'bX;
      endcase
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_eq_ln754_Z_0_v = eq_ln754_q;
      else 
        mux_eq_ln754_Z_0_v = eq_ln754_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_eq_ln763_Z_0_v = eq_ln763_Z_0_tag_0;
      else 
        mux_eq_ln763_Z_0_v = eq_ln763_z;
      and_1_ln530_z = if_ln530_z & lt_ln529_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln613_z: mux_k_0_ln613_d = {lt_ln613_z, add_ln613_z[9:0], 
          mux_k_0_ln613_z};
        mux_k_0_ln613_sel: mux_k_0_ln613_d = {lt_ln613_q, add_ln613_q, 
          mux_k_0_ln613_q};
        default: mux_k_0_ln613_d = 21'hX;
      endcase
      and_1_ln620_z = if_ln620_z & lt_ln619_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln619_0_z: mux_j_0_ln619_d_0 = {add_ln624_0_z, add_ln619_z[9:1], 
          mux_j_0_ln619_z[0]};
        mux_j_0_ln619_mux_0_sel: mux_j_0_ln619_d_0 = {add_ln624_0_q, 
          add_ln619_1_q, mux_j_0_ln619_q};
        default: mux_j_0_ln619_d_0 = 20'hX;
      endcase
      ctrlAnd_0_ln538_z = or_and_0_ln538_Z_0_z & ctrlOr_ln537_0_z;
      and_1_ln538_z = if_ln538_z & lt_ln537_z;
      if (state_fft_unisim_fft_process_itr_fft[11]) 
        C_bridge1_rtl_a = add_ln541_q;
      else 
        C_bridge1_rtl_a = add_ln542_0_z;
      and_1_ln511_z = if_ln511_z & le_ln510_z;
      or_and_0_ln511_Z_0_z = if_ln510_z | gt_ln511_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: lsh_ln608_d = {mux_mux_mySin_ln47_0_Z_v[1:0], 
          mux_mux_myCos_ln24_0_Z_v, mux_unary_or_ln631_Z_0_v, mux_lsh_ln608_Z_v};
        lsh_ln608_sel: lsh_ln608_d = {mux_mySin_ln47_0_q[1:0], 
          mux_myCos_ln24_0_q, unary_or_ln631_Z_0_tag_0, lsh_ln608_q};
        default: lsh_ln608_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: mux_s_ln490_d = mux_mux_s_ln490_Z_v;
        mux_s_ln490_sel: mux_s_ln490_d = mux_s_ln490_q;
        default: mux_s_ln490_d = 32'hX;
      endcase
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_add_div_ln616_Z_v = add_div_ln616_q;
      else 
        mux_add_div_ln616_Z_v = add_div_ln616_z;
      if (eq_ln754_z) 
        mux_windex_ln754_z = 22'h0;
      else 
        mux_windex_ln754_z = add_ln753_z;
      if (eq_ln763_z) 
        mux_index_ln763_z = 22'h0;
      else 
        mux_index_ln763_z = add_ln762_z;
      ctrlOr_ln529_0_z = ctrlAnd_0_ln538_z | 
      state_fft_unisim_fft_process_itr_fft[8];
      ctrlAnd_1_ln538_z = and_1_ln538_z & ctrlOr_ln537_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: mux_mySin_ln47_0_2_d_0 = {mux_add_div_ln616_Z_v, 
          mux_mux_mySin_ln47_0_Z_v[30:2]};
        lsh_ln608_sel: mux_mySin_ln47_0_2_d_0 = {add_div_ln616_q, 
          mux_mySin_ln47_0_q[30:2]};
        default: mux_mySin_ln47_0_2_d_0 = 60'hX;
      endcase
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_windex_ln754_Z_v = mux_windex_ln754_q;
      else 
        mux_mux_windex_ln754_Z_v = mux_windex_ln754_z;
      if (state_fft_unisim_fft_process_itr_fft[2]) 
        mux_mux_index_ln763_Z_v = mux_index_ln763_q;
      else 
        mux_mux_index_ln763_Z_v = mux_index_ln763_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln538_z: add_ln541_d = add_ln541_z;
        add_ln541_sel: add_ln541_d = add_ln541_q;
        default: add_ln541_d = 10'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln538_z: add_ln542_0_d = add_ln542_0_z;
        add_ln542_0_sel: add_ln542_0_d = add_ln542_0_q;
        default: add_ln542_0_d = 10'hX;
      endcase
      eq_ln763_Z_0_tag_sel = state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | 
      state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | ctrlOr_ln693_z | 
      ctrlOr_ln619_0_z | ctrlOr_ln613_z | ctrlOr_ln529_0_z | ctrlOr_ln510_0_z | 
      ctrlOr_ln495_z | ctrlAnd_1_ln620_z | ctrlAnd_1_ln603_z | ctrlAnd_1_ln538_z | 
      ctrlAnd_1_ln530_z | ctrlAnd_1_ln511_z | ctrlAnd_0_ln603_z | 
      ctrlAnd_0_ln501_z | state_fft_unisim_fft_process_itr_fft[30] | 
      state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26] | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20] | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      memread_fft_A0_ln550_en = eq_ln549_Z_0_tag_0 & ctrlAnd_1_ln538_z;
      memread_fft_C_ln557_en = !eq_ln549_Z_0_tag_0 & ctrlAnd_1_ln538_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln538_z: mux_j_ln537_d_0 = {add_ln537_z[9:1], mux_j_ln537_z[0]};
        mux_j_ln537_mux_0_sel: mux_j_ln537_d_0 = {add_ln537_1_q, mux_j_ln537_q};
        default: mux_j_ln537_d_0 = 10'hX;
      endcase
      mux_k_ln529_sel = state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | ctrlAnd_1_ln538_z | 
      ctrlAnd_1_ln530_z | state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      mux_ping_ln490_sel = state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | 
      state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | ctrlOr_ln777_z | ctrlOr_ln774_z | 
      ctrlOr_ln693_z | ctrlOr_ln619_0_z | ctrlOr_ln613_z | ctrlOr_ln529_0_z | 
      ctrlOr_ln510_0_z | ctrlOr_ln495_z | ctrlAnd_1_ln620_z | ctrlAnd_1_ln603_z | 
      ctrlAnd_1_ln538_z | ctrlAnd_1_ln530_z | ctrlAnd_1_ln511_z | 
      ctrlAnd_0_ln603_z | ctrlAnd_0_ln501_z | 
      state_fft_unisim_fft_process_itr_fft[30] | 
      state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26] | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20] | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      mux_s_ln510_sel = state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | ctrlOr_ln529_0_z | 
      ctrlAnd_1_ln538_z | ctrlAnd_1_ln530_z | ctrlAnd_1_ln511_z | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln538_z: mux_w_ln537_64_d_0 = mux_w_ln537_z[95:64];
        mux_w_ln537_sel: mux_w_ln537_64_d_0 = mux_w_ln537_q[95:64];
        default: mux_w_ln537_64_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln538_z: mux_w_ln537_d = mux_w_ln537_z[63:0];
        mux_w_ln537_sel: mux_w_ln537_d = mux_w_ln537_q[63:0];
        default: mux_w_ln537_d = 64'hX;
      endcase
      mux_windex_ln490_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | 
      state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | ctrlOr_ln619_0_z | 
      ctrlOr_ln613_z | ctrlOr_ln529_0_z | ctrlOr_ln510_0_z | ctrlOr_ln495_z | 
      ctrlAnd_1_ln620_z | ctrlAnd_1_ln538_z | ctrlAnd_1_ln530_z | 
      ctrlAnd_1_ln511_z | ctrlAnd_0_ln603_z | ctrlAnd_0_ln501_z | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20] | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      mux_wsplit_ln490_sel = state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | 
      state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | ctrlOr_ln619_0_z | 
      ctrlOr_ln613_z | ctrlOr_ln529_0_z | ctrlOr_ln510_0_z | ctrlOr_ln495_z | 
      ctrlAnd_1_ln620_z | ctrlAnd_1_ln603_z | ctrlAnd_1_ln538_z | 
      ctrlAnd_1_ln530_z | ctrlAnd_1_ln511_z | ctrlAnd_0_ln603_z | 
      ctrlAnd_0_ln501_z | state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20] | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      read_fft_len_ln483_sel = state_fft_unisim_fft_process_itr_fft[29] | 
      state_fft_unisim_fft_process_itr_fft[28] | 
      state_fft_unisim_fft_process_itr_fft[22] | 
      state_fft_unisim_fft_process_itr_fft[23] | 
      state_fft_unisim_fft_process_itr_fft[13] | 
      state_fft_unisim_fft_process_itr_fft[14] | ctrlOr_ln777_z | ctrlOr_ln774_z | 
      ctrlOr_ln693_z | ctrlOr_ln619_0_z | ctrlOr_ln613_z | ctrlOr_ln529_0_z | 
      ctrlOr_ln510_0_z | ctrlOr_ln495_z | ctrlOr_ln492_z | ctrlAnd_1_ln620_z | 
      ctrlAnd_1_ln603_z | ctrlAnd_1_ln538_z | ctrlAnd_1_ln530_z | 
      ctrlAnd_1_ln511_z | ctrlAnd_0_ln603_z | ctrlAnd_0_ln501_z | 
      state_fft_unisim_fft_process_itr_fft[30] | 
      state_fft_unisim_fft_process_itr_fft[27] | 
      state_fft_unisim_fft_process_itr_fft[26] | 
      state_fft_unisim_fft_process_itr_fft[21] | 
      state_fft_unisim_fft_process_itr_fft[20] | 
      state_fft_unisim_fft_process_itr_fft[15] | 
      state_fft_unisim_fft_process_itr_fft[12] | 
      state_fft_unisim_fft_process_itr_fft[11];
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: unary_or_ln703_Z_0_tag_d_0 = {mux_mux_windex_ln754_Z_v[1:
          0], mux_mux_mySin_ln47_1_Z_v, mux_mux_myCos_ln24_1_Z_v, 
          mux_eq_ln754_Z_0_v, mux_unary_or_ln703_Z_0_v};
        unary_or_ln703_Z_0_tag_mux_0_sel: unary_or_ln703_Z_0_tag_d_0 = {
          mux_windex_ln754_q[1:0], mux_mySin_ln47_1_q, mux_myCos_ln24_1_q, 
          eq_ln754_q, unary_or_ln703_Z_0_tag_0};
        default: unary_or_ln703_Z_0_tag_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: mux_windex_ln754_2_d_0 = mux_mux_windex_ln754_Z_v[21:2];
        unary_or_ln703_Z_0_tag_mux_0_sel: mux_windex_ln754_2_d_0 = 
          mux_windex_ln754_q[21:2];
        default: mux_windex_ln754_2_d_0 = 20'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: eq_ln763_Z_0_tag_d = mux_eq_ln763_Z_0_v;
        eq_ln763_Z_0_tag_sel: eq_ln763_Z_0_tag_d = eq_ln763_Z_0_tag_0;
        default: eq_ln763_Z_0_tag_d = 1'bX;
      endcase
      A0_bridge1_rtl_CE_en = memread_fft_A0_ln706_en | memread_fft_A0_ln704_en | 
      memread_fft_A0_ln634_en | memread_fft_A0_ln632_en | 
      memread_fft_A0_ln552_en | memread_fft_A0_ln550_en;
      C_bridge1_rtl_CE_en = memread_fft_C_ln557_en | memread_fft_C_ln555_en;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln529_0_z: mux_k_ln529_d = {add_ln529_z, mux_k_ln529_z[9:0]};
        mux_k_ln529_sel: mux_k_ln529_d = {add_ln529_q, mux_k_ln529_q};
        default: mux_k_ln529_d = 42'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: mux_ping_ln490_d = {mux_mux_index_ln763_Z_v, 
          mux_mux_ping_ln490_Z_v};
        mux_ping_ln490_sel: mux_ping_ln490_d = {mux_index_ln763_q, 
          mux_ping_ln490_q};
        default: mux_ping_ln490_d = 30'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln510_0_z: mux_s_ln510_d = {mux_mySin_ln47_z[12:0], 
          mux_myCos_ln24_z, eq_ln584_z, eq_ln549_z, add_ln510_z[3:1], 
          lsh_ln514_z, mux_s_ln510_z[0]};
        mux_s_ln510_sel: mux_s_ln510_d = {mux_mySin_ln47_q[12:0], 
          mux_myCos_ln24_q, eq_ln584_Z_0_tag_0, eq_ln549_Z_0_tag_0, 
          add_ln510_1_q, lsh_ln514_q, mux_s_ln510_q[0]};
        default: mux_s_ln510_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln510_0_z: mux_mySin_ln47_13_d_0 = mux_mySin_ln47_z[30:13];
        mux_s_ln510_sel: mux_mySin_ln47_13_d_0 = mux_mySin_ln47_q[30:13];
        default: mux_mySin_ln47_13_d_0 = 18'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: mux_windex_ln490_d = mux_mux_windex_ln490_Z_v;
        mux_windex_ln490_sel: mux_windex_ln490_d = mux_windex_ln490_q;
        default: mux_windex_ln490_d = 22'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: mux_wsplit_ln490_d = mux_mux_wsplit_ln490_Z_v;
        mux_wsplit_ln490_sel: mux_wsplit_ln490_d = mux_wsplit_ln490_q[63:0];
        default: mux_wsplit_ln490_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln492_z: mux_wsplit_ln490_64_d_0 = mux_mux_wsplit_ln490_Z_64_v_0;
        mux_wsplit_ln490_sel: mux_wsplit_ln490_64_d_0 = mux_wsplit_ln490_q[95:64];
        default: mux_wsplit_ln490_64_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln477_z: read_fft_len_ln483_d = {le_ln501_z, log_len[3:0], len};
        read_fft_len_ln483_sel: read_fft_len_ln483_d = {le_ln501_q, 
          read_fft_log_len_ln484_q, read_fft_len_ln483_q};
        default: read_fft_len_ln483_d = 37'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_process_itr_fft[0]: // Wait_ln477
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln477_z: state_fft_unisim_fft_process_itr_fft_next[0] = 
                1'b1;
              ctrlAnd_1_ln477_z: state_fft_unisim_fft_process_itr_fft_next[1] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[1]: // expand_ln490
          state_fft_unisim_fft_process_itr_fft_next[2] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[2]: // Wait_ln492
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln492_z: state_fft_unisim_fft_process_itr_fft_next[2] = 
                1'b1;
              ctrlOr_ln495_z: state_fft_unisim_fft_process_itr_fft_next[3] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[3]: // Wait_ln495
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln495_z: state_fft_unisim_fft_process_itr_fft_next[3] = 
                1'b1;
              ctrlAnd_0_ln501_z: state_fft_unisim_fft_process_itr_fft_next[4] = 
                1'b1;
              ctrlAnd_0_ln603_z: state_fft_unisim_fft_process_itr_fft_next[17] = 
                1'b1;
              ctrlAnd_1_ln603_z: state_fft_unisim_fft_process_itr_fft_next[25] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[4]: // expand_ln510_0
          state_fft_unisim_fft_process_itr_fft_next[5] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[5]: // expand_ln510
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln774_z: state_fft_unisim_fft_process_itr_fft_next[6] = 
                1'b1;
              ctrlAnd_1_ln511_z: state_fft_unisim_fft_process_itr_fft_next[8] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[6]: // Wait_ln774
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln774_z: state_fft_unisim_fft_process_itr_fft_next[6] = 
                1'b1;
              ctrlOr_ln777_z: state_fft_unisim_fft_process_itr_fft_next[7] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[7]: // Wait_ln777
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln777_z: state_fft_unisim_fft_process_itr_fft_next[7] = 
                1'b1;
              ctrlOr_ln492_z: state_fft_unisim_fft_process_itr_fft_next[2] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[8]: // expand_ln529_0
          state_fft_unisim_fft_process_itr_fft_next[9] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[9]: // expand_ln529
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln510_0_z: state_fft_unisim_fft_process_itr_fft_next[5] = 
                1'b1;
              ctrlAnd_1_ln530_z: state_fft_unisim_fft_process_itr_fft_next[10] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[10]: // expand_ln537
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln529_0_z: state_fft_unisim_fft_process_itr_fft_next[9] = 
                1'b1;
              ctrlAnd_1_ln538_z: state_fft_unisim_fft_process_itr_fft_next[11] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[11]: // Wait_ln551
          state_fft_unisim_fft_process_itr_fft_next[12] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[12]: // Wait_ln553
          state_fft_unisim_fft_process_itr_fft_next[13] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[13]: // expand_ln553
          state_fft_unisim_fft_process_itr_fft_next[14] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[14]: // expand_ln553_0
          state_fft_unisim_fft_process_itr_fft_next[15] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[15]: // Wait_ln586
          state_fft_unisim_fft_process_itr_fft_next[16] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[16]: // Wait_ln588
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln529_0_z: state_fft_unisim_fft_process_itr_fft_next[9] = 
                1'b1;
              ctrlAnd_1_ln538_z: state_fft_unisim_fft_process_itr_fft_next[11] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[17]: // expand_ln613
          state_fft_unisim_fft_process_itr_fft_next[18] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[18]: // expand_ln619
          state_fft_unisim_fft_process_itr_fft_next[19] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[19]: // xformState_ln619
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln613_z: state_fft_unisim_fft_process_itr_fft_next[18] = 
                1'b1;
              ctrlOr_ln774_z: state_fft_unisim_fft_process_itr_fft_next[6] = 
                1'b1;
              ctrlAnd_1_ln620_z: state_fft_unisim_fft_process_itr_fft_next[20] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        state_fft_unisim_fft_process_itr_fft[20]: // Wait_ln633
          state_fft_unisim_fft_process_itr_fft_next[21] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[21]: // Wait_ln635
          state_fft_unisim_fft_process_itr_fft_next[22] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[22]: // expand_ln635
          state_fft_unisim_fft_process_itr_fft_next[23] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[23]: // expand_ln635_0
          state_fft_unisim_fft_process_itr_fft_next[24] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[24]: // Wait_ln666
          state_fft_unisim_fft_process_itr_fft_next[19] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[25]: // expand_ln693
          state_fft_unisim_fft_process_itr_fft_next[26] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[26]: // Wait_ln705
          state_fft_unisim_fft_process_itr_fft_next[27] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[27]: // Wait_ln707
          state_fft_unisim_fft_process_itr_fft_next[28] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[28]: // expand_ln707_0
          state_fft_unisim_fft_process_itr_fft_next[29] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[29]: // expand_ln707
          state_fft_unisim_fft_process_itr_fft_next[30] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[30]: // Wait_ln738
          state_fft_unisim_fft_process_itr_fft_next[31] = 1'b1;
        state_fft_unisim_fft_process_itr_fft[31]: // Wait_ln740
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln693_z: state_fft_unisim_fft_process_itr_fft_next[26] = 
                1'b1;
              ctrlOr_ln774_z: state_fft_unisim_fft_process_itr_fft_next[6] = 
                1'b1;
              default: state_fft_unisim_fft_process_itr_fft_next = 32'hX;
            endcase
          end
        default: // Don't care
          state_fft_unisim_fft_process_itr_fft_next = 32'hX;
      endcase
    end
  fft_unisim_identity_sync_read_1024x64m32 B0_bridge1(.rtl_CE(
                                           B0_bridge1_rtl_CE_en), .rtl_A(
                                           B0_bridge1_rtl_a), .mem_Q(B0_Q1), .CLK(
                                           clk), .mem_CE(B0_CE1), .mem_A(B0_A1), 
                                           .rtl_Q(B0_bridge1_rtl_Q));
  fft_unisim_identity_sync_read_1024x64m32 B1_bridge1(.rtl_CE(
                                           B1_bridge1_rtl_CE_en), .rtl_A(
                                           B1_bridge1_rtl_a), .mem_Q(B1_Q1), .CLK(
                                           clk), .mem_CE(B1_CE1), .mem_A(B1_A1), 
                                           .rtl_Q(B1_bridge1_rtl_Q));
  // synthesis sync_set_reset_local fft_unisim_fft_store_output_seq_block rst
  always @(posedge clk) // fft_unisim_fft_store_output_sequential
    begin : fft_unisim_fft_store_output_seq_block
      if (!rst) // Initialize state and outputs
      begin
        output_start <= 1'sb0;
        memread_fft_B0_ln362_q <= 64'sh0;
        mux_data_0_ln390_q <= 64'sh0;
        mux_data_1_ln420_q <= 64'sh0;
        mux_data_2_ln443_q <= 64'sh0;
        bufdout_set_valid_curr <= 1'sb0;
        mux_i_0_ln387_q <= 1'sb0;
        add_ln387_1_q <= 10'sh0;
        mux_i_1_ln417_q <= 1'sb0;
        add_ln417_1_q <= 9'sh0;
        wr_index <= 32'sh0;
        wr_length <= 32'sh0;
        wr_request <= 1'sb0;
        mux_i_2_ln440_q <= 1'sb0;
        add_ln440_1_q <= 10'sh0;
        bufdout_data <= 32'sh0;
        mux_i_ln358_q <= 1'sb0;
        add_ln358_1_q <= 10'sh0;
        dft_done <= 1'sb0;
        add_ln430_q <= 32'sh0;
        unary_or_ln390_Z_0_tag_0 <= 1'sb0;
        mux_base_ln331_q <= 32'sh0;
        and_1_ln375_q <= 1'sb0;
        mux_index_ln331_q <= 32'sh0;
        and_0_ln375_q <= 1'sb0;
        mux_s_ln400_q <= 32'sh0;
        mux_index_ln400_q <= 32'sh0;
        mux_ping_ln331_q <= 8'sh0;
        read_fft_len_ln327_q <= 32'sh0;
        read_fft_log_len_ln328_q <= 32'sh0;
        le_ln346_q <= 1'sb0;
        unary_or_ln420_Z_0_tag_0 <= 1'sb0;
        mux_index_ln459_q <= 32'sh0;
        mux_s_ln459_q <= 32'sh0;
        mux_base_ln459_q <= 32'sh0;
        state_fft_unisim_fft_store_output <= 25'h1;
      end
      else // Update Q values
      begin
        output_start <= output_start_d;
        memread_fft_B0_ln362_q <= {memread_fft_B0_ln362_32_d_0, 
        mux_memread_fft_B0_ln362_Q_v[31:0]};
        mux_data_0_ln390_q <= {mux_data_0_ln390_32_d_0, mux_mux_data_0_ln390_Z_v
        [31:0]};
        mux_data_1_ln420_q <= {mux_data_1_ln420_32_d_0, mux_mux_data_1_ln420_Z_v
        [31:0]};
        mux_data_2_ln443_q <= {mux_data_2_ln443_32_d_0, mux_mux_data_2_ln443_Z_v
        [31:0]};
        bufdout_set_valid_curr <= bufdout_set_valid_curr_d;
        mux_i_0_ln387_q <= mux_i_0_ln387_d_0[0];
        add_ln387_1_q <= mux_i_0_ln387_d_0[10:1];
        mux_i_1_ln417_q <= mux_i_1_ln417_d_0[0];
        add_ln417_1_q <= mux_i_1_ln417_d_0[9:1];
        wr_index <= wr_index_d;
        wr_length <= wr_length_d;
        wr_request <= wr_request_d;
        mux_i_2_ln440_q <= mux_i_2_ln440_d_0[0];
        add_ln440_1_q <= mux_i_2_ln440_d_0[10:1];
        bufdout_data <= bufdout_data_d;
        mux_i_ln358_q <= mux_i_ln358_d_0[0];
        add_ln358_1_q <= mux_i_ln358_d_0[10:1];
        dft_done <= dft_done_d;
        add_ln430_q <= add_ln430_d;
        unary_or_ln390_Z_0_tag_0 <= mux_base_ln331_d[32];
        mux_base_ln331_q <= mux_base_ln331_d[31:0];
        and_1_ln375_q <= mux_index_ln331_d[33];
        mux_index_ln331_q <= mux_index_ln331_d[31:0];
        and_0_ln375_q <= mux_index_ln331_d[32];
        mux_s_ln400_q <= mux_index_ln400_31_d_0[32:1];
        mux_index_ln400_q <= {mux_index_ln400_31_d_0[0], mux_base_ln331_d[63:33]};
        mux_ping_ln331_q <= mux_ping_ln331_d;
        read_fft_len_ln327_q <= {read_fft_len_ln327_31_d, read_fft_len_ln327_d[
        30:0]};
        read_fft_log_len_ln328_q <= read_fft_len_ln327_d[62:31];
        le_ln346_q <= read_fft_len_ln327_d[63];
        unary_or_ln420_Z_0_tag_0 <= unary_or_ln420_Z_0_tag_d_0[0];
        mux_index_ln459_q <= unary_or_ln420_Z_0_tag_d_0[32:1];
        mux_s_ln459_q <= {mux_s_ln459_31_d_0[0], unary_or_ln420_Z_0_tag_d_0[63:
        33]};
        mux_base_ln459_q <= mux_s_ln459_31_d_0[32:1];
        state_fft_unisim_fft_store_output <= 
        state_fft_unisim_fft_store_output_next;
      end
    end
  always @(*) begin : fft_unisim_fft_store_output_combinational
      reg STORE_SPLIT0_LOOP_for_begin_or_0;
      reg STORE_SPLIT1_LOOP_for_begin_or_0;
      reg STORE_MULTI_LOOP_for_begin_or_0;
      reg STORE_SINGLE_LOOP_for_exit_1_or_0;
      reg ctrlOr_ln272_2_z;
      reg ctrlOr_ln272_3_z;
      reg unary_nor_ln95_z;
      reg unary_nor_ln95_0_z;
      reg unary_nor_ln95_1_z;
      reg unary_nor_ln95_2_z;
      reg unary_nor_ln95_3_z;
      reg unary_nor_ln95_4_z;
      reg unary_nor_ln95_5_z;
      reg unary_nor_ln95_6_z;
      reg ctrlOr_ln272_z;
      reg ctrlOr_ln272_0_z;
      reg ctrlOr_ln272_1_z;
      reg ctrlOr_ln272_4_z;
      reg ctrlOr_ln272_5_z;
      reg ctrlOr_ln272_6_z;
      reg le_ln346_z;
      reg [31:0] mux_index_ln375_z;
      reg [31:0] mux_s_ln375_z;
      reg [31:0] mux_base_ln375_z;
      reg mux_data_1_ln420_32_mux_0_sel;
      reg memread_fft_B0_ln362_32_mux_0_sel;
      reg mux_data_0_ln390_32_mux_0_sel;
      reg mux_data_2_ln443_32_mux_0_sel;
      reg ctrlAnd_1_ln320_z;
      reg ctrlAnd_0_ln320_z;
      reg ctrlAnd_1_ln339_z;
      reg ctrlAnd_0_ln339_z;
      reg ctrlAnd_1_ln342_z;
      reg ctrlAnd_0_ln342_z;
      reg ctrlAnd_1_ln354_z;
      reg ctrlAnd_0_ln354_z;
      reg ctrlAnd_1_ln383_z;
      reg ctrlAnd_0_ln383_z;
      reg ctrlAnd_1_ln413_z;
      reg ctrlAnd_0_ln413_z;
      reg ctrlAnd_1_ln436_z;
      reg ctrlAnd_0_ln436_z;
      reg [31:0] mux_read_fft_len_ln327_Z_v;
      reg [31:0] mux_read_fft_log_len_ln328_Z_v;
      reg mux_le_ln346_Z_0_v;
      reg [63:0] mux_data_0_ln390_z;
      reg [63:0] mux_data_1_ln420_z;
      reg [63:0] mux_data_2_ln443_z;
      reg [9:0] mux_i_0_ln387_z;
      reg [8:0] mux_i_1_ln417_z;
      reg [9:0] mux_i_2_ln440_z;
      reg [10:0] mux_i_ln358_z;
      reg [7:0] mux_ping_ln331_z;
      reg [31:0] mux_s_ln331_z;
      reg [31:0] mux_base_ln331_z;
      reg [31:0] mux_index_ln331_z;
      reg ctrlAnd_0_ln375_z;
      reg ctrlAnd_1_ln375_z;
      reg output_start_hold;
      reg ctrlAnd_0_ln346_z;
      reg ctrlOr_ln342_z;
      reg wr_request_sel_0;
      reg [31:0] mux_read_fft_len_ln327_Z_0_mux_0_v;
      reg [31:0] mux_read_fft_log_len_ln328_Z_0_mux_0_v;
      reg mux_le_ln346_Z_0_v_0;
      reg mux_if_ln346_Z_1_v;
      reg [10:0] add_ln387_z;
      reg [9:0] add_ln417_z;
      reg [10:0] add_ln440_z;
      reg [10:0] add_ln358_z;
      reg eq_ln359_z;
      reg lt_ln358_z;
      reg [7:0] unary_not_ln466_z;
      reg unary_or_ln390_z;
      reg unary_or_ln420_z;
      reg [7:0] mux_mux_ping_ln331_Z_v;
      reg [31:0] add_ln460_z;
      reg gt_ln333_z;
      reg le_ln375_z;
      reg signed [31:0] lsh_ln454_z;
      reg [31:0] lsh_ln406_z;
      reg [31:0] add_ln401_z;
      reg [31:0] mux_mux_base_ln331_Z_v;
      reg [20:0] add_ln399_z;
      reg [31:0] mux_mux_index_ln331_Z_v;
      reg ctrlOr_ln383_z;
      reg wr_index_sel;
      reg ctrlOr_ln413_z;
      reg ctrlOr_ln354_z;
      reg [31:0] mux_read_fft_len_ln327_Z_0_mux_1_v;
      reg [31:0] mux_read_fft_log_len_ln328_Z_0_mux_1_v;
      reg ctrlAnd_1_ln272_0_z;
      reg ctrlAnd_0_ln272_0_z;
      reg ctrlAnd_1_ln272_1_z;
      reg ctrlAnd_0_ln272_1_z;
      reg ctrlAnd_1_ln272_2_z;
      reg ctrlAnd_0_ln272_2_z;
      reg ctrlAnd_1_ln272_3_z;
      reg ctrlAnd_0_ln272_3_z;
      reg ctrlAnd_1_ln272_4_z;
      reg ctrlAnd_0_ln272_4_z;
      reg ctrlAnd_1_ln272_5_z;
      reg ctrlAnd_0_ln272_5_z;
      reg ctrlAnd_1_ln272_6_z;
      reg ctrlAnd_0_ln272_6_z;
      reg ctrlAnd_1_ln272_z;
      reg ctrlAnd_0_ln272_z;
      reg mux_le_ln346_Z_0_v_1;
      reg or_and_0_ln359_Z_0_z;
      reg if_ln359_z;
      reg mux_unary_or_ln390_Z_0_v;
      reg mux_unary_or_ln420_Z_0_v;
      reg [7:0] mux_mux_ping_ln331_Z_0_mux_0_v;
      reg if_ln375_z;
      reg and_0_ln375_z;
      reg [31:0] add_ln454_z;
      reg [31:0] add_ln430_z;
      reg [31:0] mux_mux_base_ln331_Z_0_mux_0_v;
      reg eq_ln400_z;
      reg [31:0] mux_mux_index_ln331_Z_0_mux_0_v;
      reg ctrlOr_ln358_0_z;
      reg write_fft_bufdout_data_ln274_0_en;
      reg mux_i_ln358_mux_0_sel;
      reg write_fft_bufdout_data_ln274_1_en;
      reg ctrlAnd_0_ln387_z;
      reg ctrlAnd_1_ln387_z;
      reg write_fft_bufdout_data_ln274_2_en;
      reg mux_i_0_ln387_mux_0_sel;
      reg write_fft_bufdout_data_ln274_3_en;
      reg ctrlAnd_0_ln417_z;
      reg ctrlAnd_1_ln417_z;
      reg write_fft_bufdout_data_ln274_4_en;
      reg mux_i_1_ln417_mux_0_sel;
      reg write_fft_bufdout_data_ln274_5_en;
      reg ctrlAnd_0_ln440_z;
      reg ctrlAnd_1_ln440_z;
      reg write_fft_bufdout_data_ln274_6_en;
      reg mux_i_2_ln440_mux_0_sel;
      reg bufdout_set_valid_curr_hold;
      reg write_fft_bufdout_data_ln274_en;
      reg and_1_ln359_z;
      reg mux_unary_or_ln390_Z_0_v_0;
      reg mux_unary_or_ln420_Z_0_v_0;
      reg and_1_ln375_z;
      reg mux_and_0_ln375_Z_0_v;
      reg [31:0] mux_add_ln430_Z_v;
      reg [21:0] add_ln453_z;
      reg [31:0] mux_s_ln400_z;
      reg [31:0] mux_index_ln400_z;
      reg ctrlAnd_0_ln359_z;
      reg ctrlOr_ln387_z;
      reg ctrlOr_ln417_z;
      reg wr_index_hold;
      reg wr_length_sel;
      reg wr_request_hold;
      reg wr_request_sel;
      reg ctrlOr_ln436_z;
      reg ctrlOr_ln440_z;
      reg ctrlOr_ln375_z;
      reg bufdout_data_hold;
      reg ctrlAnd_1_ln359_z;
      reg mux_and_1_ln375_Z_0_v;
      reg mux_and_0_ln375_Z_0_v_0;
      reg [31:0] mux_add_ln430_Z_0_mux_0_v;
      reg [31:0] sub_ln457_z;
      reg eq_ln454_z;
      reg [31:0] mux_mux_index_ln400_Z_v;
      reg [31:0] mux_mux_s_ln400_Z_v;
      reg ctrlOr_ln370_z;
      reg memread_fft_B0_ln391_en;
      reg memread_fft_B1_ln393_en;
      reg mux_base_ln331_sel;
      reg add_ln430_sel;
      reg memread_fft_B0_ln421_en;
      reg memread_fft_B1_ln423_en;
      reg memread_fft_B0_ln444_en;
      reg memread_fft_B1_ln446_en;
      reg read_fft_len_ln327_sel;
      reg unary_or_ln420_Z_0_tag_mux_0_sel;
      reg ctrlOr_ln331_z;
      reg read_fft_len_ln327_31_sel;
      reg mux_and_1_ln375_Z_0_v_0;
      reg [31:0] mux_mux_index_ln400_Z_0_mux_0_v;
      reg [31:0] mux_mux_s_ln400_Z_0_mux_0_v;
      reg ctrlAnd_1_ln333_z;
      reg ctrlAnd_0_ln333_z;
      reg [31:0] mux_index_ln454_z;
      reg ctrlOr_ln333_z;
      reg dft_done_hold;
      reg dft_done_sel;
      reg eq_ln459_z;
      reg ctrlOr_ln339_z;
      reg [31:0] mux_index_ln459_z;
      reg [31:0] mux_s_ln459_z;
      reg [2:0] case_mux_base_ln459_z;
      reg [31:0] mux_mux_index_ln459_Z_v;
      reg [31:0] mux_mux_s_ln459_Z_v;
      reg [31:0] mux_base_ln459_z;
      reg [31:0] mux_mux_index_ln459_Z_0_mux_0_v;
      reg [31:0] mux_mux_s_ln459_Z_0_mux_0_v;
      reg [31:0] mux_mux_base_ln459_Z_v;
      reg [31:0] mux_mux_base_ln459_Z_0_mux_0_v;

      state_fft_unisim_fft_store_output_next = 25'h0;
      STORE_SPLIT0_LOOP_for_begin_or_0 = state_fft_unisim_fft_store_output[18] | 
      state_fft_unisim_fft_store_output[15] | 
      state_fft_unisim_fft_store_output[19];
      STORE_SPLIT1_LOOP_for_begin_or_0 = state_fft_unisim_fft_store_output[23] | 
      state_fft_unisim_fft_store_output[20] | 
      state_fft_unisim_fft_store_output[24];
      STORE_MULTI_LOOP_for_begin_or_0 = state_fft_unisim_fft_store_output[13] | 
      state_fft_unisim_fft_store_output[10] | 
      state_fft_unisim_fft_store_output[14];
      STORE_SINGLE_LOOP_for_exit_1_or_0 = state_fft_unisim_fft_store_output[8] | 
      state_fft_unisim_fft_store_output[4] | 
      state_fft_unisim_fft_store_output[9];
      ctrlOr_ln272_2_z = state_fft_unisim_fft_store_output[14] | 
      state_fft_unisim_fft_store_output[13];
      ctrlOr_ln272_3_z = state_fft_unisim_fft_store_output[17] | 
      state_fft_unisim_fft_store_output[16];
      unary_nor_ln95_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_0_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_1_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_2_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_3_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_4_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_5_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_6_z = ~bufdout_set_valid_curr;
      ctrlOr_ln272_z = state_fft_unisim_fft_store_output[7] | 
      state_fft_unisim_fft_store_output[6];
      ctrlOr_ln272_0_z = state_fft_unisim_fft_store_output[9] | 
      state_fft_unisim_fft_store_output[8];
      ctrlOr_ln272_1_z = state_fft_unisim_fft_store_output[12] | 
      state_fft_unisim_fft_store_output[11];
      ctrlOr_ln272_4_z = state_fft_unisim_fft_store_output[19] | 
      state_fft_unisim_fft_store_output[18];
      ctrlOr_ln272_5_z = state_fft_unisim_fft_store_output[22] | 
      state_fft_unisim_fft_store_output[21];
      ctrlOr_ln272_6_z = state_fft_unisim_fft_store_output[24] | 
      state_fft_unisim_fft_store_output[23];
      le_ln346_z = log_len <= 32'ha;
      if (state_fft_unisim_fft_store_output[6]) 
        mux_memread_fft_B0_ln362_Q_v = B0_bridge1_rtl_Q;
      else 
        mux_memread_fft_B0_ln362_Q_v = memread_fft_B0_ln362_q;
      if (ctrlOr_ln272_2_z) begin
        mux_index_ln375_z = mux_index_ln400_q;
        mux_s_ln375_z = mux_s_ln400_q;
        mux_base_ln375_z = mux_base_ln331_q;
      end
      else begin
        mux_index_ln375_z = mux_index_ln459_q;
        mux_s_ln375_z = mux_s_ln459_q;
        mux_base_ln375_z = mux_base_ln459_q;
      end
      mux_data_1_ln420_32_mux_0_sel = ctrlOr_ln272_3_z;
      memread_fft_B0_ln362_32_mux_0_sel = ctrlOr_ln272_z;
      mux_data_0_ln390_32_mux_0_sel = ctrlOr_ln272_1_z;
      mux_data_2_ln443_32_mux_0_sel = ctrlOr_ln272_5_z;
      ctrlAnd_1_ln320_z = init_done & state_fft_unisim_fft_store_output[0];
      ctrlAnd_0_ln320_z = !init_done & state_fft_unisim_fft_store_output[0];
      ctrlAnd_1_ln339_z = loop_done & state_fft_unisim_fft_store_output[2];
      ctrlAnd_0_ln339_z = !loop_done & state_fft_unisim_fft_store_output[2];
      ctrlAnd_1_ln342_z = !loop_done & state_fft_unisim_fft_store_output[3];
      ctrlAnd_0_ln342_z = loop_done & state_fft_unisim_fft_store_output[3];
      ctrlAnd_1_ln354_z = wr_grant & state_fft_unisim_fft_store_output[4];
      ctrlAnd_0_ln354_z = !wr_grant & state_fft_unisim_fft_store_output[4];
      ctrlAnd_1_ln383_z = wr_grant & state_fft_unisim_fft_store_output[10];
      ctrlAnd_0_ln383_z = !wr_grant & state_fft_unisim_fft_store_output[10];
      ctrlAnd_1_ln413_z = wr_grant & state_fft_unisim_fft_store_output[15];
      ctrlAnd_0_ln413_z = !wr_grant & state_fft_unisim_fft_store_output[15];
      ctrlAnd_1_ln436_z = wr_grant & state_fft_unisim_fft_store_output[20];
      ctrlAnd_0_ln436_z = !wr_grant & state_fft_unisim_fft_store_output[20];
      if (state_fft_unisim_fft_store_output[0]) 
        mux_read_fft_len_ln327_Z_v = len;
      else 
        mux_read_fft_len_ln327_Z_v = read_fft_len_ln327_q;
      if (state_fft_unisim_fft_store_output[0]) 
        mux_read_fft_log_len_ln328_Z_v = log_len;
      else 
        mux_read_fft_log_len_ln328_Z_v = read_fft_log_len_ln328_q;
      if (state_fft_unisim_fft_store_output[0]) 
        mux_le_ln346_Z_0_v = le_ln346_z;
      else 
        mux_le_ln346_Z_0_v = le_ln346_q;
      if (unary_or_ln390_Z_0_tag_0) 
        mux_data_0_ln390_z = B0_bridge1_rtl_Q;
      else 
        mux_data_0_ln390_z = B1_bridge1_rtl_Q;
      if (unary_or_ln420_Z_0_tag_0) 
        mux_data_1_ln420_z = B0_bridge1_rtl_Q;
      else 
        mux_data_1_ln420_z = B1_bridge1_rtl_Q;
      if (unary_or_ln420_Z_0_tag_0) 
        mux_data_2_ln443_z = B0_bridge1_rtl_Q;
      else 
        mux_data_2_ln443_z = B1_bridge1_rtl_Q;
      if (state_fft_unisim_fft_store_output[10]) 
        mux_i_0_ln387_z = 10'h0;
      else 
        mux_i_0_ln387_z = {add_ln387_1_q[8:0], !mux_i_0_ln387_q};
      if (state_fft_unisim_fft_store_output[15]) 
        mux_i_1_ln417_z = 9'h0;
      else 
        mux_i_1_ln417_z = {add_ln417_1_q[7:0], !mux_i_1_ln417_q};
      if (state_fft_unisim_fft_store_output[20]) 
        mux_i_2_ln440_z = 10'h200;
      else 
        mux_i_2_ln440_z = {add_ln440_1_q[8:0], !mux_i_2_ln440_q};
      if (state_fft_unisim_fft_store_output[4]) 
        mux_i_ln358_z = 11'h0;
      else 
        mux_i_ln358_z = {add_ln358_1_q, !mux_i_ln358_q};
      if (state_fft_unisim_fft_store_output[0]) 
        mux_ping_ln331_z = 8'hff;
      else 
        mux_ping_ln331_z = {!mux_ping_ln331_q[7], !mux_ping_ln331_q[6], !
        mux_ping_ln331_q[5], !mux_ping_ln331_q[4], !mux_ping_ln331_q[3], !
        mux_ping_ln331_q[2], !mux_ping_ln331_q[1], !mux_ping_ln331_q[0]};
      if (state_fft_unisim_fft_store_output[0]) 
        mux_s_ln331_z = 32'h1;
      else 
        mux_s_ln331_z = mux_s_ln375_z;
      if (state_fft_unisim_fft_store_output[0]) 
        mux_base_ln331_z = 32'h0;
      else 
        mux_base_ln331_z = mux_base_ln375_z;
      if (state_fft_unisim_fft_store_output[0]) 
        mux_index_ln331_z = 32'h0;
      else 
        mux_index_ln331_z = mux_index_ln375_z;
      ctrlAnd_0_ln375_z = and_0_ln375_q & ctrlAnd_1_ln342_z;
      ctrlAnd_1_ln375_z = and_1_ln375_q & ctrlAnd_1_ln342_z;
      output_start_hold = ~(ctrlAnd_1_ln342_z | ctrlAnd_1_ln339_z);
      ctrlAnd_0_ln346_z = le_ln346_q & ctrlAnd_1_ln342_z;
      ctrlOr_ln342_z = ctrlAnd_0_ln342_z | ctrlAnd_1_ln339_z;
      wr_request_sel_0 = ctrlAnd_1_ln436_z | ctrlAnd_1_ln413_z | 
      ctrlAnd_1_ln383_z | ctrlAnd_1_ln354_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_read_fft_len_ln327_Z_0_mux_0_v = read_fft_len_ln327_q;
      else 
        mux_read_fft_len_ln327_Z_0_mux_0_v = mux_read_fft_len_ln327_Z_v;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_read_fft_log_len_ln328_Z_0_mux_0_v = read_fft_log_len_ln328_q;
      else 
        mux_read_fft_log_len_ln328_Z_0_mux_0_v = mux_read_fft_log_len_ln328_Z_v;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_le_ln346_Z_0_v_0 = le_ln346_q;
      else 
        mux_le_ln346_Z_0_v_0 = mux_le_ln346_Z_0_v;
      if (state_fft_unisim_fft_store_output[0]) 
        mux_if_ln346_Z_1_v = !le_ln346_z;
      else 
        mux_if_ln346_Z_1_v = !le_ln346_q;
      if (state_fft_unisim_fft_store_output[11]) 
        mux_mux_data_0_ln390_Z_v = mux_data_0_ln390_z;
      else 
        mux_mux_data_0_ln390_Z_v = mux_data_0_ln390_q;
      if (state_fft_unisim_fft_store_output[16]) 
        mux_mux_data_1_ln420_Z_v = mux_data_1_ln420_z;
      else 
        mux_mux_data_1_ln420_Z_v = mux_data_1_ln420_q;
      if (state_fft_unisim_fft_store_output[21]) 
        mux_mux_data_2_ln443_Z_v = mux_data_2_ln443_z;
      else 
        mux_mux_data_2_ln443_Z_v = mux_data_2_ln443_q;
      add_ln387_z = {1'b0, mux_i_0_ln387_z} + 11'h1;
      add_ln417_z = {1'b0, mux_i_1_ln417_z} + 10'h1;
      case (1'b1)// synthesis parallel_case
        STORE_SPLIT0_LOOP_for_begin_or_0: B1_bridge1_rtl_a = {1'b0, 
          mux_i_1_ln417_z};
        STORE_SPLIT1_LOOP_for_begin_or_0: B1_bridge1_rtl_a = mux_i_2_ln440_z;
        STORE_MULTI_LOOP_for_begin_or_0: B1_bridge1_rtl_a = mux_i_0_ln387_z;
        default: B1_bridge1_rtl_a = 10'hX;
      endcase
      add_ln440_z = {1'b0, mux_i_2_ln440_z} + 11'h1;
      add_ln358_z = {1'b0, mux_i_ln358_z[9:0]} + 11'h1;
      eq_ln359_z = {21'h0, mux_i_ln358_z} == {read_fft_len_ln327_q[31], 
      wr_length[31:1]};
      lt_ln358_z = ~mux_i_ln358_z[10];
      case (1'b1)// synthesis parallel_case
        STORE_SPLIT0_LOOP_for_begin_or_0: B0_bridge1_rtl_a = {1'b0, 
          mux_i_1_ln417_z};
        STORE_SPLIT1_LOOP_for_begin_or_0: B0_bridge1_rtl_a = mux_i_2_ln440_z;
        STORE_MULTI_LOOP_for_begin_or_0: B0_bridge1_rtl_a = mux_i_0_ln387_z;
        STORE_SINGLE_LOOP_for_exit_1_or_0: B0_bridge1_rtl_a = mux_i_ln358_z[9:0];
        default: B0_bridge1_rtl_a = 10'hX;
      endcase
      unary_not_ln466_z = ~mux_ping_ln331_z;
      unary_or_ln390_z = |mux_ping_ln331_z;
      unary_or_ln420_z = |mux_ping_ln331_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_ping_ln331_Z_v = mux_ping_ln331_q;
      else 
        mux_mux_ping_ln331_Z_v = mux_ping_ln331_z;
      add_ln460_z = mux_s_ln331_z + 32'h1;
      gt_ln333_z = {1'b0, mux_s_ln331_z} > {1'b0, mux_read_fft_log_len_ln328_Z_v};
      le_ln375_z = mux_s_ln331_z <= 32'ha;
      lsh_ln454_z = 3'sh2 << mux_s_ln331_z[4:0];
      case (mux_s_ln331_z[4:0])
        5'h0: lsh_ln406_z = 32'h1;
        5'h1: lsh_ln406_z = 32'h2;
        5'h2: lsh_ln406_z = 32'h4;
        5'h3: lsh_ln406_z = 32'h8;
        5'h4: lsh_ln406_z = 32'h10;
        5'h5: lsh_ln406_z = 32'h20;
        5'h6: lsh_ln406_z = 32'h40;
        5'h7: lsh_ln406_z = 32'h80;
        5'h8: lsh_ln406_z = 32'h100;
        5'h9: lsh_ln406_z = 32'h200;
        5'ha: lsh_ln406_z = 32'h400;
        5'hb: lsh_ln406_z = 32'h800;
        5'hc: lsh_ln406_z = 32'h1000;
        5'hd: lsh_ln406_z = 32'h2000;
        5'he: lsh_ln406_z = 32'h4000;
        5'hf: lsh_ln406_z = 32'h8000;
        5'h10: lsh_ln406_z = 32'h10000;
        5'h11: lsh_ln406_z = 32'h20000;
        5'h12: lsh_ln406_z = 32'h40000;
        5'h13: lsh_ln406_z = 32'h80000;
        5'h14: lsh_ln406_z = 32'h100000;
        5'h15: lsh_ln406_z = 32'h200000;
        5'h16: lsh_ln406_z = 32'h400000;
        5'h17: lsh_ln406_z = 32'h800000;
        5'h18: lsh_ln406_z = 32'h1000000;
        5'h19: lsh_ln406_z = 32'h2000000;
        5'h1a: lsh_ln406_z = 32'h4000000;
        5'h1b: lsh_ln406_z = 32'h8000000;
        5'h1c: lsh_ln406_z = 32'h10000000;
        5'h1d: lsh_ln406_z = 32'h20000000;
        5'h1e: lsh_ln406_z = 32'h40000000;
        5'h1f: lsh_ln406_z = 32'h80000000;
        default: lsh_ln406_z = 32'h0;
      endcase
      add_ln401_z = mux_s_ln331_z + 32'h1;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_base_ln331_Z_v = mux_base_ln331_q;
      else 
        mux_mux_base_ln331_Z_v = mux_base_ln331_z;
      add_ln399_z = mux_index_ln331_z[31:11] + 21'h1;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_index_ln331_Z_v = mux_index_ln331_q;
      else 
        mux_mux_index_ln331_Z_v = mux_index_ln331_z;
      ctrlOr_ln383_z = ctrlAnd_0_ln383_z | ctrlAnd_0_ln375_z;
      wr_index_sel = ctrlAnd_1_ln375_z | ctrlAnd_0_ln375_z;
      ctrlOr_ln413_z = ctrlAnd_0_ln413_z | ctrlAnd_1_ln375_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln339_z: output_start_d = 1'b1;
        ctrlAnd_1_ln342_z: output_start_d = 1'b0;
        output_start_hold: output_start_d = output_start;
        default: output_start_d = 1'bX;
      endcase
      ctrlOr_ln354_z = ctrlAnd_0_ln354_z | ctrlAnd_0_ln346_z;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_read_fft_len_ln327_Z_0_mux_1_v = read_fft_len_ln327_q;
      else 
        mux_read_fft_len_ln327_Z_0_mux_1_v = mux_read_fft_len_ln327_Z_0_mux_0_v;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_read_fft_log_len_ln328_Z_0_mux_1_v = read_fft_log_len_ln328_q;
      else 
        mux_read_fft_log_len_ln328_Z_0_mux_1_v = 
        mux_read_fft_log_len_ln328_Z_0_mux_0_v;
      ctrlAnd_1_ln272_0_z = bufdout_can_put_sig & ctrlOr_ln272_0_z;
      ctrlAnd_0_ln272_0_z = !bufdout_can_put_sig & ctrlOr_ln272_0_z;
      ctrlAnd_1_ln272_1_z = bufdout_can_put_sig & ctrlOr_ln272_1_z;
      ctrlAnd_0_ln272_1_z = !bufdout_can_put_sig & ctrlOr_ln272_1_z;
      ctrlAnd_1_ln272_2_z = bufdout_can_put_sig & ctrlOr_ln272_2_z;
      ctrlAnd_0_ln272_2_z = !bufdout_can_put_sig & ctrlOr_ln272_2_z;
      ctrlAnd_1_ln272_3_z = bufdout_can_put_sig & ctrlOr_ln272_3_z;
      ctrlAnd_0_ln272_3_z = !bufdout_can_put_sig & ctrlOr_ln272_3_z;
      ctrlAnd_1_ln272_4_z = bufdout_can_put_sig & ctrlOr_ln272_4_z;
      ctrlAnd_0_ln272_4_z = !bufdout_can_put_sig & ctrlOr_ln272_4_z;
      ctrlAnd_1_ln272_5_z = bufdout_can_put_sig & ctrlOr_ln272_5_z;
      ctrlAnd_0_ln272_5_z = !bufdout_can_put_sig & ctrlOr_ln272_5_z;
      ctrlAnd_1_ln272_6_z = bufdout_can_put_sig & ctrlOr_ln272_6_z;
      ctrlAnd_0_ln272_6_z = !bufdout_can_put_sig & ctrlOr_ln272_6_z;
      ctrlAnd_1_ln272_z = bufdout_can_put_sig & ctrlOr_ln272_z;
      ctrlAnd_0_ln272_z = !bufdout_can_put_sig & ctrlOr_ln272_z;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_le_ln346_Z_0_v_1 = le_ln346_q;
      else 
        mux_le_ln346_Z_0_v_1 = mux_le_ln346_Z_0_v_0;
      or_and_0_ln359_Z_0_z = mux_i_ln358_z[10] | eq_ln359_z;
      if_ln359_z = ~eq_ln359_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_unary_or_ln390_Z_0_v = unary_or_ln390_Z_0_tag_0;
      else 
        mux_unary_or_ln390_Z_0_v = unary_or_ln390_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_unary_or_ln420_Z_0_v = unary_or_ln420_Z_0_tag_0;
      else 
        mux_unary_or_ln420_Z_0_v = unary_or_ln420_z;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_ping_ln331_Z_0_mux_0_v = mux_ping_ln331_q;
      else 
        mux_mux_ping_ln331_Z_0_mux_0_v = mux_mux_ping_ln331_Z_v;
      if_ln375_z = ~le_ln375_z;
      and_0_ln375_z = le_ln375_z & mux_if_ln346_Z_1_v;
      add_ln454_z = mux_base_ln331_z + $unsigned(lsh_ln454_z);
      add_ln430_z = mux_index_ln331_z + lsh_ln406_z;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_base_ln331_Z_0_mux_0_v = mux_base_ln331_q;
      else 
        mux_mux_base_ln331_Z_0_mux_0_v = mux_mux_base_ln331_Z_v;
      eq_ln400_z = {add_ln399_z, mux_index_ln331_z[10:0]} == {
      mux_read_fft_len_ln327_Z_v[30:0], 1'b0};
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_index_ln331_Z_0_mux_0_v = mux_index_ln331_q;
      else 
        mux_mux_index_ln331_Z_0_mux_0_v = mux_mux_index_ln331_Z_v;
      ctrlOr_ln358_0_z = ctrlAnd_1_ln272_0_z | ctrlAnd_1_ln354_z;
      write_fft_bufdout_data_ln274_0_en = rst & ctrlAnd_1_ln272_0_z;
      case (1'b1)// synthesis parallel_case
        memread_fft_B0_ln362_32_mux_0_sel: memread_fft_B0_ln362_32_d_0 = 
          mux_memread_fft_B0_ln362_Q_v[63:32];
        ctrlAnd_0_ln272_0_z: memread_fft_B0_ln362_32_d_0 = 
          memread_fft_B0_ln362_q[63:32];
        default: memread_fft_B0_ln362_32_d_0 = 32'hX;
      endcase
      mux_i_ln358_mux_0_sel = ctrlOr_ln272_z | ctrlAnd_0_ln272_0_z;
      write_fft_bufdout_data_ln274_1_en = rst & ctrlAnd_1_ln272_1_z;
      ctrlAnd_0_ln387_z = !add_ln387_1_q[9] & ctrlAnd_1_ln272_2_z;
      ctrlAnd_1_ln387_z = add_ln387_1_q[9] & ctrlAnd_1_ln272_2_z;
      write_fft_bufdout_data_ln274_2_en = rst & ctrlAnd_1_ln272_2_z;
      case (1'b1)// synthesis parallel_case
        mux_data_0_ln390_32_mux_0_sel: mux_data_0_ln390_32_d_0 = 
          mux_mux_data_0_ln390_Z_v[63:32];
        ctrlAnd_0_ln272_2_z: mux_data_0_ln390_32_d_0 = mux_data_0_ln390_q[63:32];
        default: mux_data_0_ln390_32_d_0 = 32'hX;
      endcase
      mux_i_0_ln387_mux_0_sel = ctrlOr_ln272_1_z | ctrlAnd_0_ln272_2_z;
      write_fft_bufdout_data_ln274_3_en = rst & ctrlAnd_1_ln272_3_z;
      ctrlAnd_0_ln417_z = !add_ln417_1_q[8] & ctrlAnd_1_ln272_4_z;
      ctrlAnd_1_ln417_z = add_ln417_1_q[8] & ctrlAnd_1_ln272_4_z;
      write_fft_bufdout_data_ln274_4_en = rst & ctrlAnd_1_ln272_4_z;
      case (1'b1)// synthesis parallel_case
        mux_data_1_ln420_32_mux_0_sel: mux_data_1_ln420_32_d_0 = 
          mux_mux_data_1_ln420_Z_v[63:32];
        ctrlAnd_0_ln272_4_z: mux_data_1_ln420_32_d_0 = mux_data_1_ln420_q[63:32];
        default: mux_data_1_ln420_32_d_0 = 32'hX;
      endcase
      mux_i_1_ln417_mux_0_sel = ctrlOr_ln272_3_z | ctrlAnd_0_ln272_4_z;
      write_fft_bufdout_data_ln274_5_en = rst & ctrlAnd_1_ln272_5_z;
      ctrlAnd_0_ln440_z = !add_ln440_1_q[9] & ctrlAnd_1_ln272_6_z;
      ctrlAnd_1_ln440_z = add_ln440_1_q[9] & ctrlAnd_1_ln272_6_z;
      write_fft_bufdout_data_ln274_6_en = rst & ctrlAnd_1_ln272_6_z;
      case (1'b1)// synthesis parallel_case
        mux_data_2_ln443_32_mux_0_sel: mux_data_2_ln443_32_d_0 = 
          mux_mux_data_2_ln443_Z_v[63:32];
        ctrlAnd_0_ln272_6_z: mux_data_2_ln443_32_d_0 = mux_data_2_ln443_q[63:32];
        default: mux_data_2_ln443_32_d_0 = 32'hX;
      endcase
      mux_i_2_ln440_mux_0_sel = ctrlOr_ln272_5_z | ctrlAnd_0_ln272_6_z;
      bufdout_set_valid_curr_hold = ~(ctrlAnd_1_ln272_z | ctrlAnd_1_ln272_6_z | 
      ctrlAnd_1_ln272_5_z | ctrlAnd_1_ln272_4_z | ctrlAnd_1_ln272_3_z | 
      ctrlAnd_1_ln272_2_z | ctrlAnd_1_ln272_1_z | ctrlAnd_1_ln272_0_z);
      write_fft_bufdout_data_ln274_en = rst & ctrlAnd_1_ln272_z;
      and_1_ln359_z = if_ln359_z & lt_ln358_z;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_unary_or_ln390_Z_0_v_0 = unary_or_ln390_Z_0_tag_0;
      else 
        mux_unary_or_ln390_Z_0_v_0 = mux_unary_or_ln390_Z_0_v;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_unary_or_ln420_Z_0_v_0 = unary_or_ln420_Z_0_tag_0;
      else 
        mux_unary_or_ln420_Z_0_v_0 = mux_unary_or_ln420_Z_0_v;
      and_1_ln375_z = if_ln375_z & mux_if_ln346_Z_1_v;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_and_0_ln375_Z_0_v = and_0_ln375_q;
      else 
        mux_and_0_ln375_Z_0_v = and_0_ln375_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_add_ln430_Z_v = add_ln430_q;
      else 
        mux_add_ln430_Z_v = add_ln430_z;
      add_ln453_z = add_ln430_z[31:10] + 22'h1;
      if (eq_ln400_z) begin
        mux_s_ln400_z = add_ln401_z;
        mux_index_ln400_z = 32'h0;
      end
      else begin
        mux_s_ln400_z = mux_s_ln331_z;
        mux_index_ln400_z = {add_ln399_z, mux_index_ln331_z[10:0]};
      end
      ctrlAnd_0_ln359_z = or_and_0_ln359_Z_0_z & ctrlOr_ln358_0_z;
      ctrlOr_ln387_z = ctrlAnd_0_ln387_z | ctrlAnd_1_ln383_z;
      ctrlOr_ln417_z = ctrlAnd_0_ln417_z | ctrlAnd_1_ln413_z;
      wr_index_hold = ~(ctrlAnd_1_ln417_z | ctrlAnd_1_ln375_z | 
      ctrlAnd_0_ln375_z | ctrlAnd_0_ln346_z);
      wr_length_sel = ctrlAnd_1_ln417_z | ctrlAnd_1_ln375_z;
      wr_request_hold = ~(ctrlAnd_1_ln436_z | ctrlAnd_1_ln417_z | 
      ctrlAnd_1_ln413_z | ctrlAnd_1_ln383_z | ctrlAnd_1_ln375_z | 
      ctrlAnd_1_ln354_z | ctrlAnd_0_ln375_z | ctrlAnd_0_ln346_z);
      wr_request_sel = ctrlAnd_1_ln417_z | ctrlAnd_1_ln375_z | ctrlAnd_0_ln375_z | 
      ctrlAnd_0_ln346_z;
      ctrlOr_ln436_z = ctrlAnd_0_ln436_z | ctrlAnd_1_ln417_z;
      ctrlOr_ln440_z = ctrlAnd_0_ln440_z | ctrlAnd_1_ln436_z;
      ctrlOr_ln375_z = ctrlAnd_1_ln440_z | ctrlAnd_1_ln387_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln272_z: bufdout_set_valid_curr_d = unary_nor_ln95_z;
        ctrlAnd_1_ln272_0_z: bufdout_set_valid_curr_d = unary_nor_ln95_0_z;
        ctrlAnd_1_ln272_1_z: bufdout_set_valid_curr_d = unary_nor_ln95_1_z;
        ctrlAnd_1_ln272_2_z: bufdout_set_valid_curr_d = unary_nor_ln95_2_z;
        ctrlAnd_1_ln272_3_z: bufdout_set_valid_curr_d = unary_nor_ln95_3_z;
        ctrlAnd_1_ln272_4_z: bufdout_set_valid_curr_d = unary_nor_ln95_4_z;
        ctrlAnd_1_ln272_5_z: bufdout_set_valid_curr_d = unary_nor_ln95_5_z;
        ctrlAnd_1_ln272_6_z: bufdout_set_valid_curr_d = unary_nor_ln95_6_z;
        bufdout_set_valid_curr_hold: bufdout_set_valid_curr_d = 
          bufdout_set_valid_curr;
        default: bufdout_set_valid_curr_d = 1'bX;
      endcase
      bufdout_data_hold = ~(write_fft_bufdout_data_ln274_en | 
      write_fft_bufdout_data_ln274_6_en | write_fft_bufdout_data_ln274_5_en | 
      write_fft_bufdout_data_ln274_4_en | write_fft_bufdout_data_ln274_3_en | 
      write_fft_bufdout_data_ln274_2_en | write_fft_bufdout_data_ln274_1_en | 
      write_fft_bufdout_data_ln274_0_en);
      ctrlAnd_1_ln359_z = and_1_ln359_z & ctrlOr_ln358_0_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_and_1_ln375_Z_0_v = and_1_ln375_q;
      else 
        mux_and_1_ln375_Z_0_v = and_1_ln375_z;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_and_0_ln375_Z_0_v_0 = and_0_ln375_q;
      else 
        mux_and_0_ln375_Z_0_v_0 = mux_and_0_ln375_Z_0_v;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_add_ln430_Z_0_mux_0_v = add_ln430_q;
      else 
        mux_add_ln430_Z_0_mux_0_v = mux_add_ln430_Z_v;
      sub_ln457_z = {add_ln453_z, add_ln430_z[9:0]} - lsh_ln406_z;
      eq_ln454_z = {add_ln453_z, add_ln430_z[9:0]} == add_ln454_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_index_ln400_Z_v = mux_index_ln400_q;
      else 
        mux_mux_index_ln400_Z_v = mux_index_ln400_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_s_ln400_Z_v = mux_s_ln400_q;
      else 
        mux_mux_s_ln400_Z_v = mux_s_ln400_z;
      ctrlOr_ln370_z = state_fft_unisim_fft_store_output[5] | ctrlAnd_0_ln359_z;
      memread_fft_B0_ln391_en = unary_or_ln390_Z_0_tag_0 & ctrlOr_ln387_z;
      memread_fft_B1_ln393_en = !unary_or_ln390_Z_0_tag_0 & ctrlOr_ln387_z;
      mux_base_ln331_sel = ctrlOr_ln387_z | ctrlOr_ln383_z | ctrlOr_ln342_z | 
      ctrlOr_ln272_1_z | ctrlAnd_0_ln272_2_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln387_z: mux_i_0_ln387_d_0 = {add_ln387_z[10:1], mux_i_0_ln387_z[
          0]};
        mux_i_0_ln387_mux_0_sel: mux_i_0_ln387_d_0 = {add_ln387_1_q, 
          mux_i_0_ln387_q};
        default: mux_i_0_ln387_d_0 = 11'hX;
      endcase
      add_ln430_sel = ctrlOr_ln417_z | ctrlOr_ln413_z | ctrlOr_ln342_z | 
      ctrlOr_ln272_3_z | ctrlAnd_0_ln272_4_z;
      memread_fft_B0_ln421_en = unary_or_ln420_Z_0_tag_0 & ctrlOr_ln417_z;
      memread_fft_B1_ln423_en = !unary_or_ln420_Z_0_tag_0 & ctrlOr_ln417_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln417_z: mux_i_1_ln417_d_0 = {add_ln417_z[9:1], mux_i_1_ln417_z[0]};
        mux_i_1_ln417_mux_0_sel: mux_i_1_ln417_d_0 = {add_ln417_1_q, 
          mux_i_1_ln417_q};
        default: mux_i_1_ln417_d_0 = 10'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        wr_index_sel: wr_index_d = mux_index_ln331_q;
        ctrlAnd_1_ln417_z: wr_index_d = add_ln430_q;
        ctrlAnd_0_ln346_z: wr_index_d = 32'h0;
        wr_index_hold: wr_index_d = wr_index;
        default: wr_index_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln375_z: wr_length_d = 32'h800;
        wr_length_sel: wr_length_d = 32'h400;
        ctrlAnd_0_ln346_z: wr_length_d = {read_fft_len_ln327_q[30:0], 1'b0};
        wr_index_hold: wr_length_d = wr_length;
        default: wr_length_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        wr_request_sel: wr_request_d = 1'b1;
        wr_request_sel_0: wr_request_d = 1'b0;
        wr_request_hold: wr_request_d = wr_request;
        default: wr_request_d = 1'bX;
      endcase
      memread_fft_B0_ln444_en = unary_or_ln420_Z_0_tag_0 & ctrlOr_ln440_z;
      memread_fft_B1_ln446_en = !unary_or_ln420_Z_0_tag_0 & ctrlOr_ln440_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_i_2_ln440_d_0 = {add_ln440_z[10:1], mux_i_2_ln440_z[
          0]};
        mux_i_2_ln440_mux_0_sel: mux_i_2_ln440_d_0 = {add_ln440_1_q, 
          mux_i_2_ln440_q};
        default: mux_i_2_ln440_d_0 = 11'hX;
      endcase
      read_fft_len_ln327_sel = ctrlOr_ln440_z | ctrlOr_ln436_z | ctrlOr_ln417_z | 
      ctrlOr_ln413_z | ctrlOr_ln387_z | ctrlOr_ln383_z | ctrlOr_ln342_z | 
      ctrlOr_ln272_5_z | ctrlOr_ln272_3_z | ctrlOr_ln272_1_z | 
      ctrlAnd_0_ln272_6_z | ctrlAnd_0_ln272_4_z | ctrlAnd_0_ln272_2_z;
      unary_or_ln420_Z_0_tag_mux_0_sel = ctrlOr_ln440_z | ctrlOr_ln436_z | 
      ctrlOr_ln417_z | ctrlOr_ln413_z | ctrlOr_ln342_z | ctrlOr_ln272_5_z | 
      ctrlOr_ln272_3_z | ctrlAnd_0_ln272_6_z | ctrlAnd_0_ln272_4_z;
      ctrlOr_ln331_z = ctrlOr_ln375_z | ctrlAnd_1_ln320_z;
      case (1'b1)// synthesis parallel_case
        write_fft_bufdout_data_ln274_en: bufdout_data_d = 
          mux_memread_fft_B0_ln362_Q_v[31:0];
        write_fft_bufdout_data_ln274_0_en: bufdout_data_d = 
          memread_fft_B0_ln362_q[63:32];
        write_fft_bufdout_data_ln274_1_en: bufdout_data_d = 
          mux_mux_data_0_ln390_Z_v[31:0];
        write_fft_bufdout_data_ln274_2_en: bufdout_data_d = mux_data_0_ln390_q[
          63:32];
        write_fft_bufdout_data_ln274_3_en: bufdout_data_d = 
          mux_mux_data_1_ln420_Z_v[31:0];
        write_fft_bufdout_data_ln274_4_en: bufdout_data_d = mux_data_1_ln420_q[
          63:32];
        write_fft_bufdout_data_ln274_5_en: bufdout_data_d = 
          mux_mux_data_2_ln443_Z_v[31:0];
        write_fft_bufdout_data_ln274_6_en: bufdout_data_d = mux_data_2_ln443_q[
          63:32];
        bufdout_data_hold: bufdout_data_d = bufdout_data;
        default: bufdout_data_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln359_z: mux_i_ln358_d_0 = {add_ln358_z[10:1], mux_i_ln358_z[0]};
        mux_i_ln358_mux_0_sel: mux_i_ln358_d_0 = {add_ln358_1_q, mux_i_ln358_q};
        default: mux_i_ln358_d_0 = 11'hX;
      endcase
      read_fft_len_ln327_31_sel = ctrlOr_ln440_z | ctrlOr_ln436_z | 
      ctrlOr_ln417_z | ctrlOr_ln413_z | ctrlOr_ln387_z | ctrlOr_ln383_z | 
      ctrlOr_ln354_z | ctrlOr_ln342_z | ctrlOr_ln272_z | ctrlOr_ln272_5_z | 
      ctrlOr_ln272_3_z | ctrlOr_ln272_1_z | ctrlAnd_1_ln359_z | 
      ctrlAnd_0_ln272_6_z | ctrlAnd_0_ln272_4_z | ctrlAnd_0_ln272_2_z | 
      ctrlAnd_0_ln272_0_z;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_and_1_ln375_Z_0_v_0 = and_1_ln375_q;
      else 
        mux_and_1_ln375_Z_0_v_0 = mux_and_1_ln375_Z_0_v;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_index_ln400_Z_0_mux_0_v = mux_index_ln400_q;
      else 
        mux_mux_index_ln400_Z_0_mux_0_v = mux_mux_index_ln400_Z_v;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_s_ln400_Z_0_mux_0_v = mux_s_ln400_q;
      else 
        mux_mux_s_ln400_Z_0_mux_0_v = mux_mux_s_ln400_Z_v;
      B0_bridge1_rtl_CE_en = memread_fft_B0_ln444_en | memread_fft_B0_ln421_en | 
      memread_fft_B0_ln391_en | ctrlAnd_1_ln359_z;
      B1_bridge1_rtl_CE_en = memread_fft_B1_ln446_en | memread_fft_B1_ln423_en | 
      memread_fft_B1_ln393_en;
      ctrlAnd_1_ln333_z = !gt_ln333_z & ctrlOr_ln331_z;
      ctrlAnd_0_ln333_z = gt_ln333_z & ctrlOr_ln331_z;
      if (eq_ln454_z) 
        mux_index_ln454_z = {add_ln453_z, add_ln430_z[9:0]};
      else 
        mux_index_ln454_z = sub_ln457_z;
      ctrlOr_ln333_z = ctrlAnd_1_ln333_z | state_fft_unisim_fft_store_output[1];
      dft_done_hold = ~(ctrlAnd_0_ln359_z | ctrlAnd_0_ln333_z);
      dft_done_sel = ctrlAnd_0_ln359_z | ctrlAnd_0_ln333_z;
      eq_ln459_z = mux_index_ln454_z == {mux_read_fft_len_ln327_Z_v[30:0], 1'b0};
      ctrlOr_ln339_z = ctrlAnd_0_ln339_z | ctrlOr_ln333_z;
      case (1'b1)// synthesis parallel_case
        dft_done_sel: dft_done_d = 1'b1;
        dft_done_hold: dft_done_d = dft_done;
        default: dft_done_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: add_ln430_d = add_ln430_z;
        ctrlOr_ln339_z: add_ln430_d = mux_add_ln430_Z_0_mux_0_v;
        add_ln430_sel: add_ln430_d = add_ln430_q;
        default: add_ln430_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: mux_base_ln331_d = {mux_index_ln400_z[30:0], 
          unary_or_ln390_z, mux_base_ln331_z};
        ctrlOr_ln339_z: mux_base_ln331_d = {mux_mux_index_ln400_Z_0_mux_0_v[30:0], 
          mux_unary_or_ln390_Z_0_v_0, mux_mux_base_ln331_Z_0_mux_0_v};
        mux_base_ln331_sel: mux_base_ln331_d = {mux_index_ln400_q[30:0], 
          unary_or_ln390_Z_0_tag_0, mux_base_ln331_q};
        default: mux_base_ln331_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: mux_index_ln331_d = {and_1_ln375_z, and_0_ln375_z, 
          mux_index_ln331_z};
        ctrlOr_ln339_z: mux_index_ln331_d = {mux_and_1_ln375_Z_0_v_0, 
          mux_and_0_ln375_Z_0_v_0, mux_mux_index_ln331_Z_0_mux_0_v};
        ctrlOr_ln342_z: mux_index_ln331_d = {and_1_ln375_q, and_0_ln375_q, 
          mux_index_ln331_q};
        default: mux_index_ln331_d = 34'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: mux_index_ln400_31_d_0 = {mux_s_ln400_z, 
          mux_index_ln400_z[31]};
        ctrlOr_ln339_z: mux_index_ln400_31_d_0 = {mux_mux_s_ln400_Z_0_mux_0_v, 
          mux_mux_index_ln400_Z_0_mux_0_v[31]};
        mux_base_ln331_sel: mux_index_ln400_31_d_0 = {mux_s_ln400_q, 
          mux_index_ln400_q[31]};
        default: mux_index_ln400_31_d_0 = 33'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: mux_ping_ln331_d = mux_ping_ln331_z;
        ctrlOr_ln339_z: mux_ping_ln331_d = mux_mux_ping_ln331_Z_0_mux_0_v;
        read_fft_len_ln327_sel: mux_ping_ln331_d = mux_ping_ln331_q;
        default: mux_ping_ln331_d = 8'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: read_fft_len_ln327_31_d = mux_read_fft_len_ln327_Z_v[
          31];
        ctrlOr_ln339_z: read_fft_len_ln327_31_d = 
          mux_read_fft_len_ln327_Z_0_mux_1_v[31];
        read_fft_len_ln327_31_sel: read_fft_len_ln327_31_d = 
          read_fft_len_ln327_q[31];
        default: read_fft_len_ln327_31_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: read_fft_len_ln327_d = {mux_le_ln346_Z_0_v, 
          mux_read_fft_log_len_ln328_Z_v, mux_read_fft_len_ln327_Z_v[30:0]};
        ctrlOr_ln339_z: read_fft_len_ln327_d = {mux_le_ln346_Z_0_v_1, 
          mux_read_fft_log_len_ln328_Z_0_mux_1_v, 
          mux_read_fft_len_ln327_Z_0_mux_1_v[30:0]};
        read_fft_len_ln327_sel: read_fft_len_ln327_d = {le_ln346_q, 
          read_fft_log_len_ln328_q, read_fft_len_ln327_q[30:0]};
        default: read_fft_len_ln327_d = 64'hX;
      endcase
      if (eq_ln459_z) begin
        mux_index_ln459_z = 32'h0;
        mux_s_ln459_z = add_ln460_z;
      end
      else begin
        mux_index_ln459_z = mux_index_ln454_z;
        mux_s_ln459_z = mux_s_ln331_z;
      end
      case (1'b1)
        eq_ln459_z: case_mux_base_ln459_z = 3'h1;
        eq_ln454_z: case_mux_base_ln459_z = 3'h2;
        default: case_mux_base_ln459_z = 3'h4;
      endcase
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_index_ln459_Z_v = mux_index_ln459_q;
      else 
        mux_mux_index_ln459_Z_v = mux_index_ln459_z;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_s_ln459_Z_v = mux_s_ln459_q;
      else 
        mux_mux_s_ln459_Z_v = mux_s_ln459_z;
      case (1'b1)// synthesis parallel_case
        case_mux_base_ln459_z[0]: mux_base_ln459_z = 32'h0;
        case_mux_base_ln459_z[1]: mux_base_ln459_z = add_ln454_z;
        case_mux_base_ln459_z[2]: mux_base_ln459_z = mux_base_ln331_z;
        default: mux_base_ln459_z = 32'hX;
      endcase
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_index_ln459_Z_0_mux_0_v = mux_index_ln459_q;
      else 
        mux_mux_index_ln459_Z_0_mux_0_v = mux_mux_index_ln459_Z_v;
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_s_ln459_Z_0_mux_0_v = mux_s_ln459_q;
      else 
        mux_mux_s_ln459_Z_0_mux_0_v = mux_mux_s_ln459_Z_v;
      if (state_fft_unisim_fft_store_output[1]) 
        mux_mux_base_ln459_Z_v = mux_base_ln459_q;
      else 
        mux_mux_base_ln459_Z_v = mux_base_ln459_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: unary_or_ln420_Z_0_tag_d_0 = {mux_s_ln459_z[30:0], 
          mux_index_ln459_z, unary_or_ln420_z};
        ctrlOr_ln339_z: unary_or_ln420_Z_0_tag_d_0 = {
          mux_mux_s_ln459_Z_0_mux_0_v[30:0], mux_mux_index_ln459_Z_0_mux_0_v, 
          mux_unary_or_ln420_Z_0_v_0};
        unary_or_ln420_Z_0_tag_mux_0_sel: unary_or_ln420_Z_0_tag_d_0 = {
          mux_s_ln459_q[30:0], mux_index_ln459_q, unary_or_ln420_Z_0_tag_0};
        default: unary_or_ln420_Z_0_tag_d_0 = 64'hX;
      endcase
      if (state_fft_unisim_fft_store_output[2]) 
        mux_mux_base_ln459_Z_0_mux_0_v = mux_base_ln459_q;
      else 
        mux_mux_base_ln459_Z_0_mux_0_v = mux_mux_base_ln459_Z_v;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln333_z: mux_s_ln459_31_d_0 = {mux_base_ln459_z, mux_s_ln459_z
          [31]};
        ctrlOr_ln339_z: mux_s_ln459_31_d_0 = {mux_mux_base_ln459_Z_0_mux_0_v, 
          mux_mux_s_ln459_Z_0_mux_0_v[31]};
        unary_or_ln420_Z_0_tag_mux_0_sel: mux_s_ln459_31_d_0 = {mux_base_ln459_q, 
          mux_s_ln459_q[31]};
        default: mux_s_ln459_31_d_0 = 33'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft_unisim_fft_store_output[0]: // Wait_ln320
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln320_z: state_fft_unisim_fft_store_output_next[0] = 
                1'b1;
              ctrlAnd_0_ln333_z: state_fft_unisim_fft_store_output_next[1] = 
                1'b1;
              ctrlOr_ln339_z: state_fft_unisim_fft_store_output_next[2] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[1]: // Wait_ln336
          state_fft_unisim_fft_store_output_next[2] = 1'b1;
        state_fft_unisim_fft_store_output[2]: // Wait_ln339
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln339_z: state_fft_unisim_fft_store_output_next[2] = 1'b1;
              ctrlOr_ln342_z: state_fft_unisim_fft_store_output_next[3] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[3]: // Wait_ln342
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln342_z: state_fft_unisim_fft_store_output_next[3] = 1'b1;
              ctrlOr_ln354_z: state_fft_unisim_fft_store_output_next[4] = 1'b1;
              ctrlOr_ln383_z: state_fft_unisim_fft_store_output_next[10] = 1'b1;
              ctrlOr_ln413_z: state_fft_unisim_fft_store_output_next[15] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[4]: // Wait_ln354
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln354_z: state_fft_unisim_fft_store_output_next[4] = 1'b1;
              ctrlOr_ln370_z: state_fft_unisim_fft_store_output_next[5] = 1'b1;
              ctrlAnd_1_ln359_z: state_fft_unisim_fft_store_output_next[6] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[5]: // Wait_ln370
          state_fft_unisim_fft_store_output_next[5] = 1'b1;
        state_fft_unisim_fft_store_output[6]: // Wait_ln364
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_z: state_fft_unisim_fft_store_output_next[7] = 
                1'b1;
              ctrlAnd_1_ln272_z: state_fft_unisim_fft_store_output_next[8] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[7]: // Wait_ln272
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_z: state_fft_unisim_fft_store_output_next[7] = 
                1'b1;
              ctrlAnd_1_ln272_z: state_fft_unisim_fft_store_output_next[8] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[8]: // Wait_ln366
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_0_z: state_fft_unisim_fft_store_output_next[9] = 
                1'b1;
              ctrlOr_ln370_z: state_fft_unisim_fft_store_output_next[5] = 1'b1;
              ctrlAnd_1_ln359_z: state_fft_unisim_fft_store_output_next[6] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[9]: // Wait_ln272_0
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_0_z: state_fft_unisim_fft_store_output_next[9] = 
                1'b1;
              ctrlOr_ln370_z: state_fft_unisim_fft_store_output_next[5] = 1'b1;
              ctrlAnd_1_ln359_z: state_fft_unisim_fft_store_output_next[6] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[10]: // Wait_ln383
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln383_z: state_fft_unisim_fft_store_output_next[10] = 1'b1;
              ctrlOr_ln387_z: state_fft_unisim_fft_store_output_next[11] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[11]: // Wait_ln395
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_1_z: state_fft_unisim_fft_store_output_next[12] = 
                1'b1;
              ctrlAnd_1_ln272_1_z: state_fft_unisim_fft_store_output_next[13] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[12]: // Wait_ln272_1
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_1_z: state_fft_unisim_fft_store_output_next[12] = 
                1'b1;
              ctrlAnd_1_ln272_1_z: state_fft_unisim_fft_store_output_next[13] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[13]: // Wait_ln397
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_2_z: state_fft_unisim_fft_store_output_next[14] = 
                1'b1;
              ctrlOr_ln387_z: state_fft_unisim_fft_store_output_next[11] = 1'b1;
              ctrlAnd_0_ln333_z: state_fft_unisim_fft_store_output_next[1] = 
                1'b1;
              ctrlOr_ln339_z: state_fft_unisim_fft_store_output_next[2] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[14]: // Wait_ln272_2
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_2_z: state_fft_unisim_fft_store_output_next[14] = 
                1'b1;
              ctrlOr_ln387_z: state_fft_unisim_fft_store_output_next[11] = 1'b1;
              ctrlAnd_0_ln333_z: state_fft_unisim_fft_store_output_next[1] = 
                1'b1;
              ctrlOr_ln339_z: state_fft_unisim_fft_store_output_next[2] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[15]: // Wait_ln413
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln413_z: state_fft_unisim_fft_store_output_next[15] = 1'b1;
              ctrlOr_ln417_z: state_fft_unisim_fft_store_output_next[16] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[16]: // Wait_ln425
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_3_z: state_fft_unisim_fft_store_output_next[17] = 
                1'b1;
              ctrlAnd_1_ln272_3_z: state_fft_unisim_fft_store_output_next[18] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[17]: // Wait_ln272_3
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_3_z: state_fft_unisim_fft_store_output_next[17] = 
                1'b1;
              ctrlAnd_1_ln272_3_z: state_fft_unisim_fft_store_output_next[18] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[18]: // Wait_ln427
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_4_z: state_fft_unisim_fft_store_output_next[19] = 
                1'b1;
              ctrlOr_ln417_z: state_fft_unisim_fft_store_output_next[16] = 1'b1;
              ctrlOr_ln436_z: state_fft_unisim_fft_store_output_next[20] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[19]: // Wait_ln272_4
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_4_z: state_fft_unisim_fft_store_output_next[19] = 
                1'b1;
              ctrlOr_ln417_z: state_fft_unisim_fft_store_output_next[16] = 1'b1;
              ctrlOr_ln436_z: state_fft_unisim_fft_store_output_next[20] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[20]: // Wait_ln436
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln436_z: state_fft_unisim_fft_store_output_next[20] = 1'b1;
              ctrlOr_ln440_z: state_fft_unisim_fft_store_output_next[21] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[21]: // Wait_ln448
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_5_z: state_fft_unisim_fft_store_output_next[22] = 
                1'b1;
              ctrlAnd_1_ln272_5_z: state_fft_unisim_fft_store_output_next[23] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[22]: // Wait_ln272_5
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_5_z: state_fft_unisim_fft_store_output_next[22] = 
                1'b1;
              ctrlAnd_1_ln272_5_z: state_fft_unisim_fft_store_output_next[23] = 
                1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[23]: // Wait_ln450
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_6_z: state_fft_unisim_fft_store_output_next[24] = 
                1'b1;
              ctrlOr_ln440_z: state_fft_unisim_fft_store_output_next[21] = 1'b1;
              ctrlAnd_0_ln333_z: state_fft_unisim_fft_store_output_next[1] = 
                1'b1;
              ctrlOr_ln339_z: state_fft_unisim_fft_store_output_next[2] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        state_fft_unisim_fft_store_output[24]: // Wait_ln272_6
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_6_z: state_fft_unisim_fft_store_output_next[24] = 
                1'b1;
              ctrlOr_ln440_z: state_fft_unisim_fft_store_output_next[21] = 1'b1;
              ctrlAnd_0_ln333_z: state_fft_unisim_fft_store_output_next[1] = 
                1'b1;
              ctrlOr_ln339_z: state_fft_unisim_fft_store_output_next[2] = 1'b1;
              default: state_fft_unisim_fft_store_output_next = 25'hX;
            endcase
          end
        default: // Don't care
          state_fft_unisim_fft_store_output_next = 25'hX;
      endcase
    end
endmodule


module fft_unisim_fft_bufdin_can_get_mod_process(bufdin_valid, bufdin_ready, 
bufdin_can_get_sig);
  input bufdin_valid;
  input bufdin_ready;
  output reg bufdin_can_get_sig;

  always @(*) begin : fft_unisim_fft_bufdin_can_get_mod_process_combinational
      reg unary_nor_ln35_z;
      reg ternaryMux_ln35_0_z;

      unary_nor_ln35_z = ~bufdin_ready;
      ternaryMux_ln35_0_z = bufdin_valid | unary_nor_ln35_z;
      bufdin_can_get_sig = ternaryMux_ln35_0_z;
    end
endmodule


module fft_unisim_fft_bufdin_sync_rcv_back_method(clk, rst, bufdin_valid, 
bufdin_ready, bufdin_set_ready_curr, bufdin_data, bufdin_sync_rcv_set_ready_prev, 
bufdin_sync_rcv_reset_ready_prev, bufdin_sync_rcv_reset_ready_curr, 
bufdin_sync_rcv_ready_flop, bufdin_data_buf);
  input clk;
  input rst;
  input bufdin_valid;
  input bufdin_ready;
  input bufdin_set_ready_curr;
  input [31:0] bufdin_data;
  output reg bufdin_sync_rcv_set_ready_prev;
  output reg bufdin_sync_rcv_reset_ready_prev;
  output reg bufdin_sync_rcv_reset_ready_curr;
  output reg bufdin_sync_rcv_ready_flop;
  output reg [31:0] bufdin_data_buf;
  reg bufdin_sync_rcv_ready_flop_d;
  reg bufdin_sync_rcv_reset_ready_prev_d;
  reg bufdin_sync_rcv_set_ready_prev_d;
  reg bufdin_sync_rcv_reset_ready_curr_d;
  reg [31:0] bufdin_data_buf_d;

  // synthesis async_set_reset_local fft_unisim_fft_bufdin_sync_rcv_back_method_seq_block rst
  always @(posedge clk or negedge rst) // fft_unisim_fft_bufdin_sync_rcv_back_method_sequential
    begin : fft_unisim_fft_bufdin_sync_rcv_back_method_seq_block
      if (!rst) // Initialize state and outputs
      begin
        bufdin_sync_rcv_ready_flop <= 1'b1;
        bufdin_sync_rcv_reset_ready_prev <= 1'b0;
        bufdin_sync_rcv_set_ready_prev <= 1'b0;
        bufdin_sync_rcv_reset_ready_curr <= 1'b0;
        bufdin_data_buf <= 32'h0;
      end
      else // Update Q values
      begin
        bufdin_sync_rcv_ready_flop <= bufdin_sync_rcv_ready_flop_d;
        bufdin_sync_rcv_reset_ready_prev <= bufdin_sync_rcv_reset_ready_prev_d;
        bufdin_sync_rcv_set_ready_prev <= bufdin_sync_rcv_set_ready_prev_d;
        bufdin_sync_rcv_reset_ready_curr <= bufdin_sync_rcv_reset_ready_curr_d;
        bufdin_data_buf <= bufdin_data_buf_d;
      end
    end
  always @(*) begin : fft_unisim_fft_bufdin_sync_rcv_back_method_combinational
      reg unary_nor_ln78_z;
      reg ternaryMux_ln95_0_z;

      bufdin_sync_rcv_ready_flop_d = bufdin_ready;
      unary_nor_ln78_z = ~bufdin_sync_rcv_reset_ready_curr;
      bufdin_sync_rcv_reset_ready_prev_d = bufdin_sync_rcv_reset_ready_curr;
      bufdin_sync_rcv_set_ready_prev_d = bufdin_set_ready_curr;
      ternaryMux_ln95_0_z = bufdin_valid & bufdin_ready;
      if (ternaryMux_ln95_0_z) 
        bufdin_sync_rcv_reset_ready_curr_d = unary_nor_ln78_z;
      else 
        bufdin_sync_rcv_reset_ready_curr_d = bufdin_sync_rcv_reset_ready_curr;
      if (ternaryMux_ln95_0_z) 
        bufdin_data_buf_d = bufdin_data;
      else 
        bufdin_data_buf_d = bufdin_data_buf;
    end
endmodule


module fft_unisim_fft_bufdin_sync_rcv_ready_arb(bufdin_set_ready_curr, 
bufdin_sync_rcv_set_ready_prev, bufdin_sync_rcv_reset_ready_curr, 
bufdin_sync_rcv_reset_ready_prev, bufdin_sync_rcv_ready_flop, bufdin_ready);
  input bufdin_set_ready_curr;
  input bufdin_sync_rcv_set_ready_prev;
  input bufdin_sync_rcv_reset_ready_curr;
  input bufdin_sync_rcv_reset_ready_prev;
  input bufdin_sync_rcv_ready_flop;
  output reg bufdin_ready;

  always @(*) begin : fft_unisim_fft_bufdin_sync_rcv_ready_arb_combinational
      reg ne_ln107_z;
      reg ne_ln109_z;
      reg mux_b_ln109_0_z;
      reg mux_b_ln107_0_z;

      ne_ln107_z = bufdin_sync_rcv_set_ready_prev ^ bufdin_set_ready_curr;
      ne_ln109_z = ~(bufdin_sync_rcv_reset_ready_prev ^ 
      bufdin_sync_rcv_reset_ready_curr);
      mux_b_ln109_0_z = ne_ln109_z & bufdin_sync_rcv_ready_flop;
      mux_b_ln107_0_z = ne_ln107_z | mux_b_ln109_0_z;
      bufdin_ready = mux_b_ln107_0_z;
    end
endmodule


module fft_unisim_fft_bufdout_can_put_mod_process(bufdout_valid, bufdout_ready, 
bufdout_can_put_sig);
  input bufdout_valid;
  input bufdout_ready;
  output reg bufdout_can_put_sig;

  always @(*) begin : fft_unisim_fft_bufdout_can_put_mod_process_combinational
      reg unary_nor_ln35_z;
      reg ternaryMux_ln35_0_z;

      unary_nor_ln35_z = ~bufdout_ready;
      ternaryMux_ln35_0_z = ~(bufdout_valid & unary_nor_ln35_z);
      bufdout_can_put_sig = ternaryMux_ln35_0_z;
    end
endmodule


module fft_unisim_fft_bufdout_sync_snd_back_method(clk, rst, bufdout_ready, 
bufdout_valid, bufdout_set_valid_curr, bufdout_sync_snd_set_valid_prev, 
bufdout_sync_snd_reset_valid_prev, bufdout_sync_snd_reset_valid_curr, 
bufdout_sync_snd_valid_flop);
  input clk;
  input rst;
  input bufdout_ready;
  input bufdout_valid;
  input bufdout_set_valid_curr;
  output reg bufdout_sync_snd_set_valid_prev;
  output reg bufdout_sync_snd_reset_valid_prev;
  output reg bufdout_sync_snd_reset_valid_curr;
  output reg bufdout_sync_snd_valid_flop;
  reg bufdout_sync_snd_reset_valid_prev_d;
  reg bufdout_sync_snd_set_valid_prev_d;
  reg bufdout_sync_snd_valid_flop_d;
  reg bufdout_sync_snd_reset_valid_curr_d;

  // synthesis async_set_reset_local fft_unisim_fft_bufdout_sync_snd_back_method_seq_block rst
  always @(posedge clk or negedge rst) // fft_unisim_fft_bufdout_sync_snd_back_method_sequential
    begin : fft_unisim_fft_bufdout_sync_snd_back_method_seq_block
      if (!rst) // Initialize state and outputs
      begin
        bufdout_sync_snd_reset_valid_prev <= 1'b0;
        bufdout_sync_snd_set_valid_prev <= 1'b0;
        bufdout_sync_snd_valid_flop <= 1'b0;
        bufdout_sync_snd_reset_valid_curr <= 1'b0;
      end
      else // Update Q values
      begin
        bufdout_sync_snd_reset_valid_prev <= bufdout_sync_snd_reset_valid_prev_d;
        bufdout_sync_snd_set_valid_prev <= bufdout_sync_snd_set_valid_prev_d;
        bufdout_sync_snd_valid_flop <= bufdout_sync_snd_valid_flop_d;
        bufdout_sync_snd_reset_valid_curr <= bufdout_sync_snd_reset_valid_curr_d;
      end
    end
  always @(*) begin : fft_unisim_fft_bufdout_sync_snd_back_method_combinational
      reg unary_nor_ln72_z;

      unary_nor_ln72_z = ~bufdout_sync_snd_reset_valid_curr;
      bufdout_sync_snd_reset_valid_prev_d = bufdout_sync_snd_reset_valid_curr;
      bufdout_sync_snd_set_valid_prev_d = bufdout_set_valid_curr;
      bufdout_sync_snd_valid_flop_d = bufdout_valid;
      if (bufdout_ready) 
        bufdout_sync_snd_reset_valid_curr_d = unary_nor_ln72_z;
      else 
        bufdout_sync_snd_reset_valid_curr_d = bufdout_sync_snd_reset_valid_curr;
    end
endmodule


module fft_unisim_fft_bufdout_sync_snd_valid_arb(bufdout_set_valid_curr, 
bufdout_sync_snd_set_valid_prev, bufdout_sync_snd_reset_valid_curr, 
bufdout_sync_snd_reset_valid_prev, bufdout_sync_snd_valid_flop, bufdout_valid);
  input bufdout_set_valid_curr;
  input bufdout_sync_snd_set_valid_prev;
  input bufdout_sync_snd_reset_valid_curr;
  input bufdout_sync_snd_reset_valid_prev;
  input bufdout_sync_snd_valid_flop;
  output reg bufdout_valid;

  always @(*) begin : fft_unisim_fft_bufdout_sync_snd_valid_arb_combinational
      reg ne_ln93_z;
      reg ne_ln95_z;
      reg mux_b_ln95_0_z;
      reg mux_b_ln93_0_z;

      ne_ln93_z = bufdout_sync_snd_set_valid_prev ^ bufdout_set_valid_curr;
      ne_ln95_z = ~(bufdout_sync_snd_reset_valid_prev ^ 
      bufdout_sync_snd_reset_valid_curr);
      mux_b_ln95_0_z = ne_ln95_z & bufdout_sync_snd_valid_flop;
      mux_b_ln93_0_z = ne_ln93_z | mux_b_ln95_0_z;
      bufdout_valid = mux_b_ln93_0_z;
    end
endmodule


module fft_unisim_identity_sync_write_m_1024x64m32(rtl_CE, rtl_A, rtl_D, rtl_WE, rtl_WEM, CLK, mem_CE, mem_A, mem_D, mem_WE, mem_WEM);
    input rtl_CE;
    input [9 : 0] rtl_A;
    input [63 : 0] rtl_D;
    input rtl_WE;
    input [1 : 0] rtl_WEM;
    input CLK;
    output mem_CE;
    output [9 : 0] mem_A;
    output [63 : 0] mem_D;
    output mem_WE;
    output [1 : 0] mem_WEM;

    assign mem_CE = rtl_CE;
    assign mem_A = rtl_A;
    assign mem_D = rtl_D;
    assign mem_WE = rtl_WE;
    assign mem_WEM = rtl_WEM;
`ifdef CTOS_SIM_MULTI_LANGUAGE_EXTERNAL_ARRAY
    // This is only required when simulating a multi-language design.
    bit use_dpi;
    wire m_ready;
    reg [63:0] dpi_D;
    initial begin
        use_dpi = 0;

        @(posedge m_ready)
        use_dpi = 1;
    end
    ctos_external_array_accessor #(.ADDR_WIDTH(10), .DATA_WIDTH(64), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

    always @(posedge CLK) begin
        if (use_dpi) begin
            if (rtl_CE && rtl_WE && rtl_WEM) begin
                arr_ref.read(rtl_A, dpi_D);
                if (rtl_WEM[0]) begin
                    dpi_D[31                     : 0] = rtl_D[31                     : 0];
                end
                if (rtl_WEM[1]) begin
                    dpi_D[63                     : 32] = rtl_D[63                     : 32];
                end
                arr_ref.write(rtl_A, dpi_D);
            end
        end
    end
`endif
endmodule


module fft_unisim_identity_sync_read_1024x64m32(rtl_CE, rtl_A, mem_Q, CLK, mem_CE, mem_A, rtl_Q);
    input rtl_CE;
    input [9 : 0] rtl_A;
    input [63 : 0] mem_Q;
    input CLK;
    output mem_CE;
    output [9 : 0] mem_A;
    output [63 : 0] rtl_Q;

    assign mem_CE = rtl_CE;
    assign mem_A = rtl_A;
`ifndef CTOS_SIM_MULTI_LANGUAGE_EXTERNAL_ARRAY
    assign rtl_Q = mem_Q;

`else
    // This is only required when simulating a multi-language design.
    reg [63:0] dpi_Q;
    bit use_dpi;
    wire m_ready;
    // Pick which Q drives the RTL Q.
    assign rtl_Q = use_dpi ? dpi_Q : mem_Q;
    initial begin
        use_dpi = 0;

        @(posedge m_ready)
        use_dpi = 1;
    end
    ctos_external_array_accessor #(.ADDR_WIDTH(10), .DATA_WIDTH(64), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

    always @(posedge CLK) begin
        if (use_dpi) begin
            if (rtl_CE) begin
                arr_ref.read(rtl_A, dpi_Q);
            end
        end
    end
`endif
endmodule


