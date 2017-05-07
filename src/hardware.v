module hardware (
  input clock, n_reset,
  input [15:0] inp,
  
  output [7:0] led0, led1, led2, led3,
               led4, led5, led6, led7,
  output [7:0] seg_sel,
  output reg [7:0] oled
  );
  
  wire [15:0] m_data, m_q;//, pc;
  wire [11:0] m_addr;
  wire m_wren;
  reg s_clock;
  ram_inc #("../../memories/test_output.mif") ram_inc_ (
    .data(m_data), .wren(m_wren), .address(m_addr),
    .clock(~clock),
    .q(m_q)
  );
  
  wire exec, rw;

  wire [15:0] inpval;
  inp inp_ (.inp(inp), .inpval(inpval));
  
  wire [15:0] reg_watch, ir;
  wire [2:0] phase;
  
  wire [2:0] outsel;
  wire [15:0] outval1;
  wire [15:0] outval2;
  
  processor processor_ (
    .clock(clock), .reset(~n_reset), .exec(exec),
    .m_q(m_q), .m_data(m_data), .m_rw(rw), .m_addr(m_addr),
    .reg_watch(reg_watch), .pc(pc), .phase(phase), .ir(ir),
    .outval1(outval1), .outval2(outval2), .outsel(outsel));
  
  out out_ (.clock(clock), .reset(~n_reset),
            .outval1(outval1), .outval2(outval2), .outsel(outsel),
            .led0(led0), .led1(led1),
            .led2(led2), .led3(led3),
            .led4(led4), .led5(led5),
            .led6(led6), .led7(led7),
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
  end
endmodule
