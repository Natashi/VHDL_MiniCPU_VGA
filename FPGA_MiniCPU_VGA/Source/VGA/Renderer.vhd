library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Renderer is
	port (
		i_VGA		: in	std_logic_vector (22 downto 0);
		i_CLK		: in	std_logic;
		
		o_CharID	: out	std_logic_vector (15 downto 0);
		o_DotPos	: out	std_logic_vector (15 downto 0)
	);
end Renderer;

architecture Behavioral of Renderer is
	alias VGA_X 	: std_logic_vector (9 downto 0) is i_VGA(22 downto 13);
	alias VGA_Y 	: std_logic_vector (9 downto 0) is i_VGA(12 downto 3);
	
	signal tmp_x1, tmp_y1	: unsigned (7 downto 0);
	signal tmp_x2, tmp_y2	: unsigned (7 downto 0);
begin
	
	-- Screen resolution: 640x480
	-- 1 char = 8x12
	
	process (i_CLK)
		variable tmp_x, tmp_y : unsigned (9 downto 0);
	begin
		if rising_edge(i_CLK) then
			if i_VGA(0) = '1' then
				tmp_x := unsigned(VGA_X) / 2;
				tmp_y := unsigned(VGA_Y) / 2;
				
				tmp_x1 <= resize(tmp_x / 8, 8);
				tmp_y1 <= resize(tmp_y / 12, 8);
				
				tmp_x2 <= 7 - resize(tmp_x mod 8, 8);
				tmp_y2 <= 11 - resize(tmp_y mod 12, 8);
			else
				tmp_x1 <= (others => '0');
				tmp_y1 <= (others => '0');
				tmp_x2 <= (others => '0');
				tmp_x2 <= (others => '0');
			end if;
		end if;
	end process;
	
	o_CharID(15 downto 8) <= std_logic_vector(tmp_y1);
	o_CharID(7 downto 0)  <= std_logic_vector(tmp_x1);
	
	o_DotPos(15 downto 8) <= std_logic_vector(tmp_y2);
	o_DotPos(7 downto 0)  <= std_logic_vector(tmp_x2);
	
end Behavioral;
