library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all; -- to use or_reduce()

library UNISIM;
use UNISIM.VComponents.all;

library mylib;
use mylib.defRayrawAdcROV1.all;
use mylib.defYaenamiAdc.all;
use mylib.defAdcBlock.all;
use mylib.defEVB.all;
use mylib.defBCT.all;

entity AdcBlock is
  generic(
    initCh      : integer := 0;
    magicWord   : std_logic_vector(3 downto 0) := X"a"  -- for ADC I'll use X"aa" (10101010) considering humming distance (ff, cc)
    );
  port(
    rst          : in std_logic;
    clkSys       : in std_logic; -- 100 MHz
    clkIdelayRef : in std_logic;
    clkAdc       : out std_logic_vector(kNumAsicBlock-1 downto 0);

    -- control registers --
    busyAdc     : out std_logic;

    -- data input --
    ADC_DATA_P   : in std_logic_vector(kNumAdcInputBlock-1 downto 0);
    ADC_DATA_N   : in std_logic_vector(kNumAdcInputBlock-1 downto 0);
    ADC_DFRAME_P : in std_logic_vector(kNumAsicBlock-1 downto 0);
    ADC_DFRAME_N : in std_logic_vector(kNumAsicBlock-1 downto 0);
    ADC_DCLK_P   : in std_logic_vector(kNumAsicBlock-1 downto 0);
    ADC_DCLK_N   : in std_logic_vector(kNumAsicBlock-1 downto 0);
    cStop        : in std_logic;

    -- Builder bus --
    addrBuilderBus      : in  BBusAddressType;
    dataBuilderBusOut   : out BBusDataType;
    reBuilderBus        : in  std_logic;
    rvBuilderBus        : out std_logic;
    dReadyBuilderBus    : out std_logic;
    bindBuilderBus      : in  std_logic;
    isBoundToBuilder    : out std_logic;

    -- Local bus --
    addrLocalBus        : in LocalAddressType;
    dataLocalBusIn      : in LocalBusInType;
    dataLocalBusOut     : out LocalBusOutType;
    reLocalBus          : in std_logic;
    weLocalBus          : in std_logic;
    readyLocalBus       : out std_logic

    );
end AdcBlock;

