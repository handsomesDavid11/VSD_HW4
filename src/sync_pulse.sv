module sync_pulse (
    input clk_a, // posedge
    input rst_a, // posedge
    input clk_b, // posedge
    input rst_b, // posedge

    input signal_a,
    output logic ready,
    output logic signal_b
);

logic cur_state;
logic nxt_state;

// for ack signal to clk_a
logic a_FF_0;
logic a_FF_1;
logic a_FF_2;
logic a_FF_3;

logic signal_b_comb;
logic ack;
logic ack_comb;

logic toggle_flop;
logic toggle_flop_comb;
logic toggle_flop_temp;


// clk_b signal
// logic b_FF;
logic b_FF_0;
logic b_FF_1;
logic b_FF_2;
logic b_FF_0_comb;
logic b_FF_1_comb;
logic b_FF_2_comb;

always_ff @( posedge clk_a or posedge rst_a ) begin : toggle_flop_reg
    if (rst_a) begin
        toggle_flop <= 1'b0;
        toggle_flop_temp <= 1'b0;
    end
    else begin
        toggle_flop <= toggle_flop_comb;
        toggle_flop_temp <= toggle_flop;
    end
end

always_comb begin : toggle_flop_comb_logic
    toggle_flop_comb = toggle_flop ^ signal_a;
end

always_ff @( posedge clk_b ) begin : b_FF_register
    // b_FF_0 <= b_FF;
    b_FF_1 <= b_FF_1_comb;
    b_FF_2 <= b_FF_2_comb;
    signal_b <= signal_b_comb;
end

always_ff @( posedge clk_b or posedge rst_b ) begin : b_FF_0_reg
    if (rst_b) begin 
        // b_FF <= 1'b0;
        b_FF_0 <= 1'b0;
        // b_FF_1 <= 1'b0;
        // b_FF_2 <= 1'b0;
        // signal_b <= 1'b0;
    end
    else begin
        // b_FF <= toggle_flop;
        b_FF_0 <= b_FF_0_comb;
        // b_FF_1 <= b_FF_1_comb;
        // b_FF_2 <= b_FF_2_comb;
        // signal_b <= signal_b_comb;
    end
end

always_comb begin : b_FF_comb
    // b_FF_0_comb = toggle_flop;
    b_FF_0_comb = toggle_flop_temp;
    // b_FF_0_comb = b_FF;
    b_FF_1_comb = b_FF_0;
    b_FF_2_comb = b_FF_1;
end

always_comb begin : signal_out_logic
    // signal_b = b_FF_1 ^ b_FF_2;
    signal_b_comb = b_FF_1 ^ b_FF_2;
end

always_ff @( posedge clk_a ) begin : cdc_clk_a_registers
    a_FF_0 <= b_FF_2;
    a_FF_1 <= a_FF_0;
    a_FF_2 <= a_FF_1;
end

always_ff @( posedge clk_a or posedge rst_a ) begin : clk_a_reg
    if (rst_a) begin
        a_FF_3 <= 1'b0;
        ack <= 1'b0;
    end
    else begin
        a_FF_3 <= a_FF_2;
        ack <= ack_comb;
    end
end

always_comb begin : ack_logic
    ack_comb = a_FF_3 ^ a_FF_2;
end

always_ff @( posedge clk_a or posedge rst_a ) begin : cur_state_logic
    if (rst_a) begin
        cur_state <= 1'b0;
    end
    else begin
        cur_state <= nxt_state;
    end
end

always_comb begin : nxt_state_control
    nxt_state = cur_state;
    case (cur_state)
        1'b0: begin // ready
            if (signal_a) begin
                nxt_state = 1'b1;
            end
        end 
        1'b1: begin //busy
            if (ack) begin
                nxt_state = 1'b0;
            end
        end
    endcase
end

always_comb begin : ready_control
    ready = 1'b0;
    case (cur_state)
        1'b0: begin // ready
            ready = 1'b1;
        end 
        1'b1: begin //busy
            ready = 1'b0;
        end
    endcase
end
    
endmodule