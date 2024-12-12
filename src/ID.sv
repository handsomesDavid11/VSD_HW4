module ID (
    input clk,
    input neg_clk,
    input rst,

    input IM_stall,
    input DM_stall,
    input WFI_stall,

    input [31:0] pc_in, // from IF
    input [31:0] inst, // from IF
    input ID_EXE_reg_ctrl, // from hazard control

    input reg_write_en, // from WB
    input [31:0] wb_rd_data, // from WB
    input [4:0] wb_rd_addr, // from WB

    // floating
    input f_reg_write_en, // from WB
    input [31:0] frd_data, // from WB

    // output logic [1:0] CSR_type, // to EXE
    // output reg [3:0] alu_op, // to EXE
    output logic [1:0] alu_op, // to EXE
    output logic alu_src, // to EXE
    output logic [31:0] pc_out, // to EXE

    // floating
    output logic [31:0] floating_rs1_data, // to EXE
    output logic [31:0] floating_rs2_data, // to EXE
    // output logic floating_alu, // to EXE, 1: floating calculation
    output logic f_reg_write, // to RF

    output logic DM_src, // to MEM, 0: rs2, 1: frs2

    output logic CSR_inst, // to CSR

    output logic [31:0] rs1_data, // to EXE
    output logic [31:0] rs2_data, // to EXE
    output logic [24:0] inst_out, // inst[31:7]
    output logic [31:0] imm, // to EXE
    output logic [1:0] pc_2_reg_src, // to EXE
    output logic [1:0] branch_flag, // to EXE, 0: PC + 4 (none), 1: PC + imm, 2: imm + rs1 
    output logic rd_src, // to MEM
    output logic mem_read, // to MEM
    output logic mem_write, // to MEM
    output logic mem_2_reg_src, // to WB, 0: from DM, 1: from MEM_rd_data
    output logic reg_write // to RF
);

logic [31:0] floating_rs1_data_comb;
logic [31:0] floating_rs2_data_comb;
// logic floating_alu_comb;
logic f_reg_write_comb;

logic DM_src_comb;

logic [24:0] inst_out_comb;
logic [31:0] rs1_data_comb;
logic [31:0] rs2_data_comb;
logic [31:0] imm_comb;
// logic [3:0] alu_op_comb;
logic [1:0] alu_op_comb;
logic alu_src_comb; // 0: rs2, 1: imm
logic [1:0] pc_2_reg_src_comb; // 0: PC + imm, 1: PC + 4, 2: imm, 3: CSR
logic rd_src_comb; // 0: from alu, 1: from pc
logic mem_read_comb;
logic mem_write_comb;
logic mem_2_reg_src_comb; // 0: from DM, 1: from MEM_rd_data or FPU output
logic reg_write_comb;
logic [1:0] branch_flag_comb;
// logic [1:0] CSR_type_comb; // 0: instret_high, 1: instret_low, 2: cycle_high, 3: cycle_low
// logic clk_neg;
logic CSR_inst_comb;

// register file
logic [31:0] registers [31:0];
logic [31:0] registers_comb [31:0];
// floating register file
logic [31:0] floating_registers [31:0];
logic [31:0] floating_registers_comb [31:0];

// stall controls
logic [31:0] pc_in_stall;
logic [1:0] alu_op_comb_stall;
logic alu_src_comb_stall;
logic rd_src_comb_stall;
logic mem_read_comb_stall;
logic mem_write_comb_stall;
logic mem_2_reg_src_comb_stall;
logic reg_write_comb_stall;
logic [31:0] rs1_data_comb_stall;
logic [31:0] rs2_data_comb_stall;
logic [24:0] inst_out_comb_stall;
logic [31:0] imm_comb_stall;
logic [1:0] pc_2_reg_src_comb_stall;
logic [1:0] branch_flag_comb_stall;
logic [31:0] floating_rs1_data_comb_stall;
logic [31:0] floating_rs2_data_comb_stall;
logic f_reg_write_comb_stall;
logic DM_src_comb_stall;
logic CSR_inst_comb_stall;

integer i;
integer j;
integer k;
integer l;

// ALU OP type
localparam LW_SW = 2'b00;
localparam BRANCH = 2'b01;
localparam FUNCT = 2'b10;
localparam OTHERS = 2'b11;

