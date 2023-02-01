-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
-- Entity: 	asu
-- File:	asu.vhd
-- Author:	Paolo Mantovani - SLD @ Columbia University
-- Description:	Addition / Subtraction Unit.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.basic.all;

entity asu is

  port (
    clk      : in  std_ulogic;
    rst      : in  std_ulogic;
    double   : in  std_ulogic;          --determins result type
    add      : in  std_ulogic;
    sub      : in  std_ulogic;
    itofp    : in  std_ulogic;
    fptoi    : in  std_ulogic;
    fptornd  : in  std_ulogic;
    fptofp   : in  std_ulogic;
    cmp      : in  std_ulogic;
    cmpe     : in  std_ulogic;
    absv     : in  std_ulogic;          --single precision only
    neg      : in  std_ulogic;          --single precision only
    mov      : in  std_ulogic;          --signle precision only
    round    : in  std_logic_vector(1 downto 0);
    in0      : in  std_logic_vector(63 downto 0);
    in1      : in  std_logic_vector(63 downto 0);
    man0_ldz : in  std_logic_vector(5 downto 0);
    man1_ldz : in  std_logic_vector(5 downto 0);
    in0_zero : in  std_ulogic;
    in1_zero : in  std_ulogic;
    in0_nstd : in  std_ulogic;
    in1_nstd : in  std_ulogic;
    in0_inf  : in  std_ulogic;
    in1_inf  : in  std_ulogic;
    in0_NaN  : in  std_ulogic;
    in1_NaN  : in  std_ulogic;
    in0_SNaN : in  std_ulogic;
    in1_SNaN : in  std_ulogic;
    result   : out std_logic_vector(63 downto 0);
    cc       : out std_logic_vector(1 downto 0);
    flags    : out std_logic_vector(5 downto 0));

end asu;

-- flags
-- UNF | NV | OV | UF | DZ | NX

architecture rtl of asu is

  constant zero : std_logic_vector(55 downto 0) := (others => '0');
  constant ones : std_logic_vector(55 downto 0) := (others => '1');

-------------------------------------------------------------------------------
-- Leading zero counter. (Copyright (C) 2002 Martin Kasprzyk)
-------------------------------------------------------------------------------
  procedure lz_counter (
    in_vect       : in  std_logic_vector(55 downto 0);
    leading_zeros : out std_logic_vector(5 downto 0)) is 
    variable pos_mask : std_logic_vector(55 downto 0);
    variable neg_mask : std_logic_vector(55 downto 0);
    variable leading_one : std_logic_vector(55 downto 0);
    variable nr_zeros : std_logic_vector(5 downto 0);
  begin
    -- Find leading one e.g. if in_vect = 00101101 then pos_mask = 00111111
    -- and neg_mask = "11100000, performing and gives leading_one = 00100000
    pos_mask(55) := in_vect(55);
    for i in 54 downto 0 loop
      pos_mask(i) := pos_mask(i+1) or in_vect(i);
    end loop;
    neg_mask := "1" & (not pos_mask(55 downto 1));
    leading_one := pos_mask and neg_mask;

    -- Get number of leading zeros from the leading_one vector
    nr_zeros := "000000";
 
    for i in 1 to 55 loop
      if (i / 32) /= 0 then
        nr_zeros(5) := nr_zeros(5) or leading_one(55-i);
      end if;

      if ((i mod 32) / 16) /= 0  then
        nr_zeros(4) := nr_zeros(4) or leading_one(55-i);
      end if;

      if (((i mod 32) mod 16) / 8) /= 0 then
        nr_zeros(3) := nr_zeros(3) or leading_one(55-i);
      end if;

      if ((((i mod 32) mod 16) mod 8) / 4) /= 0 then
        nr_zeros(2) := nr_zeros(2) or leading_one(55-i);
      end if;

      if (((((i mod 32) mod 16) mod 8) mod 4) / 2) /= 0 then
        nr_zeros(1) := nr_zeros(1) or leading_one(55-i);
      end if;
      
      if (i mod 2) /= 0 then
        nr_zeros(0) := nr_zeros(0) or leading_one(55-i);
      end if;
    end loop;

    -- Return result
    leading_zeros := nr_zeros;
  end lz_counter;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Variable amount left shifter (Copyright (C) 2002 Martin Kasprzyk) - edit
-------------------------------------------------------------------------------
  procedure left_shifter (
    in_vect  : in  std_logic_vector(54 downto 0);
    amount   : in  std_logic_vector(5 downto 0);
    out_vect : out std_logic_vector(54 downto 0)) is
    variable after32 : std_logic_vector(54 downto 0);
    variable after16 : std_logic_vector(54 downto 0);
    variable after8  : std_logic_vector(54 downto 0);
    variable after4  : std_logic_vector(54 downto 0);
    variable after2  : std_logic_vector(54 downto 0);
    variable after1  : std_logic_vector(54 downto 0);
  begin
    -- If amount(5) = '1' then shift vector 32 positions left
    if amount(5) = '1' then
      after32 := in_vect(22 downto 0) & zero(31 downto 0);
    else
      after32 := in_vect;
    end if;

    -- If amount(4) = '1' then shift vector 16 positions left
    if amount(4) = '1' then
      after16 :=  after32(38 downto 0) & zero(15 downto 0);
    else
      after16 := after32;
    end if;

    -- If amount(3) = '1' then shift vector 8 positions left
    if amount(3) = '1' then
      after8 := after16(46 downto 0) & zero(7 downto 0);
    else
      after8 := after16;
    end if;

    -- If amount(2) = '1' then shift vector 4 positions left
    if amount(2) = '1' then
      after4 := after8(50 downto 0) & zero(3 downto 0);
    else
      after4 := after8;
    end if;

    -- If amount(1) = '1' then shift vector 2 positions left
    if amount(1) = '1' then
      after2 := after4(52 downto 0) & "00";
    else
      after2 := after4;
    end if;

    -- If amount(0) = '1' then shift vector 1 positions left
    if amount(0) = '1' then
      after1 := after2(53 downto 0) & "0";
    else
      after1 := after2;
    end if;

    -- Return value
    out_vect := after1;
  end left_shifter;
  
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Variable amount right shifter with sticky bit calculation.
-- (Copyright (C) 2002 Martin Kasprzyk) - Edit
-------------------------------------------------------------------------------
  procedure right_shifter_sticky (
    in_vect    : in  std_logic_vector(54 downto 0);
    amount     : in  std_logic_vector(5 downto 0);
    sticky_in  : in  std_ulogic;
    out_vect   : out std_logic_vector(54 downto 0);
    sticky_bit : out std_ulogic;
    sticky_low : out std_ulogic;
    guard_bit  : out std_ulogic) is
    variable after32  : std_logic_vector(54 downto 0);
    variable after16  : std_logic_vector(54 downto 0);
    variable after8   : std_logic_vector(54 downto 0);
    variable after4   : std_logic_vector(54 downto 0);
    variable after2   : std_logic_vector(54 downto 0);
    variable after1   : std_logic_vector(54 downto 0);
    variable sticky32 : std_ulogic;
    variable sticky16 : std_ulogic;
    variable sticky8  : std_ulogic;
    variable sticky4  : std_ulogic;
    variable sticky2  : std_ulogic;
    variable sticky1  : std_ulogic;
    variable g32, g16, g8, g4, g2, g1 : std_ulogic;
    variable sl32, sl16, sl8, sl4, sl2, sl1 : std_ulogic;
    variable sticky_bit_tmp, sticky_low_tmp, guard_bit_tmp : std_ulogic;
  begin
    -- If amount(5) = '1' then shift vector 32 positions right
    if amount(5) = '1' then
      after32 := zero(31 downto 0) & in_vect(54 downto 32);
      if in_vect(31 downto 0) /= zero(31 downto 0) then
        sticky32 := '1';
      else
        sticky32 := '0';
      end if;
      if in_vect(30 downto 0) /= zero(30 downto 0) then
        sl32 := '1';
      else
        sl32 := '0';
      end if;
      g32 := in_vect(31);
    else
      after32 := in_vect;
      sticky32 := '0';
      sl32 := '0';
      g32 := '0';
    end if;

    -- If amount(4) = '1' then shift vector 16 positions right
    if amount(4) = '1' then
      after16 := zero(15 downto 0) & after32(54 downto 16);
      if after32(15 downto 0) /= zero(15 downto 0) then
        sticky16 := '1';
      else
        sticky16 := '0';
      end if;
      if after32(14 downto 0) /= zero(14 downto 0) then
        sl16 := '1';
      else
        sl16 := g32;
      end if;
      g16 := after32(15);
    else
      after16 := after32;
      sticky16 := '0';
      sl16 := '0';
      g16 := g32;
    end if;

    -- If amount(3) = '1' then shift vector 8 positions right
    if amount(3) = '1' then
      after8 := zero(7 downto 0) & after16(54 downto 8);
      if after16(7 downto 0) /= zero(7 downto 0) then
        sticky8 := '1';
      else
        sticky8 := '0';
      end if;
      if after16(6 downto 0) /= zero(6 downto 0) then
        sl8 := '1';
      else
        sl8 := g16;
      end if;
      g8 := after16(7);
    else
      after8 := after16;
      sticky8 := '0';
      sl8 := '0';
      g8 := g16;
    end if;

    -- If amount(2) = '1' then shift vector 4 positions right
    if amount(2) = '1' then
      after4 := zero(3 downto 0) & after8(54 downto 4);
      if after8(3 downto 0) /= zero(3 downto 0) then
        sticky4 := '1';
      else
        sticky4 := '0';
      end if;
      if after8(2 downto 0) /= zero(2 downto 0) then
        sl4 := '1';
      else
        sl4 := g8;
      end if;
      g4 := after8(3);
    else
      after4 := after8;
      sticky4 := '0';
      sl4 := '0';
      g4 := g8;
    end if;

    -- If amount(1) = '1' then shift vector 2 positions right
    if amount(1) = '1' then
      after2 := "00" & after4(54 downto 2);
      if after4(1 downto 0) /= "00" then
        sticky2 := '1';
      else
        sticky2 := '0';
      end if;
      if after4(0) /= '0' then
        sl2 := '1';
      else
        sl2 := g4;
      end if;
      g2 := after4(1);
    else
      after2 := after4;
      sticky2 := '0';
      sl2 := '0';
      g2 := g4;
    end if;

    -- If amount(0) = '1' then shift vector 1 positions right
    if amount(0) = '1' then
      after1 := "0" & after2(54 downto 1);
      sticky1 := after2(0);
      sl1 := g2;
      g1 := after2(0);
    else
      after1 := after2;
      sticky1 := '0';
      sl1 := '0';
      g1 := g2;
    end if;

    sticky_bit_tmp := sticky32 or sticky16 or sticky8 or sticky4 or sticky2 or
                      sticky1 or sticky_in;
    sticky_low_tmp := sl32 or sl16 or sl8 or sl4 or sl2 or sl1 or sticky_in;
    guard_bit_tmp := g1;
    if sticky_bit_tmp = '1' and guard_bit_tmp = '0' then
      sticky_low := '1';
    else
      sticky_low := sticky_low_tmp;
    end if;

    -- Return values
    sticky_bit := sticky_bit_tmp;
    guard_bit := guard_bit_tmp;
    out_vect := after1;
  end right_shifter_sticky;

