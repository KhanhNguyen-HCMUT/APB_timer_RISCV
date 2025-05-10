module pc(
    input  logic        clk_i,
    input  logic        i_rst,
    input  logic        write_en,
    input  logic [31:0] data_i,
    output logic [31:0] data_o
);

    logic [31:0] pc_reg;
    logic [1:0]  counter;        // Đếm từ 0 đến 2 (3 chu kỳ)
    logic [31:0] pending_data;  // Dữ liệu chờ ghi sau 3 chu kỳ
    logic        counting;      // Trạng thái đang đếm

    always_ff @ (posedge clk_i or negedge i_rst) begin
        if (~i_rst) begin
            pc_reg       <= 32'd0;
            counter      <= 2'd0;
            pending_data <= 32'd0;
            counting     <= 1'b0;
        end else begin
            if (write_en && !counting) begin
                // Bắt đầu đếm từ chu kỳ 1
                pending_data <= data_i;
                counter      <= 2'd1;
                counting     <= 1'b1;
            end else if (counting) begin
                if (counter == 2'd3) begin
                    pc_reg   <= pending_data;
                    counting <= 1'b0;
                    counter  <= 2'd0;
                end else begin
                    counter <= counter + 1;
                end
            end
        end
    end

    always_comb begin
        data_o = pc_reg;
    end
endmodule
