`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/14 17:08:02
// Design Name: 
// Module Name: regfile
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
// posedge write
//////////////////////////////////////////////////////////////////////////////////


module regfile(
    input clk,  //posedge write-active
    input rst,  //active-high asynchronous
    input we,   //high:write low:read
    input [31:0] raddr1,
    input [31:0] raddr2,
    output [31:0] rdata1,
    output [31:0] rdata2,
    input [31:0] waddr,
    input [31:0] wdata,

    //for program out
    output [31:0] reg_16
    );
    
    (* KEEP = "{TRUE|FALSE|SOFT}" *) reg [31:0] array_reg[31:0]; //regfiles

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            array_reg[0]<=32'b0;
            array_reg[1]<=32'b0;
            array_reg[2]<=32'b0;
            array_reg[3]<=32'b0;
            array_reg[4]<=32'b0;
            array_reg[5]<=32'b0;
            array_reg[6]<=32'b0;
            array_reg[7]<=32'b0;
            array_reg[8]<=32'b0;
            array_reg[9]<=32'b0;
            array_reg[10]<=32'b0;
            array_reg[11]<=32'b0;
            array_reg[12]<=32'b0;
            array_reg[13]<=32'b0;
            array_reg[14]<=32'b0;
            array_reg[15]<=32'b0;
            array_reg[16]<=32'b0;
            array_reg[17]<=32'b0;
            array_reg[18]<=32'b0;
            array_reg[19]<=32'b0;
            array_reg[20]<=32'b0;
            array_reg[21]<=32'b0;
            array_reg[22]<=32'b0;
            array_reg[23]<=32'b0;
            array_reg[24]<=32'b0;
            array_reg[25]<=32'b0;
            array_reg[26]<=32'b0;
            array_reg[27]<=32'b0;
            array_reg[28]<=32'b0;
            array_reg[29]<=32'b0;
            array_reg[30]<=32'b0;
            array_reg[31]<=32'b0;
        end
        else if(we&&waddr) begin    //cannot modify $0
            array_reg[waddr]<=wdata;
        end
    end

    assign rdata1=array_reg[raddr1];
    assign rdata2=array_reg[raddr2];

    //for program out
    assign reg_16=array_reg[16];
endmodule
