module MEM (
    input clk,
    input rst,

    input IM_stall,
    input DM_stall,
    input WFI_stall,
    output logic DM_MEM_access,

    input [31:0] pc_2_reg, // from EXE
    input [31:0] alu_result, // from EXE
    input [31:0] forward_rs2_data, // from EXE
    input unsigned_flag, // from EXE
    input rd_src,  // from EXE
    input mem_read_in,  // from EXE
    input mem_write_in,  // from EXE
    input [1:0] data_type,  // from EXE

    input [4:0] rd_addr_in, // from EXE
    input mem_2_reg_src_in, // from EXE
    input reg_write_in, // from EXE

    // input forward_rd_src, // from forwarding unit
    // input [31:0] WB_rd_data, // from WB

    // floating
    input f_reg_write_in, // from EXE, to RF
    input DM_src, // from EXE
    input [31:0] frs2_data, // from EXE
    input [31:0] f_alu_result_in, // from EXE

    output logic f_reg_write, // to RF
    output logic [31:0] f_alu_result, // to WB
    
    input [31:0] DM_out, // from DM d_out

    output logic DM_WEB, // to DM comb, 0: read, 1: write
    // output logic DM_read, // to DM, comb, active high
    output logic [3:0] DM_write, // to DM, comb, active low
    output logic [31:0] DM_addr, // to DM, comb, alu_result[15:2]
    output logic [31:0] DM_data_in, // to DM, comb

    // output logic MEM_reg_write, // to forwarding unit, comb
    // output logic [4:0] MEM_rd_addr, // to forwarding unit, comb
    output logic [31:0] rd_data_comb, // to EXE, comb

    output logic [31:0] rd_data, // to WB
    output logic [31:0] DM_data_out, // to WB
    output logic mem_2_reg_src, // to WB
    output logic [4:0] rd_addr, // to RF
    output logic reg_write // to RF
);

// logic [31:0] rd_data_comb;
logic [31:0] Din_mux_out;
logic [31:0] DM_data_out_comb;

// stall control
logic [31:0] rd_data_comb_stall;
logic [31:0] DM_data_out_comb_stall;
logic mem_2_reg_src_in_stall;
logic [4:0] rd_addr_in_stall;
logic reg_write_in_stall;
logic f_reg_write_in_stall;
logic [31:0] f_alu_result_in_stall;

logic [31:0] memory_data_temp_reg;
logic [31:0] memory_data_temp_comb;

// Load/store data type
localparam NO = 2'b00; // NONE
localparam WD = 2'b01; // word
localparam HW = 2'b10; // half-word
localparam BT = 2'b11; // byte

always_ff @( posedge clk or posedge rst ) begin : MEM_WB_reg
    if (rst) begin
        rd_data <= 32'b0;
        DM_data_out <= 32'b0;
        mem_2_reg_src <= 1'b0;
        rd_addr <= 5'b0;
        reg_write <= 1'b0;
        f_reg_write <= 1'b0;
        f_alu_result <= 32'b0;
    end
    else begin
        rd_data <= rd_data_comb_stall;
        DM_data_out <= DM_data_out_comb_stall;
        mem_2_reg_src <= mem_2_reg_src_in_stall;
        rd_addr <= rd_addr_in_stall;
        reg_write <= reg_write_in_stall;
        f_reg_write <= f_reg_write_in_stall;
        f_alu_result <= f_alu_result_in_stall;
    end
end

always_comb begin : stall_control
    rd_data_comb_stall = rd_data_comb;
    DM_data_out_comb_stall = DM_data_out_comb;
    mem_2_reg_src_in_stall = mem_2_reg_src_in;
    rd_addr_in_stall = rd_addr_in;
    reg_write_in_stall = reg_write_in;
    f_reg_write_in_stall = f_reg_write_in;
    f_alu_result_in_stall = f_alu_result_in;
    if (IM_stall | DM_stall) begin
        rd_data_comb_stall = rd_data; 
        DM_data_out_comb_stall = DM_data_out; 
        mem_2_reg_src_in_stall = mem_2_reg_src; 
        rd_addr_in_stall = rd_addr; 
        reg_write_in_stall = reg_write; 
        f_reg_write_in_stall = f_reg_write; 
        f_alu_result_in_stall = f_alu_result; 
    end
end

assign DM_MEM_access = mem_read_in | mem_write_in;

