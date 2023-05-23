LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
USE ieee.math_real.uniform;
USE ieee.math_real.floor;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_CPU IS
END test_CPU;
 
ARCHITECTURE behavior OF test_CPU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPU
    PORT(
         i_Instr : IN  std_logic_vector(31 downto 0);
         i_Enable : IN  std_logic;
         i_CLK : IN  std_logic;
         o_VRAM_Char : OUT  std_logic_vector(7 downto 0);
         o_VRAM_Addr : OUT  std_logic_vector(15 downto 0);
         o_VRAM_Cmd : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal i_Instr : std_logic_vector(31 downto 0) := (others => '0');
   signal i_Enable : std_logic := '0';
   signal i_CLK : std_logic := '0';

 	--Outputs
   signal o_VRAM_Char : std_logic_vector(7 downto 0);
   signal o_VRAM_Addr : std_logic_vector(15 downto 0);
   signal o_VRAM_Cmd : std_logic_vector(4 downto 0);

	constant CLK_P : time := 10 ns;
	constant CLK_P2 : time := CLK_P * 2;
	constant CLK_P3 : time := 15 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: CPU PORT MAP (
		i_Instr => i_Instr,
		i_Enable => i_Enable,
		i_CLK => i_CLK,
		o_VRAM_Char => o_VRAM_Char,
		o_VRAM_Addr => o_VRAM_Addr,
		o_VRAM_Cmd => o_VRAM_Cmd
	);

	i_CLK_process : process
	begin
		i_CLK <= '1';
		wait for CLK_P;
		i_CLK <= '0';
		wait for CLK_P;
	end process;
	
	
	-- Stimulus process
	stim_proc: process
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
		
		constant EQ	: std_logic_vector (2 downto 0) := "001";
		constant NE	: std_logic_vector (2 downto 0) := "010";
		constant AL	: std_logic_vector (2 downto 0) := "011";
		constant LT	: std_logic_vector (2 downto 0) := "100";
		constant LE	: std_logic_vector (2 downto 0) := "101";
		constant GT	: std_logic_vector (2 downto 0) := "110";
		constant GE	: std_logic_vector (2 downto 0) := "111";
		
		function MakeInsR (
			flag		: std_logic_vector (2 downto 0);
			opcode		: integer;
			rs, rt, rd	: integer;
			func		: integer
		) return std_logic_vector is begin
			return flag & ToUVec(opcode, 5) 
				& ToUVec(rs, 4) & ToUVec(rt, 4) & ToUVec(rd, 4)
				& ToUVec(func, 4) & "00000000";
		end function;
		
		function MakeInsI (
			flag		: std_logic_vector (2 downto 0);
			opcode		: integer;
			rs, rd		: integer;
			imm			: integer
		) return std_logic_vector is begin
			return flag & ToUVec(opcode, 5) 
				& ToUVec(rs, 4) & ToUVec(rd, 4)
				& ToSVec(imm, 16);
		end function;
		
		procedure EnablePulse is begin
			i_Enable <= '1';
			wait for CLK_P2;
			i_Enable <= '0';
			
			-- mov r0, r0
			i_Instr <= MakeInsR(AL, 0, 0, 0, 0, 0);
			for i in 0 to 0 loop
				i_Enable <= '1';
				wait for CLK_P;
				i_Enable <= '0';
				wait for CLK_P;
			end loop;
		end procedure;
	begin
		wait for 20 ns;	
		
		-- movi r0, 10
		i_Instr <= MakeInsI(AL, 1, 0, 0, 10);
		EnablePulse;
		
		-- movi r1, 64
		i_Instr <= MakeInsI(AL, 1, 0, 1, 64);
		EnablePulse;
		
		-- movi r2, -6
		i_Instr <= MakeInsI(AL, 1, 0, 2, -6);
		EnablePulse;
		
		-- add r3, r0, r1
		i_Instr <= MakeInsR(AL, 0, 0, 1, 3, 1);
		EnablePulse;
		
		-- dchr r1
		i_Instr <= MakeInsR(AL, 16, 1, 0, 0, 1);
		EnablePulse;
		
		-- dchr r3
		i_Instr <= MakeInsR(AL, 16, 3, 0, 0, 1);
		EnablePulse;
		
		wait;
	end process;

END;
