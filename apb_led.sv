module apb_led (
    // APB Slave Interface
    input  logic        PCLK,        // Clock
    input  logic        PRESETn,     // Reset, active low
    input  logic        PSEL,        // Slave select
    input  logic        PENABLE,     // Enable
    input  logic        PWRITE,      // Write (1) or read (0)
    input  logic [31:0] PADDR,       // Address
    input  logic [31:0] PWDATA,      // Write data
    output logic [31:0] PRDATA,      // Read data
    output logic        PREADY,      // Slave ready
    
    // Hardware LED outputs
    output logic [31:0] o_led_value  // Giá trị đầu ra điều khiển LED
);
logic wr_en;
logic rd_en;

assign wr_en = PRESETn & PSEL & PENABLE & PWRITE;
assign rd_en = PRESETn & PSEL & PENABLE & !PWRITE;
assign PREADY = PRESETn & PSEL & PENABLE;

wire o_led_value_wr_sel;

assign o_led_value_wr_sel = wr_en & (PADDR == 32'h24);

always@(posedge PCLK or negedge PRESETn)begin
if(PRESETn == 0) o_led_value <= 32'h0;
else begin
case(o_led_value_wr_sel)
1'h0: o_led_value <= o_led_value;
1'h1: o_led_value <= PWDATA;
endcase
end
end
   
   always @(*) begin
        if (rd_en) begin
            case (PADDR)
                32'h0:  PRDATA = o_led_value;
                default: PRDATA = 32'h0;
            endcase
        end else begin
            PRDATA = 32'h0;
        end
    end
    
endmodule