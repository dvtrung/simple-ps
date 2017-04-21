module processor(
  input  clock,
  input  reset,
  input  exec,
  input  [15:0] m_q,
  output reg [15:0] m_data,
  output reg m_wren,
  output reg [11:0] m_addr
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
  reg wren;
  initial pc <= 0;
  always @(posedge phase_bus[0]) begin
    wren <= 0; // reset register
    m_addr <= pc;
    m_wren <= 0;
    pc <= pc + 16'd1;  
  end
  
  ////// P2
  reg [4:0] rs, rd, op, sd;
  always @(posedge phase_bus[1]) begin
    // m_data[15:14] == 11
    rs <= m_data[13:11];
    rd <= m_data[13:11];
    op <= m_data[7:4];
    sd <= m_data[3:0];
  end  

  wire [15:0] o_ar, o_br;
  register register_(
    .clock(phase_bus[1] | phase_bus[4]),
    .ra(rs), .rb(rd),
    .wren(0), .data(mdr),
    .ar(o_ar), .br(o_br));

  ////// P3
  reg [15:0] ar, br;
  always @(posedge phase_bus[2]) begin
    ar <= o_ar;
    br <= o_br;
  end
  
  wire o_dr;
  wire [15:0] alu_res;
  alu alu_(
    .a(ar), .b(br), .op(op),
    .res(alu_res));
  
  wire [15:0] shifter_res;
  shifter shifter_(
    .a(ar), .d(br), .op(shfter_op),
    .res(shifter_res));
  
  multiplexer multiplexer_p3(
    .t(alu_res), .f(shifter_res),
    .x(1));

  ////// P4
  reg dr;
  always @(posedge phase_bus[3]) begin
      dr <= o_dr;
  end

  reg [15:0] mdr;
  wire [15:0] written;
  multiplexer multiplexer_p4(
    .t(dr), .f(mdr),
    .x(1)
    );

  ////// P5
  always @(posedge phase_bus[4]) begin
    wren <= 1;
    mdr <= m_data;
  end

endmodule
