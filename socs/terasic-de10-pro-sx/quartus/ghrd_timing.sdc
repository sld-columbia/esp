set_time_format -unit ns -decimal_places 3

# 100MHz board input clock, 133.3333MHz for EMIF refclk
#create_clock -name MAIN_CLOCK -period 10 [get_ports CLK_100_B3I]
create_clock -name EMIF_REF_CLOCK -period 3.75 [get_ports DDR4A_REFCLK_p]
create_clock -name PCS_CLOCK -period 8 [get_ports enet_refclk]
#create_clock -name ESP_CLOCK -period 20 [get_ports CLK_50_B3C]
create_clock -name MAIN_CLOCK -period 20 [get_ports CLK_50_B3C]

set_false_path -from [get_ports {CPU_RESET_n}]
#set_input_delay -clock MAIN_CLOCK 1 [get_ports {CPU_RESET_n}]

# sourcing JTAG related SDC
source ./jtag.sdc

# FPGA IO port constraints
set_false_path -from [get_ports {BUTTON[0]}] -to *
set_false_path -from [get_ports {BUTTON[1]}] -to *
set_false_path -from [get_ports {SW[0]}] -to *
set_false_path -from [get_ports {SW[1]}] -to *
set_false_path -from [get_ports {LED[0]}] -to *
set_false_path -from [get_ports {LED[1]}] -to *
set_false_path -from [get_ports {LED[2]}] -to *
set_false_path -from [get_ports {LED[3]}] -to *
set_false_path -from * -to [get_ports {LED[0]}]
set_false_path -from * -to [get_ports {LED[1]}]
set_false_path -from * -to [get_ports {LED[2]}]
set_false_path -from * -to [get_ports {LED[3]}]
set_false_path -from [get_ports {FAN_ALERT_n}] -to *
set_false_path -from [get_ports {FAN_I2C_SDA}] -to *
set_false_path -from * -to [get_ports {FAN_I2C_SCL}]
set_false_path -from * -to [get_ports {FAN_I2C_SDA}]

set_max_skew -to [get_ports "HPS_EMAC0_MDC"] 2
set_max_skew -to [get_ports "HPS_EMAC0_MDIO"] 2
set_false_path -from * -to [ get_ports emac1_phy_rst_n ]

set_false_path -from [get_ports {emac1_phy_irq}] -to *
