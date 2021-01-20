module Fifo_MIG_Based
#(
    parameter PHY_to_UI_Rate = 1, // 1 - X4, 2 - X2
    parameter Max_Burst_Len = 16,
    parameter RW_Delay_Value = 4,
    parameter Base_Address = 0,
    parameter Memory_Size = 100,
    parameter MIG_Data_Port_Size = 128,
    parameter MIG_Addr_Port_Size = 28,
    parameter IO_Fifo_Depth = 32
)
(
    input aclk,
    input aresetn,
    input init_calib,
    // входной AXIS интерфейс
    input  [(MIG_Data_Port_Size*PHY_to_UI_Rate-1):0] in_tdata,
    input  in_tvalid,
    output in_tready,
    // выходной AXIS интерфейс
    output [(MIG_Data_Port_Size*PHY_to_UI_Rate-1):0] out_tdata,
    output out_tvalid,
    input  out_tready,
    // Native Interface MIG
    output [MIG_Addr_Port_Size-1:0] app_addr,
    output [2:0] app_cmd,
    output app_en,
    input  app_rdy,
    output [MIG_Data_Port_Size-1:0] app_wdf_data,
    output app_wdf_wren,
    output app_wdf_end,
    input  app_wdf_rdy,
    input  [MIG_Data_Port_Size-1:0] app_rd_data,
    input  app_rd_data_valid,
    input  app_rd_data_end
);

// сигналы слединения IO Fifo и блока управления памятью 
wire [(MIG_Data_Port_Size*PHY_to_UI_Rate-1):0] ififo_tdata;
wire ififo_tvalid;
wire ififo_tready;
wire [(MIG_Data_Port_Size*PHY_to_UI_Rate-1):0] ofifo_tdata;
wire ofifo_tvalid;
wire ofifo_tready;    

wire [31:0] in_wr_count;
wire [31:0] out_rd_count;
        
// блок управления памятью
Fifo_Control 
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
Fifo_Control_Inst
(
	.aclk(aclk),
    .aresetn(aresetn),
    .init_calib(init_calib),
    // входной AXIS интерфейс
    .in_tdata(ififo_tdata),
    .in_tvalid(ififo_tvalid),
    .in_tready(ififo_tready),
    .in_wr_count(in_wr_count),
    // выходной AXIS интерфейс
    .out_tdata(ofifo_tdata),
    .out_tvalid(ofifo_tvalid),
    .out_tready(ofifo_tready),
    .out_rd_count(out_rd_count),
    // Native Interface MIG
    .app_addr(app_addr),
    .app_cmd(app_cmd),
    .app_en(app_en),
    .app_rdy(app_rdy),
    .app_wdf_data(app_wdf_data),
    .app_wdf_wren(app_wdf_wren),
    .app_wdf_end(app_wdf_end),
    .app_wdf_rdy(app_wdf_rdy),
    .app_rd_data(app_rd_data),
    .app_rd_data_valid(app_rd_data_valid),
    .app_rd_data_end(app_rd_data_end)
);

// выходные и выходные Fifo
fifo_32x128 ififo (
  .s_axis_aresetn(aresetn),  
  .s_axis_aclk(aclk),        
  .s_axis_tvalid(in_tvalid),   
  .s_axis_tready(in_tready),   
  .s_axis_tdata(in_tdata),      
  .m_axis_tvalid(ififo_tvalid),   
  .m_axis_tready(ififo_tready),   
  .m_axis_tdata(ififo_tdata),
  .axis_wr_data_count(in_wr_count)      
);

fifo_32x128 ofifo (
  .s_axis_aresetn(aresetn),  
  .s_axis_aclk(aclk),        
  .s_axis_tvalid(ofifo_tvalid),   
  .s_axis_tready(ofifo_tready),   
  .s_axis_tdata(ofifo_tdata),      
  .m_axis_tvalid(out_tvalid),   
  .m_axis_tready(out_tready),   
  .m_axis_tdata(out_tdata),
  .axis_wr_data_count(out_rd_count)      
);

endmodule
