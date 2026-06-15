module top_module(
    input clk,
    output audio_l,audio_r,
        input r1,r2,
        input r3,r4,
        output c1,c2,
        output c3,
        output c4,
    //         output reg led_blue_n,
    // output reg led_amber_n,
    // output reg led_rgb_green_n
    );

wire [4:0] key;
wire audio_l,audio_r;

audio audio_inst(
    .clk(clk),
    .key(key),  
    .audio_l(audio_l),
    .audio_r(audio_r)
);
buttons button_inst5(
    .clk(clk),
    .r1(r1),
    .r2(r2),
    .r3(r3),
    .c1(c1),
    .c2(c2),
    .c3(c3),
    .key(key),
    // .led_blue_n(led_blue_n),
    // .led_amber_n(led_amber_n),
    // .led_rgb_green_n(led_rgb_green_n)
    );
// button_test button_inst(
//     .clk(clk),
//     .r1(r1),
//     .r2(r2),
//     .r3(r3),
//     .c1(c1),
//     .c2(c2),
//     .c3(c3),
//     .key(key)
// );

// button_test1 button_inst1(
//     .clk(clk),
//     .r3(r3),
//     .c3(c3),
//     .key(key)
// );

// button_test3 button_inst3(
//     .clk(clk),
//     .r1(r1),
//     .r2(r2),
//     // .r3(r3),
//     .c1(c1),
//     .c2(c2),
//     // .c3(c3),
//     .key(key)
// );





// button_test4 button_inst4(
//     .clk(clk),
//     .r1(r1),
//     .r2(r2),
//     .r3(r3),
//     .r4(r4),
//     .c1(c1),
//     .c2(c2),
//     .c3(c3),
//     .c4(c4),
//     .key(key)
// );

    endmodule

