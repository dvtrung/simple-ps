module hardware (
  input clock, n_reset, exec, rw,
  input [15:0] inp,
  
  output [7:0] led0, led1, led2, led3,
               led4, led5, led6, led7,
  output [7:0] seg_sel,
  output reg [7:0] oled,
  
  output [15:0] m_q,
  output [15:0] pc
  );
  
  wire [15:0] m_data;//, m_q;
  wire [11:0] m_addr;
  wire m_wren;
  reg s_clock;
  ram_inc #("../../memories/test_output.mif") ram_inc_ (
    .data(m_data), .wren(m_wren), .address(m_addr),
    .clock(~clock),
    .q(m_q)
  );
  
  // wire [2:0] sel = 3'b000;
  wire [15:0] inpval;
  inp inp_ (.inp(inp), .inpval(inpval));
  
  wire [15:0] reg_watch, ir;
  wire [2:0] phase;
  
  wire [15:0] outval1__;
  wire [15:0] outval2__;
  reg [15:0] outval1_;
  reg [15:0] outval2_;
  wire [2:0] outsel;// = 3'b0;
  reg [2:0] outsel2 = 3'b000;
  wire outdisplay;
  reg outdisplay_flag = 0;
  reg outdisplay_flag1[0:7];
  reg outdisplay_flag2[0:7];
  reg outdisplay_flag1_, outdisplay_flag2_;
  reg [3:0] outsel_flag = 4'b0000;
  
  reg [15:0] outval1 [0:7];
  reg [15:0] outval2 [0:7];
  
  processor processor_ (
    .clock(clock), .reset(~n_reset), .exec(exec),
    .m_q(m_q), .m_data(m_data), .m_rw(rw), .m_addr(m_addr),
    .reg_watch(reg_watch), .pc(pc), .phase(phase), .ir(ir),
    .outval1(outval1__), .outval2(outval2__), .outsel(outsel));
  
  out out_ (.clock(clock),
            .outval1(outval1_), .outval2(outval2_), .sel(outsel2),
            .led0(led0), .led1(led1),
            .led2(led2), .led3(led3),
            .led4(led4), .led5(led5),
            .led6(led6), .led7(led7),
            .display_out1(outdisplay_flag1_), .display_out2(outdisplay_flag2_),
            .seg_sel(seg_sel));
            

  reg cnt = 0;
  always @(posedge clock) begin
    oled[0] <= ~n_reset;
    oled[1] <= cnt;
    cnt <= ~cnt;
    oled[2] <= (phase == 3'd0);
    oled[3] <= (phase == 3'd1);
    oled[4] <= (phase == 3'd2);
    oled[5] <= (phase == 3'd3);
    oled[6] <= (phase == 3'd4);
    
    //outval1[5] = 16'b0000000000000111;
    //outdisplay_flag1[5] = 1;
    
    if (outsel_flag == 4'b0000) begin 
      outsel2 <= outsel2 + 1;
    end else begin
      outval1_ <= outval1[outsel2];
      outval2_ <= outval2[outsel2];
      outdisplay_flag1_ <= outdisplay_flag1[outsel2];
      outdisplay_flag2_ <= outdisplay_flag2[outsel2];
    end
    outsel_flag <= outsel_flag + 1;
    
    if (outsel !== 3'bXXX) begin
      if (outval1__[15] !== 1'bX) begin
        outval1[outsel] <= outval1__;
        outdisplay_flag1[outsel] <= 1;
      end
      if (outval2__[15] !== 1'bX) begin
        //outval2[outsel] <= outval2__;
        //outdisplay_flag2[outsel] <= 1;
      end
      //outsel <= outsel + 1;
    end
  end
endmodule
