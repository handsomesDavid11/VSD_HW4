module Hazard_Ctrl (
    input rst,

    input [1:0] branch_control, // from branch control
    input timer_interrupt_flag, // from WDT

    input [4:0] rs1_addr, // from ID
    input [4:0] rs2_addr, // from ID
    input [4:0] EXE_rd_addr, // from EXE
    input EXE_mem_read, // from EXE

    output logic pc_write, // to IF-PC
    output logic [1:0] IF_ID_reg_ctrl, // to IF, 0: normal, 1: keep, 2: clear
    output logic ID_EXE_reg_ctrl // to ID, 0: normal, 1: keep, 2: clear
);

always_comb begin : hazard_control
    // if (rst) begin
    //     pc_write = 0;
    //     IF_ID_reg_ctrl = 0;
    //     ID_EXE_reg_ctrl = 0;
    // end
    // else begin
        pc_write = 1'b0;
        IF_ID_reg_ctrl = 2'b0;
        ID_EXE_reg_ctrl = 1'b0;
        if (timer_interrupt_flag) begin
            IF_ID_reg_ctrl = 2'b10;
            ID_EXE_reg_ctrl = 1'b1;
        end
        else if (branch_control != 2'b0) begin // branch
            IF_ID_reg_ctrl = 2'b10;
            // ID_EXE_reg_ctrl = 2'b10;
            ID_EXE_reg_ctrl = 1'b1;
        end
        else if (EXE_mem_read) begin // RAW, load-use
            if (EXE_rd_addr == rs1_addr || EXE_rd_addr == rs2_addr) begin
                pc_write = 1'b1;
                IF_ID_reg_ctrl = 2'b01;
                // ID_EXE_reg_ctrl = 2'b01;
                // ID_EXE_reg_ctrl = 2'b10;
                ID_EXE_reg_ctrl = 1'b1;
            end
        end
    // end
end
    
endmodule