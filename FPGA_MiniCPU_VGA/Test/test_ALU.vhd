LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
USE ieee.math_real.uniform;
USE ieee.math_real.floor;
 
ENTITY test_ALU IS
END test_ALU;
 
ARCHITECTURE behavior OF test_ALU IS 
	COMPONENT ALU
	PORT(
		 i_Data1 : IN  std_logic_vector(31 downto 0);
		 i_Data2 : IN  std_logic_vector(31 downto 0);
		 i_Operation : IN  std_logic_vector(3 downto 0);
		 i_Enable : IN  std_logic;
		 i_CLK : IN  std_logic;
		 o_Res : OUT  std_logic_vector(31 downto 0);
		 o_CPSR : OUT  std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	--Inputs
	signal i_Data1 : std_logic_vector(31 downto 0) := (others => '0');
	signal i_Data2 : std_logic_vector(31 downto 0) := (others => '0');
	signal i_Operation : std_logic_vector(3 downto 0) := (others => '0');
	signal i_Enable : std_logic := '0';
	signal i_CLK : std_logic := '0';

	--Outputs
	signal o_Res : std_logic_vector(31 downto 0);
	signal o_CPSR : std_logic_vector(7 downto 0);
	
	constant CLK_P : time := 10 ns;
	constant CLK_P2 : time := CLK_P * 2;
BEGIN
	uut: ALU port map (
		i_Data1 => i_Data1,
		i_Data2 => i_Data2,
		i_Operation => i_Operation,
		i_Enable => i_Enable,
		i_CLK => i_CLK,
		o_Res => o_Res,
		o_CPSR => o_CPSR
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
		
		impure function Rand_Real (
			min_v, max_v	: real
		) return real is
			variable r : real;
		begin
			uniform(seed1, seed2, r);
			return min_v + r * (max_v - min_v);
		end function;
		
		impure function Rand_V32 (
			min_v, max_v	: real
		) return std_logic_vector is
		begin
			return std_logic_vector(
				to_signed(integer(Rand_Real(min_v, max_v)), 32));
		end function;
		
		function ToUVec (
			x : integer;
			n : integer
		) return std_logic_vector is
		begin
			return std_logic_vector(to_unsigned(x, n));
		end function;
		
		function ToSVec (
			x : integer;
			n : integer
		) return std_logic_vector is
		begin
			return std_logic_vector(to_signed(x, n));
		end function;
		
		procedure EnablePulse is begin
			i_Enable <= '1';
			wait for CLK_P2;
			i_Enable <= '0';
		end procedure;
	begin
		wait for 20 ns;
		
		-- mov
		i_Operation <= "0000";
		for i in 0 to 0 loop
			i_Data2 <= Rand_V32(-1024.0, 1024.0);
			EnablePulse;
			wait for CLK_P2;
		end loop;
		
		-- clr
		i_Operation <= "1111";
		EnablePulse;
		wait for CLK_P2;
		
		-- add
		i_Operation <= "0001";
		for i in 0 to 1 loop
			i_Data1 <= Rand_V32(-1024.0, 1024.0);
			i_Data2 <= Rand_V32(-1024.0, 1024.0);
			EnablePulse;
			wait for CLK_P2;
		end loop;
		
		-- sub
		i_Operation <= "0010";
		for i in 0 to 1 loop
			i_Data1 <= Rand_V32(-1024.0, 1024.0);
			i_Data2 <= Rand_V32(-1024.0, 1024.0);
			EnablePulse;
			wait for CLK_P2;
		end loop;
		
		-- mul
		i_Operation <= "0011";
		for i in 0 to 4 loop
			i_Data1 <= Rand_V32(-128.0, 128.0);
			i_Data2 <= Rand_V32(-128.0, 128.0);
			EnablePulse;
			wait for CLK_P2;
		end loop;
		
		-- div
		i_Operation <= "0100";
		for i in 0 to 4 loop
			i_Data1 <= Rand_V32(-128.0, 128.0);
			i_Data2 <= Rand_V32(-128.0, 128.0);
			EnablePulse;
			wait for CLK_P2;
		end loop;
		
		-- sll
		i_Operation <= "0110";
		for i in 0 to 2 loop
			i_Data1 <= Rand_V32(-1024.0, 1024.0);
			i_Data2 <= Rand_V32(0.0, 32.0);
			EnablePulse;
			wait for CLK_P2;
		end loop;
		
		-- srl
		i_Operation <= "0111";
		for i in 0 to 2 loop
			i_Data1 <= Rand_V32(-1024.0, 1024.0);
			i_Data2 <= Rand_V32(0.0, 32.0);
			EnablePulse;
			wait for CLK_P2;
		end loop;
		
		-- neg
		i_Operation <= "1000";
		i_Data1 <= ToUVec(533, 32);
		EnablePulse;
		wait for CLK_P2;
		i_Data1 <= ToUVec(-666, 32);
		EnablePulse;
		wait for CLK_P2;
		
		-- and, or, xor
		for op in 9 to 11 loop
			i_Operation <= ToUVec(op, 4);
			for i in 0 to 2 loop
				i_Data1 <= Rand_V32(-1024.0, 1024.0);
				i_Data2 <= Rand_V32(-1024.0, 1024.0);
				EnablePulse;
				wait for CLK_P2;
			end loop;
		end loop;
		
		wait for CLK_P2;
		
		---- cmp
		--i_Operation <= "0100";
		--
		--i_Data1 <= ToSVec(0, 32);
		--i_Data2 <= ToSVec(0, 32);
		--EnablePulse;
		--wait for CLK_P2;
		--
		--i_Data1 <= ToSVec(10, 32);
		--i_Data2 <= ToSVec(0, 32);
		--EnablePulse;
		--wait for CLK_P2;
		--
		--i_Data1 <= ToSVec(-10, 32);
		--i_Data2 <= ToSVec(-20, 32);
		--EnablePulse;
		--wait for CLK_P2;
		--
		--i_Data1 <= ToSVec(0, 32);
		--i_Data2 <= ToSVec(10, 32);
		--EnablePulse;
		--wait for CLK_P2;
		--
		--i_Data1 <= ToSVec(-20, 32);
		--i_Data2 <= ToSVec(-10, 32);
		--EnablePulse;
		--wait for CLK_P2;
		
		wait;
	end process;

END;