architecture RTL of AdcBlock is
  --attribute mark_debug    : string;
  --attribute keep          : string;

  -- internal signals -------------------------------------------------------
  signal busy_adc     : std_logic;

  -- builder bus control --
  signal state_bbus                           : BBusSlaveType;

  -- builder bus rename --
  signal addr_bbus                            : BBusAddressType;
  signal dout_bbus                            : BBusDataType;
  signal re_bbus, rv_bbus                     : std_logic;
  signal bind_bbus, is_bound_to_builder       : std_logic;

  -- Local bus controll -----------------------------------------------------
  signal state_lbus	      : BusProcessType;
  signal reg_adc          : regAdc;
  signal reg_adc_ro_reset : std_logic;

  -- ADC ----------------------------------------------------------------------------------
  signal adc_ro_reset       : std_logic;
  signal adc_ro_reset_vio   : std_logic_vector(0 downto 0);
  signal tap_value_in       : std_logic_vector(kNumTapBit-1 downto 0);
  signal tap_value_frame_in     : std_logic_vector(kNumTapBit-1 downto 0);
  signal en_ext_tapin       : std_logic_vector(0 downto 0);
  signal adcro_is_ready     : std_logic_vector(kNumAsicBlock-1 downto 0);
  -- signal clk_adc          : std_logic_vector(kNumASIC-1 downto 0);
  -- signal gclk_adc         : std_logic_vector(kNumASIC-1 downto 0);
  signal adc_data           : AdcDataBlockArray; -- 32 * 10

  COMPONENT vio_adc
  PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    probe_out1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_out2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    probe_out3 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
  END COMPONENT;

  -- Ring Buffer -----------------------------------------------
  signal rb_in        : std_logic_vector(kNumAdcBit*kNumAdcInputBlock-1 downto 0); -- TODO: kNumAdcBit->10bit(kNumAdcBit)
  signal we_ringbuf   : std_logic_vector(0 downto 0);  -- defined by cstop
  signal write_ptr    : std_logic_vector(kWidthCoarseCount-1 downto 0);

  signal re_ringbuf       : std_logic;
  signal rv_ringbuf       : std_logic;

  signal read_ptr     : std_logic_vector(kWidthCoarseCount-1 downto 0);
  signal rb_out       : std_logic_vector(kNumAdcBit*kNumAdcInputBlock-1 downto 0); -- 32*10

  COMPONENT ringbuffer_adc  -- TODO: create IP name
    PORT (
      clka    : IN STD_LOGIC;
      wea     : IN STD_LOGIC_VECTOR(0 DOWNTO 0); -- write enable, always "1"
      addra   : IN STD_LOGIC_VECTOR(kWidthCoarseCount-1 DOWNTO 0);
      dina    : IN STD_LOGIC_VECTOR(kNumAdcBit*kNumAdcInputBlock-1 downto 0); -- 32*10
      clkb    : IN STD_LOGIC;
      rstb    : IN STD_LOGIC;
      enb     : IN STD_LOGIC; -- read enable
      addrb   : IN STD_LOGIC_VECTOR(kWidthCoarseCount-1 DOWNTO 0);
      doutb   : OUT STD_LOGIC_VECTOR(kNumAdcBit*kNumAdcInputBlock-1 downto 0) -- 32*10
      );
  END COMPONENT;

  -- channel buffer ----------------------------------------------
  signal we_chfifo              : std_logic_vector(kNumAdcInputBlock -1 downto 0);
  signal bufwe_ring2chfifo      : std_logic_vector(kNumAdcInputBlock -1 downto 0);
  signal re_chfifo              : std_logic_vector(kNumAdcInputBlock -1 downto 0);
  signal rv_raw_chfifo          : std_logic_vector(kNumAdcInputBlock -1 downto 0);

  -- fifo control --
  signal bufd_ring2chfifo       : chAdcDataArray;
  signal din_chfifo             : chAdcDataArray;
  signal dout_chfifo            : chAdcDataArray;

  signal full_fifo      : std_logic_vector(kNumAdcInputBlock -1 downto 0);
  signal pgfull_fifo    : std_logic_vector(kNumAdcInputBlock -1 downto 0);
  signal full_flag, pgfull_flag    : std_logic;

  signal empty_fifo     : std_logic_vector(kNumAdcInputBlock -1 downto 0);
  signal empty_flag     : std_logic;
  signal dready_fifo    : std_logic;

  signal dcount_chfifo  : chAdcDcountArray;
  signal last_ch_count  : chAdcDcountArray;
  signal nospace_flag   : std_logic_vector(kNumAdcInputBlock-1 downto 0);
  signal busy_fifo      : std_logic;

  COMPONENT channel_buffer_adc
    PORT (
      clk         : IN STD_LOGIC;
      rst         : IN STD_LOGIC;
      din         : IN STD_LOGIC_VECTOR(kWidthAdcChData-1 DOWNTO 0);
      wr_en       : IN STD_LOGIC;
      rd_en       : IN STD_LOGIC;
      dout        : OUT STD_LOGIC_VECTOR(kWidthAdcChData-1 DOWNTO 0);
      full        : OUT STD_LOGIC;
      empty       : OUT STD_LOGIC;
      valid       : OUT STD_LOGIC;
      data_count  : OUT STD_LOGIC_VECTOR(kWidthAdcChDataCount-1 DOWNTO 0);
      prog_full   : OUT STD_LOGIC
      );
  END COMPONENT;

  -- Trigger search sequence --------------------------------------------
  signal state_search           : HitSearchProcessType; -- NOTE: this should be TriggerSearchProcess

  signal cstop_issued           : std_logic;
  signal coarse_counter         : std_logic_vector(kWidthCoarseCount-1 downto 0);
  signal busy_process           : std_logic;
  signal data_bit               : std_logic;

  signal lastword_count         : std_logic_vector(kWidthLastCount-1 downto 0);
  signal finalize_count         : std_logic;
  signal we_endevent            : std_logic;

  -- Partial event build sequence ----------------------------------------------------
  signal state_build  : BuildProcessType;

  signal read_valid   : std_logic_vector(kNumAdcInputBlock -1 downto 0);
  signal n_of_word    : std_logic_vector(kWidthAdcNWord-1 downto 0);
  signal local_index  : std_logic_vector(kWidthAdcChIndex-1 downto 0);

  signal adc_ch       : std_logic_vector(kWidthAdcChannel-1 downto 0); -- 5 bit
  signal offset_ch    : std_logic_vector(adc_ch'range);

  -- Block FIFO -------------------------------------------------------------
  signal din_block_buffer       : std_logic_vector(kWidthDaqWord-1 downto 0);
  signal din_block_buffer_buf   : std_logic_vector(kWidthDaqWord-1 downto 0);
  signal dout_block_buffer      : std_logic_vector(kWidthDaqWord-1 downto 0);
  signal we_ok_to_blbuffer      : std_logic;
  signal we_block_buffer        : std_logic;
  signal we_block_buffer_buf    : std_logic;
  signal re_block_buffer        : std_logic;
  signal rv_block_buffer        : std_logic;
  signal pgfull_block_buffer    : std_logic;
  signal empty_bbuffer            : std_logic;

  COMPONENT block_buffer_adc
    PORT (
      clk         : IN STD_LOGIC;
      rst         : IN STD_LOGIC;
      din         : IN STD_LOGIC_VECTOR(kWidthDaqWord-1 DOWNTO 0);
      wr_en       : IN STD_LOGIC;
      rd_en       : IN STD_LOGIC;
      dout        : OUT STD_LOGIC_VECTOR(kWidthDaqWord-1 DOWNTO 0);
      full        : OUT STD_LOGIC;
      empty       : OUT STD_LOGIC;
      valid       : OUT STD_LOGIC;
      prog_full   : OUT STD_LOGIC
      );
  END COMPONENT;

  -- Event Summary FIFO ------------------------------------------------------
  signal din_evsum    : std_logic_vector(kWidthEvtSummary-1 downto 0); -- overflow(18) : n_word(17-0)
  signal dout_evsum   : std_logic_vector(kWidthEvtSummary-1 downto 0); -- overflow(18) : n_word(17-0)
  signal we_evsum     : std_logic;
  signal re_evsum     : std_logic;
  signal full_block, afull_block  : std_logic;
  signal block_busy   : std_logic;
  signal rv_evsum     : std_logic;
  signal empty_block  : std_logic;
  signal data_ready   : std_logic;

  COMPONENT evsummary_fifo
    PORT (
      clk         : IN STD_LOGIC;
      rst         : IN STD_LOGIC;
      din         : IN STD_LOGIC_VECTOR(kWidthEvtSummary-1 DOWNTO 0);
      wr_en       : IN STD_LOGIC;
      rd_en       : IN STD_LOGIC;
      dout        : OUT STD_LOGIC_VECTOR(kWidthEvtSummary-1 DOWNTO 0);
      full        : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty       : OUT STD_LOGIC;
      valid       : OUT STD_LOGIC
      );
  END COMPONENT;

  -- debug ------------------------------------------------------------------
   --attribute mark_debug of full_flag     : signal is "true";
   ---attribute mark_debug of pgfull_flag   : signal is "true";
   --attribute mark_debug of busy_fifo     : signal is "true";
   --attribute mark_debug of full_block    : signal is "true";
   --attribute mark_debug of afull_block   : signal is "true";
   --attribute mark_debug of busy_process  : signal is "true";
   --attribute mark_debug of busyAdc       : signal is "true";
   --attribute mark_debug of we_ringbuf    : signal is "true";
   --attribute mark_debug of re_ringbuf    : signal is "true";
   --attribute mark_debug of rv_ringbuf    : signal is "true";
   --attribute mark_debug of we_chfifo    : signal is "true";
   --attribute mark_debug of bufwe_ring2chfifo    : signal is "true";
   --attribute mark_debug of re_chfifo    : signal is "true";
   --attribute mark_debug of rv_raw_chfifo    : signal is "true";
   --attribute mark_debug of n_of_word    : signal is "true";
   --attribute mark_debug of coarse_counter    : signal is "true";
   --attribute mark_debug of cstop_issued : signal is "true";
   --attribute mark_debug of pgfull_fifo : signal is "true";
   --attribute mark_debug of data_bit    : signal is "true";
   --attribute mark_debug of state_search    : signal is "true";
   --attribute mark_debug of state_build    : signal is "true";
   --attribute mark_debug of state_bbus    : signal is "true";
   --attribute mark_debug of empty_fifo    : signal is "true"; --chfifo
   --attribute mark_debug of empty_bbuffer    : signal is "true"; --block buffer
   --attribute mark_debug of empty_block    : signal is "true"; --evsum
   --attribute mark_debug of local_index    : signal is "true"; --evsum

begin
  -- ========================================================================
  -- body
  -- ========================================================================
  offset_ch   <= std_logic_vector(to_unsigned(initCh, 5)); -- TODO: redefine kWidthAdcChannel for ADC

  -- signal connection ------------------------------------------------------
  busyAdc         <= busy_adc;
  busy_adc        <= full_flag OR pgfull_flag OR busy_fifo OR full_block OR afull_block OR busy_process;

  -- builder bus --
  -- At present, just rename
  addr_bbus       <= addrBuilderBus;
  re_bbus         <= reBuilderBus;
  bind_bbus       <= bindBuilderBus;

  dataBuilderBusOut   <= dout_bbus;
  rvBuilderBus        <= rv_bbus;
  dReadyBuilderBus    <= data_ready;
  isBoundToBuilder    <= is_bound_to_builder;

  u_reg_dready : process(rst, clkSys)
  begin
     if(rst = '1') then
       data_ready  <= '0';
     elsif(clkSys'event AND clkSys = '1') then
       data_ready  <= NOT empty_block;
     end if;
   end process;

  u_buf_local : process(rst, clkSys)
  begin
    if(rst = '1') then
      cstop_issued    <= '0';
    elsif(clkSys'event AND clkSys = '1') then
      cstop_issued    <= cStop;
    end if;
  end process;

  u_VIO : vio_adc
    PORT MAP (
      clk => clkSys,
      probe_out0 => adc_ro_reset_vio,
      probe_out1 => tap_value_in,
      probe_out2 => tap_value_frame_in,
      probe_out3 => en_ext_tapin
    );

  adc_ro_reset  <= reg_adc_ro_reset or adc_ro_reset_vio(0);
  u_ADC : entity mylib.RawrayAdcRO
    generic map
    (
      enDEBUG       => TRUE
    )
    port map
    (
      -- SYSTEM port --
      rst           => adc_ro_reset,
      clkSys        => clkSys,
      clkIdelayRef  => clkIdelayRef,
      tapValueIn    => tap_value_in,
      tapValueFrameIn    => tap_value_frame_in,
      enExtTapIn    => en_ext_tapin(0),
      enBitslip     => '1',
      frameRefPatt  => "1100000000",

      -- Status --
      isReady       => adcro_is_ready,
      bitslipErr    => open,
      clkAdc        => open, -- clk_adc (later gclk_adc)

      -- Data Out --
      validOut      => open,
      adcDataOut    => adc_data,
      adcFrameOut   => open,

      -- ADC In --
      adcDClkP      => ADC_DCLK_P,
      adcDClkN      => ADC_DCLK_N,
      adcDataP      => ADC_DATA_P,
      adcDataN      => ADC_DATA_N,
      adcFrameP     => ADC_DFRAME_P,
      adcFrameN     => ADC_DFRAME_N

    );

  -- For debug --
  -- BUFG_inst : BUFG
  -- port map (
  --     O => gclk_adc,
  --     I => clk_adc
  -- );


  gen_vectorizeAdcData : for i in 0 to kNumAdcInputBlock-1 generate   -- 32
      -- zero suppression before this
      rb_in(kNumAdcBit*(i+1)-1 downto kNumAdcBit*i) <= adc_data(i); -- TODO: 320bit
  end generate;

  -- Ring Buffer
  -- instance of ring buffer --
  u_RingBuffer : ringbuffer_adc
    port map (
      clka    => clkSys,
      wea     => we_ringbuf, -- TODO
      addra   => write_ptr, -- TODO
      dina    => rb_in,  -- TODO: define
      clkb    => clkSys,
      rstb    => rst,
      enb     => re_ringbuf, -- TODO
      addrb   => read_ptr, -- TODO
      doutb   => rb_out  -- TODO
      );

  -- from ringbuffer to chfifo -----------------------------
  u_buf_ring2chfifo : process(clkSys, rst)
  begin
    if(rst = '1') then
      for i in 0 to kNumAdcInputBlock-1 loop
        bufd_ring2chfifo(i)   <= (others => '0');
        bufwe_ring2chfifo(i)  <= '0';
      end loop;
    elsif(clkSys'event AND clkSys = '1') then
      for i in 0 to kNumAdcInputBlock-1 loop
        bufd_ring2chfifo(i)   <= data_bit & coarse_counter & rb_out(kNumAdcBit*(i+1)-1 downto kNumAdcBit*i);
        bufwe_ring2chfifo(i)  <= (rv_ringbuf AND (NOT pgfull_fifo(i))) OR we_endevent;
      end loop;
    end if;
  end process u_buf_ring2chfifo;

  -- Issue busy from search process -------------------------------------------
  empty_flag  <= '0' when(unsigned(empty_fifo) = 0) else '1';
  dready_fifo <= NOT empty_flag;

  full_flag   <= '0' when(unsigned(full_fifo)   = 0) else '1';
  pgfull_flag <= '0' when(unsigned(pgfull_fifo) = 0) else '1';

  busy_fifo   <= '0' when(unsigned(nospace_flag) = 0) else '1';

  u_dcount : process(rst, clkSys)
  begin
    if(rst = '1') then
      for i in 0 to kNumAdcInputBlock-1 loop
        last_ch_count(i)   <= (others => '0');
        nospace_flag(i) <= '0';
      end loop;
    elsif(clkSys'event AND clkSys = '1') then
      for i in 0 to kNumAdcInputBlock-1 loop
        last_ch_count(i)    <= std_logic_vector(kMaxAdcChDepth - unsigned(dcount_chfifo(i)));
        --if(unsigned(last_ch_count(i)) <= to_unsigned(kMaxChThreshold, kWidthChDataCount)) then
        if(unsigned(last_ch_count(i)) <= kMaxAdcChThreshold) then
          nospace_flag(i) <= '1';
        else
          nospace_flag(i) <= '0';
        end if;
      end loop;
    end if;
  end process u_dcount;

  -- Instance of Ch FIFO ----------------------------------------------------
  gen_chfifo : for i in 0 to kNumAdcInputBlock-1 generate
    din_chfifo(i)   <= bufd_ring2chfifo(i);
    we_chfifo(i)    <= bufwe_ring2chfifo(i);
    read_valid(i)   <= dout_chfifo(i)(kIndexAdcDataBit) AND rv_raw_chfifo(i);

    u_chfifo : channel_buffer_adc
      port map(
        clk     => clkSys,
        rst     => rst,
        din     => din_chfifo(i),
        wr_en   => we_chfifo(i),
        rd_en   => re_chfifo(i),
        dout    => dout_chfifo(i),
        full    => full_fifo(i),
        empty   => empty_fifo(i),
        valid   => rv_raw_chfifo(i),
        data_count  => dcount_chfifo(i),
        prog_full => pgfull_fifo(i)
        );
  end generate;

  -- Instance of Block Buffer -----------------------------------------------
  u_block_fifo : block_buffer_adc
    port map (
      clk         => clkSys,
      rst         => rst,
      din         => din_block_buffer,
      wr_en       => we_block_buffer,
      rd_en       => re_block_buffer,
      dout        => dout_block_buffer,
      full        => open,
      empty       => empty_bbuffer,
      valid       => rv_block_buffer,
      prog_full   => pgfull_block_buffer
      );

  -- Instance of Event Summary ----------------------------------------------
    din_evsum   <= '0' & std_logic_vector(to_unsigned(0, kWidthEventSize-kWidthAdcNWord)) & n_of_word; -- '0': no overflow for ADC

  u_evsum : evsummary_fifo
    port map (
      clk         => clkSys,
      rst         => rst,
      din         => din_evsum,
      wr_en       => we_evsum,
      rd_en       => re_evsum,
      dout        => dout_evsum,
      full        => full_block,
      almost_full => afull_block,
      empty       => empty_block,
      valid       => rv_evsum
      );


  -- Write data from Rinb fuffer to channel buffer --------------------------
  u_write_ptr : process(rst, clkSys)
  begin
    if(rst = '1') then
      write_ptr   <= (others => '0');
    elsif(clkSys'event AND clkSys = '1') then
      write_ptr   <= std_logic_vector(unsigned(write_ptr) +1);
    end if;
  end process;

  u_SearchProcess : process(rst, clkSys)
  begin
    if(rst = '1') then
      we_ringbuf        <= "0";
      busy_process      <= '0';
      --write_ptr       <= (others => '0');
      read_ptr          <= (others => '0');
      re_ringbuf        <= '0';
      rv_ringbuf        <= '0';

      data_bit          <= '0';
      lastword_count    <= (others => '0');
      finalize_count    <= '0';
      state_search         <= Init;
    elsif(clkSys'event AND clkSys = '1') then
      case state_search is
        when Init =>
          busy_process    <= '0';
          we_ringbuf      <= "0";
          --write_ptr       <= (others => '0');
          read_ptr        <= (others => '0');
          re_ringbuf      <= '0';
          rv_ringbuf      <= '0';

          data_bit        <= isSeparator;
          lastword_count  <= (others => '0');
          finalize_count  <= '0';
          state_search    <= WaitCommonStop;

        when WaitCommonStop =>
          busy_process    <= '0';
          we_ringbuf      <= "1";
          if(cstop_issued = '1') then
            busy_process    <= '1';

            re_ringbuf      <= '1';
            data_bit        <= isData;
            read_ptr        <= std_logic_vector(unsigned(write_ptr) + unsigned(reg_adc.offset_ptr));

            coarse_counter  <= reg_adc.window_max;
            state_search    <= ReadRingBuffer;
          end if;

        when ReadRingBuffer =>
          read_ptr              <= std_logic_vector(unsigned(read_ptr) +1);
          coarse_counter        <= std_logic_vector(unsigned(coarse_counter) -1);
          if(coarse_counter = reg_adc.window_min) then
            re_ringbuf          <= '0';
            rv_ringbuf          <= '0';
            data_bit            <= isSeparator;
            lastword_count      <= "111";
            state_search        <= LastWord;
          else
            rv_ringbuf         <= '1';
          end if;

        when LastWord =>
          read_ptr              <= std_logic_vector(unsigned(read_ptr) +1);
          lastword_count        <= std_logic_vector(unsigned(lastword_count) -1);
          if(lastword_count = "000") then
            we_endevent         <= '1';
            finalize_count      <= '1';
            state_search        <= Finalize;
          end if;

        when Finalize =>
          read_ptr      <= read_ptr;
          if(finalize_count = '1') then
            finalize_count  <= '0';
          else
            we_endevent     <= '0';
            state_search    <= Done;
          end if;

        when Done =>
          busy_process    <= '0';
          state_search    <= WaitCommonStop;

        when others =>
          state_search    <= Init;

      end case;
    end if;
  end process u_SearchProcess;


  -- Build one event in this block ------------------------------------------
  u_BuildProcess : process(rst, clkSys)
    variable id : integer;
  begin
    if(rst = '1') then
      local_index       <= (others => '0');
      re_chfifo         <= (others => '0');
      n_of_word         <= (others => '0');
      we_evsum          <= '0';
      we_ok_to_blbuffer <= '1';
      adc_ch            <= std_logic_vector(unsigned(offset_ch) + kNumAdcInputBlock-1);
      state_build       <= Init;
    elsif(clkSys'event AND clkSys = '1') then
      id      := to_integer(unsigned(local_index));

      din_block_buffer_buf  <= magicWord & adc_ch & "00" & dout_chfifo(id)(kIndexAdcDataBit-1 downto 0);
      din_block_buffer      <= din_block_buffer_buf;
      we_block_buffer_buf   <= we_ok_to_blbuffer AND read_valid(id);
      we_block_buffer       <= we_block_buffer_buf;

      case state_build is
        when Init =>
          local_index   <= (others => '0');
          re_chfifo     <= (others => '0');
          n_of_word     <= (others => '0');
          we_evsum      <= '0';
          we_ok_to_blbuffer     <= '1';
          adc_ch        <= std_logic_vector(unsigned(offset_ch) + kNumAdcInputBlock-1);
          state_build   <= WaitDready;

        when WaitDready =>
          if(dready_fifo = '1' and pgfull_block_buffer = '0') then
            we_ok_to_blbuffer <= '1';
            adc_ch        <= std_logic_vector(unsigned(offset_ch) + kNumAdcInputBlock-1);
            local_index   <= std_logic_vector(to_unsigned(kNumAdcInputBlock-1, kWidthAdcChIndex));
            state_build   <= DreadyInterval;
          end if;

        when DreadyInterval =>
          state_build     <= StartPosition;

        when StartPosition =>
          re_chfifo(id)   <= '1';
          state_build     <= ReadInterval;

        when ReadInterval =>
          state_build     <= ReadOneChannel;

        when ReadOneChannel =>
          if(rv_raw_chfifo(id) = '1') then
            if(dout_chfifo(id)(kIndexAdcDataBit) = isSeparator) then
              re_chfifo(id)   <= '0';
              local_index     <= std_logic_vector(unsigned(local_index) -1);
              state_build     <= EndOneChannel;

            else
              n_of_word       <= std_logic_vector(unsigned(n_of_word) +1);
            end if;
          end if;

        when EndOneChannel =>
          we_ok_to_blbuffer <= '1';
          adc_ch            <= std_logic_vector(unsigned(local_index) + unsigned(offset_ch));
          if(unsigned(local_index) = kNumAdcInputBlock-1) then
            state_build <= Finalize;
          else
            if(pgfull_block_buffer = '0') then
              state_build <= StartPosition;
            end if;
          end if;

        when Finalize =>
          we_evsum      <= '1';
          state_build   <= Done;

        when Done =>
          n_of_word     <= (others => '0');
          we_evsum      <= '0';
          state_build   <= WaitDready;

        when others =>
          state_build <= Init;

      end case;
    end if;
  end process u_BuildProcess;

  -- Builder bus process --
  u_BuilderBusProcess : process(rst, clkSys)
  begin
    if(rst = '1') then
      dout_bbus           <= (others => '0');
      rv_bbus             <= '0';
      is_bound_to_builder <= '0';

      re_block_buffer     <= '0';
      state_bbus          <= Init;
    elsif(clkSys'event and clkSys = '1') then
      case state_bbus is
        when Init =>
          dout_bbus           <= (others => '0');
          rv_bbus             <= '0';
          is_bound_to_builder <= '0';

          re_evsum            <= '0';
          re_block_buffer     <= '0';
          state_bbus          <= Idle;

        when Idle =>
          re_evsum         <= '0';
          re_block_buffer  <= '0';
          if(bind_bbus = '1') then
            state_bbus <= BoundBus;
          end if;

        when BoundBus =>
          case addr_bbus is
            when kEventSummary =>
              re_evsum        <= re_bbus;
              re_block_buffer <= '0';
              dout_bbus       <= std_logic_vector(to_unsigned(0, kWidthBBusData-kWidthEvtSummary)) & dout_evsum;
              rv_bbus         <= rv_evsum;
            when kDataBuffer =>
              re_evsum        <= '0';
              re_block_buffer <= re_bbus;
              dout_bbus       <= dout_block_buffer;
              rv_bbus         <= rv_block_buffer;
            when others =>
              null;
          end case;

          is_bound_to_builder  <= '1';
          if(bind_bbus = '0') then
            state_bbus  <= CloseBus;
          end if;

        when CloseBus =>
          re_evsum            <= '0';
          re_block_buffer     <= '0';
          rv_bbus             <= '0';
          is_bound_to_builder <= '0';
          state_bbus          <= Idle;

        when others =>
          state_bbus  <= Init;
      end case;
    end if;
  end process;

  -- Local bus process -----------------------------------------------------
  u_BusProcess : process(clkSys, rst)
  begin
    if(rst = '1') then
      dataLocalBusOut     <= x"00";
      readyLocalBus       <= '0';
      reg_adc.offset_ptr  <= (others => '0');
      reg_adc.window_max  <= (others => '0');
      reg_adc.window_min  <= (others => '0');
      reg_adc_ro_reset    <= '1';
      state_lbus    <= Init;
    elsif(clkSys'event and clkSys = '1') then
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
            when kOfsPtr(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                reg_adc.offset_ptr(7 downto 0)  <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                reg_adc.offset_ptr(kWidthCoarseCount-1 downto 8)  <= dataLocalBusIn(kWidthCoarseCount-1-8 downto 0);
              else
              end if;

            when kWinMax(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                reg_adc.window_max(7 downto 0)  <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                reg_adc.window_max(kWidthCoarseCount-1 downto 8)  <= dataLocalBusIn(kWidthCoarseCount-1-8 downto 0);
              else
              end if;

            when kWinMin(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                reg_adc.window_min(7 downto 0)  <= dataLocalBusIn;
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                reg_adc.window_min(kWidthCoarseCount-1 downto 8)  <= dataLocalBusIn(kWidthCoarseCount-1-8 downto 0);
              else
              end if;

            when kAdcRoReset(kNonMultiByte'range) =>
              reg_adc_ro_reset  <= dataLocalBusIn(0);

            when others => null;
          end case;
          state_lbus    <= Done;

        when Read =>
          case addrLocalBus(kNonMultiByte'range) is
            when kOfsPtr(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                dataLocalBusOut <= reg_adc.offset_ptr(7 downto 0);
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                dataLocalBusOut <= "00000" & reg_adc.offset_ptr(kWidthCoarseCount-1 downto 8);
              else
              end if;

            when kWinMax(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                dataLocalBusOut <= reg_adc.window_max(7 downto 0);
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                dataLocalBusOut <= "00000" & reg_adc.window_max(kWidthCoarseCount-1 downto 8);
              else
              end if;

            when kWinMin(kNonMultiByte'range) =>
              if(addrLocalBus(kMultiByte'range) = k1stbyte) then
                dataLocalBusOut <= reg_adc.window_min(7 downto 0);
              elsif(addrLocalBus(kMultiByte'range) = k2ndbyte) then
                dataLocalBusOut <= "00000" & reg_adc.window_min(kWidthCoarseCount-1 downto 8);
              else
              end if;

            when kAdcRoReset(kNonMultiByte'range) =>
              dataLocalBusOut <= "0000000" & reg_adc_ro_reset;

            when kIsReady(kNonMultiByte'range) =>
              dataLocalBusOut <= "0000" & adcro_is_ready;

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

end RTL;
