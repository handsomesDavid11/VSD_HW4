module WB (
    input rst,

    input [31:0] rd_data, // from MEM
    input [31:0] DM_data_out, // from MEM
    input mem_2_reg_src, // from MEM

    input [4:0] rd_addr_in, // from MEM
    input reg_write_in, // from MEM

    // floating
    input f_reg_write_in, // from MEM
    input [31:0] f_alu_result, // from MEM

    output logic f_reg_write, // to floating RF
    output logic [31:0] frd_data, // to floating RF
    output logic [31:0] WB_rd_data, // to RF & MEM & EXE, comb
    output logic [4:0] WB_rd_addr, // to RF & forwarding unit, comb
    output logic reg_write // to RF & forwarding unit, comb
);

always_comb begin : WB_logic
    // if (rst) begin
    //     WB_rd_data = 0;
    //     WB_rd_addr = 0;
    //     reg_write = 0;
    // end
    // else begin
        WB_rd_data = 32'b0;
        WB_rd_addr = rd_addr_in;
        reg_write = reg_write_in;
        f_reg_write = f_reg_write_in;
        case (mem_2_reg_src)
            1'b0: WB_rd_data = DM_data_out;
            1'b1: WB_rd_data = rd_data;
            // 1: WB_rd_data = (f_reg_write_in) ? f_alu_result : rd_data;
        endcase
        case (mem_2_reg_src)
            1'b0: frd_data = DM_data_out; 
            1'b1: frd_data = f_alu_result;
        endcase
    // end
end
    
endmodule