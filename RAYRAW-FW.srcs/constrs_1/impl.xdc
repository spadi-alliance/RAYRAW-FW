set_operating_conditions -ambient_temp 40.0
set_operating_conditions -airflow 0
set_operating_conditions -heatsink none

set_property CONFIG_MODE SPIx4 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

