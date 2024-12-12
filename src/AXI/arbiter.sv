// `include "AXI_define.svh"

module arbiter (
    input clk,
    input rst,

    // master 0
	input  [`AXI_ID_BITS-1:0] ID_M0,
    input  [`AXI_ADDR_BITS-1:0] ADDR_M0,
    input  [`AXI_LEN_BITS-1:0] LEN_M0,
    input  [`AXI_SIZE_BITS-1:0] SIZE_M0,
    input  [1:0] BURST_M0,
    input  VALID_M0,

	// master 1
	input  [`AXI_ID_BITS-1:0] ID_M1,
    input  [`AXI_ADDR_BITS-1:0] ADDR_M1,
    input  [`AXI_LEN_BITS-1:0] LEN_M1,
    input  [`AXI_SIZE_BITS-1:0] SIZE_M1,
    input  [1:0] BURST_M1,
    input  VALID_M1,

    // master 2
	input  [`AXI_ID_BITS-1:0] ID_M2,
    input  [`AXI_ADDR_BITS-1:0] ADDR_M2,
    input  [`AXI_LEN_BITS-1:0] LEN_M2,
    input  [`AXI_SIZE_BITS-1:0] SIZE_M2,
    input  [1:0] BURST_M2,
    input  VALID_M2,
	
    // slave
    output  logic   [`AXI_IDS_BITS-1:0] ID_S,
    output  logic   [`AXI_ADDR_BITS-1:0] ADDR_S,
    output  logic   [`AXI_LEN_BITS-1:0] LEN_S,
    output  logic   [`AXI_SIZE_BITS-1:0] SIZE_S,
    output  logic   [1:0] BURST_S,
    output  logic   VALID_S,
	input  READY_S,

    // connect info
    output logic [1:0] occupied_M,

    // decoder
    input M0_req,
    input M1_req,
    input M2_req
);

// parameter for occupied_M
parameter O_IDLE = 2'b00;
parameter O_M0 = 2'b01;
parameter O_M1 = 2'b10;
parameter O_M2 = 2'b11;

logic LOCK_M0;
logic LOCK_M1;
logic LOCK_M2;
logic LOCK_M0_comb;
logic LOCK_M1_comb;
logic LOCK_M2_comb;
// logic [1:0] occupied_M;

logic READY_S_reg;
logic READY_S_comb;

always_ff @( posedge clk or negedge rst ) begin : ready_reg
    if (~rst) begin
        READY_S_reg <= 1'b0;
    end
    else begin
        READY_S_reg <= READY_S_comb;
    end
end

always_comb begin : ready_comb
    READY_S_comb = READY_S_reg;
    if (READY_S) begin
        READY_S_comb = READY_S; // update READY_S
    end
end

always_ff@(posedge clk or negedge rst) begin : lock_reg
    if(~rst)begin
        LOCK_M0 <= 1'b0;
        LOCK_M1 <= 1'b0;
        LOCK_M2 <= 1'b0;
    end
    else begin
        LOCK_M0 <= LOCK_M0_comb;	
        LOCK_M1 <= LOCK_M1_comb;	
        LOCK_M2 <= LOCK_M2_comb;	
    end
end

always_comb begin : lock_M0_comb
    LOCK_M0_comb = LOCK_M0;
    if (LOCK_M0 & READY_S) begin
        LOCK_M0_comb = 1'b0;
    end
    else if (~LOCK_M2 & M0_req & VALID_M0 & ~VALID_M1 & ~READY_S) begin
        LOCK_M0_comb = 1'b1;
    end
end

always_comb begin : lock_M1_comb
    LOCK_M1_comb = LOCK_M1;
    if (LOCK_M1 & READY_S) begin
        LOCK_M1_comb = 1'b0;
    end
    else if (~LOCK_M0 & ~LOCK_M2 & M1_req & VALID_M1 & ~READY_S) begin
        LOCK_M1_comb = 1'b1;
    end
end

always_comb begin : lock_M2_comb
    LOCK_M2_comb = LOCK_M2;
    if (LOCK_M2 & READY_S) begin
        LOCK_M2_comb = 1'b0;
    end
    else if (M2_req & VALID_M2 & ~VALID_M0 & ~VALID_M1 & ~READY_S) begin
        LOCK_M2_comb = 1'b1;
    end
end

always_comb begin : occupied_src
    occupied_M = O_IDLE;
    if((VALID_M1 & M1_req & ~LOCK_M0 & ~LOCK_M2) | LOCK_M1)
        occupied_M = O_M1;
    else if ((VALID_M0 & M0_req & ~LOCK_M2) | LOCK_M0)
        occupied_M = O_M0;
    else if ((VALID_M2 & M2_req) | LOCK_M2) begin
        occupied_M = O_M2;
    end
end

always_comb begin : output_signals
        ID_S = `AXI_IDS_BITS'b0;
        ADDR_S = `AXI_ADDR_BITS'b0;
        LEN_S = `AXI_LEN_BITS'b0;
        SIZE_S = `AXI_SIZE_BITS'b0;
        BURST_S = 2'b0;
        VALID_S = 1'b0;
        // READY_M0 = 1'b0;
        // READY_M1 = 1'b0;
		case(occupied_M)
			O_M0: begin
				ID_S = {4'b0001,ID_M0};
                ADDR_S = ADDR_M0;
                LEN_S = LEN_M0;
                SIZE_S = SIZE_M0;
                BURST_S = BURST_M0;
                VALID_S = VALID_M0 & (!(READY_S_reg & ~READY_S));
            end
			O_M1: begin
				ID_S = {4'b0010,ID_M1};
                ADDR_S = ADDR_M1;
                LEN_S = LEN_M1;
                SIZE_S = SIZE_M1;
                BURST_S = BURST_M1;
                VALID_S = VALID_M1 & (!(READY_S_reg & ~READY_S));
            end
            O_M2: begin
                ID_S = {4'b0011,ID_M2};
                ADDR_S = ADDR_M2;
                LEN_S = LEN_M2;
                SIZE_S = SIZE_M2;
                BURST_S = BURST_M2;
                VALID_S = VALID_M2 & (!(READY_S_reg & ~READY_S));
            end
		endcase
	end

endmodule