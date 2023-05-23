library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity VRAM is
	port (
		i_WrData	: in	std_logic_vector (7 downto 0);
		i_WrAddr	: in	std_logic_vector (15 downto 0);
		i_Cmd		: in	std_logic_vector (4 downto 0);
		i_RdAddr	: in	std_logic_vector (15 downto 0);
		i_CLK		: in	std_logic;
		
		o_Char		: out	std_logic_vector (7 downto 0);
		o_Color		: out	std_logic_vector (2 downto 0)
	);
end VRAM;

architecture Behavioral of VRAM is
	-- 640x480
	-- 1 char takes up 8x12
	--   = 80 char / line
	--   = 40 lines / screen
	-- 1 char = 8 bytes
	
	subtype char_t is std_logic_vector (7 downto 0);
	
	type vram_t is array (39 downto 0, 79 downto 0) of char_t;
	signal vram		: vram_t;
	
	alias i_Color 	: std_logic_vector (2 downto 0) is i_Cmd(4 downto 2);
	alias i_Write 	: std_logic is i_Cmd(1);
	alias i_Reset 	: std_logic is i_Cmd(0);
	
	signal rd_x	: integer range 0 to 79;
	signal rd_y	: integer range 0 to 39;
	
	signal tmp_pix	: std_logic;
begin
	
	process (i_CLK)
		variable wr_x	: integer range 0 to 79;
		variable wr_y	: integer range 0 to 39;
	begin
		if rising_edge(i_CLK) then
			if i_Reset = '1' then
				for iy in 0 to 39 loop
					for ix in 0 to 79 loop
						vram(iy, ix) <= (others => '0');
					end loop;
				end loop;
			else
				if i_Write = '1' then
					wr_x := to_integer(unsigned(i_WrAddr(7 downto 0)));
					wr_y := to_integer(unsigned(i_WrAddr(15 downto 8)));
				
					vram(wr_y, wr_x) <= i_WrData;
				end if;
			end if;
		end if;
	end process;
	
	rd_x <= to_integer(unsigned(i_RdAddr(7 downto 0)));
	rd_y <= to_integer(unsigned(i_RdAddr(15 downto 8)));
	
	o_Char <= vram(rd_y, rd_x);
	
	o_Color <= i_Color;
	
end Behavioral;
