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

module Coprocessor(
    input clk,
    input rst,
    input [4:0] reg_R_addr,
    input [4:0] reg_W_addr,
    input [31:0] wdata,
    input [31:0] pc_i,
    input reg_we,
    input EPCWrite,
    input CauseWrite,
    input [1:0] IntCause,
    output [31:0] rdata
    );

reg [31:0] register[12:14];
integer i;

assign rdata = register[reg_R_addr];

always @(posedge clk or posedge rst)
    if (rst == 1)begin
        for (i=12;i<14;i=i+1)
            register[i] <= 0;
    end else begin
        if (reg_we)
            register[reg_W_addr] <= wdata;
        if (EPCWrite == 1)
            register[14] <= pc_i;
        if (CauseWrite == 1)
            register[13] <= IntCause;
    end

endmodule
