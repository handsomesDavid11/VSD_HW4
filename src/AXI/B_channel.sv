// for vip
// `include "decoder_S.sv"
// `include "AXI/arbiter_R.sv"

module B_channel (
    input clk,
    input rst,

	// W_channel connect info
	// input [1:0] M1_connect_info_W_reg,

    // SLAVE INTERFACE FOR MASTERS
    // master 1
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	// master 2
	output logic [`AXI_ID_BITS-1:0] BID_M2,
	output logic [1:0] BRESP_M2,
	output logic BVALID_M2,
	input BREADY_M2,

    // MASTER INTERFACE FOR SLAVES
	// default slave
	input [`AXI_IDS_BITS-1:0] BID_SD,
	input [1:0] BRESP_SD,
	input BVALID_SD,
	output logic BREADY_SD,

    // slave 0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,

    // slave 1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,

	// slave 2
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,

	// slave 3
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic BREADY_S3,

	// slave 4
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4,

	// slave 5
	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output logic BREADY_S5
);

parameter DR = 1'b0; // default master ready
parameter M0R = 1'b0; // master 0 ready

parameter O_IDLE = 3'b000;
parameter O_SD = 3'b001;
parameter O_S0 = 3'b010;
parameter O_S1 = 3'b011;
parameter O_S2 = 3'b100;
parameter O_S3 = 3'b101;
parameter O_S4 = 3'b110;
parameter O_S5 = 3'b111;

logic SD_M1_req;
logic SD_M2_req;
logic S0_M1_req;
logic S0_M2_req;
logic S1_M1_req;
logic S1_M2_req;
logic S2_M1_req;
logic S2_M2_req;
logic S3_M1_req;
logic S3_M2_req;
logic S4_M1_req;
logic S4_M2_req;
logic S5_M1_req;
logic S5_M2_req;

logic [2:0] occupied_M1;
logic [2:0] occupied_M2;

logic decoder_BREADY_SD;
logic decoder_BREADY_S0;
logic decoder_BREADY_S1;
logic decoder_BREADY_S2;
logic decoder_BREADY_S3;
logic decoder_BREADY_S4;
logic decoder_BREADY_S5;

