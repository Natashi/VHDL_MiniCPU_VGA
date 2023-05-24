--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:14:39 05/23/2023
-- Design Name:   
-- Module Name:   /home/ise/Projects/FPGA_MiniCPU/FPGA_MiniCPU_VGA/Test/test_ClockController.vhd
-- Project Name:  FPGA_MiniCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ClockController
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_ClockController IS
END test_ClockController;
 
ARCHITECTURE behavior OF test_ClockController IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ClockController
    PORT(
         i_Enable : IN  std_logic;
         i_CLK : IN  std_logic;
         o_Clk_Decode : OUT  std_logic;
         o_Clk_RegisterR : OUT  std_logic;
         o_Clk_Execute : OUT  std_logic;
         o_Clk_RegisterW : OUT  std_logic;
         o_Busy : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_Enable : std_logic := '0';
   signal i_CLK : std_logic := '0';

 	--Outputs
   signal o_Clk_Decode : std_logic;
   signal o_Clk_RegisterR : std_logic;
   signal o_Clk_Execute : std_logic;
   signal o_Clk_RegisterW : std_logic;
   signal o_Busy : std_logic;

   -- Clock period definitions
   constant i_CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ClockController PORT MAP (
          i_Enable => i_Enable,
          i_CLK => i_CLK,
          o_Clk_Decode => o_Clk_Decode,
          o_Clk_RegisterR => o_Clk_RegisterR,
          o_Clk_Execute => o_Clk_Execute,
          o_Clk_RegisterW => o_Clk_RegisterW,
          o_Busy => o_Busy
        );

   -- Clock process definitions
   i_CLK_process :process
   begin
		i_CLK <= '1';
		wait for i_CLK_period;
		i_CLK <= '0';
		wait for i_CLK_period;
   end process;
 

	-- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;	

		for i in 0 to 10 loop
			i_Enable <= '1';
			wait for i_CLK_period;
			i_Enable <= '0';
			wait for i_CLK_period;
		end loop;

		wait;
	end process;

END;
