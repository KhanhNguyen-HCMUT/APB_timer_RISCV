module regfile(
input logic [0:0] clk_i, rst_ni, rd_wren,
input logic [4:0] rs1_addr, rs2_addr, rd_addr,
input logic [31:0] rd_data,
output logic [31:0] rs1_data, rs2_data
);

logic [31:0] reg_array [1:31];

always_ff @ (posedge clk_i or negedge rst_ni) begin
if(~rst_ni) begin
reg_array <= '{default:32'd0};
end
else begin
if(rd_wren) begin
reg_array[rd_addr] <= rd_data;
end
end
end
always_comb begin
if(!rs1_addr[4] && !rs1_addr[3] && !rs1_addr[2] && !rs1_addr[1] && !rs1_addr[0]) rs1_data = 32'd0;
else rs1_data = reg_array[rs1_addr];
if(!rs2_addr[4] && !rs2_addr[3] && !rs2_addr[2] && !rs2_addr[1] && !rs2_addr[0]) rs2_data = 32'd0;
else rs2_data = reg_array[rs2_addr];
end
endmodule