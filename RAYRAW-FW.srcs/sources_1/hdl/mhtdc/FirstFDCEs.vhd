library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use mylib.defTdcBlock.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity FirstFDCEs is
  port (
    rst     : in std_logic;
    clk     : in std_logic_vector(kNumTdcClock-1 downto 0);
    dataIn  : in std_logic;
    dataOut : out std_logic_vector(kNumTdcClock-1 downto 0)    
    );
end FirstFDCEs;

architecture RTL of FirstFDCEs is
  attribute rloc : string;
  attribute rloc of FDCE_Inst1 : label is "X0Y0";
  attribute rloc of FDCE_Inst2 : label is "X1Y0";
  attribute rloc of FDCE_Inst3 : label is "X0Y1";
  attribute rloc of FDCE_Inst4 : label is "X1Y1";

begin

  FDCE_inst1 : FDCE
    generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
    port map (
      Q     => dataOut(0),  -- Data output
      C     => clk(0),      -- Clock input
      CE    => '1',         -- Clock enable input
      CLR   => rst,         -- Asynchronous clear input
      D     => dataIn       -- Data input
      );
  
  FDCE_inst2 : FDCE
    generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
    port map (
      Q     => dataOut(1),  -- Data output
      C     => clk(1),      -- Clock input
      CE    => '1',         -- Clock enable input
      CLR   => rst,         -- Asynchronous clear input
      D     => dataIn       -- Data input
      );   
  
  FDCE_inst3 : FDCE
    generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
    port map (
      Q     => dataOut(2),  -- Data output
      C     => clk(2),      -- Clock input
      CE    => '1',         -- Clock enable input
      CLR   => rst,         -- Asynchronous clear input
      D     => dataIn       -- Data input
      );   
  
  FDCE_inst4 : FDCE
    generic map (
      INIT => '0') -- Initial value of register ('0' or '1')  
    port map (
      Q     => dataOut(3),  -- Data output
      C     => clk(3),      -- Clock input
      CE    => '1',         -- Clock enable input
      CLR   => rst,         -- Asynchronous clear input
      D     => dataIn       -- Data input
      );   

end RTL;
