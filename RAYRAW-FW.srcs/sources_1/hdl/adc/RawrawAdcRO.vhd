library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library mylib;
use mylib.defYaenamiAdc.all;
use mylib.defRayrawAdcROV1.all;

entity RawrayAdcRO is
  generic
  (
    enDEBUG            : boolean:= false
  );
  port
  (
    -- SYSTEM port --
    rst           : in std_logic; -- Asynchronous reset (active high)
    clkSys        : in std_logic; -- System clock (global clock)
    clkIdelayRef  : in std_logic; -- 200 MHz ref. clock.
    tapValueIn    : in TapType;   -- External TAP value input (for data)
    tapValueFrameIn    : in TapType;   -- External TAP value input (for frame)
    enExtTapIn    : in std_logic; -- Activate tapValueIn and tapValueFraneIn
    enBitslip     : in std_logic; -- Enablle bitslip sequence
    frameRefPatt  : in AdcDataType; -- ADC FRAME reference bit pattern

    -- Status --
    isReady       : out std_logic_vector(kNumAsicBlock-1 downto 0); -- If high, data outputs are valid
    bitslipErr    : out std_logic_vector(kNumAsicBlock-1 downto 0); -- Indicate bitslip failure
    clkAdc        : out std_logic_vector(kNumAsicBlock-1 downto 0); -- Regional clock: clk_sys (for debug)

    -- Data Out --
    validOut      : out std_logic_vector(kNumAsicBlock-1 downto 0); -- FIFO output is valid
    adcDataOut    : out AdcDataBlockArray; -- De-serialized ADC data
    adcFrameOut   : out AdcFrameBlockArray;-- De-serialized frame bit pattern

    -- ADC In --
    adcDClkP      : in std_logic_vector(kNumAsicBlock-1 downto 0);  -- ADC DCLK (forwarded fast clock)
    adcDClkN      : in std_logic_vector(kNumAsicBlock-1 downto 0);
    adcDataP      : in std_logic_vector(kNumAsicBlock*kNumAdcCh-1 downto 0); -- ADC DATA
    adcDataN      : in std_logic_vector(kNumAsicBlock*kNumAdcCh-1 downto 0);
    adcFrameP     : in std_logic_vector(kNumAsicBlock-1 downto 0);  -- ADC FRAME
    adcFrameN     : in std_logic_vector(kNumAsicBlock-1 downto 0)

  );
end RawrayAdcRO;

