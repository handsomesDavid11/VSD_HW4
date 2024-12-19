
//////////////////////////////////////////////////////////////////////
//`include "../../include/AXI_define.svh"
//`include "../../include/AXI_include_files.svh"
// for synthesize
// `include "AXI/default_slave.sv"
// `include "AXI/AR_channel.sv"
// `include "AXI/R_channel.sv"
// `include "AXI/AW_channel.sv"
// `include "AXI/W_channel.sv"
// `include "AXI/B_channel.sv"
// `include "AXI/arbiter.sv"
// `include "AXI/decoder.sv"
// `include "AXI/arbiter_R.sv"
// `include "AXI/decoder_S.sv"

// for rtl & vip
// `include "default_slave.sv"
// `include "AR_channel.sv"
// `include "R_channel.sv"
// `include "AW_channel.sv"
// `include "W_channel.sv"
// `include "B_channel.sv"
// `include "arbiter.sv"
// `include "decoder.sv"
// `include "arbiter_R.sv"
// `include "decoder_S.sv"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	
	//WRITE ADDRESS1
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA1
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE1
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	//WRITE ADDRESS2
	input [`AXI_ID_BITS-1:0] AWID_M2,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M2,
	input [`AXI_LEN_BITS-1:0] AWLEN_M2,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M2,
	input [1:0] AWBURST_M2,
	input AWVALID_M2,
	output logic AWREADY_M2,
	
	//WRITE DATA2
	input [`AXI_DATA_BITS-1:0] WDATA_M2,
	input [`AXI_STRB_BITS-1:0] WSTRB_M2,
	input WLAST_M2,
	input WVALID_M2,
	output logic WREADY_M2,
	
	//WRITE RESPONSE2
	output logic [`AXI_ID_BITS-1:0] BID_M2,
	output logic [1:0] BRESP_M2,
	output logic BVALID_M2,
	input BREADY_M2,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	//READ ADDRESS2
	input [`AXI_ID_BITS-1:0] ARID_M2,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M2,
	input [`AXI_LEN_BITS-1:0] ARLEN_M2,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M2,
	input [1:0] ARBURST_M2,
	input ARVALID_M2,
	output logic ARREADY_M2,
	
	//READ DATA2
	output logic [`AXI_ID_BITS-1:0] RID_M2,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M2,
	output logic [1:0] RRESP_M2,
	output logic RLAST_M2,
	output logic RVALID_M2,
	input RREADY_M2,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,

	//WRITE ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
	input AWREADY_S2,
	
	//WRITE DATA2
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,
	
	//WRITE RESPONSE2
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,

	//WRITE ADDRESS3
	output logic [`AXI_IDS_BITS-1:0] AWID_S3,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output logic [1:0] AWBURST_S3,
	output logic AWVALID_S3,
	input AWREADY_S3,
	
	//WRITE DATA3
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic WLAST_S3,
	output logic WVALID_S3,
	input WREADY_S3,
	
	//WRITE RESPONSE3
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic BREADY_S3,

	//WRITE ADDRESS4
	output logic [`AXI_IDS_BITS-1:0] AWID_S4,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output logic [1:0] AWBURST_S4,
	output logic AWVALID_S4,
	input AWREADY_S4,
	
	//WRITE DATA4
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic WLAST_S4,
	output logic WVALID_S4,
	input WREADY_S4,
	
	//WRITE RESPONSE4
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4,

	//WRITE ADDRESS5
	output logic [`AXI_IDS_BITS-1:0] AWID_S5,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output logic [1:0] AWBURST_S5,
	output logic AWVALID_S5,
	input AWREADY_S5,
	
	//WRITE DATA5
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic WLAST_S5,
	output logic WVALID_S5,
	input WREADY_S5,
	
	//WRITE RESPONSE5
	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output logic BREADY_S5,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
	
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,

	//READ ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
	input ARREADY_S2,
	
	//READ DATA2
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2,

	//READ ADDRESS3
	output logic [`AXI_IDS_BITS-1:0] ARID_S3,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	output logic [1:0] ARBURST_S3,
	output logic ARVALID_S3,
	input ARREADY_S3,
	
	//READ DATA3
	input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output logic RREADY_S3,

	//READ ADDRESS4
	output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output logic [1:0] ARBURST_S4,
	output logic ARVALID_S4,
	input ARREADY_S4,
	
	//READ DATA4
	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output logic RREADY_S4,

	//READ ADDRESS5
	output logic [`AXI_IDS_BITS-1:0] ARID_S5,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output logic [1:0] ARBURST_S5,
	output logic ARVALID_S5,
	input ARREADY_S5,
	
	//READ DATA5
	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output logic RREADY_S5
	
);
    //---------- you should put your design here ----------//
// wires
// default slave
logic [`AXI_IDS_BITS-1:0] ARID_SD;
logic [`AXI_ADDR_BITS-1:0] ARADDR_SD;
logic [`AXI_LEN_BITS-1:0] ARLEN_SD;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_SD;
logic [1:0] ARBURST_SD;
logic ARVALID_SD;
logic ARREADY_SD;

