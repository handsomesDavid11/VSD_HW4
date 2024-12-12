module Forwarding_Unit (
    input rst,
    // from EXE
    // input [4:0] EXE_frs1_addr,
    // input [4:0] EXE_frs2_addr,
    input [4:0] EXE_rs1_addr,
    input [4:0] EXE_rs2_addr,
    // from MEM
    input MEM_f_reg_write,
    input MEM_reg_write,
    input [4:0] MEM_rd_addr,
    // from WB
    input [4:0] WB_rd_addr,
    input WB_f_reg_write,
    input WB_reg_write,
    // to EXE
    output logic [1:0] forward_frs1_src, // 0: ID, 1:MEM, 2: WB
    output logic [1:0] forward_frs2_src, // 0: ID, 1:MEM, 2: WB
    output logic [1:0] forward_rs1_src, // 0: ID, 1: MEM, 2: WB
    output logic [1:0] forward_rs2_src // 0: ID, 1: MEM, 2: WB
);
    
always_comb begin : forwarding_unit
//     if (rst) begin
//         forward_rs1_src = 0;
//         forward_rs2_src = 0;
//    end    
//     else begin
        forward_rs1_src = 2'b0;
        forward_rs2_src = 2'b0;
        // rs1 src
        if (MEM_reg_write && EXE_rs1_addr == MEM_rd_addr) begin
            forward_rs1_src = 2'b01;
        end
        else if (WB_reg_write && EXE_rs1_addr == WB_rd_addr) begin
            forward_rs1_src = 2'b10;
        end
        // rs2 src
        if (MEM_reg_write && EXE_rs2_addr == MEM_rd_addr) begin
            forward_rs2_src = 2'b01;
        end
        else if (WB_reg_write && EXE_rs2_addr == WB_rd_addr) begin
            forward_rs2_src = 2'b10;
        end
    // end
end

always_comb begin : floating_forwarding_unit
    forward_frs1_src = 2'b0;
    forward_frs2_src = 2'b0;
    // rs1 src
    if (MEM_f_reg_write && EXE_rs1_addr == MEM_rd_addr) begin
        forward_frs1_src = 2'b01;
    end
    else if (WB_f_reg_write && EXE_rs1_addr == WB_rd_addr) begin
        forward_frs1_src = 2'b10;
    end
    // rs2 src
    if (MEM_f_reg_write && EXE_rs2_addr == MEM_rd_addr) begin
        forward_frs2_src = 2'b01;
    end
    else if (WB_f_reg_write && EXE_rs2_addr == WB_rd_addr) begin
        forward_frs2_src = 2'b10;
    end
end
endmodule