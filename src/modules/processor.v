module processor(
  input  clock,
  input  reset,
  input  exec,
  
  input [15:0] inpval1, inpval2,
  
  input  [15:0] ir_m_q,
  output reg [15:0] ir_m_data,
  output ir_m_rw,
  output reg [11:0] ir_m_addr,
  
  input  [15:0] main_m_q,
  output reg [15:0] main_m_data,
  output reg main_m_rw,
  output reg [11:0] main_m_addr,

  output [15:0] outval1,     // output value
  output [15:0] outval2,
  output [2:0] outsel,        // if output instruction
  output outdisplay
  );
    
  ///////////////////////////
  //   P1
  ///////////////////////////
  
  reg [15:0] p1_PC;
  assign ir_m_rw = 0;
  wire [15:0] p1_IR = ir_m_q;
  
  wire p1_RegWrite, p1_MemtoReg, p1_RegDst, p1_ALUSrc, p1_PCSrc;
  
  reg stall = 0; // stop to increment PC
  
  controller controller_(
    .clock(clock), .reset(reset), .exec(exec),
    .instr(p1_IR),
    .RegWrite(p1_RegWrite),
    .MemtoReg(p1_MemtoReg),
    .RegDst(p1_RegDst),
    .ALUSrc(p1_ALUSrc),
    .PCSrc(p1_PCSrc)
  );
  
  always @(posedge clock) begin
    ir_m_addr <= p1_PC;
  end
  
  ///////////////////////////
  //   P2
  ///////////////////////////
  
  reg [15:0] p2_IR;
  wire [2:0] p2_r1 = p2_IR[13:11];
  wire [2:0] p2_r2 = p2_IR[10:8];
  reg [15:0] p2_PC;
  wire [15:0] p2_AR, p2_BR;
  
  reg p2_RegWrite, p2_MemtoReg, p2_RegDst, p2_ALUSrc, p2_PCSrc;
  
  always @(posedge clock) begin
    p2_PC <= p1_PC; p2_IR <= p1_IR;
    // p2_AR, p2_BR <~ register in p5
    
    p2_RegWrite <= p1_RegWrite;
    p2_MemtoReg <= p1_MemtoReg;
    p2_RegDst <= p1_RegDst;
    p2_ALUSrc <= p1_ALUSrc;
    p2_PCSrc <= p1_PCSrc;
  end
  
  wire [15:0] p2_D = sign_ext(p2_IR[7:0]);
  
  ///////////////////////////
  //   P3
  ///////////////////////////
  
  reg [15:0] p3_PC;
  reg [15:0] p3_IR;
  wire [1:0] p3_op1 = p3_IR[15:14];
  wire [3:0] p3_op3 = p3_IR[7:4];
  reg [15:0] p3_AR, p3_BR;
  reg [15:0] p3_D;
  
  reg p3_RegWrite, p3_MemtoReg, p3_RegDst, p3_ALUSrc, p3_PCSrc;

  function [15:0] sign_ext;
    input [7:0] in;
    begin
      sign_ext = {{8{in[7]}}, in[7:0]};
    end
  endfunction
    
  always @(posedge clock) begin
    p3_PC <= p2_PC; p3_IR <= p2_IR;
    p3_D <= p2_D;
    p3_AR <= p2_AR; p3_BR <= p2_BR;

    p3_RegWrite <= p2_RegWrite;
    p3_MemtoReg <= p2_MemtoReg;
    p3_RegDst <= p2_RegDst;
    p3_ALUSrc <= p2_ALUSrc;
    p3_PCSrc <= p2_PCSrc;
  end
  
  wire [15:0] alu_res;
  wire [3:0] SZCV;
  alu_shifter alu_shifter_(
    .a(p3_ALUSrc ? p3_D : p3_AR),
    .b(p3_BR),
    .shift_d(p3_IR[3:0]), .op(p3_op3),
    .res(alu_res), .szcv(SZCV)
  );
  
  wire [15:0] p3_DR = (p3_IR[15:11] == 5'b10000 /*LI*/) ? p3_D : alu_res;
  reg jumped;
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      p1_PC = 0;
    end else if (~stall) begin
      if (p2_IR[15:11] == 5'b10100 /*B*/ ||
          p2_IR[15:8] == 8'b10111000 /*BE*/ & SZCV[2] ||
          p2_IR[15:8] == 8'b10111001 /*BLT*/ & (SZCV[3] ^ SZCV[0]) ||
          p2_IR[15:8] == 8'b10111010 /*BLE*/ & (SZCV[2] || (SZCV[3] ^ SZCV[0])) ||
          p2_IR[15:8] == 8'b10111011 /*BNE*/ & (~ SZCV[2])) begin
        p1_PC <= p2_PC + p2_D;
        jumped <= 1;
      end else begin
        p1_PC <= p1_PC + 1;
        jumped <= 0;
      end
    end
  end
  
  wire [11:0] p3_m_addr = p3_D + p3_AR;
  
  ///////////////////////////
  //   P4
  ///////////////////////////
  
  reg [15:0] p4_PC, p4_IR;
  reg [15:0] p4_D;
  reg [15:0] p4_DR;
  reg [15:0] p4_MR;
  reg [15:0] p4_AR, p4_BR;
  wire [1:0] p4_op1 = p4_IR[15:14]; 
  
  reg p4_RegWrite, p4_MemtoReg, p4_RegDst, p4_PCSrc;
  
  reg [2:0] outsel_; reg outdisplay_;
  assign outsel = outsel_;
  assign outdisplay = outdisplay_;
  assign outval1 = p4_AR;
  assign outval2 = p4_BR;
  
  reg [11:0] p4_addr;
  reg [15:0] p4_data;
  
  wire is_input = (p3_IR[15:14] == 2'b11) && (p3_IR[7:4] == 4'b1100);
  wire is_output = (p3_IR[15:14] == 2'b11) && (p3_IR[7:4] == 4'b1101);
  always @(posedge clock) begin
    p4_PC <= p3_PC; p4_IR <= p3_IR;
    p4_D <= p3_D;
    p4_AR <= p3_AR; p4_BR <= p3_BR;
    
    p4_RegWrite <= p3_RegWrite;
    p4_MemtoReg <= p3_MemtoReg;
    p4_RegDst <= p3_RegDst;
    p4_PCSrc <= p3_PCSrc;

    // Store
    main_m_addr <= p3_m_addr;
    if (p3_IR[15:14] == 2'b01) begin /* ST */
        main_m_data <= p3_BR;
        main_m_rw <= 1;
    end else begin
        main_m_rw <= 0;
    end
    
    // Input
    if (is_input) /* IN */ begin
      p4_DR <= (p3_IR[3:0] == 4'b0000) ? inpval1 : inpval2;
    end else begin
      p4_DR <= p3_DR;
    end
    
    // Output
    if (is_output) /* OUT */ begin
      outsel_ <= p3_IR[2:0];
      outdisplay_ <= 1;
    end else begin
      outdisplay_ <= 0;
    end
  end
  
  ///////////////////////////
  //   P5
  ///////////////////////////
  
  reg [15:0] p5_DR;
  wire [15:0] p5_MDR = main_m_q;
  reg [15:0] p5_IR;
  
  reg p5_RegWrite, p5_MemtoReg, p5_RegDst, p5_PCSrc;

  always @(posedge clock) begin
    p5_IR <= p4_IR;
    p5_DR <= p4_DR;
    
    p5_RegWrite <= p4_RegWrite;
    p5_MemtoReg <= p4_MemtoReg;
    p5_RegDst <= p4_RegDst;
    p5_PCSrc <= p4_PCSrc;
  end
  
  wire [15:0] reg_ar, reg_br;
  register register_(
    .clock(~clock), .reset(reset),
    .ra(p2_r1), .rb(p2_r2),
    .RegWrite(p5_RegWrite), 
    .write_addr(p5_IR[10:8]),

    .write_data(p5_MemtoReg ? p5_MDR : p5_DR),
    .ar(reg_ar), .br(reg_br));
  
  function [15:0]  fetch_reg;
    input [2:0]  regnum, p3_num, p4_num;
    input [15:0] regout, p3_DR, p4_DR;
  begin
    if (p3_RegWrite & (p3_num == regnum)) begin
      fetch_reg = p3_DR;
    end else if (p4_RegWrite & (p4_num == regnum)) begin
      fetch_reg = p4_DR;
    end else begin
      fetch_reg = regout;
    end
  end
  endfunction
  
  assign p2_AR = fetch_reg(p2_r1, p3_IR[10:8], p4_IR[10:8], reg_ar, p3_DR, p4_DR);
  assign p2_BR = fetch_reg(p2_r2, p3_IR[10:8], p4_IR[10:8], reg_br, p3_DR, p4_DR);
  
endmodule
