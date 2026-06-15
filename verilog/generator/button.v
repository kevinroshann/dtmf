module buttons (
    input clk,
    input r1, r2, r3,
    output reg c1, c2, c3,
    output reg [4:0] key,
    // output reg led_blue_n,
    // output reg led_amber_n,
    // output reg led_rgb_green_n
);


    parameter STATE_SCAN_C1= 4'b0000, STATE_READ_C1= 4'b0001, STATE_READ_C1_WAIT = 4'b0010;
    parameter STATE_SCAN_C2= 4'b0011, STATE_READ_C2= 4'b0100, STATE_READ_C2_WAIT = 4'b0101;
    parameter STATE_SCAN_C3= 4'b0110, STATE_READ_C3= 4'b0111, STATE_READ_C3_WAIT = 4'b1000;
    
    reg [3:0] curr_state = STATE_SCAN_C1;
    reg [3:0] next_state;
    reg [2:0] ff1, ff2;
    reg [8:0] det_key = 9'b000000000;

    reg [22:0] clk_div = 0;
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
    end

    wire scan_clk  = clk_div[15];

    wire [2:0] row = {r3, r2, r1}; 

    always @(posedge scan_clk) begin
        ff1        <= row;
        ff2        <= ff1;
        curr_state <= next_state;
    end
    always @(posedge scan_clk) begin
        case (curr_state)
            STATE_READ_C1_WAIT: begin
                det_key[0] <= ff2[0]; 
                det_key[3] <= ff2[1];
                det_key[6] <= ff2[2];
            end
            STATE_READ_C2_WAIT: begin
                det_key[1] <= ff2[0]; 
                det_key[4] <= ff2[1]; 
                det_key[7] <= ff2[2]; 
            end
            STATE_READ_C3_WAIT: begin
                det_key[2] <= ff2[0]; 
                det_key[5] <= ff2[1];
                det_key[8] <= ff2[2];
            end
        endcase
    end


    always @(*) begin
        next_state = curr_state;
        c1 = 1'b0; c2 = 1'b0; c3 = 1'b0;

        case(curr_state)
            STATE_SCAN_C1: begin
                c1 = 1'b1;
                next_state = STATE_READ_C1;
            end
            STATE_READ_C1: begin
                c1 = 1'b1;
                next_state = STATE_READ_C1_WAIT;
            end
            STATE_READ_C1_WAIT: begin
                c1 = 1'b1; 
                next_state = STATE_SCAN_C2; 
            end

            STATE_SCAN_C2: begin
                c2 = 1'b1; 
                next_state = STATE_READ_C2;
            end
            STATE_READ_C2: begin
                c2 = 1'b1; 
                next_state = STATE_READ_C2_WAIT;
            end
            STATE_READ_C2_WAIT: begin
                c2 = 1'b1; 
                next_state = STATE_SCAN_C3;
            end

            STATE_SCAN_C3: begin
                c3 = 1'b1; 
                next_state = STATE_READ_C3;
            end
            STATE_READ_C3: begin
                c3 = 1'b1;
                next_state = STATE_READ_C3_WAIT;
            end
            STATE_READ_C3_WAIT: begin
                c3 = 1'b1;
                next_state = STATE_SCAN_C1;
            end

            default: next_state = STATE_SCAN_C1;
        endcase
    end

always @(*) begin
        case (det_key)

            9'b000000001: begin 
                key= 5'd1;
            end
            9'b000000010: begin 
                key= 5'd2;
            end
            9'b000000100: begin 
                key= 5'd3; 
            end

            9'b000001000: begin 
                key= 5'd4;
            end
            9'b000010000: begin 
                key= 5'd5;
            end
            9'b000100000: begin 
                key= 5'd6; 
            end

            9'b001000000: begin 
                key= 5'd7; 
            end
            9'b010000000: begin 
                key= 5'd8; 
            end
            9'b100000000: begin 
                key= 5'd9; 
            end

            default: begin 
                key= 5'd0;
            end
        endcase
    end

endmodule