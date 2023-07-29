library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

library mylib;
use mylib.defToplevel.all;
use mylib.defTRM.all;
use mylib.defTdcBlock.all;
use mylib.defMTDC.all;
use mylib.defYAENAMIController.all; -- Slow Control
use mylib.defMAX.all; -- APD_BIAS
use mylib.defC6C.all;
use mylib.defEVB.all;
use mylib.defSiTCP.all;
use mylib.defMiiRstTimer.all;
use mylib.defBCT.all;

entity toplevel is
  Port (
      -- System ---------------------------------------------------------------
    PROGB_ON            : out std_logic;
    BASE_CLKP           : in std_logic;
    BASE_CLKN           : in std_logic;
    USR_RSTB            : in std_logic;
    LED                 : out std_logic_vector(4 downto 1);
    DIP                 : in std_logic_vector(8 downto 1);
    VP                  : in std_logic;
    VN                  : in std_logic;

    -- GTX ------------------------------------------------------------------
    GTX_REFCLK_P        : in std_logic;        -- not included in .xlsx
    GTX_REFCLK_N        : in std_logic;        -- not included in .xlsx
    GTX_TX_P            : out std_logic_vector(0 downto 0);
    GTX_RX_P            : in std_logic_vector(0 downto 0);
    GTX_TX_N            : out std_logic_vector(0 downto 0);
    GTX_RX_N            : in std_logic_vector(0 downto 0);
    -- SFP_SCL             : inout std_logic;
    -- SFP_SDA             : inout std_logic;

    -- SPI flash ------------------------------------------------------------
    SPI_MOSI            : out std_logic;
    SPI_DIN             : in std_logic;
    -- SPI_D2              : in std_logic;
    -- SPI_D3              : in std_logic;
    FCSB                : out std_logic;

    -- EEPROM ---------------------------------------------------------------
    EEP_CS              : out std_logic;
    EEP_SK              : out std_logic;
    EEP_DI              : out std_logic;
    EEP_DO              : in std_logic;

    -- NIM-IO ---------------------------------------------------------------
    NIM_IN              : in std_logic_vector(2 downto 1);
    NIM_OUT             : out std_logic_vector(2 downto 1);

    -- JItter cleaner -------------------------------------------------------
    CDCE_PDB            : out std_logic;
    CDCE_LOCK           : in std_logic;
    CDCE_SCLK           : out std_logic;
    CDCE_SO             : in std_logic;
    CDCE_SI             : out std_logic;
    CDCE_SEN            : out std_logic;
    CDCE_REFP           : out std_logic;
    CDCE_REFN           : out std_logic;
    CDCE_CLKP           : in std_logic_vector(1 downto 0);
    CDCE_CLKN           : in std_logic_vector(1 downto 0);

    -- MIKUMARI -------------------------------------------------------------
    -- CDCM_RX_P           : in std_logic;
    -- CDCM_RX_N           : in std_logic;
    -- CDCM_TX_P           : out std_logic;
    -- CDCM_TX_N           : out std_logic;

    -- ASIC -----------------------------------------------------------------
    -- ASIC_REFC           : out std_logic_vector(3 downto 0);
    ASIC_SSB            : out std_logic_vector(3 downto 0);
    ASIC_SCK            : out std_logic;
    ASIC_MOSI           : out std_logic;


    ASIC_DISCRI         : in std_logic_vector(31 downto 0);

    -- TRIGGER_OUT ----------------------------------------------------------
    -- TRIG_O              : out std_logic_vector(31 downto 0);

    -- APD_BIAS -------------------------------------------------------------
    CP_CS_B             : out std_logic;
    CP_SCLK             : out std_logic;
    CP_DIN              : out std_logic;
    -- CP_CL_B             : in std_logic;

    -- ASIC_ADC -------------------------------------------------------------
    ADC_DATA_P          : in std_logic_vector(31 downto 0);
    ADC_DATA_N          : in std_logic_vector(31 downto 0);


    ADC_DFRAME_P        : in std_logic_vector(3 downto 0);
    ADC_DFRAME_N        : in std_logic_vector(3 downto 0);
    ADC_DCLK_P          : in std_logic_vector(3 downto 0);
    ADC_DCLK_N          : in std_logic_vector(3 downto 0)

    -- MEZZANINE ------------------------------------------------------------
    -- MZN_P               : inout std_logic_vector(7 downto 0);
    -- MZN_N               : inout std_logic_vector(7 downto 0);


    -- System ----------------------------------------------------------------
    -- CLKOSC        : in std_logic; -- 50 MHz
    -- LED           : out std_logic_vector(kNumLED-1 downto 0);
    -- DIP           : in  std_logic_vector(kNumBitDIP-1 downto 0);
    -- PROG_B_ON     : out std_logic;
    -- VP            : in std_logic; -- XADC
    -- VN            : in std_logic; -- XADC

    -- ASIC IO ---------------------------------------------------------------
    -- DISCRI_IN     : in std_logic_vector(kNumInput-1 downto 0); -- 0-31 ch

    -- PHY -------------------------------------------------------------------
    -- GTX_REFCLK_P        : in std_logic;
    -- GTX_REFCLK_N        : in std_logic;
    -- GTX_TX_P            : out std_logic_vector(kNumGtx downto 1);
    -- GTX_RX_P            : in  std_logic_vector(kNumGtx downto 1);
    -- GTX_TX_N            : out std_logic_vector(kNumGtx downto 1);
    -- GTX_RX_N            : in  std_logic_vector(kNumGtx downto 1);

    -- EEPROM ----------------------------------------------------------------
    -- PROM_CS	      : out std_logic;
    -- PROM_SK       : out std_logic;
    -- PROM_DI       : out std_logic;
    -- PROM_DO       : in std_logic;

    -- SPI flash memory ------------------------------------------------------
    -- FCS_B         : out std_logic;
--    USR_CLK       : out std_logic;
    -- MOSI          : out std_logic;
    -- DIN           : in  std_logic;

    -- User I/O --------------------------------------------------------------
    -- USER_RST_B    : in std_logic;
    -- NIMIN         : in  std_logic_vector(kNumNIM downto 1);
    -- NIMOUT        : out std_logic_vector(kNumNIM downto 1)

    );
