// `include "AXI_define.svh"

module decoder_S (
    input [3:0] ID, // higher 4 bits
    input RREADY_MD, 
    input RREADY_M0,
    input RREADY_M1,
    input RREADY_M2,
    output logic RREADY_S,
    output logic M0_req,
    output logic M1_req,
    output logic M2_req
);

always_comb begin : id_decode
    M0_req = 1'b0;
    M1_req = 1'b0;
    M2_req = 1'b0;
    RREADY_S = RREADY_MD;
    case (ID)
        4'b0001: begin // master 0
            RREADY_S = RREADY_M0;
            M0_req = 1'b1;
        end
        4'b0010: begin // master 1
            RREADY_S = RREADY_M1;
            M1_req = 1'b1;
        end
        4'b0011: begin // master 2
            RREADY_S = RREADY_M2;
            M2_req = 1'b1;
        end
    endcase
end

endmodule