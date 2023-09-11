library IEEE, mylib;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use mylib.defTRM.all;
use mylib.defEVB.all;
--use mylib.defTdcBlock.all;
use mylib.defSiTCP.all;

entity EventBuilder is
  port(
    rst	        : in std_logic;
    clk         : in std_logic;
    clkLink     : in std_logic;
    enRM        : in  std_logic;

    -- TRM data --
    dInTRM      : in  dataTrm2Evb;
    dOutTRM     : out  dataEvb2Trm;

    -- Builder bus --
    addrBuilderBus      : out BBusAddressType;
    dataBuilderBusIn    : in  BBusDataArray;
    reBuilderBus        : out BBusControlType;
    rvBuilderBus        : in  BBusControlType;
    dReadyBuilderBus    : in  BBusControlType;
    bindBuilderBus      : out BBusControlType;
    isBoundToBuilder    : in  BBusControlType;

    -- TSD data --
    rdToTSD		  : out std_logic_vector(kWidthDataTCP-1 downto 0);
    rvToTSD     : out std_logic;
    emptyToTSD  : out std_logic;
    reFromTSD   : in std_logic
    );
end EventBuilder;

architecture RTL of EventBuilder is
  attribute mark_debug : string;

  -- System --
  signal sync_reset       : std_logic;
  signal reg_en_rm        : std_logic;

  -- Header --
  signal self_counter     : std_logic_vector(kWidthSelfCounter-1 downto 0);

  -- TRM --
  -- rename --
  signal in_trm           : dataTrm2Evb;
  signal out_trm          : dataEvb2Trm;
  -- rename --
  signal reg_level2, reg_clr  : std_logic;
  signal reg_tag          : std_logic_vector(kWidthTAG-1 downto 0);
  signal trig_ready       : std_logic;

  -- RVM --
  signal data_ready_rvm_buf   : std_logic;
  signal data_ready_rvm       : std_logic;

  -- User block --
  signal data_ready_user      : std_logic;

  -- Data Size --
  type blockSize is array(kNumBuilderBlock-1 downto 0) of std_logic_vector(kWidthEventSize-1 downto 0);
  signal reg_block_size       : blockSize;
  signal reg_event_size       : std_logic_vector(kWidthEventSize-1 downto 0);

  -- Overflow bit --
  signal reg_block_overflow   : std_logic_vector(kNumBuilderBlock-1 downto 0);
  signal reg_event_overflow   : std_logic;

  -- Event --
  signal data_ready           : std_logic;

  -- Evb FIFO --
  signal we_evbuf             : std_logic;
  signal din_evbuf            : std_logic_vector(kWidthDaqWord-1 downto 0);
  signal din_evbuf_swap       : std_logic_vector(kWidthDaqWord-1 downto 0);
  signal dout_sub_evbuf       : std_logic_vector(kWidthDaqWord-1 downto 0);

  signal re_from_evbbuf       : std_logic;
  signal valid_to_evbbuf      : std_logic;

  -- Event Building process --
  signal state_evb            : EvbProcessType;

  signal bbus_dest            : BlockID;
  signal num_read_word        : std_logic_vector(kWidthEventSize-1 downto 0);
  signal local_data_address   : BBusAddressType;

  signal req_bbus_cycle       : std_logic;
  signal ack_bbus_cycle       : std_logic;

  -- Builder bus master process --
  signal state_bbus       : BBusMasterType;

  signal addr_bbus        : BBusAddressType;
  signal din_bbus         : BBusDataArray;
  signal re_bbus          : BBusControlType;
  signal rv_bbus          : BBusControlType;
  signal dready_bbus      : BBusControlType;
  signal bind_bbus        : BBusControlType;
  signal is_bound_bbus    : BBusControlType;

  signal reg_read_count   : std_logic_vector(kWidthEventSize-1 downto 0);
  signal read_count       : std_logic_vector(kWidthEventSize-1 downto 0);
  signal recv_count       : std_logic_vector(kWidthEventSize-1 downto 0);
  signal index_bbus       : BlockID;

  signal pgfull_sub_evbuf     : std_logic;

  COMPONENT sub_event_buffer
    PORT (
      clk : IN STD_LOGIC;
      srst : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      valid : OUT STD_LOGIC;
      prog_full : OUT STD_LOGIC
    );
  END COMPONENT;

  signal pgfull_evbuf     : std_logic;
  COMPONENT event_buffer
    PORT (
      rst         : IN STD_LOGIC;
      wr_clk      : IN STD_LOGIC;
      rd_clk      : IN STD_LOGIC;
      din         : IN STD_LOGIC_VECTOR(kWidthDaqWord-1 DOWNTO 0);
      wr_en       : IN STD_LOGIC;
      rd_en       : IN STD_LOGIC;
      dout        : OUT STD_LOGIC_VECTOR(kWidthDataTCP-1 DOWNTO 0);
      full        : OUT STD_LOGIC;
      empty       : OUT STD_LOGIC;
      valid       : OUT STD_LOGIC;
      prog_full   : OUT STD_LOGIC
      );
  END COMPONENT;

  -- Debug ---------------------------------------------------------------------
  --attribute mark_debug of data_ready_rvm  : signal is "true";
  --attribute mark_debug of data_ready_user  : signal is "true";
  --attribute mark_debug of trig_ready  : signal is "true";
