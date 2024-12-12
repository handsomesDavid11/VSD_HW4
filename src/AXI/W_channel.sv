module W_channel (
    input clk,
    input rst,

    // AW connect info
    // input [1:0] M1_connect_info_reg, 
	// 2'b00: NULL, 2'b01: default slve, 2'b10: slave 1, 2'b11: slave 2
	input [1:0] occupied_SD_comb,
    input [1:0] occupied_S0_comb,
    input [1:0] occupied_S1_comb,
    input [1:0] occupied_S2_comb,
    input [1:0] occupied_S3_comb,
    input [1:0] occupied_S4_comb,
    input [1:0] occupied_S5_comb,

	// AWVALID_S signals
	// input AWVALID_S3,
	// input AWVALID_S0,
	// input AWVALID_S1,
	// input AWVALID_S2,
	// input AWVALID_S3,
	// input AWVALID_S4,
	// input AWVALID_S5,

    //SLAVE INTERFACE FOR MASTERS
    // WRITE DATA1
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,

	// WRITE DATA2
	input [`AXI_DATA_BITS-1:0] WDATA_M2,
	input [`AXI_STRB_BITS-1:0] WSTRB_M2,
	input WLAST_M2,
	input WVALID_M2,
	output logic WREADY_M2,

    //MASTER INTERFACE FOR SLAVES
	// default slave
	output logic [`AXI_DATA_BITS-1:0] WDATA_SD,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_SD,
	output logic WLAST_SD,
	output logic WVALID_SD,
	input WREADY_SD,

    // slave 0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,

    // slave 1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,

	// slave 2
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,

	// slave 3
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic WLAST_S3,
	output logic WVALID_S3,
	input WREADY_S3,

	// slave 4
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic WLAST_S4,
	output logic WVALID_S4,
	input WREADY_S4,

	// slave 5
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic WLAST_S5,
	output logic WVALID_S5,
	input WREADY_S5
);

// write channel transfer start flag
logic [6:0] EN_M1;
logic [6:0] EN_M2;
logic write_en_M1_SD;
logic write_en_M1_S0;
logic write_en_M1_S1;
logic write_en_M1_S2;
logic write_en_M1_S3;
logic write_en_M1_S4;
logic write_en_M1_S5;
logic write_en_M1_SD_comb;
logic write_en_M1_S0_comb;
logic write_en_M1_S1_comb;
logic write_en_M1_S2_comb;
logic write_en_M1_S3_comb;
logic write_en_M1_S4_comb;
logic write_en_M1_S5_comb;
logic write_en_M2_SD;
logic write_en_M2_S0;
logic write_en_M2_S1;
logic write_en_M2_S2;
logic write_en_M2_S3;
logic write_en_M2_S4;
logic write_en_M2_S5;
logic write_en_M2_SD_comb;
logic write_en_M2_S0_comb;
logic write_en_M2_S1_comb;
logic write_en_M2_S2_comb;
logic write_en_M2_S3_comb;
logic write_en_M2_S4_comb;
logic write_en_M2_S5_comb;

// parameter for occupied_M
parameter O_IDLE = 2'b00;
parameter O_M0 = 2'b01;
parameter O_M1 = 2'b10;
parameter O_M2 = 2'b11;

// slave connect src flag
logic M1_SD_flag;
logic M2_SD_flag;
logic M1_S0_flag;
logic M2_S0_flag;
logic M1_S1_flag;
logic M2_S1_flag;
logic M1_S2_flag;
logic M2_S2_flag;
logic M1_S3_flag;
logic M2_S3_flag;
logic M1_S4_flag;
logic M2_S4_flag;
logic M1_S5_flag;
logic M2_S5_flag;

assign EN_M1 = {(((occupied_S5_comb == O_M1) | write_en_M1_S5)),
			(((occupied_S4_comb == O_M1) | write_en_M1_S4)), 
			(((occupied_S3_comb == O_M1) | write_en_M1_S3)), 
			(((occupied_S2_comb == O_M1) | write_en_M1_S2)), 
			(((occupied_S1_comb == O_M1) | write_en_M1_S1)), 
			(((occupied_S0_comb == O_M1) | write_en_M1_S0)), 
			(((occupied_SD_comb == O_M1) | write_en_M1_SD))};

// assign EN_M1 = {(((M1_S5_flag) | write_en_M1_S5)),
// 			(((M1_S4_flag) | write_en_M1_S4)), 
// 			(((M1_S3_flag) | write_en_M1_S3)), 
// 			(((M1_S2_flag) | write_en_M1_S2)), 
// 			(((M1_S1_flag) | write_en_M1_S1)), 
// 			(((M1_S0_flag) | write_en_M1_S0)), 
// 			(((M1_SD_flag) | write_en_M1_SD))};

assign EN_M2 = {(((occupied_S5_comb == O_M2) | write_en_M2_S5)),
			(((occupied_S4_comb == O_M2) | write_en_M2_S4)), 
			(((occupied_S3_comb == O_M2) | write_en_M2_S3)), 
			(((occupied_S2_comb == O_M2) | write_en_M2_S2)), 
			(((occupied_S1_comb == O_M2) | write_en_M2_S1)), 
			(((occupied_S0_comb == O_M2) | write_en_M2_S0)), 
			(((occupied_SD_comb == O_M2) | write_en_M2_SD))};

// assign EN_M2 = {(((M2_S5_flag) | write_en_M2_S5)),
// 			(((M2_S4_flag) | write_en_M2_S4)), 
// 			(((M2_S3_flag) | write_en_M2_S3)), 
// 			(((M2_S2_flag) | write_en_M2_S2)), 
// 			(((M2_S1_flag) | write_en_M2_S1)), 
// 			(((M2_S0_flag) | write_en_M2_S0)), 
// 			(((M2_SD_flag) | write_en_M2_SD))};

always_ff @( posedge clk or negedge rst ) begin : enable_M1_reg
	if (~rst) begin
		write_en_M1_SD <= 1'b0;
		write_en_M1_S0 <= 1'b0;
		write_en_M1_S1 <= 1'b0;
		write_en_M1_S2 <= 1'b0;
		write_en_M1_S3 <= 1'b0;
		write_en_M1_S4 <= 1'b0;
		write_en_M1_S5 <= 1'b0;
	end
	else begin
		write_en_M1_SD <= write_en_M1_SD_comb;
		write_en_M1_S0 <= write_en_M1_S0_comb;
		write_en_M1_S1 <= write_en_M1_S1_comb;
		write_en_M1_S2 <= write_en_M1_S2_comb;
		write_en_M1_S3 <= write_en_M1_S3_comb;
		write_en_M1_S4 <= write_en_M1_S4_comb;
		write_en_M1_S5 <= write_en_M1_S5_comb;
	end
end

always_ff @( posedge clk or negedge rst ) begin : enable_M2_reg
	if (~rst) begin
		write_en_M2_SD <= 1'b0;
		write_en_M2_S0 <= 1'b0;
		write_en_M2_S1 <= 1'b0;
		write_en_M2_S2 <= 1'b0;
		write_en_M2_S3 <= 1'b0;
		write_en_M2_S4 <= 1'b0;
		write_en_M2_S5 <= 1'b0;
	end
	else begin
		write_en_M2_SD <= write_en_M2_SD_comb;
		write_en_M2_S0 <= write_en_M2_S0_comb;
		write_en_M2_S1 <= write_en_M2_S1_comb;
		write_en_M2_S2 <= write_en_M2_S2_comb;
		write_en_M2_S3 <= write_en_M2_S3_comb;
		write_en_M2_S4 <= write_en_M2_S4_comb;
		write_en_M2_S5 <= write_en_M2_S5_comb;
	end
end

always_comb begin : enable_M1_SD_comb
	write_en_M1_SD_comb = write_en_M1_SD;
	if ((occupied_SD_comb == O_M1) & ~WREADY_M1) begin
		write_en_M1_SD_comb = 1'b1;
	end
	else if (WLAST_M1 & WVALID_M1 & WREADY_M1) begin
		write_en_M1_SD_comb = 1'b0;
	end
end

always_comb begin : enable_M1_S0_comb
	write_en_M1_S0_comb = write_en_M1_S0;
	if ((occupied_S0_comb == O_M1) & ~WREADY_M1) begin
		write_en_M1_S0_comb = 1'b1;
	end
	else if (WLAST_M1 & WVALID_M1 & WREADY_M1) begin
		write_en_M1_S0_comb = 1'b0;
	end
end

always_comb begin : enable_M1_S1_comb
	write_en_M1_S1_comb = write_en_M1_S1;
	if ((occupied_S1_comb == O_M1) & ~WREADY_M1) begin
		write_en_M1_S1_comb = 1'b1;
	end
	else if (WLAST_M1 & WVALID_M1 & WREADY_M1) begin
		write_en_M1_S1_comb = 1'b0;
	end
end

always_comb begin : enable_M1_S2_comb
	write_en_M1_S2_comb = write_en_M1_S2;
	if ((occupied_S2_comb == O_M1) & ~WREADY_M1) begin
		write_en_M1_S2_comb = 1'b1;
	end
	else if (WLAST_M1 & WVALID_M1 & WREADY_M1) begin
		write_en_M1_S2_comb = 1'b0;
	end
end

always_comb begin : enable_M1_S3_comb
	write_en_M1_S3_comb = write_en_M1_S3;
	if ((occupied_S3_comb == O_M1) & ~WREADY_M1) begin
		write_en_M1_S3_comb = 1'b1;
	end
	else if (WLAST_M1 & WVALID_M1 & WREADY_M1) begin
		write_en_M1_S3_comb = 1'b0;
	end
end

always_comb begin : enable_M1_S4_comb
	write_en_M1_S4_comb = write_en_M1_S4;
	if ((occupied_S4_comb == O_M1) & ~WREADY_M1) begin
		write_en_M1_S4_comb = 1'b1;
	end
	else if (WLAST_M1 & WVALID_M1 & WREADY_M1) begin
		write_en_M1_S4_comb = 1'b0;
	end
end

always_comb begin : enable_M1_S5_comb
	write_en_M1_S5_comb = write_en_M1_S5;
	if ((occupied_S5_comb == O_M1) & ~WREADY_M1) begin
		write_en_M1_S5_comb = 1'b1;
	end
	else if (WLAST_M1 & WVALID_M1 & WREADY_M1) begin
		write_en_M1_S5_comb = 1'b0;
	end
end

always_comb begin : enable_M2_SD_comb
	write_en_M2_SD_comb = write_en_M2_SD;
	if ((occupied_SD_comb == O_M2) & ~WREADY_M2) begin
		write_en_M2_SD_comb = 1'b1;
	end
	else if (WLAST_M2 & WVALID_M2 & WREADY_M2) begin
		write_en_M2_SD_comb = 1'b0;
	end
end

always_comb begin : enable_M2_S0_comb
	write_en_M2_S0_comb = write_en_M2_S0;
	if ((occupied_S0_comb == O_M2) & ~WREADY_M2) begin
		write_en_M2_S0_comb = 1'b1;
	end
	else if (WLAST_M2 & WVALID_M2 & WREADY_M2) begin
		write_en_M2_S0_comb = 1'b0;
	end
end

always_comb begin : enable_M2_S1_comb
	write_en_M2_S1_comb = write_en_M2_S1;
	if ((occupied_S1_comb == O_M2) & ~WREADY_M2) begin
		write_en_M2_S1_comb = 1'b1;
	end
	else if (WLAST_M2 & WVALID_M2 & WREADY_M2) begin
		write_en_M2_S1_comb = 1'b0;
	end
end

always_comb begin : enable_M2_S2_comb
	write_en_M2_S2_comb = write_en_M2_S2;
	if ((occupied_S2_comb == O_M2) & ~WREADY_M2) begin
		write_en_M2_S2_comb = 1'b1;
	end
	else if (WLAST_M2 & WVALID_M2 & WREADY_M2) begin
		write_en_M2_S2_comb = 1'b0;
	end
end

always_comb begin : enable_M2_S3_comb
	write_en_M2_S3_comb = write_en_M2_S3;
	if ((occupied_S3_comb == O_M2) & ~WREADY_M2) begin
		write_en_M2_S3_comb = 1'b1;
	end
	else if (WLAST_M2 & WVALID_M2 & WREADY_M2) begin
		write_en_M2_S3_comb = 1'b0;
	end
end

always_comb begin : enable_M2_S4_comb
	write_en_M2_S4_comb = write_en_M2_S4;
	if ((occupied_S4_comb == O_M2) & ~WREADY_M2) begin
		write_en_M2_S4_comb = 1'b1;
	end
	else if (WLAST_M2 & WVALID_M2 & WREADY_M2) begin
		write_en_M2_S4_comb = 1'b0;
	end
end

always_comb begin : enable_M2_S5_comb
	write_en_M2_S5_comb = write_en_M2_S5;
	if ((occupied_S5_comb == O_M2) & ~WREADY_M2) begin
		write_en_M2_S5_comb = 1'b1;
	end
	else if (WLAST_M2 & WVALID_M2 & WREADY_M2) begin
		write_en_M2_S5_comb = 1'b0;
	end
end

always_comb begin : output_M1_signals
	WREADY_M1 = 1'b0;
	if (EN_M1[6]) begin // slave 5
		WREADY_M1 = WREADY_S5;
	end
	else if (EN_M1[5]) begin // slave 4
		WREADY_M1 = WREADY_S4;
	end
	else if (EN_M1[4]) begin // slave 3
		WREADY_M1 = WREADY_S3;
	end
	else if (EN_M1[3]) begin // slave 2
		WREADY_M1 = WREADY_S2;
	end
	else if (EN_M1[2]) begin // slave 1
		WREADY_M1 = WREADY_S1;
	end
	else if (EN_M1[1]) begin // slave 0
		WREADY_M1 = WREADY_S0;
	end
	else if (EN_M1[0]) begin // default slave 
		WREADY_M1 = WREADY_SD;
	end
end

always_comb begin : output_M2_signals
	WREADY_M2 = 1'b0;
	if (EN_M2[6]) begin // slave 5
		WREADY_M2 = WREADY_S5;
	end
	else if (EN_M2[5]) begin // slave 4
		WREADY_M2 = WREADY_S4;
	end
	else if (EN_M2[4]) begin // slave 3
		WREADY_M2 = WREADY_S3;
	end
	else if (EN_M2[3]) begin // slave 2
		WREADY_M2 = WREADY_S2;
	end
	else if (EN_M2[2]) begin // slave 1
		WREADY_M2 = WREADY_S1;
	end
	else if (EN_M2[1]) begin // slave 0
		WREADY_M2 = WREADY_S0;
	end
	else if (EN_M2[0]) begin // default slave 
		WREADY_M2 = WREADY_SD;
	end
end

always_comb begin : SD_output_signals
	WDATA_SD = 32'b0;
	WSTRB_SD = 4'b0;
	WLAST_SD = 1'b0;
	WVALID_SD = 1'b0;
	// connect flag
	M1_SD_flag = 1'b0;
	M2_SD_flag = 1'b0;
	// if (occupied_SD_comb == O_M1) begin
	if (EN_M1[0]) begin
		WDATA_SD = WDATA_M1;
		WSTRB_SD = WSTRB_M1;
		WLAST_SD = WLAST_M1;
		WVALID_SD = WVALID_M1;
		M1_SD_flag = 1'b1;
	end
	// else if (occupied_SD_comb == O_M2) begin
	else if (EN_M2[0]) begin
		WDATA_SD = WDATA_M2;
		WSTRB_SD = WSTRB_M2;
		WLAST_SD = WLAST_M2;
		WVALID_SD = WVALID_M2;
		M2_SD_flag = 1'b1;
	end
end

always_comb begin : S0_output_signals
	WDATA_S0 = 32'b0;
	WSTRB_S0 = 4'b0;
	WLAST_S0 = 1'b0;
	WVALID_S0 = 1'b0;
	// connect flag
	M1_S0_flag = 1'b0;
	M2_S0_flag = 1'b0;
	// if (occupied_S0_comb == O_M1) begin
	if (EN_M1[1]) begin
		WDATA_S0 = WDATA_M1;
		WSTRB_S0 = WSTRB_M1;
		WLAST_S0 = WLAST_M1;
		WVALID_S0 = WVALID_M1;
		M1_S0_flag = 1'b1;
	end
	// else if (occupied_S0_comb == O_M2) begin
	else if (EN_M2[1]) begin
		WDATA_S0 = WDATA_M2;
		WSTRB_S0 = WSTRB_M2;
		WLAST_S0 = WLAST_M2;
		WVALID_S0 = WVALID_M2;
		M2_S0_flag = 1'b1;
	end
end

always_comb begin : S1_output_signals
	WDATA_S1 = 32'b0;
	WSTRB_S1 = 4'b0;
	WLAST_S1 = 1'b0;
	WVALID_S1 = 1'b0;
	// connect flag
	M1_S1_flag = 1'b0;
	M2_S1_flag = 1'b0;
	// if (occupied_S1_comb == O_M1) begin
	if (EN_M1[2]) begin
		WDATA_S1 = WDATA_M1;
		WSTRB_S1 = WSTRB_M1;
		WLAST_S1 = WLAST_M1;
		WVALID_S1 = WVALID_M1;
		M1_S1_flag = 1'b1;
	end
	// else if (occupied_S1_comb == O_M2) begin
	else if (EN_M2[2]) begin
		WDATA_S1 = WDATA_M2;
		WSTRB_S1 = WSTRB_M2;
		WLAST_S1 = WLAST_M2;
		WVALID_S1 = WVALID_M2;
		M2_S1_flag = 1'b1;
	end
end

always_comb begin : S2_output_signals
	WDATA_S2 = 32'b0;
	WSTRB_S2 = 4'b0;
	WLAST_S2 = 1'b0;
	WVALID_S2 = 1'b0;
	// connect flag
	M1_S2_flag = 1'b0;
	M2_S2_flag = 1'b0;
	// if (occupied_S2_comb == O_M1) begin
	if (EN_M1[3]) begin
		WDATA_S2 = WDATA_M1;
		WSTRB_S2 = WSTRB_M1;
		WLAST_S2 = WLAST_M1;
		WVALID_S2 = WVALID_M1;
		M1_S2_flag = 1'b1;
	end
	// else if (occupied_S2_comb == O_M2) begin
	else if (EN_M2[3]) begin
		WDATA_S2 = WDATA_M2;
		WSTRB_S2 = WSTRB_M2;
		WLAST_S2 = WLAST_M2;
		WVALID_S2 = WVALID_M2;
		M2_S2_flag = 1'b1;
	end
end

always_comb begin : S3_output_signals
	WDATA_S3 = 32'b0;
	WSTRB_S3 = 4'b0;
	WLAST_S3 = 1'b0;
	WVALID_S3 = 1'b0;
	// connect flag
	M1_S3_flag = 1'b0;
	M2_S3_flag = 1'b0;
	// if (occupied_S3_comb == O_M1) begin
	if (EN_M1[4]) begin
		WDATA_S3 = WDATA_M1;
		WSTRB_S3 = WSTRB_M1;
		WLAST_S3 = WLAST_M1;
		WVALID_S3 = WVALID_M1;
		M1_S3_flag = 1'b1;
	end
	// else if (occupied_S3_comb == O_M2) begin
	else if (EN_M2[4]) begin
		WDATA_S3 = WDATA_M2;
		WSTRB_S3 = WSTRB_M2;
		WLAST_S3 = WLAST_M2;
		WVALID_S3 = WVALID_M2;
		M2_S3_flag = 1'b1;
	end
end

always_comb begin : S4_output_signals
	WDATA_S4 = 32'b0;
	WSTRB_S4 = 4'b0;
	WLAST_S4 = 1'b0;
	WVALID_S4 = 1'b0;
	// connect flag
	M1_S4_flag = 1'b0;
	M2_S4_flag = 1'b0;
	// if (occupied_S4_comb == O_M1) begin
	if (EN_M1[5]) begin
		WDATA_S4 = WDATA_M1;
		WSTRB_S4 = WSTRB_M1;
		WLAST_S4 = WLAST_M1;
		WVALID_S4 = WVALID_M1;
		M1_S4_flag = 1'b1;
	end
	// else if (occupied_S4_comb == O_M2) begin
	else if (EN_M2[5]) begin
		WDATA_S4 = WDATA_M2;
		WSTRB_S4 = WSTRB_M2;
		WLAST_S4 = WLAST_M2;
		WVALID_S4 = WVALID_M2;
		M2_S4_flag = 1'b1;
	end
end

always_comb begin : S5_output_signals
	WDATA_S5 = 32'b0;
	WSTRB_S5 = 4'b0;
	WLAST_S5 = 1'b0;
	WVALID_S5 = 1'b0;
	// connect flag
	M1_S5_flag = 1'b0;
	M2_S5_flag = 1'b0;
	// if (occupied_S5_comb == O_M1) begin
	if (EN_M1[6]) begin
		WDATA_S5 = WDATA_M1;
		WSTRB_S5 = WSTRB_M1;
		WLAST_S5 = WLAST_M1;
		WVALID_S5 = WVALID_M1;
		M1_S5_flag = 1'b1;
	end
	// else if (occupied_S5_comb == O_M2) begin
	else if (EN_M2[6]) begin
		WDATA_S5 = WDATA_M2;
		WSTRB_S5 = WSTRB_M2;
		WLAST_S5 = WLAST_M2;
		WVALID_S5 = WVALID_M2;
		M2_S5_flag = 1'b1;
	end
end

/*
always_comb begin : M1_connect
	// master 1
	WREADY_M1 = 1'b0;

	// default slave
	WDATA_S3 = `AXI_DATA_BITS'b0;
	WSTRB_S3 = `AXI_STRB_BITS'b1111;
	WLAST_S3 = 1'b0;
	WVALID_S3 = 1'b0;

	// slave 1
	WDATA_S0 = `AXI_DATA_BITS'b0;
	WSTRB_S0 = `AXI_STRB_BITS'b1111;
	WLAST_S0 = 1'b0;
	WVALID_S0 = 1'b0;

	// slave 2
	WDATA_S1 = `AXI_DATA_BITS'b0;
	WSTRB_S1 = `AXI_STRB_BITS'b1111;
	WLAST_S1 = 1'b0;
	WVALID_S1 = 1'b0;

	case (M1_connect_info_reg)
		// 2'b00: begin // NULL
			
		// end 
		2'b01: begin // default slave
			// master
			WREADY_M1 = WREADY_S3;
			// slave
			WDATA_S3 = WDATA_M1;
			WSTRB_S3 = WSTRB_M1;
			WLAST_S3 = WLAST_M1;
			WVALID_S3 = WVALID_M1;
		end
		2'b10: begin // slave 1
			// master
			WREADY_M1 = WREADY_S0;
			// slave
			WDATA_S0 = WDATA_M1;
			WSTRB_S0 = WSTRB_M1;
			WLAST_S0 = WLAST_M1;
			WVALID_S0 = WVALID_M1;
		end
		2'b11: begin // slave 2
			// master
			WREADY_M1 = WREADY_S1;
			// slave
			WDATA_S1 = WDATA_M1;
			WSTRB_S1 = WSTRB_M1;
			WLAST_S1 = WLAST_M1;
			WVALID_S1 = WVALID_M1;
		end
	endcase
end
*/

endmodule