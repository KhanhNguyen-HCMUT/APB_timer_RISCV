module apb_mux (
    // APB Master Interface (từ CPU)
    input  logic [31:0] M_PADDR,
    input  logic        M_PWRITE,
    input  logic        M_PSEL,
    input  logic        M_PENABLE,
    input  logic [31:0] M_PWDATA,
    output logic [31:0] M_PRDATA,
    output logic        M_PREADY,
    
    // APB Slave Interface 0 (Data Memory: 0x3000 - 0x37FF)
    output logic        S0_PSEL,
    output logic        S0_PENABLE,
    output logic        S0_PWRITE,
    output logic [31:0] S0_PADDR,
    output logic [31:0] S0_PWDATA,
    input  logic [31:0] S0_PRDATA,
    input  logic        S0_PREADY,
    
    // APB Slave Interface 1 (Switch: 0x20)
    output logic        S1_PSEL,
    output logic        S1_PENABLE,
    output logic        S1_PWRITE,
    output logic [31:0] S1_PADDR,
    output logic [31:0] S1_PWDATA,
    input  logic [31:0] S1_PRDATA,
    input  logic        S1_PREADY,
    
    // APB Slave Interface 2 (LED: 0x24)
    output logic        S2_PSEL,
    output logic        S2_PENABLE,
    output logic        S2_PWRITE,
    output logic [31:0] S2_PADDR,
    output logic [31:0] S2_PWDATA,
    input  logic [31:0] S2_PRDATA,
    input  logic        S2_PREADY,
    
    // APB Slave Interface 3 (Timer: 0x0 - 0x18)
    output logic        S3_PSEL,
    output logic        S3_PENABLE,
    output logic        S3_PWRITE,
    output logic [31:0] S3_PADDR,
    output logic [31:0] S3_PWDATA,
    input  logic [31:0] S3_PRDATA,
    input  logic        S3_PREADY
);

    // Địa chỉ ranges cho từng slave
    // Data Memory: 0x3000 - 0x37FF
    // Switch:      0x20
    // LED:         0x24
    // Timer:       0x0 - 0x18
    
    // Decoder logic - chọn slave dựa vào địa chỉ
    always_comb begin
        // Mặc định không chọn slave nào
        S0_PSEL = 1'b0;
        S1_PSEL = 1'b0;
        S2_PSEL = 1'b0;
        S3_PSEL = 1'b0;
        
        if (M_PSEL) begin
            if ((M_PADDR >= 32'h3000) && (M_PADDR <= 32'h3800)) begin
                // Data Memory
                S0_PSEL = 1'b1;
            end
            else if (M_PADDR == 32'h20) begin
                // Switch Register
                S1_PSEL = 1'b1;
            end
            else if (M_PADDR == 32'h24) begin
                // LED Register
                S2_PSEL = 1'b1;
            end
            else if ((M_PADDR >= 32'h0) && (M_PADDR <= 32'h18)) begin
                // Timer Registers (0x0 - 0x18)
                S3_PSEL = 1'b1;
            end
        end
    end
    
    // Forward control signals đến tất cả slaves
    assign S0_PENABLE = M_PENABLE;
    assign S0_PWRITE  = M_PWRITE;
    assign S0_PADDR   = M_PADDR;
    assign S0_PWDATA  = M_PWDATA;
    
    assign S1_PENABLE = M_PENABLE;
    assign S1_PWRITE  = M_PWRITE;
    assign S1_PADDR   = M_PADDR;
    assign S1_PWDATA  = M_PWDATA;
    
    assign S2_PENABLE = M_PENABLE;
    assign S2_PWRITE  = M_PWRITE;
    assign S2_PADDR   = M_PADDR;
    assign S2_PWDATA  = M_PWDATA;
    
    assign S3_PENABLE = M_PENABLE;
    assign S3_PWRITE  = M_PWRITE;
    assign S3_PADDR   = M_PADDR;
    assign S3_PWDATA  = M_PWDATA;
    
    // Multiplexer đầu ra từ slaves
    always_comb begin
        if (S0_PSEL) begin
            M_PRDATA = S0_PRDATA;
            M_PREADY = S0_PREADY;
        end
        else if (S1_PSEL) begin
            M_PRDATA = S1_PRDATA;
            M_PREADY = S1_PREADY;
        end
        else if (S2_PSEL) begin
            M_PRDATA = S2_PRDATA;
            M_PREADY = S2_PREADY;
        end
        else if (S3_PSEL) begin
            M_PRDATA = S3_PRDATA;
            M_PREADY = S3_PREADY;
        end
        else begin
            M_PRDATA = 32'h0;
            M_PREADY = 1'b1;  // Default ready
        end
    end
    
endmodule