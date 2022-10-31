`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/23 19:52:25
// Design Name: 
// Module Name: CP0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// eret excluded from interruption?
// intr
// 32'h0000_0400; //reg_cause?
// posedge write
// Revision 1.01 - simplify
// remove intr,mfc0,timer_int
// Additional Comments:
// a liitle bug may appear in cp0_reg[12-14] exception write
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module CP0(
    input clk,
    input rst,
    input mtc0, //cpu instruction mtc0,high-active
    input [31:0] pc,

    input [4:0] waddr, //specifies CP0 reg to write
    input [31:0] wdata, //data from GP reg to place CP0 reg
    input exception,    //instruction syscall,break,teq,high-active
    input eret, //instruction eret,high-active
    input [4:0] cause,
    
    input [4:0] raddr, //specifies CP0 reg to read
    output [31:0] rdata,    //data from CP0 reg for GP reg
    output [31:0] status,   //mask,low-active
    output [31:0] exc_addr,  //address for PC at the beginning of an exception
    output [31:0] intr_addr    //exception check
    );
    
    reg [31:0] cp0_reg[31:0];   //regfiles
    wire [31:0] status_left,status_right;
    assign status_left=cp0_reg[12]<<5;
    assign status_right=cp0_reg[12]>>5;
    assign status=cp0_reg[12];
    assign exc_addr=cp0_reg[14];
    assign rdata=cp0_reg[raddr];

    wire timer_int=exception&&((cause[3:0]==`EXC_SYSCALL&&status[1]&&status[0])||(cause[3:0]==`EXC_BREAK&&status[2]&&status[0])||(cause[3:0]==`EXC_TEQ&&status[3]&&status[0]));
    assign intr_addr=timer_int?32'h00400004:pc;

    always@(posedge clk,posedge rst) begin
        if(rst) begin
            cp0_reg[0]<=32'b0;
            cp0_reg[1]<=32'b0;
            cp0_reg[2]<=32'b0;
            cp0_reg[3]<=32'b0;
            cp0_reg[4]<=32'b0;
            cp0_reg[5]<=32'b0;
            cp0_reg[6]<=32'b0;
            cp0_reg[7]<=32'b0;
            cp0_reg[8]<=32'b0;
            cp0_reg[9]<=32'b0;
            cp0_reg[10]<=32'b0;
            cp0_reg[11]<=32'b0;
            cp0_reg[12]<=32'h0000_000f;         //reg_status
            cp0_reg[13]<=32'h0;         //reg_cause
            cp0_reg[14]<=32'h0;         //reg_epc
            cp0_reg[15]<=32'b0;
            cp0_reg[16]<=32'b0;
            cp0_reg[17]<=32'b0;
            cp0_reg[18]<=32'b0;
            cp0_reg[19]<=32'b0;
            cp0_reg[20]<=32'b0;
            cp0_reg[21]<=32'b0;
            cp0_reg[22]<=32'b0;
            cp0_reg[23]<=32'b0;
            cp0_reg[24]<=32'b0;
            cp0_reg[25]<=32'b0;
            cp0_reg[26]<=32'b0;
            cp0_reg[27]<=32'b0;
            cp0_reg[28]<=32'b0;
            cp0_reg[29]<=32'b0;
            cp0_reg[30]<=32'b0;
            cp0_reg[31]<=32'b0;
        end
        else if(eret) begin
            cp0_reg[12]<=status_right;
        end
        else if(exception) begin
            case(cause[3:0])
                `EXC_SYSCALL: if(status[1]&status[0]) begin  //syscall
                    cp0_reg[12]<=status_left;
                    cp0_reg[13][6:2]=cause;
                    cp0_reg[14]<=pc-32'h4;
                end
                `EXC_BREAK: if(status[2]&status[0]) begin  //break
                    cp0_reg[12]<=status_left;
                    cp0_reg[13][6:2]=cause;
                    cp0_reg[14]<=pc-32'h4;
                end
                `EXC_TEQ: if(status[3]&status[0]) begin  //teq
                    cp0_reg[12]<=status_left;
                    cp0_reg[13][6:2]=cause;
                    cp0_reg[14]<=pc-32'h4;
                end 
                default: begin end
            endcase
        end
        else if(mtc0) begin
            cp0_reg[waddr]<=wdata;
        end
        else begin end
    end
endmodule
