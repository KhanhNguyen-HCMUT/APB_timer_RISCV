module singlecycle(
    input  logic [0:0]  i_clk, i_rst, 
    // APB Interface
    output logic [31:0] o_paddr,         // Địa chỉ APB
    output logic        o_pwrite,        // Tín hiệu ghi (1) hoặc đọc (0)
    output logic        o_psel,          // Chọn thiết bị
    output logic        o_penable,       // Kích hoạt truyền dữ liệu
    output logic [31:0] o_pwdata,        // Dữ liệu ghi
    input  logic [31:0] i_prdata,        // Dữ liệu đọc
    input  logic        i_pready         // Tín hiệu sẵn sàng từ slave
);
    //PC wires
    logic [31:0] pc, pc_next;
    //IMEM wire
    logic [31:0] instr;
    //Regfile wires
    logic [31:0] rs1_data, rs2_data;
    //Immediate generator wire
    logic [31:0] imm;
    //ALU wire
    logic [31:0] operand_a, operand_b, alu_data;
    //LSU wires
    logic [31:0] ld_data;
    //WBMUX wire
    logic [31:0] wb_data;
    //Control unit wires
    logic [0:0] br_less, br_equal, pc_sel, rd_wren, br_unsigned, op_a_sel, op_b_sel, mem_wren;
    logic [1:0] wb_sel;
    logic [3:0] alu_op;
    //PC 
    logic instr_valid;
    //debug
    
    //Module zone
    pc programcounter(i_clk, i_rst, 1'b1, pc_next, pc);
    imem ins_memory(pc, instr);
    regfile registers(i_clk, i_rst, rd_wren, instr[19:15], instr[24:20], instr[11:7], wb_data, rs1_data, rs2_data);
    imm_gen immediate(instr, imm);
    brcomp branch(rs1_data, rs2_data, br_unsigned, br_less, br_equal);
    alu arith_logic(alu_op, operand_a, operand_b, alu_data);
    ctrl_unit control(instr, br_less, br_equal, pc_sel, rd_wren, br_unsigned, op_a_sel, op_b_sel, mem_wren, wb_sel, alu_op, instr_valid);
    
    // BIU module để kết nối với APB bus
    biu bus_interface(
        .i_clk       (i_clk),
        .i_rst       (i_rst),
	.opcode	     (instr[6:0]),
        .i_alu_data  (alu_data),       // Địa chỉ từ ALU
        .i_rs2_data  (rs2_data),       // Dữ liệu để ghi từ rs2
        .i_funct3    (instr[14:12]),   // Funct3 từ instruction
        .o_ld_data   (ld_data),        // Dữ liệu load về CPU
        
        // APB interface
        .o_paddr     (o_paddr),
        .o_pwrite    (o_pwrite),
        .o_psel      (o_psel),
        .o_penable   (o_penable),
        .o_pwdata    (o_pwdata),
        .i_prdata    (i_prdata),
        .i_pready    (i_pready)
    );
    
    always_comb begin
        //PC branch mux
        case(pc_sel)
            default: pc_next = pc + 32'd4;
            1'd1: pc_next = alu_data;
        endcase
        
        //ALU operand mux
        case(op_a_sel)
            default: operand_a = rs1_data;
            1'd1: operand_a = pc;
        endcase
        
        case(op_b_sel)
            default: operand_b = rs2_data;
            1'd1: operand_b = imm;
        endcase
        
        //Write back mux
        case(wb_sel)
            default: wb_data = alu_data;
            2'd0: wb_data = ld_data;
            2'd2: wb_data = pc + 32'd4;
        endcase
    end
endmodule