//`include "../include/AXI_define.svh"

module SRAM_wrapper (
	input ACLK,
	input ARESETn,

	// Read Address Signals
	input [`AXI_IDS_BITS-1:0] ARID_S,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input [`AXI_LEN_BITS-1:0] ARLEN_S,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input [1:0] ARBURST_S, // only INCR type
	input ARVALID_S,
	output logic ARREADY_S,

	// Read Data Signals
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input RREADY_S,

	// Write Address Signals
	input [`AXI_IDS_BITS-1:0] AWID_S,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input [`AXI_LEN_BITS-1:0] AWLEN_S,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input [1:0] AWBURST_S, // only INCR type
	input AWVALID_S,
	output logic AWREADY_S,

	// Write Data Signals
	input [`AXI_DATA_BITS-1:0] WDATA_S,
    input [`AXI_STRB_BITS-1:0] WSTRB_S,
    input WLAST_S,
    input WVALID_S,
    output logic WREADY_S,

	// Write Response Signals
	output logic [`AXI_IDS_BITS-1:0] BID_S,
    output logic [1:0] BRESP_S,
    output logic BVALID_S,
    input BREADY_S
);

// wire to SRAM ports
logic CEB;
logic WEB;
logic [31:0] BWEB;
logic [13:0] A;
logic [31:0] DI;
logic [31:0] DO;

logic [31:0] DO_reg;
logic [31:0] DO_comb;

/*
// reg
// Read Address Signals
logic ARREADY_S;
// Read Data Signals
logic [`AXI_IDS_BITS-1:0] RID_S;
logic [`AXI_DATA_BITS-1:0] RDATA_S;
logic [1:0] RRESP_S;
logic RLAST_S;
logic RVALID_S;
// Write Address Signals
logic AWREADY_S;
// Write Data Signals
logic WREADY_S;
// Write Response Signals
logic [`AXI_IDS_BITS-1:0] BID_S;
logic [1:0] BRESP_S;
logic BVALID_S;
*/

// FSM
logic [1:0] cur_state;
logic [1:0] nxt_state;
parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter WRITE = 2'b10;
parameter WRITE_RESP = 2'b11;

// temp registers
logic [`AXI_IDS_BITS-1:0] ARID_reg;
logic [`AXI_IDS_BITS-1:0] ARID_comb;
logic [`AXI_LEN_BITS-1:0] ARLEN_reg;
logic [`AXI_LEN_BITS-1:0] ARLEN_comb;
logic [`AXI_IDS_BITS-1:0] AWID_reg;
logic [`AXI_IDS_BITS-1:0] AWID_comb;
logic [`AXI_LEN_BITS-1:0] AWLEN_reg;
logic [`AXI_LEN_BITS-1:0] AWLEN_comb;
logic [`AXI_ADDR_BITS-1:0] ADDR_reg;
logic [`AXI_ADDR_BITS-1:0] ADDR_comb;
logic [`AXI_SIZE_BITS-1:0] SIZE_reg;
logic [`AXI_SIZE_BITS-1:0] SIZE_comb;

// temp wire
logic [`AXI_SIZE_BITS-1:0] ADDR_offset;

// 

// length counter 
logic [`AXI_LEN_BITS-1:0] lens_counter;
logic [`AXI_LEN_BITS-1:0] lens_counter_comb;

always_ff @( posedge ACLK or negedge ARESETn ) begin : FSM_cur
	if (~ARESETn) begin
		cur_state <= IDLE;
	end
	else begin
		cur_state <= nxt_state;
	end
end

always_comb begin : FSM_nxt
	nxt_state = cur_state;
	case (cur_state)
		IDLE: begin
			if (AWVALID_S & AWREADY_S) begin
				nxt_state = WRITE;
			end
			else if (ARVALID_S & ARREADY_S) begin
				nxt_state = READ;
			end
		end 
		READ: begin
			// if (RREADY_S & RVALID_S & RLAST_S) begin
			if (RREADY_S & RLAST_S) begin
				nxt_state = IDLE;
			end
		end
		WRITE: begin
			if (WREADY_S & WVALID_S & WLAST_S) begin
			// if (WVALID_S & WLAST_S) begin
				nxt_state = WRITE_RESP;
			end
		end
		WRITE_RESP: begin
			if (BREADY_S & BVALID_S) begin
				nxt_state = IDLE;
			end
		end
	endcase
end

always_ff @( posedge ACLK or negedge ARESETn ) begin : input_temp_reg
	if (~ARESETn) begin
		ARID_reg <= `AXI_IDS_BITS'b0;
		ARLEN_reg <= `AXI_LEN_BITS'b0;
		AWID_reg <= `AXI_IDS_BITS'b0;
		AWLEN_reg <= `AXI_LEN_BITS'b0;
		SIZE_reg <= `AXI_SIZE_BITS'b0;
	end
	else begin
		ARID_reg <= ARID_comb;
		ARLEN_reg <= ARLEN_comb;
		AWID_reg <= AWID_comb;
		AWLEN_reg <= AWLEN_comb;
		SIZE_reg <= SIZE_comb;
	end
end

always_comb begin : input_temp_comb
	ARID_comb = ARID_reg; 
	ARLEN_comb = ARLEN_reg; 
	AWID_comb = AWID_reg; 
	AWLEN_comb = AWLEN_reg;
	SIZE_comb = SIZE_reg;
	if (cur_state == IDLE) begin // to save handshake info
		if (ARVALID_S & ARREADY_S) begin
			ARID_comb = ARID_S;
			ARLEN_comb  = ARLEN_S;
			SIZE_comb = ARSIZE_S;
		end
		if (AWVALID_S & AWREADY_S) begin
			AWID_comb = AWID_S;
			AWLEN_comb = AWLEN_S;
			SIZE_comb = AWSIZE_S;
		end
	end 
end

always_ff @( posedge ACLK or negedge ARESETn ) begin : addr_control_reg
	if (~ARESETn) begin
		ADDR_reg <= `AXI_ADDR_BITS'b0;
	end
	else begin
		ADDR_reg <= ADDR_comb;
	end
end

assign ADDR_offset = `AXI_LEN_BITS'b1 << SIZE_reg;

always_comb begin : addr_control_comb
	ADDR_comb = ADDR_reg;
	case (cur_state)
		IDLE: begin // start address
			if (AWVALID_S & AWREADY_S) begin
				ADDR_comb = AWADDR_S;
			end
			else if (ARVALID_S & ARREADY_S) begin
				ADDR_comb = ARADDR_S;
			end
		end 
		READ: begin
			if (lens_counter > `AXI_LEN_BITS'b0
				& RREADY_S & RVALID_S) begin
				ADDR_comb = ADDR_reg + ADDR_offset;
			end
		end
		WRITE: begin // INCR aligned
			if (lens_counter > `AXI_LEN_BITS'b0
				& WREADY_S & WVALID_S) begin
				ADDR_comb = ADDR_reg + ADDR_offset;
			end
		end
		// WRITE: begin // INCR aligned
			
		// end
		// WRITE_RESP: begin
			
		// end
	endcase
end

always_ff @( posedge ACLK or negedge ARESETn ) begin : LEN_counter
	if (~ARESETn) begin
		lens_counter <= `AXI_LEN_BITS'b0;
	end
	else begin
		lens_counter <= lens_counter_comb;
	end
end

always_comb begin : LEN_counter_comb
	lens_counter_comb = lens_counter;
	case (cur_state)
		IDLE: begin
			lens_counter_comb = `AXI_LEN_BITS'b0;
		end 
		READ: begin
			if (RREADY_S & RVALID_S) begin
				lens_counter_comb = lens_counter + `AXI_LEN_BITS'b1;
			end
		end
		WRITE: begin
			if (WREADY_S & WVALID_S) begin
				lens_counter_comb = lens_counter + `AXI_LEN_BITS'b1;
			end
		end
		WRITE_RESP: begin
			lens_counter_comb = `AXI_LEN_BITS'b0;
		end
	endcase
end

always_comb begin : output_signals
	// read
	ARREADY_S = 1'b0;
	RID_S = ARID_reg;
	// RDATA_S = DO_reg;
	RDATA_S = DO_comb;
	RRESP_S = `AXI_RESP_OKAY;
	RLAST_S = 1'b0;
	RVALID_S = 1'b0;
	// write
	AWREADY_S = 1'b0;
	WREADY_S = 1'b0;
	BID_S = AWID_reg;
	BRESP_S = `AXI_RESP_OKAY;
	BVALID_S = 1'b0;
	case (cur_state)
		IDLE: begin
			// ARREADY_S = 1'b1;
			ARREADY_S = ~AWVALID_S;
			AWREADY_S = 1'b1;
		end 
		READ: begin
			RVALID_S = 1'b1;
			if (ARLEN_reg == lens_counter) begin
				RLAST_S = 1'b1;
			end
		end
		WRITE: begin
			WREADY_S = 1'b1;
		end
		WRITE_RESP: begin
			BVALID_S = 1'b1;
		end
	endcase
end

always_ff @( posedge ACLK or negedge ARESETn ) begin : DO_temp_reg
	if (~ARESETn) begin
		DO_reg <= 32'b0;
	end
	else begin
		DO_reg <= DO_comb;
	end
end

always_comb begin : DO_temp_comb
	// DO_comb = DO_reg;
	// if (ARVALID_S) begin // update new DO
	// 	DO_comb = DO;
	// end 
	// DO_comb = DO;
	DO_comb = 32'b0;
	case (cur_state)
		READ: begin
			DO_comb = DO;
		end 
	endcase
end

always_comb begin : sram_control
	CEB = 1'b0;
	WEB = 1'b1; // read
	BWEB = {32{1'b1}};
	// A = ARADDR_S[15:2]; 
	// A = ADDR_reg[15:2]; 
	A = ADDR_comb[15:2]; 
	DI = 32'b0;
	case (cur_state)
		// IDLE: begin
			// A = ARADDR_S[15:2];
		// end 
		// READ: begin
			// A = ADDR_reg[15:2]; 
		// end
		WRITE: begin
			WEB = 1'b0; // write
			if (WVALID_S) begin
				BWEB = {{{8{WSTRB_S[3]}}, {8{WSTRB_S[2]}}, {8{WSTRB_S[1]}}, {8{WSTRB_S[0]}}}};
			end
			// A = AWADDR_S[15:2];
			DI = WDATA_S;
		end
		// WRITE_RESP: begin
			
		// end
	endcase
end

TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
    .SLP(1'b0),
    .DSLP(1'b0),
    .SD(1'b0),
    .PUDELAY(),
    .CLK(ACLK),
	.CEB(CEB),
	.WEB(WEB),
    .A(A),
	.D(DI),
    .BWEB(BWEB),
    .RTSEL(2'b01),
    .WTSEL(2'b01),
    .Q(DO)
);

endmodule
