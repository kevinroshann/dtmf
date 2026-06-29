`timescale 1ns/1ps

module tb_goertzel;

reg clk;
reg reset;



reg [7:0] key [0:3][0:3];
integer j,k;

initial begin
    key[0][0] = "1"; key[0][1] = "2"; key[0][2] = "3"; key[0][3] = "A";
    key[1][0] = "4"; key[1][1] = "5"; key[1][2] = "6"; key[1][3] = "B";
    key[2][0] = "7"; key[2][1] = "8"; key[2][2] = "9"; key[2][3] = "C";
    key[3][0] = "*"; key[3][1] = "0"; key[3][2] = "#"; key[3][3] = "D";
end

wire signed [15:0] maxcoeff;
    wire signed [63:0] power ;
    wire signed [63:0] power_tb ;
    wire signed [63:0] max_power ;
    wire signed [15:0] COEFF_tb;


reg reset1;


wire signed [15:0] maxcoeff1;
    wire signed [63:0] power1 ;
    wire signed [63:0] power_tb1 ;
    wire signed [63:0] max_power1 ;
    wire signed [15:0] COEFF_tb1;

goertzel dut(
.clk(clk),
.reset(reset),
.maxcoeff(maxcoeff),
.power(power),
.power_tb(power_tb),
.COEFF_tb(COEFF_tb),
.max_power(max_power)

);

goertzel1 dut1(
.clk(clk),
.reset(reset1),
.maxcoeff(maxcoeff1),
.power(power1),
.power_tb(power_tb1),
.COEFF_tb(COEFF_tb1),
.max_power(max_power1)

);



always #41.667 clk = ~clk;

integer F;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_goertzel);
        clk = 0;
    reset=1;
    #100
    reset=0;
          $monitor("time=%0t , i=%0d , coeff=%0d , power=%0d , peakpower=%0d", 
                $time, dut.i, COEFF_tb, power_tb, max_power);
   #50000;  
case(maxcoeff) 
    16'sd28106 :begin
        F = 697;
        j=0;
    end
    16'sd27018 : begin
        F = 770; 
        j=1;
    end
    16'sd25330 : begin
        F = 852;
        j=2;
    end
    16'sd24126 : 
    begin
    F = 941; 
    j=3;
    end
    // 16'sd19478 : F = 1209; 
    // 16'sd16846 : F = 1336; 
    // 16'sd12490 : F = 1477; 
    // 16'sd9220  : F = 1633;
    default    : F = 0;
endcase

        $display("det freq: %0d Hz", F);
        $display("power peak: %0d", max_power);
        


           clk = 0;
    reset1=1;
    #100
    reset1=0;
          $monitor("time=%0t , i=%0d , coeff=%0d , power=%0d , peakpower=%0d", 
                $time, dut1.i, COEFF_tb1, power_tb1, max_power1);
   #50000;  
case(maxcoeff1) 
    // 16'sd28106 : F = 697;
    // 16'sd27018 : F = 770; 
    // 16'sd25330 : F = 852;
    // 16'sd24126 : F = 941; 
    16'sd19478 : begin 
        F = 1209;
        k=0;
    end 

    16'sd16846 : begin
        F = 1336; 
        k=1;
    end
    16'sd12490 :begin
        F = 1477;
        k=2;
    end 
    16'sd9220  :begin
      
  F = 1633;
k=3;
end 
    default    : F = 0;
endcase

        $display("det freq: %0d Hz", F);
        $display("power peak: %0d", max_power1);

$display("key is: %0s", key[j][k]);






        $finish;
    
end





endmodule
