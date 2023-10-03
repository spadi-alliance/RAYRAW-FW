library ieee;
use ieee.std_logic_1164.all;

library mylib;

package defYaenamiAdc is
  -- SYSTEM -------------------------------------------------------------
  constant kWidthSys    : integer:= 1;
  constant kWidthDev    : integer:= 10;

  constant kSyncLength  : integer := 4;

  -- IDELAY --
  type IdelayControlProcessType is (
    Init,
    TapLoad,
    IdelayAdjusted
    );

  -- Bitslip --
  constant kMaxPattCheck    : integer:= 32;
  constant kPattOkThreshold : integer:= 16;

  type BitslipControlProcessType is (
    Init,
    WaitStart,
    CheckFramePatt,
    BitSlip,
    BitslipFinished,
    BitslipFailure
    );

  -- Pattern match --
  constant kNumPattMatchCycle : integer:= 16;

  -- ASIC data format ---------------------------------------------------
  constant kNumAdcCh	  : integer := 8;
  constant kNumAdcBit   : integer := 10;
  constant kNumTapBit   : integer := 5;
  constant kNumFrame    : integer := 1;

  subtype AdcDataType is std_logic_vector(kNumAdcBit-1 downto 0);
  subtype TapType is std_logic_vector(kNumTapBit-1 downto 0);

  type AdcDataArray is array (integer range kNumAdcCh-1 downto 0) of AdcDataType;
  type TapArray     is array (integer range kNumAdcCh+kNumFrame-1 downto 0) of TapType;
end package defYaenamiAdc;
