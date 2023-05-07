library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use mylib.defBCT.all;

package defTRM is
  -- Definition of J0 backplane trigger
  constant kWidthTAG            : positive:= 4;

  -- Trigger control
  constant kNumOfTrigType       : positive:= 3;
  constant kTrigAllZero         : std_logic_vector(kNumOfTrigType-1 downto 0):= "000";
  
  constant kWidthSelTrig        : integer := 12;

  subtype RegID is integer range 0 to kWidthSelTrig-1;
  type regLeaf is record
    Index : RegID;
  end record;
  constant kL1Ext     : regLeaf := (Index => 0);
  constant kL1J0      : regLeaf := (Index => 1);
  constant kL1RM      : regLeaf := (Index => 2);
  constant kL2Ext     : regLeaf := (Index => 3);
  constant kL2J0      : regLeaf := (Index => 4);
  constant kL2RM      : regLeaf := (Index => 5);
  constant kClrExt    : regLeaf := (Index => 6);
  constant kClrJ0     : regLeaf := (Index => 7);
  constant kClrRM     : regLeaf := (Index => 8);
  constant kEnL2      : regLeaf := (Index => 9);
  constant kEnJ0      : regLeaf := (Index => 10);
  constant kEnRM      : regLeaf := (Index => 11);

  -- Trigger sequence
  constant kWidthTriggerData    : positive:= 6;
  -- 0:   Level2
  -- 1:   Clear
  -- 2-5: TAG
  constant kIndexLevel2         : integer:= 0;
  constant kIndexClear          : integer:= 1;
  
  constant kNumL2Delay          : positive:= 20;
  constant kWidthBusyCount      : positive:= 4;

  -- Definition of the internal trigger
  type TrigDownType is record
    L1request  : std_logic;
    L1accept   : std_logic;
    L1OneShot  : std_logic;
    L2accept   : std_logic;
    FastClear  : std_logic;
  --self_busy  : std_logic;
  --seq_busy   : std_logic;
  end record;

  -- Local Address --------------------------------------------------------
  constant kSelectTrigger       : LocalAddressType := x"000"; -- W/R, [11:0]
  
end package defTRM;
