module brcomp(
input logic [31:0] rs1_data, rs2_data,
input logic [0:0] br_unsigned,
output logic [0:0] br_less, br_equal
);

logic [31:0] equal_data;
logic [32:0] xtended_rs1, xtended_rs2, xtended_data;

always_comb begin
if(br_unsigned) begin
xtended_rs1 = {1'b0, rs1_data};
xtended_rs2 = {1'b0, rs2_data};
end
else begin
if(rs1_data[31]) begin
xtended_rs1 = {1'b1, rs1_data};
end
else begin
xtended_rs1 = {1'b0, rs1_data};
end;
if(rs2_data[31]) begin
xtended_rs2 = {1'b1, rs2_data};
end
else begin
xtended_rs2 = {1'b0, rs2_data};
end
end
xtended_data = xtended_rs1 + ~xtended_rs2 + 33'd1;
if(xtended_data[32]) begin
br_less = 1'd1;
end
else begin
br_less = 1'd0;
end

//br_equal
equal_data = ~(rs1_data ^ rs2_data); //XNOR
br_equal = &equal_data[31:0]; //AND all the bits together
end
endmodule
