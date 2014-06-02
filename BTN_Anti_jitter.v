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

module BTN_Anti_jitter(
	input wire clk,
	input wire [4:0]button,
	input wire [7:0]SW,
	output reg [4:0]button_out,
	output reg [7:0]SW_OK
    );

reg [31:0] counter;
always @(posedge clk)begin

	if (counter > 0)begin
		if (counter < 100000)            //100000
			counter <= counter + 1;
		else begin
			counter <= 32'b0;
			button_out <= button;
			SW_OK <= SW;
		end
	end else
	if (button >0 || SW > 0)
		counter <= counter + 1;
end

endmodule
