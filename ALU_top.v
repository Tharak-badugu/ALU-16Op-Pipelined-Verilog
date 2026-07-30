`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.07.2026 14:04:29
// Design Name: 
// Module Name: ALU_top
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


module alu_top #(
    parameter WIDTH = 8                      //width of the bits
)(
    input                  clk,
    input                  rst_n,                //active low reset
    input      [WIDTH-1:0] io_a,
    input      [WIDTH-1:0] io_b,
    input      [3:0]       io_opcode,            //to determine the operation
    
    output reg [WIDTH-1:0] o_result,               //output 
    output reg             o_zero,
    output reg             o_carry,
    output reg             o_overflow,
    output reg             o_negative);

    reg [WIDTH-1:0] r_a;              //interna register for a
    reg [WIDTH-1:0] r_b;               //internal reg for b
    reg [3:0]       r_opcode;          //internal register for operation

    wire [WIDTH-1:0] w_result;
    wire             w_zero;
    wire             w_carry;
    wire             w_overflow;
    wire             w_negative;

    // Input Pipeline Stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_a      <= {WIDTH{1'b0}};
            r_b      <= {WIDTH{1'b0}};
            r_opcode <= 4'b0000;
        end else begin
            r_a      <= io_a;
            r_b      <= io_b;
            r_opcode <= io_opcode;
        end
    end

    // ALU Core Core Core
    alu_engine #(.WIDTH(WIDTH)) u_alu_core (
        .a             (r_a),
        .b             (r_b),
        .opcode        (r_opcode),
        .result        (w_result),
        .zero_flag     (w_zero),
        .carry_flag    (w_carry),
        .overflow_flag (w_overflow),
        .negative_flag (w_negative)
    );

    // Output Pipeline Stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_result   <= {WIDTH{1'b0}};
            o_zero     <= 1'b0;
            o_carry    <= 1'b0;
            o_overflow <= 1'b0;
            o_negative <= 1'b0;
        end else begin
            o_result   <= w_result;
            o_zero     <= w_zero;
            o_carry    <= w_carry;
            o_overflow <= w_overflow;
            o_negative <= w_negative;
        end
    end

endmodule