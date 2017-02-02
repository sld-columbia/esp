// *****************************************************************************
//                         Cadence C-to-Silicon Compiler
//          Version 14.10-p100  (64 bit), build 50398 Tue, 27 May 2014
// 
// File created on Tue Jul 22 16:42:55 2014
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
// bufdin.get_initiator_imp<ctos_sc_dt::sc_fixed<32, 20, SC_RND, SC_WRAP, 0>, SIG_TRAITS_pCLK_nRST, 1>::data.m_mant maps to bufdin_data[31:0]
// bufdout.put_initiator_imp<ctos_sc_dt::sc_fixed<32, 20, SC_RND, SC_WRAP, 0>, SIG_TRAITS_pCLK_nRST, 1>::data.m_mant maps to bufdout_data[31:0]

module fft2d_unisim_rtl(clk, rst, rd_grant, wr_grant, conf_size, conf_log2, 
conf_batch, conf_transpose, conf_done, bufdin_valid, bufdin_data, bufdout_ready, 
A0_Q1, B0_Q1, rd_index, rd_length, rd_request, wr_index, wr_length, wr_request, 
fft2d_done, bufdin_ready, bufdout_valid, bufdout_data, A0_CE0, A0_A0, A0_D0, 
A0_WE0, A0_WEM0, A0_CE1, A0_A1, A0_D1, A0_WE1, A0_WEM1, B0_CE0, B0_A0, B0_D0, 
B0_WE0, B0_CE1, B0_A1);
  input clk;
  input rst;
  input rd_grant;
  input wr_grant;
  input [31:0] conf_size;
  input [31:0] conf_log2;
  input [31:0] conf_batch;
  input conf_transpose;
  input conf_done;
  input bufdin_valid;
  input [31:0] bufdin_data;
  input bufdout_ready;
  input [63:0] A0_Q1;
  input [63:0] B0_Q1;
  output reg [31:0] rd_index;
  output reg [31:0] rd_length;
  output reg rd_request;
  output reg [31:0] wr_index;
  output reg [31:0] wr_length;
  output reg wr_request;
  output reg fft2d_done;
  output bufdin_ready;
  output bufdout_valid;
  output reg [31:0] bufdout_data;
  output A0_CE0;
  output [12:0] A0_A0;
  output [63:0] A0_D0;
  output A0_WE0;
  output [1:0] A0_WEM0;
  output A0_CE1;
  output [12:0] A0_A1;
  output [63:0] A0_D1;
  output A0_WE1;
  output [1:0] A0_WEM1;
  output B0_CE0;
  output [12:0] B0_A0;
  output [63:0] B0_D0;
  output B0_WE0;
  output B0_CE1;
  output [12:0] B0_A1;
  reg [31:0] sig_size;
  reg [31:0] sig_log2;
  reg [31:0] sig_batch;
  reg sig_transpose;
  reg init_done;
  reg input_valid;
  reg input_ack;
  reg output_valid;
  reg output_ack;
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
  wire [31:0] fft2d_unisim___rev_ln332_z;
  reg [1:0] state_fft2d_unisim_fft2d_config_fft2d;
  reg [1:0] state_fft2d_unisim_fft2d_config_fft2d_next;
  reg [31:0] sig_size_d;
  reg sig_transpose_d;
  reg [31:0] sig_batch_d;
  reg [31:0] sig_log2_d;
  reg init_done_d;
  reg [8:0] state_fft2d_unisim_fft2d_load_input;
  reg [8:0] state_fft2d_unisim_fft2d_load_input_next;
  reg eq_ln142_Z_0_tag_0;
  reg [30:0] add_ln156_q;
  reg [30:0] mux_base_ln143_q;
  reg [31:0] mux_s_ln143_q;
  reg mux_rows_ln143_0_q;
  reg [12:0] add_ln164_1_q;
  reg [12:0] mux_i_ln164_q;
  reg [30:0] mux_base_ln140_q;
  reg mux_rows_ln140_q;
  reg mux_s_ln140_q;
  reg [31:0] read_fft2d_sig_batch_ln134_q;
  reg [31:0] read_fft2d_sig_size_ln133_q;
  reg read_fft2d_sig_transpose_ln135_q;
  reg [30:0] mul_ln145_q;
  reg [30:0] add_ln187_1_q;
  reg A0_bridge0_rtl_CE_en;
  reg [12:0] A0_bridge0_rtl_a;
  reg [63:0] A0_bridge0_rtl_d;
  reg [1:0] A0_bridge0_rtl_wem;
  reg [31:0] rd_length_d;
  reg [31:0] rd_index_d;
  reg rd_request_d;
  reg eq_ln142_z;
  reg [30:0] add_ln156_z;
  reg [30:0] mux_base_ln143_z;
  reg [31:0] mux_s_ln143_z;
  reg mux_rows_ln143_0_z;
  reg input_valid_d;
  reg [13:0] mux_i_ln164_d;
  reg [11:0] mux_i_ln164_1_d_0;
  reg [63:0] mul_ln145_30_d_0;
  reg [63:0] read_fft2d_sig_size_ln133_31_d_0;
  reg [30:0] mux_read_fft2d_sig_size_ln133_Z_0_mux_0_v;
  reg add_ln187_1_30_d;
  reg bufdin_set_ready_curr_d;
  reg [22:0] state_fft2d_unisim_fft2d_process_itr_fft2d;
  reg [22:0] state_fft2d_unisim_fft2d_process_itr_fft2d_next;
  reg [63:0] memread_fft2d_A0_ln338_q;
  reg [63:0] memread_fft2d_A0_ln381_q;
  reg [54:0] add_ln176_1_11_q;
  reg [63:0] memread_fft2d_A0_ln336_q;
  reg [63:0] memread_fft2d_A0_ln379_q;
  reg [54:0] sub_ln196_2_11_q;
  reg [31:0] add_ln404_3_q;
  reg [31:0] add_ln404_4_q;
  reg [88:0] mul_ln221_q;
  reg [88:0] mul_ln221_1_q;
  reg [89:0] mul_ln221_0_q;
  reg [89:0] mul_ln221_2_q;
  reg lt_ln328_q;
  reg [55:0] add_ln404_q;
  reg [55:0] add_ln404_0_q;
  reg or_and_0_ln360_Z_0_q;
  reg or_and_0_ln351_Z_0_q;
  reg [12:0] mux_i_ln328_q;
  reg [30:0] add_ln328_1_q;
  reg and_1_ln360_q;
  reg [12:0] rsh_ln333_q;
  reg lt_ln335_q;
  reg and_1_ln351_q;
  reg [12:0] add_ln371_q;
  reg [12:0] add_ln372_0_q;
  reg mux_j_ln367_q;
  reg [11:0] add_ln367_1_q;
  reg [111:0] mux_w_ln367_q;
  reg [12:0] mux_k_ln359_q;
  reg [31:0] add_ln359_q;
  reg eq_ln408_Z_0_tag_0;
  reg [15:0] lsh_ln354_q;
  reg [32:0] mux_myCos_ln41_q;
  reg mux_s_ln350_q;
  reg [2:0] add_ln350_1_q;
  reg [33:0] mux_mySin_ln61_q;
  reg [31:0] read_fft2d_sig_size_ln309_q;
  reg [31:0] read_fft2d_sig_log2_ln310_q;
  reg [3:0] add_ln325_1_q;
  reg B0_bridge0_rtl_CE_en;
  reg [12:0] B0_bridge0_rtl_a;
  reg [63:0] B0_bridge0_rtl_d;
  reg A0_bridge1_rtl_CE_en;
  reg [12:0] A0_bridge1_rtl_a;
  reg [63:0] A0_bridge1_rtl_d;
  reg A0_bridge1_rtl_WE_en;
  wire [63:0] A0_bridge1_rtl_Q;
  reg [65:0] add_ln176_1_z;
  reg [63:0] memread_fft2d_A0_ln336_d;
  reg [63:0] memread_fft2d_A0_ln379_d;
  reg [65:0] sub_ln196_2_z;
  reg [31:0] add_ln404_3_z;
  reg [31:0] add_ln404_4_z;
  reg signed [88:0] mul_ln221_z;
  reg signed [88:0] mul_ln221_1_z;
  reg signed [89:0] mul_ln221_0_z;
  reg signed [89:0] mul_ln221_2_z;
  reg lt_ln328_z;
  reg [63:0] add_ln404_0_d_0;
  reg [47:0] add_ln404_8_d_0;
  reg input_ack_d;
  reg output_valid_d;
  reg or_and_0_ln360_Z_0_z;
  reg or_and_0_ln351_Z_0_z;
  reg [31:0] mux_i_ln328_d;
  reg [11:0] mux_i_ln328_1_d_0;
  reg and_1_ln360_z;
  reg [12:0] rsh_ln333_d;
  reg lt_ln335_z;
  reg and_1_ln351_z;
  reg [12:0] add_ln371_d;
  reg [12:0] add_ln372_0_d;
  reg [12:0] mux_j_ln367_d_0;
  reg [63:0] mux_w_ln367_d;
  reg [47:0] mux_w_ln367_64_d_0;
  reg [44:0] mux_k_ln359_d;
  reg [63:0] mux_s_ln350_d_0;
  reg [23:0] mux_mySin_ln61_10_d_0;
  reg [63:0] read_fft2d_sig_size_ln309_d;
  reg [3:0] add_ln325_1_d;
  reg [31:0] mux_i_ln328_z;
  reg [15:0] state_fft2d_unisim_fft2d_store_output;
  reg [15:0] state_fft2d_unisim_fft2d_store_output_next;
  reg [63:0] memread_fft2d_B0_ln256_q;
  reg [63:0] memread_fft2d_B0_ln278_q;
  reg [30:0] add_ln271_q;
  reg mux_rows_ln223_0_q;
  reg [30:0] mux_base_ln223_q;
  reg [31:0] mux_s_ln223_q;
  reg [12:0] mux_i_0_ln264_q;
  reg [12:0] add_ln264_1_q;
  reg mux_i_ln252_q;
  reg [12:0] add_ln252_1_q;
  reg [30:0] mul_ln241_q;
  reg [31:0] read_fft2d_sig_size_ln209_q;
  reg read_fft2d_sig_transpose_ln211_Z_0_tag_0;
  reg [31:0] read_fft2d_sig_batch_ln210_q;
  reg [30:0] mux_base_ln220_q;
  reg mux_rows_ln220_q;
  reg [30:0] mux_s_ln220_q;
  reg [30:0] add_ln292_1_q;
  reg B0_bridge1_rtl_CE_en;
  reg [12:0] B0_bridge1_rtl_a;
  wire [63:0] B0_bridge1_rtl_Q;
  reg [31:0] wr_length_d;
  reg [31:0] wr_index_d;
  reg wr_request_d;
  reg [63:0] mux_memread_fft2d_B0_ln256_Q_v;
  reg [31:0] memread_fft2d_B0_ln256_32_d_0;
  reg [63:0] mux_memread_fft2d_B0_ln278_Q_v;
  reg [31:0] memread_fft2d_B0_ln278_32_d_0;
  reg [30:0] add_ln271_z;
  reg mux_rows_ln223_0_z;
  reg [30:0] mux_base_ln223_z;
  reg [31:0] mux_s_ln223_z;
  reg bufdout_set_valid_curr_d;
  reg [31:0] bufdout_data_d;
  reg [13:0] mux_i_0_ln264_d;
  reg [11:0] mux_i_0_ln264_1_d_0;
  reg [13:0] mux_i_ln252_d_0;
  reg [30:0] mul_ln241_d;
  reg output_ack_d;
  reg fft2d_done_d;
  reg [30:0] read_fft2d_sig_size_ln209_d;
  reg [33:0] read_fft2d_sig_size_ln209_31_d_0;
  reg [63:0] mux_base_ln220_d;
  reg [29:0] mux_s_ln220_1_d_0;

  fft2d_unisim_fft2d_bufdin_can_get_mod_process 
                                                fft2d_unisim_fft2d_bufdin_can_get_mod_process(
                                                .bufdin_valid(bufdin_valid), .bufdin_ready(
                                                bufdin_ready), .bufdin_can_get_sig(
                                                bufdin_can_get_sig));
  fft2d_unisim_fft2d_bufdin_sync_rcv_back_method 
                                                 fft2d_unisim_fft2d_bufdin_sync_rcv_back_method(
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
  fft2d_unisim_fft2d_bufdin_sync_rcv_ready_arb 
                                               fft2d_unisim_fft2d_bufdin_sync_rcv_ready_arb(
                                               .bufdin_set_ready_curr(
                                               bufdin_set_ready_curr), .bufdin_sync_rcv_set_ready_prev(
                                               bufdin_sync_rcv_set_ready_prev), 
                                               .bufdin_sync_rcv_reset_ready_curr(
                                               bufdin_sync_rcv_reset_ready_curr), 
                                               .bufdin_sync_rcv_reset_ready_prev(
                                               bufdin_sync_rcv_reset_ready_prev), 
                                               .bufdin_sync_rcv_ready_flop(
                                               bufdin_sync_rcv_ready_flop), .bufdin_ready(
                                               bufdin_ready));
  fft2d_unisim_fft2d_bufdout_can_put_mod_process 
                                                 fft2d_unisim_fft2d_bufdout_can_put_mod_process(
                                                 .bufdout_valid(bufdout_valid), 
                                                 .bufdout_ready(bufdout_ready), 
                                                 .bufdout_can_put_sig(
                                                 bufdout_can_put_sig));
  fft2d_unisim_fft2d_bufdout_sync_snd_back_method 
                                                  fft2d_unisim_fft2d_bufdout_sync_snd_back_method(
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
  fft2d_unisim_fft2d_bufdout_sync_snd_valid_arb 
                                                fft2d_unisim_fft2d_bufdout_sync_snd_valid_arb(
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
  // synthesis sync_set_reset_local fft2d_unisim_fft2d_config_fft2d_seq_block rst
  always @(posedge clk) // fft2d_unisim_fft2d_config_fft2d_sequential
    begin : fft2d_unisim_fft2d_config_fft2d_seq_block
      if (!rst) // Initialize state and outputs
      begin
        sig_size <= 32'sh0;
        sig_transpose <= 1'sb0;
        sig_batch <= 32'sh0;
        sig_log2 <= 32'sh0;
        init_done <= 1'sb0;
        state_fft2d_unisim_fft2d_config_fft2d <= 2'h1;
      end
      else // Update Q values
      begin
        sig_size <= sig_size_d;
        sig_transpose <= sig_transpose_d;
        sig_batch <= sig_batch_d;
        sig_log2 <= sig_log2_d;
        init_done <= init_done_d;
        state_fft2d_unisim_fft2d_config_fft2d <= 
        state_fft2d_unisim_fft2d_config_fft2d_next;
      end
    end
  always @(*) begin : fft2d_unisim_fft2d_config_fft2d_combinational
      reg write_fft2d_sig_log2_ln98_en;
      reg ctrlAnd_1_ln92_z;
      reg ctrlAnd_0_ln92_z;
      reg ctrlOr_ln109_z;

      state_fft2d_unisim_fft2d_config_fft2d_next = 2'h0;
      write_fft2d_sig_log2_ln98_en = rst & 
      state_fft2d_unisim_fft2d_config_fft2d[0];
      ctrlAnd_1_ln92_z = conf_done & state_fft2d_unisim_fft2d_config_fft2d[0];
      ctrlAnd_0_ln92_z = !conf_done & state_fft2d_unisim_fft2d_config_fft2d[0];
      if (state_fft2d_unisim_fft2d_config_fft2d[0]) 
        sig_size_d = conf_size;
      else 
        sig_size_d = sig_size;
      if (state_fft2d_unisim_fft2d_config_fft2d[0]) 
        sig_transpose_d = conf_transpose;
      else 
        sig_transpose_d = sig_transpose;
      if (state_fft2d_unisim_fft2d_config_fft2d[0]) 
        sig_batch_d = conf_batch;
      else 
        sig_batch_d = sig_batch;
      ctrlOr_ln109_z = state_fft2d_unisim_fft2d_config_fft2d[1] | 
      ctrlAnd_1_ln92_z;
      if (write_fft2d_sig_log2_ln98_en) 
        sig_log2_d = conf_log2;
      else 
        sig_log2_d = sig_log2;
      if (ctrlAnd_1_ln92_z) 
        init_done_d = 1'b1;
      else 
        init_done_d = init_done;
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_config_fft2d[0]: // Wait_ln93
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln92_z: state_fft2d_unisim_fft2d_config_fft2d_next[0] = 
                1'b1;
              ctrlOr_ln109_z: state_fft2d_unisim_fft2d_config_fft2d_next[1] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_config_fft2d_next = 2'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_config_fft2d[1]: // Wait_ln110
          state_fft2d_unisim_fft2d_config_fft2d_next[1] = 1'b1;
        default: // Don't care
          state_fft2d_unisim_fft2d_config_fft2d_next = 2'hX;
      endcase
    end
  fft2d_unisim_identity_sync_write_m_8192x64m32 A0_bridge0(.rtl_CE(
                                                A0_bridge0_rtl_CE_en), .rtl_A(
                                                A0_bridge0_rtl_a), .rtl_D(
                                                A0_bridge0_rtl_d), .rtl_WE(
                                                A0_bridge0_rtl_CE_en), .rtl_WEM(
                                                A0_bridge0_rtl_wem), .CLK(clk), 
                                                .mem_CE(A0_CE0), .mem_A(A0_A0), 
                                                .mem_D(A0_D0), .mem_WE(A0_WE0), 
                                                .mem_WEM(A0_WEM0));
  // synthesis sync_set_reset_local fft2d_unisim_fft2d_load_input_seq_block rst
  always @(posedge clk) // fft2d_unisim_fft2d_load_input_sequential
    begin : fft2d_unisim_fft2d_load_input_seq_block
      if (!rst) // Initialize state and outputs
      begin
        rd_length <= 32'sh0;
        rd_index <= 32'sh0;
        rd_request <= 1'sb0;
        eq_ln142_Z_0_tag_0 <= 1'sb0;
        add_ln156_q <= 31'sh0;
        mux_base_ln143_q <= 31'sh0;
        mux_s_ln143_q <= 32'sh0;
        mux_rows_ln143_0_q <= 1'sb0;
        input_valid <= 1'sb0;
        add_ln164_1_q <= 13'sh0;
        mux_i_ln164_q <= 13'sh0;
        mux_base_ln140_q <= 31'sh0;
        mux_rows_ln140_q <= 1'sb0;
        mux_s_ln140_q <= 1'sb0;
        read_fft2d_sig_batch_ln134_q <= 32'sh0;
        read_fft2d_sig_size_ln133_q <= 32'sh0;
        read_fft2d_sig_transpose_ln135_q <= 1'sb0;
        mul_ln145_q <= 31'sh0;
        add_ln187_1_q <= 31'sh0;
        bufdin_set_ready_curr <= 1'sb0;
        state_fft2d_unisim_fft2d_load_input <= 9'h1;
      end
      else // Update Q values
      begin
        rd_length <= rd_length_d;
        rd_index <= rd_index_d;
        rd_request <= rd_request_d;
        eq_ln142_Z_0_tag_0 <= eq_ln142_z;
        add_ln156_q <= add_ln156_z;
        mux_base_ln143_q <= mux_base_ln143_z;
        mux_s_ln143_q <= mux_s_ln143_z;
        mux_rows_ln143_0_q <= mux_rows_ln143_0_z;
        input_valid <= input_valid_d;
        add_ln164_1_q <= mux_i_ln164_d[13:1];
        mux_i_ln164_q <= {mux_i_ln164_1_d_0, mux_i_ln164_d[0]};
        mux_base_ln140_q <= mul_ln145_30_d_0[31:1];
        mux_rows_ln140_q <= mul_ln145_30_d_0[32];
        mux_s_ln140_q <= mul_ln145_30_d_0[33];
        read_fft2d_sig_batch_ln134_q <= read_fft2d_sig_size_ln133_31_d_0[32:1];
        read_fft2d_sig_size_ln133_q <= {read_fft2d_sig_size_ln133_31_d_0[0], 
        mux_read_fft2d_sig_size_ln133_Z_0_mux_0_v};
        read_fft2d_sig_transpose_ln135_q <= read_fft2d_sig_size_ln133_31_d_0[33];
        mul_ln145_q <= {mul_ln145_30_d_0[0], read_fft2d_sig_size_ln133_31_d_0[63:
        34]};
        add_ln187_1_q <= {add_ln187_1_30_d, mul_ln145_30_d_0[63:34]};
        bufdin_set_ready_curr <= bufdin_set_ready_curr_d;
        state_fft2d_unisim_fft2d_load_input <= 
        state_fft2d_unisim_fft2d_load_input_next;
      end
    end
  always @(*) begin : fft2d_unisim_fft2d_load_input_combinational
      reg ctrlOr_ln300_0_z;
      reg unary_nor_ln98_z;
      reg unary_nor_ln98_0_z;
      reg ctrlAnd_0_ln142_z;
      reg [30:0] mul_ln145_z;
      reg mux_i_ln164_sel_0;
      reg ctrlAnd_1_ln125_z;
      reg ctrlAnd_0_ln125_z;
      reg ctrlAnd_1_ln160_z;
      reg ctrlAnd_0_ln160_z;
      reg ctrlAnd_1_ln180_z;
      reg ctrlAnd_0_ln180_z;
      reg ctrlAnd_1_ln183_z;
      reg ctrlAnd_0_ln183_z;
      reg ctrlAnd_1_ln142_z;
      reg [31:0] mux_read_fft2d_sig_batch_ln134_Z_v;
      reg mux_read_fft2d_sig_size_ln133_Z_31_v;
      reg mux_read_fft2d_sig_transpose_ln135_Z_0_v;
      reg [30:0] mux_read_fft2d_sig_size_ln133_Z_v;
      reg mux_rows_ln142_z;
      reg [30:0] mux_base_ln142_z;
      reg [13:0] mux_i_ln164_z;
      reg [30:0] mux_mul_ln145_Z_v;
      reg [31:0] mux_s_ln142_z;
      reg ctrlOr_ln164_0_z;
      reg ctrlOr_ln142_z;
      reg ctrlOr_ln183_z;
      reg rd_request_hold;
      reg ctrlOr_ln160_z;
      reg [31:0] mux_item_ln304_z;
      reg [31:0] mux_item_ln304_0_z;
      reg mux_rows_ln140_z;
      reg [30:0] mux_base_ln140_z;
      reg eq_ln165_z;
      reg lt_ln164_z;
      reg [12:0] mux_mux_i_ln164_Z_v;
      reg [13:0] add_ln164_z;
      reg [31:0] mux_s_ln140_z;
      reg ctrlOr_ln140_z;
      reg ctrlAnd_1_ln300_0_z;
      reg ctrlAnd_0_ln300_0_z;
      reg ternaryMux_ln143_0_z;
      reg or_and_0_ln165_Z_0_z;
      reg if_ln165_z;
      reg [12:0] mux_add_ln164_Z_1_v_0;
      reg [30:0] mul_ln153_z;
      reg [31:0] add_ln187_z;
      reg ctrlAnd_0_ln165_z;
      reg and_1_ln165_z;
      reg input_valid_hold;
      reg ctrlOr_ln180_z;
      reg ctrlAnd_1_ln165_z;
      reg ctrlOr_ln300_z;
      reg ctrlAnd_0_ln300_z;
      reg ctrlAnd_1_ln300_z;
      reg mux_i_ln164_sel;
      reg add_ln187_1_30_sel;
      reg bufdin_set_ready_curr_hold;

      state_fft2d_unisim_fft2d_load_input_next = 9'h0;
      ctrlOr_ln300_0_z = state_fft2d_unisim_fft2d_load_input[7] | 
      state_fft2d_unisim_fft2d_load_input[6];
      unary_nor_ln98_z = ~bufdin_set_ready_curr;
      unary_nor_ln98_0_z = ~bufdin_set_ready_curr;
      ctrlAnd_0_ln142_z = eq_ln142_Z_0_tag_0 & 
      state_fft2d_unisim_fft2d_load_input[1];
      mul_ln145_z = sig_size[30:0] * sig_size[30:0];
      mux_i_ln164_sel_0 = ctrlOr_ln300_0_z;
      ctrlAnd_1_ln125_z = init_done & state_fft2d_unisim_fft2d_load_input[0];
      ctrlAnd_0_ln125_z = !init_done & state_fft2d_unisim_fft2d_load_input[0];
      ctrlAnd_1_ln160_z = rd_grant & state_fft2d_unisim_fft2d_load_input[2];
      ctrlAnd_0_ln160_z = !rd_grant & state_fft2d_unisim_fft2d_load_input[2];
      ctrlAnd_1_ln180_z = input_ack & state_fft2d_unisim_fft2d_load_input[3];
      ctrlAnd_0_ln180_z = !input_ack & state_fft2d_unisim_fft2d_load_input[3];
      ctrlAnd_1_ln183_z = !input_ack & state_fft2d_unisim_fft2d_load_input[4];
      ctrlAnd_0_ln183_z = input_ack & state_fft2d_unisim_fft2d_load_input[4];
      ctrlAnd_1_ln142_z = !eq_ln142_Z_0_tag_0 & 
      state_fft2d_unisim_fft2d_load_input[1];
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_read_fft2d_sig_batch_ln134_Z_v = sig_batch;
      else 
        mux_read_fft2d_sig_batch_ln134_Z_v = read_fft2d_sig_batch_ln134_q;
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_read_fft2d_sig_size_ln133_Z_31_v = sig_size[31];
      else 
        mux_read_fft2d_sig_size_ln133_Z_31_v = read_fft2d_sig_size_ln133_q[31];
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_read_fft2d_sig_transpose_ln135_Z_0_v = sig_transpose;
      else 
        mux_read_fft2d_sig_transpose_ln135_Z_0_v = 
        read_fft2d_sig_transpose_ln135_q;
      if (state_fft2d_unisim_fft2d_load_input[1]) 
        mux_read_fft2d_sig_size_ln133_Z_v = read_fft2d_sig_size_ln133_q[30:0];
      else 
        mux_read_fft2d_sig_size_ln133_Z_v = rd_length[31:1];
      if (state_fft2d_unisim_fft2d_load_input[1]) 
        mux_rows_ln142_z = mux_rows_ln143_0_q;
      else 
        mux_rows_ln142_z = mux_rows_ln140_q;
      if (state_fft2d_unisim_fft2d_load_input[1]) 
        mux_base_ln142_z = mux_base_ln143_q;
      else 
        mux_base_ln142_z = mux_base_ln140_q;
      if (state_fft2d_unisim_fft2d_load_input[2]) 
        mux_i_ln164_z = 14'h0;
      else 
        mux_i_ln164_z = {add_ln164_1_q, !mux_i_ln164_q[0]};
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_mul_ln145_Z_v = mul_ln145_z;
      else 
        mux_mul_ln145_Z_v = mul_ln145_q;
      if (state_fft2d_unisim_fft2d_load_input[1]) 
        mux_s_ln142_z = mux_s_ln143_q;
      else 
        mux_s_ln142_z = {add_ln187_1_q, !mux_s_ln140_q};
      ctrlOr_ln164_0_z = state_fft2d_unisim_fft2d_load_input[8] | 
      ctrlAnd_1_ln160_z;
      ctrlOr_ln142_z = ctrlAnd_1_ln183_z | ctrlAnd_0_ln142_z;
      ctrlOr_ln183_z = ctrlAnd_0_ln183_z | ctrlAnd_1_ln180_z;
      rd_request_hold = ~(ctrlAnd_1_ln160_z | ctrlAnd_1_ln142_z);
      ctrlOr_ln160_z = ctrlAnd_0_ln160_z | ctrlAnd_1_ln142_z;
      if (bufdin_ready) 
        mux_item_ln304_z = bufdin_data;
      else 
        mux_item_ln304_z = bufdin_data_buf;
      if (bufdin_ready) 
        mux_item_ln304_0_z = bufdin_data;
      else 
        mux_item_ln304_0_z = bufdin_data_buf;
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_read_fft2d_sig_size_ln133_Z_0_mux_0_v = sig_size[30:0];
      else 
        mux_read_fft2d_sig_size_ln133_Z_0_mux_0_v = 
        mux_read_fft2d_sig_size_ln133_Z_v;
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_rows_ln140_z = 1'b1;
      else 
        mux_rows_ln140_z = mux_rows_ln142_z;
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_base_ln140_z = 31'h0;
      else 
        mux_base_ln140_z = mux_base_ln142_z;
      eq_ln165_z = {18'h0, mux_i_ln164_z} == {read_fft2d_sig_size_ln133_q[31], 
      rd_length[31:1]};
      lt_ln164_z = ~mux_i_ln164_z[13];
      if (state_fft2d_unisim_fft2d_load_input[5]) 
        mux_mux_i_ln164_Z_v = mux_i_ln164_q;
      else 
        mux_mux_i_ln164_Z_v = mux_i_ln164_z[12:0];
      add_ln164_z = {1'b0, mux_i_ln164_z[12:0]} + 14'h1;
      if (state_fft2d_unisim_fft2d_load_input[0]) 
        mux_s_ln140_z = 32'h0;
      else 
        mux_s_ln140_z = mux_s_ln142_z;
      ctrlOr_ln140_z = ctrlOr_ln142_z | ctrlAnd_1_ln125_z;
      if (ctrlAnd_1_ln142_z) 
        rd_length_d = {read_fft2d_sig_size_ln133_q[30:0], 1'b0};
      else 
        rd_length_d = rd_length;
      if (ctrlAnd_1_ln142_z) 
        rd_index_d = {add_ln156_q, 1'b0};
      else 
        rd_index_d = rd_index;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln142_z: rd_request_d = 1'b1;
        ctrlAnd_1_ln160_z: rd_request_d = 1'b0;
        rd_request_hold: rd_request_d = rd_request;
        default: rd_request_d = 1'bX;
      endcase
      ctrlAnd_1_ln300_0_z = bufdin_can_get_sig & ctrlOr_ln300_0_z;
      ctrlAnd_0_ln300_0_z = !bufdin_can_get_sig & ctrlOr_ln300_0_z;
      ternaryMux_ln143_0_z = mux_read_fft2d_sig_transpose_ln135_Z_0_v & 
      mux_rows_ln140_z;
      or_and_0_ln165_Z_0_z = mux_i_ln164_z[13] | eq_ln165_z;
      if_ln165_z = ~eq_ln165_z;
      if (ctrlOr_ln300_0_z) begin
        A0_bridge0_rtl_wem = 2'h2;
        A0_bridge0_rtl_d = {mux_item_ln304_0_z, 32'h0};
        A0_bridge0_rtl_a = mux_i_ln164_q;
      end
      else begin
        A0_bridge0_rtl_wem = 2'h1;
        A0_bridge0_rtl_d = {32'h0, mux_item_ln304_z};
        A0_bridge0_rtl_a = mux_mux_i_ln164_Z_v;
      end
      if (state_fft2d_unisim_fft2d_load_input[5]) 
        mux_add_ln164_Z_1_v_0 = add_ln164_1_q;
      else 
        mux_add_ln164_Z_1_v_0 = add_ln164_z[13:1];
      eq_ln142_z = mux_s_ln140_z == mux_read_fft2d_sig_batch_ln134_Z_v;
      mul_ln153_z = mux_s_ln140_z[30:0] * 
      mux_read_fft2d_sig_size_ln133_Z_0_mux_0_v;
      add_ln187_z = mux_s_ln140_z + 32'h1;
      ctrlAnd_0_ln165_z = or_and_0_ln165_Z_0_z & ctrlOr_ln164_0_z;
      and_1_ln165_z = if_ln165_z & lt_ln164_z;
      add_ln156_z = mux_base_ln140_z + mul_ln153_z;
      if (ternaryMux_ln143_0_z) begin
        mux_s_ln143_z = 32'h0;
        mux_base_ln143_z = mux_mul_ln145_Z_v;
      end
      else begin
        mux_s_ln143_z = mux_s_ln140_z;
        mux_base_ln143_z = mux_base_ln140_z;
      end
      mux_rows_ln143_0_z = !ternaryMux_ln143_0_z & mux_rows_ln140_z;
      input_valid_hold = ~(ctrlAnd_1_ln180_z | ctrlAnd_0_ln165_z);
      ctrlOr_ln180_z = ctrlAnd_0_ln180_z | ctrlAnd_0_ln165_z;
      ctrlAnd_1_ln165_z = and_1_ln165_z & ctrlOr_ln164_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln165_z: input_valid_d = 1'b1;
        ctrlAnd_1_ln180_z: input_valid_d = 1'b0;
        input_valid_hold: input_valid_d = input_valid;
        default: input_valid_d = 1'bX;
      endcase
      ctrlOr_ln300_z = state_fft2d_unisim_fft2d_load_input[5] | 
      ctrlAnd_1_ln165_z;
      ctrlAnd_0_ln300_z = !bufdin_can_get_sig & ctrlOr_ln300_z;
      ctrlAnd_1_ln300_z = bufdin_can_get_sig & ctrlOr_ln300_z;
      mux_i_ln164_sel = ctrlOr_ln300_z;
      add_ln187_1_30_sel = ctrlOr_ln300_z | ctrlOr_ln300_0_z | ctrlOr_ln183_z | 
      ctrlOr_ln180_z | ctrlOr_ln160_z;
      bufdin_set_ready_curr_hold = ~(ctrlAnd_1_ln300_z | ctrlAnd_1_ln300_0_z);
      A0_bridge0_rtl_CE_en = ctrlAnd_1_ln300_z | ctrlAnd_1_ln300_0_z;
      case (1'b1)// synthesis parallel_case
        mux_i_ln164_sel: mux_i_ln164_d = {mux_add_ln164_Z_1_v_0, 
          mux_mux_i_ln164_Z_v[0]};
        mux_i_ln164_sel_0: mux_i_ln164_d = {add_ln164_1_q, mux_i_ln164_q[0]};
        default: mux_i_ln164_d = 14'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        mux_i_ln164_sel: mux_i_ln164_1_d_0 = mux_mux_i_ln164_Z_v[12:1];
        ctrlAnd_0_ln300_0_z: mux_i_ln164_1_d_0 = mux_i_ln164_q[12:1];
        default: mux_i_ln164_1_d_0 = 12'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln140_z: mul_ln145_30_d_0 = {add_ln187_z[30:1], mux_s_ln140_z[0], 
          mux_rows_ln140_z, mux_base_ln140_z, mux_mul_ln145_Z_v[30]};
        add_ln187_1_30_sel: mul_ln145_30_d_0 = {add_ln187_1_q[29:0], 
          mux_s_ln140_q, mux_rows_ln140_q, mux_base_ln140_q, mul_ln145_q[30]};
        default: mul_ln145_30_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln140_z: read_fft2d_sig_size_ln133_31_d_0 = {mux_mul_ln145_Z_v[29:
          0], mux_read_fft2d_sig_transpose_ln135_Z_0_v, 
          mux_read_fft2d_sig_batch_ln134_Z_v, 
          mux_read_fft2d_sig_size_ln133_Z_31_v};
        add_ln187_1_30_sel: read_fft2d_sig_size_ln133_31_d_0 = {mul_ln145_q[29:0], 
          read_fft2d_sig_transpose_ln135_q, read_fft2d_sig_batch_ln134_q, 
          read_fft2d_sig_size_ln133_q[31]};
        default: read_fft2d_sig_size_ln133_31_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln140_z: add_ln187_1_30_d = add_ln187_z[31];
        add_ln187_1_30_sel: add_ln187_1_30_d = add_ln187_1_q[30];
        default: add_ln187_1_30_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln300_z: bufdin_set_ready_curr_d = unary_nor_ln98_z;
        ctrlAnd_1_ln300_0_z: bufdin_set_ready_curr_d = unary_nor_ln98_0_z;
        bufdin_set_ready_curr_hold: bufdin_set_ready_curr_d = 
          bufdin_set_ready_curr;
        default: bufdin_set_ready_curr_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_load_input[0]: // Wait_ln125
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln125_z: state_fft2d_unisim_fft2d_load_input_next[0] = 
                1'b1;
              ctrlOr_ln140_z: state_fft2d_unisim_fft2d_load_input_next[1] = 1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[1]: // Wait_ln147
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln140_z: state_fft2d_unisim_fft2d_load_input_next[1] = 1'b1;
              ctrlOr_ln160_z: state_fft2d_unisim_fft2d_load_input_next[2] = 1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[2]: // Wait_ln160
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln160_z: state_fft2d_unisim_fft2d_load_input_next[2] = 1'b1;
              ctrlOr_ln180_z: state_fft2d_unisim_fft2d_load_input_next[3] = 1'b1;
              ctrlAnd_0_ln300_z: state_fft2d_unisim_fft2d_load_input_next[5] = 
                1'b1;
              ctrlAnd_1_ln300_z: state_fft2d_unisim_fft2d_load_input_next[6] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[3]: // Wait_ln180
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln180_z: state_fft2d_unisim_fft2d_load_input_next[3] = 1'b1;
              ctrlOr_ln183_z: state_fft2d_unisim_fft2d_load_input_next[4] = 1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[4]: // Wait_ln183
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln183_z: state_fft2d_unisim_fft2d_load_input_next[4] = 1'b1;
              ctrlOr_ln140_z: state_fft2d_unisim_fft2d_load_input_next[1] = 1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[5]: // Wait_ln300
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_z: state_fft2d_unisim_fft2d_load_input_next[5] = 
                1'b1;
              ctrlAnd_1_ln300_z: state_fft2d_unisim_fft2d_load_input_next[6] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[6]: // Wait_ln170
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_0_z: state_fft2d_unisim_fft2d_load_input_next[7] = 
                1'b1;
              ctrlAnd_1_ln300_0_z: state_fft2d_unisim_fft2d_load_input_next[8] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[7]: // Wait_ln300_0
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln300_0_z: state_fft2d_unisim_fft2d_load_input_next[7] = 
                1'b1;
              ctrlAnd_1_ln300_0_z: state_fft2d_unisim_fft2d_load_input_next[8] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_load_input[8]: // Wait_ln174
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln180_z: state_fft2d_unisim_fft2d_load_input_next[3] = 1'b1;
              ctrlAnd_0_ln300_z: state_fft2d_unisim_fft2d_load_input_next[5] = 
                1'b1;
              ctrlAnd_1_ln300_z: state_fft2d_unisim_fft2d_load_input_next[6] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_load_input_next = 9'hX;
            endcase
          end
        default: // Don't care
          state_fft2d_unisim_fft2d_load_input_next = 9'hX;
      endcase
    end
  fft2d_unisim_identity_sync_write_8192x64m0 B0_bridge0(.rtl_CE(
                                             B0_bridge0_rtl_CE_en), .rtl_A(
                                             B0_bridge0_rtl_a), .rtl_D(
                                             B0_bridge0_rtl_d), .rtl_WE(
                                             B0_bridge0_rtl_CE_en), .CLK(clk), .mem_CE(
                                             B0_CE0), .mem_A(B0_A0), .mem_D(
                                             B0_D0), .mem_WE(B0_WE0));
  fft2d_unisim_identity_sync_read_write_m_8192x64m32 A0_bridge1(.rtl_CE(
                                                     A0_bridge1_rtl_CE_en), .rtl_A(
                                                     A0_bridge1_rtl_a), .mem_Q(
                                                     A0_Q1), .rtl_D(
                                                     A0_bridge1_rtl_d), .rtl_WE(
                                                     A0_bridge1_rtl_WE_en), .rtl_WEM(
                                                     2'h3), .CLK(clk), .mem_CE(
                                                     A0_CE1), .mem_A(A0_A1), .rtl_Q(
                                                     A0_bridge1_rtl_Q), .mem_D(
                                                     A0_D1), .mem_WE(A0_WE1), .mem_WEM(
                                                     A0_WEM1));
  // synthesis sync_set_reset_local fft2d_unisim_fft2d_process_itr_fft2d_seq_block rst
  always @(posedge clk) // fft2d_unisim_fft2d_process_itr_fft2d_sequential
    begin : fft2d_unisim_fft2d_process_itr_fft2d_seq_block
      if (!rst) // Initialize state and outputs
      begin
        memread_fft2d_A0_ln338_q <= 64'sh0;
        memread_fft2d_A0_ln381_q <= 64'sh0;
        add_ln176_1_11_q <= 55'h0;
        memread_fft2d_A0_ln336_q <= 64'sh0;
        memread_fft2d_A0_ln379_q <= 64'sh0;
        sub_ln196_2_11_q <= 55'h0;
        add_ln404_3_q <= 32'sh0;
        add_ln404_4_q <= 32'sh0;
        mul_ln221_q <= 89'sh0;
        mul_ln221_1_q <= 89'sh0;
        mul_ln221_0_q <= 90'sh0;
        mul_ln221_2_q <= 90'sh0;
        lt_ln328_q <= 1'sb0;
        add_ln404_q <= 56'sh0;
        add_ln404_0_q <= 56'sh0;
        input_ack <= 1'sb0;
        output_valid <= 1'sb0;
        or_and_0_ln360_Z_0_q <= 1'sb0;
        or_and_0_ln351_Z_0_q <= 1'sb0;
        mux_i_ln328_q <= 13'sh0;
        add_ln328_1_q <= 31'sh0;
        and_1_ln360_q <= 1'sb0;
        rsh_ln333_q <= 13'sh0;
        lt_ln335_q <= 1'sb0;
        and_1_ln351_q <= 1'sb0;
        add_ln371_q <= 13'sh0;
        add_ln372_0_q <= 13'sh0;
        mux_j_ln367_q <= 1'sb0;
        add_ln367_1_q <= 12'h0;
        mux_w_ln367_q <= 112'sh0;
        mux_k_ln359_q <= 13'sh0;
        add_ln359_q <= 32'sh0;
        eq_ln408_Z_0_tag_0 <= 1'sb0;
        lsh_ln354_q <= 16'sh0;
        mux_myCos_ln41_q <= 33'sh0;
        mux_s_ln350_q <= 1'sb0;
        add_ln350_1_q <= 3'h0;
        mux_mySin_ln61_q <= 34'sh0;
        read_fft2d_sig_size_ln309_q <= 32'sh0;
        read_fft2d_sig_log2_ln310_q <= 32'sh0;
        add_ln325_1_q <= 4'sh0;
        state_fft2d_unisim_fft2d_process_itr_fft2d <= 23'h1;
      end
      else // Update Q values
      begin
        memread_fft2d_A0_ln338_q <= A0_bridge1_rtl_Q;
        memread_fft2d_A0_ln381_q <= A0_bridge1_rtl_Q;
        add_ln176_1_11_q <= add_ln176_1_z[65:11];
        memread_fft2d_A0_ln336_q <= memread_fft2d_A0_ln336_d;
        memread_fft2d_A0_ln379_q <= memread_fft2d_A0_ln379_d;
        sub_ln196_2_11_q <= sub_ln196_2_z[65:11];
        add_ln404_3_q <= add_ln404_3_z;
        add_ln404_4_q <= add_ln404_4_z;
        mul_ln221_q <= mul_ln221_z;
        mul_ln221_1_q <= mul_ln221_1_z;
        mul_ln221_0_q <= mul_ln221_0_z;
        mul_ln221_2_q <= mul_ln221_2_z;
        lt_ln328_q <= lt_ln328_z;
        add_ln404_q <= {add_ln404_8_d_0, add_ln404_0_d_0[63:56]};
        add_ln404_0_q <= add_ln404_0_d_0[55:0];
        input_ack <= input_ack_d;
        output_valid <= output_valid_d;
        or_and_0_ln360_Z_0_q <= or_and_0_ln360_Z_0_z;
        or_and_0_ln351_Z_0_q <= or_and_0_ln351_Z_0_z;
        mux_i_ln328_q <= {mux_i_ln328_1_d_0, mux_i_ln328_d[0]};
        add_ln328_1_q <= mux_i_ln328_d[31:1];
        and_1_ln360_q <= and_1_ln360_z;
        rsh_ln333_q <= rsh_ln333_d;
        lt_ln335_q <= lt_ln335_z;
        and_1_ln351_q <= and_1_ln351_z;
        add_ln371_q <= add_ln371_d;
        add_ln372_0_q <= add_ln372_0_d;
        mux_j_ln367_q <= mux_j_ln367_d_0[0];
        add_ln367_1_q <= mux_j_ln367_d_0[12:1];
        mux_w_ln367_q <= {mux_w_ln367_64_d_0, mux_w_ln367_d};
        mux_k_ln359_q <= mux_k_ln359_d[12:0];
        add_ln359_q <= mux_k_ln359_d[44:13];
        eq_ln408_Z_0_tag_0 <= mux_s_ln350_d_0[20];
        lsh_ln354_q <= mux_s_ln350_d_0[16:1];
        mux_myCos_ln41_q <= mux_s_ln350_d_0[53:21];
        mux_s_ln350_q <= mux_s_ln350_d_0[0];
        add_ln350_1_q <= mux_s_ln350_d_0[19:17];
        mux_mySin_ln61_q <= {mux_mySin_ln61_10_d_0, mux_s_ln350_d_0[63:54]};
        read_fft2d_sig_size_ln309_q <= read_fft2d_sig_size_ln309_d[31:0];
        read_fft2d_sig_log2_ln310_q <= read_fft2d_sig_size_ln309_d[63:32];
        add_ln325_1_q <= add_ln325_1_d;
        state_fft2d_unisim_fft2d_process_itr_fft2d <= 
        state_fft2d_unisim_fft2d_process_itr_fft2d_next;
      end
    end
  fft2d_unisim___rev fft2d_unisim___rev(.v_in(mux_i_ln328_z), ._rev_out(
                     fft2d_unisim___rev_ln332_z));
  always @(*) begin : fft2d_unisim_fft2d_process_itr_fft2d_combinational
      reg A0_bridge1_rtl_a_sel;
      reg A0_bridge1_rtl_a_sel_0;
      reg ctrlOr_ln367_0_z;
      reg A0_bridge1_rtl_a_sel_1;
      reg memwrite_fft2d_B0_ln409_en;
      reg memwrite_fft2d_B0_ln411_en;
      reg [53:0] add_ln404_5_z;
      reg [53:0] add_ln404_0_0_z;
      reg [89:0] sub_ln196_z;
      reg signed [65:0] mul_ln221_1_0_z;
      reg signed [65:0] mul_ln221_2_0_z;
      reg [88:0] add_ln176_z;
      reg [4:0] not_ln325_z;
      reg add_ln371_sel;
      reg add_ln372_0_sel;
      reg add_ln404_0_mux_0_sel;
      reg ctrlAnd_0_ln328_z;
      reg ctrlAnd_0_ln351_z;
      reg ctrlAnd_0_ln360_z;
      reg ctrlAnd_1_ln351_z;
      reg ctrlAnd_1_ln360_z;
      reg ctrlOr_ln328_z;
      reg memread_fft2d_A0_ln336_sel;
      reg memread_fft2d_A0_ln379_sel;
      reg mux_j_ln367_mux_0_sel;
      reg mux_w_ln367_sel;
      reg signed [65:0] mul_ln221_3_z;
      reg signed [65:0] mul_ln221_0_0_z;
      reg [53:0] sub_ln196_1_z;
      reg [31:0] add_ln176_2_z;
      reg [53:0] sub_ln196_0_0_z;
      reg [31:0] add_ln176_0_0_z;
      reg [55:0] add_ln176_0_z;
      reg [89:0] sub_ln196_0_z;
      reg [4:0] add_ln325_z;
      reg ctrlAnd_1_ln304_z;
      reg ctrlAnd_0_ln304_z;
      reg ctrlAnd_1_ln315_z;
      reg ctrlAnd_0_ln315_z;
      reg ctrlAnd_0_ln335_z;
      reg ctrlOr_ln350_0_z;
      reg ctrlAnd_1_ln434_z;
      reg ctrlAnd_0_ln434_z;
      reg ctrlAnd_1_ln438_z;
      reg ctrlAnd_0_ln438_z;
      reg ctrlAnd_1_ln441_z;
      reg ctrlAnd_0_ln441_z;
      reg ctrlAnd_1_ln328_z;
      reg ctrlAnd_1_ln335_z;
      reg [31:0] mux_read_fft2d_sig_log2_ln310_Z_v;
      reg [31:0] mux_read_fft2d_sig_size_ln309_Z_v;
      reg memwrite_fft2d_A0_ln418_en;
      reg memwrite_fft2d_A0_ln416_en;
      reg [31:0] mux_k_ln359_z;
      reg [111:0] mux_w_ln367_z;
      reg [12:0] mux_j_ln367_z;
      reg [3:0] mux_s_ln350_z;
      reg [31:0] add_ln404_1_z;
      reg [31:0] add_ln404_2_z;
      reg [55:0] add_ln404_0_z;
      reg [55:0] add_ln404_z;
      reg [3:0] mux_add_ln325_Z_1_v_1;
      reg mux_i_ln328_1_mux_0_sel;
      reg rsh_ln333_sel;
      reg input_ack_hold;
      reg ctrlOr_ln434_z;
      reg output_valid_hold;
      reg ctrlOr_ln438_z;
      reg ctrlOr_ln313_z;
      reg ctrlOr_ln441_z;
      reg ctrlOr_ln335_z;
      reg [31:0] mux_read_fft2d_sig_log2_ln310_Z_0_mux_0_v;
      reg [31:0] mux_read_fft2d_sig_size_ln309_Z_0_mux_0_v;
      reg eq_ln360_z;
      reg lt_ln359_z;
      reg [31:0] add_ln359_z;
      reg [31:0] add_ln328_z;
      reg [12:0] add_ln367_z;
      reg eq_ln368_z;
      reg lt_ln367_z;
      reg [12:0] add_ln371_z;
      reg eq_ln408_z;
      reg gt_ln351_z;
      reg le_ln350_z;
      reg [15:0] lsh_ln354_z;
      reg [13:0] switch_ln43_z;
      reg [33:0] mux_mySin_ln61_z;
      reg [32:0] mux_myCos_ln41_z;
      reg [3:0] add_ln350_z;
      reg [3:0] mux_add_ln325_Z_1_mux_0_v;
      reg ctrlOr_ln315_z;
      reg mux_i_ln328_sel;
      reg if_ln360_z;
      reg [31:0] rsh_ln333_z;
      reg or_and_0_ln368_Z_0_z;
      reg if_ln368_z;
      reg [12:0] add_ln372_0_z;
      reg if_ln351_z;
      reg ctrlAnd_0_ln368_z;
      reg and_1_ln368_z;
      reg ctrlOr_ln359_0_z;
      reg ctrlAnd_1_ln368_z;
      reg mux_k_ln359_sel;
      reg mux_s_ln350_mux_0_sel;
      reg read_fft2d_sig_size_ln309_sel;

      state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'h0;
      A0_bridge1_rtl_a_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[3] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[6];
      A0_bridge1_rtl_a_sel_0 = state_fft2d_unisim_fft2d_process_itr_fft2d[7] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[4];
      ctrlOr_ln367_0_z = state_fft2d_unisim_fft2d_process_itr_fft2d[22] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[16];
      A0_bridge1_rtl_a_sel_1 = state_fft2d_unisim_fft2d_process_itr_fft2d[21] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17];
      memwrite_fft2d_B0_ln409_en = 
      state_fft2d_unisim_fft2d_process_itr_fft2d[20] & eq_ln408_Z_0_tag_0;
      memwrite_fft2d_B0_ln411_en = eq_ln408_Z_0_tag_0 & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[21];
      add_ln404_5_z = sub_ln196_2_11_q[54:1] + sub_ln196_2_11_q[0];
      add_ln404_0_0_z = add_ln176_1_11_q[54:1] + add_ln176_1_11_q[0];
      sub_ln196_z = {mul_ln221_1_q, 1'b0} - mul_ln221_2_q;
      mul_ln221_1_0_z = $signed(mux_w_ln367_q[55:0]) * $signed(
      memread_fft2d_A0_ln381_q[63:32]);
      mul_ln221_2_0_z = $signed(mux_w_ln367_q[111:56]) * $signed(
      memread_fft2d_A0_ln381_q[31:0]);
      add_ln176_z = mul_ln221_q + mul_ln221_0_q[89:1];
      not_ln325_z = ~sig_log2[4:0];
      add_ln371_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[19] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17];
      add_ln372_0_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[20] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[19] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17];
      add_ln404_0_mux_0_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[20] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[19] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[21] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18];
      ctrlAnd_0_ln328_z = lt_ln328_q & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[3];
      ctrlAnd_0_ln351_z = or_and_0_ln351_Z_0_q & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[10];
      ctrlAnd_0_ln360_z = or_and_0_ln360_Z_0_q & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[15];
      ctrlAnd_1_ln351_z = and_1_ln351_q & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[10];
      ctrlAnd_1_ln360_z = and_1_ln360_q & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[15];
      ctrlOr_ln328_z = state_fft2d_unisim_fft2d_process_itr_fft2d[8] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[2];
      memread_fft2d_A0_ln336_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[5] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[6];
      memread_fft2d_A0_ln379_sel = 
      state_fft2d_unisim_fft2d_process_itr_fft2d[19] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18];
      mux_j_ln367_mux_0_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[20] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[19] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[21] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17];
      mux_w_ln367_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[18] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17];
      mul_ln221_3_z = $signed(mux_w_ln367_q[55:0]) * $signed(
      memread_fft2d_A0_ln381_q[31:0]);
      mul_ln221_0_0_z = $signed(mux_w_ln367_q[111:56]) * $signed(
      memread_fft2d_A0_ln381_q[63:32]);
      B0_bridge0_rtl_CE_en = memwrite_fft2d_B0_ln411_en | 
      memwrite_fft2d_B0_ln409_en;
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[20]) 
        B0_bridge0_rtl_a = add_ln371_q;
      else 
        B0_bridge0_rtl_a = add_ln372_0_q;
      sub_ln196_1_z = {memread_fft2d_A0_ln379_q[31:0], 22'h0} - add_ln404_5_z;
      add_ln176_2_z = memread_fft2d_A0_ln379_q[31:0] + add_ln404_5_z[53:22];
      sub_ln196_0_0_z = {memread_fft2d_A0_ln379_q[63:32], 22'h0} - 
      add_ln404_0_0_z;
      add_ln176_0_0_z = memread_fft2d_A0_ln379_q[63:32] + add_ln404_0_0_z[53:22];
      add_ln176_0_z = sub_ln196_z[89:34] + mux_w_ln367_q[111:56];
      add_ln176_1_z = $unsigned(mul_ln221_1_0_z) + $unsigned(mul_ln221_2_0_z);
      sub_ln196_0_z = {mux_w_ln367_q[55:0], 34'h0} - {add_ln176_z, mul_ln221_0_q
      [0]};
      add_ln325_z = not_ln325_z + 5'h1;
      ctrlAnd_1_ln304_z = init_done & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[0];
      ctrlAnd_0_ln304_z = !init_done & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[0];
      ctrlAnd_1_ln315_z = input_valid & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[1];
      ctrlAnd_0_ln315_z = !input_valid & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[1];
      ctrlAnd_0_ln335_z = lt_ln335_q & ctrlAnd_0_ln328_z;
      ctrlOr_ln350_0_z = ctrlAnd_0_ln360_z | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[9];
      ctrlAnd_1_ln434_z = !input_valid & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[11];
      ctrlAnd_0_ln434_z = input_valid & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[11];
      ctrlAnd_1_ln438_z = output_ack & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[12];
      ctrlAnd_0_ln438_z = !output_ack & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[12];
      ctrlAnd_1_ln441_z = !output_ack & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[13];
      ctrlAnd_0_ln441_z = output_ack & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[13];
      ctrlAnd_1_ln328_z = !lt_ln328_q & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[3];
      ctrlAnd_1_ln335_z = !lt_ln335_q & ctrlAnd_0_ln328_z;
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[0]) 
        mux_read_fft2d_sig_log2_ln310_Z_v = sig_log2;
      else 
        mux_read_fft2d_sig_log2_ln310_Z_v = read_fft2d_sig_log2_ln310_q;
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[0]) 
        mux_read_fft2d_sig_size_ln309_Z_v = sig_size;
      else 
        mux_read_fft2d_sig_size_ln309_Z_v = read_fft2d_sig_size_ln309_q;
      memwrite_fft2d_A0_ln418_en = !eq_ln408_Z_0_tag_0 & 
      state_fft2d_unisim_fft2d_process_itr_fft2d[21];
      memwrite_fft2d_A0_ln416_en = 
      state_fft2d_unisim_fft2d_process_itr_fft2d[20] & !eq_ln408_Z_0_tag_0;
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[14]) 
        mux_k_ln359_z = 32'h0;
      else 
        mux_k_ln359_z = add_ln359_q;
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[16]) 
        mux_w_ln367_z = 112'h400000000;
      else 
        mux_w_ln367_z = {add_ln404_0_q, add_ln404_q};
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_process_itr_fft2d[4]: memread_fft2d_A0_ln336_d = 
          A0_bridge1_rtl_Q;
        memread_fft2d_A0_ln336_sel: memread_fft2d_A0_ln336_d = 
          memread_fft2d_A0_ln336_q;
        default: memread_fft2d_A0_ln336_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_process_itr_fft2d[17]: memread_fft2d_A0_ln379_d = 
          A0_bridge1_rtl_Q;
        memread_fft2d_A0_ln379_sel: memread_fft2d_A0_ln379_d = 
          memread_fft2d_A0_ln379_q;
        default: memread_fft2d_A0_ln379_d = 64'hX;
      endcase
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[2]) 
        mux_i_ln328_z = 32'h0;
      else 
        mux_i_ln328_z = {add_ln328_1_q, !mux_i_ln328_q[0]};
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[16]) 
        mux_j_ln367_z = 13'h0;
      else 
        mux_j_ln367_z = {add_ln367_1_q, !mux_j_ln367_q};
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[9]) 
        mux_s_ln350_z = 4'h1;
      else 
        mux_s_ln350_z = {add_ln350_1_q, !mux_s_ln350_q};
      sub_ln196_2_z = $unsigned(mul_ln221_3_z) - $unsigned(mul_ln221_0_0_z);
      add_ln404_3_z = sub_ln196_1_z[53:22] + sub_ln196_1_z[21];
      add_ln404_1_z = add_ln176_2_z + add_ln404_5_z[21];
      add_ln404_4_z = sub_ln196_0_0_z[53:22] + sub_ln196_0_0_z[21];
      add_ln404_2_z = add_ln176_0_0_z + add_ln404_0_0_z[21];
      add_ln404_0_z = add_ln176_0_z + sub_ln196_z[33];
      add_ln404_z = sub_ln196_0_z[89:34] + sub_ln196_0_z[33];
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[0]) 
        mux_add_ln325_Z_1_v_1 = add_ln325_z[4:1];
      else 
        mux_add_ln325_Z_1_v_1 = add_ln325_1_q;
      mux_i_ln328_1_mux_0_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[5] | 
      ctrlAnd_0_ln335_z | state_fft2d_unisim_fft2d_process_itr_fft2d[4];
      rsh_ln333_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[5] | 
      ctrlAnd_0_ln335_z | state_fft2d_unisim_fft2d_process_itr_fft2d[6] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[4];
      input_ack_hold = ~(ctrlAnd_1_ln434_z | ctrlAnd_0_ln351_z);
      ctrlOr_ln434_z = ctrlAnd_0_ln434_z | ctrlAnd_0_ln351_z;
      output_valid_hold = ~(ctrlAnd_1_ln438_z | ctrlAnd_0_ln351_z);
      ctrlOr_ln438_z = ctrlAnd_0_ln438_z | ctrlAnd_1_ln434_z;
      ctrlOr_ln313_z = ctrlAnd_1_ln441_z | ctrlAnd_1_ln304_z;
      ctrlOr_ln441_z = ctrlAnd_0_ln441_z | ctrlAnd_1_ln438_z;
      ctrlOr_ln335_z = ctrlAnd_1_ln335_z | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[7];
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[1]) 
        mux_read_fft2d_sig_log2_ln310_Z_0_mux_0_v = read_fft2d_sig_log2_ln310_q;
      else 
        mux_read_fft2d_sig_log2_ln310_Z_0_mux_0_v = 
        mux_read_fft2d_sig_log2_ln310_Z_v;
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[1]) 
        mux_read_fft2d_sig_size_ln309_Z_0_mux_0_v = read_fft2d_sig_size_ln309_q;
      else 
        mux_read_fft2d_sig_size_ln309_Z_0_mux_0_v = 
        mux_read_fft2d_sig_size_ln309_Z_v;
      A0_bridge1_rtl_WE_en = memwrite_fft2d_A0_ln418_en | 
      memwrite_fft2d_A0_ln416_en | state_fft2d_unisim_fft2d_process_itr_fft2d[7] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[6];
      eq_ln360_z = mux_k_ln359_z == read_fft2d_sig_size_ln309_q;
      lt_ln359_z = mux_k_ln359_z[31:13] == 19'h0;
      add_ln359_z = mux_k_ln359_z + lsh_ln354_q;
      mul_ln221_z = $signed(mux_w_ln367_z[111:56]) * $signed(mux_mySin_ln61_q);
      mul_ln221_1_z = $signed(mux_w_ln367_z[55:0]) * $signed(mux_mySin_ln61_q);
      mul_ln221_0_z = $signed(mux_w_ln367_z[55:0]) * $signed({1'sb0, 
      mux_myCos_ln41_q[32], 1'sb0, mux_myCos_ln41_q[31], mux_myCos_ln41_q[29], 
      mux_myCos_ln41_q[31:0]});
      mul_ln221_2_z = $signed(mux_w_ln367_z[111:56]) * $signed({1'sb0, 
      mux_myCos_ln41_q[32], 1'sb0, mux_myCos_ln41_q[31], mux_myCos_ln41_q[29], 
      mux_myCos_ln41_q[31:0]});
      lt_ln328_z = {1'b0, read_fft2d_sig_size_ln309_q} > {1'b0, mux_i_ln328_z};
      add_ln328_z = mux_i_ln328_z + 32'h1;
      add_ln367_z = {1'b0, mux_j_ln367_z[11:0]} + 13'h1;
      eq_ln368_z = {2'h0, mux_j_ln367_z} == lsh_ln354_q[15:1];
      lt_ln367_z = ~mux_j_ln367_z[12];
      add_ln371_z = mux_k_ln359_q + mux_j_ln367_z;
      eq_ln408_z = {28'h0, mux_s_ln350_z} == read_fft2d_sig_log2_ln310_q;
      gt_ln351_z = {29'h0, mux_s_ln350_z} > {1'b0, read_fft2d_sig_log2_ln310_q};
      le_ln350_z = mux_s_ln350_z[3:1] == 3'h7;
      case (mux_s_ln350_z)
        4'h0: lsh_ln354_z = 16'h1;
        4'h1: lsh_ln354_z = 16'h2;
        4'h2: lsh_ln354_z = 16'h4;
        4'h3: lsh_ln354_z = 16'h8;
        4'h4: lsh_ln354_z = 16'h10;
        4'h5: lsh_ln354_z = 16'h20;
        4'h6: lsh_ln354_z = 16'h40;
        4'h7: lsh_ln354_z = 16'h80;
        4'h8: lsh_ln354_z = 16'h100;
        4'h9: lsh_ln354_z = 16'h200;
        4'ha: lsh_ln354_z = 16'h400;
        4'hb: lsh_ln354_z = 16'h800;
        4'hc: lsh_ln354_z = 16'h1000;
        4'hd: lsh_ln354_z = 16'h2000;
        4'he: lsh_ln354_z = 16'h4000;
        4'hf: lsh_ln354_z = 16'h8000;
        default: lsh_ln354_z = 16'h0;
      endcase
      case (mux_s_ln350_z)
        4'h1: begin
            mux_mySin_ln61_z = 34'h2ef;
            mux_myCos_ln41_z = 33'h100000000;
          end
        4'h2: begin
            mux_mySin_ln61_z = 34'h200000000;
            mux_myCos_ln41_z = 33'hfffffc00;
          end
        4'h3: begin
            mux_mySin_ln61_z = 34'h295f61a00;
            mux_myCos_ln41_z = 33'h2bec3600;
          end
        4'h4: begin
            mux_mySin_ln61_z = 34'h33c10ea00;
            mux_myCos_ln41_z = 33'h4df28600;
          end
        4'h5: begin
            mux_mySin_ln61_z = 34'h39c1d1f00;
            mux_myCos_ln41_z = 33'h13ad0600;
          end
        4'h6: begin
            mux_mySin_ln61_z = 34'h3cdd0b280;
            mux_myCos_ln41_z = 33'h4ee4b88;
          end
        4'h7: begin
            mux_mySin_ln61_z = 34'h3e6e09a00;
            mux_myCos_ln41_z = 33'h13bc392;
          end
        4'h8: begin
            mux_mySin_ln61_z = 34'h3f36f5500;
            mux_myCos_ln41_z = 33'h4ef3f0;
          end
        4'h9: begin
            mux_mySin_ln61_z = 34'h3f9b78b80;
            mux_myCos_ln41_z = 33'h13bd2d;
          end
        4'ha: begin
            mux_mySin_ln61_z = 34'h3fcdbc1e0;
            mux_myCos_ln41_z = 33'h4ef4e;
          end
        4'hb: begin
            mux_mySin_ln61_z = 34'h3fe6de074;
            mux_myCos_ln41_z = 33'h13bd4;
          end
        4'hc: begin
            mux_mySin_ln61_z = 34'h3ff36f02a;
            mux_myCos_ln41_z = 33'h4ef5;
          end
        4'hd: begin
            mux_mySin_ln61_z = 34'h3ff9b7813;
            mux_myCos_ln41_z = 33'h13bd;
          end
        default: begin
            mux_mySin_ln61_z = 34'h0;
            mux_myCos_ln41_z = 33'h0;
          end
      endcase
      add_ln350_z = mux_s_ln350_z + 4'h1;
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[20]) 
        B0_bridge0_rtl_d = {add_ln404_2_z, add_ln404_1_z};
      else 
        B0_bridge0_rtl_d = {add_ln404_4_q, add_ln404_3_q};
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_process_itr_fft2d[6]: A0_bridge1_rtl_d = 
          memread_fft2d_A0_ln338_q;
        state_fft2d_unisim_fft2d_process_itr_fft2d[7]: A0_bridge1_rtl_d = 
          memread_fft2d_A0_ln336_q;
        state_fft2d_unisim_fft2d_process_itr_fft2d[20]: A0_bridge1_rtl_d = {
          add_ln404_2_z, add_ln404_1_z};
        state_fft2d_unisim_fft2d_process_itr_fft2d[21]: A0_bridge1_rtl_d = {
          add_ln404_4_q, add_ln404_3_q};
        default: A0_bridge1_rtl_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_process_itr_fft2d[17]: add_ln404_8_d_0 = 
          add_ln404_z[55:8];
        add_ln404_0_mux_0_sel: add_ln404_8_d_0 = add_ln404_q[55:8];
        default: add_ln404_8_d_0 = 48'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_process_itr_fft2d[17]: add_ln404_0_d_0 = {
          add_ln404_z[7:0], add_ln404_0_z};
        add_ln404_0_mux_0_sel: add_ln404_0_d_0 = {add_ln404_q[7:0], 
          add_ln404_0_q};
        default: add_ln404_0_d_0 = 64'hX;
      endcase
      if (state_fft2d_unisim_fft2d_process_itr_fft2d[1]) 
        mux_add_ln325_Z_1_mux_0_v = add_ln325_1_q;
      else 
        mux_add_ln325_Z_1_mux_0_v = mux_add_ln325_Z_1_v_1;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln328_z: mux_i_ln328_1_d_0 = mux_i_ln328_z[12:1];
        mux_i_ln328_1_mux_0_sel: mux_i_ln328_1_d_0 = mux_i_ln328_q[12:1];
        default: mux_i_ln328_1_d_0 = 12'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln351_z: input_ack_d = 1'b1;
        ctrlAnd_1_ln434_z: input_ack_d = 1'b0;
        input_ack_hold: input_ack_d = input_ack;
        default: input_ack_d = 1'bX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_0_ln351_z: output_valid_d = 1'b1;
        ctrlAnd_1_ln438_z: output_valid_d = 1'b0;
        output_valid_hold: output_valid_d = output_valid;
        default: output_valid_d = 1'bX;
      endcase
      ctrlOr_ln315_z = ctrlAnd_0_ln315_z | ctrlOr_ln313_z;
      mux_i_ln328_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[5] | 
      ctrlOr_ln335_z | ctrlAnd_0_ln335_z | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[6] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[4];
      if_ln360_z = ~eq_ln360_z;
      or_and_0_ln360_Z_0_z = !lt_ln359_z | eq_ln360_z;
      rsh_ln333_z = fft2d_unisim___rev_ln332_z >> {add_ln325_1_q, 
      read_fft2d_sig_log2_ln310_q[0]};
      or_and_0_ln368_Z_0_z = mux_j_ln367_z[12] | eq_ln368_z;
      if_ln368_z = ~eq_ln368_z;
      add_ln372_0_z = lsh_ln354_q[13:1] + add_ln371_z;
      case (1'b1)// synthesis parallel_case
        A0_bridge1_rtl_a_sel: A0_bridge1_rtl_a = mux_i_ln328_q;
        A0_bridge1_rtl_a_sel_0: A0_bridge1_rtl_a = rsh_ln333_q;
        ctrlOr_ln367_0_z: A0_bridge1_rtl_a = add_ln371_z;
        A0_bridge1_rtl_a_sel_1: A0_bridge1_rtl_a = add_ln372_0_q;
        state_fft2d_unisim_fft2d_process_itr_fft2d[20]: A0_bridge1_rtl_a = 
          add_ln371_q;
        default: A0_bridge1_rtl_a = 13'hX;
      endcase
      if_ln351_z = ~gt_ln351_z;
      or_and_0_ln351_Z_0_z = le_ln350_z | gt_ln351_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln328_z: mux_i_ln328_d = {add_ln328_z[31:1], mux_i_ln328_z[0]};
        mux_i_ln328_sel: mux_i_ln328_d = {add_ln328_1_q, mux_i_ln328_q[0]};
        default: mux_i_ln328_d = 32'hX;
      endcase
      and_1_ln360_z = if_ln360_z & lt_ln359_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln328_z: rsh_ln333_d = rsh_ln333_z[12:0];
        rsh_ln333_sel: rsh_ln333_d = rsh_ln333_q;
        default: rsh_ln333_d = 13'hX;
      endcase
      lt_ln335_z = {1'b0, rsh_ln333_z} > {1'b0, mux_i_ln328_z};
      ctrlAnd_0_ln368_z = or_and_0_ln368_Z_0_z & ctrlOr_ln367_0_z;
      and_1_ln368_z = if_ln368_z & lt_ln367_z;
      and_1_ln351_z = if_ln351_z & !le_ln350_z;
      ctrlOr_ln359_0_z = ctrlAnd_0_ln368_z | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[14];
      ctrlAnd_1_ln368_z = and_1_ln368_z & ctrlOr_ln367_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln368_z: add_ln371_d = add_ln371_z;
        add_ln371_sel: add_ln371_d = add_ln371_q;
        default: add_ln371_d = 13'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln368_z: add_ln372_0_d = add_ln372_0_z;
        add_ln372_0_sel: add_ln372_0_d = add_ln372_0_q;
        default: add_ln372_0_d = 13'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln368_z: mux_j_ln367_d_0 = {add_ln367_z[12:1], mux_j_ln367_z[0]};
        mux_j_ln367_mux_0_sel: mux_j_ln367_d_0 = {add_ln367_1_q, mux_j_ln367_q};
        default: mux_j_ln367_d_0 = 13'hX;
      endcase
      mux_k_ln359_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[20] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[19] | ctrlAnd_1_ln368_z | 
      ctrlAnd_1_ln360_z | state_fft2d_unisim_fft2d_process_itr_fft2d[21] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17];
      mux_s_ln350_mux_0_sel = state_fft2d_unisim_fft2d_process_itr_fft2d[20] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[19] | ctrlOr_ln359_0_z | 
      ctrlAnd_1_ln368_z | ctrlAnd_1_ln360_z | ctrlAnd_1_ln351_z | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[21] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17];
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln368_z: mux_w_ln367_64_d_0 = mux_w_ln367_z[111:64];
        mux_w_ln367_sel: mux_w_ln367_64_d_0 = mux_w_ln367_q[111:64];
        default: mux_w_ln367_64_d_0 = 48'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln368_z: mux_w_ln367_d = mux_w_ln367_z[63:0];
        mux_w_ln367_sel: mux_w_ln367_d = mux_w_ln367_q[63:0];
        default: mux_w_ln367_d = 64'hX;
      endcase
      read_fft2d_sig_size_ln309_sel = 
      state_fft2d_unisim_fft2d_process_itr_fft2d[20] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[19] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[5] | ctrlOr_ln441_z | 
      ctrlOr_ln438_z | ctrlOr_ln434_z | ctrlOr_ln359_0_z | ctrlOr_ln350_0_z | 
      ctrlOr_ln335_z | ctrlOr_ln328_z | ctrlAnd_1_ln368_z | ctrlAnd_1_ln360_z | 
      ctrlAnd_1_ln351_z | ctrlAnd_1_ln328_z | ctrlAnd_1_ln315_z | 
      ctrlAnd_0_ln335_z | state_fft2d_unisim_fft2d_process_itr_fft2d[21] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[18] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[6] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[4];
      A0_bridge1_rtl_CE_en = memwrite_fft2d_A0_ln418_en | 
      memwrite_fft2d_A0_ln416_en | ctrlAnd_1_ln368_z | ctrlAnd_0_ln335_z | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[17] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[7] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[6] | 
      state_fft2d_unisim_fft2d_process_itr_fft2d[4];
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln359_0_z: mux_k_ln359_d = {add_ln359_z, mux_k_ln359_z[12:0]};
        mux_k_ln359_sel: mux_k_ln359_d = {add_ln359_q, mux_k_ln359_q};
        default: mux_k_ln359_d = 45'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln350_0_z: mux_s_ln350_d_0 = {mux_mySin_ln61_z[9:0], 
          mux_myCos_ln41_z, eq_ln408_z, add_ln350_z[3:1], lsh_ln354_z, 
          mux_s_ln350_z[0]};
        mux_s_ln350_mux_0_sel: mux_s_ln350_d_0 = {mux_mySin_ln61_q[9:0], 
          mux_myCos_ln41_q, eq_ln408_Z_0_tag_0, add_ln350_1_q, lsh_ln354_q, 
          mux_s_ln350_q};
        default: mux_s_ln350_d_0 = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln350_0_z: mux_mySin_ln61_10_d_0 = mux_mySin_ln61_z[33:10];
        mux_s_ln350_mux_0_sel: mux_mySin_ln61_10_d_0 = mux_mySin_ln61_q[33:10];
        default: mux_mySin_ln61_10_d_0 = 24'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln315_z: read_fft2d_sig_size_ln309_d = {
          mux_read_fft2d_sig_log2_ln310_Z_0_mux_0_v, 
          mux_read_fft2d_sig_size_ln309_Z_0_mux_0_v};
        read_fft2d_sig_size_ln309_sel: read_fft2d_sig_size_ln309_d = {
          read_fft2d_sig_log2_ln310_q, read_fft2d_sig_size_ln309_q};
        default: read_fft2d_sig_size_ln309_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln315_z: add_ln325_1_d = mux_add_ln325_Z_1_mux_0_v;
        read_fft2d_sig_size_ln309_sel: add_ln325_1_d = add_ln325_1_q;
        default: add_ln325_1_d = 4'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_process_itr_fft2d[0]: // Wait_ln304
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln304_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [0] = 1'b1;
              ctrlOr_ln315_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[1] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[1]: // Wait_ln315
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln315_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[1] = 
                1'b1;
              ctrlAnd_1_ln315_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [2] = 1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[2]: // expand_ln328
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[3] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[3]: // expand_ln328_0
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln335_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [4] = 1'b1;
              ctrlOr_ln335_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[8] = 
                1'b1;
              ctrlAnd_1_ln328_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [9] = 1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[4]: // Wait_ln337
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[5] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[5]: // expand_ln339
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[6] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[6]: // Wait_ln339
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[7] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[7]: // Wait_ln341
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[8] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[8]: // Wait_ln344
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[3] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[9]: // expand_ln350_0
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[10] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[10]: // expand_ln350
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln434_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[11] = 
                1'b1;
              ctrlAnd_1_ln351_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [14] = 1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[11]: // Wait_ln434
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln434_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[11] = 
                1'b1;
              ctrlOr_ln438_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[12] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[12]: // Wait_ln438
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln438_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[12] = 
                1'b1;
              ctrlOr_ln441_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[13] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[13]: // Wait_ln441
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln441_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[13] = 
                1'b1;
              ctrlOr_ln315_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[1] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[14]: // expand_ln359_0
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[15] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[15]: // expand_ln359
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln350_0_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[
                10] = 1'b1;
              ctrlAnd_1_ln360_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [16] = 1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[16]: // expand_ln367
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln359_0_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[
                15] = 1'b1;
              ctrlAnd_1_ln368_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [17] = 1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_process_itr_fft2d[17]: // Wait_ln380
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[18] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[18]: // Wait_ln382
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[19] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[19]: // expand_ln382_0
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[20] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[20]: // expand_ln382
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[21] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[21]: // Wait_ln410
          state_fft2d_unisim_fft2d_process_itr_fft2d_next[22] = 1'b1;
        state_fft2d_unisim_fft2d_process_itr_fft2d[22]: // Wait_ln412
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln359_0_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next[
                15] = 1'b1;
              ctrlAnd_1_ln368_z: state_fft2d_unisim_fft2d_process_itr_fft2d_next
                [17] = 1'b1;
              default: state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
            endcase
          end
        default: // Don't care
          state_fft2d_unisim_fft2d_process_itr_fft2d_next = 23'hX;
      endcase
    end
  fft2d_unisim_identity_sync_read_8192x64m0 B0_bridge1(.rtl_CE(
                                            B0_bridge1_rtl_CE_en), .rtl_A(
                                            B0_bridge1_rtl_a), .mem_Q(B0_Q1), .CLK(
                                            clk), .mem_CE(B0_CE1), .mem_A(B0_A1), 
                                            .rtl_Q(B0_bridge1_rtl_Q));
  // synthesis sync_set_reset_local fft2d_unisim_fft2d_store_output_seq_block rst
  always @(posedge clk) // fft2d_unisim_fft2d_store_output_sequential
    begin : fft2d_unisim_fft2d_store_output_seq_block
      if (!rst) // Initialize state and outputs
      begin
        wr_length <= 32'sh0;
        wr_index <= 32'sh0;
        wr_request <= 1'sb0;
        memread_fft2d_B0_ln256_q <= 64'sh0;
        memread_fft2d_B0_ln278_q <= 64'sh0;
        add_ln271_q <= 31'sh0;
        mux_rows_ln223_0_q <= 1'sb0;
        mux_base_ln223_q <= 31'sh0;
        mux_s_ln223_q <= 32'sh0;
        bufdout_set_valid_curr <= 1'sb0;
        bufdout_data <= 32'sh0;
        mux_i_0_ln264_q <= 13'sh0;
        add_ln264_1_q <= 13'sh0;
        mux_i_ln252_q <= 1'sb0;
        add_ln252_1_q <= 13'sh0;
        mul_ln241_q <= 31'sh0;
        output_ack <= 1'sb0;
        fft2d_done <= 1'sb0;
        read_fft2d_sig_size_ln209_q <= 32'sh0;
        read_fft2d_sig_transpose_ln211_Z_0_tag_0 <= 1'sb0;
        read_fft2d_sig_batch_ln210_q <= 32'sh0;
        mux_base_ln220_q <= 31'sh0;
        mux_rows_ln220_q <= 1'sb0;
        mux_s_ln220_q <= 31'sh0;
        add_ln292_1_q <= 31'sh0;
        state_fft2d_unisim_fft2d_store_output <= 16'h1;
      end
      else // Update Q values
      begin
        wr_length <= wr_length_d;
        wr_index <= wr_index_d;
        wr_request <= wr_request_d;
        memread_fft2d_B0_ln256_q <= {memread_fft2d_B0_ln256_32_d_0, 
        mux_memread_fft2d_B0_ln256_Q_v[31:0]};
        memread_fft2d_B0_ln278_q <= {memread_fft2d_B0_ln278_32_d_0, 
        mux_memread_fft2d_B0_ln278_Q_v[31:0]};
        add_ln271_q <= add_ln271_z;
        mux_rows_ln223_0_q <= mux_rows_ln223_0_z;
        mux_base_ln223_q <= mux_base_ln223_z;
        mux_s_ln223_q <= mux_s_ln223_z;
        bufdout_set_valid_curr <= bufdout_set_valid_curr_d;
        bufdout_data <= bufdout_data_d;
        mux_i_0_ln264_q <= {mux_i_0_ln264_1_d_0, mux_i_0_ln264_d[0]};
        add_ln264_1_q <= mux_i_0_ln264_d[13:1];
        mux_i_ln252_q <= mux_i_ln252_d_0[0];
        add_ln252_1_q <= mux_i_ln252_d_0[13:1];
        mul_ln241_q <= mul_ln241_d;
        output_ack <= output_ack_d;
        fft2d_done <= fft2d_done_d;
        read_fft2d_sig_size_ln209_q <= {read_fft2d_sig_size_ln209_31_d_0[0], 
        read_fft2d_sig_size_ln209_d};
        read_fft2d_sig_transpose_ln211_Z_0_tag_0 <= 
        read_fft2d_sig_size_ln209_31_d_0[33];
        read_fft2d_sig_batch_ln210_q <= read_fft2d_sig_size_ln209_31_d_0[32:1];
        mux_base_ln220_q <= mux_base_ln220_d[30:0];
        mux_rows_ln220_q <= mux_base_ln220_d[31];
        mux_s_ln220_q <= {mux_s_ln220_1_d_0, mux_base_ln220_d[32]};
        add_ln292_1_q <= mux_base_ln220_d[63:33];
        state_fft2d_unisim_fft2d_store_output <= 
        state_fft2d_unisim_fft2d_store_output_next;
      end
    end
  always @(*) begin : fft2d_unisim_fft2d_store_output_combinational
      reg STORE_SINGLE_LOOP_for_exit_0_or_0;
      reg unary_nor_ln95_z;
      reg unary_nor_ln95_0_z;
      reg unary_nor_ln95_1_z;
      reg unary_nor_ln95_2_z;
      reg ctrlOr_ln272_z;
      reg ctrlOr_ln272_0_z;
      reg ctrlOr_ln272_1_z;
      reg ctrlOr_ln272_2_z;
      reg [30:0] mul_ln217_z;
      reg wr_index_hold;
      reg wr_request_sel;
      reg mux_rows_ln222_z;
      reg [30:0] mux_base_ln222_z;
      reg ctrlAnd_1_ln205_z;
      reg ctrlAnd_0_ln205_z;
      reg ctrlAnd_1_ln235_z;
      reg ctrlAnd_0_ln235_z;
      reg ctrlAnd_1_ln248_z;
      reg ctrlAnd_0_ln248_z;
      reg memread_fft2d_B0_ln256_32_mux_0_sel;
      reg memread_fft2d_B0_ln278_32_mux_0_sel;
      reg ctrlAnd_1_ln275_z;
      reg ctrlAnd_0_ln275_z;
      reg ctrlAnd_1_ln287_z;
      reg ctrlAnd_0_ln287_z;
      reg [31:0] mux_read_fft2d_sig_batch_ln210_Z_v;
      reg [31:0] mux_read_fft2d_sig_size_ln209_Z_v;
      reg mux_read_fft2d_sig_transpose_ln211_Z_0_v;
      reg mux_if_ln223_Z_0_v;
      reg [30:0] mux_base_ln215_z;
      reg [13:0] mux_i_0_ln264_z;
      reg [13:0] mux_i_ln252_z;
      reg [31:0] mux_s_ln222_z;
      reg [30:0] mux_read_fft2d_sig_size_ln209_Z_0_mux_1_v;
      reg mux_rows_ln220_z;
      reg ctrlAnd_1_ln240_z;
      reg ctrlAnd_0_ln240_z;
      reg ctrlOr_ln248_z;
      reg wr_request_hold;
      reg wr_request_sel_0;
      reg ctrlOr_ln275_z;
      reg ctrlOr_ln222_z;
      reg [31:0] mux_read_fft2d_sig_batch_ln210_Z_0_mux_0_v;
      reg [31:0] mux_read_fft2d_sig_size_ln209_Z_0_mux_0_v;
      reg mux_read_fft2d_sig_transpose_ln211_Z_0_v_0;
      reg [30:0] mux_base_ln220_z;
      reg eq_ln265_z;
      reg lt_ln264_z;
      reg [30:0] mul_ln268_z;
      reg [13:0] add_ln264_z;
      reg [13:0] add_ln252_z;
      reg eq_ln253_z;
      reg lt_ln252_z;
      reg [31:0] mux_s_ln220_z;
      reg [30:0] mux_read_fft2d_sig_size_ln209_Z_0_mux_2_v;
      reg ternaryMux_ln223_0_z;
      reg mux_mux_rows_ln220_Z_0_v;
      reg ctrlOr_ln220_z;
      reg ctrlAnd_1_ln272_0_z;
      reg ctrlAnd_0_ln272_0_z;
      reg ctrlAnd_1_ln272_1_z;
      reg ctrlAnd_0_ln272_1_z;
      reg ctrlAnd_1_ln272_2_z;
      reg ctrlAnd_0_ln272_2_z;
      reg ctrlAnd_1_ln272_z;
      reg ctrlAnd_0_ln272_z;
      reg [30:0] mux_mux_base_ln220_Z_v;
      reg or_and_0_ln265_Z_0_z;
      reg if_ln265_z;
      reg [30:0] add_ln268_z;
      reg or_and_0_ln253_Z_0_z;
      reg if_ln253_z;
      reg eq_ln222_z;
      reg [30:0] mux_mux_s_ln220_Z_v;
      reg [30:0] mul_ln241_z;
      reg [31:0] add_ln292_z;
      reg ctrlOr_ln252_0_z;
      reg write_fft2d_bufdout_data_ln274_0_en;
      reg mux_i_ln252_mux_0_sel;
      reg write_fft2d_bufdout_data_ln274_1_en;
      reg ctrlOr_ln264_0_z;
      reg write_fft2d_bufdout_data_ln274_2_en;
      reg mux_i_0_ln264_sel;
      reg bufdout_set_valid_curr_hold;
      reg write_fft2d_bufdout_data_ln274_en;
      reg and_1_ln265_z;
      reg and_1_ln253_z;
      reg [30:0] mux_mul_ln241_Z_v;
      reg [30:0] mux_add_ln292_Z_1_v_0;
      reg ctrlAnd_0_ln253_z;
      reg ctrlAnd_0_ln265_z;
      reg bufdout_data_hold;
      reg ctrlAnd_1_ln265_z;
      reg ctrlAnd_1_ln253_z;
      reg ctrlAnd_1_ln222_z;
      reg ctrlAnd_0_ln222_z;
      reg ctrlOr_ln240_z;
      reg mux_s_ln220_1_mux_0_sel;
      reg read_fft2d_sig_size_ln209_sel;
      reg ctrlOr_ln235_z;
      reg write_fft2d_fft2d_done_ln230_en;
      reg output_ack_hold;
      reg ctrlOr_ln287_z;
      reg read_fft2d_sig_size_ln209_31_mux_0_sel;

      state_fft2d_unisim_fft2d_store_output_next = 16'h0;
      STORE_SINGLE_LOOP_for_exit_0_or_0 = 
      state_fft2d_unisim_fft2d_store_output[9] | 
      state_fft2d_unisim_fft2d_store_output[8] | 
      state_fft2d_unisim_fft2d_store_output[4];
      unary_nor_ln95_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_0_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_1_z = ~bufdout_set_valid_curr;
      unary_nor_ln95_2_z = ~bufdout_set_valid_curr;
      ctrlOr_ln272_z = state_fft2d_unisim_fft2d_store_output[7] | 
      state_fft2d_unisim_fft2d_store_output[6];
      ctrlOr_ln272_0_z = state_fft2d_unisim_fft2d_store_output[9] | 
      state_fft2d_unisim_fft2d_store_output[8];
      ctrlOr_ln272_1_z = state_fft2d_unisim_fft2d_store_output[13] | 
      state_fft2d_unisim_fft2d_store_output[12];
      ctrlOr_ln272_2_z = state_fft2d_unisim_fft2d_store_output[15] | 
      state_fft2d_unisim_fft2d_store_output[14];
      mul_ln217_z = sig_size[30:0] * sig_size[30:0];
      wr_index_hold = ~(state_fft2d_unisim_fft2d_store_output[10] | 
      state_fft2d_unisim_fft2d_store_output[3]);
      wr_request_sel = state_fft2d_unisim_fft2d_store_output[10] | 
      state_fft2d_unisim_fft2d_store_output[3];
      if (state_fft2d_unisim_fft2d_store_output[12]) 
        mux_memread_fft2d_B0_ln278_Q_v = B0_bridge1_rtl_Q;
      else 
        mux_memread_fft2d_B0_ln278_Q_v = memread_fft2d_B0_ln278_q;
      if (state_fft2d_unisim_fft2d_store_output[6]) 
        mux_memread_fft2d_B0_ln256_Q_v = B0_bridge1_rtl_Q;
      else 
        mux_memread_fft2d_B0_ln256_Q_v = memread_fft2d_B0_ln256_q;
      if (state_fft2d_unisim_fft2d_store_output[1]) 
        mux_rows_ln222_z = mux_rows_ln223_0_q;
      else 
        mux_rows_ln222_z = mux_rows_ln220_q;
      if (state_fft2d_unisim_fft2d_store_output[1]) 
        mux_base_ln222_z = mux_base_ln223_q;
      else 
        mux_base_ln222_z = mux_base_ln220_q;
      ctrlAnd_1_ln205_z = init_done & state_fft2d_unisim_fft2d_store_output[0];
      ctrlAnd_0_ln205_z = !init_done & state_fft2d_unisim_fft2d_store_output[0];
      ctrlAnd_1_ln235_z = output_valid & 
      state_fft2d_unisim_fft2d_store_output[2];
      ctrlAnd_0_ln235_z = !output_valid & 
      state_fft2d_unisim_fft2d_store_output[2];
      ctrlAnd_1_ln248_z = wr_grant & state_fft2d_unisim_fft2d_store_output[4];
      ctrlAnd_0_ln248_z = !wr_grant & state_fft2d_unisim_fft2d_store_output[4];
      memread_fft2d_B0_ln256_32_mux_0_sel = ctrlOr_ln272_z;
      memread_fft2d_B0_ln278_32_mux_0_sel = ctrlOr_ln272_1_z;
      ctrlAnd_1_ln275_z = wr_grant & state_fft2d_unisim_fft2d_store_output[11];
      ctrlAnd_0_ln275_z = !wr_grant & state_fft2d_unisim_fft2d_store_output[11];
      ctrlAnd_1_ln287_z = !output_valid & 
      state_fft2d_unisim_fft2d_store_output[5];
      ctrlAnd_0_ln287_z = output_valid & 
      state_fft2d_unisim_fft2d_store_output[5];
      if (state_fft2d_unisim_fft2d_store_output[0]) 
        mux_read_fft2d_sig_batch_ln210_Z_v = sig_batch;
      else 
        mux_read_fft2d_sig_batch_ln210_Z_v = read_fft2d_sig_batch_ln210_q;
      if (state_fft2d_unisim_fft2d_store_output[0]) 
        mux_read_fft2d_sig_size_ln209_Z_v = sig_size;
      else 
        mux_read_fft2d_sig_size_ln209_Z_v = read_fft2d_sig_size_ln209_q;
      if (state_fft2d_unisim_fft2d_store_output[0]) 
        mux_read_fft2d_sig_transpose_ln211_Z_0_v = sig_transpose;
      else 
        mux_read_fft2d_sig_transpose_ln211_Z_0_v = 
        read_fft2d_sig_transpose_ln211_Z_0_tag_0;
      if (state_fft2d_unisim_fft2d_store_output[0]) 
        mux_if_ln223_Z_0_v = sig_transpose;
      else 
        mux_if_ln223_Z_0_v = read_fft2d_sig_transpose_ln211_Z_0_tag_0;
      if (sig_transpose) 
        mux_base_ln215_z = mul_ln217_z;
      else 
        mux_base_ln215_z = 31'h0;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_i_0_ln264_z = 14'h0;
      else 
        mux_i_0_ln264_z = {add_ln264_1_q, !mux_i_0_ln264_q[0]};
      if (state_fft2d_unisim_fft2d_store_output[4]) 
        mux_i_ln252_z = 14'h0;
      else 
        mux_i_ln252_z = {add_ln252_1_q, !mux_i_ln252_q};
      if (state_fft2d_unisim_fft2d_store_output[1]) 
        mux_s_ln222_z = mux_s_ln223_q;
      else 
        mux_s_ln222_z = {add_ln292_1_q, !mux_s_ln220_q[0]};
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_store_output[3]: wr_length_d = {
          read_fft2d_sig_size_ln209_q[30:0], 1'b0};
        state_fft2d_unisim_fft2d_store_output[10]: wr_length_d = 32'h2;
        wr_index_hold: wr_length_d = wr_length;
        default: wr_length_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_store_output[3]: wr_index_d = {mul_ln241_q, 
          1'b0};
        state_fft2d_unisim_fft2d_store_output[10]: wr_index_d = {add_ln271_q, 
          1'b0};
        wr_index_hold: wr_index_d = wr_index;
        default: wr_index_d = 32'hX;
      endcase
      if (STORE_SINGLE_LOOP_for_exit_0_or_0) 
        mux_read_fft2d_sig_size_ln209_Z_0_mux_1_v = wr_length[31:1];
      else 
        mux_read_fft2d_sig_size_ln209_Z_0_mux_1_v = read_fft2d_sig_size_ln209_q[
        30:0];
      if (state_fft2d_unisim_fft2d_store_output[0]) 
        mux_rows_ln220_z = 1'b1;
      else 
        mux_rows_ln220_z = mux_rows_ln222_z;
      ctrlAnd_1_ln240_z = read_fft2d_sig_transpose_ln211_Z_0_tag_0 & 
      ctrlAnd_1_ln235_z;
      ctrlAnd_0_ln240_z = !read_fft2d_sig_transpose_ln211_Z_0_tag_0 & 
      ctrlAnd_1_ln235_z;
      ctrlOr_ln248_z = ctrlAnd_0_ln248_z | 
      state_fft2d_unisim_fft2d_store_output[3];
      wr_request_hold = ~(ctrlAnd_1_ln275_z | ctrlAnd_1_ln248_z | 
      state_fft2d_unisim_fft2d_store_output[10] | 
      state_fft2d_unisim_fft2d_store_output[3]);
      wr_request_sel_0 = ctrlAnd_1_ln275_z | ctrlAnd_1_ln248_z;
      ctrlOr_ln275_z = ctrlAnd_0_ln275_z | 
      state_fft2d_unisim_fft2d_store_output[10];
      ctrlOr_ln222_z = ctrlAnd_1_ln287_z | 
      state_fft2d_unisim_fft2d_store_output[1];
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_read_fft2d_sig_batch_ln210_Z_0_mux_0_v = 
        read_fft2d_sig_batch_ln210_q;
      else 
        mux_read_fft2d_sig_batch_ln210_Z_0_mux_0_v = 
        mux_read_fft2d_sig_batch_ln210_Z_v;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_read_fft2d_sig_size_ln209_Z_0_mux_0_v = read_fft2d_sig_size_ln209_q;
      else 
        mux_read_fft2d_sig_size_ln209_Z_0_mux_0_v = 
        mux_read_fft2d_sig_size_ln209_Z_v;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_read_fft2d_sig_transpose_ln211_Z_0_v_0 = 
        read_fft2d_sig_transpose_ln211_Z_0_tag_0;
      else 
        mux_read_fft2d_sig_transpose_ln211_Z_0_v_0 = 
        mux_read_fft2d_sig_transpose_ln211_Z_0_v;
      if (state_fft2d_unisim_fft2d_store_output[0]) 
        mux_base_ln220_z = mux_base_ln215_z;
      else 
        mux_base_ln220_z = mux_base_ln222_z;
      eq_ln265_z = {18'h0, mux_i_0_ln264_z} == read_fft2d_sig_size_ln209_q;
      lt_ln264_z = ~mux_i_0_ln264_z[13];
      mul_ln268_z = read_fft2d_sig_size_ln209_q[30:0] * mux_i_0_ln264_z;
      add_ln264_z = {1'b0, mux_i_0_ln264_z[12:0]} + 14'h1;
      add_ln252_z = {1'b0, mux_i_ln252_z[12:0]} + 14'h1;
      eq_ln253_z = {18'h0, mux_i_ln252_z} == {read_fft2d_sig_size_ln209_q[31], 
      wr_length[31:1]};
      lt_ln252_z = ~mux_i_ln252_z[13];
      if (state_fft2d_unisim_fft2d_store_output[11]) 
        B0_bridge1_rtl_a = mux_i_0_ln264_q;
      else 
        B0_bridge1_rtl_a = mux_i_ln252_z[12:0];
      if (state_fft2d_unisim_fft2d_store_output[0]) 
        mux_s_ln220_z = 32'h0;
      else 
        mux_s_ln220_z = mux_s_ln222_z;
      if (state_fft2d_unisim_fft2d_store_output[5]) 
        mux_read_fft2d_sig_size_ln209_Z_0_mux_2_v = read_fft2d_sig_size_ln209_q[
        30:0];
      else 
        mux_read_fft2d_sig_size_ln209_Z_0_mux_2_v = 
        mux_read_fft2d_sig_size_ln209_Z_0_mux_1_v;
      ternaryMux_ln223_0_z = mux_if_ln223_Z_0_v & mux_rows_ln220_z;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_mux_rows_ln220_Z_0_v = mux_rows_ln220_q;
      else 
        mux_mux_rows_ln220_Z_0_v = mux_rows_ln220_z;
      case (1'b1)// synthesis parallel_case
        wr_request_sel: wr_request_d = 1'b1;
        wr_request_sel_0: wr_request_d = 1'b0;
        wr_request_hold: wr_request_d = wr_request;
        default: wr_request_d = 1'bX;
      endcase
      ctrlOr_ln220_z = ctrlOr_ln222_z | ctrlAnd_1_ln205_z;
      ctrlAnd_1_ln272_0_z = bufdout_can_put_sig & ctrlOr_ln272_0_z;
      ctrlAnd_0_ln272_0_z = !bufdout_can_put_sig & ctrlOr_ln272_0_z;
      ctrlAnd_1_ln272_1_z = bufdout_can_put_sig & ctrlOr_ln272_1_z;
      ctrlAnd_0_ln272_1_z = !bufdout_can_put_sig & ctrlOr_ln272_1_z;
      ctrlAnd_1_ln272_2_z = bufdout_can_put_sig & ctrlOr_ln272_2_z;
      ctrlAnd_0_ln272_2_z = !bufdout_can_put_sig & ctrlOr_ln272_2_z;
      ctrlAnd_1_ln272_z = bufdout_can_put_sig & ctrlOr_ln272_z;
      ctrlAnd_0_ln272_z = !bufdout_can_put_sig & ctrlOr_ln272_z;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_mux_base_ln220_Z_v = mux_base_ln220_q;
      else 
        mux_mux_base_ln220_Z_v = mux_base_ln220_z;
      or_and_0_ln265_Z_0_z = mux_i_0_ln264_z[13] | eq_ln265_z;
      if_ln265_z = ~eq_ln265_z;
      add_ln268_z = mul_ln268_z + mux_s_ln220_q;
      or_and_0_ln253_Z_0_z = mux_i_ln252_z[13] | eq_ln253_z;
      if_ln253_z = ~eq_ln253_z;
      eq_ln222_z = mux_s_ln220_z == mux_read_fft2d_sig_batch_ln210_Z_v;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_mux_s_ln220_Z_v = mux_s_ln220_q;
      else 
        mux_mux_s_ln220_Z_v = mux_s_ln220_z[30:0];
      mul_ln241_z = mux_s_ln220_z[30:0] * mux_read_fft2d_sig_size_ln209_Z_v[30:0];
      add_ln292_z = mux_s_ln220_z + 32'h1;
      ctrlOr_ln252_0_z = ctrlAnd_1_ln272_0_z | ctrlAnd_1_ln248_z;
      write_fft2d_bufdout_data_ln274_0_en = rst & ctrlAnd_1_ln272_0_z;
      case (1'b1)// synthesis parallel_case
        memread_fft2d_B0_ln256_32_mux_0_sel: memread_fft2d_B0_ln256_32_d_0 = 
          mux_memread_fft2d_B0_ln256_Q_v[63:32];
        ctrlAnd_0_ln272_0_z: memread_fft2d_B0_ln256_32_d_0 = 
          memread_fft2d_B0_ln256_q[63:32];
        default: memread_fft2d_B0_ln256_32_d_0 = 32'hX;
      endcase
      mux_i_ln252_mux_0_sel = ctrlOr_ln272_z | ctrlAnd_0_ln272_0_z;
      write_fft2d_bufdout_data_ln274_1_en = rst & ctrlAnd_1_ln272_1_z;
      ctrlOr_ln264_0_z = ctrlAnd_1_ln272_2_z | ctrlAnd_1_ln240_z;
      write_fft2d_bufdout_data_ln274_2_en = rst & ctrlAnd_1_ln272_2_z;
      case (1'b1)// synthesis parallel_case
        memread_fft2d_B0_ln278_32_mux_0_sel: memread_fft2d_B0_ln278_32_d_0 = 
          mux_memread_fft2d_B0_ln278_Q_v[63:32];
        ctrlAnd_0_ln272_2_z: memread_fft2d_B0_ln278_32_d_0 = 
          memread_fft2d_B0_ln278_q[63:32];
        default: memread_fft2d_B0_ln278_32_d_0 = 32'hX;
      endcase
      mux_i_0_ln264_sel = ctrlOr_ln275_z | ctrlOr_ln272_1_z | ctrlAnd_1_ln275_z | 
      ctrlAnd_0_ln272_2_z;
      bufdout_set_valid_curr_hold = ~(ctrlAnd_1_ln272_z | ctrlAnd_1_ln272_2_z | 
      ctrlAnd_1_ln272_1_z | ctrlAnd_1_ln272_0_z);
      write_fft2d_bufdout_data_ln274_en = rst & ctrlAnd_1_ln272_z;
      and_1_ln265_z = if_ln265_z & lt_ln264_z;
      add_ln271_z = mux_base_ln220_q + add_ln268_z;
      and_1_ln253_z = if_ln253_z & lt_ln252_z;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_mul_ln241_Z_v = mul_ln241_q;
      else 
        mux_mul_ln241_Z_v = mul_ln241_z;
      if (state_fft2d_unisim_fft2d_store_output[2]) 
        mux_add_ln292_Z_1_v_0 = add_ln292_1_q;
      else 
        mux_add_ln292_Z_1_v_0 = add_ln292_z[31:1];
      mux_rows_ln223_0_z = !ternaryMux_ln223_0_z & mux_rows_ln220_z;
      if (ternaryMux_ln223_0_z) begin
        mux_s_ln223_z = 32'h0;
        mux_base_ln223_z = 31'h0;
      end
      else begin
        mux_s_ln223_z = mux_s_ln220_z;
        mux_base_ln223_z = mux_base_ln220_z;
      end
      ctrlAnd_0_ln253_z = or_and_0_ln253_Z_0_z & ctrlOr_ln252_0_z;
      ctrlAnd_0_ln265_z = or_and_0_ln265_Z_0_z & ctrlOr_ln264_0_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln272_z: bufdout_set_valid_curr_d = unary_nor_ln95_z;
        ctrlAnd_1_ln272_0_z: bufdout_set_valid_curr_d = unary_nor_ln95_0_z;
        ctrlAnd_1_ln272_1_z: bufdout_set_valid_curr_d = unary_nor_ln95_1_z;
        ctrlAnd_1_ln272_2_z: bufdout_set_valid_curr_d = unary_nor_ln95_2_z;
        bufdout_set_valid_curr_hold: bufdout_set_valid_curr_d = 
          bufdout_set_valid_curr;
        default: bufdout_set_valid_curr_d = 1'bX;
      endcase
      bufdout_data_hold = ~(write_fft2d_bufdout_data_ln274_en | 
      write_fft2d_bufdout_data_ln274_2_en | write_fft2d_bufdout_data_ln274_1_en | 
      write_fft2d_bufdout_data_ln274_0_en);
      ctrlAnd_1_ln265_z = and_1_ln265_z & ctrlOr_ln264_0_z;
      ctrlAnd_1_ln253_z = and_1_ln253_z & ctrlOr_ln252_0_z;
      ctrlAnd_1_ln222_z = !eq_ln222_z & ctrlOr_ln220_z;
      ctrlAnd_0_ln222_z = eq_ln222_z & ctrlOr_ln220_z;
      ctrlOr_ln240_z = ctrlAnd_0_ln265_z | ctrlAnd_0_ln253_z;
      case (1'b1)// synthesis parallel_case
        write_fft2d_bufdout_data_ln274_en: bufdout_data_d = 
          mux_memread_fft2d_B0_ln256_Q_v[31:0];
        write_fft2d_bufdout_data_ln274_0_en: bufdout_data_d = 
          memread_fft2d_B0_ln256_q[63:32];
        write_fft2d_bufdout_data_ln274_1_en: bufdout_data_d = 
          mux_memread_fft2d_B0_ln278_Q_v[31:0];
        write_fft2d_bufdout_data_ln274_2_en: bufdout_data_d = 
          memread_fft2d_B0_ln278_q[63:32];
        bufdout_data_hold: bufdout_data_d = bufdout_data;
        default: bufdout_data_d = 32'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln265_z: mux_i_0_ln264_1_d_0 = mux_i_0_ln264_z[12:1];
        ctrlOr_ln275_z: mux_i_0_ln264_1_d_0 = mux_i_0_ln264_q[12:1];
        default: mux_i_0_ln264_1_d_0 = 12'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln265_z: mux_i_0_ln264_d = {add_ln264_z[13:1], mux_i_0_ln264_z
          [0]};
        mux_i_0_ln264_sel: mux_i_0_ln264_d = {add_ln264_1_q, mux_i_0_ln264_q[0]};
        default: mux_i_0_ln264_d = 14'hX;
      endcase
      mux_s_ln220_1_mux_0_sel = ctrlOr_ln275_z | ctrlOr_ln272_1_z | 
      ctrlAnd_1_ln275_z | ctrlAnd_1_ln265_z | ctrlAnd_0_ln272_2_z;
      read_fft2d_sig_size_ln209_sel = ctrlOr_ln275_z | ctrlOr_ln272_1_z | 
      ctrlAnd_1_ln275_z | ctrlAnd_1_ln265_z | ctrlAnd_0_ln272_2_z | 
      ctrlAnd_0_ln240_z;
      case (1'b1)// synthesis parallel_case
        ctrlAnd_1_ln253_z: mux_i_ln252_d_0 = {add_ln252_z[13:1], mux_i_ln252_z[0]};
        mux_i_ln252_mux_0_sel: mux_i_ln252_d_0 = {add_ln252_1_q, mux_i_ln252_q};
        default: mux_i_ln252_d_0 = 14'hX;
      endcase
      B0_bridge1_rtl_CE_en = ctrlAnd_1_ln275_z | ctrlAnd_1_ln253_z;
      ctrlOr_ln235_z = ctrlAnd_0_ln235_z | ctrlAnd_1_ln222_z;
      write_fft2d_fft2d_done_ln230_en = !ternaryMux_ln223_0_z & 
      ctrlAnd_0_ln222_z;
      output_ack_hold = ~(ctrlOr_ln240_z | ctrlAnd_1_ln287_z);
      ctrlOr_ln287_z = ctrlAnd_0_ln287_z | ctrlOr_ln240_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln235_z: mul_ln241_d = mux_mul_ln241_Z_v;
        ctrlAnd_0_ln240_z: mul_ln241_d = mul_ln241_q;
        default: mul_ln241_d = 31'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln235_z: mux_s_ln220_1_d_0 = mux_mux_s_ln220_Z_v[30:1];
        mux_s_ln220_1_mux_0_sel: mux_s_ln220_1_d_0 = mux_s_ln220_q[30:1];
        default: mux_s_ln220_1_d_0 = 30'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln240_z: output_ack_d = 1'b1;
        ctrlAnd_1_ln287_z: output_ack_d = 1'b0;
        output_ack_hold: output_ack_d = output_ack;
        default: output_ack_d = 1'bX;
      endcase
      read_fft2d_sig_size_ln209_31_mux_0_sel = ctrlOr_ln287_z | ctrlOr_ln275_z | 
      ctrlOr_ln272_z | ctrlOr_ln272_1_z | ctrlOr_ln248_z | ctrlAnd_1_ln275_z | 
      ctrlAnd_1_ln265_z | ctrlAnd_1_ln253_z | ctrlAnd_0_ln272_2_z | 
      ctrlAnd_0_ln272_0_z | ctrlAnd_0_ln240_z;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln235_z: read_fft2d_sig_size_ln209_d = 
          mux_read_fft2d_sig_size_ln209_Z_0_mux_0_v[30:0];
        read_fft2d_sig_size_ln209_sel: read_fft2d_sig_size_ln209_d = 
          read_fft2d_sig_size_ln209_q[30:0];
        ctrlOr_ln287_z: read_fft2d_sig_size_ln209_d = 
          mux_read_fft2d_sig_size_ln209_Z_0_mux_2_v;
        ctrlAnd_0_ln222_z: read_fft2d_sig_size_ln209_d = 
          mux_read_fft2d_sig_size_ln209_Z_v[30:0];
        default: read_fft2d_sig_size_ln209_d = 31'hX;
      endcase
      if (write_fft2d_fft2d_done_ln230_en) 
        fft2d_done_d = 1'b1;
      else 
        fft2d_done_d = fft2d_done;
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln235_z: read_fft2d_sig_size_ln209_31_d_0 = {
          mux_read_fft2d_sig_transpose_ln211_Z_0_v_0, 
          mux_read_fft2d_sig_batch_ln210_Z_0_mux_0_v, 
          mux_read_fft2d_sig_size_ln209_Z_0_mux_0_v[31]};
        read_fft2d_sig_size_ln209_31_mux_0_sel: read_fft2d_sig_size_ln209_31_d_0 = 
          {read_fft2d_sig_transpose_ln211_Z_0_tag_0, 
          read_fft2d_sig_batch_ln210_q, read_fft2d_sig_size_ln209_q[31]};
        ctrlAnd_0_ln222_z: read_fft2d_sig_size_ln209_31_d_0 = {
          mux_read_fft2d_sig_transpose_ln211_Z_0_v, 
          mux_read_fft2d_sig_batch_ln210_Z_v, mux_read_fft2d_sig_size_ln209_Z_v[
          31]};
        default: read_fft2d_sig_size_ln209_31_d_0 = 34'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        ctrlOr_ln235_z: mux_base_ln220_d = {mux_add_ln292_Z_1_v_0, 
          mux_mux_s_ln220_Z_v[0], mux_mux_rows_ln220_Z_0_v, 
          mux_mux_base_ln220_Z_v};
        read_fft2d_sig_size_ln209_31_mux_0_sel: mux_base_ln220_d = {
          add_ln292_1_q, mux_s_ln220_q[0], mux_rows_ln220_q, mux_base_ln220_q};
        default: mux_base_ln220_d = 64'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        state_fft2d_unisim_fft2d_store_output[0]: // Wait_ln205
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln205_z: state_fft2d_unisim_fft2d_store_output_next[0] = 
                1'b1;
              ctrlAnd_0_ln222_z: state_fft2d_unisim_fft2d_store_output_next[1] = 
                1'b1;
              ctrlOr_ln235_z: state_fft2d_unisim_fft2d_store_output_next[2] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[1]: // Wait_ln227
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln222_z: state_fft2d_unisim_fft2d_store_output_next[1] = 
                1'b1;
              ctrlOr_ln235_z: state_fft2d_unisim_fft2d_store_output_next[2] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[2]: // Wait_ln235
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln235_z: state_fft2d_unisim_fft2d_store_output_next[2] = 
                1'b1;
              ctrlAnd_0_ln240_z: state_fft2d_unisim_fft2d_store_output_next[3] = 
                1'b1;
              ctrlOr_ln287_z: state_fft2d_unisim_fft2d_store_output_next[5] = 
                1'b1;
              ctrlAnd_1_ln265_z: state_fft2d_unisim_fft2d_store_output_next[10] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[3]: // Wait_ln242
          state_fft2d_unisim_fft2d_store_output_next[4] = 1'b1;
        state_fft2d_unisim_fft2d_store_output[4]: // Wait_ln248
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln248_z: state_fft2d_unisim_fft2d_store_output_next[4] = 
                1'b1;
              ctrlOr_ln287_z: state_fft2d_unisim_fft2d_store_output_next[5] = 
                1'b1;
              ctrlAnd_1_ln253_z: state_fft2d_unisim_fft2d_store_output_next[6] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[5]: // Wait_ln287
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln287_z: state_fft2d_unisim_fft2d_store_output_next[5] = 
                1'b1;
              ctrlAnd_0_ln222_z: state_fft2d_unisim_fft2d_store_output_next[1] = 
                1'b1;
              ctrlOr_ln235_z: state_fft2d_unisim_fft2d_store_output_next[2] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[6]: // Wait_ln258
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_z: state_fft2d_unisim_fft2d_store_output_next[7] = 
                1'b1;
              ctrlAnd_1_ln272_z: state_fft2d_unisim_fft2d_store_output_next[8] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[7]: // Wait_ln272
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_z: state_fft2d_unisim_fft2d_store_output_next[7] = 
                1'b1;
              ctrlAnd_1_ln272_z: state_fft2d_unisim_fft2d_store_output_next[8] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[8]: // Wait_ln260
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_0_z: state_fft2d_unisim_fft2d_store_output_next[9] = 
                1'b1;
              ctrlOr_ln287_z: state_fft2d_unisim_fft2d_store_output_next[5] = 
                1'b1;
              ctrlAnd_1_ln253_z: state_fft2d_unisim_fft2d_store_output_next[6] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[9]: // Wait_ln272_0
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_0_z: state_fft2d_unisim_fft2d_store_output_next[9] = 
                1'b1;
              ctrlOr_ln287_z: state_fft2d_unisim_fft2d_store_output_next[5] = 
                1'b1;
              ctrlAnd_1_ln253_z: state_fft2d_unisim_fft2d_store_output_next[6] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[10]: // Wait_ln269
          state_fft2d_unisim_fft2d_store_output_next[11] = 1'b1;
        state_fft2d_unisim_fft2d_store_output[11]: // Wait_ln275
          begin
            case (1'b1)// synthesis parallel_case
              ctrlOr_ln275_z: state_fft2d_unisim_fft2d_store_output_next[11] = 
                1'b1;
              ctrlAnd_1_ln275_z: state_fft2d_unisim_fft2d_store_output_next[12] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[12]: // Wait_ln280
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_1_z: state_fft2d_unisim_fft2d_store_output_next[13] = 
                1'b1;
              ctrlAnd_1_ln272_1_z: state_fft2d_unisim_fft2d_store_output_next[14] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[13]: // Wait_ln272_1
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_1_z: state_fft2d_unisim_fft2d_store_output_next[13] = 
                1'b1;
              ctrlAnd_1_ln272_1_z: state_fft2d_unisim_fft2d_store_output_next[14] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[14]: // Wait_ln282
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_2_z: state_fft2d_unisim_fft2d_store_output_next[15] = 
                1'b1;
              ctrlOr_ln287_z: state_fft2d_unisim_fft2d_store_output_next[5] = 
                1'b1;
              ctrlAnd_1_ln265_z: state_fft2d_unisim_fft2d_store_output_next[10] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        state_fft2d_unisim_fft2d_store_output[15]: // Wait_ln272_2
          begin
            case (1'b1)// synthesis parallel_case
              ctrlAnd_0_ln272_2_z: state_fft2d_unisim_fft2d_store_output_next[15] = 
                1'b1;
              ctrlOr_ln287_z: state_fft2d_unisim_fft2d_store_output_next[5] = 
                1'b1;
              ctrlAnd_1_ln265_z: state_fft2d_unisim_fft2d_store_output_next[10] = 
                1'b1;
              default: state_fft2d_unisim_fft2d_store_output_next = 16'hX;
            endcase
          end
        default: // Don't care
          state_fft2d_unisim_fft2d_store_output_next = 16'hX;
      endcase
    end
endmodule


module fft2d_unisim_fft2d_bufdin_can_get_mod_process(bufdin_valid, bufdin_ready, 
bufdin_can_get_sig);
  input bufdin_valid;
  input bufdin_ready;
  output reg bufdin_can_get_sig;

  always @(*) begin : fft2d_unisim_fft2d_bufdin_can_get_mod_process_combinational
      reg unary_nor_ln35_z;
      reg ternaryMux_ln35_0_z;

      unary_nor_ln35_z = ~bufdin_ready;
      ternaryMux_ln35_0_z = bufdin_valid | unary_nor_ln35_z;
      bufdin_can_get_sig = ternaryMux_ln35_0_z;
    end
endmodule


module fft2d_unisim_fft2d_bufdin_sync_rcv_back_method(clk, rst, bufdin_valid, 
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

  // synthesis async_set_reset_local fft2d_unisim_fft2d_bufdin_sync_rcv_back_method_seq_block rst
  always @(posedge clk or negedge rst) // fft2d_unisim_fft2d_bufdin_sync_rcv_back_method_sequential
    begin : fft2d_unisim_fft2d_bufdin_sync_rcv_back_method_seq_block
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
  always @(*) begin : fft2d_unisim_fft2d_bufdin_sync_rcv_back_method_combinational
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


module fft2d_unisim_fft2d_bufdin_sync_rcv_ready_arb(bufdin_set_ready_curr, 
bufdin_sync_rcv_set_ready_prev, bufdin_sync_rcv_reset_ready_curr, 
bufdin_sync_rcv_reset_ready_prev, bufdin_sync_rcv_ready_flop, bufdin_ready);
  input bufdin_set_ready_curr;
  input bufdin_sync_rcv_set_ready_prev;
  input bufdin_sync_rcv_reset_ready_curr;
  input bufdin_sync_rcv_reset_ready_prev;
  input bufdin_sync_rcv_ready_flop;
  output reg bufdin_ready;

  always @(*) begin : fft2d_unisim_fft2d_bufdin_sync_rcv_ready_arb_combinational
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


module fft2d_unisim_fft2d_bufdout_can_put_mod_process(bufdout_valid, 
bufdout_ready, bufdout_can_put_sig);
  input bufdout_valid;
  input bufdout_ready;
  output reg bufdout_can_put_sig;

  always @(*) begin : fft2d_unisim_fft2d_bufdout_can_put_mod_process_combinational
      reg unary_nor_ln35_z;
      reg ternaryMux_ln35_0_z;

      unary_nor_ln35_z = ~bufdout_ready;
      ternaryMux_ln35_0_z = ~(bufdout_valid & unary_nor_ln35_z);
      bufdout_can_put_sig = ternaryMux_ln35_0_z;
    end
endmodule


module fft2d_unisim_fft2d_bufdout_sync_snd_back_method(clk, rst, bufdout_ready, 
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

  // synthesis async_set_reset_local fft2d_unisim_fft2d_bufdout_sync_snd_back_method_seq_block rst
  always @(posedge clk or negedge rst) // fft2d_unisim_fft2d_bufdout_sync_snd_back_method_sequential
    begin : fft2d_unisim_fft2d_bufdout_sync_snd_back_method_seq_block
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
  always @(*) begin : fft2d_unisim_fft2d_bufdout_sync_snd_back_method_combinational
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


module fft2d_unisim_fft2d_bufdout_sync_snd_valid_arb(bufdout_set_valid_curr, 
bufdout_sync_snd_set_valid_prev, bufdout_sync_snd_reset_valid_curr, 
bufdout_sync_snd_reset_valid_prev, bufdout_sync_snd_valid_flop, bufdout_valid);
  input bufdout_set_valid_curr;
  input bufdout_sync_snd_set_valid_prev;
  input bufdout_sync_snd_reset_valid_curr;
  input bufdout_sync_snd_reset_valid_prev;
  input bufdout_sync_snd_valid_flop;
  output reg bufdout_valid;

  always @(*) begin : fft2d_unisim_fft2d_bufdout_sync_snd_valid_arb_combinational
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


module fft2d_unisim___rev(v_in, _rev_out);
  input [31:0] v_in;
  output reg [31:0] _rev_out;

  always @(*) begin : fft2d_unisim___rev_combinational
      reg unary_or_ln10_unr1_z;
      reg unary_or_ln10_unr10_z;
      reg unary_or_ln10_unr11_z;
      reg unary_or_ln10_unr12_z;
      reg unary_or_ln10_unr13_z;
      reg unary_or_ln10_unr14_z;
      reg unary_or_ln10_unr15_z;
      reg unary_or_ln10_unr16_z;
      reg unary_or_ln10_unr17_z;
      reg unary_or_ln10_unr18_z;
      reg unary_or_ln10_unr19_z;
      reg unary_or_ln10_unr2_z;
      reg unary_or_ln10_unr20_z;
      reg unary_or_ln10_unr21_z;
      reg unary_or_ln10_unr22_z;
      reg unary_or_ln10_unr23_z;
      reg unary_or_ln10_unr24_z;
      reg unary_or_ln10_unr25_z;
      reg unary_or_ln10_unr26_z;
      reg unary_or_ln10_unr27_z;
      reg unary_or_ln10_unr28_z;
      reg unary_or_ln10_unr29_z;
      reg unary_or_ln10_unr3_z;
      reg unary_or_ln10_unr4_z;
      reg unary_or_ln10_unr5_z;
      reg unary_or_ln10_unr6_z;
      reg unary_or_ln10_unr7_z;
      reg unary_or_ln10_unr8_z;
      reg unary_or_ln10_unr9_z;
      reg if_ln10_unr30_z;
      reg unary_or_ln10_unr0_z;
      reg if_ln10_unr1_z;
      reg if_ln10_unr10_z;
      reg if_ln10_unr11_z;
      reg if_ln10_unr12_z;
      reg if_ln10_unr13_z;
      reg if_ln10_unr14_z;
      reg if_ln10_unr15_z;
      reg if_ln10_unr16_z;
      reg if_ln10_unr17_z;
      reg if_ln10_unr18_z;
      reg if_ln10_unr19_z;
      reg if_ln10_unr2_z;
      reg if_ln10_unr20_z;
      reg if_ln10_unr21_z;
      reg if_ln10_unr22_z;
      reg if_ln10_unr23_z;
      reg if_ln10_unr24_z;
      reg if_ln10_unr25_z;
      reg if_ln10_unr26_z;
      reg if_ln10_unr27_z;
      reg if_ln10_unr28_z;
      reg if_ln10_unr29_z;
      reg if_ln10_unr3_z;
      reg if_ln10_unr4_z;
      reg if_ln10_unr5_z;
      reg if_ln10_unr6_z;
      reg if_ln10_unr7_z;
      reg if_ln10_unr8_z;
      reg if_ln10_unr9_z;
      reg and_1_ln10_unr1_z;
      reg and_0_ln10_unr1_z;
      reg and_1_ln10_unr2_z;
      reg and_0_ln10_unr2_z;
      reg and_1_ln10_unr3_z;
      reg and_0_ln10_unr3_z;
      reg and_1_ln10_unr4_z;
      reg and_0_ln10_unr4_z;
      reg and_1_ln10_unr5_z;
      reg and_0_ln10_unr5_z;
      reg and_1_ln10_unr6_z;
      reg and_0_ln10_unr6_z;
      reg and_1_ln10_unr7_z;
      reg and_0_ln10_unr7_z;
      reg and_1_ln10_unr8_z;
      reg and_0_ln10_unr8_z;
      reg and_1_ln10_unr9_z;
      reg and_0_ln10_unr9_z;
      reg and_1_ln10_unr10_z;
      reg and_0_ln10_unr10_z;
      reg and_1_ln10_unr11_z;
      reg and_0_ln10_unr11_z;
      reg and_1_ln10_unr12_z;
      reg and_0_ln10_unr12_z;
      reg and_1_ln10_unr13_z;
      reg and_0_ln10_unr13_z;
      reg and_1_ln10_unr14_z;
      reg and_0_ln10_unr14_z;
      reg and_1_ln10_unr15_z;
      reg and_0_ln10_unr15_z;
      reg and_1_ln10_unr16_z;
      reg and_0_ln10_unr16_z;
      reg and_1_ln10_unr17_z;
      reg and_0_ln10_unr17_z;
      reg and_1_ln10_unr18_z;
      reg and_0_ln10_unr18_z;
      reg and_1_ln10_unr19_z;
      reg and_0_ln10_unr19_z;
      reg and_1_ln10_unr20_z;
      reg and_0_ln10_unr20_z;
      reg and_1_ln10_unr21_z;
      reg and_0_ln10_unr21_z;
      reg and_1_ln10_unr22_z;
      reg and_0_ln10_unr22_z;
      reg and_1_ln10_unr23_z;
      reg and_0_ln10_unr23_z;
      reg and_1_ln10_unr24_z;
      reg and_0_ln10_unr24_z;
      reg and_1_ln10_unr25_z;
      reg and_0_ln10_unr25_z;
      reg and_1_ln10_unr26_z;
      reg and_0_ln10_unr26_z;
      reg and_1_ln10_unr27_z;
      reg and_0_ln10_unr27_z;
      reg and_1_ln10_unr28_z;
      reg and_0_ln10_unr28_z;
      reg and_1_ln10_unr29_z;
      reg and_0_ln10_unr29_z;
      reg and_1_ln10_unr30_z;
      reg and_0_ln10_unr30_z;
      reg [4:0] mux_exit_mux_s_ln10_z;
      reg [31:0] mux_exit_mux_r_ln10_z;
      reg signed [31:0] lsh_ln15_z;

      unary_or_ln10_unr1_z = |v_in[31:2];
      unary_or_ln10_unr10_z = |v_in[31:11];
      unary_or_ln10_unr11_z = |v_in[31:12];
      unary_or_ln10_unr12_z = |v_in[31:13];
      unary_or_ln10_unr13_z = |v_in[31:14];
      unary_or_ln10_unr14_z = |v_in[31:15];
      unary_or_ln10_unr15_z = |v_in[31:16];
      unary_or_ln10_unr16_z = |v_in[31:17];
      unary_or_ln10_unr17_z = |v_in[31:18];
      unary_or_ln10_unr18_z = |v_in[31:19];
      unary_or_ln10_unr19_z = |v_in[31:20];
      unary_or_ln10_unr2_z = |v_in[31:3];
      unary_or_ln10_unr20_z = |v_in[31:21];
      unary_or_ln10_unr21_z = |v_in[31:22];
      unary_or_ln10_unr22_z = |v_in[31:23];
      unary_or_ln10_unr23_z = |v_in[31:24];
      unary_or_ln10_unr24_z = |v_in[31:25];
      unary_or_ln10_unr25_z = |v_in[31:26];
      unary_or_ln10_unr26_z = |v_in[31:27];
      unary_or_ln10_unr27_z = |v_in[31:28];
      unary_or_ln10_unr28_z = |v_in[31:29];
      unary_or_ln10_unr29_z = |v_in[31:30];
      unary_or_ln10_unr3_z = |v_in[31:4];
      unary_or_ln10_unr4_z = |v_in[31:5];
      unary_or_ln10_unr5_z = |v_in[31:6];
      unary_or_ln10_unr6_z = |v_in[31:7];
      unary_or_ln10_unr7_z = |v_in[31:8];
      unary_or_ln10_unr8_z = |v_in[31:9];
      unary_or_ln10_unr9_z = |v_in[31:10];
      if_ln10_unr30_z = ~v_in[31];
      unary_or_ln10_unr0_z = |v_in[31:1];
      if_ln10_unr1_z = ~unary_or_ln10_unr1_z;
      if_ln10_unr10_z = ~unary_or_ln10_unr10_z;
      if_ln10_unr11_z = ~unary_or_ln10_unr11_z;
      if_ln10_unr12_z = ~unary_or_ln10_unr12_z;
      if_ln10_unr13_z = ~unary_or_ln10_unr13_z;
      if_ln10_unr14_z = ~unary_or_ln10_unr14_z;
      if_ln10_unr15_z = ~unary_or_ln10_unr15_z;
      if_ln10_unr16_z = ~unary_or_ln10_unr16_z;
      if_ln10_unr17_z = ~unary_or_ln10_unr17_z;
      if_ln10_unr18_z = ~unary_or_ln10_unr18_z;
      if_ln10_unr19_z = ~unary_or_ln10_unr19_z;
      if_ln10_unr2_z = ~unary_or_ln10_unr2_z;
      if_ln10_unr20_z = ~unary_or_ln10_unr20_z;
      if_ln10_unr21_z = ~unary_or_ln10_unr21_z;
      if_ln10_unr22_z = ~unary_or_ln10_unr22_z;
      if_ln10_unr23_z = ~unary_or_ln10_unr23_z;
      if_ln10_unr24_z = ~unary_or_ln10_unr24_z;
      if_ln10_unr25_z = ~unary_or_ln10_unr25_z;
      if_ln10_unr26_z = ~unary_or_ln10_unr26_z;
      if_ln10_unr27_z = ~unary_or_ln10_unr27_z;
      if_ln10_unr28_z = ~unary_or_ln10_unr28_z;
      if_ln10_unr29_z = ~unary_or_ln10_unr29_z;
      if_ln10_unr3_z = ~unary_or_ln10_unr3_z;
      if_ln10_unr4_z = ~unary_or_ln10_unr4_z;
      if_ln10_unr5_z = ~unary_or_ln10_unr5_z;
      if_ln10_unr6_z = ~unary_or_ln10_unr6_z;
      if_ln10_unr7_z = ~unary_or_ln10_unr7_z;
      if_ln10_unr8_z = ~unary_or_ln10_unr8_z;
      if_ln10_unr9_z = ~unary_or_ln10_unr9_z;
      and_1_ln10_unr1_z = if_ln10_unr1_z & unary_or_ln10_unr0_z;
      and_0_ln10_unr1_z = unary_or_ln10_unr1_z & unary_or_ln10_unr0_z;
      and_1_ln10_unr2_z = if_ln10_unr2_z & and_0_ln10_unr1_z;
      and_0_ln10_unr2_z = unary_or_ln10_unr2_z & and_0_ln10_unr1_z;
      and_1_ln10_unr3_z = if_ln10_unr3_z & and_0_ln10_unr2_z;
      and_0_ln10_unr3_z = unary_or_ln10_unr3_z & and_0_ln10_unr2_z;
      and_1_ln10_unr4_z = if_ln10_unr4_z & and_0_ln10_unr3_z;
      and_0_ln10_unr4_z = unary_or_ln10_unr4_z & and_0_ln10_unr3_z;
      and_1_ln10_unr5_z = if_ln10_unr5_z & and_0_ln10_unr4_z;
      and_0_ln10_unr5_z = unary_or_ln10_unr5_z & and_0_ln10_unr4_z;
      and_1_ln10_unr6_z = if_ln10_unr6_z & and_0_ln10_unr5_z;
      and_0_ln10_unr6_z = unary_or_ln10_unr6_z & and_0_ln10_unr5_z;
      and_1_ln10_unr7_z = if_ln10_unr7_z & and_0_ln10_unr6_z;
      and_0_ln10_unr7_z = unary_or_ln10_unr7_z & and_0_ln10_unr6_z;
      and_1_ln10_unr8_z = if_ln10_unr8_z & and_0_ln10_unr7_z;
      and_0_ln10_unr8_z = unary_or_ln10_unr8_z & and_0_ln10_unr7_z;
      and_1_ln10_unr9_z = if_ln10_unr9_z & and_0_ln10_unr8_z;
      and_0_ln10_unr9_z = unary_or_ln10_unr9_z & and_0_ln10_unr8_z;
      and_1_ln10_unr10_z = if_ln10_unr10_z & and_0_ln10_unr9_z;
      and_0_ln10_unr10_z = unary_or_ln10_unr10_z & and_0_ln10_unr9_z;
      and_1_ln10_unr11_z = if_ln10_unr11_z & and_0_ln10_unr10_z;
      and_0_ln10_unr11_z = unary_or_ln10_unr11_z & and_0_ln10_unr10_z;
      and_1_ln10_unr12_z = if_ln10_unr12_z & and_0_ln10_unr11_z;
      and_0_ln10_unr12_z = unary_or_ln10_unr12_z & and_0_ln10_unr11_z;
      and_1_ln10_unr13_z = if_ln10_unr13_z & and_0_ln10_unr12_z;
      and_0_ln10_unr13_z = unary_or_ln10_unr13_z & and_0_ln10_unr12_z;
      and_1_ln10_unr14_z = if_ln10_unr14_z & and_0_ln10_unr13_z;
      and_0_ln10_unr14_z = unary_or_ln10_unr14_z & and_0_ln10_unr13_z;
      and_1_ln10_unr15_z = if_ln10_unr15_z & and_0_ln10_unr14_z;
      and_0_ln10_unr15_z = unary_or_ln10_unr15_z & and_0_ln10_unr14_z;
      and_1_ln10_unr16_z = if_ln10_unr16_z & and_0_ln10_unr15_z;
      and_0_ln10_unr16_z = unary_or_ln10_unr16_z & and_0_ln10_unr15_z;
      and_1_ln10_unr17_z = if_ln10_unr17_z & and_0_ln10_unr16_z;
      and_0_ln10_unr17_z = unary_or_ln10_unr17_z & and_0_ln10_unr16_z;
      and_1_ln10_unr18_z = if_ln10_unr18_z & and_0_ln10_unr17_z;
      and_0_ln10_unr18_z = unary_or_ln10_unr18_z & and_0_ln10_unr17_z;
      and_1_ln10_unr19_z = if_ln10_unr19_z & and_0_ln10_unr18_z;
      and_0_ln10_unr19_z = unary_or_ln10_unr19_z & and_0_ln10_unr18_z;
      and_1_ln10_unr20_z = if_ln10_unr20_z & and_0_ln10_unr19_z;
      and_0_ln10_unr20_z = unary_or_ln10_unr20_z & and_0_ln10_unr19_z;
      and_1_ln10_unr21_z = if_ln10_unr21_z & and_0_ln10_unr20_z;
      and_0_ln10_unr21_z = unary_or_ln10_unr21_z & and_0_ln10_unr20_z;
      and_1_ln10_unr22_z = if_ln10_unr22_z & and_0_ln10_unr21_z;
      and_0_ln10_unr22_z = unary_or_ln10_unr22_z & and_0_ln10_unr21_z;
      and_1_ln10_unr23_z = if_ln10_unr23_z & and_0_ln10_unr22_z;
      and_0_ln10_unr23_z = unary_or_ln10_unr23_z & and_0_ln10_unr22_z;
      and_1_ln10_unr24_z = if_ln10_unr24_z & and_0_ln10_unr23_z;
      and_0_ln10_unr24_z = unary_or_ln10_unr24_z & and_0_ln10_unr23_z;
      and_1_ln10_unr25_z = if_ln10_unr25_z & and_0_ln10_unr24_z;
      and_0_ln10_unr25_z = unary_or_ln10_unr25_z & and_0_ln10_unr24_z;
      and_1_ln10_unr26_z = if_ln10_unr26_z & and_0_ln10_unr25_z;
      and_0_ln10_unr26_z = unary_or_ln10_unr26_z & and_0_ln10_unr25_z;
      and_1_ln10_unr27_z = if_ln10_unr27_z & and_0_ln10_unr26_z;
      and_0_ln10_unr27_z = unary_or_ln10_unr27_z & and_0_ln10_unr26_z;
      and_1_ln10_unr28_z = if_ln10_unr28_z & and_0_ln10_unr27_z;
      and_0_ln10_unr28_z = unary_or_ln10_unr28_z & and_0_ln10_unr27_z;
      and_1_ln10_unr29_z = if_ln10_unr29_z & and_0_ln10_unr28_z;
      and_0_ln10_unr29_z = unary_or_ln10_unr29_z & and_0_ln10_unr28_z;
      and_1_ln10_unr30_z = if_ln10_unr30_z & and_0_ln10_unr29_z;
      and_0_ln10_unr30_z = v_in[31] & and_0_ln10_unr29_z;
      case (1'b1)// synthesis parallel_case
        !unary_or_ln10_unr0_z: mux_exit_mux_s_ln10_z = 5'h1f;
        and_1_ln10_unr1_z: mux_exit_mux_s_ln10_z = 5'h1e;
        and_1_ln10_unr2_z: mux_exit_mux_s_ln10_z = 5'h1d;
        and_1_ln10_unr3_z: mux_exit_mux_s_ln10_z = 5'h1c;
        and_1_ln10_unr4_z: mux_exit_mux_s_ln10_z = 5'h1b;
        and_1_ln10_unr5_z: mux_exit_mux_s_ln10_z = 5'h1a;
        and_1_ln10_unr6_z: mux_exit_mux_s_ln10_z = 5'h19;
        and_1_ln10_unr7_z: mux_exit_mux_s_ln10_z = 5'h18;
        and_1_ln10_unr8_z: mux_exit_mux_s_ln10_z = 5'h17;
        and_1_ln10_unr9_z: mux_exit_mux_s_ln10_z = 5'h16;
        and_1_ln10_unr10_z: mux_exit_mux_s_ln10_z = 5'h15;
        and_1_ln10_unr11_z: mux_exit_mux_s_ln10_z = 5'h14;
        and_1_ln10_unr12_z: mux_exit_mux_s_ln10_z = 5'h13;
        and_1_ln10_unr13_z: mux_exit_mux_s_ln10_z = 5'h12;
        and_1_ln10_unr14_z: mux_exit_mux_s_ln10_z = 5'h11;
        and_1_ln10_unr15_z: mux_exit_mux_s_ln10_z = 5'h10;
        and_1_ln10_unr16_z: mux_exit_mux_s_ln10_z = 5'hf;
        and_1_ln10_unr17_z: mux_exit_mux_s_ln10_z = 5'he;
        and_1_ln10_unr18_z: mux_exit_mux_s_ln10_z = 5'hd;
        and_1_ln10_unr19_z: mux_exit_mux_s_ln10_z = 5'hc;
        and_1_ln10_unr20_z: mux_exit_mux_s_ln10_z = 5'hb;
        and_1_ln10_unr21_z: mux_exit_mux_s_ln10_z = 5'ha;
        and_1_ln10_unr22_z: mux_exit_mux_s_ln10_z = 5'h9;
        and_1_ln10_unr23_z: mux_exit_mux_s_ln10_z = 5'h8;
        and_1_ln10_unr24_z: mux_exit_mux_s_ln10_z = 5'h7;
        and_1_ln10_unr25_z: mux_exit_mux_s_ln10_z = 5'h6;
        and_1_ln10_unr26_z: mux_exit_mux_s_ln10_z = 5'h5;
        and_1_ln10_unr27_z: mux_exit_mux_s_ln10_z = 5'h4;
        and_1_ln10_unr28_z: mux_exit_mux_s_ln10_z = 5'h3;
        and_1_ln10_unr29_z: mux_exit_mux_s_ln10_z = 5'h2;
        and_1_ln10_unr30_z: mux_exit_mux_s_ln10_z = 5'h1;
        and_0_ln10_unr30_z: mux_exit_mux_s_ln10_z = 5'h0;
        default: mux_exit_mux_s_ln10_z = 5'hX;
      endcase
      case (1'b1)// synthesis parallel_case
        !unary_or_ln10_unr0_z: mux_exit_mux_r_ln10_z = v_in;
        and_1_ln10_unr1_z: mux_exit_mux_r_ln10_z = {v_in[30:0], v_in[1]};
        and_1_ln10_unr2_z: mux_exit_mux_r_ln10_z = {v_in[29:0], v_in[1], v_in[2]};
        and_1_ln10_unr3_z: mux_exit_mux_r_ln10_z = {v_in[28:0], v_in[1], v_in[2], 
          v_in[3]};
        and_1_ln10_unr4_z: mux_exit_mux_r_ln10_z = {v_in[27:0], v_in[1], v_in[2], 
          v_in[3], v_in[4]};
        and_1_ln10_unr5_z: mux_exit_mux_r_ln10_z = {v_in[26:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5]};
        and_1_ln10_unr6_z: mux_exit_mux_r_ln10_z = {v_in[25:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6]};
        and_1_ln10_unr7_z: mux_exit_mux_r_ln10_z = {v_in[24:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7]};
        and_1_ln10_unr8_z: mux_exit_mux_r_ln10_z = {v_in[23:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8]};
        and_1_ln10_unr9_z: mux_exit_mux_r_ln10_z = {v_in[22:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9]};
        and_1_ln10_unr10_z: mux_exit_mux_r_ln10_z = {v_in[21:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10]};
        and_1_ln10_unr11_z: mux_exit_mux_r_ln10_z = {v_in[20:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11]};
        and_1_ln10_unr12_z: mux_exit_mux_r_ln10_z = {v_in[19:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12]};
        and_1_ln10_unr13_z: mux_exit_mux_r_ln10_z = {v_in[18:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13]};
        and_1_ln10_unr14_z: mux_exit_mux_r_ln10_z = {v_in[17:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14]};
        and_1_ln10_unr15_z: mux_exit_mux_r_ln10_z = {v_in[16:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15]};
        and_1_ln10_unr16_z: mux_exit_mux_r_ln10_z = {v_in[15:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16]};
        and_1_ln10_unr17_z: mux_exit_mux_r_ln10_z = {v_in[14:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17]};
        and_1_ln10_unr18_z: mux_exit_mux_r_ln10_z = {v_in[13:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18]};
        and_1_ln10_unr19_z: mux_exit_mux_r_ln10_z = {v_in[12:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19]};
        and_1_ln10_unr20_z: mux_exit_mux_r_ln10_z = {v_in[11:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20]};
        and_1_ln10_unr21_z: mux_exit_mux_r_ln10_z = {v_in[10:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21]};
        and_1_ln10_unr22_z: mux_exit_mux_r_ln10_z = {v_in[9:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22]};
        and_1_ln10_unr23_z: mux_exit_mux_r_ln10_z = {v_in[8:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23]};
        and_1_ln10_unr24_z: mux_exit_mux_r_ln10_z = {v_in[7:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24]};
        and_1_ln10_unr25_z: mux_exit_mux_r_ln10_z = {v_in[6:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24], 
          v_in[25]};
        and_1_ln10_unr26_z: mux_exit_mux_r_ln10_z = {v_in[5:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24], 
          v_in[25], v_in[26]};
        and_1_ln10_unr27_z: mux_exit_mux_r_ln10_z = {v_in[4:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24], 
          v_in[25], v_in[26], v_in[27]};
        and_1_ln10_unr28_z: mux_exit_mux_r_ln10_z = {v_in[3:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24], 
          v_in[25], v_in[26], v_in[27], v_in[28]};
        and_1_ln10_unr29_z: mux_exit_mux_r_ln10_z = {v_in[2:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24], 
          v_in[25], v_in[26], v_in[27], v_in[28], v_in[29]};
        and_1_ln10_unr30_z: mux_exit_mux_r_ln10_z = {v_in[1:0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24], 
          v_in[25], v_in[26], v_in[27], v_in[28], v_in[29], v_in[30]};
        and_0_ln10_unr30_z: mux_exit_mux_r_ln10_z = {v_in[0], v_in[1], v_in[2], 
          v_in[3], v_in[4], v_in[5], v_in[6], v_in[7], v_in[8], v_in[9], v_in[10], 
          v_in[11], v_in[12], v_in[13], v_in[14], v_in[15], v_in[16], v_in[17], 
          v_in[18], v_in[19], v_in[20], v_in[21], v_in[22], v_in[23], v_in[24], 
          v_in[25], v_in[26], v_in[27], v_in[28], v_in[29], v_in[30], v_in[31]};
        default: mux_exit_mux_r_ln10_z = 32'hX;
      endcase
      lsh_ln15_z = $signed(mux_exit_mux_r_ln10_z) << mux_exit_mux_s_ln10_z;
      _rev_out = lsh_ln15_z;
    end
endmodule


module fft2d_unisim_identity_sync_write_m_8192x64m32(rtl_CE, rtl_A, rtl_D, rtl_WE, rtl_WEM, CLK, mem_CE, mem_A, mem_D, mem_WE, mem_WEM);
    input rtl_CE;
    input [12 : 0] rtl_A;
    input [63 : 0] rtl_D;
    input rtl_WE;
    input [1 : 0] rtl_WEM;
    input CLK;
    output mem_CE;
    output [12 : 0] mem_A;
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
    ctos_external_array_accessor #(.ADDR_WIDTH(13), .DATA_WIDTH(64), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

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


module fft2d_unisim_identity_sync_write_8192x64m0(rtl_CE, rtl_A, rtl_D, rtl_WE, CLK, mem_CE, mem_A, mem_D, mem_WE);
    input rtl_CE;
    input [12 : 0] rtl_A;
    input [63 : 0] rtl_D;
    input rtl_WE;
    input CLK;
    output mem_CE;
    output [12 : 0] mem_A;
    output [63 : 0] mem_D;
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
    ctos_external_array_accessor #(.ADDR_WIDTH(13), .DATA_WIDTH(64), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

    always @(posedge CLK) begin
        if (use_dpi) begin
            if (rtl_CE && rtl_WE) begin
                arr_ref.write(rtl_A, rtl_D);
            end
        end
    end
`endif
endmodule


module fft2d_unisim_identity_sync_read_write_m_8192x64m32(rtl_CE, rtl_A, mem_Q, rtl_D, rtl_WE, rtl_WEM, CLK, mem_CE, mem_A, rtl_Q, mem_D, mem_WE, mem_WEM);
    input rtl_CE;
    input [12 : 0] rtl_A;
    input [63 : 0] mem_Q;
    input [63 : 0] rtl_D;
    input rtl_WE;
    input [1 : 0] rtl_WEM;
    input CLK;
    output mem_CE;
    output [12 : 0] mem_A;
    output [63 : 0] rtl_Q;
    output [63 : 0] mem_D;
    output mem_WE;
    output [1 : 0] mem_WEM;

    assign mem_CE = rtl_CE;
    assign mem_A = rtl_A;
    assign mem_D = rtl_D;
    assign mem_WE = rtl_WE;
    assign mem_WEM = rtl_WEM;
`ifndef CTOS_SIM_MULTI_LANGUAGE_EXTERNAL_ARRAY
    assign rtl_Q = mem_Q;

`else
    // This is only required when simulating a multi-language design.
    reg [63:0] dpi_Q;
    bit use_dpi;
    wire m_ready;
    reg [63:0] dpi_D;
    // Pick which Q drives the RTL Q.
    assign rtl_Q = use_dpi ? dpi_Q : mem_Q;
    initial begin
        use_dpi = 0;

        @(posedge m_ready)
        use_dpi = 1;
    end
    ctos_external_array_accessor #(.ADDR_WIDTH(13), .DATA_WIDTH(64), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

    always @(posedge CLK) begin
        if (use_dpi) begin
            if (rtl_CE && !rtl_WE) begin
                arr_ref.read(rtl_A, dpi_Q);
            end
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


module fft2d_unisim_identity_sync_read_8192x64m0(rtl_CE, rtl_A, mem_Q, CLK, mem_CE, mem_A, rtl_Q);
    input rtl_CE;
    input [12 : 0] rtl_A;
    input [63 : 0] mem_Q;
    input CLK;
    output mem_CE;
    output [12 : 0] mem_A;
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
    ctos_external_array_accessor #(.ADDR_WIDTH(13), .DATA_WIDTH(64), .TRACE(`CTOS_TRACE_EXT_ARRAY_)) arr_ref(m_ready);

    always @(posedge CLK) begin
        if (use_dpi) begin
            if (rtl_CE) begin
                arr_ref.read(rtl_A, dpi_Q);
            end
        end
    end
`endif
endmodule


