--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:33:23 05/24/2023
-- Design Name:   
-- Module Name:   /home/ise/Projects/FPGA_MiniCPU/FPGA_MiniCPU_VGA/Test/test_VGA_Renderer.vhd
-- Project Name:  FPGA_MiniCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: VGA_Renderer
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
use IEEE.NUMERIC_STD.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_VGA_Renderer IS
END test_VGA_Renderer;
 
ARCHITECTURE behavior OF test_VGA_Renderer IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT VGA_Renderer
    PORT(
         i_Data : IN  std_logic_vector(7 downto 0);
         i_Addr : IN  std_logic_vector(15 downto 0);
         i_Cmd : IN  std_logic_vector(4 downto 0);
         i_CLK : IN  std_logic;
         o_VGA : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal i_Data : std_logic_vector(7 downto 0) := "00110000";
   signal i_Addr : std_logic_vector(15 downto 0) := (others => '0');
   signal i_Cmd : std_logic_vector(4 downto 0) := "11100";
   signal i_CLK : std_logic := '0';

 	--Outputs
   signal o_VGA : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant i_CLK_period : time := 1 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: VGA_Renderer PORT MAP (
          i_Data => i_Data,
          i_Addr => i_Addr,
          i_Cmd => i_Cmd,
          i_CLK => i_CLK,
          o_VGA => o_VGA
        );

   -- Clock process definitions
   i_CLK_process :process
   begin
		i_CLK <= '0';
		wait for i_CLK_period;
		i_CLK <= '1';
		wait for i_CLK_period;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		--i_Data <= "00110000";
		--i_Addr <= "00000000" & "00000000";
		--i_Cmd(1) <= '1';
		
		wait for 1000 ms;

		wait;
   end process;

END;
