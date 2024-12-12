`include "../include/AXI_define.svh"
`include "FIFO.sv"
module DMA_master (
     input clk,
     input rst,


     //AXI
     //WRITE ADDRESS
	output logic [`AXI_ID_BITS-1:0] AWID,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR,
	output logic [`AXI_LEN_BITS-1:0] AWLEN,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE,
	output logic [1:0] AWBURST,
	output logic AWVALID,
	input AWREADY,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA,
	output logic [`AXI_STRB_BITS-1:0] WSTRB,
	output logic WLAST,
	output logic WVALID,
	input WREADY,
	
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID,
	input [1:0] BRESP,
	input BVALID,
	output logic BREADY,

	//READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR,
	output logic [`AXI_LEN_BITS-1:0] ARLEN,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE,
	output logic [1:0] ARBURST,
	output logic ARVALID,
	input ARREADY,
	
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID,
	input [`AXI_DATA_BITS-1:0] RDATA,
	input [1:0] RRESP,
	input RLAST,
	input RVALID,
	output logic RREADY,

     input  [31:0] DMASRC,   
     input  [31:0] DMADST,
     input  [31:0] DMALEN,
     input   DMAEN,

     output logic interrupt

);
     logic [2:0] cur_state, next_state;

     localparam [2:0]    INIT        = 3'b000,
                         CHECK       = 3'b001,
                         READADDR    = 3'b010,
                         WRITEADDR   = 3'b011,
                         BUSY        = 3'b100,
                         RESPONSE    = 3'b101,
                         DONE        = 3'b110;

     logic AR_done, RD_done, AW_done, WD_done, RES_done;
     assign AR_done  = ARVALID & ARREADY;
     assign RD_done  = RVALID  & RREADY;
     assign AW_done  = AWVALID & AWREADY;
     assign WD_done  = WVALID  & WREADY;
     assign RES_done = BVALID  & BREADY; 

     logic RD_done_last, WD_done_last;
     assign RD_done_last = RLAST & RD_done;
     assign WD_done_last = WLAST & WD_done;
     //fifo
     logic [`AXI_DATA_BITS-1:0] fifo_DI, fifo_DO;
     logic fifo_WEn, fifo_REn, fifo_empty, fifo_full;
     //DMA
     logic [`AXI_LEN_BITS-1:0] oper_DMALEN;
     logic [31:0] rem_DMALEN;
     logic burst;
     logic done;
     //AXI
     logic [`AXI_ADDR_BITS-1:0] tmp_DMASRC;
     logic [`AXI_ADDR_BITS-1:0] tmp_DMADST;
     

     always_ff @(posedge clk or posedge rst) begin
          if(rst)
               cur_state <= INIT;
          else 
               cur_state <= next_state;
     end

     always_comb begin
          case(cur_state)
               INIT:begin
                    if(DMAEN)
                         next_state = CHECK;
                    else
                         next_state = INIT;
               end
               CHECK:begin
                    if(|rem_DMALEN)
                         next_state = READADDR;
                    else
                         next_state = DONE;
               end
               READADDR:begin
                    if(AR_done)
                         next_state = WRITEADDR;
                    else
                         next_state = READADDR;
               end
               WRITEADDR:begin
                    if(AW_done)
                         next_state = BUSY;
                    else
                         next_state = WRITEADDR;
               end
               BUSY:begin
                    if(WD_done_last)
                         next_state = RESPONSE;
                    else
                         next_state = BUSY;
               end
               RESPONSE:begin
                    next_state = RESPONSE;
                    if(RES_done)begin
                         if(~|rem_DMALEN)
                              next_state = DONE;
                         else
                              next_state = READADDR;
                    end
               end
               default: begin
                    next_state = INIT;
               end
          endcase
     end
     always_comb begin
          done      = 1'b0;
          interrupt = 1'b0;
          case(cur_state)
               RESPONSE: 
                    done = ~|rem_DMALEN;
               DONE:
                    interrupt = 1'b1;
          endcase
     end
     //reminder DMALEN 
     always_ff @(posedge clk or posedge rst) begin
          if(rst)
               rem_DMALEN <= `AXI_DATA_BITS'h0;
          else if (DMAEN)
               rem_DMALEN <= DMALEN;
          else if (WD_done_last)
               rem_DMALEN <= rem_DMALEN - oper_DMALEN;
               //rem_DMALEN <= rem_DMALEN - `AXI_DATA_BITS'h1;
     end

     //reminder oper_DMALEN
     always_ff @(posedge clk or posedge rst) begin
          if(rst)
               oper_DMALEN <= `AXI_LEN_BITS'h0;
          else if (DMAEN)
               oper_DMALEN <= ( DMALEN < `AXI_DATA_BITS'hf )?DMALEN[`AXI_LEN_BITS-1:0]:`AXI_LEN_BITS'hf ;
          else if (cur_state == RESPONSE)begin               
                    if(rem_DMALEN < `AXI_DATA_BITS'hf)
                         oper_DMALEN <= rem_DMALEN[`AXI_LEN_BITS-1:0];
                    else 
                         oper_DMALEN <= `AXI_LEN_BITS'hf;
          end
               //oper_DMALEN <= ( rem_DMALEN < `AXI_DATA_BITS'hf )?rem_DMALEN[`AXI_LEN_BITS-1:0]:`AXI_LEN_BITS'hf;
     end
     
     always_ff @(posedge clk or posedge rst) begin
          if(rst) begin
               tmp_DMADST <= 32'h0;
               tmp_DMASRC <= 32'h0;    
               
          end
          else if(DMAEN) begin
               tmp_DMADST <= DMADST;
               tmp_DMASRC <= DMASRC;
          end
          else if((cur_state == RESPONSE) && ~done) begin
               if(tmp_DMASRC == 32'h20104fc8 | tmp_DMASRC == 32'h20104fe4)begin
                    tmp_DMADST <= tmp_DMADST + `AXI_ADDR_BITS'h1c;
                    tmp_DMASRC <= tmp_DMASRC + `AXI_ADDR_BITS'h1c;
                    
               end
          else 
          begin
               tmp_DMADST <= tmp_DMADST + `AXI_ADDR_BITS'h20;
               tmp_DMASRC <= tmp_DMASRC + `AXI_ADDR_BITS'h20;
          end
          end
     end
     //FIFO
     logic dram_burst;
     logic [2:0] dcnt;
     ///////////////
     always_ff @(posedge clk or posedge rst) begin
          if (rst) 
               dram_burst <= 1'b0;
          else if(dcnt[2]) 
               dram_burst <= 1'b0;
          else if(AW_done)
               dram_burst <= tmp_DMADST[31:24] == 8'h20;
     end

     always_ff @(posedge clk or posedge rst) begin
          if (rst)
               dcnt <= 3'h0;
          else if(dram_burst)
               dcnt <= dcnt + 3'h1;
          else if(interrupt)
               dcnt <= 3'h0;
          else if(dcnt[2])
               dcnt <= dcnt;
     end
     

     assign fifo_DI  = RDATA;
     assign fifo_WEn = (cur_state == BUSY) && ~fifo_full && RVALID;
     assign fifo_REn = (cur_state == BUSY) && ~fifo_empty && WREADY || (dcnt == 3'h4);   

     //write count 

     logic wlast;
     logic rlast;
     //length
     logic [`AXI_LEN_BITS-1:0] wcnt, rcnt;

     assign rlast = rcnt == oper_DMALEN;
     assign wlast = wcnt == oper_DMALEN;

     always_ff @(posedge clk or posedge rst) begin
          if (rst)
               wcnt <= `AXI_LEN_BITS'h0;
          else if(cur_state == RESPONSE)
               wcnt <= `AXI_LEN_BITS'h0;
          else if(wlast)
               wcnt <=  wcnt;
          else if(fifo_REn)
               wcnt <=  wcnt + `AXI_LEN_BITS'h1;
     end

     always_ff @(posedge clk or posedge rst) begin
          if (rst)
               rcnt <= `AXI_LEN_BITS'h0;
          else if(cur_state == RESPONSE)
               rcnt <= `AXI_LEN_BITS'h0;
          else if(rlast)
               rcnt <=  rcnt;
          else if(fifo_WEn)
               rcnt <=  rcnt + `AXI_LEN_BITS'h1;
     end


     FIFO FIFO(
          .clk(clk),
          .rst(rst),
          .clear(interrupt),
          .WEn(fifo_WEn),
          .REn(fifo_REn),
          .DI(fifo_DI),
          .DO(fifo_DO),
          .empty(fifo_empty),
          .full(fifo_full)

     );




     //to AXI
     assign AWSIZE  = `AXI_SIZE_WORD;
     assign ARID    = `AXI_ID_BITS'h2;
     assign ARADDR  = tmp_DMASRC;
     assign ARLEN   = oper_DMALEN;
     assign ARSIZE  = `AXI_SIZE_WORD;
     assign ARBURST = `AXI_BURST_FIXED;
     assign AWID    =  `AXI_ID_BITS'h2;
     assign AWADDR  = tmp_DMADST;
     assign AWLEN   = oper_DMALEN;
     assign AWBURST = `AXI_BURST_FIXED;
     assign WSTRB   = 4'b0;
     assign WDATA   = fifo_DO;
     assign WLAST   = wlast;
     //valid
     assign ARVALID = (cur_state == READADDR);
     assign AWVALID = (cur_state == WRITEADDR);
     assign WVALID  = (cur_state == BUSY) && fifo_REn;
     //ready
     assign RREADY  = (cur_state == BUSY) && (~fifo_full);
     assign BREADY  = (cur_state == RESPONSE);








     



endmodule