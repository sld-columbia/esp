 module IVRCM (
        CLKADC, QADC, ENADC,
        DDAC, SEL_1V, VDD_IVR,
	VREF );

   input [3:0] DDAC;
   input CLKADC;
   input ENADC;
   input SEL_1V;
   input VDD_IVR;
   output VREF;
   // the ADC has a minimum clock period of 8 ns
   // it samples on the rising edge of CLKADC, and the
   // output is correct on the falling edge (4 ns later)

   output [4:0] QADC;

   // current will be approximately the decimal value of
   // QDC - decimal DDACIN / 10e-3... at the least, we'll get a
   // signal that is correlated with power.
 
   IVRADC adcSB (.clock(CLKADC), .en(ENADC), .encoder_out(QADC), .vdd_ivr(VDD_IVR));
   //.VIN(VDDR), .VREF(VDDF)
   
   IVRDAC dacSB (.D(DDAC), .SEL_1V(SEL_1V), .vref(VREF) );

endmodule

module IVRADC ( clock, en, encoder_out, vdd_ivr );
    //
    input clock;
    input en;
    output [4:0] encoder_out;
    input 	 vdd_ivr;
endmodule

module IVRDAC ( D, SEL_1V , vref );
    input [3:0] D;
    input SEL_1V;
   output vref;
endmodule
