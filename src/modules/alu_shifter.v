module alu_shifter(
  input signed [15:0] a, b, 
  input [3:0] shift_d,
  input [3:0] op,
  output signed [15:0] res,
  output [3:0] szcv
  );
  function signed [16:0] alu_res;
    input [3:0] op;
    input [3:0] d;
    input signed [16:0] a, b;
  begin
    case (op)
      4'b0000: alu_res = b + a; // ADD
      4'b0001: alu_res = b - a; // SUB
      4'b0010: alu_res = a & b; // AND
      4'b0011: alu_res = a | b; // OR
      4'b0100: alu_res = a ^ b; // XOR
      
      4'b0110: alu_res = a;     // MOV
      4'b0101: alu_res = b;     // CMP
      
      4'b1000: begin // SLL: Shift left logical
        alu_res = b << shift_d;
      end
      4'b1001: begin // SLR: Shift left rotate
        alu_res = (b << shift_d) | {1'd0, (b[15:0] >> -shift_d)};
      end
      4'b1010: begin // SRL: Shift right logical
        alu_res = b[15:0] >> shift_d;
      end
      4'b1011: begin // SRA: Shift right arithmetic
        alu_res = b >>> shift_d;
      end
      default: alu_res = 16'hXXXX;
    endcase
  end
  endfunction
  
  wire [17:0] alu_res_ = alu_res(op, shift_d, {a[15], a}, {b[15], b});
    
  assign res = alu_res_[16:0];
  
  function [3:0] alu_v;
    input [3:0] op;
    input signed [15:0] a, b, res;
  begin
    case (op)
      4'b0000: begin // ADD
        alu_v = (a[15] == b[15]) & (res[15] != b[15]);
      end
      4'b0001: begin // SUB
        alu_v = (a[15] != b[15]) & (res[15] != b[15]);
      end
      default: alu_v = 1'bx;
    endcase
  end
  endfunction
  
  assign szcv[0] = alu_res(op, a, b, res);
  
  function [1:0] alu_sz;
    input [3:0] op;
    input signed [15:0] a, b, res, ba;
  begin
    if (op == 4'b0101 /*CMP*/) begin
      alu_sz = {ba[15] == 1,  // S: if negative
                ba == 0}; // Z: if equal to zero
    end else begin
      alu_sz = {res[15] == 1,  // S: if negative
                res == 0}; // Z: if equal to zero
    end
  end
  endfunction
  
  assign szcv[3:2] = alu_sz(op, a, b, res, b - a);
  
  assign szcv[1] = 1'b0; // TODO: C
endmodule
