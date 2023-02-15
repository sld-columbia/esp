-- Copyright (c) 2011-2023 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

--/*
-- * Module: router
-- * Description: 5x5 router
-- *              The router has 1 port attached to the processor and 4 ports to route
-- *              data. The routing algorithm is XY Dimension Order.
-- *              The router uses a worm-hole flow-control at network level
-- *              and an ACK/NACK flow control at link level. It can be interfaced with
-- *              single state Relay Stations.
-- *              The router implements routing look-ahead, performing routing for the following hop
-- *              and carrying the routing result into the head flit of the worm.
-- *              In case of incoming head flit directed to a free output without contention
-- *              the flit is forwarded in a single clock cycle (low load hypotesys). In all the other
-- *              scenarios the worm is forwarded in two clock cycles, resolving contentions during
-- *              the added cycle.
-- * Author: Michele Petracca
-- * $ID$
-- * 
-- Mapping:
-- 0 = North
-- 1 = South
-- 2 = West
-- 3 = East
-- 4 = Processor
-- */

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity router is
	generic(
		flow_control : integer := 0; --0 = AN; 1 = CB
		width : integer := 34;
		depth : integer := 4;
                ports : std_logic_vector(4 downto 0) := "11111"
--                localx  : std_logic_vector(2 downto 0);
--                localy  : std_logic_vector(2 downto 0)

	);
	port(
		clk		: in std_logic;
		rst		: in std_logic;

--                CONST_ports     : in std_logic_vector(4 downto 0);
                CONST_localx    : in std_logic_vector(2 downto 0);
                CONST_localy    : in std_logic_vector(2 downto 0);

		data_n_in	: in std_logic_vector(width-1 downto 0);
		data_s_in	: in std_logic_vector(width-1 downto 0);
		data_w_in	: in std_logic_vector(width-1 downto 0);
		data_e_in	: in std_logic_vector(width-1 downto 0);
		data_p_in	: in std_logic_vector(width-1 downto 0);

		data_void_in	: in std_logic_vector(4 downto 0);
		stop_in		: in std_logic_vector(4 downto 0);

		data_n_out	: out std_logic_vector(width-1 downto 0);
		data_s_out	: out std_logic_vector(width-1 downto 0);
		data_w_out	: out std_logic_vector(width-1 downto 0);
		data_e_out	: out std_logic_vector(width-1 downto 0);
		data_p_out	: out std_logic_vector(width-1 downto 0);

		data_void_out	: out std_logic_vector(4 downto 0);
		stop_out		: out std_logic_vector(4 downto 0));
end router;



architecture behavior of router is

component bypassable_queue
	generic(
		depth : integer;
		width : integer
--		localx	: std_logic_vector(2 downto 0);
--		localy	: std_logic_vector(2 downto 0)
        );

	port(
		clk		: in std_logic;
		rst		: in std_logic;

--                CONST_localx    : in std_logic_vector(2 downto 0);
--                CONST_localy    : in std_logic_vector(2 downto 0);

		rdreq		: in std_logic;
		wrreq		: in std_logic;
		data_in 	: in std_logic_vector(width-1 downto 0);

		--request registers
		empty		: out std_logic;
		full		: out std_logic;
		data_out 	: out std_logic_vector(width-1 downto 0);
		routing_out	: out std_logic_vector(4 downto 0));
end component;

component nobypassable_queue
	generic(
		depth : integer;
		width : integer
--		localx	: std_logic_vector(2 downto 0);
--		localy	: std_logic_vector(2 downto 0)
        );

	port(
		clk		: in std_logic;
		rst		: in std_logic;

--                CONST_localx    : in std_logic_vector(2 downto 0);
--                CONST_localy    : in std_logic_vector(2 downto 0);

		rdreq		: in std_logic;
		wrreq		: in std_logic;
		data_in 	: in std_logic_vector(width-1 downto 0);

		--request registers
		empty		: out std_logic;
		full		: out std_logic;
		data_out 	: out std_logic_vector(width-1 downto 0);
		routing_out	: out std_logic_vector(4 downto 0));
end component;

