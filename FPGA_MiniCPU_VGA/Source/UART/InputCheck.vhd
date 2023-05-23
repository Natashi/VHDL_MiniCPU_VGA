library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity InputCheck is
	port (
		i_Data		: in	std_logic_vector (31 downto 0);
		i_Hash		: in	std_logic_vector (7 downto 0);
		
		o_Valid		: out	std_logic
	);
end InputCheck;

architecture Behavioral of InputCheck is
	signal tmp_xor	: std_logic_vector (7 downto 0);
begin
	
	tmp_xor <= i_Data(31 downto 24)
		xor i_Data(23 downto 16)
		xor i_Data(15 downto 8)
		xor i_Data(7 downto 0);
	
	o_Valid <= '1' when i_Hash = tmp_xor else '0';
	
end Behavioral;
