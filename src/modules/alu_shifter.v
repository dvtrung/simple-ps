module alu_shifter(
  input signed [15:0] a, b, 
  input [3:0] shift_d,
  input [3:0] op,
  output signed [15:0] res,
  output [3:0] szcv
  );
  
  reg [15:0] reg_d1, reg_d2;
  reg signed [15:0] res_, res__; 
  reg [16:0] reg_d; 
  reg [3:0] szcv_;
  
  always @(*) begin
    case (op)
      4'b0000: begin          // ADD
        res_ <= b + a;
        //szcv_[1] <= res_[16]; // C: if carry exists
      end
      4'b0001: begin          // SUB
        res_ <= b - a;
        //szcv_[1] <= res_[16]; // C: if carry exists
      end
      4'b0010: res_ <= a & b;  // AND
      4'b0011: res_ <= a | b;  // OR
      4'b0100: res_ <= a ^ b;  // XOR
      
      4'b0110: res_ <= a;      // MOV
      
      4'b0101: begin          // CMP
        res_ <= b;
        res__ <= b - a;
        szcv_[1] <= res_[16];
      end
      4'b1000: begin // SLL: Shift left logical
        res_ <= b << shift_d;
        reg_d = b << (shift_d - 1);
        szcv_[1] = reg_d[15];
      end
      4'b1001: begin // SLR: Shift left rotate
        reg_d1 <= b << shift_d;
        reg_d2 <= b >> -shift_d;
        res_ <= reg_d1 | reg_d2;
        reg_d = b << (shift_d - 1);
        szcv_[1] = reg_d[15];
      end
      4'b1010: begin // SRL: Shift right logical
        reg_d1 <= b >> shift_d;
        res_ <= reg_d1;
        reg_d <= b >> (shift_d - 1);
        szcv_[1] = reg_d[0];
      end
      4'b1011: begin // SRA: Shift right arithmetic
        reg_d1 <= b >>> shift_d;
        res_ <= reg_d1;
        reg_d <= b >> (shift_d - 1);
        szcv_[1] = reg_d[0];
      end
      default: szcv_[1] <= 0;
    endcase
    
    if (op == 4'b0101 /*CMP*/) begin
      szcv_[3] <= (res__[15] == 1);  // S: if negative
      szcv_[2] <= (res__ == 0); // Z: if equal to zero
    end else begin
      szcv_[3] <= (res_[15] == 1);  // S: if negative
      szcv_[2] <= (res_ == 0); // Z: if equal to zero
    end
    
    if (op == 4'b0000 /*ADD*/) begin
      szcv_[0] = (a[15] == b[15]) & (res_[15] != b[15]);
    end else if (op == 4'b0001 /*SUB*/) begin
      szcv_[0] = (a[15] != b[15]) & (res_[15] != b[15]);
    end else if (op == 4'b0101 /*CMP*/) begin
      szcv_[0] = (a[15] != b[15]) & (res__[15] != b[15]);
    end else begin
      szcv_[0] = 0;           // V: if overflow
    end
  end
  
  assign res = res_[15:0];
  assign szcv = szcv_;
endmodule
