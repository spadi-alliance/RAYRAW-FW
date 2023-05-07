--JKFF ACLR 1bit

library ieee;
use ieee.std_logic_1164.all;

entity JKFF is
    port(
	ACLR   : in std_logic;
	J	   : in std_logic;
	K      : in std_logic;
	CLK    : in std_logic;
	Q      : out std_logic
	);
end JKFF;

architecture RTL of JKFF is
signal q1	: std_logic;
begin
	process (CLK, ACLR)
	begin
	   if (ACLR = '1') then   
	      q1 <= '0';
	   elsif (CLK'event AND CLK='1') then 
	      q1 <= (J AND (NOT q1)) OR (K NOR (NOT q1));
	   end if;
	end process;

Q	<= q1;
end RTL;