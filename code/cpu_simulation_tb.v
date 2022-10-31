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
    wire [31:0] inst,pc;
    reg [31:0] pc_history[0:4],inst_history[0:4];
    wire [31:0] reg_16;
    reg cpu_stall;

    top_parts uut(
        clk,  //posedge write-active
        reset,    //active-high asynchronous
        pc,
        inst,

        reg_16,
        cpu_stall
    );


    integer file_output;
    integer counter=0;

    initial begin
        file_output=$fopen("output.txt");
        //$readmemh("C:/DigitalLogic/DLProject/project_51/test.hex",cpu_tb.uut.mem.memory);
        pc_history[0]=32'h0000_0000;
        clk=0;
        reset=1;
        cpu_stall=0;
        #275;
        reset=0;
    end

    always begin
        #4;
        clk=~clk;
        #1;
        if(clk==1'b0&&reset==0) begin
            if(counter==5000/*||(inst_history[3]===32'h00000000&&pc_history[3]!=32'h00400000)*/) begin
                $fclose(file_output);
                $finish;
            end 
            else if(pc_history[0]!=pc) begin
                pc_history[4]=pc_history[3];
                pc_history[3]=pc_history[2];
                pc_history[2]=pc_history[1];
                pc_history[1]=pc_history[0];
                pc_history[0]=pc;

                inst_history[4]=inst_history[3];
                inst_history[3]=inst_history[2];
                inst_history[2]=inst_history[1];
                inst_history[1]=inst_history[0];
                inst_history[0]=inst;
                
                if (pc_history[4]!=32'h0000_0000) begin
                    counter=counter+1;
                    $fdisplay(file_output,"pc: %h",pc_history[4]);
                    $fdisplay(file_output,"instr: %h",inst_history[4]);
                    $fdisplay(file_output,"regfile0: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[0]);
                    $fdisplay(file_output,"regfile1: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[1]);
                    $fdisplay(file_output,"regfile2: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[2]);
                    $fdisplay(file_output,"regfile3: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[3]);
                    $fdisplay(file_output,"regfile4: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[4]);
                    $fdisplay(file_output,"regfile5: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[5]);
                    $fdisplay(file_output,"regfile6: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[6]);
                    $fdisplay(file_output,"regfile7: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[7]);
                    $fdisplay(file_output,"regfile8: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[8]);
                    $fdisplay(file_output,"regfile9: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[9]);
                    $fdisplay(file_output,"regfile10: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[10]);
                    $fdisplay(file_output,"regfile11: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[11]);
                    $fdisplay(file_output,"regfile12: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[12]);
                    $fdisplay(file_output,"regfile13: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[13]);
                    $fdisplay(file_output,"regfile14: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[14]);
                    $fdisplay(file_output,"regfile15: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[15]);
                    $fdisplay(file_output,"regfile16: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[16]);
                    $fdisplay(file_output,"regfile17: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[17]);
                    $fdisplay(file_output,"regfile18: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[18]);
                    $fdisplay(file_output,"regfile19: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[19]);
                    $fdisplay(file_output,"regfile20: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[20]);
                    $fdisplay(file_output,"regfile21: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[21]);
                    $fdisplay(file_output,"regfile22: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[22]);
                    $fdisplay(file_output,"regfile23: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[23]);
                    $fdisplay(file_output,"regfile24: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[24]);
                    $fdisplay(file_output,"regfile25: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[25]);
                    $fdisplay(file_output,"regfile26: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[26]);
                    $fdisplay(file_output,"regfile27: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[27]);
                    $fdisplay(file_output,"regfile28: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[28]);
                    $fdisplay(file_output,"regfile29: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[29]);
                    $fdisplay(file_output,"regfile30: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[30]);
                    $fdisplay(file_output,"regfile31: %h",cpu_tb.uut.id_inst.cpu_ref.array_reg[31]);
                end
            end
        end
    end
endmodule

