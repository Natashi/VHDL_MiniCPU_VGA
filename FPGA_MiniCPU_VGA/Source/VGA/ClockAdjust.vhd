--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : dcm_clock.vhf
-- /___/   /\     Timestamp : 05/21/2023 09:36:50
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: /opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/unwrapped/sch2hdl -intstyle ise -family spartan6 -flat -suppress -vhdl dcm_clock.vhf -w /home/ise/ComHardware/testVerilog/dcm_clock.sch
--Design Name: dcm_clock
--Device: spartan6
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity ClockAdjust is
   port ( i_Clk : in    std_logic; 
          o_Clk : out   std_logic);
end ClockAdjust;

architecture BEHAVIORAL of ClockAdjust is
   attribute CLKFXDV_DIVIDE  : string ;
   attribute CLKFX_DIVIDE    : string ;
   attribute CLKFX_MD_MAX    : string ;
   attribute CLKFX_MULTIPLY  : string ;
   attribute CLKIN_PERIOD    : string ;
   attribute SPREAD_SPECTRUM : string ;
   attribute STARTUP_WAIT    : string ;
   attribute BOX_TYPE        : string ;
   signal XLXN_3 : std_logic;
   component DCM_CLKGEN
      -- synopsys translate_off
      generic( CLKFXDV_DIVIDE : integer :=  2;
               CLKFX_DIVIDE : integer :=  1;
               CLKFX_MULTIPLY : integer :=  4;
               CLKIN_PERIOD : real :=  0.0;
               SPREAD_SPECTRUM : string :=  "NONE";
               STARTUP_WAIT : boolean :=  FALSE);
      -- synopsys translate_on
      port ( CLKIN     : in    std_logic; 
             FREEZEDCM : in    std_logic; 
             PROGCLK   : in    std_logic; 
             PROGDATA  : in    std_logic; 
             PROGEN    : in    std_logic; 
             RST       : in    std_logic; 
             STATUS    : out   std_logic_vector (2 downto 1); 
             CLKFX     : out   std_logic; 
             CLKFX180  : out   std_logic; 
             CLKFXDV   : out   std_logic; 
             LOCKED    : out   std_logic; 
             PROGDONE  : out   std_logic);
   end component;
   attribute CLKFXDV_DIVIDE of DCM_CLKGEN : component is "2";
   attribute CLKFX_DIVIDE of DCM_CLKGEN : component is "1";
   attribute CLKFX_MD_MAX of DCM_CLKGEN : component is "0.000";
   attribute CLKFX_MULTIPLY of DCM_CLKGEN : component is "4";
   attribute CLKIN_PERIOD of DCM_CLKGEN : component is "0.0";
   attribute SPREAD_SPECTRUM of DCM_CLKGEN : component is "NONE";
   attribute STARTUP_WAIT of DCM_CLKGEN : component is "FALSE";
   attribute BOX_TYPE of DCM_CLKGEN : component is "BLACK_BOX";
   
   component GND
      port ( G : out   std_logic);
   end component;
   attribute BOX_TYPE of GND : component is "BLACK_BOX";
   
   attribute CLKIN_PERIOD of XLXI_1 : label is "50.0";
   attribute CLKFX_MULTIPLY of XLXI_1 : label is "5";
   attribute CLKFX_DIVIDE of XLXI_1 : label is "4";
begin
   XLXI_1 : DCM_CLKGEN
   -- synopsys translate_off
   generic map( CLKIN_PERIOD => 50.0,
            CLKFX_MULTIPLY => 5,
            CLKFX_DIVIDE => 4)
   -- synopsys translate_on
      port map (CLKIN=>i_Clk,
                FREEZEDCM=>XLXN_3,
                PROGCLK=>XLXN_3,
                PROGDATA=>XLXN_3,
                PROGEN=>XLXN_3,
                RST=>XLXN_3,
                CLKFX=>o_Clk,
                CLKFXDV=>open,
                CLKFX180=>open,
                LOCKED=>open,
                PROGDONE=>open,
                STATUS=>open);
   
   XLXI_2 : GND
      port map (G=>XLXN_3);
   
end BEHAVIORAL;