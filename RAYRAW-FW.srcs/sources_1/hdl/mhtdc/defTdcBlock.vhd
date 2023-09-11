library ieee;
use ieee.std_logic_1164.all;

library mylib;
use mylib.defTopLevel.all;

package defTdcBlock is
  -- FirstFDCEs parameters -------------------------------------------------------------
  constant kNumTdcClock       : positive:= 4;

  -- FineCounter paramters -------------------------------------------------------------
  constant kNumDelay270deg    : positive:= 3;

  -- FineCounterDecoder parameters -----------------------------------------------------
  constant kWidthFineCount    : positive:= 4; -- (semi-fine: 2 bit + fine: 2 bit)

  -- Block identification --------------------------------------------------------------
  constant kNumInputBlock     : integer:= 32;
  constant kNumBitMagicWord   : positive:= 8;

  -- Ring buffer --
  constant kWidthRingData     : positive:= kWidthFineCount +1;
  constant kIndexHit          : positive:= 4;
  constant kWidthCoarseCount  : positive:= 11;

  -- Channel buffer --
  constant kWidthTdcData      : positive:= kWidthFineCount + kWidthCoarseCount;
  constant kWidthDataBit      : positive:= 1;
  constant kWidthChData       : positive:= kWidthDataBit + kWidthTdcData;
  type chDataArray is array (integer range kNumInput-1 downto 0)
    of std_logic_vector(kWidthChData-1 downto 0);

  constant kWidthChDataCount  : positive:= 7; -- upto 127
  constant kMaxChDepth        : positive:= 127;
  constant kMaxChThreshold    : positive:= 36;
  type chDcountArray is array (integer range kNumInput-1 downto 0)
    of std_logic_vector(kWidthChDataCount-1 downto 0);

  -- Hit search sequence --
  type HitSearchProcessType is (
    Init,
    WaitCommonStop, ReadRingBuffer, LastWord, Finalize,
    Done
    );

  constant kIndexDataBit  : positive:= kWidthChData-1;
  constant isData         : std_logic:= '1';
  constant isSeparator    : std_logic:= '0';

  constant kWidthLastCount    : positive:= 3;
  type dataTdcArray is array (integer range kNumInput-1 downto 0)
    of std_logic_vector(kWidthTdcData-1 downto 0);

  -- Event build sequence --
  type BuildProcessType is (
    Init,
    WaitDready, DreadyInterval, StartPosition, ReadInterval, ReadOneChannel, EndOneChannel,
    Finalize,
    Done
    );

  constant kWidthChannel    : positive:= 7; -- 128 in total in this FW.

  constant kWidthMultiHit   : positive:= 6;
  constant kMaxMultiHit     : positive:= 16;
  constant kWidthChIndex    : positive:= 5;
  constant kWidthNWord      : positive:= 10;
  --constant kWidthEvSumTDC   : positive:= kWidthNWord + 1; -- overflowbit + Nword(10bit)
  constant kIndexOverflow   : positive:= 10;

  -- Control register --
  type regTdc is record
      --enable_block    : std_logic; -- enable this block
    offset_ptr      : std_logic_vector(kWidthCoarseCount-1 downto 0); -- 2047 - window_max +2
    window_max      : std_logic_vector(kWidthCoarseCount-1 downto 0);
    window_min      : std_logic_vector(kWidthCoarseCount-1 downto 0);
  end record;

end package defTdcBlock;

