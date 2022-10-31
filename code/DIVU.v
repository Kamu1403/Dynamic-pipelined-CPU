`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/10 22:13:17
// Design Name: 
// Module Name: DIVU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// �������˻������ƶ���һλ -unknown
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DIVU(
    input [31:0] dividend,
    input [31:0] divisor,
    input start,
    input clock,
    input reset,    //active-high
    output [31:0] q,
    output [31:0] r,
    output reg busy,
    output reg finish,

    //for program in
    input cpu_stall
    );
    
    reg [5:0] cnt;
    reg [32:0] inner_sr;
    reg [31:0] rmdr;    //remainder
    reg [31:0] qtnt;    //quotient
    reg sign;
    
    wire [32:0] inner_complement_sr;
    assign inner_complement_sr=~inner_sr+1'b1;
    wire [32:0] add;
    assign add={rmdr,qtnt[31]}+(sign?inner_complement_sr:inner_sr);

    assign r=rmdr;
    assign q=qtnt;
    
    always@(posedge(clock) or posedge(reset)) begin
        if(reset==1) begin
            cnt<=0;
            busy<=0;
            rmdr<=0;
            qtnt<=0;
            inner_sr<=0;
            sign<=0;
            finish<=0;
        end
        else begin
            if(start) begin
                rmdr<=0;
                qtnt<=dividend;
                inner_sr<={1'b0,divisor};
                busy<=1;
                cnt<=1;
                sign<=1;
                finish<=0;
            end
            else if(busy) begin
                if (!cpu_stall) begin
                    case(cnt)
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31: begin
                            {rmdr,qtnt}<={add[31:0],qtnt[30:0],~add[32]};
                            sign<=~add[32];
                            cnt<=cnt+1;
                            finish<=0;
                        end
                        32: begin
                            {rmdr,qtnt}<={add[31:0],qtnt[30:0],~add[32]}+(add[32]?{inner_sr[31:0],32'b0}:64'b0);
                            sign<=~add[32];
                            cnt<=cnt+1;
                            busy<=0;
                            finish<=1;
                        end
                        default: begin end
                    endcase
                end
            end
            else
                finish<=0;
        end
    end
endmodule
