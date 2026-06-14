/* Ref: mmicko FPGA101 workshop tutorials - https://github.com/mmicko/fpga101-workshop/blob/master/tutorials/04-Audio/audio.v */

module audio(
    input clk,
    input [4:0] key1,
    output reg audio_l,audio_r

    );

reg [4:0] key;
always @(*) begin
    key <= 5'd1;
end
    parameter clkfreq=12000000; // 12MHz

reg [15:0] freq_r ;
reg [15:0] freq_c ;
wire key_pressed = (key >= 5'd1 && key <= 5'd16);
wire [31:0] phase_inc_r;
wire [31:0] phase_inc_c;
assign phase_inc_r = freq_r * 358;
assign phase_inc_c = freq_c * 358;

always @(*) begin
    case (key)
        5'd1: freq_r = 697;
        5'd2: freq_r = 540;
        5'd3: freq_r = 640;
        5'd4: freq_r = 740;

        default: freq_r = 0;
    endcase
end

always @(*) begin
    case (key)
        5'd1: freq_c = 1209;
        5'd2: freq_c = 6000;
        5'd3: freq_c = 7000;
        5'd4: freq_c = 8000;

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
// Clear or freeze the counter when no keys are pressed to avoid idle leaking noise
always @(posedge clk) begin
    if (key_pressed) begin
        counter_r <= counter_r + phase_inc_r;
        counter_c <= counter_c + phase_inc_c;
    end else begin
        counter_r <= 32'd0; // Completely flattens the DDS wave table index when idle
        counter_c <= 32'd0; // Completely flattens the DDS wave table index when idle
    end
end

wire [15:0] sample_r= sine_out_r + 16'd32768;
wire [15:0] sample_c= sine_out_c + 16'd32768;
wire [16:0] mixer= sample_r + sample_c;


reg [17:0] acc = 0; // 17 bits to prevent overflow when adding two 16-bit samples together
always @(posedge clk) begin
    if (key_pressed) begin
        // Only run the sigma-delta modulator when a key is active
acc <= {1'b0, acc[16:0]} + mixer;
    end else begin
        // Completely freeze the accumulator when idle
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
