module shifter(
  input [15:0] a, 
  input [3:0] d,
  input [3:0] op, // 00: SLL  | 01: SLR | 10: SRL | 11: SRA
  output reg [15:0] res
  );
  
  always @(a, d, op) begin
    case (op[1:0])
      2'b00: // Shift left logical
        res <= a << d;
      2'b01: // Shift left rotate
        res <= (a << d) | (a >> - d); 
      2'b10: // Shift right logical
        res <= a >> d;
      2'b11: // Shift right rotate
        res <= (a >> d) | (a << - d);
    endcase
  end
endmodule
