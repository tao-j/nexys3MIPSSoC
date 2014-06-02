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

module seven_seg_Dev_IO( input clk,
							input rst,
							input GPIOe0000000_we,
							input [2:0] Test,
							input [31:0] disp_cpudata,
							input [31:0] Test_data0,
							input [31:0] Test_data1,
							input [31:0] Test_data2,
							input [31:0] Test_data3,
							input [31:0] Test_data4,
							input [31:0] Test_data5,
							input [31:0] Test_data6,
							output[31:0] disp_num
						);

endmodule
