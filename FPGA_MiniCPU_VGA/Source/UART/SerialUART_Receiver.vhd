library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity SerialUART_Receiver is
	generic (
		CLKS_PER_BIT : integer := 115
	);
	port (
		i_RX		: in	std_logic;
		i_CLK		: in	std_logic;
		
		o_Data		: out	std_logic_vector (31 downto 0);
		o_Valid		: out	std_logic;
		o_Busy		: out	std_logic
	);
end SerialUART_Receiver;

architecture Behavioral of SerialUART_Receiver is
	signal net_uart_data	: std_logic_vector (39 downto 0);
begin
	
	-- Serial baud rate is 	9600
	-- Clock rate is		20MHz
	--		= 20e6 / 9600 / 16 = 
	INST_READER: entity work.SerialUART_Reader(Behavioral) 
		generic map (
			BAUD_X16_CLK_TICKS	=> 130,
			DATA_COUNT			=> 40
		)
		port map (
			i_RX		=> i_RX,
			i_CLK		=> i_CLK,
			
			o_Data		=> net_uart_data,
			o_Busy		=> o_Busy
		);
	
	INST_CHECK: entity work.InputCheck(Behavioral) 
		port map (
			i_Data		=> net_uart_data(39 downto 8),
			i_Hash		=> net_uart_data(7 downto 0),
			
			o_Valid		=> o_Valid
		);
	
end Behavioral;