logic [`AXI_IDS_BITS-1:0] RID_SD;
logic [`AXI_DATA_BITS-1:0] RDATA_SD;
logic [1:0] RRESP_SD;
logic RLAST_SD;
logic RVALID_SD;
logic RREADY_SD;

logic [`AXI_IDS_BITS-1:0] AWID_SD;
logic [`AXI_ADDR_BITS-1:0] AWADDR_SD;
logic [`AXI_LEN_BITS-1:0] AWLEN_SD;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_SD;
logic [1:0] AWBURST_SD;
logic AWVALID_SD;
logic AWREADY_SD;

logic [`AXI_DATA_BITS-1:0] WDATA_SD;
logic [`AXI_STRB_BITS-1:0] WSTRB_SD;
logic WLAST_SD;
logic WVALID_SD;
logic WREADY_SD;

logic [`AXI_IDS_BITS-1:0] BID_SD;
logic [1:0] BRESP_SD;
logic BVALID_SD;
logic BREAD_SD;

// AW_channel
// logic [1:0] M0_connect_info;
// logic [1:0] M0_connect_info_comb;
// logic [1:0] M0_connect_info_reg;
// logic [1:0] M1_connect_info;
// logic [1:0] M1_connect_info_comb;
// logic [1:0] M1_connect_info_reg;
// logic [1:0] M1_connect_info_W_reg; // for B channel
logic [1:0] occupied_SD_comb;
logic [1:0] occupied_S0_comb;
logic [1:0] occupied_S1_comb;
logic [1:0] occupied_S2_comb;
logic [1:0] occupied_S3_comb;
logic [1:0] occupied_S4_comb;
logic [1:0] occupied_S5_comb;

