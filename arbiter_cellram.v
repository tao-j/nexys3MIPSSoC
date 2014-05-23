
   /* Lighweight arbiter between instruction and data busses going
    into the cellram controller */

   wire [31:0] 				  cellram_wb_adr_i;
   wire [31:0] 				  cellram_wb_dat_i;
   wire [31:0] 				  cellram_wb_dat_o;
   wire [3:0] 				  cellram_wb_sel_i;
   wire 				  cellram_wb_cyc_i;
   wire 				  cellram_wb_stb_i;
   wire 				  cellram_wb_we_i;
   wire 				  cellram_wb_ack_o;

   reg [1:0] 				  cellram_mst_sel;

   reg [9:0] 				  cellram_arb_timeout;
   wire 				  cellram_arb_reset;

   always @(posedge wb_clk)
     if (wb_rst)
       cellram_mst_sel <= 0;
     else begin
	if (cellram_mst_sel==2'b00) begin
	   /* wait for new access from masters. data takes priority */
	   if (wbs_d_cellram_cyc_i & wbs_d_cellram_stb_i)
	     cellram_mst_sel[1] <= 1;
	   else if (wbs_i_cellram_cyc_i & wbs_i_cellram_stb_i)
	     cellram_mst_sel[0] <= 1;
	end
	else begin
	   if (cellram_wb_ack_o | cellram_arb_reset)
	     cellram_mst_sel <= 0;
	end // else: !if(cellram_mst_sel==2'b00)
     end // else: !if(wb_rst)

   reg [3:0] cellram_rst_counter;
   always @(posedge wb_clk or posedge wb_rst)
     if (wb_rst)
       cellram_rst_counter <= 4'hf;
     else if (|cellram_rst_counter)
       cellram_rst_counter <= cellram_rst_counter - 1;

   assign cellram_wb_adr_i = cellram_mst_sel[0] ? wbs_i_cellram_adr_i :
			   wbs_d_cellram_adr_i;
   assign cellram_wb_dat_i = cellram_mst_sel[0] ? wbs_i_cellram_dat_i :
			   wbs_d_cellram_dat_i;
   assign cellram_wb_stb_i = (cellram_mst_sel[0] ?  wbs_i_cellram_stb_i :
			   cellram_mst_sel[1]  ? wbs_d_cellram_stb_i : 0) &
			   !(|cellram_rst_counter);
   assign cellram_wb_cyc_i = cellram_mst_sel[0] ?  wbs_i_cellram_cyc_i :
			   cellram_mst_sel[1] ?  wbs_d_cellram_cyc_i : 0;
   assign cellram_wb_we_i = cellram_mst_sel[0] ? wbs_i_cellram_we_i :
			  wbs_d_cellram_we_i;
   assign cellram_wb_sel_i = cellram_mst_sel[0] ? wbs_i_cellram_sel_i :
			  wbs_d_cellram_sel_i;

   assign wbs_i_cellram_dat_o = cellram_wb_dat_o;
   assign wbs_d_cellram_dat_o = cellram_wb_dat_o;
   assign wbs_i_cellram_ack_o = cellram_wb_ack_o & cellram_mst_sel[0];
   assign wbs_d_cellram_ack_o = cellram_wb_ack_o & cellram_mst_sel[1];
   assign wbs_i_cellram_err_o = cellram_arb_reset & cellram_mst_sel[0];
   assign wbs_i_cellram_rty_o = 0;
   assign wbs_d_cellram_err_o = cellram_arb_reset & cellram_mst_sel[1];
   assign wbs_d_cellram_rty_o = 0;


   always @(posedge wb_clk)
     if (wb_rst)
       cellram_arb_timeout <= 0;
     else if (cellram_wb_ack_o)
       cellram_arb_timeout <= 0;
     else if (cellram_wb_stb_i & cellram_wb_cyc_i)
       cellram_arb_timeout <= cellram_arb_timeout + 1;

   assign cellram_arb_reset = (&cellram_arb_timeout);

   cellram_ctrl
     /* Use the simple flash interface */
     #(
       .cellram_read_cycles(4), // 70ns in cycles, at 50MHz 4=80ns
       .cellram_write_cycles(4)) // 70ns in cycles, at 50Mhz 4=80ns
     cellram_ctrl0
     (
      .wb_clk_i(wb_clk),
      .wb_rst_i(wb_rst | cellram_arb_reset),

      .wb_adr_i(cellram_wb_adr_i),
      .wb_dat_i(cellram_wb_dat_i),
      .wb_stb_i(cellram_wb_stb_i),
      .wb_cyc_i(cellram_wb_cyc_i),
      .wb_we_i (cellram_wb_we_i ),
      .wb_sel_i(cellram_wb_sel_i),
      .wb_dat_o(cellram_wb_dat_o),
      .wb_ack_o(cellram_wb_ack_o),
      .wb_err_o(),
      .wb_rty_o(),

      .cellram_dq_io(cellram_dq_io),
      .cellram_adr_o(cellram_adr_o),
      .cellram_adv_n_o(cellram_adv_n_o),
      .cellram_ce_n_o(cellram_ce_n_o),
      .cellram_clk_o(cellram_clk_o),
      .cellram_oe_n_o(cellram_oe_n_o),
      .cellram_rst_n_o(),
      .cellram_wait_i(cellram_wait_i),
      .cellram_we_n_o(cellram_we_n_o),
      .cellram_wp_n_o(),
      .cellram_lb_n_o(cellram_lb_n_o),
      .cellram_ub_n_o(cellram_ub_n_o),
      .cellram_cre_o(cellram_cre_o)
      );

