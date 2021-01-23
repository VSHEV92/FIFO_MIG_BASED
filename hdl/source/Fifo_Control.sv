module Fifo_Control
#(
    parameter PHY_to_UI_Rate = 1, // 1 - X4, 2 - X2
    parameter Max_Burst_Len = 64,
    parameter RW_Delay_Value = 4,
    parameter Base_Address = 0,
    parameter Memory_Size = 100,
    parameter MIG_Data_Port_Size = 128,
    parameter MIG_Addr_Port_Size = 28,
    parameter IO_Fifo_Depth = 32
)
(
    input logic aclk,
    input logic aresetn,
    input logic init_calib,
    // входной AXIS интерфейс
    input  logic [(MIG_Data_Port_Size*PHY_to_UI_Rate-1):0] in_tdata,
    input  logic in_tvalid,
    output logic in_tready,
    input  logic [31:0] in_wr_count,
    // выходной AXIS интерфейс
    output logic [(MIG_Data_Port_Size*PHY_to_UI_Rate-1):0] out_tdata,
    output logic out_tvalid,
    input  logic out_tready,
    input  logic [31:0] out_rd_count,
    // Native Interface MIG
    output logic [MIG_Addr_Port_Size-1:0] app_addr,
    output logic [2:0] app_cmd,
    output logic app_en,
    input  logic app_rdy,
    output logic [MIG_Data_Port_Size-1:0] app_wdf_data,
    output logic app_wdf_wren,
    output logic app_wdf_end,
    input  logic app_wdf_rdy,
    input  logic [MIG_Data_Port_Size-1:0] app_rd_data,
    input  logic app_rd_data_valid,
    input  logic app_rd_data_end
);

// максимальный адрес памяти
localparam Max_Address = Base_Address + (Memory_Size - 1) * 8;

// вычисление минимального значения
function automatic logic [31:0] min_func (logic [31:0] mem_space, logic [31:0] fifo_space);
    logic [31:0] min_val;
    if (mem_space > fifo_space)
        min_val = fifo_space;
    else
        min_val = mem_space;

    if (min_val > Max_Burst_Len)
        min_val = Max_Burst_Len;

    return min_val;
endfunction 

// состояния конечного автомата
enum {INIT, CHECK_WR, CHECK_RD, WRITE, READ, DELAY_WR, DELAY_RD} State;

logic [31:0] out_Rd_space;

logic [MIG_Data_Port_Size-1:0] Data_H;
logic WR_X2_Flag;

logic [31:0] Mem_Wr_Addr, Mem_Rd_Addr;         // адрес записи и чтения
logic [31:0] Wr_Addr_Counter, Rd_Addr_Counter; // счетчик оставшихся команд для записи и чтения
logic [31:0] Wr_Counter, Rd_Counter;           // счетчик оставшихся данных для записи и чтения
logic [31:0] Mem_Wr_Counter, Mem_Rd_Counter;   // число слов и свободных мест в памяти
logic [7:0]  Delay_Counter;

logic [31:0] wr_count_load, rd_count_load;
// ---------------------------------------------------------------------------------
// входной AXIS интерфейс
assign in_tready = (State == WRITE) & app_wdf_rdy & app_wdf_end;

// ---------------------------------------------------------------------------------
// выходной AXIS интерфейс
assign out_Rd_space = IO_Fifo_Depth - out_rd_count; // число мест в выходном Fifo
generate
    // режим X4
    if (PHY_to_UI_Rate == 1) begin
        assign out_tdata = app_rd_data;
        assign out_tvalid = (State == READ) & app_rd_data_valid; 
    end
    // режим X2
    else begin
        always_ff @(posedge aclk)
            if ((State == READ) && app_rd_data_valid)
                Data_H <= app_rd_data;

        assign out_tdata = {Data_H, app_rd_data};
        assign out_tvalid = (State == READ) & app_rd_data_valid & app_rd_data_end;    
    end    
endgenerate

// ---------------------------------------------------------------------------------
// app cmd интерфейс
assign app_addr = (State == WRITE) ? Mem_Wr_Addr : Mem_Rd_Addr;
assign app_cmd = (State == WRITE) ? 0 : 1;
assign app_en = ((State == WRITE) & (Wr_Counter < Wr_Addr_Counter)) | ((State == READ) & (Rd_Addr_Counter > 0));

// ---------------------------------------------------------------------------------
// app write интерфейс
generate
    // режим X4
    if (PHY_to_UI_Rate == 1) begin
        assign app_wdf_data = in_tdata;
        assign app_wdf_wren = (State == WRITE) & (Wr_Counter > 0);
        assign app_wdf_end = (State == WRITE) & (Wr_Counter > 0); 
    end
    // режим X2
    else begin
        always_ff @(posedge aclk)
            if (!aresetn)
                WR_X2_Flag <= 0;
            else if (app_wdf_rdy && (State == WRITE))
                WR_X2_Flag <= ~WR_X2_Flag;

        assign app_wdf_data = (WR_X2_Flag) ? in_tdata[MIG_Data_Port_Size-1:0] : in_tdata[2*MIG_Data_Port_Size-1:MIG_Data_Port_Size];
        assign app_wdf_wren = (State == WRITE) & (Wr_Counter > 0);
        assign app_wdf_end = (State == WRITE) & WR_X2_Flag & (Wr_Counter > 0);                   
    end     
