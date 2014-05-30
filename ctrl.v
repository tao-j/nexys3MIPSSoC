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

module ctrl(clk,
	reset,
	Inst_in,
	zero,
	overflow,
	MIO_ready,
	MemRead,
	MemWrite,
	ALU_operation,
	state_out,

	CPU_MIO,
	IorD,
	IRWrite,
	RegDst,
	RegWrite,
	MemtoReg,
	ALUSrcA,
	ALUSrcB,
	PCSource,
	PCWrite,
	PCWriteCond,
	Beq,
	CauseWrite,
	IntCause,
	EPCWrite,
	Co0Write,
	Ireq,
	Iack
	);

input clk,reset;
input zero,overflow,MIO_ready,Ireq;
input [31:0] Inst_in;
output [2:0] ALU_operation,MemtoReg,PCSource;
output CPU_MIO,MemRead,MemWrite,IorD,IRWrite,RegWrite,ALUSrcA,PCWrite,PCWriteCond,Beq,CauseWrite,IntCause,EPCWrite,Iack,Co0Write;
output [4:0] state_out;
output [1:0] RegDst,ALUSrcB;

wire [4:0] state_out;
wire reset,MIO_ready,Ireq;
reg CPU_MIO,MemRead,MemWrite,IorD,IRWrite,RegWrite,ALUSrcA,PCWrite,PCWriteCond,Beq,CauseWrite,EPCWrite,Iack,Co0Write;
reg [1:0] RegDst,ALUSrcB,IntCause;
reg [2:0] ALU_operation, MemtoReg, PCSource;
reg [4:0] state;

parameter IF = 5'b00000, ID=5'b00001, EX_R= 5'b00010, EX_Mem=5'b00011, EX_I=5'b00100,
	Lui_WB=5'b00101, EX_beq=5'b00110, EX_bne= 5'b00111, EX_jr= 5'b01000, EX_JAL=5'b01001,
	Exe_J = 5'b01010, MEM_RD=5'b01011, MEM_WD= 5'b01100, WB_R= 5'b01101, WB_I=5'b01110,
	WB_LW=5'b01111, EX_jalr=5'b10000, EX_INT=5'b10001, EX_ERET=5'b10010, Error=5'b11111;
parameter AND=3'b000, OR=3'b001, ADD=3'b010, SUB=3'b110, NOR=3'b100, SLT=3'b111, XOR=3'b011, SRL=3'b101;

`define CPU_ctrl_signals {PCSource[2],MemtoReg[2],Co0Write,CauseWrite,EPCWrite,PCWrite,PCWriteCond,IorD,MemRead,MemWrite,IRWrite,MemtoReg[1:0],PCSource[1:0],ALUSrcB,ALUSrcA,RegWrite,RegDst,CPU_MIO}
// EX_INT                                                           0,       1,      1,          0,   0,      0,       0,      0,           00,           11,     01,      0,       0,    00,      0
// EX_ERET                          1,          0,       0,         0,       0,      1,          0,   0,      0,       0,      0,           00,           00,     11,      0,       0,    00,      0
// EX_JM                                                                             1,          0,   0,      0,       0,      0,           00,           10,     11,      0,       0,    00,      0
// IF                                                                         1,          0,   0,      1,       0,      1,      00,      00,     01,      0,       0,    00,      1
// IF                                                                         0,          0,   0,      0,       0,      0,      00,      00,     11,      0,       0,    00,      0
// 1 0 0 0 0 0 10 10 00 0 0 00 0
//
`define nSignals 22

assign state_out=state;

always @ (posedge clk or posedge reset)
if (reset==1) begin
	`CPU_ctrl_signals<=`nSignals'h12821; //12821
	ALU_operation<=ADD;
	state <= IF;
	Iack <= 0;
