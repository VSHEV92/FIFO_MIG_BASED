`timescale 1ns / 1ps

`include "../header/Environment.svh"
`include "../header/testbench_settings_x2.svh"
`include "../header/test_set.svh"

module Fifo_MIG_Based_tb();

localparam int TDATA_WIDTH = MIG_Data_Port_Size*PHY_to_UI_Rate;

logic   rst_n, ck, ck_n, cke, ras_n, cas_n, we_n, odt;
tri     [1:0]  dm_tdqs, dqs, dqs_n;
logic   [2:0]  ba;
logic   [14:0] addr;
tri     [15:0] dq;

logic reset, aresetn, aclk, init_calib;
bit sys_rst = 1;
bit sys_clk_i = 0;
bit clk_ref_i = 0;

logic [27:0] app_addr;
logic [2:0] app_cmd;
logic app_en, app_rdy;

logic [MIG_Data_Port_Size-1:0] app_wdf_data, app_rd_data;
logic [7:0] app_wdf_mask;
logic app_wdf_wren, app_wdf_end, app_wdf_rdy;
logic app_rd_data_valid, app_rd_data_end;

AXIS_intf #(TDATA_WIDTH) axis_in (aclk, aresetn);
AXIS_intf #(TDATA_WIDTH) axis_out (aclk, aresetn);

Environment #(TDATA_WIDTH) env;
    
// --------------------------------------------------------------------------------------------
// тактовый сигнал
 initial forever
    #(1000.0 / 2 / CLK_FREQ) sys_clk_i = ~sys_clk_i; 

initial forever
    #(1000.0 / 2 / 200) clk_ref_i = ~clk_ref_i; 


// сигнал сброса
initial 
	#RESET_DEASSERT_DELAY sys_rst = 0;

// тестовое окружение
initial begin
    env = new(GEN_MAX_DELAY_NS, MON_MAX_DELAY_NS, TRANSACTIONS_NUMB);
    env.axis_in = axis_in;
    env.axis_out = axis_out;
    wait(init_calib);
    env.run();
end

// завершение проекта по тайм-ауту
initial begin 
    #SIM_TIMEOUT_NS;
    $display("time = %t: Simulation timeout!", $time);
    $finish;
end    

// вывод результатов теста
final begin
    automatic int f_result; 
    automatic string file_path = find_file_path(`__FILE__);
    f_result = $fopen({file_path, "../../log_fifo_mig_based_tests/Test_Results_x2.txt"}, "a");

    $display("-------------------------------------");
    if (env.test_pass) begin
        $display("------------- TEST PASS -------------");
        $fdisplay(f_result, "TEST PASS");
    end else begin
        $display("------------- TEST FAIL -------------");
        $fdisplay(f_result, "TEST FAIL");
    end
    $display("-------------------------------------");

    $fclose(f_result);    
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
    .clk_ref_i              (clk_ref_i),  
    .sys_rst                (sys_rst) 
    );
assign aresetn = ~reset;

// --------------------------------------------------------------------------------------------
// модель DDR3 памяти
ddr3_model ddr3_DRAM (.*, .tdqs_n(), .cs_n(0));

endmodule
