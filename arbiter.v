module arbiter(/*AUTOARG*/
   // Outputs
   wb_m0_vcache_dat_o, wb_m0_vcache_ack_o, wb_m1_cpu_dat_o,
   wb_m1_cpu_ack_o, wb_s0_cellram_wb_adr_o, wb_s0_cellram_wb_dat_o,
   wb_s0_cellram_wb_sel_o, wb_s0_cellram_wb_stb_o,
   wb_s0_cellram_wb_cyc_o, wb_s0_cellram_wb_we_o,
   // Inputs
   wb_clk, wb_rst, wb_m0_vcache_adr_i, wb_m0_vcache_dat_i,
   wb_m0_vcache_sel_i, wb_m0_vcache_cyc_i, wb_m0_vcache_stb_i,
   wb_m0_vcache_we_i, wb_m1_cpu_adr_i, wb_m1_cpu_dat_i,
   wb_m1_cpu_sel_i, wb_m1_cpu_cyc_i, wb_m1_cpu_stb_i, wb_m1_cpu_we_i,
   wb_s0_cellram_wb_dat_i, wb_s0_cellram_wb_ack_i
	//
	,cellram_mst_sel
   );

   input  wire wb_clk, wb_rst;

   input  wire [31:0] 	       		  wb_m0_vcache_adr_i;
   input  wire [31:0] 	       		  wb_m0_vcache_dat_i;
   input  wire [3:0] 	       		  wb_m0_vcache_sel_i;
   input  wire 				  wb_m0_vcache_cyc_i;
   input  wire 				  wb_m0_vcache_stb_i;
   input  wire 				  wb_m0_vcache_we_i;
   output wire [31:0]  			  wb_m0_vcache_dat_o;
   output wire 				  wb_m0_vcache_ack_o;

   input  wire [31:0] 	       		  wb_m1_cpu_adr_i;
   input  wire [31:0] 	       		  wb_m1_cpu_dat_i;
   input  wire [3:0] 	       		  wb_m1_cpu_sel_i;
   input  wire 				  wb_m1_cpu_cyc_i;
   input  wire 				  wb_m1_cpu_stb_i;
   input  wire 				  wb_m1_cpu_we_i;
   output wire [31:0] 	       		  wb_m1_cpu_dat_o;
   output wire 				  wb_m1_cpu_ack_o;

   output wire [31:0] 			  wb_s0_cellram_wb_adr_o;
   output wire [31:0] 			  wb_s0_cellram_wb_dat_o;
   output wire [3:0] 			  wb_s0_cellram_wb_sel_o;
   output wire 				  wb_s0_cellram_wb_stb_o;
   output wire 				  wb_s0_cellram_wb_cyc_o;
   output wire 				  wb_s0_cellram_wb_we_o;
   input  wire [31:0] 			  wb_s0_cellram_wb_dat_i;
   input  wire 				  wb_s0_cellram_wb_ack_i;
   
   //output wire 				  wb_m1_cpu_gnt;
   //output wire 				  wb_m0_vcache_gnt;
   
   output reg [1:0] 				  cellram_mst_sel;
	
	//assign cellram_mst_sel[1] = wb_m0_vcache_cyc_i & wb_m0_vcache_stb_i 
	                 //& !(cellram_mst_sel[1]  & (wb_s0_cellram_wb_ack_i | cellram_arb_reset))
	//					  ;
	//assign cellram_mst_sel[0] = !cellram_mst_sel[1] & wb_m1_cpu_cyc_i & wb_m1_cpu_stb_i
	                 //& !(cellram_mst_sel[0]  & (wb_s0_cellram_wb_ack_i | cellram_arb_reset))
	//					  ;

   reg [9:0] 				  cellram_arb_timeout;
   wire 				  cellram_arb_reset;

   //assign wb_m1_cpu_gnt = cellram_mst_sel[0];
   //assign wb_m0_vcache_gnt = cellram_mst_sel[1];

   always @(posedge wb_clk)
     if (wb_rst)
       cellram_mst_sel <= 0;
     else begin
	if (cellram_mst_sel==2'b00) begin
	   /* wait for new access from masters. vcache takes priority */
	   if (wb_m0_vcache_cyc_i & wb_m0_vcache_stb_i) //if (wbs_d_cellram_cyc_i & wbs_d_cellram_stb_i)
	     cellram_mst_sel[1] <= 1;
     else if (wb_m1_cpu_cyc_i & wb_m1_cpu_stb_i) //else if (wbs_i_cellram_cyc_i & wbs_i_cellram_stb_i)
	     cellram_mst_sel[0] <= 1;
	end
	else begin
	   if (wb_s0_cellram_wb_ack_i) //| cellram_arb_reset) //TODO: reset
	     cellram_mst_sel <= 0;
	end // else: !if(cellram_mst_sel==2'b00)
     end // else: !if(wb_rst)

   reg [3:0] cellram_rst_counter;
   always @(posedge wb_clk or posedge wb_rst)
     if (wb_rst)
       cellram_rst_counter <= 4'hf;
     else if (|cellram_rst_counter)
       cellram_rst_counter <= cellram_rst_counter - 1;

   assign wb_s0_cellram_wb_adr_o = cellram_mst_sel[0] ? wb_m1_cpu_adr_i :
			   wb_m0_vcache_adr_i;
   assign wb_s0_cellram_wb_dat_o = cellram_mst_sel[0] ? wb_m1_cpu_dat_i :
			   wb_m0_vcache_dat_i;
   assign wb_s0_cellram_wb_stb_o = (cellram_mst_sel[0] ?  wb_m1_cpu_stb_i :
			   cellram_mst_sel[1]  ? wb_m0_vcache_stb_i : 0) &
			   !(|cellram_rst_counter);
   assign wb_s0_cellram_wb_cyc_o = cellram_mst_sel[0] ?  wb_m1_cpu_cyc_i :
			   cellram_mst_sel[1] ?  wb_m0_vcache_cyc_i : 0;
   assign wb_s0_cellram_wb_we_o = cellram_mst_sel[0] ? wb_m1_cpu_we_i :
			  wb_m0_vcache_we_i;
   assign wb_s0_cellram_wb_sel_o = cellram_mst_sel[0] ? wb_m1_cpu_sel_i :
			  wb_m0_vcache_sel_i;

   assign wb_m1_cpu_dat_o = wb_s0_cellram_wb_dat_i;
   assign wb_m0_vcache_dat_o = wb_s0_cellram_wb_dat_i;
   assign wb_m1_cpu_ack_o = wb_s0_cellram_wb_ack_i & cellram_mst_sel[0];
   assign wb_m0_vcache_ack_o = wb_s0_cellram_wb_ack_i & cellram_mst_sel[1];
   assign wb_m1_cpu_err_o = cellram_arb_reset & cellram_mst_sel[0];
   assign wb_m1_cpu_rty_o = 0;
   assign wb_m0_vcache_err_o = cellram_arb_reset & cellram_mst_sel[1];
   assign wb_m0_vcache_rty_o = 0;


   always @(posedge wb_clk)
     if (wb_rst)
       cellram_arb_timeout <= 0;
     else if (wb_s0_cellram_wb_ack_i)
       cellram_arb_timeout <= 0;
     else if (wb_s0_cellram_wb_stb_o & wb_s0_cellram_wb_cyc_o)
       cellram_arb_timeout <= cellram_arb_timeout + 1;

   assign cellram_arb_reset = (&cellram_arb_timeout);

endmodule

