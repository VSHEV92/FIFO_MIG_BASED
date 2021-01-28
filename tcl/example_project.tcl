# ---------------------------------------------------------------------
# ----- Cкрипт для автоматической сборки демонстрационного проекта ----
# ---------------------------------------------------------------------
set Project_Name fifo_mig_based_example

close_project -quiet
if { [file exists $Project_Name] != 0 } { 
	file delete -force $Project_Name
	puts "Delete old Project"
}

# создаем проект
create_project $Project_Name ./$Project_Name -part xc7a50tftg256-1

# запускаем скрипт по упаковке ядра и добавляем репозиторий
if { [file exists IP] == 0 } { 
	source tcl/package_IP.tcl
} else {
	close_project -quiet
}
open_project fifo_mig_based_example/fifo_mig_based_example.xpr
set_property  ip_repo_paths IP [current_project]
update_ip_catalog

config_ip_cache -import_from_project -use_cache_location ip_cache

# создание IP MIG для платы Artix 7A50T
create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.2 -module_name mig_7series_0
set_property -dict [list CONFIG.RESET_BOARD_INTERFACE {Custom} CONFIG.MIG_DONT_TOUCH_PARAM {Custom} CONFIG.BOARD_MIG_PARAM {Custom} CONFIG.SYSTEM_RESET.INSERT_VIP {0} CONFIG.CLK_REF_I.INSERT_VIP {0} CONFIG.RESET.INSERT_VIP {0} CONFIG.DDR3_RESET.INSERT_VIP {0} CONFIG.DDR2_RESET.INSERT_VIP {0} CONFIG.LPDDR2_RESET.INSERT_VIP {0} CONFIG.QDRIIP_RESET.INSERT_VIP {0} CONFIG.RLDII_RESET.INSERT_VIP {0} CONFIG.RLDIII_RESET.INSERT_VIP {0} CONFIG.CLOCK.INSERT_VIP {0} CONFIG.MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S_AXI_CTRL.INSERT_VIP {0} CONFIG.S_AXI.INSERT_VIP {0} CONFIG.SYS_CLK_I.INSERT_VIP {0} CONFIG.ARESETN.INSERT_VIP {0} CONFIG.C0_RESET.INSERT_VIP {0} CONFIG.C0_DDR3_RESET.INSERT_VIP {0} CONFIG.C0_DDR2_RESET.INSERT_VIP {0} CONFIG.C0_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C0_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C0_RLDII_RESET.INSERT_VIP {0} CONFIG.C0_RLDIII_RESET.INSERT_VIP {0} CONFIG.C0_CLOCK.INSERT_VIP {0} CONFIG.C0_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C0_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C0_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C0_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C0_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S0_AXI_CTRL.INSERT_VIP {0} CONFIG.S0_AXI.INSERT_VIP {0} CONFIG.C0_SYS_CLK_I.INSERT_VIP {0} CONFIG.C0_ARESETN.INSERT_VIP {0} CONFIG.C1_RESET.INSERT_VIP {0} CONFIG.C1_DDR3_RESET.INSERT_VIP {0} CONFIG.C1_DDR2_RESET.INSERT_VIP {0} CONFIG.C1_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C1_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C1_RLDII_RESET.INSERT_VIP {0} CONFIG.C1_RLDIII_RESET.INSERT_VIP {0} CONFIG.C1_CLOCK.INSERT_VIP {0} CONFIG.C1_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C1_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C1_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C1_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C1_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S1_AXI_CTRL.INSERT_VIP {0} CONFIG.S1_AXI.INSERT_VIP {0} CONFIG.C1_SYS_CLK_I.INSERT_VIP {0} CONFIG.C1_ARESETN.INSERT_VIP {0} CONFIG.C2_RESET.INSERT_VIP {0} CONFIG.C2_DDR3_RESET.INSERT_VIP {0} CONFIG.C2_DDR2_RESET.INSERT_VIP {0} CONFIG.C2_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C2_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C2_RLDII_RESET.INSERT_VIP {0} CONFIG.C2_RLDIII_RESET.INSERT_VIP {0} CONFIG.C2_CLOCK.INSERT_VIP {0} CONFIG.C2_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C2_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C2_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C2_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C2_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S2_AXI_CTRL.INSERT_VIP {0} CONFIG.S2_AXI.INSERT_VIP {0} CONFIG.C2_SYS_CLK_I.INSERT_VIP {0} CONFIG.C2_ARESETN.INSERT_VIP {0} CONFIG.C3_RESET.INSERT_VIP {0} CONFIG.C3_DDR3_RESET.INSERT_VIP {0} CONFIG.C3_DDR2_RESET.INSERT_VIP {0} CONFIG.C3_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C3_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C3_RLDII_RESET.INSERT_VIP {0} CONFIG.C3_RLDIII_RESET.INSERT_VIP {0} CONFIG.C3_CLOCK.INSERT_VIP {0} CONFIG.C3_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C3_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C3_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C3_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C3_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S3_AXI_CTRL.INSERT_VIP {0} CONFIG.S3_AXI.INSERT_VIP {0} CONFIG.C3_SYS_CLK_I.INSERT_VIP {0} CONFIG.C3_ARESETN.INSERT_VIP {0} CONFIG.C4_RESET.INSERT_VIP {0} CONFIG.C4_DDR3_RESET.INSERT_VIP {0} CONFIG.C4_DDR2_RESET.INSERT_VIP {0} CONFIG.C4_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C4_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C4_RLDII_RESET.INSERT_VIP {0} CONFIG.C4_RLDIII_RESET.INSERT_VIP {0} CONFIG.C4_CLOCK.INSERT_VIP {0} CONFIG.C4_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C4_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C4_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C4_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C4_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S4_AXI_CTRL.INSERT_VIP {0} CONFIG.S4_AXI.INSERT_VIP {0} CONFIG.C4_SYS_CLK_I.INSERT_VIP {0} CONFIG.C4_ARESETN.INSERT_VIP {0} CONFIG.C5_RESET.INSERT_VIP {0} CONFIG.C5_DDR3_RESET.INSERT_VIP {0} CONFIG.C5_DDR2_RESET.INSERT_VIP {0} CONFIG.C5_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C5_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C5_RLDII_RESET.INSERT_VIP {0} CONFIG.C5_RLDIII_RESET.INSERT_VIP {0} CONFIG.C5_CLOCK.INSERT_VIP {0} CONFIG.C5_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C5_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C5_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C5_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C5_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S5_AXI_CTRL.INSERT_VIP {0} CONFIG.S5_AXI.INSERT_VIP {0} CONFIG.C5_SYS_CLK_I.INSERT_VIP {0} CONFIG.C5_ARESETN.INSERT_VIP {0} CONFIG.C6_RESET.INSERT_VIP {0} CONFIG.C6_DDR3_RESET.INSERT_VIP {0} CONFIG.C6_DDR2_RESET.INSERT_VIP {0} CONFIG.C6_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C6_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C6_RLDII_RESET.INSERT_VIP {0} CONFIG.C6_RLDIII_RESET.INSERT_VIP {0} CONFIG.C6_CLOCK.INSERT_VIP {0} CONFIG.C6_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C6_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C6_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C6_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C6_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S6_AXI_CTRL.INSERT_VIP {0} CONFIG.S6_AXI.INSERT_VIP {0} CONFIG.C6_SYS_CLK_I.INSERT_VIP {0} CONFIG.C6_ARESETN.INSERT_VIP {0} CONFIG.C7_RESET.INSERT_VIP {0} CONFIG.C7_DDR3_RESET.INSERT_VIP {0} CONFIG.C7_DDR2_RESET.INSERT_VIP {0} CONFIG.C7_LPDDR2_RESET.INSERT_VIP {0} CONFIG.C7_QDRIIP_RESET.INSERT_VIP {0} CONFIG.C7_RLDII_RESET.INSERT_VIP {0} CONFIG.C7_RLDIII_RESET.INSERT_VIP {0} CONFIG.C7_CLOCK.INSERT_VIP {0} CONFIG.C7_MMCM_CLKOUT0.INSERT_VIP {0} CONFIG.C7_MMCM_CLKOUT1.INSERT_VIP {0} CONFIG.C7_MMCM_CLKOUT2.INSERT_VIP {0} CONFIG.C7_MMCM_CLKOUT3.INSERT_VIP {0} CONFIG.C7_MMCM_CLKOUT4.INSERT_VIP {0} CONFIG.S7_AXI_CTRL.INSERT_VIP {0} CONFIG.S7_AXI.INSERT_VIP {0} CONFIG.C7_SYS_CLK_I.INSERT_VIP {0} CONFIG.C7_ARESETN.INSERT_VIP {0}] [get_ips mig_7series_0]
file copy -force constraints/mig_a_x4.prj fifo_mig_based_example/fifo_mig_based_example.srcs/sources_1/ip/mig_7series_0/mig_a.prj 
set_property -dict [list CONFIG.XML_INPUT_FILE {mig_a.prj}] [get_ips mig_7series_0]
generate_target {all} [get_files fifo_mig_based_example/fifo_mig_based_example.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci]

