// `include "AXI_define.svh"
// for synthesize
// `include "AXI/arbiter_R.sv"
// `include "AXI/decoder_S.sv"
// for vip
// `include "arbiter_R.sv"
// `include "decoder_S.sv"

module R_channel (
    input clk,
    input rst,

    // SLAVE INTERFACE FOR MASTERS
    // READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,

    //READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	//READ DATA2
	output logic [`AXI_ID_BITS-1:0] RID_M2,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M2,
	output logic [1:0] RRESP_M2,
	output logic RLAST_M2,
	output logic RVALID_M2,
	input RREADY_M2,

    // MASTER INTERFACE FOR SLAVES
    // default slave
    input [`AXI_IDS_BITS-1:0] RID_SD,
	input [`AXI_DATA_BITS-1:0] RDATA_SD,
	input [1:0] RRESP_SD,
	input RLAST_SD,
	input RVALID_SD,
	output logic RREADY_SD,

    // READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,

    // READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,

	// READ DATA2
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2,

	// READ DATA3
	input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output logic RREADY_S3,

	// READ DATA4
	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output logic RREADY_S4,

	// READ DATA5
	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output logic RREADY_S5
);

parameter DR = 1'b0; // default master ready

parameter O_IDLE = 3'b000;
parameter O_SD = 3'b001;
parameter O_S0 = 3'b010;
parameter O_S1 = 3'b011;
parameter O_S2 = 3'b100;
parameter O_S3 = 3'b101;
parameter O_S4 = 3'b110;
parameter O_S5 = 3'b111;

logic SD_M0_req;
logic SD_M1_req;
logic SD_M2_req;
logic S0_M0_req;
logic S0_M1_req;
logic S0_M2_req;
logic S1_M0_req;
logic S1_M1_req;
logic S1_M2_req;
logic S2_M0_req;
logic S2_M1_req;
logic S2_M2_req;
logic S3_M0_req;
logic S3_M1_req;
logic S3_M2_req;
logic S4_M0_req;
logic S4_M1_req;
logic S4_M2_req;
logic S5_M0_req;
logic S5_M1_req;
logic S5_M2_req;

logic [2:0] occupied_M0;
logic [2:0] occupied_M1;
logic [2:0] occupied_M2;

logic decoder_RREADY_SD;
logic decoder_RREADY_S0;
logic decoder_RREADY_S1;
logic decoder_RREADY_S2;
logic decoder_RREADY_S3;
logic decoder_RREADY_S4;
logic decoder_RREADY_S5;
  
// default slave decoder
decoder_S R_decoder_SD(
    .ID(RID_SD[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_M2(RREADY_M2),
    .RREADY_S(decoder_RREADY_SD),
    .M0_req(SD_M0_req),
    .M1_req(SD_M1_req),
    .M2_req(SD_M2_req)
);

// SD RREADY logic
always_comb begin : SD_RREADY_logic
	RREADY_SD = 1'b0;
	if (occupied_M0 == O_SD
		|| occupied_M1 == O_SD
		|| occupied_M2 == O_SD) begin
		RREADY_SD = decoder_RREADY_SD & RVALID_SD;
	end
end

// S0 decoder
decoder_S R_decoder_S0(
    .ID(RID_S0[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_M2(RREADY_M2),
    .RREADY_S(decoder_RREADY_S0),
    .M0_req(S0_M0_req),
    .M1_req(S0_M1_req),
    .M2_req(S0_M2_req)
);

// S0 RREADY logic
always_comb begin : S0_RREADY_logic
	RREADY_S0 = 1'b0;
	if (occupied_M0 == O_S0
		|| occupied_M1 == O_S0
		|| occupied_M2 == O_S0) begin
		RREADY_S0 = decoder_RREADY_S0 & RVALID_S0;
	end
end

// S1 decoder
decoder_S R_decoder_S1(
    .ID(RID_S1[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_M2(RREADY_M2),
    .RREADY_S(decoder_RREADY_S1),
    .M0_req(S1_M0_req),
    .M1_req(S1_M1_req),
    .M2_req(S1_M2_req)
);

// S1 RREADY logic
always_comb begin : S1_RREADY_logic
	RREADY_S1 = 1'b0;
	if (occupied_M0 == O_S1
		|| occupied_M1 == O_S1
		|| occupied_M2 == O_S1) begin
		RREADY_S1 = decoder_RREADY_S1 & RVALID_S1;
	end
end

// S2 decoder
decoder_S R_decoder_S2(
    .ID(RID_S2[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_M2(RREADY_M2),
    .RREADY_S(decoder_RREADY_S2),
    .M0_req(S2_M0_req),
    .M1_req(S2_M1_req),
    .M2_req(S2_M2_req)
);

// S2 RREADY logic
always_comb begin : S2_RREADY_logic
	RREADY_S2 = 1'b0;
	if (occupied_M0 == O_S2
		|| occupied_M1 == O_S2
		|| occupied_M2 == O_S2) begin
		RREADY_S2 = decoder_RREADY_S2 & RVALID_S2;
	end
end

// S3 decoder
decoder_S R_decoder_S3(
    .ID(RID_S3[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_M2(RREADY_M2),
    .RREADY_S(decoder_RREADY_S3),
    .M0_req(S3_M0_req),
    .M1_req(S3_M1_req),
    .M2_req(S3_M2_req)
);

// S3 RREADY logic
always_comb begin : S3_RREADY_logic
	RREADY_S3 = 1'b0;
	if (occupied_M0 == O_S3
		|| occupied_M1 == O_S3
		|| occupied_M2 == O_S3) begin
		RREADY_S3 = decoder_RREADY_S3 & RVALID_S3;
	end
end

// S4 decoder
decoder_S R_decoder_S4(
    .ID(RID_S4[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_M2(RREADY_M2),
    .RREADY_S(decoder_RREADY_S4),
    .M0_req(S4_M0_req),
    .M1_req(S4_M1_req),
    .M2_req(S4_M2_req)
);

// S4 RREADY logic
always_comb begin : S4_RREADY_logic
	RREADY_S4 = 1'b0;
	if (occupied_M0 == O_S4
		|| occupied_M1 == O_S4
		|| occupied_M2 == O_S4) begin
		RREADY_S4 = decoder_RREADY_S4 & RVALID_S4;
	end
end

// S5 decoder
decoder_S R_decoder_S5(
    .ID(RID_S5[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_M2(RREADY_M2),
    .RREADY_S(decoder_RREADY_S5),
    .M0_req(S5_M0_req),
    .M1_req(S5_M1_req),
    .M2_req(S5_M2_req)
);

// S5 RREADY logic
always_comb begin : S5_RREADY_logic
	RREADY_S5 = 1'b0;
	if (occupied_M0 == O_S5
		|| occupied_M1 == O_S5
		|| occupied_M2 == O_S5) begin
		RREADY_S5 = decoder_RREADY_S5 & RVALID_S5;
	end
end

// master 0
arbiter_R R_arbiter_M0 (
    .clk(clk),
    .rst(rst),

    // default slave
    .RID_SD(RID_SD),
	.RDATA_SD(RDATA_SD),
	.RRESP_SD(RRESP_SD),
	.RLAST_SD(RLAST_SD),
	.RVALID_SD(RVALID_SD),

    // slave 0
    .RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),

    // slave 1
    .RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),

	// slave 2
	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),

	// slave 3
	.RID_S3(RID_S3),
	.RDATA_S3(RDATA_S3),
	.RRESP_S3(RRESP_S3),
	.RLAST_S3(RLAST_S3),
	.RVALID_S3(RVALID_S3),

	// slave 4
	.RID_S4(RID_S4),
	.RDATA_S4(RDATA_S4),
	.RRESP_S4(RRESP_S4),
	.RLAST_S4(RLAST_S4),
	.RVALID_S4(RVALID_S4),

	// slave 5
	.RID_S5(RID_S5),
	.RDATA_S5(RDATA_S5),
	.RRESP_S5(RRESP_S5),
	.RLAST_S5(RLAST_S5),
	.RVALID_S5(RVALID_S5),

    // master
    .RID_M(RID_M0),
	.RDATA_M(RDATA_M0),
	.RRESP_M(RRESP_M0),
	.RLAST_M(RLAST_M0),
	.RVALID_M(RVALID_M0),
	.RREADY_M(RREADY_M0),

	// connect info
	.occupied_S(occupied_M0),

    // decoder
    .SD_req(SD_M0_req),
    .S0_req(S0_M0_req),
    .S1_req(S1_M0_req),
    .S2_req(S2_M0_req),
    .S3_req(S3_M0_req),
    .S4_req(S4_M0_req),
    .S5_req(S5_M0_req)
);

// master 1
arbiter_R R_arbiter_M1 (
    .clk(clk),
    .rst(rst),

    // default slave
    .RID_SD(RID_SD),
	.RDATA_SD(RDATA_SD),
	.RRESP_SD(RRESP_SD),
	.RLAST_SD(RLAST_SD),
	.RVALID_SD(RVALID_SD),

    // slave 0
    .RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),

    // slave 1
    .RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),

	// slave 2
	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),

	// slave 3
	.RID_S3(RID_S3),
	.RDATA_S3(RDATA_S3),
	.RRESP_S3(RRESP_S3),
	.RLAST_S3(RLAST_S3),
	.RVALID_S3(RVALID_S3),

	// slave 4
	.RID_S4(RID_S4),
	.RDATA_S4(RDATA_S4),
	.RRESP_S4(RRESP_S4),
	.RLAST_S4(RLAST_S4),
	.RVALID_S4(RVALID_S4),

	// slave 5
	.RID_S5(RID_S5),
	.RDATA_S5(RDATA_S5),
	.RRESP_S5(RRESP_S5),
	.RLAST_S5(RLAST_S5),
	.RVALID_S5(RVALID_S5),

    // master
    .RID_M(RID_M1),
	.RDATA_M(RDATA_M1),
	.RRESP_M(RRESP_M1),
	.RLAST_M(RLAST_M1),
	.RVALID_M(RVALID_M1),
	.RREADY_M(RREADY_M1),

	// connect info
	.occupied_S(occupied_M1),

    // decoder
    .SD_req(SD_M1_req),
    .S0_req(S0_M1_req),
    .S1_req(S1_M1_req),
    .S2_req(S2_M1_req),
    .S3_req(S3_M1_req),
    .S4_req(S4_M1_req),
    .S5_req(S5_M1_req)
);

// master 2
arbiter_R R_arbiter_M2 (
    .clk(clk),
    .rst(rst),

    // default slave
    .RID_SD(RID_SD),
	.RDATA_SD(RDATA_SD),
	.RRESP_SD(RRESP_SD),
	.RLAST_SD(RLAST_SD),
	.RVALID_SD(RVALID_SD),

    // slave 0
    .RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),

    // slave 1
    .RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),

	// slave 2
	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),

	// slave 3
	.RID_S3(RID_S3),
	.RDATA_S3(RDATA_S3),
	.RRESP_S3(RRESP_S3),
	.RLAST_S3(RLAST_S3),
	.RVALID_S3(RVALID_S3),

	// slave 4
	.RID_S4(RID_S4),
	.RDATA_S4(RDATA_S4),
	.RRESP_S4(RRESP_S4),
	.RLAST_S4(RLAST_S4),
	.RVALID_S4(RVALID_S4),

	// slave 5
	.RID_S5(RID_S5),
	.RDATA_S5(RDATA_S5),
	.RRESP_S5(RRESP_S5),
	.RLAST_S5(RLAST_S5),
	.RVALID_S5(RVALID_S5),

    // master
    .RID_M(RID_M2),
	.RDATA_M(RDATA_M2),
	.RRESP_M(RRESP_M2),
	.RLAST_M(RLAST_M2),
	.RVALID_M(RVALID_M2),
	.RREADY_M(RREADY_M2),

	// connect info
	.occupied_S(occupied_M2),

    // decoder
    .SD_req(SD_M2_req),
    .S0_req(S0_M2_req),
    .S1_req(S1_M2_req),
    .S2_req(S2_M2_req),
    .S3_req(S3_M2_req),
    .S4_req(S4_M2_req),
    .S5_req(S5_M2_req)
);

endmodule