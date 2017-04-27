module shifter(
  input [15:0] a, 
  input [3:0] d,
  input [1:0] op, // 00: SLL  | 01: SLR | 10: SRL | 11: SRA
  output [15:0] res,
  output [3:0] szcv
  );
  
  reg [3:0] szcv_;
  reg [15:0] res_;
  
  always @(a, d, op) begin
    szcv_[3] <= 0; // S
    szcv_[2] <= 0; // Z
    szcv_[0] <= 0; // V
    if (d == 0) begin
      res_ <= a;
      szcv_[1] = 0;
    end else begin
      case (op)
        2'b00: begin // SLL: Shift left logical
          res_ = a << (d - 1);
          szcv_[1] = res_[15];
          res_ = res_ << 1;
        end
        2'b01: begin // SLR: Shift left rotate
          res_ = a << (d - 1);
          szcv_[1] = res_[15];
          res_ = res_ << 1;
          res_ = res_ | (a >> - d); 
        end
        2'b10: begin // SRL: Shift right logical
          res_ = a >> (d - 1);
          szcv_[1] = res_[0];
          res_ = res_ >> 1;
        end
        2'b11: begin // SRA: Shift right arithmetic
          res_ = a >> (d - 1);
          szcv_[1] = res_[0];
          res_ = res_ >> 1;
          res_ = res_ | (a << - d);
        end
      endcase
    end
  end
  assign szcv = szcv_;
  assign res = res_;
endmodule
