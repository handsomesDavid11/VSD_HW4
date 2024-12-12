module EXE (
    input clk,
    input rst,

    input IM_stall,
    input DM_stall,
    input WFI_stall,

    input [31:0] pc_in, // from ID
    input [24:0] inst, // from ID inst[31:7]

    input [1:0] alu_op, // from ID
    input alu_src, // from ID, 0: rs2, 1: imm

    input [31:0] rs1_data, // from ID
    input [31:0] rs2_data, // from ID
    input [31:0] imm, // from ID
    input [1:0] pc_2_reg_src, // from ID
    // input [1:0] branch_flag, // from ID
    
    input [31:0] mem_rd_data, // from MEM
    input [31:0] mem_frd_data, // from MEM
    input [31:0] wb_rd_data, // from WB
    input [31:0] wb_frd_data, // from WB
    input [1:0] forward_rs1_src, // from Forwarding Unit
    input [1:0] forward_rs2_src, // from Forwarding Unit
    input [1:0] forward_frs1_src, // from Forwarding Unit
    input [1:0] forward_frs2_src, // from Forwarding Unit

    input rd_src_in, // from ID
    input mem_read_in, // from ID
    input mem_write_in, // from ID
    input mem_2_reg_src_in, // from ID
    input reg_write_in, // from ID
    
    input [31:0] CSR_output, // from CSR

    // floating 
    input [31:0] floating_rs1_data, // from ID
    input [31:0] floating_rs2_data, // from ID, to MEM
    // input floating_alu, // from ID

    input f_reg_write_in, // from ID, to RF
    input DM_src_in, // from ID, to MEM

    output logic f_reg_write, // to RF
    output logic DM_src, // to MEM
    output logic [31:0] frs2_data, // to MEM
    output logic [31:0] f_alu_result, // to MEM

    // output logic [1:0] CSR_type_comb, // to CSR counter, // 0: instret_high, 1: instret_low, 2: cycle_high, 3: cycle_low
    output logic [31:0] forward_rs1_data, // to CSR
    // output logic [2:0] CSR_op, // to CSR

    output logic [31:0] pc_2_reg, // to MEM
    output logic [31:0] alu_result, // to MEM
    output logic [31:0] forward_rs2_data, // to MEM

    output logic [31:0] pc_imm, // to IF, comb
    output logic [31:0] pc_imm_rs1, // to IF, comb

    // output logic [1:0] branch_flag_comb, // to Branch Control, comb
    output logic zero_flag_comb, // to Branch Control, comb
    
    output logic unsigned_flag, // to MEM
    output logic rd_src, // to MEM
    output logic mem_read, // to MEM
    output logic mem_write, // to MEM
    output logic [1:0] data_type, // to MEM, 0: NONE, 1: word, 2: half-word, 3: byte 
    output logic mem_2_reg_src, // to WB
    output logic [4:0] rd_addr, // to RF
    output logic reg_write // to RF
);
// floating
logic [31:0] f_alu_result_comb; // floating alu output

// mul
logic [63:0] mul_result;
logic [63:0] mul_result_MUL;
logic [63:0] mul_result_MULH;
logic [63:0] mul_result_MULHSU;
// logic [63:0] mul_result_MULHU;

logic [31:0] pc_2_reg_comb;
logic [31:0] alu_result_comb;
logic [31:0] forward_rs2_data_comb;
logic [1:0] data_type_comb;

// logic [2:0] alu_ctrl_comb;
logic [3:0] alu_ctrl_comb;
logic [1:0] TF_type_comb;
logic unsigned_flag_comb;

logic [31:0] alu_in_1;
logic [31:0] alu_in_2;
logic [31:0] forward_mux_out_2;

logic [31:0] frs1_forwarding_out;
logic [31:0] frs2_forwarding_out;

// stall control
logic [31:0] pc_2_reg_comb_stall;
logic [31:0] alu_result_comb_stall;
logic [31:0] forward_rs2_data_comb_stall;
logic [4:0] rd_addr_stall;
logic unsigned_flag_comb_stall;
logic rd_src_in_stall;
logic mem_read_in_stall;
logic mem_write_in_stall;
logic [1:0] data_type_comb_stall;
logic mem_2_reg_src_in_stall;
logic reg_write_in_stall;
logic f_reg_write_in_stall;
logic DM_src_in_stall;
logic [31:0] frs2_forwarding_out_stall;
logic [31:0] f_alu_result_comb_stall;

