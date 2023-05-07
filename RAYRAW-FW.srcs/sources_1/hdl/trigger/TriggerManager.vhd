library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use mylib.defTRM.all;
use mylib.defEVB.all;
use mylib.defBCT.all;

entity TriggerManager is
  port(
    rst 							: in std_logic;
    clk 							: in std_logic;

    -- Busy In --
    sequenceBusy	    : in std_logic;
    gateDAQ		        : in std_logic;

    -- Busy Out --
    moduleBusy        : out std_logic;

    -- Ext trigger	In --
    extClear 		      : in std_logic;
    extL1		          : in std_logic;
    extL2		          : in std_logic;

    -- J0 trigger --
    j0Clear		        : in std_logic;
    j0L1		          : in std_logic;
    j0L2		          : in std_logic;
    j0TAG		          : in std_logic_vector(kWidthTAG-1 downto 0);
    enJ0C             : out std_logic;

    -- RM trigger --
    rmClear           : in std_logic;
    rmL1              : in std_logic;
    rmL2              : in std_logic;
    rmTAG             : in std_logic_vector(kWidthTAG-1 downto 0);

    -- module input --
    dInTRM            : in dataEvb2Trm;

    -- module output --
    triggerToDAQ      : out TrigDownType;
    dOutTRM           : out dataTrm2Evb;

    -- Local bus --
    addrLocalBus	    : in LocalAddressType;
    dataLocalBusIn	  : in LocalBusInType;
    dataLocalBusOut	  : out LocalBusOutType;
    reLocalBus		    : in std_logic;
    weLocalBus		    : in std_logic;
    readyLocalBus	    : out std_logic
    );
end TriggerManager;

architecture RTL of TriggerManager is
  attribute mark_debug    : string;
  attribute keep          : string;

  -- System --
  signal sync_reset       : std_logic;

  -- signal declaration ------------------------------------------------------
  type DelayProcessType is ( Init, DelayCount, Arise, Width );
  signal state_delay, state_busy	      : DelayProcessType;
  signal state_lbus			                : BusProcessType;

  signal reg_sel_trig                   : std_logic_vector(kWidthSelTrig-1 downto 0);
  attribute keep of reg_sel_trig        : signal is "true";

  -- trigger signals -----------------------------------------------------
  signal L1_req, L1_trigger, L1_trigger_sync      : std_logic;
  signal L1_one_shot                              : std_logic;
  signal masked_L1				  : std_logic_vector(kNumOfTrigType-1 downto 0);

  signal L2_req, L2_trigger, L2_trigger_sync      : std_logic;
  signal L2_one_shot                              : std_logic;
  signal masked_L2				  : std_logic_vector(kNumOfTrigType-1 downto 0);

  signal clear_req, fast_clear, fast_clear_sync   : std_logic;
  signal fast_clear_one_shot                      : std_logic;
  signal masked_clear				: std_logic_vector(kNumOfTrigType-1 downto 0);

  signal tag_sel                                  : std_logic_vector(1 downto 0);
  signal tag_out, masked_tag, buf_tag1, buf_tag2  : std_logic_vector(kWidthTAG-1 downto 0);

  signal module_ready				                      : std_logic;
  signal self_busy, seq_busy, fifo_busy           : std_logic;
  attribute keep of self_busy : signal is "true";
  attribute keep of fifo_busy : signal is "true";
  attribute keep of seq_busy  : signal is "true";

  -- Trigger record ------------------------------------------------------
  signal prev_level2, current_level2        : std_logic;
  signal level2_detect, level2_detect_sync  : std_logic;

  signal full_fifo, afull_fifo, pgfull_fifo : std_logic;

  signal din_trig_record, dout_trig_record  : std_logic_vector(kWidthTriggerData-1 downto 0);
  signal empty_trig_record                  : std_logic;
  signal data_ready                         : std_logic;

  signal level2_detect_delay                : std_logic_vector(kNumL2Delay-1 downto 0);
  signal level2_delay                       : std_logic_vector(kNumL2Delay-1 downto 0);
  signal clear_delay                        : std_logic_vector(kNumL2Delay-1 downto 0);

  COMPONENT trigger_record_fifo
    PORT (
      clk         : IN STD_LOGIC;
      rst         : IN STD_LOGIC;
      din         : IN STD_LOGIC_VECTOR(kWidthTriggerData-1 DOWNTO 0);
      wr_en       : IN STD_LOGIC;
      rd_en       : IN STD_LOGIC;
      dout        : OUT STD_LOGIC_VECTOR(kWidthTriggerData-1 DOWNTO 0);
      full        : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty       : OUT STD_LOGIC;
      valid       : OUT STD_LOGIC;
      prog_full   : OUT STD_LOGIC
      );
  END COMPONENT;

  -- trigger signals -----------------------------------------------------
  signal count_busy   : std_logic_vector(kWidthBusyCount-1 downto 0);

  -- debug