// default slave decoder
decoder_S B_decoder_SD(
    .ID(BID_SD[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(M0R),
    .RREADY_M1(BREADY_M1),
	.RREADY_M2(BREADY_M2),
    .RREADY_S(decoder_BREADY_SD),
    .M1_req(SD_M1_req),
    .M2_req(SD_M2_req)
);

// SD RREADY logic
always_comb begin : SD_RREADY_logic
	BREADY_SD = 1'b0;
	if (occupied_M1 == O_SD
		|| occupied_M2 == O_SD) begin
		BREADY_SD = decoder_BREADY_SD & BVALID_SD;
	end
end

// slave 0 decoder
decoder_S B_decoder_S0(
    .ID(BID_S0[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(M0R),
    .RREADY_M1(BREADY_M1),
	.RREADY_M2(BREADY_M2),
    .RREADY_S(decoder_BREADY_S0),
    .M1_req(S0_M1_req),
    .M2_req(S0_M2_req)
);

// S0 RREADY logic
always_comb begin : S0_RREADY_logic
	BREADY_S0 = 1'b0;
	if (occupied_M1 == O_S0
		|| occupied_M2 == O_S0) begin
		BREADY_S0 = decoder_BREADY_S0 & BVALID_S0;
	end
end

// slave 1 decoder
decoder_S B_decoder_S1(
    .ID(BID_S1[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(M0R),
    .RREADY_M1(BREADY_M1),
	.RREADY_M2(BREADY_M2),
    .RREADY_S(decoder_BREADY_S1),
    .M1_req(S1_M1_req),
    .M2_req(S1_M2_req)
);

// S1 RREADY logic
always_comb begin : S1_RREADY_logic
	BREADY_S1 = 1'b0;
	if (occupied_M1 == O_S1
		|| occupied_M2 == O_S1) begin
		BREADY_S1 = decoder_BREADY_S1 & BVALID_S1;
	end
end

// slave 2 decoder
decoder_S B_decoder_S2(
    .ID(BID_S2[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(M0R),
    .RREADY_M1(BREADY_M1),
	.RREADY_M2(BREADY_M2),
    .RREADY_S(decoder_BREADY_S2),
    .M1_req(S2_M1_req),
    .M2_req(S2_M2_req)
);

// S2 RREADY logic
always_comb begin : S2_RREADY_logic
	BREADY_S2 = 1'b0;
	if (occupied_M1 == O_S2
		|| occupied_M2 == O_S2) begin
		BREADY_S2 = decoder_BREADY_S2 & BVALID_S2;
	end
end

// slave 3 decoder
decoder_S B_decoder_S3(
    .ID(BID_S3[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(M0R),
    .RREADY_M1(BREADY_M1),
	.RREADY_M2(BREADY_M2),
    .RREADY_S(decoder_BREADY_S3),
    .M1_req(S3_M1_req),
    .M2_req(S3_M2_req)
);

// S3 RREADY logic
always_comb begin : S3_RREADY_logic
	BREADY_S3 = 1'b0;
	if (occupied_M1 == O_S3
		|| occupied_M2 == O_S3) begin
		BREADY_S3 = decoder_BREADY_S3 & BVALID_S3;
	end
end

// slave 4 decoder
decoder_S B_decoder_S4(
    .ID(BID_S4[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(M0R),
    .RREADY_M1(BREADY_M1),
	.RREADY_M2(BREADY_M2),
    .RREADY_S(decoder_BREADY_S4),
    .M1_req(S4_M1_req),
    .M2_req(S4_M2_req)
);

// S4 RREADY logic
always_comb begin : S4_RREADY_logic
	BREADY_S4 = 1'b0;
	if (occupied_M1 == O_S4
		|| occupied_M2 == O_S4) begin
		BREADY_S4 = decoder_BREADY_S4 & BVALID_S4;
	end
end

// slave 5 decoder
decoder_S B_decoder_S5(
    .ID(BID_S5[7:4]), // higher 4 bits
    .RREADY_MD(DR),
    .RREADY_M0(M0R),
    .RREADY_M1(BREADY_M1),
	.RREADY_M2(BREADY_M2),
    .RREADY_S(decoder_BREADY_S5),
    .M1_req(S5_M1_req),
    .M2_req(S5_M2_req)
);

// S5 RREADY logic
always_comb begin : S5_RREADY_logic
	BREADY_S5 = 1'b0;
	if (occupied_M1 == O_S5
		|| occupied_M2 == O_S5) begin
		BREADY_S5 = decoder_BREADY_S5 & BVALID_S5;
	end
end

// master 1
arbiter_R B_arbiter_M1 (
    .clk(clk),
    .rst(rst),

    // default slave
    .RID_SD(BID_SD),
	.RDATA_SD(`AXI_DATA_BITS'b0),
	.RRESP_SD(BRESP_SD),
	.RLAST_SD(1'b1),
	.RVALID_SD(BVALID_SD),

    // slave 0
    .RID_S0(BID_S0),
	.RDATA_S0(`AXI_DATA_BITS'b0),
	.RRESP_S0(BRESP_S0),
	.RLAST_S0(1'b1),
	.RVALID_S0(BVALID_S0),

    // slave 1
    .RID_S1(BID_S1),
	.RDATA_S1(`AXI_DATA_BITS'b0),
	.RRESP_S1(BRESP_S1),
	.RLAST_S1(1'b1),
	.RVALID_S1(BVALID_S1),

	// slave 2
    .RID_S2(BID_S2),
	.RDATA_S2(`AXI_DATA_BITS'b0),
	.RRESP_S2(BRESP_S2),
	.RLAST_S2(1'b1),
	.RVALID_S2(BVALID_S2),

    // slave 3
    .RID_S3(BID_S3),
	.RDATA_S3(`AXI_DATA_BITS'b0),
	.RRESP_S3(BRESP_S3),
	.RLAST_S3(1'b1),
	.RVALID_S3(BVALID_S3),

    // slave 4
    .RID_S4(BID_S4),
	.RDATA_S4(`AXI_DATA_BITS'b0),
	.RRESP_S4(BRESP_S4),
	.RLAST_S4(1'b1),
	.RVALID_S4(BVALID_S4),	

    // slave 5
    .RID_S5(BID_S5),
	.RDATA_S5(`AXI_DATA_BITS'b0),
	.RRESP_S5(BRESP_S5),
	.RLAST_S5(1'b1),
	.RVALID_S5(BVALID_S5),

    // master
    .RID_M(BID_M1),
	// .RDATA_M(RDATA_M1),
	.RRESP_M(BRESP_M1),
	// .RLAST_M(RLAST_M1),
	.RVALID_M(BVALID_M1),
	.RREADY_M(BREADY_M1),

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
arbiter_R B_arbiter_M2 (
    .clk(clk),
    .rst(rst),

    // default slave
    .RID_SD(BID_SD),
	.RDATA_SD(`AXI_DATA_BITS'b0),
	.RRESP_SD(BRESP_SD),
	.RLAST_SD(1'b1),
	.RVALID_SD(BVALID_SD),

    // slave 0
    .RID_S0(BID_S0),
	.RDATA_S0(`AXI_DATA_BITS'b0),
	.RRESP_S0(BRESP_S0),
	.RLAST_S0(1'b1),
	.RVALID_S0(BVALID_S0),

    // slave 1
    .RID_S1(BID_S1),
	.RDATA_S1(`AXI_DATA_BITS'b0),
	.RRESP_S1(BRESP_S1),
	.RLAST_S1(1'b1),
	.RVALID_S1(BVALID_S1),

	// slave 2
    .RID_S2(BID_S2),
	.RDATA_S2(`AXI_DATA_BITS'b0),
	.RRESP_S2(BRESP_S2),
	.RLAST_S2(1'b1),
	.RVALID_S2(BVALID_S2),

    // slave 3
    .RID_S3(BID_S3),
	.RDATA_S3(`AXI_DATA_BITS'b0),
	.RRESP_S3(BRESP_S3),
	.RLAST_S3(1'b1),
	.RVALID_S3(BVALID_S3),

    // slave 4
    .RID_S4(BID_S4),
	.RDATA_S4(`AXI_DATA_BITS'b0),
	.RRESP_S4(BRESP_S4),
	.RLAST_S4(1'b1),
	.RVALID_S4(BVALID_S4),	

    // slave 5
    .RID_S5(BID_S5),
	.RDATA_S5(`AXI_DATA_BITS'b0),
	.RRESP_S5(BRESP_S5),
	.RLAST_S5(1'b1),
	.RVALID_S5(BVALID_S5),

    // master
    .RID_M(BID_M2),
	// .RDATA_M(RDATA_M2),
	.RRESP_M(BRESP_M2),
	// .RLAST_M(RLAST_M2),
	.RVALID_M(BVALID_M2),
	.RREADY_M(BREADY_M2),

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

/*
always_comb begin : M1_connect
	// master 1
	BID_M1 = `AXI_ID_BITS'b0;
	BRESP_M1 = `AXI_RESP_DECERR;
	BVALID_M1 = 1'b0;
	// default slave
	BREADY_SD = 1'b0;
	// slave 1
	BREADY_S0 = 1'b0;
	// slave 2
	BREADY_S1 = 1'b0;
	case (M1_connect_info_W_reg)
		2'b01: begin // default slave
			// master 1
			BID_M1 = BID_SD;
			BRESP_M1 = BRESP_SD;
			BVALID_M1 = BVALID_SD;
			// slave
			BREADY_SD = BREADY_M1;
		end 
		2'b10: begin // slave 1
			// master 1
			BID_M1 = BID_S0;
			BRESP_M1 = BRESP_S0;
			BVALID_M1 = BVALID_S0;
			// slave
			BREADY_S0 = BREADY_M1;
		end
		2'b11: begin // slave 2
			// master 1
			BID_M1 = BID_S1;
			BRESP_M1 = BRESP_S1;
			BVALID_M1 = BVALID_S1;
			// slave
			BREADY_S1 = BREADY_M1;
		end
	endcase
end
*/   

endmodule