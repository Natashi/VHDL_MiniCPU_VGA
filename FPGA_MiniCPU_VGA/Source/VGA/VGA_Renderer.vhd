library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA_Renderer is
	port (
		i_Data 			: in  std_logic_vector (7 downto 0);
		i_Addr 			: in  std_logic_vector (15 downto 0);
		i_Cmd 			: in  std_logic_vector (4 downto 0);
		i_CLK 			: in  std_logic;
		
		o_VGA			: out std_logic_vector (4 downto 0)
	);
end VGA_Renderer;

architecture Behavioral of VGA_Renderer is
	signal net_Char			: std_logic_vector (7 downto 0);
	signal net_Color		: std_logic_vector (2 downto 0);
	
	signal net_VGA			: std_logic_vector (22 downto 0);
	
	signal net_Ren_CharID		: std_logic_vector (15 downto 0);
	signal net_Ren_DotPos	: std_logic_vector (15 downto 0);
	
	signal net_Dots			: std_logic_vector (95 downto 0);
	
	signal net_OutRGB		: std_logic_vector (2 downto 0);
begin
	
	INST_VRAM: entity work.VRAM(Behavioral) 
		port map (
			i_WrData	=> i_Data,
			i_WrAddr	=> i_Addr,
			i_Cmd		=> i_Cmd,
			i_RdAddr	=> net_Ren_CharID,
			i_CLK		=> i_CLK,
			
			o_Char		=> net_Char,
			o_Color		=> net_Color
		);
	
	INST_VGA_GEN: entity work.VGA_Gen(Behavioral) 
		port map (
			i_Clk 		=> i_CLK,
			o_VGA		=> net_VGA
		);
	
	INST_RENDERER: entity work.Renderer(Behavioral) 
		port map (
			i_VGA		=> net_VGA,
			i_Clk		=> i_CLK,
			
			o_CharID	=> net_Ren_CharID,
			o_DotPos	=> net_Ren_DotPos
		);
	
	INST_CROM: entity work.CharacterROM(Behavioral) 
		port map (
			i_Char		=> net_Char,
			i_Clk		=> i_CLK,
			
			o_Dots		=> net_Dots
		);
	
	INST_RASTER: entity work.CharacterRaster(Behavioral) 
		port map (
			i_Dots		=> net_Dots,
			i_DotPos	=> net_Ren_DotPos,
			i_Color		=> net_Color,
			
			o_RGB		=> net_OutRGB
		);
	
	INST_VGA_COMBINE: entity work.VGA_RGB_Combine(Behavioral) 
		port map (
			i_RGB	=> net_OutRGB,
			i_VGA	=> net_VGA,
			
			o_VGA	=> o_VGA
		);
	
end Behavioral;
