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
	-- 1 char = 7 bytes (32 ~ 127)
	
	type vram_t is array (3199 downto 0) 
		of std_logic_vector (6 downto 0);
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
			--if i_Reset = '1' then
			--	for i in 0 to 3199 loop
			--		vram(i) <= (others => '0');
			--	end loop;
			--else
				if i_Write = '1' then
					wr_x := to_integer(unsigned(i_WrAddr(6 downto 0)));
					wr_y := to_integer(unsigned(i_WrAddr(14 downto 8)));
				
					vram(wr_y * 80 + wr_x) <= i_WrData(6 downto 0);
				end if;
			--end if;
			
			rd_x <= to_integer(unsigned(i_RdAddr(6 downto 0)));
			rd_y <= to_integer(unsigned(i_RdAddr(14 downto 8)));
			o_Char <= '0' & vram(rd_y * 80 + rd_x);
		end if;
	end process;
	
	o_Color <= i_Color;
	
end Behavioral;
