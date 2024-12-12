module CSR_counter (
    input rst,
    input clk,

    input IM_stall,
    input DM_stall,
    input WFI_stall,

    // input [1:0] branch_ctrl, // from branch control
    input [1:0] IF_ID_reg_ctrl, // from hazard control
    input [1:0] CSR_type, // from EXE

    // output logic [63:0] CSR_cycle_counter, // to EXE
    // output logic [63:0] CSR_instr_counter  // to EXE
    output logic [31:0] CSR_output // to EXE
);

logic [63:0] CSR_cycle_counter;
logic [63:0] CSR_instr_counter;
logic [63:0] CSR_cycle_counter_comb;
logic [63:0] CSR_instr_counter_comb;

always_ff @( posedge clk or posedge rst ) begin : counter_reg
    if (rst) begin
        CSR_cycle_counter <= 64'b0;
        CSR_instr_counter <= 64'b0;
    end
    else begin
        CSR_cycle_counter <= CSR_cycle_counter_comb;
        CSR_instr_counter <= CSR_instr_counter_comb;
    end
end

always_comb begin : counter_comb
    if(rst) begin
        CSR_cycle_counter_comb = 64'b0;
        CSR_instr_counter_comb = 64'b0;
    end
    else begin
        CSR_cycle_counter_comb = CSR_cycle_counter + 64'b1;
        CSR_instr_counter_comb = CSR_instr_counter;
        if (CSR_cycle_counter > 64'd4) begin // in EXE stage
            case (IF_ID_reg_ctrl) 
                2'b00: CSR_instr_counter_comb = CSR_instr_counter + 64'b1;
                2'b01: CSR_instr_counter_comb = CSR_instr_counter;
                2'b10: CSR_instr_counter_comb = CSR_instr_counter - 64'b1;
            endcase
            if (IM_stall | DM_stall | WFI_stall) begin
                CSR_instr_counter_comb = CSR_instr_counter;
            end
        end
        // case (branch_ctrl)
        //     2'b00: begin
        //         CSR_instr_counter_comb = CSR_instr_counter + 1;
        //     end 
        //     2'b01,
        //     2'b10: begin
        //         CSR_instr_counter_comb = CSR_instr_counter - 1;
        //     end
        // endcase        
    end
end

always_comb begin : CSR_out
    if (rst) begin
        CSR_output = 32'b0;
    end
    else begin
        CSR_output = 32'b0;
        case (CSR_type)
            2'b00: begin
                CSR_output = CSR_instr_counter[63:32];
            end 
            2'b01: begin
                CSR_output = CSR_instr_counter[31:0];
            end 
            2'b10: begin
                CSR_output = CSR_cycle_counter[63:32];
            end 
            2'b11: begin
                CSR_output = CSR_cycle_counter[31:0];
            end 
        endcase
    end
end

endmodule