module FIFO(
    input clk,
    input rst,
    input clear,
    input WEn,
    input REn,
    input [31:0] DI,
    output logic [31:0] DO,
    output logic full,
    output logic empty

);
    logic [31:0] mem[15:0];
    // logic [3:0] R_ptr, W_ptr, W_ptr1;
    logic [3:0] R_ptr, W_ptr;
    integer i;

    assign DO    = mem[R_ptr];
    // assign full  = W_ptr1 == R_ptr;
    assign full  = (W_ptr + 4'b1) == R_ptr;
    assign empty = W_ptr  == R_ptr;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)begin
            for (i = 0; i < 16 ; i = i + 1)
                mem[i] <= 32'h0;
        end
        else if (clear) begin
            for (i = 0; i < 16 ; i = i + 1)
                mem[i] <= 32'h0;
        end
        else if (WEn && ~full)
            mem[W_ptr] <= DI;
    end
    always_ff @(posedge clk or posedge rst) begin
        if (rst)begin
            W_ptr  <= 4'b0;
            // W_ptr1 <= 4'b1;
            R_ptr  <= 4'b0;
        end
        else if (clear) begin
            W_ptr  <= 4'b0;
            // W_ptr1 <= 4'b1;
            R_ptr  <= 4'b0;
            
        end
        else begin
            W_ptr  <= W_ptr  + (~full && WEn);
            // W_ptr1 <= W_ptr1 + (~full && WEn); 
            R_ptr  <= R_ptr  + (~empty && REn);
        
        end

    end




    

endmodule