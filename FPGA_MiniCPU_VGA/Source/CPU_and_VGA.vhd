library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPU_and_VGA is
    port (
		i_InstrRX	: in	std_logic;
		i_Enable	: in	std_logic;
		CLK			: in	std_logic;
		
		o_VGA		: out	std_logic_vector (4 downto 0);
		o_Busy		: out	std_logic
	);
end CPU_and_VGA;
	
architecture Behavioral of CPU_and_VGA is
	signal net_rx			: std_logic;
	
	signal net_uart_data	: std_logic_vector (31 downto 0);
	signal net_uart_valid	: std_logic;
	
	signal net_vram_char	: std_logic_vector (7 downto 0);
	signal net_vram_addr	: std_logic_vector (15 downto 0);
	signal net_vram_cmd		: std_logic_vector (4 downto 0);
begin
	
	net_rx <= i_InstrRX when i_Enable = '1' else '1';
	
	INST_UART: entity work.SerialUART_Receiver(Behavioral) 
		port map (
			i_RX		=> net_rx,
			i_CLK		=> CLK,
			
			o_Data		=> net_uart_data,
			o_Busy		=> o_Busy,
			o_Valid		=> net_uart_valid
		);
	
	INST_CPU: entity work.CPU(Behavioral) 
		port map (
			i_Instr 		=> net_uart_data,
			i_Enable 		=> net_uart_valid,
			i_CLK 			=> CLK,
			
			o_VRAM_Char 	=> net_vram_char,
			o_VRAM_Addr 	=> net_vram_addr,
			o_VRAM_Cmd 		=> net_vram_cmd
		);
	
	INST_VGA: entity work.VGA_Renderer(Behavioral) 
		port map (
			i_Data 			=> net_vram_char,
			i_Addr 			=> net_vram_addr,
			i_Cmd 			=> net_vram_cmd,
			i_CLK 			=> CLK,
			
			o_VGA			=> o_VGA
		);
	
end Behavioral;
