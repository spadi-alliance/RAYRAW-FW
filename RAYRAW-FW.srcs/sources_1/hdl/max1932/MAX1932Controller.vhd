library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_MISC.ALL;
use ieee.numeric_std.all;
use mylib.defBCT.all;
use mylib.defMAX.all;

library UNISIM;
use UNISIM.VComponents.all;

entity MAX1932Controller is
  generic(
    kSysClkFreq         : integer:= 150_000_000   -- integer [Hz]
  );
  port(
    rst	                : in std_logic;
    clk	                : in std_logic;

    -- Module output --
    CSB_SPI             : out std_logic;
    SCLK_SPI            : out std_logic;
    MOSI_SPI            : out std_logic;

    -- Local bus --
    addrLocalBus	      : in LocalAddressType;
    dataLocalBusIn	    : in LocalBusInType;
    dataLocalBusOut	    : out LocalBusOutType;
    reLocalBus		      : in std_logic;
    weLocalBus		      : in std_logic;
    readyLocalBus	      : out std_logic
    );
end MAX1932Controller;

architecture RTL of MAX1932Controller is
  attribute mark_debug        : string;

  -- System --
  signal sync_reset           : std_logic;

  -- internal signal declaration --------------------------------------
  -- GSPI-IF --
  signal busy_cycle           : std_logic;
  signal busy_if              : std_logic;
  signal reg_busy_cycle       : std_logic_vector(1 downto 0);

  signal start_spi_if         : std_logic;
  signal read_phase           : std_logic;
  signal reg_txd_if           : std_logic_vector(kWidthSpi-1 downto 0);

  signal csb_if               : std_logic;
  signal sclk_if              : std_logic;
  signal mosi_if              : std_logic;
  signal miso_if              : std_logic;

  signal state_spi            : SpiIfProcessType;

  -- Local bus --
  signal start_a_cycle      : std_logic;
  signal mode_read          : std_logic;
  signal reg_txd_lbus       : std_logic_vector(kWidthSpi-1 downto 0);

  signal state_lbus	: MaxBusProcessType;

  -- debug --

-- =============================== body ===============================
begin

  CSB_SPI   <= csb_if;
  SCLK_SPI  <= sclk_if;
  MOSI_SPI  <= mosi_if;
  miso_if   <= '0';

  u_IfProcess : process(clk, sync_reset)
    variable count : integer range 0 to kLengthInterval;
  begin
    if(sync_reset = '1') then
      count             := kLengthInterval;
      start_spi_if      <= '0';
      busy_cycle        <= '0';
      read_phase        <= '0';
      state_spi         <= Idle;
    elsif(clk'event and clk = '1') then
      case state_spi is
        when Idle =>
          start_spi_if      <= '0';
          read_phase        <= '0';

          if(start_a_cycle = '1') then
            busy_cycle      <= '1';
            reg_txd_if      <= reg_txd_lbus;
            start_spi_if    <= '1';
            state_spi       <= StartIF;
          end if;

        when StartIF =>
          if(busy_if = '1') then
            start_spi_if  <= '0';
            state_spi     <= WaitCommandDone;
          end if;

        when WaitCommandDone =>
          if(busy_if = '0') then
            if(mode_read = '1' and read_phase = '0') then
              count         := kLengthInterval-1;
              read_phase    <= '1';
              state_spi     <= Interval;
            else
              state_spi     <= Finalize;
            end if;
          end if;

        when Interval =>
          count   := count - 1;
          if(count = 0) then
            start_spi_if  <= '1';
            state_spi     <= StartIF;
          end if;

        when Finalize =>
          busy_cycle  <= '0';
          read_phase  <= '0';
          state_spi   <= Idle;

        when others =>
          state_spi        <= Idle;

      end case;
    end if;
  end process;

  u_reg_busy : process(clk)
  begin
    if(clk'event and clk = '1') then
      reg_busy_cycle  <= reg_busy_cycle(0) & busy_cycle;
    end if;
  end process;

  u_GSPI_IF : entity mylib.GeneralSpiMaster
    generic map(
      freqSysClk => kSysClkFreq,
      freqBusClk => kSpiClkFreq,
      widthData  => kWidthSpi,
      cpol       => kCpol,
      cpha       => kCpha
      )
    port map(
      -- System --
      clk       => clk,
      reset     => sync_reset,
      start     => start_spi_if,
      dataWr    => reg_txd_if,
      dataRd    => open,
      busy      => busy_if,
      errorBit  => open,

      -- SPI port --
      csb       => csb_if,
      sclk      => sclk_if,
      mosi      => mosi_if,
      miso      => miso_if
      );


  ---------------------------------------------------------------------
  -- Local bus process
  ---------------------------------------------------------------------
  u_BusProcess : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      start_a_cycle   <= '0';
      mode_read       <= '0';
      reg_txd_lbus    <= (others => '0');
      state_lbus	    <= Init;
    elsif(clk'event and clk = '1') then
      case state_lbus is
        when Init =>
          start_a_cycle   <= '0';
          reg_txd_lbus    <= (others => '0');
          dataLocalBusOut <= x"00";
          readyLocalBus		<= '0';
          state_lbus		  <= Idle;

        when Idle =>
          readyLocalBus	<= '0';
          if(weLocalBus = '1' or reLocalBus = '1') then
            state_lbus	<= Connect;
          end if;

        when Connect =>
          if(weLocalBus = '1') then
            state_lbus	<= Write;
          else
            state_lbus	<= Done;
          end if;

        when Write =>
          case addrLocalBus(kNonMultiByte'range) is
            when kTxd(kNonMultiByte'range) =>
              reg_txd_lbus(7 downto 0)	  <= dataLocalBusIn;
              state_lbus	 <= Done;

            when kExecWrite(kNonMultiByte'range) =>
              state_lbus	 <= ExecuteWrite;

            when others =>
              state_lbus	<= Done;
          end case;

        when ExecuteWrite =>
          start_a_cycle   <= '1';
          mode_read       <= '0';
          state_lbus      <= WaitDone;

        when WaitDone =>
          start_a_cycle   <= '0';
          if(reg_busy_cycle = "10") then
            state_lbus        <= Finalize;
          end if;

        when Finalize =>
          mode_read       <= '0';
          state_lbus      <= Done;

        when Done =>
          readyLocalBus	<= '1';
          if(weLocalBus = '0' and reLocalBus = '0') then
            state_lbus	<= Idle;
          end if;

        -- probably this is error --
        when others =>
          state_lbus	<= Init;
      end case;
    end if;
  end process u_BusProcess;

  -- Reset sequence --
  u_reset_gen_sys   : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;

