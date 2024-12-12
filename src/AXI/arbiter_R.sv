// `include "AXI_define.svh"

module arbiter_R (
    input clk,
    input rst,

    // default slave
    input [`AXI_IDS_BITS-1:0] RID_SD,
	input [`AXI_DATA_BITS-1:0] RDATA_SD,
	input [1:0] RRESP_SD,
	input RLAST_SD,
	input RVALID_SD,

    // slave 0
    input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,

    // slave 1
    input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,

    // slave 2
    input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,

    // slave 3
    input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,

    // slave 4
    input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,

    // slave 5
    input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,

    // master
    output logic [`AXI_ID_BITS-1:0] RID_M,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M,
	output logic [1:0] RRESP_M,
	output logic RLAST_M,
	output logic RVALID_M,
	input RREADY_M,

    // connect info
    output logic [2:0] occupied_S,

    // decoder
    input SD_req,
    input S0_req,
    input S1_req,
    input S2_req,
    input S3_req,
    input S4_req,
    input S5_req
);

logic LOCK_SD;
logic LOCK_S0;
logic LOCK_S1;
logic LOCK_S2;
logic LOCK_S3;
logic LOCK_S4;
logic LOCK_S5;
logic LOCK_SD_comb;
logic LOCK_S0_comb;
logic LOCK_S1_comb;
logic LOCK_S2_comb;
logic LOCK_S3_comb;
logic LOCK_S4_comb;
logic LOCK_S5_comb;

parameter O_IDLE = 3'b000;
parameter O_SD = 3'b001;
parameter O_S0 = 3'b010;
parameter O_S1 = 3'b011;
parameter O_S2 = 3'b100;
parameter O_S3 = 3'b101;
parameter O_S4 = 3'b110;
parameter O_S5 = 3'b111;

always_ff @( posedge clk or negedge rst ) begin : lock_reg
    if (~rst) begin
        LOCK_SD <= 1'b0;
        LOCK_S0 <= 1'b0;
        LOCK_S1 <= 1'b0;
        LOCK_S2 <= 1'b0;
        LOCK_S3 <= 1'b0;
        LOCK_S4 <= 1'b0;
        LOCK_S5 <= 1'b0;
    end
    else begin
        LOCK_SD <= LOCK_SD_comb;
        LOCK_S0 <= LOCK_S0_comb;
        LOCK_S1 <= LOCK_S1_comb;
        LOCK_S2 <= LOCK_S2_comb;
        LOCK_S3 <= LOCK_S3_comb;
        LOCK_S4 <= LOCK_S4_comb;
        LOCK_S5 <= LOCK_S5_comb;
    end
end

always_comb begin : lock_SD_comb
    LOCK_SD_comb = LOCK_SD;
    if (LOCK_SD & RREADY_M & RLAST_SD) begin
        LOCK_SD_comb = 1'b0;
    end
    else if (SD_req & RVALID_SD & ~RVALID_S0 & ~RVALID_S1 & ~RVALID_S2 
            & ~RVALID_S3 & ~RVALID_S4 & ~RVALID_S5 & ~RREADY_M) begin
        LOCK_SD_comb = 1'b1;
    end
end

always_comb begin : lock_S0_comb
    LOCK_S0_comb = LOCK_S0;
    if (LOCK_S0 & RREADY_M & RLAST_S0) begin
        LOCK_S0_comb = 1'b0;
    end
    else if (~LOCK_SD & S0_req & RVALID_S0 & ~RVALID_S1 & ~RVALID_S2 
        & ~RVALID_S3 & ~RVALID_S4 & ~RVALID_S5 & ~RREADY_M) begin
        LOCK_S0_comb = 1'b1;
    end
end

always_comb begin : lock_S1_comb
    LOCK_S1_comb = LOCK_S1;
    if (LOCK_S1 & RREADY_M & RLAST_S1) begin
        LOCK_S1_comb = 1'b0;
    end
    else if (~LOCK_SD & ~LOCK_S0 & S1_req & RVALID_S1 & ~RVALID_S2 
        & ~RVALID_S3 & ~RVALID_S4 & ~RVALID_S5 & ~RREADY_M) begin
        LOCK_S1_comb = 1'b1;
    end
end

always_comb begin : lock_S2_comb
    LOCK_S2_comb = LOCK_S2;
    if (LOCK_S2 & RREADY_M & RLAST_S2) begin
        LOCK_S2_comb = 1'b0;
    end
    else if (~LOCK_SD & ~LOCK_S0 & ~LOCK_S1 & S2_req & RVALID_S2 
        & ~RVALID_S3 & ~RVALID_S4 & ~RVALID_S5 & ~RREADY_M) begin
        LOCK_S2_comb = 1'b1;
    end
end

always_comb begin : lock_S3_comb
    LOCK_S3_comb = LOCK_S3;
    if (LOCK_S3 & RREADY_M & RLAST_S3) begin
        LOCK_S3_comb = 1'b0;
    end
    else if (~LOCK_SD & ~LOCK_S0 & ~LOCK_S1 & ~LOCK_S2 & S3_req
        & RVALID_S3 & ~RVALID_S4 & ~RVALID_S5 & ~RREADY_M) begin
        LOCK_S3_comb = 1'b1;
    end
end

always_comb begin : lock_S4_comb
    LOCK_S4_comb = LOCK_S4;
    if (LOCK_S4 & RREADY_M & RLAST_S4) begin
        LOCK_S4_comb = 1'b0;
    end
    else if (~LOCK_SD & ~LOCK_S0 & ~LOCK_S1 & ~LOCK_S2 & ~LOCK_S3
        & S4_req & RVALID_S4 & ~RVALID_S5 & ~RREADY_M) begin
        LOCK_S4_comb = 1'b1;
    end
end

always_comb begin : lock_S5_comb
    LOCK_S5_comb = LOCK_S5;
    if (LOCK_S5 & RREADY_M & RLAST_S5) begin
        LOCK_S5_comb = 1'b0;
    end
    else if (~LOCK_SD & ~LOCK_S0 & ~LOCK_S1 & ~LOCK_S2 & ~LOCK_S3
        & ~LOCK_S4 & S5_req & RVALID_S5 & ~RREADY_M) begin
        LOCK_S5_comb = 1'b1;
    end
end

always_comb begin : occupied_src
    occupied_S = O_IDLE;
    if(((S5_req & RVALID_S5) & ~LOCK_SD & ~LOCK_S0 & ~LOCK_S1 
        & ~LOCK_S2 & ~LOCK_S3 & ~LOCK_S4) | LOCK_S5)
        occupied_S = O_S5;
    else if(((S4_req & RVALID_S4) & ~LOCK_SD & ~LOCK_S0 & ~LOCK_S1 
        & ~LOCK_S2 & ~LOCK_S3) | LOCK_S4)
        occupied_S = O_S4;
    else if(((S3_req & RVALID_S3) & ~LOCK_SD & ~LOCK_S0 & ~LOCK_S1 
        & ~LOCK_S2) | LOCK_S3)
        occupied_S = O_S3;
    else if(((S2_req & RVALID_S2) & ~LOCK_SD & ~LOCK_S0 & ~LOCK_S1) 
        | LOCK_S2)
        occupied_S = O_S2;
    else if(((S1_req & RVALID_S1) & ~LOCK_SD & ~LOCK_S0) | LOCK_S1)
        occupied_S = O_S1;
    else if (((S0_req & RVALID_S0) & ~LOCK_SD) | LOCK_S0)
        occupied_S = O_S0;
    else if ((SD_req & RVALID_SD) | LOCK_SD)
        occupied_S = O_SD;
end

always_comb begin : output_signals
    RID_M = `AXI_ID_BITS'b0;
    RDATA_M = `AXI_DATA_BITS'b0;
    RRESP_M = 2'b0;
    RLAST_M = 1'b0;
    RVALID_M = 1'b0;
    case(occupied_S)
        O_SD: begin
            RID_M = RID_SD[`AXI_ID_BITS-1:0];
            RDATA_M = RDATA_SD;
            RRESP_M = RRESP_SD;
            RLAST_M = RLAST_SD;
            RVALID_M = RVALID_SD;
        end
        O_S0: begin
            RID_M = RID_S0[`AXI_ID_BITS-1:0];
            RDATA_M = RDATA_S0;
            RRESP_M = RRESP_S0;
            RLAST_M = RLAST_S0;
            RVALID_M = RVALID_S0;
        end
        O_S1: begin
            RID_M = RID_S1[`AXI_ID_BITS-1:0];
            RDATA_M = RDATA_S1;
            RRESP_M = RRESP_S1;
            RLAST_M = RLAST_S1;
            RVALID_M = RVALID_S1;
        end
        O_S2: begin
            RID_M = RID_S2[`AXI_ID_BITS-1:0];
            RDATA_M = RDATA_S2;
            RRESP_M = RRESP_S2;
            RLAST_M = RLAST_S2;
            RVALID_M = RVALID_S2;
        end
        O_S3: begin
            RID_M = RID_S3[`AXI_ID_BITS-1:0];
            RDATA_M = RDATA_S3;
            RRESP_M = RRESP_S3;
            RLAST_M = RLAST_S3;
            RVALID_M = RVALID_S3;
        end
        O_S4: begin
            RID_M = RID_S4[`AXI_ID_BITS-1:0];
            RDATA_M = RDATA_S4;
            RRESP_M = RRESP_S4;
            RLAST_M = RLAST_S4;
            RVALID_M = RVALID_S4;
        end
        O_S5: begin
            RID_M = RID_S5[`AXI_ID_BITS-1:0];
            RDATA_M = RDATA_S5;
            RRESP_M = RRESP_S5;
            RLAST_M = RLAST_S5;
            RVALID_M = RVALID_S5;
        end
    endcase
end

endmodule