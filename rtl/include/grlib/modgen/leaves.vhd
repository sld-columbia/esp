-----------------------------------------------------------------------------
-- File:	leaves.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	A set of multipliers generated from the Arithmetic Module
--		Generator at Norwegian University of Science and Technology.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package blocks is
  component FLIPFLOP
  port (
	DIN, CLK: in std_logic;
	DOUT: out std_logic
  );
  end component;
  component DBLCADDER_32_32
    port(OPA: in std_logic_vector(0 to 31);
         OPB: in std_logic_vector(0 to 31);
         CIN: in std_logic;
         PHI: in std_logic;
         SUM: out std_logic_vector(0 to 31);
         COUT: out std_logic);
  end component;
component FULL_ADDER
port
(
	DATA_A, DATA_B, DATA_C: in std_logic;
	SAVE, CARRY: out std_logic
);
end component;
component HALF_ADDER
port
(
	DATA_A, DATA_B: in std_logic;
	SAVE, CARRY: out std_logic
);
end component;
component R_GATE
port
(
		INA, INB, INC: in std_logic;
		PPBIT: out std_logic
);

end component;
component DECODER
port
(
		INA, INB, INC: in std_logic;
		TWOPOS, TWONEG, ONEPOS, ONENEG: out std_logic
);

end component;
component PP_LOW
port
(
		ONEPOS, ONENEG, TWONEG: in std_logic;
		INA, INB: in std_logic;
		PPBIT: out std_logic
);

end component;
component PP_MIDDLE
port
(
		ONEPOS, ONENEG, TWOPOS, TWONEG: in std_logic;
		INA, INB, INC, IND: in std_logic;
		PPBIT: out std_logic
);

end component;
component PP_HIGH
port
(
		ONEPOS, ONENEG, TWOPOS, TWONEG: in std_logic;
		INA, INB: in std_logic;
		PPBIT: out std_logic
);

end component;
component BLOCK0
port
(
	A,B,PHI: in std_logic;
	POUT,GOUT: out std_logic
);
end component;
component INVBLOCK
port
(
	GIN,PHI:in std_logic;
	GOUT:out std_logic
);
end component;

component BLOCK1
port
(
	PIN1,PIN2,GIN1,GIN2,PHI:in std_logic;
	POUT,GOUT:out std_logic
);
end component;

component BLOCK1A 
port
(
	PIN2,GIN1,GIN2,PHI:in std_logic;
	GOUT:out std_logic
);
end component;

component BLOCK2 
port
(
	PIN1,PIN2,GIN1,GIN2,PHI:in std_logic;
	POUT,GOUT:out std_logic
);
end component;

component BLOCK2A 
port
(
	PIN2,GIN1,GIN2,PHI:in std_logic;
	GOUT:out std_logic
);
end component;

component PRESTAGE_32
port
(
	A: in std_logic_vector(0 to 31);
	B: in std_logic_vector(0 to 31);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 31);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component XXOR1
port
(
	A,B,GIN,PHI:in std_logic;
	SUM:out std_logic
);
end component;
component XXOR2
port
(
	A,B,GIN,PHI:in std_logic;
	SUM:out std_logic
);
end component;
component DBLCTREE_32
port
(
	PIN:in std_logic_vector(0 to 31);
	GIN:in std_logic_vector(0 to 32);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 32);
	POUT:out std_logic_vector(0 to 0)
);
end component;

component XORSTAGE_32
port
(
	A: in std_logic_vector(0 to 31);
	B: in std_logic_vector(0 to 31);
	PBIT: in std_logic;
	PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 32);
	SUM: out std_logic_vector(0 to 31);
	COUT: out std_logic
);
end component;

component DBLC_0_32
port
(
	PIN: in std_logic_vector(0 to 31);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 30);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_1_32
port
(
	PIN: in std_logic_vector(0 to 30);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 28);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_2_32
port
(
	PIN: in std_logic_vector(0 to 28);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 24);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_3_32
port
(
	PIN: in std_logic_vector(0 to 24);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 16);
	GOUT: out std_logic_vector(0 to 32)
);
end component;

component DBLC_4_32
port
(
	PIN: in std_logic_vector(0 to 16);
	GIN: in std_logic_vector(0 to 32);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 32)
);
end component;
component PRESTAGE_64
port
(
	A: in std_logic_vector(0 to 63);
	B: in std_logic_vector(0 to 63);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 63);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLCTREE_64
port
(
	PIN:in std_logic_vector(0 to 63);
	GIN:in std_logic_vector(0 to 64);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 64);
	POUT:out std_logic_vector(0 to 0)
);
end component;

component XORSTAGE_64
port
(
	A: in std_logic_vector(0 to 63);
	B: in std_logic_vector(0 to 63);
	PBIT: in std_logic;
	PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 64);
	SUM: out std_logic_vector(0 to 63);
	COUT: out std_logic
);
end component;
component DBLC_0_64
port
(
	PIN: in std_logic_vector(0 to 63);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 62);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_1_64
port
(
	PIN: in std_logic_vector(0 to 62);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 60);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_2_64
port
(
	PIN: in std_logic_vector(0 to 60);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 56);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_3_64
port
(
	PIN: in std_logic_vector(0 to 56);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 48);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_4_64
port
(
	PIN: in std_logic_vector(0 to 48);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 32);
	GOUT: out std_logic_vector(0 to 64)
);
end component;

