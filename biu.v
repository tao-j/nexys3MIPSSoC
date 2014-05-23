`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    21:32:02 05/16/2014
// Design Name:
// Module Name:    biu
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
module BIU(
input wire clk,
input wire rst,

 //
 // WISHBONE interface
 //
 input  wire      wb_ack_i, // normal termination
 input  wire      wb_err_i, // termination w/ error
 input  wire      wb_rty_i, // termination w/ retry
 input  wire [31:0]       wb_dat_i, // input data bus
 output reg      wb_cyc_o, // cycle valid output
 output reg [31:0]      wb_adr_o, // address bus outputs
 output reg      wb_stb_o, // strobe output
 output reg      wb_we_o,  // indicates write transfer
 output reg [3:0]       wb_sel_o, // byte select outputs
 output reg [31:0]      wb_dat_o, // output data bus

input wire Cpu_mem_w_i,
input wire [31:0] Cpu_data2bus_i,                                   //data from CPU
input wire Cpu_req_i,
input wire [31:0] Cpu_addr_bus_i,
output reg [31:0] Cpu_data4bus_o,
output reg Cpu_ready_o,

output reg MIO_mem_w_o,
output reg [31:0] MIO_data2bus_o,                                   //data from CPU
output reg [31:0] MIO_addr_bus_o,
input wire [31:0] MIO_data4bus_i,
input wire MIO_ready_i
    );

always @(*) begin
    MIO_data2bus_o <= Cpu_data2bus_i;
    wb_dat_o       <= Cpu_data2bus_i;

    MIO_addr_bus_o <= Cpu_addr_bus_i;
    wb_adr_o       <= Cpu_addr_bus_i;
end

always @(*) begin
    wb_sel_o <= 4'b1111;
end

always @(*) begin
    MIO_mem_w_o    <= 0;
    wb_we_o        <= 0;
    Cpu_data4bus_o <= 0;
    Cpu_ready_o    <= 0;
    wb_cyc_o       <= 0;
    wb_stb_o       <= 0;
    case(Cpu_addr_bus_i[31:28])
        4'h3: begin
            wb_we_o        <= Cpu_mem_w_i;
            Cpu_data4bus_o <= wb_dat_i;
            Cpu_ready_o    <= wb_ack_i;
            wb_cyc_o       <= Cpu_req_i;
            wb_stb_o       <= Cpu_req_i;
        end
        default: begin
            MIO_mem_w_o    <= Cpu_mem_w_i;
            Cpu_data4bus_o <= MIO_data4bus_i;
            Cpu_ready_o    <= MIO_ready_i;
        end
    endcase
end

endmodule
