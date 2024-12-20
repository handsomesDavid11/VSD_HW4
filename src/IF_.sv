module IF_ (
    input clk,
    input rst,

    output logic IM_MEM_access,
    input IM_stall,
    input DM_stall,
    input WFI_stall,
    input timer_interrupt_flag,
    input external_interrupt_flag,

    input MRET_flag, // make PC <= mepc
    input [31:0] mepc_out, // interrupt return PC
    input [31:0] mtvec_out, // Interrupt service routine PC

    input [1:0] branch_ctrl,
    input [31:0] pc_imm_rs1,
    input [31:0] pc_imm,
    input pc_write,
    input [1:0] IF_ID_reg_ctrl, // 0: normal, 1: keep, 2: clear

    input [31:0] inst, //from IM

    output logic [31:0] pc_out, // to ID
    output logic [31:0] inst_out, // to ID

    // output logic [13:0] pc_2_IM // to IM, comb
    output logic [31:0] pc_2_IM // to IM, comb
);

logic [31:0] pc_out_comb;
logic [31:0] pc_reg_comb;
logic [31:0] pc_reg;
// logic [31:0] inst;
logic [31:0] inst_out_comb;

// SRAM_wrapper IM1(
// 	.CK	(clk),
// 	.CS	(1'b1),
// 	.OE	(1'b1),
// 	.WEB(4'b1111),
// 	.A	(pc_out_comb[15:2]),
// 	.DI	(0),
// 	.DO	(inst)
// );

assign IM_MEM_access = (WFI_stall)? 1'b0:1'b1;

always_ff @(posedge clk or posedge rst) begin : IF_ID_reg
    if (rst) begin
        pc_out <= 32'b0;
        inst_out <= 32'b0;
    end
    else begin
        pc_out <= pc_out_comb;
        inst_out <= inst_out_comb;
    end
end

always_ff @( posedge clk or posedge rst ) begin : PC_reg
    if (rst) begin
        pc_reg <= 32'b0;
    end
    else begin
        pc_reg <= pc_reg_comb; 
    end
end

always_comb begin : PC
    if (rst) begin
        pc_reg_comb = 32'b0;
        pc_2_IM = pc_reg_comb;
    end
    else begin
        pc_reg_comb = pc_reg + 32'd4;
        if (timer_interrupt_flag) begin
            pc_reg_comb = 32'b0;
        end
        else if (WFI_stall) begin
            pc_reg_comb = mtvec_out;
        end
        else if (MRET_flag) begin
            pc_reg_comb = mepc_out;
        end
        else if (pc_write | IM_stall | DM_stall) begin
            pc_reg_comb = pc_reg; // keep
        end
        else begin  
            case (branch_ctrl)
                2'b00: pc_reg_comb = pc_reg + 32'd4;
                2'b01: pc_reg_comb = pc_imm; 
                2'b10: pc_reg_comb = pc_imm_rs1; 
            endcase
        end
        pc_2_IM = pc_reg_comb;
    end
end

always_comb begin : PC_out
    // if (rst) begin
    //     pc_out_comb = 0;
    //     pc_2_IM = 0;
    // end
    // else begin
        pc_out_comb = pc_reg;
        if (timer_interrupt_flag) begin
            pc_out_comb = 32'b0;
        end
        else if (WFI_stall) begin
            pc_out_comb = mtvec_out;
        end
        else if (pc_write | IM_stall | DM_stall) begin
            pc_out_comb = pc_out; // keep
        end
        else if (MRET_flag) begin
            pc_out_comb = mepc_out;
        end
        // pc_2_IM = pc_out_comb[15:2]; 
        // pc_2_IM = pc_out_comb; 
    // end
end

always_comb begin : mux
    // if (rst) begin
    //     inst_out_comb = 0;
    // end
    // else begin
        inst_out_comb = inst;
        // inst_out_comb = inst_out;
        // if (IF_ID_reg_ctrl == 2'b10) begin
        //     inst_out_comb = 32'b0; // clear
        // end
        // else if (IF_ID_reg_ctrl == 2'b01 | IM_stall | DM_stall) begin
        //     inst_out_comb = inst_out; // keep 
        // end
        // else if (IF_ID_reg_ctrl == 2'b00) begin
        //     inst_out_comb = inst; // normal
        // end
        case (IF_ID_reg_ctrl)
            2'b00: begin
                inst_out_comb = inst; // normal
            end
            2'b01: begin
                inst_out_comb = inst_out; // keep 
            end 
            2'b10:  begin
                inst_out_comb = 32'b0; // clear
            end
        endcase
        if (WFI_stall) begin
            inst_out_comb = 32'b0;
        end
        else if (IM_stall | DM_stall) begin
            inst_out_comb = inst_out;
        end
    // end
end
    
endmodule