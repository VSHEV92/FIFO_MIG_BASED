# input false path
set_false_path -from [get_ports sys_rst]
set_false_path -from [get_ports Uart_RX]

# output false path
set_false_path -to   [get_ports Uart_TX]
set_false_path -to [get_ports init_led]