// CSR_output_reg
logic [31:0] CSR_output_reg;
logic [31:0] CSR_output_comb;
logic CSR_output_reg_flag;
logic CSR_output_reg_flag_reg;

// ALU OP type
localparam LW_SW = 2'b00;
localparam BRANCH = 2'b01;
localparam FUNCT = 2'b10;
localparam OTHERS = 2'b11;

// ALU control type
localparam ADD = 4'b0000; // +
localparam SUB = 4'b0001; // -
localparam SLL = 4'b0010; // <<
localparam SRL = 4'b0011; // >>
localparam TF = 4'b0100; // alu_result = 1 or 0
localparam XOR_type = 4'b0101; // ^
localparam OR_type = 4'b0110; // |
localparam AND_type = 4'b0111; // &
localparam MUL = 4'b1000; // * lower 32 bit of result
localparam MULH = 4'b1001; // * upper 32 bit of result
localparam MULHSU = 4'b1010; // * upper 32 bit of result
localparam MULHU = 4'b1011; // * upper 32 bit of result
localparam NONE = 4'b1100; // none

// True or False type
localparam EQ = 2'b00; // ==
localparam NE = 2'b01; // !=
localparam LT = 2'b10; // <
localparam GE = 2'b11; // >=

// Load/store data type
localparam NO = 2'b00; // NONE
localparam WD = 2'b01; // word
localparam HW = 2'b10; // half-word
localparam BT = 2'b11; // byte

// CSR_op type
// localparam Privileged = 3'b000; // MRET, WFI
// localparam CSRRW = 3'b001;
// localparam CSRRS = 3'b010; // CSRRS, RD
// localparam CSRRC = 3'b011;
// localparam NO_CSR = 3'b100; // NO CSR
// localparam CSRRWI = 3'b101;
// localparam CSRRSI = 3'b110;
// localparam CSRRCI = 3'b111;

always_ff @( posedge clk or posedge rst ) begin : EXE_MEM_reg
    if (rst) begin
        pc_2_reg <= 32'b0;
        alu_result <= 32'b0;
        forward_rs2_data <= 32'b0;
        rd_addr <= 5'b0;
        unsigned_flag <= 1'b0;
        rd_src <= 1'b0;
        mem_read <= 1'b0;
        mem_write <= 1'b0;
        data_type <= NO;
        mem_2_reg_src <= 1'b0;
        reg_write <= 1'b0;
        // floating
        f_reg_write <= 1'b0;
        DM_src <= 1'b0;
        frs2_data <= 32'b0;
        f_alu_result <= 32'b0;
    end
    else begin
        pc_2_reg <= pc_2_reg_comb_stall;
        alu_result <= alu_result_comb_stall;
        forward_rs2_data <= forward_rs2_data_comb_stall;
        rd_addr <= rd_addr_stall;
        unsigned_flag <= unsigned_flag_comb_stall;
        rd_src <= rd_src_in_stall;
        mem_read <= mem_read_in_stall;
        mem_write <= mem_write_in_stall;
        data_type <= data_type_comb_stall;
        mem_2_reg_src <= mem_2_reg_src_in_stall;
        reg_write <= reg_write_in_stall;
        // floating
        f_reg_write <= f_reg_write_in_stall;
        DM_src <= DM_src_in_stall;
        // frs2_data <= floating_rs2_data;
        frs2_data <= frs2_forwarding_out_stall;
        f_alu_result <= f_alu_result_comb_stall;
    end
end

