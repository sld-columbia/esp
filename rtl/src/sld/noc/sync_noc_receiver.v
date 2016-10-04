module sync_noc_receiver (
			  clock,
			  reset, // reset is active low
			  req, 
			  ack,
			  valid_out, // valid is also active low
			  data_in,
			  data_out,
			  stop_out,
			  chnl_stop);

   parameter DATA_WIDTH = 34;
//------------Input Ports------------------------------
   input 	         clock;
   input 	         reset;
   input 	         req;
   input 	         data_in;
   input 	         stop_out;
//------------Output Ports-----------------------------
   output 	         ack;
   output 	         data_out;
   output 	         valid_out;
   output 	         chnl_stop;
//------------Input Ports Data Type--------------------
   wire 	         clock;
   wire  	         reset;
   wire  	         req;
   wire [DATA_WIDTH-1:0] data_in;
   wire 		 stop_out;
//------------Output Ports Data Type-------------------
   wire			 ack;
   wire [DATA_WIDTH-1:0] data_out;
   wire 		 chnl_stop;
   wire 		 valid_out;
//------------Internal Variables-----------------------
   wire 		 valid_out_ori; 
//------------Component instatiation-------------------
   sync_receiver sync_rx1(
			  .clock(clock),
			  .reset(reset), // reset is active low
			  .req(req), 
			  .ack(ack),
			  .valid_out(valid_out_ori), // valid is also active low
			  .data_in(data_in),
			  .data_out(data_out),
			  .stop_out(stop_out),
			  .chnl_stop(chnl_stop) );
//------------valid_out constraint for NoC-------------
   assign valid_out = valid_out_ori & !stop_out;

endmodule // sync_noc_receiver
