`include "IF_.sv"
`include "ID.sv"
`include "EXE.sv"
`include "Branch_Ctrl.sv"
`include "MEM.sv"
`include "WB.sv"
`include "Forwarding_Unit.sv"
`include "Hazard_Ctrl.sv"
`include "CSR_counter.sv"
`include "CSR.sv"

module CPU(
	input clk,
	input rst,

    // interrupt signal
    input external_interrupt_flag,
    input timer_interrupt_flag,

    input [31:0] inst_IM, // from IM
    // output logic [13:0] pc_2_IM, // to IM
    output logic [31:0] pc_2_IM, // to IM
    output logic IM_MEM_access,
    input IM_stall,

    input [31:0] DM_out, // from DM
    // to DM
    output logic [31:0] DM_addr, 
    output logic DM_WEB,
    // output logic DM_read,
    output logic [3:0] DM_write,
    output logic DM_MEM_access,
    input DM_stall,
    output logic [31:0] DM_data_in
);

// from IF
logic [31:0] IF_pc_out;
logic [31:0] IF_inst_out;

// from ID
logic [1:0] alu_op; 
logic alu_src; 
logic [31:0] ID_pc_out; 
logic [31:0] ID_rs1_data; 
logic [31:0] ID_rs2_data; 
logic [24:0] ID_inst_out; 
logic [31:0] imm; 
logic [1:0] ID_pc_2_reg_src; 
logic [1:0] ID_branch_flag;
logic ID_rd_src; 
logic ID_mem_read; 
logic ID_mem_write; 
logic ID_mem_2_reg_src; 
logic ID_reg_write; 
logic [31:0] ID_floating_rs1_data;
logic [31:0] ID_floating_rs2_data;
logic ID_f_reg_write;
logic ID_DM_src;
logic CSR_inst;

// from CSR_counter
logic [31:0] CSR_counter_output;
// from CSR
logic [1:0] CSR_counter_type; // to CSR_counter
logic MRET_flag; // make PC <= mepc 
logic WFI_stall; // CPU stall until interrupt
logic [31:0] mepc_out; // interrupt return PC
logic [31:0] mtvec_out; // Interrupt service routine PC
logic [31:0] CSR_output; // to EXE for rd data

// from EXE
logic [31:0] EXE_pc_2_reg; 
logic [31:0] alu_result; 
logic [31:0] forward_rs2_data;
logic [31:0] pc_imm; 
logic [31:0] pc_imm_rs1; 
// logic [1:0] branch_flag_comb;
logic zero_flag_comb; 
logic unsigned_flag; 
logic EXE_rd_src; 
logic EXE_mem_read; 
logic EXE_mem_write; 
logic [1:0] EXE_data_type; 
logic EXE_mem_2_reg_src; 
logic [4:0] EXE_rd_addr; 
logic EXE_reg_write;
logic [1:0] CSR_type;
logic [31:0] forward_rs1_data;
// logic [2:0] CSR_op;
logic EXE_f_reg_write;
logic EXE_DM_src;
logic [31:0] EXE_frs2_data;
logic [31:0] EXE_f_alu_result;

// from MEM
logic MEM_reg_write;  
logic [4:0] MEM_rd_addr;
logic [31:0] MEM_rd_data; 
logic [31:0] DM_data_out;
logic MEM_mem_2_reg_src;  
logic [4:0] MEM_rd_addr_comb; 
logic [31:0] MEM_rd_data_comb; 
// logic MEM_reg_write_comb;
logic MEM_f_reg_write;
logic [31:0] MEM_f_alu_result;

// from WB
logic [31:0] WB_rd_data;
logic [4:0] WB_rd_addr;
logic WB_reg_write;
logic WB_f_reg_write;
logic [31:0] WB_frd_data;

// from branch control
logic [1:0] branch_ctrl;

// from hazard control
logic pc_write;
logic [1:0] IF_ID_reg_ctrl;
logic ID_EXE_reg_ctrl;

// from forwarding unit
logic [1:0] forward_rs1_src;
logic [1:0] forward_rs2_src;
logic [1:0] forward_frs1_src;
logic [1:0] forward_frs2_src;

