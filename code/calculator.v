`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 12:29:39
// Design Name: 
// Module Name: calculator
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
// posedge calculate
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module calculator(
    input clk,
    input [31:0] a, //multiplicand/dividend
    input [31:0] b, //multiplier/divisor
    input [1:0] calc,
    input reset,      //high-active,at the beginning of test
    input ena,  //high-active
    output reg [31:0] oLO,
    output reg [31:0] oHI,
    output reg sum_finish,

    //for program in
    input cpu_stall
    );

    wire cal_clk=~clk;
    reg start,busy;
    wire busyDivu,busyDiv,busyMult,busyMultu,finishDivu,finishDiv,finishMult,finishMultu;
    wire [63:0] oMult,oMultu,oDiv,oDivu;

    reg [1:0] inner_calc;
    always @(negedge clk) begin
        inner_calc<=calc;
    end

    always @(*) begin
        case (inner_calc)
            `CAL_MULTU: begin
                oLO<=oMultu[31:0];
                oHI<=oMultu[63:32];
                sum_finish<=finishMultu;
            end
            `CAL_MULT: begin
                oLO<=oMult[31:0];
                oHI<=oMult[63:32];
                sum_finish<=finishMult;
            end
            `CAL_DIVU: begin
                oLO<=oDivu[31:0];
                oHI<=oDivu[63:32];
                sum_finish<=finishDivu;
            end
            `CAL_DIV: begin
                oLO<=oDiv[31:0];
                oHI<=oDiv[63:32];
                sum_finish<=finishDiv;
            end
            default: begin end
        endcase
    end

        always @(*) begin
        case (calc)
            `CAL_MULTU: begin
                busy<=busyMultu;
            end
            `CAL_MULT: begin
                busy<=busyMult;
            end
            `CAL_DIVU: begin
                busy<=busyDivu;
            end
            `CAL_DIV: begin
                busy<=busyDiv;
            end
            default: begin end
        endcase
    end

    always @(posedge ena or posedge busy or posedge reset) begin
        if (reset) begin
            start<=0;
        end else begin
            if (busy) 
                start<=0;
            else if(ena)
                start<=1;
        end
    end

    (* KEEP = "{TRUE|FALSE|SOFT}" *) wire start_mult,start_multu,start_div,start_divu;
    assign start_mult=start&&(calc==`CAL_MULT);
    assign start_multu=start&&(calc==`CAL_MULTU);
    assign start_div=start&&(calc==`CAL_DIV);
    assign start_divu=start&&(calc==`CAL_DIVU);
    MULT MULT_inst(
        .clk(cal_clk),
        .reset(reset),    //active high
        .start(start_mult),
        .a(a), //multiplicand
        .b(b), //multiplier
        .z(oMult),
        .busy(busyMult),
        .finish(finishMult),
        .cpu_stall(cpu_stall)
    );
    MULTU MULTU_inst(
        .clk(cal_clk),
        .reset(reset),    //active high
        .start(start_multu),
        .a(a), //multiplicand
        .b(b), //multiplier
        .z(oMultu),
        .busy(busyMultu),
        .finish(finishMultu),
        .cpu_stall(cpu_stall)
    );
    DIV DIV_inst(
        .dividend(a),
        .divisor(b),
        .start(start_div),
        .clock(cal_clk),
        .reset(reset),    //active-high
        .q(oDiv[31:0]),
        .r(oDiv[63:32]),
        .busy(busyDiv),
        .finish(finishDiv),
        .cpu_stall(cpu_stall)
    );
    DIVU DIVU_inst(
        .dividend(a),
        .divisor(b),
        .start(start_divu),
        .clock(cal_clk),
        .reset(reset),    //active-high
        .q(oDivu[31:0]),
        .r(oDivu[63:32]),
        .busy(busyDivu),
        .finish(finishDivu),
        .cpu_stall(cpu_stall)
    );
endmodule