# добавляем исходники к проекту
add_files ./hdl/project_top/project_top.v

# добавляем constraints к проекту
add_files -fileset constrs_1 -norecurse constraints/pins.xdc
add_files -fileset constrs_1 -norecurse constraints/timing.xdc

# добавляем ядро MIG Fifo в проект
create_ip -name Fifo_MIG_Based -vendor VSHEV92 -library user -version 1.0 -module_name Fifo_MIG_Based_0 -dir fifo_mig_based_example/fifo_mig_based_example.srcs/sources_1/ip
generate_target {instantiation_template} [get_files fifo_mig_based_example/fifo_mig_based_example.srcs/sources_1/ip/Fifo_MIG_Based_0/Fifo_MIG_Based_0.xci]

# -----------------------------------------------------------------
# создаем block design с microblaze
create_bd_design "microblaze_bd"

# microblaze 
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {0} axi_periph {Enabled} cache {None} clk {New External Port} debug_module {Debug Only} ecc {None} local_mem {64KB} preset {None}}  [get_bd_cells microblaze_0]
set_property -dict [list CONFIG.C_FSL_LINKS {1}] [get_bd_cells microblaze_0]

# reset
make_bd_pins_external  [get_bd_pins rst_Clk_100M/ext_reset_in]
set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports ext_reset_in_0]
set_property name reset [get_bd_ports ext_reset_in_0]

