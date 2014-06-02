module vcache(
	      input wire 	wb_clk_i,
	      input wire 	wb_rst_i, 
			//input wire 	wb_m0_vcache_gnt,
	      input wire 	wb_ack_i, // normal termination
	      input wire 	wb_err_i, // termination w/ error
	      input wire 	wb_rty_i, // termination w/ retry
	      input wire [31:0] wb_dat_i, // input data bus
	      output reg 	wb_cyc_o, // cycle valid output
	      output reg [31:0] wb_adr_o, // address bus outputs
	      output reg 	wb_stb_o, // strobe output
	      output reg 	wb_we_o, // indicates write transfer
	      output reg [3:0] 	wb_sel_o, // byte select outputs
	      output reg [31:0] wb_dat_o // output data bus
	      );
   
	reg [25:0] counter;
	
	always @(posedge wb_clk_i) begin
	   counter <= counter + 1;
	end
	
   always @(posedge wb_clk_i) begin
      wb_cyc_o <= counter > 'hf;
		wb_stb_o <= counter > 'hf;
      wb_we_o <= 0;
   end
   

      
     endmodule