end toplevel;

architecture Behavioral of toplevel is
  attribute mark_debug : string;
  attribute keep       : string;

  -- System ------------------------------------------------------------------
  signal sitcp_reset  : std_logic;
  signal system_reset : std_logic;
  signal user_reset   : std_logic;
  signal bct_reset    : std_logic;
  signal emergency_reset : std_logic;
  signal rst_from_bus : std_logic;

  signal delayed_usr_rstb : std_logic;

  -- DIP ---------------------------------------------------------------------
  signal dip_sw       : std_logic_vector(DIP'range);
  subtype DipID is integer range 1 to 8;
  type regLeaf is record
    Index : DipID;
  end record;
  constant kSiTCP     : regLeaf := (Index => 1);
  constant kC6CON     : regLeaf := (Index => 2);
  constant kNC2       : regLeaf := (Index => 3);
  constant kNC3       : regLeaf := (Index => 4);
  constant kNC4       : regLeaf := (Index => 5);
  constant kNC5       : regLeaf := (Index => 6);
  constant kNC6       : regLeaf := (Index => 7);
  constant kNC7       : regLeaf := (Index => 8);

  -- ASIC IO -----------------------------------------------------------------
  signal asic_adc_data            :  std_logic_vector(ADC_DATA_P'range);
  signal asic_adc_fco             :  std_logic_vector(ADC_DFRAME_P'range);
  signal asic_adc_dco             :  std_logic_vector(ADC_DCLK_P'range);

  signal asic_discri_input        :  std_logic_vector(ASIC_DISCRI'range);

  signal dummy_signal             : std_logic;

  -- TRM ---------------------------------------------------------------------
  signal seq_busy, module_busy    : std_logic;
  attribute keep of seq_busy      : signal is "TRUE";
  attribute keep of module_busy   : signal is "TRUE";

  signal reg_trm2evb              : dataTrm2Evb;
  signal reg_evb2trm              : dataEvb2Trm;
  signal trigger_out              : TrigDownType;

  -- DCT -----------------------------------------------------------------------------------
  signal daq_gate                 : std_logic;
  signal evb_reset_from_DCT       : std_logic;

  -- TDC ---------------------------------------------------------------------
  signal sig_in_tdc     : arrayInput;
  signal tdc_busy       : std_logic;
  signal data_tdc_bbus  : BBusDataTDC;

  -- IOM ----------------------------------------------------------------------------------
  signal ext_L1           : std_logic;
  signal ext_L2           : std_logic;
  signal ext_clr          : std_logic;
  signal ext_busy         : std_logic;

  -- C6C ----------------------------------------------------------------------------------
  signal c6c_reset        : std_logic;

  -- EVB ----------------------------------------------------------------------------------
  signal evb_reset        : std_logic;

  signal addr_bbus          : BBusAddressType;
  signal data_bbus          : BBusDataArray;
  signal re_bbus            : BBusControlType;
  signal rv_bbus            : BBusControlType;
  signal dready_bbus        : BBusControlType;
  signal bind_bbus          : BBusControlType;
  signal isbound_to_builder : BBusControlType;

  -- SDS ---------------------------------------------------------------------
  signal shutdown_over_temp     : std_logic;
  signal uncorrectable_flag     : std_logic;

  -- FMP ---------------------------------------------------------------------

  -- BCT --------------------------------------------------------------------
  signal addr_LocalBus          : LocalAddressType;
  signal data_LocalBusIn        : LocalBusInType;
  signal data_LocalBusOut       : DataArray;
  signal re_LocalBus            : ControlRegArray;
  signal we_LocalBus            : ControlRegArray;
  signal ready_LocalBus         : ControlRegArray;

  -- TSD ---------------------------------------------------------------------
  signal daq_data                          : std_logic_vector(kWidthDataTCP-1 downto 0);
  signal valid_data, empty_data, req_data  : std_logic;

  -- SiTCP ---------------------------------------------------------------------------------
  signal mii_reset    : std_logic;

  type typeUdpAddr is array(kNumGtx-1 downto 0) of std_logic_vector(kWidthAddrRBCP-1 downto 0);
  type typeUdpData is array(kNumGtx-1 downto 0) of std_logic_vector(kWidthDataRBCP-1 downto 0);
  type typeTcpData is array(kNumGtx-1 downto 0) of std_logic_vector(kWidthDataTCP-1 downto 0);

  signal tcp_isActive, close_req, close_act    : std_logic_vector(kNumGtx-1 downto 0);

  signal tcp_tx_clk   : std_logic_vector(kNumGtx-1 downto 0);
  signal tcp_rx_wr    : std_logic_vector(kNumGtx-1 downto 0);
  signal tcp_rx_data  : typeTcpData;
  signal tcp_tx_full  : std_logic_vector(kNumGtx-1 downto 0);
  signal tcp_tx_wr    : std_logic_vector(kNumGtx-1 downto 0);
  signal tcp_tx_data  : typeTcpData;

  signal rbcp_addr    : typeUdpAddr;
  signal rbcp_wd      : typeUdpData;
  signal rbcp_we      : std_logic_vector(kNumGtx-1 downto 0); --: Write enable
  signal rbcp_re      : std_logic_vector(kNumGtx-1 downto 0); --: Read enable
  signal rbcp_ack     : std_logic_vector(kNumGtx-1 downto 0); -- : Access acknowledge
  signal rbcp_rd      : typeUdpData;

  signal rbcp_gmii_addr    : typeUdpAddr;
  signal rbcp_gmii_wd      : typeUdpData;
  signal rbcp_gmii_we      : std_logic_vector(kNumGtx-1 downto 0); --: Write enable
  signal rbcp_gmii_re      : std_logic_vector(kNumGtx-1 downto 0); --: Read enable
  signal rbcp_gmii_ack     : std_logic_vector(kNumGtx-1 downto 0); -- : Access acknowledge
  signal rbcp_gmii_rd      : typeUdpData;

  component WRAP_SiTCP_GMII_XC7K_32K
    port
      (
        CLK                   : in std_logic; --: System Clock >129MHz
        RST                   : in std_logic; --: System reset
        -- Configuration parameters
        FORCE_DEFAULTn        : in std_logic; --: Load default parameters
        EXT_IP_ADDR           : in std_logic_vector(31 downto 0); --: IP address[31:0]
        EXT_TCP_PORT          : in std_logic_vector(15 downto 0); --: TCP port #[15:0]
        EXT_RBCP_PORT         : in std_logic_vector(15 downto 0); --: RBCP port #[15:0]
        PHY_ADDR              : in std_logic_vector(4 downto 0);  --: PHY-device MIF address[4:0]

        -- EEPROM
        EEPROM_CS             : out std_logic; --: Chip select
        EEPROM_SK             : out std_logic; --: Serial data clock
        EEPROM_DI             : out    std_logic; --: Serial write data
        EEPROM_DO             : in std_logic; --: Serial read data
        --    user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
        USR_REG_X3C           : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3C
        USR_REG_X3D           : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3D
        USR_REG_X3E           : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3E
        USR_REG_X3F           : out    std_logic_vector(7 downto 0); --: Stored at 0xFFFF_FF3F
        -- MII interface
        GMII_RSTn             : out    std_logic; --: PHY reset
        GMII_1000M            : in std_logic;  --: GMII mode (0:MII, 1:GMII)
        -- TX
        GMII_TX_CLK           : in std_logic; -- : Tx clock
        GMII_TX_EN            : out    std_logic; --: Tx enable
        GMII_TXD              : out    std_logic_vector(7 downto 0); --: Tx data[7:0]
        GMII_TX_ER            : out    std_logic; --: TX error
        -- RX
        GMII_RX_CLK           : in std_logic; -- : Rx clock
        GMII_RX_DV            : in std_logic; -- : Rx data valid
        GMII_RXD              : in std_logic_vector(7 downto 0); -- : Rx data[7:0]
        GMII_RX_ER            : in std_logic; --: Rx error
        GMII_CRS              : in std_logic; --: Carrier sense
        GMII_COL              : in std_logic; --: Collision detected
        -- Management IF
        GMII_MDC              : out std_logic; --: Clock for MDIO
        GMII_MDIO_IN          : in std_logic; -- : Data
        GMII_MDIO_OUT         : out    std_logic; --: Data
        GMII_MDIO_OE          : out    std_logic; --: MDIO output enable
        -- User I/F
        SiTCP_RST             : out    std_logic; --: Reset for SiTCP and related circuits
        -- TCP connection control
        TCP_OPEN_REQ          : in std_logic; -- : Reserved input, shoud be 0
        TCP_OPEN_ACK          : out    std_logic; --: Acknowledge for open (=Socket busy)
        TCP_ERROR             : out    std_logic; --: TCP error, its active period is equal to MSL
        TCP_CLOSE_REQ         : out    std_logic; --: Connection close request
        TCP_CLOSE_ACK         : in std_logic ;-- : Acknowledge for closing
        -- FIFO I/F
        TCP_RX_WC             : in std_logic_vector(15 downto 0); --: Rx FIFO write count[15:0] (Unused bits should be set 1)
        TCP_RX_WR             : out    std_logic; --: Write enable
        TCP_RX_DATA           : out    std_logic_vector(7 downto 0); --: Write data[7:0]
        TCP_TX_FULL           : out    std_logic; --: Almost full flag
        TCP_TX_WR             : in std_logic; -- : Write enable
        TCP_TX_DATA           : in std_logic_vector(7 downto 0); -- : Write data[7:0]
        -- RBCP
        RBCP_ACT              : out std_logic; -- RBCP active
        RBCP_ADDR             : out    std_logic_vector(31 downto 0); --: Address[31:0]
        RBCP_WD               : out    std_logic_vector(7 downto 0); --: Data[7:0]
        RBCP_WE               : out    std_logic; --: Write enable
        RBCP_RE               : out    std_logic; --: Read enable
        RBCP_ACK              : in std_logic; -- : Access acknowledge
        RBCP_RD               : in std_logic_vector(7 downto 0 ) -- : Read data[7:0]
        );
  end component;

  -- SFP transceiver -----------------------------------------------------------------------
  constant kMiiPhyad      : std_logic_vector(kWidthPhyAddr-1 downto 0):= "00000";
  signal mii_init_mdc, mii_init_mdio : std_logic;

  component mii_initializer is
    port(
      -- System
      CLK         : in std_logic;
      --RST         => system_reset,
      RST         : in std_logic;
      -- PHY
      PHYAD       : in std_logic_vector(kWidthPhyAddr-1 downto 0);
      -- MII
      MDC         : out std_logic;
      MDIO_OUT    : out std_logic;
      -- status
      COMPLETE    : out std_logic
      );
  end component;

  signal mmcm_reset_all   : std_logic;
  signal mmcm_reset       : std_logic_vector(kNumGtx-1 downto 0);
  signal mmcm_locked      : std_logic;

  signal gt0_qplloutclk, gt0_qplloutrefclk  : std_logic;
  signal gtrefclk_i, gtrefclk_bufg  : std_logic;
  signal txout_clk, rxout_clk       : std_logic_vector(kNumGtx-1 downto 0);
  signal user_clk, user_clk2, rxuser_clk, rxuser_clk2   : std_logic;

  signal eth_tx_clk       : std_logic_vector(kNumGtx-1 downto 0);
  signal eth_tx_en        : std_logic_vector(kNumGtx-1 downto 0);
  signal eth_tx_er        : std_logic_vector(kNumGtx-1 downto 0);
  signal eth_tx_d         : typeTcpData;

  signal eth_rx_clk       : std_logic_vector(kNumGtx-1 downto 0);
  signal eth_rx_dv        : std_logic_vector(kNumGtx-1 downto 0);
  signal eth_rx_er        : std_logic_vector(kNumGtx-1 downto 0);
  signal eth_rx_d         : typeTcpData;


  -- Clock -------------------------------------------------------------------
  signal clk_tdc                    : std_logic_vector(kNumTdcClock-1 downto 0);
  signal clk_sys                    : std_logic;
  signal clk_link, clk_indep        : std_logic;
  signal clk_spi                    : std_logic;
  signal clk_locked_sys             : std_logic;
  signal clk_locked_cdcm            : std_logic;
  signal clk_locked                 : std_logic;
  signal mmcm_cdcm_reset            : std_logic;

  signal clk_10MHz, clk_1MHz, clk_100kHz, clk_10kHz, clk_1kHz : std_logic;

  component clk_wiz_sys
    port
     (-- Clock in ports
      -- Clock out ports
      clk_link          : out    std_logic;
      clk_indep          : out    std_logic;
      clk_spi          : out    std_logic;
      clk_10MHz          : out    std_logic;
      -- Status and control signals
      reset             : in     std_logic;
      locked            : out    std_logic;
      clk_in1_p         : in     std_logic;
      clk_in1_n         : in     std_logic
     );
  end component;

  component clk_wiz_cdcm
    port
     (-- Clock in ports
      -- Clock out ports
      clk_sys          : out    std_logic;
      clk_tdc0          : out    std_logic;
      clk_tdc1          : out    std_logic;
      clk_tdc2          : out    std_logic;
      clk_tdc3          : out    std_logic;
      -- Status and control signals
      reset             : in     std_logic;
      locked            : out    std_logic;
      clk_in1           : in     std_logic
     );
  end component;

  -- debug -----------------------------------------------------------------------------
  --attribute mark_debug of clk_150MHz : signal is "true";

begin
  -- ===================================================================================
  -- body
  -- ===================================================================================

  -- Global ------------------------------------------------------------------
  u_DelayUsrRstb : entity mylib.DelayGen
    generic map(kNumDelay => 128)
    port map(clk_link, USR_RSTB, delayed_usr_rstb);

  c6c_reset       <= '1' when(dip_sw(kC6CON.Index) = '0') else (not delayed_usr_rstb);
  mmcm_cdcm_reset <= (not delayed_usr_rstb);

  clk_locked    <= clk_locked_sys and clk_locked_cdcm;
  system_reset  <= (NOT clk_locked) or (not USR_RSTB);
  user_reset    <= system_reset or rst_from_bus or emergency_reset;
  bct_reset     <= system_reset or emergency_reset;

  --dip_sw(0)   <= NOT DIP(0);
  dip_sw(1)   <= DIP(1);
  dip_sw(2)   <= DIP(2);
  dip_sw(3)   <= DIP(3);
  dip_sw(4)   <= DIP(4);
  dip_sw(5)   <= DIP(5);
  dip_sw(6)   <= DIP(6);
  dip_sw(7)   <= DIP(7);

  NIM_OUT(1)  <= trigger_out.L1accept;
  NIM_OUT(2)  <= dummy_signal;

  dummy_signal  <= or_reduce(asic_adc_data) or or_reduce(asic_adc_fco) or or_reduce(asic_adc_dco);

  -- Temp IO --
  gen_adc_d : for i in 0 to 31 generate
  begin
    u_ibufds_d : IBUFDS
      generic map (
        DIFF_TERM => true, -- Differential Termination
        IBUF_LOW_PWR => true, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD => "LVDS")
      port map (
        O  => asic_adc_data(i),  -- Buffer output
        I  => ADC_DATA_P(i),  -- Diff_p buffer input (connect directly to top-level port)
        IB => ADC_DATA_N(i) -- Diff_n buffer input (connect directly to top-level port)
      );
  end generate;

  gen_adc_fc : for i in 0 to 3 generate
  begin
    u_ibufds_f : IBUFDS
      generic map (
        DIFF_TERM => true, -- Differential Termination
        IBUF_LOW_PWR => true, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD => "LVDS")
      port map (
        O  => asic_adc_fco(i),  -- Buffer output
        I  => ADC_DFRAME_P(i),  -- Diff_p buffer input (connect directly to top-level port)
        IB => ADC_DFRAME_N(i) -- Diff_n buffer input (connect directly to top-level port)
      );

    u_ibufds_c : IBUFDS
      generic map (
        DIFF_TERM => true, -- Differential Termination
        IBUF_LOW_PWR => true, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD => "LVDS")
      port map (
        O  => asic_adc_dco(i),  -- Buffer output
        I  => ADC_DCLK_P(i),  -- Diff_p buffer input (connect directly to top-level port)
        IB => ADC_DCLK_N(i) -- Diff_n buffer input (connect directly to top-level port)
      );
  end generate;

  -- Fixed input ports -------------------------------------------------------
  asic_discri_input  <= ASIC_DISCRI;

  -- TRM -------------------------------------------------------------------------------
  -- LED <= clk_locked_sys & clk_locked_cdcm & module_busy &  tcp_isActive;
  LED <= CDCE_LOCK & clk_locked_cdcm & module_busy &  tcp_isActive;

  seq_busy   <= tdc_busy;-- OR dip_sw(kFBUSY.Index);

  u_TRM_Inst :  entity mylib.TriggerManager
    port map(
      RST                     => user_reset,
      CLK                     => clk_sys,

      -- Busy In --
      sequenceBusy            => seq_busy,
      gateDAQ                 => daq_gate,

      -- Busy Out --
      moduleBusy              => module_busy,

      -- Ext trigger    In --
      ExtClear                => '0',
      ExtL1                   => ext_L1,
      ExtL2                   => '0',

      -- J0 trigger --
      J0Clear                 => '0',
      J0L1                    => '0',
      J0L2                    => '0',
      J0TAG                   => "0000",
      EnJ0C                   => open,

      -- RM trigger --
      RMClear                 => '0',
      RML1                    => '0',
      RML2                    => '0',
      RMTAG                   => "0000",

      -- module input --
      dInTRM                  => reg_evb2trm,

      -- module output --
      TriggerToDAQ            => trigger_out,
      dOutTRM                 => reg_trm2evb,

      -- Local bus --
      addrLocalBus        => addr_LocalBus,
      dataLocalBusIn      => data_LocalBusIn,
      dataLocalBusOut     => data_LocalBusOut(kTRM.ID),
      reLocalBus          => re_LocalBus(kTRM.ID),
      weLocalBus          => we_LocalBus(kTRM.ID),
      readyLocalBus       => ready_LocalBus(kTRM.ID)
      );

  -- DCT -------------------------------------------------------------------------------
  u_DCT_Inst :  entity mylib.DAQController
    port map(
      rst                 => user_reset,
      clk                 => clk_sys,
      -- Module output --
      daqGate             => daq_gate,
      rstEvb              => evb_reset_from_DCT,
      -- Local bus --
      addrLocalBus        => addr_LocalBus,
      dataLocalBusIn      => data_LocalBusIn,
      dataLocalBusOut     => data_LocalBusOut(kDCT.ID),
      reLocalBus          => re_LocalBus(kDCT.ID),
      weLocalBus          => we_LocalBus(kDCT.ID),
      readyLocalBus       => ready_LocalBus(kDCT.ID)
      );

  -- TDC -------------------------------------------------------------------------------
  sig_in_tdc(0)(0)             <= NIM_IN(2);
  sig_in_tdc(0)(31 downto 1)   <= ASIC_DISCRI(31 downto 1);

  data_bbus(kBbTDCL0.ID) <= data_tdc_bbus(0);
  data_bbus(kBbTDCT0.ID) <= data_tdc_bbus(1);

  u_TDC_Inst : entity mylib.MTDC
    port map(
      rst         => user_reset,
      clk         => clk_sys,
      clkTdc      => clk_tdc,

      -- Module input --
      enRM        => '0',
      triggerIn   => trigger_out,
      sigIn       => sig_in_tdc,

      -- Module output --
      busyTdc     => tdc_busy,

      -- Builder bus --
      addrBuilderBus      => addr_bbus,
      dataBuilderBusOut   => data_tdc_bbus,
      reBuilderBus        => re_bbus(kBbTDCT0.ID downto kBbTDCL0.ID),
      rvBuilderBus        => rv_bbus(kBbTDCT0.ID downto kBbTDCL0.ID),
      dReadyBuilderBus    => dready_bbus(kBbTDCT0.ID downto kBbTDCL0.ID),
      bindBuilderBus      => bind_bbus(kBbTDCT0.ID downto kBbTDCL0.ID),
      isBoundToBuilder    => isbound_to_builder(kBbTDCT0.ID downto kBbTDCL0.ID),

      -- Local bus --
      addrLocalBus        => addr_LocalBus,
      dataLocalBusIn      => data_LocalBusIn,
      dataLocalBusOut     => data_LocalBusOut(kTDC.ID),
      reLocalBus          => re_LocalBus(kTDC.ID),
      weLocalBus          => we_LocalBus(kTDC.ID),
      readyLocalBus       => ready_LocalBus(kTDC.ID)
      );

  -- IOM -------------------------------------------------------------------------------
  u_IOM_Inst : entity mylib.IOManager
    port map(
      rst                 => user_reset,
      clk                 => clk_sys,

      -- NIM input signal --
      NimIn               => NIM_IN,
      ExtL1               => ext_L1,
      ExtL2               => ext_L2,
      ExtClr              => ext_clr,
      ExtBusy             => ext_busy,

      -- NIM output signal --
      -- NimOut              => NIM_OUT,
      NimOut              => open,
      ModuleBusy          => module_busy,
      DaqGate             => daq_gate,
      clk1MHz             => clk_1MHz,
      clk100kHz           => clk_100kHz,
      clk10kHz            => clk_10kHz,
      clk1kHz             => clk_1kHz,

      -- Local bus --
      addrLocalBus        => addr_LocalBus,
      dataLocalBusIn      => data_LocalBusIn,
      dataLocalBusOut     => data_LocalBusOut(kIOM.ID),
      reLocalBus          => re_LocalBus(kIOM.ID),
      weLocalBus          => we_LocalBus(kIOM.ID),
      readyLocalBus       => ready_LocalBus(kIOM.ID)
      );
  -- YSC (YAENAMI Slow Control) ---------------------------------------------------------
  u_YSC_Inst : entity mylib.YAENAMIController
    generic map  -- use generic parameters in SctDriver.vhd
    (
      kFreqSysClk   => 125_000_000,
      kNumIO        => kNumIO,   -- # of MOSI lines: defined in defToplevel.vhd
      kNumASIC      => kNumASIC, -- # of ASICs; defined in defToplevel.vhd
      enDebug       => true
    )
    port map
    (
      -- System --
      rst         => user_reset,   -- port name(defined in SctDriver) => signal name
      clk         => clk_sys,

      -- Rx Chip port --
      SSB         => ASIC_SSB,  -- vector
      MOSI        => ASIC_MOSI,
      SCK         => ASIC_SCK,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kYSC.ID),
      reLocalBus        => re_LocalBus(kYSC.ID),
      weLocalBus        => we_LocalBus(kYSC.ID),
      readyLocalBus     => ready_LocalBus(kYSC.ID)
  );

  -- APD_BIAS -------------------------------------------------------------------------
  u_APD_Inst : entity mylib.MAX1932Controller
    generic map(
      kSysClkFreq         => 125_000_000
    )
    port map(
      rst	          => user_reset,
      clk	          => clk_sys,

      -- Module output --
      CSB_SPI           => CP_CS_B,
      SCLK_SPI          => CP_SCLK,
      MOSI_SPI          => CP_DIN,

      -- Local bus --
      addrLocalBus	    => addr_LocalBus,
      dataLocalBusIn	  => data_LocalBusIn,
      dataLocalBusOut	  => data_LocalBusOut(kAPD.ID),
      reLocalBus	      => re_LocalBus(kAPD.ID),
      weLocalBus	      => we_LocalBus(kAPD.ID),
      readyLocalBus	    => ready_LocalBus(kAPD.ID)
    );

  -- C6C -------------------------------------------------------------------------------
  u_C6C_Inst : entity mylib.CDCE62002Controller
    generic map(
      kSysClkFreq         => 125_000_000,
      kIoStandard         => "LVDS"
    )
    port map(
      rst	                => system_reset,
      clk	                => clk_sys,
      refClkIn            => clk_link,

      chipReset           => c6c_reset,
      clkIndep            => clk_sys,
      chipLock            => CDCE_LOCK,

      -- Module output --
      PDB                 => CDCE_PDB,
      REF_CLKP            => CDCE_REFP,
      REF_CLKN            => CDCE_REFN,
      CSB_SPI             => CDCE_SEN,
      SCLK_SPI            => CDCE_SCLK,
      MOSI_SPI            => CDCE_SI,
      MISO_SPI            => CDCE_SO,

      -- Local bus --
      addrLocalBus	      => addr_LocalBus,
      dataLocalBusIn	    => data_LocalBusIn,
      dataLocalBusOut	    => data_LocalBusOut(kC6C.ID),
      reLocalBus		      => re_LocalBus(kC6C.ID),
      weLocalBus		      => we_LocalBus(kC6C.ID),
      readyLocalBus	      => ready_LocalBus(kC6C.ID)
    );

  -- EVB -------------------------------------------------------------------------------
  evb_reset   <= user_reset OR evb_reset_from_DCT;

  u_EVB_Inst : entity mylib.EventBuilder
    port map(
      rst         => evb_reset,
      clk         => clk_sys,
      clkLink     => clk_link,
      EnRM        => '0',

      -- TRM data --
      dInTRM      => reg_trm2evb,
      dOutTRM     => reg_evb2trm,

      -- Builder bus --
      addrBuilderBus      => addr_bbus,
      dataBuilderBusIn    => data_bbus,
      reBuilderBus        => re_bbus,
      rvBuilderBus        => rv_bbus,
      dReadyBuilderBus    => dready_bbus,
      bindBuilderBus      => bind_bbus,
      isBoundToBuilder    => isbound_to_builder,

      -- TSD data --
      rdToTSD     => daq_data,
      rvToTSD     => valid_data,
      emptyToTSD  => empty_data,
      reFromTSD   => req_data
      );

  -- SDS --------------------------------------------------------------------
  u_SDS_Inst : entity mylib.SelfDiagnosisSystem
    port map(
      rst               => user_reset,
      clk               => clk_sys,
      clkIcap           => clk_spi,

      -- Module input  --
      VP                => VP,
      VN                => VN,

      -- Module output --
      shutdownOverTemp  => shutdown_over_temp,
      uncorrectableAlarm => uncorrectable_flag,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kSDS.ID),
      reLocalBus        => re_LocalBus(kSDS.ID),
      weLocalBus        => we_LocalBus(kSDS.ID),
      readyLocalBus     => ready_LocalBus(kSDS.ID)
      );


  -- FMP --------------------------------------------------------------------
  u_FMP_Inst : entity mylib.FlashMemoryProgrammer
    port map(
      rst	              => user_reset,
      clk	              => clk_sys,
      clkSpi            => clk_spi,

      -- Module output --
      CS_SPI            => FCSB,
--      SCLK_SPI          => USR_CLK,
      MOSI_SPI          => SPI_MOSI,
      MISO_SPI          => SPI_DIN,

      -- Local bus --
      addrLocalBus      => addr_LocalBus,
      dataLocalBusIn    => data_LocalBusIn,
      dataLocalBusOut   => data_LocalBusOut(kFMP.ID),
      reLocalBus        => re_LocalBus(kFMP.ID),
      weLocalBus        => we_LocalBus(kFMP.ID),
      readyLocalBus     => ready_LocalBus(kFMP.ID)
      );


  -- BCT --------------------------------------------------------------------
  u_BCT_Inst : entity mylib.BusController
    port map(
      rstSys                    => bct_reset,
      rstFromBus                => rst_from_bus,
      reConfig                  => PROGB_ON,
      clk                       => clk_sys,
      -- Local Bus --
      addrLocalBus              => addr_LocalBus,
      dataFromUserModules       => data_LocalBusOut,
      dataToUserModules         => data_LocalBusIn,
      reLocalBus                => re_LocalBus,
      weLocalBus                => we_LocalBus,
      readyLocalBus             => ready_LocalBus,
      -- RBCP --
      addrRBCP                  => rbcp_addr(0),
      wdRBCP                    => rbcp_wd(0),
      weRBCP                    => rbcp_we(0),
      reRBCP                    => rbcp_re(0),
      ackRBCP                   => rbcp_ack(0),
      rdRBCP                    => rbcp_rd(0)
      );

  -- TSD ---------------------------------------------------------------------
  u_TSD_Inst : entity mylib.TCP_sender
    port map(
      RST               => user_reset,
      CLK               => clk_link,

      -- data from EVB --
      rdFromEVB         => daq_data,
      rvFromEVB         => valid_data,
      emptyFromEVB      => empty_data,
      reToEVB           => req_data,

      -- data to SiTCP
      isActive          => tcp_isActive(0),
      afullTx           => tcp_tx_full(0),
      weTx              => tcp_tx_wr(0),
      wdTx              => tcp_tx_data(0)
      );


  -- SiTCP Inst ------------------------------------------------------------------------
  sitcp_reset     <= system_reset OR (NOT USR_RSTB);

  gen_SiTCP : for i in 0 to kNumGtx-1 generate

    eth_tx_clk(i)      <= eth_rx_clk(0);

    u_SiTCP_Inst : WRAP_SiTCP_GMII_XC7K_32K
      port map
      (
        CLK               => clk_link, --: System Clock >129MHz
        RST               => sitcp_reset, --: System reset
        -- Configuration parameters
        --FORCE_DEFAULTn    => dip_sw(kSiTCP.Index), --: Load default parameters
        FORCE_DEFAULTn    => '0', --: Load default parameters
        EXT_IP_ADDR       => X"00000000", --: IP address[31:0]
        EXT_TCP_PORT      => X"0000", --: TCP port #[15:0]
        EXT_RBCP_PORT     => X"0000", --: RBCP port #[15:0]
        PHY_ADDR          => "00000", --: PHY-device MIF address[4:0]
        -- EEPROM
        EEPROM_CS         => EEP_CS, --: Chip select
        EEPROM_SK         => EEP_SK, --: Serial data clock
        EEPROM_DI         => EEP_DI, --: Serial write data
        EEPROM_DO         => EEP_DO, --: Serial read data
        --    user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
        USR_REG_X3C       => open, --: Stored at 0xFFFF_FF3C
        USR_REG_X3D       => open, --: Stored at 0xFFFF_FF3D
        USR_REG_X3E       => open, --: Stored at 0xFFFF_FF3E
        USR_REG_X3F       => open, --: Stored at 0xFFFF_FF3F
        -- MII interface
        GMII_RSTn         => open, --: PHY reset
        GMII_1000M        => '1',  --: GMII mode (0:MII, 1:GMII)
        -- TX
        GMII_TX_CLK       => eth_tx_clk(i), --: Tx clock
        GMII_TX_EN        => eth_tx_en(i),  --: Tx enable
        GMII_TXD          => eth_tx_d(i),   --: Tx data[7:0]
        GMII_TX_ER        => eth_tx_er(i),  --: TX error
        -- RX
        GMII_RX_CLK       => eth_rx_clk(0), --: Rx clock
        GMII_RX_DV        => eth_rx_dv(i),  --: Rx data valid
        GMII_RXD          => eth_rx_d(i),   --: Rx data[7:0]
        GMII_RX_ER        => eth_rx_er(i),  --: Rx error
        GMII_CRS          => '0', --: Carrier sense
        GMII_COL          => '0', --: Collision detected
        -- Management IF
        GMII_MDC          => open, --: Clock for MDIO
        GMII_MDIO_IN      => '1', -- : Data
        GMII_MDIO_OUT     => open, --: Data
        GMII_MDIO_OE      => open, --: MDIO output enable
        -- User I/F
        SiTCP_RST         => emergency_reset, --: Reset for SiTCP and related circuits
        -- TCP connection control
        TCP_OPEN_REQ      => '0', -- : Reserved input, shoud be 0
        TCP_OPEN_ACK      => tcp_isActive(i), --: Acknowledge for open (=Socket busy)
        --    TCP_ERROR           : out    std_logic; --: TCP error, its active period is equal to MSL
        TCP_CLOSE_REQ     => close_req(i), --: Connection close request
        TCP_CLOSE_ACK     => close_act(i), -- : Acknowledge for closing
        -- FIFO I/F
        TCP_RX_WC         => X"0000",    --: Rx FIFO write count[15:0] (Unused bits should be set 1)
        TCP_RX_WR         => open, --: Read enable
        TCP_RX_DATA       => open, --: Read data[7:0]
        TCP_TX_FULL       => tcp_tx_full(i), --: Almost full flag
        TCP_TX_WR         => tcp_tx_wr(i),   -- : Write enable
        TCP_TX_DATA       => tcp_tx_data(i), -- : Write data[7:0]
        -- RBCP
        RBCP_ACT          => open, --: RBCP active
        RBCP_ADDR         => rbcp_gmii_addr(i), --: Address[31:0]
        RBCP_WD           => rbcp_gmii_wd(i),   --: Data[7:0]
        RBCP_WE           => rbcp_gmii_we(i),   --: Write enable
        RBCP_RE           => rbcp_gmii_re(i),   --: Read enable
        RBCP_ACK          => rbcp_gmii_ack(i),  --: Access acknowledge
        RBCP_RD           => rbcp_gmii_rd(i)    --: Read data[7:0]
        );

  u_RbcpCdc : entity mylib.RbcpCdc
  port map(
    -- Mikumari clock domain --
    rstSys      => system_reset,
    clkSys      => clk_sys,
    rbcpAddr    => rbcp_addr(i),
    rbcpWd      => rbcp_wd(i),
    rbcpWe      => rbcp_we(i),
    rbcpRe      => rbcp_re(i),
    rbcpAck     => rbcp_ack(i),
    rbcpRd      => rbcp_rd(i),

    -- GMII clock domain --
    rstXgmii    => system_reset,
    clkXgmii    => clk_link,
    rbcpXgAddr  => rbcp_gmii_addr(i),
    rbcpXgWd    => rbcp_gmii_wd(i),
    rbcpXgWe    => rbcp_gmii_we(i),
    rbcpXgRe    => rbcp_gmii_re(i),
    rbcpXgAck   => rbcp_gmii_ack(i),
    rbcpXgRd    => rbcp_gmii_rd(i)
    );

    u_gTCP_inst : entity mylib.global_sitcp_manager
      port map(
        RST           => system_reset,
        CLK           => clk_link,
        ACTIVE        => tcp_isActive(i),
        REQ           => close_req(i),
        ACT           => close_act(i),
        rstFromTCP    => open
        );
  end generate;

  -- SFP transceiver -------------------------------------------------------------------
  u_MiiRstTimer_Inst : entity mylib.MiiRstTimer
    port map(
      rst         => system_reset,
      clk         => clk_link,
      rstMiiOut   => mii_reset
    );

  u_MiiInit_Inst : mii_initializer
    port map(
      -- System
      CLK         => clk_link,
      --RST         => system_reset,
      RST         => mii_reset,
      -- PHY
      PHYAD       => kMiiPhyad,
      -- MII
      MDC         => mii_init_mdc,
      MDIO_OUT    => mii_init_mdio,
      -- status
      COMPLETE    => open
      );

  mmcm_reset_all  <= or_reduce(mmcm_reset);

  u_GtClockDist_Inst : entity mylib.GtClockDistributer2
    port map(
      -- GTX refclk --
      GT_REFCLK_P   => GTX_REFCLK_P,
      GT_REFCLK_N   => GTX_REFCLK_N,

      gtRefClk      => gtrefclk_i,
      gtRefClkBufg  => gtrefclk_bufg,

      -- USERCLK2 --
      mmcmReset     => mmcm_reset_all,
      mmcmLocked    => mmcm_locked,
      txOutClk      => txout_clk(0),
      rxOutClk      => rxout_clk(0),

      userClk       => user_clk,
      userClk2      => user_clk2,
      rxuserClk     => rxuser_clk,
      rxuserClk2    => rxuser_clk2,

      -- GTXE_COMMON --
      reset         => system_reset,
      clkIndep      => clk_indep,
      clkQPLL       => gt0_qplloutclk,
      refclkQPLL    => gt0_qplloutrefclk
      );

  gen_pcspma : for i in 0 to kNumGtx-1 generate
    u_pcspma_Inst : entity mylib.GbEPcsPma
      port map(

        --An independent clock source used as the reference clock for an
        --IDELAYCTRL (if present) and for the main GT transceiver reset logic.
        --This example design assumes that this is of frequency 200MHz.
        independent_clock    => clk_indep,

        -- Tranceiver Interface
        -----------------------
        gtrefclk             => gtrefclk_i,
        gtrefclk_bufg        => gtrefclk_bufg,

        gt0_qplloutclk       => gt0_qplloutclk,
        gt0_qplloutrefclk    => gt0_qplloutrefclk,

        userclk              => user_clk,
        userclk2             => user_clk2,
        rxuserclk            => rxuser_clk,
        rxuserclk2           => rxuser_clk2,

        mmcm_locked          => mmcm_locked,
        mmcm_reset           => mmcm_reset(i),

        -- clockout --
        txoutclk             => txout_clk(i),
        rxoutclk             => rxout_clk(i),

        -- Tranceiver Interface
        -----------------------
        txp                  => GTX_TX_P(i),
        txn                  => GTX_TX_N(i),
        rxp                  => GTX_RX_P(i),
        rxn                  => GTX_RX_N(i),

        -- GMII Interface (client MAC <=> PCS)
        --------------------------------------
        gmii_tx_clk          => eth_tx_clk(i),
        gmii_rx_clk          => eth_rx_clk(i),
        gmii_txd             => eth_tx_d(i),
        gmii_tx_en           => eth_tx_en(i),
        gmii_tx_er           => eth_tx_er(i),
        gmii_rxd             => eth_rx_d(i),
        gmii_rx_dv           => eth_rx_dv(i),
        gmii_rx_er           => eth_rx_er(i),
        -- Management: MDIO Interface
        -----------------------------

        mdc                  => mii_init_mdc,
        mdio_i               => mii_init_mdio,
        mdio_o               => open,
        mdio_t               => open,
        phyaddr              => "00000",
        configuration_vector => "00000",
        configuration_valid  => '0',

        -- General IO's
        ---------------
        status_vector        => open,
        reset                => system_reset
        );
  end generate;


  -- Clock inst ------------------------------------------------------------------------
  u_ClkSys_Inst : clk_wiz_sys
    port map
     (-- Clock in ports
      -- Clock out ports
      clk_link          => clk_link,
      clk_indep         => clk_indep,
      clk_spi           => clk_spi,
      clk_10MHz         => clk_10MHz,
      -- Status and control signals
      reset             => '0',
      locked            => clk_locked_sys,
      clk_in1_p         => BASE_CLKP,
      clk_in1_n         => BASE_CLKN
     );

  u_ClkCdcm_Inst : clk_wiz_cdcm
   port map
    (-- Clock in ports
     -- Clock out ports
     clk_sys           => clk_sys,
     clk_tdc0          => clk_tdc(0),
     clk_tdc1          => clk_tdc(1),
     clk_tdc2          => clk_tdc(2),
     clk_tdc3          => clk_tdc(3),
     -- Status and control signals
     reset             => mmcm_cdcm_reset,
     locked            => clk_locked_cdcm,
     clk_in1           => clk_link
    );

  u_ClkDivision : entity mylib.ClkDivision
    port map(
      rst         => system_reset,
      clk         => clk_10MHz,

      -- module output --
      clk1MHz     => clk_1MHz,
      clk100kHz   => clk_100kHz,
      clk10kHz    => clk_10kHz,
      clk1kHz     => clk_1kHz
      );

  -- CDCE clocks --
  -- pll_is_locked   <= (mmcm_cdcm_locked or CDCE_LOCK) and clk_sys_locked;

--  u_IBUFDS_SLOW_inst : IBUFDS
--    generic map (
--       DIFF_TERM => TRUE, -- Differential Termination
--       IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--       IOSTANDARD => "LVDS")
--    port map (
--       O => NIM_OUT(1),  -- Buffer output
--       I => CDCE_CLKP(0),  -- Diff_p buffer input (connect directly to top-level port)
--       IB => CDCE_CLKN(0) -- Diff_n buffer input (connect directly to top-level port)
--       );
--
--  u_IBUFDS_FAST_inst : IBUFDS
--    generic map (
--       DIFF_TERM => TRUE, -- Differential Termination
--       IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--       IOSTANDARD => "LVDS")
--    port map (
--       O => NIM_OUT(2),  -- Buffer output
--       I => CDCE_CLKP(1),  -- Diff_p buffer input (connect directly to top-level port)
--       IB => CDCE_CLKN(1) -- Diff_n buffer input (connect directly to top-level port)
--       );

end Behavioral;
