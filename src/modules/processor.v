module processor(
  input  clock,
  input  reset,
  input  exec,
  input  [15:0] m_q,
  output [15:0] m_data,
  output m_wren,
  output [11:0] m_addr
  );
  
  ////// Controller
  wire [3:0] phase;
  wire reset_ps;
  wire [4:0] phase_bus;
  controller controller_(
    .clock(clock), .reset(reset), .exec(exec),
    .phase(phase), .phase_bus(phase_bus),
    .reset_ps(reset_ps));
  
  ////// P1
  reg [15:0] pc;
  initial pc <= 0;

  reg [15:0] inst;
  
  always @(posedge phase_bus[0]) begin
    wren <= 0; // reset register
    m_addr <= pc;
    m_wren <= 0;
    pc <= pc + 1;  
  end
  ////// P2
  reg [15:0] rs, rd, sd;
  wire [15:0] o_ar, o_br;
  reg [15:0] ar, br;
  
  register register_(
    .clock(phase_bus[1] or phase_bus[4]), .ra(rs), .rb(rd),
    .wren(0), .data(mdr),
    .ar(o_ar), .br(o_br));
  
  always @(posedge phase_bus[1]) begin
    // m_data[15:14] == 11
    rs <= m_data[13:11];
    rd <= m_data[13:11];
    op <= m_data[7:4];
    sd <= m_data[3:0];
  end
  ////// P3
  reg dr;
  wire o_dr;
  reg [15:0] alu_res;
  alu alu_(
    .a(ar), .b(br), .op(op),
    .res(alu_res))
  
  reg [15:0] shifter_res;
  shifter shifter_(
    .a(ar), .d(br), .op(shfter_op),
    .res(shifter_res));
  
  p3_multiplexer(
    .alu_res(alu_res), .shifter_res(shifter_res),
    .dr(o_dr));

  always @(posedge phase_bus[2]) begin
    ar <= o_ar;
    br <= o_br;
  end
  ////// P4
  reg [15:0] mdr;
  
  wire [15:0] written;
  p4_multiplexer(
    mdr, dr,
    written);
  
  always @(posedge phase_bus[3]) begin
      dr <= o_dr
  end
  ////// P5
  
  always @(posedge phase_bus[4]) begin
      wren <= 1;
      ar <=   
  end
  
endmodule
