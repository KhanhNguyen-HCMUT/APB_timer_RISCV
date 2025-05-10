module apb_switch (
    // APB Slave Interface
    input  logic        PCLK,        // Clock
    input  logic        PRESETn,     // Reset, active low
    input  logic        PSEL,        // Slave select
    input  logic        PENABLE,     // Enable
    input  logic        PWRITE,      // Write (1) or read (0)
    input  logic [31:0] PADDR,       // Address
    input  logic [31:0] PWDATA,      // Write data (không sử dụng)
    output logic [31:0] PRDATA,      // Read data
    output logic        PREADY,      // Slave ready
    
    // Hardware switch inputs
    input  logic [31:0] i_switch_value  // Giá trị từ các switch phần cứng
);
    // Địa chỉ của thanh ghi switch: 0x20
    localparam SWITCH_REG_ADDR = 32'h20;
    
    // Tín hiệu nội bộ
    logic addr_match;
    logic apb_read;
    
    // Kiểm tra địa chỉ có khớp với địa chỉ của switch register không
    assign addr_match = (PADDR == SWITCH_REG_ADDR);
    
    // Enable đọc khi địa chỉ khớp, PSEL active, PENABLE active và không phải là ghi
    // Tuân theo đúng giao thức APB - đọc trong pha truy cập (access phase)
    assign apb_read = addr_match && PSEL && PENABLE && !PWRITE;
    
    // Luôn sẵn sàng đáp ứng trong 1 cycle
    assign PREADY = 1'b1;
    
    // Xử lý đọc giá trị switch - sử dụng logic tổ hợp thay vì always_ff
    always_comb begin
        if (apb_read) begin
            // Trả về giá trị hiện tại của switch khi đọc
            PRDATA = i_switch_value;
        end
        else begin
            PRDATA = 32'h0;
        end
    end
    
    // Lưu ý: Thiết kế này bỏ qua bất kỳ yêu cầu ghi nào đến địa chỉ switch
    // Điều này phù hợp với yêu cầu là switch chỉ có thể đọc
    
endmodule