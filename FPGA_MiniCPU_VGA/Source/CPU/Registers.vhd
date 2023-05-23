library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity Registers is
	port (
		i_RdReg1		: in	std_logic_vector (3 downto 0);
		i_RdReg2		: in	std_logic_vector (3 downto 0);
		i_WrReg			: in	std_logic_vector (3 downto 0);
		i_WrData		: in	std_logic_vector (31 downto 0);
		i_WriteEnable	: in	std_logic;
		i_CLK			: in	std_logic;
		
		o_Data1			: out	std_logic_vector (31 downto 0);
		o_Data2			: out	std_logic_vector (31 downto 0)
	);
end Registers;

architecture Behavioral of Registers is
	type registers_t is array (0 to 15) 
		of std_logic_vector (31 downto 0);
	signal register_file: registers_t;
begin
	
	process (i_CLK, i_WriteEnable)
		variable tmp_rd1, tmp_rd2 : integer range 0 to 15;
	begin
		if rising_edge(i_CLK) then
			if i_WriteEnable = '1' then
				register_file(to_integer(unsigned(i_WrReg))) 
					<= i_WrData;
			end if;
			
			tmp_rd1 := to_integer(unsigned(i_RdReg1));
			tmp_rd2 := to_integer(unsigned(i_RdReg2));
			
			o_Data1 <= register_file(tmp_rd1);
			o_Data2 <= register_file(tmp_rd2);
		end if;
	end process;
	
end Behavioral;
