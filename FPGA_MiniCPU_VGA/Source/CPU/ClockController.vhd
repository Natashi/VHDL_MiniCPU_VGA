library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity ClockController is
	port (
		i_Enable		: in	std_logic;
		i_CLK			: in	std_logic;
		
		o_Clk_Decode	: out	std_logic;
		o_Clk_RegisterR	: out	std_logic;
		o_Clk_Execute	: out	std_logic;
		o_Clk_RegisterW	: out	std_logic;
		o_Busy			: out	std_logic
	);
end ClockController;

architecture Behavioral of ClockController is
	type fsm_states_t is (IDLE, BUSY, STOP);
    signal fsm_state : fsm_states_t := IDLE;
	
    signal c_counter : integer range 0 to 3;
begin
	process (i_CLK, i_Enable)
	begin
		if rising_edge(i_CLK) then
			case fsm_state is
				when IDLE => 
					
					if i_Enable = '1' then
						o_Clk_Decode 	<= '0';
						o_Clk_RegisterR	<= '0';
						o_Clk_Execute 	<= '0';
						o_Clk_RegisterW <= '0';
						
						c_counter <= 0;
						fsm_state <= BUSY;
					end if;
					
				when BUSY => 
					
					case c_counter is
						when 0 =>
							
							o_Clk_Decode	<= '1';
							c_counter		<= 1;
							
						when 1 =>
							
							o_Clk_Decode	<= '0';
							o_Clk_RegisterR	<= '1';
							c_counter		<= 2;
							
						when 2 =>
							
							o_Clk_RegisterR	<= '0';
							o_Clk_Execute	<= '1';
							c_counter		<= 3;
							
						when 3 =>
							
							o_Clk_Execute	<= '0';
							o_Clk_RegisterW	<= '1';
							c_counter		<= 0;
							
							fsm_state <= STOP;
							
					end case;
					
				when STOP => 
					
					o_Clk_Decode 	<= '0';
					o_Clk_RegisterR	<= '0';
					o_Clk_Execute 	<= '0';
					o_Clk_RegisterW <= '0';
					
					fsm_state <= IDLE;
					
			end case;
		end if;
	end process;
	
	o_Busy <= '0' when fsm_state = IDLE else '1';
	
end Behavioral;
