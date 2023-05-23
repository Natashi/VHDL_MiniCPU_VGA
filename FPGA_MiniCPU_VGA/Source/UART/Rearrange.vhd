library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- !! THIS VHDL SOURCE IS NOT USED: UNNECESSARY !!

-- Got:
--		39													0
-- 		b4[7 to 0] b3[7 to 0] b2[7 to 0] b1[7 to 0] b0[7 to 0]
-- Need:
--		39													0
-- 		b0[7 to 0] b1[7 to 0] b2[7 to 0] b3[7 to 0] b4[7 to 0]

entity Rearrange is
	port (
		i_Data		: in	std_logic_vector (39 downto 0);
		o_Data		: out	std_logic_vector (39 downto 0)
	);
end Rearrange;

architecture Behavioral of Rearrange is
begin
	
	o_Data(39 downto 32)	<= i_Data(7 downto 0);
	o_Data(31 downto 24)	<= i_Data(15 downto 8);
	o_Data(23 downto 16)	<= i_Data(23 downto 16);
	o_Data(15 downto 8)		<= i_Data(31 downto 24);
	o_Data(7 downto 0)		<= i_Data(39 downto 32);
	
end Behavioral;
