`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:34:44 03/12/2012 
// Design Name: 
// Module Name:    Regs 
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
