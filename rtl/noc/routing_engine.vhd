-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

--/*
-- * Module: routing_engine
-- * Description: Input Routing Engine.  
-- *              Placed at each input it gives the output port the worm must be forwarded
-- *              through for the next hop (routing look-ahead). The routing algorithm is XY Dimension Order.
-- *              This algorithm is proved to be deadlock-free over a Mesh topology.
-- * Author: Michele Petracca
-- * $ID$
-- * 
-- */

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity routing_engine is
	generic(
		loc_port		:  integer
--		localx	: std_logic_vector(2 downto 0);
--		localy	: std_logic_vector(2 downto 0)
        );

	port(
		clk		: in std_logic;
		rst		: in std_logic;

                localx          : in std_logic_vector(2 downto 0);
                localy          : in std_logic_vector(2 downto 0);

		--current hop routing; one-hot encoding
		destination_port : in std_logic_vector(4 downto 0);
		destx		: in std_logic_vector(2 downto 0);	
		desty		: in std_logic_vector(2 downto 0);

		--next hop routing; one-hot encoded
		next_routing	: out std_logic_vector(4 downto 0)); 
end routing_engine;
architecture behavior of routing_engine is

type coordinate_t is array (0 to 3) of std_logic_vector(2 downto 0);
signal next_localx, next_localy : coordinate_t;

type routing_t is array (0 to 3) of std_logic_vector(4 downto 0);
signal next_hop_routing : routing_t;

signal masked_destination_port : std_logic_vector(4 downto 0);

begin

	--evaluation of the coordinates of the next hop
	MASKING: for i in 0 to 4 generate
	--begin
		MSK0: if (i = loc_port) generate
		--begin 
			masked_destination_port(i) <= '0';
		end generate;	
		MSK1: if (i /= loc_port) generate 
		--begin 
			masked_destination_port(i) <= destination_port(i);
		end generate;
	end generate;

	--evaluation of the coordinates of the next hop
	process(rst,clk)
	begin
		if rst = '0' then
                  next_localx <= (others => (others => '0'));
                  next_localy <= (others => (others => '0'));
                  --next_localx(0) <= localx;
			--next_localx(1) <= localx;
			--next_localx(2)(2) <= (localx(2) and (localx(1) or localx(0)));
			--next_localx(2)(1) <= not (localx(1) xor localx(0));
			--next_localx(2)(0) <= (not localx(0));
			--next_localx(3)(2) <= (localx(2) or (localx(1) and localx(0)));
			--next_localx(3)(1) <= (localx(1) xor localx(0));
			--next_localx(3)(0) <= (not localx(0));
			--next_localy(0)(2) <= (localy(2) and (localy(1) or localy(0)));
			--next_localy(0)(1) <= not (localy(1) xor localy(0));
			--next_localy(0)(0) <= (not localy(0));
			--next_localy(1)(2) <= (localy(2) or (localy(1) and localy(0)));
			--next_localy(1)(1) <= (localy(1) xor localy(0));
			--next_localy(1)(0) <= (not localy(0));
			--next_localy(2) <= localy;
			--next_localy(3) <= localy;
		elsif clk'event and clk = '1' then
			next_localx(0) <= localx;
			next_localx(1) <= localx;
			next_localx(2)(2) <= (localx(2) and (localx(1) or localx(0)));
			next_localx(2)(1) <= not (localx(1) xor localx(0));
			next_localx(2)(0) <= (not localx(0));
			next_localx(3)(2) <= (localx(2) or (localx(1) and localx(0)));
			next_localx(3)(1) <= (localx(1) xor localx(0));
			next_localx(3)(0) <= (not localx(0));
			next_localy(0)(2) <= (localy(2) and (localy(1) or localy(0)));
			next_localy(0)(1) <= not (localy(1) xor localy(0));
			next_localy(0)(0) <= (not localy(0));
			next_localy(1)(2) <= (localy(2) or (localy(1) and localy(0)));
			next_localy(1)(1) <= (localy(1) xor localy(0));
			next_localy(1)(0) <= (not localy(0));
			next_localy(2) <= localy;
			next_localy(3) <= localy;
		end if;
	end process;

	process(next_localy(0), desty)
	begin
		if desty /= next_localy(0) then
			next_hop_routing(0) <= "00001";
		else 
			next_hop_routing(0) <= "10000";
		end if;
	end process;

	process(next_localy(1), desty)
	begin
		if desty /= next_localy(1) then
		      next_hop_routing(1) <= "00010";
		else 
			next_hop_routing(1) <= "10000";
		end if;
	end process;

	process(next_localx(2), next_localy(2), desty, destx)
	begin
		if destx /= next_localx(2) then
			next_hop_routing(2) <= "00100";
		elsif desty = next_localy(2) then
			next_hop_routing(2) <= "10000";
		elsif desty > next_localy(2) then
			next_hop_routing(2) <= "00010";
		else 
			next_hop_routing(2) <= "00001";
		end if;
	end process;

	process(next_localx(3), next_localy(3), desty, destx)
	begin
		if destx /= next_localx(3) then
			next_hop_routing(3) <= "01000";
		elsif desty = next_localy(3) then
			next_hop_routing(3) <= "10000";
		elsif desty > next_localy(3) then
			next_hop_routing(3) <= "00010";
		else 
			next_hop_routing(3) <= "00001";
		end if;
	end process;

	--selection of next_hop_routing based on current routing
	process(masked_destination_port, next_hop_routing)
	begin
		case masked_destination_port is
			when "00001" =>
				next_routing <= next_hop_routing(0);

			when "00010" =>
				next_routing <= next_hop_routing(1);

			when "00100" =>
				next_routing <= next_hop_routing(2);

			when "01000" =>
				next_routing <= next_hop_routing(3);

			when others =>
				next_routing <= next_hop_routing(0);
			
		end case;
	end process;

end behavior;
