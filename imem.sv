module imem(
input logic [31:0] imem_addr,
output logic [31:0] imem_data
);

logic [31:0] imem [0:2047];
initial $readmemh ("D:/Study/do_an_2/3/test.dump", imem);

always_comb begin
imem_data = imem[imem_addr[12:2]];
end
endmodule
