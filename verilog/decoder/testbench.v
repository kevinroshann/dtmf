// `timescale 1ps/1ps

// module tb_goertzel;

// reg clk;
// reg reset;
// initial begin
//     clk = 0;
//     reset=1;
//     #100
//     reset=0;
//     forever #41667 clk = ~clk;
// end

// wire signed [15:0] maxcoeff;
//     wire signed [63:0] power ;
//     wire signed [63:0] power_tb ;
//     wire signed [63:0] max_power ;
//     wire signed [15:0] COEFF_tb;
// goertzel dut(
// .clk(clk),
//     // .led_amber_n(),
//     // .led_blue_n()
// .reset(reset),
// .maxcoeff(maxcoeff),
// .power(power),
// .power_tb(power_tb),
// .COEFF_tb(COEFF_tb),
// .max_power(max_power)

// );

// integer F;
// initial begin
//     $dumpfile("wave.vcd");
//     $dumpvars(0, tb_goertzel);
// end
// initial begin
//    #90000000;  // 1 us with 1ps timescale
// case(maxcoeff) 
//     16'sd28106 : F = 697;
//     16'sd27018 : F = 770; 
//     16'sd25330 : F = 852;
//     16'sd24126 : F = 941; 
//     16'sd19478 : F = 1209; 
//     16'sd16846 : F = 1336; 
//     16'sd12490 : F = 1477; 
//     16'sd9220  : F = 1633;
//     default    : F = 0; // Highly recommended to avoid uninitialized 'x' values
// endcase
//     $display("final value is %0d %0d",F,maxcoeff);
//     $finish;
    
// end


// initial begin
//     $monitor("Time=%0t power=%0d max_power=%0d coeff=%0d max_coeff=%0d", $time, power_tb,max_power,COEFF_tb, maxcoeff);
// end
// endmodule
`timescale 1ns/1ps

module tb_goertzel;

    reg clk;
    reg reset;
    
    wire signed [15:0] maxcoeff;
    wire signed [63:0] power;
    wire signed [63:0] power_tb;
    wire signed [63:0] max_power;
    wire signed [15:0] COEFF_tb;
    integer F;

    // Instantiate Device Under Test
    goertzel dut (
        .clk(clk),
        .reset(reset),
        .maxcoeff(maxcoeff),
        .power(power),
        .power_tb(power_tb),
        .COEFF_tb(COEFF_tb),
        .max_power(max_power)
    );

    // 12 MHz Clock Generator (Period = 83.333 ns -> Half-Period = 41.667 ns)
    always #41.667 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_goertzel);
        
        // Initialize at time 0
        clk = 0;
        reset = 1;
        
        // Hold reset stable for 3 full clock cycles (~250 ns)
        #250; 
        reset = 0;
        
        // Monitor output changes
        $monitor("Time=%0t ns | Bin Coeff=%0d | Power=%0d | Max Power=%0d", $time, COEFF_tb, power_tb, max_power);
        
        // --- THE FIX ---
        // Your Goertzel sweeps 8 frequency bins sequentially.
        // Each bin processes 128 samples. Total samples = 8 * 128 = 1024 samples.
        // 1024 samples * 83.333 ns per sample = 85,333 ns minimum execution time.
        // We will run the simulation for 100,000 ns to let it fully complete and output the final result.
        #85400; 

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

        $display("\n=== DETECTION RESULT ===");
        $display("Detected Frequency: %0d Hz (Coeff: %0d)", F, maxcoeff);
        $display("=========================");
        $finish;
    end

endmodule