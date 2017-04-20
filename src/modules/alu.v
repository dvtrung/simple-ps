module alu(
  input [15:0] a, b, 
  input [3:0] op,
  output reg [15:0] res
  );
  
  always @(a, b, op) begin
	case (op)
	  3'b0000: res = a + b;
	endcase
  end
endmodule
