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
  
  wire [15:0] p1_IR = m_q;
  wire [2:0] p1_r1 = p1_IR[13:11];
  wire [2:0] p1_r2 = p1_IR[10:8];

  reg r_rw;
  always @(posedge phase_bus[0]) begin
    m_addr <= p1_PC;
    m_rw <= 0;
    r_rw <= 0;
    p1_PC <= p1_PC + 16'd1;
  end
  
  ////// p2
  reg [15:0] p2_IR;
  wire [7:0] p2_ld = p2_IR[7:0];
  reg [15:0] p2_PC;
  wire [15:0] r_data;
  wire [15:0] ar_res, br_res;
  
  wire [2:0] r_wb;
  register register_(
    .clock(~(phase_bus[1] | phase_bus[4])), .reset(reset_ps),
    .ra(p1_r2), .rb(r_wb),
    .write(r_rw), .data(r_data),
    .ar(ar_res), .br(br_res));

  function [15:0] sign_ext;
    input [7:0] in;
    begin
      sign_ext = {{8{in[7]}}, in[7:0]};
    end
  endfunction 
    
  always @(posedge phase_bus[1]) begin
    p2_IR <= p1_IR;
    p2_PC <= p1_PC;
  end  

  ////// P3
  reg [15:0] p3_PC;
  reg [15:0] p3_IR;
  wire [1:0] p3_op1 = p3_IR[15:14];
  wire [3:0] p3_op3 = p3_IR[7:4];
  wire [3:0] p3_d = p3_IR[3:0];
  reg [15:0] p3_AR, p3_BR;
  reg [15:0] p3_D;

  always @(posedge phase_bus[2]) begin
    p3_PC <= p2_PC;
    p3_D <= sign_ext(p2_ld);
    p3_IR <= p2_IR;
    p3_AR <= ar_res;
    p3_BR <= br_res;
  end
  
  wire [15:0] alu_res;
  wire [3:0] alu_szcv;
  alu alu_(
    .a(p3_AR), .b(p3_BR), .op(p3_op3),
    .res(alu_res), .szcv(alu_szcv));
  
  wire [15:0] shifter_res;
  wire [3:0] shifter_szcv;
  shifter shifter_(
    .a(p3_AR), .d(p3_d), .op(p3_op3[1:0]),
    .res(shifter_res), .szcv(shifter_szcv));

  function [15:0] mux_dr;
    input [15:0] ir;
    input [15:0] alu, shifter, br, d, pc;
  begin
    case (ir[15:14])
      2'b11: case (ir[7:6])
        2'b00: mux_dr = alu;
        2'b01: mux_dr = alu;
        2'b10: mux_dr = shifter;
        2'b11: mux_dr = 16'hX1;
      endcase
      2'b01: mux_dr = br; /*ST*/
      2'b10: mux_dr = (ir[13:11] == 3'b000) ? d /*LI*/
                                            : pc + d; /*JP*/
      2'b11: mux_dr = 16'hX1;
    endcase
  end
  endfunction
  
  wire [15:0] dr_res = mux_dr(p3_IR,
    alu_res, shifter_res, p3_BR, p3_D, p3_PC);
  
  ////// P4
  reg [15:0] p4_PC;
  reg [15:0] p4_DR;
  reg [3:0] p4_SZCV;
  reg [15:0] p4_MR;
  reg [15:0] p4_IR;
  wire [1:0] p4_op1 = p4_IR[15:14]; 

  always @(posedge phase_bus[3]) begin
    p4_PC <= p3_PC;
    p4_DR <= dr_res;
    p4_SZCV <= p3_op3[0] ? shifter_szcv : alu_szcv;
    p4_IR <= p3_IR;
    p4_MR <= p3_AR + p3_D;
    m_addr <= p3_AR + p3_D;
    m_rw <= (p3_op1 == 2'b01 /*ST*/);
    m_data <= dr_res;
  end
  
  function mux_r_rw;
    input [15:0] ir;
  begin
    case (ir[15:14])
      2'b11: mux_r_rw = (ir[7:4] != 4'b0101 /*CMP*/);
      2'b00: mux_r_rw = 1; // LD
      2'b01: mux_r_rw = 0; // ST
      2'b10: mux_r_rw = (ir[13:11] == 3'b000 /*LI*/);
    endcase
  end
  endfunction

  ////// P5
  reg [15:0] p5_DR;
  reg [3:0] p5_SZCV;
  reg [15:0] p5_MDR;
  reg [15:0] p5_IR;
  reg [15:0] p5_r_wb;

  assign r_data = (p4_IR[15:14] == 2'b00 /*LD*/) ? p5_MDR : p5_DR;
  assign r_wb = r_rw ? p5_r_wb : p1_r1;
  always @(posedge phase_bus[4]) begin
    p5_IR <= p4_IR;
    p5_DR <= p4_DR;
    p5_MDR <= m_q;
    p5_SZCV <= p4_SZCV;
    m_rw <= 0;
    r_rw <= mux_r_rw(p4_IR);
    p5_r_wb <= (p4_IR[15:14] == 2'b00) ? p4_IR[13:11] /*LD*/
                                       : p4_IR[10:8];
  end
endmodule
