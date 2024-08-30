module tb_asyn_fifo;

  // Parameters
  parameter DATA_WIDTH = 8;
  parameter FIFO_DEPTH = 8;
  parameter ADDRESS_SIZE = 4;

  // Testbench signals
  reg wr_clk;
  reg rd_clk;
  reg rst;
  reg wr;
  reg rd;
  reg [DATA_WIDTH-1:0] wdata;
  wire [DATA_WIDTH-1:0] rdata;
  wire full;
  wire empty;
  wire valid;
  wire overflow;
  wire underflow;
  int i;
  // Instantiate the FIFO module
  asyn_fifo #(
    .data_width(DATA_WIDTH),
    .fifo_depth(FIFO_DEPTH)
  ) uut (.wr_clk(wr_clk),.rd_clk(rd_clk),.rst(rst),.wr(wr),.rd(rd), .wdata(wdata),.rdata(rdata),.valid(valid),.empty(empty),.full(full),.overflow(overflow),.underflow(underflow) );

  // Clock generation
  initial begin
    wr_clk = 0;
    rd_clk = 0;
    forever begin
      #5 wr_clk = ~wr_clk; // 100 MHz write clock
    end
  end

  initial begin
    forever begin
      #7 rd_clk = ~rd_clk; // 71.4 MHz read clock
    end
  end

  // Test sequence
  initial begin
    // Initialize signals
    rst = 1;
    wr = 0;
    rd = 0;
    wdata = 0;

    // Reset the FIFO
    #10;
    rst = 0;

    // Write data into FIFO
    #10;
    wr = 1;
    wdata = 8'hAA;  // Write value 0xAA
    #10;
    wr = 0;

    // Check for valid data and read it
    #20;
    rd = 1;
    #10;
    rd = 0;

    // Continue writing and reading data
    #10;
    wr = 1;
    wdata = 8'hBB;  // Write value 0xBB
    #10;
    wr = 0;

    #20;
    rd = 1;
    #10;
    rd = 0;

    // Test overflow condition
    // Fill the FIFO

    for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
      #10;
      wr = 1;
      wdata = i;
    end
    #10;
    wr = 0;

    // Try to write more data and check overflow
    #10;
    wr = 1;
    wdata = 8'hFF;  // Should cause overflow
    #10;
    wr = 0;

    // Read all data out
    #10;
    for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
      rd = 1;
      #10;
      rd = 0;
    end

    // Check underflow
    #10;
    rd = 1;  // Should cause underflow
    #10;
    rd = 0;

    // Finish simulation
    #50;
    $finish;
  end

  // Monitor outputs
  initial begin
    $monitor("Time: %0t | wr_clk: %b | rd_clk: %b | rst: %b | wr: %b | rd: %b | wdata: %h | rdata: %h | full: %b | empty: %b | valid: %b | overflow: %b | underflow: %b",
             $time, wr_clk, rd_clk, rst, wr, rd, wdata, rdata, full, empty, valid, overflow, underflow);
  end

endmodule