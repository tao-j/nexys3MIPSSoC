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

module Regs(
	input clk,
	input rst,
	input [4:0] reg_R_addr_A,
	input [4:0] reg_R_addr_B,
	input [4:0] reg_W_addr,
	input [31:0] wdata,
	input reg_we,
	output [31:0] rdata_A,
	output [31:0] rdata_B
    );

reg [31:0] register[1:31];
integer i;

assign rdata_A = (reg_R_addr_A == 0)?0:register[reg_R_addr_A];
assign rdata_B = (reg_R_addr_B == 0)?0:register[reg_R_addr_B];

always @(posedge clk or posedge rst)
begin
	if (rst == 1)begin
		for (i=1;i<32;i=i+1)
			register[i] <= 0;
	end else begin
		if ((reg_W_addr != 0)&&(reg_we == 1))
			register[reg_W_addr] <= wdata;
	end
end
endmodule
