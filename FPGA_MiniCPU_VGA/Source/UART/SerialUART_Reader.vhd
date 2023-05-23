library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- Modified from
-- https://www.hackster.io/alexey-sudbin/uart-interface-in-vhdl-for-basys3-board-eef170

-- Set Generic BAUD_X8_CLK_TICKS as:
-- (clk freq) / (baud rate) / 8

-- Example: 20MHz Clock, 115200 baud rate
-- 20000000 / 115200 / 8 = 21

entity SerialUART_Reader is
	generic (
		BAUD_X8_CLK_TICKS 	: integer;
		DATA_COUNT			: integer
	);
	port (
		i_RX		: in	std_logic;
		i_CLK		: in	std_logic;
		
		o_Data		: out	std_logic_vector (DATA_COUNT-1 downto 0);
		o_Busy		: out	std_logic
	);
end SerialUART_Reader;

architecture Behavioral of SerialUART_Reader is
	type rx_states_t is (IDLE, START, DATA, STOP);
    signal rx_state : rx_states_t := IDLE;

    signal baud_rate_x8_clk		: std_logic := '0';
    signal rx_stored_data		: std_logic_vector (DATA_COUNT-1 downto 0) := (others => '0');
begin
	
	-- The baud_rate_x8_clk_generator process generates an oversampled clock.
	-- The baud_rate_x8_clk signal is 16 times faster than the baud rate clock.
	-- Oversampling is needed to put the capture point at the middle of duration of
	-- the receiving bit.
	-- The BAUD_X8_CLK_TICKS constant reflects the ratio between the master clk
	-- and the x8 baud rate.

	baud_rate_x8_clk_generator: process(i_CLK)
		variable baud_x8_count : integer range 0 to (BAUD_X8_CLK_TICKS - 1) := (BAUD_X8_CLK_TICKS - 1);
	begin
		if rising_edge(i_CLK) then
			if (baud_x8_count = 0) then
				baud_rate_x8_clk <= '1';
				baud_x8_count := BAUD_X8_CLK_TICKS - 1;
			else
				baud_rate_x8_clk <= '0';
				baud_x8_count := baud_x8_count - 1;
			end if;
		end if;
	end process baud_rate_x8_clk_generator;
	
	-- The UART_rx_FSM process represents a Finite State Machine which has
	-- four states (IDLE, START, DATA, STOP). See inline comments for more details.
	
	UART_rx_FSM: process(i_CLK)
		variable bit_duration_count : integer range 0 to 7 := 0;
		variable bit_count          : integer range 0 to DATA_COUNT-1 := 0;
	begin
		if rising_edge(i_CLK) then
			if (baud_rate_x8_clk = '1') then     -- the FSM works 16 times faster the baud rate frequency
				case rx_state is
					
					when IDLE =>
						
						rx_stored_data <= (others => '0');		-- clean the received data register
						bit_duration_count := 0;				-- reset counters
						bit_count := 0;
						
						if (i_RX = '0') then					-- if the start bit received
							rx_state <= START;					-- transit to the START state
						end if;
						
					when START =>
						
						if (i_RX = '0') then					-- verify that the start bit is preset
							if (bit_duration_count = 3) then	-- wait a half of the baud rate cycle
								rx_state <= DATA;				-- (it puts the capture point at the middle of duration of the receiving bit)
								bit_duration_count := 0;
							else
								bit_duration_count := bit_duration_count + 1;
							end if;
						else
							rx_state <= IDLE;					-- the start bit is not preset (false alarm)
						end if;
						
					when DATA =>
						
						if (bit_duration_count = 7) then				-- wait for "one" baud rate cycle (not strictly one, about one)
							rx_stored_data(bit_count) <= i_RX;			-- fill in the receiving register one received bit.
							bit_duration_count := 0;
							if (bit_count = DATA_COUNT-1) then			-- when all bits received, go to the STOP state
								rx_state <= STOP;
								bit_duration_count := 0;
							else
								bit_count := bit_count + 1;
							end if;
						else
							bit_duration_count := bit_duration_count + 1;
						end if;
						
					when STOP =>
						
						if (bit_duration_count = 7) then		-- wait for "one" baud rate cycle
							o_Data <= rx_stored_data;			-- transer the received data to the outside world
							rx_state <= IDLE;
						else
							bit_duration_count := bit_duration_count + 1;
						end if;
						
					when others =>
						rx_state <= IDLE;
					
				end case;
			end if;
		end if;
	end process UART_rx_FSM;
	
	o_Busy <= '0' when (rx_state = IDLE or rx_state = STOP) else '1';
	
end Behavioral;
