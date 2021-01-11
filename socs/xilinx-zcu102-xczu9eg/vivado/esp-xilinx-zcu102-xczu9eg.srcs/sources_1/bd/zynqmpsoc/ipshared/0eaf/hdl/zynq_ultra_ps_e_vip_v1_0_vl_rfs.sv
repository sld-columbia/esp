/**********************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_arb_wr.sv
 *
 * Date : 2015-16
 *
 * Description : Module that arbitrates between 2 write requests from 2 ports.
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_arb_wr (
 rstn,
 sw_clk,
 prt_qos1,
 prt_qos2,
 prt_dv1,
 prt_dv2,
 prt_data1,
 prt_data2,
 prt_strb1,
 prt_strb2,
 prt_addr1,
 prt_addr2,
 prt_bytes1,
 prt_bytes2,
 prt_ack1,
 prt_ack2,
 prt_qos,
 prt_req,
 prt_data,
 prt_strb,
 prt_addr,
 prt_bytes,
 prt_ack
);

`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"
input rstn, sw_clk;
input [axi_qos_width-1:0] prt_qos1,prt_qos2;
input [max_burst_bits-1:0] prt_data1,prt_data2;
input [max_burst_bytes-1:0] prt_strb1,prt_strb2;
input [addr_width-1:0] prt_addr1,prt_addr2;
input [max_burst_bytes_width:0] prt_bytes1,prt_bytes2;
input prt_dv1, prt_dv2, prt_ack;
output reg prt_ack1,prt_ack2,prt_req;
output reg [max_burst_bits-1:0] prt_data;
output reg [max_burst_bytes-1:0] prt_strb;
output reg [addr_width-1:0] prt_addr;
output reg [max_burst_bytes_width:0] prt_bytes;
output reg [axi_qos_width-1:0] prt_qos;

parameter wait_req = 2'b00, serv_req1 = 2'b01, serv_req2 = 2'b10,wait_ack_low = 2'b11;
reg [1:0] state,temp_state;

always@(posedge sw_clk or negedge rstn)
begin
if(!rstn) begin
 state = wait_req;
 prt_req = 1'b0;
 prt_ack1 = 1'b0;
 prt_ack2 = 1'b0;
 prt_qos = 0;
end else begin
 case(state)
 wait_req:begin  
         state = wait_req;
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0; 
         prt_req = 1'b0;
         if(prt_dv1 && !prt_dv2) begin
           state = serv_req1;
           prt_req = 1;
           prt_data = prt_data1;
           prt_strb = prt_strb1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
           prt_qos = prt_qos1;
         end else if(!prt_dv1 && prt_dv2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           prt_data = prt_data2;
           prt_strb = prt_strb2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_dv1 && prt_dv2) begin
           if(prt_qos1 > prt_qos2) begin
             prt_req = 1;
             prt_qos = prt_qos1;
             prt_data = prt_data1;
             prt_strb = prt_strb1;
             prt_addr = prt_addr1;
             prt_bytes = prt_bytes1;
             state = serv_req1;
           end else if(prt_qos1 < prt_qos2) begin
             prt_req = 1;
             prt_qos = prt_qos2;
             prt_data = prt_data2;
             prt_strb = prt_strb2;
             prt_addr = prt_addr2;
             prt_bytes = prt_bytes2;
             state = serv_req2;
           end else begin
             prt_req = 1;
             prt_qos = prt_qos1;
             prt_data = prt_data1;
             prt_strb = prt_strb1;
             prt_addr = prt_addr1;
             prt_bytes = prt_bytes1;
             state = serv_req1;
           end
         end
       end 
 serv_req1:begin  
         state = serv_req1; 
         prt_ack2 = 1'b0;
         if(prt_ack) begin 
           prt_ack1 = 1'b1;
           prt_req = 0;
           if(prt_dv2) begin
             prt_req = 1;
             prt_qos = prt_qos2;
             prt_data = prt_data2;
             prt_strb = prt_strb2;
             prt_addr = prt_addr2;
             prt_bytes = prt_bytes2;
             state = serv_req2;
           end else begin
         //    state = wait_req;
         state = wait_ack_low;
           end
         end
       end 
 serv_req2:begin
         state = serv_req2; 
         prt_ack1 = 1'b0;
         if(prt_ack) begin 
           prt_ack2 = 1'b1;
           prt_req = 0;
           if(prt_dv1) begin
             prt_req = 1;
             prt_qos = prt_qos1;
             prt_data = prt_data1;
             prt_strb = prt_strb1;
             prt_addr = prt_addr1;
             prt_bytes = prt_bytes1;
             state = serv_req1;
           end else begin
         state = wait_ack_low;
         //    state = wait_req;
           end
         end
       end 
 wait_ack_low:begin
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0;
         state = wait_ack_low;
         if(!prt_ack)
           state = wait_req;
       end  
 endcase
end /// if else
end /// always
endmodule


/************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_arb_rd.sv
 *
 * Date : 2015-16
 *
 * Description : Module that arbitrates between 2 read requests from 2 ports.
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_arb_rd(
 rstn,
 sw_clk,

 prt_qos1,
 prt_qos2,
 prt_req1,
 prt_req2,
 prt_bytes1,
 prt_bytes2,
 prt_addr1,
 prt_addr2,
 prt_data1,
 prt_data2,
 prt_dv1,
 prt_dv2,

 prt_req,
 prt_qos,
 prt_addr,
 prt_bytes,
 prt_data,
 prt_dv

);
`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"
input rstn, sw_clk;
input [axi_qos_width-1:0] prt_qos1,prt_qos2;
input prt_req1, prt_req2;
input [addr_width-1:0] prt_addr1, prt_addr2;
input [max_burst_bytes_width:0] prt_bytes1, prt_bytes2;
output reg prt_dv1, prt_dv2;
output reg [max_burst_bits-1:0] prt_data1,prt_data2;

output reg prt_req;
output reg [axi_qos_width-1:0] prt_qos;
output reg [addr_width-1:0] prt_addr;
output reg [max_burst_bytes_width:0] prt_bytes;
input [max_burst_bits-1:0] prt_data;
input prt_dv;

parameter wait_req = 2'b00, serv_req1 = 2'b01, serv_req2 = 2'b10,wait_dv_low = 2'b11;
reg [1:0] state;

always@(posedge sw_clk or negedge rstn)
begin
if(!rstn) begin
 state = wait_req;
 prt_req = 1'b0;
 prt_dv1 = 1'b0;
 prt_dv2 = 1'b0;
 prt_qos = 0;
end else begin
 case(state)
 wait_req:begin  
         state = wait_req;
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         prt_req = 0;
         if(prt_req1 && !prt_req2) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(!prt_req1 && prt_req2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_req1 && prt_req2) begin
           if(prt_qos1 > prt_qos2) begin
             prt_req = 1;
             prt_qos = prt_qos1;
             prt_addr = prt_addr1;
             prt_bytes = prt_bytes1;
             state = serv_req1;
           end else if(prt_qos1 < prt_qos2) begin
             prt_req = 1;
             prt_addr = prt_addr2;
             prt_qos = prt_qos2;
             prt_bytes = prt_bytes2;
             state = serv_req2;
           end else begin
             prt_req = 1;
             prt_qos = prt_qos1;
             prt_addr = prt_addr1;
             prt_bytes = prt_bytes1;
             state = serv_req1;
           end
         end
       end 
 serv_req1:begin  
         state = serv_req1; 
         prt_dv2 = 1'b0;
         if(prt_dv) begin 
           prt_dv1 = 1'b1;
           prt_data1 = prt_data;
           prt_req = 0;
           if(prt_req2) begin
             prt_req = 1;
             prt_qos = prt_qos2;
             prt_addr = prt_addr2;
             prt_bytes = prt_bytes2;
             state = serv_req2;
           end else begin
             state = wait_dv_low;
             //state = wait_req;
           end
         end
       end 
 serv_req2:begin
         state = serv_req2; 
         prt_dv1 = 1'b0;
         if(prt_dv) begin 
           prt_dv2 = 1'b1;
           prt_data2 = prt_data;
           prt_req = 0;
           if(prt_req1) begin
             prt_req = 1;
             prt_qos = prt_qos1;
             prt_addr = prt_addr1;
             prt_bytes = prt_bytes1;
             state = serv_req1;
           end else begin
             state = wait_dv_low;
             //state = wait_req;
           end
         end
       end 

 wait_dv_low:begin
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         state = wait_dv_low;
         if(!prt_dv)
           state = wait_req;
       end  
 endcase
end /// if else
end /// always
endmodule


/*********************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_arb_wr_6.sv
 *
 * Date : 2015-16
 *
 * Description : Module that arbitrates between 6 write requests from 6 ports.
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_arb_wr_6(
 rstn,
 sw_clk,

 prt_qos0,
 prt_qos1,
 prt_qos2,
 prt_qos3,
 prt_qos4,
 prt_qos5,

 prt_dv0,
 prt_dv1,
 prt_dv2,
 prt_dv3,
 prt_dv4,
 prt_dv5,

 prt_data0,
 prt_data1,
 prt_data2,
 prt_data3,
 prt_data4,
 prt_data5,

 prt_strb0,
 prt_strb1,
 prt_strb2,
 prt_strb3,
 prt_strb4,
 prt_strb5,

 prt_addr0,
 prt_addr1,
 prt_addr2,
 prt_addr3,
 prt_addr4,
 prt_addr5,

 prt_bytes0,
 prt_bytes1,
 prt_bytes2,
 prt_bytes3,
 prt_bytes4,
 prt_bytes5,

 prt_ack0,
 prt_ack1,
 prt_ack2,
 prt_ack3,
 prt_ack4,
 prt_ack5,

 prt_qos,
 prt_req,
 prt_data,
 prt_strb,
 prt_addr,
 prt_bytes,
 prt_ack

);
`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"
input rstn, sw_clk;
input [axi_qos_width-1:0] prt_qos0,prt_qos1,prt_qos2,prt_qos3,prt_qos4,prt_qos5;
input [max_burst_bits-1:0] prt_data0,prt_data1,prt_data2,prt_data3,prt_data4,prt_data5;
input [max_burst_bytes-1:0] prt_strb0,prt_strb1,prt_strb2,prt_strb3,prt_strb4,prt_strb5;
input [addr_width-1:0] prt_addr0,prt_addr1,prt_addr2,prt_addr3,prt_addr4,prt_addr5;
input [max_burst_bytes_width:0] prt_bytes0,prt_bytes1,prt_bytes2,prt_bytes3,prt_bytes4,prt_bytes5;
input prt_dv0, prt_dv1,prt_dv2, prt_dv3, prt_dv4, prt_dv5, prt_ack;
output reg prt_ack0,prt_ack1,prt_ack2,prt_ack3,prt_ack4,prt_ack5,prt_req;
output reg [max_burst_bits-1:0] prt_data;
output reg [max_burst_bytes-1:0] prt_strb;
output reg [addr_width-1:0] prt_addr;
output reg [max_burst_bytes_width:0] prt_bytes;
output reg [axi_qos_width-1:0] prt_qos;
parameter wait_req = 3'b000, serv_req0 = 3'b001, serv_req1 = 3'b010, serv_req2 = 3'b011, serv_req3 = 4'b100, serv_req4 = 4'b101, serv_req5 = 4'b110, wait_ack_low = 3'b111;
reg [2:0] state;

always@(posedge sw_clk or negedge rstn)
begin
if(!rstn) begin
 state = wait_req;
 prt_req = 1'b0;
 prt_ack0 = 1'b0;
 prt_ack1 = 1'b0;
 prt_ack2 = 1'b0;
 prt_ack3 = 1'b0;
 prt_ack4 = 1'b0;
 prt_ack5 = 1'b0;
 prt_qos = 0;
end else begin
 case(state)
 wait_req:begin  
         state = wait_req;
         prt_ack0 = 1'b0;
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0;
         prt_ack3 = 1'b0;
         prt_ack4 = 1'b0;
         prt_ack5 = 1'b0;
         prt_req = 0;
         if(prt_dv0) begin
           state = serv_req0;
           prt_req = 1;
           prt_qos = prt_qos0;
           #0 prt_data = prt_data0;
           #0 prt_strb = prt_strb0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_dv1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           #0 prt_data = prt_data1;
           #0 prt_strb = prt_strb1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_dv2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           #0 prt_data = prt_data2;
           #0 prt_strb = prt_strb2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_dv3) begin
           state = serv_req3;
           prt_req = 1;
           prt_qos = prt_qos3;
		   // $display("Naveen we are assigning the prt_data");
           #0 prt_data = prt_data3;
		   // $display("Naveen we are assigning the prt_data %0h prt_data3 %0h",prt_data,prt_data3);
           #0 prt_strb = prt_strb3;
		   // $display("Naveen we are assigning the prt_strb %0h prt_strb3 %0h",prt_strb,prt_strb3);
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_dv4) begin
           state = serv_req4;
           prt_req = 1;
           prt_qos = prt_qos4;
           #0 prt_data = prt_data4;
           #0 prt_strb = prt_strb4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_dv5) begin
           prt_req = 1;
           prt_qos = prt_qos5;
           #0 prt_data = prt_data5;
           #0 prt_strb = prt_strb5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
           state = serv_req5;
         end
       end 
 serv_req0:begin  
         state = serv_req0;
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0;
         prt_ack3 = 1'b0;
         prt_ack4 = 1'b0;
         prt_ack5 = 1'b0;
       if(prt_ack)begin 
           prt_ack0 = 1'b1;
           state = wait_ack_low;
           prt_req = 0;
         if(prt_dv1) begin
           state = serv_req1;
           prt_qos = prt_qos1;
           prt_req = 1;
           #0 prt_data = prt_data1;
           #0 prt_strb = prt_strb1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_dv2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           #0 prt_data = prt_data2;
           #0 prt_strb = prt_strb2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_dv3) begin
           state = serv_req3;
           prt_req = 1;
           prt_qos = prt_qos3;
           #0 prt_data = prt_data3;
           #0 prt_strb = prt_strb3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_dv4) begin
           state = serv_req4;
           prt_req = 1;
           prt_qos = prt_qos4;
           #0 prt_data = prt_data4;
           #0 prt_strb = prt_strb4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_dv5) begin
           prt_req = 1;
           prt_qos = prt_qos5;
           #0 prt_data = prt_data5;
           #0 prt_strb = prt_strb5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
           state = serv_req5;
         end
       end 
       end
 serv_req1:begin  
         state = serv_req1;
         prt_ack0 = 1'b0;
         prt_ack2 = 1'b0;
         prt_ack3 = 1'b0;
         prt_ack4 = 1'b0;
         prt_ack5 = 1'b0;
       if(prt_ack)begin 
           prt_ack1 = 1'b1;
           state = wait_ack_low;
           prt_req = 0;
         if(prt_dv2) begin
           state = serv_req2;
           prt_qos = prt_qos2;
           prt_req = 1;
           #0 prt_data = prt_data2;
           #0 prt_strb = prt_strb2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_dv3) begin
           state = serv_req3;
           prt_req = 1;
           prt_qos = prt_qos3;
           #0 prt_data = prt_data3;
           #0 prt_strb = prt_strb3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_dv4) begin
           state = serv_req4;
           prt_req = 1;
           prt_qos = prt_qos4;
           #0 prt_data = prt_data4;
           #0 prt_strb = prt_strb4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_dv5) begin
           state = serv_req5;
           prt_req = 1;
           prt_qos = prt_qos5;
           #0 prt_data = prt_data5;
           #0 prt_strb = prt_strb5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_dv0) begin
           prt_req = 1;
           prt_qos = prt_qos0;
           #0 prt_data = prt_data0;
           #0 prt_strb = prt_strb0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
           state = serv_req0;
         end
       end
       end 
 serv_req2:begin  
         state = serv_req2;
         prt_ack0 = 1'b0;
         prt_ack1 = 1'b0;
         prt_ack3 = 1'b0;
         prt_ack4 = 1'b0;
         prt_ack5 = 1'b0;
       if(prt_ack)begin 
           prt_ack2 = 1'b1;
           state = wait_ack_low;
           prt_req = 0;
         if(prt_dv3) begin
           state = serv_req3;
           prt_qos = prt_qos3;
           prt_req = 1;
           #0 prt_data = prt_data3;
           #0 prt_strb = prt_strb3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_dv4) begin
           state = serv_req4;
           prt_qos = prt_qos4;
           prt_req = 1;
           #0 prt_data = prt_data4;
           #0 prt_strb = prt_strb4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_dv5) begin
           state = serv_req5;
           prt_qos = prt_qos5;
           prt_req = 1;
           #0 prt_data = prt_data5;
           #0 prt_strb = prt_strb5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_dv0) begin
           state = serv_req0;
           prt_req = 1;
           prt_qos = prt_qos0;
           #0 prt_data = prt_data0;
           #0 prt_strb = prt_strb0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_dv1) begin
           prt_req = 1;
           prt_qos = prt_qos1;
           #0 prt_data = prt_data1;
           #0 prt_strb = prt_strb1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
           state = serv_req1;
         end
       end
       end 
 serv_req3:begin  
         state = serv_req3;
         prt_ack0 = 1'b0;
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0;
         prt_ack4 = 1'b0;
         prt_ack5 = 1'b0;
       if(prt_ack)begin 
           prt_ack3 = 1'b1;
           state = wait_ack_low;
           prt_req = 0;
         if(prt_dv4) begin
           state = serv_req4;
           prt_req = 1;
           prt_qos = prt_qos4;
           #0 prt_data = prt_data4;
           #0 prt_strb = prt_strb4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_dv5) begin
           state = serv_req5;
           prt_req = 1;
           prt_qos = prt_qos5;
           #0 prt_data = prt_data5;
           #0 prt_strb = prt_strb5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_dv0) begin
           state = serv_req0;
           prt_req = 1;
           prt_qos = prt_qos0;
           #0 prt_data = prt_data0;
           #0 prt_strb = prt_strb0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_dv1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           #0 prt_data = prt_data1;
           #0 prt_strb = prt_strb1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_dv2) begin
           prt_req = 1;
           prt_qos = prt_qos2;
           #0 prt_data = prt_data2;
           #0 prt_strb = prt_strb2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
           state = serv_req2;
         end
       end
       end 
 serv_req4:begin  
         state = serv_req4;
         prt_ack0 = 1'b0;
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0;
         prt_ack3 = 1'b0;
         prt_ack5 = 1'b0;
       if(prt_ack)begin 
           prt_ack4 = 1'b1;
           state = wait_ack_low;
           prt_req = 0;
         if(prt_dv5) begin
           state = serv_req5;
           prt_req = 1;
           prt_qos = prt_qos5;
           #0 prt_data = prt_data5;
           #0 prt_strb = prt_strb5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_dv0) begin
           state = serv_req0;
           prt_req = 1;
           prt_qos = prt_qos0;
           #0 prt_data = prt_data0;
           #0 prt_strb = prt_strb0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_dv1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           #0 prt_data = prt_data1;
           #0 prt_strb = prt_strb1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_dv2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           #0 prt_data = prt_data2;
           #0 prt_strb = prt_strb2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_dv3) begin
           prt_req = 1;
           prt_qos = prt_qos3;
           #0 prt_data = prt_data3;
           #0 prt_strb = prt_strb3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
           state = serv_req3;
         end
       end
       end 
 serv_req5:begin  
         state = serv_req5;
         prt_ack0 = 1'b0;
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0;
         prt_ack3 = 1'b0;
         prt_ack4 = 1'b0;
       if(prt_ack)begin 
           prt_ack5 = 1'b1;
           state = wait_ack_low;
           prt_req = 0;
         if(prt_dv0) begin
           state = serv_req0;
           prt_req = 1;
           prt_qos = prt_qos0;
           #0 prt_data = prt_data0;
           #0 prt_strb = prt_strb0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_dv1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           #0 prt_data = prt_data1;
           #0 prt_strb = prt_strb1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_dv2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           #0 prt_data = prt_data2;
           #0 prt_strb = prt_strb2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_dv3) begin
           state = serv_req3;
           prt_req = 1;
           prt_qos = prt_qos3;
           #0 prt_data = prt_data3;
           #0 prt_strb = prt_strb3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_dv4) begin
           prt_req = 1;
           prt_qos = prt_qos4;
           #0 prt_data = prt_data4;
           #0 prt_strb = prt_strb4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
           state = serv_req4;
         end
       end
       end 
 wait_ack_low:begin
         state = wait_ack_low;
         prt_ack0 = 1'b0;
         prt_ack1 = 1'b0;
         prt_ack2 = 1'b0;
         prt_ack3 = 1'b0;
         prt_ack4 = 1'b0;
         prt_ack5 = 1'b0;
         if(!prt_ack)
           state = wait_req;
       end  
 endcase
end /// if else
end /// always
endmodule


/*****************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_arb_rd_6.sv
 *
 * Date : 2015-16
 *
 * Description : Module that arbitrates between 6 read requests from 6 ports.
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_arb_rd_6(
 rstn,
 sw_clk,

 prt_qos0,
 prt_qos1,
 prt_qos2,
 prt_qos3,
 prt_qos4,
 prt_qos5,

 prt_req0,
 prt_req1,
 prt_req2,
 prt_req3,
 prt_req4,
 prt_req5,

 prt_data0,
 prt_data1,
 prt_data2,
 prt_data3,
 prt_data4,
 prt_data5,

 prt_addr0,
 prt_addr1,
 prt_addr2,
 prt_addr3,
 prt_addr4,
 prt_addr5,

 prt_bytes0,
 prt_bytes1,
 prt_bytes2,
 prt_bytes3,
 prt_bytes4,
 prt_bytes5,

 prt_dv0,
 prt_dv1,
 prt_dv2,
 prt_dv3,
 prt_dv4,
 prt_dv5,

 prt_qos,
 prt_req,
 prt_data,
 prt_addr,
 prt_bytes,
 prt_dv

);
`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"
input rstn, sw_clk;
input [axi_qos_width-1:0] prt_qos0,prt_qos1,prt_qos2,prt_qos3,prt_qos4,prt_qos5;
input prt_req0, prt_req1,prt_req2, prt_req3, prt_req4, prt_req5 ,prt_dv;
output reg [max_burst_bits-1:0] prt_data0,prt_data1,prt_data2,prt_data3,prt_data4,prt_data5;
input [addr_width-1:0] prt_addr0,prt_addr1,prt_addr2,prt_addr3,prt_addr4,prt_addr5;
input [max_burst_bytes_width:0] prt_bytes0,prt_bytes1,prt_bytes2,prt_bytes3,prt_bytes4,prt_bytes5;
output reg prt_dv0,prt_dv1,prt_dv2,prt_dv3,prt_dv4,prt_dv5,prt_req;
input [max_burst_bits-1:0] prt_data;
output reg [addr_width-1:0] prt_addr;
output reg [max_burst_bytes_width:0] prt_bytes;
output reg [axi_qos_width-1:0] prt_qos;

parameter wait_req = 3'b000, serv_req0 = 3'b001, serv_req1 = 3'b010, serv_req2 = 3'b011, serv_req3 = 3'b100, serv_req4 = 3'b101, serv_req5 = 3'b110, wait_dv_low = 3'b111;
reg [2:0] state;

always@(posedge sw_clk or negedge rstn)
begin
if(!rstn) begin
 state = wait_req;
 prt_req = 1'b0;
 prt_dv0 = 1'b0;
 prt_dv1 = 1'b0;
 prt_dv2 = 1'b0;
 prt_dv3 = 1'b0;
 prt_dv4 = 1'b0;
 prt_dv5 = 1'b0;
 prt_qos =    0;
end else begin
 case(state)
 wait_req:begin  
         state = wait_req;
         prt_dv0 = 1'b0;
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         prt_dv3 = 1'b0;
         prt_dv4 = 1'b0;
         prt_dv5 = 1'b0;
         prt_req = 1'b0;
         if(prt_req0) begin
           state = serv_req0;
           prt_req = 1;
           prt_qos = prt_qos0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_req1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_req2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_req3) begin
           state = serv_req3;
           prt_req = 1;
           prt_qos = prt_qos3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_req4) begin
           state = serv_req4;
           prt_req = 1;
           prt_qos = prt_qos4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_req5) begin
           prt_req = 1;
           prt_addr = prt_addr5;
           prt_qos = prt_qos5;
           prt_bytes = prt_bytes5;
           state = serv_req5;
         end
       end 
 serv_req0:begin  
         state = serv_req0;
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         prt_dv3 = 1'b0;
         prt_dv4 = 1'b0;
         prt_dv5 = 1'b0;
       if(prt_dv)begin 
           prt_dv0 = 1'b1;
           prt_data0 = prt_data;
           state = wait_dv_low;
           prt_req = 1'b0;
         if(prt_req1) begin
           state = serv_req1;
           prt_qos = prt_qos1;
           prt_req = 1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_req2) begin
           state = serv_req2;
           prt_qos = prt_qos2;
           prt_req = 1;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_req3) begin
           state = serv_req3;
           prt_qos = prt_qos3;
           prt_req = 1;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_req4) begin
           state = serv_req4;
           prt_qos = prt_qos4;
           prt_req = 1;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_req5) begin
           prt_req = 1;
           prt_qos = prt_qos5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
           state = serv_req5;
         end
       end 
       end
 serv_req1:begin  
         state = serv_req1;
         prt_dv0 = 1'b0;
         prt_dv2 = 1'b0;
         prt_dv3 = 1'b0;
         prt_dv4 = 1'b0;
         prt_dv5 = 1'b0;
       if(prt_dv)begin 
           prt_dv1 = 1'b1;
           prt_data1 = prt_data;
           state = wait_dv_low;
           prt_req = 1'b0;
         if(prt_req2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_req3) begin
           state = serv_req3;
           prt_req = 1;
           prt_qos = prt_qos3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_req4) begin
           state = serv_req4;
           prt_req = 1;
           prt_qos = prt_qos4;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_req5) begin
           state = serv_req5;
           prt_req = 1;
           prt_qos = prt_qos5;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_req0) begin
           prt_req = 1;
           prt_addr = prt_addr0;
           prt_qos = prt_qos0;
           prt_bytes = prt_bytes0;
           state = serv_req0;
         end
       end
       end 
 serv_req2:begin  
         state = serv_req2;
         prt_dv0 = 1'b0;
         prt_dv1 = 1'b0;
         prt_dv3 = 1'b0;
         prt_dv4 = 1'b0;
         prt_dv5 = 1'b0;
       if(prt_dv)begin 
           prt_dv2 = 1'b1;
           prt_data2 = prt_data;
           state = wait_dv_low;
           prt_req = 1'b0;
         if(prt_req3) begin
           state = serv_req3;
           prt_qos = prt_qos3;
           prt_req = 1;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_req4) begin
           state = serv_req4;
           prt_qos = prt_qos4;
           prt_req = 1;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_req5) begin
           state = serv_req5;
           prt_qos = prt_qos5;
           prt_req = 1;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_req0) begin
           state = serv_req0;
           prt_req = 1;
           prt_qos = prt_qos0;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_req1) begin
           prt_req = 1;
           prt_qos = prt_qos1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
           state = serv_req1;
         end
       end
       end 
 serv_req3:begin  
         state = serv_req3;
         prt_dv0 = 1'b0;
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         prt_dv4 = 1'b0;
         prt_dv5 = 1'b0;
       if(prt_dv)begin 
           prt_dv3 = 1'b1;
           prt_data3 = prt_data;
           state = wait_dv_low;
           prt_req = 1'b0;
         if(prt_req4) begin
           state = serv_req4;
           prt_qos = prt_qos4;
           prt_req = 1;
           prt_addr = prt_addr4;
           prt_bytes = prt_bytes4;
         end else if(prt_req5) begin
           state = serv_req5;
           prt_qos = prt_qos5;
           prt_req = 1;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_req0) begin
           state = serv_req0;
           prt_qos = prt_qos0;
           prt_req = 1;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_req1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_req2) begin
           prt_req = 1;
           prt_addr = prt_addr2;
           prt_qos = prt_qos2;
           prt_bytes = prt_bytes2;
           state = serv_req2;
         end
       end
       end 
 serv_req4:begin  
         state = serv_req4;
         prt_dv0 = 1'b0;
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         prt_dv3 = 1'b0;
         prt_dv5 = 1'b0;
       if(prt_dv)begin 
           prt_dv4 = 1'b1;
           prt_data4 = prt_data;
           state = wait_dv_low;
           prt_req = 1'b0;
         if(prt_req5) begin
           state = serv_req5;
           prt_qos = prt_qos5;
           prt_req = 1;
           prt_addr = prt_addr5;
           prt_bytes = prt_bytes5;
         end else if(prt_req0) begin
           state = serv_req0;
           prt_qos = prt_qos0;
           prt_req = 1;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_req1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_req2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_req3) begin
           prt_req = 1;
           prt_addr = prt_addr3;
           prt_qos = prt_qos3;
           prt_bytes = prt_bytes3;
           state = serv_req3;
         end
       end
       end 
 serv_req5:begin
         state = serv_req5;
         prt_dv0 = 1'b0;
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         prt_dv3 = 1'b0;
         prt_dv4 = 1'b0;
       if(prt_dv)begin 
           prt_dv5 = 1'b1;
           prt_data5 = prt_data;
           state = wait_dv_low;
           prt_req = 1'b0;
         if(prt_req0) begin
           state = serv_req0;
           prt_qos = prt_qos0;
           prt_req = 1;
           prt_addr = prt_addr0;
           prt_bytes = prt_bytes0;
         end else if(prt_req1) begin
           state = serv_req1;
           prt_req = 1;
           prt_qos = prt_qos1;
           prt_addr = prt_addr1;
           prt_bytes = prt_bytes1;
         end else if(prt_req2) begin
           state = serv_req2;
           prt_req = 1;
           prt_qos = prt_qos2;
           prt_addr = prt_addr2;
           prt_bytes = prt_bytes2;
         end else if(prt_req3) begin
           state = serv_req3;
           prt_req = 1;
           prt_qos = prt_qos3;
           prt_addr = prt_addr3;
           prt_bytes = prt_bytes3;
         end else if(prt_req4) begin
           prt_req = 1;
           prt_addr = prt_addr4;
           prt_qos = prt_qos4;
           prt_bytes = prt_bytes4;
           state = serv_req4;
         end
       end
       end 
 wait_dv_low:begin
         state = wait_dv_low;
         prt_dv0 = 1'b0;
         prt_dv1 = 1'b0;
         prt_dv2 = 1'b0;
         prt_dv3 = 1'b0;
         prt_dv4 = 1'b0;
         prt_dv5 = 1'b0;
         if(!prt_dv)
           state = wait_req;
       end  
 endcase
end /// if else
end /// always
endmodule


/*****************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr.sv
 *
 * Date : 2015-16
 *
 * Description : Module that arbitrates between RD/WR requests from 2 ports.
 *               Used for modelling the Top_Interconnect switch.
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr(
 sw_clk,
 rstn,
 wr_qos_1,
 rd_qos_1,
 wr_qos_2,
 rd_qos_2,

 wr_ack_1,
 wr_data_1,
 wr_strb_1,
 wr_addr_1,
 wr_bytes_1,
 wr_dv_1,
 rd_req_1,
 rd_addr_1,
 rd_bytes_1,
 rd_data_1,
 rd_dv_1,

 wr_ack_2,
 wr_data_2,
 wr_strb_2,
 wr_addr_2,
 wr_bytes_2,
 wr_dv_2,
 rd_req_2,
 rd_addr_2,
 rd_bytes_2,
 rd_data_2,
 rd_dv_2,

 wr_ack,
 wr_dv,
 rd_req,
 rd_dv,
 rd_qos,
 wr_qos,
 
 wr_addr,
 wr_data,
 wr_strb,
 wr_bytes,
 rd_addr,
 rd_data,
 rd_bytes

);
`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"
input sw_clk;
input rstn;
input [axi_qos_width-1:0] wr_qos_1;
input [axi_qos_width-1:0] rd_qos_1;
input [axi_qos_width-1:0] wr_qos_2;
input [axi_qos_width-1:0] rd_qos_2;
output [axi_qos_width-1:0] rd_qos;
output [axi_qos_width-1:0] wr_qos;

output wr_ack_1;
input [max_burst_bits-1:0] wr_data_1;
input [max_burst_bytes-1:0] wr_strb_1;
input [addr_width-1:0] wr_addr_1;
input [max_burst_bytes_width:0] wr_bytes_1;
output wr_dv_1;

input rd_req_1;
input [addr_width-1:0] rd_addr_1;
input [max_burst_bytes_width:0] rd_bytes_1;
output [max_burst_bits-1:0] rd_data_1;
output rd_dv_1;
 
output wr_ack_2;
input [max_burst_bits-1:0] wr_data_2;
input [max_burst_bytes-1:0] wr_strb_2;
input [addr_width-1:0] wr_addr_2;
input [max_burst_bytes_width:0] wr_bytes_2;
output wr_dv_2;

input rd_req_2;
input [addr_width-1:0] rd_addr_2;
input [max_burst_bytes_width:0] rd_bytes_2;
output [max_burst_bits-1:0] rd_data_2;
output rd_dv_2;
 
input wr_ack;
output wr_dv;
output [addr_width-1:0]wr_addr;
output [max_burst_bits-1:0]wr_data;
output [max_burst_bytes-1:0]wr_strb;
output [max_burst_bytes_width:0]wr_bytes;

input rd_dv;
input [max_burst_bits-1:0] rd_data;
output rd_req;
output [addr_width-1:0] rd_addr;
output [max_burst_bytes_width:0] rd_bytes;

zynq_ultra_ps_e_vip_v1_0_6_arb_wr arb_wr(
 .rstn(rstn),
 .sw_clk(sw_clk),
 .prt_qos1(wr_qos_1),
 .prt_qos2(wr_qos_2),
 .prt_dv1(wr_dv_1),
 .prt_dv2(wr_dv_2),
 .prt_data1(wr_data_1),
 .prt_data2(wr_data_2),
 .prt_strb1(wr_strb_1),
 .prt_strb2(wr_strb_2),
 .prt_addr1(wr_addr_1),
 .prt_addr2(wr_addr_2),
 .prt_bytes1(wr_bytes_1),
 .prt_bytes2(wr_bytes_2),
 .prt_ack1(wr_ack_1),
 .prt_ack2(wr_ack_2),
 .prt_req(wr_dv),
 .prt_qos(wr_qos),
 .prt_data(wr_data),
 .prt_strb(wr_strb),
 .prt_addr(wr_addr),
 .prt_bytes(wr_bytes),
 .prt_ack(wr_ack)
);

zynq_ultra_ps_e_vip_v1_0_6_arb_rd arb_rd (
 .rstn(rstn),
 .sw_clk(sw_clk),
 .prt_qos1(rd_qos_1),
 .prt_qos2(rd_qos_2),
 .prt_req1(rd_req_1),
 .prt_req2(rd_req_2),
 .prt_data1(rd_data_1),
 .prt_data2(rd_data_2),
 .prt_addr1(rd_addr_1),
 .prt_addr2(rd_addr_2),
 .prt_bytes1(rd_bytes_1),
 .prt_bytes2(rd_bytes_2),
 .prt_dv1(rd_dv_1),
 .prt_dv2(rd_dv_2),
 .prt_req(rd_req),
 .prt_qos(rd_qos),
 .prt_data(rd_data),
 .prt_addr(rd_addr),
 .prt_bytes(rd_bytes),
 .prt_dv(rd_dv)
);

endmodule


/***************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_sparse_mem.sv
 *
 * Date : 2015-16
 *
 * Description : Sparse Memory Model
 *
 *****************************************************************************/

/*** WA for CR # 695818 ***/
`ifdef XILINX_SIMULATOR
   `define XSIM_ISIM
`endif
`ifdef XILINX_ISIM
   `define XSIM_ISIM
`endif

 `timescale 1ns/1ps
module zynq_ultra_ps_e_vip_v1_0_6_sparse_mem();

`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

parameter mem_size = 32'h4000_0000; /// 1GB mem size
parameter xsim_mem_size = 32'h1000_0000; ///256 MB mem size (x4 for XSIM/ISIM)


//`ifdef XSIM_ISIM
// reg [data_width-1:0] ddr_mem0 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
// reg [data_width-1:0] ddr_mem1 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
// reg [data_width-1:0] ddr_mem2 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
// reg [data_width-1:0] ddr_mem3 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
// reg [data_width-1:0] ddr_mem4 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
// reg [data_width-1:0] ddr_mem5 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
// reg [data_width-1:0] ddr_mem6 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
// reg [data_width-1:0] ddr_mem7 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
//`else
 reg /*sparse*/ [data_width-1:0] ddr_mem0 [0:(mem_size/mem_width)-1]; // 'h0000_0000 to 'h3FFF_FFFF - 1G mem
 reg /*sparse*/ [data_width-1:0] ddr_mem1 [0:(mem_size/mem_width)-1]; // 'h8_0000_0000 to 'h8_3FFF_FFFF - 1G mem
//`endif

event mem_updated;
reg check_we;
reg [addr_width-1:0] check_up_add;
reg [data_width-1:0] updated_data;

/* preload memory from file */
task automatic pre_load_mem_from_file;
input [(max_chars*8)-1:0] file_name;
input [addr_width-1:0] start_addr;
input [int_width-1:0] no_of_bytes;
logic [31:0] addr;
// reg /*sparse*/ [data_width-1:0] ddr_mem0_temp [0:(mem_size/mem_width)-1]; // 'h0000_0000 to 'h3FFF_FFFF - 1G mem
// reg /*sparse*/ [data_width-1:0] ddr_mem1_temp [0:(mem_size/mem_width)-1]; // 'h8_0000_0000 to 'h8_3FFF_FFFF - 1G mem

// `ifdef XSIM_ISIM
//   if (start_addr[35:32] == 4'h0) begin
//     case(start_addr[31:28])
//       4'd0 : $readmemh(file_name,ddr_mem0,start_addr>>shft_addr_bits);
//       4'd1 : $readmemh(file_name,ddr_mem1,start_addr>>shft_addr_bits);
//       4'd2 : $readmemh(file_name,ddr_mem2,start_addr>>shft_addr_bits);
//       4'd3 : $readmemh(file_name,ddr_mem3,start_addr>>shft_addr_bits);
//     endcase
//   end else if (start_addr[35:32] == 4'h8) begin
//     case(start_addr[31:28])
//       4'd0 : $readmemh(file_name,ddr_mem4,start_addr>>shft_addr_bits);
//       4'd1 : $readmemh(file_name,ddr_mem5,start_addr>>shft_addr_bits);
//       4'd2 : $readmemh(file_name,ddr_mem6,start_addr>>shft_addr_bits);
//       4'd3 : $readmemh(file_name,ddr_mem7,start_addr>>shft_addr_bits);
//     endcase
//   end
// `else
//   if (start_addr[35:32] == 4'h0) begin
//     $readmemh(file_name,ddr_mem0,start_addr>>shft_addr_bits);
//   end else if (start_addr[35:32] == 4'h8) begin
//     $readmemh(file_name,ddr_mem1,start_addr>>shft_addr_bits);
//   end
// `endif
addr = start_addr>>shft_addr_bits;
//   if(addr[28] == 1'h0) begin
//     $display(" pre_load_mem_from_file11 entered");
//     // $readmemh(file_name,ddr_mem0,addr[27:0]);
//      $readmemh(file_name,ddr_mem0_temp,start_addr>>shft_addr_bits);
//      for (int i = 0; i < no_of_bytes; i = i + 1) begin
//        ddr_mem0[(start_addr>>shft_addr_bits) + i] = ddr_mem0_temp[(start_addr>>shft_addr_bits) + i];
//      end
//   end else begin	
//     $display(" pre_load_mem_from_file222 entered");
//     // $readmemh(file_name,ddr_mem1,addr[27:0]);
//      $readmemh(file_name,ddr_mem1_temp,start_addr>>shft_addr_bits);
//      for (int i = 0; i < no_of_bytes; i = i + 1) begin
//        ddr_mem1[(start_addr>>shft_addr_bits) + i] = ddr_mem1_temp[(start_addr>>shft_addr_bits) + i];
//      end		
//   end		
$display($time," DDR data width is %0d start addr is %0h ",data_width,addr); 
  if(addr[28] == 1'h0) begin
    $display(" pre_load_mem_from_file11 entered");
    $readmemh(file_name,ddr_mem0,addr[27:0],addr[27:0]+(no_of_bytes-1));
  end else begin	
    $display(" pre_load_mem_from_file222 entered");
    $readmemh(file_name,ddr_mem1,addr[27:0],addr[27:0]+(no_of_bytes-1));
  end	
  
endtask

/* preload memory with some random data */
task automatic pre_load_mem;
input [1:0]  data_type;
input [addr_width-1:0] start_addr;
input [int_width-1:0] no_of_bytes;
integer i;
reg [addr_width-1:0] addr;
begin
addr = start_addr >> shft_addr_bits;
for (i = 0; i < no_of_bytes; i = i + mem_width) begin
   case(data_type)
     ALL_RANDOM : set_data(addr , $random, 4'hF);
     ALL_ZEROS  : set_data(addr , 32'h0000_0000, 4'hF);
     ALL_ONES   : set_data(addr , 32'hFFFF_FFFF, 4'hF);
     default    : set_data(addr , $random, 4'hF);
   endcase
   addr = addr+1;
end 
end
endtask

/* wait for memory update at certain location */
task automatic wait_mem_update;
input[addr_width-1:0] address;
output[data_width-1:0] dataout;
begin
  check_up_add = address >> shft_addr_bits;
  check_we = 1;
  @(mem_updated); 
  dataout = updated_data;
  check_we = 0;
end
endtask

/* internal task to write data in memory */
task automatic set_data;
input [addr_width-1:0] addr;
input [data_width-1:0] data;
input [(data_width/8)-1:0] strb;
begin
//  $display("addr %0h data %0h strb %0h data_width %0d strb %0h",addr,data,addr,strb,data_width,strb);
if(check_we && (addr === check_up_add)) begin
 updated_data = data;
 -> mem_updated;
end
// `ifdef XSIM_ISIM
//   if (addr[35:30] == 6'h0) begin
//     case(addr[31:26])
//       6'd0 : begin
//         if (strb[0] == 1'b1) ddr_mem0[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem0[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem0[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem0[addr[25:0]][31:24] = data[31:24];
//       end
//       6'd1 : begin
//         if (strb[0] == 1'b1) ddr_mem1[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem1[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem1[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem1[addr[25:0]][31:24] = data[31:24];
//       end
//       6'd2 : begin
//         if (strb[0] == 1'b1) ddr_mem2[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem2[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem2[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem2[addr[25:0]][31:24] = data[31:24];
//       end
//       6'd3 : begin
//         if (strb[0] == 1'b1) ddr_mem3[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem3[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem3[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem3[addr[25:0]][31:24] = data[31:24];
//       end
//     endcase
//   end else if (addr[35:30] == 6'h8) begin
//       case(addr[31:26])
//       6'd0 : begin
//         if (strb[0] == 1'b1) ddr_mem4[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem4[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem4[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem4[addr[25:0]][31:24] = data[31:24];
//       end
//       6'd1 : begin
//         if (strb[0] == 1'b1) ddr_mem5[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem5[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem5[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem5[addr[25:0]][31:24] = data[31:24];
//       end
//       6'd2 : begin
//         if (strb[0] == 1'b1) ddr_mem6[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem6[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem6[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem6[addr[25:0]][31:24] = data[31:24];
//       end
//       6'd3 : begin
//         if (strb[0] == 1'b1) ddr_mem7[addr[25:0]][7:0]   = data[7:0];
//         if (strb[1] == 1'b1) ddr_mem7[addr[25:0]][15:8]  = data[15:8];
//         if (strb[2] == 1'b1) ddr_mem7[addr[25:0]][23:16] = data[23:16];
//         if (strb[3] == 1'b1) ddr_mem7[addr[25:0]][31:24] = data[31:24];
//       end
//     endcase
//   end
// `else
//   if (addr[35:30] == 6'h0) begin
//     if (strb[0] == 1'b1) ddr_mem0[addr[29:0]][7:0]   = data[7:0];
//     $display("addr %0h data %0h ddr_mem0[%0h][7:0] %0h strb[0] %0b ",addr,data,addr,ddr_mem0[addr[29:0]][7:0],strb[0]);
//   if (strb[1] == 1'b1) ddr_mem0[addr[29:0]][15:8]  = data[15:8];
//     $display("addr %0h data %0h ddr_mem0[%0h][15:8] %0h strb[1] %0b ",addr,data,addr,ddr_mem0[addr[29:0]][15:8],strb[1]);
//   if (strb[2] == 1'b1) ddr_mem0[addr[29:0]][23:16] = data[23:16];
//     $display("addr %0h data %0h ddr_mem0[%0h][23:16] %0h strb[2] %0b ",addr,data,addr,ddr_mem0[addr[29:0]][23:16],strb[2]);
//   if (strb[3] == 1'b1) ddr_mem0[addr[29:0]][31:24] = data[31:24];
//     $display("addr %0h data %0h ddr_mem0[%0h][31:24] %0h strb[3] %0b ",addr,data,addr,ddr_mem0[addr[29:0]][31:24],strb[3]);
// //    ddr_mem0[addr[25:0]] = data ;
// //    $display("addr %0h data %0h ddr_mem0[%0h] %0h",addr,data,addr,ddr_mem0[addr[25:0]]);
// //    $display("addr %0h data %0h ddr_mem0[%0h][7:0] %0h",addr,data,addr,ddr_mem0[addr[25:0]][7:0]);
//   end else if (addr[35:30] == 6'h8) begin
//     if (strb[0] == 1'b1) ddr_mem1[addr[29:0]][7:0]   = data[7:0];
//     if (strb[1] == 1'b1) ddr_mem1[addr[29:0]][15:8]  = data[15:8];
//     if (strb[2] == 1'b1) ddr_mem1[addr[29:0]][23:16] = data[23:16];
//     if (strb[3] == 1'b1) ddr_mem1[addr[29:0]][31:24] = data[31:24];
//   end
// `endif
  if (addr[28] == 1'h0) begin
     if (strb[0] == 1'b1) ddr_mem0[addr[27:0]][7:0]   = data[7:0];
     if (strb[1] == 1'b1) ddr_mem0[addr[27:0]][15:8]  = data[15:8];
     if (strb[2] == 1'b1) ddr_mem0[addr[27:0]][23:16] = data[23:16];
     if (strb[3] == 1'b1) ddr_mem0[addr[27:0]][31:24] = data[31:24];
  end else begin	
     if (strb[0] == 1'b1) ddr_mem1[addr[27:0]][7:0]   = data[7:0];
     if (strb[1] == 1'b1) ddr_mem1[addr[27:0]][15:8]  = data[15:8];
     if (strb[2] == 1'b1) ddr_mem1[addr[27:0]][23:16] = data[23:16];
     if (strb[3] == 1'b1) ddr_mem1[addr[27:0]][31:24] = data[31:24];
  end	
end
endtask

/* internal task to read data from memory */
task automatic get_data;
input [addr_width-1:0] addr;
output [data_width-1:0] data;
begin
// `ifdef XSIM_ISIM
//   if (addr[35:30] == 6'h0) begin
//     case(addr[31:28])
//       6'd0 : data = ddr_mem0[addr[27:0]];
//       6'd1 : data = ddr_mem1[addr[27:0]];
//       6'd2 : data = ddr_mem2[addr[27:0]];
//       6'd3 : data = ddr_mem3[addr[27:0]];
//     endcase
//   end else if (addr[35:30] == 6'h8) begin
//     case(addr[31:26])
//       6'd0 : data = ddr_mem4[addr[25:0]];
//       //$display("addr %0h data %0h ddr_mem0[%0h][7:0] %0h strb[0] %0b ",addr,data,addr,ddr_mem0[addr[25:0]][7:0],strb[0]);
//     6'd1 : data = ddr_mem5[addr[25:0]];
//       //$display("addr %0h data %0h ddr_mem0[%0h][15:8] %0h strb[1] %0b ",addr,data,addr,ddr_mem0[addr[25:0]][15:8],strb[1]);
//     6'd2 : data = ddr_mem6[addr[25:0]];
//       //$display("addr %0h data %0h ddr_mem0[%0h][23:16] %0h strb[2] %0b ",addr,data,addr,ddr_mem0[addr[25:0]][23:16],strb[2]);
//     6'd3 : data = ddr_mem7[addr[25:0]];
//       //$display("addr %0h data %0h ddr_mem0[%0h][31:24] %0h strb[3] %0b ",addr,data,addr,ddr_mem0[addr[25:0]][31:24],strb[3]);
//     endcase
//   end
// `else
//   if (addr[35:30] == 6'h0) begin
//     data = ddr_mem0[addr[29:0]];
//     $display(" read addr %0h data %0h ddr_mem0[%0h] %0h ",addr[25:0],data,addr[25:0],ddr_mem0[addr[25:0]]);
//   end else if (addr[35:30] == 6'h8) begin
//     data = ddr_mem1[addr[29:0]];
//   end
// `endif
  if (addr[28] == 1'h0 ) begin
     data = ddr_mem0[addr[27:0]];
     //$display(" ddr_mem0 read addr %0h data %0h ddr_mem0[%0h] %0h ",addr[28:0],data,addr[27:0],ddr_mem0[addr[27:0]]);
  end else begin	
     data = ddr_mem1[addr[27:0]];
     //$display(" ddr_mem1 read addr %0h data %0h ddr_mem1[%0h] %0h ",addr[28:0],data,addr[27:0],ddr_mem1[addr[27:0]]);
  end		 
end
endtask

/* Write memory */
task write_mem;
input [max_burst_bits-1 :0] data;
input [addr_width-1:0] start_addr;
input [max_burst_bytes_width:0] no_of_bytes;
input [max_burst_bytes-1:0] strb;
reg [addr_width-1:0] addr;
reg [max_burst_bits-1 :0] wr_temp_data;
reg [max_burst_bytes-1:0] wr_temp_strb;
reg [data_width-1:0]     pre_pad_data,post_pad_data,temp_data;
reg [(data_width/8)-1:0] pre_pad_strb,post_pad_strb,temp_strb;
integer bytes_left;
integer pre_pad_bytes;
integer post_pad_bytes;
begin
addr = start_addr >> shft_addr_bits;
wr_temp_data = data;
wr_temp_strb = strb;

`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : Writing DDR Memory starting address (0x%0h) with %0d bytes.\n Data (0x%0h)",$time, DISP_INT_INFO, start_addr, no_of_bytes, data); 
`endif

temp_data = wr_temp_data[data_width-1:0];
temp_strb = wr_temp_strb[(data_width/8)-1:0];
bytes_left = no_of_bytes;
/* when the no. of bytes to be updated is less than mem_width */
if(bytes_left+start_addr[shft_addr_bits-1:0] < mem_width) begin
 /* first data word in the burst , if unaligned address, the adjust the wr_data accordingly for first write*/
 if(start_addr[shft_addr_bits-1:0] > 0) begin
   //temp_data     = ddr_mem[addr];
   get_data(addr,temp_data);
   temp_strb = 4'hF;
   pre_pad_bytes = mem_width - start_addr[shft_addr_bits-1:0];
   repeat(pre_pad_bytes) begin
     temp_data = temp_data << 8;
	 temp_strb = temp_strb << 1;
   end
   repeat(pre_pad_bytes) begin
     temp_data = temp_data >> 8;
	 temp_strb = temp_strb >> 1;
     temp_data[data_width-1:data_width-8] = wr_temp_data[7:0];
	 temp_strb[(data_width/8)-1]          = wr_temp_strb[0];
     wr_temp_data = wr_temp_data >> 8;
	 wr_temp_strb = wr_temp_strb >> 1;
   end
   bytes_left = bytes_left + pre_pad_bytes;
 end
 /* This is needed for post padding the data ...*/
 post_pad_bytes = mem_width - bytes_left;
 //post_pad_data  = ddr_mem[addr];
 get_data(addr,post_pad_data);
 post_pad_strb = 4'hF;
 repeat(post_pad_bytes) begin
   temp_data = temp_data << 8;
   temp_strb = temp_strb << 1;
 end
 repeat(bytes_left) begin
   post_pad_data = post_pad_data >> 8;
   post_pad_strb = post_pad_strb >> 1;
 end
 repeat(post_pad_bytes) begin
   temp_data = temp_data >> 8;
   temp_strb = temp_strb >> 1;
   temp_data[data_width-1:data_width-8] = post_pad_data[7:0];
   temp_strb[(data_width/8)-1]          = post_pad_strb[0];
   post_pad_data = post_pad_data >> 8; 
   post_pad_strb = post_pad_strb >> 1;
 end
 //ddr_mem[addr] = temp_data;
 set_data(addr,temp_data,temp_strb);
end else begin
 /* first data word in the burst , if unaligned address, the adjust the wr_data accordingly for first write*/
 if(start_addr[shft_addr_bits-1:0] > 0) begin
  //temp_data     = ddr_mem[addr];
  get_data(addr,temp_data);
  temp_strb = 4'hF;
  pre_pad_bytes = mem_width - start_addr[shft_addr_bits-1:0];
  repeat(pre_pad_bytes) begin
    temp_data = temp_data << 8;
	temp_strb = temp_strb << 1;
  end
  repeat(pre_pad_bytes) begin
    temp_data = temp_data >> 8;
	temp_strb = temp_strb >> 1;
    temp_data[data_width-1:data_width-8] = wr_temp_data[7:0];
    temp_strb[(data_width/8)-1]          = wr_temp_strb[0];
    wr_temp_data = wr_temp_data >> 8;
	wr_temp_strb = wr_temp_strb >> 1;
    bytes_left = bytes_left -1;  
  end
 end else begin
  wr_temp_data = wr_temp_data >> data_width;
  wr_temp_strb = wr_temp_strb >> data_width/8;
  bytes_left = bytes_left - mem_width;
 end
 /* first data word end */
 //ddr_mem[addr] = temp_data;
 set_data(addr,temp_data,temp_strb);
 addr = addr + 1;
 while(bytes_left > (mem_width-1) ) begin  /// for unaliged address necessary to check for mem_wd-1 , accordingly we have to pad post bytes.
  //ddr_mem[addr] = wr_temp_data[data_width-1:0];
  set_data(addr,wr_temp_data[data_width-1:0],wr_temp_strb[(data_width/8)-1:0]);
  addr = addr+1;
  wr_temp_data = wr_temp_data >> data_width;
  wr_temp_strb = wr_temp_strb >> data_width/8;
  bytes_left = bytes_left - mem_width;
 end
 
 //post_pad_data   = ddr_mem[addr];
 get_data(addr,post_pad_data);
 post_pad_strb = 4'hF;
 post_pad_bytes  = mem_width - bytes_left;
 /* This is needed for last transfer in unaliged burst */
 if(bytes_left > 0) begin
   temp_data = wr_temp_data[data_width-1:0];
   temp_strb = wr_temp_strb[(data_width/8)-1:0];
   repeat(post_pad_bytes) begin
     temp_data = temp_data << 8;
	 temp_strb = temp_strb << 1;
   end
   repeat(bytes_left) begin
     post_pad_data = post_pad_data >> 8;
	 post_pad_strb = post_pad_strb >> 1;
   end
   repeat(post_pad_bytes) begin
     temp_data = temp_data >> 8;
	 temp_strb = temp_strb >> 1;
     temp_data[data_width-1:data_width-8] = post_pad_data[7:0];
     temp_strb[(data_width/8)-1]          = post_pad_strb[0];
     post_pad_data = post_pad_data >> 8; 
	 post_pad_strb = post_pad_strb >> 1;
   end
   //ddr_mem[addr] = temp_data;
   set_data(addr,temp_data,temp_strb);
 end
end
`ifdef XLNX_INT_DBG $display("[%0d] : %0s : DONE -> Writing DDR Memory starting address (0x%0h)",$time, DISP_INT_INFO, start_addr ); 
`endif
end
endtask

/* read_memory */
task read_mem;
output[max_burst_bits-1 :0] data;
input [addr_width-1:0] start_addr;
input [max_burst_bytes_width :0] no_of_bytes;
integer i;
reg [addr_width-1:0] addr;
reg [data_width-1:0] temp_rd_data;
reg [max_burst_bits-1:0] temp_data;
integer pre_bytes;
integer bytes_left;
begin
addr = start_addr >> shft_addr_bits;
pre_bytes  = start_addr[shft_addr_bits-1:0];
bytes_left = no_of_bytes;

`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : Reading DDR Memory starting address (0x%0h) -> %0d bytes",$time, DISP_INT_INFO, start_addr,no_of_bytes ); 
`endif 

/* Get first data ... if unaligned address */
//temp_data[(max_burst * max_data_burst)-1 : (max_burst * max_data_burst)- data_width] = ddr_mem[addr];
get_data(addr,temp_data[max_burst_bits-1 : max_burst_bits-data_width]);

if(no_of_bytes+start_addr[shft_addr_bits-1:0]  < mem_width ) begin
  temp_data = temp_data >> (pre_bytes * 8);
  repeat(max_burst_bytes - mem_width)
   temp_data = temp_data >> 8;

end else begin
  bytes_left = bytes_left - (mem_width - pre_bytes);
  addr  = addr+1;
  /* Got first data */
  while (bytes_left > (mem_width-1) ) begin
   temp_data = temp_data >> data_width;
   //temp_data[(max_burst * max_data_burst)-1 : (max_burst * max_data_burst)- data_width] = ddr_mem[addr];
   get_data(addr,temp_data[max_burst_bits-1 : max_burst_bits-data_width]);
   addr = addr+1;
   bytes_left = bytes_left - mem_width;
  end 

  /* Get last valid data in the burst*/
  //temp_rd_data = ddr_mem[addr];
  get_data(addr,temp_rd_data);
  while(bytes_left > 0) begin
    temp_data = temp_data >> 8;
    temp_data[max_burst_bits-1 : max_burst_bits-8] = temp_rd_data[7:0];
    temp_rd_data = temp_rd_data >> 8;
    bytes_left = bytes_left - 1;
  end
  /* align to the brst_byte length */
  repeat(max_burst_bytes - no_of_bytes)
    temp_data = temp_data >> 8;
end 
data = temp_data;
`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : DONE -> Reading DDR Memory starting address (0x%0h), Data returned(0x%0h)",$time, DISP_INT_INFO, start_addr, data ); 
`endif 
end
endtask

/* backdoor read to memory */
task peek_mem_to_file;
input [(max_chars*8)-1:0] file_name;
input [addr_width-1:0] start_addr;
input [int_width-1:0] no_of_bytes;

integer rd_fd;
integer bytes;
reg [addr_width-1:0] addr;
reg [data_width-1:0] rd_data;
begin
rd_fd = $fopen(file_name,"w");
bytes = no_of_bytes;

addr = start_addr >> shft_addr_bits;
while (bytes > 0) begin
  get_data(addr,rd_data);
  $fdisplayh(rd_fd,rd_data);
  bytes = bytes - 4;
  addr = addr + 1;
end
end
endtask

endmodule


/*******************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_reg_map.sv
 *
 * Date : 2015-16
 *
 * Description : Controller for Register Map Memory
 *
 *****************************************************************************/
`ifdef XILINX_SIMULATOR
   `define XSIM_ISIM
`endif
`ifdef XILINX_ISIM
   `define XSIM_ISIM
`endif

 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_reg_map();

`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

/* Register definitions */
`include "zynq_ultra_ps_e_vip_v1_0_6_reg_params.sv"

parameter mem_size = 32'h2000_0000; ///as the memory is implemented 4 byte wide
parameter xsim_mem_size = 32'h1000_0000; ///as the memory is implemented 4 byte wide 256 MB 

`ifdef XSIM_ISIM
 reg [data_width-1:0] reg_mem0 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
 reg [data_width-1:0] reg_mem1 [0:(xsim_mem_size/mem_width)-1]; // 256MB mem
 parameter addr_offset_bits = 26;
`else
 reg /*sparse*/ [data_width-1:0] reg_mem [0:(mem_size/mem_width)-1]; //  512 MB needed for reg space
 parameter addr_offset_bits = 27;
`endif

/* preload reset_values from file */
task automatic pre_load_rst_values;
input dummy;
begin
 `include "zynq_ultra_ps_e_vip_v1_0_6_reg_init.sv" /* This file has list of set_reset_data() calls to set the reset value for each register*/
end
endtask

/* writes the reset data into the reg memory */
task automatic set_reset_data;
input [addr_width-1:0] address;
input [data_width-1:0] data;
reg   [addr_width-1:0] addr;
begin
addr = address >> 2; 
`ifdef XSIM_ISIM
  case(addr[addr_width-1:addr_offset_bits])
    14 : reg_mem0[addr[addr_offset_bits-1:0]] = data;
    15 : reg_mem1[addr[addr_offset_bits-1:0]] = data;
  endcase
`else
  reg_mem[addr[addr_offset_bits-1:0]] = data;
`endif
end
endtask

/* writes the data into the reg memory */
task automatic set_data;
input [addr_width-1:0] addr;
input [data_width-1:0] data;
begin
`ifdef XSIM_ISIM
  case(addr[addr_width-1:addr_offset_bits])
    6'h0E : reg_mem0[addr[addr_offset_bits-1:0]] = data;
    6'h0F : reg_mem1[addr[addr_offset_bits-1:0]] = data;
  endcase
`else
  reg_mem[addr[addr_offset_bits-1:0]] = data;
`endif
end
endtask

/* get the read data from reg mem */
task automatic get_data;
input [addr_width-1:0] addr;
output [data_width-1:0] data;
begin
`ifdef XSIM_ISIM
  case(addr[addr_width-1:addr_offset_bits])
    6'h0E : data = reg_mem0[addr[addr_offset_bits-1:0]];
    6'h0F : data = reg_mem1[addr[addr_offset_bits-1:0]];
  endcase
`else
  data = reg_mem[addr[addr_offset_bits-1:0]];
`endif
end
endtask

/* read chunk of registers */
task read_reg_mem;
output[max_burst_bits-1 :0] data;
input [addr_width-1:0] start_addr;
input [max_burst_bytes_width:0] no_of_bytes;
integer i;
reg [addr_width-1:0] addr;
reg [data_width-1:0] temp_rd_data;
reg [max_burst_bits-1:0] temp_data;
integer bytes_left;
begin
addr = start_addr >> shft_addr_bits;
bytes_left = no_of_bytes;

`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : Reading Register Map starting address (0x%0h) -> %0d bytes",$time, DISP_INT_INFO, start_addr,no_of_bytes ); 
`endif 

/* Get first data ... if unaligned address */
get_data(addr,temp_data[max_burst_bits-1 : max_burst_bits- data_width]);

if(no_of_bytes < mem_width ) begin
  repeat(max_burst_bytes - mem_width)
   temp_data = temp_data >> 8;

end else begin
  bytes_left = bytes_left - mem_width;
  addr  = addr+1;
  /* Got first data */
  while (bytes_left > (mem_width-1) ) begin
   temp_data = temp_data >> data_width;
   get_data(addr,temp_data[max_burst_bits-1 : max_burst_bits-data_width]);
   addr = addr+1;
   bytes_left = bytes_left - mem_width;
  end 

  /* Get last valid data in the burst*/
  get_data(addr,temp_rd_data);
  while(bytes_left > 0) begin
    temp_data = temp_data >> 8;
    temp_data[max_burst_bits-1 : max_burst_bits-8] = temp_rd_data[7:0];
    temp_rd_data = temp_rd_data >> 8;
    bytes_left = bytes_left - 1;
  end
  /* align to the brst_byte length */
  repeat(max_burst_bytes - no_of_bytes)
    temp_data = temp_data >> 8;
end 
data = temp_data;
`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : DONE -> Reading Register Map starting address (0x%0h), Data returned(0x%0h)",$time, DISP_INT_INFO, start_addr, data ); 
`endif 
end
endtask

initial 
begin
 pre_load_rst_values(1);
end

endmodule


/*****************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_ocm_mem.sv
 *
 * Date : 2015-16
 *
 * Description : Mimics OCM model
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_ocm_mem();
`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

parameter mem_size = 32'h4_0000; /// 256 KB 
parameter mem_addr_width = clogb2(mem_size/mem_width);

  reg [data_width-1:0] ocm_memory [0:(mem_size/mem_width)-1]; /// 256 KB memory
  //Changed to bit by satya
//   bit [data_width-1:0] ocm_memory [0:(mem_size/mem_width)-1]; /// 256 KB memory  

/* preload memory from file */
// task automatic pre_load_mem_from_file;
// input [(max_chars*8)-1:0] file_name;
// input [addr_width-1:0] start_addr;
// input [int_width-1:0] no_of_bytes;
//  $readmemh(file_name,ocm_memory,start_addr>>shft_addr_bits);
// endtask

task automatic pre_load_mem_from_file;
input [(max_chars*8)-1:0] file_name;
input [addr_width-1:0] start_addr;
input [int_width-1:0] no_of_bytes;
integer i;
 reg [data_width-1:0] ocm_memory_temp [0:(mem_size/mem_width)-1]; /// 256 KB memory

 $readmemh(file_name,ocm_memory_temp,start_addr>>shft_addr_bits);
  for (i = 0; i < no_of_bytes; i = i + 1) begin
   ocm_memory[(start_addr>>shft_addr_bits) + i] = ocm_memory_temp[(start_addr>>shft_addr_bits) + i];
  end
endtask

/* preload memory with some random data */
task automatic pre_load_mem;
input [1:0]  data_type;
input [addr_width-1:0] start_addr;
input [int_width-1:0] no_of_bytes;
integer i;
reg [mem_addr_width-1:0] addr;
begin
addr = start_addr >> shft_addr_bits;

for (i = 0; i < no_of_bytes; i = i + mem_width) begin
   case(data_type)
     ALL_RANDOM : ocm_memory[addr] = $random;
     ALL_ZEROS  : ocm_memory[addr] = 32'h0000_0000;
     ALL_ONES   : ocm_memory[addr] = 32'hFFFF_FFFF;
     default    : ocm_memory[addr] = $random;
   endcase
   addr = addr+1;
end 
end
endtask

/* Write memory */
task write_mem;
input [max_burst_bits-1 :0] data;
input [addr_width-1:0] start_addr;
input [max_burst_bytes_width:0] no_of_bytes;
input [max_burst_bytes-1 :0] strb;
reg [mem_addr_width-1:0] addr;
reg [max_burst_bits-1 :0] wr_temp_data;
reg [max_burst_bytes-1 :0] wr_temp_strb;
reg [data_width-1:0] pre_pad_data,post_pad_data,temp_data;
reg [(data_width/8)-1:0] pre_pad_strb, post_pad_strb, temp_strb;
integer bytes_left;
integer pre_pad_bytes;
integer post_pad_bytes;
begin
addr = start_addr >> shft_addr_bits;
wr_temp_data = data;
wr_temp_strb = strb;

//$display("write_mem called with  start_addr %0h data %0h no_of_bytes %0h",start_addr,data,no_of_bytes);
`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : Writing OCM Memory starting address (0x%0h) with %0d bytes.\n Data (0x%0h)",$time, DISP_INT_INFO, start_addr, no_of_bytes, data); 
`endif

temp_data = wr_temp_data[data_width-1:0];
temp_strb = wr_temp_strb[(data_width/8)-1:0];
bytes_left = no_of_bytes;
//$display("bytes_left %0d temp_data %0h temp_strb %0h",bytes_left,temp_data,temp_strb);
/* when the no. of bytes to be updated is less than mem_width */
if(bytes_left+start_addr[shft_addr_bits-1:0] < mem_width) begin
 /* first data word in the burst , if unaligned address, the adjust the wr_data accordingly for first write*/
 if(start_addr[shft_addr_bits-1:0] > 0) begin
   temp_data     = ocm_memory[addr];
   temp_strb     = 4'hF;
   pre_pad_bytes = mem_width - start_addr[shft_addr_bits-1:0];
   repeat(pre_pad_bytes) begin
     temp_data = temp_data << 8;
	 temp_strb = temp_strb << 1;
   end
   repeat(pre_pad_bytes) begin
     temp_data = temp_data >> 8;
	 temp_strb = temp_strb >> 1;
     temp_data[data_width-1:data_width-8] = wr_temp_data[7:0];
	 temp_strb[(data_width/8)-1]          = wr_temp_strb[0];
     wr_temp_data = wr_temp_data >> 8;
	 wr_temp_strb = wr_temp_strb >> 1;
   end
   bytes_left = bytes_left + pre_pad_bytes;
   //$display("bytes_left %0d temp_data %0h temp_strb %0h",bytes_left,temp_data,temp_strb);
 end
 /* This is needed for post padding the data ...*/
 post_pad_bytes = mem_width - bytes_left;
 post_pad_data  = ocm_memory[addr];
 post_pad_strb = 4'hF;
 repeat(post_pad_bytes) begin
   temp_data = temp_data << 8;
   temp_strb = temp_strb << 1;
 end
 repeat(bytes_left) begin 
   post_pad_data = post_pad_data >> 8;
   post_pad_strb = post_pad_strb >> 1;
 end
 repeat(post_pad_bytes) begin
   temp_data = temp_data >> 8;
   temp_strb = temp_strb >> 1;
   temp_data[data_width-1:data_width-8] = post_pad_data[7:0];
   temp_strb[(data_width/8)-1]          = post_pad_strb[0];
   post_pad_data = post_pad_data >> 8; 
   post_pad_strb = post_pad_strb >> 1;
 end
 if (temp_strb[0] == 1'b1) ocm_memory[addr][7:0]   = temp_data[7:0];
 if (temp_strb[1] == 1'b1) ocm_memory[addr][15:8]  = temp_data[15:8];
 if (temp_strb[2] == 1'b1) ocm_memory[addr][23:16] = temp_data[23:16];
 if (temp_strb[3] == 1'b1) ocm_memory[addr][31:24] = temp_data[31:24];
 //$display(" zero ocm_memory[addr] %0h temp_data %0h ",ocm_memory[addr],temp_data[31:0]);
end else begin
 /* first data word in the burst , if unaligned address, the adjust the wr_data accordingly for first write*/
 if(start_addr[shft_addr_bits-1:0] > 0) begin
  temp_data     = ocm_memory[addr];
  temp_strb     = 4'hF;
  pre_pad_bytes = mem_width - start_addr[shft_addr_bits-1:0];
  repeat(pre_pad_bytes) begin
    temp_data = temp_data << 8;
	temp_strb = temp_strb << 1;
  end
  repeat(pre_pad_bytes) begin
    temp_data = temp_data >> 8;
	temp_strb = temp_strb >> 1;
    temp_data[data_width-1:data_width-8] = wr_temp_data[7:0];
    temp_strb[(data_width/8)-1]          = wr_temp_strb[0];
    wr_temp_data = wr_temp_data >> 8;
    wr_temp_strb = wr_temp_strb >> 1;
    bytes_left = bytes_left -1;  
  end
 end else begin
  wr_temp_data = wr_temp_data >> data_width;  
  wr_temp_strb = wr_temp_strb >> data_width/8;
  bytes_left = bytes_left - mem_width;
 end
 /* first data word end */
 if (temp_strb[0] == 1'b1) ocm_memory[addr][7:0]   = temp_data[7:0];
 if (temp_strb[1] == 1'b1) ocm_memory[addr][15:8]  = temp_data[15:8];
 if (temp_strb[2] == 1'b1) ocm_memory[addr][23:16] = temp_data[23:16];
 if (temp_strb[3] == 1'b1) ocm_memory[addr][31:24] = temp_data[31:24];
 addr = addr + 1;
 //$display(" first write ocm_memory[addr] %0h temp_data %0h ",ocm_memory[addr],temp_data[31:0]);
 while(bytes_left > (mem_width-1) ) begin  /// for unaliged address necessary to check for mem_wd-1 , accordingly we have to pad post bytes.
  if (wr_temp_strb[0] == 1'b1) ocm_memory[addr][7:0]   = wr_temp_data[7:0];
  if (wr_temp_strb[1] == 1'b1) ocm_memory[addr][15:8]  = wr_temp_data[15:8];
  if (wr_temp_strb[2] == 1'b1) ocm_memory[addr][23:16] = wr_temp_data[23:16];
  if (wr_temp_strb[3] == 1'b1) ocm_memory[addr][31:24] = wr_temp_data[31:24];
 //$display("second write ocm_memory[addr] %0h temp_data %0h ",ocm_memory[addr],temp_data[31:0]);
//ocm_memory[addr] = wr_temp_data[data_width-1:0];
  addr = addr+1;
  wr_temp_data = wr_temp_data >> data_width;
  wr_temp_strb = wr_temp_strb >> data_width/8;
  bytes_left = bytes_left - mem_width;
 end
 
 post_pad_data   = ocm_memory[addr];
 post_pad_strb   = 4'hF;
 post_pad_bytes  = mem_width - bytes_left;
 /* This is needed for last transfer in unaliged burst */
 if(bytes_left > 0) begin
   temp_data = wr_temp_data[data_width-1:0];
   temp_strb = wr_temp_strb[(data_width/8)-1:0];
   repeat(post_pad_bytes) begin 
     temp_data = temp_data << 8;
	 temp_strb = temp_strb << 1;
   end
   repeat(bytes_left) begin
     post_pad_data = post_pad_data >> 8;
	 post_pad_strb = post_pad_strb >> 1;
   end
   repeat(post_pad_bytes) begin
     temp_data = temp_data >> 8;
	 temp_strb = temp_strb >> 1;
     temp_data[data_width-1:data_width-8] = post_pad_data[7:0];
     temp_strb[(data_width/8)-1]          = post_pad_strb[0];
     post_pad_data = post_pad_data >> 8; 
	 post_pad_strb = post_pad_strb >> 1;
   end
   if (temp_strb[0] == 1'b1) ocm_memory[addr][7:0]   = temp_data[7:0];
   if (temp_strb[1] == 1'b1) ocm_memory[addr][15:8]  = temp_data[15:8];
   if (temp_strb[2] == 1'b1) ocm_memory[addr][23:16] = temp_data[23:16];
   if (temp_strb[3] == 1'b1) ocm_memory[addr][31:24] = temp_data[31:24];
   //$display("third write ocm_memory[addr] %0h temp_data %0h ",ocm_memory[addr],temp_data[31:0]);
// ocm_memory[addr] = temp_data;
 end
end
`ifdef XLNX_INT_DBG $display("[%0d] : %0s : DONE -> Writing OCM Memory starting address (0x%0h)",$time, DISP_INT_INFO, start_addr ); 
`endif
end
endtask

/* read_memory */
task read_mem;
output[max_burst_bits-1 :0] data;
input [addr_width-1:0] start_addr;
input [max_burst_bytes_width:0] no_of_bytes;
integer i;
reg [mem_addr_width-1:0] addr;
reg [data_width-1:0] temp_rd_data;
reg [max_burst_bits-1:0] temp_data;
integer pre_bytes;
integer bytes_left;
integer number_of_reads_first_loc,number_of_extra_reads;
begin
addr = start_addr >> shft_addr_bits;
pre_bytes  = start_addr[shft_addr_bits-1:0];
// if(pre_bytes+no_of_bytes > mem_width) begin
// bytes_left = pre_bytes+no_of_bytes;
// $display(" new0 number of bytes_left %0d",bytes_left);
// end else begin
// bytes_left = no_of_bytes;
// $display(" new1 number of bytes_left %0d",bytes_left);
// end
number_of_reads_first_loc = (mem_width - pre_bytes);
if(pre_bytes > number_of_reads_first_loc)
number_of_extra_reads = (pre_bytes - number_of_reads_first_loc);
else
number_of_extra_reads = 0;
//$display("number_of_reads_first_loc %0d number_of_extra_reads %0d",number_of_reads_first_loc,number_of_extra_reads);

bytes_left = no_of_bytes-number_of_reads_first_loc;

`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : Reading OCM Memory starting address (0x%0h) -> %0d bytes",$time, DISP_INT_INFO, start_addr,no_of_bytes ); 
`endif 

//$display("start_addr %0h  no_of_bytes %0d addr %0h shft_addr_bits %0d",start_addr,no_of_bytes,addr,shft_addr_bits);

/* Get first data ... if unaligned address */
temp_data[max_burst_bits-1 : max_burst_bits-data_width] = ocm_memory[addr];


//$display("start_addr %0h  ocm_memory[%0h]  %0h pre_bytes %0d",start_addr,addr,ocm_memory[addr],pre_bytes);
// if(no_of_bytes < mem_width ) begin
// if(bytes_left < mem_width ) begin
if(bytes_left <= 0 ) begin
  temp_data = temp_data >> (pre_bytes * 8);
  repeat(max_burst_bytes - mem_width)
   temp_data = temp_data >> 8;
   //$display("temp_data %0h no_of_bytes %0h mem_width %0h",temp_data,no_of_bytes,mem_width);
end else begin
  // bytes_left = bytes_left - (mem_width - pre_bytes);
  //$display(" else bytes_left %0d ",bytes_left);
  addr  = addr+1;
  /* Got first data */
  while (bytes_left > (mem_width-1) ) begin
   temp_data = temp_data >> data_width;
   temp_data[max_burst_bits-1 : max_burst_bits-data_width] = ocm_memory[addr];
   addr = addr+1;
   bytes_left = bytes_left - mem_width;
  end 

  /* Get last valid data in the burst*/
  temp_rd_data = ocm_memory[addr];
   //$display("second temp_rd_data %0h no_of_bytes %0h ocm_memory[%0h] %0h",temp_rd_data,no_of_bytes,addr,ocm_memory[addr]);
  while(bytes_left > 0) begin
    temp_data = temp_data >> 8;
    //$display("temp_data %0h bytes_left %0d max_burst_bits %0d",temp_data,bytes_left,max_burst_bits);
    temp_data[max_burst_bits-1 : max_burst_bits-8] = temp_rd_data[7:0];
    temp_rd_data = temp_rd_data >> 8;
    bytes_left = bytes_left - 1;
    //$display("temp_rd_data %0h bytes_left %0d max_burst_bits %0d",temp_rd_data,bytes_left,max_burst_bits);
  end
  /* align to the brst_byte length */
  repeat(max_burst_bytes - no_of_bytes) begin
    temp_data = temp_data >> 8;
    // $display("temp_data %0h no_of_bytes %0d max_burst_bytes %0d",temp_data,no_of_bytes,max_burst_bytes);
  end	
end 
data = temp_data;
    //$display("final data %0h ",data);
`ifdef XLNX_INT_DBG
   $display("[%0d] : %0s : DONE -> Reading OCM Memory starting address (0x%0h), Data returned(0x%0h)",$time, DISP_INT_INFO, start_addr, data ); 
`endif 
end
endtask

/* backdoor read to memory */
task peek_mem_to_file;
input [(max_chars*8)-1:0] file_name;
input [addr_width-1:0] start_addr;
input [int_width-1:0] no_of_bytes;

integer rd_fd;
integer bytes;
reg [addr_width-1:0] addr;
reg [data_width-1:0] rd_data;
begin
rd_fd = $fopen(file_name,"w");
bytes = no_of_bytes;

addr = start_addr >> shft_addr_bits;
while (bytes > 0) begin
  rd_data = ocm_memory[addr];
  $fdisplayh(rd_fd,rd_data);
  bytes = bytes - 4;
  addr = addr + 1;
end
end
endtask

endmodule


/******************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_regc.sv
 *
 * Date : 2015-16
 *
 * Description : Controller for Register Map Memory
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_regc(
 rstn,
 sw_clk,

/* Goes to port 0 of REG */
 rd_req,
 rd_dv,
 rd_addr,
 rd_data,
 rd_bytes,
 rd_qos

);

`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

input                            rstn;
input                            sw_clk;
input                            rd_req;
output                           rd_dv;
input [addr_width-1:0]           rd_addr;
output[max_burst_bits-1:0]       rd_data;
input[max_burst_bytes_width:0] rd_bytes;
input [3:0]                      rd_qos;

wire [3:0]                       rd_qos;
reg  [max_burst_bits-1:0]        rd_data;
wire [addr_width-1:0]            rd_addr;
wire [max_burst_bytes_width:0] rd_bytes;
reg                              rd_dv;
wire                             rd_req;

zynq_ultra_ps_e_vip_v1_0_6_reg_map regm();

reg state;
always@(posedge sw_clk or negedge rstn)
begin
if(!rstn) begin
 rd_dv <= 0;
 state <= 0;
end else begin
 case(state) 
 0:begin
     state <= 0;
     rd_dv <= 0;
     if(rd_req) begin
       regm.read_reg_mem(rd_data,rd_addr, rd_bytes); 
       rd_dv <= 1;
       state <= 1;
     end

   end
 1:begin
       rd_dv  <= 0;
       state <= 0;
   end 

 endcase
end /// if
end// always

endmodule 


/*****************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_ocmc.sv
 *
 * Date : 2015-16
 *
 * Description : Controller for OCM model
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_ocmc(
 rstn,
 sw_clk,

/* Goes to port 0 of OCM */
 wr_ack,
 wr_dv,
 rd_req,
 rd_dv,
 wr_addr,
 wr_data,
 wr_strb,
 wr_bytes,
 rd_addr,
 rd_data,
 rd_bytes,
 wr_qos,
 rd_qos

);

`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"
input rstn;
input sw_clk;

output wr_ack;
input wr_dv;
input rd_req;
output rd_dv;
input[addr_width-1:0] wr_addr;
input[max_burst_bits-1:0] wr_data;
input[max_burst_bytes-1:0] wr_strb;
input[max_burst_bytes_width:0] wr_bytes;
input[addr_width-1:0] rd_addr;
output[max_burst_bits-1:0] rd_data;
input[max_burst_bytes_width:0] rd_bytes;
input [axi_qos_width-1:0] wr_qos;
input [axi_qos_width-1:0] rd_qos;

wire [axi_qos_width-1:0] wr_qos;
wire wr_req;
wire [max_burst_bits-1:0] wr_data;
wire [max_burst_bytes-1:0] wr_strb;
wire [addr_width-1:0] wr_addr;
wire [max_burst_bytes_width:0] wr_bytes;
reg wr_ack;

wire [axi_qos_width-1:0] rd_qos;
reg [max_burst_bits-1:0] rd_data;
wire [addr_width-1:0] rd_addr;
wire [max_burst_bytes_width:0] rd_bytes;
reg rd_dv;
wire rd_req;

zynq_ultra_ps_e_vip_v1_0_6_ocm_mem ocm();

reg [1:0] state;
always@(posedge sw_clk or negedge rstn)
begin
if(!rstn) begin
 wr_ack <= 0; 
 rd_dv <= 0;
 state <= 2'd0;
end else begin
 case(state) 
 0:begin
     state <= 0;
     wr_ack <= 0;
     rd_dv <= 0;
     if(wr_dv) begin
       ocm.write_mem(wr_data , wr_addr, wr_bytes, wr_strb); 
	   // $display(" ocm_write_data wr_addr %0h wr_data %0h wr_bytes %0h wr_strb %0h",wr_addr,wr_data,wr_bytes,wr_strb);
       wr_ack <= 1;
       state <= 1;
     end
     if(rd_req) begin
       ocm.read_mem(rd_data,rd_addr, rd_bytes); 
	   // $display(" ocm_read_data rd_addr %0h rd_data %0h rd_bytes %0h ",rd_addr,rd_data,rd_bytes);
       rd_dv <= 1;
       state <= 1;
     end

   end
 1:begin
       wr_ack <= 0;
       rd_dv  <= 0;
       state <= 0;
   end 

 endcase
end /// if
end// always

endmodule 


/****************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_interconnect_model.sv
 *
 * Date : 2015-16
 *
 * Description : Mimics Top_interconnect Switch.
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_interconnect_model (
   rstn,
   sw_clk,

   wr_qos_acp,
   wr_ack_acp,
   wr_data_acp,
   wr_strb_acp,
   wr_addr_acp,
   wr_bytes_acp,
   wr_dv_acp,
   rd_qos_acp,
   rd_req_acp,
   rd_addr_acp,
   rd_bytes_acp,
   rd_data_acp,
   rd_dv_acp,

   wr_qos_ace,
   wr_ack_ace,
   wr_data_ace,
   wr_strb_ace,
   wr_addr_ace,
   wr_bytes_ace,
   wr_dv_ace,
   rd_qos_ace,
   rd_req_ace,
   rd_addr_ace,
   rd_bytes_ace,
   rd_data_ace,
   rd_dv_ace,
   
   wr_qos_gp0,
   wr_ack_gp0,
   wr_data_gp0,
   wr_strb_gp0,
   wr_addr_gp0,
   wr_bytes_gp0,
   wr_dv_gp0,
   rd_qos_gp0,
   rd_req_gp0,
   rd_addr_gp0,
   rd_bytes_gp0,
   rd_data_gp0,
   rd_dv_gp0,

   wr_qos_gp1,
   wr_ack_gp1,
   wr_data_gp1,
   wr_strb_gp1,
   wr_addr_gp1,
   wr_bytes_gp1,
   wr_dv_gp1,
   rd_qos_gp1,
   rd_req_gp1,
   rd_addr_gp1,
   rd_bytes_gp1,
   rd_data_gp1,
   rd_dv_gp1,

   wr_qos_gp2,
   wr_ack_gp2,
   wr_data_gp2,
   wr_strb_gp2,
   wr_addr_gp2,
   wr_bytes_gp2,
   wr_dv_gp2,
   rd_qos_gp2,
   rd_req_gp2,
   rd_addr_gp2,
   rd_bytes_gp2,
   rd_data_gp2,
   rd_dv_gp2,

   wr_qos_gp3,
   wr_ack_gp3,
   wr_data_gp3,
   wr_strb_gp3,
   wr_addr_gp3,
   wr_bytes_gp3,
   wr_dv_gp3,
   rd_qos_gp3,
   rd_req_gp3,
   rd_addr_gp3,
   rd_bytes_gp3,
   rd_data_gp3,
   rd_dv_gp3,

   wr_qos_gp4,
   wr_ack_gp4,
   wr_data_gp4,
   wr_strb_gp4,
   wr_addr_gp4,
   wr_bytes_gp4,
   wr_dv_gp4,
   rd_qos_gp4,
   rd_req_gp4,
   rd_addr_gp4,
   rd_bytes_gp4,
   rd_data_gp4,
   rd_dv_gp4,

   wr_qos_gp5,
   wr_ack_gp5,
   wr_data_gp5,
   wr_strb_gp5,
   wr_addr_gp5,
   wr_bytes_gp5,
   wr_dv_gp5,
   rd_qos_gp5,
   rd_req_gp5,
   rd_addr_gp5,
   rd_bytes_gp5,
   rd_data_gp5,
   rd_dv_gp5,

   wr_qos_gp6,
   wr_ack_gp6,
   wr_data_gp6,
   wr_strb_gp6,
   wr_addr_gp6,
   wr_bytes_gp6,
   wr_dv_gp6,
   rd_qos_gp6,
   rd_req_gp6,
   rd_addr_gp6,
   rd_bytes_gp6,
   rd_data_gp6,
   rd_dv_gp6,

   wr_qos,
   wr_ack,
   wr_data,
   wr_strb,
   wr_addr,
   wr_bytes,
   wr_dv,
   rd_qos,
   rd_req,
   rd_addr,
   rd_bytes,
   rd_data,
   rd_dv
);
   `include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

   input                           rstn;
   input                           sw_clk;

   input [axi_qos_width-1:0]       wr_qos_acp;
   output                          wr_ack_acp;
   input[max_burst_bits-1:0]       wr_data_acp;
   input[max_burst_bytes-1:0]      wr_strb_acp;
   input[addr_width-1:0]           wr_addr_acp;
   input[max_burst_bytes_width:0]  wr_bytes_acp;
   input                           wr_dv_acp;
   input [axi_qos_width-1:0]       rd_qos_acp;
   input                           rd_req_acp;
   input[addr_width-1:0]           rd_addr_acp;
   input[max_burst_bytes_width:0]  rd_bytes_acp;
   output[max_burst_bits-1:0]      rd_data_acp;
   output                          rd_dv_acp;

   input [axi_qos_width-1:0]       wr_qos_ace;
   output                          wr_ack_ace;
   input[max_burst_bits-1:0]       wr_data_ace;
   input[max_burst_bytes-1:0]      wr_strb_ace;
   input[addr_width-1:0]           wr_addr_ace;
   input[max_burst_bytes_width:0]  wr_bytes_ace;
   input                           wr_dv_ace;
   input [axi_qos_width-1:0]       rd_qos_ace;
   input                           rd_req_ace;
   input[addr_width-1:0]           rd_addr_ace;
   input[max_burst_bytes_width:0]  rd_bytes_ace;
   output[max_burst_bits-1:0]      rd_data_ace;
   output                          rd_dv_ace;
   
   input [axi_qos_width-1:0]       wr_qos_gp0;
   output                          wr_ack_gp0;
   input[max_burst_bits-1:0]       wr_data_gp0;
   input[max_burst_bytes-1:0]      wr_strb_gp0;
   input[addr_width-1:0]           wr_addr_gp0;
   input[max_burst_bytes_width:0]  wr_bytes_gp0;
   input                           wr_dv_gp0;
   input [axi_qos_width-1:0]       rd_qos_gp0;
   input                           rd_req_gp0;
   input[addr_width-1:0]           rd_addr_gp0;
   input[max_burst_bytes_width:0]  rd_bytes_gp0;
   output[max_burst_bits-1:0]      rd_data_gp0;
   output                          rd_dv_gp0;

   input [axi_qos_width-1:0]       wr_qos_gp1;
   output                          wr_ack_gp1;
   input[max_burst_bits-1:0]       wr_data_gp1;
   input[max_burst_bytes-1:0]      wr_strb_gp1;
   input[addr_width-1:0]           wr_addr_gp1;
   input[max_burst_bytes_width:0]  wr_bytes_gp1;
   input                           wr_dv_gp1;
   input [axi_qos_width-1:0]       rd_qos_gp1;
   input                           rd_req_gp1;
   input[addr_width-1:0]           rd_addr_gp1;
   input[max_burst_bytes_width:0]  rd_bytes_gp1;
   output[max_burst_bits-1:0]      rd_data_gp1;
   output                          rd_dv_gp1;

   input [axi_qos_width-1:0]       wr_qos_gp2;
   output                          wr_ack_gp2;
   input[max_burst_bits-1:0]       wr_data_gp2;
   input[max_burst_bytes-1:0]      wr_strb_gp2;
   input[addr_width-1:0]           wr_addr_gp2;
   input[max_burst_bytes_width:0]  wr_bytes_gp2;
   input                           wr_dv_gp2;
   input [axi_qos_width-1:0]       rd_qos_gp2;
   input                           rd_req_gp2;
   input[addr_width-1:0]           rd_addr_gp2;
   input[max_burst_bytes_width:0]  rd_bytes_gp2;
   output[max_burst_bits-1:0]      rd_data_gp2;
   output                          rd_dv_gp2;

   input [axi_qos_width-1:0]       wr_qos_gp3;
   output                          wr_ack_gp3;
   input[max_burst_bits-1:0]       wr_data_gp3;
   input[max_burst_bytes-1:0]      wr_strb_gp3;
   input[addr_width-1:0]           wr_addr_gp3;
   input[max_burst_bytes_width:0]  wr_bytes_gp3;
   input                           wr_dv_gp3;
   input [axi_qos_width-1:0]       rd_qos_gp3;
   input                           rd_req_gp3;
   input[addr_width-1:0]           rd_addr_gp3;
   input[max_burst_bytes_width:0]  rd_bytes_gp3;
   output[max_burst_bits-1:0]      rd_data_gp3;
   output                          rd_dv_gp3;

   input [axi_qos_width-1:0]       wr_qos_gp4;
   output                          wr_ack_gp4;
   input[max_burst_bits-1:0]       wr_data_gp4;
   input[max_burst_bytes-1:0]      wr_strb_gp4;
   input[addr_width-1:0]           wr_addr_gp4;
   input[max_burst_bytes_width:0]  wr_bytes_gp4;
   input                           wr_dv_gp4;
   input [axi_qos_width-1:0]       rd_qos_gp4;
   input                           rd_req_gp4;
   input[addr_width-1:0]           rd_addr_gp4;
   input[max_burst_bytes_width:0]  rd_bytes_gp4;
   output[max_burst_bits-1:0]      rd_data_gp4;
   output                          rd_dv_gp4;

   input [axi_qos_width-1:0]       wr_qos_gp5;
   output                          wr_ack_gp5;
   input[max_burst_bits-1:0]       wr_data_gp5;
   input[max_burst_bytes-1:0]      wr_strb_gp5;
   input[addr_width-1:0]           wr_addr_gp5;
   input[max_burst_bytes_width:0]  wr_bytes_gp5;
   input                           wr_dv_gp5;
   input [axi_qos_width-1:0]       rd_qos_gp5;
   input                           rd_req_gp5;
   input[addr_width-1:0]           rd_addr_gp5;
   input[max_burst_bytes_width:0]  rd_bytes_gp5;
   output[max_burst_bits-1:0]      rd_data_gp5;
   output                          rd_dv_gp5;

   input [axi_qos_width-1:0]       wr_qos_gp6;
   output                          wr_ack_gp6;
   input[max_burst_bits-1:0]       wr_data_gp6;
   input[max_burst_bytes-1:0]      wr_strb_gp6;
   input[addr_width-1:0]           wr_addr_gp6;
   input[max_burst_bytes_width:0]  wr_bytes_gp6;
   input                           wr_dv_gp6;
   input [axi_qos_width-1:0]       rd_qos_gp6;
   input                           rd_req_gp6;
   input[addr_width-1:0]           rd_addr_gp6;
   input[max_burst_bytes_width:0]  rd_bytes_gp6;
   output[max_burst_bits-1:0]      rd_data_gp6;
   output                          rd_dv_gp6;

   output [axi_qos_width-1:0]      wr_qos;
   input                           wr_ack;
   output[max_burst_bits-1:0]      wr_data;
   output[max_burst_bytes-1:0]     wr_strb;
   output[addr_width-1:0]          wr_addr;
   output[max_burst_bytes_width:0] wr_bytes;
   output                          wr_dv;
   output [axi_qos_width-1:0]      rd_qos;
   output                          rd_req;
   output[addr_width-1:0]          rd_addr;
   output[max_burst_bytes_width:0] rd_bytes;
   input[max_burst_bits-1:0]       rd_data;
   input                           rd_dv;

   wire   [axi_qos_width-1:0]     net_wr_qos_port0;
   wire                           net_wr_ack_port0;
   wire [max_burst_bits-1:0]      net_wr_data_port0;
   wire [max_burst_bytes-1:0]     net_wr_strb_port0;
   wire [addr_width-1:0]          net_wr_addr_port0;
   wire [max_burst_bytes_width:0] net_wr_bytes_port0;
   wire                           net_wr_dv_port0;
   wire   [axi_qos_width-1:0]     net_rd_qos_port0;
   wire                           net_rd_req_port0;
   wire [addr_width-1:0]          net_rd_addr_port0;
   wire [max_burst_bytes_width:0] net_rd_bytes_port0;
   wire [max_burst_bits-1:0]      net_rd_data_port0;
   wire                           net_rd_dv_port0;

   wire   [axi_qos_width-1:0]     net_wr_qos_port1;
   wire                           net_wr_ack_port1;
   wire [max_burst_bits-1:0]      net_wr_data_port1;
   wire [max_burst_bytes-1:0]     net_wr_strb_port1;
   wire [addr_width-1:0]          net_wr_addr_port1;
   wire [max_burst_bytes_width:0] net_wr_bytes_port1;
   wire                           net_wr_dv_port1;
   wire   [axi_qos_width-1:0]     net_rd_qos_port1;
   wire                           net_rd_req_port1;
   wire [addr_width-1:0]          net_rd_addr_port1;
   wire [max_burst_bytes_width:0] net_rd_bytes_port1;
   wire [max_burst_bits-1:0]      net_rd_data_port1;
   wire                           net_rd_dv_port1;
   
   wire   [axi_qos_width-1:0]     net_wr_qos_port2;
   wire                           net_wr_ack_port2;
   wire [max_burst_bits-1:0]      net_wr_data_port2;
   wire [max_burst_bytes-1:0]     net_wr_strb_port2;
   wire [addr_width-1:0]          net_wr_addr_port2;
   wire [max_burst_bytes_width:0] net_wr_bytes_port2;
   wire                           net_wr_dv_port2;
   wire   [axi_qos_width-1:0]     net_rd_qos_port2;
   wire                           net_rd_req_port2;
   wire [addr_width-1:0]          net_rd_addr_port2;
   wire [max_burst_bytes_width:0] net_rd_bytes_port2;
   wire [max_burst_bits-1:0]      net_rd_data_port2;
   wire                           net_rd_dv_port2;

   wire   [axi_qos_width-1:0]     net_wr_qos_port3;
   wire                           net_wr_ack_port3;
   wire [max_burst_bits-1:0]      net_wr_data_port3;
   wire [max_burst_bytes-1:0]     net_wr_strb_port3;
   wire [addr_width-1:0]          net_wr_addr_port3;
   wire [max_burst_bytes_width:0] net_wr_bytes_port3;
   wire                           net_wr_dv_port3;
   wire   [axi_qos_width-1:0]     net_rd_qos_port3;
   wire                           net_rd_req_port3;
   wire [addr_width-1:0]          net_rd_addr_port3;
   wire [max_burst_bytes_width:0] net_rd_bytes_port3;
   wire [max_burst_bits-1:0]      net_rd_data_port3;
   wire                           net_rd_dv_port3;
   
   wire   [axi_qos_width-1:0]     net_wr_qos_port4;
   wire                           net_wr_ack_port4;
   wire [max_burst_bits-1:0]      net_wr_data_port4;
   wire [max_burst_bytes-1:0]     net_wr_strb_port4;
   wire [addr_width-1:0]          net_wr_addr_port4;
   wire [max_burst_bytes_width:0] net_wr_bytes_port4;
   wire                           net_wr_dv_port4;
   wire   [axi_qos_width-1:0]     net_rd_qos_port4;
   wire                           net_rd_req_port4;
   wire [addr_width-1:0]          net_rd_addr_port4;
   wire [max_burst_bytes_width:0] net_rd_bytes_port4;
   wire [max_burst_bits-1:0]      net_rd_data_port4;
   wire                           net_rd_dv_port4;
   
   wire   [axi_qos_width-1:0]     net_wr_qos_port5;
   wire                           net_wr_ack_port5;
   wire [max_burst_bits-1:0]      net_wr_data_port5;
   wire [max_burst_bytes-1:0]     net_wr_strb_port5;
   wire [addr_width-1:0]          net_wr_addr_port5;
   wire [max_burst_bytes_width:0] net_wr_bytes_port5;
   wire                           net_wr_dv_port5;
   wire   [axi_qos_width-1:0]     net_rd_qos_port5;
   wire                           net_rd_req_port5;
   wire [addr_width-1:0]          net_rd_addr_port5;
   wire [max_burst_bytes_width:0] net_rd_bytes_port5;
   wire [max_burst_bits-1:0]      net_rd_data_port5;
   wire                           net_rd_dv_port5;

  //arb_port0
  assign net_wr_qos_port0   = wr_qos_gp6;
  assign wr_ack_gp6     = net_wr_ack_port0;
  assign net_wr_data_port0  = wr_data_gp6;
  assign net_wr_strb_port0  = wr_strb_gp6;
  assign net_wr_addr_port0  = wr_addr_gp6;
  assign net_wr_bytes_port0 = wr_bytes_gp6;
  assign net_wr_dv_port0    = wr_dv_gp6;
  assign net_rd_qos_port0   = rd_qos_gp6;
  assign net_rd_req_port0   = rd_req_gp6;
  assign net_rd_addr_port0  = rd_addr_gp6;
  assign net_rd_bytes_port0 = rd_bytes_gp6;
  assign rd_data_gp6    = net_rd_data_port0;
  assign rd_dv_gp6      = net_rd_dv_port0;

 //arb_port1
zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr arb_port1 (
   .sw_clk         (sw_clk),
   .rstn           (rstn),

   .wr_qos_1        (wr_qos_acp),
   .wr_ack_1       (wr_ack_acp),
   .wr_data_1      (wr_data_acp),
   .wr_strb_1      (wr_strb_acp),
   .wr_addr_1      (wr_addr_acp),
   .wr_bytes_1     (wr_bytes_acp),
   .wr_dv_1        (wr_dv_acp),
   .rd_qos_1       (rd_qos_acp),
   .rd_req_1       (rd_req_acp),
   .rd_addr_1      (rd_addr_acp),
   .rd_bytes_1     (rd_bytes_acp),
   .rd_data_1      (rd_data_acp),
   .rd_dv_1        (rd_dv_acp),

   .wr_qos_2        (wr_qos_ace),
   .wr_ack_2       (wr_ack_ace),
   .wr_data_2      (wr_data_ace),
   .wr_strb_2      (wr_strb_ace),
   .wr_addr_2      (wr_addr_ace),
   .wr_bytes_2     (wr_bytes_ace),
   .wr_dv_2        (wr_dv_ace),
   .rd_qos_2       (rd_qos_ace),
   .rd_req_2       (rd_req_ace),
   .rd_addr_2      (rd_addr_ace),
   .rd_bytes_2     (rd_bytes_ace),
   .rd_data_2      (rd_data_ace),
   .rd_dv_2        (rd_dv_ace),

   .wr_qos         (net_wr_qos_port1),
   .wr_ack         (net_wr_ack_port1),
   .wr_data        (net_wr_data_port1),
   .wr_strb        (net_wr_strb_port1),
   .wr_addr        (net_wr_addr_port1),
   .wr_bytes       (net_wr_bytes_port1),
   .wr_dv          (net_wr_dv_port1),
   .rd_qos         (net_rd_qos_port1),
   .rd_req         (net_rd_req_port1),
   .rd_addr        (net_rd_addr_port1),
   .rd_bytes       (net_rd_bytes_port1),
   .rd_data        (net_rd_data_port1),
   .rd_dv          (net_rd_dv_port1)
);

 //arb_port2
 zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr arb_port2 (
   .sw_clk         (sw_clk),
   .rstn           (rstn),

   .wr_qos_1        (wr_qos_gp0),
   .wr_ack_1       (wr_ack_gp0),
   .wr_data_1      (wr_data_gp0),
   .wr_strb_1      (wr_strb_gp0),
   .wr_addr_1      (wr_addr_gp0),
   .wr_bytes_1     (wr_bytes_gp0),
   .wr_dv_1        (wr_dv_gp0),
   .rd_qos_1       (rd_qos_gp0),
   .rd_req_1       (rd_req_gp0),
   .rd_addr_1      (rd_addr_gp0),
   .rd_bytes_1     (rd_bytes_gp0),
   .rd_data_1      (rd_data_gp0),
   .rd_dv_1        (rd_dv_gp0),

   .wr_qos_2        (wr_qos_gp1),
   .wr_ack_2       (wr_ack_gp1),
   .wr_data_2      (wr_data_gp1),
   .wr_strb_2      (wr_strb_gp1),
   .wr_addr_2      (wr_addr_gp1),
   .wr_bytes_2     (wr_bytes_gp1),
   .wr_dv_2        (wr_dv_gp1),
   .rd_qos_2       (rd_qos_gp1),
   .rd_req_2       (rd_req_gp1),
   .rd_addr_2      (rd_addr_gp1),
   .rd_bytes_2     (rd_bytes_gp1),
   .rd_data_2      (rd_data_gp1),
   .rd_dv_2        (rd_dv_gp1),

   .wr_qos         (net_wr_qos_port2),
   .wr_ack         (net_wr_ack_port2),
   .wr_data        (net_wr_data_port2),
   .wr_strb        (net_wr_strb_port2),
   .wr_addr        (net_wr_addr_port2),
   .wr_bytes       (net_wr_bytes_port2),
   .wr_dv          (net_wr_dv_port2),
   .rd_qos         (net_rd_qos_port2),
   .rd_req         (net_rd_req_port2),
   .rd_addr        (net_rd_addr_port2),
   .rd_bytes       (net_rd_bytes_port2),
   .rd_data        (net_rd_data_port2),
   .rd_dv          (net_rd_dv_port2)
);

  //arb_port3
  assign net_wr_qos_port3   = wr_qos_gp2;
  assign wr_ack_gp2     = net_wr_ack_port3;
  assign net_wr_data_port3  = wr_data_gp2;
  assign net_wr_strb_port3  = wr_strb_gp2;
  assign net_wr_addr_port3  = wr_addr_gp2;
  assign net_wr_bytes_port3 = wr_bytes_gp2;
  assign net_wr_dv_port3    = wr_dv_gp2;
  assign net_rd_qos_port3   = rd_qos_gp2;
  assign net_rd_req_port3   = rd_req_gp2;
  assign net_rd_addr_port3  = rd_addr_gp2;
  assign net_rd_bytes_port3 = rd_bytes_gp2;
  assign rd_data_gp2    = net_rd_data_port3;
  assign rd_dv_gp2      = net_rd_dv_port3;

 //arb_port4
 zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr arb_port4 (
   .sw_clk         (sw_clk),
   .rstn           (rstn),

   .wr_qos_1        (wr_qos_gp3),
   .wr_ack_1       (wr_ack_gp3),
   .wr_data_1      (wr_data_gp3),
   .wr_strb_1      (wr_strb_gp3),
   .wr_addr_1      (wr_addr_gp3),
   .wr_bytes_1     (wr_bytes_gp3),
   .wr_dv_1        (wr_dv_gp3),
   .rd_qos_1       (rd_qos_gp3),
   .rd_req_1       (rd_req_gp3),
   .rd_addr_1      (rd_addr_gp3),
   .rd_bytes_1     (rd_bytes_gp3),
   .rd_data_1      (rd_data_gp3),
   .rd_dv_1        (rd_dv_gp3),

   .wr_qos_2       (wr_qos_gp4),
   .wr_ack_2       (wr_ack_gp4),
   .wr_data_2      (wr_data_gp4),
   .wr_strb_2      (wr_strb_gp4),
   .wr_addr_2      (wr_addr_gp4),
   .wr_bytes_2     (wr_bytes_gp4),
   .wr_dv_2        (wr_dv_gp4),
   .rd_qos_2       (rd_qos_gp4),
   .rd_req_2       (rd_req_gp4),
   .rd_addr_2      (rd_addr_gp4),
   .rd_bytes_2     (rd_bytes_gp4),
   .rd_data_2      (rd_data_gp4),
   .rd_dv_2        (rd_dv_gp4),

   .wr_qos         (net_wr_qos_port4),
   .wr_ack         (net_wr_ack_port4),
   .wr_data        (net_wr_data_port4),
   .wr_strb        (net_wr_strb_port4),
   .wr_addr        (net_wr_addr_port4),
   .wr_bytes       (net_wr_bytes_port4),
   .wr_dv          (net_wr_dv_port4),
   .rd_qos         (net_rd_qos_port4),
   .rd_req         (net_rd_req_port4),
   .rd_addr        (net_rd_addr_port4),
   .rd_bytes       (net_rd_bytes_port4),
   .rd_data        (net_rd_data_port4),
   .rd_dv          (net_rd_dv_port4)
);

  //arb_port5
  assign net_wr_qos_port5   = wr_qos_gp5;
  assign wr_ack_gp5     = net_wr_ack_port5;
  assign net_wr_data_port5  = wr_data_gp5;
  assign net_wr_strb_port5  = wr_strb_gp5;
  assign net_wr_addr_port5  = wr_addr_gp5;
  assign net_wr_bytes_port5 = wr_bytes_gp5;
  assign net_wr_dv_port5    = wr_dv_gp5;
  assign net_rd_qos_port5   = rd_qos_gp5;
  assign net_rd_req_port5   = rd_req_gp5;
  assign net_rd_addr_port5  = rd_addr_gp5;
  assign net_rd_bytes_port5 = rd_bytes_gp5;
  assign rd_data_gp5    = net_rd_data_port5;
  assign rd_dv_gp5      = net_rd_dv_port5;

  zynq_ultra_ps_e_vip_v1_0_6_arb_wr_6 write_ports (
   .rstn(rstn),
   .sw_clk(sw_clk),
     
   .prt_qos0(net_wr_qos_port0),
   .prt_qos1(net_wr_qos_port1),
   .prt_qos2(net_wr_qos_port2),
   .prt_qos3(net_wr_qos_port3),
   .prt_qos4(net_wr_qos_port4),
   .prt_qos5(net_wr_qos_port5),
     
   .prt_dv0(net_wr_dv_port0),
   .prt_dv1(net_wr_dv_port1),
   .prt_dv2(net_wr_dv_port2),
   .prt_dv3(net_wr_dv_port3),
   .prt_dv4(net_wr_dv_port4),
   .prt_dv5(net_wr_dv_port5),
     
   .prt_data0(net_wr_data_port0),
   .prt_data1(net_wr_data_port1),
   .prt_data2(net_wr_data_port2),
   .prt_data3(net_wr_data_port3),
   .prt_data4(net_wr_data_port4),
   .prt_data5(net_wr_data_port5),
         
   .prt_strb0(net_wr_strb_port0),
   .prt_strb1(net_wr_strb_port1),
   .prt_strb2(net_wr_strb_port2),
   .prt_strb3(net_wr_strb_port3),
   .prt_strb4(net_wr_strb_port4),
   .prt_strb5(net_wr_strb_port5),
      
   .prt_addr0(net_wr_addr_port0),
   .prt_addr1(net_wr_addr_port1),
   .prt_addr2(net_wr_addr_port2),
   .prt_addr3(net_wr_addr_port3),
   .prt_addr4(net_wr_addr_port4),
   .prt_addr5(net_wr_addr_port5),
     
   .prt_bytes0(net_wr_bytes_port0),
   .prt_bytes1(net_wr_bytes_port1),
   .prt_bytes2(net_wr_bytes_port2),
   .prt_bytes3(net_wr_bytes_port3),
   .prt_bytes4(net_wr_bytes_port4),
   .prt_bytes5(net_wr_bytes_port5),
     
   .prt_ack0(net_wr_ack_port0),
   .prt_ack1(net_wr_ack_port1),
   .prt_ack2(net_wr_ack_port2),
   .prt_ack3(net_wr_ack_port3),
   .prt_ack4(net_wr_ack_port4),
   .prt_ack5(net_wr_ack_port5),
     
   .prt_qos(wr_qos),
   .prt_req(wr_dv),
   .prt_data(wr_data),
   .prt_strb(wr_strb),
   .prt_addr(wr_addr),
   .prt_bytes(wr_bytes),
   .prt_ack(wr_ack)
  
  );
  
  zynq_ultra_ps_e_vip_v1_0_6_arb_rd_6 read_ports (
   .rstn(rstn),
   .sw_clk(sw_clk),
     
   .prt_qos0(net_rd_qos_port0),
   .prt_qos1(net_rd_qos_port1),
   .prt_qos2(net_rd_qos_port2),
   .prt_qos3(net_rd_qos_port3),
   .prt_qos4(net_rd_qos_port4),
   .prt_qos5(net_rd_qos_port5),
     
   .prt_req0(net_rd_req_port0),
   .prt_req1(net_rd_req_port1),
   .prt_req2(net_rd_req_port2),
   .prt_req3(net_rd_req_port3),
   .prt_req4(net_rd_req_port4),
   .prt_req5(net_rd_req_port5),
     
   .prt_data0(net_rd_data_port0),
   .prt_data1(net_rd_data_port1),
   .prt_data2(net_rd_data_port2),
   .prt_data3(net_rd_data_port3),
   .prt_data4(net_rd_data_port4),
   .prt_data5(net_rd_data_port5),
     
   .prt_addr0(net_rd_addr_port0),
   .prt_addr1(net_rd_addr_port1),
   .prt_addr2(net_rd_addr_port2),
   .prt_addr3(net_rd_addr_port3),
   .prt_addr4(net_rd_addr_port4),
   .prt_addr5(net_rd_addr_port5),
     
   .prt_bytes0(net_rd_bytes_port0),
   .prt_bytes1(net_rd_bytes_port1),
   .prt_bytes2(net_rd_bytes_port2),
   .prt_bytes3(net_rd_bytes_port3),
   .prt_bytes4(net_rd_bytes_port4),
   .prt_bytes5(net_rd_bytes_port5),
     
   .prt_dv0(net_rd_dv_port0),
   .prt_dv1(net_rd_dv_port1),
   .prt_dv2(net_rd_dv_port2),
   .prt_dv3(net_rd_dv_port3),
   .prt_dv4(net_rd_dv_port4),
   .prt_dv5(net_rd_dv_port5),
     
   .prt_qos(rd_qos),
   .prt_req(rd_req),
   .prt_data(rd_data),
   .prt_addr(rd_addr),
   .prt_bytes(rd_bytes),
   .prt_dv(rd_dv)
  
  );

endmodule


/*****************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_ddr_interconnect_model.sv
 *
 * Date : 2015-16
 *
 * Description : Mimics Top_interconnect Switch.
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_ddr_interconnect_model (
   rstn,
   sw_clk,

   wr_qos_ddr_acp,
   wr_ack_ddr_acp,
   wr_data_ddr_acp,
   wr_strb_ddr_acp,
   wr_addr_ddr_acp,
   wr_bytes_ddr_acp,
   wr_dv_ddr_acp,
   rd_qos_ddr_acp,
   rd_req_ddr_acp,
   rd_addr_ddr_acp,
   rd_bytes_ddr_acp,
   rd_data_ddr_acp,
   rd_dv_ddr_acp,

   wr_qos_ddr_ace,
   wr_ack_ddr_ace,
   wr_data_ddr_ace,
   wr_strb_ddr_ace,
   wr_addr_ddr_ace,
   wr_bytes_ddr_ace,
   wr_dv_ddr_ace,
   rd_qos_ddr_ace,
   rd_req_ddr_ace,
   rd_addr_ddr_ace,
   rd_bytes_ddr_ace,
   rd_data_ddr_ace,
   rd_dv_ddr_ace,
   
   wr_qos_ddr_gp0,
   wr_ack_ddr_gp0,
   wr_data_ddr_gp0,
   wr_strb_ddr_gp0,
   wr_addr_ddr_gp0,
   wr_bytes_ddr_gp0,
   wr_dv_ddr_gp0,
   rd_qos_ddr_gp0,
   rd_req_ddr_gp0,
   rd_addr_ddr_gp0,
   rd_bytes_ddr_gp0,
   rd_data_ddr_gp0,
   rd_dv_ddr_gp0,

   wr_qos_ddr_gp1,
   wr_ack_ddr_gp1,
   wr_data_ddr_gp1,
   wr_strb_ddr_gp1,
   wr_addr_ddr_gp1,
   wr_bytes_ddr_gp1,
   wr_dv_ddr_gp1,
   rd_qos_ddr_gp1,
   rd_req_ddr_gp1,
   rd_addr_ddr_gp1,
   rd_bytes_ddr_gp1,
   rd_data_ddr_gp1,
   rd_dv_ddr_gp1,

   wr_qos_ddr_gp2,
   wr_ack_ddr_gp2,
   wr_data_ddr_gp2,
   wr_strb_ddr_gp2,
   wr_addr_ddr_gp2,
   wr_bytes_ddr_gp2,
   wr_dv_ddr_gp2,
   rd_qos_ddr_gp2,
   rd_req_ddr_gp2,
   rd_addr_ddr_gp2,
   rd_bytes_ddr_gp2,
   rd_data_ddr_gp2,
   rd_dv_ddr_gp2,

   wr_qos_ddr_gp3,
   wr_ack_ddr_gp3,
   wr_data_ddr_gp3,
   wr_strb_ddr_gp3,
   wr_addr_ddr_gp3,
   wr_bytes_ddr_gp3,
   wr_dv_ddr_gp3,
   rd_qos_ddr_gp3,
   rd_req_ddr_gp3,
   rd_addr_ddr_gp3,
   rd_bytes_ddr_gp3,
   rd_data_ddr_gp3,
   rd_dv_ddr_gp3,

   wr_qos_ddr_gp4,
   wr_ack_ddr_gp4,
   wr_data_ddr_gp4,
   wr_strb_ddr_gp4,
   wr_addr_ddr_gp4,
   wr_bytes_ddr_gp4,
   wr_dv_ddr_gp4,
   rd_qos_ddr_gp4,
   rd_req_ddr_gp4,
   rd_addr_ddr_gp4,
   rd_bytes_ddr_gp4,
   rd_data_ddr_gp4,
   rd_dv_ddr_gp4,

   wr_qos_ddr_gp5,
   wr_ack_ddr_gp5,
   wr_data_ddr_gp5,
   wr_strb_ddr_gp5,
   wr_addr_ddr_gp5,
   wr_bytes_ddr_gp5,
   wr_dv_ddr_gp5,
   rd_qos_ddr_gp5,
   rd_req_ddr_gp5,
   rd_addr_ddr_gp5,
   rd_bytes_ddr_gp5,
   rd_data_ddr_gp5,
   rd_dv_ddr_gp5,

   wr_qos_ddr_gp6,
   wr_ack_ddr_gp6,
   wr_data_ddr_gp6,
   wr_strb_ddr_gp6,
   wr_addr_ddr_gp6,
   wr_bytes_ddr_gp6,
   wr_dv_ddr_gp6,
   rd_qos_ddr_gp6,
   rd_req_ddr_gp6,
   rd_addr_ddr_gp6,
   rd_bytes_ddr_gp6,
   rd_data_ddr_gp6,
   rd_dv_ddr_gp6,

   /* Goes to port 1 of DDR */
   ddr_wr_qos_port1,
   ddr_wr_ack_port1,
   ddr_wr_data_port1,
   ddr_wr_strb_port1,
   ddr_wr_addr_port1,
   ddr_wr_bytes_port1,
   ddr_wr_dv_port1,
   ddr_rd_qos_port1,
   ddr_rd_req_port1,
   ddr_rd_addr_port1,
   ddr_rd_bytes_port1,
   ddr_rd_data_port1,
   ddr_rd_dv_port1,

   /* Goes to port 2 of DDR */
   ddr_wr_qos_port2,
   ddr_wr_ack_port2,
   ddr_wr_data_port2,
   ddr_wr_strb_port2,
   ddr_wr_addr_port2,
   ddr_wr_bytes_port2,
   ddr_wr_dv_port2,
   ddr_rd_qos_port2,
   ddr_rd_req_port2,
   ddr_rd_addr_port2,
   ddr_rd_bytes_port2,
   ddr_rd_data_port2,
   ddr_rd_dv_port2,

   /* Goes to port 3 of DDR */
   ddr_wr_qos_port3,
   ddr_wr_ack_port3,
   ddr_wr_data_port3,
   ddr_wr_strb_port3,
   ddr_wr_addr_port3,
   ddr_wr_bytes_port3,
   ddr_wr_dv_port3,
   ddr_rd_qos_port3,
   ddr_rd_req_port3,
   ddr_rd_addr_port3,
   ddr_rd_bytes_port3,
   ddr_rd_data_port3,
   ddr_rd_dv_port3,

   /* Goes to port 4 of DDR */
   ddr_wr_qos_port4,
   ddr_wr_ack_port4,
   ddr_wr_data_port4,
   ddr_wr_strb_port4,
   ddr_wr_addr_port4,
   ddr_wr_bytes_port4,
   ddr_wr_dv_port4,
   ddr_rd_qos_port4,
   ddr_rd_req_port4,
   ddr_rd_addr_port4,
   ddr_rd_bytes_port4,
   ddr_rd_data_port4,
   ddr_rd_dv_port4,

   /* Goes to port 5 of DDR */
   ddr_wr_qos_port5,
   ddr_wr_ack_port5,
   ddr_wr_data_port5,
   ddr_wr_strb_port5,
   ddr_wr_addr_port5,
   ddr_wr_bytes_port5,
   ddr_wr_dv_port5,
   ddr_rd_qos_port5,
   ddr_rd_req_port5,
   ddr_rd_addr_port5,
   ddr_rd_bytes_port5,
   ddr_rd_data_port5,
   ddr_rd_dv_port5
);
   `include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

   input                           rstn;
   input                           sw_clk;

   input [axi_qos_width-1:0]       wr_qos_ddr_acp;
   output                          wr_ack_ddr_acp;
   input[max_burst_bits-1:0]       wr_data_ddr_acp;
   input[max_burst_bytes-1:0]      wr_strb_ddr_acp;
   input[addr_width-1:0]           wr_addr_ddr_acp;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_acp;
   input                           wr_dv_ddr_acp;
   input [axi_qos_width-1:0]       rd_qos_ddr_acp;
   input                           rd_req_ddr_acp;
   input[addr_width-1:0]           rd_addr_ddr_acp;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_acp;
   output[max_burst_bits-1:0]      rd_data_ddr_acp;
   output                          rd_dv_ddr_acp;

   input [axi_qos_width-1:0]       wr_qos_ddr_ace;
   output                          wr_ack_ddr_ace;
   input[max_burst_bits-1:0]       wr_data_ddr_ace;
   input[max_burst_bytes-1:0]      wr_strb_ddr_ace;
   input[addr_width-1:0]           wr_addr_ddr_ace;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_ace;
   input                           wr_dv_ddr_ace;
   input [axi_qos_width-1:0]       rd_qos_ddr_ace;
   input                           rd_req_ddr_ace;
   input[addr_width-1:0]           rd_addr_ddr_ace;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_ace;
   output[max_burst_bits-1:0]      rd_data_ddr_ace;
   output                          rd_dv_ddr_ace;
   
   input [axi_qos_width-1:0]       wr_qos_ddr_gp0;
   output                          wr_ack_ddr_gp0;
   input[max_burst_bits-1:0]       wr_data_ddr_gp0;
   input[max_burst_bytes-1:0]      wr_strb_ddr_gp0;
   input[addr_width-1:0]           wr_addr_ddr_gp0;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_gp0;
   input                           wr_dv_ddr_gp0;
   input [axi_qos_width-1:0]       rd_qos_ddr_gp0;
   input                           rd_req_ddr_gp0;
   input[addr_width-1:0]           rd_addr_ddr_gp0;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_gp0;
   output[max_burst_bits-1:0]      rd_data_ddr_gp0;
   output                          rd_dv_ddr_gp0;

   input [axi_qos_width-1:0]       wr_qos_ddr_gp1;
   output                          wr_ack_ddr_gp1;
   input[max_burst_bits-1:0]       wr_data_ddr_gp1;
   input[max_burst_bytes-1:0]      wr_strb_ddr_gp1;
   input[addr_width-1:0]           wr_addr_ddr_gp1;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_gp1;
   input                           wr_dv_ddr_gp1;
   input [axi_qos_width-1:0]       rd_qos_ddr_gp1;
   input                           rd_req_ddr_gp1;
   input[addr_width-1:0]           rd_addr_ddr_gp1;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_gp1;
   output[max_burst_bits-1:0]      rd_data_ddr_gp1;
   output                          rd_dv_ddr_gp1;

   input [axi_qos_width-1:0]       wr_qos_ddr_gp2;
   output                          wr_ack_ddr_gp2;
   input[max_burst_bits-1:0]       wr_data_ddr_gp2;
   input[max_burst_bytes-1:0]      wr_strb_ddr_gp2;
   input[addr_width-1:0]           wr_addr_ddr_gp2;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_gp2;
   input                           wr_dv_ddr_gp2;
   input [axi_qos_width-1:0]       rd_qos_ddr_gp2;
   input                           rd_req_ddr_gp2;
   input[addr_width-1:0]           rd_addr_ddr_gp2;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_gp2;
   output[max_burst_bits-1:0]      rd_data_ddr_gp2;
   output                          rd_dv_ddr_gp2;

   input [axi_qos_width-1:0]       wr_qos_ddr_gp3;
   output                          wr_ack_ddr_gp3;
   input[max_burst_bits-1:0]       wr_data_ddr_gp3;
   input[max_burst_bytes-1:0]      wr_strb_ddr_gp3;
   input[addr_width-1:0]           wr_addr_ddr_gp3;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_gp3;
   input                           wr_dv_ddr_gp3;
   input [axi_qos_width-1:0]       rd_qos_ddr_gp3;
   input                           rd_req_ddr_gp3;
   input[addr_width-1:0]           rd_addr_ddr_gp3;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_gp3;
   output[max_burst_bits-1:0]      rd_data_ddr_gp3;
   output                          rd_dv_ddr_gp3;

   input [axi_qos_width-1:0]       wr_qos_ddr_gp4;
   output                          wr_ack_ddr_gp4;
   input[max_burst_bits-1:0]       wr_data_ddr_gp4;
   input[max_burst_bytes-1:0]      wr_strb_ddr_gp4;
   input[addr_width-1:0]           wr_addr_ddr_gp4;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_gp4;
   input                           wr_dv_ddr_gp4;
   input [axi_qos_width-1:0]       rd_qos_ddr_gp4;
   input                           rd_req_ddr_gp4;
   input[addr_width-1:0]           rd_addr_ddr_gp4;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_gp4;
   output[max_burst_bits-1:0]      rd_data_ddr_gp4;
   output                          rd_dv_ddr_gp4;

   input [axi_qos_width-1:0]       wr_qos_ddr_gp5;
   output                          wr_ack_ddr_gp5;
   input[max_burst_bits-1:0]       wr_data_ddr_gp5;
   input[max_burst_bytes-1:0]      wr_strb_ddr_gp5;
   input[addr_width-1:0]           wr_addr_ddr_gp5;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_gp5;
   input                           wr_dv_ddr_gp5;
   input [axi_qos_width-1:0]       rd_qos_ddr_gp5;
   input                           rd_req_ddr_gp5;
   input[addr_width-1:0]           rd_addr_ddr_gp5;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_gp5;
   output[max_burst_bits-1:0]      rd_data_ddr_gp5;
   output                          rd_dv_ddr_gp5;

   input [axi_qos_width-1:0]       wr_qos_ddr_gp6;
   output                          wr_ack_ddr_gp6;
   input[max_burst_bits-1:0]       wr_data_ddr_gp6;
   input[max_burst_bytes-1:0]      wr_strb_ddr_gp6;
   input[addr_width-1:0]           wr_addr_ddr_gp6;
   input[max_burst_bytes_width:0]  wr_bytes_ddr_gp6;
   input                           wr_dv_ddr_gp6;
   input [axi_qos_width-1:0]       rd_qos_ddr_gp6;
   input                           rd_req_ddr_gp6;
   input[addr_width-1:0]           rd_addr_ddr_gp6;
   input[max_burst_bytes_width:0]  rd_bytes_ddr_gp6;
   output[max_burst_bits-1:0]      rd_data_ddr_gp6;
   output                          rd_dv_ddr_gp6;

   output [axi_qos_width-1:0]      ddr_wr_qos_port1;
   input                           ddr_wr_ack_port1;
   output[max_burst_bits-1:0]      ddr_wr_data_port1;
   output[max_burst_bytes-1:0]     ddr_wr_strb_port1;
   output[addr_width-1:0]          ddr_wr_addr_port1;
   output[max_burst_bytes_width:0] ddr_wr_bytes_port1;
   output                          ddr_wr_dv_port1;
   output [axi_qos_width-1:0]      ddr_rd_qos_port1;
   output                          ddr_rd_req_port1;
   output[addr_width-1:0]          ddr_rd_addr_port1;
   output[max_burst_bytes_width:0] ddr_rd_bytes_port1;
   input[max_burst_bits-1:0]       ddr_rd_data_port1;
   input                           ddr_rd_dv_port1;

   output [axi_qos_width-1:0]      ddr_wr_qos_port2;
   input                           ddr_wr_ack_port2;
   output[max_burst_bits-1:0]      ddr_wr_data_port2;
   output[max_burst_bytes-1:0]     ddr_wr_strb_port2;
   output[addr_width-1:0]          ddr_wr_addr_port2;
   output[max_burst_bytes_width:0] ddr_wr_bytes_port2;
   output                          ddr_wr_dv_port2;
   output [axi_qos_width-1:0]      ddr_rd_qos_port2;
   output                          ddr_rd_req_port2;
   output[addr_width-1:0]          ddr_rd_addr_port2;
   output[max_burst_bytes_width:0] ddr_rd_bytes_port2;
   input[max_burst_bits-1:0]       ddr_rd_data_port2;
   input                           ddr_rd_dv_port2;

   output [axi_qos_width-1:0]      ddr_wr_qos_port3;
   input                           ddr_wr_ack_port3;
   output[max_burst_bits-1:0]      ddr_wr_data_port3;
   output[max_burst_bytes-1:0]     ddr_wr_strb_port3;
   output[addr_width-1:0]          ddr_wr_addr_port3;
   output[max_burst_bytes_width:0] ddr_wr_bytes_port3;
   output                          ddr_wr_dv_port3;
   output [axi_qos_width-1:0]      ddr_rd_qos_port3;
   output                          ddr_rd_req_port3;
   output[addr_width-1:0]          ddr_rd_addr_port3;
   output[max_burst_bytes_width:0] ddr_rd_bytes_port3;
   input[max_burst_bits-1:0]       ddr_rd_data_port3;
   input                           ddr_rd_dv_port3;

   output [axi_qos_width-1:0]      ddr_wr_qos_port4;
   input                           ddr_wr_ack_port4;
   output[max_burst_bits-1:0]      ddr_wr_data_port4;
   output[max_burst_bytes-1:0]     ddr_wr_strb_port4;
   output[addr_width-1:0]          ddr_wr_addr_port4;
   output[max_burst_bytes_width:0] ddr_wr_bytes_port4;
   output                          ddr_wr_dv_port4;
   output [axi_qos_width-1:0]      ddr_rd_qos_port4;
   output                          ddr_rd_req_port4;
   output[addr_width-1:0]          ddr_rd_addr_port4;
   output[max_burst_bytes_width:0] ddr_rd_bytes_port4;
   input[max_burst_bits-1:0]       ddr_rd_data_port4;
   input                           ddr_rd_dv_port4;

   output [axi_qos_width-1:0]      ddr_wr_qos_port5;
   input                           ddr_wr_ack_port5;
   output[max_burst_bits-1:0]      ddr_wr_data_port5;
   output[max_burst_bytes-1:0]     ddr_wr_strb_port5;
   output[addr_width-1:0]          ddr_wr_addr_port5;
   output[max_burst_bytes_width:0] ddr_wr_bytes_port5;
   output                          ddr_wr_dv_port5;
   output [axi_qos_width-1:0]      ddr_rd_qos_port5;
   output                          ddr_rd_req_port5;
   output[addr_width-1:0]          ddr_rd_addr_port5;
   output[max_burst_bytes_width:0] ddr_rd_bytes_port5;
   input[max_burst_bits-1:0]       ddr_rd_data_port5;
   input                           ddr_rd_dv_port5;

zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr ddr_arb_port1 (
   .sw_clk         (sw_clk),
   .rstn           (rstn),

   .wr_qos_1       (wr_qos_ddr_acp),
   .wr_ack_1       (wr_ack_ddr_acp),
   .wr_data_1      (wr_data_ddr_acp),
   .wr_strb_1      (wr_strb_ddr_acp),
   .wr_addr_1      (wr_addr_ddr_acp),
   .wr_bytes_1     (wr_bytes_ddr_acp),
   .wr_dv_1        (wr_dv_ddr_acp),
   .rd_qos_1       (rd_qos_ddr_acp),
   .rd_req_1       (rd_req_ddr_acp),
   .rd_addr_1      (rd_addr_ddr_acp),
   .rd_bytes_1     (rd_bytes_ddr_acp),
   .rd_data_1      (rd_data_ddr_acp),
   .rd_dv_1        (rd_dv_ddr_acp),

   .wr_qos_2       (wr_qos_ddr_ace),
   .wr_ack_2       (wr_ack_ddr_ace),
   .wr_data_2      (wr_data_ddr_ace),
   .wr_strb_2      (wr_strb_ddr_ace),
   .wr_addr_2      (wr_addr_ddr_ace),
   .wr_bytes_2     (wr_bytes_ddr_ace),
   .wr_dv_2        (wr_dv_ddr_ace),
   .rd_qos_2       (rd_qos_ddr_ace),
   .rd_req_2       (rd_req_ddr_ace),
   .rd_addr_2      (rd_addr_ddr_ace),
   .rd_bytes_2     (rd_bytes_ddr_ace),
   .rd_data_2      (rd_data_ddr_ace),
   .rd_dv_2        (rd_dv_ddr_ace),

   .wr_qos         (ddr_wr_qos_port1),
   .wr_ack         (ddr_wr_ack_port1),
   .wr_data        (ddr_wr_data_port1),
   .wr_strb        (ddr_wr_strb_port1),
   .wr_addr        (ddr_wr_addr_port1),
   .wr_bytes       (ddr_wr_bytes_port1),
   .wr_dv          (ddr_wr_dv_port1),
   .rd_qos         (ddr_rd_qos_port1),
   .rd_req         (ddr_rd_req_port1),
   .rd_addr        (ddr_rd_addr_port1),
   .rd_bytes       (ddr_rd_bytes_port1),
   .rd_data        (ddr_rd_data_port1),
   .rd_dv          (ddr_rd_dv_port1)
);


   wire                           net_wr_qos_ddr_gp01;
   wire                           net_wr_ack_ddr_gp01;
   wire [max_burst_bits-1:0]      net_wr_data_ddr_gp01;
   wire [max_burst_bytes-1:0]     net_wr_strb_ddr_gp01;
   wire [addr_width-1:0]          net_wr_addr_ddr_gp01;
   wire [max_burst_bytes_width:0] net_wr_bytes_ddr_gp01;
   wire                           net_wr_dv_ddr_gp01;
   wire                           net_rd_qos_ddr_gp01;
   wire                           net_rd_req_ddr_gp01;
   wire [addr_width-1:0]          net_rd_addr_ddr_gp01;
   wire [max_burst_bytes_width:0] net_rd_bytes_ddr_gp01;
   wire [max_burst_bits-1:0]      net_rd_data_ddr_gp01;
   wire                           net_rd_dv_ddr_gp01;

 zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr ddr_arb_gp01 (
   .sw_clk         (sw_clk),
   .rstn           (rstn),

   .wr_qos_1       (wr_qos_ddr_gp0),
   .wr_ack_1       (wr_ack_ddr_gp0),
   .wr_data_1      (wr_data_ddr_gp0),
   .wr_strb_1      (wr_strb_ddr_gp0),
   .wr_addr_1      (wr_addr_ddr_gp0),
   .wr_bytes_1     (wr_bytes_ddr_gp0),
   .wr_dv_1        (wr_dv_ddr_gp0),
   .rd_qos_1       (rd_qos_ddr_gp0),
   .rd_req_1       (rd_req_ddr_gp0),
   .rd_addr_1      (rd_addr_ddr_gp0),
   .rd_bytes_1     (rd_bytes_ddr_gp0),
   .rd_data_1      (rd_data_ddr_gp0),
   .rd_dv_1        (rd_dv_ddr_gp0),

   .wr_qos_2        (wr_qos_ddr_gp1),
   .wr_ack_2       (wr_ack_ddr_gp1),
   .wr_data_2      (wr_data_ddr_gp1),
   .wr_strb_2      (wr_strb_ddr_gp1),
   .wr_addr_2      (wr_addr_ddr_gp1),
   .wr_bytes_2     (wr_bytes_ddr_gp1),
   .wr_dv_2        (wr_dv_ddr_gp1),
   .rd_qos_2       (rd_qos_ddr_gp1),
   .rd_req_2       (rd_req_ddr_gp1),
   .rd_addr_2      (rd_addr_ddr_gp1),
   .rd_bytes_2     (rd_bytes_ddr_gp1),
   .rd_data_2      (rd_data_ddr_gp1),
   .rd_dv_2        (rd_dv_ddr_gp1),

   .wr_qos         (net_wr_qos_ddr_gp01),
   .wr_ack         (net_wr_ack_ddr_gp01),
   .wr_data        (net_wr_data_ddr_gp01),
   .wr_strb        (net_wr_strb_ddr_gp01),
   .wr_addr        (net_wr_addr_ddr_gp01),
   .wr_bytes       (net_wr_bytes_ddr_gp01),
   .wr_dv          (net_wr_dv_ddr_gp01),
   .rd_qos         (net_rd_qos_ddr_gp01),
   .rd_req         (net_rd_req_ddr_gp01),
   .rd_addr        (net_rd_addr_ddr_gp01),
   .rd_bytes       (net_rd_bytes_ddr_gp01),
   .rd_data        (net_rd_data_ddr_gp01),
   .rd_dv          (net_rd_dv_ddr_gp01)
);

 
 zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr ddr_arb_port2 (
   .sw_clk        (sw_clk),
   .rstn          (rstn),

   .wr_qos_1      (net_wr_qos_ddr_gp01),
   .wr_ack_1      (net_wr_ack_ddr_gp01),
   .wr_data_1     (net_wr_data_ddr_gp01),
   .wr_strb_1     (net_wr_strb_ddr_gp01),
   .wr_addr_1     (net_wr_addr_ddr_gp01),
   .wr_bytes_1    (net_wr_bytes_ddr_gp01),
   .wr_dv_1       (net_wr_dv_ddr_gp01),
   .rd_qos_1      (net_rd_qos_ddr_gp01),
   .rd_req_1      (net_rd_req_ddr_gp01),
   .rd_addr_1     (net_rd_addr_ddr_gp01),
   .rd_bytes_1    (net_rd_bytes_ddr_gp01),
   .rd_data_1     (net_rd_data_ddr_gp01),
   .rd_dv_1       (net_rd_dv_ddr_gp01),

   .wr_qos_2       (wr_qos_ddr_gp6),
   .wr_ack_2      (wr_ack_ddr_gp6),
   .wr_data_2     (wr_data_ddr_gp6),
   .wr_strb_2     (wr_strb_ddr_gp6),
   .wr_addr_2     (wr_addr_ddr_gp6),
   .wr_bytes_2    (wr_bytes_ddr_gp6),
   .wr_dv_2       (wr_dv_ddr_gp6),
   .rd_qos_2      (rd_qos_ddr_gp6),
   .rd_req_2      (rd_req_ddr_gp6),
   .rd_addr_2     (rd_addr_ddr_gp6),
   .rd_bytes_2    (rd_bytes_ddr_gp6),
   .rd_data_2     (rd_data_ddr_gp6),
   .rd_dv_2       (rd_dv_ddr_gp6),

   .wr_qos        (ddr_wr_qos_port2),
   .wr_ack        (ddr_wr_ack_port2),
   .wr_data       (ddr_wr_data_port2),
   .wr_strb       (ddr_wr_strb_port2),
   .wr_addr       (ddr_wr_addr_port2),
   .wr_bytes      (ddr_wr_bytes_port2),
   .wr_dv         (ddr_wr_dv_port2),
   .rd_qos        (ddr_rd_qos_port2),
   .rd_req        (ddr_rd_req_port2),
   .rd_addr       (ddr_rd_addr_port2),
   .rd_bytes      (ddr_rd_bytes_port2),
   .rd_data       (ddr_rd_data_port2),
   .rd_dv         (ddr_rd_dv_port2)

);

  //ddr_arb_port3
  assign ddr_wr_qos_port3   = wr_qos_ddr_gp2;
  assign wr_ack_ddr_gp2     = ddr_wr_ack_port3;
  assign ddr_wr_data_port3  = wr_data_ddr_gp2;
  assign ddr_wr_strb_port3  = wr_strb_ddr_gp2;
  assign ddr_wr_addr_port3  = wr_addr_ddr_gp2;
  assign ddr_wr_bytes_port3 = wr_bytes_ddr_gp2;
  assign ddr_wr_dv_port3    = wr_dv_ddr_gp2;
  assign ddr_rd_qos_port3   = rd_qos_ddr_gp2;
  assign ddr_rd_req_port3   = rd_req_ddr_gp2;
  assign ddr_rd_addr_port3  = rd_addr_ddr_gp2;
  assign ddr_rd_bytes_port3 = rd_bytes_ddr_gp2;
  assign rd_data_ddr_gp2    = ddr_rd_data_port3;
  assign rd_dv_ddr_gp2      = ddr_rd_dv_port3;

 //ddr_arb_port4
 zynq_ultra_ps_e_vip_v1_0_6_arb_rd_wr ddr_arb_port4 (
   .sw_clk         (sw_clk),
   .rstn           (rstn),

   .wr_qos_1       (wr_qos_ddr_gp3),
   .wr_ack_1       (wr_ack_ddr_gp3),
   .wr_data_1      (wr_data_ddr_gp3),
   .wr_strb_1      (wr_strb_ddr_gp3),
   .wr_addr_1      (wr_addr_ddr_gp3),
   .wr_bytes_1     (wr_bytes_ddr_gp3),
   .wr_dv_1        (wr_dv_ddr_gp3),
   .rd_qos_1       (rd_qos_ddr_gp3),
   .rd_req_1       (rd_req_ddr_gp3),
   .rd_addr_1      (rd_addr_ddr_gp3),
   .rd_bytes_1     (rd_bytes_ddr_gp3),
   .rd_data_1      (rd_data_ddr_gp3),
   .rd_dv_1        (rd_dv_ddr_gp3),

   .wr_qos_2       (wr_qos_ddr_gp4),
   .wr_ack_2       (wr_ack_ddr_gp4),
   .wr_data_2      (wr_data_ddr_gp4),
   .wr_strb_2      (wr_strb_ddr_gp4),
   .wr_addr_2      (wr_addr_ddr_gp4),
   .wr_bytes_2     (wr_bytes_ddr_gp4),
   .wr_dv_2        (wr_dv_ddr_gp4),
   .rd_qos_2       (rd_qos_ddr_gp4),
   .rd_req_2       (rd_req_ddr_gp4),
   .rd_addr_2      (rd_addr_ddr_gp4),
   .rd_bytes_2     (rd_bytes_ddr_gp4),
   .rd_data_2      (rd_data_ddr_gp4),
   .rd_dv_2        (rd_dv_ddr_gp4),

   .wr_qos         (ddr_wr_qos_port4),
   .wr_ack         (ddr_wr_ack_port4),
   .wr_data        (ddr_wr_data_port4),
   .wr_strb        (ddr_wr_strb_port4),
   .wr_addr        (ddr_wr_addr_port4),
   .wr_bytes       (ddr_wr_bytes_port4),
   .wr_dv          (ddr_wr_dv_port4),
   .rd_qos         (ddr_rd_qos_port4),
   .rd_req         (ddr_rd_req_port4),
   .rd_addr        (ddr_rd_addr_port4),
   .rd_bytes       (ddr_rd_bytes_port4),
   .rd_data        (ddr_rd_data_port4),
   .rd_dv          (ddr_rd_dv_port4)
);

    //ddr_arb_port5
  assign ddr_wr_qos_port5   = wr_qos_ddr_gp5;
  assign wr_ack_ddr_gp5     = ddr_wr_ack_port5;
  assign ddr_wr_data_port5  = wr_data_ddr_gp5;
  assign ddr_wr_strb_port5  = wr_strb_ddr_gp5;
  assign ddr_wr_addr_port5  = wr_addr_ddr_gp5;
  assign ddr_wr_bytes_port5 = wr_bytes_ddr_gp5;
  assign ddr_wr_dv_port5    = wr_dv_ddr_gp5;
  assign ddr_rd_qos_port5   = rd_qos_ddr_gp5;
  assign ddr_rd_req_port5   = rd_req_ddr_gp5;
  assign ddr_rd_addr_port5  = rd_addr_ddr_gp5;
  assign ddr_rd_bytes_port5 = rd_bytes_ddr_gp5;
  assign rd_data_ddr_gp5    = ddr_rd_data_port5;
  assign rd_dv_ddr_gp5      = ddr_rd_dv_port5;

endmodule


/************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_gen_reset.sv
 *
 * Date : 2015-16
 *
 * Description : Module that generates FPGA_RESETs and synchronizes RESETs to the
 *               respective clocks.
 *****************************************************************************/
 `timescale 1ns/1ps
module zynq_ultra_ps_e_vip_v1_0_6_gen_reset(
 por_rst_n_dummy,
 sys_rst_n_dummy,
 rst_out_n,

 m_axi_gp0_clk,
 m_axi_gp1_clk,
 m_axi_gp2_clk,
 s_axi_gp0_clk,
 s_axi_gp1_clk,
 s_axi_gp2_clk,
 s_axi_gp3_clk,
 s_axi_gp4_clk,
 s_axi_gp5_clk,
 s_axi_gp6_clk,
 s_axi_acp_clk,
 s_axi_ace_clk,

 m_axi_gp0_rstn,
 m_axi_gp1_rstn,
 m_axi_gp2_rstn,
 s_axi_gp0_rstn,
 s_axi_gp1_rstn,
 s_axi_gp2_rstn,
 s_axi_gp3_rstn,
 s_axi_gp4_rstn,
 s_axi_gp5_rstn,
 s_axi_gp6_rstn,
 s_axi_acp_rstn,
 s_axi_ace_rstn,

 fclk_reset3_n,
 fclk_reset2_n,
 fclk_reset1_n,
 fclk_reset0_n
);

input por_rst_n_dummy;
input sys_rst_n_dummy;

input m_axi_gp0_clk;
input m_axi_gp1_clk;
input m_axi_gp2_clk;
input s_axi_gp0_clk;
input s_axi_gp1_clk;
input s_axi_gp2_clk;
input s_axi_gp3_clk;
input s_axi_gp4_clk;
input s_axi_gp5_clk;
input s_axi_gp6_clk;
input s_axi_acp_clk;
input s_axi_ace_clk;

output  reg m_axi_gp0_rstn;
output  reg m_axi_gp1_rstn;
output  reg m_axi_gp2_rstn;
output  reg s_axi_gp0_rstn;
output  reg s_axi_gp1_rstn;
output  reg s_axi_gp2_rstn;
output  reg s_axi_gp3_rstn;
output  reg s_axi_gp4_rstn;
output  reg s_axi_gp5_rstn;
output  reg s_axi_gp6_rstn;
output  reg s_axi_acp_rstn;
output  reg s_axi_ace_rstn;

output rst_out_n;
output fclk_reset3_n;
output fclk_reset2_n;
output fclk_reset1_n;
output fclk_reset0_n;

bit [3:0] fabric_rst_n;
reg por_rst_n,sys_rst_n;

assign rst_out_n = por_rst_n & sys_rst_n;

assign fclk_reset0_n = !fabric_rst_n[0];
assign fclk_reset1_n = !fabric_rst_n[1];
assign fclk_reset2_n = !fabric_rst_n[2];
assign fclk_reset3_n = !fabric_rst_n[3];

task fpga_soft_reset;
input[3:0] reset_ctrl;
 begin 
  fabric_rst_n[0] = reset_ctrl[0];
  fabric_rst_n[1] = reset_ctrl[1];
  fabric_rst_n[2] = reset_ctrl[2];
  fabric_rst_n[3] = reset_ctrl[3];
  
 end
endtask


task por_srstb_reset;
input por_reset_ctrl;
 begin 
  por_rst_n = por_reset_ctrl;
  sys_rst_n = por_reset_ctrl;
 end
endtask

//always@(negedge por_rst_n or negedge sys_rst_n) fabric_rst_n = 4'hf;

always@(posedge m_axi_gp0_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      m_axi_gp0_rstn = 1'b0;
	else
      m_axi_gp0_rstn = 1'b1;
  end

always@(posedge m_axi_gp1_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      m_axi_gp1_rstn = 1'b0;
	else
      m_axi_gp1_rstn = 1'b1;
  end

always@(posedge m_axi_gp2_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      m_axi_gp2_rstn = 1'b0;
	else
      m_axi_gp2_rstn = 1'b1;
  end

always@(posedge s_axi_gp0_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_gp0_rstn = 1'b0;
	else
      s_axi_gp0_rstn = 1'b1;
  end

always@(posedge s_axi_gp1_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_gp1_rstn = 1'b0;
	else
      s_axi_gp1_rstn = 1'b1;
  end

always@(posedge s_axi_gp2_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_gp2_rstn = 1'b0;
	else
      s_axi_gp2_rstn = 1'b1;
  end

always@(posedge s_axi_gp3_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_gp3_rstn = 1'b0;
	else
      s_axi_gp3_rstn = 1'b1;
  end

always@(posedge s_axi_gp4_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_gp4_rstn = 1'b0;
	else
      s_axi_gp4_rstn = 1'b1;
  end

always@(posedge s_axi_gp5_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_gp5_rstn = 1'b0;
	else
      s_axi_gp5_rstn = 1'b1;
  end

always@(posedge s_axi_gp6_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_gp6_rstn = 1'b0;
	else
      s_axi_gp6_rstn = 1'b1;
  end

always@(posedge s_axi_acp_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_acp_rstn = 1'b0;
	else
      s_axi_acp_rstn = 1'b1;
  end

always@(posedge s_axi_ace_clk or negedge (por_rst_n & sys_rst_n))
  begin 
    if (!(por_rst_n & sys_rst_n))
      s_axi_ace_rstn = 1'b0;
	else
      s_axi_ace_rstn = 1'b1;
  end


always@(*) begin
  if ((por_rst_n!= 1'b0) && (por_rst_n!= 1'b1) && (sys_rst_n !=  1'b0) && (sys_rst_n != 1'b1)) begin
     $display(" Error:zynq_ultra_ps_e_vip_v1_0_6_gen_reset.  PS_PORB and PS_SRSTB must be driven to known state");
     $finish();
  end
end

endmodule


/***************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_gen_clock.sv
 *
 * Date : 2015-16
 *
 * Description : Module that generates FCLK clocks and internal clock for Zynq BFM. 
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_gen_clock(
 ps_clk, 
 sw_clk,
 
 fclk_clk3,
 fclk_clk2,
 fclk_clk1,
 fclk_clk0
);

input  ps_clk;
output sw_clk;

output fclk_clk3;
output fclk_clk2;
output fclk_clk1;
output fclk_clk0;

parameter freq_clk3 = 50;
parameter freq_clk2 = 50;
parameter freq_clk1 = 50;
parameter freq_clk0 = 50;

bit clk0 ;
bit clk1 ;
bit clk2 ;
bit clk3 ;
reg sw_clk = 1'b0;

assign fclk_clk0 = clk0;
assign fclk_clk1 = clk1;
assign fclk_clk2 = clk2;
assign fclk_clk3 = clk3;
 
real clk3_p = (1000.00/freq_clk3)/2;
real clk2_p = (1000.00/freq_clk2)/2;
real clk1_p = (1000.00/freq_clk1)/2;
real clk0_p = (1000.00/freq_clk0)/2;

always #(clk3_p) clk3 = !clk3;
always #(clk2_p) clk2 = !clk2;
always #(clk1_p) clk1 = !clk1;
always #(clk0_p) clk0 = !clk0;

always #(0.5) sw_clk = !sw_clk;


endmodule


/********************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_ddrc.sv
 *
 * Date : 2015-16
 *
 * Description : Module that acts as controller for sparse memory (DDR).
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6_ddrc(
 rstn,
 sw_clk,

/* Goes to port 0 of DDR */
 ddr_wr_ack_port0,
 ddr_wr_dv_port0,
 ddr_rd_req_port0,
 ddr_rd_dv_port0,
 ddr_wr_addr_port0,
 ddr_wr_data_port0,
 ddr_wr_strb_port0,
 ddr_wr_bytes_port0,
 ddr_rd_addr_port0,
 ddr_rd_data_port0,
 ddr_rd_bytes_port0,
 ddr_wr_qos_port0,
 ddr_rd_qos_port0,

/* Goes to port 1 of DDR */
 ddr_wr_ack_port1,
 ddr_wr_dv_port1,
 ddr_rd_req_port1,
 ddr_rd_dv_port1,
 ddr_wr_addr_port1,
 ddr_wr_data_port1,
 ddr_wr_strb_port1,
 ddr_wr_bytes_port1,
 ddr_rd_addr_port1,
 ddr_rd_data_port1,
 ddr_rd_bytes_port1,
 ddr_wr_qos_port1,
 ddr_rd_qos_port1,

/* Goes to port2 of DDR */
 ddr_wr_ack_port2,
 ddr_wr_dv_port2,
 ddr_rd_req_port2,
 ddr_rd_dv_port2,
 ddr_wr_addr_port2,
 ddr_wr_data_port2,
 ddr_wr_strb_port2,
 ddr_wr_bytes_port2,
 ddr_rd_addr_port2,
 ddr_rd_data_port2,
 ddr_rd_bytes_port2,
 ddr_wr_qos_port2,
 ddr_rd_qos_port2,

/* Goes to port3 of DDR */
 ddr_wr_ack_port3,
 ddr_wr_dv_port3,
 ddr_rd_req_port3,
 ddr_rd_dv_port3,
 ddr_wr_addr_port3,
 ddr_wr_data_port3,
 ddr_wr_strb_port3,
 ddr_wr_bytes_port3,
 ddr_rd_addr_port3,
 ddr_rd_data_port3,
 ddr_rd_bytes_port3,
 ddr_wr_qos_port3,
 ddr_rd_qos_port3,

 /* Goes to port4 of DDR */
 ddr_wr_ack_port4,
 ddr_wr_dv_port4,
 ddr_rd_req_port4,
 ddr_rd_dv_port4,
 ddr_wr_addr_port4,
 ddr_wr_data_port4,
 ddr_wr_strb_port4,
 ddr_wr_bytes_port4,
 ddr_rd_addr_port4,
 ddr_rd_data_port4,
 ddr_rd_bytes_port4,
 ddr_wr_qos_port4,
 ddr_rd_qos_port4,

 /* Goes to port5 of DDR */
 ddr_wr_ack_port5,
 ddr_wr_dv_port5,
 ddr_rd_req_port5,
 ddr_rd_dv_port5,
 ddr_wr_addr_port5,
 ddr_wr_data_port5,
 ddr_wr_strb_port5,
 ddr_wr_bytes_port5,
 ddr_rd_addr_port5,
 ddr_rd_data_port5,
 ddr_rd_bytes_port5,
 ddr_wr_qos_port5,
 ddr_rd_qos_port5

);

`include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

input rstn;
input sw_clk;

output ddr_wr_ack_port0;
input ddr_wr_dv_port0;
input ddr_rd_req_port0;
output ddr_rd_dv_port0;
input[addr_width-1:0] ddr_wr_addr_port0;
input[max_burst_bits-1:0] ddr_wr_data_port0;
input[max_burst_bytes-1:0] ddr_wr_strb_port0;
input[max_burst_bytes_width:0] ddr_wr_bytes_port0;
input[addr_width-1:0] ddr_rd_addr_port0;
output[max_burst_bits-1:0] ddr_rd_data_port0;
input[max_burst_bytes_width:0] ddr_rd_bytes_port0;
input [axi_qos_width-1:0] ddr_wr_qos_port0;
input [axi_qos_width-1:0] ddr_rd_qos_port0;

output ddr_wr_ack_port1;
input ddr_wr_dv_port1;
input ddr_rd_req_port1;
output ddr_rd_dv_port1;
input[addr_width-1:0] ddr_wr_addr_port1;
input[max_burst_bits-1:0] ddr_wr_data_port1;
input[max_burst_bytes-1:0] ddr_wr_strb_port1;
input[max_burst_bytes_width:0] ddr_wr_bytes_port1;
input[addr_width-1:0] ddr_rd_addr_port1;
output[max_burst_bits-1:0] ddr_rd_data_port1;
input[max_burst_bytes_width:0] ddr_rd_bytes_port1;
input[axi_qos_width-1:0] ddr_wr_qos_port1;
input[axi_qos_width-1:0] ddr_rd_qos_port1;

output ddr_wr_ack_port2;
input ddr_wr_dv_port2;
input ddr_rd_req_port2;
output ddr_rd_dv_port2;
input[addr_width-1:0] ddr_wr_addr_port2;
input[max_burst_bits-1:0] ddr_wr_data_port2;
input[max_burst_bytes-1:0] ddr_wr_strb_port2;
input[max_burst_bytes_width:0] ddr_wr_bytes_port2;
input[addr_width-1:0] ddr_rd_addr_port2;
output[max_burst_bits-1:0] ddr_rd_data_port2;
input[max_burst_bytes_width:0] ddr_rd_bytes_port2;
input[axi_qos_width-1:0] ddr_wr_qos_port2;
input[axi_qos_width-1:0] ddr_rd_qos_port2;

output ddr_wr_ack_port3;
input ddr_wr_dv_port3;
input ddr_rd_req_port3;
output ddr_rd_dv_port3;
input[addr_width-1:0] ddr_wr_addr_port3;
input[max_burst_bits-1:0] ddr_wr_data_port3;
input[max_burst_bytes-1:0] ddr_wr_strb_port3;
input[max_burst_bytes_width:0] ddr_wr_bytes_port3;
input[addr_width-1:0] ddr_rd_addr_port3;
output[max_burst_bits-1:0] ddr_rd_data_port3;
input[max_burst_bytes_width:0] ddr_rd_bytes_port3;
input[axi_qos_width-1:0] ddr_wr_qos_port3;
input[axi_qos_width-1:0] ddr_rd_qos_port3;

output ddr_wr_ack_port4;
input ddr_wr_dv_port4;
input ddr_rd_req_port4;
output ddr_rd_dv_port4;
input[addr_width-1:0] ddr_wr_addr_port4;
input[max_burst_bits-1:0] ddr_wr_data_port4;
input[max_burst_bytes-1:0] ddr_wr_strb_port4;
input[max_burst_bytes_width:0] ddr_wr_bytes_port4;
input[addr_width-1:0] ddr_rd_addr_port4;
output[max_burst_bits-1:0] ddr_rd_data_port4;
input[max_burst_bytes_width:0] ddr_rd_bytes_port4;
input[axi_qos_width-1:0] ddr_wr_qos_port4;
input[axi_qos_width-1:0] ddr_rd_qos_port4;

output ddr_wr_ack_port5;
input ddr_wr_dv_port5;
input ddr_rd_req_port5;
output ddr_rd_dv_port5;
input[addr_width-1:0] ddr_wr_addr_port5;
input[max_burst_bits-1:0] ddr_wr_data_port5;
input[max_burst_bytes-1:0] ddr_wr_strb_port5;
input[max_burst_bytes_width:0] ddr_wr_bytes_port5;
input[addr_width-1:0] ddr_rd_addr_port5;
output[max_burst_bits-1:0] ddr_rd_data_port5;
input[max_burst_bytes_width:0] ddr_rd_bytes_port5;
input[axi_qos_width-1:0] ddr_wr_qos_port5;
input[axi_qos_width-1:0] ddr_rd_qos_port5;

wire [axi_qos_width-1:0] wr_qos;
wire wr_req;
wire [max_burst_bits-1:0] wr_data;
wire [max_burst_bytes-1:0] wr_strb;
wire [addr_width-1:0] wr_addr;
wire [max_burst_bytes_width:0] wr_bytes;
reg wr_ack;

wire [axi_qos_width-1:0] rd_qos;
reg [max_burst_bits-1:0] rd_data;
wire [addr_width-1:0] rd_addr;
wire [max_burst_bytes_width:0] rd_bytes;
reg rd_dv;
wire rd_req;

zynq_ultra_ps_e_vip_v1_0_6_arb_wr_6 ddr_write_ports (
 .rstn(rstn),
 .sw_clk(sw_clk),
   
 .prt_qos0(ddr_wr_qos_port0),
 .prt_qos1(ddr_wr_qos_port1),
 .prt_qos2(ddr_wr_qos_port2),
 .prt_qos3(ddr_wr_qos_port3),
 .prt_qos4(ddr_wr_qos_port4),
 .prt_qos5(ddr_wr_qos_port5),
   
 .prt_dv0(ddr_wr_dv_port0),
 .prt_dv1(ddr_wr_dv_port1),
 .prt_dv2(ddr_wr_dv_port2),
 .prt_dv3(ddr_wr_dv_port3),
 .prt_dv4(ddr_wr_dv_port4),
 .prt_dv5(ddr_wr_dv_port5),
   
 .prt_data0(ddr_wr_data_port0),
 .prt_data1(ddr_wr_data_port1),
 .prt_data2(ddr_wr_data_port2),
 .prt_data3(ddr_wr_data_port3),
 .prt_data4(ddr_wr_data_port4),
 .prt_data5(ddr_wr_data_port5),
   
 .prt_strb0(ddr_wr_strb_port0),
 .prt_strb1(ddr_wr_strb_port1),
 .prt_strb2(ddr_wr_strb_port2),
 .prt_strb3(ddr_wr_strb_port3),
 .prt_strb4(ddr_wr_strb_port4),
 .prt_strb5(ddr_wr_strb_port5),
   
 .prt_addr0(ddr_wr_addr_port0),
 .prt_addr1(ddr_wr_addr_port1),
 .prt_addr2(ddr_wr_addr_port2),
 .prt_addr3(ddr_wr_addr_port3),
 .prt_addr4(ddr_wr_addr_port4),
 .prt_addr5(ddr_wr_addr_port5),
   
 .prt_bytes0(ddr_wr_bytes_port0),
 .prt_bytes1(ddr_wr_bytes_port1),
 .prt_bytes2(ddr_wr_bytes_port2),
 .prt_bytes3(ddr_wr_bytes_port3),
 .prt_bytes4(ddr_wr_bytes_port4),
 .prt_bytes5(ddr_wr_bytes_port5),
   
 .prt_ack0(ddr_wr_ack_port0),
 .prt_ack1(ddr_wr_ack_port1),
 .prt_ack2(ddr_wr_ack_port2),
 .prt_ack3(ddr_wr_ack_port3),
 .prt_ack4(ddr_wr_ack_port4),
 .prt_ack5(ddr_wr_ack_port5),
   
 .prt_qos(wr_qos),
 .prt_req(wr_req),
 .prt_data(wr_data),
 .prt_strb(wr_strb),
 .prt_addr(wr_addr),
 .prt_bytes(wr_bytes),
 .prt_ack(wr_ack)

);

zynq_ultra_ps_e_vip_v1_0_6_arb_rd_6 ddr_read_ports (
 .rstn(rstn),
 .sw_clk(sw_clk),
   
 .prt_qos0(ddr_rd_qos_port0),
 .prt_qos1(ddr_rd_qos_port1),
 .prt_qos2(ddr_rd_qos_port2),
 .prt_qos3(ddr_rd_qos_port3),
 .prt_qos4(ddr_rd_qos_port4),
 .prt_qos5(ddr_rd_qos_port5),
   
 .prt_req0(ddr_rd_req_port0),
 .prt_req1(ddr_rd_req_port1),
 .prt_req2(ddr_rd_req_port2),
 .prt_req3(ddr_rd_req_port3),
 .prt_req4(ddr_rd_req_port4),
 .prt_req5(ddr_rd_req_port5),
   
 .prt_data0(ddr_rd_data_port0),
 .prt_data1(ddr_rd_data_port1),
 .prt_data2(ddr_rd_data_port2),
 .prt_data3(ddr_rd_data_port3),
 .prt_data4(ddr_rd_data_port4),
 .prt_data5(ddr_rd_data_port5),
   
 .prt_addr0(ddr_rd_addr_port0),
 .prt_addr1(ddr_rd_addr_port1),
 .prt_addr2(ddr_rd_addr_port2),
 .prt_addr3(ddr_rd_addr_port3),
 .prt_addr4(ddr_rd_addr_port4),
 .prt_addr5(ddr_rd_addr_port5),
   
 .prt_bytes0(ddr_rd_bytes_port0),
 .prt_bytes1(ddr_rd_bytes_port1),
 .prt_bytes2(ddr_rd_bytes_port2),
 .prt_bytes3(ddr_rd_bytes_port3),
 .prt_bytes4(ddr_rd_bytes_port4),
 .prt_bytes5(ddr_rd_bytes_port5),
   
 .prt_dv0(ddr_rd_dv_port0),
 .prt_dv1(ddr_rd_dv_port1),
 .prt_dv2(ddr_rd_dv_port2),
 .prt_dv3(ddr_rd_dv_port3),
 .prt_dv4(ddr_rd_dv_port4),
 .prt_dv5(ddr_rd_dv_port5),
   
 .prt_qos(rd_qos),
 .prt_req(rd_req),
 .prt_data(rd_data),
 .prt_addr(rd_addr),
 .prt_bytes(rd_bytes),
 .prt_dv(rd_dv)

);

zynq_ultra_ps_e_vip_v1_0_6_sparse_mem ddr();

reg [1:0] state;
always@(posedge sw_clk or negedge rstn)
begin
if(!rstn) begin
 wr_ack <= 0; 
 rd_dv <= 0;
 state <= 2'd0;
end else begin
 case(state) 
 0:begin
     state <= 0;
     wr_ack <= 0;
     rd_dv <= 0;
     if(wr_req) begin
	   // $display("wr_addr %0h,wr_data %0h,wr_bytes %0h , wr_strb %0h ",wr_addr,wr_data,wr_bytes,wr_strb);
       ddr.write_mem(wr_data , wr_addr, wr_bytes, wr_strb); 
       // ddr.write_mem(wr_data , wr_addr, wr_bytes, 16'hFFFF); 
       wr_ack <= 1;
       state <= 1;
     end
     if(rd_req) begin
       ddr.read_mem(rd_data,rd_addr, rd_bytes); 
	   // $display("rd_addr %0h,rd_data %0h  , rd_bytes %0h ",rd_addr,rd_data,rd_bytes);
       rd_dv <= 1;
       state <= 1;
     end

   end
 1:begin
       wr_ack <= 0;
       rd_dv  <= 0;
       state <= 0;
   end 

 endcase
end /// if
end// always

endmodule 


/********************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_axi_slave.sv
 *
 * Date : 2012-11
 *
 * Description : Model that acts as PS AXI Slave  port interface. 
 *               It uses AXI3 Slave  BFM
 *****************************************************************************/
 `timescale 1ns/1ps
 import axi_vip_pkg::*;

module zynq_ultra_ps_e_vip_v1_0_6_axi_slave (
  S_RESETN,

  S_ARREADY,
  S_AWREADY,
  S_BVALID,
  S_RLAST,
  S_RVALID,
  S_WREADY,
  S_BRESP,
  S_RRESP,
  S_RDATA,
  S_BID,
  S_RID,
  S_ACLK,
  S_ARVALID,
  S_AWVALID,
  S_BREADY,
  S_RREADY,
  S_WLAST,
  S_WVALID,
  S_ARBURST,
  S_ARLOCK,
  S_ARSIZE,
  S_AWBURST,
  S_AWLOCK,
  S_AWSIZE,
  S_ARPROT,
  S_AWPROT,
  S_ARADDR,
  S_AWADDR,
  S_WDATA,
  S_ARCACHE,
  S_ARLEN,
  S_AWCACHE,
  S_AWLEN,
  S_WSTRB,
  S_ARID,
  S_AWID,
  S_AWQOS,
  S_ARQOS,
  S_AWREGION,
  S_ARREGION,
  S_AWUSER,
  S_WUSER,
  S_BUSER,
  S_ARUSER,
  S_RUSER,
  SW_CLK,
  WR_DATA_ACK_OCM,
  WR_DATA_ACK_DDR,
  WR_ADDR,
  WR_DATA,
  WR_DATA_STRB,
  WR_BYTES,
  WR_DATA_VALID_OCM,
  WR_DATA_VALID_DDR,
  WR_QOS,
  RD_QOS, 
  RD_REQ_DDR,
  RD_REQ_OCM,
  RD_REQ_REG,
  RD_ADDR,
  RD_DATA_OCM,
  RD_DATA_DDR,
  RD_DATA_REG,
  RD_BYTES,
  RD_DATA_VALID_OCM,
  RD_DATA_VALID_DDR,
  RD_DATA_VALID_REG

);
  parameter enable_this_port = 0;  
  parameter slave_name = "Slave";
  parameter data_bus_width = 32;
  parameter address_bus_width = 40;
  parameter id_bus_width = 6;
  parameter awuser_bus_width = 1;
  parameter aruser_bus_width = 1;
  parameter ruser_bus_width  = 1;
  parameter wuser_bus_width  = 1;
  parameter buser_bus_width  = 1;
  parameter max_outstanding_transactions = 25;
  parameter exclusive_access_supported = 0;
  parameter max_wr_outstanding_transactions = 25;
  parameter max_rd_outstanding_transactions = 25;
  parameter region_bus_width = 4;
  
  `include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

  /* Local parameters only for this module */
  /* Internal counters that are used as Read/Write pointers to the fifo's that store all the transaction info on all channles.
     This parameter is used to define the width of these pointers --> depending on Maximum outstanding transactions supported.
     1-bit extra width than the no.of.bits needed to represent the outstanding transactions
     Extra bit helps in generating the empty and full flags */
  parameter int_wr_cntr_width = clogb2(max_wr_outstanding_transactions+1);
  parameter int_rd_cntr_width = clogb2(max_rd_outstanding_transactions+1);

  /* RESP data */
  parameter wr_fifo_data_bits = ((data_bus_width/8)*axi_burst_len) + (data_bus_width*axi_burst_len) + axi_qos_width + addr_width + (max_burst_bytes_width+1);
  parameter wr_bytes_lsb = 0;
  parameter wr_bytes_msb = max_burst_bytes_width;
  parameter wr_addr_lsb  = wr_bytes_msb + 1;
  parameter wr_addr_msb  = wr_addr_lsb + addr_width-1;
  parameter wr_data_lsb  = wr_addr_msb + 1;
  parameter wr_data_msb  = wr_data_lsb + (data_bus_width*axi_burst_len)-1;
  parameter wr_qos_lsb   = wr_data_msb + 1;
  parameter wr_qos_msb   = wr_qos_lsb + axi_qos_width-1;
  parameter wr_strb_lsb  = wr_qos_msb + 1;
  parameter wr_strb_msb  = wr_strb_lsb + ((data_bus_width/8)*axi_burst_len)-1;

  parameter rsp_fifo_bits = axi_rsp_width+id_bus_width;
  parameter rsp_lsb = 0;
  parameter rsp_msb = axi_rsp_width-1;
  parameter rsp_id_lsb = rsp_msb + 1;
  parameter rsp_id_msb = rsp_id_lsb + id_bus_width-1;

  input  S_RESETN;

  output  S_ARREADY;
  output  S_AWREADY;
  output  S_BVALID;
  output  S_RLAST;
  output  S_RVALID;
  output  S_WREADY;
  output  [axi_rsp_width-1:0] S_BRESP;
  output  [axi_rsp_width-1:0] S_RRESP;
  output  [data_bus_width-1:0] S_RDATA;
  output  [id_bus_width-1:0] S_BID;
  output  [id_bus_width-1:0] S_RID;
  input S_ACLK;
  input S_ARVALID;
  input S_AWVALID;
  input S_BREADY;
  input S_RREADY;
  input S_WLAST;
  input S_WVALID;
  input [axi_brst_type_width-1:0] S_ARBURST;
  input [axi_lock_width-1:0] S_ARLOCK;
  input [axi_size_width-1:0] S_ARSIZE;
  input [axi_brst_type_width-1:0] S_AWBURST;
  input [axi_lock_width-1:0] S_AWLOCK;
  input [axi_size_width-1:0] S_AWSIZE;
  input [axi_prot_width-1:0] S_ARPROT;
  input [axi_prot_width-1:0] S_AWPROT;
  input [address_bus_width-1:0] S_ARADDR;
  input [address_bus_width-1:0] S_AWADDR;
  input [data_bus_width-1:0] S_WDATA;
  input [axi_cache_width-1:0] S_ARCACHE;
  input [axi_len_width-1:0] S_ARLEN;
  
  input [axi_qos_width-1:0] S_ARQOS;
  input [aruser_bus_width-1:0] S_ARUSER;
  output [ruser_bus_width-1:0] S_RUSER;
  input [region_bus_width-1:0] S_ARREGION;
 
  input [axi_cache_width-1:0] S_AWCACHE;
  input [axi_len_width-1:0] S_AWLEN;

  input [axi_qos_width-1:0] S_AWQOS;
  input [awuser_bus_width-1:0] S_AWUSER;
  input [wuser_bus_width-1:0] S_WUSER;
  output [buser_bus_width-1:0] S_BUSER;
  input [region_bus_width-1:0] S_AWREGION;

  input [(data_bus_width/8)-1:0] S_WSTRB;
  input [id_bus_width-1:0] S_ARID;
  input [id_bus_width-1:0] S_AWID;

  input SW_CLK;
  input WR_DATA_ACK_DDR, WR_DATA_ACK_OCM;
  output reg WR_DATA_VALID_DDR, WR_DATA_VALID_OCM;
  output reg [(data_bus_width*axi_burst_len)-1:0] WR_DATA;
  output reg [((data_bus_width/8)*axi_burst_len)-1:0] WR_DATA_STRB;
  output reg [addr_width-1:0] WR_ADDR;
  output reg [max_burst_bytes_width:0] WR_BYTES;
  output reg RD_REQ_OCM, RD_REQ_DDR, RD_REQ_REG;
  output reg [addr_width-1:0] RD_ADDR;
  input [(data_bus_width*axi_burst_len)-1:0] RD_DATA_DDR,RD_DATA_OCM, RD_DATA_REG;
  output reg[max_burst_bytes_width:0] RD_BYTES;
  input RD_DATA_VALID_OCM,RD_DATA_VALID_DDR, RD_DATA_VALID_REG;
  output reg [axi_qos_width-1:0] WR_QOS, RD_QOS;
  wire net_ARVALID;
  wire net_AWVALID;
  wire net_WVALID;
  bit [31:0] static_count; 

  real s_aclk_period1;
  real s_aclk_period2;
  real diff_time = 1;
   axi_slv_agent#(0,address_bus_width, data_bus_width, data_bus_width, id_bus_width,id_bus_width,0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1) slv;

   axi_vip_v1_1_6_top #(
     .C_AXI_PROTOCOL(0),
     .C_AXI_INTERFACE_MODE(2),
     .C_AXI_ADDR_WIDTH(address_bus_width),
     .C_AXI_WDATA_WIDTH(data_bus_width),
     .C_AXI_RDATA_WIDTH(data_bus_width),
     .C_AXI_WID_WIDTH(id_bus_width),
     .C_AXI_RID_WIDTH(id_bus_width),
     .C_AXI_AWUSER_WIDTH(0),
     .C_AXI_ARUSER_WIDTH(0),
     .C_AXI_WUSER_WIDTH(0),
     .C_AXI_RUSER_WIDTH(0),
     .C_AXI_BUSER_WIDTH(0),
     .C_AXI_SUPPORTS_NARROW(1),
     .C_AXI_HAS_BURST(1),
     .C_AXI_HAS_LOCK(1),
     .C_AXI_HAS_CACHE(1),
     .C_AXI_HAS_REGION(0),
     .C_AXI_HAS_PROT(1),
     .C_AXI_HAS_QOS(1),
     .C_AXI_HAS_WSTRB(1),
     .C_AXI_HAS_BRESP(1),
     .C_AXI_HAS_RRESP(1),
 	 .C_AXI_HAS_ARESETN(1)
   ) slave (
     .aclk(S_ACLK),
     .aclken(1'B1),
     .aresetn(S_RESETN),
     .s_axi_awid(S_AWID),
     .s_axi_awaddr(S_AWADDR),
     .s_axi_awlen(S_AWLEN),
     .s_axi_awsize(S_AWSIZE),
     .s_axi_awburst(S_AWBURST),
     .s_axi_awlock(S_AWLOCK),
     .s_axi_awcache(S_AWCACHE),
     .s_axi_awprot(S_AWPROT),
     .s_axi_awregion(4'B0),
     .s_axi_awqos(4'h0),
     .s_axi_awuser(S_AWUSER),
     .s_axi_awvalid(S_AWVALID),
     .s_axi_awready(S_AWREADY),
     .s_axi_wid(S_WID),
     .s_axi_wdata(S_WDATA),
     .s_axi_wstrb(S_WSTRB),
     .s_axi_wlast(S_WLAST),
     .s_axi_wuser(S_WUSER),
     .s_axi_wvalid(S_WVALID),
     .s_axi_wready(S_WREADY),
     .s_axi_bid(S_BID),
     .s_axi_bresp(S_BRESP),
     .s_axi_buser(S_BUSER),
     .s_axi_bvalid(S_BVALID),
     .s_axi_bready(S_BREADY),
     .s_axi_arid(S_ARID),
     .s_axi_araddr(S_ARADDR),
     .s_axi_arlen(S_ARLEN),
     .s_axi_arsize(S_ARSIZE),
     .s_axi_arburst(S_ARBURST),
     .s_axi_arlock(S_ARLOCK),
     .s_axi_arcache(S_ARCACHE),
     .s_axi_arprot(S_ARPROT),
     .s_axi_arregion(4'B0),
     .s_axi_arqos(S_ARQOS),
     .s_axi_aruser(S_ARUSER),
     .s_axi_arvalid(S_ARVALID),
     .s_axi_arready(S_ARREADY),
     .s_axi_rid(S_RID),
     .s_axi_rdata(S_RDATA),
     .s_axi_rresp(S_RRESP),
     .s_axi_rlast(S_RLAST),
     .s_axi_ruser(S_RUSER),
     .s_axi_rvalid(S_RVALID),
     .s_axi_rready(S_RREADY),
     .m_axi_awid(),
     .m_axi_awaddr(),
     .m_axi_awlen(),
     .m_axi_awsize(),
     .m_axi_awburst(),
     .m_axi_awlock(),
     .m_axi_awcache(),
     .m_axi_awprot(),
     .m_axi_awregion(),
     .m_axi_awqos(),
     .m_axi_awuser(),
     .m_axi_awvalid(),
     .m_axi_awready(1'b0),
     .m_axi_wid(),
     .m_axi_wdata(),
     .m_axi_wstrb(),
     .m_axi_wlast(),
     .m_axi_wuser(),
     .m_axi_wvalid(),
     .m_axi_wready(1'b0),
     .m_axi_bid(12'h000),
     .m_axi_bresp(2'b00),
     .m_axi_buser(1'B0),
     .m_axi_bvalid(1'b0),
     .m_axi_bready(),
     .m_axi_arid(),
     .m_axi_araddr(),
     .m_axi_arlen(),
     .m_axi_arsize(),
     .m_axi_arburst(),
     .m_axi_arlock(),
     .m_axi_arcache(),
     .m_axi_arprot(),
     .m_axi_arregion(),
     .m_axi_arqos(),
     .m_axi_aruser(),
     .m_axi_arvalid(),
     .m_axi_arready(1'b0),
     .m_axi_rid(12'h000),
     .m_axi_rdata(32'h00000000),
     .m_axi_rresp(2'b00),
     .m_axi_rlast(1'b0),
     .m_axi_ruser(1'B0),
     .m_axi_rvalid(1'b0),
     .m_axi_rready()
   );


   xil_axi_cmd_beat twc, trc;
   xil_axi_write_beat twd;
   xil_axi_read_beat trd;
   axi_transaction twr, trr,trr_get_rd;
   axi_transaction trr_rd[$];
   axi_ready_gen           awready_gen;
   axi_ready_gen           wready_gen;
   axi_ready_gen           arready_gen;
   integer i,j,k,add_val,size_local,burst_local,len_local,num_bytes;
   bit [3:0] a;
   bit [15:0] a_16_bits,a_new,a_wrap,a_wrt_val,a_cnt;

  initial begin
   slv = new("slv",slave.IF);
   twr = new("twr");
   trr = new("trr");
   trr_get_rd = new("trr_get_rd");
   wready_gen = slv.wr_driver.create_ready("wready");
   slv.monitor.axi_wr_cmd_port.set_enabled();
   slv.monitor.axi_wr_beat_port.set_enabled();
   slv.monitor.axi_rd_cmd_port.set_enabled();
   slv.wr_driver.set_transaction_depth(max_wr_outstanding_transactions);
   slv.rd_driver.set_transaction_depth(max_rd_outstanding_transactions);
   slv.start_slave();
  end

  initial begin
    slave.IF.set_enable_xchecks_to_warn();
    repeat(10) @(posedge S_ACLK);
    slave.IF.set_enable_xchecks();
   end 

  /* Latency type and Debug/Error Control */
  reg[1:0] latency_type = RANDOM_CASE;
  reg DEBUG_INFO = 1; 
  reg STOP_ON_ERROR = 1'b1; 

  /* WR_FIFO stores 32-bit address, valid data and valid bytes for each AXI Write burst transaction */
  reg [wr_fifo_data_bits-1:0] wr_fifo [0:max_wr_outstanding_transactions-1];
  reg [int_wr_cntr_width-1:0]    wr_fifo_wr_ptr = 0, wr_fifo_rd_ptr = 0;
  wire wr_fifo_empty;

  /* Store the awvalid receive time --- necessary for calculating the latency in sending the bresp*/
  reg [7:0] aw_time_cnt = 0, bresp_time_cnt = 0;
  real awvalid_receive_time[0:max_wr_outstanding_transactions-1]; // store the time when a new awvalid is received
  reg  awvalid_flag[0:max_wr_outstanding_transactions-1]; // indicates awvalid is received 

  /* Address Write Channel handshake*/
  reg[int_wr_cntr_width-1:0] aw_cnt = 0;// count of awvalid

  /* various FIFOs for storing the ADDR channel info */
  reg [axi_size_width-1:0]  awsize [0:max_wr_outstanding_transactions-1];
  reg [axi_prot_width-1:0]  awprot [0:max_wr_outstanding_transactions-1];
  reg [axi_lock_width-1:0]  awlock [0:max_wr_outstanding_transactions-1];
  reg [axi_cache_width-1:0]  awcache [0:max_wr_outstanding_transactions-1];
  reg [axi_brst_type_width-1:0]  awbrst [0:max_wr_outstanding_transactions-1];
  reg [axi_len_width-1:0]  awlen [0:max_wr_outstanding_transactions-1];
  reg aw_flag [0:max_wr_outstanding_transactions-1];
  reg [addr_width-1:0] awaddr [0:max_wr_outstanding_transactions-1];
  reg [addr_width-1:0] addr_wr_local;
  reg [addr_width-1:0] addr_wr_final;
  reg [id_bus_width-1:0] awid [0:max_wr_outstanding_transactions-1];
  reg [axi_qos_width-1:0] awqos [0:max_wr_outstanding_transactions-1];
  wire aw_fifo_full; // indicates awvalid_fifo is full (max outstanding transactions reached)

  /* internal fifos to store burst write data, ID & strobes*/
  reg [(data_bus_width*axi_burst_len)-1:0] burst_data [0:max_wr_outstanding_transactions-1];
  reg [((data_bus_width/8)*axi_burst_len)-1:0] burst_strb [0:max_wr_outstanding_transactions-1];
  reg [max_burst_bytes_width:0] burst_valid_bytes [0:max_wr_outstanding_transactions-1]; /// total valid bytes received in a complete burst transfer
  reg [max_burst_bytes_width:0] valid_bytes = 0; /// total valid bytes received in a complete burst transfer
  reg wlast_flag [0:max_wr_outstanding_transactions-1]; // flag  to indicate WLAST received
  wire wd_fifo_full;

  /* Write Data Channel and Write Response handshake signals*/
  reg [int_wr_cntr_width-1:0] wd_cnt = 0;
  reg [(data_bus_width*axi_burst_len)-1:0] aligned_wr_data;
  reg [((data_bus_width/8)*axi_burst_len)-1:0] aligned_wr_strb;
  reg [addr_width-1:0] aligned_wr_addr;
  reg [max_burst_bytes_width:0] valid_data_bytes;
  reg [int_wr_cntr_width-1:0] wr_bresp_cnt = 0;
  reg [axi_rsp_width-1:0] bresp;
  reg [rsp_fifo_bits-1:0] fifo_bresp [0:max_wr_outstanding_transactions-1]; // store the ID and its corresponding response
  reg enable_write_bresp;
  reg [int_wr_cntr_width-1:0] rd_bresp_cnt = 0;
  integer wr_latency_count;
  reg  wr_delayed;
  wire bresp_fifo_empty;

  /* states for managing read/write to WR_FIFO */ 
  parameter SEND_DATA = 0,  WAIT_ACK = 1;
  reg state;

  /* Qos*/
  reg [axi_qos_width-1:0] ar_qos, aw_qos;

  initial begin
   if(DEBUG_INFO) begin
    if(enable_this_port)
     $display("[%0d] : %0s : %0s : Port is ENABLED.",$time, DISP_INFO, slave_name);
    else
     $display("[%0d] : %0s : %0s : Port is DISABLED.",$time, DISP_INFO, slave_name);
   end
  end

//initial slave.set_disable_reset_value_checks(1); 
  initial begin
     repeat(2) @(posedge S_ACLK);
     if(!enable_this_port) begin
     end 
//   slave.RESPONSE_TIMEOUT = 0;
  end
  /*--------------------------------------------------------------------------------*/

  /* Set Latency type to be used */
  task set_latency_type;
    input[1:0] lat;
  begin
   if(enable_this_port) 
    latency_type = lat;
   else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. 'Latency Profile' will not be set...",$time, DISP_WARN, slave_name);
   end
  end
  endtask
  /*--------------------------------------------------------------------------------*/

  /* Set verbosity to be used */
  task automatic set_verbosity;
    input[31:0] verb;
  begin
   if(enable_this_port) begin 
    slv.set_verbosity(verb);
   end  else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. set_verbosity will not be set...",$time, DISP_WARN, slave_name);
   end

  end
  endtask
  /*--------------------------------------------------------------------------------*/

  /* Set ARQoS to be used */
  task automatic set_arqos;
    input[axi_qos_width-1:0] qos;
  begin
   if(enable_this_port) begin 
    ar_qos = qos;
   end  else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. 'ARQOS' will not be set...",$time, DISP_WARN, slave_name);
   end

  end
  endtask
  /*--------------------------------------------------------------------------------*/

  /* Set AWQoS to be used */
  task set_awqos;
    input[axi_qos_width-1:0] qos;
  begin
   if(enable_this_port) 
    aw_qos = qos;
   else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. 'AWQOS' will not be set...",$time, DISP_WARN, slave_name);
   end
  end
  endtask
  /*--------------------------------------------------------------------------------*/
  /* get the wr latency number */
  function [31:0] get_wr_lat_number;
  input dummy;
  reg[1:0] temp;
  begin 
   case(latency_type)
    BEST_CASE   : if(slave_name == axi_acp_name) get_wr_lat_number = acp_wr_min; else get_wr_lat_number = gp_wr_min;            
    AVG_CASE    : if(slave_name == axi_acp_name) get_wr_lat_number = acp_wr_avg; else get_wr_lat_number = gp_wr_avg;            
    WORST_CASE  : if(slave_name == axi_acp_name) get_wr_lat_number = acp_wr_max; else get_wr_lat_number = gp_wr_max;            
    default     : begin  // RANDOM_CASE
                   temp = $random;
                   case(temp) 
                    2'b00   : if(slave_name == axi_acp_name) get_wr_lat_number = ($random()%10+ acp_wr_min); else get_wr_lat_number = ($random()%10+ gp_wr_min); 
                    2'b01   : if(slave_name == axi_acp_name) get_wr_lat_number = ($random()%40+ acp_wr_avg); else get_wr_lat_number = ($random()%40+ gp_wr_avg); 
                    default : if(slave_name == axi_acp_name) get_wr_lat_number = ($random()%60+ acp_wr_max); else get_wr_lat_number = ($random()%60+ gp_wr_max); 
                   endcase        
                  end
   endcase
  end
  endfunction
 /*--------------------------------------------------------------------------------*/

  /* get the rd latency number */
  function [31:0] get_rd_lat_number;
  input dummy;
  reg[1:0] temp;
  begin 
   case(latency_type)
    BEST_CASE   : if(slave_name == axi_acp_name) get_rd_lat_number = acp_rd_min; else get_rd_lat_number = gp_rd_min;            
    AVG_CASE    : if(slave_name == axi_acp_name) get_rd_lat_number = acp_rd_avg; else get_rd_lat_number = gp_rd_avg;            
    WORST_CASE  : if(slave_name == axi_acp_name) get_rd_lat_number = acp_rd_max; else get_rd_lat_number = gp_rd_max;            
    default     : begin  // RANDOM_CASE
                   temp = $random;
                   case(temp) 
                    2'b00   : if(slave_name == axi_acp_name) get_rd_lat_number = ($random()%10+ acp_rd_min); else get_rd_lat_number = ($random()%10+ gp_rd_min); 
                    2'b01   : if(slave_name == axi_acp_name) get_rd_lat_number = ($random()%40+ acp_rd_avg); else get_rd_lat_number = ($random()%40+ gp_rd_avg); 
                    default : if(slave_name == axi_acp_name) get_rd_lat_number = ($random()%60+ acp_rd_max); else get_rd_lat_number = ($random()%60+ gp_rd_max); 
                   endcase        
                  end
   endcase
  end
  endfunction
 /*--------------------------------------------------------------------------------*/

  /* Store the Clock cycle time period */
  always@(S_RESETN)
  begin
   if(S_RESETN) begin
	diff_time = 1;
    @(posedge S_ACLK);
    s_aclk_period1 = $realtime;
    @(posedge S_ACLK);
    s_aclk_period2 = $realtime;
	diff_time = s_aclk_period2 - s_aclk_period1;
   end
  end
 /*--------------------------------------------------------------------------------*/

 /* Check for any WRITE/READs when this port is disabled */
 always@(S_AWVALID or S_WVALID or S_ARVALID)
 begin
  if((S_AWVALID | S_WVALID | S_ARVALID) && !enable_this_port) begin
    $display("[%0d] : %0s : %0s : Port is disabled. AXI transaction is initiated on this port ...\nSimulation will halt ..",$time, DISP_ERR, slave_name);
    $stop;
  end
 end

 /*--------------------------------------------------------------------------------*/

 
  assign net_ARVALID = enable_this_port ? S_ARVALID : 1'b0;
  assign net_AWVALID = enable_this_port ? S_AWVALID : 1'b0;
  assign net_WVALID  = enable_this_port ? S_WVALID : 1'b0;

  assign wr_fifo_empty = (wr_fifo_wr_ptr === wr_fifo_rd_ptr)?1'b1: 1'b0;
  assign aw_fifo_full = ((aw_cnt[int_wr_cntr_width-1] !== rd_bresp_cnt[int_wr_cntr_width-1]) && (aw_cnt[int_wr_cntr_width-2:0] === rd_bresp_cnt[int_wr_cntr_width-2:0]))?1'b1 :1'b0; /// complete this
  assign wd_fifo_full = ((wd_cnt[int_wr_cntr_width-1] !== rd_bresp_cnt[int_wr_cntr_width-1]) && (wd_cnt[int_wr_cntr_width-2:0] === rd_bresp_cnt[int_wr_cntr_width-2:0]))?1'b1 :1'b0; /// complete this
  assign bresp_fifo_empty = (wr_bresp_cnt === rd_bresp_cnt)?1'b1:1'b0;
 

  /* Store the awvalid receive time --- necessary for calculating the bresp latency */
  always@(negedge S_RESETN or posedge S_ACLK)
  begin
  if(!S_RESETN)
   aw_time_cnt = 0;
  else begin
  if(net_AWVALID && S_AWREADY) begin
     awvalid_receive_time[aw_time_cnt[int_wr_cntr_width-2:0]] = $realtime;
     awvalid_flag[aw_time_cnt[int_wr_cntr_width-2:0]] = 1'b1;
     aw_time_cnt = aw_time_cnt + 1;
     if(aw_time_cnt[int_wr_cntr_width-2:0] === max_wr_outstanding_transactions ) begin 
	    aw_time_cnt[int_wr_cntr_width-1] = ~ aw_time_cnt[int_wr_cntr_width-1];
        aw_time_cnt[int_wr_cntr_width-2:0] = 0;
	 end  
   end
  end // else
  end /// always
  /*--------------------------------------------------------------------------------*/
  always@(posedge S_ACLK)
  begin
  if(net_AWVALID && S_AWREADY) begin
    if(S_AWQOS === 0) begin awqos[aw_cnt[int_wr_cntr_width-2:0]] = aw_qos; 
    end else awqos[aw_cnt[int_wr_cntr_width-2:0]] = S_AWQOS; 
  end
  end
  /*--------------------------------------------------------------------------------*/
  
  always@(aw_fifo_full)
  begin
  if(aw_fifo_full && DEBUG_INFO) 
    $display("[%0d] : %0s : %0s : Reached the maximum outstanding Write transactions limit (%0d). Blocking all future Write transactions until at least 1 of the outstanding Write transaction has completed.",$time, DISP_INFO, slave_name,max_wr_outstanding_transactions);
  end
  /*--------------------------------------------------------------------------------*/
  
  /* Address Write Channel handshake*/
  //always@(negedge S_RESETN or posedge S_ACLK)
  //begin
  initial begin
  forever begin
  if(!S_RESETN) begin
    aw_cnt = 0;
  end else begin
    // if(!aw_fifo_full) begin 
    wait(aw_fifo_full == 0) begin 
        slv.monitor.axi_wr_cmd_port.get(twc);
        // awaddr[aw_cnt[int_wr_cntr_width-2:0]] = twc.addr;
        awlen[aw_cnt[int_wr_cntr_width-2:0]]  = twc.len;
        awsize[aw_cnt[int_wr_cntr_width-2:0]] = twc.size;
        awbrst[aw_cnt[int_wr_cntr_width-2:0]] = twc.burst;
        awlock[aw_cnt[int_wr_cntr_width-2:0]] = twc.lock;
        awcache[aw_cnt[int_wr_cntr_width-2:0]]= twc.cache;
        awprot[aw_cnt[int_wr_cntr_width-2:0]] = twc.prot;
        awid[aw_cnt[int_wr_cntr_width-2:0]]   = twc.id;
        aw_flag[aw_cnt[int_wr_cntr_width-2:0]] = 1;
	    size_local = twc.size;
        burst_local = twc.burst;
		len_local = twc.len;
		if(burst_local == AXI_INCR || burst_local == AXI_FIXED) begin
          if(data_bus_width === 'd128)  begin 
          if(size_local === 'd0)  a = {twc.addr[3:0]};
          if(size_local === 'd1)  a = {twc.addr[3:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[3:2],2'b0};
          if(size_local === 'd3)  a = {twc.addr[3],3'b0};
          if(size_local === 'd4)  a = 'b0;
		  end else if(data_bus_width === 'd64 ) begin
          if(size_local === 'd0)  a = {twc.addr[2:0]};
          if(size_local === 'd1)  a = {twc.addr[2:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[2],2'b0};
          if(size_local === 'd3)  a = 'b0;
		  end else if(data_bus_width === 'd32 ) begin
          if(size_local === 'd0)  a = {twc.addr[1:0]};
          if(size_local === 'd1)  a = {twc.addr[1],1'b0};
          if(size_local === 'd2)  a = 'b0;
		  end
		end if(burst_local == AXI_WRAP) begin
		  if(data_bus_width === 'd128)  begin 
          if(size_local === 'd0)  a = {twc.addr[3:0]};
          if(size_local === 'd1)  a = {twc.addr[3:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[3:2],2'b0};
          if(size_local === 'd3)  a = {twc.addr[3],3'b0};
          if(size_local === 'd4)  a = 'b0;
		  end else if(data_bus_width === 'd64 ) begin
          if(size_local === 'd0)  a = {twc.addr[2:0]};
          if(size_local === 'd1)  a = {twc.addr[2:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[2],2'b0};
          if(size_local === 'd3)  a = 'b0;
		  end else if(data_bus_width === 'd32 ) begin
          if(size_local === 'd0)  a = {twc.addr[1:0]};
          if(size_local === 'd1)  a = {twc.addr[1],1'b0};
          if(size_local === 'd2)  a = 'b0;
		  end
		  // a = twc.addr[3:0];
		  a_16_bits = twc.addr[7:0];
		  num_bytes = ((len_local+1)*(2**size_local));
		  // $display("num_bytes %0d num_bytes %0h",num_bytes,num_bytes);
		end
		addr_wr_local = twc.addr;
		if(burst_local == AXI_INCR || burst_local == AXI_FIXED) begin
	      case(size_local) 
	        0   : addr_wr_final = {addr_wr_local}; 
	        1   : addr_wr_final = {addr_wr_local[31:1],1'b0}; 
	        2   : addr_wr_final = {addr_wr_local[31:2],2'b0}; 
	        3   : addr_wr_final = {addr_wr_local[31:3],3'b0}; 
	        4   : addr_wr_final = {addr_wr_local[31:4],4'b0}; 
	        5   : addr_wr_final = {addr_wr_local[31:5],5'b0}; 
	        6   : addr_wr_final = {addr_wr_local[31:6],6'b0}; 
	        7   : addr_wr_final = {addr_wr_local[31:7],7'b0}; 
	      endcase	  
	      awaddr[aw_cnt[int_wr_cntr_width-2:0]] = addr_wr_final;
		  $display("%m SLAVE WRITE : final_address %0h awid[aw_cnt[int_wr_cntr_width-2:0]] %0h awlen[aw_cnt[int_wr_cntr_width-2:0]] %0d awsize[aw_cnt[int_wr_cntr_width-2:0]] %0d ",addr_wr_final,awid[aw_cnt[int_wr_cntr_width-2:0]],awlen[aw_cnt[int_wr_cntr_width-2:0]],awsize[aw_cnt[int_wr_cntr_width-2:0]]);
		end if(burst_local == AXI_WRAP) begin
	       awaddr[aw_cnt[int_wr_cntr_width-2:0]] = twc.addr;
           // // $display(" awaddr[aw_cnt[int_wr_cntr_width-2:0]] %0h",awaddr[aw_cnt[int_wr_cntr_width-2:0]]);
		end         
		aw_cnt   = aw_cnt + 1;
        // if(data_bus_width === 'd32)  a = 0;
        // if(data_bus_width === 'd64)  a = twc.addr[2:0];
        // if(data_bus_width === 'd128) a = twc.addr[3:0];
        // $display(" %m addr_wr_final %0h size %0d len %0d awaddr[aw_cnt[int_wr_cntr_width-2:0]] %0h int_wr_cntr_width %0d",twc.addr,twc.size,twc.len,awaddr[aw_cnt[int_wr_cntr_width-2:0]],int_wr_cntr_width);
		 // $display(" %m before resetting  aw_cnt[int_wr_cntr_width-2:0] %0d max_wr_outstanding_transactions  reached %0d ",aw_cnt[int_wr_cntr_width-2:0],max_wr_outstanding_transactions);
        if(aw_cnt[int_wr_cntr_width-2:0] === (max_wr_outstanding_transactions)) begin
          // aw_cnt[int_wr_cntr_width-1] = ~ aw_cnt[int_wr_cntr_width-1];
          aw_cnt[int_wr_cntr_width-2:0] = 0;
        end
    end // if (!aw_fifo_full)
  end /// if else
  end /// always
  end /// always
  /*--------------------------------------------------------------------------------*/

  /* Write Data Channel Handshake */
  // always@(negedge S_RESETN or posedge S_ACLK)
  // begin
  initial begin
  forever begin
  if(!S_RESETN) begin
   wd_cnt = 0;
  end else begin
    // if(!wd_fifo_full && S_WVALID) begin
    wait(wd_fifo_full == 0) begin
      slv.monitor.axi_wr_beat_port.get(twd);
      wait((aw_flag[wd_cnt[int_wr_cntr_width-2:0]] === 'b1));
	  case(size_local) 
	    0   : add_val = 1; 
	    1   : add_val = 2; 
	    2   : add_val = 4; 
	    3   : add_val = 8; 
	    4   : add_val = 16; 
	    5   : add_val = 32; 
	    6   : add_val = 64; 
	    7   : add_val = 128; 
	  endcase

	 // $display(" size_local %0d add_val %0d wd_cnt %0d",size_local,add_val,wd_cnt);
//	   $display(" data depth : %0d size %0d srrb %0d last %0d burst %0d ",2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]],twd.get_data_size(),twd.get_strb_size(),twd.last,twc.burst);
	   //$display(" a value is %0d ",a);
	  // twd.sprint_c();
      for(i = 0; i < (2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]]); i = i+1) begin
	      burst_data[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8))+:8] = twd.data[i+a];
	       //$display("data burst %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h i %0d a %0d full data %0h",burst_data[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8))+:8],twd.data[i],twd.data[i+1],twd.data[i+2],twd.data[i+3],twd.data[i+4],twd.data[i+5],twd.data[i+a],i,a,twd.data[i+a]);
		   //$display(" wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8) %0d  wd_cnt %0d valid_bytes %0d int_wr_cntr_width %0d", wd_cnt[int_wr_cntr_width-2:0],wd_cnt,valid_bytes,int_wr_cntr_width);
	       //$display(" full data %0h",twd.data[i+a]);
		   burst_strb[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes)+(i*1))+:1] = twd.strb[i+a];
		   //$display("burst_strb %0h twd_strb %0h int_wr_cntr_width %0d  valid_bytes %0d wd_cnt[int_wr_cntr_width-2:0] %0d twd.strb[i+a] %0b full strb %0h",burst_strb[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes)+(i*1))+:1],twd.strb[i],int_wr_cntr_width,valid_bytes,wd_cnt[int_wr_cntr_width-2:0],twd.strb[i+a],twd.strb[i+a]);
		   //$display("burst_strb %0h twd.strb[i+1] %0h twd.strb[i+2] %0h twd.strb[i+3] %0h twd.strb[i+4] %0h twd.strb[i+5] %0h twd.strb[i+6] %0h twd.strb[i+7] %0h",twd.strb[i],twd.strb[i+1],twd.strb[i+1],twd.strb[i+2],twd.strb[i+3],twd.strb[i+4],twd.strb[i+5],twd.strb[i+6],twd.strb[i+7]);
		   //$display("full strb %0h",twd.strb[i+a]);
		  
		  if(i == ((2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]])-1) ) begin
		     if(burst_local == AXI_FIXED) begin
		       a = a;
			   end else if(burst_local == AXI_INCR) begin
		       a = a+add_val;
			   end else if(burst_local == AXI_WRAP) begin
			     a_new = (a_16_bits/num_bytes)*num_bytes;
			     a_wrap = a_new + (num_bytes);
		         a = a+add_val;
				 a_cnt = a_cnt+1;
				 a_16_bits = a_16_bits+add_val;
			     a_wrt_val = a_16_bits;
			     //$display(" new a value for wrap a %0h add_val %0d a_wrap %0h a_wrt_val %0h a_new %0h num_bytes %0h a_cnt %0d ",a,add_val,a_wrap[3:0],a_wrt_val,a_new,num_bytes,a_cnt);
			     if(a_wrt_val[15:0] >= a_wrap[15:0]) begin
				   if(data_bus_width === 'd128)
			       a = a_new[3:0];
				   else if(data_bus_width === 'd64)
			       a = a_new[2:0];
				   else if(data_bus_width === 'd32)
			       a = a_new[1:0];
			       //$display(" setting up a_wrap %0h a_new %0h a %0h", a_wrap,a_new,a);
			     end else begin 
		           a = a;
			        //$display(" setting incr a_wrap %0h a_new %0h a %0h", a_wrap,a_new ,a );
			     end
			  end
			 //$display(" new a value a %0h add_val %0d",a,add_val);
		  end	 
        end 
		if(burst_local == AXI_INCR) begin   
		if( a >= (data_bus_width/8) || (burst_local == 0 ) || (twd.last) ) begin
		// if( (burst_local == 0 ) || (twd.last) ) begin
		  a = 0;
		  //$display("resetting a = %0d ",a);
		end  
		end else if (burst_local == AXI_WRAP) begin 
		 if( ((a >= (data_bus_width/8)) ) || (burst_local == 0 ) || (twd.last) ) begin
		  a = 0;
		  //$display("resetting a = %0d ",a);
		end  
		end

      valid_bytes = valid_bytes+(2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]]);
	  //$display("valid bytes in valid_bytes %0d",valid_bytes);

      if (twd.last === 'b1) begin
        wlast_flag[wd_cnt[int_wr_cntr_width-2:0]] = 1'b1;
        burst_valid_bytes[wd_cnt[int_wr_cntr_width-2:0]] = valid_bytes;
		valid_bytes = 0;
        wd_cnt   = wd_cnt + 1;
		a = 0;
		a_cnt = 0;
		// $display(" %m before match max_wr_outstanding_transactions reached %0d wd_cnt %0d",max_wr_outstanding_transactions,wd_cnt);
        if(wd_cnt[int_wr_cntr_width-2:0] === (max_wr_outstanding_transactions)) begin
          wd_cnt[int_wr_cntr_width-1] = ~wd_cnt[int_wr_cntr_width-1];
          wd_cnt[int_wr_cntr_width-2:0] = 0;
		  // $display(" %m Now max_wr_outstanding_transactions  reached %0d ",max_wr_outstanding_transactions);
        end
  	  end
    end /// if
  end /// else
  end /// always
  end /// always

//   /* Write Data Channel Handshake */
//  always@(negedge S_RESETN or posedge S_ACLK)
//  begin
//  if(!S_RESETN) begin
//   wd_cnt = 0;
//  end else begin
//    if(!wd_fifo_full && S_WVALID) begin
//      slv.monitor.axi_wr_beat_port.get(twd);
//	  // twd.do_print();
//	  $display(" data depth : %0d size %0d ",2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]],twd.get_data_size());
//      for(i = 0; i < (2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]]); i = i+1) begin
//        for(int j = 0; j < 2 ; j = j+1) begin
//	      burst_data[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8))+:8] = twd.data[(i*2)+j];
//	      $display("data burst %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h i %0d j %0d",burst_data[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8))+:8],twd.data[i],twd.data[i+1],twd.data[i+2],twd.data[i+3],twd.data[i+4],twd.data[i+5],i,j);
//		  // burst_strb[wd_cnt[wd_cnt[int_wr_cntr_width-2:0]]][((valid_bytes*8)+(i*8))+:8/8)] = twd.strb[i];
//		  $display("burst_strb %0h",twd.strb[i]);
//        end
//      end
//      valid_bytes = valid_bytes+(2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]]);
//      if (twd.last) begin
//        wlast_flag[wd_cnt[int_wr_cntr_width-2:0]] = 1'b1;
//        burst_valid_bytes[wd_cnt[int_wr_cntr_width-2:0]] = valid_bytes;
//		valid_bytes = 0;
//        wd_cnt   = wd_cnt + 1;
//        if(wd_cnt[int_wr_cntr_width-2:0] === (max_wr_outstanding_transactions-1)) begin
//          wd_cnt[int_wr_cntr_width-1] = ~wd_cnt[int_wr_cntr_width-1];
//          wd_cnt[int_wr_cntr_width-2:0] = 0;
//        end
//  	  end
//    end /// if
//  end /// else
//  end /// always
 
  /* Align the wrap data for write transaction */
  task automatic get_wrap_aligned_wr_data;
  output [(data_bus_width*axi_burst_len)-1:0] aligned_data;
  output [addr_width-1:0] start_addr; /// aligned start address
  input  [addr_width-1:0] addr;
  input  [(data_bus_width*axi_burst_len)-1:0] b_data;
  input  [max_burst_bytes_width:0] v_bytes;
  reg    [(data_bus_width*axi_burst_len)-1:0] temp_data, wrp_data;
  integer wrp_bytes;
  integer i;
  begin
    // $display("addr %0h,b_data %0h v_bytes %0h",addr,b_data,v_bytes);
    start_addr = (addr/v_bytes) * v_bytes;
	// $display("wrap start_addr %0h",start_addr);
    wrp_bytes = addr - start_addr;
	// $display("wrap wrp_bytes %0h",wrp_bytes);
    wrp_data = b_data;
    temp_data = 0;
    wrp_data = wrp_data << ((data_bus_width*axi_burst_len) - (v_bytes*8));
	 // $display("wrap wrp_data %0h",wrp_data);
    while(wrp_bytes > 0) begin /// get the data that is wrapped
      temp_data = temp_data << 8;
      temp_data[7:0] = wrp_data[(data_bus_width*axi_burst_len)-1 : (data_bus_width*axi_burst_len)-8];
      wrp_data = wrp_data << 8;
      wrp_bytes = wrp_bytes - 1;
	  // $display("wrap wrp_data %0h  temp_data %0h wrp_bytes %0h ",wrp_data,temp_data[7:0],wrp_bytes);
    end
    wrp_bytes = addr - start_addr;
    wrp_data = b_data << (wrp_bytes*8);
    
    aligned_data = (temp_data | wrp_data);
	// $display("temp_data %0h wrp_data %0h aligned_data %0h",temp_data,wrp_data,aligned_data);
  end
  endtask

  /*--------------------------------------------------------------------------------*/
  /* Align the wrap strb for write transaction */
  task automatic get_wrap_aligned_wr_strb;
  output [((data_bus_width/8)*axi_burst_len)-1:0] aligned_strb;
  output [addr_width-1:0] start_addr; /// aligned start address
  input  [addr_width-1:0] addr;
  input  [((data_bus_width/8)*axi_burst_len)-1:0] b_strb;
  input  [max_burst_bytes_width:0] v_bytes;
  reg    [((data_bus_width/8)*axi_burst_len)-1:0] temp_strb, wrp_strb;
  integer wrp_bytes;
  integer i;
  begin
    // $display("addr %0h,b_strb %0h v_bytes %0h",addr,b_strb,v_bytes);
    start_addr = (addr/v_bytes) * v_bytes;
	// $display("wrap  strb start_addr %0h",start_addr);
    wrp_bytes = addr - start_addr;
	// $display("wrap strb wrp_bytes %0h",wrp_bytes);
    wrp_strb = b_strb;
    temp_strb = 0;
	// $display("wrap strb wrp_strb %0h  before shift value1 %0h value2 %0h",wrp_strb,((data_bus_width/8)*axi_burst_len) ,(v_bytes*4));
	// $display("wrap strb wrp_strb %0h  before shift value1 %0h value2 %0h",wrp_strb,((data_bus_width/8)*axi_burst_len) ,(v_bytes*4));
    wrp_strb = wrp_strb << (((data_bus_width/8)*axi_burst_len) - (v_bytes));
	// $display("wrap wrp_strb %0h  after shift value1 %0h value2 %0h",wrp_strb,((data_bus_width/8)*axi_burst_len) ,(v_bytes*4));
    while(wrp_bytes > 0) begin /// get the strb that is wrapped
      temp_strb = temp_strb << 1;
      temp_strb[0] = wrp_strb[((data_bus_width/8)*axi_burst_len) : ((data_bus_width/8)*axi_burst_len)-1];
      wrp_strb = wrp_strb << 1;
      wrp_bytes = wrp_bytes - 1;
	  // $display("wrap strb wrp_strb %0h wrp_bytes %0h temp_strb %0h",wrp_strb,wrp_bytes,temp_strb);
    end
    wrp_bytes = addr - start_addr;
    wrp_strb = b_strb << (wrp_bytes);
    
    aligned_strb = (temp_strb | wrp_strb);
	// $display("wrap strb aligned_strb %0h tmep_strb %0h wrp_strb %0h",aligned_strb,temp_strb,wrp_strb);
  end
  endtask
  /*--------------------------------------------------------------------------------*/
   
  /* Calculate the Response for each read/write transaction */
  function [axi_rsp_width-1:0] calculate_resp;
  input rd_wr; // indicates Read(1) or Write(0) transaction 
  input [addr_width-1:0] awaddr; 
  input [axi_prot_width-1:0] awprot;
  reg [axi_rsp_width-1:0] rsp;
  begin
    rsp = AXI_OK;
    /* Address Decode */
    if(decode_address(awaddr) === INVALID_MEM_TYPE) begin
     rsp = AXI_SLV_ERR; //slave error
     $display("[%0d] : %0s : %0s : AXI Access to Invalid location(0x%0h) awaddr %0h",$time, DISP_ERR, slave_name, awaddr,awaddr);
    end
    if(!rd_wr && decode_address(awaddr) === REG_MEM) begin
     rsp = AXI_SLV_ERR; //slave error
     $display("[%0d] : %0s : %0s : AXI Write to Register Map(0x%0h) is not supported ",$time, DISP_ERR, slave_name, awaddr);
    end
    if(secure_access_enabled && awprot[1])
     rsp = AXI_DEC_ERR; // decode error
    calculate_resp = rsp;
  end
  endfunction
  /*--------------------------------------------------------------------------------*/

  /* Store the Write response for each write transaction */
  // always@(negedge S_RESETN or posedge S_ACLK)
  // begin
  initial begin
  forever begin
  if(!S_RESETN) begin
   wr_bresp_cnt = 0;
   wr_fifo_wr_ptr = 0;
  end else begin
  // if((wlast_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] === 'b1) && (aw_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] === 'b1)) begin
  wait((wlast_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] === 'b1) && (aw_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] === 'b1)) begin
     // enable_write_bresp <= aw_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] && wlast_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]];
     //#0 enable_write_bresp = 'b1;
     enable_write_bresp = 'b1;
      // $display("%t  ravi enable_write_bresp %0d wr_bresp_cnt %0d aw_flag is %0d",$time ,enable_write_bresp,wlast_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]],aw_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] );
   end
   // enable_write_bresp = aw_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] && wlast_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]];
   /* calculate bresp only when AWVALID && WLAST is received */
   if(enable_write_bresp) begin
     aw_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]]    = 0;
     wlast_flag[wr_bresp_cnt[int_wr_cntr_width-2:0]] = 0;
      // $display("awaddr[wr_bresp_cnt[int_wr_cntr_width-2:0]] %0h ",awaddr[wr_bresp_cnt[int_wr_cntr_width-2:0]]); 
     bresp = calculate_resp(1'b0, awaddr[wr_bresp_cnt[int_wr_cntr_width-2:0]],awprot[wr_bresp_cnt[int_wr_cntr_width-2:0]]);
     fifo_bresp[wr_bresp_cnt[int_wr_cntr_width-2:0]] = {awid[wr_bresp_cnt[int_wr_cntr_width-2:0]],bresp};
	 // $display(" %m current id awid[wr_bresp_cnt[int_wr_cntr_width-2:0] %0h wr_bresp_cnt[int_wr_cntr_width-2:0] %0d",awid[wr_bresp_cnt[int_wr_cntr_width-2:0]],wr_bresp_cnt[int_wr_cntr_width-2:0]);
     /* Fill WR data FIFO */
     if(bresp === AXI_OK) begin
       if(awbrst[wr_bresp_cnt[int_wr_cntr_width-2:0]] === AXI_WRAP) begin /// wrap type? then align the data
         get_wrap_aligned_wr_data(aligned_wr_data,aligned_wr_addr, awaddr[wr_bresp_cnt[int_wr_cntr_width-2:0]],burst_data[wr_bresp_cnt[int_wr_cntr_width-2:0]],burst_valid_bytes[wr_bresp_cnt[int_wr_cntr_width-2:0]]);      /// gives wrapped start address
         get_wrap_aligned_wr_strb(aligned_wr_strb,aligned_wr_addr, awaddr[wr_bresp_cnt[int_wr_cntr_width-2:0]],burst_strb[wr_bresp_cnt[int_wr_cntr_width-2:0]],burst_valid_bytes[wr_bresp_cnt[int_wr_cntr_width-2:0]]);      /// gives wrapped start address
       end else begin
         aligned_wr_data = burst_data[wr_bresp_cnt[int_wr_cntr_width-2:0]]; 
         aligned_wr_addr = awaddr[wr_bresp_cnt[int_wr_cntr_width-2:0]] ;
		 aligned_wr_strb = burst_strb[wr_bresp_cnt[int_wr_cntr_width-2:0]];
		 //$display("  got form fifo aligned_wr_addr %0h wr_bresp_cnt[int_wr_cntr_width-2:0]] %0d",aligned_wr_addr,wr_bresp_cnt[int_wr_cntr_width-2:0]);
		 //$display("  got form fifo aligned_wr_strb %0h wr_bresp_cnt[int_wr_cntr_width-2:0]] %0d",aligned_wr_strb,wr_bresp_cnt[int_wr_cntr_width-2:0]);
       end
       valid_data_bytes = burst_valid_bytes[wr_bresp_cnt[int_wr_cntr_width-2:0]];
     end else 
       valid_data_bytes = 0;  

      if(awbrst[wr_bresp_cnt[int_wr_cntr_width-2:0]] != AXI_WRAP) begin 
        // wr_fifo[wr_fifo_wr_ptr[int_wr_cntr_width-2:0]] = {burst_strb[wr_bresp_cnt[int_wr_cntr_width-2:0]],awqos[wr_bresp_cnt[int_wr_cntr_width-2:0]], aligned_wr_data, aligned_wr_addr, valid_data_bytes};
        wr_fifo[wr_fifo_wr_ptr[int_wr_cntr_width-2:0]] = {aligned_wr_strb,awqos[wr_bresp_cnt[int_wr_cntr_width-2:0]], aligned_wr_data, aligned_wr_addr, valid_data_bytes};
	  end else begin	
        wr_fifo[wr_fifo_wr_ptr[int_wr_cntr_width-2:0]] = {aligned_wr_strb,awqos[wr_bresp_cnt[int_wr_cntr_width-2:0]], aligned_wr_data, aligned_wr_addr, valid_data_bytes};
	 end
     wr_fifo_wr_ptr = wr_fifo_wr_ptr + 1; 
     // $display($time," wr ptr is %0d", wr_fifo_wr_ptr);
     wr_bresp_cnt = wr_bresp_cnt+1;
	 enable_write_bresp = 'b0;
     if(wr_bresp_cnt[int_wr_cntr_width-2:0] === (max_wr_outstanding_transactions)) begin
       wr_bresp_cnt[int_wr_cntr_width-1] = ~ wr_bresp_cnt[int_wr_cntr_width-1];
       wr_bresp_cnt[int_wr_cntr_width-2:0] = 0;
     end
   end
  end // else
  end // always
  end // always
  /*--------------------------------------------------------------------------------*/

  /* Send Write Response Channel handshake */
  always@(negedge S_RESETN or posedge S_ACLK)
  begin
  if(!S_RESETN) begin
   rd_bresp_cnt = 0;
   wr_latency_count = get_wr_lat_number(1);
   wr_delayed = 0;
   bresp_time_cnt = 0; 
  end else begin
   	 if(static_count < 32 ) begin
        // wready_gen.set_ready_policy(XIL_AXI_READY_GEN_SINGLE); 
       //==wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE); 
       //wready_gen.set_low_time(0); 
       //wready_gen.set_high_time(1); 
       //==slv.wr_driver.send_wready(wready_gen);
     end
   if(awvalid_flag[bresp_time_cnt[int_wr_cntr_width-2:0]] && (($realtime - awvalid_receive_time[bresp_time_cnt[int_wr_cntr_width-2:0]])/diff_time >= wr_latency_count))
     wr_delayed = 1;
   if(!bresp_fifo_empty && wr_delayed) begin
     slv.wr_driver.get_wr_reactive(twr);
	 twr.set_id(fifo_bresp[rd_bresp_cnt[int_wr_cntr_width-2:0]][rsp_id_msb : rsp_id_lsb]);
     case(fifo_bresp[rd_bresp_cnt[int_wr_cntr_width-2:0]][rsp_msb : rsp_lsb])
	  2'b00: twr.set_bresp(XIL_AXI_RESP_OKAY);
	  2'b01: twr.set_bresp(XIL_AXI_RESP_EXOKAY);
	  2'b10: twr.set_bresp(XIL_AXI_RESP_SLVERR);
	  2'b11: twr.set_bresp(XIL_AXI_RESP_DECERR);
	 endcase
	 if(static_count > 32 ) begin
      //  wready_gen.set_ready_policy(XIL_AXI_READY_GEN_SINGLE); 
      //==wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE); 
      // wready_gen.set_low_time(3); 
      // wready_gen.set_high_time(3); 
      // wready_gen.set_low_time_range(3,6); 
      // wready_gen.set_high_time_range(3,6); 
      //==slv.wr_driver.send_wready(wready_gen);
     end
     wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
     slv.wr_driver.send_wready(wready_gen);
     slv.wr_driver.send(twr);
     wr_delayed = 0;
     awvalid_flag[bresp_time_cnt[int_wr_cntr_width-2:0]] = 1'b0;
     bresp_time_cnt = bresp_time_cnt+1;
     rd_bresp_cnt = rd_bresp_cnt + 1;
      if(rd_bresp_cnt[int_wr_cntr_width-2:0] === (max_wr_outstanding_transactions)) begin
        rd_bresp_cnt[int_wr_cntr_width-1] = ~ rd_bresp_cnt[int_wr_cntr_width-1];
        rd_bresp_cnt[int_wr_cntr_width-2:0] = 0;
      end
      if(bresp_time_cnt[int_wr_cntr_width-2:0] === (max_wr_outstanding_transactions)) begin
        bresp_time_cnt[int_wr_cntr_width-1] = ~ bresp_time_cnt[int_wr_cntr_width-1];
        bresp_time_cnt[int_wr_cntr_width-2:0] = 0;
        // bresp_time_cnt = 0; 
      end
     wr_latency_count = get_wr_lat_number(1);
	 static_count++;
   end 
	 static_count++;
  end // else
  end//always
  /*--------------------------------------------------------------------------------*/

  /* Reading from the wr_fifo */
  always@(negedge S_RESETN or posedge SW_CLK) begin
  if(!S_RESETN) begin 
   WR_DATA_VALID_DDR = 1'b0;
   WR_DATA_VALID_OCM = 1'b0;
   wr_fifo_rd_ptr = 0;
   state = SEND_DATA;
   WR_QOS = 0;
  end else begin
   case(state)
   SEND_DATA :begin
      state = SEND_DATA;
      WR_DATA_VALID_OCM = 0;
      WR_DATA_VALID_DDR = 0;
      if(!wr_fifo_empty) begin
        WR_DATA  = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-2:0]][wr_data_msb : wr_data_lsb];
        WR_ADDR  = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-2:0]][wr_addr_msb : wr_addr_lsb];
        WR_BYTES = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-2:0]][wr_bytes_msb : wr_bytes_lsb];
        WR_QOS   = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-2:0]][wr_qos_msb : wr_qos_lsb];
		WR_DATA_STRB = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-2:0]][wr_strb_msb : wr_strb_lsb];
        state = WAIT_ACK;
		$display("%m SLAVE WRITE : WR_ADDR %0h WR_DATA %0h WR_DATA_STRB %0h",WR_ADDR,WR_DATA[31:0],WR_DATA_STRB[3:0]);
        case (decode_address(wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-2:0]][wr_addr_msb : wr_addr_lsb]))
         OCM_MEM : WR_DATA_VALID_OCM = 1;
         DDR_MEM : WR_DATA_VALID_DDR = 1;
         default : state = SEND_DATA;
        endcase
        wr_fifo_rd_ptr = wr_fifo_rd_ptr+1;
      end
      end
   WAIT_ACK :begin
      state = WAIT_ACK;
      if(WR_DATA_ACK_OCM | WR_DATA_ACK_DDR) begin 
        WR_DATA_VALID_OCM = 1'b0;
        WR_DATA_VALID_DDR = 1'b0;
        state = SEND_DATA;
      end
      end
   endcase
  end
  end
  /*--------------------------------------------------------------------------------*/
/*-------------------------------- WRITE HANDSHAKE END ----------------------------------------*/

/*-------------------------------- READ HANDSHAKE ---------------------------------------------*/

  /* READ CHANNELS */
  /* Store the arvalid receive time --- necessary for calculating latency in sending the rresp latency */
  reg [7:0] ar_time_cnt = 0,rresp_time_cnt = 0;
  real arvalid_receive_time[0:max_rd_outstanding_transactions]; // store the time when a new arvalid is received
  reg arvalid_flag[0:max_rd_outstanding_transactions]; // store the time when a new arvalid is received
  reg [int_rd_cntr_width-1:0] ar_cnt = 0; // counter for arvalid info

  /* various FIFOs for storing the ADDR channel info */
  reg [axi_size_width-1:0]  arsize [0:max_rd_outstanding_transactions-1];
  reg [axi_prot_width-1:0]  arprot [0:max_rd_outstanding_transactions-1];
  reg [axi_brst_type_width-1:0]  arbrst [0:max_rd_outstanding_transactions-1];
  reg [axi_len_width-1:0]  arlen [0:max_rd_outstanding_transactions-1];
  reg [axi_cache_width-1:0]  arcache [0:max_rd_outstanding_transactions-1];
  reg [axi_lock_width-1:0]  arlock [0:max_rd_outstanding_transactions-1];
  reg ar_flag [0:max_rd_outstanding_transactions-1];
  reg [addr_width-1:0] araddr [0:max_rd_outstanding_transactions-1];
  reg [addr_width-1:0] addr_local;
  reg [addr_width-1:0] addr_final;
  reg [id_bus_width-1:0]  arid [0:max_rd_outstanding_transactions-1];
  reg [axi_qos_width-1:0]  arqos [0:max_rd_outstanding_transactions-1];
  wire ar_fifo_full; // indicates arvalid_fifo is full (max outstanding transactions reached)

  reg [int_rd_cntr_width-1:0] rd_cnt = 0;
  reg [int_rd_cntr_width-1:0] trr_rd_cnt = 0;
  reg [int_rd_cntr_width-1:0] wr_rresp_cnt = 0;
  reg [axi_rsp_width-1:0] rresp;
  reg [rsp_fifo_bits-1:0] fifo_rresp [0:max_rd_outstanding_transactions-1]; // store the ID and its corresponding response

  /* Send Read Response  & Data Channel handshake */
  integer rd_latency_count;
  reg  rd_delayed;
  reg  read_fifo_empty;

  reg [max_burst_bits-1:0] read_fifo [0:max_rd_outstanding_transactions-1]; /// Store only AXI Burst Data ..
  reg [int_rd_cntr_width-1:0] rd_fifo_wr_ptr = 0, rd_fifo_rd_ptr = 0;
  wire read_fifo_full; 
 
  assign read_fifo_full = (rd_fifo_wr_ptr[int_rd_cntr_width-1] !== rd_fifo_rd_ptr[int_rd_cntr_width-1] && rd_fifo_wr_ptr[int_rd_cntr_width-2:0] === rd_fifo_rd_ptr[int_rd_cntr_width-2:0])?1'b1: 1'b0;
  assign read_fifo_empty = (rd_fifo_wr_ptr === rd_fifo_rd_ptr)?1'b1: 1'b0;
  assign ar_fifo_full = ((ar_cnt[int_rd_cntr_width-1] !== rd_cnt[int_rd_cntr_width-1]) && (ar_cnt[int_rd_cntr_width-2:0] === rd_cnt[int_rd_cntr_width-2:0]))?1'b1 :1'b0; 

  /* Store the arvalid receive time --- necessary for calculating the bresp latency */
  always@(negedge S_RESETN or posedge S_ACLK)
  begin
  if(!S_RESETN)
   ar_time_cnt = 0;
  else begin
  if(net_ARVALID == 'b1 && S_ARREADY == 'b1) begin
     arvalid_receive_time[ar_time_cnt] = $time;
     arvalid_flag[ar_time_cnt] = 1'b1;
     ar_time_cnt = ar_time_cnt + 1;
	 // $display(" %m current ar_time_cnt %0d",ar_time_cnt);
     if((ar_time_cnt === max_rd_outstanding_transactions) )
       ar_time_cnt = 0; 
   end 
  end // else
  end /// always
  /*--------------------------------------------------------------------------------*/
  always@(posedge S_ACLK)
  begin
  if(net_ARVALID == 'b1 && S_ARREADY == 'b1) begin
    if(S_ARQOS === 0) begin 
      arqos[ar_cnt[int_rd_cntr_width-2:0]] = ar_qos; 
    end else begin 
      arqos[ar_cnt[int_rd_cntr_width-2:0]] = S_ARQOS; 
    end
  end
  end
  /*--------------------------------------------------------------------------------*/
  
  always@(ar_fifo_full)
  begin
  if(ar_fifo_full && DEBUG_INFO) 
    $display("[%0d] : %0s : %0s : Reached the maximum outstanding Read transactions limit (%0d). Blocking all future Read transactions until at least 1 of the outstanding Read transaction has completed.",$time, DISP_INFO, slave_name,max_rd_outstanding_transactions);
  end
  /*--------------------------------------------------------------------------------*/
  
  /* Address Read  Channel handshake*/
  always@(negedge S_RESETN or posedge S_ACLK)
  begin
  if(!S_RESETN) begin
    ar_cnt = 0;
  end else begin
    if(!ar_fifo_full) begin
      slv.monitor.axi_rd_cmd_port.get(trc);
      // araddr[ar_cnt[int_rd_cntr_width-2:0]] = trc.addr;
      arlen[ar_cnt[int_rd_cntr_width-2:0]]  = trc.len;
      arsize[ar_cnt[int_rd_cntr_width-2:0]] = trc.size;
      arbrst[ar_cnt[int_rd_cntr_width-2:0]] = trc.burst;
      arlock[ar_cnt[int_rd_cntr_width-2:0]] = trc.lock;
      arcache[ar_cnt[int_rd_cntr_width-2:0]]= trc.cache;
      arprot[ar_cnt[int_rd_cntr_width-2:0]] = trc.prot;
      arid[ar_cnt[int_rd_cntr_width-2:0]]   = trc.id;
      ar_flag[ar_cnt[int_rd_cntr_width-2:0]] = 1'b1;
	  size_local = trc.size;
	  addr_local = trc.addr;
	  case(size_local) 
	    0   : addr_final = {addr_local}; 
	    1   : addr_final = {addr_local[31:1],1'b0}; 
	    2   : addr_final = {addr_local[31:2],2'b0}; 
	    3   : addr_final = {addr_local[31:3],3'b0}; 
	    4   : addr_final = {addr_local[31:4],4'b0}; 
	    5   : addr_final = {addr_local[31:5],5'b0}; 
	    6   : addr_final = {addr_local[31:6],6'b0}; 
	    7   : addr_final = {addr_local[31:7],7'b0}; 
	  endcase	  
	    araddr[ar_cnt[int_rd_cntr_width-2:0]] = addr_final;
	$display(" %m SLAVE READ address %0h arlen[ar_cnt[int_rd_cntr_width-2:0]] %0d arsize[ar_cnt[int_rd_cntr_width-2:0]] %0d ",addr_final,arlen[ar_cnt[int_rd_cntr_width-2:0]],arsize[ar_cnt[int_rd_cntr_width-2:0]]);
        ar_cnt = ar_cnt+1;
        if(ar_cnt[int_rd_cntr_width-2:0] === max_rd_outstanding_transactions) begin
          ar_cnt[int_rd_cntr_width-1] = ~ ar_cnt[int_rd_cntr_width-1];
          ar_cnt[int_rd_cntr_width-2:0] = 0;
        end 
    end /// if(!ar_fifo_full)
  end /// if else
  end /// always*/
  /*--------------------------------------------------------------------------------*/

  /* Align Wrap data for read transaction*/
  task automatic get_wrap_aligned_rd_data;
  output [(data_bus_width*axi_burst_len)-1:0] aligned_data;
  input [addr_width-1:0] addr;
  input [(data_bus_width*axi_burst_len)-1:0] b_data;
  input [max_burst_bytes_width:0] v_bytes;
  reg [addr_width-1:0] start_addr;
  reg [(data_bus_width*axi_burst_len)-1:0] temp_data, wrp_data;
  integer wrp_bytes;
  integer i;
  begin
    start_addr = (addr/v_bytes) * v_bytes;
    wrp_bytes = addr - start_addr;
    wrp_data  = b_data;
    temp_data = 0;
    while(wrp_bytes > 0) begin /// get the data that is wrapped
     temp_data = temp_data >> 8;
     temp_data[(data_bus_width*axi_burst_len)-1 : (data_bus_width*axi_burst_len)-8] = wrp_data[7:0];
     wrp_data = wrp_data >> 8;
     wrp_bytes = wrp_bytes - 1;
    end
    temp_data = temp_data >> ((data_bus_width*axi_burst_len) - (v_bytes*8));
    wrp_bytes = addr - start_addr;
    wrp_data = b_data >> (wrp_bytes*8);
    
    aligned_data = (temp_data | wrp_data);
  end
  endtask
  /*--------------------------------------------------------------------------------*/
   
  parameter RD_DATA_REQ = 1'b0, WAIT_RD_VALID = 1'b1;
  reg [addr_width-1:0] temp_read_address;
  reg [max_burst_bytes_width:0] temp_rd_valid_bytes;
  reg rd_fifo_state; 
  reg invalid_rd_req;
  /* get the data from memory && also calculate the rresp*/
  always@(negedge S_RESETN or posedge SW_CLK)
  begin
  if(!S_RESETN)begin
   rd_fifo_wr_ptr = 0; 
   wr_rresp_cnt =0;
   rd_fifo_state = RD_DATA_REQ;
   temp_rd_valid_bytes = 0;
   temp_read_address = 0;
   RD_REQ_DDR = 0;
   RD_REQ_OCM = 0;
   RD_REQ_REG = 0;
   RD_QOS  = 0;
   invalid_rd_req = 0;
  end else begin
   case(rd_fifo_state)
    RD_DATA_REQ : begin
     rd_fifo_state = RD_DATA_REQ;
     RD_REQ_DDR = 0;
     RD_REQ_OCM = 0;
     RD_REQ_REG = 0;
     RD_QOS  = 0;
     if(ar_flag[wr_rresp_cnt[int_rd_cntr_width-2:0]] && !read_fifo_full) begin
       ar_flag[wr_rresp_cnt[int_rd_cntr_width-2:0]] = 0;
       rresp = calculate_resp(1'b1, araddr[wr_rresp_cnt[int_rd_cntr_width-2:0]],arprot[wr_rresp_cnt[int_rd_cntr_width-2:0]]);
       fifo_rresp[wr_rresp_cnt[int_rd_cntr_width-2:0]] = {arid[wr_rresp_cnt[int_rd_cntr_width-2:0]],rresp};
       temp_rd_valid_bytes = (arlen[wr_rresp_cnt[int_rd_cntr_width-2:0]]+1)*(2**arsize[wr_rresp_cnt[int_rd_cntr_width-2:0]]);//data_bus_width/8;

       if(arbrst[wr_rresp_cnt[int_rd_cntr_width-2:0]] === AXI_WRAP) /// wrap begin
        temp_read_address = (araddr[wr_rresp_cnt[int_rd_cntr_width-2:0]]/temp_rd_valid_bytes) * temp_rd_valid_bytes;
       else 
        temp_read_address = araddr[wr_rresp_cnt[int_rd_cntr_width-2:0]];
       if(rresp === AXI_OK) begin 
        case(decode_address(temp_read_address))//decode_address(araddr[wr_rresp_cnt[int_rd_cntr_width-2:0]]);
          OCM_MEM : RD_REQ_OCM = 1;
          DDR_MEM : RD_REQ_DDR = 1;
          REG_MEM : RD_REQ_REG = 1;
          default : invalid_rd_req = 1;
        endcase
       end else
        invalid_rd_req = 1;
        
       RD_QOS     = arqos[wr_rresp_cnt[int_rd_cntr_width-2:0]];
       RD_ADDR    = temp_read_address; ///araddr[wr_rresp_cnt[int_rd_cntr_width-2:0]];
       RD_BYTES   = temp_rd_valid_bytes;
       rd_fifo_state = WAIT_RD_VALID;
       wr_rresp_cnt = wr_rresp_cnt + 1;
       if(wr_rresp_cnt[int_rd_cntr_width-2:0] === max_rd_outstanding_transactions) begin
         wr_rresp_cnt[int_rd_cntr_width-1] = ~ wr_rresp_cnt[int_rd_cntr_width-1];
         wr_rresp_cnt[int_rd_cntr_width-2:0] = 0;
       end
     end
    end
    WAIT_RD_VALID : begin    
     rd_fifo_state = WAIT_RD_VALID; 
     if(RD_DATA_VALID_OCM | RD_DATA_VALID_DDR | RD_DATA_VALID_REG | invalid_rd_req) begin ///temp_dec == 2'b11) begin
       if(RD_DATA_VALID_DDR)
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-2:0]] = RD_DATA_DDR;
       else if(RD_DATA_VALID_OCM)
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-2:0]] = RD_DATA_OCM;
       else if(RD_DATA_VALID_REG)
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-2:0]] = RD_DATA_REG;
       else
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-2:0]] = 0;
       rd_fifo_wr_ptr = rd_fifo_wr_ptr + 1;
       RD_REQ_DDR = 0;
       RD_REQ_OCM = 0;
       RD_REQ_REG = 0;
       RD_QOS  = 0;
       invalid_rd_req = 0;
       rd_fifo_state = RD_DATA_REQ;
     end
    end
   endcase
  end /// else
  end /// always

  /*--------------------------------------------------------------------------------*/
  reg[max_burst_bytes_width:0] rd_v_b;
  reg [(data_bus_width*axi_burst_len)-1:0] temp_read_data;
  reg [(data_bus_width*axi_burst_len)-1:0] temp_wrap_data;
  reg[(axi_rsp_width*axi_burst_len)-1:0] temp_read_rsp;

  xil_axi_data_beat new_data;


  /* Read Data Channel handshake */
  //always@(negedge S_RESETN or posedge S_ACLK)
  initial begin
    forever begin
      if(!S_RESETN)begin
       // rd_fifo_rd_ptr = 0;
       trr_rd_cnt = 0;
       // rd_latency_count = get_rd_lat_number(1);
       // rd_delayed = 0;
       // rresp_time_cnt = 0;
       // rd_v_b = 0;
      end else begin
         //if(net_ARVALID && S_ARREADY)
           // trr_rd[trr_rd_cnt] = new("trr_rd[trr_rd_cnt]");
           // trr_rd[trr_rd_cnt] = new($psprintf("trr_rd[%0d]",trr_rd_cnt));
           slv.rd_driver.get_rd_reactive(trr);
		   trr_rd.push_back(trr.my_clone());
		   //$cast(trr_rd[trr_rd_cnt],trr.copy());
           // rd_latency_count = get_rd_lat_number(1);
           // $display("%m waiting for next transfer trr_rd_cnt %0d trr.size %0d " ,trr_rd_cnt,trr.size);
           // $display("%m waiting for next transfer trr_rd_cnt %0d trr_rd[trr_rd_cnt] %0d" ,trr_rd_cnt,trr_rd[trr_rd_cnt].size);
		   trr_rd_cnt++;
		   @(posedge S_ACLK);
         end
    end // forever
    end // initial


  initial begin
    forever begin
  if(!S_RESETN)begin
   rd_fifo_rd_ptr = 0;
   rd_cnt = 0;
   rd_latency_count = get_rd_lat_number(1);
   rd_delayed = 0;
   rresp_time_cnt = 0;
   rd_v_b = 0;
  end else begin
     //if(net_ARVALID && S_ARREADY)
       // slv.rd_driver.get_rd_reactive(trr_rd[rresp_time_cnt]);
       wait(arvalid_flag[rresp_time_cnt] == 1);
	   // while(trr_rd[rresp_time_cnttrr_rd_cnt] == null) begin
  	   // @(posedge S_ACLK);
	   // end
       rd_latency_count = get_rd_lat_number(1);
	    // $display("%m waiting for element form vip rresp_time_cnt %0d ",rresp_time_cnt);
	    // while(trr_rd.size()< 0 ) begin
	    // $display("%m got the element form vip rresp_time_cnt %0d ",rresp_time_cnt);
  	    // @(posedge S_ACLK);
	    // end
	    // $display("%m got the element form vip rresp_time_cnt %0d ",rresp_time_cnt);
		wait(trr_rd.size() > 0);
		trr_get_rd = trr_rd.pop_front();
        // $display("%m waiting for next transfer trr_rd_cnt %0d trr_get_rd %0d" ,trr_rd_cnt,trr_get_rd.size);
     while ((arvalid_flag[rresp_time_cnt] == 'b1 )&& ((($realtime - arvalid_receive_time[rresp_time_cnt])/diff_time) < rd_latency_count)) begin
  	   @(posedge S_ACLK);
     end

     //if(arvalid_flag[rresp_time_cnt] && ((($realtime - arvalid_receive_time[rresp_time_cnt])/diff_time) >= rd_latency_count)) 
       rd_delayed = 1;
     if(!read_fifo_empty && rd_delayed)begin
       rd_delayed = 0;  
       arvalid_flag[rresp_time_cnt] = 1'b0;
       rd_v_b = ((arlen[rd_cnt[int_rd_cntr_width-2:0]]+1)*(2**arsize[rd_cnt[int_rd_cntr_width-2:0]]));
       temp_read_data =  read_fifo[rd_fifo_rd_ptr[int_rd_cntr_width-2:0]];
       rd_fifo_rd_ptr = rd_fifo_rd_ptr+1;

       if(arbrst[rd_cnt[int_rd_cntr_width-2:0]]=== AXI_WRAP) begin
         get_wrap_aligned_rd_data(temp_wrap_data, araddr[rd_cnt[int_rd_cntr_width-2:0]], temp_read_data, rd_v_b);
         temp_read_data = temp_wrap_data;
       end 
       temp_read_rsp = 0;
       repeat(axi_burst_len) begin
         temp_read_rsp = temp_read_rsp >> axi_rsp_width;
         temp_read_rsp[(axi_rsp_width*axi_burst_len)-1:(axi_rsp_width*axi_burst_len)-axi_rsp_width] = fifo_rresp[rd_cnt[int_rd_cntr_width-2:0]][rsp_msb : rsp_lsb];
       end 
	   case (arsize[rd_cnt[int_rd_cntr_width-2:0]])
         3'b000: trr_get_rd.size = XIL_AXI_SIZE_1BYTE;
         3'b001: trr_get_rd.size = XIL_AXI_SIZE_2BYTE;
         3'b010: trr_get_rd.size = XIL_AXI_SIZE_4BYTE;
         3'b011: trr_get_rd.size = XIL_AXI_SIZE_8BYTE;
         3'b100: trr_get_rd.size = XIL_AXI_SIZE_16BYTE;
         3'b101: trr_get_rd.size = XIL_AXI_SIZE_32BYTE;
         3'b110: trr_get_rd.size = XIL_AXI_SIZE_64BYTE;
         3'b111: trr_get_rd.size = XIL_AXI_SIZE_128BYTE;
       endcase
	   trr_get_rd.len = arlen[rd_cnt[int_rd_cntr_width-2:0]];
	   trr_get_rd.id = (arid[rd_cnt[int_rd_cntr_width-2:0]]);
//	   trr_get_rd.data  = new[((2**arsize[rd_cnt[int_rd_cntr_width-2:0]])*(arlen[rd_cnt[int_rd_cntr_width-2:0]]+1))];
	   trr_get_rd.rresp = new[((2**arsize[rd_cnt[int_rd_cntr_width-2:0]])*(arlen[rd_cnt[int_rd_cntr_width-2:0]]+1))];
       for(j = 0; j < (arlen[rd_cnt[int_rd_cntr_width-2:0]]+1); j = j+1) begin
         for(k = 0; k < (2**arsize[rd_cnt[int_rd_cntr_width-2:0]]); k = k+1) begin
		   new_data[(k*8)+:8] = temp_read_data[7:0];
		   temp_read_data = temp_read_data >> 8;
		 end
         trr_get_rd.set_data_beat(j, new_data);
		 //$display("Read data %0h",new_data);
	     case(temp_read_rsp[(j*2)+:2])
	       2'b00: trr_get_rd.rresp[j] = XIL_AXI_RESP_OKAY;
	       2'b01: trr_get_rd.rresp[j] = XIL_AXI_RESP_EXOKAY;
	       2'b10: trr_get_rd.rresp[j] = XIL_AXI_RESP_SLVERR;
	       2'b11: trr_get_rd.rresp[j] = XIL_AXI_RESP_DECERR;
	     endcase
       end
       slv.rd_driver.send(trr_get_rd);
       rd_cnt = rd_cnt + 1; 
       rresp_time_cnt = rresp_time_cnt+1;
	   // $display("current rresp_time_cnt %0d rd_cnt %0d",rresp_time_cnt,rd_cnt);
       if(rresp_time_cnt === max_rd_outstanding_transactions) rresp_time_cnt = 0;
       if(rd_cnt[int_rd_cntr_width-2:0] === (max_rd_outstanding_transactions)) begin
         rd_cnt[int_rd_cntr_width-1] = ~ rd_cnt[int_rd_cntr_width-1];
         rd_cnt[int_rd_cntr_width-2:0] = 0;
       end
       rd_latency_count = get_rd_lat_number(1);
     end
  end /// else
  end /// always
end
endmodule




/********************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_axi_slave_acp.sv
 *
 * Date : 2012-11
 *
 * Description : Model that acts as PS AXI Slave  port interface. 
 *               It uses AXI3 Slave  BFM
 *****************************************************************************/
 `timescale 1ns/1ps
 import axi_vip_pkg::*;

module zynq_ultra_ps_e_vip_v1_0_6_axi_slave_acp (
  S_RESETN,

  S_ARREADY,
  S_AWREADY,
  S_BVALID,
  S_RLAST,
  S_RVALID,
  S_WREADY,
  S_BRESP,
  S_RRESP,
  S_RDATA,
  S_BID,
  S_RID,
  S_ACLK,
  S_ARVALID,
  S_AWVALID,
  S_BREADY,
  S_RREADY,
  S_WLAST,
  S_WVALID,
  S_ARBURST,
  S_ARLOCK,
  S_ARSIZE,
  S_AWBURST,
  S_AWLOCK,
  S_AWSIZE,
  S_ARPROT,
  S_AWPROT,
  S_ARADDR,
  S_AWADDR,
  S_WDATA,
  S_ARCACHE,
  S_ARLEN,
  S_AWCACHE,
  S_AWLEN,
  S_WSTRB,
  S_ARID,
  S_AWID,
  S_AWQOS,
  S_ARQOS,
  S_AWREGION,
  S_ARREGION,
  S_AWUSER,
  S_WUSER,
  S_BUSER,
  S_ARUSER,
  S_RUSER,
  SW_CLK,
  WR_DATA_ACK_OCM,
  WR_DATA_ACK_DDR,
  WR_ADDR,
  WR_DATA,
  WR_DATA_STRB,
  WR_BYTES,
  WR_DATA_VALID_OCM,
  WR_DATA_VALID_DDR,
  WR_QOS,
  RD_QOS, 
  RD_REQ_DDR,
  RD_REQ_OCM,
  RD_REQ_REG,
  RD_ADDR,
  RD_DATA_OCM,
  RD_DATA_DDR,
  RD_DATA_REG,
  RD_BYTES,
  RD_DATA_VALID_OCM,
  RD_DATA_VALID_DDR,
  RD_DATA_VALID_REG

);
  parameter enable_this_port = 0;  
  parameter slave_name = "Slave";
  parameter data_bus_width = 32;
  parameter address_bus_width = 40;
  parameter id_bus_width = 6;
  parameter awuser_bus_width = 1;
  parameter aruser_bus_width = 1;
  parameter ruser_bus_width  = 1;
  parameter wuser_bus_width  = 1;
  parameter buser_bus_width  = 1;
  parameter max_outstanding_transactions = 25;
  parameter exclusive_access_supported = 0;
  parameter max_wr_outstanding_transactions = 50;
  parameter max_rd_outstanding_transactions = 50;
  parameter region_bus_width = 4;
  
  `include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

  /* Local parameters only for this module */
  /* Internal counters that are used as Read/Write pointers to the fifo's that store all the transaction info on all channles.
     This parameter is used to define the width of these pointers --> depending on Maximum outstanding transactions supported.
     1-bit extra width than the no.of.bits needed to represent the outstanding transactions
     Extra bit helps in generating the empty and full flags */
  parameter int_wr_cntr_width = clogb2(max_wr_outstanding_transactions+1);
  parameter int_rd_cntr_width = clogb2(max_rd_outstanding_transactions+1);

  /* RESP data */
  parameter wr_fifo_data_bits = ((data_bus_width/8)*axi_burst_len) + (data_bus_width*axi_burst_len) + axi_qos_width + addr_width + (max_burst_bytes_width+1);
  parameter wr_bytes_lsb = 0;
  parameter wr_bytes_msb = max_burst_bytes_width;
  parameter wr_addr_lsb  = wr_bytes_msb + 1;
  parameter wr_addr_msb  = wr_addr_lsb + addr_width-1;
  parameter wr_data_lsb  = wr_addr_msb + 1;
  parameter wr_data_msb  = wr_data_lsb + (data_bus_width*axi_burst_len)-1;
  parameter wr_qos_lsb   = wr_data_msb + 1;
  parameter wr_qos_msb   = wr_qos_lsb + axi_qos_width-1;
  parameter wr_strb_lsb  = wr_qos_msb + 1;
  parameter wr_strb_msb  = wr_strb_lsb + ((data_bus_width/8)*axi_burst_len)-1;

  parameter rsp_fifo_bits = axi_rsp_width+id_bus_width;
  parameter rsp_lsb = 0;
  parameter rsp_msb = axi_rsp_width-1;
  parameter rsp_id_lsb = rsp_msb + 1;
  parameter rsp_id_msb = rsp_id_lsb + id_bus_width-1;

  input  S_RESETN;

  output  S_ARREADY;
  output  S_AWREADY;
  output  S_BVALID;
  output  S_RLAST;
  output  S_RVALID;
  output  S_WREADY;
  output  [axi_rsp_width-1:0] S_BRESP;
  output  [axi_rsp_width-1:0] S_RRESP;
  output  [data_bus_width-1:0] S_RDATA;
  output  [id_bus_width-1:0] S_BID;
  output  [id_bus_width-1:0] S_RID;
  input S_ACLK;
  input S_ARVALID;
  input S_AWVALID;
  input S_BREADY;
  input S_RREADY;
  input S_WLAST;
  input S_WVALID;
  input [axi_brst_type_width-1:0] S_ARBURST;
  input [axi_lock_width-1:0] S_ARLOCK;
  input [axi_size_width-1:0] S_ARSIZE;
  input [axi_brst_type_width-1:0] S_AWBURST;
  input [axi_lock_width-1:0] S_AWLOCK;
  input [axi_size_width-1:0] S_AWSIZE;
  input [axi_prot_width-1:0] S_ARPROT;
  input [axi_prot_width-1:0] S_AWPROT;
  input [address_bus_width-1:0] S_ARADDR;
  input [address_bus_width-1:0] S_AWADDR;
  input [data_bus_width-1:0] S_WDATA;
  input [axi_cache_width-1:0] S_ARCACHE;
  input [axi_len_width-1:0] S_ARLEN;
  
  input [axi_qos_width-1:0] S_ARQOS;
  input [aruser_bus_width-1:0] S_ARUSER;
  output [ruser_bus_width-1:0] S_RUSER;
  input [region_bus_width-1:0] S_ARREGION;
 
  input [axi_cache_width-1:0] S_AWCACHE;
  input [axi_len_width-1:0] S_AWLEN;

  input [axi_qos_width-1:0] S_AWQOS;
  input [awuser_bus_width-1:0] S_AWUSER;
  input [wuser_bus_width-1:0] S_WUSER;
  output [buser_bus_width-1:0] S_BUSER;
  input [region_bus_width-1:0] S_AWREGION;

  input [(data_bus_width/8)-1:0] S_WSTRB;
  input [id_bus_width-1:0] S_ARID;
  input [id_bus_width-1:0] S_AWID;

  input SW_CLK;
  input WR_DATA_ACK_DDR, WR_DATA_ACK_OCM;
  output reg WR_DATA_VALID_DDR, WR_DATA_VALID_OCM;
  output reg [(data_bus_width*axi_burst_len)-1:0] WR_DATA;
  output reg [((data_bus_width/8)*axi_burst_len)-1:0] WR_DATA_STRB;
  output reg [addr_width-1:0] WR_ADDR;
  output reg [max_burst_bytes_width:0] WR_BYTES;
  output reg RD_REQ_OCM, RD_REQ_DDR, RD_REQ_REG;
  output reg [addr_width-1:0] RD_ADDR;
  input [(data_bus_width*axi_burst_len)-1:0] RD_DATA_DDR,RD_DATA_OCM, RD_DATA_REG;
  output reg[max_burst_bytes_width:0] RD_BYTES;
  input RD_DATA_VALID_OCM,RD_DATA_VALID_DDR, RD_DATA_VALID_REG;
  output reg [axi_qos_width-1:0] WR_QOS, RD_QOS;
  wire net_ARVALID;
  wire net_AWVALID;
  wire net_WVALID;
  bit [31:0] static_count; 

  real s_aclk_period1;
  real s_aclk_period2;
  real diff_time = 1;
   axi_slv_agent#(0,address_bus_width, data_bus_width, data_bus_width, id_bus_width,id_bus_width,0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1) slv;

   axi_vip_v1_1_6_top #(
     .C_AXI_PROTOCOL(0),
     .C_AXI_INTERFACE_MODE(2),
     .C_AXI_ADDR_WIDTH(address_bus_width),
     .C_AXI_WDATA_WIDTH(data_bus_width),
     .C_AXI_RDATA_WIDTH(data_bus_width),
     .C_AXI_WID_WIDTH(id_bus_width),
     .C_AXI_RID_WIDTH(id_bus_width),
     .C_AXI_AWUSER_WIDTH(0),
     .C_AXI_ARUSER_WIDTH(0),
     .C_AXI_WUSER_WIDTH(0),
     .C_AXI_RUSER_WIDTH(0),
     .C_AXI_BUSER_WIDTH(0),
     .C_AXI_SUPPORTS_NARROW(1),
     .C_AXI_HAS_BURST(1),
     .C_AXI_HAS_LOCK(1),
     .C_AXI_HAS_CACHE(1),
     .C_AXI_HAS_REGION(0),
     .C_AXI_HAS_PROT(1),
     .C_AXI_HAS_QOS(1),
     .C_AXI_HAS_WSTRB(1),
     .C_AXI_HAS_BRESP(1),
     .C_AXI_HAS_RRESP(1),
 	 .C_AXI_HAS_ARESETN(1)
   ) slave (
     .aclk(S_ACLK),
     .aclken(1'B1),
     .aresetn(S_RESETN),
     .s_axi_awid(S_AWID),
     .s_axi_awaddr(S_AWADDR),
     .s_axi_awlen(S_AWLEN),
     .s_axi_awsize(S_AWSIZE),
     .s_axi_awburst(S_AWBURST),
     .s_axi_awlock(S_AWLOCK),
     .s_axi_awcache(S_AWCACHE),
     .s_axi_awprot(S_AWPROT),
     .s_axi_awregion(4'B0),
     .s_axi_awqos(4'h0),
     .s_axi_awuser(S_AWUSER),
     .s_axi_awvalid(S_AWVALID),
     .s_axi_awready(S_AWREADY),
     .s_axi_wid(S_WID),
     .s_axi_wdata(S_WDATA),
     .s_axi_wstrb(S_WSTRB),
     .s_axi_wlast(S_WLAST),
     .s_axi_wuser(S_WUSER),
     .s_axi_wvalid(S_WVALID),
     .s_axi_wready(S_WREADY),
     .s_axi_bid(S_BID),
     .s_axi_bresp(S_BRESP),
     .s_axi_buser(S_BUSER),
     .s_axi_bvalid(S_BVALID),
     .s_axi_bready(S_BREADY),
     .s_axi_arid(S_ARID),
     .s_axi_araddr(S_ARADDR),
     .s_axi_arlen(S_ARLEN),
     .s_axi_arsize(S_ARSIZE),
     .s_axi_arburst(S_ARBURST),
     .s_axi_arlock(S_ARLOCK),
     .s_axi_arcache(S_ARCACHE),
     .s_axi_arprot(S_ARPROT),
     .s_axi_arregion(4'B0),
     .s_axi_arqos(S_ARQOS),
     .s_axi_aruser(S_ARUSER),
     .s_axi_arvalid(S_ARVALID),
     .s_axi_arready(S_ARREADY),
     .s_axi_rid(S_RID),
     .s_axi_rdata(S_RDATA),
     .s_axi_rresp(S_RRESP),
     .s_axi_rlast(S_RLAST),
     .s_axi_ruser(S_RUSER),
     .s_axi_rvalid(S_RVALID),
     .s_axi_rready(S_RREADY),
     .m_axi_awid(),
     .m_axi_awaddr(),
     .m_axi_awlen(),
     .m_axi_awsize(),
     .m_axi_awburst(),
     .m_axi_awlock(),
     .m_axi_awcache(),
     .m_axi_awprot(),
     .m_axi_awregion(),
     .m_axi_awqos(),
     .m_axi_awuser(),
     .m_axi_awvalid(),
     .m_axi_awready(1'b0),
     .m_axi_wid(),
     .m_axi_wdata(),
     .m_axi_wstrb(),
     .m_axi_wlast(),
     .m_axi_wuser(),
     .m_axi_wvalid(),
     .m_axi_wready(1'b0),
     .m_axi_bid(12'h000),
     .m_axi_bresp(2'b00),
     .m_axi_buser(1'B0),
     .m_axi_bvalid(1'b0),
     .m_axi_bready(),
     .m_axi_arid(),
     .m_axi_araddr(),
     .m_axi_arlen(),
     .m_axi_arsize(),
     .m_axi_arburst(),
     .m_axi_arlock(),
     .m_axi_arcache(),
     .m_axi_arprot(),
     .m_axi_arregion(),
     .m_axi_arqos(),
     .m_axi_aruser(),
     .m_axi_arvalid(),
     .m_axi_arready(1'b0),
     .m_axi_rid(12'h000),
     .m_axi_rdata(32'h00000000),
     .m_axi_rresp(2'b00),
     .m_axi_rlast(1'b0),
     .m_axi_ruser(1'B0),
     .m_axi_rvalid(1'b0),
     .m_axi_rready()
   );


   xil_axi_cmd_beat twc, trc;
   xil_axi_write_beat twd;
   xil_axi_read_beat trd;
   axi_transaction twr, trr,trr_get_rd;
   axi_transaction trr_rd[$];
   axi_ready_gen           awready_gen;
   axi_ready_gen           wready_gen;
   axi_ready_gen           arready_gen;
   integer i,j,k,add_val,size_local,burst_local,len_local,num_bytes;
   bit [3:0] a;
   bit [15:0] a_16_bits,a_new,a_wrap,a_wrt_val,a_cnt;

  initial begin
   slv = new("slv",slave.IF);
   twr = new("twr");
   trr = new("trr");
   trr_get_rd = new("trr_get_rd");
   wready_gen = slv.wr_driver.create_ready("wready");
   slv.monitor.axi_wr_cmd_port.set_enabled();
   slv.monitor.axi_wr_beat_port.set_enabled();
   slv.monitor.axi_rd_cmd_port.set_enabled();
   slv.wr_driver.set_transaction_depth(max_wr_outstanding_transactions);
   slv.rd_driver.set_transaction_depth(max_rd_outstanding_transactions);
   slv.start_slave();
  end

  initial begin
    slave.IF.set_enable_xchecks_to_warn();
    repeat(10) @(posedge S_ACLK);
    slave.IF.set_enable_xchecks();
   end 

  /* Latency type and Debug/Error Control */
  reg[1:0] latency_type = RANDOM_CASE;
  reg DEBUG_INFO = 1; 
  reg STOP_ON_ERROR = 1'b1; 

  /* WR_FIFO stores 32-bit address, valid data and valid bytes for each AXI Write burst transaction */
  reg [wr_fifo_data_bits-1:0] wr_fifo [0:max_wr_outstanding_transactions-1];
  reg [int_wr_cntr_width-1:0]    wr_fifo_wr_ptr = 0, wr_fifo_rd_ptr = 0;
  wire wr_fifo_empty;

  /* Store the awvalid receive time --- necessary for calculating the latency in sending the bresp*/
  // reg [7:0] aw_time_cnt = 0, bresp_time_cnt = 0;
  reg [int_wr_cntr_width-1:0] aw_time_cnt = 0, bresp_time_cnt = 0;
  real awvalid_receive_time[0:max_wr_outstanding_transactions-1]; // store the time when a new awvalid is received
  reg  awvalid_flag[0:max_wr_outstanding_transactions-1]; // indicates awvalid is received 

  /* Address Write Channel handshake*/
  reg[int_wr_cntr_width-1:0] aw_cnt = 0;// count of awvalid

  /* various FIFOs for storing the ADDR channel info */
  reg [axi_size_width-1:0]  awsize [0:max_wr_outstanding_transactions-1];
  reg [axi_prot_width-1:0]  awprot [0:max_wr_outstanding_transactions-1];
  reg [axi_lock_width-1:0]  awlock [0:max_wr_outstanding_transactions-1];
  reg [axi_cache_width-1:0]  awcache [0:max_wr_outstanding_transactions-1];
  reg [axi_brst_type_width-1:0]  awbrst [0:max_wr_outstanding_transactions-1];
  reg [axi_len_width-1:0]  awlen [0:max_wr_outstanding_transactions-1];
  reg aw_flag [0:max_wr_outstanding_transactions-1];
  reg [addr_width-1:0] awaddr [0:max_wr_outstanding_transactions-1];
  reg [addr_width-1:0] addr_wr_local;
  reg [addr_width-1:0] addr_wr_final;
  reg [id_bus_width-1:0] awid [0:max_wr_outstanding_transactions-1];
  reg [axi_qos_width-1:0] awqos [0:max_wr_outstanding_transactions-1];
  wire aw_fifo_full; // indicates awvalid_fifo is full (max outstanding transactions reached)

  /* internal fifos to store burst write data, ID & strobes*/
  reg [(data_bus_width*axi_burst_len)-1:0] burst_data [0:max_wr_outstanding_transactions-1];
  reg [((data_bus_width/8)*axi_burst_len)-1:0] burst_strb [0:max_wr_outstanding_transactions-1];
  reg [max_burst_bytes_width:0] burst_valid_bytes [0:max_wr_outstanding_transactions-1]; /// total valid bytes received in a complete burst transfer
  reg [max_burst_bytes_width:0] valid_bytes = 0; /// total valid bytes received in a complete burst transfer
  reg wlast_flag [0:max_wr_outstanding_transactions-1]; // flag  to indicate WLAST received
  wire wd_fifo_full;

  /* Write Data Channel and Write Response handshake signals*/
  reg [int_wr_cntr_width-1:0] wd_cnt = 0;
  reg [(data_bus_width*axi_burst_len)-1:0] aligned_wr_data;
  reg [((data_bus_width/8)*axi_burst_len)-1:0] aligned_wr_strb;
  reg [addr_width-1:0] aligned_wr_addr;
  reg [max_burst_bytes_width:0] valid_data_bytes;
  reg [int_wr_cntr_width-1:0] wr_bresp_cnt = 0;
  reg [axi_rsp_width-1:0] bresp;
  reg [rsp_fifo_bits-1:0] fifo_bresp [0:max_wr_outstanding_transactions-1]; // store the ID and its corresponding response
  reg enable_write_bresp;
  reg [int_wr_cntr_width-1:0] rd_bresp_cnt = 0;
  integer wr_latency_count;
  reg  wr_delayed,wr_fifo_full_flag;
  wire bresp_fifo_empty;

  /* states for managing read/write to WR_FIFO */ 
  parameter SEND_DATA = 0,  WAIT_ACK = 1;
  reg state;

  /* Qos*/
  reg [axi_qos_width-1:0] ar_qos, aw_qos;

  initial begin
   if(DEBUG_INFO) begin
    if(enable_this_port)
     $display("[%0d] : %0s : %0s : Port is ENABLED.",$time, DISP_INFO, slave_name);
    else
     $display("[%0d] : %0s : %0s : Port is DISABLED.",$time, DISP_INFO, slave_name);
   end
  end

//initial slave.set_disable_reset_value_checks(1); 
  initial begin
     repeat(2) @(posedge S_ACLK);
     if(!enable_this_port) begin
     end 
//   slave.RESPONSE_TIMEOUT = 0;
  end
  /*--------------------------------------------------------------------------------*/

  /* Set Latency type to be used */
  task set_latency_type;
    input[1:0] lat;
  begin
   if(enable_this_port) 
    latency_type = lat;
   else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. 'Latency Profile' will not be set...",$time, DISP_WARN, slave_name);
   end
  end
  endtask
  /*--------------------------------------------------------------------------------*/

  /* Set verbosity to be used */
  task automatic set_verbosity;
    input[31:0] verb;
  begin
   if(enable_this_port) begin 
    slv.set_verbosity(verb);
   end  else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. set_verbosity will not be set...",$time, DISP_WARN, slave_name);
   end

  end
  endtask
  /*--------------------------------------------------------------------------------*/

  /* Set ARQoS to be used */
  task automatic set_arqos;
    input[axi_qos_width-1:0] qos;
  begin
   if(enable_this_port) begin 
    ar_qos = qos;
   end  else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. 'ARQOS' will not be set...",$time, DISP_WARN, slave_name);
   end

  end
  endtask
  /*--------------------------------------------------------------------------------*/

  /* Set AWQoS to be used */
  task set_awqos;
    input[axi_qos_width-1:0] qos;
  begin
   if(enable_this_port) 
    aw_qos = qos;
   else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. 'AWQOS' will not be set...",$time, DISP_WARN, slave_name);
   end
  end
  endtask
  /*--------------------------------------------------------------------------------*/
  /* get the wr latency number */
  function [31:0] get_wr_lat_number;
  input dummy;
  reg[1:0] temp;
  begin 
   case(latency_type)
    BEST_CASE   : if(slave_name == axi_acp_name) get_wr_lat_number = acp_wr_min; else get_wr_lat_number = gp_wr_min;            
    AVG_CASE    : if(slave_name == axi_acp_name) get_wr_lat_number = acp_wr_avg; else get_wr_lat_number = gp_wr_avg;            
    WORST_CASE  : if(slave_name == axi_acp_name) get_wr_lat_number = acp_wr_max; else get_wr_lat_number = gp_wr_max;            
    default     : begin  // RANDOM_CASE
                   temp = $random;
                   case(temp) 
                    2'b00   : if(slave_name == axi_acp_name) get_wr_lat_number = ($random()%10+ acp_wr_min); else get_wr_lat_number = ($random()%10+ gp_wr_min); 
                    2'b01   : if(slave_name == axi_acp_name) get_wr_lat_number = ($random()%40+ acp_wr_avg); else get_wr_lat_number = ($random()%40+ gp_wr_avg); 
                    default : if(slave_name == axi_acp_name) get_wr_lat_number = ($random()%60+ acp_wr_max); else get_wr_lat_number = ($random()%60+ gp_wr_max); 
                   endcase        
                  end
   endcase
  end
  endfunction
 /*--------------------------------------------------------------------------------*/

  /* get the rd latency number */
  function [31:0] get_rd_lat_number;
  input dummy;
  reg[1:0] temp;
  begin 
   case(latency_type)
    BEST_CASE   : if(slave_name == axi_acp_name) get_rd_lat_number = acp_rd_min; else get_rd_lat_number = gp_rd_min;            
    AVG_CASE    : if(slave_name == axi_acp_name) get_rd_lat_number = acp_rd_avg; else get_rd_lat_number = gp_rd_avg;            
    WORST_CASE  : if(slave_name == axi_acp_name) get_rd_lat_number = acp_rd_max; else get_rd_lat_number = gp_rd_max;            
    default     : begin  // RANDOM_CASE
                   temp = $random;
                   case(temp) 
                    2'b00   : if(slave_name == axi_acp_name) get_rd_lat_number = ($random()%10+ acp_rd_min); else get_rd_lat_number = ($random()%10+ gp_rd_min); 
                    2'b01   : if(slave_name == axi_acp_name) get_rd_lat_number = ($random()%40+ acp_rd_avg); else get_rd_lat_number = ($random()%40+ gp_rd_avg); 
                    default : if(slave_name == axi_acp_name) get_rd_lat_number = ($random()%60+ acp_rd_max); else get_rd_lat_number = ($random()%60+ gp_rd_max); 
                   endcase        
                  end
   endcase
  end
  endfunction
 /*--------------------------------------------------------------------------------*/

  /* Store the Clock cycle time period */
  always@(S_RESETN)
  begin
   if(S_RESETN) begin
	diff_time = 1;
    @(posedge S_ACLK);
    s_aclk_period1 = $realtime;
    @(posedge S_ACLK);
    s_aclk_period2 = $realtime;
	diff_time = s_aclk_period2 - s_aclk_period1;
   end
  end
 /*--------------------------------------------------------------------------------*/

 /* Check for any WRITE/READs when this port is disabled */
 always@(S_AWVALID or S_WVALID or S_ARVALID)
 begin
  if((S_AWVALID | S_WVALID | S_ARVALID) && !enable_this_port) begin
    $display("[%0d] : %0s : %0s : Port is disabled. AXI transaction is initiated on this port ...\nSimulation will halt ..",$time, DISP_ERR, slave_name);
    $stop;
  end
 end

 /*--------------------------------------------------------------------------------*/

 
  assign net_ARVALID = enable_this_port ? S_ARVALID : 1'b0;
  assign net_AWVALID = enable_this_port ? S_AWVALID : 1'b0;
  assign net_WVALID  = enable_this_port ? S_WVALID : 1'b0;

  assign wr_fifo_empty = (wr_fifo_wr_ptr === wr_fifo_rd_ptr)?1'b1: 1'b0;
  // assign aw_fifo_full = ((aw_cnt[int_wr_cntr_width-1] !== rd_bresp_cnt[int_wr_cntr_width-1]) && (aw_cnt[int_wr_cntr_width-2:0] === rd_bresp_cnt[int_wr_cntr_width-2:0]))?1'b1 :1'b0; /// complete this
  // assign aw_fifo_full = ((aw_cnt[int_wr_cntr_width-1] !== rd_bresp_cnt[int_wr_cntr_width-1]) && (aw_cnt[int_wr_cntr_width-1:0] === rd_bresp_cnt[int_wr_cntr_width-1:0]))?1'b1 :1'b0; /// complete this
  assign aw_fifo_full = ((aw_cnt[1] !== rd_bresp_cnt[1]) && (aw_cnt[0] === rd_bresp_cnt[0]))?1'b1 :1'b0; /// complete this
  assign wd_fifo_full = ((wd_cnt[1] !== rd_bresp_cnt[1]) && (wd_cnt[0] === rd_bresp_cnt[0]))?1'b1 :1'b0; /// complete this
  assign bresp_fifo_empty = ((wr_fifo_full_flag == 1'b0) && (wr_bresp_cnt === rd_bresp_cnt))?1'b1:1'b0;
 

  /* Store the awvalid receive time --- necessary for calculating the bresp latency */
  always@(negedge S_RESETN or posedge S_ACLK)
  begin
  if(!S_RESETN)
   aw_time_cnt = 0;
  else begin
  if(net_AWVALID && S_AWREADY) begin
     awvalid_receive_time[aw_time_cnt] = $realtime;
     awvalid_flag[aw_time_cnt] = 1'b1;
	 // $display("setting up awredy flag awvalid_receive_time[aw_time_cnt] %0t awvalid_flag[aw_time_cnt] %0d aw_time_cnt %0d",awvalid_receive_time[aw_time_cnt],awvalid_flag[aw_time_cnt],aw_time_cnt);
     aw_time_cnt = aw_time_cnt + 1;
     if(aw_time_cnt === max_wr_outstanding_transactions) begin 
	    aw_time_cnt = 0;
		// $display("reached max count max_wr_outstanding_transactions %0d aw_time_cnt %0d",max_wr_outstanding_transactions,aw_time_cnt);
     end
   end
  end // else
  end /// always
  /*--------------------------------------------------------------------------------*/
  always@(posedge S_ACLK)
  begin
  if(net_AWVALID && S_AWREADY) begin
    if(S_AWQOS === 0) begin awqos[aw_cnt[int_wr_cntr_width-2:0]] = aw_qos; 
    end else awqos[aw_cnt[int_wr_cntr_width-2:0]] = S_AWQOS; 
  end
  end
  /*--------------------------------------------------------------------------------*/
  
  always@(aw_fifo_full)
  begin
  if(aw_fifo_full && DEBUG_INFO) 
    $display("[%0d] : %0s : %0s : Reached the maximum outstanding Write transactions limit (%0d). Blocking all future Write transactions until at least 1 of the outstanding Write transaction has completed.",$time, DISP_INFO, slave_name,max_wr_outstanding_transactions);
  end
  /*--------------------------------------------------------------------------------*/
  
  /* Address Write Channel handshake*/
 //  always@(negedge S_RESETN or posedge S_ACLK)
  initial begin
    forever begin
  if(!S_RESETN) begin
    aw_cnt = 0;
  end else begin
    // if(!aw_fifo_full) begin 
	// $display(" %0t ACP waitting for aw_fifo_full %0d max_wr_outstanding_transactions %0d",$time, aw_fifo_full,max_wr_outstanding_transactions);
    wait(aw_fifo_full == 0) begin 
	// $display("%0t ACP waitting done for aw_fifo_full %0d max_wr_outstanding_transactions %0d ",$time,aw_fifo_full,max_wr_outstanding_transactions);
        slv.monitor.axi_wr_cmd_port.get(twc);
        // awaddr[aw_cnt[int_wr_cntr_width-2:0]] = twc.addr;
        awlen[aw_cnt[int_wr_cntr_width-1:0]]  = twc.len;
        awsize[aw_cnt[int_wr_cntr_width-1:0]] = twc.size;
        awbrst[aw_cnt[int_wr_cntr_width-1:0]] = twc.burst;
        awlock[aw_cnt[int_wr_cntr_width-1:0]] = twc.lock;
        awcache[aw_cnt[int_wr_cntr_width-1:0]]= twc.cache;
        awprot[aw_cnt[int_wr_cntr_width-1:0]] = twc.prot;
        awid[aw_cnt[int_wr_cntr_width-1:0]]   = twc.id;
        aw_flag[aw_cnt[int_wr_cntr_width-1:0]] = 1'b1;
	    size_local = twc.size;
        burst_local = twc.burst;
		len_local = twc.len;
		if(burst_local == AXI_INCR || burst_local == AXI_FIXED) begin
          if(data_bus_width === 'd128)  begin 
          if(size_local === 'd0)  a = {twc.addr[3:0]};
          if(size_local === 'd1)  a = {twc.addr[3:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[3:2],2'b0};
          if(size_local === 'd3)  a = {twc.addr[3],3'b0};
          if(size_local === 'd4)  a = 'b0;
		  end else if(data_bus_width === 'd64 ) begin
          if(size_local === 'd0)  a = {twc.addr[2:0]};
          if(size_local === 'd1)  a = {twc.addr[2:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[2],2'b0};
          if(size_local === 'd3)  a = 'b0;
		  end else if(data_bus_width === 'd32 ) begin
          if(size_local === 'd0)  a = {twc.addr[1:0]};
          if(size_local === 'd1)  a = {twc.addr[1],1'b0};
          if(size_local === 'd2)  a = 'b0;
		  end
		end if(burst_local == AXI_WRAP) begin
		  if(data_bus_width === 'd128)  begin 
          if(size_local === 'd0)  a = {twc.addr[3:0]};
          if(size_local === 'd1)  a = {twc.addr[3:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[3:2],2'b0};
          if(size_local === 'd3)  a = {twc.addr[3],3'b0};
          if(size_local === 'd4)  a = 'b0;
		  end else if(data_bus_width === 'd64 ) begin
          if(size_local === 'd0)  a = {twc.addr[2:0]};
          if(size_local === 'd1)  a = {twc.addr[2:1],1'b0};
          if(size_local === 'd2)  a = {twc.addr[2],2'b0};
          if(size_local === 'd3)  a = 'b0;
		  end else if(data_bus_width === 'd32 ) begin
          if(size_local === 'd0)  a = {twc.addr[1:0]};
          if(size_local === 'd1)  a = {twc.addr[1],1'b0};
          if(size_local === 'd2)  a = 'b0;
		  end
		  // a = twc.addr[3:0];
		  a_16_bits = twc.addr[7:0];
		  num_bytes = ((len_local+1)*(2**size_local));
		  // $display("num_bytes %0d num_bytes %0h",num_bytes,num_bytes);
		end
		addr_wr_local = twc.addr;
		if(burst_local == AXI_INCR || burst_local == AXI_FIXED) begin
	      case(size_local) 
	        0   : addr_wr_final = {addr_wr_local}; 
	        1   : addr_wr_final = {addr_wr_local[31:1],1'b0}; 
	        2   : addr_wr_final = {addr_wr_local[31:2],2'b0}; 
	        3   : addr_wr_final = {addr_wr_local[31:3],3'b0}; 
	        4   : addr_wr_final = {addr_wr_local[31:4],4'b0}; 
	        5   : addr_wr_final = {addr_wr_local[31:5],5'b0}; 
	        6   : addr_wr_final = {addr_wr_local[31:6],6'b0}; 
	        7   : addr_wr_final = {addr_wr_local[31:7],7'b0}; 
	      endcase	  
	      awaddr[aw_cnt[int_wr_cntr_width-1:0]] = addr_wr_final;
		  // $display("addr_wr_final %0h aw_cnt %0d",addr_wr_final,aw_cnt);
		end if(burst_local == AXI_WRAP) begin
	       awaddr[aw_cnt[int_wr_cntr_width-1:0]] = twc.addr;
           // $display(" awaddr[aw_cnt[int_wr_cntr_width-2:0]] %0h",awaddr[aw_cnt[int_wr_cntr_width-1:0]]);
		end         
		aw_cnt   = aw_cnt + 1;
		// $display(" %0t ACP aw_cnt %0d",$time,aw_cnt);
        // if(data_bus_width === 'd32)  a = 0;
        // if(data_bus_width === 'd64)  a = twc.addr[2:0];
        // if(data_bus_width === 'd128) a = twc.addr[3:0];
        // $display(" %0t ACP addr_wr_final %0h size %0d len %0d awaddr[aw_cnt[int_wr_cntr_width-2:0]] %0h twc.id %0h",$time,twc.addr,twc.size,twc.len,awaddr[aw_cnt[int_wr_cntr_width-2:0]],twc.id);
		#0;
        if(aw_cnt[int_wr_cntr_width-1:0] === (max_wr_outstanding_transactions)) begin
          // aw_cnt[int_wr_cntr_width] = ~aw_cnt[int_wr_cntr_width];
          aw_cnt[int_wr_cntr_width-1:0] = 0;
		  // $display("%0t ACP resetting the aw_cnt[int_wr_cntr_width-2:0] %0d max_wr_outstanding_transactions %0d",$time,aw_cnt,max_wr_outstanding_transactions);
        end
    end // if (!aw_fifo_full)
  end /// if else
  end /// forever
  end /// always
  /*--------------------------------------------------------------------------------*/

  /* Write Data Channel Handshake */
  // always@(negedge S_RESETN or posedge S_ACLK)
  initial begin
  forever begin
  if(!S_RESETN) begin
   wd_cnt = 0;
   wr_fifo_full_flag = 0;
  end else begin
	// $display(" ACP before data channel wd_fifo_full %0d S_WVALID %0d",wd_fifo_full,S_WVALID);
    // if(!wd_fifo_full && S_WVALID) begin
    // wait(wd_fifo_full == 0 && S_WVALID == 1) begin
    wait(wd_fifo_full == 0 ) begin
	  // $display(" ACP after data channel wd_fifo_full %0d S_WVALID %0d",wd_fifo_full,S_WVALID);
      slv.monitor.axi_wr_beat_port.get(twd);
	  // $display(" ACP got the element from monitor data channel wd_fifo_full %0d S_WVALID %0d",wd_fifo_full,S_WVALID);
      wait((aw_flag[wd_cnt[int_wr_cntr_width-1:0]] === 'b1));
	  case(size_local) 
	    0   : add_val = 1; 
	    1   : add_val = 2; 
	    2   : add_val = 4; 
	    3   : add_val = 8; 
	    4   : add_val = 16; 
	    5   : add_val = 32; 
	    6   : add_val = 64; 
	    7   : add_val = 128; 
	  endcase

	 // $display(" ACP size_local %0d add_val %0d wd_cnt %0d",size_local,add_val,wd_cnt);
//	   $display(" data depth : %0d size %0d srrb %0d last %0d burst %0d ",2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]],twd.get_data_size(),twd.get_strb_size(),twd.last,twc.burst);
	   //$display(" a value is %0d ",a);
	  // twd.sprint_c();
      for(i = 0; i < (2**awsize[wr_bresp_cnt[int_wr_cntr_width-1:0]]); i = i+1) begin
	      burst_data[wd_cnt[int_wr_cntr_width-1:0]][((valid_bytes*8)+(i*8))+:8] = twd.data[i+a];
	       //$display("data burst %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h i %0d a %0d full data %0h",burst_data[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8))+:8],twd.data[i],twd.data[i+1],twd.data[i+2],twd.data[i+3],twd.data[i+4],twd.data[i+5],twd.data[i+a],i,a,twd.data[i+a]);
		   //$display(" wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8) %0d  wd_cnt %0d valid_bytes %0d int_wr_cntr_width %0d", wd_cnt[int_wr_cntr_width-2:0],wd_cnt,valid_bytes,int_wr_cntr_width);
	       // $display(" ACP full data %0h",twd.data[i+a]);
		   burst_strb[wd_cnt[int_wr_cntr_width-1:0]][((valid_bytes)+(i*1))+:1] = twd.strb[i+a];
		   // $display("ACP burst_strb %0h twd_strb %0h int_wr_cntr_width %0d  valid_bytes %0d wd_cnt[int_wr_cntr_width-1:0] %0d twd.strb[i+a] %0b full strb %0h",burst_strb[wd_cnt[int_wr_cntr_width-1:0]][((valid_bytes)+(i*1))+:1],twd.strb[i],int_wr_cntr_width,valid_bytes,wd_cnt[int_wr_cntr_width-1:0],twd.strb[i+a],twd.strb[i+a]);
		   // $display("ACP burst_strb %0h twd.strb[i+1] %0h twd.strb[i+2] %0h twd.strb[i+3] %0h twd.strb[i+4] %0h twd.strb[i+5] %0h twd.strb[i+6] %0h twd.strb[i+7] %0h",twd.strb[i],twd.strb[i+1],twd.strb[i+1],twd.strb[i+2],twd.strb[i+3],twd.strb[i+4],twd.strb[i+5],twd.strb[i+6],twd.strb[i+7]);
		   // $display("ACP full strb %0h",twd.strb[i+a]);
		  
		  if(i == ((2**awsize[wr_bresp_cnt[int_wr_cntr_width-1:0]])-1) ) begin
		     if(burst_local == AXI_FIXED) begin
		       a = a;
			   end else if(burst_local == AXI_INCR) begin
		       a = a+add_val;
			   end else if(burst_local == AXI_WRAP) begin
			     a_new = (a_16_bits/num_bytes)*num_bytes;
			     a_wrap = a_new + (num_bytes);
		         a = a+add_val;
				 a_cnt = a_cnt+1;
				 a_16_bits = a_16_bits+add_val;
			     a_wrt_val = a_16_bits;
			     // $display(" ACP new a value for wrap a %0h add_val %0d a_wrap %0h a_wrt_val %0h a_new %0h num_bytes %0h a_cnt %0d ",a,add_val,a_wrap[3:0],a_wrt_val,a_new,num_bytes,a_cnt);
			     if(a_wrt_val[15:0] >= a_wrap[15:0]) begin
				   if(data_bus_width === 'd128)
			       a = a_new[3:0];
				   else if(data_bus_width === 'd64)
			       a = a_new[2:0];
				   else if(data_bus_width === 'd32)
			       a = a_new[1:0];
			       //$display(" setting up a_wrap %0h a_new %0h a %0h", a_wrap,a_new,a);
			     end else begin 
		           a = a;
			        // $display(" ACP setting incr a_wrap %0h a_new %0h a %0h", a_wrap,a_new ,a );
			     end
			  end
			 // $display(" ACP new a value a %0h add_val %0d",a,add_val);
		  end	 
        end 
		if(burst_local == AXI_INCR) begin   
		if( a >= (data_bus_width/8) || (burst_local == 0 ) || (twd.last) ) begin
		// if( (burst_local == 0 ) || (twd.last) ) begin
		  a = 0;
		  //$display("resetting a = %0d ",a);
		end  
		end else if (burst_local == AXI_WRAP) begin 
		 if( ((a >= (data_bus_width/8)) ) || (burst_local == 0 ) || (twd.last) ) begin
		  a = 0;
		  //$display("resetting a = %0d ",a);
		end  
		end

      valid_bytes = valid_bytes+(2**awsize[wr_bresp_cnt[int_wr_cntr_width-1:0]]);
	  // $display("ACP valid bytes in valid_bytes %0d",valid_bytes);

      if (twd.last === 'b1) begin
        wlast_flag[wd_cnt[int_wr_cntr_width-1:0]] = 1'b1;
        burst_valid_bytes[wd_cnt[int_wr_cntr_width-1:0]] = valid_bytes;
		valid_bytes = 0;
        wd_cnt   = wd_cnt + 1;
		a = 0;
		a_cnt = 0;
		// $display(" %0t ACP before match max_wr_outstanding_transactions reached %0d wd_cnt %0d int_wr_cntr_width %0d ",$time,max_wr_outstanding_transactions,wd_cnt,int_wr_cntr_width);
        if(wd_cnt[int_wr_cntr_width-1:0] === (max_wr_outstanding_transactions)) begin
          // wd_cnt[int_wr_cntr_width] = ~wd_cnt[int_wr_cntr_width];
          wd_cnt[int_wr_cntr_width-1:0] = 0;
		  // $display(" ACP resetting the wd_cnt %0d Now max_wr_outstanding_transactions reached %0d ",wd_cnt,max_wr_outstanding_transactions);
        end
  	  end
    end /// if
  end /// else
  end /// forever
  end /// always

//   /* Write Data Channel Handshake */
//  always@(negedge S_RESETN or posedge S_ACLK)
//  begin
//  if(!S_RESETN) begin
//   wd_cnt = 0;
//  end else begin
//    if(!wd_fifo_full && S_WVALID) begin
//      slv.monitor.axi_wr_beat_port.get(twd);
//	  // twd.do_print();
//	  $display(" data depth : %0d size %0d ",2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]],twd.get_data_size());
//      for(i = 0; i < (2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]]); i = i+1) begin
//        for(int j = 0; j < 2 ; j = j+1) begin
//	      burst_data[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8))+:8] = twd.data[(i*2)+j];
//	      $display("data burst %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h twd.data %0h i %0d j %0d",burst_data[wd_cnt[int_wr_cntr_width-2:0]][((valid_bytes*8)+(i*8))+:8],twd.data[i],twd.data[i+1],twd.data[i+2],twd.data[i+3],twd.data[i+4],twd.data[i+5],i,j);
//		  // burst_strb[wd_cnt[wd_cnt[int_wr_cntr_width-2:0]]][((valid_bytes*8)+(i*8))+:8/8)] = twd.strb[i];
//		  $display("burst_strb %0h",twd.strb[i]);
//        end
//      end
//      valid_bytes = valid_bytes+(2**awsize[wr_bresp_cnt[int_wr_cntr_width-2:0]]);
//      if (twd.last) begin
//        wlast_flag[wd_cnt[int_wr_cntr_width-2:0]] = 1'b1;
//        burst_valid_bytes[wd_cnt[int_wr_cntr_width-2:0]] = valid_bytes;
//		valid_bytes = 0;
//        wd_cnt   = wd_cnt + 1;
//        if(wd_cnt[int_wr_cntr_width-2:0] === (max_wr_outstanding_transactions-1)) begin
//          wd_cnt[int_wr_cntr_width-1] = ~wd_cnt[int_wr_cntr_width-1];
//          wd_cnt[int_wr_cntr_width-2:0] = 0;
//        end
//  	  end
//    end /// if
//  end /// else
//  end /// always
 
  /* Align the wrap data for write transaction */
  task automatic get_wrap_aligned_wr_data;
  output [(data_bus_width*axi_burst_len)-1:0] aligned_data;
  output [addr_width-1:0] start_addr; /// aligned start address
  input  [addr_width-1:0] addr;
  input  [(data_bus_width*axi_burst_len)-1:0] b_data;
  input  [max_burst_bytes_width:0] v_bytes;
  reg    [(data_bus_width*axi_burst_len)-1:0] temp_data, wrp_data;
  integer wrp_bytes;
  integer i;
  begin
    // $display("addr %0h,b_data %0h v_bytes %0h",addr,b_data,v_bytes);
    start_addr = (addr/v_bytes) * v_bytes;
	// $display("wrap start_addr %0h",start_addr);
    wrp_bytes = addr - start_addr;
	// $display("wrap wrp_bytes %0h",wrp_bytes);
    wrp_data = b_data;
    temp_data = 0;
    wrp_data = wrp_data << ((data_bus_width*axi_burst_len) - (v_bytes*8));
	 // $display("wrap wrp_data %0h",wrp_data);
    while(wrp_bytes > 0) begin /// get the data that is wrapped
      temp_data = temp_data << 8;
      temp_data[7:0] = wrp_data[(data_bus_width*axi_burst_len)-1 : (data_bus_width*axi_burst_len)-8];
      wrp_data = wrp_data << 8;
      wrp_bytes = wrp_bytes - 1;
	  // $display("wrap wrp_data %0h  temp_data %0h wrp_bytes %0h ",wrp_data,temp_data[7:0],wrp_bytes);
    end
    wrp_bytes = addr - start_addr;
    wrp_data = b_data << (wrp_bytes*8);
    
    aligned_data = (temp_data | wrp_data);
	// $display("temp_data %0h wrp_data %0h aligned_data %0h",temp_data,wrp_data,aligned_data);
  end
  endtask

  /*--------------------------------------------------------------------------------*/
  /* Align the wrap strb for write transaction */
  task automatic get_wrap_aligned_wr_strb;
  output [((data_bus_width/8)*axi_burst_len)-1:0] aligned_strb;
  output [addr_width-1:0] start_addr; /// aligned start address
  input  [addr_width-1:0] addr;
  input  [((data_bus_width/8)*axi_burst_len)-1:0] b_strb;
  input  [max_burst_bytes_width:0] v_bytes;
  reg    [((data_bus_width/8)*axi_burst_len)-1:0] temp_strb, wrp_strb;
  integer wrp_bytes;
  integer i;
  begin
    // $display("addr %0h,b_strb %0h v_bytes %0h",addr,b_strb,v_bytes);
    start_addr = (addr/v_bytes) * v_bytes;
	// $display("wrap  strb start_addr %0h",start_addr);
    wrp_bytes = addr - start_addr;
	// $display("wrap strb wrp_bytes %0h",wrp_bytes);
    wrp_strb = b_strb;
    temp_strb = 0;
	// $display("wrap strb wrp_strb %0h  before shift value1 %0h value2 %0h",wrp_strb,((data_bus_width/8)*axi_burst_len) ,(v_bytes*4));
	// $display("wrap strb wrp_strb %0h  before shift value1 %0h value2 %0h",wrp_strb,((data_bus_width/8)*axi_burst_len) ,(v_bytes*4));
    wrp_strb = wrp_strb << (((data_bus_width/8)*axi_burst_len) - (v_bytes));
	// $display("wrap wrp_strb %0h  after shift value1 %0h value2 %0h",wrp_strb,((data_bus_width/8)*axi_burst_len) ,(v_bytes*4));
    while(wrp_bytes > 0) begin /// get the strb that is wrapped
      temp_strb = temp_strb << 1;
      temp_strb[0] = wrp_strb[((data_bus_width/8)*axi_burst_len) : ((data_bus_width/8)*axi_burst_len)-1];
      wrp_strb = wrp_strb << 1;
      wrp_bytes = wrp_bytes - 1;
	  // $display("wrap strb wrp_strb %0h wrp_bytes %0h temp_strb %0h",wrp_strb,wrp_bytes,temp_strb);
    end
    wrp_bytes = addr - start_addr;
    wrp_strb = b_strb << (wrp_bytes);
    
    aligned_strb = (temp_strb | wrp_strb);
	// $display("wrap strb aligned_strb %0h tmep_strb %0h wrp_strb %0h",aligned_strb,temp_strb,wrp_strb);
  end
  endtask
  /*--------------------------------------------------------------------------------*/
   
  /* Calculate the Response for each read/write transaction */
  function [axi_rsp_width-1:0] calculate_resp;
  input rd_wr; // indicates Read(1) or Write(0) transaction 
  input [addr_width-1:0] awaddr; 
  input [axi_prot_width-1:0] awprot;
  reg [axi_rsp_width-1:0] rsp;
  begin
    rsp = AXI_OK;
    /* Address Decode */
    if(decode_address(awaddr) === INVALID_MEM_TYPE) begin
     rsp = AXI_SLV_ERR; //slave error
     $display("[%0d] : %0s : %0s : AXI Access to Invalid location(0x%0h) awaddr %0h",$time, DISP_ERR, slave_name, awaddr,awaddr);
    end
    if(!rd_wr && decode_address(awaddr) === REG_MEM) begin
     rsp = AXI_SLV_ERR; //slave error
     $display("[%0d] : %0s : %0s : AXI Write to Register Map(0x%0h) is not supported ",$time, DISP_ERR, slave_name, awaddr);
    end
    if(secure_access_enabled && awprot[1])
     rsp = AXI_DEC_ERR; // decode error
    calculate_resp = rsp;
  end
  endfunction
  /*--------------------------------------------------------------------------------*/

  /* Store the Write response for each write transaction */
  // always@(negedge S_RESETN or posedge S_ACLK)
  // begin
  initial begin
  forever begin
  if(!S_RESETN) begin
   wr_bresp_cnt = 0;
   wr_fifo_wr_ptr = 0;
  end else begin
  // $display("%t ACP enable_write_bresp %0d wr_bresp_cnt %0d",$time ,enable_write_bresp,wr_bresp_cnt[int_wr_cntr_width-1:0]);
  // $display("%t ACP aw_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] %0d  wlast_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] %0d ",$time,aw_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] , wlast_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]]);
  // if((wlast_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] === 'b1) && (aw_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] === 'b1)) begin
  wait((wlast_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] === 'b1) && (aw_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] === 'b1)) begin
     // enable_write_bresp <= aw_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] && wlast_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]];
     //#0 enable_write_bresp = 'b1;
     enable_write_bresp = 'b1;
     // $display("%t ACP enable_write_bresp %0d wr_bresp_cnt %0d",$time ,enable_write_bresp,wr_bresp_cnt[int_wr_cntr_width-1:0]);
     // $display("%t enable_write_bresp %0d wr_bresp_cnt %0d",$time ,enable_write_bresp,wr_bresp_cnt[int_wr_cntr_width-1:0]);
   end
   // enable_write_bresp = aw_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] && wlast_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]];
   /* calculate bresp only when AWVALID && WLAST is received */
   if(enable_write_bresp) begin
     aw_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]]    = 0;
     wlast_flag[wr_bresp_cnt[int_wr_cntr_width-1:0]] = 0;
     // $display("awaddr[wr_bresp_cnt[int_wr_cntr_width-1:0]] %0h ",awaddr[wr_bresp_cnt[int_wr_cntr_width-1:0]]); 
     bresp = calculate_resp(1'b0, awaddr[wr_bresp_cnt[int_wr_cntr_width-1:0]],awprot[wr_bresp_cnt[int_wr_cntr_width-1:0]]);
     fifo_bresp[wr_bresp_cnt[int_wr_cntr_width-1:0]] = {awid[wr_bresp_cnt[int_wr_cntr_width-1:0]],bresp};
     /* Fill WR data FIFO */
     if(bresp === AXI_OK) begin
       if(awbrst[wr_bresp_cnt[int_wr_cntr_width-1:0]] === AXI_WRAP) begin /// wrap type? then align the data
         get_wrap_aligned_wr_data(aligned_wr_data,aligned_wr_addr, awaddr[wr_bresp_cnt[int_wr_cntr_width-1:0]],burst_data[wr_bresp_cnt[int_wr_cntr_width-1:0]],burst_valid_bytes[wr_bresp_cnt[int_wr_cntr_width-1:0]]);      /// gives wrapped start address
         get_wrap_aligned_wr_strb(aligned_wr_strb,aligned_wr_addr, awaddr[wr_bresp_cnt[int_wr_cntr_width-1:0]],burst_strb[wr_bresp_cnt[int_wr_cntr_width-1:0]],burst_valid_bytes[wr_bresp_cnt[int_wr_cntr_width-1:0]]);      /// gives wrapped start address
       end else begin
         aligned_wr_data = burst_data[wr_bresp_cnt[int_wr_cntr_width-1:0]]; 
         aligned_wr_addr = awaddr[wr_bresp_cnt[int_wr_cntr_width-1:0]] ;
		 aligned_wr_strb = burst_strb[wr_bresp_cnt[int_wr_cntr_width-1:0]];
		 //$display("  got form fifo aligned_wr_addr %0h wr_bresp_cnt[int_wr_cntr_width-1:0]] %0d",aligned_wr_addr,wr_bresp_cnt[int_wr_cntr_width-1:0]);
		 //$display("  got form fifo aligned_wr_strb %0h wr_bresp_cnt[int_wr_cntr_width-1:0]] %0d",aligned_wr_strb,wr_bresp_cnt[int_wr_cntr_width-1:0]);
       end
       valid_data_bytes = burst_valid_bytes[wr_bresp_cnt[int_wr_cntr_width-1:0]];
     end else 
       valid_data_bytes = 0;  

      if(awbrst[wr_bresp_cnt[int_wr_cntr_width-1:0]] != AXI_WRAP) begin 
        // wr_fifo[wr_fifo_wr_ptr[int_wr_cntr_width-1:0]] = {burst_strb[wr_bresp_cnt[int_wr_cntr_width-1:0]],awqos[wr_bresp_cnt[int_wr_cntr_width-1:0]], aligned_wr_data, aligned_wr_addr, valid_data_bytes};
        wr_fifo[wr_fifo_wr_ptr[int_wr_cntr_width-1:0]] = {aligned_wr_strb,awqos[wr_bresp_cnt[int_wr_cntr_width-1:0]], aligned_wr_data, aligned_wr_addr, valid_data_bytes};
		// $display(" %0t ACP updating the wr_fifo  wrap aligned_wr_strb %0h  aligned_wr_addr %0h valid_data_bytes %0h",$time,aligned_wr_strb,aligned_wr_addr ,valid_data_bytes);
	  end else begin	
        wr_fifo[wr_fifo_wr_ptr[int_wr_cntr_width-1:0]] = {aligned_wr_strb,awqos[wr_bresp_cnt[int_wr_cntr_width-1:0]], aligned_wr_data, aligned_wr_addr, valid_data_bytes};
		// $display(" %0t ACP updating the wr_fifo  incr aligned_wr_strb %0h  aligned_wr_addr %0h valid_data_bytes %0h",$time,aligned_wr_strb,aligned_wr_addr ,valid_data_bytes);
	 end
     wr_fifo_wr_ptr = wr_fifo_wr_ptr + 1'b1; 
     wr_bresp_cnt = wr_bresp_cnt+1'b1;
	 enable_write_bresp = 'b0;
	 if(wr_bresp_cnt == 2'd2) begin
	   wr_fifo_full_flag = 1'b1; 
	 end

	 // $display(" %0t ACP before resetting the wr_bresp_cnt counter %0d max_wr_outstanding_transactions %0d int_wr_cntr_width %0d wr_fifo_wr_ptr %0d" ,$time, wr_bresp_cnt[int_wr_cntr_width-1:0],max_wr_outstanding_transactions,int_wr_cntr_width,wr_fifo_wr_ptr);
     if(wr_bresp_cnt[int_wr_cntr_width-1:0] === (max_wr_outstanding_transactions)) begin
       // wr_bresp_cnt[int_wr_cntr_width] = ~ wr_bresp_cnt[int_wr_cntr_width];
       wr_bresp_cnt[int_wr_cntr_width-1:0] = 0;
	   // $display(" ACP resetting the wr_bresp_cnt counter %0d " , wr_bresp_cnt);
     end

	  if(wr_fifo_wr_ptr[int_wr_cntr_width-1:0] === (max_wr_outstanding_transactions)) begin
       wr_fifo_wr_ptr[int_wr_cntr_width-1:0] = 0;
	   // $display(" ACP resetting the wr_fifo_wr_ptr counter %0d " , wr_fifo_wr_ptr);
     end

   end
  end // else
  end // alway1
  end // alway1
  /*--------------------------------------------------------------------------------*/

  /* Send Write Response Channel handshake */
  always@(negedge S_RESETN or posedge S_ACLK)
  begin
  if(!S_RESETN) begin
   rd_bresp_cnt = 0;
   wr_latency_count = get_wr_lat_number(1);
   // wr_latency_count = 5;
   wr_delayed = 0;
   bresp_time_cnt = 0; 
  end else begin
   // 	 if(static_count < 32 ) begin
   //      // wready_gen.set_ready_policy(XIL_AXI_READY_GEN_SINGLE); 
   //     wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE); 
   //     //wready_gen.set_low_time(0); 
   //     //wready_gen.set_high_time(1); 
   //     slv.wr_driver.send_wready(wready_gen);
   //   end
   // $display(" ACP waiting for awvalid_flag[bresp_time_cnt] %0d $realtime  %0t awvalid_receive_time[bresp_time_cnt] %0t",awvalid_flag[bresp_time_cnt],$realtime ,awvalid_receive_time[bresp_time_cnt]);
   // $display(" ACP waiting for wr_latency_count %0t bresp_time_cnt %0d",wr_latency_count,bresp_time_cnt);
   // $display(" ACP waiting for diff_time %0t",diff_time);
   if(awvalid_flag[bresp_time_cnt] && (($realtime - awvalid_receive_time[bresp_time_cnt])/diff_time >= wr_latency_count)) begin
     wr_delayed = 1;
   end	 
	 // $display(" ACP waiting for wr_delayed wr_delayed %0d bresp_fifo_empty %0d ",wr_delayed,bresp_fifo_empty);
   if(!bresp_fifo_empty && wr_delayed) begin
	 // $display(" ACP before getting twr wr_delayed %0d bresp_fifo_empty %0d ",wr_delayed,bresp_fifo_empty);
     slv.wr_driver.get_wr_reactive(twr);
	 // $display(" ACP after getting twr wr_delayed %0d bresp_fifo_empty %0d ",wr_delayed,bresp_fifo_empty);
	 twr.set_id(fifo_bresp[rd_bresp_cnt[int_wr_cntr_width-1:0]][rsp_id_msb : rsp_id_lsb]);
     case(fifo_bresp[rd_bresp_cnt[int_wr_cntr_width-1:0]][rsp_msb : rsp_lsb])
	  2'b00: twr.set_bresp(XIL_AXI_RESP_OKAY);
	  2'b01: twr.set_bresp(XIL_AXI_RESP_EXOKAY);
	  2'b10: twr.set_bresp(XIL_AXI_RESP_SLVERR);
	  2'b11: twr.set_bresp(XIL_AXI_RESP_DECERR);
	 endcase
	//  if(static_count > 32 ) begin
      //  wready_gen.set_ready_policy(XIL_AXI_READY_GEN_SINGLE); 
      wready_gen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE); 
      // wready_gen.set_low_time(3); 
      // wready_gen.set_high_time(3); 
      // wready_gen.set_low_time_range(3,6); 
      // wready_gen.set_high_time_range(3,6); 
      // slv.wr_driver.send_wready(wready_gen);
     // end
     slv.wr_driver.send_wready(wready_gen);
     slv.wr_driver.send(twr);
	 // $display("%0t ACP sending the element to driver",$time);
     wr_delayed = 0;
     awvalid_flag[bresp_time_cnt] = 1'b0;
     bresp_time_cnt = bresp_time_cnt+1;
     rd_bresp_cnt = rd_bresp_cnt + 1;
	 if(rd_bresp_cnt == 2'd2) begin
	   wr_fifo_full_flag = 1'b0; 
	 end
      if(rd_bresp_cnt[int_wr_cntr_width-1:0] === (max_wr_outstanding_transactions)) begin
        // rd_bresp_cnt[int_wr_cntr_width] = ~ rd_bresp_cnt[int_wr_cntr_width];
        rd_bresp_cnt[int_wr_cntr_width-1:0] = 0;
      end
      if(bresp_time_cnt[int_wr_cntr_width-1:0] === max_wr_outstanding_transactions) begin
        bresp_time_cnt[int_wr_cntr_width-1:0] = 0; 
      end
     wr_latency_count = get_wr_lat_number(1);
     // wr_latency_count = 5;
	 static_count++;
   end 
	 static_count++;
  end // else
  end//always
  /*--------------------------------------------------------------------------------*/

  /* Reading from the wr_fifo */
  always@(negedge S_RESETN or posedge SW_CLK) begin
  if(!S_RESETN) begin 
   WR_DATA_VALID_DDR = 1'b0;
   WR_DATA_VALID_OCM = 1'b0;
   wr_fifo_rd_ptr = 0;
   state = SEND_DATA;
   WR_QOS = 0;
  end else begin
   case(state)
   SEND_DATA :begin
      state = SEND_DATA;
      WR_DATA_VALID_OCM = 0;
      WR_DATA_VALID_DDR = 0;
      if(!wr_fifo_empty) begin
        WR_DATA  = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-1:0]][wr_data_msb : wr_data_lsb];
        WR_ADDR  = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-1:0]][wr_addr_msb : wr_addr_lsb];
        WR_BYTES = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-1:0]][wr_bytes_msb : wr_bytes_lsb];
        WR_QOS   = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-1:0]][wr_qos_msb : wr_qos_lsb];
		WR_DATA_STRB = wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-1:0]][wr_strb_msb : wr_strb_lsb];
        state = WAIT_ACK;
		$display("ACP final WR_ADDR %0h WR_DATA %0h WR_DATA_STRB %0h wr_fifo_rd_ptr %0d",WR_ADDR,WR_DATA[31:0],WR_DATA_STRB,wr_fifo_rd_ptr[int_wr_cntr_width-1:0]);
        case (decode_address(wr_fifo[wr_fifo_rd_ptr[int_wr_cntr_width-1:0]][wr_addr_msb : wr_addr_lsb]))
         OCM_MEM : WR_DATA_VALID_OCM = 1;
         DDR_MEM : WR_DATA_VALID_DDR = 1;
         default : state = SEND_DATA;
        endcase
        wr_fifo_rd_ptr = wr_fifo_rd_ptr+1;
		if(wr_fifo_rd_ptr[int_wr_cntr_width-1:0] === (max_wr_outstanding_transactions)) begin
           wr_fifo_rd_ptr[int_wr_cntr_width] = ~ wr_fifo_rd_ptr[int_wr_cntr_width];
           wr_fifo_rd_ptr[int_wr_cntr_width-1:0] = 0;
	       // $display(" ACP resetting the wr_fifo_rd_ptr counter %0d " , wr_fifo_rd_ptr);
     end

      end
      end
   WAIT_ACK :begin
      state = WAIT_ACK;
      if(WR_DATA_ACK_OCM | WR_DATA_ACK_DDR) begin 
        WR_DATA_VALID_OCM = 1'b0;
        WR_DATA_VALID_DDR = 1'b0;
        state = SEND_DATA;
      end
      end
   endcase
  end
  end
  /*--------------------------------------------------------------------------------*/
/*-------------------------------- WRITE HANDSHAKE END ----------------------------------------*/

/*-------------------------------- READ HANDSHAKE ---------------------------------------------*/

  /* READ CHANNELS */
  /* Store the arvalid receive time --- necessary for calculating latency in sending the rresp latency */
  reg [int_rd_cntr_width-1:0] ar_time_cnt = 0,rresp_time_cnt = 0;
  real arvalid_receive_time[0:max_rd_outstanding_transactions-1]; // store the time when a new arvalid is received
  reg arvalid_flag[0:max_rd_outstanding_transactions-1]; // store the time when a new arvalid is received
  reg [int_rd_cntr_width-1:0] ar_cnt = 0; // counter for arvalid info

  /* various FIFOs for storing the ADDR channel info */
  reg [axi_size_width-1:0]  arsize [0:max_rd_outstanding_transactions-1];
  reg [axi_prot_width-1:0]  arprot [0:max_rd_outstanding_transactions-1];
  reg [axi_brst_type_width-1:0]  arbrst [0:max_rd_outstanding_transactions-1];
  reg [axi_len_width-1:0]  arlen [0:max_rd_outstanding_transactions-1];
  reg [axi_cache_width-1:0]  arcache [0:max_rd_outstanding_transactions-1];
  reg [axi_lock_width-1:0]  arlock [0:max_rd_outstanding_transactions-1];
  reg ar_flag [0:max_rd_outstanding_transactions-1];
  reg [addr_width-1:0] araddr [0:max_rd_outstanding_transactions-1];
  reg [addr_width-1:0] addr_local;
  reg [addr_width-1:0] addr_final;
  reg [id_bus_width-1:0]  arid [0:max_rd_outstanding_transactions-1];
  reg [axi_qos_width-1:0]  arqos [0:max_rd_outstanding_transactions-1];
  wire ar_fifo_full; // indicates arvalid_fifo is full (max outstanding transactions reached)

  reg [int_rd_cntr_width-1:0] rd_cnt = 0;
  reg [int_rd_cntr_width-1:0] trr_rd_cnt = 0;
  reg [int_rd_cntr_width-1:0] wr_rresp_cnt = 0;
  reg [axi_rsp_width-1:0] rresp;
  reg [rsp_fifo_bits-1:0] fifo_rresp [0:max_rd_outstanding_transactions-1]; // store the ID and its corresponding response

  /* Send Read Response  & Data Channel handshake */
  integer rd_latency_count;
  reg  rd_delayed;
  reg  read_fifo_empty;

  reg [max_burst_bits-1:0] read_fifo [0:max_rd_outstanding_transactions-1]; /// Store only AXI Burst Data ..
  reg [int_rd_cntr_width-1:0] rd_fifo_wr_ptr = 0, rd_fifo_rd_ptr = 0;
  wire read_fifo_full; 
 
  assign read_fifo_full = (rd_fifo_wr_ptr[int_rd_cntr_width-1] !== rd_fifo_rd_ptr[int_rd_cntr_width-1] && rd_fifo_wr_ptr[int_rd_cntr_width-1:0] === rd_fifo_rd_ptr[int_rd_cntr_width-1:0])?1'b1: 1'b0;
  assign read_fifo_empty = (rd_fifo_wr_ptr === rd_fifo_rd_ptr)?1'b1: 1'b0;
  assign ar_fifo_full = ((ar_cnt[int_rd_cntr_width-1] !== rd_cnt[int_rd_cntr_width-1]) && (ar_cnt[int_rd_cntr_width-1:0] === rd_cnt[int_rd_cntr_width-1:0]))?1'b1 :1'b0; 

  /* Store the arvalid receive time --- necessary for calculating the bresp latency */
  always@(negedge S_RESETN or posedge S_ACLK)
  begin
  if(!S_RESETN)
   ar_time_cnt = 0;
  else begin
  if(net_ARVALID == 'b1 && S_ARREADY == 'b1) begin
     arvalid_receive_time[ar_time_cnt] = $time;
     arvalid_flag[ar_time_cnt] = 1'b1;
     ar_time_cnt = ar_time_cnt + 1;
	 // $display(" %m current ar_time_cnt %0d",ar_time_cnt);
     if((ar_time_cnt === max_rd_outstanding_transactions) ) begin
       ar_time_cnt = 0; 
	   // $display("reached max count max_rd_outstanding_transactions %0d aw_time_cnt %0d",max_rd_outstanding_transactions,ar_time_cnt);
	   // $display(" resetting the read ar_time_cnt counter %0d", ar_time_cnt);
	 end   
   end 
  end // else
  end /// always
  /*--------------------------------------------------------------------------------*/
  always@(posedge S_ACLK)
  begin
  if(net_ARVALID == 'b1 && S_ARREADY == 'b1) begin
    if(S_ARQOS === 0) begin 
      arqos[ar_cnt[int_rd_cntr_width-1:0]] = ar_qos; 
    end else begin 
      arqos[ar_cnt[int_rd_cntr_width-1:0]] = S_ARQOS; 
    end
  end
  end
  /*--------------------------------------------------------------------------------*/
  
  always@(ar_fifo_full)
  begin
  if(ar_fifo_full && DEBUG_INFO) 
    $display("[%0d] : %0s : %0s : Reached the maximum outstanding Read transactions limit (%0d). Blocking all future Read transactions until at least 1 of the outstanding Read transaction has completed.",$time, DISP_INFO, slave_name,max_rd_outstanding_transactions);
  end
  /*--------------------------------------------------------------------------------*/
  
  /* Address Read  Channel handshake*/
  // always@(negedge S_RESETN or posedge S_ACLK)
  // begin
  initial begin
  forever begin
  if(!S_RESETN) begin
    ar_cnt = 0;
  end else begin
    // if(!ar_fifo_full) begin
    wait(ar_fifo_full != 1) begin
      slv.monitor.axi_rd_cmd_port.get(trc);
      // araddr[ar_cnt[int_rd_cntr_width-2:0]] = trc.addr;
      arlen[ar_cnt[int_rd_cntr_width-1:0]]  = trc.len;
      arsize[ar_cnt[int_rd_cntr_width-1:0]] = trc.size;
      arbrst[ar_cnt[int_rd_cntr_width-1:0]] = trc.burst;
      arlock[ar_cnt[int_rd_cntr_width-1:0]] = trc.lock;
      arcache[ar_cnt[int_rd_cntr_width-1:0]]= trc.cache;
      arprot[ar_cnt[int_rd_cntr_width-1:0]] = trc.prot;
      arid[ar_cnt[int_rd_cntr_width-1:0]]   = trc.id;
      ar_flag[ar_cnt[int_rd_cntr_width-1:0]] = 1'b1;
	  size_local = trc.size;
	  addr_local = trc.addr;
	  case(size_local) 
	    0   : addr_final = {addr_local}; 
	    1   : addr_final = {addr_local[31:1],1'b0}; 
	    2   : addr_final = {addr_local[31:2],2'b0}; 
	    3   : addr_final = {addr_local[31:3],3'b0}; 
	    4   : addr_final = {addr_local[31:4],4'b0}; 
	    5   : addr_final = {addr_local[31:5],5'b0}; 
	    6   : addr_final = {addr_local[31:6],6'b0}; 
	    7   : addr_final = {addr_local[31:7],7'b0}; 
	  endcase	  
	    araddr[ar_cnt[int_rd_cntr_width-1:0]] = addr_final;
        ar_cnt = ar_cnt+1;
		// $display(" READ address addr_final %0h ar_cnt %0d",addr_final,ar_cnt);
        if(ar_cnt[int_rd_cntr_width-1:0] === max_rd_outstanding_transactions) begin
          ar_cnt[int_rd_cntr_width] = ~ ar_cnt[int_rd_cntr_width];
          ar_cnt[int_rd_cntr_width-1:0] = 0;
		  // $display(" reseeting the read ar_cnt %0d",ar_cnt);
        end 
    end /// if(!ar_fifo_full)
  end /// if else
  end /// forever
  end /// always*/
  /*--------------------------------------------------------------------------------*/

  /* Align Wrap data for read transaction*/
  task automatic get_wrap_aligned_rd_data;
  output [(data_bus_width*axi_burst_len)-1:0] aligned_data;
  input [addr_width-1:0] addr;
  input [(data_bus_width*axi_burst_len)-1:0] b_data;
  input [max_burst_bytes_width:0] v_bytes;
  reg [addr_width-1:0] start_addr;
  reg [(data_bus_width*axi_burst_len)-1:0] temp_data, wrp_data;
  integer wrp_bytes;
  integer i;
  begin
    start_addr = (addr/v_bytes) * v_bytes;
    wrp_bytes = addr - start_addr;
    wrp_data  = b_data;
    temp_data = 0;
    while(wrp_bytes > 0) begin /// get the data that is wrapped
     temp_data = temp_data >> 8;
     temp_data[(data_bus_width*axi_burst_len)-1 : (data_bus_width*axi_burst_len)-8] = wrp_data[7:0];
     wrp_data = wrp_data >> 8;
     wrp_bytes = wrp_bytes - 1;
    end
    temp_data = temp_data >> ((data_bus_width*axi_burst_len) - (v_bytes*8));
    wrp_bytes = addr - start_addr;
    wrp_data = b_data >> (wrp_bytes*8);
    
    aligned_data = (temp_data | wrp_data);
  end
  endtask
  /*--------------------------------------------------------------------------------*/
   
  parameter RD_DATA_REQ = 1'b0, WAIT_RD_VALID = 1'b1;
  reg [addr_width-1:0] temp_read_address;
  reg [max_burst_bytes_width:0] temp_rd_valid_bytes;
  reg rd_fifo_state; 
  reg invalid_rd_req;
  /* get the data from memory && also calculate the rresp*/
  always@(negedge S_RESETN or posedge SW_CLK)
  begin
  if(!S_RESETN)begin
   rd_fifo_wr_ptr = 0; 
   wr_rresp_cnt =0;
   rd_fifo_state = RD_DATA_REQ;
   temp_rd_valid_bytes = 0;
   temp_read_address = 0;
   RD_REQ_DDR = 0;
   RD_REQ_OCM = 0;
   RD_REQ_REG = 0;
   RD_QOS  = 0;
   invalid_rd_req = 0;
  end else begin
   case(rd_fifo_state)
    RD_DATA_REQ : begin
     rd_fifo_state = RD_DATA_REQ;
     RD_REQ_DDR = 0;
     RD_REQ_OCM = 0;
     RD_REQ_REG = 0;
     RD_QOS  = 0;
     wait(ar_flag[wr_rresp_cnt[int_rd_cntr_width-1:0]] == 1'b1 && read_fifo_full == 0) begin
       // $display(" got the element for ar_flag %0h wr_rresp_cnt[int_rd_cntr_width-1:0] %0d ",ar_flag[wr_rresp_cnt[int_rd_cntr_width-1:0]],wr_rresp_cnt[int_rd_cntr_width-1:0]);
       ar_flag[wr_rresp_cnt[int_rd_cntr_width-1:0]] = 0;
       rresp = calculate_resp(1'b1, araddr[wr_rresp_cnt[int_rd_cntr_width-1:0]],arprot[wr_rresp_cnt[int_rd_cntr_width-1:0]]);
       fifo_rresp[wr_rresp_cnt[int_rd_cntr_width-1:0]] = {arid[wr_rresp_cnt[int_rd_cntr_width-1:0]],rresp};
       temp_rd_valid_bytes = (arlen[wr_rresp_cnt[int_rd_cntr_width-1:0]]+1)*(2**arsize[wr_rresp_cnt[int_rd_cntr_width-1:0]]);//data_bus_width/8;
       // $display(" got the element for id %0h ",arid[wr_rresp_cnt[int_rd_cntr_width-1:0]]);

       if(arbrst[wr_rresp_cnt[int_rd_cntr_width-1:0]] === AXI_WRAP) /// wrap begin
        temp_read_address = (araddr[wr_rresp_cnt[int_rd_cntr_width-1:0]]/temp_rd_valid_bytes) * temp_rd_valid_bytes;
       else 
        temp_read_address = araddr[wr_rresp_cnt[int_rd_cntr_width-1:0]];
       if(rresp === AXI_OK) begin 
        case(decode_address(temp_read_address))//decode_address(araddr[wr_rresp_cnt[int_rd_cntr_width-2:0]]);
          OCM_MEM : RD_REQ_OCM = 1;
          DDR_MEM : RD_REQ_DDR = 1;
          REG_MEM : RD_REQ_REG = 1;
          default : invalid_rd_req = 1;
        endcase
       end else
        invalid_rd_req = 1;
        
       RD_QOS     = arqos[wr_rresp_cnt[int_rd_cntr_width-1:0]];
       RD_ADDR    = temp_read_address; ///araddr[wr_rresp_cnt[int_rd_cntr_width-2:0]];
       RD_BYTES   = temp_rd_valid_bytes;
       rd_fifo_state = WAIT_RD_VALID;
       wr_rresp_cnt = wr_rresp_cnt + 1;
	   // $display(" before resetting the read wr_rresp_cnt counter %0d", wr_rresp_cnt);
	   // $display(" final read address RD_ADDR %0h RD_BYTES %0h" , RD_ADDR,RD_BYTES);
       if(wr_rresp_cnt[int_rd_cntr_width-1:0] === max_rd_outstanding_transactions) begin
         wr_rresp_cnt[int_rd_cntr_width] = ~ wr_rresp_cnt[int_rd_cntr_width];
         wr_rresp_cnt[int_rd_cntr_width-1:0] = 0;
		 // $display(" resetting the read wr_rresp_cnt counter %0d", wr_rresp_cnt);
       end
     end
    end
    WAIT_RD_VALID : begin    
     rd_fifo_state = WAIT_RD_VALID; 
     if(RD_DATA_VALID_OCM | RD_DATA_VALID_DDR | RD_DATA_VALID_REG | invalid_rd_req) begin ///temp_dec == 2'b11) begin
       if(RD_DATA_VALID_DDR)
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-1:0]] = RD_DATA_DDR;
       else if(RD_DATA_VALID_OCM)
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-1:0]] = RD_DATA_OCM;
       else if(RD_DATA_VALID_REG)
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-1:0]] = RD_DATA_REG;
       else
         read_fifo[rd_fifo_wr_ptr[int_rd_cntr_width-1:0]] = 0;
       rd_fifo_wr_ptr = rd_fifo_wr_ptr + 1;
       if(rd_fifo_wr_ptr[int_rd_cntr_width-1:0] === (max_rd_outstanding_transactions)) begin
         rd_fifo_wr_ptr[int_rd_cntr_width]  = ~rd_fifo_wr_ptr[int_rd_cntr_width] ;
         rd_fifo_wr_ptr[int_rd_cntr_width-1:0] = 0;
	     // $display(" resetting the read rd_fifo_wr_ptr counter %0d", rd_fifo_wr_ptr);
	   end
       RD_REQ_DDR = 0;
       RD_REQ_OCM = 0;
       RD_REQ_REG = 0;
       RD_QOS  = 0;
       invalid_rd_req = 0;
       rd_fifo_state = RD_DATA_REQ;
     end
    end
   endcase
  end /// else
  end /// always

  /*--------------------------------------------------------------------------------*/
  reg[max_burst_bytes_width:0] rd_v_b;
  reg [(data_bus_width*axi_burst_len)-1:0] temp_read_data;
  reg [(data_bus_width*axi_burst_len)-1:0] temp_wrap_data;
  reg[(axi_rsp_width*axi_burst_len)-1:0] temp_read_rsp;

  xil_axi_data_beat new_data;


  /* Read Data Channel handshake */
  //always@(negedge S_RESETN or posedge S_ACLK)
  initial begin
    forever begin
      if(!S_RESETN)begin
       // rd_fifo_rd_ptr = 0;
       trr_rd_cnt = 0;
       // rd_latency_count = get_rd_lat_number(1);
       // rd_delayed = 0;
       // rresp_time_cnt = 0;
       // rd_v_b = 0;
      end else begin
         //if(net_ARVALID && S_ARREADY)
           // trr_rd[trr_rd_cnt] = new("trr_rd[trr_rd_cnt]");
           // trr_rd[trr_rd_cnt] = new($psprintf("trr_rd[%0d]",trr_rd_cnt));
           slv.rd_driver.get_rd_reactive(trr);
		   // $display(" got the id form slv trr.id %0h" trr.id);
		   trr_rd.push_back(trr.my_clone());
		   //$cast(trr_rd[trr_rd_cnt],trr.copy());
           // rd_latency_count = get_rd_lat_number(1);
           // $display("%m waiting for next transfer trr_rd_cnt %0d trr.size %0d " ,trr_rd_cnt,trr.size);
           // $display("%m waiting for next transfer trr_rd_cnt %0d trr_rd[trr_rd_cnt] %0d" ,trr_rd_cnt,trr_rd[trr_rd_cnt].size);
		   trr_rd_cnt++;
           $display("%m waiting for next transfer trr_rd_cnt %0d" ,trr_rd_cnt);
		   // @(posedge S_ACLK);
         end
    end // forever
    end // initial


  initial begin
    forever begin
  if(!S_RESETN)begin
   rd_fifo_rd_ptr = 0;
   rd_cnt = 0;
   // rd_latency_count = get_rd_lat_number(1);
   rd_latency_count = 20;
   rd_delayed = 0;
   rresp_time_cnt = 0;
   rd_v_b = 0;
  end else begin
     //if(net_ARVALID && S_ARREADY)
       // slv.rd_driver.get_rd_reactive(trr_rd[rresp_time_cnt]);
       wait(arvalid_flag[rresp_time_cnt] == 1);
	   // while(trr_rd[rresp_time_cnttrr_rd_cnt] == null) begin
  	   // @(posedge S_ACLK);
	   // end
       // rd_latency_count = get_rd_lat_number(1);
       rd_latency_count = 20; 
	    // $display("%m waiting for element form vip rresp_time_cnt %0d ",rresp_time_cnt);
	    // while(trr_rd.size()< 0 ) begin
	    // $display("%m got the element form vip rresp_time_cnt %0d ",rresp_time_cnt);
  	    // @(posedge S_ACLK);
	    // end
	    // $display("%m got the element form vip rresp_time_cnt %0d ",rresp_time_cnt);
		wait(trr_rd.size() > 0);
		trr_get_rd = trr_rd.pop_front();
        // $display("%m got the element trr_rd waiting for next transfer rresp_time_cnt %0d trr_get_rd.id %0h" ,rresp_time_cnt,trr_get_rd.id);
     while ((arvalid_flag[rresp_time_cnt] == 'b1 )&& ((($realtime - arvalid_receive_time[rresp_time_cnt])/diff_time) < rd_latency_count)) begin
  	   @(posedge S_ACLK);
     end

     //if(arvalid_flag[rresp_time_cnt] && ((($realtime - arvalid_receive_time[rresp_time_cnt])/diff_time) >= rd_latency_count)) 
       rd_delayed = 1;
       // $display("%m   reading form rd_delayed %0d read_fifo_empty %0d next transfer rresp_time_cnt %0d trr_get_rd.id %0h",rd_delayed ,~read_fifo_empty,rresp_time_cnt,trr_get_rd.id);
     if(!read_fifo_empty && rd_delayed)begin
       rd_delayed = 0;  
       // $display("%m   reading form rd_delayed %0d next transfer rresp_time_cnt %0d trr_get_rd.id %0h",rd_delayed ,rresp_time_cnt,trr_get_rd.id);
       arvalid_flag[rresp_time_cnt] = 1'b0;
       rd_v_b = ((arlen[rd_cnt[int_rd_cntr_width-1:0]]+1)*(2**arsize[rd_cnt[int_rd_cntr_width-1:0]]));
       temp_read_data =  read_fifo[rd_fifo_rd_ptr[int_rd_cntr_width-1:0]];
       rd_fifo_rd_ptr = rd_fifo_rd_ptr+1;

       if(arbrst[rd_cnt[int_rd_cntr_width-1:0]]=== AXI_WRAP) begin
         get_wrap_aligned_rd_data(temp_wrap_data, araddr[rd_cnt[int_rd_cntr_width-1:0]], temp_read_data, rd_v_b);
         temp_read_data = temp_wrap_data;
       end 
       temp_read_rsp = 0;
       repeat(axi_burst_len) begin
         temp_read_rsp = temp_read_rsp >> axi_rsp_width;
         temp_read_rsp[(axi_rsp_width*axi_burst_len)-1:(axi_rsp_width*axi_burst_len)-axi_rsp_width] = fifo_rresp[rd_cnt[int_rd_cntr_width-1:0]][rsp_msb : rsp_lsb];
       end 
	   case (arsize[rd_cnt[int_rd_cntr_width-1:0]])
         3'b000: trr_get_rd.size = XIL_AXI_SIZE_1BYTE;
         3'b001: trr_get_rd.size = XIL_AXI_SIZE_2BYTE;
         3'b010: trr_get_rd.size = XIL_AXI_SIZE_4BYTE;
         3'b011: trr_get_rd.size = XIL_AXI_SIZE_8BYTE;
         3'b100: trr_get_rd.size = XIL_AXI_SIZE_16BYTE;
         3'b101: trr_get_rd.size = XIL_AXI_SIZE_32BYTE;
         3'b110: trr_get_rd.size = XIL_AXI_SIZE_64BYTE;
         3'b111: trr_get_rd.size = XIL_AXI_SIZE_128BYTE;
       endcase
	   trr_get_rd.len = arlen[rd_cnt[int_rd_cntr_width-1:0]];
	   trr_get_rd.id = (arid[rd_cnt[int_rd_cntr_width-1:0]]);
//	   trr_get_rd.data  = new[((2**arsize[rd_cnt[int_rd_cntr_width-2:0]])*(arlen[rd_cnt[int_rd_cntr_width-2:0]]+1))];
	   trr_get_rd.rresp = new[((2**arsize[rd_cnt[int_rd_cntr_width-1:0]])*(arlen[rd_cnt[int_rd_cntr_width-1:0]]+1))];
       // $display("%m   updateing reading form trr_get_rd.id %0d next transfer rresp_time_cnt %0d trr_get_rd.id %0h",trr_get_rd.id,rresp_time_cnt,trr_get_rd.id);
       for(j = 0; j < (arlen[rd_cnt[int_rd_cntr_width-1:0]]+1); j = j+1) begin
         for(k = 0; k < (2**arsize[rd_cnt[int_rd_cntr_width-1:0]]); k = k+1) begin
		   new_data[(k*8)+:8] = temp_read_data[7:0];
		   temp_read_data = temp_read_data >> 8;
		 end
         trr_get_rd.set_data_beat(j, new_data);
		 // $display("Read data %0h trr_get_rd.id %0h rd_cnt[int_rd_cntr_width-1:0] %0d",new_data,trr_get_rd.id,rd_cnt[int_rd_cntr_width-1:0]);
	     case(temp_read_rsp[(j*2)+:2])
	       2'b00: trr_get_rd.rresp[j] = XIL_AXI_RESP_OKAY;
	       2'b01: trr_get_rd.rresp[j] = XIL_AXI_RESP_EXOKAY;
	       2'b10: trr_get_rd.rresp[j] = XIL_AXI_RESP_SLVERR;
	       2'b11: trr_get_rd.rresp[j] = XIL_AXI_RESP_DECERR;
	     endcase
       end
       slv.rd_driver.send(trr_get_rd);
       rd_cnt = rd_cnt + 1; 
       rresp_time_cnt = rresp_time_cnt+1;
	   // $display("current rresp_time_cnt %0d rd_cnt %0d",rresp_time_cnt,rd_cnt[int_rd_cntr_width-1:0]);
       if(rd_cnt[int_rd_cntr_width-1:0] === (max_rd_outstanding_transactions)) begin
         rd_cnt[int_rd_cntr_width] = ~ rd_cnt[int_rd_cntr_width];
         rd_cnt[int_rd_cntr_width-1:0] = 0;
	     // $display(" resetting the read rd_cnt counter %0d", rd_cnt);
       end
       if(rresp_time_cnt[int_rd_cntr_width-1:0] === (max_rd_outstanding_transactions)) begin
         rresp_time_cnt[int_rd_cntr_width]  = ~ rresp_time_cnt[int_rd_cntr_width] ;
         rresp_time_cnt[int_rd_cntr_width-1:0] = 0;
	     // $display(" resetting the read rresp_time_cnt counter %0d", rresp_time_cnt);
	   end
       if(rd_fifo_rd_ptr[int_rd_cntr_width-1:0] === (max_rd_outstanding_transactions)) begin
         rd_fifo_rd_ptr[int_rd_cntr_width]  = ~rd_fifo_rd_ptr[int_rd_cntr_width] ;
         rd_fifo_rd_ptr[int_rd_cntr_width-1:0] = 0;
	     // $display(" resetting the read rd_fifo_rd_ptr counter %0d", rd_fifo_rd_ptr);
	   end
       rd_latency_count = get_rd_lat_number(1);
     end
  end /// else
  end /// always
end
endmodule




/**************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_axi_master.sv
 *
 * Date : 2012-11
 *
 * Description : Model that acts as PS AXI Master port interface. 
 *               It uses AXI3 Master BFM
 *****************************************************************************/
 `timescale 1ns/1ps
import axi_vip_pkg::*;
 `define M_AWUSER_DEF 'b0
 `define M_ARUSER_DEF 'b0

module zynq_ultra_ps_e_vip_v1_0_6_axi_master (
    M_RESETN,
    M_ARVALID,
    M_AWVALID,
    M_BREADY,
    M_RREADY,
    M_WLAST,
    M_WVALID,
    M_ARID,
    M_AWID,
    M_ARBURST,
    M_ARLOCK,
    M_ARSIZE,
    M_AWBURST,
    M_AWLOCK,
    M_AWSIZE,
    M_ARPROT,
    M_AWPROT,
    M_ARADDR,
    M_AWADDR,
    M_WDATA,
    M_ARCACHE,
    M_ARLEN,
    M_AWCACHE,
    M_AWLEN,
    M_ARQOS,
    M_AWQOS,
    M_AWREGION,
    M_ARREGION,
    M_AWUSER,
    M_WUSER,
    M_BUSER,
    M_ARUSER,
    M_RUSER,
    M_WSTRB,
    M_ACLK,
    M_ARREADY,
    M_AWREADY,
    M_BVALID,
    M_RLAST,
    M_RVALID,
    M_WREADY,
    M_BID,
    M_RID,
    M_BRESP,
    M_RRESP,
    M_RDATA

);
   parameter enable_this_port = 0;  
   parameter master_name = "Master";
   parameter data_bus_width = 32;
   parameter address_bus_width = 32;
   parameter id_bus_width = 6;
   parameter awuser_bus_width = 1;
   parameter aruser_bus_width = 1;
   parameter ruser_bus_width  = 1;
   parameter wuser_bus_width  = 1;
   parameter buser_bus_width  = 1;
   parameter max_outstanding_transactions = 8;
   parameter exclusive_access_supported = 0;
   parameter WR_ID = 16'h0800;
   parameter RD_ID = 16'h0900;
   parameter ID = 12'hC00;
   parameter region_bus_width = 1;
   `include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

    /* IDs for Masters 
       // l2m1 (CPU000)
       12'b11_000_000_00_00    
       12'b11_010_000_00_00     
       12'b11_011_000_00_00   
       12'b11_100_000_00_00   
       12'b11_101_000_00_00   
       12'b11_110_000_00_00     
       12'b11_111_000_00_00     
       // l2m1 (CPU001)
       12'b11_000_001_00_00    
       12'b11_010_001_00_00     
       12'b11_011_001_00_00    
       12'b11_100_001_00_00    
       12'b11_101_001_00_00    
       12'b11_110_001_00_00     
       12'b11_111_001_00_00    
   */

   input  M_RESETN;

   output M_ARVALID;
   output M_AWVALID;
   output M_BREADY;
   output M_RREADY;
   output M_WLAST;
   output M_WVALID;
   output [id_bus_width-1:0] M_ARID;
   output [id_bus_width-1:0] M_AWID;
   output [axi_brst_type_width-1:0] M_ARBURST;
   output [axi_lock_width-1:0] M_ARLOCK;
   output [axi_size_width-1:0] M_ARSIZE;
   output [axi_brst_type_width-1:0] M_AWBURST;
   output [axi_lock_width-1:0] M_AWLOCK;
   output [axi_size_width-1:0] M_AWSIZE;
   output [axi_prot_width-1:0] M_ARPROT;
   output [axi_prot_width-1:0] M_AWPROT;
   output [address_bus_width-1:0] M_ARADDR;
   output [address_bus_width-1:0] M_AWADDR;
   output [data_bus_width-1:0] M_WDATA;
   output [axi_cache_width-1:0] M_ARCACHE;
   output [axi_len_width-1:0] M_ARLEN;
   output [axi_qos_width-1:0] M_ARQOS;  // not connected to AXI BFM
   output [axi_cache_width-1:0] M_AWCACHE;
   output [axi_len_width-1:0] M_AWLEN;
   output [axi_qos_width-1:0] M_AWQOS;  // not connected to AXI BFM
   output [(data_bus_width/8)-1:0] M_WSTRB;
   output [region_bus_width-1:0] M_AWREGION;
   output [region_bus_width-1:0] M_ARREGION;
   output [awuser_bus_width-1:0] M_AWUSER;
   output [wuser_bus_width-1:0] M_WUSER;
   input  [buser_bus_width-1:0] M_BUSER;
   output [aruser_bus_width-1:0] M_ARUSER;
   input [ruser_bus_width-1:0] M_RUSER;
   input M_ACLK;
   input M_ARREADY;
   input M_AWREADY;
   input M_BVALID;
   input M_RLAST;
   input M_RVALID;
   input M_WREADY;
   input [id_bus_width-1:0] M_BID;
   input [id_bus_width-1:0] M_RID;
   input [axi_rsp_width-1:0] M_BRESP;
   input [axi_rsp_width-1:0] M_RRESP;
   input [data_bus_width-1:0] M_RDATA;

   wire net_RESETN;
   wire net_RVALID;
   wire net_BVALID;
   reg DEBUG_INFO = 1'b1; 
   reg STOP_ON_ERROR = 1'b1; 

   integer use_id_no = 0;
   
   wire [axi_qos_width-1:0] M_ARQOS ;
   wire [axi_qos_width-1:0] M_AWQOS ;

   assign M_AWUSER = `M_AWUSER_DEF ;
   assign M_ARUSER = `M_ARUSER_DEF ;
   assign net_RESETN = M_RESETN; //ENABLE_THIS_PORT ? M_RESETN : 1'b0;
   assign net_RVALID = enable_this_port ? M_RVALID : 1'b0;
   assign net_BVALID = enable_this_port ? M_BVALID : 1'b0;

  initial begin
   if(DEBUG_INFO) begin
    if(enable_this_port)
     $display("[%0d] : %0s : %0s : Port is ENABLED.",$time, DISP_INFO, master_name);
    else
     $display("[%0d] : %0s : %0s : Port is DISABLED.",$time, DISP_INFO, master_name);
   end
  end

   // initial master.set_disable_reset_value_checks(1); 
   initial master.IF.xilinx_slave_ready_check_enable = 0;
   // initial M_AWUSER = `M_AWUSER_DEF ;
   // initial M_ARUSER = `M_ARUSER_DEF ;
   initial begin
      repeat(2) @(posedge M_ACLK);
      if(!enable_this_port) begin
      //   master.set_channel_level_info(0);
      //   master.set_function_level_info(0);
      end
     // master.RESPONSE_TIMEOUT = 0;
   end

   



     axi_mst_agent#(0,address_bus_width, data_bus_width, data_bus_width, id_bus_width,id_bus_width,0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1) mst;

 
    axi_vip_v1_1_6_top #(
      .C_AXI_PROTOCOL(0),
      .C_AXI_INTERFACE_MODE(0),
      .C_AXI_ADDR_WIDTH(address_bus_width),
      .C_AXI_WDATA_WIDTH(data_bus_width),
      .C_AXI_RDATA_WIDTH(data_bus_width),
      .C_AXI_WID_WIDTH(id_bus_width),
      .C_AXI_RID_WIDTH(id_bus_width),
      .C_AXI_AWUSER_WIDTH(0),
      .C_AXI_ARUSER_WIDTH(0),
      .C_AXI_WUSER_WIDTH(0),
      .C_AXI_RUSER_WIDTH(0),
      .C_AXI_BUSER_WIDTH(0),
      .C_AXI_SUPPORTS_NARROW(1),
      .C_AXI_HAS_BURST(1),
      .C_AXI_HAS_LOCK(1),
      .C_AXI_HAS_CACHE(1),
      .C_AXI_HAS_REGION(0),
      .C_AXI_HAS_PROT(1),
      .C_AXI_HAS_QOS(1),
      .C_AXI_HAS_WSTRB(1),
      .C_AXI_HAS_BRESP(1),
      .C_AXI_HAS_RRESP(1),
 	 .C_AXI_HAS_ARESETN(1)
    ) master (
      .aclk(M_ACLK),
      .aclken(1'B1),
      .aresetn(net_RESETN),
      .s_axi_awid(12'h000),
      .s_axi_awaddr(32'B0),
      .s_axi_awlen(4'h0),
      .s_axi_awsize(3'B0),
      .s_axi_awburst(2'B0),
      .s_axi_awlock(2'b00),
      .s_axi_awcache(4'B0),
      .s_axi_awprot(3'B0),
      .s_axi_awregion(4'B0),
      .s_axi_awqos(4'B0),
      .s_axi_awuser(1'B0),
      .s_axi_awvalid(1'B0),
      .s_axi_awready(),
      .s_axi_wid(12'h000),
      .s_axi_wdata(32'B0),
      .s_axi_wstrb(4'B0),
      .s_axi_wlast(1'B0),
      .s_axi_wuser(1'B0),
      .s_axi_wvalid(1'B0),
      .s_axi_wready(),
      .s_axi_bid(),
      .s_axi_bresp(),
      .s_axi_buser(),
      .s_axi_bvalid(),
      .s_axi_bready(1'B0),
      .s_axi_arid(12'h000),
      .s_axi_araddr(32'B0),
      .s_axi_arlen(4'h0),
      .s_axi_arsize(3'B0),
      .s_axi_arburst(2'B0),
      .s_axi_arlock(2'b00),
      .s_axi_arcache(4'B0),
      .s_axi_arprot(3'B0),
      .s_axi_arregion(4'B0),
      .s_axi_arqos(4'B0),
      .s_axi_aruser(1'B0),
      .s_axi_arvalid(1'B0),
      .s_axi_arready(),
      .s_axi_rid(),
      .s_axi_rdata(),
      .s_axi_rresp(),
      .s_axi_rlast(),
      .s_axi_ruser(),
      .s_axi_rvalid(),
      .s_axi_rready(1'B0),
      .m_axi_awid(M_AWID),
      .m_axi_awaddr(M_AWADDR),
      .m_axi_awlen(M_AWLEN),
      .m_axi_awsize(M_AWSIZE),
      .m_axi_awburst(M_AWBURST),
      .m_axi_awlock(M_AWLOCK),
      .m_axi_awcache(M_AWCACHE),
      .m_axi_awprot(M_AWPROT),
      .m_axi_awregion(),
      .m_axi_awqos(M_AWQOS),
      .m_axi_awuser(),
      .m_axi_awvalid(M_AWVALID),
      .m_axi_awready(M_AWREADY),
      // .m_axi_wid(M_WID),
      .m_axi_wdata(M_WDATA),
      .m_axi_wstrb(M_WSTRB),
      .m_axi_wlast(M_WLAST),
      .m_axi_wuser(),
      .m_axi_wvalid(M_WVALID),
      .m_axi_wready(M_WREADY),
      .m_axi_bid(M_BID),
      .m_axi_bresp(M_BRESP),
      .m_axi_buser(1'B0),
      .m_axi_bvalid(M_BVALID),
      .m_axi_bready(M_BREADY),
      .m_axi_arid(M_ARID),
      .m_axi_araddr(M_ARADDR),
      .m_axi_arlen(M_ARLEN),
      .m_axi_arsize(M_ARSIZE),
      .m_axi_arburst(M_ARBURST),
      .m_axi_arlock(M_ARLOCK),
      .m_axi_arcache(M_ARCACHE),
      .m_axi_arprot(M_ARPROT),
      .m_axi_arregion(),
      .m_axi_arqos(M_ARQOS),
      .m_axi_aruser(),
      .m_axi_arvalid(M_ARVALID),
      .m_axi_arready(M_ARREADY),
      .m_axi_rid(M_RID),
      .m_axi_rdata(M_RDATA),
      .m_axi_rresp(M_RRESP),
      .m_axi_rlast(M_RLAST),
      .m_axi_ruser(1'B0),
      .m_axi_rvalid(M_RVALID),
      .m_axi_rready(M_RREADY)
    );
 
 
 
    axi_transaction tw, tr;
    axi_monitor_transaction tr_m, tw_m;
    axi_ready_gen           bready_gen;
    axi_ready_gen           rready_gen;
 
   initial begin
    mst = new("mst",master.IF);
    tr_m = new("master monitor trans");
    mst.start_master();
   end

   initial begin
    master.IF.set_enable_xchecks_to_warn();
    repeat(10) @(posedge M_ACLK);
    master.IF.set_enable_xchecks();
   end 

 
 /* Call to VIP APIs */
 // task automatic read_burst(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,output [(axi_mgp_data_width*axi_burst_len)-1:0] data, output [(axi_rsp_width*axi_burst_len)-1:0] response);
 task automatic read_burst(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,output [(axi_burst_len*data_bus_width)-1:0] data, output [(axi_rsp_width*axi_burst_len)-1:0] response);
  integer i;
  xil_axi_burst_t burst_i;
  xil_axi_size_t  size_i;
  xil_axi_data_beat new_data;
  xil_axi_lock_t  lock_i;
  integer datasize;
  case (burst)
    2'b00: burst_i = XIL_AXI_BURST_TYPE_FIXED;
    2'b01: burst_i = XIL_AXI_BURST_TYPE_INCR;
    2'b10: burst_i = XIL_AXI_BURST_TYPE_WRAP;
    2'b11: burst_i = XIL_AXI_BURST_TYPE_RSVD;
  endcase
  case (siz)
    3'b000: size_i = XIL_AXI_SIZE_1BYTE;
    3'b001: size_i = XIL_AXI_SIZE_2BYTE;
    3'b010: size_i = XIL_AXI_SIZE_4BYTE;
    3'b011: size_i = XIL_AXI_SIZE_8BYTE;
    3'b100: size_i = XIL_AXI_SIZE_16BYTE;
    3'b101: size_i = XIL_AXI_SIZE_32BYTE;
    3'b110: size_i = XIL_AXI_SIZE_64BYTE;
    3'b111: size_i = XIL_AXI_SIZE_128BYTE;
  endcase
  case (lck)
    2'b00: lock_i = XIL_AXI_ALOCK_NOLOCK;
    2'b01: lock_i = XIL_AXI_ALOCK_EXCL;
    2'b10: lock_i = XIL_AXI_ALOCK_LOCKED;
    2'b11: lock_i = XIL_AXI_ALOCK_RSVD;
  endcase
  if(enable_this_port)begin
   fork 
     begin
       rready_gen = mst.rd_driver.create_ready("rready");
       rready_gen.set_ready_policy(XIL_AXI_READY_GEN_OSC);
       // rready_gen.set_high_time(len+1);
       mst.rd_driver.send_rready(rready_gen);
 	end
 	begin
       tr = mst.rd_driver.create_transaction("write_tran");
       mst.rd_driver.set_transaction_depth(max_outstanding_transactions);
       assert(tr.randomize());
    	   datasize = 0;
       tr.set_read_cmd(addr,burst_i,ID,len,size_i);
       tr.set_cache(cache);
       tr.set_lock(lock_i);
       tr.set_prot(prot);
       tr.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);	   
       mst.rd_driver.send(tr);
	   mst.rd_driver.wait_rsp(tr);
       // new_data = new[tr.get_len()+1];
       for( xil_axi_uint beat=0; beat<tr.get_len()+1; beat++) begin
         new_data = tr.get_data_beat(beat);
	      for(int k = 0; k < (2**siz); k = k+1) begin
            data[(datasize*8)+:8] = new_data[(k*8)+:8];
            datasize = datasize+1;
           end
		     response = response << 2;
             // fixing the CR-1030755 
			 response[1:0] = tr.get_rresp(beat);
             // response[1:0] = tr.rresp[i];
 	   end
 	   end

   join
 //==   mst.monitor.item_collected_port.get(tr_m);
 //==   datasize = 0;
 //==   for(i = 0; i < (len+1); i = i+1) begin
 //==     new_data = tr_m.get_data_beat(i);
 //==     for(int k = 0; k < (2**siz); k = k+1) begin
 //==	   data[(datasize*8)+:8] = new_data[(k*8)+:8];
 //==	   datasize = datasize+1;
 //==	 end
 //==	 response = response << 2;
 //==     response[1:0] = tr_m.rresp[i];
 //==   end
  end else begin
    $display("[%0d] : %0s : %0s : Port is disabled. 'read_burst' will not be executed...",$time, DISP_ERR, master_name);
    if(STOP_ON_ERROR) $stop;
  end
 endtask 
 
 task automatic write_burst(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(axi_burst_len*data_bus_width)-1:0] data,input integer datasize, output [axi_rsp_width-1:0] response);
 // task automatic write_burst(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(axi_mgp_data_width*axi_burst_len)-1:0] data,input integer datasize, output [axi_rsp_width-1:0] response);
  integer i,j;
  xil_axi_burst_t burst_i;
  xil_axi_size_t  size_i;
  xil_axi_lock_t  lock_i;
  xil_axi_data_beat new_data;
  xil_axi_strb_beat new_strb;
 
  case (burst)
    2'b00: burst_i = XIL_AXI_BURST_TYPE_FIXED;
    2'b01: burst_i = XIL_AXI_BURST_TYPE_INCR;
    2'b10: burst_i = XIL_AXI_BURST_TYPE_WRAP;
    2'b11: burst_i = XIL_AXI_BURST_TYPE_RSVD;
  endcase
  case (siz)
    3'b000: size_i = XIL_AXI_SIZE_1BYTE;
    3'b001: size_i = XIL_AXI_SIZE_2BYTE;
    3'b010: size_i = XIL_AXI_SIZE_4BYTE;
    3'b011: size_i = XIL_AXI_SIZE_8BYTE;
    3'b100: size_i = XIL_AXI_SIZE_16BYTE;
    3'b101: size_i = XIL_AXI_SIZE_32BYTE;
    3'b110: size_i = XIL_AXI_SIZE_64BYTE;
    3'b111: size_i = XIL_AXI_SIZE_128BYTE;
  endcase
  case (lck)
    2'b00: lock_i = XIL_AXI_ALOCK_NOLOCK;
    2'b01: lock_i = XIL_AXI_ALOCK_EXCL;
    2'b10: lock_i = XIL_AXI_ALOCK_LOCKED;
    2'b11: lock_i = XIL_AXI_ALOCK_RSVD;
  endcase
  if(enable_this_port)begin
    fork 
      begin
        bready_gen = mst.wr_driver.create_ready("bready");
        bready_gen.set_ready_policy(XIL_AXI_READY_GEN_OSC);
        // bready_gen.set_high_time(1);
        mst.wr_driver.send_bready(bready_gen);
      end
      begin
        tw = mst.wr_driver.create_transaction("write_tran");
        mst.wr_driver.set_transaction_depth(max_outstanding_transactions);
        assert(tw.randomize());
        tw.set_write_cmd(addr,burst_i,ID,len,size_i);
        tw.set_cache(cache);
        tw.set_lock(lock_i);
        tw.set_prot(prot);
        tw.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN); 
        for(i = 0; i < (len+1); i = i+1) begin
          for(j = 0; j < (2**siz); j = j+1) begin
            new_data[j*8+:8] = data[7:0];
 		    new_strb[j*1+:1] = 1'b1;
            data = data >> 8;
			// $display(" addr %0h i %0d J %0d data %0h new_strb %0d axi_mgp_data_width %0d",addr,i,j,data,new_strb[j*1+:1],axi_mgp_data_width);
 		 end
         tw.set_data_beat(i, new_data);
 		 tw.set_strb_beat(i, new_strb);
			// $display("  addr %0h i %0d J %0d new_data %0h new_strb %0d ",addr,i,j,new_data,new_strb);
        end
        mst.wr_driver.send(tw);
      end
    join
    // mst.monitor.item_collected_port.get(tw_m);
    mst.wr_driver.wait_rsp(tw);
    $display("  addr %0h i %0d J %0d new_data %0h new_strb %0d ",addr,i,j,new_data,new_strb);
    response = tw.bresp;
  end else begin
    // $display("[%0d] : %0s : %0s : Port is disabled. 'write_burst' will not be executed...",$time, DISP_ERR, master_name);
    if(STOP_ON_ERROR) $stop;
  end
 endtask 

  // task automatic write_burst_strb(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(axi_mgp_data_width*axi_burst_len)-1:0] data,input strb_en,input [(axi_mgp_data_width*axi_burst_len)/8-1:0] strb,input integer datasize, output [axi_rsp_width-1:0] response);
  task automatic write_burst_strb(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [((axi_burst_len*data_bus_width))-1:0] data,input strb_en,input [((axi_burst_len*data_bus_width)/8)-1:0] strb,input integer datasize, output [axi_rsp_width-1:0] response);
  integer i,j;
  xil_axi_burst_t burst_i;
  xil_axi_size_t  size_i;
  xil_axi_lock_t  lock_i;
  xil_axi_data_beat new_data;
  xil_axi_strb_beat new_strb;
 
  // $display(" write_burst_strb addr %0h trnsfr_lngth %0d siz %0d burst %0d wr_data %0h strb %0h",addr,len,siz,burst,data,strb);
  case (burst)
    2'b00: burst_i = XIL_AXI_BURST_TYPE_FIXED;
    2'b01: burst_i = XIL_AXI_BURST_TYPE_INCR;
    2'b10: burst_i = XIL_AXI_BURST_TYPE_WRAP;
    2'b11: burst_i = XIL_AXI_BURST_TYPE_RSVD;
  endcase
  case (siz)
    3'b000: size_i = XIL_AXI_SIZE_1BYTE;
    3'b001: size_i = XIL_AXI_SIZE_2BYTE;
    3'b010: size_i = XIL_AXI_SIZE_4BYTE;
    3'b011: size_i = XIL_AXI_SIZE_8BYTE;
    3'b100: size_i = XIL_AXI_SIZE_16BYTE;
    3'b101: size_i = XIL_AXI_SIZE_32BYTE;
    3'b110: size_i = XIL_AXI_SIZE_64BYTE;
    3'b111: size_i = XIL_AXI_SIZE_128BYTE;
  endcase
  case (lck)
    2'b00: lock_i = XIL_AXI_ALOCK_NOLOCK;
    2'b01: lock_i = XIL_AXI_ALOCK_EXCL;
    2'b10: lock_i = XIL_AXI_ALOCK_LOCKED;
    2'b11: lock_i = XIL_AXI_ALOCK_RSVD;
  endcase
  if(enable_this_port)begin
    fork 
      begin
        bready_gen = mst.wr_driver.create_ready("bready");
        bready_gen.set_ready_policy(XIL_AXI_READY_GEN_OSC);
        // bready_gen.set_high_time(1);
        mst.wr_driver.send_bready(bready_gen);
      end
      begin
        tw = mst.wr_driver.create_transaction("write_tran");
        mst.wr_driver.set_transaction_depth(max_outstanding_transactions);
        assert(tw.randomize());
        tw.set_write_cmd(addr,burst_i,ID,len,size_i);
        tw.set_cache(cache);
        tw.set_lock(lock_i);
        tw.set_prot(prot);
        tw.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN); 
		if(strb_en == 0) begin
        for(i = 0; i < (len+1); i = i+1) begin
          for(j = 0; j < (2**siz); j = j+1) begin
            new_data[j*8+:8] = data[7:0];
 		    new_strb[j*1+:1] = 1'b1;
            data = data >> 8;
 		 end
          tw.set_data_beat(i, new_data);
 		 tw.set_strb_beat(i, new_strb);
        end
        end
		else begin
		  for(i = 0; i < (len+1); i = i+1) begin
          for(j = 0; j < (2**siz); j = j+1) begin
            new_data[j*8+:8] = data[7:0];
 		    new_strb[j*1+:1] = strb[0];
            data = data >> 8;
            strb = strb >> 1;
 		  end
          tw.set_data_beat(i, new_data);
 		  tw.set_strb_beat(i, new_strb);
          // $display(" write_burst_strb new_data %0h new_strb %0h ",new_data,new_strb);
          end
		end
        mst.wr_driver.send(tw);
      end
    join
    // mst.monitor.item_collected_port.get(tw_m);
    mst.wr_driver.wait_rsp(tw);
    $display("  BURST addr %0h i %0d J %0d new_data %0h new_strb %0d ",addr,i,j,new_data,new_strb);
    response = tw.bresp;
  end else begin
    $display("[%0d] : %0s : %0s : Port is disabled. 'write_burst_strb' will not be executed...",$time, DISP_ERR, master_name);
    if(STOP_ON_ERROR) $stop;
  end
 endtask 
 

 task automatic write_burst_concurrent(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(axi_burst_len*data_bus_width)-1:0] data,input integer datasize, output [axi_rsp_width-1:0] response);
  integer i;
  if(enable_this_port)begin
    write_burst(addr,len,siz,burst,lck,cache,prot,data,datasize,response);
  end else begin
    $display("[%0d] : %0s : %0s : Port is disabled. 'write_burst_concurrent' will not be executed...",$time, DISP_ERR, master_name);
    if(STOP_ON_ERROR) $stop;
  end
 endtask 
 
 /* local */
 function automatic[id_bus_width-1:0] get_id;
 input dummy; 
 begin
  case(use_id_no)
   // l2m1 (CPU000)
   0 : get_id = 12'b11_000_000_00_00;   
   1 : get_id = 12'b11_010_000_00_00;    
   2 : get_id = 12'b11_011_000_00_00;  
   3 : get_id = 12'b11_100_000_00_00;  
   4 : get_id = 12'b11_101_000_00_00;  
   5 : get_id = 12'b11_110_000_00_00;    
   6 : get_id = 12'b11_111_000_00_00;    
   // l2m1 (CPU001)
   7 : get_id = 12'b11_000_001_00_00;   
   8 : get_id = 12'b11_010_001_00_00;    
   9 : get_id = 12'b11_011_001_00_00;   
  10 : get_id = 12'b11_100_001_00_00;   
  11 : get_id = 12'b11_101_001_00_00;   
  12 : get_id = 12'b11_110_001_00_00;    
  13 : get_id = 12'b11_111_001_00_00;   
  endcase
  if(use_id_no == 13)
   use_id_no = 0;
  else
   use_id_no = use_id_no+1;
 end
 endfunction
 
 /* Write data from file */
 task automatic write_from_file;
 input [(max_chars*8)-1:0] file_name;
 input [addr_width-1:0] start_addr;
 input [int_width-1:0] wr_size;
 output [axi_rsp_width-1:0] response;
 reg [axi_rsp_width-1:0] wresp,rwrsp;
 reg [addr_width-1:0] addr;
 reg [(axi_burst_len*data_bus_width)-1 : 0] wr_data;
 integer bytes;
 integer trnsfr_bytes;
 integer wr_fd;
 integer succ;
 integer trnsfr_lngth;
 reg concurrent; 
 integer i;
 int siz_in_bytes;
 
 reg [id_bus_width-1:0] wr_id;
 reg [axi_size_width-1:0] siz;
 reg [axi_brst_type_width-1:0] burst;
 reg [axi_lock_width-1:0] lck;
 reg [axi_cache_width-1:0] cache;
 reg [axi_prot_width-1:0] prot; 
 begin
 if(!enable_this_port) begin
  $display("[%0d] : %0s : %0s : Port is disabled. 'write_from_file' will not be executed...",$time, DISP_ERR, master_name);
  if(STOP_ON_ERROR) $stop;
 end else begin
  siz =  2; 
  burst = 1;
  lck = 0;
  cache = 0;
  prot = 0;
 
  addr = start_addr;
  bytes = wr_size;
  wresp = 0;
  concurrent = $random; 
  if(bytes > (axi_burst_len * data_bus_width/8)) begin
    trnsfr_bytes = (axi_burst_len * data_bus_width/8);
    trnsfr_lngth = axi_burst_len-1;
    siz_in_bytes =  (data_bus_width/8); 
  end else begin
    trnsfr_bytes = bytes;
  end 
  
  if(bytes > (axi_burst_len * data_bus_width/8)) begin
   trnsfr_lngth = axi_burst_len-1;
  end else if(bytes%(data_bus_width/8) == 0) begin
   trnsfr_lngth = bytes/(data_bus_width/8) - 1;
   siz_in_bytes =  (data_bus_width/8); 
  end else begin 
   trnsfr_lngth = bytes/(data_bus_width/8);
   siz_in_bytes =  (data_bus_width/8); 
  end

  wr_id = ID;
  wr_fd = $fopen(file_name,"r");
  
  while (bytes > 0) begin
    case(siz_in_bytes) 
	  1   : siz = 0; 
	  2   : siz = 1; 
	  4   : siz = 2; 
	  8   : siz = 3; 
	  16  : siz = 4; 
	  32  : siz = 5; 
	  64  : siz = 6; 
	  128 : siz = 7; 
	endcase
  
    repeat(axi_burst_len) begin /// get the data for 1 AXI burst transaction
     wr_data = wr_data >> data_bus_width;
     succ = $fscanf(wr_fd,"%h",wr_data[(axi_burst_len*data_bus_width)-1 :(axi_burst_len*data_bus_width)-data_bus_width ]); /// write as 4 bytes (data_bus_width) ..
    end
    write_burst(addr, trnsfr_lngth, siz, burst, lck, cache, prot, wr_data, trnsfr_bytes, rwrsp);
    bytes = bytes - trnsfr_bytes;
    addr = addr + trnsfr_bytes;
    if(bytes >= (axi_burst_len * data_bus_width/8) )
     trnsfr_bytes = (axi_burst_len * data_bus_width/8); //
    else
     trnsfr_bytes = bytes;
  
    if(bytes > (axi_burst_len * data_bus_width/8))
     trnsfr_lngth = axi_burst_len-1;
    else if(bytes%(data_bus_width/8) == 0)
     trnsfr_lngth = bytes/(data_bus_width/8) - 1;
    else 
     trnsfr_lngth = bytes/(data_bus_width/8);
  
    wresp = wresp | rwrsp;
  end /// while 
  response = wresp;
 end
 end
 endtask
 
 /* Read data to file */
 task automatic read_to_file;
 input [(max_chars*8)-1:0] file_name;
 input [addr_width-1:0] start_addr;
 input [int_width-1:0] rd_size;
 output [axi_rsp_width-1:0] response;
 reg [axi_rsp_width-1:0] rresp, rrrsp;
 reg [addr_width-1:0] addr;
 integer bytes;
 integer trnsfr_lngth;
 reg [(axi_burst_len*data_bus_width)-1 :0] rd_data;
 integer rd_fd;
 reg [id_bus_width-1:0] rd_id;
 
 reg [axi_size_width-1:0] siz;
 int siz_in_bytes;
 reg [axi_brst_type_width-1:0] burst;
 reg [axi_lock_width-1:0] lck;
 reg [axi_cache_width-1:0] cache;
 reg [axi_prot_width-1:0] prot; 
 begin
 if(!enable_this_port) begin
  $display("[%0d] : %0s : %0s : Port is disabled. 'read_to_file' will not be executed...",$time, DISP_ERR, master_name);
  if(STOP_ON_ERROR) $stop;
 end else begin
   siz =  2; 
   burst = 1;
   lck = 0;
   cache = 0;
   prot = 0;
 
   addr = start_addr;
   rresp = 0;
   bytes = rd_size;
   
   rd_id = ID;
   
   if(bytes > (axi_burst_len * data_bus_width/8)) begin
     trnsfr_lngth = axi_burst_len-1;
	 siz_in_bytes =  (data_bus_width/8); 
    end		
   else if(bytes%(data_bus_width/8) == 0) begin
    trnsfr_lngth = bytes/(data_bus_width/8) - 1;
	siz_in_bytes =  (data_bus_width/8); 
	end  
   else begin
    trnsfr_lngth = bytes/(data_bus_width/8);
    siz_in_bytes =  (data_bus_width/8); 
   end
  
   rd_fd = $fopen(file_name,"w");
   
   while (bytes > 0) begin
     case(siz_in_bytes) 
	   1   : siz = 0; 
	   2   : siz = 1; 
	   4   : siz = 2; 
	   8   : siz = 3; 
	   16  : siz = 4; 
	   32  : siz = 5; 
	   64  : siz = 6; 
	   128 : siz = 7; 
	 endcase
     read_burst(addr, trnsfr_lngth, siz, burst, lck, cache, prot, rd_data, rrrsp);
     repeat(trnsfr_lngth+1) begin
      $fdisplayh(rd_fd,rd_data[data_bus_width-1:0]);
      rd_data = rd_data >> data_bus_width;
     end
     
     addr = addr + (trnsfr_lngth+1)*4;
 
     if(bytes >= (axi_burst_len * data_bus_width/8) )
      bytes = bytes - (axi_burst_len * data_bus_width/8); //
     else
      bytes = 0;
  
     if(bytes > (axi_burst_len * data_bus_width/8))
      trnsfr_lngth = axi_burst_len-1;
     else if(bytes%(data_bus_width/8) == 0)
      trnsfr_lngth = bytes/(data_bus_width/8) - 1;
     else 
      trnsfr_lngth = bytes/(data_bus_width/8);
 
     rresp = rresp | rrrsp;
   end /// while 
   response = rresp;
 end
 end
 endtask
 
 /* Write data (used for transfer size <= 128 Bytes */
 task automatic write_data;
 input [addr_width-1:0] start_addr;
 input [max_transfer_bytes_width:0] wr_size;
 input [((axi_burst_len*data_bus_width))-1:0] w_data;
 output [axi_rsp_width-1:0] response;
 reg [axi_rsp_width-1:0] wresp,rwrsp;
 reg [addr_width-1:0] addr;
 reg [addr_width-1:0] mask_addr;
 reg [7:0] bytes,tmp_bytes;
 reg[127:0] strb;
 // reg [max_transfer_bytes_width*8:0] wr_strb;
 reg [((axi_burst_len*data_bus_width)/8):0] wr_strb;
 integer trnsfr_bytes,strb_cnt;
 reg [((axi_burst_len*data_bus_width))-1:0] wr_data;
 integer trnsfr_lngth;
 reg concurrent; 
 
 reg [id_bus_width-1:0] wr_id;
 reg [axi_size_width-1:0] siz;
 int siz_in_bytes,j;
 reg [axi_brst_type_width-1:0] burst;
 reg [axi_lock_width-1:0] lck;
 reg [axi_cache_width-1:0] cache;
 reg [axi_prot_width-1:0] prot; 
 
 integer pad_bytes;
 begin
 if(!enable_this_port) begin
  $display("[%0d] : %0s : %0s : Port is disabled. 'write_data' will not be executed...",$time, DISP_ERR, master_name);
  if(STOP_ON_ERROR) $stop;
 end else begin
  addr = start_addr;
  bytes = wr_size;
  wresp = 0;
  wr_data = w_data;
  concurrent = $random; 
  siz =  2; 
  burst = 1;
  lck = 0;
  cache = 0;
  prot = 0;
  wr_strb = 0;
  pad_bytes = start_addr[clogb2(data_bus_width/8)-1:0];
  wr_id = ID;
  // $display("write_data called with wr_size %0d ",wr_size);
  // $display("outside pad_bytes %0d ",pad_bytes);
  if(bytes+pad_bytes > (data_bus_width/8*axi_burst_len)) begin /// for unaligned address
    trnsfr_bytes = (data_bus_width*axi_burst_len)/8 - pad_bytes;//start_addr[1:0]; 
    trnsfr_lngth = axi_burst_len-1;
     siz_in_bytes =  (data_bus_width/8); 
	 // $display("0 pad_bytes %0d ",pad_bytes);
  end else begin 
    trnsfr_bytes = bytes;
    tmp_bytes   = bytes + pad_bytes;//start_addr[1:0];
    if(tmp_bytes%(data_bus_width/8) == 0) begin
      trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
      siz_in_bytes =  (data_bus_width/8); 
	 // $display("1 pad_bytes %0d ",pad_bytes);
    end else begin
      trnsfr_lngth = tmp_bytes/(data_bus_width/8);
      siz_in_bytes =  (data_bus_width/8); 
	 // $display("2 pad_bytes %0d ",pad_bytes);
	end
  end

	if(bytes > siz_in_bytes) begin
	 strb_cnt = ((bytes/siz_in_bytes)*siz_in_bytes) + (bytes%siz_in_bytes);
	 // $display("strb_cnt %0d (bytes/siz_in_bytes) %0d (bytes) %0d",strb_cnt,bytes/siz_in_bytes,bytes%siz_in_bytes);
	end begin
	  strb_cnt =  bytes ;
	  // $display("strb_cnt %0d max_transfer_bytes_width %0d",strb_cnt,max_transfer_bytes_width);
	end
 
  while (bytes > 0) begin
    case(siz_in_bytes) 
	  1   : siz = 0; 
	  2   : siz = 1; 
	  4   : siz = 2; 
	  8   : siz = 3; 
	  16  : siz = 4; 
	  32  : siz = 5; 
	  64  : siz = 6; 
	  128 : siz = 7; 
	endcase
    // $display("bytes %0d",bytes);
    // $display("addr %0h trnsfr_lngth %0d siz %0d burst %0d wr_data %0h trnsfr_bytes %0d siz_in_bytes %0d ",addr,trnsfr_lngth,siz,burst,wr_data,trnsfr_bytes,siz_in_bytes);
	mask_addr = addr[27:0] & (~(1 << siz));
	// $display("mask_addr %0h addr %0h (~(1 << siz)) %0h ((1 << siz)) %0h size %0d ",mask_addr,addr,(~(1 << siz)), ((1 << siz)),siz);
	if(pad_bytes != 0) begin 
	wr_data = (wr_data << (mask_addr[3:0]*8) );
	// $display(" pading bytes wr_data %0h ",wr_data);
	end else begin
	wr_data = wr_data;
	// $display(" non pading bytes wr_data %0h ",wr_data);
	end

      // $display("wr_data %0h",wr_data);
	for(j=0;j<strb_cnt;j=j+1) begin
	  wr_strb = {wr_strb, 1'b1};
      // $display("wr_strb %0h",wr_strb);
	end
	for(j=0;j<pad_bytes;j=j+1) begin
	  wr_strb = {wr_strb ,1'b0};
      // $display("new wr_strb %0h",wr_strb);
	end

    // write_burst(addr, trnsfr_lngth,  siz, burst, lck, cache, prot, wr_data[(axi_burst_len*data_bus_width)-1:0], trnsfr_bytes, rwrsp);
    write_burst_strb(addr, trnsfr_lngth,  siz, burst, lck, cache, prot, wr_data[((axi_burst_len*data_bus_width))-1:0], 1,wr_strb,trnsfr_bytes, rwrsp);
    wr_data = wr_data >> (trnsfr_bytes*8);
    // $display("wr_data %0h",wr_data);
    // $display("trnsfr_bytes %0d",trnsfr_bytes);
    bytes = bytes - trnsfr_bytes;
    addr = addr + trnsfr_bytes;
    // $display("addr %0d",addr);
    if(bytes  > (axi_burst_len * data_bus_width/8)) begin
     trnsfr_bytes = (axi_burst_len * data_bus_width/8) - pad_bytes;//start_addr[1:0]; 
     trnsfr_lngth = axi_burst_len-1;
	 pad_bytes = 0;
     // $display("trnsfr_lngth %0d pad_bytes %0d",trnsfr_lngth,pad_bytes);
    end else begin 
      trnsfr_bytes = bytes;
      // $display(" 1 trnsfr_bytes %0d",trnsfr_bytes);
      tmp_bytes = bytes + pad_bytes;//start_addr[1:0];
      if(tmp_bytes%(data_bus_width/8) == 0) begin
        trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
        // $display("2 trnsfr_lngth %0d",trnsfr_lngth);
      end else begin 
        trnsfr_lngth = tmp_bytes/(data_bus_width/8);
	    pad_bytes = 0;
        // $display("3 trnsfr_lngth %0d pad_bytes %0d",trnsfr_lngth,pad_bytes);
	  end	
    end
    wresp = wresp | rwrsp;
  end /// while 
  response = wresp;
 end
 end
 endtask
 
 /* Read data (used for transfer size <= 128 Bytes */
 task automatic read_data;
 input [addr_width-1:0] start_addr;
 input [max_transfer_bytes_width:0] rd_size;
 output [(axi_burst_len*data_bus_width)-1:0] r_data;
 output [axi_rsp_width-1:0] response;
 reg [axi_rsp_width-1:0] rresp,rdrsp;
 reg [addr_width-1:0] addr;
 reg [max_transfer_bytes_width:0] bytes,tmp_bytes;
 integer trnsfr_bytes;
 reg [(axi_burst_len*data_bus_width)-1:0] rd_data;
 reg [(axi_burst_len*data_bus_width)-1:0] rcv_rd_data;
 integer total_rcvd_bytes;
 integer trnsfr_lngth;
 integer i;
 reg [id_bus_width-1:0] rd_id;
 
 reg [axi_size_width-1:0] siz;
 int siz_in_bytes;
 reg [axi_brst_type_width-1:0] burst;
 reg [axi_lock_width-1:0] lck;
 reg [axi_cache_width-1:0] cache;
 reg [axi_prot_width-1:0] prot; 
 
 integer pad_bytes;
 
 begin
 if(!enable_this_port) begin
  $display("[%0d] : %0s : %0s : Port is disabled. 'read_data' will not be executed...",$time, DISP_ERR, master_name);
  if(STOP_ON_ERROR) $stop;
 end else begin
  addr = start_addr;
  bytes = rd_size;
  rresp = 0;
  total_rcvd_bytes = 0;
  rd_data = 0; 
  rd_id = ID;
 
  siz =  2; 
  burst = 1;
  lck = 0;
  cache = 0;
  prot = 0;
  pad_bytes = start_addr[clogb2(data_bus_width/8)-1:0];
 
  if(bytes+ pad_bytes > (axi_burst_len * data_bus_width/8)) begin /// for unaligned address
    trnsfr_bytes = (axi_burst_len * data_bus_width/8) - pad_bytes;//start_addr[1:0]; 
    trnsfr_lngth = axi_burst_len-1;
	siz_in_bytes =  (data_bus_width/8); 
	// $display("0 pad_bytes %0d ",pad_bytes);
  end else begin 
    trnsfr_bytes = bytes;
    tmp_bytes = bytes + pad_bytes;//start_addr[1:0];
    if(tmp_bytes%(data_bus_width/8) == 0) begin
      trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
      siz_in_bytes =  (data_bus_width/8); 
	 // $display("1 pad_bytes %0d ",pad_bytes);
	end  
    else begin 
      trnsfr_lngth = tmp_bytes/(data_bus_width/8);
      siz_in_bytes =  (data_bus_width/8); 
	 // $display("2 pad_bytes %0d ",pad_bytes);
	end
  end
  while (bytes > 0) begin
      case(siz_in_bytes) 
	  1   : siz = 0; 
	  2   : siz = 1; 
	  4   : siz = 2; 
	  8   : siz = 3; 
	  16  : siz = 4; 
	  32  : siz = 5; 
	  64  : siz = 6; 
	  128 : siz = 7; 
	endcase
    read_burst(addr, trnsfr_lngth, siz, burst, lck, cache, prot, rcv_rd_data, rdrsp);
    for(i = 0; i < trnsfr_bytes; i = i+1) begin
      rd_data = rd_data >> 8;
      rd_data[(max_transfer_bytes*8)-1 : (max_transfer_bytes*8)-8] = rcv_rd_data[7:0];
      rcv_rd_data =  rcv_rd_data >> 8;
      total_rcvd_bytes = total_rcvd_bytes+1;
    end
    bytes = bytes - trnsfr_bytes;
    addr = addr + trnsfr_bytes;
    if(bytes  > (axi_burst_len * data_bus_width/8)) begin
     trnsfr_bytes = (axi_burst_len * data_bus_width/8) - pad_bytes;//start_addr[1:0]; 
     trnsfr_lngth = 15;
    end else begin 
      trnsfr_bytes = bytes;
      tmp_bytes = bytes + pad_bytes;//start_addr[1:0];
      if(tmp_bytes%(data_bus_width/8) == 0)
        trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
      else 
        trnsfr_lngth = tmp_bytes/(data_bus_width/8);
    end
    rresp = rresp | rdrsp;
  end /// while 
  rd_data =  rd_data >> (max_transfer_bytes - total_rcvd_bytes)*8;
  r_data = rd_data;
  response = rresp;
 end
 end
 endtask
 
 
 /* Wait Register Update in PL */
 /* Issue a series of 1 burst length reads until the expected data pattern is received */
 
 task automatic wait_reg_update;
 input [addr_width-1:0] addri;
 input [data_width-1:0] datai;
 input [data_width-1:0] maski;
 input [int_width-1:0] time_interval;
 input [int_width-1:0] time_out;
 output [data_width-1:0] data_o;
 output upd_done;
 
 reg [addr_width-1:0] addr;
 reg [data_width-1:0] data_i;
 reg [data_width-1:0] mask_i;
 integer time_int;
 integer timeout;
 
 reg [axi_rsp_width-1:0] rdrsp;
 reg [id_bus_width-1:0] rd_id;
 reg [axi_size_width-1:0] siz;
 reg [axi_brst_type_width-1:0] burst;
 reg [axi_lock_width-1:0] lck;
 reg [axi_cache_width-1:0] cache;
 reg [axi_prot_width-1:0] prot; 
 reg [data_width-1:0] rcv_data;
 integer trnsfr_lngth; 
 reg rd_loop;
 reg timed_out; 
 integer i;
 integer cycle_cnt;
 
 begin
 addr = addri;
 data_i = datai;
 mask_i = maski;
 time_int = time_interval;
 timeout = time_out;
 timed_out = 0;
 cycle_cnt = 0;
 
 if(!enable_this_port) begin
  $display("[%0d] : %0s : %0s : Port is disabled. 'wait_reg_update' will not be executed...",$time, DISP_ERR, master_name);
  upd_done = 0;
  if(STOP_ON_ERROR) $stop;
 end else begin
  rd_id = ID;
  siz =  2; 
  burst = 1;
  lck = 0;
  cache = 0;
  prot = 0;
  trnsfr_lngth = 0;
  rd_loop = 1;
  fork 
   begin
     while(!timed_out & rd_loop) begin
       cycle_cnt = cycle_cnt + 1;
       if(cycle_cnt >= timeout) timed_out = 1;
       @(posedge M_ACLK);
     end
   end
   begin
     while (rd_loop) begin 
      if(DEBUG_INFO)
        $display("[%0d] : %0s : %0s : Reading Register mapped at Address(0x%0h) ",$time, master_name, DISP_INFO, addr); 
      read_burst(addr, trnsfr_lngth, siz, burst, lck, cache, prot, rcv_data, rdrsp);
      if(DEBUG_INFO)
        $display("[%0d] : %0s : %0s : Reading Register returned (0x%0h) ",$time, master_name, DISP_INFO, rcv_data); 
      if(((rcv_data & ~mask_i) === (data_i & ~mask_i)) | timed_out)
        rd_loop = 0;
      else
        repeat(time_int) @(posedge M_ACLK);
     end /// while 
   end 
  join
  data_o = rcv_data & ~mask_i; 
  if(timed_out) begin
    $display("[%0d] : %0s : %0s : 'wait_reg_update' timed out ... Register is not updated ",$time, DISP_ERR, master_name);
    if(STOP_ON_ERROR) $stop;
  end else
    upd_done = 1;
 end
 end
 endtask
 

  /* Set verbosity to be used */
  task automatic set_verbosity;
    input[31:0] verb;
  begin
   if(enable_this_port) begin 
    mst.set_verbosity(verb);
   end  else begin
    if(DEBUG_INFO)
     $display("[%0d] : %0s : %0s : Port is disabled. 'ARQOS' will not be set...",$time, DISP_WARN, master_name);
   end

  end
  endtask



 /* Call to BFM APIs */
 // task automatic read_burst(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,output [(max_data_width*axi_burst_len)-1:0] data, output [(axi_rsp_width*axi_burst_len)-1:0] response);
 //  reg [(axi_burst_len*1)-1:0] ruser;
 //  if(enable_this_port)begin
 //   if(lck !== AXI_NRML)
 //    master.READ_BURST(RD_ID,addr,len,siz,burst,lck,cache,prot,0,0,0,data,response,ruser);
 //   else
 //    master.READ_BURST(RD_ID,addr,len,siz,burst,lck,cache,prot,0,0,0,data,response,ruser);
 //  end else begin
 //    $display("[%0d] : %0s : %0s : Port is disabled. 'read_burst' will not be executed...",$time, DISP_ERR, master_name);
 //    if(STOP_ON_ERROR) $stop;
 //  end
 // endtask 
 // 
 // task automatic write_burst(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(max_data_width*axi_burst_len)-1:0] data,input integer datasize, output [axi_rsp_width-1:0] response);
 //  reg [(axi_burst_len*1)-1:0] buser;
 //  if(enable_this_port)begin
 //   if(lck !== AXI_NRML)
 //    master.WRITE_BURST(WR_ID,addr,len,siz,burst,lck,cache,prot,data,datasize,0,0,0,0,response,buser);
 //   else
 //    master.WRITE_BURST(WR_ID,addr,len,siz,burst,lck,cache,prot,data,datasize,0,0,0,0,response,buser);
 //  end else begin
 //    $display("[%0d] : %0s : %0s : Port is disabled. 'write_burst' will not be executed...",$time, DISP_ERR, master_name);
 //    if(STOP_ON_ERROR) $stop;
 //  end
 // endtask 
 // 
 // task automatic write_burst_concurrent(input [address_bus_width-1:0] addr,input [axi_len_width-1:0] len,input [axi_size_width-1:0] siz,input [axi_brst_type_width-1:0] burst,input [axi_lock_width-1:0] lck,input [axi_cache_width-1:0] cache,input [axi_prot_width-1:0] prot,input [(max_data_width*axi_burst_len)-1:0] data,input integer datasize, output [axi_rsp_width-1:0] response);
 //  reg [(axi_burst_len*1)-1:0] buser;
 //  if(enable_this_port)begin
 //   if(lck !== AXI_NRML)
 //    master.WRITE_BURST_CONCURRENT(WR_ID,addr,len,siz,burst,lck,cache,prot,data,datasize,0,0,0,0,response,buser);
 //   else
 //    master.WRITE_BURST_CONCURRENT(WR_ID,addr,len,siz,burst,lck,cache,prot,data,datasize,0,0,0,0,response,buser);
 //  end else begin
 //    $display("[%0d] : %0s : %0s : Port is disabled. 'write_burst_concurrent' will not be executed...",$time, DISP_ERR, master_name);
 //    if(STOP_ON_ERROR) $stop;
 //  end
 // endtask 
 // 
 // /* local */
 // function automatic[id_bus_width-1:0] get_id;
 // input dummy; 
 // begin
 //  case(use_id_no)
 //   0 : get_id = 16'h0C00;   
 //   1 : get_id = 16'h0D00;    
 //   2 : get_id = 16'h0D80;  
 //   3 : get_id = 16'h0E00;  
 //   4 : get_id = 16'h0E80;  
 //   5 : get_id = 16'h0F00;    
 //   6 : get_id = 16'h0F80;    
 //   7 : get_id = 16'h0C10;   
 //   8 : get_id = 16'h0D10;    
 //   9 : get_id = 16'h0D90;   
 //  10 : get_id = 16'h0E10;   
 //  11 : get_id = 16'h0E90;   
 //  12 : get_id = 16'h0F10;    
 //  13 : get_id = 16'h0F90;   
 //  endcase
 //  if(use_id_no == 13)
 //   use_id_no = 0;
 //  else
 //   use_id_no = use_id_no+1;
 // end
 // endfunction
 // 
 // /* Write data from file */
 // task automatic write_from_file;
 // input [(max_chars*8)-1:0] file_name;
 // input [addr_width-1:0] start_addr;
 // input [int_width-1:0] wr_size;
 // output [axi_rsp_width-1:0] response;
 // reg [axi_rsp_width-1:0] wresp,rwrsp;
 // reg [addr_width-1:0] addr;
 // reg [(axi_burst_len*data_bus_width)-1 : 0] wr_data;
 // integer bytes;
 // integer trnsfr_bytes;
 // integer wr_fd;
 // integer succ;
 // integer trnsfr_lngth;
 // reg concurrent; 
 // 
 // reg [id_bus_width-1:0] wr_id;
 // reg [axi_size_width-1:0] siz;
 // reg [axi_brst_type_width-1:0] burst;
 // reg [axi_lock_width-1:0] lck;
 // reg [axi_cache_width-1:0] cache;
 // reg [axi_prot_width-1:0] prot; 
 //  reg [(axi_burst_len*1)-1:0] buser;
 // begin
 // if(!enable_this_port) begin
 //  $display("[%0d] : %0s : %0s : Port is disabled. 'write_from_file' will not be executed...",$time, DISP_ERR, master_name);
 //  if(STOP_ON_ERROR) $stop;
 // end else begin
 //  if (data_bus_width == 128) 
 //    siz =  4;
 //  else if (data_bus_width == 64)
 //    siz =  3;
 //  else if (data_bus_width == 32)
 //    siz =  2;
 //  burst = 1;
 //  lck = 0;
 //  cache = 0;
 //  prot = 0;
 // 
 //  addr = start_addr;
 //  bytes = wr_size;
 //  wresp = 0;
 //  concurrent = $random; 
 //  if(bytes > (axi_burst_len * data_bus_width/8))
 //   trnsfr_bytes = (axi_burst_len * data_bus_width/8);
 //  else
 //   trnsfr_bytes = bytes;
 //  
 //  if(bytes > (axi_burst_len * data_bus_width/8))
 //   trnsfr_lngth = axi_burst_len-1;
 //  else if(bytes%(data_bus_width/8) == 0)
 //   trnsfr_lngth = bytes/(data_bus_width/8) - 1;
 //  else 
 //   trnsfr_lngth = bytes/(data_bus_width/8);
 //  
 //  wr_id = WR_ID;
 //  wr_fd = $fopen(file_name,"r");
 //  
 //  while (bytes > 0) begin
 //    repeat(axi_burst_len*(data_bus_width/32)) begin /// get the data for 1 AXI burst transaction
 //     wr_data = wr_data >> 32;
 //     succ = $fscanf(wr_fd,"%h",wr_data[(axi_burst_len*data_bus_width)-1 :(axi_burst_len*data_bus_width)-32 ]); /// write as 4 bytes (data_bus_width) ..
 //    end
 //    if(concurrent)
 //     master.WRITE_BURST_CONCURRENT(wr_id, addr, trnsfr_lngth, siz, burst, lck, cache, prot, wr_data, trnsfr_bytes, 0,0,0,0,rwrsp,buser);
 //    else
 //     master.WRITE_BURST(wr_id, addr, trnsfr_lngth, siz, burst, lck, cache, prot, wr_data, trnsfr_bytes, 0,0,0,0,rwrsp,buser);
 //    bytes = bytes - trnsfr_bytes;
 //    addr = addr + trnsfr_bytes;
 //    if(bytes >= (axi_burst_len * data_bus_width/8) )
 //     trnsfr_bytes = (axi_burst_len * data_bus_width/8); //
 //    else
 //     trnsfr_bytes = bytes;
 //  
 //    if(bytes > (axi_burst_len * data_bus_width/8))
 //     trnsfr_lngth = axi_burst_len-1;
 //    else if(bytes%(data_bus_width/8) == 0)
 //     trnsfr_lngth = bytes/(data_bus_width/8) - 1;
 //    else 
 //     trnsfr_lngth = bytes/(data_bus_width/8);
 //  
 //    wresp = wresp | rwrsp;
 //  end /// while 
 //  response = wresp;
 // end
 // end
 // endtask
 // 
 // /* Read data to file */
 // task automatic read_to_file;
 // input [(max_chars*8)-1:0] file_name;
 // input [addr_width-1:0] start_addr;
 // input [int_width-1:0] rd_size;
 // output [axi_rsp_width-1:0] response;
 // reg [axi_rsp_width-1:0] rresp, rrrsp;
 // reg [addr_width-1:0] addr;
 // integer bytes;
 // integer trnsfr_lngth;
 // reg [(axi_burst_len*data_bus_width)-1 :0] rd_data;
 // integer rd_fd;
 // reg [id_bus_width-1:0] rd_id;
 // 
 // reg [axi_size_width-1:0] siz;
 // reg [axi_brst_type_width-1:0] burst;
 // reg [axi_lock_width-1:0] lck;
 // reg [axi_cache_width-1:0] cache;
 // reg [axi_prot_width-1:0] prot; 
 // reg [(axi_burst_len*1)-1:0] ruser;
 // begin
 // if(!enable_this_port) begin
 //  $display("[%0d] : %0s : %0s : Port is disabled. 'read_to_file' will not be executed...",$time, DISP_ERR, master_name);
 //  if(STOP_ON_ERROR) $stop;
 // end else begin
 //  if (data_bus_width == 128) 
 //    siz =  4;
 //  else if (data_bus_width == 64)
 //    siz =  3;
 //  else if (data_bus_width == 32)
 //    siz =  2;
 //   burst = 1;
 //   lck = 0;
 //   cache = 0;
 //   prot = 0;
 // 
 //   addr = start_addr;
 //   rresp = 0;
 //   bytes = rd_size;
 //   
 //   rd_id = RD_ID;
 //   
 //   if(bytes > (axi_burst_len * data_bus_width/8))
 //    trnsfr_lngth = axi_burst_len-1;
 //   else if(bytes%(data_bus_width/8) == 0)
 //    trnsfr_lngth = bytes/(data_bus_width/8) - 1;
 //   else 
 //    trnsfr_lngth = bytes/(data_bus_width/8);
 //  
 //   rd_fd = $fopen(file_name,"w");
 //   
 //   while (bytes > 0) begin
 //     master.READ_BURST(rd_id, addr, trnsfr_lngth, siz, burst, lck, cache, prot, 0,0,0,rd_data, rrrsp,ruser);
 //     repeat((trnsfr_lngth+1)*(data_bus_width/32)) begin
 //      $fdisplayh(rd_fd,rd_data[31:0]);
 //      rd_data = rd_data >> 32;
 //     end
 //     
 //     addr = addr + (trnsfr_lngth+1)*4;
 // 
 //     if(bytes >= (axi_burst_len * data_bus_width/8) )
 //      bytes = bytes - (axi_burst_len * data_bus_width/8); //
 //     else
 //      bytes = 0;
 //  
 //     if(bytes > (axi_burst_len * data_bus_width/8))
 //      trnsfr_lngth = axi_burst_len-1;
 //     else if(bytes%(data_bus_width/8) == 0)
 //      trnsfr_lngth = bytes/(data_bus_width/8) - 1;
 //     else 
 //      trnsfr_lngth = bytes/(data_bus_width/8);
 // 
 //     rresp = rresp | rrrsp;
 //   end /// while 
 //   response = rresp;
 // end
 // end
 // endtask
 // 
 // /* Write data (used for transfer size <= 128 Bytes */
 // task automatic write_data;
 // input [addr_width-1:0] start_addr;
 // input [max_transfer_bytes_width:0] wr_size;
 // input [(max_transfer_bytes*8)-1:0] w_data;
 // output [axi_rsp_width-1:0] response;
 // reg [axi_rsp_width-1:0] wresp,rwrsp;
 // reg [addr_width-1:0] addr;
 // reg [7:0] bytes,tmp_bytes;
 // integer trnsfr_bytes;
 // reg [(max_transfer_bytes*8)-1:0] wr_data;
 // integer trnsfr_lngth;
 // reg concurrent; 
 // 
 // reg [id_bus_width-1:0] wr_id;
 // reg [axi_size_width-1:0] siz;
 // reg [axi_brst_type_width-1:0] burst;
 // reg [axi_lock_width-1:0] lck;
 // reg [axi_cache_width-1:0] cache;
 // reg [axi_prot_width-1:0] prot; 
 //  reg [(axi_burst_len*1)-1:0] buser;
 // 
 // integer pad_bytes;
 // begin
 // if(!enable_this_port) begin
 //  $display("[%0d] : %0s : %0s : Port is disabled. 'write_data' will not be executed...",$time, DISP_ERR, master_name);
 //  if(STOP_ON_ERROR) $stop;
 // end else begin
 //  addr = start_addr;
 //  bytes = wr_size;
 //  wresp = 0;
 //  wr_data = w_data;
 //  concurrent = $random; 
 //  if (data_bus_width == 128)
 //    siz =  4;
 //  else if (data_bus_width == 64)
 //    siz =  3;
 //  else if (data_bus_width == 32)
 //    siz =  2;
 //  burst = 1;
 //  lck = 0;
 //  cache = 0;
 //  prot = 0;
 //  pad_bytes = start_addr[clogb2(data_bus_width/8)-1:0];
 //  wr_id = WR_ID;
 //  if(bytes+pad_bytes > (data_bus_width/8*axi_burst_len)) begin /// for unaligned address
 //    trnsfr_bytes = (data_bus_width*axi_burst_len)/8 - pad_bytes;//start_addr[1:0]; 
 //    trnsfr_lngth = axi_burst_len-1;
 //  end else begin 
 //    trnsfr_bytes = bytes;
 //    tmp_bytes   = bytes + pad_bytes;//start_addr[1:0];
 //    if(tmp_bytes%(data_bus_width/8) == 0)
 //      trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
 //    else 
 //      trnsfr_lngth = tmp_bytes/(data_bus_width/8);
 //  end
 // 
 //  while (bytes > 0) begin
 //    if(concurrent)
 //     master.WRITE_BURST_CONCURRENT(wr_id, addr, trnsfr_lngth,  siz, burst, lck, cache, prot, wr_data[(axi_burst_len*data_bus_width)-1:0], trnsfr_bytes, 0,0,0,0,rwrsp,buser);
 //    else
 //     master.WRITE_BURST(wr_id, addr, trnsfr_lngth,  siz, burst, lck, cache, prot, wr_data[(axi_burst_len*data_bus_width)-1:0], trnsfr_bytes, 0,0,0,0,rwrsp,buser);
 //    wr_data = wr_data >> (trnsfr_bytes*8);
 //    bytes = bytes - trnsfr_bytes;
 //    addr = addr + trnsfr_bytes;
 //    if(bytes  > (axi_burst_len * data_bus_width/8)) begin
 //     trnsfr_bytes = (axi_burst_len * data_bus_width/8) - pad_bytes;//start_addr[1:0]; 
 //     trnsfr_lngth = axi_burst_len-1;
 //    end else begin 
 //      trnsfr_bytes = bytes;
 //      tmp_bytes = bytes + pad_bytes;//start_addr[1:0];
 //      if(tmp_bytes%(data_bus_width/8) == 0)
 //        trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
 //      else 
 //        trnsfr_lngth = tmp_bytes/(data_bus_width/8);
 //    end
 //    wresp = wresp | rwrsp;
 //  end /// while 
 //  response = wresp;
 // end
 // end
 // endtask
 // 
 // /* Read data (used for transfer size <= 128 Bytes */
 // task automatic read_data;
 // input [addr_width-1:0] start_addr;
 // input [max_transfer_bytes_width:0] rd_size;
 // output [(max_transfer_bytes*8)-1:0] r_data;
 // output [axi_rsp_width-1:0] response;
 // reg [axi_rsp_width-1:0] rresp,rdrsp;
 // reg [addr_width-1:0] addr;
 // reg [max_transfer_bytes_width:0] bytes,tmp_bytes;
 // integer trnsfr_bytes;
 // reg [(max_transfer_bytes*8)-1 : 0] rd_data;
 // reg [(axi_burst_len*data_bus_width)-1:0] rcv_rd_data;
 // integer total_rcvd_bytes;
 // integer trnsfr_lngth;
 // integer i;
 // reg [id_bus_width-1:0] rd_id;
 // 
 // reg [axi_size_width-1:0] siz;
 // reg [axi_brst_type_width-1:0] burst;
 // reg [axi_lock_width-1:0] lck;
 // reg [axi_cache_width-1:0] cache;
 // reg [axi_prot_width-1:0] prot; 
 // reg [(axi_burst_len*1)-1:0] ruser;
 // 
 // integer pad_bytes;
 // 
 // begin
 // if(!enable_this_port) begin
 //  $display("[%0d] : %0s : %0s : Port is disabled. 'read_data' will not be executed...",$time, DISP_ERR, master_name);
 //  if(STOP_ON_ERROR) $stop;
 // end else begin
 //  addr = start_addr;
 //  bytes = rd_size;
 //  rresp = 0;
 //  total_rcvd_bytes = 0;
 //  rd_data = 0; 
 //  rd_id = RD_ID;
 // 
 //  if (data_bus_width == 128) 
 //    siz =  4;
 //  else if (data_bus_width == 64)
 //    siz =  3;
 //  else if (data_bus_width == 32)
 //    siz =  2;
 //  burst = 1;
 //  lck = 0;
 //  cache = 0;
 //  prot = 0;
 //  pad_bytes = start_addr[clogb2(data_bus_width/8)-1:0];
 // 
 //  if(bytes+ pad_bytes > (axi_burst_len * data_bus_width/8)) begin /// for unaligned address
 //    trnsfr_bytes = (axi_burst_len * data_bus_width/8) - pad_bytes;//start_addr[1:0]; 
 //    trnsfr_lngth = axi_burst_len-1;
 //  end else begin 
 //    trnsfr_bytes = bytes;
 //    tmp_bytes = bytes + pad_bytes;//start_addr[1:0];
 //    if(tmp_bytes%(data_bus_width/8) == 0)
 //      trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
 //    else 
 //      trnsfr_lngth = tmp_bytes/(data_bus_width/8);
 //  end
 //  while (bytes > 0) begin
 //    master.READ_BURST(rd_id,addr, trnsfr_lngth, siz, burst, lck, cache, prot, 0,0,0, rcv_rd_data, rdrsp,ruser);
 //    for(i = 0; i < trnsfr_bytes; i = i+1) begin
 //      rd_data = rd_data >> 8;
 //      rd_data[(max_transfer_bytes*8)-1 : (max_transfer_bytes*8)-8] = rcv_rd_data[7:0];
 //      rcv_rd_data =  rcv_rd_data >> 8;
 //      total_rcvd_bytes = total_rcvd_bytes+1;
 //    end
 //    bytes = bytes - trnsfr_bytes;
 //    addr = addr + trnsfr_bytes;
 //    if(bytes  > (axi_burst_len * data_bus_width/8)) begin
 //     trnsfr_bytes = (axi_burst_len * data_bus_width/8) - pad_bytes;//start_addr[1:0]; 
 //     trnsfr_lngth = 15;
 //    end else begin 
 //      trnsfr_bytes = bytes;
 //      tmp_bytes = bytes + pad_bytes;//start_addr[1:0];
 //      if(tmp_bytes%(data_bus_width/8) == 0)
 //        trnsfr_lngth = tmp_bytes/(data_bus_width/8) - 1;
 //      else 
 //        trnsfr_lngth = tmp_bytes/(data_bus_width/8);
 //    end
 //    rresp = rresp | rdrsp;
 //  end /// while 
 //  rd_data =  rd_data >> (max_transfer_bytes - total_rcvd_bytes)*8;
 //  r_data = rd_data;
 //  response = rresp;
 // end
 // end
 // endtask
 // 
 // 
 // /* Wait Register Update in PL */
 // /* Issue a series of 1 burst length reads until the expected data pattern is received */
 // 
 // task automatic wait_reg_update;
 // input [addr_width-1:0] addri;
 // input [data_width-1:0] datai;
 // input [data_width-1:0] maski;
 // input [int_width-1:0] time_interval;
 // input [int_width-1:0] time_out;
 // output [data_width-1:0] data_o;
 // output upd_done;
 // 
 // reg [addr_width-1:0] addr;
 // reg [data_width-1:0] data_i;
 // reg [data_width-1:0] mask_i;
 // integer time_int;
 // integer timeout;
 // 
 // reg [axi_rsp_width-1:0] rdrsp;
 // reg [id_bus_width-1:0] rd_id;
 // reg [axi_size_width-1:0] siz;
 // reg [axi_brst_type_width-1:0] burst;
 // reg [axi_lock_width-1:0] lck;
 // reg [axi_cache_width-1:0] cache;
 // reg [axi_prot_width-1:0] prot; 
 // reg [data_width-1:0] rcv_data;
 // integer trnsfr_lngth; 
 // reg rd_loop;
 // reg timed_out; 
 // integer i;
 // integer cycle_cnt;
 // reg [(axi_burst_len*1)-1:0] ruser;
 // 
 // begin
 // addr = addri;
 // data_i = datai;
 // mask_i = maski;
 // time_int = time_interval;
 // timeout = time_out;
 // timed_out = 0;
 // cycle_cnt = 0;
 // 
 // if(!enable_this_port) begin
 //  $display("[%0d] : %0s : %0s : Port is disabled. 'wait_reg_update' will not be executed...",$time, DISP_ERR, master_name);
 //  upd_done = 0;
 //  if(STOP_ON_ERROR) $stop;
 // end else begin
 //  rd_id = RD_ID;
 //  siz =  2; 
 //  burst = 1;
 //  lck = 0;
 //  cache = 0;
 //  prot = 0;
 //  trnsfr_lngth = 0;
 //  rd_loop = 1;
 //  fork 
 //   begin
 //     while(!timed_out & rd_loop) begin
 //       cycle_cnt = cycle_cnt + 1;
 //       if(cycle_cnt >= timeout) timed_out = 1;
 //       @(posedge M_ACLK);
 //     end
 //   end
 //   begin
 //     while (rd_loop) begin 
 //      if(DEBUG_INFO)
 //        $display("[%0d] : %0s : %0s : Reading Register mapped at Address(0x%0h) ",$time, master_name, DISP_INFO, addr); 
 //      master.READ_BURST(rd_id,addr, trnsfr_lngth, siz, burst, lck, cache, prot, 0,0,0, rcv_data, rdrsp,ruser);
 //      if(DEBUG_INFO)
 //        $display("[%0d] : %0s : %0s : Reading Register returned (0x%0h) ",$time, master_name, DISP_INFO, rcv_data); 
 //      if(((rcv_data & ~mask_i) === (data_i & ~mask_i)) | timed_out)
 //        rd_loop = 0;
 //      else
 //        repeat(time_int) @(posedge M_ACLK);
 //     end /// while 
 //   end 
 //  join
 //  data_o = rcv_data & ~mask_i; 
 //  if(timed_out) begin
 //    $display("[%0d] : %0s : %0s : 'wait_reg_update' timed out ... Register is not updated ",$time, DISP_ERR, master_name);
 //    if(STOP_ON_ERROR) $stop;
 //  end else
 //    upd_done = 1;
 // end
 // end
 // endtask

endmodule


/******************************************************************************
 * File : zynq_ultra_ps_e_vip_v1_0_6_vip.sv
 *
 * Date : 2015-16
 *
 * Description : zynq_ultra_ps_e_vip Top (Zynq MPSoC BFM top)
 *
 *****************************************************************************/
 `timescale 1ns/1ps

module zynq_ultra_ps_e_vip_v1_0_6
  (
  PSS_ALTO_CORE_PAD_CLK,
  PSS_ALTO_CORE_PAD_DONEB,
  PSS_ALTO_CORE_PAD_DRAMACTN,
  PSS_ALTO_CORE_PAD_DRAMALERTN,
  PSS_ALTO_CORE_PAD_DRAMPARITY,
  PSS_ALTO_CORE_PAD_DRAMRAMRSTN,
  PSS_ALTO_CORE_PAD_ERROROUT,
  PSS_ALTO_CORE_PAD_ERRORSTATUS,
  PSS_ALTO_CORE_PAD_INITB,
  PSS_ALTO_CORE_PAD_JTAGTCK,
  PSS_ALTO_CORE_PAD_JTAGTDI,
  PSS_ALTO_CORE_PAD_JTAGTDO,
  PSS_ALTO_CORE_PAD_JTAGTMS,
  PSS_ALTO_CORE_PAD_PORB,
  PSS_ALTO_CORE_PAD_PROGB,
  PSS_ALTO_CORE_PAD_RCALIBINOUT,
  PSS_ALTO_CORE_PAD_SRSTB,
  PSS_ALTO_CORE_PAD_ZQ,
  PSS_ALTO_CORE_PAD_DRAMA,
  PSS_ALTO_CORE_PAD_DRAMBA,
  PSS_ALTO_CORE_PAD_DRAMBG,
  PSS_ALTO_CORE_PAD_DRAMCK,
  PSS_ALTO_CORE_PAD_DRAMCKE,
  PSS_ALTO_CORE_PAD_DRAMCKN,
  PSS_ALTO_CORE_PAD_DRAMCSN,
  PSS_ALTO_CORE_PAD_DRAMODT,
  PSS_ALTO_CORE_PAD_BOOTMODE,
  PSS_ALTO_CORE_PAD_DRAMDQ,
  PSS_ALTO_CORE_PAD_MIO,
  PSS_ALTO_CORE_PAD_DRAMDM,
  PSS_ALTO_CORE_PAD_DRAMDQS,
  PSS_ALTO_CORE_PAD_DRAMDQSN,
  AIBPMUAFIFMFPDACK,
  AIBPMUAFIFMLPDACK,
  DDRCEXTREFRESHRANK0REQ,
  DDRCEXTREFRESHRANK1REQ,
  DDRCREFRESHPLCLK,
  DPAUXDATAIN,
  DPEXTERNALCUSTOMEVENT1,
  DPEXTERNALCUSTOMEVENT2,
  DPEXTERNALVSYNCEVENT,
  DPHOTPLUGDETECT,
  DPLIVEVIDEOINDE,
  DPLIVEVIDEOINHSYNC,
  DPLIVEVIDEOINVSYNC,
  DPMAXISMIXEDAUDIOTREADY,
  DPSAXISAUDIOCLK,
  DPSAXISAUDIOTID,
  DPSAXISAUDIOTVALID,
  DPVIDEOINCLK,
  EMIOCAN0PHYRX,
  EMIOCAN1PHYRX,
  EMIOENET0DMATXSTATUSTOG,
  EMIOENET0EXTINTIN,
  EMIOENET0GMIICOL,
  EMIOENET0GMIICRS,
  EMIOENET0GMIIRXCLK,
  EMIOENET0GMIIRXDV,
  EMIOENET0GMIIRXER,
  EMIOENET0GMIITXCLK,
  EMIOENET0MDIOI,
  EMIOENET0RXWOVERFLOW,
  EMIOENET0TXRCONTROL,
  EMIOENET0TXRDATARDY,
  EMIOENET0TXREOP,
  EMIOENET0TXRERR,
  EMIOENET0TXRFLUSHED,
  EMIOENET0TXRSOP,
  EMIOENET0TXRUNDERFLOW,
  EMIOENET0TXRVALID,
  EMIOENET1DMATXSTATUSTOG,
  EMIOENET1EXTINTIN,
  EMIOENET1GMIICOL,
  EMIOENET1GMIICRS,
  EMIOENET1GMIIRXCLK,
  EMIOENET1GMIIRXDV,
  EMIOENET1GMIIRXER,
  EMIOENET1GMIITXCLK,
  EMIOENET1MDIOI,
  EMIOENET1RXWOVERFLOW,
  EMIOENET1TXRCONTROL,
  EMIOENET1TXRDATARDY,
  EMIOENET1TXREOP,
  EMIOENET1TXRERR,
  EMIOENET1TXRFLUSHED,
  EMIOENET1TXRSOP,
  EMIOENET1TXRUNDERFLOW,
  EMIOENET1TXRVALID,
  EMIOENET2DMATXSTATUSTOG,
  EMIOENET2EXTINTIN,
  EMIOENET2GMIICOL,
  EMIOENET2GMIICRS,
  EMIOENET2GMIIRXCLK,
  EMIOENET2GMIIRXDV,
  EMIOENET2GMIIRXER,
  EMIOENET2GMIITXCLK,
  EMIOENET2MDIOI,
  EMIOENET2RXWOVERFLOW,
  EMIOENET2TXRCONTROL,
  EMIOENET2TXRDATARDY,
  EMIOENET2TXREOP,
  EMIOENET2TXRERR,
  EMIOENET2TXRFLUSHED,
  EMIOENET2TXRSOP,
  EMIOENET2TXRUNDERFLOW,
  EMIOENET2TXRVALID,
  EMIOENET3DMATXSTATUSTOG,
  EMIOENET3EXTINTIN,
  EMIOENET3GMIICOL,
  EMIOENET3GMIICRS,
  EMIOENET3GMIIRXCLK,
  EMIOENET3GMIIRXDV,
  EMIOENET3GMIIRXER,
  EMIOENET3GMIITXCLK,
  EMIOENET3MDIOI,
  EMIOENET3RXWOVERFLOW,
  EMIOENET3TXRCONTROL,
  EMIOENET3TXRDATARDY,
  EMIOENET3TXREOP,
  EMIOENET3TXRERR,
  EMIOENET3TXRFLUSHED,
  EMIOENET3TXRSOP,
  EMIOENET3TXRUNDERFLOW,
  EMIOENET3TXRVALID,
  EMIOENETTSUCLK,
  EMIOHUBPORTOVERCRNTUSB20,
  EMIOHUBPORTOVERCRNTUSB21,
  EMIOHUBPORTOVERCRNTUSB30,
  EMIOHUBPORTOVERCRNTUSB31,
  EMIOI2C0SCLI,
  EMIOI2C0SDAI,
  EMIOI2C1SCLI,
  EMIOI2C1SDAI,
  EMIOSDIO0CDN,
  EMIOSDIO0CMDIN,
  EMIOSDIO0FBCLKIN,
  EMIOSDIO0WP,
  EMIOSDIO1CDN,
  EMIOSDIO1CMDIN,
  EMIOSDIO1FBCLKIN,
  EMIOSDIO1WP,
  EMIOSPI0MI,
  EMIOSPI0SCLKI,
  EMIOSPI0SI,
  EMIOSPI0SSIN,
  EMIOSPI1MI,
  EMIOSPI1SCLKI,
  EMIOSPI1SI,
  EMIOSPI1SSIN,
  EMIOUART0CTSN,
  EMIOUART0DCDN,
  EMIOUART0DSRN,
  EMIOUART0RIN,
  EMIOUART0RX,
  EMIOUART1CTSN,
  EMIOUART1DCDN,
  EMIOUART1DSRN,
  EMIOUART1RIN,
  EMIOUART1RX,
  EMIOWDT0CLKI,
  EMIOWDT1CLKI,
  FMIOGEM0FIFORXCLKFROMPL,
  FMIOGEM0FIFOTXCLKFROMPL,
  FMIOGEM0SIGNALDETECT,
  FMIOGEM1FIFORXCLKFROMPL,
  FMIOGEM1FIFOTXCLKFROMPL,
  FMIOGEM1SIGNALDETECT,
  FMIOGEM2FIFORXCLKFROMPL,
  FMIOGEM2FIFOTXCLKFROMPL,
  FMIOGEM2SIGNALDETECT,
  FMIOGEM3FIFORXCLKFROMPL,
  FMIOGEM3FIFOTXCLKFROMPL,
  FMIOGEM3SIGNALDETECT,
  FMIOGEMTSUCLKFROMPL,
  MAXIGP0ACLK,
  MAXIGP0ARREADY,
  MAXIGP0AWREADY,
  MAXIGP0BVALID,
  MAXIGP0RLAST,
  MAXIGP0RVALID,
  MAXIGP0WREADY,
  MAXIGP1ACLK,
  MAXIGP1ARREADY,
  MAXIGP1AWREADY,
  MAXIGP1BVALID,
  MAXIGP1RLAST,
  MAXIGP1RVALID,
  MAXIGP1WREADY,
  MAXIGP2ACLK,
  MAXIGP2ARREADY,
  MAXIGP2AWREADY,
  MAXIGP2BVALID,
  MAXIGP2RLAST,
  MAXIGP2RVALID,
  MAXIGP2WREADY,
  NFIQ0LPDRPU,
  NFIQ1LPDRPU,
  NIRQ0LPDRPU,
  NIRQ1LPDRPU,
  PLACECLK,
  PLACPINACT,
  PLPSEVENTI,
  PLPSTRACECLK,
  PSS_ALTO_CORE_PAD_MGTRXN0IN,
  PSS_ALTO_CORE_PAD_MGTRXN1IN,
  PSS_ALTO_CORE_PAD_MGTRXN2IN,
  PSS_ALTO_CORE_PAD_MGTRXN3IN,
  PSS_ALTO_CORE_PAD_MGTRXP0IN,
  PSS_ALTO_CORE_PAD_MGTRXP1IN,
  PSS_ALTO_CORE_PAD_MGTRXP2IN,
  PSS_ALTO_CORE_PAD_MGTRXP3IN,
  PSS_ALTO_CORE_PAD_PADI,
  PSS_ALTO_CORE_PAD_REFN0IN,
  PSS_ALTO_CORE_PAD_REFN1IN,
  PSS_ALTO_CORE_PAD_REFN2IN,
  PSS_ALTO_CORE_PAD_REFN3IN,
  PSS_ALTO_CORE_PAD_REFP0IN,
  PSS_ALTO_CORE_PAD_REFP1IN,
  PSS_ALTO_CORE_PAD_REFP2IN,
  PSS_ALTO_CORE_PAD_REFP3IN,
  RPUEVENTI0,
  RPUEVENTI1,
  SACEFPDACREADY,
  SACEFPDARLOCK,
  SACEFPDARVALID,
  SACEFPDAWLOCK,
  SACEFPDAWVALID,
  SACEFPDBREADY,
  SACEFPDCDLAST,
  SACEFPDCDVALID,
  SACEFPDCRVALID,
  SACEFPDRACK,
  SACEFPDRREADY,
  SACEFPDWACK,
  SACEFPDWLAST,
  SACEFPDWUSER,
  SACEFPDWVALID,
  SAXIACPACLK,
  SAXIACPARLOCK,
  SAXIACPARVALID,
  SAXIACPAWLOCK,
  SAXIACPAWVALID,
  SAXIACPBREADY,
  SAXIACPRREADY,
  SAXIACPWLAST,
  SAXIACPWVALID,
  SAXIGP0ARLOCK,
  SAXIGP0ARUSER,
  SAXIGP0ARVALID,
  SAXIGP0AWLOCK,
  SAXIGP0AWUSER,
  SAXIGP0AWVALID,
  SAXIGP0BREADY,
  SAXIGP0RCLK,
  SAXIGP0RREADY,
  SAXIGP0WCLK,
  SAXIGP0WLAST,
  SAXIGP0WVALID,
  SAXIGP1ARLOCK,
  SAXIGP1ARUSER,
  SAXIGP1ARVALID,
  SAXIGP1AWLOCK,
  SAXIGP1AWUSER,
  SAXIGP1AWVALID,
  SAXIGP1BREADY,
  SAXIGP1RCLK,
  SAXIGP1RREADY,
  SAXIGP1WCLK,
  SAXIGP1WLAST,
  SAXIGP1WVALID,
  SAXIGP2ARLOCK,
  SAXIGP2ARUSER,
  SAXIGP2ARVALID,
  SAXIGP2AWLOCK,
  SAXIGP2AWUSER,
  SAXIGP2AWVALID,
  SAXIGP2BREADY,
  SAXIGP2RCLK,
  SAXIGP2RREADY,
  SAXIGP2WCLK,
  SAXIGP2WLAST,
  SAXIGP2WVALID,
  SAXIGP3ARLOCK,
  SAXIGP3ARUSER,
  SAXIGP3ARVALID,
  SAXIGP3AWLOCK,
  SAXIGP3AWUSER,
  SAXIGP3AWVALID,
  SAXIGP3BREADY,
  SAXIGP3RCLK,
  SAXIGP3RREADY,
  SAXIGP3WCLK,
  SAXIGP3WLAST,
  SAXIGP3WVALID,
  SAXIGP4ARLOCK,
  SAXIGP4ARUSER,
  SAXIGP4ARVALID,
  SAXIGP4AWLOCK,
  SAXIGP4AWUSER,
  SAXIGP4AWVALID,
  SAXIGP4BREADY,
  SAXIGP4RCLK,
  SAXIGP4RREADY,
  SAXIGP4WCLK,
  SAXIGP4WLAST,
  SAXIGP4WVALID,
  SAXIGP5ARLOCK,
  SAXIGP5ARUSER,
  SAXIGP5ARVALID,
  SAXIGP5AWLOCK,
  SAXIGP5AWUSER,
  SAXIGP5AWVALID,
  SAXIGP5BREADY,
  SAXIGP5RCLK,
  SAXIGP5RREADY,
  SAXIGP5WCLK,
  SAXIGP5WLAST,
  SAXIGP5WVALID,
  SAXIGP6ARLOCK,
  SAXIGP6ARUSER,
  SAXIGP6ARVALID,
  SAXIGP6AWLOCK,
  SAXIGP6AWUSER,
  SAXIGP6AWVALID,
  SAXIGP6BREADY,
  SAXIGP6RCLK,
  SAXIGP6RREADY,
  SAXIGP6WCLK,
  SAXIGP6WLAST,
  SAXIGP6WVALID,
  MAXIGP0RDATA,
  MAXIGP1RDATA,
  MAXIGP2RDATA,
  SACEFPDCDDATA,
  SACEFPDWDATA,
  SAXIACPWDATA,
  SAXIGP0WDATA,
  SAXIGP1WDATA,
  SAXIGP2WDATA,
  SAXIGP3WDATA,
  SAXIGP4WDATA,
  SAXIGP5WDATA,
  SAXIGP6WDATA,
  MAXIGP0BID,
  MAXIGP0RID,
  MAXIGP1BID,
  MAXIGP1RID,
  MAXIGP2BID,
  MAXIGP2RID,
  SACEFPDARUSER,
  SACEFPDAWUSER,
  SACEFPDWSTRB,
  SAXIACPWSTRB,
  SAXIGP0WSTRB,
  SAXIGP1WSTRB,
  SAXIGP2WSTRB,
  SAXIGP3WSTRB,
  SAXIGP4WSTRB,
  SAXIGP5WSTRB,
  SAXIGP6WSTRB,
  EMIOGEM0TSUINCCTRL,
  EMIOGEM1TSUINCCTRL,
  EMIOGEM2TSUINCCTRL,
  EMIOGEM3TSUINCCTRL,
  MAXIGP0BRESP,
  MAXIGP0RRESP,
  MAXIGP1BRESP,
  MAXIGP1RRESP,
  MAXIGP2BRESP,
  MAXIGP2RRESP,
  PLLAUXREFCLKLPD,
  SACEFPDARBAR,
  SACEFPDARBURST,
  SACEFPDARDOMAIN,
  SACEFPDAWBAR,
  SACEFPDAWBURST,
  SACEFPDAWDOMAIN,
  SAXIACPARBURST,
  SAXIACPARUSER,
  SAXIACPAWBURST,
  SAXIACPAWUSER,
  SAXIGP0ARBURST,
  SAXIGP0AWBURST,
  SAXIGP1ARBURST,
  SAXIGP1AWBURST,
  SAXIGP2ARBURST,
  SAXIGP2AWBURST,
  SAXIGP3ARBURST,
  SAXIGP3AWBURST,
  SAXIGP4ARBURST,
  SAXIGP4AWBURST,
  SAXIGP5ARBURST,
  SAXIGP5AWBURST,
  SAXIGP6ARBURST,
  SAXIGP6AWBURST,
  EMIOTTC0CLKI,
  EMIOTTC1CLKI,
  EMIOTTC2CLKI,
  EMIOTTC3CLKI,
  PLLAUXREFCLKFPD,
  SACEFPDARPROT,
  SACEFPDARSIZE,
  SACEFPDAWPROT,
  SACEFPDAWSIZE,
  SACEFPDAWSNOOP,
  SAXIACPARPROT,
  SAXIACPARSIZE,
  SAXIACPAWPROT,
  SAXIACPAWSIZE,
  SAXIGP0ARPROT,
  SAXIGP0ARSIZE,
  SAXIGP0AWPROT,
  SAXIGP0AWSIZE,
  SAXIGP1ARPROT,
  SAXIGP1ARSIZE,
  SAXIGP1AWPROT,
  SAXIGP1AWSIZE,
  SAXIGP2ARPROT,
  SAXIGP2ARSIZE,
  SAXIGP2AWPROT,
  SAXIGP2AWSIZE,
  SAXIGP3ARPROT,
  SAXIGP3ARSIZE,
  SAXIGP3AWPROT,
  SAXIGP3AWSIZE,
  SAXIGP4ARPROT,
  SAXIGP4ARSIZE,
  SAXIGP4AWPROT,
  SAXIGP4AWSIZE,
  SAXIGP5ARPROT,
  SAXIGP5ARSIZE,
  SAXIGP5AWPROT,
  SAXIGP5AWSIZE,
  SAXIGP6ARPROT,
  SAXIGP6ARSIZE,
  SAXIGP6AWPROT,
  SAXIGP6AWSIZE,
  DPSAXISAUDIOTDATA,
  FTMGPI,
  PLPMUGPI,
  DPLIVEGFXPIXEL1IN,
  DPLIVEVIDEOINPIXEL1,
  SAXIACPARADDR,
  SAXIACPAWADDR,
  PLFPGASTOP,
  PLPSAPUGICFIQ,
  PLPSAPUGICIRQ,
  PLPSTRIGACK,
  PLPSTRIGGER,
  PMUERRORFROMPL,
  SACEFPDARCACHE,
  SACEFPDARQOS,
  SACEFPDARREGION,
  SACEFPDARSNOOP,
  SACEFPDAWCACHE,
  SACEFPDAWQOS,
  SACEFPDAWREGION,
  SAXIACPARCACHE,
  SAXIACPARQOS,
  SAXIACPAWCACHE,
  SAXIACPAWQOS,
  SAXIGP0ARCACHE,
  SAXIGP0ARQOS,
  SAXIGP0AWCACHE,
  SAXIGP0AWQOS,
  SAXIGP1ARCACHE,
  SAXIGP1ARQOS,
  SAXIGP1AWCACHE,
  SAXIGP1AWQOS,
  SAXIGP2ARCACHE,
  SAXIGP2ARQOS,
  SAXIGP2AWCACHE,
  SAXIGP2AWQOS,
  SAXIGP3ARCACHE,
  SAXIGP3ARQOS,
  SAXIGP3AWCACHE,
  SAXIGP3AWQOS,
  SAXIGP4ARCACHE,
  SAXIGP4ARQOS,
  SAXIGP4AWCACHE,
  SAXIGP4AWQOS,
  SAXIGP5ARCACHE,
  SAXIGP5ARQOS,
  SAXIGP5AWCACHE,
  SAXIGP5AWQOS,
  SAXIGP6ARCACHE,
  SAXIGP6ARQOS,
  SAXIGP6AWCACHE,
  SAXIGP6AWQOS,
  SACEFPDARADDR,
  SACEFPDAWADDR,
  SAXIGP0ARADDR,
  SAXIGP0AWADDR,
  SAXIGP1ARADDR,
  SAXIGP1AWADDR,
  SAXIGP2ARADDR,
  SAXIGP2AWADDR,
  SAXIGP3ARADDR,
  SAXIGP3AWADDR,
  SAXIGP4ARADDR,
  SAXIGP4AWADDR,
  SAXIGP5ARADDR,
  SAXIGP5AWADDR,
  SAXIGP6ARADDR,
  SAXIGP6AWADDR,
  SACEFPDCRRESP,
  SAXIACPARID,
  SAXIACPAWID,
  STMEVENT,
  SACEFPDARID,
  SACEFPDAWID,
  SAXIGP0ARID,
  SAXIGP0AWID,
  SAXIGP1ARID,
  SAXIGP1AWID,
  SAXIGP2ARID,
  SAXIGP2AWID,
  SAXIGP3ARID,
  SAXIGP3AWID,
  SAXIGP4ARID,
  SAXIGP4AWID,
  SAXIGP5ARID,
  SAXIGP5AWID,
  SAXIGP6ARID,
  SAXIGP6AWID,
  ADMAFCICLK,
  DPLIVEGFXALPHAIN,
  EMIOENET0GMIIRXD,
  EMIOENET0TXRDATA,
  EMIOENET1GMIIRXD,
  EMIOENET1TXRDATA,
  EMIOENET2GMIIRXD,
  EMIOENET2TXRDATA,
  EMIOENET3GMIIRXD,
  EMIOENET3TXRDATA,
  EMIOSDIO0DATAIN,
  EMIOSDIO1DATAIN,
  GDMAFCICLK,
  PL2ADMACVLD,
  PL2ADMATACK,
  PL2GDMACVLD,
  PL2GDMATACK,
  PLPSIRQ0,
  PLPSIRQ1,
  SACEFPDARLEN,
  SACEFPDAWLEN,
  SAXIACPARLEN,
  SAXIACPAWLEN,
  SAXIGP0ARLEN,
  SAXIGP0AWLEN,
  SAXIGP1ARLEN,
  SAXIGP1AWLEN,
  SAXIGP2ARLEN,
  SAXIGP2AWLEN,
  SAXIGP3ARLEN,
  SAXIGP3AWLEN,
  SAXIGP4ARLEN,
  SAXIGP4AWLEN,
  SAXIGP5ARLEN,
  SAXIGP5AWLEN,
  SAXIGP6ARLEN,
  SAXIGP6AWLEN,
  EMIOGPIOI,
  DPAUDIOREFCLK,
  DPAUXDATAOEN,
  DPAUXDATAOUT,
  DPLIVEVIDEODEOUT,
  DPMAXISMIXEDAUDIOTID,
  DPMAXISMIXEDAUDIOTVALID,
  DPSAXISAUDIOTREADY,
  DPVIDEOOUTHSYNC,
  DPVIDEOOUTVSYNC,
  DPVIDEOREFCLK,
  EMIOCAN0PHYTX,
  EMIOCAN1PHYTX,
  EMIOENET0DMATXENDTOG,
  EMIOENET0GMIITXEN,
  EMIOENET0GMIITXER,
  EMIOENET0MDIOMDC,
  EMIOENET0MDIOO,
  EMIOENET0MDIOTN,
  EMIOENET0RXWEOP,
  EMIOENET0RXWERR,
  EMIOENET0RXWFLUSH,
  EMIOENET0RXWSOP,
  EMIOENET0RXWWR,
  EMIOENET0TXRRD,
  EMIOENET1DMATXENDTOG,
  EMIOENET1GMIITXEN,
  EMIOENET1GMIITXER,
  EMIOENET1MDIOMDC,
  EMIOENET1MDIOO,
  EMIOENET1MDIOTN,
  EMIOENET1RXWEOP,
  EMIOENET1RXWERR,
  EMIOENET1RXWFLUSH,
  EMIOENET1RXWSOP,
  EMIOENET1RXWWR,
  EMIOENET1TXRRD,
  EMIOENET2DMATXENDTOG,
  EMIOENET2GMIITXEN,
  EMIOENET2GMIITXER,
  EMIOENET2MDIOMDC,
  EMIOENET2MDIOO,
  EMIOENET2MDIOTN,
  EMIOENET2RXWEOP,
  EMIOENET2RXWERR,
  EMIOENET2RXWFLUSH,
  EMIOENET2RXWSOP,
  EMIOENET2RXWWR,
  EMIOENET2TXRRD,
  EMIOENET3DMATXENDTOG,
  EMIOENET3GMIITXEN,
  EMIOENET3GMIITXER,
  EMIOENET3MDIOMDC,
  EMIOENET3MDIOO,
  EMIOENET3MDIOTN,
  EMIOENET3RXWEOP,
  EMIOENET3RXWERR,
  EMIOENET3RXWFLUSH,
  EMIOENET3RXWSOP,
  EMIOENET3RXWWR,
  EMIOENET3TXRRD,
  EMIOGEM0DELAYREQRX,
  EMIOGEM0DELAYREQTX,
  EMIOGEM0PDELAYREQRX,
  EMIOGEM0PDELAYREQTX,
  EMIOGEM0PDELAYRESPRX,
  EMIOGEM0PDELAYRESPTX,
  EMIOGEM0RXSOF,
  EMIOGEM0SYNCFRAMERX,
  EMIOGEM0SYNCFRAMETX,
  EMIOGEM0TSUTIMERCMPVAL,
  EMIOGEM0TXRFIXEDLAT,
  EMIOGEM0TXSOF,
  EMIOGEM1DELAYREQRX,
  EMIOGEM1DELAYREQTX,
  EMIOGEM1PDELAYREQRX,
  EMIOGEM1PDELAYREQTX,
  EMIOGEM1PDELAYRESPRX,
  EMIOGEM1PDELAYRESPTX,
  EMIOGEM1RXSOF,
  EMIOGEM1SYNCFRAMERX,
  EMIOGEM1SYNCFRAMETX,
  EMIOGEM1TSUTIMERCMPVAL,
  EMIOGEM1TXRFIXEDLAT,
  EMIOGEM1TXSOF,
  EMIOGEM2DELAYREQRX,
  EMIOGEM2DELAYREQTX,
  EMIOGEM2PDELAYREQRX,
  EMIOGEM2PDELAYREQTX,
  EMIOGEM2PDELAYRESPRX,
  EMIOGEM2PDELAYRESPTX,
  EMIOGEM2RXSOF,
  EMIOGEM2SYNCFRAMERX,
  EMIOGEM2SYNCFRAMETX,
  EMIOGEM2TSUTIMERCMPVAL,
  EMIOGEM2TXRFIXEDLAT,
  EMIOGEM2TXSOF,
  EMIOGEM3DELAYREQRX,
  EMIOGEM3DELAYREQTX,
  EMIOGEM3PDELAYREQRX,
  EMIOGEM3PDELAYREQTX,
  EMIOGEM3PDELAYRESPRX,
  EMIOGEM3PDELAYRESPTX,
  EMIOGEM3RXSOF,
  EMIOGEM3SYNCFRAMERX,
  EMIOGEM3SYNCFRAMETX,
  EMIOGEM3TSUTIMERCMPVAL,
  EMIOGEM3TXRFIXEDLAT,
  EMIOGEM3TXSOF,
  EMIOI2C0SCLO,
  EMIOI2C0SCLTN,
  EMIOI2C0SDAO,
  EMIOI2C0SDATN,
  EMIOI2C1SCLO,
  EMIOI2C1SCLTN,
  EMIOI2C1SDAO,
  EMIOI2C1SDATN,
  EMIOSDIO0BUSPOWER,
  EMIOSDIO0CLKOUT,
  EMIOSDIO0CMDENA,
  EMIOSDIO0CMDOUT,
  EMIOSDIO0LEDCONTROL,
  EMIOSDIO1BUSPOWER,
  EMIOSDIO1CLKOUT,
  EMIOSDIO1CMDENA,
  EMIOSDIO1CMDOUT,
  EMIOSDIO1LEDCONTROL,
  EMIOSPI0MO,
  EMIOSPI0MOTN,
  EMIOSPI0SCLKO,
  EMIOSPI0SCLKTN,
  EMIOSPI0SO,
  EMIOSPI0SSNTN,
  EMIOSPI0STN,
  EMIOSPI1MO,
  EMIOSPI1MOTN,
  EMIOSPI1SCLKO,
  EMIOSPI1SCLKTN,
  EMIOSPI1SO,
  EMIOSPI1SSNTN,
  EMIOSPI1STN,
  EMIOU2DSPORTVBUSCTRLUSB30,
  EMIOU2DSPORTVBUSCTRLUSB31,
  EMIOU3DSPORTVBUSCTRLUSB30,
  EMIOU3DSPORTVBUSCTRLUSB31,
  EMIOUART0DTRN,
  EMIOUART0RTSN,
  EMIOUART0TX,
  EMIOUART1DTRN,
  EMIOUART1RTSN,
  EMIOUART1TX,
  EMIOWDT0RSTO,
  EMIOWDT1RSTO,
  FMIOGEM0FIFORXCLKTOPLBUFG,
  FMIOGEM0FIFOTXCLKTOPLBUFG,
  FMIOGEM1FIFORXCLKTOPLBUFG,
  FMIOGEM1FIFOTXCLKTOPLBUFG,
  FMIOGEM2FIFORXCLKTOPLBUFG,
  FMIOGEM2FIFOTXCLKTOPLBUFG,
  FMIOGEM3FIFORXCLKTOPLBUFG,
  FMIOGEM3FIFOTXCLKTOPLBUFG,
  FMIOGEMTSUCLKTOPLBUFG,
  MAXIGP0ARLOCK,
  MAXIGP0ARVALID,
  MAXIGP0AWLOCK,
  MAXIGP0AWVALID,
  MAXIGP0BREADY,
  MAXIGP0RREADY,
  MAXIGP0WLAST,
  MAXIGP0WVALID,
  MAXIGP1ARLOCK,
  MAXIGP1ARVALID,
  MAXIGP1AWLOCK,
  MAXIGP1AWVALID,
  MAXIGP1BREADY,
  MAXIGP1RREADY,
  MAXIGP1WLAST,
  MAXIGP1WVALID,
  MAXIGP2ARLOCK,
  MAXIGP2ARVALID,
  MAXIGP2AWLOCK,
  MAXIGP2AWVALID,
  MAXIGP2BREADY,
  MAXIGP2RREADY,
  MAXIGP2WLAST,
  MAXIGP2WVALID,
  OSCRTCCLK,
  PMUAIBAFIFMFPDREQ,
  PMUAIBAFIFMLPDREQ,
  PSPLEVENTO,
  PSPLTRACECTL,
  PSS_ALTO_CORE_PAD_MGTTXN0OUT,
  PSS_ALTO_CORE_PAD_MGTTXN1OUT,
  PSS_ALTO_CORE_PAD_MGTTXN2OUT,
  PSS_ALTO_CORE_PAD_MGTTXN3OUT,
  PSS_ALTO_CORE_PAD_MGTTXP0OUT,
  PSS_ALTO_CORE_PAD_MGTTXP1OUT,
  PSS_ALTO_CORE_PAD_MGTTXP2OUT,
  PSS_ALTO_CORE_PAD_MGTTXP3OUT,
  PSS_ALTO_CORE_PAD_PADO,
  RPUEVENTO0,
  RPUEVENTO1,
  SACEFPDACVALID,
  SACEFPDARREADY,
  SACEFPDAWREADY,
  SACEFPDBUSER,
  SACEFPDBVALID,
  SACEFPDCDREADY,
  SACEFPDCRREADY,
  SACEFPDRLAST,
  SACEFPDRUSER,
  SACEFPDRVALID,
  SACEFPDWREADY,
  SAXIACPARREADY,
  SAXIACPAWREADY,
  SAXIACPBVALID,
  SAXIACPRLAST,
  SAXIACPRVALID,
  SAXIACPWREADY,
  SAXIGP0ARREADY,
  SAXIGP0AWREADY,
  SAXIGP0BVALID,
  SAXIGP0RLAST,
  SAXIGP0RVALID,
  SAXIGP0WREADY,
  SAXIGP1ARREADY,
  SAXIGP1AWREADY,
  SAXIGP1BVALID,
  SAXIGP1RLAST,
  SAXIGP1RVALID,
  SAXIGP1WREADY,
  SAXIGP2ARREADY,
  SAXIGP2AWREADY,
  SAXIGP2BVALID,
  SAXIGP2RLAST,
  SAXIGP2RVALID,
  SAXIGP2WREADY,
  SAXIGP3ARREADY,
  SAXIGP3AWREADY,
  SAXIGP3BVALID,
  SAXIGP3RLAST,
  SAXIGP3RVALID,
  SAXIGP3WREADY,
  SAXIGP4ARREADY,
  SAXIGP4AWREADY,
  SAXIGP4BVALID,
  SAXIGP4RLAST,
  SAXIGP4RVALID,
  SAXIGP4WREADY,
  SAXIGP5ARREADY,
  SAXIGP5AWREADY,
  SAXIGP5BVALID,
  SAXIGP5RLAST,
  SAXIGP5RVALID,
  SAXIGP5WREADY,
  SAXIGP6ARREADY,
  SAXIGP6AWREADY,
  SAXIGP6BVALID,
  SAXIGP6RLAST,
  SAXIGP6RVALID,
  SAXIGP6WREADY,
  MAXIGP0WDATA,
  MAXIGP1WDATA,
  MAXIGP2WDATA,
  SACEFPDRDATA,
  SAXIACPRDATA,
  SAXIGP0RDATA,
  SAXIGP1RDATA,
  SAXIGP2RDATA,
  SAXIGP3RDATA,
  SAXIGP4RDATA,
  SAXIGP5RDATA,
  SAXIGP6RDATA,
  MAXIGP0ARID,
  MAXIGP0ARUSER,
  MAXIGP0AWID,
  MAXIGP0AWUSER,
  MAXIGP0WSTRB,
  MAXIGP1ARID,
  MAXIGP1ARUSER,
  MAXIGP1AWID,
  MAXIGP1AWUSER,
  MAXIGP1WSTRB,
  MAXIGP2ARID,
  MAXIGP2ARUSER,
  MAXIGP2AWID,
  MAXIGP2AWUSER,
  MAXIGP2WSTRB,
  EMIOENET0DMABUSWIDTH,
  EMIOENET1DMABUSWIDTH,
  EMIOENET2DMABUSWIDTH,
  EMIOENET3DMABUSWIDTH,
  MAXIGP0ARBURST,
  MAXIGP0AWBURST,
  MAXIGP1ARBURST,
  MAXIGP1AWBURST,
  MAXIGP2ARBURST,
  MAXIGP2AWBURST,
  SACEFPDBRESP,
  SAXIACPBRESP,
  SAXIACPRRESP,
  SAXIGP0BRESP,
  SAXIGP0RRESP,
  SAXIGP1BRESP,
  SAXIGP1RRESP,
  SAXIGP2BRESP,
  SAXIGP2RRESP,
  SAXIGP3BRESP,
  SAXIGP3RRESP,
  SAXIGP4BRESP,
  SAXIGP4RRESP,
  SAXIGP5BRESP,
  SAXIGP5RRESP,
  SAXIGP6BRESP,
  SAXIGP6RRESP,
  EMIOENET0SPEEDMODE,
  EMIOENET1SPEEDMODE,
  EMIOENET2SPEEDMODE,
  EMIOENET3SPEEDMODE,
  EMIOSDIO0BUSVOLT,
  EMIOSDIO1BUSVOLT,
  EMIOSPI0SSON,
  EMIOSPI1SSON,
  EMIOTTC0WAVEO,
  EMIOTTC1WAVEO,
  EMIOTTC2WAVEO,
  EMIOTTC3WAVEO,
  MAXIGP0ARPROT,
  MAXIGP0ARSIZE,
  MAXIGP0AWPROT,
  MAXIGP0AWSIZE,
  MAXIGP1ARPROT,
  MAXIGP1ARSIZE,
  MAXIGP1AWPROT,
  MAXIGP1AWSIZE,
  MAXIGP2ARPROT,
  MAXIGP2ARSIZE,
  MAXIGP2AWPROT,
  MAXIGP2AWSIZE,
  SACEFPDACPROT,
  DPMAXISMIXEDAUDIOTDATA,
  FTMGPO,
  PMUPLGPO,
  PSPLTRACEDATA,
  DPVIDEOOUTPIXEL1,
  MAXIGP0ARADDR,
  MAXIGP0AWADDR,
  MAXIGP1ARADDR,
  MAXIGP1AWADDR,
  MAXIGP2ARADDR,
  MAXIGP2AWADDR,
  EMIOENET0TXRSTATUS,
  EMIOENET1TXRSTATUS,
  EMIOENET2TXRSTATUS,
  EMIOENET3TXRSTATUS,
  MAXIGP0ARCACHE,
  MAXIGP0ARQOS,
  MAXIGP0AWCACHE,
  MAXIGP0AWQOS,
  MAXIGP1ARCACHE,
  MAXIGP1ARQOS,
  MAXIGP1AWCACHE,
  MAXIGP1AWQOS,
  MAXIGP2ARCACHE,
  MAXIGP2ARQOS,
  MAXIGP2AWCACHE,
  MAXIGP2AWQOS,
  PLCLK,
  PL_RESETN0,
  PL_RESETN1,
  PL_RESETN2,
  PL_RESETN3,
  PSPLSTANDBYWFE,
  PSPLSTANDBYWFI,
  PSPLTRIGACK,
  PSPLTRIGGER,
  SACEFPDACSNOOP,
  SACEFPDRRESP,
  SAXIGP0RACOUNT,
  SAXIGP0WACOUNT,
  SAXIGP1RACOUNT,
  SAXIGP1WACOUNT,
  SAXIGP2RACOUNT,
  SAXIGP2WACOUNT,
  SAXIGP3RACOUNT,
  SAXIGP3WACOUNT,
  SAXIGP4RACOUNT,
  SAXIGP4WACOUNT,
  SAXIGP5RACOUNT,
  SAXIGP5WACOUNT,
  SAXIGP6RACOUNT,
  SAXIGP6WACOUNT,
  SACEFPDACADDR,
  EMIOENET0RXWSTATUS,
  EMIOENET1RXWSTATUS,
  EMIOENET2RXWSTATUS,
  EMIOENET3RXWSTATUS,
  PMUERRORTOPL,
  SAXIACPBID,
  SAXIACPRID,
  SACEFPDBID,
  SACEFPDRID,
  SAXIGP0BID,
  SAXIGP0RID,
  SAXIGP1BID,
  SAXIGP1RID,
  SAXIGP2BID,
  SAXIGP2RID,
  SAXIGP3BID,
  SAXIGP3RID,
  SAXIGP4BID,
  SAXIGP4RID,
  SAXIGP5BID,
  SAXIGP5RID,
  SAXIGP6BID,
  SAXIGP6RID,
  PSPLIRQFPD,
  ADMA2PLCACK,
  ADMA2PLTVLD,
  EMIOENET0GMIITXD,
  EMIOENET0RXWDATA,
  EMIOENET1GMIITXD,
  EMIOENET1RXWDATA,
  EMIOENET2GMIITXD,
  EMIOENET2RXWDATA,
  EMIOENET3GMIITXD,
  EMIOENET3RXWDATA,
  EMIOSDIO0DATAENA,
  EMIOSDIO0DATAOUT,
  EMIOSDIO1DATAENA,
  EMIOSDIO1DATAOUT,
  GDMA2PLCACK,
  GDMA2PLTVLD,
  MAXIGP0ARLEN,
  MAXIGP0AWLEN,
  MAXIGP1ARLEN,
  MAXIGP1AWLEN,
  MAXIGP2ARLEN,
  MAXIGP2AWLEN,
  SAXIGP0RCOUNT,
  SAXIGP0WCOUNT,
  SAXIGP1RCOUNT,
  SAXIGP1WCOUNT,
  SAXIGP2RCOUNT,
  SAXIGP2WCOUNT,
  SAXIGP3RCOUNT,
  SAXIGP3WCOUNT,
  SAXIGP4RCOUNT,
  SAXIGP4WCOUNT,
  SAXIGP5RCOUNT,
  SAXIGP5WCOUNT,
  SAXIGP6RCOUNT,
  SAXIGP6WCOUNT,
  EMIOENET0GEMTSUTIMERCNT,
  EMIOGPIOO,
  EMIOGPIOTN,
  PSPLIRQLPD
  );

  /* parameters for gen_clk */
  parameter C_FCLK_CLK0_FREQ = 50;
  parameter C_FCLK_CLK1_FREQ = 50;
  parameter C_FCLK_CLK3_FREQ = 50;
  parameter C_FCLK_CLK2_FREQ = 50;

  /* parameters for Slave ports */
  parameter C_USE_S_AXI_GP0 = 1;
  parameter C_USE_S_AXI_GP1 = 1;
  parameter C_USE_S_AXI_GP2 = 1;
  parameter C_USE_S_AXI_GP3 = 1;
  parameter C_USE_S_AXI_GP4 = 1;
  parameter C_USE_S_AXI_GP5 = 1;
  parameter C_USE_S_AXI_GP6 = 1;
  parameter C_USE_S_AXI_ACP = 1;
  parameter C_USE_S_AXI_ACE = 1;

  parameter C_S_AXI_GP0_DATA_WIDTH = 32;
  parameter C_S_AXI_GP1_DATA_WIDTH = 32;
  parameter C_S_AXI_GP2_DATA_WIDTH = 32;
  parameter C_S_AXI_GP3_DATA_WIDTH = 32;
  parameter C_S_AXI_GP4_DATA_WIDTH = 32;
  parameter C_S_AXI_GP5_DATA_WIDTH = 32;
  parameter C_S_AXI_GP6_DATA_WIDTH = 32;

  /* parameters for Master ports */
  parameter C_USE_M_AXI_GP0 = 1;
  parameter C_USE_M_AXI_GP1 = 1;
  parameter C_USE_M_AXI_GP2 = 1;

  parameter C_M_AXI_GP0_DATA_WIDTH = 32;
  parameter C_M_AXI_GP1_DATA_WIDTH = 32;
  parameter C_M_AXI_GP2_DATA_WIDTH = 32;

  /* parameters for High DDR */
  parameter C_HIGH_DDR_EN    = 0;
  
  `include "zynq_ultra_ps_e_vip_v1_0_6_local_params.sv"

   input            PSS_ALTO_CORE_PAD_CLK; //inout
   inout            PSS_ALTO_CORE_PAD_DONEB;
   inout            PSS_ALTO_CORE_PAD_DRAMACTN;
   inout            PSS_ALTO_CORE_PAD_DRAMALERTN;
   inout            PSS_ALTO_CORE_PAD_DRAMPARITY;
   inout            PSS_ALTO_CORE_PAD_DRAMRAMRSTN;
   inout            PSS_ALTO_CORE_PAD_ERROROUT;
   inout            PSS_ALTO_CORE_PAD_ERRORSTATUS;
   inout            PSS_ALTO_CORE_PAD_INITB;
   inout            PSS_ALTO_CORE_PAD_JTAGTCK;
   inout            PSS_ALTO_CORE_PAD_JTAGTDI;
   inout            PSS_ALTO_CORE_PAD_JTAGTDO;
   inout            PSS_ALTO_CORE_PAD_JTAGTMS;
   input            PSS_ALTO_CORE_PAD_PORB; //inout
   inout            PSS_ALTO_CORE_PAD_PROGB;
   inout            PSS_ALTO_CORE_PAD_RCALIBINOUT;
   input            PSS_ALTO_CORE_PAD_SRSTB; //inout
   inout            PSS_ALTO_CORE_PAD_ZQ;
   inout  [17:0]    PSS_ALTO_CORE_PAD_DRAMA;
   inout  [1:0]     PSS_ALTO_CORE_PAD_DRAMBA;
   inout  [1:0]     PSS_ALTO_CORE_PAD_DRAMBG;
   inout  [1:0]     PSS_ALTO_CORE_PAD_DRAMCK;
   inout  [1:0]     PSS_ALTO_CORE_PAD_DRAMCKE;
   inout  [1:0]     PSS_ALTO_CORE_PAD_DRAMCKN;
   inout  [1:0]     PSS_ALTO_CORE_PAD_DRAMCSN;
   inout  [1:0]     PSS_ALTO_CORE_PAD_DRAMODT;
   inout  [3:0]     PSS_ALTO_CORE_PAD_BOOTMODE;
   inout  [71:0]    PSS_ALTO_CORE_PAD_DRAMDQ;
   inout  [77:0]    PSS_ALTO_CORE_PAD_MIO;
   inout  [8:0]     PSS_ALTO_CORE_PAD_DRAMDM;
   inout  [8:0]     PSS_ALTO_CORE_PAD_DRAMDQS;
   inout  [8:0]     PSS_ALTO_CORE_PAD_DRAMDQSN;
   input            AIBPMUAFIFMFPDACK;
   input            AIBPMUAFIFMLPDACK;
   input            DDRCEXTREFRESHRANK0REQ;
   input            DDRCEXTREFRESHRANK1REQ;
   input            DDRCREFRESHPLCLK;
   input            DPAUXDATAIN;
   input            DPEXTERNALCUSTOMEVENT1;
   input            DPEXTERNALCUSTOMEVENT2;
   input            DPEXTERNALVSYNCEVENT;
   input            DPHOTPLUGDETECT;
   input            DPLIVEVIDEOINDE;
   input            DPLIVEVIDEOINHSYNC;
   input            DPLIVEVIDEOINVSYNC;
   input            DPMAXISMIXEDAUDIOTREADY;
   input            DPSAXISAUDIOCLK;
   input            DPSAXISAUDIOTID;
   input            DPSAXISAUDIOTVALID;
   input            DPVIDEOINCLK;
   input            EMIOCAN0PHYRX;
   input            EMIOCAN1PHYRX;
   input            EMIOENET0DMATXSTATUSTOG;
   input            EMIOENET0EXTINTIN;
   input            EMIOENET0GMIICOL;
   input            EMIOENET0GMIICRS;
   input            EMIOENET0GMIIRXCLK;
   input            EMIOENET0GMIIRXDV;
   input            EMIOENET0GMIIRXER;
   input            EMIOENET0GMIITXCLK;
   input            EMIOENET0MDIOI;
   input            EMIOENET0RXWOVERFLOW;
   input            EMIOENET0TXRCONTROL;
   input            EMIOENET0TXRDATARDY;
   input            EMIOENET0TXREOP;
   input            EMIOENET0TXRERR;
   input            EMIOENET0TXRFLUSHED;
   input            EMIOENET0TXRSOP;
   input            EMIOENET0TXRUNDERFLOW;
   input            EMIOENET0TXRVALID;
   input            EMIOENET1DMATXSTATUSTOG;
   input            EMIOENET1EXTINTIN;
   input            EMIOENET1GMIICOL;
   input            EMIOENET1GMIICRS;
   input            EMIOENET1GMIIRXCLK;
   input            EMIOENET1GMIIRXDV;
   input            EMIOENET1GMIIRXER;
   input            EMIOENET1GMIITXCLK;
   input            EMIOENET1MDIOI;
   input            EMIOENET1RXWOVERFLOW;
   input            EMIOENET1TXRCONTROL;
   input            EMIOENET1TXRDATARDY;
   input            EMIOENET1TXREOP;
   input            EMIOENET1TXRERR;
   input            EMIOENET1TXRFLUSHED;
   input            EMIOENET1TXRSOP;
   input            EMIOENET1TXRUNDERFLOW;
   input            EMIOENET1TXRVALID;
   input            EMIOENET2DMATXSTATUSTOG;
   input            EMIOENET2EXTINTIN;
   input            EMIOENET2GMIICOL;
   input            EMIOENET2GMIICRS;
   input            EMIOENET2GMIIRXCLK;
   input            EMIOENET2GMIIRXDV;
   input            EMIOENET2GMIIRXER;
   input            EMIOENET2GMIITXCLK;
   input            EMIOENET2MDIOI;
   input            EMIOENET2RXWOVERFLOW;
   input            EMIOENET2TXRCONTROL;
   input            EMIOENET2TXRDATARDY;
   input            EMIOENET2TXREOP;
   input            EMIOENET2TXRERR;
   input            EMIOENET2TXRFLUSHED;
   input            EMIOENET2TXRSOP;
   input            EMIOENET2TXRUNDERFLOW;
   input            EMIOENET2TXRVALID;
   input            EMIOENET3DMATXSTATUSTOG;
   input            EMIOENET3EXTINTIN;
   input            EMIOENET3GMIICOL;
   input            EMIOENET3GMIICRS;
   input            EMIOENET3GMIIRXCLK;
   input            EMIOENET3GMIIRXDV;
   input            EMIOENET3GMIIRXER;
   input            EMIOENET3GMIITXCLK;
   input            EMIOENET3MDIOI;
   input            EMIOENET3RXWOVERFLOW;
   input            EMIOENET3TXRCONTROL;
   input            EMIOENET3TXRDATARDY;
   input            EMIOENET3TXREOP;
   input            EMIOENET3TXRERR;
   input            EMIOENET3TXRFLUSHED;
   input            EMIOENET3TXRSOP;
   input            EMIOENET3TXRUNDERFLOW;
   input            EMIOENET3TXRVALID;
   input            EMIOENETTSUCLK;
   input            EMIOHUBPORTOVERCRNTUSB20;
   input            EMIOHUBPORTOVERCRNTUSB21;
   input            EMIOHUBPORTOVERCRNTUSB30;
   input            EMIOHUBPORTOVERCRNTUSB31;
   input            EMIOI2C0SCLI;
   input            EMIOI2C0SDAI;
   input            EMIOI2C1SCLI;
   input            EMIOI2C1SDAI;
   input            EMIOSDIO0CDN;
   input            EMIOSDIO0CMDIN;
   input            EMIOSDIO0FBCLKIN;
   input            EMIOSDIO0WP;
   input            EMIOSDIO1CDN;
   input            EMIOSDIO1CMDIN;
   input            EMIOSDIO1FBCLKIN;
   input            EMIOSDIO1WP;
   input            EMIOSPI0MI;
   input            EMIOSPI0SCLKI;
   input            EMIOSPI0SI;
   input            EMIOSPI0SSIN;
   input            EMIOSPI1MI;
   input            EMIOSPI1SCLKI;
   input            EMIOSPI1SI;
   input            EMIOSPI1SSIN;
   input            EMIOUART0CTSN;
   input            EMIOUART0DCDN;
   input            EMIOUART0DSRN;
   input            EMIOUART0RIN;
   input            EMIOUART0RX;
   input            EMIOUART1CTSN;
   input            EMIOUART1DCDN;
   input            EMIOUART1DSRN;
   input            EMIOUART1RIN;
   input            EMIOUART1RX;
   input            EMIOWDT0CLKI;
   input            EMIOWDT1CLKI;
   input            FMIOGEM0FIFORXCLKFROMPL;
   input            FMIOGEM0FIFOTXCLKFROMPL;
   input            FMIOGEM0SIGNALDETECT;
   input            FMIOGEM1FIFORXCLKFROMPL;
   input            FMIOGEM1FIFOTXCLKFROMPL;
   input            FMIOGEM1SIGNALDETECT;
   input            FMIOGEM2FIFORXCLKFROMPL;
   input            FMIOGEM2FIFOTXCLKFROMPL;
   input            FMIOGEM2SIGNALDETECT;
   input            FMIOGEM3FIFORXCLKFROMPL;
   input            FMIOGEM3FIFOTXCLKFROMPL;
   input            FMIOGEM3SIGNALDETECT;
   input            FMIOGEMTSUCLKFROMPL;
   input            MAXIGP0ACLK;
   input            MAXIGP0ARREADY;
   input            MAXIGP0AWREADY;
   input            MAXIGP0BVALID;
   input            MAXIGP0RLAST;
   input            MAXIGP0RVALID;
   input            MAXIGP0WREADY;
   input            MAXIGP1ACLK;
   input            MAXIGP1ARREADY;
   input            MAXIGP1AWREADY;
   input            MAXIGP1BVALID;
   input            MAXIGP1RLAST;
   input            MAXIGP1RVALID;
   input            MAXIGP1WREADY;
   input            MAXIGP2ACLK;
   input            MAXIGP2ARREADY;
   input            MAXIGP2AWREADY;
   input            MAXIGP2BVALID;
   input            MAXIGP2RLAST;
   input            MAXIGP2RVALID;
   input            MAXIGP2WREADY;
   input            NFIQ0LPDRPU;
   input            NFIQ1LPDRPU;
   input            NIRQ0LPDRPU;
   input            NIRQ1LPDRPU;
   input            PLACECLK;
   input            PLACPINACT;
   input            PLPSEVENTI;
   input            PLPSTRACECLK;
   input            PSS_ALTO_CORE_PAD_MGTRXN0IN;
   input            PSS_ALTO_CORE_PAD_MGTRXN1IN;
   input            PSS_ALTO_CORE_PAD_MGTRXN2IN;
   input            PSS_ALTO_CORE_PAD_MGTRXN3IN;
   input            PSS_ALTO_CORE_PAD_MGTRXP0IN;
   input            PSS_ALTO_CORE_PAD_MGTRXP1IN;
   input            PSS_ALTO_CORE_PAD_MGTRXP2IN;
   input            PSS_ALTO_CORE_PAD_MGTRXP3IN;
   input            PSS_ALTO_CORE_PAD_PADI;
   input            PSS_ALTO_CORE_PAD_REFN0IN;
   input            PSS_ALTO_CORE_PAD_REFN1IN;
   input            PSS_ALTO_CORE_PAD_REFN2IN;
   input            PSS_ALTO_CORE_PAD_REFN3IN;
   input            PSS_ALTO_CORE_PAD_REFP0IN;
   input            PSS_ALTO_CORE_PAD_REFP1IN;
   input            PSS_ALTO_CORE_PAD_REFP2IN;
   input            PSS_ALTO_CORE_PAD_REFP3IN;
   input            RPUEVENTI0;
   input            RPUEVENTI1;
   input            SACEFPDACREADY;
   input            SACEFPDARLOCK;
   input            SACEFPDARVALID;
   input            SACEFPDAWLOCK;
   input            SACEFPDAWVALID;
   input            SACEFPDBREADY;
   input            SACEFPDCDLAST;
   input            SACEFPDCDVALID;
   input            SACEFPDCRVALID;
   input            SACEFPDRACK;
   input            SACEFPDRREADY;
   input            SACEFPDWACK;
   input            SACEFPDWLAST;
   input            SACEFPDWUSER;
   input            SACEFPDWVALID;
   input            SAXIACPACLK;
   input            SAXIACPARLOCK;
   input            SAXIACPARVALID;
   input            SAXIACPAWLOCK;
   input            SAXIACPAWVALID;
   input            SAXIACPBREADY;
   input            SAXIACPRREADY;
   input            SAXIACPWLAST;
   input            SAXIACPWVALID;
   input            SAXIGP0ARLOCK;
   input            SAXIGP0ARUSER;
   input            SAXIGP0ARVALID;
   input            SAXIGP0AWLOCK;
   input            SAXIGP0AWUSER;
   input            SAXIGP0AWVALID;
   input            SAXIGP0BREADY;
   input            SAXIGP0RCLK;
   input            SAXIGP0RREADY;
   input            SAXIGP0WCLK;
   input            SAXIGP0WLAST;
   input            SAXIGP0WVALID;
   input            SAXIGP1ARLOCK;
   input            SAXIGP1ARUSER;
   input            SAXIGP1ARVALID;
   input            SAXIGP1AWLOCK;
   input            SAXIGP1AWUSER;
   input            SAXIGP1AWVALID;
   input            SAXIGP1BREADY;
   input            SAXIGP1RCLK;
   input            SAXIGP1RREADY;
   input            SAXIGP1WCLK;
   input            SAXIGP1WLAST;
   input            SAXIGP1WVALID;
   input            SAXIGP2ARLOCK;
   input            SAXIGP2ARUSER;
   input            SAXIGP2ARVALID;
   input            SAXIGP2AWLOCK;
   input            SAXIGP2AWUSER;
   input            SAXIGP2AWVALID;
   input            SAXIGP2BREADY;
   input            SAXIGP2RCLK;
   input            SAXIGP2RREADY;
   input            SAXIGP2WCLK;
   input            SAXIGP2WLAST;
   input            SAXIGP2WVALID;
   input            SAXIGP3ARLOCK;
   input            SAXIGP3ARUSER;
   input            SAXIGP3ARVALID;
   input            SAXIGP3AWLOCK;
   input            SAXIGP3AWUSER;
   input            SAXIGP3AWVALID;
   input            SAXIGP3BREADY;
   input            SAXIGP3RCLK;
   input            SAXIGP3RREADY;
   input            SAXIGP3WCLK;
   input            SAXIGP3WLAST;
   input            SAXIGP3WVALID;
   input            SAXIGP4ARLOCK;
   input            SAXIGP4ARUSER;
   input            SAXIGP4ARVALID;
   input            SAXIGP4AWLOCK;
   input            SAXIGP4AWUSER;
   input            SAXIGP4AWVALID;
   input            SAXIGP4BREADY;
   input            SAXIGP4RCLK;
   input            SAXIGP4RREADY;
   input            SAXIGP4WCLK;
   input            SAXIGP4WLAST;
   input            SAXIGP4WVALID;
   input            SAXIGP5ARLOCK;
   input            SAXIGP5ARUSER;
   input            SAXIGP5ARVALID;
   input            SAXIGP5AWLOCK;
   input            SAXIGP5AWUSER;
   input            SAXIGP5AWVALID;
   input            SAXIGP5BREADY;
   input            SAXIGP5RCLK;
   input            SAXIGP5RREADY;
   input            SAXIGP5WCLK;
   input            SAXIGP5WLAST;
   input            SAXIGP5WVALID;
   input            SAXIGP6ARLOCK;
   input            SAXIGP6ARUSER;
   input            SAXIGP6ARVALID;
   input            SAXIGP6AWLOCK;
   input            SAXIGP6AWUSER;
   input            SAXIGP6AWVALID;
   input            SAXIGP6BREADY;
   input            SAXIGP6RCLK;
   input            SAXIGP6RREADY;
   input            SAXIGP6WCLK;
   input            SAXIGP6WLAST;
   input            SAXIGP6WVALID;
   input  [127:0]   MAXIGP0RDATA;
   input  [127:0]   MAXIGP1RDATA;
   input  [127:0]   MAXIGP2RDATA;
   input  [127:0]   SACEFPDCDDATA;
   input  [127:0]   SACEFPDWDATA;
   input  [127:0]   SAXIACPWDATA;
   input  [127:0]   SAXIGP0WDATA;
   input  [127:0]   SAXIGP1WDATA;
   input  [127:0]   SAXIGP2WDATA;
   input  [127:0]   SAXIGP3WDATA;
   input  [127:0]   SAXIGP4WDATA;
   input  [127:0]   SAXIGP5WDATA;
   input  [127:0]   SAXIGP6WDATA;
   input  [15:0]    MAXIGP0BID;
   input  [15:0]    MAXIGP0RID;
   input  [15:0]    MAXIGP1BID;
   input  [15:0]    MAXIGP1RID;
   input  [15:0]    MAXIGP2BID;
   input  [15:0]    MAXIGP2RID;
   input  [15:0]    SACEFPDARUSER;
   input  [15:0]    SACEFPDAWUSER;
   input  [15:0]    SACEFPDWSTRB;
   input  [15:0]    SAXIACPWSTRB;
   input  [15:0]    SAXIGP0WSTRB;
   input  [15:0]    SAXIGP1WSTRB;
   input  [15:0]    SAXIGP2WSTRB;
   input  [15:0]    SAXIGP3WSTRB;
   input  [15:0]    SAXIGP4WSTRB;
   input  [15:0]    SAXIGP5WSTRB;
   input  [15:0]    SAXIGP6WSTRB;
   input  [1:0]     EMIOGEM0TSUINCCTRL;
   input  [1:0]     EMIOGEM1TSUINCCTRL;
   input  [1:0]     EMIOGEM2TSUINCCTRL;
   input  [1:0]     EMIOGEM3TSUINCCTRL;
   input  [1:0]     MAXIGP0BRESP;
   input  [1:0]     MAXIGP0RRESP;
   input  [1:0]     MAXIGP1BRESP;
   input  [1:0]     MAXIGP1RRESP;
   input  [1:0]     MAXIGP2BRESP;
   input  [1:0]     MAXIGP2RRESP;
   input  [1:0]     PLLAUXREFCLKLPD;
   input  [1:0]     SACEFPDARBAR;
   input  [1:0]     SACEFPDARBURST;
   input  [1:0]     SACEFPDARDOMAIN;
   input  [1:0]     SACEFPDAWBAR;
   input  [1:0]     SACEFPDAWBURST;
   input  [1:0]     SACEFPDAWDOMAIN;
   input  [1:0]     SAXIACPARBURST;
   input  [1:0]     SAXIACPARUSER;
   input  [1:0]     SAXIACPAWBURST;
   input  [1:0]     SAXIACPAWUSER;
   input  [1:0]     SAXIGP0ARBURST;
   input  [1:0]     SAXIGP0AWBURST;
   input  [1:0]     SAXIGP1ARBURST;
   input  [1:0]     SAXIGP1AWBURST;
   input  [1:0]     SAXIGP2ARBURST;
   input  [1:0]     SAXIGP2AWBURST;
   input  [1:0]     SAXIGP3ARBURST;
   input  [1:0]     SAXIGP3AWBURST;
   input  [1:0]     SAXIGP4ARBURST;
   input  [1:0]     SAXIGP4AWBURST;
   input  [1:0]     SAXIGP5ARBURST;
   input  [1:0]     SAXIGP5AWBURST;
   input  [1:0]     SAXIGP6ARBURST;
   input  [1:0]     SAXIGP6AWBURST;
   input  [2:0]     EMIOTTC0CLKI;
   input  [2:0]     EMIOTTC1CLKI;
   input  [2:0]     EMIOTTC2CLKI;
   input  [2:0]     EMIOTTC3CLKI;
   input  [2:0]     PLLAUXREFCLKFPD;
   input  [2:0]     SACEFPDARPROT;
   input  [2:0]     SACEFPDARSIZE;
   input  [2:0]     SACEFPDAWPROT;
   input  [2:0]     SACEFPDAWSIZE;
   input  [2:0]     SACEFPDAWSNOOP;
   input  [2:0]     SAXIACPARPROT;
   input  [2:0]     SAXIACPARSIZE;
   input  [2:0]     SAXIACPAWPROT;
   input  [2:0]     SAXIACPAWSIZE;
   input  [2:0]     SAXIGP0ARPROT;
   input  [2:0]     SAXIGP0ARSIZE;
   input  [2:0]     SAXIGP0AWPROT;
   input  [2:0]     SAXIGP0AWSIZE;
   input  [2:0]     SAXIGP1ARPROT;
   input  [2:0]     SAXIGP1ARSIZE;
   input  [2:0]     SAXIGP1AWPROT;
   input  [2:0]     SAXIGP1AWSIZE;
   input  [2:0]     SAXIGP2ARPROT;
   input  [2:0]     SAXIGP2ARSIZE;
   input  [2:0]     SAXIGP2AWPROT;
   input  [2:0]     SAXIGP2AWSIZE;
   input  [2:0]     SAXIGP3ARPROT;
   input  [2:0]     SAXIGP3ARSIZE;
   input  [2:0]     SAXIGP3AWPROT;
   input  [2:0]     SAXIGP3AWSIZE;
   input  [2:0]     SAXIGP4ARPROT;
   input  [2:0]     SAXIGP4ARSIZE;
   input  [2:0]     SAXIGP4AWPROT;
   input  [2:0]     SAXIGP4AWSIZE;
   input  [2:0]     SAXIGP5ARPROT;
   input  [2:0]     SAXIGP5ARSIZE;
   input  [2:0]     SAXIGP5AWPROT;
   input  [2:0]     SAXIGP5AWSIZE;
   input  [2:0]     SAXIGP6ARPROT;
   input  [2:0]     SAXIGP6ARSIZE;
   input  [2:0]     SAXIGP6AWPROT;
   input  [2:0]     SAXIGP6AWSIZE;
   input  [31:0]    DPSAXISAUDIOTDATA;
   input  [31:0]    FTMGPI;
   input  [31:0]    PLPMUGPI;
   input  [35:0]    DPLIVEGFXPIXEL1IN;
   input  [35:0]    DPLIVEVIDEOINPIXEL1;
   input  [39:0]    SAXIACPARADDR;
   input  [39:0]    SAXIACPAWADDR;
   input  [3:0]     PLFPGASTOP;
   input  [3:0]     PLPSAPUGICFIQ;
   input  [3:0]     PLPSAPUGICIRQ;
   input  [3:0]     PLPSTRIGACK;
   input  [3:0]     PLPSTRIGGER;
   input  [3:0]     PMUERRORFROMPL;
   input  [3:0]     SACEFPDARCACHE;
   input  [3:0]     SACEFPDARQOS;
   input  [3:0]     SACEFPDARREGION;
   input  [3:0]     SACEFPDARSNOOP;
   input  [3:0]     SACEFPDAWCACHE;
   input  [3:0]     SACEFPDAWQOS;
   input  [3:0]     SACEFPDAWREGION;
   input  [3:0]     SAXIACPARCACHE;
   input  [3:0]     SAXIACPARQOS;
   input  [3:0]     SAXIACPAWCACHE;
   input  [3:0]     SAXIACPAWQOS;
   input  [3:0]     SAXIGP0ARCACHE;
   input  [3:0]     SAXIGP0ARQOS;
   input  [3:0]     SAXIGP0AWCACHE;
   input  [3:0]     SAXIGP0AWQOS;
   input  [3:0]     SAXIGP1ARCACHE;
   input  [3:0]     SAXIGP1ARQOS;
   input  [3:0]     SAXIGP1AWCACHE;
   input  [3:0]     SAXIGP1AWQOS;
   input  [3:0]     SAXIGP2ARCACHE;
   input  [3:0]     SAXIGP2ARQOS;
   input  [3:0]     SAXIGP2AWCACHE;
   input  [3:0]     SAXIGP2AWQOS;
   input  [3:0]     SAXIGP3ARCACHE;
   input  [3:0]     SAXIGP3ARQOS;
   input  [3:0]     SAXIGP3AWCACHE;
   input  [3:0]     SAXIGP3AWQOS;
   input  [3:0]     SAXIGP4ARCACHE;
   input  [3:0]     SAXIGP4ARQOS;
   input  [3:0]     SAXIGP4AWCACHE;
   input  [3:0]     SAXIGP4AWQOS;
   input  [3:0]     SAXIGP5ARCACHE;
   input  [3:0]     SAXIGP5ARQOS;
   input  [3:0]     SAXIGP5AWCACHE;
   input  [3:0]     SAXIGP5AWQOS;
   input  [3:0]     SAXIGP6ARCACHE;
   input  [3:0]     SAXIGP6ARQOS;
   input  [3:0]     SAXIGP6AWCACHE;
   input  [3:0]     SAXIGP6AWQOS;
   input  [43:0]    SACEFPDARADDR;
   input  [43:0]    SACEFPDAWADDR;
   input  [39:0]    SAXIGP0ARADDR;
   input  [39:0]    SAXIGP0AWADDR;
   input  [39:0]    SAXIGP1ARADDR;
   input  [39:0]    SAXIGP1AWADDR;
   input  [39:0]    SAXIGP2ARADDR;
   input  [39:0]    SAXIGP2AWADDR;
   input  [39:0]    SAXIGP3ARADDR;
   input  [39:0]    SAXIGP3AWADDR;
   input  [39:0]    SAXIGP4ARADDR;
   input  [39:0]    SAXIGP4AWADDR;
   input  [39:0]    SAXIGP5ARADDR;
   input  [39:0]    SAXIGP5AWADDR;
   input  [39:0]    SAXIGP6ARADDR;
   input  [39:0]    SAXIGP6AWADDR;
   input  [4:0]     SACEFPDCRRESP;
   input  [4:0]     SAXIACPARID;
   input  [4:0]     SAXIACPAWID;
   input  [59:0]    STMEVENT;
   input  [5:0]     SACEFPDARID;
   input  [5:0]     SACEFPDAWID;
   input  [5:0]     SAXIGP0ARID;
   input  [5:0]     SAXIGP0AWID;
   input  [5:0]     SAXIGP1ARID;
   input  [5:0]     SAXIGP1AWID;
   input  [5:0]     SAXIGP2ARID;
   input  [5:0]     SAXIGP2AWID;
   input  [5:0]     SAXIGP3ARID;
   input  [5:0]     SAXIGP3AWID;
   input  [5:0]     SAXIGP4ARID;
   input  [5:0]     SAXIGP4AWID;
   input  [5:0]     SAXIGP5ARID;
   input  [5:0]     SAXIGP5AWID;
   input  [5:0]     SAXIGP6ARID;
   input  [5:0]     SAXIGP6AWID;
   input  [7:0]     ADMAFCICLK;
   input  [7:0]     DPLIVEGFXALPHAIN;
   input  [7:0]     EMIOENET0GMIIRXD;
   input  [7:0]     EMIOENET0TXRDATA;
   input  [7:0]     EMIOENET1GMIIRXD;
   input  [7:0]     EMIOENET1TXRDATA;
   input  [7:0]     EMIOENET2GMIIRXD;
   input  [7:0]     EMIOENET2TXRDATA;
   input  [7:0]     EMIOENET3GMIIRXD;
   input  [7:0]     EMIOENET3TXRDATA;
   input  [7:0]     EMIOSDIO0DATAIN;
   input  [7:0]     EMIOSDIO1DATAIN;
   input  [7:0]     GDMAFCICLK;
   input  [7:0]     PL2ADMACVLD;
   input  [7:0]     PL2ADMATACK;
   input  [7:0]     PL2GDMACVLD;
   input  [7:0]     PL2GDMATACK;
   input  [7:0]     PLPSIRQ0;
   input  [7:0]     PLPSIRQ1;
   input  [7:0]     SACEFPDARLEN;
   input  [7:0]     SACEFPDAWLEN;
   input  [7:0]     SAXIACPARLEN;
   input  [7:0]     SAXIACPAWLEN;
   input  [7:0]     SAXIGP0ARLEN;
   input  [7:0]     SAXIGP0AWLEN;
   input  [7:0]     SAXIGP1ARLEN;
   input  [7:0]     SAXIGP1AWLEN;
   input  [7:0]     SAXIGP2ARLEN;
   input  [7:0]     SAXIGP2AWLEN;
   input  [7:0]     SAXIGP3ARLEN;
   input  [7:0]     SAXIGP3AWLEN;
   input  [7:0]     SAXIGP4ARLEN;
   input  [7:0]     SAXIGP4AWLEN;
   input  [7:0]     SAXIGP5ARLEN;
   input  [7:0]     SAXIGP5AWLEN;
   input  [7:0]     SAXIGP6ARLEN;
   input  [7:0]     SAXIGP6AWLEN;
   input  [95:0]    EMIOGPIOI;
   output           DPAUDIOREFCLK;
   output           DPAUXDATAOEN;
   output           DPAUXDATAOUT;
   output           DPLIVEVIDEODEOUT;
   output           DPMAXISMIXEDAUDIOTID;
   output           DPMAXISMIXEDAUDIOTVALID;
   output           DPSAXISAUDIOTREADY;
   output           DPVIDEOOUTHSYNC;
   output           DPVIDEOOUTVSYNC;
   output           DPVIDEOREFCLK;
   output           EMIOCAN0PHYTX;
   output           EMIOCAN1PHYTX;
   output           EMIOENET0DMATXENDTOG;
   output           EMIOENET0GMIITXEN;
   output           EMIOENET0GMIITXER;
   output           EMIOENET0MDIOMDC;
   output           EMIOENET0MDIOO;
   output           EMIOENET0MDIOTN;
   output           EMIOENET0RXWEOP;
   output           EMIOENET0RXWERR;
   output           EMIOENET0RXWFLUSH;
   output           EMIOENET0RXWSOP;
   output           EMIOENET0RXWWR;
   output           EMIOENET0TXRRD;
   output           EMIOENET1DMATXENDTOG;
   output           EMIOENET1GMIITXEN;
   output           EMIOENET1GMIITXER;
   output           EMIOENET1MDIOMDC;
   output           EMIOENET1MDIOO;
   output           EMIOENET1MDIOTN;
   output           EMIOENET1RXWEOP;
   output           EMIOENET1RXWERR;
   output           EMIOENET1RXWFLUSH;
   output           EMIOENET1RXWSOP;
   output           EMIOENET1RXWWR;
   output           EMIOENET1TXRRD;
   output           EMIOENET2DMATXENDTOG;
   output           EMIOENET2GMIITXEN;
   output           EMIOENET2GMIITXER;
   output           EMIOENET2MDIOMDC;
   output           EMIOENET2MDIOO;
   output           EMIOENET2MDIOTN;
   output           EMIOENET2RXWEOP;
   output           EMIOENET2RXWERR;
   output           EMIOENET2RXWFLUSH;
   output           EMIOENET2RXWSOP;
   output           EMIOENET2RXWWR;
   output           EMIOENET2TXRRD;
   output           EMIOENET3DMATXENDTOG;
   output           EMIOENET3GMIITXEN;
   output           EMIOENET3GMIITXER;
   output           EMIOENET3MDIOMDC;
   output           EMIOENET3MDIOO;
   output           EMIOENET3MDIOTN;
   output           EMIOENET3RXWEOP;
   output           EMIOENET3RXWERR;
   output           EMIOENET3RXWFLUSH;
   output           EMIOENET3RXWSOP;
   output           EMIOENET3RXWWR;
   output           EMIOENET3TXRRD;
   output           EMIOGEM0DELAYREQRX;
   output           EMIOGEM0DELAYREQTX;
   output           EMIOGEM0PDELAYREQRX;
   output           EMIOGEM0PDELAYREQTX;
   output           EMIOGEM0PDELAYRESPRX;
   output           EMIOGEM0PDELAYRESPTX;
   output           EMIOGEM0RXSOF;
   output           EMIOGEM0SYNCFRAMERX;
   output           EMIOGEM0SYNCFRAMETX;
   output           EMIOGEM0TSUTIMERCMPVAL;
   output           EMIOGEM0TXRFIXEDLAT;
   output           EMIOGEM0TXSOF;
   output           EMIOGEM1DELAYREQRX;
   output           EMIOGEM1DELAYREQTX;
   output           EMIOGEM1PDELAYREQRX;
   output           EMIOGEM1PDELAYREQTX;
   output           EMIOGEM1PDELAYRESPRX;
   output           EMIOGEM1PDELAYRESPTX;
   output           EMIOGEM1RXSOF;
   output           EMIOGEM1SYNCFRAMERX;
   output           EMIOGEM1SYNCFRAMETX;
   output           EMIOGEM1TSUTIMERCMPVAL;
   output           EMIOGEM1TXRFIXEDLAT;
   output           EMIOGEM1TXSOF;
   output           EMIOGEM2DELAYREQRX;
   output           EMIOGEM2DELAYREQTX;
   output           EMIOGEM2PDELAYREQRX;
   output           EMIOGEM2PDELAYREQTX;
   output           EMIOGEM2PDELAYRESPRX;
   output           EMIOGEM2PDELAYRESPTX;
   output           EMIOGEM2RXSOF;
   output           EMIOGEM2SYNCFRAMERX;
   output           EMIOGEM2SYNCFRAMETX;
   output           EMIOGEM2TSUTIMERCMPVAL;
   output           EMIOGEM2TXRFIXEDLAT;
   output           EMIOGEM2TXSOF;
   output           EMIOGEM3DELAYREQRX;
   output           EMIOGEM3DELAYREQTX;
   output           EMIOGEM3PDELAYREQRX;
   output           EMIOGEM3PDELAYREQTX;
   output           EMIOGEM3PDELAYRESPRX;
   output           EMIOGEM3PDELAYRESPTX;
   output           EMIOGEM3RXSOF;
   output           EMIOGEM3SYNCFRAMERX;
   output           EMIOGEM3SYNCFRAMETX;
   output           EMIOGEM3TSUTIMERCMPVAL;
   output           EMIOGEM3TXRFIXEDLAT;
   output           EMIOGEM3TXSOF;
   output           EMIOI2C0SCLO;
   output           EMIOI2C0SCLTN;
   output           EMIOI2C0SDAO;
   output           EMIOI2C0SDATN;
   output           EMIOI2C1SCLO;
   output           EMIOI2C1SCLTN;
   output           EMIOI2C1SDAO;
   output           EMIOI2C1SDATN;
   output           EMIOSDIO0BUSPOWER;
   output           EMIOSDIO0CLKOUT;
   output           EMIOSDIO0CMDENA;
   output           EMIOSDIO0CMDOUT;
   output           EMIOSDIO0LEDCONTROL;
   output           EMIOSDIO1BUSPOWER;
   output           EMIOSDIO1CLKOUT;
   output           EMIOSDIO1CMDENA;
   output           EMIOSDIO1CMDOUT;
   output           EMIOSDIO1LEDCONTROL;
   output           EMIOSPI0MO;
   output           EMIOSPI0MOTN;
   output           EMIOSPI0SCLKO;
   output           EMIOSPI0SCLKTN;
   output           EMIOSPI0SO;
   output           EMIOSPI0SSNTN;
   output           EMIOSPI0STN;
   output           EMIOSPI1MO;
   output           EMIOSPI1MOTN;
   output           EMIOSPI1SCLKO;
   output           EMIOSPI1SCLKTN;
   output           EMIOSPI1SO;
   output           EMIOSPI1SSNTN;
   output           EMIOSPI1STN;
   output           EMIOU2DSPORTVBUSCTRLUSB30;
   output           EMIOU2DSPORTVBUSCTRLUSB31;
   output           EMIOU3DSPORTVBUSCTRLUSB30;
   output           EMIOU3DSPORTVBUSCTRLUSB31;
   output           EMIOUART0DTRN;
   output           EMIOUART0RTSN;
   output           EMIOUART0TX;
   output           EMIOUART1DTRN;
   output           EMIOUART1RTSN;
   output           EMIOUART1TX;
   output           EMIOWDT0RSTO;
   output           EMIOWDT1RSTO;
   output           FMIOGEM0FIFORXCLKTOPLBUFG;
   output           FMIOGEM0FIFOTXCLKTOPLBUFG;
   output           FMIOGEM1FIFORXCLKTOPLBUFG;
   output           FMIOGEM1FIFOTXCLKTOPLBUFG;
   output           FMIOGEM2FIFORXCLKTOPLBUFG;
   output           FMIOGEM2FIFOTXCLKTOPLBUFG;
   output           FMIOGEM3FIFORXCLKTOPLBUFG;
   output           FMIOGEM3FIFOTXCLKTOPLBUFG;
   output           FMIOGEMTSUCLKTOPLBUFG;
   output           MAXIGP0ARLOCK;
   output           MAXIGP0ARVALID;
   output           MAXIGP0AWLOCK;
   output           MAXIGP0AWVALID;
   output           MAXIGP0BREADY;
   output           MAXIGP0RREADY;
   output           MAXIGP0WLAST;
   output           MAXIGP0WVALID;
   output           MAXIGP1ARLOCK;
   output           MAXIGP1ARVALID;
   output           MAXIGP1AWLOCK;
   output           MAXIGP1AWVALID;
   output           MAXIGP1BREADY;
   output           MAXIGP1RREADY;
   output           MAXIGP1WLAST;
   output           MAXIGP1WVALID;
   output           MAXIGP2ARLOCK;
   output           MAXIGP2ARVALID;
   output           MAXIGP2AWLOCK;
   output           MAXIGP2AWVALID;
   output           MAXIGP2BREADY;
   output           MAXIGP2RREADY;
   output           MAXIGP2WLAST;
   output           MAXIGP2WVALID;
   output           OSCRTCCLK;
   output           PMUAIBAFIFMFPDREQ;
   output           PMUAIBAFIFMLPDREQ;
   output           PSPLEVENTO;
   output           PSPLTRACECTL;
   output           PSS_ALTO_CORE_PAD_MGTTXN0OUT;
   output           PSS_ALTO_CORE_PAD_MGTTXN1OUT;
   output           PSS_ALTO_CORE_PAD_MGTTXN2OUT;
   output           PSS_ALTO_CORE_PAD_MGTTXN3OUT;
   output           PSS_ALTO_CORE_PAD_MGTTXP0OUT;
   output           PSS_ALTO_CORE_PAD_MGTTXP1OUT;
   output           PSS_ALTO_CORE_PAD_MGTTXP2OUT;
   output           PSS_ALTO_CORE_PAD_MGTTXP3OUT;
   output           PSS_ALTO_CORE_PAD_PADO;
   output           RPUEVENTO0;
   output           RPUEVENTO1;
   output           SACEFPDACVALID;
   output           SACEFPDARREADY;
   output           SACEFPDAWREADY;
   output           SACEFPDBUSER;
   output           SACEFPDBVALID;
   output           SACEFPDCDREADY;
   output           SACEFPDCRREADY;
   output           SACEFPDRLAST;
   output           SACEFPDRUSER;
   output           SACEFPDRVALID;
   output           SACEFPDWREADY;
   output           SAXIACPARREADY;
   output           SAXIACPAWREADY;
   output           SAXIACPBVALID;
   output           SAXIACPRLAST;
   output           SAXIACPRVALID;
   output           SAXIACPWREADY;
   output           SAXIGP0ARREADY;
   output           SAXIGP0AWREADY;
   output           SAXIGP0BVALID;
   output           SAXIGP0RLAST;
   output           SAXIGP0RVALID;
   output           SAXIGP0WREADY;
   output           SAXIGP1ARREADY;
   output           SAXIGP1AWREADY;
   output           SAXIGP1BVALID;
   output           SAXIGP1RLAST;
   output           SAXIGP1RVALID;
   output           SAXIGP1WREADY;
   output           SAXIGP2ARREADY;
   output           SAXIGP2AWREADY;
   output           SAXIGP2BVALID;
   output           SAXIGP2RLAST;
   output           SAXIGP2RVALID;
   output           SAXIGP2WREADY;
   output           SAXIGP3ARREADY;
   output           SAXIGP3AWREADY;
   output           SAXIGP3BVALID;
   output           SAXIGP3RLAST;
   output           SAXIGP3RVALID;
   output           SAXIGP3WREADY;
   output           SAXIGP4ARREADY;
   output           SAXIGP4AWREADY;
   output           SAXIGP4BVALID;
   output           SAXIGP4RLAST;
   output           SAXIGP4RVALID;
   output           SAXIGP4WREADY;
   output           SAXIGP5ARREADY;
   output           SAXIGP5AWREADY;
   output           SAXIGP5BVALID;
   output           SAXIGP5RLAST;
   output           SAXIGP5RVALID;
   output           SAXIGP5WREADY;
   output           SAXIGP6ARREADY;
   output           SAXIGP6AWREADY;
   output           SAXIGP6BVALID;
   output           SAXIGP6RLAST;
   output           SAXIGP6RVALID;
   output           SAXIGP6WREADY;
   output  [127:0]  MAXIGP0WDATA;
   output  [127:0]  MAXIGP1WDATA;
   output  [127:0]  MAXIGP2WDATA;
   output  [127:0]  SACEFPDRDATA;
   output  [127:0]  SAXIACPRDATA;
   output  [127:0]  SAXIGP0RDATA;
   output  [127:0]  SAXIGP1RDATA;
   output  [127:0]  SAXIGP2RDATA;
   output  [127:0]  SAXIGP3RDATA;
   output  [127:0]  SAXIGP4RDATA;
   output  [127:0]  SAXIGP5RDATA;
   output  [127:0]  SAXIGP6RDATA;
   output  [15:0]   MAXIGP0ARID;
   output  [15:0]   MAXIGP0ARUSER;
   output  [15:0]   MAXIGP0AWID;
   output  [15:0]   MAXIGP0AWUSER;
   output  [15:0]   MAXIGP0WSTRB;
   output  [15:0]   MAXIGP1ARID;
   output  [15:0]   MAXIGP1ARUSER;
   output  [15:0]   MAXIGP1AWID;
   output  [15:0]   MAXIGP1AWUSER;
   output  [15:0]   MAXIGP1WSTRB;
   output  [15:0]   MAXIGP2ARID;
   output  [15:0]   MAXIGP2ARUSER;
   output  [15:0]   MAXIGP2AWID;
   output  [15:0]   MAXIGP2AWUSER;
   output  [15:0]   MAXIGP2WSTRB;
   output  [1:0]    EMIOENET0DMABUSWIDTH;
   output  [1:0]    EMIOENET1DMABUSWIDTH;
   output  [1:0]    EMIOENET2DMABUSWIDTH;
   output  [1:0]    EMIOENET3DMABUSWIDTH;
   output  [1:0]    MAXIGP0ARBURST;
   output  [1:0]    MAXIGP0AWBURST;
   output  [1:0]    MAXIGP1ARBURST;
   output  [1:0]    MAXIGP1AWBURST;
   output  [1:0]    MAXIGP2ARBURST;
   output  [1:0]    MAXIGP2AWBURST;
   output  [1:0]    SACEFPDBRESP;
   output  [1:0]    SAXIACPBRESP;
   output  [1:0]    SAXIACPRRESP;
   output  [1:0]    SAXIGP0BRESP;
   output  [1:0]    SAXIGP0RRESP;
   output  [1:0]    SAXIGP1BRESP;
   output  [1:0]    SAXIGP1RRESP;
   output  [1:0]    SAXIGP2BRESP;
   output  [1:0]    SAXIGP2RRESP;
   output  [1:0]    SAXIGP3BRESP;
   output  [1:0]    SAXIGP3RRESP;
   output  [1:0]    SAXIGP4BRESP;
   output  [1:0]    SAXIGP4RRESP;
   output  [1:0]    SAXIGP5BRESP;
   output  [1:0]    SAXIGP5RRESP;
   output  [1:0]    SAXIGP6BRESP;
   output  [1:0]    SAXIGP6RRESP;
   output  [2:0]    EMIOENET0SPEEDMODE;
   output  [2:0]    EMIOENET1SPEEDMODE;
   output  [2:0]    EMIOENET2SPEEDMODE;
   output  [2:0]    EMIOENET3SPEEDMODE;
   output  [2:0]    EMIOSDIO0BUSVOLT;
   output  [2:0]    EMIOSDIO1BUSVOLT;
   output  [2:0]    EMIOSPI0SSON;
   output  [2:0]    EMIOSPI1SSON;
   output  [2:0]    EMIOTTC0WAVEO;
   output  [2:0]    EMIOTTC1WAVEO;
   output  [2:0]    EMIOTTC2WAVEO;
   output  [2:0]    EMIOTTC3WAVEO;
   output  [2:0]    MAXIGP0ARPROT;
   output  [2:0]    MAXIGP0ARSIZE;
   output  [2:0]    MAXIGP0AWPROT;
   output  [2:0]    MAXIGP0AWSIZE;
   output  [2:0]    MAXIGP1ARPROT;
   output  [2:0]    MAXIGP1ARSIZE;
   output  [2:0]    MAXIGP1AWPROT;
   output  [2:0]    MAXIGP1AWSIZE;
   output  [2:0]    MAXIGP2ARPROT;
   output  [2:0]    MAXIGP2ARSIZE;
   output  [2:0]    MAXIGP2AWPROT;
   output  [2:0]    MAXIGP2AWSIZE;
   output  [2:0]    SACEFPDACPROT;
   output  [31:0]   DPMAXISMIXEDAUDIOTDATA;
   output  [31:0]   FTMGPO;
   output  [31:0]   PMUPLGPO;
   output  [31:0]   PSPLTRACEDATA;
   output  [35:0]   DPVIDEOOUTPIXEL1;
   output  [39:0]   MAXIGP0ARADDR;
   output  [39:0]   MAXIGP0AWADDR;
   output  [39:0]   MAXIGP1ARADDR;
   output  [39:0]   MAXIGP1AWADDR;
   output  [39:0]   MAXIGP2ARADDR;
   output  [39:0]   MAXIGP2AWADDR;
   output  [3:0]    EMIOENET0TXRSTATUS;
   output  [3:0]    EMIOENET1TXRSTATUS;
   output  [3:0]    EMIOENET2TXRSTATUS;
   output  [3:0]    EMIOENET3TXRSTATUS;
   output  [3:0]    MAXIGP0ARCACHE;
   output  [3:0]    MAXIGP0ARQOS;
   output  [3:0]    MAXIGP0AWCACHE;
   output  [3:0]    MAXIGP0AWQOS;
   output  [3:0]    MAXIGP1ARCACHE;
   output  [3:0]    MAXIGP1ARQOS;
   output  [3:0]    MAXIGP1AWCACHE;
   output  [3:0]    MAXIGP1AWQOS;
   output  [3:0]    MAXIGP2ARCACHE;
   output  [3:0]    MAXIGP2ARQOS;
   output  [3:0]    MAXIGP2AWCACHE;
   output  [3:0]    MAXIGP2AWQOS;
   output  [3:0]    PLCLK;
   output           PL_RESETN0;
   output           PL_RESETN1;
   output           PL_RESETN2;
   output           PL_RESETN3;
   output  [3:0]    PSPLSTANDBYWFE;
   output  [3:0]    PSPLSTANDBYWFI;
   output  [3:0]    PSPLTRIGACK;
   output  [3:0]    PSPLTRIGGER;
   output  [3:0]    SACEFPDACSNOOP;
   output  [3:0]    SACEFPDRRESP;
   output  [3:0]    SAXIGP0RACOUNT;
   output  [3:0]    SAXIGP0WACOUNT;
   output  [3:0]    SAXIGP1RACOUNT;
   output  [3:0]    SAXIGP1WACOUNT;
   output  [3:0]    SAXIGP2RACOUNT;
   output  [3:0]    SAXIGP2WACOUNT;
   output  [3:0]    SAXIGP3RACOUNT;
   output  [3:0]    SAXIGP3WACOUNT;
   output  [3:0]    SAXIGP4RACOUNT;
   output  [3:0]    SAXIGP4WACOUNT;
   output  [3:0]    SAXIGP5RACOUNT;
   output  [3:0]    SAXIGP5WACOUNT;
   output  [3:0]    SAXIGP6RACOUNT;
   output  [3:0]    SAXIGP6WACOUNT;
   output  [43:0]   SACEFPDACADDR;
   output  [44:0]   EMIOENET0RXWSTATUS;
   output  [44:0]   EMIOENET1RXWSTATUS;
   output  [44:0]   EMIOENET2RXWSTATUS;
   output  [44:0]   EMIOENET3RXWSTATUS;
   output  [46:0]   PMUERRORTOPL;
   output  [4:0]    SAXIACPBID;
   output  [4:0]    SAXIACPRID;
   output  [5:0]    SACEFPDBID;
   output  [5:0]    SACEFPDRID;
   output  [5:0]    SAXIGP0BID;
   output  [5:0]    SAXIGP0RID;
   output  [5:0]    SAXIGP1BID;
   output  [5:0]    SAXIGP1RID;
   output  [5:0]    SAXIGP2BID;
   output  [5:0]    SAXIGP2RID;
   output  [5:0]    SAXIGP3BID;
   output  [5:0]    SAXIGP3RID;
   output  [5:0]    SAXIGP4BID;
   output  [5:0]    SAXIGP4RID;
   output  [5:0]    SAXIGP5BID;
   output  [5:0]    SAXIGP5RID;
   output  [5:0]    SAXIGP6BID;
   output  [5:0]    SAXIGP6RID;
   output  [63:0]   PSPLIRQFPD;
   output  [7:0]    ADMA2PLCACK;
   output  [7:0]    ADMA2PLTVLD;
   output  [7:0]    EMIOENET0GMIITXD;
   output  [7:0]    EMIOENET0RXWDATA;
   output  [7:0]    EMIOENET1GMIITXD;
   output  [7:0]    EMIOENET1RXWDATA;
   output  [7:0]    EMIOENET2GMIITXD;
   output  [7:0]    EMIOENET2RXWDATA;
   output  [7:0]    EMIOENET3GMIITXD;
   output  [7:0]    EMIOENET3RXWDATA;
   output  [7:0]    EMIOSDIO0DATAENA;
   output  [7:0]    EMIOSDIO0DATAOUT;
   output  [7:0]    EMIOSDIO1DATAENA;
   output  [7:0]    EMIOSDIO1DATAOUT;
   output  [7:0]    GDMA2PLCACK;
   output  [7:0]    GDMA2PLTVLD;
   output  [7:0]    MAXIGP0ARLEN;
   output  [7:0]    MAXIGP0AWLEN;
   output  [7:0]    MAXIGP1ARLEN;
   output  [7:0]    MAXIGP1AWLEN;
   output  [7:0]    MAXIGP2ARLEN;
   output  [7:0]    MAXIGP2AWLEN;
   output  [7:0]    SAXIGP0RCOUNT;
   output  [7:0]    SAXIGP0WCOUNT;
   output  [7:0]    SAXIGP1RCOUNT;
   output  [7:0]    SAXIGP1WCOUNT;
   output  [7:0]    SAXIGP2RCOUNT;
   output  [7:0]    SAXIGP2WCOUNT;
   output  [7:0]    SAXIGP3RCOUNT;
   output  [7:0]    SAXIGP3WCOUNT;
   output  [7:0]    SAXIGP4RCOUNT;
   output  [7:0]    SAXIGP4WCOUNT;
   output  [7:0]    SAXIGP5RCOUNT;
   output  [7:0]    SAXIGP5WCOUNT;
   output  [7:0]    SAXIGP6RCOUNT;
   output  [7:0]    SAXIGP6WCOUNT;
   output  [93:0]   EMIOENET0GEMTSUTIMERCNT;
   output  [95:0]   EMIOGPIOO;
   output  [95:0]   EMIOGPIOTN;
   output  [99:0]   PSPLIRQLPD;

  /* Internal wires/nets used for connectivity */
   wire net_sw_clk;
   wire net_m_axi_gp0_rstn;
   wire net_m_axi_gp1_rstn;
   wire net_m_axi_gp2_rstn;
   wire net_s_axi_gp0_rstn;
   wire net_s_axi_gp1_rstn;
   wire net_s_axi_gp2_rstn;
   wire net_s_axi_gp3_rstn;
   wire net_s_axi_gp4_rstn;
   wire net_s_axi_gp5_rstn;
   wire net_s_axi_gp6_rstn;
   wire net_s_axi_acp_rstn;
   wire net_s_axi_ace_rstn;
   wire net_rstn;
   wire net_fclk_reset3_n;
   wire net_fclk_reset2_n;
   wire net_fclk_reset1_n;
   wire net_fclk_reset0_n;

   wire  [axi_qos_width-1:0]      net_wr_qos_acp;
   wire                           ddr_wr_ack_acp;
   wire                           reg_wr_ack_acp;
   wire                           ocm_wr_ack_acp;
   wire [max_burst_bits-1:0]      net_wr_data_acp;
   wire [max_burst_bytes-1:0]     net_wr_strb_acp;
   wire [addr_width-1:0]          net_wr_addr_acp;
   wire [max_burst_bytes_width:0] net_wr_bytes_acp;
   wire                           ddr_wr_dv_acp;
   wire                           reg_wr_dv_acp;
   wire                           ocm_wr_dv_acp;
   wire  [axi_qos_width-1:0]      net_rd_qos_acp;
   wire                           ddr_rd_req_acp;
   wire                           reg_rd_req_acp;
   wire                           ocm_rd_req_acp;
   wire [addr_width-1:0]          net_rd_addr_acp;
   wire [max_burst_bytes_width:0] net_rd_bytes_acp;
   wire [max_burst_bits-1:0]      ddr_rd_data_acp;
   wire [max_burst_bits-1:0]      reg_rd_data_acp;
   wire [max_burst_bits-1:0]      ocm_rd_data_acp;
   wire                           ddr_rd_dv_acp;
   wire                           reg_rd_dv_acp;
   wire                           ocm_rd_dv_acp;

   wire  [axi_qos_width-1:0]      net_wr_qos_ace;
   wire                           ddr_wr_ack_ace;
   wire                           reg_wr_ack_ace;
   wire                           ocm_wr_ack_ace;
   wire [max_burst_bits-1:0]      net_wr_data_ace;
   wire [max_burst_bytes-1:0]     net_wr_strb_ace;
   wire [addr_width-1:0]          net_wr_addr_ace;
   wire [max_burst_bytes_width:0] net_wr_bytes_ace;
   wire                           ddr_wr_dv_ace;
   wire                           reg_wr_dv_ace;
   wire                           ocm_wr_dv_ace;
   wire  [axi_qos_width-1:0]      net_rd_qos_ace;
   wire                           ddr_rd_req_ace;
   wire                           reg_rd_req_ace;
   wire                           ocm_rd_req_ace;
   wire [addr_width-1:0]          net_rd_addr_ace;
   wire [max_burst_bytes_width:0] net_rd_bytes_ace;
   wire [max_burst_bits-1:0]      ddr_rd_data_ace;
   wire [max_burst_bits-1:0]      reg_rd_data_ace;
   wire [max_burst_bits-1:0]      ocm_rd_data_ace;
   wire                           ddr_rd_dv_ace;
   wire                           reg_rd_dv_ace;
   wire                           ocm_rd_dv_ace;

   wire  [axi_qos_width-1:0]      net_wr_qos_gp0;
   wire                           ddr_wr_ack_gp0;
   wire                           reg_wr_ack_gp0;
   wire                           ocm_wr_ack_gp0;
   wire [max_burst_bits-1:0]      net_wr_data_gp0;
   wire [max_burst_bytes-1:0]     net_wr_strb_gp0;
   wire [addr_width-1:0]          net_wr_addr_gp0;
   wire [max_burst_bytes_width:0] net_wr_bytes_gp0;
   wire                           ddr_wr_dv_gp0;
   wire                           reg_wr_dv_gp0;
   wire                           ocm_wr_dv_gp0;
   wire  [axi_qos_width-1:0]      net_rd_qos_gp0;
   wire                           ddr_rd_req_gp0;
   wire                           reg_rd_req_gp0;
   wire                           ocm_rd_req_gp0;
   wire [addr_width-1:0]          net_rd_addr_gp0;
   wire [max_burst_bytes_width:0] net_rd_bytes_gp0;
   wire [max_burst_bits-1:0]      ddr_rd_data_gp0;
   wire [max_burst_bits-1:0]      reg_rd_data_gp0;
   wire [max_burst_bits-1:0]      ocm_rd_data_gp0;
   wire                           ddr_rd_dv_gp0;
   wire                           reg_rd_dv_gp0;
   wire                           ocm_rd_dv_gp0;

   wire  [axi_qos_width-1:0]      net_wr_qos_gp1;
   wire                           ddr_wr_ack_gp1;
   wire                           reg_wr_ack_gp1;
   wire                           ocm_wr_ack_gp1;
   wire [max_burst_bits-1:0]      net_wr_data_gp1;
   wire [max_burst_bytes-1:0]     net_wr_strb_gp1;
   wire [addr_width-1:0]          net_wr_addr_gp1;
   wire [max_burst_bytes_width:0] net_wr_bytes_gp1;
   wire                           ddr_wr_dv_gp1;
   wire                           reg_wr_dv_gp1;
   wire                           ocm_wr_dv_gp1;
   wire  [axi_qos_width-1:0]      net_rd_qos_gp1;
   wire                           ddr_rd_req_gp1;
   wire                           reg_rd_req_gp1;
   wire                           ocm_rd_req_gp1;
   wire [addr_width-1:0]          net_rd_addr_gp1;
   wire [max_burst_bytes_width:0] net_rd_bytes_gp1;
   wire [max_burst_bits-1:0]      ddr_rd_data_gp1;
   wire [max_burst_bits-1:0]      reg_rd_data_gp1;
   wire [max_burst_bits-1:0]      ocm_rd_data_gp1;
   wire                           ddr_rd_dv_gp1;
   wire                           reg_rd_dv_gp1;
   wire                           ocm_rd_dv_gp1;

   wire  [axi_qos_width-1:0]      net_wr_qos_gp2;
   wire                           ddr_wr_ack_gp2;
   wire                           reg_wr_ack_gp2;
   wire                           ocm_wr_ack_gp2;
   wire [max_burst_bits-1:0]      net_wr_data_gp2;
   wire [max_burst_bytes-1:0]     net_wr_strb_gp2;
   wire [addr_width-1:0]          net_wr_addr_gp2;
   wire [max_burst_bytes_width:0] net_wr_bytes_gp2;
   wire                           ddr_wr_dv_gp2;
   wire                           reg_wr_dv_gp2;
   wire                           ocm_wr_dv_gp2;
   wire  [axi_qos_width-1:0]      net_rd_qos_gp2;
   wire                           ddr_rd_req_gp2;
   wire                           reg_rd_req_gp2;
   wire                           ocm_rd_req_gp2;
   wire [addr_width-1:0]          net_rd_addr_gp2;
   wire [max_burst_bytes_width:0] net_rd_bytes_gp2;
   wire [max_burst_bits-1:0]      ddr_rd_data_gp2;
   wire [max_burst_bits-1:0]      reg_rd_data_gp2;
   wire [max_burst_bits-1:0]      ocm_rd_data_gp2;
   wire                           ddr_rd_dv_gp2;
   wire                           reg_rd_dv_gp2;
   wire                           ocm_rd_dv_gp2;

   wire  [axi_qos_width-1:0]      net_wr_qos_gp3;
   wire                           ddr_wr_ack_gp3;
   wire                           reg_wr_ack_gp3;
   wire                           ocm_wr_ack_gp3;
   wire [max_burst_bits-1:0]      net_wr_data_gp3;
   wire [max_burst_bytes-1:0]     net_wr_strb_gp3;
   wire [addr_width-1:0]          net_wr_addr_gp3;
   wire [max_burst_bytes_width:0] net_wr_bytes_gp3;
   wire                           ddr_wr_dv_gp3;
   wire                           reg_wr_dv_gp3;
   wire                           ocm_wr_dv_gp3;
   wire  [axi_qos_width-1:0]      net_rd_qos_gp3;
   wire                           ddr_rd_req_gp3;
   wire                           reg_rd_req_gp3;
   wire                           ocm_rd_req_gp3;
   wire [addr_width-1:0]          net_rd_addr_gp3;
   wire [max_burst_bytes_width:0] net_rd_bytes_gp3;
   wire [max_burst_bits-1:0]      ddr_rd_data_gp3;
   wire [max_burst_bits-1:0]      reg_rd_data_gp3;
   wire [max_burst_bits-1:0]      ocm_rd_data_gp3;
   wire                           ddr_rd_dv_gp3;
   wire                           reg_rd_dv_gp3;
   wire                           ocm_rd_dv_gp3;

   wire  [axi_qos_width-1:0]      net_wr_qos_gp4;
   wire                           ddr_wr_ack_gp4;
   wire                           reg_wr_ack_gp4;
   wire                           ocm_wr_ack_gp4;
   wire [max_burst_bits-1:0]      net_wr_data_gp4;
   wire [max_burst_bytes-1:0]     net_wr_strb_gp4;
   wire [addr_width-1:0]          net_wr_addr_gp4;
   wire [max_burst_bytes_width:0] net_wr_bytes_gp4;
   wire                           ddr_wr_dv_gp4;
   wire                           reg_wr_dv_gp4;
   wire                           ocm_wr_dv_gp4;
   wire  [axi_qos_width-1:0]      net_rd_qos_gp4;
   wire                           ddr_rd_req_gp4;
   wire                           reg_rd_req_gp4;
   wire                           ocm_rd_req_gp4;
   wire [addr_width-1:0]          net_rd_addr_gp4;
   wire [max_burst_bytes_width:0] net_rd_bytes_gp4;
   wire [max_burst_bits-1:0]      ddr_rd_data_gp4;
   wire [max_burst_bits-1:0]      reg_rd_data_gp4;
   wire [max_burst_bits-1:0]      ocm_rd_data_gp4;
   wire                           ddr_rd_dv_gp4;
   wire                           reg_rd_dv_gp4;
   wire                           ocm_rd_dv_gp4;

   wire  [axi_qos_width-1:0]      net_wr_qos_gp5;
   wire                           ddr_wr_ack_gp5;
   wire                           reg_wr_ack_gp5;
   wire                           ocm_wr_ack_gp5;
   wire [max_burst_bits-1:0]      net_wr_data_gp5;
   wire [max_burst_bytes-1:0]     net_wr_strb_gp5;
   wire [addr_width-1:0]          net_wr_addr_gp5;
   wire [max_burst_bytes_width:0] net_wr_bytes_gp5;
   wire                           ddr_wr_dv_gp5;
   wire                           reg_wr_dv_gp5;
   wire                           ocm_wr_dv_gp5;
   wire  [axi_qos_width-1:0]      net_rd_qos_gp5;
   wire                           ddr_rd_req_gp5;
   wire                           reg_rd_req_gp5;
   wire                           ocm_rd_req_gp5;
   wire [addr_width-1:0]          net_rd_addr_gp5;
   wire [max_burst_bytes_width:0] net_rd_bytes_gp5;
   wire [max_burst_bits-1:0]      ddr_rd_data_gp5;
   wire [max_burst_bits-1:0]      reg_rd_data_gp5;
   wire [max_burst_bits-1:0]      ocm_rd_data_gp5;
   wire                           ddr_rd_dv_gp5;
   wire                           reg_rd_dv_gp5;
   wire                           ocm_rd_dv_gp5;

   wire  [axi_qos_width-1:0]      net_wr_qos_gp6;
   wire                           ddr_wr_ack_gp6;
   wire                           reg_wr_ack_gp6;
   wire                           ocm_wr_ack_gp6;
   wire [max_burst_bits-1:0]      net_wr_data_gp6;
   wire [max_burst_bytes-1:0]     net_wr_strb_gp6;
   wire [addr_width-1:0]          net_wr_addr_gp6;
   wire [max_burst_bytes_width:0] net_wr_bytes_gp6;
   wire                           ddr_wr_dv_gp6;
   wire                           reg_wr_dv_gp6;
   wire                           ocm_wr_dv_gp6;
   wire  [axi_qos_width-1:0]      net_rd_qos_gp6;
   wire                           ddr_rd_req_gp6;
   wire                           reg_rd_req_gp6;
   wire                           ocm_rd_req_gp6;
   wire [addr_width-1:0]          net_rd_addr_gp6;
   wire [max_burst_bytes_width:0] net_rd_bytes_gp6;
   wire [max_burst_bits-1:0]      ddr_rd_data_gp6;
   wire [max_burst_bits-1:0]      reg_rd_data_gp6;
   wire [max_burst_bits-1:0]      ocm_rd_data_gp6;
   wire                           ddr_rd_dv_gp6;
   wire                           reg_rd_dv_gp6;
   wire                           ocm_rd_dv_gp6;

   wire   [axi_qos_width-1:0]     net_ddr_wr_qos_port0;
   wire                           net_ddr_wr_ack_port0;
   wire [max_burst_bits-1:0]      net_ddr_wr_data_port0;
   wire [max_burst_bytes-1:0]     net_ddr_wr_strb_port0;
   wire [addr_width-1:0]          net_ddr_wr_addr_port0;
   wire [max_burst_bytes_width:0] net_ddr_wr_bytes_port0;
   wire                           net_ddr_wr_dv_port0;
   wire   [axi_qos_width-1:0]     net_ddr_rd_qos_port0;
   wire                           net_ddr_rd_req_port0;
   wire [addr_width-1:0]          net_ddr_rd_addr_port0;
   wire [max_burst_bytes_width:0] net_ddr_rd_bytes_port0;
   wire [max_burst_bits-1:0]      net_ddr_rd_data_port0;
   wire                           net_ddr_rd_dv_port0;

   wire   [axi_qos_width-1:0]     net_ddr_wr_qos_port1;
   wire                           net_ddr_wr_ack_port1;
   wire [max_burst_bits-1:0]      net_ddr_wr_data_port1;
   wire [max_burst_bytes-1:0]     net_ddr_wr_strb_port1;
   wire [addr_width-1:0]          net_ddr_wr_addr_port1;
   wire [max_burst_bytes_width:0] net_ddr_wr_bytes_port1;
   wire                           net_ddr_wr_dv_port1;
   wire   [axi_qos_width-1:0]     net_ddr_rd_qos_port1;
   wire                           net_ddr_rd_req_port1;
   wire [addr_width-1:0]          net_ddr_rd_addr_port1;
   wire [max_burst_bytes_width:0] net_ddr_rd_bytes_port1;
   wire [max_burst_bits-1:0]      net_ddr_rd_data_port1;
   wire                           net_ddr_rd_dv_port1;

   wire   [axi_qos_width-1:0]     net_ddr_wr_qos_port2;
   wire                           net_ddr_wr_ack_port2;
   wire [max_burst_bits-1:0]      net_ddr_wr_data_port2;
   wire [max_burst_bytes-1:0]     net_ddr_wr_strb_port2;
   wire [addr_width-1:0]          net_ddr_wr_addr_port2;
   wire [max_burst_bytes_width:0] net_ddr_wr_bytes_port2;
   wire                           net_ddr_wr_dv_port2;
   wire   [axi_qos_width-1:0]     net_ddr_rd_qos_port2;
   wire                           net_ddr_rd_req_port2;
   wire [addr_width-1:0]          net_ddr_rd_addr_port2;
   wire [max_burst_bytes_width:0] net_ddr_rd_bytes_port2;
   wire [max_burst_bits-1:0]      net_ddr_rd_data_port2;
   wire                           net_ddr_rd_dv_port2;

   wire   [axi_qos_width-1:0]     net_ddr_wr_qos_port3;
   wire                           net_ddr_wr_ack_port3;
   wire [max_burst_bits-1:0]      net_ddr_wr_data_port3;
   wire [max_burst_bytes-1:0]     net_ddr_wr_strb_port3;
   wire [addr_width-1:0]          net_ddr_wr_addr_port3;
   wire [max_burst_bytes_width:0] net_ddr_wr_bytes_port3;
   wire                           net_ddr_wr_dv_port3;
   wire   [axi_qos_width-1:0]     net_ddr_rd_qos_port3;
   wire                           net_ddr_rd_req_port3;
   wire [addr_width-1:0]          net_ddr_rd_addr_port3;
   wire [max_burst_bytes_width:0] net_ddr_rd_bytes_port3;
   wire [max_burst_bits-1:0]      net_ddr_rd_data_port3;
   wire                           net_ddr_rd_dv_port3;

   wire   [axi_qos_width-1:0]     net_ddr_wr_qos_port4;
   wire                           net_ddr_wr_ack_port4;
   wire [max_burst_bits-1:0]      net_ddr_wr_data_port4;
   wire [max_burst_bytes-1:0]     net_ddr_wr_strb_port4;
   wire [addr_width-1:0]          net_ddr_wr_addr_port4;
   wire [max_burst_bytes_width:0] net_ddr_wr_bytes_port4;
   wire                           net_ddr_wr_dv_port4;
   wire   [axi_qos_width-1:0]     net_ddr_rd_qos_port4;
   wire                           net_ddr_rd_req_port4;
   wire [addr_width-1:0]          net_ddr_rd_addr_port4;
   wire [max_burst_bytes_width:0] net_ddr_rd_bytes_port4;
   wire [max_burst_bits-1:0]      net_ddr_rd_data_port4;
   wire                           net_ddr_rd_dv_port4;

   wire   [axi_qos_width-1:0]     net_ddr_wr_qos_port5;
   wire                           net_ddr_wr_ack_port5;
   wire [max_burst_bits-1:0]      net_ddr_wr_data_port5;
   wire [max_burst_bytes-1:0]     net_ddr_wr_strb_port5;
   wire [addr_width-1:0]          net_ddr_wr_addr_port5;
   wire [max_burst_bytes_width:0] net_ddr_wr_bytes_port5;
   wire                           net_ddr_wr_dv_port5;
   wire   [axi_qos_width-1:0]     net_ddr_rd_qos_port5;
   wire                           net_ddr_rd_req_port5;
   wire [addr_width-1:0]          net_ddr_rd_addr_port5;
   wire [max_burst_bytes_width:0] net_ddr_rd_bytes_port5;
   wire [max_burst_bits-1:0]      net_ddr_rd_data_port5;
   wire                           net_ddr_rd_dv_port5;

   wire   [axi_qos_width-1:0]     net_ocm_wr_qos;
   wire                           net_ocm_wr_ack;
   wire [max_burst_bits-1:0]      net_ocm_wr_data;
   wire [max_burst_bytes-1:0]     net_ocm_wr_strb;
   wire [addr_width-1:0]          net_ocm_wr_addr;
   wire [max_burst_bytes_width:0] net_ocm_wr_bytes;
   wire                           net_ocm_wr_dv;
   wire   [axi_qos_width-1:0]     net_ocm_rd_qos;
   wire                           net_ocm_rd_req;
   wire [addr_width-1:0]          net_ocm_rd_addr;
   wire [max_burst_bytes_width:0] net_ocm_rd_bytes;
   wire [max_burst_bits-1:0]      net_ocm_rd_data;
   wire                           net_ocm_rd_dv;

   wire   [axi_qos_width-1:0]     net_reg_wr_qos;
   wire                           net_reg_wr_ack;
   wire [max_burst_bits-1:0]      net_reg_wr_data;
   wire [max_burst_bytes-1:0]     net_reg_wr_strb;
   wire [addr_width-1:0]          net_reg_wr_addr;
   wire [max_burst_bytes_width:0] net_reg_wr_bytes;
   wire                           net_reg_wr_dv;
   wire   [axi_qos_width-1:0]     net_reg_rd_qos;
   wire                           net_reg_rd_req;
   wire [addr_width-1:0]          net_reg_rd_addr;
   wire [max_burst_bytes_width:0] net_reg_rd_bytes;
   wire [max_burst_bits-1:0]      net_reg_rd_data;
   wire                           net_reg_rd_dv;

  /* Global variables */
  reg DEBUG_INFO = 1;
  reg STOP_ON_ERROR = 1;

  /* local variable acting as semaphore for wait_mem_update and wait_reg_update task */ 
  reg mem_update_key = 1; 
  reg reg_update_key_0 = 1; 
  reg reg_update_key_1 = 1; 
  reg reg_update_key_2 = 1; 

  /* assignments and semantic checks for unused ports */
  `include "zynq_ultra_ps_e_vip_v1_0_6_unused_ports.sv"
  /* Reset Generator */
  zynq_ultra_ps_e_vip_v1_0_6_gen_reset gen_rst(
     .por_rst_n_dummy(PSS_ALTO_CORE_PAD_PORB),
     .sys_rst_n_dummy(PSS_ALTO_CORE_PAD_SRSTB),
     .rst_out_n      (net_rstn),
     .m_axi_gp0_clk  (MAXIGP0ACLK),
     .m_axi_gp1_clk  (MAXIGP1ACLK),
     .m_axi_gp2_clk  (MAXIGP2ACLK),
     .s_axi_gp0_clk  (SAXIGP0WCLK),
     .s_axi_gp1_clk  (SAXIGP1WCLK),
     .s_axi_gp2_clk  (SAXIGP2WCLK),
     .s_axi_gp3_clk  (SAXIGP3WCLK),
     .s_axi_gp4_clk  (SAXIGP4WCLK),
     .s_axi_gp5_clk  (SAXIGP5WCLK),
     .s_axi_gp6_clk  (SAXIGP6WCLK),
     .s_axi_acp_clk  (SAXIACPACLK),
     .s_axi_ace_clk  (PLACECLK),
     .m_axi_gp0_rstn (net_m_axi_gp0_rstn),
     .m_axi_gp1_rstn (net_m_axi_gp1_rstn),
     .m_axi_gp2_rstn (net_m_axi_gp2_rstn),
     .s_axi_gp0_rstn (net_s_axi_gp0_rstn),
     .s_axi_gp1_rstn (net_s_axi_gp1_rstn),
     .s_axi_gp2_rstn (net_s_axi_gp2_rstn),
     .s_axi_gp3_rstn (net_s_axi_gp3_rstn),
     .s_axi_gp4_rstn (net_s_axi_gp4_rstn),
     .s_axi_gp5_rstn (net_s_axi_gp5_rstn),
     .s_axi_gp6_rstn (net_s_axi_gp6_rstn),
     .s_axi_acp_rstn (net_s_axi_acp_rstn),
     .s_axi_ace_rstn (net_s_axi_ace_rstn),
     // .fclk_reset3_n  (net_fclk_reset3_n),
     // .fclk_reset2_n  (net_fclk_reset2_n),
     // .fclk_reset1_n  (net_fclk_reset1_n),
     // .fclk_reset0_n  (net_fclk_reset0_n)
     .fclk_reset3_n  (PL_RESETN3),
     .fclk_reset2_n  (PL_RESETN2),
     .fclk_reset1_n  (PL_RESETN1),
     .fclk_reset0_n  (PL_RESETN0)
  );

  /* Clock Generator */
  zynq_ultra_ps_e_vip_v1_0_6_gen_clock #(C_FCLK_CLK3_FREQ, C_FCLK_CLK2_FREQ, C_FCLK_CLK1_FREQ, C_FCLK_CLK0_FREQ) gen_clk(
     .ps_clk      (PSS_ALTO_CORE_PAD_CLK),
     .sw_clk      (net_sw_clk),
     .fclk_clk3   (PLCLK[3:3]),
     .fclk_clk2   (PLCLK[2:2]),
     .fclk_clk1   (PLCLK[1:1]),
     .fclk_clk0   (PLCLK[0:0])
  );

  zynq_ultra_ps_e_vip_v1_0_6_ddrc ddrc (
     .rstn               (net_rstn),
     .sw_clk             (net_sw_clk),
      /* Goes to port 0 of DDR */
     .ddr_wr_qos_port0   (net_ddr_wr_qos_port0),
     .ddr_wr_ack_port0   (net_ddr_wr_ack_port0),
     .ddr_wr_data_port0  (net_ddr_wr_data_port0),
     .ddr_wr_strb_port0  (net_ddr_wr_strb_port0),
     .ddr_wr_addr_port0  (net_ddr_wr_addr_port0),
     .ddr_wr_bytes_port0 (net_ddr_wr_bytes_port0),
     .ddr_wr_dv_port0    (net_ddr_wr_dv_port0),
     .ddr_rd_qos_port0   (net_ddr_rd_qos_port0),
     .ddr_rd_req_port0   (net_ddr_rd_req_port0),
     .ddr_rd_addr_port0  (net_ddr_rd_addr_port0),
     .ddr_rd_bytes_port0 (net_ddr_rd_bytes_port0),
     .ddr_rd_data_port0  (net_ddr_rd_data_port0),
     .ddr_rd_dv_port0    (net_ddr_rd_dv_port0),
      /* Goes to port 1 of DDR */
     .ddr_wr_qos_port1   (net_ddr_wr_qos_port1),
     .ddr_wr_ack_port1   (net_ddr_wr_ack_port1),
     .ddr_wr_data_port1  (net_ddr_wr_data_port1),
     .ddr_wr_strb_port1  (net_ddr_wr_strb_port1),
     .ddr_wr_addr_port1  (net_ddr_wr_addr_port1),
     .ddr_wr_bytes_port1 (net_ddr_wr_bytes_port1),
     .ddr_wr_dv_port1    (net_ddr_wr_dv_port1),
     .ddr_rd_qos_port1   (net_ddr_rd_qos_port1),
     .ddr_rd_req_port1   (net_ddr_rd_req_port1),
     .ddr_rd_addr_port1  (net_ddr_rd_addr_port1),
     .ddr_rd_bytes_port1 (net_ddr_rd_bytes_port1),
     .ddr_rd_data_port1  (net_ddr_rd_data_port1),
     .ddr_rd_dv_port1    (net_ddr_rd_dv_port1),
      /* Goes to port2 of DDR */
     .ddr_wr_qos_port2   (net_ddr_wr_qos_port2),
     .ddr_wr_ack_port2   (net_ddr_wr_ack_port2),
     .ddr_wr_data_port2  (net_ddr_wr_data_port2),
     .ddr_wr_strb_port2  (net_ddr_wr_strb_port2),
     .ddr_wr_addr_port2  (net_ddr_wr_addr_port2),
     .ddr_wr_bytes_port2 (net_ddr_wr_bytes_port2),
     .ddr_wr_dv_port2    (net_ddr_wr_dv_port2),
     .ddr_rd_qos_port2   (net_ddr_rd_qos_port2),
     .ddr_rd_req_port2   (net_ddr_rd_req_port2),
     .ddr_rd_addr_port2  (net_ddr_rd_addr_port2),
     .ddr_rd_bytes_port2 (net_ddr_rd_bytes_port2),
     .ddr_rd_data_port2  (net_ddr_rd_data_port2),
     .ddr_rd_dv_port2    (net_ddr_rd_dv_port2),
      /* Goes to port3 of DDR */
     .ddr_wr_qos_port3   (net_ddr_wr_qos_port3),
     .ddr_wr_ack_port3   (net_ddr_wr_ack_port3),
     .ddr_wr_data_port3  (net_ddr_wr_data_port3),
     .ddr_wr_strb_port3  (net_ddr_wr_strb_port3),
     .ddr_wr_addr_port3  (net_ddr_wr_addr_port3),
     .ddr_wr_bytes_port3 (net_ddr_wr_bytes_port3),
     .ddr_wr_dv_port3    (net_ddr_wr_dv_port3),
     .ddr_rd_qos_port3   (net_ddr_rd_qos_port3),
     .ddr_rd_req_port3   (net_ddr_rd_req_port3),
     .ddr_rd_addr_port3  (net_ddr_rd_addr_port3),
     .ddr_rd_bytes_port3 (net_ddr_rd_bytes_port3),
     .ddr_rd_data_port3  (net_ddr_rd_data_port3),
     .ddr_rd_dv_port3    (net_ddr_rd_dv_port3),
      /* Goes to port4 of DDR */
     .ddr_wr_qos_port4   (net_ddr_wr_qos_port4),
     .ddr_wr_ack_port4   (net_ddr_wr_ack_port4),
     .ddr_wr_data_port4  (net_ddr_wr_data_port4),
     .ddr_wr_strb_port4  (net_ddr_wr_strb_port4),
     .ddr_wr_addr_port4  (net_ddr_wr_addr_port4),
     .ddr_wr_bytes_port4 (net_ddr_wr_bytes_port4),
     .ddr_wr_dv_port4    (net_ddr_wr_dv_port4),
     .ddr_rd_qos_port4   (net_ddr_rd_qos_port4),
     .ddr_rd_req_port4   (net_ddr_rd_req_port4),
     .ddr_rd_addr_port4  (net_ddr_rd_addr_port4),
     .ddr_rd_bytes_port4 (net_ddr_rd_bytes_port4),
     .ddr_rd_data_port4  (net_ddr_rd_data_port4),
     .ddr_rd_dv_port4    (net_ddr_rd_dv_port4),
      /* Goes to port5 of DDR */
     .ddr_wr_qos_port5   (net_ddr_wr_qos_port5),
     .ddr_wr_ack_port5   (net_ddr_wr_ack_port5),
     .ddr_wr_data_port5  (net_ddr_wr_data_port5),
     .ddr_wr_strb_port5  (net_ddr_wr_strb_port5),
     .ddr_wr_addr_port5  (net_ddr_wr_addr_port5),
     .ddr_wr_bytes_port5 (net_ddr_wr_bytes_port5),
     .ddr_wr_dv_port5    (net_ddr_wr_dv_port5),
     .ddr_rd_qos_port5   (net_ddr_rd_qos_port5),
     .ddr_rd_req_port5   (net_ddr_rd_req_port5),
     .ddr_rd_addr_port5  (net_ddr_rd_addr_port5),
     .ddr_rd_bytes_port5 (net_ddr_rd_bytes_port5),
     .ddr_rd_data_port5  (net_ddr_rd_data_port5),
     .ddr_rd_dv_port5    (net_ddr_rd_dv_port5)
  );
 
  /* include api definition */
  `include "zynq_ultra_ps_e_vip_v1_0_6_apis.sv"
 

  zynq_ultra_ps_e_vip_v1_0_6_ocmc ocmc (
     .rstn     (net_rstn),
     .sw_clk   (net_sw_clk),
     .wr_qos   (net_ocm_wr_qos),
     .wr_ack   (net_ocm_wr_ack),
     .wr_data  (net_ocm_wr_data),
     .wr_strb  (net_ocm_wr_strb),
     .wr_addr  (net_ocm_wr_addr),
     .wr_bytes (net_ocm_wr_bytes),
     .wr_dv    (net_ocm_wr_dv),
     .rd_qos   (net_ocm_rd_qos),
     .rd_req   (net_ocm_rd_req),
     .rd_addr  (net_ocm_rd_addr),
     .rd_bytes (net_ocm_rd_bytes),
     .rd_data  (net_ocm_rd_data),
     .rd_dv    (net_ocm_rd_dv)
  );

  zynq_ultra_ps_e_vip_v1_0_6_regc regc (
     .rstn     (net_rstn),
     .sw_clk   (net_sw_clk),
     .rd_qos   (net_reg_rd_qos),
     .rd_req   (net_reg_rd_req),
     .rd_addr  (net_reg_rd_addr),
     .rd_bytes (net_reg_rd_bytes),
     .rd_data  (net_reg_rd_data),
     .rd_dv    (net_reg_rd_dv)
  );

  /* include axi_acp port instantiations */
  `include "zynq_ultra_ps_e_vip_v1_0_6_axi_acp.sv"

  /* include axi_ace port instantiations */
  `include "zynq_ultra_ps_e_vip_v1_0_6_axi_ace.sv"

  /* include axi_gp port instantiations */
  `include "zynq_ultra_ps_e_vip_v1_0_6_axi_gp.sv"

  zynq_ultra_ps_e_vip_v1_0_6_ddr_interconnect_model ddr_interconnect (
     .rstn               (net_rstn),
     .sw_clk             (net_sw_clk),
  
     .wr_qos_ddr_acp     (net_wr_qos_acp),
     .wr_ack_ddr_acp     (ddr_wr_ack_acp),
     .wr_data_ddr_acp    (net_wr_data_acp),
     .wr_strb_ddr_acp    (net_wr_strb_acp),
     .wr_addr_ddr_acp    (net_wr_addr_acp),
     .wr_bytes_ddr_acp   (net_wr_bytes_acp),
     .wr_dv_ddr_acp      (ddr_wr_dv_acp),
     .rd_qos_ddr_acp     (net_rd_qos_acp),
     .rd_req_ddr_acp     (ddr_rd_req_acp),
     .rd_addr_ddr_acp    (net_rd_addr_acp),
     .rd_bytes_ddr_acp   (net_rd_bytes_acp),
     .rd_data_ddr_acp    (ddr_rd_data_acp),
     .rd_dv_ddr_acp      (ddr_rd_dv_acp),
  
     .wr_qos_ddr_ace     (net_wr_qos_ace),
     .wr_ack_ddr_ace     (ddr_wr_ack_ace),
     .wr_data_ddr_ace    (net_wr_data_ace),
     .wr_strb_ddr_ace    (net_wr_strb_ace),
     .wr_addr_ddr_ace    (net_wr_addr_ace),
     .wr_bytes_ddr_ace   (net_wr_bytes_ace),
     .wr_dv_ddr_ace      (ddr_wr_dv_ace),
     .rd_qos_ddr_ace     (net_rd_qos_ace),
     .rd_req_ddr_ace     (ddr_rd_req_ace),
     .rd_addr_ddr_ace    (net_rd_addr_ace),
     .rd_bytes_ddr_ace   (net_rd_bytes_ace),
     .rd_data_ddr_ace    (ddr_rd_data_ace),
     .rd_dv_ddr_ace      (ddr_rd_dv_ace),

     .wr_qos_ddr_gp0     (net_wr_qos_gp0),
     .wr_ack_ddr_gp0     (ddr_wr_ack_gp0),
     .wr_data_ddr_gp0    (net_wr_data_gp0),
     .wr_strb_ddr_gp0    (net_wr_strb_gp0),
     .wr_addr_ddr_gp0    (net_wr_addr_gp0),
     .wr_bytes_ddr_gp0   (net_wr_bytes_gp0),
     .wr_dv_ddr_gp0      (ddr_wr_dv_gp0),
     .rd_qos_ddr_gp0     (net_rd_qos_gp0),
     .rd_req_ddr_gp0     (ddr_rd_req_gp0),
     .rd_addr_ddr_gp0    (net_rd_addr_gp0),
     .rd_bytes_ddr_gp0   (net_rd_bytes_gp0),
     .rd_data_ddr_gp0    (ddr_rd_data_gp0),
     .rd_dv_ddr_gp0      (ddr_rd_dv_gp0),
  
     .wr_qos_ddr_gp1     (net_wr_qos_gp1),
     .wr_ack_ddr_gp1     (ddr_wr_ack_gp1),
     .wr_data_ddr_gp1    (net_wr_data_gp1),
     .wr_strb_ddr_gp1    (net_wr_strb_gp1),
     .wr_addr_ddr_gp1    (net_wr_addr_gp1),
     .wr_bytes_ddr_gp1   (net_wr_bytes_gp1),
     .wr_dv_ddr_gp1      (ddr_wr_dv_gp1),
     .rd_qos_ddr_gp1     (net_rd_qos_gp1),
     .rd_req_ddr_gp1     (ddr_rd_req_gp1),
     .rd_addr_ddr_gp1    (net_rd_addr_gp1),
     .rd_bytes_ddr_gp1   (net_rd_bytes_gp1),
     .rd_data_ddr_gp1    (ddr_rd_data_gp1),
     .rd_dv_ddr_gp1      (ddr_rd_dv_gp1),
  
     .wr_qos_ddr_gp2     (net_wr_qos_gp2),
     .wr_ack_ddr_gp2     (ddr_wr_ack_gp2),
     .wr_data_ddr_gp2    (net_wr_data_gp2),
     .wr_strb_ddr_gp2    (net_wr_strb_gp2),
     .wr_addr_ddr_gp2    (net_wr_addr_gp2),
     .wr_bytes_ddr_gp2   (net_wr_bytes_gp2),
     .wr_dv_ddr_gp2      (ddr_wr_dv_gp2),
     .rd_qos_ddr_gp2     (net_rd_qos_gp2),
     .rd_req_ddr_gp2     (ddr_rd_req_gp2),
     .rd_addr_ddr_gp2    (net_rd_addr_gp2),
     .rd_bytes_ddr_gp2   (net_rd_bytes_gp2),
     .rd_data_ddr_gp2    (ddr_rd_data_gp2),
     .rd_dv_ddr_gp2      (ddr_rd_dv_gp2),
  
     .wr_qos_ddr_gp3     (net_wr_qos_gp3),
     .wr_ack_ddr_gp3     (ddr_wr_ack_gp3),
     .wr_data_ddr_gp3    (net_wr_data_gp3),
     .wr_strb_ddr_gp3    (net_wr_strb_gp3),
     .wr_addr_ddr_gp3    (net_wr_addr_gp3),
     .wr_bytes_ddr_gp3   (net_wr_bytes_gp3),
     .wr_dv_ddr_gp3      (ddr_wr_dv_gp3),
     .rd_qos_ddr_gp3     (net_rd_qos_gp3),
     .rd_req_ddr_gp3     (ddr_rd_req_gp3),
     .rd_addr_ddr_gp3    (net_rd_addr_gp3),
     .rd_bytes_ddr_gp3   (net_rd_bytes_gp3),
     .rd_data_ddr_gp3    (ddr_rd_data_gp3),
     .rd_dv_ddr_gp3      (ddr_rd_dv_gp3),
  
     .wr_qos_ddr_gp4     (net_wr_qos_gp4),
     .wr_ack_ddr_gp4     (ddr_wr_ack_gp4),
     .wr_data_ddr_gp4    (net_wr_data_gp4),
     .wr_strb_ddr_gp4    (net_wr_strb_gp4),
     .wr_addr_ddr_gp4    (net_wr_addr_gp4),
     .wr_bytes_ddr_gp4   (net_wr_bytes_gp4),
     .wr_dv_ddr_gp4      (ddr_wr_dv_gp4),
     .rd_qos_ddr_gp4     (net_rd_qos_gp4),
     .rd_req_ddr_gp4     (ddr_rd_req_gp4),
     .rd_addr_ddr_gp4    (net_rd_addr_gp4),
     .rd_bytes_ddr_gp4   (net_rd_bytes_gp4),
     .rd_data_ddr_gp4    (ddr_rd_data_gp4),
     .rd_dv_ddr_gp4      (ddr_rd_dv_gp4),
  
     .wr_qos_ddr_gp5     (net_wr_qos_gp5),
     .wr_ack_ddr_gp5     (ddr_wr_ack_gp5),
     .wr_data_ddr_gp5    (net_wr_data_gp5),
     .wr_strb_ddr_gp5    (net_wr_strb_gp5),
     .wr_addr_ddr_gp5    (net_wr_addr_gp5),
     .wr_bytes_ddr_gp5   (net_wr_bytes_gp5),
     .wr_dv_ddr_gp5      (ddr_wr_dv_gp5),
     .rd_qos_ddr_gp5     (net_rd_qos_gp5),
     .rd_req_ddr_gp5     (ddr_rd_req_gp5),
     .rd_addr_ddr_gp5    (net_rd_addr_gp5),
     .rd_bytes_ddr_gp5   (net_rd_bytes_gp5),
     .rd_data_ddr_gp5    (ddr_rd_data_gp5),
     .rd_dv_ddr_gp5      (ddr_rd_dv_gp5),
  
     .wr_qos_ddr_gp6     (net_wr_qos_gp6),
     .wr_ack_ddr_gp6     (ddr_wr_ack_gp6),
     .wr_data_ddr_gp6    (net_wr_data_gp6),
     .wr_strb_ddr_gp6    (net_wr_strb_gp6),
     .wr_addr_ddr_gp6    (net_wr_addr_gp6),
     .wr_bytes_ddr_gp6   (net_wr_bytes_gp6),
     .wr_dv_ddr_gp6      (ddr_wr_dv_gp6),
     .rd_qos_ddr_gp6     (net_rd_qos_gp6),
     .rd_req_ddr_gp6     (ddr_rd_req_gp6),
     .rd_addr_ddr_gp6    (net_rd_addr_gp6),
     .rd_bytes_ddr_gp6   (net_rd_bytes_gp6),
     .rd_data_ddr_gp6    (ddr_rd_data_gp6),
     .rd_dv_ddr_gp6      (ddr_rd_dv_gp6),
  
     .ddr_wr_qos_port1   (net_ddr_wr_qos_port1),
     .ddr_wr_ack_port1   (net_ddr_wr_ack_port1),
     .ddr_wr_data_port1  (net_ddr_wr_data_port1),
     .ddr_wr_strb_port1  (net_ddr_wr_strb_port1),
     .ddr_wr_addr_port1  (net_ddr_wr_addr_port1),
     .ddr_wr_bytes_port1 (net_ddr_wr_bytes_port1),
     .ddr_wr_dv_port1    (net_ddr_wr_dv_port1),
     .ddr_rd_qos_port1   (net_ddr_rd_qos_port1),
     .ddr_rd_req_port1   (net_ddr_rd_req_port1),
     .ddr_rd_addr_port1  (net_ddr_rd_addr_port1),
     .ddr_rd_bytes_port1 (net_ddr_rd_bytes_port1),
     .ddr_rd_data_port1  (net_ddr_rd_data_port1),
     .ddr_rd_dv_port1    (net_ddr_rd_dv_port1),
 
     .ddr_wr_qos_port2   (net_ddr_wr_qos_port2),
     .ddr_wr_ack_port2   (net_ddr_wr_ack_port2),
     .ddr_wr_data_port2  (net_ddr_wr_data_port2),
     .ddr_wr_strb_port2  (net_ddr_wr_strb_port2),
     .ddr_wr_addr_port2  (net_ddr_wr_addr_port2),
     .ddr_wr_bytes_port2 (net_ddr_wr_bytes_port2),
     .ddr_wr_dv_port2    (net_ddr_wr_dv_port2),
     .ddr_rd_qos_port2   (net_ddr_rd_qos_port2),
     .ddr_rd_req_port2   (net_ddr_rd_req_port2),
     .ddr_rd_addr_port2  (net_ddr_rd_addr_port2),
     .ddr_rd_bytes_port2 (net_ddr_rd_bytes_port2),
     .ddr_rd_data_port2  (net_ddr_rd_data_port2),
     .ddr_rd_dv_port2    (net_ddr_rd_dv_port2),
 
     .ddr_wr_qos_port3   (net_ddr_wr_qos_port3),
     .ddr_wr_ack_port3   (net_ddr_wr_ack_port3),
     .ddr_wr_data_port3  (net_ddr_wr_data_port3),
     .ddr_wr_strb_port3  (net_ddr_wr_strb_port3),
     .ddr_wr_addr_port3  (net_ddr_wr_addr_port3),
     .ddr_wr_bytes_port3 (net_ddr_wr_bytes_port3),
     .ddr_wr_dv_port3    (net_ddr_wr_dv_port3),
     .ddr_rd_qos_port3   (net_ddr_rd_qos_port3),
     .ddr_rd_req_port3   (net_ddr_rd_req_port3),
     .ddr_rd_addr_port3  (net_ddr_rd_addr_port3),
     .ddr_rd_bytes_port3 (net_ddr_rd_bytes_port3),
     .ddr_rd_data_port3  (net_ddr_rd_data_port3),
     .ddr_rd_dv_port3    (net_ddr_rd_dv_port3),
 
     .ddr_wr_qos_port4   (net_ddr_wr_qos_port4),
     .ddr_wr_ack_port4   (net_ddr_wr_ack_port4),
     .ddr_wr_data_port4  (net_ddr_wr_data_port4),
     .ddr_wr_strb_port4  (net_ddr_wr_strb_port4),
     .ddr_wr_addr_port4  (net_ddr_wr_addr_port4),
     .ddr_wr_bytes_port4 (net_ddr_wr_bytes_port4),
     .ddr_wr_dv_port4    (net_ddr_wr_dv_port4),
     .ddr_rd_qos_port4   (net_ddr_rd_qos_port4),
     .ddr_rd_req_port4   (net_ddr_rd_req_port4),
     .ddr_rd_addr_port4  (net_ddr_rd_addr_port4),
     .ddr_rd_bytes_port4 (net_ddr_rd_bytes_port4),
     .ddr_rd_data_port4  (net_ddr_rd_data_port4),
     .ddr_rd_dv_port4    (net_ddr_rd_dv_port4),
 
     .ddr_wr_qos_port5   (net_ddr_wr_qos_port5),
     .ddr_wr_ack_port5   (net_ddr_wr_ack_port5),
     .ddr_wr_data_port5  (net_ddr_wr_data_port5),
     .ddr_wr_strb_port5  (net_ddr_wr_strb_port5),
     .ddr_wr_addr_port5  (net_ddr_wr_addr_port5),
     .ddr_wr_bytes_port5 (net_ddr_wr_bytes_port5),
     .ddr_wr_dv_port5    (net_ddr_wr_dv_port5),
     .ddr_rd_qos_port5   (net_ddr_rd_qos_port5),
     .ddr_rd_req_port5   (net_ddr_rd_req_port5),
     .ddr_rd_addr_port5  (net_ddr_rd_addr_port5),
     .ddr_rd_bytes_port5 (net_ddr_rd_bytes_port5),
     .ddr_rd_data_port5  (net_ddr_rd_data_port5),
     .ddr_rd_dv_port5    (net_ddr_rd_dv_port5)
  );

  zynq_ultra_ps_e_vip_v1_0_6_interconnect_model ocm_interconnect (
     .rstn           (net_rstn),
     .sw_clk         (net_sw_clk),

     .wr_qos_acp     (net_wr_qos_acp),
     .wr_ack_acp     (ocm_wr_ack_acp),
     .wr_data_acp    (net_wr_data_acp),
     .wr_strb_acp    (net_wr_strb_acp),
     .wr_addr_acp    (net_wr_addr_acp),
     .wr_bytes_acp   (net_wr_bytes_acp),
     .wr_dv_acp      (ocm_wr_dv_acp),
     .rd_qos_acp     (net_rd_qos_acp),
     .rd_req_acp     (ocm_rd_req_acp),
     .rd_addr_acp    (net_rd_addr_acp),
     .rd_bytes_acp   (net_rd_bytes_acp),
     .rd_data_acp    (ocm_rd_data_acp),
     .rd_dv_acp      (ocm_rd_dv_acp),
                                                   
     .wr_qos_ace     (net_wr_qos_ace),
     .wr_ack_ace     (ocm_wr_ack_ace),
     .wr_data_ace    (net_wr_data_ace),
     .wr_strb_ace    (net_wr_strb_ace),
     .wr_addr_ace    (net_wr_addr_ace),
     .wr_bytes_ace   (net_wr_bytes_ace),
     .wr_dv_ace      (ocm_wr_dv_ace),
     .rd_qos_ace     (net_rd_qos_ace),
     .rd_req_ace     (ocm_rd_req_ace),
     .rd_addr_ace    (net_rd_addr_ace),
     .rd_bytes_ace   (net_rd_bytes_ace),
     .rd_data_ace    (ocm_rd_data_ace),
     .rd_dv_ace      (ocm_rd_dv_ace),
                                             
     .wr_qos_gp0     (net_wr_qos_gp0),
     .wr_ack_gp0     (ocm_wr_ack_gp0),
     .wr_data_gp0    (net_wr_data_gp0),
     .wr_strb_gp0    (net_wr_strb_gp0),
     .wr_addr_gp0    (net_wr_addr_gp0),
     .wr_bytes_gp0   (net_wr_bytes_gp0),
     .wr_dv_gp0      (ocm_wr_dv_gp0),
     .rd_qos_gp0     (net_rd_qos_gp0),
     .rd_req_gp0     (ocm_rd_req_gp0),
     .rd_addr_gp0    (net_rd_addr_gp0),
     .rd_bytes_gp0   (net_rd_bytes_gp0),
     .rd_data_gp0    (ocm_rd_data_gp0),
     .rd_dv_gp0      (ocm_rd_dv_gp0),
                                                   
     .wr_qos_gp1     (net_wr_qos_gp1),
     .wr_ack_gp1     (ocm_wr_ack_gp1),
     .wr_data_gp1    (net_wr_data_gp1),
     .wr_strb_gp1    (net_wr_strb_gp1),
     .wr_addr_gp1    (net_wr_addr_gp1),
     .wr_bytes_gp1   (net_wr_bytes_gp1),
     .wr_dv_gp1      (ocm_wr_dv_gp1),
     .rd_qos_gp1     (net_rd_qos_gp1),
     .rd_req_gp1     (ocm_rd_req_gp1),
     .rd_addr_gp1    (net_rd_addr_gp1),
     .rd_bytes_gp1   (net_rd_bytes_gp1),
     .rd_data_gp1    (ocm_rd_data_gp1),
     .rd_dv_gp1      (ocm_rd_dv_gp1),
                                                   
     .wr_qos_gp2     (net_wr_qos_gp2),
     .wr_ack_gp2     (ocm_wr_ack_gp2),
     .wr_data_gp2    (net_wr_data_gp2),
     .wr_strb_gp2    (net_wr_strb_gp2),
     .wr_addr_gp2    (net_wr_addr_gp2),
     .wr_bytes_gp2   (net_wr_bytes_gp2),
     .wr_dv_gp2      (ocm_wr_dv_gp2),
     .rd_qos_gp2     (net_rd_qos_gp2),
     .rd_req_gp2     (ocm_rd_req_gp2),
     .rd_addr_gp2    (net_rd_addr_gp2),
     .rd_bytes_gp2   (net_rd_bytes_gp2),
     .rd_data_gp2    (ocm_rd_data_gp2),
     .rd_dv_gp2      (ocm_rd_dv_gp2),
                                                   
     .wr_qos_gp3     (net_wr_qos_gp3),
     .wr_ack_gp3     (ocm_wr_ack_gp3),
     .wr_data_gp3    (net_wr_data_gp3),
     .wr_strb_gp3    (net_wr_strb_gp3),
     .wr_addr_gp3    (net_wr_addr_gp3),
     .wr_bytes_gp3   (net_wr_bytes_gp3),
     .wr_dv_gp3      (ocm_wr_dv_gp3),
     .rd_qos_gp3     (net_rd_qos_gp3),
     .rd_req_gp3     (ocm_rd_req_gp3),
     .rd_addr_gp3    (net_rd_addr_gp3),
     .rd_bytes_gp3   (net_rd_bytes_gp3),
     .rd_data_gp3    (ocm_rd_data_gp3),
     .rd_dv_gp3      (ocm_rd_dv_gp3),
                                                   
     .wr_qos_gp4     (net_wr_qos_gp4),
     .wr_ack_gp4     (ocm_wr_ack_gp4),
     .wr_data_gp4    (net_wr_data_gp4),
     .wr_strb_gp4    (net_wr_strb_gp4),
     .wr_addr_gp4    (net_wr_addr_gp4),
     .wr_bytes_gp4   (net_wr_bytes_gp4),
     .wr_dv_gp4      (ocm_wr_dv_gp4),
     .rd_qos_gp4     (net_rd_qos_gp4),
     .rd_req_gp4     (ocm_rd_req_gp4),
     .rd_addr_gp4    (net_rd_addr_gp4),
     .rd_bytes_gp4   (net_rd_bytes_gp4),
     .rd_data_gp4    (ocm_rd_data_gp4),
     .rd_dv_gp4      (ocm_rd_dv_gp4),
                                                   
     .wr_qos_gp5     (net_wr_qos_gp5),
     .wr_ack_gp5     (ocm_wr_ack_gp5),
     .wr_data_gp5    (net_wr_data_gp5),
     .wr_strb_gp5    (net_wr_strb_gp5),
     .wr_addr_gp5    (net_wr_addr_gp5),
     .wr_bytes_gp5   (net_wr_bytes_gp5),
     .wr_dv_gp5      (ocm_wr_dv_gp5),
     .rd_qos_gp5     (net_rd_qos_gp5),
     .rd_req_gp5     (ocm_rd_req_gp5),
     .rd_addr_gp5    (net_rd_addr_gp5),
     .rd_bytes_gp5   (net_rd_bytes_gp5),
     .rd_data_gp5    (ocm_rd_data_gp5),
     .rd_dv_gp5      (ocm_rd_dv_gp5),
                                                   
     .wr_qos_gp6     (net_wr_qos_gp6),
     .wr_ack_gp6     (ocm_wr_ack_gp6),
     .wr_data_gp6    (net_wr_data_gp6),
     .wr_strb_gp6    (net_wr_strb_gp6),
     .wr_addr_gp6    (net_wr_addr_gp6),
     .wr_bytes_gp6   (net_wr_bytes_gp6),
     .wr_dv_gp6      (ocm_wr_dv_gp6),
     .rd_qos_gp6     (net_rd_qos_gp6),
     .rd_req_gp6     (ocm_rd_req_gp6),
     .rd_addr_gp6    (net_rd_addr_gp6),
     .rd_bytes_gp6   (net_rd_bytes_gp6),
     .rd_data_gp6    (ocm_rd_data_gp6),
     .rd_dv_gp6      (ocm_rd_dv_gp6),
                                                   
     .wr_qos         (net_ocm_wr_qos),
     .wr_ack         (net_ocm_wr_ack),
     .wr_data        (net_ocm_wr_data),
     .wr_strb        (net_ocm_wr_strb),
     .wr_addr        (net_ocm_wr_addr),
     .wr_bytes       (net_ocm_wr_bytes),
     .wr_dv          (net_ocm_wr_dv),
     .rd_qos         (net_ocm_rd_qos),
     .rd_req         (net_ocm_rd_req),
     .rd_addr        (net_ocm_rd_addr),
     .rd_bytes       (net_ocm_rd_bytes),
     .rd_data        (net_ocm_rd_data),
     .rd_dv          (net_ocm_rd_dv)
  );

  zynq_ultra_ps_e_vip_v1_0_6_interconnect_model reg_interconnect (
     .rstn           (net_rstn),
     .sw_clk         (net_sw_clk),

     .wr_qos_acp     (net_wr_qos_acp),
     .wr_ack_acp     (reg_wr_ack_acp),
     .wr_data_acp    (net_wr_data_acp),
     .wr_strb_acp    (net_wr_strb_acp),
     .wr_addr_acp    (net_wr_addr_acp),
     .wr_bytes_acp   (net_wr_bytes_acp),
     .wr_dv_acp      (reg_wr_dv_acp),
     .rd_qos_acp     (net_rd_qos_acp),
     .rd_req_acp     (reg_rd_req_acp),
     .rd_addr_acp    (net_rd_addr_acp),
     .rd_bytes_acp   (net_rd_bytes_acp),
     .rd_data_acp    (reg_rd_data_acp),
     .rd_dv_acp      (reg_rd_dv_acp),
                                                   
     .wr_qos_ace     (net_wr_qos_ace),
     .wr_ack_ace     (reg_wr_ack_ace),
     .wr_data_ace    (net_wr_data_ace),
     .wr_strb_ace    (net_wr_strb_ace),
     .wr_addr_ace    (net_wr_addr_ace),
     .wr_bytes_ace   (net_wr_bytes_ace),
     .wr_dv_ace      (reg_wr_dv_ace),
     .rd_qos_ace     (net_rd_qos_ace),
     .rd_req_ace     (reg_rd_req_ace),
     .rd_addr_ace    (net_rd_addr_ace),
     .rd_bytes_ace   (net_rd_bytes_ace),
     .rd_data_ace    (reg_rd_data_ace),
     .rd_dv_ace      (reg_rd_dv_ace),

     .wr_qos_gp0     (net_wr_qos_gp0),
     .wr_ack_gp0     (reg_wr_ack_gp0),
     .wr_data_gp0    (net_wr_data_gp0),
     .wr_strb_gp0    (net_wr_strb_gp0),
     .wr_addr_gp0    (net_wr_addr_gp0),
     .wr_bytes_gp0   (net_wr_bytes_gp0),
     .wr_dv_gp0      (reg_wr_dv_gp0),
     .rd_qos_gp0     (net_rd_qos_gp0),
     .rd_req_gp0     (reg_rd_req_gp0),
     .rd_addr_gp0    (net_rd_addr_gp0),
     .rd_bytes_gp0   (net_rd_bytes_gp0),
     .rd_data_gp0    (reg_rd_data_gp0),
     .rd_dv_gp0      (reg_rd_dv_gp0),
                                                   
     .wr_qos_gp1     (net_wr_qos_gp1),
     .wr_ack_gp1     (reg_wr_ack_gp1),
	 .wr_data_gp1    (net_wr_data_gp1),
     .wr_strb_gp1    (net_wr_strb_gp1),
     .wr_addr_gp1    (net_wr_addr_gp1),
     .wr_bytes_gp1   (net_wr_bytes_gp1),
     .wr_dv_gp1      (reg_wr_dv_gp1),
     .rd_qos_gp1     (net_rd_qos_gp1),
     .rd_req_gp1     (reg_rd_req_gp1),
     .rd_addr_gp1    (net_rd_addr_gp1),
     .rd_bytes_gp1   (net_rd_bytes_gp1),
     .rd_data_gp1    (reg_rd_data_gp1),
     .rd_dv_gp1      (reg_rd_dv_gp1),
                                                   
     .wr_qos_gp2     (net_wr_qos_gp2),
     .wr_ack_gp2     (reg_wr_ack_gp2),
     .wr_data_gp2    (net_wr_data_gp2),
     .wr_strb_gp2    (net_wr_strb_gp2),
     .wr_addr_gp2    (net_wr_addr_gp2),
     .wr_bytes_gp2   (net_wr_bytes_gp2),
     .wr_dv_gp2      (reg_wr_dv_gp2),
     .rd_qos_gp2     (net_rd_qos_gp2),
     .rd_req_gp2     (reg_rd_req_gp2),
     .rd_addr_gp2    (net_rd_addr_gp2),
     .rd_bytes_gp2   (net_rd_bytes_gp2),
     .rd_data_gp2    (reg_rd_data_gp2),
     .rd_dv_gp2      (reg_rd_dv_gp2),
                                                   
     .wr_qos_gp3     (net_wr_qos_gp3),
     .wr_ack_gp3     (reg_wr_ack_gp3),
     .wr_data_gp3    (net_wr_data_gp3),
     .wr_strb_gp3    (net_wr_strb_gp3),
     .wr_addr_gp3    (net_wr_addr_gp3),
     .wr_bytes_gp3   (net_wr_bytes_gp3),
     .wr_dv_gp3      (reg_wr_dv_gp3),
     .rd_qos_gp3     (net_rd_qos_gp3),
     .rd_req_gp3     (reg_rd_req_gp3),
     .rd_addr_gp3    (net_rd_addr_gp3),
     .rd_bytes_gp3   (net_rd_bytes_gp3),
     .rd_data_gp3    (reg_rd_data_gp3),
     .rd_dv_gp3      (reg_rd_dv_gp3),
                                                   
     .wr_qos_gp4     (net_wr_qos_gp4),
     .wr_ack_gp4     (reg_wr_ack_gp4),
     .wr_data_gp4    (net_wr_data_gp4),
     .wr_strb_gp4    (net_wr_strb_gp4),
     .wr_addr_gp4    (net_wr_addr_gp4),
     .wr_bytes_gp4   (net_wr_bytes_gp4),
     .wr_dv_gp4      (reg_wr_dv_gp4),
     .rd_qos_gp4     (net_rd_qos_gp4),
     .rd_req_gp4     (reg_rd_req_gp4),
     .rd_addr_gp4    (net_rd_addr_gp4),
     .rd_bytes_gp4   (net_rd_bytes_gp4),
     .rd_data_gp4    (reg_rd_data_gp4),
     .rd_dv_gp4      (reg_rd_dv_gp4),
                                                   
     .wr_qos_gp5     (net_wr_qos_gp5),
     .wr_ack_gp5     (reg_wr_ack_gp5),
     .wr_data_gp5    (net_wr_data_gp5),
     .wr_strb_gp5    (net_wr_strb_gp5),
     .wr_addr_gp5    (net_wr_addr_gp5),
     .wr_bytes_gp5   (net_wr_bytes_gp5),
     .wr_dv_gp5      (reg_wr_dv_gp5),
     .rd_qos_gp5     (net_rd_qos_gp5),
     .rd_req_gp5     (reg_rd_req_gp5),
     .rd_addr_gp5    (net_rd_addr_gp5),
     .rd_bytes_gp5   (net_rd_bytes_gp5),
     .rd_data_gp5    (reg_rd_data_gp5),
     .rd_dv_gp5      (reg_rd_dv_gp5),
                                                   
     .wr_qos_gp6     (net_wr_qos_gp6),
     .wr_ack_gp6     (reg_wr_ack_gp6),
     .wr_data_gp6    (net_wr_data_gp6),
     .wr_strb_gp6    (net_wr_strb_gp6),
     .wr_addr_gp6    (net_wr_addr_gp6),
     .wr_bytes_gp6   (net_wr_bytes_gp6),
     .wr_dv_gp6      (reg_wr_dv_gp6),
     .rd_qos_gp6     (net_rd_qos_gp6),
     .rd_req_gp6     (reg_rd_req_gp6),
     .rd_addr_gp6    (net_rd_addr_gp6),
     .rd_bytes_gp6   (net_rd_bytes_gp6),
     .rd_data_gp6    (reg_rd_data_gp6),
     .rd_dv_gp6      (reg_rd_dv_gp6),
                                                   
     .wr_qos         (net_reg_wr_qos),
     .wr_ack         (net_reg_wr_ack),
     .wr_data        (net_reg_wr_data),
     .wr_strb        (net_reg_wr_strb),
     .wr_addr        (net_reg_wr_addr),
     .wr_bytes       (net_reg_wr_bytes),
     .wr_dv          (net_reg_wr_dv),
     .rd_qos         (net_reg_rd_qos),
     .rd_req         (net_reg_rd_req),
     .rd_addr        (net_reg_rd_addr),
     .rd_bytes       (net_reg_rd_bytes),
     .rd_data        (net_reg_rd_data),
     .rd_dv          (net_reg_rd_dv)
  );


endmodule