// stall control
always_comb begin : stall_control
    pc_2_reg_comb_stall = pc_2_reg_comb;
    alu_result_comb_stall = alu_result_comb;
    forward_rs2_data_comb_stall = forward_rs2_data_comb;
    rd_addr_stall = inst[4:0];
    unsigned_flag_comb_stall = unsigned_flag_comb;
    rd_src_in_stall = rd_src_in;
    mem_read_in_stall = mem_read_in;
    mem_write_in_stall = mem_write_in;
    data_type_comb_stall = data_type_comb;
    mem_2_reg_src_in_stall = mem_2_reg_src_in;
    reg_write_in_stall = reg_write_in;
    f_reg_write_in_stall = f_reg_write_in;
    DM_src_in_stall = DM_src_in;
    frs2_forwarding_out_stall = frs2_forwarding_out;
    f_alu_result_comb_stall = f_alu_result_comb;
    if (IM_stall & ~DM_stall) begin
        pc_2_reg_comb_stall = pc_2_reg;
        alu_result_comb_stall = alu_result;
        forward_rs2_data_comb_stall = forward_rs2_data;
        rd_addr_stall = rd_addr;
        unsigned_flag_comb_stall = unsigned_flag;
        rd_src_in_stall = rd_src;
        mem_read_in_stall = 1'b0;
        mem_write_in_stall = 1'b0;
        data_type_comb_stall = data_type;
        mem_2_reg_src_in_stall = mem_2_reg_src;
        reg_write_in_stall = reg_write;
        f_reg_write_in_stall = f_reg_write;
        DM_src_in_stall = DM_src;
        frs2_forwarding_out_stall = frs2_data;
        f_alu_result_comb_stall = f_alu_result;
    end
    else if (IM_stall | DM_stall) begin
    // if (IM_stall) begin
    // if (IM_stall | DM_stall) begin
        pc_2_reg_comb_stall = pc_2_reg;
        alu_result_comb_stall = alu_result;
        forward_rs2_data_comb_stall = forward_rs2_data;
        rd_addr_stall = rd_addr;
        unsigned_flag_comb_stall = unsigned_flag;
        rd_src_in_stall = rd_src;
        mem_read_in_stall = mem_read;
        mem_write_in_stall = mem_write;
        data_type_comb_stall = data_type;
        mem_2_reg_src_in_stall = mem_2_reg_src;
        reg_write_in_stall = reg_write;
        f_reg_write_in_stall = f_reg_write;
        DM_src_in_stall = DM_src;
        frs2_forwarding_out_stall = frs2_data;
        f_alu_result_comb_stall = f_alu_result;
    end
end

always @(posedge clk or posedge rst) begin : CSR_output_register
    if (rst) begin
        CSR_output_reg <= 32'b0;
        CSR_output_reg_flag_reg <= 1'b0;
    end
    else begin
        CSR_output_reg <= CSR_output_comb;
        CSR_output_reg_flag_reg <= CSR_output_reg_flag;
    end
end

always_comb begin : CSR_output_comb_control
    CSR_output_comb = CSR_output;
    if (CSR_output_reg_flag) begin
        CSR_output_comb = CSR_output_reg;
    end
end

always_comb begin : CSR_output_reg_flag_control
    CSR_output_reg_flag = 1'b0;
    if (IM_stall | DM_stall) begin
        CSR_output_reg_flag = 1'b1;
    end
end

always_comb begin : PC_to_reg
    // if (rst) begin
    //     pc_imm = 0;
    //     pc_2_reg_comb = 0;
    // end
    // else begin
        pc_imm = pc_in + imm;
        pc_2_reg_comb = 32'b0;
        case (pc_2_reg_src)
            2'b00: pc_2_reg_comb = pc_in + imm;
            2'b01: pc_2_reg_comb = pc_in + 32'd4;
            2'b10: pc_2_reg_comb = imm;
            // 2'b11: pc_2_reg_comb = CSR_output;
            2'b11: begin
                pc_2_reg_comb = CSR_output;
                if (CSR_output_reg_flag_reg) begin
                    pc_2_reg_comb = CSR_output_reg;
                end
            end
        endcase
    // ends
end

