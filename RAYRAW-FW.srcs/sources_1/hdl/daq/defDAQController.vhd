library ieee, mylib;
use ieee.std_logic_1164.all;
use mylib.defBCT.all;

package defDCT is
  -- Local Address --------------------------------------------------------
  constant kDaqGate       : LocalAddressType := x"000"; -- W/R, [0:0]
  constant kResetEvb      : LocalAddressType := x"010"; -- W, reset EventBuilder

end package defDCT;
