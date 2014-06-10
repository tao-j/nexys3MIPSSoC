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

module vgachar(
    input wire clk,
	input wire clr,
	input wire cBlink,

	/* char data input */

	input wire [6:0] char,
	input wire [7:0] fontcolor,
	input wire [7:0] backcolor,
	input wire Blink,

	/* Pipeline VGA sync */

	input wire xsync,
	input wire ysync,
	input wire [11:0] xpos,
	input wire [11:0] ypos,
	input wire valid,

	/* VGA output */

	output reg [2:0] vgaRed,
	output reg [2:0] vgaGreen,
	output reg [2:1] vgaBlue,
	output reg hsync,
	output reg vsync
    );

wire [10:0] addra;
wire [7:0] douta;
wire pixel;

asciifont fontmap (
  .a(addra), // input [10 : 0] addra
  .spo({douta[0], douta[1], douta[2], douta[3],
        douta[4], douta[5], douta[6], douta[7]}) // output [7 : 0] douta
);

assign addra = {char, ypos[3:0]};

assign pixel = douta[xpos[2:0]];

always @(posedge clk or posedge clr)
    if(clr == 1) begin
	    vgaRed <= 3'b000;
		vgaGreen <= 3'b000;
		vgaBlue[2:1] <= 2'b00;
		hsync <= 0;
		vsync <= 0;
	end else begin
		hsync <= xsync;
		vsync <= ysync;
		if(valid == 0) begin
			vgaRed <= 3'b000;
			vgaGreen <= 3'b000;
			vgaBlue[2:1] <= 2'b00;
		end else if(pixel && ~(Blink && cBlink)) begin
			vgaRed <= fontcolor[7:5];
			vgaGreen <= fontcolor[4:2];
			vgaBlue[2:1] <= fontcolor[1:0];
		end else begin
		    vgaRed <= backcolor[7:5];
			vgaGreen <= backcolor[4:2];
			vgaBlue[2:1] <= backcolor[1:0];
		end
	end
endmodule
