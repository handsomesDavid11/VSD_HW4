// `include "AXI_define.svh"
// `include "arbiter.sv"
// `include "decoder.sv"
// for vip
// `include "arbiter.sv"
// `include "decoder.sv"

module AW_channel (
    input clk,
    input rst,

    // connect info
    // output logic [1:0] M0_connect_info,
    // output logic [1:0] M1_connect_info,
    output logic [1:0] occupied_SD_comb,
    output logic [1:0] occupied_S0_comb,
    output logic [1:0] occupied_S1_comb,
    output logic [1:0] occupied_S2_comb,
    output logic [1:0] occupied_S3_comb,
    output logic [1:0] occupied_S4_comb,
    output logic [1:0] occupied_S5_comb,

    // SLAVE INTERFACE FOR MASTERS
    // WRITE ADDRESS0
	input [`AXI_ID_BITS-1:0] AWID_M0,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M0,
	input [`AXI_LEN_BITS-1:0] AWLEN_M0,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
	input [1:0] AWBURST_M0,
	input AWVALID_M0,
	output logic AWREADY_M0,

    // WRITE ADDRESS1
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,

    // WRITE ADDRESS2
	input [`AXI_ID_BITS-1:0] AWID_M2,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M2,
	input [`AXI_LEN_BITS-1:0] AWLEN_M2,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M2,
	input [1:0] AWBURST_M2,
	input AWVALID_M2,
	output logic AWREADY_M2,

    // MASTER INTERFACE FOR SLAVES
    // default slave
    output logic [`AXI_IDS_BITS-1:0] AWID_SD,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_SD,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_SD,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_SD,
	output logic [1:0] AWBURST_SD,
	output logic AWVALID_SD,
	input AWREADY_SD,

    // WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,

    // WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,

    // WRITE ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
	input AWREADY_S2,

    // WRITE ADDRESS3
	output logic [`AXI_IDS_BITS-1:0] AWID_S3,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output logic [1:0] AWBURST_S3,
	output logic AWVALID_S3,
	input AWREADY_S3,

    // WRITE ADDRESS4
	output logic [`AXI_IDS_BITS-1:0] AWID_S4,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output logic [1:0] AWBURST_S4,
	output logic AWVALID_S4,
	input AWREADY_S4,

    // WRITE ADDRESS5
	output logic [`AXI_IDS_BITS-1:0] AWID_S5,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output logic [1:0] AWBURST_S5,
	output logic AWVALID_S5,
	input AWREADY_S5
);

// parameter for occupied_M
parameter O_IDLE = 2'b00;
parameter O_M0 = 2'b01;
parameter O_M1 = 2'b10;
parameter O_M2 = 2'b11;

// connect info
// logic [1:0] occupied_SD_comb;
// logic [1:0] occupied_S0_comb;
// logic [1:0] occupied_S1_comb;
// logic [1:0] occupied_S2_comb;
// logic [1:0] occupied_S3_comb;
// logic [1:0] occupied_S4_comb;
// logic [1:0] occupied_S5_comb;

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
logic decoder_AWREADY_M0;
logic decoder_AWREADY_M1;
logic decoder_ARREADY_M2;


// M0 decoder 
assign decoder_AWREADY_M0 = 1'b0;
assign M0_SD_req = 1'b0;
assign M0_S0_req = 1'b0;
assign M0_S1_req = 1'b0;
assign M0_S2_req = 1'b0;
assign M0_S3_req = 1'b0;
assign M0_S4_req = 1'b0;
assign M0_S5_req = 1'b0;

// M0 AWREADY logic
always_comb begin : M0_AWREADY_logic
    AWREADY_M0 = 1'b0;
    if (occupied_SD_comb == O_M0
        || occupied_S0_comb == O_M0
        || occupied_S1_comb == O_M0
        || occupied_S2_comb == O_M0
        || occupied_S3_comb == O_M0
        || occupied_S4_comb == O_M0
        || occupied_S5_comb == O_M0) begin
        AWREADY_M0 = decoder_AWREADY_M0 & AWVALID_M0;
    end
