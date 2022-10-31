//----------Instruction----------

`define PARTS_COND_FLOW 2'b00
`define PARTS_COND_STALL 2'b01
`define PARTS_COND_ZERO 2'b10
`define PC_ADDR_INIT 32'h00400000
`define IR_NON 32'hffffffff
`define IR_NON_31_26 6'b111111

//----------Operation----------

`define CAL_MULTU 2'b00
`define CAL_MULT 2'b01
`define CAL_DIVU 2'b10
`define CAL_DIV 2'b11

//----------ALU----------

`define ALU_ADDU 4'b0000
`define ALU_ADD 4'b0010
`define ALU_SUBU 4'b0001
`define ALU_SUB 4'b0011
`define ALU_AND 4'b0100
`define ALU_OR 4'b0101
`define ALU_XOR 4'b0110
`define ALU_NOR 4'b0111
`define ALU_LUI 4'b1000
`define ALU_SLT 4'b1011
`define ALU_SLTU 4'b1010
`define ALU_SRA 4'b1100
`define ALU_SLL 4'b1110
`define ALU_SLA 4'b1111
`define ALU_SRL 4'b1101
`define ALU_CLZ 4'b1001

//----------CP0----------

`define EXC_SYSCALL 4'b1000
`define EXC_BREAK 4'b1001
`define EXC_TEQ 4'b1101

//----------Extend----------

`define EXT5_Z 3'b000
`define EXT16_SL2_S 3'b001
`define EXT16_Z 3'b010
`define EXT16_S 3'b011
`define EXT8_Z 3'b100
`define EXT8_S 3'b101
`define EXT32_NON 3'b110

//----------Mux----------

`define MUX_PC_NPCEXT 3'b000
`define MUX_PC_RS 3'b001
`define MUX_PC_INTR_ADDR 3'b010
`define MUX_PC_EPC 3'b011
`define MUX_PC_CONNECT 3'b100
`define MUX_PC_NPC 3'b101

`define MUX_ALUa_HI 3'b000
`define MUX_ALUa_LO 3'b001
`define MUX_ALUa_NPC 3'b010
`define MUX_ALUa_RS 3'b011
`define MUX_ALUa_EXT 3'b100
`define MUX_ALUa_CP0 3'b101
`define MUX_ALUa_IMM0 3'b110

`define MUX_ALUb_IMM0 2'b00
`define MUX_ALUb_RT 2'b01
`define MUX_ALUb_EXT 2'b10

`define MUX_RDC_IR_15_11 2'b00
`define MUX_RDC_IR_20_16 2'b01
`define MUX_RDC_IMM31 2'b10

`define MUX_RD_Z 2'b00
`define MUX_RD_MEM 2'b01
`define MUX_RD_HI 2'b10
`define MUX_RD_LO 2'b11

//----------RAM----------

`define RAM_WIDTH_32 2'b00
`define RAM_WIDTH_16 2'b01
`define RAM_WIDTH_8 2'b10

//----------CtrlUnit----------

`define FLOW_NORMAL 2'b00
`define FLOW_OVERFLOW 2'b01
`define FLOW_MULDIV 2'b10
`define FLOW_VIOLATE 2'b11

//----------Others----------

//judge read/write violation
`define VIOLATION_REGFILE_HEAD 2'b00
`define VIOLATION_CP0REG_HEAD 2'b01
`define VIOLATION_HI 7'b100_0000
`define VIOLATION_LO 7'b100_0001
`define VIOLATION_HILO 7'b100_0010
`define VIOLATION_NON 7'b110_0000