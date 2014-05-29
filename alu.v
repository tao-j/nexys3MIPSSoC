`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:40:41 03/20/2014 
// Design Name: 
// Module Name:    ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu(
	input [31:0] A,
	input [31:0] B,
	input [2:0] ALU_operation,
	output [31:0] res,
	output zero,
	output reg overflow
    );
wire [31:0] res_and,res_or,res_add,res_sub,res_nor,res_slt;
reg [31:0] res_op; 
parameter one = 32'h00000001,zero_0=32'h00000000;

assign res_and = A&B;
assign res_or = A|B;
assign res_add = A+B;
assign res_sub = A-B;
assign res_slt = (A<B)?one:zero_0;
assign res = res_op[31:0];

always @(*) begin
	overflow = 0;
	case(ALU_operation)
		3'b000: res_op = res_and;
		3'b001: res_op = res_or;
		3'b010: begin
					res_op = res_add;
					if ((A[31:31]&B[31:31]&~res[31:31]) | (~A[31:31]&~B[31:31]&res[31:31]))
						overflow = 1;
				  end
		3'b110: begin
					res_op = res_sub;
					if ((A[31:31]&~B[31:31]&~res[31:31]) | (~A[31:31]&B[31:31]&res[31:31]))
						overflow = 1;
				  end
		3'b100: res_op = ~(A|B);
		3'b111: res_op = res_slt;
		3'b101: res_op = A >> 1;
		3'b011: res_op = (~A&B) | (A&~B);
		default: res_op=32'hxxxxxxxx;
	endcase
end
	assign zero = (res==0)?1:0;
endmodule

