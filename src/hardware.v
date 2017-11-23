module hardware (
  input clock, n_reset,
  input [15:0] inpval1,
  input [15:0] inpval2,
  
  output [7:0] led0, led1, led2, led3,
               led4, led5, led6, led7,
  output [7:0] seg_sel,
  output [7:0] oled1, oled2, oled_sel
  );
  
  wire f_clock; // 40MHz(0) -> 60MHz
  atlpll atlpll_(.inclk0(clock), .c0(f_clock));
  
  reg reset;
  
  wire use_clock = f_clock;
  
  wire [15:0] ir_m_data, ir_m_q;
  wire [11:0] ir_m_addr;
  wire ir_m_wren;
  
  ram_ir ir_ram_inc_ (
    .data(ir_m_data), .wren(ir_m_wren), .address(ir_m_addr),
    .clock(~use_clock),
    .q(ir_m_q)
  );
  
  wire [15:0] main_m_data, main_m_q;
  wire [11:0] main_m_addr;
  wire main_m_wren;
  
  ram_main main_ram_inc_ (
    .data(main_m_data), .wren(main_m_wren), .address(main_m_addr),
    .clock(~use_clock),
    .q(main_m_q)
  );
  
  wire exec;
  
  wire [3:0] outsel;
  wire [15:0] outval1;
  wire [15:0] outval2;
  wire outdisplay;
  wire halting;
  
  processor processor_ (
    .clock(use_clock), .reset(reset), .exec(exec),
    .ir_m_q(ir_m_q), .ir_m_data(ir_m_data),
    .ir_m_rw(ir_m_wren), .ir_m_addr(ir_m_addr),
    .main_m_q(main_m_q), .main_m_data(main_m_data),
    .main_m_rw(main_m_wren), .main_m_addr(main_m_addr),
    .inpval1(inpval1), .inpval2({8'b0, inpval2[7:0]}),
    .outval1(outval1), .outval2(outval2), .outsel(outsel), .outdisplay(outdisplay),
    .halting(halting));
  
  out out_ (.clock(use_clock), .reset(reset),
            .outval1(outval1), .outsel(outsel), .outdisplay(outdisplay),
            .led0(led0), .led1(led1),
            .led2(led2), .led3(led3),
            .led4(led4), .led5(led5),
            .led6(led6), .led7(led7),
            .seg_sel(seg_sel));
            
  
  out_counter out_counter_(
    .clock(use_clock), .reset(reset), .halting(halting),
    .led1(oled1), .led2(oled2), .led_sel(oled_sel));
  
  reg [15:0] pushing;
  always @(posedge use_clock) begin
    if (~n_reset) begin
      reset <= pushing == 16'd0;
      pushing <= 16'hfff;
    end else begin
      reset <= 1'd0;
      pushing <= (pushing > 0) ? pushing - 16'd1 : 16'd0;
    end
  end
endmodule