IF_ IF1(
	.clk(clk),
    .rst(rst),

    .IM_MEM_access(IM_MEM_access),
    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .WFI_stall(WFI_stall),
    .timer_interrupt_flag(timer_interrupt_flag),
    .external_interrupt_flag(external_interrupt_flag),

    .MRET_flag(MRET_flag), // make PC <= mepc
    .mepc_out(mepc_out), // interrupt return PC
    .mtvec_out(mtvec_out), // Interrupt service routine PC

    .branch_ctrl(branch_ctrl), // from branch control
    .pc_imm_rs1(pc_imm_rs1), // from EXE
    .pc_imm(pc_imm), // from EXE
    .pc_write(pc_write), // from hazard control
    .IF_ID_reg_ctrl(IF_ID_reg_ctrl), // from hazard control

	.inst(inst_IM), // from IM

    .pc_out(IF_pc_out), // to ID
    .inst_out(IF_inst_out), // to ID

	.pc_2_IM(pc_2_IM) // to IM
);

ID ID1(
    .clk(clk),
    .neg_clk(~clk),
    .rst(rst),

    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .WFI_stall(WFI_stall),

    .pc_in(IF_pc_out), // from IF
    .inst(IF_inst_out), // from IF
    .ID_EXE_reg_ctrl(ID_EXE_reg_ctrl), // from hazard control

    .reg_write_en(WB_reg_write), // from WB
    .wb_rd_data(WB_rd_data), // from WB
    .wb_rd_addr(WB_rd_addr), // from WB

    .f_reg_write_en(WB_f_reg_write), // from WB
    .frd_data(WB_frd_data), // from WB

    .alu_op(alu_op), // to EXE
    .alu_src(alu_src), // to EXE
    .pc_out(ID_pc_out), // to EXE

    // floating
    .floating_rs1_data(ID_floating_rs1_data),// to EXE
    .floating_rs2_data(ID_floating_rs2_data),// to EXE
    // .floating_alu(),// to EXE, 1: floating calculation
    .f_reg_write(ID_f_reg_write),// to RF

    .DM_src(ID_DM_src),// to MEM, 0: rs2, 1: frs2

    .CSR_inst(CSR_inst), // to CSR

    .rs1_data(ID_rs1_data), // to EXE
    .rs2_data(ID_rs2_data), // to EXE
    .inst_out(ID_inst_out), // // to EXE
    .imm(imm), // to EXE
    .pc_2_reg_src(ID_pc_2_reg_src), // to EXE
    .branch_flag(ID_branch_flag), // to EXE
    .rd_src(ID_rd_src), // to MEM
    .mem_read(ID_mem_read), // to MEM
    .mem_write(ID_mem_write), // to MEM
    .mem_2_reg_src(ID_mem_2_reg_src), // to WB
    .reg_write(ID_reg_write) // to RF
);

CSR_counter CSR_counter1(
    .rst(rst),
    .clk(clk),

    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .WFI_stall(WFI_stall),

    // .branch_ctrl(branch_ctrl), // from branch control
    .IF_ID_reg_ctrl(IF_ID_reg_ctrl), // from hazard control
    .CSR_type(CSR_counter_type), // from CSR

    .CSR_output(CSR_counter_output) // to CSR
);

CSR CSR1(
    .clk(clk),
    .rst(rst),

    .CSR_inst(CSR_inst), // from ID_EXE_reg
    .inst(ID_inst_out), // from ID_EXE_reg
    .pc_in(ID_pc_out), // from ID_EXE_reg
    .external_interrupt_flag(external_interrupt_flag),
    .timer_interrupt_flag(timer_interrupt_flag),
    .forward_rs1_data(forward_rs1_data), // from EXE
    .CSR_counter_output(CSR_counter_output), // from CSR_counter

    .CSR_counter_type(CSR_counter_type), // to CSR_counter
    .MRET_flag(MRET_flag), // make PC <= mepc 
    .WFI_stall(WFI_stall), // CPU stall until interrupt
    .mepc_out(mepc_out), // interrupt return PC
    .mtvec_out(mtvec_out), // Interrupt service routine PC
    .CSR_output(CSR_output) // to EXE for rd data
);

