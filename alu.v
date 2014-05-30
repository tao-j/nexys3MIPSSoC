`timescale 1ns / 1ps

// nexys3MIPSSoC is a MIPS implementation originated from COAD projects
// Copyright (C) 2014  @Wenri, @dtopn, @Speed
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

