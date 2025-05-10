module register(
    input  wire [31:0] addr,
    input  wire [31:0] tcr,
    input  wire [31:0] tier,
    input  wire [31:0] tisr,
    input  wire [31:0] tdr_0,
    input  wire [31:0] tdr_1,
    input  wire [31:0] tcmp0,
    input  wire [31:0] tcmp1,
    input  wire        rd_en,
    output wire [31:0] rdata
);

    // Multiplexer cho dữ liệu đọc
    reg [31:0] rdata_int;
    
    always @(*) begin
        if (rd_en) begin
            case (addr)
                32'h0:  rdata_int = tcr;
                32'h4:  rdata_int = tdr_0;
                32'h8:  rdata_int = tdr_1;
                32'hC:  rdata_int = tcmp0;
                32'h10: rdata_int = tcmp1;
                32'h14: rdata_int = tier;
                32'h18: rdata_int = tisr;
                default: rdata_int = 32'h0;
            endcase
        end else begin
            rdata_int = 32'h0;
        end
    end
    
    assign rdata = rdata_int;
    
endmodule