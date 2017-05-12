module processor(
  input  clock,
  input  reset,
  input  exec,
  input  [15:0] m_q,
  
  input inpval1,
  input inpval2,
  
  output [15:0] m_data,
  output m_rw,
  output [11:0] m_addr,
  
  output [15:0] outval1,     // output value
  output [15:0] outval2,
  output [2:0] outsel,        // if output instruction
  output outdisplay
  );
  
  reg stall = 0;
  reg [11:0] mdr_addr_;
  reg [15:0] mdr_data_;
  assign m_data = mdr_data_;
  assign m_addr = mdr_addr_;
  
  ///////////////////////////
  //   P1
  ///////////////////////////
  
  reg [15:0] p1_PC;
  assign m_rw = 0;
  wire [15:0] p1_IR = m_q;
  reg p1_r_rw;
  
  wire p1_RegWrite, p1_MemtoReg, p1_RegDst, p1_ALUSrc, p1_PCSrc;
  
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
    p1_r_rw <= 0;
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
    if (~stall) begin
      p2_PC <= p1_PC; 
      p2_IR <= p1_IR;
    end
    // p2_AR, p2_BR <~ register in p5
    p2_RegWrite <= p1_RegWrite;
    p2_MemtoReg <= p1_MemtoReg;
    p2_RegDst <= p1_RegDst;
    p2_ALUSrc <= p1_ALUSrc;
    p2_PCSrc <= p1_PCSrc;
  end
  
  ///////////////////////////
  //   P3
  ///////////////////////////
  
  reg [15:0] p3_PC;
  reg [15:0] p3_IR;
  wire [1:0] p3_op1 = p3_IR[15:14];
  wire [3:0] p3_op3 = p3_IR[7:4];
  reg [15:0] p3_AR, p3_BR;
  wire signed [15:0] p3_DR;
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
    
    p3_D <= sign_ext(p2_IR[7:0]);
    p3_AR <= p2_AR; p3_BR <= p2_BR;
    
    p3_RegWrite <= p2_RegWrite;
    p3_MemtoReg <= p2_MemtoReg;
    p3_RegDst <= p2_RegDst;
    p3_ALUSrc <= p2_ALUSrc;
    p3_PCSrc <= p2_PCSrc;
  end
  
  wire [3:0] p3_SZCV;
  alu_shifter alu_shifter_(
    .a(p3_AR), .b(p3_ALUSrc ? p3_D : p3_BR), 
    .shift_d(p3_IR[3:0]), .op(p3_op3),
    .res(p3_DR), .szcv(p3_SZCV)
  );

  ///////////////////////////
  //   P4
  ///////////////////////////
  
  reg [15:0] p4_PC, p4_IR;
  reg [15:0] p4_D;
  reg signed [15:0] p4_DR;
  reg [3:0] p4_SZCV; //TODO: SZCV is not pipeline register.
  reg [15:0] p4_MR;
  reg [15:0] p4_AR, p4_BR;
  wire [1:0] p4_op1 = p4_IR[15:14]; 
  //reg p4_m_rw;
  
  reg p4_RegWrite, p4_MemtoReg, p4_RegDst, p4_PCSrc;
  
  reg [2:0] outsel_; reg outdisplay_;
  assign outsel = outsel_;
  assign outdisplay = outdisplay_;
  assign outval1 = p4_AR;
  assign outval2 = p4_BR;
  
  reg [11:0] p4_addr;
  reg [15:0] p4_data;
  always @(posedge clock) begin
    p4_PC <= p3_PC; p4_IR <= p3_IR;
    p4_DR <= p3_DR;
    p4_SZCV <= p3_SZCV;
    p4_D = p3_D;
    p4_AR <= p3_AR; p4_BR <= p3_BR;
    
    p4_RegWrite <= p3_RegWrite;
    p4_MemtoReg <= p3_MemtoReg;
    p4_RegDst <= p3_RegDst;
    p4_PCSrc <= p3_PCSrc;

    // Load / store
    //if (p2_IR[15:14] == 2'b00) begin /* LD */
    //  if (stall == 0) begin
    //    stall <= 1;
    //    p4_addr <= p4_DR;
    //  end else begin
    //    stall <= 0;
    //    p4_D <= mdr_addr_;
    //  end
    //end else if (p2_IR[15:14] == 2'b01) begin /* ST */
    //  stall <= 1;
    //end
    //p4_MR <= p3_BR + p3_DR;
    //
    //p4_m_rw <= (p3_op1 == 2'b01 /*ST*/);
    //p4_data <= p4_DR;
    
    // Input
    if ((p3_IR[15:14] == 2'b11) && (p3_IR[7:4] == 4'b1100)) /* IN */ begin
      p4_D = (p3_D == 16'b0) ? inpval1 : inpval2;
    end
    
    // Output
    if ((p3_IR[15:14] == 2'b11) && (p3_IR[7:4] == 4'b1101)) /* OUT */ begin
      outsel_ <= p3_IR[2:0];
      outdisplay_ <= 1;
    end else begin
      outdisplay_ <= 0;
    end
  end
  //assign m_data = p4_m_data;
  //assign m_addr = p1_addr;//fill_bus[0] ? p1_m_addr :
                  //fill_bus[3] ? p4_m_addr : 12'hX;

  ///////////////////////////
  //   P5
  ///////////////////////////
  
  reg [15:0] p5_DR, p5_D;
  reg [3:0] p5_SZCV;
  reg [15:0] p5_MDR;
  reg [15:0] p5_IR;
  reg [15:0] p5_r_wb;
  
  reg p5_RegWrite, p5_MemtoReg, p5_RegDst, p5_PCSrc;

  //assign m_rw = fill_bus[0] ? p1_m_rw : 
  //              fill_bus[3] ? p4_m_rw : 
  //              fill_bus[4] ? p5_m_rw : 0;
  always @(posedge clock) begin
    p5_IR <= p4_IR;
    p5_DR <= p4_DR;
    p5_D <= p4_D;
    p5_MDR <= m_q;
    p5_SZCV <= p4_SZCV;
    
    p5_RegWrite <= p4_RegWrite;
    p5_MemtoReg <= p4_MemtoReg;
    p5_RegDst <= p4_RegDst;
    p5_PCSrc <= p4_PCSrc;
    
    //p5_r_rw <= mux_r_rw(p4_IR);
    //p5_r_wb <= (p4_IR[15:14] == 2'b00) ? p4_IR[13:11] /*LD*/
    //                                   : p4_IR[10:8];
  end
  
  register register_(
    .clock(clock), .reset(reset),
    .ra(p2_r1), .rb(p2_r2 /*r_wb*/),
    .RegWrite(stall ? 0 : p5_RegWrite), 
    .write_addr(p5_RegDst ? p5_IR[10:8] : p5_IR[13:11]),
    .write_data(p5_MemtoReg ? p5_D : p5_DR),
    .ar(p2_AR), .br(p2_BR));
  
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      p1_PC <= 0;
    end else if (~stall) begin
      p1_PC <= p1_PC + 1;
      //TODO: PC changed in p1 and **p3**
    end
    mdr_addr_ <= /*stall ? p4_addr : */p1_PC;
  end
endmodule