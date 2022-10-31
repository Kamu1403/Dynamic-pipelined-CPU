`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/14 19:21:51
// Design Name: 
// Module Name: ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// [31:0] memory [0:1023]
// ram_addr=addr>>2 :real address
// Dependencies: 
// 
// Revision:
// Revision 1.02 - simplify
// remove ena,finish
// Revision 1.01 - add content
// synchronous-ram
// allow byte,hword
// posedge write
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module ram(
    input clk,  //posedge read/write-active
    input wena, //high:write low:read
    
    input [1:0] width,  //0:word,1:hword,2:byte
    input [31:0] addr,
    input [31:0] data_in,   //use zero side
    output reg [31:0] data_out   //use zero side
    );
    
    reg [31:0] memory [0:4095]; //16KB
    wire [31:0] ram_addr;
    assign ram_addr=addr>>2;
    
    always @(posedge clk) begin
        if(wena) begin
            case (width)
                `RAM_WIDTH_32: memory[ram_addr]<=data_in;   //addr[1:0]=00
                `RAM_WIDTH_16: begin     //addr[0]=0
                    if(addr[1]==1'b0)
                        memory[ram_addr][15:0]<=data_in[15:0];
                    else
                        memory[ram_addr][31:16]<=data_in[15:0];
                end
                `RAM_WIDTH_8: begin
                    case (addr[1:0])
                        2'b00: memory[ram_addr][7:0]<=data_in[7:0];
                        2'b01: memory[ram_addr][15:8]<=data_in[7:0];
                        2'b10: memory[ram_addr][23:16]<=data_in[7:0];
                        2'b11: memory[ram_addr][31:24]<=data_in[7:0];
                        default: begin end
                    endcase
                end
                default: begin end
            endcase
        end
    end

    always @(*) begin
        case (width)
            `RAM_WIDTH_32: data_out[31:0]<=memory[ram_addr];   //addr[1:0]=00
            `RAM_WIDTH_16: begin      //addr[0]=0
                if(addr[1]==1'b0)
                    data_out<={16'b0,memory[ram_addr][15:0]};
                else
                    data_out<={16'b0,memory[ram_addr][31:16]};
            end
            `RAM_WIDTH_8: begin
                case (addr[1:0])
                    2'b00: data_out<={24'b0,memory[ram_addr][7:0]};
                    2'b01: data_out<={24'b0,memory[ram_addr][15:8]};
                    2'b10: data_out<={24'b0,memory[ram_addr][23:16]};
                    2'b11: data_out<={24'b0,memory[ram_addr][31:24]};
                    default: begin end
                endcase
            end
            default: data_out<=32'b0;
        endcase
    end

endmodule