always_ff @(posedge clk or posedge rst) begin : ID_EXE_reg
    if (rst) begin
        pc_out <= 32'b0;
        alu_op <= 2'b0;
        alu_src <= 1'b0;
        rd_src <= 1'b0;
        mem_read <= 1'b0;
        mem_write <= 1'b0;
        mem_2_reg_src <= 1'b0;
        reg_write <= 1'b0;
        rs1_data <= 32'b0;
        rs2_data <= 32'b0;
        inst_out <= 25'b0;
        imm <= 32'b0;
        pc_2_reg_src <= 2'b0;
        branch_flag <= 2'b0;
        // CSR_type <= 0;
        floating_rs1_data <= 32'b0;
        floating_rs2_data <= 32'b0;
        // floating_alu <= 0;
        f_reg_write <= 1'b0;
        DM_src <= 1'b0;
        CSR_inst <= 1'b0;
    end
    else begin
        pc_out <= pc_in_stall;
        alu_op <= alu_op_comb_stall;
        alu_src <= alu_src_comb_stall;
        rd_src <= rd_src_comb_stall;
        mem_read <= mem_read_comb_stall;
        mem_write <= mem_write_comb_stall;
        mem_2_reg_src <= mem_2_reg_src_comb_stall;
        reg_write <= reg_write_comb_stall;
        rs1_data <= rs1_data_comb_stall;
        rs2_data <= rs2_data_comb_stall;
        inst_out <= inst_out_comb_stall;
        imm <= imm_comb_stall;
        pc_2_reg_src <= pc_2_reg_src_comb_stall;
        branch_flag <= branch_flag_comb_stall;
        floating_rs1_data <= floating_rs1_data_comb_stall;
        floating_rs2_data <= floating_rs2_data_comb_stall;
        f_reg_write <= f_reg_write_comb_stall;
        DM_src <= DM_src_comb_stall;
        CSR_inst <= CSR_inst_comb_stall;
    end
end

always_comb begin : stall_control
    pc_in_stall = pc_in;
    alu_op_comb_stall = alu_op_comb;
    alu_src_comb_stall = alu_src_comb;
    rd_src_comb_stall = rd_src_comb;
    mem_read_comb_stall = mem_read_comb;
    mem_write_comb_stall = mem_write_comb;
    mem_2_reg_src_comb_stall = mem_2_reg_src_comb;
    reg_write_comb_stall = reg_write_comb;
    rs1_data_comb_stall = rs1_data_comb;
    rs2_data_comb_stall = rs2_data_comb;
    inst_out_comb_stall = inst_out_comb;
    imm_comb_stall = imm_comb;
    pc_2_reg_src_comb_stall = pc_2_reg_src_comb;
    branch_flag_comb_stall = branch_flag_comb;
    floating_rs1_data_comb_stall = floating_rs1_data_comb;
    floating_rs2_data_comb_stall = floating_rs2_data_comb;
    f_reg_write_comb_stall = f_reg_write_comb;
    DM_src_comb_stall = DM_src_comb;
    CSR_inst_comb_stall = CSR_inst_comb;
    if ((IM_stall | DM_stall) & ~WFI_stall) begin
        pc_in_stall = pc_out;
        alu_op_comb_stall = alu_op;
        alu_src_comb_stall = alu_src;
        rd_src_comb_stall = rd_src;
        mem_read_comb_stall = mem_read;
        mem_write_comb_stall = mem_write;
        mem_2_reg_src_comb_stall = mem_2_reg_src;
        reg_write_comb_stall = reg_write;
        rs1_data_comb_stall = rs1_data;
        rs2_data_comb_stall = rs2_data;
        inst_out_comb_stall = inst_out;
        imm_comb_stall = imm;
        pc_2_reg_src_comb_stall = pc_2_reg_src;
        branch_flag_comb_stall = branch_flag;
        floating_rs1_data_comb_stall = floating_rs1_data;
        floating_rs2_data_comb_stall = floating_rs2_data;
        f_reg_write_comb_stall = f_reg_write;
        DM_src_comb_stall = DM_src;
        CSR_inst_comb_stall = CSR_inst;
    end
end

