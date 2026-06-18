module Fan_Control(
input 		       CLK,
input       [12:0] Speed_Set,
input					 Alert_Clear,
input 				 Alert,
output   	[3:0]  Alert_Type,
output      [12:0] FAN0_Speed,
output      [12:0] FAN1_Speed,
output   			 FAN_I2C_SCL,
inout					 FAN_I2C_SDA,
output             RST_N

						 );



reg	      [3:0]  FAN_INIT_INDEX;
reg	      [15:0] FAN_REG_DATA;
reg         [12:0] FAN_SPEED_RPM;


wire 		  			 i2c_reg_control_start ;
wire 		  			 wr_cmd ;
wire 			[6:0]  slave_addr ;
wire 			[7:0]  reg_addr ;
wire 			[7:0]  reg_wdata ;
wire 					 i2c_rdata_rdy ;
wire 			[7:0]  i2c_rdata ;
wire 			       i2c_cmd_finish ;

reg  			[4:0]  Count;
reg 		  			 CLK_2M;
reg  		   [12:0] FAN_RPM;
reg  			[12:0] FAN_RPS;
reg  			[7:0]  KTACH;
reg         [31:0] RESET_DELAY =0; // important

`define KSCALE 4

//-- Auto reset
assign RST_N =RESET_DELAY[25] ;

always @( negedge Alert_Clear  or posedge CLK  )
if ( !Alert_Clear ) RESET_DELAY<=0;
else begin
  if   ( RESET_DELAY[25]==0 ) RESET_DELAY<=RESET_DELAY+1 ;
  else  RESET_DELAY<= RESET_DELAY ;
end

//---- main

always@(posedge CLK  or negedge RST_N)
if(!RST_N)
   begin
    Count <= 0;
  end
  else
  begin
    if( Count > 24)
	 begin
	  Count<=0;
	  CLK_2M <= ~CLK_2M;
	 end
	 else
	  Count <= Count + 1;
  end

//---

always@(posedge CLK)
begin
  FAN_RPM <= Speed_Set;
  FAN_RPS <= FAN_RPM/60;
  KTACH   <= (12'd992 *`KSCALE / FAN_RPS)-1;
end

I2C_Config u0
(
	 .iClk  (CLK_2M),
	 .iRst_n(RST_N),
	 .oStart(i2c_reg_control_start),
	 .oSlave_Addr(slave_addr),
	 .oWord_Addr(reg_addr),
	 .owdata(reg_wdata),
	 .owcmd(wr_cmd),
	 .Speed_Set       (KTACH),
	 .Speed_Detected_0(FAN0_Speed),
	 .Speed_Detected_1(FAN1_Speed),
	 .Alert_Type(Alert_Type),
	 .Alert(Alert),
	 .Alert_Clear(Alert_Clear),
	 .iSYSTEM_STATE(1'b0),
    .iReadData(i2c_rdata),
	 .iReadData_rdy(i2c_rdata_rdy),
	 .iCONFIG_DONE(i2c_cmd_finish)
);

I2C_Bus_Controller u1 (
    .iCLK       (CLK_2M),
    .iRST_n     (RST_N),
    .iStart     (i2c_reg_control_start),
    .iSlave_addr(slave_addr),
    .iWord_addr (reg_addr),
    .iSequential_read(1'b0),
    .iRead_length(8'd1),
    .i2c_clk    (FAN_I2C_SCL),
    .i2c_data   (FAN_I2C_SDA),
    .i2c_read_data(i2c_rdata),
    .i2c_read_data_rdy(i2c_rdata_rdy),
    .wr_data(reg_wdata),
    .wr_cmd(wr_cmd),
    .oCONFIG_DONE(i2c_cmd_finish)
    ) ;

endmodule
