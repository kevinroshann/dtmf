module button_test (
        input clk,
        input r1,r2,
        input r3,
        output reg c1,c2,
        output reg c3,
        output reg [4:0] key


);





reg [1:0] state = 0;
always @(posedge clk) begin
    if (state >= 2) 
        state <= 0;
    else 
        state <= state + 1;


end
always @(posedge clk) begin
    case(state)
        0: begin
            c1 <= 1; c2 <= 0; c3 <= 0;
            if(r1) key <= 1;
            else if(r2) key <= 2;
            else if(r3) key <= 3;
            else key <= 0;
        end

        1: begin
            c1 <= 0; c2 <= 1; c3 <= 0;
            if(r1) key <= 4;
            else if(r2) key <= 5;
            else if(r3) key <= 6;
                else key <= 0;
        end

        2: begin
            c1 <= 0; c2 <= 0; c3 <= 1;
            if(r1) key <= 7;
            else if(r2) key <= 8;
            else if(r3) key <= 9;
            else key <= 0;
        end
        default: begin
            c1 <= 0; c2 <= 0; c3 <= 0;
            key <= 0;
        end
    endcase
end


endmodule