# uart
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
connect_bd_intf_net [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0/M_AXI_DP]
connect_bd_net [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins rst_Clk_100M/peripheral_aresetn]
connect_bd_net [get_bd_ports Clk] [get_bd_pins axi_uartlite_0/s_axi_aclk]
make_bd_intf_pins_external  [get_bd_intf_pins axi_uartlite_0/UART]

# axis data width conterters (in)
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_1
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES.VALUE_SRC USER] [get_bd_cells axis_dwidth_converter_1]
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {16} CONFIG.M_TDATA_NUM_BYTES {4}] [get_bd_cells axis_dwidth_converter_1]
connect_bd_net [get_bd_ports Clk] [get_bd_pins axis_dwidth_converter_1/aclk]
connect_bd_net [get_bd_pins axis_dwidth_converter_1/aresetn] [get_bd_pins rst_Clk_100M/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins axis_dwidth_converter_1/M_AXIS] [get_bd_intf_pins microblaze_0/S0_AXIS]
make_bd_intf_pins_external  [get_bd_intf_pins axis_dwidth_converter_1/S_AXIS]

# axis data width conterters (out)
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES.VALUE_SRC USER] [get_bd_cells axis_dwidth_converter_0]
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {4} CONFIG.M_TDATA_NUM_BYTES {16}] [get_bd_cells axis_dwidth_converter_0]
connect_bd_net [get_bd_pins axis_dwidth_converter_0/aresetn] [get_bd_pins rst_Clk_100M/peripheral_aresetn]
connect_bd_net [get_bd_ports Clk] [get_bd_pins axis_dwidth_converter_0/aclk]
connect_bd_intf_net [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS] [get_bd_intf_pins microblaze_0/M0_AXIS]
make_bd_intf_pins_external  [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS]

# сохранение block design
assign_bd_address
validate_bd_design
regenerate_bd_layout
save_bd_design
close_bd_design [get_bd_designs microblaze_bd]
# -----------------------------------------------------------------
