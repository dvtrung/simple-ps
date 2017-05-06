module register (
  input clock, reset,
  input [2:0] ra, rb,
  input write,
  input [15:0] data, // data to write
  output [15:0] ar, br
  );

  reg [15:0] r [0:7];
  integer i;

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 8 ; i = i + 1)
        r[i] <= 16'b0;
    end else begin
      if (write) begin
        r[rb] = data;
      end
    end
  end

  assign ar = r[ra];
  assign br = r[rb];
endmodule
