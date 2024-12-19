//`include "../include/AXI_define.svh"
//`include "DMA_master.sv"
//`include "DMA_slave.sv"
module DMA_wrapper (
	input clk,
    	input rst,

	//master to  AXI
	//Address write
	output logic [`AXI_ID_BITS-1:0] AWID_M,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
	output logic [1:0] AWBURST_M,
	output logic AWVALID_M,
	input AWREADY_M,
	
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
	output logic WLAST_M,
	output logic WVALID_M,
	input WREADY_M,
     //WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M,
	input [1:0] BRESP_M,
	input BVALID_M,
	output logic BREADY_M,

     output logic [`AXI_ID_BITS-1:0] ARID_M,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
	output logic [1:0] ARBURST_M,
	output logic ARVALID_M,
	input ARREADY_M,
	
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID_M,
	input [`AXI_DATA_BITS-1:0] RDATA_M,
	input [1:0] RRESP_M,
	input RLAST_M,
	input RVALID_M,
	output logic RREADY_M,

      //AXI
     //WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID_S,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input [`AXI_LEN_BITS-1:0] AWLEN_S,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input [1:0] AWBURST_S,
	input AWVALID_S,
	output logic AWREADY_S,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_S,
	input [`AXI_STRB_BITS-1:0] WSTRB_S,
	input WLAST_S,
	input WVALID_S,
	output logic WREADY_S,
	
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID_S,
	output logic [1:0] BRESP_S,
	output logic BVALID_S,
	input BREADY_S,

	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID_S,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input [`AXI_LEN_BITS-1:0] ARLEN_S,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input [1:0] ARBURST_S,
	input ARVALID_S,
	output logic ARREADY_S,
	
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input RREADY_S,

     output logic interrupt

);
	logic [31:0] DMASRC, DMADST;
	logic [31:0] DMALEN;  //Total length of the data
	logic DMAEN;  // Enable the DMA

	DMA_master DMA_master(
	.clk(clk),
	.rst(rst),
	.AWID(AWID_M),
	.AWADDR(AWADDR_M),
	.AWLEN(AWLEN_M),
	.AWSIZE(AWSIZE_M),
	.AWBURST(AWBURST_M),
	.AWVALID(AWVALID_M),
	.AWREADY(AWREADY_M),
	//WRITE DATA
	.WDATA(WDATA_M),
	.WSTRB(WSTRB_M),
	.WLAST(WLAST_M),
	.WVALID(WVALID_M),
	.WREADY(WREADY_M),

	//WRITE RESPONSE
	.BID(BID_M),
	.BRESP(BRESP_M),
	.BVALID(BVALID_M),
	.BREADY(BREADY_M),
		
	//READ ADDRESS0
	.ARID(ARID_M),
	.ARADDR(ARADDR_M),
	.ARLEN(ARLEN_M),
	.ARSIZE(ARSIZE_M),
	.ARBURST(ARBURST_M),
	.ARVALID(ARVALID_M),
	.ARREADY(ARREADY_M),

	//READ DATA0
	.RID(RID_M),
	.RDATA(RDATA_M),
	.RRESP(RRESP_M),
	.RLAST(RLAST_M),
	.RVALID(RVALID_M),
	.RREADY(RREADY_M),

	.DMASRC(DMASRC),   
	.DMADST(DMADST),
	.DMALEN(DMALEN),
	.DMAEN(DMAEN),

	.interrupt(interrupt)

		
	); 
	DMA_slave DMA_slave(
	.clk(clk),
	.rst(rst),
	.AWID_S(AWID_S),
	.AWADDR_S(AWADDR_S),
	.AWLEN_S(AWLEN_S),
	.AWSIZE_S(AWSIZE_S),
	.AWBURST_S(AWBURST_S),
	.AWVALID_S(AWVALID_S),
	.AWREADY_S(AWREADY_S),
	.WDATA_S(WDATA_S),
	.WSTRB_S(WSTRB_S),
	.WLAST_S(WLAST_S),
	.WVALID_S(WVALID_S),
	.WREADY_S(WREADY_S),
	.BID_S(BID_S),
	.BRESP_S(BRESP_S),
	.BVALID_S(BVALID_S),
	.BREADY_S(BREADY_S),
	.ARID_S(ARID_S),
	.ARADDR_S(ARADDR_S),
	.ARLEN_S(ARLEN_S),
	.ARSIZE_S(ARSIZE_S),
	.ARBURST_S(ARBURST_S),
	.ARVALID_S(ARVALID_S),
	.ARREADY_S(ARREADY_S),
	.RID_S(RID_S),
	.RDATA_S(RDATA_S),
	.RRESP_S(RRESP_S),
	.RLAST_S(RLAST_S),
	.RVALID_S(RVALID_S),
	.RREADY_S(RREADY_S),

	.DMASRC(DMASRC),   
	.DMADST(DMADST),
	.DMALEN(DMALEN),
	.tmp_DMAEN(DMAEN)

);


endmodule
