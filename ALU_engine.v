`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.07.2026 14:03:30
// Design Name: 
// Module Name: ALU_engine
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


module alu_engine #(
    parameter WIDTH = 8
)(
    input      [WIDTH-1:0] a,
    input      [WIDTH-1:0] b,
    input      [3:0]       opcode,
    output reg [WIDTH-1:0] result,
    output                 zero_flag,
    output reg             carry_flag,
    output reg             overflow_flag,
    output                 negative_flag
);

    localparam ADD  = 4'b0000; localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010; localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100; localparam NOR  = 4'b0101;
    localparam NAND = 4'b0110; localparam XNOR = 4'b0111;
    localparam NOTA = 4'b1000; localparam SLL  = 4'b1001;
    localparam SRL  = 4'b1010; localparam SRA  = 4'b1011;
    localparam ROL  = 4'b1100; localparam ROR  = 4'b1101;
    localparam INCA = 4'b1110; localparam DECA = 4'b1111;

    localparam SREG_W = $clog2(WIDTH); 
    reg [WIDTH:0] alu_ext; 
    
    wire [SREG_W-1:0] shift_amt = b[SREG_W-1:0];

    always @(*) begin
        result        = {WIDTH{1'b0}};
        carry_flag    = 1'b0;
        overflow_flag = 1'b0;
        alu_ext       = {(WIDTH+1){1'b0}};

        case (opcode)
            ADD: begin
                alu_ext       = {1'b0, a} + {1'b0, b};
                result        = alu_ext[WIDTH-1:0];
                carry_flag    = alu_ext[WIDTH];
                overflow_flag = (a[WIDTH-1] == b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
            end
            SUB: begin
                alu_ext       = {1'b0, a} - {1'b0, b};
                result        = alu_ext[WIDTH-1:0];
                carry_flag    = alu_ext[WIDTH]; 
                overflow_flag = (a[WIDTH-1] != b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
            end
            AND:  result = a & b;
            OR:   result = a | b;
            XOR:  result = a ^ b;
            NOR:  result = ~(a | b);
            NAND: result = ~(a & b);
            XNOR: result = ~(a ^ b);
            NOTA: result = ~a;
            SLL:  result = a << shift_amt; 
            SRL:  result = a >> shift_amt;
            SRA:  result = $signed(a) >>> shift_amt; 
            ROL:  result = (a << shift_amt) | (a >> (WIDTH - shift_amt)); 
            ROR:  result = (a >> shift_amt) | (a << (WIDTH - shift_amt));
            INCA: begin
                alu_ext       = {1'b0, a} + 1'b1;
                result        = alu_ext[WIDTH-1:0];
                carry_flag    = alu_ext[WIDTH];
                overflow_flag = (a[WIDTH-1] == 1'b0) && (result[WIDTH-1] == 1'b1);
            end
            DECA: begin
                alu_ext       = {1'b0, a} - 1'b1;
                result        = alu_ext[WIDTH-1:0];
                carry_flag    = alu_ext[WIDTH];
                overflow_flag = (a[WIDTH-1] == 1'b1) && (result[WIDTH-1] == 1'b0);
            end
            default: result = {WIDTH{1'b0}};
        endcase
    end

    assign zero_flag     = (result == {WIDTH{1'b0}});
    assign negative_flag = result[WIDTH-1];

endmodule
