library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SignExtend_16_32 is
	port (
		i		: in	std_logic_vector (15 downto 0);
		o		: out	std_logic_vector (31 downto 0)
	);
end SignExtend_16_32;

architecture Behavioral of SignExtend_16_32 is
begin
	
	o <= "0000000000000000" & i 
		 when i(15) = '0' else 
		 "1111111111111111" & i;
	
end Behavioral;