always_comb begin : Control_Unit
    if (rst) begin
        alu_op_comb =  2'b0;
        alu_src_comb = 1'b0;
        pc_2_reg_src_comb = 2'b0;
        rd_src_comb = 1'b0;
        mem_read_comb = 1'b0;
        mem_write_comb = 1'b0;
        mem_2_reg_src_comb = 1'b0;
        reg_write_comb = 1'b0;
        branch_flag_comb = 2'b0;
        inst_out_comb = 25'b0;
        // CSR_type_comb = 0;
        // floating_alu_comb = 0;
        f_reg_write_comb = 1'b0;
        DM_src_comb = 1'b0;
        CSR_inst_comb = 1'b0;
    end
    else begin
        alu_op_comb = OTHERS;
        alu_src_comb = 1'b1;
        pc_2_reg_src_comb = 2'b00;
        rd_src_comb = 1'b0;
        mem_read_comb = 1'b0;
        mem_write_comb = 1'b0;
        mem_2_reg_src_comb = 1'b1;
        reg_write_comb = 1'b0;
        branch_flag_comb = 2'b00;
        inst_out_comb = inst[31:7];
        // CSR_type_comb = 0;
        // floating_alu_comb = 0;
        f_reg_write_comb = 1'b0;
        DM_src_comb = 1'b0; // rs2
        CSR_inst_comb = 1'b0;
        // op code
        case (inst[6:0])
            7'b0110011: begin // R-type
                // alu_op_comb = R_type;
                alu_op_comb = FUNCT;
                alu_src_comb = 1'b0;
                reg_write_comb = 1'b1;
            end
            7'b0000011: begin // I-type load
                // alu_op_comb = I_type_load;
                alu_op_comb = LW_SW;
                mem_2_reg_src_comb = 1'b0;
                mem_read_comb = 1'b1;
                reg_write_comb = 1'b1;
            end
            7'b0010011: begin // I-type alu
                // alu_op_comb = I_type_alu;
                alu_op_comb = FUNCT;
                reg_write_comb = 1'b1;
            end
            7'b1100111: begin // I-type JALR
                // alu_op_comb = I_type_JALR;
                alu_op_comb = LW_SW; // for imm + rs1
                pc_2_reg_src_comb = 2'b01;
                rd_src_comb = 1'b1;
                reg_write_comb = 1'b1;     
                branch_flag_comb = 2'b10; // PC = imm + rs1       
            end
            7'b0100011: begin // S-type
                alu_op_comb = LW_SW; 
                // mem_2_reg_src_comb = 1;
                mem_write_comb = 1'b1;
            end
            7'b1100011: begin // B-type
                alu_op_comb = BRANCH;
                alu_src_comb = 1'b0;
                branch_flag_comb = 2'b01; // PC = PC + imm;
            end
            7'b0010111: begin // U-type AUIPC
                alu_op_comb = OTHERS;
                pc_2_reg_src_comb = 2'b00; // rd = PC + imm
                rd_src_comb = 1'b1;
                reg_write_comb = 1'b1;
            end
            7'b0110111: begin // U-type LUI
                alu_op_comb = OTHERS;
                pc_2_reg_src_comb = 2'b10; // rd = imm
                rd_src_comb = 1'b1;
                reg_write_comb = 1'b1;
            end
            7'b1101111: begin // J-type JAL
                alu_op_comb = OTHERS;
                pc_2_reg_src_comb = 2'd1;
                rd_src_comb = 1'b1;
                reg_write_comb = 1'b1;
                branch_flag_comb = 2'b01; // PC = PC + imm;
            end
            7'b0000111: begin // F-type FLW
                alu_op_comb = LW_SW;
                mem_2_reg_src_comb = 1'b0; // from DM
                mem_read_comb = 1'b1;
                // reg_write_comb = 1;
                f_reg_write_comb = 1'b1;
            end
            7'b0100111: begin // F-type FSW
                alu_op_comb = LW_SW; 
                mem_write_comb = 1'b1;
                DM_src_comb = 1'b1; // from frs2
            end
            7'b1010011: begin // F-type alu
                alu_op_comb = OTHERS;
                f_reg_write_comb = 1'b1;
                // floating_alu_comb = 1;
            end
            7'b1110011: begin // CSR instruction
                alu_op_comb = OTHERS;
                pc_2_reg_src_comb = 2'd3;
                rd_src_comb = 1'b1;
                reg_write_comb = 1'b1;
                if (inst[11:7] == 5'b0) begin // rd_addr = 0
                    reg_write_comb = 1'b0;
                end
                // mem_2_reg_src_comb = 1;
                CSR_inst_comb = 1'b1;
            end
        endcase
        // hazard zontrol, flush
        if (ID_EXE_reg_ctrl | WFI_stall) begin
            alu_op_comb = OTHERS;
            mem_read_comb = 1'b0;
            mem_write_comb = 1'b0;
            reg_write_comb = 1'b0;
            branch_flag_comb = 2'b0;
            mem_2_reg_src_comb = 1'b0;
            alu_src_comb = 1'b0;
            pc_2_reg_src_comb = 2'b0;
            rd_src_comb = 1'b0;
            inst_out_comb = 25'b0;
            // floating_alu_comb = 0;
            f_reg_write_comb = 1'b0;
            DM_src_comb = 1'b0; 
            CSR_inst_comb = 1'b0;
        end
        // else if (IM_stall | DM_stall) begin // keep
        //     alu_op_comb = alu_op;
        //     mem_read_comb = mem_read;
        //     mem_write_comb = mem_write;
        //     reg_write_comb = reg_write;
        //     branch_flag_comb = branch_flag;
        //     mem_2_reg_src_comb = mem_2_reg_src;
        //     alu_src_comb = alu_src;
        //     pc_2_reg_src_comb = pc_2_reg_src;
        //     rd_src_comb = rd_src;
        //     inst_out_comb = inst_out;
        //     f_reg_write_comb = f_reg_write;
        //     DM_src_comb = DM_src;
        // end
    end
end

// assign neg_clk = ~clk;

always_comb begin : Register_File_output
    if (rst) begin
        rs1_data_comb = 0;
        rs2_data_comb = 0;
    end
    else begin
        rs1_data_comb = registers[inst[19:15]];
        rs2_data_comb = registers[inst[24:20]];
        // case (ID_EXE_reg_ctrl)
        //     2'b01: begin // keep
        //         rs1_data_comb = rs1_data;
        //         rs2_data_comb = rs2_data;
        //     end
        //     2'b10: begin // clear
        //         rs1_data_comb = 0;
        //         rs2_data_comb = 0;
        //     end
        // endcase
    end
end

always_comb begin : Register_File
    // if (rst) begin
    //     for (i = 0; i <= 31; i = i + 1) begin
    //         registers_comb[i] = 0;
    //     end
    // end
    // else begin
        for (i = 0; i <= 31; i = i + 1) begin
            registers_comb[i] = registers[i];
        end
        if (wb_rd_addr != 5'b0 && reg_write_en) begin
            registers_comb[wb_rd_addr] = wb_rd_data;
        end
    // end
end

// always_ff @( posedge neg_clk or posedge rst ) begin : Register_file_reg
always_ff @( posedge clk or posedge rst ) begin : Register_file_reg
// always_ff @( posedge ~clk or posedge rst ) begin : Register_file_reg
    if (rst) begin
        for (j = 0; j <= 31; j = j + 1) begin
            registers[j] <= 32'b0;
        end
    end
    else begin
        for (j = 0; j <= 31; j = j + 1) begin
            registers[j] <= registers_comb[j];
        end
    end
end

always_comb begin : Immediate_Generator
    if (rst) begin
        imm_comb = 32'b0;
    end
    else begin
        imm_comb = 32'b0;
        case (inst[6:0])
            7'b0000111, // F-type FLW
            7'b0000011, // I-type load
            7'b1100111: begin // I-type JALR
                imm_comb = {{20{inst[31]}}, inst[31:20]};
            end 
            7'b0010011: begin // I-type alu
                imm_comb = {{20{inst[31]}}, inst[31:20]};
                // funct3
                if (inst[14:12] == 3'b001 || inst[14:12] == 3'b101) begin
                    imm_comb = {{27{1'b0}}, inst[24:20]};
                end
            end
            7'b0100111, // F-type FSW
            7'b0100011: begin // S-type
                imm_comb = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            end
            7'b1100011: begin // B-type
                imm_comb = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            end
            7'b0110111, // U-type LUI
            7'b0010111: begin // U-type AUIPC
                imm_comb = {inst[31:12], {12{1'b0}}};
            end
            7'b1101111: begin // J-type JAL
                imm_comb = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            end
        endcase
        // case (ID_EXE_reg_ctrl)
        //     2'b01: begin // keep
        //         imm_comb = imm;
        //     end
        //     2'b10: begin // clear
        //         imm_comb = 0;
        //     end
        // endcase
    end
end

always_comb begin : floating_Register_File_output
    if (rst) begin
        floating_rs1_data_comb = 0;
        floating_rs2_data_comb = 0;
    end
    else begin
        floating_rs1_data_comb = floating_registers[inst[19:15]];
        floating_rs2_data_comb = floating_registers[inst[24:20]];
        // case (ID_EXE_reg_ctrl)
        //     2'b01: begin // keep
        //         rs1_data_comb = rs1_data;
        //         rs2_data_comb = rs2_data;
        //     end
        //     2'b10: begin // clear
        //         rs1_data_comb = 0;
        //         rs2_data_comb = 0;
        //     end
        // endcase
    end
end

always_comb begin : floating_Register_File
    // if (rst) begin
    //     for (k = 0; k <= 31; k = k + 1) begin
    //         floating_registers_comb[k] = 0;
    //     end
    // end
    // else begin
        for (k = 0; k <= 31; k = k + 1) begin
            floating_registers_comb[k] = floating_registers[k];
        end
        if (f_reg_write_en) begin
            floating_registers_comb[wb_rd_addr] = frd_data;
        end
    // end
end

// always_ff @( posedge neg_clk or posedge rst ) begin : floating_Register_file_reg
always_ff @( posedge clk or posedge rst ) begin : floating_Register_file_reg
// always_ff @( posedge ~clk or posedge rst ) begin : floating_Register_file_reg
    if (rst) begin
        for (l = 0; l <= 31; l = l + 1) begin
            floating_registers[l] <= 32'b0;
        end
    end
    else begin
        for (l = 0; l <= 31; l = l + 1) begin
            floating_registers[l] <= floating_registers_comb[l];
        end
    end
end

endmodule