endgenerate

// ---------------------------------------------------------------------------------
// конечный автомат
always_ff @(posedge aclk) begin : fsm_block
    if(!aresetn)
        State <= INIT;
    else 
        unique case (State) 
        INIT :      // ожидание инициализации памяти
            State <= (init_calib) ? CHECK_WR : INIT;
        CHECK_WR :  // проверка возможности записи 
            State <= (Mem_Wr_Counter && in_wr_count) ? WRITE : CHECK_RD;
        CHECK_RD :  // проверка возможности чтения 
            State <= (Mem_Rd_Counter && out_Rd_space) ? READ : CHECK_WR;
        WRITE:      // запись в память
            State <= ((Wr_Addr_Counter == 1) && (Wr_Counter == 0) && app_rdy) ? DELAY_WR : WRITE;
        READ:       // чтение в память
            State <= ((Rd_Counter == 1) && app_rd_data_valid && app_rd_data_end) ? DELAY_RD : READ;
        DELAY_WR :  // задержка после записи
            State <= (Delay_Counter == 0) ? CHECK_RD : DELAY_WR;
        DELAY_RD :  // задержка после чтения
            State <= (Delay_Counter == 0) ? CHECK_WR : DELAY_RD;
        endcase                           
end

// ---------------------------------------------------------------------------------
// счетчик числа слов для записи
assign wr_count_load = min_func(Mem_Wr_Counter, in_wr_count);
always_ff @(posedge aclk)
    if (State == CHECK_WR)
        Wr_Counter <= wr_count_load;
    else if (app_wdf_end && app_wdf_rdy)
        Wr_Counter <= Wr_Counter - 1;

// счетчик команд для записи
always_ff @(posedge aclk)
    if (State == CHECK_WR)
        Wr_Addr_Counter <= wr_count_load;
    else if ((State == WRITE) && app_rdy && app_en)
        Wr_Addr_Counter <= Wr_Addr_Counter - 1;

// ---------------------------------------------------------------------------------
// счетчик числа слов для чтения
assign rd_count_load = min_func(Mem_Rd_Counter, out_Rd_space);
always_ff @(posedge aclk)
    if (State == CHECK_RD)
        Rd_Counter <= rd_count_load;
    else if (app_rd_data_valid && app_rd_data_end)
        Rd_Counter <= Rd_Counter - 1;

// счетчик команд для чтения
always_ff @(posedge aclk)
    if (State == CHECK_RD)
        Rd_Addr_Counter <= rd_count_load;
    else if ((State == READ) && app_rdy && app_en)
        Rd_Addr_Counter <= Rd_Addr_Counter - 1;

// ---------------------------------------------------------------------------------
// счетчик адресов записи
always_ff @(posedge aclk)
    if(!aresetn)
        Mem_Wr_Addr <= Base_Address;
    else if ((State == WRITE) && app_en && app_rdy) begin
        Mem_Wr_Addr <= Mem_Wr_Addr + 8;
        if (Mem_Wr_Addr == Max_Address)
            Mem_Wr_Addr <= Base_Address;
    end

// ---------------------------------------------------------------------------------
// счетчик адресов чтения
always_ff @(posedge aclk)
    if(!aresetn)
        Mem_Rd_Addr <= Base_Address;
    else if ((State == READ) && app_rdy && app_en) begin
        Mem_Rd_Addr <= Mem_Rd_Addr + 8;
        if (Mem_Rd_Addr == Max_Address)
            Mem_Rd_Addr <= Base_Address;
    end

// ---------------------------------------------------------------------------------
// счетчик числа свободных мест в памяти
always_ff @(posedge aclk)
    if(!aresetn)
        Mem_Wr_Counter <= Memory_Size;
    else if (app_wdf_end && app_wdf_rdy)
        Mem_Wr_Counter <= Mem_Wr_Counter - 1;
    else if (app_rd_data_end && app_rd_data_valid)
        Mem_Wr_Counter <= Mem_Wr_Counter + 1;

// ---------------------------------------------------------------------------------
// счетчик числа слов в памяти
always_ff @(posedge aclk)
    if(!aresetn)
        Mem_Rd_Counter <= 0;
    else if (app_wdf_end && app_wdf_rdy)
        Mem_Rd_Counter <= Mem_Rd_Counter + 1;
    else if (app_rd_data_end && app_rd_data_valid)
        Mem_Rd_Counter <= Mem_Rd_Counter - 1;

// ---------------------------------------------------------------------------------
// счетчик задержки после записи или считывания       
always_ff @(posedge aclk)
    if ((State == READ) || (State == WRITE))
        Delay_Counter <= RW_Delay_Value;
    else if ((State == DELAY_RD) || (State == DELAY_WR))
        Delay_Counter <= Delay_Counter - 1;

endmodule
