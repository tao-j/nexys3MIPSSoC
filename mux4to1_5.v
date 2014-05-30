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

module mux4to1_5(
	input wire sel,
	input wire [4:0] a,
	input wire [4:0] b,
	input wire [4:0] c,
	input wire [4:0] d,
	output reg [4:0] o
);


always @(*)
	case(sel)
		2'b00: o<=a;
		2'b01: o<=b;
		2'b10: o<=c;
		2'b11: o<=d;
	endcase

endmodule
