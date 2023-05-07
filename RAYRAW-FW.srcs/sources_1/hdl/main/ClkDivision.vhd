library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;

entity ClkDivision is
  port (
    rst         : in std_logic;
    clk         : in std_logic;

    -- module output --
    clk1MHz    : out std_logic;
    clk100kHz  : out std_logic;
    clk10kHz   : out std_logic;
    clk1kHz    : out std_logic
    );
end ClkDivision;

architecture RTL of ClkDivision is
  -- System --
  signal sync_reset       : std_logic;

  -- signal decralation ------------------------------------------------------
  signal clk_1MHz, clk_100kHz, clk_10kHz, clk_1kHz : std_logic;

begin
  -- =============================== body ====================================
  clk1MHz     <= clk_1MHz;
  clk100kHz   <= clk_100kHz;
  clk10kHz    <= clk_10kHz;
  clk1kHz     <= clk_1kHz;

  u_clk1MHz   : entity mylib.Division10 port map(rst=>sync_reset, clk=>clk,        clkDiv10=>clk_1MHz);
  u_clk100kHz : entity mylib.Division10 port map(rst=>sync_reset, clk=>clk_1MHz,   clkDiv10=>clk_100kHz);
  u_clk10kHz  : entity mylib.Division10 port map(rst=>sync_reset, clk=>clk_100kHz, clkDiv10=>clk_10kHz);
  u_clk1kHz   : entity mylib.Division10 port map(rst=>sync_reset, clk=>clk_10kHz,  clkDiv10=>clk_1kHz);

  -- Reset sequence --
  u_reset_gen : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;