-------------------------------------------------------------------------------

  
  --input register
  signal double_reg, double1_reg, double2_reg    : std_ulogic;
  signal add_reg, add1_reg, add2_reg             : std_ulogic;
  signal sub_reg, sub1_reg, sub2_reg             : std_ulogic;
  signal itofp_reg, itofp1_reg, itofp2_reg       : std_ulogic;
  signal fptoi_reg, fptoi1_reg, fptoi2_reg       : std_ulogic;
  signal fptornd_reg, fptornd1_reg, fptornd2_reg : std_ulogic;
  signal fptofp_reg, fptofp1_reg, fptofp2_reg    : std_ulogic;
  signal cmp_reg, cmp1_reg, cmp2_reg             : std_ulogic;
  signal cmpe_reg, cmpe1_reg, cmpe2_reg          : std_ulogic;
  signal absv_reg, absv1_reg, absv2_reg          : std_ulogic; --single precision only
  signal neg_reg, neg1_reg, neg2_reg             : std_ulogic; --single precision only
  signal mov_reg, mov1_reg, mov2_reg             : std_ulogic; --signle precision only
  signal round_reg, round1_reg, round2_reg       : std_logic_vector(1 downto 0);

  signal in0_reg, in1_reg : std_logic_vector(63 downto 0);
  signal in0_reg1, in1_reg1 : std_logic_vector(63 downto 0);
  signal in0_reg2, in1_reg2 : std_logic_vector(63 downto 0);
  
  signal man0_ldz_reg, man0_ldz1_reg, man0_ldz2_reg : std_logic_vector(5 downto 0);
  signal man1_ldz_reg, man1_ldz1_reg, man1_ldz2_reg : std_logic_vector(5 downto 0);
  signal in0_zero_reg, in0_zero1_reg, in0_zero2_reg : std_ulogic;
  signal in1_zero_reg, in1_zero1_reg, in1_zero2_reg : std_ulogic;
  signal in0_nstd_reg, in0_nstd1_reg, in0_nstd2_reg : std_ulogic;
  signal in1_nstd_reg, in1_nstd1_reg, in1_nstd2_reg : std_ulogic;
  signal in0_inf_reg, in0_inf1_reg, in0_inf2_reg    : std_ulogic;
  signal in1_inf_reg, in1_inf1_reg, in1_inf2_reg    : std_ulogic;
  signal in0_NaN_reg, in0_NaN1_reg, in0_NaN2_reg    : std_ulogic;
  signal in1_NaN_reg, in1_NaN1_reg, in1_NaN2_reg    : std_ulogic;
  signal in0_SNaN_reg, in0_SNaN1_reg, in0_SNaN2_reg : std_ulogic;
  signal in1_SNaN_reg, in1_SNaN1_reg, in1_SNaN2_reg : std_ulogic;

  --output register
  signal result_out : std_logic_vector(63 downto 0);
  signal cc_out : std_logic_vector(1 downto 0);
  signal nv_out, ovf_out, udf_out, nx_out : std_ulogic;
  signal man_out : std_logic_vector(51 downto 0);
  signal exp_out : std_logic_vector(10 downto 0);
  signal sign_out : std_ulogic;
  signal in0_nv, in1_nv : std_ulogic;
  signal qnangen_out : std_ulogic;
  
  --exceptions
  -- UNF | NV | OV | UF | DZ | NX
  signal UNF, NV, OV, UF, DZ, NX : std_ulogic;

  --ADD/SUB Stage 1
  signal exp0, exp1, exp1b, expA, expB : std_logic_vector(11 downto 0);
  signal exp_diff, exp_diffb : std_logic_vector(11 downto 0);
  signal larger_operand, exp_diff_sign, exp_diff_co : std_ulogic;
  signal shift1more : std_ulogic;
  signal exp : std_logic_vector(11 downto 0);
  signal shift_amount : std_logic_vector(11 downto 0);
  signal sigloss : std_ulogic;
  signal shift_max_double : std_logic_vector(11 downto 0);
  signal shift_max_single : std_logic_vector(11 downto 0);
  signal dosub : std_ulogic;
  signal man0, man1 : std_logic_vector(52 downto 0);
  signal manA, manB : std_logic_vector(54 downto 0);
  signal sticky : std_ulogic;
  signal stickyl : std_ulogic;
  signal sticky_one : std_ulogic;
  signal guard : std_ulogic;
  --Sage 1 registers
  signal larger_operand1_reg : std_ulogic;
  signal sigloss1_reg : std_ulogic;
  signal manA1_reg, manB1_reg : std_logic_vector(55 downto 0);
  signal exp1_reg : std_logic_vector(11 downto 0);
  signal dosub1_reg : std_ulogic;
  signal sticky1_reg : std_ulogic;
  signal stickyl1_reg : std_ulogic;
  signal sticky_one1_reg : std_ulogic;
  signal guard1_reg : std_ulogic;

  --ADD/SUB Stage 2
  signal man_sum_carry_in : std_ulogic;
  signal man_sum : std_logic_vector(55 downto 0);
  signal man_sum_carry : std_ulogic;
  signal man_sum_sign : std_ulogic;
  signal sign0, sign1 : std_ulogic;
  signal sign : std_ulogic;
  signal man_to_norm : std_logic_vector(54 downto 0);
  signal man_ldz : std_logic_vector(5 downto 0);
  signal man_is_zero : std_ulogic;
  --Stage 2 registers
  signal sticky2_reg : std_ulogic;
  signal stickyl2_reg : std_ulogic;
  signal guard2_reg : std_ulogic;
  signal dosub2_reg : std_ulogic;
  signal exp2_reg : std_logic_vector(11 downto 0);
  signal man_to_norm2_reg : std_logic_vector(54 downto 0);
  signal sign2_reg : std_ulogic;
  signal man_ldz2_reg : std_logic_vector(5 downto 0);
  signal man_is_zero2_reg : std_ulogic;

  --ADD/SUB Stage 3
  signal exp_adj : std_logic_vector(11 downto 0);
  signal exp_norm : std_logic_vector(11 downto 0);
  signal exp_norm_m1_sign : std_ulogic;
  signal exp_norm_carry : std_ulogic;
  signal exp_norm_m1 : std_logic_vector(11 downto 0);
  signal exp_norm_m1_carry : std_ulogic;
  signal man_ldz_adj : std_logic_vector(5 downto 0);
  signal man_ldz_adj_carry : std_ulogic;
  signal round_add1_in : std_logic_vector(54 downto 0);
  signal man_to_round : std_logic_vector(54 downto 0);
  signal round_factor : std_logic_vector(54 downto 0);
  signal man_round : std_logic_vector(54 downto 0);
  signal man_round_carry : std_ulogic;
  signal ulsb, lsb, llsb : std_ulogic;
  signal sticky_norm : std_ulogic;
  signal guard_norm : std_ulogic;
  signal nornd : std_ulogic;
  signal expp1 : std_logic_vector(11 downto 0);
  signal expp1_carry : std_ulogic;
  signal man_o : std_logic_vector(51 downto 0);
  signal exp_o : std_logic_vector(10 downto 0);
  signal sign_o : std_ulogic;
  signal ovf_o, nx_o, nv_o : std_ulogic;

  -- ABS
  signal man_abs : std_logic_vector(51 downto 0);
  signal exp_abs : std_logic_vector(10 downto 0);
  signal sign_abs : std_ulogic;
  -- NEG
  signal man_neg : std_logic_vector(51 downto 0);
  signal exp_neg : std_logic_vector(10 downto 0);
  signal sign_neg : std_ulogic;
  -- MOV
  signal man_mov : std_logic_vector(51 downto 0);
  signal exp_mov : std_logic_vector(10 downto 0);
  signal sign_mov : std_ulogic;

  --Compare
  signal nv_cmp : std_ulogic;
  signal nv_cmpe : std_ulogic;
  signal man_cmp : std_logic_vector(51 downto 0);
  signal exp_cmp : std_logic_vector(10 downto 0);
  signal sign_cmp : std_ulogic;
  signal exp_diff1_reg, exp_diff2_reg : std_logic_vector(11 downto 0);
  signal larger_operand2_reg : std_ulogic;

  --Integer to fp. stage 1
  signal int_ldz : std_logic_vector(5 downto 0);
  signal int_sign : std_ulogic;
  signal int_man_tmp : std_logic_vector(31 downto 0);
  signal int_manb_tmp : std_logic_vector(31 downto 0);
  signal int_man_2comp_tmp : std_logic_vector(31 downto 0);
  signal int_man_2comp_tmp_co : std_ulogic;
  signal int_man : std_logic_vector(31 downto 0);
  --Registers
  signal int_ldz1_reg : std_logic_vector(5 downto 0);
  signal int_man1_reg : std_logic_vector(31 downto 0);
  signal int_sign1_reg : std_ulogic;
  
  --Integer to fp. Stage 2
  signal int_ldzb : std_logic_vector(10 downto 0);
  signal int_exp : std_logic_vector(10 downto 0);
  signal int_exp_co : std_ulogic;
  constant int_ovf_exp : std_logic_vector(10 downto 0) := "00000100000";  --32
  signal int_man_shift : std_logic_vector(31 downto 0);
  --Registers
  signal int_exp2_reg : std_logic_vector(10 downto 0);
  signal int_man2_reg : std_logic_vector(31 downto 0);
  signal int_sign2_reg : std_ulogic;

  --Integer to fp Stage 3
  signal int_bias : std_logic_vector(10 downto 0);
  signal int_bexp, int_bexpp1 : std_logic_vector(10 downto 0);
  signal int_bexp_co, int_bexpp1_co : std_ulogic;
  signal int_sticky : std_ulogic;
  --By adding this constant we also take into account the sticky bit.
  constant int_single_round_wsticky : std_logic_vector(31 downto 0) := X"0000007f";
  --This constant has to be used when lsb is 1. Sticky does not matter.
  constant int_single_round_nsticky : std_logic_vector(31 downto 0) := X"00000080";
  signal int_single_round_factor : std_logic_vector(31 downto 0);
  signal int_man_single_round : std_logic_vector(31 downto 0);
  signal int_man_single_round_co : std_ulogic;
  signal nx_itofp : std_ulogic;
  signal man_itofp : std_logic_vector(51 downto 0);
  signal exp_itofp : std_logic_vector(10 downto 0);
  signal sign_itofp : std_ulogic;

  --Fp to Int Stage1
  constant fptoi_double_ovf : std_logic_vector(11 downto 0) := "010000011101";  --1023+30
  constant fptoi_double_udf : std_logic_vector(11 downto 0) := "001111111111";  --1023+0
  constant fptoi_single_ovf : std_logic_vector(11 downto 0) := "000010011101";  --127+30
  constant fptoi_single_udf : std_logic_vector(11 downto 0) := "000001111111";  --127+0
  signal fptoi_ovf, fptoi_udf : std_ulogic;
  signal fptoi_exp0 : std_logic_vector(11 downto 0);
  signal fptoi_exp0b : std_logic_vector(11 downto 0);
  signal fptoi_base_exp : std_logic_vector(11 downto 0);
  signal fptoi_shift : std_logic_vector(11 downto 0);
  signal fptoi_shift_co : std_ulogic;
  --Registers
  signal fptoi_ovf1_reg, fptoi_udf1_reg : std_ulogic;
  signal fptoi_shift1_reg : std_logic_vector(5 downto 0);
  
  --Fp to Int Stage2 TODO: implement the round according to RND!!!
  signal fptoi_man : std_logic_vector(31 downto 0);
  signal fptoi_sticky : std_ulogic;
  --Registers
  signal fptoi_ovf2_reg, fptoi_udf2_reg : std_ulogic;
  signal fptoi_man2_reg : std_logic_vector(31 downto 0);
  signal fptoi_sticky2_reg : std_ulogic;

  --Fp to Int Stage3
  constant INT_MAX : std_logic_vector(31 downto 0) := X"7fffffff";
  constant INT_MIN : std_logic_vector(31 downto 0) := X"80000000";
  signal fptoi_sign : std_ulogic;
  signal fptoi_manb : std_logic_vector(31 downto 0);
  signal fptoi_man_2comp : std_logic_vector(31 downto 0);
  signal fptoi_man_2comp_co : std_ulogic;
  signal nx_fptoi, nv_fptoi : std_ulogic;
  signal result_int : std_logic_vector(31 downto 0);

  --Fp to Fp Stage 1
  signal fptofp_bexp_in : std_logic_vector(11 downto 0);
  signal fptofp_bias_in : std_logic_vector(11 downto 0);
  signal fptofp_exp_in : std_logic_vector(11 downto 0);
  signal fptofp_exp_in_co : std_ulogic;
  signal fptofp_man_in : std_logic_vector(52 downto 0);
  signal fptofp_round_factor : std_logic_vector(52 downto 0);
  signal fptofp_man_round : std_logic_vector(52 downto 0);
  signal fptofp_use_expp1 : std_ulogic;
  signal fptofp_sub_stod_add0 : std_logic_vector(11 downto 0);
  signal fptofp_sub_stod_add1 : std_logic_vector(11 downto 0);
  signal fptofp_sub_exp_in : std_logic_vector(11 downto 0);
  signal fptofp_sub_exp_in_co : std_ulogic;
  --Registers
  signal fptofp_exp_in1_reg : std_logic_vector(11 downto 0);
  signal fptofp_man_round1_reg : std_logic_vector(52 downto 0);
  signal fptofp_use_expp11_reg : std_ulogic;

  --Fp to Fp Stage 2
  signal fptofp_bias_out : std_logic_vector(11 downto 0);
  signal fptofp_bexp_out_ci : std_ulogic;
  signal fptofp_bexp_out : std_logic_vector(11 downto 0);
  signal fptofo_bexp_out_co : std_ulogic;
  signal fptofp_man_shift : std_logic_vector(22 downto 0);
  --Registers
  signal fptofp_man_round2_reg : std_logic_vector(52 downto 0);
  signal fptofp_use_expp12_reg : std_ulogic;
  signal fptofp_bexp_out2_reg : std_logic_vector(11 downto 0);
  signal fptofp_man_shift2_reg : std_logic_vector(22 downto 0);
  
  --Fp to Fp Stage 3
  signal dtos_exact : std_ulogic;
  signal fptofp_man_sub : std_logic_vector(24 downto 0);
  signal fptofp_man_sub_ci : std_ulogic;
  signal fptofp_man_sub_round : std_logic_vector(24 downto 0);
  signal fptofp_man_sub_co : std_ulogic;
  signal dtos_exact_sub : std_ulogic;
  signal fptofp_res_nstd : std_ulogic;
  signal nv_fptofp, nx_fptofp, ovf_fptofp, udf_fptofp : std_ulogic;
  signal man_fptofp : std_logic_vector(51 downto 0);
  signal exp_fptofp : std_logic_vector(10 downto 0);
  signal sign_fptofp : std_ulogic;
  
  constant bias_single  : std_logic_vector(10 downto 0) := "00001111111"; -- +127
  constant nbias_single : std_logic_vector(10 downto 0) := "11110000001"; -- -127
  constant bias_double  : std_logic_vector(10 downto 0) := "01111111111"; -- +1023
  constant nbias_double : std_logic_vector(10 downto 0) := "10000000001"; -- -1023
  constant expudf : std_logic_vector(10 downto 0) := "11111101001";  -- -23
  constant expovf : std_logic_vector(10 downto 0) := "00011111110";  -- +254

