library ieee;
use ieee.std_logic_1164.all;


library mylib;
use mylib.defTdcBlock.all;
use mylib.defYaenamiAdc.all;
use mylib.defRayrawAdcROV1.all;

package defAdcBlock is
  constant kNumAdcInputBlock  : positive:= kNumAsicBlock*kNumAdcCh; -- 32: 4*8
  -- channel buffer depth
  constant kWidthAdcChDataCount  : positive:= 12;
  constant kMaxAdcChDepth        : positive:= 4056;
  constant kMaxAdcChThreshold    : positive:= 40;
  type chAdcDcountArray is array (integer range kNumAdcInputBlock-1 downto 0)
    of std_logic_vector(kWidthAdcChDataCount-1 downto 0);

  -- block buffer
  constant kWidthAdcData      : positive:= kWidthCoarseCount + kNumAdcBit; -- 11+10
  constant kWidthAdcChData    : positive:= kWidthDataBit + kWidthAdcData;
  constant kWidthAdcChannel   : positive:= 5;
  constant kIndexAdcDataBit   : positive:= kWidthAdcChData-1;
  constant kWidthAdcChIndex   : positive:= 5;

  -- event build
  constant kWidthAdcNWord  : positive:= 18;

  type chAdcDataArray is array (integer range kNumAdcInputBlock-1 downto 0) of std_logic_vector(kWidthAdcChData-1 downto 0); -- 1+11+10
end package defAdcBlock;