end

// M1 decoder 
decoder AW_decoder_M1(
    .addr(AWADDR_M1),
    .ARREADY_SD(AWREADY_SD),
    .ARREADY_S0(AWREADY_S0),
    .ARREADY_S1(AWREADY_S1),
    .ARREADY_S2(AWREADY_S2),
    .ARREADY_S3(AWREADY_S3),
    .ARREADY_S4(AWREADY_S4),
    .ARREADY_S5(AWREADY_S5),
    .ARREADY_M(decoder_AWREADY_M1),
    .SD_req(M1_SD_req),
    .S0_req(M1_S0_req),
    .S1_req(M1_S1_req),
    .S2_req(M1_S2_req),
    .S3_req(M1_S3_req),
    .S4_req(M1_S4_req),
    .S5_req(M1_S5_req)
);

// M1 AWREADY logic
always_comb begin : M1_AWREADY_logic
    AWREADY_M1 = 1'b0;
    if (occupied_SD_comb == O_M1
        || occupied_S0_comb == O_M1
        || occupied_S1_comb == O_M1
        || occupied_S2_comb == O_M1
        || occupied_S3_comb == O_M1
        || occupied_S4_comb == O_M1
        || occupied_S5_comb == O_M1) begin
        AWREADY_M1 = decoder_AWREADY_M1 & AWVALID_M1;
    end
end

// M2 decoder 
decoder AW_decoder_M2(
    .addr(AWADDR_M2),
    .ARREADY_SD(AWREADY_SD),
    .ARREADY_S0(AWREADY_S0),
    .ARREADY_S1(AWREADY_S1),
    .ARREADY_S2(AWREADY_S2),
    .ARREADY_S3(AWREADY_S3),
    .ARREADY_S4(AWREADY_S4),
    .ARREADY_S5(AWREADY_S5),
    .ARREADY_M(decoder_AWREADY_M2),
    .SD_req(M2_SD_req),
    .S0_req(M2_S0_req),
    .S1_req(M2_S1_req),
    .S2_req(M2_S2_req),
    .S3_req(M2_S3_req),
    .S4_req(M2_S4_req),
    .S5_req(M2_S5_req)
);

// M2 AWREADY logic
always_comb begin : M2_AWREADY_logic
    AWREADY_M2 = 1'b0;
    if (occupied_SD_comb == O_M2
        || occupied_S0_comb == O_M2
        || occupied_S1_comb == O_M2
        || occupied_S2_comb == O_M2
        || occupied_S3_comb == O_M2
        || occupied_S4_comb == O_M2
        || occupied_S5_comb == O_M2) begin
        AWREADY_M2 = decoder_AWREADY_M2 & AWVALID_M2;
    end
end

// default slave
arbiter AW_arbiter_SD(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(AWID_M0),
    .ADDR_M0(AWADDR_M0),
    .LEN_M0(AWLEN_M0),
    .SIZE_M0(AWSIZE_M0),
    .BURST_M0(AWBURST_M0),
    .VALID_M0(AWVALID_M0),

	// master 1
	.ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    // master 2
	.ID_M2(AWID_M2),
    .ADDR_M2(AWADDR_M2),
    .LEN_M2(AWLEN_M2),
    .SIZE_M2(AWSIZE_M2),
    .BURST_M2(AWBURST_M2),
    .VALID_M2(AWVALID_M2),
	
    // slave
    .ID_S(AWID_SD),
    .ADDR_S(AWADDR_SD),
    .LEN_S(AWLEN_SD),
    .SIZE_S(AWSIZE_SD),
    .BURST_S(AWBURST_SD),
    .VALID_S(AWVALID_SD),
	.READY_S(AWREADY_SD),

    // connect info
    .occupied_M(occupied_SD_comb),

    // info from decoder
    .M0_req(M0_SD_req),
    .M1_req(M1_SD_req),
    .M2_req(M2_SD_req)
);

