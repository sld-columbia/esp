module sync_noc_transmitter (
     			  clock, 
			  reset,     // reset is active low
			  valid_in,  // valid is also active low
			  stop_in,
			  ack, 
			  req,
			  data_in,
			  data_out,
			  chnl_stop);

   parameter DATA_WIDTH = 34;
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
   wire			   req;
   wire [DATA_WIDTH-1:0]   data_out;
   wire 		   stop_in;
//------------Internal Variables-----------------
   wire			   stop;
//------------Component Instantiation-----------------
   sync_transmitter tx1 (
			 .clock(clock), 
			 .reset(reset), 
			 .valid_in(valid_in), 
			 .stop_in(stop), 
			 .ack(ack), 
			 .req(req), 
			 .data_in(data_in), 
			 .data_out(data_out), 
			 .chnl_stop(chnl_stop) );

//------------stop_in constraint for NoC-----------------
   assign stop_in = stop & !valid_in;

endmodule // sync_noc_transmitter
