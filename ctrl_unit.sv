module ctrl_unit(
input logic [31:0] instr,
input logic [0:0] br_less, br_equal,
output logic [0:0] br_sel, rd_wren, br_unsigned, op_a_sel, op_b_sel, mem_wren,
output logic [1:0] wb_sel,
output logic [3:0] alu_op,
output logic [0:0] o_instr_vld
);

always_comb begin
case(instr[6:0])
//ARITHMETIC OPCODE GROUP
7'b0110011: begin //R-type
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd0; //PC += 4
rd_wren = 1'd1; //Enable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd0; //operand_a = rs1_data
op_b_sel = 1'd0; //operand_b = rs2_data
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd1; //rd_data = alu_data
case(instr[14:12])
3'd0: begin //ADD + SUB
if(instr[30]) alu_op = 4'd1; //SUB
else alu_op = 4'd0; //ADD
end
3'd1: alu_op = 4'd2; //SLL
3'd2: alu_op = 4'd3; //SLT
3'd3: alu_op = 4'd4; //SLTU
3'd4: alu_op = 4'd5; //XOR
3'd5: begin //SRL + SRA
if(instr[30]) alu_op = 4'd7; //SRA
else alu_op = 4'd6; //SRL
end
3'd6: alu_op = 4'd8; //OR
3'd7: alu_op = 4'd9; //AND
default: alu_op = 4'd15; //If none
endcase
end

7'b0010011: begin //I-type (Arithmetic)
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd0; //PC += 4
rd_wren = 1'd1; //Enable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd0; //operand_a = rs1_data
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd1; //rd_data = alu_data
case(instr[14:12])
3'd0: alu_op = 4'd0; //ADDI
3'd1: alu_op = 4'd2; //SLLI
3'd2: alu_op = 4'd3; //SLTI
3'd3: alu_op = 4'd4; //SLTIU
3'd4: alu_op = 4'd5; //XORI
3'd5: begin //SRLI + SRAI
if(instr[30]) alu_op = 4'd7; //SRAI
else alu_op = 4'd6; //SRLI
end
3'd6: alu_op = 4'd8; //ORI
3'd7: alu_op = 4'd9; //ANDI
default: alu_op = 4'd15; //If none
endcase
end

//LOAD-STORE OPCODE GROUP
7'b0000011: begin //I-type (Load)
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd0; //PC += 4
rd_wren = 1'd1; //Enable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd0; //operand_a = rs1_data
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd0; //rd_data = ld_data
alu_op = 4'd0; //alu_op = ADD
end

7'b0100011: begin //S-type
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd0; //PC += 4
rd_wren = 1'd0; //Disable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd0; //operand_a = rs1_data
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd1; //Enable write LSU
wb_sel = 2'd0; //rd_data = ld_data
alu_op = 4'd0; //alu_op = ADD
end

//BRANCH OPCODE GROUP
7'b1100011: begin //B-type
o_instr_vld = 1'd1; //Valid instruction
rd_wren = 1'd0; //Disable write reg
op_a_sel = 1'd1; //operand_a = pc
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd0; //rd_data = ld_data
alu_op = 4'd0; //alu_op = ADD

case(instr[14:12])
3'd0: begin //Branch if = (BEQ)
br_unsigned = 1'd0; //Signed
if(br_equal) br_sel = 1'd1; //If =, PC += imm
else br_sel = 1'd0; //If not, PC += 4;
end
3'd1: begin //Branch if != (BNE)
br_unsigned = 1'd0; //Signed
if(~br_equal) br_sel = 1'd1; //If !=, PC += imm
else br_sel = 1'd0; //If not, PC += 4;
end
3'd4: begin //Branch if < (BLT)
br_unsigned = 1'd0; //Signed
if(br_less) br_sel = 1'd1; //If <, PC += imm
else br_sel = 1'd0; //If not, PC += 4
end
3'd5: begin //Branch if >= (BGE)
br_unsigned = 1'd0; //Signed
if(~br_less || br_equal) br_sel = 1'd1; //If >=, PC += imm
else br_sel = 1'd0; //If not, PC += 4;
end
3'd6: begin //Branch if < unsigned (BLTU)
br_unsigned = 1'd1; //Unsigned
if(br_less) br_sel = 1'd1; //If <, PC += imm
else br_sel = 1'd0; //If not, PC += 4;
end
3'd7: begin //Branch if >= unsigned (BGE)
br_unsigned = 1'd1; //Unsigned
if(~br_less || br_equal) br_sel = 1'd1; //If >=, PC += imm
else br_sel = 1'd0; //If not, PC += 4;
end
default: begin //If none of above
br_unsigned = 1'd0; //Signed
br_sel = 1'd0; //PC += 4;
end
endcase
end

//JUMP OPCODE GROUP
7'b1101111: begin //J-type (JAL)
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd1; //PC += imm
rd_wren = 1'd1; //Enable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd1; //operand_a = pc
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd2; //rd_data = pc+4
alu_op = 4'd0; //alu_op = ADD
end

7'b1100111: begin //I-type (JALR)
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd1; //PC += imm
rd_wren = 1'd1; //Enable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd0; //operand_a = rs1_data
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd2; //rd_data = pc+4
alu_op = 4'd0; //alu_op = ADD
end

//UPPER IMM OPCODE GROUP
7'b0110111: begin //U-type (LUI)
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd0; //PC += 4
rd_wren = 1'd1; //Enable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd0; //operand_a = rs1_data
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd1; //rd_data = alu_data
alu_op = 4'd10; //alu_op = (alu_data = operand_b);
end

7'b0010111: begin //U-type (AUIPC)
o_instr_vld = 1'd1; //Valid instruction
br_sel = 1'd0; //PC += 4
rd_wren = 1'd1; //Enable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd1; //operand_a = pc
op_b_sel = 1'd1; //operand_b = imm
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd1; //rd_data = alu_data
alu_op = 4'd0; //alu_op = ADD;
end

default: begin//If none
o_instr_vld = 1'd0; //Invalid instruction
br_sel = 1'd0; //PC += 4
rd_wren = 1'd0; //Disable write reg
br_unsigned = 1'd0; //Signed
op_a_sel = 1'd0; //operand_a = rs1_data
op_b_sel = 1'd0; //operand_b = rs2_data
mem_wren = 1'd0; //Disable write LSU
wb_sel = 2'd0; //rd_data = ld_data
alu_op = 4'd15; //alu_op = null
end
endcase
end
endmodule