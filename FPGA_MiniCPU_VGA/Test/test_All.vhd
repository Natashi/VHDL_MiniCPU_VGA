LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_All IS
END test_All;

ARCHITECTURE behavior OF test_All IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPU_and_VGA
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
    END COMPONENT;
    

	--Inputs
	signal i_InstrRX : std_logic := '1';
	signal i_Enable : std_logic := '0';
	signal CLK : std_logic := '0';

	--Outputs
	signal o_TestLED : std_logic_vector (7 downto 0);
	signal o_TestLED2 : std_logic_vector (7 downto 0);
	signal o_TestLED3 : std_logic_vector (6 downto 0);
	signal o_TestSeg : std_logic;
	signal o_VGA : std_logic_vector (4 downto 0);
	signal o_Busy : std_logic;

	-- Clock period definitions
	constant CLK_P 			: time 		:= 50 ns;	-- 20MHz (will become 25MHz after ClockAdjust)
	
	constant baud_period	: time 		:= 104 us;	-- 9600
	--constant baud_period	: time 		:= 8.7 us;	-- 115200
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: CPU_and_VGA 
	PORT MAP (
		i_InstrRX	=> i_InstrRX,
		i_Enable	=> i_Enable,
		CLK			=> CLK,
					
		o_TestLED	=> o_TestLED,
		o_TestLED2	=> o_TestLED2,
		o_TestLED3	=> o_TestLED3,
		o_TestSeg	=> o_TestSeg,
		o_VGA		=> o_VGA,
		o_Busy		=> o_Busy
	);

	i_CLK_process : process
	begin
		CLK <= '1';
		wait for CLK_P / 2;
		CLK <= '0';
		wait for CLK_P / 2;
	end process;
	
	
	-- Stimulus process
	stim_proc: process
		variable data : std_logic_vector (39 downto 0);
		
		procedure SendUART is begin
			i_Enable <= '1';
			wait for 50 ns;
			
			i_InstrRX <= '0';
			
			for i in 0 to 39 loop
				wait for baud_period;
				i_InstrRX <= data(i);
			end loop;
			
			wait for baud_period;
			i_InstrRX <= '1';
			
			wait for 50 ns;
			i_Enable <= '0';
		end procedure;
	begin
		wait for 100 us;
		
		data := "10010111"&"00001001"&"00000000"&"00000000"&"01100001";		-- movi r0, 9
		SendUART;
		
		wait for 1 ms;
		
		data := "10010111"&"00001001"&"00000000"&"00000000"&"01100000";		-- Invalid ins
		SendUART;
		
		wait;
	end process;

END;
