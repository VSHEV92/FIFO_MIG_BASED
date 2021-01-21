`timescale 1ns / 1ps

`include "../header/Environment.svh"
`include "../header/testbench_settings.svh"
//`include "../header/test_set.svh"

module Fifo_MIG_Based_tb();

	parameter PHY_to_UI_Rate = 1; // 1 - X4, 2 - X2
    parameter Max_Burst_Len = 16;
    parameter RW_Delay_Value = 4;
    parameter Base_Address = 0;
    parameter Memory_Size = 100;
    parameter MIG_Data_Port_Size = 128;
    parameter MIG_Addr_Port_Size = 28;
    parameter IO_Fifo_Depth = 32;

logic   rst_n, ck, ck_n, cke, ras_n, cas_n, we_n, odt;
tri     [1:0]  dm_tdqs, dqs, dqs_n;
logic   [2:0]  ba;
logic   [14:0] addr;
tri     [15:0] dq;

logic reset, aresetn, aclk, init_calib;
bit sys_rst = 1;
bit sys_clk_i = 0;

logic [27:0] app_addr;
logic [2:0] app_cmd;
logic app_en, app_rdy;

logic [127:0] app_wdf_data, app_rd_data;
logic [15:0] app_wdf_mask;
logic app_wdf_wren, app_wdf_end, app_wdf_rdy;
logic app_rd_data_valid, app_rd_data_end;

AXIS_intf #(128) axis_in (aclk, aresetn);
AXIS_intf #(128) axis_out (aclk, aresetn);
    
// --------------------------------------------------------------------------------------------
// тактовый сигнал
 initial forever
    #(1000.0 / 2 / CLK_FREQ) sys_clk_i = ~sys_clk_i; 

// сигнал сброса
initial 
	#RESET_DEASSERT_DELAY sys_rst = 0;

// тестовое окружение
initial begin
    Environment #(128) env;
    env = new;
    env.axis_in = axis_in;
    axis_in.tvalid = 0;
    axis_in.tdata = 0;
    axis_out.tready = 1;
    wait(init_calib);
    env.run(200);
end

// --------------------------------------------------------------------------------------------
// проверяемый блок
Fifo_MIG_Based
#(
 	.PHY_to_UI_Rate(PHY_to_UI_Rate),
    .Max_Burst_Len(Max_Burst_Len),
    .RW_Delay_Value(RW_Delay_Value),
    .Base_Address(Base_Address),
    .Memory_Size(Memory_Size),
    .MIG_Data_Port_Size(MIG_Data_Port_Size),
    .MIG_Addr_Port_Size(MIG_Addr_Port_Size),
    .IO_Fifo_Depth(IO_Fifo_Depth)
)
DUT
(
	.aclk(aclk),
    .aresetn(aresetn),
    .init_calib(init_calib),
    // входной AXIS интерфейс
    .in_tdata(axis_in.tdata),
    .in_tvalid(axis_in.tvalid),
    .in_tready(axis_in.tready),
    // выходной AXIS интерфейс
    .out_tdata(axis_out.tdata),
    .out_tvalid(axis_out.tvalid),
    .out_tready(axis_out.tready),
    // Native Interface MIG
    .app_addr(app_addr),
    .app_cmd(app_cmd),
    .app_en(app_en),
    .app_rdy(app_rdy),
    .app_wdf_data(app_wdf_data),
    .app_wdf_wren(app_wdf_wren),
    .app_wdf_mask(app_wdf_mask),  
    .app_wdf_end(app_wdf_end),
    .app_wdf_rdy(app_wdf_rdy),
    .app_rd_data(app_rd_data),
    .app_rd_data_valid(app_rd_data_valid),
    .app_rd_data_end(app_rd_data_end)
);

// --------------------------------------------------------------------------------------------
// ядро MIG
mig_7series_0 MIG_inst (
    .ddr3_addr              (addr), 
    .ddr3_ba                (ba),  
    .ddr3_cas_n             (cas_n),  
    .ddr3_ck_n              (ck_n),  
    .ddr3_ck_p              (ck),  
    .ddr3_cke               (cke),  
    .ddr3_ras_n             (ras_n),  
    .ddr3_reset_n           (rst_n),  
    .ddr3_we_n              (we_n),  
    .ddr3_dq                (dq),  
    .ddr3_dqs_n             (dqs_n),  
    .ddr3_dqs_p             (dqs),  
    .init_calib_complete    (init_calib),  
    .ddr3_dm                (dm_tdqs),  
    .ddr3_odt               (odt),  
    .app_addr               (app_addr),  
    .app_cmd                (app_cmd),  
    .app_en                 (app_en),  
    .app_wdf_data           (app_wdf_data),  
    .app_wdf_end            (app_wdf_end), 
    .app_wdf_wren           (app_wdf_wren), 
    .app_rd_data            (app_rd_data),  
    .app_rd_data_end        (app_rd_data_end),  
    .app_rd_data_valid      (app_rd_data_valid),  
    .app_rdy                (app_rdy),  
    .app_wdf_rdy            (app_wdf_rdy),  
    .app_sr_req             (0), 
    .app_ref_req            (0),  
    .app_zq_req             (0), 
    .app_sr_active          (), 
    .app_ref_ack            (),  
    .app_zq_ack             (), 
    .ui_clk                 (aclk),  
    .ui_clk_sync_rst        (reset),  
    .app_wdf_mask           (app_wdf_mask),  
    .sys_clk_i              (sys_clk_i), 
    .sys_rst                (sys_rst) 
    );
assign aresetn = ~reset;

// --------------------------------------------------------------------------------------------
// модель DDR3 памяти
ddr3_model ddr3_DRAM (.*, .tdqs_n(), .cs_n(0));

endmodule
