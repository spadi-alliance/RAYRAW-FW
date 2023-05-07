  library ieee, mylib;
use ieee.std_logic_1164.all;
use mylib.defBCT.all;

package defIOM is
  constant kWidthOutReg   : positive:= 4;
  constant kWidthInReg    : positive:= 3;

  -- Local Address --------------------------------------------------------
  constant kNimOut1       : LocalAddressType := x"000"; -- W/R, [3:0]
  constant kNimOut2       : LocalAddressType := x"010"; -- W/R, [3:0]

  constant kExtL1         : LocalAddressType := x"040"; -- W/R, [2:0]
  constant kExtL2         : LocalAddressType := x"050"; -- W/R, [2:0]
  constant kExtClr        : LocalAddressType := x"060"; -- W/R, [2:0]
  constant kExtBusy       : LocalAddressType := x"070"; -- W/R, [2:0]

end package defIOM;
