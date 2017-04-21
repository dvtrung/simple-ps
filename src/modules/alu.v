module alu(
  input signed [15:0] a, b, 
  input [3:0] op,
  output [15:0] res,
  output [3:0] szcv
  );
  
  reg [16:0] res_;
  reg [3:0] szcv_;
  
  always @(a, b, op) begin
    case (op)
      4'b0000: res_ = a + b;
      4'b0001: res_ = a - b;
      4'b0010: res_ = a & b;
      4'b0011: res_ = a | b;
      4'b0100: res_ = a ^ b;
      4'b0110: res_ = a;
    endcase
    
    szcv_[3] = (res_[15] == 1);  // S: if negative
    szcv_[2] = (res_ == 0); // Z: if equal to zero
    szcv_[1] = res_[16];    // C: if carry exists
    
    szcv_[0] = 0;           // V: if overflow
    if (op == 4'b0000) begin // + operator
      // if a and b have the same sign but res_ not
      szcv_[0] = (a[15] == b[15]) & (res_[15] != a[15]);
    end else if (op == 4'b0001) begin // - operator
      // if a have different size to both b and res_
      szcv_[0] = (a[15] != b[15]) & (res_[15] != a[15]);
    end
  end
  
  assign res = res_[15:0];
  assign szcv = szcv_;
endmodule
