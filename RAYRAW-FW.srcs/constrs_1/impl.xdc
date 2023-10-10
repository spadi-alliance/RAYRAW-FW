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
connect_debug_port u_ila_0/clk [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[0].u_adc/adcClk}]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[0].u_adc/state_bitslip[0]} {u_ADC_Inst/u_ADC/gen_adc[0].u_adc/state_bitslip[1]} {u_ADC_Inst/u_ADC/gen_adc[0].u_adc/state_bitslip[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[0].u_adc/state_idelay[0]} {u_ADC_Inst/u_ADC/gen_adc[0].u_adc/state_idelay[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 10 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][4][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][4][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 10 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][0][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][0][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 10 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_ADC_Inst/u_ADC/adc_frame_out[0][0]} {u_ADC_Inst/u_ADC/adc_frame_out[0][1]} {u_ADC_Inst/u_ADC/adc_frame_out[0][2]} {u_ADC_Inst/u_ADC/adc_frame_out[0][3]} {u_ADC_Inst/u_ADC/adc_frame_out[0][4]} {u_ADC_Inst/u_ADC/adc_frame_out[0][5]} {u_ADC_Inst/u_ADC/adc_frame_out[0][6]} {u_ADC_Inst/u_ADC/adc_frame_out[0][7]} {u_ADC_Inst/u_ADC/adc_frame_out[0][8]} {u_ADC_Inst/u_ADC/adc_frame_out[0][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 10 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][6][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][6][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {u_ADC_Inst/u_ADC/is_ready[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 10 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][1][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][1][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 10 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][3][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][3][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 10 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][2][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][2][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 10 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][5][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][5][9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 10 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[0][7][0]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][1]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][2]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][3]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][4]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][5]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][6]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][7]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][8]} {u_ADC_Inst/u_ADC/adc_data_out[0][7][9]}]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[1].u_adc/adcClk}]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 3 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[1].u_adc/state_bitslip[0]} {u_ADC_Inst/u_ADC/gen_adc[1].u_adc/state_bitslip[1]} {u_ADC_Inst/u_ADC/gen_adc[1].u_adc/state_bitslip[2]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 2 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[1].u_adc/state_idelay[0]} {u_ADC_Inst/u_ADC/gen_adc[1].u_adc/state_idelay[1]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 10 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][4][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][4][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 10 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][7][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][7][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 10 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][3][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][3][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 1 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list {u_ADC_Inst/u_ADC/is_ready[1]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 10 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][5][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][5][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 10 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][6][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][6][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 10 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][2][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][2][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 10 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][0][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][0][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe10]
set_property port_width 10 [get_debug_ports u_ila_1/probe10]
connect_debug_port u_ila_1/probe10 [get_nets [list {u_ADC_Inst/u_ADC/adc_frame_out[1][0]} {u_ADC_Inst/u_ADC/adc_frame_out[1][1]} {u_ADC_Inst/u_ADC/adc_frame_out[1][2]} {u_ADC_Inst/u_ADC/adc_frame_out[1][3]} {u_ADC_Inst/u_ADC/adc_frame_out[1][4]} {u_ADC_Inst/u_ADC/adc_frame_out[1][5]} {u_ADC_Inst/u_ADC/adc_frame_out[1][6]} {u_ADC_Inst/u_ADC/adc_frame_out[1][7]} {u_ADC_Inst/u_ADC/adc_frame_out[1][8]} {u_ADC_Inst/u_ADC/adc_frame_out[1][9]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe11]
set_property port_width 10 [get_debug_ports u_ila_1/probe11]
connect_debug_port u_ila_1/probe11 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[1][1][0]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][1]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][2]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][3]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][4]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][5]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][6]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][7]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][8]} {u_ADC_Inst/u_ADC/adc_data_out[1][1][9]}]]
create_debug_core u_ila_2 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_2]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_2]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_2]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_2]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_2]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_2]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_2]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_2]
set_property port_width 1 [get_debug_ports u_ila_2/clk]
connect_debug_port u_ila_2/clk [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[2].u_adc/adcClk}]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe0]
set_property port_width 3 [get_debug_ports u_ila_2/probe0]
connect_debug_port u_ila_2/probe0 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[2].u_adc/state_bitslip[0]} {u_ADC_Inst/u_ADC/gen_adc[2].u_adc/state_bitslip[1]} {u_ADC_Inst/u_ADC/gen_adc[2].u_adc/state_bitslip[2]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe1]
set_property port_width 2 [get_debug_ports u_ila_2/probe1]
connect_debug_port u_ila_2/probe1 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[2].u_adc/state_idelay[0]} {u_ADC_Inst/u_ADC/gen_adc[2].u_adc/state_idelay[1]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe2]
set_property port_width 10 [get_debug_ports u_ila_2/probe2]
connect_debug_port u_ila_2/probe2 [get_nets [list {u_ADC_Inst/u_ADC/adc_frame_out[2][0]} {u_ADC_Inst/u_ADC/adc_frame_out[2][1]} {u_ADC_Inst/u_ADC/adc_frame_out[2][2]} {u_ADC_Inst/u_ADC/adc_frame_out[2][3]} {u_ADC_Inst/u_ADC/adc_frame_out[2][4]} {u_ADC_Inst/u_ADC/adc_frame_out[2][5]} {u_ADC_Inst/u_ADC/adc_frame_out[2][6]} {u_ADC_Inst/u_ADC/adc_frame_out[2][7]} {u_ADC_Inst/u_ADC/adc_frame_out[2][8]} {u_ADC_Inst/u_ADC/adc_frame_out[2][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe3]
set_property port_width 10 [get_debug_ports u_ila_2/probe3]
connect_debug_port u_ila_2/probe3 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][3][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][3][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe4]
set_property port_width 10 [get_debug_ports u_ila_2/probe4]
connect_debug_port u_ila_2/probe4 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][5][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][5][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe5]
set_property port_width 10 [get_debug_ports u_ila_2/probe5]
connect_debug_port u_ila_2/probe5 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][4][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][4][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe6]
set_property port_width 1 [get_debug_ports u_ila_2/probe6]
connect_debug_port u_ila_2/probe6 [get_nets [list {u_ADC_Inst/u_ADC/is_ready[2]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe7]
set_property port_width 10 [get_debug_ports u_ila_2/probe7]
connect_debug_port u_ila_2/probe7 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][7][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][7][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe8]
set_property port_width 10 [get_debug_ports u_ila_2/probe8]
connect_debug_port u_ila_2/probe8 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][2][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][2][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe9]
set_property port_width 10 [get_debug_ports u_ila_2/probe9]
connect_debug_port u_ila_2/probe9 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][0][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][0][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe10]
set_property port_width 10 [get_debug_ports u_ila_2/probe10]
connect_debug_port u_ila_2/probe10 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][6][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][6][9]}]]
create_debug_port u_ila_2 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_2/probe11]
set_property port_width 10 [get_debug_ports u_ila_2/probe11]
connect_debug_port u_ila_2/probe11 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[2][1][0]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][1]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][2]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][3]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][4]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][5]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][6]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][7]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][8]} {u_ADC_Inst/u_ADC/adc_data_out[2][1][9]}]]
create_debug_core u_ila_3 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_3]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_3]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_3]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_3]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_3]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_3]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_3]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_3]
set_property port_width 1 [get_debug_ports u_ila_3/clk]
connect_debug_port u_ila_3/clk [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[3].u_adc/adcClk}]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe0]
set_property port_width 2 [get_debug_ports u_ila_3/probe0]
connect_debug_port u_ila_3/probe0 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[3].u_adc/state_idelay[0]} {u_ADC_Inst/u_ADC/gen_adc[3].u_adc/state_idelay[1]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe1]
set_property port_width 3 [get_debug_ports u_ila_3/probe1]
connect_debug_port u_ila_3/probe1 [get_nets [list {u_ADC_Inst/u_ADC/gen_adc[3].u_adc/state_bitslip[0]} {u_ADC_Inst/u_ADC/gen_adc[3].u_adc/state_bitslip[1]} {u_ADC_Inst/u_ADC/gen_adc[3].u_adc/state_bitslip[2]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe2]
set_property port_width 10 [get_debug_ports u_ila_3/probe2]
connect_debug_port u_ila_3/probe2 [get_nets [list {u_ADC_Inst/u_ADC/adc_frame_out[3][0]} {u_ADC_Inst/u_ADC/adc_frame_out[3][1]} {u_ADC_Inst/u_ADC/adc_frame_out[3][2]} {u_ADC_Inst/u_ADC/adc_frame_out[3][3]} {u_ADC_Inst/u_ADC/adc_frame_out[3][4]} {u_ADC_Inst/u_ADC/adc_frame_out[3][5]} {u_ADC_Inst/u_ADC/adc_frame_out[3][6]} {u_ADC_Inst/u_ADC/adc_frame_out[3][7]} {u_ADC_Inst/u_ADC/adc_frame_out[3][8]} {u_ADC_Inst/u_ADC/adc_frame_out[3][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe3]
set_property port_width 10 [get_debug_ports u_ila_3/probe3]
connect_debug_port u_ila_3/probe3 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][3][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][3][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe4]
set_property port_width 10 [get_debug_ports u_ila_3/probe4]
connect_debug_port u_ila_3/probe4 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][4][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][4][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe5]
set_property port_width 1 [get_debug_ports u_ila_3/probe5]
connect_debug_port u_ila_3/probe5 [get_nets [list {u_ADC_Inst/u_ADC/is_ready[3]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe6]
set_property port_width 10 [get_debug_ports u_ila_3/probe6]
connect_debug_port u_ila_3/probe6 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][2][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][2][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe7]
set_property port_width 10 [get_debug_ports u_ila_3/probe7]
connect_debug_port u_ila_3/probe7 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][0][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][0][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe8]
set_property port_width 10 [get_debug_ports u_ila_3/probe8]
connect_debug_port u_ila_3/probe8 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][6][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][6][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe9]
set_property port_width 10 [get_debug_ports u_ila_3/probe9]
connect_debug_port u_ila_3/probe9 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][1][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][1][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe10]
set_property port_width 10 [get_debug_ports u_ila_3/probe10]
connect_debug_port u_ila_3/probe10 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][5][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][5][9]}]]
create_debug_port u_ila_3 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_3/probe11]
set_property port_width 10 [get_debug_ports u_ila_3/probe11]
connect_debug_port u_ila_3/probe11 [get_nets [list {u_ADC_Inst/u_ADC/adc_data_out[3][7][0]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][1]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][2]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][3]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][4]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][5]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][6]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][7]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][8]} {u_ADC_Inst/u_ADC/adc_data_out[3][7][9]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ASIC_REFC_OBUF[0]]
