-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity rtr_arbitration_engine is
	port(
		clk		: in std_logic;
		rst		: in std_logic;

		--requests registers; one-hot encoded like the parameter
		requests	: in std_logic_vector(3 downto 0);

		shift_priority : in std_logic;
		update_priority : in std_logic;
		lock_priority : in std_logic;

		valid_no_collision : out std_logic;
		valid_collision	 : out std_logic;
		--grant registers; one-hot encoded like the parameter
		grant_no_collision : out std_logic_vector(3 downto 0); 
		grant_collision : out std_logic_vector(3 downto 0));
end rtr_arbitration_engine;

architecture behavior of rtr_arbitration_engine is

signal no_collision, collision_d, new_requests : std_logic;

type masked_request_t is array (0 to 3) of std_logic_vector(3 downto 0);
signal masked_request : masked_request_t;
signal request_match, grant_int, saved_grant : std_logic_vector(3 downto 0);
signal enable_d : std_logic;

signal grant_tmp, grant_tmp_debug, grant_i, final_grant_tmp : std_logic_vector(3 downto 0);

type priority_t is array (0 to 3) of std_logic_vector(3 downto 0);
--signal priority_mask : std_logic_vector(3 downto 0);
signal priority_mask : priority_t;

signal priority_locked : std_logic;

signal arbitration_first_stage : priority_t;
signal arbitration_second_stage : priority_t;



begin
  valid_collision <= '0';
  grant_collision <= (others => '0');

	new_requests <= requests(0) or requests(1) or requests(2) or requests(3);
	
	valid_no_collision <= new_requests and (not priority_locked);
	grant_no_collision <= grant_tmp and requests;
  
	process(clk,rst)
	begin
		if rst = '0' then
			priority_mask(0) <= "1110";
			priority_mask(1) <= "1100";
			priority_mask(2) <= "1000";
			priority_mask(3) <= "0000";
		elsif clk = '1' and clk'event then
			if shift_priority = '1' then
				if (grant_tmp(0) and requests(0)) = '1' then				
					priority_mask(0)(0) <= '1';
					priority_mask(1)(0) <= '1';
					priority_mask(2)(0) <= '1';
					priority_mask(3)(0) <= '1';
					priority_mask(0) <= (others => '0');
				end if;
				if (grant_tmp(1) and requests(1)) = '1' then				
					priority_mask(0)(1) <= '1';
					priority_mask(1)(1) <= '1';
					priority_mask(2)(1) <= '1';
					priority_mask(3)(1) <= '1';
					priority_mask(1) <= (others => '0');
				end if;
				if (grant_tmp(2) and requests(2)) = '1' then				
					priority_mask(0)(2) <= '1';
					priority_mask(1)(2) <= '1';
					priority_mask(2)(2) <= '1';
					priority_mask(3)(2) <= '1';
					priority_mask(2) <= (others => '0');
				end if;
				if (grant_tmp(3) and requests(3)) = '1' then				
					priority_mask(0)(3) <= '1';
					priority_mask(1)(3) <= '1';
					priority_mask(2)(3) <= '1';
					priority_mask(3)(3) <= '1';
					priority_mask(3) <= (others => '0');
				end if;				
			end if;
		end if;
	end process;

	priority_locked <= lock_priority;	
	
	TMP_GRANT: for i in 0 to 3 generate
		TMP_GRANT_2: for j in 0 to 3 generate
			arbitration_first_stage(i)(j) <= requests(j) and priority_mask(j)(i);
		end generate;
	
		TMP_GRANT_3: for l in 0 to 1 generate
			arbitration_second_stage(i)(l) <= arbitration_first_stage(i)(2*l) nor arbitration_first_stage(i)(2*l + 1);
		end generate;
	
		grant_tmp(i) <= arbitration_second_stage(i)(0) and arbitration_second_stage(i)(1);
		grant_tmp_debug(i) <= ((requests(0) and priority_mask(0)(i)) nor (requests(1) and priority_mask(1)(i))) and ((requests(2) and priority_mask(2)(i)) nor (requests(3) and priority_mask(3)(i)));	
	end generate TMP_GRANT;

	
end behavior;
