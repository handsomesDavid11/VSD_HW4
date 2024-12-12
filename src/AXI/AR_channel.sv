// `include "AXI_define.svh"
// for synthesize
// `include "AXI/arbiter.sv"
// `include "AXI/decoder.sv"
// for vip
// `include "arbiter.sv"
// `include "decoder.sv"

module AR_channel (
    input clk,
    input rst,

    // SLAVE INTERFACE FOR MASTERS
    // READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,

    // READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,

    // READ ADDRESS2
	input [`AXI_ID_BITS-1:0] ARID_M2,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M2,
	input [`AXI_LEN_BITS-1:0] ARLEN_M2,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M2,
	input [1:0] ARBURST_M2,
	input ARVALID_M2,
	output logic ARREADY_M2,

    // MASTER INTERFACE FOR SLAVES
    // default slave
    output logic [`AXI_IDS_BITS-1:0] ARID_SD,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_SD,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_SD,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_SD,
	output logic [1:0] ARBURST_SD,
	output logic ARVALID_SD,
	input ARREADY_SD,

    // READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,

    // READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,

    // READ ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
	input ARREADY_S2,

    // READ ADDRESS3
	output logic [`AXI_IDS_BITS-1:0] ARID_S3,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	output logic [1:0] ARBURST_S3,
	output logic ARVALID_S3,
	input ARREADY_S3,

    // READ ADDRESS4
	output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output logic [1:0] ARBURST_S4,
	output logic ARVALID_S4,
	input ARREADY_S4,

    // READ ADDRESS5
	output logic [`AXI_IDS_BITS-1:0] ARID_S5,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output logic [1:0] ARBURST_S5,
	output logic ARVALID_S5,
	input ARREADY_S5
);

// parameter for occupied_M
parameter O_IDLE = 2'b00;
parameter O_M0 = 2'b01;
parameter O_M1 = 2'b10;
parameter O_M2 = 2'b11;

// connect info
logic [1:0] occupied_SD_comb;
logic [1:0] occupied_S0_comb;
logic [1:0] occupied_S1_comb;
logic [1:0] occupied_S2_comb;
logic [1:0] occupied_S3_comb;
logic [1:0] occupied_S4_comb;
logic [1:0] occupied_S5_comb;

// decoder output
logic M0_SD_req;
logic M0_S0_req;
logic M0_S1_req;
logic M0_S2_req;
logic M0_S3_req;
logic M0_S4_req;
logic M0_S5_req;
logic M1_SD_req;
logic M1_S0_req;
logic M1_S1_req;
logic M1_S2_req;
logic M1_S3_req;
logic M1_S4_req;
logic M1_S5_req;
logic M2_SD_req;
logic M2_S0_req;
logic M2_S1_req;
logic M2_S2_req;
logic M2_S3_req;
logic M2_S4_req;
logic M2_S5_req;

// decoder ready signal output
logic decoder_ARREADY_M0;
logic decoder_ARREADY_M1;
logic decoder_ARREADY_M2;

// M0 decoder 
decoder AR_decoder_M0(
    .addr(ARADDR_M0),
    .ARREADY_SD(ARREADY_SD),
    .ARREADY_S0(ARREADY_S0),
    .ARREADY_S1(ARREADY_S1),
    .ARREADY_S2(ARREADY_S2),
    .ARREADY_S3(ARREADY_S3),
    .ARREADY_S4(ARREADY_S4),
    .ARREADY_S5(ARREADY_S5),
    .ARREADY_M(decoder_ARREADY_M0),
    .SD_req(M0_SD_req),
    .S0_req(M0_S0_req),
    .S1_req(M0_S1_req),
    .S2_req(M0_S2_req),
    .S3_req(M0_S3_req),
    .S4_req(M0_S4_req),
    .S5_req(M0_S5_req)
);

// M0 ARREADY logic
always_comb begin : M0_ARREADY_logic
    ARREADY_M0 = 1'b0;
    if (occupied_SD_comb == O_M0
        || occupied_S0_comb == O_M0
        || occupied_S1_comb == O_M0
        || occupied_S2_comb == O_M0
        || occupied_S3_comb == O_M0
        || occupied_S4_comb == O_M0
        || occupied_S5_comb == O_M0) begin
        ARREADY_M0 = decoder_ARREADY_M0 & ARVALID_M0;
    end
    // if (occupied_S2_comb == O_M0) begin
    //     ARREADY_M0 = decoder_ARREADY_M0 & ARVALID_M0;
    // end
    // else if (occupied_S1_comb == O_M0) begin
    //     ARREADY_M0 = decoder_ARREADY_M0 & ARVALID_M0;
    // end
    // else if (occupied_SD_comb == O_M0) begin
    //     ARREADY_M0 = decoder_ARREADY_M0 & ARVALID_M0;
    // end
end

// M1 decoder 
decoder AR_decoder_M1(
    .addr(ARADDR_M1),
    .ARREADY_SD(ARREADY_SD),
    .ARREADY_S0(ARREADY_S0),
    .ARREADY_S1(ARREADY_S1),
    .ARREADY_S2(ARREADY_S2),
    .ARREADY_S3(ARREADY_S3),
    .ARREADY_S4(ARREADY_S4),
    .ARREADY_S5(ARREADY_S5),
    .ARREADY_M(decoder_ARREADY_M1),
    .SD_req(M1_SD_req),
    .S0_req(M1_S0_req),
    .S1_req(M1_S1_req),
    .S2_req(M1_S2_req),
    .S3_req(M1_S3_req),
    .S4_req(M1_S4_req),
    .S5_req(M1_S5_req)
);

// M1 ARREADY logic
always_comb begin : M1_ARREADY_logic
    ARREADY_M1 = 1'b0;
    if (occupied_SD_comb == O_M1
        || occupied_S0_comb == O_M1
        || occupied_S1_comb == O_M1
        || occupied_S2_comb == O_M1
        || occupied_S3_comb == O_M1
        || occupied_S4_comb == O_M1
        || occupied_S5_comb == O_M1) begin
        ARREADY_M1 = decoder_ARREADY_M1 & ARVALID_M1;
    end
end

// M2 decoder 
decoder AR_decoder_M2(
    .addr(ARADDR_M2),
    .ARREADY_SD(ARREADY_SD),
    .ARREADY_S0(ARREADY_S0),
    .ARREADY_S1(ARREADY_S1),
    .ARREADY_S2(ARREADY_S2),
    .ARREADY_S3(ARREADY_S3),
    .ARREADY_S4(ARREADY_S4),
    .ARREADY_S5(ARREADY_S5),
    .ARREADY_M(decoder_ARREADY_M2),
    .SD_req(M2_SD_req),
    .S0_req(M2_S0_req),
    .S1_req(M2_S1_req),
    .S2_req(M2_S2_req),
    .S3_req(M2_S3_req),
    .S4_req(M2_S4_req),
    .S5_req(M2_S5_req)
);

// M2 ARREADY logic
always_comb begin : M2_ARREADY_logic
    ARREADY_M2 = 1'b0;
    if (occupied_SD_comb == O_M2
        || occupied_S0_comb == O_M2
        || occupied_S1_comb == O_M2
        || occupied_S2_comb == O_M2
        || occupied_S3_comb == O_M2
        || occupied_S4_comb == O_M2
        || occupied_S5_comb == O_M2) begin
        ARREADY_M2 = decoder_ARREADY_M2 & ARVALID_M2;
    end
end

// default slave
arbiter AR_arbiter_SD(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

	// master 1
	.ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),

    // master 2
    .ID_M2(ARID_M2),
    .ADDR_M2(ARADDR_M2),
    .LEN_M2(ARLEN_M2),
    .SIZE_M2(ARSIZE_M2),
    .BURST_M2(ARBURST_M2),
    .VALID_M2(ARVALID_M2),
	
    // slave
    .ID_S(ARID_SD),
    .ADDR_S(ARADDR_SD),
    .LEN_S(ARLEN_SD),
    .SIZE_S(ARSIZE_SD),
    .BURST_S(ARBURST_SD),
    .VALID_S(ARVALID_SD),
	.READY_S(ARREADY_SD),

    // connect info
    .occupied_M(occupied_SD_comb),

    // info from decoder
    .M0_req(M0_SD_req),
    .M1_req(M1_SD_req),
    .M2_req(M2_SD_req)
);

// slave 0
arbiter AR_arbiter_S0(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

	// master 1
	.ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),
	
    
    // master 2
    .ID_M2(ARID_M2),
    .ADDR_M2(ARADDR_M2),
    .LEN_M2(ARLEN_M2),
    .SIZE_M2(ARSIZE_M2),
    .BURST_M2(ARBURST_M2),
    .VALID_M2(ARVALID_M2),

    // slave
    .ID_S(ARID_S0),
    .ADDR_S(ARADDR_S0),
    .LEN_S(ARLEN_S0),
    .SIZE_S(ARSIZE_S0),
    .BURST_S(ARBURST_S0),
    .VALID_S(ARVALID_S0),
	.READY_S(ARREADY_S0),

    // connect info
    .occupied_M(occupied_S0_comb),

    // info from decoder
    .M0_req(M0_S0_req),
    .M1_req(M1_S0_req),
    .M2_req(M2_S0_req)
);

// slave 1
arbiter AR_arbiter_S1(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

	// master 1
	.ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),
    
    // master 2
    .ID_M2(ARID_M2),
    .ADDR_M2(ARADDR_M2),
    .LEN_M2(ARLEN_M2),
    .SIZE_M2(ARSIZE_M2),
    .BURST_M2(ARBURST_M2),
    .VALID_M2(ARVALID_M2),

    // slave
    .ID_S(ARID_S1),
    .ADDR_S(ARADDR_S1),
    .LEN_S(ARLEN_S1),
    .SIZE_S(ARSIZE_S1),
    .BURST_S(ARBURST_S1),
    .VALID_S(ARVALID_S1),
	.READY_S(ARREADY_S1),

    // connect info
    .occupied_M(occupied_S1_comb),

    // info from decoder
    .M0_req(M0_S1_req),
    .M1_req(M1_S1_req),
    .M2_req(M2_S1_req)
);

// slave 2
arbiter AR_arbiter_S2(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

	// master 1
	.ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),
    
    // master 2
    .ID_M2(ARID_M2),
    .ADDR_M2(ARADDR_M2),
    .LEN_M2(ARLEN_M2),
    .SIZE_M2(ARSIZE_M2),
    .BURST_M2(ARBURST_M2),
    .VALID_M2(ARVALID_M2),

    // slave
    .ID_S(ARID_S2),
    .ADDR_S(ARADDR_S2),
    .LEN_S(ARLEN_S2),
    .SIZE_S(ARSIZE_S2),
    .BURST_S(ARBURST_S2),
    .VALID_S(ARVALID_S2),
	.READY_S(ARREADY_S2),

    // connect info
    .occupied_M(occupied_S2_comb),

    // info from decoder
    .M0_req(M0_S2_req),
    .M1_req(M1_S2_req),
    .M2_req(M2_S2_req)
);

// slave 3
arbiter AR_arbiter_S3(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

	// master 1
	.ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),
    
    // master 2
    .ID_M2(ARID_M2),
    .ADDR_M2(ARADDR_M2),
    .LEN_M2(ARLEN_M2),
    .SIZE_M2(ARSIZE_M2),
    .BURST_M2(ARBURST_M2),
    .VALID_M2(ARVALID_M2),

    // slave
    .ID_S(ARID_S3),
    .ADDR_S(ARADDR_S3),
    .LEN_S(ARLEN_S3),
    .SIZE_S(ARSIZE_S3),
    .BURST_S(ARBURST_S3),
    .VALID_S(ARVALID_S3),
	.READY_S(ARREADY_S3),

    // connect info
    .occupied_M(occupied_S3_comb),

    // info from decoder
    .M0_req(M0_S3_req),
    .M1_req(M1_S3_req),
    .M2_req(M2_S3_req)
);

// slave 4
arbiter AR_arbiter_S4(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

	// master 1
	.ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),
    
    // master 2
    .ID_M2(ARID_M2),
    .ADDR_M2(ARADDR_M2),
    .LEN_M2(ARLEN_M2),
    .SIZE_M2(ARSIZE_M2),
    .BURST_M2(ARBURST_M2),
    .VALID_M2(ARVALID_M2),

    // slave
    .ID_S(ARID_S4),
    .ADDR_S(ARADDR_S4),
    .LEN_S(ARLEN_S4),
    .SIZE_S(ARSIZE_S4),
    .BURST_S(ARBURST_S4),
    .VALID_S(ARVALID_S4),
	.READY_S(ARREADY_S4),

    // connect info
    .occupied_M(occupied_S4_comb),

    // info from decoder
    .M0_req(M0_S4_req),
    .M1_req(M1_S4_req),
    .M2_req(M2_S4_req)
);

// slave 5
arbiter AR_arbiter_S5(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(ARID_M0),
    .ADDR_M0(ARADDR_M0),
    .LEN_M0(ARLEN_M0),
    .SIZE_M0(ARSIZE_M0),
    .BURST_M0(ARBURST_M0),
    .VALID_M0(ARVALID_M0),

	// master 1
	.ID_M1(ARID_M1),
    .ADDR_M1(ARADDR_M1),
    .LEN_M1(ARLEN_M1),
    .SIZE_M1(ARSIZE_M1),
    .BURST_M1(ARBURST_M1),
    .VALID_M1(ARVALID_M1),
    
    // master 2
    .ID_M2(ARID_M2),
    .ADDR_M2(ARADDR_M2),
    .LEN_M2(ARLEN_M2),
    .SIZE_M2(ARSIZE_M2),
    .BURST_M2(ARBURST_M2),
    .VALID_M2(ARVALID_M2),

    // slave
    .ID_S(ARID_S5),
    .ADDR_S(ARADDR_S5),
    .LEN_S(ARLEN_S5),
    .SIZE_S(ARSIZE_S5),
    .BURST_S(ARBURST_S5),
    .VALID_S(ARVALID_S5),
	.READY_S(ARREADY_S5),

    // connect info
    .occupied_M(occupied_S5_comb),

    // info from decoder
    .M0_req(M0_S5_req),
    .M1_req(M1_S5_req),
    .M2_req(M2_S5_req)
);

endmodule