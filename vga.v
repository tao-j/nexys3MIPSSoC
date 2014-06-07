module vga(/*AUTOARG*/
   // Outputs
   hsync, vsync, x, y, ve, newline, newfield,
   // Inputs
   clk_p, rst
   );
	input wire clk_p;
	input wire rst;
	output wire hsync, vsync;
	output wire [9:0] x, y; //1023
	output wire ve;
	output wire newline, newfield;
	assign newline = x_i == 0;
	assign newfield = y_i == 0;
	
	reg [10:0] x_i, y_i; //2047
	//wire clk_l; //clk_p pixel clock, clk_l line clock
	//60Hz 0 < x < 1023, 0 < y < 767 75Mhz clk_d
	//Horizontal (line) Front Porch 24clk_p Sync 136clk_p Back Porch 160clk_p = 1344
	//Vertical (field)  					3clk_l		6clk_l					29clk_l = 806
	
	//60Hz 0 < x < 799, 0 < y < 599 40Mhz clk_d
//	parameter h_pixel = 'd799;
//	parameter v_pixel = 'd599;
//	parameter h_front_porch = 'd40;
//	parameter h_sync_pulse = 'd128;
//	parameter h_back_porch = 'd88;
//	parameter v_front_porch = 'd1;
//	parameter v_sync_pulse = 'd4;
//	parameter v_back_porch = 'd23;
//	parameter line = h_pixel + h_front_porch + h_sync_pulse + h_back_porch;
//	parameter field = v_pixel + v_front_porch + v_sync_pulse + v_back_porch;
	
	//60Hz 0 < x < 639, 0 < y < 479 25Mhz clk_d
	parameter h_pixel = 'd639;
	parameter v_pixel = 'd479;
	parameter v_front_porch = 'd10;
	parameter v_sync_pulse = 'd2;
	parameter v_back_porch = 'd29; //33
	parameter h_front_porch = 'd16;
	parameter h_sync_pulse = 'd96;
	parameter h_back_porch = 'd48;
	parameter line = h_pixel + h_front_porch + h_sync_pulse + h_back_porch;
	parameter field = v_pixel + v_front_porch + v_sync_pulse + v_back_porch;
	
	always @(posedge clk_p) begin
		if(~rst) begin 
			x_i <= 0;
		end
		else begin
			if(x_i == line) begin
				x_i <= 0;
			end
			else begin
				x_i <= x_i + 1;
			end
		end
	end
	
	always @(posedge clk_p) begin
		if(~rst) begin
			y_i <= 0;
		end
		else if (x_i == line) begin
			if(y_i == field) begin
				y_i <= 0;
			end
			else begin 
				y_i <= y_i + 1;
			end
		end
	end
	
	assign hsync = (x_i >= h_sync_pulse) ? 1: 0;
	assign vsync = (y_i >= v_sync_pulse) ? 1: 0;
	assign ve = 0
				||	(x_i >= h_sync_pulse + h_back_porch && x_i <= line - h_front_porch) && (y_i >= v_sync_pulse + v_back_porch && y_i <= field - v_front_porch)
//				&&  ( (|y[2:0]))
//				|| (x_i >= h_sync_pulse + h_back_porch && x_i <=1+ line - h_front_porch) && (y_i >= v_sync_pulse + v_back_porch && y_i <= field - v_front_porch)
//				&&  (!(|y[2:0]))
				;
	//assign x = (ve) ? x_i - h_back_porch - h_sync_pulse : 0;
	//assign y = (ve) ? y_i - v_back_porch - v_sync_pulse : 0;
	assign x = x_i - h_back_porch - h_sync_pulse;
	assign y = y_i - v_back_porch - v_sync_pulse;

endmodule