component routing_engine
	generic(
		loc_port		: integer
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
end component;

component rtr_arbitration_engine
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
end component;

type data_t is array (0 to 4) of std_logic_vector(width-1 downto 0);
signal data_in, data_out, data_out_crossbar, fifo_head, last_flit : data_t;

type routing_matching_t is array (0 to 4) of std_logic_vector(4 downto 0);
signal saved_routing_request, final_routing_request, routing_request, next_hop_routing, enhanc_routing_configuration : routing_matching_t;

type transp_routing_matching_t is array (0 to 4) of std_logic_vector(3 downto 0);
signal transp_final_routing_request, grant_no_collision, grant_collision, saved_grant_collision, saved_grant_no_collision, routing_configuration, saved_routing_configuration : transp_routing_matching_t;

type routing_clr_t is array (0 to 4) of std_logic_vector(4 downto 0);
signal rd_fifo, routing_clr : routing_clr_t;
signal rd_fifo_output : std_logic_vector(4 downto 0);


--type state_t is (idle, read_ctrl_msg, read);
type state_t_a is array (0 to 4) of std_logic_vector(1 downto 0);
signal state, new_state : state_t_a;

signal in_unvalid_flit, out_unvalid_flit : std_logic_vector(4 downto 0);

signal rd_fifo_or : std_logic_vector(4 downto 0);

signal full, empty, wr_fifo : std_logic_vector(4 downto 0);
signal shift_priority, update_priority, lock_priority, data_void_in_d : std_logic_vector(4 downto 0);

signal stop_out_i, data_void_out_i, valid_no_collision, valid_collision, last_flit_tail : std_logic_vector(4 downto 0);

--constant depth : integer := 2;
--constant width : integer := 18;

constant idle : std_logic_vector(1 downto 0) := "00";
constant read_ctrl_msg : std_logic_vector(1 downto 0) := "01";
constant read : std_logic_vector(1 downto 0) := "10";
constant read_tail : std_logic_vector(1 downto 0) := "11";

constant max_credits : integer := 6;
subtype credits_tt is integer range 0 to depth;
type credits_t is array (0 to 4) of credits_tt;
signal credits : credits_t;

signal forwarded_tail, forwarding_tail, forwarding_head, forwarded_head, forwarding_under_progress : std_logic_vector(4 downto 0);

signal insert_lookahead_routing : std_logic_vector(4 downto 0);

attribute keep : string;
attribute keep of data_n_in	: signal is "true";
attribute keep of data_s_in	: signal is "true";
attribute keep of	data_w_in	: signal is "true";
attribute keep of	data_e_in	: signal is "true";
attribute keep of	data_p_in	: signal is "true";
attribute keep of	data_void_in	: signal is "true";
attribute keep of	stop_in		: signal is "true";
attribute keep of	data_n_out	: signal is "true";
attribute keep of	data_s_out	: signal is "true";
attribute keep of	data_w_out	: signal is "true";
attribute keep of	data_e_out	: signal is "true";
attribute keep of	data_p_out	: signal is "true";
attribute keep of data_void_out	: signal is "true";
attribute keep of	stop_out		: signal is "true";
attribute keep of	data_in		: signal is "true";
attribute keep of	data_out		: signal is "true";
attribute keep of	data_out_crossbar		: signal is "true";
attribute keep of	fifo_head		: signal is "true";
attribute keep of	last_flit		: signal is "true";
attribute keep of	saved_routing_request		: signal is "true";
attribute keep of	final_routing_request		: signal is "true";
attribute keep of	routing_request		: signal is "true";
attribute keep of	next_hop_routing		: signal is "true";
attribute keep of	enhanc_routing_configuration		: signal is "true";
attribute keep of transp_final_routing_request : signal is "true";
attribute keep of grant_no_collision : signal is "true";
attribute keep of grant_collision : signal is "true";
attribute keep of saved_grant_collision : signal is "true";
attribute keep of saved_grant_no_collision : signal is "true";
attribute keep of routing_configuration : signal is "true";
attribute keep of saved_routing_configuration : signal is "true";
attribute keep of rd_fifo : signal is "true";
attribute keep of routing_clr : signal is "true";
attribute keep of rd_fifo_output : signal is "true";
attribute keep of state : signal is "true";
attribute keep of new_state : signal is "true";
attribute keep of in_unvalid_flit : signal is "true";
attribute keep of out_unvalid_flit : signal is "true";
attribute keep of rd_fifo_or : signal is "true";
attribute keep of full : signal is "true";
attribute keep of empty : signal is "true";
attribute keep of wr_fifo : signal is "true";
attribute keep of shift_priority : signal is "true";
attribute keep of update_priority : signal is "true";
attribute keep of lock_priority : signal is "true";
attribute keep of data_void_in_d : signal is "true";
attribute keep of stop_out_i : signal is "true";
attribute keep of data_void_out_i : signal is "true";
attribute keep of valid_no_collision : signal is "true";
attribute keep of valid_collision : signal is "true";
attribute keep of last_flit_tail : signal is "true";
attribute keep of credits : signal is "true";
attribute keep of forwarded_tail : signal is "true";
attribute keep of forwarding_tail : signal is "true";
attribute keep of forwarding_head : signal is "true";
attribute keep of forwarded_head : signal is "true";
attribute keep of forwarding_under_progress : signal is "true";
attribute keep of insert_lookahead_routing : signal is "true";

begin

data_in(0) <= data_n_in;
data_in(1) <= data_s_in;
data_in(2) <= data_w_in;
data_in(3) <= data_e_in;
data_in(4) <= data_p_in;

data_n_out <= data_out(0);
data_s_out <= data_out(1);
data_w_out <= data_out(2);
data_e_out <= data_out(3);
data_p_out <= data_out(4);

stop_out <= stop_out_i;


INPUT_FIFO : for i in 0 to 4 generate
	INPUT_FIFO_SEL : if ports(i) = '1' generate

		VOID_IN_DELAY_AN: if flow_control = 0 generate
		--ACK/NACK
			process(clk, rst)
			begin
				if rst = '0' then
					data_void_in_d(i) <= '1';
				elsif clk'event and clk = '1' then
					if stop_out_i(i) = '0' then
						data_void_in_d(i) <= data_void_in(i);
					end if;
				end if;
			end process;
		end generate;

		VOID_IN_DELAY_CB: if flow_control = 1 generate
			--With CB stop_out and void_in are not correlated
			data_void_in_d(i) <= data_void_in(i);
		end generate;

		--read from the queue if any of the output requests data
		rd_fifo_or(i) <= rd_fifo(0)(i) or rd_fifo(1)(i) or rd_fifo(2)(i) or rd_fifo(3)(i) or rd_fifo(4)(i);
		--write in the fifo just valid data if the fifo is not backpressuring the channel
		wr_fifo(i) <= (not data_void_in(i)) and (not full(i)); --TO CHECK: maybe the control on the full can be avoided

		INPUT_QUEUE_AN: if flow_control = 0 generate
			INPUT_FIFO_i: bypassable_queue --ACKNACK or CB w/ bypassable queue
			generic map(
				depth => depth,
				width => width
--				localx => localx,
--				localy => localy
                          )
                          port map(
				clk => clk,
				rst => rst,

--                                CONST_localx => CONST_localx,
--                                CONST_localy => CONST_localy,

				rdreq => rd_fifo_or(i),
				wrreq	=> wr_fifo(i),
				data_in => data_in(i),

				--request registers
				empty		=> empty(i),
				full		=> full(i),
				data_out => fifo_head(i),
				routing_out => routing_request(i));

			in_unvalid_flit(i) <= empty(i) and data_void_in(i);
		end generate;

		INPUT_QUEUE_CB: if flow_control = 1 generate
			INPUT_FIFO_i: nobypassable_queue --CB w/ non-bypassable queue
			generic map(
				depth => depth,
				width => width
--				localx => localx,
--				localy => localy
                          )
                          port map(
				clk => clk,
				rst => rst,

--                                CONST_localx => CONST_localx,
--                                CONST_localy => CONST_localy,

				rdreq => rd_fifo_or(i),
				wrreq	=> wr_fifo(i),
				data_in => data_in(i),

				--request registers
				empty		=> empty(i),
				full		=> full(i),
				data_out => fifo_head(i),
				routing_out => routing_request(i));

			in_unvalid_flit(i) <= empty(i);
		end generate;

		process(rst,clk)
		begin
			if rst = '0' then
				last_flit_tail(i) <= '0';
			elsif clk'event and clk = '1' then
				last_flit_tail(i) <= fifo_head(i)(width - 2);
			end if;
		end process;


		ROUTING_REQUEST_LATCH_CB: if flow_control = 1 generate
			--latching of the routing for the current worm
			process(clk, rst)
			begin
				if rst = '0' then
					saved_routing_request(i) <= (others => '0');
				elsif clk'event and clk = '1' then
					if fifo_head(i)(width-2) = '1' then
						saved_routing_request(i) <= (others => '0');
					--CB: why AN does not need to know if the FIFO is empty? Just because of the bypassable queue?
					--Or because I never checked with FIFO_depth = packet_size?
					--Response (12-27-09): with the bypassable queue you need to add the condition and you need an extra
					--condition to take care of the bypassability => in_unvalid_flit is the right flac to use in both cases (TODO)
					elsif fifo_head(i)(width-1) = '1' and empty(i) = '0' then
						saved_routing_request(i) <= routing_request(i);
					end if;
				end if;
			end process;
		end generate;

		ROUTING_REQUEST_LATCH_AN: if flow_control = 0 generate
			--latching of the routing for the current worm
			process(clk, rst)
			begin
				if rst = '0' then
					saved_routing_request(i) <= (others => '0');
				elsif clk'event and clk = '1' then
					if fifo_head(i)(width-2) = '1' then
						saved_routing_request(i) <= (others => '0');
					--ACKNACK: condition changed on Dec-27th-09 by MP to solve a reset problem
					--in_unvalid_flit tells you if a new routing needs to be saved, o/w you keep the old one
					--NOTE: matches with the condition above for the CB
					elsif fifo_head(i)(width-1) = '1' and in_unvalid_flit(i) = '0' then
						saved_routing_request(i) <= routing_request(i);
					end if;
				end if;
			end process;
		end generate;


		FINAL_ROUTING_REQUEST_MUX_AN: if flow_control = 0 generate
			process(fifo_head(i), routing_request(i), saved_routing_request(i), data_void_in(i), empty(i))
			begin
				--ACKNACK or CB w/ bypassable queue
				if fifo_head(i)(width-1) = '1' and ((data_void_in(i) = '0' and empty(i) = '1') or (empty(i) = '0')) then
					final_routing_request(i) <= routing_request(i);
				else
					final_routing_request(i) <= saved_routing_request(i);
				end if;
			end process;
		end generate;

		FINAL_ROUTING_REQUEST_MUX_CB: if flow_control = 1 generate
			process(fifo_head(i), routing_request(i), saved_routing_request(i), data_void_in(i), empty(i))
			begin
				--CB w/ nonbypassable queue
				if fifo_head(i)(width-1) = '1' and empty(i) = '0' then
					final_routing_request(i) <= routing_request(i);
				else
					final_routing_request(i) <= saved_routing_request(i);
				end if;
			end process;
		end generate;


		STOP_OUT_AN: if flow_control = 0 generate
			--ACK/NACK
			stop_out_i(i) <= full(i);
		end generate;

		STOP_OUT_CB: if flow_control = 1 generate
			--CB: I give a credit back every time a flit is read from the bypassable queue : w/ bypassable queue
			--process(clk, rst)
			--begin
			--	if rst = '0' then
			--		stop_out_i(i) <= '1';
			--	elsif clk'event and clk = '1' then
			--		stop_out_i(i) <= not (rd_fifo_or(i) and (not in_unvalid_flit(i)));
			--	end if;
			--end process;

			--CB: I give a credit back every time a flit is read from the bypassable queue : w/ no bypassable queue
			stop_out_i(i) <= not (rd_fifo_or(i) and (not in_unvalid_flit(i)));
		end generate;


		ROUTING_INPUT_i: routing_engine
		generic map (
			loc_port => i
--			localx => localx,
--			localy => localy
                  )
                  port map(
			clk => clk,
			rst => rst,

                        localx => CONST_localx,
                        localy => CONST_localy,

			destination_port => fifo_head(i)(4 downto 0),
			--move the destination address at the begining of the head flit - there were 2 bits for command
			--destx	=> fifo_head(i)(width-6 downto width-8),
			--desty	=> fifo_head(i)(width-3 downto width-5),
			destx => fifo_head(i)(width-12 downto width-14), -- 14 - 12
			desty => fifo_head(i)(width-9 downto width-11), -- 17 - 15

			--response registers; one-hot encoded like the parameter
			next_routing => next_hop_routing(i));

	end generate INPUT_FIFO_SEL;

	INPUT_FIFO_SEL_BAR : if ports(i) = '0' generate
		stop_out_i(i) <= '1';
		final_routing_request(i) <= (others => '0');
		saved_routing_request(i) <= (others => '0');
		in_unvalid_flit(i) <= '1';
		fifo_head(i) <=	(others => '0');
		routing_request(i) <= (others => '0');
		empty(i) <= '1';
		next_hop_routing(i) <= (others => '0');
	end generate INPUT_FIFO_SEL_BAR;

end generate INPUT_FIFO;

transp_final_routing_request(0)(0) <= final_routing_request(1)(0);
transp_final_routing_request(0)(1) <= final_routing_request(2)(0);
transp_final_routing_request(0)(2) <= final_routing_request(3)(0);
transp_final_routing_request(0)(3) <= final_routing_request(4)(0);

transp_final_routing_request(1)(0) <= final_routing_request(0)(1);
transp_final_routing_request(1)(1) <= final_routing_request(2)(1);
transp_final_routing_request(1)(2) <= final_routing_request(3)(1);
transp_final_routing_request(1)(3) <= final_routing_request(4)(1);

transp_final_routing_request(2)(0) <= final_routing_request(0)(2);
transp_final_routing_request(2)(1) <= final_routing_request(1)(2);
transp_final_routing_request(2)(2) <= final_routing_request(3)(2);
transp_final_routing_request(2)(3) <= final_routing_request(4)(2);

transp_final_routing_request(3)(0) <= final_routing_request(0)(3);
transp_final_routing_request(3)(1) <= final_routing_request(1)(3);
transp_final_routing_request(3)(2) <= final_routing_request(2)(3);
transp_final_routing_request(3)(3) <= final_routing_request(4)(3);

transp_final_routing_request(4)(0) <= final_routing_request(0)(4);
transp_final_routing_request(4)(1) <= final_routing_request(1)(4);
transp_final_routing_request(4)(2) <= final_routing_request(2)(4);
transp_final_routing_request(4)(3) <= final_routing_request(3)(4);


enhanc_routing_configuration(0)(0) <= '0';
enhanc_routing_configuration(0)(1) <= routing_configuration(0)(0);
enhanc_routing_configuration(0)(2) <= routing_configuration(0)(1);
enhanc_routing_configuration(0)(3) <= routing_configuration(0)(2);
enhanc_routing_configuration(0)(4) <= routing_configuration(0)(3);

enhanc_routing_configuration(1)(0) <= routing_configuration(1)(0);
enhanc_routing_configuration(1)(1) <= '0';
enhanc_routing_configuration(1)(2) <= routing_configuration(1)(1);
enhanc_routing_configuration(1)(3) <= routing_configuration(1)(2);
enhanc_routing_configuration(1)(4) <= routing_configuration(1)(3);

enhanc_routing_configuration(2)(0) <= routing_configuration(2)(0);
enhanc_routing_configuration(2)(1) <= routing_configuration(2)(1);
enhanc_routing_configuration(2)(2) <= '0';
enhanc_routing_configuration(2)(3) <= routing_configuration(2)(2);
enhanc_routing_configuration(2)(4) <= routing_configuration(2)(3);

enhanc_routing_configuration(3)(0) <= routing_configuration(3)(0);
enhanc_routing_configuration(3)(1) <= routing_configuration(3)(1);
enhanc_routing_configuration(3)(2) <= routing_configuration(3)(2);
enhanc_routing_configuration(3)(3) <= '0';
enhanc_routing_configuration(3)(4) <= routing_configuration(3)(3);

enhanc_routing_configuration(4)(0) <= routing_configuration(4)(0);
enhanc_routing_configuration(4)(1) <= routing_configuration(4)(1);
enhanc_routing_configuration(4)(2) <= routing_configuration(4)(2);
enhanc_routing_configuration(4)(3) <= routing_configuration(4)(3);
enhanc_routing_configuration(4)(4) <= '0';


OUTPUT_CONTROL : for i in 0 to 4 generate
	OUTPUT_CONTROL_SEL : if ports(i) = '1' generate
		update_priority(i) <= '0';
		ARBITRATION_OUTPUT_i: rtr_arbitration_engine
		port map(
			clk => clk,
			rst => rst,

			--requests registers; one-hot encoded like the parameter
			requests => transp_final_routing_request(i),
			shift_priority => shift_priority(i),
			update_priority => update_priority(i),
			lock_priority => lock_priority(i),

			valid_no_collision => valid_no_collision(i),
			valid_collision => valid_collision(i),
			--grant registers; one-hot encoded like the parameter
			grant_no_collision => grant_no_collision(i),
			grant_collision	=> grant_collision(i));

		--Uncommented if TH < 1
--		process(clk, rst)
--		begin
--			if rst = '0' then
--				saved_grant_collision(i) <= (others => '0');
--			elsif clk'event and clk = '1' then
--				if valid_collision(i) = '1' then
--					saved_grant_collision(i) <= grant_collision(i);
----				elsif data_out(i)(width - 2) = '1' then
--				elsif forwarded_tail(i) = '1' then
--					saved_grant_collision(i) <= (others => '0');
--				end if;
--			end if;
--		end process;

		process(clk, rst)
		begin
			if rst = '0' then
				saved_grant_no_collision(i) <= (others => '0');
			elsif clk'event and clk = '1' then
				if valid_no_collision(i) = '1' then
					saved_grant_no_collision(i) <= grant_collision(i);
				elsif forwarded_tail(i) = '1' then
					saved_grant_no_collision(i) <= (others => '0');
				end if;
			end if;
		end process;

		process(clk, rst)
		begin
			if rst = '0' then
				saved_routing_configuration(i) <= (others => '0');
			elsif clk'event and clk = '1' then
				if forwarding_under_progress(i) = '1' then
					saved_routing_configuration(i) <= routing_configuration(i);
				elsif forwarded_tail(i) = '1' then
					saved_routing_configuration(i) <= (others => '0');
				end if;
			end if;
		end process;

		shift_priority(i) <= forwarding_tail(i);
		process(rst,clk)
		begin
			if rst = '0' then
				lock_priority(i) <= '0';
			elsif clk'event and clk = '1' then
				if forwarding_tail(i) = '1' then
					lock_priority(i) <= '0';
				elsif forwarding_head(i) = '1' then
					lock_priority(i) <= '1';
				end if;
			end if;
		end process;

		--TH = 1 : The lookahead routing has to be inserted on the first flit of a packet
		process(rst,clk)
		begin
			if rst = '0' then
				insert_lookahead_routing(i) <= '1';
			elsif clk'event and clk = '1' then
				if forwarding_tail(i) = '1' then --and forwarding_under_progress(i) = '1' then
					insert_lookahead_routing(i) <= '1';
				elsif forwarding_head(i) = '1' then --and forwarding_under_progress(i) = '1' then
					insert_lookahead_routing(i) <= '0';
				end if;
			end if;
		end process;

		--crossbar
		process(enhanc_routing_configuration(i), rd_fifo_output(i), fifo_head, next_hop_routing, in_unvalid_flit, forwarding_head(i), forwarding_under_progress(i), state(i), insert_lookahead_routing(i))
		begin
			--if state(i) = idle then --TH < 1: after every packet the FSM goes in idle and that allows to insert the lookahead routing in the head flit
			if insert_lookahead_routing(i) = '1' then --for TH = 1, because the FSM does not always go through idle before sending a head flit--and forwarding_under_progress(i) = '1' then
				if enhanc_routing_configuration(i)(0) = '1' then
					data_out_crossbar(i) <= fifo_head(0)(width-1 downto 5) & next_hop_routing(0);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(0) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(0);

				elsif enhanc_routing_configuration(i)(1) = '1' then
					data_out_crossbar(i) <= fifo_head(1)(width-1 downto 5) & next_hop_routing(1);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(1) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(1);

				elsif enhanc_routing_configuration(i)(2) = '1' then
					data_out_crossbar(i) <= fifo_head(2)(width-1 downto 5) & next_hop_routing(2);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(2) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(2);

				elsif enhanc_routing_configuration(i)(3) = '1' then
					data_out_crossbar(i) <= fifo_head(3)(width-1 downto 5) & next_hop_routing(3);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(3) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(3);

				elsif enhanc_routing_configuration(i)(4) = '1' then
					data_out_crossbar(i) <= fifo_head(4)(width-1 downto 5) & next_hop_routing(4);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(4) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(4);

				else
					data_out_crossbar(i) <= (others => '0');
					rd_fifo(i) <= (others => '0');
					out_unvalid_flit(i) <= '1';
				end if;
			else
				if enhanc_routing_configuration(i)(0) = '1' then
					data_out_crossbar(i) <= fifo_head(0);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(0) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(0);

				elsif enhanc_routing_configuration(i)(1) = '1' then
					data_out_crossbar(i) <= fifo_head(1);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(1) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(1);

				elsif enhanc_routing_configuration(i)(2) = '1' then
					data_out_crossbar(i) <= fifo_head(2);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(2) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(2);

				elsif enhanc_routing_configuration(i)(3) = '1' then
					data_out_crossbar(i) <= fifo_head(3);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(3) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(3);

				elsif enhanc_routing_configuration(i)(4) = '1' then
					data_out_crossbar(i) <= fifo_head(4);
					rd_fifo(i) <= (others => '0');
					rd_fifo(i)(4) <= rd_fifo_output(i);
					out_unvalid_flit(i) <= in_unvalid_flit(4);

				else
					data_out_crossbar(i) <= (others => '0');
					rd_fifo(i) <= (others => '0');
					out_unvalid_flit(i) <= '1';
				end if;

			end if;
		end process;

		MISC_AN: if flow_control = 0 generate
			--ACKNACK
			rd_fifo_output(i) <= not stop_in(i);
			forwarded_tail(i) <= data_out(i)(width - 2) and (not stop_in(i));
			forwarded_head(i) <= data_out(i)(width - 1) and (not stop_in(i));
			forwarding_tail(i) <= '1' when (data_out_crossbar(i)(width-2) = '1' and out_unvalid_flit(i) = '0' and stop_in(i) = '0') else '0';
			forwarding_head(i) <= '1' when (data_out_crossbar(i)(width-1) = '1' and out_unvalid_flit(i) = '0' and stop_in(i) = '0') else '0';
		end generate;

		MISC_CB: if flow_control = 1 generate
			--CB
			rd_fifo_output(i) <= '1' when credits(i) > 0 else '0';
			--w/ output FF
			--forwarded_tail(i) <= '1' when (data_out(i)(width - 2) = '1' and data_void_out_i(i) = '0') else '0'; -- and credits(i) > 0) else '0';
			--forwarded_head(i) <= '1' when (data_out(i)(width - 1) = '1' and data_void_out_i(i) = '0') else '0'; -- and credits(i) > 0) else '0';
			--w/o output FF
			forwarded_tail(i) <= '1' when (last_flit(i)(width - 2) = '1') else '0'; -- and credits(i) > 0) else '0';
			forwarded_head(i) <= '1' when (last_flit(i)(width - 1) = '1') else '0'; -- and credits(i) > 0) else '0';
			forwarding_tail(i) <= '1' when (data_out_crossbar(i)(width-2) = '1' and out_unvalid_flit(i) = '0' and credits(i) > 0) else '0';
			forwarding_head(i) <= '1' when (data_out_crossbar(i)(width-1) = '1' and out_unvalid_flit(i) = '0' and credits(i) > 0) else '0';
		end generate;


		process(state(i), valid_collision(i), valid_no_collision(i), grant_no_collision(i), grant_collision(i), saved_routing_configuration(i), data_out_crossbar(i), data_out(i), stop_in(i), forwarded_tail(i), forwarding_tail(i), rd_fifo_output(i))
		begin
			case state(i) is

				when idle =>
					--if a configuration is obtained forward the head flit
					if valid_no_collision(i) = '1' and rd_fifo_output(i) = '1' then
						routing_configuration(i) <= grant_no_collision(i);
						if data_out_crossbar(i)(width - 2) = '1' then
							forwarding_under_progress(i) <=	'1';
							new_state(i) <= read_ctrl_msg;
						else
							forwarding_under_progress(i) <=	'1';
							new_state(i) <= read;
						end if;
					--uncomment if TH < 1
					--elsif valid_collision(i) = '1' and rd_fifo_output(i) = '1' then
					--	routing_configuration(i) <= grant_collision(i);
					--	if data_out_crossbar(i)(width - 2) = '1' then
					--		forwarding_under_progress(i) <=	'0';
					--		new_state(i) <= read_ctrl_msg;
					--	else
					--		forwarding_under_progress(i) <=	'1';
					--		new_state(i) <= read;
					--	end if;
					else
						routing_configuration(i) <= (others => '0');
						forwarding_under_progress(i) <=	'0';
						new_state(i) <= idle;
					end if;

				when read_ctrl_msg =>
					if rd_fifo_output(i) = '1'  then
						--added for TH = 1
						if valid_no_collision(i) = '1' then
							routing_configuration(i) <= grant_no_collision(i);
							if data_out_crossbar(i)(width - 2) = '1' then
								forwarding_under_progress(i) <=	data_out_crossbar(i)(width - 1); -- considering single-flit packets!
								new_state(i) <= read_ctrl_msg;
							else
								forwarding_under_progress(i) <=	'1';
								new_state(i) <= read;
							end if;
						else
						--until here added for TH = 1
							routing_configuration(i) <= (others => '0');
							forwarding_under_progress(i) <=	'0';
							new_state(i) <= idle;
						--added for TH = 1
						end if;
						--until here added for TH = 1
					else
						routing_configuration(i) <= (others => '0');
						forwarding_under_progress(i) <=	'1';
						new_state(i) <= read_ctrl_msg;
					end if;

				when read =>
					--New note: equal for both CB and ACKNACK
					if forwarded_tail(i) = '1'  then --ACK/NACK for TH < 1
						--TH < 1
						--routing_configuration(i) <= (others => '0');
						--forwarding_under_progress(i) <=	'0';
						--new_state(i) <= idle;
						--until here: TH < 1
						--added for TH = 1
						if valid_no_collision(i) = '1' then
							routing_configuration(i) <= grant_no_collision(i);
							if data_out_crossbar(i)(width - 2) = '1' then
								forwarding_under_progress(i) <=	data_out_crossbar(i)(width - 1); -- considering single-flit packets!
								new_state(i) <= read_ctrl_msg;
							else
								forwarding_under_progress(i) <=	'1';
								new_state(i) <= read;
							end if;
						else
							routing_configuration(i) <= (others => '0');
							forwarding_under_progress(i) <=	'0';
							new_state(i) <= idle;
						end if;
						--until here added for TH = 1
					else
						routing_configuration(i) <= saved_routing_configuration(i);
						forwarding_under_progress(i) <=	'1';
						new_state(i) <= read;
					end if;

				when others =>
					routing_configuration(i) <= (others => '0');
					forwarding_under_progress(i) <=	'0';
					new_state(i) <= idle;

			end case;
		end process;

		process(clk, rst)
		begin
			if rst = '0' then
				state(i) <= idle;
			elsif clk'event and clk = '1' then
				state(i) <= new_state(i);
			end if;
		end process;

		DATA_OUT_AN: if flow_control = 0 generate
			--ACK/NACK
			process(rst, clk)
			begin
				if rst = '0' then
					data_out(i) <= (others => '0');
				elsif clk'event and clk = '1' then
					if stop_in(i) = '0' and forwarding_under_progress(i) = '1' and out_unvalid_flit(i) = '0' then
						data_out(i) <= data_out_crossbar(i);
					end if;
				end if;
			end process;

			process(rst, clk)
			begin
				if rst = '0' then
					data_void_out_i(i) <= '1';
				elsif clk'event and clk = '1' then
					--if new_state(i) = idle or (out_unvalid_flit(i) = '1' and stop_in(i) = '0')  then
                                        --  data_void_out_i(i) <= '1';
					--else
					--	data_void_out_i(i) <= out_unvalid_flit(i);
					--end if;
                                        if new_state(i) = idle then
                                          data_void_out_i(i) <= '1';
                                        elsif stop_in(i) = '0' then
                                          data_void_out_i(i) <= out_unvalid_flit(i);
                                        end if;
				end if;
			end process;
		end generate;


		DATA_OUT_CB: if flow_control = 1 generate
			--CB: a flit is sent only if credits > 0 : with output FF
			--process(rst, clk)
			--begin
			--	if rst = '0' then
			--		data_out(i) <= (others => '0');
			--	elsif clk'event and clk = '1' then
			--		--question: forwarding_under_progress instead of idle?
			--		if credits(i) > 0 and new_state(i) /= idle and out_unvalid_flit(i) = '0' then
			--			data_out(i) <= data_out_crossbar(i);
			--		end if;
			--	end if;
			--end process;

			--CB: a flit is sent only if credits > 0 : w/o output FF
			data_out(i) <= data_out_crossbar(i);

			--CB: a flit is sent only if credits > 0 : with output FF
			--process(rst, clk)
			--begin
			--	if rst = '0' then
			--		data_void_out_i(i) <= '1';
			--		credits(i) <= depth;
			--	elsif clk'event and clk = '1' then
			--		if credits(i) > 0 and new_state(i) /= idle and out_unvalid_flit(i) = '0' then
			--			data_void_out_i(i) <= '0';
			--			if stop_in(i) = '1' then
			--				credits(i) <= credits(i) - 1;
			--			end if;
			--		else
			--			data_void_out_i(i) <= '1';
			--			if stop_in(i) = '0' then
			--				credits(i) <= credits(i) + 1;
			--			end if;
			--		end if;
			--	end if;
			--end process;

			--CB: a flit is sent only if credits > 0 : w/o output FF
			process(rst, clk)
			begin
				if rst = '0' then
					credits(i) <= depth;
				elsif clk'event and clk = '1' then
					if data_void_out_i(i) ='0' then
						if stop_in(i) = '1' then
							credits(i) <= credits(i) - 1;
						end if;
					else
						if stop_in(i) = '0' then
							credits(i) <= credits(i)	 + 1;
						end if;
					end if;
				end if;
			end process;
			data_void_out_i(i) <= '0' when (credits(i) > 0 and new_state(i) /= idle and out_unvalid_flit(i) = '0') else '1';
		end generate;


		data_void_out(i) <= data_void_out_i(i);


		process(rst, clk)
		begin
			if rst = '0' then
				last_flit(i) <= (others => '0');
			elsif clk = '1' and clk'event then
				if data_void_out_i(i) = '0' then
            				last_flit(i) <= data_out_crossbar(i);
				end if;
			end if;
		end process;

	end generate OUTPUT_CONTROL_SEL;

	OUTPUT_CONTROL_SEL_BAR : if ports(i) = '0' generate
		valid_no_collision(i) <= '0';
		valid_collision(i) <= '0';
		grant_no_collision(i) <= (others => '0');
		grant_collision(i) <= (others => '0');
		data_void_out(i) <= '1';
		data_out(i) <= (others => '0');
		routing_configuration(i) <= (others => '0');
		data_out_crossbar(i) <= (others => '0');
		rd_fifo(i) <= (others => '0');
		out_unvalid_flit(i) <= '1';
		shift_priority(i) <= '0';
		lock_priority(i) <= '0';
		saved_routing_configuration(i) <= (others => '0');
		saved_grant_no_collision(i) <= (others => '0');
		saved_grant_collision(i) <= (others => '0');
                rd_fifo_output(i) <= '0';
                rd_fifo_or(i) <= '0';
                wr_fifo(i) <= '0';
                update_priority(i) <= '0';
                data_void_in_d(i) <= '1';
                data_void_out_i(i) <= '1';
                last_flit_tail(i) <= '0';
                forwarded_tail(i) <= '0';
                forwarding_tail(i) <= '0';
                forwarding_head(i) <= '0';
                forwarded_head(i) <= '0';
                forwarding_under_progress(i) <= '0';
                insert_lookahead_routing(i) <= '0';
                full(i) <= '0';
		DISCONNECTED_PORT_CB: if flow_control = 1 generate
			credits(i) <= 0;
		end generate;
	end generate OUTPUT_CONTROL_SEL_BAR;

end generate OUTPUT_CONTROL;


end behavior;
