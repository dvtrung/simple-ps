module processor(
  input  clock,
  input  reset,
  input  exec,
  input  [15:0] m_q,
  output reg [15:0] m_data,
  output reg m_rw,
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
  
  ////// p1
  reg [15:0] p1_PC;
  initial p1_PC <= 0;
  
  reg [15:0] p2_IR;
  wire [2:0] p2_r1 = p2_IR[13:11];
  wire [2:0] p2_r2 = p2_IR[10:8];
  wire [7:0] p2_ld = p2_IR[7:0];
  
  always @(posedge phase_bus[0]) begin
    m_addr <= p1_PC;
    m_rw <= 0;
    p1_PC <= p1_PC + 16'd1;
    p2_IR <= m_q;
  end
  
  ////// p2
  reg [15:0] p3_IR;
  wire [1:0] p3_op1 = p3_IR[15:14];
  wire [3:0] p3_op3 = p3_IR[7:4];
  wire [3:0] p3_d = p3_IR[3:0];
  reg [15:0] p3_AR, p3_BR;
  reg [15:0] p3_D;
  reg r_rw;
  
  wire [15:0] r_data;
  wire [15:0] ar_res, br_res;
  register register_(
    .clock(phase_bus[1] | phase_bus[4]), .reset(reset_ps),
    .ra(p2_r1), .rb(p2_r2),
    .write(r_rw), .data(r_data),
    .ar(ar_res), .br(br_res));

  wire [15:0] r0 = register_.r[0];
  wire [15:0] r1 = register_.r[1];
  wire [15:0] r2 = register_.r[2];
  wire [15:0] r3 = register_.r[3];
  wire [15:0] r4 = register_.r[4];
  wire [15:0] r5 = register_.r[5];
  wire [15:0] r6 = register_.r[6];
  wire [15:0] r7 = register_.r[7];

  function [15:0] sign_ext;
    input [7:0] in;
    begin
      sign_ext = {{8{in[7]}}, in[7:0]};
    end
  endfunction 
    
  always @(posedge phase_bus[1]) begin
    p3_D <= sign_ext(p2_ld);
    p3_IR <= p2_IR;
    p3_AR <= ar_res;
    p3_BR <= br_res;
  end  

  ////// P3
  reg [15:0] p4_DR;
  reg [3:0] p4_SZCV;
  reg [15:0] p4_D;
  reg [15:0] p4_IR;
  wire [1:0] p4_op1 = p4_IR[15:14]; 
  
  wire [15:0] alu_res;
  wire [3:0] szcv_res;
  alu alu_(
    .a(p3_AR), .b(p3_BR), .op(p3_op3),
    .res(alu_res), .szcv(szcv_res));
  
  wire [15:0] shifter_res;
  shifter shifter_(
    .a(p3_BR), .d(p3_d), .op(p3_op3),
    .res(shifter_res));

  function [15:0] mux_dr;
    input [4:0] op3;
  begin
    case (op3[3:2])
      2'b00: mux_dr = alu_res;
      2'b01: mux_dr = alu_res;
      2'b10: mux_dr = shifter_res;
      // TODO:OTHER
    endcase
  end
  endfunction
  
  always @(posedge phase_bus[2]) begin
    p4_DR <= mux_dr(p3_op3);
    p4_SZCV <= szcv_res;
    p4_IR <= p3_IR;
    p4_D <= p3_D;
  end
  
  ////// P4
  reg [15:0] p5_DDR;
  reg [3:0] p5_SZCV;
  reg [15:0] p5_MDR;
  
  always @(posedge phase_bus[3]) begin
    p5_DDR <= p4_DR;
    p5_MDR <= m_q;
    case (p4_op1)
      2'b00:
        r_rw <= 0;
      default:
        r_rw <= 1;
    endcase
  end

  ////// P5
  assign r_data = 1 ? p5_DDR : p5_MDR;
  always @(posedge phase_bus[4]) begin
  end
endmodule
