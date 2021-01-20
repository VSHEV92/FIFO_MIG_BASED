// ---------------------------------------------------
// --------------  AXIS интерфейс  -------------------
// ---------------------------------------------------
interface AXIS_intf
    #(
        parameter int TDATA_WIDTH = 128;
    )
    (
        input logic aclk,
        input logic aresetn 
    );

    logic tready;
    logic tvalid;
    logic [TDATA_WIDTH-1:0] tdata;
    
    modport Master (
        input  aclk, aresetn,
        output tdata, tvalid,
        input  tready
    );

    modport Slave (
        input  aclk, aresetn,
        input  tdata, tvalid,
        output tready
    );

    //-------------------------------------------------------------------------------------
    // принимает данные по axis и передает их mailbox
    task automatic put_to_mailbox(ref mailbox mb);
        tready = 1'b0;
        wait (aresetn);
        @(posedge aclk)
        // если данные валидны, устанавливаем tready в 1
        if(tvalid)
            tready = 1'b1;
        // на следующем такте забираем данные в mailbox
        @(posedge aclk)
        mb.put(tdata);
        tready = 1'b0;        
    endtask
    
    //-------------------------------------------------------------------------------------
    // принимает данные из mailbox и передает их по axis  
    task automatic get_forever_from_mailbox(ref mailbox mb);
        logic [TDATA_WIDTH-1:0] data = 'b0;
        bit new_data = 1'b0; // флаг новых данных на линии
        tvalid = 1'b0;
        wait (aresetn);
        @(posedge aclk)        
        if (!new_data) // получаем новые данные и выставляем из на линию
            if(data_mb.try_get(data)) begin
                new_data = 1'b1;
                tvalid <= 1'b1;
                tdata <= data;
            end else
                tvalid <= 1'b0;
        else // иначе, если tready равен единице, говорим, что данные получены
            if(tready)  
                new_data = 1'b0;           
    endtask

endinterface
    