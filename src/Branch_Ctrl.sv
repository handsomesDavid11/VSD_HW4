module Branch_Ctrl (
    input [1:0] branch_flag, 
    input zero_flag,

    output logic [1:0] branch_ctrl
);

always_comb begin : branch_control
    branch_ctrl = branch_flag;
    if (zero_flag) begin
        branch_ctrl = 2'b00;
    end
end
    
endmodule