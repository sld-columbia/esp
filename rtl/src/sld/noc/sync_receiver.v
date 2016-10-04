module sync_receiver (
		      clock,
		      reset, // reset is active low
		      req, 
		      ack,
		      valid_out, // valid is also active low
		      data_in,
		      data_out,
		      stop_out,
		      chnl_stop);

   parameter DATA_WIDTH  = 34;
   parameter BUFFER_SIZE = 4;
//------------Input Ports-----------------
   input 	         clock;
   input 	         reset;
   input 	         req;
   input  [DATA_WIDTH-1:0] data_in;
   input 	         stop_out;
//------------Output Ports-----------------
   output 	         ack;
   output [DATA_WIDTH-1:0] data_out;
   output 	         valid_out;
   output 	         chnl_stop;
//------------Input Ports Data Type-----------------
   wire 	         clock;
   wire  	         reset;
   wire  	         req;
   wire [DATA_WIDTH-1:0] data_in;
   wire 		 stop_out;
//------------Output Ports Data Type-----------------
   reg 			 ack;
   reg  [DATA_WIDTH-1:0] data_out;
   reg 			 chnl_stop;
   reg 			 valid_out;
//------------Internal Variables-----------------
   reg 			 lock;
   reg 			 lock_prev;
   reg 			 req1, req2, req3;
   reg  [1:0] 		 fsm_state;// 0-idle, 1-ack,  others
//------------Sequential Logic-----------------
   // initial begin
   //    lock         = 1'b1;
   //    lock_prev    = 1'b1;
   //    valid_out    = 1'b1;
   //    chnl_stop    = 1'b0;
   //    ack          = 1'b0;
   //    req1         = 1'b0;
   //    req2         = 1'b0;
   //    req3         = 1'b0;
   //    data_out     = 1'b0;
   // end


always @(posedge clock)
begin 
  // valid_out <= lock;
  if (reset == 1'b0)  begin 
    ack       <= 1'b0;
    lock      <= 1'b1;
    fsm_state <= 2'b0;
    chnl_stop <= 1'b0;
    valid_out <= 1'b1;
    lock_prev <= 1'b1;
    req1 <= 1'b0;
    req2 <= 1'b0;
    req3 <= 1'b0;
  end else if (stop_out == 1'b1 )  begin
    chnl_stop <= 1'b1;
    lock      <= 1'b1;
    lock_prev <= lock;
    //valid_out <= 1'b0;
  end else begin
    chnl_stop <= 1'b0;
    req1      <= req;
    req2      <= req1;
    req3      <= req2;

    lock      <= req3 ~^ req2;
    valid_out <= lock & lock_prev;
    lock_prev <= 1'b1;

    case (fsm_state)
      2'b0:	
	    if (req3 == 1'b1)  begin
	      fsm_state <= 2'b1;
	      ack       <= 1'b1;
	    end  
      2'b1:
	    if (req3 == 1'b0)  begin
	      fsm_state <= 2'b0;
	      ack       <= 1'b0;		      
	    end 
      default: 
	    begin
	      fsm_state <= 2'b0;
	      ack       <= 1'b0;
	    end 
    endcase
  end 
end

   always @(posedge clock)
     begin
	if (lock == 1'b0)
	  data_out <= data_in;
     end

endmodule
