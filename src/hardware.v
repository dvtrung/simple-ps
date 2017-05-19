module hardware (
  input clock, n_reset,
  input [15:0] inpval1,
  input [15:0] inpval2,
  
  output [7:0] led0, led1, led2, led3,
               led4, led5, led6, led7,
  output [7:0] seg_sel,
  output [7:0] oled1, oled2, oled_sel
  );
  
  wire [15:0] ir_m_data, ir_m_q;
  wire [11:0] ir_m_addr;
  wire ir_m_wren;
  
  reg s_clock;
  ram_inc #("../../memories/hlt_test.mif") ir_ram_inc_ (
    .data(ir_m_data), .wren(ir_m_wren), .address(ir_m_addr),
    .clock(~clock),
    .q(ir_m_q)
  );
  
  wire [15:0] main_m_data, main_m_q;
  wire [11:0] main_m_addr;
  wire main_m_wren;
  
  ram_inc #("../../memories/test_stall.mif") main_ram_inc_ (
    .data(main_m_data), .wren(main_m_wren), .address(main_m_addr),
    .clock(~clock),
    .q(main_m_q)
  );
  
  wire exec;

  wire [15:0] inpval;
  inp inp_ (.inp(inp), .inpval(inpval));
    
  wire [2:0] outsel;
  wire [15:0] outval1;
  wire [15:0] outval2;
  wire outdisplay;
  wire halting;
  
  processor processor_ (
    .clock(clock), .reset(~n_reset), .exec(exec),
    .ir_m_q(ir_m_q), .ir_m_data(ir_m_data),
    .ir_m_rw(ir_m_wren), .ir_m_addr(ir_m_addr),
    .main_m_q(main_m_q), .main_m_data(main_m_data),
    .main_m_rw(main_m_wren), .main_m_addr(main_m_addr),
    .inpval1(inpval1), .inpval2({8'b0, inpval2[7:0]}),
    .outval1(outval1), .outval2(outval2), .outsel(outsel), .outdisplay(outdisplay),
    .halting(halting));
  
  out out_ (.clock(clock), .reset(~n_reset),
            .outval1(outval1), .outval2(outval2), .outsel(outsel), .outdisplay(outdisplay),
            .led0(led0), .led1(led1),
            .led2(led2), .led3(led3),
            .led4(led4), .led5(led5),
            .led6(led6), .led7(led7),
            .seg_sel(seg_sel));
            
  
  out_counter out_counter_(
    .clock(clock), .reset(~n_reset), .halting(halting),
    .led1(oled1), .led2(oled2), .led_sel(oled_sel));
endmodule
