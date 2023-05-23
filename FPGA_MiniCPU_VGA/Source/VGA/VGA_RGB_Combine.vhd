library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA_RGB_Combine is
	port (
		i_RGB 	: in	std_logic_vector(2 downto 0);
		i_VGA 	: in	std_logic_vector(22 downto 0);
		
		o_VGA 	: out	std_logic_vector(4 downto 0)
	);
end entity VGA_RGB_Combine;


architecture Behavioral of VGA_RGB_Combine is
	alias VGA_RGB	: std_logic_vector (2 downto 0) is o_VGA(4 downto 2);
	alias VGA_HS	: std_logic is o_VGA(1);
	alias VGA_VS	: std_logic is o_VGA(0);
begin
	
	VGA_RGB <= i_RGB
		when i_VGA(0) = '1' else "000";
	
	VGA_HS <= i_VGA(2);
	VGA_VS <= i_VGA(1);

end architecture Behavioral;
