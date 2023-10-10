library ieee, mylib;
use ieee.std_logic_1164.all;

use mylib.defTRM.all;
use mylib.defMTDC.all;

package defEVB is
  -- Definition of DAQ data
  constant kWidthDaqWord      : integer:= 32;
  constant kWidthEventSize    : integer:= 18;
  constant kWidthSelfCounter  : integer:= 16;

  -- Data structure of HUL HRM
  -- Header1  : Eigen word:  0xffffxxxx (See defBCT)
  -- Header2  : Data size
  -- Header3  : Event number
  -- Data
  constant kEigenWord         : std_logic_vector(kWidthDaqWord-1 downto 0):= x"ffff0160";

  -- Trigger record readout --
  type dataEvb2Trm is record
    reFifo      : std_logic;
  end record;

  type dataTrm2Evb is record
    rvFifo   		: std_logic;
    regLevel2		: std_logic;
--    regClear   		: std_logic;
    regTag  		: std_logic_vector(kWidthTAG-1 downto 0);
    trigReady   : std_logic;
  end record;

  -- Builder bus definition --
  constant kNumBuilderBlock   : integer:= 3;
  -- TDC-L: 1
  -- TDC-T: 1
  -- ADC  : 1

  subtype BlockID is integer range -1 to kNumBuilderBlock-1;
  type DaqBlock is record
    ID : BlockID;
  end record;

  type Binder is array (integer range <>) of DaqBlock;
  constant kBbTDCL0 : DaqBlock := (ID => 0);
  constant kBbTDCT0 : DaqBlock := (ID => 1);
  constant kBbADC   : DaqBlock := (ID => 2);
  constant kBbDummy : DaqBlock := (ID => -1);

  constant kWidthBBusAddr   : integer:= 4;
  constant kWidthBBusData   : integer:= 32;

  subtype BBusAddressType is std_logic_vector(kWidthBBusAddr-1 downto 0);
  subtype BBusDataType    is std_logic_vector(kWidthBBusData-1 downto 0);
  subtype BBusControlType is std_logic_vector(kNumBuilderBlock-1 downto 0);

  type BBusDataArray is array (integer range kNumBuilderBlock-1 downto 0) of BBusDataType;
  type BBusDataTDC   is array (integer range kNumTdcBlock-1 downto 0) of BBusDataType;

  -- Builder bus address --
  constant kEventSummary  : BBusAddressType:= X"1";
  constant kDataBuffer    : BBusAddressType:= X"2";

  -- EventSummary data structure --
  --  Overflow bit + data size (kWidthEventSize-1 downto 0);
  constant kWidthEvtSummary : integer:= kWidthEventSize +1; -- Overflow bit + NWord

  type BBusMasterType is
    (
      Init, Idle, SetBus, BindBus, ReadBus, ReleaseBus
    );

  type BBusSlaveType is
    (
      Init, Idle, BoundBus, CloseBus
    );

  -- Event Building process
  type EvbProcessType is
    (
      Init,
      WaitDready,
      SetLevel2,
      SetBBusSize, ReadBlockSize, SetEventSize,
      SendHeader1, SendHeader2, SendHeader3, FinalizeHeader,
      SetBBusData, ReadBlock, CheckEndOfBuild,
      Finalize,
      Done
    );

end package defEVB;
