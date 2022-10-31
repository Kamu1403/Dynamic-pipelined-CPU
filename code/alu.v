//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/16 19:33:05
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 2.01 - add new content
// Additional Comments:
// 1.add ALU_C=4'b1001 as CLZ
//////////////////////////////////////////////////////////////////////////////////

`include "define.vh"

module alu(
    input [31:0] a,
    input [31:0] b,
    input [3:0] aluc,
    output reg [31:0] r,
    output reg zero,
    output reg carry,
    output reg negative,
    output reg overflow
    );
    reg [1:0] carry2;
    reg [31:0] tmp;
    always@(*)
    begin
        case(aluc)
            `ALU_ADDU:    //unsigned +
            begin
                {carry,r[31:0]}={1'b0,a}+{1'b0,b};
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_ADD:    //signed +
            begin
                {carry2[0],r}={1'b0,a}+{1'b0,b};
                zero=(0==r)?1:0;
                negative=r[31];
                overflow=(r[31]+a[31]+b[31])^carry2[0];
            end
            `ALU_SUBU:    //unsigned -
            begin
                {carry,r[31:0]}={1'b0,a}-{1'b0,b};
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_SUB:    //signed -
            begin
                {carry2[0],r}={1'b0,a}-{1'b0,b};
                zero=(0==r)?1:0;
                negative=r[31];
                overflow=(r[31]+a[31]+b[31])^carry2[0];
            end
            
            `ALU_AND:    //and
            begin
                r=a&b;
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_OR:    //or
            begin
                r=a|b;
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_XOR:    //xor
            begin
                r=a^b;
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_NOR:    //nor
            begin
                r=~(a|b);
                zero=(0==r)?1:0;
                negative=r[31];
            end
            
            `ALU_LUI:    //lui
            begin
                r={b[15:0],16'b0};
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_SLT:    //signed <
            begin
                {carry2[0],tmp}={a[31],a}-{b[31],b};
                zero=(a==b)?1:0;
                negative=carry2[0];
                r={31'b0,negative};
            end
            `ALU_SLTU:    //unsigned <
            begin
                carry=(a<b)?1:0;
                zero=(a==b)?1:0;
                negative=0;
                r={31'b0,carry};
            end
            
            `ALU_SRA:    //shiftR arithmetic
            begin
                if(a[4:0]>0)
                begin
                    carry=b[a[4:0]-1];
                    tmp={32{b[31]}};
                    r={tmp,b}>>a[4:0];
                end
                else 
                begin
                    carry=b[0];
                    r=b;    //fix
                end
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_SLL,`ALU_SLA:    //shiftL
            begin
                if(a[4:0]>0)
                    carry=b[32-a[4:0]];
                else 
                begin
                    carry=b[31];
                    r=b;    //fix
                end
                r=b<<a[4:0];
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_SRL:    //shiftR logic
            begin
                if(a[4:0]>0)
                    carry=b[a[4:0]-1];
                else 
                begin
                    carry=b[0];
                    r=b;    //fix
                end
                r=b>>a[4:0];
                zero=(0==r)?1:0;
                negative=r[31];
            end
            `ALU_CLZ:    //count leading zero
            begin
                if(a==32'b0) begin
                    r=32'd32;
                end
                else begin
                    r[31:5]=27'b0;
                    tmp[31:0]=a;
                    if(tmp[31:16]==16'b0) begin
                        r[4]=1;
                    end
                    else begin
                        r[4]=0;
                        tmp[15:0]=tmp[31:16];
                    end
                    if(tmp[15:8]==8'b0) begin
                        r[3]=1;
                    end
                    else begin
                        r[3]=0;
                        tmp[7:0]=tmp[15:8];
                    end
                    if(tmp[7:4]==4'b0) begin
                        r[2]=1;
                    end
                    else begin
                        r[2]=0;
                        tmp[3:0]=tmp[7:4];
                    end
                    if(tmp[3:2]==2'b0) begin
                        r[1]=1;
                    end
                    else begin
                        r[1]=0;
                        tmp[1:0]=tmp[3:2];
                    end
                    r[0]=(tmp[1]==1'b0)?1:0;
                end
            end
            default:begin end
        endcase
    end
endmodule