end
else begin
	Iack <= 0;
	case (state)
		IF: begin
			if(MIO_ready) begin
				if(Ireq)begin
					Iack <= 1;
					`CPU_ctrl_signals<=`nSignals'h701A0;
					ALU_operation<=SUB;
					state <= EX_INT;
				end else begin
					`CPU_ctrl_signals<=`nSignals'h00060;
					ALU_operation<=ADD;
					state <= ID;
				end
			end else begin
				state <=IF;
				`CPU_ctrl_signals<=`nSignals'h12821;
			end
		end

		ID: begin

			case (Inst_in[31:26])
				6'b000000:begin //R-type OP
					`CPU_ctrl_signals<=`nSignals'h00010;
					state <= EX_R;
					case (Inst_in[5:0])
						6'b100000: ALU_operation<=ADD;
						6'b100010: ALU_operation<=SUB;
						6'b100100: ALU_operation<=AND;
						6'b100101: ALU_operation<=OR;
						6'b100111: ALU_operation<=NOR;
						6'b101010: ALU_operation<=SLT;
						6'b000010: ALU_operation<=SRL; //shfit 1bit right
						6'b000000: ALU_operation<=XOR;
						6'b001000: begin
							`CPU_ctrl_signals<=`nSignals'h10010;
							ALU_operation<=ADD; state <= EX_jr; end
						6'b001001:begin
							`CPU_ctrl_signals<=`nSignals'h00208;  //rd << current_pc==ori_pc+4
							ALU_operation<=ADD; state <=EX_jalr;end
						default: ALU_operation <= ADD;
					endcase
				end

				6'b100011:begin //Lw
					`CPU_ctrl_signals<=`nSignals'h00050;
					ALU_operation<=ADD;
					state <= EX_Mem;
				end

				6'b101011:begin //Sw
					`CPU_ctrl_signals<=`nSignals'h00050;
					ALU_operation<=ADD;
					state <= EX_Mem;
				end

				6'b000010:begin //Jump
					`CPU_ctrl_signals<=`nSignals'h10160;
					state <= Exe_J;
				end

				6'b000100:begin //Beq
					`CPU_ctrl_signals<=`nSignals'h08090; Beq<=1;
					ALU_operation<= SUB; state <= EX_beq; end

				6'b000101:begin //Bne
					`CPU_ctrl_signals<=`nSignals'h08090; Beq<=0;
					ALU_operation<= SUB; state <= EX_bne; end

				6'b000011:begin //Jal
					`CPU_ctrl_signals<=`nSignals'h1076c;
					state <= EX_JAL;
				end

				6'b001000:begin //Addi
					`CPU_ctrl_signals<=`nSignals'h00050;
					ALU_operation <= ADD;
					state <= EX_I;
				end

				6'b001100:begin //Andi
					`CPU_ctrl_signals<=`nSignals'h00050;
					ALU_operation <= AND;
					state <= EX_I;
				end

				6'b001101:begin //Ori
					`CPU_ctrl_signals<=`nSignals'h00050;
					ALU_operation <= OR;
					state <= EX_I;
				end

				6'b001110:begin //Xori
					`CPU_ctrl_signals<=`nSignals'h00050;
					ALU_operation <= XOR;
					state <= EX_I;
				end

				6'b001010:begin //Slti
					`CPU_ctrl_signals<=`nSignals'h00050;
					ALU_operation <= SLT;
					state <= EX_I;
				end

				6'b001111:begin //Lui
					`CPU_ctrl_signals<=`nSignals'h00468;
					state <= Lui_WB;
				end

				6'b010000: if(Inst_in[25]) begin //COP0
					case (Inst_in[5:0])
						6'b011000: begin
							`CPU_ctrl_signals<=`nSignals'h210060;
							state <= EX_ERET;
						end
						default: begin
							`CPU_ctrl_signals<=`nSignals'h12821;
							state <= Error;
						end
					endcase
				end

				default: begin
					`CPU_ctrl_signals<=`nSignals'h12821;
					state <= Error;
				end

			endcase
		end //end ID

		EX_jalr:begin
			`CPU_ctrl_signals<=`nSignals'h10018;
			ALU_operation<=ADD; state <= EX_jr;
		end

		EX_Mem:begin
			if(Inst_in[31:26]==6'b100011)begin
				`CPU_ctrl_signals<=`nSignals'h06051; state <= MEM_RD; end
			else if(Inst_in[31:26]==6'b101011)begin
				`CPU_ctrl_signals<=`nSignals'h05051; state <= MEM_WD; end
		end

		MEM_RD:begin
			if(MIO_ready)begin
				`CPU_ctrl_signals<=`nSignals'h00208; state <= WB_LW; end
			else begin
				state <=MEM_RD; `CPU_ctrl_signals<=`nSignals'h06050; end
		end

		MEM_WD:begin
			if(MIO_ready)begin
				`CPU_ctrl_signals<=`nSignals'h12821;
				ALU_operation<=ADD; state <= IF; end
			else begin
				state <=MEM_WD; `CPU_ctrl_signals<=`nSignals'h05050; end
		end

		WB_LW:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <=IF; end

		EX_R:begin
			`CPU_ctrl_signals<=`nSignals'h0001a; state <= WB_R; end

		EX_I:begin
			`CPU_ctrl_signals<=`nSignals'h00058; state <= WB_I; end

		WB_R:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		WB_I:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		Exe_J:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		EX_bne:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		EX_beq:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		EX_jr:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		EX_JAL:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		Lui_WB:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

	    EX_INT:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

	    EX_ERET:begin
			`CPU_ctrl_signals<=`nSignals'h12821;
			ALU_operation<=ADD; state <= IF; end

		Error: state <= Error;

		default: begin
			`CPU_ctrl_signals<=`nSignals'h12821; Beq<=0;
			ALU_operation<=ADD; state <= Error; end
	endcase
end

endmodule