begin  -- rtl

  -- Input Register
  input_register: process (clk, rst)
  begin  -- process input_register
    if rst = '0' then                   -- asynchronous reset (active low)
      double_reg <= '0';
      double1_reg <= '0';
      double2_reg <= '0';
      add_reg <= '0';
      add1_reg <= '0';
      add2_reg <= '0';
      sub_reg <= '0';
      sub1_reg <= '0';
      sub2_reg <= '0';
      itofp_reg <= '0';
      itofp1_reg <= '0';
      itofp2_reg <= '0';
      fptoi_reg <= '0';
      fptoi1_reg <= '0';
      fptoi2_reg <= '0';
      fptornd_reg <= '0';
      fptornd1_reg <= '0';
      fptornd2_reg <= '0';
      fptofp_reg <= '0';
      fptofp1_reg <= '0';
      fptofp2_reg <= '0';
      cmp_reg <= '0';
      cmp1_reg <= '0';
      cmp2_reg <= '0';
      cmpe_reg <= '0';
      cmpe1_reg <= '0';
      cmpe2_reg <= '0';
      absv_reg <= '0';
      absv1_reg <= '0';
      absv2_reg <= '0';
      neg_reg <= '0';
      neg1_reg <= '0';
      neg2_reg <= '0';
      mov_reg <= '0';
      mov1_reg <= '0';
      mov2_reg <= '0';
      round_reg <= (others => '0');
      round1_reg <= (others => '0');
      round2_reg <= (others => '0');
      in0_reg <= (others => '0');
      in1_reg <= (others => '0');
      in0_reg1 <= (others => '0');
      in1_reg1 <= (others => '0');
      in0_reg2 <= (others => '0');
      in1_reg2 <= (others => '0');
      man0_ldz_reg <= (others => '0');
      man0_ldz1_reg <= (others => '0');
      man0_ldz2_reg <= (others => '0');
      man1_ldz_reg <= (others => '0');
      man1_ldz1_reg <= (others => '0');
      man1_ldz2_reg <= (others => '0');
      in0_zero_reg <= '1';
      in0_zero1_reg <= '1';
      in0_zero2_reg <= '1';
      in1_zero_reg <= '1';
      in1_zero1_reg <= '1';
      in1_zero2_reg <= '1';
      in0_nstd_reg <= '0';
      in0_nstd1_reg <= '0';
      in0_nstd2_reg <= '0';
      in1_nstd_reg <= '0';
      in1_nstd1_reg <= '0';
      in1_nstd2_reg <= '0';
      in0_inf_reg <= '0';
      in0_inf1_reg <= '0';
      in0_inf2_reg <= '0';
      in1_inf_reg <= '0';
      in1_inf1_reg <= '0';
      in1_inf2_reg <= '0';
      in0_NaN_reg <= '0';
      in0_NaN1_reg <= '0';
      in0_NaN2_reg <= '0';
      in1_NaN_reg <= '0';
      in1_NaN1_reg <= '0';
      in1_NaN2_reg <= '0';
      in0_SNaN_reg <= '0';
      in0_SNaN1_reg <= '0';
      in0_SNaN2_reg <= '0';
      in1_SNaN_reg <= '0';
      in1_SNaN1_reg <= '0';
      in1_SNaN2_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      double_reg <= double;
      double1_reg <= double_reg;
      double2_reg <= double1_reg;
      add_reg <= add;
      add1_reg <= add_reg;
      add2_reg <= add1_reg;
      sub_reg <= sub;
      sub1_reg <= sub_reg;
      sub2_reg <= sub1_reg;
      itofp_reg <= itofp;
      itofp1_reg <= itofp_reg;
      itofp2_reg <= itofp1_reg;
      fptoi_reg <= fptoi;
      fptoi1_reg <= fptoi_reg;
      fptoi2_reg <= fptoi1_reg;
      fptornd_reg <= fptornd;
      fptornd1_reg <= fptornd_reg;
      fptornd2_reg <= fptornd1_reg;
      fptofp_reg <= fptofp;
      fptofp1_reg <= fptofp_reg;
      fptofp2_reg <= fptofp1_reg;
      cmp_reg <= cmp;
      cmp1_reg <= cmp_reg;
      cmp2_reg <= cmp1_reg;
      cmpe_reg <= cmpe;
      cmpe1_reg <= cmpe_reg;
      cmpe2_reg <= cmpe1_reg;
      absv_reg <= absv;
      absv1_reg <= absv_reg;
      absv2_reg <= absv1_reg;
      neg_reg <= neg;
      neg1_reg <= neg_reg;
      neg2_reg <= neg1_reg;
      mov_reg <= mov;
      mov1_reg <= mov_reg;
      mov2_reg <= mov1_reg;
      round_reg <= round;
      round1_reg <= round_reg;
      round2_reg <= round1_reg;
      in0_reg <= in0;
      in1_reg <= in1;
      in0_reg1 <= in0_reg;
      in1_reg1 <= in1_reg;
      in0_reg2 <= in0_reg1;
      in1_reg2 <= in1_reg1;
      man0_ldz_reg <= man0_ldz;
      man0_ldz1_reg <= man0_ldz_reg;
      man0_ldz2_reg <= man0_ldz1_reg;
      man1_ldz_reg <= man1_ldz;
      man1_ldz1_reg <= man1_ldz_reg;
      man1_ldz2_reg <= man1_ldz1_reg;
      in0_zero_reg <= in0_zero;
      in0_zero1_reg <= in0_zero_reg;
      in0_zero2_reg <= in0_zero1_reg;
      in1_zero_reg <= in1_zero;
      in1_zero1_reg <= in1_zero_reg;
      in1_zero2_reg <= in1_zero1_reg;
      in0_nstd_reg <= in0_nstd;
      in0_nstd1_reg <= in0_nstd_reg;
      in0_nstd2_reg <= in0_nstd1_reg;
      in1_nstd_reg <= in1_nstd;
      in1_nstd1_reg <= in1_nstd_reg;
      in1_nstd2_reg <= in1_nstd1_reg;
      in0_inf_reg <= in0_inf;
      in0_inf1_reg <= in0_inf_reg;
      in0_inf2_reg <= in0_inf1_reg;
      in1_inf_reg <= in1_inf;
      in1_inf1_reg <= in1_inf_reg;
      in1_inf2_reg <= in1_inf1_reg;
      in0_NaN_reg <= in0_NaN;
      in0_NaN1_reg <= in0_NaN_reg;
      in0_NaN2_reg <= in0_NaN1_reg;
      in1_NaN_reg <= in1_NaN;
      in1_NaN1_reg <= in1_NaN_reg;
      in1_NaN2_reg <= in1_NaN1_reg;
      in0_SNaN_reg <= in0_SNaN;
      in0_SNaN1_reg <= in0_SNaN_reg;
      in0_SNaN2_reg <= in0_SNaN1_reg;
      in1_SNaN_reg <= in1_SNaN;
      in1_SNaN1_reg <= in1_SNaN_reg;
      in1_SNaN2_reg <= in1_SNaN1_reg;
    end if;
  end process input_register;

  -- Output Register
  output_register: process (clk, rst)
  begin  -- process output_register
    if rst = '0' then                   -- asynchronous reset (active low)
      UNF <= '0';
      NV <= '0';
      OV <= '0';
      UF <= '0';
      DZ <= '0';
      NX <= '0';
      cc <= (others => '0');
      result <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      UNF <= '0';                     --handling subnormals
      NV <= nv_out;
      OV <= ovf_out;
      UF <= udf_out;
      DZ <= '0';
      NX <= nx_out;
      cc <= cc_out;
      if qnangen_out = '1' then
        if double2_reg = '1' then
          result <= QNaN_GENd;
        else
          result <= QNaN_GENs;
        end if;
      elsif (fptoi2_reg or fptornd2_reg) = '1' then
        result <= X"00000000" & result_int;
      else
        result <= result_out;
      end if;
    end if;
  end process output_register;
  flags <= UNF & NV & OV & UF & DZ & NX;
  result_out <= sign_out & exp_out & man_out when double2_reg = '1' else
                zero(31 downto 0) & sign_out & exp_out(7 downto 0) & man_out(22 downto 0);

  in0_nv <= in0_SNaN2_reg;
  in1_nv <= in1_SNaN2_reg;
  out_assign: process(add2_reg, sub2_reg, itofp2_reg, fptoi2_reg,
                      fptoi_ovf2_reg, fptoi_udf2_reg,
                      fptornd2_reg, fptofp2_reg, cmp2_reg,
                      cmpe2_reg, absv2_reg, neg2_reg, mov2_reg,
                      in0_nv, in1_nv,
                      man_o, exp_o, sign_o, nv_o, ovf_o, nx_o,
                      man_abs, exp_abs, sign_abs,
                      man_neg, exp_neg, sign_neg,
                      man_mov, exp_mov, sign_mov,
                      man_itofp, exp_itofp, sign_itofp, nx_itofp,
                      nv_fptoi, nx_fptoi, 
                      nv_fptofp, nx_fptofp, ovf_fptofp, udf_fptofp,
                      man_fptofp, exp_fptofp, sign_fptofp,
                      man_cmp, exp_cmp, sign_cmp, nv_cmp, nv_cmpe)
  begin  -- process out_assign
    if (add2_reg or sub2_reg) = '1' then
      man_out <= man_o;
      exp_out <= exp_o;
      sign_out <= sign_o;
      nv_out <= nv_o or in0_nv or in1_nv;
      ovf_out <= ovf_o;
      udf_out <= '0';
      nx_out <= nx_o;
      qnangen_out <= nv_o or in0_nv or in1_nv;
    elsif (fptoi2_reg or fptornd2_reg) = '1' then  --TODO: differs w RND!!
      man_out <= (others => '0');
      exp_out <= (others => '0');
      sign_out <= '0';
      nv_out <= nv_fptoi;
      ovf_out <= fptoi_ovf2_reg;
      udf_out <= fptoi_udf2_reg;
      nx_out <= nx_fptoi;
      qnangen_out <= '0';
    elsif (fptofp2_reg) = '1' then
      --double defines the output
      man_out <= man_fptofp;
      exp_out <= exp_fptofp;
      sign_out <= sign_fptofp;
      nv_out <= nv_fptofp;
      ovf_out <= ovf_fptofp;
      udf_out <= udf_fptofp;
      nx_out <= nx_fptofp;
      qnangen_out <= in0_nv;
    elsif itofp2_reg = '1' then
      man_out <= man_itofp;
      exp_out <= exp_itofp;
      sign_out <= sign_itofp;
      nv_out <= '0';
      ovf_out <= '0';
      udf_out <= '0';
      nx_out <= nx_itofp;
      qnangen_out <= '0';
    elsif cmp2_reg = '1' then
      man_out <= man_cmp;               --TODO: Used for NaN only
      exp_out <= exp_cmp;
      sign_out <= sign_cmp;
      nv_out <= nv_cmp;
      ovf_out <= '0';
      udf_out <= '0';
      nx_out <= '0';
      qnangen_out <= '0';
    elsif cmpe2_reg = '1' then
      man_out <= man_cmp;               --TODO: Used for NaN only
      exp_out <= exp_cmp;
      sign_out <= sign_cmp;
      nv_out <= nv_cmpe;
      ovf_out <= '0';
      udf_out <= '0';
      nx_out <= '0';
      qnangen_out <= '0';
    elsif absv2_reg = '1' then
      man_out <= man_abs;
      exp_out <= exp_abs;
      sign_out <= sign_abs;
      nv_out <= '0';
      ovf_out <= '0';
      udf_out <= '0';
      nx_out <= '0';
      qnangen_out <= '0';
    elsif neg2_reg = '1' then
      man_out <= man_neg;
      exp_out <= exp_neg;
      sign_out <= sign_neg;
      nv_out <= '0';
      ovf_out <= '0';
      udf_out <= '0';
      nx_out <= '0';
      qnangen_out <= '0';
    elsif mov2_reg = '1' then
      man_out <= man_mov;
      exp_out <= exp_mov;
      sign_out <= sign_mov;
      nv_out <= '0';
      ovf_out <= '0';
      udf_out <= '0';
      nx_out <= '0';
      qnangen_out <= '0';
    else  --NOP
      man_out <= (others => '0');
      exp_out <= (others => '0');
      sign_out <= '0';
      nv_out <= '0';
      ovf_out <= '0';
      udf_out <= '0';
      nx_out <= '0';
      qnangen_out <= '0';
    end if;

  end process out_assign;
  
