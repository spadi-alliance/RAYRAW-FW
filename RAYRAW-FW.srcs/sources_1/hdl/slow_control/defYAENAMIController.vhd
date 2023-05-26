library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mylib;
use mylib.defBCT.all;

package defYAENAMIController is
  -- Local Address  -------------------------------------------------------
  -- Address range of kWriteData is 0x000 to 0x1F0 --
  constant kWriteData       : LocalAddressType := x"000"; -- W,   [7:0]

  constant kBusyFlag        : LocalAddressType := x"200"; -- R,   [3:0]
  constant kStartCycle      : LocalAddressType := x"300"; -- W,   [3:0]
end package;