--
  --attribute mark_debug of state_evb   : signal is "true";
  --attribute mark_debug of state_bbus       : signal is "true";
  --attribute mark_debug of bbus_dest   : signal is "true";
  --attribute mark_debug of num_read_word   : signal is "true";
  --attribute mark_debug of local_data_address   : signal is "true";
  --attribute mark_debug of req_bbus_cycle   : signal is "true";
  --attribute mark_debug of ack_bbus_cycle   : signal is "true";
  --attribute mark_debug of addr_bbus   : signal is "true";
  --attribute mark_debug of re_bbus   : signal is "true";
  --attribute mark_debug of rv_bbus   : signal is "true";
  --attribute mark_debug of dready_bbus   : signal is "true";
  --attribute mark_debug of bind_bbus   : signal is "true";
  --attribute mark_debug of is_bound_bbus   : signal is "true";
  --attribute mark_debug of reg_read_count   : signal is "true";
  --attribute mark_debug of read_count   : signal is "true";
  --attribute mark_debug of recv_count   : signal is "true";
  --attribute mark_debug of index_bbus  : signal is "true";
--    attribute mark_debug of dInTrm      : signal is "true";
--    attribute mark_debug of dOutTrm     : signal is "true";
--    attribute mark_debug of emptyToTSD  : signal is "true";
--    attribute mark_debug of we_evbuf    : signal is "true";
--    attribute mark_debug of reFromTSD    : signal is "true";
--    attribute mark_debug of rvToTSD    : signal is "true";
--    attribute mark_debug of dOut1   : signal is "true";
--    attribute mark_debug of dIn1   : signal is "true";


