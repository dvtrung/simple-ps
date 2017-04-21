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
  wire [2:0] phase;
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
  reg [2:0] rs, rd;
  reg [3:0] op, sd;
  reg [16:0] inst;
  always @(posedge phase_bus[0]) begin
    wren <= 0; // reset register
    m_addr <= pc;
    m_wren <= 0;
    pc <= pc + 16'd1;
    
    inst <= m_q;
    // m_q[15:14] == 11
    rs <= m_q[13:11];
    rd <= m_q[10:8];
    op <= m_q[7:4];
    sd <= m_q[3:0];
  end
  
  ////// P2

  wire [15:0] o_ar, o_br;
  reg [15:0] mdr;
  wire [15:0] written;
  register register_(
    .clock(phase_bus[1] | phase_bus[4]), .reset(reset_ps),
    .ra(rs), .rb(rd),
    .write(wren), .data(written),
    .ar(o_ar), .br(o_br));

  wire [15:0] r0 = register_.r[0];
  wire [15:0] r1 = register_.r[1];
  wire [15:0] r2 = register_.r[2];
  wire [15:0] r3 = register_.r[3];
  wire [15:0] r4 = register_.r[4];
  wire [15:0] r5 = register_.r[5];
  wire [15:0] r6 = register_.r[6];
  wire [15:0] r7 = register_.r[7];

  reg [15:0] ar, br;
  always @(posedge phase_bus[1]) begin
    ar <= o_ar;
    br <= o_br;
  end  

  ////// P3
  wire [15:0] alu_res;
  alu alu_(
    .a(ar), .b(br), .op(op),
    .res(alu_res));
  
  wire [15:0] shifter_res;
  reg [1:0] shifter_op;
  shifter shifter_(
    .a(ar), .d(sd), .op(shifter_op),
    .res(shifter_res));
  
  wire [15:0] o_dr = 1 ? alu_res : shifter_res;
  
  reg [15:0] dr;
  always @(posedge phase_bus[2]) begin
    dr <= o_dr;
  end
  
  ////// P4
  always @(posedge phase_bus[3]) begin
    mdr <= m_q;
    wren <= 1;
  end

  ////// P5
  assign written = 1 ? dr : mdr;
  always @(posedge phase_bus[4]) begin
  end

endmodule
