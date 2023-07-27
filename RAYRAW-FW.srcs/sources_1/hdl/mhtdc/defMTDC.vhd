library ieee, mylib;
use ieee.std_logic_1164.all;

use mylib.defBCT.all;
use mylib.defTopLevel.all;
use mylib.defTdcBlock.all;

package defMTDC is
  constant kNumTdcBlock          : positive:= 2;
  type arrayInput is array(kNumTdcBlock/2-1 downto 0) of std_logic_vector(kNumInput-1 downto 0);

  constant kMagicWordLeading  : std_logic_vector(kNumBitMagicWord-1 downto 0):= X"cc";
  constant kMagicWordTrailing : std_logic_vector(kNumBitMagicWord-1 downto 0):= X"cd";

--  type typeInitCh is array(kNumTdcBlock/2 -1 downto 0) of integer;
--  constant kInitialCh : typeInitCh := (0);

  -- Local Address --------------------------------------------------------
  constant kEnBlock         : LocalAddressType := x"000"; -- W/R, [1:0] Enable blocks
  constant kOfsPtr          : LocalAddressType := x"010"; -- W/R, [10:0], pointer offset of the read pointer for ring buffer
  constant kWinMax          : LocalAddressType := x"020"; -- W/R, [10:0], Max coarse counter
  constant kWinMin          : LocalAddressType := x"030"; -- W/R, [10:0], Min coarse counter

end package defMTDC;
