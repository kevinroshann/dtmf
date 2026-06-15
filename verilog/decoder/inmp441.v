module inmp441(
    input  wire clk,     // 12 MHz
    input  wire sd,
    output reg  sck = 0,
    output reg  ws  = 0
);

reg div2 = 0;
reg [4:0] bit_counter = 0;

always @(posedge clk) begin
    div2 <= ~div2;

    if(div2) begin
        sck <= ~sck;

        if(!sck) begin
            if(&bit_counter) begin
                bit_counter <= 0;
                ws <= ~ws;
            end
            else begin
                bit_counter <= bit_counter + 1;
            end
        end
    end
end

endmodule