-------------------------------------------------------------------------------
-- ADD/SUB stage 1
--
-- Compute exponent difference and shift
-------------------------------------------------------------------------------

  effective_operation: process (double_reg, in0_reg, in1_reg, sub_reg,
                                add_reg, in0_zero_reg, in1_zero_reg)
    variable s0,s1 : std_ulogic;
  begin  -- process effective_operation
    if double_reg = '1' then
      s0 := in0_reg(63);
      s1 := in1_reg(63);
    else
      s0 := in0_reg(31);
      s1 := in1_reg(31);
    end if;
    if in0_zero_reg = '1' then
      s0 := '0';
    end if;
    if in1_zero_reg = '1' then
      s1 := '0';
    end if;

    if in0_zero_reg = '1' then
      dosub <= sub_reg xor s1;
    elsif in1_zero_reg = '1' then
      dosub <= sub_reg xor s0;
    elsif s0 = s1 then
      dosub <= sub_reg;
    else
      dosub <= add_reg;
    end if;
  end process effective_operation;
  
  exp0 <= "0" & in0_reg(62 downto 52) when double_reg = '1' else "0000" & in0_reg(30 downto 23);
  exp1 <= "0" & in1_reg(62 downto 52) when double_reg = '1' else "0000" & in1_reg(30 downto 23);
  exp1b <= not exp1;
  expAB_assign: process (exp0, in0_nstd_reg, in1_nstd_reg, exp1, exp1b, in0_zero_reg, in1_zero_reg)
  begin  -- process expAB_assign
    if (in0_zero_reg or in1_zero_reg) = '1' then  --exp diff is zero!
      expA <= exp1;
      expB <= exp1b;
    else
      if in0_nstd_reg = '0' or in1_nstd_reg = '1' then
        expA <= exp0;
      else
        expA <= exp1;
      end if;
      if (in0_nstd_reg xor in1_nstd_reg) = '0' then
        expB <= exp1b;
      else
        expB <= "111111111110";
      end if;
    end if;
  end process expAB_assign;
  
  -- exp0 - exp1
  ppadd_1: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => expA,
      add1_in   => expB,
      carry_in  => '1',
      sum_out   => exp_diff,
      carry_out => exp_diff_co);

  exp_diffb <= not exp_diff;
  exp_diff_sign <= exp_diff(11);
  larger_operand <= exp_diff(11) when in0_zero_reg = '0' and
                    (in0_nstd_reg = '0' or in1_nstd_reg = '1') else '1';

  shift_amount_assign: process (exp_diff, exp_diffb, exp_diff_sign, larger_operand,
                                exp0, exp1)
  begin  -- process shift_amount_assign
    if exp_diff_sign = '0' then
      shift_amount <= exp_diff;
    else
      shift_amount <= exp_diffb;
    end if;
    if larger_operand = '0' then
      exp <= exp0;
    else
      exp <= exp1;
    end if;
  end process shift_amount_assign;
  shift1more <= exp_diff_sign;

  shift_max_double <= "000000110101" when shift1more = '0' else "000000110100";
  shift_max_single  <= "000000011000" when shift1more = '0' else "000000010111";
  significand_loss_error: process (shift_amount,  double_reg, shift_max_double, shift_max_single)
  begin  -- process
    if double_reg = '1' and (shift_amount > shift_max_double) then
      sigloss <= '1';
    elsif double_reg = '0' and (shift_amount > shift_max_single) then
      sigloss <= '1';
    else
      sigloss <= '0';
    end if;
  end process significand_loss_error;

  --Mantissa with no hidden bit
  man0 <= in0_reg(51 downto 0) & '0' when double_reg = '1'
          else in0_reg(22 downto 0) & "00" & X"0000000";
  man1 <= in1_reg(51 downto 0) & '0' when double_reg = '1'
          else in1_reg(22 downto 0) & "00" & X"0000000";
  
  shift_smaller_operand: process (double_reg, man0, man1, sigloss,
                                  dosub, shift_amount, shift1more,
                                  in0_nstd_reg, in1_nstd_reg,
                                  in0_zero_reg, in1_zero_reg,
                                  larger_operand)
    variable in_vect : std_logic_vector(54 downto 0);
    variable amount : std_logic_vector(5 downto 0);
    variable out_vect : std_logic_vector(54 downto 0);
    variable sticky_bit : std_ulogic;
    variable stickyl_bit : std_ulogic;
    variable guard_bit : std_ulogic;
  begin  -- process shift_smaller_operand
    amount := shift_amount(5 downto 0);
    if larger_operand = '0' then
      if in1_nstd_reg = '1' or in1_zero_reg = '1' then
        in_vect := "00" & man1;
      else
        in_vect := "01" & man1;
      end if;
    else
      if in0_nstd_reg = '1' or in0_zero_reg = '1' then
        in_vect := "00" & man0;
      else
        in_vect := "01" & man0;
      end if;
    end if;
    right_shifter_sticky(in_vect, amount, '0', out_vect, sticky_bit, stickyl_bit, guard_bit);
    if shift1more = '1' then
      stickyl_bit := stickyl_bit or guard_bit;
      sticky_bit := sticky_bit or out_vect(0);
      guard_bit := out_vect(0);
      out_vect := '0' & out_vect(54 downto 1);
    end if;

    if larger_operand = '0' then
      if in0_nstd_reg = '1' or in0_zero_reg = '1' then
        manA <= "00" & man0;
      else
        manA <= "01" & man0;
      end if;
    else
      if in1_nstd_reg = '1' or in1_zero_reg = '1' then
        manA <= "00" & man1;
      else
        manA <= "01" & man1;
      end if;
    end if;

    if sigloss = '1' then
      manB <= (others => '0');
      guard <= '0';
    elsif dosub = '0' then
      manB <= out_vect;
      guard <= guard_bit;
    else
      manB <= not out_vect;
      if stickyl_bit = '0' then
        guard <= guard_bit;
      else
        guard <= not guard_bit;
      end if;
    end if;

    sticky <= sticky_bit;
    stickyl <= stickyl_bit;
    sticky_one <= not sticky_bit;     --needed only for dosub
  end process shift_smaller_operand;

  stage1_register: process (clk, rst)
  begin  -- process stage1_register
    if rst = '0' then                   -- asynchronous reset (active low)
      larger_operand1_reg <= '0';
      sigloss1_reg <= '0';
      manA1_reg <= (others => '0');
      manB1_reg <= (others => '0');
      exp1_reg <= (others => '0');
      dosub1_reg <= '0';
      sticky1_reg <= '0';
      stickyl1_reg <= '0';
      sticky_one1_reg <= '0';
      guard1_reg <= '0';
      exp_diff1_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      larger_operand1_reg <= larger_operand;
      sigloss1_reg <= sigloss;
      manA1_reg <= manA(54) & manA;
      manB1_reg <= manB(54) & manB;
      exp1_reg <= exp;
      dosub1_reg <= dosub;
      sticky1_reg <= sticky;
      stickyl1_reg <= stickyl;
      sticky_one1_reg <= sticky_one;
      guard1_reg <= guard;
      exp_diff1_reg <= exp_diff;        --needed for comparison
    end if;
  end process stage1_register;

