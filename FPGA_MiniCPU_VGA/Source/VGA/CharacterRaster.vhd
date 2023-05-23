library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity CharacterRaster is
	port (
		i_Dots		: in	std_logic_vector (95 downto 0);
		i_DotPos	: in	std_logic_vector (15 downto 0);
		i_Color		: in	std_logic_vector (2 downto 0);
		
		o_RGB		: out	std_logic_vector (2 downto 0)
	);
end CharacterRaster;

architecture Behavioral of CharacterRaster is
	signal tmp_x 	: integer range 0 to 7;
	signal tmp_y 	: integer range 0 to 11;
	signal pix 		: std_logic;
begin
	
	-- Dots = 8x12
	
	tmp_x <= to_integer(unsigned(i_DotPos(7 downto 0)));
	tmp_y <= to_integer(unsigned(i_DotPos(15 downto 8)));
	
	pix <= i_Dots(tmp_y * 8 + tmp_x);
	
	o_RGB(2) <= pix and i_Color(2);
	o_RGB(1) <= pix and i_Color(1);
	o_RGB(0) <= pix and i_Color(0);
	
end Behavioral;
