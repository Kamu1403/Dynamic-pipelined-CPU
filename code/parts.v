`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/15 00:41:49
// Design Name: 
// Module Name: parts
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
// posedge calculate,negedge flow
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module instruction_fetch(
    input clk,  //posedge write-active
    input reset,    //active-high asynchronous

    input [31:0] connect,
    input [31:0] npc_ext,
    input [31:0] regfile_Rs,
    input [31:0] cp0_EPC,
    input [31:0] cp0_intr_addr,

    output [31:0] oNPC,
    output reg [31:0] rPC,
    output reg [31:0] rIR,

    //control signal
    input [1:0] cond,
    input [2:0] mux_pc_sel
    );
    
    wire [31:0] imem_out,mux_pc_out;
    assign oNPC=rPC+32'h4;

    mux_len32_sel8 mux_Pc(
        .sel(mux_pc_sel),
        .iData_1(npc_ext),
        .iData_2(regfile_Rs),
        .iData_3(cp0_intr_addr),
        .iData_4(cp0_EPC),
        .iData_5(connect),
        .iData_6(oNPC),
        .oData(mux_pc_out)
    );
    // ram imem(
    //     .clk(clk),  //posedge read/write-active
    //     .wena(1'b0), //high:write low:read
    //     .width(`RAM_WIDTH_32),  //0:word,1:hword,2:byte
    //     .addr(rPC),
    //     .data_in(32'b0),   //use zero side
    //     .data_out(imem_out)   //use zero side
    // );
    wire [31:0] imem_addr=(rPC-32'h00400000)>>2;
    imem imem_inst(
        .a(imem_addr[10:0]),
        .spo(imem_out)
    );

    always @(posedge clk or posedge reset) begin    //execute
        if (reset) begin
            rPC<=`PC_ADDR_INIT;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: rPC<=mux_pc_out;
                `PARTS_COND_STALL: rPC<=rPC;
                `PARTS_COND_ZERO: rPC<=`PC_ADDR_INIT;
                default: begin end
            endcase
        end
    end

    always @(negedge clk or posedge reset) begin    //flow
        if (reset) begin
            rIR<=`IR_NON;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: rIR<=imem_out;
                `PARTS_COND_STALL: rIR<=rIR;
                `PARTS_COND_ZERO: rIR<=`IR_NON;
                default: begin end
            endcase
        end
    end
    
endmodule

module instruction_decode(
    input clk,
    input reset,

    input [31:0] if_IR, //to read
    input [31:0] if_NPC,
    input [4:0] regfile_Rdc,    //also cp0
    input [31:0] regfile_Rd,    //also cp0,hi,lo
    input [31:0] Rd_out_for_LO, //add for lo *only when hi also write

    output reg [31:0] rALUa,
    output reg [31:0] rALUb,
    output reg [31:0] rRt,
    output reg [31:0] rIR,
    output [31:0] cp0_EPC,
    output [31:0] cp0_intr_addr,
    output [31:0] ext_out,
    output [31:0] connect,
    output [31:0] regfile_Rs,
    output [31:0] regfile_Rt,

    //control signal
    input [1:0] cond,
    output [2:0] mux_pc_sel,
    input hi_w,
    input lo_w,
    input regfile_w,
    input cp0_w,
    output [6:0] flow_raddr1,
    output [6:0] flow_raddr2,

    //forward
    input [31:0] forward_ALUa,
    input [31:0] forward_ALUb,
    input [31:0] forward_Rt,
    input forward_ALUa_w,
    input forward_ALUb_w,
    input forward_Rt_w,

    //for program out
    output [31:0] reg_16
    );

    assign connect={if_NPC[31:28],if_IR[25:0],2'b0};

    reg [31:0] rHI,rLO;

    wire mux_lo_sel,mux_hi_sel;
    wire [31:0] cal_lo_out,cal_hi_out,mux_lo_out,mux_hi_out;
    wire [31:0] alua,alub;
    wire [31:0] cp0_out;wire [4:0] cp0_cause;

    wire [2:0] mux_ALUa_sel;wire [1:0] mux_ALUb_sel;wire [2:0] ext_sel;
    wire cp0_eret,cp0_exception;

    wire judge_beq,judge_bgez;
    assign judge_beq=((forward_ALUa_w?forward_ALUa:regfile_Rs)==(forward_ALUb_w?forward_ALUb:regfile_Rt));
    assign judge_bgez=(forward_ALUa_w?(forward_ALUa[31]==1'b0):(regfile_Rs[31]==1'b0));

    controller controller_id(
        .inst(if_IR),
        .judge_beq(judge_beq), //judge BEQ BNE condition to jump
        .judge_bgez(judge_bgez), //judge BGEZ condition to jump

        /*-----------flow_control-----------*/
        .raddr1(flow_raddr1),.raddr2(flow_raddr2),
        /*-----------control-----------*/
        //ID
        .mux_pc_sel(mux_pc_sel),
        .mux_ALUa_sel(mux_ALUa_sel),.mux_ALUb_sel(mux_ALUb_sel),.ext_sel(ext_sel),
        .cp0_exception(cp0_exception),.cp0_eret(cp0_eret),.cp0_cause(cp0_cause)
    );

    mux_len32_sel8 mux_ALUa(
        .sel(mux_ALUa_sel),
        .iData_1(rHI),
        .iData_2(rLO),
        .iData_3(if_NPC),
        .iData_4(regfile_Rs),
        .iData_5(ext_out),
        .iData_6(cp0_out),
        .iData_7(32'b0),
        .oData(alua)
    );
    mux_len32_sel4 mux_ALUb(
        .sel(mux_ALUb_sel),
        .iData_1(32'd0),
        .iData_2(regfile_Rt),
        .iData_3(ext_out),
        .oData(alub)
    );
    ext ext_id(
        .ext_switch(ext_sel),
        .iData_len5(if_IR[10:6]),
        .iData_len8(),
        .iData_len16(if_IR[15:0]),
        .iData_len32(),
        .oData(ext_out)
    );


    regfile cpu_ref(
        .clk(clk),  //posedge write-active
        .rst(reset),  //active-high asynchronous
        .we(regfile_w),   //high:write low:read
        .raddr1({27'b0,if_IR[25:21]}),
        .raddr2({27'b0,if_IR[20:16]}),
        .rdata1(regfile_Rs),
        .rdata2(regfile_Rt),
        .waddr({27'b0,regfile_Rdc}),
        .wdata(regfile_Rd),

        //for program out
        .reg_16(reg_16)
    );
    CP0 cp0_inst(
        .clk(clk),
        .rst(reset),
        .mtc0(cp0_w), //cpu instruction mtc0,high-active
        .pc(if_NPC),
        .waddr(regfile_Rdc), //specifies CP0 reg to write
        .wdata(regfile_Rd), //data from GP reg to place CP0 reg
        .exception(cp0_exception&&(cond==`PARTS_COND_FLOW)),    //instruction syscall,break,teq,high-active
        .eret(cp0_eret&&(cond==`PARTS_COND_FLOW)), //instruction eret,high-active
        .cause(cp0_cause),
        .raddr(if_IR[15:11]), //specifies CP0 reg to read
        .rdata(cp0_out),    //data from CP0 reg for GP reg
        .exc_addr(cp0_EPC),  //address for PC at the beginning of an exception
        .intr_addr(cp0_intr_addr)
    );

    always @(posedge clk or posedge reset) begin    //execute
        if (reset) begin
            rALUa<=32'b0;
            rALUb<=32'b0;
            rRt<=32'b0;
            rHI<=32'b0;
            rLO<=32'b0;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: begin
                    rALUa<=forward_ALUa_w?forward_ALUa:alua;
                    rALUb<=forward_ALUb_w?forward_ALUb:alub;
                    rRt<=forward_Rt_w?forward_Rt:regfile_Rt;
                end
                `PARTS_COND_STALL: begin
                    rALUa<=rALUa;
                    rALUb<=rALUb;
                    rRt<=rRt;
                end
                `PARTS_COND_ZERO: begin
                    rALUa<=32'b0;
                    rALUb<=32'b0;
                    rRt<=32'b0;
                end
                default: begin end
            endcase
            rHI<=hi_w?regfile_Rd:rHI;
            rLO<=lo_w?(hi_w?Rd_out_for_LO:regfile_Rd):rLO;
        end
    end

    always @(negedge clk or posedge reset) begin    //flow
        if (reset) begin
            rIR<=`IR_NON;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: rIR<=if_IR;
                `PARTS_COND_STALL: rIR<=rIR;
                `PARTS_COND_ZERO: rIR<=`IR_NON;
                default: begin end
            endcase
        end
    end
endmodule

module execute(
    input clk,
    input reset,

    input [31:0] alua,
    input [31:0] alub,
    input [31:0] id_Rt,
    input [31:0] id_IR,

    output reg [31:0] rHI,
    output reg [31:0] rLO,
    output reg [31:0] rZ,
    output reg [31:0] rRt,
    output reg [31:0] rIR,

    //control signal
    input [1:0] cond,
    output mult_div_stall,   //cause controller to stall 32 periods
    output cal_finish,
    output overflow_stall,    //next IR_NON
    output [6:0] flow_waddr,

    //for program in
    input cpu_stall
    );

    wire [31:0] cal_lo,cal_hi;
    wire [1:0] cal_sel;
    (* KEEP = "{TRUE|FALSE|SOFT}" *) wire cal_ena;
    wire [31:0] alu_z;
    wire [3:0] alu_sel;

    wire use_overflow;
    (* KEEP = "{TRUE|FALSE|SOFT}" *) assign mult_div_stall=cal_ena;
    assign overflow_stall=use_overflow&alu_overflow;

    controller controller_ex(
        .inst(id_IR),
        .judge_beq(1'b0), //judge BEQ BNE condition to jump
        .judge_bgez(1'b0), //judge BGEZ condition to jump
        /*-----------flow_control-----------*/
        .waddr(flow_waddr),
        /*-----------control-----------*/
        //EX
        .alu_sel(alu_sel),.cal_sel(cal_sel),.cal_ena(cal_ena)/*also for stall*/,.use_overflow(use_overflow)
    );

    calculator calculator_inst(
        .clk(clk), //negedge calculate
        .a(alua), //multiplicand/dividend
        .b(alub), //multiplier/divisor
        .calc(cal_sel),
        .reset(reset),      //high-active,at the beginning of test
        .ena(cal_ena),  //high-active
        .oLO(cal_lo),
        .oHI(cal_hi),
        .sum_finish(cal_finish),

        //for program in
        .cpu_stall(cpu_stall)
    );

    alu alu_inst(
        .a(alua),
        .b(alub),
        .aluc(alu_sel),
        .r(alu_z),
        .overflow(alu_overflow)
    );

    always @(posedge clk or posedge reset) begin    //execute
        if (reset) begin
            rZ<=32'b0;
            rRt<=32'b0;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: begin
                    rZ<=alu_z;
                    rRt<=id_Rt;
                end
                `PARTS_COND_STALL: begin
                    rZ<=rZ;
                    rRt<=rRt;
                end
                `PARTS_COND_ZERO: begin
                    rZ<=32'b0;
                    rRt<=32'b0;
                end
                default: begin end
            endcase
        end
    end

    always @(negedge clk or posedge reset) begin    //flow
        if (reset) begin
            rHI<=32'b0;
            rLO<=32'b0;
            rIR<=`IR_NON;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: begin
                    rHI<=cal_hi;
                    rLO<=cal_lo;
                    rIR<=id_IR;
                end
                `PARTS_COND_STALL: begin
                    rHI<=rHI;
                    rLO<=rLO;
                    rIR<=rIR;
                end
                `PARTS_COND_ZERO: begin
                    rHI<=32'b0;
                    rLO<=32'b0;
                    rIR<=`IR_NON;
                end
                default: begin end
            endcase
        end
    end
endmodule

module memory_access(
    input clk,
    input reset,

    input [31:0] ex_HI,
    input [31:0] ex_LO,
    input [31:0] ex_Z,
    input [31:0] ex_Rt,
    input [31:0] ex_IR,

    output reg [31:0] rHI,
    output reg [31:0] rLO,
    output reg [31:0] rZ,
    output reg [31:0] rMEM,
    output reg [31:0] rIR,

    //control signal
    input [1:0] cond,
    output [6:0] flow_waddr,
    output dmem_r,
    output use_mul
    );

    assign use_mul=(ex_IR[31:26]==6'b011100&&ex_IR[5:0]==6'b000010);
    wire dmem_w;wire [1:0] dmem_width;wire [31:0] dmem_out,ext_out;wire [2:0] mem_sel;

    controller controller_me(
        .inst(ex_IR),
        .judge_beq(1'b0), //judge BEQ BNE condition to jump
        .judge_bgez(1'b0), //judge BGEZ condition to jump
        /*-----------flow_control-----------*/
        .waddr(flow_waddr),.dmem_r(dmem_r),
        /*-----------control-----------*/
        //ME
        .dmem_w(dmem_w),.dmem_width(dmem_width),.mem_sel(mem_sel)
    );

    ram dmem_inst(
        .clk(clk),  //posedge read/write-active
        .wena(dmem_w), //high:write low:read
        .width(dmem_width),  //0:word,1:hword,2:byte
        .addr(ex_Z-32'h10010000),
        .data_in(ex_Rt),   //use zero side
        .data_out(dmem_out)   //use zero side
    );

    ext ext_me(
        .ext_switch(mem_sel),
        .iData_len5(),
        .iData_len8(dmem_out[7:0]),
        .iData_len16(dmem_out[15:0]),
        .iData_len32(dmem_out),
        .oData(ext_out)
    );

    always @(posedge clk or posedge reset) begin    //execute
        if (reset) begin
            rHI<=32'b0;
            rLO<=32'b0;
            rZ<=32'b0;
            rMEM<=32'b0;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: begin
                    rHI<=ex_HI;
                    rLO<=ex_LO;
                    rZ<=ex_Z;
                    rMEM<=ext_out;
                end
                `PARTS_COND_STALL: begin
                    rHI<=rHI;
                    rLO<=rLO;
                    rZ<=rZ;
                    rMEM<=rMEM;
                end
                `PARTS_COND_ZERO: begin
                    rHI<=32'b0;
                    rLO<=32'b0;
                    rZ<=32'b0;
                    rMEM<=32'b0;
                end
                default: begin end
            endcase
        end
    end

    always @(negedge clk or posedge reset) begin    //flow
        if (reset) begin
            rIR<=`IR_NON;
        end else begin
            case (cond)
                `PARTS_COND_FLOW: rIR<=ex_IR;
                `PARTS_COND_STALL: rIR<=rIR;
                `PARTS_COND_ZERO: rIR<=`IR_NON;
                default: begin end
            endcase
        end
    end
endmodule

module write_back(
    input clk,
    input reset,

    input [31:0] me_HI,
    input [31:0] me_LO,
    input [31:0] me_Z,
    input [31:0] me_MEM,
    input [31:0] me_IR,

    output [4:0] mux_Rdc_out,
    output [31:0] mux_Rd_out,
    output [31:0] Rd_out_for_LO,

    //control signal
    input [1:0] cond,
    output hi_w,
    output lo_w,
    output cp0_w,
    output regfile_w,
    output [6:0] flow_waddr,
    output dmem_r,
    output use_mul
    );

    assign use_mul=(me_IR[31:26]==6'b011100&&me_IR[5:0]==6'b000010);
    assign Rd_out_for_LO=me_LO;

    wire [1:0] mux_Rdc_sel,mux_Rd_sel;
    wire hi_w_in,lo_w_in,cp0_w_in,regfile_w_in;
    wire write_ena=(cond==`PARTS_COND_FLOW);
    assign hi_w=write_ena&hi_w_in;
    assign lo_w=write_ena&lo_w_in;
    assign cp0_w=write_ena&cp0_w_in;
    assign regfile_w=write_ena&regfile_w_in;

    controller controller_wb(
        .inst(me_IR),
        .judge_beq(1'b0), //judge BEQ BNE condition to jump
        .judge_bgez(1'b0), //judge BGEZ condition to jump

        /*-----------flow_control-----------*/
        .waddr(flow_waddr),.dmem_r(dmem_r),
        /*-----------control-----------*/
        //WB
        .mux_Rdc_sel(mux_Rdc_sel),.mux_Rd_sel(mux_Rd_sel),
        .hi_w(hi_w_in),.lo_w(lo_w_in),.regfile_w(regfile_w_in),.cp0_w(cp0_w_in)
    );

    mux_len5_sel4 mux_Rdc(
        .sel(mux_Rdc_sel),
        .iData_1(me_IR[15:11]),
        .iData_2(me_IR[20:16]),
        .iData_3(5'd31),
        .oData(mux_Rdc_out)
    );
    mux_len32_sel4 mux_Rd(
        .sel(mux_Rd_sel),
        .iData_1(me_Z),
        .iData_2(me_MEM),
        .iData_3(me_HI),
        .iData_4(me_LO),
        .oData(mux_Rd_out)
    );
endmodule



