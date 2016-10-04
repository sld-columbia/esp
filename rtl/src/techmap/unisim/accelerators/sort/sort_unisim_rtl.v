// *****************************************************************************
//                         Cadence C-to-Silicon Compiler
//          Version 13.10-s101  (64 bit), build 47617 Wed, 02 Oct 2013
// 
// File created on Fri Sep 26 02:15:08 2014
// 
// The code contained herein is generated for Cadences customer and third
// parties authorized by customer.  It may be used in accordance with a
// previously executed license agreement between Cadence and that customer.
// Absolutely no disassembling, decompiling, reverse-translations or
// reverse-engineering of the generated code is allowed.
// 
//*****************************************************************************
module sort_top_unisim_rtl(clk, rst, rd_grant, wr_grant, conf_len, conf_batch, 
conf_done, bufdin_valid, bufdin_data, bufdout_ready, rd_index, rd_length, 
rd_request, wr_index, wr_length, wr_request, sort_done, bufdin_ready, 
bufdout_valid, bufdout_data);
  input clk;
  input rst;
  input rd_grant;
  input wr_grant;
  input [31:0] conf_len;
  input [31:0] conf_batch;
  input conf_done;
  input bufdin_valid;
  input [31:0] bufdin_data;
  input bufdout_ready;
  output reg [31:0] rd_index;
  output reg [31:0] rd_length;
  output reg rd_request;
  output reg [31:0] wr_index;
  output reg [31:0] wr_length;
  output reg wr_request;
  output reg sort_done;
  output bufdin_ready;
  output bufdout_valid;
  output reg [31:0] bufdout_data;
  reg [31:0] len;
  reg [31:0] batch;
  reg init_done;
  reg input_done;
  reg rb_start;
  reg rb_done;
  reg merge_start;
  reg merge_done;
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
  wire A0_CE0;
  wire [9:0] A0_A0;
  wire [31:0] A0_D0;
  wire A0_WE0;
  wire [31:0] A0_Q1;
  wire A0_CE1;
  wire [9:0] A0_A1;
  wire A1_CE0;
  wire [9:0] A1_A0;
  wire [31:0] A1_D0;
  wire A1_WE0;
  wire [31:0] A1_Q1;
  wire A1_CE1;
  wire [9:0] A1_A1;
  wire B0_CE0;
  wire [9:0] B0_A0;
  wire [31:0] B0_D0;
  wire B0_WE0;
  wire [31:0] B0_Q1;
  wire B0_CE1;
  wire [9:0] B0_A1;
  wire B1_CE0;
  wire [9:0] B1_A0;
  wire [31:0] B1_D0;
  wire B1_WE0;
  wire [31:0] B1_Q1;
  wire B1_CE1;
  wire [9:0] B1_A1;
  wire C0_CE0;
  wire [9:0] C0_A0;
  wire [31:0] C0_D0;
  wire C0_WE0;
  wire [31:0] C0_Q1;
  wire C0_CE1;
  wire [9:0] C0_A1;
  wire C1_CE0;
  wire [9:0] C1_A0;
  wire [31:0] C1_D0;
  wire C1_WE0;
  wire [31:0] C1_Q1;
  wire C1_CE1;
  wire [9:0] C1_A1;
  wire sort_unisim_lt_float_ln284_unr0_unr0_z;
  wire sort_unisim_lt_float_ln284_unr1_unr0_z;
  wire sort_unisim_lt_float_ln284_unr2_unr0_z;
  wire sort_unisim_lt_float_ln284_unr3_unr0_z;
  wire sort_unisim_lt_float_ln284_unr4_unr0_z;
  wire sort_unisim_lt_float_ln284_unr5_unr0_z;
  wire sort_unisim_lt_float_ln284_unr6_unr0_z;
  wire sort_unisim_lt_float_ln284_unr7_unr0_z;
  wire sort_unisim_lt_float_ln284_unr8_unr0_z;
  wire sort_unisim_lt_float_ln284_unr9_unr0_z;
  wire sort_unisim_lt_float_ln284_unr10_unr0_z;
  wire sort_unisim_lt_float_ln284_unr11_unr0_z;
  wire sort_unisim_lt_float_ln284_unr12_unr0_z;
  wire sort_unisim_lt_float_ln284_unr13_unr0_z;
  wire sort_unisim_lt_float_ln284_unr14_unr0_z;
  wire sort_unisim_lt_float_ln284_unr15_unr0_z;
  wire sort_unisim_lt_float_ln294_unr0_unr0_z;
  wire sort_unisim_lt_float_ln294_unr1_unr0_z;
  wire sort_unisim_lt_float_ln294_unr2_unr0_z;
  wire sort_unisim_lt_float_ln294_unr3_unr0_z;
  wire sort_unisim_lt_float_ln294_unr4_unr0_z;
  wire sort_unisim_lt_float_ln294_unr5_unr0_z;
  wire sort_unisim_lt_float_ln294_unr6_unr0_z;
  wire sort_unisim_lt_float_ln294_unr7_unr0_z;
  wire sort_unisim_lt_float_ln294_unr8_unr0_z;
  wire sort_unisim_lt_float_ln294_unr9_unr0_z;
  wire sort_unisim_lt_float_ln294_unr10_unr0_z;
  wire sort_unisim_lt_float_ln294_unr11_unr0_z;
  wire sort_unisim_lt_float_ln294_unr12_unr0_z;
  wire sort_unisim_lt_float_ln294_unr13_unr0_z;
  wire sort_unisim_lt_float_ln294_unr14_unr0_z;
  wire sort_unisim_lt_float_ln284_unr0_unr1_z;
  wire sort_unisim_lt_float_ln284_unr1_unr1_z;
  wire sort_unisim_lt_float_ln284_unr2_unr1_z;
  wire sort_unisim_lt_float_ln284_unr3_unr1_z;
  wire sort_unisim_lt_float_ln284_unr4_unr1_z;
  wire sort_unisim_lt_float_ln284_unr5_unr1_z;
  wire sort_unisim_lt_float_ln284_unr6_unr1_z;
  wire sort_unisim_lt_float_ln284_unr7_unr1_z;
  wire sort_unisim_lt_float_ln284_unr8_unr1_z;
  wire sort_unisim_lt_float_ln284_unr9_unr1_z;
  wire sort_unisim_lt_float_ln284_unr10_unr1_z;
  wire sort_unisim_lt_float_ln284_unr11_unr1_z;
  wire sort_unisim_lt_float_ln284_unr12_unr1_z;
  wire sort_unisim_lt_float_ln284_unr13_unr1_z;
  wire sort_unisim_lt_float_ln284_unr14_unr1_z;
  wire sort_unisim_lt_float_ln284_unr15_unr1_z;
  wire sort_unisim_lt_float_ln294_unr0_unr1_z;
  wire sort_unisim_lt_float_ln294_unr1_unr1_z;
  wire sort_unisim_lt_float_ln294_unr2_unr1_z;
  wire sort_unisim_lt_float_ln294_unr3_unr1_z;
  wire sort_unisim_lt_float_ln294_unr4_unr1_z;
  wire sort_unisim_lt_float_ln294_unr5_unr1_z;
  wire sort_unisim_lt_float_ln294_unr6_unr1_z;
  wire sort_unisim_lt_float_ln294_unr7_unr1_z;
  wire sort_unisim_lt_float_ln294_unr8_unr1_z;
  wire sort_unisim_lt_float_ln294_unr9_unr1_z;
  wire sort_unisim_lt_float_ln294_unr10_unr1_z;
  wire sort_unisim_lt_float_ln294_unr11_unr1_z;
  wire sort_unisim_lt_float_ln294_unr12_unr1_z;
  wire sort_unisim_lt_float_ln294_unr13_unr1_z;
  wire sort_unisim_lt_float_ln294_unr14_unr1_z;
  wire sort_unisim_lt_float_ln447_unr0_z;
  wire sort_unisim_lt_float_ln447_unr1_z;
  wire sort_unisim_lt_float_ln447_unr2_z;
  wire sort_unisim_lt_float_ln447_unr3_z;
  wire sort_unisim_lt_float_ln447_unr4_z;
  wire sort_unisim_lt_float_ln447_unr5_z;
  wire sort_unisim_lt_float_ln447_unr6_z;
  wire sort_unisim_lt_float_ln447_unr7_z;
  wire sort_unisim_lt_float_ln447_unr8_z;
  wire sort_unisim_lt_float_ln447_unr9_z;
  wire sort_unisim_lt_float_ln447_unr10_z;
  wire sort_unisim_lt_float_ln447_unr11_z;
  wire sort_unisim_lt_float_ln447_unr12_z;
  wire sort_unisim_lt_float_ln447_unr13_z;
  wire sort_unisim_lt_float_ln447_unr14_z;
  wire sort_unisim_lt_float_ln447_unr15_z;
  wire sort_unisim_lt_float_ln447_unr16_z;
  wire sort_unisim_lt_float_ln447_unr17_z;
  wire sort_unisim_lt_float_ln447_unr18_z;
  wire sort_unisim_lt_float_ln447_unr19_z;
  wire sort_unisim_lt_float_ln447_unr20_z;
  wire sort_unisim_lt_float_ln447_unr21_z;
  wire sort_unisim_lt_float_ln447_unr22_z;
  wire sort_unisim_lt_float_ln447_unr23_z;
  wire sort_unisim_lt_float_ln447_unr24_z;
  wire sort_unisim_lt_float_ln447_unr25_z;
  wire sort_unisim_lt_float_ln447_unr26_z;
  wire sort_unisim_lt_float_ln447_unr27_z;
  wire sort_unisim_lt_float_ln447_unr28_z;
  wire sort_unisim_lt_float_ln447_unr29_z;
  wire sort_unisim_lt_float_ln447_unr30_z;
  reg [1:0] state_sort_unisim_sort_config_sort;
  reg [1:0] state_sort_unisim_sort_config_sort_next;
  reg [31:0] len_d;
  reg [31:0] batch_d;
  reg init_done_d;
  reg [6:0] state_sort_unisim_sort_load_input;
  reg [6:0] state_sort_unisim_sort_load_input_next;
  reg [9:0] mux_i_ln119_q;
  reg [9:0] add_ln119_1_q;
  reg and_1_ln123_Z_0_tag_0;
  reg and_0_ln123_Z_0_tag_0;
  reg mux_burst_ln101_q;
  reg mux_ping_ln101_q;
  reg [31:0] read_sort_batch_ln98_q;
  reg [30:0] add_ln111_1_q;
  reg [31:0] add_ln110_q;
  reg memwrite_sort_A0_ln124_en;
  reg [9:0] mux_mux_i_ln119_Z_v;
  reg [31:0] mux_item_ln304_z;
  reg memwrite_sort_A1_ln128_en;
  reg [9:0] mux_add_ln119_Z_1_v_0;
  reg [31:0] rd_length_d;
  reg [31:0] rd_index_d;
  reg rd_request_d;
  reg input_done_d;
  reg mux_and_1_ln123_Z_0_v;
  reg mux_and_0_ln123_Z_0_v;
  reg [63:0] read_sort_batch_ln98_d;
  reg [32:0] add_ln110_30_d_0;
  reg bufdin_set_ready_curr_d;
  reg [19:0] state_sort_unisim_sort_merge_sort;
  reg [19:0] state_sort_unisim_sort_merge_sort_next;
  reg [2:0] case_mux_head_ln387_0_q;
  reg [2:0] case_mux_head_ln440_1_q;
  reg [991:0] mux_regs_in_ln440_q;
  reg [31:0] mux_elem_ln577_q;
  reg [31:0] mux_head_ln440_0_q;
  reg [4:0] mux_chunk_ln406_q;
  reg [1023:0] mux_head_ln440_1_q;
  reg ge_ln457_unr0_Z_0_tag_0;
  reg ge_ln457_unr16_q;
  reg ge_ln457_unr24_q;
  reg ge_ln457_unr28_q;
  reg ge_ln457_unr30_q;
  reg ge_ln457_unr10_q;
  reg ge_ln457_unr21_q;
  reg ge_ln457_unr6_q;
  reg ge_ln457_unr19_q;
  reg ge_ln457_unr2_q;
  reg ge_ln457_unr17_q;
  reg ge_ln457_unr15_q;
  reg ge_ln457_unr13_q;
  reg ge_ln457_unr11_q;
  reg ge_ln457_unr9_q;
  reg ge_ln457_unr7_q;
  reg ge_ln457_unr5_q;
  reg ge_ln457_unr3_q;
  reg ge_ln457_unr8_q;
  reg ge_ln457_unr20_q;
  reg ge_ln457_unr26_q;
  reg ge_ln457_unr29_q;
  reg ge_ln457_unr1_q;
  reg ge_ln457_unr12_q;
  reg ge_ln457_unr22_q;
  reg ge_ln457_unr27_q;
  reg ge_ln457_unr4_q;
  reg ge_ln457_unr18_q;
  reg ge_ln457_unr25_q;
  reg ge_ln457_unr14_q;
  reg ge_ln457_unr23_q;
  reg sort_unisim_lt_float_ln447_unr0_lt_float_out_q;
  reg sort_unisim_lt_float_ln447_unr1_lt_float_out_q;
  reg [1023:0] mux_regs_0_ln440_q;
  reg [31:0] mux_cur_ln440_q;
  reg [4:0] add_ln406_1_q;
  reg [1023:0] mux_fidx_ln440_q;
  reg [9:0] mux_cnt_ln440_q;
  reg eq_ln445_unr10_Z_0_tag_0;
  reg eq_ln445_unr11_Z_0_tag_0;
  reg eq_ln445_unr12_Z_0_tag_0;
  reg eq_ln445_unr13_Z_0_tag_0;
  reg eq_ln445_unr14_Z_0_tag_0;
  reg eq_ln445_unr15_Z_0_tag_0;
  reg eq_ln445_unr16_Z_0_tag_0;
  reg eq_ln445_unr17_Z_0_tag_0;
  reg eq_ln445_unr18_Z_0_tag_0;
  reg eq_ln445_unr19_Z_0_tag_0;
  reg eq_ln445_unr1_Z_0_tag_0;
  reg eq_ln445_unr20_Z_0_tag_0;
  reg eq_ln445_unr21_Z_0_tag_0;
  reg eq_ln445_unr22_Z_0_tag_0;
  reg eq_ln445_unr23_Z_0_tag_0;
  reg eq_ln445_unr24_Z_0_tag_0;
  reg eq_ln445_unr25_Z_0_tag_0;
  reg eq_ln445_unr26_Z_0_tag_0;
  reg eq_ln445_unr27_Z_0_tag_0;
  reg eq_ln445_unr28_Z_0_tag_0;
  reg eq_ln445_unr29_Z_0_tag_0;
  reg eq_ln445_unr2_Z_0_tag_0;
  reg eq_ln445_unr30_Z_0_tag_0;
  reg eq_ln445_unr3_Z_0_tag_0;
  reg eq_ln445_unr4_Z_0_tag_0;
  reg eq_ln445_unr5_Z_0_tag_0;
  reg eq_ln445_unr6_Z_0_tag_0;
  reg eq_ln445_unr7_Z_0_tag_0;
  reg eq_ln445_unr8_Z_0_tag_0;
  reg eq_ln445_unr9_Z_0_tag_0;
  reg eq_ln485_unr0_Z_0_tag_0;
  reg eq_ln445_unr0_Z_0_tag_0;
  reg eq_ln507_Z_0_tag_0;
  reg [2:0] case_mux_shift_ln456_q;
  reg [4:0] mux_i_1_ln574_q;
  reg [4:0] add_ln574_1_q;
  reg [1023:0] mux_fidx_ln440_0_q;
  reg [1023:0] mux_head_ln440_q;
  reg [2:0] case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_q;
  reg [1023:0] memwrite_fidx_ln414_q;
  reg [31:0] mux_cur_ln558_q;
  reg [31:0] mux_cnt_ln507_q;
  reg [30:0] add_ln423_1_q;
  reg [992:0] mux_fidx_ln406_q;
  reg eq_ln564_q;
  reg [4:0] mux_chunk_4_ln570_q;
  reg [4:0] add_ln570_1_q;
  reg [1023:0] mux_head_ln387_q;
  reg [991:0] mux_regs_0_ln387_q;
  reg [991:0] mux_regs_in_ln387_q;
  reg [1023:0] mux_head_ln357_q;
  reg [1023:0] mux_head_ln406_q;
  reg [991:0] mux_regs_in_ln357_q;
  reg [991:0] mux_regs_0_ln357_q;
  reg mux_ping_ln357_Z_0_tag_0;
  reg mux_burst_ln357_q;
  reg [30:0] add_ln598_1_q;
  reg [31:0] read_sort_len_ln352_q;
  reg [31:0] read_sort_batch_ln353_q;
  reg [3:0] sub_ln510_1_q;
  reg gt_ln387_q;
  reg [1023:0] mux_regs_0_ln510_q;
  reg [31:0] memread_regs_ln510_q;
  reg [4:0] mux_pop_idx_ln520_0_q;
  reg [1023:0] mux_head_ln536_q;
  reg ne_ln534_Z_0_tag_0;
  reg [28:0] memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_q;
  reg [26:0] mux_shift_MERGE_COMPARE_for_exit_unr1_0_0_ln456_q;
  reg [22:0] memread_pop_ln523_unr0_0_9_q;
  reg [1023:0] mux_regs_in_ln456_30_q;
  reg and_0_ln523_unr1_q;
  reg and_0_ln523_unr10_q;
  reg and_0_ln523_unr11_q;
  reg and_0_ln523_unr12_q;
  reg and_0_ln523_unr13_q;
  reg and_0_ln523_unr14_q;
  reg and_0_ln523_unr15_q;
  reg and_0_ln523_unr16_q;
  reg and_0_ln523_unr17_q;
  reg and_0_ln523_unr18_q;
  reg and_0_ln523_unr19_q;
  reg and_0_ln523_unr2_q;
  reg and_0_ln523_unr20_q;
  reg and_0_ln523_unr21_q;
  reg and_0_ln523_unr22_q;
  reg and_0_ln523_unr23_q;
  reg and_0_ln523_unr24_q;
  reg and_0_ln523_unr25_q;
  reg and_0_ln523_unr26_q;
  reg and_0_ln523_unr27_q;
  reg and_0_ln523_unr28_q;
  reg and_0_ln523_unr29_q;
  reg and_0_ln523_unr3_q;
  reg and_0_ln523_unr30_q;
  reg and_0_ln523_unr31_q;
  reg and_0_ln523_unr4_q;
  reg and_0_ln523_unr5_q;
  reg and_0_ln523_unr6_q;
  reg and_0_ln523_unr7_q;
  reg and_0_ln523_unr8_q;
  reg and_0_ln523_unr9_q;
  reg or_and_0_ln521_Z_0_unr0_Z_0_tag_0;
  reg or_and_0_ln521_Z_0_unr10_q;
  reg or_and_0_ln521_Z_0_unr11_q;
  reg or_and_0_ln521_Z_0_unr12_q;
  reg or_and_0_ln521_Z_0_unr13_q;
  reg or_and_0_ln521_Z_0_unr14_q;
  reg or_and_0_ln521_Z_0_unr15_q;
  reg or_and_0_ln521_Z_0_unr16_q;
  reg or_and_0_ln521_Z_0_unr17_q;
  reg or_and_0_ln521_Z_0_unr18_q;
  reg or_and_0_ln521_Z_0_unr19_q;
  reg or_and_0_ln521_Z_0_unr20_q;
  reg or_and_0_ln521_Z_0_unr21_q;
  reg or_and_0_ln521_Z_0_unr22_q;
  reg or_and_0_ln521_Z_0_unr23_q;
  reg or_and_0_ln521_Z_0_unr24_q;
  reg or_and_0_ln521_Z_0_unr25_q;
  reg or_and_0_ln521_Z_0_unr26_q;
  reg or_and_0_ln521_Z_0_unr27_q;
  reg or_and_0_ln521_Z_0_unr28_q;
  reg or_and_0_ln521_Z_0_unr29_q;
  reg or_and_0_ln521_Z_0_unr30_q;
  reg or_and_0_ln521_Z_0_unr31_q;
  reg or_and_0_ln521_Z_0_unr9_q;
  reg and_0_ln523_unr0_q;
  reg [95:0] 
  mux_regs_0_MERGE_SEQ_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_q;
  reg and_0_ln521_unr1_Z_0_tag_0;
  reg and_0_ln521_unr2_Z_0_tag_0;
  reg and_0_ln521_unr3_Z_0_tag_0;
  reg and_0_ln521_unr4_Z_0_tag_0;
  reg and_0_ln521_unr5_Z_0_tag_0;
  reg and_0_ln521_unr6_Z_0_tag_0;
  reg and_0_ln521_unr7_Z_0_tag_0;
  reg and_1_ln523_unr8_0_q;
  reg and_0_ln521_unr8_Z_0_tag_0;
  reg B0_bridge0_rtl_CE_en;
  reg [9:0] B0_bridge0_rtl_a;
  reg [31:0] B0_bridge0_rtl_d;
  reg B1_bridge0_rtl_CE_en;
  reg [9:0] B1_bridge0_rtl_a;
  reg [31:0] B1_bridge0_rtl_d;
  reg C0_bridge1_rtl_CE_en;
  reg [9:0] C0_bridge1_rtl_a;
  wire [31:0] C0_bridge1_rtl_Q;
  reg C1_bridge1_rtl_CE_en;
  reg [9:0] C1_bridge1_rtl_a;
  wire [31:0] C1_bridge1_rtl_Q;
  reg [2:0] case_mux_head_ln387_0_z;
  reg [2:0] case_mux_head_ln440_1_z;
  reg [1023:0] mux_head_ln440_z;
  reg [1023:0] mux_regs_0_ln440_z;
  reg [991:0] mux_regs_in_ln440_z;
  reg [31:0] mux_elem_ln577_z;
  reg [31:0] mux_head_ln440_0_z;
  reg [5:0] mux_chunk_ln406_z;
  reg [1023:0] mux_head_ln440_1_z;
  reg ge_ln457_unr0_z;
  reg ge_ln457_unr16_z;
  reg ge_ln457_unr24_z;
  reg ge_ln457_unr28_z;
  reg ge_ln457_unr30_z;
  reg ge_ln457_unr10_z;
  reg ge_ln457_unr21_z;
  reg ge_ln457_unr6_z;
  reg ge_ln457_unr19_z;
  reg ge_ln457_unr2_z;
  reg ge_ln457_unr17_z;
  reg ge_ln457_unr15_z;
  reg ge_ln457_unr13_z;
  reg ge_ln457_unr11_z;
  reg ge_ln457_unr9_z;
  reg ge_ln457_unr7_z;
  reg ge_ln457_unr5_z;
  reg ge_ln457_unr3_z;
  reg ge_ln457_unr8_z;
  reg ge_ln457_unr20_z;
  reg ge_ln457_unr26_z;
  reg ge_ln457_unr29_z;
  reg ge_ln457_unr1_z;
  reg ge_ln457_unr12_z;
  reg ge_ln457_unr22_z;
  reg ge_ln457_unr27_z;
  reg ge_ln457_unr4_z;
  reg ge_ln457_unr18_z;
  reg ge_ln457_unr25_z;
  reg ge_ln457_unr14_z;
  reg ge_ln457_unr23_z;
  reg [63:0] mux_head_ln440_224_d_0;
  reg [63:0] mux_head_ln440_288_d_0;
  reg [63:0] mux_head_ln440_32_d_0;
  reg [63:0] mux_head_ln440_352_d_0;
  reg [63:0] mux_head_ln440_416_d_0;
  reg [63:0] mux_head_ln440_480_d_0;
  reg [63:0] mux_head_ln440_544_d_0;
  reg [63:0] mux_head_ln440_608_d_0;
  reg [63:0] mux_head_ln440_672_d_0;
  reg [63:0] mux_head_ln440_736_d_0;
  reg [63:0] mux_head_ln440_800_d_0;
  reg [63:0] mux_head_ln440_864_d_0;
  reg [63:0] mux_head_ln440_928_d_0;
  reg [63:0] mux_head_ln440_96_d_0;
  reg [63:0] mux_head_ln440_160_d_0;
  reg [63:0] mux_regs_0_ln440_160_d_0;
  reg [63:0] mux_regs_0_ln440_224_d_0;
  reg [63:0] mux_regs_0_ln440_288_d_0;
  reg [63:0] mux_regs_0_ln440_32_d_0;
  reg [63:0] mux_regs_0_ln440_352_d_0;
  reg [63:0] mux_regs_0_ln440_416_d_0;
  reg [63:0] mux_regs_0_ln440_480_d_0;
  reg [63:0] mux_regs_0_ln440_544_d_0;
  reg [63:0] mux_regs_0_ln440_608_d_0;
  reg [63:0] mux_regs_0_ln440_672_d_0;
  reg [63:0] mux_regs_0_ln440_736_d_0;
  reg [63:0] mux_regs_0_ln440_800_d_0;
  reg [63:0] mux_regs_0_ln440_864_d_0;
  reg [63:0] mux_regs_0_ln440_928_d_0;
  reg [63:0] mux_regs_0_ln440_96_d_0;
  reg [63:0] mux_regs_0_ln440_992_d_0;
  reg [63:0] mux_cur_ln440_d;
  reg [5:0] add_ln406_z;
  reg [9:0] mux_fidx_ln440_1014_d_0;
  reg [63:0] mux_fidx_ln440_118_d_0;
  reg [63:0] mux_fidx_ln440_182_d_0;
  reg [63:0] mux_fidx_ln440_246_d_0;
  reg [63:0] mux_fidx_ln440_310_d_0;
  reg [63:0] mux_fidx_ln440_374_d_0;
  reg [63:0] mux_fidx_ln440_438_d_0;
  reg [63:0] mux_fidx_ln440_502_d_0;
  reg [63:0] mux_fidx_ln440_54_d_0;
  reg [63:0] mux_fidx_ln440_566_d_0;
  reg [63:0] mux_fidx_ln440_630_d_0;
  reg [63:0] mux_fidx_ln440_694_d_0;
  reg [63:0] mux_fidx_ln440_758_d_0;
  reg [63:0] mux_fidx_ln440_822_d_0;
  reg [63:0] mux_fidx_ln440_886_d_0;
  reg [63:0] mux_fidx_ln440_950_d_0;
  reg [63:0] mux_cnt_ln440_d;
  reg merge_start_d;
  reg [31:0] eq_ln445_unr0_Z_0_tag_d_0;
  reg eq_ln507_Z_0_tag_d;
  reg [2:0] case_mux_shift_ln456_z;
  reg [9:0] mux_i_1_ln574_d;
  reg [63:0] mux_fidx_ln440_0_192_d_0;
  reg [63:0] mux_fidx_ln440_0_256_d_0;
  reg [63:0] mux_fidx_ln440_0_320_d_0;
  reg [63:0] mux_fidx_ln440_0_384_d_0;
  reg [63:0] mux_fidx_ln440_0_448_d_0;
  reg [63:0] mux_fidx_ln440_0_512_d_0;
  reg [63:0] mux_fidx_ln440_0_576_d_0;
  reg [63:0] mux_fidx_ln440_0_640_d_0;
  reg [63:0] mux_fidx_ln440_0_64_d_0;
  reg [63:0] mux_fidx_ln440_0_704_d_0;
  reg [63:0] mux_fidx_ln440_0_768_d_0;
  reg [63:0] mux_fidx_ln440_0_832_d_0;
  reg [63:0] mux_fidx_ln440_0_896_d_0;
  reg [63:0] mux_fidx_ln440_0_960_d_0;
  reg [63:0] mux_fidx_ln440_0_d;
  reg [63:0] mux_fidx_ln440_0_128_d_0;
  reg [34:0] mux_head_ln440_992_d_0;
  reg [1023:0] memwrite_fidx_ln414_z;
  reg [63:0] mux_cnt_ln507_d;
  reg [63:0] mux_fidx_ln406_128_d_0;
  reg [63:0] mux_fidx_ln406_192_d_0;
  reg [63:0] mux_fidx_ln406_256_d_0;
  reg [63:0] mux_fidx_ln406_320_d_0;
  reg [63:0] mux_fidx_ln406_384_d_0;
  reg [63:0] mux_fidx_ln406_448_d_0;
  reg [63:0] mux_fidx_ln406_512_d_0;
  reg [63:0] mux_fidx_ln406_576_d_0;
  reg [63:0] mux_fidx_ln406_640_d_0;
  reg [63:0] mux_fidx_ln406_64_d_0;
  reg [63:0] mux_fidx_ln406_704_d_0;
  reg [63:0] mux_fidx_ln406_768_d_0;
  reg [63:0] mux_fidx_ln406_832_d_0;
  reg [63:0] mux_fidx_ln406_896_d_0;
  reg [63:0] mux_fidx_ln406_960_d_0;
  reg [63:0] mux_fidx_ln406_d;
  reg eq_ln564_d;
  reg [9:0] mux_chunk_4_ln570_d;
  reg merge_done_d;
  reg [63:0] mux_head_ln387_128_d_0;
  reg [63:0] mux_head_ln387_192_d_0;
  reg [63:0] mux_head_ln387_256_d_0;
  reg [63:0] mux_head_ln387_320_d_0;
  reg [63:0] mux_head_ln387_384_d_0;
  reg [63:0] mux_head_ln387_448_d_0;
  reg [63:0] mux_head_ln387_512_d_0;
  reg [63:0] mux_head_ln387_576_d_0;
  reg [63:0] mux_head_ln387_640_d_0;
  reg [63:0] mux_head_ln387_64_d_0;
  reg [63:0] mux_head_ln387_704_d_0;
  reg [63:0] mux_head_ln387_768_d_0;
  reg [63:0] mux_head_ln387_832_d_0;
  reg [63:0] mux_head_ln387_896_d_0;
  reg [63:0] mux_head_ln387_960_d_0;
  reg [63:0] mux_head_ln387_d;
  reg [63:0] mux_regs_0_ln387_160_d_0;
  reg [63:0] mux_regs_0_ln387_224_d_0;
  reg [63:0] mux_regs_0_ln387_288_d_0;
  reg [63:0] mux_regs_0_ln387_32_d_0;
  reg [63:0] mux_regs_0_ln387_352_d_0;
  reg [63:0] mux_regs_0_ln387_416_d_0;
  reg [63:0] mux_regs_0_ln387_480_d_0;
  reg [63:0] mux_regs_0_ln387_544_d_0;
  reg [63:0] mux_regs_0_ln387_608_d_0;
  reg [63:0] mux_regs_0_ln387_672_d_0;
  reg [63:0] mux_regs_0_ln387_736_d_0;
  reg [63:0] mux_regs_0_ln387_800_d_0;
  reg [63:0] mux_regs_0_ln387_864_d_0;
  reg [63:0] mux_regs_0_ln387_928_d_0;
  reg [63:0] mux_regs_0_ln387_96_d_0;
  reg [63:0] mux_regs_in_ln387_128_d_0;
  reg [63:0] mux_regs_in_ln387_192_d_0;
  reg [63:0] mux_regs_in_ln387_256_d_0;
  reg [63:0] mux_regs_in_ln387_320_d_0;
  reg [63:0] mux_regs_in_ln387_384_d_0;
  reg [63:0] mux_regs_in_ln387_448_d_0;
  reg [63:0] mux_regs_in_ln387_512_d_0;
  reg [63:0] mux_regs_in_ln387_576_d_0;
  reg [63:0] mux_regs_in_ln387_640_d_0;
  reg [63:0] mux_regs_in_ln387_64_d_0;
  reg [63:0] mux_regs_in_ln387_704_d_0;
  reg [63:0] mux_regs_in_ln387_768_d_0;
  reg [63:0] mux_regs_in_ln387_832_d_0;
  reg [63:0] mux_regs_in_ln387_896_d_0;
  reg [63:0] mux_regs_in_ln387_960_d_0;
  reg [63:0] mux_regs_in_ln387_d;
  reg [63:0] mux_head_ln357_192_d_0;
  reg [63:0] mux_head_ln357_256_d_0;
  reg [63:0] mux_head_ln357_320_d_0;
  reg [63:0] mux_head_ln357_384_d_0;
  reg [63:0] mux_head_ln357_448_d_0;
  reg [63:0] mux_head_ln357_512_d_0;
  reg [63:0] mux_head_ln357_576_d_0;
  reg [63:0] mux_head_ln357_640_d_0;
  reg [63:0] mux_head_ln357_64_d_0;
  reg [63:0] mux_head_ln357_704_d_0;
  reg [63:0] mux_head_ln357_768_d_0;
  reg [63:0] mux_head_ln357_832_d_0;
  reg [63:0] mux_head_ln357_896_d_0;
  reg [63:0] mux_head_ln357_960_d_0;
  reg [63:0] mux_head_ln357_d;
  reg [63:0] mux_head_ln357_128_d_0;
  reg [63:0] mux_head_ln406_192_d_0;
  reg [63:0] mux_head_ln406_256_d_0;
  reg [63:0] mux_head_ln406_320_d_0;
  reg [63:0] mux_head_ln406_384_d_0;
  reg [63:0] mux_head_ln406_448_d_0;
  reg [63:0] mux_head_ln406_512_d_0;
  reg [63:0] mux_head_ln406_576_d_0;
  reg [63:0] mux_head_ln406_640_d_0;
  reg [63:0] mux_head_ln406_64_d_0;
  reg [63:0] mux_head_ln406_704_d_0;
  reg [63:0] mux_head_ln406_768_d_0;
  reg [63:0] mux_head_ln406_832_d_0;
  reg [63:0] mux_head_ln406_896_d_0;
  reg [63:0] mux_head_ln406_960_d_0;
  reg [63:0] mux_head_ln406_d;
  reg [63:0] mux_head_ln406_128_d_0;
  reg [63:0] mux_regs_0_ln357_224_d_0;
  reg [63:0] mux_regs_0_ln357_288_d_0;
  reg [63:0] mux_regs_0_ln357_32_d_0;
  reg [63:0] mux_regs_0_ln357_352_d_0;
  reg [63:0] mux_regs_0_ln357_416_d_0;
  reg [63:0] mux_regs_0_ln357_480_d_0;
  reg [63:0] mux_regs_0_ln357_544_d_0;
  reg [63:0] mux_regs_0_ln357_608_d_0;
  reg [63:0] mux_regs_0_ln357_672_d_0;
  reg [63:0] mux_regs_0_ln357_736_d_0;
  reg [63:0] mux_regs_0_ln357_800_d_0;
  reg [63:0] mux_regs_0_ln357_864_d_0;
  reg [63:0] mux_regs_0_ln357_928_d_0;
  reg [63:0] mux_regs_0_ln357_96_d_0;
  reg [63:0] mux_regs_in_ln357_128_d_0;
  reg [63:0] mux_regs_in_ln357_192_d_0;
  reg [63:0] mux_regs_in_ln357_256_d_0;
  reg [63:0] mux_regs_in_ln357_320_d_0;
  reg [63:0] mux_regs_in_ln357_384_d_0;
  reg [63:0] mux_regs_in_ln357_448_d_0;
  reg [63:0] mux_regs_in_ln357_512_d_0;
  reg [63:0] mux_regs_in_ln357_576_d_0;
  reg [63:0] mux_regs_in_ln357_640_d_0;
  reg [63:0] mux_regs_in_ln357_64_d_0;
  reg [63:0] mux_regs_in_ln357_704_d_0;
  reg [63:0] mux_regs_in_ln357_768_d_0;
  reg [63:0] mux_regs_in_ln357_832_d_0;
  reg [63:0] mux_regs_in_ln357_896_d_0;
  reg [63:0] mux_regs_in_ln357_960_d_0;
  reg [63:0] mux_regs_in_ln357_d;
  reg [63:0] mux_regs_0_ln357_160_d_0;
  reg mux_ping_ln357_Z_0_tag_d;
  reg [31:0] mux_burst_ln357_d_0;
  reg [63:0] read_sort_len_ln352_d;
  reg [4:0] gt_ln387_d_0;
  reg [63:0] mux_regs_0_ln510_128_d_0;
  reg [63:0] mux_regs_0_ln510_192_d_0;
  reg [63:0] mux_regs_0_ln510_256_d_0;
  reg [63:0] mux_regs_0_ln510_320_d_0;
  reg [63:0] mux_regs_0_ln510_384_d_0;
  reg [63:0] mux_regs_0_ln510_448_d_0;
  reg [63:0] mux_regs_0_ln510_512_d_0;
  reg [63:0] mux_regs_0_ln510_576_d_0;
  reg [63:0] mux_regs_0_ln510_640_d_0;
  reg [63:0] mux_regs_0_ln510_64_d_0;
  reg [63:0] mux_regs_0_ln510_704_d_0;
  reg [63:0] mux_regs_0_ln510_768_d_0;
  reg [63:0] mux_regs_0_ln510_832_d_0;
  reg [63:0] mux_regs_0_ln510_896_d_0;
  reg [63:0] mux_regs_0_ln510_960_d_0;
  reg [63:0] mux_regs_0_ln510_d;
  reg [31:0] memread_regs_ln510_z;
  reg [63:0] mux_head_ln536_123_d_0;
  reg [63:0] mux_head_ln536_187_d_0;
  reg [63:0] mux_head_ln536_251_d_0;
  reg [63:0] mux_head_ln536_315_d_0;
  reg [63:0] mux_head_ln536_379_d_0;
  reg [63:0] mux_head_ln536_443_d_0;
  reg [63:0] mux_head_ln536_507_d_0;
  reg [63:0] mux_head_ln536_571_d_0;
  reg [63:0] mux_head_ln536_59_d_0;
  reg [63:0] mux_head_ln536_635_d_0;
  reg [63:0] mux_head_ln536_699_d_0;
  reg [63:0] mux_head_ln536_763_d_0;
  reg [63:0] mux_head_ln536_827_d_0;
  reg [63:0] mux_head_ln536_891_d_0;
  reg [63:0] mux_head_ln536_955_d_0;
  reg [63:0] mux_pop_idx_ln520_0_d;
  reg [4:0] mux_head_ln536_1019_d_0;
  reg ne_ln534_Z_0_tag_d;
  reg [26:0] mux_shift_MERGE_COMPARE_for_exit_unr1_0_0_ln456_z;
  reg [28:0] memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_z;
  reg [1023:0] mux_regs_in_ln456_30_z;
  reg [31:0] memread_pop_ln523_unr0_0_z;
  reg [63:0] mux_regs_in_ln456_30_160_d_0;
  reg [63:0] mux_regs_in_ln456_30_224_d_0;
  reg [63:0] mux_regs_in_ln456_30_288_d_0;
  reg [63:0] mux_regs_in_ln456_30_32_d_0;
  reg [63:0] mux_regs_in_ln456_30_352_d_0;
  reg [63:0] mux_regs_in_ln456_30_416_d_0;
  reg [63:0] mux_regs_in_ln456_30_480_d_0;
  reg [63:0] mux_regs_in_ln456_30_544_d_0;
  reg [63:0] mux_regs_in_ln456_30_608_d_0;
  reg [63:0] mux_regs_in_ln456_30_672_d_0;
  reg [63:0] mux_regs_in_ln456_30_736_d_0;
  reg [63:0] mux_regs_in_ln456_30_800_d_0;
  reg [63:0] mux_regs_in_ln456_30_864_d_0;
  reg [63:0] mux_regs_in_ln456_30_928_d_0;
  reg [63:0] mux_regs_in_ln456_30_96_d_0;
  reg [31:0] mux_regs_in_ln456_30_992_d_0;
  reg and_0_ln523_unr1_z;
  reg and_0_ln523_unr10_z;
  reg and_0_ln523_unr11_z;
  reg and_0_ln523_unr12_z;
  reg and_0_ln523_unr13_z;
  reg and_0_ln523_unr14_z;
  reg and_0_ln523_unr15_z;
  reg and_0_ln523_unr16_z;
  reg and_0_ln523_unr17_z;
  reg and_0_ln523_unr18_z;
  reg and_0_ln523_unr19_z;
  reg and_0_ln523_unr2_z;
  reg and_0_ln523_unr20_z;
  reg and_0_ln523_unr21_z;
  reg and_0_ln523_unr22_z;
  reg and_0_ln523_unr23_z;
  reg and_0_ln523_unr24_z;
  reg and_0_ln523_unr25_z;
  reg and_0_ln523_unr26_z;
  reg and_0_ln523_unr27_z;
  reg and_0_ln523_unr28_z;
  reg and_0_ln523_unr29_z;
  reg and_0_ln523_unr3_z;
  reg and_0_ln523_unr30_z;
  reg and_0_ln523_unr31_z;
  reg and_0_ln523_unr4_z;
  reg and_0_ln523_unr5_z;
  reg and_0_ln523_unr6_z;
  reg and_0_ln523_unr7_z;
  reg and_0_ln523_unr8_z;
  reg and_0_ln523_unr9_z;
  reg or_and_0_ln521_Z_0_unr0_z;
  reg or_and_0_ln521_Z_0_unr10_z;
  reg or_and_0_ln521_Z_0_unr11_z;
  reg or_and_0_ln521_Z_0_unr12_z;
  reg or_and_0_ln521_Z_0_unr13_z;
  reg or_and_0_ln521_Z_0_unr14_z;
  reg or_and_0_ln521_Z_0_unr15_z;
  reg or_and_0_ln521_Z_0_unr16_z;
  reg or_and_0_ln521_Z_0_unr17_z;
  reg or_and_0_ln521_Z_0_unr18_z;
  reg or_and_0_ln521_Z_0_unr19_z;
  reg or_and_0_ln521_Z_0_unr20_z;
  reg or_and_0_ln521_Z_0_unr21_z;
  reg or_and_0_ln521_Z_0_unr22_z;
  reg or_and_0_ln521_Z_0_unr23_z;
  reg or_and_0_ln521_Z_0_unr24_z;
  reg or_and_0_ln521_Z_0_unr25_z;
  reg or_and_0_ln521_Z_0_unr26_z;
  reg or_and_0_ln521_Z_0_unr27_z;
  reg or_and_0_ln521_Z_0_unr28_z;
  reg or_and_0_ln521_Z_0_unr29_z;
  reg or_and_0_ln521_Z_0_unr30_z;
  reg or_and_0_ln521_Z_0_unr31_z;
  reg or_and_0_ln521_Z_0_unr9_z;
  reg and_0_ln523_unr0_z;
  reg [95:0] 
  mux_regs_0_MERGE_SEQ_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
  reg and_0_ln521_unr1_z;
  reg and_0_ln521_unr2_z;
  reg and_0_ln521_unr3_z;
  reg and_0_ln521_unr4_z;
  reg and_0_ln521_unr5_z;
  reg and_0_ln521_unr6_z;
  reg and_0_ln521_unr7_z;
  reg and_1_ln523_unr8_0_z;
  reg and_0_ln521_unr8_z;
  reg [21:0] state_sort_unisim_sort_rb_sort;
  reg [21:0] state_sort_unisim_sort_rb_sort_next;
  reg [1023:0] mux_regs_ln260_q;
  reg mux_i_2_ln317_q;
  reg mux_k_ln280_unr0_q;
  reg mux_k_ln280_unr1_q;
  reg [4:0] mux_wchunk_ln248_reg_0_0;
  reg [1023:0] memwrite_regs_ln273_unr1_q;
  reg [4:0] add_ln317_1_q;
  reg [4:0] add_ln266_1_unr1_q;
  reg [4:0] add_ln270_1_unr1_q;
  reg [31:0] memread_regs_ln266_unr1_q;
  reg [4:0] add_ln264_unr1_q;
  reg [4:0] add_ln280_unr0_1_q;
  reg [4:0] add_ln280_unr1_1_q;
  reg [1023:0] mux_regs_ln260_0_q;
  reg [1023:0] memwrite_regs_ln273_unr0_q;
  reg [4:0] mux_i_ln260_unr0_q;
  reg [4:0] add_ln260_unr0_1_q;
  reg [5:0] mux_i_ln260_unr1_q;
  reg [4:0] add_ln260_unr1_1_q;
  reg [31:0] memread_regs_ln284_unr1_unr1_0_q;
  reg [31:0] memread_regs_ln294_unr0_unr1_0_32_q;
  reg [31:0] memread_regs_ln294_unr0_unr0_0_32_q;
  reg [31:0] memread_regs_ln284_unr1_unr0_0_q;
  reg [63:0] mux_regs_ln280_0_q;
  reg [63:0] mux_regs_ln254_0_q;
  reg [63:0] mux_regs_ln254_1_q;
  reg [63:0] mux_regs_ln280_2_q;
  reg [2047:0] mux_regs_ln228_q;
  reg mux_idx_0_ln312_q;
  reg [4:0] mux_wchunk_ln312_q;
  reg [3:0] add_ln324_1_q;
  reg [63:0] mux_regs_ln260_1_q;
  reg [63:0] memread_regs_ln294_unr1_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr2_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr3_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr4_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr5_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr6_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr7_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr8_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr9_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr10_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr11_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr12_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr13_unr1_0_q;
  reg [63:0] memread_regs_ln294_unr14_unr1_0_q;
  reg [4:0] add_ln276_unr0_q;
  reg [4:0] mux_wchunk_ln248_q;
  reg [4:0] add_ln276_unr1_q;
  reg [4:0] mux_chunk_ln248_q;
  reg [29:0] add_ln254_0_unr1_1_q;
  reg mux_pipe_full_ln248_Z_0_tag_0;
  reg eq_ln255_unr1_q;
  reg [30:0] add_ln254_0_unr0_1_q;
  reg [63:0] memread_regs_ln294_unr1_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr2_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr12_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr13_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr14_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr3_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr4_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr5_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr6_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr7_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr8_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr9_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr10_unr0_0_q;
  reg [63:0] memread_regs_ln294_unr11_unr0_0_q;
  reg [1023:0] mux_regs_ln248_reg_0_0;
  reg mux_ping_ln228_q;
  reg mux_burst_ln228_q;
  reg [30:0] add_ln334_1_q;
  reg [2047:0] mux_regs_ln248_q;
  reg [31:0] read_sort_len_ln224_q;
  reg [31:0] read_sort_batch_ln225_q;
  reg A0_bridge1_rtl_CE_en;
  reg [9:0] A0_bridge1_rtl_a;
  wire [31:0] A0_bridge1_rtl_Q;
  reg A1_bridge1_rtl_CE_en;
  reg [9:0] A1_bridge1_rtl_a;
  wire [31:0] A1_bridge1_rtl_Q;
  reg C0_bridge0_rtl_CE_en;
  reg [9:0] C0_bridge0_rtl_a;
  reg [31:0] C0_bridge0_rtl_d;
  reg C1_bridge0_rtl_CE_en;
  reg [9:0] C1_bridge0_rtl_a;
  reg [31:0] C1_bridge0_rtl_d;
  reg [1023:0] mux_regs_ln260_z;
  reg [1023:0] mux_regs_ln280_z;
  reg [1023:0] mux_regs_ln280_1_z;
  reg [4:0] mux_i_2_ln317_z;
  reg [4:0] mux_i_ln260_unr0_z;
  reg [5:0] mux_i_ln260_unr1_z;
  reg [4:0] mux_k_ln280_unr0_z;
  reg [4:0] mux_k_ln280_unr1_z;
  reg [4:0] mux_wchunk_ln248_z;
  reg [2047:0] mux_regs_ln248_z;
  reg [1023:0] memwrite_regs_ln273_unr1_z;
  reg [5:0] add_ln317_z;
  reg [4:0] add_ln266_1_unr1_z;
  reg [4:0] add_ln270_1_unr1_z;
  reg [31:0] memread_regs_ln266_unr1_z;
  reg [3:0] mux_i_ln260_unr1_1_d_0;
  reg [4:0] add_ln264_unr1_z;
  reg [5:0] add_ln280_unr0_z;
  reg [5:0] add_ln280_unr1_z;
  reg rb_start_d;
  reg [63:0] mux_regs_ln260_0_192_d_0;
  reg [63:0] mux_regs_ln260_0_256_d_0;
  reg [63:0] mux_regs_ln260_0_320_d_0;
  reg [63:0] mux_regs_ln260_0_384_d_0;
  reg [63:0] mux_regs_ln260_0_448_d_0;
  reg [63:0] mux_regs_ln260_0_512_d_0;
  reg [63:0] mux_regs_ln260_0_576_d_0;
  reg [63:0] mux_regs_ln260_0_640_d_0;
  reg [63:0] mux_regs_ln260_0_64_d_0;
  reg [63:0] mux_regs_ln260_0_704_d_0;
  reg [63:0] mux_regs_ln260_0_768_d_0;
  reg [63:0] mux_regs_ln260_0_832_d_0;
  reg [63:0] mux_regs_ln260_0_896_d_0;
  reg [63:0] mux_regs_ln260_0_960_d_0;
  reg [63:0] mux_regs_ln260_0_d;
  reg [63:0] mux_regs_ln260_0_128_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_192_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_256_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_320_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_384_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_448_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_512_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_576_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_640_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_64_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_704_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_768_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_832_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_896_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_960_d_0;
  reg [63:0] memwrite_regs_ln273_unr0_d;
  reg [63:0] memwrite_regs_ln273_unr0_128_d_0;
  reg [5:0] mux_i_ln260_unr0_d;
  reg [5:0] mux_i_ln260_unr1_d;
  reg [63:0] memread_regs_ln284_unr1_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr2_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr3_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr12_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr13_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr14_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr15_unr0_0_z;
  reg [63:0] memread_regs_ln294_unr0_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr4_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr5_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr6_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr7_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr8_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr9_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr10_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr11_unr0_0_z;
  reg [63:0] memread_regs_ln284_unr1_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr2_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr3_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr4_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr5_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr6_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr7_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr8_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr9_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr10_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr11_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr12_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr13_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr14_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr15_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr0_unr1_0_z;
  reg [63:0] memread_regs_ln284_unr1_unr0_0_d;
  reg [63:0] mux_regs_ln280_0_z;
  reg [63:0] mux_regs_ln254_0_z;
  reg [63:0] mux_regs_ln280_2_z;
  reg [63:0] mux_regs_ln254_1_z;
  reg [63:0] mux_regs_ln228_1024_d_0;
  reg [63:0] mux_regs_ln228_1088_d_0;
  reg [63:0] mux_regs_ln228_1152_d_0;
  reg [63:0] mux_regs_ln228_1216_d_0;
  reg [63:0] mux_regs_ln228_1280_d_0;
  reg [63:0] mux_regs_ln228_128_d_0;
  reg [63:0] mux_regs_ln228_1344_d_0;
  reg [63:0] mux_regs_ln228_1408_d_0;
  reg [63:0] mux_regs_ln228_1472_d_0;
  reg [63:0] mux_regs_ln228_1536_d_0;
  reg [63:0] mux_regs_ln228_1600_d_0;
  reg [63:0] mux_regs_ln228_1664_d_0;
  reg [63:0] mux_regs_ln228_1728_d_0;
  reg [63:0] mux_regs_ln228_1792_d_0;
  reg [63:0] mux_regs_ln228_1856_d_0;
  reg [63:0] mux_regs_ln228_1920_d_0;
  reg [63:0] mux_regs_ln228_192_d_0;
  reg [63:0] mux_regs_ln228_1984_d_0;
  reg [63:0] mux_regs_ln228_256_d_0;
  reg [63:0] mux_regs_ln228_320_d_0;
  reg [63:0] mux_regs_ln228_384_d_0;
  reg [63:0] mux_regs_ln228_448_d_0;
  reg [63:0] mux_regs_ln228_512_d_0;
  reg [63:0] mux_regs_ln228_576_d_0;
  reg [63:0] mux_regs_ln228_640_d_0;
  reg [63:0] mux_regs_ln228_64_d_0;
  reg [63:0] mux_regs_ln228_704_d_0;
  reg [63:0] mux_regs_ln228_768_d_0;
  reg [63:0] mux_regs_ln228_832_d_0;
  reg [63:0] mux_regs_ln228_896_d_0;
  reg [63:0] mux_regs_ln228_960_d_0;
  reg [63:0] mux_regs_ln228_d;
  reg rb_done_d;
  reg [9:0] mux_idx_0_ln312_d_0;
  reg [63:0] mux_regs_ln260_1_d;
  reg [63:0] memread_regs_ln294_unr1_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr2_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr3_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr4_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr5_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr6_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr7_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr8_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr9_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr10_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr11_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr12_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr13_unr1_0_z;
  reg [63:0] memread_regs_ln294_unr14_unr1_0_z;
  reg [8:0] add_ln276_unr0_d;
  reg [7:0] mux_chunk_ln248_2_d_0;
  reg [36:0] mux_chunk_ln248_d;
  reg mux_pipe_full_ln248_Z_0_tag_d;
  reg [27:0] add_ln254_0_unr0_1_4_d_0;
  reg [63:0] memread_regs_ln294_unr1_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr2_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr12_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr13_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr14_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr3_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr4_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr5_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr6_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr7_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr8_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr9_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr10_unr0_0_d;
  reg [63:0] memread_regs_ln294_unr11_unr0_0_d;
  reg [63:0] mux_regs_ln248_reg_0_128_d_0;
  reg [63:0] mux_regs_ln248_reg_0_192_d_0;
  reg [63:0] mux_regs_ln248_reg_0_256_d_0;
  reg [63:0] mux_regs_ln248_reg_0_320_d_0;
  reg [63:0] mux_regs_ln248_reg_0_384_d_0;
  reg [63:0] mux_regs_ln248_reg_0_448_d_0;
  reg [63:0] mux_regs_ln248_reg_0_512_d_0;
  reg [63:0] mux_regs_ln248_reg_0_576_d_0;
  reg [63:0] mux_regs_ln248_reg_0_640_d_0;
  reg [63:0] mux_regs_ln248_reg_0_64_d_0;
  reg [63:0] mux_regs_ln248_reg_0_704_d_0;
  reg [63:0] mux_regs_ln248_reg_0_768_d_0;
  reg [63:0] mux_regs_ln248_reg_0_832_d_0;
  reg [63:0] mux_regs_ln248_reg_0_896_d_0;
  reg [63:0] mux_regs_ln248_reg_0_960_d_0;
  reg [63:0] mux_regs_ln248_reg_0_d;
  reg mux_ping_ln228_d;
  reg [31:0] mux_burst_ln228_d_0;
  reg [63:0] mux_regs_ln248_1088_d_0;
  reg [63:0] mux_regs_ln248_1152_d_0;
  reg [63:0] mux_regs_ln248_1216_d_0;
  reg [63:0] mux_regs_ln248_1280_d_0;
  reg [63:0] mux_regs_ln248_1344_d_0;
  reg [63:0] mux_regs_ln248_1408_d_0;
  reg [63:0] mux_regs_ln248_1472_d_0;
  reg [63:0] mux_regs_ln248_1536_d_0;
  reg [63:0] mux_regs_ln248_1600_d_0;
  reg [63:0] mux_regs_ln248_1664_d_0;
  reg [63:0] mux_regs_ln248_1728_d_0;
  reg [63:0] mux_regs_ln248_1792_d_0;
  reg [63:0] mux_regs_ln248_1856_d_0;
  reg [63:0] mux_regs_ln248_1920_d_0;
  reg [63:0] mux_regs_ln248_1984_d_0;
  reg [63:0] mux_regs_ln248_1024_d_0;
  reg [63:0] read_sort_len_ln224_d;
  reg [6:0] state_sort_unisim_sort_store_output;
  reg [6:0] state_sort_unisim_sort_store_output_next;
  reg [31:0] mux_elem_ln200_q;
  reg mux_i_ln195_q;
  reg [9:0] add_ln195_1_q;
  reg [30:0] add_ln187_1_q;
  reg mux_ping_ln168_Z_0_tag_0;
  reg mux_burst_ln168_q;
  reg [31:0] read_sort_batch_ln165_q;
  reg [31:0] add_ln186_q;
  reg [31:0] read_sort_len_ln164_q;
  reg [31:0] mux_index_ln168_q;
  reg memread_sort_B0_ln201_en;
  reg [10:0] mux_i_ln195_z;
  wire [31:0] memread_sort_B0_ln201_rtl_Q;
  reg memread_sort_B1_ln203_en;
  wire [31:0] memread_sort_B1_ln203_rtl_Q;
  reg [31:0] mux_mux_elem_ln200_Z_v;
  reg output_start_d;
  reg [31:0] wr_length_d;
  reg [31:0] wr_index_d;
  reg wr_request_d;
  reg bufdout_set_valid_curr_d;
  reg [10:0] mux_i_ln195_d_0;
  reg [31:0] bufdout_data_d;
  reg [31:0] add_ln186_31_d_0;
  reg mux_ping_ln168_Z_0_tag_d;
  reg [63:0] read_sort_batch_ln165_d;
  reg [63:0] read_sort_len_ln164_d;
  reg sort_done_d;

  // synthesis translate_off
  always @(posedge clk) // CtoS_Race_condition_checker_A0
    begin
      if (A0_bridge1_rtl_CE_en + memwrite_sort_A0_ln124_en > 1 && 
      memwrite_sort_A0_ln124_en) begin
        if (memwrite_sort_A0_ln124_en && A0_bridge1_rtl_CE_en && 
        memwrite_sort_A0_ln124_en && mux_mux_i_ln119_Z_v === A0_bridge1_rtl_a) 
        begin
          $display(
          "Warning: Potential race condition detected in module %m for memory A0 @ time %0d:\n", $time);
        end
      end
    end
  // synthesis translate_on
  sort_unisim_ram_1024x32p_1w_1r A0(.CLK(clk), .CE0(A0_CE0), .A0(A0_A0), .D0(
                                 A0_D0), .WE0(A0_WE0), .CE1(A0_CE1), .A1(A0_A1), 
                                 .Q1(A0_Q1));
  // synthesis translate_off
  always @(posedge clk) // CtoS_Race_condition_checker_A1
    begin
      if (A1_bridge1_rtl_CE_en + memwrite_sort_A1_ln128_en > 1 && 
      memwrite_sort_A1_ln128_en) begin
        if (memwrite_sort_A1_ln128_en && A1_bridge1_rtl_CE_en && 
        memwrite_sort_A1_ln128_en && mux_mux_i_ln119_Z_v === A1_bridge1_rtl_a) 
        begin
          $display(
          "Warning: Potential race condition detected in module %m for memory A1 @ time %0d:\n", $time);
        end
      end
    end
  // synthesis translate_on
  sort_unisim_ram_1024x32p_1w_1r A1(.CLK(clk), .CE0(A1_CE0), .A0(A1_A0), .D0(
                                 A1_D0), .WE0(A1_WE0), .CE1(A1_CE1), .A1(A1_A1), 
                                 .Q1(A1_Q1));
  // synthesis translate_off
  always @(posedge clk) // CtoS_Race_condition_checker_C0
    begin
      if (C0_bridge1_rtl_CE_en + C0_bridge0_rtl_CE_en > 1 && 
      C0_bridge0_rtl_CE_en) begin
        if (C0_bridge0_rtl_CE_en && C0_bridge1_rtl_CE_en && C0_bridge0_rtl_CE_en && 
        C0_bridge0_rtl_a === C0_bridge1_rtl_a) begin
          $display(
          "Warning: Potential race condition detected in module %m for memory C0 @ time %0d:\n", $time);
        end
      end
    end
  // synthesis translate_on
  sort_unisim_ram_1024x32p_1w_1r C0(.CLK(clk), .CE0(C0_CE0), .A0(C0_A0), .D0(
                                 C0_D0), .WE0(C0_WE0), .CE1(C0_CE1), .A1(C0_A1), 
                                 .Q1(C0_Q1));
  // synthesis translate_off
  always @(posedge clk) // CtoS_Race_condition_checker_C1
    begin
      if (C1_bridge1_rtl_CE_en + C1_bridge0_rtl_CE_en > 1 && 
      C1_bridge0_rtl_CE_en) begin
        if (C1_bridge0_rtl_CE_en && C1_bridge1_rtl_CE_en && C1_bridge0_rtl_CE_en && 
        C1_bridge0_rtl_a === C1_bridge1_rtl_a) begin
          $display(
          "Warning: Potential race condition detected in module %m for memory C1 @ time %0d:\n", $time);
        end
      end
    end
  // synthesis translate_on
  sort_unisim_ram_1024x32p_1w_1r C1(.CLK(clk), .CE0(C1_CE0), .A0(C1_A0), .D0(
                                 C1_D0), .WE0(C1_WE0), .CE1(C1_CE1), .A1(C1_A1), 
                                 .Q1(C1_Q1));
  // synthesis translate_off
  always @(posedge clk) // CtoS_Race_condition_checker_B0
    begin
      if (memread_sort_B0_ln201_en + B0_bridge0_rtl_CE_en > 1 && 
      B0_bridge0_rtl_CE_en) begin
        if (B0_bridge0_rtl_CE_en && memread_sort_B0_ln201_en && 
        B0_bridge0_rtl_CE_en && B0_bridge0_rtl_a === mux_i_ln195_z[9:0]) begin
          $display(
          "Warning: Potential race condition detected in module %m for memory B0 @ time %0d:\n", $time);
        end
      end
    end
  // synthesis translate_on
  sort_unisim_ram_1024x32p_1w_1r B0(.CLK(clk), .CE0(B0_CE0), .A0(B0_A0), .D0(
                                 B0_D0), .WE0(B0_WE0), .CE1(B0_CE1), .A1(B0_A1), 
                                 .Q1(B0_Q1));
  // synthesis translate_off
  always @(posedge clk) // CtoS_Race_condition_checker_B1
    begin
      if (memread_sort_B1_ln203_en + B1_bridge0_rtl_CE_en > 1 && 
      B1_bridge0_rtl_CE_en) begin
        if (B1_bridge0_rtl_CE_en && memread_sort_B1_ln203_en && 
        B1_bridge0_rtl_CE_en && B1_bridge0_rtl_a === mux_i_ln195_z[9:0]) begin
          $display(
          "Warning: Potential race condition detected in module %m for memory B1 @ time %0d:\n", $time);
        end
      end
    end
  // synthesis translate_on
  sort_unisim_ram_1024x32p_1w_1r B1(.CLK(clk), .CE0(B1_CE0), .A0(B1_A0), .D0(
                                 B1_D0), .WE0(B1_WE0), .CE1(B1_CE1), .A1(B1_A1), 
                                 .Q1(B1_Q1));
  sort_unisim_sort_bufdin_can_get_mod_process 
                                              sort_unisim_sort_bufdin_can_get_mod_process(
                                              .bufdin_valid(bufdin_valid), .bufdin_ready(
                                              bufdin_ready), .bufdin_can_get_sig(
                                              bufdin_can_get_sig));
  sort_unisim_sort_bufdin_sync_rcv_back_method 
                                               sort_unisim_sort_bufdin_sync_rcv_back_method(
                                               .clk(clk), .rst(rst), .bufdin_valid(
                                               bufdin_valid), .bufdin_ready(
                                               bufdin_ready), .bufdin_set_ready_curr(
                                               bufdin_set_ready_curr), .bufdin_data(
                                               bufdin_data), .bufdin_sync_rcv_set_ready_prev(
                                               bufdin_sync_rcv_set_ready_prev), 
                                               .bufdin_sync_rcv_reset_ready_prev(
                                               bufdin_sync_rcv_reset_ready_prev), 
                                               .bufdin_sync_rcv_reset_ready_curr(
                                               bufdin_sync_rcv_reset_ready_curr), 
                                               .bufdin_sync_rcv_ready_flop(
                                               bufdin_sync_rcv_ready_flop), .bufdin_data_buf(
                                               bufdin_data_buf));
  sort_unisim_sort_bufdin_sync_rcv_ready_arb 
                                             sort_unisim_sort_bufdin_sync_rcv_ready_arb(
                                             .bufdin_set_ready_curr(
                                             bufdin_set_ready_curr), .bufdin_sync_rcv_set_ready_prev(
                                             bufdin_sync_rcv_set_ready_prev), .bufdin_sync_rcv_reset_ready_curr(
                                             bufdin_sync_rcv_reset_ready_curr), 
                                             .bufdin_sync_rcv_reset_ready_prev(
                                             bufdin_sync_rcv_reset_ready_prev), 
                                             .bufdin_sync_rcv_ready_flop(
                                             bufdin_sync_rcv_ready_flop), .bufdin_ready(
                                             bufdin_ready));
  sort_unisim_sort_bufdout_can_put_mod_process 
                                               sort_unisim_sort_bufdout_can_put_mod_process(
                                               .bufdout_valid(bufdout_valid), .bufdout_ready(
                                               bufdout_ready), .bufdout_can_put_sig(
                                               bufdout_can_put_sig));
  sort_unisim_sort_bufdout_sync_snd_back_method 
                                                sort_unisim_sort_bufdout_sync_snd_back_method(
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
  sort_unisim_sort_bufdout_sync_snd_valid_arb 
                                              sort_unisim_sort_bufdout_sync_snd_valid_arb(
                                              .bufdout_set_valid_curr(
                                              bufdout_set_valid_curr), .bufdout_sync_snd_set_valid_prev(
                                              bufdout_sync_snd_set_valid_prev), 
                                              .bufdout_sync_snd_reset_valid_curr(
                                              bufdout_sync_snd_reset_valid_curr), 
                                              .bufdout_sync_snd_reset_valid_prev(
                                              bufdout_sync_snd_reset_valid_prev), 
                                              .bufdout_sync_snd_valid_flop(
                                              bufdout_sync_snd_valid_flop), .bufdout_valid(
                                              bufdout_valid));
  // synthesis sync_set_reset_local sort_unisim_sort_config_sort_seq_block rst
  always @(posedge clk) // sort_unisim_sort_config_sort_sequential
    begin : sort_unisim_sort_config_sort_seq_block
      if (!rst) // Initialize state and outputs
      begin
        len <= 32'sh0;
        batch <= 32'sh0;
        init_done <= 1'sb0;
        state_sort_unisim_sort_config_sort <= 2'h1;
      end
      else // Update Q values
      begin
        len <= len_d;
        batch <= batch_d;
        init_done <= init_done_d;
        state_sort_unisim_sort_config_sort <= 
        state_sort_unisim_sort_config_sort_next;
      end
    end
  always @(*) begin : sort_unisim_sort_config_sort_combinational
      reg ctrlAnd_1_ln62_z;
      reg ctrlAnd_0_ln62_z;
      reg ctrlOr_ln72_z;

      state_sort_unisim_sort_config_sort_next = 2'h0;
      if (state_sort_unisim_sort_config_sort[0]) 
        len_d = conf_len;
      else 
        len_d = len;
      if (state_sort_unisim_sort_config_sort[0]) 
        batch_d = conf_batch;
      else 
        batch_d = batch;
      ctrlAnd_1_ln62_z = conf_done & state_sort_unisim_sort_config_sort[0];
      ctrlAnd_0_ln62_z = !conf_done & state_sort_unisim_sort_config_sort[0];
      ctrlOr_ln72_z = state_sort_unisim_sort_config_sort[1] | ctrlAnd_1_ln62_z;
      if (ctrlAnd_1_ln62_z) 
        init_done_d = 1'b1;
      else 
        init_done_d = init_done;
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_config_sort[0]: // Wait_ln63
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln62_z: state_sort_unisim_sort_config_sort_next[0] = 
                1'b1;
              ctrlOr_ln72_z: state_sort_unisim_sort_config_sort_next[1] = 1'b1;
              default: state_sort_unisim_sort_config_sort_next = 2'hX;
            endcase
          end
        state_sort_unisim_sort_config_sort[1]: // Wait_ln73
          state_sort_unisim_sort_config_sort_next[1] = 1'b1;
        default: // Don't care
          state_sort_unisim_sort_config_sort_next = 2'hX;
      endcase
    end
  sort_unisim_identity_sync_write_1024x32m0 A0_bridge0(.rtl_CE(
                                            memwrite_sort_A0_ln124_en), .rtl_A(
                                            mux_mux_i_ln119_Z_v), .rtl_D(
                                            mux_item_ln304_z), .rtl_WE(
                                            memwrite_sort_A0_ln124_en), .CLK(clk), 
                                            .mem_CE(A0_CE0), .mem_A(A0_A0), .mem_D(
                                            A0_D0), .mem_WE(A0_WE0));
  sort_unisim_identity_sync_write_1024x32m0 A1_bridge0(.rtl_CE(
                                            memwrite_sort_A1_ln128_en), .rtl_A(
                                            mux_mux_i_ln119_Z_v), .rtl_D(
                                            mux_item_ln304_z), .rtl_WE(
                                            memwrite_sort_A1_ln128_en), .CLK(clk), 
                                            .mem_CE(A1_CE0), .mem_A(A1_A0), .mem_D(
                                            A1_D0), .mem_WE(A1_WE0));
  // synthesis sync_set_reset_local sort_unisim_sort_load_input_seq_block rst
  always @(posedge clk) // sort_unisim_sort_load_input_sequential
    begin : sort_unisim_sort_load_input_seq_block
      if (!rst) // Initialize state and outputs
      begin
        rd_length <= 32'sh0;
        rd_index <= 32'sh0;
        rd_request <= 1'sb0;
        input_done <= 1'sb0;
        and_1_ln123_Z_0_tag_0 <= 1'sb0;
        and_0_ln123_Z_0_tag_0 <= 1'sb0;
        bufdin_set_ready_curr <= 1'sb0;
        state_sort_unisim_sort_load_input <= 7'h1;
      end
      else // Update Q values
      begin
        rd_length <= rd_length_d;
        rd_index <= rd_index_d;
        rd_request <= rd_request_d;
        input_done <= input_done_d;
        and_1_ln123_Z_0_tag_0 <= mux_and_1_ln123_Z_0_v;
        and_0_ln123_Z_0_tag_0 <= mux_and_0_ln123_Z_0_v;
        bufdin_set_ready_curr <= bufdin_set_ready_curr_d;
        state_sort_unisim_sort_load_input <= 
        state_sort_unisim_sort_load_input_next;
      end
    end
  always @(posedge clk) // sort_unisim_sort_load_input_0_sequential
    begin
      mux_i_ln119_q <= mux_mux_i_ln119_Z_v;
      add_ln119_1_q <= mux_add_ln119_Z_1_v_0;
      mux_burst_ln101_q <= read_sort_batch_ln98_d[32];
      mux_ping_ln101_q <= read_sort_batch_ln98_d[33];
      read_sort_batch_ln98_q <= read_sort_batch_ln98_d[31:0];
      add_ln111_1_q <= add_ln110_30_d_0[32:2];
      add_ln110_q <= {add_ln110_30_d_0[1:0], read_sort_batch_ln98_d[63:34]};
    end
  always @(*) begin : sort_unisim_sort_load_input_combinational
      reg unary_nor_ln98_z;
      reg ctrlAnd_1_ln115_z;
      reg ctrlAnd_0_ln115_z;
      reg ctrlAnd_1_ln135_z;
      reg ctrlAnd_0_ln135_z;
      reg ctrlAnd_1_ln138_z;
      reg ctrlAnd_0_ln138_z;
      reg ctrlAnd_1_ln89_z;
      reg ctrlAnd_0_ln89_z;
      reg [31:0] mux_index_ln101_z;
      reg mux_ping_ln101_z;
      reg [31:0] mux_read_sort_batch_ln98_Z_v;
      reg [31:0] mux_read_sort_len_ln97_Z_v;
      reg [31:0] mux_burst_ln101_z;
      reg [10:0] mux_i_ln119_z;
      reg ctrlOr_ln119_0_z;
      reg ctrlOr_ln138_z;
      reg ctrlOr_ln101_z;
      reg mux_mux_ping_ln101_Z_0_v;
      reg if_ln123_z;
      reg [31:0] mux_read_sort_batch_ln98_Z_0_mux_0_v;
      reg [31:0] add_ln110_z;
      reg eq_ln103_z;
      reg mux_mux_burst_ln101_Z_0_v;
      reg [31:0] add_ln111_z;
      reg eq_ln120_z;
      reg lt_ln119_z;
      reg [10:0] add_ln119_z;
      reg [31:0] mux_add_ln110_Z_v;
      reg [30:0] mux_add_ln111_Z_1_v_0;
      reg or_and_0_ln120_Z_0_z;
      reg if_ln120_z;
      reg ctrlAnd_1_ln103_z;
      reg ctrlAnd_0_ln103_z;
      reg ctrlAnd_0_ln120_z;
      reg and_1_ln120_z;
      reg rd_request_hold;
      reg ctrlOr_ln115_z;
      reg ctrlOr_ln105_z;
      reg input_done_hold;
      reg ctrlOr_ln135_z;
      reg and_1_ln123_z;
      reg ctrlAnd_0_ln123_z;
      reg and_0_ln123_z;
      reg ctrlOr_ln300_z;
      reg ctrlAnd_1_ln300_z;
      reg read_sort_batch_ln98_sel;
      reg ctrlAnd_0_ln300_z;
      reg bufdin_set_ready_curr_hold;
      reg bufdin_set_ready_curr_sel;

      state_sort_unisim_sort_load_input_next = 7'h0;
      unary_nor_ln98_z = ~bufdin_set_ready_curr;
      ctrlAnd_1_ln115_z = rd_grant & state_sort_unisim_sort_load_input[2];
      ctrlAnd_0_ln115_z = !rd_grant & state_sort_unisim_sort_load_input[2];
      ctrlAnd_1_ln135_z = rb_start & state_sort_unisim_sort_load_input[3];
      ctrlAnd_0_ln135_z = !rb_start & state_sort_unisim_sort_load_input[3];
      ctrlAnd_1_ln138_z = !rb_start & state_sort_unisim_sort_load_input[4];
      ctrlAnd_0_ln138_z = rb_start & state_sort_unisim_sort_load_input[4];
      ctrlAnd_1_ln89_z = init_done & state_sort_unisim_sort_load_input[0];
      ctrlAnd_0_ln89_z = !init_done & state_sort_unisim_sort_load_input[0];
      if (state_sort_unisim_sort_load_input[0]) 
        mux_index_ln101_z = 32'h0;
      else 
        mux_index_ln101_z = add_ln110_q;
      if (state_sort_unisim_sort_load_input[0]) 
        mux_ping_ln101_z = 1'b1;
      else 
        mux_ping_ln101_z = !mux_ping_ln101_q;
      if (state_sort_unisim_sort_load_input[0]) 
        mux_read_sort_batch_ln98_Z_v = batch;
      else 
        mux_read_sort_batch_ln98_Z_v = read_sort_batch_ln98_q;
      if (state_sort_unisim_sort_load_input[0]) 
        mux_read_sort_len_ln97_Z_v = len;
      else 
        mux_read_sort_len_ln97_Z_v = rd_length;
      if (state_sort_unisim_sort_load_input[0]) 
        mux_burst_ln101_z = 32'h0;
      else 
        mux_burst_ln101_z = {add_ln111_1_q, !mux_burst_ln101_q};
      if (state_sort_unisim_sort_load_input[2]) 
        mux_i_ln119_z = 11'h0;
      else 
        mux_i_ln119_z = {add_ln119_1_q, !mux_i_ln119_q[0]};
      ctrlOr_ln119_0_z = state_sort_unisim_sort_load_input[6] | 
      ctrlAnd_1_ln115_z;
      ctrlOr_ln138_z = ctrlAnd_0_ln138_z | ctrlAnd_1_ln135_z;
      ctrlOr_ln101_z = ctrlAnd_1_ln138_z | ctrlAnd_1_ln89_z;
      if (state_sort_unisim_sort_load_input[2]) 
        mux_mux_ping_ln101_Z_0_v = mux_ping_ln101_q;
      else 
        mux_mux_ping_ln101_Z_0_v = mux_ping_ln101_z;
      if_ln123_z = ~mux_ping_ln101_z;
      if (state_sort_unisim_sort_load_input[2]) 
        mux_read_sort_batch_ln98_Z_0_mux_0_v = read_sort_batch_ln98_q;
      else 
        mux_read_sort_batch_ln98_Z_0_mux_0_v = mux_read_sort_batch_ln98_Z_v;
      add_ln110_z = mux_index_ln101_z + mux_read_sort_len_ln97_Z_v;
      if (bufdin_ready) 
        mux_item_ln304_z = bufdin_data;
      else 
        mux_item_ln304_z = bufdin_data_buf;
      eq_ln103_z = mux_burst_ln101_z == mux_read_sort_batch_ln98_Z_v;
      if (state_sort_unisim_sort_load_input[2]) 
        mux_mux_burst_ln101_Z_0_v = mux_burst_ln101_q;
      else 
        mux_mux_burst_ln101_Z_0_v = mux_burst_ln101_z[0];
      add_ln111_z = mux_burst_ln101_z + 32'h1;
      eq_ln120_z = {21'h0, mux_i_ln119_z} == rd_length;
      lt_ln119_z = ~mux_i_ln119_z[10];
      if (state_sort_unisim_sort_load_input[5]) 
        mux_mux_i_ln119_Z_v = mux_i_ln119_q;
      else 
        mux_mux_i_ln119_Z_v = mux_i_ln119_z[9:0];
      add_ln119_z = {1'b0, mux_i_ln119_z[9:0]} + 11'h1;
      if (state_sort_unisim_sort_load_input[2]) 
        mux_add_ln110_Z_v = add_ln110_q;
      else 
        mux_add_ln110_Z_v = add_ln110_z;
      if (state_sort_unisim_sort_load_input[2]) 
        mux_add_ln111_Z_1_v_0 = add_ln111_1_q;
      else 
        mux_add_ln111_Z_1_v_0 = add_ln111_z[31:1];
      or_and_0_ln120_Z_0_z = mux_i_ln119_z[10] | eq_ln120_z;
      if_ln120_z = ~eq_ln120_z;
      if (state_sort_unisim_sort_load_input[5]) 
        mux_add_ln119_Z_1_v_0 = add_ln119_1_q;
      else 
        mux_add_ln119_Z_1_v_0 = add_ln119_z[10:1];
      ctrlAnd_1_ln103_z = !eq_ln103_z & ctrlOr_ln101_z;
      ctrlAnd_0_ln103_z = eq_ln103_z & ctrlOr_ln101_z;
      ctrlAnd_0_ln120_z = or_and_0_ln120_Z_0_z & ctrlOr_ln119_0_z;
      and_1_ln120_z = if_ln120_z & lt_ln119_z;
      rd_request_hold = ~(ctrlAnd_1_ln115_z | ctrlAnd_1_ln103_z);
      ctrlOr_ln115_z = ctrlAnd_0_ln115_z | ctrlAnd_1_ln103_z;
      ctrlOr_ln105_z = state_sort_unisim_sort_load_input[1] | ctrlAnd_0_ln103_z;
      input_done_hold = ~(ctrlAnd_1_ln135_z | ctrlAnd_0_ln120_z);
      ctrlOr_ln135_z = ctrlAnd_0_ln135_z | ctrlAnd_0_ln120_z;
      and_1_ln123_z = !mux_ping_ln101_q & and_1_ln120_z;
      ctrlAnd_0_ln123_z = and_1_ln120_z & ctrlOr_ln119_0_z;
      and_0_ln123_z = mux_ping_ln101_q & and_1_ln120_z;
      if (ctrlAnd_1_ln103_z) 
        rd_length_d = mux_read_sort_len_ln97_Z_v;
      else 
        rd_length_d = rd_length;
      if (ctrlAnd_1_ln103_z) 
        rd_index_d = mux_index_ln101_z;
      else 
        rd_index_d = rd_index;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln103_z: rd_request_d = 1'b1;
        ctrlAnd_1_ln115_z: rd_request_d = 1'b0;
        rd_request_hold: rd_request_d = rd_request;
        default: rd_request_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln120_z: input_done_d = 1'b1;
        ctrlAnd_1_ln135_z: input_done_d = 1'b0;
        input_done_hold: input_done_d = input_done;
        default: input_done_d = 1'bX;
      endcase
      if (state_sort_unisim_sort_load_input[5]) 
        mux_and_1_ln123_Z_0_v = and_1_ln123_Z_0_tag_0;
      else 
        mux_and_1_ln123_Z_0_v = and_1_ln123_z;
      ctrlOr_ln300_z = state_sort_unisim_sort_load_input[5] | ctrlAnd_0_ln123_z;
      if (state_sort_unisim_sort_load_input[5]) 
        mux_and_0_ln123_Z_0_v = and_0_ln123_Z_0_tag_0;
      else 
        mux_and_0_ln123_Z_0_v = and_0_ln123_z;
      ctrlAnd_1_ln300_z = bufdin_can_get_sig & ctrlOr_ln300_z;
      read_sort_batch_ln98_sel = ctrlOr_ln300_z | ctrlOr_ln138_z | 
      ctrlOr_ln135_z;
      ctrlAnd_0_ln300_z = !bufdin_can_get_sig & ctrlOr_ln300_z;
      memwrite_sort_A0_ln124_en = mux_and_0_ln123_Z_0_v & ctrlAnd_1_ln300_z;
      memwrite_sort_A1_ln128_en = mux_and_1_ln123_Z_0_v & ctrlAnd_1_ln300_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln115_z: read_sort_batch_ln98_d = {mux_add_ln110_Z_v[29:0], 
          mux_mux_ping_ln101_Z_0_v, mux_mux_burst_ln101_Z_0_v, 
          mux_read_sort_batch_ln98_Z_0_mux_0_v};
        read_sort_batch_ln98_sel: read_sort_batch_ln98_d = {add_ln110_q[29:0], 
          mux_ping_ln101_q, mux_burst_ln101_q, read_sort_batch_ln98_q};
        default: read_sort_batch_ln98_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln115_z: add_ln110_30_d_0 = {mux_add_ln111_Z_1_v_0, 
          mux_add_ln110_Z_v[31:30]};
        read_sort_batch_ln98_sel: add_ln110_30_d_0 = {add_ln111_1_q, add_ln110_q
          [31:30]};
        default: add_ln110_30_d_0 = 33'hX;
      endcase
      bufdin_set_ready_curr_hold = ~(memwrite_sort_A1_ln128_en | 
      memwrite_sort_A0_ln124_en);
      bufdin_set_ready_curr_sel = memwrite_sort_A1_ln128_en | 
      memwrite_sort_A0_ln124_en;
      case (1'b1)// synthesis parallel_case
        bufdin_set_ready_curr_sel: bufdin_set_ready_curr_d = unary_nor_ln98_z;
        bufdin_set_ready_curr_hold: bufdin_set_ready_curr_d = 
          bufdin_set_ready_curr;
        default: bufdin_set_ready_curr_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_load_input[0]: // Wait_ln89
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln89_z: state_sort_unisim_sort_load_input_next[0] = 1'b1;
              ctrlOr_ln105_z: state_sort_unisim_sort_load_input_next[1] = 1'b1;
              ctrlOr_ln115_z: state_sort_unisim_sort_load_input_next[2] = 1'b1;
              default: state_sort_unisim_sort_load_input_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_load_input[1]: // Wait_ln105
          state_sort_unisim_sort_load_input_next[1] = 1'b1;
        state_sort_unisim_sort_load_input[2]: // Wait_ln115
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln115_z: state_sort_unisim_sort_load_input_next[2] = 1'b1;
              ctrlOr_ln135_z: state_sort_unisim_sort_load_input_next[3] = 1'b1;
              ctrlAnd_0_ln300_z: state_sort_unisim_sort_load_input_next[5] = 
                1'b1;
              ctrlAnd_1_ln300_z: state_sort_unisim_sort_load_input_next[6] = 
                1'b1;
              default: state_sort_unisim_sort_load_input_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_load_input[3]: // Wait_ln135
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln135_z: state_sort_unisim_sort_load_input_next[3] = 1'b1;
              ctrlOr_ln138_z: state_sort_unisim_sort_load_input_next[4] = 1'b1;
              default: state_sort_unisim_sort_load_input_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_load_input[4]: // Wait_ln138
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln138_z: state_sort_unisim_sort_load_input_next[4] = 1'b1;
              ctrlOr_ln105_z: state_sort_unisim_sort_load_input_next[1] = 1'b1;
              ctrlOr_ln115_z: state_sort_unisim_sort_load_input_next[2] = 1'b1;
              default: state_sort_unisim_sort_load_input_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_load_input[5]: // Wait_ln300
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_z: state_sort_unisim_sort_load_input_next[5] = 
                1'b1;
              ctrlAnd_1_ln300_z: state_sort_unisim_sort_load_input_next[6] = 
                1'b1;
              default: state_sort_unisim_sort_load_input_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_load_input[6]: // Wait_ln131
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln135_z: state_sort_unisim_sort_load_input_next[3] = 1'b1;
              ctrlAnd_0_ln300_z: state_sort_unisim_sort_load_input_next[5] = 
                1'b1;
              ctrlAnd_1_ln300_z: state_sort_unisim_sort_load_input_next[6] = 
                1'b1;
              default: state_sort_unisim_sort_load_input_next = 7'hX;
            endcase
          end
        default: // Don't care
          state_sort_unisim_sort_load_input_next = 7'hX;
      endcase
    end
  sort_unisim_identity_sync_write_1024x32m0 B0_bridge0(.rtl_CE(
                                            B0_bridge0_rtl_CE_en), .rtl_A(
                                            B0_bridge0_rtl_a), .rtl_D(
                                            B0_bridge0_rtl_d), .rtl_WE(
                                            B0_bridge0_rtl_CE_en), .CLK(clk), .mem_CE(
                                            B0_CE0), .mem_A(B0_A0), .mem_D(B0_D0), 
                                            .mem_WE(B0_WE0));
  sort_unisim_identity_sync_write_1024x32m0 B1_bridge0(.rtl_CE(
                                            B1_bridge0_rtl_CE_en), .rtl_A(
                                            B1_bridge0_rtl_a), .rtl_D(
                                            B1_bridge0_rtl_d), .rtl_WE(
                                            B1_bridge0_rtl_CE_en), .CLK(clk), .mem_CE(
                                            B1_CE0), .mem_A(B1_A0), .mem_D(B1_D0), 
                                            .mem_WE(B1_WE0));
  sort_unisim_identity_sync_read_1024x32m0 C0_bridge1(.rtl_CE(
                                           C0_bridge1_rtl_CE_en), .rtl_A(
                                           C0_bridge1_rtl_a), .mem_Q(C0_Q1), .CLK(
                                           clk), .mem_CE(C0_CE1), .mem_A(C0_A1), 
                                           .rtl_Q(C0_bridge1_rtl_Q));
  sort_unisim_identity_sync_read_1024x32m0 C1_bridge1(.rtl_CE(
                                           C1_bridge1_rtl_CE_en), .rtl_A(
                                           C1_bridge1_rtl_a), .mem_Q(C1_Q1), .CLK(
                                           clk), .mem_CE(C1_CE1), .mem_A(C1_A1), 
                                           .rtl_Q(C1_bridge1_rtl_Q));
  // synthesis sync_set_reset_local sort_unisim_sort_merge_sort_seq_block rst
  always @(posedge clk) // sort_unisim_sort_merge_sort_sequential
    begin : sort_unisim_sort_merge_sort_seq_block
      if (!rst) // Initialize state and outputs
      begin
        ge_ln457_unr0_Z_0_tag_0 <= 1'sb0;
        merge_start <= 1'sb0;
        eq_ln445_unr10_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr11_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr12_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr13_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr14_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr15_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr16_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr17_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr18_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr19_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr1_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr20_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr21_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr22_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr23_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr24_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr25_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr26_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr27_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr28_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr29_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr2_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr30_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr3_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr4_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr5_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr6_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr7_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr8_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr9_Z_0_tag_0 <= 1'sb0;
        eq_ln485_unr0_Z_0_tag_0 <= 1'sb0;
        eq_ln445_unr0_Z_0_tag_0 <= 1'sb0;
        eq_ln507_Z_0_tag_0 <= 1'sb0;
        merge_done <= 1'sb0;
        mux_ping_ln357_Z_0_tag_0 <= 1'sb0;
        ne_ln534_Z_0_tag_0 <= 1'sb0;
        or_and_0_ln521_Z_0_unr0_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr1_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr2_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr3_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr4_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr5_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr6_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr7_Z_0_tag_0 <= 1'sb0;
        and_0_ln521_unr8_Z_0_tag_0 <= 1'sb0;
        state_sort_unisim_sort_merge_sort <= 20'h1;
      end
      else // Update Q values
      begin
        ge_ln457_unr0_Z_0_tag_0 <= ge_ln457_unr0_z;
        merge_start <= merge_start_d;
        eq_ln445_unr10_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[10];
        eq_ln445_unr11_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[11];
        eq_ln445_unr12_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[12];
        eq_ln445_unr13_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[13];
        eq_ln445_unr14_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[14];
        eq_ln445_unr15_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[15];
        eq_ln445_unr16_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[16];
        eq_ln445_unr17_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[17];
        eq_ln445_unr18_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[18];
        eq_ln445_unr19_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[19];
        eq_ln445_unr1_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[1];
        eq_ln445_unr20_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[20];
        eq_ln445_unr21_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[21];
        eq_ln445_unr22_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[22];
        eq_ln445_unr23_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[23];
        eq_ln445_unr24_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[24];
        eq_ln445_unr25_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[25];
        eq_ln445_unr26_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[26];
        eq_ln445_unr27_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[27];
        eq_ln445_unr28_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[28];
        eq_ln445_unr29_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[29];
        eq_ln445_unr2_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[2];
        eq_ln445_unr30_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[30];
        eq_ln445_unr3_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[3];
        eq_ln445_unr4_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[4];
        eq_ln445_unr5_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[5];
        eq_ln445_unr6_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[6];
        eq_ln445_unr7_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[7];
        eq_ln445_unr8_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[8];
        eq_ln445_unr9_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[9];
        eq_ln485_unr0_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[31];
        eq_ln445_unr0_Z_0_tag_0 <= eq_ln445_unr0_Z_0_tag_d_0[0];
        eq_ln507_Z_0_tag_0 <= eq_ln507_Z_0_tag_d;
        merge_done <= merge_done_d;
        mux_ping_ln357_Z_0_tag_0 <= mux_ping_ln357_Z_0_tag_d;
        ne_ln534_Z_0_tag_0 <= ne_ln534_Z_0_tag_d;
        or_and_0_ln521_Z_0_unr0_Z_0_tag_0 <= or_and_0_ln521_Z_0_unr0_z;
        and_0_ln521_unr1_Z_0_tag_0 <= and_0_ln521_unr1_z;
        and_0_ln521_unr2_Z_0_tag_0 <= and_0_ln521_unr2_z;
        and_0_ln521_unr3_Z_0_tag_0 <= and_0_ln521_unr3_z;
        and_0_ln521_unr4_Z_0_tag_0 <= and_0_ln521_unr4_z;
        and_0_ln521_unr5_Z_0_tag_0 <= and_0_ln521_unr5_z;
        and_0_ln521_unr6_Z_0_tag_0 <= and_0_ln521_unr6_z;
        and_0_ln521_unr7_Z_0_tag_0 <= and_0_ln521_unr7_z;
        and_0_ln521_unr8_Z_0_tag_0 <= and_0_ln521_unr8_z;
        state_sort_unisim_sort_merge_sort <= 
        state_sort_unisim_sort_merge_sort_next;
      end
    end
  always @(posedge clk) // sort_unisim_sort_merge_sort_0_sequential
    begin
      case_mux_head_ln387_0_q <= case_mux_head_ln387_0_z;
      case_mux_head_ln440_1_q <= case_mux_head_ln440_1_z;
      mux_regs_in_ln440_q <= mux_regs_in_ln440_z;
      mux_elem_ln577_q <= mux_elem_ln577_z;
      mux_head_ln440_0_q <= mux_head_ln440_0_z;
      mux_chunk_ln406_q <= mux_chunk_ln406_z[4:0];
      mux_head_ln440_1_q <= mux_head_ln440_1_z;
      ge_ln457_unr16_q <= ge_ln457_unr16_z;
      ge_ln457_unr24_q <= ge_ln457_unr24_z;
      ge_ln457_unr28_q <= ge_ln457_unr28_z;
      ge_ln457_unr30_q <= ge_ln457_unr30_z;
      ge_ln457_unr10_q <= ge_ln457_unr10_z;
      ge_ln457_unr21_q <= ge_ln457_unr21_z;
      ge_ln457_unr6_q <= ge_ln457_unr6_z;
      ge_ln457_unr19_q <= ge_ln457_unr19_z;
      ge_ln457_unr2_q <= ge_ln457_unr2_z;
      ge_ln457_unr17_q <= ge_ln457_unr17_z;
      ge_ln457_unr15_q <= ge_ln457_unr15_z;
      ge_ln457_unr13_q <= ge_ln457_unr13_z;
      ge_ln457_unr11_q <= ge_ln457_unr11_z;
      ge_ln457_unr9_q <= ge_ln457_unr9_z;
      ge_ln457_unr7_q <= ge_ln457_unr7_z;
      ge_ln457_unr5_q <= ge_ln457_unr5_z;
      ge_ln457_unr3_q <= ge_ln457_unr3_z;
      ge_ln457_unr8_q <= ge_ln457_unr8_z;
      ge_ln457_unr20_q <= ge_ln457_unr20_z;
      ge_ln457_unr26_q <= ge_ln457_unr26_z;
      ge_ln457_unr29_q <= ge_ln457_unr29_z;
      ge_ln457_unr1_q <= ge_ln457_unr1_z;
      ge_ln457_unr12_q <= ge_ln457_unr12_z;
      ge_ln457_unr22_q <= ge_ln457_unr22_z;
      ge_ln457_unr27_q <= ge_ln457_unr27_z;
      ge_ln457_unr4_q <= ge_ln457_unr4_z;
      ge_ln457_unr18_q <= ge_ln457_unr18_z;
      ge_ln457_unr25_q <= ge_ln457_unr25_z;
      ge_ln457_unr14_q <= ge_ln457_unr14_z;
      ge_ln457_unr23_q <= ge_ln457_unr23_z;
      sort_unisim_lt_float_ln447_unr0_lt_float_out_q <= 
      sort_unisim_lt_float_ln447_unr0_z;
      sort_unisim_lt_float_ln447_unr1_lt_float_out_q <= 
      sort_unisim_lt_float_ln447_unr1_z;
      mux_regs_0_ln440_q <= {mux_regs_0_ln440_992_d_0[31:0], 
      mux_regs_0_ln440_928_d_0, mux_regs_0_ln440_864_d_0, 
      mux_regs_0_ln440_800_d_0, mux_regs_0_ln440_736_d_0, 
      mux_regs_0_ln440_672_d_0, mux_regs_0_ln440_608_d_0, 
      mux_regs_0_ln440_544_d_0, mux_regs_0_ln440_480_d_0, 
      mux_regs_0_ln440_416_d_0, mux_regs_0_ln440_352_d_0, 
      mux_regs_0_ln440_288_d_0, mux_regs_0_ln440_224_d_0, 
      mux_regs_0_ln440_160_d_0, mux_regs_0_ln440_96_d_0, mux_regs_0_ln440_32_d_0, 
      mux_cur_ln440_d[63:32]};
      mux_cur_ln440_q <= mux_cur_ln440_d[31:0];
      add_ln406_1_q <= add_ln406_z[5:1];
      mux_fidx_ln440_q <= {mux_fidx_ln440_1014_d_0, mux_fidx_ln440_950_d_0, 
      mux_fidx_ln440_886_d_0, mux_fidx_ln440_822_d_0, mux_fidx_ln440_758_d_0, 
      mux_fidx_ln440_694_d_0, mux_fidx_ln440_630_d_0, mux_fidx_ln440_566_d_0, 
      mux_fidx_ln440_502_d_0, mux_fidx_ln440_438_d_0, mux_fidx_ln440_374_d_0, 
      mux_fidx_ln440_310_d_0, mux_fidx_ln440_246_d_0, mux_fidx_ln440_182_d_0, 
      mux_fidx_ln440_118_d_0, mux_fidx_ln440_54_d_0, mux_cnt_ln440_d[63:10]};
      mux_cnt_ln440_q <= mux_cnt_ln440_d[9:0];
      case_mux_shift_ln456_q <= case_mux_shift_ln456_z;
      mux_i_1_ln574_q <= mux_i_1_ln574_d[4:0];
      add_ln574_1_q <= mux_i_1_ln574_d[9:5];
      mux_fidx_ln440_0_q <= {mux_fidx_ln440_0_960_d_0, mux_fidx_ln440_0_896_d_0, 
      mux_fidx_ln440_0_832_d_0, mux_fidx_ln440_0_768_d_0, 
      mux_fidx_ln440_0_704_d_0, mux_fidx_ln440_0_640_d_0, 
      mux_fidx_ln440_0_576_d_0, mux_fidx_ln440_0_512_d_0, 
      mux_fidx_ln440_0_448_d_0, mux_fidx_ln440_0_384_d_0, 
      mux_fidx_ln440_0_320_d_0, mux_fidx_ln440_0_256_d_0, 
      mux_fidx_ln440_0_192_d_0, mux_fidx_ln440_0_128_d_0, 
      mux_fidx_ln440_0_64_d_0, mux_fidx_ln440_0_d};
      mux_head_ln440_q <= {mux_head_ln440_992_d_0[31:0], mux_head_ln440_928_d_0, 
      mux_head_ln440_864_d_0, mux_head_ln440_800_d_0, mux_head_ln440_736_d_0, 
      mux_head_ln440_672_d_0, mux_head_ln440_608_d_0, mux_head_ln440_544_d_0, 
      mux_head_ln440_480_d_0, mux_head_ln440_416_d_0, mux_head_ln440_352_d_0, 
      mux_head_ln440_288_d_0, mux_head_ln440_224_d_0, mux_head_ln440_160_d_0, 
      mux_head_ln440_96_d_0, mux_head_ln440_32_d_0, mux_regs_0_ln440_992_d_0[63:
      32]};
      case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_q <= 
      mux_head_ln440_992_d_0[34:32];
      memwrite_fidx_ln414_q <= memwrite_fidx_ln414_z;
      mux_cur_ln558_q <= mux_cnt_ln507_d[63:32];
      mux_cnt_ln507_q <= mux_cnt_ln507_d[31:0];
      add_ln423_1_q <= mux_fidx_ln406_960_d_0[63:33];
      mux_fidx_ln406_q <= {mux_fidx_ln406_960_d_0[32:0], mux_fidx_ln406_896_d_0, 
      mux_fidx_ln406_832_d_0, mux_fidx_ln406_768_d_0, mux_fidx_ln406_704_d_0, 
      mux_fidx_ln406_640_d_0, mux_fidx_ln406_576_d_0, mux_fidx_ln406_512_d_0, 
      mux_fidx_ln406_448_d_0, mux_fidx_ln406_384_d_0, mux_fidx_ln406_320_d_0, 
      mux_fidx_ln406_256_d_0, mux_fidx_ln406_192_d_0, mux_fidx_ln406_128_d_0, 
      mux_fidx_ln406_64_d_0, mux_fidx_ln406_d};
      eq_ln564_q <= eq_ln564_d;
      mux_chunk_4_ln570_q <= mux_chunk_4_ln570_d[4:0];
      add_ln570_1_q <= mux_chunk_4_ln570_d[9:5];
      mux_head_ln387_q <= {mux_head_ln387_960_d_0, mux_head_ln387_896_d_0, 
      mux_head_ln387_832_d_0, mux_head_ln387_768_d_0, mux_head_ln387_704_d_0, 
      mux_head_ln387_640_d_0, mux_head_ln387_576_d_0, mux_head_ln387_512_d_0, 
      mux_head_ln387_448_d_0, mux_head_ln387_384_d_0, mux_head_ln387_320_d_0, 
      mux_head_ln387_256_d_0, mux_head_ln387_192_d_0, mux_head_ln387_128_d_0, 
      mux_head_ln387_64_d_0, mux_head_ln387_d};
      mux_regs_0_ln387_q <= {mux_regs_0_ln387_928_d_0, mux_regs_0_ln387_864_d_0, 
      mux_regs_0_ln387_800_d_0, mux_regs_0_ln387_736_d_0, 
      mux_regs_0_ln387_672_d_0, mux_regs_0_ln387_608_d_0, 
      mux_regs_0_ln387_544_d_0, mux_regs_0_ln387_480_d_0, 
      mux_regs_0_ln387_416_d_0, mux_regs_0_ln387_352_d_0, 
      mux_regs_0_ln387_288_d_0, mux_regs_0_ln387_224_d_0, 
      mux_regs_0_ln387_160_d_0, mux_regs_0_ln387_96_d_0, mux_regs_0_ln387_32_d_0, 
      mux_regs_in_ln387_960_d_0[63:32]};
      mux_regs_in_ln387_q <= {mux_regs_in_ln387_960_d_0[31:0], 
      mux_regs_in_ln387_896_d_0, mux_regs_in_ln387_832_d_0, 
      mux_regs_in_ln387_768_d_0, mux_regs_in_ln387_704_d_0, 
      mux_regs_in_ln387_640_d_0, mux_regs_in_ln387_576_d_0, 
      mux_regs_in_ln387_512_d_0, mux_regs_in_ln387_448_d_0, 
      mux_regs_in_ln387_384_d_0, mux_regs_in_ln387_320_d_0, 
      mux_regs_in_ln387_256_d_0, mux_regs_in_ln387_192_d_0, 
      mux_regs_in_ln387_128_d_0, mux_regs_in_ln387_64_d_0, mux_regs_in_ln387_d};
      mux_head_ln357_q <= {mux_head_ln357_960_d_0, mux_head_ln357_896_d_0, 
      mux_head_ln357_832_d_0, mux_head_ln357_768_d_0, mux_head_ln357_704_d_0, 
      mux_head_ln357_640_d_0, mux_head_ln357_576_d_0, mux_head_ln357_512_d_0, 
      mux_head_ln357_448_d_0, mux_head_ln357_384_d_0, mux_head_ln357_320_d_0, 
      mux_head_ln357_256_d_0, mux_head_ln357_192_d_0, mux_head_ln357_128_d_0, 
      mux_head_ln357_64_d_0, mux_head_ln357_d};
      mux_head_ln406_q <= {mux_head_ln406_960_d_0, mux_head_ln406_896_d_0, 
      mux_head_ln406_832_d_0, mux_head_ln406_768_d_0, mux_head_ln406_704_d_0, 
      mux_head_ln406_640_d_0, mux_head_ln406_576_d_0, mux_head_ln406_512_d_0, 
      mux_head_ln406_448_d_0, mux_head_ln406_384_d_0, mux_head_ln406_320_d_0, 
      mux_head_ln406_256_d_0, mux_head_ln406_192_d_0, mux_head_ln406_128_d_0, 
      mux_head_ln406_64_d_0, mux_head_ln406_d};
      mux_regs_in_ln357_q <= {mux_regs_in_ln357_960_d_0[31:0], 
      mux_regs_in_ln357_896_d_0, mux_regs_in_ln357_832_d_0, 
      mux_regs_in_ln357_768_d_0, mux_regs_in_ln357_704_d_0, 
      mux_regs_in_ln357_640_d_0, mux_regs_in_ln357_576_d_0, 
      mux_regs_in_ln357_512_d_0, mux_regs_in_ln357_448_d_0, 
      mux_regs_in_ln357_384_d_0, mux_regs_in_ln357_320_d_0, 
      mux_regs_in_ln357_256_d_0, mux_regs_in_ln357_192_d_0, 
      mux_regs_in_ln357_128_d_0, mux_regs_in_ln357_64_d_0, mux_regs_in_ln357_d};
      mux_regs_0_ln357_q <= {mux_regs_0_ln357_928_d_0, mux_regs_0_ln357_864_d_0, 
      mux_regs_0_ln357_800_d_0, mux_regs_0_ln357_736_d_0, 
      mux_regs_0_ln357_672_d_0, mux_regs_0_ln357_608_d_0, 
      mux_regs_0_ln357_544_d_0, mux_regs_0_ln357_480_d_0, 
      mux_regs_0_ln357_416_d_0, mux_regs_0_ln357_352_d_0, 
      mux_regs_0_ln357_288_d_0, mux_regs_0_ln357_224_d_0, 
      mux_regs_0_ln357_160_d_0, mux_regs_0_ln357_96_d_0, mux_regs_0_ln357_32_d_0, 
      mux_regs_in_ln357_960_d_0[63:32]};
      mux_burst_ln357_q <= mux_burst_ln357_d_0[0];
      add_ln598_1_q <= mux_burst_ln357_d_0[31:1];
      read_sort_len_ln352_q <= read_sort_len_ln352_d[31:0];
      read_sort_batch_ln353_q <= read_sort_len_ln352_d[63:32];
      sub_ln510_1_q <= gt_ln387_d_0[4:1];
      gt_ln387_q <= gt_ln387_d_0[0];
      mux_regs_0_ln510_q <= {mux_regs_0_ln510_960_d_0, mux_regs_0_ln510_896_d_0, 
      mux_regs_0_ln510_832_d_0, mux_regs_0_ln510_768_d_0, 
      mux_regs_0_ln510_704_d_0, mux_regs_0_ln510_640_d_0, 
      mux_regs_0_ln510_576_d_0, mux_regs_0_ln510_512_d_0, 
      mux_regs_0_ln510_448_d_0, mux_regs_0_ln510_384_d_0, 
      mux_regs_0_ln510_320_d_0, mux_regs_0_ln510_256_d_0, 
      mux_regs_0_ln510_192_d_0, mux_regs_0_ln510_128_d_0, 
      mux_regs_0_ln510_64_d_0, mux_regs_0_ln510_d};
      memread_regs_ln510_q <= memread_regs_ln510_z;
      mux_pop_idx_ln520_0_q <= mux_pop_idx_ln520_0_d[4:0];
      mux_head_ln536_q <= {mux_head_ln536_1019_d_0, mux_head_ln536_955_d_0, 
      mux_head_ln536_891_d_0, mux_head_ln536_827_d_0, mux_head_ln536_763_d_0, 
      mux_head_ln536_699_d_0, mux_head_ln536_635_d_0, mux_head_ln536_571_d_0, 
      mux_head_ln536_507_d_0, mux_head_ln536_443_d_0, mux_head_ln536_379_d_0, 
      mux_head_ln536_315_d_0, mux_head_ln536_251_d_0, mux_head_ln536_187_d_0, 
      mux_head_ln536_123_d_0, mux_head_ln536_59_d_0, mux_pop_idx_ln520_0_d[63:5]};
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_q <= 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_z;
      mux_shift_MERGE_COMPARE_for_exit_unr1_0_0_ln456_q <= 
      mux_shift_MERGE_COMPARE_for_exit_unr1_0_0_ln456_z;
      memread_pop_ln523_unr0_0_9_q <= memread_pop_ln523_unr0_0_z[31:9];
      mux_regs_in_ln456_30_q <= {mux_regs_in_ln456_30_992_d_0, 
      mux_regs_in_ln456_30_928_d_0, mux_regs_in_ln456_30_864_d_0, 
      mux_regs_in_ln456_30_800_d_0, mux_regs_in_ln456_30_736_d_0, 
      mux_regs_in_ln456_30_672_d_0, mux_regs_in_ln456_30_608_d_0, 
      mux_regs_in_ln456_30_544_d_0, mux_regs_in_ln456_30_480_d_0, 
      mux_regs_in_ln456_30_416_d_0, mux_regs_in_ln456_30_352_d_0, 
      mux_regs_in_ln456_30_288_d_0, mux_regs_in_ln456_30_224_d_0, 
      mux_regs_in_ln456_30_160_d_0, mux_regs_in_ln456_30_96_d_0, 
      mux_regs_in_ln456_30_32_d_0, mux_regs_in_ln456_30_z[31:0]};
      and_0_ln523_unr1_q <= and_0_ln523_unr1_z;
      and_0_ln523_unr10_q <= and_0_ln523_unr10_z;
      and_0_ln523_unr11_q <= and_0_ln523_unr11_z;
      and_0_ln523_unr12_q <= and_0_ln523_unr12_z;
      and_0_ln523_unr13_q <= and_0_ln523_unr13_z;
      and_0_ln523_unr14_q <= and_0_ln523_unr14_z;
      and_0_ln523_unr15_q <= and_0_ln523_unr15_z;
      and_0_ln523_unr16_q <= and_0_ln523_unr16_z;
      and_0_ln523_unr17_q <= and_0_ln523_unr17_z;
      and_0_ln523_unr18_q <= and_0_ln523_unr18_z;
      and_0_ln523_unr19_q <= and_0_ln523_unr19_z;
      and_0_ln523_unr2_q <= and_0_ln523_unr2_z;
      and_0_ln523_unr20_q <= and_0_ln523_unr20_z;
      and_0_ln523_unr21_q <= and_0_ln523_unr21_z;
      and_0_ln523_unr22_q <= and_0_ln523_unr22_z;
      and_0_ln523_unr23_q <= and_0_ln523_unr23_z;
      and_0_ln523_unr24_q <= and_0_ln523_unr24_z;
      and_0_ln523_unr25_q <= and_0_ln523_unr25_z;
      and_0_ln523_unr26_q <= and_0_ln523_unr26_z;
      and_0_ln523_unr27_q <= and_0_ln523_unr27_z;
      and_0_ln523_unr28_q <= and_0_ln523_unr28_z;
      and_0_ln523_unr29_q <= and_0_ln523_unr29_z;
      and_0_ln523_unr3_q <= and_0_ln523_unr3_z;
      and_0_ln523_unr30_q <= and_0_ln523_unr30_z;
      and_0_ln523_unr31_q <= and_0_ln523_unr31_z;
      and_0_ln523_unr4_q <= and_0_ln523_unr4_z;
      and_0_ln523_unr5_q <= and_0_ln523_unr5_z;
      and_0_ln523_unr6_q <= and_0_ln523_unr6_z;
      and_0_ln523_unr7_q <= and_0_ln523_unr7_z;
      and_0_ln523_unr8_q <= and_0_ln523_unr8_z;
      and_0_ln523_unr9_q <= and_0_ln523_unr9_z;
      or_and_0_ln521_Z_0_unr10_q <= or_and_0_ln521_Z_0_unr10_z;
      or_and_0_ln521_Z_0_unr11_q <= or_and_0_ln521_Z_0_unr11_z;
      or_and_0_ln521_Z_0_unr12_q <= or_and_0_ln521_Z_0_unr12_z;
      or_and_0_ln521_Z_0_unr13_q <= or_and_0_ln521_Z_0_unr13_z;
      or_and_0_ln521_Z_0_unr14_q <= or_and_0_ln521_Z_0_unr14_z;
      or_and_0_ln521_Z_0_unr15_q <= or_and_0_ln521_Z_0_unr15_z;
      or_and_0_ln521_Z_0_unr16_q <= or_and_0_ln521_Z_0_unr16_z;
      or_and_0_ln521_Z_0_unr17_q <= or_and_0_ln521_Z_0_unr17_z;
      or_and_0_ln521_Z_0_unr18_q <= or_and_0_ln521_Z_0_unr18_z;
      or_and_0_ln521_Z_0_unr19_q <= or_and_0_ln521_Z_0_unr19_z;
      or_and_0_ln521_Z_0_unr20_q <= or_and_0_ln521_Z_0_unr20_z;
      or_and_0_ln521_Z_0_unr21_q <= or_and_0_ln521_Z_0_unr21_z;
      or_and_0_ln521_Z_0_unr22_q <= or_and_0_ln521_Z_0_unr22_z;
      or_and_0_ln521_Z_0_unr23_q <= or_and_0_ln521_Z_0_unr23_z;
      or_and_0_ln521_Z_0_unr24_q <= or_and_0_ln521_Z_0_unr24_z;
      or_and_0_ln521_Z_0_unr25_q <= or_and_0_ln521_Z_0_unr25_z;
      or_and_0_ln521_Z_0_unr26_q <= or_and_0_ln521_Z_0_unr26_z;
      or_and_0_ln521_Z_0_unr27_q <= or_and_0_ln521_Z_0_unr27_z;
      or_and_0_ln521_Z_0_unr28_q <= or_and_0_ln521_Z_0_unr28_z;
      or_and_0_ln521_Z_0_unr29_q <= or_and_0_ln521_Z_0_unr29_z;
      or_and_0_ln521_Z_0_unr30_q <= or_and_0_ln521_Z_0_unr30_z;
      or_and_0_ln521_Z_0_unr31_q <= or_and_0_ln521_Z_0_unr31_z;
      or_and_0_ln521_Z_0_unr9_q <= or_and_0_ln521_Z_0_unr9_z;
      and_0_ln523_unr0_q <= and_0_ln523_unr0_z;
      
      mux_regs_0_MERGE_SEQ_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_q <= 
      mux_regs_0_MERGE_SEQ_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      and_1_ln523_unr8_0_q <= and_1_ln523_unr8_0_z;
    end
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_0(.in0_in(mux_regs_0_ln440_z[31:
                         0]), .in1_in(mux_head_ln440_z[63:32]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr0_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_1(.in0_in(mux_regs_0_ln440_z[63:
                         32]), .in1_in(mux_head_ln440_z[95:64]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr1_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_10(.in0_in(mux_regs_0_ln440_z[
                         351:320]), .in1_in(mux_head_ln440_z[383:352]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr10_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_11(.in0_in(mux_regs_0_ln440_z[
                         383:352]), .in1_in(mux_head_ln440_z[415:384]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr11_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_12(.in0_in(mux_regs_0_ln440_z[
                         415:384]), .in1_in(mux_head_ln440_z[447:416]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr12_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_13(.in0_in(mux_regs_0_ln440_z[
                         447:416]), .in1_in(mux_head_ln440_z[479:448]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr13_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_14(.in0_in(mux_regs_0_ln440_z[
                         479:448]), .in1_in(mux_head_ln440_z[511:480]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr14_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_15(.in0_in(mux_regs_0_ln440_z[
                         511:480]), .in1_in(mux_head_ln440_z[543:512]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr15_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_16(.in0_in(mux_regs_0_ln440_z[
                         543:512]), .in1_in(mux_head_ln440_z[575:544]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr16_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_17(.in0_in(mux_regs_0_ln440_z[
                         575:544]), .in1_in(mux_head_ln440_z[607:576]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr17_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_18(.in0_in(mux_regs_0_ln440_z[
                         607:576]), .in1_in(mux_head_ln440_z[639:608]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr18_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_19(.in0_in(mux_regs_0_ln440_z[
                         639:608]), .in1_in(mux_head_ln440_z[671:640]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr19_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_2(.in0_in(mux_regs_0_ln440_z[95:
                         64]), .in1_in(mux_head_ln440_z[127:96]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr2_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_20(.in0_in(mux_regs_0_ln440_z[
                         671:640]), .in1_in(mux_head_ln440_z[703:672]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr20_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_21(.in0_in(mux_regs_0_ln440_z[
                         703:672]), .in1_in(mux_head_ln440_z[735:704]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr21_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_22(.in0_in(mux_regs_0_ln440_z[
                         735:704]), .in1_in(mux_head_ln440_z[767:736]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr22_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_23(.in0_in(mux_regs_0_ln440_z[
                         767:736]), .in1_in(mux_head_ln440_z[799:768]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr23_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_24(.in0_in(mux_regs_0_ln440_z[
                         799:768]), .in1_in(mux_head_ln440_z[831:800]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr24_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_25(.in0_in(mux_regs_0_ln440_z[
                         831:800]), .in1_in(mux_head_ln440_z[863:832]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr25_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_26(.in0_in(mux_regs_0_ln440_z[
                         863:832]), .in1_in(mux_head_ln440_z[895:864]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr26_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_27(.in0_in(mux_regs_0_ln440_z[
                         895:864]), .in1_in(mux_head_ln440_z[927:896]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr27_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_28(.in0_in(mux_regs_0_ln440_z[
                         927:896]), .in1_in(mux_head_ln440_z[959:928]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr28_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_29(.in0_in(mux_regs_0_ln440_z[
                         959:928]), .in1_in(mux_head_ln440_z[991:960]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr29_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_3(.in0_in(mux_regs_0_ln440_z[127:
                         96]), .in1_in(mux_head_ln440_z[159:128]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr3_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_30(.in0_in(mux_regs_0_ln440_z[
                         991:960]), .in1_in(mux_head_ln440_z[1023:992]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr30_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_4(.in0_in(mux_regs_0_ln440_z[159:
                         128]), .in1_in(mux_head_ln440_z[191:160]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr4_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_5(.in0_in(mux_regs_0_ln440_z[191:
                         160]), .in1_in(mux_head_ln440_z[223:192]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr5_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_6(.in0_in(mux_regs_0_ln440_z[223:
                         192]), .in1_in(mux_head_ln440_z[255:224]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr6_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_7(.in0_in(mux_regs_0_ln440_z[255:
                         224]), .in1_in(mux_head_ln440_z[287:256]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr7_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_8(.in0_in(mux_regs_0_ln440_z[287:
                         256]), .in1_in(mux_head_ln440_z[319:288]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr8_z));
  sort_unisim_lt_float_0 sort_unisim_lt_float_0_9(.in0_in(mux_regs_0_ln440_z[319:
                         288]), .in1_in(mux_head_ln440_z[351:320]), .lt_float_out(
                         sort_unisim_lt_float_ln447_unr9_z));
  always @(*) begin : sort_unisim_sort_merge_sort_combinational
      reg memwrite_sort_B0_ln510_en;
      reg memwrite_sort_B0_ln583_en;
      reg for_ln574_or_0;
      reg [9:0] memread_fidx_ln536_z;
      reg [31:0] memread_fidx_ln539_z;
      reg and_0_ln521_unr9_z;
      reg ctrlOr_ln406_0_z;
      reg ctrlAnd_0_ln564_z;
      reg ctrlAnd_1_ln574_z;
      reg ctrlOr_ln440_z;
      reg eq_ln507_Z_0_tag_sel;
      reg eq_ln521_unr32_z;
      reg eq_ln564_sel;
      reg gt_ln387_z;
      reg [4:0] sub_ln510_z;
      reg [1023:0] memwrite_head_ln536_z;
      reg [1023:0] memwrite_head_ln410_z;
      reg [4:0] add_ln536_z;
      reg [1023:0] memwrite_head_ln538_z;
      reg [1023:0] memwrite_head_ln412_z;
      reg [31:0] add_ln539_z;
      reg ctrlAnd_0_ln574_z;
      reg [29:0] memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr0_0_z;
      reg [27:0] mux_shift_MERGE_COMPARE_for_exit_unr0_0_ln456_z;
      reg [127:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr9_0_z;
      reg ctrlAnd_1_ln346_z;
      reg ctrlAnd_0_ln346_z;
      reg ctrlAnd_1_ln379_z;
      reg ctrlAnd_0_ln379_z;
      reg ctrlAnd_1_ln382_z;
      reg ctrlAnd_0_ln382_z;
      reg ctrlAnd_1_ln592_z;
      reg ctrlAnd_0_ln592_z;
      reg ctrlAnd_1_ln595_z;
      reg ctrlAnd_0_ln595_z;
      reg ctrlAnd_1_ln564_z;
      reg ctrlOr_ln570_0_z;
      reg [1023:0] mux_head_ln357_z;
      reg [991:0] mux_regs_0_ln357_z;
      reg [991:0] mux_regs_in_ln357_z;
      reg [1023:0] mux_fidx_ln406_z;
      reg [31:0] mux_cur_ln440_z;
      reg [31:0] mux_cnt_ln440_z;
      reg [991:0] mux_regs_0_ln387_z;
      reg [991:0] mux_regs_in_ln387_z;
      reg memread_sort_C0_ln536_en;
      reg memread_sort_C1_ln538_en;
      reg memwrite_sort_B1_ln512_en;
      reg memwrite_sort_B1_ln585_en;
      reg mux_ping_ln357_z;
      reg [31:0] mux_burst_ln357_z;
      reg [5:0] mux_chunk_4_ln570_z;
      reg [1023:0] mux_fidx_ln440_z;
      reg [4:0] mux_i_1_ln574_z;
      reg [1023:0] mux_head_ln387_0_z;
      reg [1023:0] mux_head_ln406_0_z;
      reg [1023:0] memwrite_fidx_ln539_z;
      reg ctrlOr_ln574_z;
      reg [30:0] memread_shift_ln460_unr0_0_z;
      reg [159:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr10_0_z;
      reg and_0_ln521_unr10_z;
      reg ctrlAnd_1_ln387_z;
      reg merge_start_hold;
      reg ctrlAnd_0_ln387_z;
      reg ctrlOr_ln382_z;
      reg ctrlOr_ln357_z;
      reg ctrlOr_ln595_z;
      reg mux_cnt_ln507_sel;
      reg mux_regs_0_ln510_sel;
      reg mux_regs_in_ln456_30_32_mux_0_sel;
      reg [63:0] mux_mux_head_ln357_Z_192_v_0;
      reg [63:0] mux_mux_head_ln357_Z_256_v_0;
      reg [63:0] mux_mux_head_ln357_Z_320_v_0;
      reg [63:0] mux_mux_head_ln357_Z_384_v_0;
      reg [63:0] mux_mux_head_ln357_Z_448_v_0;
      reg [63:0] mux_mux_head_ln357_Z_512_v_0;
      reg [63:0] mux_mux_head_ln357_Z_576_v_0;
      reg [63:0] mux_mux_head_ln357_Z_640_v_0;
      reg [63:0] mux_mux_head_ln357_Z_64_v_0;
      reg [63:0] mux_mux_head_ln357_Z_704_v_0;
      reg [63:0] mux_mux_head_ln357_Z_768_v_0;
      reg [63:0] mux_mux_head_ln357_Z_832_v_0;
      reg [63:0] mux_mux_head_ln357_Z_896_v_0;
      reg [63:0] mux_mux_head_ln357_Z_960_v_0;
      reg [63:0] mux_mux_head_ln357_Z_v;
      reg [63:0] mux_mux_head_ln357_Z_128_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_192_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_256_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_320_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_384_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_448_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_512_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_576_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_640_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_64_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_704_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_768_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_832_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_896_v_0;
      reg [31:0] mux_mux_regs_0_ln357_Z_960_v_0;
      reg [63:0] mux_mux_regs_0_ln357_Z_v;
      reg [63:0] mux_mux_regs_0_ln357_Z_128_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_192_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_256_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_320_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_384_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_448_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_512_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_576_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_640_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_64_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_704_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_768_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_832_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_896_v_0;
      reg [31:0] mux_mux_regs_in_ln357_Z_960_v_0;
      reg [63:0] mux_mux_regs_in_ln357_Z_v;
      reg [63:0] mux_mux_regs_in_ln357_Z_128_v_0;
      reg [31:0] add_ln423_z;
      reg eq_ln445_unr0_z;
      reg eq_ln445_unr1_z;
      reg eq_ln445_unr10_z;
      reg eq_ln445_unr11_z;
      reg eq_ln445_unr12_z;
      reg eq_ln445_unr13_z;
      reg eq_ln445_unr14_z;
      reg eq_ln445_unr15_z;
      reg eq_ln445_unr16_z;
      reg eq_ln445_unr17_z;
      reg eq_ln445_unr18_z;
      reg eq_ln445_unr19_z;
      reg eq_ln445_unr2_z;
      reg eq_ln445_unr20_z;
      reg eq_ln445_unr21_z;
      reg eq_ln445_unr22_z;
      reg eq_ln445_unr23_z;
      reg eq_ln445_unr24_z;
      reg eq_ln445_unr25_z;
      reg eq_ln445_unr26_z;
      reg eq_ln445_unr27_z;
      reg eq_ln445_unr28_z;
      reg eq_ln445_unr29_z;
      reg eq_ln445_unr3_z;
      reg eq_ln445_unr30_z;
      reg eq_ln445_unr4_z;
      reg eq_ln445_unr5_z;
      reg eq_ln445_unr6_z;
      reg eq_ln445_unr7_z;
      reg eq_ln445_unr8_z;
      reg eq_ln445_unr9_z;
      reg eq_ln485_unr0_z;
      reg eq_ln507_z;
      reg lt_ln558_z;
      reg [31:0] add_ln559_z;
      reg [31:0] add_ln513_z;
      reg [63:0] mux_mux_regs_0_ln387_Z_192_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_256_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_320_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_384_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_448_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_512_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_576_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_640_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_64_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_704_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_768_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_832_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_896_v_0;
      reg [31:0] mux_mux_regs_0_ln387_Z_960_v_0;
      reg [63:0] mux_mux_regs_0_ln387_Z_v;
      reg [63:0] mux_mux_regs_0_ln387_Z_128_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_192_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_256_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_320_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_384_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_448_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_512_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_576_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_640_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_64_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_704_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_768_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_832_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_896_v_0;
      reg [31:0] mux_mux_regs_in_ln387_Z_960_v_0;
      reg [63:0] mux_mux_regs_in_ln387_Z_v;
      reg [63:0] mux_mux_regs_in_ln387_Z_128_v_0;
      reg mux_mux_ping_ln357_Z_0_v;
      reg eq_ln374_z;
      reg mux_mux_burst_ln357_Z_0_v;
      reg [31:0] add_ln598_z;
      reg eq_ln571_z;
      reg lt_ln570_z;
      reg [5:0] add_ln570_z;
      reg eq_ln407_z;
      reg lt_ln406_z;
      reg [31:0] memread_fidx_ln414_z;
      reg [5:0] add_ln574_z;
      reg [1023:0] mux_head_ln387_z;
      reg [1023:0] mux_head_ln406_z;
      reg [1023:0] mux_fidx_ln440_0_z;
      reg memread_sort_C0_ln578_en;
      reg memread_sort_C1_ln580_en;
      reg mux_chunk_4_ln570_sel;
      reg and_0_ln460_unr30_z;
      reg if_ln460_unr0_z;
      reg if_ln460_unr30_z;
      reg [28:0] mux_shift_ln456_z;
      reg or_and_0_ln460_unr0_Z_0_z;
      reg or_and_0_ln460_unr30_Z_0_z;
      reg and_0_ln460_unr0_z;
      reg [191:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr11_0_z;
      reg and_0_ln521_unr11_z;
      reg [2:0] case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z;
      reg if_ln457_unr10_z;
      reg if_ln457_unr21_z;
      reg if_ln457_unr6_z;
      reg if_ln457_unr19_z;
      reg if_ln457_unr2_z;
      reg if_ln457_unr17_z;
      reg if_ln457_unr15_z;
      reg if_ln457_unr13_z;
      reg if_ln457_unr11_z;
      reg if_ln457_unr9_z;
      reg if_ln457_unr7_z;
      reg if_ln457_unr5_z;
      reg if_ln457_unr3_z;
      reg if_ln457_unr8_z;
      reg if_ln457_unr20_z;
      reg if_ln457_unr26_z;
      reg if_ln457_unr29_z;
      reg if_ln457_unr1_z;
      reg if_ln457_unr12_z;
      reg if_ln457_unr22_z;
      reg if_ln457_unr27_z;
      reg if_ln457_unr4_z;
      reg if_ln457_unr18_z;
      reg if_ln457_unr25_z;
      reg if_ln457_unr14_z;
      reg if_ln457_unr23_z;
      reg 
      mux_shift_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr29_0_0_0_0_0_0_0_0_0_0_0_0_0__0_z;
      reg [30:0] mux_add_ln598_Z_1_v_0;
      reg or_and_0_ln571_Z_0_z;
      reg if_ln571_z;
      reg or_and_0_ln407_Z_0_z;
      reg if_ln407_z;
      reg [31:0] add_ln414_z;
      reg [63:0] mux_mux_head_ln387_Z_192_v_0;
      reg [63:0] mux_mux_head_ln387_Z_256_v_0;
      reg [63:0] mux_mux_head_ln387_Z_320_v_0;
      reg [63:0] mux_mux_head_ln387_Z_384_v_0;
      reg [63:0] mux_mux_head_ln387_Z_448_v_0;
      reg [63:0] mux_mux_head_ln387_Z_512_v_0;
      reg [63:0] mux_mux_head_ln387_Z_576_v_0;
      reg [63:0] mux_mux_head_ln387_Z_640_v_0;
      reg [63:0] mux_mux_head_ln387_Z_64_v_0;
      reg [63:0] mux_mux_head_ln387_Z_704_v_0;
      reg [63:0] mux_mux_head_ln387_Z_768_v_0;
      reg [63:0] mux_mux_head_ln387_Z_832_v_0;
      reg [63:0] mux_mux_head_ln387_Z_896_v_0;
      reg [63:0] mux_mux_head_ln387_Z_960_v_0;
      reg [63:0] mux_mux_head_ln387_Z_v;
      reg [63:0] mux_mux_head_ln387_Z_128_v_0;
      reg and_1_ln460_unr0_z;
      reg and_0_ln460_unr10_z;
      reg and_0_ln460_unr11_z;
      reg and_0_ln460_unr12_z;
      reg and_0_ln460_unr13_z;
      reg and_0_ln460_unr14_z;
      reg and_0_ln460_unr15_z;
      reg and_0_ln460_unr16_z;
      reg and_0_ln460_unr17_z;
      reg and_0_ln460_unr18_z;
      reg and_0_ln460_unr19_z;
      reg and_0_ln460_unr2_z;
      reg and_0_ln460_unr20_z;
      reg and_0_ln460_unr21_z;
      reg and_0_ln460_unr22_z;
      reg and_0_ln460_unr23_z;
      reg and_0_ln460_unr24_z;
      reg and_0_ln460_unr25_z;
      reg and_0_ln460_unr26_z;
      reg and_0_ln460_unr27_z;
      reg and_0_ln460_unr28_z;
      reg and_0_ln460_unr29_z;
      reg and_0_ln460_unr3_z;
      reg and_0_ln460_unr4_z;
      reg and_0_ln460_unr5_z;
      reg and_0_ln460_unr6_z;
      reg and_0_ln460_unr7_z;
      reg and_0_ln460_unr8_z;
      reg and_0_ln460_unr9_z;
      reg if_ln460_unr1_z;
      reg if_ln460_unr10_z;
      reg if_ln460_unr11_z;
      reg if_ln460_unr12_z;
      reg if_ln460_unr13_z;
      reg if_ln460_unr14_z;
      reg if_ln460_unr15_z;
      reg if_ln460_unr16_z;
      reg if_ln460_unr17_z;
      reg if_ln460_unr18_z;
      reg if_ln460_unr19_z;
      reg if_ln460_unr2_z;
      reg if_ln460_unr20_z;
      reg if_ln460_unr21_z;
      reg if_ln460_unr22_z;
      reg if_ln460_unr23_z;
      reg if_ln460_unr24_z;
      reg if_ln460_unr25_z;
      reg if_ln460_unr26_z;
      reg if_ln460_unr27_z;
      reg if_ln460_unr28_z;
      reg if_ln460_unr29_z;
      reg if_ln460_unr3_z;
      reg if_ln460_unr4_z;
      reg if_ln460_unr5_z;
      reg if_ln460_unr6_z;
      reg if_ln460_unr7_z;
      reg if_ln460_unr8_z;
      reg if_ln460_unr9_z;
      reg or_and_0_ln460_unr10_Z_0_z;
      reg or_and_0_ln460_unr11_Z_0_z;
      reg or_and_0_ln460_unr12_Z_0_z;
      reg or_and_0_ln460_unr13_Z_0_z;
      reg or_and_0_ln460_unr14_Z_0_z;
      reg or_and_0_ln460_unr15_Z_0_z;
      reg or_and_0_ln460_unr16_Z_0_z;
      reg or_and_0_ln460_unr17_Z_0_z;
      reg or_and_0_ln460_unr18_Z_0_z;
      reg or_and_0_ln460_unr19_Z_0_z;
      reg or_and_0_ln460_unr1_Z_0_z;
      reg or_and_0_ln460_unr20_Z_0_z;
      reg or_and_0_ln460_unr21_Z_0_z;
      reg or_and_0_ln460_unr22_Z_0_z;
      reg or_and_0_ln460_unr23_Z_0_z;
      reg or_and_0_ln460_unr24_Z_0_z;
      reg or_and_0_ln460_unr25_Z_0_z;
      reg or_and_0_ln460_unr26_Z_0_z;
      reg or_and_0_ln460_unr27_Z_0_z;
      reg or_and_0_ln460_unr28_Z_0_z;
      reg or_and_0_ln460_unr29_Z_0_z;
      reg or_and_0_ln460_unr2_Z_0_z;
      reg or_and_0_ln460_unr3_Z_0_z;
      reg or_and_0_ln460_unr4_Z_0_z;
      reg or_and_0_ln460_unr5_Z_0_z;
      reg or_and_0_ln460_unr6_Z_0_z;
      reg or_and_0_ln460_unr7_Z_0_z;
      reg or_and_0_ln460_unr8_Z_0_z;
      reg or_and_0_ln460_unr9_Z_0_z;
      reg and_0_ln460_unr1_z;
      reg [223:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr12_0_z;
      reg and_0_ln521_unr12_z;
      reg [31:0] mux_cnt_ln507_z;
      reg [31:0] mux_cur_ln558_z;
      reg [1:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg ctrlAnd_1_ln374_z;
      reg ctrlAnd_0_ln374_z;
      reg ctrlAnd_0_ln571_z;
      reg and_1_ln571_z;
      reg ctrlAnd_0_ln407_z;
      reg and_1_ln407_z;
      reg [63:0] mux_regs_in_ln456_31_z;
      reg and_1_ln460_unr1_0_z;
      reg and_0_ln460_unr1_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr1_0_z;
      reg [255:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr13_0_z;
      reg and_0_ln521_unr13_z;
      reg eq_ln564_z;
      reg [2:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg ctrlOr_ln379_z;
      reg ctrlOr_ln376_z;
      reg ctrlOr_ln387_z;
      reg ctrlAnd_1_ln571_z;
      reg memread_sort_C0_ln420_en;
      reg memread_sort_C1_ln422_en;
      reg ctrlAnd_1_ln407_z;
      reg [31:0] memwrite_regs_in_ln461_unr11_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr12_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr13_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr14_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr15_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr16_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr17_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr18_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr19_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr20_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr3_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr21_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr22_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr23_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr24_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr25_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr26_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr27_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr28_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr29_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr30_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr4_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr5_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr6_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr7_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr8_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr9_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr10_0_z;
      reg and_1_ln460_unr2_0_z;
      reg and_0_ln460_unr2_0_z;
      reg [31:0] memwrite_regs_in_ln461_unr2_0_z;
      reg [287:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr14_0_z;
      reg and_0_ln521_unr14_z;
      reg [1:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg [3:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg merge_done_hold;
      reg ctrlOr_ln592_z;
      reg mux_head_ln357_sel;
      reg memread_sort_C0_ln410_en;
      reg memread_sort_C1_ln412_en;
      reg mux_head_ln406_sel;
      reg mux_regs_in_ln357_sel;
      reg and_1_ln460_unr3_0_z;
      reg and_0_ln460_unr3_0_z;
      reg [319:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr15_0_z;
      reg and_0_ln521_unr15_z;
      reg [2:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg [4:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg mux_ping_ln357_Z_0_tag_sel;
      reg read_sort_len_ln352_sel;
      reg and_1_ln460_unr4_0_z;
      reg and_0_ln460_unr4_0_z;
      reg [351:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z;
      reg and_1_ln523_unr16_0_z;
      reg and_0_ln521_unr16_z;
      reg [3:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg [5:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr5_0_z;
      reg and_0_ln460_unr5_0_z;
      reg [383:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z;
      reg and_1_ln523_unr17_0_z;
      reg and_0_ln521_unr17_z;
      reg [4:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg [6:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr6_0_z;
      reg and_0_ln460_unr6_0_z;
      reg [415:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr18_0_z;
      reg and_0_ln521_unr18_z;
      reg [5:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg [7:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr7_0_z;
      reg and_0_ln460_unr7_0_z;
      reg [447:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr19_0_z;
      reg and_0_ln521_unr19_z;
      reg [6:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg [8:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr8_0_z;
      reg and_0_ln460_unr8_0_z;
      reg [479:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr20_0_z;
      reg and_0_ln521_unr20_z;
      reg [7:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg [9:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr9_0_z;
      reg and_0_ln460_unr9_0_z;
      reg [511:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr21_0_z;
      reg and_0_ln521_unr21_z;
      reg [8:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z;
      reg [10:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr10_0_z;
      reg and_0_ln460_unr10_0_z;
      reg [543:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr22_0_z;
      reg and_0_ln521_unr22_z;
      reg [9:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z;
      reg [11:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr11_0_z;
      reg and_0_ln460_unr11_0_z;
      reg [575:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr23_0_z;
      reg and_0_ln521_unr23_z;
      reg [10:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [12:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr12_0_z;
      reg and_0_ln460_unr12_0_z;
      reg [607:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr24_0_z;
      reg and_0_ln521_unr24_z;
      reg [11:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [13:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr13_0_z;
      reg and_0_ln460_unr13_0_z;
      reg [639:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr25_0_z;
      reg and_0_ln521_unr25_z;
      reg [12:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [14:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln460_unr14_0_z;
      reg and_0_ln460_unr14_0_z;
      reg [671:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr26_0_z;
      reg and_0_ln521_unr26_z;
      reg [13:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [15:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr15_0_z;
      reg and_0_ln460_unr15_0_z;
      reg [703:0] mux_regs_0_MERGE_SEQ_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr27_0_z;
      reg and_0_ln521_unr27_z;
      reg [14:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [16:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr16_0_z;
      reg and_0_ln460_unr16_0_z;
      reg [735:0] mux_regs_0_MERGE_SEQ_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr28_0_z;
      reg and_0_ln521_unr28_z;
      reg [15:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [17:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr17_0_z;
      reg and_0_ln460_unr17_0_z;
      reg [767:0] mux_regs_0_MERGE_SEQ_for_exit_unr7_0_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr29_0_z;
      reg and_0_ln521_unr29_z;
      reg [16:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [18:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr18_0_z;
      reg and_0_ln460_unr18_0_z;
      reg [799:0] mux_regs_0_MERGE_SEQ_for_exit_unr6_0_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr30_0_z;
      reg and_0_ln521_unr30_z;
      reg [17:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [19:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr19_0_z;
      reg and_0_ln460_unr19_0_z;
      reg [831:0] mux_regs_0_MERGE_SEQ_for_exit_unr5_0_0_0_0_0_0_ln510_z;
      reg and_1_ln523_unr31_0_z;
      reg and_0_ln521_unr31_z;
      reg [18:0] 
      mux_shift_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln456_z;
      reg [20:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr20_0_z;
      reg and_0_ln460_unr20_0_z;
      reg [863:0] mux_regs_0_MERGE_SEQ_for_exit_unr4_0_0_0_0_0_ln510_z;
      reg mux_exit_eq_ln521_z;
      reg [5:0] mux_exit_mux_chunk_3_ln520_z;
      reg mux_exit_and_0_ln523_z;
      reg [21:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_z;
      reg [19:0] mux_shift_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln456_z;
      reg and_1_ln460_unr21_0_z;
      reg and_0_ln460_unr21_0_z;
      reg [895:0] mux_regs_0_MERGE_SEQ_for_exit_unr3_0_0_0_0_ln510_z;
      reg [31:0] memwrite_head_ln527_S;
      reg [1023:0] memwrite_head_ln527_z;
      reg or_lt_ln520_Z_1_z;
      reg [26:0] memread_fidx_ln524_z;
      reg [20:0] mux_shift_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_ln456_z;
      reg [22:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr22_0_z;
      reg and_0_ln460_unr22_0_z;
      reg [927:0] mux_regs_0_MERGE_SEQ_for_exit_unr2_0_0_0_ln510_z;
      reg lt_ln524_z;
      reg [21:0] mux_shift_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_ln456_z;
      reg [23:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_z;
      reg and_1_ln460_unr23_0_z;
      reg and_0_ln460_unr23_0_z;
      reg [991:0] mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z;
      reg [5:0] mux_pop_idx_ln524_z;
      reg [1:0] case_mux_head_ln536_z;
      reg [22:0] mux_shift_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_ln456_z;
      reg [24:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_z;
      reg and_1_ln460_unr24_0_z;
      reg and_0_ln460_unr24_0_z;
      reg [1023:0] mux_regs_0_ln510_z;
      reg [6:0] mux_pop_idx_ln520_0_z;
      reg [1023:0] mux_head_ln536_z;
      reg [23:0] mux_shift_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_ln456_z;
      reg [25:0] 
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_z;
      reg and_1_ln460_unr25_0_z;
      reg and_0_ln460_unr25_0_z;
      reg ne_ln534_z;
      reg [24:0] mux_shift_MERGE_COMPARE_for_exit_unr3_0_0_0_0_ln456_z;
      reg [26:0] memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr3_0_0_0_0_z;
      reg and_1_ln460_unr26_0_z;
      reg and_0_ln460_unr26_0_z;
      reg [25:0] mux_shift_MERGE_COMPARE_for_exit_unr2_0_0_0_ln456_z;
      reg [27:0] memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr2_0_0_0_z;
      reg and_1_ln460_unr27_0_z;
      reg and_0_ln460_unr27_0_z;
      reg and_1_ln460_unr28_0_z;
      reg and_0_ln460_unr28_0_z;
      reg and_1_ln460_unr29_0_z;
      reg and_0_ln460_unr29_0_z;
      reg and_1_ln460_unr30_0_z;
      reg and_0_ln460_unr30_0_z;
      reg [959:0] mux_regs_in_ln456_z;
      reg or_and_1_ln460_unr0_Z_0_z;
      reg [4:0] mux_exit_mux_chunk_1_ln456_z;
      reg [31:0] memread_head_ln467_z;
      reg mux_pop_ln468_0_z;
      reg [1023:0] memwrite_regs_in_ln467_z;
      reg [31:0] memwrite_pop_ln468_z;
      reg [31:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr30_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg if_ln523_unr0_z;
      reg if_ln523_unr1_z;
      reg if_ln523_unr10_z;
      reg if_ln523_unr11_z;
      reg if_ln523_unr12_z;
      reg if_ln523_unr13_z;
      reg if_ln523_unr14_z;
      reg if_ln523_unr15_z;
      reg if_ln523_unr16_z;
      reg if_ln523_unr17_z;
      reg if_ln523_unr18_z;
      reg if_ln523_unr19_z;
      reg if_ln523_unr2_z;
      reg if_ln523_unr20_z;
      reg if_ln523_unr21_z;
      reg if_ln523_unr22_z;
      reg if_ln523_unr23_z;
      reg if_ln523_unr24_z;
      reg if_ln523_unr25_z;
      reg if_ln523_unr26_z;
      reg if_ln523_unr27_z;
      reg if_ln523_unr28_z;
      reg if_ln523_unr29_z;
      reg if_ln523_unr3_z;
      reg if_ln523_unr30_z;
      reg if_ln523_unr31_z;
      reg if_ln523_unr4_z;
      reg if_ln523_unr5_z;
      reg if_ln523_unr6_z;
      reg if_ln523_unr7_z;
      reg if_ln523_unr8_z;
      reg if_ln523_unr9_z;
      reg or_and_0_ln521_Z_0_unr1_z;
      reg or_and_0_ln521_Z_0_unr2_z;
      reg or_and_0_ln521_Z_0_unr3_z;
      reg or_and_0_ln521_Z_0_unr4_z;
      reg or_and_0_ln521_Z_0_unr5_z;
      reg or_and_0_ln521_Z_0_unr6_z;
      reg or_and_0_ln521_Z_0_unr7_z;
      reg or_and_0_ln521_Z_0_unr8_z;
      reg [63:0] 
      mux_regs_0_MERGE_SEQ_for_exit_unr29_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z;
      reg and_1_ln523_unr0_z;
      reg and_1_ln523_unr1_0_z;
      reg and_1_ln523_unr2_0_z;
      reg and_1_ln523_unr3_0_z;
      reg and_1_ln523_unr4_0_z;
      reg and_1_ln523_unr5_0_z;
      reg and_1_ln523_unr6_0_z;
      reg and_1_ln523_unr7_0_z;

      state_sort_unisim_sort_merge_sort_next = 20'h0;
      memwrite_sort_B0_ln510_en = mux_ping_ln357_Z_0_tag_0 & 
      state_sort_unisim_sort_merge_sort[10] & eq_ln507_Z_0_tag_0;
      memwrite_sort_B0_ln583_en = mux_ping_ln357_Z_0_tag_0 & 
      state_sort_unisim_sort_merge_sort[19];
      for_ln574_or_0 = state_sort_unisim_sort_merge_sort[17] | 
      state_sort_unisim_sort_merge_sort[19];
      case (mux_pop_idx_ln520_0_q)// synthesis parallel_case
        5'h0: memread_fidx_ln536_z = mux_fidx_ln440_q[9:0];
        5'h1: memread_fidx_ln536_z = mux_fidx_ln440_q[41:32];
        5'h2: memread_fidx_ln536_z = mux_fidx_ln440_q[73:64];
        5'h3: memread_fidx_ln536_z = mux_fidx_ln440_q[105:96];
        5'h4: memread_fidx_ln536_z = mux_fidx_ln440_q[137:128];
        5'h5: memread_fidx_ln536_z = mux_fidx_ln440_q[169:160];
        5'h6: memread_fidx_ln536_z = mux_fidx_ln440_q[201:192];
        5'h7: memread_fidx_ln536_z = mux_fidx_ln440_q[233:224];
        5'h8: memread_fidx_ln536_z = mux_fidx_ln440_q[265:256];
        5'h9: memread_fidx_ln536_z = mux_fidx_ln440_q[297:288];
        5'ha: memread_fidx_ln536_z = mux_fidx_ln440_q[329:320];
        5'hb: memread_fidx_ln536_z = mux_fidx_ln440_q[361:352];
        5'hc: memread_fidx_ln536_z = mux_fidx_ln440_q[393:384];
        5'hd: memread_fidx_ln536_z = mux_fidx_ln440_q[425:416];
        5'he: memread_fidx_ln536_z = mux_fidx_ln440_q[457:448];
        5'hf: memread_fidx_ln536_z = mux_fidx_ln440_q[489:480];
        5'h10: memread_fidx_ln536_z = mux_fidx_ln440_q[521:512];
        5'h11: memread_fidx_ln536_z = mux_fidx_ln440_q[553:544];
        5'h12: memread_fidx_ln536_z = mux_fidx_ln440_q[585:576];
        5'h13: memread_fidx_ln536_z = mux_fidx_ln440_q[617:608];
        5'h14: memread_fidx_ln536_z = mux_fidx_ln440_q[649:640];
        5'h15: memread_fidx_ln536_z = mux_fidx_ln440_q[681:672];
        5'h16: memread_fidx_ln536_z = mux_fidx_ln440_q[713:704];
        5'h17: memread_fidx_ln536_z = mux_fidx_ln440_q[745:736];
        5'h18: memread_fidx_ln536_z = mux_fidx_ln440_q[777:768];
        5'h19: memread_fidx_ln536_z = mux_fidx_ln440_q[809:800];
        5'h1a: memread_fidx_ln536_z = mux_fidx_ln440_q[841:832];
        5'h1b: memread_fidx_ln536_z = mux_fidx_ln440_q[873:864];
        5'h1c: memread_fidx_ln536_z = mux_fidx_ln440_q[905:896];
        5'h1d: memread_fidx_ln536_z = mux_fidx_ln440_q[937:928];
        5'h1e: memread_fidx_ln536_z = mux_fidx_ln440_q[969:960];
        5'h1f: memread_fidx_ln536_z = mux_fidx_ln440_q[1001:992];
        default: memread_fidx_ln536_z = 10'hX;
      endcase
      case (mux_pop_idx_ln520_0_q)// synthesis parallel_case
        5'h0: memread_fidx_ln539_z = mux_fidx_ln440_q[31:0];
        5'h1: memread_fidx_ln539_z = mux_fidx_ln440_q[63:32];
        5'h2: memread_fidx_ln539_z = mux_fidx_ln440_q[95:64];
        5'h3: memread_fidx_ln539_z = mux_fidx_ln440_q[127:96];
        5'h4: memread_fidx_ln539_z = mux_fidx_ln440_q[159:128];
        5'h5: memread_fidx_ln539_z = mux_fidx_ln440_q[191:160];
        5'h6: memread_fidx_ln539_z = mux_fidx_ln440_q[223:192];
        5'h7: memread_fidx_ln539_z = mux_fidx_ln440_q[255:224];
        5'h8: memread_fidx_ln539_z = mux_fidx_ln440_q[287:256];
        5'h9: memread_fidx_ln539_z = mux_fidx_ln440_q[319:288];
        5'ha: memread_fidx_ln539_z = mux_fidx_ln440_q[351:320];
        5'hb: memread_fidx_ln539_z = mux_fidx_ln440_q[383:352];
        5'hc: memread_fidx_ln539_z = mux_fidx_ln440_q[415:384];
        5'hd: memread_fidx_ln539_z = mux_fidx_ln440_q[447:416];
        5'he: memread_fidx_ln539_z = mux_fidx_ln440_q[479:448];
        5'hf: memread_fidx_ln539_z = mux_fidx_ln440_q[511:480];
        5'h10: memread_fidx_ln539_z = mux_fidx_ln440_q[543:512];
        5'h11: memread_fidx_ln539_z = mux_fidx_ln440_q[575:544];
        5'h12: memread_fidx_ln539_z = mux_fidx_ln440_q[607:576];
        5'h13: memread_fidx_ln539_z = mux_fidx_ln440_q[639:608];
        5'h14: memread_fidx_ln539_z = mux_fidx_ln440_q[671:640];
        5'h15: memread_fidx_ln539_z = mux_fidx_ln440_q[703:672];
        5'h16: memread_fidx_ln539_z = mux_fidx_ln440_q[735:704];
        5'h17: memread_fidx_ln539_z = mux_fidx_ln440_q[767:736];
        5'h18: memread_fidx_ln539_z = mux_fidx_ln440_q[799:768];
        5'h19: memread_fidx_ln539_z = mux_fidx_ln440_q[831:800];
        5'h1a: memread_fidx_ln539_z = mux_fidx_ln440_q[863:832];
        5'h1b: memread_fidx_ln539_z = mux_fidx_ln440_q[895:864];
        5'h1c: memread_fidx_ln539_z = mux_fidx_ln440_q[927:896];
        5'h1d: memread_fidx_ln539_z = mux_fidx_ln440_q[959:928];
        5'h1e: memread_fidx_ln539_z = mux_fidx_ln440_q[991:960];
        5'h1f: memread_fidx_ln539_z = mux_fidx_ln440_q[1023:992];
        default: memread_fidx_ln539_z = 32'hX;
      endcase
      and_0_ln521_unr9_z = or_and_0_ln521_Z_0_unr9_q & and_1_ln523_unr8_0_q;
      case (1'b1)
        ne_ln534_Z_0_tag_0: case_mux_head_ln387_0_z = 3'h1;
        mux_ping_ln357_Z_0_tag_0: case_mux_head_ln387_0_z = 3'h2;
        default: case_mux_head_ln387_0_z = 3'h4;
      endcase
      case (1'b1)
        ne_ln534_Z_0_tag_0: case_mux_head_ln440_1_z = 3'h1;
        mux_ping_ln357_Z_0_tag_0: case_mux_head_ln440_1_z = 3'h2;
        default: case_mux_head_ln440_1_z = 3'h4;
      endcase
      ctrlOr_ln406_0_z = state_sort_unisim_sort_merge_sort[15] | 
      state_sort_unisim_sort_merge_sort[5];
      ctrlAnd_0_ln564_z = eq_ln564_q & state_sort_unisim_sort_merge_sort[11];
      ctrlAnd_1_ln574_z = add_ln574_1_q[4] & 
      state_sort_unisim_sort_merge_sort[19];
      ctrlOr_ln440_z = state_sort_unisim_sort_merge_sort[14] | 
      state_sort_unisim_sort_merge_sort[7];
      eq_ln507_Z_0_tag_sel = state_sort_unisim_sort_merge_sort[9] | 
      state_sort_unisim_sort_merge_sort[8];
      eq_ln521_unr32_z = mux_cur_ln440_q == 32'h20;
      eq_ln564_sel = state_sort_unisim_sort_merge_sort[9] | 
      state_sort_unisim_sort_merge_sort[10] | 
      state_sort_unisim_sort_merge_sort[8];
      gt_ln387_z = len[31:6] == 26'h0;
      sub_ln510_z = len[9:5] - 5'h1;
      B0_bridge0_rtl_CE_en = memwrite_sort_B0_ln583_en | 
      memwrite_sort_B0_ln510_en;
      if (state_sort_unisim_sort_merge_sort[19]) 
        B0_bridge0_rtl_d = mux_elem_ln577_q;
      else 
        B0_bridge0_rtl_d = memread_regs_ln510_q;
      if (state_sort_unisim_sort_merge_sort[19]) 
        B1_bridge0_rtl_a = {5'h0, mux_i_1_ln574_q};
      else 
        B1_bridge0_rtl_a = mux_cnt_ln440_q;
      if (state_sort_unisim_sort_merge_sort[19]) 
        B1_bridge0_rtl_d = mux_elem_ln577_q;
      else 
        B1_bridge0_rtl_d = memread_regs_ln510_q;
      if (state_sort_unisim_sort_merge_sort[19]) 
        B0_bridge0_rtl_a = {5'h0, mux_i_1_ln574_q};
      else 
        B0_bridge0_rtl_a = mux_cnt_ln440_q;
      memwrite_head_ln536_z = mux_head_ln536_q;
      case (mux_pop_idx_ln520_0_q)// synthesis parallel_case
        5'h0: memwrite_head_ln536_z[31:0] = C0_bridge1_rtl_Q;
        5'h1: memwrite_head_ln536_z[63:32] = C0_bridge1_rtl_Q;
        5'h2: memwrite_head_ln536_z[95:64] = C0_bridge1_rtl_Q;
        5'h3: memwrite_head_ln536_z[127:96] = C0_bridge1_rtl_Q;
        5'h4: memwrite_head_ln536_z[159:128] = C0_bridge1_rtl_Q;
        5'h5: memwrite_head_ln536_z[191:160] = C0_bridge1_rtl_Q;
        5'h6: memwrite_head_ln536_z[223:192] = C0_bridge1_rtl_Q;
        5'h7: memwrite_head_ln536_z[255:224] = C0_bridge1_rtl_Q;
        5'h8: memwrite_head_ln536_z[287:256] = C0_bridge1_rtl_Q;
        5'h9: memwrite_head_ln536_z[319:288] = C0_bridge1_rtl_Q;
        5'ha: memwrite_head_ln536_z[351:320] = C0_bridge1_rtl_Q;
        5'hb: memwrite_head_ln536_z[383:352] = C0_bridge1_rtl_Q;
        5'hc: memwrite_head_ln536_z[415:384] = C0_bridge1_rtl_Q;
        5'hd: memwrite_head_ln536_z[447:416] = C0_bridge1_rtl_Q;
        5'he: memwrite_head_ln536_z[479:448] = C0_bridge1_rtl_Q;
        5'hf: memwrite_head_ln536_z[511:480] = C0_bridge1_rtl_Q;
        5'h10: memwrite_head_ln536_z[543:512] = C0_bridge1_rtl_Q;
        5'h11: memwrite_head_ln536_z[575:544] = C0_bridge1_rtl_Q;
        5'h12: memwrite_head_ln536_z[607:576] = C0_bridge1_rtl_Q;
        5'h13: memwrite_head_ln536_z[639:608] = C0_bridge1_rtl_Q;
        5'h14: memwrite_head_ln536_z[671:640] = C0_bridge1_rtl_Q;
        5'h15: memwrite_head_ln536_z[703:672] = C0_bridge1_rtl_Q;
        5'h16: memwrite_head_ln536_z[735:704] = C0_bridge1_rtl_Q;
        5'h17: memwrite_head_ln536_z[767:736] = C0_bridge1_rtl_Q;
        5'h18: memwrite_head_ln536_z[799:768] = C0_bridge1_rtl_Q;
        5'h19: memwrite_head_ln536_z[831:800] = C0_bridge1_rtl_Q;
        5'h1a: memwrite_head_ln536_z[863:832] = C0_bridge1_rtl_Q;
        5'h1b: memwrite_head_ln536_z[895:864] = C0_bridge1_rtl_Q;
        5'h1c: memwrite_head_ln536_z[927:896] = C0_bridge1_rtl_Q;
        5'h1d: memwrite_head_ln536_z[959:928] = C0_bridge1_rtl_Q;
        5'h1e: memwrite_head_ln536_z[991:960] = C0_bridge1_rtl_Q;
        5'h1f: memwrite_head_ln536_z[1023:992] = C0_bridge1_rtl_Q;
        default: memwrite_head_ln536_z = 32'hX;
      endcase
      memwrite_head_ln410_z = mux_head_ln406_q;
      case (mux_chunk_ln406_q)// synthesis parallel_case
        5'h0: memwrite_head_ln410_z[31:0] = C0_bridge1_rtl_Q;
        5'h1: memwrite_head_ln410_z[63:32] = C0_bridge1_rtl_Q;
        5'h2: memwrite_head_ln410_z[95:64] = C0_bridge1_rtl_Q;
        5'h3: memwrite_head_ln410_z[127:96] = C0_bridge1_rtl_Q;
        5'h4: memwrite_head_ln410_z[159:128] = C0_bridge1_rtl_Q;
        5'h5: memwrite_head_ln410_z[191:160] = C0_bridge1_rtl_Q;
        5'h6: memwrite_head_ln410_z[223:192] = C0_bridge1_rtl_Q;
        5'h7: memwrite_head_ln410_z[255:224] = C0_bridge1_rtl_Q;
        5'h8: memwrite_head_ln410_z[287:256] = C0_bridge1_rtl_Q;
        5'h9: memwrite_head_ln410_z[319:288] = C0_bridge1_rtl_Q;
        5'ha: memwrite_head_ln410_z[351:320] = C0_bridge1_rtl_Q;
        5'hb: memwrite_head_ln410_z[383:352] = C0_bridge1_rtl_Q;
        5'hc: memwrite_head_ln410_z[415:384] = C0_bridge1_rtl_Q;
        5'hd: memwrite_head_ln410_z[447:416] = C0_bridge1_rtl_Q;
        5'he: memwrite_head_ln410_z[479:448] = C0_bridge1_rtl_Q;
        5'hf: memwrite_head_ln410_z[511:480] = C0_bridge1_rtl_Q;
        5'h10: memwrite_head_ln410_z[543:512] = C0_bridge1_rtl_Q;
        5'h11: memwrite_head_ln410_z[575:544] = C0_bridge1_rtl_Q;
        5'h12: memwrite_head_ln410_z[607:576] = C0_bridge1_rtl_Q;
        5'h13: memwrite_head_ln410_z[639:608] = C0_bridge1_rtl_Q;
        5'h14: memwrite_head_ln410_z[671:640] = C0_bridge1_rtl_Q;
        5'h15: memwrite_head_ln410_z[703:672] = C0_bridge1_rtl_Q;
        5'h16: memwrite_head_ln410_z[735:704] = C0_bridge1_rtl_Q;
        5'h17: memwrite_head_ln410_z[767:736] = C0_bridge1_rtl_Q;
        5'h18: memwrite_head_ln410_z[799:768] = C0_bridge1_rtl_Q;
        5'h19: memwrite_head_ln410_z[831:800] = C0_bridge1_rtl_Q;
        5'h1a: memwrite_head_ln410_z[863:832] = C0_bridge1_rtl_Q;
        5'h1b: memwrite_head_ln410_z[895:864] = C0_bridge1_rtl_Q;
        5'h1c: memwrite_head_ln410_z[927:896] = C0_bridge1_rtl_Q;
        5'h1d: memwrite_head_ln410_z[959:928] = C0_bridge1_rtl_Q;
        5'h1e: memwrite_head_ln410_z[991:960] = C0_bridge1_rtl_Q;
        5'h1f: memwrite_head_ln410_z[1023:992] = C0_bridge1_rtl_Q;
        default: memwrite_head_ln410_z = 32'hX;
      endcase
      add_ln536_z = mux_pop_idx_ln520_0_q + memread_fidx_ln536_z[9:5];
      memwrite_head_ln538_z = mux_head_ln536_q;
      case (mux_pop_idx_ln520_0_q)// synthesis parallel_case
        5'h0: memwrite_head_ln538_z[31:0] = C1_bridge1_rtl_Q;
        5'h1: memwrite_head_ln538_z[63:32] = C1_bridge1_rtl_Q;
        5'h2: memwrite_head_ln538_z[95:64] = C1_bridge1_rtl_Q;
        5'h3: memwrite_head_ln538_z[127:96] = C1_bridge1_rtl_Q;
        5'h4: memwrite_head_ln538_z[159:128] = C1_bridge1_rtl_Q;
        5'h5: memwrite_head_ln538_z[191:160] = C1_bridge1_rtl_Q;
        5'h6: memwrite_head_ln538_z[223:192] = C1_bridge1_rtl_Q;
        5'h7: memwrite_head_ln538_z[255:224] = C1_bridge1_rtl_Q;
        5'h8: memwrite_head_ln538_z[287:256] = C1_bridge1_rtl_Q;
        5'h9: memwrite_head_ln538_z[319:288] = C1_bridge1_rtl_Q;
        5'ha: memwrite_head_ln538_z[351:320] = C1_bridge1_rtl_Q;
        5'hb: memwrite_head_ln538_z[383:352] = C1_bridge1_rtl_Q;
        5'hc: memwrite_head_ln538_z[415:384] = C1_bridge1_rtl_Q;
        5'hd: memwrite_head_ln538_z[447:416] = C1_bridge1_rtl_Q;
        5'he: memwrite_head_ln538_z[479:448] = C1_bridge1_rtl_Q;
        5'hf: memwrite_head_ln538_z[511:480] = C1_bridge1_rtl_Q;
        5'h10: memwrite_head_ln538_z[543:512] = C1_bridge1_rtl_Q;
        5'h11: memwrite_head_ln538_z[575:544] = C1_bridge1_rtl_Q;
        5'h12: memwrite_head_ln538_z[607:576] = C1_bridge1_rtl_Q;
        5'h13: memwrite_head_ln538_z[639:608] = C1_bridge1_rtl_Q;
        5'h14: memwrite_head_ln538_z[671:640] = C1_bridge1_rtl_Q;
        5'h15: memwrite_head_ln538_z[703:672] = C1_bridge1_rtl_Q;
        5'h16: memwrite_head_ln538_z[735:704] = C1_bridge1_rtl_Q;
        5'h17: memwrite_head_ln538_z[767:736] = C1_bridge1_rtl_Q;
        5'h18: memwrite_head_ln538_z[799:768] = C1_bridge1_rtl_Q;
        5'h19: memwrite_head_ln538_z[831:800] = C1_bridge1_rtl_Q;
        5'h1a: memwrite_head_ln538_z[863:832] = C1_bridge1_rtl_Q;
        5'h1b: memwrite_head_ln538_z[895:864] = C1_bridge1_rtl_Q;
        5'h1c: memwrite_head_ln538_z[927:896] = C1_bridge1_rtl_Q;
        5'h1d: memwrite_head_ln538_z[959:928] = C1_bridge1_rtl_Q;
        5'h1e: memwrite_head_ln538_z[991:960] = C1_bridge1_rtl_Q;
        5'h1f: memwrite_head_ln538_z[1023:992] = C1_bridge1_rtl_Q;
        default: memwrite_head_ln538_z = 32'hX;
      endcase
      memwrite_head_ln412_z = mux_head_ln406_q;
      case (mux_chunk_ln406_q)// synthesis parallel_case
        5'h0: memwrite_head_ln412_z[31:0] = C1_bridge1_rtl_Q;
        5'h1: memwrite_head_ln412_z[63:32] = C1_bridge1_rtl_Q;
        5'h2: memwrite_head_ln412_z[95:64] = C1_bridge1_rtl_Q;
        5'h3: memwrite_head_ln412_z[127:96] = C1_bridge1_rtl_Q;
        5'h4: memwrite_head_ln412_z[159:128] = C1_bridge1_rtl_Q;
        5'h5: memwrite_head_ln412_z[191:160] = C1_bridge1_rtl_Q;
        5'h6: memwrite_head_ln412_z[223:192] = C1_bridge1_rtl_Q;
        5'h7: memwrite_head_ln412_z[255:224] = C1_bridge1_rtl_Q;
        5'h8: memwrite_head_ln412_z[287:256] = C1_bridge1_rtl_Q;
        5'h9: memwrite_head_ln412_z[319:288] = C1_bridge1_rtl_Q;
        5'ha: memwrite_head_ln412_z[351:320] = C1_bridge1_rtl_Q;
        5'hb: memwrite_head_ln412_z[383:352] = C1_bridge1_rtl_Q;
        5'hc: memwrite_head_ln412_z[415:384] = C1_bridge1_rtl_Q;
        5'hd: memwrite_head_ln412_z[447:416] = C1_bridge1_rtl_Q;
        5'he: memwrite_head_ln412_z[479:448] = C1_bridge1_rtl_Q;
        5'hf: memwrite_head_ln412_z[511:480] = C1_bridge1_rtl_Q;
        5'h10: memwrite_head_ln412_z[543:512] = C1_bridge1_rtl_Q;
        5'h11: memwrite_head_ln412_z[575:544] = C1_bridge1_rtl_Q;
        5'h12: memwrite_head_ln412_z[607:576] = C1_bridge1_rtl_Q;
        5'h13: memwrite_head_ln412_z[639:608] = C1_bridge1_rtl_Q;
        5'h14: memwrite_head_ln412_z[671:640] = C1_bridge1_rtl_Q;
        5'h15: memwrite_head_ln412_z[703:672] = C1_bridge1_rtl_Q;
        5'h16: memwrite_head_ln412_z[735:704] = C1_bridge1_rtl_Q;
        5'h17: memwrite_head_ln412_z[767:736] = C1_bridge1_rtl_Q;
        5'h18: memwrite_head_ln412_z[799:768] = C1_bridge1_rtl_Q;
        5'h19: memwrite_head_ln412_z[831:800] = C1_bridge1_rtl_Q;
        5'h1a: memwrite_head_ln412_z[863:832] = C1_bridge1_rtl_Q;
        5'h1b: memwrite_head_ln412_z[895:864] = C1_bridge1_rtl_Q;
        5'h1c: memwrite_head_ln412_z[927:896] = C1_bridge1_rtl_Q;
        5'h1d: memwrite_head_ln412_z[959:928] = C1_bridge1_rtl_Q;
        5'h1e: memwrite_head_ln412_z[991:960] = C1_bridge1_rtl_Q;
        5'h1f: memwrite_head_ln412_z[1023:992] = C1_bridge1_rtl_Q;
        default: memwrite_head_ln412_z = 32'hX;
      endcase
      add_ln539_z = memread_fidx_ln539_z + 32'h1;
      ctrlAnd_0_ln574_z = !add_ln574_1_q[4] & 
      state_sort_unisim_sort_merge_sort[19];
      if (eq_ln445_unr1_Z_0_tag_0) 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr0_0_z = 30'h0;
      else 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr0_0_z = {
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_q, 
        sort_unisim_lt_float_ln447_unr1_lt_float_out_q};
      if (eq_ln445_unr1_Z_0_tag_0) 
        mux_shift_MERGE_COMPARE_for_exit_unr0_0_ln456_z = 28'h0;
      else 
        mux_shift_MERGE_COMPARE_for_exit_unr0_0_ln456_z = {
        mux_shift_MERGE_COMPARE_for_exit_unr1_0_0_ln456_q, 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_q[0]};
      if (eq_ln445_unr27_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:896];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_q, 
        mux_regs_in_ln456_30_q[927:896]};
      and_1_ln523_unr9_0_z = !memread_pop_ln523_unr0_0_9_q[0] & !
      eq_ln445_unr8_Z_0_tag_0 & and_1_ln523_unr8_0_q;
      ctrlAnd_1_ln346_z = init_done & state_sort_unisim_sort_merge_sort[0];
      ctrlAnd_0_ln346_z = !init_done & state_sort_unisim_sort_merge_sort[0];
      ctrlAnd_1_ln379_z = rb_done & state_sort_unisim_sort_merge_sort[3];
      ctrlAnd_0_ln379_z = !rb_done & state_sort_unisim_sort_merge_sort[3];
      ctrlAnd_1_ln382_z = !rb_done & state_sort_unisim_sort_merge_sort[4];
      ctrlAnd_0_ln382_z = rb_done & state_sort_unisim_sort_merge_sort[4];
      ctrlAnd_1_ln592_z = output_start & state_sort_unisim_sort_merge_sort[12];
      ctrlAnd_0_ln592_z = !output_start & state_sort_unisim_sort_merge_sort[12];
      ctrlAnd_1_ln595_z = !output_start & state_sort_unisim_sort_merge_sort[13];
      ctrlAnd_0_ln595_z = output_start & state_sort_unisim_sort_merge_sort[13];
      ctrlAnd_1_ln564_z = !eq_ln564_q & state_sort_unisim_sort_merge_sort[11];
      ctrlOr_ln570_0_z = ctrlAnd_1_ln574_z | 
      state_sort_unisim_sort_merge_sort[16];
      if (state_sort_unisim_sort_merge_sort[1]) 
        mux_head_ln357_z = 1024'h0;
      else 
        mux_head_ln357_z = mux_head_ln387_q;
      if (state_sort_unisim_sort_merge_sort[1]) 
        mux_regs_0_ln357_z = 992'h0;
      else 
        mux_regs_0_ln357_z = mux_regs_0_ln387_q;
      if (state_sort_unisim_sort_merge_sort[1]) 
        mux_regs_in_ln357_z = 992'h0;
      else 
        mux_regs_in_ln357_z = mux_regs_in_ln387_q;
      if (state_sort_unisim_sort_merge_sort[5]) 
        mux_fidx_ln406_z = 1024'h0;
      else 
        mux_fidx_ln406_z = memwrite_fidx_ln414_q;
      if (state_sort_unisim_sort_merge_sort[7]) 
        mux_cur_ln440_z = 32'h2;
      else 
        mux_cur_ln440_z = mux_cur_ln558_q;
      if (state_sort_unisim_sort_merge_sort[7]) 
        mux_head_ln440_z = {mux_head_ln406_q[1023:32], mux_head_ln440_0_q};
      else 
        mux_head_ln440_z = mux_head_ln440_1_q;
      if (state_sort_unisim_sort_merge_sort[7]) 
        mux_regs_0_ln440_z = {mux_regs_0_ln357_q, mux_head_ln406_q[31:0]};
      else 
        mux_regs_0_ln440_z = mux_regs_0_ln510_q;
      if (state_sort_unisim_sort_merge_sort[7]) 
        mux_regs_in_ln440_z = mux_regs_in_ln357_q;
      else 
        mux_regs_in_ln440_z = mux_regs_in_ln456_30_q[1023:32];
      if (state_sort_unisim_sort_merge_sort[7]) 
        mux_cnt_ln440_z = 32'h0;
      else 
        mux_cnt_ln440_z = mux_cnt_ln507_q;
      if (state_sort_unisim_sort_merge_sort[11]) 
        mux_regs_0_ln387_z = mux_regs_0_ln510_q[1023:32];
      else 
        mux_regs_0_ln387_z = mux_regs_0_ln357_q;
      if (state_sort_unisim_sort_merge_sort[11]) 
        mux_regs_in_ln387_z = mux_regs_in_ln456_30_q[1023:32];
      else 
        mux_regs_in_ln387_z = mux_regs_in_ln357_q;
      memread_sort_C0_ln536_en = !ne_ln534_Z_0_tag_0 & mux_ping_ln357_Z_0_tag_0 & 
      state_sort_unisim_sort_merge_sort[10];
      memread_sort_C1_ln538_en = !ne_ln534_Z_0_tag_0 & !mux_ping_ln357_Z_0_tag_0 & 
      state_sort_unisim_sort_merge_sort[10];
      memwrite_sort_B1_ln512_en = !mux_ping_ln357_Z_0_tag_0 & 
      state_sort_unisim_sort_merge_sort[10] & eq_ln507_Z_0_tag_0;
      memwrite_sort_B1_ln585_en = !mux_ping_ln357_Z_0_tag_0 & 
      state_sort_unisim_sort_merge_sort[19];
      if (mux_ping_ln357_Z_0_tag_0) 
        mux_elem_ln577_z = C0_bridge1_rtl_Q;
      else 
        mux_elem_ln577_z = C1_bridge1_rtl_Q;
      if (mux_ping_ln357_Z_0_tag_0) 
        mux_head_ln440_0_z = C0_bridge1_rtl_Q;
      else 
        mux_head_ln440_0_z = C1_bridge1_rtl_Q;
      if (state_sort_unisim_sort_merge_sort[1]) 
        mux_ping_ln357_z = 1'b1;
      else 
        mux_ping_ln357_z = !mux_ping_ln357_Z_0_tag_0;
      if (state_sort_unisim_sort_merge_sort[1]) 
        mux_burst_ln357_z = 32'h0;
      else 
        mux_burst_ln357_z = {add_ln598_1_q, !mux_burst_ln357_q};
      if (state_sort_unisim_sort_merge_sort[16]) 
        mux_chunk_4_ln570_z = 6'h0;
      else 
        mux_chunk_4_ln570_z = {add_ln570_1_q, !mux_chunk_4_ln570_q[0]};
      if (state_sort_unisim_sort_merge_sort[5]) 
        mux_chunk_ln406_z = 6'h0;
      else 
        mux_chunk_ln406_z = {add_ln406_1_q, !mux_chunk_ln406_q[0]};
      if (state_sort_unisim_sort_merge_sort[7]) 
        mux_fidx_ln440_z = {mux_fidx_ln406_q[992:1], add_ln423_1_q, !
        mux_fidx_ln406_q[0]};
      else 
        mux_fidx_ln440_z = mux_fidx_ln440_0_q;
      if (state_sort_unisim_sort_merge_sort[17]) 
        mux_i_1_ln574_z = 5'h0;
      else 
        mux_i_1_ln574_z = {add_ln574_1_q[3:0], !mux_i_1_ln574_q[0]};
      case (1'b1)// synthesis parallel_case
        case_mux_head_ln440_1_q[0]: mux_head_ln440_1_z = mux_head_ln536_q;
        case_mux_head_ln440_1_q[1]: mux_head_ln440_1_z = memwrite_head_ln536_z;
        case_mux_head_ln440_1_q[2]: mux_head_ln440_1_z = memwrite_head_ln538_z;
        default: mux_head_ln440_1_z = 1024'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        case_mux_head_ln387_0_q[0]: mux_head_ln387_0_z = mux_head_ln536_q;
        case_mux_head_ln387_0_q[1]: mux_head_ln387_0_z = memwrite_head_ln536_z;
        case_mux_head_ln387_0_q[2]: mux_head_ln387_0_z = memwrite_head_ln538_z;
        default: mux_head_ln387_0_z = 1024'hX;
      endcase
      if (mux_ping_ln357_Z_0_tag_0) 
        mux_head_ln406_0_z = memwrite_head_ln410_z;
      else 
        mux_head_ln406_0_z = memwrite_head_ln412_z;
      memwrite_fidx_ln539_z = mux_fidx_ln440_q;
      case (mux_pop_idx_ln520_0_q)// synthesis parallel_case
        5'h0: memwrite_fidx_ln539_z[31:0] = add_ln539_z;
        5'h1: memwrite_fidx_ln539_z[63:32] = add_ln539_z;
        5'h2: memwrite_fidx_ln539_z[95:64] = add_ln539_z;
        5'h3: memwrite_fidx_ln539_z[127:96] = add_ln539_z;
        5'h4: memwrite_fidx_ln539_z[159:128] = add_ln539_z;
        5'h5: memwrite_fidx_ln539_z[191:160] = add_ln539_z;
        5'h6: memwrite_fidx_ln539_z[223:192] = add_ln539_z;
        5'h7: memwrite_fidx_ln539_z[255:224] = add_ln539_z;
        5'h8: memwrite_fidx_ln539_z[287:256] = add_ln539_z;
        5'h9: memwrite_fidx_ln539_z[319:288] = add_ln539_z;
        5'ha: memwrite_fidx_ln539_z[351:320] = add_ln539_z;
        5'hb: memwrite_fidx_ln539_z[383:352] = add_ln539_z;
        5'hc: memwrite_fidx_ln539_z[415:384] = add_ln539_z;
        5'hd: memwrite_fidx_ln539_z[447:416] = add_ln539_z;
        5'he: memwrite_fidx_ln539_z[479:448] = add_ln539_z;
        5'hf: memwrite_fidx_ln539_z[511:480] = add_ln539_z;
        5'h10: memwrite_fidx_ln539_z[543:512] = add_ln539_z;
        5'h11: memwrite_fidx_ln539_z[575:544] = add_ln539_z;
        5'h12: memwrite_fidx_ln539_z[607:576] = add_ln539_z;
        5'h13: memwrite_fidx_ln539_z[639:608] = add_ln539_z;
        5'h14: memwrite_fidx_ln539_z[671:640] = add_ln539_z;
        5'h15: memwrite_fidx_ln539_z[703:672] = add_ln539_z;
        5'h16: memwrite_fidx_ln539_z[735:704] = add_ln539_z;
        5'h17: memwrite_fidx_ln539_z[767:736] = add_ln539_z;
        5'h18: memwrite_fidx_ln539_z[799:768] = add_ln539_z;
        5'h19: memwrite_fidx_ln539_z[831:800] = add_ln539_z;
        5'h1a: memwrite_fidx_ln539_z[863:832] = add_ln539_z;
        5'h1b: memwrite_fidx_ln539_z[895:864] = add_ln539_z;
        5'h1c: memwrite_fidx_ln539_z[927:896] = add_ln539_z;
        5'h1d: memwrite_fidx_ln539_z[959:928] = add_ln539_z;
        5'h1e: memwrite_fidx_ln539_z[991:960] = add_ln539_z;
        5'h1f: memwrite_fidx_ln539_z[1023:992] = add_ln539_z;
        default: memwrite_fidx_ln539_z = 32'hX;
      endcase
      ctrlOr_ln574_z = ctrlAnd_0_ln574_z | state_sort_unisim_sort_merge_sort[17];
      if (eq_ln445_unr0_Z_0_tag_0) 
        memread_shift_ln460_unr0_0_z = 31'h0;
      else 
        memread_shift_ln460_unr0_0_z = {
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr0_0_z, 
        sort_unisim_lt_float_ln447_unr0_lt_float_out_q};
      if (eq_ln445_unr26_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:864];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_q[895:864]};
      and_1_ln523_unr10_0_z = !memread_pop_ln523_unr0_0_9_q[1] & !
      eq_ln445_unr9_Z_0_tag_0 & and_1_ln523_unr9_0_z;
      and_0_ln521_unr10_z = or_and_0_ln521_Z_0_unr10_q & and_1_ln523_unr9_0_z;
      ctrlAnd_1_ln387_z = gt_ln387_q & ctrlAnd_1_ln382_z;
      merge_start_hold = ~(ctrlAnd_1_ln382_z | ctrlAnd_1_ln379_z);
      ctrlAnd_0_ln387_z = !gt_ln387_q & ctrlAnd_1_ln382_z;
      ctrlOr_ln382_z = ctrlAnd_0_ln382_z | ctrlAnd_1_ln379_z;
      ctrlOr_ln357_z = ctrlAnd_1_ln595_z | state_sort_unisim_sort_merge_sort[1];
      ctrlOr_ln595_z = ctrlAnd_0_ln595_z | ctrlAnd_1_ln592_z;
      mux_cnt_ln507_sel = state_sort_unisim_sort_merge_sort[9] | 
      state_sort_unisim_sort_merge_sort[10] | 
      state_sort_unisim_sort_merge_sort[8] | ctrlAnd_1_ln564_z;
      mux_regs_0_ln510_sel = state_sort_unisim_sort_merge_sort[10] | 
      ctrlAnd_1_ln564_z;
      mux_regs_in_ln456_30_32_mux_0_sel = state_sort_unisim_sort_merge_sort[9] | 
      state_sort_unisim_sort_merge_sort[10] | ctrlAnd_1_ln564_z;
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_192_v_0 = mux_head_ln357_q[255:192];
      else 
        mux_mux_head_ln357_Z_192_v_0 = mux_head_ln357_z[255:192];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_256_v_0 = mux_head_ln357_q[319:256];
      else 
        mux_mux_head_ln357_Z_256_v_0 = mux_head_ln357_z[319:256];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_320_v_0 = mux_head_ln357_q[383:320];
      else 
        mux_mux_head_ln357_Z_320_v_0 = mux_head_ln357_z[383:320];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_384_v_0 = mux_head_ln357_q[447:384];
      else 
        mux_mux_head_ln357_Z_384_v_0 = mux_head_ln357_z[447:384];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_448_v_0 = mux_head_ln357_q[511:448];
      else 
        mux_mux_head_ln357_Z_448_v_0 = mux_head_ln357_z[511:448];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_512_v_0 = mux_head_ln357_q[575:512];
      else 
        mux_mux_head_ln357_Z_512_v_0 = mux_head_ln357_z[575:512];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_576_v_0 = mux_head_ln357_q[639:576];
      else 
        mux_mux_head_ln357_Z_576_v_0 = mux_head_ln357_z[639:576];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_640_v_0 = mux_head_ln357_q[703:640];
      else 
        mux_mux_head_ln357_Z_640_v_0 = mux_head_ln357_z[703:640];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_64_v_0 = mux_head_ln357_q[127:64];
      else 
        mux_mux_head_ln357_Z_64_v_0 = mux_head_ln357_z[127:64];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_704_v_0 = mux_head_ln357_q[767:704];
      else 
        mux_mux_head_ln357_Z_704_v_0 = mux_head_ln357_z[767:704];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_768_v_0 = mux_head_ln357_q[831:768];
      else 
        mux_mux_head_ln357_Z_768_v_0 = mux_head_ln357_z[831:768];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_832_v_0 = mux_head_ln357_q[895:832];
      else 
        mux_mux_head_ln357_Z_832_v_0 = mux_head_ln357_z[895:832];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_896_v_0 = mux_head_ln357_q[959:896];
      else 
        mux_mux_head_ln357_Z_896_v_0 = mux_head_ln357_z[959:896];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_960_v_0 = mux_head_ln357_q[1023:960];
      else 
        mux_mux_head_ln357_Z_960_v_0 = mux_head_ln357_z[1023:960];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_v = mux_head_ln357_q[63:0];
      else 
        mux_mux_head_ln357_Z_v = mux_head_ln357_z[63:0];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_head_ln357_Z_128_v_0 = mux_head_ln357_q[191:128];
      else 
        mux_mux_head_ln357_Z_128_v_0 = mux_head_ln357_z[191:128];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_192_v_0 = mux_regs_0_ln357_q[255:192];
      else 
        mux_mux_regs_0_ln357_Z_192_v_0 = mux_regs_0_ln357_z[255:192];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_256_v_0 = mux_regs_0_ln357_q[319:256];
      else 
        mux_mux_regs_0_ln357_Z_256_v_0 = mux_regs_0_ln357_z[319:256];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_320_v_0 = mux_regs_0_ln357_q[383:320];
      else 
        mux_mux_regs_0_ln357_Z_320_v_0 = mux_regs_0_ln357_z[383:320];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_384_v_0 = mux_regs_0_ln357_q[447:384];
      else 
        mux_mux_regs_0_ln357_Z_384_v_0 = mux_regs_0_ln357_z[447:384];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_448_v_0 = mux_regs_0_ln357_q[511:448];
      else 
        mux_mux_regs_0_ln357_Z_448_v_0 = mux_regs_0_ln357_z[511:448];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_512_v_0 = mux_regs_0_ln357_q[575:512];
      else 
        mux_mux_regs_0_ln357_Z_512_v_0 = mux_regs_0_ln357_z[575:512];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_576_v_0 = mux_regs_0_ln357_q[639:576];
      else 
        mux_mux_regs_0_ln357_Z_576_v_0 = mux_regs_0_ln357_z[639:576];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_640_v_0 = mux_regs_0_ln357_q[703:640];
      else 
        mux_mux_regs_0_ln357_Z_640_v_0 = mux_regs_0_ln357_z[703:640];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_64_v_0 = mux_regs_0_ln357_q[127:64];
      else 
        mux_mux_regs_0_ln357_Z_64_v_0 = mux_regs_0_ln357_z[127:64];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_704_v_0 = mux_regs_0_ln357_q[767:704];
      else 
        mux_mux_regs_0_ln357_Z_704_v_0 = mux_regs_0_ln357_z[767:704];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_768_v_0 = mux_regs_0_ln357_q[831:768];
      else 
        mux_mux_regs_0_ln357_Z_768_v_0 = mux_regs_0_ln357_z[831:768];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_832_v_0 = mux_regs_0_ln357_q[895:832];
      else 
        mux_mux_regs_0_ln357_Z_832_v_0 = mux_regs_0_ln357_z[895:832];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_896_v_0 = mux_regs_0_ln357_q[959:896];
      else 
        mux_mux_regs_0_ln357_Z_896_v_0 = mux_regs_0_ln357_z[959:896];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_960_v_0 = mux_regs_0_ln357_q[991:960];
      else 
        mux_mux_regs_0_ln357_Z_960_v_0 = mux_regs_0_ln357_z[991:960];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_v = mux_regs_0_ln357_q[63:0];
      else 
        mux_mux_regs_0_ln357_Z_v = mux_regs_0_ln357_z[63:0];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_0_ln357_Z_128_v_0 = mux_regs_0_ln357_q[191:128];
      else 
        mux_mux_regs_0_ln357_Z_128_v_0 = mux_regs_0_ln357_z[191:128];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_192_v_0 = mux_regs_in_ln357_q[255:192];
      else 
        mux_mux_regs_in_ln357_Z_192_v_0 = mux_regs_in_ln357_z[255:192];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_256_v_0 = mux_regs_in_ln357_q[319:256];
      else 
        mux_mux_regs_in_ln357_Z_256_v_0 = mux_regs_in_ln357_z[319:256];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_320_v_0 = mux_regs_in_ln357_q[383:320];
      else 
        mux_mux_regs_in_ln357_Z_320_v_0 = mux_regs_in_ln357_z[383:320];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_384_v_0 = mux_regs_in_ln357_q[447:384];
      else 
        mux_mux_regs_in_ln357_Z_384_v_0 = mux_regs_in_ln357_z[447:384];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_448_v_0 = mux_regs_in_ln357_q[511:448];
      else 
        mux_mux_regs_in_ln357_Z_448_v_0 = mux_regs_in_ln357_z[511:448];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_512_v_0 = mux_regs_in_ln357_q[575:512];
      else 
        mux_mux_regs_in_ln357_Z_512_v_0 = mux_regs_in_ln357_z[575:512];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_576_v_0 = mux_regs_in_ln357_q[639:576];
      else 
        mux_mux_regs_in_ln357_Z_576_v_0 = mux_regs_in_ln357_z[639:576];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_640_v_0 = mux_regs_in_ln357_q[703:640];
      else 
        mux_mux_regs_in_ln357_Z_640_v_0 = mux_regs_in_ln357_z[703:640];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_64_v_0 = mux_regs_in_ln357_q[127:64];
      else 
        mux_mux_regs_in_ln357_Z_64_v_0 = mux_regs_in_ln357_z[127:64];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_704_v_0 = mux_regs_in_ln357_q[767:704];
      else 
        mux_mux_regs_in_ln357_Z_704_v_0 = mux_regs_in_ln357_z[767:704];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_768_v_0 = mux_regs_in_ln357_q[831:768];
      else 
        mux_mux_regs_in_ln357_Z_768_v_0 = mux_regs_in_ln357_z[831:768];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_832_v_0 = mux_regs_in_ln357_q[895:832];
      else 
        mux_mux_regs_in_ln357_Z_832_v_0 = mux_regs_in_ln357_z[895:832];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_896_v_0 = mux_regs_in_ln357_q[959:896];
      else 
        mux_mux_regs_in_ln357_Z_896_v_0 = mux_regs_in_ln357_z[959:896];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_960_v_0 = mux_regs_in_ln357_q[991:960];
      else 
        mux_mux_regs_in_ln357_Z_960_v_0 = mux_regs_in_ln357_z[991:960];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_v = mux_regs_in_ln357_q[63:0];
      else 
        mux_mux_regs_in_ln357_Z_v = mux_regs_in_ln357_z[63:0];
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_regs_in_ln357_Z_128_v_0 = mux_regs_in_ln357_q[191:128];
      else 
        mux_mux_regs_in_ln357_Z_128_v_0 = mux_regs_in_ln357_z[191:128];
      add_ln423_z = mux_fidx_ln406_z[31:0] + 32'h1;
      eq_ln445_unr0_z = mux_cur_ln440_z == 32'h1;
      eq_ln445_unr1_z = mux_cur_ln440_z == 32'h2;
      eq_ln445_unr10_z = mux_cur_ln440_z == 32'hb;
      eq_ln445_unr11_z = mux_cur_ln440_z == 32'hc;
      eq_ln445_unr12_z = mux_cur_ln440_z == 32'hd;
      eq_ln445_unr13_z = mux_cur_ln440_z == 32'he;
      eq_ln445_unr14_z = mux_cur_ln440_z == 32'hf;
      eq_ln445_unr15_z = mux_cur_ln440_z == 32'h10;
      eq_ln445_unr16_z = mux_cur_ln440_z == 32'h11;
      eq_ln445_unr17_z = mux_cur_ln440_z == 32'h12;
      eq_ln445_unr18_z = mux_cur_ln440_z == 32'h13;
      eq_ln445_unr19_z = mux_cur_ln440_z == 32'h14;
      eq_ln445_unr2_z = mux_cur_ln440_z == 32'h3;
      eq_ln445_unr20_z = mux_cur_ln440_z == 32'h15;
      eq_ln445_unr21_z = mux_cur_ln440_z == 32'h16;
      eq_ln445_unr22_z = mux_cur_ln440_z == 32'h17;
      eq_ln445_unr23_z = mux_cur_ln440_z == 32'h18;
      eq_ln445_unr24_z = mux_cur_ln440_z == 32'h19;
      eq_ln445_unr25_z = mux_cur_ln440_z == 32'h1a;
      eq_ln445_unr26_z = mux_cur_ln440_z == 32'h1b;
      eq_ln445_unr27_z = mux_cur_ln440_z == 32'h1c;
      eq_ln445_unr28_z = mux_cur_ln440_z == 32'h1d;
      eq_ln445_unr29_z = mux_cur_ln440_z == 32'h1e;
      eq_ln445_unr3_z = mux_cur_ln440_z == 32'h4;
      eq_ln445_unr30_z = mux_cur_ln440_z == 32'h1f;
      eq_ln445_unr4_z = mux_cur_ln440_z == 32'h5;
      eq_ln445_unr5_z = mux_cur_ln440_z == 32'h6;
      eq_ln445_unr6_z = mux_cur_ln440_z == 32'h7;
      eq_ln445_unr7_z = mux_cur_ln440_z == 32'h8;
      eq_ln445_unr8_z = mux_cur_ln440_z == 32'h9;
      eq_ln445_unr9_z = mux_cur_ln440_z == 32'ha;
      eq_ln485_unr0_z = mux_cur_ln440_z == 32'h0;
      eq_ln507_z = mux_cur_ln440_z == {5'h0, read_sort_len_ln352_q[31:5]};
      ge_ln457_unr0_z = mux_cur_ln440_z[31:5] == 27'h0;
      ge_ln457_unr16_z = mux_cur_ln440_z[31:4] == 28'h0;
      ge_ln457_unr24_z = mux_cur_ln440_z[31:3] == 29'h0;
      ge_ln457_unr28_z = mux_cur_ln440_z[31:2] == 30'h0;
      ge_ln457_unr30_z = mux_cur_ln440_z[31:1] == 31'h0;
      lt_ln558_z = {6'h0, read_sort_len_ln352_q[31:5]} > {1'b0, mux_cur_ln440_z};
      ge_ln457_unr10_z = mux_cur_ln440_z[31:1] <= 31'ha;
      ge_ln457_unr21_z = mux_cur_ln440_z <= 32'ha;
      ge_ln457_unr6_z = mux_cur_ln440_z[31:1] <= 31'hc;
      ge_ln457_unr19_z = mux_cur_ln440_z <= 32'hc;
      ge_ln457_unr2_z = mux_cur_ln440_z[31:1] <= 31'he;
      ge_ln457_unr17_z = mux_cur_ln440_z <= 32'he;
      ge_ln457_unr15_z = mux_cur_ln440_z <= 32'h10;
      ge_ln457_unr13_z = mux_cur_ln440_z <= 32'h12;
      ge_ln457_unr11_z = mux_cur_ln440_z <= 32'h14;
      ge_ln457_unr9_z = mux_cur_ln440_z <= 32'h16;
      ge_ln457_unr7_z = mux_cur_ln440_z <= 32'h18;
      ge_ln457_unr5_z = mux_cur_ln440_z <= 32'h1a;
      ge_ln457_unr3_z = mux_cur_ln440_z <= 32'h1c;
      ge_ln457_unr8_z = mux_cur_ln440_z[31:3] <= 29'h2;
      ge_ln457_unr20_z = mux_cur_ln440_z[31:2] <= 30'h2;
      ge_ln457_unr26_z = mux_cur_ln440_z[31:1] <= 31'h2;
      ge_ln457_unr29_z = mux_cur_ln440_z <= 32'h2;
      ge_ln457_unr1_z = mux_cur_ln440_z <= 32'h1e;
      ge_ln457_unr12_z = mux_cur_ln440_z[31:2] <= 30'h4;
      ge_ln457_unr22_z = mux_cur_ln440_z[31:1] <= 31'h4;
      ge_ln457_unr27_z = mux_cur_ln440_z <= 32'h4;
      ge_ln457_unr4_z = mux_cur_ln440_z[31:2] <= 30'h6;
      ge_ln457_unr18_z = mux_cur_ln440_z[31:1] <= 31'h6;
      ge_ln457_unr25_z = mux_cur_ln440_z <= 32'h6;
      ge_ln457_unr14_z = mux_cur_ln440_z[31:1] <= 31'h8;
      ge_ln457_unr23_z = mux_cur_ln440_z <= 32'h8;
      add_ln559_z = mux_cur_ln440_z + 32'h1;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_224_d_0 = mux_head_ln440_z[287:224];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_224_d_0 = 
          mux_head_ln440_q[287:224];
        default: mux_head_ln440_224_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_288_d_0 = mux_head_ln440_z[351:288];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_288_d_0 = 
          mux_head_ln440_q[351:288];
        default: mux_head_ln440_288_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_32_d_0 = mux_head_ln440_z[95:32];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_32_d_0 = 
          mux_head_ln440_q[95:32];
        default: mux_head_ln440_32_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_352_d_0 = mux_head_ln440_z[415:352];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_352_d_0 = 
          mux_head_ln440_q[415:352];
        default: mux_head_ln440_352_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_416_d_0 = mux_head_ln440_z[479:416];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_416_d_0 = 
          mux_head_ln440_q[479:416];
        default: mux_head_ln440_416_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_480_d_0 = mux_head_ln440_z[543:480];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_480_d_0 = 
          mux_head_ln440_q[543:480];
        default: mux_head_ln440_480_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_544_d_0 = mux_head_ln440_z[607:544];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_544_d_0 = 
          mux_head_ln440_q[607:544];
        default: mux_head_ln440_544_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_608_d_0 = mux_head_ln440_z[671:608];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_608_d_0 = 
          mux_head_ln440_q[671:608];
        default: mux_head_ln440_608_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_672_d_0 = mux_head_ln440_z[735:672];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_672_d_0 = 
          mux_head_ln440_q[735:672];
        default: mux_head_ln440_672_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_736_d_0 = mux_head_ln440_z[799:736];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_736_d_0 = 
          mux_head_ln440_q[799:736];
        default: mux_head_ln440_736_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_800_d_0 = mux_head_ln440_z[863:800];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_800_d_0 = 
          mux_head_ln440_q[863:800];
        default: mux_head_ln440_800_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_864_d_0 = mux_head_ln440_z[927:864];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_864_d_0 = 
          mux_head_ln440_q[927:864];
        default: mux_head_ln440_864_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_928_d_0 = mux_head_ln440_z[991:928];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_928_d_0 = 
          mux_head_ln440_q[991:928];
        default: mux_head_ln440_928_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_96_d_0 = mux_head_ln440_z[159:96];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_96_d_0 = 
          mux_head_ln440_q[159:96];
        default: mux_head_ln440_96_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_160_d_0 = mux_head_ln440_z[223:160];
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_160_d_0 = 
          mux_head_ln440_q[223:160];
        default: mux_head_ln440_160_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_160_d_0 = mux_regs_0_ln440_z[223:160];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_160_d_0 = 
          mux_regs_0_ln440_q[223:160];
        default: mux_regs_0_ln440_160_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_224_d_0 = mux_regs_0_ln440_z[287:224];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_224_d_0 = 
          mux_regs_0_ln440_q[287:224];
        default: mux_regs_0_ln440_224_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_288_d_0 = mux_regs_0_ln440_z[351:288];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_288_d_0 = 
          mux_regs_0_ln440_q[351:288];
        default: mux_regs_0_ln440_288_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_32_d_0 = mux_regs_0_ln440_z[95:32];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_32_d_0 = 
          mux_regs_0_ln440_q[95:32];
        default: mux_regs_0_ln440_32_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_352_d_0 = mux_regs_0_ln440_z[415:352];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_352_d_0 = 
          mux_regs_0_ln440_q[415:352];
        default: mux_regs_0_ln440_352_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_416_d_0 = mux_regs_0_ln440_z[479:416];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_416_d_0 = 
          mux_regs_0_ln440_q[479:416];
        default: mux_regs_0_ln440_416_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_480_d_0 = mux_regs_0_ln440_z[543:480];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_480_d_0 = 
          mux_regs_0_ln440_q[543:480];
        default: mux_regs_0_ln440_480_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_544_d_0 = mux_regs_0_ln440_z[607:544];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_544_d_0 = 
          mux_regs_0_ln440_q[607:544];
        default: mux_regs_0_ln440_544_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_608_d_0 = mux_regs_0_ln440_z[671:608];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_608_d_0 = 
          mux_regs_0_ln440_q[671:608];
        default: mux_regs_0_ln440_608_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_672_d_0 = mux_regs_0_ln440_z[735:672];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_672_d_0 = 
          mux_regs_0_ln440_q[735:672];
        default: mux_regs_0_ln440_672_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_736_d_0 = mux_regs_0_ln440_z[799:736];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_736_d_0 = 
          mux_regs_0_ln440_q[799:736];
        default: mux_regs_0_ln440_736_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_800_d_0 = mux_regs_0_ln440_z[863:800];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_800_d_0 = 
          mux_regs_0_ln440_q[863:800];
        default: mux_regs_0_ln440_800_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_864_d_0 = mux_regs_0_ln440_z[927:864];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_864_d_0 = 
          mux_regs_0_ln440_q[927:864];
        default: mux_regs_0_ln440_864_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_928_d_0 = mux_regs_0_ln440_z[991:928];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_928_d_0 = 
          mux_regs_0_ln440_q[991:928];
        default: mux_regs_0_ln440_928_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_96_d_0 = mux_regs_0_ln440_z[159:96];
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_96_d_0 = 
          mux_regs_0_ln440_q[159:96];
        default: mux_regs_0_ln440_96_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_regs_0_ln440_992_d_0 = {mux_head_ln440_z[31:0], 
          mux_regs_0_ln440_z[1023:992]};
        state_sort_unisim_sort_merge_sort[8]: mux_regs_0_ln440_992_d_0 = {
          mux_head_ln440_q[31:0], mux_regs_0_ln440_q[1023:992]};
        default: mux_regs_0_ln440_992_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_cur_ln440_d = {mux_regs_0_ln440_z[31:0], 
          mux_cur_ln440_z};
        state_sort_unisim_sort_merge_sort[8]: mux_cur_ln440_d = {
          mux_regs_0_ln440_q[31:0], mux_cur_ln440_q};
        default: mux_cur_ln440_d = 64'hX;
      endcase
      add_ln513_z = mux_cnt_ln440_z + 32'h1;
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_192_v_0 = mux_regs_0_ln387_q[255:192];
      else 
        mux_mux_regs_0_ln387_Z_192_v_0 = mux_regs_0_ln387_z[255:192];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_256_v_0 = mux_regs_0_ln387_q[319:256];
      else 
        mux_mux_regs_0_ln387_Z_256_v_0 = mux_regs_0_ln387_z[319:256];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_320_v_0 = mux_regs_0_ln387_q[383:320];
      else 
        mux_mux_regs_0_ln387_Z_320_v_0 = mux_regs_0_ln387_z[383:320];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_384_v_0 = mux_regs_0_ln387_q[447:384];
      else 
        mux_mux_regs_0_ln387_Z_384_v_0 = mux_regs_0_ln387_z[447:384];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_448_v_0 = mux_regs_0_ln387_q[511:448];
      else 
        mux_mux_regs_0_ln387_Z_448_v_0 = mux_regs_0_ln387_z[511:448];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_512_v_0 = mux_regs_0_ln387_q[575:512];
      else 
        mux_mux_regs_0_ln387_Z_512_v_0 = mux_regs_0_ln387_z[575:512];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_576_v_0 = mux_regs_0_ln387_q[639:576];
      else 
        mux_mux_regs_0_ln387_Z_576_v_0 = mux_regs_0_ln387_z[639:576];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_640_v_0 = mux_regs_0_ln387_q[703:640];
      else 
        mux_mux_regs_0_ln387_Z_640_v_0 = mux_regs_0_ln387_z[703:640];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_64_v_0 = mux_regs_0_ln387_q[127:64];
      else 
        mux_mux_regs_0_ln387_Z_64_v_0 = mux_regs_0_ln387_z[127:64];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_704_v_0 = mux_regs_0_ln387_q[767:704];
      else 
        mux_mux_regs_0_ln387_Z_704_v_0 = mux_regs_0_ln387_z[767:704];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_768_v_0 = mux_regs_0_ln387_q[831:768];
      else 
        mux_mux_regs_0_ln387_Z_768_v_0 = mux_regs_0_ln387_z[831:768];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_832_v_0 = mux_regs_0_ln387_q[895:832];
      else 
        mux_mux_regs_0_ln387_Z_832_v_0 = mux_regs_0_ln387_z[895:832];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_896_v_0 = mux_regs_0_ln387_q[959:896];
      else 
        mux_mux_regs_0_ln387_Z_896_v_0 = mux_regs_0_ln387_z[959:896];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_960_v_0 = mux_regs_0_ln387_q[991:960];
      else 
        mux_mux_regs_0_ln387_Z_960_v_0 = mux_regs_0_ln387_z[991:960];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_v = mux_regs_0_ln387_q[63:0];
      else 
        mux_mux_regs_0_ln387_Z_v = mux_regs_0_ln387_z[63:0];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_0_ln387_Z_128_v_0 = mux_regs_0_ln387_q[191:128];
      else 
        mux_mux_regs_0_ln387_Z_128_v_0 = mux_regs_0_ln387_z[191:128];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_192_v_0 = mux_regs_in_ln387_q[255:192];
      else 
        mux_mux_regs_in_ln387_Z_192_v_0 = mux_regs_in_ln387_z[255:192];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_256_v_0 = mux_regs_in_ln387_q[319:256];
      else 
        mux_mux_regs_in_ln387_Z_256_v_0 = mux_regs_in_ln387_z[319:256];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_320_v_0 = mux_regs_in_ln387_q[383:320];
      else 
        mux_mux_regs_in_ln387_Z_320_v_0 = mux_regs_in_ln387_z[383:320];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_384_v_0 = mux_regs_in_ln387_q[447:384];
      else 
        mux_mux_regs_in_ln387_Z_384_v_0 = mux_regs_in_ln387_z[447:384];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_448_v_0 = mux_regs_in_ln387_q[511:448];
      else 
        mux_mux_regs_in_ln387_Z_448_v_0 = mux_regs_in_ln387_z[511:448];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_512_v_0 = mux_regs_in_ln387_q[575:512];
      else 
        mux_mux_regs_in_ln387_Z_512_v_0 = mux_regs_in_ln387_z[575:512];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_576_v_0 = mux_regs_in_ln387_q[639:576];
      else 
        mux_mux_regs_in_ln387_Z_576_v_0 = mux_regs_in_ln387_z[639:576];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_640_v_0 = mux_regs_in_ln387_q[703:640];
      else 
        mux_mux_regs_in_ln387_Z_640_v_0 = mux_regs_in_ln387_z[703:640];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_64_v_0 = mux_regs_in_ln387_q[127:64];
      else 
        mux_mux_regs_in_ln387_Z_64_v_0 = mux_regs_in_ln387_z[127:64];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_704_v_0 = mux_regs_in_ln387_q[767:704];
      else 
        mux_mux_regs_in_ln387_Z_704_v_0 = mux_regs_in_ln387_z[767:704];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_768_v_0 = mux_regs_in_ln387_q[831:768];
      else 
        mux_mux_regs_in_ln387_Z_768_v_0 = mux_regs_in_ln387_z[831:768];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_832_v_0 = mux_regs_in_ln387_q[895:832];
      else 
        mux_mux_regs_in_ln387_Z_832_v_0 = mux_regs_in_ln387_z[895:832];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_896_v_0 = mux_regs_in_ln387_q[959:896];
      else 
        mux_mux_regs_in_ln387_Z_896_v_0 = mux_regs_in_ln387_z[959:896];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_960_v_0 = mux_regs_in_ln387_q[991:960];
      else 
        mux_mux_regs_in_ln387_Z_960_v_0 = mux_regs_in_ln387_z[991:960];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_v = mux_regs_in_ln387_q[63:0];
      else 
        mux_mux_regs_in_ln387_Z_v = mux_regs_in_ln387_z[63:0];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_regs_in_ln387_Z_128_v_0 = mux_regs_in_ln387_q[191:128];
      else 
        mux_mux_regs_in_ln387_Z_128_v_0 = mux_regs_in_ln387_z[191:128];
      B1_bridge0_rtl_CE_en = memwrite_sort_B1_ln585_en | 
      memwrite_sort_B1_ln512_en;
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_ping_ln357_Z_0_v = mux_ping_ln357_Z_0_tag_0;
      else 
        mux_mux_ping_ln357_Z_0_v = mux_ping_ln357_z;
      eq_ln374_z = mux_burst_ln357_z == read_sort_batch_ln353_q;
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_mux_burst_ln357_Z_0_v = mux_burst_ln357_q;
      else 
        mux_mux_burst_ln357_Z_0_v = mux_burst_ln357_z[0];
      add_ln598_z = mux_burst_ln357_z + 32'h1;
      eq_ln571_z = mux_chunk_4_ln570_z == {5'h0, read_sort_len_ln352_q[5]};
      lt_ln570_z = ~mux_chunk_4_ln570_z[5];
      add_ln570_z = {1'b0, mux_chunk_4_ln570_z[4:0]} + 6'h1;
      add_ln406_z = {1'b0, mux_chunk_ln406_z[4:0]} + 6'h1;
      eq_ln407_z = {21'h0, mux_chunk_ln406_z} == read_sort_len_ln352_q[31:5];
      lt_ln406_z = ~mux_chunk_ln406_z[5];
      case (mux_chunk_ln406_z[4:0])// synthesis parallel_case
        5'h0: memread_fidx_ln414_z = mux_fidx_ln406_z[31:0];
        5'h1: memread_fidx_ln414_z = mux_fidx_ln406_z[63:32];
        5'h2: memread_fidx_ln414_z = mux_fidx_ln406_z[95:64];
        5'h3: memread_fidx_ln414_z = mux_fidx_ln406_z[127:96];
        5'h4: memread_fidx_ln414_z = mux_fidx_ln406_z[159:128];
        5'h5: memread_fidx_ln414_z = mux_fidx_ln406_z[191:160];
        5'h6: memread_fidx_ln414_z = mux_fidx_ln406_z[223:192];
        5'h7: memread_fidx_ln414_z = mux_fidx_ln406_z[255:224];
        5'h8: memread_fidx_ln414_z = mux_fidx_ln406_z[287:256];
        5'h9: memread_fidx_ln414_z = mux_fidx_ln406_z[319:288];
        5'ha: memread_fidx_ln414_z = mux_fidx_ln406_z[351:320];
        5'hb: memread_fidx_ln414_z = mux_fidx_ln406_z[383:352];
        5'hc: memread_fidx_ln414_z = mux_fidx_ln406_z[415:384];
        5'hd: memread_fidx_ln414_z = mux_fidx_ln406_z[447:416];
        5'he: memread_fidx_ln414_z = mux_fidx_ln406_z[479:448];
        5'hf: memread_fidx_ln414_z = mux_fidx_ln406_z[511:480];
        5'h10: memread_fidx_ln414_z = mux_fidx_ln406_z[543:512];
        5'h11: memread_fidx_ln414_z = mux_fidx_ln406_z[575:544];
        5'h12: memread_fidx_ln414_z = mux_fidx_ln406_z[607:576];
        5'h13: memread_fidx_ln414_z = mux_fidx_ln406_z[639:608];
        5'h14: memread_fidx_ln414_z = mux_fidx_ln406_z[671:640];
        5'h15: memread_fidx_ln414_z = mux_fidx_ln406_z[703:672];
        5'h16: memread_fidx_ln414_z = mux_fidx_ln406_z[735:704];
        5'h17: memread_fidx_ln414_z = mux_fidx_ln406_z[767:736];
        5'h18: memread_fidx_ln414_z = mux_fidx_ln406_z[799:768];
        5'h19: memread_fidx_ln414_z = mux_fidx_ln406_z[831:800];
        5'h1a: memread_fidx_ln414_z = mux_fidx_ln406_z[863:832];
        5'h1b: memread_fidx_ln414_z = mux_fidx_ln406_z[895:864];
        5'h1c: memread_fidx_ln414_z = mux_fidx_ln406_z[927:896];
        5'h1d: memread_fidx_ln414_z = mux_fidx_ln406_z[959:928];
        5'h1e: memread_fidx_ln414_z = mux_fidx_ln406_z[991:960];
        5'h1f: memread_fidx_ln414_z = mux_fidx_ln406_z[1023:992];
        default: memread_fidx_ln414_z = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_1014_d_0 = mux_fidx_ln440_z[1023:1014];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_1014_d_0 = mux_fidx_ln440_q[1023:
          1014];
        default: mux_fidx_ln440_1014_d_0 = 10'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_118_d_0 = mux_fidx_ln440_z[181:118];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_118_d_0 = mux_fidx_ln440_q[181:118];
        default: mux_fidx_ln440_118_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_182_d_0 = mux_fidx_ln440_z[245:182];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_182_d_0 = mux_fidx_ln440_q[245:182];
        default: mux_fidx_ln440_182_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_246_d_0 = mux_fidx_ln440_z[309:246];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_246_d_0 = mux_fidx_ln440_q[309:246];
        default: mux_fidx_ln440_246_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_310_d_0 = mux_fidx_ln440_z[373:310];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_310_d_0 = mux_fidx_ln440_q[373:310];
        default: mux_fidx_ln440_310_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_374_d_0 = mux_fidx_ln440_z[437:374];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_374_d_0 = mux_fidx_ln440_q[437:374];
        default: mux_fidx_ln440_374_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_438_d_0 = mux_fidx_ln440_z[501:438];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_438_d_0 = mux_fidx_ln440_q[501:438];
        default: mux_fidx_ln440_438_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_502_d_0 = mux_fidx_ln440_z[565:502];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_502_d_0 = mux_fidx_ln440_q[565:502];
        default: mux_fidx_ln440_502_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_54_d_0 = mux_fidx_ln440_z[117:54];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_54_d_0 = mux_fidx_ln440_q[117:54];
        default: mux_fidx_ln440_54_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_566_d_0 = mux_fidx_ln440_z[629:566];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_566_d_0 = mux_fidx_ln440_q[629:566];
        default: mux_fidx_ln440_566_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_630_d_0 = mux_fidx_ln440_z[693:630];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_630_d_0 = mux_fidx_ln440_q[693:630];
        default: mux_fidx_ln440_630_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_694_d_0 = mux_fidx_ln440_z[757:694];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_694_d_0 = mux_fidx_ln440_q[757:694];
        default: mux_fidx_ln440_694_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_758_d_0 = mux_fidx_ln440_z[821:758];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_758_d_0 = mux_fidx_ln440_q[821:758];
        default: mux_fidx_ln440_758_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_822_d_0 = mux_fidx_ln440_z[885:822];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_822_d_0 = mux_fidx_ln440_q[885:822];
        default: mux_fidx_ln440_822_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_886_d_0 = mux_fidx_ln440_z[949:886];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_886_d_0 = mux_fidx_ln440_q[949:886];
        default: mux_fidx_ln440_886_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_fidx_ln440_950_d_0 = mux_fidx_ln440_z[1013:950];
        eq_ln507_Z_0_tag_sel: mux_fidx_ln440_950_d_0 = mux_fidx_ln440_q[1013:950];
        default: mux_fidx_ln440_950_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_cnt_ln440_d = {mux_fidx_ln440_z[53:0], 
          mux_cnt_ln440_z[9:0]};
        eq_ln507_Z_0_tag_sel: mux_cnt_ln440_d = {mux_fidx_ln440_q[53:0], 
          mux_cnt_ln440_q};
        default: mux_cnt_ln440_d = 64'hX;
      endcase
      add_ln574_z = {1'b0, mux_i_1_ln574_z} + 6'h1;
      if (state_sort_unisim_sort_merge_sort[11]) 
        mux_head_ln387_z = mux_head_ln387_0_z;
      else 
        mux_head_ln387_z = mux_head_ln357_q;
      if (state_sort_unisim_sort_merge_sort[5]) 
        mux_head_ln406_z = mux_head_ln357_q;
      else 
        mux_head_ln406_z = mux_head_ln406_0_z;
      if (ne_ln534_Z_0_tag_0) 
        mux_fidx_ln440_0_z = mux_fidx_ln440_q;
      else 
        mux_fidx_ln440_0_z = memwrite_fidx_ln539_z;
      memread_sort_C0_ln578_en = mux_ping_ln357_Z_0_tag_0 & ctrlOr_ln574_z;
      memread_sort_C1_ln580_en = !mux_ping_ln357_Z_0_tag_0 & ctrlOr_ln574_z;
      mux_chunk_4_ln570_sel = state_sort_unisim_sort_merge_sort[18] | 
      ctrlOr_ln574_z;
      and_0_ln460_unr30_z = memread_shift_ln460_unr0_0_z[0] & !ge_ln457_unr30_q;
      if_ln460_unr0_z = ~memread_shift_ln460_unr0_0_z[30];
      if_ln460_unr30_z = ~memread_shift_ln460_unr0_0_z[0];
      case (1'b1)// synthesis parallel_case
        case_mux_shift_ln456_q[0]: mux_shift_ln456_z = 
          memread_shift_ln460_unr0_0_z[29:1];
        case_mux_shift_ln456_q[1]: mux_shift_ln456_z = 29'h0;
        case_mux_shift_ln456_q[2]: mux_shift_ln456_z = {
          mux_shift_MERGE_COMPARE_for_exit_unr0_0_ln456_z, 
          memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr0_0_z[0]};
        default: mux_shift_ln456_z = 29'hX;
      endcase
      or_and_0_ln460_unr0_Z_0_z = ge_ln457_unr0_Z_0_tag_0 | 
      memread_shift_ln460_unr0_0_z[30];
      or_and_0_ln460_unr30_Z_0_z = ge_ln457_unr30_q | 
      memread_shift_ln460_unr0_0_z[0];
      and_0_ln460_unr0_z = memread_shift_ln460_unr0_0_z[30] & !
      ge_ln457_unr0_Z_0_tag_0;
      if (eq_ln445_unr25_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:832];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_q[863:832]};
      and_1_ln523_unr11_0_z = !memread_pop_ln523_unr0_0_9_q[2] & !
      eq_ln445_unr10_Z_0_tag_0 & and_1_ln523_unr10_0_z;
      and_0_ln521_unr11_z = or_and_0_ln521_Z_0_unr11_q & and_1_ln523_unr10_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln379_z: merge_start_d = 1'b1;
        ctrlAnd_1_ln382_z: merge_start_d = 1'b0;
        merge_start_hold: merge_start_d = merge_start;
        default: merge_start_d = 1'bX;
      endcase
      case (1'b1)
        eq_ln445_unr0_z: case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z = 
          3'h1;
        eq_ln445_unr1_z: case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z = 
          3'h2;
        default: case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z = 3'h4;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: eq_ln445_unr0_Z_0_tag_d_0 = {eq_ln485_unr0_z, 
          eq_ln445_unr30_z, eq_ln445_unr29_z, eq_ln445_unr28_z, eq_ln445_unr27_z, 
          eq_ln445_unr26_z, eq_ln445_unr25_z, eq_ln445_unr24_z, eq_ln445_unr23_z, 
          eq_ln445_unr22_z, eq_ln445_unr21_z, eq_ln445_unr20_z, eq_ln445_unr19_z, 
          eq_ln445_unr18_z, eq_ln445_unr17_z, eq_ln445_unr16_z, eq_ln445_unr15_z, 
          eq_ln445_unr14_z, eq_ln445_unr13_z, eq_ln445_unr12_z, eq_ln445_unr11_z, 
          eq_ln445_unr10_z, eq_ln445_unr9_z, eq_ln445_unr8_z, eq_ln445_unr7_z, 
          eq_ln445_unr6_z, eq_ln445_unr5_z, eq_ln445_unr4_z, eq_ln445_unr3_z, 
          eq_ln445_unr2_z, eq_ln445_unr1_z, eq_ln445_unr0_z};
        state_sort_unisim_sort_merge_sort[8]: eq_ln445_unr0_Z_0_tag_d_0 = {
          eq_ln485_unr0_Z_0_tag_0, eq_ln445_unr30_Z_0_tag_0, 
          eq_ln445_unr29_Z_0_tag_0, eq_ln445_unr28_Z_0_tag_0, 
          eq_ln445_unr27_Z_0_tag_0, eq_ln445_unr26_Z_0_tag_0, 
          eq_ln445_unr25_Z_0_tag_0, eq_ln445_unr24_Z_0_tag_0, 
          eq_ln445_unr23_Z_0_tag_0, eq_ln445_unr22_Z_0_tag_0, 
          eq_ln445_unr21_Z_0_tag_0, eq_ln445_unr20_Z_0_tag_0, 
          eq_ln445_unr19_Z_0_tag_0, eq_ln445_unr18_Z_0_tag_0, 
          eq_ln445_unr17_Z_0_tag_0, eq_ln445_unr16_Z_0_tag_0, 
          eq_ln445_unr15_Z_0_tag_0, eq_ln445_unr14_Z_0_tag_0, 
          eq_ln445_unr13_Z_0_tag_0, eq_ln445_unr12_Z_0_tag_0, 
          eq_ln445_unr11_Z_0_tag_0, eq_ln445_unr10_Z_0_tag_0, 
          eq_ln445_unr9_Z_0_tag_0, eq_ln445_unr8_Z_0_tag_0, 
          eq_ln445_unr7_Z_0_tag_0, eq_ln445_unr6_Z_0_tag_0, 
          eq_ln445_unr5_Z_0_tag_0, eq_ln445_unr4_Z_0_tag_0, 
          eq_ln445_unr3_Z_0_tag_0, eq_ln445_unr2_Z_0_tag_0, 
          eq_ln445_unr1_Z_0_tag_0, eq_ln445_unr0_Z_0_tag_0};
        default: eq_ln445_unr0_Z_0_tag_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: eq_ln507_Z_0_tag_d = eq_ln507_z;
        eq_ln507_Z_0_tag_sel: eq_ln507_Z_0_tag_d = eq_ln507_Z_0_tag_0;
        default: eq_ln507_Z_0_tag_d = 1'bX;
      endcase
      case (1'b1)
        !ge_ln457_unr0_z: case_mux_shift_ln456_z = 3'h1;
        eq_ln445_unr0_z: case_mux_shift_ln456_z = 3'h2;
        default: case_mux_shift_ln456_z = 3'h4;
      endcase
      if_ln457_unr10_z = ~ge_ln457_unr10_z;
      if_ln457_unr21_z = ~ge_ln457_unr21_z;
      if_ln457_unr6_z = ~ge_ln457_unr6_z;
      if_ln457_unr19_z = ~ge_ln457_unr19_z;
      if_ln457_unr2_z = ~ge_ln457_unr2_z;
      if_ln457_unr17_z = ~ge_ln457_unr17_z;
      if_ln457_unr15_z = ~ge_ln457_unr15_z;
      if_ln457_unr13_z = ~ge_ln457_unr13_z;
      if_ln457_unr11_z = ~ge_ln457_unr11_z;
      if_ln457_unr9_z = ~ge_ln457_unr9_z;
      if_ln457_unr7_z = ~ge_ln457_unr7_z;
      if_ln457_unr5_z = ~ge_ln457_unr5_z;
      if_ln457_unr3_z = ~ge_ln457_unr3_z;
      if_ln457_unr8_z = ~ge_ln457_unr8_z;
      if_ln457_unr20_z = ~ge_ln457_unr20_z;
      if_ln457_unr26_z = ~ge_ln457_unr26_z;
      if_ln457_unr29_z = ~ge_ln457_unr29_z;
      if_ln457_unr1_z = ~ge_ln457_unr1_z;
      if_ln457_unr12_z = ~ge_ln457_unr12_z;
      if_ln457_unr22_z = ~ge_ln457_unr22_z;
      if_ln457_unr27_z = ~ge_ln457_unr27_z;
      if_ln457_unr4_z = ~ge_ln457_unr4_z;
      if_ln457_unr18_z = ~ge_ln457_unr18_z;
      if_ln457_unr25_z = ~ge_ln457_unr25_z;
      if_ln457_unr14_z = ~ge_ln457_unr14_z;
      if_ln457_unr23_z = ~ge_ln457_unr23_z;
      
      mux_shift_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
      !eq_ln445_unr29_z & sort_unisim_lt_float_ln447_unr29_z & !eq_ln445_unr28_z;
      
      memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr29_0_0_0_0_0_0_0_0_0_0_0_0_0__0_z = 
      !eq_ln445_unr30_z & sort_unisim_lt_float_ln447_unr30_z;
      if (state_sort_unisim_sort_merge_sort[3]) 
        mux_add_ln598_Z_1_v_0 = add_ln598_1_q;
      else 
        mux_add_ln598_Z_1_v_0 = add_ln598_z[31:1];
      or_and_0_ln571_Z_0_z = mux_chunk_4_ln570_z[5] | eq_ln571_z;
      if_ln571_z = ~eq_ln571_z;
      or_and_0_ln407_Z_0_z = mux_chunk_ln406_z[5] | eq_ln407_z;
      if_ln407_z = ~eq_ln407_z;
      add_ln414_z = memread_fidx_ln414_z + 32'h1;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln574_z: mux_i_1_ln574_d = {add_ln574_z[5:1], mux_i_1_ln574_z};
        state_sort_unisim_sort_merge_sort[18]: mux_i_1_ln574_d = {add_ln574_1_q, 
          mux_i_1_ln574_q};
        default: mux_i_1_ln574_d = 10'hX;
      endcase
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_192_v_0 = mux_head_ln387_q[255:192];
      else 
        mux_mux_head_ln387_Z_192_v_0 = mux_head_ln387_z[255:192];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_256_v_0 = mux_head_ln387_q[319:256];
      else 
        mux_mux_head_ln387_Z_256_v_0 = mux_head_ln387_z[319:256];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_320_v_0 = mux_head_ln387_q[383:320];
      else 
        mux_mux_head_ln387_Z_320_v_0 = mux_head_ln387_z[383:320];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_384_v_0 = mux_head_ln387_q[447:384];
      else 
        mux_mux_head_ln387_Z_384_v_0 = mux_head_ln387_z[447:384];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_448_v_0 = mux_head_ln387_q[511:448];
      else 
        mux_mux_head_ln387_Z_448_v_0 = mux_head_ln387_z[511:448];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_512_v_0 = mux_head_ln387_q[575:512];
      else 
        mux_mux_head_ln387_Z_512_v_0 = mux_head_ln387_z[575:512];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_576_v_0 = mux_head_ln387_q[639:576];
      else 
        mux_mux_head_ln387_Z_576_v_0 = mux_head_ln387_z[639:576];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_640_v_0 = mux_head_ln387_q[703:640];
      else 
        mux_mux_head_ln387_Z_640_v_0 = mux_head_ln387_z[703:640];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_64_v_0 = mux_head_ln387_q[127:64];
      else 
        mux_mux_head_ln387_Z_64_v_0 = mux_head_ln387_z[127:64];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_704_v_0 = mux_head_ln387_q[767:704];
      else 
        mux_mux_head_ln387_Z_704_v_0 = mux_head_ln387_z[767:704];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_768_v_0 = mux_head_ln387_q[831:768];
      else 
        mux_mux_head_ln387_Z_768_v_0 = mux_head_ln387_z[831:768];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_832_v_0 = mux_head_ln387_q[895:832];
      else 
        mux_mux_head_ln387_Z_832_v_0 = mux_head_ln387_z[895:832];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_896_v_0 = mux_head_ln387_q[959:896];
      else 
        mux_mux_head_ln387_Z_896_v_0 = mux_head_ln387_z[959:896];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_960_v_0 = mux_head_ln387_q[1023:960];
      else 
        mux_mux_head_ln387_Z_960_v_0 = mux_head_ln387_z[1023:960];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_v = mux_head_ln387_q[63:0];
      else 
        mux_mux_head_ln387_Z_v = mux_head_ln387_z[63:0];
      if (state_sort_unisim_sort_merge_sort[12]) 
        mux_mux_head_ln387_Z_128_v_0 = mux_head_ln387_q[191:128];
      else 
        mux_mux_head_ln387_Z_128_v_0 = mux_head_ln387_z[191:128];
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_192_d_0 = 
          mux_fidx_ln440_0_z[255:192];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_192_d_0 = mux_fidx_ln440_0_q[255:192];
        default: mux_fidx_ln440_0_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_256_d_0 = 
          mux_fidx_ln440_0_z[319:256];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_256_d_0 = mux_fidx_ln440_0_q[319:256];
        default: mux_fidx_ln440_0_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_320_d_0 = 
          mux_fidx_ln440_0_z[383:320];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_320_d_0 = mux_fidx_ln440_0_q[383:320];
        default: mux_fidx_ln440_0_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_384_d_0 = 
          mux_fidx_ln440_0_z[447:384];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_384_d_0 = mux_fidx_ln440_0_q[447:384];
        default: mux_fidx_ln440_0_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_448_d_0 = 
          mux_fidx_ln440_0_z[511:448];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_448_d_0 = mux_fidx_ln440_0_q[511:448];
        default: mux_fidx_ln440_0_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_512_d_0 = 
          mux_fidx_ln440_0_z[575:512];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_512_d_0 = mux_fidx_ln440_0_q[575:512];
        default: mux_fidx_ln440_0_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_576_d_0 = 
          mux_fidx_ln440_0_z[639:576];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_576_d_0 = mux_fidx_ln440_0_q[639:576];
        default: mux_fidx_ln440_0_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_640_d_0 = 
          mux_fidx_ln440_0_z[703:640];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_640_d_0 = mux_fidx_ln440_0_q[703:640];
        default: mux_fidx_ln440_0_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_64_d_0 = 
          mux_fidx_ln440_0_z[127:64];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_64_d_0 = mux_fidx_ln440_0_q[127:64];
        default: mux_fidx_ln440_0_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_704_d_0 = 
          mux_fidx_ln440_0_z[767:704];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_704_d_0 = mux_fidx_ln440_0_q[767:704];
        default: mux_fidx_ln440_0_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_768_d_0 = 
          mux_fidx_ln440_0_z[831:768];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_768_d_0 = mux_fidx_ln440_0_q[831:768];
        default: mux_fidx_ln440_0_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_832_d_0 = 
          mux_fidx_ln440_0_z[895:832];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_832_d_0 = mux_fidx_ln440_0_q[895:832];
        default: mux_fidx_ln440_0_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_896_d_0 = 
          mux_fidx_ln440_0_z[959:896];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_896_d_0 = mux_fidx_ln440_0_q[959:896];
        default: mux_fidx_ln440_0_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_960_d_0 = 
          mux_fidx_ln440_0_z[1023:960];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_960_d_0 = mux_fidx_ln440_0_q[1023:
          960];
        default: mux_fidx_ln440_0_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_d = 
          mux_fidx_ln440_0_z[63:0];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_d = mux_fidx_ln440_0_q[63:0];
        default: mux_fidx_ln440_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[10]: mux_fidx_ln440_0_128_d_0 = 
          mux_fidx_ln440_0_z[191:128];
        ctrlAnd_1_ln564_z: mux_fidx_ln440_0_128_d_0 = mux_fidx_ln440_0_q[191:128];
        default: mux_fidx_ln440_0_128_d_0 = 64'hX;
      endcase
      and_1_ln460_unr0_z = if_ln460_unr0_z & !ge_ln457_unr0_Z_0_tag_0;
      and_0_ln460_unr10_z = mux_shift_ln456_z[19] & !ge_ln457_unr10_q;
      and_0_ln460_unr11_z = mux_shift_ln456_z[18] & !ge_ln457_unr11_q;
      and_0_ln460_unr12_z = mux_shift_ln456_z[17] & !ge_ln457_unr12_q;
      and_0_ln460_unr13_z = mux_shift_ln456_z[16] & !ge_ln457_unr13_q;
      and_0_ln460_unr14_z = mux_shift_ln456_z[15] & !ge_ln457_unr14_q;
      and_0_ln460_unr15_z = mux_shift_ln456_z[14] & !ge_ln457_unr15_q;
      and_0_ln460_unr16_z = mux_shift_ln456_z[13] & !ge_ln457_unr16_q;
      and_0_ln460_unr17_z = mux_shift_ln456_z[12] & !ge_ln457_unr17_q;
      and_0_ln460_unr18_z = mux_shift_ln456_z[11] & !ge_ln457_unr18_q;
      and_0_ln460_unr19_z = mux_shift_ln456_z[10] & !ge_ln457_unr19_q;
      and_0_ln460_unr2_z = mux_shift_ln456_z[27] & !ge_ln457_unr2_q;
      and_0_ln460_unr20_z = mux_shift_ln456_z[9] & !ge_ln457_unr20_q;
      and_0_ln460_unr21_z = mux_shift_ln456_z[8] & !ge_ln457_unr21_q;
      and_0_ln460_unr22_z = mux_shift_ln456_z[7] & !ge_ln457_unr22_q;
      and_0_ln460_unr23_z = mux_shift_ln456_z[6] & !ge_ln457_unr23_q;
      and_0_ln460_unr24_z = mux_shift_ln456_z[5] & !ge_ln457_unr24_q;
      and_0_ln460_unr25_z = mux_shift_ln456_z[4] & !ge_ln457_unr25_q;
      and_0_ln460_unr26_z = mux_shift_ln456_z[3] & !ge_ln457_unr26_q;
      and_0_ln460_unr27_z = mux_shift_ln456_z[2] & !ge_ln457_unr27_q;
      and_0_ln460_unr28_z = mux_shift_ln456_z[1] & !ge_ln457_unr28_q;
      and_0_ln460_unr29_z = mux_shift_ln456_z[0] & !ge_ln457_unr29_q;
      and_0_ln460_unr3_z = mux_shift_ln456_z[26] & !ge_ln457_unr3_q;
      and_0_ln460_unr4_z = mux_shift_ln456_z[25] & !ge_ln457_unr4_q;
      and_0_ln460_unr5_z = mux_shift_ln456_z[24] & !ge_ln457_unr5_q;
      and_0_ln460_unr6_z = mux_shift_ln456_z[23] & !ge_ln457_unr6_q;
      and_0_ln460_unr7_z = mux_shift_ln456_z[22] & !ge_ln457_unr7_q;
      and_0_ln460_unr8_z = mux_shift_ln456_z[21] & !ge_ln457_unr8_q;
      and_0_ln460_unr9_z = mux_shift_ln456_z[20] & !ge_ln457_unr9_q;
      if_ln460_unr1_z = ~mux_shift_ln456_z[28];
      if_ln460_unr10_z = ~mux_shift_ln456_z[19];
      if_ln460_unr11_z = ~mux_shift_ln456_z[18];
      if_ln460_unr12_z = ~mux_shift_ln456_z[17];
      if_ln460_unr13_z = ~mux_shift_ln456_z[16];
      if_ln460_unr14_z = ~mux_shift_ln456_z[15];
      if_ln460_unr15_z = ~mux_shift_ln456_z[14];
      if_ln460_unr16_z = ~mux_shift_ln456_z[13];
      if_ln460_unr17_z = ~mux_shift_ln456_z[12];
      if_ln460_unr18_z = ~mux_shift_ln456_z[11];
      if_ln460_unr19_z = ~mux_shift_ln456_z[10];
      if_ln460_unr2_z = ~mux_shift_ln456_z[27];
      if_ln460_unr20_z = ~mux_shift_ln456_z[9];
      if_ln460_unr21_z = ~mux_shift_ln456_z[8];
      if_ln460_unr22_z = ~mux_shift_ln456_z[7];
      if_ln460_unr23_z = ~mux_shift_ln456_z[6];
      if_ln460_unr24_z = ~mux_shift_ln456_z[5];
      if_ln460_unr25_z = ~mux_shift_ln456_z[4];
      if_ln460_unr26_z = ~mux_shift_ln456_z[3];
      if_ln460_unr27_z = ~mux_shift_ln456_z[2];
      if_ln460_unr28_z = ~mux_shift_ln456_z[1];
      if_ln460_unr29_z = ~mux_shift_ln456_z[0];
      if_ln460_unr3_z = ~mux_shift_ln456_z[26];
      if_ln460_unr4_z = ~mux_shift_ln456_z[25];
      if_ln460_unr5_z = ~mux_shift_ln456_z[24];
      if_ln460_unr6_z = ~mux_shift_ln456_z[23];
      if_ln460_unr7_z = ~mux_shift_ln456_z[22];
      if_ln460_unr8_z = ~mux_shift_ln456_z[21];
      if_ln460_unr9_z = ~mux_shift_ln456_z[20];
      or_and_0_ln460_unr10_Z_0_z = ge_ln457_unr10_q | mux_shift_ln456_z[19];
      or_and_0_ln460_unr11_Z_0_z = ge_ln457_unr11_q | mux_shift_ln456_z[18];
      or_and_0_ln460_unr12_Z_0_z = ge_ln457_unr12_q | mux_shift_ln456_z[17];
      or_and_0_ln460_unr13_Z_0_z = ge_ln457_unr13_q | mux_shift_ln456_z[16];
      or_and_0_ln460_unr14_Z_0_z = ge_ln457_unr14_q | mux_shift_ln456_z[15];
      or_and_0_ln460_unr15_Z_0_z = ge_ln457_unr15_q | mux_shift_ln456_z[14];
      or_and_0_ln460_unr16_Z_0_z = ge_ln457_unr16_q | mux_shift_ln456_z[13];
      or_and_0_ln460_unr17_Z_0_z = ge_ln457_unr17_q | mux_shift_ln456_z[12];
      or_and_0_ln460_unr18_Z_0_z = ge_ln457_unr18_q | mux_shift_ln456_z[11];
      or_and_0_ln460_unr19_Z_0_z = ge_ln457_unr19_q | mux_shift_ln456_z[10];
      or_and_0_ln460_unr1_Z_0_z = ge_ln457_unr1_q | mux_shift_ln456_z[28];
      or_and_0_ln460_unr20_Z_0_z = ge_ln457_unr20_q | mux_shift_ln456_z[9];
      or_and_0_ln460_unr21_Z_0_z = ge_ln457_unr21_q | mux_shift_ln456_z[8];
      or_and_0_ln460_unr22_Z_0_z = ge_ln457_unr22_q | mux_shift_ln456_z[7];
      or_and_0_ln460_unr23_Z_0_z = ge_ln457_unr23_q | mux_shift_ln456_z[6];
      or_and_0_ln460_unr24_Z_0_z = ge_ln457_unr24_q | mux_shift_ln456_z[5];
      or_and_0_ln460_unr25_Z_0_z = ge_ln457_unr25_q | mux_shift_ln456_z[4];
      or_and_0_ln460_unr26_Z_0_z = ge_ln457_unr26_q | mux_shift_ln456_z[3];
      or_and_0_ln460_unr27_Z_0_z = ge_ln457_unr27_q | mux_shift_ln456_z[2];
      or_and_0_ln460_unr28_Z_0_z = ge_ln457_unr28_q | mux_shift_ln456_z[1];
      or_and_0_ln460_unr29_Z_0_z = ge_ln457_unr29_q | mux_shift_ln456_z[0];
      or_and_0_ln460_unr2_Z_0_z = ge_ln457_unr2_q | mux_shift_ln456_z[27];
      or_and_0_ln460_unr3_Z_0_z = ge_ln457_unr3_q | mux_shift_ln456_z[26];
      or_and_0_ln460_unr4_Z_0_z = ge_ln457_unr4_q | mux_shift_ln456_z[25];
      or_and_0_ln460_unr5_Z_0_z = ge_ln457_unr5_q | mux_shift_ln456_z[24];
      or_and_0_ln460_unr6_Z_0_z = ge_ln457_unr6_q | mux_shift_ln456_z[23];
      or_and_0_ln460_unr7_Z_0_z = ge_ln457_unr7_q | mux_shift_ln456_z[22];
      or_and_0_ln460_unr8_Z_0_z = ge_ln457_unr8_q | mux_shift_ln456_z[21];
      or_and_0_ln460_unr9_Z_0_z = ge_ln457_unr9_q | mux_shift_ln456_z[20];
      and_0_ln460_unr1_z = mux_shift_ln456_z[28] & !ge_ln457_unr1_q;
      if (eq_ln445_unr24_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:800];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_q[831:800]};
      and_1_ln523_unr12_0_z = !memread_pop_ln523_unr0_0_9_q[3] & !
      eq_ln445_unr11_Z_0_tag_0 & and_1_ln523_unr11_0_z;
      and_0_ln521_unr12_z = or_and_0_ln521_Z_0_unr12_q & and_1_ln523_unr11_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_head_ln440_992_d_0 = {
          case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z, mux_head_ln440_z[
          1023:992]};
        state_sort_unisim_sort_merge_sort[8]: mux_head_ln440_992_d_0 = {
          case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_q, mux_head_ln440_q[
          1023:992]};
        default: mux_head_ln440_992_d_0 = 35'hX;
      endcase
      if (eq_ln507_z) 
        mux_cnt_ln507_z = add_ln513_z;
      else 
        mux_cnt_ln507_z = mux_cnt_ln440_z;
      if (lt_ln558_z) 
        mux_cur_ln558_z = add_ln559_z;
      else 
        mux_cur_ln558_z = mux_cur_ln440_z;
      if (eq_ln445_unr29_z) 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        2'h0;
      else 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr29_0_0_0_0_0_0_0_0_0_0_0_0_0__0_z, 
        sort_unisim_lt_float_ln447_unr29_z};
      ctrlAnd_1_ln374_z = !eq_ln374_z & ctrlOr_ln357_z;
      ctrlAnd_0_ln374_z = eq_ln374_z & ctrlOr_ln357_z;
      ctrlAnd_0_ln571_z = or_and_0_ln571_Z_0_z & ctrlOr_ln570_0_z;
      and_1_ln571_z = if_ln571_z & lt_ln570_z;
      ctrlAnd_0_ln407_z = or_and_0_ln407_Z_0_z & ctrlOr_ln406_0_z;
      and_1_ln407_z = if_ln407_z & lt_ln406_z;
      memwrite_fidx_ln414_z = mux_fidx_ln406_z;
      case (mux_chunk_ln406_z[4:0])// synthesis parallel_case
        5'h0: memwrite_fidx_ln414_z[31:0] = add_ln414_z;
        5'h1: memwrite_fidx_ln414_z[63:32] = add_ln414_z;
        5'h2: memwrite_fidx_ln414_z[95:64] = add_ln414_z;
        5'h3: memwrite_fidx_ln414_z[127:96] = add_ln414_z;
        5'h4: memwrite_fidx_ln414_z[159:128] = add_ln414_z;
        5'h5: memwrite_fidx_ln414_z[191:160] = add_ln414_z;
        5'h6: memwrite_fidx_ln414_z[223:192] = add_ln414_z;
        5'h7: memwrite_fidx_ln414_z[255:224] = add_ln414_z;
        5'h8: memwrite_fidx_ln414_z[287:256] = add_ln414_z;
        5'h9: memwrite_fidx_ln414_z[319:288] = add_ln414_z;
        5'ha: memwrite_fidx_ln414_z[351:320] = add_ln414_z;
        5'hb: memwrite_fidx_ln414_z[383:352] = add_ln414_z;
        5'hc: memwrite_fidx_ln414_z[415:384] = add_ln414_z;
        5'hd: memwrite_fidx_ln414_z[447:416] = add_ln414_z;
        5'he: memwrite_fidx_ln414_z[479:448] = add_ln414_z;
        5'hf: memwrite_fidx_ln414_z[511:480] = add_ln414_z;
        5'h10: memwrite_fidx_ln414_z[543:512] = add_ln414_z;
        5'h11: memwrite_fidx_ln414_z[575:544] = add_ln414_z;
        5'h12: memwrite_fidx_ln414_z[607:576] = add_ln414_z;
        5'h13: memwrite_fidx_ln414_z[639:608] = add_ln414_z;
        5'h14: memwrite_fidx_ln414_z[671:640] = add_ln414_z;
        5'h15: memwrite_fidx_ln414_z[703:672] = add_ln414_z;
        5'h16: memwrite_fidx_ln414_z[735:704] = add_ln414_z;
        5'h17: memwrite_fidx_ln414_z[767:736] = add_ln414_z;
        5'h18: memwrite_fidx_ln414_z[799:768] = add_ln414_z;
        5'h19: memwrite_fidx_ln414_z[831:800] = add_ln414_z;
        5'h1a: memwrite_fidx_ln414_z[863:832] = add_ln414_z;
        5'h1b: memwrite_fidx_ln414_z[895:864] = add_ln414_z;
        5'h1c: memwrite_fidx_ln414_z[927:896] = add_ln414_z;
        5'h1d: memwrite_fidx_ln414_z[959:928] = add_ln414_z;
        5'h1e: memwrite_fidx_ln414_z[991:960] = add_ln414_z;
        5'h1f: memwrite_fidx_ln414_z[1023:992] = add_ln414_z;
        default: memwrite_fidx_ln414_z = 32'hX;
      endcase
      if (and_0_ln460_unr30_z) 
        mux_regs_in_ln456_31_z = {mux_regs_0_ln440_q[31:0], mux_head_ln440_q[31:
        0]};
      else 
        mux_regs_in_ln456_31_z = {mux_regs_in_ln440_q[31:0], mux_regs_0_ln440_q[
        31:0]};
      and_1_ln460_unr1_0_z = if_ln460_unr1_z & !ge_ln457_unr1_q & 
      or_and_0_ln460_unr0_Z_0_z;
      and_0_ln460_unr1_0_z = or_and_0_ln460_unr1_Z_0_z & 
      or_and_0_ln460_unr0_Z_0_z;
      if (and_0_ln460_unr0_z) 
        memwrite_regs_in_ln461_unr1_0_z = mux_regs_0_ln440_q[991:960];
      else 
        memwrite_regs_in_ln461_unr1_0_z = mux_regs_in_ln440_q[991:960];
      if (eq_ln445_unr23_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:768];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_q[799:768]};
      and_1_ln523_unr13_0_z = !memread_pop_ln523_unr0_0_9_q[4] & !
      eq_ln445_unr12_Z_0_tag_0 & and_1_ln523_unr12_0_z;
      and_0_ln521_unr13_z = or_and_0_ln521_Z_0_unr13_q & and_1_ln523_unr12_0_z;
      eq_ln564_z = mux_cnt_ln507_z == read_sort_len_ln352_q;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: mux_cnt_ln507_d = {mux_cur_ln558_z, mux_cnt_ln507_z};
        mux_cnt_ln507_sel: mux_cnt_ln507_d = {mux_cur_ln558_q, mux_cnt_ln507_q};
        default: mux_cnt_ln507_d = 64'hX;
      endcase
      if (eq_ln445_unr28_z) 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        3'h0;
      else 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        sort_unisim_lt_float_ln447_unr28_z};
      ctrlOr_ln379_z = ctrlAnd_0_ln379_z | ctrlAnd_1_ln374_z;
      ctrlOr_ln376_z = state_sort_unisim_sort_merge_sort[2] | ctrlAnd_0_ln374_z;
      ctrlOr_ln387_z = ctrlAnd_0_ln571_z | ctrlAnd_0_ln564_z;
      ctrlAnd_1_ln571_z = and_1_ln571_z & ctrlOr_ln570_0_z;
      memread_sort_C0_ln420_en = mux_ping_ln357_Z_0_tag_0 & ctrlAnd_0_ln407_z;
      memread_sort_C1_ln422_en = !mux_ping_ln357_Z_0_tag_0 & ctrlAnd_0_ln407_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_128_d_0 = mux_fidx_ln406_z[222:159];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_128_d_0 = 
          mux_fidx_ln406_q[191:128];
        default: mux_fidx_ln406_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_192_d_0 = mux_fidx_ln406_z[286:223];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_192_d_0 = 
          mux_fidx_ln406_q[255:192];
        default: mux_fidx_ln406_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_256_d_0 = mux_fidx_ln406_z[350:287];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_256_d_0 = 
          mux_fidx_ln406_q[319:256];
        default: mux_fidx_ln406_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_320_d_0 = mux_fidx_ln406_z[414:351];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_320_d_0 = 
          mux_fidx_ln406_q[383:320];
        default: mux_fidx_ln406_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_384_d_0 = mux_fidx_ln406_z[478:415];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_384_d_0 = 
          mux_fidx_ln406_q[447:384];
        default: mux_fidx_ln406_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_448_d_0 = mux_fidx_ln406_z[542:479];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_448_d_0 = 
          mux_fidx_ln406_q[511:448];
        default: mux_fidx_ln406_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_512_d_0 = mux_fidx_ln406_z[606:543];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_512_d_0 = 
          mux_fidx_ln406_q[575:512];
        default: mux_fidx_ln406_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_576_d_0 = mux_fidx_ln406_z[670:607];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_576_d_0 = 
          mux_fidx_ln406_q[639:576];
        default: mux_fidx_ln406_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_640_d_0 = mux_fidx_ln406_z[734:671];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_640_d_0 = 
          mux_fidx_ln406_q[703:640];
        default: mux_fidx_ln406_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_64_d_0 = mux_fidx_ln406_z[158:95];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_64_d_0 = 
          mux_fidx_ln406_q[127:64];
        default: mux_fidx_ln406_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_704_d_0 = mux_fidx_ln406_z[798:735];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_704_d_0 = 
          mux_fidx_ln406_q[767:704];
        default: mux_fidx_ln406_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_768_d_0 = mux_fidx_ln406_z[862:799];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_768_d_0 = 
          mux_fidx_ln406_q[831:768];
        default: mux_fidx_ln406_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_832_d_0 = mux_fidx_ln406_z[926:863];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_832_d_0 = 
          mux_fidx_ln406_q[895:832];
        default: mux_fidx_ln406_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_896_d_0 = mux_fidx_ln406_z[990:927];
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_896_d_0 = 
          mux_fidx_ln406_q[959:896];
        default: mux_fidx_ln406_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_960_d_0 = {add_ln423_z[31:1], 
          mux_fidx_ln406_z[1023:991]};
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_960_d_0 = {
          add_ln423_1_q, mux_fidx_ln406_q[992:960]};
        default: mux_fidx_ln406_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln407_z: mux_fidx_ln406_d = {mux_fidx_ln406_z[94:32], 
          mux_fidx_ln406_z[0]};
        state_sort_unisim_sort_merge_sort[6]: mux_fidx_ln406_d = 
          mux_fidx_ln406_q[63:0];
        default: mux_fidx_ln406_d = 64'hX;
      endcase
      ctrlAnd_1_ln407_z = and_1_ln407_z & ctrlOr_ln406_0_z;
      if (and_0_ln460_unr10_z) 
        memwrite_regs_in_ln461_unr11_0_z = mux_regs_0_ln440_q[671:640];
      else 
        memwrite_regs_in_ln461_unr11_0_z = mux_regs_in_ln440_q[671:640];
      if (and_0_ln460_unr11_z) 
        memwrite_regs_in_ln461_unr12_0_z = mux_regs_0_ln440_q[639:608];
      else 
        memwrite_regs_in_ln461_unr12_0_z = mux_regs_in_ln440_q[639:608];
      if (and_0_ln460_unr12_z) 
        memwrite_regs_in_ln461_unr13_0_z = mux_regs_0_ln440_q[607:576];
      else 
        memwrite_regs_in_ln461_unr13_0_z = mux_regs_in_ln440_q[607:576];
      if (and_0_ln460_unr13_z) 
        memwrite_regs_in_ln461_unr14_0_z = mux_regs_0_ln440_q[575:544];
      else 
        memwrite_regs_in_ln461_unr14_0_z = mux_regs_in_ln440_q[575:544];
      if (and_0_ln460_unr14_z) 
        memwrite_regs_in_ln461_unr15_0_z = mux_regs_0_ln440_q[543:512];
      else 
        memwrite_regs_in_ln461_unr15_0_z = mux_regs_in_ln440_q[543:512];
      if (and_0_ln460_unr15_z) 
        memwrite_regs_in_ln461_unr16_0_z = mux_regs_0_ln440_q[511:480];
      else 
        memwrite_regs_in_ln461_unr16_0_z = mux_regs_in_ln440_q[511:480];
      if (and_0_ln460_unr16_z) 
        memwrite_regs_in_ln461_unr17_0_z = mux_regs_0_ln440_q[479:448];
      else 
        memwrite_regs_in_ln461_unr17_0_z = mux_regs_in_ln440_q[479:448];
      if (and_0_ln460_unr17_z) 
        memwrite_regs_in_ln461_unr18_0_z = mux_regs_0_ln440_q[447:416];
      else 
        memwrite_regs_in_ln461_unr18_0_z = mux_regs_in_ln440_q[447:416];
      if (and_0_ln460_unr18_z) 
        memwrite_regs_in_ln461_unr19_0_z = mux_regs_0_ln440_q[415:384];
      else 
        memwrite_regs_in_ln461_unr19_0_z = mux_regs_in_ln440_q[415:384];
      if (and_0_ln460_unr19_z) 
        memwrite_regs_in_ln461_unr20_0_z = mux_regs_0_ln440_q[383:352];
      else 
        memwrite_regs_in_ln461_unr20_0_z = mux_regs_in_ln440_q[383:352];
      if (and_0_ln460_unr2_z) 
        memwrite_regs_in_ln461_unr3_0_z = mux_regs_0_ln440_q[927:896];
      else 
        memwrite_regs_in_ln461_unr3_0_z = mux_regs_in_ln440_q[927:896];
      if (and_0_ln460_unr20_z) 
        memwrite_regs_in_ln461_unr21_0_z = mux_regs_0_ln440_q[351:320];
      else 
        memwrite_regs_in_ln461_unr21_0_z = mux_regs_in_ln440_q[351:320];
      if (and_0_ln460_unr21_z) 
        memwrite_regs_in_ln461_unr22_0_z = mux_regs_0_ln440_q[319:288];
      else 
        memwrite_regs_in_ln461_unr22_0_z = mux_regs_in_ln440_q[319:288];
      if (and_0_ln460_unr22_z) 
        memwrite_regs_in_ln461_unr23_0_z = mux_regs_0_ln440_q[287:256];
      else 
        memwrite_regs_in_ln461_unr23_0_z = mux_regs_in_ln440_q[287:256];
      if (and_0_ln460_unr23_z) 
        memwrite_regs_in_ln461_unr24_0_z = mux_regs_0_ln440_q[255:224];
      else 
        memwrite_regs_in_ln461_unr24_0_z = mux_regs_in_ln440_q[255:224];
      if (and_0_ln460_unr24_z) 
        memwrite_regs_in_ln461_unr25_0_z = mux_regs_0_ln440_q[223:192];
      else 
        memwrite_regs_in_ln461_unr25_0_z = mux_regs_in_ln440_q[223:192];
      if (and_0_ln460_unr25_z) 
        memwrite_regs_in_ln461_unr26_0_z = mux_regs_0_ln440_q[191:160];
      else 
        memwrite_regs_in_ln461_unr26_0_z = mux_regs_in_ln440_q[191:160];
      if (and_0_ln460_unr26_z) 
        memwrite_regs_in_ln461_unr27_0_z = mux_regs_0_ln440_q[159:128];
      else 
        memwrite_regs_in_ln461_unr27_0_z = mux_regs_in_ln440_q[159:128];
      if (and_0_ln460_unr27_z) 
        memwrite_regs_in_ln461_unr28_0_z = mux_regs_0_ln440_q[127:96];
      else 
        memwrite_regs_in_ln461_unr28_0_z = mux_regs_in_ln440_q[127:96];
      if (and_0_ln460_unr28_z) 
        memwrite_regs_in_ln461_unr29_0_z = mux_regs_0_ln440_q[95:64];
      else 
        memwrite_regs_in_ln461_unr29_0_z = mux_regs_in_ln440_q[95:64];
      if (and_0_ln460_unr29_z) 
        memwrite_regs_in_ln461_unr30_0_z = mux_regs_0_ln440_q[63:32];
      else 
        memwrite_regs_in_ln461_unr30_0_z = mux_regs_in_ln440_q[63:32];
      if (and_0_ln460_unr3_z) 
        memwrite_regs_in_ln461_unr4_0_z = mux_regs_0_ln440_q[895:864];
      else 
        memwrite_regs_in_ln461_unr4_0_z = mux_regs_in_ln440_q[895:864];
      if (and_0_ln460_unr4_z) 
        memwrite_regs_in_ln461_unr5_0_z = mux_regs_0_ln440_q[863:832];
      else 
        memwrite_regs_in_ln461_unr5_0_z = mux_regs_in_ln440_q[863:832];
      if (and_0_ln460_unr5_z) 
        memwrite_regs_in_ln461_unr6_0_z = mux_regs_0_ln440_q[831:800];
      else 
        memwrite_regs_in_ln461_unr6_0_z = mux_regs_in_ln440_q[831:800];
      if (and_0_ln460_unr6_z) 
        memwrite_regs_in_ln461_unr7_0_z = mux_regs_0_ln440_q[799:768];
      else 
        memwrite_regs_in_ln461_unr7_0_z = mux_regs_in_ln440_q[799:768];
      if (and_0_ln460_unr7_z) 
        memwrite_regs_in_ln461_unr8_0_z = mux_regs_0_ln440_q[767:736];
      else 
        memwrite_regs_in_ln461_unr8_0_z = mux_regs_in_ln440_q[767:736];
      if (and_0_ln460_unr8_z) 
        memwrite_regs_in_ln461_unr9_0_z = mux_regs_0_ln440_q[735:704];
      else 
        memwrite_regs_in_ln461_unr9_0_z = mux_regs_in_ln440_q[735:704];
      if (and_0_ln460_unr9_z) 
        memwrite_regs_in_ln461_unr10_0_z = mux_regs_0_ln440_q[703:672];
      else 
        memwrite_regs_in_ln461_unr10_0_z = mux_regs_in_ln440_q[703:672];
      and_1_ln460_unr2_0_z = if_ln460_unr2_z & !ge_ln457_unr2_q & 
      and_0_ln460_unr1_0_z;
      and_0_ln460_unr2_0_z = or_and_0_ln460_unr2_Z_0_z & and_0_ln460_unr1_0_z;
      if (and_0_ln460_unr1_z) 
        memwrite_regs_in_ln461_unr2_0_z = mux_regs_0_ln440_q[959:928];
      else 
        memwrite_regs_in_ln461_unr2_0_z = mux_regs_in_ln440_q[959:928];
      if (eq_ln445_unr22_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:736];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_q[767:736]};
      and_1_ln523_unr14_0_z = !memread_pop_ln523_unr0_0_9_q[5] & !
      eq_ln445_unr13_Z_0_tag_0 & and_1_ln523_unr13_0_z;
      and_0_ln521_unr14_z = or_and_0_ln521_Z_0_unr14_q & and_1_ln523_unr13_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln440_z: eq_ln564_d = eq_ln564_z;
        eq_ln564_sel: eq_ln564_d = eq_ln564_q;
        default: eq_ln564_d = 1'bX;
      endcase
      case (mux_cur_ln440_z)
        32'h1c: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            2'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            4'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr27_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr27_z};
          end
      endcase
      merge_done_hold = ~(ctrlOr_ln387_z | ctrlAnd_1_ln592_z);
      ctrlOr_ln592_z = ctrlAnd_0_ln592_z | ctrlOr_ln387_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln571_z: mux_chunk_4_ln570_d = {add_ln570_z[5:1], 
          mux_chunk_4_ln570_z[4:0]};
        mux_chunk_4_ln570_sel: mux_chunk_4_ln570_d = {add_ln570_1_q, 
          mux_chunk_4_ln570_q};
        default: mux_chunk_4_ln570_d = 10'hX;
      endcase
      mux_head_ln357_sel = state_sort_unisim_sort_merge_sort[18] | 
      ctrlOr_ln574_z | ctrlOr_ln382_z | ctrlAnd_1_ln571_z | ctrlAnd_1_ln387_z | 
      ctrlAnd_0_ln387_z;
      memread_sort_C0_ln410_en = mux_ping_ln357_Z_0_tag_0 & ctrlAnd_1_ln407_z;
      memread_sort_C1_ln412_en = !mux_ping_ln357_Z_0_tag_0 & ctrlAnd_1_ln407_z;
      mux_head_ln406_sel = ctrlAnd_1_ln407_z | ctrlAnd_0_ln407_z;
      mux_regs_in_ln357_sel = state_sort_unisim_sort_merge_sort[18] | 
      ctrlOr_ln574_z | ctrlOr_ln382_z | ctrlAnd_1_ln571_z | ctrlAnd_1_ln407_z | 
      ctrlAnd_1_ln387_z | ctrlAnd_0_ln407_z | ctrlAnd_0_ln387_z | 
      state_sort_unisim_sort_merge_sort[6];
      and_1_ln460_unr3_0_z = if_ln460_unr3_z & !ge_ln457_unr3_q & 
      and_0_ln460_unr2_0_z;
      and_0_ln460_unr3_0_z = or_and_0_ln460_unr3_Z_0_z & and_0_ln460_unr2_0_z;
      if (eq_ln445_unr21_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:704];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_q[735:704]};
      and_1_ln523_unr15_0_z = !memread_pop_ln523_unr0_0_9_q[6] & !
      eq_ln445_unr14_Z_0_tag_0 & and_1_ln523_unr14_0_z;
      and_0_ln521_unr15_z = or_and_0_ln521_Z_0_unr15_q & and_1_ln523_unr14_0_z;
      case (mux_cur_ln440_z)
        32'h1b: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            3'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            5'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr26_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr26_z};
          end
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln387_z: merge_done_d = 1'b1;
        ctrlAnd_1_ln592_z: merge_done_d = 1'b0;
        merge_done_hold: merge_done_d = merge_done;
        default: merge_done_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_128_d_0 = mux_mux_head_ln387_Z_128_v_0;
        ctrlOr_ln595_z: mux_head_ln387_128_d_0 = mux_head_ln387_q[191:128];
        default: mux_head_ln387_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_192_d_0 = mux_mux_head_ln387_Z_192_v_0;
        ctrlOr_ln595_z: mux_head_ln387_192_d_0 = mux_head_ln387_q[255:192];
        default: mux_head_ln387_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_256_d_0 = mux_mux_head_ln387_Z_256_v_0;
        ctrlOr_ln595_z: mux_head_ln387_256_d_0 = mux_head_ln387_q[319:256];
        default: mux_head_ln387_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_320_d_0 = mux_mux_head_ln387_Z_320_v_0;
        ctrlOr_ln595_z: mux_head_ln387_320_d_0 = mux_head_ln387_q[383:320];
        default: mux_head_ln387_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_384_d_0 = mux_mux_head_ln387_Z_384_v_0;
        ctrlOr_ln595_z: mux_head_ln387_384_d_0 = mux_head_ln387_q[447:384];
        default: mux_head_ln387_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_448_d_0 = mux_mux_head_ln387_Z_448_v_0;
        ctrlOr_ln595_z: mux_head_ln387_448_d_0 = mux_head_ln387_q[511:448];
        default: mux_head_ln387_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_512_d_0 = mux_mux_head_ln387_Z_512_v_0;
        ctrlOr_ln595_z: mux_head_ln387_512_d_0 = mux_head_ln387_q[575:512];
        default: mux_head_ln387_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_576_d_0 = mux_mux_head_ln387_Z_576_v_0;
        ctrlOr_ln595_z: mux_head_ln387_576_d_0 = mux_head_ln387_q[639:576];
        default: mux_head_ln387_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_640_d_0 = mux_mux_head_ln387_Z_640_v_0;
        ctrlOr_ln595_z: mux_head_ln387_640_d_0 = mux_head_ln387_q[703:640];
        default: mux_head_ln387_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_64_d_0 = mux_mux_head_ln387_Z_64_v_0;
        ctrlOr_ln595_z: mux_head_ln387_64_d_0 = mux_head_ln387_q[127:64];
        default: mux_head_ln387_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_704_d_0 = mux_mux_head_ln387_Z_704_v_0;
        ctrlOr_ln595_z: mux_head_ln387_704_d_0 = mux_head_ln387_q[767:704];
        default: mux_head_ln387_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_768_d_0 = mux_mux_head_ln387_Z_768_v_0;
        ctrlOr_ln595_z: mux_head_ln387_768_d_0 = mux_head_ln387_q[831:768];
        default: mux_head_ln387_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_832_d_0 = mux_mux_head_ln387_Z_832_v_0;
        ctrlOr_ln595_z: mux_head_ln387_832_d_0 = mux_head_ln387_q[895:832];
        default: mux_head_ln387_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_896_d_0 = mux_mux_head_ln387_Z_896_v_0;
        ctrlOr_ln595_z: mux_head_ln387_896_d_0 = mux_head_ln387_q[959:896];
        default: mux_head_ln387_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_960_d_0 = mux_mux_head_ln387_Z_960_v_0;
        ctrlOr_ln595_z: mux_head_ln387_960_d_0 = mux_head_ln387_q[1023:960];
        default: mux_head_ln387_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_head_ln387_d = mux_mux_head_ln387_Z_v;
        ctrlOr_ln595_z: mux_head_ln387_d = mux_head_ln387_q[63:0];
        default: mux_head_ln387_d = 64'hX;
      endcase
      mux_ping_ln357_Z_0_tag_sel = state_sort_unisim_sort_merge_sort[18] | 
      state_sort_unisim_sort_merge_sort[9] | 
      state_sort_unisim_sort_merge_sort[10] | 
      state_sort_unisim_sort_merge_sort[8] | ctrlOr_ln595_z | ctrlOr_ln592_z | 
      ctrlOr_ln574_z | ctrlOr_ln440_z | ctrlOr_ln382_z | ctrlAnd_1_ln571_z | 
      ctrlAnd_1_ln564_z | ctrlAnd_1_ln407_z | ctrlAnd_1_ln387_z | 
      ctrlAnd_0_ln407_z | ctrlAnd_0_ln387_z | 
      state_sort_unisim_sort_merge_sort[6];
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_160_d_0 = {
          mux_mux_regs_0_ln387_Z_192_v_0[31:0], mux_mux_regs_0_ln387_Z_128_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_160_d_0 = mux_regs_0_ln387_q[223:160];
        default: mux_regs_0_ln387_160_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_224_d_0 = {
          mux_mux_regs_0_ln387_Z_256_v_0[31:0], mux_mux_regs_0_ln387_Z_192_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_224_d_0 = mux_regs_0_ln387_q[287:224];
        default: mux_regs_0_ln387_224_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_288_d_0 = {
          mux_mux_regs_0_ln387_Z_320_v_0[31:0], mux_mux_regs_0_ln387_Z_256_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_288_d_0 = mux_regs_0_ln387_q[351:288];
        default: mux_regs_0_ln387_288_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_32_d_0 = {mux_mux_regs_0_ln387_Z_64_v_0
          [31:0], mux_mux_regs_0_ln387_Z_v[63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_32_d_0 = mux_regs_0_ln387_q[95:32];
        default: mux_regs_0_ln387_32_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_352_d_0 = {
          mux_mux_regs_0_ln387_Z_384_v_0[31:0], mux_mux_regs_0_ln387_Z_320_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_352_d_0 = mux_regs_0_ln387_q[415:352];
        default: mux_regs_0_ln387_352_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_416_d_0 = {
          mux_mux_regs_0_ln387_Z_448_v_0[31:0], mux_mux_regs_0_ln387_Z_384_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_416_d_0 = mux_regs_0_ln387_q[479:416];
        default: mux_regs_0_ln387_416_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_480_d_0 = {
          mux_mux_regs_0_ln387_Z_512_v_0[31:0], mux_mux_regs_0_ln387_Z_448_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_480_d_0 = mux_regs_0_ln387_q[543:480];
        default: mux_regs_0_ln387_480_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_544_d_0 = {
          mux_mux_regs_0_ln387_Z_576_v_0[31:0], mux_mux_regs_0_ln387_Z_512_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_544_d_0 = mux_regs_0_ln387_q[607:544];
        default: mux_regs_0_ln387_544_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_608_d_0 = {
          mux_mux_regs_0_ln387_Z_640_v_0[31:0], mux_mux_regs_0_ln387_Z_576_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_608_d_0 = mux_regs_0_ln387_q[671:608];
        default: mux_regs_0_ln387_608_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_672_d_0 = {
          mux_mux_regs_0_ln387_Z_704_v_0[31:0], mux_mux_regs_0_ln387_Z_640_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_672_d_0 = mux_regs_0_ln387_q[735:672];
        default: mux_regs_0_ln387_672_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_736_d_0 = {
          mux_mux_regs_0_ln387_Z_768_v_0[31:0], mux_mux_regs_0_ln387_Z_704_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_736_d_0 = mux_regs_0_ln387_q[799:736];
        default: mux_regs_0_ln387_736_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_800_d_0 = {
          mux_mux_regs_0_ln387_Z_832_v_0[31:0], mux_mux_regs_0_ln387_Z_768_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_800_d_0 = mux_regs_0_ln387_q[863:800];
        default: mux_regs_0_ln387_800_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_864_d_0 = {
          mux_mux_regs_0_ln387_Z_896_v_0[31:0], mux_mux_regs_0_ln387_Z_832_v_0[
          63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_864_d_0 = mux_regs_0_ln387_q[927:864];
        default: mux_regs_0_ln387_864_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_928_d_0 = {
          mux_mux_regs_0_ln387_Z_960_v_0, mux_mux_regs_0_ln387_Z_896_v_0[63:32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_928_d_0 = mux_regs_0_ln387_q[991:928];
        default: mux_regs_0_ln387_928_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_0_ln387_96_d_0 = {
          mux_mux_regs_0_ln387_Z_128_v_0[31:0], mux_mux_regs_0_ln387_Z_64_v_0[63:
          32]};
        ctrlOr_ln595_z: mux_regs_0_ln387_96_d_0 = mux_regs_0_ln387_q[159:96];
        default: mux_regs_0_ln387_96_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_128_d_0 = 
          mux_mux_regs_in_ln387_Z_128_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_128_d_0 = mux_regs_in_ln387_q[191:128];
        default: mux_regs_in_ln387_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_192_d_0 = 
          mux_mux_regs_in_ln387_Z_192_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_192_d_0 = mux_regs_in_ln387_q[255:192];
        default: mux_regs_in_ln387_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_256_d_0 = 
          mux_mux_regs_in_ln387_Z_256_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_256_d_0 = mux_regs_in_ln387_q[319:256];
        default: mux_regs_in_ln387_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_320_d_0 = 
          mux_mux_regs_in_ln387_Z_320_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_320_d_0 = mux_regs_in_ln387_q[383:320];
        default: mux_regs_in_ln387_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_384_d_0 = 
          mux_mux_regs_in_ln387_Z_384_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_384_d_0 = mux_regs_in_ln387_q[447:384];
        default: mux_regs_in_ln387_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_448_d_0 = 
          mux_mux_regs_in_ln387_Z_448_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_448_d_0 = mux_regs_in_ln387_q[511:448];
        default: mux_regs_in_ln387_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_512_d_0 = 
          mux_mux_regs_in_ln387_Z_512_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_512_d_0 = mux_regs_in_ln387_q[575:512];
        default: mux_regs_in_ln387_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_576_d_0 = 
          mux_mux_regs_in_ln387_Z_576_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_576_d_0 = mux_regs_in_ln387_q[639:576];
        default: mux_regs_in_ln387_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_640_d_0 = 
          mux_mux_regs_in_ln387_Z_640_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_640_d_0 = mux_regs_in_ln387_q[703:640];
        default: mux_regs_in_ln387_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_64_d_0 = 
          mux_mux_regs_in_ln387_Z_64_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_64_d_0 = mux_regs_in_ln387_q[127:64];
        default: mux_regs_in_ln387_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_704_d_0 = 
          mux_mux_regs_in_ln387_Z_704_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_704_d_0 = mux_regs_in_ln387_q[767:704];
        default: mux_regs_in_ln387_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_768_d_0 = 
          mux_mux_regs_in_ln387_Z_768_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_768_d_0 = mux_regs_in_ln387_q[831:768];
        default: mux_regs_in_ln387_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_832_d_0 = 
          mux_mux_regs_in_ln387_Z_832_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_832_d_0 = mux_regs_in_ln387_q[895:832];
        default: mux_regs_in_ln387_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_896_d_0 = 
          mux_mux_regs_in_ln387_Z_896_v_0;
        ctrlOr_ln595_z: mux_regs_in_ln387_896_d_0 = mux_regs_in_ln387_q[959:896];
        default: mux_regs_in_ln387_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_960_d_0 = {mux_mux_regs_0_ln387_Z_v[31:
          0], mux_mux_regs_in_ln387_Z_960_v_0};
        ctrlOr_ln595_z: mux_regs_in_ln387_960_d_0 = {mux_regs_0_ln387_q[31:0], 
          mux_regs_in_ln387_q[991:960]};
        default: mux_regs_in_ln387_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln592_z: mux_regs_in_ln387_d = mux_mux_regs_in_ln387_Z_v;
        ctrlOr_ln595_z: mux_regs_in_ln387_d = mux_regs_in_ln387_q[63:0];
        default: mux_regs_in_ln387_d = 64'hX;
      endcase
      read_sort_len_ln352_sel = state_sort_unisim_sort_merge_sort[18] | 
      state_sort_unisim_sort_merge_sort[9] | 
      state_sort_unisim_sort_merge_sort[10] | 
      state_sort_unisim_sort_merge_sort[8] | ctrlOr_ln595_z | ctrlOr_ln592_z | 
      ctrlOr_ln574_z | ctrlOr_ln440_z | ctrlOr_ln382_z | ctrlOr_ln379_z | 
      ctrlAnd_1_ln571_z | ctrlAnd_1_ln564_z | ctrlAnd_1_ln407_z | 
      ctrlAnd_1_ln387_z | ctrlAnd_0_ln407_z | ctrlAnd_0_ln387_z | 
      state_sort_unisim_sort_merge_sort[6];
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_192_d_0 = mux_mux_head_ln357_Z_192_v_0;
        mux_head_ln357_sel: mux_head_ln357_192_d_0 = mux_head_ln357_q[255:192];
        default: mux_head_ln357_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_256_d_0 = mux_mux_head_ln357_Z_256_v_0;
        mux_head_ln357_sel: mux_head_ln357_256_d_0 = mux_head_ln357_q[319:256];
        default: mux_head_ln357_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_320_d_0 = mux_mux_head_ln357_Z_320_v_0;
        mux_head_ln357_sel: mux_head_ln357_320_d_0 = mux_head_ln357_q[383:320];
        default: mux_head_ln357_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_384_d_0 = mux_mux_head_ln357_Z_384_v_0;
        mux_head_ln357_sel: mux_head_ln357_384_d_0 = mux_head_ln357_q[447:384];
        default: mux_head_ln357_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_448_d_0 = mux_mux_head_ln357_Z_448_v_0;
        mux_head_ln357_sel: mux_head_ln357_448_d_0 = mux_head_ln357_q[511:448];
        default: mux_head_ln357_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_512_d_0 = mux_mux_head_ln357_Z_512_v_0;
        mux_head_ln357_sel: mux_head_ln357_512_d_0 = mux_head_ln357_q[575:512];
        default: mux_head_ln357_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_576_d_0 = mux_mux_head_ln357_Z_576_v_0;
        mux_head_ln357_sel: mux_head_ln357_576_d_0 = mux_head_ln357_q[639:576];
        default: mux_head_ln357_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_640_d_0 = mux_mux_head_ln357_Z_640_v_0;
        mux_head_ln357_sel: mux_head_ln357_640_d_0 = mux_head_ln357_q[703:640];
        default: mux_head_ln357_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_64_d_0 = mux_mux_head_ln357_Z_64_v_0;
        mux_head_ln357_sel: mux_head_ln357_64_d_0 = mux_head_ln357_q[127:64];
        default: mux_head_ln357_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_704_d_0 = mux_mux_head_ln357_Z_704_v_0;
        mux_head_ln357_sel: mux_head_ln357_704_d_0 = mux_head_ln357_q[767:704];
        default: mux_head_ln357_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_768_d_0 = mux_mux_head_ln357_Z_768_v_0;
        mux_head_ln357_sel: mux_head_ln357_768_d_0 = mux_head_ln357_q[831:768];
        default: mux_head_ln357_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_832_d_0 = mux_mux_head_ln357_Z_832_v_0;
        mux_head_ln357_sel: mux_head_ln357_832_d_0 = mux_head_ln357_q[895:832];
        default: mux_head_ln357_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_896_d_0 = mux_mux_head_ln357_Z_896_v_0;
        mux_head_ln357_sel: mux_head_ln357_896_d_0 = mux_head_ln357_q[959:896];
        default: mux_head_ln357_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_960_d_0 = mux_mux_head_ln357_Z_960_v_0;
        mux_head_ln357_sel: mux_head_ln357_960_d_0 = mux_head_ln357_q[1023:960];
        default: mux_head_ln357_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_d = mux_mux_head_ln357_Z_v;
        mux_head_ln357_sel: mux_head_ln357_d = mux_head_ln357_q[63:0];
        default: mux_head_ln357_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_head_ln357_128_d_0 = mux_mux_head_ln357_Z_128_v_0;
        mux_head_ln357_sel: mux_head_ln357_128_d_0 = mux_head_ln357_q[191:128];
        default: mux_head_ln357_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        memread_sort_C0_ln410_en: C0_bridge1_rtl_a = {mux_chunk_ln406_z[4:0], 
          5'h0};
        memread_sort_C0_ln420_en: C0_bridge1_rtl_a = 10'h1;
        for_ln574_or_0: C0_bridge1_rtl_a = {mux_chunk_4_ln570_q, mux_i_1_ln574_z};
        state_sort_unisim_sort_merge_sort[10]: C0_bridge1_rtl_a = {add_ln536_z, 
          memread_fidx_ln536_z[4:0]};
        default: C0_bridge1_rtl_a = 10'hX;
      endcase
      C0_bridge1_rtl_CE_en = memread_sort_C0_ln578_en | memread_sort_C0_ln536_en | 
      memread_sort_C0_ln420_en | memread_sort_C0_ln410_en;
      case (1'b1)// synthesis parallel_case
        memread_sort_C1_ln412_en: C1_bridge1_rtl_a = {mux_chunk_ln406_z[4:0], 
          5'h0};
        memread_sort_C1_ln422_en: C1_bridge1_rtl_a = 10'h1;
        for_ln574_or_0: C1_bridge1_rtl_a = {mux_chunk_4_ln570_q, mux_i_1_ln574_z};
        state_sort_unisim_sort_merge_sort[10]: C1_bridge1_rtl_a = {add_ln536_z, 
          memread_fidx_ln536_z[4:0]};
        default: C1_bridge1_rtl_a = 10'hX;
      endcase
      C1_bridge1_rtl_CE_en = memread_sort_C1_ln580_en | memread_sort_C1_ln538_en | 
      memread_sort_C1_ln422_en | memread_sort_C1_ln412_en;
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_192_d_0 = mux_head_ln406_z[255:192];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_192_d_0 = 
          mux_head_ln406_q[255:192];
        default: mux_head_ln406_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_256_d_0 = mux_head_ln406_z[319:256];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_256_d_0 = 
          mux_head_ln406_q[319:256];
        default: mux_head_ln406_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_320_d_0 = mux_head_ln406_z[383:320];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_320_d_0 = 
          mux_head_ln406_q[383:320];
        default: mux_head_ln406_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_384_d_0 = mux_head_ln406_z[447:384];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_384_d_0 = 
          mux_head_ln406_q[447:384];
        default: mux_head_ln406_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_448_d_0 = mux_head_ln406_z[511:448];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_448_d_0 = 
          mux_head_ln406_q[511:448];
        default: mux_head_ln406_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_512_d_0 = mux_head_ln406_z[575:512];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_512_d_0 = 
          mux_head_ln406_q[575:512];
        default: mux_head_ln406_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_576_d_0 = mux_head_ln406_z[639:576];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_576_d_0 = 
          mux_head_ln406_q[639:576];
        default: mux_head_ln406_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_640_d_0 = mux_head_ln406_z[703:640];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_640_d_0 = 
          mux_head_ln406_q[703:640];
        default: mux_head_ln406_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_64_d_0 = mux_head_ln406_z[127:64];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_64_d_0 = 
          mux_head_ln406_q[127:64];
        default: mux_head_ln406_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_704_d_0 = mux_head_ln406_z[767:704];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_704_d_0 = 
          mux_head_ln406_q[767:704];
        default: mux_head_ln406_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_768_d_0 = mux_head_ln406_z[831:768];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_768_d_0 = 
          mux_head_ln406_q[831:768];
        default: mux_head_ln406_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_832_d_0 = mux_head_ln406_z[895:832];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_832_d_0 = 
          mux_head_ln406_q[895:832];
        default: mux_head_ln406_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_896_d_0 = mux_head_ln406_z[959:896];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_896_d_0 = 
          mux_head_ln406_q[959:896];
        default: mux_head_ln406_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_960_d_0 = mux_head_ln406_z[1023:960];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_960_d_0 = 
          mux_head_ln406_q[1023:960];
        default: mux_head_ln406_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_d = mux_head_ln406_z[63:0];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_d = 
          mux_head_ln406_q[63:0];
        default: mux_head_ln406_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_head_ln406_sel: mux_head_ln406_128_d_0 = mux_head_ln406_z[191:128];
        state_sort_unisim_sort_merge_sort[6]: mux_head_ln406_128_d_0 = 
          mux_head_ln406_q[191:128];
        default: mux_head_ln406_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_224_d_0 = {
          mux_mux_regs_0_ln357_Z_256_v_0[31:0], mux_mux_regs_0_ln357_Z_192_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_224_d_0 = mux_regs_0_ln357_q[287:
          224];
        default: mux_regs_0_ln357_224_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_288_d_0 = {
          mux_mux_regs_0_ln357_Z_320_v_0[31:0], mux_mux_regs_0_ln357_Z_256_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_288_d_0 = mux_regs_0_ln357_q[351:
          288];
        default: mux_regs_0_ln357_288_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_32_d_0 = {mux_mux_regs_0_ln357_Z_64_v_0
          [31:0], mux_mux_regs_0_ln357_Z_v[63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_32_d_0 = mux_regs_0_ln357_q[95:
          32];
        default: mux_regs_0_ln357_32_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_352_d_0 = {
          mux_mux_regs_0_ln357_Z_384_v_0[31:0], mux_mux_regs_0_ln357_Z_320_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_352_d_0 = mux_regs_0_ln357_q[415:
          352];
        default: mux_regs_0_ln357_352_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_416_d_0 = {
          mux_mux_regs_0_ln357_Z_448_v_0[31:0], mux_mux_regs_0_ln357_Z_384_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_416_d_0 = mux_regs_0_ln357_q[479:
          416];
        default: mux_regs_0_ln357_416_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_480_d_0 = {
          mux_mux_regs_0_ln357_Z_512_v_0[31:0], mux_mux_regs_0_ln357_Z_448_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_480_d_0 = mux_regs_0_ln357_q[543:
          480];
        default: mux_regs_0_ln357_480_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_544_d_0 = {
          mux_mux_regs_0_ln357_Z_576_v_0[31:0], mux_mux_regs_0_ln357_Z_512_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_544_d_0 = mux_regs_0_ln357_q[607:
          544];
        default: mux_regs_0_ln357_544_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_608_d_0 = {
          mux_mux_regs_0_ln357_Z_640_v_0[31:0], mux_mux_regs_0_ln357_Z_576_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_608_d_0 = mux_regs_0_ln357_q[671:
          608];
        default: mux_regs_0_ln357_608_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_672_d_0 = {
          mux_mux_regs_0_ln357_Z_704_v_0[31:0], mux_mux_regs_0_ln357_Z_640_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_672_d_0 = mux_regs_0_ln357_q[735:
          672];
        default: mux_regs_0_ln357_672_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_736_d_0 = {
          mux_mux_regs_0_ln357_Z_768_v_0[31:0], mux_mux_regs_0_ln357_Z_704_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_736_d_0 = mux_regs_0_ln357_q[799:
          736];
        default: mux_regs_0_ln357_736_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_800_d_0 = {
          mux_mux_regs_0_ln357_Z_832_v_0[31:0], mux_mux_regs_0_ln357_Z_768_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_800_d_0 = mux_regs_0_ln357_q[863:
          800];
        default: mux_regs_0_ln357_800_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_864_d_0 = {
          mux_mux_regs_0_ln357_Z_896_v_0[31:0], mux_mux_regs_0_ln357_Z_832_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_864_d_0 = mux_regs_0_ln357_q[927:
          864];
        default: mux_regs_0_ln357_864_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_928_d_0 = {
          mux_mux_regs_0_ln357_Z_960_v_0, mux_mux_regs_0_ln357_Z_896_v_0[63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_928_d_0 = mux_regs_0_ln357_q[991:
          928];
        default: mux_regs_0_ln357_928_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_96_d_0 = {
          mux_mux_regs_0_ln357_Z_128_v_0[31:0], mux_mux_regs_0_ln357_Z_64_v_0[63:
          32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_96_d_0 = mux_regs_0_ln357_q[159:
          96];
        default: mux_regs_0_ln357_96_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_128_d_0 = 
          mux_mux_regs_in_ln357_Z_128_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_128_d_0 = mux_regs_in_ln357_q[
          191:128];
        default: mux_regs_in_ln357_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_192_d_0 = 
          mux_mux_regs_in_ln357_Z_192_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_192_d_0 = mux_regs_in_ln357_q[
          255:192];
        default: mux_regs_in_ln357_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_256_d_0 = 
          mux_mux_regs_in_ln357_Z_256_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_256_d_0 = mux_regs_in_ln357_q[
          319:256];
        default: mux_regs_in_ln357_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_320_d_0 = 
          mux_mux_regs_in_ln357_Z_320_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_320_d_0 = mux_regs_in_ln357_q[
          383:320];
        default: mux_regs_in_ln357_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_384_d_0 = 
          mux_mux_regs_in_ln357_Z_384_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_384_d_0 = mux_regs_in_ln357_q[
          447:384];
        default: mux_regs_in_ln357_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_448_d_0 = 
          mux_mux_regs_in_ln357_Z_448_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_448_d_0 = mux_regs_in_ln357_q[
          511:448];
        default: mux_regs_in_ln357_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_512_d_0 = 
          mux_mux_regs_in_ln357_Z_512_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_512_d_0 = mux_regs_in_ln357_q[
          575:512];
        default: mux_regs_in_ln357_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_576_d_0 = 
          mux_mux_regs_in_ln357_Z_576_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_576_d_0 = mux_regs_in_ln357_q[
          639:576];
        default: mux_regs_in_ln357_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_640_d_0 = 
          mux_mux_regs_in_ln357_Z_640_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_640_d_0 = mux_regs_in_ln357_q[
          703:640];
        default: mux_regs_in_ln357_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_64_d_0 = 
          mux_mux_regs_in_ln357_Z_64_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_64_d_0 = mux_regs_in_ln357_q[
          127:64];
        default: mux_regs_in_ln357_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_704_d_0 = 
          mux_mux_regs_in_ln357_Z_704_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_704_d_0 = mux_regs_in_ln357_q[
          767:704];
        default: mux_regs_in_ln357_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_768_d_0 = 
          mux_mux_regs_in_ln357_Z_768_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_768_d_0 = mux_regs_in_ln357_q[
          831:768];
        default: mux_regs_in_ln357_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_832_d_0 = 
          mux_mux_regs_in_ln357_Z_832_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_832_d_0 = mux_regs_in_ln357_q[
          895:832];
        default: mux_regs_in_ln357_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_896_d_0 = 
          mux_mux_regs_in_ln357_Z_896_v_0;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_896_d_0 = mux_regs_in_ln357_q[
          959:896];
        default: mux_regs_in_ln357_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_960_d_0 = {mux_mux_regs_0_ln357_Z_v[31:
          0], mux_mux_regs_in_ln357_Z_960_v_0};
        mux_regs_in_ln357_sel: mux_regs_in_ln357_960_d_0 = {mux_regs_0_ln357_q[
          31:0], mux_regs_in_ln357_q[991:960]};
        default: mux_regs_in_ln357_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_in_ln357_d = mux_mux_regs_in_ln357_Z_v;
        mux_regs_in_ln357_sel: mux_regs_in_ln357_d = mux_regs_in_ln357_q[63:0];
        default: mux_regs_in_ln357_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_regs_0_ln357_160_d_0 = {
          mux_mux_regs_0_ln357_Z_192_v_0[31:0], mux_mux_regs_0_ln357_Z_128_v_0[
          63:32]};
        mux_regs_in_ln357_sel: mux_regs_0_ln357_160_d_0 = mux_regs_0_ln357_q[223:
          160];
        default: mux_regs_0_ln357_160_d_0 = 64'hX;
      endcase
      and_1_ln460_unr4_0_z = if_ln460_unr4_z & !ge_ln457_unr4_q & 
      and_0_ln460_unr3_0_z;
      and_0_ln460_unr4_0_z = or_and_0_ln460_unr4_Z_0_z & and_0_ln460_unr3_0_z;
      if (eq_ln445_unr20_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
        mux_regs_0_ln440_q[1023:672];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_q[703:672]};
      and_1_ln523_unr16_0_z = !memread_pop_ln523_unr0_0_9_q[7] & !
      eq_ln445_unr15_Z_0_tag_0 & and_1_ln523_unr15_0_z;
      and_0_ln521_unr16_z = or_and_0_ln521_Z_0_unr16_q & and_1_ln523_unr15_0_z;
      case (mux_cur_ln440_z)
        32'h1a: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            4'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            6'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr25_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr25_z};
          end
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_ping_ln357_Z_0_tag_d = mux_mux_ping_ln357_Z_0_v;
        mux_ping_ln357_Z_0_tag_sel: mux_ping_ln357_Z_0_tag_d = 
          mux_ping_ln357_Z_0_tag_0;
        default: mux_ping_ln357_Z_0_tag_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln379_z: mux_burst_ln357_d_0 = {mux_add_ln598_Z_1_v_0, 
          mux_mux_burst_ln357_Z_0_v};
        mux_ping_ln357_Z_0_tag_sel: mux_burst_ln357_d_0 = {add_ln598_1_q, 
          mux_burst_ln357_q};
        default: mux_burst_ln357_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln346_z: read_sort_len_ln352_d = {batch, len};
        read_sort_len_ln352_sel: read_sort_len_ln352_d = {
          read_sort_batch_ln353_q, read_sort_len_ln352_q};
        default: read_sort_len_ln352_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln346_z: gt_ln387_d_0 = {sub_ln510_z[4:1], gt_ln387_z};
        read_sort_len_ln352_sel: gt_ln387_d_0 = {sub_ln510_1_q, gt_ln387_q};
        default: gt_ln387_d_0 = 5'hX;
      endcase
      and_1_ln460_unr5_0_z = if_ln460_unr5_z & !ge_ln457_unr5_q & 
      and_0_ln460_unr4_0_z;
      and_0_ln460_unr5_0_z = or_and_0_ln460_unr5_Z_0_z & and_0_ln460_unr4_0_z;
      if (eq_ln445_unr19_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
        mux_regs_0_ln440_q[1023:640];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z, 
        mux_regs_in_ln456_30_q[671:640]};
      and_1_ln523_unr17_0_z = !memread_pop_ln523_unr0_0_9_q[8] & !
      eq_ln445_unr16_Z_0_tag_0 & and_1_ln523_unr16_0_z;
      and_0_ln521_unr17_z = or_and_0_ln521_Z_0_unr17_q & and_1_ln523_unr16_0_z;
      case (mux_cur_ln440_z)
        32'h19: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            5'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            7'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr24_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr24_z};
          end
      endcase
      and_1_ln460_unr6_0_z = if_ln460_unr6_z & !ge_ln457_unr6_q & 
      and_0_ln460_unr5_0_z;
      and_0_ln460_unr6_0_z = or_and_0_ln460_unr6_Z_0_z & and_0_ln460_unr5_0_z;
      if (eq_ln445_unr18_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:608];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z, 
        mux_regs_in_ln456_30_q[639:608]};
      and_1_ln523_unr18_0_z = !memread_pop_ln523_unr0_0_9_q[9] & !
      eq_ln445_unr17_Z_0_tag_0 & and_1_ln523_unr17_0_z;
      and_0_ln521_unr18_z = or_and_0_ln521_Z_0_unr18_q & and_1_ln523_unr17_0_z;
      case (mux_cur_ln440_z)
        32'h18: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            6'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            8'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr23_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr23_z};
          end
      endcase
      and_1_ln460_unr7_0_z = if_ln460_unr7_z & !ge_ln457_unr7_q & 
      and_0_ln460_unr6_0_z;
      and_0_ln460_unr7_0_z = or_and_0_ln460_unr7_Z_0_z & and_0_ln460_unr6_0_z;
      if (eq_ln445_unr17_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:576];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[607:576]};
      and_1_ln523_unr19_0_z = !memread_pop_ln523_unr0_0_9_q[10] & !
      eq_ln445_unr18_Z_0_tag_0 & and_1_ln523_unr18_0_z;
      and_0_ln521_unr19_z = or_and_0_ln521_Z_0_unr19_q & and_1_ln523_unr18_0_z;
      case (mux_cur_ln440_z)
        32'h17: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            7'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            9'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr22_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr22_z};
          end
      endcase
      and_1_ln460_unr8_0_z = if_ln460_unr8_z & !ge_ln457_unr8_q & 
      and_0_ln460_unr7_0_z;
      and_0_ln460_unr8_0_z = or_and_0_ln460_unr8_Z_0_z & and_0_ln460_unr7_0_z;
      if (eq_ln445_unr16_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:544];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[575:544]};
      and_1_ln523_unr20_0_z = !memread_pop_ln523_unr0_0_9_q[11] & !
      eq_ln445_unr19_Z_0_tag_0 & and_1_ln523_unr19_0_z;
      and_0_ln521_unr20_z = or_and_0_ln521_Z_0_unr20_q & and_1_ln523_unr19_0_z;
      case (mux_cur_ln440_z)
        32'h16: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            8'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            10'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr21_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr21_z};
          end
      endcase
      and_1_ln460_unr9_0_z = if_ln460_unr9_z & !ge_ln457_unr9_q & 
      and_0_ln460_unr8_0_z;
      and_0_ln460_unr9_0_z = or_and_0_ln460_unr9_Z_0_z & and_0_ln460_unr8_0_z;
      if (eq_ln445_unr15_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:512];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[543:512]};
      and_1_ln523_unr21_0_z = !memread_pop_ln523_unr0_0_9_q[12] & !
      eq_ln445_unr20_Z_0_tag_0 & and_1_ln523_unr20_0_z;
      and_0_ln521_unr21_z = or_and_0_ln521_Z_0_unr21_q & and_1_ln523_unr20_0_z;
      case (mux_cur_ln440_z)
        32'h15: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
            9'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            11'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr20_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr20_z};
          end
      endcase
      and_1_ln460_unr10_0_z = if_ln460_unr10_z & !ge_ln457_unr10_q & 
      and_0_ln460_unr9_0_z;
      and_0_ln460_unr10_0_z = or_and_0_ln460_unr10_Z_0_z & and_0_ln460_unr9_0_z;
      if (eq_ln445_unr14_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:480];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[511:480]};
      and_1_ln523_unr22_0_z = !memread_pop_ln523_unr0_0_9_q[13] & !
      eq_ln445_unr21_Z_0_tag_0 & and_1_ln523_unr21_0_z;
      and_0_ln521_unr22_z = or_and_0_ln521_Z_0_unr22_q & and_1_ln523_unr21_0_z;
      case (mux_cur_ln440_z)
        32'h14: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
            10'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            12'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr19_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr19_z};
          end
      endcase
      and_1_ln460_unr11_0_z = if_ln460_unr11_z & !ge_ln457_unr11_q & 
      and_0_ln460_unr10_0_z;
      and_0_ln460_unr11_0_z = or_and_0_ln460_unr11_Z_0_z & and_0_ln460_unr10_0_z;
      if (eq_ln445_unr13_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:448];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[479:448]};
      and_1_ln523_unr23_0_z = !memread_pop_ln523_unr0_0_9_q[14] & !
      eq_ln445_unr22_Z_0_tag_0 & and_1_ln523_unr22_0_z;
      and_0_ln521_unr23_z = or_and_0_ln521_Z_0_unr23_q & and_1_ln523_unr22_0_z;
      case (mux_cur_ln440_z)
        32'h13: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            11'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            13'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr18_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr18_z};
          end
      endcase
      and_1_ln460_unr12_0_z = if_ln460_unr12_z & !ge_ln457_unr12_q & 
      and_0_ln460_unr11_0_z;
      and_0_ln460_unr12_0_z = or_and_0_ln460_unr12_Z_0_z & and_0_ln460_unr11_0_z;
      if (eq_ln445_unr12_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:416];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        {mux_regs_0_MERGE_SEQ_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[447:416]};
      and_1_ln523_unr24_0_z = !memread_pop_ln523_unr0_0_9_q[15] & !
      eq_ln445_unr23_Z_0_tag_0 & and_1_ln523_unr23_0_z;
      and_0_ln521_unr24_z = or_and_0_ln521_Z_0_unr24_q & and_1_ln523_unr23_0_z;
      case (mux_cur_ln440_z)
        32'h12: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            12'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            14'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr17_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr17_z};
          end
      endcase
      and_1_ln460_unr13_0_z = if_ln460_unr13_z & !ge_ln457_unr13_q & 
      and_0_ln460_unr12_0_z;
      and_0_ln460_unr13_0_z = or_and_0_ln460_unr13_Z_0_z & and_0_ln460_unr12_0_z;
      if (eq_ln445_unr11_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:384];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[415:384]};
      and_1_ln523_unr25_0_z = !memread_pop_ln523_unr0_0_9_q[16] & !
      eq_ln445_unr24_Z_0_tag_0 & and_1_ln523_unr24_0_z;
      and_0_ln521_unr25_z = or_and_0_ln521_Z_0_unr25_q & and_1_ln523_unr24_0_z;
      case (mux_cur_ln440_z)
        32'h11: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            13'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            15'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr16_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr16_z};
          end
      endcase
      and_1_ln460_unr14_0_z = if_ln460_unr14_z & !ge_ln457_unr14_q & 
      and_0_ln460_unr13_0_z;
      and_0_ln460_unr14_0_z = or_and_0_ln460_unr14_Z_0_z & and_0_ln460_unr13_0_z;
      if (eq_ln445_unr10_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:352];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[383:352]};
      and_1_ln523_unr26_0_z = !memread_pop_ln523_unr0_0_9_q[17] & !
      eq_ln445_unr25_Z_0_tag_0 & and_1_ln523_unr25_0_z;
      and_0_ln521_unr26_z = or_and_0_ln521_Z_0_unr26_q & and_1_ln523_unr25_0_z;
      case (mux_cur_ln440_z)
        32'h10: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            14'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            16'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0__z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr15_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
            sort_unisim_lt_float_ln447_unr15_z};
          end
      endcase
      and_1_ln460_unr15_0_z = if_ln460_unr15_z & !ge_ln457_unr15_q & 
      and_0_ln460_unr14_0_z;
      and_0_ln460_unr15_0_z = or_and_0_ln460_unr15_Z_0_z & and_0_ln460_unr14_0_z;
      if (eq_ln445_unr9_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:320];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[351:320]};
      and_1_ln523_unr27_0_z = !memread_pop_ln523_unr0_0_9_q[18] & !
      eq_ln445_unr26_Z_0_tag_0 & and_1_ln523_unr26_0_z;
      and_0_ln521_unr27_z = or_and_0_ln521_Z_0_unr27_q & and_1_ln523_unr26_0_z;
      case (mux_cur_ln440_z)
        32'hf: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            15'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            17'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr14_0_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr14_z};
          end
      endcase
      and_1_ln460_unr16_0_z = if_ln460_unr16_z & !ge_ln457_unr16_q & 
      and_0_ln460_unr15_0_z;
      and_0_ln460_unr16_0_z = or_and_0_ln460_unr16_Z_0_z & and_0_ln460_unr15_0_z;
      if (eq_ln445_unr8_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:288];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[319:288]};
      and_1_ln523_unr28_0_z = !memread_pop_ln523_unr0_0_9_q[19] & !
      eq_ln445_unr27_Z_0_tag_0 & and_1_ln523_unr27_0_z;
      and_0_ln521_unr28_z = or_and_0_ln521_Z_0_unr28_q & and_1_ln523_unr27_0_z;
      case (mux_cur_ln440_z)
        32'he: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            16'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            18'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr13_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr13_z};
          end
      endcase
      and_1_ln460_unr17_0_z = if_ln460_unr17_z & !ge_ln457_unr17_q & 
      and_0_ln460_unr16_0_z;
      and_0_ln460_unr17_0_z = or_and_0_ln460_unr17_Z_0_z & and_0_ln460_unr16_0_z;
      if (eq_ln445_unr7_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr7_0_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:256];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr7_0_0_0_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[287:256]};
      and_1_ln523_unr29_0_z = !memread_pop_ln523_unr0_0_9_q[20] & !
      eq_ln445_unr28_Z_0_tag_0 & and_1_ln523_unr28_0_z;
      and_0_ln521_unr29_z = or_and_0_ln521_Z_0_unr29_q & and_1_ln523_unr28_0_z;
      case (mux_cur_ln440_z)
        32'hd: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            17'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            19'h0;
          end
        default: begin
            
            mux_shift_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr12_0_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr12_z};
          end
      endcase
      and_1_ln460_unr18_0_z = if_ln460_unr18_z & !ge_ln457_unr18_q & 
      and_0_ln460_unr17_0_z;
      and_0_ln460_unr18_0_z = or_and_0_ln460_unr18_Z_0_z & and_0_ln460_unr17_0_z;
      if (eq_ln445_unr6_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr6_0_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:224];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr6_0_0_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr7_0_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[255:224]};
      and_1_ln523_unr30_0_z = !memread_pop_ln523_unr0_0_9_q[21] & !
      eq_ln445_unr29_Z_0_tag_0 & and_1_ln523_unr29_0_z;
      and_0_ln521_unr30_z = or_and_0_ln521_Z_0_unr30_q & and_1_ln523_unr29_0_z;
      case (mux_cur_ln440_z)
        32'hc: begin
            mux_shift_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            18'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_z = 
            20'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr11_0_0_0_0_0_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr11_z};
          end
      endcase
      and_1_ln460_unr19_0_z = if_ln460_unr19_z & !ge_ln457_unr19_q & 
      and_0_ln460_unr18_0_z;
      and_0_ln460_unr19_0_z = or_and_0_ln460_unr19_Z_0_z & and_0_ln460_unr18_0_z;
      if (eq_ln445_unr5_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr5_0_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:192];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr5_0_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr6_0_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[223:192]};
      and_1_ln523_unr31_0_z = !memread_pop_ln523_unr0_0_9_q[22] & !
      eq_ln445_unr30_Z_0_tag_0 & and_1_ln523_unr30_0_z;
      and_0_ln521_unr31_z = or_and_0_ln521_Z_0_unr31_q & and_1_ln523_unr30_0_z;
      case (mux_cur_ln440_z)
        32'hb: begin
            mux_shift_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            19'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_z = 
            21'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln456_z = 
            {
            mux_shift_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr10_0_0_0_0_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr10_z};
          end
      endcase
      and_1_ln460_unr20_0_z = if_ln460_unr20_z & !ge_ln457_unr20_q & 
      and_0_ln460_unr19_0_z;
      and_0_ln460_unr20_0_z = or_and_0_ln460_unr20_Z_0_z & and_0_ln460_unr19_0_z;
      if (eq_ln445_unr4_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr4_0_0_0_0_0_ln510_z = 
        mux_regs_0_ln440_q[1023:160];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr4_0_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr5_0_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[191:160]};
      case (1'b1)// synthesis parallel_case
        or_and_0_ln521_Z_0_unr0_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln485_unr0_Z_0_tag_0;
        and_0_ln521_unr1_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr0_Z_0_tag_0;
        and_0_ln521_unr2_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr1_Z_0_tag_0;
        and_0_ln521_unr3_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr2_Z_0_tag_0;
        and_0_ln521_unr4_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr3_Z_0_tag_0;
        and_0_ln521_unr5_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr4_Z_0_tag_0;
        and_0_ln521_unr6_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr5_Z_0_tag_0;
        and_0_ln521_unr7_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr6_Z_0_tag_0;
        and_0_ln521_unr8_Z_0_tag_0: mux_exit_eq_ln521_z = 
          eq_ln445_unr7_Z_0_tag_0;
        and_0_ln521_unr9_z: mux_exit_eq_ln521_z = eq_ln445_unr8_Z_0_tag_0;
        and_0_ln521_unr10_z: mux_exit_eq_ln521_z = eq_ln445_unr9_Z_0_tag_0;
        and_0_ln521_unr11_z: mux_exit_eq_ln521_z = eq_ln445_unr10_Z_0_tag_0;
        and_0_ln521_unr12_z: mux_exit_eq_ln521_z = eq_ln445_unr11_Z_0_tag_0;
        and_0_ln521_unr13_z: mux_exit_eq_ln521_z = eq_ln445_unr12_Z_0_tag_0;
        and_0_ln521_unr14_z: mux_exit_eq_ln521_z = eq_ln445_unr13_Z_0_tag_0;
        and_0_ln521_unr15_z: mux_exit_eq_ln521_z = eq_ln445_unr14_Z_0_tag_0;
        and_0_ln521_unr16_z: mux_exit_eq_ln521_z = eq_ln445_unr15_Z_0_tag_0;
        and_0_ln521_unr17_z: mux_exit_eq_ln521_z = eq_ln445_unr16_Z_0_tag_0;
        and_0_ln521_unr18_z: mux_exit_eq_ln521_z = eq_ln445_unr17_Z_0_tag_0;
        and_0_ln521_unr19_z: mux_exit_eq_ln521_z = eq_ln445_unr18_Z_0_tag_0;
        and_0_ln521_unr20_z: mux_exit_eq_ln521_z = eq_ln445_unr19_Z_0_tag_0;
        and_0_ln521_unr21_z: mux_exit_eq_ln521_z = eq_ln445_unr20_Z_0_tag_0;
        and_0_ln521_unr22_z: mux_exit_eq_ln521_z = eq_ln445_unr21_Z_0_tag_0;
        and_0_ln521_unr23_z: mux_exit_eq_ln521_z = eq_ln445_unr22_Z_0_tag_0;
        and_0_ln521_unr24_z: mux_exit_eq_ln521_z = eq_ln445_unr23_Z_0_tag_0;
        and_0_ln521_unr25_z: mux_exit_eq_ln521_z = eq_ln445_unr24_Z_0_tag_0;
        and_0_ln521_unr26_z: mux_exit_eq_ln521_z = eq_ln445_unr25_Z_0_tag_0;
        and_0_ln521_unr27_z: mux_exit_eq_ln521_z = eq_ln445_unr26_Z_0_tag_0;
        and_0_ln521_unr28_z: mux_exit_eq_ln521_z = eq_ln445_unr27_Z_0_tag_0;
        and_0_ln521_unr29_z: mux_exit_eq_ln521_z = eq_ln445_unr28_Z_0_tag_0;
        and_0_ln521_unr30_z: mux_exit_eq_ln521_z = eq_ln445_unr29_Z_0_tag_0;
        and_0_ln521_unr31_z: mux_exit_eq_ln521_z = eq_ln445_unr30_Z_0_tag_0;
        and_1_ln523_unr31_0_z: mux_exit_eq_ln521_z = eq_ln521_unr32_z;
        default: mux_exit_eq_ln521_z = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        or_and_0_ln521_Z_0_unr0_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h0;
        and_0_ln521_unr1_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h1;
        and_0_ln521_unr2_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h2;
        and_0_ln521_unr3_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h3;
        and_0_ln521_unr4_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h4;
        and_0_ln521_unr5_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h5;
        and_0_ln521_unr6_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h6;
        and_0_ln521_unr7_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h7;
        and_0_ln521_unr8_Z_0_tag_0: mux_exit_mux_chunk_3_ln520_z = 6'h8;
        and_0_ln521_unr9_z: mux_exit_mux_chunk_3_ln520_z = 6'h9;
        and_0_ln521_unr10_z: mux_exit_mux_chunk_3_ln520_z = 6'ha;
        and_0_ln521_unr11_z: mux_exit_mux_chunk_3_ln520_z = 6'hb;
        and_0_ln521_unr12_z: mux_exit_mux_chunk_3_ln520_z = 6'hc;
        and_0_ln521_unr13_z: mux_exit_mux_chunk_3_ln520_z = 6'hd;
        and_0_ln521_unr14_z: mux_exit_mux_chunk_3_ln520_z = 6'he;
        and_0_ln521_unr15_z: mux_exit_mux_chunk_3_ln520_z = 6'hf;
        and_0_ln521_unr16_z: mux_exit_mux_chunk_3_ln520_z = 6'h10;
        and_0_ln521_unr17_z: mux_exit_mux_chunk_3_ln520_z = 6'h11;
        and_0_ln521_unr18_z: mux_exit_mux_chunk_3_ln520_z = 6'h12;
        and_0_ln521_unr19_z: mux_exit_mux_chunk_3_ln520_z = 6'h13;
        and_0_ln521_unr20_z: mux_exit_mux_chunk_3_ln520_z = 6'h14;
        and_0_ln521_unr21_z: mux_exit_mux_chunk_3_ln520_z = 6'h15;
        and_0_ln521_unr22_z: mux_exit_mux_chunk_3_ln520_z = 6'h16;
        and_0_ln521_unr23_z: mux_exit_mux_chunk_3_ln520_z = 6'h17;
        and_0_ln521_unr24_z: mux_exit_mux_chunk_3_ln520_z = 6'h18;
        and_0_ln521_unr25_z: mux_exit_mux_chunk_3_ln520_z = 6'h19;
        and_0_ln521_unr26_z: mux_exit_mux_chunk_3_ln520_z = 6'h1a;
        and_0_ln521_unr27_z: mux_exit_mux_chunk_3_ln520_z = 6'h1b;
        and_0_ln521_unr28_z: mux_exit_mux_chunk_3_ln520_z = 6'h1c;
        and_0_ln521_unr29_z: mux_exit_mux_chunk_3_ln520_z = 6'h1d;
        and_0_ln521_unr30_z: mux_exit_mux_chunk_3_ln520_z = 6'h1e;
        and_0_ln521_unr31_z: mux_exit_mux_chunk_3_ln520_z = 6'h1f;
        and_1_ln523_unr31_0_z: mux_exit_mux_chunk_3_ln520_z = 6'h20;
        default: mux_exit_mux_chunk_3_ln520_z = 6'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        or_and_0_ln521_Z_0_unr0_Z_0_tag_0: mux_exit_and_0_ln523_z = 
          and_0_ln523_unr0_q;
        and_0_ln521_unr1_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr1_q;
        and_0_ln521_unr2_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr2_q;
        and_0_ln521_unr3_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr3_q;
        and_0_ln521_unr4_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr4_q;
        and_0_ln521_unr5_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr5_q;
        and_0_ln521_unr6_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr6_q;
        and_0_ln521_unr7_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr7_q;
        and_0_ln521_unr8_Z_0_tag_0: mux_exit_and_0_ln523_z = and_0_ln523_unr8_q;
        and_0_ln521_unr9_z: mux_exit_and_0_ln523_z = and_0_ln523_unr9_q;
        and_0_ln521_unr10_z: mux_exit_and_0_ln523_z = and_0_ln523_unr10_q;
        and_0_ln521_unr11_z: mux_exit_and_0_ln523_z = and_0_ln523_unr11_q;
        and_0_ln521_unr12_z: mux_exit_and_0_ln523_z = and_0_ln523_unr12_q;
        and_0_ln521_unr13_z: mux_exit_and_0_ln523_z = and_0_ln523_unr13_q;
        and_0_ln521_unr14_z: mux_exit_and_0_ln523_z = and_0_ln523_unr14_q;
        and_0_ln521_unr15_z: mux_exit_and_0_ln523_z = and_0_ln523_unr15_q;
        and_0_ln521_unr16_z: mux_exit_and_0_ln523_z = and_0_ln523_unr16_q;
        and_0_ln521_unr17_z: mux_exit_and_0_ln523_z = and_0_ln523_unr17_q;
        and_0_ln521_unr18_z: mux_exit_and_0_ln523_z = and_0_ln523_unr18_q;
        and_0_ln521_unr19_z: mux_exit_and_0_ln523_z = and_0_ln523_unr19_q;
        and_0_ln521_unr20_z: mux_exit_and_0_ln523_z = and_0_ln523_unr20_q;
        and_0_ln521_unr21_z: mux_exit_and_0_ln523_z = and_0_ln523_unr21_q;
        and_0_ln521_unr22_z: mux_exit_and_0_ln523_z = and_0_ln523_unr22_q;
        and_0_ln521_unr23_z: mux_exit_and_0_ln523_z = and_0_ln523_unr23_q;
        and_0_ln521_unr24_z: mux_exit_and_0_ln523_z = and_0_ln523_unr24_q;
        and_0_ln521_unr25_z: mux_exit_and_0_ln523_z = and_0_ln523_unr25_q;
        and_0_ln521_unr26_z: mux_exit_and_0_ln523_z = and_0_ln523_unr26_q;
        and_0_ln521_unr27_z: mux_exit_and_0_ln523_z = and_0_ln523_unr27_q;
        and_0_ln521_unr28_z: mux_exit_and_0_ln523_z = and_0_ln523_unr28_q;
        and_0_ln521_unr29_z: mux_exit_and_0_ln523_z = and_0_ln523_unr29_q;
        and_0_ln521_unr30_z: mux_exit_and_0_ln523_z = and_0_ln523_unr30_q;
        and_0_ln521_unr31_z: mux_exit_and_0_ln523_z = and_0_ln523_unr31_q;
        and_1_ln523_unr31_0_z: mux_exit_and_0_ln523_z = 1'b0;
        default: mux_exit_and_0_ln523_z = 1'bX;
      endcase
      if (eq_ln445_unr9_z) 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_z = 
        22'h0;
      else 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_z = 
        {
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_z, 
        sort_unisim_lt_float_ln447_unr9_z};
      if (eq_ln445_unr9_z) 
        mux_shift_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln456_z = 20'h0;
      else 
        mux_shift_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln456_z = {
        mux_shift_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_ln456_z, 
        memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr9_0_0_0_0_0_0_0_0_0_0_z
        [0]};
      and_1_ln460_unr21_0_z = if_ln460_unr21_z & !ge_ln457_unr21_q & 
      and_0_ln460_unr20_0_z;
      and_0_ln460_unr21_0_z = or_and_0_ln460_unr21_Z_0_z & and_0_ln460_unr20_0_z;
      if (eq_ln445_unr3_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr3_0_0_0_0_ln510_z = mux_regs_0_ln440_q[
        1023:128];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr3_0_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr4_0_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[159:128]};
      memwrite_head_ln527_z = mux_head_ln440_q;
      memwrite_head_ln527_S = 32'h7f800000;
      case (mux_exit_mux_chunk_3_ln520_z[4:0])// synthesis parallel_case
        5'h0: memwrite_head_ln527_z[31:0] = memwrite_head_ln527_S;
        5'h1: memwrite_head_ln527_z[63:32] = memwrite_head_ln527_S;
        5'h2: memwrite_head_ln527_z[95:64] = memwrite_head_ln527_S;
        5'h3: memwrite_head_ln527_z[127:96] = memwrite_head_ln527_S;
        5'h4: memwrite_head_ln527_z[159:128] = memwrite_head_ln527_S;
        5'h5: memwrite_head_ln527_z[191:160] = memwrite_head_ln527_S;
        5'h6: memwrite_head_ln527_z[223:192] = memwrite_head_ln527_S;
        5'h7: memwrite_head_ln527_z[255:224] = memwrite_head_ln527_S;
        5'h8: memwrite_head_ln527_z[287:256] = memwrite_head_ln527_S;
        5'h9: memwrite_head_ln527_z[319:288] = memwrite_head_ln527_S;
        5'ha: memwrite_head_ln527_z[351:320] = memwrite_head_ln527_S;
        5'hb: memwrite_head_ln527_z[383:352] = memwrite_head_ln527_S;
        5'hc: memwrite_head_ln527_z[415:384] = memwrite_head_ln527_S;
        5'hd: memwrite_head_ln527_z[447:416] = memwrite_head_ln527_S;
        5'he: memwrite_head_ln527_z[479:448] = memwrite_head_ln527_S;
        5'hf: memwrite_head_ln527_z[511:480] = memwrite_head_ln527_S;
        5'h10: memwrite_head_ln527_z[543:512] = memwrite_head_ln527_S;
        5'h11: memwrite_head_ln527_z[575:544] = memwrite_head_ln527_S;
        5'h12: memwrite_head_ln527_z[607:576] = memwrite_head_ln527_S;
        5'h13: memwrite_head_ln527_z[639:608] = memwrite_head_ln527_S;
        5'h14: memwrite_head_ln527_z[671:640] = memwrite_head_ln527_S;
        5'h15: memwrite_head_ln527_z[703:672] = memwrite_head_ln527_S;
        5'h16: memwrite_head_ln527_z[735:704] = memwrite_head_ln527_S;
        5'h17: memwrite_head_ln527_z[767:736] = memwrite_head_ln527_S;
        5'h18: memwrite_head_ln527_z[799:768] = memwrite_head_ln527_S;
        5'h19: memwrite_head_ln527_z[831:800] = memwrite_head_ln527_S;
        5'h1a: memwrite_head_ln527_z[863:832] = memwrite_head_ln527_S;
        5'h1b: memwrite_head_ln527_z[895:864] = memwrite_head_ln527_S;
        5'h1c: memwrite_head_ln527_z[927:896] = memwrite_head_ln527_S;
        5'h1d: memwrite_head_ln527_z[959:928] = memwrite_head_ln527_S;
        5'h1e: memwrite_head_ln527_z[991:960] = memwrite_head_ln527_S;
        5'h1f: memwrite_head_ln527_z[1023:992] = memwrite_head_ln527_S;
        default: memwrite_head_ln527_z = 32'hX;
      endcase
      or_lt_ln520_Z_1_z = mux_exit_eq_ln521_z | mux_exit_mux_chunk_3_ln520_z[5];
      case (mux_exit_mux_chunk_3_ln520_z[4:0])// synthesis parallel_case
        5'h0: memread_fidx_ln524_z = mux_fidx_ln440_q[31:5];
        5'h1: memread_fidx_ln524_z = mux_fidx_ln440_q[63:37];
        5'h2: memread_fidx_ln524_z = mux_fidx_ln440_q[95:69];
        5'h3: memread_fidx_ln524_z = mux_fidx_ln440_q[127:101];
        5'h4: memread_fidx_ln524_z = mux_fidx_ln440_q[159:133];
        5'h5: memread_fidx_ln524_z = mux_fidx_ln440_q[191:165];
        5'h6: memread_fidx_ln524_z = mux_fidx_ln440_q[223:197];
        5'h7: memread_fidx_ln524_z = mux_fidx_ln440_q[255:229];
        5'h8: memread_fidx_ln524_z = mux_fidx_ln440_q[287:261];
        5'h9: memread_fidx_ln524_z = mux_fidx_ln440_q[319:293];
        5'ha: memread_fidx_ln524_z = mux_fidx_ln440_q[351:325];
        5'hb: memread_fidx_ln524_z = mux_fidx_ln440_q[383:357];
        5'hc: memread_fidx_ln524_z = mux_fidx_ln440_q[415:389];
        5'hd: memread_fidx_ln524_z = mux_fidx_ln440_q[447:421];
        5'he: memread_fidx_ln524_z = mux_fidx_ln440_q[479:453];
        5'hf: memread_fidx_ln524_z = mux_fidx_ln440_q[511:485];
        5'h10: memread_fidx_ln524_z = mux_fidx_ln440_q[543:517];
        5'h11: memread_fidx_ln524_z = mux_fidx_ln440_q[575:549];
        5'h12: memread_fidx_ln524_z = mux_fidx_ln440_q[607:581];
        5'h13: memread_fidx_ln524_z = mux_fidx_ln440_q[639:613];
        5'h14: memread_fidx_ln524_z = mux_fidx_ln440_q[671:645];
        5'h15: memread_fidx_ln524_z = mux_fidx_ln440_q[703:677];
        5'h16: memread_fidx_ln524_z = mux_fidx_ln440_q[735:709];
        5'h17: memread_fidx_ln524_z = mux_fidx_ln440_q[767:741];
        5'h18: memread_fidx_ln524_z = mux_fidx_ln440_q[799:773];
        5'h19: memread_fidx_ln524_z = mux_fidx_ln440_q[831:805];
        5'h1a: memread_fidx_ln524_z = mux_fidx_ln440_q[863:837];
        5'h1b: memread_fidx_ln524_z = mux_fidx_ln440_q[895:869];
        5'h1c: memread_fidx_ln524_z = mux_fidx_ln440_q[927:901];
        5'h1d: memread_fidx_ln524_z = mux_fidx_ln440_q[959:933];
        5'h1e: memread_fidx_ln524_z = mux_fidx_ln440_q[991:965];
        5'h1f: memread_fidx_ln524_z = mux_fidx_ln440_q[1023:997];
        default: memread_fidx_ln524_z = 27'hX;
      endcase
      case (mux_cur_ln440_z)
        32'h9: begin
            mux_shift_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_ln456_z = 
            21'h0;
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_z = 
            23'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_ln456_z = {
            mux_shift_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_z
            [0]};
            
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr8_0_0_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr8_z};
          end
      endcase
      and_1_ln460_unr22_0_z = if_ln460_unr22_z & !ge_ln457_unr22_q & 
      and_0_ln460_unr21_0_z;
      and_0_ln460_unr22_0_z = or_and_0_ln460_unr22_Z_0_z & and_0_ln460_unr21_0_z;
      if (eq_ln445_unr2_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr2_0_0_0_ln510_z = mux_regs_0_ln440_q[
        1023:96];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr2_0_0_0_ln510_z = {
        mux_regs_0_MERGE_SEQ_for_exit_unr3_0_0_0_0_ln510_z, 
        mux_regs_in_ln456_30_q[127:96]};
      lt_ln524_z = memread_fidx_ln524_z == 27'h0;
      case (mux_cur_ln440_z)
        32'h8: begin
            mux_shift_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_ln456_z = 22'h0;
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_z = 
            24'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_ln456_z = {
            mux_shift_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_z
            [0]};
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr7_0_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr7_z};
          end
      endcase
      and_1_ln460_unr23_0_z = if_ln460_unr23_z & !ge_ln457_unr23_q & 
      and_0_ln460_unr22_0_z;
      and_0_ln460_unr23_0_z = or_and_0_ln460_unr23_Z_0_z & and_0_ln460_unr22_0_z;
      case (1'b1)// synthesis parallel_case
        case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_q[0]: 
          mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z = mux_regs_0_ln440_q[1023:
          32];
        case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_q[1]: 
          mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z = {mux_regs_0_ln440_q[
          1023:64], mux_regs_in_ln456_30_q[63:32]};
        case_mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_q[2]: 
          mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z = {
          mux_regs_0_MERGE_SEQ_for_exit_unr2_0_0_0_ln510_z, 
          mux_regs_in_ln456_30_q[95:32]};
        default: mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z = 992'hX;
      endcase
      if (lt_ln524_z) 
        mux_pop_idx_ln524_z = mux_exit_mux_chunk_3_ln520_z;
      else 
        mux_pop_idx_ln524_z = 6'h3f;
      case (1'b1)
        !mux_exit_and_0_ln523_z: case_mux_head_ln536_z = 2'h1;
        lt_ln524_z: case_mux_head_ln536_z = 2'h1;
        default: case_mux_head_ln536_z = 2'h2;
      endcase
      case (mux_cur_ln440_z)
        32'h7: begin
            mux_shift_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_ln456_z = 23'h0;
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_z = 
            25'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_ln456_z = {
            mux_shift_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_z
            [0]};
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_z = 
            {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr6_0_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr6_z};
          end
      endcase
      and_1_ln460_unr24_0_z = if_ln460_unr24_z & !ge_ln457_unr24_q & 
      and_0_ln460_unr23_0_z;
      and_0_ln460_unr24_0_z = or_and_0_ln460_unr24_Z_0_z & and_0_ln460_unr23_0_z;
      if (eq_ln485_unr0_Z_0_tag_0) 
        mux_regs_0_ln510_z = mux_regs_0_ln440_q;
      else 
        mux_regs_0_ln510_z = {mux_regs_0_MERGE_SEQ_for_exit_unr0_0_ln510_z, 
        mux_regs_in_ln456_30_q[31:0]};
      case (1'b1)// synthesis parallel_case
        or_lt_ln520_Z_1_z: mux_pop_idx_ln520_0_z = 7'h7f;
        mux_exit_and_0_ln523_z: mux_pop_idx_ln520_0_z = {!lt_ln524_z, 
          mux_pop_idx_ln524_z};
        default: mux_pop_idx_ln520_0_z = 7'hX;
      endcase
      if (case_mux_head_ln536_z[0]) 
        mux_head_ln536_z = mux_head_ln440_q;
      else 
        mux_head_ln536_z = memwrite_head_ln527_z;
      case (mux_cur_ln440_z)
        32'h6: begin
            mux_shift_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_ln456_z = 24'h0;
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_z = 
            26'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_ln456_z = {
            mux_shift_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_z[0]};
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_z = {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr5_0_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr5_z};
          end
      endcase
      and_1_ln460_unr25_0_z = if_ln460_unr25_z & !ge_ln457_unr25_q & 
      and_0_ln460_unr24_0_z;
      and_0_ln460_unr25_0_z = or_and_0_ln460_unr25_Z_0_z & and_0_ln460_unr24_0_z;
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_128_d_0 = 
          mux_regs_0_ln510_z[191:128];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_128_d_0 = mux_regs_0_ln510_q[191:
          128];
        default: mux_regs_0_ln510_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_192_d_0 = 
          mux_regs_0_ln510_z[255:192];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_192_d_0 = mux_regs_0_ln510_q[255:
          192];
        default: mux_regs_0_ln510_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_256_d_0 = 
          mux_regs_0_ln510_z[319:256];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_256_d_0 = mux_regs_0_ln510_q[319:
          256];
        default: mux_regs_0_ln510_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_320_d_0 = 
          mux_regs_0_ln510_z[383:320];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_320_d_0 = mux_regs_0_ln510_q[383:
          320];
        default: mux_regs_0_ln510_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_384_d_0 = 
          mux_regs_0_ln510_z[447:384];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_384_d_0 = mux_regs_0_ln510_q[447:
          384];
        default: mux_regs_0_ln510_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_448_d_0 = 
          mux_regs_0_ln510_z[511:448];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_448_d_0 = mux_regs_0_ln510_q[511:
          448];
        default: mux_regs_0_ln510_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_512_d_0 = 
          mux_regs_0_ln510_z[575:512];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_512_d_0 = mux_regs_0_ln510_q[575:
          512];
        default: mux_regs_0_ln510_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_576_d_0 = 
          mux_regs_0_ln510_z[639:576];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_576_d_0 = mux_regs_0_ln510_q[639:
          576];
        default: mux_regs_0_ln510_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_640_d_0 = 
          mux_regs_0_ln510_z[703:640];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_640_d_0 = mux_regs_0_ln510_q[703:
          640];
        default: mux_regs_0_ln510_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_64_d_0 = 
          mux_regs_0_ln510_z[127:64];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_64_d_0 = mux_regs_0_ln510_q[127:
          64];
        default: mux_regs_0_ln510_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_704_d_0 = 
          mux_regs_0_ln510_z[767:704];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_704_d_0 = mux_regs_0_ln510_q[767:
          704];
        default: mux_regs_0_ln510_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_768_d_0 = 
          mux_regs_0_ln510_z[831:768];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_768_d_0 = mux_regs_0_ln510_q[831:
          768];
        default: mux_regs_0_ln510_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_832_d_0 = 
          mux_regs_0_ln510_z[895:832];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_832_d_0 = mux_regs_0_ln510_q[895:
          832];
        default: mux_regs_0_ln510_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_896_d_0 = 
          mux_regs_0_ln510_z[959:896];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_896_d_0 = mux_regs_0_ln510_q[959:
          896];
        default: mux_regs_0_ln510_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_960_d_0 = 
          mux_regs_0_ln510_z[1023:960];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_960_d_0 = mux_regs_0_ln510_q[1023:
          960];
        default: mux_regs_0_ln510_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_regs_0_ln510_d = 
          mux_regs_0_ln510_z[63:0];
        mux_regs_0_ln510_sel: mux_regs_0_ln510_d = mux_regs_0_ln510_q[63:0];
        default: mux_regs_0_ln510_d = 64'hX;
      endcase
      case ({sub_ln510_1_q, !read_sort_len_ln352_q[5]})// synthesis parallel_case
        5'h0: memread_regs_ln510_z = mux_regs_0_ln510_z[31:0];
        5'h1: memread_regs_ln510_z = mux_regs_0_ln510_z[63:32];
        5'h2: memread_regs_ln510_z = mux_regs_0_ln510_z[95:64];
        5'h3: memread_regs_ln510_z = mux_regs_0_ln510_z[127:96];
        5'h4: memread_regs_ln510_z = mux_regs_0_ln510_z[159:128];
        5'h5: memread_regs_ln510_z = mux_regs_0_ln510_z[191:160];
        5'h6: memread_regs_ln510_z = mux_regs_0_ln510_z[223:192];
        5'h7: memread_regs_ln510_z = mux_regs_0_ln510_z[255:224];
        5'h8: memread_regs_ln510_z = mux_regs_0_ln510_z[287:256];
        5'h9: memread_regs_ln510_z = mux_regs_0_ln510_z[319:288];
        5'ha: memread_regs_ln510_z = mux_regs_0_ln510_z[351:320];
        5'hb: memread_regs_ln510_z = mux_regs_0_ln510_z[383:352];
        5'hc: memread_regs_ln510_z = mux_regs_0_ln510_z[415:384];
        5'hd: memread_regs_ln510_z = mux_regs_0_ln510_z[447:416];
        5'he: memread_regs_ln510_z = mux_regs_0_ln510_z[479:448];
        5'hf: memread_regs_ln510_z = mux_regs_0_ln510_z[511:480];
        5'h10: memread_regs_ln510_z = mux_regs_0_ln510_z[543:512];
        5'h11: memread_regs_ln510_z = mux_regs_0_ln510_z[575:544];
        5'h12: memread_regs_ln510_z = mux_regs_0_ln510_z[607:576];
        5'h13: memread_regs_ln510_z = mux_regs_0_ln510_z[639:608];
        5'h14: memread_regs_ln510_z = mux_regs_0_ln510_z[671:640];
        5'h15: memread_regs_ln510_z = mux_regs_0_ln510_z[703:672];
        5'h16: memread_regs_ln510_z = mux_regs_0_ln510_z[735:704];
        5'h17: memread_regs_ln510_z = mux_regs_0_ln510_z[767:736];
        5'h18: memread_regs_ln510_z = mux_regs_0_ln510_z[799:768];
        5'h19: memread_regs_ln510_z = mux_regs_0_ln510_z[831:800];
        5'h1a: memread_regs_ln510_z = mux_regs_0_ln510_z[863:832];
        5'h1b: memread_regs_ln510_z = mux_regs_0_ln510_z[895:864];
        5'h1c: memread_regs_ln510_z = mux_regs_0_ln510_z[927:896];
        5'h1d: memread_regs_ln510_z = mux_regs_0_ln510_z[959:928];
        5'h1e: memread_regs_ln510_z = mux_regs_0_ln510_z[991:960];
        5'h1f: memread_regs_ln510_z = mux_regs_0_ln510_z[1023:992];
        default: memread_regs_ln510_z = 32'hX;
      endcase
      ne_ln534_z = mux_pop_idx_ln520_0_z == 7'h7f;
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_123_d_0 = 
          mux_head_ln536_z[186:123];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_123_d_0 = 
          mux_head_ln536_q[186:123];
        default: mux_head_ln536_123_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_187_d_0 = 
          mux_head_ln536_z[250:187];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_187_d_0 = 
          mux_head_ln536_q[250:187];
        default: mux_head_ln536_187_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_251_d_0 = 
          mux_head_ln536_z[314:251];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_251_d_0 = 
          mux_head_ln536_q[314:251];
        default: mux_head_ln536_251_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_315_d_0 = 
          mux_head_ln536_z[378:315];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_315_d_0 = 
          mux_head_ln536_q[378:315];
        default: mux_head_ln536_315_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_379_d_0 = 
          mux_head_ln536_z[442:379];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_379_d_0 = 
          mux_head_ln536_q[442:379];
        default: mux_head_ln536_379_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_443_d_0 = 
          mux_head_ln536_z[506:443];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_443_d_0 = 
          mux_head_ln536_q[506:443];
        default: mux_head_ln536_443_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_507_d_0 = 
          mux_head_ln536_z[570:507];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_507_d_0 = 
          mux_head_ln536_q[570:507];
        default: mux_head_ln536_507_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_571_d_0 = 
          mux_head_ln536_z[634:571];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_571_d_0 = 
          mux_head_ln536_q[634:571];
        default: mux_head_ln536_571_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_59_d_0 = 
          mux_head_ln536_z[122:59];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_59_d_0 = 
          mux_head_ln536_q[122:59];
        default: mux_head_ln536_59_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_635_d_0 = 
          mux_head_ln536_z[698:635];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_635_d_0 = 
          mux_head_ln536_q[698:635];
        default: mux_head_ln536_635_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_699_d_0 = 
          mux_head_ln536_z[762:699];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_699_d_0 = 
          mux_head_ln536_q[762:699];
        default: mux_head_ln536_699_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_763_d_0 = 
          mux_head_ln536_z[826:763];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_763_d_0 = 
          mux_head_ln536_q[826:763];
        default: mux_head_ln536_763_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_827_d_0 = 
          mux_head_ln536_z[890:827];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_827_d_0 = 
          mux_head_ln536_q[890:827];
        default: mux_head_ln536_827_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_891_d_0 = 
          mux_head_ln536_z[954:891];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_891_d_0 = 
          mux_head_ln536_q[954:891];
        default: mux_head_ln536_891_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_955_d_0 = 
          mux_head_ln536_z[1018:955];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_955_d_0 = 
          mux_head_ln536_q[1018:955];
        default: mux_head_ln536_955_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_pop_idx_ln520_0_d = {
          mux_head_ln536_z[58:0], mux_pop_idx_ln520_0_z[4:0]};
        state_sort_unisim_sort_merge_sort[10]: mux_pop_idx_ln520_0_d = {
          mux_head_ln536_q[58:0], mux_pop_idx_ln520_0_q};
        default: mux_pop_idx_ln520_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: mux_head_ln536_1019_d_0 = 
          mux_head_ln536_z[1023:1019];
        state_sort_unisim_sort_merge_sort[10]: mux_head_ln536_1019_d_0 = 
          mux_head_ln536_q[1023:1019];
        default: mux_head_ln536_1019_d_0 = 5'hX;
      endcase
      case (mux_cur_ln440_z)
        32'h5: begin
            mux_shift_MERGE_COMPARE_for_exit_unr3_0_0_0_0_ln456_z = 25'h0;
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr3_0_0_0_0_z = 
            27'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr3_0_0_0_0_ln456_z = {
            mux_shift_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_z[0]};
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr3_0_0_0_0_z = {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr4_0_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr4_z};
          end
      endcase
      and_1_ln460_unr26_0_z = if_ln460_unr26_z & !ge_ln457_unr26_q & 
      and_0_ln460_unr25_0_z;
      and_0_ln460_unr26_0_z = or_and_0_ln460_unr26_Z_0_z & and_0_ln460_unr25_0_z;
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[9]: ne_ln534_Z_0_tag_d = ne_ln534_z;
        state_sort_unisim_sort_merge_sort[10]: ne_ln534_Z_0_tag_d = 
          ne_ln534_Z_0_tag_0;
        default: ne_ln534_Z_0_tag_d = 1'bX;
      endcase
      case (mux_cur_ln440_z)
        32'h4: begin
            mux_shift_MERGE_COMPARE_for_exit_unr2_0_0_0_ln456_z = 26'h0;
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr2_0_0_0_z = 28'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr2_0_0_0_ln456_z = {
            mux_shift_MERGE_COMPARE_for_exit_unr3_0_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr3_0_0_0_0_z[0]};
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr2_0_0_0_z = {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr3_0_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr3_z};
          end
      endcase
      and_1_ln460_unr27_0_z = if_ln460_unr27_z & !ge_ln457_unr27_q & 
      and_0_ln460_unr26_0_z;
      and_0_ln460_unr27_0_z = or_and_0_ln460_unr27_Z_0_z & and_0_ln460_unr26_0_z;
      case (mux_cur_ln440_z)
        32'h3: begin
            mux_shift_MERGE_COMPARE_for_exit_unr1_0_0_ln456_z = 27'h0;
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_z = 29'h0;
          end
        default: begin
            mux_shift_MERGE_COMPARE_for_exit_unr1_0_0_ln456_z = {
            mux_shift_MERGE_COMPARE_for_exit_unr2_0_0_0_ln456_z, 
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr2_0_0_0_z[0]};
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr1_0_0_z = {
            memread_shift_ln460_unr0_MERGE_COMPARE_for_exit_unr2_0_0_0_z, 
            sort_unisim_lt_float_ln447_unr2_z};
          end
      endcase
      and_1_ln460_unr28_0_z = if_ln460_unr28_z & !ge_ln457_unr28_q & 
      and_0_ln460_unr27_0_z;
      and_0_ln460_unr28_0_z = or_and_0_ln460_unr28_Z_0_z & and_0_ln460_unr27_0_z;
      and_1_ln460_unr29_0_z = if_ln460_unr29_z & !ge_ln457_unr29_q & 
      and_0_ln460_unr28_0_z;
      and_0_ln460_unr29_0_z = or_and_0_ln460_unr29_Z_0_z & and_0_ln460_unr28_0_z;
      and_1_ln460_unr30_0_z = if_ln460_unr30_z & !ge_ln457_unr30_q & 
      and_0_ln460_unr29_0_z;
      and_0_ln460_unr30_0_z = or_and_0_ln460_unr30_Z_0_z & and_0_ln460_unr29_0_z;
      case (1'b1)// synthesis parallel_case
        and_1_ln460_unr0_z: mux_regs_in_ln456_z = mux_regs_in_ln440_q[991:32];
        and_1_ln460_unr1_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, mux_regs_in_ln440_q[959:32]};
        and_1_ln460_unr2_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          mux_regs_in_ln440_q[927:32]};
        and_1_ln460_unr3_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, mux_regs_in_ln440_q[895:32]};
        and_1_ln460_unr4_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          mux_regs_in_ln440_q[863:32]};
        and_1_ln460_unr5_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, mux_regs_in_ln440_q[831:32]};
        and_1_ln460_unr6_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          mux_regs_in_ln440_q[799:32]};
        and_1_ln460_unr7_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, mux_regs_in_ln440_q[767:32]};
        and_1_ln460_unr8_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          mux_regs_in_ln440_q[735:32]};
        and_1_ln460_unr9_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, mux_regs_in_ln440_q[703:32]};
        and_1_ln460_unr10_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          mux_regs_in_ln440_q[671:32]};
        and_1_ln460_unr11_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, mux_regs_in_ln440_q[639:32]};
        and_1_ln460_unr12_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          mux_regs_in_ln440_q[607:32]};
        and_1_ln460_unr13_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, mux_regs_in_ln440_q[575:32]};
        and_1_ln460_unr14_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          mux_regs_in_ln440_q[543:32]};
        and_1_ln460_unr15_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, mux_regs_in_ln440_q[511:32]};
        and_1_ln460_unr16_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          mux_regs_in_ln440_q[479:32]};
        and_1_ln460_unr17_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, mux_regs_in_ln440_q[447:32]};
        and_1_ln460_unr18_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          mux_regs_in_ln440_q[415:32]};
        and_1_ln460_unr19_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, mux_regs_in_ln440_q[383:32]};
        and_1_ln460_unr20_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          mux_regs_in_ln440_q[351:32]};
        and_1_ln460_unr21_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, mux_regs_in_ln440_q[319:32]};
        and_1_ln460_unr22_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          mux_regs_in_ln440_q[287:32]};
        and_1_ln460_unr23_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, mux_regs_in_ln440_q[255:32]};
        and_1_ln460_unr24_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          mux_regs_in_ln440_q[223:32]};
        and_1_ln460_unr25_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          memwrite_regs_in_ln461_unr25_0_z, mux_regs_in_ln440_q[191:32]};
        and_1_ln460_unr26_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          memwrite_regs_in_ln461_unr25_0_z, memwrite_regs_in_ln461_unr26_0_z, 
          mux_regs_in_ln440_q[159:32]};
        and_1_ln460_unr27_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          memwrite_regs_in_ln461_unr25_0_z, memwrite_regs_in_ln461_unr26_0_z, 
          memwrite_regs_in_ln461_unr27_0_z, mux_regs_in_ln440_q[127:32]};
        and_1_ln460_unr28_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          memwrite_regs_in_ln461_unr25_0_z, memwrite_regs_in_ln461_unr26_0_z, 
          memwrite_regs_in_ln461_unr27_0_z, memwrite_regs_in_ln461_unr28_0_z, 
          mux_regs_in_ln440_q[95:32]};
        and_1_ln460_unr29_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          memwrite_regs_in_ln461_unr25_0_z, memwrite_regs_in_ln461_unr26_0_z, 
          memwrite_regs_in_ln461_unr27_0_z, memwrite_regs_in_ln461_unr28_0_z, 
          memwrite_regs_in_ln461_unr29_0_z, mux_regs_in_ln440_q[63:32]};
        and_1_ln460_unr30_0_z: mux_regs_in_ln456_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          memwrite_regs_in_ln461_unr25_0_z, memwrite_regs_in_ln461_unr26_0_z, 
          memwrite_regs_in_ln461_unr27_0_z, memwrite_regs_in_ln461_unr28_0_z, 
          memwrite_regs_in_ln461_unr29_0_z, memwrite_regs_in_ln461_unr30_0_z};
        default: mux_regs_in_ln456_z = 960'hX;
      endcase
      or_and_1_ln460_unr0_Z_0_z = and_1_ln460_unr30_0_z | and_1_ln460_unr29_0_z | 
      and_1_ln460_unr28_0_z | and_1_ln460_unr27_0_z | and_1_ln460_unr26_0_z | 
      and_1_ln460_unr25_0_z | and_1_ln460_unr24_0_z | and_1_ln460_unr23_0_z | 
      and_1_ln460_unr22_0_z | and_1_ln460_unr21_0_z | and_1_ln460_unr20_0_z | 
      and_1_ln460_unr19_0_z | and_1_ln460_unr18_0_z | and_1_ln460_unr17_0_z | 
      and_1_ln460_unr16_0_z | and_1_ln460_unr15_0_z | and_1_ln460_unr14_0_z | 
      and_1_ln460_unr13_0_z | and_1_ln460_unr12_0_z | and_1_ln460_unr11_0_z | 
      and_1_ln460_unr10_0_z | and_1_ln460_unr9_0_z | and_1_ln460_unr8_0_z | 
      and_1_ln460_unr7_0_z | and_1_ln460_unr6_0_z | and_1_ln460_unr5_0_z | 
      and_1_ln460_unr4_0_z | and_1_ln460_unr3_0_z | and_1_ln460_unr2_0_z | 
      and_1_ln460_unr1_0_z | and_1_ln460_unr0_z;
      case (1'b1)// synthesis parallel_case
        and_1_ln460_unr0_z: mux_exit_mux_chunk_1_ln456_z = 5'h1f;
        and_1_ln460_unr1_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h1e;
        and_1_ln460_unr2_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h1d;
        and_1_ln460_unr3_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h1c;
        and_1_ln460_unr4_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h1b;
        and_1_ln460_unr5_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h1a;
        and_1_ln460_unr6_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h19;
        and_1_ln460_unr7_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h18;
        and_1_ln460_unr8_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h17;
        and_1_ln460_unr9_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h16;
        and_1_ln460_unr10_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h15;
        and_1_ln460_unr11_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h14;
        and_1_ln460_unr12_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h13;
        and_1_ln460_unr13_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h12;
        and_1_ln460_unr14_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h11;
        and_1_ln460_unr15_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h10;
        and_1_ln460_unr16_0_z: mux_exit_mux_chunk_1_ln456_z = 5'hf;
        and_1_ln460_unr17_0_z: mux_exit_mux_chunk_1_ln456_z = 5'he;
        and_1_ln460_unr18_0_z: mux_exit_mux_chunk_1_ln456_z = 5'hd;
        and_1_ln460_unr19_0_z: mux_exit_mux_chunk_1_ln456_z = 5'hc;
        and_1_ln460_unr20_0_z: mux_exit_mux_chunk_1_ln456_z = 5'hb;
        and_1_ln460_unr21_0_z: mux_exit_mux_chunk_1_ln456_z = 5'ha;
        and_1_ln460_unr22_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h9;
        and_1_ln460_unr23_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h8;
        and_1_ln460_unr24_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h7;
        and_1_ln460_unr25_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h6;
        and_1_ln460_unr26_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h5;
        and_1_ln460_unr27_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h4;
        and_1_ln460_unr28_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h3;
        and_1_ln460_unr29_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h2;
        and_1_ln460_unr30_0_z: mux_exit_mux_chunk_1_ln456_z = 5'h1;
        default: mux_exit_mux_chunk_1_ln456_z = 5'hX;
      endcase
      case (mux_exit_mux_chunk_1_ln456_z)// synthesis parallel_case
        5'h0: memread_head_ln467_z = mux_head_ln440_q[31:0];
        5'h1: memread_head_ln467_z = mux_head_ln440_q[63:32];
        5'h2: memread_head_ln467_z = mux_head_ln440_q[95:64];
        5'h3: memread_head_ln467_z = mux_head_ln440_q[127:96];
        5'h4: memread_head_ln467_z = mux_head_ln440_q[159:128];
        5'h5: memread_head_ln467_z = mux_head_ln440_q[191:160];
        5'h6: memread_head_ln467_z = mux_head_ln440_q[223:192];
        5'h7: memread_head_ln467_z = mux_head_ln440_q[255:224];
        5'h8: memread_head_ln467_z = mux_head_ln440_q[287:256];
        5'h9: memread_head_ln467_z = mux_head_ln440_q[319:288];
        5'ha: memread_head_ln467_z = mux_head_ln440_q[351:320];
        5'hb: memread_head_ln467_z = mux_head_ln440_q[383:352];
        5'hc: memread_head_ln467_z = mux_head_ln440_q[415:384];
        5'hd: memread_head_ln467_z = mux_head_ln440_q[447:416];
        5'he: memread_head_ln467_z = mux_head_ln440_q[479:448];
        5'hf: memread_head_ln467_z = mux_head_ln440_q[511:480];
        5'h10: memread_head_ln467_z = mux_head_ln440_q[543:512];
        5'h11: memread_head_ln467_z = mux_head_ln440_q[575:544];
        5'h12: memread_head_ln467_z = mux_head_ln440_q[607:576];
        5'h13: memread_head_ln467_z = mux_head_ln440_q[639:608];
        5'h14: memread_head_ln467_z = mux_head_ln440_q[671:640];
        5'h15: memread_head_ln467_z = mux_head_ln440_q[703:672];
        5'h16: memread_head_ln467_z = mux_head_ln440_q[735:704];
        5'h17: memread_head_ln467_z = mux_head_ln440_q[767:736];
        5'h18: memread_head_ln467_z = mux_head_ln440_q[799:768];
        5'h19: memread_head_ln467_z = mux_head_ln440_q[831:800];
        5'h1a: memread_head_ln467_z = mux_head_ln440_q[863:832];
        5'h1b: memread_head_ln467_z = mux_head_ln440_q[895:864];
        5'h1c: memread_head_ln467_z = mux_head_ln440_q[927:896];
        5'h1d: memread_head_ln467_z = mux_head_ln440_q[959:928];
        5'h1e: memread_head_ln467_z = mux_head_ln440_q[991:960];
        5'h1f: memread_head_ln467_z = mux_head_ln440_q[1023:992];
        default: memread_head_ln467_z = 32'hX;
      endcase
      mux_pop_ln468_0_z = and_0_ln460_unr30_0_z & and_0_ln460_unr30_z;
      memwrite_regs_in_ln467_z = {mux_regs_in_ln456_z, mux_regs_in_ln440_q[31:0], 
      mux_regs_0_ln440_q[31:0]};
      case (mux_exit_mux_chunk_1_ln456_z)// synthesis parallel_case
        5'h0: memwrite_regs_in_ln467_z[31:0] = memread_head_ln467_z;
        5'h1: memwrite_regs_in_ln467_z[63:32] = memread_head_ln467_z;
        5'h2: memwrite_regs_in_ln467_z[95:64] = memread_head_ln467_z;
        5'h3: memwrite_regs_in_ln467_z[127:96] = memread_head_ln467_z;
        5'h4: memwrite_regs_in_ln467_z[159:128] = memread_head_ln467_z;
        5'h5: memwrite_regs_in_ln467_z[191:160] = memread_head_ln467_z;
        5'h6: memwrite_regs_in_ln467_z[223:192] = memread_head_ln467_z;
        5'h7: memwrite_regs_in_ln467_z[255:224] = memread_head_ln467_z;
        5'h8: memwrite_regs_in_ln467_z[287:256] = memread_head_ln467_z;
        5'h9: memwrite_regs_in_ln467_z[319:288] = memread_head_ln467_z;
        5'ha: memwrite_regs_in_ln467_z[351:320] = memread_head_ln467_z;
        5'hb: memwrite_regs_in_ln467_z[383:352] = memread_head_ln467_z;
        5'hc: memwrite_regs_in_ln467_z[415:384] = memread_head_ln467_z;
        5'hd: memwrite_regs_in_ln467_z[447:416] = memread_head_ln467_z;
        5'he: memwrite_regs_in_ln467_z[479:448] = memread_head_ln467_z;
        5'hf: memwrite_regs_in_ln467_z[511:480] = memread_head_ln467_z;
        5'h10: memwrite_regs_in_ln467_z[543:512] = memread_head_ln467_z;
        5'h11: memwrite_regs_in_ln467_z[575:544] = memread_head_ln467_z;
        5'h12: memwrite_regs_in_ln467_z[607:576] = memread_head_ln467_z;
        5'h13: memwrite_regs_in_ln467_z[639:608] = memread_head_ln467_z;
        5'h14: memwrite_regs_in_ln467_z[671:640] = memread_head_ln467_z;
        5'h15: memwrite_regs_in_ln467_z[703:672] = memread_head_ln467_z;
        5'h16: memwrite_regs_in_ln467_z[735:704] = memread_head_ln467_z;
        5'h17: memwrite_regs_in_ln467_z[767:736] = memread_head_ln467_z;
        5'h18: memwrite_regs_in_ln467_z[799:768] = memread_head_ln467_z;
        5'h19: memwrite_regs_in_ln467_z[831:800] = memread_head_ln467_z;
        5'h1a: memwrite_regs_in_ln467_z[863:832] = memread_head_ln467_z;
        5'h1b: memwrite_regs_in_ln467_z[895:864] = memread_head_ln467_z;
        5'h1c: memwrite_regs_in_ln467_z[927:896] = memread_head_ln467_z;
        5'h1d: memwrite_regs_in_ln467_z[959:928] = memread_head_ln467_z;
        5'h1e: memwrite_regs_in_ln467_z[991:960] = memread_head_ln467_z;
        5'h1f: memwrite_regs_in_ln467_z[1023:992] = memread_head_ln467_z;
        default: memwrite_regs_in_ln467_z = 32'hX;
      endcase
      memwrite_pop_ln468_z = {31'h0, mux_pop_ln468_0_z};
      memwrite_pop_ln468_z[mux_exit_mux_chunk_1_ln456_z] = 1'b1;
      case (1'b1)// synthesis parallel_case
        and_0_ln460_unr30_0_z: mux_regs_in_ln456_30_z = {
          memwrite_regs_in_ln461_unr1_0_z, memwrite_regs_in_ln461_unr2_0_z, 
          memwrite_regs_in_ln461_unr3_0_z, memwrite_regs_in_ln461_unr4_0_z, 
          memwrite_regs_in_ln461_unr5_0_z, memwrite_regs_in_ln461_unr6_0_z, 
          memwrite_regs_in_ln461_unr7_0_z, memwrite_regs_in_ln461_unr8_0_z, 
          memwrite_regs_in_ln461_unr9_0_z, memwrite_regs_in_ln461_unr10_0_z, 
          memwrite_regs_in_ln461_unr11_0_z, memwrite_regs_in_ln461_unr12_0_z, 
          memwrite_regs_in_ln461_unr13_0_z, memwrite_regs_in_ln461_unr14_0_z, 
          memwrite_regs_in_ln461_unr15_0_z, memwrite_regs_in_ln461_unr16_0_z, 
          memwrite_regs_in_ln461_unr17_0_z, memwrite_regs_in_ln461_unr18_0_z, 
          memwrite_regs_in_ln461_unr19_0_z, memwrite_regs_in_ln461_unr20_0_z, 
          memwrite_regs_in_ln461_unr21_0_z, memwrite_regs_in_ln461_unr22_0_z, 
          memwrite_regs_in_ln461_unr23_0_z, memwrite_regs_in_ln461_unr24_0_z, 
          memwrite_regs_in_ln461_unr25_0_z, memwrite_regs_in_ln461_unr26_0_z, 
          memwrite_regs_in_ln461_unr27_0_z, memwrite_regs_in_ln461_unr28_0_z, 
          memwrite_regs_in_ln461_unr29_0_z, memwrite_regs_in_ln461_unr30_0_z, 
          mux_regs_in_ln456_31_z};
        or_and_1_ln460_unr0_Z_0_z: mux_regs_in_ln456_30_z = 
          memwrite_regs_in_ln467_z;
        default: mux_regs_in_ln456_30_z = 1024'hX;
      endcase
      if (or_and_1_ln460_unr0_Z_0_z) 
        memread_pop_ln523_unr0_0_z = memwrite_pop_ln468_z;
      else 
        memread_pop_ln523_unr0_0_z = {31'h0, mux_pop_ln468_0_z};
      if (eq_ln445_unr30_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr30_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:992];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr30_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_in_ln456_30_z[1023:992];
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_160_d_0 = 
          mux_regs_in_ln456_30_z[223:160];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_160_d_0 = 
          mux_regs_in_ln456_30_q[223:160];
        default: mux_regs_in_ln456_30_160_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_224_d_0 = 
          mux_regs_in_ln456_30_z[287:224];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_224_d_0 = 
          mux_regs_in_ln456_30_q[287:224];
        default: mux_regs_in_ln456_30_224_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_288_d_0 = 
          mux_regs_in_ln456_30_z[351:288];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_288_d_0 = 
          mux_regs_in_ln456_30_q[351:288];
        default: mux_regs_in_ln456_30_288_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_32_d_0 = 
          mux_regs_in_ln456_30_z[95:32];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_32_d_0 = 
          mux_regs_in_ln456_30_q[95:32];
        default: mux_regs_in_ln456_30_32_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_352_d_0 = 
          mux_regs_in_ln456_30_z[415:352];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_352_d_0 = 
          mux_regs_in_ln456_30_q[415:352];
        default: mux_regs_in_ln456_30_352_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_416_d_0 = 
          mux_regs_in_ln456_30_z[479:416];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_416_d_0 = 
          mux_regs_in_ln456_30_q[479:416];
        default: mux_regs_in_ln456_30_416_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_480_d_0 = 
          mux_regs_in_ln456_30_z[543:480];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_480_d_0 = 
          mux_regs_in_ln456_30_q[543:480];
        default: mux_regs_in_ln456_30_480_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_544_d_0 = 
          mux_regs_in_ln456_30_z[607:544];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_544_d_0 = 
          mux_regs_in_ln456_30_q[607:544];
        default: mux_regs_in_ln456_30_544_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_608_d_0 = 
          mux_regs_in_ln456_30_z[671:608];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_608_d_0 = 
          mux_regs_in_ln456_30_q[671:608];
        default: mux_regs_in_ln456_30_608_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_672_d_0 = 
          mux_regs_in_ln456_30_z[735:672];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_672_d_0 = 
          mux_regs_in_ln456_30_q[735:672];
        default: mux_regs_in_ln456_30_672_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_736_d_0 = 
          mux_regs_in_ln456_30_z[799:736];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_736_d_0 = 
          mux_regs_in_ln456_30_q[799:736];
        default: mux_regs_in_ln456_30_736_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_800_d_0 = 
          mux_regs_in_ln456_30_z[863:800];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_800_d_0 = 
          mux_regs_in_ln456_30_q[863:800];
        default: mux_regs_in_ln456_30_800_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_864_d_0 = 
          mux_regs_in_ln456_30_z[927:864];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_864_d_0 = 
          mux_regs_in_ln456_30_q[927:864];
        default: mux_regs_in_ln456_30_864_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_928_d_0 = 
          mux_regs_in_ln456_30_z[991:928];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_928_d_0 = 
          mux_regs_in_ln456_30_q[991:928];
        default: mux_regs_in_ln456_30_928_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_96_d_0 = 
          mux_regs_in_ln456_30_z[159:96];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_96_d_0 = 
          mux_regs_in_ln456_30_q[159:96];
        default: mux_regs_in_ln456_30_96_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[8]: mux_regs_in_ln456_30_992_d_0 = 
          mux_regs_in_ln456_30_z[1023:992];
        mux_regs_in_ln456_30_32_mux_0_sel: mux_regs_in_ln456_30_992_d_0 = 
          mux_regs_in_ln456_30_q[1023:992];
        default: mux_regs_in_ln456_30_992_d_0 = 32'hX;
      endcase
      and_0_ln523_unr1_z = memread_pop_ln523_unr0_0_z[1] & !
      eq_ln445_unr0_Z_0_tag_0;
      and_0_ln523_unr10_z = memread_pop_ln523_unr0_0_z[10] & !
      eq_ln445_unr9_Z_0_tag_0;
      and_0_ln523_unr11_z = memread_pop_ln523_unr0_0_z[11] & !
      eq_ln445_unr10_Z_0_tag_0;
      and_0_ln523_unr12_z = memread_pop_ln523_unr0_0_z[12] & !
      eq_ln445_unr11_Z_0_tag_0;
      and_0_ln523_unr13_z = memread_pop_ln523_unr0_0_z[13] & !
      eq_ln445_unr12_Z_0_tag_0;
      and_0_ln523_unr14_z = memread_pop_ln523_unr0_0_z[14] & !
      eq_ln445_unr13_Z_0_tag_0;
      and_0_ln523_unr15_z = memread_pop_ln523_unr0_0_z[15] & !
      eq_ln445_unr14_Z_0_tag_0;
      and_0_ln523_unr16_z = memread_pop_ln523_unr0_0_z[16] & !
      eq_ln445_unr15_Z_0_tag_0;
      and_0_ln523_unr17_z = memread_pop_ln523_unr0_0_z[17] & !
      eq_ln445_unr16_Z_0_tag_0;
      and_0_ln523_unr18_z = memread_pop_ln523_unr0_0_z[18] & !
      eq_ln445_unr17_Z_0_tag_0;
      and_0_ln523_unr19_z = memread_pop_ln523_unr0_0_z[19] & !
      eq_ln445_unr18_Z_0_tag_0;
      and_0_ln523_unr2_z = memread_pop_ln523_unr0_0_z[2] & !
      eq_ln445_unr1_Z_0_tag_0;
      and_0_ln523_unr20_z = memread_pop_ln523_unr0_0_z[20] & !
      eq_ln445_unr19_Z_0_tag_0;
      and_0_ln523_unr21_z = memread_pop_ln523_unr0_0_z[21] & !
      eq_ln445_unr20_Z_0_tag_0;
      and_0_ln523_unr22_z = memread_pop_ln523_unr0_0_z[22] & !
      eq_ln445_unr21_Z_0_tag_0;
      and_0_ln523_unr23_z = memread_pop_ln523_unr0_0_z[23] & !
      eq_ln445_unr22_Z_0_tag_0;
      and_0_ln523_unr24_z = memread_pop_ln523_unr0_0_z[24] & !
      eq_ln445_unr23_Z_0_tag_0;
      and_0_ln523_unr25_z = memread_pop_ln523_unr0_0_z[25] & !
      eq_ln445_unr24_Z_0_tag_0;
      and_0_ln523_unr26_z = memread_pop_ln523_unr0_0_z[26] & !
      eq_ln445_unr25_Z_0_tag_0;
      and_0_ln523_unr27_z = memread_pop_ln523_unr0_0_z[27] & !
      eq_ln445_unr26_Z_0_tag_0;
      and_0_ln523_unr28_z = memread_pop_ln523_unr0_0_z[28] & !
      eq_ln445_unr27_Z_0_tag_0;
      and_0_ln523_unr29_z = memread_pop_ln523_unr0_0_z[29] & !
      eq_ln445_unr28_Z_0_tag_0;
      and_0_ln523_unr3_z = memread_pop_ln523_unr0_0_z[3] & !
      eq_ln445_unr2_Z_0_tag_0;
      and_0_ln523_unr30_z = memread_pop_ln523_unr0_0_z[30] & !
      eq_ln445_unr29_Z_0_tag_0;
      and_0_ln523_unr31_z = memread_pop_ln523_unr0_0_z[31] & !
      eq_ln445_unr30_Z_0_tag_0;
      and_0_ln523_unr4_z = memread_pop_ln523_unr0_0_z[4] & !
      eq_ln445_unr3_Z_0_tag_0;
      and_0_ln523_unr5_z = memread_pop_ln523_unr0_0_z[5] & !
      eq_ln445_unr4_Z_0_tag_0;
      and_0_ln523_unr6_z = memread_pop_ln523_unr0_0_z[6] & !
      eq_ln445_unr5_Z_0_tag_0;
      and_0_ln523_unr7_z = memread_pop_ln523_unr0_0_z[7] & !
      eq_ln445_unr6_Z_0_tag_0;
      and_0_ln523_unr8_z = memread_pop_ln523_unr0_0_z[8] & !
      eq_ln445_unr7_Z_0_tag_0;
      and_0_ln523_unr9_z = memread_pop_ln523_unr0_0_z[9] & !
      eq_ln445_unr8_Z_0_tag_0;
      if_ln523_unr0_z = ~memread_pop_ln523_unr0_0_z[0];
      if_ln523_unr1_z = ~memread_pop_ln523_unr0_0_z[1];
      if_ln523_unr10_z = ~memread_pop_ln523_unr0_0_z[10];
      if_ln523_unr11_z = ~memread_pop_ln523_unr0_0_z[11];
      if_ln523_unr12_z = ~memread_pop_ln523_unr0_0_z[12];
      if_ln523_unr13_z = ~memread_pop_ln523_unr0_0_z[13];
      if_ln523_unr14_z = ~memread_pop_ln523_unr0_0_z[14];
      if_ln523_unr15_z = ~memread_pop_ln523_unr0_0_z[15];
      if_ln523_unr16_z = ~memread_pop_ln523_unr0_0_z[16];
      if_ln523_unr17_z = ~memread_pop_ln523_unr0_0_z[17];
      if_ln523_unr18_z = ~memread_pop_ln523_unr0_0_z[18];
      if_ln523_unr19_z = ~memread_pop_ln523_unr0_0_z[19];
      if_ln523_unr2_z = ~memread_pop_ln523_unr0_0_z[2];
      if_ln523_unr20_z = ~memread_pop_ln523_unr0_0_z[20];
      if_ln523_unr21_z = ~memread_pop_ln523_unr0_0_z[21];
      if_ln523_unr22_z = ~memread_pop_ln523_unr0_0_z[22];
      if_ln523_unr23_z = ~memread_pop_ln523_unr0_0_z[23];
      if_ln523_unr24_z = ~memread_pop_ln523_unr0_0_z[24];
      if_ln523_unr25_z = ~memread_pop_ln523_unr0_0_z[25];
      if_ln523_unr26_z = ~memread_pop_ln523_unr0_0_z[26];
      if_ln523_unr27_z = ~memread_pop_ln523_unr0_0_z[27];
      if_ln523_unr28_z = ~memread_pop_ln523_unr0_0_z[28];
      if_ln523_unr29_z = ~memread_pop_ln523_unr0_0_z[29];
      if_ln523_unr3_z = ~memread_pop_ln523_unr0_0_z[3];
      if_ln523_unr30_z = ~memread_pop_ln523_unr0_0_z[30];
      if_ln523_unr31_z = ~memread_pop_ln523_unr0_0_z[31];
      if_ln523_unr4_z = ~memread_pop_ln523_unr0_0_z[4];
      if_ln523_unr5_z = ~memread_pop_ln523_unr0_0_z[5];
      if_ln523_unr6_z = ~memread_pop_ln523_unr0_0_z[6];
      if_ln523_unr7_z = ~memread_pop_ln523_unr0_0_z[7];
      if_ln523_unr8_z = ~memread_pop_ln523_unr0_0_z[8];
      if_ln523_unr9_z = ~memread_pop_ln523_unr0_0_z[9];
      or_and_0_ln521_Z_0_unr0_z = memread_pop_ln523_unr0_0_z[0] | 
      eq_ln485_unr0_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr1_z = memread_pop_ln523_unr0_0_z[1] | 
      eq_ln445_unr0_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr10_z = memread_pop_ln523_unr0_0_z[10] | 
      eq_ln445_unr9_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr11_z = memread_pop_ln523_unr0_0_z[11] | 
      eq_ln445_unr10_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr12_z = memread_pop_ln523_unr0_0_z[12] | 
      eq_ln445_unr11_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr13_z = memread_pop_ln523_unr0_0_z[13] | 
      eq_ln445_unr12_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr14_z = memread_pop_ln523_unr0_0_z[14] | 
      eq_ln445_unr13_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr15_z = memread_pop_ln523_unr0_0_z[15] | 
      eq_ln445_unr14_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr16_z = memread_pop_ln523_unr0_0_z[16] | 
      eq_ln445_unr15_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr17_z = memread_pop_ln523_unr0_0_z[17] | 
      eq_ln445_unr16_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr18_z = memread_pop_ln523_unr0_0_z[18] | 
      eq_ln445_unr17_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr19_z = memread_pop_ln523_unr0_0_z[19] | 
      eq_ln445_unr18_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr2_z = memread_pop_ln523_unr0_0_z[2] | 
      eq_ln445_unr1_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr20_z = memread_pop_ln523_unr0_0_z[20] | 
      eq_ln445_unr19_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr21_z = memread_pop_ln523_unr0_0_z[21] | 
      eq_ln445_unr20_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr22_z = memread_pop_ln523_unr0_0_z[22] | 
      eq_ln445_unr21_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr23_z = memread_pop_ln523_unr0_0_z[23] | 
      eq_ln445_unr22_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr24_z = memread_pop_ln523_unr0_0_z[24] | 
      eq_ln445_unr23_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr25_z = memread_pop_ln523_unr0_0_z[25] | 
      eq_ln445_unr24_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr26_z = memread_pop_ln523_unr0_0_z[26] | 
      eq_ln445_unr25_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr27_z = memread_pop_ln523_unr0_0_z[27] | 
      eq_ln445_unr26_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr28_z = memread_pop_ln523_unr0_0_z[28] | 
      eq_ln445_unr27_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr29_z = memread_pop_ln523_unr0_0_z[29] | 
      eq_ln445_unr28_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr3_z = memread_pop_ln523_unr0_0_z[3] | 
      eq_ln445_unr2_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr30_z = memread_pop_ln523_unr0_0_z[30] | 
      eq_ln445_unr29_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr31_z = memread_pop_ln523_unr0_0_z[31] | 
      eq_ln445_unr30_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr4_z = memread_pop_ln523_unr0_0_z[4] | 
      eq_ln445_unr3_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr5_z = memread_pop_ln523_unr0_0_z[5] | 
      eq_ln445_unr4_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr6_z = memread_pop_ln523_unr0_0_z[6] | 
      eq_ln445_unr5_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr7_z = memread_pop_ln523_unr0_0_z[7] | 
      eq_ln445_unr6_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr8_z = memread_pop_ln523_unr0_0_z[8] | 
      eq_ln445_unr7_Z_0_tag_0;
      or_and_0_ln521_Z_0_unr9_z = memread_pop_ln523_unr0_0_z[9] | 
      eq_ln445_unr8_Z_0_tag_0;
      and_0_ln523_unr0_z = memread_pop_ln523_unr0_0_z[0] & !
      eq_ln485_unr0_Z_0_tag_0;
      if (eq_ln445_unr29_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr29_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:960];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr29_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr30_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_z[991:960]};
      and_1_ln523_unr0_z = if_ln523_unr0_z & !eq_ln485_unr0_Z_0_tag_0;
      if (eq_ln445_unr28_Z_0_tag_0) 
        mux_regs_0_MERGE_SEQ_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        mux_regs_0_ln440_q[1023:928];
      else 
        mux_regs_0_MERGE_SEQ_for_exit_unr28_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z = 
        {
        mux_regs_0_MERGE_SEQ_for_exit_unr29_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0__z, 
        mux_regs_in_ln456_30_z[959:928]};
      and_1_ln523_unr1_0_z = if_ln523_unr1_z & !eq_ln445_unr0_Z_0_tag_0 & 
      and_1_ln523_unr0_z;
      and_0_ln521_unr1_z = or_and_0_ln521_Z_0_unr1_z & and_1_ln523_unr0_z;
      and_1_ln523_unr2_0_z = if_ln523_unr2_z & !eq_ln445_unr1_Z_0_tag_0 & 
      and_1_ln523_unr1_0_z;
      and_0_ln521_unr2_z = or_and_0_ln521_Z_0_unr2_z & and_1_ln523_unr1_0_z;
      and_1_ln523_unr3_0_z = if_ln523_unr3_z & !eq_ln445_unr2_Z_0_tag_0 & 
      and_1_ln523_unr2_0_z;
      and_0_ln521_unr3_z = or_and_0_ln521_Z_0_unr3_z & and_1_ln523_unr2_0_z;
      and_1_ln523_unr4_0_z = if_ln523_unr4_z & !eq_ln445_unr3_Z_0_tag_0 & 
      and_1_ln523_unr3_0_z;
      and_0_ln521_unr4_z = or_and_0_ln521_Z_0_unr4_z & and_1_ln523_unr3_0_z;
      and_1_ln523_unr5_0_z = if_ln523_unr5_z & !eq_ln445_unr4_Z_0_tag_0 & 
      and_1_ln523_unr4_0_z;
      and_0_ln521_unr5_z = or_and_0_ln521_Z_0_unr5_z & and_1_ln523_unr4_0_z;
      and_1_ln523_unr6_0_z = if_ln523_unr6_z & !eq_ln445_unr5_Z_0_tag_0 & 
      and_1_ln523_unr5_0_z;
      and_0_ln521_unr6_z = or_and_0_ln521_Z_0_unr6_z & and_1_ln523_unr5_0_z;
      and_1_ln523_unr7_0_z = if_ln523_unr7_z & !eq_ln445_unr6_Z_0_tag_0 & 
      and_1_ln523_unr6_0_z;
      and_0_ln521_unr7_z = or_and_0_ln521_Z_0_unr7_z & and_1_ln523_unr6_0_z;
      and_1_ln523_unr8_0_z = if_ln523_unr8_z & !eq_ln445_unr7_Z_0_tag_0 & 
      and_1_ln523_unr7_0_z;
      and_0_ln521_unr8_z = or_and_0_ln521_Z_0_unr8_z & and_1_ln523_unr7_0_z;
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_merge_sort[0]: // Wait_ln346
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln346_z: state_sort_unisim_sort_merge_sort_next[0] = 
                1'b1;
              ctrlAnd_1_ln346_z: state_sort_unisim_sort_merge_sort_next[1] = 
                1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[1]: // expand_ln357
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln376_z: state_sort_unisim_sort_merge_sort_next[2] = 1'b1;
              ctrlOr_ln379_z: state_sort_unisim_sort_merge_sort_next[3] = 1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[2]: // Wait_ln376
          state_sort_unisim_sort_merge_sort_next[2] = 1'b1;
        state_sort_unisim_sort_merge_sort[3]: // Wait_ln379
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln379_z: state_sort_unisim_sort_merge_sort_next[3] = 1'b1;
              ctrlOr_ln382_z: state_sort_unisim_sort_merge_sort_next[4] = 1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[4]: // Wait_ln382
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln382_z: state_sort_unisim_sort_merge_sort_next[4] = 1'b1;
              ctrlAnd_0_ln387_z: state_sort_unisim_sort_merge_sort_next[5] = 
                1'b1;
              ctrlAnd_1_ln387_z: state_sort_unisim_sort_merge_sort_next[16] = 
                1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[5]: // expand_ln406
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln407_z: state_sort_unisim_sort_merge_sort_next[6] = 
                1'b1;
              ctrlAnd_1_ln407_z: state_sort_unisim_sort_merge_sort_next[15] = 
                1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[6]: // Wait_ln424
          state_sort_unisim_sort_merge_sort_next[7] = 1'b1;
        state_sort_unisim_sort_merge_sort[7]: // expand_ln440
          state_sort_unisim_sort_merge_sort_next[8] = 1'b1;
        state_sort_unisim_sort_merge_sort[8]: // expand_ln440_0
          state_sort_unisim_sort_merge_sort_next[9] = 1'b1;
        state_sort_unisim_sort_merge_sort[9]: // expand_ln440_2
          state_sort_unisim_sort_merge_sort_next[10] = 1'b1;
        state_sort_unisim_sort_merge_sort[10]: // expand_ln440_1
          state_sort_unisim_sort_merge_sort_next[11] = 1'b1;
        state_sort_unisim_sort_merge_sort[11]: // Wait_ln562
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln592_z: state_sort_unisim_sort_merge_sort_next[12] = 1'b1;
              ctrlAnd_1_ln564_z: state_sort_unisim_sort_merge_sort_next[14] = 
                1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[12]: // Wait_ln592
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln592_z: state_sort_unisim_sort_merge_sort_next[12] = 1'b1;
              ctrlOr_ln595_z: state_sort_unisim_sort_merge_sort_next[13] = 1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[13]: // Wait_ln595
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln595_z: state_sort_unisim_sort_merge_sort_next[13] = 1'b1;
              ctrlOr_ln376_z: state_sort_unisim_sort_merge_sort_next[2] = 1'b1;
              ctrlOr_ln379_z: state_sort_unisim_sort_merge_sort_next[3] = 1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[14]: // expand_ln440_3
          state_sort_unisim_sort_merge_sort_next[8] = 1'b1;
        state_sort_unisim_sort_merge_sort[15]: // Wait_ln415
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln407_z: state_sort_unisim_sort_merge_sort_next[6] = 
                1'b1;
              ctrlAnd_1_ln407_z: state_sort_unisim_sort_merge_sort_next[15] = 
                1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[16]: // expand_ln570
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln592_z: state_sort_unisim_sort_merge_sort_next[12] = 1'b1;
              ctrlAnd_1_ln571_z: state_sort_unisim_sort_merge_sort_next[17] = 
                1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        state_sort_unisim_sort_merge_sort[17]: // expand_ln574
          state_sort_unisim_sort_merge_sort_next[18] = 1'b1;
        state_sort_unisim_sort_merge_sort[18]: // expand_ln581
          state_sort_unisim_sort_merge_sort_next[19] = 1'b1;
        state_sort_unisim_sort_merge_sort[19]: // Wait_ln581
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln574_z: state_sort_unisim_sort_merge_sort_next[18] = 1'b1;
              ctrlOr_ln592_z: state_sort_unisim_sort_merge_sort_next[12] = 1'b1;
              ctrlAnd_1_ln571_z: state_sort_unisim_sort_merge_sort_next[17] = 
                1'b1;
              default: state_sort_unisim_sort_merge_sort_next = 20'hX;
            endcase
          end
        default: // Don't care
          state_sort_unisim_sort_merge_sort_next = 20'hX;
      endcase
    end
  sort_unisim_identity_sync_read_1024x32m0 A0_bridge1(.rtl_CE(
                                           A0_bridge1_rtl_CE_en), .rtl_A(
                                           A0_bridge1_rtl_a), .mem_Q(A0_Q1), .CLK(
                                           clk), .mem_CE(A0_CE1), .mem_A(A0_A1), 
                                           .rtl_Q(A0_bridge1_rtl_Q));
  sort_unisim_identity_sync_read_1024x32m0 A1_bridge1(.rtl_CE(
                                           A1_bridge1_rtl_CE_en), .rtl_A(
                                           A1_bridge1_rtl_a), .mem_Q(A1_Q1), .CLK(
                                           clk), .mem_CE(A1_CE1), .mem_A(A1_A1), 
                                           .rtl_Q(A1_bridge1_rtl_Q));
  sort_unisim_identity_sync_write_1024x32m0 C0_bridge0(.rtl_CE(
                                            C0_bridge0_rtl_CE_en), .rtl_A(
                                            C0_bridge0_rtl_a), .rtl_D(
                                            C0_bridge0_rtl_d), .rtl_WE(
                                            C0_bridge0_rtl_CE_en), .CLK(clk), .mem_CE(
                                            C0_CE0), .mem_A(C0_A0), .mem_D(C0_D0), 
                                            .mem_WE(C0_WE0));
  sort_unisim_identity_sync_write_1024x32m0 C1_bridge0(.rtl_CE(
                                            C1_bridge0_rtl_CE_en), .rtl_A(
                                            C1_bridge0_rtl_a), .rtl_D(
                                            C1_bridge0_rtl_d), .rtl_WE(
                                            C1_bridge0_rtl_CE_en), .CLK(clk), .mem_CE(
                                            C1_CE0), .mem_A(C1_A0), .mem_D(C1_D0), 
                                            .mem_WE(C1_WE0));
  // synthesis sync_set_reset_local sort_unisim_sort_rb_sort_seq_block rst
  always @(posedge clk) // sort_unisim_sort_rb_sort_sequential
    begin : sort_unisim_sort_rb_sort_seq_block
      if (!rst) // Initialize state and outputs
      begin
        rb_start <= 1'sb0;
        rb_done <= 1'sb0;
        mux_pipe_full_ln248_Z_0_tag_0 <= 1'sb0;
        mux_ping_ln228_q <= 1'sb0;
        state_sort_unisim_sort_rb_sort <= 22'h1;
      end
      else // Update Q values
      begin
        rb_start <= rb_start_d;
        rb_done <= rb_done_d;
        mux_pipe_full_ln248_Z_0_tag_0 <= mux_pipe_full_ln248_Z_0_tag_d;
        mux_ping_ln228_q <= mux_ping_ln228_d;
        state_sort_unisim_sort_rb_sort <= state_sort_unisim_sort_rb_sort_next;
      end
    end
  always @(posedge clk) // sort_unisim_sort_rb_sort_0_sequential
    begin
      mux_regs_ln260_q <= mux_regs_ln260_z;
      mux_i_2_ln317_q <= mux_i_2_ln317_z[0];
      mux_k_ln280_unr0_q <= mux_k_ln280_unr0_z[0];
      mux_k_ln280_unr1_q <= mux_k_ln280_unr1_z[0];
      mux_wchunk_ln248_reg_0_0 <= mux_wchunk_ln248_z;
      memwrite_regs_ln273_unr1_q <= memwrite_regs_ln273_unr1_z;
      add_ln317_1_q <= add_ln317_z[5:1];
      add_ln266_1_unr1_q <= add_ln266_1_unr1_z;
      add_ln270_1_unr1_q <= add_ln270_1_unr1_z;
      memread_regs_ln266_unr1_q <= memread_regs_ln266_unr1_z;
      add_ln264_unr1_q <= add_ln264_unr1_z;
      add_ln280_unr0_1_q <= add_ln280_unr0_z[5:1];
      add_ln280_unr1_1_q <= add_ln280_unr1_z[5:1];
      mux_regs_ln260_0_q <= {mux_regs_ln260_0_960_d_0, mux_regs_ln260_0_896_d_0, 
      mux_regs_ln260_0_832_d_0, mux_regs_ln260_0_768_d_0, 
      mux_regs_ln260_0_704_d_0, mux_regs_ln260_0_640_d_0, 
      mux_regs_ln260_0_576_d_0, mux_regs_ln260_0_512_d_0, 
      mux_regs_ln260_0_448_d_0, mux_regs_ln260_0_384_d_0, 
      mux_regs_ln260_0_320_d_0, mux_regs_ln260_0_256_d_0, 
      mux_regs_ln260_0_192_d_0, mux_regs_ln260_0_128_d_0, 
      mux_regs_ln260_0_64_d_0, mux_regs_ln260_0_d};
      memwrite_regs_ln273_unr0_q <= {memwrite_regs_ln273_unr0_960_d_0, 
      memwrite_regs_ln273_unr0_896_d_0, memwrite_regs_ln273_unr0_832_d_0, 
      memwrite_regs_ln273_unr0_768_d_0, memwrite_regs_ln273_unr0_704_d_0, 
      memwrite_regs_ln273_unr0_640_d_0, memwrite_regs_ln273_unr0_576_d_0, 
      memwrite_regs_ln273_unr0_512_d_0, memwrite_regs_ln273_unr0_448_d_0, 
      memwrite_regs_ln273_unr0_384_d_0, memwrite_regs_ln273_unr0_320_d_0, 
      memwrite_regs_ln273_unr0_256_d_0, memwrite_regs_ln273_unr0_192_d_0, 
      memwrite_regs_ln273_unr0_128_d_0, memwrite_regs_ln273_unr0_64_d_0, 
      memwrite_regs_ln273_unr0_d};
      mux_i_ln260_unr0_q <= {mux_i_ln260_unr0_z[4:1], mux_i_ln260_unr0_d[0]};
      add_ln260_unr0_1_q <= mux_i_ln260_unr0_d[5:1];
      mux_i_ln260_unr1_q <= {mux_i_ln260_unr1_z[5], mux_i_ln260_unr1_1_d_0, 
      mux_i_ln260_unr1_d[0]};
      add_ln260_unr1_1_q <= mux_i_ln260_unr1_d[5:1];
      memread_regs_ln284_unr1_unr1_0_q <= memread_regs_ln284_unr1_unr1_0_z[31:0];
      memread_regs_ln294_unr0_unr1_0_32_q <= memread_regs_ln294_unr0_unr1_0_z[63:
      32];
      memread_regs_ln294_unr0_unr0_0_32_q <= memread_regs_ln284_unr1_unr0_0_d[63:
      32];
      memread_regs_ln284_unr1_unr0_0_q <= memread_regs_ln284_unr1_unr0_0_d[31:0];
      mux_regs_ln280_0_q <= mux_regs_ln280_0_z;
      mux_regs_ln254_0_q <= mux_regs_ln254_0_z;
      mux_regs_ln254_1_q <= mux_regs_ln254_1_z;
      mux_regs_ln280_2_q <= mux_regs_ln280_2_z;
      mux_regs_ln228_q <= {mux_regs_ln228_1984_d_0, mux_regs_ln228_1920_d_0, 
      mux_regs_ln228_1856_d_0, mux_regs_ln228_1792_d_0, mux_regs_ln228_1728_d_0, 
      mux_regs_ln228_1664_d_0, mux_regs_ln228_1600_d_0, mux_regs_ln228_1536_d_0, 
      mux_regs_ln228_1472_d_0, mux_regs_ln228_1408_d_0, mux_regs_ln228_1344_d_0, 
      mux_regs_ln228_1280_d_0, mux_regs_ln228_1216_d_0, mux_regs_ln228_1152_d_0, 
      mux_regs_ln228_1088_d_0, mux_regs_ln228_1024_d_0, mux_regs_ln228_960_d_0, 
      mux_regs_ln228_896_d_0, mux_regs_ln228_832_d_0, mux_regs_ln228_768_d_0, 
      mux_regs_ln228_704_d_0, mux_regs_ln228_640_d_0, mux_regs_ln228_576_d_0, 
      mux_regs_ln228_512_d_0, mux_regs_ln228_448_d_0, mux_regs_ln228_384_d_0, 
      mux_regs_ln228_320_d_0, mux_regs_ln228_256_d_0, mux_regs_ln228_192_d_0, 
      mux_regs_ln228_128_d_0, mux_regs_ln228_64_d_0, mux_regs_ln228_d};
      mux_idx_0_ln312_q <= mux_idx_0_ln312_d_0[0];
      mux_wchunk_ln312_q <= mux_idx_0_ln312_d_0[5:1];
      add_ln324_1_q <= mux_idx_0_ln312_d_0[9:6];
      mux_regs_ln260_1_q <= mux_regs_ln260_1_d;
      memread_regs_ln294_unr1_unr1_0_q <= memread_regs_ln294_unr1_unr1_0_z;
      memread_regs_ln294_unr2_unr1_0_q <= memread_regs_ln294_unr2_unr1_0_z;
      memread_regs_ln294_unr3_unr1_0_q <= memread_regs_ln294_unr3_unr1_0_z;
      memread_regs_ln294_unr4_unr1_0_q <= memread_regs_ln294_unr4_unr1_0_z;
      memread_regs_ln294_unr5_unr1_0_q <= memread_regs_ln294_unr5_unr1_0_z;
      memread_regs_ln294_unr6_unr1_0_q <= memread_regs_ln294_unr6_unr1_0_z;
      memread_regs_ln294_unr7_unr1_0_q <= memread_regs_ln294_unr7_unr1_0_z;
      memread_regs_ln294_unr8_unr1_0_q <= memread_regs_ln294_unr8_unr1_0_z;
      memread_regs_ln294_unr9_unr1_0_q <= memread_regs_ln294_unr9_unr1_0_z;
      memread_regs_ln294_unr10_unr1_0_q <= memread_regs_ln294_unr10_unr1_0_z;
      memread_regs_ln294_unr11_unr1_0_q <= memread_regs_ln294_unr11_unr1_0_z;
      memread_regs_ln294_unr12_unr1_0_q <= memread_regs_ln294_unr12_unr1_0_z;
      memread_regs_ln294_unr13_unr1_0_q <= memread_regs_ln294_unr13_unr1_0_z;
      memread_regs_ln294_unr14_unr1_0_q <= memread_regs_ln294_unr14_unr1_0_z;
      add_ln276_unr0_q <= add_ln276_unr0_d[4:0];
      mux_wchunk_ln248_q <= mux_chunk_ln248_2_d_0[7:3];
      add_ln276_unr1_q <= mux_chunk_ln248_d[36:32];
      mux_chunk_ln248_q <= {mux_chunk_ln248_2_d_0[2:0], mux_chunk_ln248_d[1:0]};
      add_ln254_0_unr1_1_q <= mux_chunk_ln248_d[31:2];
      eq_ln255_unr1_q <= add_ln254_0_unr0_1_4_d_0[27];
      add_ln254_0_unr0_1_q <= {add_ln254_0_unr0_1_4_d_0[26:0], add_ln276_unr0_d[
      8:5]};
      memread_regs_ln294_unr1_unr0_0_q <= memread_regs_ln294_unr1_unr0_0_d;
      memread_regs_ln294_unr2_unr0_0_q <= memread_regs_ln294_unr2_unr0_0_d;
      memread_regs_ln294_unr12_unr0_0_q <= memread_regs_ln294_unr12_unr0_0_d;
      memread_regs_ln294_unr13_unr0_0_q <= memread_regs_ln294_unr13_unr0_0_d;
      memread_regs_ln294_unr14_unr0_0_q <= memread_regs_ln294_unr14_unr0_0_d;
      memread_regs_ln294_unr3_unr0_0_q <= memread_regs_ln294_unr3_unr0_0_d;
      memread_regs_ln294_unr4_unr0_0_q <= memread_regs_ln294_unr4_unr0_0_d;
      memread_regs_ln294_unr5_unr0_0_q <= memread_regs_ln294_unr5_unr0_0_d;
      memread_regs_ln294_unr6_unr0_0_q <= memread_regs_ln294_unr6_unr0_0_d;
      memread_regs_ln294_unr7_unr0_0_q <= memread_regs_ln294_unr7_unr0_0_d;
      memread_regs_ln294_unr8_unr0_0_q <= memread_regs_ln294_unr8_unr0_0_d;
      memread_regs_ln294_unr9_unr0_0_q <= memread_regs_ln294_unr9_unr0_0_d;
      memread_regs_ln294_unr10_unr0_0_q <= memread_regs_ln294_unr10_unr0_0_d;
      memread_regs_ln294_unr11_unr0_0_q <= memread_regs_ln294_unr11_unr0_0_d;
      mux_regs_ln248_reg_0_0 <= {mux_regs_ln248_reg_0_960_d_0, 
      mux_regs_ln248_reg_0_896_d_0, mux_regs_ln248_reg_0_832_d_0, 
      mux_regs_ln248_reg_0_768_d_0, mux_regs_ln248_reg_0_704_d_0, 
      mux_regs_ln248_reg_0_640_d_0, mux_regs_ln248_reg_0_576_d_0, 
      mux_regs_ln248_reg_0_512_d_0, mux_regs_ln248_reg_0_448_d_0, 
      mux_regs_ln248_reg_0_384_d_0, mux_regs_ln248_reg_0_320_d_0, 
      mux_regs_ln248_reg_0_256_d_0, mux_regs_ln248_reg_0_192_d_0, 
      mux_regs_ln248_reg_0_128_d_0, mux_regs_ln248_reg_0_64_d_0, 
      mux_regs_ln248_reg_0_d};
      mux_burst_ln228_q <= mux_burst_ln228_d_0[0];
      add_ln334_1_q <= mux_burst_ln228_d_0[31:1];
      mux_regs_ln248_q <= {mux_regs_ln248_1984_d_0, mux_regs_ln248_1920_d_0, 
      mux_regs_ln248_1856_d_0, mux_regs_ln248_1792_d_0, mux_regs_ln248_1728_d_0, 
      mux_regs_ln248_1664_d_0, mux_regs_ln248_1600_d_0, mux_regs_ln248_1536_d_0, 
      mux_regs_ln248_1472_d_0, mux_regs_ln248_1408_d_0, mux_regs_ln248_1344_d_0, 
      mux_regs_ln248_1280_d_0, mux_regs_ln248_1216_d_0, mux_regs_ln248_1152_d_0, 
      mux_regs_ln248_1088_d_0, mux_regs_ln248_1024_d_0, mux_regs_ln248_z[1023:0]};
      read_sort_len_ln224_q <= read_sort_len_ln224_d[31:0];
      read_sort_batch_ln225_q <= read_sort_len_ln224_d[63:32];
    end
  sort_unisim_lt_float sort_unisim_lt_float(.in0_in(mux_regs_ln280_z[31:0]), .in1_in(
                       mux_regs_ln280_z[63:32]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr0_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_0(.in0_in(mux_regs_ln280_z[95:64]), 
                       .in1_in(mux_regs_ln280_z[127:96]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr1_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_1(.in0_in(mux_regs_ln280_z[159:128]), 
                       .in1_in(mux_regs_ln280_z[191:160]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr2_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_10(.in0_in(mux_regs_ln280_z[735:704]), 
                       .in1_in(mux_regs_ln280_z[767:736]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr11_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_11(.in0_in(mux_regs_ln280_z[799:768]), 
                       .in1_in(mux_regs_ln280_z[831:800]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr12_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_12(.in0_in(mux_regs_ln280_z[863:832]), 
                       .in1_in(mux_regs_ln280_z[895:864]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr13_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_13(.in0_in(mux_regs_ln280_z[927:896]), 
                       .in1_in(mux_regs_ln280_z[959:928]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr14_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_14(.in0_in(mux_regs_ln280_z[991:960]), 
                       .in1_in(mux_regs_ln280_z[1023:992]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr15_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_2(.in0_in(mux_regs_ln280_z[223:192]), 
                       .in1_in(mux_regs_ln280_z[255:224]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr3_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_3(.in0_in(mux_regs_ln280_z[287:256]), 
                       .in1_in(mux_regs_ln280_z[319:288]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr4_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_4(.in0_in(mux_regs_ln280_z[351:320]), 
                       .in1_in(mux_regs_ln280_z[383:352]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr5_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_5(.in0_in(mux_regs_ln280_z[415:384]), 
                       .in1_in(mux_regs_ln280_z[447:416]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr6_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_6(.in0_in(mux_regs_ln280_z[479:448]), 
                       .in1_in(mux_regs_ln280_z[511:480]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr7_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_7(.in0_in(mux_regs_ln280_z[543:512]), 
                       .in1_in(mux_regs_ln280_z[575:544]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr8_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_8(.in0_in(mux_regs_ln280_z[607:576]), 
                       .in1_in(mux_regs_ln280_z[639:608]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr9_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_9(.in0_in(mux_regs_ln280_z[671:640]), 
                       .in1_in(mux_regs_ln280_z[703:672]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr10_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_30(.in0_in(mux_regs_ln280_1_z[31:0]), 
                       .in1_in(mux_regs_ln280_1_z[63:32]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr0_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_31(.in0_in(mux_regs_ln280_1_z[95:64]), 
                       .in1_in(mux_regs_ln280_1_z[127:96]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr1_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_32(.in0_in(mux_regs_ln280_1_z[159:
                       128]), .in1_in(mux_regs_ln280_1_z[191:160]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr2_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_33(.in0_in(mux_regs_ln280_1_z[223:
                       192]), .in1_in(mux_regs_ln280_1_z[255:224]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr3_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_34(.in0_in(mux_regs_ln280_1_z[287:
                       256]), .in1_in(mux_regs_ln280_1_z[319:288]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr4_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_35(.in0_in(mux_regs_ln280_1_z[351:
                       320]), .in1_in(mux_regs_ln280_1_z[383:352]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr5_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_36(.in0_in(mux_regs_ln280_1_z[415:
                       384]), .in1_in(mux_regs_ln280_1_z[447:416]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr6_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_37(.in0_in(mux_regs_ln280_1_z[479:
                       448]), .in1_in(mux_regs_ln280_1_z[511:480]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr7_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_38(.in0_in(mux_regs_ln280_1_z[543:
                       512]), .in1_in(mux_regs_ln280_1_z[575:544]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr8_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_39(.in0_in(mux_regs_ln280_1_z[607:
                       576]), .in1_in(mux_regs_ln280_1_z[639:608]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr9_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_40(.in0_in(mux_regs_ln280_1_z[671:
                       640]), .in1_in(mux_regs_ln280_1_z[703:672]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr10_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_41(.in0_in(mux_regs_ln280_1_z[735:
                       704]), .in1_in(mux_regs_ln280_1_z[767:736]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr11_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_42(.in0_in(mux_regs_ln280_1_z[799:
                       768]), .in1_in(mux_regs_ln280_1_z[831:800]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr12_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_43(.in0_in(mux_regs_ln280_1_z[863:
                       832]), .in1_in(mux_regs_ln280_1_z[895:864]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr13_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_44(.in0_in(mux_regs_ln280_1_z[927:
                       896]), .in1_in(mux_regs_ln280_1_z[959:928]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr14_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_45(.in0_in(mux_regs_ln280_1_z[991:
                       960]), .in1_in(mux_regs_ln280_1_z[1023:992]), .lt_float_out(
                       sort_unisim_lt_float_ln284_unr15_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_15(.in0_in(
                       memread_regs_ln284_unr1_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr2_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr0_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_16(.in0_in(
                       memread_regs_ln284_unr2_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr3_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr1_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_26(.in0_in(
                       memread_regs_ln284_unr12_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr13_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr11_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_27(.in0_in(
                       memread_regs_ln284_unr13_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr14_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr12_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_28(.in0_in(
                       memread_regs_ln284_unr14_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr15_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr13_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_29(.in0_in(
                       memread_regs_ln284_unr15_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln294_unr0_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr14_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_17(.in0_in(
                       memread_regs_ln284_unr3_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr4_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr2_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_18(.in0_in(
                       memread_regs_ln284_unr4_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr5_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr3_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_19(.in0_in(
                       memread_regs_ln284_unr5_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr6_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr4_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_20(.in0_in(
                       memread_regs_ln284_unr6_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr7_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr5_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_21(.in0_in(
                       memread_regs_ln284_unr7_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr8_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr6_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_22(.in0_in(
                       memread_regs_ln284_unr8_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr9_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr7_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_23(.in0_in(
                       memread_regs_ln284_unr9_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr10_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr8_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_24(.in0_in(
                       memread_regs_ln284_unr10_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr11_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr9_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_25(.in0_in(
                       memread_regs_ln284_unr11_unr0_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr12_unr0_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr10_unr0_z));
  sort_unisim_lt_float sort_unisim_lt_float_46(.in0_in(
                       memread_regs_ln284_unr1_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr2_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr0_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_47(.in0_in(
                       memread_regs_ln284_unr2_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr3_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr1_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_48(.in0_in(
                       memread_regs_ln284_unr3_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr4_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr2_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_49(.in0_in(
                       memread_regs_ln284_unr4_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr5_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr3_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_50(.in0_in(
                       memread_regs_ln284_unr5_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr6_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr4_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_51(.in0_in(
                       memread_regs_ln284_unr6_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr7_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr5_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_52(.in0_in(
                       memread_regs_ln284_unr7_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr8_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr6_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_53(.in0_in(
                       memread_regs_ln284_unr8_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr9_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr7_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_54(.in0_in(
                       memread_regs_ln284_unr9_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr10_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr8_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_55(.in0_in(
                       memread_regs_ln284_unr10_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr11_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr9_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_56(.in0_in(
                       memread_regs_ln284_unr11_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr12_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr10_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_57(.in0_in(
                       memread_regs_ln284_unr12_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr13_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr11_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_58(.in0_in(
                       memread_regs_ln284_unr13_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr14_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr12_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_59(.in0_in(
                       memread_regs_ln284_unr14_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln284_unr15_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr13_unr1_z));
  sort_unisim_lt_float sort_unisim_lt_float_60(.in0_in(
                       memread_regs_ln284_unr15_unr1_0_z[63:32]), .in1_in(
                       memread_regs_ln294_unr0_unr1_0_z[31:0]), .lt_float_out(
                       sort_unisim_lt_float_ln294_unr14_unr1_z));
  always @(*) begin : sort_unisim_sort_rb_sort_combinational
      reg RB_RW_CHUNK_for_begin_unr0_or_0;
      reg RB_W_LAST_CHUNKS_INNER_for_begin_or_0;
      reg ctrlAnd_1_ln260_unr0_z;
      reg ctrlAnd_1_ln280_unr0_z;
      reg ctrlAnd_1_ln260_unr1_z;
      reg ctrlAnd_1_ln280_unr1_z;
      reg ctrlAnd_1_ln317_z;
      reg ctrlOr_ln260_unr1_z;
      reg [4:0] mux_exit_mux_wchunk_ln254_z;
      reg [1087:0] mux_regs_ln254_z;
      reg ctrlAnd_0_ln260_unr0_z;
      reg ctrlAnd_0_ln280_unr0_z;
      reg ctrlAnd_0_ln280_unr1_z;
      reg ctrlAnd_0_ln317_z;
      reg ctrlAnd_1_ln218_z;
      reg ctrlAnd_0_ln218_z;
      reg ctrlAnd_1_ln234_z;
      reg ctrlAnd_0_ln234_z;
      reg ctrlAnd_1_ln237_z;
      reg ctrlAnd_0_ln237_z;
      reg ctrlAnd_0_ln255_unr1_z;
      reg ctrlAnd_0_ln260_unr1_z;
      reg ctrlAnd_1_ln328_z;
      reg ctrlAnd_0_ln328_z;
      reg ctrlAnd_1_ln331_z;
      reg ctrlAnd_0_ln331_z;
      reg ctrlAnd_1_ln255_unr1_z;
      reg ctrlOr_ln312_0_z;
      reg [2047:0] mux_regs_ln228_z;
      reg mux_pipe_full_ln248_z;
      reg [1023:0] mux_regs_ln260_0_z;
      reg [31:0] mux_elem_ln263_unr0_z;
      reg [31:0] mux_elem_ln263_unr1_z;
      reg mux_ping_ln228_z;
      reg [31:0] mux_burst_ln228_z;
      reg [31:0] mux_exit_mux_chunk_ln254_z;
      reg [1:0] mux_idx_0_ln312_z;
      reg [4:0] mux_wchunk_ln312_z;
      reg ctrlOr_ln260_unr0_z;
      reg ctrlOr_ln280_unr0_z;
      reg ctrlOr_ln280_unr1_z;
      reg ctrlOr_ln317_z;
      reg rb_start_hold;
      reg ctrlOr_ln237_z;
      reg ctrlOr_ln254_z;
      reg memread_sort_A0_ln264_unr1_en;
      reg memread_sort_A1_ln268_unr1_en;
      reg memwrite_sort_C0_ln266_unr1_en;
      reg memwrite_sort_C1_ln270_unr1_en;
      reg mux_i_ln260_unr1_sel;
      reg mux_regs_ln260_0_sel;
      reg ctrlOr_ln228_z;
      reg ctrlOr_ln331_z;
      reg [63:0] mux_mux_regs_ln228_Z_1088_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1152_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1216_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1280_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_128_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1344_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1408_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1472_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1536_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1600_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1664_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1728_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1792_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1856_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1920_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_192_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_1984_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_256_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_320_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_384_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_448_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_512_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_576_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_640_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_64_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_704_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_768_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_832_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_896_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_960_v_0;
      reg [63:0] mux_mux_regs_ln228_Z_v;
      reg [63:0] mux_mux_regs_ln228_Z_1024_v_0;
      reg [1023:0] memwrite_regs_ln273_unr0_z;
      reg mux_mux_ping_ln228_Z_0_v;
      reg unary_nor_ln335_z;
      reg eq_ln230_z;
      reg mux_mux_burst_ln228_Z_0_v;
      reg [31:0] add_ln334_z;
      reg [31:0] mux_chunk_ln248_z;
      reg [31:0] memread_regs_ln319_z;
      reg [5:0] add_ln260_unr0_z;
      reg [31:0] memread_regs_ln266_unr0_z;
      reg [5:0] add_ln260_unr1_z;
      reg lt_ln312_z;
      reg xor_ln312_z;
      reg eq_ln313_z;
      reg [4:0] add_ln324_z;
      reg [4:0] add_ln276_unr0_z;
      reg memread_sort_A0_ln264_unr0_en;
      reg memread_sort_A1_ln268_unr0_en;
      reg memwrite_sort_C0_ln266_unr0_en;
      reg memwrite_sort_C1_ln270_unr0_en;
      reg mux_chunk_ln248_2_mux_0_sel;
      reg mux_pipe_full_ln248_Z_0_tag_sel;
      reg add_ln254_0_unr0_1_4_mux_0_sel;
      reg memread_regs_ln284_unr1_unr0_0_sel;
      reg mux_chunk_ln248_sel;
      reg memwrite_sort_C0_ln319_en;
      reg memwrite_sort_C1_ln321_en;
      reg mux_regs_ln228_sel;
      reg ctrlOr_ln248_0_z;
      reg [30:0] mux_add_ln334_Z_1_v_0;
      reg [31:0] add_ln254_0_unr0_z;
      reg eq_ln249_z;
      reg lt_ln248_0_z;
      reg [30:0] add_ln254_0_unr1_z;
      reg or_and_0_ln313_Z_0_z;
      reg if_ln313_z;
      reg [4:0] add_ln276_unr1_z;
      reg ctrlAnd_1_ln230_z;
      reg ctrlAnd_0_ln230_z;
      reg eq_ln255_unr1_z;
      reg if_ln249_z;
      reg lt_ln248_z;
      reg ctrlAnd_0_ln313_z;
      reg and_1_ln313_z;
      reg ctrlOr_ln234_z;
      reg ctrlOr_ln232_z;
      reg if_ln255_unr1_z;
      reg if_ln248_z;
      reg and_1_ln255_unr0_z;
      reg rb_done_hold;
      reg ctrlOr_ln328_z;
      reg ctrlAnd_1_ln313_z;
      reg [63:0] mux_regs_ln260_1_z;
      reg or_and_0_ln249_Z_0_z;
      reg ctrlAnd_1_ln255_unr0_z;
      reg mux_regs_ln248_1024_mux_0_sel_0;
      reg mux_regs_ln248_reg_0_sel;
      reg [63:0] memread_regs_ln294_unr1_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr2_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr12_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr13_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr14_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr3_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr4_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr5_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr6_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr7_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr8_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr9_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr10_unr0_0_z;
      reg [63:0] memread_regs_ln294_unr11_unr0_0_z;
      reg ctrlAnd_0_ln249_z;
      reg mux_ping_ln228_sel;
      reg mux_regs_ln248_1024_mux_0_sel;
      reg read_sort_len_ln224_sel;

      state_sort_unisim_sort_rb_sort_next = 22'h0;
      RB_RW_CHUNK_for_begin_unr0_or_0 = state_sort_unisim_sort_rb_sort[13] | 
      state_sort_unisim_sort_rb_sort[11];
      RB_W_LAST_CHUNKS_INNER_for_begin_or_0 = state_sort_unisim_sort_rb_sort[9] | 
      state_sort_unisim_sort_rb_sort[10];
      ctrlAnd_1_ln260_unr0_z = add_ln260_unr0_1_q[4] & 
      state_sort_unisim_sort_rb_sort[13];
      ctrlAnd_1_ln280_unr0_z = add_ln280_unr0_1_q[4] & 
      state_sort_unisim_sort_rb_sort[15];
      ctrlAnd_1_ln260_unr1_z = mux_i_ln260_unr1_q[5] & 
      state_sort_unisim_sort_rb_sort[17];
      ctrlAnd_1_ln280_unr1_z = add_ln280_unr1_1_q[4] & 
      state_sort_unisim_sort_rb_sort[21];
      ctrlAnd_1_ln317_z = add_ln317_1_q[4] & state_sort_unisim_sort_rb_sort[10];
      ctrlOr_ln260_unr1_z = state_sort_unisim_sort_rb_sort[19] | 
      state_sort_unisim_sort_rb_sort[16];
      if (state_sort_unisim_sort_rb_sort[15]) 
        mux_exit_mux_wchunk_ln254_z = add_ln276_unr0_q;
      else 
        mux_exit_mux_wchunk_ln254_z = add_ln276_unr1_q;
      if (state_sort_unisim_sort_rb_sort[15]) 
        mux_regs_ln254_z = {mux_regs_ln248_q[2047:1024], mux_regs_ln254_0_q};
      else 
        mux_regs_ln254_z = {memread_regs_ln294_unr0_unr1_0_32_q, 
        mux_regs_ln254_1_q, memread_regs_ln294_unr14_unr1_0_q, 
        memread_regs_ln294_unr13_unr1_0_q, memread_regs_ln294_unr12_unr1_0_q, 
        memread_regs_ln294_unr11_unr1_0_q, memread_regs_ln294_unr10_unr1_0_q, 
        memread_regs_ln294_unr9_unr1_0_q, memread_regs_ln294_unr8_unr1_0_q, 
        memread_regs_ln294_unr7_unr1_0_q, memread_regs_ln294_unr6_unr1_0_q, 
        memread_regs_ln294_unr5_unr1_0_q, memread_regs_ln294_unr4_unr1_0_q, 
        memread_regs_ln294_unr3_unr1_0_q, memread_regs_ln294_unr2_unr1_0_q, 
        memread_regs_ln294_unr1_unr1_0_q, memread_regs_ln284_unr1_unr1_0_q, 
        mux_regs_ln260_1_q};
      ctrlAnd_0_ln260_unr0_z = !add_ln260_unr0_1_q[4] & 
      state_sort_unisim_sort_rb_sort[13];
      ctrlAnd_0_ln280_unr0_z = !add_ln280_unr0_1_q[4] & 
      state_sort_unisim_sort_rb_sort[15];
      ctrlAnd_0_ln280_unr1_z = !add_ln280_unr1_1_q[4] & 
      state_sort_unisim_sort_rb_sort[21];
      ctrlAnd_0_ln317_z = !add_ln317_1_q[4] & state_sort_unisim_sort_rb_sort[10];
      ctrlAnd_1_ln218_z = init_done & state_sort_unisim_sort_rb_sort[0];
      ctrlAnd_0_ln218_z = !init_done & state_sort_unisim_sort_rb_sort[0];
      ctrlAnd_1_ln234_z = input_done & state_sort_unisim_sort_rb_sort[3];
      ctrlAnd_0_ln234_z = !input_done & state_sort_unisim_sort_rb_sort[3];
      ctrlAnd_1_ln237_z = !input_done & state_sort_unisim_sort_rb_sort[4];
      ctrlAnd_0_ln237_z = input_done & state_sort_unisim_sort_rb_sort[4];
      ctrlAnd_0_ln255_unr1_z = eq_ln255_unr1_q & ctrlAnd_1_ln280_unr0_z;
      ctrlAnd_0_ln260_unr1_z = !mux_i_ln260_unr1_q[5] & 
      state_sort_unisim_sort_rb_sort[17];
      ctrlAnd_1_ln328_z = merge_start & state_sort_unisim_sort_rb_sort[7];
      ctrlAnd_0_ln328_z = !merge_start & state_sort_unisim_sort_rb_sort[7];
      ctrlAnd_1_ln331_z = !merge_start & state_sort_unisim_sort_rb_sort[8];
      ctrlAnd_0_ln331_z = merge_start & state_sort_unisim_sort_rb_sort[8];
      ctrlAnd_1_ln255_unr1_z = !eq_ln255_unr1_q & ctrlAnd_1_ln280_unr0_z;
      ctrlOr_ln312_0_z = ctrlAnd_1_ln317_z | state_sort_unisim_sort_rb_sort[6];
      if (state_sort_unisim_sort_rb_sort[1]) 
        mux_regs_ln228_z = 2048'h0;
      else 
        mux_regs_ln228_z = {mux_regs_ln248_q[2047:1024], mux_regs_ln248_reg_0_0};
      if (state_sort_unisim_sort_rb_sort[5]) 
        mux_pipe_full_ln248_z = 1'b0;
      else 
        mux_pipe_full_ln248_z = 1'b1;
      if (state_sort_unisim_sort_rb_sort[11]) 
        mux_regs_ln260_z = mux_regs_ln248_q[1023:0];
      else 
        mux_regs_ln260_z = memwrite_regs_ln273_unr0_q;
      if (state_sort_unisim_sort_rb_sort[16]) 
        mux_regs_ln260_0_z = mux_regs_ln248_q[2047:1024];
      else 
        mux_regs_ln260_0_z = memwrite_regs_ln273_unr1_q;
      if (state_sort_unisim_sort_rb_sort[14]) 
        mux_regs_ln280_z = memwrite_regs_ln273_unr0_q;
      else 
        mux_regs_ln280_z = {memread_regs_ln294_unr0_unr0_0_32_q, 
        mux_regs_ln280_0_q, memread_regs_ln294_unr14_unr0_0_q, 
        memread_regs_ln294_unr13_unr0_0_q, memread_regs_ln294_unr12_unr0_0_q, 
        memread_regs_ln294_unr11_unr0_0_q, memread_regs_ln294_unr10_unr0_0_q, 
        memread_regs_ln294_unr9_unr0_0_q, memread_regs_ln294_unr8_unr0_0_q, 
        memread_regs_ln294_unr7_unr0_0_q, memread_regs_ln294_unr6_unr0_0_q, 
        memread_regs_ln294_unr5_unr0_0_q, memread_regs_ln294_unr4_unr0_0_q, 
        memread_regs_ln294_unr3_unr0_0_q, memread_regs_ln294_unr2_unr0_0_q, 
        memread_regs_ln294_unr1_unr0_0_q, memread_regs_ln284_unr1_unr0_0_q};
      if (state_sort_unisim_sort_rb_sort[20]) 
        mux_regs_ln280_1_z = mux_regs_ln260_0_q;
      else 
        mux_regs_ln280_1_z = {memread_regs_ln294_unr0_unr1_0_32_q, 
        mux_regs_ln280_2_q, memread_regs_ln294_unr14_unr1_0_q, 
        memread_regs_ln294_unr13_unr1_0_q, memread_regs_ln294_unr12_unr1_0_q, 
        memread_regs_ln294_unr11_unr1_0_q, memread_regs_ln294_unr10_unr1_0_q, 
        memread_regs_ln294_unr9_unr1_0_q, memread_regs_ln294_unr8_unr1_0_q, 
        memread_regs_ln294_unr7_unr1_0_q, memread_regs_ln294_unr6_unr1_0_q, 
        memread_regs_ln294_unr5_unr1_0_q, memread_regs_ln294_unr4_unr1_0_q, 
        memread_regs_ln294_unr3_unr1_0_q, memread_regs_ln294_unr2_unr1_0_q, 
        memread_regs_ln294_unr1_unr1_0_q, memread_regs_ln284_unr1_unr1_0_q};
      if (mux_ping_ln228_q) 
        mux_elem_ln263_unr0_z = A0_bridge1_rtl_Q;
      else 
        mux_elem_ln263_unr0_z = A1_bridge1_rtl_Q;
      if (mux_ping_ln228_q) 
        mux_elem_ln263_unr1_z = A0_bridge1_rtl_Q;
      else 
        mux_elem_ln263_unr1_z = A1_bridge1_rtl_Q;
      if (state_sort_unisim_sort_rb_sort[1]) 
        mux_ping_ln228_z = 1'b1;
      else 
        mux_ping_ln228_z = !mux_ping_ln228_q;
      if (state_sort_unisim_sort_rb_sort[1]) 
        mux_burst_ln228_z = 32'h0;
      else 
        mux_burst_ln228_z = {add_ln334_1_q, !mux_burst_ln228_q};
      if (state_sort_unisim_sort_rb_sort[15]) 
        mux_exit_mux_chunk_ln254_z = {add_ln254_0_unr0_1_q, !mux_chunk_ln248_q[0]};
      else 
        mux_exit_mux_chunk_ln254_z = {add_ln254_0_unr1_1_q, !mux_chunk_ln248_q[1], 
        mux_chunk_ln248_q[0]};
      if (state_sort_unisim_sort_rb_sort[9]) 
        mux_i_2_ln317_z = 5'h0;
      else 
        mux_i_2_ln317_z = {add_ln317_1_q[3:0], !mux_i_2_ln317_q};
      if (state_sort_unisim_sort_rb_sort[11]) 
        mux_i_ln260_unr0_z = 5'h0;
      else 
        mux_i_ln260_unr0_z = {add_ln260_unr0_1_q[3:0], !mux_i_ln260_unr0_q[0]};
      if (state_sort_unisim_sort_rb_sort[16]) 
        mux_i_ln260_unr1_z = 6'h0;
      else 
        mux_i_ln260_unr1_z = {add_ln260_unr1_1_q, !mux_i_ln260_unr1_q[0]};
      if (state_sort_unisim_sort_rb_sort[6]) 
        mux_idx_0_ln312_z = 2'h0;
      else 
        mux_idx_0_ln312_z = {mux_idx_0_ln312_q, !mux_idx_0_ln312_q};
      if (state_sort_unisim_sort_rb_sort[14]) 
        mux_k_ln280_unr0_z = 5'h0;
      else 
        mux_k_ln280_unr0_z = {add_ln280_unr0_1_q[3:0], !mux_k_ln280_unr0_q};
      if (state_sort_unisim_sort_rb_sort[20]) 
        mux_k_ln280_unr1_z = 5'h0;
      else 
        mux_k_ln280_unr1_z = {add_ln280_unr1_1_q[3:0], !mux_k_ln280_unr1_q};
      if (state_sort_unisim_sort_rb_sort[6]) 
        mux_wchunk_ln312_z = mux_wchunk_ln248_reg_0_0;
      else 
        mux_wchunk_ln312_z = {add_ln324_1_q, !mux_wchunk_ln312_q[0]};
      if (state_sort_unisim_sort_rb_sort[5]) 
        mux_wchunk_ln248_z = 5'h0;
      else 
        mux_wchunk_ln248_z = mux_exit_mux_wchunk_ln254_z;
      if (state_sort_unisim_sort_rb_sort[5]) 
        mux_regs_ln248_z = mux_regs_ln228_q;
      else 
        mux_regs_ln248_z = {mux_regs_ln254_z[1087:64], 
        memread_regs_ln294_unr0_unr0_0_32_q, mux_regs_ln254_z[63:0], 
        memread_regs_ln294_unr14_unr0_0_q, memread_regs_ln294_unr13_unr0_0_q, 
        memread_regs_ln294_unr12_unr0_0_q, memread_regs_ln294_unr11_unr0_0_q, 
        memread_regs_ln294_unr10_unr0_0_q, memread_regs_ln294_unr9_unr0_0_q, 
        memread_regs_ln294_unr8_unr0_0_q, memread_regs_ln294_unr7_unr0_0_q, 
        memread_regs_ln294_unr6_unr0_0_q, memread_regs_ln294_unr5_unr0_0_q, 
        memread_regs_ln294_unr4_unr0_0_q, memread_regs_ln294_unr3_unr0_0_q, 
        memread_regs_ln294_unr2_unr0_0_q, memread_regs_ln294_unr1_unr0_0_q, 
        memread_regs_ln284_unr1_unr0_0_q};
      ctrlOr_ln260_unr0_z = ctrlAnd_0_ln260_unr0_z | 
      state_sort_unisim_sort_rb_sort[11];
      ctrlOr_ln280_unr0_z = ctrlAnd_0_ln280_unr0_z | 
      state_sort_unisim_sort_rb_sort[14];
      ctrlOr_ln280_unr1_z = ctrlAnd_0_ln280_unr1_z | 
      state_sort_unisim_sort_rb_sort[20];
      ctrlOr_ln317_z = ctrlAnd_0_ln317_z | state_sort_unisim_sort_rb_sort[9];
      rb_start_hold = ~(ctrlAnd_1_ln237_z | ctrlAnd_1_ln234_z);
      ctrlOr_ln237_z = ctrlAnd_0_ln237_z | ctrlAnd_1_ln234_z;
      ctrlOr_ln254_z = ctrlAnd_1_ln280_unr1_z | ctrlAnd_0_ln255_unr1_z;
      memread_sort_A0_ln264_unr1_en = mux_ping_ln228_q & ctrlAnd_0_ln260_unr1_z;
      memread_sort_A1_ln268_unr1_en = !mux_ping_ln228_q & ctrlAnd_0_ln260_unr1_z;
      memwrite_sort_C0_ln266_unr1_en = mux_pipe_full_ln248_Z_0_tag_0 & 
      mux_ping_ln228_q & ctrlAnd_0_ln260_unr1_z;
      memwrite_sort_C1_ln270_unr1_en = mux_pipe_full_ln248_Z_0_tag_0 & !
      mux_ping_ln228_q & ctrlAnd_0_ln260_unr1_z;
      mux_i_ln260_unr1_sel = state_sort_unisim_sort_rb_sort[18] | 
      ctrlAnd_0_ln260_unr1_z;
      mux_regs_ln260_0_sel = ctrlAnd_1_ln260_unr1_z | ctrlAnd_0_ln260_unr1_z;
      ctrlOr_ln228_z = ctrlAnd_1_ln331_z | state_sort_unisim_sort_rb_sort[1];
      ctrlOr_ln331_z = ctrlAnd_0_ln331_z | ctrlAnd_1_ln328_z;
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1088_v_0 = mux_regs_ln228_q[1151:1088];
      else 
        mux_mux_regs_ln228_Z_1088_v_0 = mux_regs_ln228_z[1151:1088];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1152_v_0 = mux_regs_ln228_q[1215:1152];
      else 
        mux_mux_regs_ln228_Z_1152_v_0 = mux_regs_ln228_z[1215:1152];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1216_v_0 = mux_regs_ln228_q[1279:1216];
      else 
        mux_mux_regs_ln228_Z_1216_v_0 = mux_regs_ln228_z[1279:1216];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1280_v_0 = mux_regs_ln228_q[1343:1280];
      else 
        mux_mux_regs_ln228_Z_1280_v_0 = mux_regs_ln228_z[1343:1280];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_128_v_0 = mux_regs_ln228_q[191:128];
      else 
        mux_mux_regs_ln228_Z_128_v_0 = mux_regs_ln228_z[191:128];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1344_v_0 = mux_regs_ln228_q[1407:1344];
      else 
        mux_mux_regs_ln228_Z_1344_v_0 = mux_regs_ln228_z[1407:1344];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1408_v_0 = mux_regs_ln228_q[1471:1408];
      else 
        mux_mux_regs_ln228_Z_1408_v_0 = mux_regs_ln228_z[1471:1408];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1472_v_0 = mux_regs_ln228_q[1535:1472];
      else 
        mux_mux_regs_ln228_Z_1472_v_0 = mux_regs_ln228_z[1535:1472];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1536_v_0 = mux_regs_ln228_q[1599:1536];
      else 
        mux_mux_regs_ln228_Z_1536_v_0 = mux_regs_ln228_z[1599:1536];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1600_v_0 = mux_regs_ln228_q[1663:1600];
      else 
        mux_mux_regs_ln228_Z_1600_v_0 = mux_regs_ln228_z[1663:1600];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1664_v_0 = mux_regs_ln228_q[1727:1664];
      else 
        mux_mux_regs_ln228_Z_1664_v_0 = mux_regs_ln228_z[1727:1664];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1728_v_0 = mux_regs_ln228_q[1791:1728];
      else 
        mux_mux_regs_ln228_Z_1728_v_0 = mux_regs_ln228_z[1791:1728];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1792_v_0 = mux_regs_ln228_q[1855:1792];
      else 
        mux_mux_regs_ln228_Z_1792_v_0 = mux_regs_ln228_z[1855:1792];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1856_v_0 = mux_regs_ln228_q[1919:1856];
      else 
        mux_mux_regs_ln228_Z_1856_v_0 = mux_regs_ln228_z[1919:1856];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1920_v_0 = mux_regs_ln228_q[1983:1920];
      else 
        mux_mux_regs_ln228_Z_1920_v_0 = mux_regs_ln228_z[1983:1920];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_192_v_0 = mux_regs_ln228_q[255:192];
      else 
        mux_mux_regs_ln228_Z_192_v_0 = mux_regs_ln228_z[255:192];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1984_v_0 = mux_regs_ln228_q[2047:1984];
      else 
        mux_mux_regs_ln228_Z_1984_v_0 = mux_regs_ln228_z[2047:1984];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_256_v_0 = mux_regs_ln228_q[319:256];
      else 
        mux_mux_regs_ln228_Z_256_v_0 = mux_regs_ln228_z[319:256];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_320_v_0 = mux_regs_ln228_q[383:320];
      else 
        mux_mux_regs_ln228_Z_320_v_0 = mux_regs_ln228_z[383:320];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_384_v_0 = mux_regs_ln228_q[447:384];
      else 
        mux_mux_regs_ln228_Z_384_v_0 = mux_regs_ln228_z[447:384];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_448_v_0 = mux_regs_ln228_q[511:448];
      else 
        mux_mux_regs_ln228_Z_448_v_0 = mux_regs_ln228_z[511:448];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_512_v_0 = mux_regs_ln228_q[575:512];
      else 
        mux_mux_regs_ln228_Z_512_v_0 = mux_regs_ln228_z[575:512];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_576_v_0 = mux_regs_ln228_q[639:576];
      else 
        mux_mux_regs_ln228_Z_576_v_0 = mux_regs_ln228_z[639:576];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_640_v_0 = mux_regs_ln228_q[703:640];
      else 
        mux_mux_regs_ln228_Z_640_v_0 = mux_regs_ln228_z[703:640];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_64_v_0 = mux_regs_ln228_q[127:64];
      else 
        mux_mux_regs_ln228_Z_64_v_0 = mux_regs_ln228_z[127:64];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_704_v_0 = mux_regs_ln228_q[767:704];
      else 
        mux_mux_regs_ln228_Z_704_v_0 = mux_regs_ln228_z[767:704];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_768_v_0 = mux_regs_ln228_q[831:768];
      else 
        mux_mux_regs_ln228_Z_768_v_0 = mux_regs_ln228_z[831:768];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_832_v_0 = mux_regs_ln228_q[895:832];
      else 
        mux_mux_regs_ln228_Z_832_v_0 = mux_regs_ln228_z[895:832];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_896_v_0 = mux_regs_ln228_q[959:896];
      else 
        mux_mux_regs_ln228_Z_896_v_0 = mux_regs_ln228_z[959:896];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_960_v_0 = mux_regs_ln228_q[1023:960];
      else 
        mux_mux_regs_ln228_Z_960_v_0 = mux_regs_ln228_z[1023:960];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_v = mux_regs_ln228_q[63:0];
      else 
        mux_mux_regs_ln228_Z_v = mux_regs_ln228_z[63:0];
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_regs_ln228_Z_1024_v_0 = mux_regs_ln228_q[1087:1024];
      else 
        mux_mux_regs_ln228_Z_1024_v_0 = mux_regs_ln228_z[1087:1024];
      memwrite_regs_ln273_unr0_z = mux_regs_ln260_q;
      case (mux_i_ln260_unr0_q)// synthesis parallel_case
        5'h0: memwrite_regs_ln273_unr0_z[31:0] = mux_elem_ln263_unr0_z;
        5'h1: memwrite_regs_ln273_unr0_z[63:32] = mux_elem_ln263_unr0_z;
        5'h2: memwrite_regs_ln273_unr0_z[95:64] = mux_elem_ln263_unr0_z;
        5'h3: memwrite_regs_ln273_unr0_z[127:96] = mux_elem_ln263_unr0_z;
        5'h4: memwrite_regs_ln273_unr0_z[159:128] = mux_elem_ln263_unr0_z;
        5'h5: memwrite_regs_ln273_unr0_z[191:160] = mux_elem_ln263_unr0_z;
        5'h6: memwrite_regs_ln273_unr0_z[223:192] = mux_elem_ln263_unr0_z;
        5'h7: memwrite_regs_ln273_unr0_z[255:224] = mux_elem_ln263_unr0_z;
        5'h8: memwrite_regs_ln273_unr0_z[287:256] = mux_elem_ln263_unr0_z;
        5'h9: memwrite_regs_ln273_unr0_z[319:288] = mux_elem_ln263_unr0_z;
        5'ha: memwrite_regs_ln273_unr0_z[351:320] = mux_elem_ln263_unr0_z;
        5'hb: memwrite_regs_ln273_unr0_z[383:352] = mux_elem_ln263_unr0_z;
        5'hc: memwrite_regs_ln273_unr0_z[415:384] = mux_elem_ln263_unr0_z;
        5'hd: memwrite_regs_ln273_unr0_z[447:416] = mux_elem_ln263_unr0_z;
        5'he: memwrite_regs_ln273_unr0_z[479:448] = mux_elem_ln263_unr0_z;
        5'hf: memwrite_regs_ln273_unr0_z[511:480] = mux_elem_ln263_unr0_z;
        5'h10: memwrite_regs_ln273_unr0_z[543:512] = mux_elem_ln263_unr0_z;
        5'h11: memwrite_regs_ln273_unr0_z[575:544] = mux_elem_ln263_unr0_z;
        5'h12: memwrite_regs_ln273_unr0_z[607:576] = mux_elem_ln263_unr0_z;
        5'h13: memwrite_regs_ln273_unr0_z[639:608] = mux_elem_ln263_unr0_z;
        5'h14: memwrite_regs_ln273_unr0_z[671:640] = mux_elem_ln263_unr0_z;
        5'h15: memwrite_regs_ln273_unr0_z[703:672] = mux_elem_ln263_unr0_z;
        5'h16: memwrite_regs_ln273_unr0_z[735:704] = mux_elem_ln263_unr0_z;
        5'h17: memwrite_regs_ln273_unr0_z[767:736] = mux_elem_ln263_unr0_z;
        5'h18: memwrite_regs_ln273_unr0_z[799:768] = mux_elem_ln263_unr0_z;
        5'h19: memwrite_regs_ln273_unr0_z[831:800] = mux_elem_ln263_unr0_z;
        5'h1a: memwrite_regs_ln273_unr0_z[863:832] = mux_elem_ln263_unr0_z;
        5'h1b: memwrite_regs_ln273_unr0_z[895:864] = mux_elem_ln263_unr0_z;
        5'h1c: memwrite_regs_ln273_unr0_z[927:896] = mux_elem_ln263_unr0_z;
        5'h1d: memwrite_regs_ln273_unr0_z[959:928] = mux_elem_ln263_unr0_z;
        5'h1e: memwrite_regs_ln273_unr0_z[991:960] = mux_elem_ln263_unr0_z;
        5'h1f: memwrite_regs_ln273_unr0_z[1023:992] = mux_elem_ln263_unr0_z;
        default: memwrite_regs_ln273_unr0_z = 32'hX;
      endcase
      memwrite_regs_ln273_unr1_z = mux_regs_ln260_0_q;
      case (mux_i_ln260_unr1_q[4:0])// synthesis parallel_case
        5'h0: memwrite_regs_ln273_unr1_z[31:0] = mux_elem_ln263_unr1_z;
        5'h1: memwrite_regs_ln273_unr1_z[63:32] = mux_elem_ln263_unr1_z;
        5'h2: memwrite_regs_ln273_unr1_z[95:64] = mux_elem_ln263_unr1_z;
        5'h3: memwrite_regs_ln273_unr1_z[127:96] = mux_elem_ln263_unr1_z;
        5'h4: memwrite_regs_ln273_unr1_z[159:128] = mux_elem_ln263_unr1_z;
        5'h5: memwrite_regs_ln273_unr1_z[191:160] = mux_elem_ln263_unr1_z;
        5'h6: memwrite_regs_ln273_unr1_z[223:192] = mux_elem_ln263_unr1_z;
        5'h7: memwrite_regs_ln273_unr1_z[255:224] = mux_elem_ln263_unr1_z;
        5'h8: memwrite_regs_ln273_unr1_z[287:256] = mux_elem_ln263_unr1_z;
        5'h9: memwrite_regs_ln273_unr1_z[319:288] = mux_elem_ln263_unr1_z;
        5'ha: memwrite_regs_ln273_unr1_z[351:320] = mux_elem_ln263_unr1_z;
        5'hb: memwrite_regs_ln273_unr1_z[383:352] = mux_elem_ln263_unr1_z;
        5'hc: memwrite_regs_ln273_unr1_z[415:384] = mux_elem_ln263_unr1_z;
        5'hd: memwrite_regs_ln273_unr1_z[447:416] = mux_elem_ln263_unr1_z;
        5'he: memwrite_regs_ln273_unr1_z[479:448] = mux_elem_ln263_unr1_z;
        5'hf: memwrite_regs_ln273_unr1_z[511:480] = mux_elem_ln263_unr1_z;
        5'h10: memwrite_regs_ln273_unr1_z[543:512] = mux_elem_ln263_unr1_z;
        5'h11: memwrite_regs_ln273_unr1_z[575:544] = mux_elem_ln263_unr1_z;
        5'h12: memwrite_regs_ln273_unr1_z[607:576] = mux_elem_ln263_unr1_z;
        5'h13: memwrite_regs_ln273_unr1_z[639:608] = mux_elem_ln263_unr1_z;
        5'h14: memwrite_regs_ln273_unr1_z[671:640] = mux_elem_ln263_unr1_z;
        5'h15: memwrite_regs_ln273_unr1_z[703:672] = mux_elem_ln263_unr1_z;
        5'h16: memwrite_regs_ln273_unr1_z[735:704] = mux_elem_ln263_unr1_z;
        5'h17: memwrite_regs_ln273_unr1_z[767:736] = mux_elem_ln263_unr1_z;
        5'h18: memwrite_regs_ln273_unr1_z[799:768] = mux_elem_ln263_unr1_z;
        5'h19: memwrite_regs_ln273_unr1_z[831:800] = mux_elem_ln263_unr1_z;
        5'h1a: memwrite_regs_ln273_unr1_z[863:832] = mux_elem_ln263_unr1_z;
        5'h1b: memwrite_regs_ln273_unr1_z[895:864] = mux_elem_ln263_unr1_z;
        5'h1c: memwrite_regs_ln273_unr1_z[927:896] = mux_elem_ln263_unr1_z;
        5'h1d: memwrite_regs_ln273_unr1_z[959:928] = mux_elem_ln263_unr1_z;
        5'h1e: memwrite_regs_ln273_unr1_z[991:960] = mux_elem_ln263_unr1_z;
        5'h1f: memwrite_regs_ln273_unr1_z[1023:992] = mux_elem_ln263_unr1_z;
        default: memwrite_regs_ln273_unr1_z = 32'hX;
      endcase
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_ping_ln228_Z_0_v = mux_ping_ln228_q;
      else 
        mux_mux_ping_ln228_Z_0_v = mux_ping_ln228_z;
      unary_nor_ln335_z = ~mux_ping_ln228_z;
      eq_ln230_z = mux_burst_ln228_z == read_sort_batch_ln225_q;
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_mux_burst_ln228_Z_0_v = mux_burst_ln228_q;
      else 
        mux_mux_burst_ln228_Z_0_v = mux_burst_ln228_z[0];
      add_ln334_z = mux_burst_ln228_z + 32'h1;
      if (state_sort_unisim_sort_rb_sort[5]) 
        mux_chunk_ln248_z = 32'h0;
      else 
        mux_chunk_ln248_z = mux_exit_mux_chunk_ln254_z;
      add_ln317_z = {1'b0, mux_i_2_ln317_z} + 6'h1;
      case ({mux_idx_0_ln312_q, mux_i_2_ln317_z})// synthesis parallel_case
        6'h0: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[31:0];
        6'h1: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[63:32];
        6'h2: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[95:64];
        6'h3: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[127:96];
        6'h4: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[159:128];
        6'h5: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[191:160];
        6'h6: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[223:192];
        6'h7: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[255:224];
        6'h8: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[287:256];
        6'h9: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[319:288];
        6'ha: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[351:320];
        6'hb: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[383:352];
        6'hc: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[415:384];
        6'hd: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[447:416];
        6'he: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[479:448];
        6'hf: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[511:480];
        6'h10: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[543:512];
        6'h11: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[575:544];
        6'h12: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[607:576];
        6'h13: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[639:608];
        6'h14: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[671:640];
        6'h15: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[703:672];
        6'h16: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[735:704];
        6'h17: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[767:736];
        6'h18: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[799:768];
        6'h19: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[831:800];
        6'h1a: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[863:832];
        6'h1b: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[895:864];
        6'h1c: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[927:896];
        6'h1d: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[959:928];
        6'h1e: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[991:960];
        6'h1f: memread_regs_ln319_z = mux_regs_ln248_reg_0_0[1023:992];
        6'h20: memread_regs_ln319_z = mux_regs_ln248_q[1055:1024];
        6'h21: memread_regs_ln319_z = mux_regs_ln248_q[1087:1056];
        6'h22: memread_regs_ln319_z = mux_regs_ln248_q[1119:1088];
        6'h23: memread_regs_ln319_z = mux_regs_ln248_q[1151:1120];
        6'h24: memread_regs_ln319_z = mux_regs_ln248_q[1183:1152];
        6'h25: memread_regs_ln319_z = mux_regs_ln248_q[1215:1184];
        6'h26: memread_regs_ln319_z = mux_regs_ln248_q[1247:1216];
        6'h27: memread_regs_ln319_z = mux_regs_ln248_q[1279:1248];
        6'h28: memread_regs_ln319_z = mux_regs_ln248_q[1311:1280];
        6'h29: memread_regs_ln319_z = mux_regs_ln248_q[1343:1312];
        6'h2a: memread_regs_ln319_z = mux_regs_ln248_q[1375:1344];
        6'h2b: memread_regs_ln319_z = mux_regs_ln248_q[1407:1376];
        6'h2c: memread_regs_ln319_z = mux_regs_ln248_q[1439:1408];
        6'h2d: memread_regs_ln319_z = mux_regs_ln248_q[1471:1440];
        6'h2e: memread_regs_ln319_z = mux_regs_ln248_q[1503:1472];
        6'h2f: memread_regs_ln319_z = mux_regs_ln248_q[1535:1504];
        6'h30: memread_regs_ln319_z = mux_regs_ln248_q[1567:1536];
        6'h31: memread_regs_ln319_z = mux_regs_ln248_q[1599:1568];
        6'h32: memread_regs_ln319_z = mux_regs_ln248_q[1631:1600];
        6'h33: memread_regs_ln319_z = mux_regs_ln248_q[1663:1632];
        6'h34: memread_regs_ln319_z = mux_regs_ln248_q[1695:1664];
        6'h35: memread_regs_ln319_z = mux_regs_ln248_q[1727:1696];
        6'h36: memread_regs_ln319_z = mux_regs_ln248_q[1759:1728];
        6'h37: memread_regs_ln319_z = mux_regs_ln248_q[1791:1760];
        6'h38: memread_regs_ln319_z = mux_regs_ln248_q[1823:1792];
        6'h39: memread_regs_ln319_z = mux_regs_ln248_q[1855:1824];
        6'h3a: memread_regs_ln319_z = mux_regs_ln248_q[1887:1856];
        6'h3b: memread_regs_ln319_z = mux_regs_ln248_q[1919:1888];
        6'h3c: memread_regs_ln319_z = mux_regs_ln248_q[1951:1920];
        6'h3d: memread_regs_ln319_z = mux_regs_ln248_q[1983:1952];
        6'h3e: memread_regs_ln319_z = mux_regs_ln248_q[2015:1984];
        6'h3f: memread_regs_ln319_z = mux_regs_ln248_q[2047:2016];
        default: memread_regs_ln319_z = 32'hX;
      endcase
      if (state_sort_unisim_sort_rb_sort[17]) 
        A1_bridge1_rtl_a = {add_ln264_unr1_q, mux_i_ln260_unr1_q[4:0]};
      else 
        A1_bridge1_rtl_a = {mux_chunk_ln248_q, mux_i_ln260_unr0_z};
      case (1'b1)// synthesis parallel_case
        RB_RW_CHUNK_for_begin_unr0_or_0: C0_bridge0_rtl_a = {mux_wchunk_ln248_q, 
          mux_i_ln260_unr0_z};
        state_sort_unisim_sort_rb_sort[17]: C0_bridge0_rtl_a = {
          add_ln266_1_unr1_q, mux_i_ln260_unr1_q[4:0]};
        RB_W_LAST_CHUNKS_INNER_for_begin_or_0: C0_bridge0_rtl_a = {
          mux_wchunk_ln312_q, mux_i_2_ln317_z};
        default: C0_bridge0_rtl_a = 10'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        RB_RW_CHUNK_for_begin_unr0_or_0: C1_bridge0_rtl_a = {mux_wchunk_ln248_q, 
          mux_i_ln260_unr0_z};
        state_sort_unisim_sort_rb_sort[17]: C1_bridge0_rtl_a = {
          add_ln270_1_unr1_q, mux_i_ln260_unr1_q[4:0]};
        RB_W_LAST_CHUNKS_INNER_for_begin_or_0: C1_bridge0_rtl_a = {
          mux_wchunk_ln312_q, mux_i_2_ln317_z};
        default: C1_bridge0_rtl_a = 10'hX;
      endcase
      add_ln260_unr0_z = {1'b0, mux_i_ln260_unr0_z} + 6'h1;
      case (mux_i_ln260_unr0_z)// synthesis parallel_case
        5'h0: memread_regs_ln266_unr0_z = mux_regs_ln260_z[31:0];
        5'h1: memread_regs_ln266_unr0_z = mux_regs_ln260_z[63:32];
        5'h2: memread_regs_ln266_unr0_z = mux_regs_ln260_z[95:64];
        5'h3: memread_regs_ln266_unr0_z = mux_regs_ln260_z[127:96];
        5'h4: memread_regs_ln266_unr0_z = mux_regs_ln260_z[159:128];
        5'h5: memread_regs_ln266_unr0_z = mux_regs_ln260_z[191:160];
        5'h6: memread_regs_ln266_unr0_z = mux_regs_ln260_z[223:192];
        5'h7: memread_regs_ln266_unr0_z = mux_regs_ln260_z[255:224];
        5'h8: memread_regs_ln266_unr0_z = mux_regs_ln260_z[287:256];
        5'h9: memread_regs_ln266_unr0_z = mux_regs_ln260_z[319:288];
        5'ha: memread_regs_ln266_unr0_z = mux_regs_ln260_z[351:320];
        5'hb: memread_regs_ln266_unr0_z = mux_regs_ln260_z[383:352];
        5'hc: memread_regs_ln266_unr0_z = mux_regs_ln260_z[415:384];
        5'hd: memread_regs_ln266_unr0_z = mux_regs_ln260_z[447:416];
        5'he: memread_regs_ln266_unr0_z = mux_regs_ln260_z[479:448];
        5'hf: memread_regs_ln266_unr0_z = mux_regs_ln260_z[511:480];
        5'h10: memread_regs_ln266_unr0_z = mux_regs_ln260_z[543:512];
        5'h11: memread_regs_ln266_unr0_z = mux_regs_ln260_z[575:544];
        5'h12: memread_regs_ln266_unr0_z = mux_regs_ln260_z[607:576];
        5'h13: memread_regs_ln266_unr0_z = mux_regs_ln260_z[639:608];
        5'h14: memread_regs_ln266_unr0_z = mux_regs_ln260_z[671:640];
        5'h15: memread_regs_ln266_unr0_z = mux_regs_ln260_z[703:672];
        5'h16: memread_regs_ln266_unr0_z = mux_regs_ln260_z[735:704];
        5'h17: memread_regs_ln266_unr0_z = mux_regs_ln260_z[767:736];
        5'h18: memread_regs_ln266_unr0_z = mux_regs_ln260_z[799:768];
        5'h19: memread_regs_ln266_unr0_z = mux_regs_ln260_z[831:800];
        5'h1a: memread_regs_ln266_unr0_z = mux_regs_ln260_z[863:832];
        5'h1b: memread_regs_ln266_unr0_z = mux_regs_ln260_z[895:864];
        5'h1c: memread_regs_ln266_unr0_z = mux_regs_ln260_z[927:896];
        5'h1d: memread_regs_ln266_unr0_z = mux_regs_ln260_z[959:928];
        5'h1e: memread_regs_ln266_unr0_z = mux_regs_ln260_z[991:960];
        5'h1f: memread_regs_ln266_unr0_z = mux_regs_ln260_z[1023:992];
        default: memread_regs_ln266_unr0_z = 32'hX;
      endcase
      if (state_sort_unisim_sort_rb_sort[17]) 
        A0_bridge1_rtl_a = {add_ln264_unr1_q, mux_i_ln260_unr1_q[4:0]};
      else 
        A0_bridge1_rtl_a = {mux_chunk_ln248_q, mux_i_ln260_unr0_z};
      add_ln266_1_unr1_z = add_ln276_unr0_q + mux_i_ln260_unr1_z[5];
      add_ln270_1_unr1_z = add_ln276_unr0_q + mux_i_ln260_unr1_z[5];
      add_ln260_unr1_z = {1'b0, mux_i_ln260_unr1_z[4:0]} + 6'h1;
      case (mux_i_ln260_unr1_z[4:0])// synthesis parallel_case
        5'h0: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[31:0];
        5'h1: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[63:32];
        5'h2: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[95:64];
        5'h3: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[127:96];
        5'h4: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[159:128];
        5'h5: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[191:160];
        5'h6: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[223:192];
        5'h7: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[255:224];
        5'h8: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[287:256];
        5'h9: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[319:288];
        5'ha: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[351:320];
        5'hb: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[383:352];
        5'hc: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[415:384];
        5'hd: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[447:416];
        5'he: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[479:448];
        5'hf: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[511:480];
        5'h10: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[543:512];
        5'h11: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[575:544];
        5'h12: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[607:576];
        5'h13: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[639:608];
        5'h14: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[671:640];
        5'h15: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[703:672];
        5'h16: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[735:704];
        5'h17: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[767:736];
        5'h18: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[799:768];
        5'h19: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[831:800];
        5'h1a: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[863:832];
        5'h1b: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[895:864];
        5'h1c: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[927:896];
        5'h1d: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[959:928];
        5'h1e: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[991:960];
        5'h1f: memread_regs_ln266_unr1_z = mux_regs_ln260_0_z[1023:992];
        default: memread_regs_ln266_unr1_z = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_i_ln260_unr1_1_d_0 = mux_i_ln260_unr1_z[4:1];
        ctrlAnd_0_ln260_unr1_z: mux_i_ln260_unr1_1_d_0 = mux_i_ln260_unr1_q[4:1];
        default: mux_i_ln260_unr1_1_d_0 = 4'hX;
      endcase
      add_ln264_unr1_z = {add_ln254_0_unr0_1_q[3:0], !mux_chunk_ln248_q[0]} + 
      mux_i_ln260_unr1_z[5];
      lt_ln312_z = ~mux_idx_0_ln312_z[1];
      xor_ln312_z = ~mux_idx_0_ln312_z[0];
      eq_ln313_z = {25'h0, mux_idx_0_ln312_z, 5'h0} == read_sort_len_ln224_q;
      add_ln280_unr0_z = {1'b0, mux_k_ln280_unr0_z} + 6'h1;
      add_ln280_unr1_z = {1'b0, mux_k_ln280_unr1_z} + 6'h1;
      add_ln324_z = mux_wchunk_ln312_z + 5'h1;
      add_ln276_unr0_z = mux_wchunk_ln248_z + mux_pipe_full_ln248_z;
      memread_sort_A0_ln264_unr0_en = mux_ping_ln228_q & ctrlOr_ln260_unr0_z;
      memread_sort_A1_ln268_unr0_en = !mux_ping_ln228_q & ctrlOr_ln260_unr0_z;
      memwrite_sort_C0_ln266_unr0_en = mux_pipe_full_ln248_Z_0_tag_0 & 
      mux_ping_ln228_q & ctrlOr_ln260_unr0_z;
      memwrite_sort_C1_ln270_unr0_en = mux_pipe_full_ln248_Z_0_tag_0 & !
      mux_ping_ln228_q & ctrlOr_ln260_unr0_z;
      mux_chunk_ln248_2_mux_0_sel = state_sort_unisim_sort_rb_sort[12] | 
      ctrlOr_ln260_unr0_z;
      mux_pipe_full_ln248_Z_0_tag_sel = state_sort_unisim_sort_rb_sort[12] | 
      state_sort_unisim_sort_rb_sort[18] | ctrlOr_ln280_unr0_z | 
      ctrlOr_ln260_unr1_z | ctrlOr_ln260_unr0_z | ctrlAnd_1_ln260_unr0_z | 
      ctrlAnd_1_ln255_unr1_z | ctrlAnd_0_ln260_unr1_z;
      add_ln254_0_unr0_1_4_mux_0_sel = state_sort_unisim_sort_rb_sort[12] | 
      ctrlOr_ln280_unr0_z | ctrlOr_ln260_unr0_z | ctrlAnd_1_ln260_unr0_z;
      memread_regs_ln284_unr1_unr0_0_sel = state_sort_unisim_sort_rb_sort[18] | 
      ctrlOr_ln280_unr1_z | ctrlOr_ln260_unr1_z | ctrlAnd_1_ln260_unr1_z | 
      ctrlAnd_1_ln255_unr1_z | ctrlAnd_0_ln260_unr1_z;
      mux_chunk_ln248_sel = state_sort_unisim_sort_rb_sort[12] | 
      state_sort_unisim_sort_rb_sort[18] | ctrlOr_ln280_unr1_z | 
      ctrlOr_ln280_unr0_z | ctrlOr_ln260_unr1_z | ctrlOr_ln260_unr0_z | 
      ctrlAnd_1_ln260_unr1_z | ctrlAnd_1_ln260_unr0_z | ctrlAnd_1_ln255_unr1_z | 
      ctrlAnd_0_ln260_unr1_z;
      memwrite_sort_C0_ln319_en = mux_ping_ln228_q & ctrlOr_ln317_z;
      memwrite_sort_C1_ln321_en = !mux_ping_ln228_q & ctrlOr_ln317_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln234_z: rb_start_d = 1'b1;
        ctrlAnd_1_ln237_z: rb_start_d = 1'b0;
        rb_start_hold: rb_start_d = rb_start;
        default: rb_start_d = 1'bX;
      endcase
      mux_regs_ln228_sel = ctrlOr_ln237_z | ctrlAnd_1_ln237_z;
      ctrlOr_ln248_0_z = ctrlOr_ln254_z | state_sort_unisim_sort_rb_sort[5];
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_192_d_0 = mux_regs_ln260_0_z[255:
          192];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_192_d_0 = mux_regs_ln260_0_q[255:
          192];
        default: mux_regs_ln260_0_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_256_d_0 = mux_regs_ln260_0_z[319:
          256];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_256_d_0 = mux_regs_ln260_0_q[319:
          256];
        default: mux_regs_ln260_0_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_320_d_0 = mux_regs_ln260_0_z[383:
          320];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_320_d_0 = mux_regs_ln260_0_q[383:
          320];
        default: mux_regs_ln260_0_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_384_d_0 = mux_regs_ln260_0_z[447:
          384];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_384_d_0 = mux_regs_ln260_0_q[447:
          384];
        default: mux_regs_ln260_0_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_448_d_0 = mux_regs_ln260_0_z[511:
          448];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_448_d_0 = mux_regs_ln260_0_q[511:
          448];
        default: mux_regs_ln260_0_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_512_d_0 = mux_regs_ln260_0_z[575:
          512];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_512_d_0 = mux_regs_ln260_0_q[575:
          512];
        default: mux_regs_ln260_0_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_576_d_0 = mux_regs_ln260_0_z[639:
          576];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_576_d_0 = mux_regs_ln260_0_q[639:
          576];
        default: mux_regs_ln260_0_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_640_d_0 = mux_regs_ln260_0_z[703:
          640];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_640_d_0 = mux_regs_ln260_0_q[703:
          640];
        default: mux_regs_ln260_0_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_64_d_0 = mux_regs_ln260_0_z[127:64];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_64_d_0 = mux_regs_ln260_0_q[127:
          64];
        default: mux_regs_ln260_0_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_704_d_0 = mux_regs_ln260_0_z[767:
          704];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_704_d_0 = mux_regs_ln260_0_q[767:
          704];
        default: mux_regs_ln260_0_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_768_d_0 = mux_regs_ln260_0_z[831:
          768];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_768_d_0 = mux_regs_ln260_0_q[831:
          768];
        default: mux_regs_ln260_0_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_832_d_0 = mux_regs_ln260_0_z[895:
          832];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_832_d_0 = mux_regs_ln260_0_q[895:
          832];
        default: mux_regs_ln260_0_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_896_d_0 = mux_regs_ln260_0_z[959:
          896];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_896_d_0 = mux_regs_ln260_0_q[959:
          896];
        default: mux_regs_ln260_0_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_960_d_0 = mux_regs_ln260_0_z[1023:
          960];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_960_d_0 = mux_regs_ln260_0_q[1023:
          960];
        default: mux_regs_ln260_0_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_d = mux_regs_ln260_0_z[63:0];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_d = mux_regs_ln260_0_q[63:0];
        default: mux_regs_ln260_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_regs_ln260_0_128_d_0 = mux_regs_ln260_0_z[191:
          128];
        mux_regs_ln260_0_sel: mux_regs_ln260_0_128_d_0 = mux_regs_ln260_0_q[191:
          128];
        default: mux_regs_ln260_0_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_192_d_0 = 
          memwrite_regs_ln273_unr0_z[255:192];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_192_d_0 = 
          memwrite_regs_ln273_unr0_q[255:192];
        default: memwrite_regs_ln273_unr0_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_256_d_0 = 
          memwrite_regs_ln273_unr0_z[319:256];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_256_d_0 = 
          memwrite_regs_ln273_unr0_q[319:256];
        default: memwrite_regs_ln273_unr0_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_320_d_0 = 
          memwrite_regs_ln273_unr0_z[383:320];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_320_d_0 = 
          memwrite_regs_ln273_unr0_q[383:320];
        default: memwrite_regs_ln273_unr0_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_384_d_0 = 
          memwrite_regs_ln273_unr0_z[447:384];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_384_d_0 = 
          memwrite_regs_ln273_unr0_q[447:384];
        default: memwrite_regs_ln273_unr0_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_448_d_0 = 
          memwrite_regs_ln273_unr0_z[511:448];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_448_d_0 = 
          memwrite_regs_ln273_unr0_q[511:448];
        default: memwrite_regs_ln273_unr0_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_512_d_0 = 
          memwrite_regs_ln273_unr0_z[575:512];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_512_d_0 = 
          memwrite_regs_ln273_unr0_q[575:512];
        default: memwrite_regs_ln273_unr0_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_576_d_0 = 
          memwrite_regs_ln273_unr0_z[639:576];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_576_d_0 = 
          memwrite_regs_ln273_unr0_q[639:576];
        default: memwrite_regs_ln273_unr0_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_640_d_0 = 
          memwrite_regs_ln273_unr0_z[703:640];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_640_d_0 = 
          memwrite_regs_ln273_unr0_q[703:640];
        default: memwrite_regs_ln273_unr0_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_64_d_0 = 
          memwrite_regs_ln273_unr0_z[127:64];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_64_d_0 = 
          memwrite_regs_ln273_unr0_q[127:64];
        default: memwrite_regs_ln273_unr0_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_704_d_0 = 
          memwrite_regs_ln273_unr0_z[767:704];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_704_d_0 = 
          memwrite_regs_ln273_unr0_q[767:704];
        default: memwrite_regs_ln273_unr0_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_768_d_0 = 
          memwrite_regs_ln273_unr0_z[831:768];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_768_d_0 = 
          memwrite_regs_ln273_unr0_q[831:768];
        default: memwrite_regs_ln273_unr0_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_832_d_0 = 
          memwrite_regs_ln273_unr0_z[895:832];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_832_d_0 = 
          memwrite_regs_ln273_unr0_q[895:832];
        default: memwrite_regs_ln273_unr0_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_896_d_0 = 
          memwrite_regs_ln273_unr0_z[959:896];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_896_d_0 = 
          memwrite_regs_ln273_unr0_q[959:896];
        default: memwrite_regs_ln273_unr0_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_960_d_0 = 
          memwrite_regs_ln273_unr0_z[1023:960];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_960_d_0 = 
          memwrite_regs_ln273_unr0_q[1023:960];
        default: memwrite_regs_ln273_unr0_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_d = 
          memwrite_regs_ln273_unr0_z[63:0];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_d = 
          memwrite_regs_ln273_unr0_q[63:0];
        default: memwrite_regs_ln273_unr0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[12]: memwrite_regs_ln273_unr0_128_d_0 = 
          memwrite_regs_ln273_unr0_z[191:128];
        ctrlAnd_1_ln260_unr0_z: memwrite_regs_ln273_unr0_128_d_0 = 
          memwrite_regs_ln273_unr0_q[191:128];
        default: memwrite_regs_ln273_unr0_128_d_0 = 64'hX;
      endcase
      if (state_sort_unisim_sort_rb_sort[3]) 
        mux_add_ln334_Z_1_v_0 = add_ln334_1_q;
      else 
        mux_add_ln334_Z_1_v_0 = add_ln334_z[31:1];
      add_ln254_0_unr0_z = mux_chunk_ln248_z + 32'h1;
      eq_ln249_z = {mux_chunk_ln248_z[26:0], 5'h0} == read_sort_len_ln224_q;
      lt_ln248_0_z = ~|mux_chunk_ln248_z[30:5];
      add_ln254_0_unr1_z = mux_chunk_ln248_z[31:1] + 31'h1;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr0_z: mux_i_ln260_unr0_d = {add_ln260_unr0_z[5:1], 
          mux_i_ln260_unr0_z[0]};
        state_sort_unisim_sort_rb_sort[12]: mux_i_ln260_unr0_d = {
          add_ln260_unr0_1_q, mux_i_ln260_unr0_q[0]};
        default: mux_i_ln260_unr0_d = 6'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        RB_RW_CHUNK_for_begin_unr0_or_0: C1_bridge0_rtl_d = 
          memread_regs_ln266_unr0_z;
        state_sort_unisim_sort_rb_sort[17]: C1_bridge0_rtl_d = 
          memread_regs_ln266_unr1_q;
        RB_W_LAST_CHUNKS_INNER_for_begin_or_0: C1_bridge0_rtl_d = 
          memread_regs_ln319_z;
        default: C1_bridge0_rtl_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        RB_RW_CHUNK_for_begin_unr0_or_0: C0_bridge0_rtl_d = 
          memread_regs_ln266_unr0_z;
        state_sort_unisim_sort_rb_sort[17]: C0_bridge0_rtl_d = 
          memread_regs_ln266_unr1_q;
        RB_W_LAST_CHUNKS_INNER_for_begin_or_0: C0_bridge0_rtl_d = 
          memread_regs_ln319_z;
        default: C0_bridge0_rtl_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln260_unr1_z: mux_i_ln260_unr1_d = {add_ln260_unr1_z[5:1], 
          mux_i_ln260_unr1_z[0]};
        mux_i_ln260_unr1_sel: mux_i_ln260_unr1_d = {add_ln260_unr1_1_q, 
          mux_i_ln260_unr1_q[0]};
        default: mux_i_ln260_unr1_d = 6'hX;
      endcase
      or_and_0_ln313_Z_0_z = mux_idx_0_ln312_z[1] | eq_ln313_z;
      if_ln313_z = ~eq_ln313_z;
      add_ln276_unr1_z = add_ln276_unr0_z + mux_pipe_full_ln248_z;
      A0_bridge1_rtl_CE_en = memread_sort_A0_ln264_unr1_en | 
      memread_sort_A0_ln264_unr0_en;
      A1_bridge1_rtl_CE_en = memread_sort_A1_ln268_unr1_en | 
      memread_sort_A1_ln268_unr0_en;
      C0_bridge0_rtl_CE_en = memwrite_sort_C0_ln319_en | 
      memwrite_sort_C0_ln266_unr1_en | memwrite_sort_C0_ln266_unr0_en;
      C1_bridge0_rtl_CE_en = memwrite_sort_C1_ln321_en | 
      memwrite_sort_C1_ln270_unr1_en | memwrite_sort_C1_ln270_unr0_en;
      if (sort_unisim_lt_float_ln284_unr0_unr0_z) 
        memread_regs_ln284_unr1_unr0_0_z = mux_regs_ln280_z[63:0];
      else 
        memread_regs_ln284_unr1_unr0_0_z = {mux_regs_ln280_z[31:0], 
        mux_regs_ln280_z[63:32]};
      if (sort_unisim_lt_float_ln284_unr1_unr0_z) 
        memread_regs_ln284_unr2_unr0_0_z = mux_regs_ln280_z[127:64];
      else 
        memread_regs_ln284_unr2_unr0_0_z = {mux_regs_ln280_z[95:64], 
        mux_regs_ln280_z[127:96]};
      if (sort_unisim_lt_float_ln284_unr2_unr0_z) 
        memread_regs_ln284_unr3_unr0_0_z = mux_regs_ln280_z[191:128];
      else 
        memread_regs_ln284_unr3_unr0_0_z = {mux_regs_ln280_z[159:128], 
        mux_regs_ln280_z[191:160]};
      if (sort_unisim_lt_float_ln284_unr11_unr0_z) 
        memread_regs_ln284_unr12_unr0_0_z = mux_regs_ln280_z[767:704];
      else 
        memread_regs_ln284_unr12_unr0_0_z = {mux_regs_ln280_z[735:704], 
        mux_regs_ln280_z[767:736]};
      if (sort_unisim_lt_float_ln284_unr12_unr0_z) 
        memread_regs_ln284_unr13_unr0_0_z = mux_regs_ln280_z[831:768];
      else 
        memread_regs_ln284_unr13_unr0_0_z = {mux_regs_ln280_z[799:768], 
        mux_regs_ln280_z[831:800]};
      if (sort_unisim_lt_float_ln284_unr13_unr0_z) 
        memread_regs_ln284_unr14_unr0_0_z = mux_regs_ln280_z[895:832];
      else 
        memread_regs_ln284_unr14_unr0_0_z = {mux_regs_ln280_z[863:832], 
        mux_regs_ln280_z[895:864]};
      if (sort_unisim_lt_float_ln284_unr14_unr0_z) 
        memread_regs_ln284_unr15_unr0_0_z = mux_regs_ln280_z[959:896];
      else 
        memread_regs_ln284_unr15_unr0_0_z = {mux_regs_ln280_z[927:896], 
        mux_regs_ln280_z[959:928]};
      if (sort_unisim_lt_float_ln284_unr15_unr0_z) 
        memread_regs_ln294_unr0_unr0_0_z = mux_regs_ln280_z[1023:960];
      else 
        memread_regs_ln294_unr0_unr0_0_z = {mux_regs_ln280_z[991:960], 
        mux_regs_ln280_z[1023:992]};
      if (sort_unisim_lt_float_ln284_unr3_unr0_z) 
        memread_regs_ln284_unr4_unr0_0_z = mux_regs_ln280_z[255:192];
      else 
        memread_regs_ln284_unr4_unr0_0_z = {mux_regs_ln280_z[223:192], 
        mux_regs_ln280_z[255:224]};
      if (sort_unisim_lt_float_ln284_unr4_unr0_z) 
        memread_regs_ln284_unr5_unr0_0_z = mux_regs_ln280_z[319:256];
      else 
        memread_regs_ln284_unr5_unr0_0_z = {mux_regs_ln280_z[287:256], 
        mux_regs_ln280_z[319:288]};
      if (sort_unisim_lt_float_ln284_unr5_unr0_z) 
        memread_regs_ln284_unr6_unr0_0_z = mux_regs_ln280_z[383:320];
      else 
        memread_regs_ln284_unr6_unr0_0_z = {mux_regs_ln280_z[351:320], 
        mux_regs_ln280_z[383:352]};
      if (sort_unisim_lt_float_ln284_unr6_unr0_z) 
        memread_regs_ln284_unr7_unr0_0_z = mux_regs_ln280_z[447:384];
      else 
        memread_regs_ln284_unr7_unr0_0_z = {mux_regs_ln280_z[415:384], 
        mux_regs_ln280_z[447:416]};
      if (sort_unisim_lt_float_ln284_unr7_unr0_z) 
        memread_regs_ln284_unr8_unr0_0_z = mux_regs_ln280_z[511:448];
      else 
        memread_regs_ln284_unr8_unr0_0_z = {mux_regs_ln280_z[479:448], 
        mux_regs_ln280_z[511:480]};
      if (sort_unisim_lt_float_ln284_unr8_unr0_z) 
        memread_regs_ln284_unr9_unr0_0_z = mux_regs_ln280_z[575:512];
      else 
        memread_regs_ln284_unr9_unr0_0_z = {mux_regs_ln280_z[543:512], 
        mux_regs_ln280_z[575:544]};
      if (sort_unisim_lt_float_ln284_unr9_unr0_z) 
        memread_regs_ln284_unr10_unr0_0_z = mux_regs_ln280_z[639:576];
      else 
        memread_regs_ln284_unr10_unr0_0_z = {mux_regs_ln280_z[607:576], 
        mux_regs_ln280_z[639:608]};
      if (sort_unisim_lt_float_ln284_unr10_unr0_z) 
        memread_regs_ln284_unr11_unr0_0_z = mux_regs_ln280_z[703:640];
      else 
        memread_regs_ln284_unr11_unr0_0_z = {mux_regs_ln280_z[671:640], 
        mux_regs_ln280_z[703:672]};
      if (sort_unisim_lt_float_ln284_unr0_unr1_z) 
        memread_regs_ln284_unr1_unr1_0_z = mux_regs_ln280_1_z[63:0];
      else 
        memread_regs_ln284_unr1_unr1_0_z = {mux_regs_ln280_1_z[31:0], 
        mux_regs_ln280_1_z[63:32]};
      if (sort_unisim_lt_float_ln284_unr1_unr1_z) 
        memread_regs_ln284_unr2_unr1_0_z = mux_regs_ln280_1_z[127:64];
      else 
        memread_regs_ln284_unr2_unr1_0_z = {mux_regs_ln280_1_z[95:64], 
        mux_regs_ln280_1_z[127:96]};
      if (sort_unisim_lt_float_ln284_unr2_unr1_z) 
        memread_regs_ln284_unr3_unr1_0_z = mux_regs_ln280_1_z[191:128];
      else 
        memread_regs_ln284_unr3_unr1_0_z = {mux_regs_ln280_1_z[159:128], 
        mux_regs_ln280_1_z[191:160]};
      if (sort_unisim_lt_float_ln284_unr3_unr1_z) 
        memread_regs_ln284_unr4_unr1_0_z = mux_regs_ln280_1_z[255:192];
      else 
        memread_regs_ln284_unr4_unr1_0_z = {mux_regs_ln280_1_z[223:192], 
        mux_regs_ln280_1_z[255:224]};
      if (sort_unisim_lt_float_ln284_unr4_unr1_z) 
        memread_regs_ln284_unr5_unr1_0_z = mux_regs_ln280_1_z[319:256];
      else 
        memread_regs_ln284_unr5_unr1_0_z = {mux_regs_ln280_1_z[287:256], 
        mux_regs_ln280_1_z[319:288]};
      if (sort_unisim_lt_float_ln284_unr5_unr1_z) 
        memread_regs_ln284_unr6_unr1_0_z = mux_regs_ln280_1_z[383:320];
      else 
        memread_regs_ln284_unr6_unr1_0_z = {mux_regs_ln280_1_z[351:320], 
        mux_regs_ln280_1_z[383:352]};
      if (sort_unisim_lt_float_ln284_unr6_unr1_z) 
        memread_regs_ln284_unr7_unr1_0_z = mux_regs_ln280_1_z[447:384];
      else 
        memread_regs_ln284_unr7_unr1_0_z = {mux_regs_ln280_1_z[415:384], 
        mux_regs_ln280_1_z[447:416]};
      if (sort_unisim_lt_float_ln284_unr7_unr1_z) 
        memread_regs_ln284_unr8_unr1_0_z = mux_regs_ln280_1_z[511:448];
      else 
        memread_regs_ln284_unr8_unr1_0_z = {mux_regs_ln280_1_z[479:448], 
        mux_regs_ln280_1_z[511:480]};
      if (sort_unisim_lt_float_ln284_unr8_unr1_z) 
        memread_regs_ln284_unr9_unr1_0_z = mux_regs_ln280_1_z[575:512];
      else 
        memread_regs_ln284_unr9_unr1_0_z = {mux_regs_ln280_1_z[543:512], 
        mux_regs_ln280_1_z[575:544]};
      if (sort_unisim_lt_float_ln284_unr9_unr1_z) 
        memread_regs_ln284_unr10_unr1_0_z = mux_regs_ln280_1_z[639:576];
      else 
        memread_regs_ln284_unr10_unr1_0_z = {mux_regs_ln280_1_z[607:576], 
        mux_regs_ln280_1_z[639:608]};
      if (sort_unisim_lt_float_ln284_unr10_unr1_z) 
        memread_regs_ln284_unr11_unr1_0_z = mux_regs_ln280_1_z[703:640];
      else 
        memread_regs_ln284_unr11_unr1_0_z = {mux_regs_ln280_1_z[671:640], 
        mux_regs_ln280_1_z[703:672]};
      if (sort_unisim_lt_float_ln284_unr11_unr1_z) 
        memread_regs_ln284_unr12_unr1_0_z = mux_regs_ln280_1_z[767:704];
      else 
        memread_regs_ln284_unr12_unr1_0_z = {mux_regs_ln280_1_z[735:704], 
        mux_regs_ln280_1_z[767:736]};
      if (sort_unisim_lt_float_ln284_unr12_unr1_z) 
        memread_regs_ln284_unr13_unr1_0_z = mux_regs_ln280_1_z[831:768];
      else 
        memread_regs_ln284_unr13_unr1_0_z = {mux_regs_ln280_1_z[799:768], 
        mux_regs_ln280_1_z[831:800]};
      if (sort_unisim_lt_float_ln284_unr13_unr1_z) 
        memread_regs_ln284_unr14_unr1_0_z = mux_regs_ln280_1_z[895:832];
      else 
        memread_regs_ln284_unr14_unr1_0_z = {mux_regs_ln280_1_z[863:832], 
        mux_regs_ln280_1_z[895:864]};
      if (sort_unisim_lt_float_ln284_unr14_unr1_z) 
        memread_regs_ln284_unr15_unr1_0_z = mux_regs_ln280_1_z[959:896];
      else 
        memread_regs_ln284_unr15_unr1_0_z = {mux_regs_ln280_1_z[927:896], 
        mux_regs_ln280_1_z[959:928]};
      if (sort_unisim_lt_float_ln284_unr15_unr1_z) 
        memread_regs_ln294_unr0_unr1_0_z = mux_regs_ln280_1_z[1023:960];
      else 
        memread_regs_ln294_unr0_unr1_0_z = {mux_regs_ln280_1_z[991:960], 
        mux_regs_ln280_1_z[1023:992]};
      ctrlAnd_1_ln230_z = !eq_ln230_z & ctrlOr_ln228_z;
      ctrlAnd_0_ln230_z = eq_ln230_z & ctrlOr_ln228_z;
      eq_ln255_unr1_z = {add_ln254_0_unr0_z[26:0], 5'h0} == 
      read_sort_len_ln224_q;
      if_ln249_z = ~eq_ln249_z;
      lt_ln248_z = mux_chunk_ln248_z[31] | lt_ln248_0_z;
      ctrlAnd_0_ln313_z = or_and_0_ln313_Z_0_z & ctrlOr_ln312_0_z;
      and_1_ln313_z = if_ln313_z & lt_ln312_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln284_unr1_unr0_0_d = {
          memread_regs_ln294_unr0_unr0_0_z[63:32], 
          memread_regs_ln284_unr1_unr0_0_z[31:0]};
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln284_unr1_unr0_0_d = {
          memread_regs_ln294_unr0_unr0_0_32_q, memread_regs_ln284_unr1_unr0_0_q};
        default: memread_regs_ln284_unr1_unr0_0_d = 64'hX;
      endcase
      ctrlOr_ln234_z = ctrlAnd_0_ln234_z | ctrlAnd_1_ln230_z;
      ctrlOr_ln232_z = state_sort_unisim_sort_rb_sort[2] | ctrlAnd_0_ln230_z;
      if_ln255_unr1_z = ~eq_ln255_unr1_z;
      if_ln248_z = ~lt_ln248_z;
      and_1_ln255_unr0_z = lt_ln248_z & if_ln249_z;
      rb_done_hold = ~(ctrlAnd_1_ln328_z | ctrlAnd_0_ln313_z);
      ctrlOr_ln328_z = ctrlAnd_0_ln328_z | ctrlAnd_0_ln313_z;
      ctrlAnd_1_ln313_z = and_1_ln313_z & ctrlOr_ln312_0_z;
      if (sort_unisim_lt_float_ln294_unr14_unr0_z) begin
        mux_regs_ln260_1_z = {memread_regs_ln294_unr0_unr0_0_z[31:0], 
        memread_regs_ln284_unr15_unr0_0_z[63:32]};
        mux_regs_ln280_0_z = {memread_regs_ln294_unr0_unr0_0_z[31:0], 
        memread_regs_ln284_unr15_unr0_0_z[63:32]};
        mux_regs_ln254_0_z = {memread_regs_ln294_unr0_unr0_0_z[31:0], 
        memread_regs_ln284_unr15_unr0_0_z[63:32]};
      end
      else begin
        mux_regs_ln260_1_z = {memread_regs_ln284_unr15_unr0_0_z[63:32], 
        memread_regs_ln294_unr0_unr0_0_z[31:0]};
        mux_regs_ln280_0_z = {memread_regs_ln284_unr15_unr0_0_z[63:32], 
        memread_regs_ln294_unr0_unr0_0_z[31:0]};
        mux_regs_ln254_0_z = {memread_regs_ln284_unr15_unr0_0_z[63:32], 
        memread_regs_ln294_unr0_unr0_0_z[31:0]};
      end
      if (sort_unisim_lt_float_ln294_unr14_unr1_z) begin
        mux_regs_ln280_2_z = {memread_regs_ln294_unr0_unr1_0_z[31:0], 
        memread_regs_ln284_unr15_unr1_0_z[63:32]};
        mux_regs_ln254_1_z = {memread_regs_ln294_unr0_unr1_0_z[31:0], 
        memread_regs_ln284_unr15_unr1_0_z[63:32]};
      end
      else begin
        mux_regs_ln280_2_z = {memread_regs_ln284_unr15_unr1_0_z[63:32], 
        memread_regs_ln294_unr0_unr1_0_z[31:0]};
        mux_regs_ln254_1_z = {memread_regs_ln284_unr15_unr1_0_z[63:32], 
        memread_regs_ln294_unr0_unr1_0_z[31:0]};
      end
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1024_d_0 = mux_mux_regs_ln228_Z_1024_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1024_d_0 = mux_regs_ln228_q[1087:1024];
        default: mux_regs_ln228_1024_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1088_d_0 = mux_mux_regs_ln228_Z_1088_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1088_d_0 = mux_regs_ln228_q[1151:1088];
        default: mux_regs_ln228_1088_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1152_d_0 = mux_mux_regs_ln228_Z_1152_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1152_d_0 = mux_regs_ln228_q[1215:1152];
        default: mux_regs_ln228_1152_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1216_d_0 = mux_mux_regs_ln228_Z_1216_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1216_d_0 = mux_regs_ln228_q[1279:1216];
        default: mux_regs_ln228_1216_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1280_d_0 = mux_mux_regs_ln228_Z_1280_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1280_d_0 = mux_regs_ln228_q[1343:1280];
        default: mux_regs_ln228_1280_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_128_d_0 = mux_mux_regs_ln228_Z_128_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_128_d_0 = mux_regs_ln228_q[191:128];
        default: mux_regs_ln228_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1344_d_0 = mux_mux_regs_ln228_Z_1344_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1344_d_0 = mux_regs_ln228_q[1407:1344];
        default: mux_regs_ln228_1344_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1408_d_0 = mux_mux_regs_ln228_Z_1408_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1408_d_0 = mux_regs_ln228_q[1471:1408];
        default: mux_regs_ln228_1408_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1472_d_0 = mux_mux_regs_ln228_Z_1472_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1472_d_0 = mux_regs_ln228_q[1535:1472];
        default: mux_regs_ln228_1472_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1536_d_0 = mux_mux_regs_ln228_Z_1536_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1536_d_0 = mux_regs_ln228_q[1599:1536];
        default: mux_regs_ln228_1536_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1600_d_0 = mux_mux_regs_ln228_Z_1600_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1600_d_0 = mux_regs_ln228_q[1663:1600];
        default: mux_regs_ln228_1600_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1664_d_0 = mux_mux_regs_ln228_Z_1664_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1664_d_0 = mux_regs_ln228_q[1727:1664];
        default: mux_regs_ln228_1664_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1728_d_0 = mux_mux_regs_ln228_Z_1728_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1728_d_0 = mux_regs_ln228_q[1791:1728];
        default: mux_regs_ln228_1728_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1792_d_0 = mux_mux_regs_ln228_Z_1792_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1792_d_0 = mux_regs_ln228_q[1855:1792];
        default: mux_regs_ln228_1792_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1856_d_0 = mux_mux_regs_ln228_Z_1856_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1856_d_0 = mux_regs_ln228_q[1919:1856];
        default: mux_regs_ln228_1856_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1920_d_0 = mux_mux_regs_ln228_Z_1920_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1920_d_0 = mux_regs_ln228_q[1983:1920];
        default: mux_regs_ln228_1920_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_192_d_0 = mux_mux_regs_ln228_Z_192_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_192_d_0 = mux_regs_ln228_q[255:192];
        default: mux_regs_ln228_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_1984_d_0 = mux_mux_regs_ln228_Z_1984_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_1984_d_0 = mux_regs_ln228_q[2047:1984];
        default: mux_regs_ln228_1984_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_256_d_0 = mux_mux_regs_ln228_Z_256_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_256_d_0 = mux_regs_ln228_q[319:256];
        default: mux_regs_ln228_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_320_d_0 = mux_mux_regs_ln228_Z_320_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_320_d_0 = mux_regs_ln228_q[383:320];
        default: mux_regs_ln228_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_384_d_0 = mux_mux_regs_ln228_Z_384_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_384_d_0 = mux_regs_ln228_q[447:384];
        default: mux_regs_ln228_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_448_d_0 = mux_mux_regs_ln228_Z_448_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_448_d_0 = mux_regs_ln228_q[511:448];
        default: mux_regs_ln228_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_512_d_0 = mux_mux_regs_ln228_Z_512_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_512_d_0 = mux_regs_ln228_q[575:512];
        default: mux_regs_ln228_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_576_d_0 = mux_mux_regs_ln228_Z_576_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_576_d_0 = mux_regs_ln228_q[639:576];
        default: mux_regs_ln228_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_640_d_0 = mux_mux_regs_ln228_Z_640_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_640_d_0 = mux_regs_ln228_q[703:640];
        default: mux_regs_ln228_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_64_d_0 = mux_mux_regs_ln228_Z_64_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_64_d_0 = mux_regs_ln228_q[127:64];
        default: mux_regs_ln228_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_704_d_0 = mux_mux_regs_ln228_Z_704_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_704_d_0 = mux_regs_ln228_q[767:704];
        default: mux_regs_ln228_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_768_d_0 = mux_mux_regs_ln228_Z_768_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_768_d_0 = mux_regs_ln228_q[831:768];
        default: mux_regs_ln228_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_832_d_0 = mux_mux_regs_ln228_Z_832_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_832_d_0 = mux_regs_ln228_q[895:832];
        default: mux_regs_ln228_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_896_d_0 = mux_mux_regs_ln228_Z_896_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_896_d_0 = mux_regs_ln228_q[959:896];
        default: mux_regs_ln228_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_960_d_0 = mux_mux_regs_ln228_Z_960_v_0;
        mux_regs_ln228_sel: mux_regs_ln228_960_d_0 = mux_regs_ln228_q[1023:960];
        default: mux_regs_ln228_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_regs_ln228_d = mux_mux_regs_ln228_Z_v;
        mux_regs_ln228_sel: mux_regs_ln228_d = mux_regs_ln228_q[63:0];
        default: mux_regs_ln228_d = 64'hX;
      endcase
      or_and_0_ln249_Z_0_z = if_ln248_z | eq_ln249_z;
      ctrlAnd_1_ln255_unr0_z = and_1_ln255_unr0_z & ctrlOr_ln248_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln313_z: rb_done_d = 1'b1;
        ctrlAnd_1_ln328_z: rb_done_d = 1'b0;
        rb_done_hold: rb_done_d = rb_done;
        default: rb_done_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln313_z: mux_idx_0_ln312_d_0 = {add_ln324_z[4:1], 
          mux_wchunk_ln312_z, mux_idx_0_ln312_z[0]};
        ctrlOr_ln317_z: mux_idx_0_ln312_d_0 = {add_ln324_1_q, mux_wchunk_ln312_q, 
          mux_idx_0_ln312_q};
        default: mux_idx_0_ln312_d_0 = 10'hX;
      endcase
      mux_regs_ln248_1024_mux_0_sel_0 = state_sort_unisim_sort_rb_sort[12] | 
      ctrlOr_ln331_z | ctrlOr_ln328_z | ctrlOr_ln317_z | ctrlOr_ln280_unr0_z | 
      ctrlOr_ln260_unr0_z | ctrlAnd_1_ln313_z | ctrlAnd_1_ln260_unr0_z | 
      ctrlAnd_1_ln255_unr1_z;
      mux_regs_ln248_reg_0_sel = ctrlOr_ln331_z | ctrlOr_ln328_z | 
      ctrlOr_ln317_z | ctrlAnd_1_ln313_z;
      if (sort_unisim_lt_float_ln294_unr0_unr0_z) 
        memread_regs_ln294_unr1_unr0_0_z = {memread_regs_ln284_unr2_unr0_0_z[31:
        0], memread_regs_ln284_unr1_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr1_unr0_0_z = {memread_regs_ln284_unr1_unr0_0_z[63:
        32], memread_regs_ln284_unr2_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr1_unr0_z) 
        memread_regs_ln294_unr2_unr0_0_z = {memread_regs_ln284_unr3_unr0_0_z[31:
        0], memread_regs_ln284_unr2_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr2_unr0_0_z = {memread_regs_ln284_unr2_unr0_0_z[63:
        32], memread_regs_ln284_unr3_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr11_unr0_z) 
        memread_regs_ln294_unr12_unr0_0_z = {memread_regs_ln284_unr13_unr0_0_z[
        31:0], memread_regs_ln284_unr12_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr12_unr0_0_z = {memread_regs_ln284_unr12_unr0_0_z[
        63:32], memread_regs_ln284_unr13_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr12_unr0_z) 
        memread_regs_ln294_unr13_unr0_0_z = {memread_regs_ln284_unr14_unr0_0_z[
        31:0], memread_regs_ln284_unr13_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr13_unr0_0_z = {memread_regs_ln284_unr13_unr0_0_z[
        63:32], memread_regs_ln284_unr14_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr13_unr0_z) 
        memread_regs_ln294_unr14_unr0_0_z = {memread_regs_ln284_unr15_unr0_0_z[
        31:0], memread_regs_ln284_unr14_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr14_unr0_0_z = {memread_regs_ln284_unr14_unr0_0_z[
        63:32], memread_regs_ln284_unr15_unr0_0_z[31:0]};
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: mux_regs_ln260_1_d = mux_regs_ln260_1_z;
        memread_regs_ln284_unr1_unr0_0_sel: mux_regs_ln260_1_d = 
          mux_regs_ln260_1_q;
        default: mux_regs_ln260_1_d = 64'hX;
      endcase
      if (sort_unisim_lt_float_ln294_unr2_unr0_z) 
        memread_regs_ln294_unr3_unr0_0_z = {memread_regs_ln284_unr4_unr0_0_z[31:
        0], memread_regs_ln284_unr3_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr3_unr0_0_z = {memread_regs_ln284_unr3_unr0_0_z[63:
        32], memread_regs_ln284_unr4_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr3_unr0_z) 
        memread_regs_ln294_unr4_unr0_0_z = {memread_regs_ln284_unr5_unr0_0_z[31:
        0], memread_regs_ln284_unr4_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr4_unr0_0_z = {memread_regs_ln284_unr4_unr0_0_z[63:
        32], memread_regs_ln284_unr5_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr4_unr0_z) 
        memread_regs_ln294_unr5_unr0_0_z = {memread_regs_ln284_unr6_unr0_0_z[31:
        0], memread_regs_ln284_unr5_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr5_unr0_0_z = {memread_regs_ln284_unr5_unr0_0_z[63:
        32], memread_regs_ln284_unr6_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr5_unr0_z) 
        memread_regs_ln294_unr6_unr0_0_z = {memread_regs_ln284_unr7_unr0_0_z[31:
        0], memread_regs_ln284_unr6_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr6_unr0_0_z = {memread_regs_ln284_unr6_unr0_0_z[63:
        32], memread_regs_ln284_unr7_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr6_unr0_z) 
        memread_regs_ln294_unr7_unr0_0_z = {memread_regs_ln284_unr8_unr0_0_z[31:
        0], memread_regs_ln284_unr7_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr7_unr0_0_z = {memread_regs_ln284_unr7_unr0_0_z[63:
        32], memread_regs_ln284_unr8_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr7_unr0_z) 
        memread_regs_ln294_unr8_unr0_0_z = {memread_regs_ln284_unr9_unr0_0_z[31:
        0], memread_regs_ln284_unr8_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr8_unr0_0_z = {memread_regs_ln284_unr8_unr0_0_z[63:
        32], memread_regs_ln284_unr9_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr8_unr0_z) 
        memread_regs_ln294_unr9_unr0_0_z = {memread_regs_ln284_unr10_unr0_0_z[31:
        0], memread_regs_ln284_unr9_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr9_unr0_0_z = {memread_regs_ln284_unr9_unr0_0_z[63:
        32], memread_regs_ln284_unr10_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr9_unr0_z) 
        memread_regs_ln294_unr10_unr0_0_z = {memread_regs_ln284_unr11_unr0_0_z[
        31:0], memread_regs_ln284_unr10_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr10_unr0_0_z = {memread_regs_ln284_unr10_unr0_0_z[
        63:32], memread_regs_ln284_unr11_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr10_unr0_z) 
        memread_regs_ln294_unr11_unr0_0_z = {memread_regs_ln284_unr12_unr0_0_z[
        31:0], memread_regs_ln284_unr11_unr0_0_z[63:32]};
      else 
        memread_regs_ln294_unr11_unr0_0_z = {memread_regs_ln284_unr11_unr0_0_z[
        63:32], memread_regs_ln284_unr12_unr0_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr0_unr1_z) 
        memread_regs_ln294_unr1_unr1_0_z = {memread_regs_ln284_unr2_unr1_0_z[31:
        0], memread_regs_ln284_unr1_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr1_unr1_0_z = {memread_regs_ln284_unr1_unr1_0_z[63:
        32], memread_regs_ln284_unr2_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr1_unr1_z) 
        memread_regs_ln294_unr2_unr1_0_z = {memread_regs_ln284_unr3_unr1_0_z[31:
        0], memread_regs_ln284_unr2_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr2_unr1_0_z = {memread_regs_ln284_unr2_unr1_0_z[63:
        32], memread_regs_ln284_unr3_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr2_unr1_z) 
        memread_regs_ln294_unr3_unr1_0_z = {memread_regs_ln284_unr4_unr1_0_z[31:
        0], memread_regs_ln284_unr3_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr3_unr1_0_z = {memread_regs_ln284_unr3_unr1_0_z[63:
        32], memread_regs_ln284_unr4_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr3_unr1_z) 
        memread_regs_ln294_unr4_unr1_0_z = {memread_regs_ln284_unr5_unr1_0_z[31:
        0], memread_regs_ln284_unr4_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr4_unr1_0_z = {memread_regs_ln284_unr4_unr1_0_z[63:
        32], memread_regs_ln284_unr5_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr4_unr1_z) 
        memread_regs_ln294_unr5_unr1_0_z = {memread_regs_ln284_unr6_unr1_0_z[31:
        0], memread_regs_ln284_unr5_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr5_unr1_0_z = {memread_regs_ln284_unr5_unr1_0_z[63:
        32], memread_regs_ln284_unr6_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr5_unr1_z) 
        memread_regs_ln294_unr6_unr1_0_z = {memread_regs_ln284_unr7_unr1_0_z[31:
        0], memread_regs_ln284_unr6_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr6_unr1_0_z = {memread_regs_ln284_unr6_unr1_0_z[63:
        32], memread_regs_ln284_unr7_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr6_unr1_z) 
        memread_regs_ln294_unr7_unr1_0_z = {memread_regs_ln284_unr8_unr1_0_z[31:
        0], memread_regs_ln284_unr7_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr7_unr1_0_z = {memread_regs_ln284_unr7_unr1_0_z[63:
        32], memread_regs_ln284_unr8_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr7_unr1_z) 
        memread_regs_ln294_unr8_unr1_0_z = {memread_regs_ln284_unr9_unr1_0_z[31:
        0], memread_regs_ln284_unr8_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr8_unr1_0_z = {memread_regs_ln284_unr8_unr1_0_z[63:
        32], memread_regs_ln284_unr9_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr8_unr1_z) 
        memread_regs_ln294_unr9_unr1_0_z = {memread_regs_ln284_unr10_unr1_0_z[31:
        0], memread_regs_ln284_unr9_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr9_unr1_0_z = {memread_regs_ln284_unr9_unr1_0_z[63:
        32], memread_regs_ln284_unr10_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr9_unr1_z) 
        memread_regs_ln294_unr10_unr1_0_z = {memread_regs_ln284_unr11_unr1_0_z[
        31:0], memread_regs_ln284_unr10_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr10_unr1_0_z = {memread_regs_ln284_unr10_unr1_0_z[
        63:32], memread_regs_ln284_unr11_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr10_unr1_z) 
        memread_regs_ln294_unr11_unr1_0_z = {memread_regs_ln284_unr12_unr1_0_z[
        31:0], memread_regs_ln284_unr11_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr11_unr1_0_z = {memread_regs_ln284_unr11_unr1_0_z[
        63:32], memread_regs_ln284_unr12_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr11_unr1_z) 
        memread_regs_ln294_unr12_unr1_0_z = {memread_regs_ln284_unr13_unr1_0_z[
        31:0], memread_regs_ln284_unr12_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr12_unr1_0_z = {memread_regs_ln284_unr12_unr1_0_z[
        63:32], memread_regs_ln284_unr13_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr12_unr1_z) 
        memread_regs_ln294_unr13_unr1_0_z = {memread_regs_ln284_unr14_unr1_0_z[
        31:0], memread_regs_ln284_unr13_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr13_unr1_0_z = {memread_regs_ln284_unr13_unr1_0_z[
        63:32], memread_regs_ln284_unr14_unr1_0_z[31:0]};
      if (sort_unisim_lt_float_ln294_unr13_unr1_z) 
        memread_regs_ln294_unr14_unr1_0_z = {memread_regs_ln284_unr15_unr1_0_z[
        31:0], memread_regs_ln284_unr14_unr1_0_z[63:32]};
      else 
        memread_regs_ln294_unr14_unr1_0_z = {memread_regs_ln284_unr14_unr1_0_z[
        63:32], memread_regs_ln284_unr15_unr1_0_z[31:0]};
      ctrlAnd_0_ln249_z = or_and_0_ln249_Z_0_z & ctrlOr_ln248_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln255_unr0_z: add_ln276_unr0_d = {add_ln254_0_unr0_z[4:1], 
          add_ln276_unr0_z};
        mux_pipe_full_ln248_Z_0_tag_sel: add_ln276_unr0_d = {
          add_ln254_0_unr0_1_q[3:0], add_ln276_unr0_q};
        default: add_ln276_unr0_d = 9'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln255_unr0_z: mux_chunk_ln248_2_d_0 = {mux_wchunk_ln248_z, 
          mux_chunk_ln248_z[4:2]};
        mux_chunk_ln248_2_mux_0_sel: mux_chunk_ln248_2_d_0 = {mux_wchunk_ln248_q, 
          mux_chunk_ln248_q[4:2]};
        default: mux_chunk_ln248_2_d_0 = 8'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln255_unr0_z: mux_chunk_ln248_d = {add_ln276_unr1_z, 
          add_ln254_0_unr1_z[30:1], mux_chunk_ln248_z[1:0]};
        mux_chunk_ln248_sel: mux_chunk_ln248_d = {add_ln276_unr1_q, 
          add_ln254_0_unr1_1_q, mux_chunk_ln248_q[1:0]};
        default: mux_chunk_ln248_d = 37'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln255_unr0_z: mux_pipe_full_ln248_Z_0_tag_d = 
          mux_pipe_full_ln248_z;
        mux_pipe_full_ln248_Z_0_tag_sel: mux_pipe_full_ln248_Z_0_tag_d = 
          mux_pipe_full_ln248_Z_0_tag_0;
        default: mux_pipe_full_ln248_Z_0_tag_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln255_unr0_z: add_ln254_0_unr0_1_4_d_0 = {eq_ln255_unr1_z, 
          add_ln254_0_unr0_z[31:5]};
        add_ln254_0_unr0_1_4_mux_0_sel: add_ln254_0_unr0_1_4_d_0 = {
          eq_ln255_unr1_q, add_ln254_0_unr0_1_q[30:4]};
        default: add_ln254_0_unr0_1_4_d_0 = 28'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr1_unr0_0_d = 
          memread_regs_ln294_unr1_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr1_unr0_0_d = 
          memread_regs_ln294_unr1_unr0_0_q;
        default: memread_regs_ln294_unr1_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr2_unr0_0_d = 
          memread_regs_ln294_unr2_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr2_unr0_0_d = 
          memread_regs_ln294_unr2_unr0_0_q;
        default: memread_regs_ln294_unr2_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr12_unr0_0_d = 
          memread_regs_ln294_unr12_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr12_unr0_0_d = 
          memread_regs_ln294_unr12_unr0_0_q;
        default: memread_regs_ln294_unr12_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr13_unr0_0_d = 
          memread_regs_ln294_unr13_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr13_unr0_0_d = 
          memread_regs_ln294_unr13_unr0_0_q;
        default: memread_regs_ln294_unr13_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr14_unr0_0_d = 
          memread_regs_ln294_unr14_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr14_unr0_0_d = 
          memread_regs_ln294_unr14_unr0_0_q;
        default: memread_regs_ln294_unr14_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr3_unr0_0_d = 
          memread_regs_ln294_unr3_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr3_unr0_0_d = 
          memread_regs_ln294_unr3_unr0_0_q;
        default: memread_regs_ln294_unr3_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr4_unr0_0_d = 
          memread_regs_ln294_unr4_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr4_unr0_0_d = 
          memread_regs_ln294_unr4_unr0_0_q;
        default: memread_regs_ln294_unr4_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr5_unr0_0_d = 
          memread_regs_ln294_unr5_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr5_unr0_0_d = 
          memread_regs_ln294_unr5_unr0_0_q;
        default: memread_regs_ln294_unr5_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr6_unr0_0_d = 
          memread_regs_ln294_unr6_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr6_unr0_0_d = 
          memread_regs_ln294_unr6_unr0_0_q;
        default: memread_regs_ln294_unr6_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr7_unr0_0_d = 
          memread_regs_ln294_unr7_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr7_unr0_0_d = 
          memread_regs_ln294_unr7_unr0_0_q;
        default: memread_regs_ln294_unr7_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr8_unr0_0_d = 
          memread_regs_ln294_unr8_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr8_unr0_0_d = 
          memread_regs_ln294_unr8_unr0_0_q;
        default: memread_regs_ln294_unr8_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr9_unr0_0_d = 
          memread_regs_ln294_unr9_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr9_unr0_0_d = 
          memread_regs_ln294_unr9_unr0_0_q;
        default: memread_regs_ln294_unr9_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr10_unr0_0_d = 
          memread_regs_ln294_unr10_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr10_unr0_0_d = 
          memread_regs_ln294_unr10_unr0_0_q;
        default: memread_regs_ln294_unr10_unr0_0_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln280_unr0_z: memread_regs_ln294_unr11_unr0_0_d = 
          memread_regs_ln294_unr11_unr0_0_z;
        memread_regs_ln284_unr1_unr0_0_sel: memread_regs_ln294_unr11_unr0_0_d = 
          memread_regs_ln294_unr11_unr0_0_q;
        default: memread_regs_ln294_unr11_unr0_0_d = 64'hX;
      endcase
      mux_ping_ln228_sel = state_sort_unisim_sort_rb_sort[12] | 
      state_sort_unisim_sort_rb_sort[18] | ctrlOr_ln331_z | ctrlOr_ln328_z | 
      ctrlOr_ln317_z | ctrlOr_ln280_unr1_z | ctrlOr_ln280_unr0_z | 
      ctrlOr_ln260_unr1_z | ctrlOr_ln260_unr0_z | ctrlOr_ln237_z | 
      ctrlAnd_1_ln313_z | ctrlAnd_1_ln260_unr1_z | ctrlAnd_1_ln260_unr0_z | 
      ctrlAnd_1_ln255_unr1_z | ctrlAnd_1_ln255_unr0_z | ctrlAnd_1_ln237_z | 
      ctrlAnd_0_ln260_unr1_z | ctrlAnd_0_ln249_z;
      mux_regs_ln248_1024_mux_0_sel = ctrlAnd_1_ln255_unr0_z | ctrlAnd_0_ln249_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_128_d_0 = mux_regs_ln248_z[191:
          128];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_128_d_0 = 
          mux_regs_ln248_reg_0_0[191:128];
        default: mux_regs_ln248_reg_0_128_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_192_d_0 = mux_regs_ln248_z[255:
          192];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_192_d_0 = 
          mux_regs_ln248_reg_0_0[255:192];
        default: mux_regs_ln248_reg_0_192_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_256_d_0 = mux_regs_ln248_z[319:
          256];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_256_d_0 = 
          mux_regs_ln248_reg_0_0[319:256];
        default: mux_regs_ln248_reg_0_256_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_320_d_0 = mux_regs_ln248_z[383:
          320];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_320_d_0 = 
          mux_regs_ln248_reg_0_0[383:320];
        default: mux_regs_ln248_reg_0_320_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_384_d_0 = mux_regs_ln248_z[447:
          384];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_384_d_0 = 
          mux_regs_ln248_reg_0_0[447:384];
        default: mux_regs_ln248_reg_0_384_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_448_d_0 = mux_regs_ln248_z[511:
          448];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_448_d_0 = 
          mux_regs_ln248_reg_0_0[511:448];
        default: mux_regs_ln248_reg_0_448_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_512_d_0 = mux_regs_ln248_z[575:
          512];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_512_d_0 = 
          mux_regs_ln248_reg_0_0[575:512];
        default: mux_regs_ln248_reg_0_512_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_576_d_0 = mux_regs_ln248_z[639:
          576];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_576_d_0 = 
          mux_regs_ln248_reg_0_0[639:576];
        default: mux_regs_ln248_reg_0_576_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_640_d_0 = mux_regs_ln248_z[703:
          640];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_640_d_0 = 
          mux_regs_ln248_reg_0_0[703:640];
        default: mux_regs_ln248_reg_0_640_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_64_d_0 = mux_regs_ln248_z[127:64];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_64_d_0 = 
          mux_regs_ln248_reg_0_0[127:64];
        default: mux_regs_ln248_reg_0_64_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_704_d_0 = mux_regs_ln248_z[767:
          704];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_704_d_0 = 
          mux_regs_ln248_reg_0_0[767:704];
        default: mux_regs_ln248_reg_0_704_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_768_d_0 = mux_regs_ln248_z[831:
          768];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_768_d_0 = 
          mux_regs_ln248_reg_0_0[831:768];
        default: mux_regs_ln248_reg_0_768_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_832_d_0 = mux_regs_ln248_z[895:
          832];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_832_d_0 = 
          mux_regs_ln248_reg_0_0[895:832];
        default: mux_regs_ln248_reg_0_832_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_896_d_0 = mux_regs_ln248_z[959:
          896];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_896_d_0 = 
          mux_regs_ln248_reg_0_0[959:896];
        default: mux_regs_ln248_reg_0_896_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_960_d_0 = mux_regs_ln248_z[1023:
          960];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_960_d_0 = 
          mux_regs_ln248_reg_0_0[1023:960];
        default: mux_regs_ln248_reg_0_960_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln249_z: mux_regs_ln248_reg_0_d = mux_regs_ln248_z[63:0];
        mux_regs_ln248_reg_0_sel: mux_regs_ln248_reg_0_d = 
          mux_regs_ln248_reg_0_0[63:0];
        default: mux_regs_ln248_reg_0_d = 64'hX;
      endcase
      read_sort_len_ln224_sel = state_sort_unisim_sort_rb_sort[12] | 
      state_sort_unisim_sort_rb_sort[18] | ctrlOr_ln331_z | ctrlOr_ln328_z | 
      ctrlOr_ln317_z | ctrlOr_ln280_unr1_z | ctrlOr_ln280_unr0_z | 
      ctrlOr_ln260_unr1_z | ctrlOr_ln260_unr0_z | ctrlOr_ln237_z | 
      ctrlOr_ln234_z | ctrlAnd_1_ln313_z | ctrlAnd_1_ln260_unr1_z | 
      ctrlAnd_1_ln260_unr0_z | ctrlAnd_1_ln255_unr1_z | ctrlAnd_1_ln255_unr0_z | 
      ctrlAnd_1_ln237_z | ctrlAnd_0_ln260_unr1_z | ctrlAnd_0_ln249_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_ping_ln228_d = mux_mux_ping_ln228_Z_0_v;
        mux_ping_ln228_sel: mux_ping_ln228_d = mux_ping_ln228_q;
        default: mux_ping_ln228_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln234_z: mux_burst_ln228_d_0 = {mux_add_ln334_Z_1_v_0, 
          mux_mux_burst_ln228_Z_0_v};
        mux_ping_ln228_sel: mux_burst_ln228_d_0 = {add_ln334_1_q, 
          mux_burst_ln228_q};
        default: mux_burst_ln228_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1088_d_0 = 
          mux_regs_ln248_z[1151:1088];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1088_d_0 = 
          mux_regs_ln248_q[1151:1088];
        default: mux_regs_ln248_1088_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1152_d_0 = 
          mux_regs_ln248_z[1215:1152];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1152_d_0 = 
          mux_regs_ln248_q[1215:1152];
        default: mux_regs_ln248_1152_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1216_d_0 = 
          mux_regs_ln248_z[1279:1216];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1216_d_0 = 
          mux_regs_ln248_q[1279:1216];
        default: mux_regs_ln248_1216_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1280_d_0 = 
          mux_regs_ln248_z[1343:1280];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1280_d_0 = 
          mux_regs_ln248_q[1343:1280];
        default: mux_regs_ln248_1280_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1344_d_0 = 
          mux_regs_ln248_z[1407:1344];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1344_d_0 = 
          mux_regs_ln248_q[1407:1344];
        default: mux_regs_ln248_1344_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1408_d_0 = 
          mux_regs_ln248_z[1471:1408];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1408_d_0 = 
          mux_regs_ln248_q[1471:1408];
        default: mux_regs_ln248_1408_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1472_d_0 = 
          mux_regs_ln248_z[1535:1472];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1472_d_0 = 
          mux_regs_ln248_q[1535:1472];
        default: mux_regs_ln248_1472_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1536_d_0 = 
          mux_regs_ln248_z[1599:1536];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1536_d_0 = 
          mux_regs_ln248_q[1599:1536];
        default: mux_regs_ln248_1536_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1600_d_0 = 
          mux_regs_ln248_z[1663:1600];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1600_d_0 = 
          mux_regs_ln248_q[1663:1600];
        default: mux_regs_ln248_1600_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1664_d_0 = 
          mux_regs_ln248_z[1727:1664];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1664_d_0 = 
          mux_regs_ln248_q[1727:1664];
        default: mux_regs_ln248_1664_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1728_d_0 = 
          mux_regs_ln248_z[1791:1728];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1728_d_0 = 
          mux_regs_ln248_q[1791:1728];
        default: mux_regs_ln248_1728_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1792_d_0 = 
          mux_regs_ln248_z[1855:1792];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1792_d_0 = 
          mux_regs_ln248_q[1855:1792];
        default: mux_regs_ln248_1792_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1856_d_0 = 
          mux_regs_ln248_z[1919:1856];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1856_d_0 = 
          mux_regs_ln248_q[1919:1856];
        default: mux_regs_ln248_1856_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1920_d_0 = 
          mux_regs_ln248_z[1983:1920];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1920_d_0 = 
          mux_regs_ln248_q[1983:1920];
        default: mux_regs_ln248_1920_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1984_d_0 = 
          mux_regs_ln248_z[2047:1984];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1984_d_0 = 
          mux_regs_ln248_q[2047:1984];
        default: mux_regs_ln248_1984_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_regs_ln248_1024_mux_0_sel: mux_regs_ln248_1024_d_0 = 
          mux_regs_ln248_z[1087:1024];
        mux_regs_ln248_1024_mux_0_sel_0: mux_regs_ln248_1024_d_0 = 
          mux_regs_ln248_q[1087:1024];
        default: mux_regs_ln248_1024_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln218_z: read_sort_len_ln224_d = {batch, len};
        read_sort_len_ln224_sel: read_sort_len_ln224_d = {
          read_sort_batch_ln225_q, read_sort_len_ln224_q};
        default: read_sort_len_ln224_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_rb_sort[0]: // Wait_ln218
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln218_z: state_sort_unisim_sort_rb_sort_next[0] = 1'b1;
              ctrlAnd_1_ln218_z: state_sort_unisim_sort_rb_sort_next[1] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[1]: // expand_ln228
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln232_z: state_sort_unisim_sort_rb_sort_next[2] = 1'b1;
              ctrlOr_ln234_z: state_sort_unisim_sort_rb_sort_next[3] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[2]: // Wait_ln232
          state_sort_unisim_sort_rb_sort_next[2] = 1'b1;
        state_sort_unisim_sort_rb_sort[3]: // Wait_ln234
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln234_z: state_sort_unisim_sort_rb_sort_next[3] = 1'b1;
              ctrlOr_ln237_z: state_sort_unisim_sort_rb_sort_next[4] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[4]: // Wait_ln237
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln237_z: state_sort_unisim_sort_rb_sort_next[4] = 1'b1;
              ctrlAnd_1_ln237_z: state_sort_unisim_sort_rb_sort_next[5] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[5]: // expand_ln248
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln249_z: state_sort_unisim_sort_rb_sort_next[6] = 1'b1;
              ctrlAnd_1_ln255_unr0_z: state_sort_unisim_sort_rb_sort_next[11] = 
                1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[6]: // expand_ln312
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln328_z: state_sort_unisim_sort_rb_sort_next[7] = 1'b1;
              ctrlAnd_1_ln313_z: state_sort_unisim_sort_rb_sort_next[9] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[7]: // Wait_ln328
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln328_z: state_sort_unisim_sort_rb_sort_next[7] = 1'b1;
              ctrlOr_ln331_z: state_sort_unisim_sort_rb_sort_next[8] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[8]: // Wait_ln331
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln331_z: state_sort_unisim_sort_rb_sort_next[8] = 1'b1;
              ctrlOr_ln232_z: state_sort_unisim_sort_rb_sort_next[2] = 1'b1;
              ctrlOr_ln234_z: state_sort_unisim_sort_rb_sort_next[3] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[9]: // expand_ln317
          state_sort_unisim_sort_rb_sort_next[10] = 1'b1;
        state_sort_unisim_sort_rb_sort[10]: // Wait_ln322
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln317_z: state_sort_unisim_sort_rb_sort_next[10] = 1'b1;
              ctrlOr_ln328_z: state_sort_unisim_sort_rb_sort_next[7] = 1'b1;
              ctrlAnd_1_ln313_z: state_sort_unisim_sort_rb_sort_next[9] = 1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[11]: // expand_ln260_1
          state_sort_unisim_sort_rb_sort_next[12] = 1'b1;
        state_sort_unisim_sort_rb_sort[12]: // expand_ln260
          state_sort_unisim_sort_rb_sort_next[13] = 1'b1;
        state_sort_unisim_sort_rb_sort[13]: // expand_ln260_4
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln260_unr0_z: state_sort_unisim_sort_rb_sort_next[12] = 
                1'b1;
              ctrlAnd_1_ln260_unr0_z: state_sort_unisim_sort_rb_sort_next[14] = 
                1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[14]: // expand_ln280_1
          state_sort_unisim_sort_rb_sort_next[15] = 1'b1;
        state_sort_unisim_sort_rb_sort[15]: // expand_ln280
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln280_unr0_z: state_sort_unisim_sort_rb_sort_next[15] = 
                1'b1;
              ctrlAnd_1_ln255_unr1_z: state_sort_unisim_sort_rb_sort_next[16] = 
                1'b1;
              ctrlAnd_0_ln249_z: state_sort_unisim_sort_rb_sort_next[6] = 1'b1;
              ctrlAnd_1_ln255_unr0_z: state_sort_unisim_sort_rb_sort_next[11] = 
                1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[16]: // expand_ln260_2
          state_sort_unisim_sort_rb_sort_next[17] = 1'b1;
        state_sort_unisim_sort_rb_sort[17]: // expand_ln260_0
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln260_unr1_z: state_sort_unisim_sort_rb_sort_next[18] = 
                1'b1;
              ctrlAnd_1_ln260_unr1_z: state_sort_unisim_sort_rb_sort_next[20] = 
                1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        state_sort_unisim_sort_rb_sort[18]: // expand_ln260_3
          state_sort_unisim_sort_rb_sort_next[19] = 1'b1;
        state_sort_unisim_sort_rb_sort[19]: // expand_ln260_5
          state_sort_unisim_sort_rb_sort_next[17] = 1'b1;
        state_sort_unisim_sort_rb_sort[20]: // expand_ln280_2
          state_sort_unisim_sort_rb_sort_next[21] = 1'b1;
        state_sort_unisim_sort_rb_sort[21]: // expand_ln280_0
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln280_unr1_z: state_sort_unisim_sort_rb_sort_next[21] = 
                1'b1;
              ctrlAnd_0_ln249_z: state_sort_unisim_sort_rb_sort_next[6] = 1'b1;
              ctrlAnd_1_ln255_unr0_z: state_sort_unisim_sort_rb_sort_next[11] = 
                1'b1;
              default: state_sort_unisim_sort_rb_sort_next = 22'hX;
            endcase
          end
        default: // Don't care
          state_sort_unisim_sort_rb_sort_next = 22'hX;
      endcase
    end
  sort_unisim_identity_sync_read_1024x32m0 B0_bridge1(.rtl_CE(
                                           memread_sort_B0_ln201_en), .rtl_A(
                                           mux_i_ln195_z[9:0]), .mem_Q(B0_Q1), .CLK(
                                           clk), .mem_CE(B0_CE1), .mem_A(B0_A1), 
                                           .rtl_Q(memread_sort_B0_ln201_rtl_Q));
  sort_unisim_identity_sync_read_1024x32m0 B1_bridge1(.rtl_CE(
                                           memread_sort_B1_ln203_en), .rtl_A(
                                           mux_i_ln195_z[9:0]), .mem_Q(B1_Q1), .CLK(
                                           clk), .mem_CE(B1_CE1), .mem_A(B1_A1), 
                                           .rtl_Q(memread_sort_B1_ln203_rtl_Q));
  // synthesis sync_set_reset_local sort_unisim_sort_store_output_seq_block rst
  always @(posedge clk) // sort_unisim_sort_store_output_sequential
    begin : sort_unisim_sort_store_output_seq_block
      if (!rst) // Initialize state and outputs
      begin
        output_start <= 1'sb0;
        wr_length <= 32'sh0;
        wr_index <= 32'sh0;
        wr_request <= 1'sb0;
        bufdout_set_valid_curr <= 1'sb0;
        mux_ping_ln168_Z_0_tag_0 <= 1'sb0;
        sort_done <= 1'sb0;
        state_sort_unisim_sort_store_output <= 7'h1;
      end
      else // Update Q values
      begin
        output_start <= output_start_d;
        wr_length <= wr_length_d;
        wr_index <= wr_index_d;
        wr_request <= wr_request_d;
        bufdout_set_valid_curr <= bufdout_set_valid_curr_d;
        mux_ping_ln168_Z_0_tag_0 <= mux_ping_ln168_Z_0_tag_d;
        sort_done <= sort_done_d;
        state_sort_unisim_sort_store_output <= 
        state_sort_unisim_sort_store_output_next;
      end
    end
  always @(posedge clk) // sort_unisim_sort_store_output_0_sequential
    begin
      mux_elem_ln200_q <= mux_mux_elem_ln200_Z_v;
      mux_i_ln195_q <= mux_i_ln195_d_0[0];
      add_ln195_1_q <= mux_i_ln195_d_0[10:1];
      bufdout_data <= bufdout_data_d;
      add_ln187_1_q <= add_ln186_31_d_0[31:1];
      mux_burst_ln168_q <= read_sort_batch_ln165_d[32];
      read_sort_batch_ln165_q <= read_sort_batch_ln165_d[31:0];
      add_ln186_q <= {add_ln186_31_d_0[0], read_sort_batch_ln165_d[63:33]};
      read_sort_len_ln164_q <= read_sort_len_ln164_d[31:0];
      mux_index_ln168_q <= read_sort_len_ln164_d[63:32];
    end
  always @(*) begin : sort_unisim_sort_store_output_combinational
      reg unary_nor_ln95_z;
      reg ctrlOr_ln272_z;
      reg ctrlAnd_1_ln158_z;
      reg ctrlAnd_0_ln158_z;
      reg ctrlAnd_1_ln176_z;
      reg ctrlAnd_0_ln176_z;
      reg ctrlAnd_1_ln179_z;
      reg ctrlAnd_0_ln179_z;
      reg ctrlAnd_1_ln191_z;
      reg ctrlAnd_0_ln191_z;
      reg [31:0] mux_index_ln168_z;
      reg [31:0] mux_read_sort_batch_ln165_Z_v;
      reg [31:0] mux_read_sort_len_ln164_Z_v;
      reg [31:0] mux_elem_ln200_z;
      reg mux_ping_ln168_z;
      reg [31:0] mux_burst_ln168_z;
      reg output_start_hold;
      reg ctrlOr_ln179_z;
      reg wr_request_hold;
      reg ctrlOr_ln191_z;
      reg [31:0] mux_mux_index_ln168_Z_v;
      reg [31:0] mux_read_sort_batch_ln165_Z_0_mux_0_v;
      reg [31:0] mux_read_sort_len_ln164_Z_0_mux_0_v;
      reg [31:0] add_ln186_z;
      reg mux_mux_ping_ln168_Z_0_v;
      reg unary_nor_ln207_z;
      reg eq_ln170_z;
      reg mux_mux_burst_ln168_Z_0_v;
      reg [31:0] add_ln187_z;
      reg [10:0] add_ln195_z;
      reg eq_ln196_z;
      reg lt_ln195_z;
      reg [31:0] mux_add_ln186_Z_v;
      reg [30:0] mux_add_ln187_Z_1_v_0;
      reg or_and_0_ln196_Z_0_z;
      reg if_ln196_z;
      reg ctrlAnd_1_ln272_z;
      reg ctrlAnd_0_ln272_z;
      reg and_1_ln196_z;
      reg ctrlOr_ln195_0_z;
      reg write_sort_bufdout_data_ln274_en;
      reg ctrlAnd_1_ln196_z;
      reg ctrlAnd_0_ln196_z;
      reg mux_ping_ln168_Z_0_tag_sel;
      reg ctrlOr_ln168_z;
      reg ctrlAnd_1_ln170_z;
      reg ctrlAnd_0_ln170_z;
      reg ctrlOr_ln176_z;
      reg ctrlOr_ln173_z;

      state_sort_unisim_sort_store_output_next = 7'h0;
      unary_nor_ln95_z = ~bufdout_set_valid_curr;
      ctrlOr_ln272_z = state_sort_unisim_sort_store_output[6] | 
      state_sort_unisim_sort_store_output[5];
      ctrlAnd_1_ln158_z = init_done & state_sort_unisim_sort_store_output[0];
      ctrlAnd_0_ln158_z = !init_done & state_sort_unisim_sort_store_output[0];
      ctrlAnd_1_ln176_z = merge_done & state_sort_unisim_sort_store_output[2];
      ctrlAnd_0_ln176_z = !merge_done & state_sort_unisim_sort_store_output[2];
      ctrlAnd_1_ln179_z = !merge_done & state_sort_unisim_sort_store_output[3];
      ctrlAnd_0_ln179_z = merge_done & state_sort_unisim_sort_store_output[3];
      ctrlAnd_1_ln191_z = wr_grant & state_sort_unisim_sort_store_output[4];
      ctrlAnd_0_ln191_z = !wr_grant & state_sort_unisim_sort_store_output[4];
      if (state_sort_unisim_sort_store_output[0]) 
        mux_index_ln168_z = 32'h0;
      else 
        mux_index_ln168_z = add_ln186_q;
      if (state_sort_unisim_sort_store_output[0]) 
        mux_read_sort_batch_ln165_Z_v = batch;
      else 
        mux_read_sort_batch_ln165_Z_v = read_sort_batch_ln165_q;
      if (state_sort_unisim_sort_store_output[0]) 
        mux_read_sort_len_ln164_Z_v = len;
      else 
        mux_read_sort_len_ln164_Z_v = wr_length;
      if (mux_ping_ln168_Z_0_tag_0) 
        mux_elem_ln200_z = memread_sort_B0_ln201_rtl_Q;
      else 
        mux_elem_ln200_z = memread_sort_B1_ln203_rtl_Q;
      if (state_sort_unisim_sort_store_output[0]) 
        mux_ping_ln168_z = 1'b1;
      else 
        mux_ping_ln168_z = !mux_ping_ln168_Z_0_tag_0;
      if (state_sort_unisim_sort_store_output[0]) 
        mux_burst_ln168_z = 32'h0;
      else 
        mux_burst_ln168_z = {add_ln187_1_q, !mux_burst_ln168_q};
      if (state_sort_unisim_sort_store_output[4]) 
        mux_i_ln195_z = 11'h0;
      else 
        mux_i_ln195_z = {add_ln195_1_q, !mux_i_ln195_q};
      output_start_hold = ~(ctrlAnd_1_ln179_z | ctrlAnd_1_ln176_z);
      ctrlOr_ln179_z = ctrlAnd_0_ln179_z | ctrlAnd_1_ln176_z;
      wr_request_hold = ~(ctrlAnd_1_ln191_z | ctrlAnd_1_ln179_z);
      ctrlOr_ln191_z = ctrlAnd_0_ln191_z | ctrlAnd_1_ln179_z;
      if (state_sort_unisim_sort_store_output[2]) 
        mux_mux_index_ln168_Z_v = mux_index_ln168_q;
      else 
        mux_mux_index_ln168_Z_v = mux_index_ln168_z;
      if (state_sort_unisim_sort_store_output[2]) 
        mux_read_sort_batch_ln165_Z_0_mux_0_v = read_sort_batch_ln165_q;
      else 
        mux_read_sort_batch_ln165_Z_0_mux_0_v = mux_read_sort_batch_ln165_Z_v;
      if (state_sort_unisim_sort_store_output[2]) 
        mux_read_sort_len_ln164_Z_0_mux_0_v = read_sort_len_ln164_q;
      else 
        mux_read_sort_len_ln164_Z_0_mux_0_v = mux_read_sort_len_ln164_Z_v;
      add_ln186_z = mux_index_ln168_z + mux_read_sort_len_ln164_Z_v;
      if (state_sort_unisim_sort_store_output[5]) 
        mux_mux_elem_ln200_Z_v = mux_elem_ln200_z;
      else 
        mux_mux_elem_ln200_Z_v = mux_elem_ln200_q;
      if (state_sort_unisim_sort_store_output[2]) 
        mux_mux_ping_ln168_Z_0_v = mux_ping_ln168_Z_0_tag_0;
      else 
        mux_mux_ping_ln168_Z_0_v = mux_ping_ln168_z;
      unary_nor_ln207_z = ~mux_ping_ln168_z;
      eq_ln170_z = mux_burst_ln168_z == mux_read_sort_batch_ln165_Z_v;
      if (state_sort_unisim_sort_store_output[2]) 
        mux_mux_burst_ln168_Z_0_v = mux_burst_ln168_q;
      else 
        mux_mux_burst_ln168_Z_0_v = mux_burst_ln168_z[0];
      add_ln187_z = mux_burst_ln168_z + 32'h1;
      add_ln195_z = {1'b0, mux_i_ln195_z[9:0]} + 11'h1;
      eq_ln196_z = {21'h0, mux_i_ln195_z} == wr_length;
      lt_ln195_z = ~mux_i_ln195_z[10];
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln176_z: output_start_d = 1'b1;
        ctrlAnd_1_ln179_z: output_start_d = 1'b0;
        output_start_hold: output_start_d = output_start;
        default: output_start_d = 1'bX;
      endcase
      if (ctrlAnd_1_ln179_z) 
        wr_length_d = read_sort_len_ln164_q;
      else 
        wr_length_d = wr_length;
      if (ctrlAnd_1_ln179_z) 
        wr_index_d = mux_index_ln168_q;
      else 
        wr_index_d = wr_index;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln179_z: wr_request_d = 1'b1;
        ctrlAnd_1_ln191_z: wr_request_d = 1'b0;
        wr_request_hold: wr_request_d = wr_request;
        default: wr_request_d = 1'bX;
      endcase
      if (state_sort_unisim_sort_store_output[2]) 
        mux_add_ln186_Z_v = add_ln186_q;
      else 
        mux_add_ln186_Z_v = add_ln186_z;
      if (state_sort_unisim_sort_store_output[2]) 
        mux_add_ln187_Z_1_v_0 = add_ln187_1_q;
      else 
        mux_add_ln187_Z_1_v_0 = add_ln187_z[31:1];
      or_and_0_ln196_Z_0_z = mux_i_ln195_z[10] | eq_ln196_z;
      if_ln196_z = ~eq_ln196_z;
      ctrlAnd_1_ln272_z = bufdout_can_put_sig & ctrlOr_ln272_z;
      ctrlAnd_0_ln272_z = !bufdout_can_put_sig & ctrlOr_ln272_z;
      and_1_ln196_z = if_ln196_z & lt_ln195_z;
      ctrlOr_ln195_0_z = ctrlAnd_1_ln272_z | ctrlAnd_1_ln191_z;
      write_sort_bufdout_data_ln274_en = rst & ctrlAnd_1_ln272_z;
      if (ctrlAnd_1_ln272_z) 
        bufdout_set_valid_curr_d = unary_nor_ln95_z;
      else 
        bufdout_set_valid_curr_d = bufdout_set_valid_curr;
      ctrlAnd_1_ln196_z = and_1_ln196_z & ctrlOr_ln195_0_z;
      ctrlAnd_0_ln196_z = or_and_0_ln196_Z_0_z & ctrlOr_ln195_0_z;
      memread_sort_B0_ln201_en = mux_ping_ln168_Z_0_tag_0 & ctrlAnd_1_ln196_z;
      memread_sort_B1_ln203_en = !mux_ping_ln168_Z_0_tag_0 & ctrlAnd_1_ln196_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln196_z: mux_i_ln195_d_0 = {add_ln195_z[10:1], mux_i_ln195_z[0]};
        ctrlAnd_0_ln272_z: mux_i_ln195_d_0 = {add_ln195_1_q, mux_i_ln195_q};
        default: mux_i_ln195_d_0 = 11'hX;
      endcase
      mux_ping_ln168_Z_0_tag_sel = ctrlOr_ln191_z | ctrlOr_ln179_z | 
      ctrlAnd_1_ln196_z | ctrlAnd_0_ln272_z;
      ctrlOr_ln168_z = ctrlAnd_0_ln196_z | ctrlAnd_1_ln158_z;
      if (write_sort_bufdout_data_ln274_en) 
        bufdout_data_d = mux_mux_elem_ln200_Z_v;
      else 
        bufdout_data_d = bufdout_data;
      ctrlAnd_1_ln170_z = !eq_ln170_z & ctrlOr_ln168_z;
      ctrlAnd_0_ln170_z = eq_ln170_z & ctrlOr_ln168_z;
      ctrlOr_ln176_z = ctrlAnd_0_ln176_z | ctrlAnd_1_ln170_z;
      ctrlOr_ln173_z = state_sort_unisim_sort_store_output[1] | 
      ctrlAnd_0_ln170_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln176_z: add_ln186_31_d_0 = {mux_add_ln187_Z_1_v_0, 
          mux_add_ln186_Z_v[31]};
        mux_ping_ln168_Z_0_tag_sel: add_ln186_31_d_0 = {add_ln187_1_q, 
          add_ln186_q[31]};
        default: add_ln186_31_d_0 = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln176_z: mux_ping_ln168_Z_0_tag_d = mux_mux_ping_ln168_Z_0_v;
        mux_ping_ln168_Z_0_tag_sel: mux_ping_ln168_Z_0_tag_d = 
          mux_ping_ln168_Z_0_tag_0;
        default: mux_ping_ln168_Z_0_tag_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln176_z: read_sort_batch_ln165_d = {mux_add_ln186_Z_v[30:0], 
          mux_mux_burst_ln168_Z_0_v, mux_read_sort_batch_ln165_Z_0_mux_0_v};
        mux_ping_ln168_Z_0_tag_sel: read_sort_batch_ln165_d = {add_ln186_q[30:0], 
          mux_burst_ln168_q, read_sort_batch_ln165_q};
        default: read_sort_batch_ln165_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln176_z: read_sort_len_ln164_d = {mux_mux_index_ln168_Z_v, 
          mux_read_sort_len_ln164_Z_0_mux_0_v};
        ctrlOr_ln179_z: read_sort_len_ln164_d = {mux_index_ln168_q, 
          read_sort_len_ln164_q};
        default: read_sort_len_ln164_d = 64'hX;
      endcase
      if (ctrlAnd_0_ln170_z) 
        sort_done_d = 1'b1;
      else 
        sort_done_d = sort_done;
      case (1'b1)// synthesis parallel_case
        state_sort_unisim_sort_store_output[0]: // Wait_ln158
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln158_z: state_sort_unisim_sort_store_output_next[0] = 
                1'b1;
              ctrlOr_ln173_z: state_sort_unisim_sort_store_output_next[1] = 1'b1;
              ctrlOr_ln176_z: state_sort_unisim_sort_store_output_next[2] = 1'b1;
              default: state_sort_unisim_sort_store_output_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_store_output[1]: // Wait_ln173
          state_sort_unisim_sort_store_output_next[1] = 1'b1;
        state_sort_unisim_sort_store_output[2]: // Wait_ln176
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln176_z: state_sort_unisim_sort_store_output_next[2] = 1'b1;
              ctrlOr_ln179_z: state_sort_unisim_sort_store_output_next[3] = 1'b1;
              default: state_sort_unisim_sort_store_output_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_store_output[3]: // Wait_ln179
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln179_z: state_sort_unisim_sort_store_output_next[3] = 1'b1;
              ctrlOr_ln191_z: state_sort_unisim_sort_store_output_next[4] = 1'b1;
              default: state_sort_unisim_sort_store_output_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_store_output[4]: // Wait_ln191
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln191_z: state_sort_unisim_sort_store_output_next[4] = 1'b1;
              ctrlOr_ln173_z: state_sort_unisim_sort_store_output_next[1] = 1'b1;
              ctrlOr_ln176_z: state_sort_unisim_sort_store_output_next[2] = 1'b1;
              ctrlAnd_1_ln196_z: state_sort_unisim_sort_store_output_next[5] = 
                1'b1;
              default: state_sort_unisim_sort_store_output_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_store_output[5]: // Wait_ln205
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_z: state_sort_unisim_sort_store_output_next[6] = 
                1'b1;
              ctrlOr_ln173_z: state_sort_unisim_sort_store_output_next[1] = 1'b1;
              ctrlOr_ln176_z: state_sort_unisim_sort_store_output_next[2] = 1'b1;
              ctrlAnd_1_ln196_z: state_sort_unisim_sort_store_output_next[5] = 
                1'b1;
              default: state_sort_unisim_sort_store_output_next = 7'hX;
            endcase
          end
        state_sort_unisim_sort_store_output[6]: // Wait_ln272
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_z: state_sort_unisim_sort_store_output_next[6] = 
                1'b1;
              ctrlOr_ln173_z: state_sort_unisim_sort_store_output_next[1] = 1'b1;
              ctrlOr_ln176_z: state_sort_unisim_sort_store_output_next[2] = 1'b1;
              ctrlAnd_1_ln196_z: state_sort_unisim_sort_store_output_next[5] = 
                1'b1;
              default: state_sort_unisim_sort_store_output_next = 7'hX;
            endcase
          end
        default: // Don't care
          state_sort_unisim_sort_store_output_next = 7'hX;
      endcase
    end
endmodule


module sort_unisim_sort_bufdin_can_get_mod_process(bufdin_valid, bufdin_ready, 
bufdin_can_get_sig);
  input bufdin_valid;
  input bufdin_ready;
  output reg bufdin_can_get_sig;

  always @(*) begin : sort_unisim_sort_bufdin_can_get_mod_process_combinational
      reg unary_nor_ln35_z;
      reg ternaryMux_ln35_0_z;

      unary_nor_ln35_z = ~bufdin_ready;
      ternaryMux_ln35_0_z = bufdin_valid | unary_nor_ln35_z;
      bufdin_can_get_sig = ternaryMux_ln35_0_z;
    end
endmodule


module sort_unisim_sort_bufdin_sync_rcv_back_method(clk, rst, bufdin_valid, 
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

  // synthesis async_set_reset_local sort_unisim_sort_bufdin_sync_rcv_back_method_seq_block rst
  always @(posedge clk or negedge rst) // sort_unisim_sort_bufdin_sync_rcv_back_method_sequential
    begin : sort_unisim_sort_bufdin_sync_rcv_back_method_seq_block
      if (!rst) // Initialize state and outputs
      begin
        bufdin_sync_rcv_ready_flop <= 1'b1;
        bufdin_sync_rcv_reset_ready_prev <= 1'b0;
        bufdin_sync_rcv_set_ready_prev <= 1'b0;
        bufdin_sync_rcv_reset_ready_curr <= 1'b0;
      end
      else // Update Q values
      begin
        bufdin_sync_rcv_ready_flop <= bufdin_sync_rcv_ready_flop_d;
        bufdin_sync_rcv_reset_ready_prev <= bufdin_sync_rcv_reset_ready_prev_d;
        bufdin_sync_rcv_set_ready_prev <= bufdin_sync_rcv_set_ready_prev_d;
        bufdin_sync_rcv_reset_ready_curr <= bufdin_sync_rcv_reset_ready_curr_d;
      end
    end
  always @(posedge clk) // sort_unisim_sort_bufdin_sync_rcv_back_method_0_sequential
    bufdin_data_buf <= bufdin_data_buf_d;
  always @(*) begin : sort_unisim_sort_bufdin_sync_rcv_back_method_combinational
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


module sort_unisim_sort_bufdin_sync_rcv_ready_arb(bufdin_set_ready_curr, 
bufdin_sync_rcv_set_ready_prev, bufdin_sync_rcv_reset_ready_curr, 
bufdin_sync_rcv_reset_ready_prev, bufdin_sync_rcv_ready_flop, bufdin_ready);
  input bufdin_set_ready_curr;
  input bufdin_sync_rcv_set_ready_prev;
  input bufdin_sync_rcv_reset_ready_curr;
  input bufdin_sync_rcv_reset_ready_prev;
  input bufdin_sync_rcv_ready_flop;
  output reg bufdin_ready;

  always @(*) begin : sort_unisim_sort_bufdin_sync_rcv_ready_arb_combinational
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


module sort_unisim_sort_bufdout_can_put_mod_process(bufdout_valid, bufdout_ready, 
bufdout_can_put_sig);
  input bufdout_valid;
  input bufdout_ready;
  output reg bufdout_can_put_sig;

  always @(*) begin : sort_unisim_sort_bufdout_can_put_mod_process_combinational
      reg unary_nor_ln35_z;
      reg ternaryMux_ln35_0_z;

      unary_nor_ln35_z = ~bufdout_ready;
      ternaryMux_ln35_0_z = ~(bufdout_valid & unary_nor_ln35_z);
      bufdout_can_put_sig = ternaryMux_ln35_0_z;
    end
endmodule


module sort_unisim_sort_bufdout_sync_snd_back_method(clk, rst, bufdout_ready, 
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

  // synthesis async_set_reset_local sort_unisim_sort_bufdout_sync_snd_back_method_seq_block rst
  always @(posedge clk or negedge rst) // sort_unisim_sort_bufdout_sync_snd_back_method_sequential
    begin : sort_unisim_sort_bufdout_sync_snd_back_method_seq_block
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
  always @(*) begin : sort_unisim_sort_bufdout_sync_snd_back_method_combinational
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


module sort_unisim_sort_bufdout_sync_snd_valid_arb(bufdout_set_valid_curr, 
bufdout_sync_snd_set_valid_prev, bufdout_sync_snd_reset_valid_curr, 
bufdout_sync_snd_reset_valid_prev, bufdout_sync_snd_valid_flop, bufdout_valid);
  input bufdout_set_valid_curr;
  input bufdout_sync_snd_set_valid_prev;
  input bufdout_sync_snd_reset_valid_curr;
  input bufdout_sync_snd_reset_valid_prev;
  input bufdout_sync_snd_valid_flop;
  output reg bufdout_valid;

  always @(*) begin : sort_unisim_sort_bufdout_sync_snd_valid_arb_combinational
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


module sort_unisim_lt_float_0(in0_in, in1_in, lt_float_out);
  input [31:0] in0_in;
  input [31:0] in1_in;
  output reg lt_float_out;

  always @(*) begin : sort_unisim_lt_float_0_combinational
      reg eq_ln18_z;
      reg eq_ln18_0_z;
      reg eq_ln21_z;
      reg eq_ln21_0_z;
      reg eq_ln8_z;
      reg eq_ln9_z;
      reg gt_ln39_z;
      reg gt_ln45_z;
      reg ne_ln33_z;
      reg lt_ln36_z;
      reg lt_ln42_z;
      reg ternaryMux_ln18_0_z;
      reg ternaryMux_ln21_0_z;
      reg mux_lt_float_ln4_zip_6_z;
      reg [2:0] case_mux_lt_float_ln4_zip_1_z;
      reg ternaryMux_ln24_0_z;
      reg and_if_ln30_z;
      reg and_if_ln33_0_z;
      reg and_if_ln36_0_0_z;
      reg and_case_mux_lt_float_ln4_zip_1_1_0_0_0_z;
      reg and_case_mux_lt_float_ln4_zip_1_2_0_0_z;
      reg and_case_mux_lt_float_ln4_zip_1_0_0_0_0_z;
      reg or_and_if_ln30_Z_0_z;
      reg or_and_if_ln36_0_0_Z_0_z;
      reg mux_lt_float_ln4_zip_5_z;
      reg mux_lt_float_ln4_0_z;

      eq_ln18_z = in0_in[30:23] == 8'h0;
      eq_ln18_0_z = in0_in[22:0] == 23'h0;
      eq_ln21_z = in1_in[30:23] == 8'h0;
      eq_ln21_0_z = in1_in[22:0] == 23'h0;
      eq_ln8_z = ~in0_in[31];
      eq_ln9_z = ~in1_in[31];
      gt_ln39_z = {1'b0, in0_in[30:23]} > {1'b0, in1_in[30:23]};
      gt_ln45_z = {1'b0, in0_in[22:0]} > {1'b0, in1_in[22:0]};
      ne_ln33_z = in1_in[31] ^ in0_in[31];
      lt_ln36_z = {1'b0, in1_in[30:23]} > {1'b0, in0_in[30:23]};
      lt_ln42_z = {1'b0, in1_in[22:0]} > {1'b0, in0_in[22:0]};
      ternaryMux_ln18_0_z = eq_ln18_z & eq_ln18_0_z;
      ternaryMux_ln21_0_z = eq_ln21_z & eq_ln21_0_z;
      mux_lt_float_ln4_zip_6_z = gt_ln45_z & in0_in[31];
      case (1'b1)
        gt_ln39_z: case_mux_lt_float_ln4_zip_1_z = 3'h1;
        lt_ln42_z: case_mux_lt_float_ln4_zip_1_z = 3'h2;
        default: case_mux_lt_float_ln4_zip_1_z = 3'h4;
      endcase
      ternaryMux_ln24_0_z = ternaryMux_ln18_0_z & ternaryMux_ln21_0_z;
      and_if_ln30_z = !ternaryMux_ln18_0_z & ternaryMux_ln21_0_z;
      and_if_ln33_0_z = !ternaryMux_ln21_0_z & ne_ln33_z & !ternaryMux_ln18_0_z;
      and_if_ln36_0_0_z = !ne_ln33_z & lt_ln36_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      and_case_mux_lt_float_ln4_zip_1_1_0_0_0_z = !lt_ln36_z & 
      case_mux_lt_float_ln4_zip_1_z[2] & !ne_ln33_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      and_case_mux_lt_float_ln4_zip_1_2_0_0_z = !lt_ln36_z & 
      case_mux_lt_float_ln4_zip_1_z[0] & !ne_ln33_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      and_case_mux_lt_float_ln4_zip_1_0_0_0_0_z = !lt_ln36_z & 
      case_mux_lt_float_ln4_zip_1_z[1] & !ne_ln33_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      or_and_if_ln30_Z_0_z = and_case_mux_lt_float_ln4_zip_1_2_0_0_z | 
      and_if_ln33_0_z | and_if_ln30_z;
      or_and_if_ln36_0_0_Z_0_z = and_case_mux_lt_float_ln4_zip_1_0_0_0_0_z | 
      and_if_ln36_0_0_z;
      case (1'b1)// synthesis parallel_case
        ternaryMux_ln18_0_z: mux_lt_float_ln4_zip_5_z = eq_ln9_z;
        or_and_if_ln30_Z_0_z: mux_lt_float_ln4_zip_5_z = in0_in[31];
        or_and_if_ln36_0_0_Z_0_z: mux_lt_float_ln4_zip_5_z = eq_ln8_z;
        and_case_mux_lt_float_ln4_zip_1_1_0_0_0_z: mux_lt_float_ln4_zip_5_z = 
          mux_lt_float_ln4_zip_6_z;
        default: mux_lt_float_ln4_zip_5_z = 1'bX;
      endcase
      mux_lt_float_ln4_0_z = !ternaryMux_ln24_0_z & mux_lt_float_ln4_zip_5_z;
      lt_float_out = mux_lt_float_ln4_0_z;
    end
endmodule


module sort_unisim_lt_float(in0_in, in1_in, lt_float_out);
  input [31:0] in0_in;
  input [31:0] in1_in;
  output reg lt_float_out;

  always @(*) begin : sort_unisim_lt_float_combinational
      reg eq_ln18_z;
      reg eq_ln18_0_z;
      reg eq_ln21_z;
      reg eq_ln21_0_z;
      reg eq_ln8_z;
      reg eq_ln9_z;
      reg gt_ln39_z;
      reg gt_ln45_z;
      reg ne_ln33_z;
      reg lt_ln36_z;
      reg lt_ln42_z;
      reg ternaryMux_ln18_0_z;
      reg ternaryMux_ln21_0_z;
      reg mux_lt_float_ln4_zip_6_z;
      reg [2:0] case_mux_lt_float_ln4_zip_1_z;
      reg ternaryMux_ln24_0_z;
      reg and_if_ln30_z;
      reg and_if_ln33_0_z;
      reg and_if_ln36_0_0_z;
      reg and_case_mux_lt_float_ln4_zip_1_1_0_0_0_z;
      reg and_case_mux_lt_float_ln4_zip_1_2_0_0_z;
      reg and_case_mux_lt_float_ln4_zip_1_0_0_0_0_z;
      reg or_and_if_ln30_Z_0_z;
      reg or_and_if_ln36_0_0_Z_0_z;
      reg mux_lt_float_ln4_zip_5_z;
      reg mux_lt_float_ln4_0_z;

      eq_ln18_z = in0_in[30:23] == 8'h0;
      eq_ln18_0_z = in0_in[22:0] == 23'h0;
      eq_ln21_z = in1_in[30:23] == 8'h0;
      eq_ln21_0_z = in1_in[22:0] == 23'h0;
      eq_ln8_z = ~in0_in[31];
      eq_ln9_z = ~in1_in[31];
      gt_ln39_z = {1'b0, in0_in[30:23]} > {1'b0, in1_in[30:23]};
      gt_ln45_z = {1'b0, in0_in[22:0]} > {1'b0, in1_in[22:0]};
      ne_ln33_z = in1_in[31] ^ in0_in[31];
      lt_ln36_z = {1'b0, in1_in[30:23]} > {1'b0, in0_in[30:23]};
      lt_ln42_z = {1'b0, in1_in[22:0]} > {1'b0, in0_in[22:0]};
      ternaryMux_ln18_0_z = eq_ln18_z & eq_ln18_0_z;
      ternaryMux_ln21_0_z = eq_ln21_z & eq_ln21_0_z;
      mux_lt_float_ln4_zip_6_z = gt_ln45_z & in0_in[31];
      case (1'b1)
        gt_ln39_z: case_mux_lt_float_ln4_zip_1_z = 3'h1;
        lt_ln42_z: case_mux_lt_float_ln4_zip_1_z = 3'h2;
        default: case_mux_lt_float_ln4_zip_1_z = 3'h4;
      endcase
      ternaryMux_ln24_0_z = ternaryMux_ln18_0_z & ternaryMux_ln21_0_z;
      and_if_ln30_z = !ternaryMux_ln18_0_z & ternaryMux_ln21_0_z;
      and_if_ln33_0_z = !ternaryMux_ln21_0_z & ne_ln33_z & !ternaryMux_ln18_0_z;
      and_if_ln36_0_0_z = !ne_ln33_z & lt_ln36_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      and_case_mux_lt_float_ln4_zip_1_1_0_0_0_z = !lt_ln36_z & 
      case_mux_lt_float_ln4_zip_1_z[2] & !ne_ln33_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      and_case_mux_lt_float_ln4_zip_1_2_0_0_z = !lt_ln36_z & 
      case_mux_lt_float_ln4_zip_1_z[0] & !ne_ln33_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      and_case_mux_lt_float_ln4_zip_1_0_0_0_0_z = !lt_ln36_z & 
      case_mux_lt_float_ln4_zip_1_z[1] & !ne_ln33_z & !ternaryMux_ln21_0_z & !
      ternaryMux_ln18_0_z;
      or_and_if_ln30_Z_0_z = and_case_mux_lt_float_ln4_zip_1_2_0_0_z | 
      and_if_ln33_0_z | and_if_ln30_z;
      or_and_if_ln36_0_0_Z_0_z = and_case_mux_lt_float_ln4_zip_1_0_0_0_0_z | 
      and_if_ln36_0_0_z;
      case (1'b1)// synthesis parallel_case
        ternaryMux_ln18_0_z: mux_lt_float_ln4_zip_5_z = eq_ln9_z;
        or_and_if_ln30_Z_0_z: mux_lt_float_ln4_zip_5_z = in0_in[31];
        or_and_if_ln36_0_0_Z_0_z: mux_lt_float_ln4_zip_5_z = eq_ln8_z;
        and_case_mux_lt_float_ln4_zip_1_1_0_0_0_z: mux_lt_float_ln4_zip_5_z = 
          mux_lt_float_ln4_zip_6_z;
        default: mux_lt_float_ln4_zip_5_z = 1'bX;
      endcase
      mux_lt_float_ln4_0_z = !ternaryMux_ln24_0_z & mux_lt_float_ln4_zip_5_z;
      lt_float_out = mux_lt_float_ln4_0_z;
    end
endmodule


module sort_unisim_identity_sync_write_1024x32m0(rtl_CE, rtl_A, rtl_D, rtl_WE, CLK, mem_CE, mem_A, mem_D, mem_WE);
    input rtl_CE;
    input [9 : 0] rtl_A;
    input [31 : 0] rtl_D;
    input rtl_WE;
    input CLK;
    output mem_CE;
    output [9 : 0] mem_A;
    output [31 : 0] mem_D;
    output mem_WE;

    assign mem_CE = rtl_CE;
    assign mem_A = rtl_A;
    assign mem_D = rtl_D;
    assign mem_WE = rtl_WE;
`ifdef CTOS_SIM_MULTI_LANGUAGE_EXTERNAL_ARRAY
    // This is only required when simulating a multi-language design.
    bit use_dpi;
    wire m_ready;
    initial begin
        use_dpi = 0;

        @(posedge m_ready)
        use_dpi = 1;
    end
    ctos_external_array_accessor #(.ADDR_WIDTH(10), .DATA_WIDTH(32), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

    always @(posedge CLK) begin
        if (use_dpi) begin
            if (rtl_CE && rtl_WE) begin
                arr_ref.write(rtl_A, rtl_D);
            end
        end
    end
`endif
endmodule


module sort_unisim_identity_sync_read_1024x32m0(rtl_CE, rtl_A, mem_Q, CLK, mem_CE, mem_A, rtl_Q);
    input rtl_CE;
    input [9 : 0] rtl_A;
    input [31 : 0] mem_Q;
    input CLK;
    output mem_CE;
    output [9 : 0] mem_A;
    output [31 : 0] rtl_Q;

    assign mem_CE = rtl_CE;
    assign mem_A = rtl_A;
`ifndef CTOS_SIM_MULTI_LANGUAGE_EXTERNAL_ARRAY
    assign rtl_Q = mem_Q;

`else
    // This is only required when simulating a multi-language design.
    reg [31:0] dpi_Q;
    bit use_dpi;
    wire m_ready;
    // Pick which Q drives the RTL Q.
    assign rtl_Q = use_dpi ? dpi_Q : mem_Q;
    initial begin
        use_dpi = 0;

        @(posedge m_ready)
        use_dpi = 1;
    end
    ctos_external_array_accessor #(.ADDR_WIDTH(10), .DATA_WIDTH(32), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

    always @(posedge CLK) begin
        if (use_dpi) begin
            if (rtl_CE) begin
                arr_ref.read(rtl_A, dpi_Q);
            end
        end
    end
`endif
endmodule


/**
 * Copyright (c) 2014, Columbia University
 *
 * @author Christian Pilato <pilato@cs.columbia.edu>
 */

module sort_unisim_ram_1024x32p_1w_1r(CLK, CE0, A0, D0, WE0, CE1, A1, Q1);

  parameter memSize=1024;  /* physical memory size */
  parameter selBit=1;      /* log_2(memSize/512), # of banks */

  parameter nOfBanks=(memSize/512);
  parameter bitAddress=9+selBit;

  input CLK;
  input CE0;
  input [bitAddress-1:0] A0;
  input [31:0] D0;
  input WE0;
  input CE1;
  input [bitAddress-1:0] A1;
  output [31:0] Q1;

  wire [nOfBanks-1:0] A_ENA_tmp;
  wire [nOfBanks-1:0] A_WEA_tmp;
  wire [31:0] A_DOA_float[0:nOfBanks-1];
  wire [3:0] A_DOPA_float[0:nOfBanks-1];

  wire [nOfBanks-1:0] A_ENB_tmp;
  wire [nOfBanks-1:0] A_WEB_tmp;
  wire [31:0] A_DOB_temp[0:nOfBanks-1];
  wire [3:0] A_DOPB_float[0:nOfBanks-1];

  reg [selBit-1:0] sel;

  always@(posedge CLK)
  begin
     sel = A1[selBit-1:0];
  end

  assign Q1 = A_DOB_temp[sel];

  genvar i;
  generate
  for(i=0; i< nOfBanks; i=i+1) begin:bramgen

    assign A_WEA_tmp[i] = (WE0 && A0[selBit-1:0] == i);
    assign A_ENA_tmp[i] = (CE0 && A0[selBit-1:0] == i);

    assign A_WEB_tmp[i] = 1'b0;
    assign A_ENB_tmp[i] = (CE1 && A1[selBit-1:0] == i);

    RAMB16_S36_S36 b0(
      .DOA(A_DOA_float[i]),
      .DOB(A_DOB_temp[i]),
      .DOPA(A_DOPA_float[i]),
      .DOPB(A_DOPB_float[i]),
      .ADDRA(A0[bitAddress-1:selBit]),
      .ADDRB(A1[bitAddress-1:selBit]),
      .CLKA(CLK),
      .CLKB(CLK),
      .DIA(D0),
      .DIB(32'b0),
      .DIPA(4'b0),
      .DIPB(4'b0),
      .ENA(A_ENA_tmp[i]),
      .ENB(A_ENB_tmp[i]),
      .SSRA(1'b0),
      .SSRB(1'b0),
      .WEA(A_WEA_tmp[i]),
      .WEB(A_WEB_tmp[i]));

    end
    endgenerate

endmodule