--  attribute mark_debug of self_busy : signal is "TRUE";
--  attribute mark_debug of seq_busy : signal is "TRUE";
--  attribute mark_debug of fifo_busy : signal is "TRUE";

-- ================================= body ==================================
begin
  -- Signal connection -------------------------------------------------------
  enJ0C	<= reg_sel_trig(kEnJ0.Index);

  triggerToDAQ.L1request    <= L1_req;
  triggerToDAQ.L1accept	    <= L1_trigger;
  triggerToDAQ.L1OneShot    <= L1_one_shot;
  triggerToDAQ.L2accept	    <= L2_one_shot;
  triggerToDAQ.FastClear    <= fast_clear_one_shot;

  seq_busy   <= sequenceBusy;
  moduleBusy <= self_busy OR seq_busy OR fifo_busy;

  -- make L1 trigger ---------------------------------------------------------
  --module_ready	<= (NOT seq_busy) AND gateDAQ;
  module_ready	<= gateDAQ;
  L1_req	    <= '0' when masked_L1 = kTrigAllZero else '1';
  L1_trigger	<= L1_req AND module_ready;

  masked_L1	<=  (j0L1     and reg_sel_trig(kL1J0.Index)) &
                (extL1    and reg_sel_trig(kL1Ext.Index)) &
                (rmL1     and reg_sel_trig(kL1RM.Index));

  -- make L2 trigger ---------------------------------------------------------
  L2_req	    <= '0' when masked_L2 = kTrigAllZero else '1';
  L2_trigger	<= (L2_req AND module_ready) when reg_sel_trig(kEnL2.Index) = '1' else L1_trigger;

  masked_L2	<= (j0L2     and reg_sel_trig(kL2J0.Index)) &
               (extL2    and reg_sel_trig(kL2Ext.Index)) &
               (rmL2     and reg_sel_trig(kL2RM.Index));

  -- make clear --------------------------------------------------------------
  clear_req	  <= '0' when masked_clear = kTrigAllZero else '1';
  fast_clear	<= (clear_req and module_ready) when reg_sel_trig(kEnL2.Index) = '1' else '0';

  masked_clear	<= (J0Clear     and reg_sel_trig(kClrJ0.Index)) &
                   (ExtClear    and reg_sel_trig(kClrExt.Index)) &
                   (RMClear     and reg_sel_trig(kClrRM.Index));

  -- make J0 tag -------------------------------------------------------------
  tag_sel     <= reg_sel_trig(kEnJ0.Index) & reg_sel_trig(kEnRM.Index);
  masked_tag	<= J0TAG when tag_sel = "10" else
                 RMTAG when tag_sel = "01" else
                 "0000";

  u_reg_tag : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      buf_tag1  <= (others => '0');
      buf_tag2  <= (others => '0');
      tag_out   <= (others => '0');
    elsif(clk'event AND clk = '1') then
      buf_tag1  <= masked_tag;
      buf_tag2  <= buf_tag1;
      if(L2_trigger_sync = '1') then
        tag_out	<= buf_tag2;
      end if;
    end if;
  end process u_reg_tag;

  -- sync L1 -----------------------------------------------------------------
  u_Sync_L1      : entity mylib.synchronizer port map(clk=>clk, dIn=>L1_trigger, dOut=>L1_trigger_sync);
  u_OneShot_L1   : entity mylib.EdgeDetector port map(rst=>'0', clk=>clk, dIn=>L1_trigger_sync, dOut=>L1_one_shot);

  -- sync L2 -----------------------------------------------------------------
  u_Sync_L2      : entity mylib.synchronizer port map(clk=>clk, dIn=>L2_trigger, dOut=>L2_trigger_sync);
  u_OneShot_L2   : entity mylib.EdgeDetector port map(rst=>'0', clk=>clk, dIn=>L2_trigger_sync, dOut=>L2_one_shot);

  -- sync clear --------------------------------------------------------------
  u_Sync_Clear   : entity mylib.synchronizer port map(clk=>clk, dIn=>fast_clear, dOut=>fast_clear_sync);
  u_OneShot_Clear: entity mylib.EdgeDetector port map(rst=>'0', clk=>clk, dIn=>fast_clear_sync, dOut=>fast_clear_one_shot);

  -- L2 hit detect -----------------------------------------------------------
  current_level2  <= L2_trigger_sync OR fast_clear_sync;
  level2_detect   <= (prev_level2 XOR current_level2) AND current_level2;

  u_detect_level2 : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
--      l2_detect_sync   <= '0';
    elsif(clk'event AND clk = '1') then
      prev_level2      <= current_level2;
--      l2_detect_sync  <= l2_detect;
    end if;
  end process;

  u_delay_level2 : process(clk, sync_reset)
  begin
    if(sync_reset = '1') then
      level2_detect_delay   <= (others => '0');
      level2_delay          <= (others => '0');
      clear_delay           <= (others => '0');
    elsif(clk'event and clk = '1') then
      level2_detect_delay   <= level2_detect_delay(kNumL2Delay-2 downto 0) & level2_detect;
      level2_delay          <= level2_delay(kNumL2Delay-2 downto 0) & L2_trigger_sync;
      clear_delay           <= clear_delay(kNumL2Delay-2 downto 0) & fast_clear_sync;
    end if;
  end process;


  -- Trigger record buffer ---------------------------------------------------
  din_trig_record     <= tag_out & clear_delay(kNumL2Delay-1) & level2_delay(kNumL2Delay-1);
  dOutTRM.regLevel2   <= dout_trig_record(kIndexLevel2);
--  dOutTRM.regClear        <= fifo_out_l2(kIndexClear);
  dOutTRM.regTag      <= dout_trig_record(5 downto 2);
  dOutTRM.trigReady   <= data_ready;
  fifo_busy           <= full_fifo OR afull_fifo OR pgfull_fifo;

  u_reg_dready : process(sync_reset, clk)
  begin
    if(sync_reset = '1') then
      data_ready  <= '0';
    elsif(clk'event AND clk = '1') then
      data_ready  <= NOT empty_trig_record;
    end if;
  end process;

  u_TrigRecordBuf : trigger_record_fifo port map(
    clk         => clk,
    rst         => sync_reset,
    din         => din_trig_record,
    wr_en       => level2_detect_delay(kNumL2Delay-1),
    rd_en       => dInTRM.reFifo,
    dout        => dout_trig_record,
    full        => full_fifo,
    almost_full => afull_fifo,
    empty       => empty_trig_record,
    valid       => dOutTRM.rvFifo,
    prog_full   => pgfull_fifo
    );

  -- Self busy ---------------------------------------------------------------
  u_SelfBusyProcess : process( clk, sync_reset)
  begin
    if(sync_reset = '1') then
      self_busy	<= '0';
      count_busy	<= "1111";
      state_busy	<= Init;
    elsif(clk'event and clk = '1') then
      case state_busy is
        when Init =>
          self_busy	<= '0';
          count_busy	<= "1111";
          if(L1_one_shot = '1') then
            self_busy	<= '1';
            state_busy	<= DelayCount;
          end if;

        when DelayCount =>
          count_busy	<= std_logic_vector(unsigned(count_busy)-1);
          if(count_busy = "0000") then
            self_busy	<= '0';
            state_busy	<= Init;
          end if;

        when others =>
          state_busy	<= Init;
      end case;
    end if;
  end process u_SelfBusyProcess;

  -- Bus process -------------------------------------------------------------
  u_BusProcess : process ( clk, sync_reset )
  begin
    if( sync_reset = '1' ) then
      dataLocalBusOut    <= x"00";
      readyLocalBus      <= '0';
      reg_sel_trig       <= (others => '0');
      state_lbus         <= Init;
    elsif( clk'event and clk='1' ) then
      case state_lbus is
        when Init =>
          state_lbus 		   <= Idle;

        when Idle =>
          readyLocalBus <= '0';
          if ( weLocalBus = '1' ) then
            state_lbus <= Write;
          elsif ( reLocalBus = '1' ) then
            state_lbus <= Read;
          end if;

        when Write =>
          case addrLocalBus(kNonMultiByte'range) is
            when kSelectTrigger(kNonMultiByte'range) =>
              if( addrLocalBus(kMultiByte'range) = k1stbyte) then
                reg_sel_trig(7 downto 0)	  <= dataLocalBusIn;
              else
                reg_sel_trig(kWidthSelTrig-1 downto 8)	  <= dataLocalBusIn(kWidthSelTrig-8-1 downto 0);
              end if;
            when others => null;
          end case;
          state_lbus <= Done;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kSelectTrigger(kNonMultiByte'range) =>
              if( addrLocalBus(kMultiByte'range) = k1stbyte) then
                dataLocalBusOut   <= reg_sel_trig(7 downto 0);
              else
                dataLocalBusOut   <= "0000" & reg_sel_trig(kWidthSelTrig-1 downto 8);
              end if;
            when others =>
              dataLocalBusOut	<= X"ff";
          end case;
          state_lbus <= Done;

        when Done =>
          readyLocalBus <= '1';
          if ( weLocalBus='0' and reLocalBus='0' ) then
            state_lbus <= Idle;
          end if;

        when others =>
          state_lbus	<= Init;
      end case;
    end if;
  end process u_BusProcess;

  -- Reset sequence --
  u_reset_gen : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;

