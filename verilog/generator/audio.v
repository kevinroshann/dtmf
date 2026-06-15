module audio(
    input clk,
    input [4:0] key,
    output reg audio_l,audio_r

    );

// reg [4:0] key;
// always @(*) begin
//     key <= 5'd1;
// end


parameter clkfreq=12000000; 

reg [15:0] freq_r ;
reg [15:0] freq_c ;
wire key_pressed = (key >= 5'd1 && key <= 5'd16);
wire [31:0] phase_inc_r;
wire [31:0] phase_inc_c;
assign phase_inc_r = freq_r * 358; //freq*2**32/clock frequency
assign phase_inc_c = freq_c * 358;

always @(*) begin
    case (key)
5'd1,5'd2,5'd3 : freq_r = 697;
5'd4,5'd5,5'd6 : freq_r = 770;
5'd7,5'd8,5'd9 : freq_r = 852;

        default: freq_r = 0;
    endcase
end

always @(*) begin
    case (key)
5'd1,5'd4,5'd7 : freq_c = 1209;
5'd2,5'd5,5'd8 : freq_c = 1336;
5'd3,5'd6,5'd9 : freq_c = 1477;

        default: freq_c = 0;
    endcase
end


reg  signed [15:0] sine_out_r;
reg [31:0] counter_r;
wire [7:0] addr_r;

reg  signed [15:0] sine_out_c;
reg [31:0] counter_c;
wire [7:0] addr_c;

assign addr_r = counter_r[31:24];
assign addr_c = counter_c[31:24];
always @(posedge clk) begin
    if (key_pressed) begin
        counter_r <= counter_r + phase_inc_r;
        counter_c <= counter_c + phase_inc_c;
    end else begin
        counter_r <= 32'd0; 
        counter_c <= 32'd0; 
    end
end

wire [15:0] sample_r= sine_out_r + 16'd32768;
wire [15:0] sample_c= sine_out_c + 16'd32768;
wire [16:0] mixer= sample_r + sample_c;


reg [17:0] acc = 0;
always @(posedge clk) begin
    if (key_pressed) begin
      
acc <= {1'b0, acc[16:0]} + mixer;
    end else begin

        acc <= 18'd0;
    end
end
always @(posedge clk) begin
    if(key_pressed) begin
    audio_l <= acc[17];
    audio_r <= acc[17];
    end else begin
  audio_l <= 1'b0;
  audio_r <= 1'b0;
    end

end

sinout sinout_r (
    .addr(addr_r),
    .sine_out(sine_out_r)
);
sinout sinout_c (
    .addr(addr_c),
    .sine_out(sine_out_c)
);


endmodule
