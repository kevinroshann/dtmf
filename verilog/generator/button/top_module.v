`timescale 1ns / 1ps

module matrix_3x3_led (
    input clk,
    // Matrix Inputs (Rows)
    input r1, r2, r3,
    // Matrix Outputs (Columns)
    output reg c1, c2, c3,
    // Active-Low LED Outputs
    output reg led_blue_n,
    output reg led_amber_n,
    output reg led_rgb_green_n
);

    // 1. Clock Divider for Scanning and Blinking
    reg [22:0] clk_div = 0;
    always @(posedge clk) begin
        clk_div <= clk_div + 1;
    end
    
    wire scan_clk  = clk_div[15]; // Fast enough for scanning (~183 Hz at 12MHz)
    wire blink_clk = clk_div[22]; // Slow enough to visibly flash/blink (~1.4 Hz)

    // Combine active rows into a 3-bit vector
    wire [2:0] rows = {r3, r2, r1};

    // 2. Dual-Stage Synchronizer for Row Inputs
    reg [2:0] rows_sync_1;
    reg [2:0] rows_sync_2;
    always @(posedge scan_clk) begin
        rows_sync_1 <= rows;
        rows_sync_2 <= rows_sync_1;
    end

    // FSM States for 3 Columns
    parameter STATE_SCAN_C1 = 3'b000, STATE_READ_C1 = 3'b001;
    parameter STATE_SCAN_C2 = 3'b010, STATE_READ_C2 = 3'b011;
    parameter STATE_SCAN_C3 = 3'b100, STATE_READ_C3 = 3'b101;

    reg [2:0] current_state = STATE_SCAN_C1;
    reg [2:0] next_state;

    // 9-bit Key Register tracking the matrix grid
    reg [8:0] detected_keys = 9'b000_000_000;

    // FSM State Register
    always @(posedge scan_clk) begin
        current_state <= next_state;
    end

    // FSM State & Output Drive Logic
    always @(*) begin
        next_state = current_state;
        c1 = 1'b0; c2 = 1'b0; c3 = 1'b0;

        case (current_state)
            STATE_SCAN_C1: begin c1 = 1'b1; next_state = STATE_READ_C1; end
            STATE_READ_C1: begin c1 = 1'b1; next_state = STATE_SCAN_C2; end
            
            STATE_SCAN_C2: begin c2 = 1'b1; next_state = STATE_READ_C2; end
            STATE_READ_C2: begin c2 = 1'b1; next_state = STATE_SCAN_C3; end
            
            STATE_SCAN_C3: begin c3 = 1'b1; next_state = STATE_READ_C3; end
            STATE_READ_C3: begin c3 = 1'b1; next_state = STATE_SCAN_C1; end
            
            default: next_state = STATE_SCAN_C1;
        endcase
    end

    // 3. Key Capture (Saves row data)
    always @(posedge scan_clk) begin
        case (current_state)
            STATE_READ_C1: begin
                detected_keys[0] <= rows_sync_2[0]; // Button 1
                detected_keys[3] <= rows_sync_2[1]; // Button 4
                detected_keys[6] <= rows_sync_2[2]; // Button 7
            end
            STATE_READ_C2: begin
                detected_keys[1] <= rows_sync_2[0]; // Button 2
                detected_keys[4] <= rows_sync_2[1]; // Button 5
                detected_keys[7] <= rows_sync_2[2]; // Button 8
            end
            STATE_READ_C3: begin
                detected_keys[2] <= rows_sync_2[0]; // Button 3
                detected_keys[5] <= rows_sync_2[1]; // Button 6
                detected_keys[8] <= rows_sync_2[2]; // Button 9
            end
        endcase
    end

    // 4. Unique LED Blinking & Display Combinations
    // Remember: Active Low (1'b0 = ON, 1'b1 = OFF)
    always @(*) begin
        case (detected_keys)
            // --- ROW 1 BUTTONS ---
            9'b000_000_001: begin // Button 1: Solid Blue
                led_blue_n      = 1'b0; 
                led_amber_n     = 1'b1; 
                led_rgb_green_n = 1'b1; 
            end
            9'b000_000_010: begin // Button 2: Solid Amber
                led_blue_n      = 1'b1; 
                led_amber_n     = 1'b0; 
                led_rgb_green_n = 1'b1; 
            end
            9'b000_000_100: begin // Button 3: Solid Green
                led_blue_n      = 1'b1; 
                led_amber_n     = 1'b1; 
                led_rgb_green_n = 1'b0; 
            end

            // --- ROW 2 BUTTONS ---
            9'b000_001_000: begin // Button 4: Blinking Blue
                led_blue_n      = blink_clk; 
                led_amber_n     = 1'b1; 
                led_rgb_green_n = 1'b1; 
            end
            9'b000_010_000: begin // Button 5: Blinking Amber
                led_blue_n      = 1'b1; 
                led_amber_n     = blink_clk; 
                led_rgb_green_n = 1'b1; 
            end
            9'b000_100_000: begin // Button 6: Blinking Green
                led_blue_n      = 1'b1; 
                led_amber_n     = 1'b1; 
                led_rgb_green_n = blink_clk; 
            end

            // --- ROW 3 BUTTONS ---
            9'b001_000_000: begin // Button 7: Blue + Amber Alternating Cop Car style
                led_blue_n      = blink_clk; 
                led_amber_n     = ~blink_clk; 
                led_rgb_green_n = 1'b1; 
            end
            9'b010_000_000: begin // Button 8: Amber + Green Alternating
                led_blue_n      = 1'b1; 
                led_amber_n     = blink_clk; 
                led_rgb_green_n = ~blink_clk; 
            end
            9'b100_000_000: begin // Button 9: All 3 LEDs flashing together
                led_blue_n      = blink_clk; 
                led_amber_n     = blink_clk; 
                led_rgb_green_n = blink_clk; 
            end

            // --- DEFAULT / NO PRESS ---
            default: begin // Everything completely OFF
                led_blue_n      = 1'b1;  
                led_amber_n     = 1'b1; 
                led_rgb_green_n = 1'b1; 
            end
        endcase
    end

endmodule