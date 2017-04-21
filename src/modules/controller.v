module controller(
  input clock, reset, exec,
  output reg [2:0] phase, 
  output reg [4:0] phase_bus,
  output reg reset_ps
  );
  
  initial phase <= 3'd0;
  always @(posedge clock) begin
    phase <= phase + 3'd1;
    if(phase >= 4) begin
      phase <= 0;
    end
    phase_bus <= {
      phase == 4,
      phase == 3,
      phase == 2,
      phase == 1,
      phase == 0};
    reset_ps <= reset; // TODO: ONESHOT
  end
endmodule
