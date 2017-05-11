module hardware (
  input clock, n_reset,
  input [15:0] inpval1,
  input [15:0] inpval2,
  
  output [7:0] led0, led1, led2, led3,
               led4, led5, led6, led7,
  output [7:0] seg_sel,
  output reg [7:0] oled
  );
  
  wire [15:0] m_data, m_q;
  wire [11:0] m_addr;
  wire m_wren;
  reg s_clock;
  ram_inc #("../../memories/test_output.mif") ram_inc_ (
    .data(m_data), .wren(m_wren), .address(m_addr),
    .clock(~clock),
    .q(m_q)
  );
  
  wire exec;

  wire [15:0] inpval;
  inp inp_ (.inp(inp), .inpval(inpval));
    
  wire [2:0] outsel;
  wire [15:0] outval1;
  wire [15:0] outval2;
  wire outdisplay;
  
  processor processor_ (
    .clock(clock), .reset(~n_reset), .exec(exec),
    .m_q(m_q), .m_data(m_data), .m_rw(m_wren), .m_addr(m_addr),
    .inpval1(inpval1), .inpval2(inpval2),
    .outval1(outval1), .outval2(outval2), .outsel(outsel), .outdisplay(outdisplay));
  
  out out_ (.clock(clock), .reset(~n_reset),
            .outval1(outval1), .outval2(outval2), .outsel(outsel), .outdisplay(outdisplay),
            .led0(led0), .led1(led1),
            .led2(led2), .led3(led3),
            .led4(led4), .led5(led5),
            .led6(led6), .led7(led7),
            .seg_sel(seg_sel));
            

  always @(posedge clock) begin
    oled <= inpval1[7:0];
  end
endmodule
