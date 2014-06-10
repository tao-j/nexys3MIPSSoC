`timescale 1ns / 1ps

// nexys3MIPSSoC is a MIPS implementation originated from COAD projects
// Copyright (C) 2014  @Wenri, @dtopn, @Speed
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

module Top_Muliti_IOBUS(
 sys_clk,
 BTN,  // I/O:
 SW,
 LED,
 SEGMENT,
 AN_SEL,

cellram_dq_io,
cellram_adr_o,
cellram_adv_n_o,
cellram_ce_n_o,
cellram_clk_o,
cellram_oe_n_o,
cellram_wait_i,
cellram_we_n_o,
cellram_cre_o,
cellram_lb_n_o,
cellram_ub_n_o,

   vsync, rgb, hsync,
   ps2_clk,ps2_dat
 );
   parameter cellram_dq_width = 16;
   parameter cellram_adr_width = 23;

   parameter cellram_write_cycles = 4; // wlwh/Tclk = 50ns / 15 ns (66Mhz)
   parameter cellram_read_cycles = 4;  // elqv/Tclk = 95 / 15 ns (66MHz)

 input sys_clk;
 input [4:0] BTN;
 input [7:0] SW;
 output [7:0] LED,SEGMENT;
 output [3:0] AN_SEL;

   inout [cellram_dq_width-1:0]        cellram_dq_io;
   output [cellram_adr_width-1:0]      cellram_adr_o;

   output                  cellram_adv_n_o;
   output                  cellram_ce_n_o;
   output                  cellram_clk_o;
   output                  cellram_oe_n_o;
   input                   cellram_wait_i;
   output                  cellram_we_n_o;
   output                  cellram_cre_o;
   output                  cellram_ub_n_o;
   output                  cellram_lb_n_o;

 wire clk_50mhz;
 wire vga_clk, txt_clk;
 wire Clk_CPU, rst,clk_m, mem_w,data_ram_we,GPIOf0000000_we,GPIOe0000000_we,counter_we;
 wire counter_OUT0,counter_OUT1,counter_OUT2;
 wire [1:0]Counter_set;
 wire [4:0] state;
 wire [3:0] digit_anode,blinke;
 wire [4:0] button_out;
 wire [7:0] SW_OK,SW,led_out,LED,SEGMENT; //led_out is current LED light
 wire [9:0] rom_addr,ram_addr;
 wire [21:0]GPIOf0;
 wire [31:0] pc,Inst,addr_bus,Cpu_data2bus,ram_data_out,disp_num;
 wire [31:0]clkdiv,Cpu_data4bus,counter_out,ram_data_in,Peripheral_in;
 wire [3:0] dpdot;

 wire BIU_ready, MIO_ready, BIU_req;
 wire CPU_MIO;
 wire sys_rst=button_out[3];
 wire sys_locked;
 reg Ireq;
 reg Ireq_hold;
 wire Iack;

  clkgen clkgen0
   (// Clock in ports
    .CLK_IN1(sys_clk),      // IN
    // Clock out ports
    .CLK_OUT1(clk_50mhz),     // OUT
	  .CLK_OUT2(vga_clk),     // OUT
    .CLK_OUT3(txt_clk),
    // Status and control signals
    .RESET(1'b0),// IN
    .LOCKED(sys_locked));      // OUT

 assign MIO_ready=~button_out[1];
 assign rst=~sys_locked;
 assign SW2=SW_OK[2];
 assign LED=led_out;
 assign clk_m=~clk_50mhz;
 assign rom_addr=pc[11:2];
 assign AN_SEL=digit_anode;
 assign clk_io=~Clk_CPU;

 seven_seg seven_seg(
 .disp_num(disp_num),
 .clk(clk_50mhz),
 .clr(rst),
 .SW(SW_OK[1:0]),
 .Scanning(clkdiv[19:18]),
 .dpdot(dpdot),
 .SEGMENT(SEGMENT),
 .AN(digit_anode)
 );

 BTN_Anti_jitter BTN_OK (clk_50mhz, BTN,SW, button_out,SW_OK);

 clk_div div_clk(clk_50mhz,
 rst,
 SW2,
 clkdiv,
 Clk_CPU
 ); // Clock divider-


 //++++++++++++++++++single_cycle_Cpu+++++++++++++++++++++++++++++++++++++++++++++++
 /* single_cycle_Cpu_9_mux
 // simple_cpu_more
 // simple_cpu_more_int
 single_cycle_cpu(
 .clk(Clk_CPU),
 .reset(rst),
 // Internal signals:
 .pc_out(pc),
 .inst_in(Inst),
 .mem_w(mem_w),
 .Addr_out(addr_bus),
 .Cpudata_out(Cpu_data2bus),
 .Cpudata_in(Cpu_data4bus)
 // .INT(counter_OUT0)
 );

 ROM_B IRom(
 .clka(clk_m),
 .addra(rom_addr),
 .douta(Inst)
 );

 RAM_B D_Ram (.clka(clk_m),
 .wea(data_ram_we),
 .addra(ram_addr),
 .dina(ram_data_in),
 .douta(ram_data_out)
 ); // Addre_Bus [9 : 0] ,Data_Bus [31 : 0]
 */

 //++++++++++++++++++++++muliti_cycle_cpu+++++++++++++++++++++++++++++++++++++++++++
 Muliti_cycle_Cpu muliti_cycle_cpu(
 .clk(Clk_CPU),
 .reset(rst),
 .MIO_ready(BIU_ready), //MIO_ready

 // Internal signals:
 .pc_out(pc), //Test
 .Inst(Inst), //Test
 .mem_w(mem_w),
 .breq_o(BIU_req),
 .Addr_out(addr_bus),
 .data_out(Cpu_data2bus),
 .data_in(Cpu_data4bus),
 .CPU_MIO(CPU_MIO),
 .Ireq(Ireq),
 .Iack(Iack),
 .state(state), //Test
 .Enable_i(&clkdiv[27:0] | SW2)
 );

 Mem_B RAM_I_D(.clka(clk_m),
 .wea(data_ram_we),
 .addra(ram_addr),
 .dina(ram_data_in),
 .douta(ram_data_out)
 ); // Addre_Bus [9 : 0] ,Data_Bus [31 : 0]

 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 wire [31:0] MIO_data2bus, MIO_data4bus;
 wire [31:0] MIO_addr_bus;
 wire MIO_mem_w;

 wire txt_ena;
 wire txt_wea;
 wire [12:0] txt_addra;
 wire [15:0] txt_dina;
 wire [15:0] txt_douta;
 wire [31:0] gpu_status;

   wire [31:0]          cellram_wb_adr_i;
   wire [31:0]          cellram_wb_dat_i;
   wire [31:0]          cellram_wb_dat_o;
   wire [3:0]           cellram_wb_sel_i;
   wire           cellram_wb_cyc_i;
   wire           cellram_wb_stb_i;
   wire           cellram_wb_we_i;
   wire           cellram_wb_ack_o;

   wire [31:0] 	       		  wb_m0_vcache_adr_i;
   wire [31:0] 	       		  wb_m0_vcache_dat_i;
   wire [3:0] 	       		  wb_m0_vcache_sel_i;
   wire 				  wb_m0_vcache_cyc_i;
   wire 				  wb_m0_vcache_stb_i;
   wire 				  wb_m0_vcache_we_i;
   wire [31:0]  			  wb_m0_vcache_dat_o;
   wire 				  wb_m0_vcache_ack_o;

   wire [31:0] 	       		  wb_m1_cpu_adr_i;
   wire [31:0] 	       		  wb_m1_cpu_dat_i;
   wire [3:0] 	       		  wb_m1_cpu_sel_i;
   wire 				  wb_m1_cpu_cyc_i;
   wire 				  wb_m1_cpu_stb_i;
   wire 				  wb_m1_cpu_we_i;
   wire [31:0] 	       		  wb_m1_cpu_dat_o;
   wire 				  wb_m1_cpu_ack_o;

   wire 				  wb_m1_cpu_gnt;
   wire 				  wb_m0_vcache_gnt;

   wire [7:0]     ps2_wb_dat_i;
   wire [7:0]     ps2_wb_dat_o;
   wire [0:0]     ps2_wb_adr_i;
   wire           ps2_wb_stb_i;
   wire           ps2_wb_we_i;
   wire           ps2_wb_ack_o;

 BIU biu0(
 .clk(clk_50mhz),
 .rst(rst),

 .Cpu_mem_w_i(mem_w),
 .Cpu_req_i(BIU_req),
 .Cpu_data2bus_i(Cpu_data2bus), //data from CPU
 .Cpu_addr_bus_i(addr_bus),
 .Cpu_data4bus_o(Cpu_data4bus), //write to CPU
 .Cpu_ready_o(BIU_ready),

 .MIO_mem_w_o(MIO_mem_w),
 .MIO_data2bus_o(MIO_data2bus), //data from CPU
 .MIO_addr_bus_o(MIO_addr_bus),
 .MIO_data4bus_i(MIO_data4bus), //write to CPU
 .MIO_ready_i(MIO_ready),

 .wb_d_adr_o(wb_m1_cpu_adr_i),
 .wb_d_dat_o(wb_m1_cpu_dat_i),
 .wb_d_sel_o(wb_m1_cpu_sel_i),
 .wb_d_cyc_o(wb_m1_cpu_cyc_i),
 .wb_d_stb_o(wb_m1_cpu_stb_i),
 .wb_d_we_o (wb_m1_cpu_we_i ),
 .wb_d_dat_i(wb_m1_cpu_dat_o),
 .wb_d_ack_i(wb_m1_cpu_ack_o),

 .wb_c_adr_o(ps2_wb_adr_i),
 .wb_c_dat_o(ps2_wb_dat_i),
 .wb_c_stb_o(ps2_wb_stb_i),
 .wb_c_we_o (ps2_wb_we_i ),
 .wb_c_dat_i(ps2_wb_dat_o),
 .wb_c_ack_i(ps2_wb_ack_o),

 .txt_ena(txt_ena),
 .txt_wea(txt_wea),
 .txt_addra(txt_addra),
 .txt_dina(txt_douta),
 .txt_douta(txt_dina),

 .gpu_status(gpu_status)
    );

output			hsync;			// From vchache0 of vcache.v
output [7:0]		rgb;			// From vchache0 of vcache.v
output			vsync;			// From vchache0 of vcache.v

assign hsync = gpu_status[0] ? hsync_vc : hsync_tx;
assign vsync = gpu_status[0] ? vsync_vc : vsync_tx;
assign rgb   = gpu_status[0] ? rgb_vc   : rgb_tx;

wire [7:0] rgb_vc;
wire hsync_vc;
wire vsync_vc;

vcache
     #(
       .vram_adr_base('hf80000)
	   )
		vchache0
(
 .wb_clk_i(clk_50mhz),
 .wb_rst_i(rst),

 //.wb_m0_vcache_gnt(wb_m0_vcache_gnt),
 .wb_adr_o(wb_m0_vcache_adr_i),
 .wb_dat_o(wb_m0_vcache_dat_i),
 .wb_sel_o(wb_m0_vcache_sel_i),
 .wb_cyc_o(wb_m0_vcache_cyc_i),
 .wb_stb_o(wb_m0_vcache_stb_i),
 .wb_we_o (wb_m0_vcache_we_i ),
 .wb_dat_i(wb_m0_vcache_dat_o),
 .wb_ack_i(wb_m0_vcache_ack_o),
		//vga
		// Outputs
		.rgb			(rgb_vc[7:0]),
		.hsync			(hsync_vc),
		.vsync			(vsync_vc),
		// Inputs
		.vga_clk		(vga_clk)
);

wire [7:0] rgb_tx;
wire hsync_tx;
wire vsync_tx;

gpu gpu0 (
    .clr(rst),
    .clka(clk_50mhz),
    .clkb(txt_clk),
    .ena(txt_ena),
    .wea(txt_wea),
    .addra(txt_addra),
    .dina(txt_dina),
    .douta(txt_douta),
    .vgaRed(rgb_tx[2:0]),
    .vgaGreen(rgb_tx[5:3]),
    .vgaBlue(rgb_tx[7:6]),
    .Hsync(hsync_tx),
    .Vsync(vsync_tx)
    );

wire [1:0] 				  cellram_mst_sel;
arbiter arbiter0(
   .wb_clk(clk_50mhz),
   .wb_rst(rst),

   .cellram_mst_sel(cellram_mst_sel),

   .wb_s0_cellram_wb_adr_o(cellram_wb_adr_i),
   .wb_s0_cellram_wb_dat_o(cellram_wb_dat_i),
   .wb_s0_cellram_wb_sel_o(cellram_wb_sel_i),
   .wb_s0_cellram_wb_stb_o(cellram_wb_stb_i),
   .wb_s0_cellram_wb_cyc_o(cellram_wb_cyc_i),
   .wb_s0_cellram_wb_we_o (cellram_wb_we_i ),
   .wb_s0_cellram_wb_dat_i(cellram_wb_dat_o),
   .wb_s0_cellram_wb_ack_i(cellram_wb_ack_o),

		 .wb_m0_vcache_dat_o	(wb_m0_vcache_dat_o[31:0]),
		 .wb_m0_vcache_ack_o	(wb_m0_vcache_ack_o),
		 .wb_m0_vcache_adr_i	(wb_m0_vcache_adr_i[31:0]),
		 .wb_m0_vcache_dat_i	(wb_m0_vcache_dat_i[31:0]),
		 .wb_m0_vcache_sel_i	(wb_m0_vcache_sel_i[3:0]),
		 .wb_m0_vcache_cyc_i	(wb_m0_vcache_cyc_i),
		 .wb_m0_vcache_stb_i	(wb_m0_vcache_stb_i),
		 .wb_m0_vcache_we_i	(wb_m0_vcache_we_i),

		 .wb_m1_cpu_dat_o	(wb_m1_cpu_dat_o[31:0]),
		 .wb_m1_cpu_ack_o	(wb_m1_cpu_ack_o),
		 .wb_m1_cpu_adr_i	(wb_m1_cpu_adr_i[31:0]),
		 .wb_m1_cpu_dat_i	(wb_m1_cpu_dat_i[31:0]),
		 .wb_m1_cpu_sel_i	(wb_m1_cpu_sel_i[3:0]),
		 .wb_m1_cpu_cyc_i	(wb_m1_cpu_cyc_i),
		 .wb_m1_cpu_stb_i	(wb_m1_cpu_stb_i),
		 .wb_m1_cpu_we_i	(wb_m1_cpu_we_i)

		 //.wb_m1_cpu_gnt		(wb_m1_cpu_gnt),
		 //.wb_m0_vcache_gnt	(wb_m0_vcache_gnt)
);

   cellram_ctrl
     /* Use the simple flash interface */
     #(
       .cellram_read_cycles(4), // 70ns in cycles, at 50MHz 4=80ns
       .cellram_write_cycles(4)) // 70ns in cycles, at 50Mhz 4=80ns
     cellram_ctrl0
     (
      .wb_clk_i(clk_50mhz),
      .wb_rst_i(rst),

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

 MIO_BUS MIO_interface( .clk(clk_50mhz),
 .rst(rst),
 .BTN(botton_out),
 .SW(SW_OK),
 .mem_w(MIO_mem_w),
 .Cpu_data2bus(MIO_data2bus), //data from CPU
 .addr_bus(MIO_addr_bus),
 .ram_data_out(ram_data_out),
 .led_out(led_out),
 .counter_out(counter_out),
 .counter0_out(counter_OUT0),
 .counter1_out(counter_OUT1),
 .counter2_out(counter_OUT2),
 .Cpu_data4bus(MIO_data4bus), //write to CPU
 .ram_data_in(ram_data_in),   //from CPU write to Memory
 .ram_addr(ram_addr),         //Memory Address signals
 .data_ram_we(data_ram_we),
 .GPIOf0000000_we(GPIOf0000000_we),
 .GPIOe0000000_we(GPIOe0000000_we),
 .counter_we(counter_we),
 .Peripheral_in(Peripheral_in)

 );

inout ps2_clk, ps2_dat;
wire  ps2_clk, ps2_dat;
wire  ps2_irq_o;
reg ps2_clk_trig, ps2_dat_trig;

always @(posedge clk_50mhz or posedge rst) begin
  if(rst) begin
    ps2_clk_trig <= 0;
    ps2_dat_trig <= 0;
  end else if(&clkdiv[20:0]) begin
    ps2_clk_trig <= ~ps2_clk;
    ps2_dat_trig <= ~ps2_dat;
  end else begin
    ps2_clk_trig <= ps2_clk_trig | ~ps2_clk;
    ps2_dat_trig <= ps2_dat_trig | ~ps2_dat;
  end
end

ps2_wb ps2_wb0 (
    .wb_clk_i(clk_50mhz),
    .wb_rst_i(rst),
    .wb_dat_i(ps2_wb_dat_i),
    .wb_dat_o(ps2_wb_dat_o),
    .wb_adr_i(ps2_wb_adr_i),
    .wb_stb_i(ps2_wb_stb_i),
    .wb_we_i (ps2_wb_we_i),
    .wb_ack_o(ps2_wb_ack_o),
    .irq_o(ps2_irq_o),
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat)
    );

 //------Peripheral Driver-----------------------------------
 /* GPIO out use on LEDs & Counter-Controler read and write addre=f0000000-ffffffff0
*/
 led_Dev_IO Device_led( clk_io,
 rst,
 GPIOf0000000_we,
 Peripheral_in,
 Counter_set,
 led_out,
 GPIOf0
 );
 /* GPIO out use on 7-seg display & CPU state display addre=e0000000-efffffff */
 seven_seg_Dev_IO Device_7seg( .clk(clk_io),
 .rst(rst),
 .GPIOe0000000_we(GPIOe0000000_we),
 .Test(SW_OK[7:5]),
 .disp_cpudata(Peripheral_in), //CPU data output
 .Test_data0({2'b00,pc[31:2]}), //pc[31:2]
 .Test_data1(counter_out), //counter
 .Test_data2(Inst), //Inst
 .Test_data3(addr_bus), //addr_bus
 .Test_data4(Cpu_data2bus), //Cpu_data2bus;
 .Test_data5(Cpu_data4bus), //Cpu_data4bus;
 .Test_data6(pc), //pc;
 .disp_num(disp_num)
 );

 Counter_x Counter_xx(.clk(clk_io),
 .rst(rst),
 .clk0(clkdiv[9]),
 .clk1(clkdiv[10]),
 .clk2(clkdiv[10]),
 .counter_we(counter_we),
 .counter_val(Peripheral_in),
 .counter_ch(Counter_set),

 .counter0_OUT(counter_OUT0),
 .counter1_OUT(counter_OUT1),
 .counter2_OUT(counter_OUT2),
 .counter_out(counter_out)
 );


 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 // assign AN_SEL=(SW_OK[3]) ? digit_anode : digit_anode|(blinke&{clkdiv[24],clkdiv[24],clkdiv[24],clkdiv[24]});

 always @(posedge Clk_CPU or posedge rst) begin : proc_
   if(rst) begin
     Ireq <= 0;
   end else if(Iack) begin
     Ireq <= 0;
   end else begin
     Ireq_hold <= ps2_irq_o;
     if(!Ireq_hold && ps2_irq_o) Ireq <= 1;
   end
 end

//assign dpdot = {MIO_ready, BIU_req, mem_w, BIU_ready};
//assign dpdot = {cellram_mst_sel, mem_w, BIU_ready};//vga_gnt, cpu_gnt
assign dpdot = {Ireq, Iack | ps2_irq_o, mem_w | ps2_clk_trig, BIU_ready | ps2_dat_trig};

 endmodule
