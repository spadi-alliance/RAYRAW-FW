library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

library mylib;
use mylib.defTdcBlock.all;
use mylib.defCommonStopBlock.all;
use mylib.defEVB.all;

entity TdcBlock is
  generic(
    initCh      : integer := 0;
    magicWord   : std_logic_vector(KNumBitMagicWord-1 downto 0) := X"cc"
    );
  port(
    rst         : in std_logic;
    sysClk      : in std_logic; -- 100 MHz
    tdcClk      : in std_logic_vector(kNumTdcClock-1 downto 0); -- 400 MHz

    -- control registers --
    busyTdc     : out std_logic;
    enBlock     : in std_logic;
    regIn       : in regTdc;

    -- data input --
    tdcIn       : in std_logic_vector(kNumInputBlock-1 downto 0);
    dInStop     : in std_logic_vector(kWidthStopData-1 downto 0); -- 4:CStop bit, 3-0: CStop values

    -- Builder bus --
    addrBuilderBus      : in  BBusAddressType;
    dataBuilderBusOut   : out BBusDataType;
    reBuilderBus        : in  std_logic;
    rvBuilderBus        : out std_logic;
    dReadyBuilderBus    : out std_logic;
    bindBuilderBus      : in  std_logic;
    isBoundToBuilder    : out std_logic

    );
end TdcBlock;

