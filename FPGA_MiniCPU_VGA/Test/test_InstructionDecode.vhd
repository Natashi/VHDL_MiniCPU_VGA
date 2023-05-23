LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
 
ENTITY test_InstructionDecode IS
END test_InstructionDecode;
 
ARCHITECTURE behavior OF test_InstructionDecode IS 
    COMPONENT InstructionDecode
    PORT(
         i_Instr : IN  std_logic_vector(31 downto 0);
         i_Enable : IN  std_logic;
         i_CPSR : IN  std_logic_vector(7 downto 0);
         i_CLK : IN  std_logic;
         o_Operation : OUT  std_logic_vector(3 downto 0);
         o_ALU_Src : OUT  std_logic;
         o_Reg_Dest : OUT  std_logic;
         o_ALU_Enable : OUT  std_logic;
         o_Reg_Write : OUT  std_logic;
         o_GC_Enable : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_Instr : std_logic_vector(31 downto 0) := (others => '0');
   signal i_Enable : std_logic := '0';
   signal i_CPSR : std_logic_vector(7 downto 0) := (others => '0');
   signal i_CLK : std_logic := '0';

 	--Outputs
   signal o_Operation : std_logic_vector(3 downto 0);
   signal o_ALU_Src : std_logic;
   signal o_Reg_Dest : std_logic;
   signal o_ALU_Enable : std_logic;
   signal o_Reg_Write : std_logic;
   signal o_GC_Enable : std_logic;

	constant CLK_P : time := 10 ns;
	constant CLK_P2 : time := CLK_P * 2;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: InstructionDecode PORT MAP (
		i_Instr => i_Instr,
		i_Enable => i_Enable,
		i_CPSR => i_CPSR,
		i_CLK => i_CLK,
		o_Operation => o_Operation,
		o_ALU_Src => o_ALU_Src,
		o_Reg_Dest => o_Reg_Dest,
		o_ALU_Enable => o_ALU_Enable,
		o_Reg_Write => o_Reg_Write,
		o_GC_Enable => o_GC_Enable
	);

	i_CLK_process : process
	begin
		i_CLK <= '1';
		wait for CLK_P;
		i_CLK <= '0';
		wait for CLK_P;
	end process;

	stim_proc: process
		procedure LoopAllFlags is begin
			i_Enable <= '1';
			for i in 0 to 7 loop
				i_Instr(31 downto 29) <= std_logic_vector(
					to_unsigned(i, 3));
				wait for CLK_P2;
			end loop;
			i_Enable <= '0';
			wait for 20 ns;
		end procedure;
	begin		
		wait for 20 ns;
		
		i_Instr(28 downto 24) 	<= "00000";	-- Basic
		i_Instr(11 downto 8) 	<= "0000";
		
		i_CPSR <= "00000000";	-- Should trigger AL, NE, GT, GE
		LoopAllFlags;
		
		i_CPSR <= "01000000";	-- Should trigger AL, EQ, LE, GE
		LoopAllFlags;
		
		i_CPSR <= "10000000";	-- Should trigger AL, NE, LT, LE
		LoopAllFlags;
		
		wait for 40 ns;
		
		----------------------------------------------
		
		i_CPSR <= "00000000";
		i_Instr(31 downto 29) <= "011";
		i_Enable <= '1';
		
		for i in 1 to 17 loop
			i_Instr(28 downto 24) <= std_logic_vector(
				to_unsigned(i, 5));
			wait for 20 ns;
		end loop;
		
	wait;
	end process;

END;
