library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use mylib.defDCT.all;
use mylib.defBCT.all;

entity DAQController is
  port(
    rst               : in std_logic;
    clk               : in std_logic;
    -- Module output --
    daqGate           : out std_logic;
    rstEvb            : out std_logic;

    -- Local bus --
    addrLocalBus	    : in LocalAddressType;
    dataLocalBusIn	  : in LocalBusInType;
    dataLocalBusOut	  : out LocalBusOutType;
    reLocalBus				: in std_logic;
    weLocalBus				: in std_logic;
    readyLocalBus			: out std_logic
    );
end DAQController;

architecture RTL of DAQController is
  attribute keep  : string;

  -- System --
  signal sync_reset       : std_logic;

  -- internal signal declaration ----------------------------------------
  signal reg_daq_gate    : std_logic;
  signal evb_reset       : std_logic;
  attribute keep of reg_daq_gate : signal is "true";
  attribute keep of evb_reset    : signal is "true";
  signal state_lbus	   : BusProcessType;

-- =============================== body ===============================
begin
  daqGate <= reg_daq_gate;
  rstEvb  <= evb_reset;

  u_BusProcess : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      dataLocalBusOut <= x"00";
      readyLocalBus   <= '0';
      reg_daq_gate    <= '0';
      evb_reset       <= '0';
      state_lbus	    <= Init;
    elsif(clk'event and clk = '1') then
      case state_lbus is
        when Init =>
          state_lbus    <= Idle;

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
            when kDaqGate(kNonMultiByte'range) =>
              reg_daq_gate	<= dataLocalBusIn(0);
              state_lbus	<= Done;
            when kResetEvb(kNonMultiByte'range) =>
              state_lbus	<= Execute;
            when others =>
              state_lbus	<= Done;
          end case;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kDaqGate(kNonMultiByte'range) =>
              dataLocalBusOut <= "0000000" & reg_daq_gate;
            when others =>
              dataLocalBusOut <= x"ff";
          end case;
          state_lbus	<= Done;

        when Execute =>
          evb_reset   <= '1';
          state_lbus  <= Finalize;

        when Finalize =>
          evb_reset   <= '0';
          state_lbus  <= Done;

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
  u_reset_gen : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;
