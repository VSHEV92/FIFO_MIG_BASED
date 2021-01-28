module project_top
(
	input sys_clk, sys_rst,
	// пины DDR памяти
	output   ddr3_reset_n, ddr3_ck_p, ddr3_ck_n, ddr3_cke, ddr3_ras_n, ddr3_cas_n, ddr3_we_n, ddr3_odt,
	inout	   [1:0]  ddr3_dqs_p, ddr3_dqs_n,
	output   [2:0]  ddr3_ba,
	output   [1:0]  ddr3_dm,
	output   [13:0] ddr3_addr,
	inout    [15:0] ddr3_dq,
	// uart
	input Uart_RX,
	output Uart_TX,
	// init led
	output init_led
	);

wire ui_clk; // 100 MHz 
wire bd_reset, ui_reset, init_calib;

wire [27:0] app_addr;
wire [2:0] app_cmd;
wire app_en, app_rdy;
wire [127:0] app_wdf_data, app_rd_data;
wire [15:0] app_wdf_mask;
wire app_wdf_wren, app_wdf_end, app_wdf_rdy;
wire app_rd_data_valid, app_rd_data_end;

wire [127:0] M_AXIS_0_tdata, S_AXIS_0_tdata;
wire M_AXIS_0_tvalid, S_AXIS_0_tvalid, M_AXIS_0_tready, S_AXIS_0_tready;

assign bd_reset = ui_reset | ~init_calib;
assign init_led = init_calib;

// block design
microblaze_bd processor_bd
   (
   	.Clk(ui_clk),
   	.reset(bd_reset),
    .M_AXIS_0_tdata(M_AXIS_0_tdata),
    .M_AXIS_0_tready(M_AXIS_0_tready),
    .M_AXIS_0_tvalid(M_AXIS_0_tvalid),
    .S_AXIS_0_tdata(S_AXIS_0_tdata),
    .S_AXIS_0_tready(S_AXIS_0_tready),
    .S_AXIS_0_tvalid(S_AXIS_0_tvalid),
    .UART_0_rxd(Uart_RX),
    .UART_0_txd(Uart_TX)
    );

// MIG Fifo
Fifo_MIG_Based_0 fifi_ip (
  .aclk(ui_clk),                           
  .aresetn(~ui_reset),                      
  .init_calib(init_calib),               
  .in_tdata(M_AXIS_0_tdata),                    
  .in_tvalid(M_AXIS_0_tvalid),                  
  .in_tready(M_AXIS_0_tready),                  
  .out_tdata(S_AXIS_0_tdata),                  
  .out_tvalid(S_AXIS_0_tvalid),                
  .out_tready(S_AXIS_0_tready),                
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

// ядро MIG
mig_7series_0 MIG_inst (
    .ddr3_addr              (ddr3_addr), 
    .ddr3_ba                (ddr3_ba),  
    .ddr3_cas_n             (ddr3_cas_n),  
    .ddr3_ck_n              (ddr3_ck_n),  
    .ddr3_ck_p              (ddr3_ck_p),  
    .ddr3_cke               (ddr3_cke),  
    .ddr3_ras_n             (ddr3_ras_n),  
    .ddr3_reset_n           (ddr3_reset_n),  
    .ddr3_we_n              (ddr3_we_n),  
    .ddr3_dq                (ddr3_dq),  
    .ddr3_dqs_n             (ddr3_dqs_n),  
    .ddr3_dqs_p             (ddr3_dqs_p),  
    .init_calib_complete    (init_calib),  
    .ddr3_dm                (ddr3_dm),  
    .ddr3_odt               (ddr3_odt),  
    .app_addr               (app_addr),  
    .app_cmd                (app_cmd),  
    .app_en                 (app_en),  
    .app_wdf_data           (app_wdf_data),  
    .app_wdf_end            (app_wdf_end), 
    .app_wdf_wren           (app_wdf_wren), 
    .app_wdf_rdy            (app_wdf_rdy),  
    .app_wdf_mask           (app_wdf_mask), 
    .app_rd_data            (app_rd_data),  
    .app_rd_data_end        (app_rd_data_end),  
    .app_rd_data_valid      (app_rd_data_valid),  
    .app_rdy                (app_rdy),  
    .app_sr_req             (0), 
    .app_ref_req            (0),  
    .app_zq_req             (0), 
    .ui_clk                 (ui_clk),  
    .ui_clk_sync_rst        (ui_reset),   
    .sys_clk_i              (sys_clk), 
    .sys_rst                (sys_rst) 
);

endmodule
