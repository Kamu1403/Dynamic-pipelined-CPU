`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/30 08:40:33
// Design Name: 
// Module Name: MULTU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 1.01 - multi periods
// Additional Comments:
// testing
//////////////////////////////////////////////////////////////////////////////////

module MULTU(
    input clk,
    input reset,    //active high
    input start,
    input [31:0] a, //multiplicand
    input [31:0] b, //multiplier
    output [63:0] z,
    output reg busy,
    output reg finish,

    //for program in
    input cpu_stall
    );
    
    reg [5:0] cnt;
    reg [31:0] multa,multb;
    reg [31:0] multpart;
    reg shiftr;
    wire cf;
    wire [31:0] add;
    
    assign z={multpart,multb};
    assign {cf,add}={1'b0,multpart}+{1'b0,(multb[0]?multa:32'b0)};
    always@(posedge clk or posedge reset)
    begin
        if(reset) begin
            cnt<=0;
            multa<=0;
            multb<=0;
            multpart<=0;
            busy<=0;
            finish<=0;
        end
        else begin
            if(start) begin
                cnt<=1;
                multa<=a;
                multb<=b;
                multpart<=0;
                busy<=1;
                finish<=0;
            end else if(busy) begin
                if (!cpu_stall) begin
                    case(cnt)
                        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31: begin
                            {multpart,multb,shiftr}<={cf,add,multb};
                            cnt<=cnt+1;
                            finish<=0;
                        end
                        32: begin
                            {multpart,multb,shiftr}<={cf,add,multb};
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