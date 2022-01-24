
module PBIDIRN_18_18_H
  (
   PAD,
   Y,
   A,
   OE,
   DS0,
   DS1,
   SR,
   IE
   );

   inout PAD;
   output Y;
   input A;
   input OE;
   input DS0;
   input DS1;
   input SR;
   input IE;

   PBIDIRN_18_18_FS_DR_H p_i
     (
      .PAD(PAD),
      .Y(Y),
      .PO( ),
      .A(A),
      .OE(OE),
      .DS0(DS0),
      .DS1(DS1),
      .SR(SR),
      .PS(1'b0),
      .PE(1'b0),
      .IE(IE),
      .IS(1'b0),
      .POE(1'b0),
      .RTO( ),
      .SNS( )
      );

endmodule

module PBIDIRN_18_18_V
  (
   PAD,
   Y,
   A,
   OE,
   DS0,
   DS1,
   SR,
   IE
   );

   inout PAD;
   output Y;
   input A;
   input OE;
   input DS0;
   input DS1;
   input SR;
   input IE;

   PBIDIRN_18_18_FS_DR_V p_i
     (
      .PAD(PAD),
      .Y(Y),
      .PO( ),
      .A(A),
      .OE(OE),
      .DS0(DS0),
      .DS1(DS1),
      .SR(SR),
      .PS(1'b0),
      .PE(1'b0),
      .IE(IE),
      .IS(1'b0),
      .POE(1'b0),
      .RTO( ),
      .SNS( )
      );

endmodule
