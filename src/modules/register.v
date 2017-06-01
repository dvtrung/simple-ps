module register (
  input clock, reset,
  input [2:0] ra, rb, write_addr,
  input RegWrite,
  input [15:0] write_data, // data to write
  output [15:0] ar, br
  );

  reg [15:0] r [0:7];

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      r[7] <= 16'b0;
      r[6] <= 16'b0;
      r[5] <= 16'b0;
      r[4] <= 16'b0;
      r[3] <= 16'b0;
      r[2] <= 16'b0;
      r[1] <= 16'b0;
      r[0] <= 16'b0;
    end else begin
      if (RegWrite) begin
        r[write_addr] = write_data;
      end
    end
  end
  
  assign ar = r[ra];
  assign br = r[rb];
endmodule
