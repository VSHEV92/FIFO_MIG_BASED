// ---------------------------------------------------
// --------------  AXIS интерфейс  -------------------
// ---------------------------------------------------
interface AXIS_intf
    #(
        parameter int TDATA_WIDTH = 128
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

    // //-------------------------------------------------------------------------------------
    // // принимает данные по axis и передает их mailbox
    // task automatic put_to_mailbox(ref mailbox mb);
    //     tready = 1'b0;
    //     wait (aresetn);
    //     @(posedge aclk)
    //     // если данные валидны, устанавливаем tready в 1
    //     if(tvalid)
    //         tready = 1'b1;
    //     // на следующем такте забираем данные в mailbox
    //     @(posedge aclk)
    //     mb.put(tdata);
    //     tready = 1'b0;        
    // endtask

endinterface

// ---------------------------------------------------
// -----------------  Транзакция  --------------------
// ---------------------------------------------------
class Transaction
#(
    TDATA_WIDTH = 128   // размер шины данных
);
    rand logic [TDATA_WIDTH-1:0] data;
    int unsigned count;

    // выдача данных транзакции
    function logic [TDATA_WIDTH-1:0] get_data();
        return data;        
    endfunction

    // увеличить счетчик транзакций
    function void count_inc();
        count++;    
    endfunction    
    
    // запись в лог 
    function void print(string tag="");
        $display("%s: time = %t, transaction number = %d, value = %h", tag, $time, count, data);
    endfunction

endclass

// ---------------------------------------------------
// --------------  Генератор данных  -----------------
// ---------------------------------------------------
class Generator
#(
    TDATA_WIDTH = 128,   // размер шины данных
    MAX_DELAY_NS = 100  // максимальная задержка в нс
);
    int unsigned delay; // случайная задержка генератор
    Transaction #(TDATA_WIDTH) trans;
    
    mailbox mb_driver;
    mailbox mb_scoreboard;

    event dr_done;
    
    //конструктор класс
    function new();
        trans = new;
    endfunction

    // передача случайных данных в mailbox
    task send_data_to_mb();
        trans.randomize();
        trans.count_inc();
        delay = $urandom_range(0, MAX_DELAY_NS);
        # delay; // случайная задержка
        mb_driver.put(trans);
        mb_scoreboard.put(trans);
        trans.print("Generator");
        @(dr_done);       
    endtask

    // создать заданное число транзакций
    task run(input int trans_numb);
        repeat (trans_numb) 
            send_data_to_mb();
    endtask

endclass    

// ---------------------------------------------------
// ------------------  Драйвер  ----------------------
// ---------------------------------------------------
class Driver
#(
    TDATA_WIDTH = 128   // размер шины данных
);
    mailbox mb_driver;
    Transaction #(TDATA_WIDTH) trans;
    virtual AXIS_intf axis;
    event dr_done;
    //конструктор класс
    function new();
        trans = new;
    endfunction

    // принимает данные из mailbox и передает их по axis  
    task run();
        axis.tvalid = 1'b0;
        forever begin
            wait (axis.aresetn);
            @(posedge axis.aclk)        
            axis.tvalid <= 1'b0;
            if(mb_driver.try_get(trans)) begin // пробеум получить данные
                axis.tvalid <= 1'b1;
                axis.tdata <= trans.get_data();
                wait(axis.tready);  // если данные получены, ждем установки tready 
                trans.print("Driver");
                -> dr_done;   
            end            
        end        
    endtask

endclass

// ---------------------------------------------------
// ------------  Тестовое окружение  -----------------
// ---------------------------------------------------
class Environment
#(
    TDATA_WIDTH = 128   // размер шины данных
);
    Generator #(TDATA_WIDTH) gen;
    Driver #(TDATA_WIDTH) dr;

    mailbox mb_driver;
    mailbox mb_scoreboard;
    mailbox mb_monitor;

    event dr_done;

    virtual AXIS_intf axis_in;
    virtual AXIS_intf axis_out;
    // конструктор класса
    function new ();
        mb_driver = new();
        mb_scoreboard = new();
        mb_monitor = new();
        gen = new();
        dr = new();
    endfunction 

    // запуск тестового окружения
    task run(int unsigned trans_numb);
        dr.axis = axis_in;
        dr.mb_driver = mb_driver;
        dr.dr_done = dr_done;

        gen.mb_driver = mb_driver;
        gen.mb_scoreboard = mb_scoreboard;
        gen.dr_done = dr_done;
        


        fork
            gen.run(trans_numb);
            dr.run();
        join    
    endtask
endclass