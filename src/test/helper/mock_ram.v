//レジスタ配列に格納(memory)
module mock_ram #(
  parameter filename
  )(
  input clock, wren,
  input  [11:0] addr,
  input  [15:0] data,
  output reg [15:0] q
  );
  reg [15:0] rom [0:31];

  initial $readmemh(filename, rom);

  always @(posedge clock) begin
    if (wren) begin
      rom[addr] <= data;
      q <= 16'dx;
    end else begin
      q <= rom[addr];
    end
  end
endmodule