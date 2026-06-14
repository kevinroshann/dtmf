module button_test1 (
        input clk,
        input r3,
        output reg c3,
        output reg [4:0] key,


);
assign c3=1'b1;

always @(*) begin
    if(r3) key <= 1;
    else key <= 0;
end
endmodule