// slave 0
arbiter AW_arbiter_S0(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(AWID_M0),
    .ADDR_M0(AWADDR_M0),
    .LEN_M0(AWLEN_M0),
    .SIZE_M0(AWSIZE_M0),
    .BURST_M0(AWBURST_M0),
    .VALID_M0(AWVALID_M0),

	// master 1
	.ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    // master 2
	.ID_M2(AWID_M2),
    .ADDR_M2(AWADDR_M2),
    .LEN_M2(AWLEN_M2),
    .SIZE_M2(AWSIZE_M2),
    .BURST_M2(AWBURST_M2),
    .VALID_M2(AWVALID_M2),
	
    // slave
    .ID_S(AWID_S0),
    .ADDR_S(AWADDR_S0),
    .LEN_S(AWLEN_S0),
    .SIZE_S(AWSIZE_S0),
    .BURST_S(AWBURST_S0),
    .VALID_S(AWVALID_S0),
	.READY_S(AWREADY_S0),

    // connect info
    .occupied_M(occupied_S0_comb),

    // info from decoder
    .M0_req(M0_S0_req),
    .M1_req(M1_S0_req),
    .M2_req(M2_S0_req)
);

// slave 1
arbiter AW_arbiter_S1(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(AWID_M0),
    .ADDR_M0(AWADDR_M0),
    .LEN_M0(AWLEN_M0),
    .SIZE_M0(AWSIZE_M0),
    .BURST_M0(AWBURST_M0),
    .VALID_M0(AWVALID_M0),

	// master 1
	.ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    // master 2
	.ID_M2(AWID_M2),
    .ADDR_M2(AWADDR_M2),
    .LEN_M2(AWLEN_M2),
    .SIZE_M2(AWSIZE_M2),
    .BURST_M2(AWBURST_M2),
    .VALID_M2(AWVALID_M2),
	
    // slave
    .ID_S(AWID_S1),
    .ADDR_S(AWADDR_S1),
    .LEN_S(AWLEN_S1),
    .SIZE_S(AWSIZE_S1),
    .BURST_S(AWBURST_S1),
    .VALID_S(AWVALID_S1),
	.READY_S(AWREADY_S1),

    // connect info
    .occupied_M(occupied_S1_comb),

    // info from decoder
    .M0_req(M0_S1_req),
    .M1_req(M1_S1_req),
    .M2_req(M2_S1_req)
);

// slave 2
arbiter AW_arbiter_S2(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(AWID_M0),
    .ADDR_M0(AWADDR_M0),
    .LEN_M0(AWLEN_M0),
    .SIZE_M0(AWSIZE_M0),
    .BURST_M0(AWBURST_M0),
    .VALID_M0(AWVALID_M0),

	// master 1
	.ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    // master 2
	.ID_M2(AWID_M2),
    .ADDR_M2(AWADDR_M2),
    .LEN_M2(AWLEN_M2),
    .SIZE_M2(AWSIZE_M2),
    .BURST_M2(AWBURST_M2),
    .VALID_M2(AWVALID_M2),
	
    // slave
    .ID_S(AWID_S2),
    .ADDR_S(AWADDR_S2),
    .LEN_S(AWLEN_S2),
    .SIZE_S(AWSIZE_S2),
    .BURST_S(AWBURST_S2),
    .VALID_S(AWVALID_S2),
	.READY_S(AWREADY_S2),

    // connect info
    .occupied_M(occupied_S2_comb),

    // info from decoder
    .M0_req(M0_S2_req),
    .M1_req(M1_S2_req),
    .M2_req(M2_S2_req)
);

