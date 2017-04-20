module alu(
  input [15:0] a, b, 
  input [3:0] op,
  output reg [15:0] res
  );
  
  always @(a, b, op) begin
    case (op)
      4'b0000: res = a + b;
      4'b0001: res = a - b;
      4'b0010: res = a & b;
      4'b0011: res = a | b;
      4'b0100: res = a ^ b;
      4'b0110: res = a;
    endcase
  end
endmodule
