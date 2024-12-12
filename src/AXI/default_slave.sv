// `include "AXI_define.svh"

module default_slave (
    input CLK,
	input RST,

	// Read Address Signals
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST, // only INCR type
	input ARVALID,
	output logic ARREADY,

	// Read Data Signals
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,

	// Write Address Signals
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST, // only INCR type
	input AWVALID,
	output logic AWREADY,

	// Write Data Signals
	input [`AXI_DATA_BITS-1:0] WDATA,
    input [`AXI_STRB_BITS-1:0] WSTRB,
    input WLAST,
    input WVALID,
    output logic WREADY,

	// Write Response Signals
	output logic [`AXI_IDS_BITS-1:0] BID,
    output logic [1:0] BRESP,
    output logic BVALID,
    input BREADY
);

// length counter 
logic [`AXI_LEN_BITS-1:0] lens_counter;
logic [`AXI_LEN_BITS-1:0] lens_counter_comb;

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

always_ff @( posedge CLK or negedge RST ) begin : FSM_cur
	if (~RST) begin
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
			if (AWVALID & AWREADY) begin
				nxt_state = WRITE;
			end
			else if (ARVALID & ARREADY) begin
				nxt_state = READ;
			end
		end 
		READ: begin
			// if (RREADY & RVALID & RLAST) begin
			if (RREADY & RLAST) begin
				nxt_state = IDLE;
			end
		end
		WRITE: begin
			if (WREADY & WVALID & WLAST) begin
			// if (WVALID & WLAST) begin
				nxt_state = WRITE_RESP;
			end
		end
		WRITE_RESP: begin
			if (BREADY & BVALID) begin
				nxt_state = IDLE;
			end
		end
	endcase
end

always_ff @( posedge CLK or negedge RST ) begin : input_temp_reg
	if (~RST) begin
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
		if (ARVALID & ARREADY) begin
			ARID_comb = ARID;
			ARLEN_comb  = ARLEN;
			SIZE_comb = ARSIZE;
		end
		if (AWVALID & AWREADY) begin
			AWID_comb = AWID;
			AWLEN_comb = AWLEN;
			SIZE_comb = AWSIZE;
		end
	end 
end

always_ff @( posedge CLK or negedge RST ) begin : addr_control_reg
	if (~RST) begin
		ADDR_reg <= `AXI_ADDR_BITS'b0;
	end
	else begin
		ADDR_reg <= ADDR_comb;
	end
end

always_ff @( posedge CLK or negedge RST ) begin : LEN_counter
	if (~RST) begin
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
			if (RREADY & RVALID) begin
				lens_counter_comb = lens_counter + `AXI_LEN_BITS'b1;
			end
		end
		WRITE: begin
			if (WREADY & WVALID) begin
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
	ARREADY = 1'b0;
	RID = ARID_reg;
	RDATA = `AXI_DATA_BITS'b0;
	RRESP = `AXI_RESP_DECERR;
	RLAST = 1'b0;
	RVALID = 1'b0;
	// write
	AWREADY = 1'b0;
	WREADY = 1'b0;
	BID = AWID_reg;
	BRESP = `AXI_RESP_DECERR;
	BVALID = 1'b0;
	case (cur_state)
		IDLE: begin
			ARREADY = 1'b1;
			AWREADY = 1'b1;
		end 
		READ: begin
			RVALID = 1'b1;
            // RLAST = 1'b1;
			if (ARLEN_reg == lens_counter) begin
				RLAST = 1'b1;
			end
		end
		WRITE: begin
			WREADY = 1'b1;
		end
		WRITE_RESP: begin
			BVALID = 1'b1;
		end
	endcase
end
    
endmodule