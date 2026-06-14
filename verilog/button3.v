module button_test3 (
        input clk,
        input r1,r2,
        // input r3,
        output reg c1,c2,
        output reg c3,
        output reg [4:0] key


);





reg state = 0;
always @(posedge clk) begin
    state <= ~state;
end
always @(posedge clk) begin
    case(state)
        0: begin
            c1 <= 1; c2 <= 0; c3 <= 0;
            if(r1) key <= 1;
            if(r2) key <= 2;
        //     else if(r3) key <= 3;
            if(!r1 && !r2) key <= 0;
        end

        1: begin
            c1 <= 0; c2 <= 1; c3 <= 0;
            if(r1) key <= 3;
            if(r2) key <= 4;
        //     else if(r3) key <= 6;
            if(!r1 && !r2) key <= 0;
        end

        default: begin
            c1 <= 0; c2 <= 0; c3 <= 0;
        //     key <= 0;
        end
    endcase
end


endmodule






