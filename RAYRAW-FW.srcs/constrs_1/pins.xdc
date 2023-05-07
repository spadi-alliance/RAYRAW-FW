# ----------------------------------------------------------------
# Pin assignments
# ----------------------------------------------------------------
# clock
set_property PACKAGE_PIN E18 [get_ports CLKOSC]

# FIXED PORT -----------------------------------------------------
set_property PACKAGE_PIN V26 [get_ports {DISCRI_IN[0]}]
set_property PACKAGE_PIN V23 [get_ports {DISCRI_IN[1]}]
set_property PACKAGE_PIN W25 [get_ports {DISCRI_IN[2]}]
set_property PACKAGE_PIN Y26 [get_ports {DISCRI_IN[3]}]
set_property PACKAGE_PIN Y23 [get_ports {DISCRI_IN[4]}]
set_property PACKAGE_PIN AA24 [get_ports {DISCRI_IN[5]}]
set_property PACKAGE_PIN AB26 [get_ports {DISCRI_IN[6]}]
set_property PACKAGE_PIN AB24 [get_ports {DISCRI_IN[7]}]
set_property PACKAGE_PIN AE26 [get_ports {DISCRI_IN[8]}]
set_property PACKAGE_PIN AF25 [get_ports {DISCRI_IN[9]}]
set_property PACKAGE_PIN AD25 [get_ports {DISCRI_IN[10]}]
set_property PACKAGE_PIN AD24 [get_ports {DISCRI_IN[11]}]
set_property PACKAGE_PIN AF23 [get_ports {DISCRI_IN[12]}]
set_property PACKAGE_PIN AD23 [get_ports {DISCRI_IN[13]}]
set_property PACKAGE_PIN AE22 [get_ports {DISCRI_IN[14]}]
set_property PACKAGE_PIN AE21 [get_ports {DISCRI_IN[15]}]
set_property PACKAGE_PIN V24 [get_ports {DISCRI_IN[16]}]
set_property PACKAGE_PIN W26 [get_ports {DISCRI_IN[17]}]
set_property PACKAGE_PIN W24 [get_ports {DISCRI_IN[18]}]
set_property PACKAGE_PIN Y25 [get_ports {DISCRI_IN[19]}]
set_property PACKAGE_PIN AA25 [get_ports {DISCRI_IN[20]}]
set_property PACKAGE_PIN AA23 [get_ports {DISCRI_IN[21]}]
set_property PACKAGE_PIN AB25 [get_ports {DISCRI_IN[22]}]
set_property PACKAGE_PIN AC26 [get_ports {DISCRI_IN[23]}]
set_property PACKAGE_PIN AD26 [get_ports {DISCRI_IN[24]}]
set_property PACKAGE_PIN AE25 [get_ports {DISCRI_IN[25]}]
set_property PACKAGE_PIN AF24 [get_ports {DISCRI_IN[26]}]
set_property PACKAGE_PIN AC24 [get_ports {DISCRI_IN[27]}]
set_property PACKAGE_PIN AE23 [get_ports {DISCRI_IN[28]}]
set_property PACKAGE_PIN AF22 [get_ports {DISCRI_IN[29]}]
set_property PACKAGE_PIN AC22 [get_ports {DISCRI_IN[30]}]
set_property PACKAGE_PIN AD21 [get_ports {DISCRI_IN[31]}]

# GTX ------------------------------------------------------------
set_property PACKAGE_PIN D6 [get_ports GTX_REFCLK_P]
set_property PACKAGE_PIN D5 [get_ports GTX_REFCLK_N]

# SPI flash memory --------------------------------------------------
set_property PACKAGE_PIN C23 [get_ports FCS_B]
#set_property PACKAGE_PIN B17 [get_ports USR_CLK]
set_property PACKAGE_PIN B24 [get_ports MOSI]
set_property PACKAGE_PIN A25 [get_ports DIN]

# EEPROM ------------------------------------------------------------
set_property PACKAGE_PIN D15 [get_ports PROM_CS]
set_property PACKAGE_PIN B16 [get_ports PROM_SK]
set_property PACKAGE_PIN C16 [get_ports PROM_DI]
set_property PACKAGE_PIN D16 [get_ports PROM_DO]

# NIM IN ------------------------------------------------------------
set_property PACKAGE_PIN J24 [get_ports {NIMIN[1]}]
set_property PACKAGE_PIN J25 [get_ports {NIMIN[2]}]

# NIM OUT -----------------------------------------------------------
set_property PACKAGE_PIN H24 [get_ports {NIMOUT[1]}]
set_property PACKAGE_PIN H26 [get_ports {NIMOUT[2]}]

# Others ------------------------------------------------------------
set_property PACKAGE_PIN C9 [get_ports {DIP[0]}]
set_property PACKAGE_PIN D9 [get_ports {DIP[1]}]
set_property PACKAGE_PIN F9 [get_ports {DIP[2]}]
set_property PACKAGE_PIN G9 [get_ports {DIP[3]}]
set_property PACKAGE_PIN H8 [get_ports {DIP[4]}]
set_property PACKAGE_PIN H9 [get_ports {DIP[5]}]
set_property PACKAGE_PIN J8 [get_ports {DIP[6]}]
set_property PACKAGE_PIN E10 [get_ports {DIP[7]}]

set_property PACKAGE_PIN A8 [get_ports {LED[0]}]
set_property PACKAGE_PIN B9 [get_ports {LED[1]}]
set_property PACKAGE_PIN D8 [get_ports {LED[2]}]
set_property PACKAGE_PIN F8 [get_ports {LED[3]}]

set_property PACKAGE_PIN A17 [get_ports PROG_B_ON]
set_property PACKAGE_PIN G26 [get_ports USER_RST_B]

set_property PACKAGE_PIN N12 [get_ports VP]
set_property PACKAGE_PIN P11 [get_ports VN]

# ----------------------------------------------------------------
# Attribute
# ----------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports CLKOSC]

# input ------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports {DISCRI_IN[*]}]
#set_property IOB true [get_ports DISCRI_IN[*]]

# SPI flash memory -------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports FCS_B]
#set_property IOSTANDARD LVCMOS33 [get_ports USR_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports DIN]
set_property IOSTANDARD LVCMOS33 [get_ports MOSI]
set_property IOB TRUE [get_ports FCS_B]
#set_property IOB TRUE [get_ports USR_CLK]
set_property IOB TRUE [get_ports DIN]
set_property IOB TRUE [get_ports MOSI]

# EEPROM -----------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports PROM_CS]
set_property IOSTANDARD LVCMOS33 [get_ports PROM_SK]
set_property IOSTANDARD LVCMOS33 [get_ports PROM_DI]
set_property IOSTANDARD LVCMOS33 [get_ports PROM_DO]

set_property IOSTANDARD LVCMOS33 [get_ports {DIP[*]}]
set_property PULLUP true [get_ports {DIP[7]}]
set_property PULLUP true [get_ports {DIP[6]}]
set_property PULLUP true [get_ports {DIP[5]}]
set_property PULLUP true [get_ports {DIP[4]}]
set_property PULLUP true [get_ports {DIP[3]}]
set_property PULLUP true [get_ports {DIP[2]}]
set_property PULLUP true [get_ports {DIP[1]}]
set_property PULLUP true [get_ports {DIP[0]}]

# NIM -------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports {NIMOUT[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {NIMIN[*]}]

# system ----------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports {LED[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports PROG_B_ON]
set_property IOSTANDARD LVCMOS33 [get_ports USER_RST_B]

# J0 bus ----------------------------------------------------------
