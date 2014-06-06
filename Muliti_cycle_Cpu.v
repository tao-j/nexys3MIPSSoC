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
 state,
 Ireq,
 Iack,
 Enable_i
 );


 input clk,reset,MIO_ready,Ireq,Enable_i;
 output [31:0] pc_out;
 output [31:0] Inst;
 output mem_w, breq_o, CPU_MIO,Iack;
 output [31:0] Addr_out;
 output [31:0] data_out;
 output [4:0] state;
 input [31:0] data_in;

 wire [31:0] Inst,Addr_out,PC_Current,pc_out,data_in,data_out;
 wire [15:0] imm;
 wire [4:0] state;
 wire [2:0] ALU_operation,MemtoReg,PCSource;

 wire [1:0] RegDst,ALUSrcB,IntCause;
 wire breq_o,CPU_MIO,MemRead,MemWrite,IorD,IRWrite,RegWrite,ALUSrcA,PCWrite,PCWriteCond,Beq,CauseWrite,EPCWrite,Co0Write;
 wire reset,MIO_ready, mem_w,zero,overflow,Ireq,Iack,Enable_i;

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
 .Beq(Beq),
 .CauseWrite(CauseWrite),
 .IntCause(IntCause),
 .EPCWrite(EPCWrite),
 .Co0Write(Co0Write),
 .Ireq(Ireq),
 .Iack(Iack),
 .Enable_i(Enable_i)
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
 .overflow(overflow),

 .CauseWrite(CauseWrite),
 .IntCause(IntCause),
 .EPCWrite(EPCWrite),
 .Co0Write(Co0Write)
 );


 //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++==
 assign mem_w=MemWrite&&(~MemRead);
 assign breq_o=MemRead|MemWrite;
 assign pc_out=PC_Current;

 endmodule
