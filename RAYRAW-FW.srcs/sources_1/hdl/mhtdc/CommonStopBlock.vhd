library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

library mylib;
use mylib.defMTDC.all;
use mylib.defTdcBlock.all;
use mylib.defCommonStopBlock.all;

entity CommonStopBlock is
  port(
    sysClk      : in std_logic; -- 100 MHz
    tdcClk      : in std_logic_vector(kNumTdcClock-1 downto 0); -- 400 MHz

    -- data input --
    stopIn      : in std_logic;
    dOutStop    : out std_logic_vector(kWidthStopData-1 downto 0) -- 4:CStop bit, 3-0: CStop values
    );
end CommonStopBlock;

architecture RTL of CommonStopBlock is
  -- internal signals ------------------------------------------------------
  signal dout_first_fdc   : std_logic_vector(kNumTdcClock-1 downto 0);

  -- FineCounter ---------------------------------------------
  signal dout_bit_pattern : std_logic_vector(kNumTdcClock-1 downto 0);

  -- FineCounterDecoder ----------------------------------------
  signal decoded_fcount   : std_logic_vector(kWidthFineCount-1 downto 0);
  signal hit_found        : std_logic;

begin
  -- ========================================================================
  -- Body
  -- ========================================================================
  -- signal connection ------------------------------------------------------
  dOutStop(kIndexHit)             <= hit_found;
  dOutStop(kIndexHit-1 downto 0)  <= decoded_fcount;
  -- signal connection ------------------------------------------------------
  u_FirstFDC : entity mylib.FirstFDCEs
    port map(
      rst     => '0',
      clk     => tdcClk,
      dataIn  => stopIn,
      dataOut => dout_first_fdc
      );

  u_FCounter_Inst : entity mylib.FineCounter
    port map(
      clk0   => tdcClk(0),
      clk90  => tdcClk(1),
      clk180 => tdcClk(2),
      clk270 => tdcClk(3),

      dIn    => dout_first_fdc,
      dOut   => dout_bit_pattern
      );

  u_FCDecoder : entity mylib.FineCounterDecoder
    port map(
      tdcClk        => tdcClk(0),
      sysClk        => sysClk,
      dIn           => dout_bit_pattern,
      fineCount     => decoded_fcount,
      hitFound      => hit_found
      );


end RTL;