component DBLC_5_64
port
(
	PIN: in std_logic_vector(0 to 32);
	GIN: in std_logic_vector(0 to 64);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 64)
);
end component;
component DBLC_0_128
port
(
	PIN: in std_logic_vector(0 to 127);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 126);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_1_128
port
(
	PIN: in std_logic_vector(0 to 126);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 124);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_2_128
port
(
	PIN: in std_logic_vector(0 to 124);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 120);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_3_128
port
(
	PIN: in std_logic_vector(0 to 120);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 112);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_4_128
port
(
	PIN: in std_logic_vector(0 to 112);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 96);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_5_128
port
(
	PIN: in std_logic_vector(0 to 96);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 64);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLC_6_128
port
(
	PIN: in std_logic_vector(0 to 64);
	GIN: in std_logic_vector(0 to 128);
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 0);
	GOUT: out std_logic_vector(0 to 128)
);
end component;
component PRESTAGE_128
port
(
	A: in std_logic_vector(0 to 127);
	B: in std_logic_vector(0 to 127);
	CIN: in std_logic;
	PHI: in std_logic;
	POUT: out std_logic_vector(0 to 127);
	GOUT: out std_logic_vector(0 to 128)
);
end component;

component DBLCTREE_128
port
(
	PIN:in std_logic_vector(0 to 127);
	GIN:in std_logic_vector(0 to 128);
	PHI:in std_logic;
	GOUT:out std_logic_vector(0 to 128);
	POUT:out std_logic_vector(0 to 0)
);
end component;

component XORSTAGE_128
port
(
	A: in std_logic_vector(0 to 127);
	B: in std_logic_vector(0 to 127);
	PBIT: in std_logic;
	PHI: in std_logic;
	CARRY: in std_logic_vector(0 to 128);
	SUM: out std_logic_vector(0 to 127);
	COUT: out std_logic
);
end component;
component BOOTHCODER_18_18 
port
(
	OPA: in std_logic_vector(0 to 17);
	OPB: in std_logic_vector(0 to 17);
	SUMMAND: out std_logic_vector(0 to 188)
);
end component;
component WALLACE_18_18
port
(
	SUMMAND: in std_logic_vector(0 to 188);
	CARRY: out std_logic_vector(0 to 33);
	SUM: out std_logic_vector(0 to 34)
);
end component;
component DBLCADDER_64_64
port
(
	OPA:in std_logic_vector(0 to 63);
	OPB:in std_logic_vector(0 to 63);
	CIN:in std_logic;
	PHI:in std_logic;
	SUM:out std_logic_vector(0 to 63);
	COUT:out std_logic
);
end component;
component BOOTHCODER_34_10 
port
(
	OPA: in std_logic_vector(0 to 33);
	OPB: in std_logic_vector(0 to 9);
	SUMMAND: out std_logic_vector(0 to 184)
);
end component;
component WALLACE_34_10
port
(
	SUMMAND: in std_logic_vector(0 to 184);
	CARRY: out std_logic_vector(0 to 41);
	SUM: out std_logic_vector(0 to 42)
);
end component;
component BOOTHCODER_34_18 
port
(
	OPA: in std_logic_vector(0 to 33);
	OPB: in std_logic_vector(0 to 17);
	SUMMAND: out std_logic_vector(0 to 332)
);
end component;
component WALLACE_34_18
port
(
	SUMMAND: in std_logic_vector(0 to 332);
	CARRY: out std_logic_vector(0 to 49);
	SUM: out std_logic_vector(0 to 50)
);
end component;
component BOOTHCODER_34_34 
port
(
	OPA: in std_logic_vector(0 to 33);
	OPB: in std_logic_vector(0 to 33);
	SUMMAND: out std_logic_vector(0 to 628)
);
end component;
component WALLACE_34_34
port
(
	SUMMAND: in std_logic_vector(0 to 628);
	CARRY: out std_logic_vector(0 to 65);
	SUM: out std_logic_vector(0 to 66)
);
end component;
component DBLCADDER_128_128
port
(
	OPA:in std_logic_vector(0 to 127);
	OPB:in std_logic_vector(0 to 127);
	CIN:in std_logic;
	PHI:in std_logic;
	SUM:out std_logic_vector(0 to 127);
	COUT:out std_logic
);
end component;
  component MULTIPLIER_18_18
    generic (mulpipe : integer := 0);
    port(MULTIPLICAND: in std_logic_vector(0 to 17);
         MULTIPLIER: in std_logic_vector(0 to 17);
         PHI: in std_ulogic;
	 holdn: in std_ulogic;
         RESULT: out std_logic_vector(0 to 63));
  end component;
  component MULTIPLIER_34_10
    port(MULTIPLICAND: in std_logic_vector(0 to 33);
         MULTIPLIER: in std_logic_vector(0 to 9);
         PHI: in std_logic;
         RESULT: out std_logic_vector(0 to 63));
  end component;
  component MULTIPLIER_34_18
    port(MULTIPLICAND: in std_logic_vector(0 to 33);
         MULTIPLIER: in std_logic_vector(0 to 17);
         PHI: in std_logic;
         RESULT: out std_logic_vector(0 to 63));
  end component;
  component MULTIPLIER_34_34
    generic (mulpipe : integer := 0);
    port(MULTIPLICAND: in std_logic_vector(0 to 33);
         MULTIPLIER: in std_logic_vector(0 to 33);
         PHI: in std_logic;
	 holdn: in std_ulogic;
         RESULT: out std_logic_vector(0 to 127));
  end component;
end;



