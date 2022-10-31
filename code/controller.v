`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/27 22:28:11
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 1.01 - fit for multi period
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module controller(
    input [31:0] inst,
    input judge_beq, //judge BEQ BNE condition to jump
    input judge_bgez, //judge BGEZ condition to jump

    /*-----------flow_control-----------*/
    output reg [6:0] raddr1,output reg [6:0] raddr2,output reg [6:0] waddr,output reg dmem_r,

    /*-----------control-----------*/
    //ID
    output reg [2:0] mux_pc_sel,
    output reg [2:0] mux_ALUa_sel,output reg [1:0] mux_ALUb_sel,output reg [2:0] ext_sel,
    output reg cp0_exception,output reg cp0_eret,output reg [4:0] cp0_cause,
    //EX
    output reg [3:0] alu_sel,output reg [1:0] cal_sel,output reg cal_ena/*also for stall*/,output reg use_overflow,
    //ME
    output reg dmem_w,output reg [1:0] dmem_width,output reg [2:0] mem_sel,
    //WB
    output reg [1:0] mux_Rdc_sel,output reg [1:0] mux_Rd_sel,
    output reg hi_w,output reg lo_w,output reg regfile_w,output reg cp0_w
    );

    always @(*) begin
        case (inst[31:26])
            `IR_NON_31_26: begin    //do nothing
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b000000: begin
                case (inst[5:0])
                    6'b100000: begin    //add
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b1;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100001: begin    //addu
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100010: begin    //sub
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SUB;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b1;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100011: begin    //subu
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SUBU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100100: begin    //and
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_AND;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100101: begin    //or
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_OR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100110: begin    //xor
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_XOR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100111: begin    //nor
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_NOR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b101010: begin    //slt
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLT;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b101011: begin    //sltu
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_S;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLTU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b000000: begin    //sll
                        //FLOW
                        raddr1<=`VIOLATION_NON;raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_EXT;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b000010: begin    //srl
                        //FLOW
                        raddr1<=`VIOLATION_NON;raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_EXT;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SRL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b000011: begin    //sra
                        //FLOW
                        raddr1<=`VIOLATION_NON;raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_EXT;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SRA;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b000100: begin    //sllv
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b000110: begin    //srlv
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SRL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b000111: begin    //srav
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SRA;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b001000: begin    //jr
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_RS;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b011010: begin    //div
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_HILO;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLL;cal_sel<=`CAL_DIV;cal_ena<=1'b1;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_HI;
                        hi_w<=1'b1;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b011011: begin    //divu
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_HILO;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLL;cal_sel<=`CAL_DIVU;cal_ena<=1'b1;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_HI;
                        hi_w<=1'b1;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b011001: begin    //multu
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_HILO;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_SLL;cal_sel<=`CAL_MULTU;cal_ena<=1'b1;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_HI;
                        hi_w<=1'b1;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b001001: begin    //jarl
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_RS;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_NPC;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b001101: begin    //break
                        //FLOW
                        raddr1<={`VIOLATION_CP0REG_HEAD,5'd12};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_INTR_ADDR;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b1;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b001100: begin    //syscall
                        //FLOW
                        raddr1<={`VIOLATION_CP0REG_HEAD,5'd12};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_INTR_ADDR;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b1;cp0_eret<=1'b0;cp0_cause<=`EXC_SYSCALL;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b010000: begin    //mfhi
                        //FLOW
                        raddr1<=`VIOLATION_HI;raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_HI;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b010010: begin    //mflo
                        //FLOW
                        raddr1<=`VIOLATION_LO;raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_LO;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b010001: begin    //mthi
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_HI;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b1;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b010011: begin    //mtlo
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_LO;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b1;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    6'b110100: begin    //teq
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_INTR_ADDR;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=judge_beq;cp0_eret<=1'b0;cp0_cause<=`EXC_TEQ;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    default: begin    //do nothing
                        //FLOW
                        raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                endcase
            end
            6'b001000: begin    //addi
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b1;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b001001: begin    //addiu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b001100: begin    //andi
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_AND;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b001101: begin    //ori
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_OR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b001110: begin    //xori
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_XOR;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b001111: begin    //lui
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_LUI;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b100011: begin    //lw
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_32;mem_sel<=`EXT32_NON;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b101011: begin    //sw
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b1;dmem_width<=`RAM_WIDTH_32;mem_sel<=`EXT32_NON;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b000100: begin    //beq
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=judge_beq?`MUX_PC_NPCEXT:`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_SL2_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b000101: begin    //bne
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=judge_beq?`MUX_PC_NPC:`MUX_PC_NPCEXT;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT16_SL2_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b001010: begin    //slti
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_SLT;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b001011: begin    //sltiu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_SLTU;cal_sel<=`CAL_MULT;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b000010: begin    //j
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_CONNECT;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b000011: begin    //jal
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,5'd31};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_CONNECT;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_NPC;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b000001: begin    //bgez
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=judge_bgez?`MUX_PC_NPCEXT:`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_NPC;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT16_SL2_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b100100: begin    //lbu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_8;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b100101: begin    //lhu
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT16_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b100000: begin    //lb
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_8;mem_sel<=`EXT8_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b100001: begin    //lh
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b1;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT16_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
            end
            6'b101000: begin    //sb
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b1;dmem_width<=`RAM_WIDTH_8;mem_sel<=`EXT8_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b101001: begin    //sh
                //FLOW
                raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_EXT;ext_sel<=`EXT16_S;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADD;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b1;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT16_S;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_MEM;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
            6'b010000: begin
                case (inst[25:21])
                    5'b10000: begin     //eret
                        //FLOW
                        raddr1<={`VIOLATION_CP0REG_HEAD,5'd14};raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_EPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b1;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                    5'b00000: begin     //mfc0
                        //FLOW
                        raddr1<={`VIOLATION_CP0REG_HEAD,inst[15:11]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[20:16]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_CP0;mux_ALUb_sel<=`MUX_ALUb_IMM0;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_20_16;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    5'b00100: begin     //mtc0
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[20:16]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_CP0REG_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_IMM0;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b1;
                    end
                    default: begin    //do nothing
                        //FLOW
                        raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                endcase
            end
            6'b011100: begin
                case (inst[5:0])
                    6'b000010: begin    //mul
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<={`VIOLATION_REGFILE_HEAD,inst[20:16]};waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULT;cal_ena<=1'b1;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_LO;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    6'b100000: begin    //clz
                        //FLOW
                        raddr1<={`VIOLATION_REGFILE_HEAD,inst[25:21]};raddr2<=`VIOLATION_NON;waddr<={`VIOLATION_REGFILE_HEAD,inst[15:11]};dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_CLZ;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IR_15_11;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b1;cp0_w<=1'b0;
                    end
                    default: begin    //do nothing
                        //FLOW
                        raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                        //IF
                        mux_pc_sel<=`MUX_PC_NPC;
                        //ID
                        mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                        cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                        //EX
                        alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                        dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                        //WB
                        mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                        hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
                    end
                endcase
            end
            default: begin    //do nothing
                //FLOW
                raddr1<=`VIOLATION_NON;raddr2<=`VIOLATION_NON;waddr<=`VIOLATION_NON;dmem_r<=1'b0;
                //IF
                mux_pc_sel<=`MUX_PC_NPC;
                //ID
                mux_ALUa_sel<=`MUX_ALUa_RS;mux_ALUb_sel<=`MUX_ALUb_RT;ext_sel<=`EXT5_Z;
                cp0_exception<=1'b0;cp0_eret<=1'b0;cp0_cause<=`EXC_BREAK;
                //EX
                alu_sel<=`ALU_ADDU;cal_sel<=`CAL_MULTU;cal_ena<=1'b0;use_overflow<=1'b0;
                dmem_w<=1'b0;dmem_width<=`RAM_WIDTH_16;mem_sel<=`EXT8_Z;
                //WB
                mux_Rdc_sel<=`MUX_RDC_IMM31;mux_Rd_sel<=`MUX_RD_Z;
                hi_w<=1'b0;lo_w<=1'b0;regfile_w<=1'b0;cp0_w<=1'b0;
            end
        endcase
    end
endmodule
