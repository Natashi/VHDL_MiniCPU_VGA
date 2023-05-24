library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity InstructionDecode is
	port (
		i_Instr			: in	std_logic_vector (31 downto 0);
		i_CPSR			: in	std_logic_vector (7 downto 0);
		i_Enable		: in	std_logic;
		i_CLK			: in	std_logic;
		
		o_Operation		: out	std_logic_vector (3 downto 0);
		o_ALU_Src		: out	std_logic;
		o_Reg_Dest		: out	std_logic;
		o_ALU_Enable	: out	std_logic;
		o_Reg_Write		: out	std_logic;
		o_GC_Enable		: out	std_logic
	);
end InstructionDecode;

architecture Behavioral of InstructionDecode is
	alias i_Flag	: std_logic_vector (2 downto 0) is i_Instr(31 downto 29);
	alias i_Opcode	: std_logic_vector (4 downto 0) is i_Instr(28 downto 24);
	
	alias cpsr_N is i_CPSR(7);
	alias cpsr_Z is i_CPSR(6);
	alias cpsr_C is i_CPSR(5);
	alias cpsr_V is i_CPSR(4);
	
	signal all_enable		: std_logic;
	signal res_operation	: integer range 0 to 15;
	signal res_control		: std_logic_vector (4 downto 0);
begin
	process (i_CLK)
	begin
		if rising_edge(i_CLK) then
			case i_Flag is
				when "001" =>	-- EQ
					all_enable <= cpsr_Z;
				when "010" =>	-- NE
					all_enable <= not cpsr_Z;
				when "011" =>	-- Always
					all_enable <= '1';
				when "100" =>	-- LT
					all_enable <= cpsr_N;
				when "101" =>	-- LE
					all_enable <= cpsr_Z or cpsr_N;
				when "110" =>	-- GT
					all_enable <= (not cpsr_Z) and (not cpsr_N);
				when "111" =>	-- GE
					all_enable <= not cpsr_N;
				when others =>
					all_enable <= '0';
			end case;
		end if;
	end process;
	
	process (i_CLK)
	begin
		if rising_edge(i_CLK) then
			if i_Enable = '1' then
				if 		i_Opcode = "00000" then		-- Basic ALU
					res_operation 	<= to_integer(unsigned(i_Instr(11 downto 8)));
					res_control		<= "01110";
				elsif 	i_Opcode = "00001" then		-- movi
					res_operation 	<= 0;
					res_control		<= "10110";
				elsif 	i_Opcode = "00010" then		-- addi
					res_operation 	<= 1;
					res_control		<= "10110";
				elsif 	i_Opcode = "00011" then		-- subi
					res_operation 	<= 2;
					res_control		<= "10110";
				elsif 	i_Opcode = "00100" then		-- muli
					res_operation 	<= 3;
					res_control		<= "10110";
				elsif 	i_Opcode = "00101" then		-- divi
					res_operation 	<= 4;
					res_control		<= "10110";
				elsif 	i_Opcode = "00110" then		-- cmpi
					res_operation 	<= 5;
					res_control		<= "10110";
				elsif 	i_Opcode = "00101" then		-- slli
					res_operation 	<= 6;
					res_control		<= "10110";
				elsif 	i_Opcode = "00110" then		-- srli
					res_operation 	<= 7;
					res_control		<= "10110";
				elsif 	i_Opcode = "00111" then		-- clr
					res_operation 	<= 15;
					res_control		<= "00100";
				elsif 	i_Opcode = "01000" then		-- andi
					res_operation 	<= 9;
					res_control		<= "10110";
				elsif 	i_Opcode = "01001" then		-- orri
					res_operation 	<= 10;
					res_control		<= "10110";
				elsif 	i_Opcode = "01010" then		-- xori
					res_operation 	<= 11;
					res_control		<= "10110";
				elsif 	i_Opcode = "10000" then		-- Display
					res_operation 	<= to_integer(unsigned(i_Instr(11 downto 8)));
					res_control		<= "00001";
				else
					res_operation 	<= 0;
					res_control		<= "00000";
				end if;
			else
				res_operation 	<= 0;
				res_control		<= "00000";
			end if;
		end if;
	end process;
	
	o_Operation 	<= std_logic_vector(to_unsigned(res_operation, 4));
	o_ALU_Src 		<= res_control(4);
	o_Reg_Dest 		<= res_control(3);
	o_ALU_Enable 	<= res_control(2) and all_enable;
	o_Reg_Write 	<= res_control(1) and all_enable;
	o_GC_Enable 	<= res_control(0) and all_enable;
	
end Behavioral;
