library ieee, mylib;
use ieee.std_logic_1164.all;
use mylib.defBCT.all;

package defMAX is
  -- GSPI-IF --
--  constant kSysClkFreq      : integer:= 150_000_000;
  constant kSpiClkFreq      : integer:= 1_000_000;
  constant kWidthSpi        : integer:= 8;

  constant kCpol            : std_logic:= '0';
  constant kCpha            : std_logic:= '0';

  constant kLengthInterval  : positive:= 32;

  type SpiIfProcessType is (
    Idle, StartIF, WaitCommandDone, Interval, Finalize
    );

  -- Local bus --
  type MaxBusProcessType is (
    Init, Idle, Connect,
    Write,
    ExecuteWrite,
    WaitDone,
    Finalize,
    Done
    );


  -- -- Local Address  -------------------------------------------------------
  constant kTxd             : LocalAddressType := x"000"; -- W,   [31:0]
  constant kExecWrite       : LocalAddressType := x"100"; -- W,

end package defMAX;

