`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:51:53 05/16/2014 
// Design Name: 
// Module Name:    mux4to1_32 
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
module mux4to1_32(
	input wire [1:0] sel,
	input wire [31:0] a,
	input wire [31:0] b,
	input wire [31:0] c,
	input wire [31:0] d,
	output reg [31:0] o
    );

always @(*)
	case(sel)
		2'b00: o<=a;
		2'b01: o<=b;
		2'b10: o<=c;
		2'b11: o<=d;
	endcase
	
endmodule