-------------------------------------------------------------------------------
-- ADD/SUB stage 2
--
-- Compute mantissa and final sign
-- Count leading zeros to adjust exponent
-------------------------------------------------------------------------------

  man_sum_carry_in <= dosub1_reg and (not sigloss1_reg) and sticky_one1_reg;
  ppadd_2: ppadd
    generic map (
      n    => 56,
      logn => 6)
    port map (
      add0_in   => manA1_reg,
      add1_in   => manB1_reg,
      carry_in  => man_sum_carry_in,
      sum_out   => man_sum,
      carry_out => man_sum_carry);

  sign0 <= in0_reg1(63) when double1_reg = '1' else in0_reg1(31);
  sign1 <= in1_reg1(63) when double1_reg = '1' else in1_reg1(31);
  
  man_sum_sign <= man_sum(55);
  sign <= man_sum_sign xor sign0 when larger_operand1_reg = '0'
          else sub1_reg xor sign1;
  man_to_norm <= man_sum(54 downto 0) when man_sum_sign = '0' else
                 (not man_sum(54 downto 0)) + (X"0000000000000" & "001");
  man_is_zero <= '1' when man_sum = zero(55 downto 0) else '0';
  
  man_sum_ldz: process (man_to_norm, exp1_reg)
    variable in_vect : std_logic_vector(55 downto 0);
    variable leading_zeros : std_logic_vector(5 downto 0);
  begin  -- process man_sum_ldz
    in_vect := man_to_norm(53 downto 0) & "00";
    lz_counter(in_vect, leading_zeros);
    if man_to_norm(54) = '1' then
      man_ldz <= (others => '0');
    elsif exp1_reg = zero(10 downto 0) then
      man_ldz <= (others => '0');
    else
      man_ldz <= leading_zeros;
    end if;
  end process man_sum_ldz;


  stage2_register: process (clk, rst)
  begin  -- process stage2_register
    if rst = '0' then                   -- asynchronous reset (active low)
      sticky2_reg <= '0';
      stickyl2_reg <= '0';
      guard2_reg <= '0';
      dosub2_reg <= '0';
      exp2_reg <= (others => '0');
      man_to_norm2_reg <= (others => '0');
      sign2_reg <= '0';
      man_ldz2_reg <= (others => '0');
      man_is_zero2_reg <= '0';
      exp_diff2_reg <= (others => '0');
      larger_operand2_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      sticky2_reg <= sticky1_reg;
      stickyl2_reg <= stickyl1_reg;
      guard2_reg <= guard1_reg;
      dosub2_reg <= dosub1_reg;
      exp2_reg <= exp1_reg;
      man_to_norm2_reg <= man_to_norm;
      sign2_reg <= sign;
      man_ldz2_reg <= man_ldz;
      man_is_zero2_reg <= man_is_zero;
      exp_diff2_reg <= exp_diff1_reg;   --needed for comparison
      larger_operand2_reg <= larger_operand1_reg;  --needed for comparison
    end if;
  end process stage2_register;


