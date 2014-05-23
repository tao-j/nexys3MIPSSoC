`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    20:08:52 05/15/2014
// Design Name:
// Module Name:    Muliti_cycle_Cpu
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
 module Muliti_cycle_Cpu( clk,
 reset,
 MIO_ready,

 pc_out, //TEST
 Inst, //TEST
 mem_w,
 Addr_out,
 data_out,
 data_in,
 breq_o,
 CPU_MIO,
 state
 );


 input clk,reset,MIO_ready;
 output [31:0] pc_out;
 output [31:0] Inst;
 output mem_w, breq_o, CPU_MIO;
 output [31:0] Addr_out;
 output [31:0] data_out;
 output [4:0] state;
 input [31:0] data_in;

 wire [31:0] Inst,Addr_out,PC_Current,pc_out,data_in,data_out;
 wire [15:0] imm;
 wire [4:0] state;
 wire [2:0] ALU_operation;

 wire [1:0] RegDst,MemtoReg,ALUSrcB,PCSource;
 wire breq_o,CPU_MIO,MemRead,MemWrite,IorD,IRWrite,RegWrite,ALUSrcA,PCWrite,PCWriteCond,Beq;
 wire reset,MIO_ready, mem_w,zero,overflow;



 // assign rst=reset;
 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=

 ctrl x_ctrl(.clk(clk),
 .reset(reset),
 .Inst_in(Inst),
 .zero(zero),
 .overflow(overflow),
 .MIO_ready(MIO_ready),
 .MemRead(MemRead),
 .MemWrite(MemWrite),
 .ALU_operation(ALU_operation),
 .state_out(state),

 .CPU_MIO(CPU_MIO),
 .IorD(IorD),
 .IRWrite(IRWrite),
 .RegDst(RegDst),
 .RegWrite(RegWrite),
 .MemtoReg(MemtoReg),
 .ALUSrcA(ALUSrcA),
 .ALUSrcB(ALUSrcB),
 .PCSource(PCSource),
 .PCWrite(PCWrite),
 .PCWriteCond(PCWriteCond),
 .Beq(Beq)
 );

 data_path x_datapath(.clk(clk),
 .reset(reset),
 .MIO_ready(MIO_ready),

 .IorD(IorD),
 .IRWrite(IRWrite),
 .RegDst(RegDst),
 .RegWrite(RegWrite),
 .MemtoReg(MemtoReg),
 .ALUSrcA(ALUSrcA),
 .ALUSrcB(ALUSrcB),
 .PCSource(PCSource),
 .PCWrite(PCWrite),
 .PCWriteCond(PCWriteCond),
 .Beq(Beq),

 .ALU_operation(ALU_operation),
 .PC_Current(PC_Current),
 .data2CPU(data_in),
 .Inst_R(Inst),
 .data_out(data_out),
 .M_addr(Addr_out),
 .zero(zero),
 .overflow(overflow)
 );


 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++==
 assign mem_w=MemWrite&&(~MemRead);
 assign breq_o=MemRead|MemWrite;
 assign pc_out=PC_Current;

 endmodule
