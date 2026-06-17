module inmp441(
    input  wire clk,      // 12 MHz
    input  wire sd,

    output reg  sck = 0,  // 1.5 MHz
    output reg  ws  = 0,  // 23.4375 kHz

    
    output reg led_amber_n,
    output reg led_blue_n
);

reg [1:0] sck_cnt = 0;
reg [5:0] bit_cnt = 0;
reg [23:0] data = 0;
always @(posedge clk) begin

    led_amber_n <= 0;

    if (sck_cnt == 3) begin

        sck_cnt <= 0;
        sck <= ~sck;

        // Do receiver logic once per SCK toggle
        if (sck == 0) begin

            // Left slot
            if (bit_cnt == 31)
                ws <= 1;

            // End of frame
            if (bit_cnt == 63) begin
                ws <= 0;
                bit_cnt <= 0;
                led_amber_n <= 1;
            end
            else begin
                bit_cnt <= bit_cnt + 1;
            end

            // Capture 24 audio bits
            if (bit_cnt >= 1 && bit_cnt <= 24)
                data <= {data[22:0], sd};
                led_blue_n<=sd;

        end

    end
    else begin
        sck_cnt <= sck_cnt + 1'b1;
    end

end

endmodule