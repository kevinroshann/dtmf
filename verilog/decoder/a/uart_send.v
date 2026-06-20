// Reference : https://github.com/cyrozap/iCEstick-UART-Demo/

`include "osdvu/uart.v"

module uart_send
(
	input wire clk,
	input rx,
	output tx,
	input reg [23:0] data 
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

reg [32:0] counter = 32'b0;
reg [3:0] addr = 4'b0000;



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
	counter <= counter + 32'b1;
end

always @(posedge clk) begin
	if (&counter) 
	begin
		tx_byte <= rom_data[addr];
		addr <= (addr == 4'd25 ? 4'b0 : addr + 4'b1);
		transmit <= 1'b1;
	end 
	else 
	begin
		transmit <= 1'b0;
	end
end

endmodule
