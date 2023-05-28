library ieee;
use ieee.std_logic_1164.all;

package defToplevel is
  -- Number of input per a main port.
  constant kNumInput            : integer:= 32;

  -- RAYRAW PCB specification
  constant kNumLED              : integer:= 4;
  constant kNumBitDIP           : integer:= 8;
  constant kNumNIM              : integer:= 2;
  constant kNumGtx              : integer:= 1;

  constant kNumIO       : integer:= 1;
  constant kNumASIC		: integer:= 4;

  end package defToplevel;
