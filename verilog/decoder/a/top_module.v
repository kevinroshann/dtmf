module top_module(
    input  wire clk,      // 12 MHz
    input  wire sd,

    output reg  sck = 0,  // 1.5 MHz
    output reg  ws  = 0,  // 23.4375 kHz
    output reg led_amber_n,
    output reg led_blue_n

);

wire [23:0] data;
uart_send us(

	clk,
	rx,
	tx,
	data 


);
inmp441 inm(
    clk,      // 12 MHz
    sd,
    sck ,
    ws, 
    data,
    led_amber_n,
    led_blue_n

);


endmodule   