library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity InputCheck is
	port (
		i_Data		: in	std_logic_vector (31 downto 0);
		i_Hash		: in	std_logic_vector (7 downto 0);
		i_Enable	: in	std_logic;
		
		o_Valid		: out	std_logic
	);
end InputCheck;

architecture Behavioral of InputCheck is
	signal valid	: std_logic := '0';
begin
	
	process (i_Enable)
		variable tmp_xor	: std_logic_vector (7 downto 0);
	begin
		if rising_edge(i_Enable) then
			tmp_xor := not (
				i_Data(31 downto 24)
				xor i_Data(23 downto 16)
				xor i_Data(15 downto 8)
				xor i_Data(7 downto 0));
			
			if i_Hash = tmp_xor then
				valid <= '1';
			else
				valid <= '0';
			end if;
		end if;
	end process;
	
	o_Valid <= valid;
	
end Behavioral;
