module imm_gen(
input logic [31:0] instr,
output logic [31:0] imm
);
	wire [6:0] opcode;
	wire [2:0] funct;
	assign opcode = instr[6:0];
	assign funct = instr[14:12];
	always@(*) begin
	imm = 0;
		case(opcode)
						///U-FORMAT///
			///LUI///
			7'b0110111: imm = {instr[31:12],{12{1'b0}}};
			///AUIPC///
			7'b0010111: imm = {instr[31:12],{12{1'b0}}};
			///JAL///
			7'b1101111: imm = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
			///JALR///
			7'b1100111: imm = {{20{instr[31]}},instr[31:20]};
						///B-FORMAT///
			7'b1100011: imm = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
			///S-FORMAT///
			7'b0100011: imm = {{20{instr[31]}},instr[31:25],instr[11:7]};
						///I-FORMAT///
			///L-TYPE///
			7'b0000011: imm = {{20{instr[31]}},instr[31:20]};
			///Arithmetic Logic///
			7'b0010011: begin
				case(funct) 
					3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: imm = {{20{instr[31]}},instr[31:20]};
					3'b001, 3'b101: imm = {{27{1'b0}},instr[24:20]};
					default : imm = 32'h0;
				endcase
			end
			default: imm = 32'h0;
		endcase
	end
endmodule