begin
  -- ===========================================================================
  -- body
  -- ===========================================================================
  --data_ready_rvm_buf  <= dready_bbus(kBbTDCL0.ID) when(reg_en_rm = '1') else '1';
  data_ready_rvm_buf  <= '1';
  data_ready_user     <= and_reduce(dready_bbus(kNumBuilderBlock-1 downto 0));

  u_data_ready : process(sync_reset, clk)
  begin
    if(sync_reset = '1') then
      data_ready  <= '0';
      trig_ready  <= '0';
    elsif(clk'event AND clk = '1') then
      data_ready      <= data_ready_user and data_ready_rvm;
      trig_ready      <= in_trm.trigReady;
      data_ready_rvm  <= data_ready_rvm_buf;
    end if;
  end process;

  u_buffer : process(clk)
  begin
    if(clk'event AND clk = '1') then
      in_trm          <= dInTRM;
      dOutTRM         <= out_trm;

      -- Builder bus --
      addrBuilderBus  <= addr_bbus;
      reBuilderBus    <= re_bbus;
      rv_bbus         <= rvBuilderBus;
      dready_bbus     <= dReadyBuilderBus;
      bindBuilderBus  <= bind_bbus;
      is_bound_bbus   <= isBoundToBuilder;
      for i in 0 to kNumBuilderBlock-1 loop
        din_bbus(i)   <= dataBuilderBusIn(i);
      end loop;
    end if;
  end process;

  u_sync_enrm : entity mylib.synchronizer
    port map(clk=> clk, dIn=>enRM, dOut=>reg_en_rm);


  -- Event building ------------------------------------------------------------
  u_Evb : process(sync_reset, clk)
  begin
    if(sync_reset = '1') then
      for i in 0 to kNumBuilderBlock-1 loop
        reg_block_size(i)   <= (others => '0');
      end loop;

      we_evbuf          <= '0';
      out_trm.reFifo    <= '0';
      bbus_dest         <= kBbTDCL0.ID;
      self_counter      <= (others => '0');
      reg_event_size    <= (others => '0');
      reg_block_overflow  <= (others => '0');
      reg_event_overflow  <= '0';

      state_evb   <= Init;
    elsif(clk'event AND clk = '1') then
      case state_evb is
        when Init =>
          for i in 0 to kNumBuilderBlock-1 loop
            reg_block_size(i)         <= (others => '0');
          end loop;

          we_evbuf              <= '0';
          out_trm.reFifo        <= '0';
          bbus_dest             <= kBbTDCL0.ID;
          self_counter          <= (others => '0');
          reg_event_size        <= (others => '0');
          reg_block_overflow    <= (others => '0');
          reg_event_overflow    <= '0';
          state_evb             <= WaitDready;

        when WaitDready =>
          if(data_ready = '1' AND trig_ready = '1' AND pgfull_sub_evbuf = '0') then
            --if(data_ready = '1' AND pgfull_evbuf = '0') then
            out_trm.reFifo      <= '1';
            bbus_dest           <= kBbTDCL0.ID;
            state_evb           <= SetLevel2;
          end if;

        when SetLevel2 =>
          out_trm.reFifo        <= '0';
          if(in_trm.rvFifo = '1') then
            reg_level2          <= in_trm.regLevel2;
--            reg_clr           <= in_trm.regClear;
            reg_tag             <= in_trm.regTag;
            state_evb           <= SetBBusSize;
          end if;

        -- Data Size loop --
        when SetBBusSize =>
          local_data_address  <= kEventSummary;
          num_read_word       <= std_logic_vector(to_unsigned(1, kWidthEventSize));
          req_bbus_cycle      <= '1';
          if(is_bound_bbus(bbus_dest) = '1') then
            state_evb           <= ReadBlockSize;
          end if;

        when ReadBlockSize =>
          req_bbus_cycle      <= '0';
          if(rv_bbus(bbus_dest) = '1') then
            reg_block_size(bbus_dest)       <= din_bbus(bbus_dest)(kWidthEventSize-1 downto 0);
            reg_block_overflow(bbus_dest)   <= din_bbus(bbus_dest)(kWidthEventSize); -- This bit is defined as overflow bit.
          end if;

          if(ack_bbus_cycle = '1') then
            state_evb <= SetEventSize;
          end if;

        when SetEventSize =>
          reg_event_size  <= std_logic_vector(unsigned(reg_event_size) + unsigned(reg_block_size(bbus_dest)));
          if(bbus_dest = (kNumBuilderBlock-1)) then
            if(unsigned(reg_block_overflow) = 0) then
              reg_event_overflow  <= '0';
            else
              reg_event_overflow  <= '1';
            end if;

            state_evb     <= SendHeader1;
          else
            bbus_dest     <= bbus_dest + 1;
            state_evb     <= SetBBusSize;
          end if;
        -- Data Size loop --

        when SendHeader1  =>
          we_evbuf            <= '1' AND reg_level2;
          din_evbuf           <= kEigenWord;
          state_evb           <= SendHeader2;

        when SendHeader2  =>
          we_evbuf            <= '1' AND reg_level2;
          din_evbuf           <= X"ff0" & '0' & reg_event_overflow & reg_event_size;
          state_evb           <= SendHeader3;

        when SendHeader3 =>
          we_evbuf            <= '1' AND reg_level2;
          din_evbuf           <= X"ff" & reg_en_rm & "000" & reg_tag & self_counter;
          bbus_dest           <= kBbTDCL0.ID;
          state_evb           <= FinalizeHeader;

        when FinalizeHeader =>
          we_evbuf    <= '0';
          state_evb   <= SetBBusData;

        -- Data Read loop --
        when SetBBusData =>
          local_data_address  <= kDataBuffer;
          num_read_word       <= reg_block_size(bbus_dest);
          req_bbus_cycle      <= '1';
          if(is_bound_bbus(bbus_dest) = '1') then
            state_evb           <= ReadBlock;
          end if;

        when ReadBlock =>
          req_bbus_cycle      <= '0';
          we_evbuf            <= rv_bbus(bbus_dest) and reg_level2;
          din_evbuf           <= din_bbus(bbus_dest);
          if(ack_bbus_cycle = '1') then
            state_evb <= CheckEndOfBuild;
          end if;

        when CheckEndOfBuild =>
          we_evbuf        <= '0';
          if(bbus_dest = (kNumBuilderBlock-1)) then
            state_evb     <= Finalize;
          else
            bbus_dest     <= bbus_dest + 1;
            state_evb     <= SetBBusData;
          end if;
        -- Data Read loop --

        when Finalize   =>
          we_evbuf        <= '0';
          reg_event_size  <= (others => '0');
          if(reg_level2 = '1') then
            self_counter  <= std_logic_vector(unsigned(self_counter) +1);
          end if;
          state_evb       <= Done;

        when Done =>
          state_evb   <= WaitDready;

      end case;
    end if;
  end process u_Evb;

  u_BBusMasterProcess : process(sync_reset, clk)
  begin
    if(sync_reset = '1') then
      addr_bbus       <= (others => '0');
      re_bbus         <= (others => '0');
      bind_bbus       <= (others => '0');
      ack_bbus_cycle  <= '0';
      index_bbus      <= 0;

      reg_read_count  <= (others => '0');
      read_count      <= (others => '0');
      recv_count      <= (others => '0');

      state_bbus  <= Init;
    elsif(clk'event and clk = '1') then
      case state_bbus is
        when Init =>
          addr_bbus       <= (others => '0');
          re_bbus         <= (others => '0');
          bind_bbus       <= (others => '0');
          ack_bbus_cycle  <= '0';

          reg_read_count  <= (others => '0');
          read_count      <= (others => '0');
          recv_count      <= (others => '0');

          state_bbus      <= Idle;

        when Idle =>
          index_bbus      <= 0;
          ack_bbus_cycle  <= '0';
          if(req_bbus_cycle = '1') then
            state_bbus <= SetBus;
          end if;

        when SetBus =>
          addr_bbus       <= local_data_address;
          reg_read_count  <= num_read_word;
          read_count      <= num_read_word;
          recv_count      <= (others => '0');
          index_bbus      <= bbus_dest; -- Actually, this has no meaning.
                                        -- Just my preference.
          state_bbus      <= BindBus;

        when BindBus =>
          bind_bbus(index_bbus)   <= '1';
          if(is_bound_bbus(index_bbus) = '1') then
            state_bbus  <= ReadBus;
          end if;

        when ReadBus =>
          if(unsigned(read_count) = 0) then
            re_bbus(index_bbus)  <= '0';
--            count_end_block   <= "100";
--            state_evb   <= EndOfBlock;
          elsif(pgfull_evbuf = '1') then
            re_bbus(index_bbus)   <= '0';
          else
            re_bbus(index_bbus)   <= '1';
            read_count            <= std_logic_vector(unsigned(read_count) -1);
          end if;

          if(rv_bbus(index_bbus) = '1') then
            recv_count  <= std_logic_vector(unsigned(recv_count) +1);
          end if;

          if(reg_read_count = recv_count) then
            state_bbus  <= ReleaseBus;
          end if;

        when ReleaseBus =>
          re_bbus(index_bbus)     <= '0';
          bind_bbus(index_bbus)   <= '0';
          ack_bbus_cycle          <= '1';
          state_bbus              <= Idle;

        when others =>
          state_bbus  <= Init;
      end case;
    end if;
  end process;


  din_evbuf_swap  <= din_evbuf(7 downto 0) & din_evbuf(15 downto 8) & din_evbuf(23 downto 16) & din_evbuf(31 downto 24);

  u_SubEvbBuf : sub_event_buffer
    port map (
      clk     => clk,
      srst    => sync_reset,
      din     => din_evbuf_swap,
      wr_en   => we_evbuf,
      rd_en   => re_from_evbbuf,
      dout    => dout_sub_evbuf,
      full    => open,
      empty   => open,
      valid   => valid_to_evbbuf,
      prog_full   => pgfull_sub_evbuf
    );

  re_from_evbbuf  <= not pgfull_evbuf;

  u_EvbBuf : event_buffer
    port map(
      rst         => sync_reset,
      wr_clk      => clk,
      rd_clk      => clkLink,
      din         => dout_sub_evbuf,
      wr_en       => valid_to_evbbuf,
      rd_en       => reFromTSD,
      dout        => rdToTSD,
      full        => open,
      empty       => emptyToTSD,
      valid       => rvToTSD,
      prog_full   => pgfull_evbuf
      );

  -- Reset sequence --
  u_reset_gen : entity mylib.ResetGen
    port map(rst, clk, sync_reset);

end RTL;
