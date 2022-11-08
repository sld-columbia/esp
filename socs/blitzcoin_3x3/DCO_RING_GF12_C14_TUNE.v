module DCO_RING_GF12_C14_TUNE (EN,DCLK,SEL,FC_SEL,LDO_IN);
	
   input EN;
   output DCLK;
   input [5:0] SEL;
   input [5:0] FC_SEL;
   input [7:0] LDO_IN;


reg [255:0] clk;

localparam TIME_PERIOD= 10;
localparam TIME_PERIOD_HALF= TIME_PERIOD/2;

parameter integer DELAYS [3 : 0]   = {2, 2, 3, 5};


assign DCLK=clk[unsigned'(LDO_IN)];


	//localparam DELAYH=DELAYS[i]/2;

genvar i;

generate
for (i = 0; i < 4 ; i = i + 1) begin
	localparam TIME_PERIODI=DELAYS[i]/2;
	initial 
	begin
	clk[i]=0;
    forever #TIME_PERIODI clk[i]=~clk[i]&&EN;
	end
end
endgenerate

endmodule
