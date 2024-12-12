
module CSR (
    input clk,
    input rst,

    input CSR_inst, // from ID_EXE_reg
    input [24:0] inst, // from ID_EXE_reg
    input [31:0] pc_in, // from ID_EXE_reg
    input external_interrupt_flag,
    input timer_interrupt_flag,
    input [31:0] forward_rs1_data, // from EXE
    input [31:0] CSR_counter_output, // from CSR_counter
    // input [2:0] CSR_op, // from EXE

    output logic [1:0] CSR_counter_type, // to CSR_counter
    output logic MRET_flag, // make PC <= mepc 
    output logic WFI_stall, // CPU stall until interrupt
    output logic [31:0] mepc_out, // interrupt return PC
    output logic [31:0] mtvec_out, // Interrupt service routine PC
    output logic [31:0] CSR_output // to EXE for rd data
);

// register width
// parameter XLEN = 32;
// Machine status register
logic [31:0] mstatus;
logic [31:0] mstatus_comb;
// Machine interrupt-enable register
logic [31:0] mie;
logic [31:0] mie_comb;
// Machine Trap-Vector Base-Address register
logic [31:0] mtvec;
logic [31:0] mtvec_comb;
// Machine exception program counter
logic [31:0] mepc;
logic [31:0] mepc_comb;
// Machine interrupt pending register
logic [31:0] mip;
logic [31:0] mip_comb;

logic mstatus_en;
logic mie_en;
logic mtvec_en;
logic mepc_en;
logic mip_en;
logic rd_en;

// status indicator
logic MRET_en;
logic WFI_en;
logic WFI_en_reg;

// CSR_op type
localparam Privileged = 3'b000; // MRET, WFI
localparam CSRRW = 3'b001;
localparam CSRRS = 3'b010; // CSRRS, RD
localparam CSRRC = 3'b011;
// localparam NO_CSR = 3'b100; // NO CSR
localparam CSRRWI = 3'b101;
localparam CSRRSI = 3'b110;
localparam CSRRCI = 3'b111;

