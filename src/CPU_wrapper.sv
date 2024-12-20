//`include "../include/AXI_define.svh"
//`include "CPU.sv"
//`include "Master.sv"
//`include "def.svh"
//`include "L1C_inst.sv"
module CPU_wrapper (
	input ACLK,
	input ARESETn,
    input rst,

    // interrupt signal
    input external_interrupt_flag,
    input timer_interrupt_flag,

	// Read Address Signals master 0
    output logic [`AXI_ID_BITS-1:0] ARID_M0,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    output logic [1:0] ARBURST_M0,
    output logic ARVALID_M0,
    input ARREADY_M0,

    // Read Data Signals master 0
    input [`AXI_ID_BITS-1:0] RID_M0,
    input [`AXI_DATA_BITS-1:0] RDATA_M0,
    input [1:0] RRESP_M0,
    input RLAST_M0,
    input RVALID_M0,
    output logic RREADY_M0,

    // Write Address Signals master 0
    // output logic [`AXI_ID_BITS-1:0] AWID_M0,
    // output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
    // output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
    // output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
    // output logic [1:0] AWBURST_M0,
    // output logic AWVALID_M0,
    // input AWREADY_M0,

    // Write Data Signals master 0
    // output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
    // output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
    // output logic WLAST_M0,
    // output logic WVALID_M0,
    // input WREADY_M0,

    // Write Response Signals master 0
    // input [`AXI_ID_BITS-1:0] BID_M0,
    // input [1:0] BRESP_M0,
    // input BVALID_M0,
    // output logic BREADY_M0,
    
    // Read Address Signals master 1
    output logic [`AXI_ID_BITS-1:0] ARID_M1,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    output logic [1:0] ARBURST_M1,
    output logic ARVALID_M1,
    input ARREADY_M1,

    // READ DATA1
    input [`AXI_ID_BITS-1:0] RID_M1,
    input [`AXI_DATA_BITS-1:0] RDATA_M1,
    input [1:0] RRESP_M1,
    input RLAST_M1,
    input RVALID_M1,
    output logic RREADY_M1,

    // Write Address Signals master 1
    output logic [`AXI_ID_BITS-1:0] AWID_M1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    output logic [1:0] AWBURST_M1,
    output logic AWVALID_M1,
    input AWREADY_M1,

    // Read Data Signals master 1
    output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
    output logic WLAST_M1,
    output logic WVALID_M1,
    input WREADY_M1,

    // Write Response Signals master 1
    input [`AXI_ID_BITS-1:0] BID_M1,
    input [1:0] BRESP_M1,
    input BVALID_M1,
    output logic BREADY_M1
);

// wire for unuse ports in M0
// Write Address Signals master 0
logic [`AXI_ID_BITS-1:0] AWID_M0;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M0;
logic [`AXI_LEN_BITS-1:0] AWLEN_M0;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0;
logic [1:0] AWBURST_M0;
logic AWVALID_M0;
logic AWREADY_M0;
// Write Data Signals master 0
logic [`AXI_DATA_BITS-1:0] WDATA_M0;
logic [`AXI_STRB_BITS-1:0] WSTRB_M0;
logic WLAST_M0;
logic WVALID_M0;
logic WREADY_M0;
// Write Response Signals master 0
logic [`AXI_ID_BITS-1:0] BID_M0;
logic [1:0] BRESP_M0;
logic BVALID_M0;
logic BREADY_M0;

// wire to CPU
// IM
logic IM_MEM_access;
logic [31:0] inst_IM;
logic [31:0] pc_2_IM;
logic IM_stall;
// DM
logic DM_MEM_access;
logic [31:0] DM_out;
logic [31:0] DM_addr;
logic DM_WEB;
logic [3:0] DM_write;
logic DM_stall;
logic [31:0] DM_data_in;
//cache
logic [`DATA_BITS-1:0] core_addr_m0;
logic core_req_m0;
logic [`DATA_BITS-1:0] I_out_m0;
logic I_wait_m0;
logic [`DATA_BITS-1:0] core_out_m0;
logic core_wait_m0;
logic I_req_m0;
logic [`DATA_BITS-1:0] I_addr_m0;

Master IF_stage(
    .clk(ACLK),
	.rst(ARESETn),
    
    // Read Address Signals
	.ARID(ARID_M0),
	.ARADDR(ARADDR_M0),
	.ARLEN(ARLEN_M0),
	.ARSIZE(ARSIZE_M0),
	.ARBURST(ARBURST_M0),
	.ARVALID(ARVALID_M0),
	.ARREADY(ARREADY_M0),

    // Read Data Signals
	.RID(RID_M0),
	.RDATA(RDATA_M0),
	.RRESP(RRESP_M0),
	.RLAST(RLAST_M0),
	.RVALID(RVALID_M0),
	.RREADY(RREADY_M0),

    // Write Address Signals
	.AWID(AWID_M0),
	.AWADDR(AWADDR_M0),
	.AWLEN(AWLEN_M0),
	.AWSIZE(AWSIZE_M0),
	.AWBURST(AWBURST_M0),
	.AWVALID(AWVALID_M0),
	.AWREADY(AWREADY_M0),

    // Write Data Signals
	.WDATA(WDATA_M0),
	.WSTRB(WSTRB_M0),
	.WLAST(WLAST_M0),
	.WVALID(WVALID_M0),
	.WREADY(WREADY_M0),

    // Write Response Signals
	.BID(BID_M0),
	.BRESP(BRESP_M0),
	.BVALID(BVALID_M0),
	.BREADY(BREADY_M0),

    // CPU
	//.MEM_access(IM_MEM_access),
	//.WEB(1'b1), // read only
	//.BWEB(4'b1111), // 4 bits
	//.addr(pc_2_IM),
	//.data_in(32'b0),
	//.data_out(inst_IM),
	//.stall(IM_stall)

    .MEM_access(I_req_m0),
	.WEB(1'b1), // read only
	.BWEB(4'b1111), // 4 bits
	.addr(I_addr_m0),
	.data_in(32'b0),
	.data_out(I_out_m0),
	.stall(I_wait_m0),
    //.I_stall(I_wait_m0)

    .cacheEn(1'b1)
);

Master MEM_stage(
    .clk(ACLK),
	.rst(ARESETn),
    
    // Read Address Signals
	.ARID(ARID_M1),
	.ARADDR(ARADDR_M1),
	.ARLEN(ARLEN_M1),
	.ARSIZE(ARSIZE_M1),
	.ARBURST(ARBURST_M1),
	.ARVALID(ARVALID_M1),
	.ARREADY(ARREADY_M1),

    // Read Data Signals
	.RID(RID_M1),
	.RDATA(RDATA_M1),
	.RRESP(RRESP_M1),
	.RLAST(RLAST_M1),
	.RVALID(RVALID_M1),
	.RREADY(RREADY_M1),

    // Write Address Signals
	.AWID(AWID_M1),
	.AWADDR(AWADDR_M1),
	.AWLEN(AWLEN_M1),
	.AWSIZE(AWSIZE_M1),
	.AWBURST(AWBURST_M1),
	.AWVALID(AWVALID_M1),
	.AWREADY(AWREADY_M1),

    // Write Data Signals
	.WDATA(WDATA_M1),
	.WSTRB(WSTRB_M1),
	.WLAST(WLAST_M1),
	.WVALID(WVALID_M1),
	.WREADY(WREADY_M1),

    // Write Response Signals
	.BID(BID_M1),
	.BRESP(BRESP_M1),
	.BVALID(BVALID_M1),
	.BREADY(BREADY_M1),

    // CPU
    
	.MEM_access(DM_MEM_access),
	.WEB(DM_WEB),
	.BWEB(DM_write), // 4 bits
	// .addr({16'h0001 ,DM_addr[15:0]}),
	.addr(DM_addr),
	.data_in(DM_data_in),
	.data_out(DM_out),
	.stall(DM_stall),


    .cacheEn(1'b0)
);



L1C_inst L1CI(
    .clk(ACLK),
    .rst(~ARESETn),
    
    //.core_addr(pc_2_IM),
    //.core_req(IM_MEM_access),
    //.core_write(1'b0),
    //.core_in(`DATA_BITS'b0),
    //.core_type(`CACHE_WORD),
    //
    //.I_out(inst_IM),
    //.I_wait(IM_stall)
    
    //cpu
    .core_addr(core_addr_m0),
    //.core_req(1'b1),
    .core_req(core_req_m0),
    
    .core_write(1'b0),
    .core_in(`DATA_BITS'b0),
    .core_type(`CACHE_WORD),
    ////
    .I_out(I_out_m0),
    .I_wait(I_wait_m0),
    //
    .core_out(core_out_m0),
    .core_wait(core_wait_m0),
    .I_req(I_req_m0),
    .I_addr(I_addr_m0)
    

);



CPU CPU1(
	.clk(ACLK),
	.rst(rst),

    // interrupt signal
    .external_interrupt_flag(external_interrupt_flag),
    .timer_interrupt_flag(timer_interrupt_flag),


	//.inst_IM(inst_IM),
    //.pc_2_IM(pc_2_IM), // to IM
    //.IM_MEM_access(IM_MEM_access),
    //.IM_stall(IM_stall),
    .inst_IM(core_out_m0),
    .pc_2_IM(core_addr_m0), // to IM
    .IM_MEM_access(core_req_m0),
    .IM_stall(core_wait_m0),
    //L1IC
    //.L1IC_wait(cache_wait_m0),
	.DM_out(DM_out), // from DM
    // to DM
    .DM_addr(DM_addr),
    .DM_WEB(DM_WEB),
    // .DM_read(DM_read),
    .DM_write(DM_write),
    .DM_MEM_access(DM_MEM_access),
    .DM_stall(DM_stall),
    .DM_data_in(DM_data_in)
);

endmodule