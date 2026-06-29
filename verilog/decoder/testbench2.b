
// `timescale 1ns/1ps

// module tb_goertzel;

//     reg clk;
//     reg reset;
    
//     wire signed [15:0] maxcoeff;
//     wire signed [63:0] power;
//     wire signed [63:0] power_tb;
//     wire signed [63:0] max_power;
//     wire signed [15:0] COEFF_tb;
//     integer F;

//     // Instantiate Device Under Test
//     goertzel dut (
//         .clk(clk),
//         .reset(reset),
//         .maxcoeff(maxcoeff),
//         .power(power),
//         .power_tb(power_tb),
//         .COEFF_tb(COEFF_tb),
//         .max_power(max_power)
//     );

//     // 12 MHz Clock Generator (Period = 83.333 ns -> Half-Period = 41.667 ns)
//     always #41.667 clk = ~clk;

//     initial begin
//         $dumpfile("wave.vcd");
//         $dumpvars(0, tb_goertzel);
        
//         // Initialize signals
//         clk = 0;
//         reset = 1;
        
//         // Hold reset for 3 full clock cycles
//         #250; 
//         reset = 0;
        
//         // Print progress monitor directly to the terminal
//         $monitor("Time=%0t ns | Bin Index=%0d | Coeff=%0d | Power=%0d | Peak Power Found=%0d", 
//                  $time, dut.i, COEFF_tb, power_tb, max_power);
        
//         // --- DYNAMIC TERMINATION ---
//         // Instead of hardcoding delays, we wait until the design finishes the 
//         // 8th frequency bin (index i = 7) and the 128th sample (count = 127).
//         @(posedge clk);
//         while (dut.i !== 3'd7 || dut.count !== 7'd127) begin
//             @(posedge clk);
//         end
        
//         // Wait 1 final clock cycle to allow the final comparison logic 
//         // to update the register outputs (maxcoeff, max_power)
//         @(posedge clk);

//         // Map the highest recorded coefficient to its corresponding frequency
//         case(maxcoeff) 
//             16'sd28106 : F = 697;
//             16'sd27018 : F = 770; 
//             16'sd25330 : F = 852;
//             16'sd24126 : F = 941; 
//             16'sd19478 : F = 1209;
//             16'sd16846 : F = 1336; 
//             16'sd12490 : F = 1477; 
//             16'sd9220  : F = 1633;
//             default    : F = 0;
//         endcase

//         $display("\n=================================");
//         $display("       DETECTION COMPLETE        ");
//         $display("=================================");
//         $display("Detected Frequency : %0d Hz", F);
//         $display("Winning Coefficient: %0d", maxcoeff);
//         $display("Peak Calculated Power: %0d", max_power);
//         $display("=================================\n");
        
//         $finish;
//     end

// endmodule