module top (
    input  logic        clk,         // Clock
    input  logic        rst,         // Reset, active high
    output logic        interrupt,
    output logic [31:0] hw_leds,
    input  logic [31:0]	hw_switches,
    output logic [63:0] cnt
);
    logic clk_out;
    
    // Các tín hiệu APB bus chính từ CPU
    logic [31:0] cpu_paddr;
    logic        cpu_pwrite;
    logic        cpu_psel;
    logic        cpu_penable;
    logic [31:0] cpu_pwdata;
    logic [31:0] cpu_prdata;
    logic        cpu_pready;
    
    // Các tín hiệu APB cho Data Memory
    logic        dmem_psel;
    logic        dmem_penable;
    logic        dmem_pwrite;
    logic [31:0] dmem_paddr;
    logic [31:0] dmem_pwdata;
    logic [31:0] dmem_prdata;
    logic        dmem_pready;
    
    // Các tín hiệu APB cho Switch
    logic        switch_psel;
    logic        switch_penable;
    logic        switch_pwrite;
    logic [31:0] switch_paddr;
    logic [31:0] switch_pwdata;
    logic [31:0] switch_prdata;
    logic        switch_pready;
    
    // Các tín hiệu APB cho LED
    logic        led_psel;
    logic        led_penable;
    logic        led_pwrite;
    logic [31:0] led_paddr;
    logic [31:0] led_pwdata;
    logic [31:0] led_prdata;
    logic        led_pready;
    
    // Các tín hiệu APB cho Timer
    logic        timer_psel;
    logic        timer_penable;
    logic        timer_pwrite;
    logic [31:0] timer_paddr;
    logic [31:0] timer_pwdata;
    logic [31:0] timer_prdata;
    logic        timer_pready;
    
    // Instantiate clock divider
    Clock_divider clock(
	.clk_in(clk),
	.rst_n(rst),
	.clk_out(clk_out)
    );
    
    // Instantiate RISC-V single cycle CPU
    singlecycle cpu (
        .i_clk      (clk_out),
        .i_rst      (rst),
        
        // APB master interface
        .o_paddr    (cpu_paddr),
        .o_pwrite   (cpu_pwrite),
        .o_psel     (cpu_psel),
        .o_penable  (cpu_penable),
        .o_pwdata   (cpu_pwdata),
        .i_prdata   (cpu_prdata),
        .i_pready   (cpu_pready)
    );
    
    // Instantiate APB Multiplexer
    apb_mux apb_mux_inst (
        // Master (CPU)
        .M_PADDR    (cpu_paddr),
        .M_PWRITE   (cpu_pwrite),
        .M_PSEL     (cpu_psel),
        .M_PENABLE  (cpu_penable),
        .M_PWDATA   (cpu_pwdata),
        .M_PRDATA   (cpu_prdata),
        .M_PREADY   (cpu_pready),
        
        // Slave 0 (Data Memory)
        .S0_PSEL    (dmem_psel),
        .S0_PENABLE (dmem_penable),
        .S0_PWRITE  (dmem_pwrite),
        .S0_PADDR   (dmem_paddr),
        .S0_PWDATA  (dmem_pwdata),
        .S0_PRDATA  (dmem_prdata),
        .S0_PREADY  (dmem_pready),
        
        // Slave 1 (Switch)
        .S1_PSEL    (switch_psel),
        .S1_PENABLE (switch_penable),
        .S1_PWRITE  (switch_pwrite),
        .S1_PADDR   (switch_paddr),
        .S1_PWDATA  (switch_pwdata),
        .S1_PRDATA  (switch_prdata),
        .S1_PREADY  (switch_pready),
        
        // Slave 2 (LED)
        .S2_PSEL    (led_psel),
        .S2_PENABLE (led_penable),
        .S2_PWRITE  (led_pwrite),
        .S2_PADDR   (led_paddr),
        .S2_PWDATA  (led_pwdata),
        .S2_PRDATA  (led_prdata),
        .S2_PREADY  (led_pready),        
        // Slave 3 (Timer)
        .S3_PSEL    (timer_psel),
        .S3_PENABLE (timer_penable),
        .S3_PWRITE  (timer_pwrite),
        .S3_PADDR   (timer_paddr),
        .S3_PWDATA  (timer_pwdata),
        .S3_PRDATA  (timer_prdata),
        .S3_PREADY  (timer_pready)
    );
    
    // Instantiate APB Data Memory (2KB)
    apb_data_memory data_mem (
        .PCLK       (clk_out),
        .PRESETn    (rst),
        .PSEL       (dmem_psel),
        .PENABLE    (dmem_penable),
        .PWRITE     (dmem_pwrite),
        .PADDR      (dmem_paddr),
        .PWDATA     (dmem_pwdata),
        .PRDATA     (dmem_prdata),
        .PREADY     (dmem_pready)
    );
    
    // Instantiate APB Switch
    apb_switch switch_peripheral (
        .PCLK          (clk_out),
        .PRESETn       (rst),
        .PSEL          (switch_psel),
        .PENABLE       (switch_penable),
        .PWRITE        (switch_pwrite),
        .PADDR         (switch_paddr),
        .PWDATA        (switch_pwdata),
        .PRDATA        (switch_prdata),
        .PREADY        (switch_pready),
        .i_switch_value(hw_switches)  // Kết nối với switch phần cứng
    );
    
    // Instantiate APB LED
    apb_led led_peripheral (
        .PCLK          (clk_out),
        .PRESETn       (rst),
        .PSEL          (led_psel),
        .PENABLE       (led_penable),
        .PWRITE        (led_pwrite),
        .PADDR         (led_paddr),
        .PWDATA        (led_pwdata),
        .PRDATA        (led_prdata),
        .PREADY        (led_pready),
        .o_led_value   (hw_leds)      // Kết nối với LED phần cứng
    );
    
// Instantiate APB Timer
timer_top timer(
	.sys_clk(clk_out),
	.sys_rst_n(rst),
	.tim_paddr(timer_paddr),
	.tim_penable(timer_penable),
	.tim_pwdata(timer_pwdata),
	.tim_pwrite(timer_pwrite),
	.tim_prdata(timer_prdata),
	.tim_int(interrupt),
	.tim_pready(timer_pready),
	.tim_psel(timer_psel), 
	.cnt(cnt)
);
    
endmodule