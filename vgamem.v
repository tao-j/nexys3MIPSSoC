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

module vgamem(
	/* Global Reset */
	input wire clr,

	/* Graph Memory Access Port */
    input wire clka,
	input wire ena,
	input wire wea,
	input wire [12:0] addra,
	input wire [15:0] dina,
	output wire [15:0] douta,

	/* char Data output port */

    input wire clkb,
	output wire [6:0] char,
	output wire [7:0] fontcolor,
	output wire [7:0] backcolor,
	output wire Blink,

	/* Pipeline VGA sync */

	input wire xsync,
	input wire ysync,
	input wire [11:0] xpos,
	input wire [11:0] ypos,
	input wire valid,

	output reg hsync,
	output reg vsync,
	output reg [11:0] hc,
	output reg [11:0] vc,
	output reg vidon
    );

wire [12:0] addrb;
wire [15:0] dinb;
wire [15:0] doutb;

wire Increase;
wire [2:0] backRGB;
wire [2:0] fontRGB;


wire [6:0] column;
wire [5:0] line;

assign line   = ypos / 16;
assign column = xpos / 8;

assign addrb = {line, column};
assign char = doutb[15:8];
assign {Blink, backRGB, Increase, fontRGB} = doutb[7:0];

assign fontcolor = {Increase, fontRGB[2], 1'b0,
                    Increase, fontRGB[1], 1'b0,
					Increase, fontRGB[0]};

assign backcolor = {1'b0, backRGB[2], 1'b0,
                    1'b0, backRGB[1], 1'b0,
					1'b0, backRGB[0]};

memchar charmem (

  .clka(clka), // input clka
  .ena(ena), // input ena
  .wea(wea), // input [0 : 0] wea
  .addra(addra), // input [12 : 0] addra
  .dina(dina), // input [15 : 0] dina
  .douta(douta), // output [15 : 0] douta

  .clkb(clkb), // input clkb
  .enb(valid), // input enb
  .web(1'b0), // input [0 : 0] web
  .addrb(addrb), // input [12 : 0] addrb
  .dinb(dinb), // input [15 : 0] dinb
  .doutb(doutb) // output [15 : 0] doutb
);

always @(posedge clkb) begin
    hsync <= xsync;
	vsync <= ysync;
	hc <= xpos;
	vc <= ypos;
	vidon <= valid;
end

endmodule
