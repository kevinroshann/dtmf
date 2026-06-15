// Reference : https://github.com/cyrozap/iCEstick-UART-Demo/

`include "osdvu/uart.v"

module uart_hello_world
(
	input wire clk,
	input wire enc_sw,	
	output reg led_blue_n,
	output reg led_amber_n,
	output wire led_rgb_red_n,
	output wire led_rgb_blue_n,
	output wire led_rgb_green_n,
	input rx,
	output tx
);

/*  LEDs are wired active low */

wire reset = 0;
reg transmit;
reg [7:0] tx_byte;
wire received;
wire [7:0] rx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;

reg [20:0] counter = 21'b0;
reg [3:0] addr = 4'b0000;

assign led_rgb_red_n   = ~addr[3];
assign led_rgb_green_n = ~addr[2];
assign led_rgb_blue_n  = ~addr[1];

assign led_amber_n = ~is_receiving;
assign led_blue_n  = ~is_transmitting;

wire [7:0] rom_data [13:0];

assign rom_data[0] = "H";
assign rom_data[1] = "e";
assign rom_data[2] = "l";
assign rom_data[3] = "l";
assign rom_data[4] = "o";
assign rom_data[5] = " ";
assign rom_data[6] = "W";
assign rom_data[7] = "o";
assign rom_data[8] = "r";
assign rom_data[9] = "l";
assign rom_data[10] = "d";
assign rom_data[11] = "!";
assign rom_data[12] = "\n";
assign rom_data[13] = "\r";

uart #(
	.baud_rate(9600),                 // The baud rate in kilobits/s
	.sys_clk_freq(12000000)           // The master clock frequency
)
uart0(
	.clk(clk),                    // The master clock for this module
	.rst(reset),                      // Synchronous reset
	.rx(rx),                // Incoming serial line
	.tx(tx),                // Outgoing serial line
	.transmit(transmit),              // Signal to transmit
	.tx_byte(tx_byte),                // Byte to transmit
	.received(received),              // Indicated that a byte has been received
	.rx_byte(rx_byte),                // Byte received
	.is_receiving(is_receiving),      // Low when receive line is idle
	.is_transmitting(is_transmitting),// Low when transmit line is idle
	.recv_error(recv_error)           // Indicates error in receiving packet.
);

always @(posedge clk)
begin
	counter <= counter + 21'b1;
end

always @(posedge clk) begin
	if (&counter) 
	begin
		tx_byte <= rom_data[addr];
		addr <= (addr == 4'd13 ? 4'b0 : addr + 4'b1);
		transmit <= 1'b1;
	end 
	else 
	begin
		transmit <= 1'b0;
	end
end

endmodule
