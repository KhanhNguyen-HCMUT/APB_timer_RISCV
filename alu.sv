module alu(
input logic [3:0] alu_op,
input logic [31:0] operand_a, operand_b,
output logic [31:0] alu_data
);

logic [32:0] compare_a, compare_b, compare_data;

always_comb begin
case(alu_op)
4'd0: begin
alu_data = operand_a + operand_b; //ADD
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd1: begin
alu_data = operand_a + ~operand_b + 32'd1; //SUB
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd2: begin
case(operand_b[4:0]) //SLL
5'h0: alu_data = operand_a;
5'h1: alu_data = {operand_a[30:0], 1'h0};
5'h2: alu_data = {operand_a[29:0], 2'h0};
5'h3: alu_data = {operand_a[28:0], 3'h0};
5'h4: alu_data = {operand_a[27:0], 4'h0};
5'h5: alu_data = {operand_a[26:0], 5'h0};
5'h6: alu_data = {operand_a[25:0], 6'h0};
5'h7: alu_data = {operand_a[24:0], 7'h0};
5'h8: alu_data = {operand_a[23:0], 8'h0};
5'h9: alu_data = {operand_a[22:0], 9'h0};
5'hA: alu_data = {operand_a[21:0], 10'h0};
5'hB: alu_data = {operand_a[20:0], 11'h0};
5'hC: alu_data = {operand_a[19:0], 12'h0};
5'hD: alu_data = {operand_a[18:0], 13'h0};
5'hE: alu_data = {operand_a[17:0], 14'h0};
5'hF: alu_data = {operand_a[16:0], 15'h0};
5'h10: alu_data = {operand_a[15:0], 16'h0};
5'h11: alu_data = {operand_a[14:0], 17'h0};
5'h12: alu_data = {operand_a[13:0], 18'h0};
5'h13: alu_data = {operand_a[12:0], 19'h0};
5'h14: alu_data = {operand_a[11:0], 20'h0};
5'h15: alu_data = {operand_a[10:0], 21'h0};
5'h16: alu_data = {operand_a[9:0], 22'h0};
5'h17: alu_data = {operand_a[8:0], 23'h0};
5'h18: alu_data = {operand_a[7:0], 24'h0};
5'h19: alu_data = {operand_a[6:0], 25'h0};
5'h1A: alu_data = {operand_a[5:0], 26'h0};
5'h1B: alu_data = {operand_a[4:0], 27'h0};
5'h1C: alu_data = {operand_a[3:0], 28'h0};
5'h1D: alu_data = {operand_a[2:0], 29'h0};
5'h1E: alu_data = {operand_a[1:0], 30'h0};
5'h1F: alu_data = {operand_a[0:0], 31'h0};
default: alu_data = 32'h0;
endcase
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd3: begin //SLT
if(operand_a[31]) compare_a = {1'b1,operand_a};
else compare_a = {1'b0,operand_a};
if(operand_b[31]) compare_b = {1'b1,operand_b};
else compare_b = {1'b0,operand_b};
compare_data = compare_a + ~compare_b + 33'd1;
if(compare_data[32]) alu_data = 32'd1;
else alu_data = 32'd0;
end
4'd4: begin //SLTU
compare_a = {1'b0, operand_a};
compare_b = {1'b0, operand_b};
compare_data = compare_a + ~compare_b + 33'd1;
if(compare_data[32]) alu_data = 32'd1;
else alu_data = 32'd0;
end
4'd5: begin
alu_data = operand_a ^ operand_b; //XOR
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd6: begin
case(operand_b[4:0]) //SRL
5'h0: alu_data = operand_a;
5'h1: alu_data = {1'h0, operand_a[31:1]};
5'h2: alu_data = {2'h0, operand_a[31:2]};
5'h3: alu_data = {3'h0, operand_a[31:3]};
5'h4: alu_data = {4'h0, operand_a[31:4]};
5'h5: alu_data = {5'h0, operand_a[31:5]};
5'h6: alu_data = {6'h0, operand_a[31:6]};
5'h7: alu_data = {7'h0, operand_a[31:7]};
5'h8: alu_data = {8'h0, operand_a[31:8]};
5'h9: alu_data = {9'h0, operand_a[31:9]};
5'hA: alu_data = {10'h0, operand_a[31:10]};
5'hB: alu_data = {11'h0, operand_a[31:11]};
5'hC: alu_data = {12'h0, operand_a[31:12]};
5'hD: alu_data = {13'h0, operand_a[31:13]};
5'hE: alu_data = {14'h0, operand_a[31:14]};
5'hF: alu_data = {15'h0, operand_a[31:15]};
5'h10: alu_data = {16'h0, operand_a[31:16]};
5'h11: alu_data = {17'h0, operand_a[31:17]};
5'h12: alu_data = {18'h0, operand_a[31:18]};
5'h13: alu_data = {19'h0, operand_a[31:19]};
5'h14: alu_data = {20'h0, operand_a[31:20]};
5'h15: alu_data = {21'h0, operand_a[31:21]};
5'h16: alu_data = {22'h0, operand_a[31:22]};
5'h17: alu_data = {23'h0, operand_a[31:23]};
5'h18: alu_data = {24'h0, operand_a[31:24]};
5'h19: alu_data = {25'h0, operand_a[31:25]};
5'h1A: alu_data = {26'h0, operand_a[31:26]};
5'h1B: alu_data = {27'h0, operand_a[31:27]};
5'h1C: alu_data = {28'h0, operand_a[31:28]};
5'h1D: alu_data = {29'h0, operand_a[31:29]};
5'h1E: alu_data = {30'h0, operand_a[31:30]};
5'h1F: alu_data = {31'h0, operand_a[31:31]};
default: alu_data = 32'h0;
endcase
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd7: begin
if(operand_a[31]) begin //SRA
case(operand_b[4:0]) //SRL
5'h0: alu_data = operand_a;
5'h1: alu_data = {1'h1, operand_a[31:1]};
5'h2: alu_data = {2'h3, operand_a[31:2]};
5'h3: alu_data = {3'h7, operand_a[31:3]};
5'h4: alu_data = {4'hF, operand_a[31:4]};
5'h5: alu_data = {5'h1F, operand_a[31:5]};
5'h6: alu_data = {6'h3F, operand_a[31:6]};
5'h7: alu_data = {7'h7F, operand_a[31:7]};
5'h8: alu_data = {8'hFF, operand_a[31:8]};
5'h9: alu_data = {9'h1FF, operand_a[31:9]};
5'hA: alu_data = {10'h3FF, operand_a[31:10]};
5'hB: alu_data = {11'h7FF, operand_a[31:11]};
5'hC: alu_data = {12'hFFF, operand_a[31:12]};
5'hD: alu_data = {13'h1FFF, operand_a[31:13]};
5'hE: alu_data = {14'h3FFF, operand_a[31:14]};
5'hF: alu_data = {15'h7FFF, operand_a[31:15]};
5'h10: alu_data = {16'hFFFF, operand_a[31:16]};
5'h11: alu_data = {17'h1FFFF, operand_a[31:17]};
5'h12: alu_data = {18'h3FFFF, operand_a[31:18]};
5'h13: alu_data = {19'h7FFFF, operand_a[31:19]};
5'h14: alu_data = {20'hFFFFF, operand_a[31:20]};
5'h15: alu_data = {21'h1FFFFF, operand_a[31:21]};
5'h16: alu_data = {22'h3FFFFF, operand_a[31:22]};
5'h17: alu_data = {23'h7FFFFF, operand_a[31:23]};
5'h18: alu_data = {24'hFFFFFF, operand_a[31:24]};
5'h19: alu_data = {25'h1FFFFFF, operand_a[31:25]};
5'h1A: alu_data = {26'h3FFFFFF, operand_a[31:26]};
5'h1B: alu_data = {27'h7FFFFFF, operand_a[31:27]};
5'h1C: alu_data = {28'hFFFFFFF, operand_a[31:28]};
5'h1D: alu_data = {29'h1FFFFFFF, operand_a[31:29]};
5'h1E: alu_data = {30'h3FFFFFFF, operand_a[31:30]};
5'h1F: alu_data = {31'h7FFFFFFF, operand_a[31:31]};
default: alu_data = 32'hFFFFFFFF;
endcase
end
else begin
case(operand_b[4:0])
5'h0: alu_data = operand_a;
5'h1: alu_data = {1'h0, operand_a[31:1]};
5'h2: alu_data = {2'h0, operand_a[31:2]};
5'h3: alu_data = {3'h0, operand_a[31:3]};
5'h4: alu_data = {4'h0, operand_a[31:4]};
5'h5: alu_data = {5'h0, operand_a[31:5]};
5'h6: alu_data = {6'h0, operand_a[31:6]};
5'h7: alu_data = {7'h0, operand_a[31:7]};
5'h8: alu_data = {8'h0, operand_a[31:8]};
5'h9: alu_data = {9'h0, operand_a[31:9]};
5'hA: alu_data = {10'h0, operand_a[31:10]};
5'hB: alu_data = {11'h0, operand_a[31:11]};
5'hC: alu_data = {12'h0, operand_a[31:12]};
5'hD: alu_data = {13'h0, operand_a[31:13]};
5'hE: alu_data = {14'h0, operand_a[31:14]};
5'hF: alu_data = {15'h0, operand_a[31:15]};
5'h10: alu_data = {16'h0, operand_a[31:16]};
5'h11: alu_data = {17'h0, operand_a[31:17]};
5'h12: alu_data = {18'h0, operand_a[31:18]};
5'h13: alu_data = {19'h0, operand_a[31:19]};
5'h14: alu_data = {20'h0, operand_a[31:20]};
5'h15: alu_data = {21'h0, operand_a[31:21]};
5'h16: alu_data = {22'h0, operand_a[31:22]};
5'h17: alu_data = {23'h0, operand_a[31:23]};
5'h18: alu_data = {24'h0, operand_a[31:24]};
5'h19: alu_data = {25'h0, operand_a[31:25]};
5'h1A: alu_data = {26'h0, operand_a[31:26]};
5'h1B: alu_data = {27'h0, operand_a[31:27]};
5'h1C: alu_data = {28'h0, operand_a[31:28]};
5'h1D: alu_data = {29'h0, operand_a[31:29]};
5'h1E: alu_data = {30'h0, operand_a[31:30]};
5'h1F: alu_data = {31'h0, operand_a[31:31]};
default: alu_data = 32'h0;
endcase
end
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd8: begin
alu_data = operand_a | operand_b; //OR
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd9: begin
alu_data = operand_a & operand_b; //AND
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
4'd10: begin
alu_data = operand_b; //IMM passthrough
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
default: begin//If none
alu_data = 0; 
compare_a = 0;
compare_b = 0;
compare_data = 0;
end
endcase
end
endmodule
