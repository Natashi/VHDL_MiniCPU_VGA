--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:39:03 05/24/2023
-- Design Name:   
-- Module Name:   /home/ise/Projects/FPGA_MiniCPU/FPGA_MiniCPU_VGA/Test/test_UART.vhd
-- Project Name:  FPGA_MiniCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SerialUART_Receiver
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY test_UART IS
END test_UART;
 
ARCHITECTURE behavior OF test_UART IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SerialUART_Receiver
    port (
		i_RX		: in	std_logic;
		i_CLK		: in	std_logic;
		
		o_Data		: out	std_logic_vector (39 downto 0);
		o_Valid		: out	std_logic;
		o_Busy		: out	std_logic
	);
    END COMPONENT;
    

   --Inputs
   signal i_RX : std_logic := '1';
   signal i_CLK : std_logic := '0';

 	--Outputs
   signal o_Data : std_logic_vector(39 downto 0);
   signal o_Valid : std_logic;
   signal o_Busy : std_logic;

   -- Clock period definitions
   constant i_CLK_period : time := 40 ns;	-- 25MHz
   
   constant baud_rate 	: integer 	:= 9600;
   constant baud_period	: time 		:= 104 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: SerialUART_Receiver
		port map (
			i_RX		=> i_RX,
			i_CLK		=> i_CLK,
			
			o_Data		=> o_Data,
			o_Valid		=> o_Valid,
			o_Busy		=> o_Busy
		);

   -- Clock process definitions
   i_CLK_process :process
   begin
		i_CLK <= '1';
		wait for i_CLK_period / 2;
		i_CLK <= '0';
		wait for i_CLK_period / 2;
   end process;
 

   -- Stimulus process
   stim_proc: process
		variable data : std_logic_vector(39 downto 0);
		
		procedure SendUART is begin
			i_RX <= '0';
			
			for i in 0 to 39 loop
				wait for baud_period;
				i_RX <= data(i);
			end loop;
			
			wait for baud_period;
			i_RX <= '1';
		end procedure;
   begin		
		-- hold reset state for 100 ns.
		wait for 100 us;	
		
		data := "10011011"&"00000101"&"00000000"&"00000000"&"01100001";
		SendUART;
		
		wait for 1 ms;
		
		data := "10011011"&"00000101"&"00000000"&"00000000"&"01100000";		-- Invalid data
		SendUART;

		wait;
   end process;

END;
