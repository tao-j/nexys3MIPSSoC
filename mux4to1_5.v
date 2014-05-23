`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:48:14 04/03/2014 
// Design Name: 
// Module Name:    mux2to1_5 
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
