module ahb_sdc_controller(
clk,
rst_n,
//AHB inputs
haddr,
hwdata,
hwrite,
hreadyout,
hsize,
hburst,
hsel,
htrans,
hrdata,
hresp,
hready,
hprot,
//Wishbone outputs
/*wbm_dat_o,
wbm_dat_i,
wbm_adr_o, 
wbm_sel_o, 
wbm_we_o,
wbm_cyc_o,
wbm_stb_o, 
wbm_ack_i,
wbm_cti_o, 
wbm_bte_o,
*/
//SD CMD
sd_cmd_dat_i, 
sd_cmd_out_o, 
sd_cmd_oe_o,
//SD DATA
sd_dat_dat_i, 
sd_dat_out_o, 
sd_dat_oe_o, 
sd_clk_o_pad,
sd_clk_i_pad,
);

input clk;
input rst_n;
//AHB signals
input [31:0] haddr;
input [31:0] hwdata;
input hwrite;
input hready;
input [2:0] hsize;
input [2:0] hburst;
input hsel;
input [1:0] htrans;
output [31:0] hrdata;
output hresp;
output hreadyout;
input [3:0] hprot;
//Wishbone signals
/*
output [31:0] wbm_dat_o;
input [31:0] wbm_dat_i;
output [31:0] wbm_adr_o;
output [3:0] wbm_sel_o;
output wbm_we_o;
output wbm_cyc_o;
output wbm_stb_o;
input wbm_ack_i;
output wbm_cti_o;
output wbm_bte_o;
*/
//SD CMD
input sd_cmd_dat_i;
output sd_cmd_out_o;
output sd_cmd_oe_o;
//SD DATA
input [3:0] sd_dat_dat_i;
output [3:0] sd_dat_out_o;
output sd_dat_oe_o;
output sd_clk_o_pad;
input sd_clk_i_pad;

wire[31:0] wbs_dat_i;
wire[31:0] wbs_dat_o;
wire[31:0] wbs_adr_i;
wire[3:0] wbs_sel_i;
wire wbs_we_i;
wire wbs_stb_i;
wire wbs_cyc_i;
wire wbs_ack_o;
wire[31:0] wbm_adr_o;
wire[3:0] wbm_sel_o;
wire wbm_we_o;
wire[31:0] wbm_dat_o;
wire[31:0] wbm_dat_i;
wire wbm_cyc_o;
wire wbm_stb_o;
wire wbm_ack_i;
wire[2:0] wbm_cti_o;
wire[1:0] wbm_bte_o;

wire [7:0] wbs_adr;
assign wbs_adr = wbs_adr_i[28] ? wbs_adr_i[7:0] : 8'bxxxxxxxx;

sdc_controller sd_controller(
    .wb_clk_i(clk),
    .wb_rst_i(!rst_n),
    .wb_dat_i(wbs_dat_i),
    .wb_dat_o(wbs_dat_o),
    .wb_adr_i(wbs_adr),
    .wb_sel_i(wbs_sel_i),
    .wb_we_i(wbs_we_i),
    .wb_stb_i(wbs_stb_i),
    .wb_cyc_i(wbs_cyc_i),
    .wb_ack_o(wbs_ack_o),
    .m_wb_adr_o(wbm_adr_o),
    .m_wb_sel_o(wbm_sel_o),
    .m_wb_we_o(wbm_we_o),
    .m_wb_dat_o(wbm_dat_o),
    .m_wb_dat_i(wbm_dat_i),
    .m_wb_cyc_o(wbm_cyc_o),
    .m_wb_stb_o(wbm_stb_o),
    .m_wb_ack_i(wbm_ack_i),
    .m_wb_cti_o(wbm_cti_o),
    .m_wb_bte_o(wbm_bte_o),
    .sd_cmd_dat_i(sd_cmd_dat_i),
    .sd_cmd_out_o(sd_cmd_out_o),
    .sd_cmd_oe_o(sd_cmd_oe_o),
    .sd_dat_dat_i(sd_dat_dat_i),
    .sd_dat_out_o(sd_dat_out_o),
    .sd_dat_oe_o(sd_dat_oe_o),
    .sd_clk_o_pad(sd_clk_o_pad),
    .sd_clk_i_pad(sd_clk_i_pad),
    .int_cmd (int_cmd),
    .int_data (int_data)
    );

ahb3lite_to_wb ahb3lite_to_wb(
  .clk_i(clk),
  .rst_n_i(rst_n),
  .sHADDR(haddr),
  .sHWDATA(hwdata),
  .sHWRITE(hwrite),
  .sHREADYOUT(hreadyout),
  .sHSIZE(hsize),
  .sHBURST(hburst),
  .sHSEL(hsel),
  .sHTRANS(htrans),
  .sHRDATA(hrdata),
  .sHRESP(hresp),
  .sHREADY(hready),
  .sHPROT(hprot),
  .to_wb_dat_i(wbs_dat_i),
  .to_wb_adr_i(wbs_adr_i),
  .to_wb_sel_i(wbs_sel_i),
  .to_wb_we_i(wbs_we_i),
  .to_wb_cyc_i(wbs_cyc_i),
  .to_wb_stb_i(wbs_stb_i),
  .from_wb_dat_o(wbs_dat_o),
  .from_wb_ack_o(wbs_ack_o),
  .from_wb_err_o(1'b0)
  );


endmodule
