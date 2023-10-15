library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--use mylib.defTopLevel.all;
use mylib.defTdcBlock.all;
use mylib.defCommonStopBlock.all;
use mylib.defMTDC.all;
use mylib.defEVB.all;
use mylib.defTRM.all;
use mylib.defBCT.all;

entity MTDC is
  port(
    rst	                : in std_logic;
    clk                 : in std_logic;
    clkTdc              : in std_logic_vector(kNumTdcClock-1 downto 0);

    -- Module input --
    enRM                : in std_logic;
    triggerIn           : in TrigDownType;
    sigIn               : in arrayInput;
    -- 0 = Leading, 1 = Trailing

    -- Module output --
    busyTdc             : out std_logic;
    cStop               : out std_logic;

    -- Builder bus --
    addrBuilderBus      : in  BBusAddressType;
    dataBuilderBusOut   : out BBusDataTDC;
    reBuilderBus        : in  std_logic_vector(kNumTdcBlock-1 downto 0);
    rvBuilderBus        : out std_logic_vector(kNumTdcBlock-1 downto 0);
    dReadyBuilderBus    : out std_logic_vector(kNumTdcBlock-1 downto 0);
    bindBuilderBus      : in  std_logic_vector(kNumTdcBlock-1 downto 0);
    isBoundToBuilder    : out std_logic_vector(kNumTdcBlock-1 downto 0);

    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut     : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus       : out std_logic
    );
end MTDC;

architecture RTL of MTDC is
  -- Signal decralation ----------------------------------------------------
  attribute mark_debug    : string;

  -- System --
  signal sync_reset       : std_logic;

  -- system ---------------------------------------
  signal busy     : std_logic_vector(kNumTdcBlock-1 downto 0);
  signal sig_in_n : arrayInput;

  signal sig_in_n1  : std_logic_vector(kNumInputBlock-1 downto 0);

  signal sig_cstop  : std_logic_vector(kWidthStopData-1 downto 0);

  -- Local bus controll -----------------------------------------------------
  signal state_lbus	  : BusProcessType;
  signal enable_block : std_logic_vector(kNumTdcBlock-1 downto 0);
  signal en_block     : std_logic_vector(kNumTdcBlock-1 downto 0);
  signal reg_tdc      : regTdc;

  -- debug ------------------------------------------------------------------
  --attribute mark_debug of sig_cstop : signal is "true";

