module vcache(/*AUTOARG*/
   // Outputs
   rgb, hsync, vsync, wb_cyc_o, wb_adr_o, wb_stb_o, wb_we_o,
   wb_sel_o, wb_dat_o,
   // Inputs
   wb_clk_i, wb_rst_i, vga_clk, wb_ack_i, wb_err_i, wb_rty_i,
   wb_dat_i
   );
	
   input wire  wb_clk_i;
   input wire  wb_rst_i;

   input wire  vga_clk;
   output  [7:0] rgb;
   output      hsync;         // From vga0 of vga.v
   output      vsync;         // From vga0 of vga.v

   //input wire   wb_m0_vcache_gnt;
   input wire  wb_ack_i; // normal termination
   input wire  wb_err_i; // termination w/ error
   input wire  wb_rty_i; // termination w/ retry
   input wire [31:0] wb_dat_i; // input data bus
   output        wb_cyc_o; // cycle valid output
   output  [31:0] wb_adr_o; // address bus outputs
   output        wb_stb_o; // strobe output
   output        wb_we_o; // indicates write transfer
   output  [3:0]  wb_sel_o; // byte select outputs
   output  [31:0] wb_dat_o; // output data bus
	
	wire  [9:0]    x;
   wire  [9:0]    y;
   wire     ve;

	parameter vram_adr_base = 'hf80000;
	
	//wire rd_en;//, wr_en;
	//wire full, almost_full, empty, almost_empty;
	//assign rgb = ve? x / 2 + y / 2 : 0;
	wire [7:0] dout_rgb;
	assign rgb = ve ? dout_rgb : 0;
//	assign rd_en = ve
//		|| (0 && x >= 480 && x <= 483) && (!(|y[2:0]) && y[3]) || (0 && x >= 480 && x <= 484) && (!(|y[2:0]) && !y[3])
//			;
	assign wb_sel_o = 4'b1111;
	assign wb_we_o = 0;

/*	reg write_start;
	reg wea;
	wire web = 0;
	reg ena;
	reg [7:0] addra;
	wire [31:0] douta;
	always @(posedge wb_clk_i) begin
		if( (y >= -1 || y <= 478) && x == 300) begin
			write_start <= 1;
		end
		if(write_start) begin
			ena <= 1;
			wb_cyc_o <= 1;
			wb_stb_o <= 1;
			if (wb_ack_i) begin
				wea <= 1;
				addra <= addra + 1;
				counter <= counter + 1;
			end
			else begin
				wea <= 0;
			end
			if (addra == 'd190) begin
				wb_cyc_o <= 0;
				wb_stb_o <= 0;
				write_start <= 0;
				ena <= 0;
			end
		end
		if(y == 480) begin
			counter <= 0;
		end
	end

	line_buffer call_me_a_fifo (
  .clka(wb_clk_i), // input clka
  .wea(wea), // input [0 : 0] wea
  .ena(!ve),
  .addra(addra), // input [7 : 0] addra
  .dina(wb_dat_i), // input [31 : 0] dina
  .douta(douta), // output [31 : 0] douta
  .clkb(vga_clk), // input clkb
  .web(web), // input [0 : 0] web
  .enb(ve),
  .addrb(x[9:0]), // input [9 : 0] addrb
  .dinb(8'b0), // input [7 : 0] dinb
  .doutb(dout_rgb) // output [7 : 0] doutb
	);*/

	`define FILL  1
	`define IDLE  0
	reg state;
	reg [16:0] counter, counter_line;
	assign wb_adr_o = vram_adr_base + (counter_line + counter) * 4;
	assign wb_cyc_o = (state == `IDLE)? 0 : 1;
	assign wb_stb_o = ((state == `IDLE)? 0 : 1) & !wb_ack_i;

	always @(posedge wb_clk_i) begin
		if (wb_ack_i) begin
			if (counter_line == 159) begin
				state <= `IDLE;
				counter_line <= 0;
				counter <= counter + 160;
			end
			else begin
				counter_line <= counter_line + 1;
			end
		end
		if (y >= 0 && y < 480) begin
			case(state)
				`IDLE: begin 
					if (newline) state <= `FILL;
				end
				`FILL: begin
					
				end
			endcase
		end
		else begin
			counter <= 0;
			counter_line <= 0;
		end
	end
/*	assign fifo_rst = ((y == 'd479) && (x == 'd640)) || ((y == 'd479) && (x == 'd641));
	`define FILL  0
	`define IDLE  1
	reg fifo_state;
	wire fill_req;
	reg [16:0] counter, counter_line;
	assign wb_adr_o = vram_adr_base + (counter_line + counter) * 4;
   always @(posedge wb_clk_i) begin
		if (fifo_rst) begin
			counter <= 0;
			counter_line <= 0;
		end
		else begin
			if (wb_ack_i) begin
				if (counter_line == 'd159) begin
					counter_line <= 0;
					if (counter == 0)	counter <= counter + 'd159;
					else counter <= counter + 'd160;
				end
				else begin
					counter_line <= counter_line + 1;
				end
			end
		end
	   case (fifo_state)
			`IDLE: begin
				if(
				!hsync && y >= 0 && y < 480 
//				prog_empty //256depth 162prog_full 62prog_empty
					) begin
					fifo_state <= `FILL;
					wb_cyc_o <= 1;
					wb_stb_o <= 1;
				end
				else begin
					wb_cyc_o <= 0;
					wb_stb_o <= 0;
				end
			end
			`FILL: begin
				if (counter_line != 159) begin
					wb_cyc_o <= 1;
					wb_stb_o <= 1;
				end
				else begin
					fifo_state <= `IDLE;
					wb_cyc_o <= 0;
					wb_stb_o <= 0;
				end
			end
		endcase
		
//		if(prog_empty & !prog_full) begin
//			wb_cyc_o <= 1;
//			wb_stb_o <= 1;
//		end
//		else begin
//			wb_cyc_o <= 0;
//			wb_stb_o <= 0;
//		end
		
	end
*/
 //F**k yourself, use fifo
 wire line_rst = x == 'd640;
 wire newline, newfield;
	vcache_fifo fifo0 (
  .wr_clk(wb_clk_i), // input wr_clk
  .rd_clk(vga_clk), // input rd_clk
  .rst(x == 640 || newfield),
//  .rst(fifo_rst),
	.din(wb_dat_i),
//  .din({wb_dat_i[23:16], wb_dat_i[31:24], wb_dat_i[7:0], wb_dat_i[15:8]} ), // input [31 : 0] din
  .wr_en(wb_ack_i), // input wr_en
  .rd_en(ve), // input rd_en
  .dout(dout_rgb) // output [7 : 0] dout
//  .wr_ack(wr_ack), // output wr_ack
		//ack is asserted when the previous write cycle succeeded
//  .full(full), // output full
//  .empty(empty), // output empty
//  .prog_full(prog_full) // output prog_full
//  .prog_empty(prog_empty) // output prog_empty
	);

   wire clk_p = vga_clk;
   vga vga0(
	    .rst			(~wb_rst_i),
      /*AUTOINST*/
	    // Outputs
	    .hsync			(hsync),
	    .vsync			(vsync),
	    .x				(x[9:0]),
	    .y				(y[9:0]),
	    .ve				(ve),
		 .newline		(newline),
		 .newfield		(newfield),
	    // Inputs
	    .clk_p			(clk_p)
   );
	
endmodule

