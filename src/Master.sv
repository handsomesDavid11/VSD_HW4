module Master (
    input   clk,
	input   rst,
    
    // Read Address Signals
	output  logic [`AXI_ID_BITS-1:0] ARID,
	output  logic [`AXI_ADDR_BITS-1:0] ARADDR,
	output  logic [`AXI_LEN_BITS-1:0] ARLEN,
	output  logic [`AXI_SIZE_BITS-1:0] ARSIZE,
	output  logic [1:0] ARBURST,
	output  logic ARVALID,
	input   ARREADY,

    // Read Data Signals
	input   [`AXI_ID_BITS-1:0] RID,
	input   [`AXI_DATA_BITS-1:0] RDATA,
	input   [1:0] RRESP,
	input   RLAST,
	input   RVALID,
	output  logic RREADY,

    // Write Address Signals
	output  logic [`AXI_ID_BITS-1:0] AWID,
	output  logic [`AXI_ADDR_BITS-1:0] AWADDR,
	output  logic [`AXI_LEN_BITS-1:0] AWLEN,
	output  logic [`AXI_SIZE_BITS-1:0] AWSIZE,
	output  logic [1:0] AWBURST,
	output  logic AWVALID,
	input   AWREADY,

    // Write Data Signals
	output  logic [`AXI_DATA_BITS-1:0] WDATA,
	output  logic [`AXI_STRB_BITS-1:0] WSTRB,
	output  logic WLAST,
	output  logic WVALID,
	input   WREADY,

    // Write Response Signals
	input   [`AXI_ID_BITS-1:0] BID,
	input   [1:0] BRESP,
	input   BVALID,
	output  logic BREADY,

    // CPU
	input	MEM_access,
	input   WEB,
	input   [`AXI_STRB_BITS-1:0] BWEB, // 4 bits
	input   [`AXI_ADDR_BITS-1:0] addr,
	// input   [13:0] addr,
	input   [`AXI_DATA_BITS-1:0] data_in,
	input cacheEn,
	output  logic [`AXI_DATA_BITS-1:0] data_out,
	output  logic stall,
	output logic I_stall
);

logic rst_flag;

// FSM
logic [1:0] cur_state;
logic [1:0] nxt_state;
parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter WRITE = 2'b10;
parameter WRITE_RESP = 2'b11;

// memory data out reg
logic [31:0] data_reg;
logic [31:0] data_comb;

always_ff @( posedge clk or negedge rst ) begin : rst_detector
	if (~rst) begin
		rst_flag <= 1'b0;
	end
	else begin
		rst_flag <= 1'b1;
	end
end

always_ff @( posedge clk or negedge rst ) begin : FSM_cur
	if (~rst) begin
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
			if (MEM_access) begin
				if (WEB) begin // 0: write, 1: read
					if (ARVALID & ARREADY & rst_flag) begin
						nxt_state = READ;
					end
				end
				else begin
					if (AWVALID & AWREADY & rst_flag) begin
						nxt_state = WRITE;
					end		
				end
			end
		end 
		READ: begin
			if (RLAST & RREADY & RVALID) begin
				nxt_state = IDLE;
			end
		end
		WRITE: begin
			if (WVALID & WLAST & WREADY) begin
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

always_comb begin : output_signals
	// read
	ARID = `AXI_ID_BITS'b0;
	ARADDR = addr;
	ARLEN = (cacheEn)?`AXI_LEN_BITS'h3:`AXI_LEN_BITS'h0;
	ARSIZE = `AXI_SIZE_BITS'b10; // 4 bytes = 32 bits
	ARBURST = `AXI_BURST_INC;
	ARVALID = 1'b0;
	RREADY = 1'b0;
	// write
	AWID = `AXI_ID_BITS'b0;
	AWADDR = addr;
	AWLEN = `AXI_LEN_BITS'b0;
	AWSIZE = `AXI_SIZE_BITS'b10; // 4 bytes = 32 bits
	AWBURST = `AXI_BURST_INC;
	AWVALID = 1'b0;
	WDATA = data_in;
	WSTRB = BWEB;
	WLAST = 1'b0;
	WVALID = 1'b0;
	BREADY = 1'b0;
	case (cur_state)
		IDLE: begin
			if (MEM_access) begin
				if (WEB & rst_flag) begin // read
					ARVALID = 1'b1;
				end
				else if (~WEB & rst_flag) begin
					AWVALID = 1'b1;
				end
			end
		end 
		READ: begin
			RREADY = 1'b1;
		end
		WRITE: begin
			WVALID = 1'b1;
			WLAST = 1'b1; // for only 1 transfer
		end
		WRITE_RESP: begin
			BREADY = 1'b1;
		end
	endcase
end

always_ff @( posedge clk or negedge rst ) begin : data_register
	if (~rst) begin
		data_reg <= 32'b0;
	end
	else begin
		data_reg <= data_comb;
	end
end

always_comb begin : data_reg_comb
	data_comb = data_reg;
	if (RVALID & RREADY) begin
		data_comb = RDATA;
	end
end

always_comb begin : CPU_output
	// data_out = RDATA;
	data_out = data_comb;
	stall = 1'b0;
	case (cur_state)
		IDLE: begin
			if (MEM_access) begin // read
				stall = 1'b1;
			end
		end 
		READ: begin
			stall = 1'b1;
			if (RREADY & RVALID) begin
				stall = 1'b0;
			end
		end
		WRITE: begin
			stall = 1'b1;
			// if (WREADY & WVALID) begin
			// 	stall = 1'b0;
			// end
		end
		WRITE_RESP: begin
			stall = 1'b1;
			if (BREADY & BVALID) begin
				stall = 1'b0;
			end
		end
	endcase
end
    
endmodule