always_comb begin : Din_MUX
    // if (rst) begin
    //     Din_mux_out = 0;
    // end
    // else begin
        Din_mux_out = forward_rs2_data;
        // if (forward_rd_src) begin
        //     Din_mux_out = WB_rd_data;
        // end
        if (DM_src) begin // from frs2
            Din_mux_out = frs2_data;
        end
    // end
end

always_comb begin : rd_data_MUX
    // if (rst) begin
    //     rd_data_comb = 0;
    // end
    // else begin
        rd_data_comb = alu_result; // from alu 
        if (rd_src) begin
            rd_data_comb = pc_2_reg; // from pc
        end
    // end
end

always_ff @( posedge clk or posedge rst ) begin : data_temp_reg
    if (rst) begin
        memory_data_temp_reg <= 32'b0;
    end
    else begin
        memory_data_temp_reg <= memory_data_temp_comb;
    end
end

always_comb begin : data_temp_comb
    memory_data_temp_comb = memory_data_temp_reg;
    if (mem_read_in) begin
        memory_data_temp_comb = DM_data_out_comb;
    end
end

always_comb begin : mem_control
    // if (rst) begin
    //     DM_read = 0;
    //     DM_write = 4'b1111;
    //     DM_data_in = 0;
    //     DM_addr = 0;
    //     DM_data_out_comb = 0;
    // end
    // else begin
        DM_WEB = 1'b1; // read
        // DM_read = 0;
        DM_write = 4'b1111; 
        DM_data_in = Din_mux_out;
        // DM_addr = alu_result[15:2];
        // DM_addr = {16'b0 ,alu_result[15:2], 2'b00};
        DM_addr = alu_result;
        DM_data_out_comb = memory_data_temp_reg;
        if (mem_read_in) begin
            case (data_type)
                WD: begin
                    // DM_read = 1;
                    DM_data_out_comb = DM_out;
                end 
                HW: begin
                    // DM_read = 1;
                    DM_data_out_comb = {{16{DM_out[15]}}, DM_out[15:0]}; 
                    if (unsigned_flag) begin
                        DM_data_out_comb = {{16{1'b0}}, DM_out[15:0]}; 
                    end
                end
                BT: begin
                    // DM_read = 1;
                    DM_data_out_comb = {{24{DM_out[7]}}, DM_out[7:0]};
                    if (unsigned_flag) begin
                        DM_data_out_comb = {{24{1'b0}}, DM_out[7:0]};
                    end
                end
            endcase
        end
        if (mem_write_in) begin
            DM_data_out_comb = 32'b0;
            DM_WEB = 1'b0;
            case (data_type)
                WD: begin
                    DM_write = 4'b0000;
                    DM_data_in = Din_mux_out;
                end 
                HW: begin
                    // DM_write = 4'b1100;
                    DM_write = 4'b1111;
                    DM_data_in = Din_mux_out;
                    case (alu_result[1])
                        1'b0: begin
                            DM_write = 4'b1100;
                            // DM_write = 4'b0011;
                            DM_data_in = {{16{1'b0}}, Din_mux_out[15:0]};
                        end
                        1'b1: begin
                            DM_write = 4'b0011;
                            // DM_write = 4'b1100;
                            DM_data_in = {Din_mux_out[15:0], {16{1'b0}}};
                        end
                    endcase
                end
                BT: begin
                    // DM_write = 4'b1110;
                    DM_write = 4'b1111;
                    DM_data_in = Din_mux_out;
                    case (alu_result[1:0])
                        2'b00: begin
                            DM_write = 4'b1110;
                            // DM_write = 4'b0111;
                            DM_data_in = {{24{1'b0}}, Din_mux_out[7:0]};
                        end
                        2'b01: begin
                            DM_write = 4'b1101;
                            // DM_write = 4'b1011;
                            DM_data_in = {{16{1'b0}}, Din_mux_out[7:0], {8{1'b0}}};
                        end
                        2'b10: begin
                            DM_write = 4'b1011;
                            // DM_write = 4'b1101;
                            DM_data_in = {{8{1'b0}}, Din_mux_out[7:0], {16{1'b0}}};
                        end
                        2'b11: begin
                            DM_write = 4'b0111;
                            // DM_write = 4'b1110;
                            DM_data_in = {Din_mux_out[7:0], {24{1'b0}}};
                        end
                    endcase
                end
            endcase
        end
    // end
end

endmodule