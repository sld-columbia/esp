module sync_transmitter ( 
			  clock, 
			  reset,     // reset is active low
			  valid_in,  // valid is also active low
			  stop_in,
			  ack, 
			  req,
			  data_in,
			  data_out,
			  chnl_stop);

   parameter DATA_WIDTH  = 34; // DATA_WIDTH is FLIT_SIZE
   parameter BUFFER_SIZE = 4;  // BUFFER_SIZE is the number of flits that will be stored then sent
   parameter CHNL_WIDTH  = DATA_WIDTH*BUFFER_SIZE;
   
//------------Input Ports-----------------
   input 	           clock;
   input 		   reset;
   input 		   valid_in;
   input 		   ack;
   input [DATA_WIDTH-1:0]  data_in;
   input 		   chnl_stop;
//------------Output Ports-----------------
   output                  req; 
   output [DATA_WIDTH-1:0] data_out;
   output 		   stop_in;
//------------Input Ports Data Type-----------------
   wire 		   clock; 
   wire 		   reset;
   wire 		   valid_in;
   wire 		   ack;
   wire [DATA_WIDTH-1:0]   data_in;
//------------Output Ports Data Type-----------------
   reg 			   req;
   reg [DATA_WIDTH-1:0]    data_out;
   wire 		   stop_in;
//------------Internal Variables-----------------
   reg 			   lock; // enable for data register - sample input 
   reg 			   stop;  
   reg 			   ack1, ack2, ack3;
   reg [1:0] 		   fsm_state;  // 0-req, 1-clear, 2-req, 3-clear
   reg [DATA_WIDTH-1:0]    data_reg [0:BUFFER_SIZE-1];
   reg [1:0]		   counter;
   
//------------Sequential Logic-----------------
   // initial begin
   //    lock     = 1'b0;
   //    req      = 1'b0;
   //    ack1     = 1'b0;
   //    ack2     = 1'b0;
   //    ack3     = 1'b0;
   //    data_out = 1'b0;
   //    stop     = 1'b0;
   //    counter  = 2'b0;
      
   // end

// stop signals ouput is modified due to NoC behaviour to a stop when data just tunrs void
// to prevent the data_void signal to go low unnescessairly. The output stop_in is gated so 
// to valid_in (data_void_)

// NOTE: Due to conflicts a top entity will add the valid condition when connected to NoC   
   assign stop_in = (stop | chnl_stop); //& !valid_in;
   //assign stop_in = stop; 

   always @(posedge clock)
     begin 
	if (reset == 1'b0) begin 
	   req	      <= 1'b0;
	   ack1       <= 1'b0;
	   ack2       <= 1'b0;
	   ack3       <= 1'b0;
	   lock       <= 1'b0;
	   fsm_state  <= 2'b0;
	   stop       <= 1'b0;
	   counter    <= 2'b0;
	end else if (chnl_stop == 1'b1)  begin
	   lock <= 1'b1;
	   // stop <= 1'b1;
	end else begin
	   ack1 <= ack;
	   ack2 <= ack1;
	   ack3 <= ack2;
	   //F    <= ~ack3 & ack2;

	   case (fsm_state)
	     2'b0 :  // data stored - send req ( 1 ) 
	       if (valid_in == 1'b0)  begin 
		  fsm_state <= 2'b1;
		  req	    <= 1'b1;
		  lock	    <= 1'b1;
		  stop	    <= 1'b1;
	       end  
	     2'b1:   // data sent - open register
	       if (ack3 == 1'b1)  begin 
		  fsm_state <= 2'b10;
		  //req       <= 1'b0;
		  lock      <= 1'b0;
		  stop      <= 1'b0;
	       end
	     2'b10: // data stored - send req ( 0 )
	       if (valid_in == 1'b0)  begin
		  fsm_state <= 2'b11;
		  req       <= 1'b0;
		  lock      <= 1'b1;
		  stop      <= 1'b1;
	       end 
	     2'b11: // data sent - open register
	       if (ack3 == 1'b0)	begin
		  fsm_state <= 2'b0;
		  lock      <= 1'b0;
		  stop      <= 1'b0;
	       end 
	     default:
	       begin
		  fsm_state <= 2'b0;
		  req       <= 1'b0;
	       end 
	   endcase 
	end
     end 

   always @(posedge clock) // DATA REGISTER
     begin
	if (lock == 1'b0)
	  data_out <= data_in;
     end

endmodule

