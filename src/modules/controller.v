module controller(
  input clock, reset, exec,
  output reg [2:0] phase, 
  output reg [4:0] phase_bus,
  output reg reset_ps
  );
  
  initial phase <= 3'd0;
  always @(clock) begin
    if(reset) begin
      phase <= 0;
      phase_bus <= 5'd4;
    end else begin
      if(clock) begin
        if(phase >= 4) begin
          phase <= 0;
        end else begin
          phase <= phase + 3'd1;
        end
        phase_bus <= {
          phase == 4,
          phase == 3,
          phase == 2,
          phase == 1,
          phase == 0};
      end else begin
        phase_bus <= 5'd0;
      end
    end
    
    reset_ps <= reset; // TODO: ONESHOT
  end
endmodule
