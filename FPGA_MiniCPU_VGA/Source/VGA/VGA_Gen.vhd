-- Video mode			640x480 @ 60hz
-- Aspect Ratio			4:3

-- Expected Pixel Clock	25.175 	MHz
-- Actual Pixel Clock		25 	MHz (40ns)

-- Horizontal:
-- 		Visible area:	640	px
-- 		Front porch:	16	px
-- 		Sync pulse:		96	px
-- 		Back porch:		48	px
-- 		Whole line:		800	px
--			->	32us / line
-- 
-- Vertical:
-- 		Visible area:	480	lines
-- 		Front porch:	10	lines
-- 		Sync pulse:		2	lines
-- 		Back porch:		33	lines
-- 		Whole line:		525	lines
--			->	16.8ms / frame
--			->	~59.52 fps

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_Gen is
	port (
		i_Clk 		: in  std_logic;
		o_VGA		: out std_logic_vector (22 downto 0)
	);
end VGA_Gen;

architecture Behavioral of VGA_Gen is
	subtype uint10_t 	is integer range 0 to 1000;

	constant H_VISIBLE 	: uint10_t := 640;
	constant H_FPORCH 	: uint10_t := 16;
	constant H_SYNC 	: uint10_t := 96;
	constant H_BPORCH 	: uint10_t := 48;
	constant H_PRESYNC 	: uint10_t := H_VISIBLE + H_FPORCH;
	constant H_POSTSYNC : uint10_t := H_PRESYNC + H_SYNC;
	constant H_SIZE 	: uint10_t := 800;

	constant V_VISIBLE 	: uint10_t := 480;
	constant V_FPORCH 	: uint10_t := 10;
	constant V_SYNC 	: uint10_t := 2;
	constant V_BPORCH 	: uint10_t := 33;
	constant V_PRESYNC 	: uint10_t := V_VISIBLE + V_FPORCH;
	constant V_POSTSYNC : uint10_t := V_PRESYNC + V_SYNC;
	constant V_SIZE 	: uint10_t := 525;

	signal CT_X : std_logic_vector (9 downto 0) := "0000000000";
	signal CT_Y : std_logic_vector (9 downto 0) := "0000000000";

begin
	process (i_Clk) begin
		if rising_edge(i_Clk) then
			CT_X <= CT_X + 1;
			if (CT_X >= H_SIZE) then
				CT_X <= "0000000000";
				CT_Y <= CT_Y + 1;
				if (CT_Y >= V_SIZE) then
					CT_Y <= "0000000000";
				end if;
			end if;
		end if;
	end process;

	o_VGA(22 downto 13) <= CT_X;
	o_VGA(12 downto 3)  <= CT_Y;
	
	-- HSYNC
	o_VGA(2) <= '0' when 
		((CT_X >= H_PRESYNC) and (CT_X < H_POSTSYNC)) 
		else '1';
	
	-- VSYNC
	o_VGA(1) <= '0' when 
		((CT_Y >= V_PRESYNC) and (CT_Y < V_POSTSYNC)) 
		else '1';
	
    -- ACTIVE
	o_VGA(0) <= '1' 
		when ((CT_X < H_VISIBLE) and (CT_Y < V_VISIBLE)) 
		else '0';

end Behavioral;