-------------------------------------------------------------------------------
-- ADD/SUB stage 3
--
-- Normalize, round, detect subnormal, underflow and overflow
-------------------------------------------------------------------------------

  --Adjust exponent
  exp_adj <= "111111" & (not man_ldz2_reg);
  ppadd_3: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => exp2_reg,
      add1_in   => exp_adj,
      carry_in  => '1',
      sum_out   => exp_norm,
      carry_out => exp_norm_carry);

  --Compute shift amount when final result is subnormal (exp_norm-1)
  ppadd_7: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => exp2_reg,
      add1_in   => exp_adj,
      carry_in  => '0',
      sum_out   => exp_norm_m1,
      carry_out => exp_norm_m1_carry);

  exp_norm_m1_sign <= exp_norm_m1(11);

  --Precompute exp + 1
  ppadd_6: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => exp_norm,
      add1_in   => X"000",
      carry_in  => '1',
      sum_out   => expp1,
      carry_out => expp1_carry);
  
  --Adjust shift amount when exponent is less then 0
  ppadd_4: ppadd
    generic map (
      n    => 6,
      logn => 3)
    port map (
      add0_in   => man_ldz2_reg,
      add1_in   => exp_norm_m1(5 downto 0),
      carry_in  => '0',
      sum_out   => man_ldz_adj,
      carry_out => man_ldz_adj_carry);

  left_shift_man: process (double2_reg, man_ldz2_reg, man_ldz_adj,
                           exp_norm_m1_sign, man_to_norm2_reg,
                           in0_nstd2_reg, in1_nstd2_reg,
                           in0_zero2_reg, in1_zero2_reg,
                           dosub2_reg, guard2_reg,
                           sticky2_reg, stickyl2_reg)
    variable in_vect : std_logic_vector(54 downto 0);
    variable amount : std_logic_vector(5 downto 0);
    variable out_vect : std_logic_vector(54 downto 0);
    variable updated_guard : std_ulogic;
    variable updated_sticky : std_ulogic;
  begin  -- process left_shift_man
    if (man_to_norm2_reg(54) = '0') then
      in_vect := man_to_norm2_reg(53 downto 0) & guard2_reg;
    else
      in_vect := man_to_norm2_reg;
    end if;

    if ((in0_nstd2_reg and in1_nstd2_reg) or in0_zero2_reg or in1_zero2_reg) = '1' then
      amount := (others => '0');
    elsif exp_norm_m1_sign = '1' then
      amount := man_ldz_adj;
    else
      amount := man_ldz2_reg;
    end if;
    left_shifter(in_vect, amount, out_vect);

    updated_sticky := sticky2_reg;
    updated_guard  := guard2_reg;
    if man_to_norm2_reg(54) = '0' then
      updated_guard := out_vect(0);
      out_vect := '0' & out_vect(54 downto 1);      
    end if;

    if amount /= "000000" then
        --out_vect(0) := guard2_reg;
        updated_sticky := stickyl2_reg;
    end if;

    guard_norm <= updated_guard;
    if double2_reg = '1' then
      man_to_round <= out_vect;
      sticky_norm <= updated_sticky or updated_guard;
    else
      man_to_round <= "0" & X"0000000" & out_vect(54 downto 29);
      if sticky2_reg = '0' and (out_vect(28 downto 0) = zero(28 downto 0)) then
        sticky_norm <= '0';
      else
        sticky_norm <= '1';
      end if;
    end if;
  end process left_shift_man;

  sticky_handling: process (man_to_round, sticky_norm, double2_reg)
    variable man_msb : std_ulogic;
  begin  -- process sticky_handling
    if double2_reg = '1' then
      man_msb := man_to_round(54);
    else
      man_msb := man_to_round(25);
    end if;
    
    if man_msb = '1' then
      round_factor <= "000" & X"0000000000002";
      ulsb <= man_to_round(2);
      lsb <= man_to_round(1);
      llsb <= man_to_round(0) or sticky_norm;
    else
      round_factor <= "000" & X"0000000000001";
      ulsb <= man_to_round(1);
      lsb <= man_to_round(0);
      llsb <= sticky_norm;        
    end if;

  end process sticky_handling;
  nornd <= ulsb nor llsb;
  
  round_add1_in <= round_factor when nornd = '0' else "000" & X"0000000000000";
  
  ppadd_5: ppadd
    generic map (
      n    => 55,
      logn => 6)
    port map (
      add0_in   => man_to_round,
      add1_in   => round_add1_in,
      carry_in  => '0',
      sum_out   => man_round,
      carry_out => man_round_carry);

  assign_result: process (man_round, man_round_carry, man_to_round,
                          exp_norm, expp1, exp_norm_m1_sign,
                          double2_reg, in0_nstd2_reg, in1_nstd2_reg,
                          in0_inf2_reg, in1_inf2_reg, man_is_zero2_reg,
                          in0_reg2, in1_reg2, in0_NaN2_reg, in1_NaN2_reg)
    variable use_expp1 : std_ulogic;
    variable s0, s1 : std_ulogic;
    variable man_nan : std_logic_vector(51 downto 0);
    variable exp_inf : std_logic_vector(11 downto 0);
    variable hidden_bit : std_ulogic;
  begin  -- process assign_result
    ovf_o <= '0';
    if double2_reg = '1' then
      use_expp1 := man_round_carry or man_round(54);
      hidden_bit := man_round(53);
      s0 := in0_reg2(63);
      s1 := in1_reg2(63);
      if in1_NaN2_reg = '1' then        --QNaN in1
        man_nan := in1_reg2(51 downto 0);
      else                              --QNaN in0
        man_nan := in0_reg2(51 downto 0);
      end if;
      exp_inf := "011111111111";
    else
      use_expp1 := man_round(25);
      hidden_bit := man_round(24);
      s0 := in0_reg2(31);
      s1 := in1_reg2(31);
      if in1_NaN2_reg = '1' then        --QNaN in1
        man_nan := X"0000000" & "0" & in1_reg2(22 downto 0);
      else                              --QNaN in0
        man_nan := X"0000000" & "0" & in0_reg2(22 downto 0);
      end if;
      exp_inf := "000011111111";
    end if;

    if ((in0_NaN2_reg or in1_NaN2_reg) = '1') then -- -NaN (non valid op)
      man_o <= man_nan;
      exp_o <= (others => '1');
    elsif (in0_inf2_reg or in1_inf2_reg) = '1' then  --signed inf
      man_o <= (others => '0');
      exp_o <= (others => '1');
    elsif man_is_zero2_reg = '1' then      -- got a zero
      man_o <= (others => '0');
      exp_o <= (others => '0');
    else
      if use_expp1 = '1' then
        man_o <= man_round(53 downto 2);
        exp_o <= expp1(10 downto 0);
        if (expp1 = exp_inf) then
          ovf_o <= '1';
        end if;
      else
        man_o <= man_round(52 downto 1);
        if (in0_nstd2_reg and in1_nstd2_reg and hidden_bit) = '1' then
        --got normal number from subnormal operands
          exp_o <= expp1(10 downto 0);
        elsif exp_norm_m1_sign = '1' then
          exp_o <= (others => '0');
        else
          exp_o <= exp_norm(10 downto 0);
        end if;
      end if;
    end if;
  end process assign_result;

  sign_assign: process (sign2_reg, man_is_zero2_reg, in0_zero2_reg, sub2_reg,
                        in1_zero2_reg, in0_reg2, in1_reg2, double2_reg,
                        in0_inf2_reg, in1_inf2_reg)
    variable s0, s1 : std_ulogic;
  begin  -- process sign_assign
    nv_o <= '0';

    if double2_reg = '1' then
      s0 := in0_reg2(63);
      s1 := in1_reg2(63);
    else
      s0 := in0_reg2(31);
      s1 := in1_reg2(31);      
    end if;
    if in0_zero2_reg = '1' then
      s0 := '0';
    end if;
    if in1_zero2_reg = '1' then
      s1 := '0';
    end if;

    --if (in1_zero2_reg and in0_zero2_reg) = '1' then  --signed zero
    --  sign_o <= (s0 and s1);
    if (in1_inf2_reg and in0_inf2_reg) = '1' then
      if s0 /= s1 then  -- -NaN
        sign_o <= '1';
        nv_o <= '1';
      else  --signed inf
        sign_o <= s0;
      end if;
    elsif in0_inf2_reg = '1' then       --signed inf
      sign_o <= s0;
    elsif in1_inf2_reg = '1' then       --signed inf
      sign_o <= s1;
    elsif man_is_zero2_reg = '1' then   --got a zero from non zero op.
      sign_o <= '0';
    elsif in0_zero2_reg = '1' then
      sign_o <= sub2_reg xor s1;
    elsif in1_zero2_reg = '1' then
      sign_o <= s0;
    else
      sign_o <= sign2_reg;
    end if;
  end process sign_assign;

  nx_o <= '0';  --TODO!!! Could be inexact...


  -----------------------------------------------------------------------------
  -- Absolute Value (signle precision only)
  -----------------------------------------------------------------------------

  sign_abs <= '0';
  exp_abs  <= "000" & in0_reg2(30 downto 23);
  man_abs  <= x"0000000" & '0' &in0_reg2(22 downto 0);

  -----------------------------------------------------------------------------
  -- Negated Value (signle precision only)
  -----------------------------------------------------------------------------

  sign_neg <= not in0_reg2(31);
  exp_neg  <= "000" & in0_reg2(30 downto 23);
  man_neg  <= x"0000000" & '0' &in0_reg2(22 downto 0);

  -----------------------------------------------------------------------------
  -- Move (signle precision only)
  -----------------------------------------------------------------------------

  sign_mov <= in0_reg2(31);
  exp_mov  <= "000" & in0_reg2(30 downto 23);
  man_mov  <= x"0000000" & '0' &in0_reg2(22 downto 0);


  -----------------------------------------------------------------------------
  -- Compare
  -----------------------------------------------------------------------------

  --TODO: may need to propagate NaNs
  man_cmp <= (others => '0');
  exp_cmp <= (others => '0');
  sign_cmp <= '0';

  condition_codes: process (in0_NaN2_reg,
                            in0_SNaN2_reg, in1_NaN2_reg, in1_SNaN2_reg,
                            in0_nstd2_reg, in1_nstd2_reg, double2_reg,
                            in0_reg2, in1_reg2, exp_diff2_reg, in0_zero2_reg,
                            in1_zero2_reg, larger_operand2_reg)
    variable s0, s1 : std_ulogic;
    variable man0, man1 : std_logic_vector(51 downto 0);
  begin  -- process condition_codes
    if double2_reg = '1' then
      s0 := in0_reg2(63);
      s1 := in1_reg2(63);
      man0 := in0_reg2(51 downto 0);
      man1 := in1_reg2(51 downto 0);
    else
      s0 := in0_reg2(31);
      s1 := in1_reg2(31);
      man0 := "0" & X"0000000" & in0_reg2(22 downto 0);
      man1 := "0" & X"0000000" & in1_reg2(22 downto 0);
    end if;

    if (in0_SNaN2_reg or in1_SNaN2_reg) = '1' then
      nv_cmpe <= '1';
      nv_cmp <= '1';
      cc_out <= "11";
    elsif (in0_NaN2_reg or in1_NaN2_reg) = '1' then
      nv_cmpe <= '1';
      nv_cmp <= '0';
      cc_out <= "11";
    else
      nv_cmp <= '0';
      nv_cmpe <= '0';
      if (in0_zero2_reg and in1_zero2_reg) = '1' then
        cc_out <= "00";                     --EQUAL
      elsif in0_zero2_reg = '1' then
        cc_out <= s1 & (not s1);
      elsif in1_zero2_reg = '1' then
        cc_out <= (not s0) & s0;
      elsif (s0 /= s1) then             --SIGN DIFF
        cc_out <= (not s0) & s0;
      elsif (in0_nstd2_reg xor in1_nstd2_reg) = '1' then  --one NSTD
        cc_out <= (in0_nstd2_reg & (not in0_nstd2_reg)) xor (s0 & s0);
      elsif (exp_diff2_reg /= zero(11 downto 0)) then  --EXP DIFF
        cc_out <= ((not larger_operand2_reg) & larger_operand2_reg) xor (s0 & s0);
      elsif man0 = man1 then            --EQUAL
        cc_out <= "00";
      elsif man0 < man1 then            --MAN DIFF
        cc_out <= "01" xor (s0 & s0);
      else                              --MAN DIFF
        cc_out <= "10" xor (s0 & s0);
      end if;
    end if;
  end process condition_codes;


  -----------------------------------------------------------------------------
  -- Integer to Floating Point Conversion - stage 1
  -- Compute integer 2's complente in case sign is negative
  -- Count leading zeros
  -----------------------------------------------------------------------------

  int_sign <= in0_reg(31);
  int_man_tmp <= in0_reg(31 downto 0);
  int_manb_tmp <= not int_man_tmp;

  --Complement integer
  ppadd_8: ppadd
    generic map (
      n    => 32,
      logn => 5)
    port map (
      add0_in   => int_manb_tmp,
      add1_in   => X"00000000",
      carry_in  => '1',
      sum_out   => int_man_2comp_tmp,
      carry_out => int_man_2comp_tmp_co);

  int_man <= int_man_tmp when int_sign = '0' else int_man_2comp_tmp;

  int_man_ldz_count: process (int_man)
    variable in_vect : std_logic_vector(55 downto 0);
    variable leading_zeros : std_logic_vector(5 downto 0);
  begin  -- process int_man_ldz_count
    in_vect := int_man & X"000000";
    lz_counter(in_vect, leading_zeros);
    int_ldz <= leading_zeros;
  end process int_man_ldz_count;

 itofp_stage1_register: process (clk, rst)
 begin  -- process itofp_stage1_register
   if rst = '0' then                    -- asynchronous reset (active low)
     int_ldz1_reg <= (others => '0');
     int_man1_reg <= (others => '0');
     int_sign1_reg <= '0';
   elsif clk'event and clk = '1' then   -- rising clock edge
     int_ldz1_reg <= int_ldz;
     int_man1_reg <= int_man;
     int_sign1_reg <= int_sign;
   end if;
 end process itofp_stage1_register;

  -----------------------------------------------------------------------------
  -- Integer to Floating Point Conversion - stage 2
  -- Compute unbiased exponent
  -- Shift mantissa accordingly
  -----------------------------------------------------------------------------

  int_ldzb <= "11111" & (not int_ldz1_reg);

  --Exp = 32 - ldz - 1 (carry is zero to account for -1)
  ppadd_9: ppadd
    generic map (
      n    => 11,
      logn => 4)
    port map (
      add0_in   => int_ovf_exp,
      add1_in   => int_ldzb,
      carry_in  => '0',
      sum_out   => int_exp,
      carry_out => int_exp_co);

  shift_integer_to_mantissa: process (int_man1_reg, int_ldz1_reg)
    variable in_vect : std_logic_vector(54 downto 0);
    variable amount : std_logic_vector(5 downto 0);
    variable out_vect : std_logic_vector(54 downto 0);
  begin  -- process shift_integer_to_mantissa
    in_vect := int_man1_reg & "000" & X"00000";
    amount := int_ldz1_reg;
    left_shifter(in_vect, amount, out_vect);
    --Keep hidden bit for now. Needed for rounding
    int_man_shift <= out_vect(54 downto 23);
  end process shift_integer_to_mantissa;

  itofp_stage2_register: process (clk, rst)
  begin  -- process itofp_stage2_register
    if rst = '0' then                   -- asynchronous reset (active low)
      int_exp2_reg <= (others => '0');
      int_man2_reg <= (others => '0');
      int_sign2_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      int_exp2_reg <= int_exp;
      int_man2_reg <= int_man_shift;
      int_sign2_reg <= int_sign1_reg;
    end if;
  end process itofp_stage2_register;

  -----------------------------------------------------------------------------
  -- Integer to Floating Point Conversion - stage 3
  -- Compute biased exponent and biased exp + 1
  -- If single, then round
  -----------------------------------------------------------------------------

  int_bias <= bias_double when double2_reg = '1' else bias_single;
  int_sticky <= '0' when int_man2_reg(7 downto 0) = zero(7 downto 0) else '1';
  
  --compute biased exponent
  ppadd_10: ppadd
    generic map (
      n    => 11,
      logn => 4)
    port map (
      add0_in   => int_exp2_reg,
      add1_in   => int_bias,
      carry_in  => '0',
      sum_out   => int_bexp,
      carry_out => int_bexp_co);

  --precompute also biased exponent +1
  ppadd_11: ppadd
    generic map (
      n    => 11,
      logn => 4)
    port map (
      add0_in   => int_exp2_reg,
      add1_in   => int_bias,
      carry_in  => '1',
      sum_out   => int_bexpp1,
      carry_out => int_bexpp1_co);

  int_single_round_factor <= int_single_round_wsticky when int_man2_reg(8) = '0' else
                             int_single_round_nsticky;

  --round mantissa for single precision conversion
  ppadd_12: ppadd
    generic map (
      n    => 32,
      logn => 5)
    port map (
      add0_in   => int_man2_reg,
      add1_in   => int_single_round_factor,
      carry_in  => '0',
      sum_out   => int_man_single_round,
      carry_out => int_man_single_round_co);

  itofp_out_assign: process (int_man2_reg, int_man_single_round,
                             int_bexp, int_bexpp1, double2_reg,
                             int_man_single_round_co, in0_zero2_reg)
  begin  -- process itofp_out_assign
    if in0_zero2_reg = '1' then
      man_itofp <= (others => '0');
      exp_itofp <= (others => '0');
    elsif double2_reg = '1' then
      man_itofp <= int_man2_reg(30 downto 0) & X"00000" & '0';
      exp_itofp <= int_bexp;
    else
      if int_man_single_round_co = '1' then
        man_itofp <= x"0000000" & "0" & int_man_single_round(31 downto 9);
        exp_itofp <= int_bexpp1;
      else
        man_itofp <= x"0000000" & "0" & int_man_single_round(30 downto 8);
        exp_itofp <= int_bexp;
      end if;
    end if;
  end process itofp_out_assign;

  sign_itofp <= int_sign2_reg;
  nx_itofp <= (not double2_reg) and int_sticky;

  -----------------------------------------------------------------------------
  -- Floating Point to Integer (RND to zero) TODO ROUNDING WITH RND
  -- Check exp for INT_MAX/INT_MIN or zero
  -- Compute shift amount (31-exp)
  -----------------------------------------------------------------------------

  fptoi_exp0 <= '0' & in0_reg(62 downto 52) when double_reg = '1' else
                "0000" & in0_reg(30 downto 23);
  fptoi_exp0b <= not fptoi_exp0;
  
  check_exp: process (fptoi_exp0, double_reg)
  begin  -- process check_exp
    fptoi_ovf <= '0';
    fptoi_udf <= '0';
    if double_reg = '1' then
      if fptoi_exp0 > fptoi_double_ovf then
        fptoi_ovf <= '1';
      elsif fptoi_exp0 < fptoi_double_udf then
        fptoi_udf <= '1';
      end if;
    else
      if fptoi_exp0 > fptoi_single_ovf then
        fptoi_ovf <= '1';
      elsif fptoi_exp0 < fptoi_single_udf then
        fptoi_udf <= '1';
      end if;
    end if;
  end process check_exp;

  fptoi_base_exp <= fptoi_double_ovf when double_reg = '1' else fptoi_single_ovf;
  -- 30 - exp; need to shift 1 more
  ppadd_13: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => fptoi_base_exp,
      add1_in   => fptoi_exp0b,
      carry_in  => '1',
      sum_out   => fptoi_shift,
      carry_out => fptoi_shift_co);

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      fptoi_ovf1_reg <= '0';
      fptoi_udf1_reg <= '0';
      fptoi_shift1_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      fptoi_udf1_reg <= fptoi_udf;
      fptoi_ovf1_reg <= fptoi_ovf;
      fptoi_shift1_reg <= fptoi_shift(5 downto 0);
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Floating Point to Integer (RND to zero) Stage 2
  -- Shift mantissa with hidden bit
  -----------------------------------------------------------------------------

  --TODO: ROUNDING SHOULD HAPPEN HERE!!!!
  shift_mantissa_w_hidden: process (in0_reg1, double1_reg, fptoi_shift1_reg)
    variable in_vect : std_logic_vector(54 downto 0);
    variable amount : std_logic_vector(5 downto 0);
    variable out_vect : std_logic_vector(54 downto 0);
    variable sticky_bit, dummy2, dummy3 : std_ulogic;
  begin  -- process shift_mantissa_w_hidden
    amount := fptoi_shift1_reg;
    if double1_reg = '1' then
      in_vect := "1" & in0_reg1(51 downto 0) & "00";
    else
      in_vect := "1" & in0_reg1(22 downto 0) & "000" & X"0000000";
    end if;
    right_shifter_sticky(in_vect, amount, '0', out_vect, sticky_bit, dummy2, dummy3);
    fptoi_man <= '0' & out_vect(54 downto 24);
    fptoi_sticky <= sticky_bit or out_vect(23);
  end process shift_mantissa_w_hidden;

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      fptoi_ovf2_reg <= '0';
      fptoi_udf2_reg <= '0';
      fptoi_man2_reg <= (others => '0');
      fptoi_sticky2_reg <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      fptoi_ovf2_reg <= fptoi_ovf1_reg;
      fptoi_udf2_reg <= fptoi_udf1_reg;
      fptoi_man2_reg <= fptoi_man;
      fptoi_sticky2_reg <= fptoi_sticky;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Floating Point to Integer (RND to zero) Stage 3
  -- Complement result if negative or assign INT_MAX/INT_MIN/zero
  -----------------------------------------------------------------------------

  fptoi_sign <= in0_reg2(63) when double2_reg = '1' else in0_reg2(31);

  --Complement result
  fptoi_manb <= not fptoi_man2_reg;
  ppadd_14: ppadd
    generic map (
      n    => 32,
      logn => 5)
    port map (
      add0_in   => fptoi_manb,
      add1_in   => X"00000000",
      carry_in  => '1',
      sum_out   => fptoi_man_2comp,
      carry_out => fptoi_man_2comp_co);

  fptoi_assign_result: process(fptoi_man2_reg, fptoi_man_2comp,
                               fptoi_sticky2_reg, fptoi_sign,
                               in0_zero2_reg, in0_inf2_reg,
                               in0_NaN2_reg, in0_SNaN2_reg,
                               fptoi_ovf2_reg, fptoi_udf2_reg)
  begin  -- process fptoi_assign_result
    if (in0_NaN2_reg or in0_SNaN2_reg) = '1' then
      result_int <= INT_MIN;
      nv_fptoi <= '1';
      nx_fptoi <= '0';
    elsif (in0_inf2_reg or fptoi_ovf2_reg) = '1' then
      nv_fptoi <= '0';
      nx_fptoi <= '1';
      if fptoi_sign = '0' then
        result_int <= INT_MAX;          --INTEL uses INT_MIN, why?
      else
        result_int <= INT_MIN;
      end if;
    elsif in0_zero2_reg = '1' then
      nv_fptoi <= '0';
      nx_fptoi <= '0';
      result_int <= (others => '0');
    elsif fptoi_udf2_reg = '1' then
      nv_fptoi <= '0';
      nx_fptoi <= '1';
      result_int <= (others => '0');
    else
      nv_fptoi <= '0';
      nx_fptoi <= fptoi_sticky2_reg;
      if fptoi_sign = '0' then
        result_int <= fptoi_man2_reg;
      else
        result_int <= fptoi_man_2comp;
      end if;
    end if;    
  end process fptoi_assign_result;

  -----------------------------------------------------------------------------
  -- Fp to Fp Stage 1
  -- exp - bias
  -- round mantissa for D to S
  -- use leading zeros for subnormal S to D
  -----------------------------------------------------------------------------

  fptofp_bexp_in <= '0' & in0_reg(62 downto 52) when double_reg = '0' else
                    "0000" & in0_reg(30 downto 23);

  fptofp_bias_in <= "1" & nbias_double when double_reg = '0' else
                    "1" & nbias_single;

  --exp - bias
  ppadd_15: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => fptofp_bexp_in,
      add1_in   => fptofp_bias_in,
      carry_in  => '0',
      sum_out   => fptofp_exp_in,
      carry_out => fptofp_exp_in_co);

  fptofp_sub_stod_add0 <= '1' & nbias_single;
  fptofp_sub_stod_add1 <= "111111" & (not man0_ldz_reg);
  -- -bias -ldz
  ppadd_18: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => fptofp_sub_stod_add0,
      add1_in   => fptofp_sub_stod_add1,
      carry_in  => '1',
      sum_out   => fptofp_sub_exp_in,
      carry_out => fptofp_sub_exp_in_co);

  fptofp_man_in <= "1" & in0_reg(51 downto 0);

  --Consider sticky!
  fptofp_round_factor <= X"0000008000000" & '0' when fptofp_man_in(29) = '1' else
                         X"0000007ffffff" & '1';
  
  --round mantissa
  ppadd_16: ppadd
    generic map (
      n    => 53,
      logn => 6)
    port map (
      add0_in   => fptofp_man_in,
      add1_in   => fptofp_round_factor,
      carry_in  => '0',
      sum_out   => fptofp_man_round,
      carry_out => fptofp_use_expp1);

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      fptofp_use_expp11_reg <= '0';
      fptofp_man_round1_reg <= (others => '0');
      fptofp_exp_in1_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      fptofp_use_expp11_reg <= fptofp_use_expp1;
      fptofp_man_round1_reg <= fptofp_man_round;
      if in0_nstd_reg = '1' and double_reg = '1' then
        fptofp_exp_in1_reg <= fptofp_sub_exp_in;
      else
        fptofp_exp_in1_reg <= fptofp_exp_in;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Fp to Fp Stage 2
  -- exp + bias (+1)
  -- shift mantissa for subnormal S to D
  -----------------------------------------------------------------------------

  fptofp_bias_out <= '0' & bias_single when double1_reg = '0' else
                     '0' & bias_double;

  fptofp_bexp_out_ci <= fptofp_use_expp11_reg and (not double1_reg);
  
  ppadd_17: ppadd
    generic map (
      n    => 12,
      logn => 4)
    port map (
      add0_in   => fptofp_exp_in1_reg,
      add1_in   => fptofp_bias_out,
      carry_in  => fptofp_bexp_out_ci,
      sum_out   => fptofp_bexp_out,
      carry_out => fptofo_bexp_out_co);

  shift_left_subnormal_man: process (in0_reg1, man0_ldz1_reg)
    variable in_vect : std_logic_vector(54 downto 0);
    variable amount : std_logic_vector(5 downto 0);
    variable out_vect : std_logic_vector(54 downto 0);
  begin  -- process shift_left_subnormal_man
    amount := man0_ldz1_reg;
    in_vect := X"00000000" & in0_reg1(22 downto 0);
    left_shifter(in_vect, amount, out_vect);
    fptofp_man_shift <= out_vect(21 downto 0) & '0';
  end process shift_left_subnormal_man;
  
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      fptofp_man_round2_reg <= (others => '0');
      fptofp_use_expp12_reg <= '0';
      fptofp_bexp_out2_reg <= (others => '0');
      fptofp_man_shift2_reg <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      fptofp_man_round2_reg <= fptofp_man_round1_reg;
      fptofp_use_expp12_reg <= fptofp_use_expp11_reg;
      fptofp_bexp_out2_reg <= fptofp_bexp_out;
      fptofp_man_shift2_reg <= fptofp_man_shift;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Fp to Fp Stage 3
  -- Check for OVF and UDF or subnormal
  -----------------------------------------------------------------------------

  dtos_exact <= '1' when in0_reg2(28 downto 0) = zero(28 downto 0) else '0';

  shift_right_subnormal_man: process (in0_reg2, fptofp_bexp_out2_reg, dtos_exact)
    variable in_vect    : std_logic_vector(54 downto 0);
    variable amount     : std_logic_vector(5 downto 0);
    variable out_vect   : std_logic_vector(54 downto 0);
    variable sticky_bit : std_ulogic;
    variable sticky_low : std_ulogic;
    variable guard_bit  : std_ulogic;
  begin  -- process shift_right_subnormal_man
    in_vect := X"00000001" & in0_reg2(51 downto 29);
    amount := not fptofp_bexp_out2_reg(5 downto 0);
    right_shifter_sticky(in_vect, amount, '0', out_vect, sticky_bit, sticky_low, guard_bit);
    if fptofp_bexp_out2_reg = zero(11 downto 0) then
      dtos_exact_sub <= dtos_exact and (not in0_reg2(29));
      fptofp_man_sub <= "01" & in0_reg2(51 downto 29);
      fptofp_res_nstd <= '1';
      fptofp_man_sub_ci <= (not dtos_exact) or in0_reg2(30);
    else
      dtos_exact_sub <= dtos_exact and (not sticky_bit) and (not out_vect(0)) and (not out_vect(1));
      fptofp_man_sub <= "0" & out_vect(24 downto 1);
      fptofp_res_nstd <= fptofp_bexp_out2_reg(11);
      fptofp_man_sub_ci <= (not dtos_exact) or sticky_bit or out_vect(1);
    end if;
  end process shift_right_subnormal_man;

  -- Round man_sub
  ppadd_19: ppadd
    generic map (
      n    => 25,
      logn => 5)
    port map (
      add0_in   => fptofp_man_sub,
      add1_in   => zero(24 downto 0),
      carry_in  => fptofp_man_sub_ci,
      sum_out   => fptofp_man_sub_round,
      carry_out => fptofp_man_sub_co);
  
  fptofp_assign_out: process (fptofp_man_round2_reg, fptofp_use_expp12_reg,
                              fptofp_bexp_out2_reg, fptofp_man_shift2_reg,
                              double2_reg, in0_reg2, in0_zero2_reg,
                              in0_nstd2_reg, in0_inf2_reg, in0_NaN2_reg,
                              in0_SNaN2_reg, dtos_exact, dtos_exact_sub,
                              fptofp_man_sub_round, fptofp_res_nstd)
    variable man_nan : std_logic_vector(51 downto 0);
  begin  -- process fptofp_assign_out
    if double2_reg = '1' then           --Single to Double
      man_nan := "1" & in0_reg2(21 downto 0) & X"0000000" & "0";
    else
      man_nan := X"0000000" & "01" & in0_reg2(50 downto 29);
    end if;
    
    if (in0_NaN2_reg or in0_SNaN2_reg) = '1' then
      nv_fptofp <= in0_SNaN2_reg;
      nx_fptofp <= '0';
      ovf_fptofp <= '0';
      udf_fptofp <= '0';
      man_fptofp <= man_nan;
      exp_fptofp <= (others => '1');
    elsif in0_inf2_reg = '1' then
      nv_fptofp <= '0';
      nx_fptofp <= '0';
      ovf_fptofp <= '0';
      udf_fptofp <= '0';
      man_fptofp <= (others => '0');
      exp_fptofp <= (others => '1');
    elsif in0_zero2_reg = '1' then
      nv_fptofp <= '0';
      nx_fptofp <= '0';
      ovf_fptofp <= '0';
      udf_fptofp <= '0';
      man_fptofp <= (others => '0');
      exp_fptofp <= (others => '0');
    elsif in0_nstd2_reg = '1' then
      nv_fptofp <= '0';
      if double2_reg = '1' then
        nx_fptofp <= '0';
        ovf_fptofp <= '0';
        udf_fptofp <= '0';
        man_fptofp <= fptofp_man_shift2_reg & "0" & X"0000000";
        exp_fptofp <= fptofp_bexp_out2_reg(10 downto 0);
      else  --double nstd to single underflows
        nx_fptofp <= '1';
        ovf_fptofp <= '0';
        udf_fptofp <= '1';
        man_fptofp <= (others => '0');
        exp_fptofp <= (others => '0');
      end if;
    else
      nv_fptofp <= '0';
      if double2_reg = '1' then         --Single to double
        nx_fptofp <= '0';
        ovf_fptofp <= '0';
        udf_fptofp <= '0';
        man_fptofp <= in0_reg2(22 downto 0) & "0" & X"0000000";
        exp_fptofp <= fptofp_bexp_out2_reg(10 downto 0);
      else                              --Double to single
        if fptofp_bexp_out2_reg(11) = '1' and (fptofp_bexp_out2_reg < ("1" & expudf)) then --UDF
          nx_fptofp <= '1';
          ovf_fptofp <= '0';
          udf_fptofp <= '1';
          man_fptofp <= (others => '0');
          exp_fptofp <= (others => '0');
        elsif fptofp_bexp_out2_reg(11) = '0' and (fptofp_bexp_out2_reg > ("0" & expovf)) then --OVF
          nx_fptofp <= '1';
          ovf_fptofp <= '1';
          udf_fptofp <= '0';
          man_fptofp <= (others => '0');
          exp_fptofp <= (others => '1');
        elsif fptofp_res_nstd = '1' then
          nx_fptofp <= dtos_exact_sub;
          ovf_fptofp <= '0';
          udf_fptofp <= '0';
          if fptofp_man_sub_round(24) = '1' then
            man_fptofp <= "0" & X"0000000" & fptofp_man_sub_round(24 downto 2);
          else
            man_fptofp <= "0" & X"0000000" & fptofp_man_sub_round(23 downto 1);
          end if;
          exp_fptofp <= (others => '0');
        else
          ovf_fptofp <= '0';
          udf_fptofp <= '0';
          if fptofp_use_expp12_reg = '1' then
            nx_fptofp <= dtos_exact and (not in0_reg2(29));
            man_fptofp <= "0" & X"0000000" & fptofp_man_round2_reg(52 downto 30);
          else
            nx_fptofp <= dtos_exact;
            man_fptofp <= "0" & X"0000000" & fptofp_man_round2_reg(51 downto 29);
          end if;
          exp_fptofp <= fptofp_bexp_out2_reg(10 downto 0);
        end if;
      end if;
    end if;
  end process fptofp_assign_out;

  sign_fptofp <= in0_reg2(31) when double2_reg = '1' else in0_reg2(63);

end rtl;
