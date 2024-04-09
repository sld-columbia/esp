module divider_unit(
          divider,
          divisor,
          clock,
          rst,
          token_counter,
          packet_out,
          packet_out_val,
          flag_start,
          packet_in_addr,
          packet_out_addr,
          sign,
          freeze,
          zerozero,
          token_delta
);
   input [12:0] divider;
   input [6:0] divisor;
   input clock;
   input rst;
   input [6:0] token_counter;
   output  packet_out;
   output [31:0] packet_out_val; 
   output [4:0] packet_out_addr;
   output [6:0] token_delta;
   input flag_start;
   input [4:0] packet_in_addr;
   input sign;
   input [6:0] zerozero; 
   input freeze;
   //Inputs
   wire [12:0] divider;
   wire [6:0] divisor;
   wire clock;
   wire rst;
   wire flag_start;
   wire signed [6:0] token_counter;
   wire [4:0] packet_in_addr;
   wire sign;
   wire [6:0] zerozero;
   wire freeze;//If 1, the divider output maintains its state (when NoC not available)
   //Outputs
   reg [31:0] packet_out_val; 
   reg [4:0] packet_out_addr;
   reg packet_out;
   //Internal variable
   reg flag_end;
   reg signed [6:0] token_counter_save;
   reg [4:0] packet_in_addr_save;
   reg signed [6:0] zerozero_save;
   reg sign_save;
   wire [5:0] divided_out;
   reg zerozero_flag;
   reg [5:0] divided_out_save;
   reg flag_end_last; //Flag end delayed by 1 cycle
   wire [5:0] divided_out_wsave;
   reg signed [6:0] token_delta;
   
   assign divided_out_wsave=(flag_end && !flag_end_last)?divided_out:divided_out_save;
   
    token_pm_divider_hls divider_hls_Div_13Ux7U_6U_4_1( 
                                  .in2( divider ),
                                  .in1( divisor ),
                                  .out1( divided_out ),
                                  .clk( clock ),
                                  .rst( rst )
                                );
 always @ (posedge clock)
 begin //SEQ logic
 if (rst == 1'b0) begin
	flag_end<=0;
	token_counter_save<=0;
	packet_in_addr_save<=0;
	sign_save<=0;
	zerozero_save<=0;
	zerozero_flag<=0;
	divided_out_save<=0;
	flag_end_last<=0;
 end
 else begin
    flag_end<=freeze?flag_end:flag_start;
	token_counter_save<=freeze?token_counter_save:token_counter;
	packet_in_addr_save<=freeze?packet_in_addr_save:packet_in_addr;
	sign_save<=freeze?sign_save:sign;
	zerozero_save<=freeze?zerozero_save:zerozero;
	zerozero_flag<=freeze?zerozero_flag:(divider==0 && divisor==0);
	divided_out_save<=divided_out_wsave;
	flag_end_last<=flag_end;
 end 
 end 
 
 always @*
 begin : COMBO //Combinational logic
 	//Default values
	packet_out=0;
	packet_out_addr=0;
	packet_out_val=0;//Has and max
	if(flag_end==1 && zerozero_flag==0)
	begin
		packet_out=1;
		packet_out_addr=packet_in_addr_save;
		packet_out_val[6:0]=sign_save?-$signed(divided_out_wsave):$signed(divided_out_wsave);
		token_delta=(sign_save)? $signed(divided_out_wsave): -$signed(divided_out_wsave);
		
	end
	if(flag_end==1 && zerozero_flag==1)
	begin
		packet_out=1;
		packet_out_addr=packet_in_addr_save;
		packet_out_val[6:0]=$signed(-zerozero_save);
		token_delta=zerozero_save;
	end
	
 end
endmodule
