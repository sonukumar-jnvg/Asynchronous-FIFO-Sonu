// Code your design here
module asyn_fifo (wr_clk,rd_clk,rst,wr,rd,wdata, rdata,full,empty,valid,overflow,underflow);

    parameter data_width = 8;     // Data width
    parameter fifo_depth = 8;     // Depth of FIFO
    parameter address_size = 4;   // Address size for FIFO
    input wire wr_clk;       // Write clock
    input wire rd_clk;       // Read clock
    input wire rst;          // Reset
    input wire wr;           // Write enable
    input wire rd;          // Read enable
    output wire full;        // FIFO full flag
    output wire empty;       // FIFO empty flag
    output wire valid;       // Read valid flag
    output reg overflow;     // Overflow flag
    output reg underflow;
  input wire [data_width-1:0] wdata; // Write data
  output reg [data_width-1:0] rdata;
    // Internal signals
    reg [address_size-1:0] wr_pointer;
    reg [address_size-1:0] rd_pointer;
    reg [address_size-1:0] wr_pointer_sync1, wr_pointer_sync2;
    reg [address_size-1:0] rd_pointer_sync1, rd_pointer_sync2;
    reg [data_width-1:0] fifo_mem [fifo_depth-1:0]; // FIFO memory
    // Write logic
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_pointer <= 0;
            overflow <= 0;
        end else begin
            if (wr && !full) begin
                fifo_mem[wr_pointer] <= wdata;
                wr_pointer <= wr_pointer + 1;
            end
            // Check for overflow
            if (wr && full) begin
                overflow <= 1;
            end else begin
                overflow <= 0;
            end
        end
    end

    // Read logic
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_pointer <= 0;
            underflow <= 0;
            rdata <= 0;
        end else begin
            if (rd && !empty) begin
                rdata <= fifo_mem[rd_pointer];
                rd_pointer <= rd_pointer + 1;
            end
            // Check for underflow
            if (rd && empty) begin
                underflow <= 1;
            end else begin
                underflow <= 0;
            end
        end
    end

    // Synchronize write pointer to read clock domain
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_pointer_sync1 <= 0;
            wr_pointer_sync2 <= 0;
        end else begin
            wr_pointer_sync1 <= wr_pointer;
            wr_pointer_sync2 <= wr_pointer_sync1;
        end
    end

    // Synchronize read pointer to write clock domain
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_pointer_sync1 <= 0;
            rd_pointer_sync2 <= 0;
        end else begin
            rd_pointer_sync1 <= rd_pointer;
            rd_pointer_sync2 <= rd_pointer_sync1;
        end
    end

    // Full and empty flags
    assign empty = (rd_pointer_sync2 == wr_pointer_sync2);
    assign full = (wr_pointer_sync2[address_size-1] != rd_pointer_sync2[address_size-1])
                && (wr_pointer_sync2[address_size-2] != rd_pointer_sync2[address_size-2])
                && (wr_pointer_sync2[address_size-3] != rd_pointer_sync2[address_size-3]);

    // Valid flag
    assign valid = !empty && rd;

endmodule

