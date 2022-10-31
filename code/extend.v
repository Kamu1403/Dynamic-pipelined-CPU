`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 18:14:16
// Design Name: 
// Module Name: ext5_z
//              ext16_sz
//              ext16sl2_s
//              ext_byte/hword_sz
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 1.01 - Altered
// direct input from iData_type
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module ext(
    input [2:0] ext_switch,

    input [4:0] iData_len5,
    input [7:0] iData_len8,
    input [15:0] iData_len16,
    input [31:0] iData_len32,
    output reg [31:0] oData
);

always @(*) begin
    case (ext_switch)
        `EXT5_Z: oData<={27'b0,iData_len5};
        `EXT16_SL2_S: oData=iData_len16[15]?{14'h3fff,iData_len16,2'b0}:{14'b0,iData_len16,2'b0};
        `EXT16_Z: oData<={16'b0,iData_len16};
        `EXT16_S: oData<={{16{iData_len16[15]}},iData_len16};
        `EXT8_Z: oData<={24'b0,iData_len8};
        `EXT8_S: oData<={{24{iData_len8[7]}},iData_len8};
        `EXT32_NON: oData<=iData_len32;
        default: oData<=32'b0;
    endcase
end
endmodule