begin
  -- ========================================================================
  -- Body
  -- ========================================================================
  -- signal connection ------------------------------------------------------
  en_block(0) <= enable_block(0);
  en_block(1) <= enable_block(1);

  busyTdc <= '0' when (unsigned(busy) = 0) else '1';
  cStop   <= sig_cstop(kWidthStopData-1);

  gen_traling : for i in 0 to kNumInputBlock-1 generate
    sig_in_n(0)(i)    <= NOT sigIn(0)(i);
  end generate;

  -- TDC Block Instans leading ---------------------------------------------
  gen_leading : for i in 0 to kNumTdcBlock/2-1 generate
  begin
    u_Tdc_Leading : entity mylib.TdcBlock
      generic map(
        initCh      => 0,
        magicWord   => kMagicWordLeading
        )
      port map(
        rst         => sync_reset,
        sysClk      => clk,
        tdcClk      => clkTdc,

        -- controll register --
        busyTdc     => busy(i),
        enBlock     => en_block(i),
        regIn       => reg_tdc,

        -- data input --
        tdcIn       => sigIn(i),
        dInStop     => sig_cstop,

        -- Builder bus --
        addrBuilderBus      => addrBuilderBus,
        dataBuilderBusOut   => dataBuilderBusOut(i),
        reBuilderBus        => reBuilderBus(i),
        rvBuilderBus        => rvBuilderBus(i),
        dReadyBuilderBus    => dReadyBuilderBus(i),
        bindBuilderBus      => bindBuilderBus(i),
        isBoundToBuilder    => isBoundToBuilder(i)
        );
  end generate;

  -- TDC Block Instans trailing --------------------------------------------
  gen_trailing : for i in 0 to kNumTdcBlock/2-1 generate
  begin
    u_Tdc_Trailing : entity mylib.TdcBlock
      generic map(
        initCh      => 0,
        magicWord   => kMagicWordTrailing
        )
      port map(
        rst         => sync_reset,
        sysClk      => clk,
        tdcClk      => clkTdc,

        -- controll register --
        busyTdc     => busy(i+1),
        enBlock     => en_block(i+1),
        regIn       => reg_tdc,

        -- data input --
        tdcIn       => sig_in_n(i),
        dInStop     => sig_cstop,

        -- Builder bus --
        addrBuilderBus      => addrBuilderBus,
        dataBuilderBusOut   => dataBuilderBusOut(i+1),
        reBuilderBus        => reBuilderBus(i+1),
        rvBuilderBus        => rvBuilderBus(i+1),
        dReadyBuilderBus    => dReadyBuilderBus(i+1),
        bindBuilderBus      => bindBuilderBus(i+1),
        isBoundToBuilder    => isBoundToBuilder(i+1)
        );
  end generate;

  -- Common Stop instance --------------------------------------------------
  u_CStop : entity mylib.CommonStopBlock
    port map(
      sysClk      => clk,
      tdcClk      => clkTdc,

      -- data input --
      stopIn      => triggerIn.L1accept,
      dOutStop    => sig_cstop
      );

  -- Local bus process -----------------------------------------------------
  u_BusProcess : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      dataLocalBusOut     <= x"00";
      readyLocalBus       <= '0';
      enable_block        <= (others => '0');
      reg_tdc.offset_ptr  <= (others => '0');
      reg_tdc.window_max  <= (others => '0');
      reg_tdc.window_min  <= (others => '0');
      state_lbus    <= Init;
    elsif(clk'event and clk = '1') then
      case state_lbus is
        when Init =>
          state_lbus          <= Idle;

        when Idle =>
          readyLocalBus    <= '0';
          if(weLocalBus = '1' or reLocalBus = '1') then
            state_lbus    <= Connect;
          end if;

        when Connect =>
          if(weLocalBus = '1') then
            state_lbus    <= Write;
          else
            state_lbus    <= Read;
          end if;

        when Write =>
          case addrLocalBus(kNonMultiByte'range) is
            when kEnBlock(kNonMultiByte'range) =>
              enable_block        <= dataLocalBusIn(kNumTdcBlock-1 downto 0);

            when kOfsPtr(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                reg_tdc.offset_ptr(7 downto 0)  <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                reg_tdc.offset_ptr(kWidthCoarseCount-1 downto 8)  <= dataLocalBusIn(kWidthCoarseCount-1-8 downto 0);
              else
              end if;

            when kWinMax(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                reg_tdc.window_max(7 downto 0)  <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                reg_tdc.window_max(kWidthCoarseCount-1 downto 8)  <= dataLocalBusIn(kWidthCoarseCount-1-8 downto 0);
              else
              end if;

            when kWinMin(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                reg_tdc.window_min(7 downto 0)  <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                reg_tdc.window_min(kWidthCoarseCount-1 downto 8)  <= dataLocalBusIn(kWidthCoarseCount-1-8 downto 0);
              else
              end if;

            when others => null;
          end case;
          state_lbus    <= Done;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kEnBlock(kNonMultiByte'range) =>
              dataLocalBusOut <= std_logic_vector(to_unsigned(0, 8-kNumTdcBlock)) & enable_block;

            when kOfsPtr(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                dataLocalBusOut <= reg_tdc.offset_ptr(7 downto 0);
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                dataLocalBusOut <= "00000" & reg_tdc.offset_ptr(kWidthCoarseCount-1 downto 8);
              else
              end if;

            when kWinMax(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                dataLocalBusOut <= reg_tdc.window_max(7 downto 0);
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                dataLocalBusOut <= "00000" & reg_tdc.window_max(kWidthCoarseCount-1 downto 8);
              else
              end if;

            when kWinMin(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                dataLocalBusOut <= reg_tdc.window_min(7 downto 0);
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                dataLocalBusOut <= "00000" & reg_tdc.window_min(kWidthCoarseCount-1 downto 8);
              else
              end if;

            when others =>
              dataLocalBusOut <= x"ff";
          end case;
          state_lbus    <= Done;

        when Done =>
          readyLocalBus    <= '1';
          if(weLocalBus = '0' and reLocalBus = '0') then
            state_lbus    <= Idle;
          end if;

        -- probably this is error --
        when others =>
          state_lbus    <= Init;
      end case;
    end if;
  end process u_BusProcess;

  -- Reset sequence --
  u_reset_gen : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;
