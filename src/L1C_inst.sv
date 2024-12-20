
module L1C_inst(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,	// im_OE
  input core_write,  
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  //MEM to CPU wrapper 
  input [`DATA_BITS-1:0] I_out,
  input I_wait, // ON when mem send data to cache 

  input rvalid_m0_i,	// NEW
  input rready_m0_i,  
  input core_wait_CD_i,  

 

  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,	// im_DO
  output logic core_wait,	// ON when L1CI_state
  // CPU wrapper to Mem
  output logic I_req,	// ON when L1CI_state is READ_MISS, like im_OE
  output logic [`DATA_BITS-1:0] I_addr, // when L1CI_state is READ_MISS, send to wrapper
  output logic I_write,
  output logic [`DATA_BITS-1:0] I_in,
  output logic [`CACHE_TYPE_BITS-1:0] I_type

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
  logic [`DATA_BITS-1:0] read_data;

  logic hit, wait_flag;
  logic rst_cnt;
  logic [3:0] DA_write_control;
  logic [2:0] wait_cnt;
  
   parameter INIT = 2'h0,
            CHECK = 2'h1,
            READ  = 2'h2,
            WRITE = 2'h3;

  logic [1:0] cur_state, next_state;
  always_ff @(posedge clk or posedge rst) begin 
    if(rst) 
      cur_state <= INIT;
    else 
      cur_state <= next_state;
  end
  always_comb begin 
    case(cur_state)
      INIT:begin
        if(core_req)begin
          if(core_write)
            next_state = WRITE;
          else begin
            if(valid[index]) next_state = CHECK;
            else next_state = READ;

          end
        end
        else
          next_state = INIT;
      end
      CHECK:begin
        if(hit)
          next_state = INIT;
        else
          next_state = READ;
      end
      READ:begin
        if(wait_cnt == 3'b110 & ~I_wait)
          next_state = INIT;
        else 
          next_state = READ;
      end
      WRITE:begin
        if(I_wait) 
          next_state = WRITE;
        else 
          next_state = INIT;
      end
    endcase
  end

  always_ff @(posedge clk or posedge rst) begin
    core_addr_t <= rst? `AXI_ADDR_BITS'h0 : (cur_state == INIT)? core_addr:core_addr_t;
  end



// assign index and tag
  assign index  = (cur_state == INIT) ? core_addr[8:4] : core_addr_t[8:4];  
  assign TA_in  = (cur_state == INIT) ? core_addr[31:9] : core_addr_t[31:9];
 //assign hit    = valid[index] && (TA_in == TA_out) && (cur_state == CHECK);
  //assign index  = core_addr[8:4];
  //assign TA_in  = core_addr[31:9];
  assign hit    = (valid[index] && (TA_in == TA_out))&& (cur_state == CHECK);
  


  //always_ff @(posedge clk or posedge rst) begin //valid
  //  if(rst)
  //    valid <= 32'h0;
  //  else if(cur_state == RMISS) 
  //    valid[index] <= 1'b1;
  //end  

  integer i;
  always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
      for (i = 0; i<`CACHE_LINES; i = i+1)
        valid[i] <= 1'b0;
    end
    else begin
      valid[index] <= (~TA_write)? 1'b1: valid[index];
    end
  end

  //control signal and data from CPU and IM 
  always_comb begin
    
    case(cur_state)
      INIT: begin
        //core_out  = DA_out[{core_addr[3:2], 5'b0}+:32];//data to cpu
        core_out  = DA_out[{core_addr[3:2], 5'b0}+:32];
        core_wait = core_req; // if core require data wait = 1
        
        I_req     = 1'b0;
        I_addr    = `DATA_BITS'b0;
        I_write   = 1'b0;
        I_in      = `DATA_BITS'b0;
        I_type    = `CACHE_TYPE_BITS'b0;
      end
      CHECK: begin
        core_out  = (hit)?DA_out[{core_addr_t[3:2], 5'b0}+:32]:`DATA_BITS'b0;//data to cpu
        //core_out  = DA_out[{core_addr[3:2], 5'b0}+:32];
        core_wait = ~hit ; 
        I_req     = 1'b0;
        I_addr    = `DATA_BITS'b0;
        I_write   = 1'b0;
        I_in      = `DATA_BITS'b0;
        I_type    = core_type;
      end
      READ: begin
        if(wait_cnt == 3'b110) begin
          core_out  = DA_out[{core_addr_t[3:2], 5'b0}+:32];//data to cpu
          core_wait = 1'b0; 
          I_req     = 1'b0;
          I_addr    = core_addr;
          I_write   = 1'b0;
          I_in      = core_in;
          I_type    = core_type;
        end
        else if(wait_cnt == 3'b101 || wait_cnt == 3'b100)begin
          core_out  = DA_out[{core_addr_t[3:2], 5'b0}+:32];//data to cpu
          core_wait = 1'b1; 
          I_req     = 1'b0;
          I_addr    = {core_addr_t[`DATA_BITS-1:4], 4'b0};
          I_write   = 1'b0;
          I_in      = core_in;
          I_type    = core_type;
        end

        else begin
          core_out  = DA_out[{core_addr_t[3:2], 5'b0}+:32];//data to cpu
          core_wait = 1'b1; 
          I_req     = 1'b1;
          I_addr    = {core_addr[`DATA_BITS-1:4], 4'b0};
          I_write   = 1'b0;
          I_in      = core_in;
          I_type    = core_type;
        end
      end
      WRITE: begin
        core_out  = `DATA_BITS'b0;
        core_wait = I_wait ; 
        I_req     = 1'b1;
        I_addr    = core_addr;
        I_write   = 1'b1;
        I_in      = core_in;
        I_type    = core_type;
      end
    endcase
  end
  always_comb begin
    TA_read   = 1'b1; //active 
    DA_in     = `CACHE_DATA_BITS'b0;
    DA_write  = `CACHE_WRITE_BITS'hffff;
    case(cur_state)
      INIT: begin
        DA_read   = 1'b0; //active high
        TA_write  = 1'b1; //active low
      end
      CHECK: begin
        DA_read   = 1'b1;
        TA_write  = 1'b1;
      end
      READ: begin
        if(wait_cnt == 3'b110) begin
          DA_in[{wait_cnt[1:0],5'b0}+:32]    = I_out;
          DA_write[{wait_cnt[1:0],2'b0}+:4]  = 4'b1111;
          DA_read   = 1'b1;
          TA_write  = 1'b1; 
        end
        else if(wait_cnt == 3'b101 || wait_cnt == 3'b100)begin
          DA_in[{wait_cnt[1:0],5'b0}+:32]    = I_out;
          DA_write[{wait_cnt[1:0],2'b0}+:4]  = 4'b1111;
          DA_read   = 1'b1;
          TA_write  = 1'b1; 
        end
        else begin
          DA_in[{wait_cnt[1:0], 5'b0}+:32] = I_out;
          DA_write[{wait_cnt[1:0], 2'b0}+:4] = (~I_wait)? DA_write_control:4'b1111;
          DA_read = 1'b0;
          TA_write = ~(wait_cnt[1:0] & ~I_wait);
        end
      end
      WRITE: begin
        DA_in[{core_addr[3:2], 5'b0}+:32] = core_in;
        DA_write[{core_addr[3:2], 2'b0}+:4] = (hit & valid[index])? DA_write_control: 4'b1111;
        DA_read = 1'b0;
        TA_write = 1'b1;
      end
    endcase
  end

  always_comb begin
    DA_write_control = 4'b1111;
    if(core_write) begin
      case(core_type) 
        `CACHE_WORD:  DA_write_control = 4'b0;
        `CACHE_HWORD: DA_write_control[core_addr[1:0]] = 1'b0;
        `CACHE_BYTE:  DA_write_control[{core_addr[1],1'b0}+:2] = 2'b00;
        default : DA_write_control = 4'b1111;
      endcase
    end
    else begin
      DA_write_control = I_wait? 4'b1111:4'b0;
    end
  end
  always_comb begin
    case (cur_state)
      READ : rst_cnt = 1'b0;
      default : rst_cnt = 1'b1;
    endcase
  end

  always_ff @(posedge clk or  posedge rst) begin
    if(rst)
      wait_cnt <= 3'b0;
    else begin
      if(rst_cnt)
        wait_cnt <= 3'b0;
      else if(wait_cnt == 3'b110)
        wait_cnt <= 3'b0;
      else
        wait_cnt <= (I_wait)? wait_cnt: wait_cnt + 3'b1;
    end
  end





  //assign TA_read  = (cur_state == INIT) || (cur_state == CHECK);
  //assign TA_write = ~wait_cnt[1];
  //assign DA_read  = (cur_state == CHECK) && hit;
//
  //always_comb begin
  //  
  //  DA_write = `CACHE_WRITE_BITS'hffff;
  //  DA_in    = `CACHE_DATA_BITS'h0;
  //  
  //  if( cur_state == RMISS) begin
  //    DA_write = &wait_cnt[1:0]? `CACHE_WRITE_BITS'h0 : `CACHE_WRITE_BITS'hffff;
  //    DA_in[127:96] = I_out;
  //    DA_in[95:64] = DA_in[127:96];
  //    DA_in[63:32] = DA_in[95:64];
  //    DA_in[31:0] = DA_in[63:32];
  //  end
  //end


  
  
  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),	// each bit control 1 byte, 128=16*8 bits
    .OE(DA_read),
    .CS(1'b0)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b0)
  );

endmodule

