//`include "sync_pulse.sv"
//`include "WDT.sv"
module WDT_wrapper (
    input ACLK,
	input ARESETn,
	input rst,
    input clk2,
    input rst2,

	// interrupt signal to CPU
	output logic timer_interrupt,

    // to AXI 
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

// WDT synchronizer
logic WDEN_in_comb;
logic WDEN_in;
logic WDEN_clk2_reg1;
logic WDEN_clk2_comb1;
logic WDEN_clk2_reg2;
logic WDEN_clk2_comb2;
logic WDEN_clk2_reg3;
logic WDLIVE_in_comb;
logic WDLIVE_in;
logic [31:0] WTOCNT_in_comb;
logic [31:0] WTOCNT_in;

logic WTOCNT_transfer_flag;
logic WTOCNT_transfer_flag_reg;
logic WTOCNT_transfer_EN;
// logic WTOCNT_transfer_finished_flag;

// clk2 sync success flag
logic NONE_flag;
logic WDEN_clk2_flag;
logic WDLIVE_clk2_flag;
logic WTO_en_clk2_flag;
logic transfer_EN_comb;
logic transfer_EN;

// WDT wires
// logic WDEN;
logic WDLIVE;
logic [31:0] WTOCNT;
logic [31:0] WTOCNT_comb;
logic WTO;

logic WDEN_reg;
logic WDLIVE_reg;
logic [31:0] WTOCNT_reg;

always_ff @( posedge clk2 or posedge rst2 ) begin : WDT_registers_in
	if (rst2) begin
		WDEN_reg <= 1'b0;
		WDLIVE_reg <= 1'b0;
		WTOCNT_reg <= 32'b0;
	end
	else begin
		WDEN_reg <= WDEN_clk2_reg3;
		WDLIVE_reg <= WDLIVE;
		WTOCNT_reg <= WTOCNT;
	end
end

// WDT WDT1(
//     .clk(ACLK),
//     .rst(rst),
//     .clk2(clk2),
//     .rst2(rst2),
//     // .WDEN(WDEN),
//     .WDEN(WDEN_clk2_reg2),
//     .WDLIVE(WDLIVE),
//     .WTOCNT(WTOCNT),
//     // .WTO(timer_interrupt)
//     .WTO(WTO)
// );

WDT WDT1(
    .clk(ACLK),
    .rst(rst),
    .clk2(clk2),
    .rst2(rst2),
    // .WDEN(WDEN),
    .WDEN(WDEN_reg),
    .WDLIVE(WDLIVE_reg),
    .WTOCNT(WTOCNT_reg),
    // .WTO(timer_interrupt)
    .WTO(WTO)
);

// AXI connection
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
	// RDATA_S = DO_comb;
	RDATA_S = 32'b0;
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
			AWREADY_S = 1'b0;
			if ((WDLIVE_clk2_flag & WTO_en_clk2_flag)) begin
				AWREADY_S = 1'b1;	
			end
		end 
		READ: begin
			RVALID_S = 1'b1;
			if (ARLEN_reg == lens_counter) begin
				RLAST_S = 1'b1;
			end
		end
		WRITE: begin
			WREADY_S = 1'b1;
			// WREADY_S = 1'b0;
			// if (~(WDLIVE_in_comb | WDLIVE_in | WTOCNT_transfer_flag_reg | WTOCNT_transfer_flag)) begin
			// 	if (NONE_flag | WDEN_clk2_flag | (WDLIVE_clk2_flag & WTO_en_clk2_flag)) begin
			// 		WREADY_S = 1'b1;
			// 	end
			// end
		end
		WRITE_RESP: begin
			BVALID_S = 1'b1;
			// BVALID_S = 1'b0;
			// if (WDLIVE_in) begin
			// 	if (NONE_flag | WDEN_clk2_flag | (WDLIVE_clk2_flag & WTO_en_clk2_flag)) begin
			// 		BVALID_S = 1'b1;
			// 	end
			// end
		end
	endcase
end

// WDT CDC logic
always_ff @( posedge ACLK or posedge rst ) begin : WDT_input_reg
    if (rst) begin
        WDEN_in <= 1'b0;
        WDLIVE_in <= 1'b0;
        WTOCNT_in <= 32'b0;
		WTOCNT_transfer_flag_reg <= 1'b0;
		transfer_EN <= 1'b0;
    end
    else begin
        WDEN_in <= WDEN_in_comb;
        WDLIVE_in <= WDLIVE_in_comb;
        WTOCNT_in <= WTOCNT_in_comb;
		WTOCNT_transfer_flag_reg <= WTOCNT_transfer_flag;
		transfer_EN <= transfer_EN_comb;
    end
end

always_comb begin : WDT_input_comb
    WDEN_in_comb = WDEN_in;
    // WDLIVE_in_comb = WDLIVE_in;
    WDLIVE_in_comb = 1'b0;
    WTOCNT_in_comb = WTOCNT_in;
	WTOCNT_transfer_flag = 1'b0;
	WDEN_clk2_flag = 1'b0;
	NONE_flag = 1'b0;
	transfer_EN_comb = 1'b0;
    case (cur_state)
		// IDLE: begin
			
		// end 
		// READ: begin
			
		// end
		WRITE: begin
			// WTOCNT_transfer_flag = 1'b1;
			NONE_flag = 1'b1;
			transfer_EN_comb = transfer_EN;
			case (ADDR_comb[15:0])
                16'h0100: begin // WDEN
					WDEN_clk2_flag = 1'b1;
					NONE_flag = 1'b0;
                    if (WDATA_S != 32'b0) begin
                        WDEN_in_comb = 1'b1;
                    end
                end
                16'h0200: begin // WDLIVE
					NONE_flag = 1'b0;
                    if (WDATA_S != 32'b0 & WDLIVE_in == 1'b0 & transfer_EN == 1'b0) begin
                        WDLIVE_in_comb = 1'b1;
						transfer_EN_comb = 1'b1;
                    end
                end
                16'h0300: begin // WTOCNT
					NONE_flag = 1'b0;
                    WTOCNT_in_comb = WDATA_S;
					if (WTOCNT_transfer_flag_reg == 1'b0 & transfer_EN == 1'b0) begin
						WTOCNT_transfer_flag = 1'b1;
						transfer_EN_comb = 1'b1;
					end
                end
            endcase
		end
		WRITE_RESP: begin
			NONE_flag = 1'b1;
			case (ADDR_comb[15:0])
                16'h0100: begin // WDEN
					WDEN_clk2_flag = 1'b1;
					NONE_flag = 1'b0;
                end
                16'h0200: begin // WDLIVE
					NONE_flag = 1'b0;
                end
                16'h0300: begin // WTOCNT
                    NONE_flag = 1'b0;
                end
            endcase
		end
	endcase
end

// sync_pulse sync_pulse_WDEN(
// 	.clk_a(ACLK), // posedge
// 	.rst_a(~ARESETn), // posedge
// 	.clk_b(clk2), // posedge
// 	.rst_b(rst2), // posedge

// 	.signal_a(WDEN_in),
// 	.signal_b(WDEN)
// );

always_ff @( posedge clk2 or posedge rst2 ) begin : WDEN_clk2_register1
	if (rst2) begin
		WDEN_clk2_reg1 <= 1'b0;
	end
	else begin
		WDEN_clk2_reg1 <= WDEN_clk2_comb1;
	end
end

always_comb begin : WDEN_clk2_comb_control1
	WDEN_clk2_comb1 = WDEN_in;
end

always_ff @( posedge clk2 or posedge rst2 ) begin : WDEN_clk2_register
	if (rst2) begin
		WDEN_clk2_reg2 <= 1'b0;
		WDEN_clk2_reg3 <= 1'b0;
	end
	else begin
		WDEN_clk2_reg2 <= WDEN_clk2_comb2;
		WDEN_clk2_reg3 <= WDEN_clk2_reg2;
	end
end

always_comb begin : WDEN_clk2_comb_control2
	WDEN_clk2_comb2 = WDEN_clk2_reg1;
end

sync_pulse sync_pulse_WDLIVE(
	.clk_a(ACLK), // posedge
	.rst_a(rst), // posedge
	.clk_b(clk2), // posedge
	.rst_b(rst2), // posedge

	.signal_a(WDLIVE_in),
	.ready(WDLIVE_clk2_flag),
	.signal_b(WDLIVE)
);

sync_pulse sync_pulse_WTO_en(
	.clk_a(ACLK), // posedge
	.rst_a(rst), // posedge
	.clk_b(clk2), // posedge
	.rst_b(rst2), // posedge

	.signal_a(WTOCNT_transfer_flag_reg),
	.ready(WTO_en_clk2_flag),
	.signal_b(WTOCNT_transfer_EN)
);

always_ff @( posedge clk2 or posedge rst2 ) begin : WTOCNT_control
	if (rst2) begin
		WTOCNT <= 32'b0;
	end
	else begin
		WTOCNT <= WTOCNT_comb;
	end
end

always_comb begin : WTOCNT_comb_control
	WTOCNT_comb = WTOCNT;
	if (WTOCNT_transfer_EN) begin
		WTOCNT_comb = WTOCNT_in;
	end
end

// sync_pulse sync_pulse_WTO(
// 	.clk_a(clk2), // posedge
// 	.rst_a(rst2), // posedge
// 	.clk_b(ACLK), // posedge
// 	.rst_b(rst), // posedge

// 	.signal_a(WTO),
// 	.signal_b(timer_interrupt)
// );

logic WTO_clk2_reg1;
logic WTO_clk1_reg1;
logic WTO_clk1_reg2;

logic WDLIVE_clk2_flag_clk2_reg1;
logic WDLIVE_clk2_flag_clk2_reg2;
logic WDLIVE_clk2_flag_clk1_reg1;
logic WDLIVE_clk2_flag_clk1_reg2;

logic WTO_en_clk2_flag_clk2_reg1;
logic WTO_en_clk2_flag_clk2_reg2;
logic WTO_en_clk2_flag_clk1_reg1;
logic WTO_en_clk2_flag_clk1_reg2;

assign timer_interrupt = WTO_clk1_reg2;
// assign WDLIVE_clk2_flag = WDLIVE_clk2_flag_clk1_reg2;
// assign WTO_en_clk2_flag = WTO_en_clk2_flag_clk1_reg2;

// CDC clk2 to clk1 2-FF
always_ff @( posedge clk2 ) begin : WTO_clk2_register
	WTO_clk2_reg1 <= WTO;
	// WDLIVE_clk2_flag_clk2_reg1 <= WDLIVE;
	// WDLIVE_clk2_flag_clk2_reg2 <= WDLIVE_clk2_flag_clk2_reg1;
	// WTO_en_clk2_flag_clk2_reg1 <= WTOCNT_transfer_EN;
	// WTO_en_clk2_flag_clk2_reg2 <= WTO_en_clk2_flag_clk2_reg1;
end

always_ff @( posedge ACLK ) begin : WTO_clk1_register
	WTO_clk1_reg1 <= WTO_clk2_reg1;
	WTO_clk1_reg2 <= WTO_clk1_reg1;
	// WDLIVE_clk2_flag_clk1_reg1 <= WDLIVE_clk2_flag_clk2_reg2;
	// WDLIVE_clk2_flag_clk1_reg2 <= WDLIVE_clk2_flag_clk1_reg1;
	// WTO_en_clk2_flag_clk1_reg1 <= WTO_en_clk2_flag_clk2_reg2;
	// WTO_en_clk2_flag_clk1_reg2 <= WTO_en_clk2_flag_clk1_reg1;
end

// sync_pulse sync_pulse_WDLIVE_flag(
// 	.clk_b(ACLK), // posedge
// 	.rst_b(rst), // posedge
// 	.clk_a(clk2), // posedge
// 	.rst_a(rst2), // posedge

// 	.signal_a(WDLIVE),
// 	.signal_b(WDLIVE_clk2_flag)
// );

// sync_pulse sync_pulse_WTO_en_flag(
// 	.clk_b(ACLK), // posedge
// 	.rst_b(rst), // posedge
// 	.clk_a(clk2), // posedge
// 	.rst_a(rst2), // posedge

// 	.signal_a(WTOCNT_transfer_EN),
// 	.signal_b(WTO_en_clk2_flag)
// );

endmodule