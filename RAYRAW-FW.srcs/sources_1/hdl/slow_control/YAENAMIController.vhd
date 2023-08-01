library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library mylib;
use mylib.defManchesterEncoder.all; --?
use mylib.defYAENAMIController.all;
use mylib.defBCT.all;

entity YAENAMIController is
  generic
  (
    kFreqSysClk   : integer:= 125_000_000;
    kNumIO        : integer:= 32;
    kNumASIC      : integer:= 4;
    enDebug       : boolean:= false
  );
  port
  (
    -- System --
    rst         : in std_logic; -- Active high reset (async)
    clk         : in std_logic; -- System clock

    -- Rx Chip port --
    SSB		    : out std_logic_vector(kNumASIC-1 downto 0); -- remove MagicNumber later?
    MOSI      : out std_logic;
    SCK		    : out std_logic;

    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut	    : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus	      : out std_logic
  );
end YAENAMIController;

architecture RTL of YAENAMIController is
  attribute mark_debug        : boolean;

  signal sync_reset           : std_logic;

  -- internal signal declaration ----------------------------------------


  -- Local bus --
  signal reg_data_in      : DsTxDataType;
  signal en_write         : std_logic_vector(kNumIO-1 downto 0);
  signal start_a_cycle    : std_logic_vector(kNumIO-1 downto 0);
  signal busy_tx          : std_logic_vector(kNumIO-1 downto 0);
  signal reg_chip_select  : std_logic_vector(kNumASIC-1 downto 0);
  signal ssb_origin       : std_logic;

  signal write_address    : std_logic_vector(7 downto 0);

  signal state_lbus	: BusProcessType;

  -- Debug --------------------------------------------------------------
  attribute mark_debug of reg_data_in     : signal is enDebug;
  attribute mark_debug of en_write        : signal is enDebug;
  attribute mark_debug of start_a_cycle   : signal is enDebug;
  attribute mark_debug of busy_tx         : signal is enDebug;

  attribute mark_debug of state_lbus      : signal is enDebug;
begin
  -- =============================== body ===============================


  gen_RxChip : for i in 0 to kNumIO-1 generate
  begin

    u_RxChipSpiInst : entity mylib.SpiTx
      generic map(
        freqSysClk => kFreqSysClk,
        enDebug    => enDebug
        )
      port map(
        -- System --
        clk       => clk,
        reset     => sync_reset,
        dataIn    => reg_data_in,
        enWr      => en_write(i),
        start     => start_a_cycle(i),
        busy      => busy_tx(i),

        -- TX port --
        SSB	      => ssb_origin,
        MOSI      => MOSI,
	      SCK	      => SCK
      );
  end generate;

  SSB(0) <= ssb_origin when reg_chip_select(0) = '1' else '1';
  SSB(1) <= ssb_origin when reg_chip_select(1) = '1' else '1';
  SSB(2) <= ssb_origin when reg_chip_select(2) = '1' else '1';
  SSB(3) <= ssb_origin when reg_chip_select(3) = '1' else '1';

  ---------------------------------------------------------------------
  -- Local bus process
  ---------------------------------------------------------------------
  write_address   <= addrLocalBus(kNonMultiByte'left downto kNonMultiByte'left -7);

  u_BusProcess : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      start_a_cycle   <= (others => '0');
      en_write        <= (others => '0');
      reg_chip_select <= (others => '0');
      state_lbus	    <= Init;
    elsif(clk'event and clk = '1') then
      case state_lbus is
        when Init =>
          start_a_cycle   <= (others => '0');
          en_write        <= (others => '0');
          reg_chip_select <= (others => '0');
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
            state_lbus	<= Read;
          end if;

        when Write =>
          case addrLocalBus(kNonMultiByte'range) is
            when kStartCycle(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stByte) then
                start_a_cycle   <= dataLocalBusIn(kNumIO-1 downto 0);
              else
                null;
              end if;
              state_lbus	    <= Finalize;

            when kChipSelect(kNonMultiByte'range) =>
              reg_chip_select <= dataLocalBusIn(kNumASIC-1 downto 0);
              state_lbus	    <= Finalize;

            when others =>
              reg_data_in                                         <= dataLocalBusIn;
              en_write(to_integer(unsigned(write_address)))       <= '1';
              state_lbus	                                        <= Finalize;

          end case;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kBusyFlag(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stByte) then
                dataLocalBusOut   <= "0000000" & busy_tx(kNumIO-1 downto 0); -- TODO: set # of '0' using kNumIO
              else
                null;
              end if;
              state_lbus	      <= Done;

            when others => null;
          end case;

        when Finalize =>
          en_write        <= (others => '0');
          start_a_cycle   <= (others => '0');
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