architecture RTL of TdcBlock is
  attribute mark_debug    : string;
  attribute keep          : string;

  -- internal signals -------------------------------------------------------
  -- controll registers --------------------------------------
  signal enable_block : std_logic;
  signal reg_local    : regTdc;
  signal busy_tdc     : std_logic;
  --attribute keep of busy_tdc : signal is "true";

  -- builder bus control --
  signal state_bbus                           : BBusSlaveType;

  -- builder bus rename --
  signal addr_bbus                            : BBusAddressType;
  signal dout_bbus                            : BBusDataType;
  signal re_bbus, rv_bbus                     : std_logic;
  signal bind_bbus, is_bound_to_builder       : std_logic;

  -- Input stage ---------------------------------------------
  type firstFdcArray is array (integer range kNumInputBlock-1 downto 0)
    of std_logic_vector(kNumTdcClock-1 downto 0);
  signal dout_first_fdc   : firstFdcArray;

  -- FineCounter ---------------------------------------------
  type fcountArray is array (integer range kNumInputBlock-1 downto 0)
    of std_logic_vector(kNumTdcClock-1 downto 0);
  signal dout_bit_pattern : fcountArray;

  -- FineCounterDecoder ----------------------------------------
  type decoded_fcountArray is array (integer range kNumInputBlock-1 downto 0)
    of std_logic_vector(kWidthFineCount-1 downto 0);
  signal decoded_fcount   : decoded_fcountArray;
  signal hit_found        : std_logic_vector(kNumInputBlock-1 downto 0);

  -- Ring Buffer -----------------------------------------------
  signal rb_in        : std_logic_vector(kWidthRingData*kNumInputBlock-1 downto 0); -- 32*4
  signal we_ringbuf   : std_logic_vector(0 downto 0);
  signal write_ptr    : std_logic_vector(kWidthCoarseCount-1 downto 0);

  signal re_ringbuf                     : std_logic;
  signal rv_ringbuf_pre                 : std_logic;
  signal rv_ringbuf, rv_ringbuf0        : std_logic;

  signal read_ptr     : std_logic_vector(kWidthCoarseCount-1 downto 0);
  signal rb_out       : std_logic_vector(kWidthRingData*kNumInputBlock-1 downto 0); -- 32*4

  COMPONENT ringbuffer_bram_v1
    PORT (
      clka    : IN STD_LOGIC;
      wea     : IN STD_LOGIC_VECTOR(0 DOWNTO 0); -- write enable, always "1"
      addra   : IN STD_LOGIC_VECTOR(kWidthCoarseCount-1 DOWNTO 0);
      dina    : IN STD_LOGIC_VECTOR(kWidthRingData*kNumInputBlock-1 downto 0); -- 32*4
      clkb    : IN STD_LOGIC;
      rstb    : IN STD_LOGIC;
      enb     : IN STD_LOGIC; -- read enable
      addrb   : IN STD_LOGIC_VECTOR(kWidthCoarseCount-1 DOWNTO 0);
      doutb   : OUT STD_LOGIC_VECTOR(kWidthRingData*kNumInputBlock-1 downto 0) -- 32*4
      );
  END COMPONENT;

  -- channel buffer ----------------------------------------------
  signal we_chfifo              : std_logic_vector(kNumInputBlock -1 downto 0);
  signal reg_we_chfifo          : std_logic_vector(kNumInputBlock -1 downto 0);
  signal raw_we_chfifo          : std_logic_vector(kNumInputBlock -1 downto 0);
  signal bufwe_ring2chfifo      : std_logic_vector(kNumInputBlock -1 downto 0);
  signal re_chfifo              : std_logic_vector(kNumInputBlock -1 downto 0);
  signal rv_raw_chfifo          : std_logic_vector(kNumInputBlock -1 downto 0);

  -- fifo control --
  signal bufd_ring2chfifo       : chDataArray;
  signal din_chfifo             : chDataArray;
  signal dout_chfifo            : chDataArray;

  signal full_fifo      : std_logic_vector(kNumInputBlock -1 downto 0);
  signal pgfull_fifo    : std_logic_vector(kNumInputBlock -1 downto 0);
  signal full_flag, pgfull_flag    : std_logic;

  signal empty_fifo     : std_logic_vector(kNumInputBlock -1 downto 0);
  signal empty_flag     : std_logic;
  signal dready_fifo    : std_logic;

  signal dcount_chfifo  : chDcountArray;
  signal last_ch_count  : chDcountArray;
  signal nospace_flag   : std_logic_vector(kNumInputBlock-1 downto 0);
  signal busy_fifo      : std_logic;

  COMPONENT channel_buffer_v2
    PORT (
      clk         : IN STD_LOGIC;
      rst         : IN STD_LOGIC;
      din         : IN STD_LOGIC_VECTOR(kWidthChData-1 DOWNTO 0);
      wr_en       : IN STD_LOGIC;
      rd_en       : IN STD_LOGIC;
      dout        : OUT STD_LOGIC_VECTOR(kWidthChData-1 DOWNTO 0);
      full        : OUT STD_LOGIC;
      empty       : OUT STD_LOGIC;
      valid       : OUT STD_LOGIC;
      data_count  : OUT STD_LOGIC_VECTOR(kWidthChDataCount-1 DOWNTO 0);
      prog_full   : OUT STD_LOGIC
      );
  END COMPONENT;

  -- Hit search sequence --------------------------------------------
  signal state_search           : HitSearchProcessType;

  signal cstop_issued           : std_logic;
  signal cstop_value            : std_logic_vector(kWidthFineCount-1 downto 0);
  signal reg_cstop_value        : std_logic_vector(cstop_value'range);
  signal coarse_counter         : std_logic_vector(kWidthCoarseCount-1 downto 0);
  signal busy_process           : std_logic;
  signal data_bit, reg_data_bit0, reg_data_bit1, reg_data_bit2, reg_data_bit : std_logic;

  signal lastword_count         : std_logic_vector(kWidthLastCount-1 downto 0);
  signal finalize_count         : std_logic;
  signal we_endevent, reg_we_endevent : std_logic;

  signal coarse_tdc   : std_logic_vector(kWidthTdcData-1 downto 0);
  signal raw_tdc_value    : dataTdcArray;
  signal tdc_value        : dataTdcArray;

  -- Partial event build sequence ----------------------------------------------------
  signal state_build  : BuildProcessType;

  signal read_valid   : std_logic_vector(kNumInputBlock -1 downto 0);
  signal n_of_word    : std_logic_vector(kWidthNWord-1 downto 0);
  signal local_nhit   : std_logic_vector(kWidthMultiHit-1 downto 0);
  signal local_index  : std_logic_vector(kWidthChIndex-1 downto 0);

  signal tdc_ch       : std_logic_vector(kWidthChannel-1 downto 0);
  signal offset_ch    : std_logic_vector(tdc_ch'range);

  signal overflow_flag    : std_logic;

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

  COMPONENT block_buffer_v2
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
  signal din_evsum    : std_logic_vector(kWidthEvtSummary-1 downto 0); -- overflow(10) : n_word(9-0)
  signal dout_evsum   : std_logic_vector(kWidthEvtSummary-1 downto 0); -- overflow(10) : n_word(9-0)
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
--   attribute mark_debug of state_daq     : signal is "true";
--   attribute mark_debug of state_trans   : signal is "true";
--   attribute mark_debug of full_flag     : signal is "true";
--   attribute mark_debug of pgfull_flag   : signal is "true";
--   attribute mark_debug of busy_fifo     : signal is "true";
--   attribute mark_debug of full_block    : signal is "true";
--   attribute mark_debug of afull_block   : signal is "true";
--   attribute mark_debug of busy_process  : signal is "true";
--   attribute mark_debug of busyTdc       : signal is "true";
--   attribute mark_debug of cstop_issued  : signal is "true";
--    attribute mark_debug of we_endevent  : signal is "true";
--    attribute mark_debug of dready_fifo  : signal is "true";
--    attribute mark_debug of we_block_buffer  : signal is "true";
--    attribute mark_debug of we_chfifo  : signal is "true";
--    attribute mark_debug of re_chfifo  : signal is "true";
--    attribute mark_debug of dcount_chfifo  : signal is "true";
--  attribute mark_debug of coarse_counter : signal is "true";
--    attribute mark_debug of overflow_flag : signal is "true";
--    attribute mark_debug of n_of_word : signal is "true";
--    attribute mark_debug of din_block_buffer : signal is "true";


begin
  -- ========================================================================
  -- body
  -- ========================================================================
  offset_ch   <= std_logic_vector(to_unsigned(initCh, kWidthChannel));

  -- signal connection ------------------------------------------------------
  --cstop_issued    <= dInStop(kIndexHit);
  --cstop_value     <= dInStop(kIndexHit-1 downto 0);
  busyTdc         <= busy_tdc;
  busy_tdc        <= full_flag OR pgfull_flag OR busy_fifo OR full_block OR afull_block OR busy_process;

  -- builder bus --
  -- At present, just rename
  addr_bbus       <= addrBuilderBus;
  re_bbus         <= reBuilderBus;
  bind_bbus       <= bindBuilderBus;

  dataBuilderBusOut   <= dout_bbus;
  rvBuilderBus        <= rv_bbus;
  dReadyBuilderBus    <= data_ready;
  isBoundToBuilder    <= is_bound_to_builder;

  u_reg_dready : process(rst, sysClk)
  begin
    if(rst = '1') then
      data_ready  <= '0';
    elsif(sysClk'event AND sysClk = '1') then
      data_ready  <= NOT empty_block;
    end if;
  end process;

  u_buf_local : process(rst, sysClk)
  begin
    if(rst = '1') then
      cstop_issued    <= '0';
    elsif(sysClk'event AND sysClk = '1') then
      cstop_issued    <= dInStop(kIndexHit);
      cstop_value     <= dInStop(kIndexHit-1 downto 0);

      enable_block    <= enBlock;
      reg_local       <= regIn;
    end if;
  end process;
  -- signal connection -----------------------------------------------------

  gen_fcounter : for i in 0 to kNumInputBlock-1 generate
    u_FirstFDC  : entity mylib.FirstFDCEs
      port map(
        rst     => '0',
        clk     => tdcClk,
        dataIn  => tdcIn(i),
        dataOut => dout_first_fdc(i)
        );

    u_FCounter : entity mylib.FineCounter
      port map(
        clk0   => tdcClk(0),
        clk90  => tdcClk(1),
        clk180 => tdcClk(2),
        clk270 => tdcClk(3),
        dIn    => dout_first_fdc(i),
        dOut   => dout_bit_pattern(i)
        );

    u_FCDecoder : entity mylib.FineCounterDecoder
      port map(
        tdcClk          => tdcClk(0),
        sysClk          => sysClk,
        dIn             => dout_bit_pattern(i),

        fineCount       => decoded_fcount(i),
        hitFound        => hit_found(i)
        );

    -- Ring buffer input --
    rb_in(kWidthRingData*i +kIndexHit downto kWidthRingData*i)  <=   hit_found(i) & decoded_fcount(i);
  end generate;

  -- instance of ring buffer --
  u_RingBuffer : ringbuffer_bram_v1
    port map (
      clka    => sysClk,
      wea     => we_ringbuf,
      addra   => write_ptr,
      dina    => rb_in,
      clkb    => sysClk,
      rstb    => rst,
      enb     => re_ringbuf,
      addrb   => read_ptr,
      doutb   => rb_out
      );

  -- 1 clock latency from ringbuffer to chfifo -----------------------------
  coarse_tdc <= coarse_counter & std_logic_vector(to_unsigned(0, kWidthFineCount));

  u_buf_ring2chfifo : process(sysClk, rst)
  begin
    if(rst = '1') then
      rv_ringbuf0     <= '0';
      rv_ringbuf      <= '0';
      reg_data_bit0   <= '0';
      reg_data_bit1   <= '0';
      reg_data_bit2   <= '0';
      reg_data_bit    <= '0';
      reg_we_endevent <= '0';

      for i in 0 to kNumInputBlock-1 loop
        bufd_ring2chfifo(i)   <= (others => '0');
        bufwe_ring2chfifo(i)  <= '0';
      end loop;
    elsif(sysClk'event AND sysClk = '1') then
      rv_ringbuf      <= rv_ringbuf_pre;
      reg_data_bit1   <= data_bit;
      reg_data_bit2   <= reg_data_bit1;
      reg_data_bit    <= reg_data_bit2;

      for i in 0 to kNumInputBlock-1 loop
        raw_tdc_value(i)    <= std_logic_vector(unsigned(coarse_tdc) - unsigned(rb_out(kWidthRingData*i +kWidthFineCount-1 downto kWidthRingData*i)));
        raw_we_chfifo(i)    <= (rb_out(kWidthRingData*i +kIndexHit) AND rv_ringbuf AND enable_block AND (NOT pgfull_fifo(i)));

        tdc_value(i)        <= std_logic_vector(unsigned(raw_tdc_value(i)) + unsigned(reg_cstop_value));
        reg_we_chfifo(i)    <= raw_we_chfifo(i) OR we_endevent;

        bufd_ring2chfifo(i)   <= reg_data_bit & tdc_value(i);
        bufwe_ring2chfifo(i)  <= reg_we_chfifo(i);
      end loop;
    end if;
  end process u_buf_ring2chfifo;

  -- Issue busy from search process -------------------------------------------
  empty_flag  <= '0' when(unsigned(empty_fifo) = 0) else '1';
  dready_fifo <= NOT empty_flag;

  full_flag   <= '0' when(unsigned(full_fifo)   = 0) else '1';
  pgfull_flag <= '0' when(unsigned(pgfull_fifo) = 0) else '1';

  busy_fifo   <= '0' when(unsigned(nospace_flag) = 0) else '1';

  u_dcount : process(rst, sysClk)
  begin
    if(rst = '1') then
      for i in 0 to kNumInputBlock-1 loop
        last_ch_count(i)   <= (others => '0');
        nospace_flag(i) <= '0';
      end loop;
    elsif(sysClk'event AND sysClk = '1') then
      for i in 0 to kNumInputBlock-1 loop
        last_ch_count(i)    <= std_logic_vector(kMaxChDepth - unsigned(dcount_chfifo(i)));
        --if(unsigned(last_ch_count(i)) <= to_unsigned(kMaxChThreshold, kWidthChDataCount)) then
        if(unsigned(last_ch_count(i)) <= kMaxChThreshold) then
          nospace_flag(i) <= '1';
        else
          nospace_flag(i) <= '0';
        end if;
      end loop;
    end if;
  end process u_dcount;

  -- Instance of Ch FIFO ----------------------------------------------------
  gen_chfifo : for i in 0 to kNumInputBlock-1 generate
    din_chfifo(i)   <= bufd_ring2chfifo(i);
    we_chfifo(i)    <= bufwe_ring2chfifo(i);
    read_valid(i)   <= dout_chfifo(i)(kIndexDataBit) AND rv_raw_chfifo(i);

    u_chfifo : channel_buffer_v2
      port map(
        clk     => sysClk,
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
  u_block_fifo : block_buffer_v2
    port map (
      clk         => sysClk,
      rst         => rst,
      din         => din_block_buffer,
      wr_en       => we_block_buffer,
      rd_en       => re_block_buffer,
      dout        => dout_block_buffer,
      full        => open,
      empty       => open,
      valid       => rv_block_buffer,
      prog_full   => pgfull_block_buffer
      );

  -- Instance of Event Summary ----------------------------------------------
  din_evsum   <= overflow_flag & std_logic_vector(to_unsigned(0, kWidthEventSize- kWidthNWord)) & n_of_word;

  u_evsum : evsummary_fifo
    port map (
      clk         => sysClk,
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
  u_write_ptr : process(rst, sysClk)
  begin
    if(rst = '1') then
      write_ptr   <= (others => '0');
    elsif(sysClk'event AND sysClk = '1') then
      write_ptr   <= std_logic_vector(unsigned(write_ptr) +1);
    end if;
  end process;

  u_SearchProcess : process(rst, sysClk)
  begin
    if(rst = '1') then
      we_ringbuf        <= "0";
      busy_process      <= '0';
      --write_ptr       <= (others => '0');
      read_ptr          <= (others => '0');
      re_ringbuf        <= '0';
      rv_ringbuf_pre    <= '0';

      data_bit          <= '0';
      lastword_count    <= (others => '0');
      finalize_count    <= '0';
      state_search         <= Init;
    elsif(sysClk'event AND sysClk = '1') then
      case state_search is
        when Init =>
          busy_process    <= '0';
          we_ringbuf      <= "0";
          --write_ptr       <= (others => '0');
          read_ptr        <= (others => '0');
          re_ringbuf      <= '0';
          rv_ringbuf_pre  <= '0';

          data_bit        <= isSeparator;
          lastword_count  <= (others => '0');
          finalize_count  <= '0';
          state_search    <= WaitCommonStop;

        when WaitCommonStop =>
          busy_process    <= '0';
          we_ringbuf      <= "1";
          if(cstop_issued = '1') then
            busy_process    <= '1';
            reg_cstop_value <= cstop_value;

            re_ringbuf      <= '1';
            data_bit        <= isData;
            read_ptr        <= std_logic_vector(unsigned(write_ptr) + unsigned(reg_local.offset_ptr));

            coarse_counter  <= reg_local.window_max;
            state_search    <= ReadRingBuffer;
          end if;

        when ReadRingBuffer =>
          read_ptr              <= std_logic_vector(unsigned(read_ptr) +1);
          coarse_counter        <= std_logic_vector(unsigned(coarse_counter) -1);
          if(coarse_counter = reg_local.window_min ) then
            re_ringbuf          <= '0';
            rv_ringbuf_pre      <= '0';
            data_bit            <= isSeparator;
            lastword_count      <= "111";
            state_search        <= LastWord;
          else
            rv_ringbuf_pre      <= '1';
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
  u_BuildProcess : process(rst, sysClk)
    variable id : integer;
  begin
    if(rst = '1') then
      local_index       <= (others => '0');
      re_chfifo         <= (others => '0');
      n_of_word         <= (others => '0');
      local_nhit        <= (others => '0');
      overflow_flag     <= '0';
      we_evsum          <= '0';
      we_ok_to_blbuffer <= '1';
      tdc_ch            <= std_logic_vector(unsigned(offset_ch) + kNumInputBlock-1);
      state_build       <= Init;
    elsif(sysClk'event AND sysClk = '1') then
      id      := to_integer(unsigned(local_index));

      din_block_buffer_buf  <= magicWord & '0' & tdc_ch & '0' & dout_chfifo(id)(kIndexDataBit-1 downto 0); -- NOTE: according to the change in # of TDC bit, "00"->'0'
      din_block_buffer      <= din_block_buffer_buf;
      we_block_buffer_buf   <= we_ok_to_blbuffer AND read_valid(id);
      we_block_buffer       <= we_block_buffer_buf;

      case state_build is
        when Init =>
          local_index   <= (others => '0');
          re_chfifo     <= (others => '0');
          n_of_word     <= (others => '0');
          local_nhit    <= (others => '0');
          overflow_flag <= '0';
          we_evsum      <= '0';
          we_ok_to_blbuffer     <= '1';
          tdc_ch        <= std_logic_vector(unsigned(offset_ch) + kNumInputBlock-1);
          state_build   <= WaitDready;

        when WaitDready =>
          if(dready_fifo = '1' and pgfull_block_buffer = '0') then
            we_ok_to_blbuffer <= '1';
            tdc_ch        <= std_logic_vector(unsigned(offset_ch) + kNumInputBlock-1);
            local_index   <= std_logic_vector(to_unsigned(kNumInputBlock-1, kWidthChIndex));
            state_build   <= DreadyInterval;
          end if;

        when DreadyInterval =>
          state_build     <= StartPosition;

        when StartPosition =>
          re_chfifo(id)   <= '1';
          local_nhit      <= (others => '0');
          state_build     <= ReadInterval;

        when ReadInterval =>
          state_build     <= ReadOneChannel;

        when ReadOneChannel =>
          if(rv_raw_chfifo(id) = '1') then
            if(dout_chfifo(id)(kIndexDataBit) = isSeparator) then
              re_chfifo(id)   <= '0';
              local_index     <= std_logic_vector(unsigned(local_index) -1);
              state_build     <= EndOneChannel;

            elsif(unsigned(local_nhit) = kMaxMultiHit
                  and dout_chfifo(id)(kIndexDataBit) = isData) then
              overflow_flag   <= '1';

            else
              local_nhit      <= std_logic_vector(unsigned(local_nhit) +1);
              n_of_word       <= std_logic_vector(unsigned(n_of_word) +1);
              if(unsigned(local_nhit) = kMaxMultiHit-1) then
                we_ok_to_blbuffer <= '0';
              end if;
            end if;
          end if;

        when EndOneChannel =>
          we_ok_to_blbuffer <= '1';
          tdc_ch            <= std_logic_vector(unsigned(local_index) + unsigned(offset_ch));
          if(unsigned(local_index) = kNumInputBlock-1) then
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
          overflow_flag <= '0';
          state_build   <= WaitDready;

        when others =>
          state_build <= Init;

      end case;
    end if;
  end process u_BuildProcess;

  -- Builder bus process --
  u_BuilderBusProcess : process(rst, sysClk)
  begin
    if(rst = '1') then
      dout_bbus           <= (others => '0');
      rv_bbus             <= '0';
      is_bound_to_builder <= '0';

      re_block_buffer     <= '0';
      state_bbus          <= Init;
    elsif(sysClk'event and sysClk = '1') then
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

end RTL;
