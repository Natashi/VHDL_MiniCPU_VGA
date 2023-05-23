library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux_2to1 is
	generic(
		N		: integer := 32
	); 
	port (
		i0		: in	std_logic_vector (N-1 downto 0);
		i1		: in	std_logic_vector (N-1 downto 0);
		sel		: in	std_logic;
		o		: out	std_logic_vector (N-1 downto 0)
	);
end Mux_2to1;

architecture Behavioral of Mux_2to1 is
begin
	
	o <= i0 when sel = '0' else i1;
	
end Behavioral;
