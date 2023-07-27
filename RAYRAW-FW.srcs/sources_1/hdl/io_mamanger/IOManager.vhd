library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use mylib.defIOM.all;
use mylib.defBCT.all;

entity IOManager is
  port(
    rst                 : in std_logic;
    clk                 : in std_logic;

    -- NIM input signal --
    nimIn               : in std_logic_vector(2 downto 1);
    extL1               : out std_logic;
    extL2               : out std_logic;
    extClr              : out std_logic;
    extBusy             : out std_logic;

    -- NIM output signal --
    nimOut              : out std_logic_vector(2 downto 1);
    moduleBusy          : in std_logic;
    daqGate             : in std_logic;
    clk1MHz             : in std_logic;
    clk100kHz           : in std_logic;
    clk10kHz            : in std_logic;
    clk1kHz             : in std_logic;

    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut     : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus       : out std_logic
    );
end IOManager;

architecture RTL of IOManager is
  attribute keep : string;

  -- System --
  signal sync_reset       : std_logic;

  -- signal decralation -------------------------------------------------------------
  signal state_lbus    	: BusProcessType;

  signal nim_out          : std_logic_vector(2 downto 1);
  signal reg_nimout_1     : std_logic_vector(kWidthOutReg-1 downto 0);
  signal reg_nimout_2     : std_logic_vector(kWidthOutReg-1 downto 0);
  attribute keep of nim_out   : signal is "TRUE";

  signal nim_in           : std_logic_vector(2 downto 1);
  signal reg_extL1        : std_logic_vector(kWidthInReg-1 downto 0);
  signal reg_extL2        : std_logic_vector(kWidthInReg-1 downto 0);
  signal reg_extClr       : std_logic_vector(kWidthInReg-1 downto 0);
  signal reg_ext_busy     : std_logic_vector(kWidthInReg-1 downto 0);

begin
  -- =================================== body =======================================
  -- signal connection -------------------------------------------------------
  -- NIM output --
  nimOut      <= nim_out;

  nim_out(1)  <= moduleBusy when(reg_nimout_1 = "0000") else
                 daqGate    when(reg_nimout_1 = "0001") else
                 clk1MHz    when(reg_nimout_1 = "0010") else
                 clk100kHz  when(reg_nimout_1 = "0011") else
                 clk10kHz   when(reg_nimout_1 = "0100") else
                 clk1kHz    when(reg_nimout_1 = "0101") else
                 '0'        when(reg_nimout_1 = "1110") else
                 moduleBusy;

  nim_out(2)  <= moduleBusy when(reg_nimout_2 = "0000") else
                 daqGate    when(reg_nimout_2 = "0001") else
                 clk1MHz    when(reg_nimout_2 = "0010") else
                 clk100kHz  when(reg_nimout_2 = "0011") else
                 clk10kHz   when(reg_nimout_2 = "0100") else
                 clk1kHz    when(reg_nimout_2 = "0101") else
                  '0'       when(reg_nimout_2 = "1110") else
                 clk1kHz;


  -- NIM input --
  nim_in  <= nimIn;
  extL1   <= nim_in(1) when(reg_extL1 = "000") else
             nim_in(2) when(reg_extL1 = "001") else
             '0'       when(reg_extL1 = "110") else
             nim_in(1);

  extL2   <= nim_in(1) when(reg_extL2 = "000") else
             nim_in(2) when(reg_extL2 = "001") else
             '0'       when(reg_extL2 = "110") else
             '0';

  extClr  <= nim_in(1) when(reg_extClr = "000") else
             nim_in(2) when(reg_extClr = "001") else
             '0'       when(reg_extClr = "110") else
             '0';

  extBusy  <= nim_in(1) when(reg_ext_busy = "000") else
              nim_in(2) when(reg_ext_busy = "001") else
              '0'       when(reg_ext_busy = "110") else
              nim_in(2);

  -- Bus process -------------------------------------------------------------
  u_BusProcess : process ( clk, sync_reset )
  begin
    if( sync_reset = '1' ) then
      dataLocalBusOut     <= x"00";
      readyLocalBus       <= '0';
      reg_nimout_1        <= (others => '1');
      reg_nimout_2        <= (others => '1');

      reg_extL1           <= (others => '1');
      reg_extL2           <= (others => '1');
      reg_extClr          <= (others => '1');
      reg_ext_busy        <= (others => '1');

      state_lbus          <= Init;
    elsif( clk'event and clk = '1' ) then
      case state_lbus is
        when Init =>
          state_lbus          <= Idle;

        when Idle =>
          readyLocalBus <= '0';
          if ( weLocalBus = '1' ) then
            state_lbus <= Write;
          elsif ( reLocalBus = '1' ) then
            state_lbus <= Read;
          end if;

        when Write =>
          case addrLocalBus(kNonMultiByte'range) is
            when kNimOut1(kNonMultiByte'range) =>
              reg_nimout_1 <= dataLocalBusIn(kWidthOutReg-1 downto 0);
            when kNimOut2(kNonMultiByte'range) =>
              reg_nimout_2 <= dataLocalBusIn(kWidthOutReg-1 downto 0);
            when kExtL1(kNonMultiByte'range) =>
              reg_extL1    <= dataLocalBusIn(kWidthInReg-1 downto 0);
            when kExtL2(kNonMultiByte'range) =>
              reg_extL2    <= dataLocalBusIn(kWidthInReg-1 downto 0);
            when kExtClr(kNonMultiByte'range) =>
              reg_extClr   <= dataLocalBusIn(kWidthInReg-1 downto 0);
            when kExtBusy(kNonMultiByte'range) =>
              reg_ext_busy <= dataLocalBusIn(kWidthInReg-1 downto 0);
              when others => null;
          end case;
          state_lbus <= Done;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kNimOut1(kNonMultiByte'range) =>
              dataLocalBusOut <= "0000" & reg_nimout_1;
            when kNimOut2(kNonMultiByte'range) =>
              dataLocalBusOut <= "0000" & reg_nimout_2;
            when kExtL1(kNonMultiByte'range) =>
              dataLocalBusOut <= "00000" & reg_extL1;
            when kExtL2(kNonMultiByte'range) =>
              dataLocalBusOut <= "00000" & reg_extL2;
            when kExtClr(kNonMultiByte'range) =>
              dataLocalBusOut <= "00000" & reg_extClr;
            when kExtBusy(kNonMultiByte'range) =>
              dataLocalBusOut <= "00000" & reg_ext_busy;
              dataLocalBusOut    <= X"ff";
            when others => null;
          end case;
          state_lbus <= Done;

        when Done =>
          readyLocalBus <= '1';
          if ( weLocalBus='0' and reLocalBus='0' ) then
            state_lbus <= Idle;
          end if;

        when others =>
          state_lbus    <= Init;
      end case;
    end if;
  end process u_BusProcess;

  -- Reset sequence --
  u_reset_gen : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;
