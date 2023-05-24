library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity CPU is
	port (
		i_Instr 		: in	std_logic_vector (31 downto 0);
		i_Enable 		: in	std_logic;
		i_CLK 			: in	std_logic;
		
		o_VRAM_Char 	: out	std_logic_vector (7 downto 0);
		o_VRAM_Addr 	: out	std_logic_vector (15 downto 0);
		o_VRAM_Cmd 		: out	std_logic_vector (4 downto 0);
		
		o_Busy 			: out	std_logic
	);
end CPU;

architecture Behavioral of CPU is
	signal reg_CPSR 		: std_logic_vector (7 downto 0);
	
	signal net_clk_d, net_clk_r, net_clk_e, net_clk_w
							: std_logic;
	
	signal net_Operation 	: std_logic_vector (3 downto 0);
	signal net_ALU_Src 		: std_logic;
	signal net_Reg_Dest 	: std_logic;
	signal net_Reg_Write 	: std_logic;
	signal net_ALU_Enable 	: std_logic;
	signal net_GC_Enable 	: std_logic;
	
	signal net_Reg_WrEn 	: std_logic;
	signal net_Reg_RdWr 	: std_logic;
	
	signal net_WrReg 		: std_logic_vector (3 downto 0);
	signal net_WrData 		: std_logic_vector (31 downto 0);
	
	signal net_Imm16to32 	: std_logic_vector (31 downto 0);
	
	signal net_RegRead1, net_RegRead2 
							: std_logic_vector (31 downto 0);
	
	signal net_ALU_in2		: std_logic_vector (31 downto 0);
begin
	
	--INST_CLK_CONTROL: entity work.ClockController(Behavioral) 
	--	port map (
	--		i_Enable		=> i_Enable,
	--		i_CLK			=> i_CLK,
	--		
	--		o_Clk_Decode	=> net_clk_d,
	--		o_Clk_RegisterR	=> net_clk_r,
	--		o_Clk_Execute	=> net_clk_e,
	--		o_Clk_RegisterW	=> net_clk_w,
	--		o_Busy			=> o_Busy
	--	);
	o_Busy <= '0';
	
	INST_IDECODER: entity work.InstructionDecode(Behavioral) 
		port map (
			i_Instr			=> i_Instr,
			i_CPSR			=> reg_CPSR,
			i_Enable		=> i_Enable,
			i_CLK			=> i_CLK,
			--i_Enable		=> '1',
			--i_CLK			=> net_clk_d,
			
			o_Operation		=> net_Operation,
			o_ALU_Src		=> net_ALU_Src,
			o_Reg_Dest		=> net_Reg_Dest,
			o_ALU_Enable	=> net_ALU_Enable,
			o_Reg_Write		=> net_Reg_Write,
			o_GC_Enable		=> net_GC_Enable
		);
	
	INST_MUX_REG1: entity work.Mux_2to1(Behavioral) 
		generic map (N => 4)
		port map (
			i0		=> i_Instr(19 downto 16),
			i1		=> i_Instr(15 downto 12),
			sel		=> net_Reg_Dest,
			
			o		=> net_WrReg
		);
	
	INST_SIGNEXT: entity work.SignExtend_16_32(Behavioral) 
		port map (
			i		=> i_Instr(15 downto 0),
			o		=> net_Imm16to32
		);
	
	--net_Reg_WrEn <= net_clk_w and net_Reg_Write;
	--net_Reg_RdWr <= net_clk_r or net_clk_w;
	
	INST_REGISTERS: entity work.Registers(Behavioral) 
		port map (
			i_RdReg1		=> i_Instr(23 downto 20),
			i_RdReg2		=> i_Instr(19 downto 16),
			i_WrReg			=> net_WrReg,
			i_WrData		=> net_WrData,
			--i_WriteEnable	=> net_Reg_WrEn,
			--i_CLK			=> net_Reg_RdWr,
			i_WriteEnable	=> net_Reg_Write,
			i_CLK			=> i_CLK,
			
			o_Data1			=> net_RegRead1,
			o_Data2			=> net_RegRead2
		);
	
	INST_MUX_REG2: entity work.Mux_2to1(Behavioral) 
		generic map (N => 32)
		port map (
			i0		=> net_RegRead2,
			i1		=> net_Imm16to32,
			sel		=> net_ALU_Src,
			
			o		=> net_ALU_in2
		);
	
	INST_ALU: entity work.ALU(Behavioral) 
		port map (
			i_Data1			=> net_RegRead1,
			i_Data2			=> net_ALU_in2,
			i_Operation		=> net_Operation,
			i_Enable		=> net_ALU_Enable,
			--i_CLK			=> net_clk_e,
			i_CLK			=> i_CLK,
			
			o_Res			=> net_WrData,
			o_CPSR			=> reg_CPSR
		);
	
	INST_GRAPHICS_C: entity work.GraphicsController(Behavioral) 
		port map (
			i_Data			=> net_RegRead1(15 downto 0),
			i_Operation		=> net_Operation,
			i_Enable		=> net_GC_Enable,
			--i_CLK			=> net_clk_e,
			i_CLK			=> i_CLK,
			
			o_VRAM_Char		=> o_VRAM_Char,
			o_VRAM_Addr		=> o_VRAM_Addr,
			o_VRAM_Cmd		=> o_VRAM_Cmd
		);
	
end Behavioral;

