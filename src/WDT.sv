
module WDT (
    input clk, // system clock
    input rst, // active high
    input clk2, // WDT clock
    input rst2, // WDT reset, active high
    input WDEN, // enable
    input WDLIVE, // restart WDT
    input [31:0] WTOCNT, // WDT timeout count
    
    output logic WTO // WDT timeout
);

logic [31:0] counter_reg;
logic [31:0] counter_comb;

logic WTO_comb;

always_ff @( posedge clk2 or posedge rst2 ) begin : WDT_counter
    if (rst2) begin
        counter_reg <= 32'b0;
    end
    else begin
        counter_reg <= counter_comb;
    end
end

always_comb begin : WDT_counter_comb
    counter_comb = 32'b0;
    if (WDEN) begin // WDT active
        if (WDLIVE) begin
            counter_comb = 32'b0;
        end
        else if (counter_reg > WTOCNT) begin
            // counter_comb = counter_reg;
            counter_comb = 32'b0;
            // if (WTO) begin
            //     counter_comb = 32'b0;
            // end
        end
        else begin
            counter_comb = counter_reg + 32'b1;
        end
    end
end

always_ff @( posedge clk2 or posedge rst2 ) begin : WTO_output
    if (rst2) begin
        WTO <= 1'b0;
    end
    else begin
        WTO <= WTO_comb;
    end
end

always_comb begin : WTO_control
    WTO_comb = 1'b0;
    if (WDEN) begin
        WTO_comb = 1'b0;
        if (counter_reg > WTOCNT) begin
            WTO_comb = 1'b1;
        end
    end
end

endmodule