// submodule
// AR_channel
AR_channel AR_channel1(
    .clk(ACLK),
    .rst(ARESETn),

    // SLAVE INTERFACE FOR MASTERS
    // READ ADDRESS0
	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	.ARREADY_M0(ARREADY_M0),

    // READ ADDRESS1
	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1),
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1),
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1),
	.ARREADY_M1(ARREADY_M1),

	// READ ADDRESS2
	.ARID_M2(ARID_M2),
	.ARADDR_M2(ARADDR_M2),
	.ARLEN_M2(ARLEN_M2),
	.ARSIZE_M2(ARSIZE_M2),
	.ARBURST_M2(ARBURST_M2),
	.ARVALID_M2(ARVALID_M2),
	.ARREADY_M2(ARREADY_M2),

    // MASTER INTERFACE FOR SLAVES
    // default slave
    .ARID_SD(ARID_SD),
	.ARADDR_SD(ARADDR_SD),
	.ARLEN_SD(ARLEN_SD),
	.ARSIZE_SD(ARSIZE_SD),
	.ARBURST_SD(ARBURST_SD),
	.ARVALID_SD(ARVALID_SD),
	.ARREADY_SD(ARREADY_SD),

    // READ ADDRESS0
	.ARID_S0(ARID_S0),
	.ARADDR_S0(ARADDR_S0),
	.ARLEN_S0(ARLEN_S0),
	.ARSIZE_S0(ARSIZE_S0),
	.ARBURST_S0(ARBURST_S0),
	.ARVALID_S0(ARVALID_S0),
	.ARREADY_S0(ARREADY_S0),

    // READ ADDRESS1
	.ARID_S1(ARID_S1),
	.ARADDR_S1(ARADDR_S1),
	.ARLEN_S1(ARLEN_S1),
	.ARSIZE_S1(ARSIZE_S1),
	.ARBURST_S1(ARBURST_S1),
	.ARVALID_S1(ARVALID_S1),
	.ARREADY_S1(ARREADY_S1),

	// READ ADDRESS2
	.ARID_S2(ARID_S2),
	.ARADDR_S2(ARADDR_S2),
	.ARLEN_S2(ARLEN_S2),
	.ARSIZE_S2(ARSIZE_S2),
	.ARBURST_S2(ARBURST_S2),
	.ARVALID_S2(ARVALID_S2),
	.ARREADY_S2(ARREADY_S2),

	// READ ADDRESS3
	.ARID_S3(ARID_S3),
	.ARADDR_S3(ARADDR_S3),
	.ARLEN_S3(ARLEN_S3),
	.ARSIZE_S3(ARSIZE_S3),
	.ARBURST_S3(ARBURST_S3),
	.ARVALID_S3(ARVALID_S3),
	.ARREADY_S3(ARREADY_S3),

	// READ ADDRESS4
	.ARID_S4(ARID_S4),
	.ARADDR_S4(ARADDR_S4),
	.ARLEN_S4(ARLEN_S4),
	.ARSIZE_S4(ARSIZE_S4),
	.ARBURST_S4(ARBURST_S4),
	.ARVALID_S4(ARVALID_S4),
	.ARREADY_S4(ARREADY_S4),

	// READ ADDRESS5
	.ARID_S5(ARID_S5),
	.ARADDR_S5(ARADDR_S5),
	.ARLEN_S5(ARLEN_S5),
	.ARSIZE_S5(ARSIZE_S5),
	.ARBURST_S5(ARBURST_S5),
	.ARVALID_S5(ARVALID_S5),
	.ARREADY_S5(ARREADY_S5)
);

// R_channel
R_channel R_channel1(
    .clk(ACLK),
    .rst(ARESETn),

    // SLAVE INTERFACE FOR MASTERS
    // READ DATA0
	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),

    //READ DATA1
	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1),

	// READ DATA2
	.RID_M2(RID_M2),
	.RDATA_M2(RDATA_M2),
	.RRESP_M2(RRESP_M2),
	.RLAST_M2(RLAST_M2),
	.RVALID_M2(RVALID_M2),
	.RREADY_M2(RREADY_M2),

    // MASTER INTERFACE FOR SLAVES
    // default slave
    .RID_SD(RID_SD),
	.RDATA_SD(RDATA_SD),
	.RRESP_SD(RRESP_SD),
	.RLAST_SD(RLAST_SD),
	.RVALID_SD(RVALID_SD),
	.RREADY_SD(RREADY_SD),

    // READ DATA0
	.RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),
	.RREADY_S0(RREADY_S0),

    // READ DATA1
	.RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),
	.RREADY_S1(RREADY_S1),
	
	// READ DATA2
	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),
	.RREADY_S2(RREADY_S2),

	// READ DATA3
	.RID_S3(RID_S3),
	.RDATA_S3(RDATA_S3),
	.RRESP_S3(RRESP_S3),
	.RLAST_S3(RLAST_S3),
	.RVALID_S3(RVALID_S3),
	.RREADY_S3(RREADY_S3),

	// READ DATA4
	.RID_S4(RID_S4),
	.RDATA_S4(RDATA_S4),
	.RRESP_S4(RRESP_S4),
	.RLAST_S4(RLAST_S4),
	.RVALID_S4(RVALID_S4),
	.RREADY_S4(RREADY_S4),

	// READ DATA5
	.RID_S5(RID_S5),
	.RDATA_S5(RDATA_S5),
	.RRESP_S5(RRESP_S5),
	.RLAST_S5(RLAST_S5),
	.RVALID_S5(RVALID_S5),
	.RREADY_S5(RREADY_S5)
);

