set_operating_conditions -ambient_temp 40.0
set_operating_conditions -airflow 0
set_operating_conditions -heatsink none

set_property CONFIG_MODE SPIx4 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]




create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list u_ClkCdcm_Inst/inst/clk_sys]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_EVB_Inst/addr_bbus_0[0]} {u_EVB_Inst/addr_bbus_0[1]} {u_EVB_Inst/addr_bbus_0[2]} {u_EVB_Inst/addr_bbus_0[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_EVB_Inst/bind_bbus[0]} {u_EVB_Inst/bind_bbus[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 2 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_EVB_Inst/is_bound_bbus[0]} {u_EVB_Inst/is_bound_bbus[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_EVB_Inst/re_bbus[0]} {u_EVB_Inst/re_bbus[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 3 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_EVB_Inst/state_bbus[0]} {u_EVB_Inst/state_bbus[1]} {u_EVB_Inst/state_bbus[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 2 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {u_EVB_Inst/bbus_dest[0]} {u_EVB_Inst/bbus_dest[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 13 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {u_EVB_Inst/recv_count[0]} {u_EVB_Inst/recv_count[1]} {u_EVB_Inst/recv_count[2]} {u_EVB_Inst/recv_count[3]} {u_EVB_Inst/recv_count[4]} {u_EVB_Inst/recv_count[5]} {u_EVB_Inst/recv_count[6]} {u_EVB_Inst/recv_count[7]} {u_EVB_Inst/recv_count[8]} {u_EVB_Inst/recv_count[9]} {u_EVB_Inst/recv_count[10]} {u_EVB_Inst/recv_count[11]} {u_EVB_Inst/recv_count[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {u_EVB_Inst/state_evb[0]} {u_EVB_Inst/state_evb[1]} {u_EVB_Inst/state_evb[2]} {u_EVB_Inst/state_evb[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 2 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_EVB_Inst/index_bbus[0]} {u_EVB_Inst/index_bbus[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 4 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {u_EVB_Inst/local_data_address[0]} {u_EVB_Inst/local_data_address[1]} {u_EVB_Inst/local_data_address[2]} {u_EVB_Inst/local_data_address[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 2 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {u_EVB_Inst/rv_bbus[0]} {u_EVB_Inst/rv_bbus[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 13 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {u_EVB_Inst/read_count[0]} {u_EVB_Inst/read_count[1]} {u_EVB_Inst/read_count[2]} {u_EVB_Inst/read_count[3]} {u_EVB_Inst/read_count[4]} {u_EVB_Inst/read_count[5]} {u_EVB_Inst/read_count[6]} {u_EVB_Inst/read_count[7]} {u_EVB_Inst/read_count[8]} {u_EVB_Inst/read_count[9]} {u_EVB_Inst/read_count[10]} {u_EVB_Inst/read_count[11]} {u_EVB_Inst/read_count[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 13 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {u_EVB_Inst/reg_read_count[0]} {u_EVB_Inst/reg_read_count[1]} {u_EVB_Inst/reg_read_count[2]} {u_EVB_Inst/reg_read_count[3]} {u_EVB_Inst/reg_read_count[4]} {u_EVB_Inst/reg_read_count[5]} {u_EVB_Inst/reg_read_count[6]} {u_EVB_Inst/reg_read_count[7]} {u_EVB_Inst/reg_read_count[8]} {u_EVB_Inst/reg_read_count[9]} {u_EVB_Inst/reg_read_count[10]} {u_EVB_Inst/reg_read_count[11]} {u_EVB_Inst/reg_read_count[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 2 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {u_EVB_Inst/dready_bbus[0]} {u_EVB_Inst/dready_bbus[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 13 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {u_EVB_Inst/num_read_word[0]} {u_EVB_Inst/num_read_word[1]} {u_EVB_Inst/num_read_word[2]} {u_EVB_Inst/num_read_word[3]} {u_EVB_Inst/num_read_word[4]} {u_EVB_Inst/num_read_word[5]} {u_EVB_Inst/num_read_word[6]} {u_EVB_Inst/num_read_word[7]} {u_EVB_Inst/num_read_word[8]} {u_EVB_Inst/num_read_word[9]} {u_EVB_Inst/num_read_word[10]} {u_EVB_Inst/num_read_word[11]} {u_EVB_Inst/num_read_word[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list u_EVB_Inst/ack_bbus_cycle]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list u_EVB_Inst/data_ready_rvm]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list u_EVB_Inst/data_ready_user]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list u_EVB_Inst/req_bbus_cycle]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list u_EVB_Inst/trig_ready]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_sys]
