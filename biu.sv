module biu (
    // Tín hiệu kết nối với CPU
    input  logic        i_clk,           // Clock
    input  logic        i_rst,           // Reset
    input  logic [31:0] i_alu_data,      // Địa chỉ từ ALU
    input  logic [31:0] i_rs2_data,      // Dữ liệu để ghi từ rs2
    input  logic [6:0]  opcode,
    input  logic [2:0]  i_funct3,        // Funct3 từ instruction để xác định loại lệnh mem
    output logic [31:0] o_ld_data,       // Dữ liệu load về CPU
    
    // Tín hiệu APB
    output logic [31:0] o_paddr,         // Địa chỉ APB
    output logic        o_pwrite,        // Tín hiệu ghi (1) hoặc đọc (0)
    output logic        o_psel,          // Chọn thiết bị
    output logic        o_penable,       // Kích hoạt truyền dữ liệu
    output logic [31:0] o_pwdata,        // Dữ liệu ghi
    input  logic [31:0] i_prdata,        // Dữ liệu đọc
    input  logic        i_pready         // Tín hiệu sẵn sàng từ slave
);

    // Các trạng thái của state machine
    typedef enum logic [1:0] {
        IDLE    = 2'b00,
        SETUP   = 2'b01,
        ACCESS  = 2'b10
    } apb_state_t;
    
    apb_state_t current_state, next_state;
    
    // Các bit thấp của địa chỉ để xác định byte/half-word
    logic [1:0] addr_low;
    assign addr_low = i_alu_data[1:0];
    
    // Tín hiệu nội bộ
    logic        mem_req;      // Yêu cầu truy cập bộ nhớ
    logic        mem_write;    // Ghi bộ nhớ
    logic        mem_read;     // Đọc bộ nhớ
    logic [31:0] mem_wdata;    // Dữ liệu ghi đã xử lý
    logic [31:0] mem_rdata;    // Dữ liệu đọc tạm thời
    
    // Xác định yêu cầu là đọc hay ghi
    assign mem_write = (opcode == 7'b0100011);
    assign mem_read = (opcode == 7'b0000011);
    assign mem_req = mem_write | mem_read;

    // Xử lý dữ liệu ghi dựa vào loại lệnh (SB, SH, SW)
    always_comb begin
        case (i_funct3)
            3'b000: begin // SB - Store Byte
                case (addr_low)
                    2'b00: mem_wdata = {24'b0, i_rs2_data[7:0]};
                    2'b01: mem_wdata = {16'b0, i_rs2_data[7:0], 8'b0};
                    2'b10: mem_wdata = {8'b0, i_rs2_data[7:0], 16'b0};
                    2'b11: mem_wdata = {i_rs2_data[7:0], 24'b0};
                endcase
            end
            
            3'b001: begin // SH - Store Half-word
                case (addr_low[1])
                    1'b0: mem_wdata = {16'b0, i_rs2_data[15:0]};
                    1'b1: mem_wdata = {i_rs2_data[15:0], 16'b0};
                endcase
            end
            
            3'b010: begin // SW - Store Word
                mem_wdata = i_rs2_data;
            end
            
            default: mem_wdata = i_rs2_data;
        endcase
    end
    
    // Xử lý dữ liệu đọc dựa vào loại lệnh (LB, LH, LW, LBU, LHU)
    always_comb begin
        case (i_funct3)
            3'b000: begin // LB - Load Byte (sign-extended)
                case (addr_low)
                    2'b00: o_ld_data = {{24{mem_rdata[7]}}, mem_rdata[7:0]};
                    2'b01: o_ld_data = {{24{mem_rdata[15]}}, mem_rdata[15:8]};
                    2'b10: o_ld_data = {{24{mem_rdata[23]}}, mem_rdata[23:16]};
                    2'b11: o_ld_data = {{24{mem_rdata[31]}}, mem_rdata[31:24]};
                endcase
            end
            
            3'b001: begin // LH - Load Half-word (sign-extended)
                case (addr_low[1])
                    1'b0: o_ld_data = {{16{mem_rdata[15]}}, mem_rdata[15:0]};
                    1'b1: o_ld_data = {{16{mem_rdata[31]}}, mem_rdata[31:16]};
                endcase
            end
            
            3'b010: begin // LW - Load Word
                o_ld_data = mem_rdata;
            end
            
            3'b100: begin // LBU - Load Byte (zero-extended)
                case (addr_low)
                    2'b00: o_ld_data = {24'b0, mem_rdata[7:0]};
                    2'b01: o_ld_data = {24'b0, mem_rdata[15:8]};
                    2'b10: o_ld_data = {24'b0, mem_rdata[23:16]};
                    2'b11: o_ld_data = {24'b0, mem_rdata[31:24]};
                endcase
            end
            
            3'b101: begin // LHU - Load Half-word (zero-extended)
                case (addr_low[1])
                    1'b0: o_ld_data = {16'b0, mem_rdata[15:0]};
                    1'b1: o_ld_data = {16'b0, mem_rdata[31:16]};
                endcase
            end
            
            default: o_ld_data = mem_rdata;
        endcase
    end
    
    // Quản lý state machine APB
    always_ff @(posedge i_clk or negedge i_rst) begin
        if (!i_rst) begin
            current_state <= IDLE;
            mem_rdata <= 32'b0;
        end else begin
            current_state <= next_state;
            
            // Lưu dữ liệu đọc khi ở trạng thái ACCESS và slave sẵn sàng
            if (current_state == ACCESS && i_pready && !o_pwrite) begin
                mem_rdata <= i_prdata;
            end
        end
    end
    
    // Logic chuyển trạng thái
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (mem_req)
                    next_state = SETUP;
            end
            
            SETUP: begin
                next_state = ACCESS;
            end
            
            ACCESS: begin
                if (i_pready)
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Tạo tín hiệu APB dựa vào trạng thái
    always_comb begin
        // Mặc định tất cả tín hiệu đều inactive
        o_psel = 1'b0;
        o_penable = 1'b0;
        o_pwrite = 1'b0;
        o_paddr = 32'b0;
        o_pwdata = 32'b0;
        
        case (current_state)
            SETUP: begin
                // Trong phase SETUP, PSEL được active nhưng PENABLE chưa active
                o_psel = 1'b1;
                o_penable = 1'b0;
                o_pwrite = mem_write;
                o_paddr = {i_alu_data[31:2], 2'b00}; // Địa chỉ được căn chỉnh word
                o_pwdata = mem_wdata;
            end
            
            ACCESS: begin
                // Trong phase ACCESS, cả PSEL và PENABLE đều được active
                o_psel = 1'b1;
                o_penable = 1'b1;
                o_pwrite = mem_write;
                o_paddr = {i_alu_data[31:2], 2'b00}; // Địa chỉ được căn chỉnh word
                o_pwdata = mem_wdata;
            end
            
            default: begin
                // IDLE state
                o_psel = 1'b0;
                o_penable = 1'b0;
                o_pwrite = 1'b0;
                o_paddr = 32'b0;
                o_pwdata = 32'b0;
            end
        endcase
    end

endmodule