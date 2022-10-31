`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/19 11:05:11
// Design Name: 
// Module Name: flow_control
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
// id_ALUa: Rs,HI,LO,CP0
// id_ALUb: Rt
// id_Rt: Rt
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module flow_control(
    input clk,input reset,
    input [6:0] raddr1,input [6:0] raddr2,input [6:0] waddr1,input [6:0] waddr2,input [6:0] waddr3,
    input mult_div_stall,input mult_div_over,input overflow_stall,

    /*-----------flow_control-----------*/
    output [1:0] cond0,output [1:0] cond1,output [1:0] cond2,output [1:0] cond3,output [1:0] cond4,

    /*-----------flow_data-----------*/
    output reg [31:0] id_ALUa,output reg [31:0] id_ALUb,output reg [31:0] id_Rt,output id_ALUa_w,output id_ALUb_w,output id_Rt_w,
    input [31:0] ex_HI,input [31:0] ex_LO,input [31:0] ex_Z,input ex_from_mem,input ex_mul,
    input [31:0] me_HI,input [31:0] me_LO,input [31:0] me_Z,input [31:0] me_MEM,input me_from_mem,input me_mul,

    //for program in
    input cpu_stall
    );

    reg [1:0] cond[0:4];
    assign cond0=cond[0];
    assign cond1=cond[1];
    assign cond2=cond[2];
    assign cond3=cond[3];
    assign cond4=cond[4];

    reg [1:0] state,nextstate;reg [4:0] cnt;
    wire violation1=(waddr1!=`VIOLATION_NON)&&(raddr1==waddr1||raddr2==waddr1||(waddr1==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO||raddr2==`VIOLATION_HI||raddr2==`VIOLATION_LO)));
    wire violation2=(waddr2!=`VIOLATION_NON)&&(raddr1==waddr2||raddr2==waddr2||(waddr2==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO||raddr2==`VIOLATION_HI||raddr2==`VIOLATION_LO)));
    wire violation3=(waddr3!=`VIOLATION_NON)&&(raddr1==waddr3||raddr2==waddr3||(waddr3==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO||raddr2==`VIOLATION_HI||raddr2==`VIOLATION_LO)));
    wire violation=violation1|(violation2&ex_from_mem);
    
    always @(posedge clk or posedge reset) begin
        if(reset)
            state<=`FLOW_NORMAL;
        else
            state<=nextstate;
    end

    assign id_ALUa_w=(!violation)&&(raddr1!=`VIOLATION_NON)&&(raddr1==waddr2||raddr1==waddr3||(waddr2==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO))||(waddr3==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO)));
    assign id_ALUb_w=(!violation)&&(raddr2!=`VIOLATION_NON)&&(raddr2==waddr2||raddr2==waddr3);
    assign id_Rt_w=id_ALUb_w;
    always @(*) begin
        if(!violation) begin
            if(id_ALUa_w) begin //use alua
                if(raddr1==waddr2||(waddr2==`VIOLATION_HILO&&(raddr1==`VIOLATION_HI||raddr1==`VIOLATION_LO))) begin //use ex
                    case (waddr2)
                        `VIOLATION_HI: id_ALUa<=ex_HI;
                        `VIOLATION_LO: id_ALUa<=ex_LO;
                        `VIOLATION_HILO: begin
                            if (raddr1==`VIOLATION_HI) 
                                id_ALUa<=ex_HI;
                            else
                                id_ALUa<=ex_LO;
                        end
                        default: begin
                            case (waddr2[6:5])
                                `VIOLATION_REGFILE_HEAD: id_ALUa<=ex_Z;
                                `VIOLATION_CP0REG_HEAD: id_ALUa<=ex_Z;
                                default: begin end
                            endcase
                        end
                    endcase
                end
                else begin //use me
                    if (me_from_mem) begin
                        id_ALUa<=me_MEM;
                    end
                    case (waddr2)
                        `VIOLATION_HI: id_ALUa<=me_HI;
                        `VIOLATION_LO: id_ALUa<=me_LO;
                        `VIOLATION_HILO: begin
                            if (raddr1==`VIOLATION_HI) 
                                id_ALUa<=me_HI;
                            else
                                id_ALUa<=me_LO;
                        end
                        default: begin
                            case (waddr2[6:5])
                                `VIOLATION_REGFILE_HEAD: id_ALUa<=me_Z;
                                `VIOLATION_CP0REG_HEAD: id_ALUa<=me_Z;
                                default: begin end
                            endcase
                        end
                    endcase
                end
            end

            if (id_ALUb_w) begin    //use alub
                if (raddr2==waddr2) //use ex
                    id_ALUb<=ex_mul?ex_LO:ex_Z;
                else begin  //use me
                    if (me_from_mem)
                        id_ALUb<=me_MEM;
                    else
                        id_ALUb<=me_mul?me_LO:me_Z;
                end
            end

            if (id_Rt_w) begin    //use Rt
                if (raddr2==waddr2) //use ex
                    id_Rt<=ex_mul?ex_LO:ex_Z;
                else begin  //use me
                    if (me_from_mem)
                        id_Rt<=me_MEM;
                    else
                        id_Rt<=me_mul?me_LO:me_Z;
                end
            end
        end
    end

    always @(*) begin
        if(cpu_stall)begin
            cond[0]<=`PARTS_COND_STALL;  //IF
            cond[1]<=`PARTS_COND_STALL;  //ID
            cond[2]<=`PARTS_COND_STALL;  //EX
            cond[3]<=`PARTS_COND_STALL;  //ME
            cond[4]<=`PARTS_COND_STALL;  //WB
            nextstate<=state;
        end else begin
            case (state)
                `FLOW_NORMAL: begin
                    if (overflow_stall) begin
                        if (violation) begin
                            cond[0]<=`PARTS_COND_FLOW;  //IF
                            cond[1]<=`PARTS_COND_ZERO;  //ID
                            cond[2]<=`PARTS_COND_ZERO;  //EX
                            cond[3]<=`PARTS_COND_FLOW;  //ME
                            cond[4]<=`PARTS_COND_FLOW;  //WB
                            nextstate<=`FLOW_NORMAL;
                        end else begin
                            cond[0]<=`PARTS_COND_FLOW;  //IF
                            cond[1]<=`PARTS_COND_FLOW;  //ID
                            cond[2]<=`PARTS_COND_ZERO;  //EX
                            cond[3]<=`PARTS_COND_FLOW;  //ME
                            cond[4]<=`PARTS_COND_FLOW;  //WB
                            nextstate<=`FLOW_NORMAL;
                        end
                    end
                    else if (!mult_div_over&mult_div_stall) begin
                        cond[0]<=`PARTS_COND_STALL;  //IF
                        cond[1]<=`PARTS_COND_STALL;  //ID
                        cond[2]<=`PARTS_COND_STALL;  //EX
                        cond[3]<=`PARTS_COND_STALL;  //ME
                        cond[4]<=`PARTS_COND_STALL;  //WB
                        nextstate<=`FLOW_MULDIV;
                    end
                    else if (violation) begin
                        cond[0]<=`PARTS_COND_STALL;  //IF
                        cond[1]<=`PARTS_COND_ZERO;  //ID
                        cond[2]<=`PARTS_COND_FLOW;  //EX
                        cond[3]<=`PARTS_COND_FLOW;  //ME
                        cond[4]<=`PARTS_COND_FLOW;  //WB
                        nextstate<=`FLOW_NORMAL;
                    end else begin
                        cond[0]<=`PARTS_COND_FLOW;  //IF
                        cond[1]<=`PARTS_COND_FLOW;  //ID
                        cond[2]<=`PARTS_COND_FLOW;  //EX
                        cond[3]<=`PARTS_COND_FLOW;  //ME
                        cond[4]<=`PARTS_COND_FLOW;  //WB
                        nextstate<=`FLOW_NORMAL;
                    end
                end
                `FLOW_MULDIV: begin
                    if (mult_div_over) begin
                        if (violation) begin
                            cond[0]<=`PARTS_COND_STALL;  //IF
                            cond[1]<=`PARTS_COND_ZERO;  //ID
                            cond[2]<=`PARTS_COND_FLOW;  //EX
                            cond[3]<=`PARTS_COND_FLOW;  //ME
                            cond[4]<=`PARTS_COND_FLOW;  //WB
                            nextstate<=`FLOW_NORMAL;
                        end else begin
                            cond[0]<=`PARTS_COND_FLOW;  //IF
                            cond[1]<=`PARTS_COND_FLOW;  //ID
                            cond[2]<=`PARTS_COND_FLOW;  //EX
                            cond[3]<=`PARTS_COND_FLOW;  //ME
                            cond[4]<=`PARTS_COND_FLOW;  //WB
                            nextstate<=`FLOW_NORMAL;
                        end
                    end else begin
                        cond[0]<=`PARTS_COND_STALL;  //IF
                        cond[1]<=`PARTS_COND_STALL;  //ID
                        cond[2]<=`PARTS_COND_STALL;  //EX
                        cond[3]<=`PARTS_COND_STALL;  //ME
                        cond[4]<=`PARTS_COND_STALL;  //WB
                        nextstate<=`FLOW_MULDIV;
                    end
                end
                default: begin
                    cond[0]<=`PARTS_COND_FLOW;  //IF
                    cond[1]<=`PARTS_COND_FLOW;  //ID
                    cond[2]<=`PARTS_COND_FLOW;  //EX
                    cond[3]<=`PARTS_COND_FLOW;  //ME
                    cond[4]<=`PARTS_COND_FLOW;  //WB
                    nextstate<=`FLOW_NORMAL;
                end
            endcase
        end
    end
endmodule
