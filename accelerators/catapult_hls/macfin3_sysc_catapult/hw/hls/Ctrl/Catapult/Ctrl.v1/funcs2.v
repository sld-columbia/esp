//------------------------------------------------------------------
//                   M G C _ H L S (F U N C S)
//------------------------------------------------------------------

//------------------------------------------------------------------
//                        M O D U L E S
//------------------------------------------------------------------

//------------------------------------------------------------------
//-- GTECH ENTITIES
//------------------------------------------------------------------

module csa (a, b, c, s, cout);

  parameter integer width = 16;

  input  [width-1:0] a;
  input  [width-1:0] b;
  input  [width-1:0] c;
  output [width-1:0] s;
  output [width-1:0] cout;

  assign s    = a^b^c;
  assign cout = (a&b) | (b&c) | (c&a);

endmodule

//------------------------------------------------------------------

module csha (a, b, s, cout);

  parameter integer width = 16;

  input  [width-1:0] a;
  input  [width-1:0] b;
  output [width-1:0] s;
  output [width-1:0] cout;

  assign s    = a^b;
  assign cout = (a&b);

endmodule