// AW_channel
AW_channel AW_channel1(
    .clk(ACLK),
    .rst(ARESETn),

    // connect info
    // .M0_connect_info(),
    // .M1_connect_info(M1_connect_info),
	.occupied_SD_comb(occupied_SD_comb),
    .occupied_S0_comb(occupied_S0_comb),
    .occupied_S1_comb(occupied_S1_comb),
    .occupied_S2_comb(occupied_S2_comb),
    .occupied_S3_comb(occupied_S3_comb),
    .occupied_S4_comb(occupied_S4_comb),
    .occupied_S5_comb(occupied_S5_comb),

    // SLAVE INTERFACE FOR MASTERS
    // WRITE ADDRESS0
	.AWID_M0(`AXI_ID_BITS'b0),
	.AWADDR_M0(`AXI_ADDR_BITS'b0),
	.AWLEN_M0(`AXI_LEN_BITS'b0),
	.AWSIZE_M0(`AXI_SIZE_BITS'b0),
	.AWBURST_M0(2'b0),
	.AWVALID_M0(1'b0),
	.AWREADY_M0(AWREADY_M0),

    // WRITE ADDRESS1
	.AWID_M1(AWID_M1),
	.AWADDR_M1(AWADDR_M1),
	.AWLEN_M1(AWLEN_M1),
	.AWSIZE_M1(AWSIZE_M1),
	.AWBURST_M1(AWBURST_M1),
	.AWVALID_M1(AWVALID_M1),
	.AWREADY_M1(AWREADY_M1),

	// WRITE ADDRESS2
	.AWID_M2(AWID_M2),
	.AWADDR_M2(AWADDR_M2),
	.AWLEN_M2(AWLEN_M2),
	.AWSIZE_M2(AWSIZE_M2),
	.AWBURST_M2(AWBURST_M2),
	.AWVALID_M2(AWVALID_M2),
	.AWREADY_M2(AWREADY_M2),

    // MASTER INTERFACE FOR SLAVES
    // default slave
    .AWID_SD(AWID_SD),
	.AWADDR_SD(AWADDR_SD),
	.AWLEN_SD(AWLEN_SD),
	.AWSIZE_SD(AWSIZE_SD),
	.AWBURST_SD(AWBURST_SD),
	.AWVALID_SD(AWVALID_SD),
	.AWREADY_SD(AWREADY_SD),

    // WRITE ADDRESS0
	.AWID_S0(AWID_S0),
	.AWADDR_S0(AWADDR_S0),
	.AWLEN_S0(AWLEN_S0),
	.AWSIZE_S0(AWSIZE_S0),
	.AWBURST_S0(AWBURST_S0),
	.AWVALID_S0(AWVALID_S0),
	.AWREADY_S0(AWREADY_S0),

    // WRITE ADDRESS1
	.AWID_S1(AWID_S1),
	.AWADDR_S1(AWADDR_S1),
	.AWLEN_S1(AWLEN_S1),
	.AWSIZE_S1(AWSIZE_S1),
	.AWBURST_S1(AWBURST_S1),
	.AWVALID_S1(AWVALID_S1),
	.AWREADY_S1(AWREADY_S1),

	// WRITE ADDRESS2
	.AWID_S2(AWID_S2),
	.AWADDR_S2(AWADDR_S2),
	.AWLEN_S2(AWLEN_S2),
	.AWSIZE_S2(AWSIZE_S2),
	.AWBURST_S2(AWBURST_S2),
	.AWVALID_S2(AWVALID_S2),
	.AWREADY_S2(AWREADY_S2),

	// WRITE ADDRESS3
	.AWID_S3(AWID_S3),
	.AWADDR_S3(AWADDR_S3),
	.AWLEN_S3(AWLEN_S3),
	.AWSIZE_S3(AWSIZE_S3),
	.AWBURST_S3(AWBURST_S3),
	.AWVALID_S3(AWVALID_S3),
	.AWREADY_S3(AWREADY_S3),

	// WRITE ADDRESS4
	.AWID_S4(AWID_S4),
	.AWADDR_S4(AWADDR_S4),
	.AWLEN_S4(AWLEN_S4),
	.AWSIZE_S4(AWSIZE_S4),
	.AWBURST_S4(AWBURST_S4),
	.AWVALID_S4(AWVALID_S4),
	.AWREADY_S4(AWREADY_S4),

	// WRITE ADDRESS5
	.AWID_S5(AWID_S5),
	.AWADDR_S5(AWADDR_S5),
	.AWLEN_S5(AWLEN_S5),
	.AWSIZE_S5(AWSIZE_S5),
	.AWBURST_S5(AWBURST_S5),
	.AWVALID_S5(AWVALID_S5),
	.AWREADY_S5(AWREADY_S5)
);

// record AW connect info for W_channel
// 2'b00: NULL, 2'b01: default slve, 2'b10: slave 1, 2'b11: slave 2
/*
always_ff @( posedge ACLK or negedge ARESETn) begin : AW_connect_info_reg
	if (~ARESETn) begin
		// M0_connect_info_reg <= 2'b00;
		M1_connect_info_reg <= 2'b00;
		M1_connect_info_W_reg <= 2'b00;
	end
	else begin
		// M0_connect_info_reg <= M0_connect_info_comb;
		M1_connect_info_reg <= M1_connect_info_comb;
		M1_connect_info_W_reg <= M1_connect_info_reg;
	end
end

always_comb begin : AW_connect_info_comb
	// M0_connect_info_comb = M0_connect_info_reg;
	M1_connect_info_comb = M1_connect_info_reg;
	if (AWVALID_M1) begin
		M1_connect_info_comb = M1_connect_info;
	end
end
*/

// W_channel
W_channel W_channel1(
    .clk(ACLK),
    .rst(ARESETn),

    // AW connect info
    // .M1_connect_info_reg(M1_connect_info_reg), 
	// 2'b00: NULL(), 2'b01: default slve(), 2'b10: slave 1(), 2'b11: slave 2
	.occupied_SD_comb(occupied_SD_comb),
    .occupied_S0_comb(occupied_S0_comb),
    .occupied_S1_comb(occupied_S1_comb),
    .occupied_S2_comb(occupied_S2_comb),
    .occupied_S3_comb(occupied_S3_comb),
    .occupied_S4_comb(occupied_S4_comb),
    .occupied_S5_comb(occupied_S5_comb),

	// AWVALID_S signals
	// .AWVALID_SD(AWVALID_SD),
	// .AWVALID_S0(AWVALID_S0),
	// .AWVALID_S1(AWVALID_S1),
	// .AWVALID_S2(AWVALID_S2),
	// .AWVALID_S3(AWVALID_S3),
	// .AWVALID_S4(AWVALID_S4),
	// .AWVALID_S5(AWVALID_S5),

    //SLAVE INTERFACE FOR MASTERS
    // WRITE DATA1
	.WDATA_M1(WDATA_M1),
	.WSTRB_M1(WSTRB_M1),
	.WLAST_M1(WLAST_M1),
	.WVALID_M1(WVALID_M1),
	.WREADY_M1(WREADY_M1),

	// WRITE DATA2
	.WDATA_M2(WDATA_M2),
	.WSTRB_M2(WSTRB_M2),
	.WLAST_M2(WLAST_M2),
	.WVALID_M2(WVALID_M2),
	.WREADY_M2(WREADY_M2),

    //MASTER INTERFACE FOR SLAVES
	// default slave
	.WDATA_SD(WDATA_SD),
	.WSTRB_SD(WSTRB_SD),
	.WLAST_SD(WLAST_SD),
	.WVALID_SD(WVALID_SD),
	.WREADY_SD(WREADY_SD),

    // slave 0
	.WDATA_S0(WDATA_S0),
	.WSTRB_S0(WSTRB_S0),
	.WLAST_S0(WLAST_S0),
	.WVALID_S0(WVALID_S0),
	.WREADY_S0(WREADY_S0),

    // slave 1
	.WDATA_S1(WDATA_S1),
	.WSTRB_S1(WSTRB_S1),
	.WLAST_S1(WLAST_S1),
	.WVALID_S1(WVALID_S1),
	.WREADY_S1(WREADY_S1),

	// slave 2
	.WDATA_S2(WDATA_S2),
	.WSTRB_S2(WSTRB_S2),
	.WLAST_S2(WLAST_S2),
	.WVALID_S2(WVALID_S2),
	.WREADY_S2(WREADY_S2),

	// slave 3
	.WDATA_S3(WDATA_S3),
	.WSTRB_S3(WSTRB_S3),
	.WLAST_S3(WLAST_S3),
	.WVALID_S3(WVALID_S3),
	.WREADY_S3(WREADY_S3),

	// slave 4
	.WDATA_S4(WDATA_S4),
	.WSTRB_S4(WSTRB_S4),
	.WLAST_S4(WLAST_S4),
	.WVALID_S4(WVALID_S4),
	.WREADY_S4(WREADY_S4),

	// slave 5
	.WDATA_S5(WDATA_S5),
	.WSTRB_S5(WSTRB_S5),
	.WLAST_S5(WLAST_S5),
	.WVALID_S5(WVALID_S5),
	.WREADY_S5(WREADY_S5)
);

// B_channel
B_channel B_channel1(
    .clk(ACLK),
    .rst(ARESETn),

	// W_channel connect info
	// .M1_connect_info_W_reg(M1_connect_info_W_reg),

    // SLAVE INTERFACE FOR MASTERS
    // master 1
	.BID_M1(BID_M1),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),
	.BREADY_M1(BREADY_M1),

	// master 2
	.BID_M2(BID_M2),
	.BRESP_M2(BRESP_M2),
	.BVALID_M2(BVALID_M2),
	.BREADY_M2(BREADY_M2),

    // MASTER INTERFACE FOR SLAVES
	// default slave
	.BID_SD(BID_SD),
	.BRESP_SD(BRESP_SD),
	.BVALID_SD(BVALID_SD),
	.BREADY_SD(BREADY_SD),

    // slave 0
	.BID_S0(BID_S0),
	.BRESP_S0(BRESP_S0),
	.BVALID_S0(BVALID_S0),
	.BREADY_S0(BREADY_S0),

    // slave 1
	.BID_S1(BID_S1),
	.BRESP_S1(BRESP_S1),
	.BVALID_S1(BVALID_S1),
	.BREADY_S1(BREADY_S1),

	// slave 2
	.BID_S2(BID_S2),
	.BRESP_S2(BRESP_S2),
	.BVALID_S2(BVALID_S2),
	.BREADY_S2(BREADY_S2),

	// slave 3
	.BID_S3(BID_S3),
	.BRESP_S3(BRESP_S3),
	.BVALID_S3(BVALID_S3),
	.BREADY_S3(BREADY_S3),

	// slave 4
	.BID_S4(BID_S4),
	.BRESP_S4(BRESP_S4),
	.BVALID_S4(BVALID_S4),
	.BREADY_S4(BREADY_S4),

	// slave 5
	.BID_S5(BID_S5),
	.BRESP_S5(BRESP_S5),
	.BVALID_S5(BVALID_S5),
	.BREADY_S5(BREADY_S5)
);

// default slave
default_slave default_slave1(
    .CLK(ACLK),
	.RST(ARESETn),

	// Read Address Signals
	.ARID(ARID_SD),
	.ARADDR(ARADDR_SD),
	.ARLEN(ARLEN_SD),
	.ARSIZE(ARSIZE_SD),
	.ARBURST(ARBURST_SD), // only INCR type
	.ARVALID(ARVALID_SD),
	.ARREADY(ARREADY_SD),

	// Read Data Signals
	.RID(RID_SD),
	.RDATA(RDATA_SD),
	.RRESP(RRESP_SD),
	.RLAST(RLAST_SD),
	.RVALID(RVALID_SD),
	.RREADY(RREADY_SD),

	// Write Address Signals
	.AWID(AWID_SD),
	.AWADDR(AWADDR_SD),
	.AWLEN(AWLEN_SD),
	.AWSIZE(AWSIZE_SD),
	.AWBURST(AWBURST_SD), // only INCR type
	.AWVALID(AWVALID_SD),
	.AWREADY(AWREADY_SD),
	
	// Write Data Signals
	.WDATA(WDATA_SD),
    .WSTRB(WSTRB_SD),
    .WLAST(WLAST_SD),
    .WVALID(WVALID_SD),
    .WREADY(WREADY_SD),

	// Write Response Signals
	.BID(BID_SD),
    .BRESP(BRESP_SD),
    .BVALID(BVALID_SD),
    .BREADY(BREADY_SD)
);

endmodule