// slave 3
arbiter AW_arbiter_S3(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(AWID_M0),
    .ADDR_M0(AWADDR_M0),
    .LEN_M0(AWLEN_M0),
    .SIZE_M0(AWSIZE_M0),
    .BURST_M0(AWBURST_M0),
    .VALID_M0(AWVALID_M0),

	// master 1
	.ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    // master 2
	.ID_M2(AWID_M2),
    .ADDR_M2(AWADDR_M2),
    .LEN_M2(AWLEN_M2),
    .SIZE_M2(AWSIZE_M2),
    .BURST_M2(AWBURST_M2),
    .VALID_M2(AWVALID_M2),
	
    // slave
    .ID_S(AWID_S3),
    .ADDR_S(AWADDR_S3),
    .LEN_S(AWLEN_S3),
    .SIZE_S(AWSIZE_S3),
    .BURST_S(AWBURST_S3),
    .VALID_S(AWVALID_S3),
	.READY_S(AWREADY_S3),

    // connect info
    .occupied_M(occupied_S3_comb),

    // info from decoder
    .M0_req(M0_S3_req),
    .M1_req(M1_S3_req),
    .M2_req(M2_S3_req)
);

// slave 4
arbiter AW_arbiter_S4(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(AWID_M0),
    .ADDR_M0(AWADDR_M0),
    .LEN_M0(AWLEN_M0),
    .SIZE_M0(AWSIZE_M0),
    .BURST_M0(AWBURST_M0),
    .VALID_M0(AWVALID_M0),

	// master 1
	.ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    // master 2
	.ID_M2(AWID_M2),
    .ADDR_M2(AWADDR_M2),
    .LEN_M2(AWLEN_M2),
    .SIZE_M2(AWSIZE_M2),
    .BURST_M2(AWBURST_M2),
    .VALID_M2(AWVALID_M2),
	
    // slave
    .ID_S(AWID_S4),
    .ADDR_S(AWADDR_S4),
    .LEN_S(AWLEN_S4),
    .SIZE_S(AWSIZE_S4),
    .BURST_S(AWBURST_S4),
    .VALID_S(AWVALID_S4),
	.READY_S(AWREADY_S4),

    // connect info
    .occupied_M(occupied_S4_comb),

    // info from decoder
    .M0_req(M0_S4_req),
    .M1_req(M1_S4_req),
    .M2_req(M2_S4_req)
);

// slave 5
arbiter AW_arbiter_S5(
	.clk(clk),
    .rst(rst),

    // master 0
	.ID_M0(AWID_M0),
    .ADDR_M0(AWADDR_M0),
    .LEN_M0(AWLEN_M0),
    .SIZE_M0(AWSIZE_M0),
    .BURST_M0(AWBURST_M0),
    .VALID_M0(AWVALID_M0),

	// master 1
	.ID_M1(AWID_M1),
    .ADDR_M1(AWADDR_M1),
    .LEN_M1(AWLEN_M1),
    .SIZE_M1(AWSIZE_M1),
    .BURST_M1(AWBURST_M1),
    .VALID_M1(AWVALID_M1),

    // master 2
	.ID_M2(AWID_M2),
    .ADDR_M2(AWADDR_M2),
    .LEN_M2(AWLEN_M2),
    .SIZE_M2(AWSIZE_M2),
    .BURST_M2(AWBURST_M2),
    .VALID_M2(AWVALID_M2),
	
    // slave
    .ID_S(AWID_S5),
    .ADDR_S(AWADDR_S5),
    .LEN_S(AWLEN_S5),
    .SIZE_S(AWSIZE_S5),
    .BURST_S(AWBURST_S5),
    .VALID_S(AWVALID_S5),
	.READY_S(AWREADY_S5),

    // connect info
    .occupied_M(occupied_S5_comb),

    // info from decoder
    .M0_req(M0_S5_req),
    .M1_req(M1_S5_req),
    .M2_req(M2_S5_req)
);

endmodule