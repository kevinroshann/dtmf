// Reference : https://github.com/cyrozap/iCEstick-UART-Demo/



module uart_send
(
    input wire clk,
    input wire rx,
    output wire tx,
    input wire [23:0] data,  // Live 24-bit audio data from microphone
    input wire data_valid    // Strobe flag indicating a new sample is ready
);

/* LEDs are wired active low */
wire reset = 0;
reg transmit;
reg [7:0] tx_byte;
wire received;
wire [7:0] rx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

// Baud rate changed to 115200 for fast ASCII serial streaming
uart #(
    .baud_rate(115200),               // 115200 baud
    .sys_clk_freq(12000000)           // 12 MHz master clock frequency
)
uart0(
    .clk(clk),                        // The master clock for this module
    .rst(reset),                      // Synchronous reset
    .rx(rx),                          // Incoming serial line
    .tx(tx),                          // Outgoing serial line
    .transmit(transmit),              // Signal to transmit
    .tx_byte(tx_byte),                // Byte to transmit
    .received(received),              // Indicated that a byte has been received
    .rx_byte(rx_byte),                // Byte received
    .is_receiving(is_receiving),      // Low when receive line is idle
    .is_transmitting(is_transmitting),// Low when transmit line is idle
    .recv_error(recv_error)           // Indicates error in receiving packet.
);

// Function to convert a 4-bit binary nibble to its ASCII hex character
function [7:0] to_hex(input [3:0] nibble);
    begin
        if (nibble < 4'd10)
            to_hex = 8'd48 + {4'b0, nibble}; // '0' to '9' (ASCII 48 - 57)
        else
            to_hex = 8'd55 + {4'b0, nibble}; // 'A' to 'F' (ASCII 65 - 70)
    end
endfunction

// State Machine Variables to output HEX characters sequentially
reg [3:0] state = 4'd0;
reg [23:0] sample_hold = 24'b0;
reg tx_busy = 1'b0;

always @(posedge clk) begin
    transmit <= 1'b0; // Default transmit strobe to low

    case (state)
        4'd0: begin
            // Wait for a fresh audio sample to arrive from the microphone
            if (data_valid) begin
                sample_hold <= data;  // Latch the sample
                state       <= 4'd1;  // Proceed to send characters
            end
        end

        // States 1 to 10 transmit: 6 Hex characters + '::' + '\r' + '\n'
        4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9, 4'd10: begin
            if (!tx_busy) begin
                transmit <= 1'b1;
                tx_busy  <= 1'b1;
                
                case (state)
                    4'd1:  tx_byte <= to_hex(sample_hold[23:20]); // Hex Digit 5 (MSB)
                    4'd2:  tx_byte <= to_hex(sample_hold[19:16]); // Hex Digit 4
                    4'd3:  tx_byte <= to_hex(sample_hold[15:12]); // Hex Digit 3
                    4'd4:  tx_byte <= to_hex(sample_hold[11:8]);  // Hex Digit 2
                    4'd5:  tx_byte <= to_hex(sample_hold[7:4]);   // Hex Digit 1
                    4'd6:  tx_byte <= to_hex(sample_hold[3:0]);   // Hex Digit 0 (LSB)
                    4'd7:  tx_byte <= 8'h3A;                      // ':'
                    4'd8:  tx_byte <= 8'h3A;                      // ':'
                    4'd9:  tx_byte <= 8'h0D;                      // Carriage Return '\r'
                    4'd10: tx_byte <= 8'h0A;                      // Line Feed '\n'
                endcase
            end else begin
                // Wait for the UART module to finish transmitting the active character
                if (!is_transmitting && !transmit) begin
                    tx_busy <= 1'b0;
                    state   <= state + 1'b1;
                end
            end
        end

        4'd11: begin
            // Wait until the final '\n' byte is fully flushed out before returning to Idle
            if (!is_transmitting && !transmit) begin
                state <= 4'd0;
            end
        end

        default: state <= 4'd0;
    endcase
end

endmodule