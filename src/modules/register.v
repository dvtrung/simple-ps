module register (
  input clock, reset,
  input [2:0] ra, rb, write_addr,
  input RegWrite,
  input [15:0] write_data, // data to write
  output [15:0] ar, br
  );

  reg [15:0] r [0:7];
  integer i;

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 8 ; i = i + 1)
        r[i] <= 16'b0;
    end else begin
      if (RegWrite) begin
        r[write_addr] = write_data;
      end
    end
  end

  assign ar = r[ra];
  assign br = r[rb];
endmodule
