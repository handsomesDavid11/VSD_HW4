// `include "AXI_define.svh"

module decoder (
    input [`AXI_ADDR_BITS-1:0] addr, // 32 bits
    input ARREADY_SD, 
    input ARREADY_S0,
    input ARREADY_S1,
    input ARREADY_S2,
    input ARREADY_S3,
    input ARREADY_S4,
    input ARREADY_S5,
    output logic ARREADY_M, 
    output logic SD_req,
    output logic S0_req,
    output logic S1_req,
    output logic S2_req,
    output logic S3_req,
    output logic S4_req,
    output logic S5_req
    // output logic [1:0] slave_ID // 0: default
);

always_comb begin : addr_decode
    SD_req = 1'b1;
    S0_req = 1'b0;
    S1_req = 1'b0;
    S2_req = 1'b0;
    S3_req = 1'b0;
    S4_req = 1'b0;
    S5_req = 1'b0;
    ARREADY_M = ARREADY_SD;
    if (addr[31:16] == 16'h0000 && addr[15:0] <= 16'h1fff) begin // slave 0
        SD_req = 1'b0;
        S0_req = 1'b1;
        ARREADY_M = ARREADY_S0;  
    end
    else if (addr[31:16] == 16'h0001) begin // slave 1
        SD_req = 1'b0;
        S1_req = 1'b1;
        ARREADY_M = ARREADY_S1;
    end
    else if (addr[31:16] == 16'h0002) begin // slave 2
        SD_req = 1'b0;
        S2_req = 1'b1;
        ARREADY_M = ARREADY_S2;
    end
    else if (addr[31:16] == 16'h1002 && addr[15:0] <= 16'h0400) begin // slave 3
        SD_req = 1'b0;
        S3_req = 1'b1;
        ARREADY_M = ARREADY_S3;  
    end
    else if (addr[31:16] == 16'h1001 && addr[15:0] <= 16'h03ff) begin // slave 4
        SD_req = 1'b0;
        S4_req = 1'b1;
        ARREADY_M = ARREADY_S4; 
    end
    else if (addr[31:24] == 8'h20 && addr[23:16] <= 8'h1f) begin // slave 5
        SD_req = 1'b0;
        S5_req = 1'b1;
        ARREADY_M = ARREADY_S5; 
    end
    /*
    case (addr)
        16'h0000: begin // slave 0
            SD_req = 1'b0;
            S0_req = 1'b1;
            ARREADY_M = ARREADY_S0;
        end
        16'h0001: begin // slave 1
            SD_req = 1'b0;
            S1_req = 1'b1;
            ARREADY_M = ARREADY_S1;
        end
        16'h0002: begin // slave 2
            SD_req = 1'b0;
            S2_req = 1'b1;
            ARREADY_M = ARREADY_S2;
        end
        16'h1002: begin // slave 3
            SD_req = 1'b0;
            S3_req = 1'b1;
            ARREADY_M = ARREADY_S3;
        end
        16'h1001: begin // slave 4
            SD_req = 1'b0;
            S4_req = 1'b1;
            ARREADY_M = ARREADY_S4;
        end
        16'h2000: begin // slave 5
            SD_req = 1'b0;
            S5_req = 1'b1;
            ARREADY_M = ARREADY_S5;
        end
    endcase
    */
end

endmodule