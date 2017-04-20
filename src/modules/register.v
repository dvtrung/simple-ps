module register (
  input clock, reset,
  input [2:0] add1, add2, addw,
  input write,
  input [15:0] wd, // data to write
  output [15:0] ar, br);
  
  reg [15:0] r [0:7];
  integer i;
  
  always @ (posedge clock or negedge reset) begin
    if (reset) begin
      for (i = 0; i < 8 ; i = i + 1)
        r[i] = 16'b0;
    end
    
    if (write) begin
      r[addw] = wd;
    end
  end
  
  assign ar = r[add1];
  assign br = r[add2];
endmodule