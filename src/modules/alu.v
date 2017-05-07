module alu(
  input signed [15:0] a, b, 
  input [3:0] op,
  output [15:0] res,
  output [3:0] szcv
  );
  
  reg [16:0] res_; reg[16:0] res__;
  reg [3:0] szcv_;
  
  always @(*) begin
    case (op)
      4'b0000: begin          // ADD
        res_ <= a + b;
        szcv_[1] <= res_[16]; // C: if carry exists
      end
      4'b0001: begin          // SUB
        res_ <= a - b;
        szcv_[1] <= res_[16]; // C: if carry exists
      end
      4'b0010: res_ <= a & b;  // AND
      4'b0011: res_ <= a | b;  // OR
      4'b0100: res_ <= a ^ b;  // XOR
      
      4'b0110: res_ <= b;      // MOV
      
      4'b0101: begin          // CMP
        res_ <= a;
        szcv_[1] = res__[16];
      end
      4'b1000: begin // SLL: Shift left logical
        res_ <= a << (b - 1);
        szcv_[1] <= res_[15];
        res_ <= res_ << 1;
      end
      4'b1001: begin // SLR: Shift left rotate
        res_ <= a << (b - 1);
        szcv_[1] <= res_[15];
        res_ <= res_ << 1;
        res_ <= res_ | (a >> - b); 
      end
      4'b1010: begin // SRL: Shift right logical
        res_ <= a >> (b - 1);
        szcv_[1] <= res_[0];
        res_ <= res_ >> 1;
      end
      4'b1011: begin // SRA: Shift right arithmetic
        res_ <= a >> (b - 1);
        szcv_[1] <= res_[0];
        res_ <= res_ >> 1;
        res_ <= res_ | (a << - b);
      end
      default: szcv_[1] <= 0;
    endcase
    
    szcv_[3] <= (res_[15] == 1);  // S: if negative
    szcv_[2] <= (res_ == 0); // Z: if equal to zero
    
    if (op == 4'b0101) begin // CMP
      res__ <= a - b;
    end
    
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
