--------------------------------------------------------------------------------
--! @file   FineCounter.vhd
--! @brief  Fine counter for MHTDC
--! @author Takehiro Shiozaki
--! @date   2014-06-06

--! @modifier Ryotaro Honda
--! @date   2014-05-21
--------------------------------------------------------------------------------

library ieee, mylib;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use mylib.defTdcBlock.all;

entity FineCounter is
  port (
    clk0    : in std_logic;
    clk90   : in std_logic;
    clk180  : in std_logic;
    clk270  : in std_logic;

    dIn     : in std_logic_vector(kNumTdcClock-1 downto 0);
    dOut    : out std_logic_vector(kNumTdcClock-1 downto 0)
    );
end FineCounter;

architecture RTL of FineCounter is
  signal Stage0 : std_logic_vector(kNumTdcClock-1 downto 0);
  signal Stage1 : std_logic_vector(kNumTdcClock-1 downto 0);
  signal delayed_stage1 : std_logic_vector(kNumDelay270deg-1 downto 0);
begin

  process(clk0)
  begin
    if(clk0'event and clk0 = '1') then
      stage0(0) <= dIn(0);
    end if;
  end process;

  process(clk90)
  begin
    if(clk90'event and clk90 = '1') then
      stage0(1) <= dIn(1);
    end if;
  end process;

  process(clk180)
  begin
    if(clk180'event and clk180 = '1') then
      stage0(2) <= dIn(2);
    end if;
  end process;

  process(clk270)
  begin
    if(clk270'event and clk270 = '1') then
      stage0(3) <= dIn(3);
    end if;
  end process;

  process(clk0)
  begin
    if(clk0'event and clk0 ='1') then
      stage1 <= stage0;
    end if;
  end process;

  process(clk0)
  begin
    if(clk0'event and clk0 = '1') then
      delayed_stage1 <= stage1(2 downto 0);
    end if;
  end process;

  dOut <= stage1(3) & delayed_stage1;
end RTL;
