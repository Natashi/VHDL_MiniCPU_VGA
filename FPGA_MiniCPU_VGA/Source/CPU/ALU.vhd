library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ALU is
	port (
		i_Data1		: in	std_logic_vector (31 downto 0);
		i_Data2		: in	std_logic_vector (31 downto 0);
		i_Operation	: in	std_logic_vector (3 downto 0);
		i_Enable	: in	std_logic;
		i_CLK		: in	std_logic;
		
		o_Res		: out	std_logic_vector (31 downto 0);
		o_CPSR		: out	std_logic_vector (7 downto 0)
	);
end ALU;

architecture Behavioral of ALU is
	signal result	: signed (32 downto 0);
	signal temp_ov	: std_logic_vector (2 downto 0);
begin
	
	process (i_CLK, i_Enable)
		variable A, B 	: signed (32 downto 0);
	begin
		if rising_edge(i_CLK) and i_Enable = '1' then
			-- Sign extension to 33 bit
			A := resize(signed(i_Data1), 33);	-- From rd1
			B := resize(signed(i_Data2), 33);	-- From rd2 or imm
			
			if 		i_Operation = "0000" then	-- mov
				result <= B;
			
			elsif	i_Operation = "0001" then	-- add
				result <= A + B;
			
			elsif	i_Operation = "0010" then	-- sub
				result <= A - B;
			
			elsif	i_Operation = "0011" then	-- mul
				result <= resize(A * B, 33);
			
			elsif	i_Operation = "0100" then	-- div
				result <= A / B;
			
			elsif	i_Operation = "0101" then	-- cmp
				result <= A - B;
			
			elsif	i_Operation = "0110" then	-- sll
				result <= shift_left(A, to_integer(B));
			
			elsif	i_Operation = "0111" then	-- srl
				result <= shift_right(A, to_integer(B));
			
			elsif	i_Operation = "1000" then	-- neg
				result <= -A;
			
			elsif	i_Operation = "1001" then	-- and
				result <= A and B;
			
			elsif	i_Operation = "1010" then	-- orr
				result <= A or B;
			
			elsif	i_Operation = "1011" then	-- xor
				result <= A xor B;
			
			elsif	i_Operation = "1100" then	-- not
				result <= not A;
			
			elsif	i_Operation = "1111" then	-- clr
				result <= to_signed(1, 33);
			
			else result <= (others => '0');
			end if;
		end if;
	end process;
	
	o_Res <= std_logic_vector(result(31 downto 0));
	
	-- Concat all sign bits into one vec
	temp_ov <= i_Data1(31) & i_Data2(31) & result(32);
	
	-- N: Negative
	o_CPSR(7) <= '1' 
		when result < 0
		else '0';
	
	-- Z: Zero
	o_CPSR(6) <= '1' 
		when result = 0 
		else '0';
	
	-- C: Carry
	o_CPSR(5) <= result(32);
	
	-- V: Overflow
	o_CPSR(4) <= '1' 
		when (temp_ov = "001" or temp_ov = "110")
		else '0';
	
	o_CPSR(3 downto 0) <= "0000";
	
end Behavioral;