EXE EXE1(
    .clk(clk),
    .rst(rst),

    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .WFI_stall(WFI_stall),

    .pc_in(ID_pc_out), // from ID
    .inst(ID_inst_out), // from ID inst[31:7]

    .alu_op(alu_op), // from ID
    .alu_src(alu_src), // from ID, 0: rs2, 1: imm

    .rs1_data(ID_rs1_data), // from ID
    .rs2_data(ID_rs2_data), // from ID
    .imm(imm), // from ID
    .pc_2_reg_src(ID_pc_2_reg_src), // from ID
    // .branch_flag(ID_branch_flag), // from ID
    
    .mem_rd_data(MEM_rd_data_comb), // from MEM, comb
    .mem_frd_data(EXE_f_alu_result), // from EXE_MEM reg
    .wb_rd_data(WB_rd_data), // from WB
    .wb_frd_data(WB_frd_data), // from WB
    .forward_rs1_src(forward_rs1_src), // from Forwarding Unit
    .forward_rs2_src(forward_rs2_src), // from Forwarding Unit
    .forward_frs1_src(forward_frs1_src), // from Forwarding Unit
    .forward_frs2_src(forward_frs2_src), // from Forwarding Unit

    .rd_src_in(ID_rd_src), // from ID
    .mem_read_in(ID_mem_read), // from ID
    .mem_write_in(ID_mem_write), // from ID
    .mem_2_reg_src_in(ID_mem_2_reg_src), // from ID
    .reg_write_in(ID_reg_write), // from ID

    .CSR_output(CSR_output), // from CSR

    // floating
    .floating_rs1_data(ID_floating_rs1_data),// from ID
    .floating_rs2_data(ID_floating_rs2_data),// from ID, to MEM
    // .floating_alu(),// from ID

    .f_reg_write_in(ID_f_reg_write),// from ID, to RF
    .DM_src_in(ID_DM_src),// from ID, to MEM

    .f_reg_write(EXE_f_reg_write),// to RF
    .DM_src(EXE_DM_src), // to MEM
    .frs2_data(EXE_frs2_data), // to MEM
    .f_alu_result(EXE_f_alu_result),// to MEM

    // .CSR_type_comb(CSR_type), // to CSR counter
    .forward_rs1_data(forward_rs1_data), // to CSR
    // .CSR_op(CSR_op), // to CSR

    // .rs1_addr(EXE_rs1_addr), // to Forwarding Unit
    // .rs2_addr(EXE_rs2_addr), // to Forwarding Unit

    .pc_2_reg(EXE_pc_2_reg), // to MEM
    .alu_result(alu_result), // to MEM
    .forward_rs2_data(forward_rs2_data), // to MEM

    .pc_imm(pc_imm), // to IF(), comb
    .pc_imm_rs1(pc_imm_rs1), // to IF, comb

    // .branch_flag_comb(branch_flag_comb), // to Branch Control, comb
    .zero_flag_comb(zero_flag_comb), // to Branch Control, comb
    
    .unsigned_flag(unsigned_flag), // to MEM
    .rd_src(EXE_rd_src), // to MEM
    .mem_read(EXE_mem_read), // to MEM
    .mem_write(EXE_mem_write), // to MEM
    .data_type(EXE_data_type), // to MEM, 0: NONE, 1: word, 2: half-word, 3: byte 
    .mem_2_reg_src(EXE_mem_2_reg_src), // to WB
    .rd_addr(EXE_rd_addr), // to RF
    .reg_write(EXE_reg_write) // to RF
);

Branch_Ctrl Branch_Ctrl1(
    .branch_flag(ID_branch_flag), // from ID_EXE_reg
    .zero_flag(zero_flag_comb), // from EXE

    .branch_ctrl(branch_ctrl) // to IF, hazard control
);

Hazard_Ctrl Hazard_Ctrl1(
    .rst(rst),

    .branch_control(branch_ctrl), // from branch control
    .timer_interrupt_flag(timer_interrupt_flag),

    .rs1_addr(IF_inst_out[19:15]), // from IF_ID_reg
    .rs2_addr(IF_inst_out[24:20]), // from IF_ID_reg
    .EXE_rd_addr(ID_inst_out[4:0]), // from ID_EXE_reg
    .EXE_mem_read(ID_mem_read), // from ID_EXE_reg

    .pc_write(pc_write), // to IF
    .IF_ID_reg_ctrl(IF_ID_reg_ctrl), // to IF, 0: normal, 1: keep, 2: clear
    .ID_EXE_reg_ctrl(ID_EXE_reg_ctrl) // to ID, 0: normal, 1: keep, 2: clear
);

