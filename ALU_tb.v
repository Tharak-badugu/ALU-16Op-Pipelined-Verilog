`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.07.2026 14:15:17
// Design Name: 
// Module Name: ALU_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module alu_tb;

    parameter WIDTH = 8;

    reg              clk;
    reg              rst_n;
    reg  [WIDTH-1:0] tb_a;
    reg  [WIDTH-1:0] tb_b;
    reg  [3:0]       tb_opcode;

    wire [WIDTH-1:0] out_result;
    wire             out_zero;
    wire             out_carry;
    wire             out_overflow;
    wire             out_negative;

    // Hooking up my ALU module to test it
    alu_top #(.WIDTH(WIDTH)) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .io_a       (tb_a),
        .io_b       (tb_b),
        .io_opcode  (tb_opcode),
        .o_result   (out_result),
        .o_zero     (out_zero),
        .o_carry    (out_carry),
        .o_overflow (out_overflow),
        .o_negative (out_negative)
    );

    // Making a simple clock that flips every 10 ticks
    always #10 clk = ~clk;

    initial begin
        // Clearing out all inputs at startup
        clk       = 0;
        rst_n     = 0;
        tb_a      = 0;
        tb_b      = 0;
        tb_opcode = 0;

        // Waiting a bit, then letting go of the reset pin
        repeat(2) @(negedge clk);
        rst_n = 1;

        // Test 1: Simple addition (5 + 3 = 8)
        @(negedge clk);
        tb_opcode = 4'b0000; tb_a = 8'h05; tb_b = 8'h03;
        repeat(2) @(negedge clk); // Give the pipeline 2 cycles to show the answer

        // Test 2: Checking if carry and zero flags work (255 + 1 rolls over to 0)
        tb_opcode = 4'b0000; tb_a = 8'hFF; tb_b = 8'h01;
        repeat(2) @(negedge clk);

        // Test 3: Forcing a signed overflow error (127 + 1 turns negative)
        tb_opcode = 4'b0000; tb_a = 8'h7F; tb_b = 8'h01;
        repeat(2) @(negedge clk);

        // Test 4: Normal subtraction (10 - 4 = 6)
        tb_opcode = 4'b0001; tb_a = 8'h0A; tb_b = 8'h04;
        repeat(2) @(negedge clk);

        // Test 5: Subtraction overflow check (-128 - 1 should wrap to positive)
        tb_opcode = 4'b0001; tb_a = 8'h80; tb_b = 8'h01;
        repeat(2) @(negedge clk);

        // Test 6: Bitwise AND (matching bits should clear out to 00)
        tb_opcode = 4'b0010; tb_a = 8'hAA; tb_b = 8'h55;
        repeat(2) @(negedge clk);

        // Test 7: Bitwise OR (mixing inputs to turn all bits on)
        tb_opcode = 4'b0011; tb_a = 8'h55; tb_b = 8'hAA;
        repeat(2) @(negedge clk);

        // Test 8: Bitwise XOR
        tb_opcode = 4'b0100; tb_a = 8'hFF; tb_b = 8'hAA;
        repeat(2) @(negedge clk);

        // Test 9: Bitwise NOR
        tb_opcode = 4'b0101; tb_a = 8'h00; tb_b = 8'h00;
        repeat(2) @(negedge clk);

        // Test 10: Bitwise NAND
        tb_opcode = 4'b0110; tb_a = 8'hFF; tb_b = 8'hFF;
        repeat(2) @(negedge clk);

        // Test 11: Bitwise XNOR
        tb_opcode = 4'b0111; tb_a = 8'hFF; tb_b = 8'h00;
        repeat(2) @(negedge clk);

        // Test 12: Flipping all bits of A using NOT
        tb_opcode = 4'b1000; tb_a = 8'h55;
        repeat(2) @(negedge clk);

        // Test 13: Shifting left by 3 spaces
        tb_opcode = 4'b1001; tb_a = 8'h01; tb_b = 8'h03;
        repeat(2) @(negedge clk);

        // Test 14: Shifting left by the absolute max amount (7 slots)
        tb_opcode = 4'b1001; tb_a = 8'hFF; tb_b = 8'h07;
        repeat(2) @(negedge clk);

        // Test 15: Logical shift right (should fill empty spots with 0s)
        tb_opcode = 4'b1010; tb_a = 8'h80; tb_b = 8'h03;
        repeat(2) @(negedge clk);

        // Test 16: Arithmetic shift right with a negative number (must keep the 1s)
        tb_opcode = 4'b1011; tb_a = 8'hF0; tb_b = 8'h02;
        repeat(2) @(negedge clk);

        // Test 17: Arithmetic shift right with a positive number (must fill with 0s)
        tb_opcode = 4'b1011; tb_a = 8'h70; tb_b = 8'h02;
        repeat(2) @(negedge clk);

        // Test 18: Spin bits left (the front bit should loop around to the back)
        tb_opcode = 4'b1100; tb_a = 8'h80; tb_b = 8'h01;
        repeat(2) @(negedge clk);

        // Test 19: Testing spin left with zero shift (nothing should change)
        tb_opcode = 4'b1100; tb_a = 8'h85; tb_b = 8'h00;
        repeat(2) @(negedge clk);

        // Test 20: Spin bits right
        tb_opcode = 4'b1101; tb_a = 8'h01; tb_b = 8'h01;
        repeat(2) @(negedge clk);

        // Test 21: Basic increment (adds 1 to A)
        tb_opcode = 4'b1110; tb_a = 8'h05;
        repeat(2) @(negedge clk);

        // Test 22: Increment rolling over (tb_a = 8'hFF)
        tb_opcode = 4'b1110; tb_a = 8'h05;
        repeat(2) @(negedge clk);

        // Test 23: Increment signed overflow check (hitting the negative boundary)
        tb_opcode = 4'b1110; tb_a = 8'h7F;
        repeat(2) @(negedge clk);

        // Test 24: Basic decrement (subtracts 1 from A)
        tb_opcode = 4'b1111; tb_a = 8'h06;
        repeat(2) @(negedge clk);

        // Test 25: Decrement signed overflow check
        tb_opcode = 4'b1111; tb_a = 8'h80;
        repeat(2) @(negedge clk);

        // Test 26: Stabbing the reset button out of nowhere to make sure it clears instantly
        tb_opcode = 4'b0000; tb_a = 8'h55; tb_b = 8'h22;
        @(posedge clk);
        #2; rst_n = 0; // Trigger reset slightly after the clock edge
        repeat(2) @(negedge clk);
        rst_n = 1;

        repeat(2) @(negedge clk);
        $finish; // Wrapped up all tests, stopping simulation
    end

endmodule
