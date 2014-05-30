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

module MIO_BUS(clk,
					rst,
					BTN,
					SW,
					mem_w,
					Cpu_data2bus,									//data from CPU
					addr_bus,
					ram_data_out,
					led_out,
					counter_out,
					counter0_out,
					counter1_out,
					counter2_out,

					Cpu_data4bus,									//write to CPU
					ram_data_in,								//from CPU write to Memory
					ram_addr,									//Memory Address signals
					data_ram_we,
					GPIOf0000000_we,
					GPIOe0000000_we,
					counter_we,
					Peripheral_in
					);


input clk,rst,mem_w;
input counter0_out,counter1_out,counter2_out;
input [3:0]BTN;
input [7:0]SW,led_out;
input [31:0] Cpu_data2bus,ram_data_out,addr_bus,counter_out;
output data_ram_we,GPIOe0000000_we,GPIOf0000000_we,counter_we;
output [31:0]Cpu_data4bus,ram_data_in,Peripheral_in;
output [9:0] ram_addr;




endmodule