always_comb begin : ALU_Control
    // if (rst) begin
    //     data_type_comb = NO;
    //     alu_ctrl_comb = AND_type;
    //     TF_type_comb = EQ;
    //     unsigned_flag_comb = 0;
    // end
    // else begin
        data_type_comb = NO;
        // alu_ctrl_comb = AND_type;
        alu_ctrl_comb = NONE;
        TF_type_comb = EQ;
        unsigned_flag_comb = 1'b0;
        // CSR_type_comb = 2'b0;
        // CSR_op = NO_CSR;
        // instruction type
        case (alu_op)
            LW_SW: begin // rs1 + imm
                alu_ctrl_comb = ADD;
                data_type_comb = WD;
                // funct3
                case (inst[7:5])
                    3'b010: begin
                        data_type_comb = WD;
                    end 
                    3'b000: begin
                        data_type_comb = BT;
                    end
                    3'b001: begin
                        data_type_comb = HW;
                    end
                    3'b101: begin
                        data_type_comb = HW;
                        unsigned_flag_comb = 1'b1;
                    end
                    3'b100: begin
                        data_type_comb = BT;
                        unsigned_flag_comb = 1'b1;
                    end
                endcase
            end
            BRANCH: begin // True or False
                alu_ctrl_comb = TF;
                // funct3
                case (inst[7:5])
                    3'b000: begin // BEQ
                        TF_type_comb = EQ;
                    end
                    3'b001: begin // BNE
                        TF_type_comb = NE;
                    end
                    3'b100: begin // BLT
                        TF_type_comb = LT;
                        unsigned_flag_comb = 1'b0;
                    end
                    3'b101: begin // BGE
                        TF_type_comb = GE;
                        unsigned_flag_comb = 1'b0;
                    end
                    3'b110: begin // BLTU
                        TF_type_comb = LT;
                        unsigned_flag_comb = 1'b1;
                    end
                    3'b111: begin // BGUE
                        TF_type_comb = GE;
                        unsigned_flag_comb = 1'b1;
                    end
                endcase
            end
            FUNCT: begin // function
                // funct3
                case (inst[7:5])
                    3'b000: begin // ADD, SUB, ADDI, MUL
                        alu_ctrl_comb = ADD;
                        if (!alu_src) begin // 0: rs2, 1: imm
                            // funct7
                            case (inst[24:18])
                            7'b0100000: begin // SUB
                                if (!alu_src) begin // 0: rs2, 1: imm
                                    alu_ctrl_comb = SUB;
                                end
                            end
                            7'b0000001: begin // MUL
                                alu_ctrl_comb = MUL;
                            end
                        endcase
                        end
                        // if (!alu_src) begin // 0: rs2, 1: imm
                        //     // funct7
                        //     if (inst[24:18] == 7'b0100000) begin
                        //         alu_ctrl_comb = SUB;
                        //     end
                        // end
                    end 
                    3'b001: begin // SLL, SLLI
                        alu_ctrl_comb = SLL;
                        unsigned_flag_comb = 1'b1;
                        if (!alu_src) begin // 0: rs2, 1: imm
                            if (inst[24:18] == 7'b0000001) begin // MULH
                                alu_ctrl_comb = MULH;
                            end 
                        end
                    end
                    3'b010: begin // SLT, SLTI
                        alu_ctrl_comb = TF;
                        TF_type_comb = LT;
                        unsigned_flag_comb = 1'b0;
                        if (!alu_src) begin // 0: rs2, 1: imm
                            if (inst[24:18] == 7'b0000001) begin // MULHSU
                                alu_ctrl_comb = MULHSU;
                            end
                        end
                    end
                    3'b011: begin // SLTU, SLTUI
                        alu_ctrl_comb = TF;
                        TF_type_comb = LT;
                        unsigned_flag_comb = 1'b1;
                        if (!alu_src) begin // 0: rs2, 1: imm
                            if (inst[24:18] == 7'b0000001) begin // MULHU
                                alu_ctrl_comb = MULHU;
                            end
                        end
                    end
                    3'b100: begin // XOR_type, XORI
                        alu_ctrl_comb = XOR_type;
                    end
                    3'b101: begin // SRL, SRA
                        alu_ctrl_comb = SRL;
                        case (inst[24:18])
                            7'b0000000: begin
                                unsigned_flag_comb = 1'b1;
                            end
                            7'b0100000: begin
                                unsigned_flag_comb = 1'b0;
                            end
                        endcase
                    end
                    3'b110: begin // OR, ORI
                        alu_ctrl_comb = OR_type;
                    end
                    3'b111: begin // AND, ADDI
                        alu_ctrl_comb = AND_type;
                    end
                endcase
            end
            OTHERS: begin // No Need ALU
                // alu_ctrl_comb = AND_type;
                alu_ctrl_comb = NONE;
                // for CSR
                /*
                case (inst[7:5])
                    3'b000: begin // MRET, WFI
                        CSR_op = Privileged;
                    end
                    3'b001: begin // CSRRW
                        CSR_op = CSRRW;
                    end
                    3'b010: begin // CSRRS, RD
                        CSR_op = CSRRS;
                    end
                    3'b011: begin // CSRRC
                        CSR_op = CSRRC;
                    end
                    3'b101: begin // CSRRWI
                        CSR_op = CSRRWI;
                    end
                    3'b110: begin // CSRRSI
                        CSR_op = CSRRSI;
                    end
                    3'b111: begin // CSRRCI
                        CSR_op = CSRRCI;
                    end
                endcase
                */
                // RD inst
                /*
                case (inst[24:13]) // imm[11:0]
                    12'b110010000010: begin
                        CSR_type_comb = 2'd0;
                    end 
                    12'b110000000010: begin
                        CSR_type_comb = 2'd1;
                    end 
                    12'b110010000000: begin
                        CSR_type_comb = 2'd2;
                    end 
                    12'b110000000000: begin
                        CSR_type_comb = 2'd3;
                    end 
                endcase
                */
            end
        endcase
    // end
end

assign forward_rs1_data = alu_in_1;

always_comb begin : Forward_rs1_src_MUX
    // if (rst) begin
    //     alu_in_1 = 0;
    // end
    // else begin
        alu_in_1 = 32'b0;
        case (forward_rs1_src)
            2'b00: begin // ID
                alu_in_1 = rs1_data;
            end 
            2'b01: begin // MEM
                alu_in_1 = mem_rd_data;
            end
            2'b10: begin // WB
                alu_in_1 = wb_rd_data;
            end
        endcase
    // end
end

assign forward_rs2_data_comb = forward_mux_out_2;

always_comb begin : Forward_rs2_src_MUX
    // if (rst) begin
    //     forward_mux_out_2 = 0;
    // end
    // else begin
        forward_mux_out_2 = 32'b0;
        case (forward_rs2_src)
            2'b00: begin
                forward_mux_out_2 = rs2_data;
            end 
            2'b01: begin
                forward_mux_out_2 = mem_rd_data;
            end
            2'b10: begin
                forward_mux_out_2 = wb_rd_data;
            end
        endcase
    // end
end

always_comb begin : ALU_src_MUX
    // if (rst) begin
    //     alu_in_2 = 0;
    // end
    // else begin
        alu_in_2 = 32'b0;
        case (alu_src)
            1'b0: begin
                alu_in_2 = forward_mux_out_2;
            end 
            1'b1: begin
                alu_in_2 = imm;
            end
        endcase
    // end
end

// assign branch_flag_comb = branch_flag;
// assign pc_imm_rs1 = {alu_result_comb[31:2], {2{1'b0}}};
// assign pc_imm_rs1 = alu_result_comb;
assign pc_imm_rs1 = alu_in_1 + imm; // imm + rs1

// MUL result
assign mul_result_MUL = alu_in_1 * alu_in_2;
assign mul_result_MULH = $signed(alu_in_1) * $signed(alu_in_2);
assign mul_result_MULHSU = $signed(alu_in_1) * $signed({1'b0, alu_in_2});

always_comb begin : ALU
    // if (rst) begin
    //     alu_result_comb = 0;
    //     zero_flag_comb = 0;
    // end
    // else begin
        alu_result_comb = 32'b0;
        zero_flag_comb = 1'b0;
        mul_result = 64'b0;
        case (alu_ctrl_comb)
            ADD: begin
                alu_result_comb = alu_in_1 + alu_in_2;
            end
            SUB: begin
                alu_result_comb = alu_in_1 - alu_in_2;
            end
            SLL: begin
                alu_result_comb = alu_in_1 << alu_in_2[4:0];
            end
            SRL: begin
                alu_result_comb = alu_in_1 >> alu_in_2[4:0];
                if (!unsigned_flag_comb) begin
                    alu_result_comb = $signed(alu_in_1) >>> alu_in_2[4:0];
                end
            end
            TF: begin
                case (TF_type_comb)
                    EQ: begin
                        zero_flag_comb = 1'b1;
                        if (alu_in_1 == alu_in_2) begin
                            zero_flag_comb = 1'b0;
                            alu_result_comb = 1;
                        end
                    end 
                    NE: begin
                        zero_flag_comb = 1'b1;
                        if (alu_in_1 != alu_in_2) begin
                            zero_flag_comb = 1'b0;
                            alu_result_comb = 1;
                        end
                    end
                    LT: begin
                        zero_flag_comb = 1'b1;
                        alu_result_comb = 0;
                        if (!unsigned_flag_comb) begin
                            if ($signed(alu_in_1) < $signed(alu_in_2)) begin
                                zero_flag_comb = 1'b0;
                                alu_result_comb = 1;
                            end
                        end
                        else begin
                            if (alu_in_1 < alu_in_2) begin
                                zero_flag_comb = 1'b0;
                                alu_result_comb = 1;
                            end
                        end
                    end
                    GE: begin
                        zero_flag_comb = 1'b1;
                        alu_result_comb = 0;
                        if (!unsigned_flag_comb) begin
                            if ($signed(alu_in_1) >= $signed(alu_in_2)) begin
                                zero_flag_comb = 1'b0;
                                alu_result_comb = 1;
                            end
                        end
                        else begin
                            if (alu_in_1 >= alu_in_2) begin
                                zero_flag_comb = 1'b0;
                                alu_result_comb = 1;
                            end
                        end
                    end
                endcase
            end
            XOR_type: begin
                alu_result_comb = alu_in_1 ^ alu_in_2;
            end
            OR_type: begin
                alu_result_comb = alu_in_1 | alu_in_2;
            end
            AND_type: begin
                alu_result_comb = alu_in_1 & alu_in_2;
            end
            MUL: begin
                // mul_result = alu_in_1 * alu_in_2;
                mul_result = mul_result_MUL;
                alu_result_comb = mul_result[31:0];
            end
            MULH: begin
                // mul_result = $signed(alu_in_1) * $signed(alu_in_2);
                mul_result = mul_result_MULH;
                alu_result_comb = mul_result[63:32];
            end
            MULHSU: begin
                // mul_result = $signed(alu_in_1) * $unsigned(alu_in_2);
                // mul_result = $signed(alu_in_1) * $signed({1'b0, alu_in_2});
                mul_result = mul_result_MULHSU;
                alu_result_comb = mul_result[63:32];
            end
            MULHU: begin
                // mul_result = alu_in_1 * alu_in_2;
                mul_result = mul_result_MUL;
                alu_result_comb = mul_result[63:32];
            end
        endcase
    // end
end

always_comb begin : frs1_forwarding_mux
    frs1_forwarding_out = 32'b0;
    case (forward_frs1_src)
        2'b00: begin // ID
            frs1_forwarding_out = floating_rs1_data;
        end 
        2'b01: begin // MEM
            frs1_forwarding_out = mem_frd_data;
        end
        2'b10: begin // WB
            frs1_forwarding_out = wb_frd_data;
        end
    endcase
end

always_comb begin : frs2_forwarding_mux
    frs2_forwarding_out = 32'b0;
    case (forward_frs2_src)
        2'b00: begin // ID
            frs2_forwarding_out = floating_rs2_data;
        end 
        2'b01: begin // MEM
            frs2_forwarding_out = mem_frd_data;
        end
        2'b10: begin // WB
            frs2_forwarding_out = wb_frd_data;
        end
    endcase
end

// [31]: sign, [30:23]: exp, [22:0]: fraction 
logic [7:0] exp_diff;
logic [31:0] frs1_fraction_shifted; // 1: [31], effective: [30:8], round: [7:0]
logic [31:0] frs2_fraction_shifted; // 1: [31], effective: [30:8], round: [7:0]
logic sign_bit_result;
logic [7:0] exp_in;
logic [7:0] exp_rounded;
logic [32:0] fraction_cal_result;
logic [32:0] fraction_cal_result_shifted;
logic [22:0] fraction_rounded;

always_comb begin : floating_bit_align
     if (frs1_forwarding_out[30:23] > frs2_forwarding_out[30:23]) begin
        exp_diff = frs1_forwarding_out[30:23] - frs2_forwarding_out[30:23];
        exp_in = frs1_forwarding_out[30:23];

        frs1_fraction_shifted = {{1'b1}, frs1_forwarding_out[22:0], {8{1'b0}}};
        frs2_fraction_shifted = {{1'b1}, frs2_forwarding_out[22:0], {8{1'b0}}} >> exp_diff;
    end
    else begin
        exp_diff = frs2_forwarding_out[30:23] - frs1_forwarding_out[30:23];
        exp_in = frs2_forwarding_out[30:23];
        
        frs1_fraction_shifted = {{1'b1}, frs1_forwarding_out[22:0], {8{1'b0}}} >> exp_diff;
        frs2_fraction_shifted = {{1'b1}, frs2_forwarding_out[22:0], {8{1'b0}}};
    end
end

always_comb begin : floating_cal
    if (frs1_forwarding_out[31] == (frs2_forwarding_out[31] ^ inst[20])) begin // add
        fraction_cal_result = {1'b0, frs1_fraction_shifted} + {1'b0, frs2_fraction_shifted};
    end
    else begin // sub
        fraction_cal_result = {1'b0, frs1_fraction_shifted} - {1'b0, frs2_fraction_shifted};
        if (frs2_fraction_shifted > frs1_fraction_shifted) begin
            fraction_cal_result = {1'b0, frs2_fraction_shifted} - {1'b0, frs1_fraction_shifted};
        end
    end
end

// logic [11:0] lead_one_1; // 1: +12
// logic [5:0] lead_one_2; // 1: +6
// logic [2:0] lead_one_3; // 1: +3
logic [15:0] lead_one_1; // 1: +16
logic [7:0] lead_one_2; // 1: +8
logic [3:0] lead_one_3; // 1: +4
logic [1:0] lead_one_4; // 1: +2
logic [4:0] lead_one_index;

always_comb begin : floating_leading_one
    lead_one_1 = 16'b0;
    lead_one_2 = 8'b0;
    lead_one_3 = 4'b0;
    lead_one_4 = 2'b0;
    lead_one_index = 5'b0;
    if (fraction_cal_result[32]) begin // carry
        lead_one_index = 5'b0;
    end
    else begin
        lead_one_1 = (|fraction_cal_result[31:16]) ? fraction_cal_result[31:16] : fraction_cal_result[15:0];
        lead_one_2 = (|lead_one_1[15:8]) ? lead_one_1[15:8] : lead_one_1[7:0];
        lead_one_3 = (|lead_one_2[7:4]) ? lead_one_2[7:4] : lead_one_2[3:0];
        lead_one_4 = (|lead_one_3[3:2]) ? lead_one_3[3:2] : lead_one_3[1:0];
        // lead_one_index = 5'b10000 & {5{(|fraction_cal_result[31:16])}}
        //                + 5'b01000 & {5{(|lead_one_1[15:8])}}
        //                + 5'b00100 & {5{(|lead_one_2[7:4])}}
        //                + 5'b00010 & {5{(|lead_one_3[3:2])}}
        //                + 5'b00001 & {5{(|lead_one_4[1])}};
        lead_one_index = {(|fraction_cal_result[31:16]),
                          (|lead_one_1[15:8]),
                          (|lead_one_2[7:4]),
                          (|lead_one_3[3:2]),
                          (lead_one_4[1])};
    end
end

always_comb begin : floating_rounded
    exp_rounded = exp_in;
    fraction_rounded = fraction_cal_result[30:8];
    fraction_cal_result_shifted = fraction_cal_result;
    if (fraction_cal_result[32]) begin // carry
        exp_rounded = exp_in + 8'b1;
        fraction_rounded = fraction_cal_result[31:9];
        if (fraction_cal_result[8] & fraction_cal_result[9]) begin // +1
        // if (fraction_cal_result[8]) begin // +1
            fraction_rounded = fraction_cal_result[31:9] + 23'b1;
        end
    end
    else if (fraction_cal_result == 33'b0) begin // 0
        fraction_rounded = 23'b0;
        exp_rounded = 8'b0;
    end
    else begin
        exp_rounded = exp_in - (31 - lead_one_index);
        fraction_cal_result_shifted = (fraction_cal_result << (31 - lead_one_index));
        fraction_rounded = fraction_cal_result_shifted[30:8];
        // if (fraction_cal_result[7] & fraction_cal_result[8]) begin // +1
        if (fraction_cal_result[7]) begin // +1
            fraction_rounded = fraction_cal_result_shifted[30:8] + 23'b1;
        end
    end
end

always_comb begin : floatuing_sign_bit
    if (frs1_fraction_shifted > frs2_fraction_shifted) begin
        sign_bit_result = frs1_forwarding_out[31];
    end
    else begin
        sign_bit_result = frs2_forwarding_out[31] ^ inst[20];
    end
end

always_comb begin : FPU_result
    // sign bit
    f_alu_result_comb[31] = sign_bit_result;
    // exp bits
    f_alu_result_comb[30:23] = exp_rounded;
    // fraction bits
    f_alu_result_comb[22:0] = fraction_rounded;
end

endmodule