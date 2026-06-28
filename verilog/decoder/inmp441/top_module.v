module top_module(
    input  wire clk,          // 12 MHz Master Clock
    input  wire sd,           // Microphone I2S Data pin
    input  wire rx,           // UART RX Pin (not used but mapped)
    
    output wire sck,          // I2S Serial Clock pin (1.5 MHz)
    output wire ws,           // I2S Word Select / LRCLK pin
    output wire tx,           // UART TX Pin (115200 Baud)
    
    output wire led_amber_n,  // Level Indicator LEDs
    output wire led_blue_n
);

    // Internal interconnect wires to bridge mic data to the UART module
    wire [23:0] audio_data;
    wire        audio_valid;

    // Instantiate INMP441 module
    inmp441 inm(
        .clk(clk),
        .sd(sd),
        .sck(sck),
        .ws(ws),
        .sample(audio_data),
        .sample_valid(audio_valid),
        .led_amber_n(led_amber_n),
        .led_blue_n(led_blue_n)
    );

    // Instantiate UART transmitter with hex display conversion
    uart_send us(
        .clk(clk),
        .rx(rx),
        .tx(tx),
        .data(audio_data),
        .data_valid(audio_valid)
    );

endmodule