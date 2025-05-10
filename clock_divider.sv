module Clock_divider (
    input  logic clk_in,      // Đồng hồ đầu vào 50 MHz
    input  logic rst_n,       // Reset tích cực mức thấp
    output logic clk_out      // Đồng hồ đầu ra 10 MHz
);

    // Để chia tần số 50 MHz thành 10 MHz, ta cần chia cho 5
    // Cần một bộ đếm đếm từ 0 đến 4 (5 trạng thái)
    // Sử dụng 3 bit để đảm bảo đủ biểu diễn giá trị
    logic [2:0] counter;
    
    // Tín hiệu chuyển trạng thái
    logic toggle;
    
    // Xử lý bộ đếm
    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'd0;
            toggle <= 1'b0;
        end else begin
            if (counter == 3'd4) begin
                counter <= 3'd0;
                toggle <= ~toggle; // Đổi trạng thái khi đếm đủ
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
    
    // Gán đầu ra
    assign clk_out = toggle;
    
endmodule