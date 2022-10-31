`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/19 16:56:27
// Design Name: 
// Module Name: cpu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_tb();
    reg clk,reset;
    wire [7:0] o_seg,o_sel;
    reg cpu_stall,switch_pc_d;
    seg7_top top_inst(
        clk,
	    reset,
	    o_seg,
	    o_sel,
        cpu_stall,
        switch_pc_d
    );

    initial begin
        clk=0;
        reset=1;
        cpu_stall=0;
        switch_pc_d=0;
        #1000;
        reset=0;
    end

    always begin
        #5;
        clk=~clk;
    end
endmodule

