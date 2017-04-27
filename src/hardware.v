module hardware (
  input  clock, reset, exec, rw,
  input [15:0] inp,
  
  output [7:0] led0,
  output [7:0] led1,
  output [7:0] led2,
  output [7:0] led3
  );
  
  wire [15:0] m_data, m_q;
    ram_inc #("../../memories/some_inst.mif") ram_inc_ (
    .data(m_data), .wren(m_wren), .address(m_addr),
    .clock(clock),
    .q(m_q)
  );
  reg [11:0] m_addr;
  
  wire [2:0] sel;
  assign sel = 3'b000;
  
  inp inp_ (.inp(inp), .inpval(inpval));
  processor processor_ (.clock(clock), .reset(reset), .exec(exec),
    .m_q(m_q), .m_data(m_data), .m_rw(rw), .m_addr(m_addr));
  out out_ (.led0(led0), .led1(led1), .led2(led2), .led3(led3), .outval1(m_data), .sel(sel));
endmodule
