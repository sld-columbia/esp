module I2C_Config(
input  				  iClk,
input  				  iRst_n,
output  reg			  oStart,
output  reg [6:0]   oSlave_Addr,		// device addr
output  reg [7:0]	  oWord_Addr,  	// reg addr
output  reg [7:0]   owdata,         //	wr data
output  reg         owcmd,		      //	1:write  0:read
output  reg [12:0]  Speed_Detected_0,
output  reg [12:0]  Speed_Detected_1,
input  				   Alert,
input		   [7:0]    Speed_Set,
output  reg [3:0]    Alert_Type,
input	      [7:0]	  iReadData,
input	      	     iReadData_rdy,	 //no use
input	      	     iSYSTEM_STATE,	 //no use
input	      	     iCONFIG_DONE,
input 				   Alert_Clear

						);




reg	      [3:0]  FAN_INIT_INDEX;
reg	      [15:0] FAN_REG_DATA;
reg         [12:0] FAN_SPEED_RPM;
reg         [7:0]  KTACH;
//reg		   state;
reg			[1:0]       state;
reg			[7:0]  Previous_Speed;
reg			Tach_pt;
reg         [7:0] delay ;
reg  Doing  ;

`define REG_FAN_INDEX_SIZE		 8
`define REG_MIN					60
`define REG_SLAVE_ADDR			72
`define REG_SET_RPM_ADDR		 0
`define REG_READ_RPS_ADDR_0	12 // TACH0
`define REG_READ_RPS_ADDR_1	14 // TACH1
`define REG_READ_STATUS_ADDR	10
`define REG_READ_CMD	 			 0
`define REG_WRITE_CMD	 		 1
`define REG_I2C_ENABLE_TRIGGER 1


always@(posedge iClk or negedge iRst_n) begin
  if(!iRst_n)
  begin
	 oSlave_Addr <= `REG_SLAVE_ADDR;
	 oStart <= 0;
	 owdata <= 0;
	 Tach_pt<= 0; //add TACH0/TACH1 pointer
	 delay  <= 0;
	 Doing  <=0 ;
  end
  else begin
	 if(FAN_INIT_INDEX < `REG_FAN_INDEX_SIZE) begin
	   oWord_Addr  <= FAN_REG_DATA[15:8];
	   owdata      <= FAN_REG_DATA[7:0];
	   owcmd       <= `REG_WRITE_CMD;
       oStart      <= 1'b1;
	 end
	 else begin
	    if(state == 1'b1)
		 begin
		    oWord_Addr <= `REG_SET_RPM_ADDR;
			owdata     <=  KTACH;
			owcmd      <= `REG_WRITE_CMD;
            oStart        <= `REG_I2C_ENABLE_TRIGGER;
		 end //if(state == 1'b1)
		 else if (( state == 0 ) &&  ( iCONFIG_DONE )) begin
		   if ( delay < 2 ) delay<=delay+1;
			 else begin
		        delay <=0;
		      if  (!Doing)  begin
		             Doing       <=1 ;
					 owcmd       <= `REG_READ_CMD;
					 oStart      <= `REG_I2C_ENABLE_TRIGGER;
		        if ( Alert  ) begin
            //--- read TACH0

			      if ( Tach_pt ==0 )   begin
					 Tach_pt <=1;
		             oWord_Addr  <= `REG_READ_RPS_ADDR_0;
		             Doing <=1 ;
			      end
				//--- read TACH1
			      else if ( Tach_pt ==1 )   begin
			        Tach_pt <=0;
		          oWord_Addr  <= `REG_READ_RPS_ADDR_1;
			      end
			     end // if( Alert  ) begin
		       else
			    begin
			      oWord_Addr  <= `REG_READ_STATUS_ADDR;
			  end
		    end //  if  (!Doing)  begin
		  end //else begin //1
		 end //if (( state == 0 ) &&  ( iCONFIG_DONE )) begin
		 else  if (( state == 0 ) &&  ( !iCONFIG_DONE )) begin
		       delay <= 0;
		       Doing <= 0 ;
		 end
	  end //else begin
  end //else begin
end //always@(posedge iClk or negedge iRst_n) begin


always@(posedge iCONFIG_DONE or negedge iRst_n)
begin
  if(!iRst_n)
  begin
	  Previous_Speed <= 0;
	  state <=2 ;
  end
  else if( Speed_Set != Previous_Speed  &&  FAN_INIT_INDEX >= `REG_FAN_INDEX_SIZE)
  begin
	 state <= 1;
	 KTACH <= Speed_Set;
     Previous_Speed <= Speed_Set;
  end
  else
    state <= 0;
end


always@( posedge iCONFIG_DONE )
begin
   //--- READ TACH0
   if(  oWord_Addr == `REG_READ_RPS_ADDR_0 )
	begin
	   FAN_SPEED_RPM     <= (iReadData * `REG_MIN) >> 1;//RPM = RPS * 60(s) / 2 (Two pules per revolution)
      Speed_Detected_0  <= (iReadData * `REG_MIN) >> 1;
	end
	//--- READ TACH1
   else if( oWord_Addr == `REG_READ_RPS_ADDR_1 )
	begin
	   FAN_SPEED_RPM     <= (iReadData * `REG_MIN) >> 1;//RPM = RPS * 60(s) / 2 (Two pules per revolution)
      Speed_Detected_1  <= (iReadData * `REG_MIN) >> 1;
	end

	else if(oWord_Addr == `REG_READ_STATUS_ADDR)
	begin
	  Alert_Type <= iReadData[3:0];
	end

	if(!Alert_Clear)
	    Alert_Type <= 0;
end

always@( posedge iCONFIG_DONE or negedge iRst_n)
begin
  if(!iRst_n)
  begin
	FAN_INIT_INDEX <= 0;
  end
  else if( FAN_INIT_INDEX <`REG_FAN_INDEX_SIZE)
	 FAN_INIT_INDEX <= FAN_INIT_INDEX + 1;
  else
	 FAN_INIT_INDEX <= FAN_INIT_INDEX;
end

always@(FAN_INIT_INDEX)
begin
	case(FAN_INIT_INDEX)
	0	:	FAN_REG_DATA	<=	16'h004e;//  - default fan speed 3000rpm
	1	:	FAN_REG_DATA	<=	16'h022a;//  - configuration Operating Mode, Fan/Tachometer Voltage and Prescaler Division.
	2	:	FAN_REG_DATA	<=	16'h04f5;//  - setup GPIO Definition Register. GPIO1 serves as a FULL ON input and GPIO0 serves as an ALERT output
	3	:	FAN_REG_DATA	<=	16'h0800;//  - Alarm-Enable Register. disable Tachometer Overflow / Minimum Output Level and Maximum Output Level alarm.
	4	:	FAN_REG_DATA	<=	16'h0800;//  - Alarm-Enable Register. disable Tachometer Overflow / Minimum Output Level and Maximum Output Level alarm.
	5	:	FAN_REG_DATA	<=	16'h0800;//  - Alarm-Enable Register. disable Tachometer Overflow / Minimum Output Level and Maximum Output Level alarm.
	6	:	FAN_REG_DATA	<=	16'h080f;//  - Alarm-Enable Register. Enable Tachometer Overflow / Minimum Output Level and Maximum Output Level alarm.
	7	:	FAN_REG_DATA	<=	16'h1602;//  - setup Tachometer Count-Time Register. Count Time = 1sec
	endcase
end





endmodule
