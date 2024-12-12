
module L1C_inst(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,	// im_OE

  //MEM to CPU wrapper 
  input [`DATA_BITS-1:0] I_out,
  input I_wait, // ON when mem send data to cache 

  input rvalid_m0_i,	// NEW
  input rready_m0_i,  
  input core_wait_CD_i,  //??


  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,	// im_DO
  output logic core_wait,	// ON when L1CI_state is not IDLE
  // CPU wrapper to Mem
  output logic I_req,	// ON when L1CI_state is READ_MISS, like im_OE
  output logic [`DATA_BITS-1:0] I_addr // when L1CI_state is READ_MISS, send to wrapper

);

  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;	// 128 bits
  logic [`CACHE_DATA_BITS-1:0] DA_in;	// 128 bits
  logic [`CACHE_WRITE_BITS-1:0] DA_write;	// write signal to data array: 16bits?
  logic DA_read;

  //TA input/output 
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid;
  
  logic [`DATA_BITS-1:0] core_addr_t;
  logic [`DATA_BITS-1:0] core_addr_t_n;


  logic hit, wait_flag;
  logic [2:0] wait_cnt;
  
   parameter INIT = 2'h0,
            CHECK = 2'h1,
            RMISS = 2'h2,
            FIN   = 2'h3;

  logic [1:0] cur_state, next_state;
  always_ff @(posedge clk, posedge rst) begin 
    if(rst) 
      cur_state <= INIT;
    else 
      cur_state <= next_state;
  end
  always_comb begin : cache FSM
    case(cur_state)
      INIT:
      begin
        if(core_req)
        begin
          if(valid[index])
            next_state = CHECK;
          else
            next_state = RMISS;
        end
        else
          next_state = INIT;
      end
      CHECK:
      begin
        if(hit)
          next_state = FIN;
        else
          next_state = CHECK;
      end
      RMISS:
      begin
        if(wait_flag)
          next_state = FIN;
        else 
          next_state = RMISS;
      end
      FIN:
      begin
        next_state = INIT;
      end
    endcase
  end

// assign index and tag
  assign index  = (cur_state == INIT) ? core_addr[8:4] : core_addr_t[8:4];  
  assign TA_in  = (cur_state == INIT) ? core_addr[31:9] : core_addr_t[31:9];
  assign hit    = valid[index] && (TA_in == TA_out) && (cur_state == CHECK);
  
  always_ff @(posedge clk or posedge rst) begin //valid
    if(rst)
      valid <= `CACHE_LINES'h0;
    else if(cur_state == RMISS) 
      valid[index] <= 1'b1;
  end  
  assign TA_read  = (cur_state == INIT) || (cur_state == CHECK);
  assign TA_in    = (cur_state == INIT) ? core_addr[31:9] : core_addr_t[31:9];
  assign TA_write = ~wait_cnt[1];

  assign DA_read  = (cur_state == CHECK) && hit;

  always_comb begin
    
    DA_write = `CACHE_WRITE_BITS'hffff;
    DA_in    = `CACHE_DATA_BITS'h0;
    
    if(wait_cnt == 3'b100) begin
             
    end
    
  

  end

 

  always_ff @(posedge clk or posedge rst)begin //reg core_addr
    if(rst) 
      core_addr_t <= DATA_BITS'h0;
    else if(cur_state == INIT)
      core_addr_t <= core_addr;
    else 
      core_addr_t <= core_addr_t;
  end

  assign wait_flag = wait_cnt[2];

  always_ff @(posedge clk or posedge rst) begin // wait_cnt
    if(rst)
      wait_cnt <= 3'h0;
    else if(cur_state == RMISS)
      wait_cnt <= wait_flag ?  3'h0 : (~I_wait ?( wait_cnt + 3'b1) :wait_cnt);
  end
  


  
  
  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),	// each bit control 1 byte, 128=16*8 bits
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );

endmodule

