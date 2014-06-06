`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:37:14 06/06/2014
// Design Name:   Muliti_cycle_Cpu
// Module Name:   /home/gongbingchen/Documents/nexys3MIPSSoC/cpu_int_t.v
// Project Name:  GBC_P3
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Muliti_cycle_Cpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cpu_int_t;

	// Inputs
	reg clk;
	reg reset;
	reg MIO_ready;
	reg [31:0] data_in;
	reg Ireq_sel;
    reg Ireq;
	reg Ireq_hold;
	
	// Outputs
	wire [31:0] pc_out;
	wire [31:0] Inst;
	wire mem_w;
	wire [31:0] Addr_out;
	wire [31:0] data_out;
	wire breq_o;
	wire CPU_MIO;
	wire [4:0] state;
	wire Iack;
	
	// Instantiate the Unit Under Test (UUT)
	Muliti_cycle_Cpu uut (
		.clk(clk), 
		.reset(reset), 
		.MIO_ready(MIO_ready), 
		.pc_out(pc_out), 
		.Inst(Inst), 
		.mem_w(mem_w), 
		.Addr_out(Addr_out), 
		.data_out(data_out), 
		.data_in(data_in), 
		.breq_o(breq_o), 
		.CPU_MIO(CPU_MIO), 
		.state(state), 
		.Ireq(Ireq), 
		.Iack(Iack)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		MIO_ready = 0;
		Ireq_sel = 0;
		
		#10
		
		reset = 0;
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		MIO_ready = 1;
		Ireq_sel = 1;

	end
	
 always @(posedge clk or posedge reset) begin : proc_
   if(reset) begin
     Ireq <= 0;
     data_in = 32'h00000020;
   end else if(Iack) begin
     Ireq <= 0;
	 data_in = 32'h42000018;
   end else begin
     Ireq_hold <= Ireq_sel;
    if(!Ireq_hold && Ireq_sel) Ireq <= 1;
   end
 end

    always #1 clk=~clk;
endmodule
