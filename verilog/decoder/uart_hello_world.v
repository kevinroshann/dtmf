// Reference : https://github.com/cyrozap/iCEstick-UART-Demo/

`include "osdvu/uart.v"

module uart_hello_world
(
	input wire clk,

	input wire signed [15:0] maxcoeff,
	input wire send,

	output tx
);


integer F;

always @(*) begin
  
 case(maxcoeff) 
            16'sd28106 : F = 697;
            16'sd27018 : F = 770; 
            16'sd25330 : F = 852;
            16'sd24126 : F = 941; 
            16'sd19478 : F = 1209;
            16'sd16846 : F = 1336; 
            16'sd12490 : F = 1477; 
            16'sd9220  : F = 1633;
            default    : F = 0;
        endcase


end	

       

/*  LEDs are wired active low */

wire reset = 0;
reg transmit;
reg [7:0] tx_byte;
wire received;
wire [7:0] rx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;


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


always @(posedge clk) begin
	if (send) 
	begin
		tx_byte <= F;
		transmit <= 1'b1;
	end 
	else 
	begin
		transmit <= 1'b0;
	end
end

endmodule