architecture RTL of RawrayAdcRO is
  -- Internal signal definition ---------------------------------------------------------
  -- ADC CLK domain --
  type AdcDataAsicArray is array (integer range kNumAsicBlock-1 downto 0) of AdcDataArray;
  signal adc_data_out   : AdcDataAsicArray;
  signal adc_frame_out  : AdcFrameBlockArray;

  signal clk_adc        : std_logic_vector(isReady'range);
  signal is_ready       : std_logic_vector(isReady'range);
  signal bitslip_error  : std_logic_vector(isReady'range);
  signal empty_fifo     : std_logic_vector(isReady'range);
  signal read_en        : std_logic_vector(isReady'range);

  type AdcFifoType is array (integer range kNumAsicBlock-1 downto 0) of std_logic_vector(kNumAdcBit*(kNumAdcCh+kNumFrame)-1 downto 0);
  signal din_fifo       : AdcFifoType;

  COMPONENT adc_cdc_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(89 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(89 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC
  );
  END COMPONENT;

  -- SYSTEM CLK domain --
  signal adc_data_block_out   : AdcDataBlockArray;
  signal adc_frame_block_out  : AdcFrameBlockArray;

  type SyncType is array (integer range kNumAsicBlock-1 downto 0) of std_logic_vector(kSyncLength-1 downto 0);
  signal sync_is_ready            : SyncType;
  signal sync_bitslip_error       : SyncType;
  signal read_valid               : std_logic_vector(isReady'range);
  signal dout_fifo                : AdcFifoType;

  signal tap_value_in         : TapBlockArray;
  signal tap_values           : TapBlockArray;

  attribute mark_debug        : boolean;
  attribute mark_debug of is_ready       : signal is enDEBUG;
  attribute mark_debug of adc_data_out   : signal is enDEBUG;
  attribute mark_debug of adc_frame_out  : signal is enDEBUG;


-- debug ---------------------------------------------------------------

begin
  -- ======================================================================
  --                                 body
  -- ======================================================================

  isReady     <= sync_is_ready(kSyncLength-1);
  bitslipErr  <= sync_bitslip_error(kSyncLength-1);
  clkAdc      <= clk_adc;

  validOut    <= read_valid;
  adcDataOut  <= adc_data_block_out;
  adcFrameOut <= adc_frame_block_out;


  -- Clock domain crossing ----------------------------------------------------------
  u_adc_to_sys : process(clkSys)
  begin
    if(clkSys'event and clkSys = '1') then
      sync_is_ready       <= sync_is_ready(kSyncLength-2 downto 0) & is_ready;
      sync_bitslip_error  <= sync_bitslip_error(kSyncLength-2 downto 0) & bitslip_error;
    end if;
  end process;

  -- ADC CLK domain ----------------------------------------------------
  gen_adc : for i in 0 to kNumAsicBlock-1 generate
  begin

    tap_values(i)  <= tap_value_in(i) when(enExtTapIn = '1') else GetTapValues(i);

    adc_frame_block_out(i)  <= dout_fifo(i)(kNumAdcBit*(kNumAdcCh+kNumFrame)-1 downto kNumAdcBit*(kNumAdcCh+kNumFrame)-kNumAdcBit);
    tap_value_in(i)(8)      <= tapValueFrameIn;

    gen_ch : for j in 0 to kNumAdcCh-1 generate
      adc_data_block_out(kNumAdcCh*i +j)   <= dout_fifo(i)(kNumAdcBit*(j+1)-1 downto kNumAdcBit*j);
      tap_value_in(i)(j)                   <= tapValueIn;
    end generate;

    u_adc : entity mylib.YaenamiAdc
      generic map
      (
        genIDELAYCTRL      => GetGenFlagIdelayCtrl(i),
        kDiffTerm          => TRUE,
        kIoStandard        => "LVDS",
        kIoDelayGroup      => GetIdelayGroup(i),
        kFreqRefClk        => 200.0,
        enDEBUG            => TRUE
      )
      port map
      (
        -- SYSTEM port --
        rst           => rst,
        invPolarity   => GetInvPolarity(i),
        clkIdelayRef  => clkIdelayRef,
        tapValueIn    => tap_values(i),
        tapValueOut   => open,
        enBitslip     => enBitslip,
        frameRefPatt  => frameRefPatt,

        -- Status --
        isReady       => is_ready(i),
        bitslipErr    => bitslip_error(i),

        -- Data Out --
        adcClk        => clk_adc(i),
        adcDataOut    => adc_data_out(i),
        adcFrameOut   => adc_frame_out(i),

        -- ADC In --
        adcDClkP      => adcDClkP(i),
        adcDClkN      => adcDClkN(i),
        adcDataP      => adcDataP((kNumAdcCh)*(i+1)-1 downto (kNumAdcCh)*i),
        adcDataN      => adcDataN((kNumAdcCh)*(i+1)-1 downto (kNumAdcCh)*i),
        adcFrameP     => adcFrameP(i),
        adcFrameN     => adcFrameN(i)

      );

    din_fifo(i)   <= adc_frame_out(i) & adc_data_out(i)(7) & adc_data_out(i)(6) & adc_data_out(i)(5) & adc_data_out(i)(4) & adc_data_out(i)(3) & adc_data_out(i)(2) & adc_data_out(i)(1) & adc_data_out(i)(0);

    read_en(i)  <= not empty_fifo(i);
    u_fifo : adc_cdc_fifo
      PORT MAP (
        rst     => rst,
        wr_clk  => clk_adc(i),
        rd_clk  => clkSys,
        din     => din_fifo(i),
        wr_en   => is_ready(i),
        rd_en   => read_en(i),
        dout    => dout_fifo(i),
        full    => open,
        empty   => empty_fifo(i),
        valid   => read_valid(i)
      );


  end generate;

  -- Clock domain crossing ---------------------------------------------------------

end RTL;
