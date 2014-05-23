`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    17:19:38 07/17/2012
// Design Name:
// Module Name:    clk_div
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
module clk_div(
	input clk,
	input wire rst,
	input wire SW2,
	output reg[31:0] clkdiv,
	output wire Clk_CPU
    );


always @(posedge clk or posedge rst)begin
	if (rst) begin
		clkdiv <= 0;
	end else begin
		clkdiv <= clkdiv + 1'b1;
	end
end

//assign Clk_CPU = SW2?clkdiv[30]:clkdiv[1];

assign Clk_CPU = clk;

endmodule
