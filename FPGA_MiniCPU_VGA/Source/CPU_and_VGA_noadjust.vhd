library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPU_and_VGA is
    port (
		i_InstrRX	: in	std_logic;
		i_Enable	: in	std_logic;
		CLK			: in	std_logic;
		
		o_TestLED	: out	std_logic_vector (7 downto 0);
		o_TestLED2	: out	std_logic_vector (7 downto 0);
		
		o_TestLED3	: out	std_logic_vector (6 downto 0);
		o_TestSeg	: out	std_logic;
		
		o_VGA		: out	std_logic_vector (4 downto 0);
		o_Busy		: out	std_logic
	);
end CPU_and_VGA;
	
architecture Behavioral of CPU_and_VGA is
	signal net_CLK_25MHz	: std_logic;
	
	signal net_rx			: std_logic;
	
	signal net_uart_data	: std_logic_vector (39 downto 0);
	signal net_uart_valid	: std_logic;
	signal net_uart_busy	: std_logic;
	
	signal net_vram_char	: std_logic_vector (7 downto 0);
	signal net_vram_addr	: std_logic_vector (15 downto 0);
	signal net_vram_cmd		: std_logic_vector (4 downto 0);
	signal net_cpu_busy		: std_logic;
	
	signal net_any_busy		: std_logic;
begin
	
	net_rx <= i_InstrRX when i_Enable = '1' else '1';
	
	INST_CLK_ADJUST: entity work.ClockAdjust(Behavioral) 
		port map (
			i_Clk 		=> CLK,
			o_Clk		=> net_CLK_25MHz
		);
	
	INST_UART: entity work.SerialUART_Receiver(Behavioral) 
		port map (
			i_RX		=> net_rx,
			i_CLK		=> net_CLK_25MHz,
			
			o_Data		=> net_uart_data,
			o_Busy		=> net_uart_busy,
			o_Valid		=> net_uart_valid
		);
	
	INST_CPU: entity work.CPU(Behavioral) 
		port map (
			i_Instr 		=> net_uart_data(39 downto 8),
			i_Enable 		=> net_uart_valid,
			i_CLK 			=> net_CLK_25MHz,
			
			o_VRAM_Char 	=> net_vram_char,
			o_VRAM_Addr 	=> net_vram_addr,
			o_VRAM_Cmd 		=> net_vram_cmd,
			o_Busy 			=> net_cpu_busy
		);
	
	INST_VGA: entity work.VGA_Renderer(Behavioral) 
		port map (
			i_Data 			=> net_vram_char,
			i_Addr 			=> net_vram_addr,
			i_Cmd 			=> net_vram_cmd,
			i_CLK 			=> net_CLK_25MHz,
			
			o_VGA			=> o_VGA
		);
	
	net_any_busy <= net_uart_busy or net_cpu_busy;
	
	o_TestLED <= net_uart_data(39 downto 32);	-- First word : flag and opcode
	o_TestLED2 <= net_uart_data(7 downto 0);	-- Last word  : checksum
	
	--    6
	-- 1     5
	--    0
	-- 2     4
	--    3
	-- 
	
	o_TestLED3 <= (
		6 => net_uart_busy,
		5 => net_cpu_busy,
		1 => net_rx,
		0 => net_uart_valid,
		others => '0');
	o_TestSeg <= '0';
	
	o_Busy <= net_any_busy;
	
end Behavioral;