assign mtvec = 32'h00010000;
always_ff @( posedge clk or posedge rst ) begin : CSR_registers
    if (rst) begin
        mstatus <= 32'b0;
        mie <= 32'b0;
        // mtvec <= 32'b0;
        mepc <= 32'b0;
        mip <= 32'b0;
    end
    else begin
        // mstatus <= mstatus_comb;
        mstatus <= {{19{1'b0}}, mstatus_comb[12:11],
                    {3{1'b0}}, mstatus_comb[7],
                    {3{1'b0}}, mstatus_comb[3],
                    {3{1'b0}}};
        // mie <= mie_comb;
        mie <= {{20{1'b0}}, mie_comb[11],
                {3{1'b0}}, mie_comb[7],
                {7{1'b0}}};
        // mtvec <= mtvec_comb;
        mepc <= mepc_comb;
        // mip <= mip_comb;
        mip <= {{20{1'b0}}, mip_comb[11],
                {3{1'b0}}, mip_comb[7],
                {7{1'b0}}};
    end
end

always_comb begin : csr_decoder
    mstatus_en = 1'b0;
    mie_en = 1'b0;
    mtvec_en = 1'b0;
    mepc_en = 1'b0;
    mip_en = 1'b0;
    MRET_en = 1'b0;
    // WFI_en = 1'b0;
    WFI_en = WFI_en_reg;
    CSR_counter_type = 2'd0;
    rd_en = 1'b0;
    case (inst[24:13])
        12'h300: begin
            mstatus_en = 1'b1;
        end
        12'h304: begin
            mie_en = 1'b1;
        end
        12'h305: begin 
            mtvec_en = 1'b1;
        end
        12'h341: begin
            mepc_en = 1'b1;
        end
        12'h344: begin
            mip_en = 1'b1;
        end
        12'b001100000010: begin
            MRET_en = 1'b1;
        end
        12'b000100000101: begin
            WFI_en = 1'b1;
        end
        12'b110010000010: begin
            rd_en = 1'b1;
            CSR_counter_type = 2'd0;
        end
        12'b110000000010: begin
            rd_en = 1'b1;
            CSR_counter_type = 2'd1;
        end
        12'b110010000000: begin
            rd_en = 1'b1;
            CSR_counter_type = 2'd2;
        end
        12'b110000000000: begin
            rd_en = 1'b1;
            CSR_counter_type = 2'd3;
        end 
    endcase
    // release WFI_stall
    if (external_interrupt_flag | timer_interrupt_flag) begin
        WFI_en = 1'b0;
    end
end

always_comb begin : rd_output
    CSR_output = 32'b0;
    case (inst[24:13])
        12'h300: begin
            CSR_output = mstatus;
        end
        12'h304: begin
            CSR_output = mie;
        end
        12'h305: begin 
            CSR_output = mtvec;
        end
        12'h341: begin
            CSR_output = mepc;
        end
        12'h344: begin
            CSR_output = mip;
        end
        12'b110010000010,
        12'b110000000010,
        12'b110010000000,
        12'b110000000000: begin
            CSR_output = CSR_counter_output;
        end 
    endcase
end

always_ff @( posedge clk or posedge rst ) begin : WFI_stall_control_reg
    if (rst) begin
        WFI_en_reg <= 1'b0;
    end
    else begin
        WFI_en_reg <= WFI_en;
    end
end

always_comb begin : WFI_stall_control
    WFI_stall = 1'b0;
    if (WFI_en | WFI_en_reg) begin
        WFI_stall = 1'b1;
    end
end

always_comb begin : MRET_flag_control
    MRET_flag = MRET_en;
end

always_comb begin : CSR_mstatus_comb
    mstatus_comb = mstatus;
    // if (external_interrupt_flag | timer_interrupt_flag) begin // interrupt taken
    if (external_interrupt_flag) begin // interrupt taken
        mstatus_comb[12:11] = 2'b11; // MPP, machine mode
        mstatus_comb[7] = mstatus[3]; // MPIE <= MIE
        mstatus_comb[3] = 1'b0; // MIE <= 0
    end
    else if (CSR_inst) begin
        if (MRET_en & inst[7:5] == Privileged) begin // interrupt return
            mstatus_comb[12:11] = 2'b11; // MPP, machine mode
            mstatus_comb[7] = 1'b1; // MPIE <= 1
            mstatus_comb[3] = mstatus[7]; // MIE <= MPIE
        end
        else if (mstatus_en) begin
            case (inst[7:5]) // funct3
                // Privileged: begin
                    
                // end
                CSRRW: begin
                    mstatus_comb = forward_rs1_data;
                end
                CSRRS: begin
                    if (inst[12:8] != 5'b0) begin
                        mstatus_comb = mstatus | forward_rs1_data;
                    end
                end
                CSRRC: begin
                    if (inst[12:8] != 5'b0) begin
                        mstatus_comb = mstatus & (~forward_rs1_data);
                    end
                end
                CSRRWI: begin
                    mstatus_comb = {{27{1'b0}}, inst[12:8]};
                end
                CSRRSI: begin
                    if (inst[12:8] != 5'b0) begin
                        mstatus_comb = mstatus | ({{27{1'b0}}, inst[12:8]});
                    end
                end
                CSRRCI: begin
                    if (inst[12:8] != 5'b0) begin
                        mstatus_comb = mstatus & (~({{27{1'b0}}, inst[12:8]}));
                    end
                end
            endcase
        end
    end
end

always_comb begin : CSR_mie_comb
    mie_comb = mie;
    if (CSR_inst & mie_en) begin
        case (inst[7:5]) // funct3
            // Privileged: begin
                
            // end
            CSRRW: begin
                mie_comb = forward_rs1_data;
            end
            CSRRS: begin
                if (inst[12:8] != 5'b0) begin
                    mie_comb = mie | forward_rs1_data;
                end
            end
            CSRRC: begin
                if (inst[12:8] != 5'b0) begin
                    mie_comb = mie & (~forward_rs1_data);
                end
            end
            CSRRWI: begin
                mie_comb = {{27{1'b0}}, inst[12:8]};
            end
            CSRRSI: begin
                if (inst[12:8] != 5'b0) begin
                    mie_comb = mie | ({{27{1'b0}}, inst[12:8]});
                end
            end
            CSRRCI: begin
                if (inst[12:8] != 5'b0) begin
                    mie_comb = mie & (~({{27{1'b0}}, inst[12:8]}));
                end
            end
        endcase
    end
    // keep timer interrupt enable
    // mie_comb[7] = 1'b1;
end

assign mtvec_out = mtvec;
/*
always_comb begin : CSR_mtvec_comb
    mtvec_comb = mtvec;
    if (CSR_inst) begin
        case (inst[7:5]) // funct3
            Privileged: begin
                
            end
            CSRRW: begin
                
            end
            CSRRS: begin
                
            end
            CSRRC: begin
                
            end
            CSRRWI: begin
                
            end
            CSRRSI: begin
                
            end
            CSRRCI: begin
                
            end
        endcase
    end
end
*/

assign mepc_out = mepc;
always_comb begin : CSR_mepc_comb
    mepc_comb = mepc;
    if (WFI_en & ~WFI_en_reg) begin // WFI trigger
        mepc_comb = pc_in + 32'd4; // instruction after WFI
    end
    else if (external_interrupt_flag & ~(WFI_en | WFI_en_reg)) begin
        mepc_comb = pc_in; // current instruction
    end
    else if (CSR_inst & mepc_en) begin
        case (inst[7:5]) // funct3
            // Privileged: begin
                
            // end
            CSRRW: begin
                mepc_comb = forward_rs1_data;
            end
            CSRRS: begin
                if (inst[12:8] != 5'b0) begin
                    mepc_comb = mie | forward_rs1_data;
                end
            end
            CSRRC: begin
                if (inst[12:8] != 5'b0) begin
                    mepc_comb = mie & (~forward_rs1_data);
                end
            end
            CSRRWI: begin
                mepc_comb = {{27{1'b0}}, inst[12:8]};
            end
            CSRRSI: begin
                if (inst[12:8] != 5'b0) begin
                    mepc_comb = mie | ({{27{1'b0}}, inst[12:8]});
                end
            end
            CSRRCI: begin
                if (inst[12:8] != 5'b0) begin
                    mepc_comb = mie & (~({{27{1'b0}}, inst[12:8]}));
                end
            end
        endcase
    end
end

always_comb begin : CSR_mip_comb
    mip_comb = mip;
    if (external_interrupt_flag) begin
        mip_comb[11] = 1'b1; 
    end
    else if (timer_interrupt_flag) begin
        mip_comb[7] = 1'b1;
    end
    else if (CSR_inst & MRET_en & inst[7:5] == Privileged) begin //interrupt return
        mip_comb = 32'b0;        
    end
    /*
    if (CSR_inst & mip_en) begin
        case (inst[7:5]) // funct3
            // Privileged: begin

            // end
            CSRRW: begin
                mip_comb = forward_rs1_data;
            end
            CSRRS: begin
                if (inst[12:8] != 5'b0) begin
                    mip_comb = mip | forward_rs1_data;
                end
            end
            CSRRC: begin
                if (inst[12:8] != 5'b0) begin
                    mip_comb = mip & (~forward_rs1_data);
                end
            end
            CSRRWI: begin
                mip_comb = {{27{1'b0}}, inst[12:8]};
            end
            CSRRSI: begin
                if (inst[12:8] != 5'b0) begin
                    mip_comb = mip | ({{27{1'b0}}, inst[12:8]});
                end
            end
            CSRRCI: begin
                if (inst[12:8] != 5'b0) begin
                    mip_comb = mip & (~({{27{1'b0}}, inst[12:8]}));
                end
            end
        endcase
    end
    */
end

endmodule