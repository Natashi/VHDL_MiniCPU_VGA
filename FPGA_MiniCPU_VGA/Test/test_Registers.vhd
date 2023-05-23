LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
USE ieee.math_real.uniform;
USE ieee.math_real.floor;
 
ENTITY test_Registers IS
END test_Registers;
 
ARCHITECTURE behavior OF test_Registers IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Registers
    PORT(
         i_RdReg1 : IN  std_logic_vector(3 downto 0);
         i_RdReg2 : IN  std_logic_vector(3 downto 0);
         i_WrReg : IN  std_logic_vector(3 downto 0);
         i_WrData : IN  std_logic_vector(31 downto 0);
         i_WriteEnable : IN  std_logic;
         i_CLK : IN  std_logic;
         o_Data1 : OUT  std_logic_vector(31 downto 0);
         o_Data2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal i_RdReg1 : std_logic_vector(3 downto 0) := (others => '0');
   signal i_RdReg2 : std_logic_vector(3 downto 0) := (others => '0');
   signal i_WrReg : std_logic_vector(3 downto 0) := (others => '0');
   signal i_WrData : std_logic_vector(31 downto 0) := (others => '0');
   signal i_WriteEnable : std_logic := '0';
   signal i_CLK : std_logic := '0';

 	--Outputs
   signal o_Data1 : std_logic_vector(31 downto 0);
   signal o_Data2 : std_logic_vector(31 downto 0);

	constant CLK_P : time := 10 ns;
	constant CLK_P2 : time := CLK_P * 2;
BEGIN
 
	uut: Registers PORT MAP (
		i_RdReg1 => i_RdReg1,
		i_RdReg2 => i_RdReg2,
		i_WrReg => i_WrReg,
		i_WrData => i_WrData,
		i_WriteEnable => i_WriteEnable,
		i_CLK => i_CLK,
		o_Data1 => o_Data1,
		o_Data2 => o_Data2
	);
	
	i_CLK_process : process
	begin
		i_CLK <= '1';
		wait for CLK_P;
		i_CLK <= '0';
		wait for CLK_P;
	end process;
	
	stim_proc : process
		variable seed1 : positive := 999;
		variable seed2 : positive := 99;
		
		impure function Rand_V32 (
			min_v, max_v	: real
		) return std_logic_vector is
			variable r : real;
		begin
			uniform(seed1, seed2, r);
			r := min_v + r * (max_v - min_v);
			return std_logic_vector(to_signed(integer(r), 32));
		end function;
		
		function ToUVec (
			x : integer;
			n : integer
		) return std_logic_vector is
		begin
			return std_logic_vector(to_unsigned(x, n));
		end function;
	begin
		wait for 20 ns;
		
		i_WriteEnable <= '1';
		for i in 0 to 15 loop
			i_RdReg1 <= ToUVec(i, 4);
			i_WrReg <= i_RdReg1;
			i_WrData <= Rand_V32(-1024.0, 1024.0);
			wait for CLK_P2;
		end loop;
		i_WriteEnable <= '0';
		
		wait for 20 ns;
		
		i_RdReg1 <= "0000";
		for i in 0 to 15 loop
			i_RdReg2 <= ToUVec(i, 4);
			wait for CLK_P2;
		end loop;
		
		wait for 20 ns;
		
		i_WriteEnable <= '1';
		i_WrReg <= ToUVec(15, 4);
		i_WrData <= ToUVec(9999, 32);
		wait for CLK_P2;
		i_WriteEnable <= '0';
		
		wait;
	end process;

END;
