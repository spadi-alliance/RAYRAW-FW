# Clock definition
#create_clock -name clk_in -period 8 -waveform {0 4} [get_ports PHY_RX_CLK]

# SiTCP
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX11Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX12Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX13Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX14Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX15Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX16Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX17Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX18Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX19Data*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1AData*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/SiTCP_INT/SiTCP_INT_REG/regX1BData*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/BBT_SiTCP_RST/resetReq*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/memRdReq*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/orRdAct*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/dlyBank0LastWrAddr*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/dlyBank1LastWrAddr*}]
set_false_path -through [get_nets {gen_SiTCP[*].u_SiTCP_Inst/SiTCP/GMII/GMII_TXBUF/muxEndTgl}]


#set_false_path -from [get_nets u_MTX1/reg_fbh*] -to [get_nets u_MTX1/gen_tof[*].gen_ch[*].u_Matrix_Impl/in_fbh]

set_false_path -through [get_ports {LED[1]}]
set_false_path -through [get_ports {LED[2]}]
set_false_path -through [get_ports {LED[3]}]
set_false_path -through [get_ports {LED[4]}]

#set_false_path -through [get_nets ext_L1]
#set_false_path -through [get_nets ext_busy]
#set_false_path -through [get_nets ext_rsv2]
set_false_path -through [get_nets seq_busy]
set_false_path -through [get_nets module_busy]
set_false_path -through [get_nets user_reset]
set_false_path -through [get_nets bct_reset]
set_false_path -through [get_nets emergency_reset]
#set_false_path -through [get_nets {DIP[*]}]
set_false_path -through [get_nets {NIM_OUT[*]}]
set_false_path -through [get_nets {NIM_IN[*]}]
set_false_path -through [get_nets u_TRM_Inst/reg_sel_trig*]
set_false_path -through [get_nets u_TRM_Inst/self_busy]
set_false_path -through [get_nets u_TRM_Inst/fifo_busy]
set_false_path -through [get_nets u_TRM_Inst/seq_busy]
set_false_path -through [get_nets u_DCT_Inst/reg_daq_gate]
set_false_path -through [get_nets u_DCT_Inst/evb_reset]
set_false_path -through [get_nets {u_TDC_Inst/busy[*]}]
set_false_path -through [get_nets u_DCT_Inst/reg_daq_gate]
set_false_path -through [get_nets u_BCT_Inst/rst_from_bus*]
set_false_path -through [get_nets {u_IOM_Inst/reg_extL1[*]}]
set_false_path -through [get_nets {u_IOM_Inst/reg_ext_busy[*]}]
set_false_path -through [get_nets {u_IOM_Inst/reg_ext_rsv2[*]}]
set_false_path -from [get_pins {u_IOM_Inst/reg_extL1_reg[*]/C}] -to [get_pins u_TDC_Inst/u_CStop/u_FirstFDC/FDCE_inst2/D]

## constraints for clk_wis_0

create_generated_clock -name clk_sys     [get_pins u_ClkCdcm_Inst/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_tdc_0   [get_pins u_ClkCdcm_Inst/inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name clk_tdc_90  [get_pins u_ClkCdcm_Inst/inst/mmcm_adv_inst/CLKOUT2]
create_generated_clock -name clk_tdc_180 [get_pins u_ClkCdcm_Inst/inst/mmcm_adv_inst/CLKOUT3]
create_generated_clock -name clk_tdc_270 [get_pins u_ClkCdcm_Inst/inst/mmcm_adv_inst/CLKOUT4]

create_generated_clock -name clk_link    [get_pins u_ClkSys_Inst/inst/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_indep   [get_pins u_ClkSys_Inst/inst/mmcm_adv_inst/CLKOUT1]
create_generated_clock -name clk_spi     [get_pins u_ClkSys_Inst/inst/mmcm_adv_inst/CLKOUT2]
create_generated_clock -name clk_10mhz   [get_pins u_ClkSys_Inst/inst/mmcm_adv_inst/CLKOUT3]

set_multicycle_path -setup -from [get_clocks clk_tdc_270] -to [get_clocks clk_tdc_0] 2

create_generated_clock -name clk_gmii1 [get_pins u_GtClockDist_Inst/core_clocking_i/mmcm_adv_inst/CLKOUT0]
create_generated_clock -name clk_gmii2 [get_pins u_GtClockDist_Inst/core_clocking_i/mmcm_adv_inst/CLKOUT1]

set_clock_groups -name async_sys -asynchronous \
    -group {clk_tdc_0 clk_tdc_90 clk_tdc_180 clk_tdc_270 clk_sys} \
    -group clk_link \
    -group clk_indep \
    -group clk_spi \
    -group clk_10mhz \
    -group {clk_gmii1 clk_gmii2}

