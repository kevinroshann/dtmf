module inmp441(
    input  wire clk,      // 12 MHz
    input  wire sd,       // INMP441 data

    output reg  sck = 0,  // 1.5 MHz
    output reg  ws  = 0,  // LRCLK

    output reg led_amber_n = 1,
    output reg led_blue_n  = 1
);

    // Clock generation
    reg [1:0] sck_cnt = 0;

    // I2S receive
    reg [5:0]  bit_cnt = 0;
    reg [23:0] shift_reg = 0;
    reg [23:0] sample = 0;
    reg        sample_valid = 0;

    // Absolute value for level detection
    wire [22:0] magnitude;

    assign magnitude =
        sample[23] ? (~sample[22:0] + 1'b1) : sample[22:0];

    always @(posedge clk) begin

        sample_valid <= 0;

        // Divide 12 MHz by 8 -> 1.5 MHz SCK
        if (sck_cnt == 3) begin
            sck_cnt <= 0;
            sck <= ~sck;

            // Receive on SCK rising edge
            if (sck == 0) begin

                // WS changes halfway through frame
                if (bit_cnt == 31)
                    ws <= 1;

                if (bit_cnt == 63) begin
                    ws <= 0;
                    bit_cnt <= 0;
                end
                else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end

                // Capture first 24 bits of left channel
                if (ws == 0) begin
                    if (bit_cnt >= 1 && bit_cnt <= 24) begin

                        shift_reg <= {shift_reg[22:0], sd};

                        if (bit_cnt == 24) begin
                            sample <= {shift_reg[22:0], sd};
                            sample_valid <= 1;
                        end
                    end
                end
            end
        end
        else begin
            sck_cnt <= sck_cnt + 1'b1;
        end

        // LED level indicator
        if (sample_valid) begin

            // Blue LED lights when sound level is high
            if (magnitude > 23'd100000)
                led_blue_n <= 0;
            else
                led_blue_n <= 1;

            // Amber LED lights when sound level is very high
            if (magnitude > 23'd500000)
                led_amber_n <= 0;
            else
                led_amber_n <= 1;
        end

    end

endmodule