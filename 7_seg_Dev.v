`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// CompANy:
// Engineer:
//
// Create Date:    23:15:49 09/30/2011
// Design Name:
// Module Name:    x7seg
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
module seven_seg(
	input wire[31:0] disp_num,
	input clk,
	input wire clr,
	input wire[1:0]SW,
	input wire[1:0]Scanning,
	input wire [3:0] dpdot,
	output wire[7:0]SEGMENT,
	output reg[3:0]AN
    );
reg[3:0] digit;
reg[7:0] temp_seg,digit_seg;
wire[15:0] disp_current;

assign SEGMENT=SW[0]?digit_seg:temp_seg;
assign disp_current=SW[1]?disp_num[31:16]:disp_num[15:0];

always @(*)begin
	case(Scanning)
		0:begin
			digit = disp_current[3:0];
			temp_seg={disp_num[24],disp_num[12],disp_num[5],disp_num[17],
			disp_num[25],disp_num[16],disp_num[4],disp_num[0]};
			AN = 4'b1110;
		  end
		1:begin
			digit = disp_current[7:4];
			temp_seg={disp_num[26],disp_num[13],disp_num[7],disp_num[19],
			disp_num[27],disp_num[18],disp_num[6],disp_num[1]};
			AN = 4'b1101;
		  end
		2:begin
			digit = disp_current[11:8];
			temp_seg={disp_num[28],disp_num[14],disp_num[9],disp_num[21],
			disp_num[29],disp_num[20],disp_num[8],disp_num[2]};
			AN = 4'b1011;
		  end
		3:begin
			digit = disp_current[15:12];
			temp_seg={disp_num[30],disp_num[15],disp_num[11],disp_num[23],
			disp_num[31],disp_num[22],disp_num[10],disp_num[3]};
			AN = 4'b0111;
		  end
	endcase
end

/*

always @(*)begin
	case(Scanning)
		0:begin
			digit = disp_current[3:0];
			temp_seg={disp_num[24],disp_num[0],disp_num[4],disp_num[16],
			disp_num[25],disp_num[17],disp_num[5],disp_num[12]};
			AN = 4'b1110;
		  end
		1:begin
			digit = disp_current[7:4];
			temp_seg={disp_num[26],disp_num[1],disp_num[6],disp_num[18],
			disp_num[27],disp_num[19],disp_num[7],disp_num[13]};
			AN = 4'b1101;
		  end
		2:begin
			digit = disp_current[11:8];
			temp_seg={disp_num[28],disp_num[2],disp_num[8],disp_num[20],
			disp_num[29],disp_num[21],disp_num[9],disp_num[14]};
			AN = 4'b1011;
		  end
		3:begin
			digit = disp_current[15:12];
			temp_seg={disp_num[30],disp_num[3],disp_num[10],disp_num[22],
			disp_num[31],disp_num[23],disp_num[11],disp_num[15]};
			AN = 4'b0111;
		  end
	endcase
end

*/

always @(*)begin
	case(digit)
		0: digit_seg = 7'b1000000;
		1: digit_seg = 7'b1111001;
		2: digit_seg = 7'b0100100;
		3: digit_seg = 7'b0110000;
		4: digit_seg = 7'b0011001;
		5: digit_seg = 7'b0010010;
		6: digit_seg = 7'b0000010;
		7: digit_seg = 7'b1111000;
		8: digit_seg = 7'b0000000;
		9: digit_seg = 7'b0010000;
		'hA: digit_seg = 7'b0001000;
		'hB: digit_seg = 7'b0000011;
		'hC: digit_seg = 7'b1000110;
		'hD: digit_seg = 7'b0100001;
		'hE: digit_seg = 7'b0000110;
		'hF: digit_seg = 7'b0001110;
		default: digit_seg = 7'b1000000;
	endcase
	digit_seg[7] = ~dpdot[Scanning];
end

endmodule

