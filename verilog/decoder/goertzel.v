module goertzel
  (

    input wire clk,reset,
    output reg signed [15:0] maxcoeff,
    output wire signed [15:0] COEFF_tb,
    output reg signed [63:0] power_tb,
    output reg signed [63:0] max_power,
    output wire signed [63:0] power



  );

  reg [6:0] addr = 7'd0;
  wire signed [15:0] sample;

  localparam integer Fs = 8000;
  localparam integer N  = 128;

  reg signed [15:0] COEFF [0:7];




  initial
  begin
    COEFF[0] = 16'sd28106; // 697 Hz
    COEFF[1] = 16'sd27018; // 770 Hz
    COEFF[2] = 16'sd25330; // 852 Hz
    COEFF[3] = 16'sd24126; // 941 Hz
    COEFF[4] = 16'sd19478; // 1209 Hz
    COEFF[5] = 16'sd16846; // 1336 Hz
    COEFF[6] = 16'sd12490; // 1477 Hz
    COEFF[7] = 16'sd9220;  // 1633 Hz
  end



  reg [2:0] i = 3'd0;
  reg signed [31:0] s1 = 0;
  reg signed [31:0] s2 = 0;

  wire signed [31:0] s_next;
  wire signed [47:0] s1_prod;
  assign s1_prod = COEFF[i] * s1;
  reg [6:0] count = 0;

  assign COEFF_tb=COEFF[i];
  assign s_next = {{16{sample[15]}}, sample} + (s1_prod >>> 14) - s2;

  assign power =
         (s_next * s_next)
         + (s1 * s1)
         - (((COEFF[i] * s_next * s1) >>> 14));

  always @(posedge clk)
  begin

    if(reset)
    begin
      addr      <= 7'd0;
      count     <= 7'd0;
      i         <= 3'd0;
      s1        <= 32'sd0;
      s2        <= 32'sd0;
      max_power <= 64'sd0;
      maxcoeff  <= 16'sd0;
      power_tb  <= 64'sd0;

    end
    else
    begin


      addr <= addr + 1'b1;

      if(count == 7'd127)
      begin
        power_tb<=power;

        if(power>max_power)
        begin
          max_power<=power;
          maxcoeff<=COEFF[i];

        end


        count <= 7'd0;
        s1    <= 32'sd0;
        s2    <= 32'sd0;
        addr  <= 7'd0;

        if (i == 3'd7)
        begin
          i <= 3'd0;
        end
        else
        begin
          i <= i + 1'b1;
        end
      end
      else
      begin

        s2 <= s1;
        s1 <= s_next;

        count <= count + 1'b1;

      end
    end
  end

  sinwave sw(
            .addr(addr),
            .sample(sample)
          );

endmodule

