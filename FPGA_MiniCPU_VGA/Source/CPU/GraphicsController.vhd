library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity GraphicsController is
	port (
		i_Data			: in	std_logic_vector (15 downto 0);
		i_Operation		: in	std_logic_vector (3 downto 0);
		i_Enable		: in	std_logic;
		i_CLK			: in	std_logic;
		
		o_VRAM_Char		: out	std_logic_vector (7 downto 0);
		o_VRAM_Addr		: out	std_logic_vector (15 downto 0);
		o_VRAM_Cmd		: out	std_logic_vector (4 downto 0)
	);
end GraphicsController;

architecture Behavioral of GraphicsController is
	signal cursor_x		: integer range 0 to 79 := 0;
	signal cursor_y		: integer range 0 to 39 := 0;
	signal color		: std_logic_vector (2 downto 0) := "000";
	
	signal w_write		: std_logic := '0';
	signal w_reset		: std_logic := '0';
begin
	
	process (i_CLK, i_Enable)
		variable tmp_chr : integer range 0 to 255;
	begin
		if rising_edge(i_CLK) and i_Enable = '1' then
			w_write <= '0';
			w_reset <= '0';
			
			if 		i_Operation = "0000" then		-- clr
				
				w_reset <= '1';
				
			elsif 	i_Operation = "0001" then		-- display char
				
				w_write <= '1';
				
				tmp_chr := to_integer(unsigned(i_Data(7 downto 0)));
				if tmp_chr < 32 or tmp_chr > 127 then
					tmp_chr := 32;
				end if;
				
				o_VRAM_Char <= std_logic_vector(to_unsigned(tmp_chr, 8));
				
				cursor_x <= cursor_x + 1;
				
			elsif 	i_Operation = "0011" then		-- set cursor
				
				cursor_x <= to_integer(unsigned(i_Data(7 downto 0)));
				cursor_y <= to_integer(unsigned(i_Data(15 downto 8)));
				
			elsif 	i_Operation = "0100" then		-- set color
				
				color <= i_Data(2 downto 0);
				
			end if;
		end if;
	end process;
	
	o_VRAM_Addr(7 downto 0)  <= std_logic_vector(to_unsigned(cursor_x, 8));
	o_VRAM_Addr(15 downto 8) <= std_logic_vector(to_unsigned(cursor_y, 8));
	
	o_VRAM_Cmd <= color & (w_write and i_Enable) & w_reset;
	
end Behavioral;