Forwarding_Unit Forwarding_Unit1(
    .rst(rst),
    // from ID_EXE_reg
    // .EXE_frs1_addr(),
    // .EXE_frs2_addr(),
    .EXE_rs1_addr(ID_inst_out[12:8]),
    .EXE_rs2_addr(ID_inst_out[17:13]),
    // from MEM
    // .MEM_reg_write(MEM_reg_write_comb),
    // .MEM_rd_addr(MEM_rd_addr_comb),
    // from EXE_MEM_reg
    .MEM_f_reg_write(EXE_f_reg_write),
    .MEM_reg_write(EXE_reg_write),
    .MEM_rd_addr(EXE_rd_addr),
    // from WB
    .WB_rd_addr(WB_rd_addr),
    .WB_f_reg_write(WB_f_reg_write),
    .WB_reg_write(WB_reg_write),
    // to EXE
    .forward_frs1_src(forward_frs1_src), // 0: ID, 1:MEM, 2: WB
    .forward_frs2_src(forward_frs2_src), // 0: ID, 1:MEM, 2: WB
    .forward_rs1_src(forward_rs1_src), // 0: ID, 1: MEM, 2: WB
    .forward_rs2_src(forward_rs2_src) // 0: ID, 1: MEM, 2: WB
);

MEM MEM1(
    .clk(clk),
    .rst(rst),

    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .WFI_stall(WFI_stall),
    .DM_MEM_access(DM_MEM_access),

    .pc_2_reg(EXE_pc_2_reg), // from EXE
    .alu_result(alu_result), // from EXE
    .forward_rs2_data(forward_rs2_data), // from EXE
    .unsigned_flag(unsigned_flag), // from EXE
    .rd_src(EXE_rd_src),  // from EXE
    .mem_read_in(EXE_mem_read),  // from EXE
    .mem_write_in(EXE_mem_write),  // from EXE
    .data_type(EXE_data_type),  // from EXE

    .rd_addr_in(EXE_rd_addr), // from EXE
    .mem_2_reg_src_in(EXE_mem_2_reg_src), // from EXE
    .reg_write_in(EXE_reg_write), // from EXE

    // .forward_rd_src(), // from forwarding unit
    // .WB_rd_data(), // from WB

    // floating
    .f_reg_write_in(EXE_f_reg_write),// from EXE, to RF
    .DM_src(EXE_DM_src),// from EXE
    .frs2_data(EXE_frs2_data), // from EXE
    .f_alu_result_in(EXE_f_alu_result),// from EXE

    .f_reg_write(MEM_f_reg_write),// to RF
    .f_alu_result(MEM_f_alu_result),// to WB

    .DM_out(DM_out), // from DM d_out
    
    .DM_WEB(DM_WEB), // to DM, comb, 1: read, 0: write
    // .DM_read(DM_read), // to DM, comb, active high
    .DM_write(DM_write), // to DM, comb, active low
    .DM_addr(DM_addr), // to DM, comb, alu_result[15:2]
    .DM_data_in(DM_data_in), // to DM, comb

    // .MEM_reg_write(MEM_reg_write_comb), // to forwarding unit, comb
    // .MEM_rd_addr(MEM_rd_addr_comb), // to forwarding unit, comb
    .rd_data_comb(MEM_rd_data_comb), // to EXE, comb

    .rd_data(MEM_rd_data), // to WB
    .DM_data_out(DM_data_out), // to WB
    .mem_2_reg_src(MEM_mem_2_reg_src), // to WB
    .rd_addr(MEM_rd_addr), // to RF
    .reg_write(MEM_reg_write) // to RF
);

WB WB1(
    .rst(rst),

    .rd_data(MEM_rd_data), // from MEM
    .DM_data_out(DM_data_out), // from MEM
    .mem_2_reg_src(MEM_mem_2_reg_src), // from MEM

    .rd_addr_in(MEM_rd_addr), // from MEM
    .reg_write_in(MEM_reg_write), // from MEM

    // floating
    .f_reg_write_in(MEM_f_reg_write), // from MEM
    .f_alu_result(MEM_f_alu_result), // from MEM

    .f_reg_write(WB_f_reg_write), // to floating RF
    .frd_data(WB_frd_data), // to floating RF
    .WB_rd_data(WB_rd_data), // to RF & EXE, comb
    .WB_rd_addr(WB_rd_addr), // to RF & forwarding unit, comb
    .reg_write(WB_reg_write) // to RF & forwarding unit, comb
);

endmodule