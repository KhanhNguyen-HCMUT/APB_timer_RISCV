module apb_data_memory (
    // APB Slave Interface
    input  logic        PCLK,        // Clock
    input  logic        PRESETn,     // Reset, active low
    input  logic        PSEL,        // Slave select
    input  logic        PENABLE,     // Enable
    input  logic        PWRITE,      // Write (1) or read (0)
    input  logic [31:0] PADDR,       // Address
    input  logic [31:0] PWDATA,      // Write data
    output logic [31:0] PRDATA,      // Read data
    output logic        PREADY       // Slave ready
);

    // Memory: 2kB = 2048 bytes = 512 words (32-bit each)
    // 512 words = 2^9 words, needs 9 address bits
    logic [31:0] mem [0:511];
    
    // Word address (divide byte address by 4)
    logic [8:0] word_addr;
    assign word_addr = PADDR[10:2];  // Bits [10:2] for 512 words
    
    // Địa chỉ bắt đầu từ 0x0, nên không cần xử lý offset
    
    // APB ready signal - luôn sẵn sàng trong 1 cycle
    assign PREADY = 1'b1;
    
    // Xử lý ghi memory
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // Reset memory (optional, có thể bỏ qua để tiết kiệm tài nguyên)
            for (int i = 0; i < 512; i++) begin
                mem[i] <= 32'h0;
            end
        end 
        else if (PSEL && PENABLE && PWRITE && ((PADDR >= 32'h3000) && (PADDR <= 32'h3800))) begin
            // Ghi dữ liệu khi đang ở APB access phase
            mem[word_addr] <= PWDATA;
        end
    end
    
    // Xử lý đọc memory
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= 32'h0;
        end 
        else if (PSEL && !PWRITE && ((PADDR >= 32'h3000) && (PADDR <= 32'h3800))) begin
            // Đọc dữ liệu khi PSEL active và PWRITE không active
            PRDATA <= mem[word_addr];
        end
        else begin
            PRDATA <= 32'h0;
        end
    end
    
endmodule