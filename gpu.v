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

module gpu(
	input wire clr,
	input wire clka,
	input wire clkb,
	input wire ena,
	input wire wea,
	input wire [12:0] addra,
	input wire [15:0] dina,
	output wire [15:0] douta,
	output wire [2:0] vgaRed,
	output wire [2:0] vgaGreen,
	output wire [2:1] vgaBlue,
	output wire Hsync,
	output wire Vsync
    );

reg [23:0] BlinkCount;
wire cBlink;
assign cBlink = BlinkCount[23];

/* vgabase_1024x768 SyncGen*/

wire pl0_xsync, pl0_ysync, pl0_vidon;
wire [11:0] pl0_xpos, pl0_ypos;

vgabase Pipeline0(.clk(clkb), .clr(clr),
	.hsync(pl0_xsync), .vsync(pl0_ysync),
    .hc(pl0_xpos), .vc(pl0_ypos), .vidon(pl0_vidon)
	);


/* vgamem_128x48 CharMemoryAccess */

wire [7:0] fontcolor;
wire [7:0] backcolor;
wire [6:0] char;
wire Blink;

wire pl1_xsync, pl1_ysync, pl1_vidon;
wire [11:0] pl1_xpos, pl1_ypos;

vgamem Pipeline1( .clr(clr), .clka(clka), .clkb(clkb),

	.ena(ena), .wea(wea), .addra(addra), .dina(dina), .douta(douta),

	.char(char), .fontcolor(fontcolor), .backcolor(backcolor), .Blink(Blink),

	.xsync(pl0_xsync), .ysync(pl0_ysync),
	.xpos(pl0_xpos), .ypos(pl0_ypos), .valid(pl0_vidon),

	.hsync(pl1_xsync), .vsync(pl1_ysync),
	.hc(pl1_xpos), .vc(pl1_ypos), .vidon(pl1_vidon)
    );

/* vgachar_128x48 CharFontGen*/
vgachar Pipeline2(.clk(clkb), .clr(clr), .cBlink(cBlink),

    .char(char), .fontcolor(fontcolor), .backcolor(backcolor), .Blink(Blink),

	.xsync(pl1_xsync), .ysync(pl1_ysync),
	.xpos(pl1_xpos), .ypos(pl1_ypos), .valid(pl1_vidon),

	.hsync(Hsync), .vsync(Vsync),
    .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue)

	);


always @(posedge clkb or posedge clr) begin
    if(clr == 1)
	    BlinkCount <= 0;
	else
		BlinkCount <= BlinkCount + 1'b1;
end

endmodule
